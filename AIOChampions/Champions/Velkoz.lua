
local loaded = false
local forcedTarget
local qMissile
local qHitPoints
local lastSpellCast = Game.Timer()
local qPointsUpdatedAt = Game.Timer()
local qLastChecked = 1
enemyPaths = {}

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

local function GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

local function GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

local function PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

local function GetLineTargetCount(source, Pos, delay, speed, width)
	local Count = 0
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 1050 and IsValid(minion) then
			
			local predictedPos = PredictUnitPosition(minion, delay+ GetDistance(source, minion.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (minion.boundingRadius + width) * (minion.boundingRadius + width)) then
				Count = Count + 1
			end
		end
	end
	return Count
end

local function CheckEnemyCollision(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 1200
	end
	for i, hero in ipairs(GetEnemyHeroes()) do
		if IsValid(hero) and GetDistance(hero.pos, location) < maxDistance then
			local predictedPosition = PredictUnitPosition(hero, delay)
			if GetDistance(location, predictedPosition) < radius + hero.boundingRadius then
				return true, hero
			end
		end
	end
	
	return false
end

local function CheckMinionIntercection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 1200
	end
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion.isEnemy and minion.isTargetable and minion.alive and GetDistance(minion.pos, location) < maxDistance then
			local predictedPosition = PredictUnitPosition(minion, delay)
			if GetDistance(location, predictedPosition) <= radius + minion.boundingRadius then
				return true
			end
		end
	end
	
	return false
end

local function CalculateNode(missile, nodePos)
	local result = {}
	result["pos"] = nodePos
	result["delay"] = 0.251 + GetDistance(missile.pos, nodePos) / Q.Speed
	
	local isCollision = false
	local hitEnemy 
	if not isCollision then
		isCollision, hitEnemy = CheckEnemyCollision(nodePos, 35, result["delay"])
	end
	
	result["playerHit"] = hitEnemy
	result["collision"] = isCollision
	return result
end

local function IsQActive()
	return qMissile and qMissile.name and qMissile.name == "VelkozQMissile"
end

local function IsRActive()
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "VelkozR" then
		return true
	else
		return false
	end
end

local function CheckCol(source, startPos, minion, endPos, delay, speed, range, radius)
	if source.networkID == minion.networkID then 
		return false
	end
	
	if _G.SDK and _G.SDK.Orbwalker and startPos and minion and minion.pos and minion.type ~= myHero.type and _G.SDK.HealthPrediction:GetPrediction(minion, delay + GetDistance(startPos, minion.pos) / speed - Game.Latency()/1000) < 0 then
		return false
	elseif _G.PremiumOrbwalker and startPos and minion and minion.pos and minion.type ~= myHero.type and _G.PremiumOrbwalker:GetHealthPrediction(minion, delay + GetDistance(startPos, minion.pos) / speed - Game.Latency()/1000) < 0 then
		return false	
	end
	
	local waypoints = GetPathNodes(minion)
	local MPos, CastPosition = #waypoints == 1 and Vector(minion.pos) or PredictUnitPosition(minion, delay)
	
	if startPos and MPos and GetDistanceSqr(startPos, MPos) <= (range)^2 and GetDistanceSqr(startPos, minion.pos) <= (range + 100)^2 then
		local buffer = (#waypoints > 1) and 8 or 0 
		
		if minion.type == myHero.type then
			buffer = buffer + minion.boundingRadius
		end
		
		if #waypoints > 1 then
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(startPos, endPos, Vector(MPos))
			if proj1 and isOnSegment and (GetDistanceSqr(MPos, proj1) <= (minion.boundingRadius + radius + buffer) ^ 2) then				
				return true		
			end
		end
		
		local proj2, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(startPos, endPos, Vector(minion.pos))
		if proj2 and isOnSegment and (GetDistanceSqr(minion.pos, proj2) <= (minion.boundingRadius + radius + buffer) ^ 2) then
			return true
		end
	end
end

local function CheckMinionCollision(source, endPos, delay, radius, speed, range, start)
	if _G.SDK and _G.SDK.Orbwalker then
		return CheckMinionCollisionGG(source, endPos, delay, radius, speed, range, start)
	else
		return CheckMinionCollision(source, endPos, delay, radius, speed, range, start)
	end
end

local function CheckMinionCollision(source, endPos, delay, radius, speed, range, start)
	local startPos = myHero.pos
	if start then
		startPos = start
	end
	
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion.alive and minion.isEnemy and GetDistance(startPos, minion.pos) < range then
			if CheckCol(source, startPos, minion, endPos, delay, speed, range, radius) then
				return true
			end
		end
	end
end


local function CheckMinionCollisionGG(source, endPos, delay, radius, speed, range, start)
	local startPos = myHero.pos
	if start then
		startPos = start
	end
		
	for i, minion in ipairs(_G.SDK.ObjectManager:GetEnemyMinions(range)) do
		if CheckCol(source, startPos, minion, endPos, delay, speed ,range,  radius) then
			return true
		end
	end
	for i, minion in ipairs(_G.SDK.ObjectManager:GetMonsters(range)) do
		if CheckCol(source, startPos, minion, endPos, delay, speed ,range,  radius) then
			return true
		end
	end
	for i, minion in ipairs(_G.SDK.ObjectManager:GetOtherEnemyMinions(range)) do
		if minion.team ~= myHero.team and CheckCol(source, startPos, minion, endPos, delay, speed ,range,  radius) then
			return true
		end
	end
	
	return false
end

local function GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11) then
			duration = buff.duration
		end
	end
	return duration		
end

local function UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

local function GetSlowedTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end

local function GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end

local function GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = delay + GetDistance(startPos, endPos) / speed
	return interceptTime
end

local function TryGetBuff(unit, buffname)	
	for i = 1, unit.buffCount do 
		local Buff = unit:GetBuff(i)
		if Buff.name == buffname and Buff.duration > 0 then
			return Buff, true
		end
	end
	return nil, false
end

local function GetStasisTarget(source, range, delay, speed, timingAccuracy)
	local target	
	for i, t in ipairs(GetEnemyHeroes()) do
		local buff, success = TryGetBuff(t, "zhonyasringshield")
		if success and t.isEnemy and buff ~= nil then
			local deltaInterceptTime = GetSpellInterceptTime(myHero.pos, t.pos, delay, speed) - buff.duration
			if deltaInterceptTime > -Game.Latency() / 2000 and deltaInterceptTime < timingAccuracy then
				target = t
				return target, target.pos
			end
		end
	end

	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i);
		if ward.isEnemy and GetDistance(source, ward.pos) <= range then
			for i = 1, ward.buffCount do 
				local Buff = ward:GetBuff(i)
				if Buff.duration > 0 and Buff.name == "teleport_target" then
					local skillInterceptTime = GetSpellInterceptTime(myHero.pos, ward.pos, delay, speed)
					if Buff.duration < skillInterceptTime and skillInterceptTime - Buff.duration < timingAccuracy then
						return ward, ward.pos
					end
				end
			end
		end
	end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i);
		if minion.isEnemy and GetDistance(source, minion.pos) <= range then
			for i = 1, minion.buffCount do 
				local Buff = minion:GetBuff(i)
				if Buff.duration > 0 and Buff.name == "teleport_target" then
					local skillInterceptTime = GetSpellInterceptTime(myHero.pos, minion.pos, delay, speed)
					if Buff.duration < skillInterceptTime and skillInterceptTime - Buff.duration < timingAccuracy then
						return minion, minion.pos
					end
				end
			end
		end
	end
end

local function GetImmobileTarget(source, range, minimumCCTime)
	local bestTarget
	local bestCCTime = 0
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy and IsValid(enemy) and GetDistance(source, enemy.pos) <= range then
			for i = 0, enemy.buffCount do
				local buff = enemy:GetBuff(i)
				
				if (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11) then					
					if (buff.duration > minimumCCTime and buff.duration > bestCCTime) then
						bestTarget = enemy
						bestCCTime = buff.duration
					end
				end
			end
		end
	end	
	return bestTarget, bestCCTime
end

local function GetInteruptTarget(source, range, delay, speed, timingAccuracy)
	local target
	local aimPosition
	for i, t in ipairs(GetEnemyHeroes()) do
		if t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed > 500 then
			local dashEndPosition = t:GetPath(1)
			if GetDistance(source, dashEndPosition) <= range then				
				local dashTimeRemaining = GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed)
				local deltaInterceptTime = math.abs(skillInterceptTime - dashTimeRemaining)
				if deltaInterceptTime < timingAccuracy then
					target = t
					aimPosition = t.pathing.endPos
					return target, aimPosition
				end
			end			
		end
	end	
end

local function UpdateTargetPaths()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy.isEnemy then
			if not enemyPaths[enemy.charName] then
				enemyPaths[enemy.charName] = {}
			end
			
			if enemy.pathing and enemy.pathing.hasMovePath and enemyPaths[enemy.charName] and GetDistance(enemy.pathing.endPos, Vector(enemyPaths[enemy.charName].endPos)) > 56 then				
				enemyPaths[enemy.charName]["time"] = Game.Timer()
				enemyPaths[enemy.charName]["endPos"] = enemy.pathing.endPos					
			end
		end
	end
end

local function PreviousPathDetails(charName)
	local deltaTime = 0
	local pathEnd
	
	if enemyPaths and enemyPaths[charName] and enemyPaths[charName]["time"] then
		deltaTime = enemyPaths[charName]["time"]
		pathEnd = enemyPaths[charName]["endPos"]
	end
	return deltaTime, pathEnd
end
 		
local function CurrentPctLife(entity)
	local pctLife =  entity.health/entity.maxHealth  * 100
	return pctLife
end

local function CurrentPctMana(entity)
	local pctMana =  entity.mana/entity.maxMana * 100
	return pctMana
end

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function Find2PassiveTarget()
	local target
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy and IsValid(enemy) then
			for i = 0, enemy.buffCount do
				local buff = enemy:GetBuff(i)
				if buff.name == "velkozresearchstack" and buff.count == 2 and buff.duration > 0 and GetDistance(myHero.pos, enemy.pos) < W.Range then
					target = enemy
				end
			end
		end
	end
	return target
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.05"}})
	Menu:MenuElement({name = " ", drop = {"Full reworked Version from Sikaka"}})
	
	Menu:MenuElement({id = "General", name = "General Settings", type = MENU})
		Menu.General:MenuElement({id = "Drawing", name = "Drawing", type = MENU})
			Menu.General.Drawing:MenuElement({id = "DrawAA", name = "Draw AA Range", value = false})
			Menu.General.Drawing:MenuElement({id = "DrawQ", name = "Draw Q Range", value = false})
			Menu.General.Drawing:MenuElement({id = "DrawW", name = "Draw W Range", value = false})	
			Menu.General.Drawing:MenuElement({id = "DrawE", name = "Draw E Range", value = false})
			Menu.General.Drawing:MenuElement({id = "DrawEAim", name = "Draw E Aim", value = false})	
			Menu.General.Drawing:MenuElement({id = "DrawR", name = "Draw R Range", value = false})			
			
		Menu.General:MenuElement({id = "ReactionTime", name = "Enemy Reaction Time",tooltip = "How quickly (seconds) do you expect enemies to react to your spells. Used for predicting enemy movements", value = .25, min = .1, max = 1, step = .05 })		
		Menu.General:MenuElement({id = "DashTime", name = "Dash Time",tooltip = "How long must a dash be to auto cast on it", value = .5, min = .1, max = 2, step = .1 })
		Menu.General:MenuElement({id = "ImmobileTime", name = "Immobile Time",tooltip = "How long must a stun be to auto cast on them", value = .5, min = .1, max = 2, step = .1 })		
		Menu.General:MenuElement({id = "CastFrequency", name = "Cast Frequency Time",tooltip = "How quickly may spells be cast", value = .25, min = .1, max = 1, step = .1 })		
		Menu.General:MenuElement({id = "CheckInterval", name = "Collision Check Interval", value = 50, min = 10, max = 150, step = 10 })		
	
----------------------------------------------------------------------
	
	Menu:MenuElement({id = "Skills", name = "Skill Settings", type = MENU})	
		Menu.Skills:MenuElement({id = "Q", name = "Q", type = MENU})
			Menu.Skills.Q:MenuElement({id = "Combo", name = "UseQ Combo ?", value = true })
			Menu.Skills.Q:MenuElement({id = "Harass", name = "UseQ Harass ?", value = true })
			Menu.Skills.Q:MenuElement({name = " ", drop = {"///////////////////////////"}})
			Menu.Skills.Q:MenuElement({name = " ", drop = {"///////////////////////////"}})
			Menu.Skills.Q:MenuElement({id = "Targets", name = "Targets", type = MENU})
			for i, hero in ipairs(GetEnemyHeroes()) do
				if hero.isEnemy then
					Menu.Skills.Q.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
				end
			end	
			Menu.Skills.Q:MenuElement({id = "Detonate", name = "Auto Detonate", value = true })
			Menu.Skills.Q:MenuElement({id = "TargetImmobile", name = "Q Immobile", value = true })
			Menu.Skills.Q:MenuElement({id = "TargetDashes", name = "Q Dashes", value = true })
			Menu.Skills.Q:MenuElement({id = "Range", name = "Max Q cast Range", value = 900, min = 100, max = 1000, step = 25 })
			Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 25, min = 1, max = 100, step = 5 })
		
		
		Menu.Skills:MenuElement({id = "W", name = "W", type = MENU})
			Menu.Skills.W:MenuElement({id = "Combo", name = "UseW Combo ?", value = true })
			Menu.Skills.W:MenuElement({id = "Harass", name = "UseW Harass ?", value = true })
			Menu.Skills.W:MenuElement({name = " ", drop = {"///////////////////////////"}})
			Menu.Skills.W:MenuElement({name = " ", drop = {"///////////////////////////"}})		
			Menu.Skills.W:MenuElement({id = "UseW", name = "Only W on Passive/Immo/Dash", value = true })		
			Menu.Skills.W:MenuElement({id = "Detonate", name = "W Detonate Passive", value = true })
			Menu.Skills.W:MenuElement({id = "TargetImmobile", name = "W Immobile", value = true })
			Menu.Skills.W:MenuElement({id = "TargetDashes", name = "W Dashes", value = false })
			Menu.Skills.W:MenuElement({id = "Mana", name = "Mana Limit", value = 25, min = 1, max = 100, step = 5 })
		
		Menu.Skills:MenuElement({id = "E", name = "E", type = MENU})
			Menu.Skills.E:MenuElement({id = "Combo", name = "UseE Combo ?", value = true })
			Menu.Skills.E:MenuElement({id = "Harass", name = "UseE Harass ?", value = true })
			Menu.Skills.E:MenuElement({name = " ", drop = {"///////////////////////////"}})
			Menu.Skills.E:MenuElement({name = " ", drop = {"///////////////////////////"}})			
			Menu.Skills.E:MenuElement({id = "Targets", name = "Slowed/Dash Targets", type = MENU})
			for i, hero in ipairs(GetEnemyHeroes()) do
				if hero.isEnemy then
					Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
				end
			end
			Menu.Skills.E:MenuElement({id = "UseE", name = "Only E on Immo/Dash/Slow", value = true })
			Menu.Skills.E:MenuElement({id = "TargetImmobile", name = "E Immobile", value = true })
			Menu.Skills.E:MenuElement({id = "TargetSlows", name = "E Slows", value = true })			
			Menu.Skills.E:MenuElement({id = "TargetDashes", name = "E Dashes", value = true })
			Menu.Skills.E:MenuElement({id = "TargetDashes2", name = "AutoE / Check Dashes everytime", value = true })			
			Menu.Skills.E:MenuElement({id = "Radius", name = "Radius", value = 190, min = 50, max = 190, step = 10 })
			Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 1, max = 100, step = 5 })

		Menu.Skills:MenuElement({id = "R", name = "R", type = MENU})
			Menu.Skills.R:MenuElement({id = "R2", name = "Auto/Combo ?", value = 2, drop = {"AutoUlt", "Use Ult only in ComboMode"}})
			Menu.Skills.R:MenuElement({id = "R1", name = "Ult function", value = 2, drop = {"Ult if killable", "Ult if Hp lower than Hp Slider", "never use Ult"}})
			Menu.Skills.R:MenuElement({id = "Hp", name = "Hp Slider for Ult function 2", value = 50, min = 0, max = 100, identifier = "%"})
			Menu.Skills.R:MenuElement({id = "Range", name = "Max R cast Range", value = 1200, min = 0, max = 1550, identifier = "range"})
			Menu.Skills.R:MenuElement({id = "Stop", name = "Stop Ult if Enemy out of range", value = false })			
			Menu.Skills.R:MenuElement({id = "Active", name = "Semi. manual Key", key = string.byte("T")})

	Menu:MenuElement({id = "Farm", name = "Farm Settings", type = MENU})
		Menu.Farm:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
			Menu.Farm.Clear:MenuElement({id = "UseW", name = "Use [W]", value = true})  
			Menu.Farm.Clear:MenuElement({id = "UseWM", name = "Use [W] min Minions", value = 3, min = 1, max = 6})	
			Menu.Farm.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
	  
		Menu.Farm:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
			Menu.Farm.JClear:MenuElement({id = "UseQ", name = "Use [Q]", value = true})         	
			Menu.Farm.JClear:MenuElement({id = "UseW", name = "Use [W]", value = true})
			Menu.Farm.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})	
			
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
		Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
		Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
		Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q1]", value = 2, drop = {"Normal", "High", "Immobile"}})			
		Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})	
		Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})			

	LoadSpells()
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("WndMsg",function(Msg, Key) WndMsge(Msg, Key) end)
	Callback.Add("Draw", function() DrawSpells() end)

	QData = {Type = _G.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 35, Range = 1050, Speed = 1300, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}	
	QspellData = {speed = 1300, range = 1050, delay = (0.25+ping), radius = 35, collision = {"minion"}, type = "linear"}

	QNoColData = {Type = _G.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 35, Range = 1500, Speed = 1300, Collision = false}	
	QNoColspellData = {speed = 1300, range = 1500, delay = (0.25+ping), radius = 35, collision = {nil}, type = "linear"}	
	
	WData = {Type = _G.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 87, Range = 1050, Speed = 1700, Collision = false}	
	WspellData = {speed = 1700, range = 1050, delay = (0.25+ping), radius = 87, collision = {nil}, type = "linear"}

	EData = {Type = _G.SPELLTYPE_CIRCLE, Delay = (0.8+ping), Radius = 185, Range = 800, Speed = MathHuge, Collision = false}	
	EspellData = {speed = MathHuge, range = 800, delay = (0.8+ping), radius = 185, collision = {nil}, type = "circular"}	
end

function LoadSpells()

	Q = {Range = 1050, Width = 35,Delay = 0.25, Speed = 1300}
	Q2 = {Range = 1100, Width = 35,Delay = 0, Speed = 2100}	
	W = {Range = 1050, Width = 87,Delay = 0.25, Speed = 1700}
	E = {Range = 800, Width = 185,Delay = 0.8, Speed = math.huge}
	R = {Range = 1550,Width = 75, Delay = 0.25, Speed = math.huge}
end

function DrawSpells()			
	if Menu.General.Drawing.DrawAA:Value() then
		Draw.Circle(myHero.pos, 525, Draw.Color(100, 255, 255,255))
	end
	
	if Ready(_Q) and Menu.General.Drawing.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, Draw.Color(150, 50, 50,50))
	end
	
	if Ready(_W) and Menu.General.Drawing.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, Draw.Color(100, 0, 0,255))
	end
	
	if Ready(_E) then
		if Menu.General.Drawing.DrawE:Value() then
			Draw.Circle(myHero.pos, E.Range, Draw.Color(100, 0, 255,0))
		end
		if forcedTarget ~= nil and IsValid(forcedTarget) and Menu.General.Drawing.DrawEAim:Value() then
			local targetOrigin = PredictUnitPosition(forcedTarget, E.Delay)
			local interceptTime = GetSpellInterceptTime(myHero.pos, targetOrigin, E.Delay, E.Speed)			
			local origin, radius = UnitMovementBounds(forcedTarget, interceptTime, Menu.General.ReactionTime:Value())			
			if radius < 25 then
				radius = 25
			end
			Draw.Circle(origin, 25,10)		
			Draw.Circle(origin, radius,1, Draw.Color(50, 255, 255,255))						
		end
	end
	if Ready(_R) and Menu.General.Drawing.DrawR:Value() then
		Draw.Circle(myHero.pos, R.Range, Draw.Color(100, 255, 0,0))
	end	
end

function Tick()
	if IsRActive() then
		SetMovement(false)
		ControlUlt()
		if (Menu.Skills.R.Stop:Value() and GetEnemyCount(1650, myHero) == 0) then
			Control.CastSpell(HK_R)
		end
	else
		SetMovement(true)
	end
	
	if PredPos and not Ready(_Q) then
		PredPos = false
	end
	
	if Game.Timer() - lastSpellCast <= 0.3 then
		SetMovement(false)
	else
		SetMovement(true)
	end
	
	SemiUlt()

	if MyHeroNotReady() then return end

	if Ready(_R) and not IsRActive() and Menu.Skills.R.R2:Value() == 1 then
		StartUlt()
	end
	
	if Game.Timer() - lastSpellCast < Menu.General.CastFrequency:Value() or IsRActive() then return end
		UpdateTargetPaths()
	
	local Mode = GetMode()
	if Mode == "Combo" then	
		if Ready(_R) and not IsRActive() and Menu.Skills.R.R2:Value() == 2 then
			StartUlt()
		end		
		
		if Ready(_Q) and Menu.Skills.Q.Combo:Value() then
			UpdateQInfo()		
			if Menu.Skills.Q.Detonate:Value() and IsQActive() then
				DetonateQ()
			elseif CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() and not IsQActive() then
				AutoQ()
			end		
		
		elseif Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() and Menu.Skills.W.Combo:Value() then
			AutoW()
			
		end
		
		if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() and Menu.Skills.E.Combo:Value() then
			AutoE()
		end	
	
	elseif Mode == "Harass" then
		if Ready(_Q) and Menu.Skills.Q.Harass:Value() then
			UpdateQInfo()		
			if Menu.Skills.Q.Detonate:Value() and IsQActive() then
				DetonateQ()
			elseif CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() and not IsQActive() then
				AutoQ()
			end
				
		
		elseif Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() and Menu.Skills.W.Harass:Value() then
			AutoW()
		end
		
		if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() and Menu.Skills.E.Harass:Value() then
			AutoE()
		end
	elseif Mode == "Clear" then
		Clear()
		JungleClear()			
	end	

	if Menu.Skills.E.TargetDashes2:Value() and Ready(_E) then 
		if ((Menu.Skills.E.TargetDashes:Value() and (Mode ~= "Combo" or Mode ~= "Harass")) or not Menu.Skills.E.TargetDashes:Value()) then
			AutoEDash()
		end
	end
end

--/////////////////////////////////////////////////////////--
		--/////////////Spell R///////////////--
--/////////////////////////////////////////////////////////--

function SemiUlt()
	for i, hero in ipairs(GetEnemyHeroes()) do
		if GetDistance(myHero.pos, hero.pos) <= Menu.Skills.R.Range:Value() and IsValid(hero) then
			if Menu.Skills.R.Active:Value() then
				SetMovement(false)
				Control.CastSpell(HK_R, hero.pos)
				return
			end
		end
	end
end
			
function StartUlt()
	for i, hero in ipairs(GetEnemyHeroes()) do
		if GetDistance(myHero.pos, hero.pos) <= Menu.Skills.R.Range:Value() and IsValid(hero) then

			if Menu.Skills.R.R1:Value() == 1 then
				local RDmg = getdmg("R", hero, myHero)
				if RDmg > hero.health then
					SetMovement(false)
					Control.CastSpell(HK_R, hero.pos)
					return
				end
				
			elseif Menu.Skills.R.R1:Value() == 2 then
				if hero.health/hero.maxHealth <= Menu.Skills.R.Hp:Value() / 100 then
					SetMovement(false)
					Control.CastSpell(HK_R, hero.pos)
					return
				end				
			end
		end
	end
end

function ControlUlt()
	for i, hero in ipairs(GetEnemyHeroes()) do
		if GetDistance(myHero.pos, hero.pos) <= 1550 and IsValid(hero) then
			if GetDistance(mousePos, hero.pos) > 75 then
				Control.SetCursorPos(hero.pos)
			end
		end
	end
end

--/////////////////////////////////////////////////////////--
		--/////////////Spell Q///////////////--
--/////////////////////////////////////////////////////////--

local PredPos = true
local PredPos2 = nil
function AutoQ()

	if Game.Timer() - qLastChecked > 0.25 then
		qLastChecked = Game.Timer()
		local enemy = GetTarget(1400)
		if enemy ~= nil and IsValid(enemy) then			
			if GetDistance(myHero.pos, enemy.pos) <= Menu.Skills.Q.Range:Value() and not CheckMinionCollision(myHero, enemy.pos, Q.Delay, Q.Width, Q.Speed, Q.Range, myHero.pos) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(enemy, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						PredPos = true
						lastSpellCast = Game.Timer()
						Control.CastSpell(HK_Q, pred.CastPosition)
						return
					else
						PredPos = false
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						PredPos = true
						lastSpellCast = Game.Timer()
						Control.CastSpell(HK_Q, pred.CastPos)
						return
					else
						PredPos = false						
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 35, Range = 1050, Speed = 1300, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
					QPrediction:GetPrediction(enemy, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						PredPos = true
						lastSpellCast = Game.Timer()
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
						return						
					end	
				end
			else
				PredPos = false	
			end	
				
			if PredPos == false then
				
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(enemy, QNoColData, myHero)
					if pred.Hitchance >= 2 then
						PredPos2 = pred.CastPosition
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, QNoColspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						PredPos2 = pred.CastPos
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 35, Range = 1500, Speed = 1300, Collision = false})
					QPrediction:GetPrediction(enemy, myHero)
					if QPrediction:CanHit(2) then
						PredPos2 = QPrediction.CastPosition
					end	
				end			
				
				if PredPos2 then
					local range = myHero.pos:DistanceTo(PredPos2)
					local castPos1 = PredPos2 - (PredPos2 - myHero.pos):Perpendicular():Normalized() * range
					local castPos2 = castPos1:Extended(myHero.pos, range/2+250)
					local Delay2 = myHero.pos:DistanceTo(castPos2)/Q.Speed + ping
					local castPos3 = PredPos2 - (PredPos2 - myHero.pos):Perpendicular2():Normalized() * range
					local castPos4 = castPos3:Extended(myHero.pos, range/2+250)
					local Delay4 = myHero.pos:DistanceTo(castPos4)/Q.Speed  + ping
					if CheckMinionCollision(myHero, PredPos2, Q.Delay, Q.Width, Q.Speed, Q.Range, castPos2) then
						--print("Right")
					end
					if CheckMinionCollision(myHero, PredPos2, Q.Delay, Q.Width, Q.Speed, Q.Range, castPos4) then
						--print("Left")
					end					
					if not CheckMinionCollision(myHero, castPos2, Q.Delay, Q.Width, Q.Speed, Q.Range, myHero.pos) and not CheckMinionCollision(myHero, PredPos2, Delay2, Q2.Width, Q2.Speed, Q2.Range, castPos2) then
						Control.CastSpell(HK_Q, castPos2)
						lastSpellCast = Game.Timer()
						PredPos2 = nil	
						--Draw.Circle(castPos2, 100, 1, Draw.Color(255, 225, 255, 10))
						return	
					elseif not CheckMinionCollision(myHero, castPos4, Q.Delay, Q.Width, Q.Speed, Q.Range, myHero.pos) and not CheckMinionCollision(myHero, PredPos2, Delay4, Q2.Width, Q2.Speed, Q2.Range, castPos4) then
						Control.CastSpell(HK_Q, castPos4)
						lastSpellCast = Game.Timer()
						PredPos2 = nil
						--Draw.Circle(castPos4, 100, 1, Draw.Color(255, 225, 255, 10))
						return
					end
				end	
			end
		end
	end
end

function DetonateQ()
	if Game.Timer() - qPointsUpdatedAt < .25 and IsQActive() and qHitPoints then
		for i = 1, #qHitPoints do		
			if qHitPoints[i] then
				if qHitPoints[i].playerHit and Menu.Skills.Q.Targets[qHitPoints[i].playerHit.charName] and Menu.Skills.Q.Targets[qHitPoints[i].playerHit.charName]:Value()then					
					Control.CastSpell(HK_Q)
				end
			end
		end
	end	
end

--/////////////////////////////////////////////////////////--
		--/////////////Spell W///////////////--
--/////////////////////////////////////////////////////////--		

function AutoW()		
	if Menu.Skills.W.UseW:Value() then
		local hasCast = false
		
		if Menu.Skills.W.TargetImmobile:Value() then
			hasCast = AutoWStasis()		
			if not hasCast then
				hasCast = AutoWImmobile()
			end		
		end	
		
		if not hasCast and Menu.Skills.W.TargetDashes:Value() then
			hasCast = AutoWDash()
		end
		
		if not hasCast and Menu.Skills.W.Detonate:Value() then
			hasCast = AutoWDetonate()
		end
	else
		local enemy = GetTarget(1000)
		if enemy ~= nil and IsValid(enemy) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(enemy, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_W, pred.CastPosition)
					return
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, WspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_W, pred.CastPos)
					return
				end
			else
				local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 87, Range = 1050, Speed = 1700, Collision = false})
				WPrediction:GetPrediction(enemy, myHero)
				if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_W, WPrediction.CastPosition)
					return
				end	
			end
		end
	end	
end

function AutoWStasis()
	local enemy, aimPos = GetStasisTarget(myHero.pos, W.Range, W.Delay, W.Speed, Menu.General.ReactionTime:Value())
	if enemy and GetDistance(myHero.pos, aimPos) <= W.Range then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(enemy, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, pred.CastPosition)
				return true
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, WspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, pred.CastPos)
				return true
			end
		else
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 87, Range = 1050, Speed = 1700, Collision = false})
			WPrediction:GetPrediction(enemy, myHero)
			if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, WPrediction.CastPosition)
				return true
			end	
		end
	end
	return false
end

function AutoWImmobile()
	local enemy, ccTime = GetImmobileTarget(myHero.pos, W.Range, Menu.General.ImmobileTime:Value())
	if enemy and GetDistance(myHero.pos, enemy.pos) <= W.Range then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(enemy, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, pred.CastPosition)
				return true
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, WspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, pred.CastPos)
				return true
			end
		else
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 87, Range = 1050, Speed = 1700, Collision = false})
			WPrediction:GetPrediction(enemy, myHero)
			if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, WPrediction.CastPosition)
				return true
			end	
		end
	end
	return false	
end

function AutoWDash()
	local enemy, aimPos = GetInteruptTarget(myHero.pos, W.Range, W.Delay, W.Speed, Menu.General.DashTime:Value())
	if enemy and IsValid(enemy) and GetDistance(myHero.pos, aimPos) <= W.Range then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(enemy, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, pred.CastPosition)
				return true
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, WspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, pred.CastPos)
				return true
			end
		else
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 87, Range = 1050, Speed = 1700, Collision = false})
			WPrediction:GetPrediction(enemy, myHero)
			if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_W, WPrediction.CastPosition)
				return true
			end	
		end
	end
	return false
end

function AutoWDetonate()
	local enemy = Find2PassiveTarget()
	if enemy and IsValid(enemy) then
		if GetDistance(myHero.pos, enemy.pos) < W.Range then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(enemy, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_W, pred.CastPosition)
					return true
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, WspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_W, pred.CastPos)
					return true
				end
			else
				local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 87, Range = 1050, Speed = 1700, Collision = false})
				WPrediction:GetPrediction(enemy, myHero)
				if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_W, WPrediction.CastPosition)
					return true
				end	
			end
		end
		return false
	end	
end

--/////////////////////////////////////////////////////////--
		--/////////////Spell E///////////////--
--/////////////////////////////////////////////////////////--

function AutoE()
	if Menu.Skills.E.UseE:Value() then
		local hasCast = false	
		
		if Menu.Skills.E.TargetImmobile:Value() then
			hasCast = AutoEStasis()		
			if not hasCast then
				hasCast = AutoEImmobile()
			end		
		end
			
		if not hasCast and Menu.Skills.E.TargetDashes:Value() then
			hasCast = AutoEDash()
		end
		
		if not hasCast and Menu.Skills.E.TargetSlows:Value() then	
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if IsValid(enemy) and Menu.Skills.E.Targets[enemy.charName] and Menu.Skills.E.Targets[enemy.charName]:Value() then				
					hasCast = AutoERadius(enemy)
				end
			end	
		end
	else
		local enemy = GetTarget(800)
		if enemy ~= nil and IsValid(enemy) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(enemy, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_E, pred.CastPosition)
					return
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_E, pred.CastPos)
					return
				end
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = (0.8+ping), Radius = 185, Range = 800, Speed = MathHuge, Collision = false})
				EPrediction:GetPrediction(enemy, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					lastSpellCast = Game.Timer()
					Control.CastSpell(HK_E, EPrediction.CastPosition)
					return
				end	
			end
		end
	end
end

function AutoERadius(enemy)
	local deltaTime, endPos = PreviousPathDetails(enemy.charName)
	if deltaTime and Game.Timer() - deltaTime < Menu.General.ReactionTime:Value() then
		return false
	end
	local targetOrigin = PredictUnitPosition(enemy, E.Delay)
	local interceptTime = GetSpellInterceptTime(myHero.pos, targetOrigin, (E.Delay+ping), E.Speed)			
	local origin, radius = UnitMovementBounds(enemy, interceptTime, Menu.General.ReactionTime:Value())			
	
	if radius < Menu.Skills.E.Radius:Value() and GetDistance(myHero.pos, origin) <= E.Range then
		Control.CastSpell(HK_E, origin)
		lastSpellCast = Game.Timer()
		return true
	end
	
	return false
end

function AutoEStasis()
	local enemy, aimPos = GetStasisTarget(myHero.pos, E.Range, E.Delay, E.Speed, Menu.General.ReactionTime:Value())
	if enemy and GetDistance(myHero.pos, aimPos) <= E.Range then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(enemy, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, pred.CastPosition)
				return true
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, pred.CastPos)
				return true
			end
		else
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = (0.8+ping), Radius = 185, Range = 800, Speed = MathHuge, Collision = false})
			EPrediction:GetPrediction(enemy, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, EPrediction.CastPosition)
				return true
			end	
		end		
	end
	return false
end

function AutoEImmobile()
	local enemy, ccTime = GetImmobileTarget(myHero.pos, E.Range, Menu.General.ImmobileTime:Value())
	if enemy and GetDistance(myHero.pos, enemy.pos) <= E.Range then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(enemy, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, pred.CastPosition)
				return true
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, pred.CastPos)
				return true
			end
		else
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = (0.8+ping), Radius = 185, Range = 800, Speed = MathHuge, Collision = false})
			EPrediction:GetPrediction(enemy, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, EPrediction.CastPosition)
				return true
			end	
		end		
	end
	return false	
end

function AutoEDash()
	local enemy, aimPos = GetInteruptTarget(myHero.pos, E.Range, E.Delay, E.Speed, Menu.General.DashTime:Value())
	if enemy and IsValid(enemy) and GetDistance(myHero.pos, aimPos) <= E.Range and Menu.Skills.E.Targets[enemy.charName] and Menu.Skills.E.Targets[enemy.charName]:Value() then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(enemy, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, pred.CastPosition)
				return true
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, pred.CastPos)
				return true
			end
		else
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = (0.8+ping), Radius = 185, Range = 800, Speed = MathHuge, Collision = false})
			EPrediction:GetPrediction(enemy, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
				lastSpellCast = Game.Timer()
				Control.CastSpell(HK_E, EPrediction.CastPosition)
				return true
			end	
		end		
	end
	return false
end

--/////////////////////////////////////////////////////////--
		--//////////////////////////////////--
--/////////////////////////////////////////////////////////--

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Farm.Clear.Mana:Value() / 100
			
            if Menu.Farm.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= 1100 and IsValid(minion) and Ready(_W) then
                local Count = GetLineTargetCount(myHero.pos, minion.pos, (0.25+ping), 1700, 87)
				if Count >= Menu.Farm.Clear.UseWM:Value() then
					Control.CastSpell(HK_W, minion.pos)
				end
            end
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Farm.JClear.Mana:Value() / 100
            
			if Menu.Farm.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1050 and IsValid(minion) and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.Farm.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1050 and IsValid(minion) and Ready(_W) then	
				Control.CastSpell(HK_W, minion.pos)
            end
        end
    end
end

function UpdateQInfo()
	if IsQActive() then	
		local directionVector = Vector(qMissile.missileData.endPos.x - qMissile.missileData.startPos.x,qMissile.missileData.endPos.y - qMissile.missileData.startPos.y,qMissile.missileData.endPos.z - qMissile.missileData.startPos.z):Normalized()										
		local checkInterval = Menu.General.CheckInterval:Value()
		local pointCount = 600 / checkInterval * 2
		qHitPoints = {}
		
		for i = 1, pointCount, 2 do
			local result =  CalculateNode(qMissile,  qMissile.pos + directionVector:Perpendicular() * i * checkInterval)			
			qHitPoints[i] = result
			if result.collision then
				break
			end
		end
				
		for i = 2, pointCount, 2 do		
			local result =  CalculateNode(qMissile,  qMissile.pos + directionVector:Perpendicular2() * i * checkInterval)			
			qHitPoints[i] = result	
			if result.collision then
				break
			end
		end		
		qPointsUpdatedAt = Game.Timer()
		
	end
		
	local qData = myHero:GetSpellData(_Q)
	if Game.Timer() - qData.castTime < 0.3 then
		for i = 1, Game.MissileCount() do
			local missile = Game.Missile(i)
			if missile.name == "VelkozQMissile" and GetDistance(missile.pos, myHero.pos) < 600 then
				qMissile = missile
			end
		end
	end
end

function WndMsge(msg,key)
	if msg == 513 then
		local starget = nil
		for i  = 1,Game.HeroCount(i) do
			local enemy = Game.Hero(i)
			if enemy.alive and enemy.isEnemy and GetDistance(mousePos, enemy.pos) < 250 then
				starget = enemy
				break
			end
		end
		if starget then
			forcedTarget = starget
		else
			forcedTarget = nil
		end
	end	
end

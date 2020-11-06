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
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

function CalculateNode(missile, nodePos)
	local result = {}
	result["pos"] = nodePos
	result["delay"] = 0.251 + GetDistance(missile.pos, nodePos) / Q.Speed
	
	local isCollision = CheckMinionIntercection(nodePos, 55, result["delay"])
	local hitEnemy 
	if not isCollision then
		isCollision, hitEnemy = CheckEnemyCollision(nodePos, 55, result["delay"])
	end
	
	result["playerHit"] = hitEnemy
	result["collision"] = isCollision
	return result
end

function IsQActive()
	return qMissile and qMissile.name and qMissile.name == "VelkozQMissile"
end

function IsRActive()
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "VelkozR" then
		return true
	else
		return false
	end
end

function CheckMinionIntercection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 1200
	end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.isEnemy and minion.isTargetable and minion.alive and GetDistance(minion.pos, location) < maxDistance then
			local predictedPosition = PredictUnitPosition(minion, delay)
			if GetDistance(location, predictedPosition) <= radius + minion.boundingRadius then
				return true
			end
		end
	end
	
	return false
end

function VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function CheckCol(source, startPos, minion, endPos, delay, speed, range, radius)
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

function CheckMinionCollision(source, endPos, delay, radius, speed, range, start)
	if _G.SDK and _G.SDK.Orbwalker then
		return self:CheckMinionCollisionGG(source, endPos, delay, radius, speed, range, start)
	else
		return self:CheckMinionCollision(source, endPos, delay, radius, speed, range, start)
	end
end

function CheckMinionCollision(source, endPos, delay, radius, speed, range, start)
	local startPos = myHero.pos
	if start then
		startPos = start
	end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.alive and minion.isEnemy and GetDistance(startPos, minion.pos) < range then
			if CheckCol(source, startPos, minion, endPos, delay, speed, range, radius) then
				return true
			end
		end
	end
end


function CheckMinionCollisionGG(source, endPos, delay, radius, speed, range, start)
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

function CheckEnemyCollision(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 1200
	end
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if IsValid(hero) and GetDistance(hero.pos, location) < maxDistance then
			local predictedPosition = PredictUnitPosition(hero, delay)
			if GetDistance(location, predictedPosition) < radius + hero.boundingRadius then
				return true, hero
			end
		end
	end
	
	return false
end

function GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function PredictUnitPosition(unit, delay)
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

function UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

function GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11) then
			duration = buff.duration
		end
	end
	return duration		
end

function GetSlowedTime(unit)
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

function GetPathNodes(unit)
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

function GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end

function GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = delay + GetDistance(startPos, endPos) / speed
	return interceptTime
end

function TryGetBuff(unit, buffname)	
	for i = 1, unit.buffCount do 
		local Buff = unit:GetBuff(i)
		if Buff.name == buffname and Buff.duration > 0 then
			return Buff, true
		end
	end
	return nil, false
end

function GetStasisTarget(source, range, delay, speed, timingAccuracy)
	local target	
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
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

function GetImmobileTarget(source, range, minimumCCTime)
	local bestTarget
	local bestCCTime = 0
	for heroIndex = 1, Game.HeroCount()  do
		local enemy = Game.Hero(heroIndex)
		if enemy and IsValid(enemy) and GetDistance(source, enemy.pos) <= range then
			for buffIndex = 0, enemy.buffCount do
				local buff = enemy:GetBuff(buffIndex)
				
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

function GetInteruptTarget(source, range, delay, speed, timingAccuracy)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
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

function UpdateTargetPaths()
	for i = 1, Game:HeroCount() do
		local enemy = Game.Hero(i)
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

function PreviousPathDetails(charName)
	local deltaTime = 0
	local pathEnd
	
	if enemyPaths and enemyPaths[charName] and enemyPaths[charName]["time"] then
		deltaTime = enemyPaths[charName]["time"]
		pathEnd = enemyPaths[charName]["endPos"]
	end
	return deltaTime, pathEnd
end
 		
function CurrentPctLife(entity)
	local pctLife =  entity.health/entity.maxHealth  * 100
	return pctLife
end

function CurrentPctMana(entity)
	local pctMana =  entity.mana/entity.maxMana * 100
	return pctMana
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})
	
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
			for i = 1, Game.HeroCount() do
				local hero = Game.Hero(i)
				if hero.isEnemy then
					Menu.Skills.Q.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
				end
			end	
			Menu.Skills.Q:MenuElement({id = "Detonate", name = "Auto Detonate", value = true })
			Menu.Skills.Q:MenuElement({id = "TargetImmobile", name = "Auto Q Immobile", value = true })
			Menu.Skills.Q:MenuElement({id = "TargetDashes", name = "Auto Q Dashes", value = true })
			Menu.Skills.Q:MenuElement({id = "Range", name = "Max Q cast Range", value = 900, min = 100, max = 1000, step = 25 })
			Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 25, min = 1, max = 100, step = 5 })
		
		
		Menu.Skills:MenuElement({id = "W", name = "W", type = MENU})
			Menu.Skills.W:MenuElement({id = "Combo", name = "UseW Combo ?", value = true })
			Menu.Skills.W:MenuElement({id = "Harass", name = "UseW Harass ?", value = true })
			Menu.Skills.W:MenuElement({name = " ", drop = {"///////////////////////////"}})
			Menu.Skills.W:MenuElement({name = " ", drop = {"///////////////////////////"}})		
			Menu.Skills.W:MenuElement({id = "UseW", name = "Only W on Passive/Immo/Dash", value = true })		
			Menu.Skills.W:MenuElement({id = "Detonate", name = "Auto Detonate Passive", value = true })
			Menu.Skills.W:MenuElement({id = "TargetImmobile", name = "Auto W Immobile", value = true })
			Menu.Skills.W:MenuElement({id = "TargetDashes", name = "Auto W Dashes", value = false })
			Menu.Skills.W:MenuElement({id = "Mana", name = "Mana Limit", value = 25, min = 1, max = 100, step = 5 })
		
		Menu.Skills:MenuElement({id = "E", name = "E", type = MENU})
			Menu.Skills.E:MenuElement({id = "Combo", name = "UseE Combo ?", value = true })
			Menu.Skills.E:MenuElement({id = "Harass", name = "UseE Harass ?", value = true })
			Menu.Skills.E:MenuElement({name = " ", drop = {"///////////////////////////"}})
			Menu.Skills.E:MenuElement({name = " ", drop = {"///////////////////////////"}})			
			Menu.Skills.E:MenuElement({id = "Targets", name = "Slowed/Dash Targets", type = MENU})
			for i = 1, Game.HeroCount() do
				local hero = Game.Hero(i)
				if hero.isEnemy then
					Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
				end
			end
			Menu.Skills.E:MenuElement({id = "UseE", name = "Only E on Immo/Dash/Slow", value = true })
			Menu.Skills.E:MenuElement({id = "TargetImmobile", name = "Auto E Immobile", value = true })
			Menu.Skills.E:MenuElement({id = "TargetDashes", name = "Auto E Dashes", value = true })
			Menu.Skills.E:MenuElement({id = "TargetSlows", name = "Auto E Slows", value = true })
			Menu.Skills.E:MenuElement({id = "Radius", name = "Radius", value = 190, min = 50, max = 225, step = 10 })
			Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 1, max = 100, step = 5 })

		Menu.Skills:MenuElement({id = "R", name = "R", type = MENU})
			Menu.Skills.R:MenuElement({id = "R2", name = "Auto/Combo ?", value = 2, drop = {"AutoUlt", "Use Ult only in ComboMode"}})
			Menu.Skills.R:MenuElement({id = "R1", name = "Ult function", value = 2, drop = {"Ult if killable", "Ult if Hp lower than Hp Slider", "never use Ult"}})
			Menu.Skills.R:MenuElement({id = "Hp", name = "Hp Slider for AutoR function 2", value = 50, min = 0, max = 100, identifier = "%"})
			Menu.Skills.R:MenuElement({id = "Range", name = "Max R cast Range", value = 1200, min = 0, max = 1550, identifier = "range"})
			Menu.Skills.R:MenuElement({id = "Active", name = "Semi. manual Key", key = string.byte("T")})		

	LoadSpells()
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("WndMsg",function(Msg, Key) WndMsge(Msg, Key) end)
	Callback.Add("Draw", function() Draw() end)	
end

function LoadSpells()

	Q = {Range = 1050, Width = 50,Delay = 0.25, Speed = 1300}
	Q2 = {Range = 1100, Width = 45,Delay = 0, Speed = 2100}	
	W = {Range = 1050, Width = 87,Delay = 0.25, Speed = 1700}
	E = {Range = 800, Width = 185,Delay = 0.8, Speed = math.huge}
	R = {Range = 1550,Width = 75, Delay = 0.25, Speed = math.huge}
end

function Draw()			
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

function Velkoz:Tick()
	if IsRActive() then
		SetMovement(false)
		ControlUlt()
	else
		SetMovement(true)
	end
	
	SemiUlt()

	if MyHeroNotReady() then return end

	if Ready(_R) and not IsRActive() and Menu.Skills.R.R2:Value() == 1 then
		StartUlt()
	end
	
	if Game.Timer() -lastSpellCast < Menu.General.CastFrequency:Value() or IsRActive() then return end
		UpdateTargetPaths()
	
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
		end		
		
		if Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() and Menu.Skills.W.Combo:Value() then
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
		end		
		
		if Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() and Menu.Skills.W.Harass:Value() then
			AutoW()
		end
		
		if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() and Menu.Skills.E.Harass:Value() then
			AutoE()
		end
	elseif Mode == "Clear" then
		--Clear()
		--JungleClear()			
	end		
end


--/////////////Spell R///////////////--

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

--/////////////Spell Q///////////////--

function AutoQ()
	if Game.Timer() - qLastChecked > 0.25 then
		qLastChecked = Game.Timer()
		local enemy = GetTarget(2500)
		if enemy ~= nil and IsValid(enemy) then		
			local predictedPosition = self:PredictUnitPosition(enemy,Q.Delay)
				
			if GetDistance(myHero.pos, predictedPosition) <= Menu.Skills.Q.Range:Value() then			
				if not CheckMinionCollision(myHero, predictedPosition, Q.Delay, Q.Width, Q.Speed, Q.Range, myHero.pos) then				
					Control.CastSpell(HK_Q, predictedPosition)
					lastSpellCast = Game.Timer()
					return
				else
					local range = myHero.pos:DistanceTo(predictedPosition)
					local castPos1 = predictedPosition - (predictedPosition - myHero.pos):Perpendicular():Normalized() * range
					local castPos2 = castPos1:Extended(myHero.pos, range/2+250)
					local Delay2 = myHero.pos:DistanceTo(castPos2)/Q.Speed
					local castPos3 = predictedPosition - (predictedPosition - myHero.pos):Perpendicular2():Normalized() * range
					local castPos4 = castPos3:Extended(myHero.pos, range/2+250)
					local Delay4 = myHero.pos:DistanceTo(castPos4)/Q.Speed
					if not CheckMinionCollision(myHero, castPos2, Q.Delay, Q.Width, Q.Speed, Q.Range, myHero.pos) and not CheckMinionCollision(myHero, predictedPosition, Delay2, Q2.Width, Q2.Speed, Q2.Range, castPos2) then
						Control.CastSpell(HK_Q, castPos2)
						lastSpellCast = Game.Timer()					
						--Draw.Circle(castPos2, 100, 1, Draw.Color(255, 225, 255, 10))
						return	
					elseif not CheckMinionCollision(myHero, castPos4, Q.Delay, Q.Width, Q.Speed, Q.Range, myHero.pos) and not CheckMinionCollision(myHero, predictedPosition, Delay4, Q2.Width, Q2.Speed, Q2.Range, castPos4) then
						Control.CastSpell(HK_Q, castPos4)
						lastSpellCast = Game.Timer()					
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

--/////////////Spell W///////////////--

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
			Control.CastSpell(HK_W, enemy.pos)
		end
	end	
end

function AutoWStasis()
	local enemy, aimPos = GetStasisTarget(myHero.pos, W.Range, W.Delay, W.Speed, Menu.General.ReactionTime:Value())
	if enemy and GetDistance(myHero.pos, aimPos) <= W.Range then
		Control.CastSpell(HK_W, aimPos)
		lastSpellCast = Game.Timer()
		return true
	end
	return false
end

function AutoWImmobile()
	local enemy, ccTime = GetImmobileTarget(myHero.pos, W.Range, Menu.General.ImmobileTime:Value())
	if enemy and GetDistance(myHero.pos, enemy.pos) <= W.Range then
		Control.CastSpell(HK_W, enemy.pos)
		lastSpellCast = Game.Timer()
		return true
	end
	return false	
end

function AutoWDash()
	local enemy, aimPos = GetInteruptTarget(myHero.pos, W.Range, W.Delay, W.Speed, Menu.General.DashTime:Value())
	if enemy and IsValid(enemy) and GetDistance(myHero.pos, aimPos) <= W.Range then
		Control.CastSpell(HK_W, aimPos)
		lastSpellCast = Game.Timer()		
		return true
	end
	return false
end

function AutoWDetonate()
	local enemy = Find2PassiveTarget()
	if enemy and IsValid(enemy) then
		local aimLocation = PredictUnitPosition(enemy, GetSpellInterceptTime(myHero.pos, enemy.pos, W.Delay, W.Speed))
		if GetDistance(myHero.pos, aimLocation) < W.Range * 3 / 4 then
			Control.CastSpell(HK_W, aimLocation)
			lastSpellCast = Game.Timer()
			return true
		end
	end	
	return false
end

function Find2PassiveTarget()
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

--/////////////Spell E///////////////--

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
			Control.CastSpell(HK_E, enemy.pos)
		end
	end
end

function AutoERadius(enemy)
	local deltaTime, endPos = PreviousPathDetails(enemy.charName)
	if deltaTime and Game.Timer() - deltaTime < Menu.General.ReactionTime:Value() then
		return false
	end
	local targetOrigin = PredictUnitPosition(enemy, E.Delay)
	local interceptTime = GetSpellInterceptTime(myHero.pos, targetOrigin, E.Delay, E.Speed)			
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
		Control.CastSpell(HK_E, aimPos)
		lastSpellCast = Game.Timer()
		return true
	end
	return false
end

function AutoEImmobile()
	local enemy, ccTime = GetImmobileTarget(myHero.pos, E.Range, Menu.General.ImmobileTime:Value())
	if enemy and GetDistance(myHero.pos, enemy.pos) <= E.Range then
		Control.CastSpell(HK_E, enemy.pos)
		lastSpellCast = Game.Timer()
		return true
	end
	return false	
end

function AutoEDash()
	local enemy, aimPos = GetInteruptTarget(myHero.pos, E.Range, E.Delay, E.Speed, Menu.General.DashTime:Value())
	if enemy and IsValid(enemy) and GetDistance(myHero.pos, aimPos) <= E.Range and Menu.Skills.E.Targets[enemy.charName] and Menu.Skills.E.Targets[enemy.charName]:Value() then
		Control.CastSpell(HK_E, aimPos)
		lastSpellCast = Game.Timer()
		return true
	end
	return false
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



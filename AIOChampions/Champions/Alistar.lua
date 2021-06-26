
local LastW = 0

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 8 or buff.type == 12 or buff.type == 22 or buff.type == 23 or buff.type == 25 or buff.type == 30 or buff.type == 35 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function GetEnemyHeroes()
	local EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero and Hero.valid and Hero.alive and Hero.visible and Hero.isEnemy and Hero.isTargetable then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

local function GetAllyHeroes()
	local AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero and Hero.valid and Hero.alive and Hero.visible and Hero.isAlly then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

local function IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or (checkTeam and unit.isAlly) then
		return false
	end
	if myHero.pos:DistanceTo(unit.pos) > range then return false end 
	return true 
end

local Q = {Range = 350, Delay = 0.25}
local W = {Range = 650}
local E = {Range = 350}

function LoadScript()
	--MainMenu
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Reworked Trust Alistar"}})	
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})
	
	--[[Protector]]
	Menu:MenuElement({type = MENU, id = "Protector", name = "Protect from dashes"})
	Menu.Protector:MenuElement({id = "enabled", name = "Enabled", value = true})
	DelayAction(function()
		for i, hero in ipairs(GetAllyHeroes()) do
			Menu.Protector:MenuElement({id = "RU"..hero.charName, name = "Protect from dashes: "..hero.charName, value = true})
		end
	end,0.2)
	
	--AutoW 
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W] if can KnockBack under AllyTower", value = true})	
	
	--[[Combo]]
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	Menu.Combo:MenuElement({id = "comboUseR1", name = "Use R if Immobile", value = true})	
	Menu.Combo:MenuElement({id = "comboUseR2", name = "Use R if Hp low", value = true})
	Menu.Combo:MenuElement({id = "Hp", name = "Use R if Hp lower than -->", value = 50, min = 0, max = 100, step = 5, identifier = "%"})	
	
	
	--[[Harass]]
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	
	Menu:MenuElement({type = MENU, id = "DrawMenu", name = "Draw Settings"})
	Menu.DrawMenu:MenuElement({id = "DrawQ", name = "Draw Q Range", value = false})
	Menu.DrawMenu:MenuElement({id = "QRangeC", name = "Q Range color", color = Draw.Color(0xBF3F3FFF)})
	Menu.DrawMenu:MenuElement({id = "DrawW", name = "Draw W Range", value = false})
	Menu.DrawMenu:MenuElement({id = "WRangeC", name = "W Range color", color = Draw.Color(0xBFBF3FFF)})

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end                                                 
		
		if Menu.DrawMenu.DrawQ:Value() then
			Draw.Circle(myHero.pos, Q.Range, 1, Menu.DrawMenu.QRangeC:Value())
		end
		if Menu.DrawMenu.DrawW:Value() then
			Draw.Circle(myHero.pos, W.Range, 1, Menu.DrawMenu.WRangeC:Value())
		end	
	end)
end

function Tick()
	if MyHeroNotReady() then return end
	
	local combomodeactive = GetMode() == "Combo"
	local harassactive = GetMode() == "Harass"
	local protector = Menu.Protector.enabled:Value()

	if protector and Ready(_W) then
		for i, hero in pairs(GetEnemyHeroes()) do 
			if hero.pathing.hasMovePath and hero.pathing.isDashing and hero.pathing.dashSpeed>500 then 
				for i, allyHero in pairs(GetAllyHeroes()) do 
					if Menu.Protector["RU"..allyHero.charName] and Menu.Protector["RU"..allyHero.charName]:Value() then 
						if allyHero.pos:DistanceTo( Vector( hero.pathing.endPos ) ) < 100 and allyHero.distance < W.Range then
							Control.CastSpell(HK_W,hero)
							return
						end
					end
				end
			end
		end
	end
	
	if ( GetTickCount() < LastW + 2000 and GetMode() == "Combo" and Menu.Combo.comboUseQ:Value() and Ready(_Q) and (myHero.pathing.isDashing or not Ready(_W)) ) then
		Control.CastSpell(HK_Q)
		--print("Q Combo After W")
	end		
	
	if combomodeactive then
		if ( Menu.Combo.comboUseW:Value() and Ready(_Q) and Ready(_W) and CastW() ) then
			LastW = GetTickCount()
			--print("WQ Combo")
		elseif ( Menu.Combo.comboUseQ:Value() and Ready(_Q) and CastQ() ) then
			--print("Q Combo")
		end
		if ( Menu.Combo.comboUseE:Value() and Ready(_E) and CastE() ) then
			--print("E Combo")
		end
		if ( Menu.Combo.comboUseR1:Value() and Ready(_R) and CastR1() ) then
			--print("R Immo")
		elseif ( Menu.Combo.comboUseR2:Value() and Ready(_R) and CastR2() ) then
			--print("R Hp")			
		end		
	elseif harassactive then
		if Menu.Harass.harassUseQ:Value() and Ready(_Q) and CastQ() then
			--print("Q Harass")
		end
	end
	
	if Menu.AutoW.UseW:Value() and Ready(_W) then
		AutoW()
	end
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end 

local function GetPathNodes(unit)
	local nodes = {}
	TableInsert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			TableInsert(nodes, path)
		end
	end		
	return nodes
end

local function GetTargetMS(target)
	local ms = target.ms
	return ms
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

local function GetLineWTarget(source, Pos, target, delay, speed, width)		
	local predictedPos = PredictUnitPosition(target, delay+ GetDistance(source, target.pos) / speed)
	local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
	if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (target.boundingRadius + width) * (target.boundingRadius + width)) then
		return true
	end
	return false
end

local function GetAllyTurrets(unit)
	for i = 1, GameTurretCount() do
		local turret = GameTurret(i)
		local Range = (turret.boundingRadius / 2 + unit.boundingRadius / 2) + 1425
		if turret and turret.isAlly and not turret.dead and turret.pos:DistanceTo(unit.pos) < Range then
			return turret
		end
	end
	return nil
end

function AutoW()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy and IsValid(enemy) and myHero.pos:DistanceTo(enemy.pos) < 700 then
			local AllyTurret = GetAllyTurrets(enemy) 
			if AllyTurret and AllyTurret.pos:DistanceTo(enemy.pos) > (AllyTurret.boundingRadius / 2 + 800 + enemy.boundingRadius / 2) then
				local CanHit = GetLineWTarget(myHero.pos, AllyTurret.pos, enemy, 0.1, 1200, 200)	
				if CanHit then
					Control.CastSpell(HK_W, enemy)
				end
			end
		end
	end	
end

function CastQ(target)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target then
		--local temppred = target:GetPrediction(math.huge,0.25)
		if target.pos:DistanceTo(myHero.pos) < Q.Range then 
			Control.CastSpell(HK_Q)
			return true
		end
	end
	return false
end

function CastW()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AP"))
	if target and target.pos:DistanceTo(myHero.pos) > Q.Range then		
		Control.CastSpell(HK_W, target)
		return true	
	end
	return false
end

function CastE()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
	if target then
		Control.CastSpell(HK_E)
		return true
	end
	return false
end

function CastR1()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	for i, hero in pairs(GetEnemyHeroes()) do 
		if IsValidTarget(hero, 500) and IsImmobileTarget(myHero) then
			Control.CastSpell(HK_R)
			return true
		end
	end	
	return false
end

function CastR2()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	for i, hero in pairs(GetEnemyHeroes()) do 
		if IsValidTarget(hero, 500) and myHero.health/myHero.maxHealth <= Menu.Combo.Hp:Value() / 100  then
			Control.CastSpell(HK_R)
			return true
		end
	end	
	return false
end

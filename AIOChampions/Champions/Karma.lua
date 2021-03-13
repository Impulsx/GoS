
local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.team ~= myHero.team then
			TableInsert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end 

local function GetAllyHeroes() 
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function GetEnemyCount(range, pos)
	local count = 0
	for i = 1, GameHeroCount() do 
	local hero = GameHero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,GameMinionCount() do
	local hero = GameMinion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function IsInRange(p1, p2, range)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined IsInRange target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return false
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range 
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

local function IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1,GameMinionCount() do
		local minion = GameMinion(i)
		if minion and IsValid(minion) and IsInRange(minion.pos, location, maxDistance) then
			local predictedPosition = PredictUnitPosition(minion, delay)
			if IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
				return true
			end
		end
	end
	return false
end

local function CheckMinionCollision(origin, endPos, delay, speed, radius)
	local directionVector = (endPos - origin):Normalized()
	local checkCount = GetDistance(origin, endPos) / radius
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * radius
		local checkDelay = delay + GetDistance(origin, checkPosition) / speed
		if IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end

local MenuValue = 1

function LoadScript() 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "HotKey", name = "HotKey Change Combo Mode", value = false, key = string.byte("T")})	
	Menu.Combo:MenuElement({name = "Combo Mode:", drop = {"[R-Q] or [R-W] or [R-E for AutoE]"}})	
	Menu.Combo:MenuElement({id = "wait", name = "Block Cast if [R] almost ready", value = 1.5, min = 0, max = 5, step = 0.1, identifier = "sec"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseQ2", name = "[R-Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W] after [R-Q]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 30, min = 0, max = 100, identifier = "%"})
	
	--AutoE
	Menu:MenuElement({id = "AutoE", name = "AutoE", type = MENU})	
	Menu.AutoE:MenuElement({id = "self", name = "Shield Self",value = true})
	Menu.AutoE:MenuElement({id = "ally", name = "Shield Ally",value = true})	
	Menu.AutoE:MenuElement({id = "Targets", name = "Ally White List", type = MENU})
	DelayAction(function()
		for i, Hero in pairs(GetAllyHeroes()) do
			Menu.AutoE.Targets:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
		end	
	end,0.2)	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		  
	Menu.Clear:MenuElement({id = "UseQM", name = "Use[Q] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	Menu.Drawing:MenuElement({id = "x", name = "TextPos: [X]", value = 700, min = 0, max = 1500, step = 10})
	Menu.Drawing:MenuElement({id = "y", name = "TextPos: [Y]", value = 0, min = 0, max = 860, step = 10})	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 950, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1700, range = 950, delay = 0.25, radius = 80, collision = {"minion"}, type = "linear"}	
  	                                           
	Q2Data =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 950, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	Q2spellData = {speed = 1700, range = 950, delay = 0.25, radius = 80, collision = {"minion"}, type = "linear"}											   
											   
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		DrawText("Combo Mode: ", 20, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+10, DrawColor(255, 225, 255, 0))
		if MenuValue == 1 then
			DrawText("R/Q", 20, Menu.Drawing.x:Value()+105, Menu.Drawing.y:Value()+10, DrawColor(255, 50, 205, 50))
		elseif MenuValue == 2 then
			DrawText("R/W", 20, Menu.Drawing.x:Value()+105, Menu.Drawing.y:Value()+10, DrawColor(255, 255, 255, 255))
		else
			DrawText("R/E", 20, Menu.Drawing.x:Value()+105, Menu.Drawing.y:Value()+10, DrawColor(255, 0, 191, 255))
		end
		
		if myHero.dead then return end
                                                
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 950, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 800, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 675, 1, DrawColor(225, 225, 125, 10))
		end
	end)	
end

Callback.Add("WndMsg", function(msg, wParam)
	if msg ~= 256 then return end
	if Menu.Combo.HotKey:Key() == wParam then
		MenuValue = MenuValue % 3 + 1
	end
end)

--local KeyDown = false
--local nextChange = true
function Tick()
	--[[if Menu.Combo.HotKey:Value() and not KeyDown and nextChange then
		KeyDown = true
		nextChange = false
	end

	if KeyDown then
		DelayAction(function()
			nextChange = true
		end,0.5)
		if MenuValue == 1 then
			MenuValue = 2
			KeyDown = false
			return
		elseif MenuValue == 2 then
			MenuValue = 3
			KeyDown = false
			return
		else
			MenuValue = 1
			KeyDown = false
			return
		end
	end]]

	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()			
	end	
	AutoE()
end

function AutoE()
	for k, enemy in ipairs(GetEnemyHeroes()) do    	
		if enemy and GetDistance(enemy.pos, myHero.pos) < 2000 and IsValid(enemy) then	

			if MenuValue == 3 then
				for i, ally in pairs(GetAllyHeroes()) do
					if myHero.pos:DistanceTo(ally.pos) < 800 and IsValid(ally) then 
						if Menu.AutoE.ally:Value() and Menu.AutoE.Targets[ally.charName] and Menu.AutoE.Targets[ally.charName]:Value() and Ready(_E) and enemy.activeSpell.target == ally.handle then
							if HasBuff(myHero, "KarmaMantra") then
								Control.CastSpell(HK_E, ally)
							end							
							if myHero:GetSpellData(_R).currentCd <= Menu.Combo.wait:Value() then
								if Ready(_R) then
									Control.CastSpell(HK_R)
								end						
							else
								if not HasBuff(myHero, "KarmaMantra") then
									Control.CastSpell(HK_E, ally)
								end
							end
						end
					end
				end		
				
				if Menu.AutoE.self:Value() and Ready(_E) and enemy.activeSpell.target == myHero.handle then
					if HasBuff(myHero, "KarmaMantra") then
						Control.CastSpell(HK_E, myHero)
					end					
					if myHero:GetSpellData(_R).currentCd <= Menu.Combo.wait:Value() then
						if Ready(_R) then
							Control.CastSpell(HK_R)
						end						
					else
						if not HasBuff(myHero, "KarmaMantra") then
							Control.CastSpell(HK_E, myHero)
						end
					end
				end
				
			else
				for i, ally in pairs(GetAllyHeroes()) do
					if myHero.pos:DistanceTo(ally.pos) < 800 and IsValid(ally) then 
						if Menu.AutoE.ally:Value() and Menu.AutoE.Targets[ally.charName] and Menu.AutoE.Targets[ally.charName]:Value() and Ready(_E) and enemy.activeSpell.target == ally.handle then
							if not HasBuff(myHero, "KarmaMantra") then
								Control.CastSpell(HK_E, ally)
							end
						end
					end
				end		
				
				if Menu.AutoE.self:Value() and Ready(_E) and enemy.activeSpell.target == myHero.handle then
					if not HasBuff(myHero, "KarmaMantra") then
						Control.CastSpell(HK_E, myHero)
					end
				end	
			end
		end
	end	
end

local QPos = nil
function Combo()
	if QPos and not Ready(_R) then
		Control.CastSpell(HK_Q, QPos)
		QPos = nil
	end	
	
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
		if MenuValue == 1 then
			
			if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 900 and Ready(_Q) then
				if myHero:GetSpellData(_R).currentCd <= Menu.Combo.wait:Value() then
					local PredPos = CastQ(target, 2)
					if PredPos then
						local CastPos = myHero.pos:Lerp(Vector(PredPos), 220 / Vector(PredPos):DistanceTo(myHero.pos))
						local Col = CheckMinionCollision(myHero.pos, CastPos, 0.25, 1700, 80)
						if not Col then
							QPos = PredPos
							if Ready(_R) then
								Control.CastSpell(HK_R)								
							end
						end		
					end
				else
					local PredPos = CastQ(target, 1)
					if PredPos and not HasBuff(myHero, "KarmaMantra") then
						local CastPos = myHero.pos:Lerp(Vector(PredPos), 200 / Vector(PredPos):DistanceTo(myHero.pos))
						local Col = CheckMinionCollision(myHero.pos, CastPos, 0.25, 1700, 60)
						if not Col then
							Control.CastSpell(HK_Q, PredPos)
						end		
					end				
				end
			end
		   
			if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 670 and Ready(_W) and not Ready(_Q) and not HasBuff(myHero, "KarmaMantra") then
				Control.CastSpell(HK_W, target)						
			end
		
		elseif MenuValue == 2 then

			if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 670 and Ready(_W) then
				if myHero:GetSpellData(_R).currentCd <= Menu.Combo.wait:Value() then
					if Ready(_R) then 
						Control.CastSpell(HK_R)
					end	
					if HasBuff(myHero, "KarmaMantra") then		
						Control.CastSpell(HK_W, target)	
					end	
				elseif not HasBuff(myHero, "KarmaMantra") then
					Control.CastSpell(HK_W, target)					
				end										
			end	
			
			if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 900 and Ready(_Q) and not HasBuff(myHero, "KarmaMantra") then
				local PredPos = CastQ(target, 1)
				if PredPos then
					local CastPos = myHero.pos:Lerp(Vector(PredPos), 200 / Vector(PredPos):DistanceTo(myHero.pos))
					local Col = CheckMinionCollision(myHero.pos, CastPos, 0.25, 1700, 60)
					if not Col then
						Control.CastSpell(HK_Q, PredPos)
					end	
				end				
			end	
			
		else
		
			if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 900 and Ready(_Q) and not HasBuff(myHero, "KarmaMantra") then
				local PredPos = CastQ(target, 1)
				if PredPos then
					local CastPos = myHero.pos:Lerp(Vector(PredPos), 200 / Vector(PredPos):DistanceTo(myHero.pos))
					local Col = CheckMinionCollision(myHero.pos, CastPos, 0.25, 1700, 60)
					if not Col then
						Control.CastSpell(HK_Q, PredPos)
					end	
				end				
			end
		   
			if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 670 and Ready(_W) and not HasBuff(myHero, "KarmaMantra") then
				Control.CastSpell(HK_W, target)						
			end		
		end	
	end
end

function Harass()
	if QPos and not Ready(_R) then
		Control.CastSpell(HK_Q, QPos)
		QPos = nil
	end	

	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then	
		
		if Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 900 and Ready(_Q) then
			if Ready(_R) then
				local PredPos = CastQ(target, 2)
				if PredPos then
					local CastPos = myHero.pos:Lerp(Vector(PredPos), 220 / Vector(PredPos):DistanceTo(myHero.pos))
					local Col = CheckMinionCollision(myHero.pos, CastPos, 0.25, 1700, 80)
					if not Col then
						QPos = PredPos
						if Ready(_R) then
							Control.CastSpell(HK_R)								
						end
					end	
				end		
			else
				local PredPos = CastQ(target, 1)
				if PredPos and not HasBuff(myHero, "KarmaMantra") then
					local CastPos = myHero.pos:Lerp(Vector(PredPos), 200 / Vector(PredPos):DistanceTo(myHero.pos))
					local Col = CheckMinionCollision(myHero.pos, CastPos, 0.25, 1700, 60)
					if not Col then
						Control.CastSpell(HK_Q, PredPos)
					end
				end	
			end	
		end
	   
		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 670 and Ready(_W) and not Ready(_Q) and not HasBuff(myHero, "KarmaMantra") then
			Control.CastSpell(HK_W, target)						
		end

	end
end	

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
			
            if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 900 and IsValid(minion) and Ready(_Q) then
                local count = GetMinionCount(280, minion)
				if count >= Menu.Clear.UseQM:Value() then
					Control.CastSpell(HK_Q, minion.pos)
				end
            end
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 900 and IsValid(minion) and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 670 and IsValid(minion) and Ready(_W) then
				Control.CastSpell(HK_W, minion)	
            end
        end
    end
end

function CastQ(unit, mode)
	if mode == 1 then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
				return pred.CastPosition
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				return pred.CastPos
			end
		else	
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 950, Speed = 1700, Collision = false})
			QPrediction:GetPrediction(unit, myHero)
			if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				return QPrediction.CastPosition
			end	
		end
	else
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, Q2Data, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
				return pred.CastPosition
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, Q2spellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				return pred.CastPos
			end
		else	
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 950, Speed = 1700, Collision = false})
			QPrediction:GetPrediction(unit, myHero)
			if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				return QPrediction.CastPosition
			end	
		end
	end
	return nil
end


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
		if unit.team == myHero.team and unit ~= myHero then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 30 or buff.type == 22 or buff.type == 28 or buff.type == 8 or buff.name == 10 or buff.name == 18 or buff.name == 24 ) and buff.count > 0 then
			return true
		end
	end
	return false	
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

local function GetMinionsAround(pos, range)
	local range = range or MathHuge; local t = {}; local n = 0
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and minion.team == TEAM_ENEMY and minion.alive and minion.valid and GetDistance(pos, minion.pos) <= range then
			TableInsert(t, minion); n = n + 1
		end
	end
	return t, n
end

local function GetCircularAOEPos(units, radius, expected)
	local BestPos = nil; local MostHit = 0
	for i = 1, #units do
		local unit = units[i]; local MostHit = 0
		for j = 1, #units do
			local target = units[j]
			if GetDistance(target.pos, unit.pos) <= radius then MostHit = MostHit + 1 end
		end
		BestPos = unit.pos
		if MostHit >= expected then return BestPos, MostHit end
	end
	return nil, 0
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

local function GetLineTargetCount(source, Pos, delay, speed, width, range)
	local _PossibleUnits = {}
	local Count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
		if hero and myHero.pos:DistanceTo(hero.pos) <= range and IsValid(hero) then
			
			local predictedPos = PredictUnitPosition(hero, delay+ GetDistance(source, hero.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (hero.boundingRadius + width) * (hero.boundingRadius + width)) then
				Count = Count + 1
				TableInsert(_PossibleUnits, hero)
			end
		end
	end
	for i, Ally in ipairs(GetAllyHeroes()) do
		if Ally and myHero.pos:DistanceTo(Ally.pos) <= range and IsValid(Ally) then
			
			local predictedPos = PredictUnitPosition(Ally, delay+ GetDistance(source, Ally.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (Ally.boundingRadius + width) * (Ally.boundingRadius + width)) then
				Count = Count + 1
				TableInsert(_PossibleUnits, Ally)
			end
		end
	end	
	return Count, _PossibleUnits
end

local function CastSpellMM(spell,pos,range,delay)
	local range = range or MathHuge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Latency() then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x-5,castPosMM.y-5)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Latency()/1000)
		end
		if ticker - castSpell.casting > Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

local function RRange()
	local UltRange = 1200
	local UltTarget = nil
	for i, hero in ipairs(GetEnemyHeroes()) do
		if hero and myHero.pos:DistanceTo(target.pos) <= 4000 and IsValid(hero) then
			local count, Units = GetLineTargetCount(myHero.pos, hero.pos, 0.5, 1600, 320, 3000)
			if count > 1 then
				local Unit1, Unit2, Unit3, Unit4, Unit5 = nil, nil, nil, nil, nil
				local range1, range2, range3, range4, range5  = 99999, 99999, 99999, 99999, 99999
				for i = 1, #Units do
					local unit = Units[i]
					if unit and unit ~= hero and GetDistance(myHero.pos, unit.pos) < range1 then
						UltRange = UltRange + GetDistance(myHero.pos, unit.pos)
						range1 = GetDistance(myHero.pos, unit.pos)
						Unit1 = unit
						UltTarget = hero
					end
					
					if Unit1 and unit and unit ~= hero and unit ~= Unit1 and GetDistance(Unit1.pos, unit.pos) < range2 then
						UltRange = UltRange + GetDistance(Unit1.pos, unit.pos)
						range2 = GetDistance(Unit1.pos, unit.pos)
						Unit2 = unit
						UltTarget = hero
					end
					
					if Unit2 and unit and unit ~= hero and unit ~= Unit1 and unit ~= Unit2 and GetDistance(Unit2.pos, unit.pos) < range3 then
						UltRange = UltRange + GetDistance(Unit2.pos, unit.pos)
						range3 = GetDistance(Unit2.pos, unit.pos)
						Unit3 = unit
						UltTarget = hero
					end	

					if Unit3 and unit and unit ~= hero and unit ~= Unit1 and unit ~= Unit2 and unit ~= Unit3 and GetDistance(Unit3.pos, unit.pos) < range4 then
						UltRange = UltRange + GetDistance(Unit3.pos, unit.pos)
						range4 = GetDistance(Unit3.pos, unit.pos)
						Unit4 = unit
						UltTarget = hero
					end	

					if Unit4 and unit and unit ~= hero and unit ~= Unit1 and unit ~= Unit2 and unit ~= Unit3 and unit ~= Unit4 and GetDistance(Unit4.pos, unit.pos) < range5 then
						UltRange = UltRange + GetDistance(Unit4.pos, unit.pos)
						range5 = GetDistance(Unit4.pos, unit.pos)
						Unit5 = unit
						UltTarget = hero
					end	
				end
			end
		end
	end
	return UltRange, UltTarget
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	

	--AutoE  
	Menu:MenuElement({type = MENU, id = "AutoE", name = "E Settings"})
	Menu.AutoE:MenuElement({id = "UseE", name = "[E] cast only on Immobile Traget", value = true})
	Menu.AutoE:MenuElement({id = "Change", name = "Only Combo/Harass or everytime ?", value = 1, drop = {"Combo/Harass", "Everytime", "never use E"}})			
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "self", name = "[W] if own Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})
	Menu.Combo:MenuElement({id = "ally", name = "[W] if Ally Hp lower than -->", value = 35, min = 0, max = 100, identifier = "%"})	
	Menu.Combo:MenuElement({id = "UseE", name = "[R]", value = true})
	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "self", name = "[W] if own Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})
	Menu.Harass:MenuElement({id = "ally", name = "[W] if Ally Hp lower than -->", value = 35, min = 0, max = 100, identifier = "%"})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 30, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "Count", name = "Min Minions", value = 3, min = 1, max = 7, step = 1, identifier = "Minion/s"})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] standard Range", value = false})	
	
	
	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 350, Range = 900, Speed = 1200, Collision = false
	}
	
	QspellData = {speed = 1200, range = 900, delay = 0.25, radius = 350, collision = {nil}, type = "circular"}		

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1300, Speed = 1200, Collision = false
	}
	
	EspellData = {speed = 1200, range = 1300, delay = 0.25, radius = 70, collision = {nil}, type = "linear"}	

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 1200, 1, DrawColor(255, 225, 255, 10))
		end 		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 1300, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 800, 1, DrawColor(225, 225, 125, 10))
		end
	end)	
end

local CanCastUlt = false
function Tick()	
if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Ult()
		Combo()	
		if Menu.AutoE.Change:Value() == 1 then
			AutoE()
		end
	elseif Mode == "Harass" then
		Harass()
		if Menu.AutoE.Change:Value() == 1 then
			AutoE()
		end		
	elseif Mode == "Clear" then
		Clear()
		JungleClear()		
	end
	
	if Menu.AutoE.Change:Value() == 2 then 
		AutoE()
	end	
	
	KillSteal()	
end

function AutoE()
	if CanCastUlt then return end
	for i, target in ipairs(GetEnemyHeroes()) do
		if target and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 1300 and IsValid(target) then	
			if Menu.AutoE.UseE:Value() then
				if IsImmobileTarget(target) then
					CastE(target)
				end
			else
				CastE(target)
			end	
		end 
	end
end
        
function KillSteal()	
	if CanCastUlt then return end
	for i, target in ipairs(GetEnemyHeroes()) do

		if Menu.ks.UseQ:Value() and Ready(_Q) and Menu.ks.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 900 and IsValid(target) then
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)	
			if (QDmg+EDmg) > (target.health - target.hpRegen*2) then 
				CastE(target)
			end
		end	
		
		if Menu.ks.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 900 and IsValid(target) then
			local QDmg = getdmg("Q", target, myHero) 
			if QDmg > target.health then 
				CastQ(target)
			end
		end
		
		if Menu.ks.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 1300 and IsValid(target) then
			local EDmg = getdmg("E", target, myHero) 
			if EDmg > target.health then			
				CastE(target)
			end
		end
	end	
end

function Ult()	
	if Menu.Combo.UseR:Value() and Ready(_R) then	
		local range, target = RRange()
		if target then 
			CanCastUlt = true
			if target.pos:To2D().onScreen then
				Control.CastSpell(HK_R, target.pos)
			else 
				CastSpellMM(HK_R, target.pos, range, 500)
			end	
		end
	end	
end		

function Combo()
	if CanCastUlt then return end
	if Menu.Combo.UseW:Value() and Ready(_W) then
		if myHero.health/myHero.maxHealth <= Menu.Combo.self:Value() / 100 then
			Control.CastSpell(HK_W)
		else
			for i, Ally in ipairs(GetAllyHeroes()) do
				if Ally and myHero.pos:DistanceTo(Ally.pos) < 800 and IsValid(Ally) then
					if Ally.health/Ally.maxHealth <= Menu.Combo.ally:Value() / 100 then
						Control.CastSpell(HK_W)	
					end	
				end
			end
		end
	end	

	local target = GetTarget(900)
	if target == nil then return end
	if IsValid(target) then	
		
		if Menu.Combo.UseQ:Value() and Ready(_Q) then
			CastQ(target)
        end	
	end
end	

function Harass()
	if myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		if Menu.Harass.UseW:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= Menu.Harass.self:Value() / 100 then
				Control.CastSpell(HK_W)
			else
				for i, Ally in ipairs(GetAllyHeroes()) do
					if Ally and myHero.pos:DistanceTo(Ally.pos) < 800 and IsValid(Ally) then
						if Ally.health/Ally.maxHealth <= Menu.Harass.ally:Value() / 100 then
							Control.CastSpell(HK_W)	
						end	
					end
				end
			end
		end	

		local target = GetTarget(900)
		if target == nil then return end
		if IsValid(target) then	
			
			if Menu.Harass.UseQ:Value() and Ready(_Q) then
				CastQ(target)
			end	
		end		
	end
end	

function Clear()	
	if Ready(_Q) and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then	
		local minions, count = GetMinionsAround(myHero.pos, 900)
		if count >= Menu.Clear.Count:Value() then
			local BestPos, MostHit = GetCircularAOEPos(minions, 350, Menu.Clear.Count:Value())
			if BestPos then
				Control.CastSpell(HK_Q, BestPos)
			end	
		end	 
	end
end

function JungleClear()		
	if Ready(_Q) and Menu.JClear.UseQ:Value() then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)	
			if myHero.pos:DistanceTo(minion.pos) < 900 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then				
				Control.CastSpell(HK_Q, minion.pos)
			end  
		end
	end
end

function CastQ(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, QData, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
			Control.CastSpell(HK_Q, pred.CastPos)
		end
	else
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 350, Range = 900, Speed = 1200, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end					
	end
end

function CastE(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, EData, myHero)
		if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
			Control.CastSpell(HK_E, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
			Control.CastSpell(HK_E, pred.CastPos)
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1300, Speed = 1200, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end					
	end
end
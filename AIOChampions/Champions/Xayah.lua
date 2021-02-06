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

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
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

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointLine, pointSegment, isOnSegment
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

local OnPostAttack
OnPostAttack = function(fn)
    if _G.SDK then
        return _G.SDK.Orbwalker:OnPostAttack(fn)    
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:OnPostAttack(fn)
	end
end

local Timer = Game.Timer
local PassiveTable = {}
local function GetLineTargetCount(source, Pos, delay, speed, width)
	local Count = 0
	for i = 1, #PassiveTable do
		local object = PassiveTable[i]
		if object and object.placetime > Game.Timer() and GetDistance(object.pos, myHero.pos) <= 3000 then
			local predictedPos = PredictUnitPosition(Pos, delay+ GetDistance(source, Pos.pos) / speed)
			local pointLine, proj1, isOnSegment = VectorPointProjectionOnLineSegment(source, object.pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (Pos.boundingRadius + width) * (Pos.boundingRadius + width)) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function LoadScript() 

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})			
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseQ2", name = "[Q] only in AutoAttack range", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseE2", name = "[E] If Can Hit X Feathers", value = 5, min = 2, max = 10, step = 1})
	Menu.Combo:MenuElement({id = "UseE3", name = "Save Mana for [E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({id = "UseR1", name = "[R] Save Life", value = true})
	Menu.Combo:MenuElement({id = "RHp", name = "[R] Save Life if Hp lower than -->", value = 15, min = 0, max = 100, identifier = "%"})	
	Menu.Combo:MenuElement({id = "TargetHp", name = "[R] if Target Hp lower than -->", value = 50, min = 0, max = 100, identifier = "%"})	
	Menu.Combo:MenuElement({id = "RTargets", name = "Ult Enemy Whitelist", type = MENU})
	DelayAction(function()	
		for i, Hero in pairs(GetEnemyHeroes()) do
			Menu.Combo.RTargets:MenuElement({id = Hero.charName, name = "Use [R] on " ..Hero.charName, value = true})		
		end	
	end,0.2)	
	
	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})	
	  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = false})
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})	
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})

	--Misc Menu
	Menu:MenuElement({type = MENU, id = "misc", name = "Misc Settings"})         		
	Menu.misc:MenuElement({id = "UseQ", name = "Auto[Q] immobile Enemies", value = true})
	Menu.misc:MenuElement({id = "UseE1", name = "Auto[E] if can root Enemy", value = true})
	Menu.misc:MenuElement({id = "UseE2", name = "Auto[E] if Enemy killable", value = true})		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 45, Range = 1100, Speed = 2075, Collision = false
	}
	
	QspellData = {speed = 2075, range = 1100, delay = 0.5, radius = 45, collision = {nil}, type = "linear"}

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 1, Radius = 150, Range = 1100, Speed = MathHuge, Collision = false
	}
	
	RspellData = {speed = MathHuge, range = 1100, delay = 1, radius = 150, collision = {nil}, type = "linear"}	
  	                                           
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("WndMsg", function(msg, param) CheckWndMsg(msg, param) end)
	OnPostAttack(function(...) PostAttack(...) end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end

		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1100, 1, DrawColor(255, 225, 255, 10))
		end                                                                                               
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 1100, 1, DrawColor(225, 225, 0, 10))
		end		
	end)		
end

function Tick()		
	if MyHeroNotReady() then return end
	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()		
	elseif Mode == "Clear" then
		LaneClear()
		JungleClear()		
	end
	AutoCast()
end

function CheckWndMsg(msg, param)
	if msg == 257 then
		local delay = nil
		if param == HK_Q then
			delay = 0.5 + ping
		elseif param == HK_R then
			delay = 1 + ping
		elseif param == HK_E then
			delay = ping
		end
	
		if delay then               
			DelayAction(function() 
				CheckFeathers() 
			end, delay)
		end
	end	
end

function PostAttack()
	CheckFeathers()
end

-- Stolen from WR --
function CheckFeather(obj)
	for i = 1, #PassiveTable do
		if PassiveTable[i].ID == obj.networkID then
			return true
		end
	end
end

function CheckFeathers()
	for i = 1, GameMissileCount() do
		local missile = GameMissile(i)
		--print(missile.missileData.name)
		if missile.missileData and missile.missileData.owner == myHero.handle and not CheckFeather(missile) then
			if missile.missileData.name:find("XayahQMissile1") or missile.missileData.name:find("XayahQMissile2") then 
				PassiveTable[#PassiveTable + 1] = {placetime = Timer() + 6, ID = missile.networkID, pos = Vector(missile.missileData.endPos), hit = false} 
			elseif missile.missileData.name:find("XayahRMissile") then
				PassiveTable[#PassiveTable + 1] = {placetime = Timer() + 6, ID = missile.networkID, pos = Vector(missile.missileData.endPos):Extended(myHero.pos, 100), hit = false} 
			elseif missile.missileData.name:find("XayahPassiveAttack") then
				PassiveTable[#PassiveTable + 1] = {placetime = Timer() + 6, ID = missile.networkID, pos = Vector(myHero.pos:Extended(missile.missileData.endPos, 1000)), hit = false} 
			elseif missile.missileData.name:find("XayahEMissileSFX") then
				PassiveTable = {}
			end
		end
	end	
end

function AutoCast()
	for i, Hero in pairs(GetEnemyHeroes()) do
	
		if Hero and IsValid(Hero) then
		
			if Menu.misc.UseQ:Value() and Ready(_Q) and GetDistance(myHero.pos, Hero.pos) < 1000 and IsImmobileTarget(Hero) then
				CastQ(Hero)
			end
			
			local FeatherCount = GetLineTargetCount(myHero.pos, Hero, 0.25, 4000, 80)
			--print(FeatherCount)
			if Menu.misc.UseE1:Value() and Ready(_E) and FeatherCount >= 3 then
				Control.CastSpell(HK_E)
			end

			if Menu.misc.UseE2:Value() and Ready(_E) and FeatherCount > 0 then
				local Dmg = FeatherCount*getdmg("E", Hero, myHero)
				if Dmg >= Hero.health then
					Control.CastSpell(HK_E)
				end	
			end				
		end
	end
end

function Combo()
	local target = GetTarget(3000)
	if target == nil then return end
	if IsValid(target) then
        
		if Menu.Combo.UseE:Value() and Ready(_E) then
			local FeatherCount = GetLineTargetCount(myHero.pos, target, 0.25, 4000, 80)
			if FeatherCount >= Menu.Combo.UseE2:Value() then
				Control.CastSpell(HK_E)	
			end	
        end	
		
		if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 1000 and Ready(_Q) and (not HasBuff(myHero, "XayahW") or myHero.hudAmmo <= 2) then
			if Menu.Combo.UseE3:Value() then
				if myHero.mana >= myHero:GetSpellData(_E).mana + myHero:GetSpellData(_Q).mana then
					if Menu.Combo.UseQ2:Value() then
						if myHero.pos:DistanceTo(target.pos) <= myHero.range then
							CastQ(target)
						end
					else
						CastQ(target)
					end
				end	
			else
				if Menu.Combo.UseQ2:Value() then
					if myHero.pos:DistanceTo(target.pos) <= myHero.range then
						CastQ(target)
					end
				else
					CastQ(target)
				end			
			end	
        end
       
		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 600 and Ready(_W) and myHero.hudAmmo <= 2 then
			if Menu.Combo.UseE3:Value() then
				if myHero.mana >= myHero:GetSpellData(_E).mana + myHero:GetSpellData(_W).mana then			
					Control.CastSpell(HK_W)
				end
			else
				Control.CastSpell(HK_W)
			end	
        end	

        if Menu.Combo.UseR:Value() and Ready(_R) then
			if Menu.Combo.UseR1:Value() then
				if myHero.health/myHero.maxHealth <= Menu.Combo.RHp:Value() / 100 and target.activeSpell.target == myHero.handle then
					Control.CastSpell(HK_R, target.pos)
					return
				end	
			end	
			
			if Menu.Combo.RTargets[target.charName] and Menu.Combo.RTargets[target.charName]:Value() then
				if myHero.pos:DistanceTo(target.pos) < 1000 and target.health/target.maxHealth <= Menu.Combo.TargetHp:Value() / 100 then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, RData, myHero)
						if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
							Control.CastSpell(HK_R, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
							Control.CastSpell(HK_R, pred.CastPos)
						end
					else
						local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 1, Radius = 150, Range = 1100, Speed = MathHuge, Collision = false})
						RPrediction:GetPrediction(target, myHero)
						if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
							Control.CastSpell(HK_R, RPrediction.CastPosition)
						end	
					end
				end
			end	
		end
	end
end

function Harass()
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
        
		if Menu.Harass.UseQ:Value() and Ready(_Q) and (not HasBuff(myHero, "XayahW") or myHero.hudAmmo <= 2) then
			CastQ(target)	
        end
       
		if Menu.Harass.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 600 and Ready(_W) and myHero.hudAmmo <= 2 then
			Control.CastSpell(HK_W)	
        end
	end
end

function LaneClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1100 and IsValid(minion) and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)	
            end
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1100 and IsValid(minion) and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 600 and IsValid(minion) and Ready(_W) then	
				Control.CastSpell(HK_W)	
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
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.5, Radius = 45, Range = 1100, Speed = 2075, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end	
	end	
end

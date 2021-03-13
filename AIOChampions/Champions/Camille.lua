require "MapPositionGOS"
local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
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

local function Rotate(startPos, endPos, height, theta)
    local dx, dy = endPos.x - startPos.x, endPos.z - startPos.z
    local px, py = dx * math.cos(theta) - dy * math.sin(theta), dx * math.sin(theta) + dy * math.cos(theta)
    return Vector(px + startPos.x, height, py + startPos.z)
end

local Objects = {[3] = WALL }

local function FindBestWPos(mode)
    local startPos, mPos, height = Vector(myHero.pos), Vector(mousePos), myHero.pos.y
    for i = 100, 2000, 100 do -- search range
        local endPos = startPos:Extended(mPos, i)
        for j = 20, 360, 20 do -- angle step
            local testPos = Rotate(startPos, endPos, height, math.rad(j))
            if testPos:ToScreen().onScreen then 
                if mode == Objects.WALL and MapPosition:inWall(testPos) then
                    return testPos
                end
            end
        end
    end
    return nil
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.11"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({name = " ", drop = {"AutoSwitch Combo: BurstCombo / StandardCombo"}})
	Menu.Combo:MenuElement({name = " ", drop = {"Set AutoAttacks = (+Calc. AADmg for BustCombo)"}})	
	Menu.Combo:MenuElement({id = "UseAA", name = "Set AutoAttacks", value = 3, min = 0, max = 10, identifier = "AutoAttack/s"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseW2", name = "[E] > [W] > [E] if possible", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E1]", value = true})
	Menu.Combo:MenuElement({id = "UseE2", name = "[E2]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "Wcount", name = "[W] min Minions", value = 3, min = 0, max = 10, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true}) 	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})

	--LastHit
	Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit Mode"})	
	Menu.LastHit:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.LastHit:MenuElement({id = "UseQ2", name = "[Q2]", value = true})
	Menu.LastHit:MenuElement({id = "UseW", name = "[W] if out of AArange", value = true})	
	Menu.LastHit:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})		
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E2]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	
	WData =
	{
	Type = _G.SPELLTYPE_CONE, Delay = 0.25, Radius = 300, Range = 610, Speed = 1750, Collision = false
	}

	WspellData = {speed = 1750, range = 610, delay = 0.25, radius = 0, angle = 70, collision = {nil}, type = "conic"}
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0, Radius = 130, Range = 1400, Speed = 1050+myHero.ms, Collision = false
	}

	EspellData = {speed = 1050+myHero.ms, range = 1400, delay = 0, radius = 130, collision = {nil}, type = "linear"}	

	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function()
	  if myHero.dead then return end                                                 
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 475, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 650, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

local IsCastingE = false
function Tick()
if myHero:GetSpellData(_E).name == "CamilleEDash2" or myHero.pathing.isDashing then 
	SetMovement(false) 
	IsCastingE = true
else
	SetMovement(true) 
	IsCastingE = false	
end

if Menu.Combo.UseW2:Value() and Ready(_W) and myHero.pathing.isDashing then
	local target = GetTarget(2000)
	if target and IsValid(target) then
		Control.CastSpell(HK_W, target.pos)
	end	
end

if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "LastHit" then
		LastHit()
	end
end

local function Q2TrueDamage()
	local total = 0
	local Lvl = myHero.levelData.lvl
	local qLvl = myHero:GetSpellData(_Q).level
	if qLvl >= 1 then	
	local qDMG = ({ 0.4, 0.5, 0.6, 0.7, 0.8 })[qLvl] * myHero.totalDamage + myHero.totalDamage
	local TrueDMG = ({ 0.4, 0.44, 0.48, 0.52, 0.56, 0.6, 0.64, 0.68, 0.72, 0.76, 0.8, 0.84, 0.88, 0.92, 0.96, 1.0, 1.0, 1.0 })[Lvl] * qDMG

	total = TrueDMG  
	end
	return total
end

local function ComboDmg(unit)
	local AADmg = (getdmg("AA", unit, myHero)*3) + (getdmg("AA", unit, myHero) * Menu.Combo.UseAA:Value())
	local Q1Dmg = getdmg("Q", unit, myHero, 1)
	local Q2Dmg = ((getdmg("Q", unit, myHero, 1)*2) + getdmg("AA", unit, myHero)) - Q2TrueDamage()
	local QTrueDmg = Q2TrueDamage()
	local WDmg = getdmg("W", unit, myHero)
	local EDmg = getdmg("E", unit, myHero)
	local RDmg = getdmg("R", unit, myHero) * (Menu.Combo.UseAA:Value()+3)
	local FullDmg = (AADmg + Q1Dmg + Q2Dmg + QTrueDmg + WDmg + EDmg + RDmg)
	if unit.health < FullDmg then
		return true
	end
	return false
end

function Combo()
local target = GetTarget(2000)
if target == nil then return end
	if IsValid(target) then
	local QRange = (myHero.range + 50 + myHero.boundingRadius + target.boundingRadius)
		
		if Menu.Combo.UseE2:Value() and Ready(_E) then
			if myHero:GetSpellData(_E).name == "CamilleEDash2" then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						Control.CastSpell(HK_E, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						Control.CastSpell(HK_E, pred.CastPos)
					end
				else				
					local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0, Radius = 130, Range = 1400, Speed = 1050+myHero.ms, Collision = false})
					EPrediction:GetPrediction(target, myHero)
					if EPrediction:CanHit(Menu.Pred.PredE:Value()+1) then
						Control.CastSpell(HK_E, EPrediction.CastPosition)
					end
				end	
			end
		end	
		
		if IsCastingE then return end
		
		if ComboDmg(target) then
		
			if Ready(_R) then
				if myHero.pos:DistanceTo(target.pos) > 500 and Menu.Combo.UseE:Value() and Ready(_E) then
					local castPos = FindBestWPos(Objects.WALL)
					if castPos ~= nil and target.pos:DistanceTo(castPos) < 1000 and myHero.pos:DistanceTo(castPos) < 800 then			
						Control.CastSpell(HK_E, castPos)
					end
				end
			else
				if myHero.pos:DistanceTo(target.pos) > 300 and Menu.Combo.UseE:Value() and Ready(_E) then
					local castPos = FindBestWPos(Objects.WALL)
					if castPos ~= nil and target.pos:DistanceTo(castPos) < 1000 and myHero.pos:DistanceTo(castPos) < 800 then			
						Control.CastSpell(HK_E, castPos)
					end
				end				
			end	
			
			if myHero.pos:DistanceTo(target.pos) < QRange and not HasBuff(myHero, "camilleqprimingstart") and Menu.Combo.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end		
						
			if myHero.pos:DistanceTo(target.pos) < 610 and Menu.Combo.UseW:Value() and Ready(_W) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						Control.CastSpell(HK_W, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						Control.CastSpell(HK_W, pred.CastPos)
					end
				else
					local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CONE, Delay = 0.25, Radius = 300, Range = 610, Speed = 1750, Collision = false})
					WPrediction:GetPrediction(target, myHero)
					if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
						Control.CastSpell(HK_W, WPrediction.CastPosition)
					end					
				end	
			end	

			if myHero.pos:DistanceTo(target.pos) < 475 and Menu.Combo.UseR:Value() and Ready(_R) then
				Control.CastSpell(HK_R, target)
			end
		
		
		else
			
			if myHero.pos:DistanceTo(target.pos) < QRange and not HasBuff(myHero, "camilleqprimingstart") and Menu.Combo.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end	

			if myHero.pos:DistanceTo(target.pos) > 300 and Menu.Combo.UseE:Value() and Ready(_E) then
				local castPos = FindBestWPos(Objects.WALL)
				if castPos ~= nil and target.pos:DistanceTo(castPos) < 1000 and myHero.pos:DistanceTo(castPos) < 800 then			
					Control.CastSpell(HK_E, castPos)
				end
			end
			
			if myHero.pos:DistanceTo(target.pos) < 610 and myHero.pos:DistanceTo(target.pos) > 310 and Menu.Combo.UseW:Value() and Ready(_W) and not HasBuff(myHero, "camilleedashtoggle") then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						Control.CastSpell(HK_W, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						Control.CastSpell(HK_W, pred.CastPos)
					end
				else
					local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CONE, Delay = 0.25, Radius = 300, Range = 610, Speed = 1750, Collision = false})
					WPrediction:GetPrediction(target, myHero)
					if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
						Control.CastSpell(HK_W, WPrediction.CastPosition)
					end					
				end
			end				
		end	
	end
end	

function Harass()
local target = GetTarget(700)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		local QRange = (myHero.range + 50 + myHero.boundingRadius + target.boundingRadius)
		if myHero.pos:DistanceTo(target.pos) < QRange and not HasBuff(myHero, "camilleqprimingstart") and Menu.Harass.UseQ:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q)
		end	
		
		if myHero.pos:DistanceTo(target.pos) > 310 and myHero.pos:DistanceTo(target.pos) < 610 and Menu.Harass.UseW:Value() and Ready(_W) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
					Control.CastSpell(HK_W, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
					Control.CastSpell(HK_W, pred.CastPos)
				end
			else
				local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CONE, Delay = 0.25, Radius = 300, Range = 610, Speed = 1750, Collision = false})
				WPrediction:GetPrediction(target, myHero)
				if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
					Control.CastSpell(HK_W, WPrediction.CastPosition)
				end					
			end
		end	
	end
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 700 and minion.team == TEAM_ENEMY and IsValid(minion) then
			local QRange = (myHero.range + 50 + myHero.boundingRadius + minion.boundingRadius)
			local QDmg = (getdmg("Q", minion, myHero, 1) + getdmg("AA", minion, myHero))

			if Ready(_Q) and Menu.Clear.UseQ:Value() and myHero:GetSpellData(_Q).name == "CamilleQ2" and myHero.pos:DistanceTo(minion.pos) <= QRange then					 
				Control.CastSpell(HK_Q)
			end		
			
			if Ready(_Q) and Menu.Clear.UseQ:Value() and not HasBuff(myHero, "camilleqprimingstart") and myHero.pos:DistanceTo(minion.pos) <= QRange and QDmg > minion.health then	
				Control.CastSpell(HK_Q)
			end	

			if myHero.pos:DistanceTo(minion.pos) < 650 and Menu.Clear.UseW:Value() and Ready(_W) then
				if GetMinionCount(400, minion) >= Menu.Clear.Wcount:Value() then	
					Control.CastSpell(HK_W, minion.pos)
				end	
			end	
		end	
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 700 and minion.team == TEAM_JUNGLE and IsValid(minion) then
			local QRange = (myHero.range + 50 + myHero.boundingRadius + minion.boundingRadius)
			if Ready(_Q) and Menu.JClear.UseQ:Value() and not HasBuff(myHero, "camilleqprimingstart") and myHero.pos:DistanceTo(minion.pos) <= QRange then					
				Control.CastSpell(HK_Q)
			end	

			if myHero.pos:DistanceTo(minion.pos) < 650 and Menu.JClear.UseW:Value() and Ready(_W) then	
				Control.CastSpell(HK_W, minion.pos)	
			end	
		end	
	end
end

function LastHit()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.mana/myHero.maxMana >= Menu.LastHit.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 700 and minion.team == TEAM_ENEMY and IsValid(minion) then
			local QDmg = (getdmg("Q", minion, myHero, 1) + getdmg("AA", minion, myHero))
			local WDmg = getdmg("W", minion, myHero)
			local QRange = (myHero.range + 50 + myHero.boundingRadius + minion.boundingRadius)			
			
			if Ready(_Q) and Menu.LastHit.UseQ:Value() and not HasBuff(myHero, "camilleqprimingstart") and myHero.pos:DistanceTo(minion.pos) <= QRange and QDmg > minion.health then					
				Control.CastSpell(HK_Q)
			end	

			if myHero.pos:DistanceTo(minion.pos) < 650 and myHero.pos:DistanceTo(minion.pos) > 200 and Menu.LastHit.UseW:Value() and Ready(_W) and WDmg > minion.health then	
				Control.CastSpell(HK_W, minion.pos)	
			end	
		end	
	end
end


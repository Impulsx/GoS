function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,Game.MinionCount() do
	local hero = Game.Minion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

require "MapPositionGOS"

function LoadScript()
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({name = " ", drop = {"2 AutoComboModes (AutoSwitch ComboMode: KillCombo / Standard Combo)"}})
	Menu.Combo:MenuElement({name = " ", drop = {"Set AutoAttacks (+Calculate AADmg for KillCombo)"}})	
	Menu.Combo:MenuElement({id = "UseAA", name = "Set AutoAttacks", value = 3, min = 0, max = 10, identifier = "AutoAttack/s"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q] If AutoAttack cooldown", value = true})
	Menu.Clear:MenuElement({id = "UseQ2", name = "[Q2]", value = true})
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "Wcount", name = "[W] min Minions", value = 3, min = 0, max = 10, identifier = "Minions/s"})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseQ2", name = "[Q2]", value = true}) 
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
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E2]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	
	WData =
	{
	Type = _G.SPELLTYPE_CONE, Delay = 1.1, Radius = 650, Range = 800, Speed = 1750, Collision = false
	}

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 925, Speed = 1750, Collision = false
	}
  	
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function()
	  if myHero.dead then return end                                                 
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 475, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 1130, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 650, 1, Draw.Color(225, 225, 125, 10))
		end
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
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
		Clear()
		JungleClear()
	elseif Mode == "LastHit" then
		LastHit()
	end	

end

function ComboDmg(unit)
	local AADmg = (getdmg("AA", unit, myHero)*3) + (getdmg("AA", unit, myHero) * Menu.Combo.UseAA:Value())
	local Q1Dmg = (getdmg("Q", unit, myHero, 1) * 2)
	local WDmg = getdmg("W", unit, myHero)
	local EDmg = getdmg("E", unit, myHero)
	local RDmg = getdmg("R", unit, myHero) * (Menu.Combo.UseAA:Value()+3)
	local FullDmg = (AADmg + Q1Dmg + WDmg + EDmg + RDmg)
	if unit.health < FullDmg then
		return true
	end
	return false
end	

local function CheckERange(unit)
	local point = Point(myHero.pos.x, myHero.pos.z)
	local Pos1, Pos2, Pos3 = unit.pos, myHero.pos, MapPosition:inWall(point)
	local a, b = 800, 800
	local C2 = (a*a) + (b*b)
	local c = math.sqrt(C2)
	if Pos1:DistanceTo(Pos2) < c then
	return Pos3
	end
	return nil
end

	
function Combo()
local target = GetTarget(1300)
if target == nil then return end
	if IsValid(target) then
	local castedE = false
	local Q1Buff = GetBuffData(myHero, "Q1")	
	local Q2Buff = GetBuffData(myHero, "Q2")	
		if ComboDmg(target) then
		
			if myHero:GetSpellData(_E).name == "CamilleE2" and Menu.Combo.UseE:Value() and Ready(_E) then
				if myHero.pos:DistanceTo(target.pos) <= 800 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
						castedE = Control.CastSpell(HK_E, pred.CastPosition)
					end
				else
					castedE = Control.CastSpell(HK_E, target.pos)
				end	
			end
			
			if Ready(_R) then
				if myHero.pos:DistanceTo(target.pos) < 1030 and myHero.pos:DistanceTo(target.pos) > 475 and myHero:GetSpellData(_E).name == "CamilleE1" and Menu.Combo.UseE:Value() and Ready(_E) then
					local Pos3 = CheckERange(target)
					if Pos3 then			
						castedE = Control.CastSpell(HK_E, Pos3)
					end
				end
			else
				if myHero.pos:DistanceTo(target.pos) < 1030 and myHero.pos:DistanceTo(target.pos) > 300 and myHero:GetSpellData(_E).name == "CamilleE1" and Menu.Combo.UseE:Value() and Ready(_E) then
					local Pos3 = CheckERange(target)
					if Pos3 then			
						castedE = Control.CastSpell(HK_E, Pos3)
					end
				end				
			end	
			
			if myHero.pos:DistanceTo(target.pos) < 300 and myHero:GetSpellData(_Q).name == "CamilleQ1" and Menu.Combo.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end	
			
			if myHero.pos:DistanceTo(target.pos) < 300 and myHero:GetSpellData(_Q).name == "CamilleQ2" and Q1Buff.duration < 2 and Menu.Combo.UseQ2:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end	
			
			if not (Q1Buff or Q2Buff) and myHero.pos:DistanceTo(target.pos) < 650 and Menu.Combo.UseW:Value() and Ready(_W) then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then	
					Control.CastSpell(HK_W, pred.CastPosition)
				end	
			end	

			if castedE then return end
			if myHero.pos:DistanceTo(target.pos) < 475 and Menu.Combo.UseR:Value() and Ready(_R) then
				Control.CastSpell(HK_R, target)
			end
		
		else
			
			if myHero.pos:DistanceTo(target.pos) < 300 and myHero:GetSpellData(_Q).name == "CamilleQ1" and Menu.Combo.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end	
			
			if myHero.pos:DistanceTo(target.pos) < 300 and myHero:GetSpellData(_Q).name == "CamilleQ2" and Q1Buff.duration < 2 and Menu.Combo.UseQ2:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end

			if myHero:GetSpellData(_E).name == "CamilleE2" and Menu.Combo.UseE:Value() and Ready(_E) then
				if myHero.pos:DistanceTo(target.pos) <= 800 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
						castedE = Control.CastSpell(HK_E, pred.CastPosition)
					end
				else
					castedE = Control.CastSpell(HK_E, target.pos)
				end	
			end

			if myHero.pos:DistanceTo(target.pos) < 1030 and myHero.pos:DistanceTo(target.pos) > 300 and myHero:GetSpellData(_E).name == "CamilleE1" and Menu.Combo.UseE:Value() and Ready(_E) then
				local Pos3 = CheckERange(target)
				if Pos3 then			
					castedE = Control.CastSpell(HK_E, Pos3)
				end
			end

			if myHero.pos:DistanceTo(target.pos) < 650 and myHero.pos:DistanceTo(target.pos) > 325 and Menu.Combo.UseW:Value() and Ready(_W) then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then	
					Control.CastSpell(HK_W, pred.CastPosition)
				end	
			end				
		end	
	end
end	

function Harass()
local target = GetTarget(700)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		local Q1Buff = GetBuffData(myHero, "Q1")
		local Q2Buff = GetBuffData(myHero, "Q2")
		if myHero.pos:DistanceTo(target.pos) < 300 and myHero:GetSpellData(_Q).name == "CamilleQ1" and Menu.Harass.UseQ:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q)
		end	
			
		if myHero.pos:DistanceTo(target.pos) < 300 and myHero:GetSpellData(_Q).name == "CamilleQ2" and Q1Buff.duration < 2 and Menu.Harass.UseQ2:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q)
		end
		
		if ((not (Q1Buff or Q2Buff)) or myHero.pos:DistanceTo(target.pos) > 325) and myHero.pos:DistanceTo(target.pos) < 650 and Menu.Harass.UseW:Value() and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then	
				Control.CastSpell(HK_W, pred.CastPosition)
			end	
		end	
	end
end	

function Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local Q1Buff = GetBuffData(myHero, "Q1")
	local Q2Buff = GetBuffData(myHero, "Q2")

		if myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 700 and minion.team == TEAM_ENEMY and IsValid(minion) then
			local QDmg = (getdmg("Q", minion, myHero, 1) + getdmg("AA", minion, myHero))
			if Ready(_Q) and Menu.Clear.UseQ:Value() and myHero:GetSpellData(_Q).name == "CamilleQ1" and myHero.pos:DistanceTo(minion.pos) <= 175 and QDmg > minion.health then					
				if _G.SDK.Orbwalker:CanAttack(minion) then return end
				Control.CastSpell(HK_Q)
			end	
		
			if myHero.pos:DistanceTo(minion.pos) < 300 and myHero:GetSpellData(_Q).name == "CamilleQ2" and Menu.Clear.UseQ2:Value() and Ready(_Q) and Q1Buff.duration < 2 then
				Control.CastSpell(HK_Q)
			end	

			if not (Q1Buff or Q2Buff) and myHero.pos:DistanceTo(minion.pos) < 650 and Menu.Clear.UseW:Value() and Ready(_W) then
				if GetMinionCount(400, minion) >= Menu.Clear.Wcount:Value() then	
					Control.CastSpell(HK_W, minion.pos)
				end	
			end	
		end	
	end
end

function JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local Q1Buff = GetBuffData(myHero, "Q1")
	local Q2Buff = GetBuffData(myHero, "Q2")
		if myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 700 and minion.team == TEAM_JUNGLE and IsValid(minion) then
			
			if Ready(_Q) and Menu.JClear.UseQ:Value() and myHero:GetSpellData(_Q).name == "CamilleQ1" and myHero.pos:DistanceTo(minion.pos) <= 175 then					
				Control.CastSpell(HK_Q)
			end	
		
			if myHero.pos:DistanceTo(minion.pos) < 300 and myHero:GetSpellData(_Q).name == "CamilleQ2" and Menu.JClear.UseQ2:Value() and Ready(_Q) and Q1Buff.duration < 2 then
				Control.CastSpell(HK_Q)
			end	

			if not (Q1Buff or Q2Buff) and myHero.pos:DistanceTo(minion.pos) < 650 and Menu.JClear.UseW:Value() and Ready(_W) then	
				Control.CastSpell(HK_W, minion.pos)	
			end	
		end	
	end
end

function LastHit()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local Q1Buff = GetBuffData(myHero, "Q1")
	local Q2Buff = GetBuffData(myHero, "Q2")
		if myHero.mana/myHero.maxMana >= Menu.LastHit.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 700 and minion.team == TEAM_ENEMY and IsValid(minion) then
			local QDmg = (getdmg("Q", minion, myHero, 1) + getdmg("AA", minion, myHero))
			local Q2Dmg = ((getdmg("Q", minion, myHero, 2)*2) + getdmg("AA", minion, myHero))
			local WDmg = getdmg("W", minion, myHero)			
			
			if Ready(_Q) and Menu.LastHit.UseQ:Value() and myHero:GetSpellData(_Q).name == "CamilleQ1" and myHero.pos:DistanceTo(minion.pos) <= 175 and QDmg > minion.health then					
				Control.CastSpell(HK_Q)
			end	
		
			if myHero.pos:DistanceTo(minion.pos) < 175 and myHero:GetSpellData(_Q).name == "CamilleQ2" and Menu.LastHit.UseQ2:Value() and Ready(_Q) and Q1Buff.duration < 2 and Q2Dmg > minion.health then
				Control.CastSpell(HK_Q)
			end	

			if myHero.pos:DistanceTo(minion.pos) < 650 and myHero.pos:DistanceTo(minion.pos) > 200 and Menu.LastHit.UseW:Value() and Ready(_W) and WDmg > minion.health then	
				Control.CastSpell(HK_W, minion.pos)	
			end	
		end	
	end
end


local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

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

local CastedQ = false
local CastedE = false
local CastedR = false
local Burst = false

function LoadScript() 

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.08"}})			
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] [NormalCombo]", value = true})	
	Menu.Combo:MenuElement({id = "Passive", name = "Dont use [Q] if Passive active ?", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W] [NormalCombo]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E] [NormalCombo]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R1] [NormalCombo]", value = true})
	Menu.Combo:MenuElement({id = "HP", name = "[R1] if EnemyHP lower than -->", value = 50, min = 0, max = 100, identifier = "%"})
	Menu.Combo:MenuElement({type = MENU, id = "Burst", name = "Burst Options"})
	Menu.Combo.Burst:MenuElement({name = " ", drop = {"If ready Q+W+E+R then BurstCombo is active"}})
	Menu.Combo.Burst:MenuElement({id = "Active", name = "Use Burst Combo", value = true})
	Menu.Combo.Burst:MenuElement({id = "DuraE", name = "If Burst E2 not possible then E2 if expires", value = true})
	Menu.Combo.Burst:MenuElement({id = "Etime", name = "E2 cast time before expire", value = 0.5, min = 0.1, max = 2, step = 0.1, identifier = "sec"})	
	Menu.Combo.Burst:MenuElement({id = "DuraR", name = "If Burst R2 not possible then R2 if expires", value = true})
	Menu.Combo.Burst:MenuElement({id = "Rtime", name = "R2 cast time before expire", value = 0.5, min = 0.1, max = 2, step = 0.1, identifier = "sec"})	
	Menu.Combo.Burst:MenuElement({id = "Draw", name = "Draw Info Text [BurstCombo Active]", value = true})	
	
	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "Passive", name = "Dont use [Q] if Passive active ?", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E1]", value = true})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true}) 
	Menu.Clear:MenuElement({id = "Key", name = "ToggleKey Push or LastHit", key = string.byte("T"), toggle = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Energie to LaneClear", value = 30, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Energie to JungleClear", value = 30, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})				

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "TextPos LaneClear[Q]"})	
	Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.4, Radius = 55, Range = 650, Speed = 1800, Collision = true, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	EspellData = {speed = 1800, range = 650, delay = 0.4, radius = 55, collision = {"minion"}, type = "linear"}	
  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end

		if Menu.Combo.Burst.Draw:Value() and Burst then
			local textPos = myHero.pos:To2D()
			DrawText("Burst Active", 20, textPos.x - 33, textPos.y + 60, DrawColor(255, 0, 255, 0))
		end
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 500, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 250, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 650, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 675, 1, DrawColor(225, 225, 0, 10))
		end		

		DrawText("LaneClear[Q]: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+15, DrawColor(255, 225, 255, 0))
		if Menu.Clear.Key:Value() then
			DrawText("Push", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		else
			DrawText("LastHit", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		end
	end)		
end

function Tick()
CheckCastedSpells()

if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		if Burst then
			BurstCombo()
		end
		Combo()
	elseif Mode == "Clear" then
		if Menu.Clear.Key:Value() then
			Push()
		else
			LastHit()
		end	
		JungleClear()
	elseif Mode == "Harass" then
		Harass()		
	end
	KillSteal()	
end

function CheckCastedSpells()
	if CastedQ and Ready(_Q) then
		CastedQ = false
	end
	if CastedE and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliE" then
		CastedE = false
	end
	if CastedR and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliR" then
		CastedR = false
	end
	if Burst then
		if GetMode() ~= "Combo" then
			Burst = false
		end
	end
end

function RbDmg(unit)
    local LvL = myHero:GetSpellData(_R).level
	local R2Dmg = (({75, 145, 215})[LvL] + 0.3 * myHero.ap)
	local PercentMissingHealth = (1 - (unit.health / unit.maxHealth)) * 100
	
	if PercentMissingHealth < 7 then
		local RDmg = R2Dmg 
        return CalcMagicalDamage(myHero, unit, RDmg)
	elseif PercentMissingHealth >= 7 and PercentMissingHealth < 70 then
        local RDmg = R2Dmg + ((0.0286 * PercentMissingHealth) * R2Dmg)
        return CalcMagicalDamage(myHero, unit, RDmg)
    else
        local RDmg = R2Dmg * 3
        return CalcMagicalDamage(myHero, unit, RDmg)
    end
end

function FindMostMissHealth()
	local Most = nil
	for i, hero in ipairs(GetEnemyHeroes()) do
		if hero then
			local PercentMissingHealthUnit = (1 - (hero.health / hero.maxHealth)) * 100
			if Most == nil then 
				if GetDistance(hero.pos, myHero.pos) <= 750 and IsValid(hero) and PercentMissingHealthUnit >= 42 then
					Most = hero
				end	
				
			elseif GetDistance(hero.pos, myHero.pos) <= 750 and IsValid(hero) and Most ~= hero and (1 - (hero.health / hero.maxHealth)) * 100 > (1 - (Most.health / Most.maxHealth)) * 100 then
				Most = hero
			end
		end	
	end
	return Most
end

function Combo()
if Menu.Combo.Burst.Active:Value() and Ready(_Q) and Ready(_W) and Ready(_E) and Ready(_R) then Burst = true return end

local target = GetTarget(1500)     	
if target == nil or Burst then return end
	if IsValid(target) then

		if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 800 and Menu.Combo.UseR:Value() and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliR" and target.health/target.maxHealth <= Menu.Combo.HP:Value() /100 then
			Control.CastSpell(HK_R, target)	
		end	
				
		if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			if Menu.Combo.Passive:Value() then
				if not HasBuff(myHero, "AkaliPWeapon") then
					Control.CastSpell(HK_Q, target.pos)
				end				
			else
				Control.CastSpell(HK_Q, target.pos)	
			end	
		end

		if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 650 and Menu.Combo.UseE:Value() and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliE" then
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
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 55, Range = 650, Speed = 3200, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end				
			end	
		end	

		if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 1500 and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") then
			Control.CastSpell(HK_E)		
		end	

		if myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target.pos)	
		end	

		if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 725 and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliRb" then
			local R2Dmg = RbDmg(target)
			if R2Dmg >= target.health then
				Control.CastSpell(HK_R, target.pos)
			else
				for i = 0, myHero.buffCount do
					local buff = myHero:GetBuff(i)
					if buff.name == "AkaliR" and buff.count > 0 and buff.duration <= 0.5 then
						Control.CastSpell(HK_R, target.pos)
					end
				end			
			end
		end					
	end	
end	

function BurstCombo()
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) < 2000 and IsValid(target) then

			if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) <= 2000 and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") then
				local AADmg = getdmg("AA", target, myHero)*3
				local QDmg = Ready(_Q) and getdmg("Q", target, myHero) or 0
				local EDmg = getdmg("E", target, myHero)
				local R1Dmg = Ready(_R) and myHero:GetSpellData(_R).name == "AkaliR" and getdmg("R", target, myHero) or 0
				local R2Dmg = Ready(_R) and myHero:GetSpellData(_R).name == "AkaliRb" and RbDmg(target) or 0
				local FullDmg = AADmg+QDmg+EDmg+R1Dmg+R2Dmg
				if FullDmg >= target.health then
					Control.CastSpell(HK_E)
				else
					if Menu.Combo.Burst.DuraE:Value() then
						for i = 0, target.buffCount do
							local buff = target:GetBuff(i)
							if buff.name == "AkaliEMis" and buff.count > 0 and buff.duration <= Menu.Combo.Burst.Etime:Value() then
								Control.CastSpell(HK_E)
							end
						end	
					end	
				end	
			end	

			if not myHero.pathing.isDashing and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliRb" then				
				if GetEnemyCount(750, myHero) == 1 and myHero.pos:DistanceTo(target.pos) < 725 then
					local R2Dmg = RbDmg(target)+getdmg("AA", target, myHero)*2
					if R2Dmg >= target.health then
						Control.CastSpell(HK_R, target.pos)
					end
					
				elseif GetEnemyCount(750, myHero) > 1 then
					local R2Target = FindMostMissHealth()
					if R2Target then
						Control.CastSpell(HK_R, R2Target.pos)
					end
					
				end	
				
				if Menu.Combo.Burst.DuraR:Value() and myHero.pos:DistanceTo(target.pos) < 725 then
					for i = 0, myHero.buffCount do
						local buff = myHero:GetBuff(i)
						if buff.name == "AkaliR" and buff.count > 0 and buff.duration <= Menu.Combo.Burst.Rtime:Value() then
							Control.CastSpell(HK_R, target.pos)
						end
					end
				end	
			end			
			
			if myHero.pos:DistanceTo(target.pos) < 500 then
			
				if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 500 and Ready(_Q) and not HasBuff(myHero, "AkaliPWeapon") then
					Control.CastSpell(HK_Q, target.pos)
					CastedQ = true
				end
				
			else
			
				if not myHero.pathing.isDashing and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and Ready(_Q) then
					Control.CastSpell(HK_E)
				end	
			end
				
			if CastedQ or HasBuff(myHero, "AkaliPWeapon") then
			
				if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 800 and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliR" then
					Control.CastSpell(HK_R, target)
					CastedR = true
				end	

				if not myHero.pathing.isDashing and CastedR and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliE" then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, EData, myHero)
						if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
							Control.CastSpell(HK_E, pred.CastPosition)
							CastedE = true
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
							Control.CastSpell(HK_E, pred.CastPos)
							CastedE = true
						end
					else
						local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 55, Range = 650, Speed = 1800, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
						EPrediction:GetPrediction(target, myHero)
						if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
							Control.CastSpell(HK_E, EPrediction.CastPosition)
							CastedE = true
						end				
					end	
				end	
				
				if myHero.pos:DistanceTo(target.pos) < 500 and Ready(_W) then
					Control.CastSpell(HK_W, target.pos)	
				end				
			end			
		end
	end	
end		

function Harass()
local target = GetTarget(700)     	
if target == nil then return end
	if IsValid(target) then
				
		if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 500 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			if Menu.Harass.Passive:Value() then
				if not HasBuff(myHero, "AkaliPWeapon") then
					Control.CastSpell(HK_Q, target.pos)
				end	
			else
				Control.CastSpell(HK_Q, target.pos)
			end
		end

		if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Harass.UseE:Value() and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliE" then
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
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 55, Range = 650, Speed = 1800, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end				
			end
		end				
	end	
end

function Push()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_ENEMY and IsValid(minion) and Menu.Clear.UseQ:Value() then
			if mana_ok and Ready(_Q) then	
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end
end

function LastHit()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_ENEMY and IsValid(minion) and Menu.Clear.UseQ:Value() then
			if mana_ok and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero)
			local Q2Dmg = (QDmg / 100) * 25
			local FullDmg = QDmg + Q2Dmg
				if myHero:GetSpellData(_Q).level <= 4 then
					if QDmg >= minion.health then
						Control.CastSpell(HK_Q, minion.pos)
					end
				else
					if FullDmg >= minion.health then
						Control.CastSpell(HK_Q, minion.pos)
					end
				end	
			end
		end
	end
end

function JungleClear()	
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_JUNGLE and IsValid(minion) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            if Menu.JClear.UseQ:Value() and mana_ok and Ready(_Q) then  
				Control.CastSpell(HK_Q, minion.pos)
            end
        end
    end
end

function KillSteal()
	for i, target in ipairs(GetEnemyHeroes()) do
			
		if target and myHero.pos:DistanceTo(target.pos) < 2000 and IsValid(target) then
		
			local EDmg = getdmg("E", target, myHero)
			local E2Dmg = getdmg("E", target, myHero) * 2
			local QDmg = getdmg("Q", target, myHero)	
			
			if Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") and Menu.ks.UseE:Value() then
				if EDmg >= target.health then
					Control.CastSpell(HK_E)	
				end
				if Ready(_Q) and (EDmg + QDmg) >= target.health then
					Control.CastSpell(HK_E)	
				end	
			end		
			
			if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < 500 and Ready(_Q) and Menu.ks.UseQ:Value() then
				local QDmg = getdmg("Q", target, myHero)
				if QDmg >= target.health then
					Control.CastSpell(HK_Q, target.pos)
				end
				if Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") and (EDmg + QDmg) >= target.health then
					Control.CastSpell(HK_Q, target.pos)
				end	
			end
			
			if not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) <= 650 and Ready(_E) and Menu.ks.UseE:Value() and myHero:GetSpellData(_E).name == "AkaliE" then
				if E2Dmg >= target.health then
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
						local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 55, Range = 650, Speed = 1800, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
						EPrediction:GetPrediction(target, myHero)
						if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
							Control.CastSpell(HK_E, EPrediction.CastPosition)
						end				
					end		
				end
				
				if not myHero.pathing.isDashing and Ready(_Q) and (E2Dmg + QDmg) >= target.health then
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
						local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 55, Range = 650, Speed = 1800, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
						EPrediction:GetPrediction(target, myHero)
						if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
							Control.CastSpell(HK_E, EPrediction.CastPosition)
						end				
					end	
				end			
			end
		end
	end	
end


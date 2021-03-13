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

local function GetAllyCount(range, pos)
    local pos = pos.pos
    local count = 0
    for i, hero in ipairs(GetAllyHeroes()) do
    local Range = range * range
        if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
        count = count + 1
        end
    end
    return count
end

function RedRDmg(unit)
    local RedDmg = (0.1 + (0.13 * (myHero.bonusDamage / 100))) * unit.maxHealth
    return CalcPhysicalDamage(myHero, unit, RedDmg)
end

local function RedQDmg(unit)
    local Bonus = 0.04 * (myHero.bonusDamage / 100)
    local RedDmg = (0.55 * myHero.totalDamage) + ((0.05 + Bonus) * unit.maxHealth)
    return CalcPhysicalDamage(myHero, unit, RedDmg) 
end

local function isRedKayne()
	if myHero:GetSpellData(_W).range == 700 then
		return true
	end
	return false
end

local function isBlueKayne()
	if myHero:GetSpellData(_W).range == 900 then
		return true
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

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 20, min = 0, max = 100, identifier = "%"})

	--KillSteal Menu
	Menu:MenuElement({type = MENU, id = "Killsteal", name = "KillSteal"})
	Menu.Killsteal:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Killsteal:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Killsteal:MenuElement({id = "UseR", name = "[R]", value = true})
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "Qmin", name = "[Q] If Hit X Minion ", value = 3, min = 1, max = 6, step = 1, identifier = "Minion/s"})
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "Wmin", name = "[W] If Hit X Minion ", value = 3, min = 1, max = 6, step = 1, identifier = "Minion/s"})
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 30, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 30, min = 0, max = 100, identifier = "%"})
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[w]", value = 2, drop = {"Normal", "High", "Immobile"}})
	
	--Misc
	Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})
	Menu.Misc:MenuElement({id = "Evade", name = "[R] Self HP", value = 15, min = 0, max = 100, identifier = "%"})

	--Drawing
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw[Q]", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw[W]", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw[R]", value = false})
	
	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.55, Radius = 50, Range = 350, Speed = MathHuge, Collision = false
	}
	
	QspellData = {speed = MathHuge, range = 350, delay = 0.55, radius = 50, collision = {nil}, type = "circular"}	

	WDataDarkin =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.55, Radius = 45, Range = 700, Speed = MathHuge, Collision = false
	}
	
	WspellDataDarkin = {speed = MathHuge, range = 700, delay = 0.55, radius = 45, collision = {nil}, type = "linear"}	

	WDataSlayer =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0, Radius = 45, Range = 900, Speed = MathHuge, Collision = false
	}
	
	WspellDataSlayer = {speed = MathHuge, range = 900, delay = 0, radius = 45, collision = {nil}, type = "linear"}			
  	                                          
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			DrawCircle(myHero, 600, 1, DrawColor(225, 0, 225, 85))
		end
		
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			if isRedKayne() then
				DrawCircle(myHero, 700, 1, DrawColor(225, 225, 188, 0))
			else
				DrawCircle(myHero, 900, 1, DrawColor(225, 225, 188, 0))
			end
		end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			if isRedKayne() then
				DrawCircle(myHero, 550, 1, DrawColor(225, 225, 0, 10))
			else
				DrawCircle(myHero, 750, 1, DrawColor(225, 225, 0, 10))
			end
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
	end
	KillSteal()
	Evade()
end

function Evade()
	for i, target in ipairs(GetEnemyHeroes()) do
	if not Ready(_R) then return end
		local hp = myHero.health

		if myHero.pos:DistanceTo(target.pos) < 800 and IsValid(target) and HasBuff(target, "kaynrenemymark") and (myHero.health * 100 ) / myHero.maxHealth <= Menu.Misc.Evade:Value() then

			if isRedKayne() then
				
				if myHero.pos:DistanceTo(target.pos) < 525 then
					Control.CastSpell(HK_R, target)
				end

			elseif isBlueKayne() then
				
				if myHero.pos:DistanceTo(target.pos) < 725 then
					Control.CastSpell(HK_R, target)
				end
			end
		end
	end
end	

function Combo()
	local target = GetTarget(900)
	if target == nil then return end
	
	if IsValid(target) then
			
		if isRedKayne() then
			if myHero.pos:DistanceTo(target.pos) < 675 then
				if Menu.Combo.UseW:Value() and Ready(_W) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, WDataDarkin, myHero)
						if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
							Control.CastSpell(HK_W, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellDataDarkin)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
							Control.CastSpell(HK_W, pred.CastPos)
						end
					else
						local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.55, Radius = 45, Range = 700, Speed = MathHuge, Collision = false})
						WPrediction:GetPrediction(target, myHero)
						if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
							Control.CastSpell(HK_W, WPrediction.CastPosition)
						end	
					end
				end
			end

		elseif isBlueKayne() then
			
			if myHero.pos:DistanceTo(target.pos) < 875 then
				if Menu.Combo.UseW:Value() and Ready(_W) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, WDataSlayer, myHero)
						if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
							Control.CastSpell(HK_W, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellDataSlayer)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
							Control.CastSpell(HK_W, pred.CastPos)
						end
					else
						local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0, Radius = 45, Range = 900, Speed = MathHuge, Collision = false})
						WPrediction:GetPrediction(target, myHero)
						if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
							Control.CastSpell(HK_W, WPrediction.CastPosition)
						end	
					end
				end
			end
		end

		if myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.15, Radius = 50, Range = 600, Speed = MathHuge, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end
		end

		local hp = target.health
		local Acount = GetAllyCount(1500, myHero)

		if isRedKayne() then
			if Menu.Combo.UseR:Value() and myHero.pos:DistanceTo(target.pos) < 525 and Ready(_R) then
				local RDmg = getdmg("R", target, myHero)
				local RedUltDmg = RDmg + RedRDmg(target)
				--local AADmg = getdmg("AA", target, myHero)				
				if RedUltDmg >= hp and Acount <= 1 and HasBuff(target, "kaynrenemymark") then
					Control.CastSpell(HK_R, target)
				end
				if RedUltDmg >= hp and myHero:GetSpellData(_R).name ~= "KaynR" then
					Control.CastSpell(HK_R, target)
				end					
			end

		elseif isBlueKayne() then
			
			if Menu.Combo.UseR:Value() and myHero.pos:DistanceTo(target.pos) < 725 and Ready(_R) then
				local RDmg = getdmg("R", target, myHero)
				--local AADmg = getdmg("AA", target, myHero)				
				if RDmg >= hp and Acount <= 1 and HasBuff(target, "kaynrenemymark") then
					Control.CastSpell(HK_R, target)
				end 
				if RDmg >= hp and myHero:GetSpellData(_R).name ~= "KaynR" then
					Control.CastSpell(HK_R, target)
				end					
			end
		end
	end
end

function KillSteal()
	for i, target in ipairs(GetEnemyHeroes()) do

		if myHero.pos:DistanceTo(target.pos) < 900 and IsValid(target) then
			local hp = target.health
			local Acount = GetAllyCount(1500, myHero)

			if isRedKayne() then
			
				if Menu.Killsteal.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 675 and Ready(_W) then
					local WDmg = getdmg("W", target, myHero)
					if WDmg > hp then
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(target, WDataDarkin, myHero)
							if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
								Control.CastSpell(HK_W, pred.CastPosition)
							end
						elseif Menu.Pred.Change:Value() == 2 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellDataDarkin)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
								Control.CastSpell(HK_W, pred.CastPos)
							end
						else
							local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.55, Radius = 45, Range = 700, Speed = MathHuge, Collision = false})
							WPrediction:GetPrediction(target, myHero)
							if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
								Control.CastSpell(HK_W, WPrediction.CastPosition)
							end	
						end
					end
				end
				
				if Menu.Killsteal.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 350 and Ready(_Q) then
					local QDmg = getdmg("Q", target, myHero)
					local RedQDmg = QDmg*2 + RedQDmg(target)
					if RedQDmg > hp then
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(target, QData, myHero)
							if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						elseif Menu.Pred.Change:Value() == 2 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						else
							local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.15, Radius = 50, Range = 350, Speed = MathHuge, Collision = false})
							QPrediction:GetPrediction(target, myHero)
							if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end				
						end
					end
				end	
				
				if GetMode() ~= "Combo" then
					if Menu.Killsteal.UseR:Value() and myHero.pos:DistanceTo(target.pos) < 525 and Ready(_R) then
						local RDmg = getdmg("R", target, myHero)
						local RedUltDmg = RDmg + RedRDmg(target)				
						--local AADmg = getdmg("AA", target, myHero)				
						if RedUltDmg >= hp and Acount <= 1 and HasBuff(target, "kaynrenemymark") then
							Control.CastSpell(HK_R, target)
						end
						if RedUltDmg >= hp and myHero:GetSpellData(_R).name ~= "KaynR" then
							Control.CastSpell(HK_R, target)
						end						
					end
				end	

			elseif isBlueKayne() then
				
				if Menu.Killsteal.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 875 and Ready(_W) then
					local WDmg = getdmg("W", target, myHero)
					if WDmg > hp then
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(target, WDataSlayer, myHero)
							if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
								Control.CastSpell(HK_W, pred.CastPosition)
							end
						elseif Menu.Pred.Change:Value() == 2 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellDataSlayer)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
								Control.CastSpell(HK_W, pred.CastPos)
							end
						else
							local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0, Radius = 45, Range = 900, Speed = MathHuge, Collision = false})
							WPrediction:GetPrediction(target, myHero)
							if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
								Control.CastSpell(HK_W, WPrediction.CastPosition)
							end	
						end
					end
				end
				
				if Menu.Killsteal.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 350 and Ready(_Q) then
					local QDmg = getdmg("Q", target, myHero)
					if QDmg*2 > hp then
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(target, QData, myHero)
							if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						elseif Menu.Pred.Change:Value() == 2 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						else
							local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.15, Radius = 50, Range = 350, Speed = MathHuge, Collision = false})
							QPrediction:GetPrediction(target, myHero)
							if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end				
						end
					end
				end	

				if GetMode() ~= "Combo" then
					if Menu.Killsteal.UseR:Value() and myHero.pos:DistanceTo(target.pos) < 725 and Ready(_R) then
						local RDmg = getdmg("R", target, myHero)
						--local AADmg = getdmg("AA", target, myHero)								
						if RDmg >= hp and Acount <= 1 and HasBuff(target, "kaynrenemymark") then
							Control.CastSpell(HK_R, target)
						end
						if RDmg >= hp and myHero:GetSpellData(_R).name ~= "KaynR" then
							Control.CastSpell(HK_R, target)
						end						
					end	
				end	
			end
		end
	end	
end

function Harass()
	local target = GetTarget(900)
	if target == nil then return end

	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value()/100 then

		if isRedKayne() then
			
			if myHero.pos:DistanceTo(target.pos) < 675 then
				if Menu.Harass.UseW:Value() and Ready(_W) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, WDataDarkin, myHero)
						if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
							Control.CastSpell(HK_W, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellDataDarkin)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
							Control.CastSpell(HK_W, pred.CastPos)
						end
					else
						local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.55, Radius = 45, Range = 700, Speed = MathHuge, Collision = false})
						WPrediction:GetPrediction(target, myHero)
						if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
							Control.CastSpell(HK_W, WPrediction.CastPosition)
						end	
					end
				end
			end

		elseif isBlueKayne() then
			
			if myHero.pos:DistanceTo(target.pos) < 875 then
				if Menu.Harass.UseW:Value() and Ready(_W) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, WDataSlayer, myHero)
						if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
							Control.CastSpell(HK_W, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellDataSlayer)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
							Control.CastSpell(HK_W, pred.CastPos)
						end
					else
						local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0, Radius = 45, Range = 900, Speed = MathHuge, Collision = false})
						WPrediction:GetPrediction(target, myHero)
						if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
							Control.CastSpell(HK_W, WPrediction.CastPosition)
						end	
					end
				end
			end
		end

		if myHero.pos:DistanceTo(target.pos) < 500 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.15, Radius = 50, Range = 600, Speed = MathHuge, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end
		end
	end
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
			
			if isRedKayne() then
				if myHero.pos:DistanceTo(minion.pos) < 675 and Menu.Clear.UseW:Value() and Ready(_W) then
					local count = GetMinionCount(150, minion)
					if count >= Menu.Clear.Wmin:Value() then
						Control.CastSpell(HK_W, minion.pos)
					end
				end

			elseif isBlueKayne() then
				
				if myHero.pos:DistanceTo(minion.pos) < 875 and Menu.Clear.UseW:Value() and Ready(_W) then
					local count = GetMinionCount(150, minion)
					if count >= Menu.Clear.Wmin:Value() then
						Control.CastSpell(HK_W, minion.pos)
					end
				end
			end

			if myHero.pos:DistanceTo(minion.pos) < 500 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				local count = GetMinionCount(200, minion)
				if count >= Menu.Clear.Qmin:Value() then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end		
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
			
			if isRedKayne() then
				
				if myHero.pos:DistanceTo(minion.pos) < 675 and Menu.Clear.UseW:Value() and Ready(_W) then
					--local count = GetMinionCount(150, minion)
					Control.CastSpell(HK_W, minion.pos)
				end

			elseif isBlueKayne() then
				
				if myHero.pos:DistanceTo(minion.pos) < 875 and Menu.Clear.UseW:Value() and Ready(_W) then
					--local count = GetMinionCount(150, minion)
					Control.CastSpell(HK_W, minion.pos)
				end
			end

			if myHero.pos:DistanceTo(minion.pos) <= 500 and Menu.JClear.UseQ:Value() and Ready(_Q) then
				--local count = GetMinionCount(200, minion)
				Control.CastSpell(HK_Q, minion.pos)
			end

		end
	end
end

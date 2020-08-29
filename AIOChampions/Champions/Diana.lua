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

local function GetEnemyCount(range, pos)
    local pos = pos.pos
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

local function GetR2Damage(unit)
	local level = myHero:GetSpellData(_R).level
	local bonus = (({35, 68, 85})[level] + 0.15 * myHero.ap)
	local count = GetEnemyCount(475, myHero)
	if count <= 1 then
		return 0
	else	
		local countDmg = ((count-1) * bonus)
		return CalcMagicalDamage(myHero, unit, countDmg)
	end	
end	

local function GetFullDmg(unit)
	local Qdmg = Ready(_Q) and getdmg("Q", unit, myHero) or 0
	local Wdmg = Ready(_W) and getdmg("W", unit, myHero) or 0
	local Edmg = Ready(_E) and getdmg("E", unit, myHero) or 0
	local Rdmg = Ready(_R) and getdmg("R", unit, myHero) or 0
	local R2dmg = Ready(_R) and GetR2Damage(unit) or 0
	local FullDmg = (Qdmg + Wdmg + Edmg + Rdmg + R2dmg)
	return FullDmg
end	
	
function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})
	
	--ComboMenu
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseEbuff", name = "only [E] if Target has QBuff", value = true})
	Menu.Combo:MenuElement({id = "GapE", name = "Gapclose[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R] if Target killable full Combo", value = true})
	Menu.Combo:MenuElement({name = " ", drop = {"------------------------"}})
	Menu.Combo:MenuElement({id = "UseR2", name = "Use[R] pull count", value = true})	
	Menu.Combo:MenuElement({id = "UseRCount", name = "[R] if can pull", value = 3, min = 1, max = 5, step = 1, identifier = "Enemy/s"})
	Menu.Combo:MenuElement({id = "UseRHP", name = "[R] if pull Enemys HP lower than", value = 50, min = 0, max = 100, identifier = "%"})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})	
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseQCount", name = "[Q] min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "UseWCount", name = "[W] min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Kill Cannon Minion if no Enemy near", value = true})
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})	
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})	
	
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQE", name = "[Q] + [E]", value = true})		
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance [Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	--Drawing
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q]", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W]", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R]", value = false})	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 900, Speed = 1300, Collision = false
	}
	
	QspellData = {speed = 1300, range = 900, delay = 0.25, radius = 100, collision = {nil}, type = "linear"}		

	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function() 
		if myHero.dead then return end
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 200, 1, DrawColor(225, 225, 0, 10))
		end	
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 825, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 475, 1, DrawColor(225, 225, 0, 10))
		end		
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		Ult()
		if Menu.Combo.GapE:Value() then
			Gapclose()
		end	
	elseif Mode == "Harass" then
		Harass()		
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end
	KillSteal()	
end

local function GetEnemyUltCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, GameHeroCount() do 
	local hero = GameHero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) and hero.health/hero.maxHealth <= Menu.Combo.UseRHP:Value() / 100 then
		count = count + 1
		end
	end
	return count
end

function Ult()
local target = GetTarget(500)
if target == nil then return end
	if IsValid(target) then
		
		if myHero.pos:DistanceTo(target.pos) < 475 and Menu.Combo.UseR2:Value() and Ready(_R) then
			local count = GetEnemyUltCount(475, myHero)
			if count >= Menu.Combo.UseRCount:Value() then
				Control.CastSpell(HK_R)
			end	
		end		
	end
end	

function Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
	
		if myHero.pos:DistanceTo(target.pos) < 475 and Menu.Combo.UseR:Value() and Ready(_R) then
			local ComboDmg = GetFullDmg(target)
			if ComboDmg > target.health then
				Control.CastSpell(HK_R)
			end	
		end		

		if myHero:GetSpellData(_W).level > 0 then
		
			if myHero.pos:DistanceTo(target.pos) <= 200 then
			
				if Menu.Combo.UseW:Value() and Ready(_W) then
					Control.CastSpell(HK_W)
				end			
				
				if Menu.Combo.UseQ:Value() and Ready(_Q) then
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
						local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 900, Speed = 1300, Collision = false})
						QPrediction:GetPrediction(target, myHero)
						if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end				
					end
				end 
				
				if Menu.Combo.UseEbuff:Value() then
					if myHero:GetSpellData(_Q).level > 0 then
				
						if Menu.Combo.UseE:Value() and Ready(_E) and HasBuff(target, "dianamoonlight") then
							Control.CastSpell(HK_E, target)
						end	

					else

						if Menu.Combo.UseE:Value() and Ready(_E) then
							Control.CastSpell(HK_E, target)
						end
					end	
				
				else
					
					if Menu.Combo.UseE:Value() and Ready(_E) then
						Control.CastSpell(HK_E, target)
					end
				end	
				
			else
			
				if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Combo.UseQ:Value() and Ready(_Q) then
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
						local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 900, Speed = 1300, Collision = false})
						QPrediction:GetPrediction(target, myHero)
						if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end				
					end
				end	

				if myHero.pos:DistanceTo(target.pos) <= 825 and Menu.Combo.UseE:Value() and Ready(_E) and HasBuff(target, "dianamoonlight") then
					Control.CastSpell(HK_E, target)
				end	

				if myHero.pos:DistanceTo(target.pos) <= 200 and Menu.Combo.UseW:Value() and Ready(_W) then
					Control.CastSpell(HK_W)
				end				
			end	
				
		else
		
			if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Combo.UseQ:Value() and Ready(_Q) then
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
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 900, Speed = 1300, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end
			end
					
			if Menu.Combo.UseEbuff:Value() then
				if myHero:GetSpellData(_Q).level > 0 then
			
					if myHero.pos:DistanceTo(target.pos) <= 825 and Menu.Combo.UseE:Value() and Ready(_E) and HasBuff(target, "dianamoonlight") then
						Control.CastSpell(HK_E, target)
					end	

				else

					if myHero.pos:DistanceTo(target.pos) <= 825 and Menu.Combo.UseE:Value() and Ready(_E) then
						Control.CastSpell(HK_E, target)
					end
				end	
			
			else
				
				if myHero.pos:DistanceTo(target.pos) <= 825 and Menu.Combo.UseE:Value() and Ready(_E) then
					Control.CastSpell(HK_E, target)
				end
			end				
		end	
	end
end

function Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) < 900 and Menu.Harass.UseQ:Value() and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 900, Speed = 1300, Collision = false})
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
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
			if myHero.pos:DistanceTo(minion.pos) <= 900 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				local Qcount = GetMinionCount(400, minion)
				if Qcount >= Menu.Clear.UseQCount:Value() then
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 300 and Menu.Clear.UseW:Value() and Ready(_W) then
				local Wcount = GetMinionCount(300, myHero)
				if Wcount >= Menu.Clear.UseWCount:Value() then
					Control.CastSpell(HK_W)
				end	
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 825 and Menu.Clear.UseE:Value() and Ready(_E) then
				local Ecount = GetEnemyCount(825, myHero)
				local EDmg = getdmg("E", minion, myHero)
				if minion.charName == "SRU_ChaosMinionSiege" and Ecount == 0 and EDmg > minion.health then
					Control.CastSpell(HK_E, minion)
				end	
			end			
		end
	end
end

function Gapclose()
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target) then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)	
			if myHero.pos:DistanceTo(minion.pos) < 825 and (minion.team == TEAM_JUNGLE or minion.team == TEAM_ENEMY) and IsValid(minion) then
				if myHero.pos:DistanceTo(target.pos) > myHero.pos:DistanceTo(minion.pos) and target.pos:DistanceTo(minion.pos) < 500 and Ready(_E) and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)
				end
				
				if Ready(_E) and HasBuff(minion, "dianamoonlight") and myHero.pos:DistanceTo(target.pos) > myHero.pos:DistanceTo(minion.pos) then
					Control.CastSpell(HK_E, minion)
				end	
			end	
		end	
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
			
			if myHero.pos:DistanceTo(minion.pos) <= 900 and Menu.JClear.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 300 and Menu.JClear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W)	
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 825 and Menu.JClear.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E, minion)
			end			
		end
	end
end

function KillSteal()	
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
		local QDmg = getdmg("Q", target, myHero) 
		local EDmg = getdmg("E", target, myHero)

		if myHero.pos:DistanceTo(target.pos) < 825 and Menu.ks.UseQE:Value() and Ready(_Q) and Ready(_E) then
			if (QDmg+EDmg) > target.health then 
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
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 900, Speed = 1300, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) < 900 and Menu.ks.UseQ:Value() and Ready(_Q) then
			if QDmg > target.health then 
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
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 900, Speed = 1300, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end
			end
		end	
		
		if myHero.pos:DistanceTo(target.pos) <= 825 and Menu.ks.UseE:Value() and Ready(_E) and EDmg > target.health then
			Control.CastSpell(HK_E, target)
		end	
	end	
end	

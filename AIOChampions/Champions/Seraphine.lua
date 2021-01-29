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

local function GetAllHeroes()
	local _Heroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit ~= myHero then
			TableInsert(_Heroes, unit)
		end
	end
	return _Heroes
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

local function CheckMissHealth(unit)
	 local MissHealth = unit.maxHealth - unit.health
	 local PercentMissHealth = MissHealth / unit.maxHealth
	 
	 if PercentMissHealth < 0.075 then
		return 0	 
	 elseif PercentMissHealth >= 0.075 and PercentMissHealth < 0.15 then
		return 0.05
	 elseif PercentMissHealth >= 0.15 and PercentMissHealth < 0.225 then
		return 0.1
	 elseif PercentMissHealth >= 0.225 and PercentMissHealth < 0.3 then
		return 0.15		
	 elseif PercentMissHealth >= 0.3 and PercentMissHealth < 0.375 then
		return 0.2
	 elseif PercentMissHealth >= 0.375 and PercentMissHealth < 0.45 then
		return 0.25
	 elseif PercentMissHealth >= 0.45 and PercentMissHealth < 0.525 then
		return 0.3
	 elseif PercentMissHealth >= 0.525 and PercentMissHealth < 0.6 then
		return 0.35
	 elseif PercentMissHealth >= 0.6 and PercentMissHealth < 0.675 then
		return 0.4
	 elseif PercentMissHealth >= 0.675 and PercentMissHealth < 0.75 then
		return 0.45
	 elseif PercentMissHealth >= 0.75 then
		return 0.5
	end	
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})	

	--AutoE  
	Menu:MenuElement({type = MENU, id = "AutoE", name = "E Settings"})
	Menu.AutoE:MenuElement({id = "UseE", name = "[E] cast only on Immobile Traget", value = false})
	Menu.AutoE:MenuElement({id = "Change", name = "Combo/Harass or everytime ?", value = 1, drop = {"Combo/Harass", "Everytime"}})

	--Passive  
	Menu:MenuElement({type = MENU, id = "Pass", name = "Passive Settings"})
	Menu.Pass:MenuElement({name = " ", drop = {"Only active if [E] Settings Off"}})	
	Menu.Pass:MenuElement({name = " ", drop = {"[W] is everytime first Priority if need Heal"}})	
	Menu.Pass:MenuElement({id = "ChangeCombo", name = "Priority Echo Spell sequence Combo", value = 2, drop = {"[Q] > [E]", "[E] > [Q]", "No priority"}})	
	Menu.Pass:MenuElement({id = "Wait", name = "Wait for Prio Spell / if Cd lower than", value = 1, min = 0, max = 5, step = 0.1, identifier = "sec"})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "self", name = "[W] if own Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})
	Menu.Combo:MenuElement({id = "ally", name = "[W] if Ally Hp lower than -->", value = 35, min = 0, max = 100, identifier = "%"})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({id = "Active", name = "[R] Semi Key", key = string.byte("T")})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "self", name = "[W] if own Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})
	Menu.Harass:MenuElement({id = "ally", name = "[W] if Ally Hp lower than -->", value = 35, min = 0, max = 100, identifier = "%"})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
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
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})		

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	
	
	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 350, Range = 900, Speed = 1200, Collision = false
	}
	
	QspellData = {speed = 1200, range = 900, delay = 0.25, radius = 350, collision = {nil}, type = "circular"}		

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1200, Speed = 1200, Collision = false
	}
	
	EspellData = {speed = 1200, range = 1200, delay = 0.25, radius = 70, collision = {nil}, type = "linear"}	
			

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			local range, target = RRange()
			if target then
				DrawCircle(myHero, range, 1, DrawColor(255, 225, 255, 10))
			else
				DrawCircle(myHero, 1200, 1, DrawColor(255, 225, 255, 10))
			end	
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

local CanCastE = false
local CanCastUlt = false
function Tick()	
	if CanCastUlt and not Ready(_R) then
		CanCastUlt = false
	end
	if CanCastE and not Ready(_E) then
		CanCastE = false
	end	

	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Ult()
		Combo()	
		if Menu.AutoE.Change:Value() == 1 and Menu.AutoE.UseE:Value() then
			Eimmo()
		end
	elseif Mode == "Harass" then
		Harass()
		if Menu.AutoE.Change:Value() == 1 and Menu.AutoE.UseE:Value() then
			Eimmo()
		end		
	elseif Mode == "Clear" then
		Clear()
		JungleClear()		
	end
	
	if Menu.AutoE.Change:Value() == 2 and Menu.AutoE.UseE:Value() then 
		Eimmo()
	end	
	
	if Menu.Combo.Active:Value() then 
		Ult2()
	end	
	
	KillSteal()	
end

function Eimmo()
	if CanCastUlt then return end
	for i, target in ipairs(GetEnemyHeroes()) do
		if target and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 1200 and IsValid(target) then	
			if IsImmobileTarget(target) then
				CastE(target)
			end
		end 
	end
end
        
function KillSteal()	
	if CanCastUlt then return end
	for i, target in ipairs(GetEnemyHeroes()) do

		if Menu.ks.UseQ:Value() and Ready(_Q) and Menu.ks.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 900 and IsValid(target) then
			--local QDmg = CalcQDmg(target)
			--local EDmg = CalcEDmg(target)
			local MissHealth = CheckMissHealth(target)
			local QDmg = getdmg("Q", target, myHero) + (MissHealth*getdmg("Q", target, myHero))
			local EDmg = HasBuff(myHero, "SeraphinePassiveEchoStage2") and getdmg("E", target, myHero)*2 or getdmg("E", target, myHero)	
			if (QDmg+EDmg) > (target.health - target.hpRegen*2) then 
				CastE(target)
			end
		end	
		
		if Menu.ks.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 1200 and IsValid(target) then
			--local EDmg = CalcEDmg(target)			
			local EDmg = HasBuff(myHero, "SeraphinePassiveEchoStage2") and getdmg("E", target, myHero)*2 or getdmg("E", target, myHero) 
			if EDmg > target.health then			
				CastE(target)
			end
		end		
		
		if Menu.ks.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 900 and IsValid(target) then
			--local QDmg = CalcQDmg(target)			
			local MissHealth = CheckMissHealth(target)
			local QDmg = HasBuff(myHero, "SeraphinePassiveEchoStage2") and (getdmg("Q", target, myHero)*2) + ((MissHealth*getdmg("Q", target, myHero))*2) or getdmg("Q", target, myHero) + (MissHealth*getdmg("Q", target, myHero))
			if QDmg > target.health then 
				CastQ(target)
			end
		end
	end	
end
	
function Ult()	
	if Menu.Combo.UseR:Value() and Ready(_R) then	
		local target = GetTarget(1100)
		if target == nil then return end
		if IsValid(target) then
			if Menu.Pred.Change:Value() == 1 then
				local RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 160, Range = 1200, Speed = 1600, Collision = false}
				local pred = GetGamsteronPrediction(target, RData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					Control.CastSpell(HK_R, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local RspellData = {speed = 1600, range = 1200, delay = 0.5, radius = 160, collision = {nil}, type = "linear"}
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					Control.CastSpell(HK_R, pred.CastPos)
				end
			else
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.5, Radius = 160, Range = 1200, Speed = 1600, Collision = false})
				RPrediction:GetPrediction(target, myHero)
				if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
					Control.CastSpell(HK_R, RPrediction.CastPosition)
				end				
			end						
		end
	end	
end	

function Ult2()	
	if Ready(_R) then	
		local target = GetTarget(1100)
		if target == nil then return end
		if IsValid(target) then
			if Menu.Pred.Change:Value() == 1 then
				local RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 160, Range = 1200, Speed = 1600, Collision = false}
				local pred = GetGamsteronPrediction(target, RData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					Control.CastSpell(HK_R, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local RspellData = {speed = 1600, range = 1200, delay = 0.5, radius = 160, collision = {nil}, type = "linear"}
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					Control.CastSpell(HK_R, pred.CastPos)
				end
			else
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.5, Radius = 160, Range = 1200, Speed = 1600, Collision = false})
				RPrediction:GetPrediction(target, myHero)
				if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
					Control.CastSpell(HK_R, RPrediction.CastPosition)
				end				
			end						
		end
	end	
end	

local function ReadyForPassive(spell)
    return myHero:GetSpellData(spell).currentCd <= Menu.Pass.Wait:Value() and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end
		
function Combo()
	if CanCastUlt then return end
	local Qtarget = GetTarget(900)
	local Etarget = GetTarget(1200)
	
	if HasBuff(myHero, "SeraphinePassiveEchoStage2") and Menu.Pass.ChangeCombo:Value() == 1 and not Menu.AutoE.UseE:Value() then

		if Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= Menu.Combo.self:Value() / 100 then
				Control.CastSpell(HK_W)
				return
			else
				for i, Ally in ipairs(GetAllyHeroes()) do
					if Ally and myHero.pos:DistanceTo(Ally.pos) < 800 and IsValid(Ally) then
						if Ally.health/Ally.maxHealth <= Menu.Combo.ally:Value() / 100 then
							Control.CastSpell(HK_W)	
							return
						end	
					end
				end
			end
		end
			
		if Menu.Combo.UseQ:Value() and ReadyForPassive(_Q) then
			if Qtarget and IsValid(Qtarget) and Ready(_Q) then
				CastQ(Qtarget)
			end	
		
		else
			if Etarget and IsValid(Etarget) and Menu.Combo.UseE:Value() and Ready(_E) then	
				CastE(Etarget)
			end 
		end

	elseif HasBuff(myHero, "SeraphinePassiveEchoStage2") and Menu.Pass.ChangeCombo:Value() == 2 and not Menu.AutoE.UseE:Value() then

		if Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= Menu.Combo.self:Value() / 100 then
				Control.CastSpell(HK_W)
				return
			else
				for i, Ally in ipairs(GetAllyHeroes()) do
					if Ally and myHero.pos:DistanceTo(Ally.pos) < 800 and IsValid(Ally) then
						if Ally.health/Ally.maxHealth <= Menu.Combo.ally:Value() / 100 then
							Control.CastSpell(HK_W)	
							return
						end	
					end
				end
			end
		end
				
		if Etarget and IsValid(Etarget) and Menu.Combo.UseE:Value() and ReadyForPassive(_E) then	
			if Ready(_E) then
				CastE(Etarget)
			end					
		
		else
			if Qtarget and IsValid(Qtarget) and Menu.Combo.UseQ:Value() and Ready(_Q) then
				CastQ(Qtarget)
			end	
		end	
				
	else
		
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

		if Etarget and IsValid(Etarget) and Menu.Combo.UseE:Value() and Ready(_E) and not Menu.AutoE.UseE:Value() then	
			CastE(Etarget)
		end 	
		
		if Qtarget and IsValid(Qtarget) and Menu.Combo.UseQ:Value() and Ready(_Q) then
			CastQ(Qtarget)
		end	
	end	
end	

function Harass()
	if myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		if HasBuff(myHero, "SeraphinePassiveEchoStage2") then
			
			if Menu.Harass.UseW:Value() and Ready(_W) then
				if myHero.health/myHero.maxHealth <= Menu.Harass.self:Value() / 100 then
					Control.CastSpell(HK_W)
					return
				else
					for i, Ally in ipairs(GetAllyHeroes()) do
						if Ally and myHero.pos:DistanceTo(Ally.pos) < 800 and IsValid(Ally) then
							if Ally.health/Ally.maxHealth <= Menu.Harass.ally:Value() / 100 then
								Control.CastSpell(HK_W)
								return
							end	
						end
					end
				end
			end		
				
			local target = GetTarget(1300)
			if target == nil then return end
			if IsValid(target) then	
				if Menu.Harass.UseE:Value() and Ready(_E) and not Menu.AutoE.UseE:Value() then	
					CastE(target)						
				else	
				
					if Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 900 then
						CastQ(target)
					end
				end	
			end						

		else		
		
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

			local target = GetTarget(1200)
			if target == nil then return end
			if IsValid(target) then	
				
				if Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 900 then
					CastQ(target)
				end	
				
				if Menu.Harass.UseE:Value() and Ready(_E) and not Menu.AutoE.UseE:Value() then	
					CastE(target)
				end				
			end	
		end	
	end
end	

function Clear()
	if Ready(_Q) and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then	
		local minions, count = GetMinionsAround(myHero.pos, 900)
		if count > 0 then
			local BestPos, MostHit = GetCircularAOEPos(minions, 175, Menu.Clear.Count:Value())
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
	if CanCastE then return end
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
			CanCastE = true
			Control.CastSpell(HK_E, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
			CanCastE = true
			Control.CastSpell(HK_E, pred.CastPos)
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1200, Speed = 1200, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			CanCastE = true
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end					
	end
end

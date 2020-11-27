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

local function EnemyInRange(pos, range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(pos.pos) <= range and IsValid(target) then 
			count = count + 1
		end
	end
	return count
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
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})
	
	Menu:MenuElement({type = MENU, id = "Flee", name = "Flee Mode"})
	Menu.Flee:MenuElement({id = "Use", name = "Use [W] for Flee", value = true})	
	Menu.Flee:MenuElement({name = " ", drop = {"Orbwalker default Key = [A]"}})

	--AutoW
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW Mode"})
	Menu.AutoW:MenuElement({id = "self", name = "Heal self", value = true})
	Menu.AutoW:MenuElement({id = "ally", name = "Heal Ally", value = true})
	Menu.AutoW:MenuElement({id = "HP", name = "HP Self/Ally", value = 50, min = 0, max = 100, step = 1, identifier = "%"})
	Menu.AutoW:MenuElement({id = "Mana", name = "min. Mana", value = 50, min = 0, max = 100, step = 1, identifier = "%"})
	Menu.AutoW:MenuElement({id = "Targets", name = "Ally white list", type = MENU})
	DelayAction(function()
		for i, Hero in ipairs(GetAllyHeroes()) do
			Menu.AutoW.Targets:MenuElement({id = Hero.charName, name = "Use on "..Hero.charName, value = true})		
		end	
	end,0.2)	

	--AutoR
	Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoR Mode"})
	Menu.AutoR:MenuElement({id = "range", name = "Only cast if Enemy range lower than -->", value = 700, min = 0, max = 1500, step = 10, identifier = "range"})	
	Menu.AutoR:MenuElement({id = "self", name = "Ult self", value = true})
	Menu.AutoR:MenuElement({id = "ally", name = "Ult Ally", value = true})
	Menu.AutoR:MenuElement({id = "HP", name = "HP Self/Ally", value = 40, min = 0, max = 100, step = 1, identifier = "%"})
	Menu.AutoR:MenuElement({id = "Targets", name = "Ally white list", type = MENU})
	DelayAction(function()
		for i, Hero in ipairs(GetAllyHeroes()) do
			Menu.AutoR.Targets:MenuElement({id = Hero.charName, name = "Use on "..Hero.charName, value = true})		
		end	
	end,0.2)	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})			
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Mode"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana [Q]", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear Mode"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseQ2", name = "Only [Q] if killable", value = true})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseE2", name = "[E] only Lasthit", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana [Q]", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana [Q]", value = 40, min = 0, max = 100, identifier = "%"})  		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 30, Range = 900, Speed = 1600, Collision = false
	}
	
	QspellData = {speed = 1600, range = 900, delay = 0.25, radius = 30, collision = {nil}, type = "linear"}	
			
  	                                          
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			DrawCircle(myHero, 900, 1, DrawColor(225, 0, 225, 85))
		end
		
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			DrawCircle(myHero, 900, 1, DrawColor(225, 225, 188, 0))
		end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			DrawCircle(myHero, 900, 1, DrawColor(225, 225, 0, 10))
		end		
	end)

		
end

local ActiveUlt = false
function Tick()
	
	local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid and myHero.isChanneling and currSpell.name == "KayleR" then
		ActiveUlt = true
		SetAttack(false)
	else
		ActiveUlt = false
		SetAttack(true)
	end

if MyHeroNotReady() or ActiveUlt then return end
	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "Flee" then
		if Menu.Flee.Use:Value() then
			Flee()
		end	
	end
	AutoR()
	AutoW()
end

function AAReset(unit)
	if Control.CastSpell(HK_E, unit) then
		if _G.SDK and _G.SDK.Orbwalker then
			_G.SDK.Orbwalker:__OnAutoAttackReset()
		elseif _G.PremiumOrbwalker then
			_G.PremiumOrbwalker:ResetAutoAttack()
		end		
	end
end

function Flee()
	if Ready(_W) then
		Control.CastSpell(HK_W)	
	end
end

function AutoW()
	local target = GetTarget(1200)     	
	if target == nil then return end	
	
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.AutoW.Mana:Value() / 100 then
		
		if Menu.AutoW.self:Value() and Ready(_W) and myHero.health/myHero.maxHealth <= Menu.AutoW.HP:Value()/100 then
			Control.CastSpell(HK_W, myHero)			
		end
		
		if Menu.AutoW.ally:Value() and Ready(_W) then		
			for i, Ally in ipairs(GetAllyHeroes()) do
				if Ally and myHero.pos:DistanceTo(Ally.pos) < 900 and IsValid(Ally) then
					if Ally.health/Ally.maxHealth <= Menu.AutoW.HP:Value()/100 and Menu.AutoW.Targets[Ally.charName] and Menu.AutoW.Targets[Ally.charName]:Value() then
						Control.CastSpell(HK_W, Ally)	
					end	
				end
			end
		end
	end	
end

function AutoR()
	if EnemyInRange(myHero, Menu.AutoR.range:Value()) >= 1 then
		if Ready(_R) and Menu.AutoR.self:Value() then
			if myHero.health/myHero.maxHealth <= Menu.AutoR.HP:Value()/100 then	
				Control.CastSpell(HK_R, myHero)
			end
		end
		
		if Ready(_R) and Menu.AutoR.ally:Value() then
			for i, Ally in ipairs(GetAllyHeroes()) do
				if Ally and myHero.pos:DistanceTo(Ally.pos) < 900 and IsValid(Ally) then
				local enemy = EnemyInRange(Ally, Menu.AutoR.range:Value())			
					if enemy >= 1 and Ally.health/Ally.maxHealth <= Menu.AutoR.HP:Value()/100 and Menu.AutoR.Targets[Ally.charName] and Menu.AutoR.Targets[Ally.charName]:Value() then
						Control.CastSpell(HK_R, Ally)
					end
				end
			end	
		end
	end	
end		

function Combo()
	local target = GetTarget(900)
	if target == nil then return end
	
	if IsValid(target) then
					
		if myHero.pos:DistanceTo(target.pos) <= 525 and Menu.Combo.UseE:Value() and Ready(_E) then					
			AAReset(target)
			return
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and Menu.Combo.UseQ:Value() and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 30, Range = 900, Speed = 1600, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end
			end
		end
	end	
end	

function Harass()
	local target = GetTarget(900)
	if target == nil then return end
	
	if IsValid(target) then

		if myHero.pos:DistanceTo(target.pos) <= 525 and Menu.Harass.UseE:Value() and Ready(_E) then					
			AAReset(target)
			return
		end		
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 30, Range = 900, Speed = 1600, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end
			end
		end
	end
end	

local function CalcEDmg(unit)
	local eLvl = myHero:GetSpellData(_E).level
	local Dmg = ({ 15, 20, 25, 30, 35 })[eLvl] + 0.1*myHero.bonusDamage + 0.25*myHero.ap
	local EDmg = CalcMagicalDamage(myHero, unit, Dmg)
	return getdmg("E", unit, myHero) + EDmg
end

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_ENEMY and IsValid(minion) then					
			
			if Ready(_Q) and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				if Menu.Clear.UseQ2:Value() then
					local QDmg = getdmg("Q", minion, myHero)
					if minion.health < QDmg then
						Control.CastSpell(HK_Q, minion.pos)
					end	
				else
					Control.CastSpell(HK_Q, minion.pos)	
				end	
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 525 and Menu.Clear.UseE:Value() and Ready(_E) then					
				if Menu.Clear.UseE2:Value() then
					local Dmg = CalcEDmg(minion)
					if Dmg >= minion.health then
						AAReset(minion)	
					end
				else
					AAReset(minion)
				end
			end				
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_JUNGLE and IsValid(minion) then					
			
			if Ready(_Q) and Menu.JClear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
				Control.CastSpell(HK_Q, minion.pos)	
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 525 and Menu.JClear.UseE:Value() and Ready(_E) then					
				AAReset(minion)	
			end			
		end
	end    
end

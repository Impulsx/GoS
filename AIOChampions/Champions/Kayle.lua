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
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})
	
	Menu:MenuElement({type = MENU, id = "Flee", name = "Flee Mode"})
	Menu.Flee:MenuElement({id = "Use", name = "Use [W] for Flee", value = true})	
	Menu.Flee:MenuElement({id = "enable", name = "Flee Key", key = string.byte("G")})

	--AutoW
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW Mode"})
	Menu.AutoW:MenuElement({id = "self", name = "Heal self", value = true})
	Menu.AutoW:MenuElement({id = "ally", name = "Heal Ally", value = true})
	Menu.AutoW:MenuElement({id = "HP", name = "HP Self/Ally", value = 50, min = 0, max = 100, step = 1, identifier = "%"})
	Menu.AutoW:MenuElement({id = "Mana", name = "min. Mana", value = 50, min = 0, max = 100, step = 1, identifier = "%"})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})			
	Menu.Combo:MenuElement({type = MENU, id = "UseR", name = "Ult Settings"})
	Menu.Combo.UseR:MenuElement({id = "self", name = "Ult self", value = true})
	Menu.Combo.UseR:MenuElement({id = "ally", name = "Ult Ally", value = true})
	Menu.Combo.UseR:MenuElement({id = "HP", name = "HP Self/Ally", value = 40, min = 0, max = 100, step = 1, identifier = "%"})	
	
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
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 900, Speed = 1600, Collision = false
	}
	
	QspellData = {speed = 1600, range = 900, delay = 0.25, radius = 60, collision = {nil}, type = "linear"}	
			
  	                                          
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
	elseif Mode == "Flee" then
		if Menu.Flee.Use:Value() and Menu.Flee.enable:Value() then
			Flee()
		end	
	end

	AutoW()
end

function AAReset()

end

function Flee()
	if Ready(_W) then
		Control.CastSpell(HK_W)	
	end
end

function AutoW()
	local target = GetTarget(1200)     	
	if target == nil then return end		
	
	if IsValid(target) and myHero.mana/myHero.maxMana >= self.Menu.AutoW.Mana:Value() / 100 then
		
		if self.Menu.AutoW.self:Value() and Ready(_W) and myHero.health/myHero.maxHealth <= self.Menu.AutoW.HP:Value()/100 then
			Control.CastSpell(HK_W, myHero)			
		end
		
		if self.Menu.AutoW.ally:Value() and Ready(_W) then		
			for i, Ally in ipairs(GetAllyHeroes()) do
				if Ally and myHero.pos:DistanceTo(Ally.pos) < 900 and IsValid(Ally) then
					if Ally.health/Ally.maxHealth <= self.Menu.AutoW.HP:Value()/100 then
						Control.CastSpell(HK_W, Ally)	
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
					
		if myHero.pos:DistanceTo(target.pos) <= 850 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 900, Speed = 1600, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= myHero.range and self.Menu.Combo.UseE:Value() and Ready(_E) then					
			Control.CastSpell(HK_E)	
		end
		
		if Ready(_R) and self.Menu.Combo.UseR.self:Value() then
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.UseR.HP:Value()/100 then	
				Control.CastSpell(HK_R, myHero)
			end
		end
		
		if Ready(_R) and self.Menu.Combo.UseR.ally:Value() then
			for i, Ally in ipairs(GetAllyHeroes()) do
				if Ally and myHero.pos:DistanceTo(Ally.pos) < 900 and IsValid(Ally) then
				local enemy = EnemyInRange(Ally, 650)			
					if enemy >= 1 and Ally.health/Ally.maxHealth <= self.Menu.Combo.UseR.HP:Value()/100 then
						Control.CastSpell(HK_R, Ally)
					end
				end
			end	
		end
	end	
end	

function Harass()
	local target = GetTarget(900)
	if target == nil then return end
	
	if IsValid(target) then
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and self.Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 900, Speed = 1600, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= myHero.range and self.Menu.Harass.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E)			
		end
	end
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

			if myHero.pos:DistanceTo(minion.pos) <= myHero.range and self.Menu.Clear.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E)			
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

			if myHero.pos:DistanceTo(minion.pos) <= myHero.range and self.Menu.JClear.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E)			
			end			
		end
	end    
end
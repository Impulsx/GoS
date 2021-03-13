
local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
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

function LoadScript()	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "ERange", name = "Max [E] range", value = 850, min = 0, max = 900})	
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo.Ult:MenuElement({id = "UseRE", name = "[R] TargetCount", value = 2, min = 1, max = 5})
	Menu.Combo.Ult:MenuElement({id = "UseRE2", name = "[Count] Spirit + TargetCount", value = true})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Harass:MenuElement({id = "ERange", name = "Max [E] range", value = 850, min = 0, max = 900})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] original Range ", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = (0.75+ping), Radius = 100, Range = 825, Speed = MathHuge, Collision = false
	}
	
	QspellData = {speed = MathHuge, range = 825, delay = (0.75+ping), radius = 100, collision = {nil}, type = "linear"}	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 50, Range = 900, Speed = 1900, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	EspellData = {speed = 1900, range = 900, delay = (0.25+ping), radius = 50, collision = {"minion"}, type = "linear"}		
  	                                           
											   
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 450, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 825, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

local FoundSpirit = false
local Spirit = nil

function Tick()
	if FoundSpirit then
		RemoveSpirit()
	end	

	local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid and myHero.isChanneling and currSpell.name == "IllaoiE" then
		ScanSpirit()
	end

	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()			
	end	
end

function ScanSpirit()
	if FoundSpirit then return end
	DelayAction(function()
		for i = 0, GameObjectCount() do
			local obj = GameObject(i)
			if obj and myHero.pos:DistanceTo(obj.pos) < 600 and obj.name == "Illaoi_Base_E_Spirit" then								
				--print("FoundSpirit")
				FoundSpirit = true
				Spirit = obj
			end
		end
	end,0.5)	
end

function RemoveSpirit()
	local Obj = Spirit
	if not Obj.visible or not Obj.pos2D.onScreen or Obj.name ~= "Illaoi_Base_E_Spirit" then
		Spirit = nil
		FoundSpirit = false
		--print("Removed")								
	--else	
		--DrawCircle(Obj.pos, 100, 1, DrawColor(255, 225, 255, 10)) 
	end	
end

function Combo()		
	local target = GetTarget(900)
	if target == nil then return end
	if IsValid(target) then
	
		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= Menu.Combo.ERange:Value() and Ready(_E) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					Control.CastSpell(HK_E, pred.CastPosition)
					return
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					Control.CastSpell(HK_E, pred.CastPos)
					return
				end
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 50, Range = 900, Speed = 1900, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
					return
				end
			end
		end

		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 400 and Ready(_W) then
			Control.CastSpell(HK_W)
			Control.Attack(target)
		end			
		
		if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 800 and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.75+ping), Radius = 100, Range = 825, Speed = MathHuge, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end
			end
		end

		if Menu.Combo.Ult.UseR:Value() and Ready(_R) then
			local Obj = Spirit
			local count = GetEnemyCount(450, myHero)
			if Menu.Combo.Ult.UseRE2:Value() and Obj then
				if myHero.pos:DistanceTo(Obj.pos) < 450 then
					if count+1 >= Menu.Combo.Ult.UseRE:Value() then
						Control.CastSpell(HK_R)
					end	
				else
					if count >= Menu.Combo.Ult.UseRE:Value() then
						Control.CastSpell(HK_R)
					end	
				end
			else
				if count >= Menu.Combo.Ult.UseRE:Value() then
					Control.CastSpell(HK_R)
				end						
			end	
		end
	end	
end

function Harass()
	local target = GetTarget(900)
	if target == nil then return end
	if IsValid(target) then
	
		if Menu.Harass.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= Menu.Harass.ERange:Value() and Ready(_E) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					Control.CastSpell(HK_E, pred.CastPosition)
					return
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					Control.CastSpell(HK_E, pred.CastPos)
					return
				end
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 50, Range = 900, Speed = 1900, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
					return
				end
			end
		end

		if Menu.Harass.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 400 and Ready(_W) then
			Control.CastSpell(HK_W)
			Control.Attack(target)	
		end			
		
		if Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 800 and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.75+ping), Radius = 100, Range = 825, Speed = MathHuge, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end
			end
		end
	end	
end	

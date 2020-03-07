local function GetEnemyHeroes()
	return Enemies
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

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})
	
	--ComboMenu
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "Grit", name = "Min Grit to Use [W]", value = 50, min = 0, max = 100, identifier = "%"})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({id = "HP", name = "Use [R] if Enemy HP lower then", value = 50, min = 0, max = 100, identifier = "%"})
	Menu.Combo:MenuElement({id = "Targets", name = "Ult Block List", type = MENU})
	DelayAction(function()
		for i, Hero in pairs(GetEnemyHeroes()) do
			Menu.Combo.Targets:MenuElement({id = Hero.charName, name = "Use [R] on ".. Hero.charName, value = true})		
		end	
	end, 0.01)
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "Wmin", name = "[W] If Hit X Minion ", value = 2, min = 1, max = 6, step = 1, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "Grit", name = "Min Grit to Use [W]", value = 0, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "Grit", name = "Min Grit to Use [W]", value = 0, min = 0, max = 100, identifier = "%"})
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance [W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	--Drawing
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W]", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R]", value = false})		
			

	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.52, Radius = 90, Range = 750, Speed = MathHuge, Collision = false
	}
	
	WspellData = {speed = MathHuge, range = 750, delay = 0.52, radius = 90, collision = {}, type = "linear"}		

  	                                           
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	elseif _G.PremiumOrbwalker then
		Orb = 5		
	end	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function() 
		if myHero.dead then return end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 750, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 490, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 400, 1, DrawColor(225, 225, 0, 10))
		end		
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end	
end

function Combo()
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then    
		
		if myHero.pos:DistanceTo(target.pos) < 400 and Menu.Combo.UseR:Value() and Ready(_R) and Menu.Combo.Targets[target.charName] and Menu.Combo.Targets[target.charName]:Value() then
			if target.health/target.maxHealth <= Menu.Combo.HP:Value() / 100 then
				ControlCastSpell(HK_R, target)
			end	
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 490 and Menu.Combo.UseE:Value() and Ready(_E) then
			ControlCastSpell(HK_E, target.pos)
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 800 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			ControlCastSpell(HK_Q)
		end

		if myHero.pos:DistanceTo(target.pos) < 750 and Menu.Combo.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= Menu.Combo.Grit:Value() / 100 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
					ControlCastSpell(HK_W, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
					ControlCastSpell(HK_W, pred.CastPos)
				end	
			end
		end	
	end
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 800 and minion.team == TEAM_ENEMY and IsValid(minion) then
			
			if myHero.pos:DistanceTo(minion.pos) <= 400 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				ControlCastSpell(HK_Q)
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 750 and Menu.Clear.UseW:Value() and Ready(_W) then
				local count = GetMinionCount(400, minion)
				if count >= Menu.Clear.Wmin:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Grit:Value() / 100 then			
					ControlCastSpell(HK_W, minion.pos)
				end	
			end			
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 800 and minion.team == TEAM_JUNGLE and IsValid(minion) then
			
			if myHero.pos:DistanceTo(minion.pos) <= 400 and Menu.JClear.UseQ:Value() and Ready(_Q) then
				ControlCastSpell(HK_Q)
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 750 and Menu.JClear.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= Menu.JClear.Grit:Value() / 100 then
				ControlCastSpell(HK_W, minion.pos)
			end			
		end
	end
end

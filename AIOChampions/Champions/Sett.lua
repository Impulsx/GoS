function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})
	
	--ComboMenu
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "Qmin", name = "[Q] If Hit X Minion ", value = 2, min = 1, max = 6, step = 1, identifier = "Minion/s"})
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	--Drawing
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw[W]", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw[E]", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw[R]", value = false})		
			

	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.75, Radius = 90, Range = 750, Speed = 1550, Collision = false
	}
	
	WspellData = {speed = 1550, range = 750, delay = 0.75, radius = 90, collision = {}, type = "linear"}		

  	                                           
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
		--Clear()
		--JungleClear()
	end	
end

function Combo()
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then    
		
		if myHero.pos:DistanceTo(target.pos) < 400 and Menu.Combo.UseR:Value() and Ready(_R) then
			ControlCastSpell(HK_R, target)	
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 490 and Menu.Combo.UseE:Value() and Ready(_E) then
			ControlCastSpell(HK_E, target.pos)
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 800 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			ControlCastSpell(HK_Q)
		end

		if myHero.pos:DistanceTo(target.pos) < 750 and Menu.Combo.UseW:Value() and Ready(_W) then
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
--[[
function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
			
			if myHero.pos:DistanceTo(minion.pos) <= 880 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				local count = GetMinionCount(150, minion)
				if count >= Menu.Clear.Qmin:Value() then
					ControlCastSpell(HK_Q, minion.pos)
				end
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 700 and Menu.Clear.UseW:Value() and Ready(_W) then
				ControlCastSpell(HK_W)
			end			
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
			
			if myHero.pos:DistanceTo(minion.pos) <= 880 and Menu.JClear.UseQ:Value() and Ready(_Q) then
				ControlCastSpell(HK_Q, minion.pos)
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 700 and Menu.JClear.UseW:Value() and Ready(_W) then
				ControlCastSpell(HK_W)
			end			
		end
	end
end
]]
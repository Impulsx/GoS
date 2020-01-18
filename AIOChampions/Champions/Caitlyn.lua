function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
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

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})				

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({name = " ", drop = {"[Q]"}})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "Count", name = "Min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1300, Speed = 2200, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}
	}

	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 67, Range = 800, Speed = 3200, Collision = false
	}

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 90, Range = 750, Speed = 1600, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
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
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 3500, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 1300, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 750, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 125, 10))
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
	end	
	KillSteal()
end
       
function KillSteal()	
local target = GetTarget(3500)     	
if target == nil then return end	
	if IsValid(target) then	
	local hp = target.health
		
		if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= hp and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 3500 and Menu.ks.UseR:Value() and Ready(_R) then
			local RDmg = getdmg("R", target, myHero) - 100
			if RDmg >= hp then			
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Combo()
local target = GetTarget(1400)
if target == nil then return end
	if IsValid(target) then

		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.Combo.UseW:Value() and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
				Control.CastSpell(HK_W, pred.CastPosition)
			end	
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then			
				Control.CastSpell(HK_Q, pred.CastPosition)
	
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 750 and Menu.Combo.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end		
	end
end	

function Harass()
local target = GetTarget(1300)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then			
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end	

function Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and Menu.Clear.UseQ:Value() and GetMinionCount(90, minion) >= Menu.Clear.Count:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	 
		end
	end
end

function JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end  
		end
	end
end

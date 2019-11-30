function GetAllyHeroes() 
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]Immobile Target", value = true})

	--AutoW
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	Menu.AutoW:MenuElement({id = "UseW", name = "Auto Heal Ally", value = true})
	Menu.AutoW:MenuElement({id = "UseWE", name = "Minimum Health Ally", value = 30, min = 0, max = 100, identifier = "%"})
	Menu.AutoW:MenuElement({id = "Mana", name = "Min Mana", value = 20, min = 0, max = 100, identifier = "%"})	

	--AutoR
	Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoR"})
	Menu.AutoR:MenuElement({id = "UseR", name = "Auto Heal Allys below 40%", value = true})
	Menu.AutoR:MenuElement({id = "UseRE", name = "Minimum Allys below 40%", value = 2, min = 1, max = 5})
	Menu.AutoR:MenuElement({type = MENU, id = "AutoR2", name = "AutoSafe priority Ally"})
	Menu.AutoR.AutoR2:MenuElement({id = "UseRE", name = "Minimum Health priority Ally", value = 40, min = 0, max = 100, identifier = "%"})	
	for i, Hero in pairs(GetAllyHeroes()) do
		Menu.AutoR.AutoR2:MenuElement({id = Hero.charName, name = Hero.charName, value = false})		
	end	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})			
		
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		  	
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
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	


	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	
	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 235, Range = 800, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}
	}

	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 250, Range = 925, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}
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
	  if myHero.dead then return end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 925, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 550, 1, Draw.Color(225, 225, 125, 10))
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
	elseif Mode == "Flee" then
		
	end	
	KillSteal()
	AutoW()
	AutoR()
	AutoR2()
	ImmoE()
end

function RCount()
	local count = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.isAlly and IsValid(hero) and hero.health/hero.maxHealth  * 100 < 40 then
			count = count + 1
		
		end
	end	
	return count
end

function ImmoE()
local target = GetTarget(1000)     	
if target == nil then return end		
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 925 and Ready(_E) and Menu.AutoE.UseE:Value() then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if IsImmobileTarget(target) and pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then   
			Control.CastSpell(HK_E, pred.CastPosition) 
			
		end	
	end
end


function AutoR()
	for i, ally in pairs(GetAllyHeroes()) do     	
	if ally == nil then return end	
		if Menu.AutoR.UseR:Value() and Ready(_R) then
			if RCount() >= Menu.AutoR.UseRE:Value() then
				Control.CastSpell(HK_R)
			end	
		end
	end	
end

function AutoR2()
	for i, ally in pairs(GetAllyHeroes()) do     	
	if ally == nil then return end	
		if IsValid(ally) and Ready(_R) then 
			if Menu.AutoR.AutoR2[ally.charName] and Menu.AutoR.AutoR2[ally.charName]:Value() and ally.health/ally.maxHealth <= Menu.AutoR.UseRE:Value()/100 then
				Control.CastSpell(HK_R)
			end	
		end	
	end
end	


function AutoW()
local target = GetTarget(2000)     	
if target == nil then return end	
	for i, ally in pairs(GetAllyHeroes()) do     	
	if ally == nil then return end	
		if IsValid(ally) and myHero.pos:DistanceTo(ally.pos) <= 550 and Ready(_W) then 
			if Menu.AutoW.UseW:Value() then
				if ally.health/ally.maxHealth <= Menu.AutoW.UseWE:Value()/100 and myHero.mana/myHero.maxMana >= Menu.AutoW.Mana:Value()/100 then
					Control.CastSpell(HK_W, ally)
				end	
			end	
		end
	end
end
       
function KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end	
	if IsValid(target) then	
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 925 and Menu.ks.UseE:Value() and Ready(_E) then
			local EDmg = getdmg("E", target, myHero)
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if EDmg >= target.health and pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
	end
end	

function Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then		
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 925 and Menu.Combo.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
	end
end	

function Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 925 and Menu.Harass.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
	end
end	

function Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_ENEMY and IsValid(minion) and myHero.pos:DistanceTo(minion.pos) <= 800 and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	  
		end
	end
end

function JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.pos:DistanceTo(minion.pos) <= 800 and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end 
		end
	end
end

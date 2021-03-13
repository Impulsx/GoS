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

local function IsAllyTurret(unit)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 650 + unit.boundingRadius / 2)
        if turret.isAlly and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
				return true
            end
        end
    end
    return false
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})	
	
	Menu:MenuElement({type = MENU, id = "Q", name = "Auto Q + E"})
	Menu.Q:MenuElement({name = " ", drop = {"Auto [Q] + [E] under Ally Tower"}})		
	Menu.Q:MenuElement({id = "UseQ", name = "Use Auto [Q] + [E]", value = true})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "Qrange", name = "[Q] if range lower than -->", value = 1050, min = 0, max = 1150})
	Menu.Combo:MenuElement({id = "Qrange2", name = "[Q] if range bigger than -->", value = 400, min = 0, max = 1150})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W] +attack speed in AA range ", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})	
	Menu.Combo.Ult:MenuElement({id = "UseRcount", name = "Use[R] count targets", value = true})
	Menu.Combo.Ult:MenuElement({id = "Rcount", name = "Use[R] min Targets", value = 2, min = 1, max = 5}) 
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "Use[R] single target [HP check]", value = true})
	Menu.Combo.Ult:MenuElement({id = "Rhp", name = " Is single target Hp lower than -->", value = 40, min = 0, max = 100, identifier = "%"}) 	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] MaxRange", value = false})
	Menu.Drawing:MenuElement({id = "DrawQ2", name = "Draw [Q] MinRange", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 35, Range = 1150, Speed = 1800, Collision = true, MaxCollision = 0, CollisionTypes = { _G.COLLISION_MINION }
	}
	
	QspellData = {speed = 1800, range = 1150, delay = 0.25, radius = 35, collision = {"minion"}, type = "linear"}	

  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 600, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, Menu.Combo.Qrange:Value(), 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawQ2:Value() and Ready(_Q) then
		DrawCircle(myHero, Menu.Combo.Qrange2:Value(), 1, DrawColor(225, 225, 0, 10))
		end		
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 300, 1, DrawColor(225, 225, 125, 10))
		end		
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()			
	end
	AutoQ()	
end

function AutoQ()
	for i, target in ipairs(GetEnemyHeroes()) do    	
	if myHero.pos:DistanceTo(target.pos) > 1200 then return end	
	
		if myHero.pos:DistanceTo(target.pos) <= 250 and IsValid(target) and Ready(_E) then
			Control.CastSpell(HK_E, target)
		end	
		
		if Ready(_Q) and Menu.Q.UseQ:Value() and IsValid(target) then
			local Tower = IsAllyTurret(myHero)
			if Tower and myHero.pos:DistanceTo(target.pos) <= Menu.Combo.Qrange:Value() then			
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						SetMovement(false)
						Control.CastSpell(HK_Q, pred.CastPosition)
						SetMovement(true)						
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						SetMovement(false)
						Control.CastSpell(HK_Q, pred.CastPos)
						SetMovement(true)						
					end	
				else
					CastGGPred(target)
				end
			end	
		end
	end	
end		

function Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then
	
		if myHero.pos:DistanceTo(target.pos) <= 250 and Menu.Combo.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E, target)
		end		

		if myHero.pos:DistanceTo(target.pos) <= 250 and Menu.Combo.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target)
		end		
		
		if myHero.pos:DistanceTo(target.pos) <= Menu.Combo.Qrange:Value() and myHero.pos:DistanceTo(target.pos) > Menu.Combo.Qrange2:Value() and Menu.Combo.UseQ:Value() and Ready(_Q) then
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
				CastGGPred(target)
			end
		end
		
		if Ready(_R) and Menu.Combo.Ult.UseRcount:Value() then
			local count = GetEnemyCount(550, myHero)
			if count >= Menu.Combo.Ult.Rcount:Value() then
				Control.CastSpell(HK_R)
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 550 and Ready(_R) and Menu.Combo.Ult.UseR:Value() then
			if target.health/target.maxHealth <= Menu.Combo.Ult.Rhp:Value() / 100 then
				Control.CastSpell(HK_R)
			end
		end		
	end
end

function CastGGPred(unit)
	local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 35, Range = 1150, Speed = 1800, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
	QPrediction:GetPrediction(unit, myHero)
	if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
		Control.CastSpell(HK_Q, QPrediction.CastPosition)
	end	
end

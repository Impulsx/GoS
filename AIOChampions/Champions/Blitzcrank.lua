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

local function IsNearAllyTurret(unit)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2 + 350)
        if turret.isAlly and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
				return turret
            end
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

local function ReadyFlash()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Game.CanUseSpell(SUMMONER_1) == 0 then
		return true
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Game.CanUseSpell(SUMMONER_2) == 0 then
		return true
	end
    return false
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
	
	Menu:MenuElement({type = MENU, id = "Q", name = "Special Hook Mode"})
	Menu.Q:MenuElement({name = " ", drop = {"Auto [Q] + Flash under Ally Tower"}})		
	Menu.Q:MenuElement({id = "UseQ", name = "Use Special Hook Mode", value = true})	
	Menu.Q:MenuElement({id = "DrawQ", name = "Draw Tower Hook Mode range", value = true})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "Qrange", name = "[Q] if range lower than -->", value = 1050, min = 0, max = 1150})	
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
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1150, Speed = 1800, Collision = true, MaxCollision = 0, CollisionTypes = { _G.COLLISION_MINION }
	}
	
	QspellData = {speed = 1800, range = 1150, delay = 0.25, radius = 70, collision = {"minion"}, type = "linear"}	

  	                                           
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
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 600, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, Menu.Combo.Qrange:Value(), 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 300, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Q.DrawQ:Value() and Ready(_Q) and ReadyFlash() then
			for i = 1, GameTurretCount() do
				local turret = GameTurret(i)
				if turret.isAlly and not turret.dead then
					local range = (turret.boundingRadius + 750 + myHero.boundingRadius / 2 + 350)				
					DrawCircle(turret, range, 1, DrawColor(0xFF00FF00))
				end
			end	
		end		
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()			
	end
	if ReadyFlash() then
		AutoQ()	
	end	
end

function AutoQ()
local target = GetTarget(1200)     	
if target == nil then return end	
	
	if Ready(_Q) and Menu.Q.UseQ:Value() and IsValid(target) then
		local Tower = IsNearAllyTurret(myHero)
		if Tower and myHero.pos:DistanceTo(target.pos) <= Menu.Combo.Qrange:Value() then
			local buff = HasBuff(target, "rocketgrab2")
			if buff then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
					ControlCastSpell(HK_SUMMONER_1, Tower.pos)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
					ControlCastSpell(HK_SUMMONER_2, Tower.pos)
				end
			end
			
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					ControlCastSpell(HK_Q, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					ControlCastSpell(HK_Q, pred.CastPos)
				end	
			end
		end	
	end
end		

function Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then

		if myHero.pos:DistanceTo(target.pos) <= 300 and Menu.Combo.UseW:Value() and Ready(_W) then
			ControlCastSpell(HK_W)
		end	

		if myHero.pos:DistanceTo(target.pos) <= 300 and Menu.Combo.UseE:Value() and Ready(_E) then
			ControlCastSpell(HK_E)
		end		
		
		if myHero.pos:DistanceTo(target.pos) <= Menu.Combo.Qrange:Value() and Menu.Combo.UseQ:Value() and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					ControlCastSpell(HK_Q, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					ControlCastSpell(HK_Q, pred.CastPos)
				end	
			end
		end
		
		if Ready(_R) and Menu.Combo.Ult.UseRcount:Value() then
			local count = GetEnemyCount(550, myHero)
			if count >= Menu.Combo.Ult.Rcount:Value() then
				ControlCastSpell(HK_R)
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 550 and Ready(_R) and Menu.Combo.Ult.UseR:Value() then
			if target.health/target.maxHealth <= Menu.Combo.Ult.Rhp:Value() / 100 then
				ControlCastSpell(HK_R)
			end
		end		
	end
end	
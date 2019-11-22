function LoadScript()
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	
	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "UseE", name = "Pull Enemys under Tower",value = true})

	--AutoW
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	Menu.AutoW:MenuElement({id = "UseW", name = "AutoW", value = true})
	Menu.AutoW:MenuElement({id = "UseWE", name = "Minimum Health", value = 50, min = 0, max = 100, identifier = "%"})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "count", name = "[E]Minimum Targets", value = 2, min = 1, max = 5})	
	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})

  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})	

	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true}) 
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
 	
    
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})			
	Menu.ks:MenuElement({id = "Targets", name = "Ult Settings", type = MENU})	
	Menu.ks.Targets:MenuElement({id = "UseR", name = "[R] FullDmg", value = true})
	for i, Hero in pairs(GetEnemyHeroes()) do
		Menu.ks.Targets:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
	end		
	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q]Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R]Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]Range", value = true})
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 400, Range = 675, Speed = 500, Collision = false
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
	Callback.Add("Draw", function() Draw() end)		
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
		JClear()			
	end	

	KillSteal()
	AutoE()
	AutoW()
end

function Draw()
  if myHero.dead then return end
	if(Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 650, 1, Draw.Color(255, 225, 255, 10)) 
	end                                                 
	if(Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 625, 1, Draw.Color(225, 225, 0, 10))
	end
	if(Menu.Drawing.DrawE:Value()) and Ready(_E) then
    Draw.Circle(myHero, 900, 1, Draw.Color(225, 225, 125, 10))
	end

	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end				
end	

function AutoW()
	if myHero.health/myHero.maxHealth <= Menu.AutoW.UseWE:Value()/100 and Menu.AutoW.UseW:Value() and Ready(_W) then
		if HasBuff(myHero, "MordekaiserW") then 
			Control.CastSpell(HK_W)
		end
		if not HasBuff(myHero, "MordekaiserW") then 
			Control.CastSpell(HK_W)
		end			
	end
end

function AutoE()
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
		
        if Menu.AutoE.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 900 and IsUnderAllyTurret(myHero) and Ready(_E) then
			Control.CastSpell(HK_E, target.pos)
        end		
	end
end

function KillSteal()	
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then	
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end	
        end

        if Menu.ks.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 900 and Ready(_E) then
            local EDmg = getdmg("E", target, myHero)
			if EDmg >= target.health then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
			end	
        end
        if Menu.ks.Targets.UseR:Value() and Menu.ks.Targets[target.charName] and Menu.ks.Targets[target.charName]:Value() and myHero.pos:DistanceTo(target.pos) <= 650 and Ready(_R) then
			if (getdmg("Q", target, myHero)+getdmg("E", target, myHero))*2 >= target.health then
				Control.CastSpell(HK_R, target.pos)
			end	
		end
	end	
end	

function Combo()
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
		if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then	
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
        end

        if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 900 and Ready(_E) then
            local count = GetEnemyCount(200, target)
			if count >= Menu.Combo.count:Value() then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
			end	
        end
	end
end

function Harass()

	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
        
		if Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
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
        if minion.team == TEAM_ENEMY and IsValid(minion) then
           
           
			if Menu.Clear.UseQ:Value() and myHero.pos:DistanceTo(minion.pos) <= 625 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end

            if Menu.Clear.UseE:Value() and myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_E) then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
            end
        end
    end
end

function JClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion) then
            
           
			if Menu.JClear.UseQ:Value() and myHero.pos:DistanceTo(minion.pos) <= 625 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end

            if Menu.JClear.UseE:Value() and myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_E) then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
            end
        end
    end
end

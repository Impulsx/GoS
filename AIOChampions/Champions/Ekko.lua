function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end 

function EnemiesNear(pos,range)
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)
		local Range = range * range
		if not hero.dead and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < Range then
			N = N + 1
		end
	end
	return N	
end	

function IsUnderTurret(unit)
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

function GetTwin()
	for i = 1, Game.ParticleCount() do 
	local particle = Game.Particle(i)
		if myHero.pos:DistanceTo(particle.pos) < 5000 and particle.name == "Ekko_Base_R_TrailEnd" then 
			return particle.pos
		end
	end 
end

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO" .. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"WIP Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({type = MENU, id = "AutoUlt", name = "Auto Ultimate"})
	Menu.Combo.AutoUlt:MenuElement({id = "Enabled", name = "Enabled", value = true})
	Menu.Combo.AutoUlt:MenuElement({id = "hit", name = "if Can Hit X Enemies", value = 3, min = 1, max = 5, identifier = "Enemy/s"})
	Menu.Combo.AutoUlt:MenuElement({id = "killable", name = "if Can Kill X Enemies", value = 2, min = 1, max = 5, identifier = "Enemy/s"})	
	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true}) 		
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"}) 

	--LastHit
	Menu:MenuElement({type = MENU, id = "Last", name = "LastHit Minion"})
	Menu.Last:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Last:MenuElement({id = "Mana", name = "Min Mana to LastHit", value = 20, min = 0, max = 100, identifier = "%"})

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Collision = false, Delay = 0.25, Radius = 120, Range = 1100, Speed = 1650
	}
	
	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 3.35, Radius = 400, Range = 1600, Speed = math.huge
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
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end  
		
		if myHero.dead then return end
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 1100, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 1600, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 325, 1, Draw.Color(225, 225, 125, 10))
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		CastR()
		AutoUlt()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "LastHit" then
		LastHit()	
		
			
	end
		
end

function Combo()
local target = GetTarget(1700)	
if target == nil then return end
    if IsValid(target) then
	
		if Ready(_W) and Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 1600 then
		local pred = GetGamsteronPrediction(target, WData, myHero)	
			if myHero.mana < (myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana) and myHero.mana >= myHero:GetSpellData(_W).mana and (myHero.health - target.health) > (60 + 20 * myHero:GetSpellData(_W).level + 1.5 * myHero.ap) then
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then	
					_G.SDK.Orbwalker:SetMovement(false)
					Control.CastSpell(HK_W, pred.CastPosition)
					_G.SDK.Orbwalker:SetMovement(true)
				end	
			elseif myHero.pos:DistanceTo(target.pos) < 925 then
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then	
					_G.SDK.Orbwalker:SetMovement(false)
					Control.CastSpell(HK_W, pred.CastPosition)
					_G.SDK.Orbwalker:SetMovement(true)
				end	
			end
		end		
		
		if Ready(_Q) and Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1100 then
			local pred = GetGamsteronPrediction(target, QData, myHero)	
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then	
				_G.SDK.Orbwalker:SetMovement(false)
				Control.CastSpell(HK_Q, pred.CastPosition)
				_G.SDK.Orbwalker:SetMovement(true)
			end	
		end
	   
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseE:Value() then 
			_G.SDK.Orbwalker:SetMovement(false)
			Control.CastSpell(HK_E, target.pos)
			_G.SDK.Orbwalker:SetMovement(true)
		end
	end
end	

function CastR()
local target = GetTarget(5000)	
if target == nil then return end    
local twin = GetTwin()	
	if twin and Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 1000 and target.dead and Menu.Combo.UseR:Value() then
		if myHero.health < 200 and IsUnderTurret(myHero) and not IsUnderTurret(twin) then
			Control.CastSpell(HK_R)
		end
    end
	   
    if twin and EnemiesNear(twin,400) >= 1 and Menu.Combo.UseR:Value() then
		if Ready(_R) and Ready(_Q) and Ready(_E) and myHero.mana >= (myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_E).mana + myHero:GetSpellData(_R).mana) and target.health < (getdmg("Q", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero) + getdmg("AA", target, myHero)) then
			Control.CastSpell(HK_R)
		elseif Ready(_R) and Ready(_Q) and myHero.mana >= (myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_R).mana) and target.health < (getdmg("Q", target, myHero) + getdmg("R", target, myHero) + getdmg("AA", target, myHero)) then
			Control.CastSpell(HK_R)
		elseif Ready(_R) and Ready(_E) and myHero.mana >= (myHero:GetSpellData(_E).mana + myHero:GetSpellData(_R).mana) and target.health < (getdmg("E", target, myHero) + getdmg("R", target, myHero) + getdmg("AA", target, myHero)) then
			Control.CastSpell(HK_R)
		elseif Ready(_R) and target.health < (getdmg("R", target, myHero) + getdmg("AA", target, myHero)) then
			Control.CastSpell(HK_R)
		end
    end
end 

function Harass()
local target = GetTarget(1700)	
if target == nil then return end
    if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then   
	
		if Ready(_Q) and Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1100 then
			local pred = GetGamsteronPrediction(target, QData, myHero)	
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then	
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
	   
		if Ready(_W) and Menu.Harass.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 1600 then
			local pred = GetGamsteronPrediction(target, WData, myHero)	
			if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then	
				Control.CastSpell(HK_W, pred.CastPosition)
			end
		end
       
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) > (myHero.range + myHero.boundingRadius) and myHero.pos:DistanceTo(target.pos) < 500 and Menu.Harass.UseE:Value() then
			local BestPos = Vector(target) - (Vector(target) - Vector(myHero)):Perpendicular():Normalized() * 350
			if BestPos then 
				Control.CastSpell(HK_E, BestPos)
			else
				Control.CastSpell(HK_E, mousePos)
			end
		end
	end	
end	
	 
function AutoUlt()
local twin = GetTwin()	
	if twin and Ready(_R) and Menu.Combo.AutoUlt.Enabled:Value() then
		if EnemiesNear(twin,400) >= Menu.Combo.AutoUlt.hit:Value() then
			Control.CastSpell(HK_R)
		end
	end
	

		
	for i,enemy in pairs(GetEnemyHeroes()) do
    local KillableEnemies = 0			
		if Ready(_R) and Menu.Combo.AutoUlt.Enabled:Value() then
			if twin and EnemiesNear(twin,400) >= 1 and enemy.health < getdmg("R", enemy, myHero) then 
				KillableEnemies = KillableEnemies + 1
			end
		  
			if KillableEnemies >= Menu.Combo.AutoUlt.killable:Value() then
				Control.CastSpell(HK_R)
			end
		end
    end
end

function Clear()	
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100   
		if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_ENEMY and IsValid(minion) and mana_ok then
            	
			if Ready(_Q) and Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) > (myHero.range + myHero.boundingRadius) and Ready(_E) and Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
    end
end

function JungleClear()         
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100        
		if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_JUNGLE and IsValid(minion) and mana_ok then
       
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) > (myHero.range + myHero.boundingRadius) and Ready(_E) and Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
    end
end

function LastHit()     	
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.Last.Mana:Value() / 100   
		if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_ENEMY and IsValid(minion) and mana_ok then
			if Ready(_Q) and Menu.Last.UseQ:Value() and minion.health < (getdmg("Q", minion, myHero, 1) + getdmg("Q", minion, myHero, 2)) then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
    end       
end

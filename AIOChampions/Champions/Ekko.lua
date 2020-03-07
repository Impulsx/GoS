local function GetEnemyHeroes()
    return Enemies
end

local function EnemiesNear(pos,range)
	local N = 0
	for i = 1,GameHeroCount()  do
		local hero = GameHero(i)
		local Range = range * range
		if not hero.dead and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < Range then
			N = N + 1
		end
	end
	return N	
end	

local function KillEnemiesNearTwin(pos,range)	
	local N = 0
	for i = 1,GameHeroCount()  do
		local hero = GameHero(i)
		local Range = range * range
		if not hero.dead and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < Range and hero.health < getdmg("R", hero, myHero) then
			N = N + 1
		end
	end
	return N	
end	

local function IsUnderTurret(unit)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
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

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO" .. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.07"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Combo:MenuElement({type = MENU, id = "AutoUlt", name = "Ultimate Settings"})
	Menu.Combo.AutoUlt:MenuElement({name = " ", drop = {"Can cause FPS drops"}})
	Menu.Combo.AutoUlt:MenuElement({id = "UseR", name = "UseR in Combo", value = false})	
	Menu.Combo.AutoUlt:MenuElement({id = "hitX", name = "UseR Hit X Enemies", value = true})
	Menu.Combo.AutoUlt:MenuElement({id = "hit", name = "if Can Hit X Enemies", value = 3, min = 1, max = 5, identifier = "Enemy/s"})
	Menu.Combo.AutoUlt:MenuElement({id = "killX", name = "UseR Kill X Enemies", value = true})	
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

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Collision = false, Delay = 0.5, Radius = 120, Range = 1100, Speed = 1650
	}
	
	QspellData = {speed = 1650, range = 1100, delay = 0.5, radius = 120, collision = {}, type = "linear"}	
	
	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.5, Radius = 400, Range = 1600, Speed = MathHuge
	}

	WspellData = {speed = MathHuge, range = 1600, delay = 0.5, radius = 400, collision = {}, type = "circular"}	

  	                                           
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
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1100, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 1600, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 325, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		if Ready(_R) then
			CastR()
			AutoUlt()
		end	
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()			
	end
end

local function GetTwin()
	local twin = {}
	local Range = 3000 * 3000	
	for i = 1, GameParticleCount() do 
	local particle = GameParticle(i)
		if particle and GetDistanceSqr(myHero.pos, particle.pos) < Range and particle.name == "Ekko_Base_R_TrailEnd" then --"Ekko_Base_R_RewindIndicator"
			TableInsert(twin, particle)
		end
	end 
	return twin
end

function Combo()
local target = GetTarget(1700)	
if target == nil then return end
    if IsValid(target) then
	
		if Ready(_W) and Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 1600 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
					SetMovement(false)
					ControlCastSpell(HK_W, pred.CastPosition)
					SetMovement(true)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
					SetMovement(false)
					ControlCastSpell(HK_W, pred.CastPos)
					SetMovement(true)
				end	
			end	
		end		
		
		if Ready(_Q) and Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					SetMovement(false)
					ControlCastSpell(HK_Q, pred.CastPosition)
					SetMovement(true)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					SetMovement(false)
					ControlCastSpell(HK_Q, pred.CastPos)
					SetMovement(true)
				end	
			end	
		end
	   
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseE:Value() then 
			SetMovement(false)
			ControlCastSpell(HK_E, target.pos)
			SetMovement(true)
		end
	end
end	

function CastR()
local target = GetTarget(3200)	
if target == nil then return end    
	if Menu.Combo.AutoUlt.UseR:Value() then	
		for i, twin in pairs(GetTwin())	do
			if myHero.pos:DistanceTo(target.pos) <= 1000 and target.dead and twin and Ready(_R) then
				if myHero.health < 300 and IsUnderTurret(myHero) and not IsUnderTurret(twin) then
					ControlCastSpell(HK_R)
				end
			end
			   
			if twin and EnemiesNear(twin.pos,400) >= 1 then
				if Ready(_R) and Ready(_Q) and Ready(_E) and myHero.mana >= (myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_E).mana + myHero:GetSpellData(_R).mana) and target.health < (getdmg("Q", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero) + getdmg("AA", target, myHero)) then
					ControlCastSpell(HK_R)
				elseif Ready(_R) and Ready(_Q) and myHero.mana >= (myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_R).mana) and target.health < (getdmg("Q", target, myHero) + getdmg("R", target, myHero) + getdmg("AA", target, myHero)) then
					ControlCastSpell(HK_R)
				elseif Ready(_R) and Ready(_E) and myHero.mana >= (myHero:GetSpellData(_E).mana + myHero:GetSpellData(_R).mana) and target.health < (getdmg("E", target, myHero) + getdmg("R", target, myHero) + getdmg("AA", target, myHero)) then
					ControlCastSpell(HK_R)
				elseif Ready(_R) and target.health < (getdmg("R", target, myHero) + getdmg("AA", target, myHero)) then
					ControlCastSpell(HK_R)
				end
			end
		end
	end	
end 

function Harass()
local target = GetTarget(1700)	
if target == nil then return end
    if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then   
	
		if Ready(_Q) and Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					SetMovement(false)
					ControlCastSpell(HK_Q, pred.CastPosition)
					SetMovement(true)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					SetMovement(false)
					ControlCastSpell(HK_Q, pred.CastPos)
					SetMovement(true)
				end	
			end		
		end
	   
		if Ready(_W) and Menu.Harass.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 1600 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
					SetMovement(false)
					ControlCastSpell(HK_W, pred.CastPosition)
					SetMovement(true)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
					SetMovement(false)
					ControlCastSpell(HK_W, pred.CastPos)
					SetMovement(true)
				end	
			end	
		end
       
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 500 and Menu.Harass.UseE:Value() then
			ControlCastSpell(HK_E, target.pos)
		end
	end	
end	
 	 
function AutoUlt()	
	for i, twin in pairs(GetTwin())	do	
		if twin and Ready(_R) and Menu.Combo.AutoUlt.hitX:Value() then
			if EnemiesNear(twin.pos,400) >= Menu.Combo.AutoUlt.hit:Value() then
				ControlCastSpell(HK_R)
			end
		end

		if twin and Ready(_R) and Menu.Combo.AutoUlt.killX:Value() then		  
			if KillEnemiesNearTwin(twin.pos,400) >= Menu.Combo.AutoUlt.killable:Value() then
				ControlCastSpell(HK_R)
			end
		end
	end
end	

function Clear()	
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100   
		if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_ENEMY and IsValid(minion) and mana_ok then
            	
			if Ready(_Q) and Menu.Clear.UseQ:Value() then
				ControlCastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) < 500 and Ready(_E) and Menu.Clear.UseE:Value() then
				ControlCastSpell(HK_E, minion.pos)
			end
		end
    end
end

function JungleClear()         
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100        
		if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_JUNGLE and IsValid(minion) and mana_ok then
       
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				ControlCastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) < 500 and Ready(_E) and Menu.JClear.UseE:Value() then
				ControlCastSpell(HK_E, minion.pos)
			end
		end
    end
end

local function GetEnemyHeroes()
    return Enemies
end 

local function GetAllyHeroes()
	return Allies
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

local function UltEnemyTurret(unit)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750) 
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit) < range then
                return true
            end
        end
    end
    return false
end

local function UltAllyTurret(unit)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750)
        if turret.isAlly and not turret.dead then
            if turret.pos:DistanceTo(unit) < range then
                return true
            end
        end
    end
    return false
end

local function GetEnemyCount(range, pos)
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

require "2DGeometry"

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.07"}})
	
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
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "Emin", name = "[E] If Hit X Minion ", value = 3, min = 1, max = 6, step = 1, identifier = "Minion/s"})	
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "Grit", name = "Min Grit to Use [W]", value = 0, min = 0, max = 100, identifier = "%"})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance [W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance [E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	--Drawing
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W]", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R]", value = false})		
	Menu.Drawing:MenuElement({id = "REnd", name = "Draw [R] Landing Pos", value = true})			

	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.52, Radius = 90, Range = 750, Speed = MathHuge, Collision = false
	}
	
	WspellData = {speed = MathHuge, range = 750, delay = 0.52, radius = 90, collision = {nil}, type = "linear"}	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.2, Radius = 175, Range = 490, Speed = MathHuge, Collision = false
	}
	
	EspellData = {speed = MathHuge, range = 490, delay = 0.2, radius = 175, collision = {nil}, type = "linear"}		
	
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
		if Menu.Drawing.REnd:Value() and Ready(_R) then
			local target = GetTarget(1000)
			if target == nil then return end
			local UltEndPos = target.pos:Extended(myHero.pos, -690)
			if IsValid(target) and myHero.pos:DistanceTo(target.pos) < 600 and GetMode() == "Combo" and target.health/target.maxHealth <= Menu.Combo.HP:Value() / 100 then    
				DrawCircle(UltEndPos, 400, 1, DrawColor(225, 225, 0, 10))				
				local LS = LineSegment(myHero.pos, UltEndPos)
				LS:__draw()
			end	
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
local target = GetTarget(1400)
if target == nil then return end
	if IsValid(target) then    
		
		if myHero.pos:DistanceTo(target.pos) < 400 and Menu.Combo.UseR:Value() and Ready(_R) and Menu.Combo.Targets[target.charName] and Menu.Combo.Targets[target.charName]:Value() then
			local Rdmg = getdmg("R", target, myHero)
			if Rdmg > target.health then 
				Control.CastSpell(HK_R, target)
			
			else
				
				if target.health/target.maxHealth <= Menu.Combo.HP:Value() / 100 then
					CastUlt(target)
				end	
			end
		end			
					
		if myHero.pos:DistanceTo(target.pos) < 440 and Menu.Combo.UseE:Value() and Ready(_E) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					Control.CastSpell(HK_E, pred.CastPos)
				end
			else
				CastGGPredE(target)
			end
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 800 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q)
		end

		if myHero.pos:DistanceTo(target.pos) < 750 and Menu.Combo.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= Menu.Combo.Grit:Value() / 100 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
					Control.CastSpell(HK_W, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
					Control.CastSpell(HK_W, pred.CastPos)
				end
			else
				CastGGPredW(target)
			end
		end	
	end
end	

function CastUlt(unit)
	for i, ally in pairs(GetAllyHeroes()) do
		local UltEndPos = unit.pos:Extended(myHero.pos, -690)
		local enemyCount = GetEnemyCount(400, UltEndPos)
		
		if UltAllyTurret(UltEndPos) then
			Control.CastSpell(HK_R, unit)
		
		elseif ally.pos:DistanceTo(UltEndPos) < 600 then
			Control.CastSpell(HK_R, unit)	
			
		elseif enemyCount >= 1 then
			if UltEnemyTurret(UltEndPos) == false then
				Control.CastSpell(HK_R, unit)
			end					
		end	
	end
end		

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 800 and minion.team == TEAM_ENEMY and IsValid(minion) then
			
			if myHero.pos:DistanceTo(minion.pos) <= 400 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 750 and Menu.Clear.UseW:Value() and Ready(_W) then
				local count = GetMinionCount(400, minion)
				if count >= Menu.Clear.Wmin:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Grit:Value() / 100 then			
					Control.CastSpell(HK_W, minion.pos)
				end	
			end	
			
			if myHero.pos:DistanceTo(minion.pos) <= 440 and Menu.Clear.UseE:Value() and Ready(_E) then
				local count = GetMinionCount (160, minion)
				if count >= Menu.Clear.Emin:Value() then
					Control.CastSpell(HK_E, minion.pos)
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
				Control.CastSpell(HK_Q)
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 750 and Menu.JClear.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= Menu.JClear.Grit:Value() / 100 then
				Control.CastSpell(HK_W, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) <= 440 and Menu.JClear.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E, minion.pos)
			end			
		end
	end
end

function CastGGPredW(unit)
	local WPrediction = GGPrediction:SpellPrediction({Delay = 0.52, Radius = 90, Range = 750, Speed = MathHuge, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
	WPrediction:GetPrediction(unit, myHero)
	if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
		Control.CastSpell(HK_W, WPrediction.CastPosition)
	end	
end

function CastGGPredE(unit)
	local EPrediction = GGPrediction:SpellPrediction({Delay = 0.2, Radius = 175, Range = 490, Speed = MathHuge, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
	EPrediction:GetPrediction(unit, myHero)
	if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
		Control.CastSpell(HK_E, EPrediction.CastPosition)
	end	
end

local function GetEnemyHeroes()
	return Enemies
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

local function IsUnderAllyTurret(unit)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isAlly and not turret.dead then
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
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.07"}})	
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
	Menu.Combo:MenuElement({id = "count", name = "[E]Minimum Targets", value = 1, min = 1, max = 5})	
	
	
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
		Menu.ks.Targets:MenuElement({id = Hero.charName, name = "Use Ult on "..Hero.charName, value = true})		
	end		
	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	

 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q]Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R]Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]Range", value = false})
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.4, Radius = 200, Range = 675, Speed = MathHuge, Collision = false
	}
	
	QspellData = {speed = MathHuge, range = 675, delay = 0.4, radius = 200, collision = {nil}, type = "linear"}	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.9, Radius = 120, Range = 900, Speed = MathHuge, Collision = false
	}
	
	EspellData = {speed = MathHuge, range = 900, delay = 0.9, radius = 120, collision = {nil}, type = "linear"}	

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 650, 1, DrawColor(255, 225, 255, 10)) 
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 625, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 125, 10))
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
		JClear()			
	end	

	KillSteal()
	AutoE()
	AutoW()
	
	
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
		
        if Menu.AutoE.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 850 and IsUnderAllyTurret(myHero) and Ready(_E) then
			CastE(target)
        end		
	end
end

local function QDmg(unit)
	local Lvl = myHero.levelData.lvl
	local QLvl = myHero:GetSpellData(_Q).level
	local raw = ({50, 80, 110, 140, 170})[QLvl] + 0.6 * myHero.ap
	local m = ({7, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 29, 32, 35, 38, 42, 46, 50})[Lvl]
	local Dmg = raw + m
	return CalcMagicalDamage(myHero, unit, Dmg)
end

function KillSteal()	
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
			local QDmg = QDmg(target)
			if QDmg >= target.health then
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
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 200, Range = 675, Speed = MathHuge, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end					
				end
			end	
        end

        if Menu.ks.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 850 and Ready(_E) then
            local EDmg = getdmg("E", target, myHero)
			if EDmg >= target.health then
				CastE(target)	
			end	
        end
        if Menu.ks.Targets.UseR:Value() and Menu.ks.Targets[target.charName] and Menu.ks.Targets[target.charName]:Value() and myHero.pos:DistanceTo(target.pos) <= 650 and Ready(_R) then
			if (QDmg(target)+ getdmg("E", target, myHero))*2 >= target.health then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 200, Range = 675, Speed = MathHuge, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end					
			end
        end

        if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 850 and Ready(_E) then
            local count = GetEnemyCount(200, target)
			if count >= Menu.Combo.count:Value() then
				CastE(target)	
			end	
        end
	end
end

function Harass()

	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
        
		if Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 200, Range = 675, Speed = MathHuge, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end					
			end
        end	
	end
end	

function CastE(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, EData, myHero)
		if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
			Control.CastSpell(HK_E, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
			Control.CastSpell(HK_E, pred.CastPos)
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.9, Radius = 120, Range = 900, Speed = MathHuge, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end	
	end
end

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion) then
           
           
			if Menu.Clear.UseQ:Value() and myHero.pos:DistanceTo(minion.pos) <= 625 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end

            if Menu.Clear.UseE:Value() and myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_E) then	
				Control.CastSpell(HK_E, minion.pos)		
            end
        end
    end
end

function JClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion) then
            
           
			if Menu.JClear.UseQ:Value() and myHero.pos:DistanceTo(minion.pos) <= 625 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end

            if Menu.JClear.UseE:Value() and myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_E) then	
				Control.CastSpell(HK_E, minion.pos)		
            end
        end
    end
end

local function GetEnemyHeroes()
	return Enemies
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

local LastPos = {}
local function MyHeroLastPos()
	return LastPos
end 

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})		
	
	--Combo  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})

	--Ult  
	Menu.Combo:MenuElement({type = MENU, id = "ult", name = "Ultimate Settings"})	
	Menu.Combo.ult:MenuElement({id = "R", name = "Save Life", value = true})		
	Menu.Combo.ult:MenuElement({id = "Rhp", name = "Use[R] if Renekton Hp lower than", value = 20, min = 0, max = 100, identifier = "%"})
	Menu.Combo.ult:MenuElement({name = " ", drop = {"-------------------------------"}})	
	Menu.Combo.ult:MenuElement({id = "tower", name = "Tower Dive", value = true})
	Menu.Combo.ult:MenuElement({id = "towerhp", name = "Use[R] if Renekton Hp lower than", value = 40, min = 0, max = 100, identifier = "%"})	
	Menu.Combo.ult:MenuElement({name = " ", drop = {"-------------------------------"}})	
	Menu.Combo.ult:MenuElement({id = "count", name = "Min Enemies near", value = true})
	Menu.Combo.ult:MenuElement({id = "countR", name = "How many Enemies near", value = 3, min = 1, max = 5, step = 1})
	Menu.Combo.ult:MenuElement({id = "counthp", name = "Use[R] if Renekton Hp lower than", value = 60, min = 0, max = 100, identifier = "%"})
	Menu.Combo.ult:MenuElement({id = "countRange", name = "Range for Enemies", value = 500, min = 0, max = 1000})	

	--Harass
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "harassMode", name = "Harass Mode", value = 1, drop = {"Only Q", "Q + W", "EQWE to enemyPos", "EQW + E back to startPos"}})	
	
	--LaneClear
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})  
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})  
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true}) 	
	
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "smartKS", name = "Smart KS", value = true})	
		
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Gamsteron Prediction", "Premium Prediction"}})		
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 450, Speed = 1400, Collision = false
	}
	
	EspellData = {speed = 1400, range = 450, delay = 0.25, radius = 50, collision = {}, type = "linear"}	

	 
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
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 175, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 325, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 450, 1, DrawColor(225, 225, 125, 10))
		end	
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		Ult()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		--Clear()
		--JungleClear()			
	end	

	KillSteal()
end

function CastQ(unit)
	if Ready(_Q) and myHero.pos:DistanceTo(unit.pos) < 325 then
		if IsValid(unit) then 
			ControlCastSpell(_Q)
		end
	end
end

function CastW(unit)
	if Ready(_W) and myHero.pos:DistanceTo(unit.pos) < (myHero.range + 50) then
		if IsValid(unit) then 
			ControlCastSpell(_W, unit)
		end
	end
end

function AimE(unit)
	if myHero.pos:DistanceTo(unit.pos) < 450 and Ready(_E) and IsValid(unit) then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				ControlCastSpell(HK_E, pred.CastPosition)
			end
		else
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				ControlCastSpell(HK_E, pred.CastPos)
			end	
		end
	end
end

function Slice(unit)
	if myHero.pos:DistanceTo(unit.pos) < 450 and Ready(_E) and myHero:GetSpellData(_E).name == "RenektonSliceAndDice" and IsValid(unit) then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				ControlCastSpell(HK_E, pred.CastPosition)
			end
		else
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				ControlCastSpell(HK_E, pred.CastPos)
			end	
		end
	end
end

function Dice(unit)
	if myHero.pos:DistanceTo(unit.pos) < 450 and Ready(_E) and myHero:GetSpellData(_E).name == "renektondice" and IsValid(unit) then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				ControlCastSpell(HK_E, pred.CastPosition)
			end
		else
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				ControlCastSpell(HK_E, pred.CastPos)
			end	
		end
	end
end

function Ult()
if not Ready(_R) then return end
	if Menu.Combo.ult.R:Value() then 
		if Ready(_R) and myHero.health/myHero.maxHealth <= Menu.Combo.ult.Rhp:Value() / 100 then 
			ControlCastSpell(_R)
		end
	end
	if Menu.Combo.ult.tower:Value() then

		if IsUnderTurret(myHero) and Ready(_R) and myHero.health/myHero.maxHealth <= Menu.Combo.ult.towerhp:Value() / 100 and count > 0 then 
			ControlCastSpell(_R)
		end
	end	
	if Menu.Combo.ult.count:Value() then
		local count = GetEnemyCount(Menu.Combo.ult.countRange:Value(), myHero)	
		if Ready(_R) and count >= Menu.Combo.ult.countR:Value() and myHero.health/myHero.maxHealth <= Menu.Combo.ult.counthp:Value() / 100 then
			ControlCastSpell(_R)
		end
	end
end

function Harass()
local target = GetTarget(1100)
if target == nil then return end
	
	if Menu.Harass.harassMode:Value() == 1 then  
		CastQ(target) 
	
	elseif Menu.Harass.harassMode:Value() == 2 then 
		CastQ(target)  
		CastW(target) 
	
	elseif Menu.Harass.harassMode:Value() == 3 then
 		CastQ(target) 
		CastW(target)  
		Slice(target)  
		Dice(target) 
	
	elseif Menu.Harass.harassMode:Value() == 4 then
		SavePos(target)
		Slice(target) 
		if myHero:GetSpellData(_E).name == "renektondice" then 
			CastQ(target) 
		end
		if myHero:GetSpellData(_E).name == "renektondice" and not Ready(_Q) then 
			CastW(target) 
		end
		if myHero:GetSpellData(_E).name == "renektondice" and not Ready(_Q) and not Ready(_W) then 
			LastDash() 
		end
	end				
end

function SavePos(unit)
	if myHero.pos:DistanceTo(unit.pos) <= 450 and IsValid(unit) then
		TableInsert(LastPos, myHero,pos)
	end
end

function LastDash()
	for i, Pos in pairs(MyHeroLastPos()) do
		if Pos then
			ControlCastSpell(_E, Pos)
		end
	end	
end

function KillSteal()
	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy ~= nil and myHero.pos:DistanceTo(enemy.pos) <= 1000 and IsValid(enemy) then
		local distance = myHero.pos:DistanceTo(enemy.pos)
		local hp = enemy.health
		local qDmg = getdmg("Q", enemy, myHero)
		local wDmg = getdmg("W", enemy, myHero)
		local eDmg = getdmg("E", enemy, myHero)
			if hp <= qDmg and Ready(_Q) and (distance <= 325)
				then CastQ(enemy)
			elseif hp <= wDmg and Ready(_W) and (distance <= (myHero.range + 50)) 
				then CastW(enemy)
			elseif hp <= eDmg and Ready(_E) and (distance <= 450) 
				then AimE()
			elseif hp <= (qDmg + wDmg) and Ready(_Q) and Ready(_W) and (distance <= 325)
				then CastW(enemy)
			elseif hp <= (qDmg + eDmg) and Ready(_Q) and Ready(_E) and (distance <= 325)
				then AimE()
			elseif hp <= (wDmg + eDmg) and Ready(_W) and Ready(_E) and (distance <= (myHero.range + 50))
				then AimE()
			elseif hp <= (qDmg + wDmg + eDmg) and Ready(_Q) and Ready(_W) and Ready(_E) and (distance <= 325)
				then AimE()
			end
		end
	end
end
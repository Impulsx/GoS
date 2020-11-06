local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
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
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local LastPos = nil
local iDmg = 0
local qDmg = 0
local wDmg = 0
local eDmg = 0


function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})		
	
	--Combo  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})

	--Ult  
	Menu.Combo:MenuElement({type = MENU, id = "ult", name = "Auto Ultimate Settings"})	
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
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})		
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "text", name = "Draw Kill Text", value = true})	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 450, Speed = 1400, Collision = false
	}
	
	EspellData = {speed = 1400, range = 450, delay = 0.25, radius = 50, collision = {}, type = "linear"}	

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		if Menu.Drawing.text:Value() then		
			DamageCalculation()
		end
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
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()			
	end	
	Ult()
	KillSteal()
end

function Combo()
local target = GetTarget(1100)
if target == nil then return end 
	if Menu.Combo.UseQ:Value() then 
		CastQ(target) 
	end
	if Menu.Combo.UseW:Value() then 
		CastW(target) 
	end
	if Menu.Combo.UseE:Value() then 
		Slice(target)  
		Dice(target) 
	end
end

function Ult()
if not Ready(_R) then return end
	if Menu.Combo.ult.R:Value() then 
		if Ready(_R) and myHero.health/myHero.maxHealth <= Menu.Combo.ult.Rhp:Value() / 100 then 
			Control.CastSpell(HK_R)
		end
	end
	if Menu.Combo.ult.tower:Value() then
		local count = GetEnemyCount(1000, myHero)
		if IsUnderTurret(myHero) and Ready(_R) and myHero.health/myHero.maxHealth <= Menu.Combo.ult.towerhp:Value() / 100 and count > 0 then 
			Control.CastSpell(HK_R)
		end
	end	
	if Menu.Combo.ult.count:Value() then
		local count = GetEnemyCount(Menu.Combo.ult.countRange:Value(), myHero)	
		if Ready(_R) and count >= Menu.Combo.ult.countR:Value() and myHero.health/myHero.maxHealth <= Menu.Combo.ult.counthp:Value() / 100 then
			Control.CastSpell(HK_R)
		end
	end
end

function Harass()
local target = GetTarget(1100)
if target == nil then return end
	
	if Menu.Harass.harassMode:Value() == 1 then  
		CastQ(target) 
	end
	if Menu.Harass.harassMode:Value() == 2 then 
		CastQ(target)  
		CastW(target) 
	end
	if Menu.Harass.harassMode:Value() == 3 then
 		CastQ(target) 
		CastW(target)  
		Slice(target)  
		Dice(target) 
	end
	if Menu.Harass.harassMode:Value() == 4 then
		local E2Buff = HasBuff(myHero, "renektonsliceanddicedelay")
		if not E2Buff then
			if myHero.pos:DistanceTo(target.pos) <= 450 and IsValid(target) then
				LastPos = myHero.pos
			end
			Slice(target) 
		end	
		if E2Buff then 
			CastQ(target) 
		end
		if E2Buff and not Ready(_Q) then 
			CastW(target) 
		end
		if E2Buff and not Ready(_Q) and not Ready(_W) then 
			LastDash() 
		end
	end				
end

function LastDash()
	if LastPos then
		Control.CastSpell(HK_E, LastPos)
	end	
end

function KillSteal()
	for i, enemy in pairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(enemy.pos) <= 1000 and IsValid(enemy) then 
		local distance = myHero.pos:DistanceTo(enemy.pos)
		local hp = enemy.health
		local q1Dmg = getdmg("Q", enemy, myHero, 1)
		local w1Dmg = getdmg("W", enemy, myHero, 1)
		local e1Dmg = getdmg("E", enemy, myHero, 1)		
		local q2Dmg = getdmg("Q", enemy, myHero, 2)
		local w2Dmg = getdmg("W", enemy, myHero, 2)
		local e2Dmg = getdmg("E", enemy, myHero, 2)
			if Menu.ks.smartKS:Value() then 
				if myHero.mana/myHero.maxMana >= 0.5 then 					
					if hp <= q2Dmg and Ready(_Q) and distance <= 325 then 						
						CastQ(enemy)
					elseif hp <= w2Dmg and Ready(_W) and distance <= 325 then 
						CastW(enemy)
					elseif hp <= e2Dmg and Ready(_E) and distance <= 450 then 
						AimE(enemy)
					elseif hp <= (q2Dmg + w1Dmg) and Ready(_Q) and Ready(_W) and distance <= 325 then 
						CastQ(enemy)						
					elseif hp <= (q1Dmg + w2Dmg) and Ready(_Q) and Ready(_W) and distance <= 325 then 
						CastW(enemy)
					elseif hp <= (q1Dmg + e2Dmg) and Ready(_Q) and Ready(_E) and distance <= 450 then 
						AimE(enemy)
					elseif hp <= (w1Dmg + e2Dmg) and Ready(_W) and Ready(_E) and distance <= 450 then 
						AimE(enemy)
					elseif hp <= (q1Dmg + w1Dmg + e2Dmg) and Ready(_Q) and Ready(_W) and Ready(_E) and distance <= 450 then 
						AimE(enemy)
					end
				else
					if hp <= q1Dmg and Ready(_Q) and distance <= 325 then 
						CastQ(enemy)
					elseif hp <= w1Dmg and Ready(_W) and distance <= 325 then 
						CastW(enemy)
					elseif hp <= e1Dmg and Ready(_E) and distance <= 450 then 
						AimE(enemy)
					elseif hp <= (q1Dmg + w1Dmg) and Ready(_Q) and Ready(_W) and distance <= 325 then 
						CastW(enemy)
					elseif hp <= (q1Dmg + e1Dmg) and Ready(_Q) and Ready(_E) and distance <= 450 then 
						AimE(enemy)
					elseif hp <= (w1Dmg + e1Dmg) and Ready(_W) and Ready(_E) and distance <= 450 then 
						AimE(enemy)
					elseif hp <= (q1Dmg + w1Dmg + e1Dmg) and Ready(_Q) and Ready(_W) and Ready(_E) and distance <= 450 then 
						AimE(enemy)
					end
				end	
			end	
		end
	end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE and myHero.pos:DistanceTo(minion.pos) < 500 then
			if Menu.JClear.UseQ:Value() then 
				CastQ(minion) 
			end
			if Menu.JClear.UseW:Value() then 
				CastW(minion) 
			end
			if Menu.JClear.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 450 and IsValid(minion) then
				Control.CastSpell(HK_E, minion.pos)
			end	
		end
	end	
end

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) < 500 then
			if Menu.Clear.UseQ:Value() then 
				CastQ(minion) 
			end
			if Menu.Clear.UseW:Value() then 
				CastW(minion) 
			end
			if Menu.Clear.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 450 and IsValid(minion) then
				Control.CastSpell(HK_E, minion.pos)
			end	
		end
	end
end

function CastQ(unit)
	if Ready(_Q) and myHero.pos:DistanceTo(unit.pos) < 325 then
		if IsValid(unit) then 
			Control.CastSpell(HK_Q)
		end
	end
end

function CastW(unit)
	if Ready(_W) and myHero.pos:DistanceTo(unit.pos) < 325 then
		if IsValid(unit) then 
			Control.CastSpell(HK_W, unit)
		end
	end
end

function AimE(unit)
	if myHero.pos:DistanceTo(unit.pos) < 450 and Ready(_E) and IsValid(unit) then
		CastE(unit)
	end
end

function Slice(unit)
local E2Buff = HasBuff(myHero, "renektonsliceanddicedelay")
if E2Buff then return end	
	if myHero.pos:DistanceTo(unit.pos) < 450 and Ready(_E) and IsValid(unit) then
		CastE(unit)
	end
end

function Dice(unit)
local E2Buff = HasBuff(myHero, "renektonsliceanddicedelay")
	if myHero.pos:DistanceTo(unit.pos) < 450 and Ready(_E) and E2Buff and IsValid(unit) then
		CastE(unit)
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
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 450, Speed = 1400, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value()+1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end	
	end
end

function DamageCalculation()
local enemy = GetTarget(1500)
if enemy == nil then return end
	if myHero.pos:DistanceTo(enemy.pos) <= 1000 and IsValid(enemy) then
		local qDmg 	= getdmg("Q", enemy, myHero, 1)	
		local wDmg	= getdmg("W", enemy, myHero, 1)	
		local eDmg	= getdmg("E", enemy, myHero, 1)

		-- "Kill! - (Q)" --
		if enemy.health <= qDmg then
			if Ready(_Q) then 
				DrawText("Kill! - (Q)", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 255, 0, 0))
			else 
				DrawText("Wait for CD's!", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 0, 255, 0))
			end
		--	"Kill! - (W)" --
		elseif enemy.health <= wDmg then
			if Ready(_W) then 
				DrawText("Kill! - (W)", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 255, 0, 0))
			else 
				DrawText("Wait for CD's!", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 0, 255, 0))
			end
		-- "Kill! - (E)" --
		elseif enemy.health <= eDmg then
			if Ready(_E) then 
				DrawText("Kill! - (E)", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 255, 0, 0))
			else 
				DrawText("Wait for CD's!", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 0, 255, 0))
			end
		-- "Kill! - (Q)+(W)" --
		elseif enemy.health <= qDmg+wDmg then
			if Ready(_Q) and Ready(_W) then 
				DrawText("Kill! - (Q)+(W)", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 255, 0, 0))
			else 
				DrawText("Wait for CD's!", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 0, 255, 0))
			end
		-- "Kill! - (Q)+(E)" --
		elseif enemy.health <= qDmg+eDmg then
			if Ready(_Q) and Ready(_E) then 
				DrawText("Kill! - (Q)+(E)", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 255, 0, 0))
			else 
				DrawText("Wait for CD's!", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 0, 255, 0))
			end
		-- "Kill! - (W)+(E)" --
		elseif enemy.health <= wDmg+eDmg then
			if Ready(_W) and Ready(_E) then 
				DrawText("Kill! - (W)+(E)", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 255, 0, 0))
			else 
				DrawText("Wait for CD's!", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 0, 255, 0))
			end
		-- "Kill! - (Q)+(W)+(E)" --
		elseif enemy.health <= qDmg+wDmg+eDmg then
			if Ready(_Q) and Ready(_W) and Ready(_E) then 
				DrawText("Kill! - (Q)+(W)+(E)", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 255, 0, 0))
			else 
				DrawText("Wait for CD's!", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 0, 255, 0))
			end
		-- "Harass your enemy!" -- 
		else 
			DrawText("Harass him!", 16, enemy.pos2D.x - 50, enemy.pos2D.y + 50,DrawColor(255, 0, 255, 0))			
		end
	end
end

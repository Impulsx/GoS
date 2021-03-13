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

local function GetAllyHeroes() 
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function GetEnemyCount(range, pos)
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function IsUnderTurret(unit, radius)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local Bradius = radius or unit.boundingRadius / 2
		local range = (turret.boundingRadius + 750 + Bradius)
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

local function GetEnergy()
	local currentEnergyNeeded = 0
	
	if Ready(_Q) then
		currentEnergyNeeded = currentEnergyNeeded + myHero:GetSpellData(_Q).mana
	end
	if Ready(_W) then
		currentEnergyNeeded = currentEnergyNeeded + myHero:GetSpellData(_W).mana
	end
	if Ready(_E) then
		currentEnergyNeeded = currentEnergyNeeded + myHero:GetSpellData(_E).mana
	end
	return currentEnergyNeeded
end

local function GetDamage(spell)
	local damage = 0
	local AD = myHero.bonusDamage
	
	if spell == HK_Q then
		if GameCanUseSpell(_Q) == 0 then
			damage = damage + ((myHero:GetSpellData(_Q).level * 35 + 45) + AD)
		end
	elseif spell == HK_E then
		if GameCanUseSpell(_E) == 0 then
			damage = damage + ((myHero:GetSpellData(_E).level * 25 + 45) + AD * 0.8)
		end
	elseif spell == Ignite then
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and GameCanUseSpell(SUMMONER_1) == 0 then
			damage = damage +  (50 + 20 * myHero.levelData.lvl)
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and GameCanUseSpell(SUMMONER_2) == 0 then
			damage = damage +  (50 + 20 * myHero.levelData.lvl)
		end	
	end
	return damage
end

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
end

local Rtarget 		= 	{}
local R1casted 		= 	false
local SpellsLoaded 	= 	false 
local Qdmg 			= 	0
local Wshadow 		= 	nil
local Rshadow 		= 	nil
local QEKillable 	= 	false
local UltKillable 	= 	false
local WTime = 0
local RTime = 0

function LoadScript()
	--OnProcessSpell()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.08"}})			
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "Change", name = "[E] Logic", value = 1, drop = {"Auto [E]", "ComboKey [E]"}})	
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "All Ult Option On/Off", value = true})	
	Menu.Combo.Ult:MenuElement({name = " ", drop = {"Ult-Logic: Calc. completely possible Dmg"}})	
	Menu.Combo.Ult:MenuElement({id = "IGN", name = "Use Ignite for KS and active Ult", value = true})			
	Menu.Combo.Ult:MenuElement({id = "UseRTower", name = "Kill[R] Dive under Tower", value = true})
	Menu.Combo.Ult:MenuElement({id = "UseR2", name = "[R2]or[W2] Back after donate deathmark", value = true})	
	Menu.Combo.Ult:MenuElement({id = "UseRBack", name = "[R2]Back if Zed Hp low", value = true})
	Menu.Combo.Ult:MenuElement({id = "Hp", name = "[R2]Back if Zed Hp lower than -->", value = 15, min = 0, max = 100, identifier = "%"})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W1]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Change", name = "[E] Logic", value = 1, drop = {"Auto [E]", "HarassKey [E]"}})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Energy to Harass", value = 40, min = 0, max = 100, identifier = "%"})

	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQE", name = "KS: [W1]>[E]>[Q]", value = true})

	Menu:MenuElement({type = MENU, id = "spells", name = "Evade"})
	Menu.spells:MenuElement({id = "wblock", name = "Evade[W] MousePos", value = true})		
	Menu.spells:MenuElement({id = "rblock", name = "Evade[R] if not ready [W]", value = true})
	for i, enemy in ipairs(GetEnemyHeroes()) do
		Menu.spells:MenuElement({type = MENU, id = enemy.charName, name = enemy.charName})	
	end	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "KillText", name = "Draw Kill Text onScreen/Minimap", value = false})	


	QData ={Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 900, Speed = 900,  Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 900, range = 900, delay = 0.25, radius = 55, type = "linear",  collision = {"minion"}
	}
	
	WData ={
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 290, Range = 900, Speed = 2500, Collision = false
	}
	
	WspellData = {speed = 2500, range = 900, delay = 0.25, radius = 290, type = "linear", collision = {nil}
	}	

	Callback.Add("Tick", function() Tick() end)
	Callback.Add("Draw", function() Drawing() end)	
end

function LoadBlockSpells()
	for i, t in ipairs(GetEnemyHeroes()) do
		if t then		
			for slot = 0, 3 do
			local enemy = t
			local spellName = enemy:GetSpellData(slot).name
				if slot == 0 and Menu.spells[enemy.charName] then
					Menu.spells[enemy.charName]:MenuElement({ id = spellName, name = "Block [Q]", value = false })
				end
				if slot == 1 and Menu.spells[enemy.charName] then
					Menu.spells[enemy.charName]:MenuElement({ id = spellName, name = "Block [W]", value = false })
				end
				if slot == 2 and Menu.spells[enemy.charName] then
					Menu.spells[enemy.charName]:MenuElement({ id = spellName, name = "Block [E]", value = false })
				end
				if slot == 3 and Menu.spells[enemy.charName] then
					Menu.spells[enemy.charName]:MenuElement({ id = spellName, name = "Block [R]", value = true })
				end			
			end
		end
	end
end

function Tick()
if not SpellsLoaded then 
	LoadBlockSpells()
	SpellsLoaded = true
end

if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		if not QEKillable then
			Ult()
			if not UltKillable then
				Q()
				W()
				if Menu.Combo.Change:Value() == 2 then
					E()
				end	
			end
		end	
	elseif Mode == "Harass" then
		Q()
		W()
		if Menu.Harass.Change:Value() == 2 then
			E()
		end	
	end
	
	if R1casted and myHero:GetSpellData(_R).name == "ZedR2" then
		Control.CastSpell(HK_R)
		R1casted = false
	end	

	if Wshadow ~= nil and (WTime + 5) < GameTimer() then
		WTime 	= 0
		Wshadow = nil
	end
	
	if Rshadow ~= nil and (RTime + 6.5) < GameTimer() then
		RTime 	= 0
		Rshadow = nil
	end			
	
	if Menu.Combo.Change:Value() == 1 or Menu.Harass.Change:Value() == 1 then
		AutoE()
	end	

	if Menu.ks.UseQE:Value() then
		QEKill()
	end

	if Ready(_W) and Menu.spells.wblock:Value() and SpellsLoaded == true then
		EvadeW()
	end	

	if Ready(_R) and (not Ready(_W) or not Menu.spells.wblock:Value()) and Menu.spells.rblock:Value() and SpellsLoaded == true then
		EvadeR()
	end	
	AutoBack()
end

function EvadeW()
local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and myHero.pos:DistanceTo(unit.pos) < 3000 and spell then
		if unit.activeSpell and unit.activeSpell.valid and
		(unit.activeSpell.target == myHero.handle or 
		GetDistance(unit.activeSpell.placementPos, myHero.pos) <= myHero.boundingRadius * 2 + unit.activeSpell.width) and not 
		string.find(unit.activeSpell.name:lower(), "attack") then
			for j = 0, 3 do
				local cast = unit:GetSpellData(j)
				if Menu.spells[unit.charName][cast.name] and Menu.spells[unit.charName][cast.name]:Value() and cast.name == unit.activeSpell.name then
					local startPos = unit.activeSpell.startPos
					local placementPos = unit.activeSpell.placementPos
					local width = 0
					if unit.activeSpell.width > 0 then
						width = unit.activeSpell.width
					else
						width = 100
					end
					local distance = GetDistance(myHero.pos, placementPos)											
					if unit.activeSpell.target == myHero.handle then
						CastEvadeW()
						return
					else
						if distance <= width * 2 + myHero.boundingRadius then
							CastEvadeW()
						break
						end
					end							
				end
			end
		end
	end
end

function CastEvadeW()	
	Control.CastSpell(HK_W, mousePos)
	WTime = GameTimer()
	DelayAction(function()
		Control.CastSpell(HK_W)
	end,0.2)		
end

function EvadeR()
local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and myHero.pos:DistanceTo(unit.pos) < 3000 and spell then
		if unit.activeSpell and unit.activeSpell.valid and
		(unit.activeSpell.target == myHero.handle or 
		GetDistance(unit.activeSpell.placementPos, myHero.pos) <= myHero.boundingRadius * 2 + unit.activeSpell.width) and not 
		string.find(unit.activeSpell.name:lower(), "attack") then
			for j = 0, 3 do
				local cast = unit:GetSpellData(j)
				if Menu.spells[unit.charName][cast.name] and Menu.spells[unit.charName][cast.name]:Value() and cast.name == unit.activeSpell.name then
					local startPos = unit.activeSpell.startPos
					local placementPos = unit.activeSpell.placementPos
					local width = 0
					if unit.activeSpell.width > 0 then
						width = unit.activeSpell.width
					else
						width = 100
					end
					local distance = GetDistance(myHero.pos, placementPos)											
					if unit.activeSpell.target == myHero.handle then
						CastEvadeR()
						return
					else
						if distance <= width * 2 + myHero.boundingRadius then
							CastEvadeR()
						break
						end
					end							
				end
			end
		end
	end
end

function CastEvadeR()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy and myHero.pos:DistanceTo(enemy.pos) <= 625 and IsValid(enemy) then
			Control.CastSpell(HK_R, enemy)
			R1casted = true
		end
	end
end	

function Drawing()
	if myHero.dead then return end

	if Menu.Drawing.DrawR:Value() and Ready(_R) then
	DrawCircle(myHero, 625, 1, DrawColor(255, 225, 255, 10))
	end                                                 
	if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
	DrawCircle(myHero, 900, 1, DrawColor(225, 225, 0, 10))
	end
	if Menu.Drawing.DrawW:Value() and Ready(_W) then
	DrawCircle(myHero, 650, 1, DrawColor(225, 225, 0, 10))
	end		
	if Menu.Drawing.DrawE:Value() and Ready(_E) then
	DrawCircle(myHero, 290, 1, DrawColor(225, 225, 125, 10))
	end	

	if Menu.Drawing.KillText:Value() then
		for i, target in ipairs(GetEnemyHeroes()) do
			local Qdmg2		= Ready(_Q) and GetDamage(HK_Q) or 0
			local Edmg2 	= Ready(_E) and GetDamage(HK_E) or 0
			local IGdmg 	= GetDamage(Ignite) or 0			
			local Qdmg 		= Ready(_Q) and getdmg("Q", target, myHero) or 0
			local Edmg 		= Ready(_E) and getdmg("E", target, myHero) or 0
			local Rdmg 		= getdmg("R", target, myHero)
			local physical	= myHero.totalDamage
			local magical 	= myHero.ap
			local TotalDmg 	= (Qdmg + Edmg + Rdmg + IGdmg + ((Qdmg2 + Edmg2 + physical)*(0.1 + 0.15 * myHero:GetSpellData(_R).level)) + ((physical + magical) * 2)) - (target.hpRegen*3)	
			local QEDmg 	= (Qdmg + Edmg) - (target.hpRegen*3)
			local currentEnergyNeeded = GetEnergy()
			if Ready(_R) then
				if myHero.pos:DistanceTo(target.pos) <= 2000 and IsValid(target) and target.health < TotalDmg and myHero.mana > currentEnergyNeeded then 
					DrawText("Kill", 24, target.pos2D.x, target.pos2D.y,DrawColor(255, 255, 0, 0))
					DrawText("Kill", 10, target.posMM.x - 15, target.posMM.y - 15,DrawColor(255, 255, 0, 0))			
				end
			else
				if myHero.pos:DistanceTo(target.pos) <= 2000 and IsValid(target) and target.health < QEDmg then
					DrawText("Kill", 24, target.pos2D.x, target.pos2D.y,DrawColor(255, 255, 0, 0))
					DrawText("Kill", 10, target.posMM.x - 15, target.posMM.y - 15,DrawColor(255, 255, 0, 0))	
				end				
			end	
		end	
	end	
end

local function CastQ(aim, unit)
	if Ready(_Q) then
	
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(aim, QData, unit)
			if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(unit, aim, QspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then					
				Control.CastSpell(HK_Q, pred.CastPos)
			end
			
		else
		
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 900, Speed = 900, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
			QPrediction:GetPrediction(aim, unit)
			if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				Control.CastSpell(HK_Q, QPrediction.CastPosition)
			end				
		end	
	end
end

local function CastW(aim, unit)
	if Ready(_W) and castSpell.state == 0 then
	
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(aim, WData, unit)
			if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
				Control.CastSpell(HK_W, pred.CastPosition)
				WTime = GameTimer()
				Wshadow = pred.CastPosition
			end
			
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(unit, aim, WspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then					
				Control.CastSpell(HK_W, pred.CastPos)
				WTime = GameTimer()
				Wshadow = pred.CastPos				
			end	
			
		else
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 290, Range = 900, Speed = 2500, Collision = false})
			WPrediction:GetPrediction(aim, unit)
			if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
				Control.CastSpell(HK_W, WPrediction.CastPosition)
				WTime = GameTimer()
				Wshadow = WPrediction.CastPosition				
			end				
		end
	end	
end

function Q()
local target = GetTarget(2000)
if target == nil then return end
    if Ready(_Q) then

		if myHero.pos:DistanceTo(target.pos) <= 850 and not Ready(_W) then
			CastQ(target, myHero)
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and ((Wshadow ~= nil) or (Rshadow ~= nil)) then
			Control.CastSpell(HK_Q, target.pos)			
		end
		
		if myHero.pos:DistanceTo(target.pos) > 850 then	
			
			if Wshadow ~= nil and GetDistance(Wshadow, target.pos) <= 850 then
				Control.CastSpell(HK_Q, target.pos)
				
			end
			
			if Rshadow ~= nil and GetDistance(Rshadow, target.pos) <= 850 then
				Control.CastSpell(HK_Q, target.pos)
				
			end
		end	
    end
end

function W()
local target = GetTarget(2000)
if target == nil then return end    
    if Ready(_W) then

		if myHero:GetSpellData(_W).name ~= "ZedW2" then
			if Ready(_Q) and not Ready(_E) then
				if myHero.pos:DistanceTo(target.pos) <= 1800 then
					if myHero.pos:DistanceTo(target.pos) <= 900 then
						CastW(target, myHero)
						DelayAction(function()
							Control.CastSpell(HK_Q, target.pos)
						end,0.2)	
						return
					else
						Control.CastSpell(HK_W, target.pos)
						return
					end	
				end
			else
				if Ready(_Q) and Ready(_E) then
					if myHero.pos:DistanceTo(target.pos) < 900 then
						CastW(target, myHero)
						DelayAction(function()
							Control.CastSpell(HK_Q, target.pos)
						end,0.2)
						return
					end	
				end	
			end
		end
    end
end

function E()
	for i, target in ipairs(GetEnemyHeroes()) do 
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 2000 and IsValid(target) then
		
			if GetDistance(target.pos, myHero.pos) < 290 then
				Control.CastSpell(HK_E)
			end	
				
			if Wshadow ~= nil then
				if GetDistance(Wshadow, target.pos) < 290 then
					Control.CastSpell(HK_E)
				end
			end
			
			if Rshadow ~= nil then
				if GetDistance(Rshadow, target.pos) < 290 then
					Control.CastSpell(HK_E)
				end
			end
		end
	end	
end

function AutoE()
	for i, target in ipairs(GetEnemyHeroes()) do 
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 2000 and IsValid(target) then
		
			if GetDistance(target.pos, myHero.pos) < 290 then
				Control.CastSpell(HK_E)
			end	
				
			if Wshadow then
				if GetDistance(Wshadow, target.pos) < 290 then
					Control.CastSpell(HK_E)
				end
			end
			
			if Rshadow then
				if GetDistance(Rshadow, target.pos) < 290 then
					Control.CastSpell(HK_E)
				end
			end
		end
	end	
end

function Ult()
local target = GetTarget(2500)
if target == nil then return end	
	if IsValid(target) then	
		local Qdmg2		= Ready(_Q) and GetDamage(HK_Q) or 0
		local Edmg2 	= Ready(_E) and GetDamage(HK_E) or 0
		local IGdmg 	= GetDamage(Ignite) or 0			
		local Qdmg 		= Ready(_Q) and getdmg("Q", target, myHero) or 0
		local Edmg 		= Ready(_E) and getdmg("E", target, myHero) or 0
		local Rdmg 		= getdmg("R", target, myHero)
		local physical	= myHero.totalDamage
		local magical 	= myHero.ap
		local TotalDmg 	= (Qdmg + Edmg + Rdmg + IGdmg + ((Qdmg2 + Edmg2 + physical)*(0.1 + 0.15 * myHero:GetSpellData(_R).level)) + ((physical + magical) * 2)) - (target.hpRegen*3) 
		local currentEnergyNeeded = GetEnergy()
		
		if Menu.Combo.Ult.IGN:Value() and myHero.pos:DistanceTo(target.pos) <= 600 and (UltKillable or IGdmg - (target.hpRegen*3) > target.health) then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and GameCanUseSpell(SUMMONER_1) == 0 then
				Control.CastSpell(HK_SUMMONER_1, target)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and GameCanUseSpell(SUMMONER_2) == 0 then
				Control.CastSpell(HK_SUMMONER_2, target)
			end	
		end	
		
		if Menu.Combo.Ult.UseR:Value() and Menu.Combo.Ult.UseRBack:Value() and myHero:GetSpellData(_R).name == "ZedR2" then	
			if myHero.health/myHero.maxHealth <= Menu.Combo.Ult.Hp:Value() / 100 then
				Control.CastSpell(HK_R)
			end	
		end		
		
		if Menu.Combo.Ult.UseR:Value() and Ready(_R) and myHero:GetSpellData(_R).name ~= "ZedR2" then					
			if myHero.pos:DistanceTo(target.pos) <= 625 then
			
				if Menu.Combo.Ult.UseRTower:Value() then
					if target.health < TotalDmg and myHero.mana > currentEnergyNeeded then
						UltKillable = true
						Rshadow = myHero.pos
						DelayAction(function()
							Control.CastSpell(HK_R, target)
							TableInsert(Rtarget, target) 
							RTime = GameTimer()
							UltKillable = false
						end,0.2)
						return
					end
				else
					for i, ally in ipairs(GetAllyHeroes()) do
						if target.health < TotalDmg and myHero.mana > currentEnergyNeeded then
							if not IsUnderTurret(target) or (IsUnderTurret(target) and ally.pos:DistanceTo(target.pos) < 900 and IsUnderTurret(ally)) then
								UltKillable = true
								Rshadow = myHero.pos
								DelayAction(function()
									Control.CastSpell(HK_R, target)
									TableInsert(Rtarget, target)
									RTime = GameTimer()
									UltKillable = false
								end,0.2)
								return
							end	
						end	
					end	
				end				
			else
				if Wshadow ~= nil then
					if Ready(_W) and myHero:GetSpellData(_W).toggleState == 2 and target.health < TotalDmg and myHero.mana > currentEnergyNeeded and GetDistance(Wshadow, target.pos) <= 625 then
						if Menu.Combo.Ult.UseRTower:Value() then
							UltKillable = true
							Wshadow = myHero.pos
							Control.CastSpell(HK_W)
							DelayAction(function()
								UltKillable = false
							end,0.2)	
						else
							for i, ally in ipairs(GetAllyHeroes()) do
								if not IsUnderTurret(target) or (IsUnderTurret(target) and ally.pos:DistanceTo(target.pos) < 800 and IsUnderTurret(ally)) then
									UltKillable = true
									Wshadow = myHero.pos
									Control.CastSpell(HK_W)
									DelayAction(function()
										UltKillable = false
									end,0.2)
								end	
							end	
						end
					end
				else
					if myHero:GetSpellData(_W).toggleState == 0 then
						if Ready(_W) and target.health < TotalDmg and myHero.mana > currentEnergyNeeded then
							
							if myHero.pos:DistanceTo(target.pos) <= 1250 then
								if Menu.Combo.Ult.UseRTower:Value() then
									UltKillable = true
									Control.CastSpell(HK_W, target.pos)
									DelayAction(function()
										UltKillable = false
									end,0.2)
								else
									for i, ally in ipairs(GetAllyHeroes()) do
										if not IsUnderTurret(target) or (IsUnderTurret(target) and ally.pos:DistanceTo(target.pos) < 800 and IsUnderTurret(ally)) then
											UltKillable = true
											Control.CastSpell(HK_W, target.pos)
											DelayAction(function()
												UltKillable = false
											end,0.2)
										end
									end	
								end	
							end
						end
					else
						if Ready(_W) and myHero:GetSpellData(_W).toggleState == 2 and target.health < TotalDmg and myHero.mana > currentEnergyNeeded then
							Wshadow = myHero.pos
							Control.CastSpell(HK_W)
						end
					end	
				end	
			end
		end	
	end	
end

function AutoBack()
	for i, target in ipairs(Rtarget) do
		
		if Menu.Combo.Ult.UseR2:Value() and HasBuff(myHero, "ZedR2") and Rshadow ~= nil and target then
			if GetEnemyCount(600, myHero.pos) > 1 or IsUnderTurret(myHero) then
				if (GetDistance(target.pos, myHero.pos) < GetDistance(target.pos, Rshadow)) and GetEnemyCount(400, Rshadow) == 0 then
					DelayAction(function()
						Control.CastSpell(HK_R)
					end,2)	
				end
				
				if Wshadow ~= nil and myHero:GetSpellData(_W).toggleState == 2 and GetEnemyCount(400, Wshadow) == 0 then
					Control.CastSpell(HK_W)
				end	
			end	
		end
	end	
end

function QEKill()
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) < 900 and IsValid(target) then
			local Qdmg 	= Ready(_Q) and getdmg("Q", target, myHero) or 0
			local Edmg 	= Ready(_E) and getdmg("E", target, myHero) or 0
			local QEdmg = (Qdmg + Edmg)
			local currentEnergyNeeded = GetEnergy()
			
			if Ready(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" and target.health < QEdmg and myHero.mana > currentEnergyNeeded then
				QEKillable = true
				Control.CastSpell(HK_W, target.pos)
			end
			if myHero:GetSpellData(_W).toggleState == 2 and target.health < QEdmg and myHero.mana > currentEnergyNeeded then
				E()			
				Q()	
			end	
		end
		QEKillable = false
	end
end	

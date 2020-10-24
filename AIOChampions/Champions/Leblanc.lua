--- Most ported from BoL/SexySeriesAIO/Author:SexySmTRed ----

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
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function IsUnderTurret(unit)
	for i = 1, GameTurretCount() do
		local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750)
        if turret and turret.isEnemy and not turret.dead then 
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local function AllyMinionUnderTower()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if minion.team == TEAM_ALLY and IsValid(minion) and IsUnderTurret(minion) and myHero.pos:DistanceTo(minion.pos) <= 750 then
			return true
		end
	end
	return false
end

-- Thanks to Ark --
local function GetMinionsAround(pos, range)
	local range = range or MathHuge; local t = {}; local n = 0
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and minion.team == TEAM_ENEMY and minion.alive and minion.valid and GetDistance(pos, minion.pos) <= range then
			TableInsert(t, minion); n = n + 1
		end
	end
	return t, n
end

local function DistanceSquared(p1, p2)
	local dx, dy = p2.x - p1.x, p2.y - p1.y
	return dx * dx + dy * dy
end

local function GetCircularAOEPos(units, radius, expected)
	local BestPos = nil; local MostHit = 0
	for i = 1, #units do
		local unit = units[i]; local MostHit = 0
		for j = 1, #units do
			local target = units[j]
			if GetDistance(target.pos, unit.pos) <= radius then MostHit = MostHit + 1 end
		end
		BestPos = unit.pos
		if MostHit >= expected then return BestPos, MostHit end
	end
	return nil, 0
end

local function GetCircularWKillPos(units, radius, expected)	
	local BestPos = nil; local MostHit = 0
	for i = 1, #units do
		local unit = units[i]; local MostHit = 0
		for j = 1, #units do
			local target = units[j]
			if GetDistance(target.pos, unit.pos) <= radius and getdmg("W", target, myHero) >= target.health then MostHit = MostHit + 1 end
		end
		BestPos = unit.pos
		if MostHit >= expected then return BestPos, MostHit end
	end
	return nil, 0
end
-----------------------------------------------

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function wUsed()
	return myHero:GetSpellData(_W).name == "LeblancWReturn"
end

local function wrUsed()
	return myHero:GetSpellData(_R).name == "LeblancRWReturn"
end 

local function SpellCalc(spell, target)
	local dmg = 0
	if spell == "RQ" then
		dmg = 100 * myHero:GetSpellData(_R).level + 0.65 * myHero.ap
	elseif spell == "RW" then
		dmg = 150 * myHero:GetSpellData(_R).level + 0.975 * myHero.ap 
	elseif spell == "RE" then
		dmg = 100 * myHero:GetSpellData(_R).level + 0.65 * myHero.ap
	elseif spell == "QMark" then
		dmg = 25 * myHero:GetSpellData(_Q).level + 30 + 0.4 * myHero.ap
	end 
	return ((CalcMagicalDamage(myHero, target, dmg) and CalcMagicalDamage(myHero, target, dmg)) or 0)
end

local smartComboTime = GameTimer()
local CanCastSpells = true
local lastActivated = nil
local RSkill = nil
local lastChainCast = GameTimer()
local chainTarget = nil
local WstartPos = myHero.pos
local WRstartPos = myHero.pos
local BestWFarmPos = nil
local DistanceKill = false
local LastRKSTime = 0

function LoadScript() 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "comboWay", name = "Combo Logic", value = 1, drop = {"Smart", "QRWE", "QWRE", "WQRE", "WRQE"}})
	Menu.Combo:MenuElement({id = "Block", name = "Block AA if [R] Ready (FastCombo)", value = true})
	Menu.Combo:MenuElement({id = "Turret", name = "Block [W] under Turret", value = true})	

	--WSettings  
	Menu:MenuElement({type = MENU, id = "settingsW", name = "W Settings"})
	Menu.settingsW:MenuElement({id = "useOptional", name = "Use Optional W Settings", value = true})	
	Menu.settingsW:MenuElement({id = "useOptionalW", name = "Return Way:", value = 1, drop = {"Smart", "Skills used"}})	
	
	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})		
	Menu.Harass:MenuElement({id = "harassQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "harassW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "Turret", name = "Block [W] under Turret", value = true})	
	Menu.Harass:MenuElement({id = "harassE", name = "[E]", value = true})	
 
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "Turret", name = "Block [W] under Turret", value = true})
	Menu.Clear:MenuElement({id = "WBack", name = "[W2] back if enemy near", value = true})	
 	Menu.Clear:MenuElement({id = "WCount", name = "Min Minions to hit W", value = 3, min = 1, max = 7, step = 1}) 	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})

	--Lasthit Menu
	Menu:MenuElement({type = MENU, id = "Last", name = "Lasthit / Freeze Lane"})
	Menu.Last:MenuElement({name = " ", drop = {"Default Key = [X]"}})		 	
	Menu.Last:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Last:MenuElement({id = "AA", name = "Only Q Lasthit if out of AA range", value = true})	
	Menu.Last:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Last:MenuElement({id = "Turret", name = "Block [W] under Turret", value = true})
	Menu.Last:MenuElement({id = "WBack", name = "[W2] back if enemy near", value = true})	
  	Menu.Last:MenuElement({id = "WCount", name = "Min killable Minions to hit W", value = 2, min = 1, max = 5, step = 1})  	
	Menu.Last:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})	
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  

	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "killstealQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "killstealW", name = "[W]", value = true})	
	Menu.ks:MenuElement({id = "killstealE", name = "[E]", value = true})
	Menu.ks:MenuElement({id = "killstealR", name = "[R]", value = true})
	Menu.ks:MenuElement({id = "killstealLong", name = "KS long range W-R-Q-W back", value = true})
	Menu.ks:MenuElement({id = "Draw", name = "DrawText if long range kill possible", value = true})	
	Menu.ks:MenuElement({id = "enemies", name = "Perform KillSteal on:", type = MENU})
	DelayAction(function()	
		for i, Hero in ipairs(GetEnemyHeroes()) do
			Menu.ks.enemies:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
		end	
	end, 0.01)		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 925, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	EspellData = {speed = 1750, range = 925, delay = 0.25, radius = 55, collision = {"minion"}, type = "linear"}	
  	                                          	
	Callback.Add("Tick", function() Tick() end)
	
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	end		
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 865, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 700, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 600, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.ks.Draw:Value() and Menu.ks.killstealLong:Value() and Ready(_R) and Ready(_W) then
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if myHero.pos:DistanceTo(enemy.pos) > 870 and myHero.pos:DistanceTo(enemy.pos) <= 5000 and IsValid(enemy) then
					local Qdmg = ((Ready(_Q) and getdmg("Q", enemy, myHero)) or 0)
					local RWdmg = SpellCalc("RW", enemy)
					local DistanceDmg = Qdmg+RWdmg
					if DistanceDmg >= enemy.health then
						DrawText("Kill Him", 24, enemy.pos2D.x, enemy.pos2D.y,DrawColor(0xFF00FF00))				
					end
				end
			end	
		end		
	end)		
end	

function Tick()
	if CanCastSpells == false and GameTimer() - smartComboTime > 3 then CanCastSpells = true end
	if (myHero:GetSpellData(_R).currentCd > 0 or myHero:GetSpellData(_R).level == 0) and not CanCastSpells then CanCastSpells = true RSkill = nil end	
	if Control.IsKeyDown(HK_R) then	Control.KeyUp(HK_R) end	
	
	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "LastHit" then
		LastHit()		
	end	
	
	if Menu.settingsW.useOptional:Value() then
		SpecificSpellChecks()
	end	
	CheckSpell()
	CeckBuffW()
	KillSteal()	
	
end	

function StopAutoAttack(args)
	local Mode = GetMode()
	if Menu.Combo.Block:Value() and Mode == "Combo" then
		if Ready(_R) then
			args.Process = false 
		else
			if args.Process == false then
				args.Process = true
			end
		end	
	end
end

function CeckBuffW()
	local target = GetTarget(1100)
	if target == nil then return end
	if IsValid(target) and HasBuff(target, "LeblancE") then
		chainTarget = target
	else
		chainTarget = nil
	end
end

function CheckSpell()
	if GameTimer() - myHero:GetSpellData(_Q).castTime <= 0.4 then
    	lastActivated = SpellQ
	end	
	if GameTimer() - myHero:GetSpellData(_W).castTime <= 0.4 then
    	lastActivated = SpellW		
    end
	if GameTimer() - myHero:GetSpellData(_E).castTime <= 0.4 then
    	lastActivated = SpellE
		lastChainCast = GameTimer()
    end	
end

function SpecificSpellChecks()
	if DistanceKill then return end

	if wUsed() and chainTarget ~= nil and GetDistance(WstartPos, chainTarget.pos) > 900 then return end 
	if wrUsed() and not wUsed() and chainTarget ~= nil and GetDistance(WRstartPos, chainTarget.pos) > 900 then return end

	if Menu.settingsW.useOptionalW:Value() == 1 then 
		if wUsed() and wrUsed() then
			if GetEnemyCount(400, WRstartPos) < GetEnemyCount(400, myHero.pos) and not Ready(_Q) and not Ready(_E) then
				DelayAction(function()
					Control.CastSpell(HK_W)
				end,0.1)	
			end
			
		elseif wUsed() and GetEnemyCount(400, WstartPos) < GetEnemyCount(400, myHero.pos) then
			DelayAction(function()
				Control.CastSpell(HK_W)
			end,0.1)
			
		else
			if wrUsed() and GetEnemyCount(400, WRstartPos) < GetEnemyCount(400, myHero.pos) and GameTimer() - LastRKSTime > 4.2 then
				DelayAction(function()
					Control.CastSpell(HK_R)
				end,0.1)
			end	
		end
		
	else
		
		if wUsed() and wrUsed() then
			if not Ready(_Q) and not Ready(_E) then
				DelayAction(function()
					Control.CastSpell(HK_W)
				end,0.1)
			end
			
		elseif wUsed() then
			if not Ready(_Q) and not Ready(_E) then
				DelayAction(function()
					Control.CastSpell(HK_W)
				end,0.1)
			end
			
		elseif wrUsed() then
			if not Ready(_Q) and not Ready(_E) and GameTimer() - LastRKSTime > 4.2 then
				DelayAction(function()
					Control.CastSpell(HK_R)
				end,0.1)
			end
		end
	end
end

function Combo()
	local target = GetTarget(900)
	if target == nil or DistanceKill then return end
	if IsValid(target) then
		
		smartComboTime = GameTimer()

		if not CanCastSpells and RSkill ~= nil then
			if RSkill == "RQ" then
				CastR("Q", target)
			elseif RSkill == "RW" and myHero.pos:DistanceTo(target.pos) > 400 then
				CastR("W", target)
			end
			return
		end

		if CanCastSpells ~= true and RSkill ~= nil then return end

		if Menu.Combo.comboWay:Value() == 1 then
			SmartCombo(target)
		elseif Menu.Combo.comboWay:Value() == 2 then
			-- "Q", "RQ", "W", "E"
			Combo1(target)
		elseif Menu.Combo.comboWay:Value() == 3 then
			-- "Q", "W", "RW", "E"
			Combo2(target)
		elseif Menu.Combo.comboWay:Value() == 4 then
			-- "W", "Q", "RQ", "E"
			Combo3(target)
		elseif Menu.Combo.comboWay:Value() == 5 then
			-- "W", "RW", "Q", "E"
			Combo4(target)
		end
	end
end

function SmartCombo(target) 
	if not CanCastSpells and RSkill ~= nil then return end

	local Wdmg = ((Ready(_W) and not wUsed and getdmg("W", target, myHero)) or 0)
	local RWdmg = ((Ready(_R) and not wrUsed() and SpellCalc("RW", target)) or 0)

	if Ready(_W) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 850 then
		local enemyCount = GetEnemyCount(250, target.pos)
		if enemyCount >= 3 then
			if not wUsed() then 
				if Menu.Combo.Turret:Value() then
					if not IsUnderTurret(target) then
						WstartPos = myHero.pos
						Control.CastSpell(HK_W, target)
						CanCastSpells = false
						RSkill = "RW"
						return
					end
				else
					WstartPos = myHero.pos
					Control.CastSpell(HK_W, target)
					CanCastSpells = false
					RSkill = "RW"
					return
				end	
			end
		end
	end

	local Qdmg = ((Ready(_Q) and getdmg("Q", target, myHero)) or 0)
	local RQdmg = ((Ready(_R) and SpellCalc("RQ", target)) or 0)
	local QMark = (((Ready(_Q) or Ready(_R)) and SpellCalc("QMark", target)) or 0)
	
	-- Q + R
	if myHero.pos:DistanceTo(target.pos) < 700 and Ready(_Q) and Ready(_R) and Qdmg + RQdmg + QMark + QMark + Wdmg > Wdmg + RWdmg + Qdmg then
		if Control.CastSpell(HK_Q, target) then
			CanCastSpells = false
			RSkill = "RQ"
		end
		return
		
	-- W + R
	elseif myHero.pos:DistanceTo(target.pos) < 850 and Ready(_W) and Ready(_R) and not wUsed() and Wdmg + RWdmg > Qdmg + RQdmg + QMark then
		if Menu.Combo.Turret:Value() then
			if not IsUnderTurret(target) then
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
				CanCastSpells = false
				RSkill = "RW"
			end
		else
			WstartPos = myHero.pos
			Control.CastSpell(HK_W, target)
			CanCastSpells = false
			RSkill = "RW"
		end	
		return
		
	elseif myHero.pos:DistanceTo(target.pos) > 700 and myHero.pos:DistanceTo(target.pos) < 860 and Ready(_E) then
		CastE(target)
		return
		
	else
		if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
			Control.CastSpell(HK_Q, target)
		elseif Ready(_R) then
			CastR("Q", target)
		elseif Ready(_W) and myHero.pos:DistanceTo(target.pos) < 850 and not wUsed() then	
			if Menu.Combo.Turret:Value() then
				if not IsUnderTurret(target) then
					WstartPos = myHero.pos
					Control.CastSpell(HK_W, target)
				end
			else
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
			end	
		elseif Ready(_R) and myHero.pos:DistanceTo(target.pos) > 400 then	
			CastR("W", target)
		else
			if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
				CastE(target)
			end	
		end
	end
end

function Combo1(target)
	if Ready(_Q) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		if Control.CastSpell(HK_Q, target) then
			CanCastSpells = false
			RSkill = "RQ"
		end
		return
	end

	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	
	end
	
	if lastActivated == SpellQ and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		CastR("Q", target)
	end
	
	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 850 then
		if Menu.Combo.Turret:Value() then
			if not IsUnderTurret(target) then
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
			end
		else
			WstartPos = myHero.pos
			Control.CastSpell(HK_W, target)
		end	
	end
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
		CastE(target)
	end		
end

function Combo2(target)
	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)
	end	

	if Ready(_W) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 850 then
		if not wUsed() then
			if Menu.Combo.Turret:Value() then
				if not IsUnderTurret(target) then
					WstartPos = myHero.pos
					Control.CastSpell(HK_W, target)
					CanCastSpells = false
					RSkill = "RW"
					return
				end
			else
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
				CanCastSpells = false
				RSkill = "RW"
				return
			end	
		end
	end

	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 850 then
		if Menu.Combo.Turret:Value() then
			if not IsUnderTurret(target) then
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
			end
		else
			WstartPos = myHero.pos
			Control.CastSpell(HK_W, target)
		end
	end
	
	if lastActivated == SpellW and Ready(_R) and not wrUsed() and myHero.pos:DistanceTo(target.pos) > 400 then
		CastR("W", target)
	end	
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
		CastE(target)
	end	
end

function Combo3(target)
	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 850 then 
		if Menu.Combo.Turret:Value() then
			if not IsUnderTurret(target) then
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
			end
		else
			WstartPos = myHero.pos
			Control.CastSpell(HK_W, target)
		end
	end

	if Ready(_Q) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		if Control.CastSpell(HK_Q, target) then
			CanCastSpells = false
			RSkill = "RQ"
		end
		return
	end

	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	
	end
	
	if lastActivated == SpellQ and Ready(_R) then
		CastR("Q", target)
	end
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
		CastE(target)
	end			
end

function Combo4(target)
	if Ready(_W) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 850 then
		if not wUsed() then
			if Menu.Combo.Turret:Value() then
				if not IsUnderTurret(target) then
					WstartPos = myHero.pos
					Control.CastSpell(HK_W, target)
					CanCastSpells = false
					RSkill = "RW"
					return	
				end				
			else
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
				CanCastSpells = false
				RSkill = "RW"
				return
			end		
		end
	end

	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 850 then 
		if Menu.Combo.Turret:Value() then
			if not IsUnderTurret(target) then
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
			end
		else
			WstartPos = myHero.pos
			Control.CastSpell(HK_W, target)
		end	
	end
	
	if lastActivated == SpellW and Ready(_R) and not wrUsed() and myHero.pos:DistanceTo(target.pos) > 400 then
		CastR("W", target)
	end
	
	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	
	end
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
		CastE(target)
	end	
end

function Harass()
	local target = GetTarget(900)
	if target == nil or DistanceKill then return end
	if IsValid(target) then
		
		if Menu.Harass.harassQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
			Control.CastSpell(HK_Q, target)
		end
		
		if Menu.Harass.harassW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 850 then
			if not wUsed() then
				if Menu.Harass.Turret:Value() then
					if not IsUnderTurret(target) then
						WstartPos = myHero.pos
						Control.CastSpell(HK_W, target)
					end
				else
					WstartPos = myHero.pos
					Control.CastSpell(HK_W, target)
				end	
			end
		end
		
		if Menu.Harass.harassE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
			CastE(target)
		end

		if wUsed() and not Ready(_Q) and not Ready(_E) then
			Control.CastSpell(HK_W)
		end
	end
end

function KillSteal()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if IsValid(enemy) and myHero.pos:DistanceTo(enemy.pos) < 850 and Menu.ks.enemies[enemy.charName] and Menu.ks.enemies[enemy.charName]:Value() then
			local Qdmg = ((Menu.ks.killstealQ:Value() and myHero.pos:DistanceTo(enemy.pos) < 700 and Ready(_Q) and getdmg("Q", enemy, myHero)) or 0)
			local Wdmg = ((Menu.ks.killstealW:Value() and myHero.pos:DistanceTo(enemy.pos) < 850 and Ready(_W) and not wUsed() and getdmg("W", enemy, myHero)) or 0)
			local Edmg = ((Menu.ks.killstealE:Value() and myHero.pos:DistanceTo(enemy.pos) < 860 and Ready(_E) and getdmg("E", enemy, myHero)) or 0)
			local RQdmg = ((Menu.ks.killstealR:Value() and myHero.pos:DistanceTo(enemy.pos) < 700 and Ready(_R) and lastActivated == SpellQ and SpellCalc("RQ", enemy)) or 0)
			local RWdmg = ((Menu.ks.killstealR:Value() and myHero.pos:DistanceTo(enemy.pos) < 850 and Ready(_R) and not wrUsed() and lastActivated == SpellW and SpellCalc("RW", enemy)) or 0)
			
			if Qdmg > enemy.health then
				Control.CastSpell(HK_Q, enemy)
			elseif Wdmg > enemy.health then
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, enemy)
			elseif Edmg > enemy.health then
				CastE(enemy)
			elseif RQdmg > enemy.health then
				CastR("Q", enemy)
			elseif RWdmg > enemy.health then
				CastR("W", enemy)
			end 
		end
		
		if Menu.ks.killstealLong:Value() and myHero:GetSpellData(_R).level > 0 then
			if IsValid(enemy) and myHero.pos:DistanceTo(enemy.pos) < 1400 and Menu.ks.enemies[enemy.charName] and Menu.ks.enemies[enemy.charName]:Value() then
				local Qdmg = ((Ready(_Q) and getdmg("Q", enemy, myHero)) or 0)
				local RWdmg = SpellCalc("RW", enemy)
				local DistanceDmg = Qdmg+RWdmg
				
				if DistanceDmg > enemy.health then
					if Ready(_W) and Ready(_R) and not wUsed() and myHero.pos:DistanceTo(enemy.pos) > 870 then
						DistanceKill = true
						local castPos = enemy.pos:Extended(myHero.pos, (myHero.pos:DistanceTo(enemy.pos)-600))
						WstartPos = myHero.pos
						Control.CastSpell(HK_W, castPos)
					end
					
					if Ready(_R) and not wrUsed() and myHero.pos:DistanceTo(enemy.pos) < 850 then
						LastRKSTime = GameTimer()
						WRstartPos = myHero.pos
						Control.SetCursorPos(enemy.pos)
						Control.KeyDown(HK_R)
					end
					
					if wrUsed() and wUsed() then
						if Ready(_Q) and myHero.pos:DistanceTo(enemy.pos) < 700 then
							if Control.CastSpell(HK_Q, enemy) then
								Control.CastSpell(HK_W)
								DistanceKill = false
							end
						else
							Control.CastSpell(HK_W)
							DistanceKill = false
						end	
					end					
				end
			end
		end	
	end
end

function Clear()
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

	if Menu.Clear.WBack:Value() and wUsed() and BestWFarmPos then		
		local EnemyCount1 = GetEnemyCount(600, BestWFarmPos)
		local EnemyCount2 = GetEnemyCount(400, WstartPos)
		if EnemyCount1 > EnemyCount2 then
			Control.CastSpell(HK_W)
		end	
	end
	
	if Menu.Clear.UseW:Value() and mana_ok and Ready(_W) and not wUsed() then
		local minions, count = GetMinionsAround(myHero.pos, 600)
		if count > 0 then
			local BestPos, MostHit = GetCircularAOEPos(minions, 260, Menu.Clear.WCount:Value())
			if BestPos then
				if Menu.Clear.Turret:Value() then
					if not IsUnderTurret(BestPos) then
						BestWFarmPos = BestPos
						WstartPos = myHero.pos
						Control.CastSpell(HK_W, BestPos)
					elseif AllyMinionUnderTower() then
						BestWFarmPos = BestPos
						WstartPos = myHero.pos
						Control.CastSpell(HK_W, BestPos)					
					end
				else
					BestWFarmPos = BestPos
					WstartPos = myHero.pos
					Control.CastSpell(HK_W, BestPos)				
				end	
			end	
		end	
	end
	
	if Menu.Clear.UseQ:Value() and mana_ok and Ready(_Q) then
		for i = 1, GameMinionCount() do
			local minion = GameMinion(i)
			if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) < 700 and IsValid(minion) then
				Control.CastSpell(HK_Q, minion)
			end	
		end
	end
end	

function JungleClear()
    for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
		
		if mana_ok and minion.team == TEAM_JUNGLE and myHero.pos:DistanceTo(minion.pos) < 700 and IsValid(minion) then
            
			if Menu.JClear.UseQ:Value() and Ready(_Q) then
                Control.CastSpell(HK_Q, minion)
            end
			
            if Menu.JClear.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) < 600 and not wUsed() then
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, minion.pos)	
            end
        end
    end
end

function LastHit()
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Last.Mana:Value() / 100
	
	if Menu.Last.WBack:Value() and wUsed() and BestWFarmPos then		
		local EnemyCount1 = GetEnemyCount(600, BestWFarmPos)
		local EnemyCount2 = GetEnemyCount(400, WstartPos)
		if EnemyCount1 > EnemyCount2 then
			Control.CastSpell(HK_W)
		end	
	end	
	
	if Menu.Last.UseW:Value() and mana_ok and Ready(_W) and not wUsed() then
		local minions, count = GetMinionsAround(myHero.pos, 600)
		if count > 0 then
			
			local BestPos, MostHit = GetCircularWKillPos(minions, 260, Menu.Last.WCount:Value())
			if BestPos then
				if Menu.Last.Turret:Value() then
					if not IsUnderTurret(BestPos) then
						BestWFarmPos = BestPos
						WstartPos = myHero.pos
						Control.CastSpell(HK_W, BestPos)
					elseif AllyMinionUnderTower() then
						BestWFarmPos = BestPos
						WstartPos = myHero.pos
						Control.CastSpell(HK_W, BestPos)					
					end
				else
					BestWFarmPos = BestPos
					WstartPos = myHero.pos
					Control.CastSpell(HK_W, BestPos)				
				end	
			end	
		end	
	end
	
	if Menu.Last.UseQ:Value() and mana_ok and Ready(_Q) then
		for i = 1, GameMinionCount() do
			local minion = GameMinion(i)
			if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) < 700 and IsValid(minion) then
				local QDmg = getdmg("Q", minion, myHero)
				if Menu.Last.AA:Value() then
					if QDmg > minion.health and myHero.pos:DistanceTo(minion.pos) > myHero.range then
						Control.CastSpell(HK_Q, minion)
					end
				else
					if QDmg > minion.health then
						Control.CastSpell(HK_Q, minion)
					end				
				end	
			end	
		end
	end
end

function CastE(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, EData, myHero)
		if pred.Hitchance >= Menu.Pred.PredE:Value()+1 and not myHero.pathing.isDashing then
			Control.CastSpell(HK_E, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) and not myHero.pathing.isDashing then
			Control.CastSpell(HK_E, pred.CastPos)
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 925, Speed = 1750, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) and not myHero.pathing.isDashing then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end	
	end
end

function CastR(skill, target)
	if Ready(_R) then
		if skill == "Q" and lastActivated == SpellQ then
			if myHero.pos:DistanceTo(target.pos) < 700 then
				Control.CastSpell(HK_R, target)
			end
		elseif skill == "W" and lastActivated == SpellW then
			if not wrUsed() and myHero.pos:DistanceTo(target.pos) < 850 then
				WRstartPos = myHero.pos
				Control.SetCursorPos(target.pos)
				Control.KeyDown(HK_R)
			end
		end
	end	
end


_G.LATENCY = 0.05
local AzirSoldiers = {}


local function ReadyToUse(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

local function EnoughMana(spells)
	if spells == QWER then
		return (myHero:GetSpellData(_Q).mana+myHero:GetSpellData(_W).mana+myHero:GetSpellData(_E).mana+myHero:GetSpellData(_R).mana) <= myHero.mana    
	elseif spells == WER then
		return (myHero:GetSpellData(_R).mana+myHero:GetSpellData(_W).mana+myHero:GetSpellData(_E).mana) <= myHero.mana	
	elseif spells == QER then
		return (myHero:GetSpellData(_Q).mana+myHero:GetSpellData(_R).mana+myHero:GetSpellData(_E).mana) <= myHero.mana	
	elseif spells == QWE then
		return (myHero:GetSpellData(_Q).mana+myHero:GetSpellData(_W).mana+myHero:GetSpellData(_E).mana) <= myHero.mana
	elseif spells == QW then
		return (myHero:GetSpellData(_Q).mana+myHero:GetSpellData(_W).mana) <= myHero.mana
	elseif spells == QE then
		return (myHero:GetSpellData(_Q).mana+myHero:GetSpellData(_E).mana) <= myHero.mana
	elseif spells == WE then
		return (myHero:GetSpellData(_W).mana+myHero:GetSpellData(_E).mana) <= myHero.mana
	end	
end

local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

local function GetDistance(pos1, pos2)
	return math.sqrt(GetDistanceSqr(pos1, pos2))
end

local function EnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

local function AllyHeroes()
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function GetEnemyTurrets()
	local _EnemyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        if turret.isEnemy and not turret.dead then
			TableInsert(_EnemyTurrets, turret)
		end
	end
	return _EnemyTurrets
end

local function GetAllyTurret()
	local _AllyTurrets = {}
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret.isAlly and not turret.dead then
			TableInsert(_AllyTurrets, turret)
		end
	end
	return _AllyTurrets		
end

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(EnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function GetAllyCount(range, pos)
    local pos = pos.pos
    local count = 0
    for i, hero in ipairs(AllyHeroes()) do
    local Range = range * range
        if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
        count = count + 1
        end
    end
    return count
end

local function IsUnderAllyTurret(unit)
	for i, turret in ipairs(GetAllyTurret()) do
        local range = (turret.boundingRadius + 775 + unit.boundingRadius / 2)
        if turret.pos:DistanceTo(unit.pos) < range then 
            return true
        end
    end
    return false
end

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurrets()) do
        local range = (turret.boundingRadius + 775 + unit.boundingRadius / 2)
        if not turret.dead and turret.pos:DistanceTo(unit.pos) < range then 
            return true
        end
    end
    return false
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointLine, pointSegment, isOnSegment
end 

local function GetPathNodes(unit)
	local nodes = {}
	TableInsert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			TableInsert(nodes, path)
		end
	end		
	return nodes
end

local function GetTargetMS(target)
	local ms = target.ms
	return ms
end

local function PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end


local function GetLineTargetCount(source, Pos, delay, speed, width)
	local Count = 0
	for i, unit in ipairs(EnemyHeroes()) do
		if unit and GetDistance(unit.pos, myHero.pos) <= 1000 and IsValid(unit) then
			local predictedPos = PredictUnitPosition(unit, delay+ GetDistance(source, unit.pos) / speed)
			local pointLine, proj1, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= width * width) then
				Count = Count + 1
			end
		end
	end
	return Count
end

local function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,Game.MinionCount() do
	local hero = Game.Minion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

local function NearestTower(unit, range)
	local pos = unit.pos
	local near = nil
	for i, turret in ipairs(GetAllyTurret()) do
		local TurretRange = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
		if GetDistance(pos, turret.pos) <= range and GetDistance(pos, turret.pos) > TurretRange and (not near or near and GetDistance(pos, turret.pos) < GetDistance(pos, near.pos)) then
			near = turret
		end
	end
	return near
end

local function NearestTower2(unit, range)
	local pos = unit.pos
	local near = nil
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
		if turret and turret.isAlly and GetDistance(pos, turret.pos) <= range and (not near or near and GetDistance(pos, turret.pos) < GetDistance(pos, near.pos)) then
			near = turret
		end
	end
	return near
end

local function NearestTower3(unit, range)
	local pos = unit.pos
	local near = nil
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
		if turret and turret.isEnemy and GetDistance(pos, turret.pos) <= range and (not near or near and GetDistance(pos, turret.pos) < GetDistance(pos, near.pos)) then
			near = turret
		end
	end
	return near
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

local function CountSoldiers()
    soldiers = 0
	for i = 1, #AzirSoldiers do
		local Soldier = AzirSoldiers[i]
        if Soldier and GetDistance(Soldier.pos, myHero.pos) < 1450 then
			soldiers = soldiers + 1
        end
    end
    return soldiers
end	

local function GetSoldiersNearEnemy()
    if CountSoldiers() > 0 then
		for i = 1, #AzirSoldiers do
			local Soldier = AzirSoldiers[i]
			for k, enemy in ipairs(EnemyHeroes()) do
				if GetDistance(myHero.pos, enemy.pos) < 1500 and GetDistance(Soldier.pos, enemy.pos) < 340 then
					return Soldier
				end
			end	
		end
	end	
    return nil
end	

local function EnemyHPPercent(range)
	local Heroes = {}
	local FoundUnit = nil
	local count = 0
	local chealth = 0
	local mHealth = 0
	local averageh = 0
	local averagem = 0
	for i, hero in ipairs(EnemyHeroes()) do
		if FoundUnit == nil then
			if hero and IsValid(hero) and GetDistance(myHero.pos, hero.pos) < range then
				TableInsert(Heroes, hero)
				chealth = chealth + hero.health
				mHealth = mHealth + hero.maxHealth
				count = count + 1
				FoundUnit = hero
			end
		else
			for k, SaveHero in pairs(Heroes) do
				if hero and SaveHero ~= hero and IsValid(hero) and GetDistance(myHero.pos, hero.pos) < range then
					TableInsert(Heroes, hero)
					chealth = chealth + hero.health
					mHealth = mHealth + hero.maxHealth
					count = count + 1
				end
			end
		end	
	end
	averageh = chealth / count
	averagem = mHealth / count
	return ((averageh / averagem) * 100) 	
end

local function AllyHPPercent(range)
	local Heroes = {}
	local FoundUnit = nil
	local count = 1
	local chealth = 0
	local mHealth = 0
	local averageh = 0
	local averagem = 0
	for i, hero in ipairs(AllyHeroes()) do
		if FoundUnit == nil then
			if hero and IsValid(hero) and GetDistance(myHero.pos, hero.pos) < range then
				TableInsert(Heroes, hero)
				chealth = chealth + hero.health
				mHealth = mHealth + hero.maxHealth
				count = count + 1
				FoundUnit = hero
			end
		else
			for k, SaveHero in pairs(Heroes) do
				if hero and SaveHero ~= hero and IsValid(hero) and GetDistance(myHero.pos, hero.pos) < range then
					TableInsert(Heroes, hero)
					chealth = chealth + hero.health
					mHealth = mHealth + hero.maxHealth
					count = count + 1				 
				end
			end
		end	
	end
	averageh = (chealth+myHero.health) / count
	averagem = (mHealth+myHero.maxHealth) / count	
	return ((averageh / averagem) * 100)
end

local function ECheck(unit)
	if GetAllyCount(2000, unit)+1 >= GetEnemyCount(2000, unit) then
		if AllyHPPercent(2000) - EnemyHPPercent(2000) > 30 then
		  return true
		end
		if EnemyHPPercent(2000) < AllyHPPercent(2000) and EnemyHPPercent(2000) < 50 then
		  return true
		end
	end
    return false
end

local function towerCheck(unit)
    if IsUnderTurret(unit) then
        if unit.health < getdmg("E", unit, myHero)+getdmg("AA", unit, myHero)*2 and myHero.health/myHero.maxHealth > 0.35 then
    		return true
    	else
    		return false
        end
    else
        return true
    end
end

local function SoldierDmg(unit)
	local LvL = myHero.levelData.lvl
	
	if LvL < 8 then
		return CalcMagicalDamage(myHero, unit, (58 + (2 * LvL)) + 0.6 * myHero.ap)
	elseif LvL < 12 then 
		return CalcMagicalDamage(myHero, unit, (35 + (5 * LvL)) + 0.6 * myHero.ap)
	else
		return CalcMagicalDamage(myHero, unit, ((10 * LvL) - 20) + 0.6 * myHero.ap)
	end
end

local function CalcAADmgSoldier(unit)
	local Damage = 0
	local SoldierCount = 0
	
	if CountSoldiers() > 0 then
		for i = 1, #AzirSoldiers do
			local Soldier = AzirSoldiers[i]	
			if GetDistance(Soldier.pos, unit.pos) < 340 then
				SoldierCount = SoldierCount + 1
			end	
		end	
	end
	
	if SoldierCount > 0 then
		local SDmg = SoldierDmg(unit)
		Damage = Damage + SDmg + ((SoldierCount - 1) * (SDmg * 0.25))
	end
	return Damage
end

local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25+ping, Radius = 35, Range = 740, Speed = 1600, Collision = false
}

local Q2Data =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25+ping, Radius = 35, Range = 900, Speed = 1600, Collision = false
}

local WData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25+ping, Radius = 315, Range = 500, Speed = math.huge, Collision = false
}

local QspellData = {speed = 1600, range = 740, delay = 0.25+ping, radius = 35, collision = {nil}, type = "linear"}
local Q2spellData = {speed = 1600, range = 900, delay = 0.25+ping, radius = 35, collision = {nil}, type = "linear"}
local WspellData = {speed = math.huge, range = 500, delay = 0.25+ping, radius = 315, collision = {nil}, type = "circular"}	
	
function LoadScript()                     
	
--MainMenu
Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
Menu:MenuElement({name = " ", drop = {"Version 0.03"}})
		
--Combo 
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseQ2", name = "Use[W]->[Q] if out of W range", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseE2", name = "[E] enemy is too close: increase distance", value = true})
	Menu.Combo:MenuElement({id = "UseE3", name = "[E] Flee: if Hp lower than...", value = true})
	Menu.Combo:MenuElement({id = "UseE3H", name = "[E] Flee: Azir Hp lower than -->", value = 20, min = 0, max = 100, step = 5, identifier = "%"})	
	
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
		Menu.Combo.Ult:MenuElement({type = MENU, id = "Pull", name = "Pull Settings"})
			Menu.Combo.Ult.Pull:MenuElement({id = "UseR", name = "[R] Pull if can Kill (FullDmg)", value = true})		
			
		Menu.Combo.Ult:MenuElement({type = MENU, id = "Push", name = "Push Settings"})
			Menu.Combo.Ult.Push:MenuElement({id = "UseR", name = "[R] Push if Azir low and enemy not killable", value = true})
			Menu.Combo.Ult.Push:MenuElement({id = "RHP", name = "[R] Push if Azir Hp lower than -->", value = 30, min = 0, max = 100, step = 5, identifier = "%"})
			Menu.Combo.Ult.Push:MenuElement({id = "UseR2", name = "[R] Safe Ally if low and enemy not killable", value = true})
			Menu.Combo.Ult.Push:MenuElement({id = "R2HP", name = "[R] Safe Ally: if Hp lower than -->", value = 30, min = 0, max = 100, step = 5, identifier = "%"})
		
--Harass		
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Mode"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseQ2", name = "Use[W]->[Q] if out of W range", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "Stop", name = "Save Soldier stacks [min 1 Soldier on Lane]", value = true})	

--Lane/JungleClear
Menu:MenuElement({type = MENU, id = "LaneClear", name = "Lane/Jungle Clear Mode"})
	Menu.LaneClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.LaneClear:MenuElement({id = "UseQ2", name = "[Q] only LastHit", value = true})	
	Menu.LaneClear:MenuElement({id = "UseW", name = "[W]", value = true})
		
		
--Prediction
Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})

--Insec
Menu:MenuElement({type = MENU, id = "Insec", name = "Insec Modes"})
	
	Menu.Insec:MenuElement({type = MENU, id = "Mode1", name = "Insec Mode 1 [Flee]"})	
		Menu.Insec.Mode1:MenuElement({name = " ", drop = {"W-E-Q to MousePos"}})
		Menu.Insec.Mode1:MenuElement({id = "Enable", name = "Insec HotKey", key = string.byte("A")})
	
	Menu.Insec:MenuElement({type = MENU, id = "Mode2", name = "Insec Mode 2"})	
		Menu.Insec.Mode2:MenuElement({name = " ", drop = {"W-E-Q-R Pull under AllyTurret if range > W.range"}})
		Menu.Insec.Mode2:MenuElement({name = " ", drop = {"W-E-R Pull under AllyTurret if range < W.range"}})		
		Menu.Insec.Mode2:MenuElement({id = "Enable", name = "Use Insec Pull under Turret ?", value = true})
		Menu.Insec.Mode2:MenuElement({id = "Mode", name = "AutoMode or ComboMode ?", value = 1, drop = {"Combo", "Auto"}})		
		Menu.Insec.Mode2:MenuElement({id = "Mode2", name = "Logic ?", value = 3, drop = {"W-E-Q-R Pull [LongRange]", "W-E-R Pull [ShortRange]", "Both"}})		

	Menu.Insec:MenuElement({type = MENU, id = "Mode3", name = "Insec Mode 3"})	
		Menu.Insec.Mode3:MenuElement({name = " ", drop = {"W-E-Q-R Pull to near Allies if range > W.range"}})
		Menu.Insec.Mode3:MenuElement({name = " ", drop = {"W-E-R Pull to near Allies if range < W.range"}})		
		Menu.Insec.Mode3:MenuElement({id = "Enable", name = "Use Insec Pull to Allies ?", value = true})
		Menu.Insec.Mode3:MenuElement({id = "Mode", name = "AutoMode or ComboMode ?", value = 1, drop = {"Combo", "Auto"}})
		Menu.Insec.Mode3:MenuElement({id = "Mode2", name = "Logic ?", value = 3, drop = {"W-E-Q-R Pull [LongRange]", "W-E-R Pull [ShortRange]", "Both"}})		
		Menu.Insec.Mode3:MenuElement({name = " ", drop = {"////////////////\\\\\\\\\\\\\\\\"}})		
		Menu.Insec.Mode3:MenuElement({name = " ", drop = {"Example Difference: [ +1 Ally or equal ]"}})
		Menu.Insec.Mode3:MenuElement({name = " ", drop = {"+1 or more allies or equal number of enemies"}})		
		Menu.Insec.Mode3:MenuElement({id = "Count", name = "Difference Ally/Enemy", value = 1, drop = {"+1 Ally or equal", "+2 Allies or equal", "+3 Allies or equal"}})		
		Menu.Insec.Mode3:MenuElement({id = "HP", name = "Min Azir and Ally Hp for count", value = 40, min = 0, max = 100, step = 5, identifier = "%"})	
		Menu.Insec.Mode3:MenuElement({id = "MyHP", name = "Block Insec if Azir Hp lower than -->", value = 30, min = 0, max = 100, step = 5, identifier = "%"})		

--Drawing 
Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	Menu.Drawing:MenuElement({id = "DrawSoldier", name = "Draw Soldier command Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end                                                 
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			Draw.Circle(myHero, 250, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			Draw.Circle(myHero, 740, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			Draw.Circle(myHero, 500, 1, Draw.Color(225, 225, 125, 10))
		end	
		
		if Menu.Drawing.DrawSoldier:Value() then		
			local Soldier = GetSoldiersNearEnemy()
			if Soldier then
				Draw.Circle(Soldier, 100, 1, Draw.Color(225, 50, 205, 50))
				if GetDistance(myHero.pos, Soldier.pos) <= 750 then
					Draw.Circle(myHero, 750, 1, Draw.Color(225, 50, 205, 50))
				else
					Draw.Circle(myHero, 750, 1, Draw.Color(225, 220, 20, 60))
				end
			end	
		end	
	end)	
end

local ReadyforInsec = false
local InsecStart = 0
local LastInsec = 0

function Tick()					
	RemoveSoldiers()

	local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid and currSpell.name == "AzirWSpawnSoldier" then	
		SearchSoldiers()
	end	

	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.Insec.Mode2.Enable:Value() then 
			if Menu.Insec.Mode2.Mode:Value() == 1 then
				InsecAllyTurret()
			end
		else
			if Menu.Insec.Mode3.Enable:Value() and Menu.Insec.Mode3.Mode:Value() == 1 then
				InsecAllies()
			end		
		end	
	elseif Mode == "Harass" then
		Harass()	
	elseif Mode == "Clear" then
		Clear()
	end
	
	if ReadyforInsec and Mode ~= "Combo" then
		ReadyforInsec = false
	end
	
	if Menu.Insec.Mode2.Enable:Value() then 
		if Menu.Insec.Mode2.Mode:Value() == 2 then
			InsecAllyTurret()
		end
	else
		if Menu.Insec.Mode3.Enable:Value() and Menu.Insec.Mode3.Mode:Value() == 2 then
			InsecAllies()
		end		
	end			
	
	if Menu.Insec.Mode1.Enable:Value() then
		InsecKey()
	end
end

function SearchSoldiers()
	for i = 1,GameObjectCount() do
		local Object = GameObject(i)	
		if Object and GetDistance(myHero.pos, Object.pos) <= 1000 and Object.name == "AzirSoldier" then
			TableInsert(AzirSoldiers, Object)
			--print("Search")
		end
	end	
end

function RemoveSoldiers()
	for i = 1, #AzirSoldiers do
		local Soldier = AzirSoldiers[i]
		if Soldier and (Soldier.health == 0 or Soldier.name ~= "AzirSoldier") then
			TableRemove(AzirSoldiers, i)
			--print("Remove")
		end
	end	
end

function Combo()
	local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid and currSpell.name == "AzirR" then return end
	
	local target = GetTarget(2000)     	
	if target == nil then return end
	if IsValid(target) then

		local Behind = myHero.pos:Lerp(target.pos, -100 / target.pos:DistanceTo(myHero.pos))
		local QDmg = ((CountSoldiers() > 0 or Ready(_W)) and Ready(_Q) and getdmg("Q", target, myHero)) or 0
		local AASDmg = CountSoldiers() > 0 and (Ready(_Q) and SoldierDmg(target)*2 or Ready(_W) and SoldierDmg(target)*2) or 0
		local AAEDmg = Ready(_E) and (getdmg("AA", target, myHero)*2 + getdmg("E", target, myHero)) or 0
		local RDmg = Ready(_R) and getdmg("R", target, myHero) or 0
		local FullDmg = QDmg+AASDmg+AAEDmg+RDmg			
		
		if Ready(_W) and Menu.Combo.UseW:Value() then 
			if GetDistance(myHero.pos, Behind) < 500 then
				if Behind then
					Control.CastSpell(HK_W, Behind)					
				end
			
			elseif GetDistance(myHero.pos, target.pos) < (500 + (340 / 2)) then 
				local pos = GetPredW(target)
				if pos then
					Control.CastSpell(HK_W, pos)
				end
				
			else
				if Menu.Combo.UseQ2:Value() and Ready(_Q) and EnoughMana(QW) and GetDistance(myHero.pos, target.pos) < (740 + (340 / 2)) then
					local pos = GetPredQ2(target)
					if pos then
						Control.CastSpell(HK_W, pos)
						DelayAction(function()
							Control.CastSpell(HK_Q, pos)
						end,0.25+ping)
					end
				end	
			end
		end	

		if CountSoldiers() > 0 then
			for i = 1, #AzirSoldiers do
				local Soldier = AzirSoldiers[i]					
				
				if Menu.Combo.UseQ:Value() and Ready(_Q) then
					if GetDistance(myHero.pos, target.pos) < (740 + (340 / 2)) and target.health < getdmg("Q", target, myHero) + CalcAADmgSoldier(target) then
						local pos = GetPredQ2(target)
						if pos then
							Control.CastSpell(HK_Q, pos)
						end													
					else
						if GetDistance(Soldier.pos, target.pos) > 340 and GetDistance(myHero.pos, target.pos) < (740 + (340 / 2)) then
							local pos = GetPredQ2(target)
							if pos then
								Control.CastSpell(HK_Q, pos)
							end
						end
					end	
				end
				
				if Menu.Combo.UseQ:Value() and Menu.Combo.UseE:Value() then
					if Ready(_Q) and Ready(_E) and EnoughMana(QE) then
						if GetDistance(Soldier.pos, target.pos) > 340 and GetDistance(myHero.pos, target.pos) > 740 then
							if GetDistance(Soldier.pos, target.pos) < 740 and GetDistance(Soldier.pos, myHero.pos) < 1100 then
								if ECheck(target) and towerCheck(target) then
									Control.CastSpell(HK_E)
									local pos = GetPredQ(target)
									if pos then
										Control.CastSpell(HK_Q, pos)
									end
								end
							end
						end
					end
				end

				if Menu.Combo.UseE:Value() and Ready(_E) then
					if GetDistance(Soldier.pos, target.pos) < 500 and GetDistance(Soldier.pos, target.pos) > 340 and GetDistance(myHero.pos, Soldier.pos) < 1100 then
						if ECheck(target) and towerCheck(target) then
							Control.CastSpell(HK_E)
						end
					end
					
					if Menu.Combo.UseE2:Value() then
						for i, enemy in ipairs(EnemyHeroes()) do
							if enemy and IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) < (myHero.boundingRadius + 200) and GetDistance(Soldier.pos, myHero.pos) < 1100 and GetDistance(myHero.pos, enemy.pos) < GetDistance(enemy.pos, Soldier.pos) then
								if GetAllyCount(525, myHero) <= 1 and myHero.health < enemy.health then
									Control.CastSpell(HK_E)
								end
							end
						end
					end	
										
					if GetDistance(myHero.pos, Soldier.pos) < 1100 then
						if ECheck(target) and towerCheck(target) then
							local y, x = VectorPointProjectionOnLineSegment(myHero.pos, Soldier.pos, target.pos)
							if y and GetDistance(target.pos, x) < (60 ^ 2) then             
								Control.CastSpell(HK_E)
							end
						end
					end
					
					if Menu.Combo.UseE3:Value() then					
						if myHero.health/myHero.maxHealth <= Menu.Combo.UseE3H:Value()/100 and GetDistance(myHero.pos, Soldier.pos) < 1100 and GetDistance(myHero.pos, target.pos) < GetDistance(target.pos, Soldier.pos) then
							Control.CastSpell(HK_E)
						end
					end	
				end
			end
		end
		
		if Menu.Combo.Ult.Pull.UseR:Value() and not IsUnderAllyTurret(target) then						
			if Ready(_R) and GetDistance(myHero.pos, target.pos) < 300 then
				if FullDmg > target.health then
					local NearestTower = NearestTower2(target, 99999)
					local RPos = Vector(target.pos) + (Vector(NearestTower.pos) - Vector(target.pos)): Normalized() * 400
					Control.CastSpell(HK_R, RPos)
				elseif RDmg > target.health or RDmg+QDmg > target.health or RDmg+AASDmg > target.health or RDmg+AAEDmg > target.health then
					local NearestTower = NearestTower2(target, 99999)
					local RPos = Vector(target.pos) + (Vector(NearestTower.pos) - Vector(target.pos)): Normalized() * 400
					Control.CastSpell(HK_R, RPos)
				else
					if ECheck(target) then
						local NearestTower = NearestTower2(target, 99999)
						local RPos = Vector(target.pos) + (Vector(NearestTower.pos) - Vector(target.pos)): Normalized() * 400
						Control.CastSpell(HK_R, RPos)					
					end
				end	
			end
			
			if CountSoldiers() > 0 then
				if Ready(_R) and GetDistance(myHero.pos, target.pos) < 740 and Ready(_Q) and Ready(_E) and EnoughMana(QER) then
					if FullDmg > target.health then					
						local pos = GetPredQ(target)
						if pos then
							Control.CastSpell(HK_Q, pos)
							DelayAction(function()
								Control.CastSpell(HK_E)
							end,0.25+ping)
						end	
					end
				end						
			else
				if Ready(_R) and GetDistance(myHero.pos, target.pos) < 500 and Ready(_W) and Ready(_E) and EnoughMana(WER) then
					if FullDmg > target.health then
						local pos = GetPredW(target)
						if pos then
							Control.CastSpell(HK_W, pos)
							DelayAction(function()
								Control.CastSpell(HK_E)
							end,0.25+ping)								
						end
					end
				else
					if Ready(_R) and GetDistance(myHero.pos, target.pos) < 1000 and Ready(_Q) and Ready(_W) and Ready(_E) and EnoughMana(QWER) then
						if AASDmg+AAEDmg+RDmg > target.health then
							Control.CastSpell(HK_W, target.pos)
							DelayAction(function()
								Control.CastSpell(HK_E)
								Control.CastSpell(HK_Q, target.pos)
							end,0.25+ping)								
						end
					end	
				end
			end	
		end
		
		if Menu.Combo.Ult.Push.UseR:Value() and Ready(_R) then		
			if myHero.health/myHero.maxHealth < Menu.Combo.Ult.Push.RHP:Value() / 100 then
				if GetDistance(myHero.pos, target.pos) < 400 and not ECheck(target) then
					local NearestTurret = NearestTower3(target, 99999)
					local UltPos = Vector(target.pos) + (Vector(NearestTurret.pos) - Vector(target.pos)): Normalized() * 600					
					Control.CastSpell(HK_R, UltPos)
				end
			end	
		end
		 
		if Menu.Combo.Ult.Push.UseR2:Value() and Ready(_R) then		
			for i, Ally in ipairs(AllyHeroes()) do
				if Ally and GetDistance(myHero.pos, Ally.pos) < 1000 and IsValid(Ally) and Ally.health/Ally.maxHealth < Menu.Combo.Ult.Push.R2HP:Value() / 100 and GetDistance(target.pos, Ally.pos) < 1000 and not ECheck(target) then
					local NearestTurret = NearestTower3(target, 99999)
					local UltPos = Vector(target.pos) + (Vector(NearestTurret.pos) - Vector(target.pos)): Normalized() * 600
					if GetDistance(myHero.pos, target.pos) > 300 then
						if GetDistance(myHero.pos, target.pos) > 750 and GetDistance(myHero.pos, target.pos) < 1100 and Ready(_Q) and Ready(_W) and Ready(_E) and EnoughMana(QWER) then
							ReadyforInsec = true
							InsecWEQ(target.pos, UltPos)
						else
							if GetDistance(myHero.pos, target.pos) < 700 and Ready(_W) and Ready(_E) and EnoughMana(WER) then
								ReadyforInsec = true
								InsecWE(target.pos, UltPos)
							end
						end
					else
						Control.CastSpell(HK_R, UltPos)
					end
				end
			end	
		end		
	end		
end

function Harass()
	local target = GetTarget(1200)     	
	if target == nil then return end
	if IsValid(target) then

		local Behind = myHero.pos:Lerp(target.pos, -100 / target.pos:DistanceTo(myHero.pos))
		
		if CountSoldiers() > 0 then 
			for i = 1, #AzirSoldiers do
				local Soldier = AzirSoldiers[i]			
				if Menu.Harass.Stop:Value() then	
					if Soldier then 
						if GetDistance(Soldier.pos, target.pos) < 340 then
							return
						else 
							if GetDistance(myHero.pos, target.pos) < (740 + (340 / 2)) and Menu.Harass.UseQ:Value() and Ready(_Q) then
								local pos = GetPredQ2(target)
								if pos then
									Control.CastSpell(HK_Q, pos)
								end								
							end
						end
					end							
				else	
					if Ready(_W) and Menu.Harass.UseW:Value() then 
						if GetDistance(myHero.pos, Behind) < 500 then
							if Behind then
								Control.CastSpell(HK_W, Behind)					
							end
						
						elseif GetDistance(myHero.pos, target.pos) < (500 + (340 / 2)) then 
							local pos = GetPredW(target)
							if pos then
								Control.CastSpell(HK_W, pos)
							end
							
						else
							if Menu.Harass.UseQ2:Value() and Ready(_Q) and EnoughMana(QW) and GetDistance(myHero.pos, target.pos) < (740 + (340 / 2)) then
								local pos = GetPredQ2(target)
								if pos then
									Control.CastSpell(HK_W, pos)
									DelayAction(function()
										Control.CastSpell(HK_Q, pos)
									end,0.25+ping)
								end
							end	
						end
					end

					if Menu.Harass.UseQ:Value() and Ready(_Q) then
						if GetDistance(Soldier.pos, target.pos) > 340 and GetDistance(myHero.pos, target.pos) < (740 + (340 / 2)) then
							local pos = GetPredQ2(target)
							if pos then
								Control.CastSpell(HK_Q, pos)
							end
						end
					end				
				end
			end	
		else		
			if Ready(_W) and Menu.Harass.UseW:Value() then 
				if GetDistance(myHero.pos, Behind) < 500 then
					if Behind then
						Control.CastSpell(HK_W, Behind)					
					end
				
				elseif GetDistance(myHero.pos, target.pos) < (500 + (340 / 2)) then 
					local pos = GetPredW(target)
					if pos then
						Control.CastSpell(HK_W, pos)
					end
					
				else
					if Menu.Harass.UseQ2:Value() and Ready(_Q) and EnoughMana(QW) and GetDistance(myHero.pos, target.pos) < (740 + (340 / 2)) then
						local pos = GetPredQ2(target)
						if pos then
							Control.CastSpell(HK_W, pos)
							DelayAction(function()
								Control.CastSpell(HK_Q, pos)
							end,0.25+ping)
						end
					end	
				end
			end		
		end	
	end	
end

function Clear()
	if Menu.LaneClear.UseQ:Value() and Ready(_Q) or Menu.LaneClear.UseW:Value() and Ready(_W) then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion.team ~= TEAM_ALLY and GetDistance(myHero.pos, minion.pos) <= 740 and IsValid(minion) then

				if Menu.LaneClear.UseQ:Value() and Ready(_Q) and CountSoldiers() > 0 then
					if Menu.LaneClear.UseQ2:Value() then
						if getdmg("Q", minion, myHero) > minion.health then
							Control.CastSpell(HK_Q, minion.pos)
						end
					else
						Control.CastSpell(HK_Q, minion.pos)
					end
				end

				if Menu.LaneClear.UseW:Value() and Ready(_W) and GetDistance(myHero.pos, minion.pos) <= 500 then
					Control.CastSpell(HK_W, minion.pos)
				end				
			end	
		end	
	end		
end

function InsecKey()
    if ReadyToUse(_Q) and Ready(_W) and ReadyToUse(_E) and EnoughMana(QWE) then       		
		ReadyforInsec = true	
	end	
		
	if ReadyforInsec then
		local cursorPos = mousePos
		local wPos = myHero.pos + (cursorPos - myHero.pos):Normalized()*550
		local qPos = myHero.pos + (cursorPos - myHero.pos):Normalized()*1250
		--Draw.Circle(qPos, 50, 1, Draw.Color(255, 225, 255, 10))
		if Ready(_W) then
			Control.CastSpell(HK_W, wPos) 
		end
		
		if Ready(_E) then 
			Control.CastSpell(HK_E)               
		end
		
		if Ready(_Q) and myHero:GetSpellData(_E).currentCd > 0 then	
			Control.CastSpell(HK_Q, qPos)
			DelayAction(function()              
				ReadyforInsec = false
			end,0.25+ping)    
		end
	end	
end

function InsecWEQ(wPos, UltPos)
	LastInsec = Game.Timer()
	--print ("INSEC W-E-Q")
	if GetDistance(myHero.pos, wPos) < 300 then
		Control.CastSpell(HK_R, UltPos)		
		DelayAction(function()              
			ReadyforInsec = false
		end,0.5+ping)    
	end		
		
	if Ready(_W) then
		Control.CastSpell(HK_W, wPos) 
	end
	DelayAction(function()	
		if Ready(_E) then 
			Control.CastSpell(HK_E)  	
		end 
	end,0.1+ping)	
	DelayAction(function()
		if Ready(_Q) then		
			Control.CastSpell(HK_Q, wPos)
		end
	end,0.15+ping)	
end

function InsecWE(wPos, UltPos)
	LastInsec = Game.Timer()
	--print ("INSEC W-E")
	
	if Ready(_W) then
		Control.CastSpell(HK_W, wPos) 
	end
	
	if Ready(_E) then	
		Control.CastSpell(HK_E)
	end

	if GetDistance(myHero.pos, wPos) <= 300 then
		Control.CastSpell(HK_R, UltPos)		
		DelayAction(function()              
			ReadyforInsec = false
		end,0.3+ping)    
	end	
end

function BestTurretTarget()
	local Target, Count, UltPos = nil, 0, nil	
	local RRadius = 280 + (50 * myHero:GetSpellData(_R).level)
	for i, unit in ipairs(EnemyHeroes()) do
		if Target == nil then
			if unit and GetDistance(myHero.pos, unit.pos) <= 1500 and IsValid(unit) then
				local AllyTurret = NearestTower(unit, 1290)
				if AllyTurret and GetDistance(AllyTurret.pos, myHero.pos) <= 3000 then
					local MidPos = Vector(unit.pos)	
					local MidPos1 = MidPos-(MidPos-Vector(AllyTurret.pos)):Normalized():Perpendicular()*RRadius	
					local MidPos2 = MidPos-(MidPos-Vector(AllyTurret.pos)):Normalized():Perpendicular2()*RRadius				
					local Number = GetLineTargetCount(MidPos1, MidPos2, 0.3, 1400, 300)
					if Number > Count then 
						Target = MidPos
						Count = Number
						UltPos = Vector(unit.pos) + (Vector(AllyTurret.pos) - Vector(unit.pos)): Normalized() * 400	
					end				
				end	
			end
		else
			if unit and unit ~= Target and GetDistance(myHero.pos, unit.pos) <= 1500 and IsValid(unit) then
				local AllyTurret = NearestTower(unit, 1290)
				if AllyTurret and GetDistance(AllyTurret.pos, myHero.pos) <= 3000 then
					local MidPos = Vector(unit.pos)	
					local MidPos1 = MidPos-(MidPos-Vector(AllyTurret.pos)):Normalized():Perpendicular()*RRadius	
					local MidPos2 = MidPos-(MidPos-Vector(AllyTurret.pos)):Normalized():Perpendicular2()*RRadius									
					local Number = GetLineTargetCount(MidPos1, MidPos2, 0.3, 1400, 300)
					if Number > Count then 
						Target = MidPos
						Count = Number
						UltPos = Vector(unit.pos) + (Vector(AllyTurret.pos) - Vector(unit.pos)): Normalized() * 400
					end				
				end	
			end		
		end	
	end
	return Target, Count, UltPos	
end

function NearestAlly(unit, range)
	local pos = unit.pos
	local near = nil
	for i, hero in ipairs(AllyHeroes()) do
		local HealthOK = hero.health/hero.maxHealth >= Menu.Insec.Mode3.HP:Value() / 100
		if GetDistance(pos, hero.pos) <= range and HealthOK and not IsUnderTurret(hero) and (not near or near and GetDistance(pos, hero.pos) < GetDistance(pos, near.pos)) then
			near = hero
		end
	end
	return near
end

function GetAllyCount(range, pos)
    local pos = pos.pos
    local count = 0
    for i, hero in ipairs(AllyHeroes()) do
    local Range = range * range
    local HealthOK = hero.health/hero.maxHealth >= Menu.Insec.Mode3.HP:Value() / 100    
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) and HealthOK then
        count = count + 1
        end
    end
    return count
end

function BestAllyTarget()
	local Target, Target2, Count, UltPos = nil, 0, nil
	local RRadius = 280 + (50 * myHero:GetSpellData(_R).level)
	for i, unit in ipairs(EnemyHeroes()) do
		if Target == nil then
			if unit and GetDistance(myHero.pos, unit.pos) <= 1500 and IsValid(unit) and not IsUnderTurret(unit) then
				local Ally = NearestAlly(unit, 1290)
				if Ally and GetDistance(Ally.pos, myHero.pos) <= 2500 then
					local MidPos = Vector(unit.pos)	
					local MidPos1 = MidPos-(MidPos-Vector(Ally.pos)):Normalized():Perpendicular()*RRadius	
					local MidPos2 = MidPos-(MidPos-Vector(Ally.pos)):Normalized():Perpendicular2()*RRadius								
					local Number = GetLineTargetCount(MidPos1, MidPos2, 0.3, 1400, 300)
					if Number > 0  then 
						Target = MidPos
						Target2 = Ally
						Count = Number
						UltPos = Vector(unit.pos) + (Vector(Ally.pos) - Vector(unit.pos)): Normalized() * 600	
					end				
				end	
			end
		else
			if unit and unit ~= Target and GetDistance(myHero.pos, unit.pos) <= 1500 and IsValid(unit) then
				local Ally = NearestAlly(unit, 1290)
				if Ally and GetDistance(Ally.pos, myHero.pos) <= 2500 then
					local MidPos = Vector(unit.pos)	
					local MidPos1 = MidPos-(MidPos-Vector(Ally.pos)):Normalized():Perpendicular()*RRadius	
					local MidPos2 = MidPos-(MidPos-Vector(Ally.pos)):Normalized():Perpendicular2()*RRadius									
					local Number = GetLineTargetCount(MidPos1, MidPos2, 0.3, 1400, 300)
					if Number > Count then 
						Target = MidPos
						Target2 = Ally
						Count = Number
						UltPos = Vector(unit.pos) + (Vector(Ally.pos) - Vector(unit.pos)): Normalized() * 600
					end				
				end	
			end		
		end	
	end
	return Target, Target2, Count, UltPos	
end

function InsecAllyTurret()	
	if Ready(_R) and ReadyToUse(_Q) and Ready(_W) and ReadyToUse(_E) and EnoughMana(QWER) then					
		ReadyforInsec = true
	end		
	local target, count, UltPos = BestTurretTarget()
	if target and count >= 1 and ReadyforInsec then
		if GetDistance(myHero.pos, target) > 750 and (Menu.Insec.Mode2.Mode2:Value() == 1 or Menu.Insec.Mode2.Mode2:Value() == 3) then 
			InsecWEQ(target, UltPos)
		elseif Game.Timer() - LastInsec > 0.9 and (Menu.Insec.Mode2.Mode2:Value() == 2 or Menu.Insec.Mode2.Mode2:Value() == 3) and GetDistance(myHero.pos, target) < 700 then
			InsecWE(target, UltPos)							
		end
	else
		if Menu.Insec.Mode2.Enable:Value() then
			InsecAllies()
		end	
	end				
end	

function InsecAllies()	
	if myHero.health/myHero.maxHealth >= Menu.Insec.Mode3.MyHP:Value() / 100 then	
		local myCount = 0
		local target, ally, count, UltPos = BestAllyTarget()		
		if target and count >= 1 and ReadyforInsec then
			if myHero.health/myHero.maxHealth >= Menu.Insec.Mode3.HP:Value() / 100 then
				myCount = 1
			else
				myCount = 0
			end

			local AllyCount = GetAllyCount(1000, ally)
			local MenuCount = Menu.Insec.Mode3.Count:Value()			
			if ((MenuCount*count)/(AllyCount+myCount)) <= MenuCount then 
				if GetDistance(myHero.pos, target) <= 300 then
					Control.CastSpell(HK_R, UltPos)
				end

				if GetDistance(myHero.pos, target) > 750 and (Menu.Insec.Mode3.Mode2:Value() == 1 or Menu.Insec.Mode3.Mode2:Value() == 3) then 
					InsecWEQ(target, UltPos)
				elseif (Menu.Insec.Mode3.Mode2:Value() == 2 or Menu.Insec.Mode3.Mode2:Value() == 3) and GetDistance(myHero.pos, target) < 700 then
					InsecWE(target, UltPos)					
				end
			else
				ReadyforInsec = false
				if not ReadyforInsec and Game.Timer() - LastInsec > 0.9 then
					Combo()
				end					
			end
		else
			ReadyforInsec = false
			if not ReadyforInsec and Game.Timer() - LastInsec > 0.9 then
				Combo()
			end				
		end	
	else
		ReadyforInsec = false
		if not ReadyforInsec and Game.Timer() - LastInsec > 0.9 then
			Combo()
		end		
	end	
end

function GetPredW(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
			return pred.CastPosition
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
			return pred.CastPos
		end
	else
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25+ping, Radius = 315, Range = 500, Speed = math.huge, Collision = false})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value()+1) then
			return WPrediction.CastPosition
		end		
	end	
end

function GetPredQ(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, Q2Data, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
			return pred.CastPosition
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, Q2spellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
			return pred.CastPos
		end
	else
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25+ping, Radius = 35, Range = 900, Speed = 1600, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then
			return QPrediction.CastPosition
		end		
	end
end

function GetPredQ2(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, QData, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
			return pred.CastPosition
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
			return pred.CastPos
		end
	else
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25+ping, Radius = 35, Range = 740, Speed = 1600, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then
			return QPrediction.CastPosition
		end		
	end
end

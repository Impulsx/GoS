local Heroes = {"Irelia"}

if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"


----------------------------------------------------
--|                    Checks                    |--
----------------------------------------------------

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	print("gamsteronPred. installed Press 2x F6")
	return
end

if not FileExist(COMMON_PATH .. "PremiumPrediction.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/Ark223/GoS-Scripts/master/PremiumPrediction.lua", COMMON_PATH .. "PremiumPrediction.lua", function() end)
	print("PremiumPred. installed Press 2x F6")
	return
end

if not FileExist(COMMON_PATH .. "GGPrediction.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGPrediction.lua", COMMON_PATH .. "GGPrediction.lua", function() end)
	print("GGPrediction installed Press 2x F6")
	return
end

local InfoBoxPos = false
if FileExist(COMMON_PATH .. "PussyBoxPos.lua") then
	InfoBoxPos = true
	require "PussyBoxPos"
end



----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

local DrawSaved = false
local LoadPos = false
local Down = false
local UnLockBox = false

local DrawTime = false
local checkCount = 0
local heroes = false
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local foundAUnit = false
local _movementHistory = {}
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local wClock = 0
local _OnVision = {}
local sqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
local GameTimer = Game.Timer
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local Orb
local DrawRect = Draw.Rect
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local ControlSetCursorPos = Control.SetCursorPos
local ControlKeyUp = Control.KeyUp
local ControlKeyDown = Control.KeyDown
local GameCanUseSpell = Game.CanUseSpell
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local GameIsChatOpen = Game.IsChatOpen
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}

function LoadUnits()
	for i = 1, GameHeroCount() do
		local unit = GameHero(i); Units[i] = {unit = unit, spell = nil}
		if unit.team ~= myHero.team then TableInsert(Enemies, unit)
		elseif unit.team == myHero.team and unit ~= myHero then TableInsert(Allies, unit) end
	end
	for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i)
		if turret and turret.isEnemy then TableInsert(Turrets, turret) end
	end
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function IsValidCrap(unit)
    if (unit and unit.isTargetable and unit.dead == false) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end

local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

local function GetDistance(pos1, pos2)
	return sqrt(GetDistanceSqr(pos1, pos2))
end

local function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local function DistanceSquared(p1, p2)
	local dx, dy = p2.x - p1.x, p2.y - p1.y
	--print(math.floor((dx * dx + dy * dy)/10000))
	return math.floor((dx * dx + dy * dy)/10000)
end

function GetTarget(range)
	local EnemyHeroes = _G.SDK.ObjectManager:GetEnemyHeroes(range, false)
    local target = _G.SDK.TargetSelector:GetTarget(EnemyHeroes)

    return target
end

function GetMode()
    if _G.SDK then
        return

		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo"
		or
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] and "Flee"
        or
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass"
        or
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "LaneClear"
        or
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] and "LaneClear"
        or
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] and "LastHit"
        or nil

	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetMode()
	end
	return nil
end

local castSpell = {state = 0, tick = GetTickCount(), casting = 500, mouse = mousePos}
local function CastSpell(spell,pos,delay)
local delay = delay or 250
local ticker = GetTickCount()

	if castSpell.state == 0 and ticker - castSpell.casting > delay + Game.Latency() and pos.pos:ToScreen().onScreen then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() and Game.Timer() - myHero:GetSpellData(_Q).castTime > delay/1000 then
			Control.CastSpell(spell, pos)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					castSpell.state = 0
				end
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			castSpell.state = 0
		end
	end
end

local function SetAttack(bool)
	if _G.EOWLoaded then
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetAttack(bool)
	else
		GOS.BlockAttack = not bool
	end

end

local function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetMovement(bool)
	else
		GOS.BlockMovement = not bool
	end
end

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.team ~= myHero.team then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local function GetEnemyTurret()
	local _EnemyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
		if turret.isEnemy and GetDistance(myHero.pos, turret.pos) < 1500 and not turret.dead then
			TableInsert(_EnemyTurrets, turret)
		end
	end
	return _EnemyTurrets
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

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if not turret.dead then
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

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then
			return true
		end
	end
	return false
end

local function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then
			return buff
		end
	end
	return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

local function IsRecalling(unit)
	local buff = GetBuffData(unit, "recall")
	if buff and buff.duration > 0 then
		return true, GameTimer() - buff.startTime
	end
    return false
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.type == 10 or buff.type == 22 or buff.type == 8 ) and buff.count > 0 then
			return true
		end
	end
	return false
end

local function ISMarked(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		local Range = range*range
		if target and GetDistanceSqr(myHero.pos, target.pos) <= Range and IsValid(target) and HasBuff(target, "ireliamark") then
			count = count + 1
		end
	end
	if count > 0 then
		return true
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
	return pointSegment, pointLine, isOnSegment
end

local function OnVision(unit)
	_OnVision[unit.networkID] = _OnVision[unit.networkID] == nil and {state = unit.visible, tick = GetTickCount(), pos = unit.pos} or _OnVision[unit.networkID]
	if _OnVision[unit.networkID].state == true and not unit.visible then
		_OnVision[unit.networkID].state = false
		_OnVision[unit.networkID].tick = GetTickCount()
	end
	if _OnVision[unit.networkID].state == false and unit.visible then
		_OnVision[unit.networkID].state = true
		_OnVision[unit.networkID].tick = GetTickCount()
	end
	return _OnVision[unit.networkID]
end

local _OnWaypoint = {}
local function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = GameTimer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = GameTimer()}
			DelayAction(function()
				local time = (GameTimer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(GameTimer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(GameTimer() - _OnWaypoint[unit.networkID].time)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end

local function GetPred(unit,speed,delay)
	local speed = speed or MathHuge
	local delay = delay or 0.25
	local unitSpeed = unit.ms
	if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
	if OnVision(unit).state == false then
		local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
		local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
		if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
		return predPos
	else
		if unitSpeed > unit.ms then
			local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		elseif IsImmobileTarget(unit) then
			return unit.pos
		else
			return unit:GetPrediction(speed,delay)
		end
	end
end

local function CalculateCollisionTime(startPos, endPos, unitPos, startTime, speed, delay, origin)
	local pos = startPos:Extended(endPos, speed * (GameTimer() - delay - startTime))
	return GetDistance(unitPos, pos) / speed
end

local function CalculateEndPos(startPos, placementPos, unitPos, range, radius, collision, type)
	local range = range or 3000; local endPos = startPos:Extended(placementPos, range)
	if type == "circular" or type == "rectangular" then
		if range > 0 then if GetDistance(unitPos, placementPos) < range then endPos = placementPos end
		else endPos = unitPos end
	elseif collision then
		for i = 1, GameMinionCount() do
			local minion = GameMinion(i)
			if minion and minion.team == myHero.team and minion.alive and GetDistance(minion.pos, startPos) < range then
				local col = VectorPointProjectionOnLineSegment(startPos, placementPos, minion.pos)
				if col and GetDistance(col, minion.pos) < (radius + minion.boundingRadius / 2) then
					range = GetDistance(startPos, col); endPos = startPos:Extended(placementPos, range); break
				end
			end
		end
	end
	return endPos, range
end

local function GetPathNodes(unit)
	local nodes = {}
	TableInsert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			local path = unit:GetPath(i)
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
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) then

			local predictedPos = PredictUnitPosition(minion, delay+ GetDistance(source, minion.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (minion.boundingRadius + width) * (minion.boundingRadius + width)) then
				Count = Count + 1
			end
		end
	end
	return Count
end

local function CheckDmgItems(itemID)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
    for _, j in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}) do
        if myHero:GetItemData(j).itemID == itemID then return j end
    end
    return nil
end

local function CheckHPPred(unit)
local ms = myHero.ms
local speed = (1500+ms)
local range = GetDistance(myHero.pos, unit.pos)/(1500+ms)
local DashTime = range / speed
	if _G.SDK and _G.SDK.Orbwalker then
		return _G.SDK.HealthPrediction:GetPrediction(unit, DashTime)
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetHealthPrediction(unit, DashTime)
	end
end

local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

local function MyHeroNotReady()
    return myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero)
end

local function ActiveModes()
	local Mode = GetMode()
	if Mode == "Combo" or
	   Mode == "Harass" or
	   Mode == "Clear" or
	   Mode == "LastHit" then
	   return true
	end
	return false
end

local function CalcExtraDmg2(unit)
	local total = 0
	local Passive = HasBuff(myHero, "ireliapassivestacksmax")								--Irelia Passive

	local BladeKing = CheckDmgItems(3153)													--Blade of the ruined King

	local Divine = CheckDmgItems(6632)														--Divine Sunderer
	local Sheen = CheckDmgItems(3057)														--Sheen
	local Black = CheckDmgItems(3071) 														--Black Cleaver
	local Trinity = CheckDmgItems(3078)														--Trinity Force
	local Titanic = CheckDmgItems(3748)														--T.Hydra

	local LvL = myHero.levelData.lvl

	if Passive then
		total = total + CalcDamage(myHero, unit, 2, (7+ (3 * LvL)) + 0.20 * myHero.bonusDamage)
	end

	if BladeKing then

			if unit.health*0.1 > 40 then
				total = total + CalcDamage(myHero, unit, 1, 40)
			else
				total = total + CalcDamage(myHero, unit, 1, (unit.health*0.1))
			end


	end



	if Titanic and myHero:GetSpellData(Titanic).currentCd == 0 then
		total = total + CalcDamage(myHero, unit, 1, (myHero.maxHealth*0.01) + (5+myHero.maxHealth*0.015))
	end

	if Sheen and myHero:GetSpellData(Sheen).currentCd == 0 then
		total = total + CalcDamage(myHero, unit, 1, myHero.baseDamage)
	end

	if Divine and myHero:GetSpellData(Divine).currentCd == 0 then

			if unit.maxHealth*0.1 < 1.5*myHero.baseDamage then
				total = total + CalcDamage(myHero, unit, 1, 1.5*myHero.baseDamage)
			else
				if unit.maxHealth*0.1 > 2.5*myHero.baseDamage then
					total = total + CalcDamage(myHero, unit, 1, 2.5*myHero.baseDamage)
				else
					total = total + CalcDamage(myHero, unit, 1,unit.maxHealth*0.1)
				end
			end

	end



	if Trinity and myHero:GetSpellData(Trinity).currentCd == 0 then
		total = total + CalcDamage(myHero, unit, 1, 2*myHero.baseDamage)
	end


	return total
end

local function CalcExtraDmg(unit, typ) -- typ 1 = minion / typ 2 = Enemy
	local total = 0
	local Passive = HasBuff(myHero, "ireliapassivestacksmax")								--Irelia Passive
	local RecurveBow = CheckDmgItems(1043)													--Recurve Bow
	local BladeKing = CheckDmgItems(3153)													--Blade of the ruined King
	local WitsEnd = CheckDmgItems(3091)														--Wits End
	local Titanic = CheckDmgItems(3748)														--T.Hydra
	local Divine = CheckDmgItems(6632)														--Divine Sunderer
	local Sheen = CheckDmgItems(3057)														--Sheen
	local Black = CheckDmgItems(3071) 														--Black Cleaver
	local Trinity = CheckDmgItems(3078)														--Trinity Force
	local Eclipse = CheckDmgItems(6692)														--Eclipse
	local LvL = myHero.levelData.lvl

	if Passive then
		total = total + CalcDamage(myHero, unit, 2, (7+ (3 * LvL)) + 0.20 * myHero.bonusDamage)
	end

	if BladeKing then
		if typ == 1 then
			if unit.health*0.1 > 40 then
				total = total + CalcDamage(myHero, unit, 1, 40)
			else
				total = total + CalcDamage(myHero, unit, 1, (unit.health*0.1))
			end
		else
			total = total + CalcDamage(myHero, unit, 1, (unit.health*0.1) + (HasBuff(myHero, "3153speed") and CalcDamage(myHero, unit, 2, 40+6.47*LvL) or 0))
		end
	end

	if WitsEnd and myHero:GetSpellData(WitsEnd).currentCd == 0 then
		total = total + CalcDamage(myHero, unit, 2, 15 + (4.44 * LvL))
	end

	if RecurveBow and myHero:GetSpellData(RecurveBow).currentCd == 0 then
		total = total + CalcDamage(myHero, unit, 1, 15)
	end

	if Titanic and myHero:GetSpellData(Titanic).currentCd == 0 then
		total = total + CalcDamage(myHero, unit, 1, (myHero.maxHealth*0.01) + (5+myHero.maxHealth*0.015))
	end

	if Sheen and myHero:GetSpellData(Sheen).currentCd == 0 then
		total = total + CalcDamage(myHero, unit, 1, myHero.baseDamage)
	end

	if Divine and myHero:GetSpellData(Divine).currentCd == 0 then
		if typ == 1 then
			if unit.maxHealth*0.1 < 1.5*myHero.baseDamage then
				total = total + CalcDamage(myHero, unit, 1, 1.5*myHero.baseDamage)
			else
				if unit.maxHealth*0.1 > 2.5*myHero.baseDamage then
					total = total + CalcDamage(myHero, unit, 1, 2.5*myHero.baseDamage)
				else
					total = total + CalcDamage(myHero, unit, 1, unit.maxHealth*0.1)
				end
			end
		else
			if unit.maxHealth*0.1 < 1.5*myHero.baseDamage then
				total = total + CalcDamage(myHero, unit, 1, 1.5*myHero.baseDamage)
			else
				total = total + CalcDamage(myHero, unit, 1, unit.maxHealth*0.1)
			end
		end
	end

	if typ == 2 and Black then
		local Buff = GetBuffData(unit, "3071blackcleavermainbuff")
		if Buff.count == 6 then
			total = total + CalcDamage(myHero, unit, 1, (unit.maxHealth-unit.health)*0.05)
		end
	end

	if Trinity and myHero:GetSpellData(Trinity).currentCd == 0 then
		total = total + CalcDamage(myHero, unit, 1, 2*myHero.baseDamage)
	end

	if typ == 2 and Eclipse and myHero:GetSpellData(Eclipse).currentCd > 6.5 then
		total = total + CalcDamage(myHero, unit, 1, unit.maxHealth*0.06)
	end
	return total
end

----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Irelia"

local cpostime=0
local cpos = myHero.pos
local qminions = {}
local lastcheck=0
local lastqdelete=0
local dkmtick=0
local lastkdelete=0
local lastdkm=0
local endp = {}
local KillMinion

local RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.4 + ping, Radius = 160, Range = 1000, Speed = 2000, Collision = false}
local RspellData = {speed = 2000, range = 1000, delay = 0.4 + ping, radius = 160, collision = {nil}, type = "linear"}
local PredLoaded = false

function Irelia:__init()
	self.Window = {x = Game.Resolution().x * 0.5, y = Game.Resolution().y * 0.5}
	self.AllowMove = nil
	self.ButtonDown = false
	self.DetectedMissiles = {}; self.DetectedSpells = {}; self.Target = nil; self.Timer = 0
	self.charging = false
	self:LoadMenu()

	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("WndMsg", function(...) self:OnWndMsg(...) end)

	if not PredLoaded then
		DelayAction(function()
			if self.Menu.MiscSet.Pred.Change:Value() == 1 then
				require('GamsteronPrediction')
				PredLoaded = true
			elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
				require('PremiumPrediction')
				PredLoaded = true
			else
				require('GGPrediction')
				PredLoaded = true
			end
		end, 1)
	end
end

function Irelia:IsOnButton(pt)
	local x, y = self.Window.x, self.Window.y
	return pt.x >= x + 72 and pt.x <= x + 169
		and pt.y >= y + 127 and pt.y <= y + 143
end

function Irelia:IsInStatusBox(pt, pos)
	if pos == 1 then
		return pt.x >= self.Window.x and pt.x <= self.Window.x + 240
			and pt.y >= self.Window.y and pt.y <= self.Window.y + 153
	elseif pos == 2 then
		return pt.x >= self.Window.x and pt.x <= self.Window.x + 240
			and pt.y >= self.Window.y and pt.y <= self.Window.y + 20 and pt.y >= self.Window.y
	elseif pos == 3 then
		return pt.x >= self.Window.x and pt.x <= self.Window.x + 240
			and pt.y >= self.Window.y and pt.y <= self.Window.y + 40 and pt.y >= self.Window.y + 20
	elseif pos == 4 then
		return pt.x >= self.Window.x and pt.x <= self.Window.x + 240
			and pt.y >= self.Window.y and pt.y <= self.Window.y + 60 and pt.y >= self.Window.y + 40
	elseif pos == 5 then
		return pt.x >= self.Window.x and pt.x <= self.Window.x + 240
			and pt.y >= self.Window.y and pt.y <= self.Window.y + 80 and pt.y >= self.Window.y + 60
	elseif pos == 6 then
		return pt.x >= self.Window.x and pt.x <= self.Window.x + 240
			and pt.y >= self.Window.y and pt.y <= self.Window.y + 100 and pt.y >= self.Window.y + 80
	elseif pos == 7 then
		return pt.x >= self.Window.x and pt.x <= self.Window.x + 240
			and pt.y >= self.Window.y and pt.y <= self.Window.y + 120 and pt.y >= self.Window.y + 100
	end
end

function Irelia:OnWndMsg(msg, wParam)
	if self.ButtonDown then return end
	if self:IsOnButton(cursorPos) then
		DelayAction(function()
			Down = true
			self.ButtonDown = true
		end,0.3)
	end
	self.AllowMove = msg == 513 and wParam == 0 and self:IsInStatusBox(cursorPos, 1)
		and {x = self.Window.x - cursorPos.x, y = self.Window.y - cursorPos.y} or nil
	if msg ~= 256 then return end
end

local function HasBuffType(unit, type)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.type == type then
            return true
        end
    end
    return false

end

local function cantkill(unit,kill,ss,aa)
	--set kill to true if you dont want to waste on undying/revive targets
	--set ss to true if you dont want to cast on spellshield
	--set aa to true if ability applies onhit (yone q, ez q etc)

	for i = 0, unit.buffCount do

		local buff = unit:GetBuff(i)
		if buff.name:lower():find("kayler") and buff.count==1 then
			return true
		end


		if buff.name:lower():find("undyingrage") and (unit.health<100 or kill) and buff.count==1 then
			return true
		end
		if buff.name:lower():find("kindredrnodeathbuff") and (kill or (unit.health / unit.maxHealth)<0.11) and buff.count==1  then
			return true
		end
		if buff.name:lower():find("chronoshift") and kill and buff.count==1 then
			return true
		end

		if  buff.name:lower():find("willrevive") and kill and buff.count==1 then
			return true
		end

		 --uncomment for cc stuff
		if  buff.name:lower():find("morganae") and ss and not aa and buff.count==1 then
			return true
		end


		if (buff.name:lower():find("fioraw") or buff.name:lower():find("pantheone")) and buff.count==1 then
			return true
		end

		if  buff.name:lower():find("jaxcounterstrike") and aa and buff.count==1  then
			return true
		end

		if  buff.name:lower():find("nilahw") and aa and buff.count==1  then
			return true
		end

		if  buff.name:lower():find("shenwbuff") and aa and buff.count==1  then
			return true
		end

	end
	if HasBuffType(unit, 4) and ss then
		return true
	end
	--if HasBuffType(myHero, 26) and aa then
		--return true
	--end


	return false
end



function Irelia:LoadMenu()
--MainMenu
    self.Menu = MenuElement({type = MENU, id = "Irelia", name = "PussyIrelia"})
    self.Menu:MenuElement({name = " ", drop = {"Version 0.40"}})

    self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})

	--ComboMenu
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	self.Menu.ComboSet.Combo:MenuElement({name = " ", drop = {"E1, W, R, Q, E2, Q + (Q when kill / almost kill)"}})
	self.Menu.ComboSet.Combo:MenuElement({id = "LogicQ", name = "Last[Q]Almost Kill or Kill", key = 0x61, value = false, toggle = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseW", name = "[W]", value = false})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseE1", name = "Cast E1 in 1v1 (at your feet))", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseR", name = "[R]Single Target if almost killable", value = false})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseRCount", name = "Auto[R] Multiple Enemys", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "RCount", name = "Multiple Enemys", value = 2, min = 2, max = 5, step = 1})
	self.Menu.ComboSet.Combo:MenuElement({id = "Gap", name = "Gapclose [Q]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "Stack", name = "Stack Passive near Target/Minion", value = true})

	--BurstModeMenu
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Burst", name = "Burst Mode"})
	self.Menu.ComboSet.Burst:MenuElement({name = " ", drop = {"If Burst Active then Combo Mode is Inactive"}})
	self.Menu.ComboSet.Burst:MenuElement({id = "StartB", name = "Use Burst Mode", key = 0x62, value = true, toggle = true})
	self.Menu.ComboSet.Burst:MenuElement({id = "Lvl", name = "Irelia Level to Start Burst", value = 6, min = 6, max = 18, step = 1})
    self.Menu.ComboSet.Burst:MenuElement({id = "UseRCount", name = "Auto[R] Multiple Enemys", value = true})
	self.Menu.ComboSet.Burst:MenuElement({id = "RCount", name = "Multiple Enemys", value = 2, min = 2, max = 5, step = 1})


	self.Menu.ComboSet:MenuElement({type = MENU, id = "Ninja", name = "Ninja Mode"})
	self.Menu.ComboSet.Ninja:MenuElement({id = "UseQ", name = "Q on all Marked Enemys", key = 0x63, value = true, toggle = true})

    self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	self.Menu.ClearSet.Clear.Last:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})
	self.Menu.ClearSet.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})

	--JungleClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})

	--LastHitMode Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "LastHit", name = "LastHit Mode"})
	self.Menu.ClearSet.LastHit:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})
	self.Menu.ClearSet.LastHit:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	self.Menu.ClearSet.LastHit:MenuElement({id = "Active", name = "LastHit Key", key = string.byte("X")})

	--HarassMenu
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})

	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})

    self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})

	self.Menu.MiscSet:MenuElement({type = MENU, id = "Flee", name = "Flee Mode"})
	self.Menu.MiscSet.Flee:MenuElement({name = " ", drop = {"Default Hotkey = [A]"}})
	self.Menu.MiscSet.Flee:MenuElement({id = "Q", name = "[Q]", value = true})
	self.Menu.MiscSet.Flee:MenuElement({id = "Qcombo", name = "q to minions in combo", value = false,key=string.byte("A")})
	self.Menu.MiscSet.Flee:MenuElement({id = "Q2", name = "[Q] even on non killable Minions", value = false})

	self.Menu.MiscSet:MenuElement({type = MENU, id = "Rrange", name = "Ultimate Range setting"})
	self.Menu.MiscSet.Rrange:MenuElement({id = "R", name = "Max Cast range [R]", value = 850, min = 0, max = 950, step = 10})


	--Prediction
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.Menu.MiscSet.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})

	--Drawing
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawKM", name = "Draw killable minions", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({type = MENU, id = "XY", name = "Info Box Settings"})
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "OnOff", name = "Draw Status Box", key = 0x67, value = true, toggle = true})
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "Key", name = "Draw HotKey Info", value = true})
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "Hide", name = "Hide Info Box if active Mode", value = true})
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "T", name = "Status Box transparency", value = 120, min = 0, max = 223, step = 10})

end





function Irelia:Tick()
	--print(GetMode())
	self:CheckInfoBox()
	if Control.IsKeyDown(0x69) then
		self.ButtonDown = false
		UnLockBox = true
	end
	if myHero:GetSpellData(_E).toggleState==0 then
	for i = 1, Game.MissileCount() do
	local missile = Game.Missile(i)
		if missile and (missile.missileData.name == "IreliaEMissile") then
			endp=Vector(missile.missileData.endPos.x,missile.missileData.endPos.y,missile.missileData.endPos.z)
		end
	end
end


	if heroes == false then
		for i, unit in pairs(Enemies) do
			checkCount = checkCount + 1
		end
		if checkCount < 1 then
			LoadUnits()
		else
			heroes = true
		end
	end



if MyHeroNotReady() then return end

local Mode = GetMode()
		if Mode == "Flee" then
			self:Flee()
		end
		if Mode == "Combo" then
			if self.Menu.ComboSet.Ninja.UseQ:Value() then
				self:Ninja()
			end
			if self.Menu.ComboSet.Burst.StartB:Value() and myHero.levelData.lvl <= self.Menu.ComboSet.Burst.Lvl:Value() then
				self:Combo()
			end
			if not self.Menu.ComboSet.Burst.StartB:Value() then
				self:Combo()
			end
		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "LaneClear" then
			self:JungleClear()
			self:Clear()
		elseif Mode == "LastHit" then
				if self.Menu.ClearSet.LastHit.Active:Value() then
				self:LastHit()
			end
		end

	if self.Menu.MiscSet.Flee.Qcombo:Value()==true then
		self:Flee()
	end
	local target = GetTarget(1100)
	if target == {} then end

	local wbuff = GetBuffData(myHero, "ireliawdefense")
	if HasBuff(myHero, "ireliawdefense") and target and wbuff.duration<0.95  then
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay =0.06, Radius = 15, Range = 895, Speed = 5000, Collision = false})
				  QPrediction:GetPrediction(target, myHero)
			if QPrediction:CanHit(1) then
		Control.CastSpell(HK_W,QPrediction.CastPosition)
		end

	end

	if Mode == "Combo" and IsValid(target) and self.Menu.ComboSet.Burst.StartB:Value() and myHero.levelData.lvl >= self.Menu.ComboSet.Burst.Lvl:Value() then

		if myHero.pos:DistanceTo(target.pos) <= 775 and myHero:GetSpellData(_E).toggleState == 0 and not ISMarked(1000) then
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 75, Range = 800, Speed = math.huge,Collision = true, CollisionTypes = {COLLISION_YASUOWALL}})
				  QPrediction:GetPrediction(target, myHero)
			if QPrediction:CanHit(1)and not (myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "IreliaR") and not cantkill(target,false,true,false)  then
				local Epos = QPrediction.CastPosition + (endp - QPrediction.CastPosition): Normalized() * -150
				SetMovement(false)
				Control.CastSpell(HK_E, Epos)
				SetMovement(true)
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 600 and myHero:GetSpellData(_E).toggleState == 1 and Ready(_E) and not ISMarked(1000) then
					for i, target2 in ipairs(GetEnemyHeroes()) do
			if target2 and target and target2 ~= target and myHero.pos:DistanceTo(target2.pos)<775 and IsValid(target2)  then
			local aimp=target2.pos + (target.pos- target2.pos): Normalized() * -150
				if aimp then
					SetMovement(false)
					Control.CastSpell(HK_E,aimp)
					SetMovement(true)
				end
			end

		end
		if self.Menu.ComboSet.Combo.UseE1:Value() then
		Control.CastSpell(HK_E, myHero.pos)
		end
		end

		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and HasBuff(target, "ireliamark") and not cantkill(target,false,true,true) then
			if CheckHPPred(target) >= 1 and IsValid(target) then
				Control.CastSpell(HK_Q, target)
			end
		end

		if self.Menu.ComboSet.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 400 and Ready(_W) and not Ready(_E) then
			Control.CastSpell(HK_W, target)
		end

		if myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and Ready(_R) and not ISMarked(1000) and not cantkill(target,false,true,false) then
	        local Passive = CalcExtraDmg(target, 2)*3
			local QDmg = Ready(_Q) and getdmg("Q", target, myHero, 1)*3 or 0
			local WDmg = Ready(_W) and getdmg("W", target, myHero) or 0
			local EDmg = Ready(_E) and getdmg("E", target, myHero) or 0
			local RDmg = getdmg("R", target, myHero)
			local AADmg = getdmg("AA", target, myHero)*2
			local FullDmg = Passive+QDmg+WDmg+EDmg+RDmg+AADmg
			if FullDmg >= target.health then
				self:CastR(target)
			end
		end

		if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and self.Menu.ComboSet.Burst.UseRCount:Value() then
			local count = GetEnemyCount(400, target)
			if count >= self.Menu.ComboSet.Burst.RCount:Value() then
				self:CastR(target)
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero) + CalcExtraDmg(target)
			if (QDmg >= target.health and CheckHPPred(target) >= 1) and IsValid(target) and not cantkill(target,true,true,true) then
				Control.CastSpell(HK_Q, target)
			end
		end

		if myHero.pos:DistanceTo(target.pos) > 600 and myHero.pos:DistanceTo(target.pos) < 775 and Ready(_Q) and Ready(_E) then
			local QDmg = getdmg("Q", target, myHero) + CalcExtraDmg(target)
			if QDmg >= target.health and not HasBuff(target, "ireliamark") then
				if myHero:GetSpellData(_E).toggleState == 1 then
							for i, target2 in ipairs(GetEnemyHeroes()) do
			if target2 and target and target2 ~= target and myHero.pos:DistanceTo(target2.pos)<775 and IsValid(target2)  then
			local aimp=target2.pos + (target.pos- target2.pos): Normalized() * -150
				if aimp then
					SetMovement(false)
					Control.CastSpell(HK_E,aimp)
					SetMovement(true)
				end
			end
		end


		Control.CastSpell(HK_E, myHero.pos)
				end
			end
			if myHero.pos:DistanceTo(target.pos) <= 775 and myHero:GetSpellData(_E).toggleState == 0 then
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 70, Range = 800, Speed = math.huge, Collision = false})
				  QPrediction:GetPrediction(target, myHero)
			if QPrediction:CanHit(1) and not ISMarked(1000) and not (myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "IreliaR") and not cantkill(target,false,true,false) then
				local Epos = QPrediction.CastPosition + (endp - QPrediction.CastPosition): Normalized() * -150
					SetMovement(false)
					Control.CastSpell(HK_E, Epos)
					SetMovement(true)
				end
			end
		end
		self:Gapclose(target)
		if myHero:GetSpellData(_E).name == "IreliaE2" then return end
		self:StackPassive(target)
	end
end

local function GetMinions(range, typ) -- 1 = Enemy / 2 = Ally / 3 = Monsters
	if _G.SDK and _G.SDK.Orbwalker then
		if typ == 1 then
			return _G.SDK.ObjectManager:GetEnemyMinions(range)
		elseif typ == 2 then
			return _G.SDK.ObjectManager:GetAllyMinions(range)
		elseif typ == 3 then
			return _G.SDK.ObjectManager:GetMonsters(range)
		end

	elseif _G.PremiumOrbwalker then
		if typ < 3 then
			return _G.PremiumOrbwalker:GetMinionsAround(range, typ)
		else
			local Monsters = {}
			local minions = _G.PremiumOrbwalker:GetMinionsAround(range, typ)
			if minions then
				for i = 1, #minions do
					local unit = minions[i]
					if unit.isEnemy and unit.team == 300 then
						TableInsert(Monsters, unit)
					end
				end
			end
			return Monsters
		end
	end
end

local function locateqminion( table, value )
    for i = 1, #table do
        if table[i] == value
		and IsValid(minion) and GetDistance(minion.pos, mousePos) < ((400 and not mode=="Combo") or 500)
		then  return true end
    end
    --print( value ..' not found' ) return false
end


local function GetKillableMinion()
	if Ready(_Q) and KillMinion == nil then
		local Minions = GetMinions(600, 1)
		if next(Minions) == nil then return end

		for i = 1, #Minions do
			local minion = Minions[i]
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg(minion, 1)
			if (minion.team == TEAM_ENEMY) and QDmg > minion.health and IsValid(minion) and GetDistance(minion.pos, mousePos) < (200) then
				KillMinion = minion
				return
			end
		end
		for i = 1, #Minions do
			local minion = Minions[i]
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg(minion, 1)
			if (minion.team == TEAM_ENEMY) and QDmg > minion.health and IsValid(minion) and GetDistance(minion.pos, mousePos) < ((400 and not mode=="Combo") or 500) then
				KillMinion = minion
				return
			elseif (minion.team == TEAM_JUNGLE) then
				local QDmg2 = getdmg("Q", minion, myHero, 1) + CalcExtraDmg2(minion)
				if QDmg2 > minion.health and IsValid(minion) and GetDistance(minion.pos, mousePos) < ((400 and not mode=="Combo") or 500) then
					KillMinion = minion
					return
				end
			end
		end
	end
end

local function locate( table, value )
    for i = 1, #table do
        if table[i] == value then  return true end
    end
    --print( value ..' not found' ) return false
end


local function DrawKillableMinion()
	dkmtick=dkmtick+1
	lastdkm=Game.Timer()
		local Minions = GetMinions(800, 1)
		if Minions == nil then return end

		for i = 1, #Minions do
			local minion = Minions[i]

			if not locate(qminions,minion.name)then
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg2(minion)
			if minion.team == TEAM_ENEMY and QDmg > minion.health and IsValid(minion) then
			if KillMinion == nil then
				if GetDistance(minion.pos, mousePos) < (230) then
					KillMinion=minion
				end
			end
				table.insert(qminions, minion.name)
			elseif (minion.team == TEAM_JUNGLE) then
				local QDmg2 = getdmg("Q", minion, myHero, 1) + CalcExtraDmg2(minion)
				if QDmg2 > minion.health and IsValid(minion)  then
				table.insert(qminions, minion.name)
				end
			end
			end
		end
		lastcheck=Game.Timer()

end

local function DrawKillableMinion2()

		local Minions = GetMinions(800, 1)
		if Minions == nil then return end
    for i = 1, #Minions do
        local minion = Minions[i]
		if locate(qminions,minion.name) then
			DrawCircle(minion,35, 4, DrawColor(225, 225, 125, 10))
        end
    end
end

function Irelia:Flee()
	local mode = GetMode()
	if self.Menu.MiscSet.Flee.Q:Value() and Ready(_Q) then
		if KillMinion and GetDistance(KillMinion.pos, mousePos) < (300) then
					Control.CastSpell(HK_Q,KillMinion)
					KillMinion = nil
		else
			GetKillableMinion()
		if KillMinion and GetDistance(KillMinion.pos, mousePos) < ((400 and not mode=="Combo") or 500) then


					Control.CastSpell(HK_Q,KillMinion)
				--	CastSpell(HK_Q, KillMinion, LastQ)
				--	LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
					KillMinion = nil


		-- else
				-- for i, enemy in ipairs(GetEnemyHeroes()) do
				-- local QDmg = getdmg("Q", enemy, myHero) + CalcExtraDmg(enemy)
					-- if (QDmg>= enemy.health) and IsValid(enemy) and GetDistance(enemy.pos, mousePos)<400 and GetDistance(enemy.pos, myHero.pos)<610 and not cantkill(enemy,true,true,true)  then
						-- Control.CastSpell(HK_Q, enemy)
					-- end
				-- end
				-- KillMinion = nil
		end


	  end
	end
end

function Irelia:Ninja()
local target1 = GetTarget(1200)
	for i, target2 in ipairs(GetEnemyHeroes()) do

		if Ready(_Q) and GetEnemyCount(1200, myHero) >= 2 then
			if target2 and target1 and target2 ~= target1 then
				if HasBuff(target2, "ireliamark") and myHero.pos:DistanceTo(target2.pos) <= 600 and IsValid(target2) then
					local time2 = myHero.pos:DistanceTo(target2.pos) / (1500+myHero.ms)
					local MarkBuff2 = GetBuffData(target2, "ireliamark")
					if MarkBuff2.duration > time2 and not cantkill(target2,false,true,true) then
						Control.CastSpell(HK_Q, target2)
					end
				end
				if (not HasBuff(target2, "ireliamark") or myHero.pos:DistanceTo(target2.pos) > 600) and HasBuff(target1, "ireliamark") and myHero.pos:DistanceTo(target1.pos) <= 600 and IsValid(target1) then
					local time1 = myHero.pos:DistanceTo(target1.pos) / (1500+myHero.ms)
					local MarkBuff1 = GetBuffData(target1, "ireliamark")
					if MarkBuff1.duration > time1 and not cantkill(target1,false,true,true) then
						Control.CastSpell(HK_Q, target1)
					end
				end
			end
		end
	end
end

function Irelia:Combo()
	if self.Menu.MiscSet.Flee.Qcombo:Value()==true then
		self:Flee()
	end
local target = GetTarget(1150)
if target == {} then end
	if IsValid(target) then

		if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and self.Menu.ComboSet.Combo.UseRCount:Value() then
			local count = GetEnemyCount(400, target)
			if count >= self.Menu.ComboSet.Combo.RCount:Value() then
				self:CastR(target)
			end
		end

		if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then

			if myHero.pos:DistanceTo(target.pos) <= 775 then
				self:CastE(target)
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and HasBuff(target, "ireliamark") and not cantkill(target,false,true,true) then
			Control.CastSpell(HK_Q, target)
		end

		if self.Menu.ComboSet.Combo.UseW:Value() and Ready(_W) and not Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then
				Control.CastSpell(HK_W, target)
			end
		end

		if self.Menu.ComboSet.Combo.UseR:Value() and Ready(_R) and not ISMarked(1000) then
			local count = GetEnemyCount(1500, myHero)
			if myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and count == 1 then
               Control.CastSpell(HK_R, target)
			end
		end

		if self.Menu.ComboSet.Combo.LogicQ:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", target, myHero) + CalcExtraDmg(target)
				if (QDmg >= target.health and CheckHPPred(target) >= 1) and IsValid(target) and not cantkill(target,true,true,true) then
					Control.CastSpell(HK_Q, target)
				end
			end

			if myHero.pos:DistanceTo(target.pos) >= 300 and myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and not cantkill(target,true,true,true) then
				local QDmg = getdmg("Q", target, myHero) + CalcExtraDmg(target)
				if (QDmg*2) >= target.health then
					Control.CastSpell(HK_Q, target)
				end
			end

		else

			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", target, myHero) + CalcExtraDmg(target)
				if (QDmg >= target.health and CheckHPPred(target) >= 1) and IsValid(target) and not cantkill(target,true,true,true) then
					Control.CastSpell(HK_Q, target)
				end
			end
		end

		if self.Menu.ComboSet.Combo.Gap:Value() then
			self:Gapclose(target)
		end
		if myHero:GetSpellData(_E).name == "IreliaE2" then return end
		if self.Menu.ComboSet.Combo.Stack:Value() then
			self:StackPassive(target)
		end
	end
end

function Irelia:Harass()
local target = GetTarget(1100)
if target == nil then return end
	if IsValid(target) then

		if self.Menu.Harass.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then
				self:CastE(target)
			end
		end
	end
end

function Irelia:LastHit()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if self.Menu.ClearSet.LastHit.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.LastHit.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg(minion)

				if not IsUnderTurret(minion) then
					if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
						Control.CastSpell(HK_Q, minion)
					end
				else
					if AllyMinionUnderTower() then
						if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
							Control.CastSpell(HK_Q, minion)
						end
					end
				end
            end
		end
	end
end

function Irelia:StackPassive(target)
if HasBuff(myHero, "ireliapassivestacksmax") then return end
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_ENEMY then
			if target.pos:DistanceTo(minion.pos) <= 400 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) and not HasBuff(target, "ireliamark") then
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg(minion)
				if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValid(minion) then
					Control.CastSpell(HK_Q, minion)
				end
			end
		end
	end
end


function Irelia:JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_JUNGLE and IsValid(minion) then

			if myHero.pos:DistanceTo(minion.pos) <= 825 and self.Menu.ClearSet.JClear.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 then
				Control.CastSpell(HK_W, minion.pos)
            end

			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.ClearSet.JClear.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero) + CalcExtraDmg(minion)
				if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
					Control.CastSpell(HK_Q, minion)
				end
			end
        end
    end
end

function Irelia:Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then

			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.ClearSet.Clear.Last.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg(minion)
				if not IsUnderTurret(minion) then
					if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
						Control.CastSpell(HK_Q, minion)
					end
				end

				if IsUnderTurret(minion) and AllyMinionUnderTower() then
					if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
						Control.CastSpell(HK_Q, minion)
					end
				end
			end
        end
    end
end

function Irelia:CastQMinion(target)
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			local Dmg = getdmg("Q", target, myHero) or getdmg("W", target, myHero) or getdmg("E", target, myHero) or getdmg("R", target, myHero)
			if IsValid(target) and myHero.pos:DistanceTo(minion.pos) <= 600 and target.pos:DistanceTo(myHero.pos) < minion.pos:DistanceTo(target.pos) and not IsUnderTurret(minion) and target.health > Dmg then
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg(minion)
				if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) and not HasBuff(target, "ireliamark") then
					Control.CastSpell(HK_Q, minion)
				end
			end
		end
	end
end

function Irelia:Gapclose(target)
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg(minion)
			if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and myHero.pos:DistanceTo(target.pos) > target.pos:DistanceTo(minion.pos) then
				Control.CastSpell(HK_Q, minion)
			end
		end
	end
end

function Irelia:CastW(target)
    if target and GetDistanceSqr(target.pos, myHero.pos) < 825 * 825 then
	local aim = GetPred(target,1400,0.6)

		if not self.charging and not HasBuff(myHero, "ireliawdefense") then
            Control.KeyDown(HK_W)
            wClock = clock()
            self.charging = true
        end

		if HasBuff(myHero, "ireliawdefense") and (target.pos:DistanceTo(myHero.pos) > 600) then
			Control.CastSpell(HK_W, aim)
			self.charging = false
		elseif HasBuff(myHero, "ireliawdefense") and clock() - wClock >= 0.5 and target.pos:DistanceTo(myHero.pos) < 825 then
			Control.CastSpell(HK_W, aim)
			self.charging = false
		end



    end
    if clock() - wClock >= 1.5 then
    Control.KeyUp(HK_W)
    self.charging = false
    end
end

function Irelia:LineCircleIntersection(p1, p2, circle, radius)
    local dx, dy = p2.x - p1.x, p2.z - p1.z
    local a = dx * dx + dy * dy
    local b = 2 * (dx * (p1.x - circle.x) + dy * (p1.z - circle.z))
    local c = (p1.x - circle.x) * (p1.x - circle.x) + (p1.z - circle.z) * (p1.z - circle.z) - (radius * radius)
    local delta = b * b - 4 * a * c
    if delta >= 0 then
        local t1, t2 = (-b + math.sqrt(delta)) / (2 * a), (-b - math.sqrt(delta)) / (2 * a)
        return Vector(p1.x + t1 * dx, p1.y, p1.z + t1 * dy), Vector(p1.x + t2 * dx, p1.y, p1.z + t2 * dy)
    end
    return nil, nil
end

-- function Irelia:GetBestECastPositions(units)
	-- local startPos, endPos, count = nil, nil, 0
    -- local candidates, unitPositions = {}, {}
    -- for i, unit in ipairs(units) do
		-- if unit then
			-- local cp = GetPred(unit, 775, 0.25)
			-- if cp then candidates[i], unitPositions[i] = cp, cp end
		-- end
    -- end
    -- local maxCount = #units
    -- for i = 1, maxCount do
        -- for j = 1, maxCount do
            -- if candidates[j] ~= candidates[i] then
                -- TableInsert(candidates, Vector(candidates[j] + candidates[i]) / 2)
            -- end
        -- end
    -- end
    -- for i, unit2 in pairs(units) do
        -- if unit2 and unit2.pos:DistanceTo(myHero.pos) < 875 then
			-- local cp = GetPred(unit2, 775, 0.25)
			-- if cp then
				-- for i, pos2 in ipairs(candidates) do
					-- if pos2 and pos2:DistanceTo(myHero.pos) < 875 then
						-- --local range = pos2:DistanceTo(cp)*2+150
						-- local ePos = Vector(cp):Extended(pos2, 775)
						-- local number = 0
						-- for i = 1, #unitPositions do
							-- local unitPos = unitPositions[i]
							-- if unitPos:DistanceTo(myHero.pos) < 875 and ePos:DistanceTo(myHero.pos) < 875 then
								-- local pointLine, pointSegment, onSegment = VectorPointProjectionOnLineSegment(cp, ePos, unitPos)
								-- if pointSegment and DistanceSquared(pointSegment, unitPos) < 8400 then number = number + 1 end
							-- end
						-- end
						-- if number >= count then startPos, endPos, count = cp, ePos, number end
					-- end
				-- end
			-- end
		-- end
    -- end
    -- return startPos, endPos, count
-- end


function Irelia:CastE(unit)


    if myHero:GetSpellData(_E).toggleState == 1  and not HasBuff(unit, "ireliamark") then
		for i, target2 in ipairs(GetEnemyHeroes()) do
			if target2 and unit and target2 ~= unit and myHero.pos:DistanceTo(target2.pos)<775 and IsValid(target2)  then
			local aimp=target2.pos + (unit.pos- target2.pos): Normalized() * -220
				if aimp then
					SetMovement(false)
					Control.CastSpell(HK_E,aimp)
					SetMovement(true)
				end
			end
		end

		if  self.Menu.ComboSet.Combo.UseE1:Value() then
		Control.CastSpell(HK_E, myHero.pos)
		end
	end
    if myHero:GetSpellData(_E).name == "IreliaE2" then
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 70, Range = 800, Speed = math.huge, Collision = true, CollisionTypes = {COLLISION_YASUOWALL}})
				  QPrediction:GetPrediction(unit, myHero)
			if QPrediction:CanHit(1)and not cantkill(unit,false,true,false) then


				local Epos = QPrediction.CastPosition + (endp - QPrediction.CastPosition): Normalized() * -200
				SetMovement(false)
				Control.CastSpell(HK_E, Epos)
				SetMovement(true)

		end
	end
end

function Irelia:CastR(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, RData, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredR:Value()+1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end
	elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
			Control.CastSpell(HK_R, pred.CastPos)
		end
	else
		self:CastGGPred(unit)
	end
end

function Irelia:CastGGPred(unit)
	local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4 + ping, Radius = 160, Range = 950, Speed = 2000, Collision = true, CollisionTypes = {COLLISION_YASUOWALL}})
		  RPrediction:GetPrediction(unit, myHero)
	if RPrediction:CanHit(self.Menu.MiscSet.Pred.PredR:Value()+1) then
		Control.CastSpell(HK_R, RPrediction.CastPosition)
	end
end

function Irelia:CheckInfoBox()
	if InfoBoxPos == true and LoadPos == false then
		local PosX, PosY = BoxPosition()
		self.Window.x = PosX
		self.Window.y = PosY
		self.ButtonDown = true
		LoadPos = true
	end

	if UnLockBox then
		DelayAction(function()
			UnLockBox = false
		end,2)
	end

	if Down then
		DrawSaved = true
		self:SaveBox()
		DelayAction(function()
			DrawSaved = false
			Down = false
		end,2)
	end
end

function Irelia:SaveBox()
	local f = io.open(COMMON_PATH .. "PussyBoxPos.lua", "w")
	f:write("function BoxPosition() \n")
	f:write("local x = " .. self.Window.x .. "\n")
	f:write("local y = " .. self.Window.y .. "\n")
	f:write("return x, y \n")
	f:write("end")
	f:close()
end

function Irelia:Draw()

	if heroes == false then
		Draw.Text(myHero.charName.." is Loading !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 255, 0, 0))
	else
		if DrawTime == false then
			Draw.Text(myHero.charName.." is Ready !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 0, 255, 0))
			DelayAction(function()
			DrawTime = true
			end, 4.0)
		end
	end

	if myHero.dead then return end

	if self.Menu.MiscSet.Drawing.DrawR:Value() and Ready(_R) then
    DrawCircle(myHero, self.Menu.MiscSet.Rrange.R:Value(), 1, DrawColor(255, 225, 255, 10))
	end
	if self.Menu.MiscSet.Drawing.DrawQ:Value() and Ready(_Q) then
    DrawCircle(myHero, 600, 1, DrawColor(225, 225, 0, 10))
	end
	if self.Menu.MiscSet.Drawing.DrawE:Value() and Ready(_E) then
    DrawCircle(myHero, 775, 1, DrawColor(225, 225, 125, 10))
	end
	if self.Menu.MiscSet.Drawing.DrawW:Value() and Ready(_W) then
    DrawCircle(myHero, 825, 1, DrawColor(225, 225, 125, 10))
	end
	if self.Menu.MiscSet.Drawing.DrawKM:Value() and Ready(_Q) then

		if (lastdkm+.65)<Game.Timer() then
		DrawKillableMinion()
		end

		if (lastkdelete+2)<Game.Timer() then
			KillMinion = nil
			lastkdelete=Game.Timer()
		end

		DrawKillableMinion2()


	end


	--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	if Game.IsChatOpen() or myHero.dead or not self.Menu.MiscSet.Drawing.XY.OnOff:Value() then return end
	local ActiveMenu = self.Menu.MiscSet.Drawing.XY.Key:Value()
	local Trans = self.Menu.MiscSet.Drawing.XY.T:Value()
	local black, red, blue, green, white, yellow = DrawColor(Trans+32, 23, 23, 23), DrawColor(Trans, 220, 20, 60), DrawColor(Trans, 0, 191, 255), DrawColor(Trans, 50, 205, 50), DrawColor(Trans, 255, 255, 255), DrawColor(Trans, 225, 255, 0)

	if self.Menu.MiscSet.Drawing.XY.Hide:Value() then
	 	if ActiveModes() then return end

		if self.AllowMove then
			self.Window = {x = cursorPos.x + self.AllowMove.x, y = cursorPos.y + self.AllowMove.y}
		end

		if DrawSaved then
			DrawRect(self.Window.x, self.Window.y, 240, 128, black)
			DrawText("SAVED", 50, self.Window.x + 60, self.Window.y + 40, DrawColor(255, 0, 191, 255))
		elseif UnLockBox then
			DrawRect(self.Window.x, self.Window.y, 240, 128, black)
			DrawText("UNLOCKED", 50, self.Window.x + 15, self.Window.y + 40, DrawColor(255, 220, 20, 60))
		else
			if self.ButtonDown == false then
				DrawRect(self.Window.x, self.Window.y, 240, 128, black)
				if self:IsInStatusBox(cursorPos, 1) then
					DrawRect(self.Window.x, self.Window.y - 30, 240, 40, black)
					DrawText("--- Hold left MouseButton and move Info Box ---", 10, self.Window.x + 20, self.Window.y - 20, blue)
					DrawRect(self.Window.x, self.Window.y + 125, 240, 20, blue)
					DrawRect(self.Window.x + 72, self.Window.y + 127, 97, 16, black)
					DrawText("Save Pos Button", 14, self.Window.x + 76, self.Window.y + 128, white)
				end
			else
				DrawRect(self.Window.x, self.Window.y, 240, 148, black)
				DrawText("Unlock Info Box:", 15, self.Window.x + 10, self.Window.y + 125, white)
				DrawText("NumPad 9", 15, self.Window.x + 153, self.Window.y + 125, green)
			end

			if self:IsInStatusBox(cursorPos, 2) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 1", 15, self.Window.x + 10, self.Window.y + 5, yellow)
			else
				DrawText("Last Q Combo Mode:", 15, self.Window.x + 10, self.Window.y + 5, white)
				if self.Menu.ComboSet.Combo.LogicQ:Value() then
					DrawText("Almost Kill", 15, self.Window.x + 153, self.Window.y + 5, green)
				else
					DrawText("Kill", 15, self.Window.x + 153, self.Window.y + 5, green)
				end
			end

			if self:IsInStatusBox(cursorPos, 3) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 2", 15, self.Window.x + 10, self.Window.y + 25, yellow)
			else
				DrawText("Burst Mode:", 15, self.Window.x + 10, self.Window.y + 25, white)
				if self.Menu.ComboSet.Burst.StartB:Value() then
					if myHero.levelData.lvl >= self.Menu.ComboSet.Burst.Lvl:Value() then
						DrawText("Active", 15, self.Window.x + 153, self.Window.y + 25, green)
					else
						DrawText("Wait for LvL ".. self.Menu.ComboSet.Burst.Lvl:Value(), 15, self.Window.x + 153, self.Window.y + 25, red)
					end
				else
					DrawText("OFF", 15, self.Window.x + 153, self.Window.y + 25, red)
				end
			end

			if self:IsInStatusBox(cursorPos, 4) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 3", 15, self.Window.x + 10, self.Window.y + 45, yellow)
			else
				DrawText("Ninja Mode:", 15, self.Window.x + 10, self.Window.y + 45, white)
				if self.Menu.ComboSet.Ninja.UseQ:Value() then
					Draw.Text("Active", 15, self.Window.x + 153, self.Window.y + 45, green)
				else
					Draw.Text("OFF", 15, self.Window.x + 153, self.Window.y + 45, red)
				end
			end
		end
	end

		if DrawSaved then
			DrawRect(self.Window.x, self.Window.y, 240, 128, black)
			DrawText("SAVED", 50, self.Window.x + 60, self.Window.y + 40, DrawColor(255, 0, 191, 255))
		elseif UnLockBox then
			DrawRect(self.Window.x, self.Window.y, 240, 128, black)
			DrawText("UNLOCKED", 50, self.Window.x + 15, self.Window.y + 40, DrawColor(255, 220, 20, 60))
		else
			if self.ButtonDown == false then
				DrawRect(self.Window.x, self.Window.y, 240, 128, black)
				if self:IsInStatusBox(cursorPos, 1) then
					DrawRect(self.Window.x, self.Window.y - 30, 240, 40, black)
					DrawText("--- Hold left MouseButton and move Info Box ---", 10, self.Window.x + 20, self.Window.y - 20, blue)
					DrawRect(self.Window.x, self.Window.y + 125, 240, 20, blue)
					DrawRect(self.Window.x + 72, self.Window.y + 127, 97, 16, black)
					DrawText("Save Pos Button", 14, self.Window.x + 76, self.Window.y + 128, white)
				end
			else
				DrawRect(self.Window.x, self.Window.y, 240, 148, black)
				DrawText("Unlock Info Box:", 15, self.Window.x + 10, self.Window.y + 125, white)
				DrawText("NumPad 9", 15, self.Window.x + 153, self.Window.y + 125, green)
			end

			if self:IsInStatusBox(cursorPos, 2) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 1", 15, self.Window.x + 10, self.Window.y + 5, yellow)
			else
				DrawText("Last Q Combo Mode:", 15, self.Window.x + 10, self.Window.y + 5, white)
				if self.Menu.ComboSet.Combo.LogicQ:Value() then
					DrawText("Almost Kill", 15, self.Window.x + 153, self.Window.y + 5, green)
				else
					DrawText("Kill", 15, self.Window.x + 153, self.Window.y + 5, green)
				end
			end

			if self:IsInStatusBox(cursorPos, 3) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 2", 15, self.Window.x + 10, self.Window.y + 25, yellow)
			else
				DrawText("Burst Mode:", 15, self.Window.x + 10, self.Window.y + 25, white)
				if self.Menu.ComboSet.Burst.StartB:Value() then
					if myHero.levelData.lvl >= self.Menu.ComboSet.Burst.Lvl:Value() then
						DrawText("Active", 15, self.Window.x + 153, self.Window.y + 25, green)
					else
						DrawText("Wait for LvL ".. self.Menu.ComboSet.Burst.Lvl:Value(), 15, self.Window.x + 153, self.Window.y + 25, red)
					end
				else
					DrawText("OFF", 15, self.Window.x + 153, self.Window.y + 25, red)
				end
			end

			if self:IsInStatusBox(cursorPos, 4) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 3", 15, self.Window.x + 10, self.Window.y + 45, yellow)
			else
				DrawText("Ninja Mode:", 15, self.Window.x + 10, self.Window.y + 45, white)
				if self.Menu.ComboSet.Ninja.UseQ:Value() then
					Draw.Text("Active", 15, self.Window.x + 153, self.Window.y + 45, green)
				else
					Draw.Text("OFF", 15, self.Window.x + 153, self.Window.y + 45, red)
				end
			end
		end
	end

Callback.Add("Load", function()
	if table.contains(Heroes, myHero.charName) then
		_G[myHero.charName]()
		LoadUnits()
	end
end)

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

-- [ AutoUpdate ]
do
    
    local Version = 0.35
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyIrelia.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyIrelia.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyIrelia.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyIrelia.version"
        }
    }
    
    local function AutoUpdate()

        local function DownloadFile(url, path, fileName)
            DownloadFileAsync(url, path .. fileName, function() end)
            while not FileExist(path .. fileName) do end
        end
        
        local function ReadFile(path, fileName)
            local file = io.open(path .. fileName, "r")
            local result = file:read()
            file:close()
            return result
        end
        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        local textPos = myHero.pos:To2D()
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print("New PussyIrelia Version Press 2x F6")
        else
            print("PussyIrelia loaded")
        end
    
    end
    
    AutoUpdate()

end 

----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

local PredLoaded = false
local LastQ = 0
local KillMinion = nil
local WStart = 0
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
local GameObjectCount = Game.ObjectCount
local GameObject = Game.Object
local GameIsChatOpen = Game.IsChatOpen


_G.LATENCY = 0.05


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

local function CheckLoadedEnemies()
	local count = 0
	for i, unit in ipairs(Enemies) do
        if unit and unit.isEnemy then
		count = count + 1
		end
	end
	return count
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0 and not unit.dead) then
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

function GetTarget(range) 
	if _G.SDK then
		if myHero.ap > myHero.totalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
		end
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end
end

function GetMode()   
    if _G.SDK then
        return 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "LaneClear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] and "LaneClear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] and "LastHit"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] and "Flee"
		or nil
    
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetMode()
	end
	return nil
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
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
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

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 775 + unit.boundingRadius / 2) 
		local TRange = range * range
		if GetDistanceSqr(turret.pos, unit.pos) < TRange then
			return true
		end
    end
    return false
end

local function AllyMinionUnderTower()
	local Minions = GetMinions(1500, 2)
	if next(Minions) == nil then return false end
	for i = 1, #Minions do
		local minion = Minions[i]
		if IsValid(minion) and IsUnderTurret(minion) then
			return true
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
	return false
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
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 or buff.type == 22 or buff.name == 8 ) and buff.count > 0 then
			return true
		end
	end
	return false	
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

local function CheckDmgItems(itemID)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
    for _, j in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}) do
        if myHero:GetItemData(j).itemID == itemID then return j end
    end
    return nil
end

function CalcExtraDmg(unit, typ) -- typ 1 = minion / typ 2 = Enemy
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
		total = total + CalcMagicalDamage(myHero, unit, (12 + (3 * LvL)) + 0.25 * myHero.bonusDamage)
	end
	
	if BladeKing then
		if typ == 1 then
			if unit.health*0.1 > 60 then
				total = total + CalcPhysicalDamage(myHero, unit, 60)
			else	
				total = total + CalcPhysicalDamage(myHero, unit, (unit.health*0.1))
			end
		else
			total = total + CalcPhysicalDamage(myHero, unit, (unit.health*0.1) + (HasBuff(myHero, "3153speed") and CalcMagicalDamage(myHero, unit, 35+4.5*LvL) or 0))
		end
	end
	
	if WitsEnd and myHero:GetSpellData(WitsEnd).currentCd == 0 then
		total = total + CalcMagicalDamage(myHero, unit, 11.1 + (3.8 * LvL))
	end

	if RecurveBow and myHero:GetSpellData(RecurveBow).currentCd == 0 then
		total = total + CalcPhysicalDamage(myHero, unit, 15)
	end	
	
	if Titanic and myHero:GetSpellData(Titanic).currentCd == 0 then
		total = total + CalcPhysicalDamage(myHero, unit, (myHero.maxHealth*0.01) + (5+myHero.maxHealth*0.015))
	end	

	if Sheen and myHero:GetSpellData(Sheen).currentCd == 0 then 
		total = total + CalcPhysicalDamage(myHero, unit, myHero.baseDamage)
	end	

	if Divine and myHero:GetSpellData(Divine).currentCd == 0 then  
		if typ == 1 then
			if unit.maxHealth*0.1 < 1.5*myHero.baseDamage then
				total = total + CalcPhysicalDamage(myHero, unit, 1.5*myHero.baseDamage)
			else
				if unit.maxHealth*0.1 > 2.5*myHero.baseDamage then
					total = total + CalcPhysicalDamage(myHero, unit, 2.5*myHero.baseDamage)
				else
					total = total + CalcPhysicalDamage(myHero, unit, unit.maxHealth*0.1)
				end
			end
		else
			if unit.maxHealth*0.1 < 1.5*myHero.baseDamage then
				total = total + CalcPhysicalDamage(myHero, unit, 1.5*myHero.baseDamage)
			else
				total = total + CalcPhysicalDamage(myHero, unit, unit.maxHealth*0.1)
			end
		end
	end	

	if typ == 2 and Black then 
		local Buff = GetBuffData(unit, "3071blackcleavermainbuff")
		if Buff.count == 6 then
			total = total + CalcPhysicalDamage(myHero, unit, (unit.maxHealth-unit.health)*0.05)
		end	
	end

	if Trinity and myHero:GetSpellData(Trinity).currentCd == 0 then 		
		total = total + CalcPhysicalDamage(myHero, unit, 2*myHero.baseDamage) 	
	end

	if typ == 2 and Eclipse and myHero:GetSpellData(Eclipse).currentCd > 6.5 then 
		total = total + CalcPhysicalDamage(myHero, unit, unit.maxHealth*0.06)
	end	
	return total		
end

local function ISMarked(range)
	local NearestTarget = nil
	local Range = range*range	
	for i, unit in ipairs(GetEnemyHeroes()) do
		if NearestTarget == nil then
			if unit and GetDistanceSqr(myHero.pos, unit.pos) <= Range and IsValid(unit) then
				local Buff = GetBuffData(unit, "ireliamark")
				local time = GetDistance(myHero.pos, unit.pos) / (1500+myHero.ms)
				if Buff and Buff.duration > time then
					NearestTarget = unit
				end
			end
		else
			if unit and unit ~= NearestTarget and GetDistanceSqr(myHero.pos, unit.pos) <= Range and IsValid(unit) and GetDistance(myHero.pos, unit.pos) < GetDistance(myHero.pos, NearestTarget.pos) then
				local Buff = GetBuffData(unit, "ireliamark")
				local time = GetDistance(myHero.pos, unit.pos) / (1500+myHero.ms)
				if Buff and Buff.duration > time then
					NearestTarget = unit
				end
			end		
		end	
	end	
	return NearestTarget
end

local function Widesttarget(range)
	local Target = nil
	local Range = range*range	
	for i, unit in ipairs(GetEnemyHeroes()) do
		if Target == nil then
			if unit and GetDistanceSqr(myHero.pos, unit.pos) <= Range and IsValid(unit) then
				Target = unit
			end
		else
			if unit and unit ~= Target and GetDistanceSqr(myHero.pos, unit.pos) <= Range and IsValid(unit) and GetDistance(myHero.pos, unit.pos) > GetDistance(myHero.pos, Target.pos) then
				Target = unit
			end		
		end	
	end	
	return Target
end

local function GetKillableMinion()
	if Ready(_Q) and KillMinion == nil then
		local Minions = GetMinions(600, 1)
		if next(Minions) == nil then return end
		for i = 1, #Minions do
			local minion = Minions[i]
			local QDmg = getdmg("Q", minion, myHero, 2) + CalcExtraDmg(minion, 1)
			if minion.team == TEAM_ENEMY and QDmg > minion.health and IsValid(minion) then				
				KillMinion = minion
				return
			end
		end	
	end
end

local function WDamage(unit)
	local WDmg = getdmg("W", unit, myHero)
	local Buff = GetBuffData(myHero, "ireliawdefense")
	local ChargeTime = clock() - WStart
	
	if Buff then
		if ChargeTime < 0.08 then
			return WDmg 				
		elseif ChargeTime >= 0.08 and ChargeTime < 0.15 then
			return WDmg + WDmg*0.1
		elseif ChargeTime >= 0.15 and ChargeTime < 0.23 then
			return WDmg + WDmg*0.2
		elseif ChargeTime >= 0.23 and ChargeTime < 0.3 then
			return WDmg + WDmg*0.3
		elseif ChargeTime >= 0.3 and ChargeTime < 0.38 then
			return WDmg + WDmg*0.4
		elseif ChargeTime >= 0.38 and ChargeTime < 0.45 then
			return WDmg + WDmg*0.5
		elseif ChargeTime >= 0.45 and ChargeTime < 0.53 then
			return WDmg + WDmg*0.6
		elseif ChargeTime >= 0.53 and ChargeTime < 0.6 then
			return WDmg + WDmg*0.7
		elseif ChargeTime >= 0.6 and ChargeTime < 0.68 then
			return WDmg + WDmg*0.8
		elseif ChargeTime >= 0.68 and ChargeTime < 0.75 then
			return WDmg + WDmg*0.9
   		else
			return WDmg*2
		end
	else
		return WDmg
	end
end

local function DistanceSquared(p1, p2)
	local dx, dy = p2.x - p1.x, p2.y - p1.y
	return math.floor((dx * dx + dy * dy)/10000)
end

local function LineCircleIntersection(p1, p2, circle, radius)
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
	local PredPos = nil
	local Count = 0
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 800 and IsValid(minion) then
			
			local predictedPos = PredictUnitPosition(minion, delay+ GetDistance(source, minion.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (minion.boundingRadius + width) * (minion.boundingRadius + width)) then
				Count = Count + 1
				PredPos = predictedPos
			end
		end
	end
	return PredPos, Count
end

----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Irelia"



Callback.Add("Load", function()	
	if table.contains(Heroes, myHero.charName) then	
		_G[myHero.charName]()
		LoadUnits()	
	end	
end)




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
    
    local Version = 0.39
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyIrelia.lua",
            Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/PussyIrelia.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyIrelia.version",
            Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/PussyIrelia.version"
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
		if buff and (buff.type == 5 or buff.type == 8 or buff.type == 12 or buff.type == 22 or buff.type == 23 or buff.type == 25 or buff.type == 30 or buff.type == 35 or buff.name == "recall") and buff.count > 0 then
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


local RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 160, Range = 950, Speed = 2000, Collision = false}
local RspellData = {speed = 2000, range = 950, delay = 0.25 + ping, radius = 160, collision = {nil}, type = "linear"}

local WData = {Type = _G.SPELLTYPE_LINE, Delay = 0.6 + ping, Radius = 80, Range = 825, Speed = MathHuge, Collision = false}
local WspellData = {speed = MathHuge, range = 825, delay = 0.6 + ping, radius = 80, collision = {nil}, type = "linear"}

local EData = {Type = _G.SPELLTYPE_LINE, Delay = 0.4 + ping, Radius = 35, Range = 850, Speed = MathHuge, Collision = false}
local EspellData = {speed = MathHuge, range = 850, delay = 0.4 + ping, radius = 35, collision = {nil}, type = "linear"}

local E2Data = {Type = _G.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 35, Range = 850, Speed = MathHuge, Collision = false}
local E2spellData = {speed = MathHuge, range = 850, delay = 0.25 + ping, radius = 35, collision = {nil}, type = "linear"}

function Irelia:__init()
	self:LoadMenu()

	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	--Callback.Add("WndMsg",function(msg, param) self:OnWndMsg(msg, param) end)	

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

function Irelia:LoadMenu()                     	
--MainMenu
self.Menu = MenuElement({type = MENU, id = "Irelia", name = "PussyIrelia"})
self.Menu:MenuElement({name = " ", drop = {"Version 0.38"}})

	--ComboMenu 
self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})
	 	
	self.Menu.ComboSet:MenuElement({name = " ", drop = {"[Q] not an option, we need Q for an optimal combo"}})	
	self.Menu.ComboSet:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.ComboSet:MenuElement({id = "ImmoW", name = "[W-Shield] If Irelia Immobile", value = true})	
	self.Menu.ComboSet:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.ComboSet:MenuElement({id = "Flash", name = "[SummonerFlash] if out of E2 range for Kill", value = true})		
	self.Menu.ComboSet:MenuElement({id = "UseRKill", name = "[R] if Enemy killable with full BurstDmg", value = true})	
	self.Menu.ComboSet:MenuElement({id = "UseRCount", name = "[R] Try hit multiple Enemies", value = true})	
	self.Menu.ComboSet:MenuElement({id = "RCount", name = "[R] Multiple Enemies", value = 3, min = 1, max = 5})	


	--HarassMenu
self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})	
	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] if marked Enemy + back killable Minion", value = true})
	self.Menu.Harass:MenuElement({id = "UseQ2", name = "[Q] Farm Minions", value = true})
	self.Menu.Harass:MenuElement({id = "Q2Range", name = "[Q] Farm if range Enemy/Minion bigger than", value = 350, min = 0, max = 1000, step = 10})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Harass:MenuElement({id = "ImmoW", name = "[W-Shield] if Irelia Immobile", value = true})	
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})



self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "UseE", name = "[E]", value = true})		
	self.Menu.ClearSet.Clear:MenuElement({id = "ECount", name = "[E] Min Minions", value = 3, min = 1, max = 7, step = 1})	
	self.Menu.ClearSet.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 30, min = 0, max = 100, identifier = "%"})
	
	--JungleClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "UseW", name = "[W]", value = false})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 30, min = 0, max = 100, identifier = "%"})

	--LastHitMode Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "LastHit", name = "LastHit Mode"})
	self.Menu.ClearSet.LastHit:MenuElement({name = " ", drop = {"Default Hotkey = [X]"}})	
	self.Menu.ClearSet.LastHit:MenuElement({id = "UseQ", name = "[Q] if out of AA range", value = true})
	self.Menu.ClearSet.LastHit:MenuElement({id = "Mana", name = "Min Mana", value = 30, min = 0, max = 100, identifier = "%"})	


	--Misc			
self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})

	self.Menu.MiscSet:MenuElement({type = MENU, id = "Rrange", name = "Ultimate Range setting"})
	self.Menu.MiscSet.Rrange:MenuElement({id = "R", name = "Max Cast range [R]", value = 850, min = 0, max = 950, step = 10})		

	--Flee
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Flee", name = "Flee Mode"})
	self.Menu.MiscSet.Flee:MenuElement({name = " ", drop = {"Default Hotkey = [A]"}})	
	self.Menu.MiscSet.Flee:MenuElement({id = "Q", name = "[Q]", value = true})	
	self.Menu.MiscSet.Flee:MenuElement({id = "Q2", name = "[Q] even on non killable Minions", value = false})		
			
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
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
end	

local SummFlash = 0
local FlashSlot 

function Irelia:Tick()		
	if SummFlash == 0 then
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
			SummFlash = 1
			FlashSlot = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
			SummFlash = 1
			FlashSlot = SUMMONER_2
		else
			SummFlash = 2
		end
	end
	
	if not heroes then 
		local EnemyCount = CheckLoadedEnemies()			
		if EnemyCount == 0 then
			LoadUnits()
		else
			heroes = true
		end	
 	end
	
	if Control.IsKeyDown(HK_W) and (not Ready(_W) or clock() - WStart >= 1.5) then
		SetMovement(true)
		Control.KeyUp(HK_W)
	end
	
	if myHero:GetSpellData(_E).name ~= "IreliaE2" then
		SetMovement(true)
	end
	
	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		self:Ninja()			
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "LaneClear" then
		self:Clear()
		self:JungleClear()
	elseif Mode == "Flee" then
		self:Flee()
	elseif Mode == "LastHit" then
		self:LastHit()
	end
end

function Irelia:Ninja()	
	if Ready(_Q) and GetEnemyCount(2000, myHero) >= 2 then	

		for i, hero in ipairs(GetEnemyHeroes()) do
			
			if hero and GetDistanceSqr(myHero.pos, hero.pos) < 2000*2000 and IsValid(hero) then	
				local Buff = GetBuffData(hero, "ireliamark")
				local time = GetDistance(myHero.pos, hero.pos) / (1500+myHero.ms)
				local Range = 600*600				
				
				if Buff and Buff.duration > time then					
					local QDmg2 = (getdmg("Q", hero, myHero, 1) + CalcExtraDmg(hero, 2))*2
					if QDmg2 > hero.health then
						if GetDistance(myHero.pos, hero.pos) < 600 then
							if CheckHPPred(hero) >= 1 then
								Control.CastSpell(HK_Q, hero)	 
								LastQ =((GetDistance(myHero.pos, hero.pos)/(1500+myHero.ms)*1000)+50)
							else
								self:Combo()
							end	
						else
							for k, hero2 in ipairs(GetEnemyHeroes()) do
								local Buff2 = GetBuffData(hero2, "ireliamark")
								local time2 = GetDistance(myHero.pos, hero2.pos) / (1500+myHero.ms)
								local Range = 600*600							
								if hero2 and hero2 ~= hero and Buff2 and Buff2.duration > time2 then
									if GetDistance(hero2.pos, hero.pos) < 600 then
										if GetDistance(myHero.pos, hero2.pos) < 600 then
											Control.CastSpell(HK_Q, hero2)	 
											LastQ =((GetDistance(myHero.pos, hero2.pos)/(1500+myHero.ms)*1000)+50)										
										else
											GetKillableMinion()
											if KillMinion and GetDistance(KillMinion.pos, hero2.pos) < GetDistance(hero2.pos, myHero.pos) then
												if CheckHPPred(KillMinion) >= 1 then
													Control.CastSpell(HK_Q, KillMinion)	 
													LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
													KillMinion = nil
												else
													self:Combo()
													KillMinion = nil											
												end
											else
												self:Combo()
											end
										end	
									else
										GetKillableMinion()
										if KillMinion and GetDistance(KillMinion.pos, hero.pos) < GetDistance(hero.pos, myHero.pos) then
											if CheckHPPred(KillMinion) >= 1 then
												Control.CastSpell(HK_Q, KillMinion)	 
												LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
												KillMinion = nil
											else
												self:Combo()
												KillMinion = nil											
											end
										else
											self:Combo()
										end	
									end
								else
									GetKillableMinion()
									if KillMinion and GetDistance(KillMinion.pos, hero.pos) < GetDistance(hero.pos, myHero.pos) then
										if CheckHPPred(KillMinion) >= 1 then
											Control.CastSpell(HK_Q, KillMinion)	 
											LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
											KillMinion = nil
										else
											self:Combo()
											KillMinion = nil										
										end	
									else
										self:Combo()
									end	
								end
							end		
						end	
					else						
						if GetDistance(myHero.pos, hero.pos) < 600 then 
							Control.CastSpell(HK_Q, hero)	 
							LastQ =((GetDistance(myHero.pos, hero.pos)/(1500+myHero.ms)*1000)+50)	
		
						else
							GetKillableMinion()
							if KillMinion and GetDistance(KillMinion.pos, hero.pos) < GetDistance(hero.pos, myHero.pos) then	
								if CheckHPPred(KillMinion) >= 1 then						
									Control.CastSpell(HK_Q, KillMinion)	 
									LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
									KillMinion = nil
								else
									self:Combo()
									KillMinion = nil
								end
							else
								self:Combo()
							end
						end	
					end		
				else
					self:Combo()	
				end
			end	
		end
	else
		self:Combo()
	end	
end

function Irelia:Combo()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target) then
	local BuffedTarget = ISMarked(1200)	
		
		if Control.IsKeyDown(HK_W) then self:CheckCastW(target) return end			
		
		if Ready(_R) and GetDistance(myHero.pos, target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and self.Menu.ComboSet.UseRCount:Value() and myHero:GetSpellData(_E).name ~= "IreliaE2" then
			local count = GetEnemyCount(400, target)
			if count >= self.Menu.ComboSet.RCount:Value() then					
				self:CastR(target)
			else
				if self.Menu.ComboSet.UseE:Value() and Ready(_E) and not IsImmobileTarget(target) and not ISMarked(650) then
					self:CheckCastE(target)
				end			
			end
					
		
		elseif self.Menu.ComboSet.UseE:Value() and Ready(_E) and not IsImmobileTarget(target) and not ISMarked(650) then
			self:CheckCastE(target)
		end
		
		if Ready(_R) and GetDistance(myHero.pos, target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and self.Menu.ComboSet.UseRKill:Value() and not ISMarked(650) and myHero:GetSpellData(_E).name ~= "IreliaE2" then
			local Passive = CalcExtraDmg(target, 2)*3
			local QDmg = Ready(_Q) and getdmg("Q", target, myHero, 1)*3 or 0
			local WDmg = Ready(_W) and getdmg("W", target, myHero) or 0
			local EDmg = Ready(_E) and getdmg("E", target, myHero) or 0
			local RDmg = getdmg("R", target, myHero)
			local AADmg = getdmg("AA", target, myHero)*2
			local FullDmg = Passive+QDmg+WDmg+EDmg+RDmg+AADmg
			if FullDmg >= target.health then					
				self:CastR(target)
			else
				if self.Menu.ComboSet.UseE:Value() and Ready(_E) and not IsImmobileTarget(target) and not ISMarked(650) then
					self:CheckCastE(target)
				end			
			end
					
		
		elseif self.Menu.ComboSet.UseE:Value() and Ready(_E) and not IsImmobileTarget(target) and not ISMarked(650) then
			self:CheckCastE(target)
		end		
			
		if Ready(_Q) then
			if BuffedTarget then
				local Q2Dmg = (getdmg("Q", BuffedTarget, myHero, 1) + CalcExtraDmg(BuffedTarget, 2))*2
				if Q2Dmg > BuffedTarget.health then
					if GetDistance(myHero.pos, BuffedTarget.pos) < 600 then
						if CheckHPPred(BuffedTarget) >= 1 then
							Control.CastSpell(HK_Q, BuffedTarget)	 
							LastQ =((GetDistance(myHero.pos, BuffedTarget.pos)/(1500+myHero.ms)*1000)+50)
						end	
					else
						GetKillableMinion()
						if KillMinion and GetDistance(KillMinion.pos, BuffedTarget.pos) < GetDistance(myHero.pos, BuffedTarget.pos) then
							if CheckHPPred(KillMinion) >= 1 then
								Control.CastSpell(HK_Q, KillMinion)	 
								LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
								KillMinion = nil
							else
								KillMinion = nil
							end	
						end						
					end
				else
					if GetDistance(myHero.pos, BuffedTarget.pos) < 600 then
						Control.CastSpell(HK_Q, BuffedTarget)	 
						LastQ =((GetDistance(myHero.pos, BuffedTarget.pos)/(1500+myHero.ms)*1000)+50)	
					else
						GetKillableMinion()
						if KillMinion and GetDistance(KillMinion.pos, BuffedTarget.pos) < GetDistance(BuffedTarget.pos, myHero.pos) then
							if not IsUnderTurret(KillMinion) then							
								if CheckHPPred(KillMinion) >= 1 then
									Control.CastSpell(HK_Q, KillMinion)	 
									LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
									KillMinion = nil
								else
									KillMinion = nil
								end
							end	
						end	
					end	
				end
			else
				local QDmg = (getdmg("Q", target, myHero, 1) + CalcExtraDmg(target, 2))
				if QDmg > target.health then
					if GetDistance(myHero.pos, target.pos) < 600 then
						if CheckHPPred(target) >= 1 then
							Control.CastSpell(HK_Q, target)	 
							LastQ =((GetDistance(myHero.pos, target.pos)/(1500+myHero.ms)*1000)+50)
						end	
					else
						GetKillableMinion()
						if KillMinion and GetDistance(KillMinion.pos, target.pos) < GetDistance(target.pos, myHero.pos) then
							if CheckHPPred(KillMinion) >= 1 then
								Control.CastSpell(HK_Q, KillMinion)	 
								LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
								KillMinion = nil
							else
								KillMinion = nil
							end
						end						
					end
				else
					if GetDistance(myHero.pos, target.pos) <= 600 and myHero:GetSpellData(_E).name ~= "IreliaE2" then
						if not HasBuff(myHero, "ireliapassivestacksmax") then
							GetKillableMinion()
							if KillMinion and GetDistance(myHero.pos, KillMinion.pos) < 600 and GetDistance(KillMinion.pos, target.pos) <= 400 then
								if not IsUnderTurret(KillMinion) then	
									if CheckHPPred(KillMinion) >= 1 then						
										CastSpell(HK_Q, KillMinion, LastQ)	 
										LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
										KillMinion = nil
									else
										KillMinion = nil
									end	
								end
							end
						end	
					end				
				end	
			end	
		end
		
		if self.Menu.ComboSet.ImmoW:Value() and Ready(_W) and not HasBuff(myHero, "ireliawdefense") then
			if IsImmobileTarget(myHero) and myHero:GetSpellData(_E).name ~= "IreliaE2" then					
				SetMovement(false)
				Control.KeyDown(HK_W)
				WStart = clock()
			end
		end	
		
		if self.Menu.ComboSet.UseW:Value() and Ready(_W) and not Ready(_E) then
			if GetDistance(myHero.pos, target.pos) <= 550 and not IsImmobileTarget(myHero) then									
				if myHero:GetSpellData(_E).name ~= "IreliaE2" and not HasBuff(myHero, "ireliawdefense") and not ISMarked(650) then
					SetMovement(false)
					Control.KeyDown(HK_W)
					WStart = clock()
				end	
			end
		end		
	end	
end	

function Irelia:Harass()
local target = GetTarget(1100)     	
if target == nil then return end 
	if IsValid(target) then
				
		if Control.IsKeyDown(HK_W) then self:CheckCastW(target) return end
		
		if self.Menu.Harass.UseE:Value() and Ready(_E) and not IsImmobileTarget(target) then
			self:CheckCastE(target)	
		end		
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and HasBuff(target, "ireliamark") and myHero.pos:DistanceTo(target.pos) <= 600 and not IsUnderTurret(target) then
			GetKillableMinion()
			if KillMinion and not IsUnderTurret(KillMinion) and GetDistance(KillMinion.pos, target.pos) < 600 and GetDistance(KillMinion.pos, target.pos) > 300 then
				if Control.CastSpell(HK_Q, target) then	
					LastQ =((GetDistance(myHero.pos, target.pos)/(1500+myHero.ms)*1000)+50)
					if CheckHPPred(KillMinion) >= 1 then
						CastSpell(HK_Q, KillMinion, LastQ)	 
						LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
						KillMinion = nil
					else
						KillMinion = nil
					end
				end	
			end
		end
		
		if self.Menu.Harass.UseQ2:Value() and Ready(_Q) then
			GetKillableMinion()
			if KillMinion and not IsUnderTurret(KillMinion) and GetDistance(KillMinion.pos, target.pos) > self.Menu.Harass.Q2Range:Value() and GetDistance(KillMinion.pos, myHero.pos) < 600 then	
				if CheckHPPred(KillMinion) >= 1 then
					CastSpell(HK_Q, KillMinion, LastQ)	 
					LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
					KillMinion = nil
				else
					KillMinion = nil
				end	
			end
		end	
		
		if self.Menu.Harass.ImmoW:Value() and Ready(_W) and not HasBuff(myHero, "ireliawdefense") then
			if IsImmobileTarget(myHero) and myHero:GetSpellData(_E).name ~= "IreliaE2" then					
				SetMovement(false)
				Control.KeyDown(HK_W)
				WStart = clock()
			end
		end	
		
		if self.Menu.Harass.UseW:Value() and Ready(_W) and not Ready(_E) then
			if GetDistance(myHero.pos, target.pos) <= 550 and not IsImmobileTarget(myHero) then									
				if myHero:GetSpellData(_E).name ~= "IreliaE2" and not HasBuff(myHero, "ireliawdefense") and not HasBuff(target, "ireliamark") then
					SetMovement(false)
					Control.KeyDown(HK_W)
					WStart = clock()
				end	
			end
		end				
	end	
end

function Irelia:Clear()
	if myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
		if self.Menu.ClearSet.Clear.UseQ:Value() and Ready(_Q) and myHero:GetSpellData(_E).name ~= "IreliaE2" then
			GetKillableMinion()		
			if KillMinion then
				if not IsUnderTurret(KillMinion) then	
					if CheckHPPred(KillMinion) >= 1 then						
						CastSpell(HK_Q, KillMinion, LastQ)	 
						LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
						KillMinion = nil
					else
						KillMinion = nil
					end	
				else  
					if AllyMinionUnderTower() then
						if CheckHPPred(KillMinion) >= 1 then						
							CastSpell(HK_Q, KillMinion, LastQ)	 
							LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
							KillMinion = nil
						else
							KillMinion = nil
						end	
					end	
				end	
			end	
		end
	end	
	
	if self.Menu.ClearSet.Clear.UseE:Value() and Ready(_E) then
		local Minions = GetMinions(800, 1)
		if next(Minions) == nil then return end
		for i = 1, #Minions do
			local minion = Minions[i]		
			if minion.team == TEAM_ENEMY then
				local CastPos, Count = GetLineTargetCount(myHero.pos, minion.pos, 0.25+ping, 2500, 35)
				if CastPos and Count >= self.Menu.ClearSet.Clear.ECount:Value() then
					local E2pos = Vector(CastPos) + (Vector(myHero.pos) - Vector(CastPos)): Normalized() * -800
					--DrawCircle(E2pos, 50, 1, DrawColor(255, 225, 255, 10))
					if myHero:GetSpellData(_E).name == "IreliaE" then
						Control.CastSpell(HK_E, myHero.pos)
					end
					if myHero:GetSpellData(_E).name == "IreliaE2" then
						Control.CastSpell(HK_E, E2pos)
					end					
				end
			end	
		end	
	end
end

function Irelia:JungleClear()
	local Minions = GetMinions(800, 3)
	if next(Minions) == nil then return end
	for i = 1, #Minions do
		local minion = Minions[i]
		
		if minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 then
 			
			if Control.IsKeyDown(HK_W) then self:CheckCastW(minion) return end
		
			if self.Menu.ClearSet.JClear.UseE:Value() and Ready(_E) then
				if myHero:GetSpellData(_E).name ~= "IreliaE2" then
					local CastPos1 = Vector(minion.pos) + (Vector(myHero.pos) - Vector(minion.pos)): Normalized() * 150
					Control.CastSpell(HK_E, CastPos1)	
				else
					if Ready(_E) then
						local CastPos2 = Vector(minion.pos) + (myHero.pos - Vector(minion.pos)): Normalized() * -150
						SetMovement(false)
						Control.CastSpell(HK_E, CastPos2)						
					end	
				end
			end	
			
			if self.Menu.ClearSet.JClear.UseW:Value() and Ready(_W) and not Ready(_E) then
				if myHero:GetSpellData(_E).name ~= "IreliaE2" and not HasBuff(myHero, "ireliawdefense") and not HasBuff(minion, "ireliamark") then
					SetMovement(false)
					Control.KeyDown(HK_W)
					WStart = clock()
				end	                  
            end           				
			
			if self.Menu.ClearSet.JClear.UseQ:Value() and Ready(_Q) and GetDistance(myHero.pos, minion.pos) < 600 and myHero:GetSpellData(_E).name ~= "IreliaE2" then
				if HasBuff(minion, "ireliamark") then
					if CheckHPPred(minion) >= 1 then						
						CastSpell(HK_Q, minion, LastQ)	 
						LastQ =((GetDistance(myHero.pos, minion.pos)/(1500+myHero.ms)*1000)+50)
					end					
				end
			
				local QDmg = getdmg("Q", minion, myHero, 1) + CalcExtraDmg(minion, 1) 
				if QDmg > minion.health then
					if CheckHPPred(minion) >= 1 then						
						CastSpell(HK_Q, minion, LastQ)	 
						LastQ =((GetDistance(myHero.pos, minion.pos)/(1500+myHero.ms)*1000)+50)
					end	
				end	
			end	
        end
    end
end

function Irelia:LastHit()           
	if self.Menu.ClearSet.LastHit.UseQ:Value() and Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.LastHit.Mana:Value() / 100 then
		GetKillableMinion()		
		if KillMinion and GetDistance(myHero.pos, KillMinion.pos) > myHero.range then
			if not IsUnderTurret(KillMinion) then	
				if CheckHPPred(KillMinion) >= 1 then						
					CastSpell(HK_Q, KillMinion, LastQ)	 
					LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
					KillMinion = nil
				else
					KillMinion = nil
				end	
			else  
				if AllyMinionUnderTower() then
					if CheckHPPred(KillMinion) >= 1 then						
						CastSpell(HK_Q, KillMinion, LastQ)	 
						LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
						KillMinion = nil
					else
						KillMinion = nil
					end	
				end	
			end	
		end
	end	
end	

function Irelia:Flee()
	if self.Menu.MiscSet.Flee.Q:Value() and Ready(_Q) then
		GetKillableMinion()		
		if KillMinion and GetDistance(KillMinion.pos, mousePos) < 500 then
			if not IsUnderTurret(KillMinion) then	
				if CheckHPPred(KillMinion) >= 1 then						
					CastSpell(HK_Q, KillMinion, LastQ)	 
					LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
					KillMinion = nil
				else
					KillMinion = nil
				end	
			else  
				if AllyMinionUnderTower() then
					if CheckHPPred(KillMinion) >= 1 then						
						CastSpell(HK_Q, KillMinion, LastQ)	 
						LastQ =((GetDistance(myHero.pos, KillMinion.pos)/(1500+myHero.ms)*1000)+50)
						KillMinion = nil
					else
						KillMinion = nil
					end	
				end	
			end
		else
			if self.Menu.MiscSet.Flee.Q2:Value() then
				local Minions = GetMinions(600, 1)
				if next(Minions) == nil then return end
				for i = 1, #Minions do
					local minion = Minions[i]
					if IsValid(minion)	then
						Control.CastSpell(HK_Q, minion)	 
						LastQ =((GetDistance(myHero.pos, minion.pos)/(1500+myHero.ms)*1000)+50)					
					end
				end	
			end
		end			
	end
end

function Irelia:CheckCastW(unit)
    
	if GetDistance(unit.pos, myHero.pos) < 600 and Ready(_Q) then
		local WDmg = WDamage(unit)
		local QDmg = getdmg("Q", unit, myHero, 1) + CalcExtraDmg(unit, 2)
		local BuffedTarget = ISMarked(600)
		if BuffedTarget then
			if (WDmg+QDmg*2) > unit.health and CheckHPPred(unit) >= 1 then
				self:CastW(unit)
			end
		else
			if (WDmg+QDmg) > unit.health and CheckHPPred(unit) >= 1 then
				self:CastW(unit)
			end		
		end		
	end
	
	if GetDistance(unit.pos, myHero.pos) < 825 then
		
		local WDmg = WDamage(unit) 
		if WDmg > unit.health then
			self:CastW(unit)
		end
		
		if not IsImmobileTarget(myHero) then
			if GetDistance(unit.pos, myHero.pos) > 670 then
				self:CastW(unit)				
			elseif clock() - WStart >= 0.75 then
				self:CastW(unit)				
			end
		else
			if clock() - WStart >= 1.4 then
				self:CastW(unit)
			end
		end	
	end
end

local function SetDist(start, path, center, dist)
	local a = start.x - center.x
	local b = start.y - center.y
	local c = start.z - center.z
	local x = path.x
	local y = path.y
	local z = path.z

	local n1 = a * x + b * y + c * z
	local n2 =
		z ^ 2 * dist ^ 2 - a ^ 2 * z ^ 2 - b ^ 2 * z ^ 2 + 2 * a * c * x * z + 2 * b * c * y * z + 2 * a * b * x * y +
		dist ^ 2 * x ^ 2 +
		dist ^ 2 * y ^ 2 -
		a ^ 2 * y ^ 2 -
		b ^ 2 * x ^ 2 -
		c ^ 2 * x ^ 2 -
		c ^ 2 * y ^ 2
	local n3 = x ^ 2 + y ^ 2 + z ^ 2

	local r1 = -(n1 + math.sqrt(n2)) / n3
	local r2 = -(n1 - math.sqrt(n2)) / n3
	local r = math.max(r1, r2)

	return start + r * path
end

function Irelia:CheckCastE(unit)
	
	if GetDistance(unit.pos, myHero.pos) <= 760 then               	
		if myHero:GetSpellData(_E).name ~= "IreliaE2" then
			local pathStartPos = Vector(unit.pathing.startPos)
			local pathEndPos = Vector(unit.pathing.endPos)
			local pathNorm = (pathEndPos - pathStartPos):Normalized()
			local Predpos = self:CastE1(unit)

			if unit.pathing.pathCount == 0 then
				if Predpos then
					local cast1Pos = Vector(myHero.pos) + (Predpos - Vector(myHero.pos)):Normalized() * 700
					Control.CastSpell(HK_E, cast1Pos)
				end
			else
				if Predpos then
					local dist1 = GetDistance(Predpos, myHero.pos)
					local dist2 = GetDistance(unit.pos, myHero.pos)
					if dist1 < dist2 then
						pathNorm = pathNorm * -1
					end
					local cast2Pos = SetDist(Predpos, pathNorm, Vector(myHero.pos), 700)
					Control.CastSpell(HK_E, cast2Pos)
				end
			end
		else				
			local pos2 = self:CastE2(unit, myHero)
			if pos2 then
				if Ready(_E) then
					SetMovement(false)
					Control.CastSpell(HK_E, pos2)
					SetMovement(true)
				end
			else
				local E2Buff = GetBuffData(myHero, "IreliaE")
				if E2Buff and E2Buff.duration <= 1 and GetMode() == "Combo" and myHero:GetSpellData(_E).name == "IreliaE2" and self.Menu.ComboSet.Flash:Value() and SummFlash == 1 and GetDistance(unit.pos, myHero.pos) <= 1300 then 
					local Passive = CalcExtraDmg(unit, 2)*2
					local QDmg = Ready(_Q) and getdmg("Q", unit, myHero, 1)*2 or 0
					local WDmg = Ready(_W) and getdmg("W", unit, myHero) or 0
					local EDmg = Ready(_E) and getdmg("E", unit, myHero) or 0
					local RDmg = Ready(_R) and getdmg("R", unit, myHero) or 0
					local AADmg = getdmg("AA", unit, myHero)*2
					local FullDmg = Passive+QDmg+WDmg+EDmg+RDmg+AADmg
										
					if FullDmg >= unit.health then
						local Fpos = myHero.pos + (myHero.pos-unit.pos):Normalized() * -600
						if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
							Control.CastSpell(HK_SUMMONER_1, Fpos)
						elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
							Control.CastSpell(HK_SUMMONER_2, Fpos)
						end
					end			
				end				
			end
		end
	end	
end	

function Irelia:CastE1(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, EData, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredE:Value()+1 then
			return pred.CastPosition
		end
	elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), pred.HitChance) then
			return pred.CastPos
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = ping, Radius = 70, Range = 700, Speed = 2500, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(self.Menu.MiscSet.Pred.PredE:Value()+1) then
			return EPrediction.CastPosition
		end		
	end
end

function Irelia:CastE2(unit, StartPos)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, E2Data, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredE:Value()+1 then
			return pred.CastPosition
		end
	elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, E2spellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), pred.HitChance) then
			return pred.CastPos
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 70, Range = 750, Speed = 2500, Collision = false})
		EPrediction:GetPrediction(unit, StartPos)
		if EPrediction:CanHit(self.Menu.MiscSet.Pred.PredE:Value()+1) then
			return EPrediction.CastPosition
		end		
	end	
end

function Irelia:CastW(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredW:Value()+1 then
			Control.CastSpell(HK_W, pred.CastPosition)
			SetMovement(true)
		end
	elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredW:Value(), pred.HitChance) then
			Control.CastSpell(HK_W, pred.CastPos)
			SetMovement(true)
		end
	else
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 60, Range = 750, Speed = MathHuge, Collision = false})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(self.Menu.MiscSet.Pred.PredW:Value()+1) then
			Control.CastSpell(HK_W, WPrediction.CastPosition)
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
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4 + ping, Radius = 160, Range = 900, Speed = 2000, Collision = false})
		RPrediction:GetPrediction(unit, myHero)
		if RPrediction:CanHit(self.Menu.MiscSet.Pred.PredR:Value()+1) then
			Control.CastSpell(HK_R, RPrediction.CastPosition)
		end		
	end
end	
 
function Irelia:Draw()
	if heroes == false then
		Draw.Text(myHero.charName.." is Loading (Search Enemies) !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 255, 0, 0))
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
end
	
Callback.Add("Load", function()	
	if table.contains(Heroes, myHero.charName) then	
		_G[myHero.charName]()
		LoadUnits()	
	end	
end)




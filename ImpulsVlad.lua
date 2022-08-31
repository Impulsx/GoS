local LoadCallbacks = {}

local currentData = {
    Champions = {
        Vladimir = {
            Version = 1.00,
            Changelog = "Vladimir Initial Release",
        },
    },
    Loader = {
        Version = 1.00,
    },
    Dependencies = {
        commonLib = {
            Version = 1.00,
        },
        prediction = {
            Version = 1.00,
        },
        changelog = {
            Version = 1.00,
        },
        callbacks = {
            Version = 1.00,
        },
        menuLoad = {
            Version = 1.00,
        },
    },
    Utilities = {
        baseult = {
            Version = 0,
        },
        evade = {
            Version = 0,
        },
        tracker = {
            Version = 0,
        },
        orbwalker = {
            Version = 0,
        },
    },
    Core = {
        Version = 1.00,
        Changelog =
        "Credits to RMAN! \n" ..
        "Enjoy your Game! "
        ,
    },
}

if currentData.Champions[myHero.charName] == nil then
    print("[Error]: " .. myHero.charName .. ' is not supported !')
    return
end

require "MapPositionGOS"
require "DamageLib"
require "2DGeometry"
 
--
local huge = math.huge
local pi = math.pi
local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt
local max = math.max
local min = math.min
--
local lenghtOf = math.lenghtOf
local abs = math.abs
local deg = math.deg
local cos = math.cos
local sin = math.sin
local acos = math.acos
local atan = math.atan
--
local contains = table.contains
local insert = table.insert
local remove = table.remove
local sort = table.sort
--
local TEAM_JUNGLE = 300
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = TEAM_JUNGLE - TEAM_ALLY
--
local _STUN = 5
local _TAUNT = 8
local _SLOW = 11
local _SNARE = 12
local _FEAR = 22
local _CHARM = 23
local _SUPRESS = 25
local _KNOCKUP = 30
local _KNOCKBACK = 31
local _Asleep = 35

--
local Vector = Vector
local KeyDown = Control.KeyDown
local KeyUp = Control.KeyUp
local IsKeyDown = Control.IsKeyDown
local SetCursorPos = Control.SetCursorPos
--
local GameCanUseSpell = Game.CanUseSpell
local Timer = Game.Timer
local Latency = Game.Latency
local HeroCount = Game.HeroCount
local Hero = Game.Hero
local MinionCount = Game.MinionCount
local Minion = Game.Minion
local TurretCount = Game.TurretCount
local Turret = Game.Turret
local WardCount = Game.WardCount
local Ward = Game.Ward
local ObjectCount = Game.ObjectCount
local Object = Game.Object
local MissileCount = Game.MissileCount
local Missile = Game.Missile
local ParticleCount = Game.ParticleCount
local Particle = Game.Particle
--
local DrawCircle = Draw.Circle
local DrawLine = Draw.Line
local DrawColor = Draw.Color
local DrawMap = Draw.CircleMinimap
local DrawText = Draw.Text
--
local barHeight = 8
local barWidth = 103
local barXOffset = 18
local barYOffset = 10
local DmgColor = DrawColor(255, 235, 103, 25)
 
local Color = {
    Red = DrawColor(255, 255, 0, 0),
    Green = DrawColor(255, 0, 255, 0),
    Blue = DrawColor(255, 0, 0, 255),
    White = DrawColor(255, 255, 255, 255),
    Black = DrawColor(255, 0, 0, 0),
}
 
local Orbwalker
local ObjectManager
local TargetSelector
local HealthPrediction
 
local GetMode, GetMinions, GetAllyMinions, GetEnemyMinions, GetMonsters, GetHeroes, GetAllyHeroes, GetEnemyHeroes, GetTurrets, GetAllyTurrets, GetEnemyTurrets, GetWards, GetAllyWards, GetEnemyWards, OnPreMovement, OnPreAttack, OnAttack, OnPostAttack, OnPostAttackTick, OnUnkillableMinion, SetMovement, SetAttack, GetTarget, ResetAutoAttack, IsAutoAttacking, Orbwalk, SetHoldRadius, SetMovementDelay, ForceTarget, ForceMovement, GetHealthPrediction, GetPriority
 
table.insert(LoadCallbacks, function()
	Orbwalker = _G.SDK.Orbwalker
	ObjectManager = _G.SDK.ObjectManager
	TargetSelector = _G.SDK.TargetSelector
	HealthPrediction = _G.SDK.HealthPrediction
	 
	GetMode = function() --1:Combo|2:Harass|3:LaneClear|4:JungleClear|5:LastHit|6:Flee
	    local modes = Orbwalker.Modes
	    for i = 0, #modes do
	        if modes[i] then return i + 1 end
	    end
	    return nil
	end
	 
	GetMinions = function(range)
	    return ObjectManager:GetMinions(range)
	end
	 
	GetAllyMinions = function(range)
	    return ObjectManager:GetAllyMinions(range)
	end
	 
	GetEnemyMinions = function(range)
	    return ObjectManager:GetEnemyMinions(range)
	end
	 
	GetMonsters = function(range)
	    return ObjectManager:GetMonsters(range)
	end
	 
	GetHeroes = function(range)
	    return ObjectManager:GetHeroes(range)
	end
	 
	GetAllyHeroes = function(range)
	    return ObjectManager:GetAllyHeroes(range)
	end
	 
	GetEnemyHeroes = function(range)
	    return ObjectManager:GetEnemyHeroes(range)
	end
	 
	GetTurrets = function(range)
	    return ObjectManager:GetTurrets(range)
	end
	 
	GetAllyTurrets = function(range)
	    return ObjectManager:GetAllyTurrets(range)
	end
	 
	GetEnemyTurrets = function(range)
	    return ObjectManager:GetEnemyTurrets(range)
	end
	 
	GetWards = function(range)
	    return ObjectManager:GetOtherMinions(range)
	end
	 
	GetAllyWards = function(range)
	    return ObjectManager:GetOtherAllyMinions(range)
	end
	 
	GetEnemyWards = function(range)
	    return ObjectManager:GetOtherEnemyMinions(range)
	end
	 
	OnPreMovement = function(fn)
	    Orbwalker:OnPreMovement(fn)
	end
	 
	OnPreAttack = function(fn)
	    Orbwalker:OnPreAttack(fn)
	end
	 
	OnAttack = function(fn)
	    Orbwalker:OnAttack(fn)
	end
	 
	OnPostAttack = function(fn)
	    Orbwalker:OnPostAttack(fn)
	end
	 
	OnPostAttackTick = function(fn)
	    if Orbwalker.OnPostAttackTick then
	        Orbwalker:OnPostAttackTick(fn)
	    else
	        Orbwalker:OnPostAttack(fn)
	    end
	end
	 
	OnUnkillableMinion = function(fn)
	    if Orbwalker.OnUnkillableMinion then
	        Orbwalker:OnUnkillableMinion(fn)
	    end
	end
	 
	SetMovement = function(bool)
	    Orbwalker:SetMovement(bool)
	end
	 
	SetAttack = function(bool)
	    Orbwalker:SetAttack(bool)
	end
	 
	GetTarget = function(range, mode) --0:Physical|1:Magical|2:True
	    return TargetSelector:GetTarget(range or huge, mode or 0)
	end
	 
	ResetAutoAttack = function()
	end
	 
	IsAutoAttacking = function()
	    return Orbwalker:IsAutoAttacking()
	end
	 
	Orbwalk = function()
	    Orbwalker:Orbwalk()
	end
	 
	SetHoldRadius = function(value)
	    Orbwalker.Menu.General.HoldRadius:Value(value)
	end
	 
	SetMovementDelay = function(value)
	    Orbwalker.Menu.General.MovementDelay:Value(value)
	end
	 
	ForceTarget = function(unit)
	    Orbwalker.ForceTarget = unit
	end
	 
	ForceMovement = function(pos)
	    Orbwalker.ForceMovement = pos
	end
	 
	GetHealthPrediction = function(unit, delay)
	    return HealthPrediction:GetPrediction(unit, delay)
	end
	 
	GetPriority = function(unit)
	    return TargetSelector:GetPriority(unit) or 1
	end
end)
 
local function TextOnScreen(str)
    local res = Game.Resolution()
    Callback.Add("Draw", function()
        DrawText(str, 64, res.x / 2 - (#str * 10), res.y / 2, Color.Red)
    end)
end
 
local function Ready(spell)
    return GameCanUseSpell(spell) == 0
end
 
local function RotateAroundPoint(v1, v2, angle)
    local cos, sin = cos(angle), sin(angle)
    local x = ((v1.x - v2.x) * cos) - ((v1.z - v2.z) * sin) + v2.x
    local z = ((v1.z - v2.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
    return Vector(x, v1.y, z or 0)
end
 
local function GetDistanceSqr(p1, p2)
	local success, message = pcall(function() if p1 == nil then print(p1.x) end end)
	if not success then print(message) end
    p2 = p2 or myHero
    p1 = p1.pos or p1
    p2 = p2.pos or p2
    
    local dx, dz = p1.x - p2.x, p1.z - p2.z
    return dx * dx + dz * dz
end
 
local function GetDistance(p1, p2)
    return sqrt(GetDistanceSqr(p1, p2))
end
 
local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7}
local function GetItemSlot(id) --returns Slot, HotKey
    for i = ITEM_1, ITEM_7 do
        if myHero:GetItemData(i).itemID == id then
            return i, ItemHotKey[i]
        end
    end
    return 0
end

local ItemID = DamageLib.ItemID
local wardItemIDs = {ItemID.StealthWard, ItemID.ControlWard, ItemID.FarsightAlteration, ItemID.ScarecrowEffigy, ItemID.StirringWardstone, 
ItemID.VigilantWardstone, ItemID.WatchfulWardstone, 
ItemID.BlackMistScythe,  ItemID.HarrowingCrescent, ItemID.SpectralSickle, 
ItemID.PauldronsofWhiterock, ItemID.RunesteelSpaulders, ItemID.SteelShoulderguards, 
ItemID.BulwarkoftheMountain, ItemID.TargonsBuckler, ItemID.RelicShield, 
ItemID.ShardofTrueIce, ItemID.Frostfang, ItemID.SpellthiefsEdge, }
local function GetWardSlot() --returns Slot, HotKey
    for i = 1, #wardItemIDs do
        local ward, key = GetItemSlot(wardItemIDs[i])
        if ward ~= 0 then
            return ward, key
        end
    end
end
 
local rotateAngle = 0
local function DrawMark(pos, thickness, size, color)
    rotateAngle = (rotateAngle + 2) % 720
    local hPos, thickness, color, size = pos or myHero.pos, thickness or 3, color or Color.Red, size * 2 or 150
    local offset, rotateAngle, mod = hPos + Vector(0, 0, size), rotateAngle / 360 * pi, 240 / 360 * pi
    local points = {
        hPos:To2D(),
        RotateAroundPoint(offset, hPos, rotateAngle):To2D(),
        RotateAroundPoint(offset, hPos, rotateAngle + mod):To2D(),
    RotateAroundPoint(offset, hPos, rotateAngle + 2 * mod):To2D(),
}
    --
    for i = 1, #points do
        for j = 1, #points do
            local lambda = i ~= j and DrawLine(points[i].x - 3, points[i].y - 5, points[j].x - 3, points[j].y - 5, thickness, color) -- -3 and -5 are offsets (because ext)
        end
    end
end
 
local function DrawRectOutline(vec1, vec2, width, color)
    local vec3, vec4 = vec2 - vec1, vec1 - vec2
    local A = (vec1 + (vec3:Perpendicular2():Normalized() * width)):To2D()
    local B = (vec1 + (vec3:Perpendicular():Normalized() * width)):To2D()
    local C = (vec2 + (vec4:Perpendicular2():Normalized() * width)):To2D()
    local D = (vec2 + (vec4:Perpendicular():Normalized() * width)):To2D()
    
    DrawLine(A, B, 3, color)
    DrawLine(B, C, 3, color)
    DrawLine(C, D, 3, color)
    DrawLine(D, A, 3, color)
end
 
local function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    local pointLine = {x = ax + rL * (bx - ax), z = ay + rL * (by - ay)}
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
    return pointSegment, pointLine, isOnSegment
end
 
local function mCollision(pos1, pos2, spell, list) --returns a table with minions (use #table to get count)
    local result, speed, width, delay, list = {}, spell.Speed, spell.Width + 65, spell.Delay, list
    --
    if not list then
        list = GetEnemyMinions(max(GetDistance(pos1), GetDistance(pos2)) + spell.Range + 100)
    end
    --
    for i = 1, #list do
        local m = list[i]
        local pos3 = delay and m:GetPrediction(speed, delay) or m.pos
        if m and m.team ~= TEAM_ALLY and m.dead == false and m.isTargetable and GetDistanceSqr(pos1, pos2) > GetDistanceSqr(pos1, pos3) then
            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(pos1, pos2, pos3)
            if isOnSegment and GetDistanceSqr(pointSegment, pos3) < width * width then
                result[#result + 1] = m
            end
        end
    end
    return result
end
 
local function hCollision(pos1, pos2, spell, list) --returns a table with heroes (use #table to get count)
    local result, speed, width, delay, list = {}, spell.Speed, spell.Width + 65, spell.Delay, list
    if not list then
        list = GetEnemyHeroes(max(GetDistance(pos1), GetDistance(pos2)) + spell.Range + 100)
    end
    for i = 1, #list do
        local h = list[i]
        local pos3 = delay and h:GetPrediction(speed, delay) or h.pos
        if h and h.team ~= TEAM_ALLY and h.dead == false and h.isTargetable and GetDistanceSqr(pos1, pos2) > GetDistanceSqr(pos1, pos3) then
            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(pos1, pos2, pos3)
            if isOnSegment and GetDistanceSqr(pointSegment, pos3) < width * width then
                insert(result, h)
            end
        end
    end
    return result
end
 
local function HealthPercent(unit)
    return unit.maxHealth > 5 and unit.health / unit.maxHealth * 100 or 100
end
 
local function ManaPercent(unit)
    return unit.maxMana > 0 and unit.mana / unit.maxMana * 100 or 100
end
 
local function HasBuffOfType(unit, bufftype, delay) --returns bool and endtime , why not starting at buffCOunt and check back to 1 ?
    local delay = delay or 0
    local bool = false
    local endT = Timer()
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.type == bufftype and buff.expireTime >= Timer() and buff.duration > 0 then
            if buff.expireTime > endT then
                bool = true
                endT = buff.expireTime
            end
        end
    end
    return bool, endT
end
 
local function HasBuff(unit, buffname) --returns bool
    return GotBuff(unit, buffname) == 1
end
 
local function GetBuffByName(unit, buffname) --returns buff
    return GetBuffData(unit, buffname)
end
 
local function GetBuffByType(unit, bufftype) --returns buff
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.type == bufftype and buff.expireTime >= Timer() and buff.duration > 0 then
            return buff
        end
    end
    return nil
end
 
local UndyingBuffs = {
    ["Aatrox"] = function(target, addHealthCheck)
        return HasBuff(target, "aatroxpassivedeath")
    end,
    ["Fiora"] = function(target, addHealthCheck)
        return HasBuff(target, "FioraW")
    end,
    ["Tryndamere"] = function(target, addHealthCheck)
        return HasBuff(target, "UndyingRage") and (not addHealthCheck or target.health <= 30)
    end,
    ["Vladimir"] = function(target, addHealthCheck)
        return HasBuff(target, "VladimirSanguinePool")
    end,
}
 
local function HasUndyingBuff(target, addHealthCheck)
    --Self Casts Only
    local buffCheck = UndyingBuffs[target.charName]
    if buffCheck and buffCheck(target, addHealthCheck) then return true end
    --Can Be Casted On Others
    if HasBuff(target, "JudicatorIntervention") or ((not addHealthCheck or HealthPercent(target) <= 10) and (HasBuff(target, "kindredrnodeathbuff") or HasBuff(target, "ChronoShift") or HasBuff(target, "chronorevive"))) then
        return true
    end
    return target.isImmortal
end
 
local function IsValidTarget(unit, range) -- the == false check is faster than using "not"
    return unit and unit.valid and unit.visible and not unit.dead and unit.isTargetableToTeam and (not range or GetDistance(unit) <= range) and (not unit.type == myHero.type or not HasUndyingBuff(unit, true))
end
 
local function GetTrueAttackRange(unit, target)
    local extra = target and target.boundingRadius or 0
    return unit.range + unit.boundingRadius + extra
end
 
local function HeroesAround(range, pos, team)
    pos = pos or myHero.pos
    local dist = GetDistance(pos) + range + 100
    local result = {}
    local heroes = (team == TEAM_ENEMY and GetEnemyHeroes(dist)) or (team == TEAM_ALLY and GetAllyHeroes(dist) or GetHeroes(dist))
    for i = 1, #heroes do
        local h = heroes[i]
        if GetDistance(pos, h.pos) <= range then
            result[#result + 1] = h
        end
    end
    return result
end
 
local function CountEnemiesAround(pos, range)
    return #HeroesAround(range, pos, TEAM_ENEMY)
end
 
local function GetClosestEnemy(unit)
    local unit = unit or myHero
    local closest, list = nil, GetHeroes()
    for i = 1, #list do
        local enemy = list[i]
        if IsValidTarget(enemy) and enemy.team ~= unit.team and (not closest or GetDistance(enemy, unit) < GetDistance(closest, unit)) then
            closest = enemy
        end
    end
    return closest
end
 
local function MinionsAround(range, pos, team)
    pos = pos or myHero.pos
    local dist = GetDistance(pos) + range + 100
    local result = {}
    local minions = (team == TEAM_ENEMY and GetEnemyMinions(dist)) or (team == TEAM_ALLY and GetAllyMinions(dist) or GetMinions(dist))
    for i = 1, #minions do
        local m = minions[i]
        if m and not m.dead and GetDistance(pos, m.pos) <= range + m.boundingRadius then
            result[#result + 1] = m
        end
    end
    return result
end
 
local function IsUnderTurret(pos, team)
    local turrets = GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if GetDistance(turret, pos) <= 915 and turret.team == team then
            return turret
        end
    end
end
 
local function GetDanger(pos)
    local result = 0
    --
    local turret = IsUnderTurret(pos, TEAM_ENEMY)
    if turret then
        result = result + floor((915 - GetDistance(turret, pos)) / 17.3)
    end
    --
    local nearby = HeroesAround(700, pos, TEAM_ENEMY)
    for i = 1, #nearby do
        local enemy = nearby[i]
        local dist, mod = GetDistance(enemy, pos), enemy.range < 350 and 2 or 1
        result = result + (dist <= GetTrueAttackRange(enemy) and 5 or 0) * mod
    end
    --
    result = result + #HeroesAround(400, pos, TEAM_ENEMY) * 1
    return result
end
 
local function IsImmobile(unit, delay)
    if unit.ms == 0 then return true, unit.pos, unit.pos end
    local delay = delay or 0
    local debuff, timeCheck = {}, Timer() + delay
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.expireTime >= timeCheck and buff.duration > 0 then
            debuff[buff.type] = true
        end
    end
    if debuff[_STUN] or debuff[_TAUNT] or debuff[_SNARE] or debuff[_Asleep] or
        debuff[_CHARM] or debuff[_SUPRESS] or debuff[_KNOCKUP] or debuff[_KNOCKBACK] or debuff[_FEAR] then
        return true
    end
end
 
local function IsFacing(unit, p2)
    p2 = p2 or myHero
    p2 = p2.pos or p2
    local V = unit.pos - p2
    local D = unit.dir
    local Angle = 180 - deg(acos(V * D / (V:Len() * D:Len())))
    if abs(Angle) < 80 then
        return true
    end
end
 
local function CheckHandle(tbl, handle)
    for i = 1, #tbl do
        local v = tbl[i]
        if handle == v.handle then return v end
    end
end
 
local function GetTargetByHandle(handle)
    return CheckHandle(GetEnemyHeroes(1200), handle) or
    CheckHandle(GetMonsters(1200), handle) or
    CheckHandle(GetEnemyTurrets(1200), handle) or
    CheckHandle(GetEnemyMinions(1200), handle) or
    CheckHandle(GetEnemyWards(1200), handle)
end
 
local function ShouldWait()
    return myHero.dead or HasBuff(myHero, "recall") or Game.IsChatOpen() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading == true) or (_G.JustEvade and _G.JustEvade:Evading())
end
 
local Emote = {
    Joke = HK_ITEM_1,
    Taunt = HK_ITEM_2,
    Dance = HK_ITEM_3,
    Mastery = HK_ITEM_5,
    Laugh = HK_ITEM_7,
    Casting = false
}
 
local function CastEmote(emote)
    if not emote or Emote.Casting or myHero.attackData.state == STATE_WINDUP then return end
    --
    Emote.Casting = true
    KeyDown(HK_LUS)
    KeyDown(emote)
    DelayAction(function()
        KeyUp(emote)
        KeyUp(HK_LUS)
        Emote.Casting = false
    end, 0.01)
end
 
-- Farm Stuff
 
local function ExcludeFurthest(average, lst, sTar)
    local removeID = 1
    for i = 2, #lst do
        if GetDistanceSqr(average, lst[i].pos) > GetDistanceSqr(average, lst[removeID].pos) then
            removeID = i
        end
    end
    
    local Newlst = {}
    for i = 1, #lst do
        if (sTar and lst[i].networkID == sTar.networkID) or i ~= removeID then
            Newlst[#Newlst + 1] = lst[i]
        end
    end
    return Newlst
end
 
local function GetBestCircularCastPos(spell, sTar, lst)
    local average = {x = 0, z = 0, count = 0}
    local heroList = lst and lst[1] and (lst[1].type == myHero.type)
    local range = spell.Range or 2000
    local radius = spell.Radius or 50
    if sTar and (not lst or #lst == 0) then
        return Prediction:GetBestCastPosition(sTar, spell), 1
    end
    --
    for i = 1, #lst do
        if IsValidTarget(lst[i], range) then
            local org = heroList and Prediction:GetBestCastPosition(lst[i], spell) or lst[i].pos
            average.x = average.x + org.x
            average.z = average.z + org.z
            average.count = average.count + 1
        end
    end
    --
    if sTar and sTar.type ~= lst[1].type then
        local org = heroList and Prediction:GetBestCastPosition(sTar, spell) or lst[i].pos
        average.x = average.x + org.x
        average.z = average.z + org.z
        average.count = average.count + 1
    end
    --
    average.x = average.x / average.count
    average.z = average.z / average.count
    --
    local inRange = 0
    for i = 1, #lst do
        local bR = lst[i].boundingRadius
        if GetDistanceSqr(average, lst[i].pos) - bR * bR < radius * radius then
            inRange = inRange + 1
        end
    end
    --
    local point = Vector(average.x, myHero.pos.y, average.z)
    --
    if inRange == #lst then
        return point, inRange
    else
        return GetBestCircularCastPos(spell, sTar, ExcludeFurthest(average, lst))
    end
end
 
local function GetBestLinearCastPos(spell, sTar, list)
    local startPos = spell.From.pos or myHero.pos
    local isHero = list[1].type == myHero.type
    --
    local center = GetBestCircularCastPos(spell, sTar, list)
    local endPos = startPos + (center - startPos):Normalized() * spell.Range
    local MostHit = isHero and #hCollision(startPos, endPos, spell, list) or #mCollision(startPos, endPos, spell, list)
    return endPos, MostHit
end
 
local function GetBestLinearFarmPos(spell)
    local minions = GetEnemyMinions(spell.Range + spell.Radius)
    if #minions == 0 then return nil, 0 end
    return GetBestLinearCastPos(spell, nil, minions)
end
 
local function GetBestCircularFarmPos(spell)
    local minions = GetEnemyMinions(spell.Range + spell.Radius)
    if #minions == 0 then return nil, 0 end
    return GetBestCircularCastPos(spell, nil, minions)
end
 
local function CircleCircleIntersection(c1, c2, r1, r2)
    local D = GetDistance(c1, c2)
    if D > r1 + r2 or D <= abs(r1 - r2) then return nil end
    local A = (r1 * r2 - r2 * r1 + D * D) / (2 * D)
    local H = sqrt(r1 * r1 - A * A)
    local Direction = (c2 - c1):Normalized()
    local PA = c1 + A * Direction
    local S1 = PA + H * Direction:Perpendicular()
    local S2 = PA - H * Direction:Perpendicular()
    return S1, S2
end
-- Damage calcs
function PassivePercentMod(source, target, dmgMod)
    local tarMinion = target.type == Obj_AI_Minion and target
    local newMod = dmgMod
    
    if source.type == Obj_AI_Turret then
        if tarMinion and (tarMinion.charName:find("MinionSiege") or tarMinion.charName:find("MinionSuper")) then
            newMod = newMod * 0.7
        end
    end
    
    if tarMinion then
        if tarMinion.charName:find("MinionMelee") and HasBuff(tarMinion, "exaltedwithbaronnashorminion") then
            newMod = newMod * 0.25
        end
    end
    
    if source.type == Obj_AI_Hero then
        if tarMinion then
            if HasBuff(source, "barontarget") and tarMinion.charName:find("SRU_Baron") then
                newMod = newMod * 0.5
            end
        end
    end
    
    return newMod
end
 
local reductions = {
    ["Alistar"] = function(t) return HasBuff(t, "FerociousHowl") and (0.45 + 0.1 * t:GetSpellData(_R).level) end,
    ["Annie"] = function(t) return HasBuff(t, "AnnieE") and (0.10 + 0.06 * t:GetSpellData(_E).level) end,
    ["Galio"] = function(t) return HasBuff(t, "GalioW") and (0.15 + 0.05 * t:GetSpellData(_W).level + 0.08 * t.bonusMagicResist / 100) end,
    ["Garen"] = function(t) return HasBuff(t, "GarenW") and (0.30) end,
    ["Gragas"] = function(t) return HasBuff(t, "gragaswself") and (0.08 + 0.02 * t:GetSpellData(_W).level + 0.04 * t.ap / 100) end,
    ["Irelia"] = function(t) return HasBuff(t, "ireliawdefense") and (0.40 + 0.05 * t:GetSpellData(_W).level + 0.07 * t.ap / 100) end,
    ["Malzahar"] = function(t) return HasBuff(t, "malzaharpassiveshield") and (0.90) end,
    ["MasterYi"] = function(t) return HasBuff(t, "Meditate") and (0.45 + 0.05 * t:GetSpellData(_W).level) end,
    ["Warwick"] = function(t) return HasBuff(t, "WarwickE") and (0.30 + 0.05 * t:GetSpellData(_E).level) end,
}
function CalcMagicalDamage(source, target, amount, time)
    local passiveMod = 0
    
    local totalMR = target.magicResist + target.bonusMagicResist
    if totalMR < 0 then
        passiveMod = 2 - 100 / (100 - totalMR)
    elseif totalMR * source.magicPenPercent - source.magicPen < 0 then
        passiveMod = 1
    else
        passiveMod = 100 / (100 + totalMR * source.magicPenPercent - source.magicPen)
    end
    
    local dmg = max(floor(PassivePercentMod(source, target, passiveMod) * amount), 0)
    
    if target.charName == "Kassadin" then
        dmg = dmg * 0.85
    elseif reductions[target.charName] then
        local reduction = reductions[target.charName](target) or 0
        dmg = dmg * (1 - reduction)
    end
    
    if HasBuff(target, "cursedtouch") then
        dmg = dmg + amount * 0.1
    end
    
    if HasBuff(target, "abyssalscepteraura") then
        dmg = dmg * 1.15
    end
    
    return dmg
end
 
function CalcPhysicalDamage(source, target, amount, time)
    local penPercent = source.armorPenPercent
    local penPercentBonus = source.bonusArmorPenPercent
    local penFlat = source.armorPen * (0.6 + 0.4 * source.levelData.lvl / 18)
    
    if source.type == Obj_AI_Minion then
        penFlat = 0
        penPercent = 1
        penPercentBonus = 1
    elseif source.type == Obj_AI_Turret then
        penFlat = 0
        penPercentBonus = 1
        penPercent = 0.7
    end
    
    local armor = target.armor
    local bonusArmor = target.bonusArmor
    
    local value
    
    if armor < 0 then
        value = 2 - 100 / (100 - armor)
    elseif armor * penPercent - bonusArmor * (1 - penPercentBonus) - penFlat < 0 then
        value = 1
    else
        value = 100 / (100 + armor * penPercent - bonusArmor * (1 - penPercentBonus) - penFlat)
    end
    
    local dmg = max(floor(PassivePercentMod(source, target, value) * amount), 0)
    if reductions[target.charName] then
        local reduction = reductions[target.charName](target) or 0
        dmg = dmg * (1 - reduction)
    end
    return dmg
end
 
function CalcMixedDamage(source, target, physicalAmount, magicalAmount)
    return CalcPhysicalDamage(source, target, physicalAmount) + CalcMagicalDamage(source, target, magicalAmount)
end
 
class "Spell"
 
function Spell:__init(SpellData)
    self.Slot = SpellData.Slot
    self.Range = SpellData.Range or huge
    self.Delay = SpellData.Delay or 0.25
    self.Speed = SpellData.Speed or huge
    self.Radius = SpellData.Radius or SpellData.Width or 0
    self.Width = SpellData.Width or SpellData.Radius or 0
    self.From = SpellData.From or myHero
    self.Collision = SpellData.Collision or false
    self.Type = SpellData.Type or "Press"
    self.DmgType = SpellData.DmgType or "Physical"
    --
    return self
end
 
function Spell:IsReady()
    return GameCanUseSpell(self.Slot) == READY
end
 
function Spell:CanCast(unit, range, from)
    local from = from or self.From.pos
    local range = range or self.Range
    return unit and unit.valid and unit.visible and not unit.dead and (not range or GetDistance(from, unit) <= range)
end
 
function Spell:GetPrediction(target)
    return Prediction:GetBestCastPosition(target, self)
end
 
function Spell:GetBestLinearCastPos(sTar, lst)
    return GetBestLinearCastPos(self, sTar, lst)
end
 
function Spell:GetBestCircularCastPos(sTar, lst)
    return GetBestCircularCastPos(self, sTar, lst)
end
 
function Spell:GetBestLinearFarmPos()
    return GetBestLinearFarmPos(self)
end
 
function Spell:GetBestCircularFarmPos()
    return GetBestCircularFarmPos(self)
end
 
function Spell:CalcDamage(target, stage)
    local stage = stage or 1
    local rawDmg = self:GetDamage(target, stage)
    if rawDmg <= 0 then return 0 end
    local damage = rawDmg
    return damage
end
 
function Spell:GetDamage(target, stage)
    local slot = self:SlotToString()
    return self:IsReady() and getdmg(slot, target, self.From, stage or 1) or 0
end
 
function Spell:SlotToHK()
    return ({[_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R, [SUMMONER_1] = HK_SUMMONER_1, [SUMMONER_2] = HK_SUMMONER_2})[self.Slot]
end
 
function Spell:SlotToString()
    return ({[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"})[self.Slot]
end
 
function Spell:Cast(castOn)
    if not self:IsReady() or ShouldWait() then return end
    --
    local slot = self:SlotToHK()
    if self.Type == "Press" then
        KeyDown(slot)
        return KeyUp(slot)
    end
    --
    if castOn == nil then return end
    local pos = castOn.x and castOn
    local targ = castOn.health and castOn
    --
    if self.Type == "AOE" and pos then
        local bestPos, hit = self:GetBestCircularCastPos(targ, GetEnemyHeroes(self.Range + self.Radius))
        pos = hit >= 2 and bestPos or pos
    end
    --
    if (targ and not targ.pos:To2D().onScreen) then
        return
    elseif (pos and not pos:To2D().onScreen) then
        if self.Type == "AOE" then
            local mapPos = pos:ToMM()
            Control.CastSpell(slot, mapPos.x, mapPos.y)
        else
            pos = myHero.pos:Extended(pos, 200)
            if not pos:To2D().onScreen then return end
        end
    end
    --
    return Control.CastSpell(slot, targ or pos)
end
 
function Spell:CastToPred(target, minHitchance)
    if not target then return end
    --
    local predPos, castPos, hC = self:GetPrediction(target)
    if predPos and hC >= minHitchance then
        return self:Cast(predPos)
    end
end
 
function Spell:OnImmobile(target)
    local TargetImmobile, ImmobilePos, ImmobileCastPosition = Prediction:IsImmobile(target, self)
    if self.Collision then
        local colStatus = #(mCollision(self.From.pos, target, self)) > 0
        if colStatus then return end
        return TargetImmobile, ImmobilePos, ImmobileCastPosition
    end
    return TargetImmobile, ImmobilePos, ImmobileCastPosition
end
 
local function DrawDmg(hero, damage)
    local screenPos = hero.pos:To2D()
    local barPos = {x = screenPos.x - 50, y = screenPos.y - 150, onScreen = screenPos.onScreen}
    if barPos.onScreen then
        local percentHealthAfterDamage = max(0, hero.health - damage) / hero.maxHealth
        local xPosEnd = barPos.x + barXOffset + barWidth * hero.health / hero.maxHealth
        local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
        DrawLine(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, DmgColor)
    end
end
 
local function DrawSpells(instance, extrafn)
    local drawSettings = Menu.Draw
    if drawSettings.ON:Value() then
        local qLambda = drawSettings.Q:Value() and instance.Q and instance.Q:Draw(66, 244, 113)
        local wLambda = drawSettings.W:Value() and instance.W and instance.W:Draw(66, 229, 244)
        local eLambda = drawSettings.E:Value() and instance.E and instance.E:Draw(244, 238, 66)
        local rLambda = drawSettings.R:Value() and instance.R and instance.R:Draw(244, 66, 104)
        local tLambda = drawSettings.TS:Value() and instance.target and DrawMark(instance.target.pos, 3, instance.target.boundingRadius, Color.Red)
        if instance.enemies and drawSettings.Dmg:Value() then
            for i = 1, #instance.enemies do
                local enemy = instance.enemies[i]
                local qDmg, wDmg, eDmg, rDmg = instance.Q and instance.Q:CalcDamage(enemy) or 0, instance.W and instance.W:CalcDamage(enemy) or 0, instance.E and instance.E:CalcDamage(enemy) or 0, instance.R and instance.R:CalcDamage(enemy) or 0
                
                DrawDmg(enemy, qDmg + wDmg + eDmg + rDmg)
                if extrafn then
                    extrafn(enemy)
                end
            end
        end
    end
end
 
function Spell:Draw(r, g, b)
    if not self.DrawColor then
        self.DrawColor = DrawColor(255, r, g, b)
        self.DrawColor2 = DrawColor(80, r, g, b)
    end
    if self.Range and self.Range ~= huge then
        if self:IsReady() then
            DrawCircle(self.From.pos, self.Range, 5, self.DrawColor)
        else
            DrawCircle(self.From.pos, self.Range, 5, self.DrawColor2)
        end
        return true
    end
end
 
function Spell:DrawMap(r, g, b)
    if not self.DrawColor then
        self.DrawColor = DrawColor(255, r, g, b)
        self.DrawColor2 = DrawColor(80, r, g, b)
    end
    if self.Range and self.Range ~= huge then
        if self:IsReady() then
            DrawMap(self.From.pos, self.Range, 5, self.DrawColor)
        else
            DrawMap(self.From.pos, self.Range, 5, self.DrawColor2)
        end
        return true
    end
end
 
print("Impuls[WR] Common Loaded")

--------------------------------------
local function OnInterruptable(fn)
    if not _INTERRUPTER_START then
        _G.Interrupter = Interrupter()
        print("Impuls[WR] Callbacks | Interrupter Loaded.")
    end
    insert(Interrupter.InterruptCallback, fn)
end
 
local function OnNewPath(fn)
    if not _PATH_STARTED then
        _G.Path = Path()
        print("Impuls[WR] Callbacks | Pathing Loaded.")
    end
    insert(Path.OnNewPathCallback, fn)
end
 
local function OnDash(fn)
    if not _PATH_STARTED then
        _G.Path = Path()
        print("Impuls[WR] Callbacks | Pathing Loaded.")
    end
    insert(Path.OnDashCallback, fn)
end
 
local function OnGainVision(fn)
    if not _VISION_STARTED then
        _G.Vision = Vision()
        print("Impuls[WR] Callbacks | Vision Loaded.")
    end
    insert(Vision.GainVisionCallback, fn)
end
 
local function OnLoseVision(fn)
    if not _VISION_STARTED then
        _G.Vision = Vision()
        print("Impuls[WR] Callbacks | Vision Loaded.")
    end
    insert(Vision.LoseVisionCallback, fn)
end
 
local function OnAnimation(fn)
    if not _ANIMATION_STARTED then
        _G.Animation = Animation()
        print("Impuls[WR] Callbacks | Animation Loaded.")
    end
    insert(Animation.OnAnimationCallback, fn)
end
 
local function OnUpdateBuff(cb)
    if not __BuffExplorer_Loaded then
        _G.BuffExplorer = BuffExplorer()
        print("Impuls[WR] Callbacks | Buff Explorer Loaded.")
    end
    insert(BuffExplorer.UpdateBuffCallback, cb)
end
 
local function OnRemoveBuff(cb)
    if not __BuffExplorer_Loaded then
        _G.BuffExplorer = BuffExplorer()
        print("Impuls[WR] Callbacks | Buff Explorer Loaded.")
    end
    insert(BuffExplorer.RemoveBuffCallback, cb)
end

class "Prediction"
 
function Prediction:VectorMovementCollision(startPoint1, endPoint1, v1, startPoint2, v2, delay)
    local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
    local d, e = eP1x - sP1x, eP1y - sP1y
    local dist, t1, t2 = sqrt(d * d + e * e), nil, nil
    local S, K = dist ~= 0 and v1 * d / dist or 0, dist ~= 0 and v1 * e / dist or 0
    local function GetCollisionPoint(t) return t and {x = sP1x + S * t, y = sP1y + K * t} or nil end
    if delay and delay ~= 0 then sP1x, sP1y = sP1x + S * delay, sP1y + K * delay end
    local r, j = sP2x - sP1x, sP2y - sP1y
    local c = r * r + j * j
    if dist > 0 then
        if v1 == huge then
            local t = dist / v1
            t1 = v2 * t >= 0 and t or nil
        elseif v2 == huge then
            t1 = 0
        else
            local a, b = S * S + K * K - v2 * v2, -r * S - j * K
            if a == 0 then
                if b == 0 then --c=0->t variable
                    t1 = c == 0 and 0 or nil
                else --2*b*t+c=0
                    local t = -c / (2 * b)
                    t1 = v2 * t >= 0 and t or nil
                end
            else --a*t*t+2*b*t+c=0
                local sqr = b * b - a * c
                if sqr >= 0 then
                    local nom = sqrt(sqr)
                    local t = (-nom - b) / a
                    t1 = v2 * t >= 0 and t or nil
                    t = (nom - b) / a
                    t2 = v2 * t >= 0 and t or nil
                end
            end
        end
    elseif dist == 0 then
        t1 = 0
    end
    return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
end
 
function Prediction:IsDashing(unit, spell)
    local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From.pos
    local OnDash, CanHit, Pos = false, false, nil
    local pathData = unit.pathing
    --
    if pathData.isDashing then
        local startPos = Vector(pathData.startPos)
        local endPos = Vector(pathData.endPos)
        local dashSpeed = pathData.dashSpeed
        local timer = Timer()
        local startT = timer - Latency() / 2000
        local dashDist = GetDistance(startPos, endPos)
        local endT = startT + (dashDist / dashSpeed)
        --
        if endT >= timer and startPos and endPos then
            OnDash = true
            --
            local t1, p1, t2, p2, dist = self:VectorMovementCollision(startPos, endPos, dashSpeed, from, speed, (timer - startT) + delay)
            t1, t2 = (t1 and 0 <= t1 and t1 <= (endT - timer - delay)) and t1 or nil, (t2 and 0 <= t2 and t2 <= (endT - timer - delay)) and t2 or nil
            local t = t1 and t2 and min(t1, t2) or t1 or t2
            --
            if t then
                Pos = t == t1 and Vector(p1.x, 0, p1.y) or Vector(p2.x, 0, p2.y)
                CanHit = true
            else
                Pos = Vector(endPos.x, 0, endPos.z)
                CanHit = (unit.ms * (delay + GetDistance(from, Pos) / speed - (endT - timer))) < radius
            end
        end
    end
    
    return OnDash, CanHit, Pos
end
 
function Prediction:IsImmobile(unit, spell)
    if unit.ms == 0 then return true, unit.pos, unit.pos end
    local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From.pos
    local debuff = {}
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.duration > 0 then
            local ExtraDelay = speed == huge and 0 or (GetDistance(from, unit.pos) / speed)
            if buff.expireTime + (radius / unit.ms) > Timer() + delay + ExtraDelay then
                debuff[buff.type] = true
            end
        end
    end
    if debuff[_STUN] or debuff[_TAUNT] or debuff[_SNARE] or debuff[_Asleep] or
        debuff[_CHARM] or debuff[_SUPRESS] or debuff[_KNOCKUP] or debuff[_KNOCKBACK] or debuff[_FEAR] then
        return true, unit.pos, unit.pos
    end
    return false, unit.pos, unit.pos
end
 
function Prediction:IsSlowed(unit, spell)
    local delay, speed, from = spell.Delay, spell.Speed, spell.From.pos
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.type == _SLOW and buff.expireTime >= Timer() and buff.duration > 0 then
            if buff.expireTime > Timer() + delay + GetDistance(unit.pos, from) / speed then
                return true
            end
        end
    end
    return false
end
 
function Prediction:CalculateTargetPosition(unit, spell, tempPos)
    local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From
    local calcPos = nil
    local pathData = unit.pathing
    local pathCount = pathData.pathCount
    local pathIndex = pathData.pathIndex
    local pathEndPos = Vector(pathData.endPos)
    local pathPos = tempPos and tempPos or unit.pos
    local pathPot = (unit.ms * ((GetDistance(pathPos) / speed) + delay))
    local unitBR = unit.boundingRadius
    --
    if pathCount < 2 then
        local extPos = unit.pos:Extended(pathEndPos, pathPot - unitBR)
        --
        if GetDistance(unit.pos, extPos) > 0 then
            if GetDistance(unit.pos, pathEndPos) >= GetDistance(unit.pos, extPos) then
                calcPos = extPos
            else
                calcPos = pathEndPos
            end
        else
            calcPos = pathEndPos
        end
    else
        for i = pathIndex, pathCount do
            if unit:GetPath(i) and unit:GetPath(i - 1) then
                local startPos = i == pathIndex and unit.pos or unit:GetPath(i - 1)
                local endPos = unit:GetPath(i)
                local pathDist = GetDistance(startPos, endPos)
                --
                if unit:GetPath(pathIndex - 1) then
                    if pathPot > pathDist then
                        pathPot = pathPot - pathDist
                    else
                        local extPos = startPos:Extended(endPos, pathPot - unitBR)
                        
                        calcPos = extPos
                        
                        if tempPos then
                            return calcPos, calcPos
                        else
                            return self:CalculateTargetPosition(unit, spell, calcPos)
                        end
                    end
                end
            end
        end
        --
        if GetDistance(unit.pos, pathEndPos) > unitBR then
            calcPos = pathEndPos
        else
            calcPos = unit.pos
        end
    end
    
    calcPos = calcPos and calcPos or unit.pos
    
    if tempPos then
        return calcPos, calcPos
    else
        return self:CalculateTargetPosition(unit, spell, calcPos)
    end
end
 
function Prediction:GetBestCastPosition(unit, spell)
    local range = spell.Range and spell.Range - 30 or huge
    local radius = spell.Radius == 0 and 1 or (spell.Radius + unit.boundingRadius) - 4
    local speed = spell.Speed or huge
    local from = spell.From or myHero
    local delay = spell.Delay + (0.07 + Latency() / 1000)
    local collision = spell.Collision or false
    --
    local Position, CastPosition, HitChance = Vector(unit), Vector(unit), 0
    local TargetDashing, CanHitDashing, DashPosition = self:IsDashing(unit, spell)
    local TargetImmobile, ImmobilePos, ImmobileCastPosition = self:IsImmobile(unit, spell)
    
    if TargetDashing then
        if CanHitDashing then
            HitChance = 5
        else
            HitChance = 0
        end
        Position, CastPosition = DashPosition, DashPosition
    elseif TargetImmobile then
        Position, CastPosition = ImmobilePos, ImmobileCastPosition
        HitChance = 4
    else
        Position, CastPosition = self:CalculateTargetPosition(unit, spell)
        
        if unit.activeSpell and unit.activeSpell.valid then
            HitChance = 2
        end
        
        if GetDistanceSqr(from.pos, CastPosition) < 250 then
            HitChance = 2
            local newSpell = {Range = range, Delay = delay * 0.5, Radius = radius, Width = radius, Speed = speed * 2, From = from}
            Position, CastPosition = self:CalculateTargetPosition(unit, newSpell)
        end
        
        local temp_angle = from.pos:AngleBetween(unit.pos, CastPosition)
        if temp_angle >= 60 then
            HitChance = 1
        elseif temp_angle <= 30 then
            HitChance = 2
        end
    end
    if GetDistanceSqr(from.pos, CastPosition) >= range * range then
        HitChance = 0
    end
    if collision and HitChance > 0 then
        local newSpell = {Range = range, Delay = delay, Radius = radius * 2, Width = radius * 2, Speed = speed * 2, From = from}
        if #(mCollision(from.pos, CastPosition, newSpell)) > 0 then
            HitChance = 0
        end
    end
    
    return Position, CastPosition, HitChance
end
 
ChangePred = function(newVal)
    if newVal == 1 then
        print("Changing to [WR]Internal Pred")
        Prediction.GetBestCastPosition = function(self, unit, spell)
            local range = spell.Range and spell.Range - 15 or huge
            local radius = spell.Radius == 0 and 1 or (spell.Radius + unit.boundingRadius) - 4
            local speed = spell.Speed or huge
            local from = spell.From or myHero
            local delay = spell.Delay + (0.07 + Latency() / 2000)
            local collision = spell.Collision or false
            --
            local Position, CastPosition, HitChance = Vector(unit), Vector(unit), 0
            local TargetDashing, CanHitDashing, DashPosition = self:IsDashing(unit, spell)
            local TargetImmobile, ImmobilePos, ImmobileCastPosition = self:IsImmobile(unit, spell)
            
            if TargetDashing then
                if CanHitDashing then
                    HitChance = 5
                else
                    HitChance = 0
                end
                Position, CastPosition = DashPosition, DashPosition
            elseif TargetImmobile then
                Position, CastPosition = ImmobilePos, ImmobileCastPosition
                HitChance = 4
            else
                Position, CastPosition = self:CalculateTargetPosition(unit, spell)
                
                if unit.activeSpell and unit.activeSpell.valid then
                    HitChance = 2
                end
                
                if GetDistanceSqr(from.pos, CastPosition) < 250 then
                    HitChance = 2
                    local newSpell = {Range = range, Delay = delay * 0.5, Radius = radius, Width = radius, Speed = speed * 2, From = from}
                    Position, CastPosition = self:CalculateTargetPosition(unit, newSpell)
                end
                
                local temp_angle = from.pos:AngleBetween(unit.pos, CastPosition)
                if temp_angle > 60 then
                    HitChance = 1
                elseif temp_angle < 30 then
                    HitChance = 2
                end
            end
            if GetDistanceSqr(from.pos, CastPosition) >= range * range then
                HitChance = 0
            end
            if collision and HitChance > 0 then
                local newSpell = {Range = range, Delay = delay, Radius = radius * 2, Width = radius * 2, Speed = speed * 2, From = from}
                if #(mCollision(from.pos, CastPosition, newSpell)) > 0 then
                    HitChance = 0
                end
            end
            
            return Position, CastPosition, HitChance
        end
    elseif newVal == 2 then
        print("Changing to GGPred")
        Prediction.GetBestCastPosition = function(self, unit, s)
            local args = {Delay = s.Delay, Radius = s.Radius, Range = s.Range, Speed = s.Speed, Collision = s.Collision, Type = s.Type == "SkillShot" and 0 or s.Type == "AOE" and 1}
            local pred = GGPrediction:GetPrediction(unit, args, s.From)
            local castPos
            if pred.CastPosition then
                castPos = Vector(pred.CastPosition.x, 0, pred.CastPosition.y)
            end
            return castPos, castPos, pred.Hitchance - 1
        end
    elseif newVal == 3 then
        print("Changing to PremPred")
        Prediction.GetBestCastPosition = function(self, unit, s)
            local args = {Delay = s.Delay, Radius = s.Radius, Range = s.Range, Speed = s.Speed, Collision = s.Collision, Type = s.Type == "SkillShot" and 0 or s.Type == "AOE" and 1}
            local pred = PremiumPrediction:GetPrediction(unit, args, s.From)
            local castPos
            if pred.CastPosition then
                castPos = Vector(pred.CastPosition.x, 0, pred.CastPosition.y)
            end
            return castPos, castPos, pred.Hitchance - 1
        end
    end
end
 
print("Impuls[WR] Prediction Loaded")

--Menu
local charName = myHero.charName
local url = "https://raw.githubusercontent.com/Impulsx/LoL-Icons/master/"
local HeroIcon = {url..charName..".png"}
local HeroSpirites = {url.. charName.."Q.png", url..charName..'W.png', url..charName..'E.png', url..charName.."R.png"}
icons, Menu = {}
icons.Hero = HeroIcon[1]
icons.Q = HeroSpirites[1]
icons.W = HeroSpirites[2]
icons.E = HeroSpirites[3]
icons.R = HeroSpirites[4]

Menu = MenuElement({id = charName, name = "Impuls[WR] | "..charName, type = MENU, leftIcon = icons.Hero})
Menu:MenuElement({name = " ", drop = {"Spell Settings"}})
Menu:MenuElement({id = "Q", name = "Q Settings", type = MENU, leftIcon = icons.Q})
--local MenuLucian = charName == "Lucian" and Menu:MenuElement({id = "Q2", name = "Q2 Settings", type = MENU, leftIcon = icons.Q, tooltip = "Extended Q Settings"}) --was local lambda
Menu:MenuElement({id = "W", name = "W Settings", type = MENU, leftIcon = icons.W})
Menu:MenuElement({id = "E", name = "E Settings", type = MENU, leftIcon = icons.E})
Menu:MenuElement({id = "R", name = "R Settings", type = MENU, leftIcon = icons.R})
--Draw
Menu:MenuElement({name = " ", drop = {"Global Settings"}})
Menu:MenuElement({id = "Draw", name = "Draw Settings", type = MENU})
Menu.Draw:MenuElement({id = "ON", name = "Enable Drawings", value = true})
Menu.Draw:MenuElement({id = "TS", name = "Draw Selected Target", value = true, leftIcon = icons.Hero})
Menu.Draw:MenuElement({id = "Dmg", name = "Draw Damage On HP", value = true, leftIcon = icons.Hero})
Menu.Draw:MenuElement({id = "Q", name = "Q", value = false, leftIcon = icons.Q})
Menu.Draw:MenuElement({id = "W", name = "W", value = false, leftIcon = icons.W})
Menu.Draw:MenuElement({id = "E", name = "E", value = false, leftIcon = icons.E})
Menu.Draw:MenuElement({id = "R", name = "R", value = false, leftIcon = icons.R})
--Pred
local ChangePred
local function CheckPred(newVal)
    if newVal == 1 then
        if _G.WR_COMMON_LOADED and ChangePred then
            return ChangePred(newVal)
        end
    elseif newVal == 2 then
        if not _G.GGPrediction and FileExist(COMMON_PATH.."GGPrediction.lua") then
            require('GGPrediction')
        end
        if _G.GGPrediction and ChangePred then
            return ChangePred(newVal)
        end
    elseif newVal == 3 then
        if not _G.PremiumPrediction and FileExist(COMMON_PATH.."PremiumPrediction.lua") then
            require('PremiumPrediction')
        end
        if _G.PremiumPrediction and ChangePred then
            return ChangePred(newVal)
        end
    end
end
DelayAction(function()
Menu:MenuElement({id = "Pred", name = "Choose Pred", value = 2, drop = {"Internal Pred", "GGPred", "PremiumPred"}, callback = CheckPred()})
end, 0.05)

local _SPELL_TABLE_PROCESS = {}
local _ANIMATION_TABLE = {}
local _VISION_TABLE = {}
local _LEVEL_UP_TABLE = {}
local _ITEM_TABLE = {}
local _PATH_TABLE = {}
 
class 'BuffExplorer'
 
function BuffExplorer:__init()
    __BuffExplorer = true
    self.Heroes = {}
    self.Buffs = {}
    self.RemoveBuffCallback = {}
    self.UpdateBuffCallback = {}
    Callback.Add("Tick", function () self:Tick() end)
end
 
function BuffExplorer:Tick() -- We can easily get rid of the pairs loops
    for i = 1, HeroCount() do
        local hero = Hero(i)
        if not self.Heroes[hero] and not self.Buffs[hero.networkID] then
            insert(self.Heroes, hero)
            self.Buffs[hero.networkID] = {}
        end
    end
    if self.UpdateBuffCallback ~= {} then
        for i = 1, #self.Heroes do
            local hero = self.Heroes[i]
            for i = 1, hero.buffCount do
                local buff = hero:GetBuff(i)
                if self:Valid(buff) then
                    if not self.Buffs[hero.networkID][buff.name] or (self.Buffs[hero.networkID][buff.name] and self.Buffs[hero.networkID][buff.name].expireTime ~= buff.expireTime) then
                        self.Buffs[hero.networkID][buff.name] = {expireTime = buff.expireTime, sent = true, networkID = buff.sourcenID, buff = buff}
                        for i, cb in pairs(self.RemoveBuffCallback) do
                            cb(hero, buff)
                        end
                    end
                end
            end
        end
    end
    if self.RemoveBuffCallback ~= {} then
        for i = 1, #self.Heroes do
            local hero = self.Heroes[i]
            for buffname, buffinfo in pairs(self.Buffs[hero.networkID]) do
                if buffinfo.expireTime < Timer() then
                    for i, cb in pairs(self.UpdateBuffCallback) do
                        cb(hero, buffinfo.buff)
                    end
                    self.Buffs[hero.networkID][buffname] = nil
                end
            end
        end
    end
end
 
function BuffExplorer:Valid(buff)
    return buff and buff.name and #buff.name > 0 and buff.startTime <= Timer() and buff.expireTime > Timer()
end
 
class("Animation")
 
function Animation:__init()
    _G._ANIMATION_STARTED = true
    self.OnAnimationCallback = {}
    Callback.Add("Tick", function () self:Tick() end)
end
 
function Animation:Tick()
    if self.OnAnimationCallback ~= {} then
        for i = 1, HeroCount() do
            local hero = Hero(i)
            local netID = hero.networkID
            if hero.activeSpellSlot then
                if not _ANIMATION_TABLE[netID] and hero.charName ~= "" then
                    _ANIMATION_TABLE[netID] = {animation = ""}
                end
                local _animation = hero.attackData.animationTime
                if _ANIMATION_TABLE[netID] and _ANIMATION_TABLE[netID].animation ~= _animation then
                    for _, Emit in pairs(self.OnAnimationCallback) do
                        Emit(hero, hero.attackData.animationTime)
                    end
                    _ANIMATION_TABLE[netID].animation = _animation
                end
            end
        end
    end
end
 
class("Vision")
 
function Vision:__init()
    self.GainVisionCallback = {}
    self.LoseVisionCallback = {}
    _G._VISION_STARTED = true
    Callback.Add("Tick", function () self:Tick() end)
end
 
function Vision:Tick()
    local heroCount = HeroCount()
    --if heroCount <= 0 then return end
    for i = 1, heroCount do
        local hero = Hero(i)
        if hero then
            local netID = hero.networkID
            if not _VISION_TABLE[netID] then
                _VISION_TABLE[netID] = {visible = hero.visible}
            end
            if self.LoseVisionCallback ~= {} then
                if hero.visible == false and _VISION_TABLE[netID] and _VISION_TABLE[netID].visible == true then
                    _VISION_TABLE[netID] = {visible = hero.visible}
                    for _, Emit in pairs(self.LoseVisionCallback) do
                        Emit(hero)
                    end
                end
            end
            if self.GainVisionCallback ~= {} then
                if hero.visible == true and _VISION_TABLE[netID] and _VISION_TABLE[netID].visible == false then
                    _VISION_TABLE[netID] = {visible = hero.visible}
                    for _, Emit in pairs(self.GainVisionCallback) do
                        Emit(hero)
                    end
                end
            end
        end
    end
end
 
class "Path"
 
function Path:__init()
    self.OnNewPathCallback = {}
    self.OnDashCallback = {}
    _G._PATH_STARTED = true
    Callback.Add("Tick", function() self:Tick() end)
end
 
function Path:Tick()
    if self.OnNewPathCallback ~= {} or self.OnDashCallback ~= {} then
        for i = 1, HeroCount() do
            local hero = Hero(i)
            self:OnPath(hero)
        end
    end
end
 
function Path:OnPath(unit)
    if not _PATH_TABLE[unit.networkID] then
        _PATH_TABLE[unit.networkID] = {
            pos = unit.posTo,
            speed = unit.ms,
        time = Timer()}
    end
    
    if _PATH_TABLE[unit.networkID].pos ~= unit.posTo then
        local path = unit.pathing
        local isDash = path.isDashing
        local dashSpeed = path.dashSpeed
        local dashGravity = path.dashGravity
        local dashDistance = GetDistance(unit.pos, unit.posTo)
        --
        _PATH_TABLE[unit.networkID] = {
            startPos = unit.pos,
            pos = unit.posTo,
            speed = unit.ms,
        time = Timer()}
        --
        for k, cb in pairs(self.OnNewPathCallback) do
            cb(unit, unit.pos, unit.posTo, isDash, dashSpeed, dashGravity, dashDistance)
        end
        --
        if isDash then
            for k, cb in pairs(self.OnDashCallback) do
                cb(unit, unit.pos, unit.posTo, dashSpeed, dashGravity, dashDistance)
            end
        end
    end
end
 
class("Interrupter")
 
function Interrupter:__init()
    _G._INTERRUPTER_START = true
    self.InterruptCallback = {}
    self.spells = {--ty Deftsu
        ["CaitlynAceintheHole"] = {Name = "Caitlyn", displayname = "R | Ace in the Hole", spellname = "CaitlynAceintheHole"},
        ["Crowstorm"] = {Name = "FiddleSticks", displayname = "R | Crowstorm", spellname = "Crowstorm"},
        ["DrainChannel"] = {Name = "FiddleSticks", displayname = "W | Drain", spellname = "DrainChannel"},
        ["GalioIdolOfDurand"] = {Name = "Galio", displayname = "R | Idol of Durand", spellname = "GalioIdolOfDurand"},
        ["ReapTheWhirlwind"] = {Name = "Janna", displayname = "R | Monsoon", spellname = "ReapTheWhirlwind"},
        ["KarthusFallenOne"] = {Name = "Karthus", displayname = "R | Requiem", spellname = "KarthusFallenOne"},
        ["KatarinaR"] = {Name = "Katarina", displayname = "R | Death Lotus", spellname = "KatarinaR"},
        ["LucianR"] = {Name = "Lucian", displayname = "R | The Culling", spellname = "LucianR"},
        ["AlZaharNetherGrasp"] = {Name = "Malzahar", displayname = "R | Nether Grasp", spellname = "AlZaharNetherGrasp"},
        ["Meditate"] = {Name = "MasterYi", displayname = "W | Meditate", spellname = "Meditate"},
        ["MissFortuneBulletTime"] = {Name = "MissFortune", displayname = "R | Bullet Time", spellname = "MissFortuneBulletTime"},
        ["AbsoluteZero"] = {Name = "Nunu", displayname = "R | Absoulte Zero", spellname = "AbsoluteZero"},
        ["PantheonRJump"] = {Name = "Pantheon", displayname = "R | Jump", spellname = "PantheonRJump"},
        ["PantheonRFall"] = {Name = "Pantheon", displayname = "R | Fall", spellname = "PantheonRFall"},
        ["ShenStandUnited"] = {Name = "Shen", displayname = "R | Stand United", spellname = "ShenStandUnited"},
        ["Destiny"] = {Name = "TwistedFate", displayname = "R | Destiny", spellname = "Destiny"},
        ["UrgotSwap2"] = {Name = "Urgot", displayname = "R | Hyper-Kinetic Position Reverser", spellname = "UrgotSwap2"},
        ["VarusQ"] = {Name = "Varus", displayname = "Q | Piercing Arrow", spellname = "VarusQ"},
        ["VelkozR"] = {Name = "Velkoz", displayname = "R | Lifeform Disintegration Ray", spellname = "VelkozR"},
        ["InfiniteDuress"] = {Name = "Warwick", displayname = "R | Infinite Duress", spellname = "InfiniteDuress"},
        ["XerathLocusOfPower2"] = {Name = "Xerath", displayname = "R | Rite of the Arcane", spellname = "XerathLocusOfPower2"},
    }
    Callback.Add("Tick", function() self:OnTick() end)
end
 
function Interrupter:AddToMenu(unit, menu)
    self.menu = menu
    if unit then
        for k, spells in pairs(self.spells) do
            if spells.Name == unit.charName then
                self.menu:MenuElement({id = spells.spellname, name = spells.Name .. " | " .. spells.displayname, value = true})
            end
        end
    end
end
 
function Interrupter:OnTick()
    local enemies = GetEnemyHeroes(3000)
    for i = 1, #(enemies) do
        local enemy = enemies[i]
        if enemy and enemy.activeSpell and enemy.activeSpell.valid then
            local spell = enemy.activeSpell
            if self.spells[spell.name] and self.menu and self.menu[spell.name] and self.menu[spell.name]:Value() and spell.isChanneling and spell.castEndTime - Timer() > 0 then
                for i, Emit in pairs(self.InterruptCallback) do
                    Emit(enemy, spell)
                end
            end
        end
    end
end

if myHero.charName == "Vladimir" then
    
    class 'Vladimir'
    
    function Vladimir:__init()
        --[[Data Initialization]]
        self.Allies, self.Enemies = {}, {}
        self.scriptVersion = "0.02"
        self:Spells()
        self:Menu()
        --[[Default Callbacks]]
        Callback.Add("Tick", function() self:OnTick() end)
        Callback.Add("Draw", function() self:OnDraw() end)
        --[[Orb Callbacks]]
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)
    end
    
    function Vladimir:Spells()
        local flashData = myHero:GetSpellData(SUMMONER_1).name:find("Flash") and SUMMONER_1 or myHero:GetSpellData(SUMMONER_2).name:find("Flash") and SUMMONER_2 or nil
        self.Q = Spell({
            Slot = 0,
            Range = 600,
            Delay = 0.25,
            Speed = huge,
            Radius = huge,
            Collision = false,
            From = myHero,
            Type = "Targetted"
        })
        self.W = Spell({
            Slot = 1,
            Range = huge,
            Delay = 0,
            Speed = huge,
            Radius = 175,
            Collision = false,
            From = myHero,
            Type = "Press" or GGPrediction.SPELLTYPE_CIRCLE or "circular"
        })
        self.E = Spell({ --Missile name = VladimirEMissile
            Slot = 2,
            Range = 600, --Missile range says 1200?lol
            Delay = 0.25,
            Speed = 4000, --was 2500
            Radius = 60,
            Collision = true or GGPrediction.COLLISION_MINION or GGPrediction.COLLISION_ENEMYHERO or GGPrediction.COLLISION_YASUOWALL,
            From = myHero,
            Type = "Press" or GGPrediction.SPELLTYPE_CIRCLE or "circular"
        })
        self.R = Spell({
            Slot = 3,
            Range = 625,
            Delay = 0.25,
            Speed = huge,
            Radius = 375,
            Collision = false,
            From = myHero,
            Type = "AOE" or GGPrediction.SPELLTYPE_CIRCLE or "circular"
        })
        self.Flash = flashData and Spell({
            Slot = flashData,
            Range = 425,
            Delay = 0.00,
            Speed = huge,
            Radius = 200 or myHero.boundingRadius, --or myHero.boundingRadius
            Collision = false,
            From = myHero,
            Type = "Press" or GGPrediction.SPELLTYPE_LINE or "linear"
        })
    end
    
    function Vladimir:Menu()
		_G.SDK.ObjectManager:OnAllyHeroLoad(function(args)
			insert(self.Allies, args.unit)
		end)
		_G.SDK.ObjectManager:OnEnemyHeroLoad(function(args)
			insert(self.Enemies, args.unit)
		end)
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "LastHit", name = "Use to LastHit", value = false}) --add
        --Menu.Q:MenuElement({id = "Unkillable", name = "    Only when Unkillable", value = false}) -- add
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Auto", name = "Auto Use to Harass", value = true})
        Menu.Q:MenuElement({id = "MinHealth", name = "    When Health Below %", value = 100, min = 10, max = 100, step = 1})
        Menu.Q:MenuElement({id = "KS", name = "Use on KS", value = true})
        Menu.Q:MenuElement({id = "Flee", name = "Use on Flee", value = true})
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})
        Menu.W:MenuElement({id = "Gapcloser", name = "Use on GapCloser", value = false})
        Menu.W:MenuElement({id = "Count", name = "Auto Use When X Enemies Around", value = 2, min = 0, max = 5, step = 1})
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.E:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.E:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.E:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.R:MenuElement({id = "Duel", name = "Use To Duel", value = true})
        Menu.R:MenuElement({id = "Heroes", name = "Duel Targets", type = MENU})
        Menu.R:MenuElement({name = " ", drop = {"Misc"}})
        Menu.R:MenuElement({id = "Count", name = "Auto Use When X Enemies", value = 2, min = 0, max = 5, step = 1})
        --Burst
        Menu:MenuElement({id = "Burst", name = "Burst Settings", type = MENU})
        Menu.Burst:MenuElement({id = "Flash", name = "Allow Flash On Burst", value = true})
        Menu.Burst:MenuElement({id = "Key", name = "Burst Key", key = string.byte("T")})
        --
        Menu:MenuElement({name = "Impuls[WR] "..charName.." Script", drop = {"Release_"..self.scriptVersion}})
        --
		_G.SDK.ObjectManager:OnEnemyHeroLoad(function(args)
			Menu.R.Heroes:MenuElement({id = args.charName, name = args.charName, value = false})
		end)
    end
    
    function Vladimir:OnTick()
        if ShouldWait() then return end
        --
        self.enemies = GetEnemyHeroes(1500)
        self.target = GetTarget(self.Q.Range, 1)
        self.mode = GetMode()
        --
        if Menu.Burst.Key:Value() then
            self:Burst()
            return
        end
        self:LogicE()
        self:LogicW()
        if myHero.isChanneling then return end
        self:Auto()
        self:KillSteal()
        --
        if not self.mode then return end
        local executeMode =
        self.mode == 1 and self:Combo() or
        self.mode == 2 and self:Harass() or
        self.mode == 3 and self:Clear() or
        self.mode == 4 and self:Clear() or
        self.mode == 5 and self:LastHit() or
        self.mode == 6 and self:Flee()
    end
    
    function Vladimir:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then
            args.Process = false
            return
        end
    end
    
    function Vladimir:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() or not myHero.valid then
            args.Process = false
            return
        end
    end
    
    function Vladimir:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)
        if ShouldWait() or not self.W:IsReady() or not Menu.W.Gapcloser:Value() then return end
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 500 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then --Gapcloser
            if self.E:IsReady() and not IsKeyDown(HK_E) then --*
                KeyDown(HK_E)
                self.W:Cast()
            elseif IsKeyDown(HK_E) then
            self.W:Cast()
            end
        end
    end
    
    function Vladimir:Auto()
        local rMinHit, wMinHit = Menu.R.Count:Value(), Menu.W.Count:Value()
        --
        if self.Q:IsReady() and (Menu.Q.Auto:Value() and HealthPercent(myHero) <= Menu.Q.MinHealth:Value()) then
            if self.target then
                self.Q:Cast(self.target); return
            end
        end
        if rMinHit ~= 0 and self.R:IsReady() then
            local bestPos, hit = self.R:GetBestCircularCastPos(nil, GetEnemyHeroes(1000))
            if bestPos and hit >= rMinHit then
                self.R:Cast(bestPos); return
            end
        end
        if wMinHit ~= 0 and self.W:IsReady() and IsKeyDown(HK_E) then --*
            local nearby = GetEnemyHeroes(600)
            if #nearby >= wMinHit then
                self.W:Cast(); return
            end
        end
    end
    
    function Vladimir:Combo()
        if not self.target then return end
        --
        if self.R:IsReady() and Menu.R.Duel:Value() and Menu.R.Heroes[self.target.charName] and Menu.R.Heroes[self.target.charName]:Value() then
            self.R:CastToPred(self.target, 2)
        elseif self.Q:IsReady() and Menu.Q.Combo:Value() then
            self.Q:Cast(self.target)
        elseif self.E:IsReady() and not IsKeyDown(HK_E) and Menu.E.Combo:Value() then
            KeyDown(HK_E)
        end
    end
    
    function Vladimir:Harass()
        if not self.target then return end
        --
        if self.Q:IsReady() and Menu.Q.Harass:Value() then
            self.Q:Cast(self.target)
        elseif self.E:IsReady() and not IsKeyDown(HK_E) and Menu.E.Harass:Value() then
            KeyDown(HK_E)
        end
    end
    
    function Vladimir:Clear()
        local qRange, jCheckQ, lCheckQ = self.Q.Range, Menu.Q.Jungle:Value(), Menu.Q.Clear:Value()
        local eRange, jCheckE, lCheckE = self.E.Range, Menu.E.Jungle:Value(), Menu.E.Clear:Value()
        --
        if self.Q:IsReady() and (jCheckQ or lCheckQ) then
            local minions = (jCheckQ and GetMonsters(qRange)) or {}
            minions = (#minions == 0 and lCheckQ and GetEnemyMinions(qRange)) or minions
            for i = 1, #minions do
                local minion = minions[i]
                if minion.health <= self.Q:GetDamage(minion) or minion.team == TEAM_JUNGLE then
                    self.Q:Cast(minion)
                    return
                end
            end
        end
        if self.E:IsReady() and (jCheckE or lCheckE) then
            local minions = (jCheckE and GetMonsters(eRange)) or {}
            minions = (#minions == 0 and lCheckE and GetEnemyMinions(eRange)) or minions
            if #minions >= Menu.E.Min:Value() or (minions[1] and minions[1].team == TEAM_JUNGLE) then
                KeyDown(HK_E)
            end
        end
    end
    
    function Vladimir:LastHit()
        if self.Q:IsReady() and Menu.Q.LastHit:Value() then
            local minions = GetEnemyMinions(self.Q.Range)
            for i = 1, #minions do
                local minion = minions[i]
                if minion.health <= self.Q:GetDamage(minion) then --check if Q dmg is right
                    self.Q:Cast(minion)
                    return
                end
            end
        end
    end
    
    function Vladimir:Flee()
        if Menu.Q.Flee:Value() and self.Q:IsReady() then
            if self.target then
                self.Q:Cast(self.target)
            end
        elseif Menu.W.Flee:Value() and self.W:IsReady() then
            if #GetEnemyHeroes(400) >= 1 then
                self.W:Cast()
            end
        end
    end
    
    function Vladimir:KillSteal()
        if (Menu.Q.KS:Value() and self.Q:IsReady()) then
            for i = 1, #self.enemies do
                local enemy = self.enemies[i]
                if enemy and self.Q:GetDamage(enemy) >= enemy.health then
                    self.Q:Cast(self.target); return
                end
            end
        end
    end
    
    function Vladimir:OnDraw()
        DrawSpells(self)
    end
    
    function Vladimir:LogicE()
        if not HasBuff(myHero, "VladimirE") then
            local eSpell = myHero:GetSpellData(self.E.Slot)
            if eSpell.currentCd ~= 0 and eSpell.cd - eSpell.currentCd > 0.5 and IsKeyDown(HK_E) then
                KeyUp(HK_E) --release stuck key
            end
            return
        end
        --
        local eRange = self.E.Range
        local enemies, minions = GetEnemyHeroes(eRange + 300), GetEnemyMinions(eRange + 300)
        local willHit, entering, leaving = 0, 0, 0
        for i = 1, #enemies do
            local target = enemies[i]
            local tP, tP2, pP2 = target.pos, target:GetPrediction(huge, 0.2), myHero:GetPrediction(huge, 0.2)
            --
            if GetDistance(tP) <= eRange then --if inside(might go out)
                if #mCollision(myHero.pos, tP, self.E, minions) == 0 then
                    willHit = willHit + 1
                end
                if GetDistance(tP2, pP2) > eRange then
                    leaving = leaving + 1
                end
            elseif GetDistance(tP2, pP2) < eRange then --if outside(might come in)
                entering = entering + 1
            end
        end
        if entering <= leaving and (willHit > 0 or entering == 0) then
            if leaving > 0 and IsKeyDown(HK_E) then
                KeyUp(HK_E) --release skill
            end
        end
    end
    
    function Vladimir:LogicW()
        if self.W:IsReady() and not self.Q:IsReady() and not self.E:IsReady() and ((self.mode == 1 and Menu.W.Combo:Value()) or (self.mode == 2 and Menu.W.Harass:Value())) then
            local nearby = GetEnemyHeroes(600)
            --
            for i = 1, #nearby do
                local enemy = nearby[i]
                if GetDistance(enemy) <= 300 and IsKeyDown(HK_E) then --*
                    self.W:Cast()
                end
            end
        end
    end
    
    local bursting, startEarly = false, false
    function Vladimir:Burst()
        Orbwalk()
        if not HasBuff(myHero, "vladimirqfrenzy") then
            return self.Q:IsReady() and self:LoadQ()
        end
        if not bursting and self.Q:IsReady() and (self.E:IsReady() or startEarly) and self.R:IsReady() then
            local canFlash = self.Flash and self.Flash:IsReady() and Menu.Burst.Flash:Value()
            local range = self.E.Range + (canFlash and self.Flash.Range or 0)
            local bTarget, eTarget = GetTarget(range + 300, 1), GetTarget(self.E.Range, 1)
            local shouldFlash = canFlash and bTarget ~= eTarget
            --
            if bTarget then
                startEarly = GetDistance(bTarget) > 600 and KeyDown(HK_E)
                if GetDistance(bTarget) < range then
                    self:BurstCombo(bTarget, shouldFlash, 1)
                end
            end
        end
    end
    
    function Vladimir:BurstCombo(target, shouldFlash, step)
        if step == 1 then
            bursting = true
            local chargeE = not IsKeyDown(HK_E) and KeyDown(HK_E)
            if shouldFlash then
                local pos, hK = mousePos, self.Flash:SlotToHK()
                SetCursorPos(target.pos)
                KeyDown(hK)
                KeyUp(hK)
                DelayAction(function() SetCursorPos(pos) end, 0.03)
            end
            DelayAction(function() self:BurstCombo(target, shouldFlash, 2) end, 0.3)
        elseif step == 2 then
            local bestPos = self.R:GetBestCircularCastPos(target, GetEnemyHeroes(self.R.Radius or 1000))
            Control.CastSpell(HK_R, bestPos or target) --Control.CastSpell(HK_R, target, pos)
            local releaseE = IsKeyDown(HK_E) and KeyUp(HK_E)
            DelayAction(function() self:BurstCombo(target, shouldFlash, 3) end, 0.3)
        elseif step == 3 then
            self.Q:Cast(target)
            if self.E:IsReady() and not IsKeyDown(HK_E) then
                KeyDown(HK_E)
                DelayAction(function() self.W:Cast() end, 0.3)
            elseif not self.E:IsReady() then
                DelayAction(function() self.W:Cast() end, 0.3)
            end
            DelayAction(function() self:Protobelt(target) end, 0.3)
            bursting = false
        end
    end
    
    function Vladimir:LoadQ()
        local qRange = self.Q.Range
        local qTarget = GetTarget(qRange, 1)
        if qTarget then return self.Q:Cast(qTarget) end
        --
        local minions = GetEnemyMinions(qRange)
        if #minions < 1 then minions = GetMonsters(qRange) end
        if minions[1] then return self.Q:Cast(minions[1]) end
    end
    
    function Vladimir:Protobelt(target)
        local slot, key = GetItemSlot(3152)
        if key and slot ~= 0 then
            Control.CastSpell(key, target)
        end
    end
    
    table.insert(LoadCallbacks, function()
        Vladimir()
    end)
end

Callback.Add('Load', function()
    for i = 1, #LoadCallbacks do
        LoadCallbacks[i]()
    end
end)

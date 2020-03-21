local Heroes = {"Irelia"}

if not table.contains(Heroes, myHero.charName) then return end




----------------------------------------------------
--|                    Checks                    |--
----------------------------------------------------

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end

if not FileExist(COMMON_PATH .. "PremiumPrediction.lua") then
	print("PremiumPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/Ark223/GoS-Scripts/master/PremiumPrediction.lua", COMMON_PATH .. "PremiumPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "PremiumPrediction.lua") do end
end


-- [ AutoUpdate ]
do
    
    local Version = 0.12
    
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
            print("Irelia loaded")
        end
    
    end
    
    AutoUpdate()

end



----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local _OnVision = {}
local sqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
local GameTimer = Game.Timer
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local Orb
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local ControlCastSpell = Control.CastSpell
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
_G.LATENCY = 0.05

require "DamageLib"

local DangerousSpells = {
	["CaitlynAceintheHole"] = {charName = "Caitlyn", slot = _R, type = "targeted", displayName = "Ace in the Hole", range = 3500},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = _E, type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},	
	["DravenR"] = {charName = "Draven", displayName = "Whirling Death", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 0.25, radius = 160, collision = false},	
	["JinxR"] = {charName = "Jinx", displayName = "Death Rocket", slot = _R, type = "linear", speed = 1700, range = 12500, delay = 0.6, radius = 140, collision = false},
	["JayceShockBlast"] = {charName = "Jayce", displayName = "ShockBlast", slot = _Q, type = "linear", speed = 2350, range = 1300, delay = 0.25, radius = 70, collision = true},
	["BlindMonkRKick"] = {charName = "LeeSin", slot = _R, type = "targeted", displayName = "Dragon's Rage", range = 375},	
	["UrgotR"] = {charName = "Urgot", displayName = "Fear Beyond Death", slot = _R, type = "linear", speed = 3200, range = 1600, delay = 0.4, radius = 80, collision = false},

}

function OnLoad()
	if table.contains(Heroes, myHero.charName) then
		_G[myHero.charName]()
		LoadUnits()
	end	
end

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

local function EnemyHeroes()
	return Enemies
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end

function GetTarget(range) 
	if Orb == 1 then
		if myHero.ap > myHero.totalDamage then
			return EOW:GetTarget(range, EOW.ap_dec, myHero.pos)
		else
			return EOW:GetTarget(range, EOW.ad_dec, myHero.pos)
		end
	elseif Orb == 2 and TargetSelector then
		if myHero.ap > myHero.totalDamage then
			return TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
		else
			return TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		end
	elseif _G.GOS then
		if myHero.ap > myHero.totalDamage then
			return GOS:GetTarget(range, "AP")
		else
			return GOS:GetTarget(range, "AD")
        end
    elseif _G.gsoSDK then
		return _G.gsoSDK.TS:GetTarget()
	
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end	
end

function GetMode()   
    if Orb == 1 then
        if combo == 1 then
            return 'Combo'
        elseif harass == 2 then
            return 'Harass'
        elseif lastHit == 3 then
            return 'Lasthit'
        elseif laneClear == 4 then
            return 'Clear'
        end
    elseif Orb == 2 then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "LastHit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
    elseif Orb == 3 then
        return GOS:GetMode()
    elseif Orb == 4 then
        return _G.gsoSDK.Orbwalker:GetMode()
	elseif Orb == 5 then
	  return _G.PremiumOrbwalker:GetMode()
	end
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

local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
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

local function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,GameMinionCount() do
	local hero = GameMinion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
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

local function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff.count
    end
  end
  return 0
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
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.name == 'recall' and buff.duration > 0 then
            return true, GameTimer() - buff.startTime
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
	return pointSegment, pointLine, isOnSegment
end

local function CastSpell(spell,pos,range,delay)
    local range = range or MathHuge
    local delay = delay or 250
    local ticker = GetTickCount()


    if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Latency() and pos:ToScreen().onScreen then
        castSpell.state = 1
        castSpell.mouse = mousePos
        castSpell.tick = ticker
    end
    if castSpell.state == 1 then
        if ticker - castSpell.tick < Latency() then
            ControlSetCursorPos(pos)
            ControlKeyDown(spell)
            ControlKeyUp(spell)
            castSpell.casting = ticker + delay
            DelayAction(function()
                if castSpell.state == 1 then
                    ControlSetCursorPos(castSpell.mouse)
                    castSpell.state = 0
                end
            end,Latency()/1000)
        end
        if ticker - castSpell.casting > Latency() then
            ControlSetCursorPos(castSpell.mouse)
            castSpell.state = 0
        end
    end
end

local function GetEnemyHeroes()
	return Enemies
end 

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function EBuff()
	if HasBuff(myHero, "IreliaE") then
		return true
	end
	return false	
end

local function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
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

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
end

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
local function GetInventorySlotItem(itemID)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
    for _, j in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}) do
        if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
    end
    return nil
end

local function CheckTitan(itemID)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
    for _, j in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}) do
        if myHero:GetItemData(j).itemID == itemID then return j end
    end
    return nil
end

local function LineCircleIntersection(p1, p2, circle, radius)
    local dx, dy = p2.x - p1.x, p2.z - p1.z
    local a = dx * dx + dy * dy
    local b = 2 * (dx * (p1.x - circle.x) + dy * (p1.z - circle.z))
    local c = (p1.x - circle.x) * (p1.x - circle.x) + (p1.z - circle.z) * (p1.z - circle.z) - (radius * radius)
    local delta = b * b - 4 * a * c
    if delta >= 0 then
        local t1, t2 = (-b + sqrt(delta)) / (2 * a), (-b - sqrt(delta)) / (2 * a)
        return Vector(p1.x + t1 * dx, p1.y, p1.z + t1 * dy), Vector(p1.x + t2 * dx, p1.y, p1.z + t2 * dy)
    end
    return nil, nil
end

local function GetBestECastPositions(units)
	local startPos, endPos, count = nil, nil, 0
	local candidates, unitPositions = {}, {}
	for i, unit in ipairs(units) do
		local cp = GetPred(unit,1000,0.75)
		if cp then candidates[i], unitPositions[i] = cp, cp end	
	end
	local maxCount = #units
	for i = 1, maxCount do
		for j = 1, maxCount do
			if candidates[j] ~= candidates[i] then
				TableInsert(candidates, Vector(candidates[j] + candidates[i]) / 2)
			end
		end
	end
	for i, unit2 in pairs(units) do
		local cp = GetPred(unit2,1000,0.75)
		if cp then
			if myHero.pos:DistanceTo(cp.pos) < 775 then
				for i, pos2 in ipairs(candidates) do
					if pos2:DistanceTo(cp.pos) < 775 then 
						
						local ePos = Vector(cp):Extended(pos2, 775)
						local number = 0
						for i = 1, #unitPositions do
							local unitPos = unitPositions[i]   
							local pointLine, pointSegment, onSegment = VectorPointProjectionOnLineSegment(cp, ePos, unitPos)
							if pointSegment and GetDistance(pointSegment, unitPos) < 1550 then number = number + 1 end 
							 
						end
						if number then startPos, endPos, count = cp, ePos, number  end

					end
				end
			end
		end
	end
	return startPos, endPos, count	
end

local function CheckHPPred(unit)
local speed = 1500+myHero.ms
local range = GetDistance(myHero.pos, unit.pos)
local time = range / speed
	if _G.SDK and _G.SDK.Orbwalker then
		return _G.SDK.HealthPrediction:GetPrediction(unit, time)
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetHealthPrediction(unit, time)
	end
end

local function MyHeroNotReady()
    return myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero)
end




----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Irelia"

local WData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.1, Radius = 100, Range = 825, Speed = 1400, Collision = false
}

local WspellData = {speed = 1400, range = 825, delay = 0.1, radius = 100, collision = {}, type = "linear"}

--[[
local EData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.75, Radius = 50, Range = 775, Speed = 2000, Collision = false
}]]

local RData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 160, Range = 950, Speed = 2000, Collision = false
}

local RspellData = {speed = 2000, range = 950, delay = 0.25, radius = 160, collision = {}, type = "linear"}
 	

function Irelia:__init()
	self.DetectedMissiles = {}; self.DetectedSpells = {}; self.Target = nil; self.Timer = 0 	
	self.charging = false
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end) 
	
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
	
DelayAction(function()
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		require('GamsteronPrediction')
	else
		require('PremiumPrediction')
	end	
end, 1.0)	
end

function Irelia:LoadMenu()                     
	
--MainMenu
self.Menu = MenuElement({type = MENU, id = "PussyIrelia", name = "PussyIrelia"})
	
self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})
	
	--ComboMenu  
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	self.Menu.ComboSet.Combo:MenuElement({id = "QLogic", name = "Last[Q]Almost Kill or Kill", key = string.byte("Z"), toggle = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseE", name = "[E] (WIP)", value = false})	
	self.Menu.ComboSet.Combo:MenuElement({id = "UseEL", name = "[E] Logic (WIP)", value = 1, drop = {"Focus most Stuns", "Focus single Target"}})	
	self.Menu.ComboSet.Combo:MenuElement({id = "UseR", name = "[R]Single Target", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseRCount", name = "Auto[R] Multiple Enemys", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "RCount", name = "Multiple Enemys", value = 2, min = 2, max = 5, step = 1})
	self.Menu.ComboSet.Combo:MenuElement({id = "Gap", name = "Gapclose [Q]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "Stack", name = "Stack Passive near Target/Minion", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "Draw", name = "Draw QLogic Text", value = true})	
	
	--BurstModeMenu
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Burst", name = "Burst Mode"})	
	self.Menu.ComboSet.Burst:MenuElement({name = " ", drop = {"If Burst Active then Combo Inactive"}})	
	self.Menu.ComboSet.Burst:MenuElement({id = "Start", name = "Use Burst Mode", key = string.byte("U"), toggle = true})
	self.Menu.ComboSet.Burst:MenuElement({id = "Lvl", name = "Irelia Level to Start Burst", value = 6, min = 6, max = 18, step = 1})
	self.Menu.ComboSet.Burst:MenuElement({id = "Draw", name = "Draw Text", value = true})	


	self.Menu.ComboSet:MenuElement({type = MENU, id = "Ninja", name = "Ninja Mode"})
	self.Menu.ComboSet.Ninja:MenuElement({id = "Q", name = "Q on all Marked Enemys", key = string.byte("I"), toggle = true})

self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	self.Menu.ClearSet.Clear.Last:MenuElement({name = " ", drop = {"Is only active, if AutoQ Off)"}})	
	self.Menu.ClearSet.Clear.Last:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})

	--LastHitMode Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "LastHit", name = "LastHit Mode"})
	self.Menu.ClearSet.LastHit:MenuElement({name = " ", drop = {"Is only active, if AutoQ Off)"}})	
	self.Menu.ClearSet.LastHit:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.ClearSet.LastHit:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.ClearSet.LastHit:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})	
	self.Menu.ClearSet.LastHit:MenuElement({id = "Active", name = "LastHit Key", key = string.byte("X")})

	--AutoQ
	self.Menu.ClearSet:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ Mode"})
	self.Menu.ClearSet.AutoQ:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.ClearSet.AutoQ:MenuElement({id = "Q", name = "Auto Q Toggle Key", key = string.byte("T"), toggle = true})
	self.Menu.ClearSet.AutoQ:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	self.Menu.ClearSet.AutoQ:MenuElement({id = "Draw", name = "Draw On/Off Text", value = true})	


	--HarassMenu
self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})	
	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"Marked + Dash back Minion", "Everytime"}})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] (WIP)", value = false})


	--KillSteal
self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal Settings"})
	
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})		

	
self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})		

	--Flee
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Flee", name = "Flee Mode"})
	self.Menu.MiscSet.Flee:MenuElement({id = "Q", name = "Flee[Q]", value = true})		
	
	--AutoW Dangerous Spells
	self.Menu.MiscSet:MenuElement({id = "WSet", name = "AutoW Mode [Test]", type = MENU})
	self.Menu.MiscSet.WSet:MenuElement({name = " ", drop = {"Supported Spells"}})
	self.Menu.MiscSet.WSet:MenuElement({name = " ", drop = {"[DravenR,JinxR,JayceQ,LeeSinR,CaitlynR,UrgotR]"}})	
	self.Menu.MiscSet.WSet:MenuElement({id = "UseW", name = "Auto[W] Dangerous Spells", value = true})
	self.Menu.MiscSet.WSet:MenuElement({id = "BlockList", name = "Block List", type = MENU})	
	self.Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()	
		for i, spell in pairs(DangerousSpells) do
			if not DangerousSpells[i] then return end
			for j, k in pairs(EnemyHeroes()) do
				if spell.charName == k.charName and not self.Menu.MiscSet.WSet.BlockList[i] then
					if not self.Menu.MiscSet.WSet.BlockList[i] then self.Menu.MiscSet.WSet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..self.Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)		
		
	--Prediction
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.Menu.MiscSet.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	self.Menu.MiscSet.Drawing:MenuElement({type = MENU, id = "XY", name = "Text Pos Settings"})	
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	
	
end	

function Irelia:Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		if self.Menu.ComboSet.Ninja.Q:Value() then
			self:Ninja()
		end	
		if self.Menu.ComboSet.Burst.Start:Value() and myHero.levelData.lvl <= self.Menu.ComboSet.Burst.Lvl:Value() then
			self:Combo()
		end
		if not self.Menu.ComboSet.Burst.Start:Value() then
			self:Combo()
		end
		if self.Menu.ComboSet.Burst.Start:Value() and myHero.levelData.lvl >= self.Menu.ComboSet.Burst.Lvl:Value() then
			self:Burst()
		end	
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:JungleClear()
		self:Clear()
	elseif Mode == "Flee" then
		self:Flee()
	elseif Mode == "LastHit" then
		if self.Menu.ClearSet.LastHit.Active:Value() then
			self:LastHit()	
		end
	end

	if self.Menu.ClearSet.AutoQ.Q:Value() and Mode ~= "Combo" then
		self:AutoQ()
	end	

	if self.Menu.MiscSet.WSet.UseW:Value() and Ready(_W) then
		self:OnProcessSpell()
		for i, spell in pairs(self.DetectedSpells) do
			self:UseW(i, spell)
		end
	end

	self:KillSteal()	
end

function Irelia:CalcExtraDmg(unit)
	total = 0
	
	local Trinity = GetInventorySlotItem(3078)
	local Sheen = GetInventorySlotItem(1027)	
	local hydra = CheckTitan(3748)	
	local Passive = HasBuff(myHero, "ireliapassivestacksmax")
	local TrinDmg = CalcPhysicalDamage(myHero, unit, 2 * (myHero.totalDamage - myHero.bonusDamage))
	local PassiveDmg = CalcMagicalDamage(myHero, unit, (12 + 3 * myHero.levelData.lvl) + (0.25 * myHero.bonusDamage))	
	local SheenDmg = CalcPhysicalDamage(myHero, unit, myHero.totalDamage - myHero.bonusDamage)
	local hydraDmg = CalcPhysicalDamage(myHero, unit, 5 + 0.01 * myHero.maxHealth)
	
	if Trinity == nil and Sheen == nil and not Passive then
		total = 0
	end
	if Trinity == nil and Sheen == nil and Passive then
		total = PassiveDmg
	end
		
	if Trinity == nil and Sheen == nil and hydra == nil then return total end
	
	if Trinity == nil and Sheen and hydra == nil and not Passive then
		total = SheenDmg
	end
	if Trinity and Sheen == nil and hydra == nil and not Passive then
		total = TrinDmg
	end
	if Trinity == nil and Sheen == nil and hydra and not Passive then
		total = hydraDmg
	end	
	
	
	if Trinity == nil and Sheen and hydra == nil and Passive then
		total = SheenDmg + PassiveDmg
	end	
	if Trinity and Sheen == nil and hydra == nil and Passive then
		total = TrinDmg + PassiveDmg
	end
	if Trinity == nil and Sheen == nil and hydra and Passive then
		total = hydraDmg + PassiveDmg
	end	
	
	
	if Trinity == nil and Sheen and hydra and Passive then
		total = SheenDmg + PassiveDmg + hydraDmg
	end	
	if Trinity and Sheen == nil and hydra and Passive then
		total = TrinDmg + PassiveDmg + hydraDmg
	end	
	return total
		
end

function Irelia:Burst()
local target = GetTarget(1100)     	
if target == nil then return end	
	if IsValid(target) then
		local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg(target)	
		local hp = CheckHPPred(target)	
		local MarkBuff = HasBuff(target, "ireliamark")
		
		
		if self.Menu.ComboSet.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 775 and myHero:GetSpellData(_E).name == "IreliaE" and Ready(_E) and not MarkBuff then
			self:CastE2(target)
		end
		if not EBuff() then 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and MarkBuff then
				ControlCastSpell(HK_Q, target)
			end		

			if myHero.pos:DistanceTo(target.pos) < 825 and Ready(_W) then					
				self:CastW(target)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 850 and myHero.pos:DistanceTo(target.pos) > 300 and not MarkBuff and Ready(_R) and Ready(_Q) and QDmg*2 < target.health then
				self:CastR(target)
			end	

			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				 
				if hp > 0 and QDmg > target.health then
					ControlCastSpell(HK_Q, target)

				end
			end	
			
			self:Gapclose(target)
			self:UseHydraminion(target)
			self:StackPassive(target)
		end	
	end
end	

function Irelia:Ninja()
local target1 = GetTarget(600)	
	for i, target2 in pairs(GetEnemyHeroes()) do
	local Buff = HasBuff(target2, "ireliamark")
		
		if myHero.pos:DistanceTo(target2.pos) <= 600 and IsValid(target2) and Ready(_Q) then 
			if Buff then
				if target2 ~= target1 then		
					local time2 = myHero.pos:DistanceTo(target2.pos) / (1500+myHero.ms)
					local MarkBuff2 = GetBuffData(target2, "ireliamark")
					if MarkBuff2.duration > time2 then
						ControlCastSpell(HK_Q, target2)
					end
				
				else
					local time1 = myHero.pos:DistanceTo(target1.pos) / (1500+myHero.ms)
					local MarkBuff1 = GetBuffData(target1, "ireliamark")
					if MarkBuff1.duration > time1 then
						ControlCastSpell(HK_Q, target1)
					end
				end	
			end
		end	
	end	
end

function Irelia:UseW(i, s)
	if not EBuff() then
		local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
		if s.speed == MathHuge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
		if s.type == "rectangular" then
			local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
			local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
			startPos = StartPosition; endPos = EndPosition
		end
		if s.startTime + travelTime > GameTimer() then
			local Col = VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
			if s.type == "circular" and GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
				local t = s.speed ~= MathHuge and CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay) or 0.29
				if t < 0.3 and not self.charging then 
					Control.KeyDown(HK_W)
					self.charging = true
				
				else
					Control.KeyUp(HK_W)
					self.charging = false
					
				end
			end
		else TableRemove(self.DetectedSpells, i) end
	end	
end

function Irelia:OnProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and spell and DangerousSpells[spell.name] then
		if GetDistance(unit.pos, myHero.pos) > 3500 or not self.Menu.MiscSet.WSet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = DangerousSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle and not self.charging then 
				Control.KeyDown(HK_W)
				self.charging = true
				TableRemove(self.DetectedSpells, i)
			else
				Control.KeyUp(HK_W)
				self.charging = false
				
			end
		else
			local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
			local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
			local endPos, range2 = CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
			TableInsert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = GameTimer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col})
		end
	end
end

function Irelia:UseHydraminion(unit)
local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
	if hydraitem and myHero.pos:DistanceTo(unit.pos) <= 400 then
		ControlCastSpell(keybindings[hydraitem])
	end
end
 
function Irelia:Draw()
  if myHero.dead then return end
	
	if self.Menu.MiscSet.Drawing.DrawR:Value() and Ready(_R) then
    DrawCircle(myHero, 950, 1, DrawColor(255, 225, 255, 10))
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
	
	if self.Menu.ComboSet.Burst.Draw:Value() then
		DrawText("Burst Mode: ", 15, self.Menu.MiscSet.Drawing.XY.x:Value(), self.Menu.MiscSet.Drawing.XY.y:Value()+30, DrawColor(255, 225, 255, 0))
		if self.Menu.ComboSet.Burst.Start:Value() then
			if myHero.levelData.lvl >= self.Menu.ComboSet.Burst.Lvl:Value() then
				DrawText("Active", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+74, self.Menu.MiscSet.Drawing.XY.y:Value()+30, DrawColor(255, 0, 255, 0))
			else
				DrawText("Level too low", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+74, self.Menu.MiscSet.Drawing.XY.y:Value()+30, DrawColor(255, 255, 0, 0)) 
			end
		else
			DrawText("OFF", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+74, self.Menu.MiscSet.Drawing.XY.y:Value()+30, DrawColor(255, 255, 0, 0)) 
		end
	end

	if self.Menu.ClearSet.AutoQ.Draw:Value() then 
		DrawText("Auto[Q] Minion: ", 15, self.Menu.MiscSet.Drawing.XY.x:Value(), self.Menu.MiscSet.Drawing.XY.y:Value()+15, DrawColor(255, 225, 255, 0))
		if self.Menu.ClearSet.AutoQ.Q:Value() then 
			DrawText("ON", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+96, self.Menu.MiscSet.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		else
			DrawText("OFF", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+96, self.Menu.MiscSet.Drawing.XY.y:Value()+15, DrawColor(255, 255, 0, 0)) 
		end	
	end	
	
	DrawText("Ninja Mode: ", 15, self.Menu.MiscSet.Drawing.XY.x:Value(), self.Menu.MiscSet.Drawing.XY.y:Value()+45, DrawColor(255, 225, 255, 0))	
	if self.Menu.ComboSet.Ninja.Q:Value() then 

		DrawText("ON", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+74, self.Menu.MiscSet.Drawing.XY.y:Value()+45, DrawColor(255, 0, 255, 0))
	else
		DrawText("OFF", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+74, self.Menu.MiscSet.Drawing.XY.y:Value()+45, DrawColor(255, 255, 0, 0)) 
		
	end	

	if self.Menu.ComboSet.Combo.Draw:Value() then
		DrawText(" Last[Q] Combo Mode: ", 15, self.Menu.MiscSet.Drawing.XY.x:Value()-3, self.Menu.MiscSet.Drawing.XY.y:Value(), DrawColor(255, 225, 255, 0))
		if self.Menu.ComboSet.Combo.QLogic:Value() then
			DrawText("Almost Kill", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+132, self.Menu.MiscSet.Drawing.XY.y:Value(), DrawColor(255, 0, 255, 0))
		else
			DrawText("Kill", 15, self.Menu.MiscSet.Drawing.XY.x:Value()+132, self.Menu.MiscSet.Drawing.XY.y:Value(), DrawColor(255, 0, 255, 0)) 
		end	
	end		
end

function Irelia:Combo()
local target = GetTarget(1100)     	
if target == nil then return end
	if IsValid(target) then
		local count = GetEnemyCount(600, target)
		
		if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				self:CastE2(target)

			end
		end		
		
		if not EBuff() then 		
			if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 850 and self.Menu.ComboSet.Combo.UseRCount:Value() then
				if count >= self.Menu.ComboSet.Combo.RCount:Value() then					
					self:CastR(target)

				end
			end				
				
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and HasBuff(target, "ireliamark") then
				ControlCastSpell(HK_Q, target)	
				
			end
			
			if self.Menu.ComboSet.Combo.UseW:Value() and Ready(_W) then
				if myHero.pos:DistanceTo(target.pos) <= 825 then					
					self:CastW(target)

				end
			end	
			
			if self.Menu.ComboSet.Combo.UseR:Value() and Ready(_R) and not Ready(_W) then
				if myHero.pos:DistanceTo(target.pos) <= 850 then					
					self:CastR(target)

				end
			end			
			
			if self.Menu.ComboSet.Combo.QLogic:Value() then
				if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then 
					local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg(target)	
					local hp = CheckHPPred(target)
					if hp > 0 and QDmg > target.health then
						ControlCastSpell(HK_Q, target)	
					end			
					
					if myHero.pos:DistanceTo(target.pos) >= 300 and myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and (QDmg*2) >= target.health then
						ControlCastSpell(HK_Q, target)
					end
				end
			
			else
				if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
					local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg(target)	 
					local hp = CheckHPPred(target) 
					if HasBuff(target, "ireliamark") then	
						if hp > 0 and (QDmg*2) > target.health then
							ControlCastSpell(HK_Q, target)	
						end
					else
						if hp > 0 and QDmg > target.health then
							ControlCastSpell(HK_Q, target)	
						end
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
end	

function Irelia:Harass()
local target = GetTarget(1100)     	
if target == nil then return end 
	if IsValid(target) then
	
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				self:CastE2(target)
				
			end
		end
				
		if not EBuff() then 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				if self.Menu.Harass.UseQ:Value() ~= 2 and HasBuff(target, "ireliamark") then
					ControlCastSpell(HK_Q, target)
					DelayAction(function()
					self:CastQMinion(target)
					end,0.5)
				end	
				if self.Menu.Harass.UseQ:Value() ~= 1 then
					ControlCastSpell(HK_Q, target)
				end	
			end
			
			if self.Menu.Harass.UseW:Value() and Ready(_W) then
				if myHero.pos:DistanceTo(target.pos) <= 825 then					
					self:CastW(target)
					
				end
			end
		end	
	end	
end

function Irelia:LastHit()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then
			if self.Menu.ClearSet.LastHit.UseItem:Value() then
				self:UseHydraminion(minion)
			end	
            
			if self.Menu.ClearSet.LastHit.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.LastHit.Mana:Value() / 100 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg(minion)
				local hp = CheckHPPred(minion)

				if QDmg > minion.health and hp > 0 and not IsUnderTurret(minion) then	
					ControlCastSpell(HK_Q, minion)
				end	

				if QDmg > minion.health and hp > 0 and IsUnderTurret(minion) and AllyMinionUnderTower() then
					ControlCastSpell(HK_Q, minion)

				end	
            end
		end
	end
end	

function Irelia:AutoQ()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i) 

		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then
			if self.Menu.ClearSet.AutoQ.UseItem:Value() then
				self:UseHydraminion(minion)
			end	
            
			if self.Menu.ClearSet.AutoQ.Q:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.AutoQ.Mana:Value() / 100 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg(minion) 
			local hp = CheckHPPred(minion)

				if QDmg > minion.health and hp > 0 and not IsUnderTurret(minion) then	
					ControlCastSpell(HK_Q, minion)
				end	

				if QDmg > minion.health and hp > 0 and IsUnderTurret(minion) and AllyMinionUnderTower() then
					ControlCastSpell(HK_Q, minion)

				end	
            end
		end
	end
end

function Irelia:StackPassive(target)
if GotBuff(myHero, "ireliapassivestacksmax") == 1 then return end	
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then
			if target.pos:DistanceTo(minion.pos) <= 400 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg(minion) 
			local hp = CheckHPPred(minion)
				if QDmg > minion.health and hp > 0 then
					ControlCastSpell(HK_Q, minion)

				end
			end
			self:UseHydraminion(minion)
		end
	end
end	

function Irelia:JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_JUNGLE and IsValid(minion) then
 			
			if myHero.pos:DistanceTo(minion.pos) <= 825 and self.Menu.ClearSet.JClear.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 then
				ControlCastSpell(HK_W, minion.pos)
                    
            end           
           
			if self.Menu.ClearSet.JClear.UseItem:Value() then
				self:UseHydraminion(minion)
			end				
			
			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.ClearSet.JClear.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero) + self:CalcExtraDmg(minion) 
			local hp = CheckHPPred(minion)
				if QDmg > minion.health and hp > 0 then
					ControlCastSpell(HK_Q, minion)
				end				
			end
        end
    end
end
			
function Irelia:Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if myHero.pos:DistanceTo(minion.pos) <= 825 and self.Menu.ClearSet.Clear.UseW:Value() and Ready(_W) and not Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
				ControlCastSpell(HK_W, minion.pos)
                    
            end 

           
			if self.Menu.ClearSet.AutoQ.Q:Value() then return end
			if self.Menu.ClearSet.Clear.UseItem:Value() then
				self:UseHydraminion(minion)
			end				
			
			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.ClearSet.Clear.Last.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg(minion) 
			local hp = CheckHPPred(minion)

				if QDmg > minion.health and hp > 0 and not IsUnderTurret(minion) then	
					ControlCastSpell(HK_Q, minion)
				end	

				if QDmg > minion.health and hp > 0 and IsUnderTurret(minion) and AllyMinionUnderTower() then
					ControlCastSpell(HK_Q, minion)

				end				
			end
        end
    end
end

function Irelia:KillSteal()
	local target = GetTarget(1100)     	
	if target == nil then return end
	if EBuff() then return end
	
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and self.Menu.ks.UseQ:Value() then
			local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg(target)	
			local hp = CheckHPPred(target) 
			if hp > 0 and QDmg > target.health then
				ControlCastSpell(HK_Q, target)
				DelayAction(function()
				self:CastQMinion(target)
				end,0.5)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 825 and Ready(_W) and self.Menu.ks.UseW:Value() then
			local WDmg = getdmg("W", target, myHero)
			local hp = target.health
			if WDmg >= hp then
				self:CastW(target)
			end
		end	
		if myHero.pos:DistanceTo(target.pos) <= 850 and Ready(_R) and self.Menu.ks.UseR:Value() then
			local RDmg = getdmg("R", target, myHero)
			local hp = target.health
			if RDmg >= hp then
				self:CastR(target)
			end
		end
	end
end	

function Irelia:CastQMinion(target)
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then
			local Dmg = getdmg("Q", target, myHero) or getdmg("W", target, myHero) or getdmg("E", target, myHero) or getdmg("R", target, myHero)
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg(minion) 
			local hp = CheckHPPred(minion)
			if myHero.pos:DistanceTo(minion.pos) > myHero.pos:DistanceTo(target.pos) and not IsUnderTurret(minion) and target.health > Dmg and QDmg > minion.health and hp > 0 then
				ControlCastSpell(HK_Q, minion)
				
			end
		end
	end
end	

function Irelia:Gapclose(target)
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if  GetDistanceSqr(minion.pos, myHero.pos) <= 600*600 and Ready(_Q) and minion.team == TEAM_ENEMY and IsValid(minion) then
			if GetDistanceSqr(target.pos, myHero.pos) > GetDistanceSqr(minion.pos, target.pos) and GetDistanceSqr(target.pos, minion.pos) <= 600*600 then
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg(minion) 
			local hp = CheckHPPred(minion)
				if QDmg > minion.health and hp > 0 then
					ControlCastSpell(HK_Q, minion)
				end		
			end
		end
	end	
end		

function Irelia:CastW(unit)
	if unit.pos:DistanceTo(myHero.pos) < 825 then
	local DefBuff = GetBuffData(myHero, "ireliawdefense")
		
		if HasBuff(myHero, "ireliawdefense") and DefBuff.duration > 0 then
			if self.Menu.MiscSet.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(unit, WData, myHero)
				if pred.Hitchance >= self.Menu.MiscSet.Pred.PredW:Value()+1 and DefBuff.duration < 0.75 then
					CastSpell(HK_W, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
				if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredW:Value(), pred.HitChance) and DefBuff.duration < 0.75 then
					CastSpell(HK_W, pred.CastPos)
				end	
			end			
		
		else		
		
			if unit.pos:DistanceTo(myHero.pos) > 300 then
				ControlKeyDown(HK_W) 
			end	
		end		       
    end
end

function Irelia:Flee()
    local target = GetTarget(1100)     	
	if target == nil then return end
	if self.Menu.MiscSet.Flee.Q:Value() then
		if target.pos:DistanceTo(myHero.pos) < 1000 then
			if Ready(_Q) then
				for i = 1, GameMinionCount() do
				local minion = GameMinion(i)
					if minion.pos:DistanceTo(myHero.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then
					local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg(minion) 
					local hp = CheckHPPred(minion)
						if target.pos:DistanceTo(myHero.pos) < minion.pos:DistanceTo(target.pos) and QDmg > minion.health and hp > 0 then
							ControlCastSpell(HK_Q, minion)
						end
					end	
                end
            end
            
		end
	end
end

function Irelia:CastE2(unit)			
	if self.Menu.ComboSet.Combo.UseEL:Value() == 1 then
		local startPos, endPos, count = GetBestECastPositions(Enemies)
		if startPos and endPos and count >= 2 then
			if Ready(_E) then 
				local cast1, cast2 = LineCircleIntersection(startPos, endPos, myHero.pos, 775)
				if cast1 and cast2 then
					if myHero:GetSpellData(_E).name == "IreliaE" then
						CastSpell(HK_E, cast1)
					end	
					if myHero:GetSpellData(_E).name == "IreliaE2" and HasBuff(myHero, "IreliaE") then 
						CastSpell(HK_E, cast2)
					end
				end	
			end
		else
			self:CastE(unit)
		end
	else
		self:CastE(unit)
	end	
end	

function Irelia:CastE(unit)

    if Ready(_E) and myHero:GetSpellData(_E).name == "IreliaE" and not HasBuff(unit, "ireliamark") then
		CastSpell(HK_E, myHero.pos)
    end
	
    if myHero:GetSpellData(_E).name == "IreliaE2" and HasBuff(myHero, "IreliaE") then
        local aimpos = GetPred(unit,MathHuge,0.25+ Latency()/1000)
		if aimpos then
		Epos = aimpos + (myHero.pos - aimpos): Normalized() * -150
			CastSpell(HK_E, Epos)
		end
	end
end

function Irelia:CastR(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, RData, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredR:Value()+1 then
			ControlCastSpell(HK_R, pred.CastPosition)
		end
	else
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
			ControlCastSpell(HK_R, pred.CastPos)
		end	
	end
end	

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

-- [ AutoUpdate ]
do
    
    local Version = 0.27
    
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
_G.LATENCY = 0.05


local DangerousSpells = {
	["CaitlynAceintheHole"] = {charName = "Caitlyn", slot = _R, type = "targeted", displayName = "Ace in the Hole", range = 3500},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = _E, type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},	
	["DravenR"] = {charName = "Draven", displayName = "Whirling Death", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 0.25, radius = 160, collision = false},	
	["JinxR"] = {charName = "Jinx", displayName = "Death Rocket", slot = _R, type = "linear", speed = 1700, range = 12500, delay = 0.6, radius = 140, collision = false},
	["JayceShockBlast"] = {charName = "Jayce", displayName = "ShockBlast", slot = _Q, type = "linear", speed = 2350, range = 1300, delay = 0.25, radius = 70, collision = true},
	["BlindMonkRKick"] = {charName = "LeeSin", slot = _R, type = "targeted", displayName = "Dragon's Rage", range = 375},	
	["UrgotR"] = {charName = "Urgot", displayName = "Fear Beyond Death", slot = _R, type = "linear", speed = 3200, range = 1600, delay = 0.4, radius = 80, collision = false},

}

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
	return Enemies
end

local function GetEnemyTurrets()
	return Turrets
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
	for i = 1,GameMinionCount() do
	local hero = GameMinion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
			count = count + 1
		end
	end
	return count
end

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurrets()) do
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

local function HasBuff(unit, buffName)
    local buffCount = unit.buffCount
    if buffCount == nil or buffCount < 0 or buffCount > 100000 then
        print("buff api error: buffCount = "..buffCount)
    	return nil
	end

    for i = 0, buffCount do
		local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == buffName then 
            return true
		end
	end
	return false
end

local function GetBuffData(unit, buffname)
    local buffCount = unit.buffCount
    if buffCount == nil or buffCount < 0 or buffCount > 100000 then
        print("buff api error: buffCount = "..buffCount)
    	return nil
	end
	
	for i = 0, buffCount do
		local buff = unit:GetBuff(i)
		if buff and buff.name == buffname and buff.count > 0 then 
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
    local buffCount = unit.buffCount
    if buffCount == nil or buffCount < 0 or buffCount > 100000 then
        print("buff api error: buffCount = "..buffCount)
    	return nil
	end
	
	for i = 0, buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
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

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
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

local function CheckHPPred(unit)
local speed = 1500+myHero.ms
local range = myHero.pos:DistanceTo(unit.pos)
local time = range / speed
	if _G.SDK and _G.SDK.Orbwalker then
		return _G.SDK.HealthPrediction:GetPrediction(unit, time)
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetHealthPrediction(unit, time)
	end
end

local function CastSpell(spell, pos, delay)
	local delay = delay or 0.25
	local ticker = GetTickCount()

	if castSpell.state == 0 and ticker - castSpell.casting > delay + Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Latency() then
			SetMovement(false)
			SetAttack(false)
			ControlSetCursorPos(pos)
			ControlKeyDown(spell)
			ControlKeyUp(spell)
			SetMovement(true)
			SetAttack(true)
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
	   Mode == "Flee" or 
	   Mode == "LastHit" then
	   return true
	end
	return false
end

----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Irelia"


local RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 80, Range = 950, Speed = 2000, Collision = false}
local RspellData = {speed = 2000, range = 950, delay = 0.25 + ping, radius = 80, collision = {nil}, type = "linear"}
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

function Irelia:LoadMenu()                     	
--MainMenu
self.Menu = MenuElement({type = MENU, id = "Irelia", name = "PussyIrelia"})
self.Menu:MenuElement({name = " ", drop = {"Version 0.27"}})

self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})
	
	--ComboMenu  
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	self.Menu.ComboSet.Combo:MenuElement({name = " ", drop = {"E1, W, R, Q, E2, Q + (Q when kill / almost kill)"}})
	self.Menu.ComboSet.Combo:MenuElement({id = "LogicQ", name = "Last[Q]Almost Kill or Kill", key = 0x61, value = false, toggle = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "UseW", name = "[W]", value = false})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "UseR", name = "[R]Single Target if almost killable", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseRCount", name = "Auto[R] Multiple Enemys", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "RCount", name = "Multiple Enemys", value = 2, min = 2, max = 5, step = 1})
	self.Menu.ComboSet.Combo:MenuElement({id = "Gap", name = "Gapclose [Q]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "Stack", name = "Stack Passive near Target/Minion", value = true})		
	
	--BurstModeMenu
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Burst", name = "Burst Mode"})	
	self.Menu.ComboSet.Burst:MenuElement({name = " ", drop = {"If Burst Active then Combo Mode is Inactive"}})	
	self.Menu.ComboSet.Burst:MenuElement({id = "StartB", name = "Use Burst Mode", key = 0x62, value = true, toggle = true})
	self.Menu.ComboSet.Burst:MenuElement({id = "Lvl", name = "Irelia Level to Start Burst", value = 6, min = 6, max = 18, step = 1})	


	self.Menu.ComboSet:MenuElement({type = MENU, id = "Ninja", name = "Ninja Mode"})
	self.Menu.ComboSet.Ninja:MenuElement({id = "UseQ", name = "Q on all Marked Enemys", key = 0x63, value = true, toggle = true})

self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	self.Menu.ClearSet.Clear.Last:MenuElement({name = " ", drop = {"Is only active, if AutoQ Off)"}})	
	self.Menu.ClearSet.Clear.Last:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "UseW", name = "[W]", value = false})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseE", name = "[E] in Line", value = false})	
	self.Menu.ClearSet.Clear:MenuElement({id = "countEnemy", name = "[E] only if no Enemy near", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "ECount", name = "min Minions for [E]", value = 4, min = 1, max = 7, step = 1})	
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
	self.Menu.ClearSet.AutoQ:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = false})	
	self.Menu.ClearSet.AutoQ:MenuElement({id = "UseQ", name = "Auto Q Toggle Key", key = 0x64, value = false, toggle = true})
	self.Menu.ClearSet.AutoQ:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})		


	--HarassMenu
self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})	
	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"Marked Target + back killable Minion", "Only Marked Target"}})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = false})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})


	--KillSteal
self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal Settings"})
	
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.ks:MenuElement({id = "UseW", name = "[W]", value = false})	
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]", value = false})		

	
self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})

	self.Menu.MiscSet:MenuElement({type = MENU, id = "Rrange", name = "Ultimate Range setting"})
	self.Menu.MiscSet.Rrange:MenuElement({id = "R", name = "Max Cast range [R]", value = 850, min = 0, max = 950, step = 10})		

	--Flee
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Flee", name = "Flee Mode"})
	self.Menu.MiscSet.Flee:MenuElement({id = "Q", name = "Flee[Q]", value = true})	

	--AutoE 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "AutoECount", name = "AutoE Mode"})
	self.Menu.MiscSet.AutoECount:MenuElement({id = "UseE", name = "Auto E 2 - 5 Enemies", key = 0x65, value = true, toggle = true})	
	
	--AutoW Dangerous Spells
	self.Menu.MiscSet:MenuElement({id = "WSet", name = "AutoW Mode [Test]", type = MENU})
	self.Menu.MiscSet.WSet:MenuElement({name = " ", drop = {"Supported Spells"}})
	self.Menu.MiscSet.WSet:MenuElement({name = " ", drop = {"[DravenR,JinxR,JayceQ,LeeSinR,CaitlynR,UrgotR]"}})	
	self.Menu.MiscSet.WSet:MenuElement({id = "UseW", name = "Auto W Dangerous Spells", key = 0x66, value = false, toggle = true})
	self.Menu.MiscSet.WSet:MenuElement({id = "BlockList", name = "Block List", type = MENU})	
	self.Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()	
		for i, spell in pairs(DangerousSpells) do
			if not DangerousSpells[i] then return end
			for j, k in ipairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not self.Menu.MiscSet.WSet.BlockList[i] then
					if not self.Menu.MiscSet.WSet.BlockList[i] then self.Menu.MiscSet.WSet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..self.Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)		
			
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
	self.Menu.MiscSet.Drawing:MenuElement({type = MENU, id = "XY", name = "Info Box Settings"})
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "OnOff", name = "Draw Status Box", key = 0x67, value = true, toggle = true})
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "Key", name = "Draw HotKey Info", value = true})	
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "Hide", name = "Hide Info Box if active Mode", value = true})	
	self.Menu.MiscSet.Drawing.XY:MenuElement({id = "T", name = "Status Box transparency", value = 120, min = 0, max = 223, step = 10})	
	
end	

function Irelia:Tick()
	self:CheckInfoBox()	
	if Control.IsKeyDown(0x69) then
		self.ButtonDown = false
		UnLockBox = true
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
		elseif Mode == "Flee" then
			self:Flee()
		elseif Mode == "LastHit" then
				if self.Menu.ClearSet.LastHit.Active:Value() then
				self:LastHit()	
			end
		end
	
	self:KillSteal()
	self:CastE2()

	if self.Menu.ClearSet.AutoQ.UseQ:Value() and Mode ~= "Combo" then
		self:AutoQ()
	end	

	if self.Menu.MiscSet.WSet.UseW:Value() and Ready(_W) then
		self:OnProcessSpell()
		for i, spell in pairs(self.DetectedSpells) do
			self:UseW(i, spell)
		end
	end
	
	local target = GetTarget(1100)     	
	if target == nil then return end
	if Mode == "Combo" and IsValid(target) and self.Menu.ComboSet.Burst.StartB:Value() and myHero.levelData.lvl >= self.Menu.ComboSet.Burst.Lvl:Value() then
	
		if myHero.pos:DistanceTo(target.pos) <= 775 and myHero:GetSpellData(_E).toggleState == 0 and not ISMarked(1000) then
			local aimpos = GetPred(target,math.huge,0.25+ Game.Latency()/1000)
			if aimpos and not (myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "IreliaR") then
			Epos = aimpos + (myHero.pos - aimpos): Normalized() * -150
				SetMovement(false)
				Control.CastSpell(HK_E, Epos)
				SetMovement(true)
			end	
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 600 and myHero:GetSpellData(_E).toggleState == 1 and Ready(_E) and not ISMarked(1000) then
			Control.CastSpell(HK_E, myHero.pos)
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and HasBuff(target, "ireliamark") then
			if CheckHPPred(target) >= 1 and IsValid(target) then
				CastSpell(HK_Q, target.pos)	
			end	
		end		

		if self.Menu.ComboSet.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 400 and Ready(_W) and not Ready(_E) then					
			Control.CastSpell(HK_W, target)
		end
		
		if myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and Ready(_R) and Ready(_Q) then
			local count = GetEnemyCount(1500, myHero)
			local AADmg = getdmg("AA", target, myHero) + self:CalcExtraDmg()
			local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()
			local RDmg = getdmg("R", target, myHero)
			local FullDmg = ((QDmg * 3) + RDmg + (AADmg * 4))
			if FullDmg > target.health and count == 1 then
				self:CastR(target)
			end	
		end
		
		local count = GetEnemyCount(400, target)
		if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and self.Menu.ComboSet.Combo.UseRCount:Value() then
			if count >= self.Menu.ComboSet.Combo.RCount:Value() and not myHero:GetSpellData(_E).toggleState == 0 then					
				self:CastR(target)
			end
		end		

		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and not self.Menu.ks.UseQ:Value() then			 
			local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()	 		
			if (QDmg >= target.health and CheckHPPred(target) >= 1) and IsValid(target) then
				CastSpell(HK_Q, target.pos)	
			end
		end	
		
		if myHero.pos:DistanceTo(target.pos) > 600 and myHero.pos:DistanceTo(target.pos) < 775 and Ready(_Q) and Ready(_E) then
			local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()			
			if QDmg >= target.health and not HasBuff(target, "ireliamark") then				
				if myHero:GetSpellData(_E).toggleState == 1 then
					Control.CastSpell(HK_E, myHero.pos)
				end
			end
			if myHero.pos:DistanceTo(target.pos) <= 775 and myHero:GetSpellData(_E).toggleState == 0 then
				local aimpos = GetPred(target,math.huge,0.25+ Game.Latency()/1000)
				if aimpos and not ISMarked(1000) and not (myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "IreliaR") then
				Epos = aimpos + (myHero.pos - aimpos): Normalized() * -150
					SetMovement(false)
					Control.CastSpell(HK_E, Epos)
					SetMovement(true)
				end	
			end
		end
		self:Gapclose(target)
		self:UseHydraminion(target)
		if myHero:GetSpellData(_E).name == "IreliaE2" then return end
		self:StackPassive(target)	
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
					if MarkBuff2.duration > time2 then
						CastSpell(HK_Q, target2.pos)
					end
				end
				if (not HasBuff(target2, "ireliamark") or myHero.pos:DistanceTo(target2.pos) > 600) and HasBuff(target1, "ireliamark") and myHero.pos:DistanceTo(target1.pos) <= 600 and IsValid(target1) then
					local time1 = myHero.pos:DistanceTo(target1.pos) / (1500+myHero.ms)
					local MarkBuff1 = GetBuffData(target1, "ireliamark")
					if MarkBuff1.duration > time1 then
						CastSpell(HK_Q, target1.pos)
					end
				end	
			end
		end	
	end	
end

function Irelia:CalcExtraDmg()
	local total = 0
	
	local Trinity = GetInventorySlotItem(3078)
	local Sheen = GetInventorySlotItem(1027)	
	local hydra = CheckTitan(3748)	
	local Passive = HasBuff(myHero, "ireliapassivestacksmax")
	local TrinDmg = 2 * (myHero.totalDamage - myHero.bonusDamage)
	local PassiveDmg = (12 + 3 * myHero.levelData.lvl) + (0.25 * myHero.bonusDamage)	
	local SheenDmg = myHero.totalDamage - myHero.bonusDamage
	local hydraDmg = 5 + 0.01 * myHero.maxHealth
	
	if Trinity then
		total = total + TrinDmg
	else
		total = total + 0
	end	

	if Sheen then
		total = total + SheenDmg
	else
		total = total + 0
	end	

	if hydra then
		total = total + hydraDmg
	else
		total = total + 0
	end	

	if Passive then
		total = total + PassiveDmg
	else
		total = total + 0
	end		
	return total		
end

function Irelia:UseW(i, s)
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
			if t < 0.3 and not charging then 
				Control.KeyDown(HK_W)
				charging = true
			
			else
				Control.KeyUp(HK_W)
				charging = false
				
			end
		end
	else table.remove(self.DetectedSpells, i) end
end

function Irelia:OnProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and spell and DangerousSpells[spell.name] then
		if GetDistance(unit.pos, myHero.pos) > 3500 or not self.Menu.MiscSet.WSet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = DangerousSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle and not charging then 
				Control.KeyDown(HK_W)
				charging = true
				table.remove(self.DetectedSpells, i)
			else
				Control.KeyUp(HK_W)
				charging = false
				
			end
		else
			local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
			local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
			local endPos, range2 = CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
			table.insert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = GameTimer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col})
		end
	end
end

function Irelia:UseHydraminion(unit)
local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
	if hydraitem and myHero.pos:DistanceTo(unit.pos) <= 400 then
		Control.CastSpell(keybindings[hydraitem])
	end
end

function Irelia:Combo()
local target = GetTarget(1100)     	
if target == nil then return end
	if IsValid(target) then
		if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and self.Menu.ComboSet.Combo.UseRCount:Value() then
			local count = GetEnemyCount(400, target)
			if count >= self.Menu.ComboSet.Combo.RCount:Value() then					
				self:CastR(target)
			end
		end			
		
		if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				self:CastE(target)
			end
		end	
			
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and HasBuff(target, "ireliamark") then
			CastSpell(HK_Q, target.pos)			
		end
		
		if self.Menu.ComboSet.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				Control.CastSpell(HK_W, target)
			end
		end	
		
		if self.Menu.ComboSet.Combo.UseR:Value() and Ready(_R) then
			local count = GetEnemyCount(1500, myHero)
			if myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and count == 1 then	
			local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()
			local RDmg = getdmg("R", target, myHero)			
				if (QDmg * 2 + RDmg) > target.health then
					self:CastR(target)
				end	
			end
		end			
		
		if self.Menu.ComboSet.Combo.LogicQ:Value() then 				 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()
				if (QDmg >= target.health and CheckHPPred(target) >= 1) and IsValid(target) then
					CastSpell(HK_Q, target.pos)		
				end
			end			
			
			if myHero.pos:DistanceTo(target.pos) >= 300 and myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()
				if (QDmg*2) >= target.health then
					CastSpell(HK_Q, target.pos)	
				end	
			end		
		
		else
				
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()
				if (QDmg >= target.health and CheckHPPred(target) >= 1) and IsValid(target) then
					CastSpell(HK_Q, target.pos)		
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
				
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
			if self.Menu.Harass.UseQ:Value() ~= 2 then
				if HasBuff(target, "ireliamark") then
					CastSpell(HK_Q, target.pos)	
				end
				if myHero:GetSpellData(_E).name ~= "IreliaE2" and not HasBuff(target, "ireliamark") then
					self:CastQMinion(target)
				end	
			else	
				CastSpell(HK_Q, target.pos)	
			end	
		end
		
		if self.Menu.Harass.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				self:CastW(target)				
			end
		end	
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				self:CastE(target)				
			end
		end	
	end	
end

function Irelia:KillSteal()
	for i, target in ipairs(GetEnemyHeroes()) do     	
		
		if target and myHero.pos:DistanceTo(target.pos) <= 1000 and IsValid(target) and myHero:GetSpellData(_E).name ~= "IreliaE2" then
		
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and self.Menu.ks.UseQ:Value() then
				local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()	 
				if HasBuff(target, "ireliamark") and (QDmg*2) >= target.health then
					CastSpell(HK_Q, target.pos)	
				end	
				if (QDmg >= target.health and CheckHPPred(target) >= 1) and IsValid(target) then
					CastSpell(HK_Q, target.pos)	
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
			
			if myHero.pos:DistanceTo(target.pos) <= self.Menu.MiscSet.Rrange.R:Value() and myHero.pos:DistanceTo(target.pos) > 300 and Ready(_R) and self.Menu.ks.UseR:Value() then
				local EDmg = getdmg("E", target, myHero)
				local WDmg = getdmg("W", target, myHero)
				local RDmg = getdmg("R", target, myHero)
				local QDmg = getdmg("Q", target, myHero) + self:CalcExtraDmg()
				local FullDmg = RDmg + WDmg + EDmg + (QDmg*2)
				local hp = target.health
				if FullDmg >= hp and not HasBuff(target, "ireliamark") then
					self:CastR(target)
				end
			end
		end
	end	
end	

function Irelia:LastHit()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if self.Menu.ClearSet.LastHit.UseItem:Value() then
				self:UseHydraminion(minion)
			end	
            
			if self.Menu.ClearSet.LastHit.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.LastHit.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg() 

				if not IsUnderTurret(minion) then	
					if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
						CastSpell(HK_Q, minion.pos)						
					end	
				else  
					if AllyMinionUnderTower() then
						if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then					
							CastSpell(HK_Q, minion.pos)
						end
					end	
				end	
            end
		end
	end
end	

function Irelia:AutoQ()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i) 

		if minion.team == TEAM_ENEMY then
			if self.Menu.ClearSet.AutoQ.UseItem:Value() then
				self:UseHydraminion(minion)
			end	

			if myHero.mana/myHero.maxMana >= self.Menu.ClearSet.AutoQ.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg() 
				
				if not IsUnderTurret(minion) then	
					if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
						CastSpell(HK_Q, minion.pos)						
					end	
				else  
					if AllyMinionUnderTower() then
						if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then					
							CastSpell(HK_Q, minion.pos)
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
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg() 
				if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
					CastSpell(HK_Q, minion.pos)
				end	
			end
			self:UseHydraminion(minion)
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
           
			if self.Menu.ClearSet.JClear.UseItem:Value() then
				self:UseHydraminion(minion)
			end				
			
			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.ClearSet.JClear.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero) + self:CalcExtraDmg() 
				if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
					CastSpell(HK_Q, minion.pos)
				end	
			end	
        end
    end
end
			
function Irelia:Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if myHero.pos:DistanceTo(minion.pos) <= 825 and self.Menu.ClearSet.Clear.UseW:Value() and Ready(_W) and not Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
				Control.CastSpell(HK_W, minion.pos)                   
            end 
			

			if self.Menu.ClearSet.Clear.UseE:Value() and Ready(_E) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
				if self.Menu.ClearSet.Clear.countEnemy:Value() then
					if GetEnemyCount(2000, myHero) == 0 then 				
						local Count = GetLineTargetCount(myHero.pos, minion.pos, 0.25+ Game.Latency()/1000, math.huge, 100)
						if Count >= self.Menu.ClearSet.Clear.ECount:Value() then
							if myHero:GetSpellData(_E).name == "IreliaE" then
								Control.CastSpell(HK_E, myHero.pos)
							end
							if myHero:GetSpellData(_E).name == "IreliaE2" then
								local Epos = minion.pos + (myHero.pos - minion.pos): Normalized() * -150
								SetMovement(false)
								Control.CastSpell(HK_E, Epos)
								SetMovement(true)
							end					
						end
					end	
				else
					local Count = GetLineTargetCount(myHero.pos, minion.pos, 0.25+ Game.Latency()/1000, math.huge, 100)
					if Count >= self.Menu.ClearSet.Clear.ECount:Value() then
						if myHero:GetSpellData(_E).name == "IreliaE" then
							Control.CastSpell(HK_E, myHero.pos)
						end
						if myHero:GetSpellData(_E).name == "IreliaE2" then
							local Epos = minion.pos + (myHero.pos - minion.pos): Normalized() * -150
							SetMovement(false)
							Control.CastSpell(HK_E, Epos)
							SetMovement(true)
						end					
					end					
				end
			end
           
			if self.Menu.ClearSet.AutoQ.UseQ:Value() then return end
			if self.Menu.ClearSet.Clear.UseItem:Value() then
				self:UseHydraminion(minion)
			end				
			
			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.ClearSet.Clear.Last.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg() 
				if not IsUnderTurret(minion) then	
					if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
						CastSpell(HK_Q, minion.pos)
					end	
				end	

				if IsUnderTurret(minion) and AllyMinionUnderTower() then
					if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then					
						CastSpell(HK_Q, minion.pos)
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
			local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg() 
				if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) and not HasBuff(target, "ireliamark") then
					CastSpell(HK_Q, minion.pos)
				end					
			end
		end
	end
end	

function Irelia:Gapclose(target)
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if Ready(_Q) and minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 600 and IsValid(minion) then
			if myHero.pos:DistanceTo(target.pos) > 600 and HasBuff(target, "ireliamark") then
				local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg()
				if QDmg >= minion.health and myHero.pos:DistanceTo(target.pos) > target.pos:DistanceTo(minion.pos) and target.pos:DistanceTo(minion.pos) <= 600 then 
					if CheckHPPred(minion) >= 1 and IsValidCrap(minion) then
						CastSpell(HK_Q, minion.pos)
					end					
				end
			else
				if myHero.pos:DistanceTo(target.pos) < 600 and not HasBuff(target, "ireliamark") then
					local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg()
					if QDmg >= minion.health and myHero.pos:DistanceTo(target.pos) > target.pos:DistanceTo(minion.pos) and target.pos:DistanceTo(minion.pos) <= 600 then 
						if CheckHPPred(minion) >= 1 and IsValidCrap(minion) then
							CastSpell(HK_Q, minion.pos)
						end					
					end				
				end
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
					if minion.team == TEAM_ENEMY and IsValid(minion) then
						if minion.pos:DistanceTo(myHero.pos) <= 600 and target.pos:DistanceTo(myHero.pos) < minion.pos:DistanceTo(target.pos) then
						local QDmg = getdmg("Q", minion, myHero, 2) + self:CalcExtraDmg() 
							if (QDmg >= minion.health and CheckHPPred(minion) >= 1) and IsValidCrap(minion) then
								CastSpell(HK_Q, minion.pos)
							end	
						end
					end	
                end
            end           
		end
	end
end

function Irelia:CastW(target)
    if target and GetDistanceSqr(target.pos, myHero.pos) < 825 * 825 then
	local aim = GetPred(target,1400,0.6)
   
		if not charging and not HasBuff(myHero, "ireliawdefense") then
            Control.KeyDown(HK_W)
            wClock = clock()
            settime = clock()
            charging = true
        end
		
		if HasBuff(myHero, "ireliawdefense") and (target.pos:DistanceTo(myHero.pos) > 600) then
			Control.CastSpell(HK_W, aim)
			charging = false
		elseif HasBuff(myHero, "ireliawdefense") and clock() - wClock >= 0.5 and target.pos:DistanceTo(myHero.pos) < 825 then
			Control.CastSpell(HK_W, aim)
			charging = false
		end		
        
        
        
    end
    if clock() - wClock >= 1.5 then
    Control.KeyUp(HK_W)
    charging = false
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

function Irelia:GetBestECastPositions(units)   
	local startPos, endPos, count = nil, nil, 0
    local candidates, unitPositions = {}, {}
    for i, unit in ipairs(units) do
		if unit then
			local cp = GetPred(unit, 775, 0.25)
			if cp then candidates[i], unitPositions[i] = cp, cp end
		end	
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
        if unit2 and unit2.pos:DistanceTo(myHero.pos) < 875 then
			local cp = GetPred(unit2, 775, 0.25)
			if cp then
				for i, pos2 in ipairs(candidates) do
					if pos2 and pos2:DistanceTo(myHero.pos) < 875 then
						--local range = pos2:DistanceTo(cp)*2+150
						local ePos = Vector(cp):Extended(pos2, 775)
						local number = 0
						for i = 1, #unitPositions do
							local unitPos = unitPositions[i]
							if unitPos:DistanceTo(myHero.pos) < 875 and ePos:DistanceTo(myHero.pos) < 875 then
								local pointLine, pointSegment, onSegment = VectorPointProjectionOnLineSegment(cp, ePos, unitPos)
								if pointSegment and DistanceSquared(pointSegment, unitPos) < 8400 then number = number + 1 end 
							end	
						end
						if number >= count then startPos, endPos, count = cp, ePos, number end
					end	
				end
			end
		end	
    end
    return startPos, endPos, count
end

function Irelia:CastE2()
	if self.Menu.MiscSet.AutoECount.UseE:Value() and Ready(_E) then
		local startPos, endPos, count = self:GetBestECastPositions(Enemies)
		if count >= 2 and startPos and endPos then 
			local E1Pos, E2Pos = self:LineCircleIntersection(startPos, endPos, myHero.pos, 775)
			if myHero:GetSpellData(_E).toggleState == 1 then
				CastSpell(HK_E, E1Pos, 0.1)
			end	
			if myHero:GetSpellData(_E).toggleState == 0 then
				CastSpell(HK_E, E2Pos, 0.1)
			end
		end
	end	
end	

function Irelia:CastE(unit)

    if myHero:GetSpellData(_E).name == "IreliaE"  and not HasBuff(unit, "ireliamark") then
		Control.CastSpell(HK_E, myHero.pos)
    end
	
    if myHero:GetSpellData(_E).name == "IreliaE2" then
        local aimpos = GetPred(unit,math.huge,0.25+ Game.Latency()/1000)
		if aimpos then
		Epos = aimpos + (myHero.pos - aimpos): Normalized() * -150
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
	local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 80, Range = 950, Speed = 2000, Collision = false})
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

			if self:IsInStatusBox(cursorPos, 5) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 4", 15, self.Window.x + 10, self.Window.y + 65, yellow)
			else
				DrawText("Auto Q Minion:", 15, self.Window.x + 10, self.Window.y + 65, white)
				if self.Menu.ClearSet.AutoQ.UseQ:Value() then 
					Draw.Text("Active", 15, self.Window.x + 153, self.Window.y + 65, green)
				else
					Draw.Text("OFF", 15, self.Window.x + 153, self.Window.y + 65, red)
				end
			end	
			
			if self:IsInStatusBox(cursorPos, 6) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 5", 15, self.Window.x + 10, self.Window.y + 85, yellow)
			else		
				DrawText("Auto E 2-5 Enemies:", 15, self.Window.x + 10, self.Window.y + 85, white)
				if self.Menu.MiscSet.AutoECount.UseE:Value() then 
					Draw.Text("Active", 15, self.Window.x + 153, self.Window.y + 85, green)
				else
					Draw.Text("OFF", 15, self.Window.x + 153, self.Window.y + 85, red)
				end
			end	
			
			if self:IsInStatusBox(cursorPos, 7) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 6", 15, self.Window.x + 10, self.Window.y + 105, yellow)
			else		
				DrawText("Auto W Danger Spells:", 15, self.Window.x + 10, self.Window.y + 105, white)
				if self.Menu.MiscSet.WSet.UseW:Value() then 
					Draw.Text("Active", 15, self.Window.x + 153, self.Window.y + 105, green)
				else
					Draw.Text("OFF", 15, self.Window.x + 153, self.Window.y + 105, red)
				end
			end
		end
	else
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

			if self:IsInStatusBox(cursorPos, 5) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 4", 15, self.Window.x + 10, self.Window.y + 65, yellow)
			else
				DrawText("Auto Q Minion:", 15, self.Window.x + 10, self.Window.y + 65, white)
				if self.Menu.ClearSet.AutoQ.UseQ:Value() then 
					Draw.Text("Active", 15, self.Window.x + 153, self.Window.y + 65, green)
				else
					Draw.Text("OFF", 15, self.Window.x + 153, self.Window.y + 65, red)
				end
			end	
			
			if self:IsInStatusBox(cursorPos, 6) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 5", 15, self.Window.x + 10, self.Window.y + 85, yellow)
			else		
				DrawText("Auto E 2-5 Enemies:", 15, self.Window.x + 10, self.Window.y + 85, white)
				if self.Menu.MiscSet.AutoECount.UseE:Value() then 
					Draw.Text("Active", 15, self.Window.x + 153, self.Window.y + 85, green)
				else
					Draw.Text("OFF", 15, self.Window.x + 153, self.Window.y + 85, red)
				end
			end	
			
			if self:IsInStatusBox(cursorPos, 7) and ActiveMenu then
				DrawText("Standard Hotkey = NumPad 6", 15, self.Window.x + 10, self.Window.y + 105, yellow)
			else		
				DrawText("Auto W Danger Spells:", 15, self.Window.x + 10, self.Window.y + 105, white)
				if self.Menu.MiscSet.WSet.UseW:Value() then 
					Draw.Text("Active", 15, self.Window.x + 153, self.Window.y + 105, green)
				else
					Draw.Text("OFF", 15, self.Window.x + 153, self.Window.y + 105, red)
				end
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

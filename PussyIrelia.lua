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
    
require('GamsteronPrediction')


if not FileExist(COMMON_PATH .. "PussyDamageLib.lua") then
	print("PussyDamageLib. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/PussyDamageLib.lua", COMMON_PATH .. "PussyDamageLib.lua", function() end)
	while not FileExist(COMMON_PATH .. "PussyDamageLib.lua") do end
end
    
require('PussyDamageLib')


-- [ AutoUpdate ]
do
    
    local Version = 0.05
    
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
local ping = Latency() * 0.001
local _OnVision = {}
local sqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
local units = {}
local foundAUnit = false
local GameTimer = Game.Timer
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local Orb

local DangerousSpells = {
	["CaitlynAceintheHole"] = {charName = "Caitlyn", slot = _R, type = "targeted", displayName = "Ace in the Hole", range = 3500},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = _E, type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},	
	["DravenR"] = {charName = "Draven", displayName = "Whirling Death", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 0.25, radius = 160, collision = false},	
	["JinxR"] = {charName = "Jinx", displayName = "Death Rocket", slot = _R, type = "linear", speed = 1700, range = 12500, delay = 0.6, radius = 140, collision = false},
	["JayceShockBlast"] = {charName = "Jayce", displayName = "ShockBlast", slot = _Q, type = "linear", speed = 2350, range = 1300, delay = 0.25, radius = 70, collision = true},
	["BlindMonkRKick"] = {charName = "LeeSin", slot = _R, type = "targeted", displayName = "Dragon's Rage", range = 375},	
	["UrgotR"] = {charName = "Urgot", displayName = "Fear Beyond Death", slot = _R, type = "linear", speed = 3200, range = 1600, delay = 0.4, radius = 80, collision = false},

}

local isLoaded = false
function TryLoad()
	if Game.Timer() < 30 then return end
	isLoaded = true	
	LoadUnits()
	if table.contains(Heroes, myHero.charName) then
		_G[myHero.charName]()
	end	
end

function OnLoad()
	Start()
end

class "Start"

function Start:__init()
	
	charging = false
	Callback.Add("Draw", function() self:Draw() end)
end

function Start:Draw()
local textPos = myHero.dir	
	if not isLoaded then
		TryLoad()
		Draw.Text("Irelia Menu appear 30Sec Ingame", 30, textPos.x + 600, textPos.y + 100, Draw.Color(255, 255, 0, 0))
	return end

end

function LoadUnits()
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i); Units[i] = {unit = unit, spell = nil}
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

function EnemyHeroes()
	return Enemies
end

function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

local function GetTarget(range) 
	if Orb == 1 then
		if myHero.ap > myHero.totalDamage then
			return EOW:GetTarget(range, EOW.ap_dec, myHero.pos)
		else
			return EOW:GetTarget(range, EOW.ad_dec, myHero.pos)
		end
	elseif Orb == 2 and SDK.TargetSelector then
		if myHero.ap > myHero.totalDamage then
			return SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
		else
			return SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		end
	elseif _G.GOS then
		if myHero.ap > myHero.totalDamage then
			return GOS:GetTarget(range, "AP")
		else
			return GOS:GetTarget(range, "AD")
        end
    elseif _G.gsoSDK then
		return _G.gsoSDK.TS:GetTarget()
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
    end
end

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function IsUnderTurret(unit)
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local function AllyMinionUnderTower()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_ALLY and IsValid(minion) and IsUnderTurret(minion) and myHero.pos:DistanceTo(minion.pos) <= 750 then
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

local function IsRecalling(unit)
	for i = 1, 63 do
	local buff = unit:GetBuff(i) 
		if buff.count > 0 and buff.name == "recall" and Game.Timer() < buff.expireTime then
			return true
		end
	end 
	return false
end


function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function GetDistanceSqr(p1, p2)
	if not p1 then return math.huge end
	p2 = p2 or myHero
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
end

function GetDistance(p1, p2)
	p2 = p2 or myHero
	return math.sqrt(GetDistanceSqr(p1, p2))
end

local function CastSpell(spell,pos,range,delay)
    local range = range or math.huge
    local delay = delay or 250
    local ticker = GetTickCount()


    if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
        castSpell.state = 1
        castSpell.mouse = mousePos
        castSpell.tick = ticker
    end
    if castSpell.state == 1 then
        if ticker - castSpell.tick < Game.Latency() then
            Control.SetCursorPos(pos)
            Control.KeyDown(spell)
            Control.KeyUp(spell)
            castSpell.casting = ticker + delay
            DelayAction(function()
                if castSpell.state == 1 then
                    Control.SetCursorPos(castSpell.mouse)
                    castSpell.state = 0
                end
            end,Game.Latency()/1000)
        end
        if ticker - castSpell.casting > Game.Latency() then
            Control.SetCursorPos(castSpell.mouse)
            castSpell.state = 0
        end
    end
end

function DisableMovement(bool)

	if Orb == 2 then
		_G.SDK.Orbwalker:SetMovement(not bool)
	elseif Orb == 1 then
		EOW:SetMovements(not bool)
	elseif Orb == 3 then
		GOS.BlockMovement = bool
	end
end

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
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

function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

function OnVision(unit)
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
function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end

local function GetPred(unit,speed,delay)
	local speed = speed or math.huge
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

function CalculateCollisionTime(startPos, endPos, unitPos, startTime, speed, delay, origin)
	local pos = startPos:Extended(endPos, speed * (GameTimer() - delay - startTime))
	return GetDistance(unitPos, pos) / speed
end

function CalculateEndPos(startPos, placementPos, unitPos, range, radius, collision, type)
	local range = range or 3000; local endPos = startPos:Extended(placementPos, range)
	if type == "circular" or type == "rectangular" then
		if range > 0 then if GetDistance(unitPos, placementPos) < range then endPos = placementPos end
		else endPos = unitPos end
	elseif collision then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
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

function OnProcessSpell()
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

local function MyHeroReady()
    return myHero.dead == false and Game.IsChatOpen() == false and (ExtLibEvade == nil or ExtLibEvade.Evading == false) and IsRecalling(myHero) == false
end




----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Irelia"

local WData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.6 + ping, Radius = 100, Range = 825, Speed = 1400, Collision = false
}

local EData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.75 + ping, Radius = 50, Range = 775, Speed = 2000, Collision = false
}

local RData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 160, Range = 1000, Speed = 2000, Collision = false
}

function Irelia:__init()
	self.DetectedMissiles = {}; self.DetectedSpells = {}; self.Target = nil; self.Timer = 0 	
	self.stacks = 0
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
	end	
end

function Irelia:LoadMenu()                     
	
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Irelia", name = "PussyIrelia"})

	--Flee
	self.Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
	self.Menu.Flee:MenuElement({id = "Q", name = "Flee[Q]", value = true})	

	--AutoE 
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "2-5 Enemys stunable", value = true})	
	
	--AutoQ
	self.Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ LastHit"})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto LastHit Minion", value = true})
	self.Menu.AutoQ:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.AutoQ:MenuElement({id = "Q", name = "Auto Q Toggle Key", key = string.byte("T"), toggle = true})
	self.Menu.AutoQ:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	self.Menu.AutoQ:MenuElement({id = "Draw", name = "Draw On/Off Text", value = true})	

  	--AutoW Dangerous Spells
	self.Menu:MenuElement({id = "WSet", name = "AutoW [Test]", type = MENU})
	self.Menu.WSet:MenuElement({name = " ", drop = {"Supported Spells"}})
	self.Menu.WSet:MenuElement({name = " ", drop = {"[DravenR,JinxR,JayceQ,LeeSinR,CaitlynR,UrgotR]"}})	
	self.Menu.WSet:MenuElement({id = "UseW", name = "Auto[W] Dangerous Spells", value = true})
	self.Menu.WSet:MenuElement({id = "BlockList", name = "Block List", type = MENU})	
	self.Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()	
		for i, spell in pairs(DangerousSpells) do
			if not DangerousSpells[i] then return end
			for j, k in pairs(EnemyHeroes()) do
				if spell.charName == k.charName and not self.Menu.WSet.BlockList[i] then
					if not self.Menu.WSet.BlockList[i] then self.Menu.WSet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..self.Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)		
			
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({name = " ", drop = {"E1, W, R, Q, E2, Q + (Q when kill / almost kill)"}})
	self.Menu.Combo:MenuElement({id = "QLogic", name = "Last[Q]Almost Kill or Kill", key = string.byte("Z"), toggle = true})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R]Single Target", value = true})
	self.Menu.Combo:MenuElement({id = "UseRCount", name = "Auto[R] Multiple Enemys", value = true})	
	self.Menu.Combo:MenuElement({id = "RCount", name = "Multiple Enemys", value = 2, min = 2, max = 5, step = 1})
	self.Menu.Combo:MenuElement({id = "Gap", name = "Gapclose [Q]", value = true})
	self.Menu.Combo:MenuElement({id = "Stack", name = "Stack Passive near Target/Minion", value = true})	
	self.Menu.Combo:MenuElement({id = "Draw", name = "Draw QLogic Text", value = true})	
	
	--BurstModeMenu
	self.Menu:MenuElement({type = MENU, id = "Burst", name = "BurstMode"})	
	self.Menu.Burst:MenuElement({name = " ", drop = {"If Burst Active then Combo Inactive"}})	
	self.Menu.Burst:MenuElement({id = "Start", name = "Use Burst Mode", key = string.byte("U"), toggle = true})
	self.Menu.Burst:MenuElement({id = "Lvl", name = "Irelia Level to Start Burst", value = 6, min = 6, max = 18, step = 1})
	self.Menu.Burst:MenuElement({id = "Draw", name = "Draw Text", value = true})	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"Marked + Dash back Minion", "Everytime"}})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	self.Menu.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	self.Menu.Clear.Last:MenuElement({name = " ", drop = {"Is only active, if AutoQ Off)"}})	
	self.Menu.Clear.Last:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Clear:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear Menu
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.JClear:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})	
	
	--LastHitMode Menu
	self.Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHitMode"})
	self.Menu.LastHit:MenuElement({name = " ", drop = {"Is only active, if AutoQ Off)"}})	
	self.Menu.LastHit:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.LastHit:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.LastHit:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})	
	self.Menu.LastHit:MenuElement({id = "Active", name = "LastHit Key", key = string.byte("X")})	
	
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	self.Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Draw", name = "Draw [Kill him] Text", value = true})	

	
	
end	

function Irelia:Tick()
	
if MyHeroReady() then

local Mode = GetMode()
		if Mode == "Combo" then
			if self.Menu.Burst.Start:Value() and myHero.levelData.lvl <= self.Menu.Burst.Lvl:Value() then
				self:Combo()
			end
			if not self.Menu.Burst.Start:Value() then
				self:Combo()
			end	
		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:JungleClear()
			self:Clear()
		elseif Mode == "Flee" then
			self:Flee()
		elseif Mode == "LastHit" then
				if self.Menu.LastHit.Active:Value() then
				self:LastHit()	
			end
		end
	if self.Menu.WSet.UseW:Value() and Ready(_W) then
		self:OnProcessSpell()
		for i, spell in pairs(self.DetectedSpells) do
			self:UseW(i, spell)
		end
	end
		
	self:KillSteal()
	self:CastE2()
	if self.Menu.AutoQ.Q:Value() and Mode ~= "Combo" then
		self:AutoQ()
	end	
	
	local target = GetTarget(1100)     	
	if target == nil then return end	
	if Mode == "Combo" and IsValid(target) and self.Menu.Burst.Start:Value() and myHero.levelData.lvl >= self.Menu.Burst.Lvl:Value() then
	local QDmg = getdmg("Q", target, myHero)	
		if myHero.pos:DistanceTo(target.pos) <= 775 and myHero:GetSpellData(_E).name == "IreliaE2" then
			local aimpos = GetPred(target,math.huge,0.25+ Game.Latency()/1000)
			if aimpos then
			Epos = aimpos + (myHero.pos - aimpos): Normalized() * -150
				DisableMovement(true)
				Control.CastSpell(HK_E, Epos)
				DisableMovement(false)
			end	
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 600 and myHero:GetSpellData(_E).name == "IreliaE" and Ready(_E) then
			Control.CastSpell(HK_E, myHero.pos)
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) and GotBuff(target, "ireliamark") == 1 then
			Control.CastSpell(HK_Q, target.pos)
		end		

		if myHero.pos:DistanceTo(target.pos) <= 400 and Ready(_W) and not Ready(_E) then					
				Control.CastSpell(HK_W, target)
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_R) and not Ready(_W) and Ready(_Q) and QDmg < target.health then
			self:CastR(target)
		end	

		if myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
			 
			if QDmg >= target.health then
				Control.CastSpell(HK_Q, target.pos)	
			end
		end	
		
		if QDmg >= target.health then
			if myHero.pos:DistanceTo(target.pos) > 600 and myHero.pos:DistanceTo(target.pos) < 775 then
				if myHero:GetSpellData(_E).name == "IreliaE" and Ready(_Q) and Ready(_E) then
					Control.CastSpell(HK_E, myHero.pos)
				end
			end
			if myHero.pos:DistanceTo(target.pos) <= 775 and myHero:GetSpellData(_E).name == "IreliaE2" then
				local aimpos = GetPred(target,math.huge,0.25+ Game.Latency()/1000)
				if aimpos then
				Epos = aimpos + (myHero.pos - aimpos): Normalized() * -150
					DisableMovement(true)
					Control.CastSpell(HK_E, Epos)
					DisableMovement(false)
				end	
			end
		end
		self:UseHydraminion(target)
		self:Gapclose(target)
		self:StackPassive(target)	
	end	
	
	end
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
		if GetDistance(unit.pos, myHero.pos) > 3500 or not self.Menu.WSet.BlockList["Dodge"..spell.name]:Value() then return end
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
 
function Irelia:Draw()
  if myHero.dead then return end
	
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 900, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 775, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 825, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.dir	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	
	if self.Menu.Burst.Draw:Value() then
		Draw.Text("Burst Mode: ", 15, textPos.x + 1026, textPos.y + 30, Draw.Color(255, 225, 255, 0))
		if self.Menu.Burst.Start:Value() then
			if myHero.levelData.lvl >= self.Menu.Burst.Lvl:Value() then
				Draw.Text("Active", 15, textPos.x + 1100, textPos.y + 30, Draw.Color(255, 0, 255, 0))
			else
				Draw.Text("Level too low", 15, textPos.x + 1100, textPos.y + 30, Draw.Color(255, 255, 0, 0)) 
			end
		else
			Draw.Text("OFF", 15, textPos.x + 1100, textPos.y + 30, Draw.Color(255, 255, 0, 0)) 
		end
	end

	if self.Menu.AutoQ.UseQ:Value() and self.Menu.AutoQ.Draw:Value() then 
		Draw.Text("Auto[Q] Minion: ", 15, textPos.x + 1004, textPos.y + 15, Draw.Color(255, 225, 255, 0))
		if self.Menu.AutoQ.Q:Value() then 
			Draw.Text("ON", 15, textPos.x + 1100, textPos.y + 15, Draw.Color(255, 0, 255, 0))
		else
			Draw.Text("OFF", 15, textPos.x + 1100, textPos.y + 15, Draw.Color(255, 255, 0, 0)) 
		end	
	end	

	if self.Menu.Combo.Draw:Value() then
		Draw.Text(" Last Combo[Q]: ", 15, textPos.x + 1000, textPos.y + 0, Draw.Color(255, 225, 255, 0))
		if self.Menu.Combo.QLogic:Value() then
			Draw.Text("Almost Kill", 15, textPos.x + 1100, textPos.y + 0, Draw.Color(255, 0, 255, 0))
		else
			Draw.Text("Kill", 15, textPos.x + 1100, textPos.y + 0, Draw.Color(255, 0, 255, 0)) 
		end	
	end		
	
	local target = GetTarget(1000)
	if target == nil then return end	
	if target and self.Menu.Drawing.Draw:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 and not target.dead then
	local Dmg = ((getdmg("Q", target, myHero)*3) + getdmg("W", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero)) 
	local hp = target.health	
		if myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_E).level > 0 and myHero:GetSpellData(_R).level > 0 and Dmg > hp then
			Draw.Text("KILL HIM", 20, target.pos2D.x, target.pos2D.y, Draw.Color(255, 255, 0, 0))
		end	
	end
end

function Irelia:Combo()
local target = GetTarget(1100)     	
if target == nil then return end
	if IsValid(target) then
		local count = GetEnemyCount(600, target)
		countR = false
		if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 1000 and self.Menu.Combo.UseRCount:Value() then
			if count >= self.Menu.Combo.RCount:Value() then					
				countR = true
				self:CastR(target)

			end
		end			
		
		if self.Menu.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				self:CastE(target)

			end
		end	
			
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and GotBuff(target, "ireliamark") == 1 then
			Control.CastSpell(HK_Q, target.pos)
		end
		
		if self.Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				Control.CastSpell(HK_W, target)

			end
		end	
		
		if self.Menu.Combo.UseR:Value() and Ready(_R) and not Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 1000 and not countR then					
				self:CastR(target)

			end
		end			
		
		if self.Menu.Combo.QLogic:Value() then 
		local dmg = getdmg("Q", target, myHero) 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				if dmg >= target.health then
					Control.CastSpell(HK_Q, target.pos)
				end
			end			
			
			if myHero.pos:DistanceTo(target.pos) >= 300 and myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and (dmg*2) >= target.health then
				Control.CastSpell(HK_Q, target.pos)
			end		
		
		else
			local dmg = getdmg("Q", target, myHero) 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				if dmg >= target.health then
					Control.CastSpell(HK_Q, target.pos)
				end
			end
		end
		
		if self.Menu.Combo.Gap:Value() then
			self:Gapclose(target)
		end	
		
		if self.Menu.Combo.Stack:Value() then
			self:StackPassive(target)
		end	
	end	
end	

function Irelia:Harass()
local target = GetTarget(1100)     	
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
			if self.Menu.Harass.UseQ:Value() ~= 2 and GotBuff(target, "ireliamark") == 1 then
				Control.CastSpell(HK_Q, target.pos)
				DelayAction(function()
				self:CastQMinion(target)
				end,0.5)
			end	
			if self.Menu.Harass.UseQ:Value() ~= 1 then
				Control.CastSpell(HK_Q, target.pos)
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

function Irelia:LastHit()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if self.Menu.LastHit.UseItem:Value() then
				self:UseHydraminion(minion)
			end	
            
			if self.Menu.LastHit.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.LastHit.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					Control.CastSpell(HK_Q, minion.pos)
				end
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					Control.CastSpell(HK_Q, minion.pos)
				end
            end
		end
	end
end
	
function Irelia:AutoQ()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if self.Menu.AutoQ.UseItem:Value() then
				self:UseHydraminion(minion)
			end	
            
			if self.Menu.AutoQ.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.AutoQ.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					Control.CastSpell(HK_Q, minion.pos)
				end
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					Control.CastSpell(HK_Q, minion.pos)
				end
            end
		end
	end
end

function Irelia:StackPassive(target)
if GotBuff(myHero, "ireliapassivestacksmax") == 1 then return end	
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if target.pos:DistanceTo(minion.pos) <= 400 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end
			self:UseHydraminion(minion)
		end
	end
end	

function Irelia:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_JUNGLE and IsValid(minion) then
 			
			if myHero.pos:DistanceTo(minion.pos) <= 825 and self.Menu.JClear.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then
				Control.CastSpell(HK_W, minion.pos)
                    
            end           
           
			if self.Menu.JClear.UseItem:Value() then
				self:UseHydraminion(minion)
			end				
			
			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.JClear.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero)
				if QDmg > minion.health then
					Control.CastSpell(HK_Q, minion.pos)
				end				
			end
        end
    end
end
			
function Irelia:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if myHero.pos:DistanceTo(minion.pos) <= 825 and self.Menu.Clear.UseW:Value() and Ready(_W) and not Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then
				Control.CastSpell(HK_W, minion.pos)
                    
            end           
           
			if self.Menu.AutoQ.Q:Value() then return end
			if self.Menu.Clear.UseItem:Value() then
				self:UseHydraminion(minion)
			end				
			
			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.Clear.Last.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					Control.CastSpell(HK_Q, minion.pos)
				end	
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					Control.CastSpell(HK_Q, minion.pos)
				end				
			end
        end
    end
end

function Irelia:KillSteal()
	local target = GetTarget(1100)     	
	if target == nil then return end
	
	
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and self.Menu.ks.UseQ:Value() then
			local QDmg = getdmg("Q", target, myHero)
			local hp = target.health
			if QDmg >= hp then
				Control.CastSpell(HK_Q, target.pos)
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
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_R) and self.Menu.ks.UseR:Value() then
			local RDmg = getdmg("R", target, myHero)
			local hp = target.health
			if RDmg >= hp then
				self:CastR(target)
			end
		end
	end
end	

function Irelia:CastQMinion(target)
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			local Dmg = getdmg("Q", target, myHero) or getdmg("W", target, myHero) or getdmg("E", target, myHero) or getdmg("R", target, myHero)
			local QDmg = getdmg("Q", minion, myHero, 2)
			local hp = target.health
			if myHero.pos:DistanceTo(minion.pos) <= 600 and myHero.pos:DistanceTo(minion.pos) > myHero.pos:DistanceTo(target.pos) and not IsUnderTurret(minion) and hp > Dmg and QDmg >= minion.health then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end
end	

function Irelia:Gapclose(target)
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if Ready(_Q) and minion.team == TEAM_ENEMY and IsValid(minion) then
			if myHero.pos:DistanceTo(minion.pos) <= 600 and myHero.pos:DistanceTo(target.pos) > myHero.pos:DistanceTo(minion.pos) and target.pos:DistanceTo(minion.pos) <= 600 then
				local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg >= minion.health then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end	
		end
	end	
end	
	

function Irelia:CastW(target)
    if target then
        if not charging and GotBuff(myHero, "ireliawdefense") == 0 then
            Control.KeyDown(HK_W)
            wClock = clock()
            settime = clock()
            charging = true
        end
		local pred = GetGamsteronPrediction(target, WData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
			if GotBuff(myHero, "ireliawdefense") == 1 and (target.pos:DistanceTo() > 600) then
				Control.CastSpell(HK_W, pred.CastPosition)
				charging = false
			elseif GotBuff(myHero, "ireliawdefense") == 1 and clock() - wClock >= 0.5 and target.pos:DistanceTo() < 825 then
				Control.CastSpell(HK_W, pred.CastPosition)
				charging = false
			end		
        end
        
        
    end
    if clock() - wClock >= 1.5 then
    Control.KeyUp(HK_W)
    charging = false
    end 
end

function Irelia:Flee()
    local target = GetTarget(1100)     	
	if target == nil then return end
	if self.Menu.Flee.Q:Value() then
		if target.pos:DistanceTo(myHero.pos) < 1000 then
			if Ready(_Q) then
				for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
					if minion.team == TEAM_ENEMY and IsValid(minion) then
						local QDmg = getdmg("Q", minion, myHero, 2)
						if minion.pos:DistanceTo(myHero.pos) <= 600 and target.pos:DistanceTo(myHero.pos) < minion.pos:DistanceTo(target.pos) and QDmg > minion.health then
							Control.CastSpell(HK_Q, minion.pos)
						end
					end	
                end
            end
            
		end
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
    local units = GetEnemyHeroes()
    local startPos, endPos, count = nil, nil, 0
    local candidates, unitPositions = {}, {}
    for i, unit in ipairs(units) do
        local cp = GetPred(unit,2000,0.75 + ping)
        if cp then candidates[i], unitPositions[i] = cp, cp end
    end
    local maxCount = #units
    for i = 1, maxCount do
        for j = 1, maxCount do
            if candidates[j] ~= candidates[i] then
                table.insert(candidates, Vector(candidates[j] + candidates[i]) / 2)
            end
        end
    end
    for i, unit2 in pairs(units) do
        local cp = GetPred(unit2,2000,0.75 + ping)
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
                        if number >= 2 then startPos, endPos, count = cp, ePos, number end

                    end
                end
            end
        end
    end
    return startPos, endPos, count
end

function Irelia:CastE2()
local target = GetTarget(1100)
	if IsValid(target) and self.Menu.AutoE.UseE:Value() and Ready(_E) then
		local startPos, endPos, count = self:GetBestECastPositions(target)
		if startPos and endPos then 
			local cast1, cast2 = self:LineCircleIntersection(startPos, endPos, myHero.pos, 725)
			local targetCount = GetEnemyCount(725, myHero)
				if targetCount >= 2 and cast1 and cast2 then
				if myHero:GetSpellData(_E).name == "IreliaE" then
					Control.CastSpell(HK_E, cast1)
				elseif myHero:GetSpellData(_E).name == "IreliaE2" then
					DelayAction(function() 
					DisableMovement(true)
					Control.CastSpell(HK_E, cast2)
					DisableMovement(false)
					end, 0.15)
				end
			end
		end
	end	
end	

function Irelia:CastE(target)

    if myHero:GetSpellData(_E).name == "IreliaE" then
		Control.CastSpell(HK_E, myHero.pos)
    end
	
    if myHero:GetSpellData(_E).name == "IreliaE2" then
        local aimpos = GetPred(target,math.huge,0.25+ Game.Latency()/1000)
		if aimpos then
		Epos = aimpos + (myHero.pos - aimpos): Normalized() * -150
			DisableMovement(true)
			Control.CastSpell(HK_E, Epos)
			DisableMovement(false)
		end
	end
end


function Irelia:CastR(target)
	local pred = GetGamsteronPrediction(target, RData, myHero)
	if pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
		Control.CastSpell(HK_R, pred.CastPosition)
	end
end	




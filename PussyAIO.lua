local Heroes = {"XinZhao","Kassadin","Veigar","Tristana","Warwick","Neeko","Cassiopeia","Malzahar","Zyra","Sylas","Kayle"}
if not table.contains(Heroes, myHero.charName) then return end



--[[

function OnLoad()
	if myHero.visible then
		MenuElement({type = MENU, id = "logo", name = "Supported Champions"})
		logo:MenuElement({id = "on", name = "Show supported Champs", key = string.byte("X"), toggle = true})	
	end
	local textPos = myHero.pos:To2D()
	if myHero.visible then
		if logo.on:MenuElement:Value() then
			Draw.Text("BlaBlaBla", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
		end
	end
end
]]


-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyAIO.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyCassio.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyAIO.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyCassio.version"
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
            print("New PussyAIO Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end


local menu = 1
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local Allies = {}; local Enemies = {}; local Turrets = {}; local Units = {}
local GameLatency = Game.Latency
local GameTimer = Game.Timer


local function IsValid(unit, range)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius) then
        return true;
    end
    return false;
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end 

function CalculateMagicalDamage(target, damage)
	
	if target and damage then	
		local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
		local damageReduction = 100 / ( 100 + targetMR)
		if targetMR < 0 then
			damageReduction = 2 - (100 / (100 - targetMR))
		end		
		damage = damage * damageReduction
		return damage
	end
	return 0
end

function CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

local function GetTarget(range) 
	local target = nil 
	if Orb == 1 then
		target = EOW:GetTarget(range)
	elseif Orb == 2 then 
		target = _G.SDK.TargetSelector:GetTarget(range)
	elseif Orb == 3 then
		target = GOS:GetTarget(range)
	elseif Orb == 4 then
		target = _G.gsoSDK.TS:GetTarget()		
	end
	return target 
end

local intToMode = {
   	[0] = "",
   	[1] = "Combo",
   	[2] = "Harass",
   	[3] = "LastHit",
   	[4] = "Clear"
}

function GetMode()
	if Orb == 1 then
		return intToMode[EOW.CurrentMode]
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
	elseif Orb == 4 then
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
	else
		return GOS.GetMode()
	end
end	

function SetAttack(bool)
	if _G.EOWLoaded then
		EOW:SetAttacks(bool)
	elseif _G.SDK then                                                        
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.gsoSDK then
		_G.gsoSDK.Orbwalker:SetAttack(bool)	
	else
		GOS.BlockAttack = not bool
	end

end

function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.gsoSDK then
		_G.gsoSDK.Orbwalker:SetMovement(bool)
		_G.gsoSDK.Orbwalker:SetAttack(bool)	
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end

function DisableOrb()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)
		end
end

function EnableOrb()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)	
		end
end

function EnableMovement()
	SetMovement(true)
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastSpellMM(spell,pos,range,delay)
	local range = range or math.huge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and HPred:GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x,castPosMM.y)
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

local spellcast = {state = 1, mouse = mousePos}
function CastSpell(HK, pos, delay)
	if spellcast.state == 2 then return end
	if ExtLibEvade and ExtLibEvade.Evading then return end
	
	spellcast.state = 2
	DisableOrb()
	spellcast.mouse = mousePos
	DelayAction(function() 
		Control.SetCursorPos(pos) 
		Control.KeyDown(HK)
		Control.KeyUp(HK)
	end, 0.05) 
	
		DelayAction(function()
			Control.SetCursorPos(spellcast.mouse)
		end,0.25)
		
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.35)
	
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

local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,
}

function EnemiesAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if (IsValid(hero, range) and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end

local function HasPoison(unit)
	for i = 0, unit.buffCount do 
	local buff = unit:GetBuff(i)
		if buff.type == 23 and Game.Timer() < buff.expireTime - 0.141  then
			return true
		end
	end
	return false
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in pairs(objects) do
        if GetDistanceSqr(pos, object.pos) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in pairs(objects) do
        local hit = CountObjectsNearPos(object.pos, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object.pos
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CountEnemiesNear(origin, range)
	local count = 0
	for i  = 1,Game.HeroCount(i) do
		local enemy = Game.Hero(i)
		if IsValid(enemy, range) and enemy.isEnemy and  HPred:CanTarget(enemy) and HPred:IsInRange(origin, enemy.pos, range) then
			count = count + 1
		end			
	end
	return count
end

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if IsValid(unit) and unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end 

local function IsRecalling()
	for i = 1, 63 do
	local buff = myHero:GetBuff(i) 
		if buff.count > 0 and buff.name == "recall" and Game.Timer() < buff.expireTime then
			return true
		end
	end 
	return false
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function GetImmobileCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if IsValid(hero, Range) and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < Range and IsImmobileTarget(hero) then
		count = count + 1
		end
	end
	return count
end

local function Cleans(unit)
	if unit == nil then return false end
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 7 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 25 or buff.type == 10 or buff.type == 31 or buff.type == 24) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function Block(boolean) 
	if boolean == true then 
		if Orb == 1 then
			EOW:SetAttacks(false)
		elseif Orb == 2 then
			_G.SDK.Orbwalker:SetAttack(false)
		else
			--GOS:BlockAttack(true)
		end
	else
		if Orb == 1 then
			EOW:SetAttacks(true)
		elseif Orb == 2 then
			_G.SDK.Orbwalker:SetAttack(true)
		else
			--GOS:BlockAttack()
		end
	end
end
local sqrt = math.sqrt 
local function GetDistance2D(p1,p2)
	return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local _OnVision = {}
function OnVision(unit)
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
	return _OnVision[unit.networkID]
end

Callback.Add("Tick", function() OnVisionF() end)
local visionTick = GetTickCount()
function OnVisionF()
	if GetTickCount() - visionTick > 100 then
		for i,v in pairs(GetEnemyHeroes()) do
			OnVision(v)
		end
	end
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

function EnemyInRange(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

function EnemiesNear(pos,range)
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if IsValid(hero) and hero.isEnemy then
			N = N + 1
		end
	end
	return N	
end	

function MinionsNear(pos,range)
	local N = 0
		for i = 1, Game.MinionCount() do 
		local Minion = Game.Minion(i)	
		if IsValid(Minion, 800) and Minion.team == TEAM_ENEMY then
			N = N + 1
		end
	end
	return N	
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

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if IsValid(hero, Range) and hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

local function GetAllyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if IsValid(hero, Range) and hero.team == TEAM_ALLY and hero ~= myHero and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

function IsUnderTurret(unit)
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

function GetAllyHeroes() 
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if IsValid(Hero) and Hero.isAlly and not Hero.isMe then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function GetAllyTurret() 
	Allyturret = {}
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
		if turret.isAlly and not turret.dead then
			table.insert(Allyturret, turret)
		end
	end
	return Allyturret
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Cassiopeia"



if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')
require "2DGeometry"

function Cassiopeia:LoadSpells()
	R = {Range = 825, Width = 200, Delay = 0.8, Speed = math.huge, Collision = false, aoe = false, Type = "circular"}

end

local QData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.8, Radius = 200, Range = 850, Speed = math.huge, Collision = false
}

	local AA = false
	local QRange = 850 * 850
	local MaxWRange = 800 * 800
	local MinWRange = 420 * 420
	local WMinCRange = 500 
	local WMaxCRange = 800 	
	local ERange = 700 * 700
	local RRange = 825 * 825

	function Cassiopeia:__init()
		Callback.Add("Tick", function() self:Tick() end)
		Callback.Add("Draw", function() self:Draw() end)
		self:Menu()
		self:LoadSpells()
		if _G.EOWLoaded then
			Orb = 1
		elseif _G.SDK and _G.SDK.Orbwalker then
			Orb = 2
		elseif _G.gsoSDK then
			Orb = 4			
		end
		print("PussyCassio Loaded")
	end

	function Cassiopeia:Menu()
		Cass = MenuElement({type = MENU, id = "Cass", name = "PussyCassio"})		
		Cass:MenuElement({name = " ", drop = {"General Settings"}})
		
		--Combo   
		Cass:MenuElement({type = MENU, id = "c", name = "Combo"})
		Cass.c:MenuElement({id = "Block", name = "Block AA in Combo [?]", value = true, tooltip = "Reload Script after changing"})
		Cass.c:MenuElement({id = "Q", name = "Use Q", value = true})
		Cass.c:MenuElement({id = "W", name = "Use W", value = true})
		Cass.c:MenuElement({id = "E", name = "Use E", value = true})
		Cass.c:MenuElement({id = "SR", name = "Manual R ", key = string.byte("A")})
		Cass.c:MenuElement({id = "R", name = "Use R ", value = true})
		Cass.c:MenuElement({id = "Count", name = "Min Amount to hit R", value = 2, min = 1, max = 5, step = 1})
		Cass.c:MenuElement({id = "P", name = "Use Panic R and Ghost", value = true})
		Cass.c:MenuElement({id = "HP", name = "Min HP % to Panic R", value = 20, min = 0, max = 100, step = 1})
		
		--Harass
		Cass:MenuElement({type = MENU, id = "h", name = "Harass"})
		Cass.h:MenuElement({id = "Q", name = "UseQ", value = true})
		Cass.h:MenuElement({id = "E", name = "UseE only poisend", value = true})		
		
		--Clear
		Cass:MenuElement({type = MENU, id = "w", name = "Clear"})
		Cass.w:MenuElement({id = "Q", name = "Use Q", value = true})
		Cass.w:MenuElement({id = "W", name = "Use W", value = true})
		Cass.w:MenuElement({id = "Count", name = "Min Minions to hit W", value = 3, min = 1, max = 5, step = 1})		
		Cass.w:MenuElement({id = "E", name = "Auto E Toggle Key", key = 84, toggle = true})
		
		--JungleClear
		Cass:MenuElement({type = MENU, id = "j", name = "JungleClear"})
		Cass.j:MenuElement({id = "Q", name = "Use Q", value = true})
		Cass.j:MenuElement({id = "W", name = "Use W", value = true})
		Cass.j:MenuElement({id = "E", name = "Use E[poisend or Lasthit]", value = true})		
		
		--KillSteal
		Cass:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
		Cass.ks:MenuElement({id = "Q", name = "UseQ", value = true})
		Cass.ks:MenuElement({id = "W", name = "UseW", value = true})
		Cass.ks:MenuElement({id = "E", name = "UseE", value = true})
		Cass.ks:MenuElement({id = "IG", name = "Use Ignite", value = true})		

		--Engage
		Cass:MenuElement({type = MENU, id = "kill", name = "Engage FullDmg + Ghost or Ignite"})
		Cass.kill:MenuElement({id = "Eng", name = "EngageKill 1vs1 Key=T", value = true, tooltip = "Press Key when Engage is Drawing"})
		
		--Mana
		Cass:MenuElement({type = MENU, id = "m", name = "Mana Manager"})
		Cass.m:MenuElement({name = " ", drop = {"Harass [%]"}})
		Cass.m:MenuElement({id = "Q", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "W", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "E", name = "E Mana", value = 5, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "R", name = "R Mana", value = 5, min = 0, max = 100, step = 1})		
		Cass.m:MenuElement({name = " ", drop = {"Clear [%]"}})
		Cass.m:MenuElement({id = "QW", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "WW", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "EW", name = "E Mana", value = 10, min = 0, max = 100, step = 1})
		
		Cass:MenuElement({name = " ", drop = {"Advanced Settings"}})
		
		--Activator
		Cass:MenuElement({type = MENU, id = "a", name = "Activator"})
		Cass.a:MenuElement({type = MENU, id = "Hextech", name = "hextech GLP-800"})
		Cass.a.Hextech:MenuElement({id = "ON", name = "Enabled in Combo", value = true})
		Cass.a.Hextech:MenuElement({id = "HP", name = "Min Target HP %", value = 100, min = 0, max = 100, step = 1})		
		Cass.a:MenuElement({type = MENU, id = "Zhonyas", name = "Zhonya's and StopWatch"})
		Cass.a.Zhonyas:MenuElement({id = "ON", name = "Enabled", value = true})
		Cass.a.Zhonyas:MenuElement({id = "HP", name = "HP % Zhonya's", value = 15, min = 0, max = 100, step = 1})
		Cass.a:MenuElement({type = MENU, id = "Seraphs", name = "Seraph's Embrace"})
		Cass.a.Seraphs:MenuElement({id = "ON", name = "Enabled", value = true})
		Cass.a.Seraphs:MenuElement({id = "HP", name = "HP % Seraph's", value = 15, min = 0, max = 100, step = 1})
		
		--Drawings
		Cass:MenuElement({type = MENU, id = "d", name = "Drawings"})
		Cass.d:MenuElement({id = "ON", name = "Enable Drawings", value = true})
		Cass.d:MenuElement({id = "Text", name = "Draw Text", value = true})
		Cass.d:MenuElement({id = "Lines", name = "Draw Lines", value = true})
		Cass.d:MenuElement({type = MENU, id = "Q", name = "Q"})
		Cass.d.Q:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "W", name = "W"})
		Cass.d.W:MenuElement({id = "ON", name = "Enabled", value = false})       
		Cass.d.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "E", name = "E"})
		Cass.d.E:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "R", name = "R"})
		Cass.d.R:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})				
		if Cass.c.Block:Value() then
			AA = true 
		end
	end

	function Cassiopeia:Qdmg(unit)
		local level = myHero:GetSpellData(_Q).level
		local base = (({75, 110, 145, 180, 215})[level] + 0.90 * myHero.ap)
		return CalcMagicalDamage(myHero,unit, base)
	end
	
	function Cassiopeia:Wdmg(unit)
		local level = myHero:GetSpellData(_W).level
		local base = ({100, 125, 150, 175, 200})[level] + 0.75 * myHero.ap
		return CalcMagicalDamage(myHero,unit, base)
	end

	function Cassiopeia:Edmg(unit)
		local level = myHero.levelData.lvl
		local base = (48 + 4 * level) + (0.1 * myHero.ap)
		return CalcMagicalDamage(myHero,unit, base)
	end

	function Cassiopeia:PEdmg(unit)
		local level = myHero:GetSpellData(_E).level
		local bonus = (({10, 30, 50, 70, 90})[level] + 0.60 * myHero.ap)
		local PEdamage = self:Edmg(unit) + bonus
		return CalcMagicalDamage(myHero,unit, PEdamage)
	end
	
	function Cassiopeia:Rdmg(unit)
		local level = myHero:GetSpellData(_R).level
		local base = ({150, 250, 350})[level] + 0.5 * myHero.ap
		return CalcMagicalDamage(myHero,unit, base)
		
	end				
	
	function Cassiopeia:Ignitedmg(unit)
		local level = myHero.levelData.lvl
		local base = 50 + (20 * level)
		return base
	end
	

	local abs = math.abs 
	local deg = math.deg 
	local acos = math.acos 
	function Cassiopeia:IsFacing(unit)
	    local V = Vector((unit.pos - myHero.pos))
	    local D = Vector(unit.dir)
	    local Angle = 180 - deg(acos(V*D/(V:Len()*D:Len())))
	    if abs(Angle) < 80 then 
	        return true  
	    end
	    return false
	end

	function Cassiopeia:GetAngle(v1, v2)
		local vec1 = v1:Len()
		local vec2 = v2:Len()
		local Angle = abs(deg(acos((v1*v2)/(vec1*vec2))))
		if Angle < 90 then
			return true
		end
		return false
	end

	function Cassiopeia:Tick()
		if myHero.dead == false and Game.IsChatOpen() == false then
		local Mode = GetMode()
			if Mode == "Combo" then
				self:BlockAA()
				self:Check(Mode)
				self:Combo()
			elseif Mode == "Harass" then
				self:Check(Mode)
				self:Harass()
			elseif Mode == "Clear" then
				self:Check(Mode)
				self:Clear()
				self:JClear()
			elseif Mode == "Flee" then
				self:Engage()
			end
			if Cass.w.E:Value() and Mode ~= "Combo" then
				self:AutoE()
			end
			if Cass.c.SR:Value() then
				self:SemiR()
			end	
			self:UnBlockAA(Mode)
			self:Activator(Mode)
			self:KsQ()
			self:KsW()
			self:KsE()
			self:KsIG()			
			self:AntiCC()
		end
	end

function Cassiopeia:IsFacing(target)
local target = GetTarget(RRange)
if target == nil then return end
	local dotProduct = myHero.dir.x*target.dir.x + myHero.dir.z*target.dir.z
	if (dotProduct < 0) then
		if (myHero.dir.x > 0 and myHero.dir.z > 0) then
			return ((target.pos.x - myHero.pos.x > 0) and (target.pos.z - myHero.pos.z > 0))
		elseif (myHero.dir.x < 0 and myHero.dir.z < 0) then
			return ((target.pos.x - myHero.pos.x < 0) and (target.pos.z - myHero.pos.z < 0))
		elseif (myHero.dir.x > 0 and myHero.dir.z < 0) then
			return ((target.pos.x - myHero.pos.x > 0) and (target.pos.z - myHero.pos.z < 0))
		elseif (myHero.dir.x < 0 and myHero.dir.z > 0) then
			return ((target.pos.x - myHero.pos.x < 0) and (target.pos.z - myHero.pos.z > 0))
		end
	end
	return false
end

	function Cassiopeia:RLogic()
		local RTarget = nil 
		local Most = 0
		local Cast = false
			local InFace = {}
			for i = 1, Game.HeroCount() do
			local Hero = Game.Hero(i)
				if IsValid(Hero, 850) then 
					--local LS = LineSegment(myHero.pos, Hero.pos)
					--LS:__draw()
					InFace[#InFace + 1] = Hero
				end
			end
			local IsFace = {}
			for r = 1, #InFace do 
			local FHero = InFace[r]
				if self:IsFacing(FHero) then
					local Vectori = Vector(myHero.pos - FHero.pos)
					IsFace[#IsFace + 1] = {Vector = Vectori, Host = FHero}
				end
			end
			local Count = {}
			local Number = #InFace
			for c = 1, #IsFace do 
			local MainLine = IsFace[c]
			if Count[MainLine] == nil then Count[MainLine] = 1 end
				for w = 1, #IsFace do 
				local CloseLine = IsFace[w] 
				local A = CloseLine.Vector
				local B = MainLine.Vector
					if A ~= B then
						if self:GetAngle(A,B) and GetDistanceSqr(MainLine.Host.pos, myHero.pos) < RRange and HasPoison(CloseLine.Host) then 
							Count[MainLine] = Count[MainLine] + 1
						end
					end
				end
				if Count[MainLine] > Most then
					Most = Count[MainLine]
					RTarget = MainLine.Host
				end
			end
		--	print(Most)
			if Most >= Cass.c.Count:Value() or Most == Number then
				Cast = true 
			end
		--	print(Most)
		--	if RTarget then
		--		LSS = Circle(Point(RTarget), 50)
		--		LSS:__draw()
		--	end
		return RTarget, Cast
	end

	function Cassiopeia:BlockAA()
		if AA == true then
			if Orb == 1 then
				EOW:SetAttacks(false)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(false)
			elseif Orb == 4 then
				_G.gsoSDK.Orbwalker:SetAttack(false)				
			else
				--GOS:BlockAttack(true)
			end
		end
	end

	function Cassiopeia:UnBlockAA(Mode)
		if Mode ~= "Combo" and AA == false then 
			if Orb == 1 then 
				EOW:SetAttacks(true)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(true)
			elseif Orb == 4 then
				_G.gsoSDK.Orbwalker:SetAttack(true)				
			else
			--	GOS:BlockAttack()
			end
		end
	end
	
	function Cassiopeia:Check(Mode)
		if AA == false or Mode ~= "Combo" then
		local activeSpell = myHero.activeSpell
		local cd = myHero:GetSpellData(_E).currentCd
			if activeSpell.windup > cd then
				if Orb == 1 then
					EOW:SetAttacks(false)
				elseif Orb == 2 then
					_G.SDK.Orbwalker:SetAttack(false)
				elseif Orb == 4 then
					_G.gsoSDK.Orbwalker:SetAttack(false)					
				else
				--	GOS:BlockAttack(true)
				end
			else
				if Orb == 1 then 
					EOW:SetAttacks(true)
				elseif Orb == 2 then
					_G.SDK.Orbwalker:SetAttack(true)
				elseif Orb == 4 then
					_G.gsoSDK.Orbwalker:SetAttack(true)				
				else
				--	GOS:BlockAttack()
				end
			end
		end
	end

	function Cassiopeia:CastW(key, pos)
		local key = key or HK_W
		local Dist = pos:DistanceTo()
		local h = myHero.pos
		local v = Vector(pos - myHero.pos):Normalized()
		if Dist < WMinCRange then
			Control.CastSpell(key, h + v*500)
		elseif Dist > WMaxCRange then
			Control.CastSpell(key, h + v*800)
		else
			Control.CastSpell(key, pos)
		end
	end	

function Cassiopeia:Activator(Mode)
	local target = GetTarget(800)
	if target == nil then return end		
	if IsValid(target, 800) then
		if Cass.a.Zhonyas.ON:Value() then
		local Zhonyas = GetItemSlot(myHero, 3157) or GetItemSlot(myHero, 2420)
			if Zhonyas >= 1 and Ready(Zhonyas) then 
				if myHero.health/myHero.maxHealth < Cass.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
		if Cass.a.Seraphs.ON:Value() then
		local Seraphs = GetItemSlot(myHero, 3040)
			if Seraphs >= 1 and Ready(Seraphs) then
				if myHero.health/myHero.maxHealth < Cass.a.Seraphs.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Seraphs])
				end
			end
		end
		if Mode == "Combo" then
			if Cass.a.Hextech.ON:Value() then
			local Hextech = GetItemSlot(myHero, 3030)
				if Hextech >= 1 and Ready(Hextech) and target.health/target.maxHealth < Cass.a.Hextech.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Hextech], target)
				end
			end

		end
	end
end	

function Cassiopeia:Combo()
	local activeSpell = myHero.activeSpell
   	if activeSpell.valid and activeSpell.spellWasCast == false then
   		return
   	end
	local target = GetTarget(950)
	if target == nil then return end
		
	local QValue = Cass.c.Q:Value()
	local WValue = Cass.c.W:Value()
	local RValue = Cass.c.R:Value()
	local Dist = GetDistanceSqr(myHero.pos, target.pos)
	local QWReady = Ready(_Q) 
	local RTarget, ShouldCast = self:RLogic()
	if IsValid(target, 950) then	
		
		if Cass.c.W:Value() and Ready(_W)  then 
			if Dist < MaxWRange and Dist > MinWRange then
			local Pos = GetPred(target, 1500, 0.25 + Game.Latency()/1000)
				if GetDistanceSqr(Pos, myHero.pos) < MaxWRange then 
					self:CastW(HK_W, Pos)
				end
			end
		end
		if QValue and Ready(_Q) then 
			if Dist < QRange then 
			local pred = GetGamsteronPrediction(target, QData, myHero)
				if GetDistanceSqr(target.pos, myHero.pos) < QRange and pred.Hitchance >= _G.HITCHANCE_HIGH then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
		end
		if Cass.c.E:Value() and Ready(_E) then 
			if Dist < ERange then
				Control.CastSpell(HK_E, target)
			end
		end		
		local WData = myHero:GetSpellData(_W) 
		local WCheck = Ready(_W)
		local Panic = Cass.c.P:Value() and myHero.health/myHero.maxHealth < Cass.c.HP:Value()/100 
			if Panic then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerHaste" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHaste" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2)
				end
			end
		if Cass.c.R:Value() and Ready(_R) and (HasPoison(target) or Panic) and ((WCheck == false or (WCheck and (Game.Timer() + WData.cd) - WData.castTime > 2)) or WValue == false) then
			if Panic then
				if Dist < RRange and self:PEdmg(target) < target.health then
					if RTarget then
						Control.CastSpell(HK_R, RTarget)
					else
						Control.CastSpell(HK_R, target)
					end
				end
			end

			if Cass.c.R:Value() and Ready(_R) then
				if Dist < RRange then 
					if RTarget then
					Control.CastSpell(HK_R, RTarget)
					end
				end 
			end
		end
	end
end	
	
function Cassiopeia:SemiR()
	local target = GetTarget(950)
	if target == nil then return end
	local Dist = GetDistanceSqr(myHero.pos, target.pos)	
	if IsValid(target, 950) and Ready(_R) then
		if Dist < RRange then
			Control.SetCursorPos(target)
			Control.CastSpell(HK_R, target)
		end
	end 
end
	
		

function Cassiopeia:Harass()
	local activeSpell = myHero.activeSpell
   	if activeSpell.valid and activeSpell.spellWasCast == false then
	return end
	local target = GetTarget(950)
	if target == nil then return end
	local QValue = Cass.h.Q:Value()
	local Dist = GetDistanceSqr(myHero.pos, target.pos)
	if IsValid(target, 950) then	
		if QValue and Ready(_Q) and myHero.mana/myHero.maxMana > Cass.m.Q:Value()/100 then 
			if Dist < QRange then 
			local pred = GetGamsteronPrediction(target, QData, myHero)
				if GetDistanceSqr(target.pos, myHero.pos) < QRange and pred.Hitchance >= _G.HITCHANCE_HIGH then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
		end

		if Cass.h.E:Value() and Ready(_E) and (HasPoison(target) or self:Edmg(target) * 2  > target.health) and myHero.mana/myHero.maxMana > Cass.m.E:Value()/100 then 
			if Dist < ERange then
				Control.CastSpell(HK_E, target)
			end
		end
	end
end	
	
	

function Cassiopeia:Clear()
	for i = 1, Game.MinionCount() do 
	local Minion = Game.Minion(i)		
	local QValue = Cass.w.Q:Value()
	local WValue = Cass.w.W:Value()				
	if Minion.team == TEAM_ENEMY then	
		if Ready(_Q) and QValue and myHero.mana/myHero.maxMana > Cass.m.QW:Value()/100 then
			if IsValid(Minion, 850) and GetDistanceSqr(Minion.pos, myHero.pos) < QRange then 
				Control.CastSpell(HK_Q, Minion.pos)
			end
		end
		local Pos = GetPred(Minion, 1500, 0.25 + Game.Latency()/1000)
		local Dist = GetDistanceSqr(Minion.pos, myHero.pos)	
		if Ready(_W) and IsRecalling() == false and WValue and myHero.mana/myHero.maxMana > Cass.m.WW:Value()/100 then
			if Dist < MaxWRange and Dist > MinWRange then	
				if IsValid(Minion, 800) and GetDistanceSqr(Pos, myHero.pos) < MaxWRange and MinionsNear(myHero.pos,800) >= Cass.w.Count:Value() then 
					self:CastW(HK_W, Pos)
													
					
				end
			end
		end			
	end
	end
end

	
function Cassiopeia:JClear()
	for i = 1, Game.MinionCount() do 
	local Minion = Game.Minion(i)		
	local QValue = Cass.j.Q:Value()
	local WValue = Cass.j.W:Value()
	local EValue = Cass.j.E:Value()
	if Minion.team == TEAM_JUNGLE then	
		if Ready(_Q) and IsRecalling() == false and QValue and myHero.mana/myHero.maxMana > Cass.m.QW:Value()/100 then
			if IsValid(Minion, 850) and GetDistanceSqr(Minion.pos, myHero.pos) < QRange then 
				Control.CastSpell(HK_Q, Minion.pos)
				
			end
		end
		
		local Pos = GetPred(Minion, 1500, 0.25 + Game.Latency()/1000)
		local Dist = GetDistanceSqr(Minion.pos, myHero.pos)	
		if Ready(_W) and IsRecalling() == false and WValue and myHero.mana/myHero.maxMana > Cass.m.WW:Value()/100 then
			if Dist < MaxWRange and Dist > MinWRange then	
				if IsValid(Minion, 800) and GetDistanceSqr(Pos, myHero.pos) < MaxWRange then 
					self:CastW(HK_W, Pos)
				end
			end
		end
		
		if Ready(_E) and IsRecalling() == false and EValue then
			if IsValid(Minion, 750) and GetDistanceSqr(Minion.pos, myHero.pos) < ERange then 
				if HasPoison(Minion) then
					Block(true)
					Control.CastSpell(HK_E, Minion)
					break
				elseif self:Edmg(Minion) > Minion.health then
					Block(true)
					Control.CastSpell(HK_E, Minion)
					break	
				end
			end
		end
		Block(false)
	end
	end
end

	
function Cassiopeia:KsE()
local target = GetTarget(750)
if target == nil then 
	return
end
	if IsValid(target, 750) then	
		if Cass.ks.E:Value() and Ready(_E) and GetDistanceSqr(target.pos, myHero.pos) < ERange then 
			if self:Edmg(target) > target.health then
				Control.CastSpell(HK_E, target)
				
			elseif HasPoison(target) and self:PEdmg(target) > target.health then
				Control.CastSpell(HK_E, target)
			
			end
		end
	end	
end	
	
function Cassiopeia:KsQ()
local target = GetTarget(900)
if target == nil then 
	return
end
	if IsValid(target, 900) then	
		if Cass.ks.Q:Value() and Ready(_Q) and GetDistanceSqr(target.pos, myHero.pos) < QRange then 
			if self:Qdmg(target) > target.health then
				Control.CastSpell(HK_Q, target.pos)
			
			end
		end
	end
end	

function Cassiopeia:KsW()
local target = GetTarget(900)
if target == nil then 
	return
end
	if IsValid(target, 900) then
		if Cass.ks.W:Value() and Ready(_W) and GetDistanceSqr(target.pos, myHero.pos) < 800 then 
			if self:Wdmg(target) > target.health then
				Control.CastSpell(HK_W, target.pos)
			
			end
		end
	end	
end	

function Cassiopeia:KsIG()
local target = GetTarget(650)
if target == nil then 
	return
end
	if IsValid(target, 650) then		
		if Cass.ks.IG:Value() and GetDistanceSqr(target.pos, myHero.pos) < 600 then 
			if self:Ignitedmg(target) > target.health then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1, target)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2, target)
				end
			end
		end
	end
end	
			
	
function Cassiopeia:AntiCC()
	local Immobile = Cleans(myHero)
	if Immobile then
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost" and Ready(SUMMONER_1) then
			Control.CastSpell(HK_SUMMONER_1, myHero)
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" and Ready(SUMMONER_2) then
			Control.CastSpell(HK_SUMMONER_2, myHero)
		end
	end
end	
	
	function Cassiopeia:Engage()
		local target = GetTarget(1200)
		if target == nil then 
			return
		end
		local fulldmg = self:Qdmg(target) + self:Wdmg(target) + self:Edmg(target) + self:Rdmg(target)
		local Dist = GetDistanceSqr(myHero.pos, target.pos)
		local RCheck = Ready(_R)
		local RTarget, ShouldCast = self:RLogic()
		if Cass.kill.Eng:Value() and IsValid(target, 1200) then
			if EnemiesNear(myHero.pos,825) == 1 and Ready(_R) and Ready(_W) and Ready(_Q) and Ready(_E) then 
				if EnemyInRange(RRange) and ShouldCast >= 1 and fulldmg > target.health then
					Control.CastSpell(HK_R, RTarget)
				end
			end 
			if not Ready(_R) then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerHaste" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHaste" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2)
				end
			end	
			if self:Ignitedmg(target) > target.health and Dist <= 600 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1, target)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2, target)
				end
			end	
			if Ready(_Q) and not Ready(_R) then 
				if Dist < QRange then 
				local pred = GetGamsteronPrediction(target, QData, myHero)
					if GetDistanceSqr(target.pos, myHero.pos) < QRange and pred.Hitchance >= _G.HITCHANCE_HIGH then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				end
			end
			if Ready(_E) and not Ready(_R) then 
				if Dist < ERange then
					Control.CastSpell(HK_E, target)
				end
			end	
			if Ready(_W) and not Ready(_R) then 
				if Dist < MaxWRange and Dist > MinWRange then
				local Pos = GetPred(target, 1500, 0.25 + Game.Latency()/1000)
					if GetDistanceSqr(target.pos, myHero.pos) < MaxWRange then 
						self:CastW(HK_W, Pos)
					end
				end
			end
		end	
	end
	
	
	
	function Cassiopeia:AutoE()
		if Ready(_E) and IsRecalling() == false and myHero.mana/myHero.maxMana > Cass.m.EW:Value()/100 and Cass.w.E:Value() then
			for i = 1, Game.MinionCount() do 
			local Minion = Game.Minion(i) 
				if IsValid(Minion, 690) and GetDistanceSqr(Minion.pos, myHero.pos) < ERange then 
					if HasPoison(Minion) and self:PEdmg(Minion) > Minion.health then 
						Block(true)
						Control.CastSpell(HK_E, Minion)
						break
					elseif self:Edmg(Minion) > Minion.health then 
						Block(true)
						Control.CastSpell(HK_E, Minion)
						break
					end
				end
			end
		end
		Block(false)
	end
					

	function Cassiopeia:Draw()
		if myHero.dead == false and Cass.d.ON:Value() then
			local textPos = myHero.pos:To2D()
			if Cass.d.Lines:Value() then
				local InFace = {}
				for i = 1, Game.HeroCount() do
				local Hero = Game.Hero(i)
					if IsValid(Hero, 850) and self:IsFacing(Hero) then 
						local Vectori = Vector(myHero.pos - Hero.pos)
						local LS = LineSegment(myHero.pos, Hero.pos)
						LS:__draw()
					end
				end
				local RTarget = self:RLogic()
				if RTarget then
					LSS = Circle(Point(RTarget), RTarget.boundingRadius)
					LSS:__draw()
				end
			end
			if Cass.d.Text:Value() then 
				if Cass.w.E:Value() then 
					Draw.Text("Auto E ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
				else
					Draw.Text("Auto E OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
				end
			end
			if Cass.d.Q.ON:Value() then
				Draw.Circle(myHero.pos, 850, Cass.d.Q.Width:Value(), Cass.d.Q.Color:Value())
			end
			if Cass.d.W.ON:Value() then
				Draw.Circle(myHero.pos, 340, Cass.d.W.Width:Value(), Cass.d.W.Color:Value())
				Draw.Circle(myHero.pos, 960, Cass.d.W.Width:Value(), Cass.d.W.Color:Value())
			end
			if Cass.d.E.ON:Value() then
				Draw.Circle(myHero.pos, 750, Cass.d.E.Width:Value(), Cass.d.E.Color:Value())
			end	
			if Cass.d.R.ON:Value() then
				Draw.Circle(myHero.pos, 750, Cass.d.E.Width:Value(), Cass.d.E.Color:Value())
			end			
		end
self:DrawEngage()		
	end
	
function Cassiopeia:DrawEngage()
	 local target = GetTarget(1200)
if target == nil then return end
	
	if EnemiesNear(myHero.pos,1200) == 1 and Ready(_R) and Ready(_W) and Ready(_E) and Ready(_Q) then	
		local fulldmg = self:Qdmg(target) + self:Wdmg(target) + self:Edmg(target) + self:Rdmg(target)
		local textPos = target.pos:To2D()
		if Cass.kill.Eng:Value() and IsValid(target, 1200) and target.isEnemy then
			 if fulldmg > target.health then 
					Draw.Text("Engage PressKey", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
			end
		end
	end
end
	



-------------------------------------------------------------------------------------------------------------------------------------------------------------




class "Kayle"



if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')

function GunbladeDMG() 
    local level = myHero.levelData.lvl
    local damage = ({175,180,184,189,193,198,203,207,212,216,221,225,230,235,239,244,248,253})[level] + 0.30 * myHero.ap
	return damage
end

local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 195, Range = 850, Speed = 500, Collision = false
}



function Kayle:__init()
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end) 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function Kayle:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Kayle", name = "PussyKayle"})

	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "Auto Heal"})
	self.Menu.AutoW:MenuElement({id = "self", name = "Heal self", value = true})
	self.Menu.AutoW:MenuElement({id = "ally", name = "Heal Ally", value = true})
	self.Menu.AutoW:MenuElement({id = "HP", name = "HP Self/Ally", value = 50, min = 0, max = 100, step = 1, identifier = "%"})
	self.Menu.AutoW:MenuElement({id = "Mana", name = "min. Mana", value = 50, min = 0, max = 100, step = 1, identifier = "%"})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})			
	self.Menu.Combo:MenuElement({type = MENU, id = "UseR", name = "Ult Settings"})
	self.Menu.Combo.UseR:MenuElement({id = "self", name = "Ult self", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "ally", name = "Ult Ally", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "HP", name = "HP Self/Ally", value = 40, min = 0, max = 100, step = 1, identifier = "%"})	
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Lasthit Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "Lasthit[Q] Radiant Blast", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "Lasthit[E] Starfire Spellblade", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})		
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.ks:MenuElement({id = "gun", name = "Hextech Gunblade + [Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseIgn", name = "Ignite", value = true})

	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", name = "Activator"})		
	self.Menu.a:MenuElement({id = "gun", name = "Hextech Gunblade in ComboMode", value = true})	
	self.Menu.a:MenuElement({id = "HP", name = "Enemy %HP To Use Gunblade", value = 75, min = 0, max = 100, step = 5, identifier = "%"})

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Kayle:Tick()
	if myHero.dead == false and Game.IsChatOpen() == false then
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
			self:Gunblade()
		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		elseif Mode == "Flee" then
		
		end
		self:KillSteal()
		self:KillStealE()
		self:AutoW()
	end
end	
	



function Kayle:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 500, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 850, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 900, 1, Draw.Color(225, 225, 125, 10))
	end
end

function Kayle:AutoW()
local target = GetTarget(1200)     	
if target == nil then return end		
	if IsValid(target, 1200) and myHero.mana/myHero.maxMana >= self.Menu.AutoW.Mana:Value() / 100 then
		if self.Menu.AutoW.self:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= self.Menu.AutoW.HP:Value()/100 then
				Control.CastSpell(HK_W, myHero)
			end	
		end
		if self.Menu.AutoW.ally:Value() and Ready(_W) then		
			for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
				if unit.isAlly and IsValid(unit, 1000) then
				local Hp = GetPercentHP(unit)
						if Hp <= self.Menu.AutoW.HP:Value() and myHero.pos:DistanceTo(unit.pos) <= 900 then
							Control.CastSpell(HK_W, unit)	
						end	
					end
				end
			end
		end	
	end	


function Kayle:Gunblade()
	local target = GetTarget(1000)     	
	if target == nil then return end
	local Gun = GetItemSlot(myHero, 3146)		
	if IsValid(target, 1000) then	
		if self.Menu.a.gun:Value() and Gun > 0 and Ready(Gun) then
			if target.health/target.maxHealth <= self.Menu.a.HP:Value()/100 and myHero.pos:DistanceTo(target.pos) <= 700 then
				Control.CastSpell(ItemHotKey[Gun], target.pos)
			end
		end
	end
end
				
function Kayle:KillStealE()	
	local target = GetTarget(600)     	
	if target == nil then return end
	local level = myHero.levelData.lvl
	local hp = target.health
	local EDmg = getdmg("E", target, myHero, 1)
	local E2Dmg = getdmg("E", target, myHero, 2)
	local E3Dmg = getdmg("E", target, myHero, 2) + getdmg("E", target, myHero, 3)
	if IsValid(target, 600) then	
		
		if self.Menu.ks.UseE:Value() and Ready(_E) then
			if level >= 1 and level < 6 and EDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 550 then
				Control.CastSpell(HK_E)
		
			
			elseif level >= 6 and level < 16 and E2Dmg >= hp and myHero.pos:DistanceTo(target.pos) <= 550 then
				Control.CastSpell(HK_E)
				
			elseif level >= 16 and E3Dmg >= hp and myHero.pos:DistanceTo(target.pos) <= 550 then
				Control.CastSpell(HK_E)				
			end			
		end	
	end
end	
       
function Kayle:KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end
	local hp = target.health
	local QDmg = getdmg("Q", target, myHero)
	local IGdamage = 80 + 25 * myHero.levelData.lvl
	local GunDmg = GunbladeDMG()
	if IsValid(target, 1000) then	
		
		if self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 850 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end

		if self.Menu.ks.UseIgn:Value() then 
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and myHero.pos:DistanceTo(target.pos) <= 600 then
				if Ready(SUMMONER_1) then
					if IGdamage >= hp + target.hpRegen * 3 then
						Control.CastSpell(HK_SUMMONER_1, target)
					end
				end
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and myHero.pos:DistanceTo(target.pos) <= 600  then
				if Ready(SUMMONER_2) then
					if IGdamage >= hp + target.hpRegen * 3 then
						Control.CastSpell(HK_SUMMONER_2, target)
					end
				end
			end
		end
		local Gun = GetItemSlot(myHero, 3146)
		if self.Menu.ks.gun:Value() and Ready(_Q) and Gun > 0 and Ready(Gun) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if (QDmg + GunDmg) >= hp and myHero.pos:DistanceTo(target.pos) <= 700 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(ItemHotKey[Gun], target.pos)
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end	

function Kayle:Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target, 1200) then
			
		
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 850 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if self.Menu.Combo.UseE:Value() and Ready(_E) then			
			if myHero.pos:DistanceTo(target.pos) <= 400 then			
				Control.CastSpell(HK_E)
	
			end
		end
		
		if Ready(_R) and self.Menu.Combo.UseR.self:Value() then
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.UseR.HP:Value()/100 then 
				Control.CastSpell(HK_R, myHero)
			end
		end
		if Ready(_R) and self.Menu.Combo.UseR.ally:Value() then
			for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
				if unit.isAlly and IsValid(unit, 1000) then
				local enemy = EnemiesAround(unit.pos, 650)			
					if enemy >= 1 and unit.health/unit.maxHealth <= self.Menu.Combo.UseR.HP:Value()/100 and myHero.pos:DistanceTo(unit.pos) <= 900  then
						Control.CastSpell(HK_R, unit)
					end
				end
			end	
		end
	end	
end	

function Kayle:Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target, 1000) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 850 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
		
			if myHero.pos:DistanceTo(target.pos) <= 400 then			
				Control.CastSpell(HK_E)
	
			end
		end
	end
end	

function Kayle:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local level = myHero.levelData.lvl
	local HP = minion.health
	local QDmg = getdmg("Q", minion, myHero)	
	local EDmg = getdmg("E", minion, myHero, 1)
	local E2Dmg = getdmg("E", minion, myHero, 2)
	local E3Dmg = getdmg("E", minion, myHero, 2) + getdmg("E", minion, myHero, 3)
		
		if IsValid(minion, 1000) and minion.team == TEAM_ENEMY and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then					
			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 500 and self.Menu.Clear.UseE:Value() then
				if level >= 1 and level < 6 and EDmg > HP then
					Control.CastSpell(HK_E)
				
				elseif level >= 6 and level < 16 and E2Dmg > HP then
					Control.CastSpell(HK_E)
					
				elseif level >= 16 and E3Dmg > HP then
					Control.CastSpell(HK_E)	
				end
			end
			
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 850 and self.Menu.Clear.UseQ:Value() and QDmg > HP then
				Control.CastSpell(HK_Q, minion.pos)
			end	 
		end
	end
end

function Kayle:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
			
		if IsValid(minion, 1000) and minion.team == TEAM_JUNGLE and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 850 and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end
			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 550 and self.Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E)
			end		
		end
	end
end




-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "Kassadin"



local cancelSpells = {
  ["Caitlyn"] = {
    ["CaitlynAceintheHole"] = {name = "Ace in the Hole"} --R
  },
  ["Darius"] = {
    ["DariusExecute"] = {name = "Noxian Guillotine"} --R
  },
  ["FiddleSticks"] = {
    ["DrainChannel"] = {name = "Drain"},  --W 
    ["Crowstorm"] = {name = "Crowstorm"}  --R 
  },
  ["Gragas"] = {
    ["GragasW"] = {name = "Drunken Rage"} --W 
  },
  ["Janna"] = {
    ["ReapTheWhirlwind"] = {name = "Monsoon"} --R
  },
  ["Karthus"] = {
    ["KarthusFallenOne"] = {name = "Requiem"} --R karthusfallenonecastsound
  },
  ["Katarina"] = {
    ["KatarinaR"] = {name = "Death Lotus"} --R 
  },
  ["Malzahar"] = {
    ["AlZaharNetherGrasp"] = {name = "Nether Grasp"} --R
  },
  ["MasterYi"] = {
    ["Meditate"] = {name = "Meditate"} --W 
  },
  ["MissFortune"] = {
    ["MissFortuneBulletTime"] = {name = "Bullet Time"} --R missfortunebulletsound   
  },
  ["Nunu"] = {
    ["AbsoluteZero"] = {name = "Absolute Zero"} --R
  },
  ["Pantheon"] = {
    ["PantheonE"] = {name = "Heartseeker Strike"}, --E
    ["PantheonRJump"] = {name = "Grand Skyfall"} --R
  },
  ["TwistedFate"] = {
    ["Destiny"] = {name = "Gate"} --R 
  },
  ["Warwick"] = {
    ["InfiniteDuress"] = {name = "Infinite Duress"} --R warwickrsound
  },
  ["Rammus"] = {
    ["PowerBall"] = {name = "Powerball"} --Q 
  }
}
local units = {}
local foundAUnit = false

function Kassadin:__init()
 
  if menu ~= 1 then return end
  menu = 2
  self.passiveTracker = 0
  self.stacks = 0
  qdmg = 0
  edmg = 0
  rdmg = 0
  self:LoadSpells()   	
  self:LoadMenu()                                            
  Callback.Add("Tick", function() self:Tick() end)
  Callback.Add("Draw", function() self:Draw() end) 
 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function Kassadin:LoadSpells()

  Q = { range = 650, delay = 0.25, speed = 1400, width = myHero:GetSpellData(_Q).width, radius = 50, Collision = false }
  W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
  E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
  R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

local Icons = {
["Kassadin"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/PussyKassadinScriptLogo.png",
["Combo"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/ComboScriptLogo.png",
["BlockSpells"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/BlockSpellsScriptLogo.png",
["Escape"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/EscapeScriptLogo.png",
["Harass"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/HarassScriptLogo.png",
["Clear"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/Clear%2BLasthitScriptLogo.png",
["JClear"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/JungleClearScriptLogo.png",
["Activator"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/ActivatorScriptLogo.png",
["Drawings"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/DrawingsScriptLogo.png",
["ks"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/KillStealScriptLogo.png",
["Pred"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/PredScriptLogo.png"
}


function Kassadin:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Kassadin", leftIcon = Icons["Kassadin"]})
 
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.Combo:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
 
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({id = "LastQ", name = "[Q] LastHit Minions", value = true})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Harass:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.Harass:MenuElement({id = "UseR", name = "Poke[R],[E],[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 65, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})         
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.Clear:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Clear:MenuElement({id = "EHit", name = "[E] if x minions", value = 3, min = 1, max = 7})
	self.Menu.Clear:MenuElement({id = "lastQ", name = "[Q] LastHit", value = true})         
	self.Menu.Clear:MenuElement({id = "lastW", name = "[W] LastHit", value = true})  
	self.Menu.Clear:MenuElement({id = "lastR", name = "[R] LastHit[Only if not Enemys near]", value = true})
	self.Menu.Clear:MenuElement({id = "RHit", name = "[R] LastHit if x minions", value = 3, min = 1, max = 7})  
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 50, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})         
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.JClear:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.JClear:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 50, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.ks:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
	self.Menu.ks:MenuElement({id = "UseQR", name = "[Q]then[R]", value = true})
	self.Menu.ks:MenuElement({id = "UseRQ", name = "[R]then[Q]", value = true})	
	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", leftIcon = Icons["Activator"]})		
	self.Menu.a:MenuElement({type = MENU, id = "Zhonyas", name = "Zhonya's + StopWatch"})
	self.Menu.a.Zhonyas:MenuElement({id = "ON", name = "Enabled", value = true})
	self.Menu.a.Zhonyas:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})
	self.Menu.a:MenuElement({type = MENU, id = "Seraphs", name = "Seraph's Embrace"})
	self.Menu.a.Seraphs:MenuElement({id = "ON", name = "Enabled", value = true})
	self.Menu.a.Seraphs:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})
 
	--BlockSpellsMenu
	self.Menu:MenuElement({type = MENU, id = "block", leftIcon = Icons["BlockSpells"]})
	for i = 1, Game.HeroCount() do
	local unit = Game.Hero(i)
		if unit.team ~= myHero.team then
		units[#units + 1] = unit
			if cancelSpells[unit.charName] then
			foundAUnit = true
		self.Menu.block:MenuElement({type = MENU, id = unit.charName, name = unit.charName})
				for spell, sname in pairs(cancelSpells[unit.charName]) do
				self.Menu.block[unit.charName]:MenuElement({id = spell, name = sname.name, value = true})
  
				end
			end
		end
	end
	if not foundAUnit then
	self.Menu.block:MenuElement({id = "none", name = "No blockable Spell found", type = SPACE}) 
	end 

	--EscapeMenu
	self.Menu:MenuElement({type = MENU, id = "evade", leftIcon = Icons["Escape"]})
	self.Menu.evade:MenuElement({type = MENU, id = "Life", name = "Auto Escape Menu"})	
	self.Menu.evade.Life:MenuElement({id = "UseR", name = "AutoEscape[R] to Ally or Tower", value = true})
	self.Menu.evade.Life:MenuElement({id = "MinR", name = "Min Life to Escape", value = 20, min = 0, max = 100, identifier = "%"})	
	self.Menu.evade:MenuElement({type = MENU, id = "Flee", name = "Manual Escape Menu"})	
	self.Menu.evade.Flee:MenuElement({id = "UseR", name = "Use[R] to Ally or Tower [EscapeKey]", value = true})
	self.Menu.evade.Flee:MenuElement({id = "UseRm", name = "Use[R] to Mouse.Pos [EscapeKey]", value = true})	
	self.Menu.evade.Flee:MenuElement({id = "Fleekey", name = "Escape key", key = string.byte("A")})
	
	
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable on Target and Minimap", value = true})	
end

function Kassadin:Tick()
	if myHero.dead == false and Game.IsChatOpen() == false then	
	self:Activator()
	self:EscapeR()
	self:OnBuff(myHero)
	self:KillSteal()

	
	if Ready(_Q) and foundAUnit then     
		for i = 1, #units do
		local unit = units[i]
		
			if IsValid(unit) and unit.isEnemy and unit.isChanneling == true and unit.activeSpell.valid then
			local spellToCancel = cancelSpells[unit.charName]
			local activeSpell = unit.activeSpell.name
			if spellToCancel == nil then return end
			local ignore = (unit.activeSpell.name == "PowerBall") or (unit.activeSpell.name == "PantheonE") or (unit.activeSpell.name == "Meditate") or (unit.activeSpell.name == "GragasW") or (unit.activeSpell.name == "FiddleSticksDrain")	
				if spellToCancel[activeSpell] and self.Menu.block[unit.charName][activeSpell]:Value() then
					if myHero.pos:DistanceTo(unit.pos) <= 650 then
						Control.CastSpell(HK_Q, unit)
					elseif Ready(_R) and myHero.pos:DistanceTo(unit.pos) > 650 and myHero.pos:DistanceTo(unit.pos) <= 1150 then
						if ignore then return end
						Control.CastSpell(HK_R, unit.pos)
						Control.CastSpell(HK_Q, unit)
					end
				end
			end    
		end
	end
	if self.Menu.evade.Flee.Fleekey:Value() then
		self:Flee()
	end
	if self.Menu.evade.Flee.Fleekey:Value() then
		self:FleeR()
	end	
	

	local Mode = GetMode()
		if Mode == "Combo" then
		self:Combo()
		self:Combo1()
		self:FullRKill()
		if self.Menu.Combo.UseAW:Value() then
			self:AutoW()
		end
		elseif Mode == "Harass" then
		self:Harass()
		self:LasthitQ()
		if self.Menu.Harass.UseAW:Value() then
			self:AutoW()
			self:AutoW1()
		end	
		elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
		if self.Menu.Clear.UseAW:Value() then
			self:AutoW1()
		end
		if self.Menu.JClear.UseAW:Value() then
			self:AutoW1()
		end	
		elseif Mode == "Flee" then
		
		end	
	end
end

function Kassadin:Activator()
if myHero.dead then return end
			--Zhonyas
	if EnemiesAround(myHero.pos,1000) then
		if self.Menu.a.Zhonyas.ON:Value()  then
		local Zhonyas = GetItemSlot(myHero, 3157)
			if Zhonyas > 0 and Ready(Zhonyas) then 
				if myHero.health/myHero.maxHealth < self.Menu.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
			--Stopwatch
		if self.Menu.a.Zhonyas.ON:Value() then
		local Stop = GetItemSlot(myHero, 2420)
			if Stop > 0 and Ready(Stop) then 
				if myHero.health/myHero.maxHealth < self.Menu.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Stop])
				end
			end
		end
			--Seraph's Embrace
		if self.Menu.a.Seraphs.ON:Value() then
		local Seraphs = GetItemSlot(myHero, 3040)
			if Seraphs > 0 and Ready(Seraphs) then
				if myHero.health/myHero.maxHealth < self.Menu.a.Seraphs.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Seraphs])
				end
			end
		end
	end
end

function Kassadin:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 500, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, Q.range, 1, Draw.Color(225, 225, 0, 10))
	end
  	local target = GetTarget(20000)
	if target == nil then return end	
	local hp = target.health
	local Dmg = (getdmg("Q", target)), (getdmg("E", target)), (getdmg("Q", target) + getdmg("R", target)), (getdmg("Q", target) + getdmg("E", target)), (getdmg("Q", target) + getdmg("E", target) + getdmg("R", target)), (getdmg("Q", target) + getdmg("W", target) + getdmg("E", target) + getdmg("R", target))
	local QWEdmg = getdmg("Q", target) + getdmg("W", target) + getdmg("E", target)
	local FullReady = Ready(_Q), Ready(_W), Ready(_E), Ready(_R)
	local QWEReady = Ready(_Q), Ready(_W), Ready(_E)	
	if IsValid(target, 20000) and self.Menu.Drawing.Kill:Value() then
				
		if Ready(_R) and getdmg("R", target) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_R) and (getdmg("R", target) + getdmg("R", target, myHero, 2)) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
		if FullReady and (getdmg("R", target) + getdmg("R", target, myHero, 2) + QWEdmg) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end	
		if Dmg > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))			
		end
		if QWEReady and QWEdmg > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end
	end
end

function Kassadin:OnBuff(unit)

  if unit.buffCount == nil then self.passiveTracker = 0 self.stacks = 0 return end
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    
    if buff.name == "forcepulsecancast" then
      self.passiveTracker = buff.count
	end  
    if buff.name == "RiftWalk" then
      self.stacks = buff.count      
    end     
  end
end

function Kassadin:ClearLogic()
  local EPos = nil 
  local Most = 0 
    for i = 1, Game.MinionCount() do
    local Minion = Game.Minion(i)
      if IsValid(Minion, 650) then
        local Count = GetMinionCount(650, Minion)
        if Count > Most then
          Most = Count
          EPos = Minion.pos
        end
      end
    end
    return EPos, Most
end 

function Kassadin:KillSteal()
	local target = GetTarget(1150)
	if target == nil then return end
	local hp = target.health
	local RDmg = getdmg("R", target)
	local QDmg = getdmg("Q", target)
	if IsValid(target, 1150) then
		
		if self.Menu.ks.UseQ:Value() and Ready(_Q) then
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 650 then
				Control.CastSpell(HK_Q, target.pos)					
			end				
		end
	
		if self.Menu.ks.UseR:Value() and Ready(_R) and not IsUnderTurret(target) then
			if RDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 500 then
				Control.CastSpell(HK_R, target)
			end
		end
		if self.Menu.ks.UseQR:Value() and Ready(_R) and Ready(_Q) then
			if (RDmg + QDmg) >= hp and myHero.pos:DistanceTo(target.pos) <= 500 and not IsUnderTurret(target) then
				Control.CastSpell(HK_Q, target.pos)
				Control.CastSpell(HK_R, target)
								
			end
		end	
		if self.Menu.ks.UseRQ:Value() and Ready(_R) and Ready(_Q) then
			if (RDmg + QDmg) >= hp and myHero.pos:DistanceTo(target.pos) < 1150 and myHero.pos:DistanceTo(target.pos) > 650 and not IsUnderTurret(target) then
				Control.CastSpell(HK_R, target)
				Control.CastSpell(HK_Q, target.pos)
								
			end
		end
	end
end	

function Kassadin:AutoW()  
	local target = GetTarget(300)
	if target == nil then return end
	if IsValid(target, 300) and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 300 then
		Control.CastSpell(HK_W)
	end
end	
	
function Kassadin:AutoW1()	
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local TEAM_ENEMY = 300 - myHero.team 
	local TEAM_JUNGLE = 300
	if minion.team == TEAM_ENEMY or minion.team == TEAM_JUNGLE then
	if minion == nil then return end	
	if minion and not minion.dead and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 300 then
		Control.CastSpell(HK_W)
		end
	end
	end
end	


	
function Kassadin:Combo()
local target = GetTarget(650)
if target == nil then return end
	
	if IsValid(target, 650) and self.Menu.Combo.UseQ:Value() and Ready(_Q) then	
		if myHero.pos:DistanceTo(target.pos) < 650 then
			Control.CastSpell(HK_Q, target.pos)
			
		end	
	end	
	
	if IsValid(target, 600) and self.passiveTracker >= 1 and self.Menu.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 600 then	
		Control.CastSpell(HK_E, target)
	end
end	
	

function Kassadin:EscapeR()
	local target = GetTarget(2000)
	if target == nil then return end
	if IsValid(target, 2000) and self.Menu.evade.Life.UseR:Value() and Ready(_R) and 100*myHero.health/myHero.maxHealth <= self.Menu.evade.Life.MinR:Value() and myHero.pos:DistanceTo(target.pos) <= 600 then 
		for i,ally in pairs(GetAllyHeroes()) do
			if self:ValidTarget(ally, 2000) and myHero.pos:DistanceTo(ally.pos) < 2000 and myHero.pos:DistanceTo(ally.pos) > 500 then
				if GetEnemyCount(1000, ally) < 1 then
				Control.CastSpell(HK_R, ally.pos)
				end
			end	
		end
		for i,tower in pairs(GetAllyTurret()) do
			if IsValid(tower, 2000) and myHero.pos:DistanceTo(tower.pos) < 2000 and myHero.pos:DistanceTo(tower.pos) > 750 then
				Control.CastSpell(HK_R, tower.pos)
			end	
		end
	end
end
	

function Kassadin:Flee()
	if self.Menu.evade.Flee.UseR:Value() and Ready(_R) then		
	for i,ally in pairs(GetAllyHeroes()) do
			if IsValid(ally, 2000) and myHero.pos:DistanceTo(ally.pos) < 2000 and myHero.pos:DistanceTo(ally.pos) > 500 then
				if GetEnemyCount(1000, ally) < 1 then
					Control.CastSpell(HK_R, ally)
				end
			end
		end	
		for i,tower in pairs(GetAllyTurret()) do
			if IsValid(tower, 2000) and myHero.pos:DistanceTo(tower.pos) < 2000 and myHero.pos:DistanceTo(tower.pos) > 750 then
				Control.CastSpell(HK_R, tower)
					
			end	
		end
	end
end	

function Kassadin:FleeR()
	if self.Menu.evade.Flee.UseRm:Value() and Ready(_R) then				
		Control.CastSpell(HK_R)
	end
end			

function Kassadin:Harass()	
local target = GetTarget(1100)
if target == nil then return end	
local ready = Ready(_Q), Ready(_E), Ready(_R)

	if IsValid(target, 1100) then
	
		if self.Menu.Harass.UseR:Value() and ready and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then	
			if myHero.pos:DistanceTo(target.pos) <= 1000 and myHero.pos:DistanceTo(target.pos) >= 700 then	
				if self.stacks == 0 and self.passiveTracker >= 1 and not IsUnderTurret(target) then	
					Control.CastSpell(HK_R, target)
					Control.CastSpell(HK_E, target)
					Control.CastSpell(HK_Q, target.pos)
						
				end				
			end
		end
		if self.Menu.Harass.UseE:Value() and Ready(_E) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) and myHero.pos:DistanceTo(target.pos) <= 550 then
			if self.passiveTracker >= 1 then		
				Control.CastSpell(HK_E, target)
			end
		end
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) and myHero.pos:DistanceTo(target.pos) <= 650 then
			Control.CastSpell(HK_Q, target)
		end 
	end
end

function Kassadin:LasthitQ()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local target = GetTarget(650)
		if target == nil then
		local TEAM_ALLY = myHero.team
		local TEAM_ENEMY = 300 - myHero.team
		local Qdamage = getdmg("Q", minion)
			if minion.isEnemy and minion.team == TEAM_ENEMY and not minion.dead then	
				if IsValid(minion,650) and Qdamage >= minion.health and self.Menu.Harass.LastQ:Value() then
					if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 and myHero.pos:DistanceTo(minion.pos) > myHero.range then
						Control.CastSpell(HK_Q, minion)
					end
				end
			end
		end
	end
end	

		
function Kassadin:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local TEAM_ALLY = myHero.team
	local TEAM_ENEMY = 300 - myHero.team
	local Qdamage = getdmg("Q", minion)
	local Wdamage = getdmg("W", minion)	
	local Rdamage = getdmg("R", minion)	
	if minion.isEnemy and minion.team == TEAM_ENEMY and not minion.dead then	
		if IsValid(minion,650) and Qdamage >= minion.health then
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.Clear.lastQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) > myHero.range then
				Control.CastSpell(HK_Q, minion)
			end
		end
		if IsValid(minion,150) and Wdamage >= minion.health then
			if self.Menu.Clear.lastW:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= myHero.range then
				Control.CastSpell(HK_W, minion)
			end
		end	
		local target = GetTarget(1000)
		if target == nil then
		if IsValid(minion,500) and Rdamage >= minion.health then
			if Ready(_R) and self.stacks == 0 and myHero.pos:DistanceTo(minion.pos) < 500 and self.Menu.Clear.lastR:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) > myHero.range then	
				local EPos, Count = self:ClearLogic()	
				if Count >= self.Menu.Clear.RHit:Value() then
					Control.CastSpell(HK_R, minion)
				
				end
			end
		end
		end
		
		if IsValid(minion,650) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.Clear.UseQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) > myHero.range then
			Control.CastSpell(HK_Q, minion)
			
		end
		
		if IsValid(minion,600) and Ready(_E) and self.passiveTracker >= 1 and myHero.pos:DistanceTo(minion.pos) < 600 and self.Menu.Clear.UseE:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) > myHero.range then
		local EPos, Count = self:ClearLogic()
				if Count >= self.Menu.Clear.EHit:Value() then
						Control.CastSpell(HK_E, EPos)
				
				end
			end  
		end
	end
end

function Kassadin:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	local TEAM_JUNGLE = 300
		if minion.isEnemy and minion.team == TEAM_JUNGLE and not minion.dead then	
			if IsValid(minion,650) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.JClear.UseQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 ) then
				CastSpell(HK_Q, minion)
			end
			if IsValid(minion,500) and Ready(_R) and myHero.pos:DistanceTo(minion.pos) < 500 and self.Menu.JClear.UseR:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 ) then
				CastSpell(HK_R,minion.pos)			
			end
			if IsValid(minion,600) and Ready(_E) and self.passiveTracker >= 1 and myHero.pos:DistanceTo(minion.pos) < 600 and self.Menu.JClear.UseE:Value() then
				CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

function Kassadin:FullRKill()
	local target = GetTarget(2500)
	if target == nil then return end
	if self.Menu.Combo.UseR:Value() and Ready(_R) then
	local hp = target.health
	local dist = myHero.pos:DistanceTo(target.pos)
	local level = myHero:GetSpellData(_R).level
	local Fulldmg1 = CalcMagicalDamage(myHero, target,(({120, 150, 180})[level] + 0.5 * myHero.ap) + 0.03 * myHero.maxMana)
	local Fulldmg2 = CalcMagicalDamage(myHero, target,(({160, 200, 240})[level] + 0.6 * myHero.ap) + 0.04 * myHero.maxMana)
	local Fulldmg3 = CalcMagicalDamage(myHero, target,(({200, 250, 300})[level] + 0.7 * myHero.ap) + 0.05 * myHero.maxMana)
	local Fulldmg4 = CalcMagicalDamage(myHero, target,(({240, 300, 360})[level] + 0.8 * myHero.ap) + 0.06 * myHero.maxMana)
	local QWEdmg = getdmg("Q", target) + getdmg("W", target) + getdmg("E", target)	
	
	if IsValid(target, 2500) then	
			if getdmg("R", target) > hp then
				if dist < 500 and self.stacks == 0 then 
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 1 then
				if Fulldmg1 > hp and dist < 500 then
				Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 2 then
				if Fulldmg2 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 3 then
				if Fulldmg3 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 4 then
				if Fulldmg4 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end		
	-----------------------------------------------------	
			if (getdmg("R", target) + QWEdmg) > hp then
				if dist < 500 and self.stacks == 0 then 
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 1 then
				if (Fulldmg1 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 2 then
				if (Fulldmg2 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 3 then
				if (Fulldmg3 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 4 then
				if (Fulldmg4 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			
	---------------------------------------------------------------
		local Full1 = Fulldmg1 + QWEdmg
		if getdmg("R", target) > target.health or Full1 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 1000 and myHero.pos:DistanceTo(target.pos) > 500 then
				Control.CastSpell(HK_R, target)
					
					
				
			end
		end	
		local Full2 = Fulldmg2 + QWEdmg			
		if getdmg("R", target) > target.health or Full2 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 1500 and myHero.pos:DistanceTo(target.pos) > 1000 then
				Control.CastSpell(HK_R, target)
					
					
				
			end
		end
		local Full3 = Fulldmg3 + QWEdmg			
		if getdmg("R", target) > target.health or Full3 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 2000 and myHero.pos:DistanceTo(target.pos) > 1500 then
				Control.CastSpell(HK_R, target)
					
				
				
			end
		end	
		local Full4 = Fulldmg4 + QWEdmg		
		if getdmg("R", target) > target.health or Full4 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 2500 and myHero.pos:DistanceTo(target.pos) > 2000 then
				Control.CastSpell(HK_R, target)
					
					
			end
		end
	end
end
end
	
function Kassadin:Combo1()
	local target = GetTarget(2000)
	if target == nil then return end
	local hp = target.health
	local dist = myHero.pos:DistanceTo(target.pos)
	local qdmg = getdmg("Q", target) 		
	local wdmg = getdmg("W", target) 
	local edmg = getdmg("E", target) 
	local rdmg = getdmg("R", target) 
if IsValid(target, 2000) then 

	if Ready(_Q) and self.Menu.Combo.UseQ:Value() then 
		if dist < 650 and qdmg > hp then
			Control.CastSpell(HK_Q, target.pos)
	
		end
	end
	if Ready(_E) and self.Menu.Combo.UseE:Value() then	
		if dist < 600 and edmg > hp and self.passiveTracker >= 1 then	
			Control.CastSpell(HK_E, target)
		
		end
	end

	if Ready(_E) and Ready(_Q) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() then	
		if dist < 600 and (qdmg+edmg) > hp then
	
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
		
		end
	end	
	
	if Ready(_Q) and Ready(_R) and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() then	
		if dist < 500 and (rdmg+qdmg) > hp then
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_Q, target.pos)
				
		end
	end
	if Ready(_E) and Ready(_Q) and Ready(_R) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() then	
		if dist < 500 and (qdmg+edmg+rdmg) > hp then	
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
				
		end
	end
	if Ready(_E) and Ready(_Q) and Ready(_R) and Ready(_W) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() and self.Menu.Combo.UseW:Value() then	
		if dist < 500 and (qdmg+edmg+rdmg+wdmg) > hp then	
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
			Control.CastSpell(HK_W)	
		end
	end
	local Killable = (qdmg > hp and Ready(_Q)), (edmg > hp and Ready(_E)), (rdmg+qdmg > hp and Ready(_Q)), (qdmg+edmg > hp and Ready(_Q) and Ready(_E)), (qdmg+edmg+rdmg > hp and Ready(_Q) and Ready(_E)), (qdmg+edmg+rdmg+wdmg > hp and Ready(_Q) and Ready(_E) and Ready(_W))
	if Ready(_R) and self.Menu.Combo.UseR:Value() then
		if Killable and dist > 650 and dist < 2000 then
			Control.CastSpell(HK_R, target)
				
		end
	end
end
end	

function OnDraw()

	local Spells = myHero:GetSpellData(_Q).level < 1  
	local textPos = myHero.pos:To2D()
	if foundAUnit and Spells then
		Draw.Text("Blockable Spell Found", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
	end
end	


-------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Malzahar"



if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')

local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 1.0, Radius = 85, Range = 900, Speed = 3200, Collision = false
}

function Malzahar:__init()

  if menu ~= 1 then return end
  menu = 2   	
  self:LoadMenu()                                            
  Callback.Add("Tick", function() self:Tick() end)
  Callback.Add("Draw", function() self:Draw() end) 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function Malzahar:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Malzahar", name = "PussyMalzahar"})

	--AutoQ
	self.Menu:MenuElement({type = MENU, id = "AutoQ", name = "Auto[Q] on Immobile Target"})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})		
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})			
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R] Nether Grasp", value = false})	
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 2, min = 1, max = 6})  	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "ks"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})	
	self.Menu.ks:MenuElement({id = "UseW", name = "[W] Malefic Visions", value = true})			
	self.Menu.ks:MenuElement({id = "UseR", name = "[R] Void Swarm", value = true})
	self.Menu.ks:MenuElement({id = "full", name = "Full Combo", value = true})	
	self.Menu.ks:MenuElement({id = "UseIgn", name = "Ignite", value = true})

	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", name = "Activator"})		
	self.Menu.a:MenuElement({id = "ON", name = "Zhonyas/StopWatch", value = true})	
	self.Menu.a:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Malzahar:Tick()
	if myHero.dead == false and Game.IsChatOpen() == false then
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()

		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		elseif Mode == "Flee" then
		
		end	
	self:Activator()
	self:KillSteal()
	self:AutoQ()

	
	end
end 

function Malzahar:AutoQ()
local target = GetTarget(1000)     	
if target == nil then return end	
local pred = GetGamsteronPrediction(target, QData, myHero)	
	if IsValid(target,1000) and self.Menu.AutoQ.UseQ:Value() and Ready(_Q) then
		if IsImmobileTarget(target) and myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= _G.HITCHANCE_HIGH then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end	
	end
end

function Malzahar:Activator()

			--Zhonyas
	if EnemiesAround(myHero.pos,2000) then	
		if self.Menu.a.ON:Value() then
		local Zhonyas = GetItemSlot(myHero, 3157)
			if Zhonyas > 0 and Ready(Zhonyas) then 
				if myHero.health/myHero.maxHealth <= self.Menu.a.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
			--Stopwatch
		if self.Menu.a.ON:Value() then
		local Stop = GetItemSlot(myHero, 2420)
			if Stop > 0 and Ready(Stop) then 
				if myHero.health/myHero.maxHealth <= self.Menu.a.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Stop])
				end
			end
		end
	end
end	
			


function Malzahar:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 700, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 850, 1, Draw.Color(225, 225, 125, 10))
	end
end
       


function Malzahar:KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end
	local ready = Ready(_Q) and Ready(_E) and Ready(_W) and Ready(_R)
	local hp = target.health
	local QDmg = getdmg("Q", target, myHero)
	local EDmg = getdmg("E", target, myHero)
	local WDmg = getdmg("W", target, myHero)
	local RDmg = getdmg("R", target, myHero)
	local fullDmg = QDmg + EDmg + WDmg + RDmg
	local IGdamage = 80 + 25 * myHero.levelData.lvl
	if IsValid(target,1000) then	
		
		if self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.ks.UseE:Value() and Ready(_E) then
			if EDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 650 then
				Control.CastSpell(HK_E, target)
	
			end
		end
		if self.Menu.ks.UseW:Value() and Ready(_W) then
			if WDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 650 then
				Control.CastSpell(HK_W, target.pos)
	
			end
		end
		if self.Menu.ks.UseR:Value() and Ready(_R) then
			if RDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 700 then
				Control.CastSpell(HK_R, target)
	
			end
		end
		if self.Menu.ks.full:Value() and ready then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if (fullDmg + IGdamage) >= hp and myHero.pos:DistanceTo(target.pos) <= 650 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				DelayAction(function()
				Control.CastSpell(HK_E, target)				
				Control.CastSpell(HK_Q, pred.CastPosition)
				Control.CastSpell(HK_W, target.pos)
				Control.CastSpell(HK_R, target)
				end, 0.05)
			elseif fullDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 650 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				DelayAction(function()
				Control.CastSpell(HK_E, target)				
				Control.CastSpell(HK_Q, pred.CastPosition)
				Control.CastSpell(HK_W, target.pos)
				Control.CastSpell(HK_R, target)
				end, 0.05)	
			end
		end
		if self.Menu.ks.UseIgn:Value() then 
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and myHero.pos:DistanceTo(target.pos) <= 600 then
				if Ready(SUMMONER_1) then
					if IGdamage >= hp + target.hpRegen * 3 then
						Control.CastSpell(HK_SUMMONER_1, target)
					end
				end
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and myHero.pos:DistanceTo(target.pos) <= 600  then
				if Ready(SUMMONER_2) then
					if IGdamage >= hp + target.hpRegen * 3 then
						Control.CastSpell(HK_SUMMONER_2, target)
					end
				end
			end
		end
	end
end	


function Malzahar:Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target,1000) then

		if self.Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 650 then 
				Control.CastSpell(HK_W, target.pos) 
			end
		end			
		
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if self.Menu.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 650 then			
				Control.CastSpell(HK_E, target)
	
			end
		end
		
		if Ready(_R) and self.Menu.Combo.UseR:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 700 then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	




function Malzahar:Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target,1000) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 650 then			
				Control.CastSpell(HK_E, target)
	
			end
		end
		if self.Menu.Harass.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 650 then			
				Control.CastSpell(HK_W, target.pos)
	
			end
		end
	end
end	




function Malzahar:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local TEAM_ALLY = myHero.team
	local TEAM_ENEMY = 300 - myHero.team
		if IsValid(minion, 1000) and minion.team == TEAM_ENEMY and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then					
			local count = GetMinionCount(650, minion)
			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 650 and self.Menu.Clear.UseE:Value() and count >= self.Menu.Clear.UseEM:Value() then
				Control.CastSpell(HK_E, minion)
			end
			
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 900 and self.Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	

			if Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 650 and self.Menu.Clear.UseW:Value() then
				Control.CastSpell(HK_W, minion.pos)
			end  
		end
	end
end

function Malzahar:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	local TEAM_JUNGLE = 300
		if IsValid(minion, 1000) and minion.team == TEAM_JUNGLE and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 900 and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 650 and self.Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion)
			end
			if Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 650 and self.Menu.JClear.UseW:Value() then
				Control.CastSpell(HK_W, minion.pos)
			end			
		end
	end
end



-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Neeko"



function Neeko:__init()

	if menu ~= 1 then return end
	menu = 2
	self:LoadSpells()   	
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end) 
 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function Neeko:LoadSpells()
	
	Q = {range = 800, width = 225, delay = 0.25, speed = 500, collision = false}    
	E = {range = 1000, width = 70, delay = 0.25, speed = 1300, collision = false}   


end




local Icons = {

["Combo"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/ComboScriptLogo.png",
["Escape"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/EscapeScriptLogo.png",
["Harass"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/HarassScriptLogo.png",
["Clear"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/Clear%2BLasthitScriptLogo.png",
["JClear"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/JungleClearScriptLogo.png",
["Activator"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/ActivatorScriptLogo.png",
["Drawings"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/DrawingsScriptLogo.png",
["ks"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/KillStealScriptLogo.png"
}


function Neeko:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Neeko", name = "PussyNeeko"})

	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})	
	self.Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E] 2-5 Targets", value = true})	
 
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})	
	self.Menu.Combo:MenuElement({id = "PredQ", name = "HitChance[Q] [1]=low [5]=high", value = 1, min = 1, max = 5})	
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.Combo:MenuElement({id = "PredE", name = "HitChance[E] [1]=low [5]=high", value = 2, min = 1, max = 5})	
	--UltSettings
	self.Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	--[W]+[R]
	self.Menu.Combo.Ult:MenuElement({type = MENU, id = "WR", name = "Check NeekoRange"})	
	self.Menu.Combo.Ult.WR:MenuElement({id = "UseR", name = "[R]+[W]", value = true, tooltip = "If [W] not Ready then only [R]"})
 	self.Menu.Combo.Ult.WR:MenuElement({id = "RHit", name = "min. Targets", value = 2, min = 1, max = 5})	
	--Ult Ally Range
	self.Menu.Combo.Ult:MenuElement({type = MENU, id = "Ally", name = "Check AllyRange"})
	self.Menu.Combo.Ult.Ally:MenuElement({id = "UseR2", name = "Flash+[R]+[W] 2-5Targets", value = true, tooltip = "Check Enemys in Ally Range"})
	--Ult Immobile
	self.Menu.Combo.Ult:MenuElement({type = MENU, id = "Immo", name = "Ult Immobile"})	
	self.Menu.Combo.Ult.Immo:MenuElement({id = "UseR3", name = "Flash+[R]+[W]", value = true, tooltip = "Check Immobile Targets"})
 	self.Menu.Combo.Ult.Immo:MenuElement({id = "UseR3M", name = "min. Immobile Targets", value = 2, min = 1, max = 5})
	--Ult 1vs1
	self.Menu.Combo.Ult:MenuElement({type = MENU, id = "One", name = "1vs1"})	
	self.Menu.Combo.Ult.One:MenuElement({id = "UseR1", name = "[R]+[W] If Killable", value = true, tooltip = "If [W] not Ready then only [R]"})	
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({type = MENU, id = "LH", name = "LastHit"})	
	self.Menu.Harass.LH:MenuElement({id = "UseQL", name = "LastHit[Q] Minions", value = true, tooltip = "There is no Enemy nearby"})	
	self.Menu.Harass.LH:MenuElement({id = "UseQLM", name = "min. Minions", value = 2, min = 1, max = 6})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})
	self.Menu.Harass:MenuElement({id = "PredQ", name = "HitChance[Q] [1]=low [5]=high", value = 1, min = 1, max = 5})	
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.Harass:MenuElement({id = "PredE", name = "HitChance[E] [1]=low [5]=high", value = 2, min = 1, max = 5})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQL", name = "LastHit[Q] Blooming Burst", value = true})	
	self.Menu.Clear:MenuElement({id = "UseQLM", name = "LastHit[Q] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})  
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 3, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})
	self.Menu.ks:MenuElement({id = "PredQ", name = "HitChance[Q] [1]=low [5]=high", value = 1, min = 1, max = 5})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.ks:MenuElement({id = "PredE", name = "HitChance[E] [1]=low [5]=high", value = 2, min = 1, max = 5})	
	self.Menu.ks:MenuElement({id = "UseEQ", name = "[E]+[Q]", value = true})

	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", leftIcon = Icons["Activator"]})		
	self.Menu.a:MenuElement({id = "ON", name = "Protobelt all UltSettings", value = true, tooltip = "Free Flash"})	
	self.Menu.a:MenuElement({type = MENU, id = "Zhonyas", name = "Zhonya's + StopWatch"})
	self.Menu.a.Zhonyas:MenuElement({id = "ON", name = "Enabled", value = true})
	self.Menu.a.Zhonyas:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})

 

	--EscapeMenu
	self.Menu:MenuElement({type = MENU, id = "evade", leftIcon = Icons["Escape"]})	
	self.Menu.evade:MenuElement({id = "UseW", name = "Auto[W] Spawn Clone", value = true})
	self.Menu.evade:MenuElement({id = "Min", name = "Min Life to Spawn Clone", value = 30, min = 0, max = 100, identifier = "%"})	
	self.Menu.evade:MenuElement({id = "gank", name = "Auto[W] Spawn Clone Incomming Gank", value = true})
	
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})
end

function Neeko:Tick()
	if myHero.dead == false and Game.IsChatOpen() == false then
	
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
			self:checkUltSpell()
			self:AutoR()
			self:AutoR1()
		elseif Mode == "Harass" then
			self:Harass()
			for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local TEAM_ALLY = myHero.team
			local TEAM_ENEMY = 300 - myHero.team
			local target = GetTarget(1000)
				if target == nil then	
					if minion.team == TEAM_ENEMY and not minion.dead and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then	
						local count = GetMinionCount(225, minion)			
						local hp = minion.health
						local QDmg = getdmg("Q", minion, myHero)
						if IsValid(minion,800) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 800 and self.Menu.Harass.LH.UseQL:Value() and count >= self.Menu.Harass.LH.UseQLM:Value() and hp <= QDmg then
							Control.CastSpell(HK_Q, minion)
						end	 
					end
				end
			end
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		elseif Mode == "Flee" then
		
		end	
		self:Activator()
		self:EscapeW()
		self:KillSteal()
		self:GankW()
		self:AutoE()
	end
end 

function Neeko:Activator()
if myHero.dead then return end
			--Zhonyas
	if EnemiesAround(myHero.pos,2000) then
	local hp = myHero.health	
		if self.Menu.a.Zhonyas.ON:Value()  then
		local Zhonyas = GetItemSlot(myHero, 3157)
			if Zhonyas > 0 and Ready(Zhonyas) then 
				if hp <= self.Menu.a.Zhonyas.HP:Value() then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
			--Stopwatch
		if self.Menu.a.Zhonyas.ON:Value() then
		local Stop = GetItemSlot(myHero, 2420)
			if Stop > 0 and Ready(Stop) then 
				if hp <= self.Menu.a.Zhonyas.HP:Value() then
					Control.CastSpell(ItemHotKey[Stop])
				end
			end
		end
	end
end	
			


function Neeko:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 600, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawing.DrawE:Value()) and Ready(_E) then
    Draw.Circle(myHero, 1000, 1, Draw.Color(225, 225, 125, 10))
	end
	local target = GetTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Drawing.Kill:Value() and not target.dead then
	local hp = target.health	
		if Ready(_Q) and getdmg("Q", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_E) and getdmg("E", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
		if Ready(_E) and Ready(_Q) and (getdmg("E", target) + getdmg("Q", target)) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end	
	end
end
       
function Neeko:ValidTarget(unit,range) 
  return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal 
end

			
function Neeko:AutoE()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target,1000) and self.Menu.AutoE.UseE:Value() and Ready(_E)	then	
	local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
	local targetCount = HPred:GetLineTargetCount(myHero.pos, aimPosition, E.delay, E.speed, E.width, false)	
		if myHero.pos:DistanceTo(target.pos) <= 1000 and hitRate and hitRate >= 1 and targetCount >= 2 then
			Control.CastSpell(HK_E, aimPosition)
		end
	end
end


function Neeko:checkUltSpell()
local target = GetTarget(1500)     	
if target == nil then return end

if IsValid(target,1000) then
local Protobelt = GetItemSlot(myHero, 3152)		
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
		if  Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt1()
			self:Immo1()
			self:Proto()
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
		if Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt1()
			self:Immo1()
			self:Proto()	
		end	
	end

	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
		if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt2()
			self:Immo2()
			self:Proto()	
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
		if  Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt2()
			self:Immo2()
			self:Proto()	
		end	
	end
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
		if  Ready(_R) and Ready(_W) and (Protobelt > 0 and not Ready(Protobelt) or Protobelt == 0) then
			self:AutoUlt3()
			self:Immo3()
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
		if  Ready(_R) and Ready(_W) and (Protobelt > 0 and not Ready(Protobelt) or Protobelt == 0) then
			self:AutoUlt3()
			self:Immo3()
		end	
	end
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and not Ready(SUMMONER_1) then
		if  Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt4()
			self:Immo4()
			self:Proto()	
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and not Ready(SUMMONER_2) then
		if Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt4()
			self:Immo4()
			self:Proto()	
		end	
	end	
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and not Ready(SUMMONER_1) then
		if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt5()
			self:Immo5()
			self:Proto()	
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and not Ready(SUMMONER_2) then
		if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt5()
			self:Immo5()
			self:Proto()	
		end	
	end	
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
		if Ready(_R) and not Ready(_W) and (Protobelt > 0 and not Ready(Protobelt)) or Protobelt == 0 then
			self:AutoUlt6()
			self:Immo6()
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
		if Ready(_R) and not Ready(_W) and (Protobelt > 0 and not Ready(Protobelt)) or Protobelt == 0 then
			self:AutoUlt6()
			self:Immo6()
		end	
	end	
end	
end


function Neeko:KillSteal()
if myHero.dead then return end	
	local target = GetTarget(2000)     	
	if target == nil then return end
	local hp = target.health
	local EDmg = getdmg("E", target, myHero)
	local QDmg = getdmg("Q", target, myHero)
	if IsValid(target,1100) then
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.ks.UseQ:Value() and Ready(_Q) and hitRate and hitRate >= self.Menu.ks.PredQ:Value() then
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 800 then
				Control.CastSpell(HK_Q, aimPosition)
			end
		end
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		if self.Menu.ks.UseE:Value() and Ready(_E) and hitRate and hitRate >= self.Menu.ks.PredE:Value() then
			if EDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 1000 then
				Control.CastSpell(HK_E, aimPosition)
			end
		end
		local hitRateE, aimPositionE = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		local hitRateQ, aimPositionQ = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.ks.UseEQ:Value() and Ready(_E) and Ready(_Q) and hitRateE and hitRateQ and hitRateE >= self.Menu.ks.PredE:Value() and hitRateQ >= self.Menu.ks.PredQ:Value() then
			if (EDmg + QDmg) >= hp and myHero.pos:DistanceTo(target.pos) <= 800 then
				Control.CastSpell(HK_E, aimPositionE)
				Control.CastSpell(HK_Q, aimPositionQ)
			end
		end
	end
end	


function Neeko:EscapeW()  
	local target = GetTarget(1500)
	if target == nil then return end
	if target and not target.dead and not myHero.dead then
	local hp = myHero.health
		if self.Menu.evade.UseW:Value() and hp <= self.Menu.evade.Min:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 1000 then
			local attackFalse = _G.SDK.Orbwalker:SetAttack(false)
			local attackTrue = _G.SDK.Orbwalker:SetAttack(true)
			local MPos = myHero.pos:Shortened(target.pos, 1000)
			DelayAction(attackFalse,0)
			Control.SetCursorPos(MPos)
			Control.KeyDown(HK_W)
			Control.KeyUp(HK_W)
			DelayAction(attackTrue, 0.2)
		end
	end
end	

function Neeko:GankW()  
	local target = GetTarget(1500)
	if target == nil then return end
	if target and not target.dead and not myHero.dead then
		if self.Menu.evade.gank:Value() and Ready(_W) then
			local targetCount = CountEnemiesNear(myHero.pos, 1000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount > 1 and allyCount == 0 then
				local attackFalse = _G.SDK.Orbwalker:SetAttack(false)
				local attackTrue = _G.SDK.Orbwalker:SetAttack(true)
				local MPos = myHero.pos:Shortened(target.pos, 1000)
				DelayAction(attackFalse,0)
				Control.SetCursorPos(MPos)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
				DelayAction(attackTrue, 0.2)				
			end
		end
	end
end	


function Neeko:AutoR()
local target = GetTarget(1000)
if target == nil then return end

local Protobelt = GetItemSlot(myHero, 3152)	
	if IsValid(target,1000) and self.Menu.Combo.Ult.WR.UseR:Value() and self.Menu.a.ON:Value() then
		if Ready(_R) and Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero.pos, 600)
			if targetCount >= self.Menu.Combo.Ult.WR.RHit:Value() and myHero.pos:DistanceTo(target.pos) < 400 then
				SetAttack(false)
				Control.CastSpell(HK_W)
				self:Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)				
			end
			
		elseif Ready(_R) and not Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then	
			local targetCount = CountEnemiesNear(myHero.pos, 600)
			if targetCount >= self.Menu.Combo.Ult.WR.RHit:Value() and myHero.pos:DistanceTo(target.pos) < 400 then
				SetAttack(false)
				self:Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		
		elseif Ready(_R) and Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero.pos, 600)
			if targetCount >= self.Menu.Combo.Ult.WR.RHit:Value() and myHero.pos:DistanceTo(target.pos) < 400 then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)				
			end
			
		elseif Ready(_R) and not Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then	
			local targetCount = CountEnemiesNear(myHero.pos, 600)
			if targetCount >= self.Menu.Combo.Ult.WR.RHit:Value() and myHero.pos:DistanceTo(target.pos) < 400 then
				SetAttack(false)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end			
		end
	end
end

			
	

function Neeko:AutoR1()
local target = GetTarget(2000)
if target == nil then return end
local hp = target.health
local RDmg = getdmg("R", target, myHero)
local QDmg = getdmg("Q", target, myHero)
local EDmg = getdmg("E", target, myHero)
local Protobelt = GetItemSlot(myHero, 3152)	
	if IsValid(target,500) then
		
		if self.Menu.Combo.Ult.One.UseR1:Value() and self.Menu.a.ON:Value() and Ready(_R) and Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero.pos, 2000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount <= 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 400 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_W)
				self:Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		elseif self.Menu.Combo.Ult.One.UseR1:Value() and self.Menu.a.ON:Value() and Ready(_R) and not Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero.pos, 2000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount <= 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 400 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				self:Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end	
		elseif self.Menu.Combo.Ult.One.UseR1:Value() and self.Menu.a.ON:Value() and Ready(_R) and Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero.pos, 2000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount <= 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 300 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		elseif self.Menu.Combo.Ult.One.UseR1:Value() and self.Menu.a.ON:Value() and Ready(_R) and not Ready(_W) and (( not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero.pos, 2000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount <= 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 300 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end			
		end
	end
end

			--Hextech Protobelt
function Neeko:Proto()	
if myHero.dead then return end	
	local target = GetTarget(1000)
	if target == nil then return end
	local Protobelt = GetItemSlot(myHero, 3152)
	if IsValid(target,600) and self.Menu.a.ON:Value() then
		if myHero.pos:DistanceTo(target.pos) < 500 and Protobelt > 0 and Ready(Protobelt)  then	
			Control.CastSpell(ItemHotKey[Protobelt], target)
			CastSpell(ItemHotKey[Protobelt], target, 2.0)
		end
	end
end	


function Neeko:AutoUlt1() --full
	local target = GetTarget(1400)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,900) then
		local targetCount = CountEnemiesNear(ally.pos, 600)	
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 800 and myHero.pos:DistanceTo(ally.pos) >= 300 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, ally.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, ally.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
					end	
				end
			end
		end
	end
end

function Neeko:AutoUlt2()   --no[W]
	local target = GetTarget(1400)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,900) then
		local targetCount = CountEnemiesNear(ally.pos, 600)		
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 800 and myHero.pos:DistanceTo(ally.pos) >= 300 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, ally.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, ally.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
					end	
				end
			end
		end
	end
end

function Neeko:AutoUlt3() --noProtobelt
	local target = GetTarget(1200)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,500) then
		local targetCount = CountEnemiesNear(ally.pos, 600)		
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 500 and myHero.pos:DistanceTo(ally.pos) >= 200 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, ally.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, ally.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
					end	
				end
			end
		end
	end
end

function Neeko:AutoUlt4()  --noFlash
	local target = GetTarget(1200)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,500) then
		local targetCount = CountEnemiesNear(ally.pos, 600)		
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 400 and myHero.pos:DistanceTo(ally.pos) >= 100 then
					SetAttack(false)
					Control.CastSpell(HK_W)
					Control.CastSpell(HK_R)
					DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end



function Neeko:AutoUlt5()  --noFlash, no[W]
	local target = GetTarget(1200)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,500) then
		local targetCount = CountEnemiesNear(ally.pos, 600)	
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 400 and myHero.pos:DistanceTo(ally.pos) >= 100 then
					SetAttack(false)
					Control.CastSpell(HK_R)
					DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end

function Neeko:AutoUlt6() --noProtobelt, no[W]
	local target = GetTarget(1200)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do
		if IsValid(ally,500) then
		local targetCount = CountEnemiesNear(ally.pos, 600)		
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 400 and myHero.pos:DistanceTo(ally.pos) >= 200 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, ally.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, ally.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
					end	
				end
			end
		end    
	end
end

	
function Neeko:Immo1() --full
	local target = GetTarget(1400)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,900) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 800 and myHero.pos:DistanceTo(target.pos) >= 300 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, target.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, target.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end

function Neeko:Immo2() --no[W]
	local target = GetTarget(1400)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,900) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then		
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 800 and myHero.pos:DistanceTo(target.pos) >= 300 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, target.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, target.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end

function Neeko:Immo3() --noProtobelt
	local target = GetTarget(1200)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,500) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 500 and myHero.pos:DistanceTo(target.pos) >= 200 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, target.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, target.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end

function Neeko:Immo4() --noFlash
	local target = GetTarget(1100)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,500) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 400 and myHero.pos:DistanceTo(target.pos) >= 100 then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Control.CastSpell(HK_R)
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		end
	end
end

function Neeko:Immo5() --noFlash, no[W]
	local target = GetTarget(1100)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,500) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then		
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 400 and myHero.pos:DistanceTo(target.pos) >= 100 then
				SetAttack(false)
				Control.CastSpell(HK_R)
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		end
	end
end

function Neeko:Immo6() --noProtobelt, no[W]
	local target = GetTarget(1200)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,500) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if self.Menu.Combo.Ult.Immo.UseR3:Value() --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 500 and myHero.pos:DistanceTo(target.pos) >= 200 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, target.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, target.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end
	
	
	
function Neeko:Combo()
	local target = GetTarget(1100)
	if target == nil then return end
	if IsValid(target,1000) then
		local hitRateE, aimPositionE = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		if self.Menu.Combo.UseE:Value() and Ready(_E) and hitRateE and hitRateE >= self.Menu.Combo.PredE:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 then			
			Control.CastSpell(HK_E, aimPositionE)
		
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 800 and hitRate and hitRate >= self.Menu.Combo.PredQ:Value() then 
			Control.CastSpell(HK_Q, aimPosition)
		end
		end
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) and not Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 800 and hitRate and hitRate >= self.Menu.Combo.PredQ:Value() and not IsImmobileTarget(target) then
			Control.CastSpell(HK_Q, aimPosition)
		end	
	end
end

	
		

function Neeko:Harass()	
	local target = GetTarget(800)
	if target == nil then return end	
	if IsValid(target,900)  and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then
		local hitRateE, aimPositionE = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		if Ready(_E) and Ready(_Q) and hitRateE and hitRateE >= self.Menu.Harass.PredE:Value() and myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.Harass.UseE:Value() then
			Control.CastSpell(HK_E, aimPositionE)
			
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and hitRate and hitRate >= self.Menu.Harass.PredQ:Value() then	
			Control.CastSpell(HK_Q, aimPosition)
		end
		end
		
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and not Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 800 and hitRate and hitRate >= self.Menu.Harass.PredQ:Value() then
			Control.CastSpell(HK_Q, aimPosition)
		end
	end
end


function Neeko:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local TEAM_ALLY = myHero.team
	local TEAM_ENEMY = 300 - myHero.team

		if minion.team == TEAM_ENEMY and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then	
		local hp = minion.health
		local QDmg = getdmg("Q", minion, myHero)		
			local count = GetMinionCount(225, minion)			
			if IsValid(minion,800) and Ready(_Q) and hp <= QDmg and myHero.pos:DistanceTo(minion.pos) <= 800 and self.Menu.Clear.UseQL:Value() and count >= self.Menu.Clear.UseQLM:Value() then
				Control.CastSpell(HK_Q, minion)
			end	
			local count = GetMinionCount(1000, myHero)
			if IsValid(minion,1000) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1000 and self.Menu.Clear.UseE:Value() and count >= self.Menu.Clear.UseEM:Value() then
				Control.CastSpell(HK_E, minion)
			end  
		end
	end
end

function Neeko:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	local TEAM_JUNGLE = 300
		if minion.team == TEAM_JUNGLE then	
			if IsValid(minion,800) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 800 and self.Menu.JClear.UseQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 ) then
				Control.CastSpell(HK_Q, minion)
			end
			if IsValid(minion,1000) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1000 and self.Menu.JClear.UseE:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 ) then
				Control.CastSpell(HK_E, minion)
			end  
		end
	end
end





-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "Sylas"



function Sylas:__init()

	if menu ~= 1 then return end
	menu = 2
	self:LoadSpells()   	
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end) 
 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function Sylas:LoadSpells()
	
	Q = {range = 775, radius = 70, delay = 0.25, speed = 1800, collision = false}    
	W = {range = 400, radius = 70, delay = 0.25, speed = 20, collision = false}      
	E = {range = 800, radius = 60, delay = 0.25, speed = 1800, collision = true}   
	R = {range = 800}  

end







function Sylas:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Sylas", name = "PussySylas"})

	
	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})	
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Safe Auto[W]", value = true})
	self.Menu.AutoW:MenuElement({id = "hp", name = "Self Hp", value = 40, min = 1, max = 40, identifier = "%"})	

	--AutoR
	self.Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoR"})	
	self.Menu.AutoR:MenuElement({id = "UseR", name = "Auto Pulling Ult", value = true})
	self.Menu.AutoR:MenuElement({type = MENU, id = "Target", name = "Target Settings"})
	for i, hero in pairs(GetEnemyHeroes()) do
		self.Menu.AutoR.Target:MenuElement({id = "ult"..hero.charName, name = "Pull Ult: "..hero.charName, value = true})
		
	end	
	

		
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})
	
	---------------------------------------------------------------------------------------------------------------------------------
	--UltSettings
	self.Menu.Combo:MenuElement({type = MENU, id = "Set", name = "Ult Settings"})
	--Tranformation Ults
	self.Menu.Combo.Set:MenuElement({id = "Trans", name = "Use Tranform Ults[inWork]", value = false})								
	--Heal+Shield Ults
	self.Menu.Combo.Set:MenuElement({id = "Heal", name = "Use HEAL+Shield Ults", value = true})   								
	self.Menu.Combo.Set:MenuElement({id = "HP", name = "MinHP Heal+Shield", value = 30, min = 0, max = 100, identifier = "%"})	
	--AOE Ults
	self.Menu.Combo.Set:MenuElement({id = "AOE", name = "Use AOE Ults", value = true})	   										
	self.Menu.Combo.Set:MenuElement({id = "Hit", name = "MinTargets AOE Ults", value = 2, min = 1, max = 5})	
	--KS Ults
	self.Menu.Combo.Set:MenuElement({id = "LastHit", name = "Use DMG Ults killable Enemy", value = true})						
	---------------------------------------------------------------------------------------------------------------------------------
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	self.Menu.Harass:MenuElement({type = MENU, id = "LH", name = "LastHit"})	
	self.Menu.Harass.LH:MenuElement({id = "UseQL", name = "LastHit[Q] Minions", value = true, tooltip = "There is no Enemy nearby"})
	self.Menu.Harass.LH:MenuElement({id = "UseQLM", name = "LastHit[Q] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})	
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQL", name = "[Q] Chain Lash", value = true})	
	self.Menu.Clear:MenuElement({id = "UseQLM", name = "[Q] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})  
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 3, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})		
	self.Menu.ks:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})
	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", name = "Activator"})		
	self.Menu.a:MenuElement({id = "ON", name = "Protobelt", value = true})	
	self.Menu.a:MenuElement({type = MENU, id = "Zhonyas", name = "Zhonya's + StopWatch"})
	self.Menu.a.Zhonyas:MenuElement({id = "ON", name = "Enabled", value = true})
	self.Menu.a.Zhonyas:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})
	
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})
end

function Sylas:Tick()
if myHero.dead == false and Game.IsChatOpen() == false then
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
			
		self:UltAatrox()
		self:KillUltAhri()
		self:KillUltAkali()
		self:UltAlistar()
		self:ShieldUltAlistar()
		self:StunUltAmumu()
		self:UltAmumu()
		self:KillUltAnivia()
		self:KillUltAnnie()
		self:KillUltAshe()			--Pred + onScreen added
		self:KillUltAurelionSol()
		self:UltAzir()
		self:UltBard()
		self:KillUltBlitzcrank()
		self:KillUltBrand()
		self:UltBrand()
		self:StunUltBraum()
		self:UltBraum()
		self:KillUltCailtyn()		--Pred + onScreen added
		self:UltCamille()
		self:StunUltCassiopeia()
		self:UltCassiopeia()
		self:KillUltChogath()
		self:KillUltCorki()
		self:KillUltDarius()
		self:KillUltDiana()
		self:UltDrMundo()
		self:KillUltDraven()		--Pred + onScreen added
		self:KillUltEkko()
		self:UltEkko()
		--self:UltElise()			--transform Ult
		self:KillUltEvelynn()
		self:KillUltEzreal()		--Pred + onScreen added
		self:UltFiddelsticks()
		self:Fiddelsticks()
		self:UltFiora()
		self:KillUltFizz()
		self:UltGalio()
		self:KillUltGangplank()		--onScreen added
		self:UltGangplank()			--onScreen added
		self:KillUltGaren()
		self:StunUltGnar()
		self:KillUltGragas()
		self:UltGragas()
		self:KillUltGraves()
		self:KillUltHecarim()
		self:KillUltHeimerdinger()
		self:KillUltIllaoi()
		self:UltIllaoi()
		self:KillUltIrellia()
		self:PetUltIvern()
		self:HealUltJanna()
		self:AOEUltJanna()
		self:UltJarvenIV()
		self:JarvenIV()
		self:BuffUltJax()
		--self:UltJayce()           --Tranformation
		--self:KillUltJhin()
		self:KillUltJinx()			--Pred + onScreen added
		self:UltKaiSa()           
		--self:UltKallista()
		self:KillUltKarma()
		self:KillUltKarthus()
		self:KillUltKassadin()
		self:KillUltKatarina()
		self:UltKatarina()
		self:BuffUltKaylie()
		self:KillUltKayn()
		self:StunUltKennen()
		self:KillUltKhazix()
		self:HealUltKindred()
		self:SpeedUltKled()
		self:KillUltKogMaw()
		self:KillUltLeBlanc()
		self:KillUltLeesin()
		self:StunUltLeona()
		self:UltLeona()
		self:UltLissandra()   	
		self:KillUltLucian()
		self:BuffUltLulu()  	
		self:KillUltLux()		--Prediction + onSceen added
		self:StunUltMalphite()
		self:UltMalphite()
		self:StunUltMalzahar()
		self:UltMalzahar()
		self:StunUltMaokai()
		self:UltMaokai()
		self:SpeedUltMasterYi()     
		self:KillUltMissFortune()    
		self:KillUltMordekaiser()
		self:StunUltMorgana()
		self:UltMorgana()
		self:StunUltNami()		--Prediction + onSceen added
		self:UltNami()			--Prediction + onSceen added
		self:BuffUltNasus()
		self:StunUltNautlus()
		self:UltNautlus()
		self:StunUltNeeko()
		self:UltNeeko()
		--self:UltNiedalee()        --tranformation
		self:KillUltNocturne()
		self:KillUltNunu()
		self:BuffUltOlaf()
		self:KillUltOriana()
		self:UltOriana()
		self:StunUltOrnn()
		self:UltPantheon()        
		self:KillUltPoppy()
		self:KillUltPyke()
		self:SpeedUltQuinn()
		self:StunUltRakan()      
		self:DmgUltRammus()
		self:UltRammus()
		self:KillUltRekSai()
		self:BuffUltRenekton()
		self:KillUltRengar()
		self:KillUltRiven()        	
		self:UltRumble()           		 
		--self:UltRyze()             	--Manuel Use-----------------
		self:UltSejuani() 
		self:Sejuani()
		self:CloneUltShaco()       	
		--self:UltShen()             	--Manuel Use-----------------
		self:UltShyvana()          		--tranformation
		self:BuffUltSinged()        	
		--self:UltSion()            	--Manuel Use-----------------
		self:SpeedUltSivir()       
		self:StunUltSkarner()       
		self:StunUltSona()
		self:UltSona()
		self:HealUltSoraka()
		self:UltSwain() 
		self:Swain()
		self:HealSwain()
		self:KillUltSyndra()
		--self:UltTahmKench()          	--Manuel Use-----------------
		self:UltTaliyah()
		self:KillUltTalon()
		self:UltTalon()
		self:BuffUltTaric()           
		self:UltTeemo()               
		self:UltThresh()
		self:Thresh()
		self:KillUltTristana()
		self:BuffUltTrundle()
		self:BuffUlttryndamere()
		--self:UltTwistedFate()        	--Manuel Use-----------------	
		self:UltTwitch()             	
		self:UltUdyr()
		self:KillUltUrgot()
		self:KillUltVarus()
		self:UltVarus()
		self:BuffUltVayne()
		self:KillUltVeigar()
		--self:KillUltVelkoz()
		self:KillUltVi()
		self:KillUltViktor()
		self:KillUltVladimir()
		self:AOEUltVladimir()
		self:HealUltVladimir()
		self:UltVolibear()
		self:Volibear()
		self:KillUltWarwick()		--Prediction + onSceen added
		self:StunUltWukong()
		self:KillUltXayah()
		--self:KillUltXerath()
		self:UltXinZhao()
		self:KillUltYasou()
		self:UltYasou()
		self:PetUltYorick()              
		self:StunUltZac()
		self:UltZed()
		self:KillUltZiggs()			--onSceen added
		self:UltZiggs()				--onSceen added
		self:BuffUltZilean()
		self:ZoeUlt()
		self:StunUltZyra()
		self:UltZyra()
	
									--131 champs added  
	elseif Mode == "Harass" then
		self:Harass()
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		local TEAM_ALLY = myHero.team
		local TEAM_ENEMY = 300 - myHero.team
		local target = GetTarget(1000)
			if target == nil then	
				if minion.team == TEAM_ENEMY and not minion.dead and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then	
					local count = GetMinionCount(225, minion)			
					local hp = minion.health
					local QDmg = getdmg("Q", minion, myHero)
					if IsValid(minion,800) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 800 and self.Menu.Harass.LH.UseQL:Value() and count >= self.Menu.Harass.LH.UseQLM:Value() and hp <= QDmg then
						Control.CastSpell(HK_Q, minion)
					end	 
				end
			end
		end
		
		
	elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
	elseif Mode == "Flee" then
		
	end	
	
	self:Activator()
	self:KillSteal()	
	self:Proto()
	   				
	local target = GetTarget(1200)  
	if target == nil then return end
	if IsValid(target,1200) and self.Menu.AutoR.UseR:Value() and self.Menu.AutoR.Target["ult"..target.charName]:Value() and Ready(_R) then		
		if myHero.pos:DistanceTo(target.pos) <= 1050 and (myHero:GetSpellData(_R).name == "SylasR") and GotBuff(target, "SylasR") == 0 then                     
				Control.CastSpell(HK_R, target)
		end
	end	
 
	if IsValid(target,600) and self.Menu.AutoW.UseW:Value() and Ready(_W) then
		if myHero.pos:DistanceTo(target.pos) <= 400  and myHero.health/myHero.maxHealth <= self.Menu.AutoW.hp:Value()/100 then
			Control.CastSpell(HK_W, target)
		end
	end	



end 
end

			--Hextech Protobelt
function Sylas:Proto()	
if myHero.dead then return end	
	local target = GetTarget(1000)
	if target == nil then return end
	local Protobelt = GetItemSlot(myHero, 3152)
	if IsValid(target,600) and self.Menu.a.ON:Value() then
		if myHero.pos:DistanceTo(target.pos) < 500 and Protobelt > 0 and Ready(Protobelt) then	
			Control.CastSpell(ItemHotKey[Protobelt], target.pos)

		end
	end
end	 



function Sylas:Activator()
local target = GetTarget(1000)
if myHero.dead or target == nil then return end
	if IsValid(target,1000) then
			--Zhonyas
		if self.Menu.a.Zhonyas.ON:Value()  then
			local Zhonyas = GetItemSlot(myHero, 3157)
			if Zhonyas > 0 and Ready(Zhonyas) then 
				if myHero.health/myHero.maxHealth <= self.Menu.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
			--Stopwatch
		if self.Menu.a.Zhonyas.ON:Value() then
			local Stop = GetItemSlot(myHero, 2420)
			if Stop > 0 and Ready(Stop) then 
				if myHero.health/myHero.maxHealth <= self.Menu.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Stop])
				end
			end
		end
	end
end	
	
			


function Sylas:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 1050, 1, Draw.Color(255, 225, 255, 10)) --1050
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 755, 1, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawing.DrawE:Value()) and Ready(_E) then
    Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 125, 10))
	end
	if(self.Menu.Drawing.DrawW:Value()) and Ready(_W) then
    Draw.Circle(myHero, 400, 1, Draw.Color(225, 225, 125, 10))
	end
	local target = GetTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Drawing.Kill:Value() and not target.dead then
	local hp = target.health
	local fullDmg = (getdmg("Q", target, myHero) + getdmg("E", target, myHero) + getdmg("W", target, myHero))	
		if Ready(_Q) and getdmg("Q", target, myHero) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_E) and getdmg("E", target, myHero) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
		if Ready(_W) and getdmg("W", target, myHero) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end
		if Ready(_W) and Ready(_E) and Ready(_Q) and fullDmg > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end		
	end
end
       












--------------------------KS Ults---------------------------------------------------
function Sylas:UltAatrox()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "AatroxR") then										--Aatrox 
			Control.CastSpell(HK_R, target)
			
		end
	end
end

function Sylas:KillUltAhri()
local target = GetTarget(600)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "AhriTumble") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Ahri 
			if getdmg("R", target, myHero, 70) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltAkali()
local target = GetTarget(600)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "AkaliR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Akali 
			if getdmg("R", target, myHero, 20) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltAkalib()
local target = GetTarget(750)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,750) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "AkaliRb") and myHero.pos:DistanceTo(target.pos) <= 750 then		--Akalib
			if getdmg("R", target, myHero, 21) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:UltAlistar()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "FerociousHowl") then										--Alistar
			Control.CastSpell(HK_R, target)
			
		end
	end
end	

function Sylas:StunUltAmumu()
local target = GetTarget(550)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,550) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "CurseoftheSadMummy") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Amumu 
			if getdmg("R", target, myHero, 22) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltAnivia()
local target = GetTarget(750)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,750) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GlacialStorm") and myHero.pos:DistanceTo(target.pos) <= 750 then		--Anivia
			if getdmg("R", target, myHero, 13) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltAnnie()
local target = GetTarget(600)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "AnnieR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Annie   	 
			if getdmg("R", target, myHero, 23) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltAshe()
local target = GetTarget(25000)     	
if target == nil then return end
local hp = target.health
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.25, 1600, 130, false)
	if IsValid(target,25000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "EnchantedCrystalArrow") and myHero.pos:DistanceTo(aimPosition.pos) <= 25000 then		--Ashe 
			if getdmg("R", target, myHero, 3) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	end
end	

function Sylas:KillUltAurelionSol()
local target = GetTarget(1500)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "AurelionSolR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--AurelionSol
			if getdmg("R", target, myHero, 14) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:UltAzir()
local target = GetTarget(250)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,250) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "AzirR") and myHero.pos:DistanceTo(target.pos) <= 250 then		--Azir
			if getdmg("R", target, myHero, 24) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	



function Sylas:KillUltBlitzcrank()							--BlitzCrank
local target = GetTarget(450)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,450) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "BlitzcrankR") and myHero.pos:DistanceTo(target.pos) <= 600 then	
			if getdmg("R", target, myHero, 26) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltBrand()
local target = GetTarget(750)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,750) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "BrandR") and myHero.pos:DistanceTo(target.pos) <= 750 then		--brand
			if getdmg("R", target, myHero, 48) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:StunUltBraum()
local target = GetTarget(1250)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1250) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "BraumRWrapper") and myHero.pos:DistanceTo(target.pos) <= 1250 then		--Braum  
			if getdmg("R", target, myHero, 15) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltCailtyn()
local target = GetTarget(3500)     	
if target == nil then return end
local hp = target.health
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 3500, 3.0, 3200, 50, true)
	if IsValid(target,3500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "CaitlynAceintheHole") and myHero.pos:DistanceTo(aimPosition.pos) <= 3500 then		--Caitlyn 
			if getdmg("R", target, myHero, 64) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end	
			end
		end
	end
end	

function Sylas:UltCamille()
local target = GetTarget(475)     	
if target == nil then return end

	if IsValid(target,475) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "CamilleR") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Camille
			Control.CastSpell(HK_R, target)
		end
	end
end


function Sylas:StunUltCassiopeia()
local target = GetTarget(850)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,850) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "CassiopeiaR") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Cassiopeia
			if getdmg("R", target, myHero, 10) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltChogath()
local target = GetTarget(200)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,200) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "Feast") and myHero.pos:DistanceTo(target.pos) <= 200 then		--Cho'gath
			if getdmg("R", target, myHero, 2) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltCorki()
local target = GetTarget(1225)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1225) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "MissileBarrageMissile") and myHero.pos:DistanceTo(target.pos) <= 1225 then		--Corki
			if getdmg("R", target, myHero, 30) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:KillUltDarius()
local target = GetTarget(600)     	
if target == nil then return end
local hp = target.health
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "DariusExecute") and myHero.pos:DistanceTo(target.pos) <= 460 then		--Darius
			if getdmg("R", target, myHero, 71) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:KillUltDiana()
local target = GetTarget(825)     	
if target == nil then return end
local hp = target.health
	if IsValid(target,825) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "DianaTeleport") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Diana
			if getdmg("R", target, myHero, 34) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end


function Sylas:KillUltDraven()
local target = GetTarget(25000)     	
if target == nil then return end
local hp = target.health
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.25, 2000, 160, false)
	if IsValid(target,25000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "DravenRCast") and myHero.pos:DistanceTo(aimPosition.pos) <= 25000 then		--Draven   
			if getdmg("R", target, myHero, 27) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end	
			end
		end
	end
end	

function Sylas:KillUltEkko()
local target = GetTarget(400)     	
if target == nil then return end
local hp = target.health
	if IsValid(target,400) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "EkkoR") and myHero.pos:DistanceTo(target.pos) <= 375 then		--Ekko
			if getdmg("R", target, myHero, 72) > hp then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--function Sylas:UltElise()

function Sylas:KillUltEvelynn()
local target = GetTarget(500)     	
if target == nil then return end
	local damage = getdmg("R", target, myHero, 25)*2
	local hp = target.health
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "EvelynnR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Evelynn      
			if target.health/target.maxHealth <= 30/100 and damage > hp then
				Control.CastSpell(HK_R, target)
			elseif getdmg("R", target, myHero, 25) > hp then
				Control.CastSpell(HK_R, target)	
			end
		end
	end
end	

function Sylas:KillUltEzreal()
local target = GetTarget(25000)     	
if target == nil then return end
local hp = target.health
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 1.0, 2000, 160, false)
	if IsValid(target,25000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "EzrealR") and myHero.pos:DistanceTo(aimPosition.pos) <= 25000 then		--ezreal
			if getdmg("R", target, myHero, 6) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end	
			end
		end
	end
end	

function Sylas:UltFiddelsticks()
local target = GetTarget(600)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "Crowstorm") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Fiddlesticks
			if getdmg("R", target, myHero, 54) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	



function Sylas:KillUltFizz()
local target = GetTarget(1300)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1300) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "FizzR") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Fizz   
			if getdmg("R", target, myHero, 28) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:UltGalio()
local target = GetTarget(6000)     	
if target == nil then return end
local hp = target.health
local level = myHero:GetSpellData(_R).level
local range = ({4000, 4750, 5500})[level]
local count = GetEnemyCount(1000, myHero)
	if IsValid(target,6000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GalioR") and myHero.pos:DistanceTo(target.pos) <= range and count == 0 then		--Galio   
			if getdmg("R", target, myHero, 73) > hp then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, range, 250)		
				end
			end
		end
	end
end

function Sylas:KillUltGangplank()
local target = GetTarget(20000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,20000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GangplankR") and myHero.pos:DistanceTo(target.pos) <= 20000 then		--Gankplank   
			if getdmg("R", target, myHero, 55) > hp then
				if target.pos:To2D().onScreen then						-----------check ist target in sichtweite
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			-----------ist target auserhalb sichtweite
					CastSpellMM(HK_R, target.pos, 20000, 500)		-----------CastSpellMM(HK_R, target.pos, range, delay)
				end
			end
		end
	end
end


function Sylas:KillUltGaren()
local target = GetTarget(1000)     	
if target == nil then return end
	local missingHP = (target.maxHealth - target.health)/100 * 0.286
	local missingHP2 = (target.maxHealth - target.health)/100 * 0.333
	local missingHP3 = (target.maxHealth - target.health)/100 * 0.4
	local damage = getdmg("R", target, myHero, 49) + missingHP
	local damage2 = getdmg("R", target, myHero, 49) + missingHP2
	local damage3 = getdmg("R", target, myHero, 49) + missingHP3
	local hp = target.health
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GarenR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Garen
			if damage3  > hp then
				Control.CastSpell(HK_R, target)
			elseif damage2  > hp then
				Control.CastSpell(HK_R, target)
			elseif damage  > hp then
				Control.CastSpell(HK_R, target)	
			end
		end
	end
end	

function Sylas:StunUltGnar()
local target = GetTarget(475)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,475) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GnarR") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Gnar     
			if getdmg("R", target, myHero, 29) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltGragas()
local target = GetTarget(1000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GragasR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Gragas   
			if getdmg("R", target, myHero, 30) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	


function Sylas:KillUltGraves()
local target = GetTarget(1000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GravesChargeShot") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Graves  
			if getdmg("R", target, myHero, 31) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltHecarim()
local target = GetTarget(1000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "HecarimUlt") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Hecarim  
			if getdmg("R", target, myHero, 32) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltHeimerdinger()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "HeimerdingerR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Heimerdinger
				Control.CastSpell(HK_R, target)
			
		end
	end
end

function Sylas:KillUltIllaoi()
local target = GetTarget(450)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,450) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "IllaoiR") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Illaoi
			if getdmg("R", target, myHero, 56) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:KillUltIrellia()
local target = GetTarget(1000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "IreliaR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Irelia
			if getdmg("R", target, myHero, 16) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:PetUltIvern()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "IvernR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Ivern
			Control.CastSpell(HK_R, target)
			
		end
	end
end	


function Sylas:UltJarvenIV()
local target = GetTarget(650)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,650) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "JarvanIVCataclysm") and myHero.pos:DistanceTo(target.pos) <= 650 then		--jarvan
			if getdmg("R", target, myHero, 57) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end



--function Sylas:UltJayyce()      

--function Sylas:KillUltJhin()
--local target = GetTarget(525)     	
--if target == nil then return end
--	local hp = target.health
--	if IsValid(target,525) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
--		if (myHero:GetSpellData(_R).name == "JhinRShot") and myHero.pos:DistanceTo(target.pos) <= 525 then		--Jhin   orbwalker block für die ulti
--			if getdmg("R", target, myHero, 33) > hp then
--				Control.CastSpell(HK_R, target)
--			end
--		end
--	end
--end	

function Sylas:KillUltJinx()
local target = GetTarget(25000)     	
if target == nil then return end
local hp = target.health
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.6, 1700, 140, false)
	if IsValid(target,25000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "JinxR") and myHero.pos:DistanceTo(aimPosition.pos) <= 25000 then		--jinx
			if getdmg("R", target, myHero, 7) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	end
end	

     

--function Sylas:UltKallista()

function Sylas:KillUltKarma()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KarmaMantra") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Karma
			Control.CastSpell(HK_R)
			
		end
	end
end	

function Sylas:KillUltKarthus()
local target = GetTarget(20000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,20000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KarthusFallenOne") and myHero.pos:DistanceTo(target.pos) <= 20000 then		--karthus
			if getdmg("R", target, myHero, 8) > hp then
				Control.CastSpell(HK_R)
			end
		end
	end
end	

function Sylas:KillUltKassadin()
local target = GetTarget(500)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "RiftWalk") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Kassadin
			if getdmg("R", target, myHero, 58) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end


function Sylas:KillUltKatarina()						--Katarina
local target = GetTarget(550)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,550) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KatarinaR") and myHero.pos:DistanceTo(target.pos) <= 550 then		
			if getdmg("R", target, myHero, 35) > hp then
				Control.CastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	end
end

function Sylas:UltKaiSa()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target,1500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KaisaR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--Kaisa  
			Control.CastSpell(HK_R, target)
			
		end
	end
end	

function Sylas:KillUltKayn()
local target = GetTarget(550)     	
if target == nil then return end
	if IsValid(target,550) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KaynR") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Kayn 
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_R, target)
		end
	end
end


function Sylas:StunUltKennen()
local target = GetTarget(550)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,550) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KennenShurikenStorm") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Kennen  
			if getdmg("R", target, myHero, 36) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:SpeedUltKled()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KledR") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Kled   
			Control.CastSpell(HK_R, target)
			
		end
	end
end


function Sylas:KillUltKogMaw()
local target = GetTarget(1300)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1300) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KogMawLivingArtillery") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Kogmaw   
			if getdmg("R", target, myHero, 59) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end


function Sylas:KillUltLeBlanc()
local target = GetTarget(600)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "LeblancSlideM") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Leblanc   
			if getdmg("R", target, myHero, 60) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:KillUltLeesin()
local target = GetTarget(500)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "BlindMonkRKick") and myHero.pos:DistanceTo(target.pos) <= 375 then		--LeeSin   
			if getdmg("R", target, myHero, 74) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end


function Sylas:UltLeona()
local target = GetTarget(1200)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1200) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "LeonaSolarFlare") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--leona   
			if getdmg("R", target, myHero, 5) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:UltLissandra()        
local target = GetTarget(550)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,550) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "LissandraR") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Lissandra      
			if getdmg("R", target, myHero, 18) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltLucian()
local target = GetTarget(1200)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1200) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "LucianR") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--Lucian
			if getdmg("R", target, myHero, 61) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltLux()
local target = GetTarget(3500)     						--Lux
if target == nil then return end
local hp = target.health
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 3500, 1, math.huge, 120, false) -- die Prediction,mußt werde von hand eingeben ////local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, range, delay, speed, radius, collision)/// ----bei collision true oder false----
	if IsValid(target,3500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "LuxMaliceCannon") and myHero.pos:DistanceTo(aimPosition.pos) <= 3500 then		
			if getdmg("R", target, myHero, 11) > hp and hitRate and hitRate >= 1 then
				
				----- diese berechnung ob target in sichtweite ist nur für spells die in Linie castet werden (also nicht für Gankplank oder so)-----
				
				if aimPosition:To2D().onScreen then 		--check ob target in sichtweite
					Control.CastSpell(HK_R, aimPosition) -- aimPosition ist die Predicted Position
				
				elseif not aimPosition:To2D().onScreen then	--ist target nicht in sichtweite
				local castPos = myHero.pos:Extended(aimPosition, 1000)    --berechnug für target auserthalb der sichtweite,,,castet 1000range vor sich auf mousepos in richtung target,,,
					Control.CastSpell(HK_R, castPos)
				end	
			end
		end
	end
end	

function Sylas:StunUltMalphite()
local target = GetTarget(1000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "UFSlash") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--malphite 
			if getdmg("R", target, myHero, 50) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:StunUltMalzahar()					--malzahar
local target = GetTarget(700)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,700) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "MalzaharR") and myHero.pos:DistanceTo(target.pos) <= 700 then		
			if getdmg("R", target, myHero, 19) > hp then
				Control.CastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	end
end	

function Sylas:StunUltMaokai()
local target = GetTarget(3000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,3000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "MaokaiR") and myHero.pos:DistanceTo(target.pos) <= 3000 then		--Maokai 
			if getdmg("R", target, myHero, 37) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	


function Sylas:SpeedUltMasterYi()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "Highlander") and myHero.pos:DistanceTo(target.pos) <= 500 then		--MasterYi
			Control.CastSpell(HK_R, target)
			
		end
	end
end



function Sylas:KillUltMissFortune()					--MissFortune
local target = GetTarget(1400)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1400) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "MissFortuneBulletTime") and myHero.pos:DistanceTo(target.pos) <= 1400 then		
			if getdmg("R", target, myHero, 38) > hp then
				Control.CastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end				
			end
		end
	end
end	
  
function Sylas:KillUltMordekaiser()
local target = GetTarget(650)     	
if target == nil then return end
	if IsValid(target,650) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "MordekaiserChildrenOfTheGrave") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Mordekaiser  
			Control.CastSpell(HK_R, target)
			
		end
	end
end	


function Sylas:StunUltMorgana()
local target = GetTarget(625)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,625) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SoulShackles") and myHero.pos:DistanceTo(target.pos) <= 625 then		--morgana   
			if getdmg("R", target, myHero, 52) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:StunUltNami()
local target = GetTarget(2750)     	
if target == nil then return end
local hp = target.health
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 2750, 0.5, 850, 250, false)
	if IsValid(target,2750) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NamiR") and myHero.pos:DistanceTo(aimPosition.pos) <= 2750 then		--Nami 
			if getdmg("R", target, myHero, 39) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	end
end	



function Sylas:StunUltNautlus()
local target = GetTarget(825)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,825) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NautilusR") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Nautilus  
			if getdmg("R", target, myHero, 40) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	


function Sylas:StunUltNeeko()
local target = GetTarget(600)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NeekoR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Neeko
			if getdmg("R", target, myHero, 65) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

--function Sylas:UltNiedalee()

function Sylas:KillUltNocturne()
local target = GetTarget(4000)     	
if target == nil then return end
local hp = target.health
local level = myHero:GetSpellData(_R).level
local range = ({2500, 3250, 4000})[level]

	if IsValid(target,4000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NocturneParanoia") and myHero.pos:DistanceTo(target.pos) <= range then		--Nocturne   
			if getdmg("R", target, myHero, 75) > hp then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, range, 250)		
				end
			end
		end
	end
end


function Sylas:KillUltNunu()																--Nunu
local target = GetTarget(650)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,650) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NunuR") and myHero.pos:DistanceTo(target.pos) <= 650 then		
			if getdmg("R", target, myHero, 17) > hp then
				Control.CastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end					
			end
		end
	end
end	

function Sylas:BuffUltOlaf()
local target = GetTarget(1200)     	
if target == nil then return end
	if IsValid(target,1200) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "OlafRagnarok") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--Olaf  
			if IsImmobileTarget(myHero) then
				Control.CastSpell(HK_R)
			end
		end
	end
end


function Sylas:KillUltOriana()
local target = GetTarget(325)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,325) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "OrianaDetonateCommand-") and myHero.pos:DistanceTo(target.pos) <= 325 then		--Orianna  
			if getdmg("R", target, myHero, 66) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:StunUltOrnn()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "OrnnR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Ornn
			Control.CastSpell(HK_R, target)
			
		end
	end
end	


function Sylas:UltPantheon()
local target = GetTarget(5500)     	
if target == nil then return end
local hp = target.health
local count = GetEnemyCount(1000, myHero)
	if IsValid(target,5500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "PantheonRJump") and myHero.pos:DistanceTo(target.pos) <= 5500 and count == 0 then		--Phantheon   
			if getdmg("R", target, myHero, 76) > hp then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5500, 2000)		
				end
			end
		end
	end
end

function Sylas:KillUltPoppy()
local target = GetTarget(500)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "PoppyRSpell") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Poppy  
			if getdmg("R", target, myHero, 77) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:GetPykeDamage()
	local total = 0
	local Lvl = myHero.levelData.lvl
	if Lvl > 5 then
		local raw = ({ 250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550 })[Lvl]
		local m = 1.5 * myHero.armorPen
		local Dmg = m + raw + (0.4 * myHero.ap)
		total = Dmg   
	end
	return total
end	



function Sylas:KillUltPyke()																				--Pyke
local target = GetTarget(800)     	
if target == nil then return end
	local hp = target.health
	local dmg = self:GetPykeDamage()
	if IsValid(target,800) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "PykeR") and myHero.pos:DistanceTo(target.pos) <= 750 and dmg >= hp then	 
			Control.CastSpell(HK_R, target)
		end
	end
end	

function Sylas:SpeedUltQuinn()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "QuinnR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Quinn   
			Control.CastSpell(HK_R, target)
			
		end
	end
end


function Sylas:StunUltRakan()
local target = GetTarget(300)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,300) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "RakanR") and myHero.pos:DistanceTo(target.pos) <= 300 then		--Rakan  
			if getdmg("R", target, myHero, 78) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	
  
  
function Sylas:DmgUltRammus()
local target = GetTarget(300)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,300) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "Tremors2") and myHero.pos:DistanceTo(target.pos) <= 300 then		--Rammus   
			if getdmg("R", target, myHero, 62) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	


function Sylas:KillUltRekSai()
local target = GetTarget(1500)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "RekSaiR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--RekSai   
			if getdmg("R", target, myHero, 79) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:KillUltRengar()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "RengarR") and myHero.pos:DistanceTo(target.pos) <= 800 then		--Rengar  
			Control.CastSpell(HK_R, target)
		
		end
	end
end	

function Sylas:KillUltRiven()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "RivenFengShuiEngine") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Riven   
			Control.CastSpell(HK_R)
		
		end
	end
end


function Sylas:UltRumble()
local target = GetTarget(1700)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1700) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "RumbleCarpetBombDummy") and myHero.pos:DistanceTo(target.pos) <= 1700 then		--Rumble   
			if getdmg("R", target, myHero, 41) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:UltSejuani()
local target = GetTarget(1300)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1300) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SejuaniR") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Sejuani   
			if getdmg("R", target, myHero, 42) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:CloneUltShaco()
local target = GetTarget(500)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "HallucinateFull") and myHero.pos:DistanceTo(target.pos) <= 500 then --Shaco 
			if getdmg("R", target, myHero, 80) > hp then
				Control.CastSpell(HK_R)
				Control.CastSpell(HK_R, target)
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:UltShyvana()
local target = GetTarget(1000)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ShyvanaTransformCast") and myHero.pos:DistanceTo(target.pos) <= 1000 then --shyvana 
			if getdmg("R", target, myHero, 51) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	
   
function Sylas:StunUltSkarner()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SkarnerImpale") and myHero.pos:DistanceTo(target.pos) <= 350 then		--Skarner    
			Control.CastSpell(HK_R, target)
			
		end
	end
end


function Sylas:StunUltSona()
local target = GetTarget(900)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,900) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SonaR") and myHero.pos:DistanceTo(target.pos) <= 900 then		--Sona    
			if getdmg("R", target, myHero, 43) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	



function Sylas:UltSwain()
local target = GetTarget(650)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,650) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Swain    
			if getdmg("R", target, myHero, 67) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	


function Sylas:KillUltSyndra()
local target = GetTarget(675)     	
if target == nil then return end
	if IsValid(target,675) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SyndraR") and myHero.pos:DistanceTo(target.pos) <= 675 then		--Syndra    
			Control.CastSpell(HK_R, target)
			
		end
	end
end

function Sylas:UltTaliyah()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "TaliyahR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Taliyah   
			Control.CastSpell(HK_R, target)
			
		end
	end
end

function Sylas:KillUltTalon()
local target = GetTarget(550)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,550) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "TalonShadowAssault") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Talon   
			if getdmg("R", target, myHero, 81) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:UltThresh()
local target = GetTarget(450)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,450) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ThreshRPenta") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Tresh   
			if getdmg("R", target, myHero, 68) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Sylas:UltTeemo()
local target = GetTarget(900)     	
if target == nil then return end
local level = myHero:GetSpellData(_R).level
local range = ({400, 650, 900})[level]
	if IsValid(target,900) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "TeemoR") and myHero.pos:DistanceTo(target.pos) <= range then		--Teemo   
			Control.CastSpell(HK_R, target.pos)
		
		end
	end
end

function Sylas:KillUltTristana()
local target = GetTarget(525)     	
if target == nil then return end
	local range = 517 + (8 * myHero.levelData.lvl)
	local hp = target.health
	if IsValid(target,525) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "TristanaR") and myHero.pos:DistanceTo(target.pos) <= range then		--Tristana  	
			if getdmg("R", target, myHero, 12) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:BuffUltTrundle()
local target = GetTarget(650)     	
if target == nil then return end
	if IsValid(target,650) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "TrundlePain") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Trundle     
			Control.CastSpell(HK_R, target)
			
		end
	end
end

function Sylas:UltTwitch()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "TwitchFullAutomatic") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Twitch    
			Control.CastSpell(HK_R, target)
			
		end
	end
end

function Sylas:UltUdyr()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "UdyrPhoenixStance") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Udyr    
			Control.CastSpell(HK_R, target)
			
		end
	end
end

function Sylas:KillUltUrgot()
local target = GetTarget(1600)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "UrgotR") and myHero.pos:DistanceTo(target.pos) <= 1600 then		--Urgot      
			if getdmg("R", target, myHero, 44) > hp then
				Control.CastSpell(HK_R, target)
			end	
			if target.health/target.maxHealth < 25/100 then
				Control.CastSpell(HK_R, target)	
			end
		end
	end
end	

function Sylas:KillUltVarus()
local target = GetTarget(1075)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1075) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VarusR") and myHero.pos:DistanceTo(target.pos) <= 1075 then		--Varus     
			if getdmg("R", target, myHero, 45) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:BuffUltVayne()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VayneInquisition") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Vayne     
			Control.CastSpell(HK_R)
			
		end
	end
end	


function Sylas:KillUltVeigar()
local target = GetTarget(650)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,650) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VeigarR") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Vaiger
			if getdmg("R", target, myHero, 4) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

--function Sylas:KillUltVel'koz()

function Sylas:KillUltVi()
local target = GetTarget(800)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,800) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ViR") and myHero.pos:DistanceTo(target.pos) <= 800 then		--Vi
			if getdmg("R", target, myHero, 82) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function Sylas:KillUltViktor()
local target = GetTarget(700)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,700) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ViktorChaosStorm") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Viktor
			if getdmg("R", target, myHero, 83) > hp then
				Control.CastSpell(HK_R, target.pos)
				Control.CastSpell(HK_R, target.pos)
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end


function Sylas:KillUltVladimir()
local target = GetTarget(700)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,700) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Vladimir
			if getdmg("R", target, myHero, 63) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	


function Sylas:UltVolibear()
local target = GetTarget(500)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VolibearR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Volibear
			if getdmg("R", target, myHero, 69) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	


function Sylas:KillUltWarwick()
local target = GetTarget(3000)     	
if target == nil then return end
local range = 2.5 * myHero.ms
local hp = target.health
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, range, 0.1, 1800, 55, false)
	if IsValid(target,3000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "WarwickR") and myHero.pos:DistanceTo(aimPosition.pos) <= range then		--Warwick	
			if getdmg("R", target, myHero, 47) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	end
end	

function Sylas:StunUltWukong()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target,500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "WukongR") and myHero.pos:DistanceTo(target.pos) <= 200 then		--Wukong
			Control.CastSpell(HK_R)
		
		end
	end
end


function Sylas:KillUltXayah()
local target = GetTarget(1100)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1100) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "XayahR") and myHero.pos:DistanceTo(target.pos) <= 1100 then		--Xayah
			if getdmg("R", target, myHero, 84) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

--[[
function Sylas:KillUltXerath()
local target = GetTarget(6500)     	
if target == nil then return end
local hp = target.health
local level = myHero:GetSpellData(_R).level
local range = ({3520, 4840, 6160})[level]
local count = GetEnemyCount(1000, myHero)
	if IsValid(target,6500) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "XerathLocusOfPower2") and myHero.pos:DistanceTo(target.pos) <= range and count == 0 then		--Xerath   
			if getdmg("R", target, myHero, 73) > hp then
				Control.CastSpell(HK_R)
				Control.SetCursorPos(target.pos)
				aim = TargetSelector:GetTarget(NEAR_MOUSE)
				if GetDistance(mousePos, aim) < 200 then						
					Control.CastSpell(HK_R) 
				end
			return end
		end
	end
end]]

function Sylas:IsKnockedUp(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 29 or buff.type == 30 or buff.type == 39) and buff.count > 0 then
				return true
			end
		end
		return false	
	end
	
function Sylas:CountKnockedUpEnemies(range)
		local count = 0
		local rangeSqr = range * range
		for i = 1, Game.HeroCount()do
		local hero = Game.Hero(i)
			if hero.isEnemy and hero.alive and GetDistanceSqr(myHero.pos, hero.pos) <= rangeSqr then
			if Sylas:IsKnockedUp(hero)then
			count = count + 1
    end
  end
end
return count
end


function Sylas:KillUltYasou()
local target = GetTarget(1400)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,1400) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "YasuoR") and myHero.pos:DistanceTo(target.pos) <= 1400 then		--Yasou
			if getdmg("R", target, myHero, 85) > hp and self:IsKnockedUp(target) then
				Control.CastSpell(HK_R)
			end
		end
	end
end

function Sylas:PetUltYorick()
local target = GetTarget(600)     	
if target == nil then return end
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "YorickReviveAlly") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Yorick
			Control.CastSpell(HK_R, target)
		
		end
	end
end

function Sylas:StunUltZac()
local target = GetTarget(1000)     	
if target == nil then return end
local level = myHero:GetSpellData(_R).level
local range = ({700, 850, 1000})[level]
	if IsValid(target,1000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ZacR") and myHero.pos:DistanceTo(target.pos) <= range then		--Zac  						
			Control.CastSpell(HK_R, target.pos) 
			Control.CastSpell(HK_R, target.pos)
			Control.CastSpell(HK_R, target.pos)
				
		end
	end
end

function Sylas:UltZed()
local target = GetTarget(700)     	
if target == nil then return end
	if IsValid(target,700) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ZedR") and myHero.pos:DistanceTo(target.pos) <= 625 then		--Zed
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_R)
			Control.CastSpell(HK_R)
			
		end
	end
end


function Sylas:KillUltZiggs()
local target = GetTarget(5300)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,5300) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ZiggsR") and myHero.pos:DistanceTo(target.pos) <= 5300 then		--ziggs
			if getdmg("R", target, myHero, 9) > hp then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5300, 375)		
				end
			end	
		end
	end
end	

function Sylas:ZoeUlt()
local target = GetTarget(600)     	
if target == nil then return end
	if IsValid(target,600) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ZoeR") and myHero.pos:DistanceTo(target.pos) <= 575 then		--Zoe
			Control.CastSpell(HK_R, target)
		
		end
	end
end

function Sylas:StunUltZyra()
local target = GetTarget(700)     	
if target == nil then return end
	local hp = target.health
	if IsValid(target,700) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ZyraR") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Zyra    
			if getdmg("R", target, myHero, 46) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end







----------------AOE Ults------------------------------------------------------------------------------------------------------------

--Amumu
function Sylas:UltAmumu()
local target = GetTarget(550)     	
if target == nil then return end
local count = GetEnemyCount(550, myHero)
	if IsValid(target,550) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "CurseoftheSadMummy") then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end	

--Bard
function Sylas:UltBard()
local target = GetTarget(3400)     	
if target == nil then return end
local count = GetEnemyCount(350, target)
	if IsValid(target,3400) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "BardR") then		
			if myHero.pos:DistanceTo(target.pos) <= 3400 and count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Braum
function Sylas:UltBraum()
local target = GetTarget(1250)     	
if target == nil then return end
local count = GetEnemyCount(115, myHero)
	if IsValid(target,1250) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "BraumRWrapper") and myHero.pos:DistanceTo(target.pos) <= 1250 then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Brand
function Sylas:UltBrand()
local target = GetTarget(750)     	
if target == nil then return end
local count = GetEnemyCount(600, target)
	if IsValid(target,750) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "BrandR") and myHero.pos:DistanceTo(target.pos) <= 750 then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Cassiopeia
function Sylas:UltCassiopeia()
local target = GetTarget(825)     	
if target == nil then return end
local count = GetEnemyCount(825, target)
	if IsValid(target,825) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "CassiopeiaR") and myHero.pos:DistanceTo(target.pos) <= 825 then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Fiddlesticks
function Sylas:Fiddelsticks()
local target = GetTarget(800)     	
if target == nil then return end
local count = GetEnemyCount(600, myHero)
	if IsValid(target,800) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "Crowstorm") and myHero.pos:DistanceTo(target.pos) <= 600 then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end




--Gankplank
function Sylas:UltGangplank()			---------Dieses nutzen für Global AOE---------
local target = GetTarget(20000)     	
if target == nil then return end
local count = GetEnemyCount(600, target)
	if IsValid(target,20000) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GangplankR") and myHero.pos:DistanceTo(target.pos) <= 20000 then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				
				if target.pos:To2D().onScreen then						-----------check ist target in sichtweite
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			-----------ist target auserhalb sichtweite
					CastSpellMM(HK_R, target.pos, 20000, 500)		-----------CastSpellMM(HK_R, target.pos, range, delay)
				end
			end
		end
	end
end    

--Gragas
function Sylas:UltGragas()
local target = GetTarget(1000)     	
if target == nil then return end
local count = GetEnemyCount(400, target)
	if IsValid(target,1000) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "GragasR") then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end


--Ilaoi
function Sylas:UltIllaoi()
local target = GetTarget(450)     	
if target == nil then return end
local count = GetEnemyCount(450, myHero)
	if IsValid(target,450) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "IllaoiR") then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Janna
function Sylas:AOEUltJanna()
local target = GetTarget(725)     	
if target == nil then return end
local count = GetEnemyCount(725, myHero)
	if IsValid(target,725) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ReapTheWhirlwind") then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Jarvan
function Sylas:JarvenIV()
local target = GetTarget(650)     	
if target == nil then return end
local count = GetEnemyCount(325, target)
	if IsValid(target,650) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "JarvanIVCataclysm") and myHero.pos:DistanceTo(target.pos) <= 650 then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end


--Katarina
function Sylas:UltKatarina()						
local target = GetTarget(550)     	
if target == nil then return end
local count = GetEnemyCount(250, myHero)
	if IsValid(target,550) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KatarinaR") then		
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	end
end

--Leona 
function Sylas:StunUltLeona()
local target = GetTarget(1200)     	
if target == nil then return end
local count = GetEnemyCount(250, target)	
	if IsValid(target,1200) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "LeonaSolarFlare") and myHero.pos:DistanceTo(target.pos) <= 1200 then		 
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target,pos)
			end
		end
	end
end	
	


--Maokai
function Sylas:UltMaokai()
local target = GetTarget(3000)     	
if target == nil then return end
local count = GetEnemyCount(900, target)
	if IsValid(target,3000) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "MaokaiR") and myHero.pos:DistanceTo(target.pos) <= 3000 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Malzahar
function Sylas:UltMalzahar()					
local target = GetTarget(700)     	
if target == nil then return end
local count = GetEnemyCount(500, target)
	if IsValid(target,700) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "MalzaharR") and myHero.pos:DistanceTo(target.pos) <= 700 and count >= self.Menu.Combo.Set.Hit:Value() then		
				Control.CastSpell(HK_R, target.pos)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
		end
	end
end

--Malphite
function Sylas:UltMalphite()
local target = GetTarget(1000)     	
if target == nil then return end
local count = GetEnemyCount(300, target)
	if IsValid(target,1000) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "UFSlash") and myHero.pos:DistanceTo(target.pos) <= 1000 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Morgana
function Sylas:UltMorgana()
local target = GetTarget(625)     	
if target == nil then return end
local count = GetEnemyCount(625, myHero)
	if IsValid(target,625) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SoulShackles") then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Nautilus
function Sylas:UltNautlus()
local target = GetTarget(825)     	
if target == nil then return end
local count = GetEnemyCount(300, target)
	if IsValid(target,825) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NautilusR") and myHero.pos:DistanceTo(target.pos) <= 825 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Neeko
function Sylas:UltNeeko()
local target = GetTarget(600)     	
if target == nil then return end
local count = GetEnemyCount(600, myHero)
	if IsValid(target,600) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NeekoR") then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Nami
function Sylas:UltNami()
local target = GetTarget(2750)     	
if target == nil then return end
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 2750, 0.5, 850, 250, false)
local count = GetEnemyCount(250, aimPosition)
	if IsValid(target,2750) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NamiR") and myHero.pos:DistanceTo(aimPosition.pos) <= 2750 then
			if count >= self.Menu.Combo.Set.Hit:Value() and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	end
end

--Orianna
function Sylas:UltOriana()
local target = GetTarget(325)     	
if target == nil then return end
local count = GetEnemyCount(325, myHero)
	if IsValid(target,325) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "OrianaDetonateCommand-") then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Rammus
function Sylas:UltRammus()
local target = GetTarget(300)     	
if target == nil then return end
local count = GetEnemyCount(300, myHero)
	if IsValid(target,300) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "Tremors2") then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Sona
function Sylas:UltSona()
local target = GetTarget(900)     	
if target == nil then return end
local count = GetEnemyCount(140, target)
	if IsValid(target,900) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SonaR") and myHero.pos:DistanceTo(target.pos) <= 900 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Swain
function Sylas:Swain()
local target = GetTarget(650)     	
if target == nil then return end
local count = GetEnemyCount(650, myHero)
	if IsValid(target,650) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Sejuani
function Sylas:Sejuani()
local target = GetTarget(1300)     	
if target == nil then return end
local count = GetEnemyCount(120, target)
	if IsValid(target,1300) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SejuaniR") and myHero.pos:DistanceTo(target.pos) <= 1300 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Talon
function Sylas:UltTalon()
local target = GetTarget(550)     	
if target == nil then return end
local count = GetEnemyCount(550, myHero)
	if IsValid(target,550) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "TalonShadowAssault") then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Thresh
function Sylas:Thresh()
local target = GetTarget(450)     	
if target == nil then return end
local count = GetEnemyCount(450, myHero)
	if IsValid(target,450) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ThreshRPenta") then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, myHero.pos)
			end
		end
	end
end


--Vladimir
function Sylas:AOEUltVladimir()
local target = GetTarget(700)     	
if target == nil then return end
local count = GetEnemyCount(325, target)
	if IsValid(target,700) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") and myHero.pos:DistanceTo(target.pos) <= 700 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Varus
function Sylas:UltVarus()
local target = GetTarget(1075)     	
if target == nil then return end
local count = GetEnemyCount(550, target)
	if IsValid(target,1075) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VarusR") and myHero.pos:DistanceTo(target.pos) <= 1075 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Volibear
function Sylas:Volibear()
local target = GetTarget(500)     	
if target == nil then return end
local count = GetEnemyCount(500, myHero)
	if IsValid(target,500) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VolibearR") then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Yasuo

function Sylas:UltYasou()
local target = GetTarget(1400)     	
if target == nil then return end
local count = self:CountKnockedUpEnemies(1400)
	if IsValid(target,1400) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "YasuoR") and myHero.pos:DistanceTo(target.pos) <= 1400 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	end
end


--Ziggs
function Sylas:UltZiggs()
local target = GetTarget(5300)     	
if target == nil then return end
local count = GetEnemyCount(550, target)
	if IsValid(target,5300) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ZiggsR") and myHero.pos:DistanceTo(target.pos) <= 5300 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5300, 375)		
				end
			end
		end
	end
end

--Zyra
function Sylas:UltZyra()
local target = GetTarget(700)     	
if target == nil then return end
local count = GetEnemyCount(500, target)
	if IsValid(target,700) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ZyraR") and myHero.pos:DistanceTo(target.pos) <= 700 then
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end







--------------------Heal/Shield Ults----------------------------------
--Alistar
function Sylas:ShieldUltAlistar()
local target = GetTarget(1200)     	
if target == nil then return end	
	if IsValid(target,1200) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "FerociousHowl") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	end
end	

--Dr.Mundo
function Sylas:UltDrMundo()
local target = GetTarget(1200)     	
if target == nil then return end	
	if IsValid(target,1200) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "Sadism") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	end
end	

--Ekko
function Sylas:UltEkko()
local target = GetTarget(800)     	
if target == nil then return end	
	if IsValid(target,800) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "EkkoR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end


--Fiora
function Sylas:UltFiora()
local target = GetTarget(500)     	
if target == nil then return end	
	if IsValid(target,500) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "FioraR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

--Janna
function Sylas:HealUltJanna()
local target = GetTarget(725)     	
if target == nil then return end	
	if IsValid(target,725) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ReapTheWhirlwind") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

--Jax
function Sylas:BuffUltJax()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "JaxRelentlessAssault") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Kayle
function Sylas:BuffUltKaylie()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "JudicatorIntervention") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	end
end

--Khazix
function Sylas:KillUltKhazix()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KhazixR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Kindred
function Sylas:HealUltKindred()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "KindredR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Lulu
function Sylas:BuffUltLulu() 
local target = GetTarget(300)     	
if target == nil then return end	
	if IsValid(target,300) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "LuluR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	end
end


--Nasus
function Sylas:BuffUltNasus()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "NasusR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

--Renekton
function Sylas:BuffUltRenekton()
local target = GetTarget(300)     	
if target == nil then return end	
	if IsValid(target,300) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "RenektonReignOfTheTyrant") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

--Singed
function Sylas:BuffUltSinged()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "InsanityPotion") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end


--Sivir
function Sylas:SpeedUltSivir()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SivirR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	end
end

--Soraka
function Sylas:HealUltSoraka()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SorakaR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Swain
function Sylas:HealSwain()
local target = GetTarget(650)     	
if target == nil then return end	
	if IsValid(target,650) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--Taric
function Sylas:BuffUltTaric()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "TaricR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Tryndamere
function Sylas:BuffUlttryndamere()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "UndyingRage") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end


--Vladimir
function Sylas:HealUltVladimir()
local target = GetTarget(700)     	
if target == nil then return end	
	if IsValid(target,700) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end

--XinZhao
function Sylas:UltXinZhao()
local target = GetTarget(700)     	
if target == nil then return end	
	if IsValid(target,700) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "XenZhaoParry") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

--Zilean
function Sylas:BuffUltZilean()
local target = GetTarget(1000)     	
if target == nil then return end	
	if IsValid(target,1000) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		if (myHero:GetSpellData(_R).name == "ZileanR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	end
end


--------------Tranformation Ults-----------------------------








-------------------------------------------------------------






function Sylas:KillSteal()
if myHero.dead then return end	
	local target = GetTarget(2000)     	
	if target == nil then return end
	local hp = target.health
	local QDmg = getdmg("Q", target, myHero)
	local WDmg = getdmg("W", target, myHero)
	local EDmg = getdmg("E", target, myHero)
	if IsValid(target,1300) then
		if EDmg >= hp and self.Menu.ks.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1200 and myHero.pos:DistanceTo(target.pos) > 400 then			
			local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
			Control.SetCursorPos(EPos)
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
			if myHero.pos:DistanceTo(target.pos) <= 800 then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
				if hitRate and hitRate >= 2 then
					Control.CastSpell(HK_E, aimPosition)
				end	
			end
	
		elseif EDmg >= hp and self.Menu.ks.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_E, target)
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 2 then
				Control.CastSpell(HK_E, aimPosition)
			end	
		end			
		
		if self.Menu.ks.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 775 then
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			if QDmg >= hp and hitRate and hitRate >= 2 then
				Control.CastSpell(HK_Q, aimPosition)
			end
		elseif self.Menu.ks.UseQ:Value() and Ready(_Q) and Ready(_E) and myHero.pos:DistanceTo(target.pos) > 775 and myHero.pos:DistanceTo(target.pos) <= 1175 then
			if QDmg >= hp then
				local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)	
			if myHero.pos:DistanceTo(target.pos) <= 775 and hitRate and hitRate >= 2 then	
				Control.CastSpell(HK_Q, aimPosition)
			end
			end
		end
		
		if self.Menu.ks.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 400 then
			if WDmg >= hp then
				Control.CastSpell(HK_W, target)		
			end
		elseif self.Menu.ks.UseW:Value() and Ready(_W) and Ready(_E) and myHero.pos:DistanceTo(target.pos) > 400 and  myHero.pos:DistanceTo(target.pos) <= 800 then
			if WDmg >= hp then
				local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
			if myHero.pos:DistanceTo(target.pos) <= 400 then	
				Control.CastSpell(HK_W, target)
			end		
			end			
		end					
	end
end	





function Sylas:Combo()
	local target = GetTarget(1300)
	if target == nil then return end
	if IsValid(target,1300) then
		if self.Menu.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1200 and myHero.pos:DistanceTo(target.pos) > 400 then			
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			local EPos = myHero.pos:Shortened(target.pos, 400)
			if hitRate and hitRate >= 2 then
			Control.SetCursorPos(EPos)
			Control.CastSpell(HK_E, aimPosition)
			if myHero.pos:DistanceTo(target.pos) <= 800 then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
				if hitRate and hitRate >= 2 then
					Control.CastSpell(HK_E, aimPosition)
				end	
			end
			end
	
		elseif self.Menu.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_E, target)	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 2 then
				Control.CastSpell(HK_E, aimPosition)
			end	
		end	
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 775 then 	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			if hitRate and hitRate >= 2 then
				Control.CastSpell(HK_Q, aimPosition)
			end	
		end
		if self.Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_W, target)
		end
	end
end

	
  		

function Sylas:Harass()	
	local target = GetTarget(1300)
	if target == nil then return end
	if IsValid(target,1300) and(myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then
		if self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1200 and myHero.pos:DistanceTo(target.pos) > 400 then			
			local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
			Control.SetCursorPos(EPos)
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
			if myHero.pos:DistanceTo(target.pos) <= 800 then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
				if hitRate and hitRate >= 2 then
					Control.CastSpell(HK_E, aimPosition)
				end
			end
		
		elseif self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_E, target)	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 2 then
				Control.CastSpell(HK_E, aimPosition)
			end
		end			
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 775 then 	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			if hitRate and hitRate >= 2 then
				Control.CastSpell(HK_Q, aimPosition)
			end	
		end
		if self.Menu.Harass.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_W, target)
		end
	end
end



function Sylas:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local TEAM_ALLY = myHero.team
	local TEAM_ENEMY = 300 - myHero.team

		if minion.team == TEAM_ENEMY and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then			
			local count = GetMinionCount(225, minion)			
			if IsValid(minion,1300) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1200 and myHero.pos:DistanceTo(minion.pos) > 400 and self.Menu.Clear.UseE:Value() then
				local EPos = minion.pos:Shortened((myHero.pos:DistanceTo(minion.pos) - 400))
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
				if myHero.pos:DistanceTo(minion.pos) <= 800 then	
					Control.CastSpell(HK_E, minion)
				end
					
			elseif IsValid(minion,400) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 400 and self.Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E, minion)
				Control.CastSpell(HK_E, minion)
			end 			
			if IsValid(minion,775) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 755 and self.Menu.Clear.UseQL:Value() and count >= self.Menu.Clear.UseQLM:Value() then
				Control.CastSpell(HK_Q, minion)
			end	

			if IsValid(minion,400) and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 400 and self.Menu.Clear.UseW:Value() then
				Control.CastSpell(HK_W, minion)
			end  
		end
	end
end

function Sylas:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	local TEAM_JUNGLE = 300
		if minion.team == TEAM_JUNGLE and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if IsValid(minion,1300) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1200 and myHero.pos:DistanceTo(minion.pos) > 400 and self.Menu.JClear.UseE:Value() then
				local EPos = minion.pos:Shortened((myHero.pos:DistanceTo(minion.pos) - 400))
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
				if myHero.pos:DistanceTo(minion.pos) <= 800 then				
					Control.CastSpell(HK_E, minion)
				end
			
			elseif IsValid(minion,400) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 400 and self.Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion)
				Control.CastSpell(HK_E, minion)
			end			
			if IsValid(minion,775) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 775 and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion)
			end

			if IsValid(minion,400) and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 400 and self.Menu.JClear.UseW:Value() then
				Control.CastSpell(HK_W, minion)
			end 
		end
	end
end




-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Tristana"

if FileExist(COMMON_PATH .. "Collision.lua") then
	require 'Collision'
end
if FileExist(COMMON_PATH .. "DamageLib.lua") then
	require 'DamageLib'
end

function Tristana:CheckSpell(range)
    local target
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
        if IsValid(hero, range) and hero.team ~= myHero.team then
			if hero.activeSpell.name == "RocketGrab" then 
				casterPos = hero.pos
				grabTime = hero.activeSpell.startTime * 100
				return true
			end
        end
    end
    return false
end

function Tristana:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

function GetInventorySlotItem(itemID)
	assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
	for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
		if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
	end
	return nil
end

function Tristana:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Tristana:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Tristana:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Tristana:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

local HeroIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/0/06/TristanaSquare.png"

function Tristana:LoadSpells()

	W = {Range = 900, Width = 250, Delay = 0.25, Speed = 1100, Collision = false, aoe = true, Type = "circle"}
	E = {Range = 517 + (8 * myHero.levelData.lvl), Width = 75, Delay = 0.25, Speed = 2400, Collision = false, aoe = false, Type = "line"}
	R = {Range = 517 + (8 * myHero.levelData.lvl), Width = 0, Delay = 0.25, Speed = 1000, Collision = false, aoe = false, Type = "line"}

end



function Tristana:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Tristana", name = "PussyTristana", leftIcon = HeroIcon})
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "AutoQ when Explosive Charge", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Combo:MenuElement({id = "UseR", name = "(R)Finisher", tooltip = "is(R)Dmg+(E)Dmg+(E)StackDmg > TargetHP than Ult", value = true})
	self.Menu.Combo:MenuElement({id = "R", name = "R", type = MENU})
	for i, hero in pairs(GetEnemyHeroes()) do
	self.Menu.Combo.R:MenuElement({id = "RR"..hero.charName, name = "KS R on: "..hero.charName, value = true})
	end	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	self.Menu:MenuElement({id = "gap", name = "Gapclose", type = MENU})
	self.Menu.gap:MenuElement({id = "UseR", name = "Ultimate Gapclose", value = true})
	self.Menu.gap:MenuElement({id = "gapkey", name = "Gapclose key", key = string.byte("T")})
	

	
	self.Menu:MenuElement({id = "Blitz", name = "AntiBlitzGrab", type = MENU})
	self.Menu.Blitz:MenuElement({id = "UseW", name = "AutoW", value = true})
	
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "AutoQ when Explosive Charge", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({id = "MS", name = "Mercurial Scimittar", type = MENU})
	self.Menu.MS:MenuElement({id = "UseMS", name = "Auto AntiCC", value = true})
	
	
	self.Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	
	--W
	self.Menu.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU})
    self.Menu.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--E
	self.Menu.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU})
    self.Menu.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    self.Menu.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--R
	self.Menu.Drawings:MenuElement({id = "R", name = "Draw R range", type = MENU})
    self.Menu.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = true})
    self.Menu.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	

	self.Menu.Drawings:MenuElement({id = "DrawR", name = "Draw Kill Ulti Gapclose ", value = true})


	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5,tooltip = "", identifier = ""})
	

end

function Tristana:Tick()
if myHero.dead == false and Game.IsChatOpen() == false then
local Mode = GetMode()
	if Mode == "Combo" then
		if self.Menu.Combo.comboActive:Value() then
			self:Combo()
			self:ComboE()
			self:UseBotrk()
			self:ComboRKS()
			self:Finisher()
		end	
		if self.Menu.gap.gapkey:Value() then
			self:GapcloseR()
			self:AutoR()

		end
	elseif Mode == "Harass" then
		if self.Menu.Harass.harassActive:Value() then
			self:HarassQ()
			self:HarassE()
		end
	elseif Mode == "Clear" then
	
	elseif Mode == "Flee" then
		
	end

	if self.Menu.Blitz.UseW:Value() then
		self:AntiBlitz()
	end

	self:UseMS()
end
end

function Tristana:Draw()
	if self:CanCast(_W) and self.Menu.Drawings.W.Enabled:Value() then Draw.Circle(myHero, 900, self.Menu.Drawings.W.Width:Value(), self.Menu.Drawings.W.Color:Value()) end
	if self:CanCast(_E) and self.Menu.Drawings.E.Enabled:Value() then Draw.Circle(myHero, GetERange(), self.Menu.Drawings.E.Width:Value(), self.Menu.Drawings.E.Color:Value()) end
	if self:CanCast(_R) and self.Menu.Drawings.R.Enabled:Value() then Draw.Circle(myHero, GetRRange(), self.Menu.Drawings.R.Width:Value(), self.Menu.Drawings.R.Color:Value()) end
	local hero = GetTarget(GetRWRange())
	if hero == nil then return end
	local textPos = myHero.pos:To2D()	
	if self.Menu.Drawings.DrawR:Value() and IsValid(hero, 1500) then 
		if myHero.pos:DistanceTo(hero.pos) > R.Range and EnemyInRange(GetRWRange()) then
		local Rdamage = self:RDMG(hero)		
		local totalDMG = CalculateMagicalDamage(hero, Rdamage)
			if totalDMG > self:HpPred(hero,1) + hero.hpRegen * 1 and not hero.dead and self:IsReady(_R) and self:IsReady(_W) then
			Draw.Text("GapcloseKill PressKey", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
			end
		end
	end
end	
local timer = {state = false, tick = GetTickCount(), mouse = mousePos, done = false, delayer = GetTickCount()}
function Tristana:AntiBlitz()	
	if GetTickCount() - timer.tick > 300 and GetTickCount() - timer.tick < 700 then 
		timer.state = false
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end

	local ctc = Game.Timer() * 100
	
	local target = _G.SDK.TargetSelector:GetTarget(900, _G.SDK.DAMAGE_TYPE_PHYSICAL)
	if self.Menu.Blitz.UseW:Value() and self:CheckSpell(900) and grabTime ~= nil and self:CanCast(_W) then 
		if myHero.pos:DistanceTo(target.pos) > 350 then
			if ctc - grabTime >= 28 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		else
			if ctc - grabTime >= 12 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		end
	end
end	

--Blade of the RuinKing	
function Tristana:UseBotrk()
	local target = GetTarget(700)
	if target == nil then return end
	if EnemyInRange(700) then 
		local BOTR = GetInventorySlotItem(3153) or GetInventorySlotItem(3144)
		if BOTR and EnemyInRange(700) then
			Control.CastSpell(HKITEM[BOTR], target)
		end
	end
end

--Mercurial Scimittar
function Tristana:UseMS()
	if self.Menu.MS.UseMS:Value() then
	local MS = GetInventorySlotItem(3139)	
		if MS and GotBuff(myHero, "veigareventhorizonstun") > 0 or GotBuff(myHero, "stun") > 0 or GotBuff(myHero, "taunt") > 0 or GotBuff(myHero, "slow") > 0 or GotBuff(myHero, "snare") > 0 or GotBuff(myHero, "charm") > 0 or GotBuff(myHero, "suppression") > 0 or GotBuff(myHero, "flee") > 0 or GotBuff(myHero, "knockup") > 0 then
			Control.CastSpell(HKITEM[MS], myHero)
		
		end
	end
end



function Tristana:Combo()
		local target = GetTarget(GetAARange())
		if target == nil then return end
		for i = 1, target.buffCount do
		local buff = target:GetBuff(i)
			if buff and buff.name == "tristanaechargesound" then
				if self.Menu.Combo.UseQ:Value() and target and self:CanCast(_Q) and EnemyInRange(GetAARange()) then
					Control.CastSpell(HK_Q)
				end
			end
		end	
	end
	
		


function Tristana:ComboE()
    local target = GetTarget(GetERange())
    if target == nil then return end
    if self.Menu.Combo.UseE:Value() and target and self:CanCast(_E) then
	    if EnemyInRange(GetERange()) then
			Control.CastSpell(HK_E, target)
		end
	end
end
		
function Tristana:ComboRKS()
	local hero = GetTarget(GetRRange())
    if hero == nil then return end
 	if self.Menu.Combo.R["RR"..hero.charName]:Value() and self:CanCast(_R) then
		if EnemyInRange(GetRRange()) then
		local Rdamage = self:RDMG(hero)   
		local totalDMG = CalculateMagicalDamage(hero, Rdamage)
			if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1 then
				Control.CastSpell(HK_R, hero)
			end
        end
    end
end

function Tristana:Finisher()
	local hero = GetTarget(GetRRange())
    if hero == nil then return end
	if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
		if EnemyInRange(GetRRange()) then
			Edmg = self:EDMG(hero)
			Rdmg = self:RDMG(hero)	
			calcEdmg = CalculatePhysicalDamage(hero, Edmg)
			calcRdmg = CalculateMagicalDamage(hero, Rdmg)
			totalDMG = calcEdmg + calcRdmg
			if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1 then
			Control.CastSpell(HK_R, hero)
			end
		end
	end
end	



	
function Tristana:GapcloseR()
	local hero = GetTarget(GetRWRange())
    if hero == nil then return end
	local Rdamage = self:RDMG(hero)		
	local totalDMG = CalculateMagicalDamage(hero, Rdamage)	
	if EnemyInRange(GetRWRange()) and self.Menu.gap.UseR:Value() and self:CanCast(_R) and self:CanCast(_W) then
		if myHero.pos:DistanceTo(hero.pos) > R.Range then
			if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1 then
				Control.CastSpell(HK_W, hero.pos) 
				self:AutoR()
			end
		end
	end
end	
		


function Tristana:AutoR()
	local hero = GetTarget(GetRRange())
    if hero == nil then return end
	if EnemyInRange(GetRRange()) and self:CanCast(_R) then
		local Rdamage = self:RDMG(hero)
		local totalDMG = CalculateMagicalDamage(hero, Rdamage)
		if  totalDMG > self:HpPred(hero,1) + hero.hpRegen * 1 then
			Control.CastSpell(HK_R, hero)
		
		end
	end
end







function Tristana:HarassQ()
		local target = GetTarget(GetAARange())
		if target == nil then return end
		for i = 1, target.buffCount do
		local buff = target:GetBuff(i)	
			if buff and buff.name == "tristanaechargesound" then
				if self.Menu.Harass.UseQ:Value() and self:CanCast(_Q) and EnemyInRange(GetAARange()) then
					Control.CastSpell(HK_Q)
				end
			end
		end	
	end



function Tristana:HarassE()
    local target = GetTarget(GetERange())
    if target == nil then return end
    if self.Menu.Harass.UseE:Value() and EnemyInRange(GetERange()) and self:CanCast(_E) then
		Control.CastSpell(HK_E, target)
		   
	    end
	end
 

-------------------------
-- DMG
---------------------
function Tristana:HasEbuff(unit)
	for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)
	for i = 1, hero.buffCount do
		local buff = hero:GetBuff(i)
		if HasBuff(hero, "tristanaechargesound") then
		if buff then
			return true
		end
	end
	return false
end
end
end

function Tristana:GetEstacks(unit)

	local stacks = 0
	if self:HasEbuff(unit) then
		for i = 1, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and buff.count > 0 and buff.name:lower() == "tristanaecharge" then
				stacks = buff.count
			end
		end
	end
	return stacks
end



function Tristana:RDMG(unit)
    total = 0
	local rLvl = myHero:GetSpellData(_R).level
    if rLvl > 0 then
	local rdamage = (({300,400,500})[rLvl] + myHero.ap) 
	total = rdamage 
	end
	return total
end

function Tristana:AADMG(unit)
    total = 0
	local AALvl = myHero.levelData.lvl

	local AAdamage = 58 + ( 2 * AALvl)
	total = AAdamage 
	return total
end

function Tristana:GetStackDmg(unit)

	local total = 0
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 21, 24, 27, 30, 33 })[eLvl]
		local m = ({ 0.15, 0.21, 0.27, 0.33, 0.39 })[eLvl]
		local bonusDmg = (m * myHero.bonusDamage) + (0.15 * myHero.ap)
		total = (raw + bonusDmg) * self:GetEstacks(unit)
	end
	return total
end

function Tristana:EDMG(unit)
	local total = 0
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 70, 80, 90, 100, 110 })[eLvl]
		local m = ({ 0.5, 0.7, 0.9, 1.1, 1.3 })[eLvl]
		local bonusDmg = (m * myHero.bonusDamage) + (0.5 * myHero.ap)
		total = raw + bonusDmg
		total = total + self:GetStackDmg(unit)  
	end
	return total
end	





function GetRRange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end

function GetRWRange()
	local rrange = GetRRange()
	local wrange = W.Range
	local range = rrange + wrange
	return range
end



function GetERange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end

function GetAARange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end




-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Veigar"



require "DamageLib"

if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
	PrintChat("TPred library loaded")
elseif FileExist(COMMON_PATH .. "Collision.lua") then
	require 'Collision'
	PrintChat("Collision library loaded")
end

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end
		
function GetPercentHP(unit)
	return (unit.health / unit.maxHealth) * 100
end

function GetPercentMP(unit)
	return (unit.mana / unit.maxMana) * 100
end

function Veigar:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Veigar:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Veigar:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Veigar:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

function Veigar:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end	
end

function Veigar:LoadSpells()

	Q = {Range = 950, Width = 70, Delay = 0.25, Speed = 2000, Collision = true, aoe = false, Type = "line"}
	W = {Range = 900, Width = 112, Delay = 1.25, Speed = math.huge, Collision = false, aoe = true, Type = "circular"}
	E = {Range = 700, Width = 375, Delay = 0.5, Speed = math.huge, Collision = false, aoe = true, Type = "circular"}
	R = {Range = 650, Width = 0, Delay = 0.25, Speed = 1400, Collision = false, aoe = false, Type = "line"}

end

function Veigar:QDMG()
    local level = myHero:GetSpellData(_Q).level
    local qdamage = (({70,110,150,190,230})[level] + 0.60 * myHero.ap)
	return qdamage
end

function Veigar:WDMG()
    local level = myHero:GetSpellData(_W).level
    local wdamage = (({100,150,200,250,300})[level] + myHero.ap)
	return wdamage
end

function Veigar:RDMG()
    local level = myHero:GetSpellData(_R).level
    local rdamage = GetPercentHP(target) > 33.3 and ({175, 250, 325})[level] + 0.75 * myHero.ap or ({350, 500, 650})[level] + 1.5 * myHero.ap; return rdamage +((0.015 * rdamage) * (100 - ((target.health / target.maxHealth) * 100)))

end



function Veigar:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Veigar", name = "PussyVeigar"})
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Combo:MenuElement({id = "WWait", name = "Only W when stunned", value = true})
	self.Menu.Combo:MenuElement({id = "EMode", name = "E Mode", drop = {"Edge", "Middle"}})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
		
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Harass:MenuElement({id = "AutoQ", name = "Auto Q Toggle", value = false, toggle = true, key = string.byte("U")})
	self.Menu.Harass:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	self.Menu.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Lasthit:MenuElement({id = "AutoQFarm", name = "Auto Q Farm", value = false, toggle = true, key = string.byte("Z")})
	self.Menu.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
	
	self.Menu:MenuElement({id = "Clear", name = "Clear", type = MENU})
	self.Menu.Clear:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.Clear:MenuElement({id = "WHit", name = "W hits x minions", value = 3,min = 1, max = 6, step = 1})
	self.Menu.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
	
	self.Menu:MenuElement({id = "Mana", name = "Mana", type = MENU})
	self.Menu.Mana:MenuElement({id = "QMana", name = "Min mana to use Q", value = 35, min = 0, max = 100, step = 1})
	self.Menu.Mana:MenuElement({id = "WMana", name = "Min mana to use W", value = 40, min = 0, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Killsteal:MenuElement({id = "UseW", name = "W", value = false})
	self.Menu.Killsteal:MenuElement({id = "UseIG", name = "Use Ignite", value = true})
	
	self.Menu.Killsteal:MenuElement({id = "RR", name = "UseR on killalble target:", value = true, type = MENU})
	for i, hero in pairs(GetEnemyHeroes()) do
	self.Menu.Killsteal.RR:MenuElement({id = "UseR"..hero.charName, name = "UseR" ..hero.charName, value = true})
	end


	self.Menu:MenuElement({id = "isCC", name = "CC Settings", type = MENU})
	self.Menu.isCC:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.isCC:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.isCC:MenuElement({id = "UseE", name = "E", value = false})
	self.Menu.isCC:MenuElement({id = "EMode", name = "E Mode", drop = {"Edge", "Middle"}})



	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	

end

function Veigar:Tick()
if myHero.dead == false and Game.IsChatOpen() == false then
local Mode = GetMode()
	if Mode == "Combo" then
		if self.Menu.Combo.comboActive:Value() then
			self:Combo()
		end
	elseif Mode == "Harass" then
		if self.Menu.Harass.harassActive:Value() then
			self:Harass()
		end
	elseif Mode == "Clear" then
		if self.Menu.Clear.clearActive:Value() then
			self:Clear()
		end	
	elseif Mode == "Flee" then
		
	end

	if self.Menu.Lasthit.lasthitActive:Value() then
		self:Lasthit()
	end

	
	if self.Menu.Killsteal.UseIG:Value() then
		self:UseIG()
	end
		self:KillstealQ()
		self:KillstealW()
		self:KillstealR()
		self:SpellonCCQ()
		self:SpellonCCE()
		self:SpellonCCW()
		self:AutoQ()
		self:AutoQFarm()
end
end

function Veigar:UseIG()
    local target = GetTarget(600)
	if self.Menu.Killsteal.UseIG:Value() and target then 
		local IGdamage = 80 + 25 * myHero.levelData.lvl
   		if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" then
       		if IsValid(target, 600, true, myHero) and self:CanCast(SUMMONER_1) then
				if IGdamage >= Veigar:HpPred(target, 1) + target.hpRegen * 3 then
					Control.CastSpell(HK_SUMMONER_1, target)
				end
       		end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
        	if IsValid(target, 600, true, myHero) and self:CanCast(SUMMONER_2) then
				if IGdamage >= Veigar:HpPred(target, 1) + target.hpRegen * 3 then
					Control.CastSpell(HK_SUMMONER_2, target)
				end
       		end
		end
	end
end

function Veigar:Clear()
	if self:CanCast(_Q) and self.Menu.Clear.UseW:Value() then
	local qMinions = {}
	local mobs = {}
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if IsValid(minion,900)  then
			if minion.team == 300 then
				mobs[#mobs+1] = minion
			elseif minion.isEnemy  then
				qMinions[#qMinions+1] = minion
			end	
	end	
		local BestPos, BestHit = GetBestCircularFarmPosition(50,112 + 80, qMinions)
		if BestHit >= self.Menu.Clear.WHit:Value() and self:CanCast(_W) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.WMana:Value() / 100 ) then
			Control.CastSpell(HK_W,BestPos)
		end
	end
end
end

function Veigar:Combo()
    local target = GetTarget(Q.Range)
    if target == nil then return end
    if self.Menu.Combo.UseQ:Value() and target and self:CanCast(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.QMana:Value() / 100 ) then
	    if EnemyInRange(Q.Range) then
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
		    if (HitChance > 0 ) then
				Control.CastSpell(HK_Q, castpos)
		    end
	    end
    end
	
	local target = GetTarget(E.Range)
    if target == nil then return end
	if self.Menu.Combo.UseE:Value() and target and self:CanCast(_E) then
		if EnemyInRange(E.Range) then
			if self.Menu.Combo.EMode:Value() == 1 then
				Control.CastSpell(HK_E, Vector(target:GetPrediction(E.Speed,E.Delay))-Vector(Vector(target:GetPrediction(E.Speed,E.Delay))-Vector(myHero.pos)):Normalized()*375) 
			elseif self.Menu.Combo.EMode:Value() == 2 then
				Control.CastSpell(HK_E,target)
			end
		end	
	end
	
	local target = GetTarget(W.Range)
    if target == nil then return end
    if self.Menu.Combo.UseW:Value() and target and self:CanCast(_W) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.WMana:Value() / 100 ) then
	    if EnemyInRange(W.Range) then
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range,W.Speed, myHero.pos, W.ignorecol, W.Type )
		    local ImmobileEnemy = IsImmobileTarget(target)
			if (HitChance > 0 ) then
				if self.Menu.Combo.WWait:Value() and ImmobileEnemy then 
					Control.CastSpell(HK_W, castpos)
				elseif self.Menu.Combo.WWait:Value() == false then 
					Control.CastSpell(HK_W, castpos)	
				end
			end
		end
    end
end	

function Veigar:Harass()
    local target = GetTarget(Q.Range)
    if target == nil then return end
    if self.Menu.Harass.UseQ:Value() and target and self:CanCast(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.QMana:Value() / 100 ) then
	    if EnemyInRange(Q.Range) then
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
		    if (HitChance > 0 ) then
				Control.CastSpell(HK_Q, castpos)
		    end
	    end
    end
 
	local target = GetTarget(W.Range)
    if target == nil then return end
    if self.Menu.Harass.UseW:Value() and target and self:CanCast(_W) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.WMana:Value() / 100 ) then
	    if EnemyInRange(W.Range) then
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range,W.Speed, myHero.pos, W.ignorecol, W.Type )
		    if (HitChance > 0 ) then
				Control.CastSpell(HK_W, castpos)
		    end
	    end
    end
end

function Veigar:AutoQ()
	local target = GetTarget(Q.Range)
	if target == nil then return end
	if self.Menu.Harass.AutoQ:Value() and target and self:CanCast(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.QMana:Value() / 100 ) then
		if EnemyInRange(Q.Range) then 
			local level = myHero:GetSpellData(_Q).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
			if (HitChance > 0 ) and self:CanCast(_Q) then
				Control.CastSpell(HK_Q, castpos)
				end
			end
		end
	end
	
function Veigar:AutoQFarm()
	if self:CanCast(_Q) and self.Menu.Lasthit.AutoQFarm:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Mana.QMana:Value() / 100 ) then
		local level = myHero:GetSpellData(_Q).level	
  		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local Qdamage = self:QDMG()
			if myHero.pos:DistanceTo(minion.pos) < Q.Range and minion.isEnemy and not minion.dead then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(minion, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
				if Qdamage >= self:HpPred(minion,1) and (HitChance > 0 ) then
				Control.CastSpell(HK_Q,minion.pos)
				end
			end
		end
	end
end

function Veigar:Lasthit()
	if self:CanCast(_Q) then
		local level = myHero:GetSpellData(_Q).level	
  		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local Qdamage = self:QDMG()
			if myHero.pos:DistanceTo(minion.pos) < Q.Range and self.Menu.Lasthit.UseQ:Value() and minion.isEnemy and not minion.dead then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(minion, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
				if Qdamage >= self:HpPred(minion,1) and (HitChance > 0 ) then
				Control.CastSpell(HK_Q,minion.pos)
				end
			end
		end
	end
end
	
function Veigar:KillstealR()
    local target = GetTarget(R.Range)
	if target == nil then return end
	if self.Menu.Killsteal.RR["UseR"..target.charName]:Value() and self:CanCast(_R) and EnemyInRange(R.Range) then   
		local level = myHero:GetSpellData(_R).level	
		local dmg = GetPercentHP(target) > 33.3 and ({175, 250, 325})[level] + 0.75 * myHero.ap or ({350, 500, 650})[level] + 1.50 * myHero.ap
		local Rdamage = dmg +((0.015 * dmg) * (100 - ((target.health / target.maxHealth) * 100)))

		if Rdamage >= self:HpPred(target,1) * 1.2 + target.hpRegen * 2 then
			Control.CastSpell(HK_R, target)
		end
	end
end
	
function Veigar:KillstealQ()
	local target = GetTarget(Q.Range)
	if target == nil then return end
	if self.Menu.Killsteal.UseQ:Value() and target and self:CanCast(_Q) then
		if EnemyInRange(Q.Range) then 
			local level = myHero:GetSpellData(_Q).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
		   	local Qdamage = Veigar:QDMG()
			if Qdamage >= self:HpPred(target,1) + target.hpRegen * 1 and not target.dead then
			if (HitChance > 0 ) then
				Control.CastSpell(HK_Q, castpos)
				end
			end
		end
	end
end

function Veigar:KillstealW()
	local target = GetTarget(W.Range)
	if target == nil then return end
	if self.Menu.Killsteal.UseW:Value() and target and self:CanCast(_W) then
		if EnemyInRange(W.Range) then 
			local level = myHero:GetSpellData(_Q).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range, W.Speed, myHero.pos, W.ignorecol, W.Type )
		   	local Wdamage = self:WDMG()
			if Wdamage >= self:HpPred(target,1) + target.hpRegen * 1 and not target.dead then
			if (HitChance > 0 ) then
				Control.CastSpell(HK_W, castpos)
				end
			end
		end
	end
end


function Veigar:SpellonCCQ()
    local target = GetTarget(Q.Range)
	if target == nil then return end
	if self.Menu.isCC.UseQ:Value() and target and self:CanCast(_Q) then
		if EnemyInRange(Q.Range) then 
			local ImmobileEnemy = IsImmobileTarget(target)
			local level = myHero:GetSpellData(_Q).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
			if ImmobileEnemy then
			if (HitChance > 0 ) and not target.dead then
				Control.CastSpell(HK_Q, castpos)
				end
			end
		end
	end
end

function Veigar:SpellonCCE()
	local target = GetTarget(E.Range)
    if target == nil then return end
    if self.Menu.isCC.UseE:Value() and target and self:CanCast(_E) then
		local ImmobileEnemy = IsImmobileTarget(target)
	    if EnemyInRange(E.Range) and ImmobileEnemy then
		if self.Menu.isCC.EMode:Value() == 1 then
			Control.CastSpell(HK_E, Vector(target:GetPrediction(E.speed,E.delay))-Vector(Vector(target:GetPrediction(E.speed,E.delay))-Vector(myHero.pos)):Normalized()*375)
		elseif self.Menu.isCC.EMode:Value() == 2 then
			Control.CastSpell(HK_E,target)
		end
    end	
 end
 end

function Veigar:SpellonCCW()
	local target = GetTarget(W.Range)
	if target == nil then return end
	if self.Menu.isCC.UseW:Value() and target and self:CanCast(_W) then
		if EnemyInRange(W.Range) then 
			local ImmobileEnemy = IsImmobileTarget(target)
			local level = myHero:GetSpellData(_W).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range, W.Speed, myHero.pos, W.ignorecol, W.Type )
			if (HitChance > 0 ) and ImmobileEnemy then
				Control.CastSpell(HK_W, castpos)
				end
			end
		end
	end





-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Warwick"



require "DamageLib"

local barHeight = 8
local barWidth = 103
local barXOffset = 0
local barYOffset = 0

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end
		
function Warwick:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Warwick:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Warwick:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Warwick:QDmg()
	total = 0
	local qLvl = myHero:GetSpellData(_Q).level
    if qLvl > 0 then
	local qdamage = 1.2 * myHero.totalDamage + 0.9 * myHero.ap + (({6, 6.5, 7, 7.5, 8})[qLvl] / 100  * target.maxHealth)
	total = qdamage
	end
	return total

end

function Warwick:RDmg()
	total = 0
	local rLvl = myHero:GetSpellData(_R).level
    if rLvl > 0 then
	local rdamage = (({175,350,525})[rLvl] + 1.67 * myHero.totalDamage)
	total = rdamage
	end
	return total

end

function Warwick:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

function Warwick:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function Warwick:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }

end

function Warwick:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "PussyWarwick", name = "PussyWarwick"})
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.ComboMode:MenuElement({id = "Key", name = "Toggle: E Insta -- Delay Key", key = string.byte("T"), toggle = true})
	self.Menu.ComboMode:MenuElement({id = "UseR", name = "R: Infinite Duress", value = true})
	self.Menu.ComboMode:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.ComboMode:MenuElement({id = "UseHYDRA", name = "Use hydra", value = true})
	self.Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw Killable", value = true})
	self.Menu.ComboMode:MenuElement({id = "DrawRange", name = "Draw RRange", value = true})	
		
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.HarassMode:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})

	self.Menu:MenuElement({id = "ClearMode", name = "Clear", type = MENU})
	self.Menu.ClearMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.ClearMode:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
		
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 100, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
end

function Warwick:Tick()
if myHero.dead == false and Game.IsChatOpen() == false then
	local Mode = GetMode()
		if Mode == "Combo" then
			if self.Menu.ComboMode.comboActive:Value() then
				self:Combo()
			end

		elseif Mode == "Harass" then
			if self.Menu.HarassMode.harassActive:Value() then
				self:Harass()
			end
		elseif Mode == "Clear" then
			if self.Menu.ClearMode.clearActive:Value() then
				self:Jungle()
			end
		elseif Mode == "Flee" then
		
		end

	if self.Menu.ComboMode.DrawDamage:Value() then
	self:Draw()
	end
end	
end	

function Warwick:Draw()
    local textPos = myHero.pos:To2D()
    if self.Menu.ComboMode.DrawRange:Value() and self:CanCast(_R) then Draw.Circle(myHero.pos, (2.5 * myHero.ms), Draw.Color(255, 000, 222, 255)) end
	if self.Menu.ComboMode.DrawDamage:Value() then
		for i, hero in pairs(GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (self:CanCast(_Q) and self:QDmg() or 0)
				local RDamage = (self:CanCast(_R) and self:RDmg() or 0)
				local damage = QDamage + RDamage
				if damage > self:HpPred(hero,1) + hero.hpRegen * 1 then
					Draw.Text("killable", 24, hero.pos2D.x, hero.pos2D.y,Draw.Color(0xFF00FF00))
					
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, Draw.Color(0xFF00FF00))
				end
			end
		end	
	end
	if self.Menu.ComboMode.Key:Value() then
		Draw.Text("Insta E: On", 20, textPos.x - 33, textPos.y + 50, Draw.Color(255, 000, 255, 000)) 
	else
		Draw.Text("Insta E: Off", 20, textPos.x - 33, textPos.y + 50, Draw.Color(255, 225, 000, 000)) 
	end
end

function UseHydra()
	local HTarget = GetTarget(300)
	if HTarget then 
		local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
		if hydraitem and myHero.attackData.state == STATE_WINDDOWN then
			Control.CastSpell(keybindings[hydraitem],HTarget.pos)
            Control.Attack(HTarget)
		end
	end
end
   
function UseHydraminion()
    for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
        if minion and minion.team == 300 or minion.team ~= myHero.team then 
			local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
			if hydraitem and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(keybindings[hydraitem])
                Control.Attack(minion)
			end
		end
    end
end

function Warwick:Combo()
    if self.Menu.ComboMode.UseHYDRA:Value() and HasBuff(myHero, "Blood Hunt") and EnemyInRange(300) then
        if myHero.attackData.state == STATE_WINDDOWN then
            UseHydra()
        end
    end

    if self:CanCast(_E) then 
		local ETarget = GetTarget(375)
		if self.Menu.ComboMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == false and ETarget and HasBuff(myHero, "Primal Howl") then
			if EnemyInRange(375) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
        if self.Menu.ComboMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == true and ETarget and not HasBuff(myHero, "Primal Howl") then
			if EnemyInRange(375) and self:CanCast(_E) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
	end

	if self:CanCast(_Q) and EnemyInRange(350) then 
		local QTarget = GetTarget(350)
		if self.Menu.ComboMode.UseQ:Value() and QTarget then
            if EnemyInRange(350) and myHero.pos:DistanceTo(QTarget.pos) < 350 and myHero.pos:DistanceTo(QTarget.pos) > 125 then
				Control.CastSpell(HK_Q, QTarget)
            end
		end
	end

    if self:CanCast(_R) then 
        local rRange = 2.5 * myHero.ms
		local RTarget = GetTarget(rRange)
        if self.Menu.ComboMode.UseR:Value() and RTarget then
			if EnemyInRange(rRange) and myHero.pos:DistanceTo(RTarget.pos) < rRange then
				Control.CastSpell(HK_R, RTarget)
			end	
        end
    end
	

    if EnemyInRange(600) and not self:CanCast(_Q) then 
        local BTarget = GetTarget(600)
        if BTarget then
            if myHero.pos:DistanceTo(BTarget.pos) < 600 then
			    UseHydra()
            end
        end
    end
end

function Warwick:Harass()
    if self.Menu.ComboMode.UseHYDRA:Value() and HasBuff(myHero, "Blood Hunt") and EnemyInRange(300) then
        if myHero.attackData.state == STATE_WINDDOWN then
            UseHydra()
        end
    end
    if self:CanCast(_E) then 
		local ETarget = GetTarget(375)
		if self.Menu.HarassMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == false and ETarget and HasBuff(myHero, "Primal Howl") then
			if EnemyInRange(375) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
        if self.Menu.HarassMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == true and ETarget and not HasBuff(myHero, "Primal Howl") then
			if EnemyInRange(375) and self:CanCast(_E) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
	end

	if self:CanCast(_Q) then 
		local QTarget = GetTarget(350)
		if self.Menu.HarassMode.UseQ:Value() and QTarget then
            if EnemyInRange(350) and myHero.pos:DistanceTo(QTarget.pos) < 350 and myHero.pos:DistanceTo(QTarget.pos) > 125 then
				Control.CastSpell(HK_Q, QTarget)
            end
		end
	end

	if self:CanCast(_W) then 
		local WTarget = GetTarget(125)
		if self.Menu.HarassMode.UseW:Value() and WTarget then
			if EnemyInRange(125) and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_W)
                Control.Attack(WTarget)
			end
		end
	end
end

function Warwick:Jungle()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    if minion and minion.team == 300 or minion.team ~= myHero.team then
    if self:CanCast(_E) and minion then 
		if self.Menu.ClearMode.UseE:Value() and self.Menu.ComboMode.Key:Value()  == false and HasBuff(myHero, "Primal Howl") then
			if myHero.pos:DistanceTo(minion.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
        if self.Menu.ClearMode.UseE:Value() and self.Menu.ComboMode.Key:Value()  == true and not HasBuff(myHero, "Primal Howl") then
			if myHero.pos:DistanceTo(minion.pos) < 375 and self:CanCast(_E) then
				Control.CastSpell(HK_E)
			end
		end
	end	

    if self.Menu.ComboMode.UseHYDRA:Value() and not HasBuff(myHero, "Blood Hunt") and minion then
        if myHero.attackData.state == STATE_WINDDOWN and not self:CanCast(_W) and myHero.pos:DistanceTo(minion.pos) < 300 then
            UseHydraminion()
        end
    end
	if self:CanCast(_Q) and minion then 
		if self.Menu.ClearMode.UseQ:Value() and IsValid(minion, 350) then
            if myHero.pos:DistanceTo(minion.pos) < 350 and myHero.pos:DistanceTo(minion.pos) > 125 then
				Control.CastSpell(HK_Q, minion)
            end
		end
	end

	if self:CanCast(_W) and minion then 
		if self.Menu.ClearMode.UseW:Value() and IsValid(minion, 175) then
			if myHero.pos:DistanceTo(minion.pos) < 175 and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_W)
                Control.Attack(minion)
			end
		end
	end
	end
	end
end




--------------------------------------------------------------------------------------------------------------------------------------------------------------



class "XinZhao"



require 'Collision'

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
end

function XinZhao:GetValidEnemy(range)
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < E.range then
            return true
        end
    end
    return false
end

function XinZhao:GetValidMinion(range)
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < E.range then
            return true
        end
    end
    return false
end

function XinZhao:isReady(spell)
return Game.CanUseSpell(spell) == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function XinZhao:EDMG(unit)
	total = 0
	local eLvl = myHero:GetSpellData(_E).level
    if eLvl > 0 then
	local edamage = (({50,75,100,125,150})[eLvl] + 0.6 * myHero.ap)
	total = edamage
	end
	return total
end

function XinZhao:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function XinZhao:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end	
end

function XinZhao:LoadSpells()
	Q = {range = 375}
	W = {range = 900, Delay = 0.30, Width = 70, Speed = 1600, Collision = false, aoe = false}
	E = {range = 650}
	R = {range = 500}
end



function XinZhao:LoadMenu()
	--Main Menu
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "PussyXinZhao"})
	
	--Main Menu-- PussyXinZhao
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "PussyXinZhao"})
	--Main Menu-- PussyXinZhao -- Combo
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "UseW if Target Flee", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "E", name = "Use E", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "R", name = "Use R", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "RHP", name = "R when target HP%", value = 20, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo:MenuElement({id = "myRHP", name = "R when XinZhao HP%", value = 30, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo:MenuElement({type = MENU, id = "Spell", name = "Summoners and Activator"})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "I", name = "Use Ignite", value = true})		
	self.Menu.Mode.Combo.Spell:MenuElement({id = "IMode", name = "Ignite Mode", drop = {"Killable", "Custom"}})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "IHP", name = "Ignite when target HP%", value = 50, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "S", name = "Use Smite", value = true})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "SMode", name = "Smite Mode", drop = {"Killable", "Custom"}, tooltip = "Will cast on Killable mode just if you have blue Smite"})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "SHP", name = "Smite when target HP%", value = 50, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "EX", name = "Use Exhaust", value = true})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "EXHP", name = "Exhaust when target HP%", value = 50, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "Hydra", name = "Use Hydra or Tiamat", value = true})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "King", name = "Use Botrk", value = true})	
	self.Menu.Mode.Combo.Spell:MenuElement({id = "Cutless", name = "Use Cutless", value = true})	
	--Main Menu-- PussyXinZhao -- Harass
	self.Menu.Mode:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	self.Menu.Mode.Harass:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.Harass:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.Harass.MM:MenuElement({id = "WMana", name = "Min Mana to W in Harass(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- PussyXinZhao -- LaneClear
	self.Menu.Mode:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
	self.Menu.Mode.LaneClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "WMinion", name = "Use W when X minions", value = 3,min = 1, max = 4, step = 1})
	self.Menu.Mode.LaneClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "E", name = "Use E", value = true})
	--Main Menu-- PussyXinZhao -- JungleClear
	self.Menu.Mode:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
	self.Menu.Mode.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "E", name = "Use E", value = true})
	
	--Main Menu-- PussyXinZhao -- KillSteal
	self.Menu.Mode:MenuElement({type = MENU, id = "KS", name = "KillSteal"})
	self.Menu.Mode.KS:MenuElement({id = "E", name = "UseE KS", value = true})	
	
	--Main Menu-- PussyXinZhao -- Spell Range 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Spell Range"})
	self.Menu.Drawing:MenuElement({id = "E", name = "Draw E Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
	self.Menu.Drawing:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
end

function XinZhao:Tick()
if myHero.dead == false and Game.IsChatOpen() == false then
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
	elseif Mode == "Flee" then
		
	end	
		
	self:KS()
end
end

function XinZhao:KS()
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
	local edamage = self:EDMG(target)
		if edamage > self:HpPred(target,1) + target.hpRegen * 1 then
			if IsValid(target,650) and myHero.pos:DistanceTo(target.pos) <= 650 and self.Menu.Mode.KS.E:Value() and self:isReady(_E) and not myHero.isChanneling  then
				Control.CastSpell(HK_E,target)
		end
	end			
end

function XinZhao:Combo()

	if self:GetValidEnemy(800) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
			if IsValid(target,650) and myHero.pos:DistanceTo(target.pos) <= 650 and self.Menu.Mode.Combo.E:Value() and self:isReady(_E) and not myHero.isChanneling  then
			Control.CastSpell(HK_E,target)
	    	if IsValid(target,900) and myHero.pos:DistanceTo(target.pos) > 400 and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
			Control.CastSpell(HK_W,target)
	    	end
	    	if IsValid(target,375) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
			Control.CastSpell(HK_Q)
	    	end 
	    	if IsValid(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and target.health/target.maxHealth <= self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
			Control.CastSpell(HK_R)
	    	end
	    end		
		if IsValid(target,900) and myHero.pos:DistanceTo(target.pos) > 400 and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W,target)
	    	if IsValid(target,375) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
		Control.CastSpell(HK_Q)
	    	end
	    	if IsValid(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and target.health/target.maxHealth <= self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    	end
	    end	
	    if IsValid(target,375) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
		Control.CastSpell(HK_Q)
	    	if IsValid(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and target.health/target.maxHealth <= self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    	end
	    end   
		if IsValid(target,R.range) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and target.health/target.maxHealth <= self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    end
		if IsValid(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and not myHero.isChanneling and
		myHero.health/myHero.maxHealth <= self.Menu.Mode.Combo.myRHP:Value()/100 then
		Control.CastSpell(HK_R)
		end
		

	local TIA = GetInventorySlotItem(3077),(3748),(3074)
	if TIA and self.Menu.Mode.Combo.Spell.Hydra:Value() and myHero.pos:DistanceTo(target.pos) < 300 then
	Control.CastSpell(HKITEM[TIA], target)
	end
	local KING = GetInventorySlotItem(3153) 
	if KING and self.Menu.Mode.Combo.Spell.King:Value() and myHero.pos:DistanceTo(target.pos) < 600  then
	Control.CastSpell(HKITEM[KING], target)
	end
	local CUT = GetInventorySlotItem(3144)
	if CUT and self.Menu.Mode.Combo.Spell.Cutless:Value() and myHero.pos:DistanceTo(target.pos) < 600  then
	Control.CastSpell(HKITEM[CUT], target)
	end
	
	
		
			
		
		
		
	if self.Menu.Mode.Combo.Spell.I:Value() then 
   		if self.Menu.Mode.Combo.Spell.IMode:Value() == 2 and myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and self:isReady(SUMMONER_1) then
       		if IsValid(target, 600, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.IHP:Value()/100 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif  self.Menu.Mode.Combo.Spell.IMode:Value() == 2 and myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and self:isReady(SUMMONER_2) then
        	if IsValid(target, 600, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.IHP:Value()/100 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end
		elseif  self.Menu.Mode.Combo.Spell.IMode:Value() == 1 and myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and self:isReady(SUMMONER_1) then
       	 	if IsValid(target, 600, true, myHero) and 50+20*myHero.levelData.lvl -(target.hpRegen*3) > target.health*1.1 then
           		Control.CastSpell(HK_SUMMONER_1, target)
       	 	end
		elseif self.Menu.Mode.Combo.Spell.IMode:Value() == 1  and myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and self:isReady(SUMMONER_2) then
       		 if IsValid(target, 600, true, myHero) and 50+20*myHero.levelData.lvl - (target.hpRegen*3) > target.health*1.1 then
           		Control.CastSpell(HK_SUMMONER_2, target)
        	end
    	end 
    end
    if self.Menu.Mode.Combo.Spell.S:Value() then 
   		if self.Menu.Mode.Combo.Spell.SMode:Value() == 2 and myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel"  and self:isReady(SUMMONER_1) then
       		if IsValid(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.SHP:Value()/100 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif  self.Menu.Mode.Combo.Spell.SMode:Value() == 2 and myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmiteDuel" and self:isReady(SUMMONER_2) then
        	if IsValid(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.SHP:Value()/100 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end	
    end
    if self.Menu.Mode.Combo.Spell.S:Value() then 
   		if self.Menu.Mode.Combo.Spell.SMode:Value() == 2 and myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker"  and self:isReady(SUMMONER_1) then
       		if IsValid(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.SHP:Value()/100 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif  self.Menu.Mode.Combo.Spell.SMode:Value() == 2 and myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and self:isReady(SUMMONER_2) then
        	if IsValid(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.SHP:Value()/100 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end
       	elseif  self.Menu.Mode.Combo.Spell.SMode:Value() == 1 and myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" and self:isReady(SUMMONER_1) then
       	 	if IsValid(target, 500, true, myHero) and 20+8*myHero.levelData.lvl > target.health*1 then
           		Control.CastSpell(HK_SUMMONER_1, target)
       	 	end
		elseif self.Menu.Mode.Combo.Spell.SMode:Value() == 1  and myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and self:isReady(SUMMONER_2) then
       		 if IsValid(target, 500, true, myHero) and 20+8*myHero.levelData.lvl > target.health*1 then
           		Control.CastSpell(HK_SUMMONER_2, target)
        	end
    	end 
    end
    if self.Menu.Mode.Combo.Spell.EX:Value() then 
   		if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"  and self:isReady(SUMMONER_1) then
       		if IsValid(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.EXHP:Value()/100 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif  myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and self:isReady(SUMMONER_2) then
        	if IsValid(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.EXHP:Value()/100 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end
       	end		
    end
end
end	


function XinZhao:Harass()

	if self:GetValidEnemy(800) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	    if target.pos:DistanceTo(myHero.pos) <= W.range and (myHero.mana/myHero.maxMana >= self.Menu.Mode.Harass.MM.WMana:Value() / 100) and self.Menu.Mode.Harass.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W,target)
	end
end



function XinZhao:Clear()

	if self:GetValidMinion(600) == false then return end
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
			if minion.team == 300 - myHero.team then
				if minion.pos:DistanceTo(myHero.pos) <= E.range and self.Menu.Mode.LaneClear.E:Value() and self:isReady(_E) then
					Control.CastSpell(HK_E,minion)
					break
				end	
				if IsValid(minion,W.range) and self.Menu.Mode.LaneClear.W:Value() and self:isReady(_W) then
					if GetMinionCount(W.range, minion.pos) >= self.Menu.Mode.LaneClear.WMinion:Value() then
						Control.CastSpell(HK_W,minion)
						break
					end	
				end
				if IsValid(minion,Q.range) and self.Menu.Mode.LaneClear.Q:Value() and self:isReady(_Q) then
					Control.CastSpell(HK_Q)
					break
				end

			elseif minion.team == 300 then
				if  minion.pos:DistanceTo(myHero.pos) <= E.range and self.Menu.Mode.JungleClear.E:Value() and self:isReady(_E) then
					Control.CastSpell(HK_E,minion)
					break
				end
				if IsValid(minion,Q.range) and self.Menu.Mode.JungleClear.Q:Value() and self:isReady(_Q) then
				Control.CastSpell(HK_Q)
				break
				end 
				if IsValid(minion,W.range) and self.Menu.Mode.JungleClear.W:Value() and self:isReady(_W) then
					Control.CastSpell(HK_W,minion)
					break
				end	
			end
		end
	end
	
function XinZhao:Draw()
if myHero.dead then return end
	if self.Menu.Drawing.E:Value() then 
		Draw.Circle(myHero.pos, 650, self.Menu.Drawing.Width:Value(), self.Menu.Drawing.Color:Value())	
	end	
end	




--------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Zyra"



if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')

local EData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1100, Speed = 1150, 
Collision = false, MaxCollision = 0, CollisionTypes = { _G.COLLISION_YASUOWALL }
}

local QData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.85, Radius = 140, Range = 800, Speed = math.huge, Collision = false
}

local RData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 2.0, Radius = 500, Range = 700, Speed = math.huge, Collision = false
}

function Zyra:__init()
if menu ~= 1 then return end
	menu = 2   	
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end) 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function Zyra:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Zyra", name = "PussyZyra"})

	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "Auto[E] on Immobile Target"})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})		
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Rampant Growth", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})			
	
	--UltSettings
	self.Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	self.Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R] Stranglethorns", value = true})
	self.Menu.Combo.Ult:MenuElement({id = "UseRE", name = "Use [R] min Targets", value = 2, min = 1, max = 6})
	self.Menu.Combo.Ult:MenuElement({id = "killR", name = "Use[R] Killable Target", value = false})
	self.Menu.Combo.Ult:MenuElement({id = "Immo", name = "Use[R]Immobile Targets > 2", value = true})	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W] Rampant Growth", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})  	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "ks"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})	
	self.Menu.ks:MenuElement({id = "UseEQ", name = "[E]+[Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseIgn", name = "Ignite", value = true})

	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", name = "Activator"})		
	self.Menu.a:MenuElement({id = "ON", name = "Zhonyas/StopWatch", value = true})	
	self.Menu.a:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Zyra:Tick()
if myHero.dead == false and Game.IsChatOpen() == false then
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
	elseif Mode == "Flee" then
		
	end	
	self:Activator()
	self:KillSteal()
	self:AutoE()
	self:AutoR()
	self:ImmoR()	
	self:UseW()
end
end 

function Zyra:UseW()
local target = GetTarget(1200)     	
if target == nil then return end		
	if IsValid(target,1200) and Ready(_W) then
		if myHero.pos:DistanceTo(target.pos) <= 850 then
			if IsImmobileTarget(target) then   
				DelayAction(function() 
				Control.CastSpell(HK_W, target.pos) 
				Control.CastSpell(HK_W, target.pos)
		
				end, 0.05)
			end
		end	
	end
end

function Zyra:AutoE()
local target = GetTarget(1200)     	
if target == nil then return end	
local pred = GetGamsteronPrediction(target, EData, myHero)	
	if IsValid(target,1200) and self.Menu.AutoE.UseE:Value() and Ready(_E) then
		if IsImmobileTarget(target) and myHero.pos:DistanceTo(target.pos) <= 1000 and pred.Hitchance >= _G.HITCHANCE_HIGH then
			self:UseW()
			Control.CastSpell(HK_E, pred.CastPosition)
		end	
	end
end

function Zyra:AutoR()
local target = GetTarget(1200)     	
if target == nil then return end
local hp = target.health
local RDmg = getdmg("R", target, myHero)
local QDmg = getdmg("Q", target, myHero)
local EDmg = getdmg("E", target, myHero)
local damage = RDmg + QDmg + EDmg + 300
local pred = GetGamsteronPrediction(target, RData, myHero)	
	if IsValid(target,1200) and self.Menu.Combo.Ult.killR:Value() and Ready(_R) then
		if myHero.pos:DistanceTo(target.pos) <= 700 and damage >= hp and pred.Hitchance >= _G.HITCHANCE_NORMAL then
			Control.CastSpell(HK_R, pred.CastPosition)
		end	
	end
end	

function Zyra:ImmoR()
local target = GetTarget(1200)     	
if target == nil then return end
local count = GetImmobileCount(500, target)
local pred = GetGamsteronPrediction(target, RData, myHero)	
	if IsValid(target,1200) and self.Menu.Combo.Ult.Immo:Value() and Ready(_R) then
		if myHero.pos:DistanceTo(target.pos) <= 700 and count >= 2 and pred.Hitchance >= _G.HITCHANCE_NORMAL then
			Control.CastSpell(HK_R, pred.CastPosition)
		end	
	end
end

function Zyra:Activator()

			--Zhonyas
	if EnemiesAround(myHero.pos,2000) then	
		if self.Menu.a.ON:Value() then
		local Zhonyas = GetItemSlot(myHero, 3157)
			if Zhonyas > 0 and Ready(Zhonyas) then 
				if myHero.health/myHero.maxHealth <= self.Menu.a.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
			--Stopwatch
		if self.Menu.a.ON:Value() then
		local Stop = GetItemSlot(myHero, 2420)
			if Stop > 0 and Ready(Stop) then 
				if myHero.health/myHero.maxHealth <= self.Menu.a.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Stop])
				end
			end
		end
	end
end	
			
function Zyra:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 700, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 850, 1, Draw.Color(225, 225, 125, 10))
	end
end
       
function Zyra:KillSteal()	
	local target = GetTarget(1200)     	
	if target == nil then return end
	local hp = target.health
	local QDmg = getdmg("Q", target, myHero)
	local EDmg = getdmg("E", target, myHero)
	local EQDmg = QDmg + EDmg
	if IsValid(target,1200) then	
		
		if self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 800 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				self:UseW()
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.ks.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if EDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 1000 and pred.Hitchance >= _G.HITCHANCE_HIGH then			
				self:UseW()
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
		if self.Menu.ks.UseEQ:Value() and Ready(_E) and Ready(_Q) then
			local Epred = GetGamsteronPrediction(target, EData, myHero)
			local Qpred = GetGamsteronPrediction(target, QData, myHero)
			if EQDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 800 then
				self:UseW()
				if Epred.Hitchance >= _G.HITCHANCE_HIGH then
					Control.CastSpell(HK_E, Epred.CastPosition)
				if Qpred.Hitchance >= _G.HITCHANCE_HIGH then	
					Control.CastSpell(HK_Q, Qpred.CastPosition)
				end
				end
			end
		end
		if self.Menu.ks.UseIgn:Value() then 
			local IGdamage = 80 + 25 * myHero.levelData.lvl
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and myHero.pos:DistanceTo(target.pos) <= 600 then
				if Ready(SUMMONER_1) then
					if IGdamage >= hp + target.hpRegen * 3 then
						Control.CastSpell(HK_SUMMONER_1, target)
					end
				end
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and myHero.pos:DistanceTo(target.pos) <= 600  then
				if Ready(SUMMONER_2) then
					if IGdamage >= hp + target.hpRegen * 3 then
						Control.CastSpell(HK_SUMMONER_2, target)
					end
				end
			end
		end
	end
end	

function Zyra:Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target,1200) then

		if self.Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 850 then
				DelayAction(function() 
				Control.CastSpell(HK_W, target.pos) 
				Control.CastSpell(HK_W, target.pos)
		
				end, 0.05)
			end
		end			
		
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 800 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if self.Menu.Combo.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1000 and pred.Hitchance >= _G.HITCHANCE_HIGH then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
		
		if Ready(_R) and self.Menu.Combo.Ult.UseR:Value() then
			local pred = GetGamsteronPrediction(target, RData, myHero)
			local count = GetEnemyCount(500, target)
			if myHero.pos:DistanceTo(target.pos) <= 700 and count >= self.Menu.Combo.Ult.UseRE:Value() and pred.Hitchance >= _G.HITCHANCE_NORMAL then
				Control.CastSpell(HK_R, pred.CastPosition)
			end
		end
	end
end	

function Zyra:Harass()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target,1200) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 800 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				self:UseW()
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1000 and pred.Hitchance >= _G.HITCHANCE_HIGH then			
				self:UseW()
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
	end
end	

function Zyra:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local TEAM_ALLY = myHero.team
	local TEAM_ENEMY = 300 - myHero.team
		if IsValid(minion, 1200) and minion.team == TEAM_ENEMY and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then					
			
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 800 and self.Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	

			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1100 and self.Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

function Zyra:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	local TEAM_JUNGLE = 300
		if IsValid(minion, 1200) and minion.team == TEAM_JUNGLE and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 800 and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1100 and self.Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end







-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Dmg Lib


function GetBaseHealth(unit)
    if unit.charName == "Sylas" then
        return 504.73 + 80.27 * myHero.levelData.lvl
    end
end



local DamageReductionTable = {
  ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level] end},
  ["Urgot"] = {buff = "urgotswapdef", amount = function(target) return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level] end},
  ["Alistar"] = {buff = "Ferocious Howl", amount = function(target) return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level] end},
  ["Amumu"] = {buff = "Tantrum", amount = function(target) return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level] end, damageType = 1},
  ["Galio"] = {buff = "GalioIdolOfDurand", amount = function(target) return 0.5 end},
  ["Garen"] = {buff = "GarenW", amount = function(target) return 0.7 end},
  ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level] end},
  ["Annie"] = {buff = "MoltenShield", amount = function(target) return 1 - ({0.16,0.22,0.28,0.34,0.4})[target:GetSpellData(_E).level] end},
  ["Kayle"] = {buff = "Kaylepassiveshield", amount = function(target) return 0.1 end}
}

function GetPercentHP(unit)
  return 100 * unit.health / unit.maxHealth
end

function string.ends(String,End)
  return End == "" or string.sub(String,-string.len(End)) == End
end

function GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0
end

function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff.count
    end
  end
  return 0
end

function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function CalcPhysicalDamage(source, target, amount)
  local ArmorPenPercent = source.armorPenPercent
  local ArmorPenFlat = (0.4 + target.levelData.lvl / 30) * source.armorPen
  local BonusArmorPen = source.bonusArmorPenPercent

  if source.type == Obj_AI_Minion then
    ArmorPenPercent = 1
    ArmorPenFlat = 0
    BonusArmorPen = 1
  elseif source.type == Obj_AI_Turret then
    ArmorPenFlat = 0
    BonusArmorPen = 1
    if source.charName:find("3") or source.charName:find("4") then
      ArmorPenPercent = 0.25
    else
      ArmorPenPercent = 0.7
    end
  end

  if source.type == Obj_AI_Turret then
    if target.type == Obj_AI_Minion then
      amount = amount * 1.25
      if string.ends(target.charName, "MinionSiege") then
        amount = amount * 0.7
      end
      return amount
    end
  end

  local armor = target.armor
  local bonusArmor = target.bonusArmor
  local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)

  if armor < 0 then
    value = 2 - 100 / (100 - armor)
  elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 1)))
end

function CalcMagicalDamage(source, target, amount)
  local mr = target.magicResist
  local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)

  if mr < 0 then
    value = 2 - 100 / (100 - mr)
  elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 2)))
end

function DamageReductionMod(source,target,amount,DamageType)
  if source.type == Obj_AI_Hero then
    if GotBuff(source, "Exhaust") > 0 then
      amount = amount * 0.6
    end
  end

  if target.type == Obj_AI_Hero then

    for i = 0, target.buffCount do
      if target:GetBuff(i).count > 0 then
        local buff = target:GetBuff(i)
        if buff.name == "MasteryWardenOfTheDawn" then
          amount = amount * (1 - (0.06 * buff.count))
        end
    
        if DamageReductionTable[target.charName] then
          if buff.name == DamageReductionTable[target.charName].buff and (not DamageReductionTable[target.charName].damagetype or DamageReductionTable[target.charName].damagetype == DamageType) then
            amount = amount * DamageReductionTable[target.charName].amount(target)
          end
        end

        if target.charName == "Maokai" and source.type ~= Obj_AI_Turret then
          if buff.name == "MaokaiDrainDefense" then
            amount = amount * 0.8
          end
        end

        if target.charName == "MasterYi" then
          if buff.name == "Meditate" then
            amount = amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpellData(_W).level] / (source.type == Obj_AI_Turret and 2 or 1)
          end
        end
      end
    end

    if GetItemSlot(target, 1054) > 0 then
      amount = amount - 8
    end

    if target.charName == "Kassadin" and DamageType == 2 then
      amount = amount * 0.85
    end
  end

  return amount
end

function PassivePercentMod(source, target, amount, damageType)
  local SiegeMinionList = {"Red_Minion_MechCannon", "Blue_Minion_MechCannon"}
  local NormalMinionList = {"Red_Minion_Wizard", "Blue_Minion_Wizard", "Red_Minion_Basic", "Blue_Minion_Basic"}

  if source.type == Obj_AI_Turret then
    if table.contains(SiegeMinionList, target.charName) then
      amount = amount * 0.7
    elseif table.contains(NormalMinionList, target.charName) then
      amount = amount * 1.14285714285714
    end
  end
  if source.type == Obj_AI_Hero then 
    if target.type == Obj_AI_Hero then
      if (GetItemSlot(source, 3036) > 0 or GetItemSlot(source, 3034) > 0) and source.maxHealth < target.maxHealth and damageType == 1 then
        amount = amount * (1 + math.min(target.maxHealth - source.maxHealth, 500) / 50 * (GetItemSlot(source, 3036) > 0 and 0.015 or 0.01))
      end
    end
  end
  return amount
end

function WLvLDMG()
    total = 0
	local Lvl = myHero.levelData.lvl
    if Lvl > 0 then
	local damage = (1.5) + (3.5 * Lvl) 
	total = damage 
	end
	return total
end

local QLvL = WLvLDMG()

local DamageLibTable = {

	["Kayle"] = {  
	{Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.5 * source.ap + 0.6 * source.bonusDamage end},
	{Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 15, 20, 25, 30})[level] + 0.2 * source.ap + 0.1 * source.totalDamage + source.totalDamage + ({10, 12, 15, 17, 20})[level] / 100 * (target.maxHealth - target.health) end},   
	{Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({10, 15, 20, 25, 30})[level] + 0.2 * source.ap + 0.1 * source.totalDamage + source.totalDamage +({10, 12, 15, 17, 20})[level] / 100 * (target.maxHealth - target.health)) + ({10, 15, 20, 25, 30})[level] + 0.2 * source.ap + 0.1 * source.totalDamage  end},	
	{Slot = "E", Stage = 3, DamageType = 3, Damage = function(source, target, level) return ({10, 15, 20, 25, 30})[level] + 0.2 * source.ap + 0.1 * source.totalDamage end},	
	{Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 350, 500})[level] + 0.8 * source.ap + source.bonusDamage  end},

  },
    ["Kassadin"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 95, 125, 155, 185})[level] + 0.7 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.8 * source.ap end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return 20 + 0.1 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 105, 130, 155, 180})[level] + 0.8 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120})[level] + (0.4 * source.ap) + (0.02 * source.maxMana) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({40, 50, 60})[level] + (0.1 * source.ap) + (0.01 * source.maxMana) end},
  },
	["Malzahar"] = {  
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.65 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({12, 14, 16, 18, 20})[level] + 0.4 * source.bonusDamage + 0.2 * source.ap + QLvL end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + 0.8 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({125, 200, 275})[level] + 0.8 * source.ap end},

  },
	["Neeko"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.5 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({140, 225, 310, 395, 480})[level] + 0.9 * source.ap end},
	{Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + 0.4 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 425, 650})[level] + 1.3 * source.ap end},
  }, 

	["Sylas"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({45, 70, 95, 120, 145})[level] + 0.6 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.65 * source.ap end},																										
	{Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 85, 100, 115, 130})[level] + 0.2 * source.ap end},
	{Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 65, 80, 95, 180})[level] + 0.4 * source.ap end},     
	{Slot = "R", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({300, 475, 650})[level] + 0.5 * source.ap + 0.1 * (myHero.maxHealth - GetBaseHealth(myHero)) end}, --cho'garh  
	{Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return (({200, 400, 600})[level] + source.ap) end}, --ashe
	{Slot = "R", Stage = 4, DamageType = 2, Damage = function(source, target, level) return (({175, 250, 325})[level] + 0.75 * source.ap) end}, --vaiger
	{Slot = "R", Stage = 5, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.8 * source.ap) end}, --leona
	{Slot = "R", Stage = 6, DamageType = 2, Damage = function(source, target, level) return (({350, 500, 650})[level] + 0.9 * source.ap + 0.45 * source.ap) end}, --ezreal
 	{Slot = "R", Stage = 7, DamageType = 2, Damage = function(source, target, level) return ({25, 35, 45})[level]/ 100 * 0.7 + (({0.25, 0.30, 0.35})[level] * (target.maxHealth - target.health)) + 0.15 * source.bonusDamage/100 * 0.5 end}, --jinx 
 	{Slot = "R", Stage = 8, DamageType = 2, Damage = function(source, target, level) return (({250, 400, 550})[level] + 0.75 * source.ap) end}, --kartus
 	{Slot = "R", Stage = 9, DamageType = 2, Damage = function(source, target, level) return (({200, 300, 400})[level] + 0.733 * source.ap) end}, --ziggs
 	{Slot = "R", Stage = 10, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.5 * source.ap) end}, --cassio
 	{Slot = "R", Stage = 11, DamageType = 2, Damage = function(source, target, level) return (({300, 400, 500})[level] + 0.75 * source.ap) end}, --lux
  	{Slot = "R", Stage = 12, DamageType = 2, Damage = function(source, target, level) return (({300, 400, 500})[level] + source.ap) end}, --tristana
    {Slot = "R", Stage = 13, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80})[level] + 0.125 * source.ap end},--Anivia
    {Slot = "R", Stage = 14, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * source.ap end},--AurelionSol
  	{Slot = "R", Stage = 15, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.6 * source.ap) end}, --Braum
  	{Slot = "R", Stage = 16, DamageType = 2, Damage = function(source, target, level) return (({125, 225, 325})[level] + 0.7 * source.ap) end}, --Irelia 
  	{Slot = "R", Stage = 17, DamageType = 2, Damage = function(source, target, level) return (({625, 950, 1275})[level] + 2.5 * source.ap) end}, --Nunu
  	{Slot = "R", Stage = 18, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.6 * source.ap) end}, -- Lissandra	
  	{Slot = "R", Stage = 19, DamageType = 2, Damage = function(source, target, level) return (({125, 200, 275})[level] + 0.8 * source.ap) end}, --Malzahar
  	{Slot = "R", Stage = 20, DamageType = 2, Damage = function(source, target, level) return (({85, 150, 215})[level]/100 * 0.7 + 0.25 * source.ap) end}, --Akali
  	{Slot = "R", Stage = 21, DamageType = 2, Damage = function(source, target, level) return (({85, 150, 215})[level] + 0.3 * source.ap) end}, --Akalib
   	{Slot = "R", Stage = 22, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.8 * source.ap) end}, --Amumu
  	{Slot = "R", Stage = 23, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 450})[level] + 0.6 * source.ap) end}, --azir
   	{Slot = "R", Stage = 24, DamageType = 2, Damage = function(source, target, level) return (({125, 250, 375})[level] + 0.75 * source.ap) end}, --evelynn 
   	{Slot = "R", Stage = 25, DamageType = 2, Damage = function(source, target, level) return (({250, 375, 500})[level] + 1.0 * source.ap) end}, --blitzgrank
  	{Slot = "R", Stage = 26, DamageType = 2, Damage = function(source, target, level) return (({175, 275, 375})[level]/100 * 0.7 + 0.55 * source.ap) end}, -- draven
   	{Slot = "R", Stage = 27, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.6 * source.ap) end}, --fizz        
  	{Slot = "R", Stage = 28, DamageType = 2, Damage = function(source, target, level) return (({200, 300, 400})[level]/100 * 0.7 + 0.1 * source.ap + 0.5 * source.ap) end}, -- gnar
  	{Slot = "R", Stage = 29, DamageType = 2, Damage = function(source, target, level) return (({200, 300, 400})[level] + 0.70 * source.ap) end}, -- gragas
   	{Slot = "R", Stage = 30, DamageType = 2, Damage = function(source, target, level) return (({90, 115, 140})[level] + (({0.075, 0.225, 0.375})[level]* source.ap) + 0.2 * source.ap) end}, --Corki
  	{Slot = "R", Stage = 31, DamageType = 2, Damage = function(source, target, level) return (({250, 400, 550})[level]/100*0.7 + 0.75 * source.ap) end}, -- graves
   	{Slot = "R", Stage = 32, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 1.0 * source.ap) end}, --hecarim
  	{Slot = "R", Stage = 33, DamageType = 2, Damage = function(source, target, level) return (({122, 306, 490})[level] + 0.35 * source.ap) end}, --Jhin
  	{Slot = "R", Stage = 34, DamageType = 2, Damage = function(source, target, level) return ({100, 160, 220})[level] + 0.6 * source.ap end}, -- Diana	
  	{Slot = "R", Stage = 35, DamageType = 2, Damage = function(source, target, level) return (({375, 562, 750})[level] + 1.65 * source.ap + 2.85 * source.ap) end}, --katarina
  	{Slot = "R", Stage = 36, DamageType = 2, Damage = function(source, target, level) return (({40, 75, 110})[level] + 0.2 * source.ap) end}, --Kennen    
  	{Slot = "R", Stage = 37, DamageType = 2, Damage = function(source, target, level) return (({150, 225, 300})[level] + 0.75 * source.ap) end}, --Maokai
  	{Slot = "R", Stage = 38, DamageType = 2, Damage = function(source, target, level) return (({250, 400, 500})[level] + 1.0 * source.ap) end}, --Missfortune  
   	{Slot = "R", Stage = 39, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.6 * source.ap) end}, --Nami
   	{Slot = "R", Stage = 40, DamageType = 2, Damage = function(source, target, level) return (({200, 325, 450})[level] + 0.8 * source.ap) end}, --Nautilus
   	{Slot = "R", Stage = 41, DamageType = 2, Damage = function(source, target, level) return (({130, 185, 240})[level] + 0.3 * source.ap) end}, --rumble   
  	{Slot = "R", Stage = 42, DamageType = 2, Damage = function(source, target, level) return (({100, 125, 150})[level] + 0.4 * source.ap) end}, --Sejuani 
   	{Slot = "R", Stage = 43, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.5 * source.ap) end}, --sona
  	{Slot = "R", Stage = 44, DamageType = 2, Damage = function(source, target, level) return (({50, 175, 300})[level]/100*0.7 + 0.25 * source.ap) end}, --urgot  
  	{Slot = "R", Stage = 45, DamageType = 2, Damage = function(source, target, level) return (({150, 200, 250})[level] + 1.0 * source.ap) end}, --varus
   	{Slot = "R", Stage = 46, DamageType = 2, Damage = function(source, target, level) return (({180, 265, 350})[level] + 0.7 * source.ap) end}, --Zyra
  	{Slot = "R", Stage = 47, DamageType = 2, Damage = function(source, target, level) return (({175, 350, 525})[level]/100*0.7 + 0.835 * source.ap) end}, --Warwick
  	{Slot = "R", Stage = 48, DamageType = 2, Damage = function(source, target, level) return (({100, 200, 300})[level] + 0.3 * source.ap) end}, --brand
  	{Slot = "R", Stage = 49, DamageType = 2, Damage = function(source, target, level) return (({175, 350, 525})[level]) end}, --Geran  
  	{Slot = "R", Stage = 50, DamageType = 2, Damage = function(source, target, level) return (({200, 300, 400})[level] + 1.0 * source.ap) end}, --malphite
  	{Slot = "R", Stage = 51, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + source.ap) end}, --shyvana
  	{Slot = "R", Stage = 52, DamageType = 2, Damage = function(source, target, level) return (({150, 225, 300})[level] + 0.7 * source.ap) end}, --morgana
  	{Slot = "R", Stage = 53, DamageType = 2, Damage = function(source, target, level) return (({20, 110, 200})[level]/100*0.7 + 0.55 * source.ap) end},	--wukong
	{Slot = "R", Stage = 54, DamageType = 2, Damage = function(source, target, level) return ({125, 225, 325})[level] + 0.45 * source.ap end}, --Fiddlesticks
	{Slot = "R", Stage = 55, DamageType = 2, Damage = function(source, target, level) return ({105, 180, 255})[level] + 0.3 * source.ap end}, --Gangplank
	{Slot = "R", Stage = 56, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level]/100*0.7 + 0.55 * source.ap) end}, --Illaoi
	{Slot = "R", Stage = 57, DamageType = 2, Damage = function(source, target, level) return ({200, 325, 450})[level]/100*0.7 + 0.75 * source.ap end}, --Jarvan
	{Slot = "R", Stage = 58, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120})[level]+ 0.4 * source.ap + 0.02 * source.maxMana end}, --Kassadin
	{Slot = "R", Stage = 59, DamageType = 2, Damage = function(source, target, level) return (({100, 140, 180})[level] + 0.325 * source.ap + 0.25 * source.ap) * (GetPercentHP(target) < 25 and 3 or (GetPercentHP(target) < 50 and 2 or 1)) end}, --Kogmaw
	{Slot = "R", Stage = 60, DamageType = 2, Damage = function(source, target, level) return (({70, 140, 210})[level] + 0.4 * source.ap) end},-- Leblanc
	{Slot = "R", Stage = 61, DamageType = 2, Damage = function(source, target, level) return ({20, 35, 50})[level]/100*0.7 + 0.1 * source.ap + 0.25 * source.totalDamage/100 * 0.7 end}, --Lucian
	{Slot = "R", Stage = 62, DamageType = 2, Damage = function(source, target, level) return ({40, 80, 120})[level] + 0.2 * source.ap end},--Rammus
	{Slot = "R", Stage = 63, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * source.ap end},--Vladimir
	{Slot = "R", Stage = 64, DamageType = 2, Damage = function(source, target, level) return ({250, 475, 700})[level]/100*0.7 + source.ap end},--Caitlyn
	{Slot = "R", Stage = 65, DamageType = 2, Damage = function(source, target, level) return (({200, 425, 650})[level] + 1.3 * source.ap) end},--Neeko
	{Slot = "R", Stage = 66, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.7 * source.ap end},--Orianna
	{Slot = "R", Stage = 67, DamageType = 2, Damage = function(source, target, level) return ({50, 70, 90})[level] + 0.2 * source.ap end},--Swain
	{Slot = "R", Stage = 68, DamageType = 2, Damage = function(source, target, level) return ({250, 400, 550})[level] + source.ap end}, --Thresh
	{Slot = "R", Stage = 69, DamageType = 2, Damage = function(source, target, level) return ({75, 115, 155})[level] + 0.4 * source.ap end},--Volibear
	{Slot = "R", Stage = 70, DamageType = 2, Damage = function(source, target, level) return ({180, 270, 360})[level] + 1.05 * source.ap end},--Ahri
	{Slot = "R", Stage = 71, DamageType = 3, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.375 * source.ap end},--Darius
	{Slot = "R", Stage = 72, DamageType = 2, Damage = function(source, target, level) return ({150, 300, 450})[level] + 1.5 * source.ap end},--Ekko
	{Slot = "R", Stage = 73, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * source.ap end},--Galio
	{Slot = "R", Stage = 74, DamageType = 2, Damage = function(source, target, level) return ({105, 262, 420})[level] + source.ap end},--LeeSin
	{Slot = "R", Stage = 75, DamageType = 2, Damage = function(source, target, level) return ({105, 192, 280})[level] + 0.6 * source.ap end},--Nocturne
	{Slot = "R", Stage = 76, DamageType = 2, Damage = function(source, target, level) return ({200, 350, 500})[level] + 0.5 * source.ap end},--Pantheon
	{Slot = "R", Stage = 77, DamageType = 2, Damage = function(source, target, level) return ({140, 210, 280})[level] + 0.45 * source.ap end},--Poppy
	{Slot = "R", Stage = 78, DamageType = 2, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.5 * source.ap end},--Rakan
	{Slot = "R", Stage = 79, DamageType = 2, Damage = function(source, target, level) return ({70, 175, 280})[level] + source.ap + (({0.20, 0.25, 0.30})[level] * (target.maxHealth - target.health)) end},--RekSai
	{Slot = "R", Stage = 80, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + source.ap end},--Shaco
	{Slot = "R", Stage = 81, DamageType = 2, Damage = function(source, target, level) return ({63, 94, 126})[level] + 0.5 * source.ap end},--Talon
	{Slot = "R", Stage = 82, DamageType = 2, Damage = function(source, target, level) return ({105, 210, 315})[level] + 0.7 * source.ap end},--Vi
	{Slot = "R", Stage = 83, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.6 * source.ap end},--Viktor
	{Slot = "R", Stage = 84, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140})[level] + 0.5 * source.ap end},--Xayah
	{Slot = "R", Stage = 85, DamageType = 2, Damage = function(source, target, level) return ({140, 210, 280})[level] + 0.75 * source.ap end},--Yasuo
  },
	["Zyra"] = {  
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.6 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.5 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({180, 265, 350})[level] + 0.7 * source.ap end},

  } 
}


function getdmg(spell,target,source,stage,level)
  local source = source or myHero
  local stage = stage or 1
  local swagtable = {}
  local k = 0
  if stage > 4 then stage = 4 end
  if spell == "Q" or spell == "W" or spell == "E" or spell == "R" or spell == "QM" or spell == "WM" or spell == "EM" then
    local level = level or source:GetSpellData(({["Q"] = _Q, ["QM"] = _Q, ["W"] = _W, ["WM"] = _W, ["E"] = _E, ["EM"] = _E, ["R"] = _R})[spell]).level
    if level <= 0 then return 0 end
    if level > 5 then level = 5 end
    if DamageLibTable[source.charName] then
      for i, spells in pairs(DamageLibTable[source.charName]) do
        if spells.Slot == spell then
          table.insert(swagtable, spells)
        end
      end
      if stage > #swagtable then stage = #swagtable end
      for v = #swagtable, 1, -1 do
        local spells = swagtable[v]
        if spells.Stage == stage then
          if spells.DamageType == 1 then
            return CalcPhysicalDamage(source, target, spells.Damage(source, target, level))
          elseif spells.DamageType == 2 then
            return CalcMagicalDamage(source, target, spells.Damage(source, target, level))
          elseif spells.DamageType == 3 then
            return spells.Damage(source, target, level)
          end
        end
      end
    end
  end
  if spell == "AA" then
    return CalcPhysicalDamage(source, target, source.totalDamage)
  end
  if spell == "IGNITE" then
    return 50+20*source.levelData.lvl - (target.hpRegen*3)
  end
  if spell == "SMITE" then
    if Smite then
      if target.type == Obj_AI_Hero then
        if source:GetSpellData(Smite).name == "s5_summonersmiteplayerganker" then
          return 20+8*source.levelData.lvl
        end
        if source:GetSpellData(Smite).name == "s5_summonersmiteduel" then
          return 54+6*source.levelData.lvl
        end
      end
      return ({390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000})[source.levelData.lvl]
    end
  end
  if spell == "BILGEWATER" then
    return CalcMagicalDamage(source, target, 100)
  end
  if spell == "BOTRK" then
    return CalcPhysicalDamage(source, target, target.maxHealth*0.1)
  end
  if spell == "HEXTECH" then
    return CalcMagicalDamage(source, target, 150+0.4*source.ap)
  end
  return 0
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "HPred"
local _atan = math.atan2
local _pi = math.pi
local _min = math.min
local _abs = math.abs
local _sqrt = math.sqrt
local _huge = math.huge
local _insert = table.insert
local _sort = table.sort
local _find = string.find
local _sub = string.sub
local _len = string.len

local LocalDrawLine					= Draw.Line;
local LocalDrawColor				= Draw.Color;
local LocalDrawCircle				= Draw.Circle;
local LocalDrawText					= Draw.Text;
local LocalControlIsKeyDown			= Control.IsKeyDown;
local LocalControlMouseEvent		= Control.mouse_event;
local LocalControlSetCursorPos		= Control.SetCursorPos;
local LocalControlKeyUp				= Control.KeyUp;
local LocalControlKeyDown			= Control.KeyDown;
local LocalGameCanUseSpell			= Game.CanUseSpell;
local LocalGameLatency				= Game.Latency;
local LocalGameTimer				= Game.Timer;
local LocalGameHeroCount 			= Game.HeroCount;
local LocalGameHero 				= Game.Hero;
local LocalGameMinionCount 			= Game.MinionCount;
local LocalGameMinion 				= Game.Minion;
local LocalGameTurretCount 			= Game.TurretCount;
local LocalGameTurret 				= Game.Turret;
local LocalGameWardCount 			= Game.WardCount;
local LocalGameWard 				= Game.Ward;
local LocalGameObjectCount 			= Game.ObjectCount;
local LocalGameObject				= Game.Object;
local LocalGameMissileCount 		= Game.MissileCount;
local LocalGameMissile				= Game.Missile;
local LocalGameParticleCount 		= Game.ParticleCount;
local LocalGameParticle				= Game.Particle;
local LocalGameIsChatOpen			= Game.IsChatOpen;
local LocalGameIsOnTop				= Game.IsOnTop;
	
local _tickFrequency = .2
local _nextTick = Game.Timer()
local _reviveLookupTable = 
	{ 
		["LifeAura.troy"] = 4, 
		["ZileanBase_R_Buf.troy"] = 3,
		["Aatrox_Base_Passive_Death_Activate"] = 3
		
		--TwistedFate_Base_R_Gatemarker_Red
			--String match would be ideal.... could be different in other skins
	}

--Stores a collection of spells that will cause a character to blink
	--Ground targeted spells go towards mouse castPos with a maximum range
	--Hero/Minion targeted spells have a direction type to determine where we will land relative to our target (in front of, behind, etc)
	
--Key = Spell name
--Value = range a spell can travel, OR a targeted end position type, OR a list of particles the spell can teleport to	
local _blinkSpellLookupTable = 
	{ 
		["EzrealArcaneShift"] = 475, 
		["RiftWalk"] = 500,
		
		--Ekko and other similar blinks end up between their start pos and target pos (in front of their target relatively speaking)
		["EkkoEAttack"] = 0,
		["AlphaStrike"] = 0,
		
		--Katarina E ends on the side of her target closest to where her mouse was... 
		["KatarinaE"] = -255,
		
		--Katarina can target a dagger to teleport directly to it: Each skin has a different particle name. This should cover all of them.
		["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, 
	}

local _blinkLookupTable = 
	{ 
		"global_ss_flash_02.troy",
		"Lissandra_Base_E_Arrival.troy",
		"LeBlanc_Base_W_return_activation.troy"
		--TODO: Check if liss/leblanc have diff skill versions. MOST likely dont but worth checking for completion sake
		
		--Zed uses 'switch shadows'... It will require some special checks to choose the shadow he's going TO not from...
		--Shaco deceive no longer has any particles where you jump to so it cant be tracked (no spell data or particles showing path)
		
	}

local _cachedBlinks = {}
local _cachedRevives = {}
local _cachedTeleports = {}

--Cache of all TARGETED missiles currently running
local _cachedMissiles = {}
local _incomingDamage = {}

--Cache of active enemy windwalls so we can calculate it when dealing with collision checks
local _windwall
local _windwallStartPos
local _windwallWidth

local _OnVision = {}
function HPred:OnVision(unit)
	if unit == nil or type(unit) ~= "userdata" then return end
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {visible = unit.visible , tick = GetTickCount(), pos = unit.pos } end
	if _OnVision[unit.networkID].visible == true and not unit.visible then _OnVision[unit.networkID].visible = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].visible == false and unit.visible then _OnVision[unit.networkID].visible = true _OnVision[unit.networkID].tick = GetTickCount() _OnVision[unit.networkID].pos = unit.pos end
	return _OnVision[unit.networkID]
end

--This must be called manually - It's not on by default because we've tracked down most of the freeze issues to this.
function HPred:Tick()
	
	
	--Update missile cache
	--DISABLED UNTIL LATER.
	--self:CacheMissiles()
	
	--Limit how often tick logic runs
	if _nextTick > Game.Timer() then return end
	_nextTick = Game.Timer() + _tickFrequency
	
	--Update hero movement history	
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			if t.isEnemy then
				HPred:OnVision(t)
			end
		end
	end
	
	--Do not run rest of logic until freeze issues are fully tracked down
	if true then return end
	
	
	--Remove old cached teleports	
	for _, teleport in pairs(_cachedTeleports) do
		if teleport and Game.Timer() > teleport.expireTime + .5 then
			_cachedTeleports[_] = nil
		end
	end	
	
	--Update teleport cache
	HPred:CacheTeleports()	
	
	
	--Record windwall
	HPred:CacheParticles()
	
	--Remove old cached revives
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	--Remove old cached blinks
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		--Record revives
		if particle and not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then
			_cachedRevives[particle.networkID] = {}
			_cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedRevives[particle.networkID]["target"] = target
				_cachedRevives[particle.networkID]["pos"] = target.pos
				_cachedRevives[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
		
		--Record blinks
		if particle and not _cachedBlinks[particle.networkID] and  _blinkLookupTable[particle.name] then
			_cachedBlinks[particle.networkID] = {}
			_cachedBlinks[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedBlinks[particle.networkID]["target"] = target
				_cachedBlinks[particle.networkID]["pos"] = target.pos
				_cachedBlinks[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
	end
	
end

function HPred:GetEnemyNexusPosition()
	--This is slightly wrong. It represents fountain not the nexus. Fix later.
	if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end
end


function HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
end


function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--TODO: Target whitelist. This will target anyone which is definitely not what we want
	--For now we can handle in the champ script. That will cause issues with multiple people in range who are goood targets though.
	
	
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get channeling enemies
	--local target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	--	if target and aimPosition then
	--	return target, aimPosition
	--end
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get instant dash enemies
	local target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get dashing enemies
	local target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get blink targets
	local target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
end

--Will return how many allies or enemies will be hit by a linear spell based on current waypoint data.
function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
	local targetCount = 0
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then
			
			local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) * (t.boundingRadius + width)) then
				targetCount = targetCount + 1
			end
		end
	end
	return targetCount
end

--Will return the valid target who has the highest hit chance and meets all conditions (minHitChance, whitelist check, etc)
function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist, isLine)
	local _validTargets = {}
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)		
		if t and self:CanTarget(t, true) and (not whitelist or whitelist[t.charName]) then
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision, isLine)		
			if hitChance >= minimumHitChance then
				_insert(_validTargets, {aimPosition,hitChance, hitChance * 100 + self:CalculateMagicDamage(t, 400)})
			end
		end
	end	
	_sort(_validTargets, function( a, b ) return a[3] >b[3] end)	
	if #_validTargets > 0 then	
		return _validTargets[1][2], _validTargets[1][1]
	end
end

function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision, isLine)

	if isLine == nil and checkCollision then
		isLine = true
	end
	
	local hitChance = 1
	local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed)	
	local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed)
	local reactionTime = self:PredictReactionTime(target, .1, isLine)
	
	--Check if they are walking the same path as the line or very close to it
	if isLine then
		local pathVector = aimPosition - target.pos
		local castVector = (aimPosition - myHero.pos):Normalized()
		if pathVector.x + pathVector.z ~= 0 then
			pathVector = pathVector:Normalized()
			if pathVector:DotProduct(castVector) < -.85 or pathVector:DotProduct(castVector) > .85 then
				if speed > 3000 then
					reactionTime = reactionTime + .25
				else
					reactionTime = reactionTime + .15
				end
			end
		end
	end			

	--If they are standing still give a higher accuracy because they have to take actions to react to it
	if not target.pathing or not target.pathing.hasMovePath then
		hitChancevisionData = 2
	end	
	
	
	local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
	--Our spell is so wide or the target so slow or their reaction time is such that the spell will be nearly impossible to avoid
	if movementRadius - target.boundingRadius <= radius /2 then
		origin,movementRadius = self:UnitMovementBounds(target, interceptTime, 0)
		if movementRadius - target.boundingRadius <= radius /2 then
			hitChance = 4
		else		
			hitChance = 3
		end
	end	
	
	--If they are casting a spell then the accuracy will be fairly high. if the windup is longer than our delay then it's quite likely to hit. 
	--Ideally we would predict where they will go AFTER the spell finishes but that's beyond the scope of this prediction
	if target.activeSpell and target.activeSpell.valid then
		if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then
			hitChance = 5
		else			
			hitChance = 3
		end
	end
	
	local visionData = HPred:OnVision(target)
	if visionData and visionData.visible == false then
		local hiddenTime = visionData.tick -GetTickCount()
		if hiddenTime < -1000 then
			hitChance = -1
		else
			local targetSpeed = self:GetTargetMS(target)
			local unitPos = target.pos + Vector(target.pos,target.posTo):Normalized() * ((GetTickCount() - visionData.tick)/1000 * targetSpeed)
			local aimPosition = unitPos + Vector(target.pos,target.posTo):Normalized() * (targetSpeed * (delay + (self:GetDistance(myHero.pos,unitPos)/speed)))
			if self:GetDistance(target.pos,aimPosition) > self:GetDistance(target.pos,target.posTo) then aimPosition = target.posTo end
			hitChance = _min(hitChance, 2)
		end
	end
	
	--Check for out of range
	if not self:IsInRange(source, aimPosition, range) then
		hitChance = -1
	end
	
	--Check minion block
	if hitChance > 0 and checkCollision then
		if self:IsWindwallBlocking(source, aimPosition) then
			hitChance = -1		
		elseif self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then
			hitChance = -1
		end
	end
	
	return hitChance, aimPosition
end

function HPred:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	
	--If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end	
	return reactionTime
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)

	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if self:IsInRange(source, dashEndPosition, range) then				
				--The dash ends within range of our skill. We now need to find if our spell can connect with them very close to the time their dash will end
				local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(source, dashEndPosition, delay, speed)
				local deltaInterceptTime =skillInterceptTime - dashTimeRemaining
				if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then
					target = t
					aimPosition = dashEndPosition
					return target, aimPosition
				end
			end			
		end
	end
end

function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy then		
			local success, timeRemaining = self:HasBuff(t, "zhonyasringshield")
			if success then
				local spellInterceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
				local deltaInterceptTime = spellInterceptTime - timeRemaining
				if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = t
					aimPosition = t.pos
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for _, revive in pairs(_cachedRevives) do	
		if revive.isEnemy then
			local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
			if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then
				target = revive.target
				aimPosition = revive.pos
				return target, aimPosition
			end
		end
	end	
end

function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then
			local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer()
			if windupRemaining > 0 then
				local endPos
				local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
				if type(blinkRange) == "table" then
					--Find the nearest matching particle to our mouse
					--local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange)
					--if target and distance < 250 then					
					--	endPos = target.pos		
					--end
				elseif blinkRange > 0 then
					endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)					
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * _min(self:GetDistance(t.activeSpell.startPos,endPos), range)
				else
					local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
					if blinkTarget then				
						local offsetDirection						
						
						--We will land in front of our target relative to our starting position
						if blinkRange == 0 then				

							if t.activeSpell.name ==  "AlphaStrike" then
								windupRemaining = windupRemaining + .75
								--TODO: Boost the windup time by the number of targets alpha will hit. Need to calculate the exact times this is just rough testing right now
							end						
							offsetDirection = (blinkTarget.pos - t.pos):Normalized()
						--We will land behind our target relative to our starting position
						elseif blinkRange == -1 then						
							offsetDirection = (t.pos-blinkTarget.pos):Normalized()
						--They can choose which side of target to come out on , there is no way currently to read this data so we will only use this calculation if the spell radius is large
						elseif blinkRange == -255 then
							if radius > 250 then
								endPos = blinkTarget.pos
							end							
						end
						
						if offsetDirection then
							endPos = blinkTarget.pos - offsetDirection * blinkTarget.boundingRadius
						end
						
					end
				end	
				
				local interceptTime = self:GetSpellInterceptTime(source, endPos, delay,speed)
				local deltaInterceptTime = interceptTime - windupRemaining
				if self:IsInRange(source, endPos, range) and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
					target = t
					aimPosition = endPos
					return target,aimPosition					
				end
			end
		end
	end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	local target
	local aimPosition
	for _, particle in pairs(_cachedBlinks) do
		if particle  and self:IsInRange(source, particle.pos, range) then
			local t = particle.target
			local pPos = particle.pos
			if t and t.isEnemy and (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
				target = t
				aimPosition = pPos
				return target,aimPosition
			end
		end		
	end
end

function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if self:CanTarget(t) and self:IsInRange(source, t.pos, range) and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos	
				return target, aimPosition
			end
		end
	end
end

function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTarget(t) and self:IsInRange(source, t.pos, range) then
			local immobileTime = self:GetImmobileTime(t)
			
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos
				return target, aimPosition
			end
		end
	end
end

function HPred:CacheTeleports()
	--Get enemies who are teleporting to towers
	for i = 1, LocalGameTurretCount() do
		local turret = LocalGameTurret(i);
		if turret and turret.isEnemy and not _cachedTeleports[turret.networkID] then
			local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
			if hasBuff then
				self:RecordTeleport(turret, self:GetTeleportOffset(turret.pos,223.31),expiresAt)
			end
		end
	end	
	
	--Get enemies who are teleporting to wards	
	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.isEnemy and not _cachedTeleports[ward.networkID] then
			local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
			if hasBuff then
				self:RecordTeleport(ward, self:GetTeleportOffset(ward.pos,100.01),expiresAt)
			end
		end
	end
	
	--Get enemies who are teleporting to minions
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion and minion.isEnemy and not _cachedTeleports[minion.networkID] then
			local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
			if hasBuff then
				self:RecordTeleport(minion, self:GetTeleportOffset(minion.pos,143.25),expiresAt)
			end
		end
	end	
end

function HPred:RecordTeleport(target, aimPos, endTime)
	_cachedTeleports[target.networkID] = {}
	_cachedTeleports[target.networkID]["target"] = target
	_cachedTeleports[target.networkID]["aimPos"] = aimPos
	_cachedTeleports[target.networkID]["expireTime"] = endTime + Game.Timer()
end


function HPred:CalculateIncomingDamage()
	_incomingDamage = {}
	local currentTime = Game.Timer()
	for _, missile in pairs(_cachedMissiles) do
		if missile then 
			local dist = self:GetDistance(missile.data.pos, missile.target.pos)			
			if missile.name == "" or currentTime >= missile.timeout or dist < missile.target.boundingRadius then
				_cachedMissiles[_] = nil
			else
				if not _incomingDamage[missile.target.networkID] then
					_incomingDamage[missile.target.networkID] = missile.damage
				else
					_incomingDamage[missile.target.networkID] = _incomingDamage[missile.target.networkID] + missile.damage
				end
			end
		end
	end	
end

function HPred:GetIncomingDamage(target)
	local damage = 0
	if _incomingDamage[target.networkID] then
		damage = _incomingDamage[target.networkID]
	end
	return damage
end


local _maxCacheRange = 3000

--Right now only used to cache enemy windwalls
function HPred:CacheParticles()	
	if _windwall and _windwall.name == "" then
		_windwall = nil
	end
	
	for i = 1, LocalGameParticleCount() do
		local particle = LocalGameParticle(i)		
		if particle and self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then			
			if _find(particle.name, "W_windwall%d") and not _windwall then
				--We don't care about ally windwalls for now
				local owner =  self:GetObjectByHandle(particle.handle)
				if owner and owner.isEnemy then
					_windwall = particle
					_windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)				
					
					local index = _len(particle.name) - 5
					local spellLevel = _sub(particle.name, index, index) -1
					--Simple fix
					if type(spellLevel) ~= "number" then
						spellLevel = 1
					end
					_windwallWidth = 150 + spellLevel * 25					
				end
			end
		end
	end
end

function HPred:CacheMissiles()
	local currentTime = Game.Timer()
	for i = 1, LocalGameMissileCount() do
		local missile = LocalGameMissile(i)
		if missile and not _cachedMissiles[missile.networkID] and missile.missileData then
			--Handle targeted missiles
			if missile.missileData.target and missile.missileData.owner then
				local missileName = missile.missileData.name
				local owner =  self:GetObjectByHandle(missile.missileData.owner)	
				local target =  self:GetObjectByHandle(missile.missileData.target)		
				if owner and target and _find(target.type, "Hero") then			
					--The missile is an auto attack of some sort that is targeting a player	
					if (_find(missileName, "BasicAttack") or _find(missileName, "CritAttack")) then
						--Cache it all and update the count
						_cachedMissiles[missile.networkID] = {}
						_cachedMissiles[missile.networkID].target = target
						_cachedMissiles[missile.networkID].data = missile
						_cachedMissiles[missile.networkID].danger = 1
						_cachedMissiles[missile.networkID].timeout = currentTime + 1.5
						
						local damage = owner.totalDamage
						if _find(missileName, "CritAttack") then
							--Leave it rough we're not that concerned
							damage = damage * 1.5
						end						
						_cachedMissiles[missile.networkID].damage = self:CalculatePhysicalDamage(target, damage)
					end
				end
			end
		end
	end
end

function HPred:CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

function HPred:CalculateMagicDamage(target, damage)			
	local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
	local damageReduction = 100 / ( 100 + targetMR)
	if targetMR < 0 then
		damageReduction = 2 - (100 / (100 - targetMR))
	end		
	damage = damage * damageReduction
	
	return damage
end


function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)

	local target
	local aimPosition
	for _, teleport in pairs(_cachedTeleports) do
		if teleport.expireTime > Game.Timer() and self:IsInRange(source,teleport.aimPos, range) then			
			local spellInterceptTime = self:GetSpellInterceptTime(source, teleport.aimPos, delay, speed)
			local teleportRemaining = teleport.expireTime - Game.Timer()
			if spellInterceptTime > teleportRemaining and spellInterceptTime - teleportRemaining <= timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, teleport.aimPos, delay, speed, radius)) then								
				target = teleport.target
				aimPosition = teleport.aimPos
				return target, aimPosition
			end
		end
	end		
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:Angle(A, B)
	local deltaPos = A - B
	local angle = _atan(deltaPos.x, deltaPos.z) *  180 / _pi	
	if angle < 0 then angle = angle + 360 end
	return angle
end

--Returns where the unit will be when the delay has passed given current pathing information. This assumes the target makes NO CHANGES during the delay.
function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			--This node of the path will be completed before the delay has finished. Move on to the next node if one remains
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:IsChannelling(target, interceptTime)
	if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then
		return true
	end
end

function HPred:HasBuff(target, buffName, minimumDuration)
	local duration = minimumDuration
	if not minimumDuration then
		duration = 0
	end
	local durationRemaining
	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		if buff.duration > duration and buff.name == buffName then
			durationRemaining = buff.duration
			return true, durationRemaining
		end
	end
end

--Moves an origin towards the enemy team nexus by magnitude
function HPred:GetTeleportOffset(origin, magnitude)
	local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude
	return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end

--Checks if a target can be targeted by abilities or auto attacks currently.
--CanTarget(target)
	--target : gameObject we are trying to hit
function HPred:CanTarget(target, allowInvisible)
	return target.isEnemy and target.alive and target.health > 0  and (allowInvisible or target.visible) and target.isTargetable
end

--Derp: dont want to fuck with the isEnemy checks elsewhere. This will just let us know if the target can actually be hit by something even if its an ally
function HPred:CanTargetALL(target)
	return target.alive and target.health > 0 and target.visible and target.isTargetable
end

--Returns a position and radius in which the target could potentially move before the delay ends. ReactionTime defines how quick we expect the target to be able to change their current path
function HPred:UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = self:PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = self:GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

--Returns how long (in seconds) the target will be unable to move from their current location
function HPred:GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			duration = buff.duration
		end
	end
	return duration		
end

--Returns how long (in seconds) the target will be slowed for
function HPred:GetSlowedTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end

--Returns all existing path nodes
function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

--Finds any game object with the correct handle to match (hero, minion, wards on either team)
function HPred:GetObjectByHandle(handle)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and minion.handle == handle then
			target = minion
			return target
		end
	end
	
	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.handle == handle then
			target = ward
			return target
		end
	end
	
	for i = 1, LocalGameTurretCount() do 
		local turret = LocalGameTurret(i)
		if turret and turret.handle == handle then
			target = turret
			return target
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and particle.handle == handle then
			target = particle
			return target
		end
	end
end

function HPred:GetHeroByPosition(position)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetObjectByPosition(position)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local enemy = LocalGameMinion(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameWardCount() do
		local enemy = LocalGameWard(i);
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local enemy = LocalGameParticle(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
end

--Finds the closest particle to the origin that is contained in the names array
function HPred:GetNearestParticleByNames(origin, names)
	local target
	local distance = 999999
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle then 
			local d = self:GetDistance(origin, particle.pos)
			if d < distance then
				distance = d
				target = particle
			end
		end
	end
	return target, distance
end

--Returns the total distance of our current path so we can calculate how long it will take to complete
function HPred:GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + self:GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end


--I know this isn't efficient but it works accurately... Leaving it for now.
function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
		
	if not frequency then
		frequency = radius
	end
	local directionVector = (endPos - origin):Normalized()
	local checkCount = self:GetDistance(origin, endPos) / frequency
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * frequency
		local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed
		if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end


function HPred:IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and self:CanTarget(minion) and self:IsInRange(minion.pos, location, maxDistance) then
			local predictedPosition = self:PredictUnitPosition(minion, delay)
			if self:IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
				return true
			end
		end
	end
	return false
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

--Determines if there is a windwall between the source and target pos. 
function HPred:IsWindwallBlocking(source, target)
	if _windwall then
		local windwallFacing = (_windwallStartPos-_windwall.pos):Normalized()
		return self:DoLineSegmentsIntersect(source, target, _windwall.pos + windwallFacing:Perpendicular() * _windwallWidth, _windwall.pos + windwallFacing:Perpendicular2() * _windwallWidth)
	end	
	return false
end
--Returns if two line segments cross eachother. AB is segment 1, CD is segment 2.
function HPred:DoLineSegmentsIntersect(A, B, C, D)

	local o1 = self:GetOrientation(A, B, C)
	local o2 = self:GetOrientation(A, B, D)
	local o3 = self:GetOrientation(C, D, A)
	local o4 = self:GetOrientation(C, D, B)
	
	if o1 ~= o2 and o3 ~= o4 then
		return true
	end
	
	if o1 == 0 and self:IsOnSegment(A, C, B) then return true end
	if o2 == 0 and self:IsOnSegment(A, D, B) then return true end
	if o3 == 0 and self:IsOnSegment(C, A, D) then return true end
	if o4 == 0 and self:IsOnSegment(C, B, D) then return true end
	
	return false
end

--Determines the orientation of ordered triplet
--0 = Colinear
--1 = Clockwise
--2 = CounterClockwise
function HPred:GetOrientation(A,B,C)
	local val = (B.z - A.z) * (C.x - B.x) -
		(B.x - A.x) * (C.z - B.z)
	if val == 0 then
		return 0
	elseif val > 0 then
		return 1
	else
		return 2
	end
	
end

function HPred:IsOnSegment(A, B, C)
	return B.x <= _max(A.x, C.x) and 
		B.x >= _min(A.x, C.x) and
		B.z <= _max(A.z, C.z) and
		B.z >= _min(A.z, C.z)
end

--Gets the slope between two vectors. Ignores Y because it is non-needed height data. Its all 2d math.
function HPred:GetSlope(A, B)
	return (B.z - A.z) / (B.x - A.x)
end

function HPred:GetEnemyByName(name)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.isEnemy and enemy.charName == name then
			target = enemy
			return target
		end
	end
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	local deltaAngle = _abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
	if deltaAngle < angle and self:IsInRange(origin,target,range) then
		return true
	end
end

function HPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return _huge
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) 
end

function HPred:IsInRange(p1, p2, range)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined IsInRange target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return false
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range 
end

function HPred:GetDistance(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistance target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return _huge
	end
	return _sqrt(self:GetDistanceSqr(p1, p2))
end

	function OnLoad()
 		if _G[myHero.charName] and myHero.charName == "XinZhao" or "Kassadin" or "Veigar" or "Tristana" or "Warwick" or "Neeko" or "Cassiopeia" or "Malzahar" or "Zyra" or "Sylas" or "Kayle" then 
 			_G[myHero.charName]()

		end
	end
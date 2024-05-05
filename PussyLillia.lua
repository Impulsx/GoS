local heroes = {
	"Lillia"
}
local version = 0.07
local loadPLillia = table.contains(heroes, myHero.charName)

if not loadPLillia or _G[myHero.charName] then
	return
end

require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"

-- Spell

local minQRange = 475

local wRange = 500
local wData = {
	Type = _G.SPELLTYPE_CIRCLE and GGPrediction.SPELLTYPE_CIRCLE,
	Delay = 0.759,
	Radius = 65,
	Range = wRange,
	Speed = math.huge,
	Collision = false
}
local wspellData = {
	speed = math.huge,
	range = wRange,
	delay = 0.759,
	radius = 65,
	collision = {},
	type = "circular"
}

local eMinRange = 700
local eSpeed = 1400    -- mis Speed 500
local eSpeedLob = 5000 -- mis Speed 1750
local eRadius = 120    -- mis Radius 85
local eData = {
	Type = _G.SPELLTYPE_LINE and GGPrediction.SPELLTYPE_LINE,
	Delay = 0.40,
	Radius = eRadius,
	Range = math.huge,
	Speed = eSpeed,
	Collision = false
}
local eDataCol = {
	Type = _G.SPELLTYPE_LINE and GGPrediction.SPELLTYPE_LINE,
	Delay = 0.40,
	Radius = eRadius,
	Range = math.huge,
	Speed = eSpeed,
	Collision = true --[[+GGPrediction.COLLISION_ENEMYHERO? , CollisionTypes = {GGPrediction.COLLISION_MINION, GGPrediction.COLLISION_ENEMYHERO, GGPrediction.COLLISION_YASUOWALL}]]
}
local eDataLob = {
	Type = _G.SPELLTYPE_LINE and GGPrediction.SPELLTYPE_LINE,
	Delay = 0.40,
	Radius = eRadius,
	Range = eMinRange,
	Speed = eSpeedLob,
	Collision = false
}

local espellData = {
	speed = eSpeed,
	range = math.huge,
	delay = 0.40,
	angle = 50,
	radius = eRadius,
	collision = {
		""
	},
	type = "linear"
}
local eSpellDataCol = {
	speed = eSpeed,
	range = math.huge,
	delay = 0.40,
	angle = 50,
	radius = eRadius,
	collision = {
		"minion",
		"hero",
		"windwall"
	} --[[ "minion" ? {"minion","hero","windwall"}]],
	type = "linear"
}
local eSpellDataLob = {
	speed = eSpeedLob,
	range = eMinRange,
	delay = 0.40,
	angle = 50,
	radius = eRadius,
	collision = {},
	type = "linear"
}

local rbuffName = "LilliaPDoT"

----------------------------------------------------
-- |                    Checks                    |--
----------------------------------------------------

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	DownloadFileAsync(
		"https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua",
		COMMON_PATH .. "GamsteronPrediction.lua",
		function()
		end
	)
	print("gamsteronPred. installed Press 2x F6")
	return
end

if not FileExist(COMMON_PATH .. "PremiumPrediction.lua") then
	DownloadFileAsync(
		"https://raw.githubusercontent.com/Ark223/GoS-Scripts/master/PremiumPrediction.lua",
		COMMON_PATH .. "PremiumPrediction.lua",
		function()
		end
	)
	print("PremiumPred. installed Press 2x F6")
	return
end

if not FileExist(COMMON_PATH .. "GGPrediction.lua") then
	DownloadFileAsync(
		"https://raw.githubusercontent.com/gamsteron/GG/master/GGPrediction.lua",
		COMMON_PATH .. "GGPrediction.lua",
		function()
		end
	)
	print("GGPrediction installed Press 2x F6")
	return
end

-- [ AutoUpdate ]
do
	local Files = {
		Lua = {
			Path = SCRIPT_PATH,
			Name = "PussyLillia.lua",
			Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/PussyLillia.lua"
		},
		Version = {
			Path = SCRIPT_PATH,
			Name = "PussyLillia.version",
			Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/PussyLillia.version"
		}
	}

	local function AutoUpdate()
		local function DownloadFile(url, path, fileName)
			DownloadFileAsync(
				url,
				path .. fileName,
				function()
				end
			)
			while not FileExist(path .. fileName) do
			end
		end

		local function ReadFile(path, fileName)
			local file = io.open(path .. fileName, "r")
			local result = file:read()
			file:close()
			return result
		end

		DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
		-- local textPos = myHero.pos:To2D()
		local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
		if NewVersion > version then
			DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
			print("New PussyLillia Version [ " .. tostring(NewVersion) .. " ] Press 2x F6")
		else
			print("PussyLillia [ " .. tostring(version) .. " ] Loading..")
		end
	end

	AutoUpdate()
end

----------------------------------------------------
-- |                    Utils                     |--
----------------------------------------------------
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local _OnVision = {}
local _movementHistory = {}
local foundAUnit = false

local heroes = false
local unitClock = 0
local unitTicks = 31
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local math = math
local table = table
local Draw = Draw
local Control = Control
local Game = Game
-- local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}

local color = {
	--[[ Lilac (Purple):
	Hex: #C8A2C8
	Red ®: 200
	Green (G): 162
	Blue (B): 200 ]]
	R = function(a)
		a = a or 225
		return Draw.Color(a, 200, 162, 200)
	end,
	--[[ Turquoise (Blue-Green):
	Hex: #00FF7F
	R: 0
	G: 255
	B: 127 ]]
	E = function(a)
		a = a or 225
		return Draw.Color(a, 0, 255, 127)
	end,
	--[[ Mint Green:
	Hex: #90EE90
	R: 144
	G: 238
	B: 144 ]]
	W = function(a)
		a = a or 225
		return Draw.Color(a, 144, 238, 144)
	end,
	--[[ Soft Brown:
	Hex: #A52A2A
	R: 165
	G: 42
	B: 42 ]]
	Q = function(a)
		a = a or 225
		return Draw.Color(a, 165, 42, 42)
	end
}

local function LoadUnits()
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		Units[i] = {
			unit = unit,
			spell = nil
		}
		if unit.team ~= myHero.team then
			table.insert(Enemies, unit)
		elseif unit.team == myHero.team and unit ~= myHero then
			table.insert(Allies, unit)
		end
	end
	for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i)
		if turret and turret.isEnemy then
			table.insert(Turrets, turret)
		end
	end
	unitClock = Game.Timer() + (0.033 * unitTicks)
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

local function IsValid(unit)
	if
		(unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and
			unit.health > 0)
	then
		return true
	end
	return false
end

local function ValidTarget(unit, range)
	if
		(unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and
			unit.health > 0)
	then
		if range then
			if GetDistance(unit.pos) <= range then
				return true
			end
		else
			return true
		end
	end
	return false
end

local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and
		myHero:GetSpellData(spell).mana <= myHero.mana and
		Game.CanUseSpell(spell) == 0
end

local function GetTarget(range)
	if _G.SDK then
		if myHero.ap > myHero.totalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		end
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end
end

local function GetMode()
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] or Orbwalker.Key.Combo:Value() then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] or Orbwalker.Key.Harass:Value() then
			return "Harass"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or Orbwalker.Key.Clear:Value() then
			return "LaneClear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] or Orbwalker.Key.Clear:Value() then
			return "JungleClear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] or Orbwalker.Key.LastHit:Value() then
			return "LastHit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] or Orbwalker.Key.Flee:Value() then
			return "Flee"
		end
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetMode()
	else
		return GOS.GetMode()
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

local function CheckLoadedEnemyies()
	local count = 0
	for i, unit in ipairs(Enemies) do
		if unit and unit.isEnemy then
			count = count + 1
		end
	end
	return count
end

local function GetEnemyHeroes()
	return Enemies
end

local function GetEnemyTurrets()
	return Turrets
end

local function GetMinionCount(range, pos)
	local pos = pos.pos
	local count = 0
	for i = 1, Game.MinionCount() do
		local hero = Game.Minion(i)
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
	return {
		type = 0,
		name = "",
		startTime = 0,
		expireTime = 0,
		duration = 0,
		stacks = 0,
		count = 0
	}
end

local function IsRecalling(unit)
	local buff = GetBuffData(unit, "recall")
	if buff and buff.duration > 0 then
		return true, Game.Timer() - buff.startTime
	end
	return false
end

local function GetBuffedEnemyCount(range, pos)
	local pos = pos.pos or myHero.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
		local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) and HasBuff(hero, rbuffName) then
			count = count + 1
		end
	end
	return count
end

local function CalcDmg(unit)
	local total = 0
	local level = myHero.levelData.lvl
	-- local QDmg = getdmg(_Q, unit, myHero)
	if Ready(_Q) then
		-- local QDmg = CalcDamage(myHero, unit, 2, (15 + 15 * level) + (0.4 * myHero.ap))
		-- local TrueDmg = (15 + 15 * level) + (0.4 * myHero.ap)
		local QDmg = getdmg(_Q, unit, myHero)
		local TrueDmg = (15 + 15 * level) + (0.4 * myHero.ap)
		total = total + (QDmg + TrueDmg)
	end

	if Ready(_W) then
		-- local WDmg = CalcDamage(myHero, unit, 2, (165 + 45 * level) + (0.9 * myHero.ap))
		local WDmg = getdmg(_W, unit, myHero)
		total = total + WDmg
	end

	if Ready(_E) then
		-- local EDmg = CalcDamage(myHero, unit, 2, (50 + 20 * level) + (0.4 * myHero.ap))
		local EDmg = getdmg(_E, unit, myHero)
		total = total + EDmg
	end

	if Ready(_R) then
		-- local RDmg = CalcDamage(myHero, unit, 2, (50 + 50 * level) + (0.3 * myHero.ap))
		local RDmg = getdmg(_R, unit, myHero)
		total = total + RDmg
		if total == RDmg then
			total = 0
		end
	end

	return total
end

local function ConvertToHitChance(menuValue, hitChance)
	local result
	if menuValue == 1 then
		result = _G.PremiumPrediction.HitChance.High(hitChance)
	elseif menuValue == 2 then
		result = (_G.PremiumPrediction.HitChance.VeryHigh(hitChance) or _G.PremiumPrediction.HitChance.Immobile(hitChance))
	elseif menuValue == 3 then
		result = hitChance:CanHit(hitChance or menuValue + 1 or hitChance.HitChance)
	end
	return result
end

local function MyHeroNotReady()
	return myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or
		(_G.ExtLibEvade and _G.ExtLibEvade.Evading) or
		IsRecalling(myHero)
end

----------------------------------------------------
-- |                Champion               		|--
----------------------------------------------------

class "Lillia"

local PredLoaded = false
local DrawTime = false
local mode

local CastingQ = false
local CastingW = false
local CastingE = false
local CastingR = false

function Lillia:__init()
	self:LoadMenu()

	Callback.Add(
		"Tick",
		function()
			self:Tick()
		end
	)
	Callback.Add(
		"Draw",
		function()
			self:Draw()
		end
	)

	if PredLoaded == false then
		DelayAction(
			function()
				if self.Menu.MiscSet.Pred.Change:Value() == 1 then
					require("GamsteronPrediction")
					PredLoaded = true
				elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
					require("PremiumPrediction")
					PredLoaded = true
				else
					require("GGPrediction")
					PredLoaded = true
				end
			end,
			1
		)
	end
	-- print("PussyLillia [ "..tostring(Version).." ] loaded")
end

function Lillia:LoadMenu()
	-- MainMenu
	self.Menu =
		MenuElement(
			{
				type = MENU,
				id = "PussyLillia",
				name = "PussyLillia [ v" .. tostring(version) .. " ] "
			}
		)
	self.Menu:MenuElement(
		{
			type = SPACE
		}
	)
	self.Menu:MenuElement(
		{
			type = MENU,
			id = "AutoSet",
			name = "Auto Mode"
		}
	)
	-- AutoQ
	self.Menu.AutoSet:MenuElement(
		{
			type = MENU,
			id = "AutoQ",
			name = "Auto[Q] Mode"
		}
	)
	self.Menu.AutoSet.AutoQ:MenuElement(
		{
			id = "UseQ",
			name = "Auto[Q] Toggle Key",
			key = string.byte("T"),
			value = true,
			toggle = true
		}
	)
	self.Menu.AutoSet.AutoQ:MenuElement(
		{
			id = "QLogic",
			name = "[Q] Logic",
			value = 1,
			drop = {
				"Auto [Q] only outer range (TrueDmg)",
				"Auto [Q] always"
			}
		}
	)
	-- AutoE
	self.Menu.AutoSet:MenuElement(
		{
			type = MENU,
			id = "AutoE",
			name = "Auto[E] Mode"
		}
	)
	self.Menu.AutoSet.AutoE:MenuElement(
		{
			id = "UseE",
			name = "Auto[E]",
			value = false
		}
	)
	-- AutoR
	self.Menu.AutoSet:MenuElement(
		{
			type = MENU,
			id = "AutoR",
			name = "Auto[R] Mode"
		}
	)
	self.Menu.AutoSet.AutoR:MenuElement(
		{
			id = "UseR",
			name = "Auto[R]",
			value = true
		}
	)
	self.Menu:MenuElement(
		{
			id = "ECastRange",
			name = "[E] Max Cast range",
			value = 8000,
			min = 1000,
			max = 20500,
			step = 10
		}
	)
	self.Menu:MenuElement(
		{
			id = "UseRCount",
			name = "Auto[R] Multiple Enemys",
			value = true
		}
	)
	self.Menu:MenuElement(
		{
			id = "RCount",
			name = "[R] Multiple Enemys",
			value = 2,
			min = 1,
			max = 6,
			step = 1
		}
	)
	self.Menu:MenuElement(
		{
			id = "RRange",
			name = "[R] Max Search Range",
			value = 8000,
			min = 1000,
			max = 20500,
			step = 10
		}
	)
	-- self.Menu:MenuElement({id = "QLogic", name = "[Q] Logic", value = 1, drop = {"Q only outer range (TrueDmg)", "Q always"}})
	self.Menu:MenuElement(
		{
			type = SPACE
		}
	)
	self.Menu:MenuElement(
		{
			type = MENU,
			id = "ComboSet",
			name = "Combo Settings"
		}
	)
	-- ComboMenu
	self.Menu.ComboSet:MenuElement(
		{
			type = MENU,
			id = "Combo",
			name = "Combo Mode"
		}
	)
	self.Menu.ComboSet.Combo:MenuElement(
		{
			id = "UseQ",
			name = "[Q]",
			value = true
		}
	)
	self.Menu.ComboSet.Combo:MenuElement(
		{
			id = "QLogic",
			name = "[Q] Logic",
			value = 1,
			drop = {
				"Q only outer range (TrueDmg)",
				"Q always"
			}
		}
	)
	self.Menu.ComboSet.Combo:MenuElement(
		{
			id = "UseW",
			name = "[W]",
			value = true
		}
	)
	self.Menu.ComboSet.Combo:MenuElement(
		{
			id = "UseE",
			name = "[E]",
			value = true
		}
	)
	self.Menu.ComboSet.Combo:MenuElement(
		{
			id = "UseR",
			name = "[R]Single Target if killable",
			value = false
		}
	)
	self.Menu.ComboSet.Combo:MenuElement(
		{
			id = "UseRCount",
			name = "Auto[R] Multiple Enemys",
			value = true
		}
	)

	self.Menu:MenuElement(
		{
			type = MENU,
			id = "ClearSet",
			name = "Clear Settings"
		}
	)
	-- LaneClear Menu
	self.Menu.ClearSet:MenuElement(
		{
			type = MENU,
			id = "Clear",
			name = "Clear Mode"
		}
	)
	self.Menu.ClearSet.Clear:MenuElement(
		{
			id = "UseQ",
			name = "[Q]",
			value = true
		}
	)
	self.Menu.ClearSet.Clear:MenuElement(
		{
			id = "QCount",
			name = "min Minions for [Q]",
			value = 3,
			min = 1,
			max = 7,
			step = 1
		}
	)
	self.Menu.ClearSet.Clear:MenuElement(
		{
			id = "UseW",
			name = "[W]",
			value = true
		}
	)
	self.Menu.ClearSet.Clear:MenuElement(
		{
			id = "WCount",
			name = "min Minions for [W]",
			value = 3,
			min = 1,
			max = 7,
			step = 1
		}
	)
	self.Menu.ClearSet.Clear:MenuElement(
		{
			id = "Mana",
			name = "Min Mana",
			value = 40,
			min = 0,
			max = 100,
			identifier = "%"
		}
	)

	-- JungleClear Menu
	self.Menu.ClearSet:MenuElement(
		{
			type = MENU,
			id = "JClear",
			name = "JungleClear Mode"
		}
	)
	self.Menu.ClearSet.JClear:MenuElement(
		{
			id = "UseQ",
			name = "[Q]",
			value = true
		}
	)
	self.Menu.ClearSet.JClear:MenuElement(
		{
			id = "UseW",
			name = "[W]",
			value = true
		}
	)
	self.Menu.ClearSet.JClear:MenuElement(
		{
			id = "UseE",
			name = "[E]",
			value = true
		}
	)
	self.Menu.ClearSet.JClear:MenuElement(
		{
			id = "Mana",
			name = "Min Mana",
			value = 40,
			min = 0,
			max = 100,
			identifier = "%"
		}
	)

	self.Menu:MenuElement(
		{
			type = MENU,
			id = "MiscSet",
			name = "Misc Settings"
		}
	)
	self.Menu.MiscSet:MenuElement(
		{
			type = MENU,
			id = "BlockAA",
			name = "Block AutoAttack"
		}
	)
	self.Menu.MiscSet.BlockAA:MenuElement(
		{
			name = " ",
			drop = {
				"BlockAA (Combo/AutoQ) if Q Ready or almost Ready"
			}
		}
	)
	self.Menu.MiscSet.BlockAA:MenuElement(
		{
			id = "Block",
			name = "Toggle Key",
			key = string.byte("Z"),
			value = true,
			toggle = true
		}
	)

	-- Prediction
	self.Menu.MiscSet:MenuElement(
		{
			type = MENU,
			id = "Pred",
			name = "Prediction Mode"
		}
	)
	self.Menu.MiscSet.Pred:MenuElement(
		{
			name = " ",
			drop = {
				"After change Prediction Typ press 2xF6"
			}
		}
	)
	self.Menu.MiscSet.Pred:MenuElement(
		{
			id = "Change",
			name = "Change Prediction Type",
			value = 3,
			drop = {
				"Gamsteron Prediction",
				"Premium Prediction",
				"GGPrediction"
			}
		}
	)
	self.Menu.MiscSet.Pred:MenuElement(
		{
			id = "WAOE",
			name = "Use AOE Pred",
			value = true
		}
	)
	self.Menu.MiscSet.Pred:MenuElement(
		{
			id = "PredW",
			name = "Hitchance[W]",
			value = 1,
			drop = {
				"Normal",
				"High",
				"Immobile"
			}
		}
	)
	self.Menu.MiscSet.Pred:MenuElement(
		{
			id = "PredE",
			name = "Hitchance[E]",
			value = 1,
			drop = {
				"Normal",
				"High",
				"Immobile"
			}
		}
	)

	-- Drawing
	self.Menu.MiscSet:MenuElement(
		{
			type = MENU,
			id = "Drawing",
			name = "Drawings Mode"
		}
	)
	self.Menu.MiscSet.Drawing:MenuElement(
		{
			id = "Draw_AutoQ",
			name = "Draw Auto Q indictator",
			value = true
		}
	)
	self.Menu.MiscSet.Drawing:MenuElement(
		{
			id = "Draw_BlockAA",
			name = "Draw Block AA indictator",
			value = true
		}
	)
	self.Menu.MiscSet.Drawing:MenuElement(
		{
			id = "DrawIsReady",
			name = "Ready Check",
			value = true
		}
	)
	self.Menu.MiscSet.Drawing:MenuElement(
		{
			id = "DrawQ",
			name = "Draw [Q] Range",
			value = false
		}
	)
	self.Menu.MiscSet.Drawing:MenuElement(
		{
			id = "DrawR",
			name = "Draw [R] Range",
			value = false
		}
	)
	self.Menu.MiscSet.Drawing:MenuElement(
		{
			id = "DrawE",
			name = "Draw [E] Range",
			value = false
		}
	)
	self.Menu.MiscSet.Drawing:MenuElement(
		{
			id = "DrawW",
			name = "Draw [W] Range",
			value = false
		}
	)
	-- self.Menu:MenuElement({id = "MenuTicks", name = "Unit Refresh: ", value = 10 , min = 1, max = 31, identifier = "ticks", callback = function(value) unitTicks = value end})
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(
			function(...)
				self:OnPreAttack(...)
			end
		)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(
			function(...)
				self:OnPreAttack(...)
			end
		)
	end
end

function Lillia:CastingChecks()
	if not CastingQ and not CastingE and not CastingR and not CastingW then
		return true
	else
		return false
	end
end

function Lillia:CanUse(spell, mode)
	if mode == nil then
		mode = GetMode()
	end
	-- PrintChat(GetMode())
	if spell == _Q then
		if mode == "Combo" and Ready(spell) and self.Menu.ComboSet.Combo.UseQ:Value() then
			return true
		end
		if mode == "Harass" and Ready(spell) and self.Menu.HarassMode.UseQ:Value() then
			return true
		end
		--[[         if mode == "AutoUlt" and Ready(spell) and self.Menu.AutoSet.UseQUlt:Value() then
            return true
        end ]]
		--[[         if mode == "Ult" and Ready(spell) and self.Menu.ComboSet.Combo.UseQUlt:Value() then
            return true
        end ]]
		if mode == "Auto" and Ready(spell) and self.Menu.AutoSet.AutoQ.UseQ:Value() then
			return true
		end
	elseif spell == _R then
		if mode == "Combo" and Ready(spell) and self.Menu.ComboSet.Combo.UseR:Value() then
			return true
		end
		if mode == "Auto" and Ready(spell) and self.Menu.AutoSet.AutoR.UseR:Value() then
			return true
		end
	elseif spell == _W then
		if mode == "Combo" and Ready(spell) and self.Menu.ComboSet.Combo.UseW:Value() then
			return true
		end
		if mode == "Harass" and Ready(spell) and self.Menu.HarassMode.UseW:Value() then
			return true
		end
	elseif spell == _E then
		if mode == "Combo" and Ready(spell) and self.Menu.ComboSet.Combo.UseE:Value() then
			return true
		end
		if mode == "Force" and Ready(spell) then
			return true
		end
		if mode == "Harass" and Ready(spell) and self.Menu.HarassMode.UseE:Value() then
			return true
		end
		--[[         if mode == "ComboGap" and Ready(spell) and self.Menu.ComboMode.UseEGap:Value() then
            return true
        end ]]
		if mode == "Auto" and Ready(spell) and self.Menu.AutoSet.AutoE.UseE:Value() then
			return true
		end
		--[[         if mode == "AutoGap" and Ready(spell) and self.Menu.AutoSet.UseEGap:Value() then
            return true
        end ]]
	end
	return false
end

function Lillia:Tick()
	CastingQ = myHero.activeSpell.name == "LilliaQ"
	CastingW = myHero.activeSpell.name == "LilliaW"
	CastingE = myHero.activeSpell.name == "LilliaE"
	CastingR = myHero.activeSpell.name == "LilliaR"
	if heroes == false then
		local EnemyCount = CheckLoadedEnemyies()
		if EnemyCount <= 1 then -- if not EnemyCount == 0 or nil
			LoadUnits()
		else
			heroes = true
		end
	else
		-- end
		-- if unitClock < Game.Timer then LoadUnits() end
		if MyHeroNotReady() then
			return
		end
		mode = GetMode() -- "Combo", "Harass", "LaneClear", JungleClear, "LastHit", "Flee"
		-- print(GetMode())
		if mode == "LaneClear" then
			self:JungleClear()
			self:Clear()
		end
		-- for i, target in pairs(Enemies) do
		-- for i = 1, Game.HeroCount() do
		-- local unit = Game.Hero(i);
		-- for
		local unit = GetTarget(math.max(self.Menu.ECastRange:Value(), self.Menu.RRange:Value())) -- GetEnemyHeroes() --2000
		if unit then
			-- print(unit.charName)
			if mode == "Combo" then
				self:Combo(unit)
			end
			self:Auto(unit)
		end
	end
end

function Lillia:OnPreAttack(args)
	if self.Menu.MiscSet.BlockAA.Block:Value() then
		if
			((mode == "Combo" or self.Menu.AutoSet.AutoQ.UseQ:Value()) and (Ready(_Q) or myHero:GetSpellData(_Q).currentCd < 1.5))
		then -- self:CanUse(_Q, "Combo") or
			args.Process = false
			return
		else
			args.Process = true
		end
	end
end

function Lillia:CastR(...)
	-- for i, target in ipairs(GetEnemyHeroes()) do
	-- local CastRange = self.Menu.RRange:Value()
	-- if target and myHero.pos:DistanceTo(target.pos) <= CastRange and IsValid(target) and Ready(_R) then
	-- local count = GetBuffedEnemyCount(CastRange, myHero)
	-- if count >= self.Menu.RCount:Value() then
	-- Control.CastSpell(HK_R)
	-- end
	-- end
	-- end
	return Control.CastSpell(HK_R, ...)
end

function Lillia:CastQ(...)
	return Control.CastSpell(HK_Q, ...)
end

function Lillia:CastW(...)
	return Control.CastSpell(HK_W, ...)
end

function Lillia:CastE(...)
	return Control.CastSpell(HK_E, ...)
end

function Lillia:Auto(unit)
	if self.Menu.AutoSet.AutoQ.UseQ:Value() then
		self:AutoQ(unit)
	end
	if self.Menu.AutoSet.AutoE.UseE:Value() then
		self:AutoE(unit)
	end
	if self.Menu.AutoSet.AutoR.UseR:Value() then
		self:AutoR(unit)
	end
end

function Lillia:AutoQ(unit)
	-- for i, target in ipairs(GetEnemyHeroes()) do
	if unit and myHero.pos:DistanceTo(unit.pos) <= minQRange and IsValid(unit) and Ready(_Q) then
		if self.Menu.AutoSet.AutoQ.QLogic:Value() == 1 then
			if myHero.pos:DistanceTo(unit.pos) > (225 + unit.boundingRadius) then
				self:CastQ()
			end
		else
			self:CastQ()
		end
	end
	-- end
end

function Lillia:AutoE(unit)
	local Etarget = nil
	-- for i, target in pairs(Enemies) do
	if unit and not unit.dead and IsValid(unit) then
		--
		if not unit and GetMode() == "Combo" and self:CanUse(_E, GetMode()) then
			if Etarget == nil or (GetDistance(unit.pos, mousePos) < GetDistance(Etarget.pos, mousePos)) then
				Etarget = unit
			end
		end
	end
	-- end
	if Etarget and self:CastingChecks() and IsValid(Etarget) then
		self:UseE(Etarget)
	end
end

function Lillia:AutoR(unit)
	local NumRTargets = 0
	-- for i, target in pairs(Enemies) do
	if unit and not unit.dead and IsValid(unit) then
		--
		local Buff = HasBuff(unit, rbuffName)
		if Buff ~= nil then
			NumRTargets = NumRTargets + 1
		end
	end
	-- end
	if
		self:CanUse(_R, "Auto") and NumRTargets >= self.Menu.RCount:Value() and self.Menu.UseRCount:Value() or
		self:CanUse(_R, "Combo") and NumRTargets >= self.Menu.RCount:Value() and self.Menu.ComboSet.Combo.UseRCount:Value()
	then
		self:CastR()
	end
end

function Lillia:Combo(unit)
	-- local unit = GetTarget(math.max(self.Menu.ECastRange:Value(), self.Menu.RRange:Value())) --GetEnemyHeroes() --2000
	-- for i, unit in ipairs(GetEnemyHeroes()) do
	if unit == nil then
		return
	end
	if IsValid(unit) then
		if not self.Menu.AutoSet.AutoQ.UseQ:Value() and self.Menu.ComboSet.Combo.UseQ:Value() and Ready(_Q) then
			if self.Menu.ComboSet.Combo.QLogic:Value() == 1 then
				if myHero.pos:DistanceTo(unit.pos) < minQRange and myHero.pos:DistanceTo(unit.pos) > (225 + unit.boundingRadius) then
					self:CastQ()
				end
			else
				if myHero.pos:DistanceTo(unit.pos) < minQRange then
					self:CastQ()
				end
			end
		end

		if self.Menu.ComboSet.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(unit.pos) <= wRange + wData.Radius then
				self:CastW(unit)
			end
		end

		if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(unit.pos) < self.Menu.ECastRange:Value() then
				self:CastE(unit)
			end
		end

		if self.Menu.ComboSet.Combo.UseR:Value() and Ready(_R) then
			if myHero.pos:DistanceTo(unit.pos) < self.Menu.RRange:Value() then
				local FullDmg = CalcDmg(unit)
				if FullDmg >= unit.health then
					self:CastR()
				end
			end
		end
	end
	-- end
end

function Lillia:JungleClear()
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.team == TEAM_JUNGLE and IsValid(minion) then
			if
				myHero.pos:DistanceTo(minion.pos) <= wRange + wData.Radius and self.Menu.ClearSet.JClear.UseW:Value() and Ready(_W) and
				myHero.mana / myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100
			then
				self:PredW(minion) -- Control.CastSpell(HK_W, minion.pos)
			end

			if
				myHero.pos:DistanceTo(minion.pos) <= eMinRange and self.Menu.ClearSet.JClear.UseE:Value() and Ready(_E) and
				myHero.mana / myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100
			then
				self:PredE(minion) -- Control.CastSpell(HK_E, minion.pos)
			end

			if
				myHero.pos:DistanceTo(minion.pos) <= minQRange and self.Menu.ClearSet.JClear.UseQ:Value() and Ready(_Q) and
				myHero.mana / myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100
			then
				self:CastQ()
			end
		end
	end
end

function Lillia:Clear()
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if
				myHero.pos:DistanceTo(minion.pos) <= minQRange and self.Menu.ClearSet.Clear.UseW:Value() and Ready(_W) and
				myHero.mana / myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100
			then
				local Count = GetMinionCount(minQRange, minion)
				if Count >= self.Menu.ClearSet.Clear.WCount:Value() then
					self:PredW(minion)
				end
			end

			if
				myHero.pos:DistanceTo(minion.pos) <= minQRange and self.Menu.ClearSet.Clear.UseQ:Value() and Ready(_Q) and
				myHero.mana / myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100
			then
				local Count = GetMinionCount(minQRange, minion)
				if Count >= self.Menu.ClearSet.Clear.QCount:Value() then
					self:CastQ()
				end
			end
		end
	end
end

function Lillia:PredW(unit)
	local aoe = self.Menu.MiscSet.Pred.WAOE:Value()
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, wData, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredW:Value() + 1 then
			return self:CastW(pred.CastPosition)
		end
	elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, wspellData)
		if aoe then
			pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, wspellData)
		end
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredW:Value(), pred.HitChance) then
			return self:CastW(pred.CastPos)
		end
	else
		local WPrediction = GGPrediction:SpellPrediction(wData)
		if aoe then
			WPrediction:GetAOEPrediction(myHero)
		else
			WPrediction:GetPrediction(unit, myHero)
		end
		if ConvertToHitChance(self.Menu.MiscSet.Pred.PredW:Value(), WPrediction.HitChance) then
			return self:CastW(WPrediction.CastPosition)
		end
	end
end

function Lillia:WallCollision(pos1, pos2)
	local Direction = Vector((pos1 - pos2):Normalized())
	local checks = GetDistance(pos1, pos2) / 50
	for i = 15, checks do
		-- for i = 1, checks do
		local CheckSpot = pos1 - Direction * (50 * i)
		local Adds = {
			Vector(100, 0, 0),
			Vector(66, 0, 66),
			Vector(0, 0, 100),
			Vector(-66, 0, 66),
			Vector(-100, 0, 0),
			Vector(66, 0, -66),
			Vector(0, 0, -100),
			Vector(-66, 0, -66)
		}
		for k = 1, #Adds do                        -- for i = 1, #Adds do
			local TargetAdded = Vector(CheckSpot + Adds[k]) -- Vector(CheckSpot + Adds[i])
			if MapPosition:inWall(TargetAdded) then
				Draw.Circle(CheckSpot, 30, 1, Draw.Color(255, 255, 0, 0))
				return true
			else
				Draw.Circle(CheckSpot, 30, 1, Draw.Color(255, 0, 191, 255))
			end
		end
	end
	return false
end

function Lillia:PredE(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, eData, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredE:Value() + 1 then
			return self:CastE(HK_E, pred.CastPosition)
		end
	elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
		--[[ 		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), pred.HitChance) then
			Control.CastSpell(HK_E, pred.CastPos)
		end ]]
		local lob = GetDistance(unit.pos) < eMinRange or myHero.pos:DistanceTo(unit.pos) < eMinRange
		if lob then
			self:UseELob(unit)
		else
			self:UseE(unit)
		end
	else
		--[[ 	local EPrediction = GGPrediction:SpellPrediction(EData)
	EPrediction:GetPrediction(unit, myHero)
	if EPrediction:CanHit(self.Menu.MiscSet.Pred.PredE:Value()+1) then
		Control.CastSpell(HK_E, EPrediction.CastPosition)
	end ]]
		local lob = GetDistance(unit.pos) < eMinRange or myHero.pos:DistanceTo(unit.pos) < eMinRange
		if lob then
			self:UseELobGGPred(unit)
		else
			self:UseEGGPred(unit)
		end
	end
end

function Lillia:UseELob(unit)
	local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, eSpellDataLob)
	if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), pred.HitChance) then
		return self:CastE(HK_E, pred.CastPos)
	end
end

function Lillia:UseELobGGPred(unit)
	local EPrediction = GGPrediction:SpellPrediction(eDataLob)
	EPrediction:GetPrediction(unit, myHero)
	if ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), EPrediction.HitChance) then
		self:CastE(HK_E, EPrediction.CastPosition)
	end
end

function Lillia:UseE(unit)
	local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, espellData)
	if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), pred.HitChance) then
		local Direction2 = Vector((myHero.pos - pred.CastPos):Normalized())
		local Pos2 = myHero.pos - Direction2 * eMinRange
		local pred2 = _G.PremiumPrediction:GetPrediction(Pos2, unit, eSpellDataCol)
		if pred2.CastPos and pred2.HitChance >= 0 then
			local direction = Vector((myHero.pos - pred.CastPos):Normalized())
			local distance = eMinRange
			local Spot = myHero.pos - direction * distance
			-- local MouseSpotBefore = mousePos
			if not self:WallCollision(myHero.pos, pred.CastPos) then
				local MouseSpotBefore = mousePos
				-- PrintChat("Casting E")
				-- PrintChat(pred.CastPos:ToScreen().onScreen)
				if pred.CastPos:ToScreen().onScreen then -- obj.pos:To2D().onScreen
					self:CastE(HK_E, pred.CastPos)
				else
					-- Control.SetCursorPos(MouseSpotBefore)
					-- Control.CastSpell(HK_E, Spot)
					local MMSpot = Vector(pred.CastPos):ToMM()
					Control.SetCursorPos(MMSpot.x, MMSpot.y)
					Control.KeyDown(HK_E)
					Control.KeyUp(HK_E)
					DelayAction(
						function()
							Control.SetCursorPos(MouseSpotBefore)
						end,
						0.20
					)
				end
			end
		end
	end
end

function Lillia:UseEGGPred(unit)
	local EPrediction = GGPrediction:SpellPrediction(eData)
	EPrediction:GetPrediction(unit, myHero)
	if EPrediction.CastPosition and ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), EPrediction.HitChance) then
		local Direction2 = Vector((myHero.pos - EPrediction.CastPosition):Normalized())
		local Pos2 = myHero.pos - Direction2 * eMinRange
		local pred2 = GGPrediction:SpellPrediction(eDataCol)
		pred2:GetPrediction(unit, Pos2)
		if pred2.CastPosition and pred2.HitChance >= 0 then
			local direction = Vector((myHero.pos - EPrediction.CastPosition):Normalized())
			local distance = eMinRange
			local Spot = myHero.pos - direction * distance
			local MouseSpotBefore = mousePos
			if not self:WallCollision(myHero.pos, EPrediction.CastPosition) then
				if EPrediction.CastPosition:ToScreen().onScreen then
					self:CastE(HK_E, EPrediction.CastPosition)
				else
					local MMSpot = Vector(EPrediction.CastPosition):ToMM()
					Control.SetCursorPos(MMSpot.x, MMSpot.y)
					Control.KeyDown(HK_E)
					Control.KeyUp(HK_E)
					DelayAction(
						function()
							Control.SetCursorPos(MouseSpotBefore)
						end,
						0.20
					)
				end
			end
		end
	end
end

function Lillia:Draw()
	if heroes == false then
		Draw.Text(
			myHero.charName .. " is Loading (Search Enemys) !!",
			24,
			myHero.pos2D.x - 50,
			myHero.pos2D.y + 195,
			Draw.Color(169, 255, 0, 0)
		)
	else
		if DrawTime == false then
			Draw.Text(
				myHero.charName .. " is Ready !!",
				24,
				myHero.pos2D.x - 50,
				myHero.pos2D.y + 195,
				Draw.Color(169, 0, 255, 0)
			)
			DelayAction(
				function()
					DrawTime = true
				end,
				3.0
			)
		end
	end

	if myHero.dead then
		return
	end
	local posX, posY
	local mePos = myHero.pos:To2D()
	local reachCheck = self.Menu.MiscSet.Drawing.DrawIsReady:Value()

	if self.Menu.MiscSet.Drawing.Draw_AutoQ:Value() then
		posX = mePos.x - 50
		posY = mePos.y

		if self.Menu.AutoSet.AutoQ.UseQ:Value() then
			Draw.Text(
				"[" .. tostring(string.char(self.Menu.AutoSet.AutoQ.UseQ:Key())) .. "] Auto Q Enabled",
				(12),
				posX,
				posY,
				Draw.Color(150, 000, 255, 000)
			)
		else
			Draw.Text(
				"[" .. tostring(string.char(self.Menu.AutoSet.AutoQ.UseQ:Key())) .. "] Auto Q Disabled",
				(12),
				posX,
				posY,
				Draw.Color(150, 255, 000, 000)
			)
		end
	end

	if self.Menu.MiscSet.Drawing.Draw_BlockAA:Value() then
		posX = mePos.x - 50
		posY = mePos.y + 16

		if self.Menu.MiscSet.BlockAA.Block:Value() then
			Draw.Text(
				"[" .. tostring(string.char(self.Menu.MiscSet.BlockAA.Block:Key())) .. "] Misc/Block AA Enabled",
				(12),
				posX,
				posY,
				Draw.Color(150, 000, 255, 000)
			)
		else
			Draw.Text(
				"[" .. tostring(string.char(self.Menu.MiscSet.BlockAA.Block:Key())) .. "] Misc/Block AA Disabled",
				(12),
				posX,
				posY,
				Draw.Color(150, 255, 000, 000)
			)
		end
	end

	if self.Menu.MiscSet.Drawing.DrawR:Value() and reachCheck == true and Ready(_R) then
		local rMaxRange = self.Menu.RRange:Value()
		local extpos = myHero.pos:Extended(myHero.pos, rMaxRange)
		if extpos:To2D().onScreen then
			Draw.Circle(myHero, rMaxRange, 1, color.R())
		else
			Draw.CircleMinimap(myHero, rMaxRange, 1, color.R())
		end
		Draw.CircleMinimap(myHero, rMaxRange, 1, color.R())
		Draw.Circle(myHero, self.Menu.RRange:Value(), 1, color.R())
	end
	if self.Menu.MiscSet.Drawing.DrawQ:Value() and reachCheck == true and Ready(_Q) then
		local edgeQRange = (225 + myHero.boundingRadius)
		-- local maxQRange = (minQRange+myHero.boundingRadius)
		Draw.Circle(myHero, minQRange, 1, color.Q(69)) -- Draw.Color(69, 225, 0, 10)
		-- Draw.Circle(myHero, maxQRange, 1, color.Q(169)) --Draw.Color(169, 225, 0, 10)
		Draw.Circle(myHero, edgeQRange, 1, color.Q()) -- Draw.Color(225, 225, 0, 10)
	end
	if self.Menu.MiscSet.Drawing.DrawE:Value() and reachCheck == true and Ready(_E) then
		Draw.Circle(myHero, eMinRange, 1, color.E(169)) -- Draw.Color(169, 225, 125, 10)
		if self.Menu.ECastRange:Value() then
			local eMaxRange = self.Menu.ECastRange:Value()
			local extpos = myHero.pos:Extended(myHero.pos, eMaxRange)
			if extpos:To2D().onScreen then
				Draw.Circle(myHero, eMaxRange, 1, color.E()) -- Draw.Color(225, 225, 125, 10)
			else
				Draw.CircleMinimap(myHero, eMaxRange, 1, color.E()) -- Draw.Color(225, 225, 125, 10)
			end
		end
	end
	if self.Menu.MiscSet.Drawing.DrawW:Value() and reachCheck == true and Ready(_W) then
		Draw.Circle(myHero, wRange + wData.Radius, 1, color.W()) -- Draw.Color(225, 225, 125, 10)
	end
end

Callback.Add(
	"Load",
	function()
		if loadPLillia then
			local delay = 10 -- set with this
			local base = 0.07 -- base non-zero delay
			DelayAction(
				function()
					--
					LoadUnits()
					_G[myHero.charName]()
				end,
				math.max(base, delay - Game.Timer())
			)
		end
	end
)

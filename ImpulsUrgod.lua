local Heroes = {
    "Urgot",
}
local Champion = myHero.charName
local version = 0.07
local author = "Impuls"

local scriptPath = debug.getinfo(1, "S").source:sub(2)
local fileName = scriptPath:match("[\\/]([^\\/]-)$")
local SCRIPT_NAME = fileName:gsub("%.lua$", "")

if not table.contains(Heroes, myHero.charName) then
    return
end
require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"

local UrgotQ = {
    delay = 0.25 + 0.30,
    speed = math.huge,
    radius = 210,
    range = 800,
    collision = true,
} -- +0.25 cast delay | 0.30 = mis delay
local UrgotW = {
    delay = 0.00,
    speed = 1600,
    radius = 475,
    range = (475 + (myHero.boundingRadius)),
    collision = true,
}
local UrgotE = {
    delay = 0.45,
    speed = 1500,
    radius = 100,
    range = (475 + (myHero.boundingRadius)),
    collision = true,
}
local UrgotR = {
    delay = 0.5,
    speed = 3200,
    radius = 80,
    range = 2500,
    collision = true,
}
local Q = {
    Delay = UrgotQ.delay,
    Radius = UrgotQ.radius,
    Range = UrgotQ.range,
    Speed = UrgotQ.speed,
    Collision = false,
    Type = GGPrediction.SPELLTYPE_CIRCLE,
}
local W = {
    Delay = UrgotW.delay,
    Radius = UrgotW.radius,
    Range = UrgotW.range,
    Speed = UrgotW.speed,
    Collision = false,
    Type = GGPrediction.SPELLTYPE_CIRCLE,
}
local E = {
    Delay = UrgotE.delay,
    Radius = UrgotE.radius,
    Range = UrgotE.range,
    Speed = UrgotE.speed,
    Collision = UrgotE.collision,
    CollisionTypes = {
        GGPrediction.COLLISION_ENEMYHERO,
    },
    Type = GGPrediction.SPELLTYPE_LINE,
}
local R = {
    Delay = UrgotR.delay,
    Radius = UrgotR.radius,
    Range = UrgotR.range,
    Speed = UrgotR.speed,
    Collision = UrgotR.collision,
    CollisionTypes = {
        GGPrediction.COLLISION_ENEMYHERO,
    },
    Type = GGPrediction.SPELLTYPE_LINE,
}

local DrawInfo = false
local EnemyLoaded = false

local EliteMonsters = {
    "SRU_RiftHerald",
    "SRU_Baron",
    "SRU_Dragon_Elder",
    "SRU_Dragon_Water",
    "SRU_Dragon_Fire",
    "SRU_Dragon_Earth",
    "SRU_Dragon_Air",
    "SRU_Dragon_Chemtech",
    "SRU_Dragon_Hextech",
    "SRU_Blue",
    "SRU_Red",
    "SRU_Crab",
    "SRU_Gromp",
    "SRU_ChaosMinionSiege",
    "SRU_OrderMinionSiege",
    "HA_ChaosMinionSiege",
    "HA_OrderMinionSiege",
}
local MeleeMinionList = {
    "SRU_ChaosMinionMelee",
    "SRU_OrderMinionMelee",
    "HA_ChaosMinionMelee",
    "HA_OrderMinionMelee",
}
local RangedMinionList = {
    "SRU_ChaosMinionRanged",
    "SRU_OrderMinionRanged",
    "HA_ChaosMinionRanged",
    "HA_OrderMinionRanged",
}
local SiegeMinionList = {
    "SRU_ChaosMinionSiege",
    "SRU_OrderMinionSiege",
    "HA_ChaosMinionSiege",
    "HA_OrderMinionSiege",
}
local SuperMinionList = {
    "SRU_ChaosMinionSuper",
    "SRU_OrderMinionSuper",
    "HA_ChaosMinionSuper",
    "HA_OrderMinionSuper",
}
local NormalMinionList = {
    "SRU_ChaosMinionRanged",
    "SRU_OrderMinionRanged",
    "SRU_ChoasMinionMelee",
    "SRU_OrderMinionMelee",
    "HA_ChaosMinionMelee",
    "HA_OrderMinionMelee",
    "HA_ChaosMinionRanged",
    "HA_OrderMinionRanged",
}

Callback.Add("Draw", function()
    if DrawInfo then
        Draw.Text("[ Impuls ] scripts will after ~[1-15]s in-game time", 18, myHero.pos2D.x - 50, myHero.pos2D.y + 195,
            Draw.Color(0xFF008080))
    end
end)

-- [[ Update ]] --
-- local mapName = DamageLib:GetMapIDName(Game.mapID)

local localName = scriptPath:match("[\\/]([^\\/]-)$")
local gitHub = "https://raw.githubusercontent.com/" .. author .. "x/GoS/master/" .. localName
local file = {
    script = {
        path = SCRIPT_PATH,
        name = SCRIPT_NAME .. ".lua",
    },
    common = {
        path = COMMON_PATH,
        name = SCRIPT_NAME .. ".lua",
    },
    sprite = {
        path = SPRITE_PATH,
        name = SCRIPT_NAME .. ".png",
    },
    sounds = {
        path = SOUNDS_PATH,
        name = SCRIPT_NAME .. ".mp3",
    },
    fonts = {
        path = FONTS_PATH,
        name = SCRIPT_NAME .. ".ttf",
    },
    version = {
        scriptpath = SCRIPT_PATH, -- or self.file.script.path,
        commonpath = COMMON_PATH, -- or self.file.common.path,
        name = SCRIPT_NAME .. ".version",
    },
}
local function update()
    local function readAll(fileName)
        local f = assert(io.open(file, "r"))
        local content = f:read("*all")
        f:close()
        return content
    end
    local function downloadFile(path, fileName)
        DownloadFileAsync(gitHub .. fileName, path .. fileName, function()
        end)
        while not FileExist(path .. fileName) do
        end
    end
    local function readFile(path, fileName)
        local file = assert(io.open(path .. fileName, "r"))
        local result = file:read()
        file:close()
        return result
    end
    local function initializeScript()
        local function writeModule(content)
            local f = assert(io.open(file.script.path .. file.lua.name, content and "a" or "w"))
            if content then
                f:write(content)
            end
            f:close()
        end
        --
        writeModule()
        local newVersion = version
        -- Write the core module
        writeModule(readAll(file.script.path .. file.script.name))
        -- writeModule(readAll(AUTO_PATH..coreName))
        -- writeModule(readAll(CHAMP_PATH..charName..dotlua))
        -- Load the active module
        dofile(file.script.path .. file.script.name)
        if newVersion > version then
            print("*ERR* | " .. SCRIPT_NAME .. " | - [RE.initialize] - [*NEW* ver. " .. tostring(newVersion) ..
                "] > [ver. " .. tostring(version) .. "]")
        end
    end

    downloadFile(file.version.scriptpath, file.version.name)
    local NewVersion = tonumber(readFile(file.version.scriptpath, file.version.name))
    if NewVersion > version then
        downloadFile(file.script.path, file.script.name)
        print("*WARN* NEW | " .. SCRIPT_NAME .. " | - [ver. " .. tostring(NewVersion) ..
            "] Downloaded - Please RELOAD with [F6]")
        -- print("*WARNING* New " .. SCRIPT_NAME .. " [ver. " .. tostring(NewVersion) .. "] Downloaded - RELOADING")
        -- initializeScript()
    else
        local jitStatus = jit and "enabled" or "disabled"
        print("| " .. SCRIPT_NAME .. " | - [ver. " .. version .. " | EXTP: " .. jitStatus .. "] - Welcome to: " ..
            "URGOD" .. "!"); -- mapName
    end
end
update()

----------------------------------------------------
-- |                    Checks                    |--
----------------------------------------------------

--[[ if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	print("gamsteronPred. installed Press 2x F6")
	return
end ]]

if not FileExist(COMMON_PATH .. "PremiumPrediction.lua") then
    DownloadFileAsync("https://raw.githubusercontent.com/Ark223/GoS-Scripts/master/PremiumPrediction.lua",
        COMMON_PATH .. "PremiumPrediction.lua", function()
        end)
    print("PremiumPred. installed Press 2x F6")
    return
end

if not FileExist(COMMON_PATH .. "GGPrediction.lua") then
    DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGPrediction.lua",
        COMMON_PATH .. "GGPrediction.lua", function()
        end)
    print("GGPrediction installed Press 2x F6")
    return
end

----------------------------------------------------
-- |                    Utils                     |--
----------------------------------------------------

local ControlCastSpell = Control.CastSpell;
local GetTickCount = GetTickCount;
local GameTimer = Game.Timer;
local GameHeroCount = Game.HeroCount;
local GameHero = Game.Hero;
local GameCanUseSpell = Game.CanUseSpell
local GameMinionCount = Game.MinionCount;
local GameMinion = Game.Minion;
local GameTurretCount = Game.TurretCount;
local GameTurret = Game.Turret;
local GameWardCount = Game.WardCount;
local GameWard = Game.Ward;
local GameMissileCount = Game.MissileCount;
local GameMissile = Game.Missile;
local GameParticleCount = Game.ParticleCount;
local GameParticle = Game.Particle;

local sqrt = math.sqrt
local pow = math.pow
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove

local Allies, Enemies, Turrets, Units = {}, {}, {}, {}

local PredLoaded = false

local CCSpells = {
    ["AatroxW"] = {
        charName = "Aatrox",
        displayName = "Infernal Chains",
        slot = _W,
        type = "linear",
        speed = 1800,
        range = 825,
        delay = 0.25,
        radius = 80,
        collision = true,
    },
    ["AhriSeduce"] = {
        charName = "Ahri",
        displayName = "Seduce",
        slot = _E,
        type = "linear",
        speed = 1500,
        range = 975,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["AkaliR"] = {
        charName = "Akali",
        displayName = "Perfect Execution [First]",
        slot = _R,
        type = "linear",
        speed = 1800,
        range = 525,
        delay = 0,
        radius = 65,
        collision = false,
    },
    ["AkaliE"] = {
        charName = "Akali",
        displayName = "Shuriken Flip",
        slot = _E,
        type = "linear",
        speed = 1800,
        range = 825,
        delay = 0.25,
        radius = 70,
        collision = true,
    },
    ["Pulverize"] = {
        charName = "Alistar",
        displayName = "Pulverize",
        slot = _Q,
        type = "circular",
        speed = MathHuge,
        range = 0,
        delay = 0.25,
        radius = 365,
        collision = false,
    },
    ["BandageToss"] = {
        charName = "Amumu",
        displayName = "Bandage Toss",
        slot = _Q,
        type = "linear",
        speed = 2000,
        range = 1100,
        delay = 0.25,
        radius = 80,
        collision = true,
    },
    ["CurseoftheSadMummy"] = {
        charName = "Amumu",
        displayName = "Curse of the Sad Mummy",
        slot = _R,
        type = "circular",
        speed = MathHuge,
        range = 0,
        delay = 0.25,
        radius = 550,
        collision = false,
    },
    ["FlashFrostSpell"] = {
        charName = "Anivia",
        displayName = "Flash Frost",
        missileName = "FlashFrostSpell",
        slot = _Q,
        type = "linear",
        speed = 850,
        range = 1100,
        delay = 0.25,
        radius = 110,
        collision = false,
    },
    ["EnchantedCrystalArrow"] = {
        charName = "Ashe",
        displayName = "Enchanted Crystal Arrow",
        slot = _R,
        type = "linear",
        speed = 1600,
        range = 25000,
        delay = 0.25,
        radius = 130,
        collision = false,
    },
    ["ApheliosR"] = {
        charName = "Aphelios",
        displayName = "Moonlight Vigil",
        slot = _R,
        type = "linear",
        speed = 2050,
        range = 1600,
        delay = 0.5,
        radius = 125,
        collision = false,
    },
    ["AurelionSolQ"] = {
        charName = "AurelionSol",
        displayName = "Starsurge",
        slot = _Q,
        type = "linear",
        speed = 850,
        range = 25000,
        delay = 0,
        radius = 110,
        collision = false,
    },
    ["AzirR"] = {
        charName = "Azir",
        displayName = "Emperor's Divide",
        slot = _R,
        type = "linear",
        speed = 1400,
        range = 500,
        delay = 0.3,
        radius = 250,
        collision = false,
    },
    ["BardQ"] = {
        charName = "Bard",
        displayName = "Cosmic Binding",
        slot = _Q,
        type = "linear",
        speed = 1500,
        range = 950,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["BardR"] = {
        charName = "Bard",
        displayName = "Tempered Fate",
        slot = _R,
        type = "circular",
        speed = 2100,
        range = 3400,
        delay = 0.5,
        radius = 350,
        collision = false,
    },
    ["RocketGrab"] = {
        charName = "Blitzcrank",
        displayName = "Rocket Grab",
        slot = _Q,
        type = "linear",
        speed = 1800,
        range = 1150,
        delay = 0.25,
        radius = 140,
        collision = true,
    },
    ["BrandQ"] = {
        charName = "Brand",
        displayName = "Sear",
        slot = _Q,
        type = "linear",
        speed = 1600,
        range = 1050,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["BraumQ"] = {
        charName = "Braum",
        displayName = "Winter's Bite",
        slot = _Q,
        type = "linear",
        speed = 1700,
        range = 1000,
        delay = 0.25,
        radius = 70,
        collision = true,
    },
    ["BraumR"] = {
        charName = "Braum",
        displayName = "Glacial Fissure",
        slot = _R,
        type = "linear",
        speed = 1400,
        range = 1250,
        delay = 0.5,
        radius = 115,
        collision = false,
    },
    ["CamilleE"] = {
        charName = "Camille",
        displayName = "Hookshot [First]",
        slot = _E,
        type = "linear",
        speed = 1900,
        range = 800,
        delay = 0,
        radius = 60,
        collision = false,
    },
    ["CamilleEDash2"] = {
        charName = "Camille",
        displayName = "Hookshot [Second]",
        slot = _E,
        type = "linear",
        speed = 1900,
        range = 400,
        delay = 0,
        radius = 60,
        collision = false,
    },
    ["CaitlynYordleTrap"] = {
        charName = "Caitlyn",
        displayName = "Yordle Trap",
        slot = _W,
        type = "circular",
        speed = MathHuge,
        range = 800,
        delay = 0.25,
        radius = 75,
        collision = false,
    },
    ["CaitlynEntrapment"] = {
        charName = "Caitlyn",
        displayName = "Entrapment",
        slot = _E,
        type = "linear",
        speed = 1600,
        range = 750,
        delay = 0.15,
        radius = 70,
        collision = true,
    },
    ["CassiopeiaW"] = {
        charName = "Cassiopeia",
        displayName = "Miasma",
        slot = _W,
        type = "circular",
        speed = 2500,
        range = 800,
        delay = 0.75,
        radius = 160,
        collision = false,
    },
    ["Rupture"] = {
        charName = "Chogath",
        displayName = "Rupture",
        slot = _Q,
        type = "circular",
        speed = MathHuge,
        range = 950,
        delay = 1.2,
        radius = 250,
        collision = false,
    },
    ["InfectedCleaverMissile"] = {
        charName = "DrMundo",
        displayName = "Infected Cleaver",
        slot = _Q,
        type = "linear",
        speed = 2000,
        range = 975,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["DianaQ"] = {
        charName = "Diana",
        displayName = "Crescent Strike",
        slot = _Q,
        type = "circular",
        speed = 1900,
        range = 900,
        delay = 0.25,
        radius = 185,
        collision = true,
    },
    ["DravenDoubleShot"] = {
        charName = "Draven",
        displayName = "Double Shot",
        slot = _E,
        type = "linear",
        speed = 1600,
        range = 1050,
        delay = 0.25,
        radius = 130,
        collision = false,
    },
    ["DravenRCast"] = {
        charName = "Draven",
        displayName = "Whirling Death",
        slot = _R,
        type = "linear",
        speed = 2000,
        range = 12500,
        delay = 0.25,
        radius = 160,
        collision = false,
    },
    ["EkkoQ"] = {
        charName = "Ekko",
        displayName = "Timewinder",
        slot = _Q,
        type = "linear",
        speed = 1650,
        range = 1175,
        delay = 0.25,
        radius = 60,
        collision = false,
    },
    ["EkkoW"] = {
        charName = "Ekko",
        displayName = "Parallel Convergence",
        slot = _W,
        type = "circular",
        speed = MathHuge,
        range = 1600,
        delay = 3.35,
        radius = 400,
        collision = false,
    },
    ["EliseHumanE"] = {
        charName = "Elise",
        displayName = "Cocoon",
        slot = _E,
        type = "linear",
        speed = 1600,
        range = 1075,
        delay = 0.25,
        radius = 55,
        collision = true,
    },
    ["EzrealR"] = {
        charName = "Ezreal",
        displayName = "Trueshot Barrage",
        slot = _R,
        type = "linear",
        speed = 2000,
        range = 12500,
        delay = 1,
        radius = 160,
        collision = true,
    },
    ["FizzR"] = {
        charName = "Fizz",
        displayName = "Chum the Waters",
        slot = _R,
        type = "linear",
        speed = 1300,
        range = 1300,
        delay = 0.25,
        radius = 150,
        collision = false,
    },
    ["GalioE"] = {
        charName = "Galio",
        displayName = "Justice Punch",
        slot = _E,
        type = "linear",
        speed = 2300,
        range = 650,
        delay = 0.4,
        radius = 160,
        collision = false,
    },
    ["GarenQ"] = {
        charName = "Garen",
        displayName = "Decisive Strike",
        slot = _Q,
        type = "targeted",
        range = 225,
    },
    ["GnarQMissile"] = {
        charName = "Gnar",
        displayName = "Boomerang Throw",
        slot = _Q,
        type = "linear",
        speed = 2500,
        range = 1125,
        delay = 0.25,
        radius = 55,
        collision = false,
    },
    ["GnarBigQMissile"] = {
        charName = "Gnar",
        displayName = "Boulder Toss",
        slot = _Q,
        type = "linear",
        speed = 2100,
        range = 1125,
        delay = 0.5,
        radius = 90,
        collision = true,
    },
    ["GnarBigW"] = {
        charName = "Gnar",
        displayName = "Wallop",
        slot = _W,
        type = "linear",
        speed = MathHuge,
        range = 575,
        delay = 0.6,
        radius = 100,
        collision = false,
    },
    ["GnarR"] = {
        charName = "Gnar",
        displayName = "GNAR!",
        slot = _R,
        type = "circular",
        speed = MathHuge,
        range = 0,
        delay = 0.25,
        radius = 475,
        collision = false,
    },
    ["GragasQ"] = {
        charName = "Gragas",
        displayName = "Barrel Roll",
        slot = _Q,
        type = "circular",
        speed = 1000,
        range = 850,
        delay = 0.25,
        radius = 275,
        collision = false,
    },
    ["GragasR"] = {
        charName = "Gragas",
        displayName = "Explosive Cask",
        slot = _R,
        type = "circular",
        speed = 1800,
        range = 1000,
        delay = 0.25,
        radius = 400,
        collision = false,
    },
    ["GravesSmokeGrenade"] = {
        charName = "Graves",
        displayName = "Smoke Grenade",
        slot = _W,
        type = "circular",
        speed = 1500,
        range = 950,
        delay = 0.15,
        radius = 250,
        collision = false,
    },
    ["HeimerdingerE"] = {
        charName = "Heimerdinger",
        displayName = "CH-2 Electron Storm Grenade",
        slot = _E,
        type = "circular",
        speed = 1200,
        range = 970,
        delay = 0.25,
        radius = 250,
        collision = false,
    },
    ["HeimerdingerEUlt"] = {
        charName = "Heimerdinger",
        displayName = "CH-2 Electron Storm Grenade",
        slot = _E,
        type = "circular",
        speed = 1200,
        range = 970,
        delay = 0.25,
        radius = 250,
        collision = false,
    },
    ["HecarimUlt"] = {
        charName = "Hecarim",
        displayName = "Onslaught of Shadows",
        slot = _R,
        type = "linear",
        speed = 1100,
        range = 1650,
        delay = 0.2,
        radius = 280,
        collision = false,
    },
    ["BlindMonkQOne"] = {
        charName = "Leesin",
        displayName = "Sonic Wave",
        slot = _Q,
        type = "linear",
        speed = 1800,
        range = 1100,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["IllaoiE"] = {
        charName = "Illaoi",
        displayName = "Test of Spirit",
        slot = _E,
        type = "linear",
        speed = 1900,
        range = 900,
        delay = 0.25,
        radius = 50,
        collision = true,
    },
    ["IreliaW2"] = {
        charName = "Irelia",
        displayName = "Defiant Dance",
        slot = _W,
        type = "linear",
        speed = MathHuge,
        range = 775,
        delay = 0.25,
        radius = 120,
        collision = false,
    },
    ["IreliaR"] = {
        charName = "Irelia",
        displayName = "Vanguard's Edge",
        slot = _R,
        type = "linear",
        speed = 2000,
        range = 950,
        delay = 0.4,
        radius = 160,
        collision = false,
    },
    ["IvernQ"] = {
        charName = "Ivern",
        displayName = "Rootcaller",
        slot = _Q,
        type = "linear",
        speed = 1300,
        range = 1075,
        delay = 0.25,
        radius = 80,
        collision = true,
    },
    ["JarvanIVDragonStrike"] = {
        charName = "JarvanIV",
        displayName = "Dragon Strike",
        slot = _Q,
        type = "linear",
        speed = MathHuge,
        range = 770,
        delay = 0.4,
        radius = 70,
        collision = false,
    },
    ["HowlingGaleSpell"] = {
        charName = "Janna",
        displayName = "Howling Gale",
        slot = _Q,
        type = "linear",
        speed = 1167,
        range = 1750,
        delay = 0,
        radius = 120,
        collision = false,
    },
    ["JhinW"] = {
        charName = "Jhin",
        displayName = "Deadly Flourish",
        slot = _W,
        type = "linear",
        speed = 5000,
        range = 2550,
        delay = 0.75,
        radius = 40,
        collision = false,
    },
    ["JhinE"] = {
        charName = "Jhin",
        displayName = "Captive Audience",
        slot = _E,
        type = "circular",
        speed = 1600,
        range = 750,
        delay = 0.25,
        radius = 130,
        collision = false,
    },
    ["JhinRShot"] = {
        charName = "Jhin",
        displayName = "Curtain Call",
        slot = _R,
        type = "linear",
        speed = 5000,
        range = 3500,
        delay = 0.25,
        radius = 80,
        collision = false,
    },
    ["JinxWMissile"] = {
        charName = "Jinx",
        displayName = "Zap!",
        slot = _W,
        type = "linear",
        speed = 3300,
        range = 1450,
        delay = 0.6,
        radius = 60,
        collision = true,
    },
    ["KarmaQ"] = {
        charName = "Karma",
        displayName = "Inner Flame",
        slot = _Q,
        type = "linear",
        speed = 1700,
        range = 950,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["KarmaQMantra"] = {
        charName = "Karma",
        displayName = "Inner Flame [Mantra]",
        slot = _Q,
        origin = "linear",
        type = "linear",
        speed = 1700,
        range = 950,
        delay = 0.25,
        radius = 80,
        collision = true,
    },
    ["KayleQ"] = {
        charName = "Kayle",
        displayName = "Radiant Blast",
        slot = _Q,
        type = "linear",
        speed = 2000,
        range = 850,
        delay = 0.5,
        radius = 60,
        collision = false,
    },
    ["KaynW"] = {
        charName = "Kayn",
        displayName = "Blade's Reach",
        slot = _W,
        type = "linear",
        speed = MathHuge,
        range = 700,
        delay = 0.55,
        radius = 90,
        collision = false,
    },
    ["KhazixWLong"] = {
        charName = "Khazix",
        displayName = "Void Spike [Threeway]",
        slot = _W,
        type = "threeway",
        speed = 1700,
        range = 1000,
        delay = 0.25,
        radius = 70,
        angle = 23,
        collision = true,
    },
    ["KledQ"] = {
        charName = "Kled",
        displayName = "Beartrap on a Rope",
        slot = _Q,
        type = "linear",
        speed = 1600,
        range = 800,
        delay = 0.25,
        radius = 45,
        collision = true,
    },
    ["KogMawVoidOozeMissile"] = {
        charName = "KogMaw",
        displayName = "Void Ooze",
        slot = _E,
        type = "linear",
        speed = 1400,
        range = 1360,
        delay = 0.25,
        radius = 120,
        collision = false,
    },
    ["LeblancE"] = {
        charName = "Leblanc",
        displayName = "Ethereal Chains [Standard]",
        slot = _E,
        type = "linear",
        speed = 1750,
        range = 925,
        delay = 0.25,
        radius = 55,
        collision = true,
    },
    ["LeblancRE"] = {
        charName = "Leblanc",
        displayName = "Ethereal Chains [Ultimate]",
        slot = _E,
        type = "linear",
        speed = 1750,
        range = 925,
        delay = 0.25,
        radius = 55,
        collision = true,
    },
    ["LeonaZenithBlade"] = {
        charName = "Leona",
        displayName = "Zenith Blade",
        slot = _E,
        type = "linear",
        speed = 2000,
        range = 875,
        delay = 0.25,
        radius = 70,
        collision = false,
    },
    ["LeonaSolarFlare"] = {
        charName = "Leona",
        displayName = "Solar Flare",
        slot = _R,
        type = "circular",
        speed = MathHuge,
        range = 1200,
        delay = 0.85,
        radius = 300,
        collision = false,
    },
    ["LilliaE"] = {
        charName = "Lillia",
        displayName = "Lillia E",
        slot = _E,
        type = "linear",
        speed = 1500,
        range = 750,
        delay = 0.4,
        radius = 150,
        collision = false,
    },
    ["LissandraQMissile"] = {
        charName = "Lissandra",
        displayName = "Ice Shard",
        slot = _Q,
        type = "linear",
        speed = 2200,
        range = 750,
        delay = 0.25,
        radius = 75,
        collision = false,
    },
    ["LuluQ"] = {
        charName = "Lulu",
        displayName = "Glitterlance",
        slot = _Q,
        type = "linear",
        speed = 1450,
        range = 925,
        delay = 0.25,
        radius = 60,
        collision = false,
    },
    ["LuxLightBinding"] = {
        charName = "Lux",
        displayName = "Light Binding",
        slot = _Q,
        type = "linear",
        speed = 1200,
        range = 1175,
        delay = 0.25,
        radius = 50,
        collision = false,
    },
    ["LuxLightStrikeKugel"] = {
        charName = "Lux",
        displayName = "Light Strike Kugel",
        slot = _E,
        type = "circular",
        speed = 1200,
        range = 1100,
        delay = 0.25,
        radius = 300,
        collision = true,
    },
    ["Landslide"] = {
        charName = "Malphite",
        displayName = "Ground Slam",
        slot = _E,
        type = "circular",
        speed = MathHuge,
        range = 0,
        delay = 0.242,
        radius = 400,
        collision = false,
    },
    ["UFSlash"] = {
        charName = "Malphite",
        displayName = "Unstoppable Force",
        slot = _R,
        type = "circular",
        speed = 1835,
        range = 1000,
        delay = 0,
        radius = 300,
        collision = false,
    },
    ["MalzaharQ"] = {
        charName = "Malzahar",
        displayName = "Call of the Void",
        slot = _Q,
        type = "rectangular",
        speed = 1600,
        range = 900,
        delay = 0.5,
        radius = 400,
        radius2 = 100,
        collision = false,
    },
    ["MaokaiQ"] = {
        charName = "Maokai",
        displayName = "Bramble Smash",
        slot = _Q,
        type = "linear",
        speed = 1600,
        range = 600,
        delay = 0.375,
        radius = 110,
        collision = false,
    },
    ["MorganaQ"] = {
        charName = "Morgana",
        displayName = "Dark Binding",
        slot = _Q,
        type = "linear",
        speed = 1200,
        range = 1250,
        delay = 0.25,
        radius = 70,
        collision = true,
    },
    ["MordekaiserE"] = {
        charName = "Mordekaiser",
        displayName = "Death's Grasp",
        slot = _E,
        type = "linear",
        speed = MathHuge,
        range = 900,
        delay = 0.9,
        radius = 140,
        collision = false,
    },
    ["NamiQ"] = {
        charName = "Nami",
        displayName = "Aqua Prison",
        slot = _Q,
        type = "circular",
        speed = MathHuge,
        range = 875,
        delay = 1,
        radius = 180,
        collision = false,
    },
    ["NamiRMissile"] = {
        charName = "Nami",
        displayName = "Tidal Wave",
        slot = _R,
        type = "linear",
        speed = 850,
        range = 2750,
        delay = 0.5,
        radius = 250,
        collision = false,
    },
    ["NautilusAnchorDragMissile"] = {
        charName = "Nautilus",
        displayName = "Dredge Line",
        slot = _Q,
        type = "linear",
        speed = 2000,
        range = 925,
        delay = 0.25,
        radius = 90,
        collision = true,
    },
    ["NeekoQ"] = {
        charName = "Neeko",
        displayName = "Blooming Burst",
        slot = _Q,
        type = "circular",
        speed = 1500,
        range = 800,
        delay = 0.25,
        radius = 200,
        collision = false,
    },
    ["NeekoE"] = {
        charName = "Neeko",
        displayName = "Tangle-Barbs",
        slot = _E,
        type = "linear",
        speed = 1400,
        range = 1000,
        delay = 0.25,
        radius = 65,
        collision = false,
    },
    ["NunuR"] = {
        charName = "Nunu",
        displayName = "Absolute Zero",
        slot = _R,
        type = "circular",
        speed = MathHuge,
        range = 0,
        delay = 3,
        radius = 650,
        collision = false,
    },
    ["OlafAxeThrowCast"] = {
        charName = "Olaf",
        displayName = "Undertow",
        slot = _Q,
        type = "linear",
        speed = 1600,
        range = 1000,
        delay = 0.25,
        radius = 90,
        collision = false,
    },
    ["OrnnQ"] = {
        charName = "Ornn",
        displayName = "Volcanic Rupture",
        slot = _Q,
        type = "linear",
        speed = 1800,
        range = 800,
        delay = 0.3,
        radius = 65,
        collision = false,
    },
    ["OrnnE"] = {
        charName = "Ornn",
        displayName = "Searing Charge",
        slot = _E,
        type = "linear",
        speed = 1600,
        range = 800,
        delay = 0.35,
        radius = 150,
        collision = false,
    },
    ["OrnnRCharge"] = {
        charName = "Ornn",
        displayName = "Call of the Forge God",
        slot = _R,
        type = "linear",
        speed = 1650,
        range = 2500,
        delay = 0.5,
        radius = 200,
        collision = false,
    },
    ["PoppyQSpell"] = {
        charName = "Poppy",
        displayName = "Hammer Shock",
        slot = _Q,
        type = "linear",
        speed = MathHuge,
        range = 430,
        delay = 0.332,
        radius = 100,
        collision = false,
    },
    ["PoppyRSpell"] = {
        charName = "Poppy",
        displayName = "Keeper's Verdict",
        slot = _R,
        type = "linear",
        speed = 2000,
        range = 1200,
        delay = 0.33,
        radius = 100,
        collision = false,
    },
    ["PykeQMelee"] = {
        charName = "Pyke",
        displayName = "Bone Skewer [Melee]",
        slot = _Q,
        type = "linear",
        speed = MathHuge,
        range = 400,
        delay = 0.25,
        radius = 70,
        collision = false,
    },
    ["PykeQRange"] = {
        charName = "Pyke",
        displayName = "Bone Skewer [Range]",
        slot = _Q,
        type = "linear",
        speed = 2000,
        range = 1100,
        delay = 0.2,
        radius = 70,
        collision = true,
    },
    ["PykeE"] = {
        charName = "Pyke",
        displayName = "Phantom Undertow",
        slot = _E,
        type = "linear",
        speed = 3000,
        range = 25000,
        delay = 0,
        radius = 110,
        collision = false,
    },
    ["QiyanaR"] = {
        charName = "Qiyana",
        displayName = "Supreme Display of Talent",
        slot = _R,
        type = "linear",
        speed = 2000,
        range = 950,
        delay = 0.25,
        radius = 190,
        collision = false,
    },
    ["RakanW"] = {
        charName = "Rakan",
        displayName = "Grand Entrance",
        slot = _W,
        type = "circular",
        speed = MathHuge,
        range = 650,
        delay = 0.7,
        radius = 265,
        collision = false,
    },
    ["RengarE"] = {
        charName = "Rengar",
        displayName = "Bola Strike",
        slot = _E,
        type = "linear",
        speed = 1500,
        range = 1000,
        delay = 0.25,
        radius = 70,
        collision = true,
    },
    ["RumbleGrenade"] = {
        charName = "Rumble",
        displayName = "Electro Harpoon",
        slot = _E,
        type = "linear",
        speed = 2000,
        range = 850,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["SeraphineE"] = {
        charName = "Seraphine",
        displayName = "Beat Drop",
        slot = _E,
        type = "linear",
        speed = 500,
        range = 1300,
        delay = 0.25,
        radius = 35,
        collision = false,
    },
    ["SettE"] = {
        charName = "Sett",
        displayName = "Facebreaker",
        slot = _E,
        type = "linear",
        speed = MathHuge,
        range = 490,
        delay = 0.25,
        radius = 175,
        collision = false,
    },
    ["SennaW"] = {
        charName = "Senna",
        displayName = "Last Embrace",
        slot = _W,
        type = "linear",
        speed = 1150,
        range = 1300,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["SejuaniR"] = {
        charName = "Sejuani",
        displayName = "Glacial Prison",
        slot = _R,
        type = "linear",
        speed = 1600,
        range = 1300,
        delay = 0.25,
        radius = 120,
        collision = false,
    },
    ["ShyvanaTransformLeap"] = {
        charName = "Shyvana",
        displayName = "Transform Leap",
        slot = _R,
        type = "linear",
        speed = 700,
        range = 850,
        delay = 0.25,
        radius = 150,
        collision = false,
    },
    ["ShenE"] = {
        charName = "Shen",
        displayName = "Shadow Dash",
        slot = _E,
        type = "linear",
        speed = 1200,
        range = 600,
        delay = 0,
        radius = 60,
        collision = false,
    },
    ["SionQ"] = {
        charName = "Sion",
        displayName = "Decimating Smash",
        slot = _Q,
        origin = "",
        type = "linear",
        speed = MathHuge,
        range = 750,
        delay = 2,
        radius = 150,
        collision = false,
    },
    ["SionE"] = {
        charName = "Sion",
        displayName = "Roar of the Slayer",
        slot = _E,
        type = "linear",
        speed = 1800,
        range = 800,
        delay = 0.25,
        radius = 80,
        collision = false,
    },
    ["SkarnerFractureMissile"] = {
        charName = "Skarner",
        displayName = "Fracture",
        slot = _E,
        type = "linear",
        speed = 1500,
        range = 1000,
        delay = 0.25,
        radius = 70,
        collision = false,
    },
    ["SonaR"] = {
        charName = "Sona",
        displayName = "Crescendo",
        slot = _R,
        type = "linear",
        speed = 2400,
        range = 1000,
        delay = 0.25,
        radius = 140,
        collision = false,
    },
    ["SorakaQ"] = {
        charName = "Soraka",
        displayName = "Starcall",
        slot = _Q,
        type = "circular",
        speed = 1150,
        range = 810,
        delay = 0.25,
        radius = 235,
        collision = false,
    },
    ["SwainW"] = {
        charName = "Swain",
        displayName = "Vision of Empire",
        slot = _W,
        type = "circular",
        speed = MathHuge,
        range = 3500,
        delay = 1.5,
        radius = 300,
        collision = false,
    },
    ["SwainE"] = {
        charName = "Swain",
        displayName = "Nevermove",
        slot = _E,
        type = "linear",
        speed = 1800,
        range = 850,
        delay = 0.25,
        radius = 85,
        collision = false,
    },
    ["SylasE2"] = {
        charName = "Sylas",
        displayName = "Abduct",
        slot = _E,
        type = "linear",
        speed = 1600,
        range = 850,
        delay = 0.25,
        radius = 60,
        collision = true,
    },
    ["TahmKenchQ"] = {
        charName = "TahmKench",
        displayName = "Tongue Lash",
        slot = _Q,
        type = "linear",
        speed = 2800,
        range = 800,
        delay = 0.25,
        radius = 70,
        collision = true,
    },
    ["TaliyahWVC"] = {
        charName = "Taliyah",
        displayName = "Seismic Shove",
        slot = _W,
        type = "circular",
        speed = MathHuge,
        range = 900,
        delay = 0.85,
        radius = 150,
        collision = false,
    },
    ["TaliyahR"] = {
        charName = "Taliyah",
        displayName = "Weaver's Wall",
        slot = _R,
        type = "linear",
        speed = 1700,
        range = 3000,
        delay = 1,
        radius = 120,
        collision = false,
    },
    ["ThreshE"] = {
        charName = "Thresh",
        displayName = "Flay",
        slot = _E,
        type = "linear",
        speed = MathHuge,
        range = 500,
        delay = 0.389,
        radius = 110,
        collision = true,
    },
    ["ThreshQ"] = {
        charName = "Thresh",
        displayName = "Death Sentence",
        slot = _Q,
        type = "linear",
        speed = 1900,
        range = 1100,
        delay = 0.5,
        radius = 70,
        collision = true,
    },
    ["TristanaW"] = {
        charName = "Tristana",
        displayName = "Rocket Jump",
        slot = _W,
        type = "circular",
        speed = 1100,
        range = 900,
        delay = 0.25,
        radius = 300,
        collision = false,
    },
    ["UrgotQ"] = {
        charName = "Urgot",
        displayName = "Corrosive Charge",
        slot = _Q,
        type = "circular",
        speed = MathHuge,
        range = 800,
        delay = 0.6,
        radius = 180,
        collision = false,
    },
    ["UrgotE"] = {
        charName = "Urgot",
        displayName = "Disdain",
        slot = _E,
        type = "linear",
        speed = 1540,
        range = 475,
        delay = 0.45,
        radius = 100,
        collision = false,
    },
    ["UrgotR"] = {
        charName = "Urgot",
        displayName = "Fear Beyond Death",
        slot = _R,
        type = "linear",
        speed = 3200,
        range = 1600,
        delay = 0.4,
        radius = 80,
        collision = false,
    },
    ["VarusE"] = {
        charName = "Varus",
        displayName = "Hail of Arrows",
        slot = _E,
        type = "linear",
        speed = 1500,
        range = 925,
        delay = 0.242,
        radius = 260,
        collision = false,
    },
    ["VarusR"] = {
        charName = "Varus",
        displayName = "Chain of Corruption",
        slot = _R,
        type = "linear",
        speed = 1950,
        range = 1200,
        delay = 0.25,
        radius = 120,
        collision = false,
    },
    ["VelkozQ"] = {
        charName = "Velkoz",
        displayName = "Plasma Fission",
        slot = _Q,
        type = "linear",
        speed = 1300,
        range = 1050,
        delay = 0.25,
        radius = 50,
        collision = true,
    },
    ["VelkozE"] = {
        charName = "Velkoz",
        displayName = "Tectonic Disruption",
        slot = _E,
        type = "circular",
        speed = MathHuge,
        range = 800,
        delay = 0.8,
        radius = 185,
        collision = false,
    },
    ["ViQ"] = {
        charName = "Vi",
        displayName = "Vault Breaker",
        slot = _Q,
        type = "linear",
        speed = 1500,
        range = 725,
        delay = 0,
        radius = 90,
        collision = false,
    },
    ["ViktorGravitonField"] = {
        charName = "Viktor",
        displayName = "Graviton Field",
        slot = _W,
        type = "circular",
        speed = MathHuge,
        range = 800,
        delay = 1.75,
        radius = 270,
        collision = false,
    },
    ["WarwickR"] = {
        charName = "Warwick",
        displayName = "Infinite Duress",
        slot = _R,
        type = "linear",
        speed = 1800,
        range = 3000,
        delay = 0.1,
        radius = 55,
        collision = false,
    },
    ["XerathArcaneBarrage2"] = {
        charName = "Xerath",
        displayName = "Arcane Barrage",
        slot = _W,
        type = "circular",
        speed = MathHuge,
        range = 1000,
        delay = 0.75,
        radius = 235,
        collision = false,
    },
    ["XerathMageSpear"] = {
        charName = "Xerath",
        displayName = "Mage Spear",
        slot = _E,
        type = "linear",
        speed = 1400,
        range = 1050,
        delay = 0.2,
        radius = 60,
        collision = true,
    },
    ["XinZhaoW"] = {
        charName = "XinZhao",
        displayName = "Wind Becomes Lightning",
        slot = _W,
        type = "linear",
        speed = 5000,
        range = 900,
        delay = 0.5,
        radius = 40,
        collision = false,
    },
    ["YasuoQ3Mis"] = {
        charName = "Yasuo",
        displayName = "Yasuo Q3",
        slot = _Q,
        type = "linear",
        speed = 1200,
        range = 1000,
        delay = 0.339,
        radius = 90,
        collision = false,
    },
    ["ZacQ"] = {
        charName = "Zac",
        displayName = "Stretching Strikes",
        slot = _Q,
        type = "linear",
        speed = 2800,
        range = 800,
        delay = 0.33,
        radius = 120,
        collision = false,
    },
    ["ZiggsW"] = {
        charName = "Ziggs",
        displayName = "Satchel Charge",
        slot = _W,
        type = "circular",
        speed = 1750,
        range = 1000,
        delay = 0.25,
        radius = 240,
        collision = false,
    },
    ["ZiggsE"] = {
        charName = "Ziggs",
        displayName = "Hexplosive Minefield",
        slot = _E,
        type = "circular",
        speed = 1800,
        range = 900,
        delay = 0.25,
        radius = 250,
        collision = false,
    },
    ["ZileanQ"] = {
        charName = "Zilean",
        displayName = "Time Bomb",
        slot = _Q,
        type = "circular",
        speed = MathHuge,
        range = 900,
        delay = 0.8,
        radius = 150,
        collision = false,
    },
    ["ZoeE"] = {
        charName = "Zoe",
        displayName = "Sleepy Trouble Bubble",
        slot = _E,
        type = "linear",
        speed = 1700,
        range = 800,
        delay = 0.3,
        radius = 50,
        collision = true,
    },
    ["ZyraE"] = {
        charName = "Zyra",
        displayName = "Grasping Roots",
        slot = _E,
        type = "linear",
        speed = 1150,
        range = 1100,
        delay = 0.25,
        radius = 70,
        collision = false,
    },
    ["ZyraR"] = {
        charName = "Zyra",
        displayName = "Stranglethorns",
        slot = _R,
        type = "circular",
        speed = MathHuge,
        range = 700,
        delay = 2,
        radius = 500,
        collision = false,
    },
    ["BrandConflagration"] = {
        charName = "Brand",
        slot = _R,
        type = "targeted",
        displayName = "Conflagration",
        range = 625,
        cc = true,
    },
    ["JarvanIVCataclysm"] = {
        charName = "JarvanIV",
        slot = _R,
        type = "targeted",
        displayName = "Cataclysm",
        range = 650,
    },
    ["JayceThunderingBlow"] = {
        charName = "Jayce",
        slot = _E,
        type = "targeted",
        displayName = "Thundering Blow",
        range = 240,
    },
    ["BlindMonkRKick"] = {
        charName = "LeeSin",
        slot = _R,
        type = "targeted",
        displayName = "Dragon's Rage",
        range = 375,
    },
    ["LissandraR"] = {
        charName = "Lissandra",
        slot = _R,
        type = "targeted",
        displayName = "Frozen Tomb",
        range = 550,
    },
    ["SeismicShard"] = {
        charName = "Malphite",
        slot = _Q,
        type = "targeted",
        displayName = "Seismic Shard",
        range = 625,
        cc = true,
    },
    ["AlZaharNetherGrasp"] = {
        charName = "Malzahar",
        slot = _R,
        type = "targeted",
        displayName = "Nether Grasp",
        range = 700,
    },
    ["MaokaiW"] = {
        charName = "Maokai",
        slot = _W,
        type = "targeted",
        displayName = "Twisted Advance",
        range = 525,
    },
    ["NautilusR"] = {
        charName = "Nautilus",
        slot = _R,
        type = "targeted",
        displayName = "Depth Charge",
        range = 825,
    },
    ["PoppyE"] = {
        charName = "Poppy",
        slot = _E,
        type = "targeted",
        displayName = "Heroic Charge",
        range = 475,
    },
    ["RyzeW"] = {
        charName = "Ryze",
        slot = _W,
        type = "targeted",
        displayName = "Rune Prison",
        range = 615,
    },
    ["Fling"] = {
        charName = "Singed",
        slot = _E,
        type = "targeted",
        displayName = "Fling",
        range = 125,
    },
    ["SkarnerImpale"] = {
        charName = "Skarner",
        slot = _R,
        type = "targeted",
        displayName = "Impale",
        range = 350,
    },
    ["TahmKenchW"] = {
        charName = "TahmKench",
        slot = _W,
        type = "targeted",
        displayName = "Devour",
        range = 250,
    },
    ["TristanaR"] = {
        charName = "Tristana",
        slot = _R,
        type = "targeted",
        displayName = "Buster Shot",
        range = 669,
    },
    ["TeemoQ"] = {
        charName = "Teemo",
        slot = _Q,
        type = "targeted",
        displayName = "Blinding Dart",
        range = 680,
    },
    ["VeigarPrimordialBurst"] = {
        charName = "Veigar",
        slot = _R,
        type = "targeted",
        displayName = "Primordial Burst",
        range = 650,
    },
    ["VolibearQ"] = {
        charName = "Volibear",
        displayName = "Thundering Smash",
        slot = _Q,
        type = "targeted",
        range = 200,
    },
    ["YoneQ3"] = {
        charName = "Yone",
        displayName = "Mortal Steel [Storm]",
        slot = _Q,
        type = "linear",
        speed = 1500,
        range = 1050,
        delay = 0.25,
        radius = 80,
        collision = false,
    },
    ["YoneR"] = {
        charName = "Yone",
        displayName = "Fate Sealed",
        slot = _R,
        type = "linear",
        speed = MathHuge,
        range = 1000,
        delay = 0.75,
        radius = 112.5,
        collision = false,
    },
}

local function LoadUnits()
    for i = 1, GameHeroCount() do
        local unit = GameHero(i);
        Units[i] = {
            unit = unit,
            spell = nil,
        }
        if unit.team ~= myHero.team then
            TableInsert(Enemies, unit)
        elseif unit.team == myHero.team and unit ~= myHero then
            TableInsert(Allies, unit)
        end
    end
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret and turret.isEnemy then
            TableInsert(Turrets, turret)
        end
    end
end

local function GetMode()
    if _G.SDK then
        return _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo" or
            _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass" or
            _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "LaneClear" or
            _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] and "JungleClear" or
            _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] and "LastHit" or
            _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] and "Flee" or nil
    elseif _G.PremiumOrbwalker then
        return _G.PremiumOrbwalker:GetMode()
    else
        return GOS.GetMode()
    end
end

local function IsReady(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and
        myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end

local function ValidTarget(target, range)
    range = range and range or MathHuge
    return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

local function GetDistance(p1, p2)
    return sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2) + pow((p2.z - p1.z), 2))
end

local function GetDistance2D(p1, p2)
    return sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2))
end

local function GetDistanceSqr(pos1, pos2)
    local pos2 = pos2 or myHero.pos
    local dx = pos1.x - pos2.x
    local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
    return dx * dx + dz * dz
end

local function GetTarget(range)
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
    EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(EnemyHeroes, Hero)
        end
    end
    return EnemyHeroes
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

local function IsFacing(unit)
    local V = Vector((unit.pos - myHero.pos))
    local D = Vector(unit.dir)
    local Angle = 180 - math.deg(math.acos(V * D / (V:Len() * D:Len())))
    if math.abs(Angle) < 80 then
        return true
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

local function HasBuff(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then
            return true
        end
    end
    return false
end

local function IsInRange(p1, p2, range)
    p2 = p2 or myHero
    p1 = p1.pos or p1
    p2 = p2.pos or p2
    local dx = p1.x - p2.x
    local dy = (p1.z or p1.y) - (p2.z or p2.y)
    return dx * dx + dy * dy <= range * range
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and
            unit.health > 0) then
        return true;
    end
    return false;
end

local function GetEnemyCount(range, unit)
    local count = 0
    for i, hero in ipairs(GetEnemyHeroes()) do
        local Range = range * range
        if unit ~= hero and GetDistanceSqr(unit, hero.pos) < Range and IsValid(hero) then
            count = count + 1
        end
    end
    return count
end

class "Urgot"

local Kraken = false
local KrakenStacks = 0

local AARange
local EAARange
local EMouseSpot
local WasAttacking

local Purge
local WTimer
local RRecast

local Flash
local FlashSpell
local PrimedFlashE = nil
local PrimedFlashETime = Game.Timer()

local CastingQ
local CastingW
local CastingE
local CastingR

local CastedQ = false
local CastedW = false
local CastedE = false
local CastedR = false
local LastSpellCasted

local TickQ = false
local TickW = false
local TickE = false
local TickR = false

local Item_HK = {}

function Urgot:__init()
    DelayAction(function()
        self:LoadMenu()
        self:LoadSpells()

        self.Detected = {}
        self.levelUP = false
        Callback.Add("Tick", function()
            self:Tick()
        end)
        Callback.Add("Draw", function()
            self:Draw()
        end)
        -- Callback.Add("Tick", OnProcessSpell)
        Callback.Add("Load", function()
            local GG_Target = _G.SDK.TargetSelector
            local GG_Orbwalker = _G.SDK.Orbwalker
            local GG_Buff = _G.SDK.BuffManager
            local GG_Damage = _G.SDK.Damage
            local GG_Spell = _G.SDK.Spell
            local GG_Object = _G.SDK.ObjectManager
            local GG_Attack = _G.SDK.Attack
            local GG_Data = _G.SDK.Data
            local GG_Cursor = _G.SDK.Cursor
            GG_Orbwalker:CanAttackEvent(Champion.CanAttackCb)
            GG_Orbwalker:CanMoveEvent(Champion.CanMoveCb)

            if Champion.OnPreAttack then
                GG_Orbwalker:OnPreAttack(Champion.OnPreAttack)
            end
            if Champion.OnAttack then
                GG_Orbwalker:OnAttack(Champion.OnAttack)
            end
            if Champion.OnPostAttack then
                GG_Orbwalker:OnPostAttack(Champion.OnPostAttack)
            end
            if Champion.OnPostAttackTick then
                GG_Orbwalker:OnPostAttackTick(Champion.OnPostAttackTick)
            end
            if Champion.OnTick then
                table.insert(_G.SDK.OnTick, function()
                    Champion:PreTick()
                    Champion:OnTick()
                end)
            end
            if Champion.OnDraw then
                table.insert(_G.SDK.OnDraw, function()
                    Champion:OnDraw()
                end)
            end
            if Champion.OnWndMsg then
                table.insert(_G.SDK.OnWndMsg, function(msg, wParam)
                    Champion:OnWndMsg(msg, wParam)
                end)
            end
        end)

        if DrawInfo then
            DrawInfo = false
        end
        LoadUnits()
    end, math.max(0.07, 15 - GameTimer()))
end

--[[ --For OnProcessSpell
local units = {}

for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    units[i] = {unit = unit, spell = nil}
end

function Urgot:OnProcessSpell()
    --Something better? Pred?
    for i = 1, #units do
        local unit = units[i].unit
        local last = units[i].spell
        local spell = unit.activeSpell
        if spell and last ~= (spell.name .. spell.startTime) and unit.isChanneling then
            units[i].spell = spell.name .. spell.startTime
            --
            --print(unit)
            --print(spell.name)
            --print(spell.placementPos)
            --print(spell.range)
            --print(spell.startPos)
            local startPos = Vector(unit.activeSpell.startPos)
            local placementPos = Vector(unit.activeSpell.placementPos)
            local unitPos = Vector(unit.pos)
            --local sRange = self.SpellsE[unit.activeSpell.name].range
            local sRange = spell.range
            local endPos = self:CalculateEndPos(startPos, placementPos, unitPos, sRange)
            --print(endPos)
            Draw.Circle(endPos, 20, 10, Draw.Color(0xFFFFFFFF))
            --Draw.Text(spell.name, 17, endPos.x, endPos.y, Draw.Color(0xFFFF0000))
            --Draw.Circle(GameObject.pos, GameObject.boundingRadius, 10, Draw.Color(255, 255, 255, 255))
            --Draw.Text(GameObject.name, 17, GameObject.pos2D.x - 45, GameObject.pos2D.y + 10, Draw.Color(0xFF32CD32))
            self.Spellx = spell
            return spell
        --return unit, spell
        end
    end
--return nil, nil
end
 ]]

function Urgot:CalculateEndPos(startPos, placementPos, unitPos, range)
    if range > 0 then
        if GetDistance(unitPos, placementPos) > range then
            local endPos = startPos - Vector(startPos - placementPos):Normalized() * range
            return endPos
        else
            local endPos = placementPos
            return endPos
        end
    else
        local endPos = unitPos
        return endPos
    end
end

-- Menu
local charName = myHero.charName
local url = "https://raw.githubusercontent.com/Impulsx/LoL-Icons/master/"
local CharIcon = {
    url .. charName .. ".png",
}
local HeroSpirites = {
    url .. charName .. "Q.png",
    url .. charName .. "W.png",
    url .. charName .. "E.png",
    url .. charName .. "R.png",
    url .. charName .. "R2.png",
}

local HeroIcon = CharIcon[1] -- "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/Urgot.png"
local IgniteIcon = url .. "Ignite.png"
local QIcon = HeroSpirites[1]
local WIcon = HeroSpirites[2]
local EIcon = HeroSpirites[3]
local RIcon = HeroSpirites[4]
local R2Icon = HeroSpirites[5]

function Urgot:LoadMenu()
    -- Menu
    self.UrgotMenu = MenuElement({
        type = MENU,
        id = "Urgot",
        name = "Impuls's Urgod",
        leftIcon = HeroIcon,
    })
    -- Harass
    self.UrgotMenu:MenuElement({
        id = "Harass",
        name = "Harass",
        type = MENU,
    })
    self.UrgotMenu.Harass:MenuElement({
        id = "UseQ",
        name = "Use Q",
        value = true,
        leftIcon = QIcon,
    })
    self.UrgotMenu.Harass:MenuElement({
        id = "UseW",
        name = "Use W",
        value = true,
        leftIcon = WIcon,
    })
    -- self.UrgotMenu.Harass:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = EIcon})

    -- Combo
    self.UrgotMenu:MenuElement({
        id = "Combo",
        name = "Combo",
        type = MENU,
    })
    self.UrgotMenu.Combo:MenuElement({
        id = "UseQ",
        name = "Use Q",
        value = true,
        leftIcon = QIcon,
    })
    self.UrgotMenu.Combo:MenuElement({
        id = "UseW",
        name = "Use W",
        value = true,
        leftIcon = WIcon,
    })
    self.UrgotMenu.Combo:MenuElement({
        id = "UseE",
        name = "Use E",
        value = true,
        leftIcon = EIcon,
    })
    self.UrgotMenu.Combo:MenuElement({
        id = "UseR",
        name = "Use R is enemy killable",
        value = true,
        leftIcon = RIcon,
    })
    -- self.UrgotMenu.Combo:MenuElement({id = "UseFlashR", name = "Use Flash R2 FEAR", value = true, leftIcon = R2Icon})
    -- self.UrgotMenu.Combo:MenuElement({id = "LvL", name = "Flash R2 FEAR > # Enemys", value = 2, min = 1, max = 5, step = 1})

    -- Farm
    self.UrgotMenu:MenuElement({
        id = "Farm",
        name = "Farm/Clear",
        type = MENU,
    })
    self.UrgotMenu.Farm:MenuElement({
        id = "UseQ",
        name = "Use Q",
        value = true,
        leftIcon = QIcon,
    })
    self.UrgotMenu.Farm:MenuElement({
        id = "UseQmin",
        name = "Min Minions for [Q]",
        value = 3,
        min = 1,
        max = 7,
        step = 1,
    })
    self.UrgotMenu.Farm:MenuElement({
        id = "UseW",
        name = "Use W",
        value = true,
        leftIcon = WIcon,
    })
    self.UrgotMenu.Farm:MenuElement({
        id = "UseWmin",
        name = "Min Minions for [Q]",
        value = 3,
        min = 1,
        max = 7,
        step = 1,
    })
    self.UrgotMenu.Farm:MenuElement({
        id = "UseE",
        name = "Use E",
        value = false,
        leftIcon = EIcon,
    })
    self.UrgotMenu.Farm:MenuElement({
        type = MENU,
        id = "JClear",
        name = "Jungle Clear",
    })
    self.UrgotMenu.Farm.JClear:MenuElement({
        id = "UseQ",
        name = "Use Q",
        value = true,
        leftIcon = QIcon,
    })
    self.UrgotMenu.Farm.JClear:MenuElement({
        id = "UseQmin",
        name = "Min Minions for [Q]",
        value = 3,
        min = 1,
        max = 7,
        step = 1,
    })
    self.UrgotMenu.Farm.JClear:MenuElement({
        id = "UseW",
        name = "Use W",
        value = true,
        leftIcon = WIcon,
    })
    self.UrgotMenu.Farm.JClear:MenuElement({
        id = "UseE",
        name = "Use E",
        value = false,
        leftIcon = EIcon,
    })

    -- KillSteal
    self.UrgotMenu:MenuElement({
        id = "KillSteal",
        name = "KillSteal",
        type = MENU,
    })
    self.UrgotMenu.KillSteal:MenuElement({
        id = "UseIgnite",
        name = "Use Ignite",
        value = false,
        leftIcon = IgniteIcon,
    })
    self.UrgotMenu.KillSteal:MenuElement({
        id = "UseQ",
        name = "Use Q",
        value = false,
        leftIcon = QIcon,
    })
    self.UrgotMenu.KillSteal:MenuElement({
        id = "UseW",
        name = "Use W",
        value = false,
        leftIcon = WIcon,
    })
    self.UrgotMenu.KillSteal:MenuElement({
        id = "UseE",
        name = "Use E",
        value = false,
        leftIcon = EIcon,
    })
    self.UrgotMenu.KillSteal:MenuElement({
        id = "UseR",
        name = "Use R",
        value = false,
        leftIcon = RIcon,
    })

    -- AutoLevel
    self.UrgotMenu:MenuElement({
        type = MENU,
        id = "AutoLevel",
        name = myHero.charName .. " AutoLevel Spells",
    })
    self.UrgotMenu.AutoLevel:MenuElement({
        id = "on",
        name = "Enabled",
        value = true,
    })
    self.UrgotMenu.AutoLevel:MenuElement({
        id = "LvL",
        name = "AutoLevel start -->",
        value = 4,
        min = 1,
        max = 6,
        step = 1,
    })
    self.UrgotMenu.AutoLevel:MenuElement({
        id = "delay",
        name = "Delay for Level up",
        value = 2,
        min = 0,
        max = 10,
        step = 0.5,
        identifier = "sec",
    })
    self.UrgotMenu.AutoLevel:MenuElement({
        id = "Order",
        name = "Skill Order",
        value = 5,
        drop = {
            "QWE",
            "WEQ",
            "EQW",
            "EWQ",
            "WQE",
            "QEW",
        },
    })

    -- Escape
    self.UrgotMenu:MenuElement({
        id = "Escape",
        name = "Escape",
        type = MENU,
    })
    self.UrgotMenu.Escape:MenuElement({
        id = "UseE",
        name = "Use E",
        value = true,
    })

    -- Kitehelper
    self.UrgotMenu:MenuElement({
        id = "OrbMode",
        name = "Orbwalker",
        type = MENU,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "UseKiteHelperWalk",
        name = "Kite Helper: Movement Assist",
        value = false,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "UseKiteHelperWalkInfo",
        name = "Assist Movement To Kite Enemies",
        type = SPACE,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperMouseDistance",
        name = "Mouse Range From Target",
        value = 50,
        min = 0,
        max = 1500,
        step = 50,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperMouseDistanceInfo",
        name = "Max Mouse Distance From Target To Kite",
        type = SPACE,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperRange",
        name = "Kite Distance Adjustment",
        value = 0,
        min = -500,
        max = 500,
        step = 10,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperRangeInfo",
        name = "Adjust the Kiting Distance By This Much",
        type = SPACE,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperRangeFacing",
        name = "Kite Distance Adjustment (Fleeing)",
        value = -120,
        min = -500,
        max = 500,
        step = 10,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperRangeFacingInfo",
        name = "Adjust the Kiting Distance Against A Fleeing Target",
        type = SPACE,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperRangeE1Info",
        name = "--------------------------------------------",
        type = SPACE,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperRangeE2Info",
        name = "Kiting Range Effects E's Location In Combo",
        type = SPACE,
        leftIcon = EIcon,
    })
    self.UrgotMenu.OrbMode:MenuElement({
        id = "KiteHelperRangeE3Info",
        name = "--------------------------------------------",
        type = SPACE,
    })

    -- Prediction
    self.UrgotMenu:MenuElement({
        type = MENU,
        id = "Pred",
        name = "Prediction Mode",
    })
    self.UrgotMenu.Pred:MenuElement({
        name = " ",
        drop = {
            "After change Prediction Type press 2xF6",
        },
    })
    self.UrgotMenu.Pred:MenuElement({
        id = "Change",
        name = "Change Prediction Type",
        value = 3,
        drop = {
            "Premium Prediction",
            "GGPrediction",
            "KillerLib",
        },
    })
    self:Pred()
    -- self.UrgotMenu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
    -- self.UrgotMenu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
    -- self.UrgotMenu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
    -- self.UrgotMenu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})

    -- Drawings
    self.UrgotMenu:MenuElement({
        id = "Drawings",
        name = "Drawings",
        type = MENU,
    })
    self.UrgotMenu.Drawings:MenuElement({
        id = "DrawQ",
        name = "Draw Q Range",
        value = true,
    })
    self.UrgotMenu.Drawings:MenuElement({
        id = "DrawW",
        name = "Draw W Range",
        value = false,
    })
    self.UrgotMenu.Drawings:MenuElement({
        id = "DrawE",
        name = "Draw E Range",
        value = true,
    })
    self.UrgotMenu.Drawings:MenuElement({
        id = "DrawR",
        name = "Draw R Range",
        value = true,
    })
    self.UrgotMenu.Drawings:MenuElement({
        id = "DrawAA",
        name = "Draw Killable AAs",
        value = false,
    })
    self.UrgotMenu.Drawings:MenuElement({
        id = "DrawKS",
        name = "Draw Killable Skills",
        value = true,
    })
    self.UrgotMenu.Drawings:MenuElement({
        id = "DrawJng",
        name = "Draw Jungler Info",
        value = true,
    })

    -- Version
    self.UrgotMenu:MenuElement({
        id = "blank",
        type = SPACE,
        name = "",
    })
    self.UrgotMenu:MenuElement({
        id = "blank",
        type = SPACE,
        name = "Script Ver: " .. version .. " by " .. author .. "",
    })
end

function Urgot:Pred()
    if self.UrgotMenu.Pred.Change:Value() == 1 then -- Prem
        self.UrgotMenu.Pred:MenuElement({
            id = "PredQ",
            name = "Hitchance[Q]",
            value = 1,
            drop = {
                "High",
                "VeryHigh",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredW",
            name = "Hitchance[W]",
            value = 1,
            drop = {
                "High",
                "VeryHigh",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredE",
            name = "Hitchance[E]",
            value = 1,
            drop = {
                "High",
                "VeryHigh",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredR",
            name = "Hitchance[R]",
            value = 1,
            drop = {
                "High",
                "VeryHigh",
                "Immobile",
            },
        })
    elseif self.UrgotMenu.Pred.Change:Value() == 2 then -- GG
        self.UrgotMenu.Pred:MenuElement({
            id = "PredQ",
            name = "Hitchance[Q]",
            value = 1,
            drop = {
                "Normal",
                "High",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredW",
            name = "Hitchance[W]",
            value = 1,
            drop = {
                "Normal",
                "High",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredE",
            name = "Hitchance[E]",
            value = 1,
            drop = {
                "Normal",
                "High",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredR",
            name = "Hitchance[R]",
            value = 1,
            drop = {
                "Normal",
                "High",
                "Immobile",
            },
        })
    elseif self.UrgotMenu.Pred.Change:Value() == 3 then -- Killer
        self.UrgotMenu.Pred:MenuElement({
            id = "PredQ",
            name = "Hitchance[Q]",
            value = 1,
            drop = {
                "Normal",
                "High",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredW",
            name = "Hitchance[W]",
            value = 1,
            drop = {
                "Normal",
                "High",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredE",
            name = "Hitchance[E]",
            value = 1,
            drop = {
                "Normal",
                "High",
                "Immobile",
            },
        })
        self.UrgotMenu.Pred:MenuElement({
            id = "PredR",
            name = "Hitchance[R]",
            value = 1,
            drop = {
                "Normal",
                "High",
                "Immobile",
            },
        })
    end
end

function Urgot:ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance) or menuValue == 2 and
        _G.PremiumPrediction.HitChance.VeryHigh(hitChance) or
        _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

function Urgot:LoadSpells()
    if not PredLoaded then
        if self.UrgotMenu.Pred.Change:Value() == 1 then
            require("PremiumPrediction")
            PredLoaded = true
        end
        if self.UrgotMenu.Pred.Change:Value() == 2 then
            require("GGPrediction")
            PredLoaded = true
        end
        if self.UrgotMenu.Pred.Change:Value() == 3 then
            require "KillerAIO\\KillerLib"
            PredLoaded = true
        end
    end
    if self.UrgotMenu.Pred.Change:Value() == 1 then
        self.QspellData = {
            speed = UrgotQ.speed,
            range = UrgotQ.range,
            delay = UrgotQ.delay,
            radius = UrgotQ.radius,
            type = "circular",
        }
        self.WspellData = {
            speed = UrgotW.speed,
            range = UrgotW.range,
            delay = UrgotW.delay,
            radius = UrgotW.radius,
            type = "circular",
        }
        self.EspellData = {
            speed = UrgotE.speed,
            range = UrgotE.range,
            delay = UrgotE.delay,
            radius = UrgotE.radius,
            type = "linear",
        }
        self.RspellData = {
            speed = UrgotR.speed,
            range = UrgotR.range,
            delay = UrgotR.delay,
            radius = UrgotR.radius,
            type = "linear",
        }
    end
    if self.UrgotMenu.Pred.Change:Value() == 2 then
        self.QPrediction = GGPrediction:SpellPrediction({
            Delay = UrgotQ.delay,
            Radius = UrgotQ.radius,
            Range = UrgotQ.range,
            Speed = UrgotQ.speed,
            Collision = false,
            Type = GGPrediction.SPELLTYPE_CIRCLE,
        })
        self.WPrediction = GGPrediction:SpellPrediction({
            Delay = UrgotW.delay,
            Radius = UrgotW.radius,
            Range = UrgotW.range,
            Speed = UrgotW.speed,
            Collision = false,
            Type = GGPrediction.SPELLTYPE_CIRCLE,
        })
        self.EPrediction = GGPrediction:SpellPrediction({
            Delay = UrgotE.delay,
            Radius = UrgotE.radius,
            Range = UrgotE.range,
            Speed = UrgotE.speed,
            Collision = UrgotE.collision,
            CollisionTypes = {
                GGPrediction.COLLISION_ENEMYHERO,
            },
            Type = GGPrediction.SPELLTYPE_LINE,
        })
        self.RPrediction = GGPrediction:SpellPrediction({
            Delay = UrgotR.delay,
            Radius = UrgotR.radius,
            Range = UrgotR.range,
            Speed = UrgotR.speed,
            Collision = UrgotR.collision,
            CollisionTypes = {
                GGPrediction.COLLISION_ENEMYHERO,
            },
            Type = GGPrediction.SPELLTYPE_LINE,
        })
    end
    if self.UrgotMenu.Pred.Change:Value() == 3 then
        self.QspellData = Q
        self.WspellData = W
        self.EspellData = E
        self.RspellData = R
    end
    --[[     Champion = {

		CanAttackCb = function()
			if Game.CanUseSpell(_W) == 0 and Game.Timer() < GG_Spell.WTimer + 0.33 then
				return
			end
			return GG_Spell:CanTakeAction({ q = 0.33, w = 0, e = 0.33, r = 0.33 })
		end,

		CanMoveCb = function()
			return GG_Spell:CanTakeAction({ q = 0.23, w = 0, e = 0.23, r = 0.23 })
		end,

		OnPreAttack = function(args)
			Champion:PreTick()
			if Game.CanUseSpell(_W) ~= 0 then
				return
			end
			if not ((Champion.IsCombo and Menu.w_combo:Value()) or (Champion.IsHarass and Menu.w_harass:Value())) then
				return
			end
			local enemies = GG_Object:GetEnemyHeroes(
				610 + (20 * myHero:GetSpellData(_W).level) + myHero.boundingRadius - 35,
				true,
				true,
				true
			)
			if #enemies > 0 then
				Utils:Cast(HK_W)
				LastW = GetTickCount()
			end
		end,

		OnPostAttackTick = function(PostAttackTimer)
			Champion:PreTick()
			Champion:QLogic()
			Champion:ELogic()
			Champion:RLogic()
		end,
	} ]]
end

function Urgot:ProcessSpells()
    CastingQ = myHero.activeSpell.name == "UrgotQ"
    CastingW = myHero.activeSpell.name == "UrgotW" -- and "UrgotWCancel"
    CastingE = myHero.activeSpell.name == "UrgotE"
    CastingR = myHero.activeSpell.name == "UrgotR" -- and "UrgotRRecast"

    ---EBuff = HasBuff(myHero, "")
    ---EActive = HasBuff(myHero, "")
    ---RActive = HasBuff(myHero, "")

    Kraken = HasBuff(myHero, "6672buff")

    if myHero:GetSpellData(SUMMONER_1).name:find("Flash") then
        Flash = SUMMONER_1
        FlashSpell = HK_SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("Flash") then
        Flash = SUMMONER_2
        FlashSpell = HK_SUMMONER_2
    else
        Flash = nil
    end

    if Kraken == false then
        KrakenStacks = 0
    end

    Purge = HasBuff(myHero, "UrgotW") or (myHero:GetSpellData(_W).name == "UrgotWCancel")
    RRecast = (myHero:GetSpellData(_R).name == "UrgotRRecast")

    if myHero:GetSpellData(_Q).currentCd == 0 then
        CastedQ = false
    else
        if CastedQ == false then
            TickQ = true
            LastSpellCasted = "Q"
        end
        CastedQ = true
    end
    if myHero:GetSpellData(_W).currentCd == 0 then
        CastedW = false
    else
        if CastedW == false then
            TickW = true
            LastSpellCasted = "W"
        end
        CastedW = true
    end
    if myHero:GetSpellData(_E).currentCd == 0 then
        CastedE = false
    else
        if CastedE == false then
            TickE = true
            LastSpellCasted = "E"
            if PrimedFlashE ~= nil and Flash and IsReady(Flash) then
                -- Control.CastSpell(FlashSpell, PrimedFlashE)
                PrimedFlashE = nil
            end
            PrimedE = false
        end
        CastedE = true
    end
    if myHero:GetSpellData(_R).currentCd == 0 then
        CastedR = false
    else
        if CastedR == false then
            TickR = true
            LastSpellCasted = "R"
        end
        CastedR = true
    end
end

function Urgot:ProcessItems()
    Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
end

function Urgot:GetAllDamage(unit, burst, mode)
    local Qdmg = getdmg("Q", unit, myHero, 1, myHero:GetSpellData(_Q).level)
    local Wdmg = getdmg("W", unit, myHero, 1, myHero:GetSpellData(_W).level)
    local Edmg = getdmg("E", unit, myHero, 1, myHero:GetSpellData(_E).level)
    local Rdmg = getdmg("R", unit, myHero, 1, myHero:GetSpellData(_R).level)
    local AAdmg = getdmg("AA", unit, myHero)

    if Kraken and KrakenStacks == 2 then
        AAdmg = AAdmg + 60 + (0.45 * myHero.bonusDamage)
        -- PrintChat(60 + (0.45*myHero.bonusDamage))
    end

    local UnitHealth = unit.health + unit.shieldAD
    local BurstDmg = Qdmg + Rdmg + Edmg + Wdmg + (AAdmg * 3)
    local QCheck = UnitHealth - (Qdmg) < 0
    local WCheck = UnitHealth - (Wdmg) < 0
    local ECheck = UnitHealth - (Edmg) < 0
    local RCheck = UnitHealth - (Rdmg) < 0
    local QWCheck = UnitHealth - (Qdmg + Wdmg) < 0
    local QECheck = UnitHealth - (Qdmg + Edmg) < 0
    local QRCheck = UnitHealth - (Qdmg + Rdmg) < 0
    local WECheck = UnitHealth - (Wdmg + Edmg) < 0
    local WRCheck = UnitHealth - (Wdmg + Rdmg) < 0
    local ERCheck = UnitHealth - (Edmg + Rdmg) < 0
    local QWECheck = UnitHealth - (Qdmg + Wdmg + Edmg) < 0
    local QERCheck = UnitHealth - (Qdmg + Edmg + Rdmg) < 0

    local TotalDmg = 0
    local PossibleDmg = 0
    local SpellsReady = 0
    if self:CanUse(_Q, "Force") then
        TotalDmg = TotalDmg + Qdmg
        SpellsReady = SpellsReady + 1
    end
    if self:CanUse(_W, "Force") then
        TotalDmg = TotalDmg + Wdmg
        SpellsReady = SpellsReady + 1
    end
    if self:CanUse(_E, "Force") then
        TotalDmg = TotalDmg + Edmg
        SpellsReady = SpellsReady + 1
    end
    if self:CanUse(_R, "Force") then
        TotalDmg = TotalDmg + Rdmg
        SpellsReady = SpellsReady + 1
    end
    TotalDmg = TotalDmg + AAdmg
    PossibleDmg = Qdmg + Wdmg + Edmg + Rdmg + AAdmg

    local Damages = {
        TotalDamage = TotalDmg,
        PossibleDamage = PossibleDmg,
        SpellsReady = SpellsReady,
        QKills = QCheck,
        WKills = WCheck,
        EKills = ECheck,
        RKills = RCheck,
        QWKills = QWCheck,
        QEKills = QECheck,
        QRKills = QRCheck,
        WEKills = WECheck,
        WRKills = WRCheck,
        ERKills = ERCheck,
        QWEKills = QWECheck,
        QERKills = QERCheck,
        BurstDamage = BurstDmg,
        QDamage = Qdmg,
        EDamage = Edmg,
        RDamage = Rdmg,
        AADamage = AAdmg,
    }
    return Damages
end

function Urgot:CanUse(spell, mode)
    if mode == nil then
        mode = GetMode()
    end
    -- PrintChat(GetMode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Combo.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Harass.UseQ:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.KillSteal.UseQ:Value() then
            return true
        end
        if mode == "LastHit" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Farm.UseQ:Value() then
            return true
        end
        if mode == "LaneClear" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Farm.UseQ:Value() then
            return true
        end
        if mode == "JungleClear" and IsReady(spell) and self:CastingChecks() and
            self.UrgotMenu.Farm.JClear.UseQ:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Combo.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Harass.UseW:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.KillSteal.UseW:Value() then
            return true
        end
        if mode == "LastHit" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Farm.UseW:Value() then
            return true
        end
        if mode == "LaneClear" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Farm.UseW:Value() then
            return true
        end
        if mode == "JungleClear" and IsReady(spell) and self:CastingChecks() and
            self.UrgotMenu.Farm.JClear.UseW:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Combo.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Harass.UseE:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.KillSteal.UseE:Value() then
            return true
        end
        if mode == "LastHit" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Farm.UseE:Value() then
            return true
        end
        if mode == "LaneClear" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Farm.UseE:Value() then
            return true
        end
        if mode == "JungleClear" and IsReady(spell) and self:CastingChecks() and
            self.UrgotMenu.Farm.JClear.UseE:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _R then
        if mode == "Combo" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Combo.UseR:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.Harass.UseR:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self:CastingChecks() and self.UrgotMenu.KillSteal.UseR:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    end
    return false
end

function Urgot:KiteHelper(unit)
    local EAARangel = _G.SDK.Data:GetAutoAttackRange(unit)
    local MoveSpot = nil
    local RangeDif = AARange - EAARangel
    local ExtraRangeDist = RangeDif + self.UrgotMenu.OrbMode.KiteHelperRange:Value()
    local ExtraRangeChaseDist = RangeDif + self.UrgotMenu.OrbMode.KiteHelperRangeFacing:Value()

    local ScanDirection = Vector((myHero.pos - mousePos):Normalized())
    local ScanDistance = GetDistance(myHero.pos, unit.pos) * 0.8
    local ScanSpot = myHero.pos - ScanDirection * ScanDistance

    local MouseDirection = Vector((unit.pos - ScanSpot):Normalized())
    local MouseSpotDistance = EAARangel + ExtraRangeDist
    if not IsFacing(unit) then
        MouseSpotDistance = EAARangel + ExtraRangeChaseDist
    end
    if MouseSpotDistance > AARange then
        MouseSpotDistance = AARange
    end

    local MouseSpot = unit.pos - MouseDirection * (MouseSpotDistance)
    local EMouseSpotDirection = Vector((myHero.pos - MouseSpot):Normalized())
    local EmouseSpotDistance = GetDistance(myHero.pos, MouseSpot)
    if EmouseSpotDistance > 400 then
        EmouseSpotDistance = 400
    end
    local EMouseSpoty = myHero.pos - EMouseSpotDirection * EmouseSpotDistance
    MoveSpot = MouseSpot

    if MoveSpot then
        if GetDistance(myHero.pos, MoveSpot) < 50 then
            _G.SDK.Orbwalker.ForceMovement = nil
        elseif self.UrgotMenu.OrbMode.UseKiteHelperWalk:Value() and GetDistance(myHero.pos, unit.pos) <= AARange - 50 and
            (GetMode() == "Combo" or GetMode() == "Harass") then
            _G.SDK.Orbwalker.ForceMovement = MoveSpot
        else
            _G.SDK.Orbwalker.ForceMovement = nil
        end
    end
    return EMouseSpoty
end

function Urgot:CastingChecks()
    if not CastingQ and not CastingW and not CastingE and not CastingR and _G.SDK.Cursor.Step == 0 and
        _G.SDK.Spell:CanTakeAction({
            q = 0.25,
            w = 0.00,
            e = 0.71,
            r = 0.50,
        }) and not _G.SDK.Orbwalker:IsAutoAttacking() then
        return true
    else
        return false
    end
end

function Urgot:CastingChecksQ()
    if not CastingQ then
        return true
    else
        return false
    end
end

function Urgot:CastingChecksW()
    if not CastingW then
        return true
    else
        return false
    end
end

function Urgot:CastingChecksE()
    if not CastingE then
        return true
    else
        return false
    end
end

function Urgot:CastingChecksR()
    if not CastingR then
        return true
    else
        return false
    end
end

function Urgot:Tick()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling(myHero) == true or
        (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) then
        return
    end

    local target = GetTarget(UrgotR.range)

    if target and ValidTarget(target) then
        self.Damage = self:GetAllDamage(target)
    end

    if _G.SDK.Attack:IsActive() then
        WasAttacking = true
    else
        if WasAttacking == true then
            KrakenStacks = KrakenStacks + 1
        end
        WasAttacking = false
    end

    AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    if target then
        EAARange = _G.SDK.Data:GetAutoAttackRange(target)
    end

    if target and ValidTarget(target) then
        -- PrintChat(target.pos:To2D())
        -- PrintChat(mousePos:To2D())
        EMouseSpot = self:KiteHelper(target)
    else
        _G.SDK.Orbwalker.ForceMovement = nil
    end

    self:ProcessSpells()
    self:ProcessItems()

    self:KillSteal(target)

    if Game.IsOnTop() or Game.IsChatOpen() == true or GetMode() ~= nil then
        self:AutoLevelStart()
    end

    if GetMode() == "Combo" then
        self:Combo(target)
    end
    if GetMode() == "Harass" then
        self:Harass(target)
    end
    if GetMode() == "LastHit" then
        self:LastHit()
    end
    if GetMode() == "LaneClear" then
        self:LaneClear()
    end
    if GetMode() == "JungleClear" then
        self:JungleClear()
    end
    if GetMode() == "Flee" then
        self:Escape()
    end
    if EnemyLoaded == false then
        local CountEnemy = 0
        for i, enemy in pairs(GetEnemyHeroes()) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            EnemyLoaded = true
            -- PrintChat("Enemy Loaded")
        end
    end
end

function Urgot:GetSkillOrder()
    local Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
    if self.UrgotMenu.AutoLevel.Order:Value() == 1 then
        Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
    elseif self.UrgotMenu.AutoLevel.Order:Value() == 2 then
        Spell1, Spell2, Spell3 = HK_W, HK_E, HK_Q
    elseif self.UrgotMenu.AutoLevel.Order:Value() == 3 then
        Spell1, Spell2, Spell3 = HK_E, HK_Q, HK_W
    elseif self.UrgotMenu.AutoLevel.Order:Value() == 4 then
        Spell1, Spell2, Spell3 = HK_E, HK_W, HK_Q
    elseif self.UrgotMenu.AutoLevel.Order:Value() == 5 then
        Spell1, Spell2, Spell3 = HK_W, HK_Q, HK_E
    elseif self.UrgotMenu.AutoLevel.Order:Value() == 6 then
        Spell1, Spell2, Spell3 = HK_Q, HK_E, HK_W
    end
    return Spell1, Spell2, Spell3
end

function Urgot:AutoLevelStart()
    if self.UrgotMenu.AutoLevel.on:Value() and not self.levelUP then
        local actualLevel = myHero.levelData.lvl
        local levelPoints = myHero.levelData.lvlPts
        local Spell1, Spell2, Spell3 = self:GetSkillOrder()

        if (actualLevel == 18 and levelPoints == 0) or self.UrgotMenu.AutoLevel.LvL:Value() > actualLevel then
            return
        end

        if levelPoints > 0 then
            self.levelUP = true
            local Delay = self.UrgotMenu.AutoLevel.delay:Value()
            DelayAction(function()
                if actualLevel == 6 or actualLevel == 11 or actualLevel == 16 then
                    Control.KeyDown(HK_LUS)
                    Control.KeyDown(HK_R)
                    Control.KeyUp(HK_R)
                    Control.KeyUp(HK_LUS)
                elseif actualLevel == 1 or actualLevel == 4 or actualLevel == 5 or actualLevel == 7 or actualLevel == 9 then
                    Control.KeyDown(HK_LUS)
                    Control.KeyDown(Spell1)
                    Control.KeyUp(Spell1)
                    Control.KeyUp(HK_LUS)
                elseif actualLevel == 2 or actualLevel == 8 or actualLevel == 10 or actualLevel == 12 or actualLevel ==
                    13 then
                    Control.KeyDown(HK_LUS)
                    Control.KeyDown(Spell2)
                    Control.KeyUp(Spell2)
                    Control.KeyUp(HK_LUS)
                elseif actualLevel == 3 or actualLevel == 14 or actualLevel == 15 or actualLevel == 17 or actualLevel ==
                    18 then
                    Control.KeyDown(HK_LUS)
                    Control.KeyDown(Spell3)
                    Control.KeyUp(Spell3)
                    Control.KeyUp(HK_LUS)
                end
                DelayAction(function()
                    self.levelUP = false
                end, 0.25)
            end, Delay)
        end
    end
end

function Urgot:Draw()
    if myHero.dead then
        return
    end
    if self.UrgotMenu.Drawings.DrawQ:Value() and IsReady(_Q) then
        Draw.Circle(myHero.pos, UrgotQ.range, 1, Draw.Color(0xFF008080))
    end
    if self.UrgotMenu.Drawings.DrawW:Value() and IsReady(_W) then
        Draw.Circle(myHero.pos, UrgotW.range, 1, Draw.Color(0xFF400080))
    end
    if self.UrgotMenu.Drawings.DrawE:Value() and IsReady(_E) then
        Draw.Circle(myHero.pos, UrgotE.range, 1, Draw.Color(0xFF408000))
    end
    if self.UrgotMenu.Drawings.DrawR:Value() and IsReady(_R) then
        Draw.Circle(myHero.pos, UrgotR.range, 1, Draw.Color(0xFF800000))
    end

    for i, enemy in pairs(GetEnemyHeroes()) do
        if self.UrgotMenu.Drawings.DrawJng:Value() then
            if enemy:GetSpellData(SUMMONER_1).name == "SummonerSmite" or enemy:GetSpellData(SUMMONER_2).name ==
                "SummonerSmite" then
                Smite = true
            else
                Smite = false
            end
            if Smite then
                if enemy.alive then
                    if ValidTarget(enemy) then
                        if GetDistance(myHero.pos, enemy.pos) > 3000 then
                            Draw.Text("Jungler: Visible", 13, myHero.pos2D.x - 45, myHero.pos2D.y + 10,
                                Draw.Color(0xFF32CD32))
                        else
                            Draw.Text("Jungler: Near", 13, myHero.pos2D.x - 43, myHero.pos2D.y + 10,
                                Draw.Color(0xFFFF0000))
                        end
                    else
                        Draw.Text("Jungler: Invisible", 13, myHero.pos2D.x - 55, myHero.pos2D.y + 10,
                            Draw.Color(0xFFFFD700))
                    end
                else
                    Draw.Text("Jungler: Dead", 13, myHero.pos2D.x - 45, myHero.pos2D.y + 10, Draw.Color(0xFF32CD32))
                end
            end
        end
        if self.UrgotMenu.Drawings.DrawAA:Value() then
            if ValidTarget(enemy) then
                local AALeft = enemy.health / myHero.totalDamage -- add getdmg(AAdmg)
                Draw.Text("AA Left: " .. tostring(math.ceil(AALeft)), 13, enemy.pos2D.x - 38, enemy.pos2D.y + 10,
                    Draw.Color(0xFF00BFFF))
            end
        end
    end
end

function Urgot:Escape()
    -- run like a bitch
end

function Urgot:LaneClear()
    if self:CanUse(_Q, "LaneClear") then -- self:CanUse(spell, mode)
        -- PrintChat("LaneClear")
        local target = nil
        local BestHit = 0
        local CurrentCount = 0
        self.QEnemyMinions = _G.SDK.ObjectManager:GetEnemyMinions(UrgotQ.range)
        for i, unit in ipairs(self.QEnemyMinions) do
            -- local monster = unit[i]
            if unit.distance < UrgotQ.range then
                CurrentCount = 0
                local minionPos = unit.pos
                for j, unit2 in ipairs(self.QEnemyMinions) do
                    if minionPos:DistanceTo(unit2.pos) < UrgotQ.radius then
                        CurrentCount = CurrentCount + 1
                    end
                end
                if CurrentCount > BestHit then
                    BestHit = CurrentCount
                    target = unit
                end
            end
        end
        if target and BestHit >= (self.UrgotMenu.Farm.UseQmin:Value()) then
            ControlCastSpell(HK_Q, target.pos)
        end
        -- ControlCastSpell(HK_W)
    end
end

function Urgot:JungleClear()
    local monsters = _G.SDK.ObjectManager:GetMonsters(UrgotQ.range)

    for i = 1, #monsters do
        local monster = monsters[i]

        if ValidTarget(monster, UrgotQ.range) then
            for i = 1, #EliteMonsters do
                if monster.charName == EliteMonsters[i] then
                    ControlCastSpell(HK_Q, monster.pos)
                    -- ControlCastSpell(HK_W)
                elseif monster.charName == EliteMonsters[i] and monster.health < self.Damage.WDamage then
                    ControlCastSpell(HK_W)
                end
            end
        end
    end
end

function Urgot:LastHit()
    local Minion = _G.SDK.ObjectManager:GetEnemyMinions(UrgotQ.range)

    for i = 1, #Minion do
        local Minion = Minion[i]
        if ValidTarget(Minion, UrgotQ.range) then
            self.Damage = self:GetAllDamage(Minion)
            for i = 1, #EliteMonsters do
                if Minion.charName == EliteMonsters[i] and Minion.health < self.Damage.QDamage then
                    ControlCastSpell(HK_Q, Minion.pos)
                elseif Minion.charName == EliteMonsters[i] and Minion.health < self.Damage.WDamage then
                    ControlCastSpell(HK_W)
                end
            end
        end
    end
end

function Urgot:Harass(target)
    -- local target = GetTarget(UrgotQ.range)
    if Purge and GetEnemyCount((UrgotW.range + myHero.boundingRadius), myHero.pos) < 1 then -- and/or GameTimer() > WTimer + WDelay
        ControlCastSpell(HK_W)
        WTimer = 0
    end
    if IsReady(_W) then
        if self:CanUse(_W, "Harass") or CastingE then
            if ValidTarget(target, UrgotW.range) then
                self:CastW(target)
            end
        end
    end

    if IsReady(_Q) and not CastingE then
        if self:CanUse(_Q, "Harass") then
            if ValidTarget(target, UrgotQ.range) then
                self:CastQ(target)
            end
        end
    end

    if IsReady(_E) then
        if self:CanUse(_E, "Combo") then
            if ValidTarget(target, UrgotE.range) then
                self:CastE(target)
            end
        end
    end
end

function Urgot:KillSteal(target)
    if RRecast and GameCanUseSpell(_R) then
        ControlCastSpell(HK_R)
    end
    --[[    for i, enemy in pairs(GetEnemyHeroes()) do
            if self.UrgotMenu.KillSteal.UseIgnite:Value() then
                local IgniteDmg = (55 + 25 * myHero.levelData.lvl)
                if ValidTarget(enemy, 600) and enemy.health + enemy.shieldAD < IgniteDmg then
                    if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and IsReady(SUMMONER_1) then
                        ControlCastSpell(HK_SUMMONER_1, enemy)
                    elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and IsReady(SUMMONER_2) then
                        ControlCastSpell(HK_SUMMONER_2, enemy)
                    end
                end
            end
        end ]]
end

function Urgot:Combo(target)
    if Purge and GetEnemyCount((UrgotW.range + myHero.boundingRadius), myHero.pos) < 1 then -- and/or GameTimer() > WTimer + WDelay
        ControlCastSpell(HK_W)
        WTimer = 0
    end

    if IsReady(_E) then
        -- PrintChat("EQWR Combo Ready")
        if self:CanUse(_E, "Combo") then
            if ValidTarget(target, UrgotE.range) then
                self:CastE(target)
            end
        end

        if IsReady(_Q) and not CastingE then
            if self:CanUse(_Q, "Combo") then
                if ValidTarget(target, UrgotQ.range) then
                    self:CastQ(target)
                end
            end
        end

        if IsReady(_W) and not Purge then
            if self:CanUse(_W, "Combo") then
                if ValidTarget(target, UrgotW.range) or CastingE then
                    self:CastW(target)
                end
            end
        end

        if IsReady(_R) and not CastingE and not CastingQ then
            if self:CanUse(_R, "Combo") then
                if ValidTarget(target, UrgotR.range) and
                    (((target.health / target.maxHealth) <= 24 / 100) or
                        ((target.health - self.Damage.RDamage) / target.maxHealth) <= 24 / 100) then
                    self:CastR(target)
                end
            end
        end
    elseif not IsReady(_E) then
        -- PrintChat("QWR Combo Ready")
        if IsReady(_Q) and not CastingE then
            if self:CanUse(_Q, "Combo") then
                if ValidTarget(target, UrgotQ.range) then
                    self:CastQ(target)
                end
            end
        end

        if IsReady(_W) and not Purge then
            if self:CanUse(_W, "Combo") then
                if ValidTarget(target, UrgotW.range) then
                    self:CastW(target)
                end
            end
        end

        if IsReady(_R) and not CastingE and not CastingQ then
            if self:CanUse(_R, "Combo") then
                if ValidTarget(target, UrgotR.range) and
                    (((target.health / target.maxHealth) <= 24 / 100) or
                        ((target.health - self.Damage.RDamage) / target.maxHealth) <= 24 / 100) then
                    self:CastR(target)
                end
            end
        end
    else
        -- PrintChat("QR Combo Ready") --never get here
        if IsReady(_Q) and not CastingE and not CastingR then
            if self:CanUse(_Q, "Combo") then
                if ValidTarget(target, UrgotQ.range) then
                    self:CastQ(target)
                end
            end
        end

        if IsReady(_R) and not CastingE and not CastingQ then
            if self:CanUse(_R, "Combo") then
                if ValidTarget(target, UrgotR.range) and
                    (((target.health / target.maxHealth) <= 24 / 100) or
                        ((target.health - self.Damage.RDamage) / target.maxHealth) <= 24 / 100) then
                    self:CastR(target)
                end
            end
        end
    end
end

function Urgot:CastQ(target)
    if IsReady(_Q) then
        -- PrintChat("Casting Q")
        if self.UrgotMenu.Pred.Change:Value() == 1 then
            local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.QspellData)
            if pred.CastPos and self:ConvertToHitChance(self.UrgotMenu.Pred.PredQ:Value(), pred.HitChance) then
                ControlCastSpell(HK_Q, pred.CastPos)
            end
        end

        if self.UrgotMenu.Pred.Change:Value() == 2 then
            local pred = self.QPrediction
            pred:GetPrediction(target, myHero)
            if pred.CastPosition and pred:CanHit(self.UrgotMenu.Pred.PredQ:Value() + 1) then
                ControlCastSpell(HK_Q, pred.CastPosition)
            end
        end

        if self.UrgotMenu.Pred.Change:Value() == 3 then
            local args = {
                Hotkey = HK_Q,
                Target = target,
                SpellData = self.QspellData,
                ExtendedCheck = true,
                maxCollision = 0,
                CheckSplashCollision = true,
                SplashCollisionRadius = self.QspellData.Radius or 0,
                UseHeroCollision = false,
                CheckTerrain = false,
                TerrainCorrectionWeight = 0.8,
                collisionRadiusOverride = self.QspellData.Radius or 0,
                IgnoreUnkillable = self.IgnoreUnkillable ~= false,
                IgnoreSpellshields = false,
                IgnoreAAImmune = false,
                ValidCheck = false,
                GGPred = false,
                StrafePred = StrafePred ~= false,
                KillerPred = KillerPred ~= false,
                InterpolatedPred = false, -- A subset of KillerPred that will cast the spell at the exact path point the unit and spell will meet.,
                offscreenLinearSkillshots = false,
                ReturnPos = false,
            }
            local didCast = CastPredictedSpell(args)
            if (didCast) then
                LastSpellCasted = HK_Q
                return didCast
            end
        end
    end
end

function Urgot:CastW(target)
    if IsReady(_W) and not Purge then
        -- PrintChat("Casting W")
        if self.UrgotMenu.Pred.Change:Value() == 1 then
            local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.WspellData)
            if pred.CastPos and self:ConvertToHitChance(self.UrgotMenu.Pred.PredW:Value(), pred.HitChance) then
                ControlCastSpell(HK_W)
                WTimer = GameTimer()
            end
        end
        if self.UrgotMenu.Pred.Change:Value() == 2 then
            local pred = self.WPrediction
            pred:GetPrediction(target, myHero)
            if pred.CastPosition and pred:CanHit(self.UrgotMenu.Pred.PredW:Value() + 1) then
                ControlCastSpell(HK_W)
                WTimer = GameTimer()
            end
        end
        if self.UrgotMenu.Pred.Change:Value() == 3 then
            local args = {
                Hotkey = HK_W,
                Target = target,
                SpellData = self.WspellData,
                ExtendedCheck = true,
                maxCollision = 0,
                CheckSplashCollision = false,
                SplashCollisionRadius = 0,
                UseHeroCollision = false,
                CheckTerrain = false,
                TerrainCorrectionWeight = 0.8,
                collisionRadiusOverride = self.WspellData.Radius or 0,
                IgnoreUnkillable = self.IgnoreUnkillable ~= false,
                IgnoreSpellshields = true,
                IgnoreAAImmune = false,
                ValidCheck = false,
                GGPred = false,
                StrafePred = StrafePred ~= false,
                KillerPred = KillerPred ~= false,
                InterpolatedPred = false, -- A subset of KillerPred that will cast the spell at the exact path point the unit and spell will meet.,
                offscreenLinearSkillshots = false,
                ReturnPos = false,
            }
            local didCast = CastPredictedSpell(args)
            if (didCast) then
                WTimer = GameTimer()
                LastSpellCasted = HK_W
                return didCast
            end
        end
    end
end

function Urgot:CastE(target)
    if IsReady(_E) then
        -- PrintChat("Cast E Ready")
        if self.UrgotMenu.Pred.Change:Value() == 1 then
            local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.EspellData)
            if pred.CastPos and self:ConvertToHitChance(self.UrgotMenu.Pred.PredE:Value(), pred.HitChance) then
                ControlCastSpell(HK_E, pred.CastPos)
            end
        end
        if self.UrgotMenu.Pred.Change:Value() == 2 then
            local pred = self.EPrediction
            pred:GetPrediction(target, myHero)
            if pred.CastPosition and pred:CanHit(self.UrgotMenu.Pred.PredE:Value() + 1) then
                ControlCastSpell(HK_E, pred.CastPosition)
            end
        end
        if self.UrgotMenu.Pred.Change:Value() == 3 then
            local args = {
                Hotkey = HK_E,
                Target = target,
                SpellData = self.EspellData,
                ExtendedCheck = false,
                maxCollision = 0,             --
                CheckSplashCollision = false, --
                SplashCollisionRadius = 0,    --
                UseHeroCollision = false,     -- might play with these to not E into a full team xd
                CheckTerrain = true,
                TerrainCorrectionWeight = 0.8,
                collisionRadiusOverride = self.EspellData.Radius or 0,
                IgnoreUnkillable = true,
                IgnoreSpellshields = false,
                IgnoreAAImmune = true,
                ValidCheck = false,
                GGPred = false,
                StrafePred = StrafePred ~= false,
                KillerPred = KillerPred ~= false,
                InterpolatedPred = false, -- A subset of KillerPred that will cast the spell at the exact path point the unit and spell will meet.,
                offscreenLinearSkillshots = self.offscreenLinearSkillshots ~= false,
                ReturnPos = false,
            }
            local didCast = CastPredictedSpell(args) -- true for extended check maybe?
            if (didCast) then
                LastSpellCasted = HK_E
                return didCast
            end
        end
    end
end

function Urgot:CastR(target, minhitchance, mintargets)
    if IsReady(_R) then
        -- PrintChat("Casting R")
        if self.UrgotMenu.Pred.Change:Value() == 1 then
            local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.RspellData)
            if pred.CastPos and self:ConvertToHitChance(self.UrgotMenu.Pred.PredR:Value(), pred.HitChance) then
                ControlCastSpell(HK_R, pred.CastPos)
            end
        end
        if self.UrgotMenu.Pred.Change:Value() == 2 then
            local pred = self.RPrediction
            pred:GetPrediction(target, myHero)
            if pred.CastPosition and pred:CanHit(self.UrgotMenu.Pred.PredR:Value() + 1) then
                ControlCastSpell(HK_R, self.RPrediction.CastPosition)
            end
        end
        if self.UrgotMenu.Pred.Change:Value() == 3 then
            local args = {
                Hotkey = HK_R,
                Target = target,
                SpellData = self.RspellData,
                ExtendedCheck = true,
                maxCollision = 1,
                CheckSplashCollision = false,
                SplashCollisionRadius = 0,
                UseHeroCollision = true,
                CheckTerrain = false,
                TerrainCorrectionWeight = 0.8,
                collisionRadiusOverride = self.RspellData.Radius or 0,
                IgnoreUnkillable = self.IgnoreUnkillable ~= false,
                IgnoreSpellshields = false,
                IgnoreAAImmune = true,
                ValidCheck = false,
                GGPred = false,
                StrafePred = StrafePred ~= false,
                KillerPred = KillerPred ~= false,
                InterpolatedPred = false, -- A subset of KillerPred that will cast the spell at the exact path point the unit and spell will meet.,
                offscreenLinearSkillshots = true,
                ReturnPos = false,
            }
            local didCast = CastPredictedSpell(args)
            if (didCast) then
                LastSpellCasted = HK_R
                return didCast
            end
        end
    end
end

function OnLoad()
    --[[     if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...)
            OnPreAttack(...)
        end)
        _G.SDK.Orbwalker:OnPreMovement(function(...)
            OnPreMovement(...)
        end)
    elseif _G.PremiumOrbwalker then
        _G.PremiumOrbwalker:OnPreAttack(function(...)
            OnPreAttack(...)
        end)
        _G.PremiumOrbwalker:OnPreMovement(function(...)
            OnPreMovement(...)
        end)
    end ]]
    Urgot()
    DrawInfo = true
end

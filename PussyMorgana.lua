if myHero.charName ~= "Morgana" then return end
class "Morgana"

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')


-- [ AutoUpdate ]
do
    
    local Version = 0.04
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyMorgana.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyMorgana.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyMorgana.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyMorgana.version"
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
            print("New PussyMorgana Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end

local MathAbs = math.abs
local MathAcos = math.acos
local MathAtan = math.atan
local MathAtan2 = math.atan2
local MathCeil = math.ceil
local MathCos = math.cos
local MathDeg = math.deg
local MathFloor = math.floor
local MathHuge = math.huge
local MathMax = math.max
local MathMin = math.min
local MathPi = math.pi
local MathRad = math.rad
local MathRandom = math.random
local MathSin = math.sin
local MathSqrt = math.sqrt
local TableInsert = table.insert
local TableRemove = table.remove
local TableSort = table.sort
local menu = 1
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local Allies = {}; local Enemies = {}; local Turrets = {}; local Units = {}
local GameLatency = Game.Latency
local GameTimer = Game.Timer

local CCExceptions = {
	["CamilleEMissile"] = true,
	["HecarimUltMissile"] = true,
	["HowlingGaleSpell"] = true,
	["JhinETrap"] = true,
	["JhinRShotMis"] = true,
	["JinxEHit"] = true,
	["SyndraESphereMissile"] = true,
	["ThreshQMissile"] = true,
}

local CCSpells = {
	["AatroxW"] = {charName = "Aatrox", displayName = "Infernal Chains", slot = _W, origin = "spell", type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 80, collision = true},
	["AhriSeduce"] = {charName = "Ahri", displayName = "Seduce", slot = _E, origin = "spell", type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, collision = true},
	["AhriSeduceMissile"] = {charName = "Ahri", displayName = "Seduce [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, collision = true},
	["AkaliR"] = {charName = "Akali", displayName = "Perfect Execution [First]", slot = _R, origin = "spell", type = "linear", speed = 1800, range = 525, delay = 0, radius = 65, collision = false},
	["Pulverize"] = {charName = "Alistar", displayName = "Pulverize", slot = _Q, origin = "spell", type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 365, collision = false},
	["BandageToss"] = {charName = "Amumu", displayName = "Bandage Toss", slot = _Q, origin = "spell", type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, collision = true},
	["SadMummyBandageToss"] = {charName = "Amumu", displayName = "Bandage Toss [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, collision = true},
	["CurseoftheSadMummy"] = {charName = "Amumu", displayName = "Curse of the Sad Mummy", slot = _R, origin = "spell", type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 550, collision = false},
	["FlashFrostSpell"] = {charName = "Anivia", displayName = "Flash Frost",missileName = "FlashFrostSpell", slot = _Q, origin = "both", type = "linear", speed = 850, range = 1100, delay = 0.25, radius = 110, collision = false},
	["EnchantedCrystalArrow"] = {charName = "Ashe", displayName = "Enchanted Crystal Arrow", slot = _R, origin = "both", type = "linear", speed = 1600, range = 25000, delay = 0.25, radius = 130, collision = false},
	["AurelionSolQ"] = {charName = "AurelionSol", displayName = "Starsurge", slot = _Q, origin = "spell", type = "linear", speed = 850, range = 25000, delay = 0, radius = 110, collision = false},
	["AurelionSolQMissile"] = {charName = "AurelionSol", displayName = "Starsurge [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 850, range = 25000, delay = 0, radius = 110, collision = false},
	["AzirR"] = {charName = "Azir", displayName = "Emperor's Divide", slot = _R, origin = "spell", type = "linear", speed = 1400, range = 500, delay = 0.3, radius = 250, collision = false},
	["BardQ"] = {charName = "Bard", displayName = "Cosmic Binding", slot = _Q, origin = "spell", type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, collision = true},
	["BardQMissile"] = {charName = "Bard", displayName = "Cosmic Binding [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, collision = true},
	["BardR"] = {charName = "Bard", displayName = "Tempered Fate", slot = _R, origin = "spell", type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, collision = false},
	["BardRMissile"] = {charName = "Bard", displayName = "Tempered Fate [Missile]", slot = _R, origin = "missile", type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, collision = false},
	["RocketGrab"] = {charName = "Blitzcrank", displayName = "Rocket Grab", slot = _Q, origin = "spell", type = "linear", speed = 1800, range = 1050, delay = 0.25, radius = 70, collision = true},
	["RocketGrabMissile"] = {charName = "Blitzcrank", displayName = "Rocket Grab [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1800, range = 1050, delay = 0.25, radius = 70, collision = true},
	["BraumQ"] = {charName = "Braum", displayName = "Winter's Bite", slot = _Q, origin = "spell", type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = true},
	["BraumQMissile"] = {charName = "Braum", displayName = "Winter's Bite [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = true},
	["BraumR"] = {charName = "Braum", displayName = "Glacial Fissure", slot = _R, origin = "spell", type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, collision = false},
	["BraumRMissile"] = {charName = "Braum", displayName = "Glacial Fissure [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, collision = false},
	["CaitlynYordleTrap"] = {charName = "Caitlyn", displayName = "Yordle Trap", slot = _W, origin = "spell", type = "circular", speed = MathHuge, range = 800, delay = 0.25, radius = 75, collision = false},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = _E, origin = "spell", type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},
	["CassiopeiaW"] = {charName = "Cassiopeia", displayName = "Miasma", slot = _W, origin = "spell", type = "circular", speed = 2500, range = 800, delay = 0.75, radius = 160, collision = false},
	["Rupture"] = {charName = "Chogath", displayName = "Rupture", slot = _Q, origin = "spell", type = "circular", speed = MathHuge, range = 950, delay = 1.2, radius = 250, collision = false},
	["InfectedCleaverMissile"] = {charName = "DrMundo", displayName = "Infected Cleaver", slot = _Q, origin = "both", type = "linear", speed = 2000, range = 975, delay = 0.25, radius = 60, collision = true},
	["DravenDoubleShot"] = {charName = "Draven", displayName = "Double Shot", slot = _E, origin = "spell", type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, collision = false},
	["DravenDoubleShotMissile"] = {charName = "Draven", displayName = "Double Shot [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, collision = false},
	["EkkoQ"] = {charName = "Ekko", displayName = "Timewinder", slot = _Q, origin = "spell", type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, collision = false},
	["EkkoQMis"] = {charName = "Ekko", displayName = "Timewinder [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, collision = false},
	["EkkoW"] = {charName = "Ekko", displayName = "Parallel Convergence", slot = _W, origin = "spell", type = "circular", speed = MathHuge, range = 1600, delay = 3.35, radius = 400, collision = false},
	["EkkoWMis"] = {charName = "Ekko", displayName = "Parallel Convergence [Missile]", slot = _W, origin = "missile", type = "circular", speed = MathHuge, range = 1600, delay = 3.35, radius = 400, collision = false},
	["EliseHumanE"] = {charName = "Elise", displayName = "Cocoon", slot = _E, origin = "both", type = "linear", speed = 1600, range = 1075, delay = 0.25, radius = 55, collision = true},
	["FizzR"] = {charName = "Fizz", displayName = "Chum the Waters", slot = _R, origin = "spell", type = "linear", speed = 1300, range = 1300, delay = 0.25, radius = 150, collision = false},
	["FizzRMissile"] = {charName = "Fizz", displayName = "Chum the Waters [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1300, range = 1300, delay = 0.25, radius = 150, collision = false},
	["GalioE"] = {charName = "Galio", displayName = "Justice Punch", slot = _E, origin = "spell", type = "linear", speed = 2300, range = 650, delay = 0.4, radius = 160, collision = false},
	["GnarQMissile"] = {charName = "Gnar", displayName = "Boomerang Throw", slot = _Q, origin = "both", type = "linear", speed = 2500, range = 1125, delay = 0.25, radius = 55, collision = false},
	["GnarBigQMissile"] = {charName = "Gnar", displayName = "Boulder Toss", slot = _Q, origin = "both", type = "linear", speed = 2100, range = 1125, delay = 0.5, radius = 90, collision = true},
	["GnarBigW"] = {charName = "Gnar", displayName = "Wallop", slot = _W, origin = "spell", type = "linear", speed = MathHuge, range = 575, delay = 0.6, radius = 100, collision = false},
	["GnarR"] = {charName = "Gnar", displayName = "GNAR!", slot = _R, origin = "spell", type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 475, collision = false},
	["GragasQ"] = {charName = "Gragas", displayName = "Barrel Roll", slot = _Q, origin = "spell", type = "circular", speed = 1000, range = 850, delay = 0.25, radius = 275, collision = false},
	["GragasQMissile"] = {charName = "Gragas", displayName = "Barrel Roll [Missile]", slot = _Q, origin = "missile", type = "circular", speed = 1000, range = 850, delay = 0.25, radius = 275, collision = false},
	["GragasR"] = {charName = "Gragas", displayName = "Explosive Cask", slot = _R, origin = "spell", type = "circular", speed = 1800, range = 1000, delay = 0.25, radius = 400, collision = false},
	["GragasRBoom"] = {charName = "Gragas", displayName = "Explosive Cask [Missile]", slot = _R, origin = "missile", type = "circular", speed = 1800, range = 1000, delay = 0.25, radius = 400, collision = false},
	["GravesSmokeGrenade"] = {charName = "Graves", displayName = "Smoke Grenade", slot = _W, origin = "spell", type = "circular", speed = 1500, range = 950, delay = 0.15, radius = 250, collision = false},
	["GravesSmokeGrenadeBoom"] = {charName = "Graves", displayName = "Smoke Grenade [Missile]", slot = _W, origin = "missile", type = "circular", speed = 1500, range = 950, delay = 0.15, radius = 250, collision = false},
	["HecarimUltMissile"] = {charName = "Hecarim", displayName = "Onslaught of Shadows", slot = _R, origin = "missile", type = "linear", speed = 1100, range = 1650, delay = 0.2, radius = 280, collision = false},
	["HeimerdingerE"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = _E, origin = "spell", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerESpell"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade [Missile]", slot = _E, origin = "missile", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerEUlt"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = _E, origin = "spell", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerESpell_ult"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade [Missile]", slot = _E, origin = "missile", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["IreliaW2"] = {charName = "Illaoi", displayName = "Defiant Dance", slot = _W, origin = "spell", type = "linear", speed = MathHuge, range = 775, delay = 0.25, radius = 120, collision = false},
	["IreliaR"] = {charName = "Illaoi", displayName = "Vanguard's Edge", slot = _R, origin = "both", type = "linear", speed = 2000, range = 950, delay = 0.4, radius = 160, collision = false},
	["IvernQ"] = {charName = "Illaoi", displayName = "Rootcaller", slot = _Q, origin = "both", type = "linear", speed = 1300, range = 1075, delay = 0.25, radius = 80, collision = true},
	["HowlingGaleSpell"] = {charName = "Janna", displayName = "Howling Gale [1]", slot = _Q, origin = "missile", type = "linear", speed = 667, range = 995, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell2"] = {charName = "Janna", displayName = "Howling Gale [2]", slot = _Q, origin = "missile", type = "linear", speed = 700, range = 1045, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell3"] = {charName = "Janna", displayName = "Howling Gale [3]", slot = _Q, origin = "missile", type = "linear", speed = 733, range = 1095, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell4"] = {charName = "Janna", displayName = "Howling Gale [4]", slot = _Q, origin = "missile", type = "linear", speed = 767, range = 1145, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell5"] = {charName = "Janna", displayName = "Howling Gale [5]", slot = _Q, origin = "missile", type = "linear", speed = 800, range = 1195, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell6"] = {charName = "Janna", displayName = "Howling Gale [6]", slot = _Q, origin = "missile", type = "linear", speed = 833, range = 1245, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell7"] = {charName = "Janna", displayName = "Howling Gale [7]", slot = _Q, origin = "missile", type = "linear", speed = 867, range = 1295, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell8"] = {charName = "Janna", displayName = "Howling Gale [8]", slot = _Q, origin = "missile", type = "linear", speed = 900, range = 1345, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell9"] = {charName = "Janna", displayName = "Howling Gale [9]", slot = _Q, origin = "missile", type = "linear", speed = 933, range = 1395, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell10"] = {charName = "Janna", displayName = "Howling Gale [10]", slot = _Q, origin = "missile", type = "linear", speed = 967, range = 1445, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell11"] = {charName = "Janna", displayName = "Howling Gale [11]", slot = _Q, origin = "missile", type = "linear", speed = 1000, range = 1495, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell12"] = {charName = "Janna", displayName = "Howling Gale [12]", slot = _Q, origin = "missile", type = "linear", speed = 1033, range = 1545, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell13"] = {charName = "Janna", displayName = "Howling Gale [13]", slot = _Q, origin = "missile", type = "linear", speed = 1067, range = 1595, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell14"] = {charName = "Janna", displayName = "Howling Gale [14]", slot = _Q, origin = "missile", type = "linear", speed = 1100, range = 1645, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell15"] = {charName = "Janna", displayName = "Howling Gale [15]", slot = _Q, origin = "missile", type = "linear", speed = 1133, range = 1695, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell16"] = {charName = "Janna", displayName = "Howling Gale [16]", slot = _Q, origin = "missile", type = "linear", speed = 1167, range = 1745, delay = 0, radius = 120, collision = false},
	["JarvanIVDragonStrike"] = {charName = "JarvanIV", displayName = "Dragon Strike", slot = _Q, origin = "spell", type = "linear", speed = MathHuge, range = 770, delay = 0.4, radius = 70, collision = false},
	["JhinW"] = {charName = "Jhin", displayName = "Deadly Flourish", slot = _W, origin = "spell", type = "linear", speed = 5000, range = 2550, delay = 0.75, radius = 40, collision = false},
	["JhinE"] = {charName = "Jhin", displayName = "Captive Audience", slot = _E, origin = "spell", type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, collision = false},
	["JhinETrap"] = {charName = "Jhin", displayName = "Captive Audience [Missile]", slot = _E, origin = "missile", type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, collision = false},
	["JhinRShotMis"] = {charName = "Jhin", displayName = "Curtain Call [Missile]", slot = _R, origin = "missile", type = "linear", speed = 5000, range = 3500, delay = 0.25, radius = 80, collision = false},
	["JinxWMissile"] = {charName = "Jinx", displayName = "Zap!", slot = _W, origin = "both", type = "linear", speed = 3300, range = 1450, delay = 0.6, radius = 60, collision = true},
	["JinxEHit"] = {charName = "Jinx", displayName = "Flame Chompers! [Missile]", slot = _E, origin = "missile", type = "circular", speed = 1750, range = 900, delay = 0, radius = 120, collision = false},
	["KarmaQ"] = {charName = "Karma", displayName = "Inner Flame", slot = _Q, origin = "spell", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 60, collision = true},
	["KarmaQMissile"] = {charName = "Karma", displayName = "Inner Flame [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 60, collision = true},
	["KarmaQMantra"] = {charName = "Karma", displayName = "Inner Flame [Mantra]", slot = _Q, origin = "linear", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 80, collision = true},
	["KarmaQMissileMantra"] = {charName = "Karma", displayName = "Inner Flame [Mantra, Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 80, collision = true},
	["KaynW"] = {charName = "Kayn", displayName = "Blade's Reach", slot = _W, origin = "spell", type = "linear", speed = MathHuge, range = 700, delay = 0.55, radius = 90, collision = false},
	["KhazixWLong"] = {charName = "Khazix", displayName = "Void Spike [Threeway]", slot = _W, origin = "spell", type = "threeway", speed = 1700, range = 1000, delay = 0.25, radius = 70,angle = 23, collision = true},
	["KledQ"] = {charName = "Kled", displayName = "Beartrap on a Rope", slot = _Q, origin = "spell", type = "linear", speed = 1600, range = 800, delay = 0.25, radius = 45, collision = true},
	["KledQMissile"] = {charName = "Kled", displayName = "Beartrap on a Rope [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1600, range = 800, delay = 0.25, radius = 45, collision = true},
	["KogMawVoidOozeMissile"] = {charName = "KogMaw", displayName = "Void Ooze", slot = _E, origin = "both", type = "linear", speed = 1400, range = 1360, delay = 0.25, radius = 120, collision = false},
	["LeblancE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Standard]", slot = _E, origin = "spell", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancEMissile"] = {charName = "Leblanc", displayName = "Ethereal Chains [Standard, Missile]", slot = _E, origin = "missile", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancRE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Ultimate]", slot = _E, origin = "spell", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancREMissile"] = {charName = "Leblanc", displayName = "Ethereal Chains [Ultimate, Missile]", slot = _E, origin = "missile", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeonaZenithBlade"] = {charName = "Leona", displayName = "Zenith Blade", slot = _E, origin = "spell", type = "linear", speed = 2000, range = 875, delay = 0.25, radius = 70, collision = false},
	["LeonaSolarFlare"] = {charName = "Leona", displayName = "Solar Flare", slot = _R, origin = "spell", type = "circular", speed = MathHuge, range = 1200, delay = 0.85, radius = 300, collision = false},
	["LissandraQMissile"] = {charName = "Lissandra", displayName = "Ice Shard", slot = _Q, origin = "both", type = "linear", speed = 2200, range = 750, delay = 0.25, radius = 75, collision = false},
	["LuluQ"] = {charName = "Lulu", displayName = "Glitterlance", slot = _Q, origin = "spell", type = "linear", speed = 1450, range = 925, delay = 0.25, radius = 60, collision = false},
	["LuluQMissile"] = {charName = "Lulu", displayName = "Glitterlance [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1450, range = 925, delay = 0.25, radius = 60, collision = false},
	["LuxLightBinding"] = {charName = "Lux", displayName = "Light Binding", slot = _Q, origin = "spell", type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 50, collision = true},
	["LuxLightBindingDummy"] = {charName = "Lux", displayName = "Light Binding [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 50, collision = true},
	["LuxLightStrikeKugel"] = {charName = "Lux", displayName = "Light Strike Kugel", slot = _E, origin = "both", type = "circular", speed = 1200, range = 1100, delay = 0.25, radius = 300, collision = true},
	["Landslide"] = {charName = "Malphite", displayName = "Ground Slam", slot = _E, origin = "spell", type = "circular", speed = MathHuge, range = 0, delay = 0.242, radius = 400, collision = false},
	["MalzaharQ"] = {charName = "Malzahar", displayName = "Call of the Void", slot = _Q, origin = "spell", type = "rectangular", speed = 1600, range = 900, delay = 0.5, radius = 400, radius2 = 100, collision = false},
	["MalzaharQMissile"] = {charName = "Malzahar", displayName = "Call of the Void [Missile]", slot = _Q, origin = "missile", type = "rectangular", speed = 1600, range = 900, delay = 0.5, radius = 400, radius2 = 100, collision = false},
	["MaokaiQ"] = {charName = "Maokai", displayName = "Bramble Smash", slot = _Q, origin = "spell", type = "linear", speed = 1600, range = 600, delay = 0.375, radius = 110, collision = false},
	["MaokaiQMissile"] = {charName = "Maokai", displayName = "Bramble Smash [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1600, range = 600, delay = 0.375, radius = 110, collision = false},
	["DarkBindingMissile"] = {charName = "Morgana", displayName = "Dark Binding", slot = _Q, origin = "both", type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 70, collision = true},
	["NamiQ"] = {charName = "Nami", displayName = "Aqua Prison", slot = _Q, origin = "spell", type = "circular", speed = MathHuge, range = 875, delay = 1, radius = 180, collision = false},
	["NamiRMissile"] = {charName = "Nami", displayName = "Tidal Wave", slot = _R, origin = "both", type = "linear", speed = 850, range = 2750, delay = 0.5, radius = 250, collision = false},
	["NautilusAnchorDragMissile"] = {charName = "Nautilus", displayName = "Dredge Line", slot = _Q, origin = "both", type = "linear", speed = 2000, range = 925, delay = 0.25, radius = 90, collision = true},
	["NeekoQ"] = {charName = "Neeko", displayName = "Blooming Burst", slot = _Q, origin = "both", type = "circular", speed = 1500, range = 800, delay = 0.25, radius = 200, collision = false},
	["NeekoE"] = {charName = "Neeko", displayName = "Tangle-Barbs", slot = _E, origin = "both", type = "linear", speed = 1400, range = 1000, delay = 0.25, radius = 65, collision = false},
	["NunuR"] = {charName = "Nunu", displayName = "Absolute Zero", slot = _R, origin = "spell", type = "circular", speed = MathHuge, range = 0, delay = 3, radius = 650, collision = false},
	["OlafAxeThrowCast"] = {charName = "Olaf", displayName = "Undertow", slot = _Q, origin = "spell", type = "linear", speed = 1600, range = 1000, delay = 0.25, radius = 90, collision = false},
	["OlafAxeThrow"] = {charName = "Olaf", displayName = "Undertow [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1600, range = 1000, delay = 0.25, radius = 90, collision = false},
	["OrnnQ"] = {charName = "Ornn", displayName = "Volcanic Rupture", slot = _Q, origin = "spell", type = "linear", speed = 1800, range = 800, delay = 0.3, radius = 65, collision = false},
	-- OrnnQMissile
	["OrnnE"] = {charName = "Ornn", displayName = "Searing Charge", slot = _E, origin = "spell", type = "linear", speed = 1800, range = 800, delay = 0.35, radius = 150, collision = false},
	["OrnnRCharge"] = {charName = "Ornn", displayName = "Call of the Forge God", slot = _R, origin = "spell", type = "linear", speed = 1650, range = 2500, delay = 0.5, radius = 200, collision = false},
	-- OrnnRMissile
	["PoppyQSpell"] = {charName = "Poppy", displayName = "Hammer Shock", slot = _Q, origin = "spell", type = "linear", speed = MathHuge, range = 430, delay = 0.332, radius = 100, collision = false},
	["PoppyRSpell"] = {charName = "Poppy", displayName = "Keeper's Verdict", slot = _R, origin = "spell", type = "linear", speed = 2000, range = 1200, delay = 0.33, radius = 100, collision = false},
	["PoppyRSpellMissile"] = {charName = "Poppy", displayName = "Keeper's Verdict [Missile]", slot = _R, origin = "missile", type = "linear", speed = 2000, range = 1200, delay = 0.33, radius = 100, collision = false},
	["PykeQMelee"] = {charName = "Pyke", displayName = "Bone Skewer [Melee]", slot = _Q, origin = "spell", type = "linear", speed = MathHuge, range = 400, delay = 0.25, radius = 70, collision = false},
	["PykeQRange"] = {charName = "Pyke", displayName = "Bone Skewer [Range]", slot = _Q, origin = "both", type = "linear", speed = 2000, range = 1100, delay = 0.2, radius = 70, collision = true},
	["PykeE"] = {charName = "Pyke", displayName = "Phantom Undertow", slot = _E, origin = "spell", type = "linear", speed = 3000, range = 25000, delay = 0, radius = 110, collision = false},
	["PykeEMissile"] = {charName = "Pyke", displayName = "Phantom Undertow [Missile]", slot = _E, origin = "missile", type = "linear", speed = 3000, range = 25000, delay = 0, radius = 110, collision = false},
	["RakanW"] = {charName = "Rakan", displayName = "Grand Entrance", slot = _W, origin = "spell", type = "circular", speed = MathHuge, range = 650, delay = 0.7, radius = 265, collision = false},
	["RengarE"] = {charName = "Rengar", displayName = "Bola Strike", slot = _E, origin = "spell", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = true},
	["RengarEMis"] = {charName = "Rengar", displayName = "Bola Strike [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = true},
	["RumbleGrenade"] = {charName = "Rumble", displayName = "Electro Harpoon", slot = _E, origin = "spell", type = "linear", speed = 2000, range = 850, delay = 0.25, radius = 60, collision = true},
	["RumbleGrenadeMissile"] = {charName = "Rumble", displayName = "Electro Harpoon [Missile]", slot = _E, origin = "missile", type = "linear", speed = 2000, range = 850, delay = 0.25, radius = 60, collision = true},
	["SejuaniR"] = {charName = "Sejuani", displayName = "Glacial Prison", slot = _R, origin = "spell", type = "linear", speed = 1600, range = 1300, delay = 0.25, radius = 120, collision = false},
	["SejuaniRMissile"] = {charName = "Sejuani", displayName = "Glacial Prison [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1600, range = 1300, delay = 0.25, radius = 120, collision = false},
	["ShyvanaTransformLeap"] = {charName = "Shyvana", displayName = "Transform Leap", slot = _R, origin = "spell", type = "linear", speed = 700, range = 850, delay = 0.25, radius = 150, collision = false},
	["SionQ"] = {charName = "Sion", displayName = "Decimating Smash", slot = _Q, origin = "", type = "linear", speed = MathHuge, range = 750, delay = 2, radius = 150, collision = false},
	["SionE"] = {charName = "Sion", displayName = "Roar of the Slayer", slot = _E, origin = "spell", type = "linear", speed = 1800, range = 800, delay = 0.25, radius = 80, collision = false},
	["SionEMissile"] = {charName = "Sion", displayName = "Roar of the Slayer [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1800, range = 800, delay = 0.25, radius = 80, collision = false},
	["SkarnerFractureMissile"] = {charName = "Skarner", displayName = "Fracture", slot = _E, origin = "both", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = false},
	["SonaR"] = {charName = "Sona", displayName = "Crescendo", slot = _R, origin = "spell", type = "linear", speed = 2400, range = 1000, delay = 0.25, radius = 140, collision = false},
	["SonaRMissile"] = {charName = "Sona", displayName = "Crescendo [Missile]", slot = _R, origin = "missile", type = "linear", speed = 2400, range = 1000, delay = 0.25, radius = 140, collision = false},
	["SorakaQ"] = {charName = "Soraka", displayName = "Starcall", slot = _Q, origin = "spell", type = "circular", speed = 1150, range = 810, delay = 0.25, radius = 235, collision = false},
	["SorakaQMissile"] = {charName = "Soraka", displayName = "Starcall [Missile]", slot = _Q, origin = "missile", type = "circular", speed = 1150, range = 810, delay = 0.25, radius = 235, collision = false},
	["SwainW"] = {charName = "Swain", displayName = "Vision of Empire", slot = _W, origin = "spell", type = "circular", speed = MathHuge, range = 3500, delay = 1.5, radius = 300, collision = false},
	["SwainE"] = {charName = "Swain", displayName = "Nevermove", slot = _E, origin = "both", type = "linear", speed = 1800, range = 850, delay = 0.25, radius = 85, collision = false},
	["SyndraESphereMissile"] = {charName = "Syndra", displayName = "Scatter the Weak [Seed]", slot = _E, origin = "missile", type = "linear", speed = 2000, range = 950, delay = 0.25, radius = 100, collision = false},
	["TahmKenchQ"] = {charName = "TahmKench", displayName = "Tongue Lash", slot = _Q, origin = "spell", type = "linear", speed = 2800, range = 800, delay = 0.25, radius = 70, collision = true},
	["TahmKenchQMissile"] = {charName = "TahmKench", displayName = "Tongue Lash [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 2800, range = 800, delay = 0.25, radius = 70, collision = true},
	["TaliyahWVC"] = {charName = "Taliyah", displayName = "Seismic Shove", slot = _W, origin = "spell", type = "circular", speed = MathHuge, range = 900, delay = 0.85, radius = 150, collision = false},
	["TaliyahR"] = {charName = "Taliyah", displayName = "Weaver's Wall", slot = _R, origin = "spell", type = "linear", speed = 1700, range = 3000, delay = 1, radius = 120, collision = false},
	["TaliyahRMis"] = {charName = "Taliyah", displayName = "Weaver's Wall [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1700, range = 3000, delay = 1, radius = 120, collision = false},
	["ThreshQMissile"] = {charName = "Thresh", displayName = "Death Sentence [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1900, range = 1075, delay = 0.5, radius = 70, collision = true},
	["ThreshE"] = {charName = "Thresh", displayName = "Flay", slot = _E, origin = "spell", type = "linear", speed = MathHuge, range = 500, delay = 0.389, radius = 110, collision = true},
	["ThreshEMissile1"] = {charName = "Thresh", displayName = "Flay [Missile]", slot = _E, origin = "missile", type = "linear", speed = MathHuge, range = 500, delay = 0.389, radius = 110, collision = true},
	["TristanaW"] = {charName = "Tristana", displayName = "Rocket Jump", slot = _W, origin = "spell", type = "circular", speed = 1100, range = 900, delay = 0.25, radius = 300, collision = false},
	["UrgotQ"] = {charName = "Urgot", displayName = "Corrosive Charge", slot = _Q, origin = "spell", type = "circular", speed = MathHuge, range = 800, delay = 0.6, radius = 180, collision = false},
	["UrgotQMissile"] = {charName = "Urgot", displayName = "Corrosive Charge [Missile]", slot = _Q, origin = "missile", type = "circular", speed = MathHuge, range = 800, delay = 0.6, radius = 180, collision = false},
	["UrgotE"] = {charName = "Urgot", displayName = "Disdain", slot = _E, origin = "spell", type = "linear", speed = 1500, range = 475, delay = 0.45, radius = 100, collision = false},
	["UrgotR"] = {charName = "Urgot", displayName = "Fear Beyond Death", slot = _R, origin = "both", type = "linear", speed = 3200, range = 1600, delay = 0.4, radius = 80, collision = false},
	["VarusE"] = {charName = "Varus", displayName = "Hail of Arrows", slot = _E, origin = "spell", type = "linear", speed = 1500, range = 925, delay = 0.242, radius = 260, collision = false},
	["VarusEMissile"] = {charName = "Varus", displayName = "Hail of Arrows [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1500, range = 925, delay = 0.242, radius = 260, collision = false},
	["VarusR"] = {charName = "Varus", displayName = "Chain of Corruption", slot = _R, origin = "spell", type = "linear", speed = 1950, range = 1200, delay = 0.25, radius = 120, collision = false},
	["VarusRMissile"] = {charName = "Varus", displayName = "Chain of Corruption [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1950, range = 1200, delay = 0.25, radius = 120, collision = false},
	["VelkozQ"] = {charName = "Velkoz", displayName = "Plasma Fission", slot = _Q, origin = "spell", type = "linear", speed = 1300, range = 1050, delay = 0.25, radius = 50, collision = true},
	["VelkozQMissile"] = {charName = "Velkoz", displayName = "Plasma Fission [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1300, range = 1050, delay = 0.25, radius = 50, collision = true},
	["VelkozQMissileSplit"] = {charName = "Velkoz", displayName = "Plasma Fission [Split]", slot = _Q, origin = "missile", type = "linear", speed = 2100, range = 1100, delay = 0.25, radius = 45, collision = true},
	["VelkozE"] = {charName = "Velkoz", displayName = "Tectonic Disruption", slot = _E, origin = "spell", type = "circular", speed = MathHuge, range = 800, delay = 0.8, radius = 185, collision = false},
	["VelkozEMissile"] = {charName = "Velkoz", displayName = "Tectonic Disruption [Missile]", slot = _E, origin = "missile", type = "circular", speed = MathHuge, range = 800, delay = 0.8, radius = 185, collision = false},
	["ViktorGravitonField"] = {charName = "Viktor", displayName = "Graviton Field", slot = _W, origin = "spell", type = "circular", speed = MathHuge, range = 800, delay = 1.75, radius = 270, collision = false},
	["WarwickR"] = {charName = "Warwick", displayName = "Infinite Duress", slot = _R, origin = "spell", type = "linear", speed = 1800, range = 3000, delay = 0.1, radius = 55, collision = false},
	["XerathArcaneBarrage2"] = {charName = "Xerath", displayName = "Arcane Barrage", slot = _W, origin = "spell", type = "circular", speed = MathHuge, range = 1000, delay = 0.75, radius = 235, collision = false},
	["XerathMageSpear"] = {charName = "Xerath", displayName = "Mage Spear", slot = _E, origin = "spell", type = "linear", speed = 1400, range = 1050, delay = 0.2, radius = 60, collision = true},
	["XerathMageSpearMissile"] = {charName = "Xerath", displayName = "Mage Spear [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1400, range = 1050, delay = 0.2, radius = 60, collision = true},
	["XinZhaoW"] = {charName = "XinZhao", displayName = "Wind Becomes Lightning", slot = _W, origin = "spell", type = "linear", speed = 5000, range = 900, delay = 0.5, radius = 40, collision = false},
	["YasuoQ3Mis"] = {charName = "Yasuo", displayName = "Gathering Storm [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1200, range = 1100, delay = 0.318, radius = 90, collision = false},
	["ZacQ"] = {charName = "Zac", displayName = "Stretching Strikes", slot = _Q, origin = "spell", type = "linear", speed = 2800, range = 800, delay = 0.33, radius = 120, collision = false},
	["ZacQMissile"] = {charName = "Zac", displayName = "Stretching Strikes [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 2800, range = 800, delay = 0.33, radius = 120, collision = false},
	["ZiggsW"] = {charName = "Ziggs", displayName = "Satchel Charge", slot = _W, origin = "both", type = "circular", speed = 1750, range = 1000, delay = 0.25, radius = 240, collision = false},
	["ZiggsE"] = {charName = "Ziggs", displayName = "Hexplosive Minefield", slot = _E, origin = "both", type = "circular", speed = 1800, range = 900, delay = 0.25, radius = 250, collision = false},
	["ZileanQ"] = {charName = "Zilean", displayName = "Time Bomb", slot = _Q, origin = "spell", type = "circular", speed = MathHuge, range = 900, delay = 0.8, radius = 150, collision = false},
	["ZileanQMissile"] = {charName = "Zilean", displayName = "Time Bomb [Missile]", slot = _Q, origin = "missile", type = "circular", speed = MathHuge, range = 900, delay = 0.8, radius = 150, collision = false},
	["ZoeE"] = {charName = "Zoe", displayName = "Sleepy Trouble Bubble", slot = _E, origin = "spell", type = "linear", speed = 1700, range = 800, delay = 0.3, radius = 50, collision = true},
	["ZoeEMissile"] = {charName = "Zoe", displayName = "Sleepy Trouble Bubble [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1700, range = 800, delay = 0.3, radius = 50, collision = true},
	["ZyraE"] = {charName = "Zyra", displayName = "Grasping Roots", slot = _E, origin = "both", type = "linear", speed = 1150, range = 1100, delay = 0.25, radius = 70, collision = false},
	["ZyraR"] = {charName = "Zyra", displayName = "Stranglethorns", slot = _R, origin = "spell", type = "circular", speed = MathHuge, range = 700, delay = 2, radius = 500, collision = false},
	["BrandConflagration"] = {charName = "Brand", slot = _R, type = "targeted", displayName = "Conflagration", range = 625,cc = true},
	["JarvanIVCataclysm"] = {charName = "JarvanIV", slot = _R, type = "targeted", displayName = "Cataclysm", range = 650},
	["JayceThunderingBlow"] = {charName = "Jayce", slot = _E, type = "targeted", displayName = "Thundering Blow", range = 240},
	["BlindMonkRKick"] = {charName = "LeeSin", slot = _R, type = "targeted", displayName = "Dragon's Rage", range = 375},
	["LissandraR"] = {charName = "Lissandra", slot = _R, type = "targeted", displayName = "Frozen Tomb", range = 550},
	["SeismicShard"] = {charName = "Malphite", slot = _Q, type = "targeted", displayName = "Seismic Shard", range = 625,cc = true},
	["AlZaharNetherGrasp"] = {charName = "Malzahar", slot = _R, type = "targeted", displayName = "Nether Grasp", range = 700},
	["MaokaiW"] = {charName = "Maokai", slot = _W, type = "targeted", displayName = "Twisted Advance", range = 525},
	["NautilusR"] = {charName = "Nautilus", slot = _R, type = "targeted", displayName = "Depth Charge", range = 825},
	["PoppyE"] = {charName = "Poppy", slot = _E, type = "targeted", displayName = "Heroic Charge", range = 475},
	["RyzeW"] = {charName = "Ryze", slot = _W, type = "targeted", displayName = "Rune Prison", range = 615},
	["Fling"] = {charName = "Singed", slot = _E, type = "targeted", displayName = "Fling", range = 125},
	["SkarnerImpale"] = {charName = "Skarner", slot = _R, type = "targeted", displayName = "Impale", range = 350},
	["TahmKenchW"] = {charName = "TahmKench", slot = _W, type = "targeted", displayName = "Devour", range = 250},
	["TristanaR"] = {charName = "Tristana", slot = _R, type = "targeted", displayName = "Buster Shot", range = 669},
}

local ChanellingSpells = {
	["CaitlynAceintheHole"] = {charName = "Caitlyn", slot = _R, type = "targeted", displayName = "Ace in the Hole", danger = 3},
	["Drain"] = {charName = "Fiddlesticks", slot = _W, type = "targeted", displayName = "Drain", danger = 2},
	["Crowstorm"] = {charName = "Fiddlesticks", slot = _R, type = "skillshot", displayName = "Crowstorm", danger = 3},
	["GalioW"] = {charName = "Galio", slot = _W, type = "skillshot", displayName = "Shield of Durand", danger = 2},
	["GalioR"] = {charName = "Galio", slot = _R, type = "skillshot", displayName = "Hero's Entrance", danger = 3},
	["GragasW"] = {charName = "Gragas", slot = _W, type = "skillshot", displayName = "Drunken Rage", danger = 1},
	["ReapTheWhirlwind"] = {charName = "Janna", slot = _R, type = "skillshot", displayName = "Monsoon", danger = 2},
	["KarthusFallenOne"] = {charName = "Karthus", slot = _R, type = "skillshot", displayName = "Requiem", danger = 3},
	["KatarinaR"] = {charName = "Katarina", slot = _R, type = "skillshot", displayName = "Death Lotus", danger = 3},
	["LucianR"] = {charName = "Lucian", slot = _R, type = "skillshot", displayName = "The Culling", danger = 2},
	["AlZaharNetherGrasp"] = {charName = "Malzahar", slot = _R, type = "targeted", displayName = "Nether Grasp", danger = 3},
	["Meditate"] = {charName = "MasterYi", slot = _Q, type = "skillshot", displayName = "Meditate", danger = 1},
	["MissFortuneBulletTime"] = {charName = "MissFortune", slot = _R, type = "skillshot", displayName = "Bullet Time", danger = 3},
	["AbsoluteZero"] = {charName = "Nunu", slot = _R, type = "skillshot", displayName = "Absolute Zero", danger = 3},
	["PantheonRFall"] = {charName = "Pantheon", slot = _R, type = "skillshot", displayName = "Grand Skyfall [Fall]", danger = 3},
	["PantheonRJump"] = {charName = "Pantheon", slot = _R, type = "skillshot", displayName = "Grand Skyfall [Jump]", danger = 3},
	["PykeQ"] = {charName = "Pyke", slot = _Q, type = "skillshot", displayName = "Bone Skewer", danger = 1},
	["ShenR"] = {charName = "Shen", slot = _R, type = "skillshot", displayName = "Stand United", danger = 2},
	["SionQ"] = {charName = "Sion", slot = _Q, type = "skillshot", displayName = "Decimating Smash", danger = 2},
	["Destiny"] = {charName = "TwistedFate", slot = _R, type = "skillshot", displayName = "Destiny", danger = 2},
	["VarusQ"] = {charName = "Varus", slot = _Q, type = "skillshot", displayName = "Piercing Arrow", danger = 1},
	["VelKozR"] = {charName = "VelKoz", slot = _R, type = "skillshot", displayName = "Life Form Disintegration Ray", danger = 3},
	["ViQ"] = {charName = "Vi", slot = _Q, type = "skillshot", displayName = "Vault Breaker", danger = 2},
	["XerathLocusOfPower2"] = {charName = "Xerath", slot = _R, type = "skillshot", displayName = "Rite of the Arcane", danger = 3},
	["ZacR"] = {charName = "Zac", slot = _R, type = "skillshot", displayName = "Let's Bounce!", danger = 3},
}


local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end 

function CanMove()
	if _G.SDK then
    return _G.SDK.Orbwalker:CanMove() 
	elseif _G.gsoSDK then
    return _G.gsoSDK.Orbwalker:CanMove()	
	end
end

function CanAttack()
	if _G.SDK then
		_G.SDK.Orbwalker:CanAttack()
	elseif _G.gsoSDK then
		_G.gsoSDK.Orbwalker:CanAttack()	
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

local function GetImmobileCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range and IsImmobileTarget(hero) then
		count = count + 1
		end
	end
	return count
end

local function IsImmobileTarget(unit)
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10) and buff.count > 0 then
				return true
			end
		end
		return false	
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

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	elseif _G.gsoSDK then
		return _G.gsoSDK.TargetSelector:GetTarget(GetEnemyHeroes(5000), false)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function Morgana:GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

function Morgana:GetDistance(pos1, pos2)
	return MathSqrt(self:GetDistanceSqr(pos1, pos2))
end
 

local function IsValidCreep(unit, range)
  return unit and unit.team ~= TEAM_ALLY and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false and unit.visible
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
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
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
		if hero.team == TEAM_ALLY and hero ~= myHero and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
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
		if Hero.isAlly and not Hero.isMe then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.startTime) and unit.activeSpell.isChanneling and unit.team ~= myHero.team then
			Units[i].spell = spell.name .. spell.startTime; return unit, spell
		end
	end
	return nil, nil
end

function LoadUnits()
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i); Units[i] = {unit = unit, spell = nil}
		if unit.team ~= myHero.team then TableInsert(Enemies, unit)
		elseif unit.team == myHero.team and unit ~= myHero then TableInsert(Allies, unit) end
	end
end



function Morgana:VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end


function Morgana:CalculateCollisionTime(startPos, endPos, unitPos, startTime, speed, delay, origin)
	local delay = origin == "spell" and delay or 0
	local pos = startPos:Extended(endPos, speed * (GameTimer() - delay - startTime))
	return self:GetDistance(unitPos, pos) / speed
end

function Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, collision, type)
	local range = range or 3000; local endPos = startPos:Extended(placementPos, range)
	if type == "circular" or type == "rectangular" then
		if range > 0 then if self:GetDistance(unitPos, placementPos) < range then endPos = placementPos end
		else endPos = unitPos end
	elseif collision then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and minion.team == myHero.team and not minion.dead and self:GetDistance(minion.pos, startPos) < range then
				local col = self:VectorPointProjectionOnLineSegment(startPos, placementPos, minion.pos)
				if col and self:GetDistance(col, minion.pos) < (radius + minion.boundingRadius / 2) then
					range = self:GetDistance(startPos, col); endPos = startPos:Extended(placementPos, range); break
				end
			end
		end
	end
	return endPos, range
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

local function GetItemSlot(unit, id)
	for i = ITEM_1, ITEM_7 do
	    if unit:GetItemData(i).itemID == id then
		return i
	    end
	end
	return 0 
end

function Morgana:__init()
  self.DetectedMissiles = {}; self.DetectedSpells = {}; self.Target = nil; self.Timer = 0
  if menu ~= 1 then return end
  menu = 2
  self:LoadSpells()   	
  self:LoadMenu()                                            
  Callback.Add("Tick", function() self:Tick() end)
  Callback.Add("Draw", function() self:Draw() end) 
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	elseif _G.gsoSDK then
		orbwalkername = "Gso orbwalker"
	else
		orbwalkername = "Orbwalker not found"
	end
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

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function IsAllyValid(unit)
    if (unit and unit.team == myHero.team and unit ~= myHero and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

function Morgana:EnemiesAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if (IsValid(hero) and hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end


function Morgana:LoadSpells()
 
	Q = {range = 1175, radius = 70, delay = 0.25, speed = 1200, collision = true}    
	W = {range = 900, radius = 280, delay = 0.25, speed = math.huge, collision = false}   
	E = {range = 800,}    
	R = {range = 625,}  

end


local WData =
{
Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.25, Radius = 150, Range = 900, Speed = math.huge
}

local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1175, Speed = 1200, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
}

function Morgana:GetEnemyHeroes()
	local result = {}
  	for i = 1, Game.HeroCount() do
    		local unit = Game.Hero(i)
    		if unit.isEnemy then
    			result[#result + 1] = unit
  		end
  	end
  	return result
end


function Morgana:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Morgana", name = "PussyMorgana"})

	--AutoE
	self.Menu:MenuElement({id = "AutoE", name = "Auto Shield CC", type = MENU})
	self.Menu.AutoE:MenuElement({id = "self", name = "Use when Self CC ",value = true})
	self.Menu.AutoE:MenuElement({id = "ally", name = "Use when Ally CC ",value = true})	
	self.Menu.AutoE:MenuElement({id = "Targets", name = "Ally Settings", type = MENU})
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.isAlly and myHero ~= hero then
			self.Menu.AutoE.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true})		
		end
	end		
	self.Menu:MenuElement({type = MENU, id = "ESet", name = "Shield incomming CC"})	
	self.Menu.ESet:MenuElement({id = "UseE", name = "UseE Self", value = true})
	self.Menu.ESet:MenuElement({id = "UseEally", name = "UseE Ally", value = true})	
	self.Menu.ESet:MenuElement({id = "ST", name = "Track Spells", drop = {"Channeling", "Missiles", "Both"}, value = 1})	
	self.Menu.ESet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})	
	
	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})	
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W] Immobile Target", value = true})
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})		
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]only if not Raedy[Q]", value = true})		
	
	--UltSettings
	self.Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	self.Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R] Dark Binding", value = true})
	self.Menu.Combo.Ult:MenuElement({id = "UseRE", name = "Use [R] min Targets", value = 2, min = 1, max = 6})

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]only if not Raedy[Q]", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQL", name = "LastHit[Q] Dark Binding", value = true})		
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})  
	self.Menu.Clear:MenuElement({id = "UseWM", name = "Use [W] min Minions", value = 3, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})
	self.Menu.JClear:MenuElement({id = "UseWM", name = "Use [W] min Minions", value = 3, min = 1, max = 6})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "ks"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})	
	self.Menu.ks:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})	


	
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
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})
	
	self.Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()
		for i, spell in pairs(CCSpells) do
			if not CCSpells[i] then return end
			for j, k in pairs(Morgana:GetEnemyHeroes()) do
				if spell.charName == k.charName and not self.Menu.ESet.BlockList[i] then
					if not self.Menu.ESet.BlockList[i] then self.Menu.ESet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..self.Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)
	
end

function Morgana:Tick()
if myHero.dead then return end	
	self:Activator()
	self:KillSteal()
	self:AutoW()
	self:AutoE()
	self:Auto1()
	self:Auto2()
	
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		self:Combo()
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then                
		self:Harass()

	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
		self:Clear()
		self:JungleClear()
	
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
		--self:LastHit()
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then

	elseif _G.gsoSDK then
	return _G.gsoSDK.Orbwalker:GetMode()
	else
	return GOS.GetMode()
	end
end 

function Morgana:Auto2()
	if self.Menu.ESet.UseE:Value() and Ready(_E) then
		if self.Menu.ESet.ST:Value() ~= 1 then self:OnMissileCreate() end
		if self.Menu.ESet.ST:Value() ~= 2 then self:OnProcessSpell() end
		for i, spell in pairs(self.DetectedSpells) do self:UseE(i, spell) end
	end
end

function Morgana:Auto1()
	if self.Menu.ESet.UseEally:Value() and Ready(_E) then
		if self.Menu.ESet.ST:Value() ~= 1 then self:OnMissileCreate1() end
		if self.Menu.ESet.ST:Value() ~= 2 then self:OnProcessSpell1() end
		for i, spell in pairs(self.DetectedSpells) do self:UseEally(i, spell) end
	end	
end 

function Morgana:GetHeroByHandle(handle)
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.handle == handle then return unit end
	end
end

function Morgana:UseE(i, s)
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == MathHuge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > GameTimer() then
		local Col = Morgana:VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
		if s.type == "circular" and Morgana:GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or Morgana:GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
			local t = s.speed ~= MathHuge and Morgana:CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay, s.origin) or 0.29
			if t < 0.3 then Control.CastSpell(HK_E, myHero.pos) end
		end
	else TableRemove(self.DetectedSpells, i) end
end

function Morgana:OnMissileCreate()
	if GameTimer() > self.Timer + 0.15 then
		for i, mis in pairs(self.DetectedMissiles) do if GameTimer() > mis.timer + 2 then TableRemove(self.DetectedMissiles, i) end end
		self.Timer = GameTimer()
	end
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		if CCSpells[missile.missileData.name] then
			local unit = self:GetHeroByHandle(missile.missileData.owner)
			if (not unit.visible and CCSpells[missile.missileData.name].origin ~= "spell") or CCExceptions[missile.missileData.name] then
				if Morgana:GetDistance(unit.pos, myHero.pos) > 3000 or not self.Menu.ESet.BlockList["Dodge"..missile.missileData.name]:Value() then return end
				local Detected = CCSpells[missile.missileData.name]
				if Detected.origin ~= "spell" then
					for i, mis in pairs(self.DetectedMissiles) do if mis.name == missile.missileData.name then return end end
					TableInsert(DetectedMissiles, {name = missile.missileData.name, timer = GameTimer()})
					local startPos = Vector(missile.missileData.startPos); local placementPos = Vector(missile.missileData.placementPos); local unitPos = unit.pos
					local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
					local endPos, range2 = Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
					TableInsert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = GameTimer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "missile"})
				end
			end
		end
	end
end

function Morgana:OnProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and spell and CCSpells[spell.name] then
		if Morgana:GetDistance(unit.pos, myHero.pos) > 3000 or not self.Menu.ESet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		if Detected.origin ~= "missile" then
			local type = Detected.type
			if type == "targeted" then
				if spell.target == myHero.handle then Control.CastSpell(HK_E, myHero.pos) end
			else
				local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
				local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
				local endPos, range2 = Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
				TableInsert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = GameTimer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "spell"})
			end
		end
	end
end


function Morgana:UseEally(i, s)
for i = 1, Game.HeroCount() do
local hero = Game.Hero(i)
if IsAllyValid(hero) then	
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == MathHuge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > GameTimer() then
		local Col = Morgana:VectorPointProjectionOnLineSegment(startPos, endPos, hero.pos)
		if s.type == "circular" and Morgana:GetDistanceSqr(hero.pos, endPos) < (s.radius + hero.boundingRadius) ^ 2 or Morgana:GetDistanceSqr(hero.pos, Col) < (s.radius + hero.boundingRadius * 1.25) ^ 2 then
			local t = s.speed ~= MathHuge and Morgana:CalculateCollisionTime(startPos, endPos, hero.pos, s.startTime, s.speed, s.delay, s.origin) or 0.29
			if t < 0.3 then Control.CastSpell(HK_E, hero.pos) end
		end
	else TableRemove(self.DetectedSpells, i) end
end
end
end

function Morgana:OnMissileCreate1()
for i = 1, Game.HeroCount() do
local hero = Game.Hero(i)
if IsAllyValid(hero) then	
	if GameTimer() > self.Timer + 0.15 then
		for i, mis in pairs(self.DetectedMissiles) do if GameTimer() > mis.timer + 2 then TableRemove(self.DetectedMissiles, i) end end
		self.Timer = GameTimer()
	end
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		if CCSpells[missile.missileData.name] then
			local unit = self:GetHeroByHandle(missile.missileData.owner)
			if (not unit.visible and CCSpells[missile.missileData.name].origin ~= "spell") or CCExceptions[missile.missileData.name] then
				if Morgana:GetDistance(unit.pos, hero.pos) > 3000 or not self.Menu.ESet.BlockList["Dodge"..missile.missileData.name]:Value() then return end
				local Detected = CCSpells[missile.missileData.name]
				if Detected.origin ~= "spell" then
					for i, mis in pairs(self.DetectedMissiles) do if mis.name == missile.missileData.name then return end end
					TableInsert(DetectedMissiles, {name = missile.missileData.name, timer = GameTimer()})
					local startPos = Vector(missile.missileData.startPos); local placementPos = Vector(missile.missileData.placementPos); local unitPos = unit.pos
					local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
					local endPos, range2 = Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
					TableInsert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = GameTimer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "missile"})
				end
			end
		end
	end
end
end
end

function Morgana:OnProcessSpell1()
for i = 1, Game.HeroCount() do
local hero = Game.Hero(i)
if IsAllyValid(hero) then	
	local unit, spell = OnProcessSpell()
	if unit and spell and CCSpells[spell.name] and myHero.pos:DistanceTo(hero.pos) <= 800 then
		if not self.Menu.ESet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		if Detected.origin ~= "missile" then
			local type = Detected.type
			if type == "targeted" then
				if spell.target == hero.handle then Control.CastSpell(HK_E, hero.pos) end
			else
				local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
				local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
				local endPos, range2 = Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
				TableInsert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = GameTimer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "spell"})
			end
		end
	end
end
end
end 



function Morgana:AutoE()
	for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)	
		if self.Menu.AutoE.self:Value() and Ready(_E) and IsImmobileTarget(myHero) then
			Control.CastSpell(HK_E, myHero)
		end
		if IsAllyValid(hero) then 
			if self.Menu.AutoE.ally:Value() and self.Menu.AutoE.Targets[ally.charName] and self.Menu.AutoE.Targets[ally.charName]:Value() and Ready(_E) and myHero.pos:DistanceTo(ally.pos) <= 800 and IsImmobileTarget(ally) then
				Control.CastSpell(HK_E, hero.pos)
			end
		end
	end
end
	






function Morgana:Activator()
if myHero.dead then return end
			--Zhonyas
	if self:EnemiesAround(myHero.pos,2000) then	
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
			


function Morgana:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 625, 3, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 1175, 3, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 800, 3, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 900, 3, Draw.Color(225, 225, 125, 10))
	end
	local target = CurrentTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Drawing.Kill:Value() and not target.dead then
	local hp = target.health	
		if Ready(_Q) and getdmg("Q", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_W) and getdmg("W", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
	end
end
       
function Morgana:ValidTarget(unit,range) 
  return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal 
end

function Morgana:KillSteal()
if myHero.dead then return end	
	local target = CurrentTarget(1200)     	
	if target == nil then return end
	local hp = target.health
	local QDmg = getdmg("Q", target, myHero)
	local WDmg = getdmg("W", target, myHero)
	if IsValid(target) then	
		if self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 1175 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.ks.UseW:Value() and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if WDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= _G.HITCHANCE_HIGH then			
				Control.CastSpell(HK_W, pred.CastPosition)
	
			end
		end
	end
end	


function Morgana:AutoW()
	local target = CurrentTarget(1200)
	if target == nil then return end
	if IsValid(target) then	
		if self.Menu.AutoW.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 900 and IsImmobileTarget(target) then
			Control.CastSpell(HK_W, target)
		
		elseif self.Menu.AutoW.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) > 900 and myHero.pos:DistanceTo(target.pos) < 1175 and IsImmobileTarget(target) then
			local WPos = myHero.pos:Shortened(target.pos - 900)
			Control.SetCursorPos(WPos)
			Control.KeyDown(HK_W)
			Control.KeyUp(HK_W)
		end	
	end
end	
	


function Morgana:Combo()
	local target = CurrentTarget(1200)
	if target == nil then return end

	if IsValid(target) then
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1175 then 	
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if self.Menu.Combo.UseW:Value() and Ready(_W) and not Ready(_Q) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= _G.HITCHANCE_HIGH then			
				Control.CastSpell(HK_W, pred.CastPosition)
	
			end
		end	
		
		local count = GetEnemyCount(625, myHero)
		if Ready(_R) and self.Menu.Combo.Ult.UseR:Value() and count >= self.Menu.Combo.Ult.UseRE:Value() then
			Control.CastSpell(HK_R)
		end
	end
end	




function Morgana:Harass()
local target = CurrentTarget(1200)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1175 then 
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.Harass.UseW:Value() and Ready(_W) and not Ready(_Q) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= _G.HITCHANCE_HIGH then			
				Control.CastSpell(HK_W, pred.CastPosition)
	
			end
		end
	end
end	




function Morgana:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local TEAM_ALLY = myHero.team
	local TEAM_ENEMY = 300 - myHero.team

		if minion.team == TEAM_ENEMY and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100  then	
		local hp = minion.health
		local QDmg = getdmg("Q", minion, myHero)				
			if Ready(_Q) and hp <= QDmg and myHero.pos:DistanceTo(minion.pos) <= 1175 and self.Menu.Clear.UseQL:Value() then
				Control.CastSpell(HK_Q, minion)
			end	
			local count = GetMinionCount(275, minion)
			if Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 900 and self.Menu.Clear.UseW:Value() and count >= self.Menu.Clear.UseWM:Value() then
				Control.CastSpell(HK_W, minion)
			end  
		end
	end
end

function Morgana:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	local TEAM_JUNGLE = 300
		if minion.team == TEAM_JUNGLE and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 1175 and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion)
			end
			local count = GetMinionCount(275, minion)
			if Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 900 and self.Menu.JClear.UseW:Value() and count >= self.Menu.JClear.UseWM:Value() then
				Control.CastSpell(HK_W, minion)
			end  
		end
	end
end

------------------------------------------------------------------------------------------------------------

--Dmg Lib



local DamageReductionTable = {
  ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level] end},
  ["Urgot"] = {buff = "urgotswapdef", amount = function(target) return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level] end},
  ["Alistar"] = {buff = "Ferocious Howl", amount = function(target) return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level] end},
  ["Amumu"] = {buff = "Tantrum", amount = function(target) return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level] end, damageType = 1},
  ["Galio"] = {buff = "GalioIdolOfDurand", amount = function(target) return 0.5 end},
  ["Garen"] = {buff = "GarenW", amount = function(target) return 0.7 end},
  ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level] end},
  ["Annie"] = {buff = "MoltenShield", amount = function(target) return 1 - ({0.16,0.22,0.28,0.34,0.4})[target:GetSpellData(_E).level] end},
  ["Malzahar"] = {buff = "malzaharpassiveshield", amount = function(target) return 0.1 end}
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

local DamageLibTable = {

  ["Morgana"] = {  
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + 0.9 * source.ap end},
	{Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({8, 16, 24, 24, 40})[level] + 0.11 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.7 * source.ap end}

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


	


function OnLoad()
	Morgana()
	LoadUnits()
end
	
  


















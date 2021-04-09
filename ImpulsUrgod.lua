local Heroes = {"Urgot"}

if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"

--[[
-- [ update not enabled until proper rank ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "ImpulsUrgod.lua",
            Url = "https://raw.githubusercontent.com/Impuls/GoS/master/ImpulsUrgod.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "ImpulsUrgod.version",
            Url = "https://raw.githubusercontent.com/Impuls/GoS/master/ImpulsUrgod.version"
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
        
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print(Files.Version.Name .. ": Updated to " .. tostring(NewVersion) .. ". Please Reload with 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end
]]

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

----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------
    
local _atan = math.atan2
local _min = math.min
local _abs = math.abs
local _sqrt = math.sqrt
local _floor = math.floor
local _max = math.max
local _pow = math.pow
local _huge = math.huge
local _pi = math.pi
local _insert = table.insert
local _contains = table.contains
local _sort = table.sort
local _pairs = pairs
local _find = string.find
local _sub = string.sub
local _len = string.len
local LocalControlCastSpell = Control.CastSpell;
local LocalGetTickCount = GetTickCount;;
local LocalGameTimer = Game.Timer;
local LocalGameHeroCount = Game.HeroCount;
local LocalGameHero = Game.Hero;
local LocalGameMinionCount = Game.MinionCount;
local LocalGameMinion = Game.Minion;
local LocalGameTurretCount = Game.TurretCount;
local LocalGameTurret = Game.Turret;
local LocalGameWardCount = Game.WardCount;
local LocalGameWard = Game.Ward;
local LocalGameMissileCount = Game.MissileCount;
local LocalGameMissile = Game.Missile;
local LocalGameParticleCount = Game.ParticleCount;
local LocalGameParticle = Game.Particle;
local PredLoaded = false
local sqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local GameCanUseSpell = Game.CanUseSpell
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero

local CCSpells = {
	["AatroxW"] = {charName = "Aatrox", displayName = "Infernal Chains", slot = _W, type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 80, collision = true},
	["AhriSeduce"] = {charName = "Ahri", displayName = "Seduce", slot = _E, type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, collision = true},
	["AkaliR"] = {charName = "Akali", displayName = "Perfect Execution [First]", slot = _R, type = "linear", speed = 1800, range = 525, delay = 0, radius = 65, collision = false},
	["AkaliE"] = {charName = "Akali", displayName = "Shuriken Flip", slot = _E, type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 70, collision = true},	
	["Pulverize"] = {charName = "Alistar", displayName = "Pulverize", slot = _Q, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 365, collision = false},
	["BandageToss"] = {charName = "Amumu", displayName = "Bandage Toss", slot = _Q, type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, collision = true},
	["CurseoftheSadMummy"] = {charName = "Amumu", displayName = "Curse of the Sad Mummy", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 550, collision = false},
	["FlashFrostSpell"] = {charName = "Anivia", displayName = "Flash Frost",missileName = "FlashFrostSpell", slot = _Q, type = "linear", speed = 850, range = 1100, delay = 0.25, radius = 110, collision = false},
	["EnchantedCrystalArrow"] = {charName = "Ashe", displayName = "Enchanted Crystal Arrow", slot = _R, type = "linear", speed = 1600, range = 25000, delay = 0.25, radius = 130, collision = false},
	["AurelionSolQ"] = {charName = "AurelionSol", displayName = "Starsurge", slot = _Q, type = "linear", speed = 850, range = 25000, delay = 0, radius = 110, collision = false},
	["AzirR"] = {charName = "Azir", displayName = "Emperor's Divide", slot = _R, type = "linear", speed = 1400, range = 500, delay = 0.3, radius = 250, collision = false},
	["ApheliosR"] = {charName = "Aphelios", displayName = "Moonlight Vigil", slot = _R, type = "linear", speed = 2050, range = 1600, delay = 0.5, radius = 125, collision = false},	
	["BardQ"] = {charName = "Bard", displayName = "Cosmic Binding", slot = _Q, type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, collision = true},	
	["BardR"] = {charName = "Bard", displayName = "Tempered Fate", slot = _R, type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, collision = false},
	["BrandQ"] = {charName = "Brand", displayName = "Sear", slot = _Q, type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 60, collision = true},	
	["RocketGrab"] = {charName = "Blitzcrank", displayName = "Rocket Grab", slot = _Q, type = "linear", speed = 1800, range = 1150, delay = 0.25, radius = 140, collision = true},
	["BraumQ"] = {charName = "Braum", displayName = "Winter's Bite", slot = _Q, type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = true},
	["BraumR"] = {charName = "Braum", displayName = "Glacial Fissure", slot = _R, type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, collision = false},
	["CaitlynYordleTrap"] = {charName = "Caitlyn", displayName = "Yordle Trap", slot = _W, type = "circular", speed = MathHuge, range = 800, delay = 0.25, radius = 75, collision = false},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = _E, type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},
	["CassiopeiaW"] = {charName = "Cassiopeia", displayName = "Miasma", slot = _W, type = "circular", speed = 2500, range = 800, delay = 0.75, radius = 160, collision = false},
	["Rupture"] = {charName = "Chogath", displayName = "Rupture", slot = _Q, type = "circular", speed = MathHuge, range = 950, delay = 1.2, radius = 250, collision = false},
	["InfectedCleaverMissile"] = {charName = "DrMundo", displayName = "Infected Cleaver", slot = _Q, type = "linear", speed = 2000, range = 975, delay = 0.25, radius = 60, collision = true},
	["DravenDoubleShot"] = {charName = "Draven", displayName = "Double Shot", slot = _E, type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, collision = false},
	["DravenRCast"] = {charName = "Draven", displayName = "Whirling Death", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 0.25, radius = 160, collision = false},	
	["DianaQ"] = {charName = "Diana", displayName = "Crescent Strike", slot = _Q, type = "circular", speed = 1900, range = 900, delay = 0.25, radius = 185, collision = true},	
	["EkkoQ"] = {charName = "Ekko", displayName = "Timewinder", slot = _Q, type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, collision = false},
	["EkkoW"] = {charName = "Ekko", displayName = "Parallel Convergence", slot = _W, type = "circular", speed = MathHuge, range = 1600, delay = 3.35, radius = 400, collision = false},
	["EliseHumanE"] = {charName = "Elise", displayName = "Cocoon", slot = _E, type = "linear", speed = 1600, range = 1075, delay = 0.25, radius = 55, collision = true},
	["EzrealR"] = {charName = "Ezreal", displayName = "Trueshot Barrage", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 1, radius = 160, collision = true},	
	["FizzR"] = {charName = "Fizz", displayName = "Chum the Waters", slot = _R, type = "linear", speed = 1300, range = 1300, delay = 0.25, radius = 150, collision = false},
	["GalioE"] = {charName = "Galio", displayName = "Justice Punch", slot = _E, type = "linear", speed = 2300, range = 650, delay = 0.4, radius = 160, collision = false},
	["GnarQMissile"] = {charName = "Gnar", displayName = "Boomerang Throw", slot = _Q, type = "linear", speed = 2500, range = 1125, delay = 0.25, radius = 55, collision = false},
	["GnarBigQMissile"] = {charName = "Gnar", displayName = "Boulder Toss", slot = _Q, type = "linear", speed = 2100, range = 1125, delay = 0.5, radius = 90, collision = true},
	["GnarBigW"] = {charName = "Gnar", displayName = "Wallop", slot = _W, type = "linear", speed = MathHuge, range = 575, delay = 0.6, radius = 100, collision = false},
	["GnarR"] = {charName = "Gnar", displayName = "GNAR!", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 475, collision = false},
	["GragasQ"] = {charName = "Gragas", displayName = "Barrel Roll", slot = _Q, type = "circular", speed = 1000, range = 850, delay = 0.25, radius = 275, collision = false},
	["GragasR"] = {charName = "Gragas", displayName = "Explosive Cask", slot = _R, type = "circular", speed = 1800, range = 1000, delay = 0.25, radius = 400, collision = false},
	["GravesSmokeGrenade"] = {charName = "Graves", displayName = "Smoke Grenade", slot = _W, type = "circular", speed = 1500, range = 950, delay = 0.15, radius = 250, collision = false},
	["HeimerdingerE"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = _E, type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerEUlt"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = _E, type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["IreliaW2"] = {charName = "Irelia", displayName = "Defiant Dance", slot = _W, type = "linear", speed = MathHuge, range = 775, delay = 0.25, radius = 120, collision = false},
	["IreliaR"] = {charName = "Irelia", displayName = "Vanguard's Edge", slot = _R, type = "linear", speed = 2000, range = 950, delay = 0.4, radius = 160, collision = false},
	["IvernQ"] = {charName = "Ivern", displayName = "Rootcaller", slot = _Q, type = "linear", speed = 1300, range = 1075, delay = 0.25, radius = 80, collision = true},
	["IllaoiE"] = {charName = "Illaoi", displayName = "Test of Spirit", slot = _E, type = "linear", speed = 1900, range = 900, delay = 0.25, radius = 50, collision = true},	
	["IvernQ"] = {charName = "Ivern", displayName = "Rootcaller", slot = _Q, type = "linear", speed = 1300, range = 1075, delay = 0.25, radius = 80, collision = true},		
	["HowlingGaleSpell"] = {charName = "Janna", displayName = "Howling Gale", slot = _Q, type = "linear", speed = 667, range = 1750, delay = 0, radius = 100, collision = false},			
	["JarvanIVDragonStrike"] = {charName = "JarvanIV", displayName = "Dragon Strike", slot = _Q, type = "linear", speed = MathHuge, range = 770, delay = 0.4, radius = 70, collision = false},
	["JhinW"] = {charName = "Jhin", displayName = "Deadly Flourish", slot = _W, type = "linear", speed = 5000, range = 2550, delay = 0.75, radius = 40, collision = false},
	["JhinRShot"] = {charName = "Jhin", displayName = "Curtain Call", slot = _R, type = "linear", speed = 5000, range = 3500, delay = 0.25, radius = 80, collision = false},
	["JhinE"] = {charName = "Jhin", displayName = "Captive Audience", slot = _E, type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, collision = false},
	["JinxWMissile"] = {charName = "Jinx", displayName = "Zap!", slot = _W, type = "linear", speed = 3300, range = 1450, delay = 0.6, radius = 60, collision = true},
	["KarmaQ"] = {charName = "Karma", displayName = "Inner Flame", slot = _Q, type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 60, collision = true},
	["KarmaQMantra"] = {charName = "Karma", displayName = "Inner Flame [Mantra]", slot = _Q, origin = "linear", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 80, collision = true},
	["KayleQ"] = {charName = "Kayle", displayName = "Radiant Blast", slot = _Q, type = "linear", speed = 2000, range = 850, delay = 0.5, radius = 60, collision = false},
	["KaynW"] = {charName = "Kayn", displayName = "Blade's Reach", slot = _W, type = "linear", speed = MathHuge, range = 700, delay = 0.55, radius = 90, collision = false},
	["KhazixWLong"] = {charName = "Khazix", displayName = "Void Spike [Threeway]", slot = _W, type = "threeway", speed = 1700, range = 1000, delay = 0.25, radius = 70,angle = 23, collision = true},
	["KledQ"] = {charName = "Kled", displayName = "Beartrap on a Rope", slot = _Q, type = "linear", speed = 1600, range = 800, delay = 0.25, radius = 45, collision = true},
	["KogMawVoidOozeMissile"] = {charName = "KogMaw", displayName = "Void Ooze", slot = _E, type = "linear", speed = 1400, range = 1360, delay = 0.25, radius = 120, collision = false},
	["BlindMonkQOne"] = {charName = "Leesin", displayName = "Sonic Wave", slot = _Q, type = "linear", speed = 1800, range = 1100, delay = 0.25, radius = 60, collision = true},	
	["LeblancE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Standard]", slot = _E, type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancRE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Ultimate]", slot = _E, type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeonaZenithBlade"] = {charName = "Leona", displayName = "Zenith Blade", slot = _E, type = "linear", speed = 2000, range = 875, delay = 0.25, radius = 70, collision = false},
	["LeonaSolarFlare"] = {charName = "Leona", displayName = "Solar Flare", slot = _R, type = "circular", speed = MathHuge, range = 1200, delay = 0.85, radius = 300, collision = false},
	["LissandraQMissile"] = {charName = "Lissandra", displayName = "Ice Shard", slot = _Q, type = "linear", speed = 2200, range = 750, delay = 0.25, radius = 75, collision = false},
	["LuluQ"] = {charName = "Lulu", displayName = "Glitterlance", slot = _Q, type = "linear", speed = 1450, range = 925, delay = 0.25, radius = 60, collision = false},
	["LuxLightBinding"] = {charName = "Lux", displayName = "Light Binding", slot = _Q, type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 50, collision = false},
	["LuxLightStrikeKugel"] = {charName = "Lux", displayName = "Light Strike Kugel", slot = _E, type = "circular", speed = 1200, range = 1100, delay = 0.25, radius = 300, collision = true},
	["Landslide"] = {charName = "Malphite", displayName = "Ground Slam", slot = _E, type = "circular", speed = MathHuge, range = 0, delay = 0.242, radius = 400, collision = false},
	["MalzaharQ"] = {charName = "Malzahar", displayName = "Call of the Void", slot = _Q, type = "rectangular", speed = 1600, range = 900, delay = 0.5, radius = 400, radius2 = 100, collision = false},
	["MaokaiQ"] = {charName = "Maokai", displayName = "Bramble Smash", slot = _Q, type = "linear", speed = 1600, range = 600, delay = 0.375, radius = 110, collision = false},
	["MorganaQ"] = {charName = "Morgana", displayName = "Dark Binding", slot = _Q, type = "linear", speed = 1200, range = 1250, delay = 0.25, radius = 70, collision = true},
	["NamiQ"] = {charName = "Nami", displayName = "Aqua Prison", slot = _Q, type = "circular", speed = MathHuge, range = 875, delay = 1, radius = 180, collision = false},
	["NamiRMissile"] = {charName = "Nami", displayName = "Tidal Wave", slot = _R, type = "linear", speed = 850, range = 2750, delay = 0.5, radius = 250, collision = false},
	["NautilusAnchorDragMissile"] = {charName = "Nautilus", displayName = "Dredge Line", slot = _Q, type = "linear", speed = 2000, range = 925, delay = 0.25, radius = 90, collision = true},
	["NeekoQ"] = {charName = "Neeko", displayName = "Blooming Burst", slot = _Q, type = "circular", speed = 1500, range = 800, delay = 0.25, radius = 200, collision = false},
	["NeekoE"] = {charName = "Neeko", displayName = "Tangle-Barbs", slot = _E, type = "linear", speed = 1400, range = 1000, delay = 0.25, radius = 65, collision = false},
	["NunuR"] = {charName = "Nunu", displayName = "Absolute Zero", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 3, radius = 650, collision = false},
	["OlafAxeThrowCast"] = {charName = "Olaf", displayName = "Undertow", slot = _Q, type = "linear", speed = 1600, range = 1000, delay = 0.25, radius = 90, collision = false},
	["OrnnQ"] = {charName = "Ornn", displayName = "Volcanic Rupture", slot = _Q, type = "linear", speed = 1800, range = 800, delay = 0.3, radius = 65, collision = false},
	["OrnnE"] = {charName = "Ornn", displayName = "Searing Charge", slot = _E, type = "linear", speed = 1600, range = 800, delay = 0.35, radius = 150, collision = false},
	["OrnnRCharge"] = {charName = "Ornn", displayName = "Call of the Forge God", slot = _R, type = "linear", speed = 1650, range = 2500, delay = 0.5, radius = 200, collision = false},
	["PoppyQSpell"] = {charName = "Poppy", displayName = "Hammer Shock", slot = _Q, type = "linear", speed = MathHuge, range = 430, delay = 0.332, radius = 100, collision = false},
	["PoppyRSpell"] = {charName = "Poppy", displayName = "Keeper's Verdict", slot = _R, type = "linear", speed = 2000, range = 1200, delay = 0.33, radius = 100, collision = false},
	["PykeQMelee"] = {charName = "Pyke", displayName = "Bone Skewer [Melee]", slot = _Q, type = "linear", speed = MathHuge, range = 400, delay = 0.25, radius = 70, collision = false},
	["PykeQRange"] = {charName = "Pyke", displayName = "Bone Skewer [Range]", slot = _Q, type = "linear", speed = 2000, range = 1100, delay = 0.2, radius = 70, collision = true},
	["PykeE"] = {charName = "Pyke", displayName = "Phantom Undertow", slot = _E, type = "linear", speed = 3000, range = 25000, delay = 0, radius = 110, collision = false},
	["QiyanaR"] = {charName = "Qiyana", displayName = "Supreme Display of Talent", slot = _R, type = "linear", speed = 2000, range = 950, delay = 0.25, radius = 190, collision = false},	
	["RakanW"] = {charName = "Rakan", displayName = "Grand Entrance", slot = _W, type = "circular", speed = MathHuge, range = 650, delay = 0.7, radius = 265, collision = false},
	["RengarE"] = {charName = "Rengar", displayName = "Bola Strike", slot = _E, type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = true},
	["RumbleGrenade"] = {charName = "Rumble", displayName = "Electro Harpoon", slot = _E, type = "linear", speed = 2000, range = 850, delay = 0.25, radius = 60, collision = true},
	["SejuaniR"] = {charName = "Sejuani", displayName = "Glacial Prison", slot = _R, type = "linear", speed = 1600, range = 1300, delay = 0.25, radius = 120, collision = false},
	["ShyvanaTransformLeap"] = {charName = "Shyvana", displayName = "Transform Leap", slot = _R, type = "linear", speed = 700, range = 850, delay = 0.25, radius = 150, collision = false},
	["SionQ"] = {charName = "Sion", displayName = "Decimating Smash", slot = _Q, origin = "", type = "linear", speed = MathHuge, range = 750, delay = 2, radius = 150, collision = false},
	["SionE"] = {charName = "Sion", displayName = "Roar of the Slayer", slot = _E, type = "linear", speed = 1800, range = 800, delay = 0.25, radius = 80, collision = false},
	["SkarnerFractureMissile"] = {charName = "Skarner", displayName = "Fracture", slot = _E, type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = false},
	["SonaR"] = {charName = "Sona", displayName = "Crescendo", slot = _R, type = "linear", speed = 2400, range = 1000, delay = 0.25, radius = 140, collision = false},
	["SorakaQ"] = {charName = "Soraka", displayName = "Starcall", slot = _Q, type = "circular", speed = 1150, range = 810, delay = 0.25, radius = 235, collision = false},
	["SwainW"] = {charName = "Swain", displayName = "Vision of Empire", slot = _W, type = "circular", speed = MathHuge, range = 3500, delay = 1.5, radius = 300, collision = false},
	["SwainE"] = {charName = "Swain", displayName = "Nevermove", slot = _E, type = "linear", speed = 1800, range = 850, delay = 0.25, radius = 85, collision = false},
	["SylasE2"] = {charName = "Sylas", displayName = "Abduct", slot = _E, type = "linear", speed = 1600, range = 850, delay = 0.25, radius = 60, collision = true},	
	["TahmKenchQ"] = {charName = "TahmKench", displayName = "Tongue Lash", slot = _Q, type = "linear", speed = 2800, range = 800, delay = 0.25, radius = 70, collision = true},
	["TaliyahWVC"] = {charName = "Taliyah", displayName = "Seismic Shove", slot = _W, type = "circular", speed = MathHuge, range = 900, delay = 0.85, radius = 150, collision = false},
	["TaliyahR"] = {charName = "Taliyah", displayName = "Weaver's Wall", slot = _R, type = "linear", speed = 1700, range = 3000, delay = 1, radius = 120, collision = false},
	["ThreshE"] = {charName = "Thresh", displayName = "Flay", slot = _E, type = "linear", speed = MathHuge, range = 500, delay = 0.389, radius = 110, collision = true},
	["TristanaW"] = {charName = "Tristana", displayName = "Rocket Jump", slot = _W, type = "circular", speed = 1100, range = 900, delay = 0.25, radius = 300, collision = false},
	["UrgotQ"] = {charName = "Urgot", displayName = "Corrosive Charge", slot = _Q, type = "circular", speed = MathHuge, range = 800, delay = 0.6, radius = 180, collision = false},
	["UrgotE"] = {charName = "Urgot", displayName = "Disdain", slot = _E, type = "linear", speed = 1540, range = 475, delay = 0.45, radius = 100, collision = false},
	["UrgotR"] = {charName = "Urgot", displayName = "Fear Beyond Death", slot = _R, type = "linear", speed = 3200, range = 1600, delay = 0.4, radius = 80, collision = false},
	["VarusE"] = {charName = "Varus", displayName = "Hail of Arrows", slot = _E, type = "linear", speed = 1500, range = 925, delay = 0.242, radius = 260, collision = false},
	["VarusR"] = {charName = "Varus", displayName = "Chain of Corruption", slot = _R, type = "linear", speed = 1950, range = 1200, delay = 0.25, radius = 120, collision = false},
	["VelkozQ"] = {charName = "Velkoz", displayName = "Plasma Fission", slot = _Q, type = "linear", speed = 1300, range = 1050, delay = 0.25, radius = 50, collision = true},
	["VelkozE"] = {charName = "Velkoz", displayName = "Tectonic Disruption", slot = _E, type = "circular", speed = MathHuge, range = 800, delay = 0.8, radius = 185, collision = false},
	["ViktorGravitonField"] = {charName = "Viktor", displayName = "Graviton Field", slot = _W, type = "circular", speed = MathHuge, range = 800, delay = 1.75, radius = 270, collision = false},
	["WarwickR"] = {charName = "Warwick", displayName = "Infinite Duress", slot = _R, type = "linear", speed = 1800, range = 3000, delay = 0.1, radius = 55, collision = false},
	["XerathArcaneBarrage2"] = {charName = "Xerath", displayName = "Arcane Barrage", slot = _W, type = "circular", speed = MathHuge, range = 1000, delay = 0.75, radius = 235, collision = false},
	["XerathMageSpear"] = {charName = "Xerath", displayName = "Mage Spear", slot = _E, type = "linear", speed = 1400, range = 1050, delay = 0.2, radius = 60, collision = true},
	["XinZhaoW"] = {charName = "XinZhao", displayName = "Wind Becomes Lightning", slot = _W, type = "linear", speed = 5000, range = 900, delay = 0.5, radius = 40, collision = false},
	["ZacQ"] = {charName = "Zac", displayName = "Stretching Strikes", slot = _Q, type = "linear", speed = 2800, range = 800, delay = 0.33, radius = 120, collision = false},
	["ZiggsW"] = {charName = "Ziggs", displayName = "Satchel Charge", slot = _W, type = "circular", speed = 1750, range = 1000, delay = 0.25, radius = 240, collision = false},
	["ZiggsE"] = {charName = "Ziggs", displayName = "Hexplosive Minefield", slot = _E, type = "circular", speed = 1800, range = 900, delay = 0.25, radius = 250, collision = false},
	["ZileanQ"] = {charName = "Zilean", displayName = "Time Bomb", slot = _Q, type = "circular", speed = MathHuge, range = 900, delay = 0.8, radius = 150, collision = false},
	["ZoeE"] = {charName = "Zoe", displayName = "Sleepy Trouble Bubble", slot = _E, type = "linear", speed = 1700, range = 800, delay = 0.3, radius = 50, collision = true},
	["ZyraE"] = {charName = "Zyra", displayName = "Grasping Roots", slot = _E, type = "linear", speed = 1150, range = 1100, delay = 0.25, radius = 70, collision = false},
	["ZyraR"] = {charName = "Zyra", displayName = "Stranglethorns", slot = _R, type = "circular", speed = MathHuge, range = 700, delay = 2, radius = 500, collision = false},
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
	["TristanaR"] = {charName = "Tristana", slot = _R, type = "targeted", displayName = "Buster Shot", range = 669}
}

local EnemyTraps = {}

function GetGameObjects()
    --EnemyHeroes = {}
    print(Game.ObjectCount())
    for i = 1, Game.ObjectCount() do
        local GameObject = Game.Object(i)
        if GameObject.isEnemy then
            if GameObject.charName:match("Cait") then
                if EnemyTraps[GameObject.name] == nil then
                    print(GameObject.isEnemy)
                    print(GameObject.type)
                    print(GameObject.name)
                    print(GameObject.pos)
                    print(EnemyTraps[GameObject.name])
                    Draw.Circle(GameObject.pos, GameObject.boundingRadius, 10, Draw.Color(255, 255, 255, 255))
                    Draw.Text(GameObject.name, 17, GameObject.pos2D.x - 45, GameObject.pos2D.y + 10, Draw.Color(0xFF32CD32))
                    EnemyTraps[GameObject.name] = GameObject.name
                end
            end
        end
    end
    if Game.ObjectCount() == 0 then
        EnemyTraps = {}
    end
--return EnemyHeroes
end

local units = {}

for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    units[i] = {unit = unit, spell = nil}
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

function IsReady(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end

function ValidTarget(target, range)
    range = range and range or math.huge
    return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function GetDistance(p1, p2)
    return _sqrt(_pow((p2.x - p1.x), 2) + _pow((p2.y - p1.y), 2) + _pow((p2.z - p1.z), 2))
end

function GetDistance(pos1, pos2)
 return sqrt(GetDistanceSqr(pos1, pos2))
end

function GetDistance2D(p1, p2)
    return _sqrt(_pow((p2.x - p1.x), 2) + _pow((p2.y - p1.y), 2))
end

function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
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

function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

function SetMovement(bool)
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

local _OnWaypoint = {}
function OnWaypoint(unit)
    if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo, speed = unit.ms, time = LocalGameTimer()} end
    if _OnWaypoint[unit.networkID].pos ~= unit.posTo then
        _OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo, speed = unit.ms, time = LocalGameTimer()}
        DelayAction(function()
            local time = (LocalGameTimer() - _OnWaypoint[unit.networkID].time)
            local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos, unit.pos) / (LocalGameTimer() - _OnWaypoint[unit.networkID].time)
            if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos, _OnWaypoint[unit.networkID].pos) > 200 then
                _OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos, unit.pos) / (LocalGameTimer() - _OnWaypoint[unit.networkID].time)
            end
        end, 0.05)
    end
    return _OnWaypoint[unit.networkID]
end

function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = {x = ax + rL * (bx - ax), y = ay + rL * (by - ay)}
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), y = ay + rS * (by - ay)}
    return pointSegment, pointLine, isOnSegment
end

function GetMinionCollision(StartPos, EndPos, Width, Target)
    local Count = 0
    for i = 1, LocalGameMinionCount() do
        local m = LocalGameMinion(i)
        if m and not m.isAlly then
            local w = Width + m.boundingRadius
            local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, m.pos)
            if isOnSegment and GetDistanceSqr(pointSegment, m.pos) < w ^ 2 and GetDistanceSqr(StartPos, EndPos) > GetDistanceSqr(StartPos, m.pos) then
                Count = Count + 1
            end
        end
    end
    return Count
end

function GetEnemyHeroes()
    EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(EnemyHeroes, Hero)
        end
    end
    return EnemyHeroes
end

function GetMinions(range, typ) -- 1 = Enemy / 2 = Ally / 3 = Monsters
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

function IsUnderTurret(unit)
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i);
        if turret and turret.isEnemy and turret.valid and turret.health > 0 then
            if GetDistance(unit, turret.pos) <= 850 then
                return true
            end
        end
    end
    return false
end

function GetDashPos(unit)
    return myHero.pos + (unit.pos - myHero.pos):Normalized() * 500
end

-- Spell data
function GetSpellWName()
    return myHero:GetSpellData(_W).name
end

function GetSpellEName()
    return myHero:GetSpellData(_E).name
end

function GetSpellRName()
    return myHero:GetSpellData(_R).name
end

function QDmg()
    if myHero:GetSpellData(_Q).level == 0 then
        local Dmg1 = (({25, 70, 115, 160, 205})[1] + 0.70 * myHero.totalDamage)
        return Dmg1
    else
        local Dmg1 = (({25, 70, 115, 160, 205})[myHero:GetSpellData(_Q).level] + 0.70 * myHero.totalDamage)
        return Dmg1
    end
end

function WDmg()
    if myHero:GetSpellData(_W).level == 0 then
        local Dmg1 = (({0.20, 0.24, 0.28, 0.32, 0.36})[1] * myHero.totalDamage + 12)
        return Dmg1
    else
        local Dmg1 = (({0.20, 0.24, 0.28, 0.32, 0.36})[myHero:GetSpellData(_W).level] * myHero.totalDamage + 12)
        return Dmg1
    end
end

function EDmg()
    if myHero:GetSpellData(_E).level == 0 then
        local Dmg1 = (({60, 80, 100, 120, 140})[1] + 1.00 * myHero.totalDamage)
        return Dmg1
    else
        local Dmg1 = (({60, 80, 100, 120, 140})[myHero:GetSpellData(_E).level] + 1.00 * myHero.totalDamage)
        return Dmg1
    end
end

function RDmg()
    if myHero:GetSpellData(_R).level == 0 then
        local Dmg1 = (({100, 225, 350})[1] + 0.5 * myHero.bonusDamage)
        return Dmg1
    else
        local Dmg1 = (({100, 225, 350})[myHero:GetSpellData(_R).level] + 0.5 * myHero.bonusDamage)
        return Dmg1
    end
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

function GetEbTarget()
    for i, enemy in pairs(GetEnemyHeroes()) do
        if GotBuff(enemy, "AkaliEMis") then
            return enemy
        end
    end
end

function IsRecalling()
    for K, Buff in pairs(GetBuffs(myHero)) do
        if Buff.name == "recall" and Buff.duration > 0 then
            return true
        end
    end
    return false
end

function GetPercentHP(unit)
    if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got " .. type(unit) .. ")") end
    return 100 * unit.health / unit.maxHealth
end

function IsImmune(unit)
    if type(unit) ~= "userdata" then error("{IsImmune}: bad argument #1 (userdata expected, got " .. type(unit) .. ")") end
    for i, buff in pairs(GetBuffs(unit)) do
        if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and GetPercentHP(unit) <= 10 then
            return true
        end
        if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then
            return true
        end
    end
    return false
end

class "Urgot"

function Urgot:OnProcessSpell()
    for i = 1, #units do
        local unit = units[i].unit
        local last = units[i].spell
        local spell = unit.activeSpell
        if spell and last ~= (spell.name .. spell.startTime) and unit.isChanneling then
            units[i].spell = spell.name .. spell.startTime
            --
            --print(unit)
            print(spell.name)
            --print(spell.placementPos)
            --print(spell.range)
            --print(spell.startPos)
            local startPos = Vector(unit.activeSpell.startPos)
            local placementPos = Vector(unit.activeSpell.placementPos)
            local unitPos = Vector(unit.pos)
            --local sRange = self.SpellsE[unit.activeSpell.name].range
            local sRange = spell.range
            local endPos = self:CalculateEndPos(startPos, placementPos, unitPos, sRange)
            print(endPos)
            Draw.Circle(endPos, 20, 10, Draw.Color(255, 255, 255, 255))
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

local HeroIcon = "https://www.mobafire.com/images/champion/icon/urgot.png"
local IgniteIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/f/f4/Ignite.png"
local QIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/0/0f/Corrosive_Charge.png"
local WIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/a/aa/Purge.png"
local EIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/5/53/Disdain.png"
local RIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/6/60/Fear_Beyond_Death.png"
local R2Icon = "https://static.wikia.nocookie.net/leagueoflegends/images/4/44/Fear_Beyond_Death_2.png"
local IS = {}
local Spells = {
    ["Aatrox"] = {"AatroxE"},
    ["Ahri"] = {"AhriOrbofDeception", "AhriFoxFire", "AhriSeduce", "AhriTumble"},
    ["Akali"] = {"AkaliMota"},
    ["Amumu"] = {"BandageToss"},
    ["Anivia"] = {"FlashFrostSpell", "Frostbite"},
    ["Annie"] = {"Disintegrate"},
    ["Ashe"] = {"Volley", "EnchantedCrystalArrow"},
    ["AurelionSol"] = {"AurelionSolQ"},
    ["Bard"] = {"BardQ"},
    ["Blitzcrank"] = {"RocketGrab"},
    ["Brand"] = {"BrandQ", "BrandR"},
    ["Braum"] = {"BraumQ", "BraumR"},
    ["Caitlyn"] = {"CaitlynPiltoverPeacemaker", "CaitlynEntrapment", "CaitlynAceintheHole"},
    ["Cassiopeia"] = {"CassiopeiaW", "CassiopeiaTwinFang"},
    ["Corki"] = {"PhosphorusBomb", "MissileBarrageMissile", "MissileBarrageMissile2"},
    ["Diana"] = {"DianaArc", "DianaOrbs"},
    ["DrMundo"] = {"InfectedCleaverMissileCast"},
    ["Draven"] = {"DravenDoubleShot", "DravenRCast"},
    ["Ekko"] = {"EkkoQ"},
    ["Elise"] = {"EliseHumanQ", "EliseHumanE"},
    ["Evelynn"] = {"EvelynnQ"},
    ["Ezreal"] = {"EzrealMysticShot", "EzrealEssenceFlux", "EzrealArcaneShift", "EzrealTrueshotBarrage"},
    ["Fiddlesticks"] = {"FiddlesticksDarkWind"},
    ["Fiora"] = {"FioraW"},
    ["Fizz"] = {"FizzR"},
    ["Galio"] = {"GalioQ"},
    ["Gangplank"] = {"GangplankQ"},
    ["Gnar"] = {"GnarQMissile", "GnarBigQMissile"},
    ["Gragas"] = {"GragasQ", "GragasR"},
    ["Graves"] = {"GravesQLineSpell", "GravesSmokeGrenade", "GravesChargeShot"},
    ["Hecarim"] = {"HecarimUlt"},
    ["Heimerdinger"] = {"HeimerdingerQ", "HeimerdingerW", "HeimerdingerE", "HeimerdingerEUlt"},
    ["Illaoi"] = {"IllaoiE"},
    ["Irelia"] = {"IreliaR"},
    ["Ivern"] = {"IvernQ"},
    ["Janna"] = {"HowlingGale", "SowTheWind"},
    ["Jayce"] = {"JayceShockBlast", "JayceShockBlastWallMis"},
    ["Jhin"] = {"JhinQ", "JhinW", "JhinR"},
    ["Jinx"] = {"JinxW", "JinxE", "JinxR"},
    ["Kaisa"] = {"KaisaQ", "KaisaW"},
    ["Kalista"] = {"KalistaMysticShot"},
    ["Karma"] = {"KarmaQ", "KarmaQMantra"},
    ["Kassadin"] = {"NullLance"},
    ["Katarina"] = {"KatarinaQ", "KatarinaR"},
    ["Kayle"] = {"JudicatorReckoning"},
    ["Kennen"] = {"KennenShurikenHurlMissile1"},
    ["Khazix"] = {"KhazixW", "KhazixWLong"},
    ["Kindred"] = {"KindredQ", "KindredE"},
    ["Kled"] = {"KledQ", "KledQRider"},
    ["KogMaw"] = {"KogMawQ", "KogMawVoidOoze"},
    ["Leblanc"] = {"LeblancQ", "LeblancE", "LeblancRQ", "LeblancRE"},
    ["Leesin"] = {"BlinkMonkQOne"},
    ["Leona"] = {"LeonaZenithBlade"},
    ["Lissandra"] = {"LissandraQMissile", "LissandraEMissile"},
    ["Lucian"] = {"LucianW", "LucianRMis"},
    ["Lulu"] = {"LuluQ", "LuluW"},
    ["Lux"] = {"LuxLightBinding", "LuxPrismaticWave", "LuxLightStrikeKugel"},
    ["Malphite"] = {"SeismicShard"},
    ["Maokai"] = {"MaokaiQ", "MaokaiR"},
    ["MissFortune"] = {"MissFortuneRicochetShot", "MissFortuneBulletTime"},
    ["Morgana"] = {"DarkBindingMissile"},
    ["Nami"] = {"NamiQ", "NamiW", "NamiRMissile"},
    ["Nautilus"] = {"NautilusAnchorDragMissile"},
    ["Nidalee"] = {"JavelinToss"},
    ["Nocturne"] = {"NocturneDuskbringer"},
    ["Nunu"] = {"IceBlast"},
    ["Olaf"] = {"OlafAxeThrowCast"},
    ["Orianna"] = {"OrianaIzunaCommand", "OrianaRedactCommand"},
    ["Ornn"] = {"OrnnQ", "OrnnR", "OrnnRCharge"},
    ["Pantheon"] = {"PantheonQ"},
    ["Poppy"] = {"PoppyRSpell"},
    ["Pyke"] = {"PykeQRange"},
    ["Quinn"] = {"QuinnQ"},
    ["Rakan"] = {"RakanQ"},
    ["Reksai"] = {"RekSaiQBurrowed"},
    ["Rengar"] = {"RengarE"},
    ["Riven"] = {"RivenIzunaBlade"},
    ["Rumble"] = {"RumbleGrenade"},
    ["Ryze"] = {"RyzeQ", "RyzeE"},
    ["Sejuani"] = {"SejuaniE", "SejuaniR"},
    ["Shaco"] = {"TwoShivPoison"},
    ["Shyvana"] = {"ShyvanaFireball", "ShyvanaFireballDragon2"},
    ["Sion"] = {"SionE"},
    ["Sivir"] = {"SivirQ"},
    ["Skarner"] = {"SkarnerFractureMissile"},
    ["Sona"] = {"SonaQ", "SonaR"},
    ["Swain"] = {"SwainE"},
    ["Syndra"] = {"SyndraR"},
    ["TahmKench"] = {"TahmKenchQ"},
    ["Taliyah"] = {"TaliyahQ"},
    ["Talon"] = {"TalonW", "TalonR"},
    ["Teemo"] = {"BlindingDart", "TeemoRCast"},
    ["Thresh"] = {"ThreshQInternal"},
    ["Tristana"] = {"TristanaE", "TristanaR"},
    ["TwistedFate"] = {"WildCards"},
    ["Twitch"] = {"TwitchVenomCask"},
    ["Urgot"] = {"UrgotQ", "UrgotR"},
    ["Varus"] = {"VarusQ", "VarusR"},
    ["Vayne"] = {"VayneCondemn", "VayneCondemnMissile"},
    ["Veigar"] = {"VeigarBalefulStrike", "VeigarR"},
    ["VelKoz"] = {"VelKozQ", "VelkozQMissileSplit", "VelKozW", "VelKozE"},
    ["Viktor"] = {"ViktorPowerTransfer", "ViktorDeathRay"},
    ["Vladimir"] = {"VladimirE"},
    ["Xayah"] = {"XayahQ", "XayahE", "XayahR"},
    ["Xerath"] = {"XerathMageSpear"},
    ["Yasuo"] = {"YasuoQ3W"},
    ["Yorick"] = {"YorickE"},
    ["Zac"] = {"ZacQ"},
    ["Zed"] = {"ZedQ"},
    ["Ziggs"] = {"ZiggsQ", "ZiggsW", "ZiggsE"},
    ["Zilean"] = {"ZileanQ", "ZileanQAttachAudio"},
    ["Zoe"] = {"ZoeQMissile", "ZoeQRecast", "ZoeE"},
    ["Zyra"] = {"ZyraE"},
}

function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = {x = ax + rL * (bx - ax), y = ay + rL * (by - ay)}
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), y = ay + rS * (by - ay)}
    return pointSegment, pointLine, isOnSegment
end

local Version, Author, LVersion = "v1", "Impuls", "0.01"

function Urgot:LoadMenu()
    
    self.Spellx = nil
    
    self.Collision = nil
    
    self.CollisionSpellName = nil
        --Menu
    self.UrgotMenu = MenuElement({type = MENU, id = "Urgot", name = "Impuls's Urgod", leftIcon = HeroIcon})
        --Harass
    self.UrgotMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
        self.UrgotMenu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = QIcon})
        self.UrgotMenu.Harass:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = WIcon})
        --Combo
    self.UrgotMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
        self.UrgotMenu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = QIcon})
        self.UrgotMenu.Combo:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = WIcon})
        self.UrgotMenu.Combo:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = EIcon})
        self.UrgotMenu.Combo:MenuElement({id = "UseR", name = "Use R is enemy killable", value = true, leftIcon = RIcon})
        --KillSteal
    self.UrgotMenu:MenuElement({id = "KillSteal", name = "KillSteal", type = MENU})
        self.UrgotMenu.KillSteal:MenuElement({id = "UseIgnite", name = "Use Ignite", value = true, leftIcon = IgniteIcon})
        self.UrgotMenu.KillSteal:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = QIcon})
        self.UrgotMenu.KillSteal:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = WIcon})
        self.UrgotMenu.KillSteal:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = EIcon})
        self.UrgotMenu.KillSteal:MenuElement({id = "UseR", name = "Use R", value = true, leftIcon = EIcon})
        --AutoLevel
    self.UrgotMenu:MenuElement({type = MENU, id = "AutoLevel", name =  myHero.charName.." AutoLevel Spells"})
        self.UrgotMenu.AutoLevel:MenuElement({id = "on", name = "Enabled", value = true})
        self.UrgotMenu.AutoLevel:MenuElement({id = "LvL", name = "AutoLevel start -->", value = 3, min = 1, max = 6, step = 1})
        self.UrgotMenu.AutoLevel:MenuElement({id = "delay", name = "Delay for Level up", value = 2, min = 0 , max = 10, step = 0.5, identifier = "sec"})
        self.UrgotMenu.AutoLevel:MenuElement({id = "Order", name = "Skill Order", value = 1, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})
        --Escape
    self.UrgotMenu:MenuElement({id = "Escape", name = "Escape", type = MENU})
    self.UrgotMenu.Escape:MenuElement({id = "UseE", name = "Use E", value = true})
    	--Prediction
	self.UrgotMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.UrgotMenu.Pred:MenuElement({name = " ", drop = {"After change Prediction Type press 2xF6"}})	
	self.UrgotMenu.Pred:MenuElement({id = "Change", name = "Change Prediction Type", value = 4, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction", "InternalPrediction"}})	
	self.UrgotMenu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})
	self.UrgotMenu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
	self.UrgotMenu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
        --Drawings
    self.UrgotMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
        self.UrgotMenu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
        self.UrgotMenu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = false})
        self.UrgotMenu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
        self.UrgotMenu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
        self.UrgotMenu.Drawings:MenuElement({id = "DrawAA", name = "Draw Killable AAs", value = false})
        self.UrgotMenu.Drawings:MenuElement({id = "DrawKS", name = "Draw Killable Skills", value = true})
        self.UrgotMenu.Drawings:MenuElement({id = "DrawJng", name = "Draw Jungler Info", value = true})
        --Version
    self.UrgotMenu:MenuElement({id = "blank", type = SPACE, name = ""})
    self.UrgotMenu:MenuElement({id = "blank", type = SPACE, name = "Script Ver: " .. Version .. " - LoL Ver: " .. LVersion .. ""})
    self.UrgotMenu:MenuElement({id = "blank", type = SPACE, name = "by " .. Author .. ""})
end

function Urgot:LoadSpells()
    UrgotQ = {delay = 0.25, speed = math.huge, radius = 210, range = 800}
    UrgotW = {radius = 490, range = 490}
    UrgotE = {delay = 0.45, speed = 1200, radius = 50, range = 445}
    UrgotR = {delay = 0.5, speed = 3200, range = 2500, radius = 150}

--["UrgotQ"]={charName="Urgot",slot=_Q,type="circular",speed=math.huge,range=800,delay=0.25,radius=210,hitbox=true,aoe=true,cc=true,collision=false},
--["UrgotE"]={charName="Urgot",slot=_E,type="linear",speed=1200,range=450,delay=0.45,radius=100,hitbox=true,aoe=true,cc=true,collision=false},
--["UrgotR"]={charName="Urgot",slot=_R,type="linear",speed=3200,range=2500,delay=0.5,radius=160,hitbox=true,aoe=false,cc=true,collision=false},
end

function Urgot:__init()
    Item_HK = {}
    self:LoadMenu()
    self:LoadSpells()
    self.SpellsE = {
        ["ThreshRPenta"] = {charName = "Thresh", range = 30, delay = 5.00, radius = 450, collision = false},
        ["VeigarEventHorizon"] = {charName = "Veigar", range = 725, delay = 3.50, radius = 390, collision = false},
        ["YasuoWMovingWall"] = {charName = "Yasuo", range = 400, delay = 3.75, radius = 100, collision = false},
    }
    self.Detected = {}
    self.levelUP = false		
    Callback.Add("Tick", function()self:Tick() end)
    Callback.Add("Draw", function()self:Draw() end)
--Callback.Add("Tick", OnProcessSpell)
end

function Urgot:Tick()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true or ExtLibEvade and ExtLibEvade.Evading == true then return end
    
    if self.Detected[1] == nil then
        self.Collision = false
        self.CollisionSpellName = nil
    end
    
    Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
    
    self:Escape()
    
    self:Action()
    self:ProcessSpell(GetEnemyHeroes())
    if Game.IsOnTop() then
		self:AutoLevelStart()
	end	
    if not PredLoaded then
		DelayAction(function()
			if self.UrgotMenu.Pred.Change:Value() == 1 then
				require('GamsteronPrediction')
				PredLoaded = true
			elseif self.UrgotMenu.Pred.Change:Value() == 2 then
				require('PremiumPrediction')
				PredLoaded = true
			else 
				require('GGPrediction')
				PredLoaded = true					
			end
		end, 1)	
	end
	DelayAction(function()
		if self.UrgotMenu.Pred.Change:Value() == 1 then
			self.QData = {Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 210, Range = 800, Speed = math.huge, Collision = false, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
			self.WData = {Type = _G.SPELLTYPE_CIRCLE, Delay = 0.00, Radius = 490, Range = 490, Speed = 2000, Collision = false, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
			self.EData = {Type = _G.SPELLTYPE_LINE, Delay = 0.45, Radius = 80, Range = 450, Speed = 1200, Collision = false, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
			self.RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.50, Radius = 160, Range = 1150, Speed =  3200, Collision = true, MaxCollision = 1, CollisionTypes = {_G.COLLISION_ENEMYHERO}}
        end
		if self.UrgotMenu.Pred.Change:Value() == 2 then
			self.QspellData = {speed = math.huge, range = 1025, delay = 0.25, radius = 210, type = "circular"}
            self.WspellData = {speed = 2000, range = 1025, delay = 0.00, radius = 490, type = "circular"}
            self.EspellData = {speed = 1200, range = 1025, delay = 0.45, radius = 80, collision = {"minion"}, type = "linear"}
            self.RspellData = {speed = 3200, range = 1025, delay = 0.50, radius = 160, type = "linear"}
		end
		if self.UrgotMenu.Pred.Change:Value() == 3 then  
            self.QPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 210, Range = 800, Speed = MathHuge, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
            self.WPrediction = GGPrediction:SpellPrediction({Delay = 0.00, Radius = 490, Range = 490, Speed = 2000, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
            self.EPrediction = GGPrediction:SpellPrediction({Delay = 0.45, Radius = 80,  Range = 450, Speed = 1200, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
            self.RPrediction = GGPrediction:SpellPrediction({Delay = 0.50, Radius = 160, Range = 1150, Speed = 3200, Collision = true, CollisionTypes = {GGPrediction.COLLISION_ENEMYHERO}, Type = GGPrediction.SPELLTYPE_LINE})
        end
            if self.UrgotMenu.Pred.Change:Value() == 4 then 
        end
	end, 1.2)	

    self:KillSteal()
    
    if GetMode() == "Harass" then
        self:Harass()
    end
    if GetMode() == "Combo" then
        self:Combo()
    end
    if GetMode() == "Flee" then
        self:Escape()
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

		if (actualLevel == 18 and levelPoints == 0) or self.UrgotMenu.AutoLevel.LvL:Value() > actualLevel then return end
	
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
				elseif actualLevel == 2 or actualLevel == 8 or actualLevel == 10 or actualLevel == 12 or actualLevel == 13 then
					Control.KeyDown(HK_LUS)
					Control.KeyDown(Spell2)
					Control.KeyUp(Spell2)
					Control.KeyUp(HK_LUS)
				elseif actualLevel == 3 or actualLevel == 14 or actualLevel == 15 or actualLevel == 17 or actualLevel == 18 then				
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

function Urgot:CollisionX(myHeroPos, dangerousPos, unitPos, radius)
    local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(Vector(myHeroPos), Vector(unitPos), Vector(dangerousPos))
    if isOnSegment and GetDistanceSqr(pointSegment, Vector(dangerousPos)) < (myHero.boundingRadius * 2 + radius) ^ 2 then
        return true
    else
        return false
    end
end

function Urgot:Action()
    for _, spell in pairs(self.Detected) do
        local delay = self.SpellsE[spell.name].delay
        local radius = self.SpellsE[spell.name].radius
        if spell.startTime + delay > Game.Timer() then
            if GetDistance(myHero.pos, spell.endPos) < (radius + myHero.boundingRadius) or GetDistance(spell.source, spell.endPos) < (radius + 100) or self:CollisionX(myHero.pos, spell.endPos, spell.source, radius) then
                --print("Yes")
                self.Collision = true
                self.CollisionSpellName = spell.name
            else
                --print("No")
                self.Collision = false
            end
        else
            table.remove(self.Detected, _)
        end
    end
--print("No")
--self.Collision = false
end

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

function Urgot:ProcessSpell(units)
    for i = 1, #units do
        local unit = units[i]
        if unit and unit.activeSpell and unit.activeSpell.isChanneling then
            --print(unit.activeSpell.name)
            if self.SpellsE and self.SpellsE[unit.activeSpell.name] then
                local startPos = Vector(unit.activeSpell.startPos)
                local placementPos = Vector(unit.activeSpell.placementPos)
                local unitPos = Vector(unit.pos)
                local sRange = self.SpellsE[unit.activeSpell.name].range
                local endPos = self:CalculateEndPos(startPos, placementPos, unitPos, sRange)
                spell = {source = unitPos, startPos = startPos, endPos = endPos, name = unit.activeSpell.name, startTime = Game.Timer()}
                table.insert(self.Detected, spell)
            end
        end
    end
end

function Urgot:Escape()
    for i = 1, Game.HeroCount() do
        local h = Game.Hero(i);
        if h.isEnemy then
            if h.activeSpell.valid and h.activeSpell.range > 0 then
                local t = Spells[h.charName]
                if t then
                    for j = 1, #t do
                        if h.activeSpell.name == t[j] then
                            if IS[h.networkID] == nil then
                                IS[h.networkID] = {
                                    sPos = h.activeSpell.startPos,
                                    ePos = h.activeSpell.startPos + Vector(h.activeSpell.startPos, h.activeSpell.placementPos):Normalized() * h.activeSpell.range,
                                    radius = h.activeSpell.width or 100,
                                    speed = h.activeSpell.speed or 9999,
                                    startTime = h.activeSpell.startTime
                                }
                            end
                        end
                    end
                end
            end
        end
    end
    for key, v in pairs(IS) do
        local SpellHit = v.sPos + Vector(v.sPos, v.ePos):Normalized() * GetDistance(myHero.pos, v.sPos)
        local SpellPosition = v.sPos + Vector(v.sPos, v.ePos):Normalized() * (v.speed * (Game.Timer() - v.startTime) * 3)
        local dodge = SpellPosition + Vector(v.sPos, v.ePos):Normalized() * (v.speed * 0.1)
        if GetDistanceSqr(SpellHit, SpellPosition) <= GetDistanceSqr(dodge, SpellPosition) and GetDistance(SpellHit, v.sPos) - v.radius - myHero.boundingRadius <= GetDistance(v.sPos, v.ePos) then
            if GetDistanceSqr(myHero.pos, SpellHit) < (v.radius + myHero.boundingRadius) ^ 2 then
                if self.UrgotMenu.Escape.UseE:Value() then
                    if IsReady(_E) then
                        local castPos = myHero.pos + Vector(myHero.pos, v.sPos):Normalized() * 100
                        Control.CastSpell(HK_E, castPos * -1)
                    end
                end
            end
        end
        if (GetDistanceSqr(SpellPosition, v.sPos) >= GetDistanceSqr(v.sPos, v.ePos)) then
            IS[key] = nil
        end
    end
end

function Urgot:KillSteal()
    for i, enemy in pairs(GetEnemyHeroes()) do
        if self.UrgotMenu.KillSteal.UseIgnite:Value() then
            local IgniteDmg = (55 + 25 * myHero.levelData.lvl)
            if ValidTarget(enemy, 600) and enemy.health + enemy.shieldAD < IgniteDmg then
                if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and IsReady(SUMMONER_1) then
                    Control.CastSpell(HK_SUMMONER_1, enemy)
                elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and IsReady(SUMMONER_2) then
                    Control.CastSpell(HK_SUMMONER_2, enemy)
                end
            end
        end
    end
    if self.UrgotMenu.KillSteal.UseQ:Value() then
        if IsReady(_Q) then
            for i, enemy in pairs(GetEnemyHeroes()) do
                if ValidTarget(enemy, UrgotQ.range) and enemy.health < QDmg() then
                    LocalControlCastSpell(HK_Q, enemy)
                end
            end
        end
    end
    if self.UrgotMenu.KillSteal.UseW:Value() then
        if IsReady(_W) then
            for i, enemy in pairs(GetEnemyHeroes()) do
                if ValidTarget(enemy, UrgotW.range) and enemy.health < WDmg() then
                    LocalControlCastSpell(HK_W, enemy)
                end
            end
        end
    end
    if self.UrgotMenu.KillSteal.UseE:Value() then
        if IsReady(_E) then
            for i, enemy in pairs(GetEnemyHeroes()) do
                if ValidTarget(enemy, UrgotE.range) and enemy.health < EDmg() then
                    LocalControlCastSpell(HK_E, enemy)
                end
            end
        end
    end
    if self.UrgotMenu.KillSteal.UseR:Value() then
        if IsReady(_R) then
            for i, enemy in pairs(GetEnemyHeroes()) do
                if ValidTarget(enemy, UrgotR.range) and (enemy.health - RDmg()) / enemy.maxHealth <= 24 / 100 then
                    --LocalControlCastSpell(HK_R, enemy)
                    local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, enemy, UrgotR.range, UrgotR.delay, UrgotR.speed, UrgotR.radius, false)
                    if hitChance and hitChance >= 2 then
                        self:CastR(enemy, aimPosition)
                    end
                end
            end
        end
    end
end

function Urgot:Draw()
    if myHero.dead then return end
    if self.UrgotMenu.Drawings.DrawQ:Value() then Draw.Circle(myHero.pos, UrgotQ.range, 1, Draw.Color(255, 0, 191, 255)) end
    if self.UrgotMenu.Drawings.DrawW:Value() then Draw.Circle(myHero.pos, UrgotW.range, 1, Draw.Color(255, 65, 105, 225)) end
    if self.UrgotMenu.Drawings.DrawE:Value() then Draw.Circle(myHero.pos, UrgotE.range, 1, Draw.Color(255, 30, 144, 255)) end
    if self.UrgotMenu.Drawings.DrawR:Value() then Draw.Circle(myHero.pos, UrgotR.range, 1, Draw.Color(255, 0, 0, 255)) end
    
    for i, enemy in pairs(GetEnemyHeroes()) do
        if self.UrgotMenu.Drawings.DrawJng:Value() then
            if enemy:GetSpellData(SUMMONER_1).name == "SummonerSmite" or enemy:GetSpellData(SUMMONER_2).name == "SummonerSmite" then
                Smite = true
            else
                Smite = false
            end
            if Smite then
                if enemy.alive then
                    if ValidTarget(enemy) then
                        if GetDistance(myHero.pos, enemy.pos) > 3000 then
                            Draw.Text("Jungler: Visible", 17, myHero.pos2D.x - 45, myHero.pos2D.y + 10, Draw.Color(0xFF32CD32))
                        else
                            Draw.Text("Jungler: Near", 17, myHero.pos2D.x - 43, myHero.pos2D.y + 10, Draw.Color(0xFFFF0000))
                        end
                    else
                        Draw.Text("Jungler: Invisible", 17, myHero.pos2D.x - 55, myHero.pos2D.y + 10, Draw.Color(0xFFFFD700))
                    end
                else
                    Draw.Text("Jungler: Dead", 17, myHero.pos2D.x - 45, myHero.pos2D.y + 10, Draw.Color(0xFF32CD32))
                end
            end
        end
        if self.UrgotMenu.Drawings.DrawAA:Value() then
            if ValidTarget(enemy) then
                AALeft = enemy.health / myHero.totalDamage
                Draw.Text("AA Left: " .. tostring(math.ceil(AALeft)), 17, enemy.pos2D.x - 38, enemy.pos2D.y + 10, Draw.Color(0xFF00BFFF))
            end
        end
    end
end

function Urgot:Harass()
    
    --print(GetSpellWName()) --UrgotW -- UrgotWCancel
    local targetQ = GOS:GetTarget(UrgotQ.range, "AD")
    local targetW = GOS:GetTarget(UrgotW.range, "AD")
    
    if targetQ then
        if not IsImmune(targetQ) then
            if self.UrgotMenu.Harass.UseQ:Value() then
                if IsReady(_Q) and self.Collision == false then
                    if ValidTarget(targetQ, UrgotQ.range) then
                        local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, targetQ, UrgotQ.range, UrgotQ.delay, UrgotQ.speed, UrgotQ.radius, false)
                        if hitChance and hitChance >= 2 then
                            self:CastQ(targetQ, aimPosition)
                        end
                    end
                end
            end
        end
    end
    
    if targetW then
        if not IsImmune(targetW) then
            if self.UrgotMenu.Harass.UseW:Value() then
                if self.CollisionSpellName == "YasuoWMovingWall" then
                    
                    else
                    if IsReady(_W) and GetSpellWName() == "UrgotW" then
                        if ValidTarget(targetW, UrgotW.range) then
                            LocalControlCastSpell(HK_W, targetW)
                        end
                    end
                end
            end
        end
    end

end

function Urgot:Combo()

    local targetQ = GOS:GetTarget(UrgotQ.range, "AD")
    local targetW = GOS:GetTarget(UrgotW.range, "AD")
    local targetE = GOS:GetTarget(UrgotE.range, "AD")
    local targetR = GOS:GetTarget(UrgotR.range, "AD")

    if IsReady(_E) and targetE then
        if targetE then
            if not IsImmune(targetE) then
                if self.UrgotMenu.Combo.UseE:Value() then
                    if IsReady(_E) and GetSpellWName() == "UrgotW" and self.Collision == false then
                        if ValidTarget(targetE, UrgotE.range) then
                            LocalControlCastSpell(HK_E, targetE)
                        end
                    end
                end
            end
        end
        
        if targetQ then
            if not IsImmune(targetQ) then
                if self.UrgotMenu.Combo.UseQ:Value() then
                    if IsReady(_Q) and self.Collision == false then
                        if ValidTarget(targetQ, UrgotQ.range) then
                            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, targetQ, UrgotQ.range, UrgotQ.delay, UrgotQ.speed, UrgotQ.radius, false)
                            if hitChance and hitChance >= 2 then
                                self:CastQ(targetQ, aimPosition)
                            end
                        end
                    end
                end
            end
        end
        
        if targetW then
            if not IsImmune(targetW) then
                if self.UrgotMenu.Combo.UseW:Value() then
                    if self.CollisionSpellName == "YasuoWMovingWall" then
                        
                        else
                        if IsReady(_W) and not IsReady(_E) and GetSpellWName() == "UrgotW" and self.Collision == false then
                            if ValidTarget(targetW, UrgotW.range) then
                                LocalControlCastSpell(HK_W, targetW)
                            end
                        end
                    end
                end
            end
        end
        
        if targetR then
            if not IsImmune(targetR) then
                if self.UrgotMenu.Combo.UseR:Value() then
                    if self.CollisionSpellName == "YasuoWMovingWall" then
                        
                        else
                        if IsReady(_R) and self.Collision == false then
                            if ValidTarget(targetR, UrgotR.range) and ((targetR.health / targetR.maxHealth <= 24 / 100) or ((targetR.health - RDmg()) / targetR.maxHealth <= 24 / 100)) then
                                --LocalControlCastSpell(HK_R, targetR)
                                local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, targetR, UrgotR.range, UrgotR.delay, UrgotR.speed, UrgotR.radius, false)
                                if hitChance and hitChance >= 2 then
                                    self:CastR(targetR, aimPosition)
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif not IsReady(_E) then
        if targetQ then
            if not IsImmune(targetQ) then
                if self.UrgotMenu.Combo.UseQ:Value() then
                    if IsReady(_Q) and self.Collision == false then
                        if ValidTarget(targetQ, UrgotQ.range) then
                            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, targetQ, UrgotQ.range, UrgotQ.delay, UrgotQ.speed, UrgotQ.radius, false)
                            if hitChance and hitChance >= 2 then
                                self:CastQ(targetQ, aimPosition)
                            end
                        end
                    end
                end
            end
        end
        
        if targetW then
            if not IsImmune(targetW) then
                if self.UrgotMenu.Combo.UseW:Value() then
                    if self.CollisionSpellName == "YasuoWMovingWall" then
                        
                        else
                        if IsReady(_W) and GetSpellWName() == "UrgotW" and self.Collision == false then
                            if ValidTarget(targetW, UrgotW.range) then
                                LocalControlCastSpell(HK_W, targetW)
                            end
                        end
                    end
                end
            end
        end
        
        if targetR then
            if not IsImmune(targetR) then
                if self.UrgotMenu.Combo.UseR:Value() then
                    if self.CollisionSpellName == "YasuoWMovingWall" then
                        
                        else
                        if IsReady(_R) and self.Collision == false then
                            if ValidTarget(targetR, UrgotR.range) and ((targetR.health / targetR.maxHealth <= 24 / 100) or ((targetR.health - RDmg()) / targetR.maxHealth <= 24 / 100)) then
                                --LocalControlCastSpell(HK_R, targetR)
                                local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, targetR, UrgotR.range, UrgotR.delay, UrgotR.speed, UrgotR.radius, false)
                                if hitChance and hitChance >= 2 then
                                    self:CastR(targetR, aimPosition)
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        if targetQ then
            if not IsImmune(targetQ) then
                if self.UrgotMenu.Combo.UseQ:Value() then
                    if IsReady(_Q) and self.Collision == false then
                        if ValidTarget(targetQ, UrgotQ.range) then
                            local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, targetQ, UrgotQ.range, UrgotQ.delay, UrgotQ.speed, UrgotQ.radius, false)
                            if hitChance and hitChance >= 2 then
                                self:CastQ(targetQ, aimPosition)
                            end
                        end
                    end
                end
            end
        end
        
        if targetR then
            if not IsImmune(targetR) then
                if self.UrgotMenu.Combo.UseR:Value() then
                    if self.CollisionSpellName == "YasuoWMovingWall" then
                        
                        else
                        if IsReady(_R) and self.Collision == false then
                            if ValidTarget(targetR, UrgotR.range) and ((targetR.health / targetR.maxHealth <= 24 / 100) or ((targetR.health - RDmg()) / targetR.maxHealth <= 24 / 100)) then
                                --LocalControlCastSpell(HK_R, targetR)
                                local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, targetR, UrgotR.range, UrgotR.delay, UrgotR.speed, UrgotR.radius, false)
                                if hitChance and hitChance >= 2 then
                                    self:CastR(targetR, aimPosition)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function Urgot:CastQ(target, EcastPos)

    if LocalGameTimer() - OnWaypoint(target).time > 0.05 and (LocalGameTimer() - OnWaypoint(target).time < 0.125 or LocalGameTimer() - OnWaypoint(target).time > 1.25) then
        if GetDistance(myHero.pos, EcastPos) <= UrgotQ.range then
            LocalControlCastSpell(HK_Q, EcastPos)
        end
    end

    --[[
    if Ready(_Q) then
        if self.UrgotMenu.Pred.Change:Value() == 1 then
            local pred = GetGamsteronPrediction(unit, self.QData, myHero)
            if pred.Hitchance >= self.UrgotMenu.Pred.PredQ:Value()+1 then
                Control.CastSpell(HK_Q, pred.CastPosition)
            end
        end	
        if self.UrgotMenu.Pred.Change:Value() == 2 then
            local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, self.QspellData)
            if pred.CastPos and ConvertToHitChance(self.Menu.Pred.PredQ:Value(), pred.HitChance) then
                Control.CastSpell(HK_Q, pred.CastPos)
            end
        end	
        if self.UrgotMenu.Pred.Change:Value() == 3 then
            self.QPrediction:GetAOEPrediction(unit, myHero)			
            if self.QPrediction:CanHit(self.UrgotMenu.Pred.PredQ:Value() + 1) then
                Control.CastSpell(HK_Q, self.QPrediction.CastPosition)
            end	
        end
        if self.UrgotMenu.Pred.Change:Value() == 4 then
            if LocalGameTimer() - OnWaypoint(target).time > 0.05 and (LocalGameTimer() - OnWaypoint(target).time < 0.125 or LocalGameTimer() - OnWaypoint(target).time > 1.25) then
                if GetDistance(myHero.pos, EcastPos) <= UrgotQ.range then
                    LocalControlCastSpell(HK_Q, EcastPos)
                end
            end
        end
    end
    ]]
end

function Urgot:CastR(target, EcastPos)

    if LocalGameTimer() - OnWaypoint(target).time > 0.05 and (LocalGameTimer() - OnWaypoint(target).time < 0.125 or LocalGameTimer() - OnWaypoint(target).time > 1.25) then
        if GetDistance(myHero.pos, EcastPos) <= UrgotR.range then
            LocalControlCastSpell(HK_R, EcastPos)
        end
    end

    --[[
    if Ready(_R) then
        if self.UrgotMenu.Pred.Change:Value() == 1 then
            local pred = GetGamsteronPrediction(unit, self.RData, myHero)
            if pred.Hitchance >= self.UrgotMenu.Pred.PredR:Value()+1 then
                Control.CastSpell(HK_R, pred.CastPosition)
            end
        end	
        if self.UrgotMenu.Pred.Change:Value() == 2 then
            local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, self.RspellData)
            if pred.CastPos and ConvertToHitChance(self.UrgotMenu.Pred.PredR:Value(), pred.HitChance) then
                Control.CastSpell(HK_R, pred.CastPos)
            end
        end	
        if self.UrgotMenu.Pred.Change:Value() == 3 then
            self.RPrediction:GetAOEPrediction(unit, myHero)			
            if self.RPrediction:CanHit(self.UrgotMenu.Pred.PredR:Value() + 1) then
                Control.CastSpell(HK_R, self.RPrediction.CastPosition)
            end	
        end
        if self.UrgotMenu.Pred.Change:Value() == 4 then
            if LocalGameTimer() - OnWaypoint(target).time > 0.05 and (LocalGameTimer() - OnWaypoint(target).time < 0.125 or LocalGameTimer() - OnWaypoint(target).time > 1.25) then
                if GetDistance(myHero.pos, EcastPos) <= UrgotR.range then
                    LocalControlCastSpell(HK_R, EcastPos)
                end
            end
        end
    end
    ]]
end

function OnLoad()
    Urgot()
end

class "HPred"

local _tickFrequency = .2
local _nextTick = LocalGameTimer()
local _reviveLookupTable =
    {
        ["LifeAura.troy"] = 4,
        ["ZileanBase_R_Buf.troy"] = 3,
        ["Aatrox_Base_Passive_Death_Activate"] = 3
    }

local _blinkSpellLookupTable =
    {
        ["EzrealArcaneShift"] = 475,
        ["RiftWalk"] = 500,
        ["EkkoEAttack"] = 0,
        ["AlphaStrike"] = 0,
        ["KatarinaE"] = -255,
        ["KatarinaEDagger"] = {"Katarina_Base_Dagger_Ground_Indicator", "Katarina_Skin01_Dagger_Ground_Indicator", "Katarina_Skin02_Dagger_Ground_Indicator", "Katarina_Skin03_Dagger_Ground_Indicator", "Katarina_Skin04_Dagger_Ground_Indicator", "Katarina_Skin05_Dagger_Ground_Indicator", "Katarina_Skin06_Dagger_Ground_Indicator", "Katarina_Skin07_Dagger_Ground_Indicator", "Katarina_Skin08_Dagger_Ground_Indicator", "Katarina_Skin09_Dagger_Ground_Indicator"},
    }

local _blinkLookupTable =
    {
        "global_ss_flash_02.troy",
        "Lissandra_Base_E_Arrival.troy",
        "LeBlanc_Base_W_return_activation.troy"
    }

local _cachedBlinks = {}
local _cachedRevives = {}
local _cachedTeleports = {}
local _cachedMissiles = {}
local _incomingDamage = {}
local _windwall
local _windwallStartPos
local _windwallWidth

local _OnVision = {}
function HPred:OnVision(unit)
    if unit == nil or type(unit) ~= "userdata" then return end
    if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {visible = unit.visible, tick = LocalGetTickCount(), pos = unit.pos} end
    if _OnVision[unit.networkID].visible == true and not unit.visible then _OnVision[unit.networkID].visible = false _OnVision[unit.networkID].tick = LocalGetTickCount() end
    if _OnVision[unit.networkID].visible == false and unit.visible then _OnVision[unit.networkID].visible = true _OnVision[unit.networkID].tick = LocalGetTickCount()_OnVision[unit.networkID].pos = unit.pos end
    return _OnVision[unit.networkID]
end

function HPred:Tick()
    if _nextTick > LocalGameTimer() then return end
    _nextTick = LocalGameTimer() + _tickFrequency
    for i = 1, LocalGameHeroCount() do
        local t = LocalGameHero(i)
        if t then
            if t.isEnemy then
                HPred:OnVision(t)
            end
        end
    end
    if true then return end
    for _, teleport in _pairs(_cachedTeleports) do
        if teleport and LocalGameTimer() > teleport.expireTime + .5 then
            _cachedTeleports[_] = nil
        end
    end
    HPred:CacheTeleports()
    HPred:CacheParticles()
    for _, revive in _pairs(_cachedRevives) do
        if LocalGameTimer() > revive.expireTime + .5 then
            _cachedRevives[_] = nil
        end
    end
    for _, revive in _pairs(_cachedRevives) do
        if LocalGameTimer() > revive.expireTime + .5 then
            _cachedRevives[_] = nil
        end
    end
    for i = 1, LocalGameParticleCount() do
        local particle = LocalGameParticle(i)
        if particle and not _cachedRevives[particle.networkID] and _reviveLookupTable[particle.name] then
            _cachedRevives[particle.networkID] = {}
            _cachedRevives[particle.networkID]["expireTime"] = LocalGameTimer() + _reviveLookupTable[particle.name]
            local target = HPred:GetHeroByPosition(particle.pos)
            if target.isEnemy then
                _cachedRevives[particle.networkID]["target"] = target
                _cachedRevives[particle.networkID]["pos"] = target.pos
                _cachedRevives[particle.networkID]["isEnemy"] = target.isEnemy
            end
        end
        if particle and not _cachedBlinks[particle.networkID] and _blinkLookupTable[particle.name] then
            _cachedBlinks[particle.networkID] = {}
            _cachedBlinks[particle.networkID]["expireTime"] = LocalGameTimer() + _reviveLookupTable[particle.name]
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
    if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396, 182.132507324219, 462); end
end


function HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
    local target, aimPosition = self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
end


function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
    local target, aimPosition = self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
    local target, aimPosition = self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
    if target and aimPosition then
        return target, aimPosition
    end
end

function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
    local targetCount = 0
    for i = 1, LocalGameHeroCount() do
        local t = LocalGameHero(i)
        if t and self:CanTargetALL(t) and (targetAllies or t.isEnemy) then
            local predictedPos = self:PredictUnitPosition(t, delay + self:GetDistance(source, t.pos) / speed)
            local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
            if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) * (t.boundingRadius + width)) then
                targetCount = targetCount + 1
            end
        end
    end
    return targetCount
end

function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist, isLine)
    local _validTargets = {}
    for i = 1, LocalGameHeroCount() do
        local t = LocalGameHero(i)
        if t and self:CanTarget(t, true) and (not whitelist or whitelist[t.charName]) then
            local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision, isLine)
            if hitChance >= minimumHitChance then
                _insert(_validTargets, {aimPosition, hitChance, hitChance * 100 + self:CalculateMagicDamage(t, 400)})
            end
        end
    end
    _sort(_validTargets, function(a, b) return a[3] > b[3] end)
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
    Waypoints = self:GetCurrentWayPoints(target)
    if (#Waypoints == 1) then
        HitChance = 2
    end
    if self:isSlowed(target, delay, speed, source) then
        HitChance = 2
    end
    if self:GetDistance(source, target.pos) < 350 then
        HitChance = 2
    end
    local angletemp = Vector(source):AngleBetween(Vector(target.pos), Vector(aimPosition))
    if angletemp > 60 then
        HitChance = 1
    elseif angletemp < 10 then
        HitChance = 2
    end
    if not target.pathing or not target.pathing.hasMovePath then
        hitChancevisionData = 2
        hitChance = 2
    end
    local origin, movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
    if movementRadius - target.boundingRadius <= radius / 2 then
        origin, movementRadius = self:UnitMovementBounds(target, interceptTime, 0)
        if movementRadius - target.boundingRadius <= radius / 2 then
            hitChance = 4
        else
            hitChance = 3
        end
    end
    if target.activeSpell and target.activeSpell.valid then
        if target.activeSpell.startTime + target.activeSpell.windup - LocalGameTimer() >= delay then
            hitChance = 5
        else
            hitChance = 3
        end
    end
    local visionData = HPred:OnVision(target)
    if visionData and visionData.visible == false then
        local hiddenTime = visionData.tick - LocalGetTickCount()
        if hiddenTime < -1000 then
            hitChance = -1
        else
            local targetSpeed = self:GetTargetMS(target)
            local unitPos = target.pos + Vector(target.pos, target.posTo):Normalized() * ((LocalGetTickCount() - visionData.tick) / 1000 * targetSpeed)
            local aimPosition = unitPos + Vector(target.pos, target.posTo):Normalized() * (targetSpeed * (delay + (self:GetDistance(myHero.pos, unitPos) / speed)))
            if self:GetDistance(target.pos, aimPosition) > self:GetDistance(target.pos, target.posTo) then aimPosition = target.posTo end
            hitChance = _min(hitChance, 2)
        end
    end
    if not self:IsInRange(source, aimPosition, range) then
        hitChance = -1
    end
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
    if unit.activeSpell and unit.activeSpell.valid then
        local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - LocalGameTimer()
        if windupRemaining > 0 then
            reactionTime = windupRemaining
        end
    end
    return reactionTime
end

function HPred:GetCurrentWayPoints(object)
    local result = {}
    if object.pathing.hasMovePath then
        _insert(result, Vector(object.pos.x, object.pos.y, object.pos.z))
        for i = object.pathing.pathIndex, object.pathing.pathCount do
            path = object:GetPath(i)
            _insert(result, Vector(path.x, path.y, path.z))
        end
    else
        _insert(result, object and Vector(object.pos.x, object.pos.y, object.pos.z) or Vector(object.pos.x, object.pos.y, object.pos.z))
    end
    return result
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)
    local target
    local aimPosition
    for i = 1, LocalGameHeroCount() do
        local t = LocalGameHero(i)
        if t and t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed > 500 then
            local dashEndPosition = t:GetPath(1)
            if self:IsInRange(source, dashEndPosition, range) then
                local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
                local skillInterceptTime = self:GetSpellInterceptTime(source, dashEndPosition, delay, speed)
                local deltaInterceptTime = skillInterceptTime - dashTimeRemaining
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
    for _, revive in _pairs(_cachedRevives) do
        if revive.isEnemy then
            local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
            if interceptTime > revive.expireTime - LocalGameTimer() and interceptTime - revive.expireTime - LocalGameTimer() < timingAccuracy then
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
            local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - LocalGameTimer()
            if windupRemaining > 0 then
                local endPos
                local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
                if type(blinkRange) == "table" then
                    elseif blinkRange > 0 then
                    endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)
                    endPos = t.activeSpell.startPos + (endPos - t.activeSpell.startPos):Normalized() * _min(self:GetDistance(t.activeSpell.startPos, endPos), range)
                    else
                        local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
                        if blinkTarget then
                            local offsetDirection
                            if blinkRange == 0 then
                                if t.activeSpell.name == "AlphaStrike" then
                                    windupRemaining = windupRemaining + .75
                                end
                                offsetDirection = (blinkTarget.pos - t.pos):Normalized()
                            elseif blinkRange == -1 then
                                offsetDirection = (t.pos - blinkTarget.pos):Normalized()
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
                local interceptTime = self:GetSpellInterceptTime(source, endPos, delay, speed)
                local deltaInterceptTime = interceptTime - windupRemaining
                if self:IsInRange(source, endPos, range) and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
                    target = t
                    aimPosition = endPos
                    return target, aimPosition
                end
            end
        end
    end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
    local target
    local aimPosition
    for _, particle in _pairs(_cachedBlinks) do
        if particle and self:IsInRange(source, particle.pos, range) then
            local t = particle.target
            local pPos = particle.pos
            if t and t.isEnemy and (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
                target = t
                aimPosition = pPos
                return target, aimPosition
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
    for i = 1, LocalGameTurretCount() do
        local turret = LocalGameTurret(i);
        if turret and turret.isEnemy and not _cachedTeleports[turret.networkID] then
            local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
            if hasBuff then
                self:RecordTeleport(turret, self:GetTeleportOffset(turret.pos, 223.31), expiresAt)
            end
        end
    end
    for i = 1, LocalGameWardCount() do
        local ward = LocalGameWard(i);
        if ward and ward.isEnemy and not _cachedTeleports[ward.networkID] then
            local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
            if hasBuff then
                self:RecordTeleport(ward, self:GetTeleportOffset(ward.pos, 100.01), expiresAt)
            end
        end
    end
    for i = 1, LocalGameMinionCount() do
        local minion = LocalGameMinion(i);
        if minion and minion.isEnemy and not _cachedTeleports[minion.networkID] then
            local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
            if hasBuff then
                self:RecordTeleport(minion, self:GetTeleportOffset(minion.pos, 143.25), expiresAt)
            end
        end
    end
end

function HPred:RecordTeleport(target, aimPos, endTime)
    _cachedTeleports[target.networkID] = {}
    _cachedTeleports[target.networkID]["target"] = target
    _cachedTeleports[target.networkID]["aimPos"] = aimPos
    _cachedTeleports[target.networkID]["expireTime"] = endTime + LocalGameTimer()
end


function HPred:CalculateIncomingDamage()
    _incomingDamage = {}
    local currentTime = LocalGameTimer()
    for _, missile in _pairs(_cachedMissiles) do
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
function HPred:CacheParticles()
    if _windwall and _windwall.name == "" then
        _windwall = nil
    end
    
    for i = 1, LocalGameParticleCount() do
        local particle = LocalGameParticle(i)
        if particle and self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then
            if _find(particle.name, "W_windwall%d") and not _windwall then
                local owner = self:GetObjectByHandle(particle.handle)
                if owner and owner.isEnemy then
                    _windwall = particle
                    _windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)
                    local index = _len(particle.name) - 5
                    local spellLevel = _sub(particle.name, index, index) - 1
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
    local currentTime = LocalGameTimer()
    for i = 1, LocalGameMissileCount() do
        local missile = LocalGameMissile(i)
        if missile and not _cachedMissiles[missile.networkID] and missile.missileData then
            if missile.missileData.target and missile.missileData.owner then
                local missileName = missile.missileData.name
                local owner = self:GetObjectByHandle(missile.missileData.owner)
                local target = self:GetObjectByHandle(missile.missileData.target)
                if owner and target and _find(target.type, "Hero") then
                    if (_find(missileName, "BasicAttack") or _find(missileName, "CritAttack")) then
                        _cachedMissiles[missile.networkID] = {}
                        _cachedMissiles[missile.networkID].target = target
                        _cachedMissiles[missile.networkID].data = missile
                        _cachedMissiles[missile.networkID].danger = 1
                        _cachedMissiles[missile.networkID].timeout = currentTime + 1.5
                        local damage = owner.totalDamage
                        if _find(missileName, "CritAttack") then
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
    local damageReduction = 100 / (100 + targetArmor)
    if targetArmor < 0 then
        damageReduction = 2 - (100 / (100 - targetArmor))
    end
    damage = damage * damageReduction
    return damage
end

function HPred:CalculateMagicDamage(target, damage)
    local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
    local damageReduction = 100 / (100 + targetMR)
    if targetMR < 0 then
        damageReduction = 2 - (100 / (100 - targetMR))
    end
    damage = damage * damageReduction
    return damage
end


function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
    local target
    local aimPosition
    for _, teleport in _pairs(_cachedTeleports) do
        if teleport.expireTime > LocalGameTimer() and self:IsInRange(source, teleport.aimPos, range) then
            local spellInterceptTime = self:GetSpellInterceptTime(source, teleport.aimPos, delay, speed)
            local teleportRemaining = teleport.expireTime - LocalGameTimer()
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
    local angle = _atan(deltaPos.x, deltaPos.z) * 180 / _pi
    if angle < 0 then angle = angle + 360 end
    return angle
end

function HPred:PredictUnitPosition(unit, delay)
    local predictedPosition = unit.pos
    local timeRemaining = delay
    local pathNodes = self:GetPathNodes(unit)
    for i = 1, #pathNodes - 1 do
        local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i + 1])
        local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
        if timeRemaining > nodeTraversalTime then
            timeRemaining = timeRemaining - nodeTraversalTime
            predictedPosition = pathNodes[i + 1]
        else
            local directionVector = (pathNodes[i + 1] - pathNodes[i]):Normalized()
            predictedPosition = pathNodes[i] + directionVector * self:GetTargetMS(unit) * timeRemaining
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

function HPred:GetTeleportOffset(origin, magnitude)
    local teleportOffset = origin + (self:GetEnemyNexusPosition() - origin):Normalized() * magnitude
    return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)
    local interceptTime = Game.Latency() / 2000 + delay + self:GetDistance(startPos, endPos) / speed
    return interceptTime
end

function HPred:CanTarget(target, allowInvisible)
    return target.isEnemy and target.alive and target.health > 0 and (allowInvisible or target.visible) and target.isTargetable
end

function HPred:CanTargetALL(target)
    return target.alive and target.health > 0 and target.visible and target.isTargetable
end

function HPred:UnitMovementBounds(unit, delay, reactionTime)
    local startPosition = self:PredictUnitPosition(unit, delay)
    local radius = 0
    local deltaDelay = delay - reactionTime - self:GetImmobileTime(unit)
    if (deltaDelay > 0) then
        radius = self:GetTargetMS(unit) * deltaDelay
    end
    return startPosition, radius
end

function HPred:GetImmobileTime(unit)
    local duration = 0
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i);
        if buff.count > 0 and buff.duration > duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39) then
            duration = buff.duration
        end
    end
    return duration
end

function HPred:isSlowed(unit, delay, speed, from)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i);
        if from and unit and buff.count > 0 and buff.duration >= (delay + GetDistance(unit.pos, from) / speed) then
            if (buff.type == 10) then
                return true
            end
        end
    end
    return false
end

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

function HPred:GetPathNodes(unit)
    local nodes = {}
    _insert(nodes, unit.pos)
    if unit.pathing.hasMovePath then
        for i = unit.pathing.pathIndex, unit.pathing.pathCount do
            path = unit:GetPath(i)
            _insert(nodes, path)
        end
    end
    return nodes
end

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

function HPred:GetPathLength(nodes)
    local result = 0
    for i = 1, #nodes - 1 do
        result = result + self:GetDistance(nodes[i], nodes[i + 1])
    end
    return result
end

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
    local pointLine = {x = ax + rL * (bx - ax), y = ay + rL * (by - ay)}
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), y = ay + rS * (by - ay)}
    return pointSegment, pointLine, isOnSegment
end

function HPred:IsWindwallBlocking(source, target)
    if _windwall then
        local windwallFacing = (_windwallStartPos - _windwall.pos):Normalized()
        return self:DoLineSegmentsIntersect(source, target, _windwall.pos + windwallFacing:Perpendicular() * _windwallWidth, _windwall.pos + windwallFacing:Perpendicular2() * _windwallWidth)
    end
    return false
end

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

function HPred:GetOrientation(A, B, C)
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
    if deltaAngle < angle and self:IsInRange(origin, target, range) then
        return true
    end
end

function HPred:GetDistanceSqr(p1, p2)
    if not p1 or not p2 then
        local dInfo = debug.getinfo(2)
        print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
        return _huge
    end
    return (p1.x - p2.x) * (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y))
end

function HPred:IsInRange(p1, p2, range)
    if not p1 or not p2 then
        local dInfo = debug.getinfo(2)
        print("Undefined IsInRange target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
        return false
    end
    return (p1.x - p2.x) * (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range
end

function HPred:GetDistance(p1, p2)
    if not p1 or not p2 then
        local dInfo = debug.getinfo(2)
        _print("Undefined GetDistance target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
        return _huge
    end
    return _sqrt(self:GetDistanceSqr(p1, p2))
end
require "PremiumPrediction"
require "GamsteronPrediction"
require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"
require "GGPrediction"

--local EnemyHeroes = {}
--local AllyHeroes = {}
local EnemySpawnPos = nil
local AllySpawnPos = nil

--[[
--[ update not enabled until proper rank ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "ImpulsViktor.lua",
            Url = "https://raw.githubusercontent.com/Impuls/GoS/master/ImpulsViktor.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "ImpulsViktor.version",
            Url = "https://raw.githubusercontent.com/Impuls/GoS/master/ImpulsViktor.version"
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

function GetNearestTurret(pos)
    --local turrets = _G.SDK.ObjectManager:GetTurrets(5000)
    local BestDistance = 0
    local BestTurret = nil
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret.isAlly then
            local Distance = GetDistance(turret.pos, pos)
            if turret and (Distance < BestDistance or BestTurret == nil) then
                --PrintChat("Set Best Turret")
                BestTurret = turret
                BestDistance = Distance
            end
        end     
    end   
    return BestTurret
end

local function IsNearEnemyTurret(pos, distance)
    --PrintChat("Checking Turrets")
    local turrets = _G.SDK.ObjectManager:GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= distance+915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
end

local function IsUnderEnemyTurret(pos)
    --PrintChat("Checking Turrets")
    local turrets = _G.SDK.ObjectManager:GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= 915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
end

function GetDifference(a,b)
    local Sa = a^2
    local Sb = b^2
    local Sdif = (a-b)^2
    return math.sqrt(Sdif)
end

function GetDistanceSqr(Pos1, Pos2)
    local Pos2 = Pos2 or myHero.pos
    local dx = Pos1.x - Pos2.x
    local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
    return dx^2 + dz^2
end

function GetDistance(Pos1, Pos2)
    return math.sqrt(GetDistanceSqr(Pos1, Pos2))
end

function IsImmobile(unit)
    local MaxDuration = 0
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local BuffType = buff.type
            if BuffType == 5 or BuffType == 11 or BuffType == 21 or BuffType == 22 or BuffType == 24 or BuffType == 29 or buff.name == "recall" then
                local BuffDuration = buff.duration
                if BuffDuration > MaxDuration then
                    MaxDuration = BuffDuration
                end
            end
        end
    end
    return MaxDuration
end

function GetEnemyHeroes()
    local EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(EnemyHeroes, Hero)
            --PrintChat(Hero.name)
        end
    end
    return EnemyHeroes
    --PrintChat("Got Enemy Heroes")
end

function GetAllyHeroes()
    local AllyHeroes = {}
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isAlly and not Hero.isMe then
            table.insert(AllyHeroes, Hero)
            --PrintChat(Hero.name)
        end
    end
    return AllyHeroes
    --PrintChat("Got Ally Heroes")
end

function GetEnemyBase()
    for i = 1, Game.ObjectCount() do
        local object = Game.Object(i)
        
        if not object.isAlly and object.type == Obj_AI_SpawnPoint then 
            EnemySpawnPos = object
            break
        end
    end
end

function GetAllyBase()
    for i = 1, Game.ObjectCount() do
        local object = Game.Object(i)
        
        if object.isAlly and object.type == Obj_AI_SpawnPoint then 
            AllySpawnPos = object
            break
        end
    end
end

function GetBuffStart(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff.startTime
        end
    end
    return nil
end

function GetBuffExpire(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff.expireTime
        end
    end
    return nil
end

function GetBuffStacks(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff.count
        end
    end
    return 0
end

local function GetWaypoints(unit) -- get unit's waypoints
    local waypoints = {}
    local pathData = unit.pathing
    table.insert(waypoints, unit.pos)
    local PathStart = pathData.pathIndex
    local PathEnd = pathData.pathCount
    if PathStart and PathEnd and PathStart >= 0 and PathEnd <= 20 and pathData.hasMovePath then
        for i = pathData.pathIndex, pathData.pathCount do
            table.insert(waypoints, unit:GetPath(i))
        end
    end
    return waypoints
end

local function GetUnitPositionNext(unit)
    local waypoints = GetWaypoints(unit)
    if #waypoints == 1 then
        return nil -- we have only 1 waypoint which means that unit is not moving, return his position
    end
    return waypoints[2] -- all segments have been checked, so the final result is the last waypoint
end

local function GetUnitPositionAfterTime(unit, time)
    local waypoints = GetWaypoints(unit)
    if #waypoints == 1 then
        return unit.pos -- we have only 1 waypoint which means that unit is not moving, return his position
    end
    local max = unit.ms * time -- calculate arrival distance
    for i = 1, #waypoints - 1 do
        local a, b = waypoints[i], waypoints[i + 1]
        local dist = GetDistance(a, b)
        if dist >= max then
            return Vector(a):Extended(b, dist) -- distance of segment is bigger or equal to maximum distance, so the result is point A extended by point B over calculated distance
        end
        max = max - dist -- reduce maximum distance and check next segments
    end
    return waypoints[#waypoints] -- all segments have been checked, so the final result is the last waypoint
end

function GetTarget(range)
    if _G.SDK then
        return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
    else
        return _G.GOS:GetTarget(range,"AD")
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

function BuffActive(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return true
        end
    end
    return false
end

function IsReady(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
end

function OnLoad()
    Manager()
end

function Mode()
    if _G.SDK then
        if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
            return "Combo"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] or Orbwalker.Key.Harass:Value() then
            return "Harass"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or Orbwalker.Key.Clear:Value() then
            return "LaneClear"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] or Orbwalker.Key.LastHit:Value() then
            return "LastHit"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
            return "Flee"
        end
    else
        return GOS.GetMode()
    end
end

function GetItemSlot(unit, id)
    for i = ITEM_1, ITEM_7 do
        if unit:GetItemData(i).itemID == id then
            return i
        end
    end
    return 0
end

function IsFacing(unit)
    local V = Vector((unit.pos - myHero.pos))
    local D = Vector(unit.dir)
    local Angle = 180 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
    if math.abs(Angle) < 80 then 
        return true  
    end
    return false
end

function IsMyHeroFacing(unit)
    local V = Vector((myHero.pos - unit.pos))
    local D = Vector(myHero.dir)
    local Angle = 180 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
    if math.abs(Angle) < 80 then 
        return true  
    end
    return false
end

function SetMovement(bool)
    if _G.PremiumOrbwalker then
        _G.PremiumOrbwalker:SetAttack(bool)
        _G.PremiumOrbwalker:SetMovement(bool)       
    elseif _G.SDK then
        _G.SDK.Orbwalker:SetMovement(bool)
        _G.SDK.Orbwalker:SetAttack(bool)
    end
end


local function CheckHPPred(unit, SpellSpeed)
     local speed = SpellSpeed
     local range = myHero.pos:DistanceTo(unit.pos)
     local time = range / speed
     if _G.SDK and _G.SDK.Orbwalker then
         return _G.SDK.HealthPrediction:GetPrediction(unit, time)
     elseif _G.PremiumOrbwalker then
         return _G.PremiumOrbwalker:GetHealthPrediction(unit, time)
    end
end

function EnableMovement()
    SetMovement(true)
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end


local function ValidTarget(unit, range)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        if range then
            if GetDistance(unit.pos) <= range then
                return true;
            end
        else
            return true
        end
    end
    return false;
end

class "Manager"

function Manager:__init()
    if myHero.charName == "Viktor" then
        DelayAction(function() self:LoadViktor() end, 1.05)
    elseif myHero.charName == "Annie" then
        DelayAction(function() self:LoadAnnie() end, 1.05)
    end
end

function Manager:LoadViktor()
    Viktor:Spells()
    Viktor:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Viktor:Tick() end)
    Callback.Add("Draw", function() Viktor:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Viktor:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Viktor:OnPostAttackTick(...) end)
    end
end

function Manager:LoadAnnie()
    Annie:Spells()
    Annie:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Annie:Tick() end)
    Callback.Add("Draw", function() Annie:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Annie:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Annie:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) Annie:OnPostAttack(...) end)
    end
end


class "Viktor"

local PredLoaded = false
local EnemyLoaded = false
local AllyLoaded = false
local casted = 0
local LastCalledTime = 0
local LastESpot = myHero.pos
local LastE2Spot = myHero.pos
local PickingCard = false
local TargetAttacking = false
local attackedfirst = 0
local CastingQ = false
local LastDirect = 0
local CastingW = false
local CastingR = false
local ReturnMouse = mousePos
local Q = 1
local Edown = false
local R = 1
local WasInRange = false
local OneTick
local attacked = 0

local HeroIcon = "https://www.mobafire.com/images/champion/icon/viktor.png"
local IgniteIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/f/f4/Ignite.png"
local QIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/3/30/Augment-_Turbocharge.png"
local WIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/b/bf/Augment-_Magnetize.png"
local EIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/5/5d/Augment-_Aftershock.png"
local RIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/9/9f/Augment-_Perfect_Storm.png"
local R2Icon = "https://static.wikia.nocookie.net/leagueoflegends/images/1/1e/Chaos_Storm_2.png"

function Viktor:LoadMenu()
    self.ViktorMenu = MenuElement({type = MENU, id = "Viktor", name = "Impuls Viktor", leftIcon = HeroIcon})
    self.ViktorMenu:MenuElement({id = "FleeKey", name = "Disengage Key", key = string.byte("A"), value = false})
    self.ViktorMenu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
        self.ViktorMenu.ComboMode:MenuElement({id = "UseQ", name = "Use Q [Siphon Power] in Combo", value = true, leftIcon = QIcon})
        self.ViktorMenu.ComboMode:MenuElement({id = "UseW", name = "Use W [Gravity Field] in Combo", value = true, leftIcon = WIcon})
        self.ViktorMenu.ComboMode:MenuElement({id = "UseE", name = "Use E [Death Ray] in Combo", value = true, leftIcon = EIcon})
        self.ViktorMenu.ComboMode:MenuElement({id = "UseEDef", name = "Use Defensive E in Combo", value = true})
        self.ViktorMenu.ComboMode:MenuElement({id = "UseEAtt", name = "Use Offensive E in Combo", value = true})
        self.ViktorMenu.ComboMode:MenuElement({id = "UseEAttHits", name = "Min enemies for Offensive E", value = 1, min = 1, max = 5, step = 1})
        self.ViktorMenu.ComboMode:MenuElement({id = "UseR", name = "Use R [Chaos Storm] in Combo", value = true, leftIcon = RIcon})

    self.ViktorMenu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
        self.ViktorMenu.HarassMode:MenuElement({id = "UseQ", name = "Use Q in Harass", value = false, leftIcon = QIcon})
        self.ViktorMenu.HarassMode:MenuElement({id = "UseE", name = "Use E in Harass", value = false, leftIcon = WIcon})
        self.ViktorMenu.HarassMode:MenuElement({id = "UseW", name = "Use W in Harass", value = false, leftIcon = EIcon})
        self.ViktorMenu.HarassMode:MenuElement({id = "UseR", name = "Use R in Harass", value = false, leftIcon = RIcon})

    self.ViktorMenu:MenuElement({id = "FleeMode", name = "Flee", type = MENU})
        self.ViktorMenu.FleeMode:MenuElement({id = "UseQ", name = "Use Q to Flee", value = true, leftIcon = QIcon})
        self.ViktorMenu.FleeMode:MenuElement({id = "UseE", name = "Use E to Flee", value = true, leftIcon = EIcon})

    self.ViktorMenu:MenuElement({id = "KSMode", name = "KS", type = MENU})
        self.ViktorMenu.KSMode:MenuElement({id = "UseQ", name = "Use Q in KS", value = true, leftIcon = QIcon})

	self.ViktorMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	    self.ViktorMenu.Drawings:MenuElement({id = "DrawQ", name = "Q: Draw Range", value = true, leftIcon = QIcon})
	    self.ViktorMenu.Drawings:MenuElement({id = "DrawW", name = "W: Draw Range", value = true, leftIcon = WIcon})
	    self.ViktorMenu.Drawings:MenuElement({id = "DrawE", name = "E: Draw Range", value = true, leftIcon = EIcon})
	    self.ViktorMenu.Drawings:MenuElement({id = "DrawR", name = "R: Draw Range", value = true, leftIcon = RIcon})

	self.ViktorMenu:MenuElement({type = MENU, id = "AutoLevel", name = myHero.charName.." AutoLevel Spells"})
        self.ViktorMenu.AutoLevel:MenuElement({id = "on", name = "Enabled", value = true})
        self.ViktorMenu.AutoLevel:MenuElement({id = "LvL", name = "AutoLevel start -->", value = 5, min = 1, max = 6, step = 1})
        self.ViktorMenu.AutoLevel:MenuElement({id = "delay", name = "Delay for Level up", value = 2, min = 0 , max = 10, step = 0.5, identifier = "sec"})
        self.ViktorMenu.AutoLevel:MenuElement({id = "Order", name = "Skill Order", value = 3, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})

    self.ViktorMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	    self.ViktorMenu.Pred:MenuElement({name = " ", drop = {"After change Prediction Type press 2xF6"}})	
	    self.ViktorMenu.Pred:MenuElement({id = "Change", name = "Change Prediction Type", value = 4, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction", "InternalPrediction"}})	
	    self.ViktorMenu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})
	    self.ViktorMenu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
	    self.ViktorMenu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
end

function Viktor:Spells()
    ESpellData = {speed = 1350, range = 600, delay = 0.25, radius = 70, collision = {}, type = "linear"}
    WSpellData = {speed = 3000, range = 800, delay = 0.5, radius = 300, collision = {}, type = "circular"}
    RSpellData = {speed = 1050, range = 700, delay = 0.25, radius = 300, collision = {}, type = "circular"}
end

function Viktor:Tick()
    self.MyPos = Geometry:To2D(myHero.pos)
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(1400)
    CastingQ = myHero.activeSpell.name == "ViktorPowerTransfer"
    CastingW = myHero.activeSpell.name == "ViktorGravitonField"
    CastingR = myHero.activeSpell.name == "ViktorChaosStorm"
    --PrintChat(myHero.activeSpell.name)
    --PrintChat(myHero:GetSpellData(_R).name)
    self:Logic()
    if not IsReady(_E) then
        Edown = false
    end
    if Edown == true then
        _G.SDK.Orbwalker:SetMovement(false)
    else
        _G.SDK.Orbwalker:SetMovement(true)
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
            PrintChat("Enemy Loaded")
        end
    end
    if AllyLoaded == false then
        local CountAlly = 0
        for i, Ally in pairs(GetAllyHeroes()) do
            CountAlly = CountAlly + 1
        end
        if CountAlly < 1 then
            GetAllyHeroes()
        else
            AllyLoaded = true
            PrintChat("Ally Loaded")
        end
    end
	if Game.IsOnTop() then
		self:AutoLevelStart()
	end	
    if not PredLoaded then
		DelayAction(function()
			if self.ViktorMenu.Pred.Change:Value() == 1 then
				require('GamsteronPrediction')
				PredLoaded = true
			elseif self.ViktorMenu.Pred.Change:Value() == 2 then
				require('PremiumPrediction')
				PredLoaded = true
			else 
				require('GGPrediction')
				PredLoaded = true					
			end
		end, 1)	
	end
end

function Viktor:Draw()
	if Game.IsChatOpen() or myHero.dead then return end
	if self.ViktorMenu.Drawings.DrawQ:Value() then
		DrawCircle(myHero.pos, self.Q.range, 1, Draw.Color(96, 0, 206, 209))
	end
	if self.ViktorMenu.Drawings.DrawW:Value() then
		DrawCircle(myHero.pos, self.W.range, 1, Draw.Color(96, 138, 43, 226))
	end
	if self.ViktorMenu.Drawings.DrawE:Value() then
		DrawCircle(myHero.pos, self.E.minRange, 1, Draw.Color(96, 255, 140, 0))
		DrawCircle(myHero.pos, self.E.maxRange, 1, Draw.Color(96, 255, 140, 0))
	end
	if self.ViktorMenu.Drawings.DrawR:Value() then
		DrawCircle(myHero.pos, self.R.range, 1, Draw.Color(96, 218, 112, 214))
	end
	if not self.MyPos then return end
end

function Viktor:GetSkillOrder()
	local Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	if self.ViktorMenu.AutoLevel.Order:Value() == 1 then
		Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 2 then
		Spell1, Spell2, Spell3 = HK_W, HK_E, HK_Q
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 3 then
		Spell1, Spell2, Spell3 = HK_E, HK_Q, HK_W
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 4 then
		Spell1, Spell2, Spell3 = HK_E, HK_W, HK_Q
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 5 then
		Spell1, Spell2, Spell3 = HK_W, HK_Q, HK_E
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 6 then
		Spell1, Spell2, Spell3 = HK_Q, HK_E, HK_W
	end
	return Spell1, Spell2, Spell3
end

function Viktor:AutoLevelStart()
	if self.ViktorMenu.AutoLevel.on:Value() and not self.levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts
		local Spell1, Spell2, Spell3 = self:GetSkillOrder() 

		if (actualLevel == 18 and levelPoints == 0) or self.ViktorMenu.AutoLevel.LvL:Value() > actualLevel then return end
	
		if levelPoints > 0 then
			self.levelUP = true
			local Delay = self.ViktorMenu.AutoLevel.delay:Value()
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

function Viktor:KS()
    --PrintChat("ksing")
    for i, enemy in pairs(GetEnemyHeroes()) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
        end
    end
end 

function Viktor:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.ViktorMenu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.ViktorMenu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.ViktorMenu.FleeMode.UseQ:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.ViktorMenu.KSMode.UseQ:Value() then
            return true
        end
    elseif spell == _R then
        if mode == "Combo" and IsReady(spell) and self.ViktorMenu.ComboMode.UseR:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.ViktorMenu.HarassMode.UseR:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.ViktorMenu.KSMode.UseR:Value() then
            return true
        end
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.ViktorMenu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.ViktorMenu.HarassMode.UseW:Value() then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.ViktorMenu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.ViktorMenu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.ViktorMenu.FleeMode.UseE:Value() then
            return true
        end
    end
    return false
end


function Viktor:DelayEscapeClick(delay)
    if Game.Timer() - LastCalledTime > delay then
        LastCalledTime = Game.Timer()
        Control.RightClick(mousePos:To2D())
    end
end


function Viktor:Logic()
    if target == nil then return end
    if Mode() == "Combo" or Mode() == "Harass" and target then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if GetDistance(target.pos) < AARange then
            WasInRange = true
        end
        local ERange = 1025
        local QRange = 600
        local WRange = 800
        local RRange = 700
        local TargetNextSpot = GetUnitPositionNext(target)
        if TargetNextSpot then
            TargetAttacking = GetDistance(myHero.pos, target.pos) > GetDistance(myHero.pos, TargetNextSpot)
        else
            TargetAttacking = false
        end

        if self:CanUse(_W, Mode()) and ValidTarget(target, WRange) and Edown == false and not CastingQ and not CastingW then
            if target.pathing.isDashing and TargetAttacking and self.ViktorMenu.ComboMode.UseEDef:Value() then
                Control.CastSpell(HK_W, myHero)
            elseif GetDistance(myHero.pos, target.pos) < 300 and self.ViktorMenu.ComboMode.UseEDef:Value() then
                Control.CastSpell(HK_W, myHero)
            elseif self.ViktorMenu.ComboMode.UseEAtt:Value() then
                self:UseW(target, self.ViktorMenu.ComboMode.UseEAttHits:Value(), TargetAttacking)
            end
        end
        if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and not CastingQ and not CastingW and not CastingR then
            self:UseE(target)
        end
        if self:CanUse(_Q, Mode()) and ValidTarget(target, QRange) and Edown == false and not CastingQ and not CastingW and not CastingR then
            Control.CastSpell(HK_Q, target)
        end
        local RDmg = getdmg("R", target, myHero, 1, myHero:GetSpellData(_R).level)
        local RDmgTick = getdmg("R", target, myHero, 2, myHero:GetSpellData(_R).level)
        local RDmgTotal = RDmg + RDmgTick*2
        if self:CanUse(_R, Mode()) and ValidTarget(target, RRange) and Edown == false and not CastingQ and not CastingW and not CastingR and target.health < RDmgTotal and myHero:GetSpellData(_R).name == "ViktorChaosStorm"then
            Control.CastSpell(HK_R, target)
            --LastDirect = Game.Timer() + 1
        end
        if self:CanUse(_R, Mode()) and ValidTarget(target) and Edown == false and not CastingQ and not CastingW and not CastingR and myHero:GetSpellData(_R).name == "ViktorChaosStormGuide" and (myHero.attackData.state == 3 or GetDistance(myHero.pos, target.pos) > AARange) then
            self:DirectR(target.pos)
        end
    else
        WasInRange = false
    end     
end

function Viktor:DirectR(spot)
    if LastDirect - Game.Timer() < 0 then
        Control.CastSpell(HK_R, target)
        LastDirect = Game.Timer() + 1
    end
end

function Viktor:UseE2(ECastPos, unit, pred)
    if Control.IsKeyDown(HK_E) then
        Control.SetCursorPos(pred.CastPos)
        Control.KeyUp(HK_E)
        DelayAction(function() Control.SetCursorPos(ReturnMouse) end, 0.01)
        DelayAction(function() Edown = false end, 0.50)   
    end
end

function Viktor:OnPostAttackTick(args)
    if target then
    end
    attackedfirst = 1
    attacked = 1
end

function Viktor:OnPreAttack(args)
    if self:CanUse(_E, Mode()) and target then
    end
end


function Viktor:UseR1(unit, hits)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, RSpellData)
    --PrintChat("trying E")
    if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 701 and pred.HitCount >= hits then
            Control.CastSpell(HK_R, pred.CastPos)
            --Casted = 1
    end 
end

function Viktor:UseW(unit, hits, attacking)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, WSpellData)
    --PrintChat("trying E")
    if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 801 and pred.HitCount >= hits then
        if attacking == true then
            local Direction = Vector((pred.CastPos-myHero.pos):Normalized())
            local Wspot = pred.CastPos - Direction*100
            Control.CastSpell(HK_W, Wspot)
        else
            local Direction = Vector((pred.CastPos-myHero.pos):Normalized())
            local Wspot = pred.CastPos + Direction*100
            if GetDistance(myHero.pos, Wspot) > 800 then
                Control.CastSpell(HK_W, pred.CastPos)
            else
                Control.CastSpell(HK_W, Wspot)
            end
        end
            --Casted = 1
    end 
end

function Viktor:UseE(unit)
    if GetDistance(unit.pos, myHero.pos) < 1025 then
        --PrintChat("Using E")
        local Direction = Vector((myHero.pos-unit.pos):Normalized())
        local Espot = myHero.pos - Direction*480
        if GetDistance(myHero.pos, unit.pos) < 480 then
            Espot = unit.pos
        end
        --Control.SetCursorPos(Espot)
        --Control.CastSpell(HK_E, unit)
        local pred = _G.PremiumPrediction:GetPrediction(Espot, unit, ESpellData)
        if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and Espot:DistanceTo(pred.CastPos) < 501 then
            if Control.IsKeyDown(HK_E) and Edown == true then
                --_G.SDK.Orbwalker:SetMovement(false)
                --PrintChat("E down")
                self:UseE2(Espot, unit, pred)
            elseif Edown == false then
                --_G.SDK.Orbwalker:SetMovement(true)
                ReturnMouse = mousePos
                --PrintChat("Pressing E")
                Control.SetCursorPos(Espot)
                Control.KeyDown(HK_E)
                Edown = true
            end
        end
    end
end


class "Annie"

local EnemyLoaded = false
local AllyLoaded = false

local TargetTime = 0

local CastingQ = false
local CastingW = false
local CastingE = false
local CastingR = false
local Item_HK = {}

local WasInRange = false

local ForceTarget = nil

local RBuff = false
local StunBuff = false
local StunStacks = 0

local PostAttack = false
local LastSpellName = ""

local Etarget = nil
local LastCastDamage = 0
local EdmgRecv = 0
local Edmg = 0
local LastTargetHealth = 0
local Added = false
local EdmgFinal = 0


local QRange = 625
local WRange = 600
local RRange = 600
local AARange = 0


local LastHitTime = 0

local Tibbers = nil
local TibbersNextClick = 0

local CastedQ = false
local TickQ = false
local CastedW = false
local TickE = false
local CastedE = false
local TickE = false
local CastedR = false
local TickR = false

local ENeeded = false

local DamageValues = {TotalDamage = 0, PossibleDamage = 0, QDamage = 0, WDamage = 0, EDamage = 0, RDamage = 0, TibbersExtraDamage = 0, SpellsReady = 0}

local RStackTime = Game.Timer()
local LastRstacks = 0

local ARStackTime = Game.Timer()
local ALastRstacks = 0
local ALastTickTarget = myHero

local HeroIcon = "https://www.mobafire.com/images/champion/icon/annie.png"
local IgniteIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/f/f4/Ignite.png"
local QIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/2/25/Disintegrate.png"
local WIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/2/21/Incinerate.png"
local EIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/9/90/Molten_Shield.png"
local RIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/e/e7/Summon-_Tibbers.png"
local R2Icon = "https://static.wikia.nocookie.net/leagueoflegends/images/4/46/Command-_Tibbers.png"

function Annie:Menu()
    self.AnnieMenu = MenuElement({type = MENU, id = "Annie", name = "Impuls Annie", leftIcon = HeroIcon})
    self.AnnieMenu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseQ", name = "[Q] Use Q", value = true, leftIcon = QIcon})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseW", name = "[W] Use W", value = true, leftIcon = WIcon})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseE", name = "[E] Use E For Stuns", value = true, leftIcon = EIcon})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseEAttacked", name = "[E] Use E When Attacked", value = true})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseETibbers", name = "[E] Use E Tibbers Is Active", value = true})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseR", name = "[R] Enabled", value = true, leftIcon = RIcon})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseRNum", name = "[R] To Damage Number Of Targets", value = 4, min = 0, max = 5, step = 1})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseRNumStun", name = "[R] To Stun Number Of Targets", value = 2, min = 0, max = 5, step = 1})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseRComboFinish", name = "[R] In Combo When Killable", value = true})
        self.AnnieMenu.ComboMode:MenuElement({id = "UseRFinish", name = "[R] To KS A Single Target", value = true})
    self.AnnieMenu:MenuElement({id = "LastHitMode", name = "Last Hit", type = MENU})
        self.AnnieMenu.LastHitMode:MenuElement({id = "UseQ", name = "[Q] use Q", value = false, leftIcon = QIcon})
        self.AnnieMenu.LastHitMode:MenuElement({id = "StopQFarmStun", name = "[Q] Stop LastHit When Stun Ready", value = true})
        self.AnnieMenu.LastHitMode:MenuElement({id = "UseQHarass", name = "[Q] Last Hit In Harass Mode", value = true})
        self.AnnieMenu.LastHitMode:MenuElement({id = "UseQLastHit", name = "[Q] Last Hit In LastHit Mode", value = true})
        self.AnnieMenu.LastHitMode:MenuElement({id = "UseQLaneClear", name = "[Q] Last Hit In Lane Clear Mode", value = true})
    self.AnnieMenu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
        self.AnnieMenu.HarassMode:MenuElement({id = "UseQ", name = "[Q] use Q", value = false, leftIcon = QIcon})
        self.AnnieMenu.HarassMode:MenuElement({id = "UseW", name = "[W] use W", value = false, leftIcon = WIcon})
    self.AnnieMenu:MenuElement({id = "AutoMode", name = "Auto", type = MENU})
        self.AnnieMenu.AutoMode:MenuElement({id = "UseQ", name = "[Q] Use Q to Poke (No Stun)", value = false, leftIcon = QIcon})
    --self.AnnieMenu.AutoMode:MenuElement({id = "UseQFarm", name = "[Q] Use Q to Last Hit", value = false})
    --self.AnnieMenu.AutoMode:MenuElement({id = "StopQFarmStun", name = "Q[] Stop LastHit When Stun Ready", value = true})
        self.AnnieMenu.AutoMode:MenuElement({id = "UseQFinish", name = "[Q] To KS A Single Target", value = true, leftIcon = QIcon})
        self.AnnieMenu.AutoMode:MenuElement({id = "UseWFinish", name = "[W] To KS A Single Target", value = true, leftIcon = WIcon})
        self.AnnieMenu.AutoMode:MenuElement({id = "UseRFinish", name = "[R] To KS A Single Target", value = true, leftIcon = RIcon})
        self.AnnieMenu.AutoMode:MenuElement({id = "UseRNumStun", name = "[R] Auto Stun Number Of Targets", value = 3, min = 0, max = 5, step = 1, leftIcon = RIcon})
        self.AnnieMenu.AutoMode:MenuElement({id = "UseWNumStun", name = "[W] Auto Stun Number Of Targets", value = 2, min = 0, max = 5, step = 1, leftIcon = WIcon})
        self.AnnieMenu.AutoMode:MenuElement({id = "UseE", name = "[E] Use E When Attacked", value = true, leftIcon = EIcon})
        self.AnnieMenu:MenuElement({type = MENU, id = "AutoEAlly", name = "Auto Use [E] on Ally", leftIcon = EIcon})
        self.AnnieMenu.AutoEAlly:MenuElement({id = "UseEAlly", name = "[E] Use E on Ally", value = true, leftIcon = EIcon})	
        self.AnnieMenu.AutoEAlly:MenuElement({id = "Mana", name = "Min Mana", value = 20, min = 0, max = 100, identifier = "%"})
        for i, Hero in pairs(GetAllyHeroes()) do
            self.AnnieMenu.AutoEAlly:MenuElement({id = Hero.charName, name = "Use [E] on "..Hero.charName, value = false})		
        end
        self.AnnieMenu:MenuElement({id = "Draw", name = "Draw", type = MENU})
        self.AnnieMenu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
        self.AnnieMenu.Draw:MenuElement({id = "DrawAA", name = "Draw AA range", value = false})
        self.AnnieMenu.Draw:MenuElement({id = "DrawQ", name = "Draw Q range", value = false, leftIcon = QIcon})
        self.AnnieMenu.Draw:MenuElement({id = "DrawW", name = "Draw W range", value = false, leftIcon = WIcon})
        self.AnnieMenu.Draw:MenuElement({id = "DrawR", name = "Draw R range", value = false})
        self.AnnieMenu.Draw:MenuElement({id = "DrawBurstDamage", name = "Burst Damage", value = false})
    self.AnnieMenu:MenuElement({type = MENU, id = "AutoLevel", name =  myHero.charName.." AutoLevel Spells", leftIcon = HeroIcon})
        self.AnnieMenu.AutoLevel:MenuElement({id = "on", name = "Enabled", value = true})
        self.AnnieMenu.AutoLevel:MenuElement({id = "LvL", name = "AutoLevel start -->", value = 3, min = 1, max = 6, step = 1})
        self.AnnieMenu.AutoLevel:MenuElement({id = "delay", name = "Delay for Level up", value = 2, min = 0 , max = 10, step = 0.5, identifier = "sec"})
        self.AnnieMenu.AutoLevel:MenuElement({id = "Order", name = "Skill Order", value = 1, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})
    self.AnnieMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
        self.AnnieMenu.Pred:MenuElement({name = " ", drop = {"After change Prediction Type press 2xF6"}})	
        self.AnnieMenu.Pred:MenuElement({id = "Change", name = "Change Prediction Type", value = 4, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction", "InternalPrediction"}})	
        self.AnnieMenu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})
        self.AnnieMenu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
        self.AnnieMenu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
end

function Annie:Spells()
    --local Erange = self.AnnieMenu.ComboMode.UseEDistance:Value()
    RSpellData = {speed = math.huge, range = 600, delay = 0.25, radius = 250, collision = {""}, type = "circular"}

    WSpellData = {speed = math.huge, range = 600, delay = 0.25, angle = 50, radius = 50, collision = {}, type = "conic"}

    --self:QLaneClear()

end

function Annie:GetSkillOrder()
	local Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	if self.AnnieMenu.AutoLevel.Order:Value() == 1 then
		Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	elseif self.AnnieMenu.AutoLevel.Order:Value() == 2 then
		Spell1, Spell2, Spell3 = HK_W, HK_E, HK_Q
	elseif self.AnnieMenu.AutoLevel.Order:Value() == 3 then
		Spell1, Spell2, Spell3 = HK_E, HK_Q, HK_W
	elseif self.AnnieMenu.AutoLevel.Order:Value() == 4 then
		Spell1, Spell2, Spell3 = HK_E, HK_W, HK_Q
	elseif self.AnnieMenu.AutoLevel.Order:Value() == 5 then
		Spell1, Spell2, Spell3 = HK_W, HK_Q, HK_E
	elseif self.AnnieMenu.AutoLevel.Order:Value() == 6 then
		Spell1, Spell2, Spell3 = HK_Q, HK_E, HK_W
	end
	return Spell1, Spell2, Spell3
end

function Annie:AutoLevelStart()
	if self.AnnieMenu.AutoLevel.on:Value() and not self.levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts
		local Spell1, Spell2, Spell3 = self:GetSkillOrder() 

		if (actualLevel == 18 and levelPoints == 0) or self.AnnieMenu.AutoLevel.LvL:Value() > actualLevel then return end
	
		if levelPoints > 0 then
			self.levelUP = true
			local Delay = self.AnnieMenu.AutoLevel.delay:Value()
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

function Annie:QLaneClear()
    local getQDamage = function()
        local level = myHero:GetSpellData(_Q).level
        return ({80, 115, 150, 185, 220})[level] + 0.8 * myHero.ap
    end
    local canQLastHit = function()
        return self.AnnieMenu.LastHitMode.UseQ:Value() and (not StunBuffFarm or not self.AnnieMenu.LastHitMode.StopQFarmStun:Value())
    end
    local canQLaneClear = function()
        return false
    end
    local isQReady = function()
        return self:CanUse(_Q, "Force")
    end
    local QPrediction = {Delay = 0.25, Range = 625, Speed = 2500}
    --_G.SDK.Spell:SpellClear(_Q, QPrediction, isQReady, canQLastHit, canQLaneClear, getQDamage)
end
    

function Annie:Draw()
    if self.AnnieMenu.Draw.UseDraws:Value() then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if self.AnnieMenu.Draw.DrawAA:Value() then
            Draw.Circle(myHero.pos, AARange, 1, Draw.Color(255, 0, 191, 0))
        end
        if self.AnnieMenu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, QRange, 1, Draw.Color(255, 255, 0, 255))
        end
        if self.AnnieMenu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, WRange, 1, Draw.Color(255, 255, 0, 255))
        end
        if self.AnnieMenu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, RRange, 1, Draw.Color(255, 255, 0, 255))
        end
        if self.AnnieMenu.Draw.DrawBurstDamage:Value() and target and DamageValues then
            local EnemyHealth = math.floor(target.health)
            local TotalDamage = math.floor(DamageValues.TotalDamage)
            local PossibleDamage = math.floor(DamageValues.PossibleDamage)
            if TotalDamage > EnemyHealth then
                Draw.Text("Total Dmg:" .. TotalDamage .. "/" .. EnemyHealth, 15, target.pos:To2D().x-15, target.pos:To2D().y-125, Draw.Color(255, 0, 255, 0))
            elseif TotalDamage*1.3 > EnemyHealth then
                Draw.Text("Total Dmg:" .. TotalDamage .. "/" .. EnemyHealth, 15, target.pos:To2D().x-15, target.pos:To2D().y-125, Draw.Color(255, 255, 150, 150))
            else
                Draw.Text("Total Dmg:" .. TotalDamage .. "/" .. EnemyHealth, 15, target.pos:To2D().x-15, target.pos:To2D().y-125, Draw.Color(255, 255, 0, 0))
            end
        end
        if Tibbers then
            Draw.Circle(Tibbers.pos, 20, 1, Draw.Color(255, 255, 0, 255))
            Draw.Circle(Tibbers.pos, 120, 1, Draw.Color(255, 255, 0, 255))
            Draw.Circle(Tibbers.pos, 220, 1, Draw.Color(255, 255, 0, 255))
        end
    end
end

function Annie:GetAllDamage(unit, burst)
    local Qdmg = getdmg("Q", unit, myHero)
    local Wdmg = getdmg("W", unit, myHero) 
    local Edmg = getdmg("E", unit, myHero)
    local Rdmg = getdmg("R", unit, myHero)
    local AAdmg = getdmg("AA", unit, myHero)
    local TibbersAA = ((myHero:GetSpellData(_R).level * 25) + 25) + 0.15 * myHero.ap
    local TibbersAOE = ((myHero:GetSpellData(_R).level * 10) + 10) + 0.12 * myHero.ap
    local TibbersAAdmg = CalcMagicalDamage(myHero, unit, TibbersAA)
    local TibbersAOEdmg = CalcMagicalDamage(myHero, unit, TibbersAOE)
    local TibbersExtraDmg = (TibbersAAdmg + TibbersAOEdmg) * 4
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
    if self:CanUse(_E, "Force") and not burst then
        TotalDmg = TotalDmg + Edmg
        SpellsReady = SpellsReady + 1
    end
    if self:CanUse(_R, "Force") and not RBuff then
        TotalDmg = TotalDmg + Rdmg + TibbersExtraDmg
        SpellsReady = SpellsReady + 1
    end
    TotalDmg = TotalDmg + AAdmg
    PossibleDmg = Qdmg + Wdmg + Edmg + Rdmg + AAdmg + TibbersExtraDmg
    local Damages = {TotalDamage = TotalDmg, PossibleDamage = PossibleDmg, QDamage = Qdmg, WDamage = Wdmg, EDamage = Edmg, RDamage = Rdmg, TibbersExtraDamage = TibbersExtraDmg, SpellsReady = SpellsReady}      
    return Damages
end

function Annie:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end

    target = GetTarget(2000)
    if target and ValidTarget(target) then
        DamageValues = self:GetAllDamage(target, true)
    end
    AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    CastingQ = myHero.activeSpell.name == "AnnieQ"
    CastingW = myHero.activeSpell.name == "AnnieW"
    CastingE = myHero.activeSpell.name == "AnnieE"
    CastingR = myHero.activeSpell.name == "AnnieR"
    if TickR == true then
        if Tibbers == nil then
            PrintChat("Getting Tibbers")
            self:GetTibbers()
        else
            PrintChat("Found Tibbers")
            TickR = false
        end
    end
    if Tibbers then
        if Tibbers.dead or Tibbers.health <= 0 then
            Tibbers = nil
        end
    end
    StunBuff = BuffActive(myHero, "anniepassiveprimed")
    RBuff = BuffActive(myHero, "AnnieRController")
    StunStacks = GetBuffStacks(myHero, "anniepassivestack")
    --PrintChat(myHero.activeSpell.name)
    self:UpdateItems()
    self:Logic()
    self:Auto()
    self:Items2()
    self:ProcessSpells()
    if EnemyLoaded == false then
        local CountEnemy = 0
        for i, enemy in pairs(GetEnemyHeroes()) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
    end
    if AllyLoaded == false then
        local CountAlly = 0
        for i, Ally in pairs(GetAllyHeroes()) do
            CountAlly = CountAlly + 1
        end
        if CountAlly < 1 then
            GetAllyHeroes()
        else
            AllyLoaded = true
            PrintChat("Ally Loaded")
        end
    end
    if Game.IsOnTop() then
		self:AutoLevelStart()
	end	
    if not PredLoaded then
		DelayAction(function()
			if self.AnnieMenu.Pred.Change:Value() == 1 then
				require('GamsteronPrediction')
				PredLoaded = true
			elseif self.AnnieMenu.Pred.Change:Value() == 2 then
				require('PremiumPrediction')
				PredLoaded = true
			else 
				require('GGPrediction')
				PredLoaded = true					
			end
		end, 1)	
	end
end

function Annie:GetTibbers()
    for i = 1, Game.ObjectCount() do
        local object = Game.Object(i)
        
        if object and object.isAlly and object.name == "Tibbers" then 
            Tibbers = object
            return
        end
    end
    Tibbers = nil
end

function Annie:UpdateItems()
    Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
end

function Annie:Items1()
    if GetItemSlot(myHero, 3074) > 0 and ValidTarget(target, 300) then --rave 
        if myHero:GetSpellData(GetItemSlot(myHero, 3074)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3074)])
        end
    end
    if GetItemSlot(myHero, 3077) > 0 and ValidTarget(target, 300) then --tiamat
        if myHero:GetSpellData(GetItemSlot(myHero, 3077)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3077)])
        end
    end
    if GetItemSlot(myHero, 3144) > 0 and ValidTarget(target, 550) then --bilge
        if myHero:GetSpellData(GetItemSlot(myHero, 3144)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3144)], target)
        end
    end
    if GetItemSlot(myHero, 3153) > 0 and ValidTarget(target, 550) then -- botrk
        if myHero:GetSpellData(GetItemSlot(myHero, 3153)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3153)], target)
        end
    end
    if GetItemSlot(myHero, 3146) > 0 and ValidTarget(target, 700) then --gunblade hex
        if myHero:GetSpellData(GetItemSlot(myHero, 3146)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3146)], target)
        end
    end
    if GetItemSlot(myHero, 3748) > 0 and ValidTarget(target, 300) then -- Titanic Hydra
        if myHero:GetSpellData(GetItemSlot(myHero, 3748)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3748)])
        end
    end
end

function Annie:Items2()
    if GetItemSlot(myHero, 3139) > 0 then
        if myHero:GetSpellData(GetItemSlot(myHero, 3139)).currentCd == 0 then
            if IsImmobile(myHero) then
                Control.CastSpell(Item_HK[GetItemSlot(myHero, 3139)], myHero)
            end
        end
    end
    if GetItemSlot(myHero, 3140) > 0 then
        if myHero:GetSpellData(GetItemSlot(myHero, 3140)).currentCd == 0 then
            if IsImmobile(myHero) then
                Control.CastSpell(Item_HK[GetItemSlot(myHero, 3140)], myHero)
            end
        end
    end
end

function Annie:LastHit()
    local mtarget = nil
    local Qdmg = 0
    local AAdmg = 0
    if IsReady(_Q) then
        if Mode() ~= "Combo" then
            local QFarmLastHit = self.AnnieMenu.LastHitMode.UseQ:Value() and (not StunBuff or not self.AnnieMenu.LastHitMode.StopQFarmStun:Value()) and (Mode() == "Harass" or Mode() == "LastHit" or Mode() == "LaneClear")
            local QFarmAuto = self:CanUse(_Q, "AutoFarm") 
            if QFarmLastHit or QFarmAuto then
                local Minions = _G.SDK.ObjectManager:GetEnemyMinions(QRange)
                for i = 1, #Minions do
                    local minion = Minions[i]
                    Qdmg = getdmg("Q", minion, myHero)
                    AAdmg = getdmg("AA", minion, myHero)
                    if minion.charName == "SRU_OrderMinionSiege" then
                        if minion.health < Qdmg + (AAdmg * 3) then
                            if mtarget == nil or GetDistance(mtarget.pos) < GetDistance(minion.pos) then
                                mtarget = minion
                            end         
                        end
                    elseif minion.health < Qdmg then
                        if mtarget == nil or (GetDistance(mtarget.pos) < GetDistance(minion.pos) and mtarget.charName ~= "SRU_OrderMinionSiege") then
                            mtarget = minion
                        end         
                    end
                end
            end
        end
        if mtarget and ValidTarget(mtarget, QRange) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
            self:UseQ(mtarget)
        end
    end
end

function Annie:LastHit3()
    local laneMinion = nil
    local QFarmLastHit = self.AnnieMenu.LastHitMode.UseQ:Value() and (not StunBuff or not self.AnnieMenu.LastHitMode.StopQFarmStun:Value()) and (Mode() == "Harass" or Mode() == "LastHit" or Mode() == "LaneClear")
    if QFarmLastHit and IsReady(_Q) then
        for i = 1, #_G.SDK.HealthPrediction.FarmMinions do
            local minion = _G.SDK.HealthPrediction.FarmMinions[i]
            if minion and minion.Minon and GetDistance(minion.Minon.pos) < QRange then
                local num = getdmg("Q", minion.Minon, myHero)
                if minion.PredictedHP < num and not minion.AlmostAlmost then--and (self.AllyTurret == nil or minion.CanUnderTurret) then
                    laneMinion = minion.Minion
                end
            end
        end
      
        if laneMinion and ValidTarget(laneMinion, QRange) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
            self:UseQ(laneMinion)
        end
    end
end

function Annie:LastHit4()
    --PrintChat("Lasthit4")
    local LastHitTarget = nil
    local Minions = _G.SDK.ObjectManager:GetEnemyMinions(QRange)
    for i = 1, #Minions do
        local minion = Minions[i]
        if minion and ValidTarget(minion, QRange) then
            local MinionHealth = CheckHPPred(minion, 1500)
            local Qdmg = getdmg("Q", minion, myHero)
            --PrintChat(MinionHealth)
            if MinionHealth > 0 and MinionHealth < Qdmg then
                if LastHitTarget == nil or minion.health < LastHitTarget.health then
                    LastHitTarget = minion
                end
            end
        end
    end
    local QFarmLastHit = self.AnnieMenu.AutoMode.UseQ:Value() and (not StunBuff or not self.AnnieMenu.AutoMode.StopQFarmStun:Value())
    if LastHitTarget and QFarmLastHit and IsReady(_Q) then
        PrintChat("Ready Q")
        local Qdmg = getdmg("Q", LastHitTarget, myHero)
        local AAdmg = getdmg("AA", LastHitTarget, myHero)
        local TargetHealth = CheckHPPred(LastHitTarget, 1500)
        PrintChat(myHero.activeSpell.name)
        PrintChat(myHero.activeSpell.speed)
        local ActiveAttack = myHero.activeSpell.name == "AnnieBasicAttack" or myHero.activeSpell.name == "AnnieBasicAttack2"
        if ActiveAttack then
            local speed = myHero.activeSpell.speed
            local range = myHero.pos:DistanceTo(LastHitTarget.pos)
            local time = range / speed
            LastHitTime = Game.Timer() + time
        end
        if TargetHealth < Qdmg and Game.Timer() > LastHitTime then
            if ValidTarget(LastHitTarget, QRange) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() and not ActiveAttack then
                self:UseQ(LastHitTarget)
            end
        end
    end
end



function Annie:LastHit2()
    local LastHitTarget = _G.SDK.HealthPrediction:GetLaneMinion()
    local HarassCheck = Mode() == "Harass" and self.AnnieMenu.LastHitMode.UseQHarass:Value()
    local LastHitCheck = Mode() == "LastHit" and self.AnnieMenu.LastHitMode.UseQLastHit:Value()
    local LaneClearCheck = Mode() == "LaneClear" and self.AnnieMenu.LastHitMode.UseQLaneClear:Value()
    local QFarmLastHit = self.AnnieMenu.LastHitMode.UseQ:Value() and (not StunBuff or not self.AnnieMenu.LastHitMode.StopQFarmStun:Value()) and (HarassCheck or LastHitCheck or LaneClearCheck)
    if LastHitTarget and QFarmLastHit and IsReady(_Q) then
        local Qdmg = getdmg("Q", LastHitTarget, myHero)
        local AAdmg = getdmg("AA", LastHitTarget, myHero)
        local TargetHealth = CheckHPPred(LastHitTarget, 1500)
        --PrintChat(myHero.activeSpell.name)
        --PrintChat(myHero.activeSpell.speed)
        local ActiveAttack = myHero.activeSpell.name == "AnnieBasicAttack" or myHero.activeSpell.name == "AnnieBasicAttack2"
        if ActiveAttack then
            local speed = myHero.activeSpell.speed
            local range = myHero.pos:DistanceTo(LastHitTarget.pos)
            local time = range / speed
            LastHitTime = Game.Timer() + time
        end
        if TargetHealth < Qdmg and Game.Timer() > LastHitTime then
            if ValidTarget(LastHitTarget, QRange) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() and not ActiveAttack then
                self:UseQ(LastHitTarget)
            end
        end
    end
end

function Annie:Auto()
    --if Mode() ~= "Combo" then
        for i, enemy in pairs(GetEnemyHeroes()) do
            if enemy and not enemy.dead and ValidTarget(enemy) then
                local Qdmg = getdmg("Q", enemy, myHero)
                local Wdmg = getdmg("W", enemy, myHero)
                local Rdmg = getdmg("R", enemy, myHero)
                if Mode() ~= "Combo" and self:CanUse(_Q, "Auto") and ValidTarget(enemy) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
                    if GetDistance(enemy.pos) < QRange then
                        self:UseQ(enemy)
                    end               
                end
                if enemy.activeSpell and enemy.activeSpell.target == myHero.handle and enemy.activeSpell.isChanneling == false then
                    if self:CanUse(_E, "Auto") or (self:CanUse(_E, "Force") and self.AnnieMenu.ComboMode.UseEAttacked:Value()) then
                        self:UseE()
                    end
                end	
                for i, Ally in pairs(GetAllyHeroes()) do
                    if enemy.activeSpell and enemy.activeSpell.target == Ally.handle and enemy.activeSpell.isChanneling == false then
                        if self:CanUse(_E, "Auto") or (self:CanUse(_E, "Force") and self.AnnieMenu.AutoEAlly:Value() and self.AnnieMenu.AutoEAlly[ally.charName] and self.AnnieMenu.AutoEAlly[ally.charName]:Value()) then
                            self:AllyE()
                        end
                    end
                end
                if ValidTarget(enemy) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
                    if RBuff then

                    elseif GetDistance(enemy.pos) < RRange then
                        if self:CanUse(_R, "AutoKill") and Rdmg > enemy.health then
                            local QKill = Qdmg > enemy.health and self:CanUse(_Q, "AutoKill")
                            local WKill = Wdmg > enemy.health and self:CanUse(_Q, "AutoKill")
                            if not QKill and not WKill then
                                self:UseR(enemy)
                            end
                        end
                        if self:CanUse(_R, "Force") and self.AnnieMenu.AutoMode.UseRNumStun:Value() > 0 and StunBuff then
                            if StunStacks == 3 and self:CanUse(_E, "Force") then
                                self:UseE()
                            else
                                self:UseR(enemy, self.AnnieMenu.AutoMode.UseRNumStun:Value())
                            end
                        end
                    end
                end
                if ValidTarget(enemy) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
                    if GetDistance(enemy.pos) < WRange then
                        if self:CanUse(_W, "AutoKill") and Wdmg > enemy.health then
                            local QKill = Qdmg > enemy.health and self:CanUse(_Q, "AutoKill")
                            if not QKill then
                                self:UseW(enemy)
                            end
                        end
                        if self:CanUse(_W, "Force") and self.AnnieMenu.AutoMode.UseWNumStun:Value() > 0 and StunBuff then
                            if StunStacks == 3 and self:CanUse(_E, "Force") then
                                self:UseE()
                            else
                                self:UseW(enemy, self.AnnieMenu.AutoMode.UseRNumStun:Value())
                            end
                        end
                    end
                end
                if ValidTarget(enemy) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
                    if GetDistance(enemy.pos) < QRange then
                        if self:CanUse(_Q, "AutoKill") and Qdmg > enemy.health then
                            self:UseQ(enemy)
                        end
                    end
                end
            end
        end
        if Mode() ~= "Harass" then
            --self:LastHit4()
        end
    --end
    self:LastHit2()
end 


function Annie:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.AnnieMenu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.AnnieMenu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.AnnieMenu.AutoMode.UseQ:Value() and not StunBuff then
            return true
        end
        if mode == "AutoFarm" and IsReady(spell) and self.AnnieMenu.AutoMode.UseQFarm:Value() and (not self.AnnieMenu.AutoMode.StopQFarmStun:Value() or not StunBuff) then
            return true
        end
        if mode == "AutoKill" and IsReady(spell) and self.AnnieMenu.AutoMode.UseQFinish:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _R then
        if mode == "Combo" and IsReady(spell) and self.AnnieMenu.ComboMode.UseR:Value() then
            return true
        end
        if mode == "AutoKill" and IsReady(spell) and self.AnnieMenu.AutoMode.UseRFinish:Value() then
            return true
        end
        if mode == "AutoStun" and IsReady(spell) and self.AnnieMenu.AutoMode.UseRNumStun:Value() > 0 then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.AnnieMenu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.AnnieMenu.HarassMode.UseW:Value() then
            return true
        end
        if mode == "AutoKill" and IsReady(spell) and self.AnnieMenu.AutoMode.UseWFinish:Value() then
            return true
        end
        if mode == "AutoStun" and IsReady(spell) and self.AnnieMenu.AutoMode.UseWNumStun:Value() > 0 then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.AnnieMenu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "TibbersCombo" and IsReady(spell) and self.AnnieMenu.ComboMode.UseETibbers:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.AnnieMenu.AutoMode.UseE:Value() or self.AnnieMenu.AutoEAlly.UseEAlly:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    end
    return false
end


function Annie:Logic()
    if target == nil then 
        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
        return 
    end
    if Mode() == "Combo" or Mode() == "Harass" and target and ValidTarget(target) then
        --PrintChat("Logic")
        TargetTime = Game.Timer()
        self:Items1()
        local EnemyHealth = target.health
        local NeedE = false
        if GetDistance(target.pos) < AARange then
            WasInRange = true
        end
        if self:CanUse(_R, Mode()) and ValidTarget(target) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
            if RBuff then
                if Tibbers and GetDistance(target.pos, Tibbers.pos) > 625 then
                    self:UseTibbers(target)
                end
            elseif GetDistance(target.pos) < RRange then
                if self.AnnieMenu.ComboMode.UseRComboFinish:Value() and DamageValues.TotalDamage > EnemyHealth then
                    if StunStacks == 3 and self:CanUse(_E, Mode()) then
                        NeedE = true
                    elseif StunBuff or DamageValues.SpellsReady + StunStacks < 4 then
                        self:UseR(target)
                    end
                end
                if self.AnnieMenu.ComboMode.UseRFinish:Value() and DamageValues.RDamage > EnemyHealth then
                    local QKill = DamageValues.QDamage > EnemyHealth and self:CanUse(_Q, Mode())
                    local WKill = DamageValues.WDamage > EnemyHealth and self:CanUse(_W, Mode())
                    if not QKill and not WKill then
                        self:UseR(target)
                    end
                end
                if self.AnnieMenu.ComboMode.UseRNum:Value() > 0 or self.AnnieMenu.ComboMode.UseRNumStun:Value() > 0 then
                    local MinRNum = self.AnnieMenu.ComboMode.UseRNum:Value()
                    if StunBuff then
                        MinRNum = self.AnnieMenu.ComboMode.UseRNumStun:Value()
                    end
                    if StunStacks == 3 and self:CanUse(_E, Mode()) then
                        NeedE = true
                    else
                        self:UseR(target, MinRNum)
                    end
                end
            end
        end
        if self:CanUse(_Q, Mode()) and ValidTarget(target) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
            if GetDistance(target.pos) < QRange then
                if StunStacks == 3 and self:CanUse(_E, Mode()) then
                    NeedE = true
                else
                    self:UseQ(target)
                end
            end               
        end
        if self:CanUse(_W, Mode()) and ValidTarget(target) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
            if GetDistance(target.pos) < WRange then
                if StunStacks == 3 and self:CanUse(_E, Mode()) then
                    NeedE = true
                else
                    self:UseW(target)
                end
            end   
        end
        if self:CanUse(_E, Mode()) and ValidTarget(target) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then 
            if StunStacks == 3 and NeedE == true then
                self:UseE()
            end
        end
        if self:CanUse(_E, "TibbersCombo") and Mode() == "Combo" and ValidTarget(target) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
            if RBuff and not StunBuff then
                self:UseE()
            end   
        end
        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
    end     
end


function Annie:ProcessSpells()
    if myHero:GetSpellData(_Q).currentCd == 0 then
        CastedQ = false
    else
        if CastedQ == false then
            TickQ = true
            --PrintChat(TickQ)
        end
        CastedQ = true
    end
    if myHero:GetSpellData(_W).currentCd == 0 then
        CastedW = false
    else
        if CastedW == false then
            TickW = true
        end
        CastedW = true
    end
    if myHero:GetSpellData(_E).currentCd == 0 then
        CastedE = false
    else
        if CastedE == false then
            TickE = true
        end
        CastedE = true
    end
    if myHero:GetSpellData(_R).currentCd == 0 and not RBuff then
        CastedR = false
    else
        if CastedR == false then
            PrintChat("Ticked R")
            TickR = true
        end
        CastedR = true
    end
end

function Annie:CastingChecks()
    if not CastingQ and not CastingW and not CastingE and not CastingR then
        return true
    else
        return false
    end
end


function Annie:OnPostAttack(args)
    --PrintChat("Post")
    PostAttack = true
end

function Annie:OnPostAttackTick(args)
end

function Annie:OnPreAttack(args)
end

function Annie:UseW(unit, hits)
    local HitNumber = 0
    if hits then
        HitNumber = hits
    end
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, WSpellData)
    if pred.CastPos and pred.HitChance > 0 and pred.HitCount >= HitNumber then
        Control.CastSpell(HK_W, pred.CastPos)
    end
end

function Annie:UseR(unit, hits)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, RSpellData)
    if pred.CastPos and pred.HitChance > 0 then
        if hits == nil or pred.HitCount >= hits then
            Control.CastSpell(HK_R, pred.CastPos)
        end
    end
end

function Annie:UseTibbers(unit)
    if TibbersNextClick < Game.Timer() then
        Control.CastSpell(HK_R, unit)
        PrintChat("Moved Tibbers")
        TibbersNextClick = Game.Timer() + 0.3
    end
end

function Annie:UseQ(unit)
    Control.CastSpell(HK_Q, unit)
end

function Annie:UseE(unit)
    Control.CastSpell(HK_E)
end

function Annie:AllyE()
    local target = GetTarget(1200)     	
    if target == nil then return end
    for i, Ally in pairs(GetAllyHeroes()) do     	
    if Ally == nil then return end	
    if myHero.pos:DistanceTo(Ally.pos) < 800 and IsValid(Ally) and IsReady(_E) then 
        if self.AnnieMenu.AutoEAlly[Ally.charName]:Value() and IsValid(Ally) and myHero.mana/myHero.maxMana >= self.AnnieMenu.AutoEAlly.Mana:Value()/100 then
            Control.CastSpell(HK_E, Ally)
            end	
        end	
    end
end

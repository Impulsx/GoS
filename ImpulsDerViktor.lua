local Heroes = {"Viktor"}

if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"

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




function GetDistanceSqr(Pos1, Pos2)
    local Pos2 = Pos2 or myHero.pos
    local dx = Pos1.x - Pos2.x
    local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
    return dx^2 + dz^2
end

function GetDistance(Pos1, Pos2)
    return math.sqrt(GetDistanceSqr(Pos1, Pos2))
end

function GetEnemyHeroes()
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(EnemyHeroes, Hero)
            PrintChat(Hero.name)
        end
    end
    --PrintChat("Got Enemy Heroes")
end

function GetAllyHeroes()
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isAlly then
            table.insert(AllyHeroes, Hero)
            PrintChat(Hero.name)
        end
    end
    --PrintChat("Got Enemy Heroes")
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

function GetBuffExpire(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff.expireTime
        end
    end
    return nil
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

function SetMovement(bool)
    if _G.PremiumOrbwalker then
        _G.PremiumOrbwalker:SetAttack(bool)
        _G.PremiumOrbwalker:SetMovement(bool)       
    elseif _G.SDK then
        _G.SDK.Orbwalker:SetMovement(bool)
        _G.SDK.Orbwalker:SetAttack(bool)
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

class "Viktor"

local EnemyLoaded = false
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
--[[
local HeroIcon = "https://www.mobafire.com/images/champion/icon/viktor.png"
local IgniteIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/f/f4/Ignite.png"
local QIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/3/30/Augment-_Turbocharge.png"
local WIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/b/bf/Augment-_Magnetize.png"
local EIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/5/5d/Augment-_Aftershock.png"
local RIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/9/9f/Augment-_Perfect_Storm.png"
local R2Icon = "https://static.wikia.nocookie.net/leagueoflegends/images/1/1e/Chaos_Storm_2.png"
]]
function Viktor:__init()
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

function Viktor:Menu()
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

	self.ViktorMenu:MenuElement({type = MENU, id = "AutoLevel", name =  myHero.charName.." AutoLevel Spells"})
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
        for i, enemy in pairs(EnemyHeroes) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
    end
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
		--[[
		DelayAction(function()
			if self.ViktorMenu.Pred.Change:Value() == 1 then
				self.QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 210, Range = 800, Speed = math.huge, Collision = false, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
				self.WData = {Type = _G.SPELLTYPE_LINE, Delay = 0.00, Radius = 490, Range = 490, Speed = 2000, Collision = false, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
				self.EData = {Type = _G.SPELLTYPE_LINE, Delay = 0.45, Radius = 80, Range = 450, Speed = 1200, Collision = false, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
				self.RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.50, Radius = 160, Range = 1150, Speed =  3200, Collision = true, MaxCollision = 1, CollisionTypes = {_G.COLLISION_ENEMYHERO}}
			end
			if self.ViktorMenu.Pred.Change:Value() == 2 then
				self.QspellData = {speed = math.huge, range = 1025, delay = 0.25, radius = 210, type = "circular"}
				self.WspellData = {speed = 2000, range = 1025, delay = 0.00, radius = 490, type = "conic"}
				self.EspellData = {speed = 1200, range = 1025, delay = 0.45, radius = 80, collision = {"minion"}, type = "linear"}
				self.RspellData = {speed = 3200, range = 1025, delay = 0.50, radius = 160, type = "linear"}
			end
			if self.ViktorMenu.Pred.Change:Value() == 3 then  
				self.QPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 210, Range = 800, Speed = MathHuge, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
				self.WPrediction = GGPrediction:SpellPrediction({Delay = 0.00, Radius = 490, Range = 490, Speed = 2000, Collision = false, Type = GGPrediction.SPELLTYPE_CONE})
				self.EPrediction = GGPrediction:SpellPrediction({Delay = 0.45, Radius = 80,  Range = 450, Speed = 1200, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
				self.RPrediction = GGPrediction:SpellPrediction({Delay = 0.50, Radius = 160, Range = 1150, Speed = 3200, Collision = true, CollisionTypes = {GGPrediction.COLLISION_ENEMYHERO}, Type = GGPrediction.SPELLTYPE_LINE})
			end
				if self.ViktorMenu.Pred.Change:Value() == 4 then 
			end
		end, 1.2)	
		]]
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
    for i, enemy in pairs(EnemyHeroes) do
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
        if mode == "Combo" and IsReady(spell) and self.Viktormenu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Viktormenu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Viktormenu.FleeMode.UseQ:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.Viktormenu.KSMode.UseQ:Value() then
            return true
        end
    elseif spell == _R then
        if mode == "Combo" and IsReady(spell) and self.Viktormenu.ComboMode.UseR:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Viktormenu.HarassMode.UseR:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.Viktormenu.KSMode.UseR:Value() then
            return true
        end
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Viktormenu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Viktormenu.HarassMode.UseW:Value() then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Viktormenu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Viktormenu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Viktormenu.FleeMode.UseE:Value() then
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
            if target.pathing.isDashing and TargetAttacking and self.Viktormenu.ComboMode.UseEDef:Value() then
                Control.CastSpell(HK_W, myHero)
            elseif GetDistance(myHero.pos, target.pos) < 300 and self.Viktormenu.ComboMode.UseEDef:Value() then
                Control.CastSpell(HK_W, myHero)
            elseif self.Viktormenu.ComboMode.UseEAtt:Value() then
                self:UseW(target, self.Viktormenu.ComboMode.UseEAttHits:Value(), TargetAttacking)
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
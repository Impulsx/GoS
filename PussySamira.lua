local Heroes = {"Samira"}

if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"


----------------------------------------------------
--|                    Checks                    |--
----------------------------------------------------


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

-- [ AutoUpdate ]
do
    
    local Version = 0.07
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussySamira.lua",
            Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/PussySamira.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussySamira.version",
            Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/PussySamira.version"
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
            print("New PussySamira Version Press 2x F6")
        else
            print("PussySamira loaded")
        end
    
    end
    
    AutoUpdate()

end 

----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------


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

_G.LATENCY = 0.05


local CCSpells = {
	["AatroxW"] = {charName = "Aatrox", displayName = "Infernal Chains", slot = _W, type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 80, collision = true},
	["AhriSeduce"] = {charName = "Ahri", displayName = "Seduce", slot = _E, type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, collision = true},
	["AkaliR"] = {charName = "Akali", displayName = "Perfect Execution [First]", slot = _R, type = "linear", speed = 1800, range = 525, delay = 0, radius = 65, collision = false},
	["AkaliE"] = {charName = "Akali", displayName = "Shuriken Flip", slot = _E, type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 70, collision = true},
	["Pulverize"] = {charName = "Alistar", displayName = "Pulverize", slot = _Q, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 365, collision = false},
	["BandageToss"] = {charName = "Amumu", displayName = "Bandage Toss", slot = _Q, type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, collision = true},
	["CurseoftheSadMummy"] = {charName = "Amumu", displayName = "Curse of the Sad Mummy", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 550, collision = false},
	["FlashFrostSpell"] = {charName = "Anivia", displayName = "Flash Frost", missileName = "FlashFrostSpell", slot = _Q, type = "linear", speed = 850, range = 1100, delay = 0.25, radius = 110, collision = false},
	["EnchantedCrystalArrow"] = {charName = "Ashe", displayName = "Enchanted Crystal Arrow", slot = _R, type = "linear", speed = 1600, range = 25000, delay = 0.25, radius = 130, collision = false},
	["ApheliosR"] = {charName = "Aphelios", displayName = "Moonlight Vigil", slot = _R, type = "linear", speed = 2050, range = 1600, delay = 0.5, radius = 125, collision = false},
	["AurelionSolQ"] = {charName = "AurelionSol", displayName = "Starsurge", slot = _Q, type = "linear", speed = 850, range = 25000, delay = 0, radius = 110, collision = false},
	["AzirR"] = {charName = "Azir", displayName = "Emperor's Divide", slot = _R, type = "linear", speed = 1400, range = 500, delay = 0.3, radius = 250, collision = false},
	["BardQ"] = {charName = "Bard", displayName = "Cosmic Binding", slot = _Q, type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, collision = true},
	["BardR"] = {charName = "Bard", displayName = "Tempered Fate", slot = _R, type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, collision = false},
	["RocketGrab"] = {charName = "Blitzcrank", displayName = "Rocket Grab", slot = _Q, type = "linear", speed = 1800, range = 1150, delay = 0.25, radius = 140, collision = true},
	["BrandQ"] = {charName = "Brand", displayName = "Sear", slot = _Q, type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 60, collision = true},	
	["BraumQ"] = {charName = "Braum", displayName = "Winter's Bite", slot = _Q, type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = true},
	["BraumR"] = {charName = "Braum", displayName = "Glacial Fissure", slot = _R, type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, collision = false},
	["CamilleE"] = {charName = "Camille", displayName = "Hookshot [First]", slot = _E, type = "linear", speed = 1900, range = 800, delay = 0, radius = 60, collision = false},
	["CamilleEDash2"] = {charName = "Camille", displayName = "Hookshot [Second]", slot = _E, type = "linear", speed = 1900, range = 400, delay = 0, radius = 60, collision = false},	
	["CaitlynYordleTrap"] = {charName = "Caitlyn", displayName = "Yordle Trap", slot = _W, type = "circular", speed = MathHuge, range = 800, delay = 0.25, radius = 75, collision = false},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = _E, type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},
	["CassiopeiaW"] = {charName = "Cassiopeia", displayName = "Miasma", slot = _W, type = "circular", speed = 2500, range = 800, delay = 0.75, radius = 160, collision = false},
	["Rupture"] = {charName = "Chogath", displayName = "Rupture", slot = _Q, type = "circular", speed = MathHuge, range = 950, delay = 1.2, radius = 250, collision = false},
	["InfectedCleaverMissile"] = {charName = "DrMundo", displayName = "Infected Cleaver", slot = _Q, type = "linear", speed = 2000, range = 975, delay = 0.25, radius = 60, collision = true},
	["DianaQ"] = {charName = "Diana", displayName = "Crescent Strike", slot = _Q, type = "circular", speed = 1900, range = 900, delay = 0.25, radius = 185, collision = true},	
	["DravenDoubleShot"] = {charName = "Draven", displayName = "Double Shot", slot = _E, type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, collision = false},
	["DravenRCast"] = {charName = "Draven", displayName = "Whirling Death", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 0.25, radius = 160, collision = false},
	["EkkoQ"] = {charName = "Ekko", displayName = "Timewinder", slot = _Q, type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, collision = false},
	["EkkoW"] = {charName = "Ekko", displayName = "Parallel Convergence", slot = _W, type = "circular", speed = MathHuge, range = 1600, delay = 3.35, radius = 400, collision = false},
	["EliseHumanE"] = {charName = "Elise", displayName = "Cocoon", slot = _E, type = "linear", speed = 1600, range = 1075, delay = 0.25, radius = 55, collision = true},
	["EzrealR"] = {charName = "Ezreal", displayName = "Trueshot Barrage", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 1, radius = 160, collision = true},
	["FizzR"] = {charName = "Fizz", displayName = "Chum the Waters", slot = _R, type = "linear", speed = 1300, range = 1300, delay = 0.25, radius = 150, collision = false},
	["GalioE"] = {charName = "Galio", displayName = "Justice Punch", slot = _E, type = "linear", speed = 2300, range = 650, delay = 0.4, radius = 160, collision = false},
	["GarenQ"] = {charName = "Garen", displayName = "Decisive Strike", slot = _Q, type = "targeted", range = 225},
	["GnarQMissile"] = {charName = "Gnar", displayName = "Boomerang Throw", slot = _Q, type = "linear", speed = 2500, range = 1125, delay = 0.25, radius = 55, collision = false},
	["GnarBigQMissile"] = {charName = "Gnar", displayName = "Boulder Toss", slot = _Q, type = "linear", speed = 2100, range = 1125, delay = 0.5, radius = 90, collision = true},
	["GnarBigW"] = {charName = "Gnar", displayName = "Wallop", slot = _W, type = "linear", speed = MathHuge, range = 575, delay = 0.6, radius = 100, collision = false},
	["GnarR"] = {charName = "Gnar", displayName = "GNAR!", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 475, collision = false},
	["GragasQ"] = {charName = "Gragas", displayName = "Barrel Roll", slot = _Q, type = "circular", speed = 1000, range = 850, delay = 0.25, radius = 275, collision = false},
	["GragasR"] = {charName = "Gragas", displayName = "Explosive Cask", slot = _R, type = "circular", speed = 1800, range = 1000, delay = 0.25, radius = 400, collision = false},
	["GravesSmokeGrenade"] = {charName = "Graves", displayName = "Smoke Grenade", slot = _W, type = "circular", speed = 1500, range = 950, delay = 0.15, radius = 250, collision = false},
	["HeimerdingerE"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = _E, type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerEUlt"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = _E, type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HecarimUlt"] = {charName = "Hecarim", displayName = "Onslaught of Shadows", slot = _R, type = "linear", speed = 1100, range = 1650, delay = 0.2, radius = 280, collision = false},	
	["BlindMonkQOne"] = {charName = "Leesin", displayName = "Sonic Wave", slot = _Q, type = "linear", speed = 1800, range = 1100, delay = 0.25, radius = 60, collision = true},	
	["IllaoiE"] = {charName = "Illaoi", displayName = "Test of Spirit", slot = _E, type = "linear", speed = 1900, range = 900, delay = 0.25, radius = 50, collision = true},	
	["IreliaW2"] = {charName = "Irelia", displayName = "Defiant Dance", slot = _W, type = "linear", speed = MathHuge, range = 775, delay = 0.25, radius = 120, collision = false},
	["IreliaR"] = {charName = "Irelia", displayName = "Vanguard's Edge", slot = _R, type = "linear", speed = 2000, range = 950, delay = 0.4, radius = 160, collision = false},
	["IvernQ"] = {charName = "Ivern", displayName = "Rootcaller", slot = _Q, type = "linear", speed = 1300, range = 1075, delay = 0.25, radius = 80, collision = true},
	["JarvanIVDragonStrike"] = {charName = "JarvanIV", displayName = "Dragon Strike", slot = _Q, type = "linear", speed = MathHuge, range = 770, delay = 0.4, radius = 70, collision = false},
	["HowlingGaleSpell"] = {charName = "Janna", displayName = "Howling Gale", slot = _Q, type = "linear", speed = 1167, range = 1750, delay = 0, radius = 120, collision = false},
	["JhinW"] = {charName = "Jhin", displayName = "Deadly Flourish", slot = _W, type = "linear", speed = 5000, range = 2550, delay = 0.75, radius = 40, collision = false},
	["JhinE"] = {charName = "Jhin", displayName = "Captive Audience", slot = _E, type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, collision = false},
	["JhinRShot"] = {charName = "Jhin", displayName = "Curtain Call", slot = _R, type = "linear", speed = 5000, range = 3500, delay = 0.25, radius = 80, collision = false},
	["JinxWMissile"] = {charName = "Jinx", displayName = "Zap!", slot = _W, type = "linear", speed = 3300, range = 1450, delay = 0.6, radius = 60, collision = true},
	["KarmaQ"] = {charName = "Karma", displayName = "Inner Flame", slot = _Q, type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 60, collision = true},
	["KarmaQMantra"] = {charName = "Karma", displayName = "Inner Flame [Mantra]", slot = _Q, origin = "linear", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 80, collision = true},
	["KayleQ"] = {charName = "Kayle", displayName = "Radiant Blast", slot = _Q, type = "linear", speed = 2000, range = 850, delay = 0.5, radius = 60, collision = false},
	["KaynW"] = {charName = "Kayn", displayName = "Blade's Reach", slot = _W, type = "linear", speed = MathHuge, range = 700, delay = 0.55, radius = 90, collision = false},
	["KhazixWLong"] = {charName = "Khazix", displayName = "Void Spike [Threeway]", slot = _W, type = "threeway", speed = 1700, range = 1000, delay = 0.25, radius = 70,angle = 23, collision = true},
	["KledQ"] = {charName = "Kled", displayName = "Beartrap on a Rope", slot = _Q, type = "linear", speed = 1600, range = 800, delay = 0.25, radius = 45, collision = true},
	["KogMawVoidOozeMissile"] = {charName = "KogMaw", displayName = "Void Ooze", slot = _E, type = "linear", speed = 1400, range = 1360, delay = 0.25, radius = 120, collision = false},
	["LeblancE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Standard]", slot = _E, type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancRE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Ultimate]", slot = _E, type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeonaZenithBlade"] = {charName = "Leona", displayName = "Zenith Blade", slot = _E, type = "linear", speed = 2000, range = 875, delay = 0.25, radius = 70, collision = false},
	["LeonaSolarFlare"] = {charName = "Leona", displayName = "Solar Flare", slot = _R, type = "circular", speed = MathHuge, range = 1200, delay = 0.85, radius = 300, collision = false},
	["LilliaE"] = {charName = "Lillia", displayName = "Lillia E", slot = _E, type = "linear", speed = 1500, range = 750, delay = 0.4, radius = 150, collision = false},
	["LissandraQMissile"] = {charName = "Lissandra", displayName = "Ice Shard", slot = _Q, type = "linear", speed = 2200, range = 750, delay = 0.25, radius = 75, collision = false},
	["LuluQ"] = {charName = "Lulu", displayName = "Glitterlance", slot = _Q, type = "linear", speed = 1450, range = 925, delay = 0.25, radius = 60, collision = false},
	["LuxLightBinding"] = {charName = "Lux", displayName = "Light Binding", slot = _Q, type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 50, collision = false},
	["LuxLightStrikeKugel"] = {charName = "Lux", displayName = "Light Strike Kugel", slot = _E, type = "circular", speed = 1200, range = 1100, delay = 0.25, radius = 300, collision = true},
	["Landslide"] = {charName = "Malphite", displayName = "Ground Slam", slot = _E, type = "circular", speed = MathHuge, range = 0, delay = 0.242, radius = 400, collision = false},
	["UFSlash"] = {charName = "Malphite", displayName = "Unstoppable Force", slot = _R, type = "circular", speed = 1835, range = 1000, delay = 0, radius = 300, collision = false},	
	["MalzaharQ"] = {charName = "Malzahar", displayName = "Call of the Void", slot = _Q, type = "rectangular", speed = 1600, range = 900, delay = 0.5, radius = 400, radius2 = 100, collision = false},
	["MaokaiQ"] = {charName = "Maokai", displayName = "Bramble Smash", slot = _Q, type = "linear", speed = 1600, range = 600, delay = 0.375, radius = 110, collision = false},
	["MorganaQ"] = {charName = "Morgana", displayName = "Dark Binding", slot = _Q, type = "linear", speed = 1200, range = 1250, delay = 0.25, radius = 70, collision = true},
	["MordekaiserE"] = {charName = "Mordekaiser", displayName = "Death's Grasp", slot = _E, type = "linear", speed = MathHuge, range = 900, delay = 0.9, radius = 140, collision = false},	
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
	["SeraphineE"] = {charName = "Seraphine", displayName = "Beat Drop", slot = _E, type = "linear", speed = 500, range = 1300, delay = 0.25, radius = 35, collision = false},
	["SettE"] = {charName = "Sett", displayName = "Facebreaker", slot = _E, type = "linear", speed = MathHuge, range = 490, delay = 0.25, radius = 175, collision = false},
	["SennaW"] = {charName = "Senna", displayName = "Last Embrace", slot = _W, type = "linear", speed = 1150, range = 1300, delay = 0.25, radius = 60, collision = true},	
	["SejuaniR"] = {charName = "Sejuani", displayName = "Glacial Prison", slot = _R, type = "linear", speed = 1600, range = 1300, delay = 0.25, radius = 120, collision = false},
	["ShyvanaTransformLeap"] = {charName = "Shyvana", displayName = "Transform Leap", slot = _R, type = "linear", speed = 700, range = 850, delay = 0.25, radius = 150, collision = false},
	["ShenE"] = {charName = "Shen", displayName = "Shadow Dash", slot = _E, type = "linear", speed = 1200, range = 600, delay = 0, radius = 60, collision = false},	
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
	["ThreshQ"] = {charName = "Thresh", displayName = "Death Sentence", slot = _Q, type = "linear", speed = 1900, range = 1100, delay = 0.5, radius = 70, collision = true},	
	["TristanaW"] = {charName = "Tristana", displayName = "Rocket Jump", slot = _W, type = "circular", speed = 1100, range = 900, delay = 0.25, radius = 300, collision = false},
	["UrgotQ"] = {charName = "Urgot", displayName = "Corrosive Charge", slot = _Q, type = "circular", speed = MathHuge, range = 800, delay = 0.6, radius = 180, collision = false},
	["UrgotE"] = {charName = "Urgot", displayName = "Disdain", slot = _E, type = "linear", speed = 1540, range = 475, delay = 0.45, radius = 100, collision = false},
	["UrgotR"] = {charName = "Urgot", displayName = "Fear Beyond Death", slot = _R, type = "linear", speed = 3200, range = 1600, delay = 0.4, radius = 80, collision = false},
	["VarusE"] = {charName = "Varus", displayName = "Hail of Arrows", slot = _E, type = "linear", speed = 1500, range = 925, delay = 0.242, radius = 260, collision = false},
	["VarusR"] = {charName = "Varus", displayName = "Chain of Corruption", slot = _R, type = "linear", speed = 1950, range = 1200, delay = 0.25, radius = 120, collision = false},
	["VelkozQ"] = {charName = "Velkoz", displayName = "Plasma Fission", slot = _Q, type = "linear", speed = 1300, range = 1050, delay = 0.25, radius = 50, collision = true},
	["VelkozE"] = {charName = "Velkoz", displayName = "Tectonic Disruption", slot = _E, type = "circular", speed = MathHuge, range = 800, delay = 0.8, radius = 185, collision = false},
	["ViQ"] = {charName = "Vi", displayName = "Vault Breaker", slot = _Q, type = "linear", speed = 1500, range = 725, delay = 0, radius = 90, collision = false},	
	["ViktorGravitonField"] = {charName = "Viktor", displayName = "Graviton Field", slot = _W, type = "circular", speed = MathHuge, range = 800, delay = 1.75, radius = 270, collision = false},
	["WarwickR"] = {charName = "Warwick", displayName = "Infinite Duress", slot = _R, type = "linear", speed = 1800, range = 3000, delay = 0.1, radius = 55, collision = false},
	["XerathArcaneBarrage2"] = {charName = "Xerath", displayName = "Arcane Barrage", slot = _W, type = "circular", speed = MathHuge, range = 1000, delay = 0.75, radius = 235, collision = false},
	["XerathMageSpear"] = {charName = "Xerath", displayName = "Mage Spear", slot = _E, type = "linear", speed = 1400, range = 1050, delay = 0.2, radius = 60, collision = true},
	["XinZhaoW"] = {charName = "XinZhao", displayName = "Wind Becomes Lightning", slot = _W, type = "linear", speed = 5000, range = 900, delay = 0.5, radius = 40, collision = false},
	["YasuoQ3Mis"] = {charName = "Yasuo", displayName = "Yasuo Q3", slot = _Q, type = "linear", speed = 1200, range = 1000, delay = 0.339, radius = 90, collision = false},	
	["ZacQ"] = {charName = "Zac", displayName = "Stretching Strikes", slot = _Q, type = "linear", speed = 2800, range = 800, delay = 0.33, radius = 120, collision = false},
	["ZiggsW"] = {charName = "Ziggs", displayName = "Satchel Charge", slot = _W, type = "circular", speed = 1750, range = 1000, delay = 0.25, radius = 240, collision = false},
	["ZiggsE"] = {charName = "Ziggs", displayName = "Hexplosive Minefield", slot = _E, type = "circular", speed = 1800, range = 900, delay = 0.25, radius = 250, collision = false},
	["ZileanQ"] = {charName = "Zilean", displayName = "Time Bomb", slot = _Q, type = "circular", speed = MathHuge, range = 900, delay = 0.8, radius = 150, collision = false},
	["ZoeE"] = {charName = "Zoe", displayName = "Sleepy Trouble Bubble", slot = _E, type = "linear", speed = 1700, range = 800, delay = 0.3, radius = 50, collision = true},
	["ZyraE"] = {charName = "Zyra", displayName = "Grasping Roots", slot = _E, type = "linear", speed = 1150, range = 1100, delay = 0.25, radius = 70, collision = false},
	["ZyraR"] = {charName = "Zyra", displayName = "Stranglethorns", slot = _R, type = "circular", speed = MathHuge, range = 700, delay = 2, radius = 500, collision = false},
	["BrandConflagration"] = {charName = "Brand", slot = _R, type = "targeted", displayName = "Conflagration", range = 625, cc = true},
	["JarvanIVCataclysm"] = {charName = "JarvanIV", slot = _R, type = "targeted", displayName = "Cataclysm", range = 650},
	["JayceThunderingBlow"] = {charName = "Jayce", slot = _E, type = "targeted", displayName = "Thundering Blow", range = 240},
	["BlindMonkRKick"] = {charName = "LeeSin", slot = _R, type = "targeted", displayName = "Dragon's Rage", range = 375},
	["LissandraR"] = {charName = "Lissandra", slot = _R, type = "targeted", displayName = "Frozen Tomb", range = 550},
	["SeismicShard"] = {charName = "Malphite", slot = _Q, type = "targeted", displayName = "Seismic Shard", range = 625, cc = true},
	["AlZaharNetherGrasp"] = {charName = "Malzahar", slot = _R, type = "targeted", displayName = "Nether Grasp", range = 700},
	["MaokaiW"] = {charName = "Maokai", slot = _W, type = "targeted", displayName = "Twisted Advance", range = 525},
	["NautilusR"] = {charName = "Nautilus", slot = _R, type = "targeted", displayName = "Depth Charge", range = 825},
	["PoppyE"] = {charName = "Poppy", slot = _E, type = "targeted", displayName = "Heroic Charge", range = 475},
	["RyzeW"] = {charName = "Ryze", slot = _W, type = "targeted", displayName = "Rune Prison", range = 615},
	["Fling"] = {charName = "Singed", slot = _E, type = "targeted", displayName = "Fling", range = 125},
	["SkarnerImpale"] = {charName = "Skarner", slot = _R, type = "targeted", displayName = "Impale", range = 350},
	["TahmKenchW"] = {charName = "TahmKench", slot = _W, type = "targeted", displayName = "Devour", range = 250},
	["TristanaR"] = {charName = "Tristana", slot = _R, type = "targeted", displayName = "Buster Shot", range = 669},
	["TeemoQ"] = {charName = "Teemo", slot = _Q, type = "targeted", displayName = "Blinding Dart", range = 680},	
	["VeigarPrimordialBurst"] = {charName = "Veigar", slot = _R, type = "targeted", displayName = "Primordial Burst", range = 650},
	["VolibearQ"] = {charName = "Volibear", displayName = "Thundering Smash", slot = _Q, type = "targeted", range = 200},
	["YoneQ3"] = {charName = "Yone", displayName = "Mortal Steel [Storm]", slot = _Q, type = "linear", speed = 1500, range = 1050, delay = 0.25, radius = 80, collision = false},
	["YoneR"] = {charName = "Yone", displayName = "Fate Sealed", slot = _R, type = "linear", speed = MathHuge, range = 1000, delay = 0.75, radius = 112.5, collision = false}
}

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
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

local function CheckLoadedEnemyies()
	local count = 0
	for i, unit in ipairs(Enemies) do
        if unit and unit.isEnemy then
		count = count + 1
		end
	end
	return count
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
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

function IsFacing(unit)
    local V = Vector((unit.pos - myHero.pos))
    local D = Vector(unit.dir)
    local Angle = 180 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
    if math.abs(Angle) < 80 then 
        return true  
    end
    return false
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
--[[
local function ForceMovement(bool)
	if _G.EOWLoaded then
		EOW:ForceMovements(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:ForceMovement(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:ForceMovement(bool)	
	else
		GOS.ForceMovement = not bool
	end
end
]]

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.team ~= myHero.team then
			TableInsert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local function GetAllyHeroes()
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end 

local function GetEnemyTurrets()
	return Turrets
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

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
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

local function CalculateCollisionTime(startPos, endPos, unitPos, startTime, speed, delay, origin)
	local pos = startPos:Extended(endPos, speed * (GameTimer() - delay - startTime))
	return GetDistance(unitPos, pos) / speed
end

local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

local LastCheck = 0
local ReadyTimer = 0
local function IsReadyUlt()
	if Ready(_R) and Game.Timer() - LastCheck > 6 then
		LastCheck = Game.Timer()
		ReadyTimer = Game.Timer()
	end
	if Game.Timer() - ReadyTimer < 6 then
		return true
	end
	return false
end	

local function MyHeroNotReady()
    return myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero)
end

----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Samira"

local UltAlly = false		
local CastedR = false
local lastSpell = GetTickCount()
local lastW = GameTimer()

local CastingQ = myHero.activeSpell.name == "SamiraQ" 
local CastingW = myHero.activeSpell.name == "SamiraW"
local CastingE = myHero.activeSpell.name == "SamiraE"
local CastingR = myHero.activeSpell.name == "SamiraR"

local EBuff = GetBuffData(myHero, "SamiraRBuff")
local WActive = GetBuffData(myHero, "SamiraW")
local RReady = GetBuffData(myHero, "samirarreadybuff")

local Kraken = GetBuffData(myHero, "6672buff")
local KrakenStacks = 0

local QspellData = {speed = 2600, range = 950, delay = 0.25, radius = 60, collision = {"minion"}, type = "linear"}
local PredLoaded = false

if Kraken == false then
	KrakenStacks = 0
end

function Samira:__init()
	self:LoadMenu()

	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)

	if not PredLoaded then
		DelayAction(function()
			if self.Menu.MiscSet.Pred.Change:Value() == 1 then
				require('PremiumPrediction')
				PredLoaded = true
			else 
				require('GGPrediction')
				PredLoaded = true					
			end
		end, 1)	
	end
end

function Samira:LoadMenu()                     	
DetectedMissiles = {}; DetectedSpells = {}; Target = nil; Timer = 0	
	--MainMenu
self.Menu = MenuElement({type = MENU, id = "PussySamira", name = "PussySamira"})
self.Menu:MenuElement({name = " ", drop = {"Version 0.04"}})

	--AutoW
self.Menu:MenuElement({type = MENU, id = "WSet", name = "AutoW Incomming CC Spells"})
	self.Menu.WSet:MenuElement({name = " ", drop = {"After 30sec CCSpells are loaded"}})	
	self.Menu.WSet:MenuElement({id = "UseW", name = "UseW Anti CC", value = true})	
	self.Menu.WSet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})	

	--ComboMenu
self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})  
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseR", name = "[R]", value = true})	


	--HarassMenu
self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})		
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})

	--Lane/JungleClear
self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ", name = "[Q2]", value = true})
	self.Menu.ClearSet.Clear:MenuElement({id = "QCount", name = "min Minions for [Q2]", value = 3, min = 1, max = 7, step = 1})	
	self.Menu.ClearSet.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ", name = "[Q1]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})	


	--KillSteal
self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal Settings"})	
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})			

	
self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})	
			
	--Prediction
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.Menu.MiscSet.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Premium Prediction", "GGPrediction"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	
	Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	if Game.Timer() < 30 then
		DelayAction(function()
			for i, spell in pairs(CCSpells) do
				if not CCSpells[i] then return end
				for j, k in pairs(GetEnemyHeroes()) do
					if spell.charName == k.charName and not self.Menu.WSet.BlockList[i] then
						if not self.Menu.WSet.BlockList[i] then self.Menu.WSet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..Slot[spell.slot].." | "..spell.displayName, value = true}) end
					end
				end
			end				
		end, 30)
	else
		DelayAction(function()
			for i, spell in pairs(CCSpells) do
				if not CCSpells[i] then return end
				for j, k in pairs(GetEnemyHeroes()) do
					if spell.charName == k.charName and not self.Menu.WSet.BlockList[i] then
						if not self.Menu.WSet.BlockList[i] then self.Menu.WSet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..Slot[spell.slot].." | "..spell.displayName, value = true}) end
					end
				end
			end				
		end, 0.02)
	end	
end

function Samira:Tick()
	--[[
    target = GetTarget(myHero.range + myHero.boundingRadius)
    if target and ValidTarget(target) then
        --PrintChat(target.pos:To2D())
        --PrintChat(mousePos:To2D())
        ForceMovementSpot = ForceMovement(target)
    else
        _G.SDK.Orbwalker.ForceMovement = nil
    end
	if target and ValidTarget(target) then
		ForceMovementSpot = ForceMovement(target)
	else
		_G.SDK.Orbwalker.ForceMovement = nil
	end
	]]
	
	local currSpell = myHero.activeSpell
	target = GetTarget(myHero.range + myHero.boundingRadius)
	if currSpell and currSpell.name == "SamiraW" and currSpell.isChanneling or lastW + 0.76 < Game.Timer() then
		SetAttack(false)
		--ForceMovementSpot = self:ForceMovement(target)
	else
		SetAttack(true)
		--_G.SDK.Orbwalker.ForceMovement = nil
	end	
	--[[
		if myHero:GetSpellData(_R).currentCd > 5.75 then
			SetAttack(false)
		else
			UltAlly = false
			CastedR = false
			SetAttack(true)
		end	
	]]
	if currSpell and currSpell.name == "SamiraR" and currSpell.isChanneling or myHero:GetSpellData(_R).currentCd > 5.75 then
		--UltAlly = true
		--CastedR = true
		SetAttack(false)
		--ForceMovementSpot = self:ForceMovement(target)
	else
		UltAlly = false
		CastedR = false
		SetAttack(true)
		--_G.SDK.Orbwalker.ForceMovement = nil
	end	

	local EPostAttack = false
	if _G.SDK.Attack:IsActive() then
        WasAttacking = true

    else
        if WasAttacking == true then
            EPostAttack = true
            KrakenStacks = KrakenStacks + 1
        end
        WasAttacking = false
    end
	
	if heroes == false then 
		local EnemyCount = CheckLoadedEnemyies()			
		if EnemyCount < 1 then
			LoadUnits()
		else
			heroes = true
		end
	end	
 	
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "LaneClear" then
		self:JungleClear()
		self:Clear()
	end
		
	if CastedR == false then	
		self:KillSteal()
		
		if self.Menu.WSet.UseW:Value() and Ready(_W) then
			self:ProcessSpell()
			for i, spell in pairs(DetectedSpells) do
				UseW(i, spell)
			end
		end		
	end	
end

function Samira:CastingChecks()
    if not CastingQ or not CastingW or not CastingE or not CastingR then
        return true
    else
        return false
    end
end

function Samira:ForceMovement(unit)
    local EAARangel = unit.range + unit.boundingRadius
    local AARange = myHero.range + myHero.boundingRadius
    local MoveSpot = nil
    local RangeDif = AARange - EAARangel
    local ExtraRangeDist = RangeDif
    local ExtraRangeChaseDist = RangeDif - 100

    local ScanDirection = Vector((myHero.pos-mousePos):Normalized())
    local ScanDistance = GetDistance(myHero.pos, unit.pos) * 0.8
    local ScanSpot = myHero.pos - ScanDirection * ScanDistance
    

    local MouseDirection = Vector((unit.pos-ScanSpot):Normalized())
    local MouseSpotDistance = EAARangel + ExtraRangeDist
    if not IsFacing(unit) then
        MouseSpotDistance = EAARangel + ExtraRangeChaseDist
    end
    if MouseSpotDistance > AARange then
        MouseSpotDistance = AARange
    end

    local MouseSpot = unit.pos - MouseDirection * (MouseSpotDistance)
    local MouseDistance = GetDistance(unit.pos, mousePos)
    local ForceMovementSpotDirection = Vector((myHero.pos-MouseSpot):Normalized())
    local ForceMovementSpotDistance = GetDistance(myHero.pos, MouseSpot)
    if ForceMovementSpotDistance > 300 then
        ForceMovementSpotDistance = 300
    end
    local ForceMovementSpoty = myHero.pos - ForceMovementSpotDirection * ForceMovementSpotDistance
    MoveSpot = MouseSpot

    if MoveSpot then
        if GetDistance(myHero.pos, MoveSpot) < 50 or IsUnderEnemyTurret(MoveSpot) then
            _G.SDK.Orbwalker.ForceMovement = nil
        elseif GetDistance(myHero.pos, unit.pos) <= AARange-50 and (GetMode() == "Combo" or GetMode() == "Harass") and self:CastingChecks() and MouseDistance < 750 then
            _G.SDK.Orbwalker.ForceMovement = MoveSpot
        else
            _G.SDK.Orbwalker.ForceMovement = nil
        end
    end
    return ForceMovementSpoty
end

function Samira:IsDashPosTurret(unit)
    local myPos = Vector(myHero.pos.x, myHero.pos.y, myHero.pos.z)
    local endPos = Vector(unit.pos.x, myHero.pos.y, unit.pos.z)
    local pos = myPos:Extended(endPos, 600)
	
	for i, turret in ipairs(GetEnemyTurrets()) do
        local range = (turret.boundingRadius + 750 + myHero.boundingRadius / 2)
        if not turret.dead then 
            if turret.pos:DistanceTo(pos) < range then
				return true
			end
		end
	end	
    return false
end

function Samira:ProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and spell and CCSpells[spell.name] then
		if myHero.pos:DistanceTo(unit.pos) > 3000 or not self.Menu.WSet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle then 
				Control.CastSpell(HK_W)
				lastW = Game.Timer()
				TableRemove(DetectedSpells, i)				
			end
		else
			local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
			local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
			local endPos, range2 = CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
			TableInsert(DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col})
		end
	end
end

function UseW(i, s)
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == MathHuge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > GameTimer() then
		local Col = VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
		if s.type == "circular" or s.type == "linear" then 
			if GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
				local t = s.speed ~= MathHuge and CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay) or 0.29
				if t < 0.7 then
					Control.CastSpell(HK_W)
					lastW = Game.Timer()
				
				end				
			end
		end	
	else TableRemove(DetectedSpells, i) end
end
 
function Samira:Combo()
	if IsReadyUlt() and self.Menu.ComboSet.Combo.UseR:Value() and self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then	
		for i, Ally in ipairs(GetAllyHeroes()) do 
			if Ally and myHero.pos:DistanceTo(Ally.pos) <= 600 and IsValid(Ally) then
				if GetEnemyCount(600, myHero.pos) == 0 and GetEnemyCount(600, Ally.pos) >= 1 then
					if Game.Timer() - ReadyTimer <= 5.2 then
						if Control.CastSpell(HK_E, Ally) and RReady then
							UltAlly = true
							Control.CastSpell(HK_R)
							CastedR = true
						end	
					end
				end
			end
		end
	end	
					
local target = GetTarget(1000)     	
if target == nil or UltAlly then return end
	if IsValid(target) then
		
		if Ready(_R) and self.Menu.ComboSet.Combo.UseR:Value() then					
			
			if GetEnemyCount(1500, myHero.pos) == 1 then
				if myHero.pos:DistanceTo(target.pos) <= 500 and RReady then
					CastedR = true
					Control.CastSpell(HK_R)
				else
					if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then
						if myHero.pos:DistanceTo(target.pos) <= 600 and not self:IsDashPosTurret(target) then
							if Control.CastSpell(HK_E, target) and RReady then
								CastedR = true
								Control.CastSpell(HK_R)	
							end									
						end
					end	
				end
			else
				if GetEnemyCount(1500, myHero.pos) > 1 then
					if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then
						if myHero.pos:DistanceTo(target.pos) <= 600 and GetEnemyCount(600, target.pos) >= 1 and not not self:IsDashPosTurret(target) then
							if Control.CastSpell(HK_E, target) and RReady then
								CastedR = true
								Control.CastSpell(HK_R)
							end	
						end
					else
						if myHero.pos:DistanceTo(target.pos) <= 500 and GetEnemyCount(600, myHero.pos) >= 2 and RReady then
							CastedR = true
							Control.CastSpell(HK_R)	
						end	
					end
				end	
			end
		end			
		
		if CastedR then return end
		
		if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 600 and not self:IsDashPosTurret(target) then					
				if self.Menu.ComboSet.Combo.UseQ:Value() and Ready(_Q) then
					if Control.CastSpell(HK_E, target) and lastW + 0.76 < Game.Timer() and not CastingW or CastingR then
						Control.CastSpell(HK_Q)
					end
				else
					Control.CastSpell(HK_E, target)
				end	
			end
		end	
		
		if self.Menu.ComboSet.Combo.UseW:Value() and Ready(_W) and not CastingR then
			if myHero.pos:DistanceTo(target.pos) <= 325 then					
				Control.CastSpell(HK_W)
				lastW = Game.Timer()
			end
		end			
		
		if self.Menu.ComboSet.Combo.UseQ:Value() and Ready(_Q) and lastW + 0.76 < Game.Timer() and not CastingW or CastingR then 				 
			if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 600 and not self:IsDashPosTurret(target) then return end
			if myHero.pos:DistanceTo(target.pos) <= 950 and myHero.pos:DistanceTo(target.pos) > 325 then
				self:CastQ(target)		
			end
			if myHero.pos:DistanceTo(target.pos) < 325 then
				Control.CastSpell(HK_Q, target.pos)		
			end				
		end
	end	
end

function Samira:Harass()
local target = GetTarget(1000)     	
if target == nil then return end 
	if IsValid(target) then
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and lastW + 0.76 < Game.Timer() and not CastingW or CastingR then
			if myHero.pos:DistanceTo(target.pos) <= 950 and myHero.pos:DistanceTo(target.pos) > 325 then
				self:CastQ(target)		
			end
			if myHero.pos:DistanceTo(target.pos) < 325 then
				Control.CastSpell(HK_Q, target.pos)		
			end
		end	
	end	
end

local CastEQ = false
function Samira:KillSteal()
	if not Ready(_Q) and CastEQ then CastEQ = false end
	for i, target in ipairs(GetEnemyHeroes()) do     	
		
		if target and myHero.pos:DistanceTo(target.pos) <= 1000 and IsValid(target) then
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local AAdmg = getdmg("AA", target, myHero)
			if Kraken and KrakenStacks == 2 then
				AAdmg = AAdmg + 60 + (0.45*myHero.bonusDamage)
				--PrintChat(60 + (0.45*myHero.bonusDamage))
			end
			
			if CastEQ then
				if Control.CastSpell(HK_E, target) and lastW + 0.76 < Game.Timer() and not CastingW or CastingR then
					Control.CastSpell(HK_Q)
				end	
			end	
			
			if self.Menu.ks.UseQ:Value() and self.Menu.ks.UseE:Value() and Ready(_Q) and Ready(_E) then
				if myHero.pos:DistanceTo(target.pos) <= 600 then
					if QDmg+EDmg > target.health then
						CastEQ = true
					end
				end
			end
									
			if Ready(_Q) and self.Menu.ks.UseQ:Value()  and lastW + 0.76 < Game.Timer() and not CastingW or CastingR then	 
				if myHero.pos:DistanceTo(target.pos) <= 950 and myHero.pos:DistanceTo(target.pos) > 325 and QDmg > target.health then
					self:CastQ(target)	
				end	
				if myHero.pos:DistanceTo(target.pos) < 325 and QDmg > target.health then
					Control.CastSpell(HK_Q, target.pos)	
				end
			end
			
			if Ready(_E) and self.Menu.ks.UseE:Value() then
				if myHero.pos:DistanceTo(target.pos) <= 600 and EDmg > target.health then
					Control.CastSpell(HK_E, target)
				end
			end
		end
	end	
end	

function Samira:JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.pos:DistanceTo(minion.pos) < 950 then
 			
			if myHero.pos:DistanceTo(minion.pos) < 325 and self.Menu.ClearSet.JClear.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 then
				Control.CastSpell(HK_W)
				lastW = Game.Timer()               
            end           			
			
			if myHero.pos:DistanceTo(minion.pos) < 950 and myHero.pos:DistanceTo(minion.pos) > 325 and self.Menu.ClearSet.JClear.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 and Ready(_Q) and lastW + 0.76 < Game.Timer() and not CastingW or CastingR then
				Control.CastSpell(HK_Q, minion.pos)
			end	
			
			if myHero.pos:DistanceTo(minion.pos) < 325 and self.Menu.ClearSet.JClear.UseQ2:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 and Ready(_Q) and lastW + 0.76 < Game.Timer() and not CastingW or CastingR then
				Control.CastSpell(HK_Q, minion.pos)
			end			
        end
    end
end
			
function Samira:Clear()
	if self.Menu.ClearSet.Clear.UseQ:Value() and Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)

			if minion.team == TEAM_ENEMY and IsValid(minion) and myHero.pos:DistanceTo(minion.pos) < 325 then				
				local Count = GetMinionCount(300, minion)
				if Count >= self.Menu.ClearSet.Clear.QCount:Value() and lastW + 0.76 < Game.Timer() and not CastingW or CastingR then
					Control.CastSpell(HK_Q, minion.pos)
				end				
			end
		end
	end	
end

function Samira:CastQ(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 and not CastingW or CastingR then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredQ:Value(), pred.HitChance) then
			Control.CastSpell(HK_Q, pred.CastPos)
		end
	else
		self:CastGGPred(unit)	
	end
end	

function Samira:CastGGPred(unit)
	local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 950, Speed = 2600, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		  QPrediction:GetPrediction(unit, myHero)
	if QPrediction:CanHit(self.Menu.MiscSet.Pred.PredQ:Value()+1) then
		Control.CastSpell(HK_Q, QPrediction.CastPosition)
	end	
end
 
function Samira:Draw()
	
	if heroes == false then
		Draw.Text(myHero.charName.." is Loading (Search Enemies) !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 255, 0, 0))
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
    DrawCircle(myHero, 600, 1, DrawColor(255, 225, 255, 10))
	end                                                 
	if self.Menu.MiscSet.Drawing.DrawQ:Value() and Ready(_Q) then
    DrawCircle(myHero, 950, 1, DrawColor(225, 225, 0, 10))
	end
	if self.Menu.MiscSet.Drawing.DrawE:Value() and Ready(_E) then
    DrawCircle(myHero, 600, 1, DrawColor(225, 225, 125, 10))
	end
	if self.Menu.MiscSet.Drawing.DrawW:Value() and Ready(_W) then
    DrawCircle(myHero, 500, 1, DrawColor(225, 225, 125, 10))
	end
end
	
Callback.Add("Load", function()	
	if table.contains(Heroes, myHero.charName) then	
		_G[myHero.charName]()
		LoadUnits()	
	end	
end)

--local Heroes = {"Gwen"}

--if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"

local DrawInfo = false
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
--[[ not until proper rank is reached
-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "ImpulsGwen.lua",
            Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/ImpulsGwen.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "ImpulsGwen.version",
            Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/ImpulsGwen.version"
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
            print("New Impuls Gwen Version Press 2x F6")
        else
            print("Impuls Gwen loaded")
            DrawInfo = true
        end
    
    end
    
    AutoUpdate()

end 
]]

Callback.Add("Draw", function() 
	if DrawInfo then	
		Draw.Text("[ Impuls ] scripts will after ~[30-40]s in-game time", 18, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 0, 128, 128))
	end	
end)	
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

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function IsReady(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end

local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

function GetDistance(pos1, pos2)
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

function CheckLoadedEnemyies()
	local count = 0
	for i, unit in ipairs(Enemies) do
        if unit and unit.isEnemy then
		count = count + 1
		end
	end
	return count
end

function IsImmobile(unit)
    local MaxDuration = 0
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local BuffType = buff.type
            if BuffType == 5 or BuffType == 8 or BuffType == 12 or BuffType == 22 or BuffType == 23 or BuffType == 25 or BuffType == 30 or BuffType == 35 or buff.name == "recall" then
                local BuffDuration = buff.duration
                if BuffDuration > MaxDuration then
                    MaxDuration = BuffDuration
                end
            end
        end
    end
    return MaxDuration
end

function ValidTarget(unit, range)
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

function GetMode()   
    if _G.SDK then
        return 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "LaneClear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] and "JungleClear"
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

function SetAttack(bool)
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

local function GetEnemyHeroes()
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

local function GetAllyHeroes()
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

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function GetEnemyTurrets()
	return Turrets
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
function IsReadyUlt()
	if IsReady(_R) and Game.Timer() - LastCheck > 6 then
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
--|                Managment               		|--
----------------------------------------------------

class "Manager"

function Manager:__init()
    DelayAction(function()
        if myHero.charName == "Gwen" then
            DelayAction(function() self:LoadGwen() end, 1.05)
        --[[elseif myHero.charName == "Urgot" then
            DelayAction(function() self:LoadUrgot() end, 1.05)
        elseif myHero.charName == "Gnar" then
            DelayAction(function() self:LoadGnar() end, 1.05)]]
        end	
    end, math.max(0.07, 30 - Game.Timer()))
end

function Manager:LoadGwen()
    if DrawInfo then DrawInfo = false end
    Gwen:Spells()
    Gwen:Menu()

    --GetEnemyHeroes()
    Callback.Add("Tick", function() Gwen:Tick() end)
    Callback.Add("Draw", function() Gwen:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Gwen:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Gwen:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) Gwen:OnPostAttack(...) end)
    end
end

----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Gwen"

local EnemyLoaded = false
local TargetTime = 0

local CastingQ = false
local CastingW = false
local CastingE = false
local CastingR = false

local CastedQ = false
local TickQ = false
local CastedW = false
local TickE = false
local CastedE = false
local TickE = false
local CastedR = false
local TickR = false

local Item_HK = {}

local WasInRange = false

local ForceTarget = nil
local Rtarget = nil

local QBuff = nil
local WBuff = nil
local EBuff = nil
local RBuff = nil

local AARange = 150
local EAARange = 250

local ActiveQRange = 450
local QMaxRange = 850

local QStarted = Game.Timer()
local RStarted = Game.Timer()

local Flash = nil
local FlashSpell = nil

local HadStun = false
local StunTime = Game.Timer()
local UseBuffs = false
local ReturnMouse = mousePos

local Kraken = false
local KrakenStacks = 0
local EActive = false
local RActive = false

local PrimedFlashE = nil
local PrimedFlashETime = Game.Timer()

local Flash = nil
local FlashSpell = nil

local QRange = 450
local WRange = 425
local ERange = 400
local RRange = 1300

local EMouseSpot = nil

local WasAttacking = false

local CameraMoving = false

local Mounted = true

local PredLoaded = false

local DamageValues = {TotalDamage = 0, PossibleDamage = 0, QDamage = 0, WDamage = 0, EDamage = 0, RDamage = 0, SpellsReady = 0}

--[[
function Gwen:__init()
    self:Menu()
    self:Spells()

    --GetEnemyHeroes()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() Gwen:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) self:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) self:OnPostAttack(...) end)
    end
    if not PredLoaded then
		DelayAction(function()
		    if self.Menu.Pred.Change:Value() == 1 then
		    	require('PremiumPrediction')
		    	PredLoaded = true
             end
             if self.Menu.Pred.Change:Value() == 2 then
		    	require('GGPrediction')
		    	PredLoaded = true					
		    end
             if self.Menu.Pred.Change:Value() == 3 then
		    	PredLoaded = true					
            end
        end, 1)	
    end
    DelayAction(function()
        if self.Menu.Pred.Change:Value() == 1 then
            self.QspellData = {speed = 500, range = 450, delay = 0.50, radius = 60, collision = {""}, type = "linear"}
            self.WspellData = {speed = 500, range = 400, delay = 0.00, radius = 60, collision = {""}, type = "circle"}
            self.EspellData = {speed = 700, range = 400, delay = 0.00, radius = 60, collision = {""}, type = "linear"}
            self.RspellData = {speed = 1500, range = 1200, delay = 0.25, radius = 45, collision = {""}, type = "linear"}
        end
        if self.Menu.Pred.Change:Value() == 2 then
            self.QPrediction = GGPrediction:SpellPrediction({Delay = 0.50, Radius = 60, Range = 450, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
            self.WPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = 400, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
            self.EPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = 400, Speed = 700, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
            self.RPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 45, Range = 1200, Speed = 1500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
        end
        if self.Menu.Pred.Change:Value() == 3 then  
            self.QspellData = {speed = 500, range = 450, delay = 0.50, radius = 60, collision = {""}, type = "linear"}
            self.WspellData = {speed = 500, range = 400, delay = 0.00, radius = 60, collision = {""}, type = "circle"}
            self.EspellData = {speed = 700, range = 400, delay = 0.00, radius = 60, collision = {""}, type = "linear"}
            self.RspellData = {speed = 1500, range = 1200, delay = 0.25, radius = 45, collision = {""}, type = "linear"}				
        end
    end, 1.2)	
end
]]

local HeroIcon = "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/gwen.png"
local IgniteIcon = "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/Ignite.png"
local PIcon = "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/gwen_passive.gwen.png"
local QIcon = "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/gwen_q.gwen.png"
local WIcon = "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/gwen_w.gwen.png"
local EIcon = "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/gwen_e.gwen.png"
local RIcon = "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/gwen_r.gwen.png"
local R2Icon = "https://raw.githubusercontent.com/Impulsx/GoS/master/PageImage/gwen_r3.gwen.png"

function Gwen:Menu()
local DetectedMissiles = {}; DetectedSpells = {}; Target = nil; Timer = 0	
    self.Menu = MenuElement({type = MENU, id = "Impuls Gwen", name = "Impuls Gwen", leftIcon = HeroIcon})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU, leftIcon = PIcon})
        self.Menu.ComboMode:MenuElement({id = "UseQ", name = "[Q] Use Q", value = true, leftIcon = QIcon})
        --self.Menu.ComboMode:MenuElement({id = "UseQLastHit", name = "[Q] with max stack only", value = true, leftIcon = PIcon})
        self.Menu.ComboMode:MenuElement({id = "UseW", name = "[W] Use W", value = true, leftIcon = WIcon})
        self.Menu.ComboMode:MenuElement({id = "UseE", name = "[E] Use E", value = true, leftIcon = EIcon})
        self.Menu.ComboMode:MenuElement({id = "UseEDodge", name = "[E] To Dodge Targets Spells", value = true})
        self.Menu.ComboMode:MenuElement({id = "UseEDodgeCalc", name = "[E] Sometimes Dodge Away From mouse", value = true})
        self.Menu.ComboMode:MenuElement({id = "UseEDodgeChamps", name = "Enemies Spells To Dodge", type = MENU})
        self.Menu.ComboMode:MenuElement({id = "UseR", name = "[R] Enabled", value = true, leftIcon = RIcon})
        --self.Menu.ComboMode:MenuElement({id = "UseRNum", name = "[R] To Damage Number Of Targets", value = 3, min = 0, max = 5, step = 1})
        self.Menu.ComboMode:MenuElement({id = "UseRComboFinish", name = "[R] In Combo Only After Manual Cast", value = true, leftIcon = R2Icon})
    self.Menu:MenuElement({id = "LastHitMode", name = "Last Hit", type = MENU})
        self.Menu.LastHitMode:MenuElement({id = "UseQ", name = "[Q] use Q", value = false, leftIcon = QIcon})
        self.Menu.LastHitMode:MenuElement({id = "UseQLastHit", name = "[Q] Max stack only to Last Hit", value = true, leftIcon = PIcon})
        self.Menu.LastHitMode:MenuElement({id = "QCount", name = "min Minions for [Q]", value = 3, min = 1, max = 8, step = 1})
        self.Menu.LastHitMode:MenuElement({id = "UseE", name = "[E]", value = true, leftIcon = EIcon})	
		self.Menu.LastHitMode:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
        self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
        self.Menu.HarassMode:MenuElement({id = "UseQ", name = "[Q] use Q", value = false, leftIcon = QIcon})
        self.Menu.HarassMode:MenuElement({id = "UseW", name = "[W] use W", value = false, leftIcon = WIcon})
        self.Menu.HarassMode:MenuElement({id = "UseE", name = "[E] use E", value = false, leftIcon = EIcon})
	self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
		self.Menu.ClearSet.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true, leftIcon = QIcon})
		self.Menu.ClearSet.Clear:MenuElement({id = "QCount", name = "Min Minions for [Q]", value = 3, min = 1, max = 8, step = 1})	
        self.Menu.ClearSet.Clear:MenuElement({id = "UseE", name = "[E]", value = true, leftIcon = EIcon})
		self.Menu.ClearSet.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
		self.Menu.ClearSet.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true, leftIcon = QIcon})	
		self.Menu.ClearSet.JClear:MenuElement({id = "UseE", name = "[E]", value = true, leftIcon = EIcon})	
		self.Menu.ClearSet.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})	
    self.Menu:MenuElement({id = "AutoMode", name = "Auto", type = MENU})
        self.Menu.AutoMode:MenuElement({id = "UseQ", name = "[Q] Use Q to Poke", value = false, leftIcon = QIcon})
        self.Menu.AutoMode:MenuElement({id = "UseQFinish", name = "[Q] To KS A Single Target", value = true, leftIcon = QIcon})
        self.Menu.AutoMode:MenuElement({id = "UseEFinish", name = "[E]+ AA To KS A Single Target", value = true, leftIcon = WIcon})
        self.Menu.AutoMode:MenuElement({id = "UseRFinish", name = "[R] To KS A Single Target", value = false, leftIcon = RIcon})
        --self.Menu.AutoMode:MenuElement({id = "UseRNum", name = "[R] Auto Number Of Targets", value = 3, min = 0, max = 5, step = 1, leftIcon = RIcon})
    self.Menu:MenuElement({type = MENU, id = "WSet", name = "AutoW Incomming CC Spells"})
	    self.Menu.WSet:MenuElement({name = "WSetSpace", name = "After 30sec CCSpells are loaded", type = SPACE})	
	    self.Menu.WSet:MenuElement({id = "UseW", name = "UseW Anti CC", value = true, leftIcon = WIcon})	
	    self.Menu.WSet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})	
    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
        self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
        self.Menu.Draw:MenuElement({id = "DrawAA", name = "Draw AA range", value = false})
        self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q range", value = false, leftIcon = QIcon})
		self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W range", value = false, leftIcon = WIcon})
        self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E range", value = false, leftIcon = EIcon})
		self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R range", value = false, leftIcon = RIcon})
        self.Menu.Draw:MenuElement({id = "DrawBurstDamage", name = "Burst Damage", value = false})
        self.Menu.Draw:MenuElement({id = "DrawJng", name = "Draw Jungler Info", value = true})
    self.Menu:MenuElement({type = MENU, id = "AutoLevel", name =  myHero.charName.." AutoLevel Spells", leftIcon = HeroIcon})
        self.Menu.AutoLevel:MenuElement({id = "on", name = "Enabled", value = true})
        self.Menu.AutoLevel:MenuElement({id = "LvL", name = "AutoLevel start -->", value = 4, min = 1, max = 6, step = 1})
        self.Menu.AutoLevel:MenuElement({id = "delay", name = "Delay for Level up", value = 2, min = 0 , max = 10, step = 0.5, identifier = "sec"})
        self.Menu.AutoLevel:MenuElement({id = "Order", name = "Skill Order", value = 6, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})
	self.Menu:MenuElement({id = "GwenOrbMode", name = "Orbwalker", type = MENU})
    	self.Menu.GwenOrbMode:MenuElement({id = "UseKiteHelperWalk", name = "Kite Helper: Movement Assist", value = false})
    	self.Menu.GwenOrbMode:MenuElement({id = "UseKiteHelperWalkInfo", name = "Assist Movement To Kite Enemies", type = SPACE})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperMouseDistance", name = "Mouse Range From Target", value = 50, min = 0, max = 1500, step = 50})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperMouseDistanceInfo", name = "Max Mouse Distance From Target To Kite", type = SPACE})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperRange", name = "Kite Distance Adjustment", value = 0, min = -500, max = 500, step = 10})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperRangeInfo", name = "Adjust the Kiting Distance By This Much", type = SPACE})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperRangeFacing", name = "Kite Distance Adjustment (Fleeing)", value = -120, min = -500, max = 500, step = 10})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperRangeFacingInfo", name = "Adjust the Kiting Distance Against A Fleeing Target", type = SPACE})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperRangeE1Info", name = "--------------------------------------------", type = SPACE})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperRangeE2Info", name = "Kiting Range Effects E's Location In Combo", type = SPACE, leftIcon = EIcon})
    	self.Menu.GwenOrbMode:MenuElement({id = "KiteHelperRangeE3Info", name = "--------------------------------------------", type = SPACE})
    self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
        self.Menu.Pred:MenuElement({name = " ", name = "After change Prediction Type press 2xF6", type = SPACE})
        self.Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Type", value = 2, drop = {"Premium Prediction", "GGPrediction", "NoPred/Internal"}})
        self.Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})
		self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})
        self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
        self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
        	
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
    --PrintChat("Enemy Spells Loaded")
	end	
end


function Gwen:ProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and spell and CCSpells[spell.name] then
		if myHero.pos:DistanceTo(unit.pos) > 3000 or not self.Menu.WSet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle then
                --PrintChat("Using W to block CC spell") 
				Control.CastSpell(HK_W)
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

function Gwen:GetSkillOrder()
	local Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	if self.Menu.AutoLevel.Order:Value() == 1 then
		Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	elseif self.Menu.AutoLevel.Order:Value() == 2 then
		Spell1, Spell2, Spell3 = HK_W, HK_E, HK_Q
	elseif self.Menu.AutoLevel.Order:Value() == 3 then
		Spell1, Spell2, Spell3 = HK_E, HK_Q, HK_W
	elseif self.Menu.AutoLevel.Order:Value() == 4 then
		Spell1, Spell2, Spell3 = HK_E, HK_W, HK_Q
	elseif self.Menu.AutoLevel.Order:Value() == 5 then
		Spell1, Spell2, Spell3 = HK_W, HK_Q, HK_E
	elseif self.Menu.AutoLevel.Order:Value() == 6 then
		Spell1, Spell2, Spell3 = HK_Q, HK_E, HK_W
	end
	return Spell1, Spell2, Spell3
end

function Gwen:AutoLevelStart()
	if self.Menu.AutoLevel.on:Value() and not self.levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts
		local Spell1, Spell2, Spell3 = self:GetSkillOrder() 

		if (actualLevel == 18 and levelPoints == 0) or self.Menu.AutoLevel.LvL:Value() > actualLevel then return end
	
		if levelPoints > 0 then
			self.levelUP = true
			local Delay = self.Menu.AutoLevel.delay:Value()
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

function Gwen:Spells()
    --[[
    require('GGPrediction')
    self.QPrediction = GGPrediction:SpellPrediction({Delay = 0.50, Radius = 60, Range = 450, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
    self.WPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = 400, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
    self.EPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = 400, Speed = 700, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
    self.RPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 45, Range = 1200, Speed = 1500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
    
    local QPrediction = GGPrediction:SpellPrediction({Delay = 0.50, Radius = 60, Range = 450, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
    local WPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = 400, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
    local EPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = 400, Speed = 700, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
    local RPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 45, Range = 1200, Speed = 1500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
    ]]

    if not PredLoaded then
		DelayAction(function()
		    if self.Menu.Pred.Change:Value() == 1 then
		    	require('PremiumPrediction')
		    	PredLoaded = true
             end
             if self.Menu.Pred.Change:Value() == 2 then
		    	require('GGPrediction')
		    	PredLoaded = true					
		    end
             if self.Menu.Pred.Change:Value() == 3 then
		    	PredLoaded = true					
            end
        end, 1)	
    end
    DelayAction(function()
        if self.Menu.Pred.Change:Value() == 1 then
            self.QspellData = {speed = 500, range = QRange, delay = 0.50, radius = 60, collision = {""}, type = "linear"}
            self.WspellData = {speed = 500, range = WRange, delay = 0.00, radius = 60, collision = {""}, type = "circle"}
            self.EspellData = {speed = 700, range = ERange, delay = 0.00, radius = 160, collision = {""}, type = "linear"}
            self.RspellData = {speed = 500, range = RRange, delay = 0.25, radius = 45, collision = {""}, type = "linear"}
        end
        if self.Menu.Pred.Change:Value() == 2 then
            self.QPrediction = GGPrediction:SpellPrediction({Delay = 0.50, Radius = 60, Range = QRange, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
            self.WPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = WRange, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
            self.EPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = ERange, Speed = 700, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
            self.RPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 45, Range = RRange, Speed = 1500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
        end
        if self.Menu.Pred.Change:Value() == 3 then  
            self.QspellData = {speed = 500, range = QRange, delay = 0.50, radius = 60, collision = {""}, type = "linear"}
            self.WspellData = {speed = 500, range = WRange, delay = 0.00, radius = 60, collision = {""}, type = "circle"}
            self.EspellData = {speed = 700, range = ERange, delay = 0.00, radius = 60, collision = {""}, type = "linear"}
            self.RspellData = {speed = 1500, range = RRange, delay = 0.25, radius = 45, collision = {""}, type = "linear"}				
        end
    end, 1.2)	
end

function Gwen:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if self.Menu.Draw.DrawAA:Value() then
            Draw.Circle(myHero.pos, AARange, 1, Draw.Color(255, 0, 191, 0))
        end
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, QRange, 1, Draw.Color(255, 255, 0, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, WRange, 1, Draw.Color(255, 0, 0, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, ERange, 1, Draw.Color(255, 0, 255, 0))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, RRange, 1, Draw.Color(255, 255, 255, 255))
        end
		if self.Menu.Draw.DrawBurstDamage:Value() and target and DamageValues then
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
        for i, enemy in pairs(GetEnemyHeroes()) do
            if self.Menu.Draw.DrawJng:Value() then
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
        end
	end
end

function Gwen:CanUse(spell, mode)
    if mode == nil then
        mode = GetMode()
    end
    --PrintChat(GetMode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseQ:Value() then
            return true
        end
        if mode == "LastHit" and IsReady(spell) and self.Menu.LastHitMode.UseQ:Value() then
            return true
        end
        if mode == "LaneClear" and IsReady(spell) and self.Menu.ClearSet.Clear.UseQ:Value() then
            return true
        end
        if mode == "JungleClear" and IsReady(spell) and self.Menu.ClearSet.JClear.UseQ:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseW:Value() then
            return true
        end
        if mode == "LastHit" and IsReady(spell) and self.Menu.LastHitMode.UseW:Value() then
            return true
        end
        if mode == "LaneClear" and IsReady(spell) and self.Menu.ClearSet.Clear.UseW:Value() then
            return true
        end
        if mode == "JungleClear" and IsReady(spell) and self.Menu.ClearSet.Clear.UseW:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _R then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseR:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseR:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    end
    return false
end

function Gwen:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(2000)
	if target and ValidTarget(target) then
        DamageValues = self:GetAllDamage(target, true)
    end
    AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    if target then
        EAARange = _G.SDK.Data:GetAutoAttackRange(target)
    end
    if target and ValidTarget(target) then
        --PrintChat(target.pos:To2D())
        --PrintChat(mousePos:To2D())
        EMouseSpot = self:KiteHelper(target)
    else
        _G.SDK.Orbwalker.ForceMovement = nil
    end

    --PrintChat(myHero.activeSpell.name)
    self:UpdateItems()
    self:Logic()
    self:Auto()
    self:ItemsCC()
    self:ProcessSpells()
    if EnemyLoaded == false then
        local CountEnemy = 0
        for i, enemy in pairs(GetEnemyHeroes()) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            self:MenuEvadeE()
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
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
			self:Clear()
            self:JungleClear()
        elseif Mode == "JungleClear" then
            self:JungleClear()
		elseif Mode == "LastHit" then
			self:LastHit()
		elseif Mode == "Flee" then
			self:Flee()
		end
		if CastedR == false then	
			self:KillSteal()
        end

	if Game.IsOnTop() then
		self:AutoLevelStart()
    end
	if self.Menu.WSet.UseW:Value() and IsReady(_W) then
		self:ProcessSpell()
		for i, spell in pairs(DetectedSpells) do
			Gwen:CastW(i, spell)
		end
	end		
end

function Gwen:IsDashPosTurret(unit)
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

function Gwen:UpdateItems()
    Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
end

function Gwen:ItemsCC()
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

function Gwen:ClosestPointOnLineSegment(p, p1, p2)
    local px = p.x
    local pz = p.z
    local ax = p1.x
    local az = p1.z
    local bx = p2.x
    local bz = p2.z
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((px - ax) * bxax + (pz - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if (t < 0) then
        return p1, false
    end
    if (t > 1) then
        return p2, false
    end
    return {x = ax + t * bxax, z = az + t * bzaz}, true
end

function Gwen:DamageChecks(unit)
    local Qdmg = getdmg("Q", unit, myHero, 1, myHero:GetSpellData(_Q).level)
    local Edmg = getdmg("E", unit, myHero, 1, myHero:GetSpellData(_E).level)
    local Rdmg = getdmg("R", unit, myHero, 1, myHero:GetSpellData(_R).level)
    local AAdmg = getdmg("AA", unit, myHero)
    if Kraken and KrakenStacks == 2 then
        AAdmg = AAdmg + 60 + (0.45*myHero.bonusDamage)
        --PrintChat(60 + (0.45*myHero.bonusDamage))
    end
    local UnitHealth = unit.health + unit.shieldAD
    local BurstDmg = Qdmg + Rdmg + Edmg + (AAdmg*3)
    local QCheck = UnitHealth - (Qdmg + AAdmg) < 0
    local ECheck = UnitHealth - (Edmg) < 0
    local RCheck = UnitHealth - Rdmg < 0
    local QECheck = UnitHealth - (Qdmg + AAdmg + Edmg) < 0
    local QRCheck = UnitHealth - (Qdmg + AAdmg + Rdmg) < 0
    local ERCheck = UnitHealth - (Edmg + Rdmg) < 0
    local QERCheck = UnitHealth - (Qdmg + AAdmg + Rdmg + Edmg) < 0

    local DamageArray = {QKills = QCheck, EKills = ECheck, RKills = RCheck, QRKills = QRCheck, ERKills = ERCheck, QERKills = QERCheck, BurstDamage = BurstDamage, QDamage = Qdmg, EDamage = Edmg, RDamage = Rdmg, AADamage = AAdmg}
    return DamageArray
end

function Gwen:GetAllDamage(unit, burst)
    local Qdmg = getdmg("Q", unit, myHero, 1, myHero:GetSpellData(_Q).level)
    local Wdmg = getdmg("W", unit, myHero) 
    local Edmg = getdmg("E", unit, myHero, 1, myHero:GetSpellData(_E).level)
    local Rdmg = getdmg("R", unit, myHero, 1, myHero:GetSpellData(_R).level)
    local AAdmg = getdmg("AA", unit, myHero)
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
        TotalDmg = TotalDmg + Rdmg
        SpellsReady = SpellsReady + 1
    end
    TotalDmg = TotalDmg + AAdmg
    PossibleDmg = Qdmg + Wdmg + Edmg + Rdmg + AAdmg
    local Damages = {TotalDamage = TotalDmg, PossibleDamage = PossibleDmg, QDamage = Qdmg, WDamage = Wdmg, EDamage = Edmg, RDamage = Rdmg, SpellsReady = SpellsReady}      
    return Damages
end

function Gwen:ProcessSpells()
    CastingQ = myHero.activeSpell.name == "GwenQ" 
    CastingW = myHero.activeSpell.name == "GwenW"
    CastingE = myHero.activeSpell.name == "GwenE"
    CastingR = myHero.activeSpell.name == "GwenR"

    EBuff = HasBuff(myHero, "GwenEAttackBuff")
    EActive = HasBuff(myHero, "GwenEAttackBuff")
    RActive = HasBuff(myHero, "GwenRRecast")

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
                --Control.CastSpell(FlashSpell, PrimedFlashE)
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

function Gwen:GetDodgeSpot(CastSpot, ClosestSpot, width)
    local DodgeSpot = nil
    local RadAngle1 = 90 * math.pi / 180
    local CheckPos1 = ClosestSpot + (CastSpot - ClosestSpot):Rotated(0, RadAngle1, 0):Normalized() * width
    local RadAngle2 = 270 * math.pi / 180
    local CheckPos2 = ClosestSpot + (CastSpot - ClosestSpot):Rotated(0, RadAngle2, 0):Normalized() * width

    if GetDistance(CheckPos1, mousePos) < GetDistance(CheckPos2, mousePos) then
        if GetDistance(CheckPos1, myHero.pos) < ERange then
            DodgeSpot = CheckPos1
        elseif GetDistance(CheckPos2, myHero.pos) < ERange then
            DodgeSpot = CheckPos2
        end
    else
        if GetDistance(CheckPos2, myHero.pos) < ERange then
            DodgeSpot = CheckPos2
        elseif GetDistance(CheckPos1, myHero.pos) < ERange then
            DodgeSpot = CheckPos1
        end
    end
    return DodgeSpot
end

function Gwen:MenuEvadeE()
    for i, enemy in pairs(GetEnemyHeroes()) do
        self.Menu.ComboMode.UseEDodgeChamps:MenuElement({id = enemy.charName, name = enemy.charName, type = MENU})
        self.Menu.ComboMode.UseEDodgeChamps[enemy.charName]:MenuElement({id = enemy:GetSpellData(_Q).name, name = enemy.charName .. "[Q]".. enemy:GetSpellData(_Q).name, value = true})
        self.Menu.ComboMode.UseEDodgeChamps[enemy.charName]:MenuElement({id = enemy:GetSpellData(_W).name, name = enemy.charName .. "[W]" .. enemy:GetSpellData(_W).name, value = true})
        self.Menu.ComboMode.UseEDodgeChamps[enemy.charName]:MenuElement({id = enemy:GetSpellData(_E).name, name = enemy.charName .. "[E]" .. enemy:GetSpellData(_E).name, value = true})
        self.Menu.ComboMode.UseEDodgeChamps[enemy.charName]:MenuElement({id = enemy:GetSpellData(_R).name, name = enemy.charName .. "[R]" .. enemy:GetSpellData(_R).name, value = true})
    end
end

function Gwen:EDodge(enemy, HelperSpot)
    if enemy.activeSpell and enemy.activeSpell.valid then
        if enemy.activeSpell.target == myHero.handle then

        else
            local SpellName = enemy.activeSpell.name
            if self.Menu.ComboMode.UseEDodgeChamps[enemy.charName] and self.Menu.ComboMode.UseEDodgeChamps[enemy.charName][SpellName] and self.Menu.ComboMode.UseEDodgeChamps[enemy.charName][SpellName]:Value() then

                local CastPos = enemy.activeSpell.startPos
                local PlacementPos = enemy.activeSpell.placementPos
                local width = 100
                if enemy.activeSpell.width > 0 then
                    width = enemy.activeSpell.width
                end
                local SpellType = "Linear"
                if SpellType == "Linear" and PlacementPos and CastPos then

                    --PrintChat(CastPos)
                    local VCastPos = Vector(CastPos.x, CastPos.y, CastPos.z)
                    local VPlacementPos = Vector(PlacementPos.x, PlacementPos.y, PlacementPos.z)

                    local CastDirection = Vector((VCastPos-VPlacementPos):Normalized())
                    local PlacementPos2 = VCastPos - CastDirection * enemy.activeSpell.range

                    local TargetPos = Vector(enemy.pos)
                    local MouseDirection = Vector((myHero.pos-mousePos):Normalized())
                    local ScanDistance = width*2 + myHero.boundingRadius
                    local ScanSpot = myHero.pos - MouseDirection * ScanDistance
                    local ClosestSpot = Vector(self:ClosestPointOnLineSegment(myHero.pos, PlacementPos2, CastPos))
                    if HelperSpot then 
                        local ClosestSpotHelper = Vector(self:ClosestPointOnLineSegment(HelperSpot, PlacementPos2, CastPos))
                        if ClosestSpot and ClosestSpotHelper then
                            local PlacementDistance = GetDistance(myHero.pos, ClosestSpot)
                            local HelperDistance = GetDistance(HelperSpot, ClosestSpotHelper)
                            if PlacementDistance < width*2 + myHero.boundingRadius then
                                if HelperDistance > width*2 + myHero.boundingRadius then
                                    return HelperSpot
                                elseif self.Menu.ComboMode.UseEDodgeCalc:Value() then
                                    local DodgeRange = width*2 + myHero.boundingRadius
                                    if DodgeRange < ERange then
                                        local DodgeSpot = self:GetDodgeSpot(CastPos, ClosestSpot, DodgeRange)
                                        if DodgeSpot ~= nil then
                                           --PrintChat("Dodging to Calced Spot")
                                            return DodgeSpot
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if ClosestSpot then
                            local PlacementDistance = GetDistance(myHero.pos, ClosestSpot)
                            if PlacementDistance < width*2 + myHero.boundingRadius then
                                if self.Menu.ComboMode.UseEDodgeCalc:Value() then
                                    local DodgeRange = width*2 + myHero.boundingRadius
                                    if DodgeRange < ERange then
                                        local DodgeSpot = self:GetDodgeSpot(CastPos, ClosestSpot, DodgeRange)
                                        if DodgeSpot ~= nil then
                                           --PrintChat("Dodging to Calced Spot")
                                            return DodgeSpot
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end    
    return nil
end

function Gwen:KiteHelper(unit)
    local EAARangel = _G.SDK.Data:GetAutoAttackRange(unit)
    local MoveSpot = nil
    local RangeDif = AARange - EAARangel
    local ExtraRangeDist = RangeDif + self.Menu.GwenOrbMode.KiteHelperRange:Value()
    local ExtraRangeChaseDist = RangeDif + self.Menu.GwenOrbMode.KiteHelperRangeFacing:Value()

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
    local EMouseSpotDirection = Vector((myHero.pos-MouseSpot):Normalized())
    local EmouseSpotDistance = GetDistance(myHero.pos, MouseSpot)
    if EmouseSpotDistance > 400 then
        EmouseSpotDistance = 400
    end
    local EMouseSpoty = myHero.pos - EMouseSpotDirection * EmouseSpotDistance
    MoveSpot = MouseSpot

    if MoveSpot then
        if GetDistance(myHero.pos, MoveSpot) < 50 then
            _G.SDK.Orbwalker.ForceMovement = nil
        elseif self.Menu.GwenOrbMode.UseKiteHelperWalk:Value() and GetDistance(myHero.pos, unit.pos) <= AARange-50 and (GetMode() == "Combo" or GetMode() == "Harass") then
            _G.SDK.Orbwalker.ForceMovement = MoveSpot
        else
            _G.SDK.Orbwalker.ForceMovement = nil
        end
    end
    return EMouseSpoty
end

function Gwen:CastingChecks()
    if not CastingQ and not CastingW and not CastingE and not CastingR then
        return true
    else
        return false
    end
end

function Gwen:CastingChecksR()
    if not CastingQ and not CastingR then
        return true
    else
        return false
    end
end

function Gwen:CastingChecksQ()
    if not CastingQ and not CastingR then
        return true
    else
        return false
    end
end

function Gwen:CastingChecksW()
    if not CastingW and not CastingR then
        return true
    else
        return false
    end
end

function Gwen:CastingChecksE()
    if not CastingE and not CastingR then
        return true
    else
        return false
    end
end

function Gwen:Logic()
	if target == nil then 
        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
        return 
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
	if GetMode() == "Combo" or GetMode() == "Harass" and target then

        local DamageList = self:DamageChecks(target)
        local ETargetRange = AARange + ERange + 50
        local EDashRange = 400
        if EAARange < 250 then
            EDashRange = EAARange + 10
        end

        local QAttackCheck = GetDistance(myHero.pos, target.pos) > AARange or EPostAttack
        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
        if GetDistance(myHero.pos, target.pos) < AARange then
            TargetTime = Game.Timer()
            WasInRange = true
        end
	end
end

function Gwen:Auto()
end

function Gwen:Combo()
					
local target = GetTarget(2000)     	
if target == nil then return end
	if IsValid(target) then
		if IsReady(_R) and self.Menu.ComboMode.UseRComboFinish:Value() then
			if GetEnemyCount(1500, myHero.pos) == 1 then
				if myHero.pos:DistanceTo(target.pos) <= RRange and RActive == true then
					--Control.CastSpell(HK_R, target.pos)
                    self.CastR(target)
				else
					if self.Menu.ComboMode.UseE:Value() and IsReady(_E) then
						if myHero.pos:DistanceTo(target.pos) <= ERange and not self:IsDashPosTurret(target) then
							if Control.CastSpell(HK_E, target) and RActive == true then
								--Control.CastSpell(HK_R, target.pos)
                                self.CastR(target)
							end									
						end
					end	
				end
			else
				if GetEnemyCount(1500, myHero.pos) > 1 then
					if self.Menu.ComboMode.UseE:Value() and IsReady(_E) then
						if myHero.pos:DistanceTo(target.pos) <= ERange and GetEnemyCount(ERange, target.pos) >= 1 and not self:IsDashPosTurret(target) then
							if Control.CastSpell(HK_E, target) and RActive == true then
								--Control.CastSpell(HK_R, target.pos)
                                self.CastR(target)
							end
						end
					else
						if myHero.pos:DistanceTo(target.pos) <= RRange and GetEnemyCount(RRange, myHero.pos) >= 2 and RActive == true then
							--Control.CastSpell(HK_R, target.pos)
                            self.CastR(target)
						end
					end
				end
			end
		else
            if IsReady(_R) and self.Menu.ComboMode.UseR:Value() then
                if GetEnemyCount(1500, myHero.pos) == 1 then
                    if myHero.pos:DistanceTo(target.pos) <= RRange then
                        --Control.CastSpell(HK_R, target.pos)
                        self.CastR(target)
                    else
                        if self.Menu.ComboMode.UseE:Value() and IsReady(_E) then
                            if myHero.pos:DistanceTo(target.pos) <= ERange and not self:IsDashPosTurret(target) then
                                if Control.CastSpell(HK_E, target) then
                                    --Control.CastSpell(HK_R, target.pos)
                                    self.CastR(target)
                                end									
                            end
                        end	
                    end
                else
                    if GetEnemyCount(1500, myHero.pos) > 1 then
                        if self.Menu.ComboMode.UseE:Value() and IsReady(_E) then
                            if myHero.pos:DistanceTo(target.pos) <= ERange and GetEnemyCount(ERange, target.pos) >= 1 and not self:IsDashPosTurret(target) then
                                if Control.CastSpell(HK_E, target) then
                                    --Control.CastSpell(HK_R, target.pos)
                                    self.CastR(target)
                                end
                            end
                        else
                            if myHero.pos:DistanceTo(target.pos) <= RRange and GetEnemyCount(RRange, myHero.pos) >= 2 then
                                --Control.CastSpell(HK_R, target.pos)
                                self.CastR(target)
                            end
                        end
                    end
                end
            end
        end

		if self.Menu.ComboMode.UseE:Value() and IsReady(_E) then
			if myHero.pos:DistanceTo(target.pos) <= QRange and not self:IsDashPosTurret(target) then					
				if self.Menu.ComboMode.UseQ:Value() and IsReady(_Q) then
					if Control.CastSpell(HK_E, target) and myHero.hudAmmo == 4 then
						--Control.CastSpell(HK_Q, target.pos)
                        self.CastQ(target)
					end
				else
					--Control.CastSpell(HK_E, target)
                    self.CastE(target)
				end
			end
		end

		if self.Menu.ComboMode.UseQ:Value() and IsReady(_Q) then 				 
			if self.Menu.ComboMode.UseE:Value() and IsReady(_E) and myHero.pos:DistanceTo(target.pos) <= ERange and not self:IsDashPosTurret(target) then return end
			if myHero.pos:DistanceTo(target.pos) <= QRange and myHero.pos:DistanceTo(target.pos) > ERange and myHero.hudAmmo == 4 then
				--Control.CastSpell(HK_Q, target.pos)	
                self.CastQ(target)	
			end
			if myHero.pos:DistanceTo(target.pos) < QRange and myHero.hudAmmo == 4 then
				--Control.CastSpell(HK_Q, target.pos)
                self.CastQ(target)		
			end
		end
	end
end

function Gwen:Harass()
local target = GetTarget(1000)     	
if target == nil then return end 
	if IsValid(target) then
		
		if self.Menu.HarassMode.UseQ:Value() and IsReady(_Q) then
			if myHero.pos:DistanceTo(target.pos) <= QRange and myHero.pos:DistanceTo(target.pos) > ERange then
				--Control.CastSpell(HK_Q, target.pos)	
                self.CastQ(target)		
			end
			if myHero.pos:DistanceTo(target.pos) < QRange then
				--Control.CastSpell(HK_Q, target.pos)	
                self.CastQ(target)	
			end
		end	
	end	
end

local CastEQ = false
function Gwen:KillSteal()
	if not IsReady(_Q) and CastEQ then CastEQ = false end
	for i, target in ipairs(GetEnemyHeroes()) do     	
		
		if target and myHero.pos:DistanceTo(target.pos) <= RRange and IsValid(target) then
			local QDmg = getdmg("Q", target, myHero, 1, myHero:GetSpellData(_Q).level)
			local EDmg = getdmg("E", target, myHero, 1, myHero:GetSpellData(_E).level)
			local RDmg = getdmg("R", target, myHero, 1, myHero:GetSpellData(_R).level)
            local AAdmg = getdmg("AA", target, myHero)

			if CastEQ then
				if Control.CastSpell(HK_E, target) then
					--Control.CastSpell(HK_Q, target.pos)
                    self.CastQ(target)
				end	
			end	
			
			if self.Menu.AutoMode.UseQFinish:Value() and self.Menu.AutoMode.UseEFinish:Value() and IsReady(_Q) and IsReady(_E) then
				if myHero.pos:DistanceTo(target.pos) <= ERange then
					if QDmg+EDmg > target.health then
						CastEQ = true
					end
				end
			end
									
			if IsReady(_Q) and self.Menu.AutoMode.UseQFinish:Value() then	 
				if myHero.pos:DistanceTo(target.pos) <= QRange and myHero.pos:DistanceTo(target.pos) > ERange and QDmg > target.health then
					--Control.CastSpell(HK_Q, target.pos)
                    self.CastQ(target)
				end	
				if myHero.pos:DistanceTo(target.pos) < QRange and QDmg > target.health then
					--Control.CastSpell(HK_Q, target.pos)
                    self.CastQ(target)
				end
			end
			
			if IsReady(_E) and self.Menu.AutoMode.UseEFinish:Value() then
				if myHero.pos:DistanceTo(target.pos) <= ERange and AAdmg > target.health then
					--Control.CastSpell(HK_E, target)
                    self.CastE(target)
				end
			end

			if IsReady(_R) and self.Menu.AutoMode.UseRFinish:Value() then
				if myHero.pos:DistanceTo(target.pos) <= RRange and RDmg > target.health then
					--Control.CastSpell(HK_R, target.pos)
                    self.CastR(target)
				end
			end
		end
	end	
end	

function Gwen:JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.pos:DistanceTo(minion.pos) < QRange+ERange then
 			
			if myHero.pos:DistanceTo(minion.pos) < ERange and self.Menu.ClearSet.JClear.UseE:Value() and IsReady(_E) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 then
				Control.CastSpell(HK_E)                  
            end           			
			
			if myHero.hudAmmo == 4 and myHero.pos:DistanceTo(minion.pos) < QRange and self.Menu.ClearSet.JClear.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 and IsReady(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
			end			
        end
    end
end
			
function Gwen:Clear()
	if self.Menu.ClearSet.Clear.UseQ:Value() and IsReady(_Q) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)

			if minion.team == TEAM_ENEMY and IsValid(minion) and myHero.pos:DistanceTo(minion.pos) < QRange then				
				local Count = GetMinionCount(ERange+AARange, minion)
                if myHero.pos:DistanceTo(minion.pos) < ERange+AARange and self.Menu.ClearSet.Clear.UseE:Value() and IsReady(_E) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
                    Control.CastSpell(HK_E)                  
                end  
				if Count >= self.Menu.ClearSet.Clear.QCount:Value() and myHero.hudAmmo == 4 then
					Control.CastSpell(HK_Q, minion.pos)
				end				
			end
		end
	end	
end

function Gwen:LastHit()
    --local minions = _G.SDK.ObjectManager:GetEnemyMinions(QRange+ERange)
    if self.Menu.LastHitMode.UseQ:Value() and IsReady(_Q) and myHero.mana/myHero.maxMana >= self.Menu.LastHitMode.Mana:Value() / 100 then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
        local Qdmg = getdmg("Q", minion, myHero, 1, myHero:GetSpellData(_Q).level)
        local Edmg = getdmg("E", minion, myHero, 1, myHero:GetSpellData(_E).level)
        --local AAdmg = getdmg("AA", unit, myHero)
        if Kraken and KrakenStacks == 2 then
            AAdmg = AAdmg + 60 + (0.45*myHero.bonusDamage)
            --PrintChat(60 + (0.45*myHero.bonusDamage))
        end
			if minion.team == TEAM_ENEMY and IsValid(minion) and myHero.pos:DistanceTo(minion.pos) < QRange then			
				local Count = GetMinionCount(QRange, minion)
                if minion.health <= Qdmg then
                    if self.Menu.LastHitMode.UseQLastHit:Value() then
	    			    if Count >= self.Menu.LastHitMode.QCount:Value() and myHero.hudAmmo == 4 then
	    			    	Control.CastSpell(HK_Q, minion.pos)
                        end
                    elseif Count >= self.Menu.LastHitMode.QCount:Value() then
                        Control.CastSpell(HK_Q, minion.pos)
                    end	
                end		
			end
		end
	end	
end

function Gwen:Flee()
    if IsReady(_E) then
        Control.CastSpell(HK_E)
    end
end

function Gwen:OnPostAttack(args)
end

function Gwen:OnPostAttackTick(args)
end

function Gwen:OnPreAttack(args)
end

function Gwen:CastQ(unit)
    local target = GetTarget(2000)     	
    if target == nil then return end
        if IsValid(target) then   
        if IsReady(_Q) then
	     	if Gwen.Menu.Pred.Change:Value() == 1 then
	     		local pred = _G.PremiumPrediction:GetPrediction(myHero, target, Gwen.QspellData)
	     		if pred.CastPos and ConvertToHitChance(Gwen.Menu.Pred.PredQ:Value(), pred.HitChance) then
	     			Control.CastSpell(HK_Q, pred.CastPos)
	     		end
	     	end	
	     	if Gwen.Menu.Pred.Change:Value() == 2 then
	     		Gwen.QPrediction:GetPrediction(target, myHero)			
	     		if Gwen.QPrediction:CanHit(Gwen.Menu.Pred.PredQ:Value() + 1) then
	     			Control.CastSpell(HK_Q, Gwen.QPrediction.CastPosition)
	     		end	
	     	end
             if Gwen.Menu.Pred.Change:Value() == 3 then
                 Control.CastSpell(HK_Q, target.pos)
	     	end
	    end	
    end
end	

function Gwen:CastW(i, s)
    --PrintChat("Using W to block CC spell")
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == MathHuge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 425)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 425)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > GameTimer() then
		local Col = VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
		if s.type == "circular" or s.type == "linear" then 
			if GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
				local t = s.speed ~= MathHuge and CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay) or 0.29
				if t < 0.7 then
					Control.CastSpell(HK_W)
				
				end				
			end
		end	
	else TableRemove(DetectedSpells, i) end
end

function Gwen:CastE(unit)
    local target = GetTarget(2000)     	
    if target == nil then return end
        if IsValid(target) then 
        if IsReady(_E) then
		    if Gwen.Menu.Pred.Change:Value() == 1 then
		    	local pred = _G.PremiumPrediction:GetPrediction(myHero, target, Gwen.RspellData)
		    	if pred.CastPos and ConvertToHitChance(Gwen.Menu.Pred.PredE:Value(), pred.HitChance) then
		    		Control.CastSpell(HK_E, pred.CastPos)
		    	end
		    end	
		    if Gwen.Menu.Pred.Change:Value() == 2 then
		    	Gwen.RPrediction:GetPrediction(target, myHero)			
		    	if Gwen.RPrediction:CanHit(Gwen.Menu.Pred.PredR:Value() + 1) then
		    		Control.CastSpell(HK_E, Gwen.EPrediction.CastPosition)
		    	end	
		    end
            if Gwen.Menu.Pred.Change:Value() == 3 then
                Control.CastSpell(HK_E, target.pos)
		    end
            --Control.CastSpell(HK_E, unit)
	    end	
    end
end

function Gwen:CastR(unit)
    local target = GetTarget(2000)     	
    if target == nil then return end
        if IsValid(target) then 
        if IsReady(_R) then
	    	if Gwen.Menu.Pred.Change:Value() == 1 then
	    		local pred = _G.PremiumPrediction:GetPrediction(myHero, target, Gwen.RspellData)
	    		if pred.CastPos and ConvertToHitChance(Gwen.Menu.Pred.PredR:Value(), pred.HitChance) then
	    			Control.CastSpell(HK_R, pred.CastPos)
	    		end
	    	end	
	    	if Gwen.Menu.Pred.Change:Value() == 2 then
	    		Gwen.RPrediction:GetPrediction(target, myHero)			
	    		if Gwen.RPrediction:CanHit(Gwen.Menu.Pred.PredR:Value() + 1) then
	    			Control.CastSpell(HK_R, Gwen.RPrediction.CastPosition)
	    		end	
	    	end
            if Gwen.Menu.Pred.Change:Value() == 3 then
                Control.CastSpell(HK_R, target.pos)
	    	end
	    end	
    end
end


function OnLoad()
    Manager()
    DrawInfo = true
end

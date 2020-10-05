local Heroes = {"Yasuo"}

if not table.contains(Heroes, myHero.charName) then return end

--print("Yasuo Load after 30sec Ingame")
require "DamageLib"

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
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "14Yasuo_Vol2.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/14Yasuo_Vol2.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "14Yasuo_Vol2.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/14Yasuo_Vol2.version"
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
            print("New 14Yasuo_Vol2 Version Press 2x F6")
        else
            print("14Yasuo_Vol2 Load after 30sec Ingame")
        end
    
    end
    
    AutoUpdate()

end 

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero

local orbwalker         = _G.SDK.Orbwalker
local targetSelector    = _G.SDK.TargetSelector
local dmglib            = _G.SDK.Damage
local healthPred        = _G.SDK.HealthPrediction
local OB                = _G.SDK.ObjectManager
local TableInsert       = _G.table.insert

local lastIG = 0
local lastMove = 0

local Enemys =   {}
local Allys  =   {}
local Units = 	 {}
local myHero = myHero

local TargetedSpell = {

	--- A ---
	["AhriOrbofDeception"]          = {charName = "Ahri"      	, slot = "Q" 		, delay = 0.25, speed = 2500       , isMissile = true },
    ["AhriSeduce"]          		= {charName = "Ahri"      	, slot = "E" 		, delay = 0.25, speed = 1500       , isMissile = true },
    ["AkaliQ"]                   	= {charName = "Akali"      	, slot = "Q" 		, delay = 0.25, speed = 3200       , isMissile = false},
    ["AkaliE"]                   	= {charName = "Akali"      	, slot = "E" 		, delay = 0.25, speed = 1800       , isMissile = true },
    ["BandageToss"]                 = {charName = "Amumu"      	, slot = "Q" 		, delay = 0.25, speed = 2000       , isMissile = true },	
    ["AatroxW"]                   	= {charName = "Aatrox"      , slot = "W" 		, delay = 0.25, speed = 1800       , isMissile = true },
    ["FlashFrostSpell"]             = {charName = "Anivia"      , slot = "Q" 		, delay = 0.25, speed =  850       , isMissile = true },
    ["Frostbite"]                   = {charName = "Anivia"      , slot = "E" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["AnnieQ"]                      = {charName = "Annie"       , slot = "Q" 		, delay = 0.25, speed = 1400       , isMissile = true },
    ["ApheliosCalibrumQ"]           = {charName = "Aphelios"    , slot = "Q1" 		, delay = 0.35, speed = 1850       , isMissile = true },
    ["ApheliosInfernumQ"]           = {charName = "Aphelios"    , slot = "Q2" 		, delay = 0.25, speed = 1500       , isMissile = false},
    ["ApheliosR"]             		= {charName = "Aphelios"    , slot = "R" 		, delay =  0.5, speed = 2050       , isMissile = true },
    ["Volley"]                      = {charName = "Ashe"       	, slot = "W" 		, delay = 0.25, speed = 2000       , isMissile = true },
    ["EnchantedCrystalArrow"]       = {charName = "Ashe"       	, slot = "R" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["AurelionSolQ"]                = {charName = "AurelionSol" , slot = "Q" 		, delay =    0, speed =  850       , isMissile = true },

	--- B ---
    ["BardQ"]                 		= {charName = "Bard"       	, slot = "Q"		, delay = 0.25, speed = 1500       , isMissile = true },
    ["RocketGrab"]                 	= {charName = "Blitzcrank"  , slot = "Q"		, delay = 0.25, speed = 1800       , isMissile = true },
    ["BrandQ"]                      = {charName = "Brand"       , slot = "Q" 		, delay = 0.25, speed = 1600       , isMissile = true },  
    ["BrandR"]                      = {charName = "Brand"       , slot = "R" 		, delay = 0.25, speed = 1000       , isMissile = true },   -- to be comfirm brand R delay 0.25 or 0.5
    ["BraumQ"]                      = {charName = "Braum"       , slot = "Q" 		, delay = 0.25, speed = 1700       , isMissile = true },  
    ["BraumR"]                      = {charName = "Braum"       , slot = "R" 		, delay =  0.5, speed = 1400       , isMissile = true },  

	--- C ---
    ["CaitlynPiltoverPeacemaker"]   = {charName = "Caitlyn"     , slot = "Q" 		, delay = 0.62, speed = 2200       , isMissile = true },  
    ["CaitlynEntrapment"]           = {charName = "Caitlyn"     , slot = "E" 		, delay = 0.15, speed = 1600       , isMissile = true },  
    ["CamilleE"]                 	= {charName = "Camille"     , slot = "E1"		, delay =    0, speed = 1900       , isMissile = true },
    ["CamilleEDash2"]               = {charName = "Camille"     , slot = "E2"		, delay =    0, speed = 1900       , isMissile = false},
    ["CassiopeiaW"]                 = {charName = "Cassiopeia"  , slot = "W" 		, delay = 0.75, speed = 2500       , isMissile = false},  
    ["CassiopeiaE"]                 = {charName = "Cassiopeia"  , slot = "E" 		, delay = 0.15, speed = 2500       , isMissile = true },   -- delay to be comfirm
    ["PhosphorusBomb"]              = {charName = "Corki"       , slot = "Q" 		, delay = 0.25, speed = 1000       , isMissile = true },
    ["MissileBarrageMissile"]       = {charName = "Corki"       , slot = "R1" 		, delay = 0.17, speed = 2000       , isMissile = true },
    ["MissileBarrageMissile2"]      = {charName = "Corki"       , slot = "R2" 		, delay = 0.17, speed = 2000       , isMissile = true },

	--- D ---
    ["DianaQ"]                 		= {charName = "Diana"       , slot = "Q"		, delay = 0.25, speed = 1900       , isMissile = false},	
    ["DravenDoubleShot"]            = {charName = "Draven"      , slot = "E"		, delay = 0.25, speed = 1600       , isMissile = true },	
    ["DravenRCast"]                 = {charName = "Draven"      , slot = "R"		, delay = 0.25, speed = 2000       , isMissile = false},	
    ["InfectedCleaverMissile"]      = {charName = "DrMundo"     , slot = "Q"		, delay = 0.25, speed = 2000       , isMissile = true },	

	--- E ---
    ["EkkoQ"]                       = {charName = "Ekko"       	, slot = "Q"		, delay = 0.25, speed = 1650       , isMissile = true },
    ["EliseHumanQ"]                 = {charName = "Elise"       , slot = "Q1"		, delay = 0.25, speed = 2200       , isMissile = true },
    ["EliseHumanE"]                 = {charName = "Elise"       , slot = "E1"		, delay = 0.25, speed = 1600       , isMissile = true },
    ["EvelynnQ"]                 	= {charName = "Evelynn"     , slot = "Q"		, delay = 0.25, speed = 2400       , isMissile = true },
    ["EzrealQ"]                 	= {charName = "Ezreal"     	, slot = "Q"		, delay = 0.25, speed = 2000       , isMissile = true },
    ["EzrealW"]                 	= {charName = "Ezreal"     	, slot = "W"		, delay = 0.25, speed = 2000       , isMissile = true },
    ["EzrealR"]                 	= {charName = "Ezreal"     	, slot = "R"		, delay =    1, speed = 2000       , isMissile = true },

	--- F ---
    ["FiddlesticksDarkWind"]        = {charName = "FiddleSticks", slot = "E" 		, delay = 0.25, speed = 1100       , isMissile = true },
    ["FioraW"]           			= {charName = "Fiora"   	, slot = "W" 		, delay = 0.75, speed = 3200       , isMissile = false},
    ["FizzR"]           			= {charName = "Fizz"   		, slot = "R" 		, delay = 0.25, speed = 1300       , isMissile = true },

	--- G ---
    ["GangplankQProceed"]           = {charName = "Gangplank"   , slot = "Q" 		, delay = 0.25, speed = 2600       , isMissile = true },
    ["GalioQ"]                  	= {charName = "Galio"       , slot = "Q" 		, delay = 0.25, speed = 1150       , isMissile = true },
    ["GnarQMissile"]                = {charName = "Gnar"       	, slot = "Q1" 		, delay = 0.25, speed = 2500       , isMissile = true },
    ["GnarBigQMissile"]             = {charName = "Gnar"       	, slot = "Q2" 		, delay =  0.5, speed = 2100       , isMissile = true },
    ["GragasQ"]                  	= {charName = "Gragas"      , slot = "Q" 		, delay = 0.25, speed = 1000       , isMissile = true },
    ["GragasR"]                  	= {charName = "Gragas"      , slot = "R" 		, delay = 0.25, speed = 1800       , isMissile = true },
    ["GravesQLineSpell"]            = {charName = "Graves"      , slot = "Q" 		, delay =  1.4, speed = math.huge  , isMissile = false},
    ["GravesSmokeGrenade"]          = {charName = "Graves"      , slot = "W" 		, delay = 0.15, speed = 1500       , isMissile = true },
    ["GravesChargeShot"]            = {charName = "Graves"      , slot = "R" 		, delay = 0.25, speed = 2100       , isMissile = true },

	--- H ---
    ["HeimerdingerW"]               = {charName = "Heimerdinger", slot = "W" 		, delay = 0.25, speed = 2050       , isMissile = false},
    ["HeimerdingerE"]               = {charName = "Heimerdinger", slot = "E" 		, delay = 0.25, speed = 1200       , isMissile = true },
    ["HeimerdingerEUlt"]            = {charName = "Heimerdinger", slot = "EUlt" 	, delay = 0.25, speed = 1200       , isMissile = true },

	--- I ---
    ["IllaoiE"]                  	= {charName = "Illaoi"      , slot = "E" 		, delay = 0.25, speed = 1900       , isMissile = true },
    ["IreliaR"]                  	= {charName = "Irelia"      , slot = "R" 		, delay =  0.4, speed = 2000       , isMissile = true },
    ["IvernQ"]                  	= {charName = "Ivern"       , slot = "Q" 		, delay = 0.25, speed = 1300       , isMissile = true },

	--- J ---
    ["HowlingGaleSpell"]            = {charName = "Janna"       , slot = "Q" 		, delay = 0.25, speed =  667       , isMissile = true },
    ["SowTheWind"]                  = {charName = "Janna"       , slot = "W" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["JayceShockBlast"]             = {charName = "Jayce"       , slot = "Q1" 		, delay = 0.21, speed = 1450       , isMissile = true },
    ["JayceShockBlastWallMis"]      = {charName = "Jayce"       , slot = "Q2" 		, delay = 0.15, speed = 2350       , isMissile = true },
    ["JhinW"]                  		= {charName = "Jhin"       	, slot = "W" 		, delay = 0.75, speed = 5000       , isMissile = false},
    ["JhinRShot"]                  	= {charName = "Jhin"       	, slot = "R" 		, delay = 0.25, speed = 5000       , isMissile = true },
    ["JinxWMissile"]                = {charName = "Jinx"       	, slot = "W" 		, delay =  0.6, speed = 3300       , isMissile = true },
    ["JinxEHit"]                  	= {charName = "Jinx"       	, slot = "E" 		, delay =  1.5, speed = 1100       , isMissile = true },
    ["JinxR"]                  		= {charName = "Jinx"       	, slot = "R" 		, delay =  0.6, speed = 1700       , isMissile = true },

	--- K ---
    ["KatarinaQ"]                   = {charName = "Katarina"    , slot = "Q" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["NullLance"]                   = {charName = "Kassadin"    , slot = "Q" 		, delay = 0.25, speed = 1400       , isMissile = true },
    ["KaisaW"]                   	= {charName = "Kaisa"    	, slot = "W" 		, delay =  0.4, speed = 1750       , isMissile = true },
    ["KalistaMysticShot"]           = {charName = "Kalista"    	, slot = "Q" 		, delay = 0.25, speed = 2400       , isMissile = true },
    ["KarmaQ"]                   	= {charName = "Karma"    	, slot = "Q1" 		, delay = 0.25, speed = 1700       , isMissile = true },
    ["KarmaQMantra"]                = {charName = "Karma"    	, slot = "Q2" 		, delay = 0.25, speed = 1700       , isMissile = true },
    ["KayleQ"]                   	= {charName = "Kayle"    	, slot = "Q" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["KennenShurikenHurlMissile1"]  = {charName = "Kennen"    	, slot = "Q" 		, delay = 0.17, speed = 1700       , isMissile = true },
    ["KhazixW"]                   	= {charName = "Khazix"    	, slot = "W1" 		, delay = 0.25, speed = 1700       , isMissile = true },
    ["KhazixWLong"]                 = {charName = "Khazix"    	, slot = "W2" 		, delay = 0.25, speed = 1700       , isMissile = false},
    ["KledQ"]                   	= {charName = "Kled"    	, slot = "QMount" 	, delay = 0.25, speed = 1600       , isMissile = true },
    ["KledRiderQ"]                  = {charName = "Kled"    	, slot = "QDismount", delay = 0.25, speed = 3000       , isMissile = true },
    ["KogMawQ"]                   	= {charName = "KogMaw"    	, slot = "Q" 		, delay = 0.25, speed = 1650       , isMissile = true },
    ["KogMawVoidOozeMissile"]       = {charName = "KogMaw"    	, slot = "E" 		, delay = 0.25, speed = 1400       , isMissile = true },

	--- L ---
    ["LeblancQ"]                    = {charName = "Leblanc"     , slot = "Q" 		, delay = 0.25, speed = 2000       , isMissile = true },
    ["LeblancRQ"]                   = {charName = "Leblanc"     , slot = "RQ"		, delay = 0.25, speed = 2000       , isMissile = true },
    ["LeblancE"]                    = {charName = "Leblanc"     , slot = "E" 		, delay = 0.25, speed = 1750       , isMissile = true },
    ["LeblancRE"]                   = {charName = "Leblanc"     , slot = "RE" 		, delay = 0.25, speed = 1750       , isMissile = true },
    ["BlindMonkQOne"]               = {charName = "LeeSin"     	, slot = "Q" 		, delay = 0.25, speed = 1800       , isMissile = true },
    ["LeonaZenithBlade"]            = {charName = "Leona"     	, slot = "E" 		, delay = 0.25, speed = 2000       , isMissile = true },
    ["LissandraQMissile"]           = {charName = "Lissandra"   , slot = "Q" 		, delay = 0.25, speed = 2200       , isMissile = true },
    ["LissandraEMissile"]           = {charName = "Lissandra"   , slot = "E" 		, delay = 0.25, speed =  850       , isMissile = true },
    ["LucianW"]                    	= {charName = "Lucian"     	, slot = "W" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["LuxLightBinding"]             = {charName = "Lux"     	, slot = "Q" 		, delay = 0.25, speed = 1200       , isMissile = true },
    ["LuxLightStrikeKugel"]         = {charName = "Lux"     	, slot = "E" 		, delay = 0.25, speed = 1200       , isMissile = true },
    ["LuluQ"]                    	= {charName = "Lulu"     	, slot = "Q" 		, delay = 0.25, speed = 1450       , isMissile = true },
    ["LuluWTwo"]                    = {charName = "Lulu"        , slot = "W" 		, delay = 0.25, speed = 2250       , isMissile = true },

	--- M ---
    ["SeismicShard"]                = {charName = "Malphite"    , slot = "Q" 		, delay = 0.25, speed = 1200       , isMissile = true },
    ["MaokaiQ"]                		= {charName = "Maokai"    	, slot = "Q" 		, delay = 0.37, speed = 1600       , isMissile = true },
    ["MordekaiserE"]                = {charName = "Mordekaiser" , slot = "E" 		, delay =  0.9, speed = math.huge  , isMissile = false},
    ["MorganaQ"]                	= {charName = "Morgana"    	, slot = "Q" 		, delay = 0.25, speed = 1200       , isMissile = true },
    ["MissFortuneRicochetShot"]     = {charName = "MissFortune" , slot = "Q" 		, delay = 0.25, speed = 1400       , isMissile = true },
    ["MissFortuneBulletTime"]       = {charName = "MissFortune" , slot = "R" 		, delay = 0.25, speed = 2000       , isMissile = false},

	--- N ---
    ["NamiQ"]                       = {charName = "Nami"        , slot = "Q" 		, delay =    1, speed = math.huge  , isMissile = true },
    ["NamiW"]                       = {charName = "Nami"        , slot = "W" 		, delay = 0.25, speed = 2000       , isMissile = true },
    ["NamiRMissile"]                = {charName = "Nami"        , slot = "R" 		, delay =  0.5, speed =  850       , isMissile = true },
    ["NautilusAnchorDragMissile"]   = {charName = "Nautilus"    , slot = "Q" 		, delay = 0.25, speed = 2000       , isMissile = true },
    ["NautilusGrandLine"]           = {charName = "Nautilus"    , slot = "R" 		, delay = 0.5 , speed = 1400       , isMissile = true },  -- delay to be comfirm
    ["NeekoQ"]                      = {charName = "Neeko"       , slot = "Q" 		, delay = 0.25, speed = 1500       , isMissile = true },
    ["NeekoE"]                      = {charName = "Neeko"       , slot = "E" 		, delay = 0.25, speed = 1300       , isMissile = true },
    ["JavelinToss"]                 = {charName = "Nidalee"     , slot = "Q" 		, delay = 0.25, speed = 1300       , isMissile = true },
    ["NocturneDuskbringer"]         = {charName = "Nocturne"    , slot = "Q" 		, delay = 0.25, speed = 1600       , isMissile = true },

	--- O ---
    ["OlafAxeThrowCast"]            = {charName = "Olaf"        , slot = "Q" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["OrnnQ"]                       = {charName = "Ornn"        , slot = "Q" 		, delay =  0.3, speed = 1800       , isMissile = false},
    ["OrnnRCharge"]                 = {charName = "Ornn"        , slot = "R" 		, delay =  0.5, speed = 1650       , isMissile = false},

	--- P ---
    ["PantheonQ"]                   = {charName = "Pantheon"    , slot = "Q" 		, delay = 0.25, speed = 1500       , isMissile = true },  -- missle.name = PantheonQMissile
    ["PantheonR"]                   = {charName = "Pantheon"    , slot = "R" 		, delay =    4, speed = 2250       , isMissile = false},
    ["PoppyRSpell"]                 = {charName = "Poppy"       , slot = "R" 		, delay = 0.33, speed = 2000       , isMissile = true },
    ["PykeQRange"]                  = {charName = "Pyke"        , slot = "Q" 		, delay =  0.2, speed = 2000       , isMissile = true },

	--- Q ---
    ["QiyanaQ_Grass"]               = {charName = "Qiyana"      , slot = "QGrass"  	, delay = 0.25, speed = 1600       , isMissile = false},
    ["QiyanaQ_Rock"]                = {charName = "Qiyana"      , slot = "QRock" 	, delay = 0.25, speed = 1600       , isMissile = false},
    ["QiyanaQ_Water"]               = {charName = "Qiyana"      , slot = "QWater" 	, delay = 0.25, speed = 1600       , isMissile = false},
    ["QiyanaR"]                     = {charName = "Qiyana"      , slot = "R" 		, delay = 0.25, speed = 2000       , isMissile = false},
    ["QuinnQ"]                      = {charName = "Quinn"       , slot = "Q" 		, delay = 0.25, speed = 1550       , isMissile = true },

	--- R ---
    ["RyzeQ"]                       = {charName = "Ryze"        , slot = "Q" 		, delay = 0.25, speed = 1700       , isMissile = true },
    ["RyzeE"]                       = {charName = "Ryze"        , slot = "E" 		, delay = 0.25, speed = 3500       , isMissile = true },
    ["RakanQ"]                      = {charName = "Rakan"       , slot = "Q" 		, delay = 0.25, speed = 1850       , isMissile = true },
    ["RekSaiQBurrowed"]             = {charName = "RekSai"      , slot = "Q" 		, delay = 0.13, speed = 1950       , isMissile = true },
    ["RengarE"]                     = {charName = "Rengar"      , slot = "E" 		, delay = 0.25, speed = 1500       , isMissile = true },
    ["RivenIzunaBlade"]             = {charName = "Riven"       , slot = "R" 		, delay = 0.25, speed = 1600       , isMissile = false},
    ["RumbleGrenade"]               = {charName = "Rumble"      , slot = "E" 		, delay = 0.25, speed = 2000       , isMissile = true },

	--- S ---
    ["SejuaniR"]                    = {charName = "Sejuani"     , slot = "R" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["SennaW"]                     	= {charName = "Senna"      	, slot = "W" 		, delay = 0.25, speed = 1150       , isMissile = true },
    ["SennaR"]                     	= {charName = "Senna"      	, slot = "R" 		, delay =    1, speed = 20000      , isMissile = true },
    ["ShyvanaFireball"]             = {charName = "Shyvana"     , slot = "EHuman"   , delay = 0.25, speed = 1575       , isMissile = true },
    ["ShyvanaFireballDragon2"]      = {charName = "Shyvana"     , slot = "EDragon" 	, delay = 0.33, speed = 1575       , isMissile = true },
    ["SionE"]                     	= {charName = "Sion"      	, slot = "E" 		, delay = 0.25, speed = 1800       , isMissile = true },
    ["SivirQ"]                      = {charName = "Sivir"       , slot = "Q" 		, delay = 0.25, speed = 1350       , isMissile = true },
    ["SkarnerFractureMissile"]      = {charName = "Skarner"     , slot = "E" 		, delay = 0.25, speed = 1500       , isMissile = true },
    ["SwainQ"]                     	= {charName = "Swain"      	, slot = "Q" 		, delay = 0.25, speed = 5000       , isMissile = false},
    ["SwainE"]                     	= {charName = "Swain"      	, slot = "E" 		, delay = 0.25, speed = 1800       , isMissile = false},
    ["SylasE2"]                     = {charName = "Sylas"       , slot = "E" 		, delay = 0.25, speed = 1600       , isMissile = true },
    ["SyndraE"]                     = {charName = "Syndra"      , slot = "E" 		, delay = 0.25, speed = 1600       , isMissile = false},
    ["SyndraR"]                     = {charName = "Syndra"      , slot = "R" 		, delay = 0.25, speed = 1400       , isMissile = true },
    ["TwoShivPoison"]               = {charName = "Shaco"       , slot = "E" 		, delay = 0.25, speed = 1500       , isMissile = true },

	--- T ---
    ["BlindingDart"]                = {charName = "Teemo"       , slot = "Q" 		, delay = 0.25, speed = 1500       , isMissile = true },
    ["TristanaR"]                   = {charName = "Tristana"    , slot = "R" 		, delay = 0.25, speed = 2000       , isMissile = true },
    ["TahmKenchQ"]                	= {charName = "TahmKench"   , slot = "Q" 		, delay = 0.25, speed = 2800       , isMissile = true },
    ["TaliyahQMis"]                	= {charName = "Taliyah"     , slot = "Q" 		, delay = 0.25, speed = 3600       , isMissile = true },
    ["TalonW"]                		= {charName = "Talon"       , slot = "W" 		, delay = 0.25, speed = 2500       , isMissile = true },
    ["ThreshQMissile"]              = {charName = "Thresh"      , slot = "Q" 		, delay =  0.5, speed = 1900       , isMissile = true },
    ["WildCards"]                	= {charName = "TwistedFate" , slot = "Q" 		, delay = 0.25, speed = 1000       , isMissile = true },
    ["BlueCardPreAttack"]           = {charName = "TwistedFate" , slot = "WBlue" 	, delay = 0   , speed = 1500       , isMissile = true },
    ["RedCardPreAttack"]            = {charName = "TwistedFate" , slot = "WRed" 	, delay = 0   , speed = 1500       , isMissile = true },
    ["GoldCardPreAttack"]           = {charName = "TwistedFate" , slot = "WGold" 	, delay = 0   , speed = 1500       , isMissile = true },	

	--- U ---
    ["UrgotQ"]                		= {charName = "Urgot"       , slot = "Q" 		, delay =  0.6, speed = math.huge  , isMissile = true },
    ["UrgotR"]                		= {charName = "Urgot"       , slot = "R" 		, delay =  0.5, speed = 3200       , isMissile = true },

	--- V ---
    ["VayneCondemn"]                = {charName = "Vayne"       , slot = "E" 		, delay = 0.25, speed = 2200       , isMissile = true },
    ["VarusQMissile"]               = {charName = "Varus"       , slot = "Q" 		, delay = 0.25, speed = 1900       , isMissile = true },
    ["VarusE"]                		= {charName = "Varus"       , slot = "E" 		, delay = 0.24, speed = 1500       , isMissile = true },
    ["VarusR"]                		= {charName = "Varus"       , slot = "R" 		, delay = 0.25, speed = 1950       , isMissile = true },
    ["VelkozQ"]                		= {charName = "Velkoz"      , slot = "Q" 		, delay = 0.25, speed = 1300       , isMissile = true },
    ["VelkozW"]               	 	= {charName = "Velkoz"      , slot = "W" 		, delay = 0.25, speed = 1700       , isMissile = true },
    ["VeigarBalefulStrike"]         = {charName = "Veigar"      , slot = "Q" 		, delay = 0.25, speed = 2200       , isMissile = true },
    ["VeigarR"]                     = {charName = "Veigar"      , slot = "R" 		, delay = 0.25, speed = 500        , isMissile = true },
    ["ViktorPowerTransfer"]         = {charName = "Viktor"      , slot = "Q" 		, delay = 0.25, speed = 2000       , isMissile = true },
    ["ViktorDeathRayMissile"]       = {charName = "Viktor"      , slot = "E" 		, delay = 0.25, speed = 1050       , isMissile = true },

	--- W ---
	
	--- X ---
    ["XayahQ"]                		= {charName = "Xayah"       , slot = "Q" 		, delay =  0.5, speed = 2075       , isMissile = true },
    ["XerathMageSpear"]             = {charName = "Xerath"      , slot = "E" 		, delay =  0.2, speed = 1400       , isMissile = true },

	--- Y ---
    ["YasuoQ3Mis"]                	= {charName = "Yasuo"       , slot = "Q3" 		, delay = 0.34, speed = 1200       , isMissile = true },

	--- Z ---
    ["ZacQ"]                		= {charName = "Zac"       	, slot = "Q" 		, delay = 0.33, speed = 2800       , isMissile = true },
    ["ZedQ"]                		= {charName = "Zed"       	, slot = "Q" 		, delay = 0.25, speed = 1700       , isMissile = true },
    ["ZiggsQ"]                		= {charName = "Ziggs"       , slot = "Q" 		, delay = 0.25, speed =  850       , isMissile = true },
    ["ZiggsW"]                		= {charName = "Ziggs"       , slot = "W" 		, delay = 0.25, speed = 1000       , isMissile = true },
    ["ZiggsE"]                		= {charName = "Ziggs"       , slot = "E" 		, delay = 0.25, speed =  900       , isMissile = true },
    ["ZileanQ"]                		= {charName = "Zilean"      , slot = "Q" 		, delay =  0.8, speed = math.huge  , isMissile = true },
    ["ZoeQMissile"]                	= {charName = "Zoe"       	, slot = "Q1" 		, delay = 0.25, speed = 1200       , isMissile = true },
    ["ZoeQMis2"]                	= {charName = "Zoe"       	, slot = "Q2" 		, delay =    0, speed = 2500       , isMissile = true },
    ["ZoeE"]                		= {charName = "Zoe"       	, slot = "E" 		, delay =  0.3, speed = 1700       , isMissile = true },
    ["ZyraE"]                		= {charName = "Zyra"        , slot = "E" 		, delay = 0.25, speed = 1150       , isMissile = true }		
}

function LoadUnits()
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i); Units[i] = {unit = unit, spell = nil}
	end
end

local function GetDistanceSquared(vec1, vec2)
    local dx = vec1.x - vec2.x
    local dy = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    return dx * dx + dy * dy
end

local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

local function GetDistance(p1, p2)
	p2 = p2 or myHero
	return math.sqrt(GetDistanceSqr(p1, p2))
end

local function IsValid(unit)
    if (unit 
        and unit.valid 
        and unit.isTargetable 
        and unit.alive 
        and unit.visible 
        and unit.networkID 
        and unit.health > 0
        and not unit.dead
    ) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 
    and myHero:GetSpellData(spell).level > 0 
    and myHero:GetSpellData(spell).mana <= myHero.mana 
    and Game.CanUseSpell(spell) == 0
end

local function OnAllyHeroLoad(cb)
    for i = 1, GameHeroCount() do
        local obj = GameHero(i)
        if obj.isAlly then
            cb(obj)
        end
    end
end

local function OnEnemyHeroLoad(cb)
    for i = 1, GameHeroCount() do
        local obj = GameHero(i)
        if obj.isEnemy then
            cb(obj)
        end
    end
end

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.team ~= myHero.team then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
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

local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

local function CheckHPPred(unit, time)
	if _G.SDK and _G.SDK.Orbwalker then
		return _G.SDK.HealthPrediction:GetPrediction(unit, time)
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetHealthPrediction(unit, time)
	end
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

local function GetPathNodes(unit)
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

local function GetTargetMS(target)
	local ms = target.ms
	return ms
end	

local function PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

local function GetLineTargetCount(source, Pos, delay, speed, width, range)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.team == TEAM_ENEMY and source:DistanceTo(minion.pos) < range and IsValid(minion) then
			
			local predictedPos = PredictUnitPosition(minion, delay+ GetDistance(source, minion.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (minion.boundingRadius + width) * (minion.boundingRadius + width)) then
				Count = Count + 1
			end
		end
	end
	return Count
end



class "Yasuo"


local PredLoaded = false
function Yasuo:__init()

    self.Q = {speed = math.huge, range = 475, delay = 0.35, radius = 40, collision = {nil}, type = "linear"}
    self.Q3 = {speed = 1500, range = 1060, delay = 0.35, radius = 90, collision = {nil}, type = "linear"}


    self.E  = {Range = 475, Speed = 715}
    self.R  = {Range = 1400}

    self.Epre = {Delay = 0.47}

    self.QCirWidth = 230
    self.RWidth = 400

    self.blockQ = false

    self.lastETick = GetTickCount()
    self.lastQTick = GetTickCount()

    OnAllyHeroLoad(function(hero) TableInsert(Allys, hero); end)
    OnEnemyHeroLoad(function(hero) TableInsert(Enemys, hero); end)

    orbwalker:OnPreMovement(
        function(args)
            if lastMove + 180 > GetTickCount() then
                args.Process = false
            else
                args.Process = true
                lastMove = GetTickCount()
            end
        end 
    )

    self:LoadMenu()
	
	if not PredLoaded then
		DelayAction(function()
			if self.tyMenu.Pred.Change:Value() == 1 then
				require('PremiumPrediction')
				PredLoaded = true
			else 
				require('GGPrediction')
				PredLoaded = true					
			end
		end, 1)	
	end	

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function Yasuo:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14", name = "14Yasuo_Vol.2"})
	self.tyMenu:MenuElement({name = " ", drop = {"Reworked by Pussykate and ty1314"}})
    self.tyMenu:MenuElement({name = "Ping", id = "ping", value = 20, min = 0, max = 300, step = 1})

    --combo
    
    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})
        self.tyMenu.combo:MenuElement({id = "useQ3", name = "[Q3]", value = true})
        self.tyMenu.combo:MenuElement({id = "Qmode", name = "Q3 Mode", value = 1, drop = {"Priority Circle Q3", "Priority Line Q3"}})
        self.tyMenu.combo:MenuElement({id = "useE", name = "[E]", value = true})
        self.tyMenu.combo:MenuElement({id = "Emode", name = "Q3 Mode", value = 1, drop = {"E to target", "E to cursor"}})
        self.tyMenu.combo:MenuElement({name = "E Gap Closer Range", id = "Erange", value = 800, min = 400, max = 1800, step = 100})
        self.tyMenu.combo:MenuElement({id = "ETower", name = "Stop E Into Tower Range", value = true})
    self.tyMenu.combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate"})		
		self.tyMenu.combo.Ult:MenuElement({name = " ", drop = {"AirBlade need more than 1.33 AttackSpeed"}})
        self.tyMenu.combo.Ult:MenuElement({id = "useR1", name = "[R] [AirBlade] Full DPS (WIP)", value = true})       
		self.tyMenu.combo.Ult:MenuElement({id = "useR2", name = "[R] if killable full Combo", value = true}) 
        self.tyMenu.combo.Ult:MenuElement({id = "useR3", name = "[R] multible Enemies", value = true})
		self.tyMenu.combo.Ult:MenuElement({id = "Count", name = "Min Enemies for [R]", value = 3, min = 2, max = 5})		

    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.tyMenu.harass:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})
        self.tyMenu.harass:MenuElement({id = "useQ3", name = "[Q3]", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "clear", name = "LaneClear"})
        self.tyMenu.clear:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})
        self.tyMenu.clear:MenuElement({id = "useQ3", name = "[Q3]", value = true})
		self.tyMenu.clear:MenuElement({id = "count", name = "Min Minions for [Q3]", value = 3, min = 1, max = 7})		
        self.tyMenu.clear:MenuElement({id = "useE", name = "[E]", value = true})
        self.tyMenu.clear:MenuElement({id = "useE2", name = "[E] Logic", value = 1, drop = {"[E] LastHit", "[E] Everytime"}})		
        self.tyMenu.clear:MenuElement({id = "ETower", name = "Stop E Into Tower Range", value = true})
        self.tyMenu.clear:MenuElement({id = "EQ", name = "FastClear [E] + [Q]", value = true})
		self.tyMenu.clear:MenuElement({id = "count2", name = "Min Minions for FastClear", value = 2, min = 2, max = 7})		


    self.tyMenu:MenuElement({type = MENU, id = "jungle", name = "JungleClear"})
        self.tyMenu.jungle:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})
        self.tyMenu.jungle:MenuElement({id = "useQ3", name = "[Q3]", value = true})				
        self.tyMenu.jungle:MenuElement({id = "EQ", name = "FastClear [E] + [Q]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "last", name = "LastHit Minion"})
        self.tyMenu.last:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})
        self.tyMenu.last:MenuElement({id = "useQ3", name = "[Q3]", value = true})				
        self.tyMenu.last:MenuElement({id = "useE", name = "[E]", value = true})	
        self.tyMenu.last:MenuElement({id = "ETower", name = "Stop E Into Tower Range", value = true})		


    self.tyMenu:MenuElement({type = MENU, id = "flee", name = "Flee"})
		self.tyMenu.flee:MenuElement({id = "ETower", name = "Stop E Into Tower Range", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "windwall", name = "WindWall Setting"})		
		self.tyMenu.windwall:MenuElement({id = "Wcombo", name = "Only Cast W in Combo", value = false})
		self.tyMenu.windwall:MenuElement({type = MENU, id = "spell", name = "Targeted Spell Setting"})

	DelayAction(function() 
		for i, hero in ipairs(GetEnemyHeroes()) do 
			for k, v in pairs(TargetedSpell) do
				if v.charName == hero.charName then
					self.tyMenu.windwall.spell:MenuElement({id = k, name = v.charName.." | "..v.slot , value = true})
				end
			end
		end
	end,0.01)


	self.tyMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
		self.tyMenu.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
		self.tyMenu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Premium Prediction", "GGPrediction"}})	
		self.tyMenu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
		self.tyMenu.Pred:MenuElement({id = "PredQ3", name = "Hitchance[Q3]", value = 2, drop = {"Normal", "High", "Immobile"}})


    --Draw
    self.tyMenu:MenuElement({type = MENU, id = "drawing", name = "Drawing"})
        self.tyMenu.drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.drawing:MenuElement({id = "Q3", name = "Draw [Q3] Range", value = true})
        self.tyMenu.drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.drawing:MenuElement({id = "EGap", name = "Draw [E] Gap Closer Range", value = false})
        self.tyMenu.drawing:MenuElement({id = "R", name = "Draw [R] Range", value = false})

end

--local prePos

function Yasuo:Draw()
    if myHero.dead then return end
    --[[
    if prePos ~= nil then
        Draw.Circle(prePos, 100,Draw.Color(80 ,0xFF,0xFF,0xFF))

    end
    ]]
    

    if self.tyMenu.drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.drawing.Q3:Value() and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" then
        Draw.Circle(myHero.pos, self.Q3.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.drawing.EGap:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.tyMenu.combo.Erange:Value(),Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

local WActive = false
local CanUlt = false
function Yasuo:Tick()
	if Control.IsKeyDown(HK_Q) then
		Control.KeyUp(HK_Q)
	end

    local enemys = OB:GetEnemyHeroes(1500)

    for i = 1, #enemys do
        local enemy = enemys[i]
        local isKnock = self:IsKnock(enemy)
		if CanUlt and not isKnock then
			CanUlt = false
		end
	end	
	
	if WActive and not Ready(_W) then
		WActive = false
	end	

    if myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) then
        return
    end

    self:UpdateQDelay()
    self:CastW()

    if orbwalker.Modes[0] then --combo
        if CanUlt == false then
			self:Combo()
		end	
		self:CastR()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    elseif orbwalker.Modes[3] then --jungle + lane
        self:Jungle()
		self:Clear()
    elseif orbwalker.Modes[4] then --lasthit
        self:LastHit()
    elseif orbwalker.Modes[5] then
        self:Flee()
    end
    -- print(self.Q3.delay)
end

function Yasuo:CastR()                                                                                  
	local enemys
    if self.tyMenu.combo.Ult.useR1:Value() and myHero.attackSpeed >= 1.33 then
		enemys = OB:GetEnemyHeroes(1850)
	else
		enemys = OB:GetEnemyHeroes(1400)
	end

    for i = 1, #enemys do
        local enemy = enemys[i]
        local isKnock = self:IsKnock(enemy)
		if isKnock and Ready(_R) then	
			
			
			if self.tyMenu.combo.Ult.useR1:Value() and myHero.attackSpeed > 1.33 then
				local Etarget =  Ready(_E) and self:GetEtargetForUlt()
				
				if self.tyMenu.combo.Ult.useR3:Value() then
					local Count = self:KnockCount(400, enemy)			
					if Count+1 >= self.tyMenu.combo.Ult.Count:Value() then
						CanUlt = true
						if Etarget and Etarget.pos:DistanceTo(enemy.pos) < 1400 and self.lastETick+100 < GetTickCount() then
							self:CheckEQ(Etarget)
							if myHero:GetSpellData(_Q).currentCd <= (Game.Latency()*0.001+1.1) then
								Control.CastSpell(HK_E, Etarget)
								self.lastETick = GetTickCount()							
							end	
							DelayAction(function()
								if not myHero.pathing.isDashing and myHero.pos:DistanceTo(enemy.pos) <= 1400 then
									Control.CastSpell(HK_R, enemy)
								end
							end,0.1)					
						else
							DelayAction(function()
								if not myHero.pathing.isDashing and myHero.pos:DistanceTo(enemy.pos) <= 1400 then
									Control.CastSpell(HK_R, enemy)
								end
							end,0.1)												
						end
					end	
				end	
				
				if self.tyMenu.combo.Ult.useR2:Value() then
					local Dmg = getdmg("Q", enemy, myHero)*2 + getdmg("E", enemy, myHero)*2 + getdmg("R", enemy, myHero) + getdmg("AA", enemy, myHero)*2			
					if Dmg > enemy.health then
						CanUlt = true
						if Etarget and Etarget.pos:DistanceTo(enemy.pos) < 1400 and self.lastETick+100 < GetTickCount() then
							self:CheckEQ(Etarget)
							if myHero:GetSpellData(_Q).currentCd <= (Game.Latency()*0.001+1.1) then
								Control.CastSpell(HK_E, Etarget)
								self.lastETick = GetTickCount()
							end	
							DelayAction(function()
								if not myHero.pathing.isDashing and myHero.pos:DistanceTo(enemy.pos) <= 1400 then
									Control.CastSpell(HK_R, enemy)
								end
							end,0.1)
						else
							DelayAction(function()
								if not myHero.pathing.isDashing and myHero.pos:DistanceTo(enemy.pos) <= 1400 then
									Control.CastSpell(HK_R, enemy)
								end
							end,0.1)						
						end
					end	
				end
				
			else
			
				if self.tyMenu.combo.Ult.useR3:Value() then
					local Count = self:KnockCount(400, enemy)			
					if Count+1 >= self.tyMenu.combo.Ult.Count:Value() then
						CanUlt = true
						if not myHero.pathing.isDashing and myHero.pos:DistanceTo(enemy.pos) <= 1400 then
							Control.CastSpell(HK_R, enemy)
						end
					end	
				end	
				
				if self.tyMenu.combo.Ult.useR2:Value() then
					local Dmg = getdmg("Q", enemy, myHero)*2 + getdmg("E", enemy, myHero)*2 + getdmg("R", enemy, myHero) + getdmg("AA", enemy, myHero)*2			
					if Dmg > enemy.health then						
						CanUlt = true
						if not myHero.pathing.isDashing and myHero.pos:DistanceTo(enemy.pos) <= 1400 then
							Control.CastSpell(HK_R, enemy)
						end						
					end	
				end			
			end
        end
    end
	CanUlt = false
end

function Yasuo:UpdateQDelay()
    local activeSpell = myHero.activeSpell

    if activeSpell.valid then
        if activeSpell.name == "YasuoQ1" or activeSpell.name == "YasuoQ2" then
            self.Q.delay = activeSpell.windup
        end

        if activeSpell.name == "YasuoQ3" then
            self.Q3.delay = activeSpell.windup

            -- print(self.Q3.delay)
        end
    end
end

function Yasuo:Combo()
    local target = nil
    self.blockQ = false
	if WActive then return end

    if self.tyMenu.combo.useE:Value() and Ready(_E) and self.lastETick + 100 < GetTickCount() and not myHero.pathing.isDashing then
        local range = self.tyMenu.combo.Erange:Value()
        target = self:GetHeroTarget(range)
        local AArange = myHero.range + myHero.boundingRadius
        local Eobj, distance, inQrange


        if target and self.tyMenu.combo.Emode:Value() == 1 then

            Eobj, distance, inQrange = self:GetBestEObjToTarget(target, self.tyMenu.combo.ETower:Value())
            if Eobj and distance < myHero.pos:DistanceTo(target.pos) then
                --print("distance: "..distance.." myHero--Target : "..myHero.pos:DistanceTo(target.pos))
                if orbwalker:CanMove() and myHero.pos:DistanceTo(target.pos) > AArange then
                    --print("castE")
                    Control.CastSpell(HK_E, Eobj)
                    self.lastETick = GetTickCount()

                    local tmpTarget = target
                    DelayAction(function()
                        self:CheckEQ(tmpTarget)
                    end, (self.Epre.Delay-0.11))

                    if inQrange then
                        --print("blockQ 1")
                        self.blockQ = true
                    end
                end
            elseif Eobj and inQrange and Ready(_Q) and orbwalker:CanMove() then
                Control.CastSpell(HK_E, Eobj)
                --print("castE")

                DelayAction(function()
                    self:CheckEQ(target)
                end, self.Epre.Delay-0.11)
    
                self.lastETick = GetTickCount()

                if inQrange then
                    --print("blockQ 2")
                    self.blockQ = true
                end
            end
            
        elseif target and self.tyMenu.combo.Emode:Value() == 2 then
            Eobj, distance  = self:GetBestEObjToCursor(self.tyMenu.combo.ETower:Value())
            if Eobj and distance < mousePos:DistanceTo(target.pos) then
                Control.CastSpell(HK_E, Eobj)
               -- print("cast E combo "..GetTickCount())
                self.lastETick = GetTickCount()

                local tmpTarget = target
                DelayAction(function()
                    self:CheckEQ(tmpTarget)
                end, self.Epre.Delay - 0.09)

                local endPos = self:GetDashPos(Eobj)
                local Qdistance = target.pos:DistanceTo(endPos)
                if Qdistance < self.QCirWidth then
                    self.blockQ = true
                end
            end
        end

    end

    target = self:GetHeroTarget(self.Q3.range)
    if target and self.tyMenu.combo.useQ3:Value() and not self.blockQ then
        self:CastQ3(target)
    end

    target = self:GetHeroTarget(self.Q.range)
    if target and self.tyMenu.combo.useQL:Value() then
        self:CastQ(target)
    end


end

function Yasuo:Harass()
    local target = nil
	if WActive then return end
    target = self:GetHeroTarget(self.Q3.range)
    if target and self.tyMenu.harass.useQ3:Value() and not self.blockQ then
        self:CastQ3(target)
    end

    target = self:GetHeroTarget(self.Q.range)
    if target and self.tyMenu.harass.useQL:Value() then
        self:CastQ(target)
    end
end
				
function Yasuo:Clear()
    local minionInRange = OB:GetEnemyMinions(self.Q3.range)
    if next(minionInRange) == nil or WActive then return  end

    for i = 1, #minionInRange do
        local minion = minionInRange[i]
		
        if self.tyMenu.clear.useQ3:Value() and Ready(_Q) and not myHero.pathing.isDashing and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
			local Q3Count = GetLineTargetCount(myHero.pos, minion.pos, self.Q3.delay, self.Q3.speed, self.Q3.radius, self.Q3.range)
			if Q3Count >= self.tyMenu.clear.count:Value() then
				Control.CastSpell(HK_Q, minion.pos)
				self.lastQTick = GetTickCount()
			end	
        end		

        if self.tyMenu.clear.useQL:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 475 and not myHero.pathing.isDashing and myHero:GetSpellData(0).name ~= "YasuoQ3Wrapper" and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
			Control.CastSpell(HK_Q, minion.pos)
			self.lastQTick = GetTickCount()
        end

        if self.tyMenu.clear.useE:Value() and Ready(_E) and not myHero.pathing.isDashing  and self.lastETick + 100 < GetTickCount() and myHero.pos:DistanceTo(minion.pos) < 475 and orbwalker:CanMove(myHero) and not self:HasBuff(minion, "YasuoE") then
			local EQCount = GetMinionCount(230, minion)
			if self.tyMenu.clear.EQ:Value() and EQCount >= self.tyMenu.clear.count2:Value() and Ready(_Q) then
				if self.tyMenu.clear.ETower:Value() then
					local endPos = self:GetDashPos(minion)
					if self:OutOfTurrents(endPos) then
						Control.CastSpell(HK_E,minion)
						self.lastETick = GetTickCount()
						DelayAction(function()
							self:CheckEQ(minion)
						end, (self.Epre.Delay-0.11))						
					end
				else
					Control.CastSpell(HK_E,minion)
					self.lastETick = GetTickCount()
					DelayAction(function()
						self:CheckEQ(minion)
					end, (self.Epre.Delay-0.11))					
				end				
			else
				if self.tyMenu.clear.useE2:Value() == 1 then
					local delay = self:GetEDmgDelay(minion)
					local hpPred = CheckHPPred(minion, delay-0.3)				
					local EDmg = self:GetEDamge(minion)
					if EDmg > hpPred then
						if self.tyMenu.clear.ETower:Value() then
							local endPos = self:GetDashPos(minion)
							if self:OutOfTurrents(endPos) then
								Control.CastSpell(HK_E,minion)
								self.lastETick = GetTickCount()    
							end
						else
							Control.CastSpell(HK_E,minion)
							self.lastETick = GetTickCount()
						end
					end	
				else
					if self.tyMenu.clear.ETower:Value() then
						local endPos = self:GetDashPos(minion)
						if self:OutOfTurrents(endPos) then
							Control.CastSpell(HK_E,minion)
							self.lastETick = GetTickCount()    
						end
					else
						Control.CastSpell(HK_E,minion)
						self.lastETick = GetTickCount()
					end				
				end	
			end	
        end
    end
end		
		
function Yasuo:Jungle()
    local jungleInrange = OB:GetMonsters(self.Q3.range)
    if next(jungleInrange) == nil or WActive then return  end

    for i = 1, #jungleInrange do
        local minion = jungleInrange[i]

        if self.tyMenu.jungle.useQ3:Value() and Ready(_Q) and not myHero.pathing.isDashing and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
			Control.CastSpell(HK_Q, minion.pos)
			self.lastQTick = GetTickCount()	
        end		

        if self.tyMenu.jungle.useQL:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 475 and not myHero.pathing.isDashing and myHero:GetSpellData(0).name ~= "YasuoQ3Wrapper" and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
			Control.CastSpell(HK_Q, minion.pos)
			self.lastQTick = GetTickCount()
        end
		
        if self.tyMenu.jungle.EQ:Value() and Ready(_E) and not myHero.pathing.isDashing  and self.lastETick + 100 < GetTickCount() and myHero.pos:DistanceTo(minion.pos) < 475 and orbwalker:CanMove(myHero) and not self:HasBuff(minion, "YasuoE") then
			Control.CastSpell(HK_E,minion)
			self.lastETick = GetTickCount()
			DelayAction(function()
				self:CheckEQ(minion)
			end, (self.Epre.Delay-0.11))						
		end
	end	
end

function Yasuo:LastHit()
    local minionInRange = OB:GetEnemyMinions(self.Q3.range)
    if next(minionInRange) == nil or WActive then return  end

    for i = 1, #minionInRange do
        local minion = minionInRange[i]
		
        if self.tyMenu.last.useQ3:Value() and Ready(_Q) and not myHero.pathing.isDashing and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
			local delay = myHero.pos:DistanceTo(minion.pos)/1500 + self.tyMenu.ping:Value()/1000
			local hpPred = CheckHPPred(minion, delay)			
			local Q3Dmg = self:GetQDamge(minion)
			if Q3Dmg > hpPred then
				Control.CastSpell(HK_Q, minion.pos)
				self.lastQTick = GetTickCount()
			end	
        end		

        if self.tyMenu.last.useQL:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 475 and not myHero.pathing.isDashing and myHero:GetSpellData(0).name ~= "YasuoQ3Wrapper" and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
			local QDmg = self:GetQDamge(minion)
			if QDmg > minion.health then
				Control.CastSpell(HK_Q, minion.pos)
				self.lastQTick = GetTickCount()
			end	
        end

        if self.tyMenu.last.useE:Value() and Ready(_E) and not myHero.pathing.isDashing  and self.lastETick + 100 < GetTickCount() and myHero.pos:DistanceTo(minion.pos) < 475 and orbwalker:CanMove(myHero) and not self:HasBuff(minion, "YasuoE") then
			local delay = self:GetEDmgDelay(minion)
			local hpPred = CheckHPPred(minion, delay-0.3)				
			local EDmg = self:GetEDamge(minion)
			if EDmg > hpPred then
				if self.tyMenu.last.ETower:Value() then
					local endPos = self:GetDashPos(minion)
					if self:OutOfTurrents(endPos) then
						Control.CastSpell(HK_E,minion)
						self.lastETick = GetTickCount()    
					end
				else
					Control.CastSpell(HK_E,minion)
					self.lastETick = GetTickCount()
				end
			end	
        end
    end
end

function Yasuo:Flee()
    if WActive then return end
	if Ready(_E) and self.lastETick + 100 < GetTickCount() and not myHero.pathing.isDashing then
        local Eobj, distance  = self:GetBestEObjToCursor(self.tyMenu.flee.ETower:Value())
        if Eobj and distance < mousePos:DistanceTo(myHero.pos) then
            Control.CastSpell(HK_E, Eobj)
          --  print("E flee "..GetTickCount())
            self.lastETick = GetTickCount()
        end
    end
end

function Yasuo:GetDashPos(obj)
    local myPos = Vector(myHero.pos.x, myHero.pos.y, myHero.pos.z)
    local objPos = Vector(obj.pos.x, myHero.pos.y, obj.pos.z)
    local pos = myPos:Extended(objPos, 475)

    return pos
end

function Yasuo:OutOfTurrents(endPos)
    local turrets = OB:GetEnemyTurrets()
    local range = 88.5 + 750 + myHero.boundingRadius / 2
    for i = 1, #turrets do
        local turret = turrets[i]
        if self:IsInRange(endPos, turret.pos, range) then
            return false
        end
    end
    return true
end

function Yasuo:CheckEQ(target)
    --print("check EQ")
    if myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) <= self.QCirWidth and Ready(_Q) then
        Control.KeyDown(HK_Q)
        orbwalker:SetAttack(false)
        --print("E delay "..self.Epre.Delay)
        --print("EQ1 "..os.clock())
        DelayAction(function()
            Control.KeyUp(HK_Q)
           -- print("EQ2 "..os.clock())
            DelayAction(function()   
                orbwalker:SetAttack(true)
            end, 0.4)

        end, 0.05)
    end    
end

function Yasuo:GetEtargetForUlt()
    local minionInERange = OB:GetEnemyMinions(475)
    local jungleInErange = OB:GetMonsters(475)
    local heroInErange   = OB:GetEnemyHeroes(475)

    for i,minion in pairs (minionInERange) do 
        if not self:HasBuff(minion, "YasuoE") then
            return minion
        end
    end

    for i,minion in pairs (jungleInErange) do 
        if not self:HasBuff(minion, "YasuoE") then
            return minion
        end
    end

    for i,minion in pairs (heroInErange) do 
        if not self:HasBuff(minion, "YasuoE") then
            return minion
        end
    end
end

function Yasuo:GetEtargetInRange()
    local minionInERange = OB:GetEnemyMinions(475)
    local jungleInErange = OB:GetMonsters(475)
    local heroInErange   = OB:GetEnemyHeroes(475)

    for i,minion in pairs (minionInERange) do 
        if not self:HasBuff(minion, "YasuoE")  then
            return minion
        end
    end

    for i,minion in pairs (jungleInErange) do 
        if not self:HasBuff(minion, "YasuoE")  then
            return minion
        end
    end

    for i,minion in pairs (heroInErange) do 
        if not self:HasBuff(minion, "YasuoE") then
            return minion
        end
    end
end

function Yasuo:GetBestEObjToCursor(underTower)
    local minionInERange = OB:GetEnemyMinions(475)
    local jungleInErange = OB:GetMonsters(475)
    local heroInErange   = OB:GetEnemyHeroes(475)

    local minDistance = math.huge
    local bestMinion = nil

    for i,minion in pairs (minionInERange) do 
        if not self:HasBuff(minion, "YasuoE") then
            local endPos = self:GetDashPos(minion)
            local distance = mousePos:DistanceTo(endPos)

            if underTower then
                if self:OutOfTurrents(endPos) and distance < minDistance then
                    minDistance = distance
                    bestMinion = minion
                end
                        
            else
                if distance < minDistance then
                    minDistance = distance
                    bestMinion = minion
                end
            end
        end
    end

    if bestMinion == nil then
        for i,minion in pairs (jungleInErange) do 
            if not self:HasBuff(minion, "YasuoE") then
                local endPos = self:GetDashPos(minion)
                local distance = mousePos:DistanceTo(endPos)
    
                if underTower then
                    if self:OutOfTurrents(endPos) and distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                            
                else
                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end
            end
        end
    end

    if bestMinion == nil then
        for i,minion in pairs (heroInErange) do 
            if not self:HasBuff(minion, "YasuoE") then
                local endPos = self:GetDashPos(minion)
                local distance = mousePos:DistanceTo(endPos)
    
                if underTower then
                    if self:OutOfTurrents(endPos) and distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                            
                else
                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end
            end
        end
    end

    return bestMinion, minDistance

end

function Yasuo:GetBestEObjToTarget(target, underTower)
    local minionInERange = OB:GetEnemyMinions(475)
    local jungleInErange = OB:GetMonsters(475)
    local heroInErange   = OB:GetEnemyHeroes(475)

    --if next(minionInERange) == nil then return nil end

    local unitPos = self:GetTargetPosAfterEDelay(target)

    --prePos = unitPos

    local minDistance = math.huge
    local bestMinion = nil

    for i,minion in pairs (minionInERange) do 
        if not self:HasBuff(minion, "YasuoE") then
            local endPos = self:GetDashPos(minion)
            local distance = unitPos:DistanceTo(endPos)

            if underTower then
                if self:OutOfTurrents(endPos) then
                    if distance < self.QCirWidth then
                        return minion, distance, true
                    end

                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end

            else
                if distance < self.QCirWidth then
                    return minion, distance, true
                end

                if distance < minDistance then
                    minDistance = distance
                    bestMinion = minion
                end
            end
        end
    end

    if bestMinion == nil then
        for i,minion in pairs (jungleInErange) do 
            if not self:HasBuff(minion, "YasuoE") then
                local endPos = self:GetDashPos(minion)
                local distance = unitPos:DistanceTo(endPos)
    
                if underTower then
                    if self:OutOfTurrents(endPos) then
                        if distance < self.QCirWidth then
                            return minion, distance,true
                        end
    
                        if distance < minDistance then
                            minDistance = distance
                            bestMinion = minion
                        end
                    end
    
                else
                    if distance < self.QCirWidth then
                        return minion, distance, true
                    end
    
                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end
            end
        end
    end

    if bestMinion == nil then
        for i,minion in pairs (heroInErange) do 
            if not self:HasBuff(minion, "YasuoE") and minion ~= target then
                local endPos = self:GetDashPos(minion)
                local distance = unitPos:DistanceTo(endPos)
    
                if underTower then
                    if self:OutOfTurrents(endPos) then
                        if distance < self.QCirWidth then
                            return minion, distance, true
                        end
    
                        if distance < minDistance then
                            minDistance = distance
                            bestMinion = minion
                        end
                    end
    
                else
                    if distance < self.QCirWidth then
                        return minion, distance, true
                    end
    
                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end
            end
        end
    end



    if bestMinion == nil then
        if myHero.pos:DistanceTo(target.pos) < 475 and not self:HasBuff(target, "YasuoE") then 
            local endPos = self:GetDashPos(target)
            local distance = unitPos:DistanceTo(endPos)

            if underTower and not self:OutOfTurrents(endPos) then return end

            if distance < self.QCirWidth then
                --print("E target")
                return target, distance, true
            else 
                --print("E target")
                return target, distance
            end
        end
    end
    return bestMinion, minDistance
end

function Yasuo:GetEDelay()
    local movementSpeed = myHero.ms
    local Espeed = 715 + movementSpeed * 0.95

    return (475/Espeed + self.tyMenu.ping:Value()/1000)
end

function Yasuo:GetEDmgDelay(target)
    local movementSpeed = myHero.ms
    local Espeed = 715 + movementSpeed * 0.95
    local distance = myHero.pos:DistanceTo(target.pos)

    return (distance/Espeed + self.tyMenu.ping:Value()/1000)
end


function Yasuo:GetHeroTarget(range)
    local EnemyHeroes = OB:GetEnemyHeroes(range, false)
    local target = targetSelector:GetTarget(EnemyHeroes)

    return target
end
		
function Yasuo:CastQ(target)
	if Ready(_Q) and not myHero.pathing.isDashing 
	and myHero:GetSpellData(0).name ~= "YasuoQ3Wrapper" 
	and self.lastETick + 100 < GetTickCount() 
	and myHero.pos:DistanceTo(target.pos) <= self.Q.range 
	and orbwalker:CanMove(myHero) 
	and self.lastQTick + 300 < GetTickCount() then
		
		if self.tyMenu.Pred.Change:Value() == 1 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.Q)
			if pred.CastPos and ConvertToHitChance(self.tyMenu.Pred.PredQ:Value(), pred.HitChance) then
				Control.CastSpell(HK_Q, pred.CastPos)
				self.lastQTick = GetTickCount()
			end
		else
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.35, Radius = 40, Range = 475, Speed = math.huge, Collision = false})
				  QPrediction:GetPrediction(target, myHero)
			if QPrediction:CanHit(self.tyMenu.Pred.PredQ:Value()+1) then
				Control.CastSpell(HK_Q, QPrediction.CastPosition)
				self.lastQTick = GetTickCount()
			end	
		end
    end
end		

function Yasuo:CastQ3(target)
    if Ready(_Q) and not myHero.pathing.isDashing 
    and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" 
    and self.lastETick + 100 < GetTickCount() 
    and myHero.pos:DistanceTo(target.pos) <= self.Q3.range 
    and orbwalker:CanMove(myHero) 
    and self.lastQTick + 300 < GetTickCount() then
		
		if self.tyMenu.Pred.Change:Value() == 1 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.Q3)
			if pred.CastPos and ConvertToHitChance(self.tyMenu.Pred.PredQ3:Value(), pred.HitChance) then
				Control.CastSpell(HK_Q, pred.CastPos)
				self.lastQTick = GetTickCount()
			end
		else
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.35, Radius = 90, Range = 1060, Speed = 1500, Collision = false})
				  QPrediction:GetPrediction(target, myHero)
			if QPrediction:CanHit(self.tyMenu.Pred.PredQ3:Value()+1) then
				Control.CastSpell(HK_Q, QPrediction.CastPosition)
				self.lastQTick = GetTickCount()
			end	
		end 
    end
end

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
end

local lastWTick = 0
function Yasuo:CastW()
    if lastWTick + 1000 > GetTickCount() or not Ready(_W) or CanUlt then return end
    if self.tyMenu.windwall.Wcombo:Value() and not orbwalker.Modes[0] then return end
	
	local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and myHero.pos:DistanceTo(unit.pos) <= 2800 and spell and TargetedSpell[spell.name] ~= nil then
		--print(Vector(spell.placementPos))
		--print(Vector(spell.startPos))			
		local Col = VectorPointProjectionOnLineSegment(Vector(spell.startPos), Vector(spell.placementPos), myHero.pos)
		if spell.target == myHero.handle or GetDistanceSqr(myHero.pos, Col) < (spell.width/2 + myHero.boundingRadius * 1.25) ^ 2 and self.tyMenu.windwall.spell[spell.name]:Value() then               
			local dt = myHero.pos:DistanceTo(spell.startPos)
			local hitTime = TargetedSpell[spell.name].delay + dt/TargetedSpell[spell.name].speed
			WActive = true
			--print("hitTime: "..hitTime)

			DelayAction(function()
				Control.CastSpell(HK_W, unit.pos)
			end,  (hitTime - Game.Latency()*0.001 - 0.4))

			lastWTick = GetTickCount()
			return
		end           
	end
	WActive = false
end

function Yasuo:GetQDamge(obj)
    local baseDMG = ({20,45,70,95,120})[myHero:GetSpellData(0).level]
    local AD = myHero.totalDamage
    local dmg = dmglib:CalculateDamage(myHero, obj, _G.SDK.DAMAGE_TYPE_PHYSICAL ,  baseDMG + AD )

    return dmg
end

function Yasuo:GetEDamge(obj)
    local Ebonus = 1
    local buff, count = self:HasBuff(myHero, "YasuoDashScalar")
    if buff then
        if count == 1 then
            Ebonus = 1.25
        elseif count == 2 then
            Ebonus = 1.5
        end
    end

    local baseDMG = ({60,70,80,90,100})[myHero:GetSpellData(2).level]
    local AD = 0.2 * myHero.bonusDamage
    local AP = 0.6 * myHero.ap
    local dmg = dmglib:CalculateDamage(myHero, obj, _G.SDK.DAMAGE_TYPE_MAGICAL ,  baseDMG * Ebonus + AD + AP )

    return dmg
end

function Yasuo:HasBuff(unit, name)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name then
            return true , buff.count
        end
    end
    return false
end

function Yasuo:IsKnock(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local bType = buff.type
            if bType == 29 or bType == 30 then
                return true--, buff.duration
            end
        end
    end
    return false
end

function Yasuo:KnockCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
		local Range = range * range
		if hero ~= pos and GetDistanceSqr(pos, hero.pos) < Range and self:IsKnock(hero) then
		count = count + 1
		end
	end
	return count
end

function Yasuo:GetTargetPosAfterEDelay(unit)
	local predictedPosition = unit.pos
	local timeRemaining = self:GetEDelay()
	local pathNodes = GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function Yasuo:IsInRange(pos1, pos2, range)
    if GetDistanceSquared(pos1,pos2) < range * range then
        return true
    end
    return false
end

DelayAction(function()
	if table.contains(Heroes, myHero.charName) then		
		_G[myHero.charName]()			
	end	

	Callback.Add("Load", function()	
		LoadUnits()
	end)	
end, math.max(0.07, 30 - Game.Timer()))

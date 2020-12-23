require "MapPositionGOS"
require "2DGeometry"

local CCSpells = {
	["AatroxW"] = {charName = "Aatrox", displayName = "Infernal Chains", slot = _W, type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 80, collision = true},
	["AhriSeduce"] = {charName = "Ahri", displayName = "Seduce", slot = _E, type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, collision = true},
	["AkaliR"] = {charName = "Akali", displayName = "Perfect Execution [First]", slot = _R, type = "linear", speed = 1800, range = 525, delay = 0, radius = 65, collision = false},
	["Pulverize"] = {charName = "Alistar", displayName = "Pulverize", slot = _Q, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 365, collision = false},
	["BandageToss"] = {charName = "Amumu", displayName = "Bandage Toss", slot = _Q, type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, collision = true},
	["CurseoftheSadMummy"] = {charName = "Amumu", displayName = "Curse of the Sad Mummy", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 550, collision = false},
	["FlashFrostSpell"] = {charName = "Anivia", displayName = "Flash Frost",missileName = "FlashFrostSpell", slot = _Q, type = "linear", speed = 850, range = 1100, delay = 0.25, radius = 110, collision = false},
	["EnchantedCrystalArrow"] = {charName = "Ashe", displayName = "Enchanted Crystal Arrow", slot = _R, type = "linear", speed = 1600, range = 25000, delay = 0.25, radius = 130, collision = false},
	["AurelionSolQ"] = {charName = "AurelionSol", displayName = "Starsurge", slot = _Q, type = "linear", speed = 850, range = 25000, delay = 0, radius = 110, collision = false},
	["AzirR"] = {charName = "Azir", displayName = "Emperor's Divide", slot = _R, type = "linear", speed = 1400, range = 500, delay = 0.3, radius = 250, collision = false},
	["BardQ"] = {charName = "Bard", displayName = "Cosmic Binding", slot = _Q, type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, collision = true},
	["BardR"] = {charName = "Bard", displayName = "Tempered Fate", slot = _R, type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, collision = false},
	["RocketGrab"] = {charName = "Blitzcrank", displayName = "Rocket Grab", slot = _Q, type = "linear", speed = 1800, range = 1150, delay = 0.25, radius = 140, collision = true},
	["BraumQ"] = {charName = "Braum", displayName = "Winter's Bite", slot = _Q, type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = true},
	["BraumR"] = {charName = "Braum", displayName = "Glacial Fissure", slot = _R, type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, collision = false},
	["CaitlynYordleTrap"] = {charName = "Caitlyn", displayName = "Yordle Trap", slot = _W, type = "circular", speed = MathHuge, range = 800, delay = 0.25, radius = 75, collision = false},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = _E, type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},
	["CassiopeiaW"] = {charName = "Cassiopeia", displayName = "Miasma", slot = _W, type = "circular", speed = 2500, range = 800, delay = 0.75, radius = 160, collision = false},
	["Rupture"] = {charName = "Chogath", displayName = "Rupture", slot = _Q, type = "circular", speed = MathHuge, range = 950, delay = 1.2, radius = 250, collision = false},
	["InfectedCleaverMissile"] = {charName = "DrMundo", displayName = "Infected Cleaver", slot = _Q, type = "linear", speed = 2000, range = 975, delay = 0.25, radius = 60, collision = true},
	["DravenDoubleShot"] = {charName = "Draven", displayName = "Double Shot", slot = _E, type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, collision = false},
	["EkkoQ"] = {charName = "Ekko", displayName = "Timewinder", slot = _Q, type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, collision = false},
	["EkkoW"] = {charName = "Ekko", displayName = "Parallel Convergence", slot = _W, type = "circular", speed = MathHuge, range = 1600, delay = 3.35, radius = 400, collision = false},
	["EliseHumanE"] = {charName = "Elise", displayName = "Cocoon", slot = _E, type = "linear", speed = 1600, range = 1075, delay = 0.25, radius = 55, collision = true},
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
	["JarvanIVDragonStrike"] = {charName = "JarvanIV", displayName = "Dragon Strike", slot = _Q, type = "linear", speed = MathHuge, range = 770, delay = 0.4, radius = 70, collision = false},
	["JhinW"] = {charName = "Jhin", displayName = "Deadly Flourish", slot = _W, type = "linear", speed = 5000, range = 2550, delay = 0.75, radius = 40, collision = false},
	["JhinE"] = {charName = "Jhin", displayName = "Captive Audience", slot = _E, type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, collision = false},
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

local function GetEnemyTurret()
	local _EnemyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        if turret.isEnemy and not turret.dead then
			TableInsert(_EnemyTurrets, turret)
		end
	end
	return _EnemyTurrets		
end

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2) 
		if turret.pos:DistanceTo(unit.pos) < range then
			return true
		end
    end
    return false
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

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
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

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
			count = count + 1
		end
	end
	return count
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

local function minionCollision2(Pos1, Pos2, wight)
	local Collision = 0
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion.isTargetable and minion.team ~= TEAM_ALLY and minion.dead == false then
			local linesegment, line, isOnSegment = VectorPointProjectionOnLineSegment(Pos1, Pos2, minion.pos)
			if linesegment and isOnSegment and (GetDistanceSqr(minion.pos, linesegment) <= (minion.boundingRadius + wight) * (minion.boundingRadius + wight)) then
				Collision = Collision + 1
			end
		end
	end
	return Collision
end

local function CastSpellMM(spell,pos,range,delay)
local range = range or MathHuge
local delay = delay or 250
local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
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

local RQCast = false
local CastE = nil
local OldPos = nil
local noBuff = 0
local stuncast = 0

function LoadScript() 
	DetectedMissiles = {}; DetectedSpells = {}; Target = nil; Timer = 0	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.11"}})	
	
	Menu:MenuElement({type = MENU, id = "RSet", name = "AutoR+E Incomming CC Spells"})	
	Menu.RSet:MenuElement({id = "UseR", name = "Use AutoR + E Stun", value = true})	
	Menu.RSet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "ERange", name = "[E] max Cast range", value = 700, min = 0, max = 800, step = 10})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--W Seetings
	Menu.Combo:MenuElement({type = MENU, id = "Wset", name = "W Settings"})	
	Menu.Combo.Wset:MenuElement({id = "UseW", name = "Use[W]", value = true})
	Menu.Combo.Wset:MenuElement({id = "Change", name = "Auto or Combo/Harass?", value = 2, drop = {"AutoW", "Combo/Harass"}})	

	Menu.Combo.Wset:MenuElement({type = MENU, id = "red", name = "Redemption", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3107.png"})	
    Menu.Combo.Wset.red:MenuElement({id = "Self", name = "Use Redemption Zoe", value = true})	    
	Menu.Combo.Wset.red:MenuElement({id = "HPself", name = "If Zoe Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})
    Menu.Combo.Wset.red:MenuElement({id = "Ally", name = "Use Redemption Ally", value = true})	    
	Menu.Combo.Wset.red:MenuElement({id = "HPally", name = "If Ally Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "Sol", name = "Locket of the Iron Solari", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3190.png"})	
    Menu.Combo.Wset.Sol:MenuElement({id = "Self", name = "Use Solari Zoe", value = true})	    
	Menu.Combo.Wset.Sol:MenuElement({id = "HPself", name = "If Zoe Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})
    Menu.Combo.Wset.Sol:MenuElement({id = "Ally", name = "Use Solari Ally near", value = true})	    
	Menu.Combo.Wset.Sol:MenuElement({id = "HPally", name = "If Ally Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "You", name = "Youmuu's Ghostblade", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3142.png"})	
    Menu.Combo.Wset.You:MenuElement({id = "Youmuu", name = "Use Youmuu's", value = true})	    
	Menu.Combo.Wset.You:MenuElement({id = "HP", name = "If Zoe Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "Zho", name = "Zhonya's Hourglass", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3157.png"})	
    Menu.Combo.Wset.Zho:MenuElement({id = "zhonya", name = "Use Zhonya's", value = true})	    
	Menu.Combo.Wset.Zho:MenuElement({id = "HP", name = "If Zoe Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "Hex", name = "Hextech Rocketbelt", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3152.png"})	
	Menu.Combo.Wset.Hex:MenuElement({id = "Hextech", name = "Use Hextech", value = true})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "Eve", name = "EverFrost", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6656.png"})
	Menu.Combo.Wset.Eve:MenuElement({id = "EverFrost", name = "Use EverFrost", value = true})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "Pre", name = "Predator Boots"--[[, leftIcon = "https://cdn.discordapp.com/attachments/577088725394391073/791398878477811742/Predator_rune.png"]]})
    Menu.Combo.Wset.Pre:MenuElement({id = "Predator", name = "Use Predator Boots", value = true})
	Menu.Combo.Wset.Pre:MenuElement({id = "range", name = "If Target range lower than -->", value = 500, min = 0, max = 3000})		

    Menu.Combo.Wset:MenuElement({type = MENU, id = "Ran", name = "Randuin's Omen", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3143.png"})
    Menu.Combo.Wset.Ran:MenuElement({id = "randuin", name = "Use Randuin's", value = true})	
 	Menu.Combo.Wset.Ran:MenuElement({id = "count", name = "Min Targets", value = 2, min = 1, max = 5, step = 1})	
	
    Menu.Combo.Wset:MenuElement({type = MENU, id = "Ign", name = "Summoner Ignite", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerDot.png"})
	Menu.Combo.Wset.Ign:MenuElement({id = "ignite", name = "Use Ignite KS", value = true})
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "ex", name = "Summoner Exhaust", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerExhaust.png"})
    Menu.Combo.Wset.ex:MenuElement({id = "exhaust", name = "Use Exhaust", value = true})
	Menu.Combo.Wset.ex:MenuElement({id = "HP", name = "If Target Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "Sm", name = "Summoner Smite", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerSmite.png"})    
	Menu.Combo.Wset.Sm:MenuElement({id = "smite", name = "Use Smite", value = true})
	Menu.Combo.Wset.Sm:MenuElement({id = "HP", name = "If Target Hp lower than -->", value = 60, min = 0, max = 100, identifier = "%"})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "He", name = "Summoner Heal", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerHeal.png"})   
	Menu.Combo.Wset.He:MenuElement({id = "heal", name = "Use Heal", value = true})
	Menu.Combo.Wset.He:MenuElement({id = "HP", name = "If Zoe Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})	
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "Ba", name = "Summoner Barrier", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerBarrier.png"})	
    Menu.Combo.Wset.Ba:MenuElement({id = "barrier", name = "Use Barrier", value = true})
	Menu.Combo.Wset.Ba:MenuElement({id = "HP", name = "If Zoe Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})    
	
	Menu.Combo.Wset:MenuElement({type = MENU, id = "Cl", name = "Summoner Cleanse", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerBoost.png"})	
	Menu.Combo.Wset.Cl:MenuElement({id = "cleanse", name = "Use Cleanse if Immobile", value = true})

	Menu.Combo.Wset:MenuElement({type = MENU, id = "Ha", name = "Summoner Haste", leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerHaste.png"})   
	Menu.Combo.Wset.Ha:MenuElement({id = "haste", name = "Use Haste", value = true})
	Menu.Combo.Wset.Ha:MenuElement({id = "HP", name = "If Zoe Hp lower than -->", value = 30, min = 0, max = 100, identifier = "%"})
	
	--Ult Settings
--[[	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = " Extra Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R] Catch Item/Summoner", value = true})
    Menu.Combo.Ult:MenuElement({id = "ignite", name = "Summoner Ignite", value = true})
    Menu.Combo.Ult:MenuElement({id = "exhaust", name = "Summoner Exhaust", value = true})
    Menu.Combo.Ult:MenuElement({id = "smite", name = "Summoner Smite", value = true})
    Menu.Combo.Ult:MenuElement({id = "heal", name = "Summoner Heal", value = true})
    Menu.Combo.Ult:MenuElement({id = "barrier", name = "Summoner Barrier", value = true})
    Menu.Combo.Ult:MenuElement({id = "cleanse", name = "Summoner Cleanse", value = true})
    Menu.Combo.Ult:MenuElement({id = "zhonya", name = "Zhonya", value = true})	
    Menu.Combo.Ult:MenuElement({id = "proto", name = "Hectech Protobelt", value = true})
    Menu.Combo.Ult:MenuElement({id = "glp", name = "Hectech GLP-800", value = true})
    Menu.Combo.Ult:MenuElement({id = "hex", name = "Hextech Gunblade", value = true})    
	Menu.Combo.Ult:MenuElement({id = "red", name = "Redemption", value = true})
    Menu.Combo.Ult:MenuElement({id = "botrk", name = "Blade Of The Ruined King", value = true})
    Menu.Combo.Ult:MenuElement({id = "solari", name = "Locket of the Iron Solari", value = true})
    Menu.Combo.Ult:MenuElement({id = "omen", name = "Randuin's Omen", value = true})	
    Menu.Combo.Ult:MenuElement({id = "yo", name = "Youmuus Ghostblade", value = true})
    Menu.Combo.Ult:MenuElement({id = "rg", name = "Righteous Glory", value = true})
    Menu.Combo.Ult:MenuElement({id = "twin", name = "Twin Shadows", value = true})	
]]
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	Menu.Clear:MenuElement({id = "UseQM", name = "Use[Q] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})		
	Menu.Pred:MenuElement({id = "PredQ2", name = "Hitchance[Q2]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	
	Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()
		for i, spell in pairs(CCSpells) do
			if not CCSpells[i] then return end
			for j, k in pairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not Menu.RSet.BlockList[i] then
					if not Menu.RSet.BlockList[i] then Menu.RSet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)

	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0, Radius = 70, Range = 2500, Speed = 2500, Collision = false
	}
	
	QspellData = {speed = 2500, range = 2500, delay = 0, radius = 70, collision = {nil}, type = "linear"}		

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.3, Radius = 50, Range = 800, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}

	EspellData = {speed = 1700, range = 800, delay = 0.3, radius = 50, collision = {"minion"}, type = "linear"}	
  	                                           	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 575, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 800, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 800, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 550, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end
 
function Tick()
	if RQCast and not Ready(_R) then
		DelayAction(function()
			RQCast = false
		end,2.5)	
	end

	if MyHeroNotReady() then return end

	if Menu.RSet.UseR:Value() then
		Stun()
		ProcessSpell()
		for i, spell in pairs(DetectedSpells) do
			UseR(i, spell)
		end
	end

	local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.Combo.Wset.Change:Value() == 2 then
			CastW()
		end
		if CastE == nil then
			Combo1()
		end	
		--CastR()
	elseif Mode == "Harass" then		
		if Menu.Combo.Wset.Change:Value() == 2 then
			CastW()
		end		
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()			
	end

	if Menu.Combo.Wset.Change:Value() == 1 then
		CastW()
	end
end	

local function QRecast()   
    if myHero:GetSpellData(_Q).name == "ZoeQRecast" then 
		return true 
    end 
	return false
end

function ProcessSpell()	
	local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and spell and CCSpells[spell.name] and Ready(_R) then
		if myHero.pos:DistanceTo(unit.pos) > 3000 or not Menu.RSet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle then 
				SetMovement(false)
				if myHero.pos:DistanceTo(unit.pos) < 1300 and Ready(_E) then
					CastE = unit.pos
					OldPos = myHero.pos
					Control.CastSpell(HK_R, unit.pos) 				
					table.remove(DetectedSpells, i)
				end	
				if not Ready(_E) then	
					local castPos = Vector(unit.pos) - (Vector(myHero.pos) - Vector(unit.pos)):Perpendicular():Normalized() * 350	
					Control.CastSpell(HK_R, castPos)
					table.remove(DetectedSpells, i)
				end
				SetMovement(true)
			end
		else
			local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
			local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
			local endPos, range2 = CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
			table.insert(DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col})
		end
	end
end

function UseR(i, s)	
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == math.huge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > Game.Timer() and Ready(_R) then
		local Col = VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
		if s.type == "circular" or s.type == "linear" then 
			if GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
				local t = s.speed ~= math.huge and CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay) or 0.29
				if t < 0.7 then
					SetMovement(false)
					if myHero.pos:DistanceTo(s.startPos) < 1300 and Ready(_E) then
						CastE = s.startPos
						OldPos = myHero.pos
						Control.CastSpell(HK_R, s.startPos) 	
					end	
					if not Ready(_E) then	
						local castPos = Vector(s.startPos) - (Vector(myHero.pos) - Vector(s.startPos)):Perpendicular():Normalized() * 350	
						Control.CastSpell(HK_R, castPos)
					end
					SetMovement(true)
				end				
			end
		end	
	else table.remove(DetectedSpells, i) end
end

function Stun()
	if CastE ~= nil and OldPos ~= nil and Ready(_E) then
		if CastE:DistanceTo(myHero.pos) < CastE:DistanceTo(OldPos) then
			if Control.CastSpell(HK_E, CastE) then
				DelayAction(function()
					CastE = nil
					OldPos = nil
				end,0.3)	
			end	
		end
	end
end

function Combo1()
    
    local target = GetTarget(1700)
    local Collision
	local Collision2
    local pDir
    local point3
    local point4
    local point5
	local RPos
    local Q1PlacementPos
	
	if target and IsValid(target) then
        
		if myHero.pos:DistanceTo(target.pos) < Menu.Combo.ERange:Value() and Menu.Combo.UseE:Value() and Ready(_E) then            
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					stuncast = os.clock()
					Control.CastSpell(HK_E, pred.CastPosition) 
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					stuncast = os.clock()
					Control.CastSpell(HK_E, pred.CastPos) 
				end
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.3, Radius = 50, Range = 800, Speed = 1700, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					stuncast = os.clock()
					Control.CastSpell(HK_E, EPrediction.CastPosition)  
				end					
			end 
        end
		
		if os.clock() - stuncast > 1 and Ready(_Q) and Menu.Combo.UseQ:Value() and Ready(_R) and Menu.Combo.UseR:Value() and not QRecast() then
			if myHero.pos:DistanceTo(target.pos) < 700 then
				local startpos = myHero.pos
				local endpos = target.pos			
				local Rpoint = (startpos-Vector(startpos-endpos):Normalized():Perpendicular2():Perpendicular2()*700)		
				RPos = (Rpoint):Extended(myHero.pos, -600)	            
				Collision = minionCollision2(myHero.pos, RPos, 50)
				Collision2 = minionCollision2(RPos, Vector(target.pos), 70)
				if Collision == 0 and Collision2 == 0 then
					RQCast = true
					if Control.CastSpell(HK_R, (myHero.pos):Extended(RPos, 600)) and not QRecast() then
						DelayAction(function()
							Control.CastSpell(HK_Q, RPos)
						end,0.8)	
					end
				end
			else
				if myHero.pos:DistanceTo(target.pos) > 700 and myHero.pos:DistanceTo(target.pos) < 1200 and target.health/target.maxHealth < 0.4 and not IsUnderTurret(myHero) then
					local GapPos = myHero.pos:Extended(Vector(target.pos), 1000)
					if os.clock() - stuncast > 1 then
						local startpos = myHero.pos
						local endpos = target.pos				
						pDir = startpos-Vector(startpos-endpos):Normalized():Perpendicular()*700
						Collision = minionCollision2(myHero.pos, pDir, 50)
						Collision2 = minionCollision2(pDir, Vector(target.pos), 70)
						if Collision == 0 and Collision2 == 0 then
							--print("R1")
							RQCast = true
							noBuff = os.clock()
							if not QRecast() and Control.CastSpell(HK_Q, pDir) then
								DelayAction(function()
									Control.CastSpell(HK_R, GapPos)
								end,0.3)							
							end
							
						elseif os.clock() - stuncast > 1 then
							local startpos = myHero.pos
							local endpos = target.pos				
							point3 = startpos-Vector(startpos-endpos):Normalized():Perpendicular2()*700
							Collision = minionCollision2(myHero.pos, point3, 50)
							Collision2 = minionCollision2(point3, Vector(target.pos), 70)				
							if Collision == 0 and Collision2 == 0 then
								--print("R2")
								RQCast = true
								noBuff = os.clock()
								if not QRecast() and Control.CastSpell(HK_Q, point3) then
									DelayAction(function()
										Control.CastSpell(HK_R, GapPos)
									end,0.3)							
								end
							
							elseif os.clock() - stuncast > 1 then
								local startpos = myHero.pos
								local endpos = target.pos				
								point4 = startpos-Vector(startpos-endpos):Normalized():Perpendicular2():Perpendicular2()*700
								Collision = minionCollision2(myHero.pos, point4, 50)
								Collision2 = minionCollision2(point4, Vector(target.pos), 70)				
								if Collision == 0 and Collision2 == 0 then
									--print("R3")
									RQCast = true
									noBuff = os.clock()
									if not QRecast() and Control.CastSpell(HK_Q, point4) then
										DelayAction(function()
											Control.CastSpell(HK_R, GapPos)
										end,0.3)							
									end
									
								else
									if os.clock() - stuncast > 1 then  
										point5 = Vector(target.pos):Extended(myHero.pos, (700+myHero.pos:DistanceTo(target.pos)))
										Collision = minionCollision2(myHero.pos, point5, 50)
										Collision2 = minionCollision2(point5, Vector(target.pos), 70)				
										if Collision == 0 and Collision2 == 0 then
											--print("R4")
											RQCast = true
											noBuff = os.clock()
											if not QRecast() and Control.CastSpell(HK_Q, point5) then
												DelayAction(function()
													Control.CastSpell(HK_R, GapPos)
												end,0.3)							
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

        if not RQCast and Menu.Combo.UseQ:Value() and Ready(_Q) and not QRecast() and myHero.pos:DistanceTo(target.pos) < 800 then			
			
			if os.clock() - stuncast > 1 then
				local startpos = myHero.pos
				local endpos = target.pos				
				pDir = startpos-Vector(startpos-endpos):Normalized():Perpendicular()*700
				Collision = minionCollision2(myHero.pos, pDir, 50)
				Collision2 = minionCollision2(pDir, Vector(target.pos), 70)
				if Collision == 0 and Collision2 == 0 then
					--print("1")
					noBuff = os.clock()
					Control.CastSpell(HK_Q, pDir)
					
				elseif os.clock() - stuncast > 1 then
					local startpos = myHero.pos
					local endpos = target.pos				
					point3 = startpos-Vector(startpos-endpos):Normalized():Perpendicular2()*700
					Collision = minionCollision2(myHero.pos, point3, 50)
					Collision2 = minionCollision2(point3, Vector(target.pos), 70)				
					if Collision == 0 and Collision2 == 0 then
						--print("2")
						noBuff = os.clock()
						Control.CastSpell(HK_Q, point3)
					
					elseif os.clock() - stuncast > 1 then
						local startpos = myHero.pos
						local endpos = target.pos				
						point4 = startpos-Vector(startpos-endpos):Normalized():Perpendicular2():Perpendicular2()*700
						Collision = minionCollision2(myHero.pos, point4, 50)
						Collision2 = minionCollision2(point4, Vector(target.pos), 70)				
						if Collision == 0 and Collision2 == 0 then
							--print("3")
							noBuff = os.clock()
							Control.CastSpell(HK_Q, point4) 
							
						else
							if os.clock() - stuncast > 1 then  
								point5 = Vector(target.pos):Extended(myHero.pos, (700+myHero.pos:DistanceTo(target.pos)))
								Collision = minionCollision2(myHero.pos, point5, 50)
								Collision2 = minionCollision2(point5, Vector(target.pos), 70)				
								if Collision == 0 and Collision2 == 0 then
									--print("4")
									noBuff = os.clock()
									Control.CastSpell(HK_Q, point5) 									
								end
							end 						
						end 										
					end 					
				end 
			end
		end
	end	

	if QRecast() and Menu.Combo.UseQ2:Value() and Ready(_Q) then
		local Q2target = GetTarget(3000)
		local CastPosition	
		
		if Q2target and IsValid(Q2target) then 				
			local PredPos = PredQ2(Q2target)
			if PredPos then
				CastPosition = PredPos
			end		
			
			if not RQCast and CastPosition and myHero.pos:DistanceTo(CastPosition) > 750 then
				--print("Q2Secure")
				Control.CastSpell(HK_Q, CastPosition)
					
			elseif HasBuff(Q2target, "zoeesleepstun") and myHero.pos:DistanceTo(Q2target.pos) < 800 then
				Control.CastSpell(HK_Q, Q2target.pos)
			
			elseif CastPosition and os.clock() - noBuff > 0.6 and HasBuff(Q2target, "zoeesleepcountdownslow") and myHero.pos:DistanceTo(Q2target.pos) < 800 then
				Control.CastSpell(HK_Q, CastPosition)
			
			elseif IsImmobileTarget(Q2target) and myHero.pos:DistanceTo(Q2target.pos) < 800 then
				Control.CastSpell(HK_Q, Q2target.pos)
				
			else				
				if CastPosition and os.clock() - noBuff > 0.5 and myHero.pos:DistanceTo(Q2target.pos) < 800 and not HasBuff(Q2target, "zoeesleepcountdownslow") then  
					Control.CastSpell(HK_Q, CastPosition)
				end
			end	
		end	
    end
end	

function CastW()
	local WName = myHero:GetSpellData(_W).name:lower()
	if WName == "zoew" then return end
	if WName == "itemredemption" and Menu.Combo.Wset.UseW:Value() and Ready(_W) then
		if Menu.Combo.Wset.red.Self:Value() and myHero.health/myHero.maxHealth < Menu.Combo.Wset.red.HPself:Value() / 100 and GetEnemyCount(1500, myHero) > 0 then
			Control.CastSpell(HK_W, myHero.pos)
		else
			if Menu.Combo.Wset.red.Ally:Value() then
				for i, Ally in ipairs(GetAllyHeroes()) do
					if Ally and myHero.pos:DistanceTo(Ally.pos) <= 5500 and IsValid(Ally) and Ally.health/Ally.maxHealth < Menu.Combo.Wset.red.HPally:Value() / 100 and GetEnemyCount(1500, Ally) > 0 then
						if Ally.pos:To2D().onScreen then						
							Control.CastSpell(HK_W, Ally.pos) 
							
						elseif not Ally.pos:To2D().onScreen then			
							CastSpellMM(HK_W, Ally.pos, 5500)
						end								
					end
				end
			end	
		end	
	end	
	
	local target = GetTarget(2000)
	if target == nil then return end
	
	if IsValid(target) then
		if Menu.Combo.Wset.UseW:Value() and Ready(_W) then

			--//// OFFENSIVE ////--
			if WName == "summonerdot" then --
				if target.pos:DistanceTo() < 600 and Menu.Combo.Wset.Ign.ignite:Value() then
					local IgnDmg = getdmg("IGNITE", target, myHero)
					if target.health < IgnDmg then
						Control.CastSpell(HK_W, target)
					end	
				end
				
			elseif WName == "summonerexhaust" then  --
				if target.pos:DistanceTo() < 650 and Menu.Combo.Wset.ex.exhaust:Value() then 
					if target.health/target.maxHealth <= Menu.Combo.Wset.ex.HP:Value()/100 then
						Control.CastSpell(HK_W, target)
					end	
				end
				
			elseif WName == "s5_summonersmiteplayerganker" then  --
				if target.pos:DistanceTo() < 500 and Menu.Combo.Wset.Sm.smite:Value() then
					if target.health/target.maxHealth <= Menu.Combo.Wset.Sm.HP:Value()/100 then
						Control.CastSpell(HK_W, target)
					end	
				end
				
			elseif WName == "randuinsomen" then --
				if GetEnemyCount(500, myHero) >= Menu.Combo.Wset.Ran.count:Value() and Menu.Combo.Wset.Ran.randuin:Value() then
					Control.CastSpell(HK_W)
				end
				
			elseif WName == "itembloodmoonbootsactive" then --
				if target.pos:DistanceTo() < Menu.Combo.Wset.Pre.range:Value() and Menu.Combo.Wset.Pre.Predator:Value() then
					Control.CastSpell(HK_W)
				end	
				
			elseif WName == "6656cast" then --
				if target.pos:DistanceTo() < 700 and Menu.Combo.Wset.Eve.EverFrost:Value() then	
					Control.CastSpell(HK_W, target.pos)
				end
				
			elseif WName == "3152active" then --
				if target.pos:DistanceTo() < 700 and Menu.Combo.Wset.Hex.Hextech:Value() then					
					Control.CastSpell(HK_W, target.pos) 
				end
			
			--//// DEFENSIVE ////--
			elseif WName == "summonerheal" then--
				if myHero.health/myHero.maxHealth < Menu.Combo.Wset.He.HP:Value() / 100 and Menu.Combo.Wset.He.heal:Value() then 
					Control.CastSpell(HK_W)
				end
				
			elseif WName == "summonerbarrier" then --
				if myHero.health/myHero.maxHealth < Menu.Combo.Wset.Ba.HP:Value() / 100 and Menu.Combo.Wset.Ba.barrier:Value() then
					Control.CastSpell(HK_W)
				end	
				
			elseif WName == "summonerhaste" then --
				if myHero.health/myHero.maxHealth < Menu.Combo.Wset.Ha.HP:Value() / 100 and Menu.Combo.Wset.Ha.haste:Value() then
					Control.CastSpell(HK_W)
				end	
				
			elseif WName == "summonerboost" then --
				if IsImmobileTarget(myHero) and Menu.Combo.Wset.Cl.cleanse:Value() then
					Control.CastSpell(HK_W)
				end
				
			elseif WName == "zhonyashourglass" then --
				if myHero.health/myHero.maxHealth < Menu.Combo.Wset.Zho.HP:Value() / 100 and Menu.Combo.Wset.Zho.zhonya:Value() then
					Control.CastSpell(HK_W)
				end
				
			elseif WName == "youmusblade" then --
				if myHero.health/myHero.maxHealth < Menu.Combo.Wset.You.HP:Value() / 100 and Menu.Combo.Wset.You.Youmuu:Value() then
					Control.CastSpell(HK_W)
				end	
	
			elseif WName == "3190active" then --
				if Menu.Combo.Wset.Sol.Self:Value() and myHero.health/myHero.maxHealth < Menu.Combo.Wset.Sol.HPself:Value() / 100 then
					Control.CastSpell(HK_W)
				else
					if Menu.Combo.Wset.Sol.Ally:Value() then
						for i, Ally in ipairs(GetAllyHeroes()) do
							if Ally and myHero.pos:DistanceTo(Ally.pos) <= 600 and IsValid(Ally) and Ally.health/Ally.maxHealth < Menu.Combo.Wset.Sol.HPally:Value() / 100 then
								Control.CastSpell(HK_W)
							end
						end
					end	
				end			
			end	
		end
	end	
end
--[[
function CastR()
	if Menu.Combo.Ult.UseR:Value() and Ready(_R) then
			local WName = myHero:GetSpellData(_W).name:lower()
			local Hp = myHero.health/myHero.maxHealth < Menu.Combo.Wset.HP:Value() / 100 
			if WName == "summonerdot" and target.pos:DistanceTo() < 600 and Menu.Combo.Wset.ignite:Value()
			or WName == "summonerexhaust"  and target.pos:DistanceTo() < 650 and Menu.Combo.Wset.exhaust:Value() 
			or WName == "hextechgunblade"  and target.pos:DistanceTo() < 700 and Menu.Combo.Wset.hex:Value()
			or WName == "s5_summonersmiteplayerganker"  and target.pos:DistanceTo() < 500 and Menu.Combo.Wset.smite:Value() 
			or WName == "itemswordoffeastandfamine"  and target.pos:DistanceTo() < 550 and Menu.Combo.Wset.botrk:Value()
			then Control.CastSpell(HK_W, target) 
			end

			if WName == "summonerheal" and Hp and Menu.Combo.Wset.heal:Value() 
			or WName == "summonerbarrier" and Hp and Menu.Combo.Wset.barrier:Value()
			or WName == "zhonyasHourglass" and Hp and Menu.Combo.Wset.zhonya:Value()
			or WName == "summonerboost" and Hp and Menu.Combo.Wset.cleanse:Value()
		 	or WName == "itemstylus"  and target.pos:DistanceTo() < 600 and Menu.Combo.Wset.solari:Value()
			or WName == "youmusblade"  and target.pos:DistanceTo() < 600 and Menu.Combo.Wset.yo:Value() 
			or WName == "itemrighteousglory"  and target.pos:DistanceTo() < 600 and Menu.Combo.Wset.rg:Value()
			or WName == "itemomen"  and target.pos:DistanceTo() < 500 and Menu.Combo.Wset.omen:Value()
			or WName == "itemtwin"  and target.pos:DistanceTo() < 2000 and target.pos:DistanceTo() > 500 and Menu.Combo.Wset.twin:Value()			
			then Control.CastSpell(HK_W) 
			end

			if WName == "itemsofboltspellbase" and target.pos:DistanceTo() < 600 and Menu.Combo.Wset.proto:Value()  
			or WName == "itemwillboltspellbase" and target.pos:DistanceTo() < 600 and Menu.Combo.Wset.glp:Value() 
			or WName == "itemredemption" and target.pos:DistanceTo() < 600 and Menu.Combo.Wset.red:Value() 
			or WName == "ironstylus" and target.pos:DistanceTo() < 600 and Menu.Combo.Wset.red:Value() 
			then Control.CastSpell(HK_W, target.pos) 
			end	
		end
	end	
]]

function Harass()              
	if Menu.Harass.UseQ:Value() and Ready(_Q) and not QRecast() then
		local target = GetTarget(800)
		if target == nil then return end
			
		local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
		if IsValid(target) and mana_ok then			
			if os.clock() - stuncast > 1 then
				local startpos = myHero.pos
				local endpos = target.pos				
				pDir = startpos-Vector(startpos-endpos):Normalized():Perpendicular()*700
				Collision = minionCollision2(myHero.pos, pDir, 50)
				Collision2 = minionCollision2(pDir, Vector(target.pos), 70)
				if Collision == 0 and Collision2 == 0 then
					noBuff = os.clock()
					Control.CastSpell(HK_Q, pDir)
					return
				end 
			end
		
			if os.clock() - stuncast > 1 then
				local startpos = myHero.pos
				local endpos = target.pos				
				point3 = startpos-Vector(startpos-endpos):Normalized():Perpendicular2()*700
				Collision = minionCollision2(myHero.pos, point3, 50)
				Collision2 = minionCollision2(point3, Vector(target.pos), 70)				
				if Collision == 0 and Collision2 == 0 then
					noBuff = os.clock()
					Control.CastSpell(HK_Q, point3)
					return
				end 
			end
						
			if os.clock() - stuncast > 1 then
				local startpos = myHero.pos
				local endpos = target.pos				
				point4 = startpos-Vector(startpos-endpos):Normalized():Perpendicular2():Perpendicular2()*700
				Collision = minionCollision2(myHero.pos, point4, 50)
				Collision2 = minionCollision2(point4, Vector(target.pos), 70)				
				if Collision == 0 and Collision2 == 0 then
					noBuff = os.clock()
					Control.CastSpell(HK_Q, point4) 
					return
				end 
			end
			
			if os.clock() - stuncast > 1 then  
				point5 = Vector(target.pos):Extended(myHero.pos, (700+myHero.pos:DistanceTo(target.pos)))
				Collision = minionCollision2(myHero.pos, point5, 50)
				Collision2 = minionCollision2(point5, Vector(target.pos), 70)				
				if Collision == 0 and Collision2 == 0 then
					noBuff = os.clock()
					Control.CastSpell(HK_Q, point5) 
					return
				end
			end 
		end
	end	
	
	if QRecast() and Menu.Harass.UseQ2:Value() and Ready(_Q) then
		local Q2target = GetTarget(5000)
		local CastPosition	
		
		if Q2target and IsValid(Q2target) then 				
			local PredPos = PredQ2(Q2target)
			if PredPos then
				CastPosition = PredPos
			end
					
			if HasBuff(Q2target, "zoeesleepstun") and myHero.pos:DistanceTo(Q2target.pos) < 800 then
				Control.CastSpell(HK_Q, Q2target.pos)
				
			end
			
			if CastPosition and os.clock() - noBuff > 0.6 and HasBuff(Q2target, "zoeesleepcountdownslow") and myHero.pos:DistanceTo(Q2target.pos) < 800 then
				Control.CastSpell(HK_Q, CastPosition)
				
			end
			
			if IsImmobileTarget(Q2target) and myHero.pos:DistanceTo(Q2target.pos) < 800 then
				Control.CastSpell(HK_Q, Q2target.pos)
				
			end
			
			if CastPosition and os.clock() - noBuff > 0.5 and myHero.pos:DistanceTo(Q2target.pos) < 800 and not HasBuff(Q2target, "zoeesleepcountdownslow") then  
				Control.CastSpell(HK_Q, CastPosition)
			end
		end	
	end		
end	

function PredQ2(unit)
	local PredictPos = nil
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, QData, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ2:Value()+1 then
			PredictPos = pred.CastPosition	
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ2:Value(), pred.HitChance) then
			PredictPos = pred.CastPos
		end	
	else
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.3, Radius = 70, Range = 2500, Speed = 2500, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ2:Value() + 1) then
			PredictPos = QPrediction.CastPosition	
		end					
	end
	return PredictPos
end

function Clear()
	if Ready(_Q) then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
			
			if QRecast() then	
				if os.clock() - noBuff > 0.8 and myHero.pos:DistanceTo(minion.pos) < 2000 and IsValid(minion) and minion.team == TEAM_ENEMY then			
					if Menu.Clear.UseQ2:Value() then
						Control.CastSpell(HK_Q, minion.pos)	
					end
				end	
			
			else
			
				if myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and minion.team == TEAM_ENEMY then			
					local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100					
					if Menu.Clear.UseQ:Value() and mana_ok  then
						local count = GetMinionCount(275, minion)
						if count >= Menu.Clear.UseQM:Value() then					
							local Pos = Vector(minion.pos):Extended(myHero.pos, (700+myHero.pos:DistanceTo(minion.pos)))
							local Collision = minionCollision2(myHero.pos, Pos, 50)
							if Collision == 0 then
								noBuff = os.clock()
								Control.CastSpell(HK_Q, Pos)
							end
						end	
					end			
				end
			end
		end	
	end
end

function JungleClear()
	if Ready(_Q) then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
			
			if QRecast() then	
				if os.clock() - noBuff > 0.8 and myHero.pos:DistanceTo(minion.pos) < 2000 and IsValid(minion) and minion.team == TEAM_JUNGLE then			
					if Menu.JClear.UseQ2:Value() then
						Control.CastSpell(HK_Q, minion.pos)	
					end
				end	
			
			else
			
				if myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and minion.team == TEAM_JUNGLE then			
					local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
					if Menu.JClear.UseQ:Value() and mana_ok  then							
						local Pos = Vector(minion.pos):Extended(myHero.pos, (700+myHero.pos:DistanceTo(minion.pos)))
						local Collision = minionCollision2(myHero.pos, Pos, 50)
						if Collision == 0 then
							noBuff = os.clock()
							Control.CastSpell(HK_Q, Pos)
						end				
					end			
				end
			end
		end	
	end	
end

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

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
end

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

local function HasBuff(unit, buffName)
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
		if buff and (buff.type == 5 or buff.type == 8 or buff.type == 12 or buff.type == 22 or buff.type == 23 or buff.type == 25 or buff.type == 30 or buff.type == 35 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in pairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
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

local function GetDmgSpells(unit)
	Damage = 0
	
	if Ready(_Q) then
		Damage = Damage + getdmg("Q", unit, myHero)
	end

	if Ready(_W) then
		Damage = Damage + getdmg("W", unit, myHero)
	end	

	if Ready(_E) then
		Damage = Damage + getdmg("E", unit, myHero)
	end	

	if Ready(_R) then
		Damage = Damage + getdmg("R", unit, myHero)
	end
	
	if HasBuff(myHero, "volibearpapplicator") then
		local LvL = myHero.levelData.lvl
		if LvL <= 3 then
			Damage = Damage + (10 + 1 * LvL) + 0.4 * myHero.ap
		elseif LvL <= 6 and LvL > 3 then
			Damage = Damage + (10 + 2 * LvL) + 0.4 * myHero.ap	
		elseif LvL <= 13 and LvL > 6 then
			Damage = Damage + (10 + 3 * LvL) + 0.4 * myHero.ap
		elseif LvL > 13 then
			Damage = Damage + (10 + 4 * LvL) + 0.4 * myHero.ap	
		end	
	end	
	return Damage
end

function LoadScript()
	DetectedMissiles = {}; DetectedSpells = {}; Target = nil; Timer = 0
	CanUlt = false	
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})		
	
	--AutoQ	
	Menu:MenuElement({type = MENU, id = "QSet", name = "AutoQ"})	
	Menu.QSet:MenuElement({id = "UseQ", name = "Use [Q] Incomming CC Spells", value = true})	
	Menu.QSet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})	
	
	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})	
	Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E] Immobile Target", value = true})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "E", name = "Use [E] in -->", value = 1, drop = {"Shield range (425)", "Full range (1200)"}})
	Menu.Combo:MenuElement({name = " ", drop = {"---- Ult Settings ----"}})
	Menu.Combo:MenuElement({id = "UseR", name = "[R] Single Target [full Dmg Calc.]", value = true})	
	Menu.Combo:MenuElement({name = " ", drop = {"----------------------"}})	
	Menu.Combo:MenuElement({id = "UseR2", name = "[R] Multible Targets", value = true})	
	Menu.Combo:MenuElement({id = "UseRM", name = "min Targets", value = 2, min = 1, max = 5})
	Menu.Combo:MenuElement({name = " ", drop = {"----------------------"}})	
	Menu.Combo:MenuElement({id = "UseR3", name = "[R] Low Voli Hp", value = true})	
	Menu.Combo:MenuElement({id = "UseRH", name = "If Voli Hp lower than -->", value = 50, min = 0, max = 100, identifier = "%"})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] in Stun range", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E] full range", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true}) 	
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseE", name = "[E] full range", value = true})		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets [possible Dmg]", value = true})
	
	Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()
		for i, spell in pairs(CCSpells) do
			if not CCSpells[i] then return end
			for j, k in pairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not Menu.QSet.BlockList[i] then
					if not Menu.QSet.BlockList[i] then Menu.QSet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)
	
	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 2, Radius = 325, Range = 1200, Speed = 1200, Collision = false
	}
	
	EspellData = {speed = 1200, range = 1200, delay = 2, radius = 325, collision = {nil}, type = "circular"}	

	RData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 500, Range = 700, Speed = 750, Collision = false
	}
	
	RspellData = {speed = 750, range = 700, delay = 0.25, radius = 500, collision = {nil}, type = "circular"}	

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 700, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 1200, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 325, 1, DrawColor(225, 225, 125, 10))
		end
		
		for i, target in pairs(GetEnemyHeroes()) do	
			if Menu.Drawing.Kill:Value() and myHero.pos:DistanceTo(target.pos) <= 5000 and IsValid(target) then
			local hp = target.health	
			local Dmg = GetDmgSpells(target)
				if Dmg > hp then
					DrawText("Killable", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
					DrawText("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))		
				end	
			end
		end	
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		Ult()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()			
	end	

	KillSteal()
	AutoE()

	if Menu.QSet.UseQ:Value() and Ready(_Q) then
		ProcessSpell()
		for i, spell in pairs(DetectedSpells) do
			UseQ(i, spell)
		end
	end	
end

function ProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and spell and CCSpells[spell.name] then
		if myHero.pos:DistanceTo(unit.pos) > 3000 or not Menu.QSet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle then 
				Control.KeyDown(HK_Q)
				Control.KeyUp(HK_Q)
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

function UseQ(i, s)
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
				if t < 0.6 then
					Control.KeyDown(HK_Q)
					Control.KeyUp(HK_Q)
				end				
			end
		end	
	else TableRemove(DetectedSpells, i) end
end

function AutoE()
	if Menu.AutoE.UseE:Value() and Ready(_E) then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if myHero.pos:DistanceTo(enemy.pos) <= 1200 and IsValid(enemy) then
				local Immobile = IsImmobileTarget(enemy)
				if Immobile then
					CastE(enemy)
				end
			end
		end	
	end
end

function KillSteal()
	if Menu.ks.UseE:Value() and Ready(_E) then	
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if myHero.pos:DistanceTo(enemy.pos) < 1200 and IsValid(enemy) then
				local EDmg = getdmg("E", enemy, myHero)
				local Hp = enemy.health + (enemy.hpRegen * 5)
				if EDmg >= Hp then
					CastE(enemy)
				end
			end
		end
	end	
end

function Ult()
	if Ready(_R) then
		local target = GetTarget(1200)
		if target == nil then return end
		local countTarget = GetEnemyCount(500, target)
		local countMyHero = GetEnemyCount(2000, myHero)
	
		if Menu.Combo.UseR2:Value() then		
			if myHero.pos:DistanceTo(target.pos) < 700 and IsValid(target) then
				if countTarget >= Menu.Combo.UseRM:Value() then
					CanUlt = true
					CastR(target)
				end
			end
		end

		if Menu.Combo.UseR:Value() and countMyHero == 1 then
			if myHero.pos:DistanceTo(target.pos) < 700 and IsValid(target) then
				local Dmg = GetDmgSpells(target)
				local Hp = target.health
				if Dmg > Hp then
					CanUlt = true
					CastR(target)
				end
			end
		end
		
		if Menu.Combo.UseR3:Value() then
			if myHero.pos:DistanceTo(target.pos) < 700 and IsValid(target) then
				if myHero.health/myHero.maxHealth <= Menu.Combo.UseRH:Value() / 100 then
					CanUlt = true
					CastR(target)
				end
			end
		end	
	end
	CanUlt = false	
end	

function Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) and CanUlt == false then
		
		if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 500 and myHero.attackData.state == 2 then
			Control.CastSpell(HK_Q, target.pos)
        end
       
		if Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 380 then
			Control.CastSpell(HK_W, target)	
        end
		
		if Menu.Combo.UseE:Value() and Ready(_E) then 
			if Menu.Combo.E:Value() == 1 then
				if myHero.pos:DistanceTo(target.pos) < 425 then
					CastE(target)
				end
			else
				if myHero.pos:DistanceTo(target.pos) < 1200 then
					CastE(target)
				end				
			end	
        end		
	end
end

function Harass()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
        
		if Menu.Harass.UseQ:Value() and Ready(_Q) and mana_ok and myHero.pos:DistanceTo(target.pos) < 500 and myHero.attackData.state == 2 then
			Control.CastSpell(HK_Q, target.pos)
        end
		
        if Menu.Harass.UseW:Value() and Ready(_W) and mana_ok and myHero.pos:DistanceTo(target.pos) <= 380 then
			Control.CastSpell(HK_W, target)
        end	
		
		if Menu.Harass.UseE:Value() and Ready(_E) and mana_ok and myHero.pos:DistanceTo(target.pos) <= 1200 then 
			CastE(target)
        end		
	end
end

function CastE(unit)	
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, EData, myHero)
		if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
			Control.CastSpell(HK_E, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
			Control.CastSpell(HK_E, pred.CastPos)
		end	
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 2, Radius = 325, Range = 1200, Speed = 1200, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end		
	end
end	

function CastR(unit)	
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, RData, myHero)
		if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
			Control.CastSpell(HK_R, pred.CastPos)
		end
	else
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 500, Range = 700, Speed = 750, Collision = false})
		RPrediction:GetPrediction(unit, myHero)
		if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
			Control.CastSpell(HK_R, RPrediction.CastPosition)
		end		
	end
end
	
function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQ:Value() and Ready(_Q) and mana_ok and myHero.pos:DistanceTo(minion.pos) < 500 and IsValid(minion) and myHero.attackData.state == 2 then
				Control.CastSpell(HK_Q, minion.pos)	
            end
			
            if Menu.Clear.UseW:Value() and Ready(_W) and mana_ok and myHero.pos:DistanceTo(minion.pos) < 380 and IsValid(minion) then
				Control.CastSpell(HK_W, minion)
            end
			
			
            if Menu.Clear.UseE:Value() and Ready(_E) and mana_ok then
				if myHero.pos:DistanceTo(minion.pos) < 1200 and IsValid(minion) then 
					local count = GetMinionCount(325, minion) 
					if count >= Menu.Clear.UseEM:Value() then
						Control.CastSpell(HK_E, minion.pos)
					end	
				end
            end			
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and Ready(_Q) and mana_ok and myHero.pos:DistanceTo(minion.pos) < 500 and IsValid(minion) and myHero.attackData.state == 2 then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and Ready(_W) and mana_ok and myHero.pos:DistanceTo(minion.pos) < 380 and IsValid(minion) then	
				Control.CastSpell(HK_W, minion)	
            end
			
            if Menu.JClear.UseE:Value() and Ready(_E) and mana_ok then
				if myHero.pos:DistanceTo(minion.pos) < 1200 and IsValid(minion) then 
					Control.CastSpell(HK_E, minion.pos)				
				end
            end			
        end
    end
end

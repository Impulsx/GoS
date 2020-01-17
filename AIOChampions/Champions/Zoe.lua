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

function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
end

function HasBuff(unit, buffname)
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

function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end 

function GetMinionCount(range, pos)
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

function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function CalculateEndPos(startPos, placementPos, unitPos, range, radius, collision, type)
	local range = range or 3000; local endPos = startPos:Extended(placementPos, range)
	if type == "circular" or type == "rectangular" then
		if range > 0 then if GetDistance(unitPos, placementPos) < range then endPos = placementPos end
		else endPos = unitPos end
	elseif collision then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
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

function CalculateCollisionTime(startPos, endPos, unitPos, startTime, speed, delay, origin)
	local pos = startPos:Extended(endPos, speed * (GameTimer() - delay - startTime))
	return GetDistance(unitPos, pos) / speed
end

require "MapPositionGOS"

function LoadScript()
	OnProcessSpell() 
	DetectedMissiles = {}; DetectedSpells = {}; Target = nil; Timer = 0	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Not Finished Version"}})	
	
	Menu:MenuElement({type = MENU, id = "RSet", name = "AutoR+E Incomming CC Spells"})	
	Menu.RSet:MenuElement({id = "UseR", name = "Use AutoR + fullCombo", value = true})	
	Menu.RSet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseQ2", name = "[Q2]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R] Increase Q2 Range", value = true})		
	Menu.Combo:MenuElement({id = "UseR2", name = "[R]+[Q] Immobile Target", value = true})
	
	--W Seetings
	Menu.Combo:MenuElement({type = MENU, id = "Wset", name = "W Settings"})	
	Menu.Combo.Wset:MenuElement({id = "UseW", name = "Use[W]", value = true})
    Menu.Combo.Wset:MenuElement({id = "ignite", name = "Summoner Ignite", value = true})
    Menu.Combo.Wset:MenuElement({id = "exhaust", name = "Summoner Exhaust", value = true})
    Menu.Combo.Wset:MenuElement({id = "smite", name = "Summoner Smite", value = true})
    Menu.Combo.Wset:MenuElement({id = "heal", name = "Summoner Heal", value = true})
    Menu.Combo.Wset:MenuElement({id = "barrier", name = "Summoner Barrier", value = true})
    Menu.Combo.Wset:MenuElement({id = "cleanse", name = "Summoner Cleanse", value = true})
    Menu.Combo.Wset:MenuElement({id = "zhonya", name = "Zhonya", value = true})	
    Menu.Combo.Wset:MenuElement({id = "proto", name = "Hectech Protobelt", value = true})
    Menu.Combo.Wset:MenuElement({id = "glp", name = "Hectech GLP-800", value = true})
    Menu.Combo.Wset:MenuElement({id = "hex", name = "Hextech Gunblade", value = true})    
	Menu.Combo.Wset:MenuElement({id = "red", name = "Redemption", value = true})
    Menu.Combo.Wset:MenuElement({id = "botrk", name = "Blade Of The Ruined King", value = true})
    Menu.Combo.Wset:MenuElement({id = "solari", name = "Locket of the Iron Solari", value = true})
    Menu.Combo.Wset:MenuElement({id = "omen", name = "Randuin's Omen", value = true})	
    Menu.Combo.Wset:MenuElement({id = "yo", name = "Youmuus Ghostblade", value = true})
    Menu.Combo.Wset:MenuElement({id = "rg", name = "Righteous Glory", value = true})
    Menu.Combo.Wset:MenuElement({id = "twin", name = "Twin Shadows", value = true})			
	
	--Ult Settings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = " Extra Ultimate Settings"})
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

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		  
	Menu.Clear:MenuElement({id = "UseQM", name = "Use[Q] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredQ2", name = "Hitchance[Q2]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	
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
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 100, Range = 800, Speed = 1200, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
	}
	
	Q2Data =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 100, Range = 2550, Speed = 1200, Collision = false
	}

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 250, Range = 800, Speed = 2000, Collision = false
	}	
  	                                           
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end  
		
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 575, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 550, 1, Draw.Color(225, 225, 125, 10))
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		CastW()
		--CastR()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "Flee" then
			
	end	

	KillSteal()

	if Menu.RSet.UseR:Value() and Ready(_R) then
		ProcessSpell()
		for i, spell in pairs(DetectedSpells) do
			UseR(i, spell)
		end
	end	
end

function ProcessSpell()
	local ReadyForE = false
	if ReadyForE then
		castE()
	end	
	local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and spell and CCSpells[spell.name] and Ready(_R) then
		if myHero.pos:DistanceTo(unit.pos) > 3000 or not Menu.RSet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle then 
				if myHero.pos:DistanceTo(unit.pos) < 1350 and Ready(_E) then
					ReadyForE = Control.CastSpell(HK_R, unit.pos)
					table.remove(DetectedSpells, i)
				else	
					local castPos = Vector(unit) - (Vector(myHero) - Vector(unit)):Perpendicular():Normalized() * 350	
					Control.CastSpell(HK_R, castPos)
					table.remove(DetectedSpells, i)
				end	
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
	local ReadyForE = false
	if ReadyForE then
		castE()
	end	
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == math.huge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > Game.Timer() then
		local Col = VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
		if s.type == "circular" or s.type == "linear" then 
			if GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
				local t = s.speed ~= math.huge and CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay) or 0.29
				if t < 0.3 then
					if myHero.pos:DistanceTo(startPos) < 1350 and Ready(_E) then
						ReadyForE = Control.CastSpell(HK_R, startPos)
					else	
						local castPos = Vector(startPos) - (Vector(myHero) - Vector(startPos)):Perpendicular():Normalized() * 350	
						Control.CastSpell(HK_R, castPos)
					end				
				end				
			end
		end	
	else table.remove(DetectedSpells, i) end
end

function castE()
local target = GetTarget(2600)
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) < 800 and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
				Control.CastSpell(HK_E, pred.CastPosition)
			end	
		end
		
		if Ready(_Q) and myHero:GetSpellData(_Q).name == "ZoeQRecast" and myHero.pos:DistanceTo(target.pos) < 2550 then
			local pred = GetGamsteronPrediction(target, Q2Data, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ2:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end

		if Ready(_Q) and myHero:GetSpellData(_Q).name == "ZoeQ" and myHero.pos:DistanceTo(target.pos) < 800 then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end       		
	end
end


function KillSteal()	
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target) then
        
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 800 and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= target.health and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
        end
		
        if Menu.ks.UseE:Value() and Ready(_E) then
            local EDmg = getdmg("E", target, myHero)
			if EDmg >= target.health then
				
				if myHero.pos:DistanceTo(target.pos) < 1400 then
					local WallPos = LineSegment(Point(myHero.pos), Point(target.pos))
					if MapPosition:intersectsWall(WallPos) then	
						Control.CastSpell(HK_E, target.pos)
					end
				end
				
				if myHero.pos:DistanceTo(target.pos) < 800 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
						Control.CastSpell(HK_E, pred.CastPosition)
					end
				end	
			end	
        end
	end	
end	

function Combo()
local target = GetTarget(2600)
if target == nil then return end
	if IsValid(target) then
	
		if Menu.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) < 1400 then
				local WallPos = LineSegment(Point(myHero.pos), Point(target.pos))
				if MapPosition:intersectsWall(WallPos) then	
					Control.CastSpell(HK_E, target.pos)
				end
			end
			
			if myHero.pos:DistanceTo(target.pos) < 800 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			end
        end	
        
		if Menu.Combo.UseQ2:Value() and Ready(_Q) then
			if myHero:GetSpellData(_Q).name == "ZoeQRecast" and myHero.pos:DistanceTo(target.pos) < 2550 and myHero.pos:DistanceTo(target.pos) > 950 then
				local pred = GetGamsteronPrediction(target, Q2Data, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ2:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end
        end
		
		if Menu.Combo.UseQ:Value() and Ready(_Q) then
			if myHero:GetSpellData(_Q).name == "ZoeQ" and myHero.pos:DistanceTo(target.pos) < 800 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end
        end		

        if Menu.Combo.UseR:Value() and myHero.pos:DistanceTo(target.pos) < 950 and Ready(_R) and Ready(_Q) and myHero:GetSpellData(_Q).name == "ZoeQRecast" then
			local castpos = myHero.pos:Shortened(target.pos, 575)
			Control.SetCursorPos(castpos)
			Control.KeyDown(HK_R)
			Control.KeyUp(HK_R)
		end
		
		if IsImmobileTarget(target) and Ready(_R) and Ready(_Q) and Menu.Combo.UseR2:Value() and myHero:GetSpellData(_Q).name == "ZoeQ"  then
			local castpos = myHero.pos + (target.pos - myHero.pos):Normalized() * - 600
			if myHero.pos:DistanceTo(target.pos) < 600 then
			Control.SetCursorPos(castpos)
			Control.KeyDown(HK_R)
			Control.KeyUp(HK_R)				
			end		
		end
	end	
end

function CastW()
local target = GetTarget(2000)
if target == nil then return end
	if IsValid(target) then
		if Menu.Combo.Wset.UseW:Value() and Ready(_W) then
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
local target = GetTarget(1200)
if target == nil then return end
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
	if IsValid(target) and mana_ok then
        
        
		if Menu.Harass.UseQ2:Value() and Ready(_Q) then
			if myHero:GetSpellData(_Q).name == "ZoeQRecast" and myHero.pos:DistanceTo(target.pos) < 2550 and myHero.pos:DistanceTo(target.pos) > 950 then
				local pred = GetGamsteronPrediction(target, Q2Data, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ2:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end
        end
		
		if Menu.Harass.UseQ:Value() and Ready(_Q) then
			if myHero:GetSpellData(_Q).name == "ZoeQ" and myHero.pos:DistanceTo(target.pos) < 800 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end
        end	
	end
end	

function Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
			
            if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and Ready(_Q) then
                local count = GetMinionCount(275, minion)
				if count >= Menu.Clear.UseQM:Value() then
					Control.CastSpell(HK_Q, minion.pos)
				end
            end
        end
    end
end

function JungleClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100

            if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end
        end
    end
end

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
	["HecarimUlt"] = {charName = "Hecarim", displayName = "Onslaught of Shadows", slot = _R, type = "linear", speed = 1100, range = 1650, delay = 0.2, radius = 280, collision = false},	
	["IllaoiE"] = {charName = "Illaoi", displayName = "Test of Spirit", slot = _E, type = "linear", speed = 1900, range = 900, delay = 0.25, radius = 50, collision = true},	
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
	["YoneR"] = {charName = "Yone", displayName = "Yone Ult", slot = _R, type = "linear", speed = 1500, range = 900, delay = 0.5, radius = 120, collision = false},
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
	["TristanaR"] = {charName = "Tristana", slot = _R, type = "targeted", displayName = "Buster Shot", range = 669},
	["TeemoQ"] = {charName = "Teemo", slot = _Q, type = "targeted", displayName = "Blinding Dart", range = 680},	
	["VeigarPrimordialBurst"] = {charName = "Veigar", slot = _R, type = "targeted", displayName = "Primordial Burst", range = 650}	
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

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
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

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function CalculateCollisionTime(startPos, endPos, unitPos, startTime, speed, delay, origin)
	local pos = startPos:Extended(endPos, speed * (GameTimer() - delay - startTime))
	return GetDistance(unitPos, pos) / speed
end

function LoadScript() 
	DetectedMissiles = {}; DetectedSpells = {}; Target = nil; Timer = 0	
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.10"}})	
	
	Menu:MenuElement({type = MENU, id = "WSet", name = "AutoW Incomming Spells"})	
	Menu.WSet:MenuElement({id = "UseW", name = "AutoW Spells", value = true})	
	Menu.WSet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "Active", name = "Semi manual key [Q]", key = string.byte("T")})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseQ2", name = "[Q] priority Passive Vital", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "QUlt", name = "priority Q on Ult Vitals", value = true})	
	Menu.Combo.Ult:MenuElement({id = "Rself", name = "[R] Check Fiora Hp", value = true})
	Menu.Combo.Ult:MenuElement({id = "myHP", name = "[R] if Fiora Hp lower than", value = 40, min = 0, max = 100, identifier = "%"})
	Menu.Combo.Ult:MenuElement({name = " ", drop = {"--------------------------------------"}})	
	Menu.Combo.Ult:MenuElement({id = "RCount", name = "Use[R] if min Enemys in range ", value = true})
	Menu.Combo.Ult:MenuElement({id = "count", name = "min Enemys", value = 2, min = 1, max = 5, step = 1, identifier = "Enemy/s"})
	Menu.Combo.Ult:MenuElement({id = "range", name = "Check Enemys in", value = 600, min = 0, max = 2000, step = 10, identifier = "range"})	
	
	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})		
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseWQ", name = "[W] + [Q]", value = true})	
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	
	Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()
		for i, spell in pairs(CCSpells) do
			if not CCSpells[i] then return end
			for j, k in pairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not Menu.WSet.BlockList[i] then
					if not Menu.WSet.BlockList[i] then Menu.WSet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)
	
	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.75, Radius = 70, Range = 750, Speed = 3200, Collision = false
	}
	
	WspellData = {speed = 3200, range = 750, delay = 0.75, radius = 70, collision = {nil}, type = "linear"}	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 400, Speed = 2000, Collision = false
	}
	
	QspellData = {speed = 2000, range = 400, delay = 0.25, radius = 70, collision = {nil}, type = "linear"}	
  	                                           
	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 500, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 400, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 750, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

local WActiv = false
local UltSE,UltSW,UltNE,UltNW,Passive = false,false,false,false,false
local UltVitalsSE = {}
local UltVitalsSW = {}
local UltVitalsNE = {}
local UltVitalsNW = {}
local PassiveVital = {}
local LastScan = GameTimer()

function Tick()
	local Ulttarget = GetTarget(1000)
	RemoveWrongObjects()
	
	if HasBuff(myHero, "FioraW") then
		WActiv = true
		SetAttack(false)
		SetMovement(false)		
	else
		WActiv = false
		SetAttack(true)
		SetMovement(true)		
	end		

	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" and not WActiv then
		Combo()
		Ult()
		if Menu.Combo.Ult.QUlt:Value() then
			Ult2(Ulttarget)	
		end	
	elseif Mode == "Harass" and not WActiv then
		Harass()
	elseif Mode == "Clear" and not WActiv then
		Clear()
		JungleClear()			
	end	

	KillSteal()	

	if Menu.Combo.Active:Value() then
		SemiQ()
	end	

	if Menu.WSet.UseW:Value() and Ready(_W) then
		ProcessSpell()
		for i, spell in pairs(DetectedSpells) do
			UseW(i, spell)
		end
	end	
end	

function RemoveWrongObjects()
	for i, Vital in ipairs(PassiveVital) do
		if Vital then
			if Vital.name ~= "Fiora_Base_Passive_SE" 
			or Vital.name ~= "Fiora_Base_Passive_SE_Timeout"
			or Vital.name ~= "Fiora_Base_Passive_SW" 
			or Vital.name ~= "Fiora_Base_Passive_SW_Timeout"
			or Vital.name ~= "Fiora_Base_Passive_NE" 
			or Vital.name ~= "Fiora_Base_Passive_NE_Timeout"
			or Vital.name ~= "Fiora_Base_Passive_NW" 
			or Vital.name ~= "Fiora_Base_Passive_NW_Timeout" then
				TableRemove(PassiveVital, i) 
				Passive = false
			end
		end	
	end
	
	for i, Vital1 in ipairs(UltVitalsSE) do	
		if Vital1 then
			if Vital1.name ~= "Fiora_Base_R_Mark_SE_FioraOnly" 
			or Vital1.name ~= "Fiora_Base_R_SE_Timeout_FioraOnly" then
				TableRemove(UltVitalsSE, i)
				UltSE = false
			end
		end
	end	
	
	for i, Vital2 in ipairs(UltVitalsSW) do	
		if Vital2 then
			if Vital2.name ~= "Fiora_Base_R_Mark_SW_FioraOnly" 
			or Vital2.name ~= "Fiora_Base_R_SW_Timeout_FioraOnly" then
				TableRemove(UltVitalsSW, i)
				UltSW = false
			end
		end
	end

	for i, Vital3 in ipairs(UltVitalsNE) do	
		if Vital3 then
			if Vital3.name ~= "Fiora_Base_R_Mark_NE_FioraOnly" 
			or Vital3.name ~= "Fiora_Base_R_NE_Timeout_FioraOnly" then
				TableRemove(UltVitalsNE, i)
				UltNE = false
			end
		end
	end

	for i, Vital4 in ipairs(UltVitalsNW) do	
		if Vital4 then
			if Vital4.name ~= "Fiora_Base_R_Mark_NW_FioraOnly" 
			or Vital4.name ~= "Fiora_Base_R_NW_Timeout_FioraOnly" then
				TableRemove(UltVitalsNW, i)
				UltNW = false
			end
		end
	end		
end

function Ult2(unit)
	if unit and HasBuff(unit, "fiorarmark") then--and (not UltSE or not UltSW or not UltNE or not UltNW) then
		
		--DelayAction(function()
			if GameTimer() - LastScan <= 0.6 then
				for i = 1, Game.ObjectCount() do				
					local object = Game.Object(i)
					if unit.pos:DistanceTo(object.pos) <= 50 then				
						print(object.name)								
						if not UltSE and object.name == "Fiora_Base_R_Mark_SE_FioraOnly" or object.name == "Fiora_Base_R_SE_Timeout_FioraOnly" then
							UltSE = true
							TableInsert(UltVitalsSE, object)
						end	
						if not UltSW and object.name == "Fiora_Base_R_Mark_SW_FioraOnly" or object.name == "Fiora_Base_R_SW_Timeout_FioraOnly" then
							UltSW = true
							TableInsert(UltVitalsSW, object)
						end	
						if not UltNE and object.name == "Fiora_Base_R_Mark_NE_FioraOnly" or object.name == "Fiora_Base_R_NE_Timeout_FioraOnly" then
							UltNE = true
							TableInsert(UltVitalsNE, object)
						end	
						if not UltNW and object.name == "Fiora_Base_R_Mark_NW_FioraOnly" or object.name == "Fiora_Base_R_NW_Timeout_FioraOnly" then
							UltNW = true
							TableInsert(UltVitalsNW, object)
						end	
					end
				end
			end
		--end,0.1)
		LastScan = GameTimer()
	end

	for i, Vital1 in ipairs(UltVitalsSE) do
		if Vital1 and not Vital1.visible then TableRemove(UltVitalsSE, i) UltSE = false end
		
		if Vital1 and UltSE then
			local Pos = Vital1.pos
			local SEPos = Vector(Pos.x - 250 ,Pos.y, Pos.z)	
			if Ready(_Q) and not myHero.pathing.isDashing and SEPos:DistanceTo(myHero.pos) <= 500 then		
				--DrawCircle(SEPos, 50, 1, DrawColor(225, 220, 20, 60))
				Control.CastSpell(HK_Q, SEPos)
				TableRemove(UltVitalsSE, i)
				UltSE = false
			end
		end
	end
	
	for i, Vital2 in ipairs(UltVitalsSW) do
		if Vital2 and not Vital2.visible then TableRemove(UltVitalsSW, i) UltSW = false end				
		if Vital2 and UltSW then
			local Pos = Vital2.pos
			local SWPos = Vector(Pos.x ,Pos.y - 250, Pos.z)	
			if Ready(_Q) and not myHero.pathing.isDashing and SWPos:DistanceTo(myHero.pos) <= 500 then		
				--DrawCircle(SWPos, 50, 1, DrawColor(225, 0, 191, 255))
				Control.CastSpell(HK_Q, SWPos)
				TableRemove(UltVitalsSW, i)
				UltSW = false
			end	
		end
	end	
	
	for i, Vital3 in ipairs(UltVitalsNE) do
		if Vital3 and not Vital3.visible then TableRemove(UltVitalsNE, i) UltNE = false end						
		if Vital3 and UltNE then
			local Pos = Vital3.pos
			local NEPos = Vector(Pos.x ,Pos.y + 250, Pos.z)	
			if Ready(_Q) and not myHero.pathing.isDashing and NEPos:DistanceTo(myHero.pos) <= 500 then		
				--DrawCircle(NEPos, 50, 1, DrawColor(225, 50, 205, 50))
				Control.CastSpell(HK_Q, NEPos)
				TableRemove(UltVitalsNE, i)
				UltNE = false
			end
		end
	end
	
	for i, Vital4 in ipairs(UltVitalsNW) do
		if Vital4 and not Vital4.visible then TableRemove(UltVitalsNW, i) UltNW = false end							
		if Vital4 and UltNW then
			local Pos = Vital4.pos
			local NWPos = Vector(Pos.x + 250,Pos.y, Pos.z)	
			if Ready(_Q) and not myHero.pathing.isDashing and NWPos:DistanceTo(myHero.pos) <= 500 then		
				--DrawCircle(NWPos, 50, 1, DrawColor(225, 255, 255, 255))
				Control.CastSpell(HK_Q, NWPos)
				TableRemove(UltVitalsNW, i)
				UltNW = false
			end	
		end
	end
end

function ProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and unit.isEnemy and spell and CCSpells[spell.name] and Ready(_W) then
		if myHero.pos:DistanceTo(unit.pos) > 3000 or not Menu.WSet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle then 
				Control.CastSpell(HK_W, unit.pos)
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
				if t < 0.4 then
					Control.CastSpell(HK_W, s.startPos)
				end				
			end
		end	
	else TableRemove(DetectedSpells, i) end
end	

function KillSteal()	
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
	local QDmg = getdmg("Q", target, myHero)
	local WDmg = getdmg("W", target, myHero)	
		
		if Menu.ks.UseWQ:Value() and myHero.pos:DistanceTo(target.pos) < 750 and Ready(_W) and Ready(_Q) then
			if (QDmg+WDmg) > target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						Control.CastSpell(HK_W, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						Control.CastSpell(HK_W, pred.CastPos)
					end
				else
					local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.75, Radius = 70, Range = 750, Speed = 3200, Collision = false})
					WPrediction:GetPrediction(target, myHero)
					if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
						Control.CastSpell(HK_W, WPrediction.CastPosition)
					end					
				end
			end	
        end
		
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 400 and Ready(_Q) then
			if QDmg > target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end	
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 400, Speed = 2000, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end					
				end
			end	
        end		
		
        if Menu.ks.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 750 and Ready(_W) then
			if WDmg > target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						Control.CastSpell(HK_W, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						Control.CastSpell(HK_W, pred.CastPos)
					end
				else
					local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.75, Radius = 70, Range = 750, Speed = 3200, Collision = false})
					WPrediction:GetPrediction(target, myHero)
					if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
						Control.CastSpell(HK_W, WPrediction.CastPosition)
					end					
				end
			end	
        end
	end	
end
	
function Ult()
local target = GetTarget(600)
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < 500 then
        
		if Menu.Combo.Ult.Rself:Value() and myHero.health/myHero.maxHealth <= Menu.Combo.Ult.myHP:Value() / 100 and Ready(_R) then
			Control.CastSpell(HK_R, target)
        end
       
		if Menu.Combo.Ult.RCount:Value() and Ready(_R) then
			local count = GetEnemyCount(Menu.Combo.Ult.range:Value(), myHero)
			if count >= Menu.Combo.Ult.count:Value() then
				Control.CastSpell(HK_R, target)
			end	
        end
	end
end

function SemiQ()
local target = GetTarget(500)
if target == nil then return end
	if IsValid(target) then
        
		if myHero.pos:DistanceTo(target.pos) < 400 and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end	
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 400, Speed = 2000, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end					
			end
        end
	end
end	

function Combo()
local target = GetTarget(700)
if target == nil then return end
	if IsValid(target) then
        
		if (Menu.Combo.Ult.QUlt:Value() and not HasBuff(target, "fiorarmark")) or (not Menu.Combo.Ult.QUlt:Value()) then	
			if Menu.Combo.UseQ2:Value() then
				if Ready(_Q) then
					PassiveCheck(target)
					for i, Vital in ipairs(PassiveVital) do
						if Vital and not Vital.visible then TableRemove(PassiveVital, i) Passive = false end
					
						if Vital and Passive then
							local Pos = Vital.pos
							if Vital.name == "Fiora_Base_Passive_SE" or Vital.name == "Fiora_Base_Passive_SE_Timeout" then
								local SEPos = Vector(Pos.x - 250 ,Pos.y, Pos.z)	
								if not myHero.pathing.isDashing and SEPos:DistanceTo(myHero.pos) <= 500 then		
									--DrawCircle(SEPos, 100, 1, DrawColor(225, 220, 20, 60))
									Control.CastSpell(HK_Q, SEPos)
									TableRemove(PassiveVital, i)
									Passive = false
								end
							end	
							if Vital.name == "Fiora_Base_Passive_SW" or Vital.name == "Fiora_Base_Passive_SW_Timeout" then
								local SWPos = Vector(Pos.x ,Pos.y - 250, Pos.z)	
								if not myHero.pathing.isDashing and SWPos:DistanceTo(myHero.pos) <= 500 then		
									--DrawCircle(SWPos, 100, 1, DrawColor(225, 0, 191, 255))
									Control.CastSpell(HK_Q, SWPos)
									TableRemove(PassiveVital, i)
									Passive = false
								end
							end
							if Vital.name == "Fiora_Base_Passive_NE" or Vital.name == "Fiora_Base_Passive_NE_Timeout" then
								local NEPos = Vector(Pos.x ,Pos.y + 250, Pos.z)	
								if not myHero.pathing.isDashing and NEPos:DistanceTo(myHero.pos) <= 500 then		
									--DrawCircle(NEPos, 100, 1, DrawColor(225, 50, 205, 50))
									Control.CastSpell(HK_Q, NEPos)
									TableRemove(PassiveVital, i)
									Passive = false
								end
							end
							if Vital.name == "Fiora_Base_Passive_NW" or Vital.name == "Fiora_Base_Passive_NW_Timeout" then
								local NWPos = Vector(Pos.x + 250,Pos.y, Pos.z)	
								if not myHero.pathing.isDashing and NWPos:DistanceTo(myHero.pos) <= 500 then		
									--DrawCircle(NWPos, 100, 1, DrawColor(225, 255, 255, 255))
									Control.CastSpell(HK_Q, NWPos)
									TableRemove(PassiveVital, i)
									Passive = false
								end							
							end
							
						else
							if Menu.Combo.UseQ:Value() or Menu.Combo.Active:Value() and myHero.pos:DistanceTo(target.pos) < 400 and Ready(_Q) then
								if Menu.Pred.Change:Value() == 1 then
									local pred = GetGamsteronPrediction(target, QData, myHero)
									if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
										Control.CastSpell(HK_Q, pred.CastPosition)
									end
								elseif Menu.Pred.Change:Value() == 2 then
									local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
									if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
										Control.CastSpell(HK_Q, pred.CastPos)
									end	
								else
									local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 400, Speed = 2000, Collision = false})
									QPrediction:GetPrediction(target, myHero)
									if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
										Control.CastSpell(HK_Q, QPrediction.CastPosition)
									end					
								end	
							end	
						end
					end					
				end
			
			else
			
				if Menu.Combo.UseQ:Value() or Menu.Combo.Active:Value() and myHero.pos:DistanceTo(target.pos) < 400 and Ready(_Q) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end	
					else
						local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 400, Speed = 2000, Collision = false})
						QPrediction:GetPrediction(target, myHero)
						if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end					
					end
				end	
			end
		end	
       
		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 250 and Ready(_E) then
			Control.CastSpell(HK_E)
			DelayAction(function()
				if _G.SDK and _G.SDK.Orbwalker then
					_G.SDK.Orbwalker:__OnAutoAttackReset()
				elseif _G.PremiumOrbwalker then
					_G.PremiumOrbwalker:ResetAutoAttack()
				end				
			end, 0.05)			
        end
	end
end

function PassiveCheck(unit)
	if unit and HasBuff(unit, "fiorapassivemanager") and not Passive then 
		for i = 1, Game.ObjectCount() do				
			local object = Game.Object(i)
			if unit.pos:DistanceTo(object.pos) <= 50 then				
				print(object.name)								
				if object.name == "Fiora_Base_Passive_SE" or object.name == "Fiora_Base_Passive_SE_Timeout" then
					print("Vital SE Found")
					Passive = true
					TableInsert(PassiveVital, object)
					return
				end	
				if object.name == "Fiora_Base_Passive_SW" or object.name == "Fiora_Base_Passive_SW_Timeout" then
					print("Vital SW Found")
					Passive = true
					TableInsert(PassiveVital, object)
					return
				end	
				if object.name == "Fiora_Base_Passive_NE" or object.name == "Fiora_Base_Passive_NE_Timeout" then
					print("Vital NE Found")
					Passive = true
					TableInsert(PassiveVital, object)
					return
				end	
				if object.name == "Fiora_Base_Passive_NW" or object.name == "Fiora_Base_Passive_NW_Timeout" then
					print("Vital NW Found")
					Passive = true
					TableInsert(PassiveVital, object)
					return
				end		
			end
		end
	end
end

function Harass()
local target = GetTarget(250)
if target == nil then return end
	if IsValid(target) then
       
		if Menu.Harass.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E)
			DelayAction(function()
				if _G.SDK and _G.SDK.Orbwalker then
					_G.SDK.Orbwalker:__OnAutoAttackReset()
				elseif _G.PremiumOrbwalker then
					_G.PremiumOrbwalker:ResetAutoAttack()
				end				
			end, 0.05)
        end
	end
end

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) < 500 and minion.team == TEAM_ENEMY and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 400 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 250 and Ready(_E) then
				Control.CastSpell(HK_E)
				DelayAction(function()
					if _G.SDK and _G.SDK.Orbwalker then
						_G.SDK.Orbwalker:__OnAutoAttackReset()
					elseif _G.PremiumOrbwalker then
						_G.PremiumOrbwalker:ResetAutoAttack()
					end				
				end, 0.05)				
            end
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) < 500 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 400 and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 250 and Ready(_E) then	
				Control.CastSpell(HK_E)
				DelayAction(function()
					if _G.SDK and _G.SDK.Orbwalker then
						_G.SDK.Orbwalker:__OnAutoAttackReset()
					elseif _G.PremiumOrbwalker then
						_G.PremiumOrbwalker:ResetAutoAttack()
					end				
				end, 0.05)				
            end
        end
    end
end

local CCSpells = {
	["AatroxW"] = {charName = "Aatrox", displayName = "Infernal Chains", slot = _W, origin = "spell", type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 80, collision = true},
	["AhriSeduce"] = {charName = "Ahri", displayName = "Seduce", slot = _E, origin = "spell", type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, collision = true},
	["AhriSeduceMissile"] = {charName = "Ahri", displayName = "Seduce [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, collision = true},
	["AkaliR"] = {charName = "Akali", displayName = "Perfect Execution [First]", slot = _R, origin = "spell", type = "linear", speed = 1800, range = 525, delay = 0, radius = 65, collision = false},
	["Pulverize"] = {charName = "Alistar", displayName = "Pulverize", slot = _Q, origin = "spell", type = "circular", speed = math.huge, range = 0, delay = 0.25, radius = 365, collision = false},
	["BandageToss"] = {charName = "Amumu", displayName = "Bandage Toss", slot = _Q, origin = "spell", type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, collision = true},
	["SadMummyBandageToss"] = {charName = "Amumu", displayName = "Bandage Toss [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, collision = true},
	["CurseoftheSadMummy"] = {charName = "Amumu", displayName = "Curse of the Sad Mummy", slot = _R, origin = "spell", type = "circular", speed = math.huge, range = 0, delay = 0.25, radius = 550, collision = false},
	["FlashFrostSpell"] = {charName = "Anivia", displayName = "Flash Frost",missileName = "FlashFrostSpell", slot = _Q, origin = "both", type = "linear", speed = 850, range = 1100, delay = 0.25, radius = 110, collision = false},
	["EnchantedCrystalArrow"] = {charName = "Ashe", displayName = "Enchanted Crystal Arrow", slot = _R, origin = "both", type = "linear", speed = 1600, range = 25000, delay = 0.25, radius = 130, collision = false},
	["AurelionSolQ"] = {charName = "AurelionSol", displayName = "Starsurge", slot = _Q, origin = "spell", type = "linear", speed = 850, range = 25000, delay = 0, radius = 110, collision = false},
	["AurelionSolQMissile"] = {charName = "AurelionSol", displayName = "Starsurge [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 850, range = 25000, delay = 0, radius = 110, collision = false},
	["AzirR"] = {charName = "Azir", displayName = "Emperor's Divide", slot = _R, origin = "spell", type = "linear", speed = 1400, range = 500, delay = 0.3, radius = 250, collision = false},
	["BardQ"] = {charName = "Bard", displayName = "Cosmic Binding", slot = _Q, origin = "spell", type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, collision = true},
	["BardQMissile"] = {charName = "Bard", displayName = "Cosmic Binding [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, collision = true},
	["BardR"] = {charName = "Bard", displayName = "Tempered Fate", slot = _R, origin = "spell", type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, collision = false},
	["BardRMissile"] = {charName = "Bard", displayName = "Tempered Fate [Missile]", slot = _R, origin = "missile", type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, collision = false},
	["RocketGrab"] = {charName = "Blitzcrank", displayName = "Rocket Grab", slot = _Q, origin = "spell", type = "linear", speed = 1800, range = 1150, delay = 0.25, radius = 140, collision = true},
	["RocketGrabMissile"] = {charName = "Blitzcrank", displayName = "Rocket Grab [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1800, range = 1150, delay = 0.25, radius = 140, collision = true},
	["BraumQ"] = {charName = "Braum", displayName = "Winter's Bite", slot = _Q, origin = "spell", type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = true},
	["BraumQMissile"] = {charName = "Braum", displayName = "Winter's Bite [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = true},
	["BraumR"] = {charName = "Braum", displayName = "Glacial Fissure", slot = _R, origin = "spell", type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, collision = false},
	["BraumRMissile"] = {charName = "Braum", displayName = "Glacial Fissure [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, collision = false},
	["CaitlynYordleTrap"] = {charName = "Caitlyn", displayName = "Yordle Trap", slot = _W, origin = "spell", type = "circular", speed = math.huge, range = 800, delay = 0.25, radius = 75, collision = false},
	["CaitlynEntrapment"] = {charName = "Caitlyn", displayName = "Entrapment", slot = _E, origin = "spell", type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, collision = true},
	["CassiopeiaW"] = {charName = "Cassiopeia", displayName = "Miasma", slot = _W, origin = "spell", type = "circular", speed = 2500, range = 800, delay = 0.75, radius = 160, collision = false},
	["Rupture"] = {charName = "Chogath", displayName = "Rupture", slot = _Q, origin = "spell", type = "circular", speed = math.huge, range = 950, delay = 1.2, radius = 250, collision = false},
	["InfectedCleaverMissile"] = {charName = "DrMundo", displayName = "Infected Cleaver", slot = _Q, origin = "both", type = "linear", speed = 2000, range = 975, delay = 0.25, radius = 60, collision = true},
	["DravenDoubleShot"] = {charName = "Draven", displayName = "Double Shot", slot = _E, origin = "spell", type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, collision = false},
	["DravenDoubleShotMissile"] = {charName = "Draven", displayName = "Double Shot [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, collision = false},
	["EkkoQ"] = {charName = "Ekko", displayName = "Timewinder", slot = _Q, origin = "spell", type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, collision = false},
	["EkkoQMis"] = {charName = "Ekko", displayName = "Timewinder [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, collision = false},
	["EkkoW"] = {charName = "Ekko", displayName = "Parallel Convergence", slot = _W, origin = "spell", type = "circular", speed = math.huge, range = 1600, delay = 3.35, radius = 400, collision = false},
	["EkkoWMis"] = {charName = "Ekko", displayName = "Parallel Convergence [Missile]", slot = _W, origin = "missile", type = "circular", speed = math.huge, range = 1600, delay = 3.35, radius = 400, collision = false},
	["EliseHumanE"] = {charName = "Elise", displayName = "Cocoon", slot = _E, origin = "both", type = "linear", speed = 1600, range = 1075, delay = 0.25, radius = 55, collision = true},
	["FizzR"] = {charName = "Fizz", displayName = "Chum the Waters", slot = _R, origin = "spell", type = "linear", speed = 1300, range = 1300, delay = 0.25, radius = 150, collision = false},
	["FizzRMissile"] = {charName = "Fizz", displayName = "Chum the Waters [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1300, range = 1300, delay = 0.25, radius = 150, collision = false},
	["GalioE"] = {charName = "Galio", displayName = "Justice Punch", slot = _E, origin = "spell", type = "linear", speed = 2300, range = 650, delay = 0.4, radius = 160, collision = false},
	["GnarQMissile"] = {charName = "Gnar", displayName = "Boomerang Throw", slot = _Q, origin = "both", type = "linear", speed = 2500, range = 1125, delay = 0.25, radius = 55, collision = false},
	["GnarBigQMissile"] = {charName = "Gnar", displayName = "Boulder Toss", slot = _Q, origin = "both", type = "linear", speed = 2100, range = 1125, delay = 0.5, radius = 90, collision = true},
	["GnarBigW"] = {charName = "Gnar", displayName = "Wallop", slot = _W, origin = "spell", type = "linear", speed = math.huge, range = 575, delay = 0.6, radius = 100, collision = false},
	["GnarR"] = {charName = "Gnar", displayName = "GNAR!", slot = _R, origin = "spell", type = "circular", speed = math.huge, range = 0, delay = 0.25, radius = 475, collision = false},
	["GragasQ"] = {charName = "Gragas", displayName = "Barrel Roll", slot = _Q, origin = "spell", type = "circular", speed = 1000, range = 850, delay = 0.25, radius = 275, collision = false},
	["GragasQMissile"] = {charName = "Gragas", displayName = "Barrel Roll [Missile]", slot = _Q, origin = "missile", type = "circular", speed = 1000, range = 850, delay = 0.25, radius = 275, collision = false},
	["GragasR"] = {charName = "Gragas", displayName = "Explosive Cask", slot = _R, origin = "spell", type = "circular", speed = 1800, range = 1000, delay = 0.25, radius = 400, collision = false},
	["GragasRBoom"] = {charName = "Gragas", displayName = "Explosive Cask [Missile]", slot = _R, origin = "missile", type = "circular", speed = 1800, range = 1000, delay = 0.25, radius = 400, collision = false},
	["GravesSmokeGrenade"] = {charName = "Graves", displayName = "Smoke Grenade", slot = _W, origin = "spell", type = "circular", speed = 1500, range = 950, delay = 0.15, radius = 250, collision = false},
	["GravesSmokeGrenadeBoom"] = {charName = "Graves", displayName = "Smoke Grenade [Missile]", slot = _W, origin = "missile", type = "circular", speed = 1500, range = 950, delay = 0.15, radius = 250, collision = false},
	["HecarimUltMissile"] = {charName = "Hecarim", displayName = "Onslaught of Shadows", slot = _R, origin = "missile", type = "linear", speed = 1100, range = 1650, delay = 0.2, radius = 280, collision = false},
	["HeimerdingerE"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = _E, origin = "spell", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerESpell"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade [Missile]", slot = _E, origin = "missile", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerEUlt"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade", slot = _E, origin = "spell", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["HeimerdingerESpell_ult"] = {charName = "Heimerdinger", displayName = "CH-2 Electron Storm Grenade [Missile]", slot = _E, origin = "missile", type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, collision = false},
	["IreliaW2"] = {charName = "Illaoi", displayName = "Defiant Dance", slot = _W, origin = "spell", type = "linear", speed = math.huge, range = 775, delay = 0.25, radius = 120, collision = false},
	["IreliaR"] = {charName = "Illaoi", displayName = "Vanguard's Edge", slot = _R, origin = "both", type = "linear", speed = 2000, range = 950, delay = 0.4, radius = 160, collision = false},
	["IvernQ"] = {charName = "Illaoi", displayName = "Rootcaller", slot = _Q, origin = "both", type = "linear", speed = 1300, range = 1075, delay = 0.25, radius = 80, collision = true},
	["HowlingGaleSpell"] = {charName = "Janna", displayName = "Howling Gale [1]", slot = _Q, origin = "missile", type = "linear", speed = 667, range = 995, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell2"] = {charName = "Janna", displayName = "Howling Gale [2]", slot = _Q, origin = "missile", type = "linear", speed = 700, range = 1045, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell3"] = {charName = "Janna", displayName = "Howling Gale [3]", slot = _Q, origin = "missile", type = "linear", speed = 733, range = 1095, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell4"] = {charName = "Janna", displayName = "Howling Gale [4]", slot = _Q, origin = "missile", type = "linear", speed = 767, range = 1145, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell5"] = {charName = "Janna", displayName = "Howling Gale [5]", slot = _Q, origin = "missile", type = "linear", speed = 800, range = 1195, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell6"] = {charName = "Janna", displayName = "Howling Gale [6]", slot = _Q, origin = "missile", type = "linear", speed = 833, range = 1245, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell7"] = {charName = "Janna", displayName = "Howling Gale [7]", slot = _Q, origin = "missile", type = "linear", speed = 867, range = 1295, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell8"] = {charName = "Janna", displayName = "Howling Gale [8]", slot = _Q, origin = "missile", type = "linear", speed = 900, range = 1345, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell9"] = {charName = "Janna", displayName = "Howling Gale [9]", slot = _Q, origin = "missile", type = "linear", speed = 933, range = 1395, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell10"] = {charName = "Janna", displayName = "Howling Gale [10]", slot = _Q, origin = "missile", type = "linear", speed = 967, range = 1445, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell11"] = {charName = "Janna", displayName = "Howling Gale [11]", slot = _Q, origin = "missile", type = "linear", speed = 1000, range = 1495, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell12"] = {charName = "Janna", displayName = "Howling Gale [12]", slot = _Q, origin = "missile", type = "linear", speed = 1033, range = 1545, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell13"] = {charName = "Janna", displayName = "Howling Gale [13]", slot = _Q, origin = "missile", type = "linear", speed = 1067, range = 1595, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell14"] = {charName = "Janna", displayName = "Howling Gale [14]", slot = _Q, origin = "missile", type = "linear", speed = 1100, range = 1645, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell15"] = {charName = "Janna", displayName = "Howling Gale [15]", slot = _Q, origin = "missile", type = "linear", speed = 1133, range = 1695, delay = 0, radius = 120, collision = false},
	["HowlingGaleSpell16"] = {charName = "Janna", displayName = "Howling Gale [16]", slot = _Q, origin = "missile", type = "linear", speed = 1167, range = 1745, delay = 0, radius = 120, collision = false},
	["JarvanIVDragonStrike"] = {charName = "JarvanIV", displayName = "Dragon Strike", slot = _Q, origin = "spell", type = "linear", speed = math.huge, range = 770, delay = 0.4, radius = 70, collision = false},
	["JhinW"] = {charName = "Jhin", displayName = "Deadly Flourish", slot = _W, origin = "spell", type = "linear", speed = 5000, range = 2550, delay = 0.75, radius = 40, collision = false},
	["JhinE"] = {charName = "Jhin", displayName = "Captive Audience", slot = _E, origin = "spell", type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, collision = false},
	["JhinETrap"] = {charName = "Jhin", displayName = "Captive Audience [Missile]", slot = _E, origin = "missile", type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, collision = false},
	["JhinRShotMis"] = {charName = "Jhin", displayName = "Curtain Call [Missile]", slot = _R, origin = "missile", type = "linear", speed = 5000, range = 3500, delay = 0.25, radius = 80, collision = false},
	["JinxWMissile"] = {charName = "Jinx", displayName = "Zap!", slot = _W, origin = "both", type = "linear", speed = 3300, range = 1450, delay = 0.6, radius = 60, collision = true},
	["JinxEHit"] = {charName = "Jinx", displayName = "Flame Chompers! [Missile]", slot = _E, origin = "missile", type = "circular", speed = 1750, range = 900, delay = 0, radius = 120, collision = false},
	["KarmaQ"] = {charName = "Karma", displayName = "Inner Flame", slot = _Q, origin = "spell", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 60, collision = true},
	["KarmaQMissile"] = {charName = "Karma", displayName = "Inner Flame [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 60, collision = true},
	["KarmaQMantra"] = {charName = "Karma", displayName = "Inner Flame [Mantra]", slot = _Q, origin = "linear", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 80, collision = true},
	["KarmaQMissileMantra"] = {charName = "Karma", displayName = "Inner Flame [Mantra, Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 80, collision = true},
	["KaynW"] = {charName = "Kayn", displayName = "Blade's Reach", slot = _W, origin = "spell", type = "linear", speed = math.huge, range = 700, delay = 0.55, radius = 90, collision = false},
	["KhazixWLong"] = {charName = "Khazix", displayName = "Void Spike [Threeway]", slot = _W, origin = "spell", type = "threeway", speed = 1700, range = 1000, delay = 0.25, radius = 70,angle = 23, collision = true},
	["KledQ"] = {charName = "Kled", displayName = "Beartrap on a Rope", slot = _Q, origin = "spell", type = "linear", speed = 1600, range = 800, delay = 0.25, radius = 45, collision = true},
	["KledQMissile"] = {charName = "Kled", displayName = "Beartrap on a Rope [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1600, range = 800, delay = 0.25, radius = 45, collision = true},
	["KogMawVoidOozeMissile"] = {charName = "KogMaw", displayName = "Void Ooze", slot = _E, origin = "both", type = "linear", speed = 1400, range = 1360, delay = 0.25, radius = 120, collision = false},
	["LeblancE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Standard]", slot = _E, origin = "spell", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancEMissile"] = {charName = "Leblanc", displayName = "Ethereal Chains [Standard, Missile]", slot = _E, origin = "missile", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancRE"] = {charName = "Leblanc", displayName = "Ethereal Chains [Ultimate]", slot = _E, origin = "spell", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeblancREMissile"] = {charName = "Leblanc", displayName = "Ethereal Chains [Ultimate, Missile]", slot = _E, origin = "missile", type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, collision = true},
	["LeonaZenithBlade"] = {charName = "Leona", displayName = "Zenith Blade", slot = _E, origin = "spell", type = "linear", speed = 2000, range = 875, delay = 0.25, radius = 70, collision = false},
	["LeonaSolarFlare"] = {charName = "Leona", displayName = "Solar Flare", slot = _R, origin = "spell", type = "circular", speed = math.huge, range = 1200, delay = 0.85, radius = 300, collision = false},
	["LissandraQMissile"] = {charName = "Lissandra", displayName = "Ice Shard", slot = _Q, origin = "both", type = "linear", speed = 2200, range = 750, delay = 0.25, radius = 75, collision = false},
	["LuluQ"] = {charName = "Lulu", displayName = "Glitterlance", slot = _Q, origin = "spell", type = "linear", speed = 1450, range = 925, delay = 0.25, radius = 60, collision = false},
	["LuluQMissile"] = {charName = "Lulu", displayName = "Glitterlance [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1450, range = 925, delay = 0.25, radius = 60, collision = false},
	["LuxLightBinding"] = {charName = "Lux", displayName = "Light Binding", slot = _Q, origin = "spell", type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 50, collision = true},
	["LuxLightBindingDummy"] = {charName = "Lux", displayName = "Light Binding [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 50, collision = true},
	["LuxLightStrikeKugel"] = {charName = "Lux", displayName = "Light Strike Kugel", slot = _E, origin = "both", type = "circular", speed = 1200, range = 1100, delay = 0.25, radius = 300, collision = true},
	["Landslide"] = {charName = "Malphite", displayName = "Ground Slam", slot = _E, origin = "spell", type = "circular", speed = math.huge, range = 0, delay = 0.242, radius = 400, collision = false},
	["MalzaharQ"] = {charName = "Malzahar", displayName = "Call of the Void", slot = _Q, origin = "spell", type = "rectangular", speed = 1600, range = 900, delay = 0.5, radius = 400, radius2 = 100, collision = false},
	["MalzaharQMissile"] = {charName = "Malzahar", displayName = "Call of the Void [Missile]", slot = _Q, origin = "missile", type = "rectangular", speed = 1600, range = 900, delay = 0.5, radius = 400, radius2 = 100, collision = false},
	["MaokaiQ"] = {charName = "Maokai", displayName = "Bramble Smash", slot = _Q, origin = "spell", type = "linear", speed = 1600, range = 600, delay = 0.375, radius = 110, collision = false},
	["MaokaiQMissile"] = {charName = "Maokai", displayName = "Bramble Smash [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1600, range = 600, delay = 0.375, radius = 110, collision = false},
	["DarkBindingMissile"] = {charName = "Morgana", displayName = "Dark Binding", slot = _Q, origin = "both", type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 70, collision = true},
	["NamiQ"] = {charName = "Nami", displayName = "Aqua Prison", slot = _Q, origin = "spell", type = "circular", speed = math.huge, range = 875, delay = 1, radius = 180, collision = false},
	["NamiRMissile"] = {charName = "Nami", displayName = "Tidal Wave", slot = _R, origin = "both", type = "linear", speed = 850, range = 2750, delay = 0.5, radius = 250, collision = false},
	["NautilusAnchorDragMissile"] = {charName = "Nautilus", displayName = "Dredge Line", slot = _Q, origin = "both", type = "linear", speed = 2000, range = 925, delay = 0.25, radius = 90, collision = true},
	["NeekoQ"] = {charName = "Neeko", displayName = "Blooming Burst", slot = _Q, origin = "both", type = "circular", speed = 1500, range = 800, delay = 0.25, radius = 200, collision = false},
	["NeekoE"] = {charName = "Neeko", displayName = "Tangle-Barbs", slot = _E, origin = "both", type = "linear", speed = 1400, range = 1000, delay = 0.25, radius = 65, collision = false},
	["NunuR"] = {charName = "Nunu", displayName = "Absolute Zero", slot = _R, origin = "spell", type = "circular", speed = math.huge, range = 0, delay = 3, radius = 650, collision = false},
	["OlafAxeThrowCast"] = {charName = "Olaf", displayName = "Undertow", slot = _Q, origin = "spell", type = "linear", speed = 1600, range = 1000, delay = 0.25, radius = 90, collision = false},
	["OlafAxeThrow"] = {charName = "Olaf", displayName = "Undertow [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1600, range = 1000, delay = 0.25, radius = 90, collision = false},
	["OrnnQ"] = {charName = "Ornn", displayName = "Volcanic Rupture", slot = _Q, origin = "spell", type = "linear", speed = 1800, range = 800, delay = 0.3, radius = 65, collision = false},
	-- OrnnQMissile
	["OrnnE"] = {charName = "Ornn", displayName = "Searing Charge", slot = _E, origin = "spell", type = "linear", speed = 1800, range = 800, delay = 0.35, radius = 150, collision = false},
	["OrnnRCharge"] = {charName = "Ornn", displayName = "Call of the Forge God", slot = _R, origin = "spell", type = "linear", speed = 1650, range = 2500, delay = 0.5, radius = 200, collision = false},
	-- OrnnRMissile
	["PoppyQSpell"] = {charName = "Poppy", displayName = "Hammer Shock", slot = _Q, origin = "spell", type = "linear", speed = math.huge, range = 430, delay = 0.332, radius = 100, collision = false},
	["PoppyRSpell"] = {charName = "Poppy", displayName = "Keeper's Verdict", slot = _R, origin = "spell", type = "linear", speed = 2000, range = 1200, delay = 0.33, radius = 100, collision = false},
	["PoppyRSpellMissile"] = {charName = "Poppy", displayName = "Keeper's Verdict [Missile]", slot = _R, origin = "missile", type = "linear", speed = 2000, range = 1200, delay = 0.33, radius = 100, collision = false},
	["PykeQMelee"] = {charName = "Pyke", displayName = "Bone Skewer [Melee]", slot = _Q, origin = "spell", type = "linear", speed = math.huge, range = 400, delay = 0.25, radius = 70, collision = false},
	["PykeQRange"] = {charName = "Pyke", displayName = "Bone Skewer [Range]", slot = _Q, origin = "both", type = "linear", speed = 2000, range = 1100, delay = 0.2, radius = 70, collision = true},
	["PykeE"] = {charName = "Pyke", displayName = "Phantom Undertow", slot = _E, origin = "spell", type = "linear", speed = 3000, range = 25000, delay = 0, radius = 110, collision = false},
	["PykeEMissile"] = {charName = "Pyke", displayName = "Phantom Undertow [Missile]", slot = _E, origin = "missile", type = "linear", speed = 3000, range = 25000, delay = 0, radius = 110, collision = false},
	["RakanW"] = {charName = "Rakan", displayName = "Grand Entrance", slot = _W, origin = "spell", type = "circular", speed = math.huge, range = 650, delay = 0.7, radius = 265, collision = false},
	["RengarE"] = {charName = "Rengar", displayName = "Bola Strike", slot = _E, origin = "spell", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = true},
	["RengarEMis"] = {charName = "Rengar", displayName = "Bola Strike [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = true},
	["RumbleGrenade"] = {charName = "Rumble", displayName = "Electro Harpoon", slot = _E, origin = "spell", type = "linear", speed = 2000, range = 850, delay = 0.25, radius = 60, collision = true},
	["RumbleGrenadeMissile"] = {charName = "Rumble", displayName = "Electro Harpoon [Missile]", slot = _E, origin = "missile", type = "linear", speed = 2000, range = 850, delay = 0.25, radius = 60, collision = true},
	["SejuaniR"] = {charName = "Sejuani", displayName = "Glacial Prison", slot = _R, origin = "spell", type = "linear", speed = 1600, range = 1300, delay = 0.25, radius = 120, collision = false},
	["SejuaniRMissile"] = {charName = "Sejuani", displayName = "Glacial Prison [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1600, range = 1300, delay = 0.25, radius = 120, collision = false},
	["ShyvanaTransformLeap"] = {charName = "Shyvana", displayName = "Transform Leap", slot = _R, origin = "spell", type = "linear", speed = 700, range = 850, delay = 0.25, radius = 150, collision = false},
	["SionQ"] = {charName = "Sion", displayName = "Decimating Smash", slot = _Q, origin = "", type = "linear", speed = math.huge, range = 750, delay = 2, radius = 150, collision = false},
	["SionE"] = {charName = "Sion", displayName = "Roar of the Slayer", slot = _E, origin = "spell", type = "linear", speed = 1800, range = 800, delay = 0.25, radius = 80, collision = false},
	["SionEMissile"] = {charName = "Sion", displayName = "Roar of the Slayer [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1800, range = 800, delay = 0.25, radius = 80, collision = false},
	["SkarnerFractureMissile"] = {charName = "Skarner", displayName = "Fracture", slot = _E, origin = "both", type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = false},
	["SonaR"] = {charName = "Sona", displayName = "Crescendo", slot = _R, origin = "spell", type = "linear", speed = 2400, range = 1000, delay = 0.25, radius = 140, collision = false},
	["SonaRMissile"] = {charName = "Sona", displayName = "Crescendo [Missile]", slot = _R, origin = "missile", type = "linear", speed = 2400, range = 1000, delay = 0.25, radius = 140, collision = false},
	["SorakaQ"] = {charName = "Soraka", displayName = "Starcall", slot = _Q, origin = "spell", type = "circular", speed = 1150, range = 810, delay = 0.25, radius = 235, collision = false},
	["SorakaQMissile"] = {charName = "Soraka", displayName = "Starcall [Missile]", slot = _Q, origin = "missile", type = "circular", speed = 1150, range = 810, delay = 0.25, radius = 235, collision = false},
	["SwainW"] = {charName = "Swain", displayName = "Vision of Empire", slot = _W, origin = "spell", type = "circular", speed = math.huge, range = 3500, delay = 1.5, radius = 300, collision = false},
	["SwainE"] = {charName = "Swain", displayName = "Nevermove", slot = _E, origin = "both", type = "linear", speed = 1800, range = 850, delay = 0.25, radius = 85, collision = false},
	["SyndraESphereMissile"] = {charName = "Syndra", displayName = "Scatter the Weak [Seed]", slot = _E, origin = "missile", type = "linear", speed = 2000, range = 950, delay = 0.25, radius = 100, collision = false},
	["TahmKenchQ"] = {charName = "TahmKench", displayName = "Tongue Lash", slot = _Q, origin = "spell", type = "linear", speed = 2800, range = 800, delay = 0.25, radius = 70, collision = true},
	["TahmKenchQMissile"] = {charName = "TahmKench", displayName = "Tongue Lash [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 2800, range = 800, delay = 0.25, radius = 70, collision = true},
	["TaliyahWVC"] = {charName = "Taliyah", displayName = "Seismic Shove", slot = _W, origin = "spell", type = "circular", speed = math.huge, range = 900, delay = 0.85, radius = 150, collision = false},
	["TaliyahR"] = {charName = "Taliyah", displayName = "Weaver's Wall", slot = _R, origin = "spell", type = "linear", speed = 1700, range = 3000, delay = 1, radius = 120, collision = false},
	["TaliyahRMis"] = {charName = "Taliyah", displayName = "Weaver's Wall [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1700, range = 3000, delay = 1, radius = 120, collision = false},
	["ThreshQMissile"] = {charName = "Thresh", displayName = "Death Sentence [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1900, range = 1075, delay = 0.5, radius = 70, collision = true},
	["ThreshE"] = {charName = "Thresh", displayName = "Flay", slot = _E, origin = "spell", type = "linear", speed = math.huge, range = 500, delay = 0.389, radius = 110, collision = true},
	["ThreshEMissile1"] = {charName = "Thresh", displayName = "Flay [Missile]", slot = _E, origin = "missile", type = "linear", speed = math.huge, range = 500, delay = 0.389, radius = 110, collision = true},
	["TristanaW"] = {charName = "Tristana", displayName = "Rocket Jump", slot = _W, origin = "spell", type = "circular", speed = 1100, range = 900, delay = 0.25, radius = 300, collision = false},
	["UrgotQ"] = {charName = "Urgot", displayName = "Corrosive Charge", slot = _Q, origin = "spell", type = "circular", speed = math.huge, range = 800, delay = 0.6, radius = 180, collision = false},
	["UrgotQMissile"] = {charName = "Urgot", displayName = "Corrosive Charge [Missile]", slot = _Q, origin = "missile", type = "circular", speed = math.huge, range = 800, delay = 0.6, radius = 180, collision = false},
	["UrgotE"] = {charName = "Urgot", displayName = "Disdain", slot = _E, origin = "spell", type = "linear", speed = 1500, range = 475, delay = 0.45, radius = 100, collision = false},
	["UrgotR"] = {charName = "Urgot", displayName = "Fear Beyond Death", slot = _R, origin = "both", type = "linear", speed = 3200, range = 1600, delay = 0.4, radius = 80, collision = false},
	["VarusE"] = {charName = "Varus", displayName = "Hail of Arrows", slot = _E, origin = "spell", type = "linear", speed = 1500, range = 925, delay = 0.242, radius = 260, collision = false},
	["VarusEMissile"] = {charName = "Varus", displayName = "Hail of Arrows [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1500, range = 925, delay = 0.242, radius = 260, collision = false},
	["VarusR"] = {charName = "Varus", displayName = "Chain of Corruption", slot = _R, origin = "spell", type = "linear", speed = 1950, range = 1200, delay = 0.25, radius = 120, collision = false},
	["VarusRMissile"] = {charName = "Varus", displayName = "Chain of Corruption [Missile]", slot = _R, origin = "missile", type = "linear", speed = 1950, range = 1200, delay = 0.25, radius = 120, collision = false},
	["VelkozQ"] = {charName = "Velkoz", displayName = "Plasma Fission", slot = _Q, origin = "spell", type = "linear", speed = 1300, range = 1050, delay = 0.25, radius = 50, collision = true},
	["VelkozQMissile"] = {charName = "Velkoz", displayName = "Plasma Fission [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1300, range = 1050, delay = 0.25, radius = 50, collision = true},
	["VelkozQMissileSplit"] = {charName = "Velkoz", displayName = "Plasma Fission [Split]", slot = _Q, origin = "missile", type = "linear", speed = 2100, range = 1100, delay = 0.25, radius = 45, collision = true},
	["VelkozE"] = {charName = "Velkoz", displayName = "Tectonic Disruption", slot = _E, origin = "spell", type = "circular", speed = math.huge, range = 800, delay = 0.8, radius = 185, collision = false},
	["VelkozEMissile"] = {charName = "Velkoz", displayName = "Tectonic Disruption [Missile]", slot = _E, origin = "missile", type = "circular", speed = math.huge, range = 800, delay = 0.8, radius = 185, collision = false},
	["ViktorGravitonField"] = {charName = "Viktor", displayName = "Graviton Field", slot = _W, origin = "spell", type = "circular", speed = math.huge, range = 800, delay = 1.75, radius = 270, collision = false},
	["WarwickR"] = {charName = "Warwick", displayName = "Infinite Duress", slot = _R, origin = "spell", type = "linear", speed = 1800, range = 3000, delay = 0.1, radius = 55, collision = false},
	["XerathArcaneBarrage2"] = {charName = "Xerath", displayName = "Arcane Barrage", slot = _W, origin = "spell", type = "circular", speed = math.huge, range = 1000, delay = 0.75, radius = 235, collision = false},
	["XerathMageSpear"] = {charName = "Xerath", displayName = "Mage Spear", slot = _E, origin = "spell", type = "linear", speed = 1400, range = 1050, delay = 0.2, radius = 60, collision = true},
	["XerathMageSpearMissile"] = {charName = "Xerath", displayName = "Mage Spear [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1400, range = 1050, delay = 0.2, radius = 60, collision = true},
	["XinZhaoW"] = {charName = "XinZhao", displayName = "Wind Becomes Lightning", slot = _W, origin = "spell", type = "linear", speed = 5000, range = 900, delay = 0.5, radius = 40, collision = false},
	["YasuoQ3Mis"] = {charName = "Yasuo", displayName = "Gathering Storm [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 1200, range = 1100, delay = 0.318, radius = 90, collision = false},
	["ZacQ"] = {charName = "Zac", displayName = "Stretching Strikes", slot = _Q, origin = "spell", type = "linear", speed = 2800, range = 800, delay = 0.33, radius = 120, collision = false},
	["ZacQMissile"] = {charName = "Zac", displayName = "Stretching Strikes [Missile]", slot = _Q, origin = "missile", type = "linear", speed = 2800, range = 800, delay = 0.33, radius = 120, collision = false},
	["ZiggsW"] = {charName = "Ziggs", displayName = "Satchel Charge", slot = _W, origin = "both", type = "circular", speed = 1750, range = 1000, delay = 0.25, radius = 240, collision = false},
	["ZiggsE"] = {charName = "Ziggs", displayName = "Hexplosive Minefield", slot = _E, origin = "both", type = "circular", speed = 1800, range = 900, delay = 0.25, radius = 250, collision = false},
	["ZileanQ"] = {charName = "Zilean", displayName = "Time Bomb", slot = _Q, origin = "spell", type = "circular", speed = math.huge, range = 900, delay = 0.8, radius = 150, collision = false},
	["ZileanQMissile"] = {charName = "Zilean", displayName = "Time Bomb [Missile]", slot = _Q, origin = "missile", type = "circular", speed = math.huge, range = 900, delay = 0.8, radius = 150, collision = false},
	["ZoeE"] = {charName = "Zoe", displayName = "Sleepy Trouble Bubble", slot = _E, origin = "spell", type = "linear", speed = 1700, range = 800, delay = 0.3, radius = 50, collision = true},
	["ZoeEMissile"] = {charName = "Zoe", displayName = "Sleepy Trouble Bubble [Missile]", slot = _E, origin = "missile", type = "linear", speed = 1700, range = 800, delay = 0.3, radius = 50, collision = true},
	["ZyraE"] = {charName = "Zyra", displayName = "Grasping Roots", slot = _E, origin = "both", type = "linear", speed = 1150, range = 1100, delay = 0.25, radius = 70, collision = false},
	["ZyraR"] = {charName = "Zyra", displayName = "Stranglethorns", slot = _R, origin = "spell", type = "circular", speed = math.huge, range = 700, delay = 2, radius = 500, collision = false},
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
}

local Allies, Enemies, Turrets, Units = {}, {}, {}, {}

function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
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

function GetAllyHeroes() 
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe and IsValid(Hero) then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
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

function LoadScript()

	self.DetectedMissiles = {}; self.DetectedSpells = {}; self.Target = nil; self.Timer = 0 
	
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})
	
	--AutoE
	Menu:MenuElement({id = "AutoE", name = "AutoE if Ground Controled", type = MENU})
	Menu.AutoE:MenuElement({id = "self", name = "Use Self if CCed ",value = true})
	Menu.AutoE:MenuElement({id = "ally", name = "Use Ally if CCed ",value = true})	
	Menu.AutoE:MenuElement({id = "Targets", name = "Ally Settings", type = MENU})
	for i, Hero in pairs(GetAllyHeroes()) do
		Menu.AutoE.Targets:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
	end		
	
	Menu:MenuElement({type = MENU, id = "ESet", name = "AutoE Incomming CC Spells"})	
	Menu.ESet:MenuElement({id = "UseE", name = "UseE Self", value = true})
	Menu.ESet:MenuElement({id = "UseEally", name = "UseE Ally", value = true})	
	Menu.ESet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})	
	
	--AutoW
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW Immobile Target"})	
	Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W]", value = true})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]only if not Raedy[Q]", value = true})		
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R] Dark Binding", value = true})
	Menu.Combo.Ult:MenuElement({id = "UseRE", name = "Use [R] min Targets", value = 2, min = 1, max = 5})

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]only if not Raedy[Q]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQL", name = "LastHit[Q] Dark Binding", value = false})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})  
	Menu.Clear:MenuElement({id = "UseWM", name = "Use[W] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})
	Menu.JClear:MenuElement({id = "UseWM", name = "Use [W] min Minions", value = 1, min = 1, max = 6})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})	
	Menu.ks:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})
	
	self.Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()
		for i, spell in pairs(CCSpells) do
			if not CCSpells[i] then return end
			for j, k in pairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not Menu.ESet.BlockList[i] then
					if not Menu.ESet.BlockList[i] then Menu.ESet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..self.Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)
	
	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.25, Radius = 150, Range = 900, Speed = math.huge
	}

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1175, Speed = 1200, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
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
		Draw.Circle(myHero, 625, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 1175, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 900, 1, Draw.Color(225, 225, 125, 10))
		end
		
		local target = GetTarget(20000)
		if target == nil then return end	
		if Menu.Drawing.Kill:Value() and IsValid(target) then
		local hp = target.health	
			if Ready(_Q) and getdmg("Q", target, myHero) > hp then
				Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
				Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
			end	
			if Ready(_W) and getdmg("W", target, myHero) > hp then
				Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
				Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
			end	
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "Flee" then
			
	end	

	KillSteal()
	AutoW()
	AutoE()
	Auto1()
	Auto2()

	if Menu.ESet.UseE:Value() and Ready(_E) then
		ProcessSpell()
		for i, spell in pairs(self.DetectedSpells) do
			UseE(i, spell)
		end
	end	

	if Menu.ESet.UseEally:Value() and Ready(_E) then
		for i, ally in pairs(GetAllyHeroes()) do
			ProcessSpell(ally)
			for i, spell in pairs(self.DetectedSpells) do
				UseE(i, spell, ally)
			end	
		end
	end	
end

function ProcessSpell(Unit)
	Unit = Unit or myHero
	local unit, spell = OnProcessSpell()
	if unit and spell and CCSpells[spell.name] then
		if GetDistance(unit.pos, myHero.pos) > 3500 or not Menu.ESet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		local type = Detected.type
		if type == "targeted" then
			if spell.target == myHero.handle then 
				Control.CastSpell(HK_E, myHero)
				table.remove(self.DetectedSpells, i)
			elseif Menu.ESet.UseEally:Value() and spell.target == Unit.handle then 
				Control.CastSpell(HK_E, Unit)
				table.remove(self.DetectedSpells, i)	
				
			end
		else
			local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
			local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
			local endPos, range2 = CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
			table.insert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col})
		end
	end
end

function UseE(i, s, Unit)
	Unit = Unit or myHero
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == math.huge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > Game.Timer() then
		local Col = VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
		local Col2 = VectorPointProjectionOnLineSegment(startPos, endPos, Unit.pos)
		if s.type == "circular" then 
			if GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
				local t = s.speed ~= math.huge and CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay) or 0.29
				if t < 0.3 then 
					Control.CastSpell(HK_E, myHero)
				
				end
			elseif Menu.ESet.UseEally:Value() and GetDistanceSqr(Unit.pos, endPos) < (s.radius + Unit.boundingRadius) ^ 2 or GetDistanceSqr(Unit.pos, Col2) < (s.radius + Unit.boundingRadius * 1.25) ^ 2 then
				local t = s.speed ~= math.huge and CalculateCollisionTime(startPos, endPos, Unit.pos, s.startTime, s.speed, s.delay) or 0.29
				if t < 0.3 then 
					Control.CastSpell(HK_E, Unit)
				
				end				
			end
		end	
	else table.remove(self.DetectedSpells, i) end
end

function AutoE()
	if IsImmobileTarget(myHero) and Menu.AutoE.self:Value() and Ready(_E) then
		Control.CastSpell(HK_E, myHero)
	end
	
	for i = 1, Game.HeroCount() do
	local ally = Game.Hero(i)
		if ally.isAlly and ally ~= myHero then
			if myHero.pos:DistanceTo(ally.pos) <= 800 and IsValid(ally) then 
				if IsImmobileTarget(ally) and Menu.AutoE.ally:Value() and Menu.AutoE.Targets[ally.charName] and Menu.AutoE.Targets[ally.charName]:Value() and Ready(_E) then
					Control.CastSpell(HK_E, ally)
				end
			end
		end
	end
end

function KillSteal()	
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then
        
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 1175 and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= target.health and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
        end
		
        if Menu.ks.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 900 and Ready(_W) then
            local WDmg = getdmg("W", target, myHero)
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if WDmg >= target.health and pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then			
				Control.CastSpell(HK_W, pred.CastPosition)
			end	
        end
	end	
end

function AutoW()
local target = GetTarget(950)
if target == nil then return end
	if IsValid(target) then
		if myHero.pos:DistanceTo(target.pos) < 900 and IsImmobileTarget(target) and Menu.AutoW.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target.pos)
		
		elseif myHero.pos:DistanceTo(target.pos) > 900 and myHero.pos:DistanceTo(target.pos) < 1175 and IsImmobileTarget(target) and Menu.AutoW.UseW:Value() and Ready(_W) then
			local WPos = myHero.pos:Shortened(target.pos - 900)
			Control.SetCursorPos(WPos)
			Control.KeyDown(HK_W)
			Control.KeyUp(HK_W)
		end	
	end
end	

function Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then
        
		if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 1175 and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
        end
       
		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 900 and Ready(_W) and not Ready(_Q) then
            local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then			
				Control.CastSpell(HK_W, pred.CastPosition)
			end	
        end

        if Menu.Combo.Ult.UseR:Value() and myHero.pos:DistanceTo(target.pos) < 625 and Ready(_R) then
            local count = GetEnemyCount(625, myHero)
			if count >= Menu.Combo.Ult.UseRE:Value() then
				Control.CastSpell(HK_R)
			end	
		end
	end
end

function Harass()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
        
		if Menu.Harass.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) < 1175 and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
        end
		
        if Menu.Harass.UseW:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) < 900 and Ready(_W) and not Ready(_Q) then
            local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then			
				Control.CastSpell(HK_W, pred.CastPosition)
	
			end
        end	
	end
end	

function Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQL:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1175 and IsValid(minion) and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero)
				if QDmg >= minion.health then
					Control.CastSpell(HK_Q, minion.pos)
				end	
            end
			
            if Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 900 and IsValid(minion) and Ready(_W) then
                local count = GetMinionCount(275, minion)
				if count >= Menu.Clear.UseWM:Value() then
					Control.CastSpell(HK_W, minion.pos)
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
            
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1175 and IsValid(minion) and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 900 and IsValid(minion) and Ready(_W) then
                local count = GetMinionCount(275, minion)
				if count >= Menu.JClear.UseWM:Value() then	
					Control.CastSpell(HK_W, minion.pos)
				end	
            end
        end
    end
end

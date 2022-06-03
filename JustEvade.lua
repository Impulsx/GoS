--[[

	_________                _____ __________                _________      
	______  /____  ____________  /____  ____/___   ________ _______  /_____ 
	___ _  / _  / / /__  ___/_  __/__  __/   __ | / /_  __ `/_  __  / _  _ \
	/ /_/ /  / /_/ / _(__  ) / /_  _  /___   __ |/ / / /_/ / / /_/ /  /  __/
	\____/   \__,_/  /____/  \__/  /_____/   _____/  \__,_/  \__,_/   \___/ 
                                                           Powered by GoS!

	Author: Ark223
	Credits: Gamsteron, Maxxxel, Mad & Noddy, Zbysiu

	Changelog:

	v1.1.7 // if you noticed any bugs write to Zbysiu#1192
	+ Added Gwen's spells (NOT TESTED!)
	+ Added Viego's spells (NOT TESTED!)
	+ Added Zeri's spells (NOT TESTED!)
	+ Added Zeri's E to evading spells
	+ Fixed the usage of flash by script. From now on, for a script to use flash from an undodgeable skill, the skill's danger level must be set to 5.
	+ Thresh Q detection has been fixed (EXPERIMENTAL!)
	+ Dr Mundo's Q detection has been fixed (Turn on "Force To Dodge" if you want the best results.)
	+ Dr Mundo's Q hitbox corrected
	+ Slightly improved optimization
	- Removed AutoUpdate because the script is no longer updated by the author

	v1.1.6
	+ Added Rell, Samira, Seraphine and Yone spells
	+ Yasuo Q & Q3 no longer needs a missile detection

	v1.1.5
	+ Extended evade loading to make sure the spells are loaded

	v1.1.4
	+ Improved drawing performance

	v1.1.3
	+ Fixed API callbacks

	v1.1.2
	+ Improved hit prediction for linear skillshots
	+ Removed 'Evade Mode' menu option and replaced 'Safety Check Sensitivity' with 'Average Game Ping'

	v1.1.1
	+ Fixed MapPosition callbacks

	v1.1
	+ Added Sett's spells
	+ Fixed rectangle offsetting

	v1.0.9
	+ Added Aphelios spells

	v1.0.8
	+ Fixed importing danger level to spells table

	v1.0.7
	+ Added Senna's spells

	v1.0.6
	+ Added VelKoz's Q split, Jayce EQ & Syndra QE spell
	+ Added danger level arg to OnImpossibleDodge callback
	+ Fixed support for multiple evading spells and conflict with flash usage
	+ Fixed Taliyah's Q detection & rectangular spells
	+ Optimized path returning structure

	v1.0.5
	+ Added Annie's E evading spell
	+ Updated Blitz's Q spell range

	v1.0.4
	+ Fixed data parsing on detected missile

	v1.0.3
	+ Fixed bug related to polygon offsetting

	v1.0.2
	+ Fixed flash usage

	v1.0.1
	+ Fixed loading & spell usage

	v1.0
	+ Initial release of new series

--]]
local Version, IntVer = 1.17, "1.1.7"

local MathAbs, MathAtan, MathAtan2, MathAcos, MathCeil, MathCos, MathDeg, MathFloor, MathHuge, MathMax, MathMin, MathPi, MathRad, MathSin, MathSqrt = math.abs, math.atan, math.atan2, math.acos, math.ceil, math.cos, math.deg, math.floor, math.huge, math.max, math.min, math.pi, math.rad, math.sin, math.sqrt
local GameCanUseSpell, GameLatency, GameTimer, GameHeroCount, GameHero, GameMinionCount, GameMinion, GameMissileCount, GameMissile = Game.CanUseSpell, Game.Latency, Game.Timer, Game.HeroCount, Game.Hero, Game.MinionCount, Game.Minion, Game.MissileCount, Game.Missile
local DrawCircle, DrawColor, DrawLine, DrawText, ControlKeyUp, ControlKeyDown, ControlMouseEvent, ControlSetCursorPos = Draw.Circle, Draw.Color, Draw.Line, Draw.Text, Control.KeyUp, Control.KeyDown, Control.mouse_event, Control.SetCursorPos
local TableInsert, TableRemove, TableSort = table.insert, table.remove, table.sort
local Icons, Png = "https://raw.githubusercontent.com/Ark223/LoL-Icons/master/", ".png"
local Icona = "https://static.wikia.nocookie.net/lolesports_gamepedia_en/images/5/59/Spark_Surge.png"
local Icona1 = "https://static.wikia.nocookie.net/lolesports_gamepedia_en/images/b/b0/Burst_Fire.png"
local Icona2 = "https://static.wikia.nocookie.net/leagueoflegends/images/f/f3/Viego_Spectral_Maw.png"
local Icona3 = "https://static.wikia.nocookie.net/lolesports_gamepedia_en/images/7/7b/Snip_Snip%21.png"
local Icona4 = "https://static.wikia.nocookie.net/lolesports_gamepedia_en/images/d/d1/Needlework.png"
local FlashIcon = Icons.."Flash"..Png

require "2DGeometry"
require 'MapPositionGOS'

local SpellDatabase = {
	["Aatrox"] = {
		["AatroxQ"] = {icon = Icons.."AatroxQ1"..Png, displayName = "The Darkin Blade [First]", slot = _Q, type = "linear", speed = MathHuge, range = 650, delay = 0.6, radius = 130, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["AatroxQ2"] = {icon = Icons.."AatroxQ2"..Png, displayName = "The Darkin Blade [Second]", slot = _Q, type = "polygon", speed = MathHuge, range = 500, delay = 0.6, radius = 200, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["AatroxQ3"] = {icon = Icons.."AatroxQ3"..Png, displayName = "The Darkin Blade [Third]", slot = _Q, type = "circular", speed = MathHuge, range = 200, delay = 0.6, radius = 300, danger = 4, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["AatroxW"] = {icon = Icons.."AatroxW"..Png, displayName = "Infernal Chains", missileName = "AatroxW", slot = _W, type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 80, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Ahri"] = {
		["AhriOrbofDeception"] = {icon = Icons.."AhriQ"..Png, missileName = "AhriOrbMissile", displayName = "Orb of Deception", slot = _Q, type = "linear", speed = 2500, range = 880, delay = 0.25, radius = 100, danger = 2, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["AhriSeduce"] = {icon = Icons.."AhriE"..Png, displayName = "Seduce",  missileName = "AhriSeduceMissile", slot = _E, type = "linear", speed = 1500, range = 975, delay = 0.25, radius = 60, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Akali"] = {
		["AkaliQ"] = {icon = Icons.."AkaliQ"..Png, displayName = "Five Point Strike", slot = _Q, type = "conic", speed = 3200, range = 550, delay = 0.25, radius = 60, angle = 45, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
		["AkaliE"] = {icon = Icons.."AkaliE"..Png, displayName = "Shuriken Flip", missileName = "AkaliEMis", slot = _E, type = "linear", speed = 1800, range = 825, delay = 0.25, radius = 70, danger = 2, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["AkaliR"] = {icon = Icons.."AkaliR1"..Png, displayName = "Perfect Execution [First]", slot = _R, type = "linear", speed = 1800, range = 675, delay = 0, radius = 65, danger = 4, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["AkaliRb"] = {icon = Icons.."AkaliR2"..Png, displayName = "Perfect Execution [Second]", slot = _R, type = "linear", speed = 3600, range = 525, delay = 0, radius = 65, danger = 4, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Alistar"] = {
		["Pulverize"] = {icon = Icons.."AlistarQ"..Png, displayName = "Pulverize", slot = _Q, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 365, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Amumu"] = {
		["BandageToss"] = {icon = Icons.."AmumuQ"..Png, displayName = "Bandage Toss", missileName = "SadMummyBandageToss", slot = _Q, type = "linear", speed = 2000, range = 1100, delay = 0.25, radius = 80, danger = 3, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["CurseoftheSadMummy"] = {icon = Icons.."AmumuR"..Png, displayName = "Curse of the Sad Mummy", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 550, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Anivia"] = {
		["FlashFrostSpell"] = {icon = Icons.."AniviaQ"..Png, displayName = "Flash Frost", missileName = "FlashFrostSpell", slot = _Q, type = "linear", speed = 950, range = 1100, delay = 0.25, radius = 110, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Annie"] = {
		["AnnieW"] = {icon = Icons.."AnnieW"..Png, displayName = "Incinerate", slot = _W, type = "conic", speed = MathHuge, range = 600, delay = 0.25, radius = 0, angle = 50, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["AnnieR"] = {icon = Icons.."AnnieR"..Png, displayName = "Summon: Tibbers", slot = _R, type = "circular", speed = MathHuge, range = 600, delay = 0.25, radius = 290, danger = 5, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Aphelios"] = {
		["ApheliosCalibrumQ"] = {icon = Icons.."ApheliosQ1"..Png, displayName = "Moonshot", missileName = "ApheliosCalibrumQ", slot = _Q, type = "linear", speed = 1850, range = 1450, delay = 0.35, radius = 60, danger = 1, cc = false, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["ApheliosInfernumQ"] = {icon = Icons.."ApheliosQ2"..Png, displayName = "Duskwave", slot = _Q, type = "conic", speed = 1500, range = 850, delay = 0.25, radius = 65, angle = 45, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
		["ApheliosR"] = {icon = Icons.."ApheliosR"..Png, displayName = "Moonlight Vigil", missileName = "ApheliosRMis", slot = _R, type = "linear", speed = 2050, range = 1600, delay = 0.5, radius = 125, danger = 3, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Ashe"] = {
		["Volley"] = {icon = Icons.."AsheW"..Png, displayName = "Volley", missileName = "VolleyRightAttack", slot = _W, type = "conic", speed = 2000, range = 1200, delay = 0.25, radius = 20, angle = 40, danger = 2, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["EnchantedCrystalArrow"] = {icon = Icons.."AsheR"..Png, displayName = "Enchanted Crystal Arrow", missileName = "EnchantedCrystalArrow", slot = _R, type = "linear", speed = 1600, range = 12500, delay = 0.25, radius = 130, danger = 4, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["AurelionSol"] = {
		["AurelionSolQ"] = {icon = Icons.."AurelionSolQ"..Png, displayName = "Starsurge", missileName = "AurelionSolQMissile", slot = _Q, type = "linear", speed = 850, range = 1075, delay = 0, radius = 110, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["AurelionSolR"] = {icon = Icons.."AurelionSolR"..Png, displayName = "Voice of Light", slot = _R, type = "linear", speed = 4500, range = 1500, delay = 0.35, radius = 120, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Azir"] = {
		["AzirR"] = {icon = Icons.."AzirR"..Png, displayName = "Emperor's Divide", slot = _R, type = "linear", speed = 1400, range = 500, delay = 0.3, radius = 250, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Bard"] = {
		["BardQ"] = {icon = Icons.."BardQ"..Png, displayName = "Cosmic Binding", missileName = "BardQMissile", slot = _Q, type = "linear", speed = 1500, range = 950, delay = 0.25, radius = 60, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["BardR"] = {icon = Icons.."BardR"..Png, displayName = "Tempered Fate", missileName = "BardRMissile", slot = _R, type = "circular", speed = 2100, range = 3400, delay = 0.5, radius = 350, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = true, exception = false, extend = false},
	},
	["Blitzcrank"] = {
		["RocketGrab"] = {icon = Icons.."BlitzcrankQ"..Png, displayName = "Rocket Grab", missileName = "RocketGrabMissile", slot = _Q, type = "linear", speed = 1800, range = 1150, delay = 0.25, radius = 70, danger = 3, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["StaticField"] = {icon = Icons.."BlitzcrankR"..Png, displayName = "Static Field", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 600, danger = 4, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Brand"] = {
		["BrandQ"] = {icon = Icons.."BrandQ"..Png, displayName = "Sear", missileName = "BrandQMissile", slot = _Q, type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 60, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["BrandW"] = {icon = Icons.."BrandW"..Png, displayName = "Pillar of Flame", slot = _W, type = "circular", speed = MathHuge, range = 900, delay = 0.85, radius = 250, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Braum"] = {
		["BraumQ"] = {icon = Icons.."BraumQ"..Png, displayName = "Winter's Bite", missileName = "BraumQMissile", slot = _Q, type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, danger = 3, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["BraumR"] = {icon = Icons.."BraumR"..Png, displayName = "Glacial Fissure", missileName = "BraumRMissile", slot = _R, type = "linear", speed = 1400, range = 1250, delay = 0.5, radius = 115, danger = 4, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Caitlyn"] = {
		["CaitlynPiltoverPeacemaker"] = {icon = Icons.."CaitlynQ"..Png, displayName = "Piltover Peacemaker", missileName = "CaitlynPiltoverPeacemaker", slot = _Q, type = "linear", speed = 2200, range = 1250, delay = 0.625, radius = 90, danger = 1, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["CaitlynYordleTrap"] = {icon = Icons.."CaitlynW"..Png, displayName = "Yordle Trap", slot = _W, type = "circular", speed = MathHuge, range = 800, delay = 0.35, radius = 75, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["CaitlynEntrapment"] = {icon = Icons.."CaitlynE"..Png, displayName = "Entrapment", missileName = "CaitlynEntrapment", slot = _E, type = "linear", speed = 1600, range = 750, delay = 0.15, radius = 70, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Camille"] = {
		["CamilleE"] = {icon = Icons.."CamilleE1"..Png, displayName = "Hookshot [First]", missileName = "CamilleEMissile", slot = _E, type = "linear", speed = 1900, range = 800, delay = 0, radius = 60, danger = 1, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["CamilleEDash2"] = {icon = Icons.."CamilleE2"..Png, displayName = "Hookshot [Second]", slot = _E, type = "linear", speed = 1900, range = 400, delay = 0, radius = 60, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Cassiopeia"] = {
		["CassiopeiaQ"] = {icon = Icons.."CassiopeiaQ"..Png, displayName = "Noxious Blast", slot = _Q, type = "circular", speed = MathHuge, range = 850, delay = 0.75, radius = 150, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["CassiopeiaW"] = {icon = Icons.."CassiopeiaW"..Png, displayName = "Miasma", slot = _W, type = "circular", speed = 2500, range = 800, delay = 0.75, radius = 160, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = false},
		["CassiopeiaR"] = {icon = Icons.."CassiopeiaR"..Png, displayName = "Petrifying Gaze", slot = _R, type = "conic", speed = MathHuge, range = 825, delay = 0.5, radius = 0, angle = 80, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Chogath"] = {
		["Rupture"] = {icon = Icons.."ChogathQ"..Png, displayName = "Rupture", slot = _Q, type = "circular", speed = MathHuge, range = 950, delay = 1.2, radius = 250, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["FeralScream"] = {icon = Icons.."ChogathW"..Png, displayName = "Feral Scream", slot = _W, type = "conic", speed = MathHuge, range = 650, delay = 0.5, radius = 0, angle = 56, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Corki"] = {
		["PhosphorusBomb"] = {icon = Icons.."CorkiQ"..Png, displayName = "Phosphorus Bomb", missileName = "PhosphorusBombMissile", slot = _Q, type = "circular", speed = 1000, range = 825, delay = 0.25, radius = 250, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["MissileBarrageMissile"] = {icon = Icons.."CorkiR1"..Png, displayName = "Missile Barrage [Standard]", missileName = "MissileBarrageMissile", slot = _R, type = "linear", speed = 2000, range = 1300, delay = 0.175, radius = 40, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["MissileBarrageMissile2"] = {icon = Icons.."CorkiR2"..Png, displayName = "Missile Barrage [Big]", missileName = "MissileBarrageMissile2", slot = _R, type = "linear", speed = 2000, range = 1500, delay = 0.175, radius = 40, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Diana"] = {
		["DianaQ"] = {icon = Icons.."DianaQ"..Png, displayName = "Crescent Strike", slot = _Q, type = "circular", speed = 1900, range = 900, delay = 0.25, radius = 185, danger = 2, cc = false, collision = true, windwall = true, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Draven"] = {
		["DravenDoubleShot"] = {icon = Icons.."DravenE"..Png, displayName = "Double Shot", missileName = "DravenDoubleShotMissile", slot = _E, type = "linear", speed = 1600, range = 1050, delay = 0.25, radius = 130, danger = 3, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["DravenRCast"] = {icon = Icons.."DravenR"..Png, displayName = "Whirling Death", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 0.25, radius = 160, danger = 4, cc = false, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
	},
	["DrMundo"] = {
		["DrMundoQ"] = {icon = Icons.."DrMundoQ"..Png, displayName = "Infected Bonesaw", missileName = "InfectedBonesawMissile", slot = _Q, type = "linear", speed = 2000, range = 925, delay = 0.25, radius = 130, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Ekko"] = {
		["EkkoQ"] = {icon = Icons.."EkkoQ"..Png, displayName = "Timewinder", missileName = "EkkoQMis", slot = _Q, type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 60, danger = 1, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["EkkoW"] = {icon = Icons.."EkkoW"..Png, displayName = "Parallel Convergence", slot = _W, type = "circular", speed = MathHuge, range = 1600, delay = 3.35, radius = 400, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Elise"] = {
		["EliseHumanE"] = {icon = Icons.."EliseE"..Png, displayName = "Cocoon", missileName = "EliseHumanE", slot = _E, type = "linear", speed = 1600, range = 1075, delay = 0.25, radius = 55, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Evelynn"] = {
		["EvelynnQ"] = {icon = Icons.."EvelynnQ"..Png, displayName = "Hate Spike", missileName = "EvelynnQ", slot = _Q, type = "linear", speed = 2400, range = 800, delay = 0.25, radius = 60, danger = 2, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["EvelynnR"] = {icon = Icons.."EvelynnR"..Png, displayName = "Last Caress", slot = _R, type = "conic", speed = MathHuge, range = 450, delay = 0.35, radius = 180, angle = 180, danger = 5, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Ezreal"] = {
		["EzrealQ"] = {icon = Icons.."EzrealQ"..Png, displayName = "Mystic Shot", missileName = "EzrealQ", slot = _Q, type = "linear", speed = 2000, range = 1150, delay = 0.25, radius = 60, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["EzrealW"] = {icon = Icons.."EzrealW"..Png, displayName = "Essence Flux", missileName = "EzrealW", slot = _W, type = "linear", speed = 2000, range = 1150, delay = 0.25, radius = 60, danger = 1, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["EzrealR"] = {icon = Icons.."EzrealR"..Png, displayName = "Trueshot Barrage", missileName = "EzrealR", slot = _R, type = "linear", speed = 2000, range = 12500, delay = 1, radius = 160, danger = 4, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Fiora"] = {
		["FioraW"] = {icon = Icons.."FioraW"..Png, displayName = "Riposte", slot = _W, type = "linear", speed = 3200, range = 750, delay = 0.75, radius = 70, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Fizz"] = {
		["FizzR"] = {icon = Icons.."FizzR"..Png, displayName = "Chum the Waters", missileName = "FizzRMissile", slot = _R, type = "linear", speed = 1300, range = 1300, delay = 0.25, radius = 150, danger = 5, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Galio"] = {
		["GalioQ"] = {icon = Icons.."GalioQ"..Png, displayName = "Winds of War", missileName = "GalioQMissile", slot = _Q, type = "circular", speed = 1150, range = 825, delay = 0.25, radius = 235, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["GalioE"] = {icon = Icons.."GalioE"..Png, displayName = "Justice Punch", slot = _E, type = "linear", speed = 2300, range = 650, delay = 0.4, radius = 160, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Gnar"] = {
		["GnarQMissile"] = {icon = Icons.."GnarQMini"..Png, displayName = "Boomerang Throw", missileName = "GnarQMissile", slot = _Q, type = "linear", speed = 2500, range = 1125, delay = 0.25, radius = 55, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["GnarBigQMissile"] = {icon = Icons.."GnarQMega"..Png, displayName = "Boulder Toss", missileName = "GnarBigQMissile", slot = _Q, type = "linear", speed = 2100, range = 1125, delay = 0.5, radius = 90, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["GnarBigW"] = {icon = Icons.."GnarWMega"..Png, displayName = "Wallop", slot = _W, type = "linear", speed = MathHuge, range = 575, delay = 0.6, radius = 100, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		--["GnarE"] = {icon = Icons.."GnarEMini"..Png, displayName = "Hop", slot = _E, type = "circular", speed = 900, range = 475, delay = 0.25, radius = 160, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		--["GnarBigE"] = {icon = Icons.."GnarEMega"..Png, displayName = "Crunch", slot = _E, type = "circular", speed = 800, range = 600, delay = 0.25, radius = 375, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["GnarR"] = {icon = Icons.."GnarR"..Png, displayName = "GNAR!", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 0.25, radius = 475, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Gragas"] = {
		["GragasQ"] = {icon = Icons.."GragasQ"..Png, displayName = "Barrel Roll", missileName = "GragasQMissile", slot = _Q, type = "circular", speed = 1000, range = 850, delay = 0.25, radius = 275, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		--["GragasE"] = {icon = Icons.."GragasE"..Png, displayName = "Body Slam", slot = _E, type = "linear", speed = 900, range = 600, delay = 0.25, radius = 170, danger = 2, cc = true, collision = true, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["GragasR"] = {icon = Icons.."GragasR"..Png, displayName = "Explosive Cask", missileName = "GragasRBoom", slot = _R, type = "circular", speed = 1800, range = 1000, delay = 0.25, radius = 400, danger = 5, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
	},
	["Graves"] = {
		["GravesQLineSpell"] = {icon = Icons.."GravesQ"..Png, displayName = "End of the Line", slot = _Q, type = "polygon", speed = MathHuge, range = 800, delay = 1.4, radius = 20, danger = 1, cc = false, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
		["GravesSmokeGrenade"] = {icon = Icons.."GravesW"..Png, displayName = "Smoke Grenade", missileName = "GravesSmokeGrenadeBoom", slot = _W, type = "circular", speed = 1500, range = 950, delay = 0.15, radius = 250, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["GravesChargeShot"] = {icon = Icons.."GravesR"..Png, displayName = "Charge Shot", missileName = "GravesChargeShotShot", slot = _R, type = "polygon", speed = 2100, range = 1000, delay = 0.25, radius = 100, danger = 5, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Gwen"] = {
		["GwenQ"] = {icon = Icona3, displayName = "Snip Snip!", slot = _Q, type = "circular", speed = 1500, range = 450, delay = 0, radius = 275, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["GwenR"] = {icon = Icona4, displayName = "Needlework", missileName = "GwenRMissile", slot = _R, type = "linear", speed = 1800, range = 1230, delay = 0.25, radius = 250, danger = 3, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Hecarim"] = {
		["HecarimUlt"] = {icon = Icons.."HecarimR"..Png, displayName = "Onslaught of Shadows", missileName = "HecarimUltMissile", slot = _R, type = "linear", speed = 1100, range = 1650, delay = 0.2, radius = 280, danger = 4, cc = true, collision = false, windwall = false, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Heimerdinger"] = {
		["HeimerdingerW"] = {icon = Icons.."HeimerdingerW"..Png, displayName = "Hextech Micro-Rockets", slot = _W, type = "linear", speed = 2050, range = 1325, delay = 0.25, radius = 100, danger = 2, cc = false, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
		["HeimerdingerE"] = {icon = Icons.."HeimerdingerE1"..Png, displayName = "CH-2 Electron Storm Grenade", missileName = "HeimerdingerESpell", slot = _E, type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["HeimerdingerEUlt"] = {icon = Icons.."HeimerdingerE2"..Png, displayName = "CH-2 Electron Storm Grenade [Ult]", missileName = "HeimerdingerESpell_ult", slot = _E, type = "circular", speed = 1200, range = 970, delay = 0.25, radius = 250, danger = 3, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
	},
	["Illaoi"] = {
		["IllaoiQ"] = {icon = Icons.."IllaoiQ"..Png, displayName = "Tentacle Smash", slot = _Q, type = "linear", speed = MathHuge, range = 850, delay = 0.75, radius = 100, danger = 2, cc = false, collision = true, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["IllaoiE"] = {icon = Icons.."IllaoiE"..Png, displayName = "Test of Spirit", missileName = "IllaoiEMis", slot = _E, type = "linear", speed = 1900, range = 900, delay = 0.25, radius = 50, danger = 1, cc = false, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Irelia"] = {
		["IreliaW2"] = {icon = Icons.."IreliaW"..Png, displayName = "Defiant Dance", slot = _W, type = "linear", speed = MathHuge, range = 825, delay = 0.25, radius = 120, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		--["IreliaEParticleMissile"] = {icon = Icons.."IreliaE"..Png, displayName = "Flawless Duet", missileName = "IreliaEParticleMissile", slot = _E, type = "linear", speed = MathHuge, range = 1550, delay = 0.5, radius = 70, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = true, exception = true, extend = false},
		["IreliaR"] = {icon = Icons.."IreliaR"..Png, displayName = "Vanguard's Edge", missileName = "IreliaR", slot = _R, type = "linear", speed = 2000, range = 950, delay = 0.4, radius = 160, danger = 4, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Ivern"] = {
		["IvernQ"] = {icon = Icons.."IvernQ"..Png, displayName = "Rootcaller", missileName = "IvernQ", slot = _Q, type = "linear", speed = 1300, range = 1075, delay = 0.25, radius = 80, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Janna"] = {
		["HowlingGaleSpell"] = {icon = Icons.."JannaQ"..Png, displayName = "Howling Gale", missileName = "HowlingGaleSpell", slot = _Q, type = "linear", speed = 667, range = 1750, radius = 100, danger = 2, cc = true, collision = false, windwall = true, fow = true, exception = true, extend = false},
	},
	["JarvanIV"] = {
		["JarvanIVDragonStrike"] = {icon = Icons.."JarvanIVQ"..Png, displayName = "Dragon Strike", slot = _Q, type = "linear", speed = MathHuge, range = 770, delay = 0.4, radius = 70, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["JarvanIVDemacianStandard"] = {icon = Icons.."JarvanIVE"..Png, displayName = "Demacian Standard", slot = _E, type = "circular", speed = 3440, range = 860, delay = 0, radius = 175, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Jayce"] = {
		["JayceShockBlast"] = {icon = Icons.."JayceQ"..Png, displayName = "Shock Blast [Standard]", missileName = "JayceShockBlastMis", slot = _Q, type = "linear", speed = 1450, range = 1050, delay = 0.214, radius = 70, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["JayceShockBlastWallMis"] = {icon = Icons.."JayceQ"..Png, displayName = "Shock Blast [Accelerated]", missileName = "JayceShockBlastWallMis", slot = _Q, type = "linear", speed = 2350, range = 1600, delay = 0.152, radius = 115, danger = 3, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = true, extend = false},
	},
	["Jhin"] = {
		["JhinW"] = {icon = Icons.."JhinW"..Png, displayName = "Deadly Flourish", slot = _W, type = "linear", speed = 5000, range = 2550, delay = 0.75, radius = 40, danger = 1, cc = true, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
		["JhinE"] = {icon = Icons.."JhinE"..Png, displayName = "Captive Audience", missileName = "JhinETrap", slot = _E, type = "circular", speed = 1600, range = 750, delay = 0.25, radius = 130, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = true, exception = false, extend = false},
		["JhinRShot"] = {icon = Icons.."JhinR"..Png, displayName = "Curtain Call", missileName = "JhinRShotMis", slot = _R, type = "linear", speed = 5000, range = 3500, delay = 0.25, radius = 80, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Jinx"] = {
		["JinxWMissile"] = {icon = Icons.."JinxW"..Png, displayName = "Zap!", missileName = "JinxWMissile", slot = _W, type = "linear", speed = 3300, range = 1450, delay = 0.6, radius = 60, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["JinxEHit"] = {icon = Icons.."JinxE"..Png, displayName = "Flame Chompers!", missileName = "JinxEHit", slot = _E, type = "polygon", speed = 1100, range = 900, delay = 1.5, radius = 120, danger = 1, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["JinxR"] = {icon = Icons.."JinxR"..Png, displayName = "Super Mega Death Rocket!", missileName = "JinxR", slot = _R, type = "linear", speed = 1700, range = 12500, delay = 0.6, radius = 140, danger = 4, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Kaisa"] = {
		["KaisaW"] = {icon = Icons.."KaisaW"..Png, displayName = "Void Seeker", missileName = "KaisaW", slot = _W, type = "linear", speed = 1750, range = 3000, delay = 0.4, radius = 100, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Kalista"] = {
		["KalistaMysticShot"] = {icon = Icons.."KalistaQ"..Png, displayName = "Pierce", missileName = "KalistaMysticShotMisTrue", slot = _Q, type = "linear", speed = 2400, range = 1150, delay = 0.25, radius = 40, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Karma"] = {
		["KarmaQ"] = {icon = Icons.."KarmaQ1"..Png, displayName = "Inner Flame", missileName = "KarmaQMissile", slot = _Q, type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 60, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["KarmaQMantra"] = {icon = Icons.."KarmaQ2"..Png, displayName = "Inner Flame [Mantra]", missileName = "KarmaQMissileMantra", slot = _Q, type = "linear", speed = 1700, range = 950, delay = 0.25, radius = 80, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Karthus"] = {
		["KarthusLayWasteA1"] = {icon = Icons.."KarthusQ"..Png, displayName = "Lay Waste [1]", slot = _Q, type = "circular", speed = MathHuge, range = 875, delay = 0.9, radius = 175, danger = 1, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["KarthusLayWasteA2"] = {icon = Icons.."KarthusQ"..Png, displayName = "Lay Waste [2]", slot = _Q, type = "circular", speed = MathHuge, range = 875, delay = 0.9, radius = 175, danger = 1, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["KarthusLayWasteA3"] = {icon = Icons.."KarthusQ"..Png, displayName = "Lay Waste [3]", slot = _Q, type = "circular", speed = MathHuge, range = 875, delay = 0.9, radius = 175, danger = 1, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Kassadin"] = {
		["ForcePulse"] = {icon = Icons.."KassadinE"..Png, displayName = "Force Pulse", slot = _E, type = "conic", speed = MathHuge, range = 600, delay = 0.3, radius = 0, angle = 80, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["RiftWalk"] = {icon = Icons.."KassadinR"..Png, displayName = "Rift Walk", slot = _R, type = "circular", speed = MathHuge, range = 500, delay = 0.25, radius = 250, danger = 3, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Kayle"] = {
		["KayleQ"] = {icon = Icons.."KayleQ"..Png, displayName = "Radiant Blast", missileName = "KayleQMis", slot = _Q, type = "linear", speed = 1600, range = 900, delay = 0.25, radius = 60, danger = 1, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Kayn"] = {
		--["KaynQ"] = {icon = Icons.."KaynQ"..Png, displayName = "Reaping Slash", slot = _Q, type = "circular", speed = MathHuge, range = 0, delay = 0.15, radius = 350, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["KaynW"] = {icon = Icons.."KaynW"..Png, displayName = "Blade's Reach", slot = _W, type = "linear", speed = MathHuge, range = 700, delay = 0.55, radius = 90, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Kennen"] = {
		["KennenShurikenHurlMissile1"] = {icon = Icons.."KennenQ"..Png, displayName = "Shuriken Hurl", missileName = "KennenShurikenHurlMissile1", slot = _Q, type = "linear", speed = 1700, range = 1050, delay = 0.175, radius = 50, danger = 2, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Khazix"] = {
		["KhazixW"] = {icon = Icons.."KhazixW1"..Png, displayName = "Void Spike [Standard]", missileName = "KhazixWMissile", slot = _W, type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 70, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["KhazixWLong"] = {icon = Icons.."KhazixW2"..Png, displayName = "Void Spike [Threeway]", slot = _W, type = "threeway", speed = 1700, range = 1000, delay = 0.25, radius = 70, angle = 23, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
	},
	["Kled"] = {
		["KledQ"] = {icon = Icons.."KledQMount"..Png, displayName = "Beartrap on a Rope", missileName = "KledQMissile", slot = _Q, type = "linear", speed = 1600, range = 800, delay = 0.25, radius = 45, danger = 1, cc = true, collision = false, windwall = true, fow = true, exception = false, extend = true},
		["KledRiderQ"] = {icon = Icons.."KledQDismount"..Png, displayName = "Pocket Pistol", missileName = "KledRiderQMissile", slot = _Q, type = "conic", speed = 3000, range = 700, delay = 0.25, radius = 0, angle = 25, danger = 3, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		--["KledEDash"] = {icon = Icons.."KledE"..Png, displayName = "Jousting", slot = _E, type = "linear", speed = 1100, range = 550, delay = 0, radius = 90, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["KogMaw"] = {
		["KogMawQ"] = {icon = Icons.."KogMawQ"..Png, displayName = "Caustic Spittle", missileName = "KogMawQ", slot = _Q, type = "linear", speed = 1650, range = 1175, delay = 0.25, radius = 70, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["KogMawVoidOozeMissile"] = {icon = Icons.."KogMawE"..Png, displayName = "Void Ooze", missileName = "KogMawVoidOozeMissile", slot = _E, type = "linear", speed = 1400, range = 1360, delay = 0.25, radius = 120, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["KogMawLivingArtillery"] = {icon = Icons.."KogMawR"..Png, displayName = "Living Artillery", slot = _R, type = "circular", speed = MathHuge, range = 1300, delay = 1.1, radius = 200, danger = 1, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Leblanc"] = {
		["LeblancE"] = {icon = Icons.."LeblancE"..Png, displayName = "Ethereal Chains [Standard]", missileName = "LeblancEMissile", slot = _E, type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["LeblancRE"] = {icon = Icons.."LeblancRE"..Png, displayName = "Ethereal Chains [Ultimate]", missileName = "LeblancREMissile", slot = _E, type = "linear", speed = 1750, range = 925, delay = 0.25, radius = 55, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["LeeSin"] = {
		["BlindMonkQOne"] = {icon = Icons.."LeeSinQ"..Png, displayName = "Sonic Wave", missileName = "BlindMonkQOne", slot = _Q, type = "linear", speed = 1800, range = 1100, delay = 0.25, radius = 60, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Leona"] = {
		["LeonaZenithBlade"] = {icon = Icons.."LeonaE"..Png, displayName = "Zenith Blade", missileName = "LeonaZenithBladeMissile", slot = _E, type = "linear", speed = 2000, range = 875, delay = 0.25, radius = 70, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["LeonaSolarFlare"] = {icon = Icons.."LeonaR"..Png, displayName = "Solar Flare", slot = _R, type = "circular", speed = MathHuge, range = 1200, delay = 0.85, radius = 300, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Lissandra"] = {
		["LissandraQMissile"] = {icon = Icons.."LissandraQ"..Png, displayName = "Ice Shard", missileName = "LissandraQMissile", slot = _Q, type = "linear", speed = 2200, range = 750, delay = 0.25, radius = 75, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["LissandraEMissile"] = {icon = Icons.."LissandraE"..Png, displayName = "Glacial Path", missileName = "LissandraEMissile", slot = _E, type = "linear", speed = 850, range = 1025, delay = 0.25, radius = 125, danger = 2, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Lucian"] = {
		["LucianQ"] = {icon = Icons.."LucianQ"..Png, displayName = "Piercing Light", slot = _Q, type = "linear", speed = MathHuge, range = 900, delay = 0.35, radius = 65, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["LucianW"] = {icon = Icons.."LucianW"..Png, displayName = "Ardent Blaze", missileName = "LucianW", slot = _W, type = "linear", speed = 1600, range = 900, delay = 0.25, radius = 80, danger = 2, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Lulu"] = {
		["LuluQ"] = {icon = Icons.."LuluQ"..Png, displayName = "Glitterlance", missileName = "LuluQMissile", slot = _Q, type = "linear", speed = 1450, range = 925, delay = 0.25, radius = 60, danger = 1, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Lux"] = {
		["LuxLightBinding"] = {icon = Icons.."LuxQ"..Png, displayName = "Light Binding", missileName = "LuxLightBindingDummy", slot = _Q, type = "linear", speed = 1200, range = 1175, delay = 0.25, radius = 70, danger = 1, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["LuxLightStrikeKugel"] = {icon = Icons.."LuxE"..Png, displayName = "Light Strike Kugel", missileName = "LuxLightStrikeKugel", slot = _E, type = "circular", speed = 1200, range = 1100, delay = 0.25, radius = 300, danger = 3, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["LuxMaliceCannon"] = {icon = Icons.."LuxR"..Png, displayName = "Malice Cannon", missileName = "LuxRVfxMis", slot = _R, type = "linear", speed = MathHuge, range = 3340, delay = 1, radius = 120, danger = 4, cc = false, collision = false, windwall = false, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Malphite"] = {
		["Landslide"] = {icon = Icons.."MalphiteE"..Png, displayName = "Ground Slam", slot = _E, type = "circular", speed = MathHuge, range = 0, delay = 0.242, radius = 400, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		--["UFSlash"] = {icon = Icons.."MalphiteR"..Png, displayName = "Unstoppable Force", slot = _R, type = "circular", speed = 1835, range = 1000, delay = 0, radius = 300, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Malzahar"] = {
		["MalzaharQ"] = {icon = Icons.."MalzaharQ"..Png, displayName = "Call of the Void", slot = _Q, type = "rectangular", speed = 1600, range = 900, delay = 0.5, radius = 100, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Maokai"] = {
		["MaokaiQ"] = {icon = Icons.."MaokaiQ"..Png, displayName = "Bramble Smash", missileName = "MaokaiQMissile", slot = _Q, type = "linear", speed = 1600, range = 600, delay = 0.375, radius = 110, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["MissFortune"] = {
		["MissFortuneBulletTime"] = {icon = Icons.."MissFortuneR"..Png, displayName = "Bullet Time", slot = _R, type = "conic", speed = 2000, range = 1400, delay = 0.25, radius = 100, angle = 34, danger = 4, cc = false, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Mordekaiser"] = {
		["MordekaiserQ"] = {icon = Icons.."MordekaiserQ"..Png, displayName = "Obliterate", slot = _Q, type = "polygon", speed = MathHuge, range = 675, delay = 0.4, radius = 200, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["MordekaiserE"] = {icon = Icons.."MordekaiserE"..Png, displayName = "Death's Grasp", slot = _E, type = "polygon", speed = MathHuge, range = 900, delay = 0.9, radius = 140, danger = 3, cc = true, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = false},
	},
	["Morgana"] = {
		["MorganaQ"] = {icon = Icons.."MorganaQ"..Png, displayName = "Dark Binding", missileName = "MorganaQ", slot = _Q, type = "linear", speed = 1200, range = 1250, delay = 0.25, radius = 70, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Nami"] = {
		["NamiQ"] = {icon = Icons.."NamiQ"..Png, displayName = "Aqua Prison", missileName = "NamiQMissile", slot = _Q, type = "circular", speed = MathHuge, range = 875, delay = 1, radius = 180, danger = 1, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["NamiRMissile"] = {icon = Icons.."NamiR"..Png, displayName = "Tidal Wave", missileName = "NamiRMissile", slot = _R, type = "linear", speed = 850, range = 2750, delay = 0.5, radius = 250, danger = 3, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Nautilus"] = {
		["NautilusAnchorDragMissile"] = {icon = Icons.."NautilusQ"..Png, displayName = "Dredge Line", missileName = "NautilusAnchorDragMissile", slot = _Q, type = "linear", speed = 2000, range = 925, delay = 0.25, radius = 90, danger = 3, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Neeko"] = {
		["NeekoQ"] = {icon = Icons.."NeekoQ"..Png, displayName = "Blooming Burst", missileName = "NeekoQ", slot = _Q, type = "circular", speed = 1500, range = 800, delay = 0.25, radius = 200, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["NeekoE"] = {icon = Icons.."NeekoE"..Png, displayName = "Tangle-Barbs", missileName = "NeekoE", slot = _E, type = "linear", speed = 1300, range = 1000, delay = 0.25, radius = 70, danger = 1, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Nidalee"] = {
		["JavelinToss"] = {icon = Icons.."NidaleeQ"..Png, displayName = "Javelin Toss", missileName = "JavelinToss", slot = _Q, type = "linear", speed = 1300, range = 1500, delay = 0.25, radius = 40, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["Bushwhack"] = {icon = Icons.."NidaleeW"..Png, displayName = "Bushwhack", slot = _W, type = "circular", speed = MathHuge, range = 900, delay = 1.25, radius = 85, danger = 1, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["Swipe"] = {icon = Icons.."NidaleeE"..Png, displayName = "Swipe", slot = _E, type = "conic", speed = MathHuge, range = 350, delay = 0.25, radius = 0, angle = 180, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Nocturne"] = {
		["NocturneDuskbringer"] = {icon = Icons.."NocturneQ"..Png, displayName = "Duskbringer", missileName = "NocturneDuskbringer", slot = _Q, type = "linear", speed = 1600, range = 1200, delay = 0.25, radius = 60, danger = 2, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Nunu"] = {
		["NunuR"] = {icon = Icons.."NunuR"..Png, displayName = "Absolute Zero", slot = _R, type = "circular", speed = MathHuge, range = 0, delay = 3, radius = 650, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Olaf"] = {
		["OlafAxeThrowCast"] = {icon = Icons.."OlafQ"..Png, displayName = "Undertow", missileName = "OlafAxeThrow", slot = _Q, type = "linear", speed = 1600, range = 1000, delay = 0.25, radius = 90, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = false},
	},
	["Orianna"] = {
		["OrianaIzuna"] = {icon = Icons.."OriannaQ"..Png, displayName = "Command: Attack", missileName = "OrianaIzuna", slot = _Q, type = "polygon", speed = 1400, range = 825, radius = 80, danger = 2, cc = false, collision = false, windwall = false, fow = true, exception = true, extend = false},
	},
	["Ornn"] = {
		["OrnnQ"] = {icon = Icons.."OrnnQ"..Png, displayName = "Volcanic Rupture", slot = _Q, type = "linear", speed = 1800, range = 800, delay = 0.3, radius = 65, danger = 1, cc = true, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
		["OrnnE"] = {icon = Icons.."OrnnE"..Png, displayName = "Searing Charge", slot = _E, type = "linear", speed = 1600, range = 800, delay = 0.35, radius = 150, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["OrnnRCharge"] = {icon = Icons.."OrnnR"..Png, displayName = "Call of the Forge God", slot = _R, type = "linear", speed = 1650, range = 2500, delay = 0.5, radius = 200, danger = 3, cc = true, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
	},
	["Pantheon"] = {
		["PantheonQTap"] = {icon = Icons.."PantheonQ"..Png, displayName = "Comet Spear [Melee]", slot = _Q, type = "linear", speed = MathHuge, range = 575, delay = 0.25, radius = 80, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["PantheonQMissile"] = {icon = Icons.."PantheonQ"..Png, displayName = "Comet Spear [Range]", missileName = "PantheonQMissile", slot = _Q, type = "linear", speed = 2700, range = 1200, delay = 0.25, radius = 60, danger = 2, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["PantheonR"] = {icon = Icons.."PantheonR"..Png, displayName = "Grand Starfall", slot = _R, type = "linear", speed = 2250, range = 1350, delay = 4, radius = 250, danger = 3, cc = false, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = false},
	},
	["Poppy"] = {
		["PoppyQSpell"] = {icon = Icons.."PoppyQ"..Png, displayName = "Hammer Shock", slot = _Q, type = "linear", speed = MathHuge, range = 430, delay = 0.332, radius = 100, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["PoppyRSpell"] = {icon = Icons.."PoppyR"..Png, displayName = "Keeper's Verdict", missileName = "PoppyRMissile", slot = _R, type = "linear", speed = 2000, range = 1200, delay = 0.33, radius = 100, danger = 3, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Pyke"] = {
		["PykeQMelee"] = {icon = Icons.."PykeQ"..Png, displayName = "Bone Skewer [Melee]", slot = _Q, type = "linear", speed = MathHuge, range = 400, delay = 0.25, radius = 70, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["PykeQRange"] = {icon = Icons.."PykeQ"..Png, displayName = "Bone Skewer [Range]", missileName = "PykeQRange", slot = _Q, type = "linear", speed = 2000, range = 1100, delay = 0.2, radius = 70, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["PykeE"] = {icon = Icons.."PykeE"..Png, displayName = "Phantom Undertow", slot = _E, type = "linear", speed = 3000, range = 12500, delay = 0, radius = 110, danger = 2, cc = true, collision = false, windwall = false, hitbox = true, fow = false, exception = false, extend = true},
		["PykeR"] = {icon = Icons.."PykeR"..Png, displayName = "Death from Below", slot = _R, type = "circular", speed = MathHuge, range = 750, delay = 0.5, radius = 100, danger = 5, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Qiyana"] = {
		["QiyanaQ"] = {icon = Icons.."QiyanaQ"..Png, displayName = "Edge of Ixtal", slot = _Q, type = "linear", speed = MathHuge, range = 500, delay = 0.25, radius = 60, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["QiyanaQ_Grass"] = {icon = Icons.."QiyanaQGrass"..Png, displayName = "Edge of Ixtal [Grass]", slot = _Q, type = "linear", speed = 1600, range = 925, delay = 0.25, radius = 70, danger = 2, cc = false, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
		["QiyanaQ_Rock"] = {icon = Icons.."QiyanaQRock"..Png, displayName = "Edge of Ixtal [Rock]", slot = _Q, type = "linear", speed = 1600, range = 925, delay = 0.25, radius = 70, danger = 2, cc = false, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
		["QiyanaQ_Water"] = {icon = Icons.."QiyanaQWater"..Png, displayName = "Edge of Ixtal [Water]", slot = _Q, type = "linear", speed = 1600, range = 925, delay = 0.25, radius = 70, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
		["QiyanaR"] = {icon = Icons.."QiyanaR"..Png, displayName = "Supreme Display of Talent", slot = _R, type = "linear", speed = 2000, range = 950, delay = 0.25, radius = 190, danger = 4, cc = true, collision = false, windwall = true, hitbox = true, fow = false, exception = false, extend = true},
	},
	["Quinn"] = {
		["QuinnQ"] = {icon = Icons.."QuinnQ"..Png, displayName = "Blinding Assault", missileName = "QuinnQ", slot = _Q, type = "linear", speed = 1550, range = 1025, delay = 0.25, radius = 60, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Rakan"] = {
		["RakanQ"] = {icon = Icons.."RakanQ"..Png, displayName = "Gleaming Quill", missileName = "RakanQMis", slot = _Q, type = "linear", speed = 1850, range = 850, delay = 0.25, radius = 65, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["RakanW"] = {icon = Icons.."RakanW"..Png, displayName = "Grand Entrance", slot = _W, type = "circular", speed = MathHuge, range = 650, delay = 0.7, radius = 265, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["RekSai"] = {
		["RekSaiQBurrowed"] = {icon = Icons.."RekSaiQ"..Png, displayName = "Prey Seeker", missileName = "RekSaiQBurrowedMis", slot = _Q, type = "linear", speed = 1950, range = 1625, delay = 0.125, radius = 65, danger = 2, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Rell"] = {
		["RellQ"] = {icon = Icons.."RellQ"..Png, displayName = "Shattering Strike", slot = _Q, speed = MathHuge, range = 700, delay = 0.35, radius = 80, danger = 2, cc = false, collision = false, windwall = false, hitbox = true, fow = false, exception = false, extend = true},
		["RellR"] = {icon = Icons.."RellR"..Png, displayName = "Magnet Storm", slot = _R, speed = MathHuge, range = 0, delay = 0.25, radius = 400, danger = 5, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	--["Renekton"] = {
	--	["RenektonSliceAndDice"] = {icon = Icons.."RenektonE"..Png, displayName = "Slice and Dice", slot = _E, type = "linear", speed = 1125, range = 450, delay = 0.25, radius = 65, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	--},
	["Rengar"] = {
		["RengarE"] = {icon = Icons.."RengarE"..Png, displayName = "Bola Strike", missileName = "RengarEMis", slot = _E, type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Riven"] = {
		["RivenIzunaBlade"] = {icon = Icons.."RivenR"..Png, displayName = "Wind Slash", slot = _R, type = "conic", speed = 1600, range = 900, delay = 0.25, radius = 0, angle = 75, danger = 5, cc = false, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Rumble"] = {
		["RumbleGrenade"] = {icon = Icons.."RumbleE"..Png, displayName = "Electro Harpoon", missileName = "RumbleGrenadeMissile", slot = _E, type = "linear", speed = 2000, range = 850, delay = 0.25, radius = 60, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Ryze"] = {
		["RyzeQ"] = {icon = Icons.."RyzeQ"..Png, displayName = "Overload", missileName = "RyzeQ", slot = _Q, type = "linear", speed = 1700, range = 1000, delay = 0.25, radius = 55, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Semira"] = {
		["SemiraQGun"] = {icon = Icons.."SemiraQ"..Png, displayName = "Flair", missileName = "SamiraQGun", slot = _Q, type = "linear", speed = 2600, range = 1000, delay = 0.25, radius = 60, danger = 1, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Sejuani"] = {
		["SejuaniR"] = {icon = Icons.."SejuaniR"..Png, displayName = "Glacial Prison", missileName = "SejuaniRMissile", slot = _R, type = "linear", speed = 1600, range = 1300, delay = 0.25, radius = 120, danger = 5, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Senna"] = {
		["SennaQCast"] = {icon = Icons.."SennaQ"..Png, displayName = "Piercing Darkness", slot = _Q, type = "linear", speed = MathHuge, range = 1400, delay = 0.4, radius = 80, danger = 2, cc = false, collision = false, windwall = false, hitbox = true, fow = false, exception = false, extend = true},
		["SennaW"] = {icon = Icons.."SennaW"..Png, displayName = "Last Embrace", missileName = "SennaW", slot = _W, type = "linear", speed = 1150, range = 1300, delay = 0.25, radius = 60, danger = 1, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["SennaR"] = {icon = Icons.."SennaR"..Png, displayName = "Dawning Shadow", missileName = "SennaRWarningMis", slot = _R, type = "linear", speed = 20000, range = 12500, delay = 1, radius = 180, danger = 4, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Seraphine"] = {
		["SeraphineQCast"] = {icon = Icons.."SeraphineQ"..Png, displayName = "High Note", missileName = "SeraphineQInitialMissile", slot = _Q, type = "circular", speed = 1200, range = 900, delay = 0.25, radius = 350, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["SeraphineECast"] = {icon = Icons.."SeraphineE"..Png, displayName = "Beat Drop", missileName = "SeraphineEMissile", slot = _E, type = "linear", speed = 1200, range = 1300, delay = 0.25, radius = 70, danger = 1, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["SeraphineR"] = {icon = Icons.."SeraphineR"..Png, displayName = "Encore", missileName = "SeraphineR", slot = _R, type = "linear", speed = 1600, range = 1300, delay = 0.5, radius = 160, danger = 3, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Sett"] = {
		["SettW"] = {icon = Icons.."SettW"..Png, displayName = "Haymaker", slot = _W, type = "polygon", speed = MathHuge, range = 790, delay = 0.75, radius = 160, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["SettE"] = {icon = Icons.."SettE"..Png, displayName = "Facebreaker", slot = _E, type = "polygon", speed = MathHuge, range = 490, delay = 0.25, radius = 175, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	--["Shen"] = {
	--	["ShenE"] = {icon = Icons.."ShenE"..Png, displayName = "Shadow Dash", slot = _E, type = "linear", speed = 1200, range = 600, delay = 0, radius = 60, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	--},
	["Shyvana"] = {
		["ShyvanaFireball"] = {icon = Icons.."ShyvanaE"..Png, displayName = "Flame Breath [Standard]", missileName = "ShyvanaFireballMissile", slot = _E, type = "linear", speed = 1575, range = 925, delay = 0.25, radius = 60, danger = 1, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["ShyvanaFireballDragon2"] = {icon = Icons.."ShyvanaE"..Png, displayName = "Flame Breath [Dragon]", missileName = "ShyvanaFireballDragonMissile", slot = _E, type = "linear", speed = 1575, range = 975, delay = 0.333, radius = 60, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["ShyvanaTransformLeap"] = {icon = Icons.."ShyvanaR"..Png, displayName = "Transform Leap", slot = _R, type = "linear", speed = 700, range = 850, delay = 0.25, radius = 150, danger = 4, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Sion"] = {
		["SionQ"] = {icon = Icons.."SionQ"..Png, displayName = "Decimating Smash", slot = _Q, type = "linear", speed = MathHuge, range = 750, delay = 2, radius = 150, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["SionE"] = {icon = Icons.."SionE"..Png, displayName = "Roar of the Slayer", missileName = "SionEMissile", slot = _E, type = "linear", speed = 1800, range = 800, delay = 0.25, radius = 80, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Sivir"] = {
		["SivirQ"] = {icon = Icons.."SivirQ"..Png, displayName = "Boomerang Blade", missileName = "SivirQMissile", slot = _Q, type = "linear", speed = 1350, range = 1250, delay = 0.25, radius = 90, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Skarner"] = {
		["SkarnerFractureMissile"] = {icon = Icons.."SkarnerE"..Png, displayName = "Fracture", missileName = "SkarnerFractureMissile", slot = _E, type = "linear", speed = 1500, range = 1000, delay = 0.25, radius = 70, danger = 1, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Sona"] = {
		["SonaR"] = {icon = Icons.."SonaR"..Png, displayName = "Crescendo", missileName = "SonaRMissile", slot = _R, type = "linear", speed = 2400, range = 1000, delay = 0.25, radius = 140, danger = 5, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Soraka"] = {
		["SorakaQ"] = {icon = Icons.."SorakaQ"..Png, displayName = "Starcall", missileName = "SorakaQMissile", slot = _Q, type = "circular", speed = 1150, range = 810, delay = 0.25, radius = 235, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = true, exception = false, extend = false},
	},
	["Swain"] = {
		["SwainQ"] = {icon = Icons.."SwainQ"..Png, displayName = "Death's Hand", slot = _Q, type = "conic", speed = 5000, range = 725, delay = 0.25, radius = 0, angle = 60, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
		["SwainW"] = {icon = Icons.."SwainW"..Png, displayName = "Vision of Empire", slot = _W, type = "circular", speed = MathHuge, range = 3500, delay = 1.5, radius = 300, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["SwainE"] = {icon = Icons.."SwainE"..Png, displayName = "Nevermove", slot = _E, type = "linear", speed = 1800, range = 850, delay = 0.25, radius = 85, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Sylas"] = {
		["SylasQ"] = {icon = Icons.."SylasQ"..Png, displayName = "Chain Lash", slot = _Q, type = "polygon", speed = MathHuge, range = 775, delay = 0.4, radius = 45, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["SylasE2"] = {icon = Icons.."SylasE"..Png, displayName = "Abduct", missileName = "SylasE2Mis", slot = _E, type = "linear", speed = 1600, range = 850, delay = 0.25, radius = 60, danger = 2, cc = true, collision = true, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Syndra"] = {
		["SyndraQSpell"] = {icon = Icons.."SyndraQ"..Png, displayName = "Dark Sphere", missileName = "SyndraQSpell", slot = _Q, type = "circular", speed = MathHuge, range = 800, delay = 0.625, radius = 200, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = true, exception = true, extend = false},
		--["SyndraWCast"] = {icon = Icons.."SyndraW"..Png, displayName = "Force of Will", slot = _W, type = "circular", speed = 1450, range = 950, delay = 0.25, radius = 225, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["SyndraE"] = {icon = Icons.."SyndraE"..Png, displayName = "Scatter the Weak [Standard]", slot = _E, type = "conic", speed = 1600, range = 700, delay = 0.25, radius = 0, angle = 40, danger = 3, cc = true, collision = false, windwall = true, hitbox = false, fow = false, exception = false, extend = true},
		["SyndraESphereMissile"] = {icon = Icons.."SyndraQ"..Png, displayName = "Scatter the Weak [Sphere]", missileName = "SyndraESphereMissile", slot = _E, type = "linear", speed = 2000, range = 1250, delay = 0.25, radius = 100, danger = 3, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = true, extend = false},
	},
	["TahmKench"] = {
		["TahmKenchQ"] = {icon = Icons.."TahmKenchQ"..Png, displayName = "Tongue Lash", missileName = "TahmKenchQMissile", slot = _Q, type = "linear", speed = 2800, range = 900, delay = 0.25, radius = 70, danger = 2, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Taliyah"] = {
		["TaliyahQMis"] = {icon = Icons.."TaliyahQ"..Png, displayName = "Threaded Volley", missileName = "TaliyahQMis", slot = _Q, type = "linear", speed = 3600, range = 1000, radius = 100, danger = 2, cc = false, collision = true, windwall = true, fow = true, exception = true, extend = true},
		["TaliyahWVC"] = {icon = Icons.."TaliyahW"..Png, displayName = "Seismic Shove", slot = _W, type = "circular", speed = MathHuge, range = 900, delay = 0.85, radius = 150, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["TaliyahE"] = {icon = Icons.."TaliyahE"..Png, displayName = "Unraveled Earth", slot = _E, type = "conic", speed = 2000, range = 800, delay = 0.45, radius = 0, angle = 80, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["TaliyahR"] = {icon = Icons.."TaliyahR"..Png, displayName = "Weaver's Wall", missileName = "TaliyahRMis", slot = _R, type = "linear", speed = 1700, range = 3000, delay = 1, radius = 120, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Talon"] = {
		["TalonW"] = {icon = Icons.."TalonW"..Png, displayName = "Rake", missileName = "TalonWMissileOne", slot = _W, type = "conic", speed = 2500, range = 650, delay = 0.25, radius = 75, angle = 26, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Thresh"] = {
		["ThreshQ"] = {icon = Icons.."ThreshQ"..Png, displayName = "Death Sentence", missileName = "ThreshQMissile", slot = _Q, type = "linear", speed = 1900, range = 1100, delay = 0.5, radius = 70, danger = 1, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = true, extend = true},
		["ThreshEFlay"] = {icon = Icons.."ThreshE"..Png, displayName = "Flay", slot = _E, type = "polygon", speed = MathHuge, range = 500, delay = 0.389, radius = 110, danger = 3, cc = true, collision = true, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Tristana"] = {
		["TristanaW"] = {icon = Icons.."TristanaW"..Png, displayName = "Rocket Jump", slot = _W, type = "circular", speed = 1100, range = 900, delay = 0.25, radius = 300, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Tryndamere"] = {
		["TryndamereE"] = {icon = Icons.."TryndamereE"..Png, displayName = "Spinning Slash", slot = _E, type = "linear", speed = 1300, range = 660, delay = 0, radius = 225, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["TwistedFate"] = {
		["WildCards"] = {icon = Icons.."TwistedFateQ"..Png, displayName = "Wild Cards", missileName = "SealFateMissile", slot = _Q, type = "threeway", speed = 1000, range = 1450, delay = 0.25, radius = 40, angle = 28, danger = 1, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Urgot"] = {
		["UrgotQ"] = {icon = Icons.."UrgotQ"..Png, displayName = "Corrosive Charge", missileName = "UrgotQMissile", slot = _Q, type = "circular", speed = MathHuge, range = 800, delay = 0.6, radius = 180, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["UrgotE"] = {icon = Icons.."UrgotE"..Png, displayName = "Disdain", slot = _E, type = "linear", speed = 1540, range = 475, delay = 0.45, radius = 100, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["UrgotR"] = {icon = Icons.."UrgotR"..Png, displayName = "Fear Beyond Death", missileName = "UrgotR", slot = _R, type = "linear", speed = 3200, range = 1600, delay = 0.5, radius = 80, danger = 4, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Varus"] = {
		["VarusQMissile"] = {icon = Icons.."VarusQ"..Png, displayName = "Piercing Arrow", missileName = "VarusQMissile", slot = _Q, type = "linear", speed = 1900, range = 1525, radius = 70, danger = 1, cc = false, collision = false, windwall = true, fow = true, exception = true, extend = true},
		["VarusE"] = {icon = Icons.."VarusE"..Png, displayName = "Hail of Arrows", missileName = "VarusEMissile", slot = _E, type = "circular", speed = 1500, range = 925, delay = 0.242, radius = 260, danger = 3, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["VarusR"] = {icon = Icons.."VarusR"..Png, displayName = "Chain of Corruption", missileName = "VarusRMissile", slot = _R, type = "linear", speed = 1500, range = 1200, delay = 0.25, radius = 120, danger = 4, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Veigar"] = {
		["VeigarBalefulStrike"] = {icon = Icons.."VeigarQ"..Png, displayName = "Baleful Strike", missileName = "VeigarBalefulStrikeMis", slot = _Q, type = "linear", speed = 2200, range = 900, delay = 0.25, radius = 70, danger = 2, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["VeigarDarkMatter"] = {icon = Icons.."VeigarW"..Png, displayName = "Dark Matter", slot = _W, type = "circular", speed = MathHuge, range = 900, delay = 1.25, radius = 200, danger = 1, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Velkoz"] = {
		["VelkozQMissileSplit"] = {icon = Icons.."VelkozQ2"..Png, displayName = "Plasma Fission [Split]", missileName = "VelkozQMissileSplit", slot = _Q, type = "linear", speed = 2100, range = 1100, radius = 45, danger = 2, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = true, extend = false},
		["VelkozQ"] = {icon = Icons.."VelkozQ"..Png, displayName = "Plasma Fission", missileName = "VelkozQMissile", slot = _Q, type = "linear", speed = 1300, range = 1050, delay = 0.25, radius = 50, danger = 1, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["VelkozW"] = {icon = Icons.."VelkozW"..Png, displayName = "Void Rift", missileName = "VelkozWMissile", slot = _W, type = "linear", speed = 1700, range = 1050, delay = 0.25, radius = 87.5, danger = 1, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["VelkozE"] = {icon = Icons.."VelkozE"..Png, displayName = "Tectonic Disruption", slot = _E, type = "circular", speed = MathHuge, range = 800, delay = 0.8, radius = 185, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
	["Vi"] = {
		["ViQ"] = {icon = Icons.."ViQ"..Png, displayName = "Vault Breaker", slot = _Q, type = "linear", speed = 1500, range = 725, delay = 0, radius = 90, danger = 2, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Viego"] = {
		["ViegoW"] = {icon = Icona2, displayName = "Spectral Maw", missileName = "ViegoWMissile", slot = _W, type = "linear", speed = 1300, range = 760, delay = 0, radius = 90, danger = 3, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Viktor"] = {
		["ViktorGravitonField"] = {icon = Icons.."ViktorW"..Png, displayName = "Graviton Field", slot = _W, type = "circular", speed = MathHuge, range = 800, delay = 1.75, radius = 270, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["ViktorDeathRayMissile"] = {icon = Icons.."ViktorE"..Png, displayName = "Death Ray", missileName = "ViktorDeathRayMissile", slot = _E, type = "linear", speed = 1050, range = 700, radius = 80, danger = 2, cc = false, collision = false, windwall = true, fow = true, exception = true, extend = true},
	},
	--["Vladimir"] = {
	--	["VladimirHemoplague"] = {icon = Icons.."VladimirR"..Png, displayName = "Hemoplague", slot = _R, type = "circular", speed = MathHuge, range = 700, delay = 0.389, radius = 350, danger = 3, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	--},
	["Warwick"] = {
		["WarwickR"] = {icon = Icons.."WarwickR"..Png, displayName = "Infinite Duress", slot = _R, type = "linear", speed = 1800, range = 3000, delay = 0.1, radius = 55, danger = 4, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Xayah"] = {
		["XayahQ"] = {icon = Icons.."XayahQ"..Png, displayName = "Double Daggers", missileName = "XayahQ", slot = _Q, type = "linear", speed = 2075, range = 1100, delay = 0.5, radius = 45, danger = 1, cc = false, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Xerath"] = {
		--["XerathArcanopulse2"] = {icon = Icons.."XerathQ"..Png, displayName = "Arcanopulse", slot = _Q, type = "linear", speed = MathHuge, range = 1400, delay = 0.5, radius = 90, danger = 2, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["XerathArcaneBarrage2"] = {icon = Icons.."XerathW"..Png, displayName = "Arcane Barrage", slot = _W, type = "circular", speed = MathHuge, range = 1000, delay = 0.75, radius = 235, danger = 3, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["XerathMageSpear"] = {icon = Icons.."XerathE"..Png, displayName = "Mage Spear", missileName = "XerathMageSpearMissile", slot = _E, type = "linear", speed = 1400, range = 1050, delay = 0.2, radius = 60, danger = 1, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["XerathLocusPulse"] = {icon = Icons.."XerathR"..Png, displayName = "Rite of the Arcane", missileName = "XerathLocusPulse", slot = _R, type = "circular", speed = MathHuge, range = 5000, delay = 0.7, radius = 200, danger = 3, cc = false, collision = false, windwall = false, hitbox = false, fow = true, exception = true, extend = false},
	},
	["XinZhao"] = {
		["XinZhaoW"] = {icon = Icons.."XinZhaoW"..Png, displayName = "Wind Becomes Lightning", slot = _W, type = "linear", speed = 5000, range = 900, delay = 0.5, radius = 40, danger = 1, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
	},
	["Yasuo"] = {
		["YasuoQ1"] = {icon = Icons.."YasuoQ1"..Png, displayName = "Steel Tempest", slot = _Q, type = "linear", speed = MathHuge, range = 450, delay = 0.25, radius = 40, danger = 1, cc = false, collision = false, windwall = false, hitbox = true, fow = false, exception = false, extend = true},
		["YasuoQ2"] = {icon = Icons.."YasuoQ2"..Png, displayName = "Steel Wind Rising", slot = _Q, type = "linear", speed = MathHuge, range = 450, delay = 0.25, radius = 40, danger = 1, cc = false, collision = false, windwall = false, hitbox = true, fow = false, exception = false, extend = true},
		["YasuoQ3"] = {icon = Icons.."YasuoQ3"..Png, displayName = "Gathering Storm", missileName = "YasuoQ3Mis", slot = _Q, type = "linear", speed = 1200, range = 1000, delay = 0.25, radius = 90, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
	},
	["Yone"] = {
		["YoneQ"] = {icon = Icons.."YoneQ"..Png, displayName = "Mortal Steel [Sword]", slot = _Q, type = "linear", speed = MathHuge, range = 450, delay = 0.25, radius = 40, danger = 1, cc = false, collision = false, windwall = false, hitbox = true, fow = false, exception = false, extend = true},
		["YoneQ3"] = {icon = Icons.."YoneQ3"..Png, displayName = "Mortal Steel [Storm]", missileName = "YoneQ3Missile", slot = _Q, type = "linear", speed = 1500, range = 1050, delay = 0.25, radius = 80, danger = 2, cc = true, collision = false, windwall = true, hitbox = true, fow = true, exception = false, extend = true},
		["YoneW"] = {icon = Icons.."YoneW"..Png, displayName = "Spirit Cleave", slot = _W, type = "conic", speed = MathHuge, range = 600, delay = 0.375, radius = 0, angle = 80, danger = 1, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = true},
		["YoneR"] = {icon = Icons.."YoneR"..Png, displayName = "Fate Sealed", slot = _R, type = "linear", speed = MathHuge, range = 1000, delay = 0.75, radius = 112.5, danger = 5, cc = true, collision = false, windwall = false, hitbox = true, fow = false, exception = false, extend = true},
	},
	["Zac"] = {
		["ZacQ"] = {icon = Icons.."ZacQ"..Png, displayName = "Stretching Strikes", missileName = "ZacQMissile", slot = _Q, type = "linear", speed = 2800, range = 800, delay = 0.33, radius = 120, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		--ZacE
	},
	["Zed"] = {
		["ZedQ"] = {icon = Icons.."ZedQ"..Png, displayName = "Razor Shuriken", missileName = "ZedQMissile", slot = _Q, type = "linear", speed = 1700, range = 900, delay = 0.25, radius = 50, danger = 1, cc = false, collision = false, windwall = true, hitbox = true, fow = true, exception = true, extend = true},
	},
	["Zeri"] = {
		["ZeriQ"] = {icon = Icona1, displayName = "Burst Fire", missileName = "ZeriQMissile", slot = _Q, type = "linear", speed = 1500, range = 840, delay = 0.25, radius = 80, danger = 2, cc = false, collision = true, windwall = true, hitbox = true, fow = true, exception = true, extend = true},
	},
	["Ziggs"] = {
		["ZiggsQ"] = {icon = Icons.."ZiggsQ"..Png, displayName = "Bouncing Bomb", missileName = "ZiggsQSpell", slot = _Q, type = "polygon", speed = 1750, range = 850, delay = 0.25, radius = 150, danger = 1, cc = false, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["ZiggsW"] = {icon = Icons.."ZiggsW"..Png, displayName = "Satchel Charge", missileName = "ZiggsW", slot = _W, type = "circular", speed = 1750, range = 1000, delay = 0.25, radius = 240, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["ZiggsE"] = {icon = Icons.."ZiggsE"..Png, displayName = "Hexplosive Minefield", missileName = "ZiggsE", slot = _E, type = "circular", speed = 1800, range = 900, delay = 0.25, radius = 250, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
		["ZiggsR"] = {icon = Icons.."ZiggsR"..Png, displayName = "Mega Inferno Bomb", missileName = "ZiggsRBoom", slot = _R, type = "circular", speed = 1550, range = 5000, delay = 0.375, radius = 480, danger = 4, cc = false, collision = false, windwall = false, hitbox = false, fow = true, exception = false, extend = false},
	},
	["Zilean"] = {
		["ZileanQ"] = {icon = Icons.."ZileanQ"..Png, displayName = "Time Bomb", missileName = "ZileanQMissile", slot = _Q, type = "circular", speed = MathHuge, range = 900, delay = 0.8, radius = 150, danger = 2, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = false},
	},
	["Zoe"] = {
		["ZoeQMissile"] = {icon = Icons.."ZoeQ1"..Png, displayName = "Paddle Star [First]", missileName = "ZoeQMissile", slot = _Q, type = "linear", speed = 1200, range = 800, delay = 0.25, radius = 50, danger = 1, cc = false, collision = true, windwall = true, hitbox = false, fow = true, exception = true, extend = true},
		["ZoeQMis2"] = {icon = Icons.."ZoeQ2"..Png, displayName = "Paddle Star [Second]", missileName = "ZoeQMis2", slot = _Q, type = "linear", speed = 2500, range = 1600, delay = 0, radius = 70, danger = 2, cc = false, collision = true, windwall = true, hitbox = false, fow = true, exception = true, extend = true},
		["ZoeE"] = {icon = Icons.."ZoeE"..Png, displayName = "Sleepy Trouble Bubble", missileName = "ZoeEMis", slot = _E, type = "linear", speed = 1700, range = 800, delay = 0.3, radius = 50, danger = 2, cc = true, collision = true, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
	},
	["Zyra"] = {
		["ZyraQ"] = {icon = Icons.."ZyraQ"..Png, displayName = "Deadly Spines", slot = _Q, type = "rectangular", speed = MathHuge, range = 800, delay = 0.825, radius = 200, danger = 1, cc = false, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
		["ZyraE"] = {icon = Icons.."ZyraE"..Png, displayName = "Grasping Roots", missileName = "ZyraE", slot = _E, type = "linear", speed = 1150, range = 1100, delay = 0.25, radius = 70, danger = 1, cc = true, collision = false, windwall = true, hitbox = false, fow = true, exception = false, extend = true},
		["ZyraR"] = {icon = Icons.."ZyraR"..Png, displayName = "Stranglethorns", slot = _R, type = "circular", speed = MathHuge, range = 700, delay = 2, radius = 500, danger = 4, cc = true, collision = false, windwall = false, hitbox = false, fow = false, exception = false, extend = false},
	},
}

local EvadeSpells = {
	["Ahri"] = {
		[3] = {icon = Icons.."AhriR"..Png, type = 1, displayName = "Spirit Rush", name = "AhriQ-", danger = 4, range = 450, slot = _R, slot2 = HK_R},
	},
	["Annie"] = {
		[2] = {icon = Icons.."AnnieE"..Png, type = 2, displayName = "Molten Shield", name = "AnnieE-", danger = 2, slot = _E, slot2 = HK_E},
	},
	["Blitzcrank"] = {
		[1] = {icon = Icons.."BlitzcrankW"..Png, type = 2, displayName = "Overdrive", name = "BlitzcrankW-", danger = 3, slot = _W, slot2 = HK_W},
	},
	["Corki"] = {
		[1] = {icon = Icons.."CorkiW"..Png, type = 1, displayName = "Valkyrie", name = "CorkiW-", danger = 4, range = 600, slot = _W, slot2 = HK_W},
	},
	["Draven"] = {
		[1] = {icon = Icons.."DravenW"..Png, type = 2, displayName = "Blood Rush", name = "DravenW-", danger = 3, slot = _W, slot2 = HK_W},
	},
	["Ekko"] = {
		[2] = {icon = Icons.."EkkoE"..Png, type = 1, displayName = "Phase Dive", name = "EkkoE-", danger = 2, range = 325, slot = _E, slot2 = HK_E},
	},
	["Ezreal"] = {
		[2] = {icon = Icons.."EzrealE"..Png, type = 1, displayName = "Arcane Shift", name = "EzrealE-", danger = 3, range = 475, slot = _E, slot2 = HK_E},
	},
	["Fiora"] = {
		[0] = {icon = Icons.."FioraQ"..Png, type = 1, displayName = "Lunge", name = "FioraQ-", danger = 1, range = 400, slot = _Q, slot2 = HK_Q},
		[1] = {icon = Icons.."FioraW"..Png, type = 7, displayName = "Riposte", name = "FioraW-", danger = 2, range = 750, slot = _W, slot2 = HK_W},
	},
	["Fizz"] = {
		[2] = {icon = Icons.."FizzR"..Png, type = 3, displayName = "Playful", name = "FizzE-", danger = 3, slot = _E, slot2 = HK_E},
	},
	["Garen"] = {
		[0] = {icon = Icons.."GarenQ"..Png, type = 2, displayName = "Decisive Strike", name = "GarenQ-", danger = 3, slot = _Q, slot2 = HK_Q},
	},
	["Gnar"] = {
		[2] = {icon = Icons.."GnarE"..Png, type = 1, displayName = "Hop/Crunch", name = "GnarE-", range = 475, danger = 3, slot = _E, slot2 = HK_E},
	},
	["Gragas"] = {
		[2] = {icon = Icons.."GragasE"..Png, type = 1, displayName = "Body Slam", name = "GragasE-", range = 600, danger = 3, slot = _E, slot2 = HK_E},
	},
	["Graves"] = {
		[2] = {icon = Icons.."GravesE"..Png, type = 1, displayName = "Quickdraw", name = "GravesE-", range = 425, danger = 1, slot = _E, slot2 = HK_E},
	},
	["Kaisa"] = {
		[2] = {icon = Icons.."KaisaE"..Png, type = 2, displayName = "Supercharge", name = "KaisaE-", danger = 2, slot = _E, slot2 = HK_E},
	},
	["Karma"] = {
		[2] = {icon = Icons.."KarmaE"..Png, type = 2, displayName = "Inspire", name = "KarmaE-", danger = 3, slot = _E, slot2 = HK_E},
	},
	["Kassadin"] = {
		[3] = {icon = Icons.."KassadinR"..Png, type = 1, displayName = "Riftwalk", name = "KassadinR-", range = 500, danger = 3, slot = _R, slot2 = HK_R},
	},
	["Katarina"] = {
		[1] = {icon = Icons.."KatarinaW"..Png, type = 2, displayName = "Preparation", name = "KatarinaW-", danger = 3, slot = _W, slot2 = HK_W},
	},
	["Kayn"] = {
		[0] = {icon = Icons.."KaynQ"..Png, type = 1, displayName = "Reaping Slash", name = "KaynQ-", danger = 2, slot = _Q, slot2 = HK_Q},
	},
	["Kennen"] = {
		[2] = {icon = Icons.."KennenE"..Png, type = 2, displayName = "Lightning Rush", name = "KennenE-", danger = 3, slot = _E, slot2 = HK_E},
	},
	["Khazix"] = {
		[2] = {icon = Icons.."KhazixE"..Png, type = 1, displayName = "Leap", name = "KhazixE-", range = 700, danger = 3, slot = _E, slot2 = HK_E},
	},
	["Kindred"] = {
		[0] = {icon = Icons.."KindredQ"..Png, type = 1, displayName = "Dance of Arrows", name = "KindredQ-", range = 340, danger = 1, slot = _Q, slot2 = HK_Q},
	},
	["Kled"] = {
		[2] = {icon = Icons.."KledE"..Png, type = 1, displayName = "Jousting", name = "KledE-", range = 550, danger = 3, slot = _E, slot2 = HK_E},
	},
	["Leblanc"] = {
		[1] = {icon = Icons.."LeblancW"..Png, type = 1, displayName = "Distortion", name = "LeblancW-", range = 600, danger = 3, slot = _W, slot2 = HK_W},
	},
	["Lucian"] = {
		[2] = {icon = Icons.."LucianE"..Png, type = 1, displayName = "Relentless Pursuit", name = "LucianE-", range = 425, danger = 3, slot = _E, slot2 = HK_E},
	},
	["MasterYi"] = {
		[0] = {icon = Icons.."MasterYiQ"..Png, type = 4, displayName = "Alpha Strike", name = "MasterYiQ-", range = 600, danger = 3, slot = _Q, slot2 = HK_Q},
	},
	["Morgana"] = {
		[2] = {icon = Icons.."MorganaE"..Png, type = 5, displayName = "Black Shield", name = "MorganaE-", danger = 2, slot = _E, slot2 = HK_E},
	},
	["Pyke"] = {
		[2] = {icon = Icons.."PykeE"..Png, type = 1, displayName = "Phantom Undertow", name = "PykeE-", range = 550, danger = 3, slot = _E, slot2 = HK_E},
	},
	["Rakan"] = {
		[1] = {icon = Icons.."RakanW"..Png, type = 1, displayName = "Grand Entrance", name = "RakanW-", range = 600, danger = 3, slot = _W, slot2 = HK_W},
	},
	["Renekton"] = {
		[2] = {icon = Icons.."RenektonE"..Png, type = 1, displayName = "Slice and Dice", name = "RenektonE-", range = 450, danger = 3, slot = _E, slot2 = HK_E},
	},
	["Riven"] = {
		[2] = {icon = Icons.."RivenE"..Png, type = 1, displayName = "Valor", name = "RivenE-", range = 325, danger = 2, slot = _E, slot2 = HK_E},
	},
	["Rumble"] = {
		[1] = {icon = Icons.."RumbleW"..Png, type = 2, displayName = "Scrap Shield", name = "RumbleW-", danger = 2, slot = _W, slot2 = HK_W},
	},
	["Sejuani"] = {
		[0] = {icon = Icons.."SejuaniQ"..Png, type = 1, displayName = "Arctic Assault", name = "SejuaniQ-", danger = 3, slot = _Q, slot2 = HK_Q},
	},
	["Shaco"] = {
		[0] = {icon = Icons.."ShacoQ"..Png, type = 1, displayName = "Deceive", name = "ShacoQ-", range = 400, danger = 3, slot = _Q, slot2 = HK_Q},
	},
	["Shen"] = {
		[2] = {icon = Icons.."ShenE"..Png, type = 1, displayName = "Shadow Dash", name = "ShenE-", range = 600, danger = 4, slot = _E, slot2 = HK_E},
	},
	["Shyvana"] = {
		[1] = {icon = Icons.."ShyvanaW"..Png, type = 2, displayName = "Burnout", name = "ShyvanaW-", danger = 3, slot = _W, slot2 = HK_W},
	},
	["Sivir"] = {
		[2] = {icon = Icons.."SivirE"..Png, type = 5, displayName = "Spell Shield", name = "SivirE-", danger = 2, slot = _E, slot2 = HK_E},
	},
	["Skarner"] = {
		[1] = {icon = Icons.."SkarnerW"..Png, type = 2, displayName = "Crystalline Exoskeleton", name = "SkarnerW-", danger = 3, slot = _W, slot2 = HK_W},
	},
	["Sona"] = {
		[2] = {icon = Icons.."SonaE"..Png, type = 2, displayName = "Song of Celerity", name = "SonaE-", danger = 3, slot = _E, slot2 = HK_E},
	},
	["Teemo"] = {
		[1] = {icon = Icons.."TeemoW"..Png, type = 2, displayName = "Move Quick", name = "TeemoW-", danger = 3, slot = _W, slot2 = HK_W},
	},
	["Tryndamere"] = {
		[2] = {icon = Icons.."TryndamereE"..Png, type = 1, displayName = "Spinning Slash", name = "TryndamereE-", range = 660, danger = 3, slot = _E, slot2 = HK_E},
	},
	["Udyr"] = {
		[2] = {icon = Icons.."UdyrE"..Png, type = 2, displayName = "Bear Stance", name = "UdyrE-", danger = 1, slot = _E, slot2 = HK_E},
	},
	["Vayne"] = {
		[0] = {icon = Icons.."VayneQ"..Png, type = 1, displayName = "Tumble", name = "VayneQ-", range = 300, danger = 2, slot = _Q, slot2 = HK_Q},
	},
	["Vi"] = {
		[0] = {icon = Icons.."ViQ"..Png, type = 1, displayName = "Vault Breaker", name = "ViQ-", range = 250, danger = 3, slot = _Q, slot2 = HK_Q},
	},
	["Vladimir"] = {
		[1] = {icon = Icons.."VladimirW"..Png, type = 3, displayName = "Sanguine Pool", name = "VladimirW-", danger = 3, slot = _W, slot2 = HK_W},
	},
	["Volibear"] = {
		[0] = {icon = Icons.."VolibearQ"..Png, type = 2, displayName = "Rolling Thunder", name = "VolibearQ-", danger = 3, slot = _Q, slot2 = HK_Q},
	},
	["Xayah"] = {
		[3] = {icon = Icons.."XayahR"..Png, type = 3, displayName = "Featherstorm", name = "XayahR-", danger = 5, slot = _R, slot2 = HK_R},
	},
	["Yasuo"] = {
		[1] = {icon = Icons.."YasuoW"..Png, type = 6, displayName = "Wind Wall", name = "YasuoW-", danger = 2, slot = _W, slot2 = HK_W},
	},
	["Zed"] = {
		[3] = {icon = Icons.."ZedR"..Png, type = 4, displayName = "Death Mark", name = "ZedR-", range = 625, danger = 4, slot = _R, slot2 = HK_R},
	},
	["Zeri"] = {
		[2] = {icon = Icona, type = 1, displayName = "Spark Surge", name = "ZeriE-", range = 300, danger = 2, slot = _E, slot2 = HK_E},
	},
	["Zilean"] = {
		[2] = {icon = Icons.."ZileanE"..Png, type = 2, displayName = "Time Warp", name = "ZileanE-", danger = 3, slot = _E, slot2 = HK_E},
	},
}

local Buffs = {
	["Katarina"] = "katarinarsound",
	["Xerath"] = "XerathLocusOfPower2",
	["Vladimir"] = "VladimirW"
}

local Minions = {
	["SRU_ChaosMinionSuper"] = true,
	["SRU_OrderMinionSuper"] = true,
	["HA_ChaosMinionSuper"] = true,
	["HA_OrderMinionSuper"] = true,
	["SRU_ChaosMinionRanged"] = true,
	["SRU_OrderMinionRanged"] = true,
	["HA_ChaosMinionRanged"] = true,
	["HA_OrderMinionRanged"] = true,
	["SRU_ChaosMinionMelee"] = true,
	["SRU_OrderMinionMelee"] = true,
	["HA_ChaosMinionMelee"] = true,
	["HA_OrderMinionMelee"] = true,
	["SRU_ChaosMinionSiege"] = true,
	["SRU_OrderMinionSiege"] = true,
	["HA_ChaosMinionSiege"] = true,
	["HA_OrderMinionSiege"] = true
}

local function Class()		
	local cls = {}; cls.__index = cls		
	return setmetatable(cls, {__call = function (c, ...)		
		local instance = setmetatable({}, cls)		
		if cls.__init then cls.__init(instance, ...) end		
		return instance		
	end})		
end

--[[
	┌─┐┌─┐┬┌┐┌┌┬┐
	├─┘│ │││││ │ 
	┴  └─┘┴┘└┘ ┴ 
--]]

local function IsPoint(p)
	return p and p.x and type(p.x) == "number" and (p.y and type(p.y) == "number")
end

local function Round(v)
	return v < 0 and MathCeil(v - 0.5) or MathFloor(v + 0.5)
end

local Point2D = Class()

function Point2D:__init(x, y)
	if not x then self.x, self.y = 0, 0
	elseif not y then self.x, self.y = x.x, x.y
	else self.x = x; if y and type(y) == "number" then self.y = y end end
end

function Point2D:__type()
	return "Point2D"
end

function Point2D:__eq(p)
	return self.x == p.x and self.y == p.y
end

function Point2D:__add(p)
	return Point2D(self.x + p.x, (p.y and self.y) and self.y + p.y)
end

function Point2D:__sub(p)
	return Point2D(self.x - p.x, (p.y and self.y) and self.y - p.y)
end

function Point2D.__mul(a, b)
	if type(a) == "number" and IsPoint(b) then
		return Point2D(b.x * a, b.y * a)
	elseif type(b) == "number" and IsPoint(a) then
		return Point2D(a.x * b, a.y * b)
	end
end

function Point2D.__div(a, b)
	if type(a) == "number" and IsPoint(b) then
		return Point2D(a / b.x, a / b.y)
	else
		return Point2D(a.x / b, a.y / b)
	end
end

function Point2D:__tostring()
	return "("..self.x..", "..self.y..")"
end

function Point2D:Clone()
	return Point2D(self)
end

function Point2D:Extended(to, distance)
	return self + (Point2D(to) - self):Normalized() * distance
end

function Point2D:Magnitude()
	return MathSqrt(self:MagnitudeSquared())
end

function Point2D:MagnitudeSquared(p)
	local p = p and Point2D(p) or self
	return self.x * self.x + self.y * self.y
end

function Point2D:Normalize()
	local dist = self:Magnitude()
	self.x, self.y = self.x / dist, self.y / dist
end

function Point2D:Normalized()
	local p = self:Clone()
	p:Normalize(); return p
end

function Point2D:Perpendicular()
	return Point2D(-self.y, self.x)
end

function Point2D:Perpendicular2()
	return Point2D(self.y, -self.x)
end

function Point2D:Rotate(phi)
	local c, s = MathCos(phi), MathSin(phi)
	self.x, self.y = self.x * c + self.y * s, self.y * c - self.x * s
end

function Point2D:Rotated(phi)
	local p = self:Clone()
	p:Rotate(phi); return p
end

function Point2D:Round()
	local p = self:Clone()
	p.x, p.y = Round(p.x), Round(p.y)
	return p
end

--[[
	┬  ┬┌─┐┬─┐┌┬┐┌─┐─┐ ┬
	└┐┌┘├┤ ├┬┘ │ ├┤ ┌┴┬┘
	 └┘ └─┘┴└─ ┴ └─┘┴ └─
--]]

local Vertex = {}

function Vertex:New(x, y, alpha, intersection)
	local new = {x = x, y = y, next = nil, prev = nil, nextPoly = nil, neighbor = nil,
		intersection = intersection, entry = nil, visited = false, alpha = alpha or 0}
	setmetatable(new, self)
	self.__index = self
	return new
end

function Vertex:InitLoop()
	local last = self:GetLast()
	last.prev.next = self
	self.prev = last.prev
end

function Vertex:Insert(first, last)
	local res = first
	while res ~= last and res.alpha < self.alpha do res = res.next end
	self.next = res
	self.prev = res.prev
	if self.prev then self.prev.next = self end
	self.next.prev = self
end

function Vertex:GetLast()
	local res = self
	while res.next and res.next ~= self do res = res.next end
	return res
end

function Vertex:GetNextNonIntersection()
	local res = self
	while res and res.intersection do res = res.next end
	return res
end

function Vertex:GetFirstVertexOfIntersection()
	local res = self
	while true do
		res = res.next
		if not res then break end
		if res == self then break end
		if res.intersection and not res.visited then break end
	end
	return res
end

--[[
	─┐ ┬┌─┐┌─┐┬ ┬ ┬┌─┐┌─┐┌┐┌
	┌┴┬┘├─┘│ ││ └┬┘│ ┬│ ││││
	┴ └─┴  └─┘┴─┘┴ └─┘└─┘┘└┘
--]]

local XPolygon = Class()

function XPolygon:__init()
end

function XPolygon:InitVertices(poly)
	local first, current = nil, nil
	for i = 1, #poly do
		if current then
			current.next = Vertex:New(poly[i].x, poly[i].y)
			current.next.prev = current
			current = current.next
		else
			current = Vertex:New(poly[i].x, poly[i].y)
			first = current
		end
	end
	local next = Vertex:New(first.x, first.y, 1)
	current.next = next
	next.prev = current
	return first, current
end

function XPolygon:FindIntersectionsForClip(subjPoly, clipPoly)
	local found, subject = false, subjPoly
	while subject.next do
		if not subject.intersection then
			local clip = clipPoly
			while clip.next do
				if not clip.intersection then
					local subjNext = subject.next:GetNextNonIntersection()
					local clipNext = clip.next:GetNextNonIntersection()
					local int, segs = self:Intersection(subject, subjNext, clip, clipNext)
					if int and segs then
						found = true
						local alpha1 = self:Distance(subject, int) / self:Distance(subject, subjNext)
						local alpha2 = self:Distance(clip, int) / self:Distance(clip, clipNext)
						local subjectInter = Vertex:New(int.x, int.y, alpha1, true)
						local clipInter = Vertex:New(int.x, int.y, alpha2, true)
						subjectInter.neighbor = clipInter
						clipInter.neighbor = subjectInter
						subjectInter:Insert(subject, subjNext)
						clipInter:Insert(clip, clipNext)
					end
				end
				clip = clip.next
			end
		end
		subject = subject.next
	end
	return found
end

function XPolygon:IdentifyIntersectionType(subjList, clipList, clipPoly, subjPoly, operation)
	local se = self:IsPointInPolygon(clipPoly, subjList)
	if operation == "intersection" then se = not se end
	local subject = subjList
	while subject do
		if subject.intersection then
			subject.entry = se
			se = not se
		end
		subject = subject.next
	end
	local ce = not self:IsPointInPolygon(subjPoly, clipList)
	if operation == "union" then ce = not ce end
	local clip = clipList
	while clip do
		if clip.intersection then
			clip.entry = ce
			ce = not ce
		end
		clip = clip.next
	end
end

function XPolygon:GetClipResult(subjList, clipList)
	subjList:InitLoop(); clipList:InitLoop()
	local walker, result = nil, {}
	while true do
		walker = subjList:GetFirstVertexOfIntersection()
		if walker == subjList then break end
		while true do
			if walker.visited then break end
			walker.visited = true
			walker = walker.neighbor
			TableInsert(result, Point2D(walker.x, walker.y))
			local forward = walker.entry
			while true do
				walker.visited = true
				walker = forward and walker.next or walker.prev
				if walker.intersection then break
				else TableInsert(result, Point2D(walker.x, walker.y)) end
			end
		end
	end
	return result
end

function XPolygon:ClipPolygons(subj, clip, op)
	local result = {}
	local subjList, l1 = self:InitVertices(subj)
	local clipList, l2 = self:InitVertices(clip)
	local ints = self:FindIntersectionsForClip(subjList, clipList)
	if ints then
		self:IdentifyIntersectionType(subjList, clipList, clip, subj, op)
		result = self:GetClipResult(subjList, clipList)
	else
		local inside = self:IsPointInPolygon(clip, subj[1])
		local outside = self:IsPointInPolygon(subj, clip[1])
		if op == "union" then
			if inside then return clip, nil
			elseif outside then return subj, nil end
		elseif op == "intersection" then
			if inside then return subj, nil
			elseif outside then return clip, nil end
		end
		return subj, clip
	end
	return result, nil
end

function XPolygon:CrossProduct(p1, p2)
	return p1.x * p2.y - p1.y * p2.x
end

function XPolygon:Distance(p1, p2)
	return MathSqrt(self:DistanceSquared(p1, p2))
end

function XPolygon:DistanceSquared(p1, p2)
	local dx, dy = p2.x - p1.x, p2.y - p1.y
	return dx * dx + dy * dy
end

function XPolygon:Intersection(a1, b1, a2, b2)
	local a1, b1, a2, b2 = Point2D(a1), Point2D(b1), Point2D(a2), Point2D(b2)
	local r, s = Point2D(b1 - a1), Point2D(b2 - a2); local x = self:CrossProduct(r, s)
	local t, u = self:CrossProduct(a2 - a1, s) / x, self:CrossProduct(a2 - a1, r) / x
	return Point2D(a1 + t * r), t >= 0 and t <= 1 and u >= 0 and u <= 1
end

function XPolygon:IsPointInPolygon(poly, point)
	local result, j = false, #poly
	for i = 1, #poly do
		if poly[i].y < point.y and poly[j].y >= point.y or poly[j].y < point.y and poly[i].y >= point.y then
			if poly[i].x + (point.y - poly[i].y) / (poly[j].y - poly[i].y) * (poly[j].x - poly[i].x) < point.x then
				result = not result
			end
		end
		j = i
	end
	return result
end

function XPolygon:OffsetPolygon(poly, offset)
	local result = {}
	for i, point in ipairs(poly) do
		local j, k = i - 1, i + 1
		if j < 1 then j = #poly end; if k > #poly then k = 1 end
		local p1, p2, p3 = poly[j], poly[i], poly[k]
		local n1 = Point2D(p2 - p1):Normalized():Perpendicular() * offset
		local a, b = Point2D(p1 + n1), Point2D(p2 + n1)
		local n2 = Point2D(p3 - p2):Normalized():Perpendicular() * offset
		local c, d = Point2D(p2 + n2), Point2D(p3 + n2)
		local int = self:Intersection(a, b, c, d)
		local dist = self:Distance(p2, int)
		local dot = (p1.x - p2.x) * (p3.x - p2.x) + (p1.y - p2.y) * (p3.y - p2.y)
		local cross = (p1.x - p2.x) * (p3.y - p2.y) - (p1.y - p2.y) * (p3.x - p2.x)
		local angle = MathAtan2(cross, dot)
		if dist > offset and angle > 0 then
			local ex = p2 + Point2D(int - p2):Normalized() * offset
			local dir = Point2D(ex - p2):Perpendicular():Normalized() * dist
			local e, f = Point2D(ex - dir), Point2D(ex + dir)
			local i1 = self:Intersection(e, f, a, b); local i2 = self:Intersection(e, f, c, d)
			TableInsert(result, i1); TableInsert(result, i2)
		else
			TableInsert(result, int)
		end
    end
    return result
end

--[[
	┬┌┐┌┬┌┬┐
	│││││ │ 
	┴┘└┘┴ ┴ 
--]]

local JEvade = Class()

function JEvade:__init()
	self.DoD, self.Evading, self.InsidePath, self.Loaded = false, false, false, false
	self.ExtendedPos, self.Flash, self.Flash2, self.MousePos, self.MyHeroPos, self.SafePos = nil, nil, nil, nil, nil, nil
	self.Debug, self.DodgeableSpells, self.DetectedSpells, self.Enemies, self.EvadeSpellData, self.OnCreateMisCBs, self.OnImpDodgeCBs, self.OnProcSpellCBs = {}, {}, {}, {}, {}, {}, {}, {}
	self.DDTimer, self.DebugTimer, self.MoveTimer, self.MissileID, self.OldTimer, self.NewTimer = 0, 0, 0, 0, 0, 0
	self.SpellSlot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit and unit.team ~= myHero.team then TableInsert(self.Enemies, {unit = unit, spell = nil, missile = nil}) end
	end
	TableSort(self.Enemies, function(a, b) return a.unit.charName < b.unit.charName end)
	self.JEMenu = MenuElement({type = MENU, id = "JustEvade", name = "Just Evade v"..IntVer})
	self.JEMenu:MenuElement({id = "Core", name = "Core Settings", type = MENU})
	self.JEMenu.Core:MenuElement({id = "SmoothEvade", name = "Enable Smooth Evading", value = true})
	self.JEMenu.Core:MenuElement({id = "LimitRange", name = "Limit Detection Range", value = true})
	self.JEMenu.Core:MenuElement({id = "GP", name = "Average Game Ping", value = 50, min = 0, max = 250, step = 5})
	self.JEMenu.Core:MenuElement({id = "CQ", name = "Circle Segments Quality", value = 16, min = 10, max = 25, step = 1})
	self.JEMenu.Core:MenuElement({id = "DS", name = "Diagonal Search Step", value = 20, min = 5, max = 100, step = 5})
	self.JEMenu.Core:MenuElement({id = "DC", name = "Diagonal Points Count", value = 4, min = 1, max = 8, step = 1})
	self.JEMenu.Core:MenuElement({id = "LR", name = "Limited Detection Range", value = 5250, min = 500, max = 10000, step = 250})
	self.JEMenu:MenuElement({id = "Main", name = "Main Settings", type = MENU})
	self.JEMenu.Main:MenuElement({id = "Evade", name = "Enable Evade", value = true})
	self.JEMenu.Main:MenuElement({id = "Dodge", name = "Dodge Spells", value = true})
	self.JEMenu.Main:MenuElement({id = "Draw", name = "Draw Spells", value = true})
	self.JEMenu.Main:MenuElement({id = "Missile", name = "Enable Missile Detection", value = false})
	self.JEMenu.Main:MenuElement({id = "Debug", name = "Debug Evade Points", value = true})
	self.JEMenu.Main:MenuElement({id = "Status", name = "Draw Evade Status", value = true})
	self.JEMenu.Main:MenuElement({id = "SafePos", name = "Draw Safe Position", value = true})
	self.JEMenu.Main:MenuElement({id = "DD", name = "Dodge Only Dangerous", key = string.byte("N")})
	self.JEMenu.Main:MenuElement({id = "Arrow", name = "Dodge Arrow Color", color = DrawColor(192, 255, 255, 0)})
	self.JEMenu.Main:MenuElement({id = "SPC", name = "Safe Position Color", color = DrawColor(192, 255, 255, 255)})
	self.JEMenu.Main:MenuElement({id = "SC", name = "Detected Spell Color", color = DrawColor(192, 255, 255, 255)})
	self.JEMenu:MenuElement({id = "Spells", name = "Spell Settings", type = MENU})
	DelayAction(function()
		self.JEMenu.Spells:MenuElement({id = "DSpells", name = "Dodgeable Spells:", type = SPACE})
		for _, data in ipairs(self.Enemies) do
			local enemy = data.unit.charName
			if SpellDatabase[enemy] then
				for j, spell in pairs(SpellDatabase[enemy]) do
					if not self.JEMenu.Spells[j] then
						self.JEMenu.Spells:MenuElement({id = j, name = ""..enemy.." "..self.SpellSlot[spell.slot].." - "..spell.displayName, leftIcon = spell.icon, type = MENU})
						self.JEMenu.Spells[j]:MenuElement({id = "Dodge"..j, name = "Dodge Spell", value = true})
						self.JEMenu.Spells[j]:MenuElement({id = "Draw"..j, name = "Draw Spell", value = true})
						self.JEMenu.Spells[j]:MenuElement({id = "Force"..j, name = "Force To Dodge", value = spell.danger >= 2})
						if spell.fow then self.JEMenu.Spells[j]:MenuElement({id = "FOW"..j, name = "FOW Detection", value = true}) end
						self.JEMenu.Spells[j]:MenuElement({id = "HP"..j, name = "%HP To Dodge Spell", value = 100, min = 0, max = 100, step = 5})
						self.JEMenu.Spells[j]:MenuElement({id = "ER"..j, name = "Extra Radius", value = 0, min = 0, max = 100, step = 5})
						self.JEMenu.Spells[j]:MenuElement({id = "Danger"..j, name = "Danger Level", value = (spell.danger or 1), min = 1, max = 5, step = 1})
					end
				end
			end
		end
		self.JEMenu.Spells:MenuElement({id = "ESpells", name = "Evading Spells:", type = SPACE})
		local eS = EvadeSpells[myHero.charName]
		if eS then
			for i = 0, 3 do
				if eS[i] then
					self.JEMenu.Spells:MenuElement({id = eS[i].name, name = ""..myHero.charName.." "..self.SpellSlot[eS[i].slot].." - "..eS[i].displayName, leftIcon = eS[i].icon, type = MENU})
					self.JEMenu.Spells[eS[i].name]:MenuElement({id = "US"..eS[i].name, name = "Use Spell", value = true})
					self.JEMenu.Spells[eS[i].name]:MenuElement({id = "Danger"..eS[i].name, name = "Danger Level", value = (eS[i].danger or 1), min = 1, max = 5, step = 1})
				end
			end
		end
	end, 0.01)
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	self.SpecialSpells = {
		["PantheonR"] = function(sP, eP, data)
			local sP2, eP2 = Point2D(eP):Extended(sP, 1150), self:AppendVector(sP, eP, 200)
			return self:RectangleToPolygon(sP2, eP2, data.radius, self.BoundingRadius),
				self:RectangleToPolygon(sP2, eP2, data.radius) end,
		["ZoeE"] = function(sP, eP, data)
			local p1 = self:CircleToPolygon(eP, data.radius + self.BoundingRadius, self.JEMenu.Core.CQ:Value())
			local p2 = self:CircleToPolygon(eP, data.radius, self.JEMenu.Core.CQ:Value())
			self:AddSpell(p1, p2, sP, eP, data, MathHuge, data.range, 5, 250, "ZoeE")
			return p1, p2 end,
		["AatroxQ2"] = function(sP, eP, data)
			local dir = Point2D(sP - eP):Perpendicular():Normalized()*data.radius
			local s1, s2 = Point2D(sP - dir), Point2D(sP + dir)
			local e1, e2 = self:Rotate(s1, eP, MathRad(40)), self:Rotate(s2, eP, -MathRad(40))
			local path = {s1, e1, e2, s2}
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["GravesQLineSpell"] = function(sP, eP, data)
			local s1 = eP - Point2D(eP - sP):Perpendicular():Normalized() * 240
			local e1 = eP + Point2D(eP - sP):Perpendicular():Normalized() * 240
			local p1, p2 = self:RectangleToPolygon(sP, eP, data.radius), self:RectangleToPolygon(s1, e1, 150)
			local path = XPolygon:ClipPolygons(p1, p2, "union")
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["GravesChargeShot"] = function(sP, eP, data)
			local p1, e1 = self:RectangleToPolygon(sP, eP, data.radius), self:AppendVector(sP, eP, 700)
			local dir = Point2D(eP - e1):Perpendicular():Normalized() * 350
			local path = {p1[2], p1[3], Point2D(e1 - dir), Point2D(e1 + dir), p1[4], p1[1]}
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["JinxE"] = function(sP, eP, data)
			local quality = self.JEMenu.Core.CQ:Value()
			local p1 = self:CircleToPolygon(eP, data.radius, quality)
			local dir = Point2D(eP - sP):Perpendicular():Normalized() * 175
			local pos1, pos2 = Point2D(eP + dir), Point2D(eP - dir)
			local p2 = self:CircleToPolygon(pos1, data.radius, quality)
			local p3 = self:CircleToPolygon(pos2, data.radius, quality)
			local p4 = XPolygon:ClipPolygons(p1, p2, "union")
			local path = XPolygon:ClipPolygons(p3, p4, "union")
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["MordekaiserQ"] = function(sP, eP, data)
			local dir = Point2D(eP - sP):Perpendicular():Normalized() * 75
			local s1, s2 = Point2D(sP - dir), Point2D(sP + dir)
			local e1 = self:Rotate(s1, Point2D(s1):Extended(eP, 675), -MathRad(18))
			local e2 = self:Rotate(s2, Point2D(s2):Extended(eP, 675), MathRad(18))
			local path = {s1, e1, e2, s2}
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["MordekaiserE"] = function(sP, eP, data)
			local endPos
			if self:Distance(sP, eP) > data.range then
				endPos = Point2D(sP):Extended(eP, data.range)
			else
				local sP = Point2D(eP):Extended(sP, data.range)
				sP = self:PrependVector(sP, eP, 200)
				endPos = self:AppendVector(sP, eP, 200)
			end
			local path = self:RectangleToPolygon(sP, endPos, data.radius)
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["OrianaIzuna"] = function(sP, eP, data)
			local p1 = self:RectangleToPolygon(sP, eP, data.radius)
			local p2 = self:CircleToPolygon(eP, 135, self.JEMenu.Core.CQ:Value())
			local path = XPolygon:ClipPolygons(p1, p2, "union")
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["SettW"] = function(sP, eP, data)
			local sPos = self:AppendVector(eP, sP, -40)
			local ePos = Point2D(sPos):Extended(eP, data.range)
			local dir = Point2D(ePos - sPos):Perpendicular():Normalized() * data.radius
			local s1, s2 = Point2D(sPos - dir), Point2D(sPos + dir)
			local e1 = self:Rotate(s1, Point2D(s1):Extended(ePos, data.range), -MathRad(30))
			local e2 = self:Rotate(s2, Point2D(s2):Extended(ePos, data.range), MathRad(30))
			local path = {s1, e1, e2, s2}
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["SettE"] = function(sP, eP, data)
			local sPos = Point2D(sP):Extended(eP, -data.range)
			return self:RectangleToPolygon(sPos, eP, data.radius, self.BoundingRadius),
				self:RectangleToPolygon(sPos, eP, data.radius) end,
		["SylasQ"] = function(sP, eP, data)
			local dir = Point2D(eP - sP):Perpendicular():Normalized() * 100
			local s1, s2 = Point2D(sP - dir), Point2D(sP + dir)
			local e1 = self:Rotate(s1, Point2D(s1):Extended(eP, data.range), MathRad(3))
			local e2 = self:Rotate(s2, Point2D(s2):Extended(eP, data.range), -MathRad(3))
			local p1, p2 = self:RectangleToPolygon(s1, e1, data.radius), self:RectangleToPolygon(s2, e2, data.radius)
			local p3 = self:CircleToPolygon(eP, 180, self.JEMenu.Core.CQ:Value())
			local path = XPolygon:ClipPolygons(p1, p2, "union")
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["ThreshEFlay"] = function(sP, eP, data)
			local sPos = Point2D(sP):Extended(eP, -data.range)
			return self:RectangleToPolygon(sPos, eP, data.radius, self.BoundingRadius),
				self:RectangleToPolygon(sPos, eP, data.radius) end,
		["ZiggsQ"] = function(sP, eP, data)
			local quality = self.JEMenu.Core.CQ:Value()
			local p1, bp1 = self:CircleToPolygon(eP, data.radius, quality),
				self:CircleToPolygon(eP, data.radius + self.BoundingRadius, quality)
			local e1 = Point2D(sP):Extended(eP, 1.4 * self:Distance(sP, eP))
			local p2, bp2 = self:CircleToPolygon(e1, data.radius, quality),
				self:CircleToPolygon(e1, data.radius + self.BoundingRadius, quality)
			local e2 = Point2D(eP):Extended(e1, 1.69 * self:Distance(eP, e1))
			local p3, bp3 = self:CircleToPolygon(e2, data.radius, quality),
				self:CircleToPolygon(e2, data.radius + self.BoundingRadius, quality)
			self:AddSpell(bp1, p1, sP, eP, data, data.speed, data.range, 0.25, data.radius, "ZiggsQ")
			self:AddSpell(bp2, p2, sP, eP, data, data.speed, data.range, 0.75, data.radius, "ZiggsQ")
			self:AddSpell(bp3, p3, sP, eP, data, data.speed, data.range, 1.25, data.radius, "ZiggsQ")
			return nil, nil end
	}
	self.SpellTypes = {
		["linear"] = function(sP, eP, data)
			return self:RectangleToPolygon(sP, eP, data.radius, self.BoundingRadius),
				self:RectangleToPolygon(sP, eP, data.radius) end,
		["threeway"] = function(sP, eP, data)
			return self:RectangleToPolygon(sP, eP, data.radius, self.BoundingRadius),
				self:RectangleToPolygon(sP, eP, data.radius) end,
		["rectangular"] = function(sP, eP, data)
			local dir = Point2D(eP - sP):Perpendicular():Normalized() * (data.radius2 or 400)
			local sP2, eP2 = Point2D(eP - dir), Point2D(eP + dir)
			return self:RectangleToPolygon(sP2, eP2, data.radius / 2, self.BoundingRadius),
				self:RectangleToPolygon(sP2, eP2, data.radius / 2) end,
		["circular"] = function(sP, eP, data)
			local quality = self.JEMenu.Core.CQ:Value()
			return self:CircleToPolygon(eP, data.radius + self.BoundingRadius, quality),
				self:CircleToPolygon(eP, data.radius, quality) end,
		["conic"] = function(sP, eP, data)
			local path = self:ConeToPolygon(sP, eP, data.angle)
			return XPolygon:OffsetPolygon(path, self.BoundingRadius), path end,
		["polygon"] = function(sP, eP, data)
			return self:RectangleToPolygon(sP, eP, data.radius, self.BoundingRadius),
				self:RectangleToPolygon(sP, eP, data.radius) end
	}
	DelayAction(function()
		self:LoadEvadeSpells()
		if self.Flash then
			self.JEMenu.Spells:MenuElement({id = "Flash", name = myHero.charName.." - Summoner Flash", leftIcon = FlashIcon, type = MENU})
			self.JEMenu.Spells.Flash:MenuElement({id = "US", name = "Use Flash", value = true})
		end
		self.Loaded = true
	end, 0.01)
end

--[[
	┌┬┐┬─┐┌─┐┬ ┬┬┌┐┌┌─┐┌─┐
	 ││├┬┘├─┤││││││││ ┬└─┐
	─┴┘┴└─┴ ┴└┴┘┴┘└┘└─┘└─┘
--]]

function JEvade:DrawArrow(startPos, endPos, color)
	local p1 = endPos-(Point2D(startPos-endPos):Normalized()*30):Perpendicular()+Point2D(startPos-endPos):Normalized()*30
	local p2 = endPos-(Point2D(startPos-endPos):Normalized()*30):Perpendicular2()+Point2D(startPos-endPos):Normalized()*30
	local startPos, endPos, p1, p2 = self:FixPos(startPos), self:FixPos(endPos), self:FixPos(p1), self:FixPos(p2)
	DrawLine(startPos.x, startPos.y, endPos.x, endPos.y, 1, color)
	DrawLine(p1.x, p1.y, endPos.x, endPos.y, 1, color)
	DrawLine(p2.x, p2.y, endPos.x, endPos.y, 1, color)
end

function JEvade:DrawPolygon(poly, y, color)
	local path = {}
	for i = 1, #poly do path[i] = self:FixPos(poly[i], y) end
	DrawLine(path[#path].x, path[#path].y, path[1].x, path[1].y, 0.5, color)
	for i = 1, #path - 1 do DrawLine(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y, 0.5, color) end
end

function JEvade:DrawText(text, size, pos, x, y, color)
	DrawText(text, size, pos.x + x, pos.y + y, color)
end

--[[
	┌─┐┌─┐┌─┐┌┬┐┌─┐┌┬┐┬─┐┬ ┬
	│ ┬├┤ │ ││││├┤  │ ├┬┘└┬┘
	└─┘└─┘└─┘┴ ┴└─┘ ┴ ┴└─ ┴ 
--]]

function JEvade:AppendVector(pos1, pos2, dist)
	return pos2 + Point2D(pos2 - pos1):Normalized() * dist
end

function JEvade:CalculateEndPos(startPos, placementPos, unitPos, speed, range, radius, collision, type, extend)
	local endPos = Point2D(startPos):Extended(placementPos, range)
	if not extend then
		if range > 0 then if self:Distance(unitPos, placementPos) < range then endPos = placementPos end
		else endPos = unitPos end
	else
		if type == "linear" then
			if speed ~= MathHuge then endPos = self:AppendVector(startPos, endPos, radius) end
			if collision then
				local startPos, minions = Point2D(startPos):Extended(placementPos, 45), {}
				for i = 1, GameMinionCount() do
					local minion = GameMinion(i); local minionPos = self:To2D(minion.pos)
					if minion and minion.team == myHero.team and minion.valid and Minions[minion.charName] and
						self:Distance(minionPos, startPos) <= range and minion.maxHealth > 295 and minion.health > 5 then
							local col = self:ClosestPointOnSegment(startPos, placementPos, minionPos)
							if col and self:Distance(col, minionPos) < ((minion.boundingRadius or 45) / 2 + radius) then
								TableInsert(minions, minionPos)
						end
					end
				end
				if #minions > 0 then
					TableSort(minions, function(a, b) return
						self:DistanceSquared(a, startPos) <
						self:DistanceSquared(b, startPos) end)
					local range2 = self:Distance(startPos, minions[1])
					local endPos = Point2D(startPos):Extended(placementPos, range2)
					return endPos, range2
				end
			end
		end
	end
	return endPos, not extend and
		self:Distance(startPos, endPos) or range
end

function JEvade:CircleToPolygon(pos, radius, quality)
	local points = {}
	for i = 0, (quality or 16) - 1 do
		local angle = 2 * MathPi / quality * (i + 0.5)
		local cx, cy = pos.x + radius * MathCos(angle), pos.y + radius * MathSin(angle)
		TableInsert(points, Point2D(cx, cy):Round())
	end
    return points
end

function JEvade:ClosestPointOnSegment(s1, s2, pt)
	local ab = Point2D(s2 - s1)
	local t = ((pt.x - s1.x) * ab.x + (pt.y - s1.y) * ab.y) / (ab.x * ab.x + ab.y * ab.y)
	return t < 0 and Point2D(s1) or (t > 1 and Point2D(s2) or Point2D(s1 + t * ab))
end

function JEvade:ConeToPolygon(startPos, endPos, angle)
	local angle, points = MathRad(angle), {}
	TableInsert(points, Point2D(startPos))
	for i = -angle / 2, angle / 2, angle / 5 do
		local rotated = Point2D(endPos - startPos):Rotated(i)
		TableInsert(points, Point2D(startPos + rotated):Round())
	end
	return points
end

function JEvade:CrossProduct(p1, p2)
	return p1.x * p2.y - p1.y * p2.x
end

function JEvade:Distance(p1, p2)
	return MathSqrt(self:DistanceSquared(p1, p2))
end

function JEvade:DistanceSquared(p1, p2)
	return (p2.x - p1.x) ^ 2 + (p2.y - p1.y) ^ 2
end

function JEvade:DotProduct(p1, p2)
	return p1.x * p2.x + p1.y * p2.y
end

function JEvade:FindIntersections(poly, p1, p2)
	local intersections = {}
	for i = 1, #poly do
		local startPos, endPos = poly[i], poly[i == #poly and 1 or (i + 1)]
		local int = self:LineSegmentIntersection(startPos, endPos, p1, p2)
		if int then TableInsert(intersections, int:Round()) end
	end
	return intersections
end

function JEvade:FixPos(pos, y)
	return Vector(pos.x, y or myHero.pos.y, pos.y):To2D()
end

function JEvade:GetBestEvadePos(spells, radius, mode, extra, force)
	local evadeModes = {
		[1] = function(a, b) return self:DistanceSquared(a, self.MyHeroPos) < self:DistanceSquared(b, self.MyHeroPos) end,
		[2] = function(a, b) local mPos = self.MyHeroPos:Extended(self.MousePos, radius + self.BoundingRadius);
							return self:DistanceSquared(a, mPos) < self:DistanceSquared(b, mPos) end
	}
	local points = {}
	for i, spell in ipairs(spells) do
		local poly = spell.path
		for j = 1, #poly do
			local startPos, endPos = poly[j], poly[j == #poly and 1 or (j + 1)]
			local original = self:ClosestPointOnSegment(startPos, endPos, self.MyHeroPos)
			local distSqr = self:DistanceSquared(original, self.MyHeroPos)
			if distSqr <= 360000 then
				if force then
					local candidate = self:AppendVector(self.MyHeroPos, original, 5)
					if distSqr <= 160000 and not self:IsDangerous(candidate)
						and not MapPosition:inWall(self:To3D(candidate)) then
							TableInsert(points, candidate) end
				else
					local direction = Point2D(endPos - startPos):Normalized()
					local step = self.JEMenu.Core.DC:Value()
					for k = -step, step, 1 do
						local candidate = Point2D(original + k * self.JEMenu.Core.DS:Value() * direction)
						local extended = self:AppendVector(self.MyHeroPos, candidate, self.BoundingRadius)
						candidate = self:AppendVector(self.MyHeroPos, candidate, 5)
						if self:IsSafePos(candidate, extra) and not
							MapPosition:inWall(self:To3D(extended)) then TableInsert(points, candidate) end
					end
				end
			end
		end
	end
	if #points > 0 then
		TableSort(points, evadeModes[mode])
		if self.JEMenu.Main.Debug:Value() then
			self.Debug = force and {points[1]} or points
		end
		return points[1]
	end
	return nil
end

function JEvade:GetExtendedSafePos(pos)
	if not self.JEMenu.Core.SmoothEvade:Value() then return pos end
	local distance, positions = self:Distance(self.MyHeroPos, pos) + 390, {}
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and minion.valid and minion.visible and not minion.dead then
			local minionPos = self:To2D(minion.pos)
			if self:Distance(self.MyHeroPos, minionPos) <= distance then
				TableInsert(positions, minionPos)
			end
		end
	end
	for i = 2, 8 do
		local collision = false
		local ext = self:AppendVector(self.MyHeroPos, pos, self.BoundingRadius * i)
		if i > 2 and not MapPosition:inWall(self:To3D(ext)) or i == 2 then
			for j, minionPos in ipairs(positions) do
				if self:Distance(ext, minionPos) <= self.BoundingRadius then collision = true; break end
			end
			if not collision then return ext end
		end
	end
	return nil
end

function JEvade:GetMovePath()
	return self:IsMoving() and myHero.pathing.endPos ~= nil
		and self:To2D(myHero.pathing.endPos) or nil
end

function JEvade:GetPaths(startPos, endPos, data, name)
	local path, path2
	if self.SpecialSpells[name] then
		path, path2 = self.SpecialSpells[name](startPos, endPos, data)
		if name ~= "ZoeE" then return path, path2 end
	end
	return self.SpellTypes[data.type](startPos, endPos, data)
end

function JEvade:IsAboutToHit(spell, pos, extra)
	local evadeSpell = #self.EvadeSpellData > 0 and self.EvadeSpellData[extra or 1] or nil
	if extra and evadeSpell and evadeSpell.type ~= 2 then return false end
	local moveSpeed = self:GetMovementSpeed(extra, evadeSpell)
	if moveSpeed == MathHuge then return false end
	local myPos = Point2D(self.MyHeroPos)
	local diff, pos = GameTimer() - spell.startTime, self:AppendVector(myPos, pos, 99999)
	if spell.speed ~= MathHuge and spell.type == "linear" or spell.type == "threeway" then
		if spell.delay > 0 and diff <= spell.delay then
			myPos = Point2D(myPos):Extended(pos, (spell.delay - diff) * moveSpeed)
			if not self:IsPointInPolygon(spell.path, myPos) then return false end
		end
		local va = Point2D(pos - myPos):Normalized() * moveSpeed
		local vb = Point2D(spell.endPos - spell.position):Normalized() * spell.speed
		local da, db = Point2D(myPos - spell.position), Point2D(va - vb)
		local a, b = self:DotProduct(db, db), 2 * self:DotProduct(da, db)
		local c = self:DotProduct(da, da) - (spell.radius + self.BoundingRadius * 2) ^ 2
		local delta = b * b - 4 * a * c
		if delta >= 0 then
			local rtDelta = MathSqrt(delta)
			local t1, t2 = (-b + rtDelta) / (2 * a), (-b - rtDelta) / (2 * a)
			return MathMax(t1, t2) >= 0
		end
		return false
	end
	local t = MathMax(0, spell.range / spell.speed + spell.delay - diff - 0.07)
	return self:IsPointInPolygon(spell.path, myPos:Extended(pos, moveSpeed * t))
end

function JEvade:IsDangerous(pos)
	for i, s in ipairs(self.DetectedSpells) do
		if self:IsPointInPolygon(s.path, pos) then return true end
	end
	return false
end

function JEvade:IsPointInPolygon(poly, point)
	local result, j = false, #poly
	for i = 1, #poly do
		if poly[i].y < point.y and poly[j].y >= point.y or poly[j].y < point.y and poly[i].y >= point.y then
			if poly[i].x + (point.y - poly[i].y) / (poly[j].y - poly[i].y) * (poly[j].x - poly[i].x) < point.x then
				result = not result
			end
		end
		j = i
	end
	return result
end

function JEvade:IsSafePos(pos, extra)
	for i, s in ipairs(self.DodgeableSpells) do
		if self:IsPointInPolygon(s.path, pos) or self:IsAboutToHit(s, pos, extra) then return false end
	end
	return true
end

function JEvade:LineSegmentIntersection(a1, b1, a2, b2)
	local r, s = Point2D(b1 - a1), Point2D(b2 - a2); local x = self:CrossProduct(r, s)
	local t, u = self:CrossProduct(a2 - a1, s) / x, self:CrossProduct(a2 - a1, r) / x
	return x ~= 0 and t >= 0 and t <= 1 and u >= 0 and u <= 1 and Point2D(a1 + t * r) or nil
end

function JEvade:Magnitude(p)
	return MathSqrt(self:MagnitudeSquared(p))
end

function JEvade:MagnitudeSquared(p)
	return p.x * p.x + p.y * p.y
end

function JEvade:PrependVector(pos1, pos2, dist)
	return pos1 + Point2D(pos2 - pos1):Normalized() * dist
end

function JEvade:RectangleToPolygon(startPos, endPos, radius, offset)
	local offset = offset or 0
	local dir = Point2D(endPos - startPos):Normalized()
	local perp = (radius + offset) * dir:Perpendicular()
	return {Point2D(startPos + perp - offset * dir), Point2D(startPos - perp - offset * dir),
		Point2D(endPos - perp + offset * dir), Point2D(endPos + perp + offset * dir)}
end

function JEvade:Rotate(startPos, endPos, theta)
	local dx, dy = endPos.x - startPos.x, endPos.y - startPos.y
	local px, py = dx * MathCos(theta) - dy * MathSin(theta), dx * MathSin(theta) + dy * MathCos(theta)
	return Point2D(px + startPos.x, py + startPos.y)
end

function JEvade:SafePosition()
	return self.SafePos and self:To3D(self.SafePos) or nil
end

function JEvade:To2D(pos)
	return Point2D(pos.x, pos.z or pos.y)
end

function JEvade:To3D(pos)
	return Vector(pos.x, myHero.pos.y, pos.y)
end

--[[
	┌┬┐┌─┐┌┐┌┌─┐┌─┐┌─┐┬─┐
	│││├─┤│││├─┤│ ┬├┤ ├┬┘
	┴ ┴┴ ┴┘└┘┴ ┴└─┘└─┘┴└─
--]]

function JEvade:AddSpell(p1, p2, sP, eP, data, speed, range, delay, radius, name)
	TableInsert(self.DetectedSpells, {
		path = p1, path2 = p2, position = sP, startPos = sP, endPos = eP, speed = speed, range = range,
		delay = delay, radius = radius, radius2 = data.radius2, angle = data.angle, name = name,
		startTime = GameTimer() - self.JEMenu.Core.GP:Value() / 2000, type = data.type,
		danger = self.JEMenu.Spells[name]["Danger"..name]:Value() or 1, cc = data.cc,
		collision = data.collision, windwall = data.windwall, y = data.y
	})
end

function JEvade:CopyTable(tab)
	local copy = {}
	for key, val in pairs(tab) do copy[key] = val end
	return copy
end

function JEvade:CreateMissile(func)
	TableInsert(self.OnCreateMisCBs, func)
end

function JEvade:GetDodgeableSpells()
	local paths, result = {}, {}
	for i, s in ipairs(self.DetectedSpells) do
		self:SpellManager(i, s)
		if self.JEMenu.Main.Dodge:Value() and self.JEMenu.Spells[s.name]["Dodge"..s.name]:Value() and
			self:GetHealthPercent() <= self.JEMenu.Spells[s.name]["HP"..s.name]:Value() then
			if self.DoD and s.danger >= 4 or not self.DoD then TableInsert(result, s) end
		end
	end
	return result
end

function JEvade:GetHealthPercent()
	return myHero.health / myHero.maxHealth * 100
end

function JEvade:GetMovementSpeed(extra, evadeSpell)
	local moveSpeed = myHero.ms or 315
	if not extra then return moveSpeed end; if not evadeSpell then return 9999 end
	local lvl, name = myHero:GetSpellData(evadeSpell.slot).level or 1, evadeSpell.name
	if lvl == nil or lvl == 0 then return moveSpeed end
	if name == "AnnieE-" then return (1.2824 + (0.0176 * myHero.levelData.lvl)) * moveSpeed
	elseif name == "BlitzcrankW-" then return ({1.7, 1.75, 1.8, 1.85, 1.9})[lvl] * moveSpeed
	elseif name == "DravenW-" then return ({1.4, 1.45, 1.5, 1.55, 1.6})[lvl] * moveSpeed
	elseif name == "GarenQ-" then return 1.3 * moveSpeed
	elseif name == "KaisaE-" then return ({1.55, 1.6, 1.65, 1.7, 1.75})[lvl] * 2 * MathMin(1, myHero.attackSpeed) * moveSpeed
	elseif name == "KatarinaW-" then return ({1.5, 1.6, 1.7, 1.8, 1.9})[lvl] * moveSpeed
	elseif name == "KennenE-" then return 2 * moveSpeed
	elseif name == "RumbleW-" then return ({1.2, 1.25, 1.3, 1.35, 1.4})[lvl] * moveSpeed
	elseif name == "ShyvanaW-" then return ({1.3, 1.35, 1.4, 1.45, 1.5})[lvl] * moveSpeed
	elseif name == "SkarnerW-" then return ({1.08, 1.1, 1.12, 1.14, 1.16})[lvl] * moveSpeed
	elseif name == "SonaE-" then return (({1.1, 1.11, 1.12, 1.13, 1.14})[lvl] + myHero.ap / 100 * 0.03) * moveSpeed
	elseif name == "TeemoW-" then return ({1.1, 1.14, 1.18, 1.22, 1.26})[lvl] * moveSpeed
	elseif name == "UdyrE-" then return ({1.15, 1.2, 1.25, 1.3, 1.35, 1.4})[lvl] * moveSpeed
	elseif name == "VolibearQ-" then return ({1.15, 1.175, 1.2, 1.225, 1.25})[lvl] * moveSpeed end
	return moveSpeed
end

function JEvade:HasBuff(buffName)
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then return true end
	end
	return false
end

function JEvade:ImpossibleDodge(func)
	TableInsert(self.OnImpDodgeCBs, func)
end

function JEvade:IsMoving()
	return myHero.pos.x - MathFloor(myHero.pos.x) ~= 0
end

function JEvade:IsReady(spell)
	return GameCanUseSpell(spell) == 0
end

function JEvade:MoveToPos(pos)
	if _G.SDK and _G.Control.Evade then
		_G.Control.Evade(self:To3D(pos))
	else
		local path = self:FixPos(pos)
		ControlSetCursorPos(path.x, path.y)
		ControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
		ControlMouseEvent(MOUSEEVENTF_RIGHTUP)
	end
end

function JEvade:ProcessSpell(func)
	TableInsert(self.OnProcSpellCBs, func)
end

function JEvade:SpellExistsThenRemove(name)
	for i = #self.DetectedSpells, 1, -1 do
		local s = self.DetectedSpells[i]
		if name == s.name then TableRemove(self.DetectedSpells, i); return end
	end
end

function JEvade:ValidTarget(target, range)
	local range = range or MathHuge
	return target and target.valid and target.visible and not target.dead and
		self:DistanceSquared(self.MyHeroPos, self:To2D(target.pos)) <= range * range
end

--[[
	┌─┐┬  ┬┌─┐┌┬┐┌─┐
	├┤ └┐┌┘├─┤ ││├┤ 
	└─┘ └┘ ┴ ┴─┴┘└─┘
--]]

function JEvade:LoadEvadeSpells()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then self.Flash, self.Flash2 = HK_SUMMONER_1, SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then self.Flash, self.Flash2 = HK_SUMMONER_2, SUMMONER_2 end
	for i = 0, 3 do
		local eS = EvadeSpells[myHero.charName]
		if eS and eS[i] then TableInsert(self.EvadeSpellData, {name = eS[i].name, slot = eS[i].slot, slot2 = eS[i].slot2, range = eS[i].range, type = eS[i].type}) end
	end
end

function JEvade:Tick()
	if not self.JEMenu.Main.Evade:Value() or GameTimer() < 5 then return end
	self.DoD = self.JEMenu.Main.DD:Value() == true
	self.BoundingRadius = myHero.boundingRadius or 65
	self.MyHeroPos, self.MousePos = self:To2D(myHero.pos), self:To2D(mousePos)
	if myHero.dead then return end
	for i = 1, #self.Enemies do
		local unit, spell = self.Enemies[i].unit, self.Enemies[i].spell
		if unit and unit.valid and not unit.dead then
			local active = unit.activeSpell
			if active and active.valid and spell ~= active.name .. active.endTime and active.isChanneling then
				self.Enemies[i].spell = active.name .. active.endTime
				self:OnProcessSpell(unit, active)
				for i = 1, #self.OnProcSpellCBs do self.OnProcSpellCBs[i](unit, active) end
			end
		end
	end
	if self.JEMenu.Main.Missile:Value() then
		for i = 1, GameMissileCount() do
			local mis = GameMissile(i)
			if mis then
				local data = mis.missileData
				for i = 1, #self.Enemies do
					local unit = self.Enemies[i].unit
					if unit.handle == data.owner then
						local id = tonumber(mis.networkID)
						if self.MissileID < id then
							self.MissileID = id; self:OnCreateMissile(unit, data)
							for i = 1, #self.OnCreateMisCBs do
								self.OnCreateMisCBs[i](unit, data) end break
						end
					end
				end
			end
		end
	end
	if #self.DodgeableSpells > 0 then
		local result = 0
		for i, s in ipairs(self.DodgeableSpells) do
			result = result + self:CoreManager(s)
		end
		local movePath = self:GetMovePath()
		if movePath and not self.Evading then
			local ints = {}
			for i, s in ipairs(self.DodgeableSpells) do
				local poly = s.path
				if not self:IsPointInPolygon(poly, self.MyHeroPos) then
					local findInts = self:FindIntersections(poly, self.MyHeroPos, movePath)
					for i, int in ipairs(findInts) do TableInsert(ints, int) end
				end
			end
			if #ints > 0 then
				TableSort(ints, function(a, b) return
					self:DistanceSquared(self.MyHeroPos, a) <
					self:DistanceSquared(self.MyHeroPos, b) end)
				local movePos = self:PrependVector(self.MyHeroPos,
					ints[1], self.BoundingRadius / 2)
				self:MoveToPos(movePos)
			end
		end
		if self.Evading then self:DodgeSpell() end
		if result == 0 then self.Evading, self.SafePos,
			self.ExtendedPos = false, nil, nil end
	else
		if self.JEMenu.Main.Debug:Value() then self.Debug = {} end
		self.Evading, self.SafePos, self.ExtendedPos = false, nil, nil
	end
	if _G.GOS then
		_G.GOS.BlockAttack = self.Evading
		_G.GOS.BlockMovement = self.Evading
	end
end

function JEvade:CoreManager(s)
	if self:IsPointInPolygon(s.path, self.MyHeroPos) then
		if self.OldTimer ~= self.NewTimer then
			local evadeSpells = self.EvadeSpellData
			local flashUsage = self.Flash2 and self.JEMenu.Spells.Flash.US:Value()
				and self:IsReady(self.Flash2) and s.danger == 5
			local safePos = self:GetBestEvadePos(self.DodgeableSpells, s.radius, 2, nil, false)
			if safePos then
				self.ExtendedPos = self:GetExtendedSafePos(safePos)
				self.SafePos, self.Evading = safePos, true
			elseif evadeSpells and #evadeSpells > 0 or flashUsage then
				local result = 0
				for i = 1, #evadeSpells do
					local alternPos = self:GetBestEvadePos(self.DodgeableSpells, s.radius, 1, i, false)
					result = self:Avoid(s, alternPos, evadeSpells[i])
					if result > 0 then
						if result == 1 then
							self.ExtendedPos = self:GetExtendedSafePos(alternPos)
							self.SafePos, self.Evading = alternPos, true
						end
						break
					end
				end
				if result == 0 then
					local dodgePos = self:GetBestEvadePos(self.DodgeableSpells, s.radius, 1, true, true)
					if dodgePos then
						
						if flashUsage then result = 1; Control.CastSpell(HK_SUMMONER_1,self:To3D(dodgePos))
						elseif self.JEMenu.Spells[s.name]["Force"..s.name]:Value() then
							self.ExtendedPos = self:GetExtendedSafePos(dodgePos)
							self.SafePos, self.Evading = dodgePos, true
						end
					end
				end
				if result == 0 then
					for i = 1, #self.OnImpDodgeCBs do self.OnImpDodgeCBs[i](s.danger) end
				end
			else
				for i = 1, #self.OnImpDodgeCBs do self.OnImpDodgeCBs[i](s.danger) end
			end
			self.OldTimer = self.NewTimer
		end
		return 1
	end
	return 0
end

function JEvade:SpellManager(i, s)
	if s.startTime + s.range / s.speed + s.delay > GameTimer() then
		if s.speed ~= MathHuge and s.startTime + s.delay < GameTimer() then
			if s.type == "linear" or s.type == "threeway" then
				local rng = s.speed * (GameTimer() - s.startTime - s.delay)
				local sP = Point2D(s.startPos):Extended(s.endPos, rng); s.position = sP
				s.path = self:RectangleToPolygon(sP, s.endPos, s.radius, self.BoundingRadius)
				s.path2 = self:RectangleToPolygon(sP, s.endPos, s.radius)
			end
		end
	else TableRemove(self.DetectedSpells, i) end
end

function JEvade:DodgeSpell()
	if Buffs and Buffs[myHero.charName] and
		self:HasBuff(Buffs[myHero.charName]) then
			self.SafePos, self.ExtendedPos = nil, nil
	end
	if self.ExtendedPos then
		self:MoveToPos(self.ExtendedPos) end
end

function JEvade:Avoid(spell, dodgePos, data)
	if self:IsReady(data.slot) and self.JEMenu.Spells[data.name]["US"..data.name]:Value()
		and spell.danger >= self.JEMenu.Spells[data.name]["Danger"..data.name]:Value() then
		if dodgePos and (data.type == 1 or data.type == 2) then
			if data.type == 1 then
				local dashPos = Point2D(self.MyHeroPos):Extended(dodgePos, data.range)
				_G.Control.CastSpell(data.slot2, self:To3D(dashPos)); return 1
			elseif data.type == 2 then _G.Control.CastSpell(data.slot2, myHero.pos); return 1 end
		elseif data.type == 3 then _G.Control.CastSpell(data.slot2, myHero.pos); return 2
		elseif data.type == 4 then
			for i = 1, GameHeroCount() do
				local enemy = GameHero(i)
				if enemy and self:ValidTarget(enemy, data.range) and myHero.team ~= enemy.team then
					_G.Control.CastSpell(data.slot2, enemy.pos); return 2
				end
			end
		elseif data.type == 5 and spell.cc then
			_G.Control.CastSpell(data.slot2, myHero.pos); return 2
		elseif data.type == 6 and spell.windwall then
			local wallPos, mPos = Point2D(self.MyHeroPos):Extended(spell.position, 100), mousePos
			if _G.SDK then _G.SDK.Orbwalker:SetAttack(false);
				_G.SDK.Orbwalker:SetMovement(false) end
			DelayAction(function()
				ControlSetCursorPos(Geometry:To3D(wallPos))
				ControlKeyDown(data.slot2); ControlKeyUp(data.slot2)
				DelayAction(function()
					ControlSetCursorPos(mPos)
					if _G.SDK then _G.SDK.Orbwalker:SetAttack(true);
						_G.SDK.Orbwalker:SetMovement(true) end
				end, 0.01)
			end, 0.01); return 2
		elseif data.type == 7 and spell.cc then
			_G.Control.CastSpell(data.slot2, self:To3D(spell.position)); return 2
		end
	end
	return 0
end

function JEvade:Draw()
	if not self.JEMenu.Main.Evade:Value() then return end
	self.DodgeableSpells = self:GetDodgeableSpells()
	if self.JEMenu.Main.Status:Value() then
		if self.JEMenu.Main.Evade:Value() then
			if self.DoD then
				self:DrawText("Evade: Dodge Only Dangerous", 14, myHero.pos2D, -83, 45, DrawColor(224, 255, 255, 0))
			else self:DrawText("Evade: ON", 14, myHero.pos2D, -30, 45, DrawColor(224, 255, 255, 255)) end
		else self:DrawText("Evade: OFF", 14, myHero.pos2D, -32, 45, DrawColor(224, 255, 255, 255)) end
	end
	if #self.DetectedSpells > 0 and self.Evading and self.SafePos ~= nil and self.JEMenu.Main.SafePos:Value() then
		DrawCircle(self:To3D(self.SafePos), self.BoundingRadius, 0.5, self.JEMenu.Main.SPC:Value())
		self:DrawArrow(self.MyHeroPos, self.SafePos, self.JEMenu.Main.Arrow:Value())
	end
	if self.JEMenu.Main.Draw:Value() then
		if self.JEMenu.Main.Debug:Value() then
			for i, dbg in ipairs(self.Debug) do
				DrawCircle(self:To3D(dbg), self.BoundingRadius, 0.5, DrawColor(192, 255, 255, 0))
			end
		end
		for i, s in ipairs(self.DetectedSpells) do
			if self.JEMenu.Spells[s.name]["Draw"..s.name]:Value() then
				self:DrawPolygon(s.path2, s.y, self.JEMenu.Main.SC:Value())
			end
		end
	end
end

function JEvade:OnProcessSpell(unit, spell)
	if unit and spell then
		if unit.team ~= myHero.team then
			local unitPos, name = self:To2D(unit.pos), spell.name
			if self.JEMenu.Core.LimitRange:Value() and self:Distance(self.MyHeroPos, unitPos)
				> self.JEMenu.Core.LR:Value() then return end
			if SpellDatabase[unit.charName] and SpellDatabase[unit.charName][name] then
				local data = self:CopyTable(SpellDatabase[unit.charName][name])
				if data.exception then return end
				local startPos, placementPos = self:To2D(spell.startPos), self:To2D(spell.placementPos)
				local endPos, range = self:CalculateEndPos(startPos, placementPos, unitPos, data.speed, data.range, data.radius, data.collision, data.type, data.extend)
				if unit.charName == "Yasuo" or unit.charName == "Yone" then endPos = startPos + self:To2D(unit.dir) * data.range end
				data.range, data.radius, data.y = range, data.radius + (self.JEMenu.Spells[name]["ER"..name]:Value() or 0), spell.placementPos.y
				local path, path2 = self:GetPaths(startPos, endPos, data, name)
				if path == nil then return end
				if name == "VelkozQ" then self:SpellExistsThenRemove("VelkozQ"); return end
				self:AddSpell(path, path2, startPos, endPos, data, data.speed, range, data.delay, data.radius, name)
				if data.type == "threeway" then
					for i = 1, 2 do
						local eP = i == 1 and self:Rotate(startPos, endPos, MathRad(data.angle)) or
											self:Rotate(startPos, endPos, -MathRad(data.angle))
						local p1 = self:RectangleToPolygon(startPos, eP, data.radius, self.BoundingRadius)
						local p2 = self:RectangleToPolygon(startPos, eP, data.radius)
						self:AddSpell(p1, p2, startPos, eP, data, data.speed, range, data.delay, data.radius, name)
					end
				end
				self.NewTimer = GameTimer()
			end
		elseif unit == myHero and spell.name == "SummonerFlash" then
			self.NewTimer, self.SafePos, self.ExtendedPos = GameTimer(), nil, nil
		end
	end
end

function JEvade:OnCreateMissile(unit, missile)
	local name, unitPos = missile.name, self:To2D(unit.pos)
	if string.find(name, "ttack") or not SpellDatabase[unit.charName] then return end
	if self.JEMenu.Core.LimitRange:Value() and self:Distance(self.MyHeroPos, unitPos)
		> self.JEMenu.Core.LR:Value() then return end
	local menuName = ""
	for i, val in pairs(SpellDatabase[unit.charName]) do
		if val.fow then
			local tested = val.missileName
			if string.find(name, tested) then menuName = i break end
		end
	end
	if menuName == "" then return end
	local data = self:CopyTable(SpellDatabase[unit.charName][menuName])
	if self.JEMenu.Spells[menuName]["FOW"..menuName]:Value() and not
		unit.visible and not data.exception or (data.exception and unit.visible) then
		local startPos, placementPos = self:To2D(missile.startPos), self:To2D(missile.endPos)
		local endPos, range = self:CalculateEndPos(startPos, placementPos, unitPos, data.speed, data.range, data.radius, data.collision, data.type, data.extend)
		data.range, data.radius, data.y = range, data.radius + (self.JEMenu.Spells[menuName]["ER"..menuName]:Value() or 0), missile.endPos.y
		local path, path2 = self:GetPaths(startPos, endPos, data, name)
		if path == nil then return end
		if menuName == "VelkozQMissileSplit" then self:SpellExistsThenRemove("VelkozQ")
		elseif menuName == "JayceShockBlastWallMis" then self:SpellExistsThenRemove("JayceShockBlast") end
		self:AddSpell(path, path2, startPos, endPos, data, data.speed, range, 0, data.radius, menuName)
		if data.type == "threeway" then
			for i = 1, 2 do
				local eP = i == 1 and self:Rotate(startPos, endPos, MathRad(data.angle)) or
										self:Rotate(startPos, endPos, -MathRad(data.angle))
				local p1 = self:RectangleToPolygon(startPos, eP, data.radius, self.BoundingRadius)
				local p2 = self:RectangleToPolygon(startPos, eP, data.radius)
				self:AddSpell(p1, p2, startPos, eP, data, data.speed, range, 0, data.radius, menuName)
			end
		end
		self.NewTimer = GameTimer()
	end
end

function OnLoad()
	print("Loading JustEvade...")
	DelayAction(function()
		JEvade:__init()
		print("JustEvade successfully loaded!")
		ReleaseEvadeAPI();
	end, MathMax(0.07, 30 - GameTimer()))
end

-- API

function ReleaseEvadeAPI()
	_G.JustEvade = {
		Loaded = function() return JEvade.Loaded end,
		Evading = function() return JEvade.Evading end,
		IsDangerous = function(self, pos) return JEvade:IsDangerous(JEvade:To2D(pos)) end,
		SafePos = function(self) return JEvade:SafePosition() end,
		OnImpossibleDodge = function(self, func) JEvade:ImpossibleDodge(func) end,
		OnCreateMissile = function(self, func) JEvade:CreateMissile(func) end,
		OnProcessSpell = function(self, func) JEvade:ProcessSpell(func) end
	}
end

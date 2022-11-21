--[[
Version: 12.22.3 HOTFIX

Usage:

require "DamageLib"

local Qdamage = getdmg("Q",target, myHero)
local QStage2damage = getdmg("Q",target, myHero, 2)

local AAdmg = getdmg("AA",target)
-------------------------------------------------------

params: "AA" "Smite", "Ignite", "Mark" or "Dash" or SUMMONER_1/SUMMONER_2
"HEXTECH" for Hextech Rocketbelt, "EVERFROST", "GALEFORCE", "GOREDRINKER", "STRIDEBREAKER", "IRONSPIKE", "PROWLER"

getdmg(spell ,target, source, stage, level)

  spell = skills "Q", "W", "E", "R", + Monster versions ["QM", "WM", "EM"],
    Autoattack: "AA"
    Summoners: "Smite", "Ignite", "Mark" or "Dash" or SUMMONER_1/SUMMONER_2
    Items: "HEXTECH" for Hextech Rocketbelt, "EVERFROST", "GALEFORCE", "GOREDRINKER", "STRIDEBREAKER", "IRONSPIKE", "PROWLER"

  source = source [or myHero if not input]
  stage = spell stage for damagecalc [or 1 if not input]
  level = spell level [or get source:GetSpellData(spell).level if not input]

GetAADamage(source, target, respectPassives)
CalcDamage(source, target, DamageType, amount, IsAA)

------------------------------------------------------


|| INDEX ||

Special Champions/Items: {
  -- Local Functions -- {
    GetBaseHealth:
      {Sylas, Chogath, Volibear, DrMundo, Volibear, Vladimir, Maokai, KSante, Sett },
    GetBaseMana:
      {Kassadin, Ryze, },
    GetCriticalStrikePercent:
      { Akshan, Fiora, Jhin, Kalista, Yasuo, Yone, },

    GetBaseAttackspeed:
    GetAttackspeed:
  }

  -- Damage Tables -- {
  DamageReductionBuffsTable:
    { --Annie, Alistar, Amumu, Belveth, Braum, Galio[AP&AD], Garen, Gragas, Malzahar, MasterYi, },
  DamageReductionItemsTable: TODO:
    { Plated Steelcaps, }
  Post-mitigation: TODO:
    { Frozen Heart, Randuin's Omen, Warden's Mail, }

  SpecialAADamageTable:
  { Akshan, Caitlyn, Corki, Diana, Draven, Graves, Jinx, Kalista, Kayle, Nasus, Thresh, TwistedFate, Varus, Vayne, Viktor, Zac, Zeri, }
  HeroPassiveDamageTable:
  { Jhin, Lux, Orianna, Quinn, Teemo, Vayne, Zed, Zac, Zeri, },
  ItemDamageTable: TODO:
  { Recurve Bow, Kirchei's Shard, Sheen, Runaan's Hurricane, Sunfire Aegis, Trinity Force (Infinity Force), Wit's End, Rapid Firecannon, Lich Bane, Nashor's Tooth, Guinsoo's Rageblade, },
}
SpellDamageTable:
{ All Champs, },


Calculations:

-- Calc -- = {
  PassivePercentMod(source, target, DamageType, amount),
    increases %
  DamageReductionMod(source, target, DamageType, amount): DamageReductionBuffsTable & DamageReductionItemsTable
    decreases %

  CalcDamage(source, target, DamageType, amount),
    GetAADamage():{
      GetCriticalStrikePercent():
      SetHeroPassiveDamageTable():HeroPassiveDamageTable
      GetHeroAADamage():{
        GetSpecialAADamage():SpecialAADamageTable
        SetItemDamageTable():ItemDamageTable
      }
    }
}

API Release:

_G.DamageLib = {
  ItemID = ItemID,
  MeleeHeros = Hero[1],
}


TODO:
getdmg(spell/Items)
ItemID table implmentation, global?
Increasing damage received:
  Champion abilities:
    Vladimir's Hemoplague,
  Items:
    Evenshroud (Equinox)
  Runes
    Press the Attack
DamageReduction: *
  Decreasing damage received:
    Champion abilities:
      Irelia's Defiant Dance
      Jax's Counter Strike (area of effect abilities only)
      *Kassadin's Void Stone <- in DamageReductionMod()
      *--Kled's Dismount
      *Nilah's Jubilant Veil
      Warwick's Primal Howl
    Summoner Spells:
      Challenging Smite
    Items:
      Anathema's Chains
      Crown of the Shattered Queen (Caesura ) (champion damage only)
      Force of Nature (magic damage only)
      Randuin's Omen
    Runes:
      Glacial Augment
  -Pre-mitigation: <- in CalcDamage
    *Fizz's Nimble Fighter
    *Leona's Eclipse
        *Guardian's Horn
  Post-mitigation:
    *Amumu's Tantrum <- in DamageReductionBuffsTable? prob not right
      Bone Plating
OnHit = {
  Items:
    { Ardent Censer, Black Cleaver, Blade of the Ruined King, Bramble Vest, Corrupting Potion, Elixir of Sorcery, Emberknife,
    Fimbulwinter, Hailblade, Hearthbound Axe, Kircheis Shard, Manamune, Muramana
    Noonquiver, Phage, Rageknife, Ravenous Hydra, Stormrazor, Thornmail,
    Tiamat, Titanic Hydra, Winter's Approach, Zeke's Convergence, },
  Champion abilities:
    { Braum's - Concussive Blows, Nami's - Tidecaller's Blessing, Sona's - Hymn of Valor, Teemo's - Toxic Shot, }
  Passive Effects:
    { Blade of the Ruined King, Dead Man's Plate, Doran's Ring, Doran's Shield, Duskblade of Draktharr (Draktharr's Shadowcarver),
    Eclipse (Syzygy), Kircheis Shard (energized), Manamune, Noonquiver, }
  Triggered Effects:
    { Ardent Censer, Divine Sunderer (Deicide), Essence Reaver, Muramana, Zeke's Convergence, }
  Runes:
    { Demolish, Electrocute, Fleet Footwork, Grasp of the Undying, Phase Rush, Press the Attack, }
  Champion abilities:
    { Akshan's Dirty Fighting and Heroic Swing (25% effectiveness), Aphelios' Onslaught (25% effectiveness), Duskwave and Moonlight Vigil,
    Bel'Veth's Death in Lavender(75% effectiveness), Void Surge(75% effectiveness), and Royal Maelstrom(6-24% effectiveness),
    Elise's Venomous Bite, Evelynn's Whiplash and Empowered Whiplash, Ezreal's Mystic Shot, Fiora's Lunge, Fizz's Urchin Strike, Gangplank's Parrrley,
    Graves' New Destiny, Irelia's Bladesurge, Katarina's Sinister Steel, Shunpo, and Death Lotus(25 / 30 / 35% effectiveness),
    Kayle's Starfire Spellblade, Lucian's Lightslinger, Master Yi's Double Strike and Alpha Strike (75% / 18.75% effectiveness), Miss Fortune's Double Up,
    Pantheon's Empowered Shield Vault, Renekton's Ruthless Predator, Senna's Piercing Darkness, Shyvana's Twin Bite, Twitch's Spray and Pray,
    Urgot's Purge(50% effectiveness), Viego's Blade of the Ruined King and Heartbreaker, Volibear's Frenzied Maul, Warwick's Jaws of the Beast and Infinite Duress,
    Yasuo's Steel Tempest, Yone's Mortal Steel, Zeri's Burst Fire, },
}
OnDisabling = {
  Items:
  { Evenshroud (Equinox), Horizon Focus, Imperial Mandate (Seat of Command), Thornmail, Zeke's Convergence, }
  Runes:
  { Aftershock, Approach Velocity, Cheap Shot, Font of Life, Glacial Augment, }
},
GetCriticalStrikePercent:
{toggle crit for spells/champs, further crit scale to add?}
]]
print("DamageLib Loaded")
--[[
      ___           ___           ___           ___           ___           ___           ___                   ___
     /\  \         /\  \         /\__\         /\  \         /\  \         /\  \         /\__\      ___        /\  \
    /::\  \       /::\  \       /::|  |       /::\  \       /::\  \       /::\  \       /:/  /     /\  \      /::\  \
   /:/\:\  \     /:/\:\  \     /:|:|  |      /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/  /      \:\  \    /:/\:\  \
  /:/  \:\__\   /::\~\:\  \   /:/|:|__|__   /::\~\:\  \   /:/  \:\  \   /::\~\:\  \   /:/  /       /::\__\  /::\~\:\__\
 /:/__/ \:|__| /:/\:\ \:\__\ /:/ |::::\__\ /:/\:\ \:\__\ /:/__/_\:\__\ /:/\:\ \:\__\ /:/__/     __/:/\/__/ /:/\:\ \:|__|
 \:\  \ /:/  / \/__\:\/:/  / \/__/~~/:/  / \/__\:\/:/  / \:\  /\ \/__/ \:\~\:\ \/__/ \:\  \    /\/:/  /    \:\~\:\/:/  /
  \:\  /:/  /       \::/  /        /:/  /       \::/  /   \:\ \:\__\    \:\ \:\__\    \:\  \   \::/__/      \:\ \::/  /
   \:\/:/  /        /:/  /        /:/  /        /:/  /     \:\/:/  /     \:\ \/__/     \:\  \   \:\__\       \:\/:/  /
    \::/__/        /:/  /        /:/  /        /:/  /       \::/  /       \:\__\        \:\__\   \/__/        \::/__/
     ~~            \/__/         \/__/         \/__/         \/__/         \/__/         \/__/                 ~~
--]]

local DAMAGE_TYPE_PHYSICAL = 1
local DAMAGE_TYPE_MAGICAL = 2
local DAMAGE_TYPE_TRUE = 3

local myHero = myHero
local Game, Draw, Callback = _G.Game, _G.Draw, _G.Callback
local GameTimer = Game.Timer
local math_huge = math.huge
local math_pi = math.pi
local math_sqrt = assert(math.sqrt)
local math_abs = assert(math.abs)
local math_ceil = assert(math.ceil)
local math_min = assert(math.min)
local math_max = assert(math.max)
local math_floor = assert(math.floor)
local table_insert = assert(table.insert)
local table_remove = assert(table.remove)
local pairs = pairs
local ipairs = ipairs

local ItemSlots = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }
local ItemKeys = { HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4, HK_ITEM_5, HK_ITEM_6, HK_ITEM_7 }

-- Minion Info --
local MeleeMinionList = {"SRU_ChaosMinionMelee", "SRU_OrderMinionMelee", "HA_ChaosMinionMelee", "HA_OrderMinionMelee", }
local RangedMinionList = {"SRU_ChaosMinionRanged", "SRU_OrderMinionRanged", "HA_ChaosMinionRanged", "HA_OrderMinionRanged", }
local SiegeMinionList = {"SRU_ChaosMinionSiege", "SRU_OrderMinionSiege", "HA_ChaosMinionSiege", "HA_OrderMinionSiege", }
local SuperMinionList = {"SRU_ChaosMinionSuper", "SRU_OrderMinionSuper", "HA_ChaosMinionSuper", "HA_OrderMinionSuper", }
local NormalMinionList = {"SRU_ChaosMinionRanged", "SRU_OrderMinionRanged", "SRU_ChoasMinionMelee", "SRU_OrderMinionMelee", "HA_ChaosMinionMelee", "HA_OrderMinionMelee", "HA_ChaosMinionRanged", "HA_OrderMinionRanged", }
-- Monster Info --
local epicMonster = {
  "SRU_Baron",
	"SRU_RiftHerald",
  "SRU_Dragon_Elder",
	"SRU_Dragon_Water",
  "SRU_Dragon_Fire",
  "SRU_Dragon_Earth",
  "SRU_Dragon_Air",
  "SRU_Dragon_Ruined",
  "SRU_Dragon_Chemtech",
	"SRU_Dragon_Hextech",
}
--[[ local Monstertable = {
  ["SRU_Baron"] = {epicMonster = true},
	["SRU_RiftHerald"] = {epicMonster = true},
  ["SRU_Dragon_Elder"] = {epicMonster = true},

	["SRU_Dragon_Water"] = {epicMonster = true},
  ["SRU_Dragon_Fire"] = {epicMonster = true},
  ["SRU_Dragon_Earth"] = {epicMonster = true},
  ["SRU_Dragon_Air"] = {epicMonster = true},

  ["SRU_Dragon_Ruined"] = {epicMonster = true},
  ["SRU_Dragon_Chemtech"] = {epicMonster = true},
	["SRU_Dragon_Hextech"] = {epicMonster = true},

	["SRU_Blue"] = {largeMonster = true},
	["SRU_Red"] = {largeMonster = true},
	["SRU_Gromp"] = {largeMonster = true},
	["SRU_Murkwolf"] = {largeMonster = true},
	["SRU_Razorbeak"] = {largeMonster = true},
	["SRU_Krug"] = {largeMonster = true},
	["Sru_Crab"] = {largeMonster = true},
  [epicMonster] = { epicMonster = true},
  [MeleeMinionList] = { meleeMinion = true },
  [RangedMinionList] = { rangedMinion = true},
  [SiegeMinionList] = { siegeMinion = true},
  [SuperMinionList] = { superMinion = true},
  [NormalMinionList] = { normalMinion = true},
} ]]

-- Turret Info --
local TurretsInfo = {
  --blue
  ["Turret_T1_C_01_A"] = {turrettype = "Base"}, --top nexus
  ["Turret_T1_C_02_A"] = {turrettype = "Base"}, --bot nexus
  ["Turret_T1_C_06_A"] = {turrettype = "Base"}, --top inhib
  ["Turret_T1_C_03_A"] = {turrettype = "Base"}, --mid inhib
  ["Turret_T1_C_07_A"] = {turrettype = "Base"}, --botlane inhib
  ["Turret_T2_C_01_A"] = {turrettype = "Base"}, --bot nexus
  ["Turret_T2_C_02_A"] = {turrettype = "Base"}, --top nexus
  ["Turret_T2_L_01_A"] = {turrettype = "Base"}, --top inhib
  ["Turret_T2_C_03_A"] = {turrettype = "Base"}, --mid inhib
  ["Turret_T2_R_01_A"] = {turrettype = "Base"}, --botlane inhib

  ["Turret_T1_L_02_A"] = {turrettype = "Inner"}, --top inner
  ["Turret_T1_C_04_A"] = {turrettype = "Inner"}, --mid inner
  ["Turret_T1_R_02_A"] = {turrettype = "Inner"}, --botlane inner
  ["Turret_T2_L_02_A"] = {turrettype = "Inner"}, --top inner
  ["Turret_T2_C_04_A"] = {turrettype = "Inner"}, --mid inner
  ["Turret_T2_R_02_A"] = {turrettype = "Inner"}, --botlane inner

  ["Turret_T1_L_03_A"] = {turrettype = "Outer"}, --top outer
  ["Turret_T1_C_05_A"] = {turrettype = "Outer"}, --mid outer
  ["Turret_T1_R_03_A"] = {turrettype = "Outer"}, --botlane outer
  ["Turret_T2_L_03_A"] = {turrettype = "Outer"}, --top outer
  ["Turret_T2_C_05_A"] = {turrettype = "Outer"}, --mid outer
  ["Turret_T2_R_03_A"] = {turrettype = "Outer"}, --botlane outer
}
local HATurretsInfo = {
  --HA
  ["Turret_T1_C_010_A"] = {turrettype = "Base"}, --top nexus
  ["Turret_T1_C_09_A"] = {turrettype = "Base"}, --bot nexus
  ["Turret_T1_C_07_A"] = {turrettype = "Base"}, --inhib

  ["Turret_T2_L_02_A"] = {turrettype = "Base"}, --inhib
  ["Turret_T2_L_03_A"] = {turrettype = "Base"}, --bot nexus
  ["Turret_T2_L_04_A"] = {turrettype = "Base"}, --top nexus

  ["Turret_T1_C_08_A"] = {turrettype = "Outer"}, --outer
  ["Turret_T2_L_01_A"] = {turrettype = "Outer"}, --outer
}
local TurretToMinionPercent = {
  [MeleeMinionList] = 0.45,
  [RangedMinionList] = 0.70,
  [SiegeMinionList] = {Base = 0.08, Inner = 0.11, Outer = 0.14},
  [SuperMinionList] = 0.07,
}

local Hero = {
  Aatrox = { true, 0.651 },
  Ahri = { false, 0.668 },
  Akali = { true, 0.625 },
  Akshan = { false, 0.638 },
  Alistar = { true, 0.625 },
  Amumu = { true, 0.736 },
  Anivia = { false, 0.625 },
  Annie = { false, 0.579 },
  Aphelios = { false, 0.64 },
  Ashe = { false, 0.658 },
  AurelionSol = { false, 0.625 },
  Azir = { true, 0.625 },
  Bard = { false, 0.625 },
  Belveth = { true, 0.85 },
  Blitzcrank = { true, 0.625 },
  Brand = { false, 0.625 },
  Braum = { true, 0.644 },
  Caitlyn = { false, 0.681 },
  Camille = { true, 0.644 },
  Cassiopeia = { false, 0.647 },
  Chogath = { true, 0.625 },
  Corki = { false, 0.638 },
  Darius = { true, 0.625 },
  Diana = { true, 0.625 },
  Draven = { false, 0.679 },
  DrMundo = { true, 0.72 },
  Ekko = { true, 0.688 },
  Elise = { false, 0.625 },
  Evelynn = { true, 0.667 },
  Ezreal = { false, 0.625 },
  FiddleSticks = { false, 0.625 },
  Fiora = { true, 0.69 },
  Fizz = { true, 0.658 },
  Galio = { true, 0.625 },
  Gangplank = { true, 0.658 },
  Garen = { true, 0.625 },
  Gnar = { false, 0.625 },
  Gragas = { true, 0.675 },
  Graves = { false, 0.475 },
  Gwen = { true, 0.69 },
  Hecarim = { true, 0.67 },
  Heimerdinger = { false, 0.625 },
  Illaoi = { true, 0.625 },
  Irelia = { true, 0.656 },
  Ivern = { true, 0.644 },
  Janna = { false, 0.625 },
  JarvanIV = { true, 0.658 },
  Jax = { true, 0.638 },
  Jayce = { false, 0.658 },
  Jhin = { false, 0.625 },
  Jinx = { false, 0.625 },
  Kaisa = { false, 0.644 },
  Kalista = { false, 0.694 },
  Karma = { false, 0.625 },
  Karthus = { false, 0.625 },
  Kassadin = { true, 0.64 },
  Katarina = { true, 0.658 },
  Kayle = { false, 0.625 },
  Kayn = { true, 0.669 },
  Kennen = { false, 0.625 },
  Khazix = { true, 0.668 },
  Kindred = { false, 0.625 },
  Kled = { true, 0.625 },
  KogMaw = { false, 0.665 },
  KSante = { true, 0.625 },
  Leblanc = { false, 0.625 },
  LeeSin = { true, 0.651 },
  Leona = { true, 0.625 },
  Lillia = { true, 0.625 },
  Lissandra = { false, 0.656 },
  Lucian = { false, 0.638 },
  Lulu = { false, 0.625 },
  Lux = { false, 0.669 },
  Malphite = { true, 0.736 },
  Malzahar = { false, 0.625 },
  Maokai = { true, 0.8 },
  MasterYi = { true, 0.679 },
  MissFortune = { false, 0.656 },
  MonkeyKing = { true, 0.680 },
  Mordekaiser = { true, 0.625 },
  Morgana = { false, 0.625 },
  Nami = { false, 0.644 },
  Nasus = { true, 0.638 },
  Nautilus = { true, 0.706 },
  Neeko = { false, 0.625 },
  Nidalee = { false, 0.638 },
  Nilah = { true, 0.697 },
  Nocturne = { true, 0.721 },
  Nunu = { true, 0.625 },
  Olaf = { true, 0.694 },
  Orianna = { false, 0.658 },
  Ornn = { true, 0.625 },
  Pantheon = { true, 0.644 },
  Poppy = { true, 0.625 },
  Pyke = { true, 0.667 },
  Qiyana = { true, 0.688 },
  Quinn = { false, 0.668 },
  Rakan = { true, 0.635 },
  Rammus = { true, 0.656 },
  RekSai = { true, 0.667 },
  Rell = { true, 0.55 },
  Renata = { false, 0.625 },
  Renekton = { true, 0.665 },
  Rengar = { true, 0.667 },
  Riven = { true, 0.625 },
  Rumble = { true, 0.644 },
  Ryze = { false, 0.625 },
  Samira = { false, 0.658 },
  Sejuani = { true, 0.688 },
  Senna = { true, 0.625 },
  Seraphine = { false, 0.669 },
  Sett = { true, 0.625 },
  Shaco = { true, 0.694 },
  Shen = { true, 0.751 },
  Shyvana = { true, 0.658 },
  Singed = { true, 0.613 },
  Sion = { true, 0.679 },
  Sivir = { false, 0.625 },
  Skarner = { true, 0.625 },
  Sona = { false, 0.644 },
  Soraka = { false, 0.625 },
  Swain = { false, 0.625 },
  Sylas = { true, 0.645 },
  Syndra = { false, 0.625 },
  TahmKench = { true, 0.658 },
  Taliyah = { false, 0.625 },
  Talon = { true, 0.625 },
  Taric = { true, 0.625 },
  Teemo = { false, 0.69 },
  Thresh = { true, 0.625 },
  Tristana = { false, 0.656 },
  Trundle = { true, 0.67 },
  Tryndamere = { true, 0.67 },
  TwistedFate = { false, 0.651 },
  Twitch = { false, 0.679 },
  Udyr = { true, 0.650 },
  Urgot = { true, 0.625 },
  Varus = { false, 0.658 },
  Vayne = { false, 0.658 },
  Veigar = { false, 0.625 },
  Velkoz = { false, 0.625 },
  Vex = { false, 0.669 },
  Vi = { true, 0.644 },
  Viego = { true, 0.658 },
  Viktor = { false, 0.658 },
  Vladimir = { false, 0.658 },
  Volibear = { true, 0.625 },
  Warwick = { true, 0.638 },
  Xayah = { false, 0.625 },
  Xerath = { false, 0.625 },
  XinZhao = { true, 0.645 },
  Yasuo = { true, 0.697 },
  Yone = { true, 0.625 },
  Yorick = { true, 0.625 },
  Yuumi = { false, 0.625 },
  Zac = { true, 0.736 },
  Zed = { true, 0.651 },
  Zeri = { false, 0.658 },
  Ziggs = { false, 0.656 },
  Zilean = { false, 0.625 },
  Zoe = { false, 0.625 },
  Zyra = { false, 0.625 },
}

local HeroSpecialMelees = {
["Elise"] = function()
  return myHero.range < 200
end,
["Gnar"] = function()
  return myHero.range < 200
end,
["Jayce"] = function()
  return myHero.range < 200
end,
["Kayle"] = function()
  return myHero.range < 200
end,
["Nidalee"] = function()
  return myHero.range < 200
end,
}
local ItemID = {
  SilverSerpents = 500,
  Boots = 1001,
  FaerieCharm = 1004,
  RejuvenationBead = 1006,
  GiantsBelt = 1011,
  CloakofAgility = 1018,
  BlastingWand = 1026,
  SapphireCrystal = 1027,
  RubyCrystal = 1028,
  ClothArmor = 1029,
  ChainVest = 1031,
  NullMagicMantle = 1033,
  Emberknife = 1035, --removed 12.22
  LongSword = 1036,
  Pickaxe = 1037,
  BFSword = 1038,
  Hailblade = 1039, --removed 12.22
  ObsidianEdge = 1040,
  Dagger = 1042,
  RecurveBow = 1043,
  AmplifyingTome = 1052,
  VampiricScepter = 1053,
  DoransShield = 1054,
  DoransBlade = 1055,
  DoransRing = 1056,
  NegatronCloak = 1057,
  NeedlesslyLargeRod = 1058,
  DarkSeal = 1082,
  Cull = 1083,
  ScorchclawPup = 1101,
  GustwalkerHatchling = 1102,
  MosstomperSeedling = 1103,
  EyeoftheHerald = 1104 or 3513,
  PenetratingBullets = 1500,
  Fortification = 1501,
  ReinforcedArmor = 1502 or 1506,
  WardensEye = 1503,
  Vanguard = 1504,
  LightningRod = 1505,
  Overcharged = 1507,
  AntitowerSocks = 1508,
  Gusto = 1509,
  PhreakishGusto = 1510,
  SuperMechArmor = 1511,
  SuperMechPowerField = 1512,
  TurretPlating = 1515,
  StructureBounty = 1516 or 1517 or 1518 or 1519,
  HealthPotion = 2003,
  TotalBiscuitofEverlastingWill = 2010,
  KircheisShard = 2015,
  RefillablePotion = 2031,
  CorruptingPotion = 2033,
  GuardiansHorn = 2051,
  PoroSnax = 2052,
  ControlWard = 2055,
  ShurelyasBattlesong = 2065,
  ElixirofIron = 2138,
  ElixirofSorcery = 2139,
  ElixirofWrath = 2140,
  MinionDematerializer = 2403,
  CommencingStopwatch = 2419,
  Stopwatch = 2420,
  BrokenStopwatch = 2421 or 2424,
  SlightlyMagicalFootwear = 2422,
  PerfectlyTimedStopwatch = 2423,
  Evenshroud = 3001,
  ArchangelsStaff = 3003,
  Manamune = 3004,
  BerserkersGreaves = 3006,
  BootsofSwiftness = 3009,
  ChemtechPutrifier = 3011,
  SorcerersShoes = 3020,
  GlacialBuckler = 3024,
  GuardianAngel = 3026,
  InfinityEdge = 3031,
  MortalReminder = 3033,
  LastWhisper = 3035,
  LordDominiksRegards = 3036,
  SeraphsEmbrace = 3040,
  MejaisSoulstealer = 3041,
  Muramana = 3042,
  Phage = 3044,
  PhantomDancer = 3046,
  PlatedSteelcaps = 3047,
  ZekesConvergence = 3050,
  HearthboundAxe = 3051,
  SteraksGage = 3053,
  Sheen = 3057,
  SpiritVisage = 3065,
  WingedMoonplate = 3066,
  Kindlegem = 3067,
  SunfireAegis = 3068,
  TearoftheGoddess = 3070,
  BlackCleaver = 3071,
  Bloodthirster = 3072,
  RavenousHydra = 3074,
  Thornmail = 3075,
  BrambleVest = 3076,
  Tiamat = 3077,
  TrinityForce = 3078,
  WardensMail = 3082,
  WarmogsArmor = 3083,
  Heartsteel = 3084,
  RunaansHurricane = 3085,
  Zeal = 3086,
  RabadonsDeathcap = 3089,
  WitsEnd = 3091,
  RapidFirecannon = 3094,
  Stormrazor = 3095,
  LichBane = 3100,
  BansheesVeil = 3102,
  AegisoftheLegion = 3105,
  Redemption = 3107,
  FiendishCodex = 3108,
  KnightsVow = 3109,
  FrozenHeart = 3110,
  MercurysTreads = 3111,
  GuardiansOrb = 3112,
  AetherWisp = 3113,
  ForbiddenIdol = 3114,
  NashorsTooth = 3115,
  RylaisCrystalScepter = 3116,
  MobilityBoots = 3117,
  WintersApproach = 3119,
  Fimbulwinter = 3121,
  ExecutionersCalling = 3123,
  GuinsoosRageblade = 3124,
  CaulfieldsWarhammer = 3133,
  SerratedDirk = 3134,
  VoidStaff = 3135,
  MercurialScimitar = 3139,
  QuicksilverSash = 3140,
  YoumuusGhostblade = 3142,
  RanduinsOmen = 3143,
  HextechAlternator = 3145,
  HextechRocketbelt = 3152,
  BladeofTheRuinedKing = 3153,
  Hexdrinker = 3155,
  MawofMalmortius = 3156,
  ZhonyasHourglass = 3157,
  IonianBootsofLucidity = 3158,
  SpearOfShojin = 3161,
  Morellonomicon = 3165,
  GuardiansBlade = 3177,
  UmbralGlaive = 3179,
  Hullbreaker = 3181,
  GuardiansHammer = 3184,
  LocketoftheIronSolari = 3190,
  SeekersArmguard = 3191,
  GargoyleStoneplate = 3193,
  SpectresCowl = 3211,
  MikaelsBlessing = 3222,
  ScarecrowEffigy = 3330,
  StealthWard = 3340,
  FarsightAlteration = 3363,
  OracleLens = 3364,
  YourCut = 3400,
  ArdentCenser = 3504,
  EssenceReaver = 3508,
  KalistasBlackSpear = 3599 or 3600,
  DeadMansPlate = 3742,
  TitanicHydra = 3748,
  CrystallineBracer = 3801,
  LostChapter = 3802,
  CatalystofAeons = 3803,
  EdgeofNight = 3814,
  SpellthiefsEdge = 3850,
  Frostfang = 3851,
  ShardofTrueIce = 3853,
  SteelShoulderguards = 3854,
  RunesteelSpaulders = 3855,
  PauldronsofWhiterock = 3857,
  RelicShield = 3858,
  TargonsBuckler = 3859,
  BulwarkoftheMountain = 3860,
  SpectralSickle = 3862,
  HarrowingCrescent = 3863,
  BlackMistScythe = 3864,
  FireatWill = 3901,
  DeathsDaughter = 3902,
  RaiseMorale = 3903,
  OblivionOrb = 3916,
  ImperialMandate = 4005,
  ForceofNature = 4401,
  TheGoldenSpatula = 4403,
  HorizonFocus = 4628,
  CosmicDrive = 4629,
  BlightingJewel = 4630,
  VerdantBarrier = 4632,
  Riftmaker = 4633,
  LeechingLeer = 4635,
  NightHarvester = 4636,
  DemonicEmbrace = 4637,
  WatchfulWardstone = 4638,
  StirringWardstone = 4641,
  BandleglassMirror = 4642,
  VigilantWardstone = 4643,
  CrownoftheShatteredQueen = 4644,
  Shadowflame = 4645,
  IronspikeWhip = 6029,
  SilvermereDawn = 6035,
  DeathsDance = 6333,
  ChempunkChainsword = 6609,
  StaffofFlowingWater = 6616,
  MoonstoneRenewer = 6617,
  Goredrinker = 6630,
  Stridebreaker = 6631,
  DivineSunderer = 6632,
  LiandrysAnguish = 6653,
  LudensTempest = 6655,
  Everfrost = 6656,
  RodofAges = 6657,
  BamisCinder = 6660,
  IcebornGauntlet = 6662,
  TurboChemtank = 6664,
  JakShoTheProtean = 6665,
  RadiantVirtue = 6667,
  Noonquiver = 6670,
  Galeforce = 6671,
  KrakenSlayer = 6672,
  ImmortalShieldbow = 6673,
  NavoriQuickblades = 6675,
  TheCollector = 6676,
  Rageknife = 6677,
  DuskbladeofDraktharr = 6691,
  Eclipse = 6692,
  ProwlersClaw = 6693,
  SeryldasGrudge = 6694,
  SerpentsFang = 6695,
  AxiomArc = 6696,
  SandshrikesClaw = 7000,
  Syzygy = 7001,
  DraktharrsShadowcarver = 7002,
  FrozenFist = 7005,
  Typhoon = 7006,
  WyrmfallenSacrifice = 7007,
  Bloodward = 7008,
  IcathiasCurse = 7009,
  Vespertide = 7010,
  UpgradedAeropack = 7011,
  LiandrysLament = 7012,
  EyeofLuden = 7013,
  EternalWinter = 7014,
  CeaselessHunger = 7015,
  Dreamshatter = 7016,
  Deicide = 7017,
  InfinityForce = 7018,
  ReliquaryoftheGoldenDawn = 7019,
  ShurelyasRequiem = 7020,
  Starcaster = 7021,
  SeatofCommand = 7022,
  Equinox = 7023,
  Caesura = 7024,
  Leviathan = 7025,
  TheUnspokenParasite = 7026,
  PrimordialDawn = 7027,
  InfiniteConvergence = 7028,
  GangplankPlaceholder = 7050,
  AnathemasChains = 8001,
  AbyssalMask = 8020,
}

-- Local Functions --
local table_contains = function(table, x)
  local found = false
  for _, v in pairs(table) do
      if v == x then
          found = true
      end
  end
  return found
end

local GetBaseHealth = function(unit)
  if unit.charName == "Sylas" then
    return 575 + (129 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  elseif unit.charName == "Chogath" then
    return 607 + (110 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  elseif unit.charName == "Volibear" then
    return 650 + (104 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  elseif unit.charName == "Vladimir" then
    return 537 + (96 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  elseif unit.charName == "DrMundo" then
    return 653 + (103 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  elseif unit.charName == "Maokai" then
    return 635 + (109 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  elseif unit.charName == "KSante" then
    return 610 + (104 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  elseif unit.charName == "Sett" then
    return 670 + (114 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  elseif unit.charName == "Nunu" then
    return 610 + (90 * (unit.levelData.lvl - 1))*(0.7025+(0.0175*(unit.levelData.lvl-1)))
  end
end

local GetBaseMana = function(unit)
  if unit.charName == "Kassadin" then
    return 300 + (70 * (unit.levelData.lvl - 1))
  elseif unit.charName == "Ryze" then
    return 400 + (87 * (unit.levelData.lvl - 1))
  end
end

local GetBaseAttackspeed = function(unit)
  local baseattackspeed = Hero[unit.charName][2]
  if baseattackspeed then
    return baseattackspeed
  end
end

local GetAttackspeed = function(unit)
  local baseattackspeed = GetBaseAttackspeed(unit)
  if baseattackspeed then
    return unit.attackSpeed * baseattackspeed
  end
end

local Cached = {
	Buffs = {},
	Reset = function(self)
		for k in pairs(self.Buffs) do
			self.Buffs[k] = nil
		end
	end,

	Buff = function(self, b)
		local class = {}
		local members = {}
		local metatable = {}
		local _b = b
		function metatable.__index(s, k)
			if members[k] == nil then
				if k == "duration" then
					members[k] = _b.duration
				elseif k == "count" then
					members[k] = _b.count
				elseif k == "stacks" then
					members[k] = _b.stacks
				else
					members[k] = _b[k]
				end
			end
			return members[k]
		end
		setmetatable(class, metatable)
		return class
	end,

	GetBuffs = function(self, o)
		local id = o.networkID
		if self.Buffs[id] == nil then
			local count = o.buffCount
			if count and count >= 0 and count < 10000 then
				local b, b2 = nil, nil
				local buffs = {}
				for i = 0, count do
					b = o:GetBuff(i)
					if b then
						b2 = self:Buff(b)
						if b2.count > 0 then
							table_insert(buffs, b2)
						end
					end
				end
				self.Buffs[id] = buffs
			end
		end
		return self.Buffs[id] or {}
	end,
}

local GetPercentHP = function(unit)
  return 100 * unit.health / unit.maxHealth
end

local GetPercentMissingHP = function(unit)
  return (1 - (unit.health / unit.maxHealth)) * 100
end

local GetMissingHP = function(unit)
  return (unit.maxHealth - unit.health)
end

-- Items --
local GetItemSlot = function(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then return i end
  end
  return 0
end

local Item = {
	CachedItems = {},

  OnTick = function(self)
		self.CachedItems = {}
	end,

	GetItemById = function(self, unit, id)
		local networkID = unit.networkID
		if self.CachedItems[networkID] == nil then
			local t = {}
			for i = 1, #ItemSlots do
				local slot = ItemSlots[i]
				local item = unit:GetItemData(slot)
				if item ~= nil and item.itemID ~= nil and item.itemID > 0 then
					t[item.itemID] = i
				end
			end
			self.CachedItems[networkID] = t
		end
		return self.CachedItems[networkID][id]
	end,

	HasItem = function(self, unit, id)
		return self:GetItemById(unit, id) ~= nil
	end,
}

-- Buffs --
local GotBuff = function(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then
      return buff.count
    end
  end
  return 0
end

local GetBuffData = function(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

local Buff = {

	GetBuffDuration = function(self, unit, name)
		name = name:lower()
		local result = 0
		local buff = nil
		local buffs = Cached:GetBuffs(unit)
		for i = 1, #buffs do
			buff = buffs[i]
			if buff.name:lower() == name then
				local duration = buff.duration
				if duration > result then
					result = duration
				end
			end
		end
		return result
	end,

	GetBuffs = function(self, unit)
		return Cached:GetBuffs(unit)
	end,

	GetBuff = function(self, unit, name)
		name = name:lower()
		local result = nil
		local buff = nil
		local buffs = Cached:GetBuffs(unit)
		for i = 1, #buffs do
			buff = buffs[i]
			if buff.name:lower() == name then
				result = buff
				break
			end
		end
		return result
	end,

	HasBuffContainsName = function(self, unit, name)
		name = name:lower()
		local buffs = Cached:GetBuffs(unit)
		local result = false
		for i = 1, #buffs do
			if buffs[i].name:lower():find(name) then
				result = true
				break
			end
		end
		return result
	end,

  	HasBuffContainsNameCount = function(self, unit, name)
		name = name:lower()
		local buffs = Cached:GetBuffs(unit)
		local result = 0
		for i = 1, #buffs do
			if buffs[i].name:lower():find(name) then
				result = result + 1
			end
		end
		return result
	end,

	ContainsBuffs = function(self, unit, arr)
		local buffs = Cached:GetBuffs(unit)
		local result = false
		for i = 1, #buffs do
			if arr[buffs[i].name:lower()] then
				result = true
				break
			end
		end
		return result
	end,

	HasBuff = function(self, unit, name)
		name = name:lower()
		local buffs = Cached:GetBuffs(unit)
		local result = false
		for i = 1, #buffs do
			if buffs[i].name:lower() == name then
				result = true
				break
			end
		end
		return result
	end,

	HasBuffTypes = function(self, unit, arr)
		local buffs = Cached:GetBuffs(unit)
		local result = false
		for i = 1, #buffs do
			if arr[buffs[i].type] then
				result = true
				break
			end
		end
		return result
	end,

	GetBuffCount = function(self, unit, name)
		name = name:lower()
		local result = 0
		local buff = nil
		local buffs = Cached:GetBuffs(unit)
		for i = 1, #buffs do
			buff = buffs[i]
			if buff.name:lower() == name then
				local count = buff.count
				if count > result then
					result = count
				end
			end
		end
		return result
	end,

	Print = function(self, target)
		local result = ""
		local buffs = self:GetBuffs(target)
		for i = 1, #buffs do
			local buff = buffs[i]
			result = result .. buff.name .. ": count=" .. buff.count .. " duration=" .. tostring(buff.duration) .. "\n"
		end
		local pos2D = target.pos:To2D()
		local posX = pos2D.x - 50
		local posY = pos2D.y
		Draw.Text(result, 22, posX + 50, posY - 15)
	end,
}

local GotSpell = function(spellslot, spellname)
    if myHero:GetSpellData(spellslot).name == spellname then
      return 1
    end
    return 0
end

local HasPoison = function(unit)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
		if buff.type == 24 and GameTimer() < buff.expireTime - 0.141  then
			return true
		end
	end
	return false
end

local GetTurretType = function(name, type)
  local Turrets = {}
  local mapID = Game.mapID
  if mapID == HOWLING_ABYSS then
    Turrets = HATurretsInfo
  elseif mapID == SUMMONERS_RIFT then
    Turrets = TurretsInfo
  else
    print("No Turret Data - Unsupported Map")
  end
  if Turrets[name] then
    if type == Turrets[name.name].turrettype then
      return true and Turrets
    end
  end
  return false
end

local IsMelee = function(unit)
  local IsHeroMelee = Hero[unit.charName][1]
  local IsHeroSpecialMelee = HeroSpecialMelees[unit.charName]
  if IsHeroMelee or (IsHeroSpecialMelee and IsHeroSpecialMelee()) then
    return true
  end
  return false
end

-- Calc Damage Tables --
local DamageReductionBuffsTable = {
  --["Annie"] = {buff = "AnnieE", amount = function(target) return 1 - ({0.10,0.13,0.16,0.19,0.22})[target:GetSpellData(_E).level] end},
  ["Alistar"] = {buff = "FerociousHowl", amount = function(target) return 1 - ({0.55, 0.65, 0.75})[target:GetSpellData(_R).level] end},
  --MOVED is flatreduction["Amumu"] = {buff = "Tantrum", DamageType = 1, amount = function(target) return (({5, 7, 9, 11, 13})[target:GetSpellData(_E).level] + (0.03 * target.bonusMagicResist) + (0.03 * target.bonusArmor)) end}, --max 50%
  ["Belveth"] = {buff = "BelvethE", amount = function(target) return 1 - 0.7 end},
  ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level] end},
  ["Galio"] = {buff = "galiowpassivedefense", DamageType = 2, amount = function(target) return 1 - ({0.2, 0.25, 0.30, 0.35, 0.40})[target:GetSpellData(_W).level] + (0.05 * target.ap / 100) + (0.8 * target.bonusMagicResist / 100) end},
  ["Galio"] = {buff = "galiowpassivedefense", DamageType = 1, amount = function(target) return 1 - ({0.1, 0.125, 0.15, 0.175, 0.20})[target:GetSpellData(_W).level] + (0.025 * target.ap / 100) + (0.4 * target.bonusMagicResist / 100) end},
  ["Garen"] = {buff = "GarenW", amount = function(target) return 1 - 0.3 end},
  ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return 1 - ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level] + 0.04 * target.ap / 100 end},
  ["KSante"] = {buff = "KSanteW", amount = function(source, target) return 1 - 0.25 + (0.10 * math_floor(target.bonusArmor/100)) + (0.10 * math_floor(target.bonusMagicResist/100)) + (0.10 * math_floor((target.maxHealth - GetBaseHealth(target))/100)) end},
  ["Malzahar"] = {buff = "malzaharpassiveshield", amount = function(target) return 1 - 0.9 end},
  ["MasterYi"] = {buff = "Meditate", amount = function(source, target) return 1 - ({0.45, 0.475, 0.50, 0.525, 0.55})[target:GetSpellData(_W).level] / (source.type == Obj_AI_Turret and 2 or 1) end},
  ["NilahW"] = {buff = "NilahW", DamageType = 2, amount = function(target) return 1 - 0.25 end}, --TODO:
}

local DamageReductionItemsTable = {
  [ItemID.PlatedSteelcaps] = {IsAA = true, amount = function(source, target, DamageType, amount) --3047 Plated Steelcaps
      --if AA and not SourceIsTurret then dmg = dmg * (1-0.12)
      return 1 - 0.12
    end},
  [ItemID.FrozenHeart] = {IsAA = true, amount = function(source, target, DamageType, amount) --3110 Frozen Heart
      --if AA then dmg = dmg - (5 + 3.5 per 1000 hp) cap at 40% of dmg
      return math_max(5 + (3.5 * math_floor(target.maxHealth / 1000)), amount*0.40)
    end},
  [ItemID.RanduinsOmen] = {IsAA = true, amount = function(source, target, DamageType, amount) --3143 Randuin's Omen
      --if AA then dmg = dmg - (7 + 3.5 per 1000 hp) cap at 40% of dmg
      return math_max(7+ (3.5 * math_floor(target.maxHealth / 1000)), amount*0.40)
    end},
  [ItemID.WardensMail] = {IsAA = true, amount = function(source, target, DamageType, amount) --3082 Warden's Mail
      --if AA then dmg = dmg - (7 + 3.5 per 1000 hp) cap at 40% of dmg
      return math_max(7+ (3.5 * math_floor(target.maxHealth / 1000)), amount*0.40)
    end},
  [ItemID.ForceofNature] = {buff = "4401maxstacked", IsAA = false, DamageType = 2,  amount = function(source, target, DamageType, amount)
      --if buff and magic damage then (1 - 0.25)
      if DamageType == 2 then
        return (1 - 0.25)
      end
    end},
}
--[[ TODO:
  Chemtech Blight damage increase/reduction
  --8020 Abyssal Mask
  --3193 Gargoyle Stoneplate
  --8001 Anathema's Chains
]]
local SpecialAADamageTable = {
  --Spell/Skills
  ["Blitzcrank"] = function(args) --BlitzcrankW
    if Buff:HasBuff(args.source, "Overdrive") then
      local unitLevel = args.source.levelData.lvl
      local maxHealth = (1 / 100 * args.Target.maxHealth)
      if args.TargetIsMinion then
        args.RawMagical = (maxHealth) +
            ({ 60, 80, 100, 120, 140, 160, 165, 170, 175, 180, 185, 190, 195, 200, 205, 210, 215, 220 })[unitLevel] -- (60+120, 17*(unitLevel-1))
      else
        args.RawMagical = (maxHealth)
      end
    end
  end,

  ["Kayle"] = function(args) --KayleE
    local level = args.source:GetSpellData(_E).level
    if level > 0 then
      if Buff:HasBuff(args.source, "JudicatorRighteousFury") then
        args.RawMagical = args.RawMagical + 10 + 10 * level + 0.3 * args.source.ap
      else
        args.RawMagical = args.RawMagical + 5 + 5 * level + 0.15 * args.source.ap
      end
    end
  end,

  ["Nasus"] = function(args) --NasusQ
    if Buff:HasBuff(args.source, "NasusQ") then
      args.RawPhysical = args.RawPhysical
          + math_max(Buff:GetBuffCount(args.source, "NasusQStacks"), 0)
          + 10
          + 20 * args.source:GetSpellData(_Q).level
    end
  end,

  ["Nilah"] = function(args) --NilahQ
    if Buff:HasBuff(args.source, "NilahQ") then
      args.RawPhysical = args.RawPhysical
          + 1.0 * args.source.totalDamage
    end
  end,

  ["Thresh"] = function(args) --ThreshE
    local level = args.source:GetSpellData(_E).level
    if level > 0 then
      local damage = math_max(Buff:GetBuffCount(args.source, "threshpassivesouls"), 0)
          + (0.5 + 0.3 * level) * args.source.totalDamage
      if Buff:HasBuff(args.source, "threshqpassive4") then
        damage = damage * 1
      elseif Buff:HasBuff(args.source, "threshqpassive3") then
        damage = damage * 0.5
      elseif Buff:HasBuff(args.source, "threshqpassive2") then
        damage = damage * 1 / 3
      else
        damage = damage * 0.25
      end
      args.RawMagical = args.RawMagical + damage
    end
  end,

  ["TwistedFate"] = function(args) --TwistedFateW
    if Buff:HasBuff(args.source, "cardmasterstackparticle") then
      args.RawMagical = args.RawMagical + 30 + 25 * args.source:GetSpellData(_E).level + 0.5 * args.source.ap
    end
    if Buff:HasBuff(args.source, "BlueCardPreAttack") then
      args.DamageType = DAMAGE_TYPE_MAGICAL
      args.RawMagical = args.RawMagical + 20 + 20 * args.source:GetSpellData(_W).level + 0.5 * args.source.ap
    elseif Buff:HasBuff(args.source, "RedCardPreAttack") then
      args.DamageType = DAMAGE_TYPE_MAGICAL
      args.RawMagical = args.RawMagical + 15 + 15 * args.source:GetSpellData(_W).level + 0.5 * args.source.ap
    elseif Buff:HasBuff(args.source, "GoldCardPreAttack") then
      args.DamageType = DAMAGE_TYPE_MAGICAL
      args.RawMagical = args.RawMagical + 7.5 + 7.5 * args.source:GetSpellData(_W).level + 0.5 * args.source.ap
    end
  end,

  ["Udyr"] = function(args) --Udyr Q and R
    if Buff:HasBuff(args.source, "UdyrPAttackReady") then
      local level = args.source.levelData.lvl
      local qlevel = args.source:GetSpellData(_Q).level
      if Buff:HasBuff(args.source, "UdyrQ") then
        args.DamageType = DAMAGE_TYPE_PHYSICAL
        args.RawPhysical = args.RawPhysical + ({ 5, 13, 21, 29, 37, 45 })[qlevel] + (0.20 * args.source.bonusDamage) +
            (
            ({ 3.00, 4.40, 5.80, 7.20, 8.60, 10.00 })[qlevel] / 100 +
                (0.06 * math_floor(args.source.bonusDamage / 100)) * args.Target.maxHealth)
      elseif Buff:HasBuff(args.source, "UdyrR") then
        args.DamageType = DAMAGE_TYPE_MAGICAL
        args.RawMagical = args.RawMagical + (10 + 20 / 17 * (level - 1)) + (0.30 * args.source.ap)
      end
    end
  end,

  ["Varus"] = function(args) --VarusW
    local level = args.source:GetSpellData(_W).level
    if level > 0 then
      args.RawMagical = args.RawMagical + 6 + 4 * level + 0.25 * args.source.ap
    end
  end,

  ["Viktor"] = function(args) --ViktorQ
    if Buff:HasBuff(args.source, "ViktorPowerTransferReturn") then
      local level = args.source:GetSpellData(_Q).level
      args.DamageType = DAMAGE_TYPE_MAGICAL
      args.RawMagical = args.RawMagical + ({ 20, 45, 70, 95, 120 })[level] + 0.6 * args.source.ap +
          1.0 * args.source.totalDamage
    end
  end,

  ["Vayne"] = function(args) --VayneQ
    if Buff:HasBuff(args.source, "vaynetumblebonus") then
      args.RawPhysical = args.RawPhysical
          + (0.25 + 0.05 * args.source:GetSpellData(_Q).level) * args.source.totalDamage
    end
  end,

  ["Zac"] = function(args) --ZacQ
    local level = args.source:GetSpellData(_Q).level
    args.DamageType = DAMAGE_TYPE_MAGICAL
    args.RawMagical = ({ 40, 55, 70, 85, 100 })[level] + (0.3 * args.source.ap) + (0.025 * args.source.maxHealth)
  end,

  ["Zeri"] = function(args) --ZeriQ
    args.DamageType = DAMAGE_TYPE_MAGICAL
    args.RawTotal = args.RawTotal * 0
    args.RawPhysical = args.RawTotal
    local small = { 15, 16, 17, 18, 19, 20, 22, 23, 24, 26, 27, 29, 31, 32, 34, 36, 38, 40 }
    local big = { 90, 94, 99, 104, 109, 115, 121, 127, 133, 140, 146, 153, 160, 168, 175, 183, 191, 200 }
    if Buff:HasBuff(myHero, "zeriqpassiveready") then
      args.RawMagical = 90 + (110 / 17) * (args.source.levelData.lvl - 1) * (0.7025 +
          0.0175 * (args.source.levelData.lvl - 1)) + args.source.ap * 0.90 +
          (1 + (14 / 17) * (args.source.levelData.lvl - 1) * (0.7025 + 0.0175 * (args.source.levelData.lvl - 1))) --big[math_max(math_min(args.source.levelData.lvl, 18), 1)] + args.source.ap * 0.8
    else
      args.RawMagical = 10 + (15 / 17) * (args.source.levelData.lvl - 1) * (0.7025 + 0.0175 *
          (args.source.levelData.lvl - 1)) + args.source.ap * 0.03 --small[math_max(math_min(args.source.levelData.lvl, 18), 1)] + args.source.ap * 0.04
    end
  end,

}

local HeroPassiveDamageTable = {
  --Passives/Buffs
  ["Blitzcrank"] = function(args) --BlitzcrankE TODO: R passive
    if Buff:HasBuff(args.source, "PowerFist") then --PowerFistAttack
      local level = args.source.levelData.lvl
      if args.TargetIsMinion then
        args.RawPhysical = args.RawPhysical + (2.00 * args.source.totalDamage) + (0.25 * args.source.ap)
      else
        args.RawPhysical = args.RawPhysical + (1.75 * args.source.totalDamage) + (0.25 * args.source.ap)
      end
    end
  end,

  ["Akshan"] = function(args) --Akshan
    args.RawPhysical = args.RawPhysical
        + 0.50 * args.source.totalDamage
  end,

  ["Ashe"] = function(args) --Ashe
    if Buff:HasBuff(args.Target, "frost") then
      args.RawPhysical = args.RawPhysical
          + 1.10 * args.source.critChance
    end
  end,

  ["Caitlyn"] = function(args) --Caitlyn headshot
    if Buff:HasBuff(args.source, "caitlynpassivedriver") then
      --local modCrit = 1.09375 + (Item:HasItem(args.source, ItemID.InfinityEdge) and 0.21875 or 0)
      --local modCrit =  1.75 + (((Item:HasItem(args.source, ItemID.InfinityEdge)) and (args.source.critChance >= 0.60) and 0.35) or 0) --actual crit
      local modCrit = 1.3125 + (Item:HasItem(args.source, ItemID.InfinityEdge) and 0.2625 or 0) --1.3125 or 131.25% = 75% * standard critical damage factor
      if args.TargetIsMinion then
        local unitLevel = args.source.levelData.lvl
        local modLevel = unitLevel < 7 and 1.10 or (unitLevel < 13 and 1.15 or 1.20)
        --args.RawPhysical = args.RawPhysical + (1 + (modCrit * args.source.critChance)) * args.source.totalDamage
        args.RawPhysical = args.RawPhysical +
            (1 + (modCrit * args.source.critChance)) * (args.source.totalDamage * modLevel)
      else
        local unitLevel = args.source.levelData.lvl
        local modLevel = unitLevel < 7 and 0.60 or (unitLevel < 13 and 0.90 or 1.20)
        args.RawPhysical = args.RawPhysical
            + (1 + (modCrit * args.source.critChance)) * (args.source.totalDamage * modLevel)
      end
    end
  end,

  ["Corki"] = function(args) --Corki
    args.RawPhysical = args.RawTotal * 0.2
    args.RawMagical = args.RawTotal * 0.80
  end,

  ["Diana"] = function(args) --Diana AA
    if Buff:GetBuffCount(args.source, "dianapassivemarker") == 2 then
      local level = args.source.levelData.lvl
      args.RawMagical = args.RawMagical
          + ({ 20, 25, 30, 35, 40, 45, 55, 65, 75, 85, 95, 110, 125, 140, 150, 170, 195, 220 })[level]
          --math_max(15 + 5 * level, -10 + 10 * level, -60 + 15 * level, -125 + 20 * level, -200 + 25 * level)
          + 0.5 * args.source.ap
    end
  end,

  ["Draven"] = function(args) --Draven
    if Buff:HasBuff(args.source, "DravenSpinningAttack") then
      local level = args.source:GetSpellData(_Q).level
      args.RawPhysical = args.RawPhysical + 25 + 5 * level + (0.55 + 0.1 * level) * args.source.bonusDamage
    end
  end,

  ["Fiora"] = function(args) --Fiora E passive for AA
    if Buff:HasBuff(args.source, "fiorae2") then
      args.CriticalStrike = true
      args.RawPhysical = args.RawPhysical
    end
  end,

  ["Graves"] = function(args) --Graves
    local t = { 70, 71, 72, 74, 75, 76, 78, 80, 81, 83, 85, 87, 89, 91, 95, 96, 97, 100 }
    args.RawTotal = args.RawTotal * t[math_max(math_min(args.source.levelData.lvl, 18), 1)] * 0.01
  end,

  ["Jhin"] = function(args) --Jhin 4thshot/AA
    if Buff:HasBuff(args.source, "jhinpassiveattackbuff") then
      args.CriticalStrike = true
      args.RawPhysical = args.RawPhysical
          + math_min(0.25, 0.1 + 0.05 * math_ceil(args.source.levelData.lvl / 5))
          * (args.Target.maxHealth - args.Target.health)
    end
  end,

  ["Jinx"] = function(args) --JinxQ
    if Buff:HasBuff(args.source, "JinxQ") then
      args.RawPhysical = args.RawPhysical + args.source.totalDamage * 0.1
    end
  end,

  ["Kalista"] = function(args) --Kalista
    args.RawPhysical = args.RawPhysical - args.source.totalDamage * 0.1
  end,

  ["KSante"] = function(args) --KSanteMark?
    local level = args.source.levelData.lvl
    local hplvl = 1
    if Buff:HasBuff(args.Target, "KSantePMark") then
      --if level < 6 then hplvl = 1
      if level >= 6 and level < 11 then hplvl = 2
      elseif level >= 11 and level < 16 then hplvl = 3
      elseif level >= 16 then hplvl = 4
      end
      if Buff:HasBuff(args.source, "KSanteRTransform") then
        local allOutDamageMod =  0.35 + (0.20 * math_floor(args.source.bonusArmor/100)) + (0.20 * math_floor(args.source.bonusMagicResist/100))
        args.RawPhysical = args.RawPhysical * allOutDamageMod
        args.CalculatedTrue = args.CalculatedTrue + ((10 + 15 / 17 * (level - 1)) + ({1.00, 1.33, 1.66, 2.00})[hplvl]/100 * args.Target.maxHealth) * allOutDamageMod
      else
        args.RawPhysical = args.RawPhysical + 10 + 15 / 17 * (level - 1) + ({1.00, 1.33, 1.66, 2.00})[hplvl]/100 * args.Target.maxHealth
      end
    end
  end,

  ["Lux"] = function(args) --Lux Marks
    if Buff:HasBuff(args.Target, "LuxIlluminatingFraulein") then
      args.RawMagical = 20 + args.source.levelData.lvl * 10 + args.source.ap * 0.2
    end
  end,

  ["Orianna"] = function(args)
    local level = math_ceil(args.source.levelData.lvl / 3)
    args.RawMagical = args.RawMagical + 2 + 8 * level + 0.15 * args.source.ap
    if args.Target.Ghandle == args.source.attackData.target then
      args.RawMagical = args.RawMagical
          + math_max(Buff:GetBuffCount(args.source, "orianapowerdaggerdisplay"), 0)
          * (0.4 + 1.6 * level + 0.03 * args.source.ap)
    end
  end,

  ["Quinn"] = function(args)
    if Buff:HasBuff(args.Target, "QuinnW") then
      local level = args.source.levelData.lvl
      args.RawPhysical = args.RawPhysical + 10 + level * 5 + (0.14 + 0.02 * level) * args.source.totalDamage
    end
  end,

  ["Teemo"] = function(args)
    local Edata = args.source:GetSpellData(_E)
    if Edata.level > 0 then
      args.RawMagical = ({ 14, 25, 36, 47, 58 })[Edata.level] + 0.30 * args.source.ap
    end
  end,

  ["Vayne"] = function(args)
    if Buff:GetBuffCount(args.Target, "VayneSilveredDebuff") == 2 then
      local level = args.source:GetSpellData(_W).level
      args.CalculatedTrue = args.CalculatedTrue
          + math_max((0.045 + 0.015 * level) * args.Target.maxHealth, 20 + 20 * level)
    end
  end,

  ["Zed"] = function(args)
    if 100 * args.Target.health / args.Target.maxHealth <= 50 and not Buff:HasBuff(args.source, "zedpassivecd") then
      args.RawMagical = args.RawMagical +
          args.Target.maxHealth * (4 + 2 * math_ceil(args.source.levelData.lvl / 6)) * 0.01
    end
  end,

  ["Zeri"] = function(args)
    if args.Target.health < (args.Target.maxHealth * 0.35) then
      args.RawMagical = args.RawMagical * 4
    end
  end,

}

local ItemDamageTable = {
  [ItemID.RecurveBow] = function(args) --"Recurve Bow"
    args.RawPhysical = args.RawPhysical + 15
  end,
  [ItemID.KircheisShard] = function(args)  --"Kircheis Shard"
    if Buff:GetBuffCount(args.source, "itemstatikshankcharge") == 100 then
      args.RawMagical = args.RawMagical + 40
    end
  end,
  [ItemID.Sheen] = function(args) --"Sheen"
    if Buff:HasBuff(args.source, "sheen") then
      args.RawPhysical = args.RawPhysical + 1 * args.source.baseDamage
    end
  end,
  [ItemID.SunfireAegis] = function(args) --"Sunfire Aegis"
    if Buff:GetBuffCount(args.source, "item3068stack") == 8 then
      --buff.ammo on hit burn * 3 - (args.Target.hpRegen*3)
    end
  end,
  [ItemID.TrinityForce] = function(args) --"Trinity Force"
    if Buff:HasBuff(args.source, "sheen") then
      args.RawPhysical = args.RawPhysical + 2 * args.source.baseDamage
    end
  end,
  [ItemID.RunaansHurricane] = function(args) --"Runaan's Hurricane"
    args.RawPhysical = args.RawPhysical + 15
  end,
  --[[ [3087] = function(args) --"REDACTED"
    if Buff:GetBuffCount(args.source, "itemstatikshankcharge") == 100 then
      local t = { 50, 50, 50, 50, 50, 56, 61, 67, 72, 77, 83, 88, 94, 99, 104, 110, 115, 120 }
      args.RawMagical = args.RawMagical
        + (1 + (args.TargetIsMinion and 1.2 or 0))
          * t[math_max(math_min(args.source.levelData.lvl, 18), 1)]
    end
  end, ]]
  [ItemID.WitsEnd] = function(args) --"Wit's End"
    args.RawMagical = args.RawMagical + 40
  end,
  [ItemID.RapidFirecannon] = function(args) --"Rapid Firecannon"
    if Buff:GetBuffCount(args.source, "itemstatikshankcharge") == 100 then
      local t = { 50, 50, 50, 50, 50, 58, 66, 75, 83, 92, 100, 109, 117, 126, 134, 143, 151, 160 }
      args.RawMagical = args.RawMagical + t[math_max(math_min(args.source.levelData.lvl, 18), 1)]
    end
  end,
  [ItemID.LichBane] = function(args) --"Lich Bane"
    if Buff:HasBuff(args.source, "lichbane") then
      args.RawMagical = args.RawMagical + 0.75 * args.source.baseDamage + 0.5 * args.source.ap
    end
  end,
  [ItemID.NashorsTooth] = function(args) --"Nashor's Tooth"
    args.RawMagical = args.RawMagical + 15 + 0.15 * args.source.ap
  end,
  [ItemID.GuinsoosRageblade] = function(args) --"Guinsoo's Rageblade"
    args.CalculatedMagical = args.CalculatedMagical + 15
  end,
}

local SpellDamageTable = {
  ["Aatrox"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 30, 50, 70, 90})[level] + ({0.6, 0.65, 0.7, 0.75, 0.8})[level] * source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({12.5, 37.5, 62.5, 87.5, 112.5})[level] + ({0.75, 0.81, 0.87, 0.93, 1.0})[level] * source.totalDamage end},
    {Slot = "Q", Stage = 3, DamageType = 1, Damage = function(source, target, level) return ({15, 45, 75, 105, 135})[level] + ({0.9, 0.95, 1.05, 1.12, 1.2})[level] * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 40, 50, 60, 70})[level] + 0.4 * source.totalDamage end},
  },

  ["Ahri"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.45 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.45 * source.ap end}, --return
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + 0.30 * source.ap end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({12, 19.5, 27, 34.5, 42})[level] + 0.09 * source.ap end}, --additional damage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.60 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120})[level] + 0.35 * source.ap end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120})[level] + 0.35 * source.ap end},
    {Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120})[level] + 0.35 * source.ap end},
  },

  ["Akali"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 55, 80, 105, 130})[level] + (0.6 * source.ap) + (0.65 * source.totalDamage) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 56.25, 82.5, 108.75, 135})[level] + (0.36 * source.ap) + (0.25 * source.totalDamage) end},
	  {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({70, 131.25, 192.5, 253.75, 315})[level] + (0.84 * source.ap) + (0.59 * source.totalDamage) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 130, 200})[level] + (0.5 * source.bonusDamage) + (0.30 * source.ap) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 130, 200})[level] + (0.5 * source.bonusDamage) + (0.30 * source.ap) + (0.0286 * (math_min(GetPercentMissingHP(target), 70))) end},
  },

  ["Akshan"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({5, 25, 45, 65, 85})[level] + 0.8 * source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({10, 50, 90, 130, 170})[level] + 1.6 * source.totalDamage end}, --total return damage
	  {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({30, 55, 80, 105, 130})[level] + 0.175 * source.bonusDamage + (1 + 0.3 * source.attackSpeed) end}, --per shot
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 25, 30})[level] + (0.1 * source.totalDamage) + (1 + (0.50 * source.critChance)) * (0.03 * (GetPercentMissingHP(target))) end}, -- min per bullet stored
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({80, 100, 120})[level] + (0.4 * source.totalDamage) + (1 + (0.50 * source.critChance)) * (0.03 * (GetPercentMissingHP(target))) end}, -- max per bullet stored
  },

  ["Alistar"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.5 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 110, 165, 220, 275})[level] + 0.7 * source.ap end},
	  {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.4 * source.ap end},
  },

  ["Amumu"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.7 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({4, 6, 8, 10, 12})[level] + (({0.5, 0.575, 0.65, 0.725, 0.8})[level]/100 + ((0.25/100) * math_floor(source.ap / 100)) * target.maxHealth) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({85, 110, 135, 160, 185})[level] + 0.5 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.8 * source.ap end},
  },

  ["Anivia"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 70, 90, 110, 130})[level] + 0.25 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.45 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({50, 80, 110, 140, 170})[level] + 0.6 * source.ap) * (GotBuff(target, "aniviachilled") and 2 or 1) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 45, 60})[level] + 0.125 * source.ap end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({90, 135, 180})[level] + 0.375 * source.ap end},
  },

  ["Annie"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + 0.80 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.85 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 275, 400})[level] + 0.75 * source.ap end},
  },

  ["Aphelios"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 60, 76.67, 76.67, 93.33, 93.33, 110, 110, 126.67, 126.67, 143.33, 143.33, 160, 160, 160, 160, 160, 160})[source.levelData.lvl] + source.ap + ({0.42, 0.42, 0.45, 0.45, 0.48, 0.48, 0.51, 0.51, 0.54, 0.54, 0.57, 0.57, 0.60, 0.60, 0.60, 0.60, 0.60, 0.60})[myHero.levelData.lvl] * source.bonusDamage end}, --Calibrum
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({10, 10, 15, 15, 20, 20, 25, 25, 30, 30, 35, 35, 40, 40, 40, 40, 40, 40})[source.levelData.lvl] + ({0.20, 0.20, 0.225, 0.225, 0.255, 0.255, 0.275, 0.275, 0.30, 0.30, 0.325, 0.325, 0.35, 0.35, 0.35, 0.35, 0.35, 0.35})[myHero.levelData.lvl] * source.bonusDamage end}, --Severum
    {Slot = "Q", Stage = 3, DamageType = 2, Damage = function(source, target, level) return ({50, 50, 60, 60, 70, 70, 80, 80, 90, 90, 100, 100, 110, 110, 110, 110, 110, 110})[source.levelData.lvl] + 0.7 * source.ap + ({0.26, 0.26, 0.275, 0.275, 0.29, 0.29, 0.305, 0.305, 0.32, 0.32, 0.335, 0.335, 0.35, 0.35, 0.35, 0.35, 0.35, 0.35})[myHero.levelData.lvl] * source.bonusDamage end}, --Gravitum
    {Slot = "Q", Stage = 4, DamageType = 1, Damage = function(source, target, level) return ({25, 25, 31.67, 31.67, 38.33, 38.33, 45, 45, 51.67, 51.67, 58.33, 58.33, 65, 65, 65, 65, 65, 65})[source.levelData.lvl] + 0.7 * source.ap + ({0.56, 0.56, 0.6, 0.6, 0.64, 0.64, 0.68, 0.68, 0.72, 0.72, 0.76, 0.76, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8})[myHero.levelData.lvl] * source.bonusDamage end}, --Infernum
    {Slot = "Q", Stage = 5, DamageType = 1, Damage = function(source, target, level) return ({31, 31, 42.5, 42.5, 54, 54, 65.5, 65.5, 77, 77, 88.5, 88.5, 100, 100, 100, 100, 100, 100})[source.levelData.lvl] + 0.5 * source.ap + ({0.40, 0.40, 0.4333, 0.4333, 0.4667, 0.4667, 0.5, 0.5, 0.5333, 0.5333, 0.5667, 0.5667, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6})[myHero.levelData.lvl] * source.bonusDamage end}, --Crescendum
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({125, 175, 225})[level] + source.ap + 0.2 * source.bonusDamage + (GotSpell(_Q, "ApheliosCalibrumQ") * (({40, 70, 100})[level] * source.bonusDamage)) end}, --Calibrum
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({125, 175, 225})[level] + source.ap + 0.2 * source.bonusDamage end}, --Severum
    {Slot = "R", Stage = 3, DamageType = 1, Damage = function(source, target, level) return ({125, 175, 225})[level] + source.ap + 0.2 * source.bonusDamage end}, --Gravitum
    {Slot = "R", Stage = 4, DamageType = 1, Damage = function(source, target, level) return ({125, 175, 225})[level] + source.ap + 0.2 * source.bonusDamage + (GotSpell(_Q, "ApheliosInfernumQ") * (({50, 100, 150})[level] + 0.25 * source.bonusDamage)) end}, --Infernum
    {Slot = "R", Stage = 5, DamageType = 1, Damage = function(source, target, level) return ({125, 175, 225})[level] + source.ap + 0.2 * source.bonusDamage end}, --Crescendum
  },

  ["Ashe"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({1.05, 1.10, 1.15, 1.20, 1.25})[level] * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 35, 50, 65, 80})[level] + source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 400, 600})[level] + source.ap end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({100, 200, 300})[level] + 0.5 * source.ap) end}, --Splash
  },

  ["AurelionSol"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.65 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * source.ap end},
  },

  ["Azir"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 90, 110, 130, 150})[level] + 0.3 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 52, 54, 56, 58, 60, 62, 65, 70, 75, 80, 90, 100, 110, 120, 130, 140, 150})[myHero.levelData.lvl] + 0.55 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.4 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({175, 325, 475})[level] + 0.6 * source.ap end},
  },

  ["Bard"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.65 * source.ap end},
  },

  ["BelVeth"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) local dmg = (({10, 15, 20, 25, 30})[level] + (1.10 * source.totalDamage)); if target.type == Obj_AI_Camp then dmg = (dmg * 1.20) elseif target.type == Obj_AI_Minion then dmg = (dmg * (({60, 70, 80, 90, 100})[level] / 100)) end ; return dmg end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + (1.00 * source.bonusDamage) + (1.25 * source.ap) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) local dmg = ({8, 10, 12, 14, 16})[level] + (0.06 * source.totalDamage) * (0.03 * (GetPercentMissingHP(target))) ; if target.type == Obj_AI_Camp then dmg = (dmg * 1.50) end ; return dmg end}, --minimum
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) local dmg = ({32, 40, 48, 56, 64})[level] + (0.24 * source.totalDamage) * (0.03 * (GetPercentMissingHP(target))) ; if target.type == Obj_AI_Camp then dmg = (dmg * 1.50) end ; return dmg end}, --maximum over 1.5 seconds
    {Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({150, 200, 500})[level] + (1.00 * source.ap) + (0.25 * GetMissingHP(target)) end},
  },

  ["Blitzcrank"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({105, 155, 205, 255, 305290})[level] + 1.2 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) local dmg = source.totalDamage + (0.25 * source.ap) if target.type == Obj_AI_Minion then dmg = (2.5 * source.totalDamage) + (1.25 * source.ap) end; return dmg end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({275, 400, 525})[level] + (1.25 * source.ap) end},
  },

  ["Brand"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.55 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({75, 120, 165, 210, 255})[level] + 0.6 * source.ap) * (GotBuff(target, "BrandAblaze") and 1.25 or 1) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 95, 120, 145, 170})[level] + 0.45 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.25 * source.ap end},
  },

  ["Braum"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 125, 175, 225, 275})[level] + (0.025 * source.maxHealth) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 300, 450})[level] + 0.6 * source.ap end},
  },

  ["Caitlyn"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 90, 130, 170, 210})[level] + (({1.25, 1.45, 1.65, 1.85, 2.05})[level] * source.totalDamage) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + (0.8 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({300, 525, 750})[level] + (2 * source.bonusDamage) * (1 + math_min(1, 0.25 * source.critChance))end}, -- 0-25% based on every 10% crit
  },

  ["Camille"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({0.2, 0.25, 0.3, 0.35, 0.4})[level] * source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({0.2, 0.25, 0.3, 0.35, 0.4})[level] * source.totalDamage * 2 end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 0.6 * source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.90 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({5, 10, 15})[level] + ({0.04, 0.06, 0.08})[level] * target.health end},
  },

  ["Cassiopeia"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 110, 145, 180, 215})[level] + 0.9 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 25, 30, 35, 40})[level] + 0.15 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return 48 + 4 * source.levelData.lvl + 0.1 * source.ap + (HasPoison(target) and ({20, 40, 60, 80, 100})[level] + 0.6 * source.ap or 0) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.5 * source.ap end},
  },

  ["Chogath"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 125, 175, 225, 275})[level] + 0.7 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({22, 34, 46, 58, 70})[level] + 0.3 * source.ap + 0.03 * target.maxHealth end},
    {Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) local dmg = ({300, 475, 650})[level] + (0.50 * source.ap) + (0.10 * (source.maxHealth - GetBaseHealth(source))); if target.type ~= Obj_AI_Hero then dmg = 1200 + (0.50 * source.ap) + (0.10 * (source.maxHealth - GetBaseHealth(source))) end; return dmg end},
  },

  ["Corki"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 120, 165, 210, 255})[level] + 0.5 * source.ap + 0.7 * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({15, 22.5, 30, 37.5, 45})[level] + 0.10 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 8.75, 10, 11.25, 12.5, 13.75, 15, 16.25, 17.5, 20, 22.5, 25})[source.levelData.lvl] + (0.5 * source.bonusDamage) + (0.06 * source.ap) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({7.5, 10.625, 13.75, 16.875, 20})[level] + 0.15 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 150})[level] + 0.12 * source.ap + ({0.15, 0.45, 0.75})[level] * source.totalDamage end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({160, 230, 300})[level] + 0.24 * source.ap + ({0.3, 0.90, 1.5})[level] * source.totalDamage end},
  },

  ["Darius"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + (({1.0, 1.1, 1.2, 1.3, 1.4})[level] * source.totalDamage) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({1.4, 1.45, 1.5, 1.55, 1.6})[level] * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.75 * source.bonusDamage end},
  },

  ["Diana"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.7 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({18, 30, 42, 54, 66})[level] + 0.15 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 70, 90, 110, 130})[level] + 0.50 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.6 * source.ap end},
  },

  ["DrMundo"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = (({20, 22.5, 25, 27.5, 30})[level] / 100 * target.health) if target.type == Obj_AI_Camp then return math_max(({80, 130, 180, 230, 280})[level], math_min(({350, 425, 500, 575, 650})[level], dmg)) end; return dmg end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({5, 8.75, 12.5, 16.25, 20})[level] end}, --per tick/activation
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({20, 35, 50, 65, 80})[level] + (0.07 * (source.maxHealth - GetBaseHealth(source))) end}, --recast/detonation
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({15, 20, 25, 30, 35})[level] * (1 + (0.01 * math_min(GetPercentMissingHP(source), 70))) end}, --Passive
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) local dmg = (({5, 15, 25, 35, 45})[level] + (0.07 * (source.maxHealth - GetBaseHealth(source)))) * (1 + (0.015 * math_min(GetPercentMissingHP(source), 40))) if target.type == Obj_AI_Minion then return dmg * 2 end; return dmg end}, --Active
  },

  ["Draven"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 45, 50, 55, 60})[level] + (({0.75, 0.85, 0.95, 1.05, 1.15})[level] * source.bonusDamage) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({75, 110, 145, 180, 215})[level] + 0.5 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({175, 275, 375})[level] + ({1.10, 1.30, 1.50})[level] * source.bonusDamage end},
  },

  ["Ekko"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 75, 90, 105, 120})[level] + 0.3 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.6 * source.ap end}, --return Q
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + 0.4 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 350, 500})[level] + 1.75 * source.ap end}
  },

  ["Elise"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = (({40, 75, 110, 145, 180})[level] + (0.04 + (0.03 * math_floor(source.ap / 100))) * target.health) if target.type == Obj_AI_Camp then return math_min(({115, 175, 235, 295, 355})[level], dmg) end; return dmg end},
    {Slot = "QM", Stage = 2, DamageType = 2, Damage = function(source, target, level) local dmg = (({70, 105, 140, 175, 210})[level] + (0.08 + (0.03 * math_floor(source.ap / 100))) * GetMissingHP(target)) if target.type == Obj_AI_Camp then return math_min(({145, 210, 275, 340, 405})[level], dmg) end; return dmg end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.95 * source.ap end},
  },

  ["Evelynn"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 30, 35, 40, 45})[level] + 0.3 * source.ap end}, --TODO: bonus damage next 3 AA or spells
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 70, 85, 100, 115})[level] + (0.03 + (0.015 * math_floor(source.ap / 100))) * target.maxHealth end}, --non-empowered
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) local dmg = ({75, 100, 125, 150, 175})[level] + (0.04 + (0.025 * math_floor(source.ap / 100))) * target.maxHealth if target.type == Obj_AI_Camp then return math_max(25, math_min(450, dmg)) end; return dmg end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = ({125, 250, 375})[level] + 0.75 * source.ap if GetPercentMissingHP(target) > 30 then return dmg * 1.4 end; return dmg end},
  },

  ["Ezreal"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 45, 70, 95, 120})[level] + 0.15 * source.ap + 1.3 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + (({0.7, 0.75, 0.8, 0.85, 0.9})[level] * source.ap) + 0.6 * source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.75 * source.ap + 0.5 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({350, 500, 650})[level] + 0.9 * source.ap + source.bonusDamage end},
  },

  ["Fiddlesticks"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({6, 7, 8, 9, 10})[level]/100 + (0.02 * math_floor(source.ap / 100)) * target.health end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({120, 180, 240, 300, 360})[level] + 0.70 * source.ap + ({0.12, 0.145, 0.17, 0.195, 0.22})[level] * GetMissingHP(target)  end}, -- full damage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.5 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({750, 1250, 1750})[level] + 2.5 * source.ap end}, -- full damage
  },

  ["Fiora"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 80, 90, 100, 110})[level] + ({0.95, 1, 1.05, 1.1, 1.15})[level] * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({110, 150, 190, 230, 270})[level] + source.ap end},
  },

  ["Fizz"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 25, 40, 55, 70})[level] + 0.55 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 70, 90, 110, 130})[level] + 0.50 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 120, 170, 220, 270})[level] + 0.90 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.80 * source.ap end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({225, 325, 425})[level] + source.ap end},
    {Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return ({300, 400, 500})[level] + 1.20 * source.ap end},
  },

  ["Galio"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.75 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (0.025 + math_floor(0.01 * target.maxHealth/100)) end}, --tornado per tick
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({90, 130, 170, 210, 250})[level] + 0.9 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * source.ap end},
  },

  ["Gangplank"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 40, 70, 100, 130})[level] + source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({75, 105, 135, 165, 195})[level] + source.totalDamage end}, -- +ignores 40% target armour +10% if crit
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 70, 100})[level] + 0.1 * source.ap end}, --per wave
    {Slot = "R", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({120, 210, 300})[level] + 0.3 * source.ap end}, --CENTER TRUE DAMAGE WITH Death's Daughter

  },

  ["Garen"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] + 0.5 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({4, 8, 12, 16, 20})[level] + ({0, 0.8, 1.6, 2.4, 3.2, 4, 4.8, 5.6, 6.4, 6.6, 6.6, 7, 7.2, 7.4, 7.6, 7.8, 8, 8.2})[myHero.levelData.lvl] + ({32, 34, 36, 38, 40})[level] / 100 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({150, 300, 450})[level] + (({25, 30, 35})[level] / 100) * GetMissingHP(target) end},
  },

  ["Gnar"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({5, 45, 85, 125, 165})[level] + 1.15 * source.totalDamage end},
    {Slot = "QM", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({25, 70, 115, 160, 205})[level] + 1.4 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = (({0, 10, 20, 30, 40})[level] + (({6, 8, 10, 12, 14})[level] / 100 * target.maxHealth) * source.ap) if target.type == Obj_AI_Camp then return math_min(300, dmg) end; return dmg end},
    {Slot = "WM", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({25, 55, 85, 115, 145})[level] + source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 85, 120, 155, 190})[level] + (0.06 * source.maxHealth) end},
    {Slot = "EM", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + (0.06 * source.maxHealth) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 300, 400})[level] + source.ap + (0.5 * source.bonusDamage) end},
  },

  ["Gragas"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + (0.8 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 50, 80, 110, 140})[level] + (0.6 * source.ap) + (0.07 * target.maxHealth) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.6 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.8 * source.ap end},
  },

  ["Graves"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({45, 60, 75, 90, 105})[level] +  0.8 * source.bonusDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({85, 120, 155, 190, 225})[level] + ({0.4, 0.7, 1.0, 1.3, 1.6})[level] * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + 0.6 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({275, 425, 575})[level] + 1.5 * source.bonusDamage end},
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({200, 320, 440})[level] + 1.2 * source.bonusDamage end},
  },

  ["Gwen"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 0.4 * source.ap + (0.02 + math_floor(0.016 * source.ap / 100) * target.maxHealth) end}, --min center damage
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 85, 110, 135, 16040})[level] + 0.35 * source.ap + (0.01 + math_floor(0.008 * source.ap / 100) * target.maxHealth) end}, --Final center damage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (15 + 0.20 * source.ap) end}, --onhit
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({35, 65, 95})[level] + 0.08 * source.ap + ((1 / 100) + (0.008 * math_floor(source.ap / 100) * target.maxHealth)) end}, -- per needle 1st Cast
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({105, 195, 285})[level] + 0.30 * source.ap + ((3 / 100) + (0.024 * math_floor(source.ap / 100) * target.maxHealth)) end}, -- 2nd Cast
    {Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return ({175, 325, 475})[level] + 0.50 * source.ap + ((5 / 100) + (0.04 * math_floor(source.ap / 100) * target.maxHealth)) end}, -- 3rd Cast
    {Slot = "R", Stage = 4, DamageType = 2, Damage = function(source, target, level) return ({315, 585, 855})[level] + 0.90 * source.ap + ((9 / 100) + (0.072 * math_floor(source.ap / 100) * target.maxHealth)) end}, -- Total
  },

  ["Hecarim"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 0.90 * source.bonusDamage end}, --TODO: per stack +4%(+6^per100bonusAD) to 12%(+18per)
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 30, 40, 50, 60})[level] + 0.2 * source.ap end}, -- per tick
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.8 * source.ap end}, -- totalDamage
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 45, 60, 75, 90})[level] + 0.50 * source.bonusDamage end}, --happens twice
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + source.ap end},
  },

  ["Heimerdinger"] = {
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + 0.45 * source.ap end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({135, 180, 225})[source:GetSpellData(_R).level] + 0.45 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.6 * source.ap end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({100, 200, 300})[source:GetSpellData(_R).level] + 0.6 * source.ap end},
  },

  ["Illaoi"] = {
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({0.03, 0.035, 0.04, 0.045, 0.05})[level] + (0.04 * math_floor(source.totalDamage / 100)) * target.maxHealth end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.5 * source.bonusDamage end},
  },

  ["Irelia"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({5, 25, 45, 65, 85})[level] + 0.6 * source.totalDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({5, 25, 45, 65, 85})[level] + (43 + (12 * myHero.levelData.lvl)) + 0.6 * source.totalDamage end}, --Minion Damage
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 25, 40, 55, 70})[level] + (0.4 * source.totalDamage) + (0.4 * source.ap) end}, --Min damage
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({30, 75, 120, 165, 210})[level] + (1.2 * source.totalDamage) + (1.2 * source.ap) end}, --Max damage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.8 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({125, 250, 375})[level] + 0.7 * source.ap end},
  },

  ["Ivern"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.7 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 90, 110, 130, 150})[level] + 0.8 * source.ap end},
  },

  ["Janna"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 0.35 * source.ap end}, --min q damage
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 85, 115, 145, 175})[level] + 0.5 * source.ap end},  --rip movespeed janna
  },

  ["JarvanIV"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({90, 130, 170, 210, 250})[level] + 1.40 * source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.8 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 325, 450})[level] + 1.5 * source.bonusDamage end},
  },

  ["Jax"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 105, 145, 185, 225})[level] + source.bonusDamage + (0.6 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 75, 110, 145, 180})[level] + 0.6 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 80, 105, 130, 155})[level] + 0.5 * source.bonusDamage end}, --min damage increases 20% per attack dodged for a max of 100% increase
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 140, 180})[level] + 0.7 * source.ap end},
  },

  ["Jayce"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 100, 145, 190, 235, 280})[level] + 1.20 * source.bonusDamage end},
    {Slot = "QM", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({55, 110, 165, 220, 275, 330})[level] + 1.20 * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 40, 55, 70, 85, 100})[level] + 0.25 * source.ap end}, --per tick for 4x ticks
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({8.00, 10.80, 13.60, 16.40, 19.20, 22.00})[level] / 100) * target.maxHealth + source.bonusDamage end},
    {Slot = "RM", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 25, 25, 25, 25, 65, 65, 65, 65, 65, 105, 105, 105, 105, 105, 105, 145, 145})[myHero.levelData.lvl] + (0.25 * source.bonusDamage) end},
  },

  ["Jhin"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({45, 70, 95, 120, 145})[level] + (({0.35, 0.425, 0.5, 0.575, 0.65})[level] * source.totalDamage) + 0.6 * source.ap end},
	  {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.5 * source.totalDamage end},
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({37.5, 63.75, 90, 116.25, 142.5})[level] + 0.375 * source.totalDamage end},
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({20, 80, 140, 200, 260})[level] + (1.2 * source.totalDamage) + source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 125, 200})[level] + (0.25 * source.totalDamage) + (0.03 * GetPercentMissingHP(target)) end}, -- Min
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({200, 500, 800})[level] + (1.00 * source.totalDamage) + (0.03 * GetPercentMissingHP(target)) end} -- max
  },

  ["Jinx"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.1 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 60, 110, 160, 210})[level] + 1.6 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 120, 170, 220, 270})[level] + source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) local dmg = (({30, 45, 60})[level] + (0.15 * source.bonusDamage) * (1.10 + (0.06 * math_min(math_floor(target.distance / 100),15)))) + (({25, 30, 35})[level] / 100 * GetMissingHP(target)); return dmg end}, --Inital hit damage
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) local dmg = (({20, 36, 48})[level] + (0.12 * source.bonusDamage) * (1.10 + (0.06 * math_min(math_floor(target.distance / 100),15)))) + (({20, 24, 28})[level] / 100 * GetMissingHP(target)); if target.type == Obj_AI_Camp then return math_min(800, dmg) end; return dmg end}, --AOE splash damage
  },

  ["Kaisa"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 55, 70, 85, 100})[level] + (0.50 * source.bonusDamage) + (0.30 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 55, 80, 105, 130})[level] + (1.30 * source.totalDamage) + (0.70 * source.ap) end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) local buff = GetBuffData(target, "kaisapassivemarker"); local PlasmaStacks = buff.count; local bonusdmg = 0; local dmg = (({5,5,8,8,8,11,11,11,14,14,17,17,17,20,20,20,23,23})[source.levelData.lvl]) + (0.15 * source.ap); if PlasmaStacks >=1 then dmg = dmg + ((({1,1,1,3.75,3.75,3.75,3.75,6.5,6.5,6.5,6.5,9.25,9.25,9.25,9.25,12,12,12})[source.levelData.lvl] + ((2.5/100) * source.ap)) * PlasmaStacks) end; if PlasmaStacks == 4 then bonusdmg = (0.15 + 0.06 * math_floor(source.ap / 100)) * GetMissingHP(target); if target.type == Obj_AI_Camp then bonusdmg = math_min(400, bonusdmg) end; dmg = dmg + bonusdmg end; return dmg end},	-- passive pop damage
  },

  ["Karma"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({90, 135, 180, 225, 270})[level] + 0.4 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({90, 135, 180, 225, 270})[level] + ({25, 75, 125, 175})[source:GetSpellData(_R).level] + 0.7 * source.ap end}, --Ult Q
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.9 * source.ap end}, -- full tether damage
  },

  ["Karthus"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({45, 62.5, 80, 97.5, 115})[level] + 0.35 * source.ap) * 2 end},--single Target
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({45, 62.5, 80, 97.5, 115})[level] + 0.35 * source.ap end},--AOE
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 50, 70, 90, 110})[level] + 0.2 * source.ap end}, --DPS not per tick deals damage every 0.25sec - toggle off deals 1 tick of damage
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 350, 500})[level] + 0.75 * source.ap end},
  },

  ["Kassadin"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 95, 125, 155, 185})[level] + 0.7 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 95, 120, 145, 170})[level] + 0.8 * source.ap end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return 20 + 0.1 * source.ap end}, --Added AAatack damage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 105, 130, 155, 180})[level] + 0.8 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120})[level] + 0.4 * source.ap + 0.02 * source.mana end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({40, 50, 60})[level] + 0.1 * source.ap + 0.01 * source.mana end},-- bonus dmg per stack
  },

  ["Katarina"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 105, 135, 165, 195})[level] + 0.3 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 35, 50, 65, 80})[level] + (0.25 * source.ap) + (0.4 * source.totalDamage) end},
	  {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 37.5, 50})[level] + 0.19 * source.ap end}, -- magical calc for 1 Dagger
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({375, 562.5, 750})[level] + 2.85 * source.ap end}, --maximum single target dmg
	  {Slot = "R", Stage = 3, DamageType = 1, Damage = function(source, target, level) return (0.16 + source.bonusDamage) + 0.22856 * source.attackSpeed end}, -- physical calc for 1 Dagger
  },

  ["Kayle"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + (0.6 * source.bonusDamage) + (0.5 * source.ap) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({8, 8.5, 9, 9.5, 10})[level]/100 + (1.5/100 * math_floor(source.ap/100)) * GetMissingHP(target) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 350, 500})[level] + (0.8 * source.ap) + source.bonusDamage end},
  },

  ["Kennen"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 120, 165, 210, 255})[level] + 0.75 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 95, 120, 145, 170})[level] + 0.80 * source.ap end}, --active
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({35, 45, 55, 65, 75})[level] + ((({80, 90, 100, 110, 120})[level]/100) * source.bonusDamage)  + (0.35 * source.ap) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.80 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 75, 110})[level] + 0.225 * source.ap end},--per Bolt
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({300, 562.5, 825})[level] + 1.6875 * source.ap end},--total single target damage
  },

  ["Khazix"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 1.3 * source.bonusDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({126, 178.5, 231, 283.5, 336})[level] + 2.73 * source.bonusDamage end},--isolated Target
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({85, 115, 145, 175, 205})[level] + source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 100, 135, 170, 205})[level] + 0.2 * source.bonusDamage end},
  },

  ["KogMaw"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({90, 140, 190, 240, 290})[level] + 0.7 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = ((({3, 3.75, 4.50, 5.25, 6.00})[level] / 100) * target.maxHealth) + (0.01 * math_floor(source.ap/100)) ; if target.type == Obj_AI_Minion or target.type == Obj_AI_Camp and dmg > 100 then dmg = 100 end ; return dmg end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 120, 165, 210, 255})[level] + 0.5 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({100, 140, 180})[level] + 0.65 * source.bonusDamage + 0.35 * source.ap) * (GetPercentHP(target) < 25 and 3 or (GetPercentHP(target) < 50 and 2 or 1)) end},
  },

  ["Kalista"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 85, 150, 215, 280})[level] + source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) local baseDmg = (({14, 15, 16, 17, 18})[level] / 100) * target.maxHealth; if GotBuff(target, "kalistacoopstrikeally") then if target.type == Obj_AI_Minion then if target.health <= 125 then return target.health end; return math_max(math_min(baseDmg, 75), ({100,125,150,175,200})[level]) end; end; return baseDmg end}, -- Soul-marked target calc
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level)
       local count = GotBuff(target, "kalistaexpungemarker");
       if count == 0 then return 0 end;
       local dmg = (({20, 30, 40, 50, 60})[level] + (0.7 * source.totalDamage)) + ((count - 1)*(({10, 16, 22, 28, 34})[level]+(({23.20, 27.55, 31.90, 36.25, 40.60})[level]/100) * (source.totalDamage)));
       if target.type == Obj_AI_Minion then
        local monsterName = target.charName;
        if table_contains(epicMonster, monsterName) then
          dmg = dmg * 0.50; end;
--[[         if table_contains(Monstertable, monsterName) and epicMonster[monsterName].epicMonster then --epicMonster[monsterName] then -- table_contains(epicMonster, monsterName)
          dmg = dmg * 0.50; end;  ]]
       end;
      return dmg end; },
  },

  ["Kayn"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({75, 95, 115, 135, 155})[level] + 0.65 * source.bonusDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({75, 95, 115, 135, 155})[level] + 0.65 * source.bonusDamage + (0.05 + (0.035 * math_floor(source.bonusDamage/100)) * target.maxHealth) end}, --darkin
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({90, 135, 180, 225, 270})[level] + 1.3 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 250, 350})[level] + 1.75 * source.bonusDamage end},
  },

  ["Kindred"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + (0.75 * source.bonusDamage) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) local buff = GetBuffData(source, "kindredmarkofthekindredstackcounter"); return ({25, 30, 35, 40, 45})[level] + (0.2 * source.bonusDamage) + (0.015 + (0.01 * buff.stacks) * GetMissingHP(target)) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) local buff = GetBuffData(source, "kindredmarkofthekindredstackcounter"); return ({80, 100, 120, 140, 160})[level] + (0.8 * source.bonusDamage) + (0.08 + (0.005 * buff.stacks) * GetMissingHP(target)) end},
  },

  ["Kled"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 55, 80, 105, 130})[level] + 0.65 * source.bonusDamage end}, --Tether
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + 1.3 *source.bonusDamage end}, --Pull
    {Slot = "Q", Stage = 3, DamageType = 1, Damage = function(source, target, level) return ({90, 165, 240, 315, 390})[level] + 1.95 * source.bonusDamage end}, --totalDamage
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 30, 40, 50, 60})[level] + (({4.5, 5, 5.5, 6, 6.5})[level]/100 + (0.05 * math_floor(source.bonusDamage/100)) * target.maxHealth) end}, --needs to be (+ 5% per 100 bonus AD)
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({35, 60, 85, 110, 135})[level] + source.bonusDamage * 0.65 end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) local dmg = (({4, 5, 6})[level]/100 + 0.04 * math_floor(source.bonusDamage/100) * target.maxHealth); return dmg end}, --0.08 * (0.16sec * spell.isChanneling.time)
  },

  ["KSante"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + (0.40 * source.totalDamage) + (0.30 * source.bonusArmor) + (0.30 * source.bonusMagicResist)end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) local dmg = ((({4.25, 4.50, 4.75, 5.00, 5.25})[level]/100) * target.maxHealth) if Buff:HasBuff(source, "KSanteRTransform") then dmg = dmg + ({25, 35, 45, 55, 65})[level] + (0.50 * source.totalDamage) end return dmg end}, --min
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) local dmg = ((({8.25, 8.50, 8.75, 9.00, 9.25})[level]/100) * target.maxHealth) if Buff:HasBuff(source, "KSanteRTransform") then dmg = dmg + ({110, 170, 230, 290, 350})[level] + (0.50 * source.totalDamage) end return dmg end}, --total max dmg
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({35, 70, 105})[level] + 0.20 * source.totalDamage end}, --No wall
    --{Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.20 * source.totalDamage end}, --additional
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({185, 320, 455})[level] + 0.40 * source.totalDamage end}, --Hit Wall
  },

  ["Leblanc"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 90, 115, 140, 165})[level] + 0.4 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 115, 155, 195, 235})[level] + 0.6 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 70, 90, 110, 130})[level] + 0.3 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 140, 210})[level] + 0.4 * source.ap end}, -- Mimic Q
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({150, 300, 450})[level] + 0.75 * source.ap end}, -- Mimic W
    {Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return ({70, 140, 210})[level] + 0.4 * source.ap end}, -- Mimic E
  },

  ["LeeSin"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 80, 105, 130, 155})[level] + source.bonusDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({55, 80, 105, 130, 155})[level] + source.bonusDamage + (0.01 * (GetPercentMissingHP(target))) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 130, 160, 190, 220})[level] + source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({175, 400, 625})[level] + 2 * source.bonusDamage end},
  },

  ["Leona"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 35, 60, 85, 110})[level] + 0.3 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({45, 80, 115, 150, 185})[level] + 0.4 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 90, 130, 170, 210})[level] + 0.4 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 175, 250})[level] + 0.8 * source.ap end},
  },

  ["Lillia"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({35, 50, 65, 80, 95})[level] + 0.4 * source.ap end}, --Q Area
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 0.8 * source.ap end}, --Q Edge
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 90, 110, 130, 150})[level] + 0.35 * source.ap end}, --W Area
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 270, 330, 390, 450})[level] + 1.5 * source.ap end}, --W Center
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 95, 120, 145, 170})[level] + 0.45 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 150, 200})[level] + 0.4 * source.ap end},
  },

  ["Lissandra"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.8 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.7 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.6 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.75 * source.ap end},
  },

  ["Lucian"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({95, 125, 155, 185, 215})[level] + (({0.6, 0.75, 0.9, 1.05, 1.2})[level] * source.bonusDamage) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 110, 145, 180, 215})[level] + 0.9 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 40, 60})[level] + (0.1 * source.ap) + (0.25 * source.totalDamage) end},--per Shot
  },

  ["Lulu"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.4 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.4 * source.ap end},
  },

  ["Lux"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.6 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + 0.65 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({300, 400, 500})[level] + source.ap end},
  },

  ["Malphite"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 120, 170, 220, 270})[level] + 0.60 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 45, 60, 75, 90})[level] + 0.30 * source.ap + 0.10 * source.armor end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.40 * source.armor + 0.60 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.90 * source.ap end},
  },

  ["Malzahar"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.55 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({12, 14, 16, 18, 20})[level] + (0.2 * source.ap) + (0.4 * source.bonusDamage) + (5 + 3.5 * source.levelData.lvl) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + 0.8 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({125, 200, 275})[level] + 0.8 * source.ap end},	-- total damage
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({10, 15, 20})[level]/100 + (0.025 * math_floor(source.ap/100))) * target.maxHealth end}, -- null zone damage
  },

  ["Maokai"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 110, 155, 200, 245})[level] + (0.40 * source.ap) + (({2.00, 2.25, 2.5, 2.75, 3.00})[target.maxHealth]/100) end}, --
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 0.4 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 80, 105, 130, 155})[level] + (0.40 * source.ap) + (0.006 * (source.maxHealth - GetBaseHealth(source))) end}, --Normal
    --{Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (2 * ({25, 50, 75, 100, 125})[level] + (({0.07, 0.0725, 0.075, 0.0775, 0.08})[level] + (0.008*source.ap)) * target.maxHealth) end}, --Bush saplings
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({55, 80, 105, 130, 155})[level] + (0.40 * source.ap) + (0.006 * (source.maxHealth - GetBaseHealth(source))) * 2 end}, --Bush saplings just x2 now
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.75 * source.ap end},
  },

  ["MasterYi"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] + 0.50 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({30, 35, 40, 45, 50})[level] + 0.30 * source.bonusDamage end},
  },

  ["MissFortune"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 45, 70, 95, 120})[level] + (0.35 * source.ap) + source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({8.75, 12.50, 16.25, 20.00, 23.75})[level] + 0.15 * source.ap end}, --per tick
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 1.20 * source.ap end}, --max damage
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (0.75 * source.totalDamage) + (0.25 * source.ap) end}, -- each wave
  },

  ["MonkeyKing"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 45, 70, 95, 120})[level] + 0.45 * source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({0.01, 0.015, 0.02})[level] * target.maxHealth + ((34.375/100) * source.totalDamage) end}, --Per Tick
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({0.08, 0.12, 0.16})[level] * target.maxHealth + (2.75 * source.totalDamage) end}, --Total
  },

  ["Mordekaiser"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 95, 115, 135, 155})[level] + (0.6 * source.ap) + ({5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 51, 61, 71, 81, 91, 107, 123, 139})[source.levelData.lvl] end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 95, 110, 125, 140})[level] + 0.6 * source.ap end},
  },

  ["Morgana"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + 0.9 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({6, 11, 16, 21, 26})[level] + (0.07 * source.ap) * (0.017 * (GetPercentMissingHP(target))) end}, -- per tick
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + (0.70 * source.ap) * (0.017 * (GetPercentMissingHP(target))) end}, -- minimum fullDmg
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.7 * source.ap end},
  },

  ["Nami"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 130, 185, 240, 295})[level] + 0.5 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.5 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 40, 55, 70, 85})[level] + 0.2 * source.ap end}, --per tick
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.6 * source.ap end},
  },

  ["Nasus"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return GetBuffData(source, "nasusqstacks").stacks + ({30, 50, 70, 90, 110})[level] end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 95, 135, 175, 215})[level] + 0.60 * source.ap end}, --initial hit
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({11, 19, 27, 35, 43})[level] + 0.12 * source.ap end}, --per tick
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({3, 4, 5})[level]/100 + 0.01 * math_floor(source.ap/100)) * target.maxHealth end},
  },

  ["Nautilus"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.9 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 40, 50, 60, 70})[level] + 0.4 * source.ap end}, --on AA
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 85, 115, 145, 175})[level] + 0.3 * source.ap end}, --per wave
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 275, 400})[level] + 0.8 * source.ap end}, --target damage
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({125, 175, 225})[level] + 0.4 * source.ap end}, --trail damage
  },

  ["Neeko"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.5 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + 0.6 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 425, 650})[level] + 1.3 * source.ap end},
  },

  ["Nilah"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (1 + math_min(1, 1 * source.critChance)) * (({5, 10, 15, 20, 25})[level] + (({0.90, 1.00, 1.10, 1.20, 1.30})[level] * source.totalDamage)) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 90, 115, 140, 165})[level] + (0.2 * source.totalDamage) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({15, 30, 45})[level] + (0.35 * source.bonusDamage) end}, -- per 0.25sec tick
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({60, 120, 180})[level] + (1.4 * source.bonusDamage) end}, -- max over 1 sec
    {Slot = "R", Stage = 3, DamageType = 1, Damage = function(source, target, level) return ({125, 225, 325})[level] + (1.2 * source.bonusDamage) end}, -- Burst
    {Slot = "R", Stage = 4, DamageType = 1, Damage = function(source, target, level) return ({185, 345, 505})[level] + (2.6 * source.bonusDamage) end}, -- total
  },

  ["Nidalee"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 90, 110, 130, 150})[level] + 0.5 * source.ap end},
    {Slot = "QM", Stage = 2, DamageType = 2, Damage = function(source, target, level) local dmg = (({5, 30, 55, 80})[source:GetSpellData(_R).level] + 0.4 * source.ap + 0.75 * source.totalDamage) * ((target.maxHealth - target.health) / target.maxHealth * 1.5 + 1) dmg = dmg * (GotBuff(target, "nidaleepassivehunted") > 0 and 1.4 or 1) return dmg end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 80, 120, 160, 200})[level] + 0.2 * source.ap end},
    {Slot = "WM", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210})[source:GetSpellData(_R).level] + 0.3 * source.ap end},
    --{Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({80, 140, 200, 260})[source:GetSpellData(_R).level] + 0.45 * source.ap end},
    {Slot = "EM", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({80, 140, 200, 260})[source:GetSpellData(_R).level] + 0.45 * source.ap end},
  },

  ["Nocturne"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 110, 155, 200, 245})[level] + 0.85 * source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 275, 400})[level] + 1.2 * source.bonusDamage end},
  },

  ["Nunu"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = ({60, 100, 140, 180, 220})[level] + (0.65 * source.ap) + (0.05 * (source.maxHealth - GetBaseHealth(source))) if target.type ~= Obj_AI_Hero then dmg = ({340, 500, 660, 820, 980})[level] end; return dmg end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({36, 45, 54, 63, 72})[level] + 0.30 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({16, 24, 32, 40, 48})[level] + 0.06 * source.ap end},--per Snowbal
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({625, 950, 1275})[level] + 3.0 * source.ap end},
  },

  ["Olaf"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 120, 170, 220, 270})[level] + source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.5 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({15, 20, 25})[level] + 0.3 * source.totalDamage end},

  },

  ["Orianna"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.5 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.7 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 0.3 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 275, 350})[level] + 0.8 * source.ap end},
  },

  ["Ornn"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 45, 70, 95, 120})[level] + 1.1 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({0.12, 0.13, 0.14, 0.15, 0.16})[level] * target.maxHealth end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + (0.4 * source.bonusArmor) + (0.4 * source.bonusMagicResist) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({125, 175, 225})[level] + 0.2 * source.ap end},
  },

  ["Pantheon"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + 1.15 * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + source.ap end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 105, 155, 205, 255})[level] + 1.5 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({300, 500, 700})[level] + source.ap end},
  },

  ["Poppy"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 60, 80, 100, 120})[level] + (0.9 * source.bonusDamage) + (0.08 * target.maxHealth) end}, --initial
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + (1.8 * source.bonusDamage) + (0.16 * target.maxHealth) end}, --totalDamage
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.7 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] + 0.5 * source.bonusDamage end},
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({120, 160, 200, 240, 280})[level] + source.bonusDamage end},--Target collide with terrain
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({100, 150, 200})[level] + 0.45 * source.bonusDamage end}, --quick cast, releasing within 0.5 secs
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.9 * source.bonusDamage end}, --full cast, releasing after 0.5 secs
  },

  ["Pyke"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({85, 135, 185, 235, 285})[level] + 0.6 * source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({105, 135, 165, 195, 225})[level] + source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550})[myHero.levelData.lvl] + (0.8 * source.bonusDamage) + 1.5 * source.armorPen end},
  },

  ["Qiyana"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 0.9 * source.bonusDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({96, 136, 176, 216, 256})[level] + 1.44 * source.bonusDamage end},--Terrain Damage
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({8, 22, 36, 50, 64})[level] + (0.1 * source.bonusDamage) + (0.45 * source.ap) end},--Passive
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 90, 120, 140, 180})[level] + 0.7 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({100, 200, 300})[level] + (1.7 * source.bonusDamage) + (0.1 * target.maxHealth) end},
  },

  ["Quinn"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 45, 70, 95, 120})[level] + (({0.8, 0.9, 1.0, 1.1, 1.2})[level] * source.totalDamage) + (0.5 * source.ap) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 70, 100, 130, 160})[level] + 0.2 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.4 * source.totalDamage end},
  },

  ["Rakan"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.70 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 125, 180, 235, 290})[level] + 0.70 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.50 * source.ap end},
  },

  ["Rammus"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 130, 160, 190, 220})[level] + source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 175, 250})[level] + (0.6 * source.ap) end}, -- impact
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({100, 175, 250})[level] + (0.6 * source.ap) + (({100, 130, 160, 190, 220})[source:GetSpellData(_Q).level] + source.ap) end}, -- center impact
  },

  ["Reksai"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({21, 27, 30, 39, 45})[level] + 0.5 * source.bonusDamage end},--UNBURROWED min per attack
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + (0.5 * source.bonusDamage) + (0.7 * source.ap) end},--BURROWED
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 70, 85, 100, 115})[level] + 0.8 * source.bonusDamage end},--BURROWED
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 60, 65, 70, 75})[level] + 0.85 * source.bonusDamage end},--UNBURROWED
    {Slot = "E", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({110, 120, 130, 140, 150})[level] + 1.7 * source.bonusDamage end},--UNBURROWED + Max FURY
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({100, 250, 400})[level] + (1.75 * source.bonusDamage) + ({20, 25, 30})[level] / 100 * GetMissingHP(target) end},
  },

  ["Rell"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.5 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({35, 52.5, 70, 87.5, 105})[level] + 0.25 * source.ap end}, -- secondary damage
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.6 * source.ap end}, -- if mounted
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + 0.3 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({120, 200, 280})[level] + 1.1 * source.ap end}, --totalDamage per target
  },

  ["Renekton"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + 1.00 * source.bonusDamage end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({90, 135, 180, 225, 270})[level] + 1.40 * source.bonusDamage end}, --REIGN OF ANGER
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 30, 50, 70, 90})[level] + 1.5 * source.totalDamage end},
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({15, 45, 75, 105, 135})[level] + 2.25 * source.totalDamage end}, --REIGN OF ANGER
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 140, 200, 260, 360})[level] + 1.8 * source.bonusDamage end}, --both
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({110, 185, 260, 335, 410})[level] + 2.25 * source.totalDamage end}, --REIGN OF ANGER
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({25, 50, 75})[level] + 0.05 * source.ap+ 0.05 * source.bonusDamage end}, --per half Second
  },

  ["Rengar"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 60, 90, 120, 150})[level] + ((({0, 5, 10, 15, 20})[level] / 100) * source.totalDamage) end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({30, 45, 60, 75, 90, 105, 120, 135, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240})[source.levelData.lvl] + 0.4 * source.totalDamage end},--EMPOWERED ACTIVE
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + 0.8 * source.ap end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (40 + 10 * source.levelData.lvl) + 0.8 * source.ap end},--EMPOWERED ACTIVE
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 100, 145, 190, 235})[level] + 0.8 * source.bonusDamage end},
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return (35 + 15 * source.levelData.lvl) + 0.8 * source.bonusDamage end},--EMPOWERED ACTIVE
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (0.5 * source.bonusDamage) end},
  },

  ["Riven"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({15, 35, 55, 75, 95})[level] + ((({45, 50, 55, 60, 65})[level] / 100) * source.totalDamage) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 85, 115, 145, 175})[level] + source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({100, 150, 200})[level] + 0.6 * source.bonusDamage) * math_max(0.02667 * math_min(100 - GetPercentHP(target), 75), 1) end},
  },

  ["Rumble"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({180, 220, 260, 300, 340})[level] + 1.1 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 0.4 * source.ap end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({90, 127.5, 165, 202.5, 240})[level] + 0.6 * source.ap end}, --enhanced
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140})[level] + 0.175 * source.ap end},--per half Second
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({840, 1260, 1680})[level] + 2.1 * source.ap end},--full Damage
  },

  ["Ryze"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 90, 110, 130, 150})[level] + (0.55 * source.ap) + 0.02 * (source.maxMana - GetBaseMana(source)) * GotBuff(target, "RyzeE") and (10 + ((30) * (source:GetSpellData(_R).level) + 100) / 100) or 1 end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + (0.70 * source.ap) + 0.04 * (source.maxMana - GetBaseMana(source)) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + (0.45 * source.ap) + 0.02 * (source.maxMana - GetBaseMana(source)) end},
  },

  ["Samira"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({0, 5, 10, 15, 20})[level] + ({0.85, 0.95, 1.05, 1.5, 1.25})[level] * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 35, 50, 65, 80})[level] + 0.8 * source.bonusDamage end}, -- 1 Hit
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 60, 70, 80, 90})[level] + 0.2 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 150, 250})[level] + 5 * source.totalDamage end},	-- Full Damage over 2.277 seconds
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({5, 15, 25})[level] + 0.5 * source.totalDamage end},	-- per shot Damage
  },

  ["Sejuani"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.6 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 25, 30, 35, 40})[level] + (0.2 * source.ap) + (0.02 * source.maxHealth) end}, --swing
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({30, 70, 110, 150, 190})[level] + (0.6 * source.ap) + (0.06 * source.maxHealth) end}, --lash
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 105, 155, 205, 255})[level] + 0.6 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.8 * source.ap end},
  },

  ["Senna"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 70, 100, 130, 160})[level] + 0.5 * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.7 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({250, 375, 500})[level] + source.bonusDamage + (0.7 * source.ap) end},
  },

  ["Seraphine"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({55, 70, 85, 100, 115})[level] + ((({45, 50, 55, 60, 65})[level] / 100) * source.ap) end}, --min damage
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({82.5, 105, 127.5, 150, 172.5})[level] + ((({67.5, 75, 80.5, 90, 97.5})[level] / 100) * source.ap) end}, --max
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] + 0.35 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 200, 250})[level] + 0.6 * source.ap end},
  },

  ["Sett"] = {
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + (25 + (0.25 / 100 * source.bonusDamage) * source.maxMana / 100) end}, -- with expended Grit
    --{Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + 0.1 * source.bonusDamage end}, -- without expended Grit
    {Slot = "W", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + (25 + (0.25 / 100 * source.bonusDamage) * source.maxMana / 100) end}, -- True Damage with expended Grit
    --{Slot = "W", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + 0.1 * source.bonusDamage end}, -- True Damage without expended Grit
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 70, 90, 110, 130})[level] + 0.6 * source.totalDamage end},
    --{Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 300, 400})[level] + (1.2 * source.bonusDamage) + ({40, 50, 60})[level] / 100 * source.bonusHealth end}, -- with Target BonusHealth when GameObject.bonusHealth becomes a thing
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 300, 400})[level] + (1.2 * source.bonusDamage) + ((({40, 50, 60})[level] / 100) * (source.maxHealth - GetBaseHealth(source))) end},
  },

  ["Shaco"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({25, 35, 45, 55, 65})[level] + 0.40 * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 1540, 20, 25, 30})[level] + 0.12 * source.ap end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({25, 40, 55, 70, 85})[level] + 0.18 * source.ap end}, -- if 1 target
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (GetPercentHP(target) < 30 and ({105, 142.5, 180, 217.5, 255})[level] + (0.90 * source.ap) + (1.125 * source.bonusDamage) or ({70, 95, 120, 145, 170})[level] + (0.60 * source.ap) + (0.75 * source.bonusDamage)) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.7 * source.ap end},
  },

  ["Shen"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = ({2, 2.5, 3, 3.5, 4})[level]/100 + (0.015 * math_floor(source.ap/100)) * target.maxHealth; if target.type == Obj_AI_Hero then return dmg end; return math_min(({30, 50, 70, 90, 110})[level]+dmg, ({75, 100, 125, 150, 175})[level]) end}, -- baseDamage
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) local dmg = ({4, 4.5, 5, 5.5, 6})[level]/100 + (0.02 * math_floor(source.ap/100)) * target.maxHealth; if target.type == Obj_AI_Hero then return dmg end; return math_min(({30, 50, 70, 90, 110})[level]+dmg, ({75, 100, 125, 150, 175})[level]) end}, -- enhanced if collided with champion
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 85, 110, 135, 160})[level] + 0.15 * (source.maxHealth - (540 + (85 * (source.levelData.lvl - 1)))) end},
  },

  ["Shyvana"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({20, 35, 50, 65, 80})[level] / 100 * source.totalDamage) + (0.25 * source.ap) end},
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return (1 * source.totalDamage) + (0.35 * source.ap) end}, --Dragon Form
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 16.25, 22.5, 28.75, 35})[level] + (0.15 * source.bonusDamage) end},--per Second
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + (0.90 * source.ap) + (0.40 * source.totalDamage) end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) local lvldmg = ({75, 75, 75, 75, 75, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135})[source.levelData.lvl] return (lvldmg) + ({60, 100, 140, 180, 220})[level] + source.ap + (0.6 * source.totalDamage) end},--Dragon Form per Second
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 1.30 * source.ap end},
  },

  ["Singed"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({5, 7.5, 10, 12.5, 15})[level] + 0.1125 * source.ap end}, --per 0.25 second over 2 seconds
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 65, 80, 95, 110})[level] + (0.75 * source.ap) + (({6, 6.5, 7, 7.5, 8})[level] / 100 * target.maxHealth) end},
  },

  ["Sion"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 50, 70, 90, 110})[level] + (({45, 52.5, 60, 67, 75})[level] / 100 * source.totalDamage) end}, -- min damage
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({70, 135, 200, 265, 330})[level] + (({135, 157.5, 180, 202.2, 225})[level] / 100 * source.totalDamage) end}, -- max damage
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + (0.4 * source.ap) + (({10, 11, 12, 13, 14})[level] / 100 * target.maxHealth) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 100, 135, 170, 205})[level] + (0.55 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 300, 450})[level] + (0.4 * source.bonusDamage) end}, --min damage
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({400, 800, 1200})[level] + (0.8 * source.bonusDamage) end}, --max damage after channeling for atleast 3 seconds
  },

  ["Sivir"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (1 + math_min(1, 0.5 * source.critChance)) * ({15, 30, 45, 60, 75})[level] + (({80, 85, 90, 95, 100})[level] / 100 * source.totalDamage) + (0.6 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) local dmg = ({25, 30, 35, 40, 45})[level] / 100 * source.totalDamage; if target.type == Obj_AI_Minion then dmg = 0.65 * dmg; if target.health - dmg < 15 then dmg = target.health; end; end; return dmg end},
  },

  ["Skarner"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (0.2 * source.totalDamage) + (({1, 1.5, 2, 2.5, 3})[level] / 100 * target.maxHealth) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + (0.2 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 60, 100})[level] + 0.5 * source.ap end}, --initial damage
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({40, 120, 200})[level] + source.ap + (1.2 * source.totalDamage) end}, --damage on succeed impale
  },

  ["Sona"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + (0.4 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + (0.5 * source.ap) end},
  },

  ["Soraka"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({85, 120, 155, 190, 225})[level] + (0.35 * source.ap) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 95, 120, 145, 170})[level] + (0.4 * source.ap) end},
  },

  ["Swain"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] + (0.38 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + (0.55 * source.ap) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({35, 70, 105, 140, 175})[level] + (0.25 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 40, 60})[level] + (0.10 * source.ap) end}, --per Second
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + (0.6 * source.ap) end}, --detonation
  },

  ["Sylas"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80, 100, 120})[level] + 0.4 * source.ap end},
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 125, 180, 235, 290})[level] + 0.9 * source.ap end}, --detonation after 0.6
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.90 * source.ap end},
    -- no longer used {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({97, 150, 202, 255, 307})[level] + 0.97 * source.ap end},--if Target below 40%
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + source.ap end},
	  {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return 0 end},  --Hijacked abilities that do not scale with AP have their AD | AD ratios converted to AP ratios, scaling with 0.6% AP per 1% total AD, and 0.4% AP per 1% bonus AD.
	  {Slot = "R", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({300, 475, 650})[level] + 0.5 * source.ap + 0.1 * (source.maxHealth - GetBaseHealth(source)) end}, --cho'garh
	  {Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return (({200, 400, 600})[level] + source.ap) end}, --ashe
	  {Slot = "R", Stage = 4, DamageType = 2, Damage = function(source, target, level) return (({175, 250, 325})[level] + 0.75 * source.ap) end}, --vaiger
	  {Slot = "R", Stage = 5, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.8 * source.ap) end}, --leona
	  {Slot = "R", Stage = 6, DamageType = 2, Damage = function(source, target, level) return (({350, 500, 650})[level] + 0.9 * source.ap + 0.45 * source.ap) end}, --ezreal
 	  {Slot = "R", Stage = 7, DamageType = 2, Damage = function(source, target, level) return ({25, 35, 45})[level]/ 100 * 0.7 + (({0.25, 0.30, 0.35})[level] * GetMissingHP(target)) + 0.15 * source.bonusDamage/100 * 0.5 end}, --jinx
 	  {Slot = "R", Stage = 8, DamageType = 2, Damage = function(source, target, level) return (({250, 400, 550})[level] + 0.75 * source.ap) end}, --kartus
 	  {Slot = "R", Stage = 9, DamageType = 2, Damage = function(source, target, level) return (({200, 300, 400})[level] + 0.733 * source.ap) end}, --ziggs
 	  {Slot = "R", Stage = 10, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.5 * source.ap) end}, --cassio
 	  {Slot = "R", Stage = 11, DamageType = 2, Damage = function(source, target, level) return (({300, 400, 500})[level] + 0.75 * source.ap) end}, --lux
  	{Slot = "R", Stage = 12, DamageType = 2, Damage = function(source, target, level) return (({300, 400, 500})[level] + source.ap) end}, --tristana
    {Slot = "R", Stage = 13, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80})[level] + 0.125 * source.ap end},--Anivia
    {Slot = "R", Stage = 14, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * source.ap end},--AurelionSol
  	{Slot = "R", Stage = 15, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.6 * source.ap) end}, --Braum
  	{Slot = "R", Stage = 16, DamageType = 2, Damage = function(source, target, level) return (({125, 225, 325})[level] + 0.7 * source.ap) end}, --Irelia
  	{Slot = "R", Stage = 17, DamageType = 2, Damage = function(source, target, level) return (({625, 950, 1275})[level] + 2.5 * source.ap) end}, --Nunu
  	{Slot = "R", Stage = 18, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.6 * source.ap) end}, -- Lissandra
  	{Slot = "R", Stage = 19, DamageType = 2, Damage = function(source, target, level) return (({125, 200, 275})[level] + 0.8 * source.ap) end}, --Malzahar
  	{Slot = "R", Stage = 20, DamageType = 2, Damage = function(source, target, level) return (({80, 220, 360})[level] + 0.5 * source.bonusDamage + 0.30 * source.ap) end}, --Akali
  	{Slot = "R", Stage = 21, DamageType = 2, Damage = function(source, target, level) return (({80, 220, 360})[level] + 0.5 * source.bonusDamage + 0.30 * source.ap + 0.02 * (target.maxHealth - target.health)) end}, --Akalib
   	{Slot = "R", Stage = 22, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.8 * source.ap) end}, --Amumu
  	{Slot = "R", Stage = 23, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 450})[level] + 0.6 * source.ap) end}, --azir
   	{Slot = "R", Stage = 24, DamageType = 2, Damage = function(source, target, level) return (({125, 250, 375})[level] + 0.75 * source.ap) end}, --evelynn
   	{Slot = "R", Stage = 25, DamageType = 2, Damage = function(source, target, level) return (({250, 375, 500})[level] + 1.0 * source.ap) end}, --blitzgrank
  	{Slot = "R", Stage = 26, DamageType = 2, Damage = function(source, target, level) return (({175, 275, 375})[level]/100 * 0.7 + 0.55 * source.ap) end}, -- draven
   	{Slot = "R", Stage = 27, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.6 * source.ap) end}, --fizz
  	{Slot = "R", Stage = 28, DamageType = 2, Damage = function(source, target, level) return (({200, 300, 400})[level]/100 * 0.7 + 0.1 * source.ap + 0.5 * source.ap) end}, -- gnar
  	{Slot = "R", Stage = 29, DamageType = 2, Damage = function(source, target, level) return (({200, 300, 400})[level] + 0.70 * source.ap) end}, -- gragas
   	{Slot = "R", Stage = 30, DamageType = 2, Damage = function(source, target, level) return (({90, 125, 160})[level] + (({0.15, 0.45, 0.75})[level]* source.ap) + 0.2 * source.ap) end}, --Corki
  	{Slot = "R", Stage = 31, DamageType = 2, Damage = function(source, target, level) return (({250, 400, 550})[level]/100*0.7 + 0.75 * source.ap) end}, -- graves
   	{Slot = "R", Stage = 32, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 1.0 * source.ap) end}, --hecarim
  	{Slot = "R", Stage = 33, DamageType = 2, Damage = function(source, target, level) return (({122, 306, 490})[level] + 0.35 * source.ap) end}, --Jhin
  	{Slot = "R", Stage = 34, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.6 * source.ap end}, -- Diana
  	{Slot = "R", Stage = 35, DamageType = 2, Damage = function(source, target, level) return (({375, 562, 750})[level] + 1.65 * source.ap + 2.85 * source.ap) end}, --katarina
  	{Slot = "R", Stage = 36, DamageType = 2, Damage = function(source, target, level) return (({40, 75, 110})[level] + 0.2 * source.ap) end}, --Kennen
  	{Slot = "R", Stage = 37, DamageType = 2, Damage = function(source, target, level) return (({150, 225, 300})[level] + 0.75 * source.ap) end}, --Maokai
  	{Slot = "R", Stage = 38, DamageType = 2, Damage = function(source, target, level) return (({250, 400, 500})[level] + 1.0 * source.ap) end}, --Missfortune
   	{Slot = "R", Stage = 39, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.6 * source.ap) end}, --Nami
   	{Slot = "R", Stage = 40, DamageType = 2, Damage = function(source, target, level) return (({200, 325, 450})[level] + 0.8 * source.ap) end}, --Nautilus
   	{Slot = "R", Stage = 41, DamageType = 2, Damage = function(source, target, level) return (({130, 185, 240})[level] + 0.3 * source.ap) end}, --rumble
  	{Slot = "R", Stage = 42, DamageType = 2, Damage = function(source, target, level) return (({100, 125, 150})[level] + 0.4 * source.ap) end}, --Sejuani
   	{Slot = "R", Stage = 43, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + 0.5 * source.ap) end}, --sona
  	{Slot = "R", Stage = 44, DamageType = 2, Damage = function(source, target, level) return (({50, 175, 300})[level]/100*0.7 + 0.25 * source.ap) end}, --urgot
  	{Slot = "R", Stage = 45, DamageType = 2, Damage = function(source, target, level) return (({150, 200, 250})[level] + 1.0 * source.ap) end}, --varus
   	{Slot = "R", Stage = 46, DamageType = 2, Damage = function(source, target, level) return (({180, 265, 350})[level] + 0.7 * source.ap) end}, --Zyra
  	{Slot = "R", Stage = 47, DamageType = 2, Damage = function(source, target, level) return (({175, 350, 525})[level]/100*0.7 + 0.835 * source.ap) end}, --Warwick
  	{Slot = "R", Stage = 48, DamageType = 2, Damage = function(source, target, level) return (({100, 200, 300})[level] + 0.3 * source.ap) end}, --brand
  	{Slot = "R", Stage = 49, DamageType = 2, Damage = function(source, target, level) return (({175, 350, 525})[level]) end}, --Geran
  	{Slot = "R", Stage = 50, DamageType = 2, Damage = function(source, target, level) return (({200, 300, 400})[level] + 1.0 * source.ap) end}, --malphite
  	{Slot = "R", Stage = 51, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level] + source.ap) end}, --shyvana
  	{Slot = "R", Stage = 52, DamageType = 2, Damage = function(source, target, level) return (({150, 225, 300})[level] + 0.7 * source.ap) end}, --morgana
  	{Slot = "R", Stage = 53, DamageType = 2, Damage = function(source, target, level) return (({20, 110, 200})[level]/100*0.7 + 0.55 * source.ap) end},	--wukong
	  {Slot = "R", Stage = 54, DamageType = 2, Damage = function(source, target, level) return ({125, 225, 325})[level] + 0.45 * source.ap end}, --Fiddlesticks
	  {Slot = "R", Stage = 55, DamageType = 2, Damage = function(source, target, level) return ({105, 180, 255})[level] + 0.3 * source.ap end}, --Gangplank
	  {Slot = "R", Stage = 56, DamageType = 2, Damage = function(source, target, level) return (({150, 250, 350})[level]/100*0.7 + 0.55 * source.ap) end}, --Illaoi
	  {Slot = "R", Stage = 57, DamageType = 2, Damage = function(source, target, level) return ({200, 325, 450})[level]/100*0.7 + 0.75 * source.ap end}, --Jarvan
	  {Slot = "R", Stage = 58, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120})[level]+ 0.4 * source.ap + 0.02 * source.maxMana end}, --Kassadin
	  {Slot = "R", Stage = 59, DamageType = 2, Damage = function(source, target, level) return (({100, 140, 180})[level] + 0.325 * source.ap + 0.25 * source.ap) * (GetPercentHP(target) < 25 and 3 or (GetPercentHP(target) < 50 and 2 or 1)) end}, --Kogmaw
	  {Slot = "R", Stage = 60, DamageType = 2, Damage = function(source, target, level) return (({70, 140, 210})[level] + 0.4 * source.ap) end},-- Leblanc
	  {Slot = "R", Stage = 61, DamageType = 2, Damage = function(source, target, level) return ({20, 35, 50})[level]/100*0.7 + 0.1 * source.ap + 0.25 * source.totalDamage/100 * 0.7 end}, --Lucian
	  {Slot = "R", Stage = 62, DamageType = 2, Damage = function(source, target, level) return ({40, 80, 120})[level] + 0.2 * source.ap end},--Rammus
	  {Slot = "R", Stage = 63, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * source.ap end},--Vladimir
	  {Slot = "R", Stage = 64, DamageType = 2, Damage = function(source, target, level) return ({300, 525, 750})[level]/100*0.7 + source.ap end},--Caitlyn
	  {Slot = "R", Stage = 65, DamageType = 2, Damage = function(source, target, level) return (({200, 425, 650})[level] + 1.3 * source.ap) end},--Neeko
	  {Slot = "R", Stage = 66, DamageType = 2, Damage = function(source, target, level) return ({150, 225, 300})[level] + 0.7 * source.ap end},--Orianna
	  {Slot = "R", Stage = 67, DamageType = 2, Damage = function(source, target, level) return ({50, 70, 90})[level] + 0.2 * source.ap end},--Swain
	  {Slot = "R", Stage = 68, DamageType = 2, Damage = function(source, target, level) return ({250, 400, 550})[level] + source.ap end}, --Thresh
	  {Slot = "R", Stage = 69, DamageType = 2, Damage = function(source, target, level) return ({250, 475, 700})[level] + 1.25 * source.ap + 2.5 * source.bonusDamage end},--Volibear
	  {Slot = "R", Stage = 70, DamageType = 2, Damage = function(source, target, level) return ({180, 270, 360})[level] + 1.05 * source.ap end},--Ahri
	  {Slot = "R", Stage = 71, DamageType = 3, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.75 * source.ap end},--Darius
	  {Slot = "R", Stage = 72, DamageType = 2, Damage = function(source, target, level) return ({150, 300, 450})[level] + 1.5 * source.ap end},--Ekko
	  {Slot = "R", Stage = 73, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.7 * source.ap end},--Galio
	  {Slot = "R", Stage = 74, DamageType = 2, Damage = function(source, target, level) return ({105, 262, 420})[level] + source.ap end},--LeeSin
	  {Slot = "R", Stage = 75, DamageType = 2, Damage = function(source, target, level) return ({105, 192, 280})[level] + 0.6 * source.ap end},--Nocturne
	  {Slot = "R", Stage = 76, DamageType = 2, Damage = function(source, target, level) return ({200, 350, 500})[level] + 0.5 * source.ap end},--Pantheon
	  {Slot = "R", Stage = 77, DamageType = 2, Damage = function(source, target, level) return ({140, 210, 280})[level] + 0.45 * source.ap end},--Poppy
	  {Slot = "R", Stage = 78, DamageType = 2, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.5 * source.ap end},--Rakan
	  {Slot = "R", Stage = 79, DamageType = 2, Damage = function(source, target, level) return ({70, 175, 280})[level] + source.ap + (({0.20, 0.25, 0.30})[level] * (target.maxHealth - target.health)) end},--RekSai
	  {Slot = "R", Stage = 80, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + source.ap end},--Shaco
	  {Slot = "R", Stage = 81, DamageType = 2, Damage = function(source, target, level) return ({63, 94, 126})[level] + 0.5 * source.ap end},--Talon
	  {Slot = "R", Stage = 82, DamageType = 2, Damage = function(source, target, level) return ({105, 210, 315})[level] + 0.7 * source.ap end},--Vi
	  {Slot = "R", Stage = 83, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + 0.6 * source.ap end},--Viktor
	  {Slot = "R", Stage = 84, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140})[level] + 0.5 * source.ap end},--Xayah
	  {Slot = "R", Stage = 85, DamageType = 2, Damage = function(source, target, level) return ({140, 210, 280})[level] + 0.75 * source.ap end},--Yasuo
	  {Slot = "R", Stage = 86, DamageType = 1, Damage = function(source, target, level) return ({250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550})[source.levelData.lvl] + 0.8 * source.bonusDamage + 1.5 * source.armorPen end}, --Pyke
  },

  ["Syndra"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({70, 105, 140, 175, 210})[level] + 0.70 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.70 * source.ap end}, -- TODO: calc for 60 splinters of wrath +15%(+1.5% per 100 ap) bonus true damage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 115, 155, 195, 235})[level] + 0.55 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({270, 390, 510})[level] + 0.51 * source.ap end}, -- min damage TODO: 100 splinters of wrath execute under 15% hp
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({90, 130, 170})[level] + 0.17 * source.ap end},-- PER SPHERE
  },

  ["Talon"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({65, 90, 115, 140, 165})[level] * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({40, 50, 60, 70, 80})[level] + 0.40 * source.bonusDamage end},--INITIAL DAMAGE
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + 0.8 * source.bonusDamage end},--RETURN DAMAGE
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({90, 135, 180})[level] + source.bonusDamage end},
  },

  ["Taliyah"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({45, 65, 85, 105, 125})[level] + 0.50 * source.ap end}, --for total dmg = dmg + 4(0.40*dmg) 5 hits susequent hits deal 40%
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({76, 114, 152, 190, 228})[level] + 0.95 * source.ap end}, --Empowered Single
    --{Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] + 0.4 * source.ap end}, --No longer deals damage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.4 * source.ap end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({62.5, 112.5, 162.5, 212.5, 262.5})[level] + 0.825 * source.ap end}, --max trigger damage
  },

  ["Taric"] = {
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({90, 130, 170, 210, 250})[level] + (0.5 * source.ap) + (0.5 * source.bonusArmor) end},
  },

  ["TahmKench"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 130, 180, 230, 280})[level] + 0.90 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 135, 170, 205, 240})[level] + 1.25 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 250, 400})[level] + (0.15 + (0.05 * math_floor(source.ap/100)) * target.maxHealth) end}, --2nd cast damage "Regurgitate"
  },

  ["Teemo"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 125, 170, 215, 260})[level] + 0.8 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = (({24, 48, 72, 96, 120})[level] + (0.4 * source.ap)) ; if target.type == Obj_AI_Camp then dmg = (dmg * 1.5) end ; return dmg end}, --total after 4sec of ticks
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg = (({14, 25, 36, 47, 58})[level] + (0.3 * source.ap)) ; if target.type == Obj_AI_Camp then dmg = (dmg * 1.5) end ; return dmg end}, --on hit
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 325, 450})[level] + 0.55 * source.ap end}, --total damage
  },

  ["Thresh"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 140, 180, 220, 260})[level] + 0.5 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 110, 145, 180, 215})[level] + 0.4 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({250, 400, 550})[level] + source.ap end},
  },

  ["Tristana"] = {
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({95, 145, 195, 245, 295})[level] + 0.5 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 80, 90, 100, 110})[level] + (({0.5, 0.75, 1, 1.25, 1.5})[level] * source.bonusDamage) + (0.5 * source.ap) + (0.333 * source.critChance) + (GetBuffData(source, "tristanaecharge").count * ({21, 24, 27, 30, 33})[level] + (({0.15, 0.225, 0.30, 0.375, 0.45})[level] * source.bonusDamage) + (0.15 * source.ap)) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({300, 400, 500})[level] + source.ap end},
  },

  ["Trundle"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 40, 60, 80, 100})[level] + (({0.15, 0.25, 0.35, 0.45, 0.55})[level] * source.totalDamage) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({20, 27.5, 35})[level]/100 + 0.02 * math_floor(source.ap/100)) * target.maxHealth end},
  },

  ["Tryndamere"] = {
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + (1.3 * source.bonusDamage) + (0.8 * source.ap) end},
  },

  ["TwistedFate"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + 0.80 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 60, 80, 100, 120})[level] + source.totalDamage + (0.9 * source.ap) end},--Blue Card
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({30, 45, 60, 75, 90})[level] + source.totalDamage + (0.6 * source.ap) end},--Red Card
    {Slot = "W", Stage = 3, DamageType = 2, Damage = function(source, target, level) return ({15, 22.5, 30, 37.5, 45})[level] + source.totalDamage + (0.5 * source.ap) end},--Gold Card
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) local count = GotBuff(source, "cardmasterstackparticle") if count > 0 then return (({65, 90, 115, 140, 165})[level] + 0.5 * source.ap) end ; return 0 end}, --calc damage only if at 3 stacks for empowered AA
  },

  ["Twitch"] = {
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (GotBuff(target, "TwitchDeadlyVenom") * ({15, 20, 25, 30, 35})[level] + (0.35 * source.ap) + (0.35 * source.bonusDamage)) + ({20, 30, 40, 50, 60})[level] end}, --mixed damage
    {Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({15, 20, 25, 30, 35})[level] + (0.333 * source.ap) + (0.35 * source.bonusDamage) + ({20, 35, 50, 65, 80})[level] end}, --mixed damage
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({40, 55, 70})[level] end},
  },

  ["Udyr"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({3.00, 4.40, 5.80, 7.20, 8.60, 10.00})[level]/100 + (0.06 * math_floor(source.bonusDamage / 100))) * target.maxHealth end}, --TODO: is AA damage x2 + on-hit
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ((1.5 + 1.5 / 17 * (level-1)) + (0.008 * math_floor(source.ap / 100))) * target.maxHealth end}, --Awaken lightning + TODO: min dmg against minions
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 19, 28, 37, 46, 55})[level] + (0.20 * source.ap) end}, --per tick
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (0.01 + 0.01 / 17 * (level-1) + (0.4375/100 * math_floor(source.ap / 100)) * target.maxHealth) end}, --Awaken storm per tick
    {Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return (10 + 20 / 17 * (level-1)) + (0.30 * source.ap) end}, --is AA dmg see SpecialAADamageTable

  },

  ["Urgot"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({25, 70, 115, 160, 205})[level] + 0.7 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 12 + ((({20, 23.5, 27, 30.5, 34})[level] / 100) * source.totalDamage) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({90, 120, 150, 180, 210})[level] + source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({100, 225, 350})[level] + 0.5 * source.bonusDamage end},
  },

  ["Varus"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 46.67, 83.33, 120, 156.67})[level] + ((({83.33, 86.67, 90, 93.33, 96.67})[level] / 100) * source.totalDamage) end}, --min
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({15, 70, 125, 180, 235})[level] + ((({125, 130, 135, 140, 145})[level] / 100) * source.totalDamage) end}, --max
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({7, 8, 9, 10, 11})[level] + 0.25 * source.ap end}, --non per stack
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ((({3, 3.5, 4, 4.5, 5})[level] / 100) + 0.02 * math_floor(source.ap/100)) * target.maxHealth end}, -- per stack
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({60, 100, 140, 180, 220})[level] + (0.6 * source.bonusDamage) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 200, 250})[level] + source.ap end},
  },

  ["Vayne"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({60, 65, 70, 75, 80})[level] / 100) * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 3, Damage = function(source, target, level) return math_max(({50, 65, 80, 95, 110})[level], (({4, 6.5, 9, 11.5, 14})[level] / 100) * target.maxHealth) end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 85, 120, 155, 190})[level] + (0.5 * source.bonusDamage) end},
  },

  ["Veigar"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + (0.6 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 150, 200, 250, 300})[level] + source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (0.015 * GetPercentHP(target) + 1) * ({175, 250, 325})[level] + (0.75 * source.ap) end},
  },

  ["Velkoz"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + (0.8 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 50, 70, 90, 110})[level] + (0.15 * source.ap) end}, --initial damage
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({45, 75, 105, 135, 165})[level] + (0.25 * source.ap) end}, --detonation
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 100, 130, 160, 190})[level] + (0.3 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) return (GotBuff(target, "velkozresearchedstack") > 0 and ({450, 625, 800})[level] + (1.25 * source.ap) or CalcDamage(source, target, ({450, 625, 800})[level] + (1.25 * source.ap))) end},
  },

  ["Vex"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + (0.7 * source.ap) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 140, 170})[level] + (0.3 * source.ap) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 70, 90, 110, 130})[level] + (({0.40, 0.45, 0.5, 0.55, 0.60})[level] * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 125, 175})[level] + (0.20 * source.ap) end}, -- initial hit
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + (0.50 * source.ap) end}, -- recast impact
  },

  ["Viego"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ((1.0 + math_min(1.0, 1.0 * source.critChance)) * ({15, 30, 45, 60, 75})[level] + (0.7 * source.totalDamage)) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (((({12, 16, 20})[level] / 100) + (0.03 * math_floor(source.bonusDamage / 100))) * (GetPercentMissingHP(target))) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (1.2 * source.totalDamage) * (1 + math_min(1, 1 * source.critChance)) end}, --slash damage
  },

  ["Vi"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 80, 105, 130, 155})[level] + (0.7 * source.bonusDamage) end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({4, 5.5, 7, 8.5, 10})[level] / 100 + (0.01 * math_floor(source.bonusDamage / 35))) * target.maxHealth end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 30, 50, 70, 90})[level] + (1.1 * source.totalDamage) + (0.9 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({150, 325, 500})[level] + (1.1 * source.bonusDamage) end},
  },

  ["Viktor"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 120, 160, 200, 240})[level] + source.ap + source.totalDamage end}, --totalDamage active & discharge
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.5 * source.ap end},
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({90, 170, 250, 330, 410})[level] + 1.3 * source.ap end},--Total Damage with augment aftershock
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 175, 250})[level] + 0.5 * source.ap end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({65, 105, 145})[level] + 0.45 * source.ap end},--Per Tick
  },

  ["Vladimir"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + 0.6 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({148, 185, 222, 259, 296})[level] + 1.11 * source.ap end},--empowered q
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 33.75, 47.5, 61.25, 75})[level] + (0.025 * (source.maxHealth - GetBaseHealth(source))) end}, --per tick
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({80, 135, 190, 245, 300})[level] + (0.1 * (source.maxHealth - GetBaseHealth(source))) end}, --totalDamage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({30, 45, 60, 75, 90})[level] + (0.35 * source.ap) + (0.015 * source.maxHealth) end}, --min damage
    {Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 90, 120, 150, 180})[level] + (0.80 * source.ap) + (0.06 * source.maxHealth) end}, --max damage
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) local dmg =  ({150, 250, 350})[level] + 0.7 * source.ap; return dmg * 1.10 end}, --increases all dmg +10%
  },

  ["Volibear"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({10, 30, 50, 70, 90})[level] + 1.2 * source.bonusDamage end},
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (({5, 30, 55, 80, 105})[level]) + 1.00 * source.totalDamage + (0.05 * (source.maxHealth - GetBaseHealth(source))) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + (0.80 * source.ap) + (({0.11, 0.12, 0.13, 0.14, 0.15})[level] * target.maxHealth) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({300, 500, 700})[level] + (1.25 * source.ap) + (2.5 * source.bonusDamage) end},
  },

  ["Warwick"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({6, 7, 8, 9, 10})[level] / 100  * target.maxHealth) + source.ap + (1.2 * source.totalDamage) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({175, 350, 525})[level] + 1.67 * source.bonusDamage end},
  },

  ["Xayah"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + 0.5 * source.bonusDamage end}, --per blade
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({55, 65, 75, 85, 95})[level] + 0.6 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({125, 250, 375})[level] + source.bonusDamage end},
  },

  ["Xerath"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 230})[level] + 0.85 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.6 * source.ap end}, -- Base damage
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({100, 158.4, 216.7, 275, 333.3})[level] + 1.02 * source.ap end}, --Center blast
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 110, 140, 170, 200})[level] + 0.45 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 250, 300})[level] + 0.43 * source.ap end},
  },

  ["XinZhao"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({16, 25, 34, 43, 52})[level] + 0.4 * source.bonusDamage end}, --per attack for next 3 AA
    {Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (0.33 * source.critChance) * ({80, 125, 170, 215, 260})[level] + (1.1 * source.totalDamage) + (0.65 * source.ap) end},	--total damage slash & thrust
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return (0.33 * source.critChance) * ({50, 85, 120, 155, 190})[level] + (0.9 * source.totalDamage) + (0.65 * source.ap) end},	--thrust damage
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 75, 100, 125, 150})[level] + 0.6 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({75, 175, 275})[level] + source.bonusDamage + (0.15 * target.health) end},
  },

  ["Yasuo"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 45, 70, 95, 120})[level] + 1.05 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 70, 80, 90, 100})[level] + (0.2 * source.bonusDamage) + (0.6 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 350, 500})[level] + 1.5 * source.bonusDamage end},
  },

  ["Yone"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({20, 40, 60, 80, 100})[level] + 1.05 * source.totalDamage end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({5, 10, 15, 20, 25})[level] + (({0.055, 0.06, 0.065, 0.07, 0.075})[level] * target.maxHealth) end}, -- Ap Damage
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({5, 10, 15, 20, 25})[level] + (({0.055, 0.06, 0.065, 0.07, 0.075})[level] * target.maxHealth) end}, -- AD Damage
    {Slot = "E", Stage = 1, DamageType = 3, Damage = function(source, target, level) return ({25, 27.5, 30, 32.5, 35})[level] / 100 end}, -- Stored damage percentage
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.4 * source.totalDamage end}, -- Ap Damage
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({100, 200, 300})[level] + 0.4 * source.totalDamage end}, -- Ad Damage
  },

  ["Yorick"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({30, 55, 80, 105, 130})[level] + 0.4 * source.totalDamage end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + (0.7 * source.ap) + (0.15 * target.health) end},
  },

  ["Yuumi"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 80, 110, 140, 170, 200})[level] + 0.3 * source.ap end}, --Normal
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 100, 140, 180, 220, 260})[level] + 0.4 * source.ap + ((({2, 3.2, 4.4, 5.6, 6.8, 8})[level] / 100) * target.health) end}, --empowered damage
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({240, 320, 400})[level] + 0.8 * source.ap end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100})[level] + 0.2 * source.ap end}, --per wave
  },

  ["Zac"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 55, 70, 85, 100})[level] + (0.3 * source.ap) + (0.025 * source.maxHealth) end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({35, 50, 65, 80, 95})[level] + ((({4, 5, 6, 7, 8})[level] / 100 + (0.04 * math_floor(source.ap / 100))) * target.maxHealth) end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 110, 160, 210, 260})[level] + 0.9 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({140, 210, 280})[level] + 0.4 * source.ap end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({350, 525, 700})[level] + source.ap end}, --max single target
  },

  ["Zed"] = {
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 115, 150, 185, 220})[level] + source.bonusDamage end},
    {Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({70, 90, 110, 130, 150})[level] + 0.8 * source.bonusDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.65 * source.totalDamage end},
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({25, 40, 55})[level] / 100 end}, -- percent of damage dealt
  },

  ["Zeri"] = {
    {Slot = "Q", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({8, 11, 14, 17, 20})[level] + (({1.00, 1.05, 1.10, 1.15, 1.20})[level] * source.totalDamage)  + (0.60 * source.ap)end}, --total
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({20, 50, 90, 125, 160})[level] + (1.00 * source.totalDamage) + (0.40 * source.ap) end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({150, 250, 350})[level] + (0.8 * source.bonusDamage) + (0.8 * source.ap) end}, --Nova damage
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({5, 10, 15})[level] + (0.15 * source.ap) end}, -- on hit bonus magic damage
  },

  ["Ziggs"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({95, 145, 195, 245, 295})[level] + 0.65 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 105, 140, 175, 210})[level] + 0.50 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 75, 110, 145, 180})[level] + 0.30 * source.ap end}, --per mine
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({300, 450, 600})[level] + 1.10 * source.ap end}, --center damage
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({200, 300, 400})[level] + 0.7333 * source.ap end}, --normal damage
  },

  ["Zilean"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 115, 165, 230, 300})[level] + 0.9 * source.ap end},
  },

  ["Zoe"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({50, 80, 110, 140, 170})[level] + (0.60 * source.ap) + ({7, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 29, 32, 35, 38, 42, 46, 50})[source.levelData.lvl] end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({75, 105, 135, 165, 195})[level] + 0.40 * source.ap end}, -- total damage
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({25, 35, 45, 55, 65})[level] + 0.133 * source.ap end}, -- per bolt 3 total
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 110, 150, 190, 2230})[level] + 0.45 * source.ap end},
  },

  ["Zyra"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 95, 130, 165, 200})[level] + 0.6 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 105, 150, 195, 240})[level] + 0.5 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({180, 265, 350})[level] + 0.7 * source.ap end},
  },

}

-- Calc Local Functions --
local SetSpecialAADamageTable = function(args)
  local s = SpecialAADamageTable[args.source.charName]
  if s then
    s(args)
  end
end

local SetHeroPassiveDamageTable = function(args)
  local s = HeroPassiveDamageTable[args.source.charName]
  if s then
    s(args)
  end
end

local SetItemDamageTable = function(id, args)
  local s = ItemDamageTable[id]
  if s then
    s(args)
  end
end

local GetCriticalStrikePercent = function(source)
  local baseCriticalDamage = 1.75
  local percentMod = 1
  local fixedMod = 0
  if Item:HasItem(source, ItemID.InfinityEdge) and source.critChance >= 0.60 then --Infinity Edge
    baseCriticalDamage = baseCriticalDamage + 0.35 or 2.10
  end
  if source.charName == "Akshan" then --TODO: additional shot after AA
    percentMod = 0.70
  elseif source.charName == "Ashe" then
    baseCriticalDamage = 1
  elseif source.charName == "Fiora" then
    baseCriticalDamage = ({1.60, 1.70, 1.80, 1.90, 2.00})[source:GetSpellData(_W).level]
  elseif source.charName == "Jhin" then
    percentMod = 0.86
  elseif source.charName == "Kalista" then
    percentMod = 0.90
  elseif source.charName == "Yasuo" then
    percentMod = 0.90
  elseif source.charName == "Yone" then
    percentMod = 0.90
  end
  local modCrit =  baseCriticalDamage + (((Item:HasItem(source, ItemID.InfinityEdge)) and (source.critChance >= 0.60) and 0.35) or 0) --TODO:
  return baseCriticalDamage * percentMod
end

local PassivePercentMod = function(source, target, DamageType, amount)
  local targetIsHero = target.type == Obj_AI_Hero;
  local sourceIsHero = source.type == Obj_AI_Hero;
  if sourceIsHero then
    if Buff:HasBuffContainsName(source, "SRX_DragonSoulBuffChemtech") and GetPercentHP(source) < 50 then
      amount = amount * (1 + 0.10)
    end
    if targetIsHero then
      if (GetItemSlot(source, ItemID.LordDominiksRegards) > 0) and source.maxHealth < target.maxHealth and DamageType == 1 then -- Lord Dominik's Regards
        amount = amount * (1 + 0.0075 * (math_min(2000, target.maxHealth - source.maxHealth)/ 100)) --TODO: as bonusDamage
      end
    end
  end
  return amount
end

local DamageReductionMod = function(source, target, DamageType, amount)
  local targetIsHero = target.type == Obj_AI_Hero;
  local sourceIsHero = source.type == Obj_AI_Hero;
  if sourceIsHero then
    if GotBuff(source, "Exhaust") > 0 then
      amount = amount * (1 - 0.35)
    end
    if GotBuff(source, "itemsmitechallenger") > 0 then --removed
      amount = amount * (1 - 0.10)
    end
    if GotBuff(source, "barontarget") > 0 then
      amount = amount * (1 - 0.50)
    end
    --Dragon Buff/Debuff
    if Buff:HasBuffContainsName(target, "SRX_DragonSoulBuffChemtech") and GetPercentHP(target) < 50 then
      amount = amount * (1 - 0.10)
    end
    if Buff:HasBuffContainsName(target, "s5_dragonvengeance") then
      --[[ if target.charName == "SRU_Dragon_Chemtech" and GetPercentHP(target) < 50 then
        amount = amount * (1 - 0.33)
      end ]]
      local count = Buff:HasBuffContainsNameCount(source, "SRX_DragonBuff")
      amount = amount * (1 - (0.07*count))
    end
  end
  if targetIsHero then
    for i = 0, target.buffCount do
      if target:GetBuff(i).count > 0 then
        local buff = target:GetBuff(i)
        --[[ if buff.name == "MasteryWardenOfTheDawn" then --no longer in game
          amount = amount * (1 - (0.06 * buff.count))
        end ]]

        if DamageReductionBuffsTable[target.charName] then
          if buff.name == DamageReductionBuffsTable[target.charName].buff and (not DamageReductionBuffsTable[target.charName].DamageType or DamageReductionBuffsTable[target.charName].DamageType == DamageType) then
            amount = amount * DamageReductionBuffsTable[target.charName].amount(source, target, DamageType, amount)
          end
        end
      end
    end
    for i = 1, #ItemSlots do
      local slot = ItemSlots[i]
      local item = target:GetItemData(slot)
      if item ~= nil and item.itemID > 0 then
        if DamageReductionItemsTable[item.itemID] then
          if item.itemID == DamageReductionItemsTable[item.itemID] and (not DamageReductionItemsTable[item.itemID].DamageType or DamageReductionItemsTable[item.itemID].DamageType == DamageType) then
            amount = amount * DamageReductionItemsTable[item.itemID].amount(source, target, DamageType, amount)
          end
        end
      end
    end

    if target.charName == "Kassadin" and DamageType == 2 then
      amount = amount * (1 - 0.10)
    end
  end
  return amount
end

--[[ local DamageFlatReductionMod = function(source, target, DamageType, amount)
  local targetIsHero = target.type == Obj_AI_Hero;
  local sourceIsHero = source.type == Obj_AI_Hero;
  if sourceIsHero then
    --if buff then reduce flat
  end

  if targetIsHero then
    for i = 0, target.buffCount do --buff flat reduction table

      if target:GetBuff(i).count > 0 then
        local buff = target:GetBuff(i)

        if DamageFlatReductionBuffsTable[target.charName] then
          if buff.name == DamageFlatReductionBuffsTable[target.charName].buff and (not DamageFlatReductionBuffsTable[target.charName].DamageType or DamageFlatReductionBuffsTable[target.charName].DamageType == DamageType) then
            amount = amount * DamageFlatReductionBuffsTable[target.charName].amount(source, target, DamageType, amount)
          end
        end
      end
    end
    for i = 1, #ItemSlots do --item flat reduction table
      local slot = ItemSlots[i]
      local item = target:GetItemData(slot)

      if item ~= nil and item.itemID > 0 then
        if DamageFlatReductionItemsTable[item.itemID] then
          if item.itemID == DamageFlatReductionItemsTable[item.itemID] and (not DamageReductionItemsTable[item.itemID].DamageType or DamageFlatReductionItemsTable[item.itemID].DamageType == DamageType) then
            amount = amount * DamageFlatReductionItemsTable[item.itemID].amount(source, target, DamageType, amount)
          end
        end
      end
    end

    if target.charName == "Kassadin" and DamageType == 2 then
      amount = amount * (1 - 0.10)
    end
  end
  return amount
end ]]

local GetHeroAADamage = function(source, target, SpecialAA)
  local args = {
    source = source,
    Target = target,
    RawTotal = SpecialAA.RawTotal,
    RawPhysical = SpecialAA.RawPhysical,
    RawMagical = SpecialAA.RawMagical,
    CalculatedTrue = SpecialAA.CalculatedTrue,
    CalculatedPhysical = SpecialAA.CalculatedPhysical,
    CalculatedMagical = SpecialAA.CalculatedMagical,
    DamageType = SpecialAA.DamageType,
    TargetIsMinion = target.type == Obj_AI_Minion,
    SourceIsMinion = source.type == Obj_AI_Minion,
    TargetIsCamp = target.type == Obj_AI_Camp,
    SourceIsCamp = source.type == Obj_AI_Camp,
    TargetIsTurret = target.type == Obj_AI_Turret,
    SourceIsTurret = source.type == Obj_AI_Turret,
    TargetIsHero = target.type == Obj_AI_Hero,
    SourceIsHero = source.type == Obj_AI_Hero,
    CriticalStrike = false,
  }
  if args.TargetIsMinion and args.Target.maxHealth <= 6 then
    return 1
  end
  SetHeroPassiveDamageTable(args)
  if args.DamageType == DAMAGE_TYPE_PHYSICAL then
    args.RawPhysical = args.RawPhysical + args.RawTotal
  elseif args.DamageType == DAMAGE_TYPE_MAGICAL then
    args.RawMagical = args.RawMagical + args.RawTotal
  elseif args.DamageType == DAMAGE_TYPE_TRUE then
    args.CalculatedTrue = args.CalculatedTrue + args.RawTotal
  end
  if args.RawPhysical > 0 then
    args.CalculatedPhysical = args.CalculatedPhysical
      + CalcDamage(
        source,
        target,
        DAMAGE_TYPE_PHYSICAL,
        args.RawPhysical,
        true,
        args.DamageType == DAMAGE_TYPE_PHYSICAL
      )
  end
  if args.RawMagical > 0 then
    args.CalculatedMagical = args.CalculatedMagical
      + CalcDamage(
        source,
        target,
        DAMAGE_TYPE_MAGICAL,
        args.RawMagical,
        true,
        args.DamageType == DAMAGE_TYPE_MAGICAL
      )
  end
  -- Focus passive for Doran items and Tear of the Goddess
  if args.TargetIsMinion then
    if args.Target.maxHealth > 6 then
      if Item:HasItem(source, ItemID.DoransRing) or Item:HasItem(source, ItemID.DoransShield) or Item:HasItem(source, ItemID.TearoftheGoddess) then
        args.CalculatedPhysical = args.CalculatedPhysical + 5
      end
    end
    --Spoils of War passive for Support items
    --TODO: charges? if buff
    if Item:HasItem(source, ItemID.RelicShield) or Item:HasItem(source, ItemID.SteelShoulderguards) then --Relic Shieldor --Steel Shoulderguards
      if IsMelee(source) then
        if GetPercentHP(target) < 50 then
          args.CalculatedPhysical = target.health + 999
        end
      elseif GetPercentHP(target) < 30 then
        args.CalculatedPhysical = target.health + 999
      end
    elseif Item:HasItem(source, ItemID.TargonsBuckler) or Item:HasItem(source, ItemID.RunesteelSpaulders) then --Targon's Buckler --Runesteel Spaulders
      if GetPercentHP(target) < 50 then
        args.CalculatedPhysical = target.health + 999
      end
    end
  end
  local percentMod = 1
  if args.source.critChance - 1 == 0 or args.CriticalStrike then
    percentMod = percentMod * GetCriticalStrikePercent(args.source)
  end
  return percentMod * args.CalculatedPhysical + args.CalculatedMagical + args.CalculatedTrue
end

local GetSpecialAADamage= function(source, target, targetIsMinion)
  local args = {
    source = source,
    Target = target,
    RawTotal = source.totalDamage,
    RawPhysical = 0,
    RawMagical = 0,
    CalculatedTrue = 0,
    CalculatedPhysical = 0,
    CalculatedMagical = 0,
    DamageType = DAMAGE_TYPE_PHYSICAL,
    TargetIsMinion = targetIsMinion,
  }
  SetSpecialAADamageTable(args)
  local HashSet = {}
  for i = 1, #ItemSlots do
    local slot = ItemSlots[i]
    local item = args.source:GetItemData(slot)
    if item ~= nil and item.itemID > 0 then
      if HashSet[item.itemID] == nil then
        SetItemDamageTable(item.itemID, args)
        HashSet[item.itemID] = true
      end
    end
  end
  return args
end

-- Global Function --
GetAADamage = function(source, target, respectPassives)
  local targetIsMinion = target.type == Obj_AI_Minion;
  local sourceIsHero = source.type == Obj_AI_Hero;
  if respectPassives == nil then
    respectPassives = true
  end
  if source == nil or target == nil then
    return 0
  end
  if respectPassives and sourceIsHero then
    return GetHeroAADamage(source, target, GetSpecialAADamage(source, target,targetIsMinion))
  end
  if targetIsMinion then --wards?
    if target.maxHealth <= 6 then
      if Item:HasItem(source, ItemID.UmbralGlaive) then
        return 2
      end
      return 1
    end
  end
  return CalcDamage(source, target, DAMAGE_TYPE_PHYSICAL, source.totalDamage, true)
end

CalcDamage = function(source, target, DamageType, amount, IsAA)
  local targetIsMinion = target.type == Obj_AI_Minion;
  local sourceIsMinion = source.type == Obj_AI_Minion;
  local targetIsCamp = target.type == Obj_AI_Camp;
  local sourceIsCamp = source.type == Obj_AI_Camp;
  local targetIsTurret = target.type == Obj_AI_Turret;
  local sourceIsTurret = source.type == Obj_AI_Turret;
  local targetIsHero = target.type == Obj_AI_Hero;
  local sourceIsHero = source.type == Obj_AI_Hero;
  local baseResist = 0
  local bonusResist = 0
  local lethality = (0.6222 + 0.3778 / 17 * (source.levelData.lvl-1))
  local flatPen = 0
  local percentPen = 0
  local bonuspercentPen = 0

  if DamageType == 1 then
    baseResist = math_max(target.armor - target.bonusArmor, 0)
    bonusResist = target.bonusArmor
    flatPen = source.armorPen * lethality
    percentPen = source.armorPenPercent
    bonuspercentPen = source.bonusArmorPenPercent
    if sourceIsMinion or sourceIsCamp then
      flatPen = 0
      percentPen = 1
      bonuspercentPen = 0
    elseif sourceIsTurret then
      flatPen = 0
      percentPen = 0.7
      bonuspercentPen = 0
      if targetIsMinion then
        local percentHP = nil
        if table_contains(SiegeMinionList, target.charName) then
          if GetTurretType(source.name, "Base") then local percentHP = TurretToMinionPercent[SiegeMinionList].Base
          elseif GetTurretType(source.name, "Inner") then local percentHP = TurretToMinionPercent[SiegeMinionList].Inner
          elseif GetTurretType(source.name, "Outer") then local percentHP = TurretToMinionPercent[SiegeMinionList].Outer
          end
        elseif table_contains(RangedMinionList, target.charName) then local percentHP = TurretToMinionPercent[RangedMinionList]
        elseif table_contains(MeleeMinionList, target.charName) then local percentHP = TurretToMinionPercent[MeleeMinionList]
        end
        if percentHP ~= nil then
          return target.maxHealth * percentHP
        end
      end
    end
  elseif DamageType == 2 then
    baseResist = math_max(target.magicResist - target.bonusMagicResist, 0)
    bonusResist = target.bonusMagicResist
    flatPen = source.magicPen
    percentPen = source.magicPenPercent
    bonuspercentPen = 0
  elseif DamageType == 3 then
    return amount
  end

  local resist = baseResist + bonusResist
  if resist > 0 then
    if percentPen > 0 then
      baseResist = baseResist * percentPen
      bonusResist = bonusResist * percentPen
    end
    if bonuspercentPen > 0 then
      bonusResist = bonusResist * bonuspercentPen
    end
    resist = baseResist + bonusResist
    resist = resist - flatPen
  end

	local postMitigation = 1
	if resist >= 0 then
		postMitigation = postMitigation * (100 / (100 + resist))
	else
		postMitigation = postMitigation * (2 - 100 / (100 - resist))
	end

  local flatPassive = 0
  if targetIsHero then --TODO: Move to own function/table
    if target.charName == "Fizz" then
      flatPassive = flatPassive - (4 + 0.01 * source.ap) --TODO 50% max reduction
    elseif target.charName == "Leona" and GetBuffData(target, "LeonaSolarBarrier") then
      flatPassive = flatPassive - (({8, 12, 16, 20, 24})[target:GetSpellData(_W).level or 1])
    elseif target.charName == "Amumu" and GetBuffData(target, "Tantrum") then
      flatPassive = flatPassive - (({5, 7, 9, 11, 13})[target:GetSpellData(_E).level or 1] + (0.03 * target.bonusMagicResist) + (0.03 * target.bonusArmor)) --TODO: max 50%
    end
    if GetItemSlot(target, ItemID.GuardiansHorn) > 0 then --Guardian's Horn
      flatPassive = flatPassive - 15
    end
  end
  local bonusPercent = 1
  if sourceIsMinion and targetIsMinion then
    bonusPercent = bonusPercent * (1 + source.bonusDamagePercent)
  end
  local flatreduction = 0
  if targetIsMinion then
    flatreduction = flatreduction - target.flatDamageReduction
  end

  -- 100 / (100 + (Armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - Lethality)
  --return math_max(0, math_floor(DamageReductionMod(source, target, PassivePercentMod(source, target, postMitigation) * amount, 1)))
  --local value = math_max(bonusPercent * DamageReductionMod(source, target, postMitigation, DamageType) * (amount + flatPassive) + flatreduction, 0)
  return math_max(math_floor(bonusPercent * DamageReductionMod(source, target, DamageType, PassivePercentMod(source, target, DamageType, postMitigation) * (amount + flatPassive)) + flatreduction), 0)
end

getdmg = function(spell, target, source, stage, level)
  local source = source or myHero
  local stage = stage or 1
  local targetIsMinion = target.type == Obj_AI_Minion;
  local sourceIsMinion = source.type == Obj_AI_Minion;
  local targetIsCamp = target.type == Obj_AI_Camp;
  local sourceIsCamp = source.type == Obj_AI_Camp;
  local targetIsTurret = target.type == Obj_AI_Turret;
  local sourceIsTurret = source.type == Obj_AI_Turret;
  local targetIsHero = target.type == Obj_AI_Hero;
  local sourceIsHero = source.type == Obj_AI_Hero;
  local Ignite = (source:GetSpellData(SUMMONER_1).name:lower():find("summonerdot") and SUMMONER_1 or (source:GetSpellData(SUMMONER_2).name:lower():find("summonerdot") and SUMMONER_2 or nil))
  local Smite = (source:GetSpellData(SUMMONER_1).name:lower():find("smite") and SUMMONER_1 or (source:GetSpellData(SUMMONER_2).name:lower():find("smite") and SUMMONER_2 or nil))
  local SmiteUnleashed = (source:GetSpellData(SUMMONER_1).name:lower():find("ganker") and SUMMONER_1 or (source:GetSpellData(SUMMONER_2).name:lower():find("ganker") and SUMMONER_2 or nil))
  local SmiteDuel = (source:GetSpellData(SUMMONER_1).name:lower():find("duel") and SUMMONER_1 or (source:GetSpellData(SUMMONER_2).name:lower():find("duel") and SUMMONER_2 or nil))
  local SmiteAvatar = (source:GetSpellData(SUMMONER_1).name:lower():find("avatar") and SUMMONER_1 or (source:GetSpellData(SUMMONER_2).name:lower():find("avatar") and SUMMONER_2 or nil))

  local Mark = (source:GetSpellData(SUMMONER_1).name:lower():find("mark") and SUMMONER_1 or (source:GetSpellData(SUMMONER_2).name:lower():find("mark") and SUMMONER_2 or nil))
  local Dash = (source:GetSpellData(SUMMONER_1).name:lower():find("Dash") and SUMMONER_1 or (source:GetSpellData(SUMMONER_2).name:lower():find("Dash") and SUMMONER_2 or nil))

  local dmgtable = {}
  if spell == "Q" or spell == "W" or spell == "E" or spell == "R" or spell == "QM" or spell == "WM" or spell == "EM" and sourceIsHero then
    local level = level or source:GetSpellData(({["Q"] = _Q, ["QM"] = _Q, ["W"] = _W, ["WM"] = _W, ["E"] = _E, ["EM"] = _E, ["R"] = _R})[spell]).level
    if level <= 0 then return 0 end
    if level > 6 then level = 6 end
    if SpellDamageTable[source.charName] then
      for i, spells in pairs(SpellDamageTable[source.charName]) do
        if spells.Slot == spell then
          table_insert(dmgtable, spells)
        end
      end
      if stage > #dmgtable then stage = #dmgtable end
      for v = #dmgtable, 1, -1 do
        local spells = dmgtable[v]
        if spells.Stage == stage then
          return CalcDamage(source, target, spells.DamageType, spells.Damage(source, target, level), false)
        end
      end
    end
  end
  if spell == "AA" then
    local SpecialAADamage = GetSpecialAADamage(source, targetIsMinion) --and targetIsMinion --target.type == Obj_AI_Minion
    --return GetAADamage(source, target, SpecialAADamage)
    return GetAADamage(source, target, SpecialAADamage)--(source, target)
  end
  if spell == "IGNITE" then
    local IgniteDamage = ((50+20*source.levelData.lvl) - (target.hpRegen*3))
    return IgniteDamage
  end
  if spell == "MARK" or spell == "DASH" then
    local MarkandDashDamage = 10+5*source.levelData.lvl
    return MarkandDashDamage
  end
  if spell == "SMITE" then
    local SmiteDamage = 600
    local SmiteUnleashedDamage = 900
    local SmitePrimalDamage = 1200
    local SmiteAdvDamageHero = 80 + 80 / 17 * (source.levelData.lvl - 1)
    if not targetIsHero then
      if source:GetSpellData(Smite).name == "SummonerSmite" then
        return SmiteDamage
      elseif source:GetSpellData(SmiteUnleashed).name == "S5_SummonerSmitePlayerGanker" or source:GetSpellData(SmiteDuel).name == "S5_SummonerSmiteDuel" then
        return SmiteUnleashedDamage
      elseif source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarOffensive" or source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarUtility"  or source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarDefensive" then
        return SmitePrimalDamage
      end
    elseif targetIsHero then
      if source:GetSpellData(SmiteUnleashed).name == "S5_SummonerSmitePlayerGanker" or source:GetSpellData(SmiteDuel).name == "S5_SummonerSmiteDuel" then
        return SmiteAdvDamageHero
      elseif source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarOffensive" or source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarUtility"  or source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarDefensive" then
        return SmiteAdvDamageHero
      end
    else
      return 0
    end
  end
  if spell == "HEXTECH" then
    return CalcDamage(source, target, 2, 125+(0.15*source.ap))
    --Dash 125-275 range, damage in arc cone of dashdirection with 7 rockets
  end
  if spell == "EVERFROST" then
    return CalcDamage(source, target, 2, 100+(0.3*source.ap))
    --~850 range 28deg cone, slows, center of cone roots
  end
  if spell == "GALEFORCE" then
    return CalcDamage(source, target, 2, (({60, 60, 60, 60, 60, 60, 60, 60, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105})[source.levelData.lvl] + (0.15 * source.bonusDamage)) * 1+math_min(0.5,0.05*math_floor(GetPercentMissingHP(target)/ 7,7)) * 3)
    --750 range radius to most wounded enemy + 3 arrows and missing hp dmg
  end
  if spell == "IRONSPIKE" then
    return CalcDamage(source, target, 1, source.totalDamage)
    --450 AOE radius centered around source
  end
  if spell == "GOREDRINKER" then
    return CalcDamage(source, target, 1, 1.75*source.totalDamage)
    --450 AOE radius centered around source + heal
  end
  if spell == "STRIDEBREAKER" then
    return CalcDamage(source, target, 1, 1.75*source.totalDamage)
    --450 AOE radius centered around source + slow
  end
  if spell == "PROWLER" then
    return CalcDamage(source, target, 1, 75+0.30*source.bonusDamage)
    --500 range + increase your damage dealt by 15%
  end
  return 0
end

-- Callbacks --
Callback.Add("Load", function()
--
  Callback.Add("Tick", function()
    Cached:Reset()
    Item:OnTick()
  end)
end)


_G.DamageLib = {
  ItemID = ItemID,
  MeleeHeros = Hero[1],
  --monsterType = Monstertable,
}
function DamageLib:IsMelee(unit)
  return IsMelee(unit) --returns bool
end

local version = 14.97
-- local scriptPath = debug.getinfo(1, "S").source:sub(2)
-- local fileName = scriptPath:match("[\\/]([^\\/]-)$")
-- local SCRIPT_NAME = fileName:gsub("%.lua$", "")
local SCRIPT_NAME = "DamageLib"
local DamageLib = {}

--[[
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
ItemID table implmentation, global? / multiple ID's or name query
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
      Hellfire Hatchet -
        UNIQUE PASSIVE - CHAR: Basic attacks on-hit and ability hits against enemies Heal power icon heal you for 2% of target's current health and apply a burn that deals 2% of target's missing health (+ 12% bonus AD) (+ 10% AP) physical damage every second over 4 seconds.
      Perplexity -
        UNIQUE PASSIVE - GIANT SLAYER: Deal 0% − 22% (based on maximum health difference) bonus damage against enemy champions with greater maximum health than you.
      -- if heal/shielding implimented {
        Sword of the Blossoming Dawn -
          UNIQUE PASSIVE - EFFERVESCENCE: Gain 1.2% bonus attack speed per 1% heal and shield power.
          UNIQUE PASSIVE - PEPPERMINT: Basic attacks on-hit cause the most wounded and nearest allied champion to be Heal power icon healed for 15 − 45 (based on level) (+ 10% bonus AD) (+ 7% AP).
      }
      Wooglet's Witchcap -
        "Zhonya's" UNIQUE ACTIVE - STASIS: Put yourself in Stasis icon stasis for 2.5 seconds, rendering you Untargetable icon untargetable and Cosmic Radiance invulnerable for the duration but also unable to move, declare basic attacks, cast abilities, use summoner spells, or activate items.




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

BATTLE OF SPIRIT AND SHADOW - Shen SHEN VS. Zed ZED
  QUEST CONDITIONS: Both champions have to be on opposing teams and at least level 11.
  QUEST REWARDS: Zed Zed must kill two of Shen's Shen's nearby allies in order to prevail.
  Shen Shen wins by scoring a takedown against Zed Zed before he is able to kill two of his allied champions. The shield strength of his Ki Barrier Ki Barrier is increased by 30%.
  Zed Zed wins by killing two of Shen's Shen's nearby allied champions before being taken down by him. The damage dealt by his Contempt for the Weak Contempt for the Weak is increased by an additional 2% of the target's maximum health.

Triple Tonic - New rune
  Replaces Perfect Timing Perfect Timing.
  Inspiration icon Inspiration Slot 1 rune.
  PASSIVE: Gain an Elixir upon reaching each of the following levels:
  Level 3: Elixir of Avarice Elixir of Avarice
  Level 6: Elixir of Force Elixir of Force
  Level 9: Elixir of Skill Elixir of Skill

Rift Herald Rift Herald
  Model has been visually updated.
  Updated unit icon.
  Spawn time increased to 14:00 from 8:00.
  Structure damage reduced to 1500 − 2250 (based on level) from 2000 − 2750 (based on level).
  REMOVED: No longer has a respawn time of 6 minutes.
  NEW EFFECT - HERALD'S GAZE: Now takes 50% reduced damage from the last enemy that it attacked for 8 seconds, refreshing with each attack. This may only affect one enemy at a time.

  Profane Hydra
  Stormsurge
  Stridebreaker
  Hextech Rocketbelt
]]

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

local DAMAGE_TYPE_PHYSICAL = DAMAGE_TYPE_PHYSICAL or 1
local DAMAGE_TYPE_MAGICAL = DAMAGE_TYPE_MAGICAL or 2
local DAMAGE_TYPE_TRUE = DAMAGE_TYPE_TRUE or 3

local myHero = myHero
local Game, Draw, Callback = _G.Game, _G.Draw, _G.Callback
local io = io
local math = math
local table = table
local pairs = pairs
local ipairs = ipairs

local ItemSlots = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }
local ItemKeys = { HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4, HK_ITEM_5, HK_ITEM_6, HK_ITEM_7 }

-- SDK
-- local Item, Buff, Target, Orbwalker, Damage, Spell, Object, Attack, Data, Cursor, IsRecalling
local Item = _G.SDK.ItemManager
local Buff = _G.SDK.BuffManager

local Target = _G.SDK.TargetSelector
local Orbwalker = _G.SDK.Orbwalker
local Damage = _G.SDK.Damage
local Spell = _G.SDK.Spell
local Object = _G.SDK.ObjectManager
local Attack = _G.SDK.Attack
local Data = _G.SDK.Data
local Cursor = _G.SDK.Cursor
local IsRecalling = _G.SDK.IsRecalling

-- [[ Tables ]] --
local buffType = {
  CCImmune = 0,
  Dodge = 0,
  Stun = 5,
  Silence = 7,
  Taunt = 8,
  Poly = 10,
  Slow = 11,
  Root = 12,
  Invulnerable = 18,
  Nearsighted = 20,
  Fear = 22,
  Charm = 23,
  Supression = 25,
  Blind = 26,
  Flee = 29,
  Knockup = 30,
  Knockback = 31,
  Disarm = 32,
  Grounded = 33,
  Drowsy = 34,
  Asleep = 35,
}

local meleeMinionList = { "SRU_ChaosMinionMelee", "SRU_OrderMinionMelee",
  "HA_ChaosMinionMelee", "HA_OrderMinionMelee", }
local rangedMinionList = { "SRU_ChaosMinionRanged", "SRU_OrderMinionRanged",
  "HA_ChaosMinionRanged", "HA_OrderMinionRanged", }
local siegeMinionList = { "SRU_ChaosMinionSiege", "SRU_OrderMinionSiege",
  "HA_ChaosMinionSiege", "HA_OrderMinionSiege", }
local superMinionList = { "SRU_ChaosMinionSuper", "SRU_OrderMinionSuper",
  "HA_ChaosMinionSuper", "HA_OrderMinionSuper", }
local allMinionList = { "SRU_ChaosMinionRanged", "SRU_OrderMinionRanged", "SRU_ChoasMinionMelee", "SRU_OrderMinionMelee",
  "HA_ChaosMinionMelee", "HA_OrderMinionMelee", "HA_ChaosMinionRanged", "HA_OrderMinionRanged", }
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
local TurretsInfo = {
  --blue
  ["Turret_T1_C_01_A"] = { turrettype = "Base" },  --top nexus
  ["Turret_T1_C_02_A"] = { turrettype = "Base" },  --bot nexus
  ["Turret_T1_C_06_A"] = { turrettype = "Base" },  --top inhib
  ["Turret_T1_C_03_A"] = { turrettype = "Base" },  --mid inhib
  ["Turret_T1_C_07_A"] = { turrettype = "Base" },  --botlane inhib
  ["Turret_T2_C_01_A"] = { turrettype = "Base" },  --bot nexus
  ["Turret_T2_C_02_A"] = { turrettype = "Base" },  --top nexus
  ["Turret_T2_L_01_A"] = { turrettype = "Base" },  --top inhib
  ["Turret_T2_C_03_A"] = { turrettype = "Base" },  --mid inhib
  ["Turret_T2_R_01_A"] = { turrettype = "Base" },  --botlane inhib

  ["Turret_T1_L_02_A"] = { turrettype = "Inner" }, --top inner
  ["Turret_T1_C_04_A"] = { turrettype = "Inner" }, --mid inner
  ["Turret_T1_R_02_A"] = { turrettype = "Inner" }, --botlane inner
  ["Turret_T2_L_02_A"] = { turrettype = "Inner" }, --top inner
  ["Turret_T2_C_04_A"] = { turrettype = "Inner" }, --mid inner
  ["Turret_T2_R_02_A"] = { turrettype = "Inner" }, --botlane inner

  ["Turret_T1_L_03_A"] = { turrettype = "Outer" }, --top outer
  ["Turret_T1_C_05_A"] = { turrettype = "Outer" }, --mid outer
  ["Turret_T1_R_03_A"] = { turrettype = "Outer" }, --botlane outer
  ["Turret_T2_L_03_A"] = { turrettype = "Outer" }, --top outer
  ["Turret_T2_C_05_A"] = { turrettype = "Outer" }, --mid outer
  ["Turret_T2_R_03_A"] = { turrettype = "Outer" }, --botlane outer
}
local HATurretsInfo = {
  --HA
  ["Turret_T1_C_010_A"] = { turrettype = "Base" }, --top nexus
  ["Turret_T1_C_09_A"] = { turrettype = "Base" },  --bot nexus
  ["Turret_T1_C_07_A"] = { turrettype = "Base" },  --inhib

  ["Turret_T2_L_02_A"] = { turrettype = "Base" },  --inhib
  ["Turret_T2_L_03_A"] = { turrettype = "Base" },  --bot nexus
  ["Turret_T2_L_04_A"] = { turrettype = "Base" },  --top nexus

  ["Turret_T1_C_08_A"] = { turrettype = "Outer" }, --outer
  ["Turret_T2_L_01_A"] = { turrettype = "Outer" }, --outer
}
local TurretToMinionPercent = {
  [meleeMinionList] = 0.45,
  [rangedMinionList] = 0.70,
  [siegeMinionList] = { Base = 0.08, Inner = 0.11, Outer = 0.14 },
  [superMinionList] = 0.07,
}

local HEROES = {
  Aatrox = { 3, true, 0.651 },
  Ahri = { 4, false, 0.668 },
  Akali = { 4, true, 0.625 },
  Akshan = { 5, false, 0.638 },
  Alistar = { 1, true, 0.625 },
  Amumu = { 1, true, 0.736 },
  Anivia = { 4, false, 0.625 },
  Annie = { 4, false, 0.61 },
  Aphelios = { 5, false, 0.64 },
  Ashe = { 5, false, 0.658 },
  AurelionSol = { 4, false, 0.625 },
  Azir = { 4, true, 0.625 },
  Bard = { 3, false, 0.625 },
  Belveth = { 4, true, 0.85 },
  Blitzcrank = { 1, true, 0.625 },
  Brand = { 4, false, 0.625 },
  Braum = { 1, true, 0.644 },
  Briar = { 4, true, 0.664 },
  Caitlyn = { 5, false, 0.681 },
  Camille = { 3, true, 0.644 },
  Cassiopeia = { 4, false, 0.647 },
  Chogath = { 1, true, 0.625 },
  Corki = { 5, false, 0.638 },
  Darius = { 2, true, 0.625 },
  Diana = { 4, true, 0.625 },
  DrMundo = { 1, true, 0.67 },
  Draven = { 5, false, 0.679 },
  Ekko = { 4, true, 0.688 },
  Elise = { 3, false, 0.625 },
  Evelynn = { 4, true, 0.667 },
  Ezreal = { 5, false, 0.625 },
  FiddleSticks = { 3, false, 0.625 },
  Fiora = { 3, true, 0.69 },
  Fizz = { 4, true, 0.658 },
  Galio = { 1, true, 0.625 },
  Gangplank = { 4, true, 0.658 },
  Garen = { 1, true, 0.625 },
  Gnar = { 1, false, 0.625 },
  Gragas = { 2, true, 0.675 },
  Graves = { 4, false, 0.475 },
  Gwen = { 4, true, 0.69 },
  Hecarim = { 2, true, 0.67 },
  Heimerdinger = { 3, false, 0.625 },
  Hwei = { 4, false, 0.69 },
  Illaoi = { 3, true, 0.625 },
  Irelia = { 3, true, 0.656 },
  Ivern = { 1, true, 0.644 },
  Janna = { 2, false, 0.625 },
  JarvanIV = { 3, true, 0.658 },
  Jax = { 3, true, 0.638 },
  Jayce = { 4, false, 0.658 },
  Jhin = { 5, false, 0.625 },
  Jinx = { 5, false, 0.625 },
  KSante = { 1, true, 0.625 },
  Kaisa = { 5, false, 0.644 },
  Kalista = { 5, false, 0.694 },
  Karma = { 4, false, 0.625 },
  Karthus = { 4, false, 0.625 },
  Kassadin = { 4, true, 0.64 },
  Katarina = { 4, true, 0.658 },
  Kayle = { 4, false, 0.625 },
  Kayn = { 4, true, 0.669 },
  Kennen = { 4, false, 0.625 },
  Khazix = { 4, true, 0.668 },
  Kindred = { 4, false, 0.625 },
  Kled = { 2, true, 0.625 },
  KogMaw = { 5, false, 0.665 },
  Leblanc = { 4, false, 0.658 },
  LeeSin = { 3, true, 0.651 },
  Leona = { 1, true, 0.625 },
  Lillia = { 4, false, 0.625 },
  Lissandra = { 4, false, 0.656 },
  Lucian = { 5, false, 0.638 },
  Lulu = { 3, false, 0.625 },
  Lux = { 4, false, 0.669 },
  Malphite = { 1, true, 0.736 },
  Malzahar = { 3, false, 0.625 },
  Maokai = { 2, true, 0.8 },
  MasterYi = { 5, true, 0.679 },
  Milio = { 3, false, 0.625 },
  MissFortune = { 5, false, 0.656 },
  MonkeyKing = { 3, true, 0.69 },
  Mordekaiser = { 4, true, 0.625 },
  Morgana = { 3, false, 0.625 },
  Naafiri = { 4, true, 0.663 },
  Nami = { 3, false, 0.644 },
  Nasus = { 2, true, 0.638 },
  Nautilus = { 1, true, 0.706 },
  Neeko = { 4, false, 0.625 },
  Nidalee = { 4, false, 0.638 },
  Nilah = { 5, true, 0.697 },
  Nocturne = { 4, true, 0.721 },
  Nunu = { 2, true, 0.625 },
  Olaf = { 2, true, 0.694 },
  Orianna = { 4, false, 0.658 },
  Ornn = { 2, true, 0.625 },
  Pantheon = { 3, true, 0.658 },
  Poppy = { 2, true, 0.625 },
  Pyke = { 4, true, 0.667 },
  Qiyana = { 4, true, 0.688 },
  Quinn = { 5, false, 0.668 },
  Rakan = { 3, true, 0.635 },
  Rammus = { 1, true, 0.656 },
  RekSai = { 2, true, 0.667 },
  Rell = { 1, true, 0.625 },
  Renata = { 2, false, 0.625 },
  Renekton = { 2, true, 0.665 },
  Rengar = { 4, true, 0.667 },
  Riven = { 4, true, 0.625 },
  Rumble = { 4, true, 0.644 },
  Ryze = { 4, false, 0.658 },
  Samira = { 5, false, 0.658 },
  Sejuani = { 2, true, 0.688 },
  Senna = { 5, false, 0.625 },
  Seraphine = { 3, false, 0.669 },
  Sett = { 2, true, 0.625 },
  Shaco = { 4, true, 0.694 },
  Shen = { 1, true, 0.751 },
  Shyvana = { 2, true, 0.658 },
  Singed = { 1, true, 0.625 },
  Sion = { 1, true, 0.679 },
  Sivir = { 5, false, 0.625 },
  Skarner = { 2, true, 0.625 },
  Smolder = { 5, false, 0.638 },
  Sona = { 3, false, 0.644 },
  Soraka = { 3, false, 0.625 },
  Swain = { 3, false, 0.625 },
  Sylas = { 4, true, 0.645 },
  Syndra = { 4, false, 0.625 },
  TahmKench = { 1, true, 0.658 },
  Taliyah = { 4, false, 0.625 },
  Talon = { 4, true, 0.625 },
  Taric = { 1, true, 0.625 },
  Teemo = { 4, false, 0.69 },
  Thresh = { 1, true, 0.625 },
  Tristana = { 5, false, 0.656 },
  Trundle = { 2, true, 0.67 },
  Tryndamere = { 4, true, 0.67 },
  TwistedFate = { 4, false, 0.651 },
  Twitch = { 5, false, 0.679 },
  Udyr = { 2, true, 0.65 },
  Urgot = { 2, true, 0.625 },
  Varus = { 5, false, 0.658 },
  Vayne = { 5, false, 0.658 },
  Veigar = { 4, false, 0.625 },
  Velkoz = { 4, false, 0.643 },
  Vex = { 4, false, 0.669 },
  Vi = { 2, true, 0.644 },
  Viego = { 4, true, 0.658 },
  Viktor = { 4, false, 0.658 },
  Vladimir = { 3, false, 0.658 },
  Volibear = { 2, true, 0.625 },
  Warwick = { 2, true, 0.638 },
  Xayah = { 5, false, 0.658 },
  Xerath = { 4, false, 0.658 },
  XinZhao = { 3, true, 0.645 },
  Yasuo = { 4, true, 0.697 },
  Yone = { 4, true, 0.625 },
  Yorick = { 2, true, 0.625 },
  Yuumi = { 3, false, 0.625 },
  Zac = { 1, true, 0.736 },
  Zed = { 4, true, 0.651 },
  Zeri = { 5, false, 0.658 },
  Ziggs = { 4, false, 0.656 },
  Zilean = { 3, false, 0.658 },
  Zoe = { 4, false, 0.658 },
  Zyra = { 2, false, 0.681 },
}

local ARAM = {
  ["Aatrox"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Akali"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Akshan"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Alistar"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Anivia"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Annie"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Aphelios"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Ashe"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["AurelionSol"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Azir"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Bard"] = {
    dmgDealt = 1.15,
    dmgReceived = 0.85,
    other = nil,
  },
  ["BelVeth"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Brand"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Briar"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Caitlyn"] = {
    dmgDealt = nil,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Camille"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["ChoGath"] = {
    dmgDealt = nil,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Corki"] = {
    dmgDealt = nil,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Darius"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Diana"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["DrMundo"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Draven"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Ekko"] = {
    dmgDealt = 1.10,
    dmgReceived = nil,
    other = nil,
  },
  ["Elise"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Evelynn"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Ezreal"] = {
    dmgDealt = 0.95,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Fiddlesticks"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Fiora"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Fizz"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Galio"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Gangplank"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Garen"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Gnar"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Gragas"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Gwen"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Hecarim"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Heimerdinger"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Hwei"] = {
    dmgDealt = 1.00,
    dmgReceived = 1.00,
    other = nil,
  },
  ["Illaoi"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Irelia"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Ivern"] = {
    dmgDealt = 0.90,
    dmgReceived = nil,
    other = nil,
  },
  ["Janna"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["JarvanIV"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Jax"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.97,
    other = nil,
  },
  ["Jhin"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Jinx"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },
  ["KSante"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["KaiSa"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Kalista"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Karma"] = {
    dmgDealt = 0.95,
    dmgReceived = nil,
    other = nil,
  },
  ["Karthus"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Kassadin"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Katarina"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Kayle"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Kayn"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Kennen"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["KhaZix"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Kindred"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Kled"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["KogMaw"] = {
    dmgDealt = 0.88,
    dmgReceived = 1.10,
    other = nil,
  },
  ["LeBlanc"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.90,
    other = nil,
  },
  ["LeeSin"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Leona"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.00,
    other = nil,
  },
  ["Lillia"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Lissandra"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Lucian"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Lulu"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Lux"] = {
    dmgDealt = 0.85,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Malzahar"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Maokai"] = {
    dmgDealt = 0.80,
    dmgReceived = 1.10,
    other = nil,
  },
  ["MasterYi"] = {
    dmgDealt = nil,
    dmgReceived = 0.97,
    other = nil,
  },
  ["Milio"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["MissFortune"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.15,
    other = nil,
  },
  ["Mordekaiser"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Morgana"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Naafiri"] = {
    dmgDealt = nil,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Nami"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Nasus"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Nautilus"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Nidalee"] = {
    dmgDealt = 1.10,
    dmgReceived = nil,
    other = nil,
  },
  ["Nilah"] = {
    dmgDealt = 0.95,
    dmgReceived = nil,
    other = nil,
  },
  ["Nocturne"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.85,
    other = nil,
  },
  ["Nunu"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Ornn"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Pantheon"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Pyke"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Qiyana"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Quinn"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.90,
    other = nil,
  },
  ["RekSai"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Rell"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.00,
    other = nil,
  },
  ["Renata"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Renekton"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Rengar"] = {
    dmgDealt = nil,
    dmgReceived = 0.92,
    other = nil,
  },
  ["Riven"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.92,
    other = nil,
  },
  ["Rumble"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Ryze"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Samira"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Sejuani"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.92,
    other = nil,
  },
  ["Senna"] = {
    dmgDealt = 0.94,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Seraphine"] = {
    dmgDealt = 0.85,
    dmgReceived = 1.20,
    other = nil,
  },
  ["Sett"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Shaco"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Shen"] = {
    dmgDealt = nil,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Shyvana"] = {
    dmgDealt = 0.95,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Singed"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Sion"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Sivir"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.08,
    other = nil,
  },
  ["Skarner"] = {
    dmgDealt = 1.00,
    dmgReceived = 1.00,
    other = nil,
  },
  ["Smolder"] = {
    dmgDealt = 1.00,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Sona"] = {
    dmgDealt = 1.00,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Swain"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.15,
    other = nil,
  },
  ["Sylas"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Syndra"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["TahmKench"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Taliyah"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Talon"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Taric"] = {
    dmgDealt = 1.00,
    dmgReceived = 1.10,
    other = nil,
  },
  ["Teemo"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.20,
    other = nil,
  },
  ["Thresh"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Tristana"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Trundle"] = {
    dmgDealt = nil,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Tryndamere"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Twitch"] = {
    dmgDealt = nil,
    dmgReceived = 0.95,
    other = nil,
  },
  ["TwistedFate"] = {
    dmgDealt = 0.95,
    dmgReceived = nil,
    other = nil,
  },
  ["Udyr"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Urgot"] = {
    dmgDealt = 1.00,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Varus"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Vayne"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Veigar"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.10,
    other = nil,
  },
  ["VelKoz"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Vex"] = {
    dmgDealt = 0.95,
    dmgReceived = nil,
    other = nil,
  },
  ["Vi"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Viego"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Viktor"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.05,
    other = nil,
  },
  ["Vladimir"] = {
    dmgDealt = 0.95,
    dmgReceived = nil,
    other = nil,
  },
  ["Warwick"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Xayah"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Xerath"] = {
    dmgDealt = 0.95,
    dmgReceived = 1.00,
    other = nil,
  },
  ["XinZhao"] = {
    dmgDealt = 0.95,
    dmgReceived = nil,
    other = nil,
  },
  ["Yone"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.97,
    other = nil,
  },
  ["Yorick"] = {
    dmgDealt = nil,
    dmgReceived = nil,
    other = nil,
  },
  ["Yuumi"] = {
    dmgDealt = 1.05,
    dmgReceived = nil,
    other = nil,
  },
  ["Zac"] = {
    dmgDealt = nil,
    dmgReceived = 0.96,
    other = nil,
  },
  ["Zed"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Zeri"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.90,
    other = nil,
  },
  ["Ziggs"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.20,
    other = nil,
  },
  ["Zilean"] = {
    dmgDealt = 1.05,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Zoe"] = {
    dmgDealt = 1.10,
    dmgReceived = 0.95,
    other = nil,
  },
  ["Zyra"] = {
    dmgDealt = 0.90,
    dmgReceived = 1.05,
    other = nil,
  },

  --[[ ITEMS
Hubris Hubris
  Eminence base bonus attack damage reduced to 10 from 15.
  Eminence bonus attack damage per statue rank reduced to 1 from 2.
  Eminence duration reduced to 45 seconds from 90.

Malignance
  Hatefog base damage per tick reduced to 10 from 15.
  Hatefog AP ratio per tick reduced to 0.7% AP from 1.5% AP.

Sundered Sky
  Lightshield Strike heal AD ratio reduced to 120% base AD from 140%.
  Lightshield Strike heal health ratio reduced to 4% of missing health from 6%.

Stormsurge
  Squall base damage reduced to (Melee role 100 / Ranged role 75) at all levels from (Melee role 100 − 200 / Ranged role 75 − 150) (based on level).
  Squall AP ratio reduced to (Melee role 15% / Ranged role 11.25%) AP from (Melee role 20% / Ranged role 15%) AP.
]]
}

local URF = {
  -- rotator
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

local ItemID = { --14.2.1 update
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
  Emberknife = 1035,
  LongSword = 1036,
  Pickaxe = 1037,
  BFSword = 1038,
  Hailblade = 1039,
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
  EyeoftheHerald = 1104,
  PenetratingBullets = 1500,
  Fortification = 1501,
  ReinforcedArmor = 1502,
  WardensEye = 1503,
  Vanguard = 1504,
  ReinforcedArmor = 1506,
  Overcharged = 1507,
  AntitowerSocks = 1508,
  Gusto = 1509,
  PhreakishGusto = 1510,
  SuperMechArmor = 1511,
  SuperMechPowerField = 1512,
  TurretPlating = 1515,
  StructureBounty = 1516,
  StructureBounty = 1517,
  StructureBounty = 1518,
  StructureBounty = 1519,
  OvererchargedHA = 1520,
  Fortification = 1521,
  TowerPowerUp = 1522,
  HealthPotion = 2003,
  TotalBiscuitofEverlastingWill = 2010,
  KircheisShard = 2015,
  SteelSigil = 2019,
  TheBrutalizer = 2020,
  Tunneler = 2021,
  GlowingMote = 2022,
  RefillablePotion = 2031,
  CorruptingPotion = 2033,
  GuardiansAmulet = 2049,
  GuardiansShroud = 2050,
  GuardiansHorn = 2051,
  PoroSnax = 2052,
  ControlWard = 2055,
  StealthWard = 2056,
  ShurelyasBattlesong = 2065,
  ElixirofIron = 2138,
  ElixirofSorcery = 2139,
  ElixirofWrath = 2140,
  CappaJuice = 2141,
  JuiceofPower = 2142,
  JuiceofVitality = 2143,
  JuiceofHaste = 2144,
  ElixirofSkill = 2150,
  ElixirofAvarice = 2151,
  ElixirofForce = 2152,
  BFSword = 221038,
  VampiricScepter = 221053,
  NeedlesslyLargeRod = 221058,
  GuardiansHorn = 222051,
  ShurelyasBattlesong = 222065,
  Evenshroud = 223001,
  ArchangelsStaff = 223003,
  Manamune = 223004,
  Ghostcrawlers = 223005,
  BerserkersGreaves = 223006,
  BootsofSwiftness = 223009,
  ChemtechPutrifier = 223011,
  SorcerersShoes = 223020,
  GuardianAngel = 223026,
  InfinityEdge = 223031,
  MortalReminder = 223033,
  LordDominiksRegards = 223036,
  AtmasReckoning = 223039,
  SeraphsEmbrace = 223040,
  Muramana = 223042,
  PhantomDancer = 223046,
  PlatedSteelcaps = 223047,
  ZekesConvergence = 223050,
  SteraksGage = 223053,
  Sheen = 223057,
  SpiritVisage = 223065,
  Kindlegem = 223067,
  SunfireAegis = 223068,
  BlackCleaver = 223071,
  Bloodthirster = 223072,
  RavenousHydra = 223074,
  Thornmail = 223075,
  TrinityForce = 223078,
  Heartsteel = 223084,
  RunaansHurricane = 223085,
  StatikkShiv = 223087,
  RabadonsDeathcap = 223089,
  WitsEnd = 223091,
  RapidFirecannon = 223094,
  Stormrazor = 223095,
  LichBane = 223100,
  BansheesVeil = 223102,
  AegisoftheLegion = 223105,
  Redemption = 223107,
  KnightsVow = 223109,
  FrozenHeart = 223110,
  MercurysTreads = 223111,
  GuardiansOrb = 223112,
  NashorsTooth = 223115,
  RylaisCrystalScepter = 223116,
  WintersApproach = 223119,
  Fimbulwinter = 223121,
  GuinsoosRageblade = 223124,
  VoidStaff = 223135,
  MercurialScimitar = 223139,
  YoumuusGhostblade = 223142,
  RanduinsOmen = 223143,
  HextechGunblade = 223146,
  HextechRocketbelt = 223152,
  BladeofTheRuinedKing = 223153,
  MawofMalmortius = 223156,
  ZhonyasHourglass = 223157,
  IonianBootsofLucidity = 223158,
  SpearofShojin = 223161,
  Morellonomicon = 223165,
  Zephyr = 223172,
  GuardiansBlade = 223177,
  Hullbreaker = 223181,
  GuardiansHammer = 223184,
  GuardiansDirk = 223185,
  LocketoftheIronSolari = 223190,
  GargoyleStoneplate = 223193,
  MikaelsBlessing = 223222,
  ArdentCenser = 223504,
  EssenceReaver = 223508,
  DeadMansPlate = 223742,
  TitanicHydra = 223748,
  EdgeofNight = 223814,
  SpectralCutlass = 224004,
  ImperialMandate = 224005,
  ForceofNature = 224401,
  TheGoldenSpatula = 224403,
  HorizonFocus = 224628,
  CosmicDrive = 224629,
  Riftmaker = 224633,
  NightHarvester = 224636,
  DemonicEmbrace = 224637,
  CrownoftheShatteredQueen = 224644,
  Shadowflame = 224645,
  SilvermereDawn = 226035,
  DeathsDance = 226333,
  ChempunkChainsword = 226609,
  StaffofFlowingWater = 226616,
  MoonstoneRenewer = 226617,
  EchoesofHelia = 226620,
  Goredrinker = 226630,
  Stridebreaker = 226631,
  DivineSunderer = 226632,
  LiandrysAnguish = 226653,
  LudensTempest = 226655,
  Everfrost = 226656,
  RodofAges = 226657,
  IcebornGauntlet = 226662,
  TurboChemtank = 226664,
  JakShoTheProtean = 226665,
  RadiantVirtue = 226667,
  Galeforce = 226671,
  KrakenSlayer = 226672,
  ImmortalShieldbow = 226673,
  NavoriQuickblades = 226675,
  TheCollector = 226676,
  DuskbladeofDraktharr = 226691,
  Eclipse = 226692,
  ProwlersClaw = 226693,
  SeryldasGrudge = 226694,
  SerpentsFang = 226695,
  AxiomArc = 226696,
  Syzygy = 227001,
  DraktharrsShadowcarver = 227002,
  FrozenFist = 227005,
  Typhoon = 227006,
  IcathiasCurse = 227009,
  Vespertide = 227010,
  UpgradedAeropack = 227011,
  LiandrysLament = 227012,
  ForceofArms = 227013,
  EternalWinter = 227014,
  CeaselessHunger = 227015,
  Dreamshatter = 227016,
  Deicide = 227017,
  InfinityForce = 227018,
  ReliquaryoftheGoldenDawn = 227019,
  ShurelyasRequiem = 227020,
  Starcaster = 227021,
  Equinox = 227023,
  Caesura = 227024,
  Leviathan = 227025,
  TheUnspokenParasite = 227026,
  PrimordialDawn = 227027,
  InfiniteConvergence = 227028,
  YoumuusWake = 227029,
  SeethingSorrow = 227030,
  EdgeofFinality = 227031,
  Flicker = 227032,
  CryoftheShriekingCity = 227033,
  AnathemasChains = 228001,
  WoogletsWitchcap = 228002,
  Deathblade = 228003,
  AdaptiveHelm = 228004,
  ObsidianCleaver = 228005,
  SanguineBlade = 228006,
  Runeglaive = 228008,
  AbyssalMask = 228020,
  MinionDematerializer = 2403,
  CommencingStopwatch = 2419,
  SeekersArmguard = 2420,
  ShatteredArmguard = 2421,
  SlightlyMagicalFootwear = 2422,
  PerfectlyTimedStopwatch = 2423,
  UnendingDespair = 2502,
  KaenicRookern = 2504,
  Evenshroud = 3001,
  Trailblazer = 3002,
  ArchangelsStaff = 3003,
  Manamune = 3004,
  Ghostcrawlers = 3005,
  BerserkersGreaves = 3006,
  BootsofSwiftness = 3009,
  ChemtechPutrifier = 3011,
  ChaliceofBlessing = 3012,
  SorcerersShoes = 3020,
  LifewellPendant = 3023,
  GlacialBuckler = 3024,
  GuardianAngel = 3026,
  InfinityEdge = 3031,
  MortalReminder = 3033,
  LastWhisper = 3035,
  LordDominiksRegards = 3036,
  AtmasReckoning = 3039,
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
  ExperimentalHexplate = 3073,
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
  StatikkShiv = 3087,
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
  Malignance = 3118,
  WintersApproach = 3119,
  Fimbulwinter = 3121,
  ExecutionersCalling = 3123,
  GuinsoosRageblade = 3124,
  DeathfireGrasp = 3128,
  SwordoftheDivine = 3131,
  CaulfieldsWarhammer = 3133,
  SerratedDirk = 3134,
  VoidStaff = 3135,
  Cryptbloom = 3137,
  MercurialScimitar = 3139,
  QuicksilverSash = 3140,
  YoumuusGhostblade = 3142,
  RanduinsOmen = 3143,
  HextechAlternator = 3145,
  HextechGunblade = 3146,
  HauntingGuise = 3147,
  HextechRocketbelt = 3152,
  BladeofTheRuinedKing = 3153,
  Hexdrinker = 3155,
  MawofMalmortius = 3156,
  ZhonyasHourglass = 3157,
  IonianBootsofLucidity = 3158,
  SpearofShojin = 3161,
  Morellonomicon = 3165,
  Zephyr = 3172,
  GuardiansBlade = 3177,
  UmbralGlaive = 3179,
  Hullbreaker = 3181,
  GuardiansHammer = 3184,
  LocketoftheIronSolari = 3190,
  GargoyleStoneplate = 3193,
  SpectresCowl = 3211,
  MikaelsBlessing = 3222,
  Terminus = 3302,
  ScarecrowEffigy = 3330,
  StealthWard = 3340,
  ArcaneSweeper = 3348,
  LucentSingularity = 3349,
  FarsightAlteration = 3363,
  OracleLens = 3364,
  YourCut = 3400,
  RiteOfRuin = 3430,
  ArdentCenser = 3504,
  EssenceReaver = 3508,
  EyeoftheHerald = 3513,
  KalistasBlackSpear = 3599,
  KalistasBlackSpear = 3600,
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
  WorldAtlas = 3865,
  RunicCompass = 3866,
  BountyofWorlds = 3867,
  CelestialOpposition = 3869,
  DreamMaker = 3870,
  ZazZaksRealmspike = 3871,
  SolsticeSleigh = 3876,
  Bloodsong = 3877,
  FireatWill = 3901,
  DeathsDaughter = 3902,
  RaiseMorale = 3903,
  OblivionOrb = 3916,
  Lifeline = 4003,
  SpectralCutlass = 4004,
  ImperialMandate = 4005,
  BloodlettersCurse = 4010,
  SwordofBlossomingDawn = 4011,
  SinEater = 4012,
  LightningBraid = 4013,
  FrozenMallet = 4014,
  Perplexity = 4015,
  WordlessPromise = 4016,
  HellfireHatchet = 4017,
  ForceofNature = 4401,
  InnervatingLocket = 4402,
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
  Stormsurge = 4646,
  IronspikeWhip = 6029,
  SilvermereDawn = 6035,
  DeathsDance = 6333,
  ChempunkChainsword = 6609,
  SunderedSky = 6610,
  StaffofFlowingWater = 6616,
  MoonstoneRenewer = 6617,
  EchoesofHelia = 6620,
  Dawncore = 6621,
  Goredrinker = 6630,
  Stridebreaker = 6631,
  DivineSunderer = 6632,
  LiandrysTorment = 6653,
  LudensCompanion = 6655,
  Everfrost = 6656,
  RodofAges = 6657,
  BamisCinder = 6660,
  IcebornGauntlet = 6662,
  HollowRadiance = 6664,
  JakSho,
  TheProtean = 6665,
  RadiantVirtue = 6667,
  Noonquiver = 6670,
  Galeforce = 6671,
  KrakenSlayer = 6672,
  ImmortalShieldbow = 6673,
  NavoriQuickblades = 6675,
  TheCollector = 6676,
  Rageknife = 6677,
  Rectrix = 6690,
  DuskbladeofDraktharr = 6691,
  Eclipse = 6692,
  ProwlersClaw = 6693,
  SeryldasGrudge = 6694,
  SerpentsFang = 6695,
  AxiomArc = 6696,
  Hubris = 6697,
  ProfaneHydra = 6698,
  VoltaicCyclosword = 6699,
  ShieldoftheRakkor = 6700,
  Opportunity = 6701,
  SandshrikesClaw = 7000,
  Syzygy = 7001,
  DraktharrsShadowcarver = 7002,
  RabadonsDeathcrown = 7003,
  EnmityoftheMasses = 7004,
  FrozenFist = 7005,
  Typhoon = 7006,
  Swordnado = 7007,
  Ataraxia = 7008,
  IcathiasCurse = 7009,
  Vespertide = 7010,
  UpgradedAeropack = 7011,
  LiandrysLament = 7012,
  ForceofArms = 7013,
  EternalWinter = 7014,
  CeaselessHunger = 7015,
  Dreamshatter = 7016,
  Deicide = 7017,
  InfinityForce = 7018,
  ReliquaryoftheGoldenDawn = 7019,
  ShurelyasRequiem = 7020,
  Starcaster = 7021,
  Certainty = 7022,
  Equinox = 7023,
  Caesura = 7024,
  Leviathan = 7025,
  TheUnspokenParasite = 7026,
  PrimordialDawn = 7027,
  InfiniteConvergence = 7028,
  YoumuusWake = 7029,
  SeethingSorrow = 7030,
  EdgeofFinality = 7031,
  Flicker = 7032,
  CryoftheShriekingCity = 7033,
  HopeAdrift = 7034,
  Daybreak = 7035,
  TURBO = 7036,
  ObsidianCleaver = 7037,
  ShojinsResolve = 7038,
  Heavensfall = 7039,
  EyeoftheStorm = 7040,
  WyrmfallenSacrifice = 7041,
  TheBaronsGift = 7042,
  GangplankPlaceholder = 7050,
  AnathemasChains = 8001,
  AbyssalMask = 8020,
}

local RuneID = { --13.20 update
  Domination = {
    Electrocute = 8112,
    Predator = 8124,
    DarkHarvest = 8128,
    HailOfBlades = 9923,
    CheapShot = 8126,
    TasteOfBlood = 8139,
    SuddenImpact = 8143,
    ZombieWard = 8136,
    GhostPoro = 8120,
    EyeballCollection = 8138,
    TreasureHunter = 8135,
    IngeniousHunter = 8134,
    RelentlessHunter = 8105,
    UltimateHunter = 8106,
  },
  Inspiration = {
    GlacialAugment = 8351,
    UnsealedSpellbook = 8360,
    FirstStrike = 8369,
    HextechFlashtraption = 8306,
    MagicalFootwear = 8304,
    PerfectTiming = 8313,
    FuturesMarket = 8321,
    MinionDematerializer = 8316,
    BiscuitDelivery = 8345,
    CosmicInsight = 8347,
    ApproachVelocity = 8410,
    TimeWarpTonic = 8352,
  },
  Precision = {

    PressTheAttack = 8005,
    LethalTempo = 8008,
    FleetFootwork = 8021,
    Conqueror = 8010,
    Overheal = 9101,
    Triumph = 9111,
    PresenceOfMind = 8009,
    LegendAlacrity = 9104,
    LegendTenacity = 9105,
    LegendBloodline = 9103,
    CoupDeGrace = 8014,
    CutDown = 8017,
    LastStand = 8299,

  },
  Resolve = {
    GraspOfTheUndying = 8437,
    Aftershock = 8439,
    Guardian = 8465,
    Demolish = 8446,
    FontOfLife = 8463,
    ShieldBash = 8401,
    Conditioning = 8429,
    SecondWind = 8444,
    BonePlating = 8473,
    Overgrowth = 8451,
    Revitalize = 8453,
    Unflinching = 8242.

  },
  Sorcery = {
    SummonAery = 8214,
    ArcaneComet = 8229,
    PhaseRush = 8230,
    NullifyingOrb = 8224,
    ManaflowBand = 8226,
    NimbusCloak = 8275,
    Transcendence = 8210,
    Celerity = 8234,
    AbsoluteFocus = 8233,
    Scorch = 8237,
    Waterwalking = 8232,
    GatheringStorm = 8236.

  },
}

-- [[ Local Functions ]] --

local table_contains = function(table, x)
  local found = false
  for _, v in pairs(table) do
    if v == x then
      found = true
    end
  end
  return found
end

local getBaseHealth = function(unit)
  --NEW API
  local baseHP = unit.baseHP
  local hpPerLevel = unit.hpPerLevel
  local hp = baseHP + (hpPerLevel * unit.levelData.lvl - 1)
      * (0.7025 + (0.0175 * (unit.levelData.lvl - 1)))
  return hp
end

local getBonusHealth = function(unit)
  --NEW API
  local maxHealth = unit.maxHealth
  local baseHP = getBaseHealth(unit)
  local BonusHealth = maxHealth - baseHP
  return BonusHealth
end

local getBaseMana = function(unit)
  if unit.charName == "Kassadin" then
    return 300 + (70 * (unit.levelData.lvl - 1))
  elseif unit.charName == "Ryze" then
    return 400 + (87 * (unit.levelData.lvl - 1))
  end
end

local getBaseAttackspeed = function(unit)
  local baseattackspeed = HEROES[unit.charName][3]
  if baseattackspeed then
    return baseattackspeed
  end
end

local getAttackspeed = function(unit)
  local baseattackspeed = getBaseAttackspeed(unit)
  if baseattackspeed then
    return unit.attackSpeed * baseattackspeed
  end
end

local getPercentHP = function(unit)
  return 100 * unit.health / unit.maxHealth
end

local getPercentMissingHP = function(unit)
  return (1 - (unit.health / unit.maxHealth))
end

local getMissingHP = function(unit)
  return (unit.maxHealth - unit.health)
end

local getSummonerSpell = function(spellName)
  local summonerSpell = (myHero:GetSpellData(SUMMONER_1).name:lower():find(spellName) and SUMMONER_1) or
      (myHero:GetSpellData(SUMMONER_2).name:lower():find(spellName) and SUMMONER_2) or nil
  return summonerSpell
end

local getItemSlot = function(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then return i end
  end
  return 0
end

local gotSpell = function(spellslot, spellname)
  if myHero:GetSpellData(spellslot).name == spellname then
    return 1
  end
  return 0
end

local hasPoison = function(unit)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.type == 24 and Game.Timer() < buff.expireTime - 0.125 then
      return true
    end
  end
  return false
end

local getTurretType = function(name, type)
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

local isMelee = function(unit)
  local IsHeroMelee = HEROES[unit.charName][2]
  local IsHeroSpecialMelee = HeroSpecialMelees[unit.charName]
  if IsHeroMelee or (IsHeroSpecialMelee and IsHeroSpecialMelee()) then
    return true
  end
  return false
end

local isARAM = function()
  local mapID = Game.mapID
  if mapID == HOWLING_ABYSS then
    return true
  else
    return false
  end
end

local getMapIDName = function(mapID)
  -- TODO:
  -- Example usage: -- getMapIDName(Game.mapID)
  -- local myMapID = 13 -- Change this to test different map IDs
  -- getMapIDName(myMapID)
  local mapNames = {
    [12] = "HOWLING_ABYSS",
    [11] = "SUMMONERS_RIFT",
    [10] = "TWISTED_TREELINE",
    [8] = "CRYSTAL_SCAR",
    [30] = "THE_ARENA"
    --COSMIC_RUINS (Dark Star)
    --Crash Site (Odyssey: Extraction)
    --Substructure 43 (PROJECT: OVERCHARGE)
    --Temple of Lily and Lotus (Nexus Blitz)
    --Valoran City Park (Star Guardians)

    --Modes:
    -- 5v5 Normal & Ranked (Summoner’s Rift)
    -- 3v3 Normal & Ranked (Twisted Treeline)
    -- Dominion (Crystal Scar)
    -- Ascension (Crystal Scar)
    -- Black Market Brawlers (Summoner’s Rift)
    -- Dark Star: Singularity (Cosmic Ruins)
    -- Definitely Not Dominion (Crystal Scar)
    -- Doom Bots (Summoner’s Rift)
    -- Hexakill (Summoner’s Rift)
    -- Hunt of the Blood Moon (Summoner’s Rift)
    -- Invasion (Valoran City Park)
    -- Nemesis Draft (Summoner’s Rift)
    -- Nexus Blitz (Temple of Lily and Lotus)
    -- Nexus Siege (Summoner’s Rift)
    -- Odyssey: Extraction (Crash Site)
    -- One for All (Summoner’s Rift)
    -- OVERCHARGE (Substructure 43)
    -- Ultra Rapid Fire (Summoner’s Rift)
    -- Ultimate Spellbook (Summoner’s Rift)
  }
  local mapName = mapNames[mapID]
  if mapName then
    return mapName
  else
    return mapID
  end
end

-- [[ Calc Damage Tables ]] --
local DamageReductionBuffsTable = {
  --["Annie"] = {buff = "AnnieE", amount = function(target) return ({0.10,0.13,0.16,0.19,0.22})[target:GetSpellData(_E).level] end},
  ["Alistar"] = {
    buff = "FerociousHowl",
    amount = function(source, target, DamageType, amount)
      return ({ 0.55, 0.65, 0.75 })
          [target:GetSpellData(_R).level]
    end
  },
  --MOVED is flatreduction["Amumu"] = {buff = "Tantrum", DamageType = 1, amount = function(target) return (({5, 7, 9, 11, 13})[target:GetSpellData(_E).level] + (0.03 * target.bonusMagicResist) + (0.03 * target.bonusArmor)) end}, --max 50%
  ["Belveth"] = {
    buff = "BelvethE",
    amount = function(source, target, DamageType, amount)
      return
          (({ 42, 49, 56, 63, 70 })[target:GetSpellData(_E).level] / 100)
    end
  },
  ["Braum"] = {
    buff = "BraumShieldRaise",
    amount = function(source, target, DamageType, amount)
      return
          ({ 0.3, 0.325, 0.35, 0.375, 0.4 })[target:GetSpellData(_E).level]
    end
  },
  ["Briar"] = { buff = "BriarE", amount = function(source, target, DamageType, amount) return 0.35 end }, -- check buff name
  ["Galio"] = {                                                                                           --magic + physical
    buff = "galiowpassivedefense" or "GalioW",
    DamageType = 2 or 1,
    amount = function(source, target, DamageType, amount)
      local reduct = {
        ap = ({ 0.25, 0.30, 0.35, 0.40, 0.45 })[target.level],
        ad = ({ 0.125, 0.15, 0.175, 0.20, 0.225 })[target.level],
      }
      local reduction = 0
      if DamageType == 2 then
        reduction = reduct.ap
      else
        reduction = reduct.ad
      end
      return reduction + (0.04 * math.floor(target.ap / 100)) +
          (0.08 * math.floor(target.bonusMagicResist / 100)) +
          (0.01 * math.floor((getBonusHealth(target)) / 100)) --target.bonusHealth
    end
  },
  ["Garen"] = { buff = "GarenW", amount = function(source, target, DamageType, amount) return 0.3 end },
  ["Gragas"] = {
    buff = "GragasWSelf",
    amount = function(source, target)
      return
          ({ 0.10, 0.12, 0.14, 0.16, 0.18 })[target:GetSpellData(_W).level] + (0.04 * math.floor(target.ap / 100))
    end
  },
  -- ["KSante"] = {buff = "KSanteW", amount = function(source, target) return  0.25 + (0.10 * math.floor(target.bonusArmor/100)) + (0.10 * math.floor(target.bonusMagicResist/100)) + (0.10 * math.floor((target.maxHealth - GetBaseHealth(target))/100)) end},
  ["KSante"] = {
    buff = "KSanteW",
    amount = function(source, target, DamageType, amount)
      return
          (0.40 + 0.25 / 17 * (target.levelData.lvl - 1))
    end
  },
  ["Malzahar"] = { buff = "malzaharpassiveshield", amount = function(source, target, DamageType, amount) return 0.9 end },
  ["MasterYi"] = {
    buff = "Meditate",
    amount = function(source, target)
      return
          ({ 0.45, 0.475, 0.50, 0.525, 0.55 })[target:GetSpellData(_W).level] / (source.type == Obj_AI_Turret and 2 or 1)
    end
  },
  ["NilahW"] = { buff = "NilahW", DamageType = 2, amount = function(source, target, DamageType, amount) return 0.25 end }, --TODO:
}

local DamageReductionItemsTable = {
  [ItemID.PlatedSteelcaps] = {
    IsAA = true,
    amount = function(source, target, DamageType, amount) --3047 Plated Steelcaps
      --if AA and not SourceIsTurret then dmg = dmg * (1-0.12)
      return 0.12
    end
  },
  [ItemID.FrozenHeart] = {
    IsAA = true,
    amount = function(source, target, DamageType, amount) --3110 Frozen Heart
      --if AA then dmg = dmg - (5 + 3.5 per 1000 hp) cap at 40% of dmg
      return math.max(5 + (3.5 * math.floor(target.maxHealth / 1000)), amount * 0.40)
    end
  },
  [ItemID.RanduinsOmen] = {
    IsAA = true,
    amount = function(source, target, DamageType, amount) --3143 Randuin's Omen
      --if AA then dmg = dmg - (7 + 3.5 per 1000 hp) cap at 40% of dmg
      return math.max(7 + (3.5 * math.floor(target.maxHealth / 1000)), amount * 0.40)
    end
  },
  [ItemID.WardensMail] = {
    IsAA = true,
    amount = function(source, target, DamageType, amount) --3082 Warden's Mail
      --if AA then dmg = dmg - (7 + 3.5 per 1000 hp) cap at 40% of dmg
      return math.max(7 + (3.5 * math.floor(target.maxHealth / 1000)), amount * 0.40)
    end
  },

  [ItemID.ForceofNature] = {
    buff = "4401maxstacked",
    IsAA = false,
    DamageType = 2,
    amount = function(source, target, DamageType, amount)
      --if buff and magic damage then ( 0.25)
      if DamageType == 2 then
        return (0.25)
      end
    end
  },
}
--[[ TODO:
  Chemtech Blight damage increase/reduction
  --8020 Abyssal Mask
  --3193 Gargoyle Stoneplate
  --8001 Anathema's Chains
]]
local SpecialAADamageTable = {
  --Spell/Skills
  ["Blitzcrank"] = function(args) --BlitzcrankW Overdrive
    if Buff:HasBuff(args.source, "Overdrive") then
      local unitLevel = args.source.levelData.lvl
      local maxHealth = (1 / 100 * args.Target.maxHealth)
      if args.TargetIsMinion then
        args.RawMagical = (maxHealth) +
            ({ 60, 80, 100, 120, 140, 160, 165, 170, 175, 180, 185, 190, 195, 200, 205, 210, 215, 220 })
            [unitLevel] -- (60+120, 17*(unitLevel-1))
      else
        args.RawMagical = (maxHealth)
      end
    end
  end,

  ["Kayle"] = function(args) --KayleE
    local elevel = args.source:GetSpellData(_E).level
    local level = args.source.levelData.lvl
    local kaylePassive = (20 + (3 * math.max(level - 11, 0)) + 0.10 * args.source.bonusDamage + 0.25 * args.source.ap)
    --Buff:HasBuff(args.source, "KayleE") e active
    --Buff:HasBuff(args.source, "KayleEPassive") e passive dmg
    --Buff:HasBuff(args.source, "kaylepassiverank0-3")
    --Buff:HasBuff(args.source, "kayleenragecounter") 1-5
    --Buff:HasBuff(args.source, "kayleenrage") @ 5 passive dmg unless kaylepassiverank3
    if elevel >= 1 then
      local kayleEPassive = (10 + (5 * elevel) + 0.10 * args.source.bonusDamage + 0.20 * args.source.ap)
      if args.source.levelData.lvl >= 16 or args.source.levelData.lvl > 11 and Buff:HasBuff(args.source, "kayleenrage") then --Buff:HasBuff(args.source, "JudicatorRighteousFury")
        args.RawMagical = args.RawMagical + kaylePassive +
            kayleEPassive                                                                                                    -- Kayle Passive
      else
        args.RawMagical = args.RawMagical +
            kayleEPassive -- E passive
      end
      if Buff:HasBuff(args.source, "KayleE") then
        local eActiveBonusDmg = (({ 8, 8.5, 9, 9.5, 10 })[elevel] + 0.015 * args.source.ap) / 100 *
            getMissingHP(args.Target)
        if args.Target.type == Obj_AI_Camp then
          eActiveBonusDmg = math.max(eActiveBonusDmg, math.min(400, eActiveBonusDmg))
        end
        args.RawMagical = args.RawMagical + eActiveBonusDmg
      end
    end
  end,

  ["Nasus"] = function(args) --NasusQ
    if Buff:HasBuff(args.source, "NasusQ") then
      args.RawPhysical = args.RawPhysical
          + math.max(Buff:GetBuffCount(args.source, "NasusQStacks"), 0)
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
      local damage = math.max(Buff:GetBuffCount(args.source, "threshpassivesouls"), 0)
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

  ["TwistedFate"] = function(args) --TwistedFateW / Stacked Deck
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
              (0.06 * math.floor(args.source.bonusDamage / 100)) * args.Target.maxHealth)
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
    --local small = { 15, 16, 17, 18, 19, 20, 22, 23, 24, 26, 27, 29, 31, 32, 34, 36, 38, 40 }
    --local big = { 90, 94, 99, 104, 109, 115, 121, 127, 133, 140, 146, 153, 160, 168, 175, 183, 191, 200 }
    if Buff:HasBuff(myHero, "zeriqpassiveready") then
      args.RawMagical = 90 + (110 / 17)
          * (args.source.levelData.lvl - 1)
          * (0.7025 + 0.0175 * (args.source.levelData.lvl - 1))
          + args.source.ap * 1.10
          + (1 + (14 / 17) * (args.source.levelData.lvl - 1) * (0.7025 + 0.0175 * (args.source.levelData.lvl - 1)))
      --big[math.max(math.min(args.source.levelData.lvl, 18), 1)] + args.source.ap * 0.8
    else
      args.RawMagical = 10 + (15 / 17) * (args.source.levelData.lvl - 1)
          * (0.7025 + 0.0175 * (args.source.levelData.lvl - 1))
          + args.source.ap * 0.03
      --small[math.max(math.min(args.source.levelData.lvl, 18), 1)] + args.source.ap * 0.04
    end
  end,

}

local HeroPassiveDamageTable = {
  --Passives/Buffs
  ["Blitzcrank"] = function(args)                  --BlitzcrankE TODO: R passive  + (0.02 * source.maxMana)
    if Buff:HasBuff(args.source, "PowerFist") then --PowerFistAttack
      local level = args.source.levelData.lvl
      --[[       if args.TargetIsMinion then
        args.RawPhysical = args.RawPhysical + (2.00 * args.source.totalDamage) + (0.25 * args.source.ap)
      else ]]
      args.RawPhysical = args.RawPhysical + (1.75 * args.source.totalDamage) + (0.25 * args.source.ap)
      --end
    end
  end,

  ["Akshan"] = function(args) --Akshan Passive 2nd shot
    if args.TargetIsMinion then
      args.RawPhysical = args.RawPhysical
          + 0.50 * args.source.totalDamage
    else
      args.RawPhysical = args.RawPhysical
          + args.source.totalDamage
    end
  end,

  ["Ashe"] = function(args) --Ashe
    if Buff:HasBuff(args.Target, "frost") then
      args.RawPhysical = args.RawPhysical
          + 1.20 * args.source.critChance
    end
  end,

  ["Caitlyn"] = function(args) --Caitlyn headshot
    if Buff:HasBuff(args.source, "caitlynpassivedriver") then
      local modCrit = 1.4875 +
          (Item:HasItem(args.source, ItemID.InfinityEdge) and 0.3825 or 0) --1.3125 or 131.25% = 75% * standard critical damage factor --1.421875 and 0.365625 =  81.25% crit
      if args.TargetIsMinion then
        local unitLevel = args.source.levelData.lvl
        local modLevel = unitLevel < 7 and 1.10 or (unitLevel < 13 and 1.15 or 1.20)
        --args.RawPhysical = args.RawPhysical + (1 + (modCrit * args.source.critChance)) * args.source.totalDamage
        args.RawPhysical = args.RawPhysical +
            (1 + (modCrit * args.source.critChance)) * (args.source.totalDamage * modLevel)
      else
        local unitLevel = args.source.levelData.lvl
        local modLevel = unitLevel < 7 and 0.60 or (unitLevel < 13 and 0.90 or 1.120)
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
          --math.max(15 + 5 * level, -10 + 10 * level, -60 + 15 * level, -125 + 20 * level, -200 + 25 * level)
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
    local t = (100 * 0.6895 + 0.01765 * args.source.levelData.lvl * (0.5955 + 0.0225 * (args.source.levelData.lvl - 1)))
    local t2 = t * 0.33302
    local t3 = t * (1 + 3 * 0.33302)
    if args.CriticalStrike then
      local modCrit = 1.45 + (Item:HasItem(args.source, ItemID.InfinityEdge) and 0.50 or 0)
      t3            = t * (1 + 5 * 0.33302) * (50 * 0.45 / 100)
    end
    local math = t3
    args.RawTotal = args.RawTotal * math
  end,
  --[[ ["Graves"] = function(args) --Graves
    local t = { 70, 71, 72, 74, 75, 76, 78, 80, 81, 83, 85, 87, 89, 91, 95, 96, 97, 100 }
    args.RawTotal = args.RawTotal * t[math.max(math.min(args.source.levelData.lvl, 18), 1)] * 0.01
  end, ]]

  ["Jhin"] = function(args) --Jhin 4thshot/AA
    if Buff:HasBuff(args.source, "jhinpassiveattackbuff") then
      args.CriticalStrike = true
      args.RawPhysical = args.RawPhysical
          + math.min(0.25, 0.1 + 0.05 * math.ceil(args.source.levelData.lvl / 5))
          * (args.Target.maxHealth - args.Target.health)
    end
  end,

  ["Jinx"] = function(args) --JinxQ
    if Buff:HasBuff(args.source, "JinxQ") then
      args.RawPhysical = args.RawPhysical + args.source.totalDamage * 0.1
    end
  end,

  --[[ ["Kalista"] = function(args) --Kalista
    args.RawPhysical = args.RawPhysical - args.source.totalDamage * 0.1
  end, ]]

  ["KSante"] = function(args) --KSanteMark + KSanteRTransform
    local level = args.source.levelData.lvl
    local hplvl = 1
    if Buff:HasBuff(args.Target, "KSantePMark") then
      --if level < 6 then hplvl = 1
      if level >= 6 and level < 11 then
        hplvl = 2
      elseif level >= 11 and level < 16 then
        hplvl = 3
      elseif level >= 16 then
        hplvl = 4
      end
      local markdmg = ((5 + 15 / 17 * (level - 1)) + ({ 1.00, 1.33, 1.66, 2.00 })[hplvl] / 100 * args.Target.maxHealth)
      if Buff:HasBuff(args.source, "KSanteRTransform") then
        --local allOutDamageMod = 0.35 + (0.20 * math.floor(args.source.bonusArmor/100)) + (0.20 * math.floor(args.source.bonusMagicResist/100)) --removed 13.20
        local allouthplvl = 0.30 + (0.04 * math.min(level, 18))
        local allOutDamageMod = 1 + allouthplvl --(({45, 60, 75})[hplvl]/100)
        args.RawPhysical = args.RawPhysical * allOutDamageMod
        args.CalculatedTrue = args.CalculatedTrue + markdmg * allOutDamageMod
      else
        args.RawPhysical = args.RawPhysical + markdmg
      end
    end
  end,

  ["Lux"] = function(args) --Lux Marks
    if Buff:HasBuff(args.Target, "LuxIlluminatingFraulein") then
      args.RawMagical = (20 + 10 * args.source.levelData.lvl) + (0.25 * args.source.ap)
    end
  end,

  ["Orianna"] = function(args)
    local level = math.ceil(args.source.levelData.lvl / 3)
    args.RawMagical = args.RawMagical + 2 + 8 * level + 0.15 * args.source.ap
    if args.Target.Ghandle == args.source.attackData.target then
      args.RawMagical = args.RawMagical
          + math.max(Buff:GetBuffCount(args.source, "orianapowerdaggerdisplay"), 0)
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
          + math.max((0.045 + 0.015 * level) * args.Target.maxHealth, 20 + 20 * level)
    end
  end,

  ["Zed"] = function(args)
    if 100 * args.Target.health / args.Target.maxHealth <= 50 and not Buff:HasBuff(args.source, "zedpassivecd") then
      args.RawMagical = args.RawMagical +
          args.Target.maxHealth * (4 + 2 * math.ceil(args.source.levelData.lvl / 6)) * 0.01
    end
  end,

  ["Zeri"] = function(args)
    if args.Target.health < (6 * 10 + (6 * 15 / 17) * (args.source.levelData.lvl - 1) * (0.7025 + 0.0175 * (args.source.levelData.lvl - 1)) + 0.18 * args.source.ap) then -- release was (args.Target.maxHealth * 0.35)
      args.RawMagical = args.Target.health + 9999
    end
  end,

}

local ItemDamageTable = {
  [ItemID.RecurveBow] = function(args) --"Recurve Bow"
    args.RawPhysical = args.RawPhysical + 15
  end,
  [ItemID.KircheisShard] = function(args) --"Kircheis Shard"
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
          * t[math.max(math.min(args.source.levelData.lvl, 18), 1)]
    end
  end, ]]
  [ItemID.WitsEnd] = function(args) --"Wit's End"
    args.RawMagical = args.RawMagical + 40
  end,
  [ItemID.RapidFirecannon] = function(args) --"Rapid Firecannon"
    if Buff:GetBuffCount(args.source, "itemstatikshankcharge") == 100 then
      local t = { 50, 50, 50, 50, 50, 58, 66, 75, 83, 92, 100, 109, 117, 126, 134, 143, 151, 160 }
      args.RawMagical = args.RawMagical + t[math.max(math.min(args.source.levelData.lvl, 18), 1)]
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
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 25, 40, 55, 70 })
            [level] + ({ 0.65, 0.675, 0.75, 0.825, 0.90 })[level] * source.totalDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 12.50, 37.50, 50, 68.75, 87.50 })
            [level] + ({ 0.8125, 0.875, 1, 1.125, 1.25 })[level] * source.totalDamage
      end
    },
    {
      Slot = "Q",
      Stage = 3,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 37.50, 60, 82.50, 105 })
            [level] + ({ 0.975, 1.05, 1.20, 1.35, 1.50 })[level] * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 40, 50, 60, 70 })
            [level] + 0.40 * source.totalDamage
      end
    },
  },

  ["Ahri"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 65, 90, 115, 140 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 40, 65, 90, 115, 140 })
            [level] + 0.50 * source.ap
      end
    }, --return
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 45, 70, 95, 120, 145 })
            [level] + 0.30 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 13.5, 21, 28.5, 36, 43.5 })
            [level] + 0.09 * source.ap
      end
    }, --additional damage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120 })[level] +
            0.35 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120 })[level] +
            0.35 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 3,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120 })[level] +
            0.35 * source.ap
      end
    },
  },

  ["Akali"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 45, 70, 95, 120, 145 })
            [level] + (0.65 * source.totalDamage) + (0.60 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 56.25, 82.5, 108.75, 135 })
            [level] + (0.255 * source.totalDamage) + (0.36 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 131.25, 192.5, 253.75, 315 })
            [level] + (0.595 * source.totalDamage) + (0.84 * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 220, 360 })[level] +
            (0.50 * source.bonusDamage) + (0.30 * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 130, 200 })[level] +
            (0.30 * source.ap) * (0.0286 * (math.min(getPercentHP(target), 70)))
      end
    },
  },

  ["Akshan"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 25, 45, 65, 85 })
            [level] + 0.80 * source.totalDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 50, 90, 130, 170 })
            [level] + 1.60 * source.totalDamage
      end
    }, --total return damage
    {
      Slot = "E",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 25, 40, 55, 70, 85 })
            [level] + 0.175 * source.bonusDamage + (1 + (0.3 * source.attackSpeed))
      end
    }, --per shot
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 25, 35, 45 })[level] +
            (0.15 * source.totalDamage) + (1 + (0.50 * source.critChance)) * (0.02 * (getPercentHP(target)))
      end
    }, -- min per bullet stored
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 75, 105, 135 })[level] +
            (0.45 * source.totalDamage) + (1 + (0.50 * source.critChance)) * (0.02 * (getPercentHP(target)))
      end
    }, -- max per bullet stored
    {
      Slot = "R",
      Stage = 3,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 125, 210, 315 })[level] +
            (({ 75, 90, 105 })[level] / 100 * source.totalDamage) +
            (1 + (0.50 * source.critChance)) * (0.02 * (getPercentHP(target)))
      end
    }, -- minimum charged damage
  },

  ["Alistar"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + 0.8 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 55, 110, 165, 220, 275 })
            [level] + 1 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + 0.4 * source.ap
      end
    },
  },

  ["Amumu"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 95, 112080, 145, 170 })
            [level] + 0.85 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 7, 7, 7, 7, 7 })[level] +
            (({ 0.5, 0.625, 0.75, 0.875, 1 })[level] / 100 + (0.25 * math.floor(source.ap / 100)) * target.maxHealth)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 65, 100, 135, 170, 205 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            0.80 * source.ap
      end
    },
  },

  ["Anivia"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 70, 90, 110, 130 })
            [level] + 0.25 * source.ap
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 95, 130, 165, 200 })
            [level] + 0.45 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 50, 80, 110, 140, 170 })[level] + 0.6 * source.ap) *
            (Buff:GetBuffCount(target, "aniviachilled") and 2 or 1)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 45, 60 })[level] +
            0.125 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 135, 180 })[level] +
            0.375 * source.ap
      end
    },
  },

  ["Annie"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.75 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 115, 160, 205, 250 })
            [level] + 0.85 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 275, 400 })[level] +
            0.75 * source.ap
      end
    },
  },

  ["Aphelios"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 60, 76.67, 76.67, 93.33, 93.33, 110, 110, 126.67, 126.67, 143.33, 143.33, 160, 160, 160, 160, 160, 160 })
            [source.levelData.lvl] + source.ap +
            ({ 0.42, 0.42, 0.45, 0.45, 0.48, 0.48, 0.51, 0.51, 0.54, 0.54, 0.57, 0.57, 0.60, 0.60, 0.60, 0.60, 0.60, 0.60 })
            [myHero.levelData.lvl] * source.bonusDamage
      end
    }, --Calibrum
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 10, 15, 15, 20, 20, 25, 25, 30, 30, 35, 35, 40, 40, 40, 40, 40, 40 })
            [source.levelData.lvl] +
            ({ 0.20, 0.20, 0.225, 0.225, 0.255, 0.255, 0.275, 0.275, 0.30, 0.30, 0.325, 0.325, 0.35, 0.35, 0.35, 0.35, 0.35, 0.35 })
            [myHero.levelData.lvl] * source.bonusDamage
      end
    }, --Severum
    {
      Slot = "Q",
      Stage = 3,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 50, 60, 60, 70, 70, 80, 80, 90, 90, 100, 100, 110, 110, 110, 110, 110, 110 })
            [source.levelData.lvl] + 0.7 * source.ap +
            ({ 0.26, 0.26, 0.275, 0.275, 0.29, 0.29, 0.305, 0.305, 0.32, 0.32, 0.335, 0.335, 0.35, 0.35, 0.35, 0.35, 0.35, 0.35 })
            [myHero.levelData.lvl] * source.bonusDamage
      end
    }, --Gravitum
    {
      Slot = "Q",
      Stage = 4,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 25, 25, 31.67, 31.67, 38.33, 38.33, 45, 45, 51.67, 51.67, 58.33, 58.33, 65, 65, 65, 65, 65, 65 })
            [source.levelData.lvl] + 0.7 * source.ap +
            ({ 0.56, 0.56, 0.6, 0.6, 0.64, 0.64, 0.68, 0.68, 0.72, 0.72, 0.76, 0.76, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8 })
            [myHero.levelData.lvl] * source.bonusDamage
      end
    }, --Infernum
    {
      Slot = "Q",
      Stage = 5,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 31, 31, 42.5, 42.5, 54, 54, 65.5, 65.5, 77, 77, 88.5, 88.5, 100, 100, 100, 100, 100, 100 })
            [source.levelData.lvl] + 0.5 * source.ap +
            ({ 0.40, 0.40, 0.4333, 0.4333, 0.4667, 0.4667, 0.5, 0.5, 0.5333, 0.5333, 0.5667, 0.5667, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6 })
            [myHero.levelData.lvl] * source.bonusDamage
      end
    }, --Crescendum
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 125, 175, 225 })[level] +
            source.ap + 0.2 * source.bonusDamage +
            (gotSpell(_Q, "ApheliosCalibrumQ") * (({ 40, 70, 100 })[level] * source.bonusDamage))
      end
    }, --Calibrum
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 125, 175, 225 })[level] +
            source.ap + 0.2 * source.bonusDamage
      end
    }, --Severum
    {
      Slot = "R",
      Stage = 3,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 125, 175, 225 })[level] +
            source.ap + 0.2 * source.bonusDamage
      end
    }, --Gravitum
    {
      Slot = "R",
      Stage = 4,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 125, 175, 225 })[level] +
            source.ap + 0.2 * source.bonusDamage +
            (gotSpell(_Q, "ApheliosInfernumQ") * (({ 50, 100, 150 })[level] + 0.25 * source.bonusDamage))
      end
    }, --Infernum
    {
      Slot = "R",
      Stage = 5,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 125, 175, 225 })[level] +
            source.ap + 0.2 * source.bonusDamage
      end
    }, --Crescendum
  },

  ["Ashe"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 1.05, 1.10, 1.15, 1.20, 1.25 })
            [level] * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 35, 50, 65, 80 })
            [level] + source.totalDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 400, 600 })[level] +
            1.20 + source.ap
      end
    },
    { Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({ 100, 200, 300 })[level] + 0.60 * source.ap) end }, --Splash
  },

  ["AurelionSol"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 45, 60, 75, 90, 105 })
            [level] + 0.55 * source.ap
      end
    }, --(3.75+6.25/17*(source.levelData.lvl-1))+({1.875, 3.125, 4.375, 5.625, 6.875})[level] + 0.075 * source.ap --old per tick
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        local starduststacks = Buff:GetBuffStacks(target, "AurelionSolPassive");
        return ({ 55, 65, 75, 85, 95 })[level] +
            0.30 * source.ap + (((3.1 / 100) * starduststacks) * target.maxHealth)
      end
    }, -- bonus damage --old (20+10/17*(source.levelData.lvl-1))+
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local starduststacks = Buff:GetBuffStacks(target, "AurelionSolPassive");
        return ({ 2.5, 3.75, 5, 6.25, 7.5 })
            [level] + 0.04 * source.ap
            + (0.05 + (0.026 * starduststacks) * target.maxHealth)
      end
    }, --per tick    damage to non-epic monster targets @ 5% (+ 2.6% Stardust stacks) of their maximum health are also executed
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 2.5, 3.75, 5, 6.25, 7.5 })
            [level] + 0.04 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = ({ 150, 250, 350 })[level] + 0.65 * source.ap;
        local starduststacks = Buff:GetBuffStacks(target, "AurelionSolPassive");
        if source:GetSpellData(_R).name == "AurelionSolR2" or starduststacks >= 75 then
          dmg = dmg * 1.25
        end;
        return dmg
      end
    },
    --{Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({187.5, 312.5, 437.5})[level] + 0.8125 * source.ap end}, --75 stardust stacks empowers for 25% more dmg
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.60 * source.ap
      end
    }, --AOE damage on empowered
  },

  ["Azir"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 80, 100, 120, 140 })
            [level] + 0.35 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local azirLevel = source.levelData.lvl
        local wDmg = ({ 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 7, 12, 17, 29, 41, 53, 65, 77 })(azirLevel)
        return wDmg + ({ 50, 65, 50, 95, 110 })[level] + 0.55 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + 0.40 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 400, 600 })[level] +
            0.75 * source.ap
      end
    },
  },

  ["Bard"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + 0.80 * source.ap
      end
    },
  },

  ["BelVeth"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local dmg = (({ 10, 15, 20, 25, 30 })[level] + (1.00 * source.totalDamage)); if target.type == Obj_AI_Camp then dmg = (dmg + ({ 45, 55, 65, 75, 85 })[level]) elseif target.type == Obj_AI_Minion then dmg = (dmg * (({ 60, 70, 80, 90, 100 })[level] / 100)) end; return
            dmg
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 110, 150, 190, 230 })
            [level] + (1.00 * source.bonusDamage) + (1.25 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local dmg = ({ 6, 7, 8, 9, 10 })[level] + (0.08 * source.totalDamage) * (0.03 * (getPercentHP(target))); if target.type == Obj_AI_Camp then dmg = (dmg * 1.50) end; return
            dmg
      end
    }, --minimum
    {
      Slot = "E",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        local dmg = ({ 24, 28, 32, 36, 40 })[level] +
            (0.32 * source.totalDamage) * (0.03 * (getPercentHP(target))); if target.type == Obj_AI_Camp then dmg = (dmg * 1.50) end; return
            dmg
      end
    }, --maximum over 1.5 seconds
    {
      Slot = "R",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 150, 200, 250 })[level] +
            (1.00 * source.ap) + (0.25 * getMissingHP(target))
      end
    },
  },

  ["Blitzcrank"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 105, 155, 205, 255, 305290 })
            [level] + 1.20 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local dmg = (0.80 * source.totalDamage) + (0.25 * source.ap); return dmg
      end
    }, -- if target.type == Obj_AI_Minion then dmg = (2.5 * source.totalDamage) + (1.25 * source.ap) end;
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 275, 400, 525 })[level] +
            (1.00 * source.ap)
      end
    },
  },

  ["Brand"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 100, 130, 160, 190 })
            [level] + 0.65 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local buff = Buff:HasBuff(target, "BrandAblaze"); local dmg = ({ 75, 120, 165, 210, 255 })[level] +
            0.60 * source.ap; if buff then dmg = dmg * 1.25 end; return dmg
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 175, 250 })[level] +
            0.25 * source.ap
      end
    },
  },

  ["Braum"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 125, 175, 225, 275 })
            [level] + (0.025 * source.maxHealth)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 300, 450 })[level] +
            0.6 * source.ap
      end
    },
  },

  ["Briar"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + (0.80 * source.bonusDamage) + (0.60 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 70, 80, 90, 100 })
            [level] / 100 * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 20, 35, 50, 65 })
            [level] + (0.05 * source.totalDamage) +
            (0.9 + (0.025 * math.floor(source.bonusDamage / 100)) * getMissingHP(target))
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 115, 150, 185, 220 })
            [level] + (source.bonusDamage) + (source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 220, 330, 440, 550, 660 })
            [level] + (3.40 * source.bonusDamage) + (3.4 * source.ap)
      end
    }, -- if into wall
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            (0.50 * source.bonusDamage) + (1.20 * source.ap)
      end
    },
  },

  ["Caitlyn"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 90, 130, 170, 210 })
            [level] + (({ 1.25, 1.45, 1.65, 1.85, 2.05 })[level] * source.totalDamage)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 130, 180, 230, 280 })
            [level] + (0.8 * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 300, 500, 700 })[level] +
            (1.70 * source.bonusDamage) * (1 + (math.min(source.critChance, 1) * .50))
      end
    }, -- was 0-25% based on every 10% crit
  },

  ["Camille"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 0.2, 0.25, 0.3, 0.35, 0.4 })
            [level] * source.totalDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 0.2, 0.25, 0.3, 0.35, 0.4 })
            [level] * source.totalDamage * 2
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 70, 100, 130, 160, 190 })
            [level] + 0.6 * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 70, 100, 130, 160, 190 })
            [level] + 0.6 * source.bonusDamage
            + (({ 6 / 6.5 / 7 / 7.5 / 8 })[level] / 100
              + (0.025 * math.floor(source.bonusDamage / 100)) * target.maxHealth)
      end
    },

    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + 0.90 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 30, 40 })[level] +
            ({ 0.04, 0.06, 0.08 })[level] * target.health
      end
    },
  },

  ["Cassiopeia"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 110, 145, 180, 215 })
            [level] + 0.9 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 25, 30, 35, 40 })
            [level] + 0.15 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return 48 +
            4 * source.levelData.lvl + 0.10 * source.ap +
            (hasPoison(target) and ({ 20, 40, 60, 80, 100 })[level] + 0.70 * source.ap or 0)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.5 * source.ap
      end
    },
  },

  ["Chogath"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 145, 200, 260, 320 })
            [level] + source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 135, 190, 245, 300 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local feastStacks = Buff:GetBuffStacks(source, "Feast")
        return ({ 22, 37, 52, 67, 82 })[level] + 0.30 * source.ap + ((0.03 + (0.005 * feastStacks)) * target.maxHealth)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        local dmg = ({ 300, 475, 650 })[level] + (0.50 * source.ap) + (0.10 * (getBonusHealth(source))); if target.type ~= Obj_AI_Hero then
          dmg = 1200 +
              (0.50 * source.ap) + (0.10 * (getBonusHealth(source)))
        end; return dmg
      end
    },
  },

  ["Corki"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 120, 165, 210, 255 })
            [level] + 0.50 * source.ap + 0.70 * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 15, 22.5, 30, 37.5, 45 })
            [level] + 0.15 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 8.75, 10, 11.25, 12.5, 13.75, 15, 16.25, 17.5, 20, 22.5, 25 })
            [source.levelData.lvl] + (0.50 * source.bonusDamage) + (0.06 * source.ap)
      end
    }, --Special Delivery / package
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 7.5, 10.625, 13.75, 16.875, 20 })
            [level] + 0.15 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 115, 150 })[level] +
            0.12 * source.ap + ({ 0.25, 0.50, 0.75 })[level] * source.totalDamage
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 160, 230, 300 })[level] +
            0.24 * source.ap + ({ 0.50, 1, 1.5 })[level] * source.totalDamage
      end
    },
  },

  ["Darius"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 80, 110, 140, 170 })
            [level] + (({ 1.0, 1.1, 1.2, 1.3, 1.4 })[level] * source.totalDamage)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 1.4, 1.45, 1.5, 1.55, 1.6 })
            [level] * source.totalDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 100, 200, 300 })[level] +
            0.75 * source.bonusDamage
      end
    },
  },

  ["Diana"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 95, 130, 165, 200 })
            [level] + 0.7 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 18, 30, 42, 54, 66 })
            [level] + 0.18 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 70, 90, 110, 130 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            0.6 * source.ap
      end
    },
  },

  ["DrMundo"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = (({ 20, 22.5, 25, 27.5, 30 })[level] / 100 * target.health)
        if target.type == Obj_AI_Camp then
          return math.max(({ 80, 130, 180, 230, 280 })[level],
            math.min(({ 350, 425, 500, 575, 650 })[level], dmg))
        end; return dmg
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 5, 8.75, 12.5, 16.25, 20 })
            [level]
      end
    }, --per tick/activation
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 35, 50, 65, 80 })
            [level] + (0.07 * (getBonusHealth(source)))
      end
    }, --recast/detonation
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 15, 25, 35, 45 })
            [level] +
            (0.07 * (getBonusHealth(source))) *
            (1 + math.min(0.0057 * getPercentHP(source), 0.40))
      end
    }, --Passive TODO: Move to AA table
    {
      Slot = "E",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        local dmg = (({ 5, 15, 25, 35, 45 })[level] + (0.07 * (getBonusHealth(source)))) *
            (1 + math.min(0.0057 * getPercentHP(source), 0.40))
        if target.type == Obj_AI_Minion then return dmg * 2 end; return dmg
      end
    }, --Active
  },

  ["Draven"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 45, 50, 55, 60, 65 })
            [level] + (({ 0.75, 0.85, 0.95, 1.05, 1.15 })[level] * source.bonusDamage)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 75, 110, 145, 180, 215 })
            [level] + 0.5 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 175, 275, 375 })[level] +
            ({ 1.10, 1.30, 1.50 })[level] * source.bonusDamage
      end
    },
  },

  ["Ekko"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 85, 100, 115, 130 })
            [level] + 0.3 * source.ap
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 65, 90, 115, 140 })
            [level] + 0.6 * source.ap
      end
    }, --return Q
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 75, 100, 125, 150 })
            [level] + 0.4 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 350, 500 })[level] +
            1.75 * source.ap
      end
    }
  },

  ["Elise"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = (({ 40, 75, 110, 145, 180 })[level] + (0.04 + (0.03 * math.floor(source.ap / 100))) * target.health)
        if target.type == Obj_AI_Camp then return math.min(({ 115, 175, 235, 295, 355 })[level], dmg) end; return dmg
      end
    },
    {
      Slot = "QM",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = (({ 70, 105, 140, 175, 210 })[level] + (0.08 + (0.03 * math.floor(source.ap / 100))) * getMissingHP(target))
        if target.type == Obj_AI_Camp then return math.min(({ 145, 210, 275, 340, 405 })[level], dmg) end; return dmg
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 105, 150, 195, 240 })
            [level] + 0.95 * source.ap
      end
    },
  },

  ["Evelynn"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 25, 30, 35, 40, 45 })
            [level] + 0.25 * source.ap
      end
    }, --TODO: bonus damage next 3 AA or spells
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = 0
        local mdmg = ({ 250, 300, 350, 400, 450 })[level] + 0.60 * source.ap
        if target.type == Obj_AI_Camp then dmg = dmg + mdmg end
        return dmg
      end
    }, --non-empowered
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 55, 70, 85, 100, 115 })
            [level] + (0.03 + (0.015 * math.floor(source.ap / 100))) * target.maxHealth
      end
    }, --non-empowered
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = ({ 75, 100, 125, 150, 175 })[level] + (0.04 + (0.025 * math.floor(source.ap / 100))) * target
            .maxHealth
        if target.type == Obj_AI_Camp then return math.max(25, math.min(450, dmg)) end; return dmg
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = ({ 125, 250, 375 })[level] + 0.65 * source.ap
        if getPercentHP(target) >= 30 then return dmg * 1.4 end;
        return dmg
      end
    },
  },

  ["Ezreal"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 45, 70, 95, 120 })
            [level] + 0.15 * source.ap + 1.30 * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 135, 190, 245, 300 })
            [level] + (({ 0.7, 0.75, 0.8, 0.85, 0.9 })[level] * source.ap) + 1.00 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 130, 180, 230, 280 })
            [level] + 0.75 * source.ap + 0.5 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 350, 500, 650 })[level] +
            0.9 * source.ap + 1.00 * source.bonusDamage
      end
    },
  },

  ["Fiddlesticks"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 6, 7, 8, 9, 10 })[level] /
            100 + (0.02 * math.floor(source.ap / 100)) * target.health
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 120, 180, 240, 300, 360 })
            [level] + 0.70 * source.ap + ({ 0.12, 0.145, 0.17, 0.195, 0.22 })[level] * getMissingHP(target)
      end
    }, -- full damage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.5 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 750, 1250, 1750 })
            [level] + 2.5 * source.ap
      end
    }, -- full damage
  },

  ["Fiora"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 70, 80, 90, 100, 110 })
            [level] + ({ 0.95, 1, 1.05, 1.1, 1.15 })[level] * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 110, 150, 190, 230, 270 })
            [level] + source.ap
      end
    },
  },

  ["Fizz"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 10, 25, 40, 55, 70 })
            [level] + 0.45 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 70, 90, 110, 130 })
            [level] + 0.40 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 130, 180, 230, 280 })
            [level] + 0.90 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.80 * source.ap
      end
    }, --GUPPY (<455)
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 225, 325, 425 })[level] +
            source.ap
      end
    }, --CHOMPER (455-910)
    {
      Slot = "R",
      Stage = 3,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 300, 400, 500 })[level] +
            1.20 * source.ap
      end
    }, --GIGALODON (>910)
  },

  ["Galio"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return (0.025 + (0.01 * math.floor(source.ap / 100))) *
            target.maxHealth
      end
    }, --tornado per tick/every 0.5 sec
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 30, 40, 50, 60 })
            [level] + 0.30 * source.ap
      end
    }, --recast 100%+(25% per 0.25 sec channeled)
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 130, 170, 210, 250 })
            [level] + 0.90 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.7 * source.ap
      end
    },
  },

  ["Gangplank"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 40, 70, 100, 130 })
            [level] + source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 75, 105, 135, 165, 195 })
            [level] + source.totalDamage
      end
    }, -- +ignores 40% target armour +10% if crit
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 70, 100 })[level] +
            0.1 * source.ap
      end
    }, --per wave
    {
      Slot = "R",
      Stage = 2,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 120, 210, 300 })[level] +
            0.3 * source.ap
      end
    }, --CENTER TRUE DAMAGE WITH Death's Daughter

  },

  ["Garen"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 60, 90, 120, 150 })
            [level] + 0.5 * source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 4, 8, 12, 16, 20 })
            [level] +
            ({ 0, 0.8, 1.6, 2.4, 3.2, 4, 4.8, 5.6, 6.4, 6.6, 6.6, 7, 7.2, 7.4, 7.6, 7.8, 8, 8.2 })[myHero.levelData.lvl] +
            ({ 36, 37, 38, 39, 40 })[level] / 100 * source.totalDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 150, 300, 450 })[level] +
            (({ 25, 30, 35 })[level] / 100) * getMissingHP(target)
      end
    },
  },

  ["Gnar"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 45, 85, 125, 165 })
            [level] + 1.15 * source.totalDamage
      end
    },
    {
      Slot = "QM",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 45, 90, 135, 180, 225 })
            [level] + 1.4 * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = (({ 0, 10, 20, 30, 40 })[level] + (({ 6, 8, 10, 12, 14 })[level] / 100 * target.maxHealth) * source.ap)
        if target.type == Obj_AI_Camp then return math.min(300, dmg) end; return dmg
      end
    },
    {
      Slot = "WM",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 45, 75, 105, 135, 165 })
            [level] + source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 85, 120, 155, 190 })
            [level] + (0.06 * source.maxHealth)
      end
    },
    {
      Slot = "EM",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 80, 115, 150, 185, 220 })
            [level] + (0.06 * source.maxHealth)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            source.ap + (0.5 * source.bonusDamage)
      end
    },
  },

  ["Gragas"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + (0.80 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 50, 80, 110, 140 })
            [level] + (0.07 * target.maxHealth) + (0.70 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 125, 170, 215, 260 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            0.80 * source.ap
      end
    },
  },

  ["Graves"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 45, 60, 75, 90, 105 })
            [level] + 0.8 * source.bonusDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 85, 120, 155, 190, 225 })
            [level] + ({ 0.4, 0.7, 1.0, 1.3, 1.6 })[level] * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 110, 160, 210, 260 })
            [level] + 0.6 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 275, 425, 575 })[level] +
            1.5 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 200, 320, 440 })[level] +
            1.2 * source.bonusDamage
      end
    },
  },

  ["Gwen"] = { --TODO: Center 50% true dmg conversion + Passive Thousand Cuts %hp
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 100, 130, 160, 190 })
            [level] + 0.40 * source.ap
      end
    }, --+ (0.02 + math.floor(0.016 * source.ap / 100) * target.maxHealth) end}, --min center damage
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 85, 110, 135, 160 })
            [level] + 0.35 * source.ap
      end
    },                                                                                                                      --+ (0.01 + math.floor(0.008 * source.ap / 100) * target.maxHealth) end}, --Final center damage
    { Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (15 + 0.20 * source.ap) end }, --onhit
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 35, 65, 95 })[level] +
            0.10 * source.ap + ((1 / 100) + (0.008 * math.floor(source.ap / 100) * target.maxHealth))
      end
    }, -- per needle 1st Cast
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 105, 195, 285 })[level] +
            0.30 * source.ap + ((3 / 100) + (0.024 * math.floor(source.ap / 100) * target.maxHealth))
      end
    }, -- 2nd Cast
    {
      Slot = "R",
      Stage = 3,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 175, 325, 475 })[level] +
            0.50 * source.ap + ((5 / 100) + (0.04 * math.floor(source.ap / 100) * target.maxHealth))
      end
    }, -- 3rd Cast
    {
      Slot = "R",
      Stage = 4,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 315, 585, 855 })[level] +
            0.90 * source.ap + ((9 / 100) + (0.072 * math.floor(source.ap / 100) * target.maxHealth))
      end
    }, -- Total
  },

  ["Hecarim"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 85, 110, 135, 160 })
            [level] + 0.90 * source.bonusDamage
      end
    }, --TODO: per stack +4%(+6^per100bonusAD) to 12%(+18per)
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 30, 40, 50, 60 })
            [level] + 0.2 * source.ap
      end
    }, -- per tick
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + 0.8 * source.ap
      end
    }, -- totalDamage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 45, 60, 75, 90 })
            [level] + 0.50 * source.bonusDamage
      end
    }, --happens twice
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            source.ap
      end
    },
  },

  ["Heimerdinger"] = {
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 75, 100, 125, 150 })
            [level] + 0.45 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 135, 180, 225 })
            [source:GetSpellData(_R).level] + 0.45 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + 0.6 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 200, 300 })
            [source:GetSpellData(_R).level] + 0.6 * source.ap
      end
    },
  },

  ["Hwei"] = {
    {
      Slot = "QQ",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [source:GetSpellData(_Q).level] + 0.75 * source.ap +
            (({ 4, 5, 6, 7, 8 })[source:GetSpellData(_Q).level] / 100 * target.maxHealth)
      end
    }, --TODO: hp ratio dmg capped 250 vs monsters
    {
      Slot = "QW",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level) -- Delayed 1 sec AOE	--TODO: Cap dmg 300 to monsters & 50% dmg to minions and non-epic monsters
        local dmg = (({ 80, 100, 120, 140, 160 })[level] + (0.25 * source.ap))
        local scalar = ({ 20, 23.75, 27.5, 31.25, 35 })[level]
        --(1 - target.health / target.maxHealth)
        local multiplier = scalar * (getPercentMissingHP(target) / 10)
        --if isolated or immobilized return (dmg * multiplier) else return dmg end},
        --cap at 300 vs monsters
        return (dmg * multiplier)
      end
    },
    {
      Slot = "QE",
      Stage = 3,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 140, 210, 280, 350 })
            [source:GetSpellData(_Q).level] + (0.925 * source.ap)
      end
    },
    {
      Slot = "WE",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 25, 35, 45, 55, 65 })
            [source:GetSpellData(_W).level] + (0.20 * source.ap)
      end
    }, -- for next 3 aa or spell hits
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 110, 150, 190, 230 })
            [level] + (0.60 * source.ap)
      end
    }, -- EQ, EW, EE dmg
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 230, 360, 490 })
            [level] + 0.95 * source.ap
      end
    }, --total
    {
      Slot = "R2",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })
            [level] + 0.80 * source.ap
      end
    }, --delayed 3 second AOE RPop
    {
      Slot = "Passive",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return 35 +
            (145 / 17 * (myHero.levelData.lvl - 1)) + 0.30 * source.ap
      end
    }, -- 0.85 delayed AOE, hitting damaging abil in 4 sec window proc
  },

  ["Illaoi"] = {
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 0.03, 0.035, 0.04, 0.045, 0.05 })
            [level] + (0.04 * math.floor(source.totalDamage / 100)) * target.maxHealth
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.5 * source.bonusDamage
      end
    },
  },

  ["Irelia"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 25, 45, 65, 85 })
            [level] + 0.6 * source.totalDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 25, 45, 65, 85 })
            [level] + (43 + (12 * source.levelData.lvl)) + 0.6 * source.totalDamage
      end
    }, --Minion Damage
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 25, 40, 55, 70 })
            [level] + (0.4 * source.totalDamage) + (0.4 * source.ap)
      end
    }, --Min damage
    {
      Slot = "W",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 75, 120, 165, 210 })
            [level] + (1.2 * source.totalDamage) + (1.2 * source.ap)
      end
    }, --Max damage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 125, 170, 215, 260 })
            [level] + 0.8 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 125, 250, 375 })[level] +
            0.7 * source.ap
      end
    },
  },

  ["Ivern"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 125, 170, 215, 260 })
            [level] + 0.7 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 90, 110, 130, 150 })
            [level] + 0.8 * source.ap
      end
    },
  },

  ["Janna"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 55, 90, 125, 160, 195 })
            [level] + 0.50 * source.ap
      end
    }, --min q damage + 10 / 15 / 20 / 25 / 30 (+ 10% AP) per sec of charge
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local jannalvl = source.levelData.lvl
        local wScaler = 1
        if jannalvl >= 6 then
          wScaler = 2
        elseif jannalvl >= 11 then
          wScaler = 3
        elseif jannalvl >= 16 then
          wScaler = 4
        end
        return ({ 55, 85, 115, 145, 175 })[level] + 0.50 * source.ap + (({ 20, 25, 30, 35 })[wScaler] / 100 * source.ms)
      end
    }, --movespeed janna lives again!
  },

  ["JarvanIV"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + 1.40 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + 0.8 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 200, 325, 450 })[level] +
            1.5 * source.bonusDamage
      end
    },
  },

  ["Jax"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 65, 105, 145, 185, 225 })
            [level] + source.bonusDamage + (0.6 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 75, 110, 145, 180 })
            [level] + 0.6 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 55, 80, 105, 130, 155 })
            [level] + 0.5 * source.bonusDamage
      end
    }, --min damage increases 20% per attack dodged for a max of 100% increase
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 140, 180 })[level] +
            0.7 * source.ap
      end
    },
  },

  ["Jayce"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 110, 160, 210, 260, 310 })
            [level] + 1.20 * source.bonusDamage
      end
    },
    {
      Slot = "QM",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 55, 110, 165, 220, 275, 330 })
            [level] + 1.20 * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 55, 70, 85, 100, 115 })
            [level] + 0.25 * source.ap
      end
    }, --per tick for 4x ticks
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 8.00, 10.80, 13.60, 16.40, 19.20, 22.00 })[level] / 100) *
            target.maxHealth + source.bonusDamage
      end
    },
    {
      Slot = "RM",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 25, 25, 25, 25, 25, 65, 65, 65, 65, 65, 105, 105, 105, 105, 105, 105, 145, 145 })
            [myHero.levelData.lvl] + (0.25 * source.bonusDamage)
      end
    },
  },

  ["Jhin"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 45, 70, 95, 120, 145 })
            [level] - 1 + (({ 0.44, 0.515, 0.59, 0.665, 0.74 })[level] * source.totalDamage) + 0.60 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 95, 130, 165, 200 })
            [level] + 0.50 * source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 80, 140, 200, 260 })
            [level] + (1.00 * source.totalDamage) + (1.00 * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 64, 154, 244 })[level] +
            (0.25 * source.totalDamage) + (0.03 * getPercentHP(target))
      end
    }, -- Min
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        if args then args.CriticalStrike = true end
        return ({ 128, 308, 488 })[level] +
            (0.50 * source.totalDamage) + (0.03 * getPercentHP(target))
      end
    } -- max
  },

  ["Jinx"] = {
    { Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.1 * source.totalDamage end },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 60, 110, 160, 210 })
            [level] + 1.6 * source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 120, 170, 220, 270 })
            [level] + source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local dmg = (({ 32.5, 47.5, 62.5 })[level] + (0.165 * source.bonusDamage) * (1.10 + (0.06 * math.min(math.floor(target.distance / 100), 15)))) +
            (({ 25, 30, 35 })[level] / 100 * getMissingHP(target)); return dmg
      end
    }, --Inital hit damage
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        local dmg = (({ 26, 38, 50 })[level] + (0.135 * source.bonusDamage) * (1.10 + (0.06 * math.min(math.floor(target.distance / 100), 15)))) +
            (({ 20, 24, 28 })[level] / 100 * getMissingHP(target)); if target.type == Obj_AI_Camp then
          return math.min(1200,
            dmg)
        end; return dmg
      end
    }, --AOE splash damage
  },

  ["Kaisa"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 40, 55, 70, 85, 100 })
            [level] + (0.55 * source.bonusDamage) + (0.20 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 55, 80, 105, 130 })
            [level] + (1.30 * source.totalDamage) + (0.45 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        local PlasmaStacks = Buff:GetBuffCount(target, "kaisapassivemarker");
        local EvolvedW = Buff:HasBuff(source, "KaisaWEvolved")
        local bonusdmg = 0;
        local stackdmg = 0
        local dmg = (5 + (1.0588235294118 * source.levelData.lvl)) + (0.15 * source.ap);
        if PlasmaStacks >= 1 then
          stackdmg = (1 + (0.64705882352941 * source.levelData.lvl)) + (0.15 + (0.025 * PlasmaStacks) * source.ap)
          dmg = dmg + stackdmg
        end;
        if PlasmaStacks == 3 or (EvolvedW and PlasmaStacks == 2) then
          bonusdmg = (0.15 + (0.06 * math.floor(source.ap / 100))) * getMissingHP(target);
          if target.type == Obj_AI_Camp then
            bonusdmg = math.min(400, bonusdmg)
          end;
          dmg = dmg + bonusdmg
        end;

        return dmg
      end
    }, -- passive pop damage
  },

  ["Kalista"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 85, 150, 215, 280 })
            [level] + 1.05 * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local baseDmg = (({ 14, 15, 16, 17, 18 })[level] / 100) * target.maxHealth; if Buff:GetBuffCount(target, "kalistacoopstrikeally") then
          if target.type == Obj_AI_Minion then
            if target.health <= 125 then return target.health end; return math.max(math.min(baseDmg, 75),
              ({ 100, 125, 150, 175, 200 })[level])
          end;
        end; return baseDmg
      end
    }, -- Soul-marked target calc
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local count = Buff:GetBuffCount(target, "kalistaexpungemarker");
        if count == 0 then return 0 end;
        local dmg = (({ 10, 20, 30, 40, 50 })[level] + 0.70 * source.totalDamage + 0.20 * source.ap) +
            ((count - 1) * (({ 8, 12, 16, 20, 24 })[level] + ({ 25, 30, 35, 40, 45 })[level] / 100 * source.totalDamage + 0.20 * source.ap));
        if target.type == Obj_AI_Minion then
          local monsterName = target.charName;
          if table_contains(epicMonster, monsterName) then
            dmg = dmg * 0.50;
          end;
        end;
        return dmg
      end,
    },
  },

  ["Karma"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 120, 170, 220, 270 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "Q", -- or "RQ"
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 70, 120, 170, 220, 270 })[level] + 0.70 * source.ap) +
            (({ 40, 100, 160, 220 })[source:GetSpellData(_R).level] + 0.30 * source.ap)
      end
    }, --Ult Q
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 65, 90, 115, 140 })
            [level] + 0.45 * source.ap
      end
    }, -- damage
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 130, 180, 230, 280 })
            [level] + 0.90 * source.ap
      end
    }, -- full tether damage
  },

  ["Karthus"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 45, 65, 85, 105, 125 })[level] + 0.35 * source.ap) *
            2
      end
    }, --single Target
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 45, 65, 85, 105, 125 })
            [level] + 0.35 * source.ap
      end
    }, --AOE
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 50, 70, 90, 110 })
            [level] + 0.2 * source.ap
      end
    }, --DPS not per tick deals damage every 0.25sec - toggle off deals 1 tick of damage
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 350, 500 })[level] +
            0.75 * source.ap
      end
    },
  },

  ["Kassadin"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 65, 95, 125, 155, 185 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 75, 100, 125, 150 })
            [level] + 0.80 * source.ap
      end
    },
    { Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return 20 + (0.10 * source.ap) end }, --Added AA attack damage --TODO: Move to passive
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local stacks = Buff:GetBuffCount(source, "RiftWalk")
        local stackDmg = (({ 35, 45, 55 })[level] + (0.10 * source.ap) + (0.01 * source.maxMana)) * stacks
        return ({ 70, 90, 110 })[level] + (0.50 * source.ap) + (0.02 * source.maxMana) + stackDmg
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 35, 45, 55 })[level] +
            (0.10 * source.ap) + (0.01 * source.maxMana)
      end
    }, -- bonus dmg per stack
  },

  ["Katarina"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + 0.35 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 35, 50, 65, 80 })
            [level] + (0.25 * source.ap) + (0.40 * source.totalDamage)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 25, 37.5, 50 })[level] +
            0.19 * source.ap
      end
    }, -- magical calc for 1 Dagger
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 375, 562.5, 750 })
            [level] + 2.85 * source.ap
      end
    }, --maximum single target dmg
    {
      Slot = "R",
      Stage = 3,
      DamageType = 1,
      Damage = function(source, target, level)
        return (0.16 + source.bonusDamage) +
            0.50 * source.attackSpeed
      end
    }, -- physical calc for 1 Dagger --50% per 100% bonus attack speed
  },

  ["Kayle"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + (0.60 * source.bonusDamage) + (0.50 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local elevel = source:GetSpellData(_E).level
        -- local kayleEPassive = (10 + (5 * level) + 0.10 * source.bonusDamage + 0.20 * source.ap)
        local kayleEPassive = ({ 15, 20, 25, 30, 35 })[level] + 0.10 * source.bonusDamage + 0.20 * source.ap
        local eActiveBonusDmg = (({ 8, 8.5, 9, 9.5, 10 })[level] / 100 + 0.015 * source.ap / 100) * getMissingHP(target)
        --({8, 8.5, 9, 9.5, 10})[level]/100 + (1.5/100 * math.floor(source.ap/100)) * GetMissingHP(target)
        return kayleEPassive + eActiveBonusDmg
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            source.bonusDamage + (0.70 * source.ap)
      end
    },
  },

  ["Kayn"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 75, 95, 115, 135, 155 })
            [level] + 0.85 * source.bonusDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 75, 95, 115, 135, 155 })
            [level] + 0.65 * source.bonusDamage +
            (0.6 + (0.035 * math.floor(source.bonusDamage / 100)) * target.maxHealth)
      end
    }, --darkin
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 90, 135, 180, 225, 270 })
            [level] + 1.10 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            1.50 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return (0.15 + (0.10 * math.floor(source.bonusDamage / 100)) * target.maxHealth)
      end
    }, --darkin
  },

  ["Kennen"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 125, 175, 225, 275 })
            [level] + 0.85 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 95, 120, 145, 170 })
            [level] + 0.80 * source.ap
      end
    }, --active
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 35, 45, 55, 65, 75 })
            [level] + ((({ 80, 90, 100, 110, 120 })[level] / 100) * source.bonusDamage) + (0.35 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + 0.80 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 75, 110 })[level] +
            0.225 * source.ap
      end
    }, --per Bolt
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 300, 562.5, 825 })
            [level] + 1.6875 * source.ap
      end
    }, --total single target damage
  },

  ["Khazix"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 70, 95, 120, 145, 170 })
            [level] + 1.10 * source.bonusDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 147, 199.5, 252, 304.5, 357 })
            [level] + 2.415 * source.bonusDamage
      end
    }, --isolated Target
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 85, 115, 145, 175, 205 })
            [level] + source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 65, 100, 135, 170, 205 })
            [level] + 0.20 * source.bonusDamage
      end
    },
  },

  ["KogMaw"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 140, 190, 240, 290 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = ((({ 3, 3.75, 4.50, 5.25, 6.00 })[level] / 100) * target.maxHealth) +
            (0.01 * math.floor(source.ap / 100))
        if target.type == Obj_AI_Minion or target.type == Obj_AI_Camp and dmg > 100 then dmg = 100 end;
        return dmg
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 120, 165, 210, 255 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 100, 140, 180 })[level] + 0.75 * source.bonusDamage + 0.35 * source.ap) *
            (getPercentHP(target) < 40 and 2) or (1 + math.min(0.833 * getPercentMissingHP(target), .50))
      end
    },
  },

  ["Kindred"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 40, 65, 90, 115, 140 })
            [level] + (0.75 * source.bonusDamage)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local buff = Buff:GetBuffStacks(source, "kindredmarkofthekindredstackcounter"); return ({ 25, 30, 35, 40, 45 })
            [level] + (0.20 * source.bonusDamage) + (0.20 * source.ap) + (0.015 + (0.01 * buff) * target.health)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local buff = Buff:GetBuffStacks(source, "kindredmarkofthekindredstackcounter"); return ({ 80, 100, 120, 140, 160 })
            [level] + (0.80 * source.bonusDamage) + (0.05 + (0.005 * buff) * getMissingHP(target))
      end
    },
  },

  ["Kled"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 55, 80, 105, 130 })
            [level] + 0.65 * source.bonusDamage
      end
    }, --Tether
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 110, 160, 210, 260 })
            [level] + 1.3 * source.bonusDamage
      end
    }, --Pull
    {
      Slot = "Q",
      Stage = 3,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 90, 165, 240, 315, 390 })
            [level] + 1.95 * source.bonusDamage
      end
    }, --totalDamage
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 30, 40, 50, 60 })
            [level] +
            (({ 4.5, 5, 5.5, 6, 6.5 })[level] / 100 + (0.05 * math.floor(source.bonusDamage / 100)) * target.maxHealth)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 35, 60, 85, 110, 135 })
            [level] + source.bonusDamage * 0.65
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        --0.08 * (0.16sec * spell.isChanneling.time)
        return (({ 4, 5, 6 })[level] / 100 + 0.04 * math.floor(source.bonusDamage / 100) * target.maxHealth)
      end
    },
  },

  ["KSante"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 55, 80, 105, 130 })[level]
            + (0.40 * source.totalDamage) + (0.30 * source.bonusArmor) + (0.30 * source.bonusMagicResist)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 40, 60, 80, 100 })[level]
            + (0.50 * source.totalDamage) + (0.50 * source.bonusArmor) + (0.50 * source.bonusMagicResist)
            + ((({ 6, 7, 8, 9, 10 })[level] / 100) * target.maxHealth)
      end
    }, --min
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 110, 150 })[level] + 0.65 * source.ap
      end
    }, --No wall
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 140, 220, 300 })[level] + 1.30 * source.ap
      end
    }, --Hit Wall
  },

  ["Leblanc"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 95, 120, 145, 170 })
            [level] + 0.45 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 115, 155, 195, 235 })
            [level] + 0.75 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 70, 90, 110, 130 })
            [level] + 0.40 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 220 })
            [level] + 0.80 * source.ap
      end
    }, --Det
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 140, 210 })[level] +
            0.40 * source.ap
      end
    }, -- Mimic Q
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 300, 450 })[level] +
            0.75 * source.ap
      end
    }, -- Mimic W
    {
      Slot = "R",
      Stage = 3,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 140, 210 })[level] +
            0.40 * source.ap
      end
    }, -- Mimic E
    {
      Slot = "R",
      Stage = 4,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 140, 280, 420 })[level] +
            0.80 * source.ap
      end
    }, -- Mimic E det 2x stage 3
  },

  ["LeeSin"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 55, 80, 105, 130, 155 })
            [level] + 1.15 * source.bonusDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return (({ 55, 80, 105, 130, 155 })
          [level] + 1.15 * source.bonusDamage) * (1 + 0.01 * (getPercentMissingHP(target)))
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 35, 60, 85, 110, 135 })
            [level] + source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 175, 400, 625 })[level] +
            2 * source.bonusDamage
      end
    },
  },

  ["Leona"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 10, 35, 60, 85, 110 })
            [level] + 0.3 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 55, 90, 125, 160, 195 })
            [level] + 0.4 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 90, 130, 170, 210 })
            [level] + 0.4 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 225, 300 })[level] +
            0.8 * source.ap
      end
    },
  },

  ["Lillia"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 50, 60, 70, 80 })
            [level] + 0.35 * source.ap
      end
    }, --Q Area
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 80, 100, 120, 140, 160 })
            [level] + 0.70 * source.ap
      end
    }, --Q Edge TODO: mixed damage Magical + True
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 100, 120, 140, 160 })
            [level] + 0.35 * source.ap
      end
    }, --W Area
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 240, 300, 360, 420, 480 })
            [level] + 1.05 * source.ap
      end
    }, --W Center
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 95, 120, 145, 170 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 150, 200 })[level] +
            0.40 * source.ap
      end
    },
  },

  ["Lissandra"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + 0.8 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.7 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.6 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.75 * source.ap
      end
    },
  },

  ["Lucian"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 95, 125, 155, 185, 215 })
            [level] + (({ 0.60, 0.75, 0.90, 1.05, 1.20 })[level] * source.bonusDamage)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 110, 145, 180, 215 })
            [level] + 0.90 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 30, 45 })[level] +
            (0.15 * source.ap) + (0.25 * source.totalDamage)
      end
    }, --per Shot
  },

  ["Lulu"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 170, 215, 260 })
            [level] + 0.50 * source.ap
      end
    },
  },

  ["Lux"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + 0.65 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 65, 115, 165, 215, 265 })
            [level] + 0.80 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 300, 400, 500 })[level] +
            1.20 * source.ap
      end
    },
  },

  ["Malphite"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 120, 170, 220, 270 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 40, 50, 60, 70 })
            [level] + 0.20 * source.ap + 0.15 * source.armor
      end
    }, --TODO: On hit
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 110, 150, 190, 230 })
            [level] + 0.60 * source.ap + 0.40 * source.armor
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            0.90 * source.ap
      end
    },
  },

  ["Malzahar"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.55 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 12, 14, 16, 18, 20 })
            [level] + (0.2 * source.ap) + (0.4 * source.bonusDamage) + (5 + 3.5 * source.levelData.lvl)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 115, 150, 185, 220 })
            [level] + 0.8 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 125, 200, 275 })[level] +
            0.8 * source.ap
      end
    }, -- total damage
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 10, 15, 20 })[level] / 100 + (0.025 * math.floor(source.ap / 100))) *
            target.maxHealth
      end
    }, -- null zone damage
  },

  ["Maokai"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 65, 115, 165, 215, 265 })
            [level] + (0.40 * source.ap) + (({ 2.00, 2.5, 3, 3.5, 4.00 })[level] / 100 * target.maxHealth)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 85, 110, 135, 160 })
            [level] + 0.40 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 75, 100, 125, 150 })
            [level] + (0.45 * source.ap) + (0.006 * (getBonusHealth(source)))
      end
    }, --Normal
    --{Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (2 * ({25, 50, 75, 100, 125})[level] + (({0.07, 0.0725, 0.075, 0.0775, 0.08})[level] + (0.008*source.ap)) * target.maxHealth) end}, --Bush saplings
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 55, 80, 105, 130, 155 })
            [level] + (0.40 * source.ap) + (0.006 * (getBonusHealth(source))) * 2
      end
    }, --Bush saplings just x2 now
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 225, 300 })[level] +
            0.75 * source.ap
      end
    },
  },

  ["MasterYi"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 60, 90, 120, 150 })
            [level] + 0.50 * source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 20, 25, 30, 35, 40 })
            [level] + 0.30 * source.bonusDamage
      end
    },
  },

  ["Milio"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 145, 210, 275, 340 })
            [level] + (1.20 * source.ap)
      end
    },
  },

  ["MissFortune"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 45, 70, 95, 120 })
            [level] + (0.35 * source.ap) + source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 8.75, 12.50, 16.25, 20.00, 23.75 })
            [level] + 0.15 * source.ap
      end
    }, --per tick
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 100, 130, 160, 190 })
            [level] + 1.20 * source.ap
      end
    }, --max damage
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (0.75 * source.totalDamage) +
            (0.25 * source.ap)
      end
    }, -- each wave
  },

  ["MonkeyKing"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 45, 70, 95, 120 })
            [level] + 0.55 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 0.01, 0.015, 0.02 })
            [level] * target.maxHealth + ((34.375 / 100) * source.totalDamage)
      end
    }, --Per Tick
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 0.08, 0.12, 0.16 })
            [level] * target.maxHealth + (2.75 * source.totalDamage)
      end
    }, --Total
  },

  ["Mordekaiser"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 95, 115, 135, 155 })
            [level] + ({ 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 51, 61, 71, 81, 91, 107, 123, 139 })
            [source.levelData.lvl] +
            (0.70 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 85, 100, 115, 130 })
            [level] + 0.60 * source.ap
      end
    },
  },

  ["Morgana"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 135, 190, 245, 300 })
            [level] + 0.90 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 6, 11, 16, 21, 26 })
            [level] + (0.085 * source.ap) * (0.017 * (getPercentMissingHP(target)))
      end
    }, -- per tick
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 110, 160, 210, 260 })
            [level] + (0.85 * source.ap) * (0.017 * (getPercentMissingHP(target)))
      end
    }, -- minimum fullDmg
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 175, 250, 325 })[level] +
            0.80 * source.ap
      end
    },
  },

  ["Naafiri"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 35, 45, 55, 65, 75 })
            [level] + 0.20 * source.bonusDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 45, 60, 75, 90 })
            [level] + (0.40 * source.bonusDamage) * (0.01 * (getPercentMissingHP(target)))
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 70, 110, 150, 190 })
            [level] + 0.80 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 95, 140, 185, 230, 275 })
            [level] + 1.30 * source.bonusDamage
      end
    }, --dash + aoe flurry
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 15, 25 })[level] +
            (({ 8, 16, 24 })[level] / 100 * source.totalDamage)
      end
    },
  },

  ["Nami"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 145, 200, 255, 310 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 95, 130, 165, 200 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 30, 40, 50, 60 })
            [level] + 0.20 * source.ap
      end
    }, --per tick
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.60 * source.ap
      end
    },
  },

  ["Nasus"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return Buff:GetBuff(source,
          "nasusqstacks").stacks + ({ 40, 60, 80, 100, 120 })[level]
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 55, 95, 135, 175, 215 })
            [level] + 0.60 * source.ap
      end
    }, --initial hit
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 11, 19, 27, 35, 43 })
            [level] + 0.12 * source.ap
      end
    }, --per tick
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 3, 4, 5 })[level] / 100 + 0.01 * math.floor(source.ap / 100)) *
            target.maxHealth
      end
    },
  },

  ["Nautilus"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 115, 160, 205, 250 })
            [level] + 0.9 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 40, 50, 60, 70 })
            [level] + 0.4 * source.ap
      end
    }, --on AA
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 55, 85, 115, 145, 175 })
            [level] + 0.3 * source.ap
      end
    }, --per wave
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 275, 400 })[level] +
            0.8 * source.ap
      end
    }, --target damage
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 125, 175, 225 })[level] +
            0.4 * source.ap
      end
    }, --trail damage
  },

  ["Neeko"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 125, 170, 215, 260 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.65 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 350, 550 })[level] +
            1.20 * source.ap
      end
    },
  },

  ["Nilah"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (1 + math.min(1, 1 * source.critChance)) *
            (({ 5, 10, 15, 20, 25 })[level] + (({ 0.90, 0.95, 1.00, 1.05, 1.10 })[level] * source.totalDamage))
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 65, 90, 115, 140, 165 })
            [level] + (0.20 * source.totalDamage)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 30, 45 })[level] +
            (0.20 * source.bonusDamage)
      end
    }, -- per 0.25sec tick
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 120, 180 })[level] +
            (0.80 * source.bonusDamage)
      end
    }, -- max over 1 sec
    {
      Slot = "R",
      Stage = 3,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 125, 225, 325 })[level] +
            (1.20 * source.bonusDamage)
      end
    }, -- Burst
    {
      Slot = "R",
      Stage = 4,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 185, 345, 505 })[level] +
            (2.00 * source.bonusDamage)
      end
    }, -- total
  },

  ["Nidalee"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 90, 110, 130, 150 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "QM",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = (({ 5, 30, 55, 80 })[source:GetSpellData(_R).level] + 0.75 * source.totalDamage + 0.40 * source.ap) *
            (1 + (({ 1, 1.25, 1.5, 1.75 })[source:GetSpellData(_R).level] / 100) * getPercentHP(target))
        dmg = dmg * (Buff:HasBuff(target, "nidaleepassivehunted") and 1.3 or 1)
        return dmg
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 80, 120, 160, 200 })
            [level] + 0.20 * source.ap
      end
    },
    {
      Slot = "WM",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 110, 160, 210 })
            [source:GetSpellData(_R).level] + 0.30 * source.ap
      end
    },
    --{Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({80, 140, 200, 260})[source:GetSpellData(_R).level] + 0.45 * source.ap end},
    {
      Slot = "EM",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 140, 200, 260 })
            [source:GetSpellData(_R).level] + 0.40 * source.bonusDamage + 0.45 * source.ap
      end
    },
  },

  ["Nocturne"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 65, 110, 155, 200, 245 })
            [level] + 0.85 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 125, 170, 215, 260 })
            [level] + source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 150, 275, 400 })[level] +
            1.2 * source.bonusDamage
      end
    },
  },

  ["Nunu"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = ({ 60, 100, 140, 180, 220 })[level] + (0.65 * source.ap) +
            (0.05 * (getBonusHealth(source)))
        if target.type ~= Obj_AI_Hero then dmg = ({ 340, 500, 660, 820, 980 })[level] end; return dmg
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 36, 45, 54, 63, 72 })
            [level] + 0.30 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 16, 24, 32, 40, 48 })
            [level] + 0.15 * source.ap
      end
    }, --per Snowbal
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 625, 950, 1275 })[level] +
            3.0 * source.ap
      end
    },
  },

  ["Olaf"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local monsterdmg = target.type == Obj_AI_Camp and ({ 10, 25, 40, 55, 70 })[level] or 0
        return ({ 65, 115, 165, 215, 265 })
            [level] + source.bonusDamage + monsterdmg
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 70, 115, 160, 205, 250 })
            [level] + 0.5 * source.totalDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 20, 25 })[level] +
            0.25 * source.totalDamage
      end
    },

  },

  ["Orianna"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 120, 170, 220, 270 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + 0.30 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 250, 400, 550 })[level] +
            0.95 * source.ap
      end
    },
  },

  ["Ornn"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 45, 70, 95, 120 })
            [level] + 1.1 * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 0.12, 0.13, 0.14, 0.15, 0.16 })
            [level] * target.maxHealth
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 80, 125, 170, 215, 260 })
            [level] + (0.4 * source.bonusArmor) + (0.4 * source.bonusMagicResist)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 125, 175, 225 })[level] +
            0.2 * source.ap
      end
    },
  },

  ["Pantheon"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 70, 100, 130, 160, 190 })
            [level] + 1.15 * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 55, 105, 155, 205, 255 })
            [level] + 1.5 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 300, 500, 700 })[level] +
            source.ap
      end
    },
  },

  ["Poppy"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 40, 60, 80, 100, 120 })
            [level] + (0.9 * source.bonusDamage) + (0.08 * target.maxHealth)
      end
    }, --initial
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + (1.8 * source.bonusDamage) + (0.16 * target.maxHealth)
      end
    }, --totalDamage
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 110, 150, 190, 230 })
            [level] + 0.7 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 80, 100, 120, 140 })
            [level] + 0.5 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 120, 160, 200, 240, 280 })
            [level] + source.bonusDamage
      end
    }, --Target collide with terrain
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 100, 150, 200 })[level] +
            0.45 * source.bonusDamage
      end
    }, --quick cast, releasing within 0.5 secs
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            0.9 * source.bonusDamage
      end
    }, --full cast, releasing after 0.5 secs
  },

  ["Pyke"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 85, 135, 185, 235, 285 })
            [level] + 0.75 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 100, 150, 200, 250, 300 })
            [level] + source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local heroLevel = myHero.levelData.lvl; return ({ 250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550 })
            [heroLevel] + (0.8 * source.bonusDamage) + 1.5 * source.armorPen
      end
    },
  },

  ["Qiyana"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 85, 120, 155, 190 })
            [level] + 0.75 * source.bonusDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 80, 136, 192, 248, 304 })
            [level] + 1.20 * source.bonusDamage
      end
    }, --Terrain Damage
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 8, 22, 36, 50, 64 })
            [level] + (0.10 * source.bonusDamage) + (0.45 * source.ap)
      end
    }, --Passive
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 90, 130, 170, 210 })
            [level] + 0.50 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 100, 200, 300 })[level] +
            (1.70 * source.bonusDamage) + (0.10 * target.maxHealth)
      end
    },
  },

  ["Quinn"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 40, 60, 80, 100 })
            [level] + (({ 0.8, 0.9, 1.0, 1.1, 1.2 })[level] * source.totalDamage) + (0.5 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 40, 65, 90, 115, 140 })
            [level] + 0.20 * source.bonusDamage
      end
    },
    { Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 0.4 * source.totalDamage end },
  },

  ["Rakan"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 115, 160, 205, 250 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 125, 180, 235, 290 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 200, 300 })[level] +
            0.50 * source.ap
      end
    },
  },

  ["Rammus"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + 1.00 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 175, 250 })[level] +
            (0.6 * source.ap)
      end
    }, -- impact
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 175, 250 })[level] +
            (0.6 * source.ap) + (({ 100, 130, 160, 190, 220 })[source:GetSpellData(_Q).level] + source.ap)
      end
    }, -- center impact
  },

  ["Reksai"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 35, 40, 45, 50 })
            [level] / 100 * source.totalDamage
      end
    }, --UNBORROWED
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 80, 110, 140, 170 })
            [level] + (0.25 * source.bonusDamage) + (0.80 * source.ap)
      end
    }, --BORROWED
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 10, 15, 20, 25 })
            [level] / 100
      end
    }, --UNBORROWED MS
    {
      Slot = "W",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 75, 100, 125, 150 })
            [level] + (0.80 * source.ap)
      end
    },                                                                                                                          --BORROWED
    { Slot = "E", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (1.00 * source.totalDamage) end }, --UNBORROWED
    {
      Slot = "E",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return (1.00 * source.totalDamage) +
            ({ 8, 9.5, 11, 12.5, 14 })[level] / 100 * target.maxHealth
      end
    }, --UNBORROWED MAX FURY
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 150, 300, 450 })[level] +
            (1.00 * source.bonusDamage) + ({ 25, 30, 35 })[level] / 100 * getMissingHP(target)
      end
    },
  },

  ["Rell"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + 0.60 * source.ap
      end
    },
    --[[     {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 170, 245, 320, 395, 470 })
            [level]
      end
    }, -- bonus damage to monsters ]]
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + 0.60 * source.ap
      end
    }, -- if mounted
    --[[     {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 125, 150, 175, 200, 225 })
            [level]
      end
    }, -- bonus damage to monsters ]]
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 25, 35, 45, 55, 65 })
            [level] + 0.50 * source.ap + 0.003 * target.maxHealth
      end
    },
    --[[     {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 120, 165, 210, 255, 300 })
            [level]
      end
    }, -- bonus damage to monsters ]]
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 120, 200, 280 })[level] +
            1.10 * source.ap
      end
    }, --totalDamage per target
  },

  ["Renekton"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + 1.00 * source.bonusDamage
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 90, 135, 180, 225, 270 })
            [level] + 1.40 * source.bonusDamage
      end
    }, --REIGN OF ANGER
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 40, 70, 100, 130 })
            [level] + 1.50 * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 60, 105, 150, 195 })
            [level] + 2.25 * source.totalDamage
      end
    }, --REIGN OF ANGER
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 80, 140, 200, 260, 360 })
            [level] + 1.80 * source.bonusDamage
      end
    }, --both
    {
      Slot = "E",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 110, 185, 260, 335, 410 })
            [level] + 2.25 * source.totalDamage
      end
    }, --REIGN OF ANGER
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 60, 70 })[level] +
            0.05 * source.ap + 0.05 * source.bonusDamage
      end
    }, --per half Second
  },

  ["Rengar"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 60, 90, 120, 150 })
            [level] + ((({ 0, 3.75, 7.5, 11.25, 15 })[level] / 100) * source.totalDamage)
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 45, 60, 75, 90, 105, 120, 135, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240 })
            [source.levelData.lvl] + 0.30 * source.totalDamage
      end
    }, --EMPOWERED ACTIVE
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 80, 110, 140, 170 })
            [level] + 0.8 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return (40 + 10 * source.levelData.lvl) +
            0.8 * source.ap
      end
    }, --EMPOWERED ACTIVE
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 55, 100, 145, 190, 235 })
            [level] + 0.8 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return (35 + 15 * source.levelData.lvl) +
            0.8 * source.bonusDamage
      end
    }, --EMPOWERED ACTIVE
    { Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (0.5 * source.bonusDamage) end },
  },

  ["Riven"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 35, 55, 75, 95 })
            [level] + ((({ 50, 55, 60, 65, 70 })[level] / 100) * source.totalDamage)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 55, 85, 115, 145, 175 })
            [level] + source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (({ 100, 150, 200 })[level] + 0.60 * source.bonusDamage) *
            math.max(0.02667 * math.min(100 - getPercentHP(target), 75), 2)
      end
    },
  },

  ["Rumble"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 125, 140, 155, 170, 185 })
            [level] + 1.10 * source.ap + ({ 6, 7, 8, 9, 10 })[level] * target.maxHealth
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 202.5, 225, 247.5, 270, 292.5 })
            [level] + 1.65 * source.ap + ({ 9, 10.5, 12, 13.5, 15 })[level] * target.maxHealth
      end
    }, --enhanced
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 85, 110, 135, 160 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 127.5, 165, 202.5, 240 })
            [level] + 0.75 * source.ap
      end
    }, --enhanced
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140 })[level] +
            0.175 * source.ap
      end
    }, --per half Second
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 840, 1260, 1680 })
            [level] + 2.1 * source.ap
      end
    }, --full Damage
  },

  ["Ryze"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 90, 110, 130, 150 })
            [level] + (0.55 * source.ap) +
            0.02 * (source.maxMana - getBaseMana(source)) * Buff:GetBuffCount(target, "RyzeE") and
            (1 + (10 + ((30 * source:GetSpellData(_R).level) + 100) / 100)) or 1.1
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + (0.70 * source.ap) + 0.04 * (source.maxMana - getBaseMana(source))
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + (0.50 * source.ap) + 0.02 * (source.maxMana - getBaseMana(source))
      end
    },
  },

  ["Samira"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 0, 5, 10, 15, 20 })
            [level] + ({ 0.85, 0.95, 1.05, 1.5, 1.25 })[level] * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 35, 50, 65, 80 })
            [level] + 0.8 * source.bonusDamage
      end
    }, -- 1 Hit
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 60, 70, 80, 90 })
            [level] + 0.2 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 150, 250 })[level] +
            5 * source.totalDamage
      end
    }, -- Full Damage over 2.277 seconds
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 15, 25 })[level] +
            0.5 * source.totalDamage
      end
    }, -- per shot Damage
  },

  ["Sejuani"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 140, 190, 240, 290 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 5, 15, 25, 35, 45 })
            [level] + (0.20 * source.ap) + (0.04 * source.maxHealth)
      end
    }, --swing
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 5, 25, 45, 65, 85 })
            [level] + (0.60 * source.ap) + (0.08 * source.maxHealth)
      end
    }, --lash
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 55, 105, 155, 205, 255 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            0.8 * source.ap
      end
    },
  },

  ["Senna"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 60, 90, 120, 150 })[level] + 0.40 * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 70, 115, 160, 205, 250 })
            [level] + 0.7 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 250, 400, 550 })[level] +
            source.bonusDamage + (0.7 * source.ap)
      end
    },
  },

  ["Seraphine"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 85, 110, 135, 160 })
            [level] + (0.60 * source.ap) * (1 + (0.06 * (math.min(getMissingHP(target), 75) / 7.5)))
      end
    }, --min damage
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 96, 136, 176, 216, 256 })
            [level] + (0.96 * source.ap) * (1 + (0.06 * (math.min(getMissingHP(target), 75) / 7.5)))
      end
    }, --enchanced dmg
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 100, 130, 160, 190 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 200, 250 })[level] +
            0.40 * source.ap
      end
    },
  },

  ["Sett"] = {
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 80, 100, 120, 140, 160 })
            [level] + (25 + (0.25 / 100 * source.bonusDamage) * source.maxMana / 100)
      end
    }, -- with expended Grit
    --{Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + 0.1 * source.bonusDamage end}, -- without expended Grit
    {
      Slot = "W",
      Stage = 2,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 80, 100, 120, 140, 160 })
            [level] + (25 + (0.25 / 100 * source.bonusDamage) * source.maxMana / 100)
      end
    }, -- True Damage with expended Grit
    --{Slot = "W", Stage = 2, DamageType = 3, Damage = function(source, target, level) return ({80, 100, 120, 140, 160})[level] + 0.1 * source.bonusDamage end}, -- True Damage without expended Grit
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 70, 90, 110, 130 })
            [level] + 0.6 * source.totalDamage
      end
    },
    --{Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({200, 300, 400})[level] + (1.2 * source.bonusDamage) + ({40, 50, 60})[level] / 100 * source.bonusHealth end}, -- with Target BonusHealth when GameObject.bonusHealth becomes a thing
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            (1.2 * source.bonusDamage) + ((({ 40, 50, 60 })[level] / 100) * (getBonusHealth(source)))
      end
    },
  },

  ["Shaco"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 25, 35, 45, 55, 65 })
            [level] + 0.60 * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 10, 1540, 20, 25, 30 })
            [level] + 0.12 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 25, 40, 55, 70, 85 })
            [level] + 0.18 * source.ap
      end
    }, -- if 1 target
    { Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (getPercentHP(target) < 30 and ({ 105, 142.5, 180, 217.5, 255 })[level] + (0.90 * source.ap) + (1.125 * source.bonusDamage) or ({ 70, 95, 120, 145, 170 })[level] + (0.60 * source.ap) + (0.75 * source.bonusDamage)) end },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 225, 300 })[level] +
            0.7 * source.ap
      end
    },
  },

  ["Shen"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = ({ 2, 2.5, 3, 3.5, 4 })[level] / 100 + (0.015 * math.floor(source.ap / 100)) * target.maxHealth; if target.type == Obj_AI_Hero then
          return
              dmg
        end; return math.min(({ 30, 50, 70, 90, 110 })[level] + dmg, ({ 75, 100, 125, 150, 175 })[level])
      end
    }, -- baseDamage
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = ({ 4, 4.5, 5, 5.5, 6 })[level] / 100 + (0.02 * math.floor(source.ap / 100)) * target.maxHealth; if target.type == Obj_AI_Hero then
          return
              dmg
        end; return math.min(({ 30, 50, 70, 90, 110 })[level] + dmg, ({ 75, 100, 125, 150, 175 })[level])
      end
    }, -- enhanced if collided with champion
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 85, 110, 135, 160 })
            [level] + 0.15 * (source.maxHealth - (540 + (85 * (source.levelData.lvl - 1))))
      end
    },
  },

  ["Shyvana"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (({ 20, 40, 60, 80, 100 })[level] / 100 * source.totalDamage) +
            (0.25 * source.ap)
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return (1 * source.totalDamage) +
            (0.50 * source.ap)
      end
    }, --Dragon Form
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 10, 15, 20, 25, 30 })
            [level] + (0.10 * source.bonusDamage)
      end
    }, --per Second
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + (0.90 * source.ap) + (0.40 * source.totalDamage)
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        local lvldmg = ({ 75, 75, 75, 75, 75, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135 })
            [source.levelData.lvl]
        return (lvldmg) + ({ 60, 100, 140, 180, 220 })[level] + source.ap + (0.6 * source.totalDamage)
      end
    }, --Dragon Form per Second
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            1.30 * source.ap
      end
    },
  },

  ["Singed"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 5, 7.5, 10, 12.5, 15 })
            [level] + 0.10 * source.ap
      end
    }, --per 0.25 second over 2 seconds
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 65, 80, 95, 110 })
            [level] + (0.75 * source.ap) + (({ 6, 6.5, 7, 7.5, 8 })[level] / 100 * target.maxHealth)
      end
    },
  },

  ["Sion"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 40, 60, 80, 100, 120 })
            [level] + (({ 40, 50, 60, 70, 80 })[level] / 100 * source.totalDamage)
      end
    }, -- min damage
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 90, 155, 220, 285, 350 })
            [level] + (({ 120, 150, 180, 210, 240 })[level] / 100 * source.totalDamage)
      end
    }, -- max damage
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 65, 90, 115, 140 })
            [level] + (0.40 * source.ap) + (({ 10, 11, 12, 13, 14 })[level] / 100 * target.maxHealth)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 65, 100, 135, 170, 205 })
            [level] + (0.55 * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 150, 300, 450 })[level] +
            (0.40 * source.bonusDamage)
      end
    }, --min damage
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 400, 800, 1200 })[level] +
            (0.80 * source.bonusDamage)
      end
    }, --max damage after channeling for atleast 3 seconds
  },

  ["Sivir"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (1 + math.min(1, 0.5 * source.critChance)) *
            ({ 15, 30, 45, 60, 75 })[level] + (({ 80, 85, 90, 95, 100 })[level] / 100 * source.totalDamage) +
            (0.6 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local dmg = ({ 30, 35, 40, 45, 50 })[level] / 100 * source.totalDamage; if target.type == Obj_AI_Minion then
          dmg = 0.65 * dmg; if target.health - dmg < 15 then dmg = target.health; end;
        end; return dmg
      end
    },
  },

  ["Skarner"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 20, 30, 40, 50 })[level]
            + (0.60 * source.bonusDamage)
            + (0.05 * getBonusHealth(source))
      end
    }, --AA
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 20, 30, 40, 50 })[level]
            + (0.60 * source.bonusDamage)
            + (0.05 * getBonusHealth(source))
            + (0.15 * target.maxHealth)
      end
    }, --3rdAA Slam/Throw
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 70, 90, 110, 130 })[level]
            + (0.80 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 60, 90, 120, 150 })[level]
            + (0.10 * source.maxHealth)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level]
            + 1.00 * source.ap
      end
    },
  },

  ["Smolder"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (({ 15, 25, 35, 45, 55 })[level] + (1.00 * source.totalDamage) + (0.15 * source.ap)) *
            (0.50 * source.critChance)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 80, 110, 140, 170 })
            [level] + (0.25 * source.totalDamage) + (0.20 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        local dragonstacks = Buff:GetBuffStacks(source, "SmoulderQPassive");
        local eAtive = Buff:GetBuffStacks(source, "SmoulderE");

        return (({ 15, 20, 25, 30, 35 })[level] + (0.10 * source.totalDamage)) *
            (5 + (0.75 * math.floor(dragonstacks / 100)))
      end
    }, --
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            (1.10 * source.bonusDamage) + (1.00 * source.ap)
      end
    }, --damage +50% in center
  },

  ["Sona"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 80, 110, 140, 170 })
            [level] + (0.40 * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            (0.50 * source.ap)
      end
    },
  },

  ["Soraka"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 85, 120, 155, 190, 225 })
            [level] + (0.35 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 95, 120, 145, 170 })
            [level] + (0.4 * source.ap)
      end
    },
  },

  ["Swain"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 65, 85, 105, 125, 1445 })
            [level] + (0.40 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 115, 150, 185, 220 })
            [level] + (0.55 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 35, 70, 105, 140, 175 })
            [level] + (0.25 * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 40, 60 })[level] +
            (0.10 * source.ap)
      end
    }, --per Second
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 225, 300 })[level] +
            (0.60 * source.ap)
      end
    }, --detonation
  },

  ["Sylas"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 60, 80, 100, 120 })
            [level] + 0.40 * source.ap
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 125, 180, 235, 290 })
            [level] + 0.90 * source.ap
      end
    }, --detonation after 0.6
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 65, 100, 135, 170, 205 })
            [level] + 0.80 * source.ap
      end
    },
    -- no longer used {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({97, 150, 202, 255, 307})[level] + 0.97 * source.ap end},--if Target below 40%
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 130, 180, 230, 280 })
            [level] + source.ap
      end
    },
    { Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return 0 end }, --Hijacked abilities that do not scale with AP have their AD | AD ratios converted to AP ratios, scaling with 0.6% AP per 1% total AD, and 0.4% AP per 1% bonus AD.
    {
      Slot = "R",
      Stage = 2,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 300, 475, 650 })[level] +
            0.5 * source.ap + 0.1 * (getBonusHealth(source))
      end
    },                                                                                                                                                                --cho'garh
    { Slot = "R", Stage = 3, DamageType = 2, Damage = function(source, target, level) return (({ 200, 400, 600 })[level] + source.ap) end },                          --ashe
    { Slot = "R", Stage = 4, DamageType = 2, Damage = function(source, target, level) return (({ 175, 250, 325 })[level] + 0.75 * source.ap) end },                   --vaiger
    { Slot = "R", Stage = 5, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 0.8 * source.ap) end },                    --leona
    { Slot = "R", Stage = 6, DamageType = 2, Damage = function(source, target, level) return (({ 350, 500, 650 })[level] + 0.9 * source.ap + 0.45 * source.ap) end }, --ezreal
    {
      Slot = "R",
      Stage = 7,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 25, 35, 45 })[level] /
            100 * 0.7 + (({ 0.25, 0.30, 0.35 })[level] * getMissingHP(target)) + 0.15 * source.bonusDamage / 100 * 0.5
      end
    },                                                                                                                                                --jinx
    { Slot = "R", Stage = 8,  DamageType = 2, Damage = function(source, target, level) return (({ 250, 400, 550 })[level] + 0.75 * source.ap) end },  --kartus
    { Slot = "R", Stage = 9,  DamageType = 2, Damage = function(source, target, level) return (({ 200, 300, 400 })[level] + 0.733 * source.ap) end }, --ziggs
    { Slot = "R", Stage = 10, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 0.5 * source.ap) end },   --cassio
    { Slot = "R", Stage = 11, DamageType = 2, Damage = function(source, target, level) return (({ 300, 400, 500 })[level] + 0.75 * source.ap) end },  --lux
    { Slot = "R", Stage = 12, DamageType = 2, Damage = function(source, target, level) return (({ 300, 400, 500 })[level] + source.ap) end },         --tristana
    {
      Slot = "R",
      Stage = 13,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 60, 80 })[level] +
            0.125 * source.ap
      end
    }, --Anivia
    {
      Slot = "R",
      Stage = 14,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.7 * source.ap
      end
    },                                                                                                                                                                                                                     --AurelionSol
    { Slot = "R", Stage = 15, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 0.6 * source.ap) end },                                                                        --Braum
    { Slot = "R", Stage = 16, DamageType = 2, Damage = function(source, target, level) return (({ 125, 225, 325 })[level] + 0.7 * source.ap) end },                                                                        --Irelia
    { Slot = "R", Stage = 17, DamageType = 2, Damage = function(source, target, level) return (({ 625, 950, 1275 })[level] + 2.5 * source.ap) end },                                                                       --Nunu
    { Slot = "R", Stage = 18, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 0.6 * source.ap) end },                                                                        -- Lissandra
    { Slot = "R", Stage = 19, DamageType = 2, Damage = function(source, target, level) return (({ 125, 200, 275 })[level] + 0.8 * source.ap) end },                                                                        --Malzahar
    { Slot = "R", Stage = 20, DamageType = 2, Damage = function(source, target, level) return (({ 80, 220, 360 })[level] + 0.5 * source.bonusDamage + 0.30 * source.ap) end },                                             --Akali
    { Slot = "R", Stage = 21, DamageType = 2, Damage = function(source, target, level) return (({ 80, 220, 360 })[level] + 0.5 * source.bonusDamage + 0.30 * source.ap + 0.02 * (target.maxHealth - target.health)) end }, --Akalib
    { Slot = "R", Stage = 22, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 0.8 * source.ap) end },                                                                        --Amumu
    { Slot = "R", Stage = 23, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 450 })[level] + 0.6 * source.ap) end },                                                                        --azir
    { Slot = "R", Stage = 24, DamageType = 2, Damage = function(source, target, level) return (({ 125, 250, 375 })[level] + 0.75 * source.ap) end },                                                                       --evelynn
    { Slot = "R", Stage = 25, DamageType = 2, Damage = function(source, target, level) return (({ 250, 375, 500 })[level] + 1.0 * source.ap) end },                                                                        --blitzgrank
    { Slot = "R", Stage = 26, DamageType = 2, Damage = function(source, target, level) return (({ 175, 275, 375 })[level] / 100 * 0.7 + 0.55 * source.ap) end },                                                           -- draven
    { Slot = "R", Stage = 27, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 0.6 * source.ap) end },                                                                        --fizz
    { Slot = "R", Stage = 28, DamageType = 2, Damage = function(source, target, level) return (({ 200, 300, 400 })[level] / 100 * 0.7 + 0.1 * source.ap + 0.5 * source.ap) end },                                          -- gnar
    { Slot = "R", Stage = 29, DamageType = 2, Damage = function(source, target, level) return (({ 200, 300, 400 })[level] + 0.80 * source.ap) end },                                                                       -- gragas
    { Slot = "R", Stage = 30, DamageType = 2, Damage = function(source, target, level) return (({ 90, 125, 160 })[level] + (({ 0.15, 0.45, 0.75 })[level] * source.ap) + 0.2 * source.ap) end },                           --Corki
    { Slot = "R", Stage = 31, DamageType = 2, Damage = function(source, target, level) return (({ 250, 400, 550 })[level] / 100 * 0.7 + 0.75 * source.ap) end },                                                           -- graves
    { Slot = "R", Stage = 32, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 1.0 * source.ap) end },                                                                        --hecarim
    { Slot = "R", Stage = 33, DamageType = 2, Damage = function(source, target, level) return (({ 122, 306, 490 })[level] + 0.35 * source.ap) end },                                                                       --Jhin
    {
      Slot = "R",
      Stage = 34,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            0.6 * source.ap
      end
    },                                                                                                                                                                  -- Diana
    { Slot = "R", Stage = 35, DamageType = 2, Damage = function(source, target, level) return (({ 375, 562, 750 })[level] + 1.65 * source.ap + 2.85 * source.ap) end }, --katarina
    { Slot = "R", Stage = 36, DamageType = 2, Damage = function(source, target, level) return (({ 40, 75, 110 })[level] + 0.2 * source.ap) end },                       --Kennen
    { Slot = "R", Stage = 37, DamageType = 2, Damage = function(source, target, level) return (({ 150, 225, 300 })[level] + 0.75 * source.ap) end },                    --Maokai
    { Slot = "R", Stage = 38, DamageType = 2, Damage = function(source, target, level) return (({ 250, 400, 500 })[level] + 1.0 * source.ap) end },                     --Missfortune
    { Slot = "R", Stage = 39, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 0.6 * source.ap) end },                     --Nami
    { Slot = "R", Stage = 40, DamageType = 2, Damage = function(source, target, level) return (({ 200, 325, 450 })[level] + 0.8 * source.ap) end },                     --Nautilus
    { Slot = "R", Stage = 41, DamageType = 2, Damage = function(source, target, level) return (({ 130, 185, 240 })[level] + 0.3 * source.ap) end },                     --rumble
    { Slot = "R", Stage = 42, DamageType = 2, Damage = function(source, target, level) return (({ 100, 125, 150 })[level] + 0.4 * source.ap) end },                     --Sejuani
    { Slot = "R", Stage = 43, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + 0.5 * source.ap) end },                     --sona
    { Slot = "R", Stage = 44, DamageType = 2, Damage = function(source, target, level) return (({ 50, 175, 300 })[level] / 100 * 0.7 + 0.25 * source.ap) end },         --urgot
    { Slot = "R", Stage = 45, DamageType = 2, Damage = function(source, target, level) return (({ 150, 200, 250 })[level] + 1.0 * source.ap) end },                     --varus
    { Slot = "R", Stage = 46, DamageType = 2, Damage = function(source, target, level) return (({ 180, 265, 350 })[level] + 0.7 * source.ap) end },                     --Zyra
    { Slot = "R", Stage = 47, DamageType = 2, Damage = function(source, target, level) return (({ 175, 350, 525 })[level] / 100 * 0.7 + 0.835 * source.ap) end },       --Warwick
    { Slot = "R", Stage = 48, DamageType = 2, Damage = function(source, target, level) return (({ 100, 200, 300 })[level] + 0.3 * source.ap) end },                     --brand
    { Slot = "R", Stage = 49, DamageType = 2, Damage = function(source, target, level) return (({ 175, 350, 525 })[level]) end },                                       --Geran
    { Slot = "R", Stage = 50, DamageType = 2, Damage = function(source, target, level) return (({ 200, 300, 400 })[level] + 1.0 * source.ap) end },                     --malphite
    { Slot = "R", Stage = 51, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] + source.ap) end },                           --shyvana
    { Slot = "R", Stage = 52, DamageType = 2, Damage = function(source, target, level) return (({ 150, 225, 300 })[level] + 0.7 * source.ap) end },                     --morgana
    { Slot = "R", Stage = 53, DamageType = 2, Damage = function(source, target, level) return (({ 20, 110, 200 })[level] / 100 * 0.7 + 0.55 * source.ap) end },         --wukong
    {
      Slot = "R",
      Stage = 54,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 125, 225, 325 })[level] +
            0.45 * source.ap
      end
    }, --Fiddlesticks
    {
      Slot = "R",
      Stage = 55,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 105, 180, 255 })[level] +
            0.3 * source.ap
      end
    },                                                                                                                                                           --Gangplank
    { Slot = "R", Stage = 56, DamageType = 2, Damage = function(source, target, level) return (({ 150, 250, 350 })[level] / 100 * 0.7 + 0.55 * source.ap) end }, --Illaoi
    {
      Slot = "R",
      Stage = 57,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 325, 450 })[level] /
            100 * 0.7 + 0.75 * source.ap
      end
    }, --Jarvan
    {
      Slot = "R",
      Stage = 58,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 100, 120 })[level] +
            0.4 * source.ap + 0.02 * source.maxMana
      end
    }, --Kassadin
    {
      Slot = "R",
      Stage = 59,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 100, 140, 180 })[level] + 0.325 * source.ap + 0.25 * source.ap) *
            (getPercentHP(target) < 25 and 3 or (getPercentHP(target) < 50 and 2 or 1))
      end
    },                                                                                                                                             --Kogmaw
    { Slot = "R", Stage = 60, DamageType = 2, Damage = function(source, target, level) return (({ 70, 140, 210 })[level] + 0.4 * source.ap) end }, -- Leblanc
    {
      Slot = "R",
      Stage = 61,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 35, 50 })[level] /
            100 * 0.7 + 0.1 * source.ap + 0.25 * source.totalDamage / 100 * 0.7
      end
    }, --Lucian
    {
      Slot = "R",
      Stage = 62,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 80, 120 })[level] +
            0.2 * source.ap
      end
    }, --Rammus
    {
      Slot = "R",
      Stage = 63,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.7 * source.ap
      end
    }, --Vladimir
    {
      Slot = "R",
      Stage = 64,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 300, 525, 750 })[level] /
            100 * 0.7 + source.ap
      end
    },                                                                                                                                              --Caitlyn
    { Slot = "R", Stage = 65, DamageType = 2, Damage = function(source, target, level) return (({ 200, 425, 650 })[level] + 1.3 * source.ap) end }, --Neeko
    {
      Slot = "R",
      Stage = 66,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 225, 300 })[level] +
            0.7 * source.ap
      end
    }, --Orianna
    {
      Slot = "R",
      Stage = 67,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 70, 90 })[level] +
            0.2 * source.ap
      end
    }, --Swain
    {
      Slot = "R",
      Stage = 68,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 250, 400, 550 })[level] +
            source.ap
      end
    }, --Thresh
    {
      Slot = "R",
      Stage = 69,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 250, 475, 700 })[level] +
            1.25 * source.ap + 2.5 * source.bonusDamage
      end
    }, --Volibear
    {
      Slot = "R",
      Stage = 70,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 180, 270, 360 })[level] +
            1.05 * source.ap
      end
    }, --Ahri
    {
      Slot = "R",
      Stage = 71,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 100, 200, 300 })[level] +
            0.75 * source.ap
      end
    }, --Darius
    {
      Slot = "R",
      Stage = 72,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 300, 450 })[level] +
            1.5 * source.ap
      end
    }, --Ekko
    {
      Slot = "R",
      Stage = 73,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.7 * source.ap
      end
    }, --Galio
    {
      Slot = "R",
      Stage = 74,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 105, 262, 420 })[level] +
            source.ap
      end
    }, --LeeSin
    {
      Slot = "R",
      Stage = 75,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 105, 192, 280 })[level] +
            0.6 * source.ap
      end
    }, --Nocturne
    {
      Slot = "R",
      Stage = 76,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 350, 500 })[level] +
            0.5 * source.ap
      end
    }, --Pantheon
    {
      Slot = "R",
      Stage = 77,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 140, 210, 280 })[level] +
            0.45 * source.ap
      end
    }, --Poppy
    {
      Slot = "R",
      Stage = 78,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 200, 300 })[level] +
            0.5 * source.ap
      end
    }, --Rakan
    {
      Slot = "R",
      Stage = 79,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 175, 280 })[level] +
            source.ap + (({ 0.20, 0.25, 0.30 })[level] * (target.maxHealth - target.health))
      end
    }, --RekSai
    {
      Slot = "R",
      Stage = 80,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            source.ap
      end
    }, --Shaco
    {
      Slot = "R",
      Stage = 81,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 63, 94, 126 })[level] +
            0.5 * source.ap
      end
    }, --Talon
    {
      Slot = "R",
      Stage = 82,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 105, 210, 315 })[level] +
            0.7 * source.ap
      end
    }, --Vi
    {
      Slot = "R",
      Stage = 83,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            0.6 * source.ap
      end
    }, --Viktor
    {
      Slot = "R",
      Stage = 84,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140 })[level] +
            0.5 * source.ap
      end
    }, --Xayah
    {
      Slot = "R",
      Stage = 85,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 140, 210, 280 })[level] +
            0.75 * source.ap
      end
    }, --Yasuo
    {
      Slot = "R",
      Stage = 86,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550 })
            [source.levelData.lvl] + 0.8 * source.bonusDamage + 1.5 * source.armorPen
      end
    }, --Pyke
  },

  ["Syndra"] = {
    { Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return (({ 75, 110, 145, 180, 215 })[level] + 0.60 * source.ap) end },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local passiveStacks = Buff:GetBuffStacks(source, "syndrapassivestack");
        local dmg = ({ 70, 110, 150, 190, 230 })[level] + 0.70 * source.ap;
        if passiveStacks >= 60 then dmg = dmg + (0.12 + (0.02 * math.floor(source.ap / 100)) * dmg) end; return dmg
      end
    }, -- TODO: +12%(+2.0% per 100 ap) as bonus true damage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 115, 155, 195, 235 })
            [level] + 0.45 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local passiveStacks = Buff:GetBuffStacks(source, "syndrapassivestack");
        local spheres = source:GetSpellData(_R).ammo;
        local spheredmg = (({ 90, 130, 170 })[level] + 0.17 * source.ap);
        local mindmg = ({ 270, 390, 510 })[level] + 0.51 * source.ap
        local dmg = mindmg + spheredmg
        if spheres > 3 then
          dmg = spheredmg + spheredmg * spheres
        end
        if passiveStacks >= 100 and (getPercentHP(target) >= 15 or (100 * (target.health - dmg / target.maxHealth)) > 15) then
          dmg =
              target.health + 9999
        end; return dmg
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 130, 170 })[level] +
            0.17 * source.ap
      end
    }, -- PER SPHERE
  },

  ["Talon"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 65, 90, 115, 140, 165 })
            [level] * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 40, 50, 60, 70, 80 })
            [level] + 0.40 * source.bonusDamage
      end
    }, --INITIAL DAMAGE
    {
      Slot = "W",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 80, 110, 140, 170 })
            [level] + 0.8 * source.bonusDamage
      end
    }, --RETURN DAMAGE
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 90, 135, 180 })[level] +
            source.bonusDamage
      end
    },
  },

  ["Taliyah"] = {
    { --TODO: Bonus damage per stone shard, and boulder vs monster?
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 78, 96, 114, 132 })
            [level] + 0.50 * source.ap
      end
    }, --for total dmg = dmg + 4(0.40*dmg) 5 hits susequent hits deal 40%
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 114, 148.2, 182.4, 216.6, 250.8 })
            [level] + 0.95 * source.ap
      end
    }, --Empowered Single
    --{Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 80, 100, 120, 140})[level] + 0.4 * source.ap end}, --No longer deals damage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 105, 150, 195, 240 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 62.5, 112.5, 162.5, 212.5, 262.5 })
            [level] + 0.75 * source.ap
      end
    }, --max trigger damage
  },

  ["Taric"] = {
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 130, 170, 210, 250 })
            [level] + (0.5 * source.ap) + (0.5 * source.bonusArmor)
      end
    },
  },

  ["TahmKench"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 130, 180, 230, 280 })
            [level] + 1.00 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 135, 170, 205, 240 })
            [level] + 1.50 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 250, 400 })[level] +
            (0.15 + (0.07 * math.floor(source.ap / 100)) * target.maxHealth)
      end
    }, --2nd cast damage "Regurgitate"
  },

  ["Teemo"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 125, 170, 215, 260 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = (({ 24, 48, 72, 96, 120 })[level] + (0.40 * source.ap)); if target.type == Obj_AI_Camp then dmg = (dmg * 1.5) end; return
            dmg
      end
    }, --total after 4sec of ticks
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = (({ 14, 25, 36, 47, 58 })[level] + (0.30 * source.ap)); if target.type == Obj_AI_Camp then dmg = (dmg * 1.5) end; return
            dmg
      end
    }, --on hit
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 325, 450 })[level] +
            0.50 * source.ap
      end
    }, --total damage
  },

  ["Thresh"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 150, 200, 250, 300 })
            [level] + 0.90 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 120, 165, 210, 255 })
            [level] + 0.70 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 250, 400, 550 })[level] +
            1.00 * source.ap
      end
    },
  },

  ["Tristana"] = {
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 95, 145, 195, 245, 295 })
            [level] + 0.5 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 70, 80, 90, 100, 110 })
            [level] + (({ 0.5, 0.75, 1, 1.25, 1.5 })[level] * source.bonusDamage) + (0.5 * source.ap) +
            (0.333 * source.critChance) +
            (Buff:GetBuff(source, "tristanaecharge").count * ({ 21, 24, 27, 30, 33 })[level] + (({ 0.15, 0.225, 0.30, 0.375, 0.45 })[level] * source.bonusDamage) + (0.15 * source.ap))
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 300, 400, 500 })[level] +
            source.ap
      end
    },
  },

  ["Trundle"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 30, 50, 70, 90 })
            [level] + (({ 0.15, 0.25, 0.35, 0.45, 0.55 })[level] * source.totalDamage)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 20, 25, 30 })[level] / 100 + 0.02 * math.floor(source.ap / 100)) *
            target.maxHealth
      end
    },
  },

  ["Tryndamere"] = {
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + (1.3 * source.bonusDamage) + (0.8 * source.ap)
      end
    },
  },

  ["TwistedFate"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + 0.90 * source.ap + 0.50 * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 60, 80, 100, 120 })
            [level] + (1.00 * source.totalDamage) + (1.00 * source.ap) * (0.35 * source.critChance)
      end
    }, --Blue Card
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 45, 60, 75, 90 })
            [level] + (1.00 * source.totalDamage) + (0.70 * source.ap) * (0.35 * source.critChance)
      end
    }, --Red Card
    {
      Slot = "W",
      Stage = 3,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 15, 22.5, 30, 37.5, 45 })
            [level] + (1.00 * source.totalDamage) + (0.50 * source.ap) * (0.35 * source.critChance)
      end
    }, --Gold Card
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        --local count = Buff:GetBuffCount(source, "cardmasterstackparticle")
        --if count > 0 then return (({ 65, 90, 115, 140, 165 })[level] + (0.75 * source.bonusDamage) + 0.50 * source.ap) end; return 0
        return (({ 65, 90, 115, 140, 165 })[level] + (0.25 * source.bonusDamage) + 0.40 * source.ap)
      end
    }, --calc damage only if at 3 stacks for empowered AA
  },

  ["Twitch"] = {
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (Buff:GetBuffCount(target, "TwitchDeadlyVenom") * ({ 15, 20, 25, 30, 35 })[level] + (0.35 * source.bonusDamage)) +
            ({ 20, 30, 40, 50, 60 })[level] + (0.30 * source.ap)
      end
    }, --mixed damage
    {
      Slot = "E",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 20, 25, 30, 35 })
            [level] + (0.35 * source.bonusDamage) + ({ 20, 35, 50, 65, 80 })[level] + (0.30 * source.ap)
      end
    },                                                                                                                      --mixed damage
    { Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({ 30, 45, 60 })[level] end }, --bonus attack range
  },

  ["Udyr"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (({ 3.00, 4.40, 5.80, 7.20, 8.60, 10.00 })[level] / 100 + (0.06 * math.floor(source.bonusDamage / 100))) *
            target.maxHealth
      end
    }, --TODO: is AA damage x2 + on-hit
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ((1.5 + 1.5 / 17 * (level - 1)) + (0.008 * math.floor(source.ap / 100))) *
            target.maxHealth
      end
    }, --Awaken lightning + TODO: min dmg against minions
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 10, 19, 28, 37, 46, 55 })
            [level] + (0.20 * source.ap)
      end
    },                                                                                                                                                                                                 --per tick
    { Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (0.01 + 0.01 / 17 * (level - 1) + (0.4375 / 100 * math.floor(source.ap / 100)) * target.maxHealth) end }, --Awaken storm per tick
    {
      Slot = "R",
      Stage = 3,
      DamageType = 2,
      Damage = function(source, target, level)
        return (10 + 20 / 17 * (level - 1)) +
            (0.30 * source.ap)
      end
    }, --is AA dmg see SpecialAADamageTable

  },

  ["Urgot"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 25, 70, 115, 160, 205 })
            [level] + 0.7 * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return 12 +
            ((({ 20, 23.5, 27, 30.5, 34 })[level] / 100) * source.totalDamage)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 90, 120, 150, 180, 210 })
            [level] + source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 100, 225, 350 })[level] +
            0.5 * source.bonusDamage
      end
    },
  },

  ["Varus"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 46.67, 83.33, 120, 156.67 })
            [level] + ((({ 83.33, 86.67, 90, 93.33, 96.67 })[level] / 100) * source.totalDamage)
      end
    }, --min
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 70, 125, 180, 235 })
            [level] + ((({ 125, 130, 135, 140, 145 })[level] / 100) * source.totalDamage)
      end
    }, --max
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 7, 13, 19, 25, 31 })
            [level] + 0.35 * source.ap
      end
    }, --non per stack
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ((({ 3, 3.5, 4, 4.5, 5 })[level] / 100) + 0.015 * math.floor(source.ap / 100)) *
            target.maxHealth
      end
    }, -- per stack
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + (0.90 * source.bonusDamage)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 200, 250 })[level] +
            source.ap
      end
    },
  },

  ["Vayne"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (({ 75, 85, 95, 105, 115 })[level] / 100) *
            source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        return math.max(
          ({ 50, 65, 80, 95, 110 })[level], (({ 6, 7, 8, 9, 10 })[level] / 100) * target.maxHealth)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 85, 120, 155, 190 })
            [level] + (0.5 * source.bonusDamage)
      end
    },
  },

  ["Veigar"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + ((({ 45, 50, 55, 60, 65 })[level] / 100) * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 85, 140, 195, 250, 305 })
            [level] + ((({ 70, 80, 90, 100, 110 })[level] / 100) * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 175, 250, 325 })[level] + (({ 0.65, 0.70, 0.75 })[level] * source.ap) *
            (1 + (0.015 * (math.max(getMissingHP(target), 66.66))))
      end
    },
  },

  ["Velkoz"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + (0.8 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 50, 70, 90, 110 })
            [level] + (0.15 * source.ap)
      end
    }, --initial damage
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 45, 75, 105, 135, 165 })
            [level] + (0.25 * source.ap)
      end
    }, --detonation
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 100, 130, 160, 190 })
            [level] + (0.3 * source.ap)
      end
    },
    { Slot = "R", Stage = 1, DamageType = 3, Damage = function(source, target, level) return (Buff:GetBuffCount(target, "velkozresearchedstack") > 0 and ({ 450, 625, 800 })[level] + (1.25 * source.ap) or CalcDamage(source, target, ({ 450, 625, 800 })[level] + (1.25 * source.ap))) end },
  },

  ["Vex"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 115, 160, 205, 250 })
            [level] + (0.70 * source.ap)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 140, 170 })
            [level] + (0.30 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 70, 90, 110, 130 })
            [level] + (({ 0.40, 0.45, 0.5, 0.55, 0.60 })[level] * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 125, 175 })[level] +
            (0.20 * source.ap)
      end
    }, -- initial hit
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 250, 350 })[level] +
            (0.50 * source.ap)
      end
    }, -- recast impact
  },

  ["Viego"] = {
    { Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ((1.0 + math.min(1.0, 1.0 * source.critChance)) * ({ 15, 30, 45, 60, 75 })[level] + (0.7 * source.totalDamage)) end },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 135, 190, 245, 300 })
            [level] + source.ap
      end
    },
    { Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return (((({ 12, 16, 20 })[level] / 100) + (0.05 * math.floor(source.bonusDamage / 100))) * (getMissingHP(target))) end },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (1.2 * source.totalDamage) *
            (1 + math.min(1, 1 * source.critChance))
      end
    }, --slash damage
  },

  ["Vi"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 45, 70, 95, 120, 145 })
            [level] + (0.80 * source.bonusDamage)
      end
    }, -- +0-100%(based on channel time) 10% per 0.125 sec(cap 1.25sec)
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (({ 4, 5.5, 7, 8.5, 10 })[level] / 100 + (0.01 * math.floor(source.bonusDamage / 35))) *
            target.maxHealth
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 0, 15, 30, 45, 90 })
            [level] + (1.20 * source.totalDamage) + (1.00 * source.ap)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 150, 275, 400 })[level] +
            (0.90 * source.bonusDamage)
      end
    },
  },

  ["Viktor"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 120, 160, 200, 240 })
            [level] + source.ap + source.totalDamage
      end
    }, --totalDamage active & discharge
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 110, 150, 190, 230 })
            [level] + 0.5 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 90, 170, 250, 330, 410 })
            [level] + 1.3 * source.ap
      end
    }, --Total Damage with augment aftershock
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 175, 250 })[level] +
            0.5 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 65, 105, 145 })[level] +
            0.45 * source.ap
      end
    }, --Per Tick
  },

  ["Vladimir"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 100, 120, 140, 160 })
            [level] + 0.6 * source.ap
      end
    },
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 148, 185, 222, 259, 296 })
            [level] + 1.11 * source.ap
      end
    }, --empowered q
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 20, 33.75, 47.5, 61.25, 75 })
            [level] + (0.025 * (getBonusHealth(source)))
      end
    }, --per tick
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 135, 190, 245, 300 })
            [level] + (0.1 * (getBonusHealth(source)))
      end
    }, --totalDamage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 30, 45, 60, 75, 90 })
            [level] + (0.35 * source.ap) + (0.015 * source.maxHealth)
      end
    }, --min damage
    {
      Slot = "E",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180 })
            [level] + (0.80 * source.ap) + (0.06 * source.maxHealth)
      end
    }, --max damage
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        local dmg = ({ 150, 250, 350 })[level] + 0.7 * source.ap; return dmg * 1.10
      end
    }, --increases all dmg +10%
  },

  ["Volibear"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 10, 30, 50, 70, 90 })
            [level] + 1.20 * source.bonusDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (({ 5, 30, 55, 80, 105 })[level]) +
            1.00 * source.totalDamage + (0.06 * (getBonusHealth(source)))
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + (0.80 * source.ap) + (({ 0.11, 0.12, 0.13, 0.14, 0.15 })[level] * target.maxHealth)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 300, 500, 700 })[level] +
            (2.50 * source.bonusDamage) + (1.25 * source.ap)
      end
    },
  },

  ["Warwick"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return (({ 6, 7, 8, 9, 10 })[level] / 100 * target.maxHealth) +
            source.ap + (1.2 * source.totalDamage)
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 175, 350, 525 })[level] +
            1.67 * source.bonusDamage
      end
    },
  },

  ["Xayah"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 45, 60, 75, 90, 105 })
            [level] + 0.50 * source.bonusDamage
      end
    }, --per blade
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 50, 60, 70, 80, 90 })
            [level] + 0.60 * source.bonusDamage
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            source.bonusDamage
      end
    },
  },

  ["Xerath"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 110, 150, 190, 230 })
            [level] + 0.85 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 95, 130, 165, 200 })
            [level] + 0.6 * source.ap
      end
    }, -- Base damage
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 158.4, 216.7, 275, 333.3 })
            [level] + 1.02 * source.ap
      end
    }, --Center blast
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 110, 140, 170, 200 })
            [level] + 0.45 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 180, 230, 280 })[level] +
            0.40 * source.ap
      end
    },
  },

  ["XinZhao"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 16, 25, 34, 43, 52 })
            [level] + 0.4 * source.bonusDamage
      end
    }, --per attack for next 3 AA
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return (0.33 * source.critChance) *
            ({ 80, 125, 170, 215, 260 })[level] + (1.1 * source.totalDamage) + (0.65 * source.ap)
      end
    }, --total damage slash & thrust
    {
      Slot = "W",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return (0.33 * source.critChance) *
            ({ 50, 85, 120, 155, 190 })[level] + (0.9 * source.totalDamage) + (0.65 * source.ap)
      end
    }, --thrust damage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 75, 100, 125, 150 })
            [level] + 0.6 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 75, 175, 275 })[level] +
            source.bonusDamage + (0.15 * target.health)
      end
    },
  },

  ["Yasuo"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 45, 70, 95, 120 })
            [level] + 1.05 * source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 70, 80, 90, 100 })
            [level] + (0.2 * source.bonusDamage) + (0.6 * source.ap)
      end
    }, --dmg increased based on level and per stack
    {
      Slot = "R",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 200, 350, 500 })[level] +
            1.5 * source.bonusDamage
      end
    },
  },

  ["Yone"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 40, 60, 80, 100 })
            [level] + 1.05 * source.totalDamage
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 5, 10, 15, 20, 25 })
            [level] + (({ 0.055, 0.06, 0.065, 0.07, 0.075 })[level] * target.maxHealth)
      end
    }, -- Ap Damage
    {
      Slot = "W",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 5, 10, 15, 20, 25 })
            [level] + (({ 0.055, 0.06, 0.065, 0.07, 0.075 })[level] * target.maxHealth)
      end
    }, -- AD Damage
    {
      Slot = "E",
      Stage = 1,
      DamageType = 3,
      Damage = function(source, target, level)
        return ({ 25, 27.5, 30, 32.5, 35 })
            [level] / 100
      end
    }, -- Stored damage percentage
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 100, 200, 300 })[level] +
            0.4 * source.totalDamage
      end
    }, -- Ap Damage
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 100, 200, 300 })[level] +
            0.4 * source.totalDamage
      end
    }, -- Ad Damage
  },

  ["Yorick"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 55, 80, 105, 130 })
            [level] + 0.40 * source.totalDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return math.max(
          ({ 70, 105, 140, 175, 210 })[level] + (0.70 * source.ap), 0.15 * target.health)
      end
    },
  },

  ["Yuumi"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 90, 120, 150, 180, 210 })
            [level] + 0.20 * source.ap
      end
    }, --Normal
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 80, 135, 190, 245, 300, 355 })
            [level] + 0.35 * source.ap
      end
    }, --empowered damage
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 150, 200, 254 })[level] +
            0.4 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 100, 125 })[level] +
            0.2 * source.ap
      end
    }, --per wave
  },

  ["Zac"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 55, 70, 85, 100 })
            [level] + (0.3 * source.ap) + (0.004 * source.maxHealth)
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 50, 60, 70, 80 })
            [level] + ((({ 4, 5, 6, 7, 8 })[level] / 100 + (0.003 * math.floor(source.ap / 100))) * target.maxHealth)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 105, 150, 195, 240 })
            [level] + 0.80 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 140, 210, 280 })[level] +
            0.4 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 350, 525, 700 })[level] + 1.00 *
            source.ap
      end
    }, --max single target
  },

  ["Zed"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 1.10 * source.bonusDamage
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 65, 90, 115, 140, 165 })
            [level] + 0.65 * source.bonusDamage
      end
    },
    { Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return 1.0 * source.totalDamage end },
    {
      Slot = "R",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 25, 40, 55 })[level] /
            100
      end
    }, -- percent of damage dealt
  },

  ["Zeri"] = {
    {
      Slot = "Q",
      Stage = 2,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 15, 17, 19, 21, 23 })
            [level] + (({ 1.04, 1.08, 1.12, 1.16, 1.20 })[level] * source.totalDamage)
      end
    }, --total
    {
      Slot = "W",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 30, 70, 110, 150, 190 })
            [level] + (1.30 * source.totalDamage) + (0.25 * source.ap)
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 1,
      Damage = function(source, target, level)
        return ({ 20, 22, 24, 26, 28 })
            [level] + (0.12 * source.bonusDamage) + (0.20 * source.ap)
      end
    },
    --TODO: E Bonus damage
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 175, 275, 375 })[level] +
            (0.85 * source.bonusDamage) + (1.10 * source.ap)
      end
    }, --Nova damage
    --{Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({5, 10, 15})[level] + (0.15 * source.ap) end}, -- on hit bonus magic damage
  },

  ["Ziggs"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 85, 135, 185, 235, 285 })
            [level] + 0.65 * source.ap
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 105, 140, 175, 210 })
            [level] + 0.50 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 40, 75, 110, 145, 180 })
            [level] + 0.30 * source.ap
      end
    }, --per mine
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 300, 450, 600 })[level] +
            1.10 * source.ap
      end
    }, --center damage
    {
      Slot = "R",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 200, 300, 400 })[level] +
            0.7333 * source.ap
      end
    }, --normal damage
  },

  ["Zilean"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 115, 165, 230, 300 })
            [level] + 0.9 * source.ap
      end
    },
  },

  ["Zoe"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 50, 80, 110, 140, 170 })
            [level] + (0.60 * source.ap) +
            ({ 7, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 29, 32, 35, 38, 42, 46, 50 })[source.levelData.lvl]
      end
    },
    {
      Slot = "W",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 75, 105, 135, 165, 195 })
            [level] + 0.40 * source.ap
      end
    }, -- total damage
    {
      Slot = "W",
      Stage = 2,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 25, 35, 45, 55, 65 })
            [level] + 0.133 * source.ap
      end
    }, -- per bolt 3 total
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 70, 110, 150, 190, 2230 })
            [level] + 0.45 * source.ap
      end
    },
  },

  ["Zyra"] = {
    {
      Slot = "Q",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 100, 140, 180, 220 })
            [level] + 0.65 * source.ap
      end
    },
    {
      Slot = "E",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 60, 95, 130, 165, 200 })
            [level] + 0.60 * source.ap
      end
    },
    {
      Slot = "R",
      Stage = 1,
      DamageType = 2,
      Damage = function(source, target, level)
        return ({ 180, 265, 350 })[level] +
            0.70 * source.ap
      end
    },
  },

}

-- [[ Calc Local Functions ]] --
DamageLib.SetSpecialAADamageTable = function(args)
  local s = SpecialAADamageTable[args.source.charName]
  if s then
    s(args)
  end
end

DamageLib.SetHeroPassiveDamageTable = function(args)
  local s = HeroPassiveDamageTable[args.source.charName]
  if s then
    s(args)
  end
end

DamageLib.SetItemDamageTable = function(id, args)
  local s = ItemDamageTable[id]
  if s then
    s(args)
  end
end

DamageLib.GetCriticalStrikePercent = function(source)
  local criticalStrikePercent = 1
  local hasInfinityEdge = ((Item:HasItem(source, ItemID.InfinityEdge)) and 0.50 or 0)
  local critDamage = 1.75 + hasInfinityEdge
  local fullCrit = source.critChance >= 1
  if fullCrit then
    criticalStrikePercent = critDamage
  else
    local avgMod = 0.0075
    local bonusCriticalDamage = avgMod * critDamage
    local avgCriticalDamage = 1 + (source.critChance * (avgMod * bonusCriticalDamage))
    criticalStrikePercent = avgCriticalDamage
  end
  local heroMod = 1
  if source.charName == "Akshan" then --TODO: additional shot after AA
    heroMod = 0.70
  elseif source.charName == "Ashe" then
    criticalStrikePercent = 1
  elseif source.charName == "Fiora" then
    criticalStrikePercent = ({ 1.60, 1.70, 1.80, 1.90, 2.00 })[source:GetSpellData(_W).level]
  elseif source.charName == "Jhin" then
    heroMod = 0.86
  elseif source.charName == "Kalista" then
    heroMod = 0.90
  elseif source.charName == "Yasuo" then
    heroMod = 0.90
  elseif source.charName == "Yone" then
    heroMod = 0.90
  end
  return criticalStrikePercent * heroMod
end

DamageLib.PassivePercentMod = function(source, target, DamageType, amount)
  local targetIsHero = target.type == Obj_AI_Hero;
  local sourceIsHero = source.type == Obj_AI_Hero;
  if sourceIsHero then
    local chemTech = Buff:HasBuff(source, "SRX_DragonSoulBuffChemtech") --HasBuffContainsName
    if chemTech and getPercentHP(source) < 50 then
      amount = amount * (1 + 0.11)
    end
    if targetIsHero then
      if (getItemSlot(source, ItemID.LordDominiksRegards) > 0) and source.maxHealth < target.maxHealth and DamageType == 1 then -- Lord Dominik's Regards
        amount = amount *
            (1 + 0.0075 * (math.min(2000, target.maxHealth - source.maxHealth) / 100))                                          --TODO: as bonusDamage
      end
      if (getItemSlot(source, ItemID.Perplexity) > 0) and source.maxHealth < target.maxHealth and DamageType == 1 then          --  Perplexity
        amount = amount *
            (1 + 0.0088 * (math.min(2000, target.maxHealth - source.maxHealth) / 100))                                          --TODO: as bonusDamage
      end
    end
  end
  return amount
end

DamageLib.DamageReductionMod = function(source, target, DamageType, amount)
  local targetIsHero = target.type == Obj_AI_Hero;
  local sourceIsHero = source.type == Obj_AI_Hero;

  local reductionFactors = {
    Exhaust = 0.35,
    itemsmitechallenger = 0.10,
    barontarget = 0.50,
  }

  if sourceIsHero then
    for buff, reduction in pairs(reductionFactors) do
      if Buff:GetBuffCount(source, buff) > 0 then
        amount = amount * (1 - reduction)
      end
    end
  end

  if targetIsHero then
    local targetBuffs = Buff:GetBuffs(target)

    for _, buff in pairs(targetBuffs) do
      if buff.name == "SRX_DragonSoulBuffChemtech" and getPercentHP(target) < 50 then
        amount = amount * (1 + 0.11)
      elseif buff.name == "s5_dragonvengeance" then
        local count = Buff:HasBuffContainsNameCount(source, "SRX_DragonBuff")
        amount = amount * (1 - 0.07 * count)
      end
      local charName = target.charName
      if DamageReductionBuffsTable[charName] and buff.name == DamageReductionBuffsTable[charName].buff and
          (not DamageReductionBuffsTable[charName].DamageType or DamageReductionBuffsTable[charName].DamageType == DamageType) then
        amount = amount * (1 - DamageReductionBuffsTable[charName].amount(source, target, DamageType, amount))
      end
    end

    for i = 1, #ItemSlots do
      local slot = ItemSlots[i]
      local item = target:GetItemData(slot)
      if item ~= nil and item.itemID > 0 and DamageReductionItemsTable[item.itemID] and
          item.itemID == DamageReductionItemsTable[item.itemID] and
          (not DamageReductionItemsTable[item.itemID].DamageType or DamageReductionItemsTable[item.itemID].DamageType == DamageType) then
        amount = amount * (1 - DamageReductionItemsTable[item.itemID].amount(source, target, DamageType, amount))
      end
    end

    if target.charName == "Kassadin" and DamageType == 2 then
      amount = amount * 0.90
    end
  end

  return amount
end

DamageLib.GetHeroAADamage = function(source, target, SpecialAA)
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
  DamageLib.SetHeroPassiveDamageTable(args)
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
      if isMelee(source) then
        if getPercentHP(target) < 50 then
          args.CalculatedPhysical = target.health + 999
        end
      elseif getPercentHP(target) < 30 then
        args.CalculatedPhysical = target.health + 999
      end
    elseif Item:HasItem(source, ItemID.TargonsBuckler) or Item:HasItem(source, ItemID.RunesteelSpaulders) then --Targon's Buckler --Runesteel Spaulders
      if getPercentHP(target) < 50 then
        args.CalculatedPhysical = target.health + 999
      end
    end
  end
  local percentMod = 1
  if args.source.critChance or args.CriticalStrike then
    percentMod = percentMod * DamageLib.GetCriticalStrikePercent(args.source)
  end
  return percentMod * args.CalculatedPhysical + args.CalculatedMagical + args.CalculatedTrue
end

DamageLib.GetSpecialAADamage = function(source, target, targetIsMinion)
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
  DamageLib.SetSpecialAADamageTable(args)
  local HashSet = {}
  for i = 1, #ItemSlots do
    local slot = ItemSlots[i]
    local item = args.source:GetItemData(slot)
    if item ~= nil and item.itemID > 0 then
      if HashSet[item.itemID] == nil then
        DamageLib.SetItemDamageTable(item.itemID, args)
        HashSet[item.itemID] = true
      end
    end
  end
  return args
end

-- [[ Global Function ]] --
GetAADamage = function(source, target, respectPassives, IsAA)
  if respectPassives == nil then
    respectPassives = true
  end
  if source == nil or target == nil then
    return 0
  end
  local targetType = target.type
  local sourceType = source.type
  local targetIsMinion = targetType == Obj_AI_Minion;
  local sourceIsHero = sourceType == Obj_AI_Hero;
  if respectPassives and sourceIsHero then
    return DamageLib.GetHeroAADamage(source, target, DamageLib.GetSpecialAADamage(source, target, targetIsMinion))
  end
  if targetIsMinion then --wards?
    if target.maxHealth <= 6 then
      if Item:HasItem(source, ItemID.UmbralGlaive) then
        return 2
      end
      return 1
    end
  end
  return CalcDamage(source, target, DAMAGE_TYPE_PHYSICAL, source.totalDamage, IsAA)
end

CalcDamage = function(source, target, DamageType, amount, IsAA)
  local targetType = target.type
  local sourceType = source.type

  -- Early return for true damage
  if DamageType == DAMAGE_TYPE_TRUE then
    return amount
  end

  -- Determine DamageType if not provided
  if DamageType == nil then
    if source.totalDamage > source.ap then
      DamageType = DAMAGE_TYPE_PHYSICAL
    else
      DamageType = DAMAGE_TYPE_MAGICAL
    end
  end

  local baseResist, bonusResist, flatPen, percentPen, bonuspercentPen, resist
  local targetIsMinion = targetType == Obj_AI_Minion;
  local sourceIsMinion = sourceType == Obj_AI_Minion;
  if DamageType == DAMAGE_TYPE_PHYSICAL then
    local lethality = (0.6222 + 0.3778 / 17 * (source.levelData.lvl - 1))
    baseResist = math.max(target.armor - target.bonusArmor, 0)
    bonusResist = target.bonusArmor
    flatPen = source.armorPen * lethality
    percentPen = source.armorPenPercent -- 1 or 0.69999998807907 with ldr
    bonuspercentPen = source.bonusArmorPenPercent

    local targetIsCamp = targetType == Obj_AI_Camp;
    local sourceIsCamp = sourceType == Obj_AI_Camp;
    local targetIsTurret = targetType == Obj_AI_Turret;
    local sourceIsTurret = sourceType == Obj_AI_Turret;
    if sourceIsMinion then
      flatPen, percentPen, bonuspercentPen = 0, 1, 0
    elseif sourceIsTurret then
      flatPen, percentPen, bonuspercentPen = 0, 0.7, 0
      if targetIsMinion then
        local percentHP
        if table_contains(siegeMinionList, target.charName) then
          if getTurretType(source.name, "Base") then
            local percentHP = TurretToMinionPercent[siegeMinionList].Base
          elseif getTurretType(source.name, "Inner") then
            local percentHP = TurretToMinionPercent[siegeMinionList].Inner
          elseif getTurretType(source.name, "Outer") then
            local percentHP = TurretToMinionPercent[siegeMinionList].Outer
          end
        elseif table_contains(rangedMinionList, target.charName) then
          local percentHP = TurretToMinionPercent[rangedMinionList]
        elseif table_contains(meleeMinionList, target.charName) then
          local percentHP = TurretToMinionPercent[meleeMinionList]
        end
        if percentHP ~= nil then
          return target.maxHealth * percentHP
        end
      end
    end
  elseif DamageType == DAMAGE_TYPE_MAGICAL then
    baseResist = math.max(target.magicResist - target.bonusMagicResist, 0)
    bonusResist = target.bonusMagicResist
    flatPen = source.magicPen
    percentPen = source.magicPenPercent
    bonuspercentPen = 0
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
    resist = baseResist + bonusResist - flatPen
  end
  local postMitigation = resist >= 0 and (100 / (100 + resist)) or (2 - 100 / (100 - resist))
  local flatPassive = 0
  local targetIsHero = targetType == Obj_AI_Hero;
  local sourceIsHero = sourceType == Obj_AI_Hero;
  if targetIsHero then --TODO: Move to own function/table
    local charName = target.charName
    if charName == "Fizz" then
      flatPassive = flatPassive - (4 + 0.01 * source.ap) --TODO: 50% max reduction
    elseif charName == "Leona" and Buff:HasBuff(target, "LeonaSolarBarrier") then
      flatPassive = flatPassive - (({ 8, 12, 16, 20, 24 })[target:GetSpellData(_W).level or 1])
    elseif charName == "Amumu" and Buff:HasBuff(target, "Tantrum") then
      flatPassive = flatPassive -
          (({ 5, 7, 9, 11, 13 })[target:GetSpellData(_E).level or 1] + (0.03 * target.bonusMagicResist) + (0.03 * target.bonusArmor)) --TODO: max 50%
    end
    if getItemSlot(target, ItemID.GuardiansHorn) > 0 then                                                                             --Guardian's Horn
      flatPassive = flatPassive - 15
    end
  end

  local bonusPercent = (sourceIsMinion and targetIsMinion) and (1 + source.bonusDamagePercent) or 1
  local flatreduction = targetIsMinion and (-target.flatDamageReduction) or 0

  local ppmod = DamageLib.PassivePercentMod(source, target, DamageType, postMitigation)
  local dmgmod = DamageLib.DamageReductionMod(source, target, DamageType, ppmod * (amount + flatPassive))
  local dmg = math.max(math.floor(bonusPercent * dmgmod + flatreduction), 0)
  if isARAM() then
    local dmgD = 1
    local dmgR = 1
    if ARAM[source.charName] then
      if ARAM[source.charName].dmgDealt ~= nil then
        dmgD = ARAM[source.charName].dmgDealt
        -- dmgD = dmgD-ARAM[source.charName].dmgDealt
      end
    end
    if targetIsHero and ARAM[target.charName] then
      if ARAM[target.charName].dmgReceived ~= nil then
        dmgR = ARAM[target.charName].dmgReceived
        -- dmgR = dmgR-ARAM[target.charName].dmgReceived
      end
    end
    dmg = math.max(math.floor(dmg * dmgD * dmgR), 0)
  end
  return dmg
end

getrawdmg = function(spell, target, source, stage, level)
  level = level or
      source:GetSpellData(({ ["Q"] = _Q, ["QM"] = _Q, ["W"] = _W, ["WM"] = _W, ["E"] = _E, ["EM"] = _E, ["R"] = _R })
        [spell])
      .level
  source = source or myHero
  stage = stage or 1
  if level <= 0 then return 0 end
  if level > 6 then level = 6 end
  if SpellDamageTable[source.charName] then
    local dmgtable = {}
    for _, spells in pairs(SpellDamageTable[source.charName]) do
      if spells.Slot == spell then
        table.insert(dmgtable, spells)
      end
    end
    if stage > #dmgtable then stage = #dmgtable end
    for v = #dmgtable, 1, -1 do
      local spells = dmgtable[v]
      if spells.Stage == stage then
        local dmg = spells.Damage(source, target, level)
        if isARAM() then
          local targetType = target.type
          local targetIsHero = targetType == Obj_AI_Hero;
          local dmgD = 1
          local dmgR = 1
          if ARAM[source.charName] then
            if ARAM[source.charName].dmgDealt ~= nil then
              dmgD = ARAM[source.charName].dmgDealt
            end
          end
          if targetIsHero and ARAM[target.charName] then
            if ARAM[target.charName].dmgReceived ~= nil then
              dmgR = ARAM[target.charName].dmgReceived
            end
          end
          dmg = dmg * dmgD * dmgR
        end
        return dmg
      end
    end
  end
end

getdmg = function(spell, target, source, stage, level)
  source = source or myHero
  stage = stage or 1
  local targetType = target.type
  local sourceType = source.type
  local sourceIsHero = sourceType == Obj_AI_Hero;

  local dmgtable = {}
  if spell == "Q" or spell == "W" or spell == "E" or spell == "R" or spell == "QM" or spell == "WM" or spell == "EM" and sourceIsHero then
    level = level or
        source:GetSpellData(({ ["Q"] = _Q, ["QM"] = _Q, ["W"] = _W, ["WM"] = _W, ["E"] = _E, ["EM"] = _E, ["R"] = _R })
          [spell]).level
    if level <= 0 then return 0 end
    if level > 6 then level = 6 end
    if SpellDamageTable[source.charName] then
      for _, spells in pairs(SpellDamageTable[source.charName]) do
        if spells.Slot == spell then
          table.insert(dmgtable, spells)
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
    local targetIsMinion = targetType == Obj_AI_Minion;
    local SpecialAADamage = DamageLib.GetSpecialAADamage(source, targetIsMinion)
    return GetAADamage(source, target, SpecialAADamage, true)
  end
  local Ignite = getSummonerSpell("dot")
  if spell == "IGNITE" or (spell == Ignite) then
    local IgniteDamage = ((50 + 20 * source.levelData.lvl) - (target.hpRegen * 3))
    return IgniteDamage
  end
  local Mark = getSummonerSpell("mark")
  local Dash = getSummonerSpell("dash")
  if (spell == "MARK" or spell == Mark) or (spell == "DASH" or spell == Dash) then
    local MarkandDashDamage = 10 + 5 * source.levelData.lvl
    return MarkandDashDamage
  end
  local Smite = getSummonerSpell("smite")
  if spell == "SMITE" or (spell == Smite) then
    local targetIsHero = targetType == Obj_AI_Hero;
    local SmiteUnleashed = getSummonerSpell("ganker")
    local SmiteDuel = getSummonerSpell("duel")
    local SmiteAvatar = getSummonerSpell("avatar")
    local SmiteDamage = 600
    local SmiteUnleashedDamage = 900
    local SmitePrimalDamage = 1200
    local SmiteAdvDamageHero = 80 + 80 / 17 * (source.levelData.lvl - 1)
    if not targetIsHero then
      if source:GetSpellData(Smite).name == "SummonerSmite" then
        return SmiteDamage
      elseif source:GetSpellData(SmiteUnleashed).name == "S5_SummonerSmitePlayerGanker" or source:GetSpellData(SmiteDuel).name == "S5_SummonerSmiteDuel" then
        return SmiteUnleashedDamage
      elseif source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarOffensive" or source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarUtility" or source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarDefensive" then
        return SmitePrimalDamage
      end
    elseif targetIsHero then
      if source:GetSpellData(SmiteUnleashed).name == "S5_SummonerSmitePlayerGanker" or source:GetSpellData(SmiteDuel).name == "S5_SummonerSmiteDuel" then
        return SmiteAdvDamageHero
      elseif source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarOffensive" or source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarUtility" or source:GetSpellData(SmiteAvatar).name == "SummonerSmiteAvatarDefensive" then
        return SmiteAdvDamageHero
      end
    else
      return 0
    end
  end
  if spell == "HEXTECH" then
    return CalcDamage(source, target, 2, 125 + (0.15 * source.ap))
    --Dash 125-275 range, damage in arc cone of dashdirection with 7 rockets
  end
  if spell == "EVERFROST" then
    return CalcDamage(source, target, 2, 100 + (0.3 * source.ap))
    --~850 range 28deg cone, slows, center of cone roots
  end
  if spell == "GALEFORCE" then
    return CalcDamage(source, target, 2,
      ((({ 60, 60, 60, 60, 60, 60, 60, 60, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105 })[source.levelData.lvl] + (0.15 * source.bonusDamage)) * 3) *
      (1 + (0.05 * (getPercentHP(target) / 7.5))))
    --750 range radius to most wounded enemy + 3 arrows and missing hp dmg
  end
  if spell == "IRONSPIKE" then
    return CalcDamage(source, target, 1, source.totalDamage)
    --450 AOE radius centered around source
  end
  if spell == "GOREDRINKER" then
    return CalcDamage(source, target, 1, 1.75 * source.totalDamage)
    --450 AOE radius centered around source + heal
  end
  if spell == "STRIDEBREAKER" then
    return CalcDamage(source, target, 1, 1.75 * source.totalDamage)
    --450 AOE radius centered around source + slow
  end
  if spell == "PROWLER" then
    return CalcDamage(source, target, 1, 75 + 0.30 * source.bonusDamage)
    --500 range + increase your damage dealt by 15%
  end
  return 0
end

-- [[ Memoize ]] --
local cache = {}
local cachegetdmg = getdmg
-- setmetatable(cache, {__mode = "v"}) --or even {__mode = "kv"} for weak keys & values if memory issues
local function createKey(spell, target, source, stage)
  return spell .. ':' .. tostring(target.networkID) .. ':' .. tostring(source.networkID) .. ':' .. tostring(stage)
end

function getcacheddmg(spell, target, source, stage, level, refreshtime)
  refreshtime = refreshtime or 0.033 --0.33 --tick 0.033 --5tick 0.165
  source = source or myHero
  stage = stage or 1
  local key = createKey(spell, target, source, stage)
  local cachedValue = cache[key]
  if cachedValue then
    if cachedValue.timestamp + refreshtime > Game.Timer() then
      return cachedValue.value
    end
  end
  local value = cachegetdmg(spell, target, source, stage, level)
  --print("getcacheddmg: ",Game.Timer())
  cache[key] = { value = value, timestamp = Game.Timer() }
  return value
end

-- pool
local pool = {}
local poolmt = { __index = pool }

function pool.create(newObject, poolSize)
  poolSize = poolSize or 16
  assert(newObject, "A function that returns new objects for the pool is required.")

  local freeObjects = {}
  for _ = 1, poolSize do
    table.insert(freeObjects, newObject())
  end

  return setmetatable({
      freeObjects = freeObjects,
      newObject = newObject
    },
    poolmt
  )
end

function pool:obtain()
  return #self.freeObjects == 0 and self.newObject() or table.remove(self.freeObjects)
end

function pool:free(obj)
  assert(obj, "An object to be freed must be passed.")

  table.insert(self.freeObjects, obj)
  if obj.reset then obj.reset() end
end

function pool:clear()
  for k in pairs(self.freeObjects) do
    self.freeObjects[k] = nil
  end
end

--

-- [[ Update ]] --
local mapName = getMapIDName(Game.mapID)
-- local localName = scriptPath:match("[\\/]([^\\/]-)$")
local map
local author = "Impulsx"
local AUTHOR_NAME = author
local gitHub = "https://raw.githubusercontent.com/" .. author .. "/GoS/master/"
local file = {
  script = {
    path = SCRIPT_PATH,
    name = SCRIPT_NAME .. ".lua"
  },
  common = {
    path = COMMON_PATH,
    name = SCRIPT_NAME .. ".lua"
  },
  sprite = {
    path = SPRITE_PATH,
    name = SCRIPT_NAME .. ".png"
  },
  sounds = {
    path = SOUNDS_PATH,
    name = SCRIPT_NAME .. ".mp3"
  },
  fonts = {
    path = FONTS_PATH,
    name = SCRIPT_NAME .. ".ttf"
  },
  version = {
    scriptpath = SCRIPT_PATH,
    commonpath = COMMON_PATH,
    name = SCRIPT_NAME .. ".version"
  }
}

_G.DamageLib = {
  ItemID = ItemID,
  RuneID = RuneID,
  Heros = HEROES,
  HerosPrio = HEROES[1],
  MeleeHeros = HEROES[2],
  HerosBaseAS = HEROES[3],
  ARAM = ARAM,
  BuffType = buffType,
  --monsterType = Monstertable,
  GetBaseAttackspeed = function(unit)
    return getBaseAttackspeed(unit)
  end,
  IsMelee = function(unit)
    return isMelee(unit) --returns bool
  end,
  pool = pool,
  file = file,
  EXTP = DamageLib.EXTP,
  GetMapIDName = function(mapID)
    map = getMapIDName(mapID)
    return map
  end,
  --
}

local function update()
  local function fileExists(path)
    local file = io.open(path, "r")
    if file ~= nil then
      io.close(file)
      return true
    else
      return false
    end
  end
  local function readAll(fileName)
    local f = assert(io.open(fileName, "r"))
    local content = f:read("*all")
    f:close()
    return content
  end
  local function downloadFile(path, fileName)
    local startTime = os.clock()
    DownloadFileAsync(gitHub .. fileName, path .. fileName, function() end)
    repeat until os.clock() - startTime > 3 or fileExists(path .. fileName)
  end
  local function readFile(path, fileName)
    local file = assert(io.open(path .. fileName, "r"))
    local result = file:read()
    file:close()
    return result
  end
  --[[ local function initializeScript()
    local function writeModule(content)
      local f = assert(io.open(file.common.path .. file.lua.name, content and "a" or "w"))
      if content then
        f:write(content)
      end
      f:close()
    end
    --
    writeModule()
    local newVersion = version
    --Write the core module
    writeModule(readAll(file.common.path .. file.common.name))
    -- writeModule(readAll(AUTO_PATH..coreName))
    -- writeModule(readAll(CHAMP_PATH..charName..dotlua))
    --Load the active module
    dofile(file.common.path .. file.common.name)
    if newVersion > version then
      print("*ERR* | " ..
        SCRIPT_NAME ..
        " | - [RE.initialize] - [*NEW* ver. " .. tostring(newVersion) .. "] > [ver. " .. tostring(version) .. "]")
    end
  end ]]

  downloadFile(file.version.commonpath, file.version.name)
  local newVersion = tonumber(readFile(file.version.commonpath, file.version.name))
  if newVersion > version then
    downloadFile(file.common.path, file.common.name)
    print("*WARN* NEW | " ..
      SCRIPT_NAME ..
      "ver. " .. version .. " | < [ver. " .. tostring(newVersion) .. "] Downloaded - Please RELOAD with [F6]")
    -- print("*WARNING* New " .. SCRIPT_NAME .. " [ver. " .. tostring(NewVersion) .. "] Downloaded - RELOADING")
  else
    local hasjit = false
    if jit then hasjit = true end
    local jitStatus = hasjit and "enabled" or "disabled"
    print("| " ..
      SCRIPT_NAME .. " | - [ver. " .. version .. " | EXTP: " .. jitStatus .. "] - Welcome to: " .. mapName .. "!");
  end
end
update()


-- Callbacks --
Callback.Add("Load", function()
  --
  Item = _G.SDK.ItemManager
  Buff = _G.SDK.BuffManager

  Target = _G.SDK.TargetSelector
  Orbwalker = _G.SDK.Orbwalker
  Damage = _G.SDK.Damage
  Spell = _G.SDK.Spell
  Object = _G.SDK.ObjectManager
  Attack = _G.SDK.Attack
  Data = _G.SDK.Data
  Cursor = _G.SDK.Cursor
  IsRecalling = _G.SDK.IsRecalling
  -- getdmg call overrides
  DamageLib.EXTP = jit and true or false
  if not DamageLib.EXTP then
    getdmg = function(...) return getcacheddmg(...) end
  end
  Callback.Add("Tick", function()
    --
    table.insert(_G.SDK.OnTick, function() end)
  end)
end)
return DamageLib

-- c:
if _G.WR_COMMON_LOADED then
    print("[WR] is already loaded, please unload other WR AIO script and try again !")
    return
end
_G.WR_COMMON_LOADED = true
local LoadCallbacks = {}
local MENU_PRED = 1
local PredLoaded = false

--# Enable/Disable
local prtchat = false
--local changelog = false

--
local myHero = myHero
local charName = myHero.charName
local currentData = {
    Champions = {
        charName = {
            Version = 1.00,
            Changelog = "",
        },
    },
    Loader = {
        Version = 1.00,
        Changelog = "",

    },
    Dependencies = {
        commonLib = {
            Version = 1.00,
        },
        prediction = {
            Version = 1.00,
        },
        changelog = {
            Version = 1.00,
        },
        callbacks = {
            Version = 1.00,
        },
        menuLoad = {
            Version = 1.00,
        },
    },
    Utilities = {
        baseult = {
            Version = 1.00,
        },
        evade = {
            Version = 1.00,
        },
        tracker = {
            Version = 1.00,
        },
        orbwalker = {
            Version = 1.00,
        },
    },
    Core = {
        Version = 1.00,
        Changelog = "\n\n" ..
                "\n" ..
                "\n" ..
                "",
    },
}

--# Libs --
require "MapPositionGOS"
require "DamageLib"
--DamageLib = require"DamageLib"
require "2DGeometry"

local Menu, Champion, Spell, Prediction, Tick, BuffExplorer, Animation, Vision, Path, Interrupter

local GG_Target, GG_Orbwalker, GG_Buff, GG_Damage, GG_Spell, GG_Object, GG_Attack, GG_Data, GG_Cursor, SDK_IsRecalling

--# Locals

local table = table
local table_insert = assert(table.insert)
local table_sort = assert(table.sort)
local table_remove = assert(table.remove)

local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring

local io = io
local math = math
local string = string
local os = os

local GetTickCount = GetTickCount
local TickCount = GetTickCount

local mousePos = mousePos
local cursorPos = cursorPos

--local Callback = Callback
--
local TEAM_JUNGLE = 300
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = TEAM_JUNGLE - TEAM_ALLY
-- Control API
local Control = Control
local KeyDown = Control.KeyDown
local KeyUp = Control.KeyUp
local IsKeyDown = Control.IsKeyDown
local SetCursorPos = Control.SetCursorPos
-- Game API
local Game = Game
local GameCanUseSpell = Game.CanUseSpell
local Timer = Game.Timer
local Latency = Game.Latency
local HeroCount = Game.HeroCount
local Hero = Game.Hero
local MinionCount = Game.MinionCount
local Minion = Game.Minion
local TurretCount = Game.TurretCount
local Turret = Game.Turret
local WardCount = Game.WardCount
local Ward = Game.Ward
local ObjectCount = Game.ObjectCount
local Object = Game.Object
local MissileCount = Game.MissileCount
local Missile = Game.Missile
local ParticleCount = Game.ParticleCount
local Particle = Game.Particle
-- Draw API
local Draw = Draw
local DrawCircle = Draw.Circle
local DrawLine = Draw.Line
local DrawColor = Draw.Color
local DrawMap = Draw.CircleMinimap
local DrawText = Draw.Text
--Vector API
local Vector = Vector


local HITCHANCE_IMPOSSIBLE = 0
local HITCHANCE_COLLISION = 1
local HITCHANCE_NORMAL = 2
local HITCHANCE_HIGH = 3
local HITCHANCE_IMMOBILE = 4
local HITCHANCE_DASHING = 5
--
local SpellTypePress = "Press" and -2
local SpellTypeTargetted = "Targetted" and -1
local SpellTypeSkillShot = "SkillShot" and "linear" and 0
local SpellTypeAOE = "AOE" and "circular" and 1
local SpellTypeCone = "Cone" and "conic" and 2
--
local COLLISION_MINION = 0
local COLLISION_ALLYHERO = 1
local COLLISION_ENEMYHERO = 2
local COLLISION_YASUOWALL = 3

local TEAM ={
    JUNGLE = 300,
    ALLY = myHero.team,
    ENEMY = 300 - myHero.team,
}
local ORBWALKER = {
    MODE = {
        NONE = -1,
        COMBO = 0,
        HARASS = 1,
        LANECLEAR = 2,
        JUNGLECLEAR = 3,
        LASTHIT = 4,
        FLEE = 5,
    }
}
local Color = {
    Red = DrawColor(255, 255, 0, 0),
    Green = DrawColor(255, 0, 255, 0),
    Blue = DrawColor(255, 0, 0, 255),
    Yellow = DrawColor(255, 255, 255, 0),
    Aqua = DrawColor(255, 0, 255, 255),
    Fuchsia = DrawColor(255, 255, 0, 255),
    Teal = DrawColor(255, 0, 128, 128),
    Gray = DrawColor(128, 128, 128, 128),
    White = DrawColor(255, 255, 255, 255), --default/nil
    Black = DrawColor(255, 0, 0, 0),
}
local ItemID = DamageLib.ItemID
local wardItemIDs = {
    ItemID.StealthWard, ItemID.ControlWard, ItemID.FarsightAlteration, ItemID.ScarecrowEffigy, ItemID.StirringWardstone, ItemID.VigilantWardstone, ItemID.WatchfulWardstone, ItemID.BlackMistScythe, ItemID.HarrowingCrescent, ItemID.SpectralSickle, ItemID.PauldronsofWhiterock, ItemID.RunesteelSpaulders, ItemID.SteelShoulderguards,ItemID.BulwarkoftheMountain, ItemID.TargonsBuckler, ItemID.RelicShield, ItemID.ShardofTrueIce, ItemID.Frostfang, ItemID.SpellthiefsEdge,
}
local ItemHotKey = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7 }
local Emote = {
    Joke = HK_ITEM_1,
    Taunt = HK_ITEM_2,
    Dance = HK_ITEM_3,
    Mastery = HK_ITEM_5,
    Laugh = HK_ITEM_7,
    Casting = false
}
local CastEmote = function(Emote)
    if not Emote or Emote.Casting or myHero.attackData.state == STATE_WINDUP then
        return
    end
    Emote.Casting = true;
    KeyDown(HK_LUS);
    KeyDown(Emote);
    return{
    DelayAction(function()
        KeyUp(Emote)
        KeyUp(HK_LUS)
        Emote.Casting = false
    end, 0.01),
}end
-- pool
local pool = {}
local poolmt = {__index = pool}

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

-- Tick
--[[ ZeTick
local Tick, Tick2 = 0, 0
local ZeTick = function(thing, one)
    local time = GetTickCount()
	if time > Tick + Menu.Tick.Delay:Value() and not one then
		Tick = time
		thing()
	end
	if one and time > Tick2 + one then
		Tick2 = time
		thing()
	end
    return{
}end
local OneTick = function(name, custom)return{
	Callback.Add("Tick", function() ZeTick(name, custom) end)
}end
]]
Tick = function()
    return {
        Tick = 0,
        Tick2 = 0,
        ZeTick = function(self, thing, delay)
            local time = GetTickCount()
            if time > self.Tick + Menu.Tick.Delay:Value() and not delay then
                self.Tick = time
                thing()
            end
            if delay and time > self.Tick2 + delay then
                self.Tick2 = time
                thing()
            end
            return {
            }
        end,
        OneTick = function(self, name, delay)
            return {
                Callback.Add("Tick", function() self.ZeTick(name, delay) end)
            }
        end,
    }
end

-- Spell --
Spell = function(SpellData)return{
    --spellData
    Slot           = SpellData.Slot,
    Range          = SpellData.Range or math.huge,
    Delay          = SpellData.Delay or 0.25,
    Speed          = SpellData.Speed or math.huge,
    Radius         = SpellData.Radius or SpellData.Width or 0,
    Width          = SpellData.Width or SpellData.Radius or 0,
    From           = SpellData.From or myHero,
    Collision      = SpellData.Collision or false,
    CollisionTypes = SpellData.CollisionTypes or nil,
    Type           = SpellData.Type or SpellTypePress or 0,
    DmgType        = SpellData.DmgType or "Physical" or 1,
    spellData = function(self)
        self.Slot          = SpellData.Slot

        local Data         = myHero:GetSpellData(self.Slot)
        self.name          = Data.name
        self.level         = Data.level
        self.castTime      = Data.castTime
        self.cd            = Data.cd
        self.currentCd     = Data.currentCd
        self.ammo          = Data.ammo
        self.ammoTime      = Data.ammoTime
        self.ammoCd        = Data.ammoCd
        self.ammoCurrentCd = Data.ammoCurrentCd
        self.toggleState   = Data.toggleState
        self.range         = Data.range
        self.mana          = Data.mana
        self.width         = Data.width
        self.speed         = Data.speed
        self.targetingType = Data.targetingType
        self.coneAngle     = Data.coneAngle
        self.coneDistance  = Data.coneDistance
        self.acceleration  = Data.acceleration
        self.castFrame     = Data.castFrame
        self.maxSpeed      = Data.maxSpeed
        self.minSpeed      = Data.minSpeed

        self.Range          = SpellData.Range or self.range or math.huge
        self.Delay          = SpellData.Delay or 0.25 --or self.castTime?
        self.Speed          = SpellData.Speed or self.speed or math.huge
        self.Radius         = SpellData.Radius or SpellData.Width or self.width or 0
        self.Width          = SpellData.Width or SpellData.Radius or self.width or 0
        self.From           = SpellData.From or myHero
        self.Collision      = SpellData.Collision or false
        self.CollisionTypes = SpellData.CollisionTypes or nil
        self.Type           = SpellData.Type or SpellTypePress or 0 --or self.targetingType?
        self.DmgType        = SpellData.DmgType or "Physical" or 1
        return self
    end,
    OnTick = function(self,...)
        return self
    end,
    OnDraw = function(self,...)
        return self
    end,
    OnWndMsg = function(self,...)
        return self
    end,
    --
    IsReady = function(self)
        return GameCanUseSpell(self.Slot) == READY
    end,
    CanCast = function(self,unit, range, from)
        from = from or self.From.pos
        range = range or self.Range
        return unit and unit.valid and unit.visible and not unit.dead and (not range or GetDistance(from, unit) <= range)
    end,
    --# Farm Stuff

    --# Damage
    CalcDamage = function(self,source, target, DamageType, amount, IsAA)
        return DamageLib:CalcDamage(source, target, DamageType, amount, IsAA)
    end,
    GetAADamage = function(self,source, target, respectPassives)
        return DamageLib:GetAADamage(source, target, respectPassives)
    end,
    getdmg = function(self,spell, target, source, stage, level)
        return DamageLib:getdmg(spell, target, source, stage, level)
    end,
    GetDamage = function(self,target, stage)
    local slot = self:SlotToString()
        return getdmg(slot, target, self.From, stage or 1)-- self:IsReady() or 0 and false --self:IsReady() and getdmg(slot, target, self.From, stage or 1) or 0
    end,
    --
    SlotToHK = function(self)
        return ({ [_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R, [SUMMONER_1] = HK_SUMMONER_1, [SUMMONER_2] = HK_SUMMONER_2 })[self.Slot]
    end,

    SlotToString = function(self)
        return ({ [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R", [SUMMONER_1] = myHero:GetSpellData(SUMMONER_1).name, [SUMMONER_2] = myHero:GetSpellData(SUMMONER_1).name })[self.Slot]
    end,
    --
    GetPrediction = function(self,target, minHitchance)
    return Prediction:GetBestCastPosition(target, self, minHitchance)
    end,

    Cast = function(self,castOn)
    if not self:IsReady() or ShouldWait() then
        return
    end
    --
    local slot = self:SlotToHK()
    --print("cast ".." "..tostring(self:SlotToString()).." "..self.Type)

    if self.Type == SpellTypePress then
        KeyDown(slot)
        return KeyUp(slot)
    end
    --
    if castOn == nil then
        return
    end
    --if not _G.WR_PREDICTION_LOADED then return self:CastToPred(castOn) end --breaks AOE non-targeted
    --
    local pos = castOn.x and castOn
    local targ = castOn.health and castOn
    if self.Type == SpellTypeTargetted then
        return Control.CastSpell(slot, castOn)
    end
    if self.Type == SpellTypeAOE and pos then
        local bestPos, hC = self:GetBestCircularCastPos(targ, GetEnemyHeroes(self.Range + self.Radius))
        pos = hC >= HITCHANCE_NORMAL and bestPos or pos
    end
    --
    if (targ and not targ.pos:To2D().onScreen) then
        return
    elseif (pos and not pos:To2D().onScreen) then
        if self.Type == SpellTypeAOE then
            local mapPos = pos:ToMM()
            Control.CastSpell(slot, mapPos.x, mapPos.y)
        else
            pos = myHero.pos:Extended(pos, 200)
            if not pos:To2D().onScreen then
                return
            end
        end
    end
    --
    return Control.CastSpell(slot, targ or pos)
    end,

    CastToPred = function(self,target, minHitchance)
    local slot = self:SlotToHK()

    if not self:IsReady() or ShouldWait() then
        return
    end
    if self.Type == SpellTypePress then
        KeyDown(slot)
        return KeyUp(slot)
    end
    if not target then
        return
    end
    if self.Type == SpellTypeTargetted then
        return Control.CastSpell(slot, target)
    end
    --
    local unitPos, predPos, hC, hit, hitCount, timetoHit, pred = self:GetPrediction(target, minHitchance)
    if _G.WR_PREDICTION_LOADED and predPos and hC >= minHitchance then
        return self:Cast(predPos)
    end
    if _G.WR_PREDICTION_LOADED then return end
    --
    if self.Type == SpellTypeAOE and pred then
        local bestDistance = self.Radius --or self.Range
        local minTargets = 2 and clamp(hitCount,2,5)
        local maxtimetoHit = 3
        local bestAoe = nil
        local bestCount = 0
        for i = 1, #pred do
            local aoe = pred[i]
            if aoe.HitChance >= minHitchance and aoe.TimeToHit <= maxtimetoHit and aoe.Count >= minTargets then
                if aoe.Count > bestCount or (aoe.Count == bestCount and aoe.Distance < bestDistance) then
                    bestDistance = aoe.Distance
                    bestCount = aoe.Count
                    bestAoe = aoe
                end
            end
        end
        if bestAoe then
            return Control.CastSpell(slot, bestAoe.CastPosition)
        end
    end
    if predPos and hit then
        return Control.CastSpell(slot, predPos)
    end
    end,

    OnImmobile = function(self,target)
    local TargetImmobile, ImmobilePos, ImmobileCastPosition = Prediction:IsImmobile(target, self)
    if self.Collision then
        local colStatus = #(mCollision(self.From.pos, target, self)) > 0
        if colStatus then
            return
        end
        return TargetImmobile, ImmobilePos, ImmobileCastPosition
    end
    return TargetImmobile, ImmobilePos, ImmobileCastPosition
    end,

    --# Draw
    Draw = function(self,r, g, b)
    if not self.DrawColor then
        self.DrawColor = DrawColor(255, r, g, b)
        self.DrawColor2 = DrawColor(80, r, g, b)
    end
    if self.Range and self.Range ~= math.huge then
        if self:IsReady() then
            DrawCircle(self.From.pos, self.Range, 5, self.DrawColor)
        else
            DrawCircle(self.From.pos, self.Range, 5, self.DrawColor2)
        end
        return true
    end
    end,
    DrawMap = function(self,r, g, b)
    if not self.DrawColor then
        self.DrawColor = DrawColor(255, r, g, b)
        self.DrawColor2 = DrawColor(80, r, g, b)
    end
    if self.Range and self.Range ~= math.huge then
        if self:IsReady() then
            DrawMap(self.From.pos, self.Range, 5, self.DrawColor)
        else
            DrawMap(self.From.pos, self.Range, 5, self.DrawColor2)
        end
        return true
    end
    end,
--[[     private void DoWallFlee()
    {
        if (!this.spells[SpellSlot.Q].IsReady() || !this.keyLinks["fleeKey"].Value.Active)
        {
            return;
        }

        const float JumpRange = 250f;
        var extendedPosition = ObjectManager.Player.ServerPosition.Extend(Game.CursorPos, JumpRange);
        if (this.IsOverWall(ObjectManager.Player.ServerPosition, extendedPosition) && !extendedPosition.IsWall())
        {
            this.spells[SpellSlot.Q].Cast(extendedPosition);
        }
    }, ]]
}end

-- Champion
if Champion == nil then
    --# Menus --
    --local charName = myHero.charName
    local url = "https://raw.githubusercontent.com/Impulsx/LoL-Icons/master/"
    local HeroIcon = { url .. charName .. ".png" }
    local HeroSprites = {
    url .. charName .. "Q.png",
    url .. charName .. 'W.png',
    url .. charName .. 'E.png',
    url .. charName .. "R.png",
    url .. charName .. "R2.png",
    url .. charName .. "P.png",
    }
    local icons = {
    Hero = HeroIcon[1],
    Q = HeroSprites[1],
    W = HeroSprites[2],
    E = HeroSprites[3],
    R = HeroSprites[4],
    R2 = HeroSprites[5],
    P = HeroSprites[6],
    }
    local Menu = {};
    Menu = MenuElement({ id = charName, name = "[ImpulsAIO] | " .. charName, type = MENU, leftIcon = icons.Hero })
    Menu:MenuElement({ name = " ", drop = { "Spell Settings" },})
    Menu:MenuElement({ id = "Q", name = "Q Settings", type = MENU, leftIcon = icons.Q })
    local extendedQsettings = charName == "Lucian" and Menu:MenuElement({ id = "Q2", name = "Q2 Settings", type = MENU, leftIcon = icons.Q, tooltip = "Extended Q Settings" })
    Menu:MenuElement({ id = "W", name = "W Settings", type = MENU, leftIcon = icons.W })
    Menu:MenuElement({ id = "E", name = "E Settings", type = MENU, leftIcon = icons.E })
    Menu:MenuElement({ id = "R", name = "R Settings", type = MENU, leftIcon = icons.R })
    -- Draw
    Menu:MenuElement({ name = " ", drop = { "Global Settings" },})
    Menu:MenuElement({ id = "Draw", name = "Draw Settings", type = MENU })
    Menu.Draw:MenuElement({ id = "ON", name = "Enable Drawings", value = true })
    Menu.Draw:MenuElement({ id = "TS", name = "Draw Selected Target", value = true, leftIcon = icons.Hero })
    Menu.Draw:MenuElement({ id = "Dmg", name = "Draw Damage On HP", value = false, leftIcon = icons.Hero })
    local extendedDrawsettings = charName == "Kalista" and Menu.Draw:MenuElement({ id = "drawEdmg", name = "Draw E Damage", value = true, leftIcon = icons.Hero })
    Menu.Draw:MenuElement({ id = "Q", name = "Q", value = false, leftIcon = icons.Q })
    Menu.Draw:MenuElement({ id = "W", name = "W", value = false, leftIcon = icons.W })
    Menu.Draw:MenuElement({ id = "E", name = "E", value = false, leftIcon = icons.E })
    Menu.Draw:MenuElement({ id = "R", name = "R", value = false, leftIcon = icons.R })
    -- DBHelper
    --Menu = MenuElement({ type = MENU, id = "DBHelper", name = "[Dash.Blink]Helper" })
    Menu:MenuElement({ id = "DBHelper", name = "[Dash.Blink]Helper", type = MENU })
    Menu.DBHelper:MenuElement({ id = "Q", name = "Q", value = false, leftIcon = icons.Q })
    Menu.DBHelper:MenuElement({ id = "W", name = "W", value = false, leftIcon = icons.W })
    Menu.DBHelper:MenuElement({ id = "E", name = "E", value = false, leftIcon = icons.E })
    Menu.DBHelper:MenuElement({ id = "R", name = "R", value = false, leftIcon = icons.R })
    --TODO per spell
    Menu.DBHelper:MenuElement({ id = "DBfake", name = "Key to use", value = false, key = string.byte("E") })
    Menu.DBHelper:MenuElement({ id = "DBlol", name = "key in game", value = false, key = string.byte("L") })
    Menu.DBHelper:MenuElement({ id = "dash", name = "dash ability", value = 1, drop = { "[Q]", "[W]", "[E]", "[R]" } })
    Menu.DBHelper:MenuElement({ id = "DBDelay", name = "DB Delay", value = 1000, min = 100, max = 10000, step = 100})
    -- Tick
    Menu:MenuElement({ id = "Tick", name = "[Tick]Helper", type = MENU })
    Menu.Tick:MenuElement({id = "Delay", name ="Ticks Delay", value = 30, min = 1, max = 150, step = 1})
    Menu.Tick:MenuElement({ name = " ", drop = "+Tick = < [delay] > = FPS+", type = SPACE })

    -- locals
    local LastChatOpenTimer = 0
    local LevelUpKeyTimer = 0
    local LastDBfake = 0
    local genericDelay = 0.25

    Champion = {
        CanAttackCb = function()
            return GG_Spell:CanTakeAction({ q = genericDelay, w = genericDelay, e = genericDelay, r = genericDelay })
        end,
        CanMoveCb = function()
            return GG_Spell:CanTakeAction({ q = genericDelay, w = genericDelay, e = genericDelay, r = genericDelay })
        end,
        OnPostAttackTick = function(self,PostAttackTimer)
            self:PreTick()
            self:DBLogic()
            -- delay with PostAttackTimer
            if self.Timer < PostAttackTimer + 0.3 then
				self:DelayLogic()
			end
        end,
        OnLoad = function(self)
            self.DBDelay = Menu.DBHelper.DBDelay:Value()
            self.DBHelper = Menu.DBHelper.DBlol:Key()
            self.Enemies, self.Recalling = {}, {}
            self.Spells()
            return self
        end,
        OnWndMsg = function(self,msg, wParam)
            if wParam == Menu.DBHelper.DBfake:Key() then
                LastDBfake = os.clock()
            end
            if msg == HK_LUS or wParam == HK_LUS then
                LevelUpKeyTimer = os.clock() --GetTickCount()
            end
        end,
        --ProcessRecall SDK_IsRecalling
        ProcessRecall = function(self, unit, recall)
            if GetTeam(unit) ~= GetTeam(myHero) then
                if recall.isStart then
                    table.insert(self.Recalling, { champ = unit, start = GetGameTimer(), duration = (recall.totalTime / 1000
                        ) })
                else
                    for i, recall in pairs(self.Recalling) do
                        if recall.champ == unit then
                            table.remove(self.Recalling, i)
                        end
                    end
                end
            end
        end,
        ProcessRecall = function(self, unit, recall)
            if not unit.isEnemy then return end
            if recall.isStart then
                table_insert(self.Recalling, {object = unit, start = Game.Timer(), duration = (recall.totalTime*0.001)})
            else
                  for i, recall in pairs(self.Recalling) do
                    if recall.object.networkID == unit.networkID then
                          TableRemove(self.Recalling, i)
                    end
                  end
            end
        end,
        OnProcessRecall = function(self, hero,recallProc)
            local heroIndex = getEnemyIndex(hero.networkID)
            if heroIndex ~= nil then
                if recallProc.isStart then
                    enemies[heroIndex].recall.isRecalling = true
                    enemies[heroIndex].recall.startTime = GetTickCount()
                    enemies[heroIndex].recall.totalTime = recallProc.totalTime
                elseif recallProc.isFinish then
                    enemies[heroIndex].recall.isRecalling = false
                    enemies[heroIndex].atBase = true
                    enemies[heroIndex].circleRadius = 0
                    enemies[heroIndex].lastSeen = GetTickCount()
                elseif not recallProc.isFinish and not recallProc.isStart then
                    enemies[heroIndex].recall.isRecalling = false
                end
            end
        end,
        -- tick
        PreTick = function(self)
            self.IsNone = GG_Orbwalker.Modes[ORBWALKER.MODE.NONE]
            self.IsCombo = GG_Orbwalker.Modes[ORBWALKER.MODE.COMBO]
            self.IsHarass = GG_Orbwalker.Modes[ORBWALKER.MODE.HARASS]
            self.IsLaneClear = GG_Orbwalker.Modes[ORBWALKER.MODE.LANECLEAR]
            self.IsJungleClear = GG_Orbwalker.Modes[ORBWALKER.MODE.JUNGLECLEAR]
            self.IsLastHit = GG_Orbwalker.Modes[ORBWALKER.MODE.LASTHIT]
            self.IsFlee = GG_Orbwalker.Modes[ORBWALKER.MODE.FLEE]
            self.AttackTarget = nil
            self.CanAttackTarget = false
            self.IsAttacking = GG_Orbwalker:IsAutoAttacking()
            if not self.IsAttacking and (self.IsCombo or self.IsHarass) then
                self.AttackTarget = GG_Target:GetComboTarget()
                self.CanAttack = GG_Orbwalker:CanAttack()
                if self.AttackTarget and self.CanAttack then
                    self.CanAttackTarget = true
                else
                    self.CanAttackTarget = false
                end
            end
            self.Timer = Game.Timer()
            self.Pos = myHero.pos
            self.BoundingRadius = myHero.boundingRadius
            self.Range = myHero.range + self.BoundingRadius
            self.ManaPercent = 100 * myHero.mana / myHero.maxMana
            self.AllyHeroes = GG_Object:GetAllyHeroes(2000)
            self.EnemyHeroes = GG_Object:GetEnemyHeroes(false, false, true)
            --Utils.CachedDistance = {}
        end,
        OnTick = function(self)
            if Game.IsChatOpen() then
                LastChatOpenTimer = os.clock()
            end
            --[[ if Control.IsKeyDown(HK_LUS) then
                LevelUpKeyTimer = os.clock()
            end
            ]]
            Champion:DBLogic()
            if self.IsAttacking or self.CanAttackTarget or self.AttackTarget then
                return
            end
        end,
        DBLogic = function(self)
            self.dashkey = _E
            --self.DBkey = {}
            self.DBDelay = Menu.DBHelper.DBDelay:Value()
            if Menu.DBHelper.dash:Value() == 1 then
                self.dashkey = _Q
            elseif Menu.DBHelper.dash:Value() == 2 then
                self.dashkey = _W
            elseif Menu.DBHelper.dash:Value() == 3 then
                self.dashkey = _E
            elseif Menu.DBHelper.dash:Value() == 4 then
                self.dashkey = _R
            end
            local timer = GetTickCount()
            if self.DBHelper ~= nil then
                if _G.SDK.Cursor.Step == 0 then
                    GG_Cursor:Add(self.DBHelper, mousePos)
                    LastDBfake = os.clock()
                    self.DBHelper = nil
                end
                return
            end
            if not (
                os.clock() < LastDBfake + genericDelay
                    and Game.CanUseSpell(self.dashkey) == 0
                    and not Control.IsKeyDown(HK_LUS)
                    and not myHero.dead
                    and not Game.IsChatOpen()
                    and Game.IsOnTop()
                )
            then
                return
            end
            if self.LastDB and timer < self.LastDB + self.DBDelay then
                return
            end
            if timer < LastChatOpenTimer + self.DBDelay then
                return
            end
            if timer < LevelUpKeyTimer + self.DBDelay then
                return
            end
            self.LastDB = timer
            if GG_Cursor.Step == 0 then
                GG_Cursor:Add(Menu.DBHelper.DBlol:Key(), mousePos)
                LastDBfake = os.clock()
                return
            end
            self.DBHelper = Menu.DBHelper.DBlol:Key()
        end,
        DelayLogic = function(self)
            --Delayed Logic
        end,
        Spells = function(self)
            self.Q = Spell({
                Slot = 0,
                Range = 420,
                Delay = 420,
                Speed = 420,
                Radius = 420,
                Collision = true,
                CollisionTypes = { COLLISION_MINION, COLLISION_ENEMYHERO, COLLISION_YASUOWALL },
                From = myHero,
                Type = SpellTypeSkillShot
            } and Spell.spellData)
            self.W = Spell({
                Slot = 1,
                Range = 420,
                Delay = 420,
                Speed = 420,
                Radius = 420,
                Collision = false,
                From = myHero,
                Type = SpellTypeAOE
            } and Spell.spellData)
            self.E = Spell({
                Slot = 2,
                Range = 420,
                Delay = 420,
                Speed = math.huge,
                Radius = 420,
                Collision = false,
                From = myHero,
                Type = SpellTypePress
            } and Spell.spellData)
            self.R = Spell({
                Slot = 3,
                Range = 420,
                Delay = 420,
                Speed = math.huge,
                Radius = 420,
                Collision = false,
                From = myHero,
                Type = SpellTypePress
            } and Spell.spellData)
        end,
        isReady = function(self,...) --self.slot/spells
            return GG_Spell:IsReady(self.Spells, { q = genericDelay, w = genericDelay, e = genericDelay, r = genericDelay })
        end,
    }
end

if Champion ~= nil then
    --# Orbwalker/SDK Callbacks
    Callback.Add("Load", function()
        GG_Target = _G.SDK.TargetSelector
        GG_Orbwalker = _G.SDK.Orbwalker
        GG_Buff = _G.SDK.BuffManager
        GG_Damage = _G.SDK.Damage
        GG_Spell = _G.SDK.Spell
        GG_Object = _G.SDK.ObjectManager
        GG_Attack = _G.SDK.Attack
        GG_Data = _G.SDK.Data
        GG_Cursor = _G.SDK.Cursor
        SDK_IsRecalling = _G.SDK.IsRecalling
        GG_Orbwalker:CanAttackEvent(Champion.CanAttackCb)
        GG_Orbwalker:CanMoveEvent(Champion.CanMoveCb)
        --# Load
        if Champion.OnLoad then
            Champion:OnLoad()
        end
        --# Orb
        if Champion.OnPreAttack then
            GG_Orbwalker:OnPreAttack(Champion.OnPreAttack)
        end
        if Champion.OnAttack then
            GG_Orbwalker:OnAttack(Champion.OnAttack)
        end
        if Champion.OnPostAttack then
            GG_Orbwalker:OnPostAttack(Champion.OnPostAttack)
        end
        if Champion.OnPostAttackTick then
            GG_Orbwalker:OnPostAttackTick(Champion.OnPostAttackTick)
        end
        --#
        --Tick.OneTick(function()
            --delay = 12000
            --[[ smite = (
                myHero:GetSpellData(SUMMONER_1).name:lower():find("smite") and SUMMONER_1
                or
                myHero:GetSpellData(SUMMONER_2).name:lower():find("smite") and SUMMONER_2
                or nil); ]]
        --    end, 12000)
        --Tick.OneTick(function() Champion:OnTick() end)
        if Champion.PreTick then
            Champion:PreTick()
        end
        if Champion.OnTick then
            table_insert(_G.SDK.OnTick, function()
                --DH:drawSpellData(myHero, _W, 0, 0, 22)
                --DH:drawActiveSpell(myHero, 500, 0, 22)
                --DH:drawHeroesDistance(22)
                Champion:PreTick()
                if not SDK_IsRecalling(myHero) then
                    Champion:OnTick()
                end
            end)
        end
        if Champion.OnDraw then
            table_insert(_G.SDK.OnDraw, function(...)
                Champion:OnDraw(...)
            end)
        end

        if Champion.OnWndMsg then
            table_insert(_G.SDK.OnWndMsg, function(msg, wParam)
                Champion:OnWndMsg(msg, wParam)
            end)
        end
        if Champion.ProcessRecall then
            table_insert(_G.SDK.ProcessRecall, function(unit,recall)
                Champion:ProcessRecall(unit,recall)
            end)
        end
    end)
    --Callback.Add("UnLoad",function() end)
    return
end

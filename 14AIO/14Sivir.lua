

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero

local GameMissileCount  = Game.MissileCount
local GameMissile       = Game.Missile

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector

local lastQ = 0
local lastW = 0
local lastE = 0
local lastMove = 0
local lastAttack = 0

local Enemys =   {}
local Allys  =   {}

require 'GGPrediction'

local shellSpells = {
    ["NautilusRavageStrikeAttack"]  = {charName = "Nautilus"    ,   slot = "Passive"} ,
    ["RekSaiWUnburrowLockout"]      = {charName = "RekSai"      ,   slot = "W"},
    ["SkarnerPassiveAttack"]        = {charName = "Skarner"     ,   slot = "E Passive"},
    ["WarwickRChannel"]             = {charName = "Warwick"     ,   slot = "R"},  -- need test
    ["XinZhaoQThrust3"]             = {charName = "XinZhao"     ,   slot = "Q3"},
    ["VolibearQAttack"]             = {charName = "Volibear"    ,   slot = "Q"},
    ["LeonaShieldOfDaybreakAttack"] = {charName = "Leona"       ,   slot = "Q"},
    ["GoldCardPreAttack"]           = {charName = "TwistedFate" ,   slot = "GoldW"},
    ["PowerFistAttack"]             = {charName = "Blitzcrank"  ,   slot = "E"},

    ["Frostbite"]               = {charName = "Anivia"      , slot = "E" , delay = 0.25, speed = 1600       , isMissile = true },
    ["AnnieQ"]                  = {charName = "Annie"       , slot = "Q" , delay = 0.25, speed = 1400       , isMissile = true },
    ["BrandE"]                  = {charName = "Brand"       , slot = "E" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["BrandR"]                  = {charName = "Brand"       , slot = "R" , delay = 0.25, speed = 1000       , isMissile = true },   -- to be comfirm brand R delay 0.25 or 0.5
    ["CassiopeiaE"]             = {charName = "Cassiopeia"  , slot = "E" , delay = 0.15, speed = 2500       , isMissile = true },   -- delay to be comfirm
    ["CamilleR"]                = {charName = "Camille"     , slot = "R" , delay = 0.5 , speed = math.huge  , isMissile = false},   -- delay to be comfirm
    ["Feast"]                   = {charName = "Chogath"     , slot = "R" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["DariusExecute"]           = {charName = "Darius"      , slot = "R" , delay = 0.25, speed = math.huge  , isMissile = false},    -- delay to be comfirm
    ["EliseHumanQ"]             = {charName = "Elise"       , slot = "Q1", delay = 0.25, speed = 2200       , isMissile = true },
    ["EliseSpiderQCast"]        = {charName = "Elise"       , slot = "Q2", delay = 0.25, speed = math.huge  , isMissile = false},
    ["Terrify"]                 = {charName = "FiddleSticks", slot = "Q" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["FiddlesticksDarkWind"]    = {charName = "FiddleSticks", slot = "E" , delay = 0.25, speed = 1100       , isMissile = true },
    ["GangplankQProceed"]       = {charName = "Gangplank"   , slot = "Q" , delay = 0.25, speed = 2600       , isMissile = true },
    ["GarenQAttack"]            = {charName = "Garen"       , slot = "Q" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["GarenR"]                  = {charName = "Garen"       , slot = "E" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["SowTheWind"]              = {charName = "Janna"       , slot = "W" , delay = 0.25, speed = 1600       , isMissile = true },
    ["JarvanIVCataclysm"]       = {charName = "JarvanIV"    , slot = "R" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["JayceToTheSkies"]         = {charName = "Jayce"       , slot = "Q2", delay = 0.25, speed = math.huge  , isMissile = false}, -- seems speed base on distance, lazy to find the forumla , maybe fixed delay
    ["JayceThunderingBlow"]     = {charName = "Jayce"       , slot = "E2", delay = 0.25, speed = math.huge  , isMissile = false},
    ["KatarinaQ"]               = {charName = "Katarina"    , slot = "Q" , delay = 0.25, speed = 1600       , isMissile = true },
    ["KatarinaE"]               = {charName = "Katarina"    , slot = "E" , delay = 0.1 , speed = math.huge  , isMissile = false}, -- delay to be comfirm
    ["NullLance"]               = {charName = "Kassadin"    , slot = "Q" , delay = 0.25, speed = 1400       , isMissile = true },
    ["KhazixQ"]                 = {charName = "Khazix"      , slot = "Q1", delay = 0.25, speed = math.huge  , isMissile = false},
    ["KhazixQLong"]             = {charName = "Khazix"      , slot = "Q2", delay = 0.25, speed = math.huge  , isMissile = false},
    ["BlindMonkRKick"]          = {charName = "LeeSin"      , slot = "R" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["LeblancQ"]                = {charName = "Leblanc"     , slot = "Q" , delay = 0.25, speed = 2000       , isMissile = true },
    ["LeblancRQ"]               = {charName = "Leblanc"     , slot = "RQ", delay = 0.25, speed = 2000       , isMissile = true },
    ["LissandraREnemy"]         = {charName = "Lissandra"   , slot = "R" , delay = 0.5 , speed = math.huge  , isMissile = false},
    ["LucianQ"]                 = {charName = "Lucian"      , slot = "Q" , delay = 0.25, speed = math.huge  , isMissile = false}, --  delay = 0.4 − 0.25 (based on level)
    ["LuluWTwo"]                = {charName = "Lulu"        , slot = "W" , delay = 0.25, speed = 2250       , isMissile = true },
    ["SeismicShard"]            = {charName = "Malphite"    , slot = "Q" , delay = 0.25, speed = 1200       , isMissile = true },
    ["MalzaharE"]               = {charName = "Malzahar"    , slot = "E" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["MalzaharR"]               = {charName = "Malzahar"    , slot = "R" , delay = 0   , speed = math.huge  , isMissile = false},
    ["AlphaStrike"]             = {charName = "MasterYi"    , slot = "Q" , delay = 0   , speed = math.huge  , isMissile = false},
    ["MissFortuneRicochetShot"] = {charName = "MissFortune" , slot = "Q" , delay = 0.25, speed = 1400       , isMissile = true },
    ["NasusW"]                  = {charName = "Nasus"       , slot = "W" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["NautilusGrandLine"]       = {charName = "Nautilus"    , slot = "R" , delay = 0.5 , speed = 1400       , isMissile = true },  -- delay to be comfirm
    ["NunuQ"]                   = {charName = "Nunu"        , slot = "Q" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["OlafRecklessStrike"]      = {charName = "Olaf"        , slot = "E" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["PantheonQ"]               = {charName = "Pantheon"    , slot = "Q" , delay = 0.25, speed = 1500       , isMissile = true },
    ["RekSaiE"]                 = {charName = "RekSai"      , slot = "E" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["RekSaiR"]                 = {charName = "RekSai"      , slot = "R" , delay = 1.5 , speed = math.huge  , isMissile = false},
    ["PuncturingTaunt"]         = {charName = "Rammus"      , slot = "E" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["RenektonExecute"]         = {charName = "Renekton"    , slot = "W1", delay = 0.25, speed = math.huge  , isMissile = false},
    ["RenektonSuperExecute"]    = {charName = "Renekton"    , slot = "W2", delay = 0.25, speed = math.huge  , isMissile = false},
    ["RyzeW"]                   = {charName = "Ryze"        , slot = "W" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["RyzeE"]                   = {charName = "Ryze"        , slot = "E" , delay = 0.25, speed = 3500       , isMissile = true },
    ["Fling"]                   = {charName = "Singed"      , slot = "E" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["SyndraR"]                 = {charName = "Syndra"      , slot = "R" , delay = 0.25, speed = 1400       , isMissile = true },
    ["TwoShivPoison"]           = {charName = "Shaco"       , slot = "E" , delay = 0.25, speed = 1500       , isMissile = true },
    ["SkarnerImpale"]           = {charName = "Skarner"     , slot = "R" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["TahmKenchW"]              = {charName = "TahmKench"   , slot = "W" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["TalonQAttack"]            = {charName = "Talon"       , slot = "Q1", delay = 0.25, speed = math.huge  , isMissile = false},
    ["BlindingDart"]            = {charName = "Teemo"       , slot = "Q" , delay = 0.25, speed = 1500       , isMissile = true },
    ["TristanaR"]               = {charName = "Tristana"    , slot = "R" , delay = 0.25, speed = 2000       , isMissile = true },
    ["TrundlePain"]             = {charName = "Trundle"     , slot = "R" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["ViR"]                     = {charName = "Vi"          , slot = "R" , delay = 0.25, speed = 800        , isMissile = false},
    ["VayneCondemn"]            = {charName = "Vayne"       , slot = "E" , delay = 0.25, speed = 2200       , isMissile = true },
    ["VolibearW"]               = {charName = "Volibear"    , slot = "W" , delay = 0.25, speed = math.huge  , isMissile = true },
    ["VeigarR"]                 = {charName = "Veigar"      , slot = "R" , delay = 0.25, speed = 500        , isMissile = true },
    ["VladimirQ"]               = {charName = "Vladimir"    , slot = "Q" , delay = 0.25, speed = math.huge  , isMissile = false},
    ["SylasR"]                  = {charName = "Sylas"       , slot = "R" , delay = 0.25, speed = 2200       , isMissile = true }

}

local missileData = {
    ["RocketGrabMissile"] = {charName = "Blitzcrank", slot = "Q"},
    ["ThreshQMissile"] = {charName = "Blitzcrank", slot = "Q"}
}

local function IsValid(unit)
    return  unit
            and unit.valid
            and unit.isTargetable
            and unit.alive
            and unit.visible
            and unit.networkID
            and unit.health > 0
            and not unit.dead
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

class "Sivir"

function Sivir:__init()
    print("Sivir init")

    self.Q = {Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 90, Range = 1250, Speed = 1350, Collision = true, MaxCollision = 0, CollisionTypes = {GGPrediction.COLLISION_YASUOWALL} }

    self:LoadMenu()

    OnAllyHeroLoad(function(hero)
        Allys[hero.networkID] = hero
    end)

    OnEnemyHeroLoad(function(hero)
        Enemys[hero.networkID] = hero
    end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

    orbwalker:OnPostAttackTick(function(...) self:OnPostAttack(...) end)

    orbwalker:OnPreAttack(
        function(args)
            if args.Process then
                if lastAttack + self.tyMenu.Human.AA:Value() > GetTickCount() then
                    args.Process = false
                    print("block aa")
                else
                    args.Process = true
                    self.AttackTarget = args.Target
                    lastAttack = GetTickCount()
                end
            end
        end
    )

    orbwalker:OnPreMovement(
        function(args)
            if args.Process then
                if (lastMove + self.tyMenu.Human.Move:Value() > GetTickCount()) or (ExtLibEvade and ExtLibEvade.Evading == true) then
                    args.Process = false
                else
                    args.Process = true
                    lastMove = GetTickCount()
                end
            end
        end
    )


end

function Sivir:LoadMenu()

    self.tyMenu = MenuElement({type = MENU, id = "14Sivir", name = "14Sivir"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "Q", name = "Use Q Combo", value = true})
        self.tyMenu.combo:MenuElement({id = "maxRange", name = "Max Q Range", value = 1250, min = 0, max = 1250, step = 10})
        self.tyMenu.combo:MenuElement({id = "WAA", name = "use W AA reset", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.tyMenu.harass:MenuElement({id = "Q", name = "Use Q Harass", value = true})
        self.tyMenu.harass:MenuElement({id = "maxRange", name = "Max Q Range", value = 1250, min = 0, max = 1250, step = 10})
        self.tyMenu.harass:MenuElement({id = "mana", name = "Only cast spell if mana >", value = 30, min = 0, max = 100, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "auto", name = "Auto Q"})
        self.tyMenu.auto:MenuElement({id = "Q", name = "Use Q in Immobile Target", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "eSetting", name = "E Setting"})
        self.tyMenu.eSetting:MenuElement({id = "eDelay", name = "Xs before Spell hit", value = 0.1, min = 0, max = 1.5, step = 0.01})
        self.tyMenu.eSetting:MenuElement({type = MENU, id = "blockSpell", name = "Auto E Block Spell"})
        OnEnemyHeroLoad(function(hero)
            for k, v in pairs(shellSpells) do
                if v.charName == hero.charName then
                    self.tyMenu.eSetting.blockSpell:MenuElement({id = k, name = v.charName.." | "..v.slot, value = true})
                end
            end
        end)
        self.tyMenu.eSetting:MenuElement({type = MENU, id = "dash", name = "Auto E If Enemy dash on ME"})
        OnEnemyHeroLoad(function(hero)
            self.tyMenu.eSetting.dash:MenuElement({id = hero.charName, name = hero.charName, value = false})
        end)

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "draw", name = "Draw Setting"})
        self.tyMenu.draw:MenuElement({id = "Q", name = "Draw Q", value = true})

end

function Sivir:OnPostAttack()
    if orbwalker.Modes[0] then
        if self.tyMenu.combo.WAA:Value() and Ready(_W) and lastW + 250 < GetTickCount() then
            Control.CastSpell(HK_W)
            lastW = GetTickCount()
        end
    end
end

function Sivir:Draw()
    if myHero.dead then return end

    if self.tyMenu.draw.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(255,255, 162, 000))
    end

end

function Sivir:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if orbwalker.Modes[0] then
        self:Combo()
    elseif orbwalker.Modes[1] then
        self:Harass()
    end

    self:BlockSpell()
    self:AutoQ()
end

function Sivir:Combo()
    local target = TargetSelector:GetTarget(self.Q.Range, 0)
    if target and IsValid(target) and myHero.pos:DistanceTo(target.pos) < self.tyMenu.combo.maxRange:Value() then
        if self.tyMenu.combo.Q:Value() then
            self:CastQ(target)
        end
    end
end

function Sivir:Harass()
    local manaPer = myHero.mana/myHero.maxMana
    local target = TargetSelector:GetTarget(self.Q.Range, 0)
    if target and IsValid(target)
        and myHero.pos:DistanceTo(target.pos) < self.tyMenu.harass.maxRange:Value()
        and  self.tyMenu.harass.mana:Value() < manaPer
    then
        if self.tyMenu.harass.Q:Value() then
            self:CastQ(target)
        end
    end
end

function Sivir:CastQ(target)
    if Ready(_Q) and lastQ +350 < GetTickCount() and orbwalker:CanMove() then
        local Pred = GGPrediction:SpellPrediction(self.Q)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
        if Pred:CanHit(2 or GGPrediction.HITCHANCE_HIGH) then
            Control.CastSpell(HK_Q, Pred.CastPosition)
            lastQ = GetTickCount()
        end
    end
end

function Sivir:AutoQ()
    if self.tyMenu.auto.Q:Value() and Ready(_Q) and lastQ +350 < GetTickCount() and orbwalker:CanMove() then
        for k , hero in pairs(Enemys) do
            local Pred = GGPrediction:SpellPrediction(self.Q)
            Pred:GetPrediction(hero, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
            if Pred:CanHit(4 or GGPrediction.HITCHANCE_IMMOBILE) then
                Control.CastSpell(HK_Q, Pred.CastPosition)
                lastQ = GetTickCount()
            end
        end
    end
end

function Sivir:BlockSpell()
    if Ready(_E) and lastE +1050 < GetTickCount() then
        for k , hero in pairs(Enemys) do
            if hero.activeSpell.valid and shellSpells[hero.activeSpell.name] ~= nil then
                if hero.activeSpell.target == myHero.handle and self.tyMenu.eSetting.blockSpell[hero.activeSpell.name]:Value() then
                    local dt = hero.pos:DistanceTo(myHero.pos)
                    local spell = shellSpells[hero.activeSpell.name]
                    local hitTime = spell.delay + dt/spell.speed

                    DelayAction(function()
                            Control.CastSpell(HK_E)
                    end, (hitTime-self.tyMenu.eSetting.eDelay:Value()))
                    lastE = GetTickCount()
                    return
                end
            end

            if hero.pathing.isDashing and self.tyMenu.eSetting.dash[hero.charName]:Value() then
                local vct = Vector(hero.pathing.endPos.x,hero.pathing.endPos.y,hero.pathing.endPos.z)
                if vct:DistanceTo(myHero.pos) < 172 then
                    Control.CastSpell(HK_E)
                    lastE = GetTickCount()
                    return
                end
            end
        end
    end
end



Sivir()

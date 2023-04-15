local Version = 0.05

require 'GGPrediction'

local TableInsert       = _G.table.insert

local ORB         = _G.SDK.Orbwalker
local TS    = _G.SDK.TargetSelector
local OB = _G.SDK.ObjectManager
local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero

local ESpells = {
    ["TristanaR"] = {charName = "Tristana", slot = _R, displayName = "[R]Buster Shot"},
    ["VayneCondemn"] = {charName = "Vayne", slot = _E, displayName = "[E]Condemn"},
    ["BlindMonkRKick"] = {charName = "LeeSin", slot = _R, displayName = "[R]Dragon's Rage"}
}

local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0
local lastIG = 0
local lastMove = 0
local lastAttack = 0


local Enemys =   {}
local Allys  =   {}

local function GetDistanceSquared(vec1, vec2)
    local dx = vec1.x - vec2.x
    local dy = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    return dx * dx + dy * dy
end


local function IsValid(unit)
    if (unit
        and unit.valid
        and unit.isTargetable
        and unit.alive
        and unit.visible
        and unit.networkID
        and unit.health > 0
        and not unit.dead
    ) then
        return true;
    end
    return false;
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

local function EnemiesNear(pos)
    local N = 0
    for i = 1,Game.HeroCount()  do
        local hero = Game.Hero(i)
        if hero.valid and hero.isEnemy and hero.pos:DistanceTo(pos) < 260 then
            N = N + 1
        end
    end
    return N
end


class "Leona"

function Leona:__init()
    self.EData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 875, Speed = 1200, Collision = false}
    self.RData = {Type = _G.SPELLTYPE_CIRCLE, Delay = 1, Radius = 250, Range = 1200, Speed = math.huge, Collision = false}

    self:LoadMenu()

    OnAllyHeroLoad(function(hero) TableInsert(Allys, hero); end)
    OnEnemyHeroLoad(function(hero) TableInsert(Enemys, hero); end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

    ORB:OnPreAttack(
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

    ORB:OnPreMovement(
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






function Leona:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Leona", name = "14 Leona"})

    --combo

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.Combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
    self.tyMenu.Combo:MenuElement({id = "DontE", name = "Dont QER to tower Range Target", value = true})
    self.tyMenu.Combo:MenuElement({id = "DontEQR", name = "If Target HP > %", value = 20, min = 0, max = 100})
    self.tyMenu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
    self.tyMenu.Combo:MenuElement({id = "MinR", name = "[R] Min R target", value = 1, min = 1, max = 5}) --trying to fix this

    --Harass
    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.Harass.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    self.tyMenu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
    self.tyMenu.Harass:MenuElement({id = "UseW", name = "W", value = true})
    self.tyMenu.Harass:MenuElement({id = "UseE", name = "E", value = true})
    self.tyMenu.Harass:MenuElement({id = "DontE", name = "Dont QER to tower Range Target", value = true})

    --Auto
    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
    self.tyMenu.Auto:MenuElement({id = "AutoIG", name = "Auto Ingite KS", value = true})
    self.tyMenu.Auto:MenuElement({id = "AotoEList", name = "Spell List", type = _G.MENU})
    OnEnemyHeroLoad(function(hero)
        for i, spell in pairs(ESpells) do
            if not ESpells[i] then return end
                if spell.charName == hero.charName and not self.tyMenu.Auto.AotoEList[i] then
                    self.tyMenu.Auto.AotoEList:MenuElement({id = hero.charName, name = ""..spell.charName.." ".." | "..spell.displayName, value = true})
                end
        end
    end)

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    --Draw
    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})
    --self.tyMenu.Drawing:MenuElement({id = "Num", name = "Draw Prediction Max Range", value = 100, min = 70 , max = 100})

    self.tyMenu:MenuElement({type = MENU, id = "Version", name = "Version: "..Version , type = SPACE})

end

function Leona:Draw()
    if myHero.dead then
        return
    end

    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, 875,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, 1200,Draw.Color(255,255, 162, 000))
    end
end


function Leona:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    self:Auto()
    ORB:SetMovement(true)
    if ORB.Modes[0] then --combo
        self:Combo()
    elseif ORB.Modes[1] then --harass
        self:Harass()
    end

end

function Leona:Combo()
    local EnemyHeroes = OB:GetEnemyHeroes(1150, false)
    local targetList = {}

    for i = 1, #EnemyHeroes do
        local hero = EnemyHeroes[i]
        local heroName = hero.charName
        if self.tyMenu.Combo.useon[heroName] and self.tyMenu.Combo.useon[heroName]:Value() then
            targetList[#targetList + 1] = hero
        end
    end
    local target = TS:GetTarget(targetList)
    if target == nil then return end


    if IsValid(target) then
        if self.tyMenu.Combo.DontE:Value() and target.health/target.maxHealth > self.tyMenu.Combo.DontEQR:Value()/100 then
            for i = 1, Game.TurretCount() do
                local turret = Game.Turret(i)
                if turret.valid and turret.isEnemy and turret.pos:DistanceTo(target.pos) < 800 then
                    return
                end
            end
        end

        if self.tyMenu.Combo.UseE:Value() and Ready(_E) and lastE +550 < GetTickCount() and myHero.pos:DistanceTo(target.pos) <= 875 then
            local Pred = GGPrediction:SpellPrediction(self.EData)
            Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.EData, myHero)
            if (Pred.Hitchance or Pred.HitChance >= _G.HITCHANCE_HIGH)  or Pred:CanHit(3 or GGPrediction.HITCHANCE_HIGH)             then
                ORB:SetMovement(false)
                Control.CastSpell(HK_E, Pred.CastPosition)
                print("cast E combo")
                lastE = GetTickCount()
            end
        end

        if self.tyMenu.Combo.UseW:Value() and Ready(_W) and lastW +750 < GetTickCount() and myHero.pos:DistanceTo(target.pos) <= 325 then
            Control.CastSpell(HK_W)
            print("cast W combo")
            lastW = GetTickCount()
        end

        if self.tyMenu.Combo.UseR:Value() and Ready(_R) and lastR +450 < GetTickCount() and myHero.pos:DistanceTo(target.pos) <= 1150 then
            if myHero.pos:DistanceTo(target.pos) < 850 and not Ready(_E) and not Ready(_Q) then
                local Pred = GGPrediction:SpellPrediction(self.RData)
                Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.RData, myHero)
                if (Pred.Hitchance or Pred.HitChance >= _G.HITCHANCE_HIGH)  or Pred:CanHit(3 or GGPrediction.HITCHANCE_HIGH)                         then
                    if EnemiesNear(Pred.CastPosition) >= self.tyMenu.Combo.MinR:Value() then
                        NextTick = GetTickCount() + 250
                        ORB:SetMovement(false)
                        Control.CastSpell(HK_R, Pred.CastPosition)
                        print("cast R combo")
                        lastR = GetTickCount()
                    end
                end
            end
            if myHero.pos:DistanceTo(target.pos) > 800 and Ready(_E) and Ready(_Q) then
                local Pred = GGPrediction:SpellPrediction(self.RData)
                Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.RData, myHero)
                if (Pred.Hitchance or Pred.HitChance >= _G.HITCHANCE_HIGH)  or Pred:CanHit(3 or GGPrediction.HITCHANCE_HIGH)                 then
                    if EnemiesNear(Pred.CastPosition) >= self.tyMenu.Combo.MinR:Value() then
                        NextTick = GetTickCount() + 250
                        ORB:SetMovement(false)
                        Control.CastSpell(HK_R, Pred.CastPosition)
                        print("cast R combo")
                        lastR = GetTickCount()
                    end
                end
            end
        end


        if self.tyMenu.Combo.UseQ:Value()
        and Ready(_Q)
        then
            self:CastQ()
        end


    end

end

function Leona:Harass()
    local EnemyHeroes = OB:GetEnemyHeroes(1150, false)
    local targetList = {}

    for i = 1, #EnemyHeroes do
        local hero = EnemyHeroes[i]
        local heroName = hero.charName
        if self.tyMenu.Harass.useon[heroName] and self.tyMenu.Harass.useon[heroName]:Value() then
            targetList[#targetList + 1] = hero
        end
    end
    local target = TS:GetTarget(targetList)
    if target == nil then return end

    if IsValid(target) then

        if self.tyMenu.Harass.DontE:Value() then
            for i = 1, Game.TurretCount() do
                local turret = Game.Turret(i)
                if turret.valid and turret.isEnemy and turret.pos:DistanceTo(target.pos) < 800 then
                    return
                end
            end
        end

        if self.tyMenu.Harass.UseE:Value() and Ready(_E) and lastE +550 < GetTickCount() and myHero.pos:DistanceTo(target.pos) <= 875 then
            local Pred = GGPrediction:SpellPrediction(self.EData)
            Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.EData, myHero)
            if (Pred.Hitchance or Pred.HitChance >= _G.HITCHANCE_HIGH)  or Pred:CanHit(3 or GGPrediction.HITCHANCE_HIGH)             then
                NextTick = GetTickCount() + 250
                ORB:SetMovement(false)
                Control.CastSpell(HK_E, Pred.CastPosition)
                print("cast E harass")
                lastE = GetTickCount()
            end
        end


        if self.tyMenu.Harass.UseW:Value() and lastW +550 < GetTickCount() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 325 then
            Control.CastSpell(HK_W)
            print("cast W harass")
            lastW = GetTickCount()
        end

        if self.tyMenu.Harass.UseQ:Value() and Ready(_Q)  then
            self:CastQ()
        end


    end

end


function Leona:Auto()
    local IGdamage = 50 + 20 * myHero.levelData.lvl
    local target = TS:GetTarget(600)
    if target == nil then return end
    if lastIG + 250 > GetTickCount() then return end
    if self.tyMenu.Auto.AutoIG:Value() then
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and myHero:GetSpellData(SUMMONER_1).currentCd == 0 then
            if IGdamage >= target.health then
                Control.CastSpell(HK_SUMMONER_1, target.pos)
                print("cast ig")

                lastIG = GetTickCount()
            end
        end


        if myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and myHero:GetSpellData(SUMMONER_2).currentCd == 0 then
            if IGdamage >= target.health then
                Control.CastSpell(HK_SUMMONER_2, target.pos)
                lastIG = GetTickCount()
                print("cast ig")

            end
        end
    end

    local EnemyHeroes = OB:GetEnemyHeroes(875, false)
    for i = 1, #EnemyHeroes do
        local hero = EnemyHeroes[i]
        if hero.activeSpell.spellWasCast then
            if ESpells[hero.activeSpell.name] ~= nil then
                if self.tyMenu.Auto.AotoEList[hero.charName]:Value() and lastE +350 < GetTickCount() and hero.activeSpell.target == myHero.handle then
                    Control.CastSpell(HK_E, hero.pos)
                    print("cast E")
                    lastE = GetTickCount()
                end
            end
        end

    end

end

function Leona:CastQ()
    if lastQ +350 < GetTickCount() then
        local EnemyHeroes = OB:GetEnemyHeroes(275, false)
        if EnemyHeroes ~= nil  and myHero.attackData.state == STATE_WINDDOWN then
            Control.CastSpell(HK_Q)
            print("cast Q")
            ORB:__OnAutoAttackReset()
            lastQ = GetTickCount()
        end

        if myHero.pathing.isDashing then
            Control.CastSpell(HK_Q)
            print("cast Q dash")
            lastQ = GetTickCount()

        end
    end
end

Leona()
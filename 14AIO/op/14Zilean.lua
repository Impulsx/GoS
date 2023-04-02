require 'GGPrediction'

local TableInsert       = _G.table.insert

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector
local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero


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

class "Zilean"

function Zilean:__init()
    self.Q = {Type = _G.SPELLTYPE_CIRCLE, Delay = 0.8, Radius = 150, Range = 900, Speed = math.huge, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}}
    self.E = {Range = 550}
    self.R = {Range = 900}

    self:LoadMenu()

    OnAllyHeroLoad(function(hero) TableInsert(Allys, hero); end)
    OnEnemyHeroLoad(function(hero) TableInsert(Enemys, hero); end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

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

function Zilean:LoadMenu()

    self.tyMenu = MenuElement({type = MENU, id = "14Zilean", name = "14 Zilean"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
        OnEnemyHeroLoad(function(hero) self.tyMenu.Combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
        self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
        OnEnemyHeroLoad(function(hero) self.tyMenu.Harass.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
        self.tyMenu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
        self.tyMenu.Auto:MenuElement({id = "UseQ", name = "Auto Q if enemy has boom", value = true})
        self.tyMenu.Auto:MenuElement({id = "Rhp", name = "If Ally HP < X%", value = 20, min = 1, max = 100, step = 1})
        self.tyMenu.Auto:MenuElement({type = MENU, id = "Ron", name = "Use R On"})
        OnAllyHeroLoad(function(hero)
            self.tyMenu.Auto.Ron:MenuElement({id = hero.charName, name = hero.charName, value = true})
        end)

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "draw", name = "Drawing"})
        self.tyMenu.draw:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.draw:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.draw:MenuElement({id = "R", name = "Draw [R] Range", value = true})


end

function Zilean:Draw()
    if myHero.dead then return end

    if self.tyMenu.draw.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(255,255, 162, 000))
    end
    if self.tyMenu.draw.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(255,255, 162, 000))
    end
    if self.tyMenu.draw.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range,Draw.Color(255,255, 162, 000))
    end

end

function Zilean:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

    self:AutoR()
    self:AutoQ()
end

function Zilean:CastQ(target)
    if Ready(_Q) and lastQ + 350 < GetTickCount() and orbwalker:CanMove() then
        local Pred = GetGamsteronPrediction(target, self.Q, myHero)
        if Pred.Hitchance >= _G.HITCHANCE_HIGH then
            Control.CastSpell(HK_Q, Pred.CastPosition)
            --print("cast Q "..GetTickCount())
            lastQ = GetTickCount()
        end
    end

    if not Ready(_Q) and lastQ +350 < GetTickCount()
    and Ready(_W) and lastW +250 < GetTickCount() and orbwalker:CanMove() then
        local Pred = GetGamsteronPrediction(target, self.Q, myHero)
        if Pred.Hitchance >= _G.HITCHANCE_HIGH then
            Control.CastSpell(HK_W)
            Control.CastSpell(HK_Q, Pred.CastPosition)
            --print("cast WQ "..GetTickCount())
            lastQ = GetTickCount()
            lastW = GetTickCount()
        end
    end
end


function Zilean:Combo()
    local targetList = {}
    local target

    for i = 1, #Enemys do
        local enemy = Enemys[i]
        local heroName = enemy.charName
        if self.tyMenu.Combo.useon[heroName] and self.tyMenu.Combo.useon[heroName]:Value() then
            targetList[#targetList + 1] = enemy
        end
    end

    target = self:GetTarget(targetList, self.Q.Range)

    if target and IsValid(target) and self.tyMenu.Combo.UseQ:Value() then
        self:CastQ(target)
    end

end

function Zilean:Harass()
    local targetList = {}
    local target

    for i = 1, #Enemys do
        local enemy = Enemys[i]
        local heroName = enemy.charName
        if self.tyMenu.Harass.useon[heroName] and self.tyMenu.Harass.useon[heroName]:Value() then
            targetList[#targetList + 1] = enemy
        end
    end

    target = self:GetTarget(targetList, self.Q.Range)

    if target and IsValid(target) and self.tyMenu.Harass.UseQ:Value() then
        self:CastQ(target)
    end
end

function Zilean:AutoQ()
    for i = 1, #Enemys do
        local enemy = Enemys[i]
        if self.tyMenu.Auto.UseQ:Value() and GetDistanceSquared(enemy.pos, myHero.pos) < 900*900 then
            local hasBuff , duration = self:HasQBuff(enemy)
            if hasBuff and duration >= 0.8 then
                self:CastQ(enemy)
            end
        end
    end
end

function Zilean:AutoR()
    if not Ready(_R) or lastR + 150 > GetTickCount() then return end

    for i = 1, #Allys do
        local ally = Allys[i]
        if self.tyMenu.Auto.Ron[ally.charName] and self.tyMenu.Auto.Ron[ally.charName]:Value() then
            if IsValid(ally) and GetDistanceSquared(ally.pos, myHero.pos) < self.R.Range ^ 2 then
                if ally.health / ally.maxHealth * 100 < self.tyMenu.Auto.Rhp:Value() and self:GetEnemyAround(ally) > 0 then
                    Control.CastSpell(HK_R, ally.pos)
                    --print("low Health cast R "..ally.charName)
                    lastR = GetTickCount()
                    return
                end
            end
        end
    end

end


function Zilean:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

function Zilean:HasQBuff(unit)
    local name = "ZileanQEnemyBomb"
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name then
            return true, buff.duration
        end
    end
    return false
end

function Zilean:GetEnemyAround(ally)
    local counter = 0
    for i = 1, #Enemys do
        local enemy = Enemys[i]
        if IsValid(enemy) and GetDistanceSquared(ally.pos, enemy.pos) < 800^2 then
            counter = counter + 1
        end
    end
    return counter
end

Zilean()

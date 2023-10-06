require 'GGPrediction'

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector

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


class "Blitzcrank"

function Blitzcrank:__init()
    self.Q = {Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1100, Speed = 1800, Collision = true, MaxCollision = 0, CollisionTypes = {GGPrediction.COLLISION_MINION, GGPrediction.COLLISION_YASUOWALL}}
    self.R = {range = 600}

    self:LoadMenu()

    OnAllyHeroLoad(function(hero)
        TableInsert(Allys, hero);
    end)

    OnEnemyHeroLoad(function(hero)
        TableInsert(Enemys, hero);
    end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)


    orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)

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



function Blitzcrank:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Blitzcrank", name = "14 Blitzcrank"})

    --combo

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.Combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "range", name = "Max Cast Q In range", value = 1100, min = 1, max = 1100, step = 1})
    self.tyMenu.Combo:MenuElement({id = "minRange", name = "Min Cast Q In range", value = 0, min = 0, max = 1100, step = 1})
    self.tyMenu.Combo:MenuElement({id = "UseE", name = "[E] before AA", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
    self.tyMenu.Combo:MenuElement({id = "Count", name = "When Can Hit X Enemies ", value = 2, min = 1, max = 5, step = 1})

    --Harass
    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.Harass.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    self.tyMenu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
    self.tyMenu.Harass:MenuElement({id = "range", name = "Max Cast Q In range", value = 1000, min = 1, max = 1100, step = 1})


    --Auto
    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
    self.tyMenu.Auto:MenuElement({id = "UseR", name = "[R]", value = true})
    self.tyMenu.Auto:MenuElement({id = "Count", name = "When Can Hit X Enemies ", value = 3, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    --Draw
    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})


end

function Blitzcrank:Draw()
    if myHero.dead then
        return
    end

    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 925,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, 600,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end



function Blitzcrank:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    self:AutoR()

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

end

function Blitzcrank:CastQ(target)
    if Ready(_Q) and lastQ +350 < GetTickCount() and orbwalker:CanMove() then
        local Pred = GGPrediction:SpellPrediction(self.Q)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
        if Pred:CanHit(3 or GGPrediction.HITCHANCE_HIGH) then
            Control.CastSpell(HK_Q, Pred.CastPosition)
            lastQ = GetTickCount()
        end
    end
end

function Blitzcrank:Combo()
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

    if target and IsValid(target) and self.tyMenu.Combo.UseQ:Value()
    and GetDistanceSquared(myHero.pos, target.pos) <= self.tyMenu.Combo.range:Value()^2
    and GetDistanceSquared(myHero.pos, target.pos) > self.tyMenu.Combo.minRange:Value()^2
    then
        self:CastQ(target)
    end

    target = self:GetTarget(Enemys, 350)

    if self.tyMenu.Combo.UseR:Value() then
        self:CastR(self.tyMenu.Combo.Count:Value())
    end
end

function Blitzcrank:Harass()
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


    if target and IsValid(target) and self.tyMenu.Harass.UseQ:Value() and GetDistanceSquared(myHero.pos, target.pos) <= self.tyMenu.Harass.range:Value()^2 then
        self:CastQ(target)
    end

end


function Blitzcrank:CastR(number)
    if not Ready(_R) or lastR + 350 > GetTickCount() then return end
    local count = 0

    for i = 1, #Enemys do
        local hero = Enemys[i]
        local delayPos = hero:GetPrediction(hero.ms,0.25)
        if IsValid(hero) and GetDistanceSquared(delayPos, myHero.pos) <= 550*550 then
            count = count + 1
        end
    end

    if count >= number then
        Control.CastSpell(HK_R)
        lastR = GetTickCount()
    end


end

function Blitzcrank:AutoR()
    if self.tyMenu.Auto.UseR:Value() then
        self:CastR(self.tyMenu.Auto.Count:Value())
    end
end

function Blitzcrank:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

function Blitzcrank:OnPreAttack()
    if orbwalker.Modes[0] and self.tyMenu.Combo.UseE:Value() then
        if Ready(_E) and lastE + 250 < GetTickCount() then
            Control.CastSpell(HK_E)
            lastE = GetTickCount()
        end
    end
end

Blitzcrank()
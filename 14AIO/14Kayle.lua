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
local lastHeal = 0
local Enemys =   {}
local Allys  =   {}





local function GetDistanceSquared(vec1, vec2)
    local dx = vec1.x - vec2.x
    local dy = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    return dx * dx + dy * dy
end

local function DistanceCompare(a,b)
    return GetDistanceSquared(myHero.pos,a.pos) < GetDistanceSquared(myHero.pos,b.pos)
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

local function GetEnemyMinions(range)
    local count = 0
    for i = 1, Game.MinionCount() do
        local obj = Game.Minion(i)
        if IsValid(obj) and GetDistanceSquared(obj.pos, myHero.pos) < range * range and obj.isEnemy and obj.team < 300 then
            count = count + 1
        end
    end
    return count
end

class "Kayle"

function Kayle:__init()
    self.Q = {Hitchance = _G.HITCHANCE_HIGH, Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 65, Range = 830, Speed = 500, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}}
    self.W = {Range = 900}
    self.E = {Range = 625}
    self.R = {Range = 900}


    self:LoadMenu()

    OnAllyHeroLoad(function(hero)
        TableInsert(Allys, hero);
    end)

    OnEnemyHeroLoad(function(hero)
        TableInsert(Enemys, hero);
    end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

    orbwalker:OnPostAttackTick(function(...) self:OnPostAttackTick(...) end)

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

function Kayle:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Kayle", name = "Kayle"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "E", name = "[E]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseE", name = "[E] AA reset", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
    self.tyMenu.Flee:MenuElement({id = "W", name = "Self [W]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
    self.tyMenu.Auto:MenuElement({id = "WHP", name = "Auto W Ally HP < X %", value = 20, min = 1, max = 101, step = 1})
    self.tyMenu.Auto:MenuElement({name = "Auto W ally ", id = "autoW", type = _G.MENU})
        OnAllyHeroLoad(function(hero) self.tyMenu.Auto.autoW:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    self.tyMenu.Auto:MenuElement({id = "RHP", name = "Auto R Ally HP < X %", value = 10, min = 1, max = 101, step = 1})
    self.tyMenu.Auto:MenuElement({name = "Auto R ally ", id = "autoR", type = _G.MENU})
        OnAllyHeroLoad(function(hero) self.tyMenu.Auto.autoR:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)

    self.tyMenu:MenuElement({type = MENU, id = "HitChance", name = "Hit Chance Setting"})
        self.tyMenu.HitChance:MenuElement({name ="Q HitChance" , drop = {"High", "Normal"}, callback = function(value)
            if value == 1 then
                self.Q.Hitchance = _G.HITCHANCE_HIGH
            end
            if value == 2 then
                self.Q.Hitchance = _G.HITCHANCE_NORMAL
            end
        end})
        self.tyMenu.HitChance:MenuElement({id = "Qminion", name = "[Q] minoin to hit target", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})


    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Kayle:Draw()
    if myHero.dead then return end

    if self.tyMenu.Drawing.Q:Value() and  Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Kayle:OnPostAttackTick()
    if orbwalker.Modes[0] and self.tyMenu.Combo.UseE:Value() then
        if lastE + 300 < GetTickCount() and Ready(_E) then
            Control.CastSpell(HK_E)
            lastE = GetTickCount()
        end
    end
end

function Kayle:Tick()

    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if myHero.activeSpell.valid and myHero.activeSpell.name == "KayleR" then
        orbwalker:SetAttack(false)
        return
    else
        orbwalker:SetAttack(true)
    end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    elseif orbwalker.Modes[5] then --flee
        self:Flee()
    end

    self:Auto()

end

function Kayle:CastQ(target)
    if lastQ + 300 < GetTickCount() and Ready(_Q) and orbwalker:CanMove() then
        self.Q.CollisionTypes = {_G.COLLISION_YASUOWALL}
        local Pred = GGPrediction:SpellPrediction(self.Q)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
        if (Pred.Hitchance or Pred.HitChance  >= self.Q.Hitchance)  or Pred:CanHit(self.Q.Hitchance or GGPrediction.HITCHANCE_HIGH)         then
            self.Q.CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
            local Pred2 = GGPrediction:SpellPrediction(self.Q)
            Pred2:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)

            if Pred2.Hitchance >= self.Q.Hitchance or Pred2:CanHit(self.Q.Hitchance or GGPrediction.HITCHANCE_HIGH)then
                Control.CastSpell(HK_Q, Pred2.CastPosition)
                lastQ = GetTickCount()
            else
                if Pred2.Hitchance == 1 and self.tyMenu.HitChance.Qminion:Value() then
                    if #Pred2.CollisionObjects > 0 then
                        table.sort(Pred2.CollisionObjects, DistanceCompare)
                        if GetDistanceSquared(Pred2.CastPosition, Pred2.CollisionObjects[1].pos) < 400*400 then
                            Control.CastSpell(HK_Q, Pred2.CastPosition)
                            lastQ = GetTickCount()
                        end
                    end
                end
            end
        end
    end
end

function Kayle:Combo()
    if self.tyMenu.Combo.UseQ:Value() then
        local target = TargetSelector:GetTarget(self.Q.Range)
        if target then
            self:CastQ(target)
        end
    end
    if self.tyMenu.Combo.E:Value() and myHero.levelData.lvl < 6 then
        local target = TargetSelector:GetTarget(self.E.Range)
        if target  then
            if lastE + 300 < GetTickCount() and Ready(_E) then
                Control.CastSpell(HK_E)
                lastE = GetTickCount()
            end
        end
    end
end

function Kayle:Harass()
    if self.tyMenu.Harass.UseQ:Value() then
        local target = TargetSelector:GetTarget(self.Q.Range)
        if target then
            self:CastQ(target)
        end
    end
end

function Kayle:Flee()
    if self.tyMenu.Flee.W:Value() then
        if Ready(_W) and lastHeal + 180 < GetTickCount() then
            Control.CastSpell(HK_W, myHero.pos)
            print("flee W ")
            lastHeal = GetTickCount()
        end
    end
end

function Kayle:Auto()
    for k, ally in pairs(Allys) do
        if Ready(_W) and lastHeal + 180 < GetTickCount() then
            if self.tyMenu.Auto.autoW[ally.charName] and self.tyMenu.Auto.autoW[ally.charName]:Value() then
                if IsValid(ally) and GetDistanceSquared(myHero.pos, ally.pos) < self.W.Range ^2 then
                    if ally.health / ally.maxHealth * 100 < self.tyMenu.Auto.WHP:Value() and self:GetEnemyAround(ally) > 0 then
                        Control.CastSpell(HK_W, ally.pos)
                        print("low Health cast W "..ally.charName)
                        lastHeal = GetTickCount()
                        return
                    end
                end
            end
        end

        if Ready(_R) and lastHeal + 180 < GetTickCount() then
            if self.tyMenu.Auto.autoR[ally.charName] and self.tyMenu.Auto.autoR[ally.charName]:Value() then
                if IsValid(ally) and GetDistanceSquared(myHero.pos, ally.pos) < self.R.Range ^2 then
                    if ally.health / ally.maxHealth * 100 < self.tyMenu.Auto.RHP:Value() and self:GetEnemyAround(ally) > 0 then
                        Control.CastSpell(HK_R, ally.pos)
                        print("low Health cast R "..ally.charName)
                        lastHeal = GetTickCount()
                        return
                    end
                end
            end
        end

    end
end

function Kayle:GetEnemyAround(ally)
    local counter = 0
    for enemyk , enemy in pairs(Enemys) do
        if IsValid(enemy) and enemy.pos:DistanceTo(ally.pos) < 650 then
            counter = counter + 1
        end
    end
    return counter
end

Kayle()
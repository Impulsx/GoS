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




local function hasBuff(name, unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name  then
            return true, buff.duration, buff.count
        end
    end
    return false
end

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

class "Kaisa"

function Kaisa:__init()
    self.Q = {Range = 630}
    self.W = {Type = _G.SPELLTYPE_LINE, Delay = 0.4, Radius = 100, Range = 3000, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}}

    self:LoadMenu()

    OnAllyHeroLoad(function(hero)
        TableInsert(Allys, hero);
    end)

    OnEnemyHeroLoad(function(hero)
        TableInsert(Enemys, hero);
    end)

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

function Kaisa:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Kaisa", name = "Kaisa"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "minion", name = "Only Q if Minions < X in range", value = 3, min = 1, max = 10, step = 1})
    self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Harass:MenuElement({id = "minion", name = "Only Q if Minions < X in range", value = 3, min = 1, max = 10, step = 1})
    self.tyMenu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
    self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
    self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})


    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})

end

function Kaisa:Draw()
    if myHero.dead then return end

    if self.tyMenu.Drawing.Q:Value() then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Kaisa:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

    if hasBuff("KaisaE",myHero) then
        orbwalker:SetAttack(false)
    else
        orbwalker:SetAttack(true)
    end
end

function Kaisa:Combo()
    if self.tyMenu.Combo.UseQ:Value() and lastQ + 300 < GetTickCount() and Ready(_Q) and orbwalker:CanMove() then
        local target = TargetSelector:GetTarget(self.Q.Range)

        if target and GetEnemyMinions(self.Q.Range) < self.tyMenu.Combo.minion:Value() then
            Control.CastSpell(HK_Q)
            lastQ = GetTickCount()
        end
    end

    if self.tyMenu.Combo.UseW:Value() and lastW + 500 < GetTickCount() and Ready(_W) and orbwalker:CanMove() then
        local target = TargetSelector:GetTarget(self.W.Range)

        if target then
            local Pred = GetGamsteronPrediction(target, self.W, myHero)
            if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                Control.CastSpell(HK_W, Pred.CastPosition)
                lastW = GetTickCount()
            end
        end
    end
end

function Kaisa:Harass()
    if self.tyMenu.Harass.UseQ:Value() and lastQ + 300 < GetTickCount() and Ready(_Q) and orbwalker:CanMove() then
        local target = TargetSelector:GetTarget(self.Q.Range)

        if target and GetEnemyMinions(self.Q.Range) < self.tyMenu.Harass.minion:Value() then
            Control.CastSpell(HK_Q)
            lastQ = GetTickCount()
        end
    end

    if self.tyMenu.Harass.UseW:Value() and lastW + 500 < GetTickCount() and Ready(_W) and orbwalker:CanMove() then
        local target = TargetSelector:GetTarget(self.W.Range)

        if target then
            local Pred = GetGamsteronPrediction(target, self.W, myHero)
            if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                Control.CastSpell(HK_W, Pred.CastPosition)
                lastW = GetTickCount()
            end
        end
    end
end

Kaisa()
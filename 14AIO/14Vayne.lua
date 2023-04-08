require 'GGPrediction'
require "2DGeometry"
require 'MapPositionGOS'

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector

local abs = math.abs
local sqrt = math.sqrt
local deg = math.deg
local acos = math.acos

local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0
local lastIG = 0
local lastMove = 0
local lastAttack = 0
local Enemys =   {}
local Allys  =   {}

local lin = nil

local function GetDistance(a,b)
    return a:DistanceTo(b)
end



local function CircleCircleIntersection(c1, c2, r1, r2)
    local D = GetDistance(c1,c2)
    if D > r1 + r2 or D <= abs(r1 - r2) then return nil end
    local A = (r1 * r2 - r2 * r1 + D * D) / (2 * D)
    local H = sqrt(r1 * r1 - A * A)
    local Direction = (c2 - c1):Normalized()
    local PA = c1 + A * Direction
    local S1 = PA + H * Direction:Perpendicular()
    local S2 = PA - H * Direction:Perpendicular()
    return S1, S2
end

local function GetDistanceSquared(vec1, vec2)
    local dx = vec1.x - vec2.x
    local dy = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    return dx * dx + dy * dy
end

local function DistanceCompare(a,b)
    return GetDistanceSquared(myHero.pos,a.pos) < GetDistanceSquared(myHero.pos,b.pos)
end

local function IsDashToMe(unit)
    local d1 = GetDistanceSquared(myHero.pos, unit.pathing.startPos)
    local d2 = GetDistanceSquared(myHero.pos, unit.pathing.endPos)

    return d2 < d1
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

local function HasBuff(unit , name)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name then
            return true, buff.duration, buff.count
        end
    end
    return false
end


class "Vayne"

function Vayne:__init()
    self.Q = {Range = 300, Speed = 830}
    self.E = {Hitchance = _G.HITCHANCE_HIGH, Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 1, Range = 650, Speed = 2200, Collision = true, MaxCollision = 0, CollisionTypes = { _G.COLLISION_YASUOWALL}}

    self.AttackTarget = nil

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

function Vayne:LoadMenu()

    self.tyMenu = MenuElement({type = MENU, id = "14Vayne", name = "[14AIO] Vayne"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({id = "Q", name = "[Q] AA reset", value = true})
        self.tyMenu.Combo:MenuElement({id = "E", name = "[E] Stun", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({id = "Q", name = "[Q] AA reset", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Setting", name = "Setting"})
        self.tyMenu.Setting:MenuElement({id = "Qmode", name ="Q mode" , drop = {"To Side", "To Cursor"}})
        self.tyMenu.Setting:MenuElement({id = "Erange", name = "E range", value = 475, min = 1, max = 475, step = 1})
        self.tyMenu.Setting:MenuElement({name ="E HitChance" , drop = {"High", "Normal"}, callback = function(value)
            if value == 1 then
                self.E.Hitchance = _G.HITCHANCE_HIGH
            end
            if value == 2 then
                self.E.Hitchance = _G.HITCHANCE_NORMAL
            end
        end})
        self.tyMenu.Setting:MenuElement({id = "antiMelee", name = "[E] Anti-Melee", value = true})
        self.tyMenu.Setting:MenuElement({id = "antiMeleeRange", name = "E Anti-Melee range", value = 300, min = 1, max = 500, step = 1})

        self.tyMenu.Setting:MenuElement({id = "antiQ", name = "[Q] Anti-Gap closer", value = true})
        self.tyMenu.Setting:MenuElement({id = "antiE", name = "[E] Anti-Gap closer", value = true})
        self.tyMenu.Setting:MenuElement({type = MENU, id = "AntiGap", name = "Anti-Gap closer"})
            OnEnemyHeroLoad(function(hero) self.tyMenu.Setting.AntiGap:MenuElement({id = hero.charName, name = hero.charName, value = false}) end)


    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})

end

function Vayne:OnPostAttackTick(args)
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if self.AttackTarget and self.AttackTarget.type == Obj_AI_Hero and Ready(_Q) and lastQ + 200 < GetTickCount() then
        if (orbwalker.Modes[0] and self.tyMenu.Combo.Q:Value()) or (orbwalker.Modes[1] and self.tyMenu.Harass.Q:Value()) then
            if self.tyMenu.Setting.Qmode:Value() == 2 then
                Control.CastSpell(HK_Q)
                lastQ = GetTickCount()
            end

            if self.tyMenu.Setting.Qmode:Value() == 1 then
                local root1, root2 = CircleCircleIntersection(myHero.pos, self.AttackTarget.pos, myHero.range + myHero.boundingRadius, 500)
                if root1 and root2 then
                    local closest = GetDistance(root1, mousePos) < GetDistance(root2, mousePos) and root1 or root2
                    Control.CastSpell(HK_Q,myHero.pos:Extended(closest, 300))
                    lastQ = GetTickCount()
                end
            end
        end
    end
end

function Vayne:Tick()

    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    end
end

function Vayne:Combo()
    local target = TargetSelector:GetTarget(self.E.Range)
    if target and self.tyMenu.Combo.E:Value() then
        self:CastE(target)
    end
end

function Vayne:CastE(target)
    if IsValid(target) and Ready(_E) and lastE + 500 < GetTickCount() then
        local Pred = GGPrediction:SpellPrediction(self.E)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.E, myHero)
        if Pred.Hitchance or Pred.HitChance  >= self.E.Hitchance  or Pred:CanHit(self.E.Hitchance or GGPrediction.HITCHANCE_HIGH)         then
            local extendPos = Pred.CastPosition:Extended(myHero.pos,-self.tyMenu.Setting.Erange:Value())
            local lineE = LineSegment(Pred.CastPosition,extendPos)

            lin = lineE

            if MapPosition:intersectsWall(lineE) then
                Control.CastSpell(HK_E,target)
                lastE = GetTickCount()
            end
        end
    end
end

function Vayne:AntiGap()
    for k, enemy in pairs(Enemys) do
        if self.tyMenu.Setting.antiMelee:Value()
        and GetDistanceSquared(myHero.pos, enemy.pos) < self.tyMenu.Setting.antiMeleeRange:Value()  ^2
        and enemy.range < 300
        and Ready(_E) and lastE + 500 < GetTickCount()
        and IsValid(enemy)
        then
            Control.CastSpell(HK_E,enemy)
            print("anti Melee E")
            lastE = GetTickCount()
        end
        if self.tyMenu.Setting.AntiGap[enemy.charName] and self.tyMenu.Setting.AntiGap[enemy.charName]:Value() then
            if IsValid(enemy) and GetDistanceSquared(myHero.pos, enemy.pos) < self.E.Range ^2 then
                local path = enemy.pathing
                if path.isDashing and path.hasMovePath and path.dashSpeed > 0
                and IsDashToMe(enemy) and not HasBuff(enemy,"VayneCondemnMissile")
                then
                    if Ready(_E) and lastE + 500 < GetTickCount() and self.tyMenu.Setting.antiE:Value() then
                        Control.CastSpell(HK_E,enemy)
                        print("anti E")
                        lastE = GetTickCount()
                    end
                    if Ready(_Q) and lastQ + 300 < GetTickCount() and self.tyMenu.Setting.antiQ:Value() then
                        local pos = myHero.pos:Extended(enemy.pos, -self.Q.Range)
                        Control.CastSpell(HK_Q,pos)
                        print("anti Q")
                        lastQ = GetTickCount()
                    end
                end
            end
        end
    end
end

function Vayne:Draw()
    -- if lin then lin:__draw(1,Draw.Color(80 ,0xFF,0xFF,0xFF)) end

    self:AntiGap()

    if myHero.dead then return end

    if self.tyMenu.Drawing.Q:Value() and  Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

end

Vayne()
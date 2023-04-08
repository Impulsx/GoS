require 'MapPositionGOS'
require "2DGeometry"
require 'GGPrediction'

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector

local abs = math.abs
local sqrt = math.sqrt

local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0
local lastIG = 0
local lastMove = 0
local lastAttack = 0
local Enemys =   {}
local Allys  =   {}

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

local function CalcPhysicalDamage(source, target, amount)
    local armorPenetrationPercent = source.armorPenPercent
    local armorPenetrationFlat = source.armorPen *
                                     (0.6 + 0.4 * source.levelData.lvl / 18)
    local bonusArmorPenetrationMod = source.bonusArmorPenPercent

    local armor = target.armor
    local bonusArmor = target.bonusArmor
    local value

    if armor < 0 then
        value = 2 - 100 / (100 - armor)
    elseif armor * armorPenetrationPercent - bonusArmor *
        (1 - bonusArmorPenetrationMod) - armorPenetrationFlat < 0 then
        value = 1
    else
        value = 100 / (100 + armor * armorPenetrationPercent - bonusArmor *
                    (1 - bonusArmorPenetrationMod) - armorPenetrationFlat)
    end

    return math.max(math.floor(value * amount), 0)

end


class "Graves"

function Graves:__init()
    self.Q = {Hitchance = _G.HITCHANCE_HIGH, Type = _G.SPELLTYPE_LINE, Delay = 0.25, Speed = 3000 , Range = 925, Radius = 20, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}}
    self.W = {Hitchance = _G.HITCHANCE_HIGH, Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Speed = 1500 , Range = 950, Radius = 250}
    self.E = {Range = 425}
    self.R = {Hitchance = _G.HITCHANCE_HIGH, Type = _G.SPELLTYPE_LINE, Delay = 0.25, Speed = 2100 , Range = 1000, Radius = 100, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}}

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

function Graves:LoadMenu()

    self.tyMenu = MenuElement({type = MENU, id = "14Graves", name = "[14AIO] Graves"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({id = "Q", name = "[Q]", value = true})
        self.tyMenu.Combo:MenuElement({id = "W", name = "[W]", value = true})
        self.tyMenu.Combo:MenuElement({id = "E", name = "[E] AA reset", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({id = "Q", name = "[Q]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Jungle", name = "Jungle Clean"})
        self.tyMenu.Jungle:MenuElement({id = "Q", name = "[Q]", value = true})
        self.tyMenu.Jungle:MenuElement({id = "E", name = "[E] AA reset", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
        self.tyMenu.Auto:MenuElement({id = "R", name = "[R] KS", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Setting", name = "Setting"})
        self.tyMenu.Setting:MenuElement({id = "Emode", name ="E mode" , drop = {"To Side", "To Cursor"}})
        self.tyMenu.Setting:MenuElement({name ="Q HitChance" , drop = {"High", "Normal"}, callback = function(value)
            if value == 1 then
                self.Q.Hitchance = _G.HITCHANCE_HIGH
            end
            if value == 2 then
                self.Q.Hitchance = _G.HITCHANCE_NORMAL
            end
        end})
        self.tyMenu.Setting:MenuElement({name ="W HitChance" , drop = {"High", "Normal"}, callback = function(value)
            if value == 1 then
                self.W.Hitchance = _G.HITCHANCE_HIGH
            end
            if value == 2 then
                self.W.Hitchance = _G.HITCHANCE_NORMAL
            end
        end})
        self.tyMenu.Setting:MenuElement({name ="R HitChance" , drop = {"High", "Normal"}, callback = function(value)
            if value == 1 then
                self.R.Hitchance = _G.HITCHANCE_HIGH
            end
            if value == 2 then
                self.R.Hitchance = _G.HITCHANCE_NORMAL
            end
        end})
    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = false})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = false})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = false})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = false})

end

function Graves:OnPostAttackTick(args)
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if self.AttackTarget and Ready(_E) and lastE + 200 < GetTickCount() then
        if (orbwalker.Modes[0] and self.tyMenu.Combo.E:Value() and self.AttackTarget.type == Obj_AI_Hero)
        or (orbwalker.Modes[3] and self.tyMenu.Jungle.E:Value() and self.AttackTarget.team == 300 ) then
            if self.tyMenu.Setting.Emode:Value() == 2 then
                Control.CastSpell(HK_E)
                lastE = GetTickCount()
            end

            if self.tyMenu.Setting.Emode:Value() == 1 then
                local root1, root2 = CircleCircleIntersection(myHero.pos, self.AttackTarget.pos, myHero.range + myHero.boundingRadius, 500)
                if root1 and root2 then
                    local closest = GetDistance(root1, mousePos) < GetDistance(root2, mousePos) and root1 or root2
                    Control.CastSpell(HK_E,myHero.pos:Extended(closest, 300))
                    lastE = GetTickCount()
                end
            end
        end
    end
end

function Graves:Tick()
    if myHero.dead or Game.IsChatOpen() or
    (ExtLibEvade and ExtLibEvade.Evading == true) then return end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    elseif orbwalker.Modes[3] then --jungle
        self:Jungle()
    end

    self:Auto()

end

function Graves:CastQ(target)
    if Ready(_Q) and lastQ + 550 < GetTickCount() and orbwalker:CanMove() and not orbwalker:CanAttack() then
        local Pred = GGPrediction:SpellPrediction(self.Q)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
        if Pred.Hitchance or Pred.HitChance >= self.Q.Hitchance  or Pred:CanHit(self.Q.Hitchance or GGPrediction.HITCHANCE_HIGH) then
            lineQ = self:CreateQPoly(Pred.CastPosition)
            for i, lineSegment in ipairs(lineQ:__getLineSegments()) do
                if MapPosition:intersectsWall(lineSegment) then
                    return
                end
            end
            Control.CastSpell(HK_Q, Pred.CastPosition)
            print("cast Q")
            lastQ = GetTickCount()
        end
    end
end

function Graves:Combo()
    local target = TargetSelector:GetTarget(self.W.Range)
    if target and Ready(_W) and lastW + 300 < GetTickCount() then
        if self.tyMenu.Combo.W:Value() and orbwalker:CanMove() then
        local Pred = GGPrediction:SpellPrediction(self.W)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.W, myHero)
                if Pred.Hitchance or Pred.HitChance >= self.W.Hitchance  or Pred:CanHit(self.W.Hitchance or GGPrediction.HITCHANCE_HIGH) then
                Control.CastSpell(HK_W, Pred.CastPosition)
                lastW = GetTickCount()
            end
        end
    end

    local target = TargetSelector:GetTarget(self.Q.Range)
    if target and self.tyMenu.Combo.Q:Value() then
        self:CastQ(target)
    end
end

function Graves:Harass()
    local target = TargetSelector:GetTarget(self.Q.Range)
    if target and self.tyMenu.Combo.Q:Value() then
        self:CastQ(target)
    end
end

function Graves:Jungle()
    local target = orbwalker:GetTarget()
    if target and self.tyMenu.Jungle.Q:Value() then
        self:CastQ(target)
    end
end

function Graves:Auto()
    if Ready(_R) and lastR + 180 < GetTickCount() then
        for i = 1, #Enemys do
            local target = Enemys[i]
            if target.health < self:GetRDmg(target) and IsValid(target) and
            GetDistanceSquared(myHero.pos, target.pos) < self.R.Range ^2 then
            local Pred = GGPrediction:SpellPrediction(self.R)
            Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.R, myHero)
                if Pred.Hitchance or Pred.HitChance >= self.R.Hitchance  or Pred:CanHit(self.R.Hitchance or GGPrediction.HITCHANCE_HIGH) then
                    Control.CastSpell(HK_R, Pred.CastPosition)
                    lastR = GetTickCount()
                end
            end
        end
    end
end


function Graves:Draw()

    if myHero.dead then return end

    if self.tyMenu.Drawing.Q:Value() and  Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.W:Value() and  Ready(_W) then
        Draw.Circle(myHero.pos, self.W.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range(),Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.R:Value() and  Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Graves:CreateQPoly(position)
    local startPos = myHero.pos
    local endPos = position
    local width = 40
    local c1 = startPos+Vector(Vector(endPos)-startPos):Perpendicular():Normalized()*width
    local c2 = startPos+Vector(Vector(endPos)-startPos):Perpendicular2():Normalized()*width
    local c3 = endPos+Vector(Vector(startPos)-endPos):Perpendicular():Normalized()*width
    local c4 = endPos+Vector(Vector(startPos)-endPos):Perpendicular2():Normalized()*width

    local poly = Polygon(c1,c2,c3,c4)

    return poly
end

function Graves:GetRDmg(target)
    local baseDmg = math.floor(({250, 400, 550})[myHero:GetSpellData(_R).level])
    local bonusDmg = math.floor(myHero.bonusDamage * 1.5)

    local value = baseDmg + bonusDmg

    return CalcPhysicalDamage(myHero, target, value)

end


Graves()

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

class "Kindred"

function Kindred:__init()
    self.Q = {Range = 340, Speed = 500}
    self.W = {Range = 500}
    self.E = {Range = function() return myHero.boundingRadius + myHero.range end}
    self.R = {Range = 500}

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

function Kindred:LoadMenu()

    self.tyMenu = MenuElement({type = MENU, id = "14Kindred", name = "[14AIO] Kindred"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({id = "Q", name = "[Q] AA reset", value = true})
        self.tyMenu.Combo:MenuElement({id = "W", name = "[W]", value = true})
        self.tyMenu.Combo:MenuElement({id = "E", name = "[E]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({id = "Q", name = "[Q] AA reset", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Wave", name = "Wave Clean"})
        self.tyMenu.Wave:MenuElement({id = "Q", name = "[Q] AA reset", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
        self.tyMenu.Auto:MenuElement({id = "RHP", name = "Auto R Ally HP < X %", value = 15, min = 1, max = 100, step = 1})
        self.tyMenu.Auto:MenuElement({name = "Auto R ally ", id = "autoR", type = _G.MENU})
            OnAllyHeroLoad(function(hero) self.tyMenu.Auto.autoR:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)

    
    self.tyMenu:MenuElement({type = MENU, id = "Setting", name = "Setting"})
        self.tyMenu.Setting:MenuElement({id = "Qmode", name ="Q mode" , drop = {"To Side", "To Cursor"}})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Kindred:OnPostAttackTick(args)
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if self.AttackTarget and Ready(_Q) and lastQ + 200 < GetTickCount() then
        if (orbwalker.Modes[0] and self.tyMenu.Combo.Q:Value() and self.AttackTarget.type == Obj_AI_Hero) 
        or (orbwalker.Modes[1] and self.tyMenu.Harass.Q:Value() and self.AttackTarget.type == Obj_AI_Hero) 
        or (orbwalker.Modes[3] and self.tyMenu.Wave.Q:Value()) then
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

function Kindred:Tick()
    if orbwalker.Modes[0] then --combo
        self:Combo()
    end

    self:Auto()
end

function Kindred:Combo()
    local target = TargetSelector:GetTarget(self.E.Range())
    if target and Ready(_E) and lastE + 300 < GetTickCount() then
        if self.tyMenu.Combo.E:Value() and orbwalker:CanMove() then
            Control.CastSpell(HK_E,target.pos)
            lastE = GetTickCount()
        end
    end

    local target = TargetSelector:GetTarget(self.W.Range)
    if target and Ready(_W) and lastW + 300 < GetTickCount() then
        if self.tyMenu.Combo.W:Value() then
            Control.CastSpell(HK_W,target.pos)
            lastW = GetTickCount()
        end
    end
end

function Kindred:Auto()
    for k, ally in pairs(Allys) do
        if Ready(_R) and lastR + 180 < GetTickCount() then
            if self.tyMenu.Auto.autoR[ally.charName] and self.tyMenu.Auto.autoR[ally.charName]:Value() then
                if IsValid(ally) and GetDistanceSquared(myHero.pos, ally.pos) < self.R.Range ^2 then
                    if ally.health / ally.maxHealth * 100 < self.tyMenu.Auto.RHP:Value() and self:GetEnemyAround(ally) > 0 then
                        Control.CastSpell(HK_R)
                        print("low Health cast R "..ally.charName)
                        lastR = GetTickCount()
                        return
                    end
                end
            end
        end
    end
end

function Kindred:GetEnemyAround(ally)
    local counter = 0
    for enemyk , enemy in pairs(Enemys) do 
        if IsValid(enemy) and enemy.pos:DistanceTo(ally.pos) < 650 then
            counter = counter + 1
        end
    end
    return counter
end

function Kindred:Draw()

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

Kindred()
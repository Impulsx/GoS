require 'PremiumPrediction'
local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert


local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector

local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0
local lastMove = 0
local lastAttack = 0

local Enemys =   {}
local Allys  =   {}

local function HasBuff(name ,unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name then
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


class "Tryndamere"

function Tryndamere:__init()
    -- self.E = {
    --     Hitchance = _G.HITCHANCE_NORMAL,
    --     Type = _G.SPELLTYPE_LINE,
    --     Delay = 0,
    --     Radius = 150,
    --     Range = 780,
    --     Speed = 900,
    --     Collision = false
    --     -- MaxCollision = 0,
    --     -- CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
    -- }

    self.E = {speed = 900, range = 780, delay = 0, radius = 150, collision = nil, type = "linear"}

    self.W = {range = 850}

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

function Tryndamere:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Tryndamere", name = "[14AIO] Tryndamere"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({id = "W", name = "[W]", value = true})
        self.tyMenu.Combo:MenuElement({id = "E", name = "[E]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
        self.tyMenu.Flee:MenuElement({id = "W", name = "[W]", value = true})
        self.tyMenu.Flee:MenuElement({id = "E", name = "[E]", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "Esetting", name = "E setting"})
        -- self.tyMenu.Esetting:MenuElement({id = "Eextent", name = "extend E cast Position", value = 100, min = 1, max = 400, step = 1})
        self.tyMenu.Esetting:MenuElement({id = "EhitChance", name = " E Hit Chance", value = 0.5, min = 0.1, max = 1, step = 0.01})


    self.tyMenu:MenuElement({type = MENU, id = "AutoR", name = "Auto R"})
        self.tyMenu.AutoR:MenuElement({id = "R", name = "use R", value = true})
        self.tyMenu.AutoR:MenuElement({id = "Rcount", name = "R only if Enemy Around", value = true})
        self.tyMenu.AutoR:MenuElement({id = "RHP", name = "If HP lower than (%)", value = 20, min = 1, max = 100, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 80, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 80, min = 1, max = 500, step = 1})


    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})

end

function Tryndamere:Draw()
    if myHero.dead then
        return
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end


    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Tryndamere:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end


    if orbwalker.Modes[0] then --combo
        self:Combo()
    end
    if orbwalker.Modes[5] then
        self:Flee()
    end

    self:AutoR()

end

function Tryndamere:Combo()
    target = TargetSelector:GetTarget(self.W.range)

    if target and IsValid(target) and self.tyMenu.Combo.W:Value() then
        self:CastW(target)
    end

    target = TargetSelector:GetTarget(self.E.range)
    if target and IsValid(target) and self.tyMenu.Combo.E:Value() then
        self:CastE(target)
    end
    

end

function Tryndamere:CastW(target)
    if Ready(_W) and orbwalker:CanMove() and lastW + 300 < GetTickCount() then
        if not _G.PremiumPrediction:IsFacing(target, myHero, 90) then
            Control.CastSpell(HK_W)
            lastW = GetTickCount()
        end
    end
end

function Tryndamere:CastE(target)
    if Ready(_E) and orbwalker:CanMove() and lastE + 250 < GetTickCount() then
        local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.E)
        if pred.CastPos and pred.HitChance > self.tyMenu.Esetting.EhitChance:Value() then
            Control.CastSpell(HK_E,pred.CastPos)
            lastE = GetTickCount()
        end
    end

end

function Tryndamere:Flee()
    target = TargetSelector:GetTarget(self.W.range)
    if target and IsValid(target) and self.tyMenu.Flee.W:Value() then
        if Ready(_W) and orbwalker:CanMove() and lastW + 300 < GetTickCount() then
            Control.CastSpell(HK_W)
            lastW = GetTickCount()
        end
    end

    if self.tyMenu.Flee.E:Value() and Ready(_E) and lastE + 250 < GetTickCount() then
        local castPos = myHero.pos:Extended(mousePos, self.E.range)
        Control.CastSpell(HK_E,castPos)
        lastE = GetTickCount()
    end



    
end

function Tryndamere:AutoR()

    if Ready(_R) and self.tyMenu.AutoR.R:Value() then
        if myHero.health / myHero.maxHealth * 100 < self.tyMenu.AutoR.RHP:Value() then

            if self.tyMenu.AutoR.Rcount:Value() then
                if self:GetEnemyAround(myHero) > 0 then
                    Control.CastSpell(HK_R)
                    lastR = GetTickCount()    
                end
            else
                Control.CastSpell(HK_R)
                lastR = GetTickCount()
            end
        end
    end
end

function Tryndamere:GetEnemyAround(ally)
    local counter = 0
    for enemyk , enemy in pairs(Enemys) do 
        if IsValid(enemy) and enemy.pos:DistanceTo(ally.pos) < 650 then
            counter = counter + 1
        end
    end
    return counter
end

Tryndamere()
require 'PremiumPrediction'

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector
local damage            = _G.SDK.Damage

local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0
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
    return Game.CanUseSpell(spell) == 0
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

class "Talon"

function Talon:__init()
    self.Q = {range = 575}
    self.W = {speed = 2500, range = 800, delay = 0.25, radius = 0, angle = 34, windup = 0.25, collision = nil, type = "conic"}
    self.R = {range = 550}

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

function Talon:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Talon", name = "[14AIO] Talon"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({id = "Burst", name = "burst mode",key = string.byte('T'),toggle = true})    
        self.tyMenu.Combo:MenuElement({id = "QRange", name = "Range Q", value = true})
        self.tyMenu.Combo:MenuElement({id = "QMelee", name = "Melee Q AA reset", value = true})
        self.tyMenu.Combo:MenuElement({id = "W", name = "W", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({id = "QRange", name = "Range Q", value = false})
        self.tyMenu.Harass:MenuElement({id = "QMelee", name = "Melee Q AA reset", value = true})
        self.tyMenu.Harass:MenuElement({id = "W", name = "W", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "KS", name = "KS"})
        self.tyMenu.KS:MenuElement({id = "Q", name = "Q", value = true})
        self.tyMenu.KS:MenuElement({id = "W", name = "W", value = true})
        self.tyMenu.KS:MenuElement({id = "R", name = "R", value = false})

    self.tyMenu:MenuElement({type = MENU, id = "Setting", name = "Setting"})
        self.tyMenu.Setting:MenuElement({id = "Whitchance", name = "W hitchance", value = 0.4, min = 0.01, max = 1, step = 0.01})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 1, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 1, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Damage", name = "Draw Combo Damage of enemy", value = true})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Talon:Draw()
    if myHero.dead then return end

    if self.tyMenu.Combo.Burst:Value() then
        Draw.Text("Brust Mode: On ",15,myHero.pos:To2D(),Draw.Color(255 ,0xFF,0xFF,0xFF))
    else
        Draw.Text("Brust Mode: Off ",15,myHero.pos:To2D(),Draw.Color(255 ,0xFF,0xFF,0xFF))

    end

    if self.tyMenu.Drawing.Damage:Value() then
        for i = 1, #Enemys do
            local enemy = Enemys[i]
            if IsValid(enemy) then
                local value = 0
                if Ready(_Q) then
                    value = value + self:getQDamage(enemy)
                end
                if Ready(_W) then
                    value = value + self:getWDamage(enemy)
                end
                if Ready(_R) then
                    value = value + self:getRDamage(enemy)
                    value = value + self:getRDamage(enemy)
                end

                if enemy.health + enemy.shieldAD - value < 0 then
                    Draw.Text("Killable ",20,enemy.pos:To2D(),Draw.Color(255 ,0xFF,0x00,0x00))
                else
                    Draw.Text("HP left after combo: "..enemy.health + enemy.shieldAD - value,20,enemy.pos:To2D())
                end
            end
        end
    end

    if self.tyMenu.Drawing.Q:Value() and  Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Talon:OnPostAttackTick()
    if orbwalker.Modes[0] and self.tyMenu.Combo.QMelee:Value() then
        local target = TargetSelector:GetTarget()

        if target and lastQ + 300 < GetTickCount() and Ready(_Q) then
            Control.CastSpell(HK_Q,target)
            lastQ = GetTickCount()
        end
    end

    if orbwalker.Modes[1] and self.tyMenu.Harass.QMelee:Value() then
        local target = TargetSelector:GetTarget()

        if target and lastQ + 300 < GetTickCount() and Ready(_Q) then
            Control.CastSpell(HK_Q,target)
            lastQ = GetTickCount()
        end
    end
end

function Talon:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

    self:KS()

end

function Talon:Combo()
    if self.tyMenu.Combo.Burst:Value() then
        local target = TargetSelector:GetTarget(self.W.range)
        if target then
            self:CastW(target)
        end
        local target = TargetSelector:GetTarget(self.R.range)
        if target and Ready(_R) and lastR + 300 < GetTickCount() then
            Control.CastSpell(HK_R)
            lastR = GetTickCount()
        end

        local target = TargetSelector:GetTarget(self.Q.range)
        if target and Ready(_Q) and lastQ + 300 < GetTickCount() and not Ready(_R) then
            Control.CastSpell(HK_Q, target)
            lastQ = GetTickCount()
        end

    else
        local target = TargetSelector:GetTarget(self.W.range)
        if target and self.tyMenu.Combo.W:Value() then
            self:CastW(target)
        end

        local target = TargetSelector:GetTarget(self.Q.range)
        if target and self.tyMenu.Combo.QRange:Value() then
            if Ready(_Q) and
            GetDistanceSquared(myHero.pos, target.pos) > (myHero.range + myHero.boundingRadius + target.boundingRadius)^2
            and lastQ + 300 < GetTickCount()
            then
                Control.CastSpell(HK_Q, target)
                lastQ = GetTickCount()
            end
        end
    end

end

function Talon:Harass()
    local target = TargetSelector:GetTarget(self.Q.range)
    if target and self.tyMenu.Harass.QRange:Value() then
        if Ready(_Q) and
        GetDistanceSquared(myHero.pos, target.pos) > (myHero.range + myHero.boundingRadius + target.boundingRadius)^2
        and lastQ + 300 < GetTickCount()
        then
            Control.CastSpell(HK_Q, target)
            lastQ = GetTickCount()
        end
    end

    local target = TargetSelector:GetTarget(self.W.range)
    if target and self.tyMenu.Harass.W:Value() then
        self:CastW(target)
    end
end

function Talon:KS()
    for i = 1, #Enemys do
        local enemy = Enemys[i]

        if IsValid(enemy) then
            if self.tyMenu.KS.Q:Value() and  Ready(_Q) and lastQ + 300 < GetTickCount() then
                if enemy.health + enemy.shieldAD < self:getQDamage(enemy) then
                    Control.CastSpell(HK_Q, target)
                    lastQ = GetTickCount()    
                    return
                end
            end
            if self.tyMenu.KS.W:Value() and  Ready(_W) and lastW + 300 < GetTickCount() then
                if enemy.health + enemy.shieldAD < self:getWDamage(enemy) then
                    self:CastW(enemy)
                    return
                end
            end

            if self.tyMenu.KS.R:Value() and  Ready(_R) and lastR + 300 < GetTickCount() then
                if enemy.health + enemy.shieldAD < self:getRDamage(enemy) then
                    Control.CastSpell(HK_R)
                    lastR = GetTickCount()   
                    return 
                end
            end
        end
    end
end

function Talon:CastW(target)
    if Ready(_W) and lastW + 300 < GetTickCount() and orbwalker:CanMove() then
        local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.W)
        if pred.CastPos and pred.HitChance > self.tyMenu.Setting.Whitchance:Value() then
            Control.CastSpell(HK_W, pred.CastPos)
            lastW = GetTickCount()
        end 
    end
end

function Talon:getQDamage(target)
    local baseDMG = ({65,90,115,140,165})[myHero:GetSpellData(0).level]
    local AD = myHero.bonusDamage * 1.1

    local value = baseDMG + AD
    if GetDistanceSquared(myHero.pos,target.pos) < (myHero.range + myHero.boundingRadius + target.boundingRadius) ^2 then
        value = value * 1.5
    end

    return damage:CalculateDamage(myHero, target, _G.SDK.DAMAGE_TYPE_PHYSICAL ,  value )

end

function Talon:getWDamage(target)
    local baseDMG = ({45,60,75,90,105})[myHero:GetSpellData(1).level]
    local AD = myHero.bonusDamage * 0.4

    local value = baseDMG + AD

    return damage:CalculateDamage(myHero, target, _G.SDK.DAMAGE_TYPE_PHYSICAL ,  value )

end

function Talon:getRDamage(target)
    local baseDMG = ({90,135,180})[myHero:GetSpellData(3).level]
    local AD = myHero.bonusDamage

    local value = baseDMG + AD

    return damage:CalculateDamage(myHero, target, _G.SDK.DAMAGE_TYPE_PHYSICAL ,  value )

end

Talon()
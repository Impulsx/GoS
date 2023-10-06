require 'GGPrediction'
local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert


local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector
local DamageLib         = _G.SDK.Damage

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

class "Kennen"


function Kennen:__init()
    self.Q = {
        Type = GGPrediction.SPELLTYPE_LINE,
        Delay = 0.175,
        Radius = 50,
        Range = 950,
        Speed = 1700,
        Collision = true,
        MaxCollision = 0,
        CollisionTypes = {GGPrediction.COLLISION_MINION, GGPrediction.COLLISION_YASUOWALL}}
    self.W = {Range = 770}
    self.R = {Range = 550}

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

function Kennen:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Kennen", name = "14 Kennen"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W] ", value = true})
    self.tyMenu.Combo:MenuElement({id = "rCount", name = "Use R If Can Hit X", value = 3, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Harass:MenuElement({id = "UseW", name = "[W] ", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
    self.tyMenu.Auto:MenuElement({id = "UseQ", name = "auto Q stun", value = true})
    self.tyMenu.Auto:MenuElement({id = "UseW", name = "auto W stun", value = true})
    self.tyMenu.Auto:MenuElement({id = "rCount", name = "Use R If Can Hit X", value = 3, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Damage", name = "Draw Combo Damage of enemy", value = true})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Kennen:Draw()
    if myHero.dead then
        return
    end

    if self.tyMenu.Drawing.Damage:Value() then
        for i = 1, #Enemys do
            local enemy = Enemys[i]
            if IsValid(enemy) then
                local value = 0
                if Ready(_Q) then
                    value = value + self:GetQDamage(enemy)
                end
                if Ready(_W) then
                    value = value + self:GetWDamage(enemy)
                end
                if Ready(_R) then
                    value = value + self:GetRDamage(enemy)
                end

                Draw.Text("HP left after combo: "..enemy.health - value,enemy.pos:To2D())
            end
        end
    end


    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end


    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Kennen:Tick()

    self:CheckE()

    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end


    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

    self:Auto()

end

function Kennen:CheckE()
    if HasBuff("KennenLightningRush", myHero) then
        orbwalker:SetAttack(false)
    else
        orbwalker:SetAttack(true)
    end
    --KennenLightningRush
end

function Kennen:Combo()

    target = self:GetTarget(Enemys, self.Q.Range)
    if target and IsValid(target) and self.tyMenu.Combo.UseQ:Value() then
        self:CastQ(target)
    end

    target = self:GetTarget(Enemys, self.W.Range)
    if target and IsValid(target) and self.tyMenu.Combo.UseW:Value() and orbwalker:CanMove() then
        if Ready(_W) and lastW +260 < GetTickCount() and HasBuff("kennenmarkofstorm",target) then
            local casted = Control.CastSpell(HK_W)
            if casted then
                lastW = GetTickCount()
                -- print("W "..GetTickCount())
            end
        end
    end



    if Ready(_R) and lastR +260 < GetTickCount() then
        if self:GetTargetInRange(self.R.Range) >= self.tyMenu.Combo.rCount:Value() then
            local casted = Control.CastSpell(HK_R)
            if casted then
                lastR = GetTickCount()
                -- print("W "..GetTickCount())
            end
        end
    end

end

function Kennen:Harass()
    target = self:GetTarget(Enemys, self.Q.Range)
    if target and IsValid(target) and self.tyMenu.Harass.UseQ:Value() then
        self:CastQ(target)
    end

    target = self:GetTarget(Enemys, self.W.Range)
    if target and IsValid(target) and self.tyMenu.Harass.UseW:Value() and orbwalker:CanMove() then
        if Ready(_W) and lastW +260 < GetTickCount() and HasBuff("kennenmarkofstorm",target) then
            local casted = Control.CastSpell(HK_W)
            if casted then
                lastW = GetTickCount()
                -- print("W "..GetTickCount())
            end
        end
    end

end

function Kennen:Auto()

    if self.tyMenu.Auto.UseQ:Value() and Ready(_Q) and lastQ +260 < GetTickCount() and orbwalker:CanMove() then
        for i = 1, #Enemys do
            local hero = Enemys[i]
            if IsValid(hero) and GetDistanceSquared(hero.pos, myHero.pos) < self.Q.Range * self.Q.Range then
                local hasbuff , duration, count = HasBuff("kennenmarkofstorm",hero)
                if hasbuff and count == 2 then
                    local Pred = GGPrediction:SpellPrediction(self.Q)
                    Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
                    if Pred:CanHit(2 or GGPrediction.HITCHANCE_NORMAL) then
                        local casted = Control.CastSpell(HK_Q, Pred.CastPosition)
                        if casted then
                            lastQ = GetTickCount()
                            return
                            -- print("Q "..GetTickCount())
                        end
                    end
                end
            end
        end
    end

    if self.tyMenu.Auto.UseW:Value() and Ready(_W) and lastW +260 < GetTickCount() and orbwalker:CanMove() then
        for i = 1, #Enemys do
            local hero = Enemys[i]
            if IsValid(hero) and GetDistanceSquared(hero.pos, myHero.pos) < self.W.Range * self.W.Range then
                local hasbuff , duration, count = HasBuff("kennenmarkofstorm",hero)
                if hasbuff and count == 2 then
                    local casted = Control.CastSpell(HK_W)
                    if casted then
                        lastW = GetTickCount()
                        return
                        -- print("Q "..GetTickCount())
                    end
                end
            end
        end
    end

    if Ready(_R) and lastR +260 < GetTickCount() then
        if self:GetTargetInRange(self.R.Range) >= self.tyMenu.Auto.rCount:Value() then
            local casted = Control.CastSpell(HK_R)
            if casted then
                lastR = GetTickCount()
                -- print("W "..GetTickCount())
            end
        end
    end
end

function Kennen:CastQ(target)
    if Ready(_Q) and lastQ +260 < GetTickCount() and orbwalker:CanMove() then
        local Pred = GGPrediction:SpellPrediction(self.Q)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
        if Pred:CanHit(2 or GGPrediction.HITCHANCE_NORMAL)         then
            local casted = Control.CastSpell(HK_Q, Pred.CastPosition)
            if casted then
                lastQ = GetTickCount()
                -- print("Q "..GetTickCount())
            end
        end
    end
end

function Kennen:GetQDamage(target)
    local baseDmg = ({75, 115, 155,195,235})[myHero:GetSpellData(_Q).level]
    local bonusDmg = myHero.ap * 0.75

    local value = baseDmg + bonusDmg
    return DamageLib:CalculateDamage(myHero, target, _G.SDK.DAMAGE_TYPE_MAGICAL ,  value )
end

function Kennen:GetWDamage(target)
    local baseDmg = ({60, 85, 110,135,160})[myHero:GetSpellData(_W).level]
    local bonusDmg = myHero.ap * 0.8

    local value = baseDmg + bonusDmg
    return DamageLib:CalculateDamage(myHero, target, _G.SDK.DAMAGE_TYPE_MAGICAL ,  value )

end

function Kennen:GetRDamage(target)
    local baseDmg = ({300, 562.5, 825})[myHero:GetSpellData(_R).level]
    local bonusDmg = myHero.ap * 1.5
    local value = baseDmg + bonusDmg
    return DamageLib:CalculateDamage(myHero, target, _G.SDK.DAMAGE_TYPE_MAGICAL ,  value )
end



function Kennen:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

function Kennen:GetTargetInRange(range)
    local counter = 0
    for i = 1, #Enemys do
        local hero = Enemys[i]
        if IsValid(hero) and GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            counter = counter + 1
        end
    end
    return counter
end

Kennen()
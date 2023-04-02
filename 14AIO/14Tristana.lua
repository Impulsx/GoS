local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector
local TableInsert       = _G.table.insert
local objectManager     =  _G.SDK.ObjectManager
local DamageLib         = _G.SDK.Damage

local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0

local lastWard = 0
local lastMove = 0
local lastAttack = 0

local Enemys =   {}
local Allys  =   {}

local function GetDistanceSquared(vec1, vec2)
    local dx = vec1.x - vec2.x
    local dy = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    return dx * dx + dy * dy
end

local function IsDashToMe(unit)
    local d1 = GetDistanceSquared(myHero.pos, unit.pathing.startPos)
    local d2 = GetDistanceSquared(myHero.pos, unit.pathing.endPos)

    return d2 < d1
end

local function GetTargetByHandle(handle, minions, monsters)
    for i = 1, GameHeroCount() do
        local obj = GameHero(i)
        if obj.handle == handle then
            return obj
        end
    end

    if minions then
        for i = 1, #minions do
            local obj = minions[i]
            if obj.handle == handle then
                return obj
            end
        end
    end

    if monsters then
        for i = 1, #monsters do
            local obj = monsters[i]
            if obj.handle == handle then
                return obj
            end
        end
    end
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

local function HasBuff(unit , name)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name then
            return true, buff.duration, buff.count
        end
    end
    return false
end


class "Tristana"

function Tristana:__init()
    self.W = {Range = 900}
    self.E = {Range = function() return myHero.boundingRadius + myHero.range end}
    self.R = {Range = function() return myHero.boundingRadius + myHero.range end}

    self.ETarget = nil

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
                else
                    args.Process = true
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

function Tristana:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Tristana", name = "[14AIO] Tristana"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
        OnEnemyHeroLoad(function(hero) self.tyMenu.Combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
        self.tyMenu.Combo:MenuElement({id = "Q", name = "[Q]", value = true})
        self.tyMenu.Combo:MenuElement({id = "E", name = "E", value = true})
        self.tyMenu.Combo:MenuElement({id = "AA", name = "Force Attack Target have E Buff ", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Wave", name = "Wave Clean"})
        self.tyMenu.Wave:MenuElement({id = "Q", name = "[Q]", value = false})
        self.tyMenu.Wave:MenuElement({id = "E", name = "[E]", value = false})
        self.tyMenu.Wave:MenuElement({id = "AA", name = "Force Attack Target have E Buff ", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
        self.tyMenu.Auto:MenuElement({id = "UseR", name = "[R] KS", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Anti", name = "Anti Gap"})
        self.tyMenu.Anti:MenuElement({id = "AntiR", name = "[R] Anti Gap R", value = true})
            OnEnemyHeroLoad(function(hero) self.tyMenu.Anti:MenuElement({id = hero.charName, name = hero.charName, value = false}) end)

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Tristana:OnPreAttack(args)
    if args.Process then
        if orbwalker.Modes[0] then
            if self.tyMenu.Combo.useon[args.Target.charName] and self.tyMenu.Combo.useon[args.Target.charName]:Value() then
                if Ready(_Q) and lastQ + 300 < GetTickCount() and self.tyMenu.Combo.Q:Value() then
                    Control.CastSpell(HK_Q)
                    lastQ = GetTickCount()
                end
            end

            if self.tyMenu.Combo.AA:Value() then
                local heros = objectManager:GetEnemyHeroes(self.E.Range(), true, true, true, true)
                if self.ETarget and IsValid(self.ETarget) and self.ETarget.type == myHero.type then
                    args.Target = self.ETarget
                end
                for i = 1, #heros do
                    local target = heros[i]
                    if HasBuff(target,"tristanaecharge") and IsValid(target) and GetDistanceSquared(myHero.pos, target.pos) < self.E.Range() ^2 then
                        args.Target = target
                        self.ETarget = nil
                    end
                end
            end

        end

        if orbwalker.Modes[3] then
            if Ready(_Q) and lastQ + 300 < GetTickCount() and self.tyMenu.Wave.Q:Value() then
                Control.CastSpell(HK_Q)
                lastQ = GetTickCount()
            end

            if self.tyMenu.Wave.AA:Value() then
                if self.ETarget and IsValid(self.ETarget) then
                    args.Target = self.ETarget
                end
                local target = self:WaveCheckEBuff()
                if target then
                    args.Target = target
                    self.ETarget = nil
                    return
                end
            end
        end
    end
end

function Tristana:Tick()

    self:CheckETarget()

    if myHero.dead or Game.IsChatOpen() or
    (ExtLibEvade and ExtLibEvade.Evading == true) then return end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[3] then --jungle
        self:WaveClean()
    end

    self:KS()
    self:AntiGap()

end

function Tristana:Combo()
    local targetList = {}

    for i = 1, #Enemys do
        local hero = Enemys[i]
        if self.tyMenu.Combo.useon[hero.charName] 
        and self.tyMenu.Combo.useon[hero.charName]:Value()
        and GetDistanceSquared(myHero.pos, hero.pos) < self.E.Range() ^2
        then
            targetList[#targetList + 1] = hero
        end
    end

    local target = TargetSelector:GetTarget(targetList)

    if target and self.tyMenu.Combo.E:Value() then
        if Ready(_E) and lastE + 300 < GetTickCount() and orbwalker:CanMove() then
            Control.CastSpell(HK_E, target.pos)
            lastE = GetTickCount()
        end
    end
end

function Tristana:WaveClean()
    local target = orbwalker:GetTarget()

    if target and self.tyMenu.Wave.E:Value() then
        if Ready(_E) and lastE + 300 < GetTickCount() and orbwalker:CanMove() then
            Control.CastSpell(HK_E, target.pos)
            lastE = GetTickCount()
        end
    end
end

function Tristana:KS()

    if Ready(_R) and lastR + 180 < GetTickCount() and self.tyMenu.Auto.UseR:Value() then
        for i = 1, #Enemys do
            local target = Enemys[i]
            if target.health < self:GetRDmg(target) and IsValid(target) and
            GetDistanceSquared(myHero.pos, target.pos) < self.R.Range() ^2 then
                Control.CastSpell(HK_R, target.pos)
                lastR = GetTickCount()
            end
        end
    end
end

function Tristana:AntiGap()
    if self.tyMenu.Anti.AntiR:Value() and Ready(_R) and lastR + 500 < GetTickCount() then
        for i = 1, #Enemys do
            local enemy = Enemys[i]
            if self.tyMenu.Anti[enemy.charName] and self.tyMenu.Anti[enemy.charName]:Value() then
                if IsValid(enemy) and GetDistanceSquared(myHero.pos, enemy.pos) < self.R.Range() ^2 then
                    local path = enemy.pathing
                    if path.isDashing and path.hasMovePath and path.dashSpeed > 0 
                    and IsDashToMe(enemy) 
                    then
                        Control.CastSpell(HK_R,enemy)
                        print("anti R")
                        lastR = GetTickCount()
                    end
                end
            end
        end
    end
end

function Tristana:Draw()

    if myHero.dead then return end

    if self.tyMenu.Drawing.W:Value() and  Ready(_W) then
        Draw.Circle(myHero.pos, self.W.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range(),Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.R:Value() and  Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range(),Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Tristana:CheckETarget()
    -- tristanaecharge
    if myHero.activeSpell.valid and myHero.activeSpell.name == "TristanaE" then
        local target = GetTargetByHandle(myHero.activeSpell.target,objectManager:GetEnemyMinions(self.E.Range()) ,objectManager:GetMonsters(self.E.Range()))
        if target then
            self.ETarget = target
            DelayAction(function()
                self.ETarget = nil
            end, 5)
        end
    end
end

function Tristana:WaveCheckEBuff()
    local enemyMinions  =   objectManager:GetEnemyMinions(self.E.Range())
    local monsters      =   objectManager:GetMonsters(self.E.Range())

    if enemyMinions then
        for i = 1, #enemyMinions do
            local obj = enemyMinions[i]
            if HasBuff(obj,"tristanaecharge") then
                return obj
            end
        end
    end

    if monsters then
        for i = 1, #monsters do
            local obj = monsters[i]
            if HasBuff(obj,"tristanaecharge") then
                return obj
            end
        end
    end

    return nil
end

function Tristana:GetRDmg(target)
    local Edmg = 0
    local baseDmg = ({300, 400, 500})[myHero:GetSpellData(_R).level]
    local bonusDmg = myHero.ap * 1

    local value = baseDmg + bonusDmg

    local hasbuff, duration, count = HasBuff(target,"tristanaecharge")

    if hasbuff and count == 3 then
        local EbaseDmg = ({70, 80, 90, 100,110})[myHero:GetSpellData(_E).level]
        local Ead = myHero.bonusDamage * ({0.5, 0.7, 0.9, 1.1,1.3})[myHero:GetSpellData(_E).level]
        local Eap = myHero.ap * 0.5



        local EcountDmg = EbaseDmg + 4*({21, 24, 27, 30,33})[myHero:GetSpellData(_E).level]
        local EcountAd = Ead + 4*myHero.bonusDamage * ({0.15, 0.21, 0.27, 0.33, 0.39})[myHero:GetSpellData(_E).level]
        local EcountAp = Eap + 4*myHero.ap * 0.15


        local Evalue = EcountDmg + EcountAd+ EcountAp

        Edmg = DamageLib:CalculateDamage(myHero, target, _G.SDK.DAMAGE_TYPE_PHYSICAL ,  Evalue )

    end

    local dmg = Edmg + DamageLib:CalculateDamage(myHero, target, _G.SDK.DAMAGE_TYPE_MAGICAL ,  value) 
    return dmg
end

Tristana()
if myHero.charName ~= "Senna" then return end

require('GamsteronPrediction')
_G.SennaAnima = 1.3

local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameObjectCount = Game.ObjectCount
local GameObject = Game.Object

local TableInsert = _G.table.insert

local orbwalker = _G.SDK.Orbwalker
local TargetSelector = _G.SDK.TargetSelector
local ObjectManager = _G.SDK.ObjectManager

local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0
local lastIG = 0
local lastMove = 0
local lastAttack = 0

local HK_ITEM_1 = HK_ITEM_1
local HK_ITEM_2 = HK_ITEM_2
local HK_ITEM_3 = HK_ITEM_3
local HK_ITEM_4 = HK_ITEM_4
local HK_ITEM_5 = HK_ITEM_5
local HK_ITEM_6 = HK_ITEM_6
local HK_ITEM_7 = HK_ITEM_7

local Enemys = {}
local Allys = {}
local recalling = {}

local function GetDistanceSquared(vec1, vec2)
    local dx = vec1.x - vec2.x
    local dy = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    return dx * dx + dy * dy
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and
        unit.visible and unit.networkID and unit.health > 0 and not unit.dead) then
        return true
    end
    return false
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and
               myHero:GetSpellData(spell).level > 0 and
               myHero:GetSpellData(spell).mana <= myHero.mana
     and Game.CanUseSpell(spell) == 0
end

local function OnAllyHeroLoad(cb)
    for i = 1, GameHeroCount() do
        local obj = GameHero(i)
        if obj.isAlly then cb(obj) end
    end
end

local function OnEnemyHeroLoad(cb)
    for i = 1, GameHeroCount() do
        local obj = GameHero(i)
        if obj.isEnemy then cb(obj) end
    end
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

class "Senna"

function Senna:__init()
    self.Q1 = {Delay = 0.4, Range = function() return myHero.range + myHero.boundingRadius + myHero.boundingRadius end}
    self.Q2 = {
        Type = _G.SPELLTYPE_LINE,
        Delay = 0.4,
        Radius = 50,
        Range = 1300,
        Speed = math.huge,
        Collision = false
    }

    self.W = {
        Type = _G.SPELLTYPE_LINE,
        Delay = 0.25,
        Radius = 60,
        Range = 1100,
        Speed = 1000,
        Collision = true,
        MaxCollision = 0,
        CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
    }
    self.R = {
        Type = _G.SPELLTYPE_LINE,
        Delay = 1,
        Radius = 80,
        Range = math.huge,
        Speed = 20000,
        Collision = false
    }

    self.ItemSlots = {ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}

    self.EnemyBase = nil
    for i = 1, GameObjectCount() do
        local base = GameObject(i)
        if base.isEnemy and base.type == Obj_AI_SpawnPoint then
            self.EnemyBase = base
            break
        end
    end

    self:LoadMenu()

    OnAllyHeroLoad(function(hero) TableInsert(Allys, hero) end)

    OnEnemyHeroLoad(function(hero)
        TableInsert(Enemys, hero)
        recalling[hero.networkID] = {
            hero = nil,
            info = nil,
            starttime = 0,
            isRecalling = false
        }
    end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

    orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
    -- orbwalker:OnPostAttackTick(function(...) self:OnPostAttackTick(...) end)
    function OnProcessRecall(...) self:OnProcessRecall(...) end

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

function Senna:OnPreAttack(args)
    if self.tyMenu.Harass.LH:Value() and orbwalker.Modes[1] and args.Target.type ~=
        myHero.type then
        args.Process = false
        if lastMove + 180 < GetTickCount() then
            orbwalker:Move()
            lastMove = GetTickCount()
        end
    end
end

function Senna:OnPostAttackTick()
    if orbwalker.Modes[0] then
        if self.tyMenu.Combo.UseQ:Value() and Ready(_Q) and lastQ + 350 <
            GetTickCount() then
            local target = self:GetTarget(Enemys, self.Q1.Range() + 50)
            if target and IsValid(target) then
                Control.CastSpell(HK_Q, target)
                orbwalker:__OnAutoAttackReset()
                lastQ = GetTickCount()
            end
        end
    end
end

function Senna:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Senna", name = "14 Senna"})

    -- combo

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({
        id = "UseQ",
        name = "[Q] After AA",
        value = true
    })
    self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})

    -- --Harass
    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({
        id = "UseQ",
        name = "[Q] Out Of AA Range",
        value = true
    })
    self.tyMenu.Harass:MenuElement({id = "UseW", name = "[W] ", value = true})
    self.tyMenu.Harass:MenuElement({
        id = "LH",
        name = "Support Mode",
        value = true
    })

    -- --Auto
    self.tyMenu:MenuElement({type = MENU, id = "KS", name = "KS"})
    self.tyMenu.KS:MenuElement({
        id = "UseQ",
        name = "[Q] KS Out Of AA Range",
        value = true
    })
    self.tyMenu.KS:MenuElement({
        id = "WQ",
        name = " TRY Ward [Q] KS Out Of AA Range",
        value = false
    })
    self.tyMenu.KS:MenuElement({id = "R", name = "[R] KS ", value = true})
    self.tyMenu.KS:MenuElement({
        id = "MinRange",
        name = "Min R Range",
        value = 1300,
        min = 1,
        max = 2000,
        step = 1
    })
    self.tyMenu.KS:MenuElement({
        id = "MaxRange",
        name = "Max R Range",
        value = 5000,
        min = 1,
        max = 20000,
        step = 1
    })

    self.tyMenu:MenuElement({type = MENU, id = "Base", name = "BastULT"})
    self.tyMenu.Base:MenuElement({
        id = "Ping",
        name = "Your Ping [Very Important]",
        value = 60,
        min = 1,
        max = 300,
        step = 1
    })
    self.tyMenu.Base:MenuElement({id = "R", name = "R BaseUlt", value = true})
    self.tyMenu.Base:MenuElement({
        id = "Disable",
        name = "Disable BaseUlt If Combo Key",
        value = true
    })

    self.tyMenu:MenuElement({type = MENU, id = "Heal", name = "Auto Heal"})
    self.tyMenu.Heal:MenuElement({
        id = "Q",
        name = "Q Auto Heal Ally",
        value = false
    })
    self.tyMenu.Heal:MenuElement({
        id = "HP",
        name = "If Ally HP < X %",
        value = 20,
        min = 1,
        max = 101,
        step = 1
    })


    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    -- Draw
    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({
        id = "Q",
        name = "Draw [Q] Range",
        value = true
    })
    self.tyMenu.Drawing:MenuElement({
        id = "W",
        name = "Draw [W] Range",
        value = true
    })

end

function Senna:Draw()
    if myHero.dead then return end

    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 1300, Draw.Color(80, 0xFF, 0xFF, 0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, 1100, Draw.Color(80, 0xFF, 0xFF, 0xFF))
    end
end

function Senna:Tick()
    self:UpdateData()

    if myHero.dead or Game.IsChatOpen() or
        (ExtLibEvade and ExtLibEvade.Evading == true) then return end

    if orbwalker.Modes[0] then -- combo
        self:Combo()
    elseif orbwalker.Modes[1] then -- harass
        self:Harass()
    end

    self:KS()
    self:BaseUlt()
    self:AutoHeal()
end

function Senna:UpdateData()
    if myHero.activeSpell.valid then
        local spell = myHero.activeSpell
        if spell.name:find("Attack") then _G.SennaAnima = spell.animation end
        if spell.name == "SennaQCast" then

            self.Q1.Delay = spell.windup
            self.Q2.Delay = spell.windup
        end
    end
end

function Senna:CastW(target)
    if Ready(_W) and lastW + 550 < GetTickCount() and orbwalker:CanMove() then
        local WPrediction = GGPrediction:SpellPrediction(self.W)
        local Pred = WPrediction:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.W, myHero)
        if Pred.Hitchance >= _G.HITCHANCE_HIGH then
            Control.CastSpell(HK_W, Pred.CastPosition)
            lastW = GetTickCount()
        end
    end
end

function Senna:Combo()
    local targetList = {}
    local target

    for i = 1, #Enemys do
        local enemy = Enemys[i]
        local heroName = enemy.charName
        targetList[#targetList + 1] = enemy
    end

    target = self:GetTarget(targetList, self.Q1.Range())

    if self.tyMenu.Combo.UseQ:Value() and Ready(_Q) and lastQ + 350 <
        GetTickCount() and target and IsValid(target) and orbwalker:CanMove() then
        Control.CastSpell(HK_Q, target)
        -- orbwalker:__OnAutoAttackReset()
        lastQ = GetTickCount()
    end

    target = self:GetTarget(targetList, self.W.Range)

    if target and IsValid(target) and self.tyMenu.Combo.UseW:Value() then
        self:CastW(target)
    end

end

function Senna:Harass()
    if self.tyMenu.Harass.UseQ:Value() and Ready(_Q) and lastQ + 350 <
        GetTickCount() then

        local targetList = {}
        local target

        for i = 1, #Enemys do
            local enemy = Enemys[i]
            local heroName = enemy.charName
            targetList[#targetList + 1] = enemy
        end

        target = self:GetTarget(targetList, self.Q2.Range)
        if target and IsValid(target) and orbwalker:CanMove() then
            local QPrediction = GGPrediction:SpellPrediction(self.Q2)
            local Pred = QPrediction:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q2, myHero)
            if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                local targetPos = myHero.pos:Extended(Pred.CastPosition,
                                                      self.Q2.Range)
                local minions = ObjectManager:GetMinions(self.Q1.Range())
                for i = 1, #minions do
                    local minion = minions[i]
                    if minion then
                        local minionPos =
                            myHero.pos:Extended(minion.pos, self.Q2.Range)

                        if GetDistanceSquared(targetPos, minionPos) <=
                            (self.Q2.Radius + target.boundingRadius) ^ 2 then
                            Control.CastSpell(HK_Q, minion)
                            -- orbwalker:__OnAutoAttackReset()

                            lastQ = GetTickCount()
                        end
                    end
                end
            end
        end
    end

    if self.tyMenu.Harass.UseW:Value() and Ready(_W) and lastW + 350 <
        GetTickCount() then
        local targetList = {}
        local target

        for i = 1, #Enemys do
            local enemy = Enemys[i]
            local heroName = enemy.charName
            targetList[#targetList + 1] = enemy
        end

        target = self:GetTarget(targetList, self.W.Range)
        if target and IsValid(target) then self:CastW(target) end
    end
end

function Senna:KS()
    if self.tyMenu.KS.UseQ:Value() and Ready(_Q) and lastQ + 350 <
        GetTickCount() then
        for i = 1, #Enemys do
            local target = Enemys[i]

            if IsValid(target) and target.health + target.shieldAD <
                self:GetQDmg(target) then
                local QPrediction = GGPrediction:SpellPrediction(self.Q2)
                local Pred = QPrediction:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q2, myHero)
                if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                    local targetPos = myHero.pos:Extended(Pred.CastPosition,
                                                          self.Q2.Range)
                    local minions = ObjectManager:GetMinions(self.Q1.Range())
                    for i = 1, #minions do
                        local minion = minions[i]
                        if minion then
                            local minionPos =
                                myHero.pos:Extended(minion.pos, self.Q2.Range)

                            if GetDistanceSquared(targetPos, minionPos) <=
                                (self.Q2.Radius + target.boundingRadius) ^ 2 then
                                Control.CastSpell(HK_Q, minion)
                                -- orbwalker:__OnAutoAttackReset()
                                lastQ = GetTickCount()
                                return
                            end
                        end
                    end
                    local Heros = ObjectManager:GetHeroes(self.Q1.Range())
                    for i = 1, #Heros do
                        local hero = Heros[i]
                        if hero then
                            local heroPos =
                                myHero.pos:Extended(hero.pos, self.Q2.Range)

                            if GetDistanceSquared(targetPos, heroPos) <=
                                (self.Q2.Radius + target.boundingRadius) ^ 2 then
                                -- Control.CastSpell(HK_Q, hero)
                                -- -- orbwalker:__OnAutoAttackReset()
                                -- lastQ = GetTickCount()
                                return
                            end
                        end
                    end

                    if self.tyMenu.KS.WQ:Value() and
                        GetDistanceSquared(myHero.pos, target.pos) >
                        self.Q1.Range() ^ 2 then
                        local i, slot = self:GetItemSlot(3340) -- wd
                        if myHero:GetSpellData(slot).currentCd == 0 and i then
                            local HKItem =
                                ({
                                    HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4,
                                    HK_ITEM_5, HK_ITEM_6, HK_ITEM_7
                                })[i]
                            local wdPos =
                                myHero.pos:Extended(Pred.CastPosition, 500)
                            Control.CastSpell(HKItem, wdPos)

                            DelayAction(function()
                                Control.CastSpell(HK_Q, wdPos)
                            end, 0.15)

                            print('use wdQ')
                            lastQ = GetTickCount()
                            return
                        else
                            local i, slot = self:GetItemSlot(2055) -- wd
                            if myHero:GetSpellData(slot).currentCd == 0 and i then
                                local HKItem =
                                    ({
                                        HK_ITEM_1, HK_ITEM_2, HK_ITEM_3,
                                        HK_ITEM_4, HK_ITEM_5, HK_ITEM_6,
                                        HK_ITEM_7
                                    })[i]
                                local wdPos =
                                    myHero.pos:Extended(Pred.CastPosition, 500)
                                Control.CastSpell(HKItem, wdPos)

                                DelayAction(
                                    function()
                                        Control.CastSpell(HK_Q, wdPos)
                                    end, 0.15)

                                print('use Pink WDQ')
                                lastQ = GetTickCount()
                                return
                            end
                        end
                    end
                end
            end

        end
    end

    if self.tyMenu.KS.R:Value() and Ready(_R) and lastR + 1200 < GetTickCount() then
        for i = 1, #Enemys do
            local target = Enemys[i]
            if target.health < self:GetRDmg(target) and IsValid(target) and
                GetDistanceSquared(myHero.pos, target.pos) <
                self.tyMenu.KS.MaxRange:Value() ^ 2 and
                GetDistanceSquared(myHero.pos, target.pos) >
                self.tyMenu.KS.MinRange:Value() ^ 2 then
                print("can R")
                local RPrediction = GGPrediction:SpellPrediction(self.R)
                local Pred = RPrediction:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.R, myHero)
                if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                    Control.CastSpell(HK_R, Pred.CastPosition)
                    lastR = GetTickCount()
                end
            end
        end
    end

end

function Senna:GetItemSlot(id)
    for i = 1, #self.ItemSlots do
        local slot = self.ItemSlots[i]
        local item = myHero:GetItemData(slot)
        if item and item.itemID > 0 then
            if item.itemID == id then return i, slot end
        end
    end

    return nil
end

function Senna:GetQDmg(target)
    local baseDmg = math.floor(
                        ({50, 80, 110, 140, 170})[myHero:GetSpellData(_Q).level])
    local bonusDmg = math.floor(myHero.bonusDamage * 0.5)
    local passiveDmg = math.floor(myHero.totalDamage * 0.2)

    local value = baseDmg + bonusDmg + passiveDmg

    return CalcPhysicalDamage(myHero, target, value)
end

function Senna:AutoHeal()
    if self.tyMenu.Heal.Q:Value() and Ready(_Q) and lastQ + 350 < GetTickCount() then
        for i = 1, #Allys do
            local ally = Allys[i]
            local percetHealth = ally.health / ally.maxHealth*100
            if ally ~= myHero and GetDistanceSquared(myHero.pos, ally.pos) <
                self.Q1.Range() ^ 2 and percetHealth <
                self.tyMenu.Heal.HP:Value()
                and IsValid(ally) then
                Control.CastSpell(HK_Q, ally.pos)
                lastQ = GetTickCount()
                print("heal Q " .. ally.charName)
                return
            end
        end
    end
end

function Senna:BaseUlt()

    if self.tyMenu.Base.Disable:Value() and orbwalker.Modes[0] then return end

    if self.tyMenu.Base.R:Value() and Ready(_R) and lastR + 20000 <
        GetTickCount() then
        for k, recallObj in pairs(recalling) do
            if recallObj.isRecalling then
                local leftTime = recallObj.starttime - GetTickCount() +
                                     recallObj.info.totalTime
                local distance = self.EnemyBase.pos:DistanceTo(myHero.pos)
                local hittime = distance / 20000 + 1 +
                                    self.tyMenu.Base.Ping:Value() / 1000

                if hittime * 1000 - leftTime > 0 then
                    local PredictedHealth =
                        recallObj.hero.health + recallObj.hero.hpRegen * hittime
                    if PredictedHealth < self:GetRDmg(recallObj.hero) then
                        local castPosMM = self.EnemyBase.pos:ToMM()
                        Control.SetCursorPos(castPosMM.x, castPosMM.y)
                        Control.KeyDown(HK_R)
                        Control.KeyUp(HK_R)
                        lastR = GetTickCount()
                    end
                end
            end
        end
    end
end

function Senna:OnProcessRecall(Object, recallProc)
    if Object.team == myHero.team then return end

    local recallData = recalling[Object.networkID]

    if recallProc.isStart then
        recallData.hero = Object
        recallData.info = recallProc
        recallData.starttime = GetTickCount()
        recallData.isRecalling = true
    else
        recallData.isRecalling = false
    end
end

function Senna:GetRDmg(target)
    local baseDmg = math.floor(({250, 375, 500})[myHero:GetSpellData(_R).level])
    local bonusDmg = math.floor(myHero.bonusDamage * 1)
    local bonusAP = math.floor(myHero.ap * 0.4)

    local value = baseDmg + bonusDmg + bonusAP

    return CalcPhysicalDamage(myHero, target, value)

end

function Senna:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

Senna()

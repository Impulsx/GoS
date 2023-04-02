local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector
local TableInsert       = _G.table.insert
local objectManager     =  _G.SDK.ObjectManager

local lastQ = 0
local lastW = 0
local lastE = 0
local lastWard = 0
local lastMove = 0
local lastAttack = 0

local Enemys =   {}
local Allys  =   {}

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

class "Jax"

function Jax:__init()
    self.Q = {Range = 700}
    self.E = {Range = 350}

    self.ItemSlots = {ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}

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

function Jax:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Jax", name = "[14AIO] Jax"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({id = "Q", name = "[Q]", value = true})
        self.tyMenu.Combo:MenuElement({id = "W", name = "[W]", value = true})
        self.tyMenu.Combo:MenuElement({id = "E1", name = "E1", value = true})
        self.tyMenu.Combo:MenuElement({id = "E2", name = "E2", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Jungle", name = "Jungle Clean"})
        self.tyMenu.Jungle:MenuElement({id = "Q", name = "[Q]", value = true})
        self.tyMenu.Jungle:MenuElement({id = "W", name = "[W]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
        self.tyMenu.Flee:MenuElement({id = "Q", name = "Ward Q", value = true})
        self.tyMenu.Flee:MenuElement({id = "Pink", name = "Use Pink Ward", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})

end

function Jax:OnPostAttackTick(args)
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if Ready(_W) and lastW + 200 < GetTickCount() then
        if (orbwalker.Modes[0] and self.tyMenu.Combo.Q:Value() ) 
        or (orbwalker.Modes[3] and self.tyMenu.Jungle.Q:Value() and self.AttackTarget.team == 300 ) then
            Control.CastSpell(HK_W)
            lastW = GetTickCount()
        end
    end
end

function Jax:Tick()
    if orbwalker.Modes[0] then --combo
        self:Combo()
    end
    if orbwalker.Modes[3] then
        self:Jungle()
    end
    if orbwalker.Modes[5] then
        self:Flee()
    end
end

function Jax:Combo()
    local AArange = myHero.range + myHero.boundingRadius

    local target = TargetSelector:GetTarget(self.Q.Range)
    if target and Ready(_Q) and lastQ + 300 < GetTickCount() then
        if self.tyMenu.Combo.Q:Value() and orbwalker:CanMove()
        and myHero.pos:DistanceTo(target.pos) > AArange then
            Control.CastSpell(HK_Q,target.pos)
            lastQ = GetTickCount()
        end
    end

    local target = TargetSelector:GetTarget(self.E.Range)
    if target and Ready(_E) and lastE + 300 < GetTickCount() then
        if self.tyMenu.Combo.E1:Value() and not HasBuff(myHero,"JaxCounterStrike") then
            Control.CastSpell(HK_E)
            lastE = GetTickCount()
        end
    end

    if target and Ready(_E) and lastE + 300 < GetTickCount() then
        if self.tyMenu.Combo.E2:Value() and myHero.pos:DistanceTo(target.pos) > AArange and  HasBuff(myHero,"JaxCounterStrike") then
            Control.CastSpell(HK_E)
            lastE = GetTickCount()
        end
    end

end

function Jax:Jungle()
    local target = objectManager:GetMonsters(self.Q.Range)
    if target[1] and Ready(_Q) and lastQ + 300 < GetTickCount() then
        if self.tyMenu.Jungle.Q:Value() and orbwalker:CanMove() then
            Control.CastSpell(HK_Q,target[1].pos)
            lastQ = GetTickCount()
        end
    end
end

function Jax:Draw()

    if myHero.dead then return end

    if self.tyMenu.Drawing.Q:Value() and  Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Jax:Flee()
    if Ready(_Q) and lastQ + 500 < GetTickCount()  and self.tyMenu.Flee.Q:Value() then
        local i, slot = self:GetItemSlot(3340) -- wd
        if myHero:GetSpellData(slot).currentCd == 0 and Game.CanUseSpell(slot) == 0 and i then
            local HKItem = ({ HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4, HK_ITEM_5, HK_ITEM_6, HK_ITEM_7})[i]
            local wdPos = myHero.pos:Extended(mousePos, 620)
            Control.CastSpell(HKItem, wdPos)

            DelayAction(function()
                Control.CastSpell(HK_Q, wdPos)
            end, 0.15)

            print('use wdQ')
            lastQ = GetTickCount()
            return
        else
            if self.tyMenu.Flee.Pink:Value() then
                local i, slot = self:GetItemSlot(2055) -- Pink wd
                if myHero:GetSpellData(slot).currentCd == 0 and i then
                    local HKItem =
                        ({
                            HK_ITEM_1, HK_ITEM_2, HK_ITEM_3,
                            HK_ITEM_4, HK_ITEM_5, HK_ITEM_6,
                            HK_ITEM_7
                        })[i]
                    local wdPos =
                        myHero.pos:Extended(mousePos, 620)
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

function Jax:GetItemSlot(id)
    for i = 1, #self.ItemSlots do
        local slot = self.ItemSlots[i]
        local item = myHero:GetItemData(slot)
        if item and item.itemID > 0 then
            if item.itemID == id then return i, slot end
        end
    end

    return nil
end

Jax()
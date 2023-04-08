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

class "Ryze"


function Ryze:__init()
    self.Q = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 1000, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}}
    self.W = {Range = 615}
    self.E = {Range = 615}

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

function Ryze:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Ryze", name = "14 Ryze"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W] ", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Setting", name = "Setting"})
    self.tyMenu.Setting:MenuElement({id = "AAlevel", name = "Disable AA >= Level If Q/W/E ready", value = 6, min = 1, max = 18, step = 1})
    self.tyMenu.Setting:MenuElement({id = "AAQ", name = "Disable AA if Q ready", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})

end

function Ryze:Draw()
    if myHero.dead then
        return
    end

    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end


    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Ryze:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    orbwalker:SetAttack(true)

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        -- self:Harass()
    end

end

function Ryze:Combo()
    self:DisableAAcheck()

    target = self:GetTarget(Enemys, self.Q.Range)

    if target and IsValid(target) and self.tyMenu.Combo.UseQ:Value() then
        self:CastQ(target)
    end

    target = self:GetTarget(Enemys, self.W.Range)
    if target and IsValid(target) and self.tyMenu.Combo.UseW:Value() then
        if not Ready(_Q)  and Ready(_W) and lastW +260 < GetTickCount() and myHero.mana >= (self:GetSpellMana("Q") + self:GetSpellMana("W"))  then
            local casted = Control.CastSpell(HK_W, target)
            if casted then
                lastW = GetTickCount()
                -- print("W "..GetTickCount())
            end
        end
    end


    target = self:GetTarget(Enemys, self.E.Range)
    if target and IsValid(target) and self.tyMenu.Combo.UseE:Value() then
        if not Ready(_Q)  and Ready(_E) and lastE +260 < GetTickCount() and myHero.mana >= (self:GetSpellMana("Q") + self:GetSpellMana("E"))  then
            local casted = Control.CastSpell(HK_E, target)
            if casted then
                lastE = GetTickCount()
                -- print("E "..GetTickCount())
            end
        end
    end


end

function Ryze:CastQ(target)
    if Ready(_Q) and lastQ +260 < GetTickCount() then
        local Pred = GGPrediction:SpellPrediction(self.Q)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
        if Pred.Hitchance or Pred.HitChance >= _G.HITCHANCE_NORMAL  or Pred:CanHit(2 or GGPrediction.HITCHANCE_NORMAL)         then
            if HasBuff("RyzeW",target) then
                local casted = Control.CastSpell(HK_Q, target)
                if casted then
                    lastQ = GetTickCount()
                    -- print("Q targeted "..GetTickCount())
                end
            else
                local casted = Control.CastSpell(HK_Q, Pred.CastPosition)
                if casted then
                    lastQ = GetTickCount()
                    -- print("Q "..GetTickCount())
                end
            end

        end
    end
end

function Ryze:DisableAAcheck()
    if myHero.levelData.lvl >= self.tyMenu.Setting.AAlevel:Value()  then
        if Ready(_Q) or Ready(_W) or Ready(_E) then
            orbwalker:SetAttack(false)
        end
    end

    if self.tyMenu.Setting.AAQ:Value() and Ready(_Q) then
        orbwalker:SetAttack(false)
    end
end

function Ryze:GetSpellMana(spell)
    if spell == "Q" then
        return 40
    end
    if spell == "W" then
        return ({40,55,70,85,100})[myHero:GetSpellData(1).level]
    end
    if spell == "E" then
        return ({40,55,70,85,100})[myHero:GetSpellData(2).level]
    end

end

function Ryze:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

Ryze()
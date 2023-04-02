
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
local lastIG = 0
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


class "Khazix"

function Khazix:__init()

    self.Q = {Range = 325}
    self.W = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1000, Speed = 1650, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}}
    self.E = {Type = _G.SPELLTYPE_CIRCLE, Delay = 0, Radius = 120, Range = 700, Speed = 1000, Collision = false}

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






function Khazix:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Khazix", name = "Khazix"})

    --combo

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
    self.tyMenu.Combo:MenuElement({id = "range", name = "Max Cast W In range", value = 1000, min = 1, max = 1000, step = 1})
    self.tyMenu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})

    --jungle
    self.tyMenu:MenuElement({type = MENU, id = "Jungle", name = "Jungle"})
    self.tyMenu.Jungle:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Jungle:MenuElement({id = "UseW", name = "[W]", value = true})



    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    --Draw
    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})


end


function Khazix:Draw()
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



function Khazix:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    self:UpdateSpell()

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[3] then --jungle
        self:Jungle()
    end

end

function Khazix:UpdateSpell()


    if myHero:GetSpellData(0).name == "KhazixQLong" then
        self.Q.Range = 375
    end

    if myHero:GetSpellData(1).name == "KhazixWLong" then
        self.W.Type = _G.SPELLTYPE_CONE
    end

    if myHero:GetSpellData(2).name == "KhazixELong" then
        self.E.Range = 900
    end
end

function Khazix:Combo()

    if self.tyMenu.Combo.UseQ:Value() then
        local target = self:GetHeroTarget(self.Q.Range)
        if target ~= nil then
            self:CastQ(target)
        end
    end

    if self.tyMenu.Combo.UseW:Value() then
        local target = self:GetHeroTarget(self.tyMenu.Combo.range:Value())
        if target ~= nil then
            self:CastW(target)
        end
    end

    if self.tyMenu.Combo.UseE:Value()  then
        local target = self:GetHeroTarget(self.E.Range)
        if target ~= nil then
            self:CastE(target)
        end
    end


end

function Khazix:Jungle()
    local target = orbwalker:GetTarget()
    if target ~= nil then
        if self.tyMenu.Jungle.UseQ:Value() and Ready(_Q) then
            self:CastQ(target)
            return
        end

        if self.tyMenu.Jungle.UseW:Value() and Ready(_W) and orbwalker:CanMove() then
            Control.CastSpell(HK_W, target)
        end
    end
end


function Khazix:GetHeroTarget(range)
    local tg = TargetSelector:GetTarget(range)

    return tg
end

function Khazix:CastQ(target)
    if not Ready(_Q) or lastQ + 350 >GetTickCount() then return end

    if myHero.pos:DistanceTo(target.pos) <= self.Q.Range and orbwalker:CanMove() then
        Control.CastSpell(HK_Q, target)
        lastQ = GetTickCount()
        print("cast Q")
    end
end


function Khazix:CastW(target)
    if not Ready(_W) or lastW + 350 > GetTickCount() then return end

    local Pred = GetGamsteronPrediction(target, self.W, myHero)
    if Pred.Hitchance >= _G.HITCHANCE_HIGH and orbwalker:CanMove() then
            Control.CastSpell(HK_W, Pred.CastPosition)
            lastW = GetTickCount()
            print("cast W "..GetTickCount())
    end


end

function Khazix:CastE(target)
    if not Ready(_E) or lastE + 350 >GetTickCount() then return end

    local Pred = GetGamsteronPrediction(target, self.E, myHero)
    if Pred.Hitchance >= _G.HITCHANCE_HIGH and orbwalker:CanMove() then
        Control.CastSpell(HK_E, Pred.CastPosition)
        lastE = GetTickCount()
        print("cast E")

    end


end

Khazix()
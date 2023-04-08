require 'GGPrediction'


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


class "Ashe"

function Ashe:__init()
    self.W = {Hitchance = _G.HITCHANCE_NORMAL,Type = _G.SPELLTYPE_CONE, Delay = 0.25, Radius = 20, Range = 1200, Speed = 1500, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}}
    self.R = {Hitchance = _G.HITCHANCE_HIGH,Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 130, Range = math.huge, Speed = 1600, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_ENEMYHERO, _G.COLLISION_YASUOWALL}}

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

function Ashe:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Ashe", name = "14 Ashe"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({id = "Q", name = "[Q]", value = true})
        self.tyMenu.Combo:MenuElement({id = "W", name = "[W]", value = true})
        self.tyMenu.Combo:MenuElement({id = 'R', name = 'R Key', key = string.byte('T')})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({id = "W", name = "[W]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Setting", name = "Setting"})
        self.tyMenu.Setting:MenuElement({id = "Rrange", name = "Max R range", value = 2000, min = 1, max = 5000, step = 1})
        self.tyMenu.Setting:MenuElement({id = "Wrange", name = "Max W range", value = 1200, min = 1, max = 1200, step = 1, callback = function(value)
            self.W.Range = value
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

    self.tyMenu:MenuElement({type = MENU, id = "Anti", name = "Anti Gap"})
        self.tyMenu.Anti:MenuElement({id = "AntiR", name = "[R] Anti Gap R", value = true})
        OnEnemyHeroLoad(function(hero) self.tyMenu.Anti:MenuElement({id = hero.charName, name = hero.charName, value = false}) end)

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 80, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 80, min = 1, max = 500, step = 1})


    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Ashe:OnPreAttack()
    if orbwalker.Modes[0] and self.tyMenu.Combo.Q:Value() then
        if Ready(_Q) and lastQ + 250 < GetTickCount() then
            Control.CastSpell(HK_Q)
            lastQ = GetTickCount()
        end
    end
end

function Ashe:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

    self:AntiGap()
end


function Ashe:Combo()
    local target = TargetSelector:GetTarget(self.W.Range)
    if target and self.tyMenu.Combo.W:Value() then
        self:CastW(target)
    end

    local target = TargetSelector:GetTarget(self.tyMenu.Setting.Rrange:Value())
    if target and self.tyMenu.Combo.R:Value() then
        self:CastR(target)
    end

end

function Ashe:Harass()
    local target = TargetSelector:GetTarget(self.W.Range)
    if target and self.tyMenu.Harass.W:Value() then
        self:CastW(target)
    end
end

function Ashe:AntiGap()
    if self.tyMenu.Anti.AntiR:Value() and Ready(_R) and lastR + 500 < GetTickCount() then
        for i = 1, #Enemys do
            local enemy = Enemys[i]
            if self.tyMenu.Anti[enemy.charName] and self.tyMenu.Anti[enemy.charName]:Value() then
                if IsValid(enemy) and GetDistanceSquared(myHero.pos, enemy.pos) < self.tyMenu.Setting.Rrange:Value() ^2 then
                    local path = enemy.pathing
                    if path.isDashing and path.hasMovePath and path.dashSpeed > 0
                    and IsDashToMe(enemy)
                    then
                    local Pred = GGPrediction:SpellPrediction(self.RData)
                    Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.RData, myHero)
                        if Pred.Hitchance or Pred.HitChance >= self.R.Hitchance or Pred:CanHit(self.R.Hitchance or GGPrediction.HITCHANCE_HIGH) then
                            Control.CastSpell(HK_R,Pred.CastPosition)
                            lastR = GetTickCount()
                        end
                    end
                end
            end
        end
    end
end

function Ashe:CastR(target)
    if IsValid(target) and Ready(_R) and lastR + 500 < GetTickCount()  then
        local Pred = GGPrediction:SpellPrediction(self.RData)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.RData, myHero)
        if Pred.Hitchance or Pred.HitChance >= self.R.Hitchance or Pred:CanHit(self.R.Hitchance or GGPrediction.HITCHANCE_HIGH) then
            Control.CastSpell(HK_R,Pred.CastPosition)
            lastR = GetTickCount()
        end
    end
end

function Ashe:CastW(target)
    if IsValid(target) and Ready(_W) and lastW + 500 < GetTickCount()
    and orbwalker:CanMove() and GetDistanceSquared(myHero.pos,target.pos) < self.tyMenu.Setting.Wrange:Value()^2 then
        local Pred = GGPrediction:SpellPrediction(self.W)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.W, myHero)
        if Pred.Hitchance or Pred.HitChance  >= self.W.Hitchance or Pred:CanHit(self.W.Hitchance or GGPrediction.HITCHANCE_HIGH) then
            Control.CastSpell(HK_W,Pred.CastPosition)
            lastW = GetTickCount()
        end
    end

end

function Ashe:Draw()

    if myHero.dead then
        return
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.tyMenu.Setting.Rrange:Value() ,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

Ashe()
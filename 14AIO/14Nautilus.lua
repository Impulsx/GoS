require 'MapPositionGOS'
require 'GGPrediction'
require "2DGeometry"

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

local lineQ

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

class "Nautilus"

function Nautilus:__init()
    self.QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 90, Range = 1000, Speed = 2000, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}}

    self:LoadMenu()

    OnAllyHeroLoad(function(hero)
        TableInsert(Allys, hero);
    end)

    OnEnemyHeroLoad(function(hero)
        TableInsert(Enemys, hero);
    end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
    orbwalker:OnPostAttackTick(function(...) self:OnPostAttack(...) end)

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






function Nautilus:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Nautilus", name = "Nautilus"})

    --combo

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
        OnEnemyHeroLoad(function(hero) self.tyMenu.Combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
        self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
        self.tyMenu.Combo:MenuElement({id = "range", name = "Max Cast Q In range", value = 1000, min = 1, max = 1000, step = 1})
        self.tyMenu.Combo:MenuElement({id = "minRange", name = "Min Cast Q In range", value = 0, min = 0, max = 1000, step = 1})

        self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W] AA reset", value = true})
        self.tyMenu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})

    --Harass
    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
        OnEnemyHeroLoad(function(hero) self.tyMenu.Harass.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
        self.tyMenu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
        self.tyMenu.Harass:MenuElement({id = "range", name = "Max Cast Q In range", value = 1000, min = 1, max = 1000, step = 1})

    --Auto
    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
        self.tyMenu.Auto:MenuElement({id = "AutoIG", name = "Auto Ingite KS", value = true})
        self.tyMenu.Auto:MenuElement({id = "combo", name = "Only Use In Combo", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    --Draw
    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "Qdebug", name = "Draw [Q] debug", value = false})


end

function Nautilus:Draw()
    if myHero.dead then return end

    if self.tyMenu.Drawing.Qdebug:Value() and lineQ ~= nil then
        lineQ:__draw(1,Draw.Color(80 ,0xFF,0xFF,0xFF) )
    end

    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 1000,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

end


function Nautilus:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    self:Auto()

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

end

function Nautilus:CastQ(target)
    if Ready(_Q) and lastQ +350 < GetTickCount() and orbwalker:CanMove() then
        local Pred = GGPrediction:SpellPrediction(self.QData)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.QData, myHero)

        if (Pred.Hitchance or Pred.HitChance >= _G.HITCHANCE_HIGH)  or Pred:CanHit(3 or GGPrediction.HITCHANCE_HIGH)         then
            lineQ = self:CreateQPoly(Pred.CastPosition)
            for i, lineSegment in ipairs(lineQ:__getLineSegments()) do
                if MapPosition:intersectsWall(lineSegment) then
                    return
                end
            end
            Control.CastSpell(HK_Q, Pred.CastPosition)
            print("cast Q")
            lastQ = GetTickCount()
        end
    end
end

function Nautilus:OnPostAttack()
    if orbwalker.Modes[0] then
        if self.tyMenu.Combo.UseW:Value() and Ready(_W) and lastW + 350 < GetTickCount() then
            Control.CastSpell(HK_W)
            lastW = GetTickCount()
            --print('cast W')
        end
    end
end

function Nautilus:Combo()
    local targetList = {}
    local target

    for i = 1, #Enemys do
        local enemy = Enemys[i]
        local heroName = enemy.charName
        if self.tyMenu.Combo.useon[heroName] and self.tyMenu.Combo.useon[heroName]:Value() then
            targetList[#targetList + 1] = enemy
        end
    end

    target = self:GetTarget(targetList, self.QData.Range)

    if target and IsValid(target) and self.tyMenu.Combo.UseQ:Value()
    and GetDistanceSquared(myHero.pos, target.pos) <= self.tyMenu.Combo.range:Value()^2
    and GetDistanceSquared(myHero.pos, target.pos) > self.tyMenu.Combo.minRange:Value()^2
    then
        self:CastQ(target)
    end

    target = self:GetTarget(Enemys, 325)

    if target and IsValid(target) and self.tyMenu.Combo.UseE:Value() and Ready(_E) and lastE + 550 < GetTickCount() and orbwalker:CanMove() then
        Control.CastSpell(HK_E)
        lastE = GetTickCount()
        --print("cast E")
        return
    end

end

function Nautilus:Harass()
    local targetList = {}
    local target

    for i = 1, #Enemys do
        local enemy = Enemys[i]
        local heroName = enemy.charName
        if self.tyMenu.Harass.useon[heroName] and self.tyMenu.Harass.useon[heroName]:Value() then
            targetList[#targetList + 1] = enemy
        end
    end

    target = self:GetTarget(targetList, self.QData.Range)


    if target and IsValid(target) and self.tyMenu.Harass.UseQ:Value() and GetDistanceSquared(myHero.pos, target.pos) <= self.tyMenu.Harass.range:Value()^2 then
        self:CastQ(target)
    end

end


function Nautilus:Auto()
    if self.tyMenu.Auto.combo:Value() and not orbwalker.Modes[0] then return end

    if myHero:GetSpellData(SUMMONER_1).name ~= "SummonerDot" and myHero:GetSpellData(SUMMONER_2).name ~= "SummonerDot" then return end
    if lastIG + 250 > GetTickCount() then return end
    local IGdamage = 50 + 20 * myHero.levelData.lvl
    for enemyk , enemy in pairs(Enemys) do
        if IsValid(enemy) and enemy.pos:DistanceTo(myHero.pos) < 600 then
            if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and myHero:GetSpellData(SUMMONER_1).currentCd == 0 then
                if IGdamage >= enemy.health then
                    Control.CastSpell(HK_SUMMONER_1, enemy.pos)
                    lastIG = GetTickCount()
                    --print('cast IG')
                    return
                end
            end



            if myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and myHero:GetSpellData(SUMMONER_2).currentCd == 0 then
                if IGdamage >= enemy.health then
                    Control.CastSpell(HK_SUMMONER_2, enemy.pos)
                    lastIG = GetTickCount()
                    return
                end
            end
        end
    end

end

function Nautilus:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

function Nautilus:CreateQPoly(position)
    local startPos = myHero.pos
    local endPos = position
    local width = 10
    local c1 = startPos+Vector(Vector(endPos)-startPos):Perpendicular():Normalized()*width
    local c2 = startPos+Vector(Vector(endPos)-startPos):Perpendicular2():Normalized()*width
    local c3 = endPos+Vector(Vector(startPos)-endPos):Perpendicular():Normalized()*width
    local c4 = endPos+Vector(Vector(startPos)-endPos):Perpendicular2():Normalized()*width

    local poly = Polygon(c1,c2,c3,c4)

    return poly
end
Nautilus()
require 'GamsteronPrediction'

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


class "Amumu"

function Amumu:__init()
    self.QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 1100, Speed = 2000, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}}
    
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






function Amumu:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Amumu", name = "14 Amumu"})
    
    --combo
    
    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.Combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "range", name = "Max Cast Q In range", value = 1100, min = 1, max = 1000, step = 1})
    self.tyMenu.Combo:MenuElement({id = "minRange", name = "Min Cast Q In range", value = 0, min = 0, max = 1000, step = 1})
    self.tyMenu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
    self.tyMenu.Combo:MenuElement({id = "Count", name = "When Can Hit X Enemies ", value = 2, min = 1, max = 5, step = 1})

    --Harass
    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.Harass.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    self.tyMenu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
    self.tyMenu.Harass:MenuElement({id = "range", name = "Max Cast Q In range", value = 1000, min = 1, max = 1000, step = 1})

    --wave clean
    self.tyMenu:MenuElement({type = MENU, id = "WaveClean", name = "Jungle Clean"})
    self.tyMenu.WaveClean:MenuElement({id = "UseE", name = "E", value = true})


    --Auto
    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
    self.tyMenu.Auto:MenuElement({id = "UseR", name = "[R]", value = true})
    self.tyMenu.Auto:MenuElement({id = "Count", name = "When Can Hit X Enemies ", value = 3, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    --Draw
    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})


end

function Amumu:Draw()
    if myHero.dead then
        return
    end

    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 1100,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, 350,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, 550,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end



function Amumu:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    self:AutoR()

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    elseif orbwalker.Modes[2] then --harass
        self:WaveClean()
    end

end

function Amumu:CastQ(target)
    if Ready(_Q) and lastQ +350 < GetTickCount() and orbwalker:CanMove() then
        local Pred = GetGamsteronPrediction(target, self.QData, myHero)
        if Pred.Hitchance >= _G.HITCHANCE_HIGH then
            Control.CastSpell(HK_Q, Pred.CastPosition)
            print("cast Q")
            lastQ = GetTickCount()
        end
    end
end

function Amumu:Combo()
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

    target = self:GetTarget(Enemys, 350)

    if target and IsValid(target) and self.tyMenu.Combo.UseE:Value() and Ready(_E) and lastE + 350 < GetTickCount() and orbwalker:CanMove() then
        Control.CastSpell(HK_E)
        lastE = GetTickCount()
        print('cast E')
        return
    end

    if self.tyMenu.Combo.UseR:Value() then
        self:CastR(self.tyMenu.Combo.Count:Value())
    end
end

function Amumu:Harass()
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

function Amumu:WaveClean()
    if self.tyMenu.WaveClean.UseE:Value() and Ready(_E) and lastE + 350 < GetTickCount() and orbwalker:CanMove() then 
        local target = orbwalker:GetTarget()
        if target then
            Control.CastSpell(HK_E)
            print('jg E')
            lastE = GetTickCount()
        end
    end
end

function Amumu:CastR(number)
    if not Ready(_R) or lastR + 350 > GetTickCount() then return end
    local count = 0

    for i = 1, #Enemys do
        local hero = Enemys[i]
        local delayPos = hero:GetPrediction(hero.ms,0.25)
        if GetDistanceSquared(delayPos, myHero.pos) <= 550*550 then
            count = count + 1
        end
    end

    if count >= number then
        Control.CastSpell(HK_R)
        print('cast R')
        lastR = GetTickCount()
    end


end

function Amumu:AutoR()
    if self.tyMenu.Auto.UseR:Value() then
        self:CastR(self.tyMenu.Auto.Count:Value())
    end
end

function Amumu:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

Amumu()
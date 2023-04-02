require('GamsteronPrediction')

local myHero = myHero
local GameMissileCount = Game.MissileCount
local GameMissile = Game.Missile

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert

local orbwalker         = _G.SDK.Orbwalker
local TS                   = _G.SDK.TargetSelector
local OB                 = _G.SDK.ObjectManager

local CanR = true
local ballMissile = nil
local ballobject = nil
local ballPos = {pos = myHero.pos, ground = false, selfball = false, canW = true}
local lastRTick = 0
local lastQTick = 0
local lastEWTick = 0
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
    return  unit 
            and unit.valid 
            and unit.isTargetable 
            and unit.alive 
            and unit.visible 
            and unit.networkID 
            and unit.health > 0
            and not unit.dead
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

class "Orianna"

function Orianna:__init()

    self.QData = {
        Type = _G.SPELLTYPE_LINE, 
        Delay = 0, Radius = 130, 
        Range = 1250, Speed = 1400,
        Collision = true, 
        MaxCollision = 0, 
        CollisionTypes = {_G.COLLISION_YASUOWALL}
        

    }
    self.WData = {
        Radius = 225
    }
    self.EData = {
        Delay = 0,
        Radius = 130,
        Range = 1100,
        Speed = 1850
    }
    self.RData = {
        Delay = 0.75,
        Radius = 370
    }



    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
    Callback.Add("WndMsg", function(...) self:WndMsg(...) end)

    orbwalker:OnPreAttack(
        function(args)
            if args.Process then
                if lastAttack + TY.Human.AA:Value() > GetTickCount() then
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
                if (lastMove + TY.Human.Move:Value() > GetTickCount()) or (ExtLibEvade and ExtLibEvade.Evading == true) then
                    args.Process = false
                else
                    args.Process = true
                    lastMove = GetTickCount()
                end
            end
        end 
    )
end

function Orianna:LoadMenu()
    TY = MenuElement({type = MENU, id = "14", name = "14Orianna"})

    TY:MenuElement({type = MENU, id = "combo", name = "Combo"})
    TY.combo:MenuElement({id = "UseQ", name = "Q", value = true})
    TY.combo:MenuElement({id = "UseW", name = "W", value = false})
    TY.combo:MenuElement({id = "UseE", name = "E", value = true})
    TY.combo:MenuElement({id = "UseR", name = "R", value = true})
    TY.combo:MenuElement({id = "Rmax", name = "Only Use R if taret HP < X % ", value = 50, min = 0, max = 100, step = 1})
    TY.combo:MenuElement({id = "Rmin", name = "Only Use R if taret HP > X % ", value = 10, min = 0, max = 100, step = 1})
    TY.combo:MenuElement({name = "Use R on:", id = "useon", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) TY.combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)


    TY:MenuElement({type = MENU, id = "harass", name = "Harass"})
    TY.harass:MenuElement({id = "UseQ", name = "Q", value = true})

    TY:MenuElement({type = MENU, id = "AutoQ", name = "Auto Q"})
    TY.AutoQ:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) TY.AutoQ.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    TY.AutoQ:MenuElement({id = "UseQ", name = "Q", value = true})

    TY:MenuElement({type = MENU, id = "AutoR", name = "Auto R"})
    TY.AutoR:MenuElement({id = "Count", name = "When Can Hit X Enemies ", value = 3, min = 1, max = 5, step = 1})

    TY:MenuElement({type = MENU, id = "AutoW", name = "Auto W"})
    TY.AutoW:MenuElement({id = "Count", name = "When Can Hit X Enemies ", value = 2, min = 1, max = 5, step = 1})

    TY:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        TY.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        TY.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})


    TY:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    TY.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})

    TY.Drawing:MenuElement({type = MENU, id = "QColor", name = "Q Range Color"})
    TY.Drawing.QColor:MenuElement({id = "T", name = "Transparency ", value = 255, min = 0, max = 255, step = 1})
    TY.Drawing.QColor:MenuElement({id = "R", name = "Red ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.QColor:MenuElement({id = "G", name = "Grean ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.QColor:MenuElement({id = "B", name = "Blue ", value = 150, min = 0, max = 255, step = 1})

    TY.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})

    TY.Drawing:MenuElement({type = MENU, id = "EColor", name = "E Range Color"})
    TY.Drawing.EColor:MenuElement({id = "T", name = "Transparency ", value = 255, min = 0, max = 255, step = 1})
    TY.Drawing.EColor:MenuElement({id = "R", name = "Red ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.EColor:MenuElement({id = "G", name = "Grean ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.EColor:MenuElement({id = "B", name = "Blue ", value = 150, min = 0, max = 255, step = 1})


    TY.Drawing:MenuElement({id = "ball", name = "Draw Ball Pos", value = true})

    TY.Drawing:MenuElement({type = MENU, id = "BColor", name = "Ball Color"})
    TY.Drawing.BColor:MenuElement({id = "T", name = "Transparency ", value = 255, min = 0, max = 255, step = 1})
    TY.Drawing.BColor:MenuElement({id = "R", name = "Red ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.BColor:MenuElement({id = "G", name = "Grean ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.BColor:MenuElement({id = "B", name = "Blue ", value = 150, min = 0, max = 255, step = 1})


    TY.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = false})

    TY.Drawing:MenuElement({type = MENU, id = "WColor", name = "W Range Color"})
    TY.Drawing.WColor:MenuElement({id = "T", name = "Transparency ", value = 255, min = 0, max = 255, step = 1})
    TY.Drawing.WColor:MenuElement({id = "R", name = "Red ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.WColor:MenuElement({id = "G", name = "Grean ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.WColor:MenuElement({id = "B", name = "Blue ", value = 150, min = 0, max = 255, step = 1})

    TY.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})
    TY.Drawing:MenuElement({type = MENU, id = "RColor", name = "R Range Color"})
    TY.Drawing.RColor:MenuElement({id = "T", name = "Transparency ", value = 255, min = 0, max = 255, step = 1})
    TY.Drawing.RColor:MenuElement({id = "R", name = "Red ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.RColor:MenuElement({id = "G", name = "Grean ", value = 150, min = 0, max = 255, step = 1})
    TY.Drawing.RColor:MenuElement({id = "B", name = "Blue ", value = 150, min = 0, max = 255, step = 1})

end


function Orianna:Tick()

    if lastQTick + 50 < GetTickCount() then
        orbwalker:SetAttack(true)
        orbwalker:SetMovement(true)
    end

    self:LoadBallPos()

    if lastQTick+ 150 > GetTickCount() then return end
    if lastRTick + 800 > GetTickCount() then return end
    if lastEWTick +300 > GetTickCount() then return end

    ballPos.canW = true

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

    self:AutoQ()
    self:AutoR()
    self:AutoW()

end

function Orianna:Draw()

    if ballPos.pos then 
        if TY.Drawing.ball:Value() then
            Draw.Circle(ballPos.pos, 133, Draw.Color(TY.Drawing.BColor.T:Value() ,TY.Drawing.BColor.R:Value(),TY.Drawing.BColor.G:Value(),TY.Drawing.BColor.B:Value())) 
        end
        if TY.Drawing.W:Value() and Ready(_W) then
            Draw.Circle(ballPos.pos, self.WData.Radius , Draw.Color(TY.Drawing.WColor.T:Value() ,TY.Drawing.WColor.R:Value(),TY.Drawing.WColor.G:Value(),TY.Drawing.WColor.B:Value()))
        end
        if TY.Drawing.R:Value() and Ready(_R) then
            Draw.Circle(ballPos.pos, self.RData.Radius , Draw.Color(TY.Drawing.RColor.T:Value() ,TY.Drawing.RColor.R:Value(),TY.Drawing.RColor.G:Value(),TY.Drawing.RColor.B:Value()))
        end
    end
    if TY.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 825 ,Draw.Color(TY.Drawing.QColor.T:Value() ,TY.Drawing.QColor.R:Value(),TY.Drawing.QColor.G:Value(),TY.Drawing.QColor.B:Value()))
    end

    if TY.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.EData.Range , Draw.Color(TY.Drawing.EColor.T:Value() ,TY.Drawing.EColor.R:Value(),TY.Drawing.EColor.G:Value(),TY.Drawing.EColor.B:Value()))
    end
    --print(myHero.pos:DistanceTo(ballPos.pos))

end

function Orianna:Combo()
    local EnemyHeroes = OB:GetEnemyHeroes(self.QData.Range, false)

    local target = TS:GetTarget(EnemyHeroes)
    if target == nil then return end

    if IsValid(target) then
        if TY.combo.UseQ:Value() then
            self:CastQ(target)
        end

        if TY.combo.UseW:Value() and Ready(_W) and ballPos.pos:DistanceTo(target.pos) <= self.WData.Radius and ballPos.canW then
            print("cast W")
            lastEWTick = GetTickCount()
            Control.CastSpell(HK_W)
        end
        --GetCollision = function(source (Object), castPos (Vector), predPos (Vector), speed (integer), delay (float (seconds)), radius (integer), collisionTypes (table), skipID (integer))

        if TY.combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= self.EData.Range and myHero.pos:DistanceTo(ballPos.pos) > 10 then
            local isWall , collisionObjects , collisionCount   = GetCollision(ballPos.pos,  myHero.pos , myHero.pos, self.EData.speed, 0, 40, {_G.COLLISION_ENEMYHERO})

            if collisionCount >= 1 then
                lastEWTick = GetTickCount()
                Control.CastSpell(HK_E, myHero)
                print("cast E")
                CanR = false
                DelayAction(function()
                    CanR = true
                end, ballPos.pos:DistanceTo(myHero.pos)/1850 )

            end
        end

        if TY.combo.UseR:Value() and Ready(_R) and self:GetHP(target) <= TY.combo.Rmax:Value() and self:GetHP(target) >= TY.combo.Rmin:Value() then
            local delayPos = target:GetPrediction(target.ms,0.75)
            if delayPos:DistanceTo(ballPos.pos) <= 370 and CanR then
                lastRTick = GetTickCount()
                Control.CastSpell(HK_R)
                print("cast R")

            end
        end

    end

end

function Orianna:Harass()
    local EnemyHeroes = OB:GetEnemyHeroes(self.QData.Range, false)

    local target = TS:GetTarget(EnemyHeroes)
    if target == nil then return end

    if IsValid(target) then
        if TY.harass.UseQ:Value() then
            self:CastQ(target)
        end
    end
end


function Orianna:AutoQ()
    local EnemyHeroes = OB:GetEnemyHeroes(self.QData.Range, false)
    local targetList = {}

    for i = 1, #EnemyHeroes do
        local hero = EnemyHeroes[i]
        local heroName = hero.charName
        if TY.AutoQ.useon[heroName] and TY.AutoQ.useon[heroName]:Value() then
            targetList[#targetList + 1] = hero
        end
    end
    local target = TS:GetTarget(targetList)
    if target == nil then return end

    if IsValid(target) then
        if TY.AutoQ.UseQ:Value()  then
            self:CastQ(target)
        end
    end

end

function Orianna:AutoW()
    if Ready(_W) and ballPos.canW then
        local count = 0
        local EnemyHeroes = OB:GetEnemyHeroes()
        for i = 1, #EnemyHeroes do
            local hero = EnemyHeroes[i]
            if hero.pos:DistanceTo(ballPos.pos) <= self.WData.Radius then
                count = count + 1
            end
        end

        if count >= TY.AutoW.Count:Value() then
            lastEWTick = GetTickCount()
            Control.CastSpell(HK_W)
            --print("Auo W")

        end
    end
end

function Orianna:AutoR()
    if Ready(_R) and ballPos.canW then
        local count = 0
        local EnemyHeroes = OB:GetEnemyHeroes()
        for i = 1, #EnemyHeroes do
            local hero = EnemyHeroes[i]
            local delayPos = hero:GetPrediction(hero.ms,0.75)
            if delayPos:DistanceTo(ballPos.pos) <= 370 then
                count = count + 1
            end
        end

        if count >= TY.AutoR.Count:Value() and canR then
            lastRTick = GetTickCount()
            Control.CastSpell(HK_R)
            print("Auto R")

        end


    end
end

function Orianna:CastQ(target)
    if lastQTick + 100 > GetTickCount() then return end
    if Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= self.QData.Range then
        local Pred = GetGamsteronPrediction(target, self.QData, ballPos)
        if Pred.Hitchance >= _G.HITCHANCE_HIGH 
        and  myHero.pos:DistanceTo(Pred.CastPosition)<= 825
        then
            lastQTick = GetTickCount()
            orbwalker:SetAttack(false)
            orbwalker:SetMovement(false)
            local casted = Control.CastSpell(HK_Q, Pred.CastPosition)
            if casted then
                CanR = false
                DelayAction(function()
                    CanR = true
                end, ballPos.pos:DistanceTo(Pred.CastPosition)/1400 )
                ballPos.pos = Pred.CastPosition
                ballPos.canW = false
                print("cast Q")
                DelayAction(function()
                    self:LoadBallMissile()
                end, 0.1)
            end
        end
    end
end

function Orianna:LoadBallPos()

    if ballobject and  string.find(ballobject.name, "Orianna_Base_Q_G")  then
        local vetor  = Vector(ballobject.pos.x, ballobject.pos.y, ballobject.pos.z)
        -- local vetor = missile.pos
        ballPos.pos = vetor
        ballPos.ground = true
        ballPos.selfball = false
        ballPos.canW = false
    end

    if ballMissile and ballMissile.missileData.name == "OrianaIzuna" then
        local vetor  = Vector(ballMissile.missileData.endPos.x, ballMissile.missileData.endPos.y, ballMissile.missileData.endPos.z)
        -- local vetor = missile.pos
        ballPos.pos = vetor
        ballPos.ground = true
        ballPos.selfball = false
        ballPos.canW = false
    end

    local EnemyHeroes = OB:GetAllyHeroes()
    for i = 1, #EnemyHeroes do
        local hero = EnemyHeroes[i]
        for i=1,hero.buffCount do
            local buff = hero:GetBuff(i)
            -- if buff.startTime > 0 then
            -- print(buff.name.." "..buff.count.." "..buff.startTime)
            -- end
            if buff.name=="orianaghostself" or buff.name == "orianaghost" then
                if buff.count > 0 then
                    -- print("hand")
                    ballPos.pos = hero.pos
                    ballPos.ground = false
                    ballPos.selfball = false
                end
            end
        end
    end

    if ballPos.ground  and myHero.pos:DistanceTo(ballPos.pos) <= 100 then

        ballPos.selfball = true
        ballPos.ground = false
    end

    if ballPos.ground  and myHero.pos:DistanceTo(ballPos.pos) >= 1250 then
        ballPos.selfball = true
        ballPos.ground = false
    end

    if ballPos.selfball then
        ballPos.pos = myHero.pos
    end

end

function Orianna:LoadBallMissile()
    for i = 1, GameMissileCount() do
        local missile = GameMissile(i)
        if missile.missileData.name == "OrianaIzuna" then
            local vetor  = Vector(missile.missileData.endPos.x, missile.missileData.endPos.y, missile.missileData.endPos.z)
            -- local vetor = missile.pos
            ballPos.pos = vetor
            ballPos.ground = true
            ballPos.selfball = false
            ballPos.canW = false
        end
    end
end

function Orianna:LoadBallObject()
    -- for i = 1, GameMissileCount() do
    --     local missile = GameMissile(i)
    --     if missile.missileData.name == "OrianaIzuna" then
    --         ballMissile = missile
    --     end
    -- end
    for i = 1, Game.ObjectCount() do
        local obj = Game.Object(i)
        if string.find(obj.name, "Orianna_Base_Q_G") then
            ballobject = obj
        end
    end
end

function Orianna:WndMsg(msg, wParam)
    if msg == 256 and wParam == 81 then
        DelayAction(function()
            self:LoadBallMissile()
            self:LoadBallObject()
        end, 0.1)

    end
end

function Orianna:GetHP(target)
    return target.health/target.maxHealth * 100
end

Orianna()
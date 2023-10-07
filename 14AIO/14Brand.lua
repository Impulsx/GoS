local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector

local lastQ = 0
local lastW = 0
local lastE = 0
local lastEQ = 0
local lastMove = 0
local lastR = 0
local lastIG = 0
local lastAttack = 0

local Enemys =   {}
local Allys  =   {}

require 'GGPrediction'

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

class "Brand"

function Brand:__init()
    print("14Brand init")

    self.Q = {Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Speed = 1600 , range = 1050, radius = 60, Collision = true, MaxCollision = 0, CollisionTypes = {GGPrediction.COLLISION_MINION, GGPrediction.COLLISION_ENEMYHERO, GGPrediction.COLLISION_YASUOWALL}}
    self.W = {Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.9, Speed = math.huge , range = 900, radius = 200}
    self.E = {range = 625}
    self.R = {range = 750}

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

function Brand:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Brand", name = "14Brand"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "QE", name = "Try QE", value = true})
        self.tyMenu.combo:MenuElement({id = "minQE", name = "min target Range", value = 590, min = 0, max = 625, step = 1})
        self.tyMenu.combo:MenuElement({id = "W", name = "use W", value = true})
        self.tyMenu.combo:MenuElement({id = "EQ", name = "use EQ", value = true})
        self.tyMenu.combo:MenuElement({id = "R", name = "use R", value = true})
        self.tyMenu.combo:MenuElement({id = "minComboR", name = "Min R target", value = 2, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.tyMenu.harass:MenuElement({id = "W", name = "use W", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "auto", name = "Auto"})
        self.tyMenu.auto:MenuElement({id = "IG", name = "use ignite", value = true})
        self.tyMenu.auto:MenuElement({id = "R", name = "use R", value = true})
        self.tyMenu.auto:MenuElement({id = "minAutoR", name = "Min R target", value = 4, min = 1, max = 5, step = 1})
        self.tyMenu.auto:MenuElement({id = "Q", name = "auto Q to stun", value = true})
        self.tyMenu.auto:MenuElement({id = "maxRange", name = "Max Q Range", value = 875, min = 0, max = 875, step = 1})
        self.tyMenu.auto:MenuElement({id = "W", name = "auto W if Immobile", value = true})
        self.tyMenu.auto:MenuElement({id = "E", name = "auto E if Buff count 2", value = true})
        self.tyMenu.auto:MenuElement({type = MENU, id = "antiDash", name = "EQ Anti Dash Target"})
        OnEnemyHeroLoad(function(hero) self.tyMenu.auto.antiDash:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)


    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Brand:Draw()
    if myHero.dead then return  end

    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 1050,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, 900,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, 625,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, 750,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end


function Brand:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

    self:Auto()
    self:IG()

end

function Brand:Combo()
    local target = nil

    --QE
    target = self:GetTarget(900)

    if target and self.tyMenu.combo.QE:Value() and Ready(_Q) and Ready(_E) and lastQ + 350 < GetTickCount() and orbwalker:CanMove() then
        local Pred = GGPrediction:SpellPrediction(self.Q)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
        if Pred:CanHit(2 or GGPrediction.HITCHANCE_HIGH)
        and GetDistanceSquared(myHero.pos, Pred.CastPosition) >= self.tyMenu.combo.minQE:Value()^2
        and GetDistanceSquared(myHero.pos, Pred.CastPosition) < self.E.range^2
        then
            Control.CastSpell(HK_Q, Pred.CastPosition)
            lastQ = GetTickCount()
            -- print("cast QE Q "   ..GetTickCount())
            DelayAction(
                function()
                    Control.CastSpell(HK_E, target)
                    -- print("cast QE E")
                    lastE = GetTickCount()
                end, .25
            )
        end
    end

    target = self:GetTarget(625)
    if target and self.tyMenu.combo.EQ:Value() and Ready(_Q) and Ready(_E)
    and lastE + 350 < GetTickCount() then
        local Pred = GGPrediction:SpellPrediction(self.Q)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
        if Pred:CanHit(2 or GGPrediction.HITCHANCE_HIGH) then
            Control.CastSpell(HK_E, target)
            lastE = GetTickCount()
            lastEQ = GetTickCount()
        end
    end

    target = self:GetTarget(900)
    if target and self.tyMenu.combo.W:Value() then
        self:CastW(target)
    end


end

function Brand:Harass()
    local  target = self:GetTarget(900)
    if target and self.tyMenu.harass.W:Value() then
        self:CastW(target)
    end
end

function Brand:Auto()
    for i = 1, #Enemys do
        local hero = Enemys[i]
        if IsValid(hero) then
            local distanceSqr = GetDistanceSquared(myHero.pos, hero.pos)
            if Ready(_R) and lastR + 350 < GetTickCount() and distanceSqr < self.R.range^2 then
                local numAround = self:GetTargetInRange(480, hero)
                if self.tyMenu.auto.R:Value() and numAround >= self.tyMenu.auto.minAutoR:Value() then
                    Control.CastSpell(HK_R, hero)
                    lastR = GetTickCount()
                    -- print("auto R")
                    return
                end

                if self.tyMenu.combo.R:Value() and  orbwalker.Modes[0]
                and numAround >= self.tyMenu.combo.minComboR:Value() then
                    Control.CastSpell(HK_R, hero)
                    lastR = GetTickCount()
                    -- print("combo R")
                    return
                end
            end

            if self.tyMenu.auto.Q:Value() and distanceSqr < self.tyMenu.auto.maxRange:Value() ^2
            and Ready(_Q) and lastQ + 550 < GetTickCount() then
                local hasBuff, duration = self:HasPassiveBuff(hero)
                local time = 0.25 + distanceSqr/(1600*1600)
                if hasBuff and duration >= time then
                    local Pred = GGPrediction:SpellPrediction(self.Q)
                    Pred:GetPrediction(hero, myHero) --GetGamsteronPrediction(target, self.Q, myHero)
                    if Pred:CanHit(2 or GGPrediction.HITCHANCE_HIGH) then
                        Control.CastSpell(HK_Q, Pred.CastPosition)
                        lastQ = GetTickCount()
                        -- print("auto Q")
                        return
                    end
                end
            end

            if self.tyMenu.auto.W:Value() and Ready(_W) and lastW + 700 < GetTickCount() and distanceSqr < 900*900 then
                local Pred = GGPrediction:SpellPrediction(self.W)
                Pred:GetPrediction(hero, myHero) --GetGamsteronPrediction(target, self.W, myHero)
                if Pred:CanHit(4 or GGPrediction.HITCHANCE_IMMOBILE) then
                    Control.CastSpell(HK_W, Pred.CastPosition)
                    lastW = GetTickCount()
                    -- print("auto W")
                    return
                end
            end

            if self.tyMenu.auto.antiDash[hero.charName] and self.tyMenu.auto.antiDash[hero.charName]:Value()
            and hero.pathing.isDashing and hero.pathing.dashSpeed>0 and Ready(_Q) and Ready(_E) and lastE+350 < GetTickCount()  and distanceSqr < 625*625 then
                Control.CastSpell(HK_E, hero)
                lastE = GetTickCount()
                -- print("dash E")
                return
            end

            if self.tyMenu.auto.E:Value() and Ready(_E) and lastE +350 < GetTickCount() and distanceSqr < 625*625 then
                local hasBuff, duration, count = self:HasPassiveBuff(hero)
                if hasBuff and count == 2 then
                    Control.CastSpell(HK_E, hero)
                    lastE = GetTickCount()
                    -- print("auto E")
                    return
                end

            end
        end
    end
end

function Brand:IG()
    if self.tyMenu.auto.IG:Value() and not orbwalker.Modes[0] then return end

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

function Brand:CastW(target)
    if Ready(_W) and lastW + 600 < GetTickCount() and lastEQ + 550 < GetTickCount() then
        local Pred = GGPrediction:SpellPrediction(self.W)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.W, myHero)
        if Pred:CanHit(2 or GGPrediction.HITCHANCE_HIGH) then
            Control.CastSpell(HK_W, Pred.CastPosition)
            lastW = GetTickCount()
        end
    end
end

function Brand:GetTarget(range, list)
    local targetList = {}
    local inputList = list or Enemys
    for i = 1, #inputList do
        local hero = inputList[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range and IsValid(hero) then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

function Brand:GetTargetInRange(range, target)
    local counter = 0
    for i = 1, #Enemys do
        local hero = Enemys[i]
        if IsValid(hero) then
            if GetDistanceSquared(target.pos, hero.pos) < range * range then
                counter = counter + 1
            end
        end
    end
    return counter
end

function Brand:HasPassiveBuff(unit)
    local name = "BrandAblaze"
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name then
            return true, buff.duration, buff.count
        end
    end
    return false
end


Brand()
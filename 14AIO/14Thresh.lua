
require 'GamsteronPrediction'

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector
local ObjectManager     = _G.SDK.ObjectManager
local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert

local myHero = myHero
local LocalGameTimer = Game.Timer

local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0
local lastIG = 0
local lastMove = 0
local lastAttack = 0

local Enemys =   {}
local Allys  =   {}

local function hasBuff(name, unit)
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



class "Thresh"

function Thresh:__init()
    self.QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 70, Range = 1000, Speed = 1900, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL} }
    --Q range 1100 cant hit
    self.EData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 150, Range = 450, Speed = 1100, Collision = false}
    self:LoadMenu()

    OnAllyHeroLoad(function(hero) TableInsert(Allys, hero); end)
    OnEnemyHeroLoad(function(hero) TableInsert(Enemys, hero); end)


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

function Thresh:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Thresh", name = "14Thresh"})

    self.tyMenu:MenuElement({type = MENU, id = "Q", name = "[Q]"})
    self.tyMenu.Q:MenuElement({name =" " , drop = {"Combo Settings"}})
    self.tyMenu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
    self.tyMenu.Q:MenuElement({id = "ComboQ2", name = "Combo Q2", value = false})
    self.tyMenu.Q:MenuElement({name = "Combo list:", id = "ComboOn", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.Q.ComboOn:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    self.tyMenu.Q:MenuElement({name =" " , drop = {"Harrass Settings"}})
    self.tyMenu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
    self.tyMenu.Q:MenuElement({id = "HarassQ2", name = "Harass Q2", value = false})
    self.tyMenu.Q:MenuElement({name = "Harass list:", id = "HarassOn", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.Q.HarassOn:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
    --self.tyMenu.Q:MenuElement({name =" " , drop = {"Misc Settings"}})
    --self.tyMenu.Q:MenuElement({id = "Auto", name = "Auto Use on Immobile", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "E", name = "[E]"})
    self.tyMenu.E:MenuElement({name =" " , drop = {"Combo Settings"}})
    self.tyMenu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
    self.tyMenu.E:MenuElement({name =" " , drop = {"Harrass Settings"}})
    self.tyMenu.E:MenuElement({id = "Harass", name = "Use on Harass", value = true})
    self.tyMenu.E:MenuElement({name =" " , drop = {"Misc Settings"}})
    self.tyMenu.E:MenuElement({id = "Auto", name = "Disable autoAttack if E ready", value = true})
    self.tyMenu.E:MenuElement({id = "AntiE", name = "Anti Dash", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.E.AntiE:MenuElement({id = hero.charName, name = hero.charName, value = false}) end)
    --self.tyMenu.E:MenuElement({id = "Grass", name = "Anti Dash from Grass(beta)", value = false})

    self.tyMenu.E:MenuElement({id = "AutoE", name = "Auto Pull E on ", type = _G.MENU})
    OnEnemyHeroLoad(function(hero) self.tyMenu.E.AutoE:MenuElement({id = hero.charName, name = hero.charName, value = false}) end)

    self.tyMenu:MenuElement({type = MENU, id = "R", name = "[R]"})
    self.tyMenu.R:MenuElement({name =" " , drop = {"Combo Settings"}})
    self.tyMenu.R:MenuElement({id = "Combo", name = "Use on Combo", value = true})
    self.tyMenu.R:MenuElement({id = "Count", name = "When X Enemies Around", value = 2, min = 1, max = 5, step = 1})
    self.tyMenu.R:MenuElement({name = " ", drop = {"Misc"}})
    self.tyMenu.R:MenuElement({id = "Auto", name = "Auto Use When X Enemies Around", value = 3, min = 1, max = 5, step = 1})


    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Ignite"})
    self.tyMenu.Auto:MenuElement({id = "AutoIG", name = "Auto Ingite KS", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})


end

function Thresh:Draw()
    if myHero.dead then
        return
    end

    self:AntiE()

    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 1000,Draw.Color(255,255, 162, 000))
    end
    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, 465,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    --[[
    local target = TS:GetTarget(1000)
    if target == nil then return end
    local flayTowards = self:GetPosE(target.pos)      
    Draw.Circle(flayTowards, 20,Draw.Color(80 ,0xFF,0xFF,0xFF))

    pos = target:GetPrediction(2265, 0.7)
    Draw.Circle(pos, 20,Draw.Color(80 ,0xFF,0xFF,0xFF))
    Draw.Circle(flayTowards, 20,Draw.Color(80 ,0xFF,0xFF,0xFF))
    --]]
    

end

local NextTick = GetTickCount()
function Thresh:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end
    
    self:Auto()

    self:AntiE()

    if Ready(_E) and self.tyMenu.E.Auto:Value() then
        orbwalker:SetAttack(false)
    else
        orbwalker:SetAttack(true)
    end

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

    self:AutoE()

end

function Thresh:Combo()
    local targetList = {}
    local target

    for i = 1, #Enemys do
        local enemy = Enemys[i]
        local heroName = enemy.charName
        if self.tyMenu.Q.ComboOn[heroName] and self.tyMenu.Q.ComboOn[heroName]:Value() then
            targetList[#targetList + 1] = enemy
        end
    end

    target = self:GetTarget(targetList, self.QData.Range)


    if target and IsValid(target) then
        if self.tyMenu.Q.Combo:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1000 and lastQ + 1000 < GetTickCount() and not hasBuff("ThreshQ",target) then
            local Pred = GetGamsteronPrediction(target, self.QData, myHero)
            if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                Control.CastSpell(HK_Q, Pred.CastPosition)
                lastQ = GetTickCount()
            end
        end

        if self.tyMenu.Q.Combo:Value() and self.tyMenu.Q.ComboQ2:Value() and Ready(_Q) and lastQ + 1000 < GetTickCount() and hasBuff("ThreshQ",target) then
            Control.CastSpell(HK_Q)
            lastQ = GetTickCount()
        end

        if hasBuff("ThreshQ",target) then
            orbwalker:SetAttack(false)
        else
            orbwalker:SetAttack(true)
        end
    end


    target = self:GetTarget(targetList, self.EData.Range)
    if target and IsValid(target) and self.tyMenu.E.Combo:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 450 and lastE + 1000 < GetTickCount() then
        pre = self:GetPosE(target.pos)
        Control.CastSpell(HK_E, pre)
        lastE = GetTickCount()
    end

    local nearby = #ObjectManager:GetEnemyHeroes(420, false)

    if Ready(_R) and self.tyMenu.R.Combo:Value() and nearby >= self.tyMenu.R.Count:Value() and lastR + 1000 < GetTickCount() then
        Control.CastSpell(HK_R)
        lastR = GetTickCount()
    end

end

function Thresh:Harass()
    local targetList = {}
    local target

    for i = 1, #Enemys do
        local enemy = Enemys[i]
        local heroName = enemy.charName
        if self.tyMenu.Q.HarassOn[heroName] and self.tyMenu.Q.HarassOn[heroName]:Value() then
            targetList[#targetList + 1] = enemy
        end
    end

    target = self:GetTarget(targetList, self.QData.Range)


    if target and IsValid(target) then
        if self.tyMenu.Q.Harass:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1000 and lastQ + 1000 < GetTickCount() and not hasBuff("ThreshQ",target) then
            local Pred = GetGamsteronPrediction(target, self.QData, myHero)
            if Pred.Hitchance >= _G.HITCHANCE_HIGH then
                Control.CastSpell(HK_Q, Pred.CastPosition)
                lastQ = GetTickCount()

            end


        end

        if self.tyMenu.Q.Harass:Value() and self.tyMenu.Q.HarassQ2:Value() and Ready(_Q) and lastQ + 1000 < GetTickCount()   then
            Control.CastSpell(HK_Q)
            lastQ = GetTickCount()
        end

        if hasBuff("ThreshQ",target) then
            orbwalker:SetAttack(false)
        else
            orbwalker:SetAttack(true)
        end
        
        if self.tyMenu.E.Harass:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 450 and lastE + 1000 < GetTickCount() then
            pre = self:GetPosE(target.pos)
            Control.CastSpell(HK_E, pre)
            lastE = GetTickCount()
        end

    end
end

function Thresh:Auto()
    local nearby = #ObjectManager:GetEnemyHeroes(420, false)
    if Ready(_R) and nearby >= self.tyMenu.R.Auto:Value() and lastR + 1000 < GetTickCount() then
        Control.CastSpell(HK_R)
        lastR = GetTickCount()
    end


    local IGdamage = 50 + 20 * myHero.levelData.lvl
    local EnemyHeroes = ObjectManager:GetEnemyHeroes(600,false)
    if next(EnemyHeroes) == nil then return end
    for i = 1, #EnemyHeroes do
        local target = EnemyHeroes[i]

        if self.tyMenu.Auto.AutoIG:Value() then
            if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and myHero:GetSpellData(SUMMONER_1).currentCd == 0 and lastIG + 1000 < GetTickCount()  then
                if IGdamage >= target.health then
                    Control.CastSpell(HK_SUMMONER_1, target.pos)
                    lastIG = GetTickCount()
                end
            end
            

            
            if myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and myHero:GetSpellData(SUMMONER_2).currentCd == 0 and lastIG + 1000 < GetTickCount()  then
                if IGdamage >= target.health then
                    Control.CastSpell(HK_SUMMONER_2, target.pos)
                    lastIG = GetTickCount()
                end
            end
        end
    end
end

function Thresh:AutoE()
    local EnemyHeroes = ObjectManager:GetEnemyHeroes(465, false)
    if next(EnemyHeroes) == nil then  return  end
    for i = 1, #EnemyHeroes do
        local target = EnemyHeroes[i]
        local heroName = target.charName
        if Ready(_E) and self.tyMenu.E.AutoE[heroName] and self.tyMenu.E.AutoE[heroName]:Value() and lastE + 1000 < GetTickCount() then
            pre = self:GetPosE(target.pos)
            Control.CastSpell(HK_E, pre)
            lastE = GetTickCount()
        end
    end

end

function Thresh:AntiE()
    local EnemyHeroes = ObjectManager:GetEnemyHeroes(475, false)
    if next(EnemyHeroes) == nil then  return  end
        for i = 1, #EnemyHeroes do
        local target = EnemyHeroes[i]
        local heroName = target.charName
        if Ready(_E) and self.tyMenu.E.AntiE[heroName] and self.tyMenu.E.AntiE[heroName]:Value() and lastE + 1000 < GetTickCount() then
    
            if target.pathing.isDashing and target.pathing.dashSpeed>870 then

                local delay = 0.25 + (475 - target.pos:DistanceTo())/1100
                --print(delay)
                local pos = target:GetPrediction(target.pathing.dashSpeed, delay)
                local pre = self:GetPosE(pos)
                lastE = GetTickCount()
                --print(target.pathing.dashSpeed)
                Control.CastSpell(HK_E, pre)

            end
        end
    end

end

function Thresh:GetPosE(pos, mode) --RMAN
	local push = mode == "Push" and true or false
	--	
	return myHero.pos:Extended(pos, self.EData.Range * (push and 1 or -1))
end

function Thresh:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

Thresh()

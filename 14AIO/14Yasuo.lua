  
-- require('GamsteronPrediction')
require "PremiumPrediction"

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero

local orbwalker         = _G.SDK.Orbwalker
local targetSelector    = _G.SDK.TargetSelector
local dmglib            = _G.SDK.Damage
local healthPred        = _G.SDK.HealthPrediction
local OB                = _G.SDK.ObjectManager
local TableInsert       = _G.table.insert

local lastIG = 0
local lastMove = 0

local Enemys =   {}
local Allys  =   {}

local myHero = myHero

local TargetedSpell = {
    ["Frostbite"]                   = {charName = "Anivia"      , slot = "E" , delay = 0.25, speed = 1600       , isMissile = true },
    ["AnnieQ"]                      = {charName = "Annie"       , slot = "Q" , delay = 0.25, speed = 1400       , isMissile = true },
    ["BrandR"]                      = {charName = "Brand"       , slot = "R" , delay = 0.25, speed = 1000       , isMissile = true },   -- to be comfirm brand R delay 0.25 or 0.5
    ["CassiopeiaE"]                 = {charName = "Cassiopeia"  , slot = "E" , delay = 0.15, speed = 2500       , isMissile = true },   -- delay to be comfirm
    ["EliseHumanQ"]                 = {charName = "Elise"       , slot = "Q1", delay = 0.25, speed = 2200       , isMissile = true },
    ["FiddlesticksDarkWind"]        = {charName = "FiddleSticks", slot = "E" , delay = 0.25, speed = 1100       , isMissile = true },
    ["GangplankQProceed"]           = {charName = "Gangplank"   , slot = "Q" , delay = 0.25, speed = 2600       , isMissile = true },
    ["SowTheWind"]                  = {charName = "Janna"       , slot = "W" , delay = 0.25, speed = 1600       , isMissile = true },
    ["KatarinaQ"]                   = {charName = "Katarina"    , slot = "Q" , delay = 0.25, speed = 1600       , isMissile = true },
    ["NullLance"]                   = {charName = "Kassadin"    , slot = "Q" , delay = 0.25, speed = 1400       , isMissile = true },
    ["LeblancQ"]                    = {charName = "Leblanc"     , slot = "Q" , delay = 0.25, speed = 2000       , isMissile = true },
    ["LeblancRQ"]                   = {charName = "Leblanc"     , slot = "RQ", delay = 0.25, speed = 2000       , isMissile = true },
    ["LuluWTwo"]                    = {charName = "Lulu"        , slot = "W" , delay = 0.25, speed = 2250       , isMissile = true },
    ["SeismicShard"]                = {charName = "Malphite"    , slot = "Q" , delay = 0.25, speed = 1200       , isMissile = true },
    ["MissFortuneRicochetShot"]     = {charName = "MissFortune" , slot = "Q" , delay = 0.25, speed = 1400       , isMissile = true },
    ["NautilusGrandLine"]           = {charName = "Nautilus"    , slot = "R" , delay = 0.5 , speed = 1400       , isMissile = true },  -- delay to be comfirm
    ["PantheonQ"]                   = {charName = "Pantheon"    , slot = "Q" , delay = 0.25, speed = 1500       , isMissile = true },
    ["RyzeE"]                       = {charName = "Ryze"        , slot = "E" , delay = 0.25, speed = 3500       , isMissile = true },
    ["SyndraR"]                     = {charName = "Syndra"      , slot = "R" , delay = 0.25, speed = 1400       , isMissile = true },
    ["TwoShivPoison"]               = {charName = "Shaco"       , slot = "E" , delay = 0.25, speed = 1500       , isMissile = true },
    ["BlindingDart"]                = {charName = "Teemo"       , slot = "Q" , delay = 0.25, speed = 1500       , isMissile = true },
    ["TristanaR"]                   = {charName = "Tristana"    , slot = "R" , delay = 0.25, speed = 2000       , isMissile = true },
    ["VayneCondemn"]                = {charName = "Vayne"       , slot = "E" , delay = 0.25, speed = 2200       , isMissile = true },
    ["VeigarR"]                     = {charName = "Veigar"      , slot = "R" , delay = 0.25, speed = 500        , isMissile = true },
    ["NamiW"]                       = {charName = "Nami"        , slot = "W" , delay = 0.25, speed = 2000       , isMissile = true },
    ["ViktorPowerTransfer"]         = {charName = "Viktor"      , slot = "Q" , delay = 0.25, speed = 2000       , isMissile = true },
    ["BlueCardPreAttack"]           = {charName = "TwistedFate" , slot = "WBlue" , delay = 0   , speed = 1500       , isMissile = true },
    ["RedCardPreAttack"]            = {charName = "TwistedFate" , slot = "WRed" , delay = 0   , speed = 1500       , isMissile = true },
    ["GoldCardPreAttack"]           = {charName = "TwistedFate" , slot = "WGold" , delay = 0   , speed = 1500       , isMissile = true }
}


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

class "Yasuo"

function Yasuo:__init()
    
    -- self.Q = {Type = _G.SPELLTYPE_LINE, Delay = 0.35, Radius = 40, Range = 475, Speed = math.huge, Collision = false}
    -- self.Q3 = {Type = _G.SPELLTYPE_LINE, Delay = 0.35, Radius = 90, Range = 1060, Speed = 1500, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}}
    self.Q = {speed = math.huge, range = 475,Range = 475, delay = 0.35, radius = 40, type = "linear"}
    self.Q3 = {speed = 1500, range = 1060,Range = 1060, delay = 0.35, radius = 90, type = "linear"}


    self.E  = {Range = 475, Speed = 715}
    self.R  = {Range = 1400}

    self.Epre = {Type = _G.SPELLTYPE_LINE, Delay = 0.47, Radius = 1, Range = 475, Speed = math.huge, Collision = false}

    self.QCirWidth = 230
    self.RWidth = 400

    self.blockQ = false

    self.lastETick = GetTickCount()
    self.lastQTick = GetTickCount()

    OnAllyHeroLoad(function(hero) TableInsert(Allys, hero); end)
    OnEnemyHeroLoad(function(hero) TableInsert(Enemys, hero); end)

    orbwalker:OnPreMovement(
        function(args)
            if lastMove + 180 > GetTickCount() then
                args.Process = false
            else
                args.Process = true
                lastMove = GetTickCount()
            end
        end 
    )

    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end




function Yasuo:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14", name = "14Yasuo"})

    self.tyMenu:MenuElement({name = "Ping", id = "ping", value = 20, min = 0, max = 300, step = 1})

    --combo
    
    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})
        self.tyMenu.combo:MenuElement({id = "useQ3", name = "[Q3]", value = true})
        self.tyMenu.combo:MenuElement({id = "Qmode", name = "Q3 Mode", value = 1, drop = {"Priority Circle Q3", "Priority Line Q3"}})
        self.tyMenu.combo:MenuElement({id = "useE", name = "[E]", value = true})
        self.tyMenu.combo:MenuElement({id = "Emode", name = "Q3 Mode", value = 1, drop = {"E to target", "E to cursor"}})
        self.tyMenu.combo:MenuElement({name = "E Gap Closer Range", id = "Erange", value = 800, min = 500, max = 1800, step = 100})
        self.tyMenu.combo:MenuElement({id = "ETower", name = "Stop E Into Tower Range", value = true})
    

    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.tyMenu.harass:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})
        self.tyMenu.harass:MenuElement({id = "useQ3", name = "[Q3]", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "lasthit", name = "Lasthit"})
        self.tyMenu.lasthit:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})
        --self.tyMenu.lasthit:MenuElement({id = "useQ3", name = "[Q3]", value = false})
        self.tyMenu.lasthit:MenuElement({id = "useE", name = "[E]", value = true})
        self.tyMenu.lasthit:MenuElement({id = "ETower", name = "Stop E Into Tower Range", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "jungle", name = "Jungle"})
        self.tyMenu.jungle:MenuElement({id = "useQL", name = "[Q1]/[Q2]", value = true})    
        self.tyMenu.jungle:MenuElement({id = "useQ3", name = "[Q3]", value = true})
        self.tyMenu.jungle:MenuElement({id = "useE", name = "[E]", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "flee", name = "Flee"})
    self.tyMenu.flee:MenuElement({id = "ETower", name = "Stop E Into Tower Range", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "windwall", name = "WindWall Setting"})
    self.tyMenu.windwall:MenuElement({id = "Wcombo", name = "Only Cast W in Combo", value = false})
    self.tyMenu.windwall:MenuElement({name = "Use W Xs before Spell hit", id = "wDelay", value = 0.15, min = 0, max = 0.5, step = 0.01})
    self.tyMenu.windwall:MenuElement({type = MENU, id = "spell", name = "Targeted Spell Setting"})

    OnEnemyHeroLoad(function(hero) 
        for k, v in pairs(TargetedSpell) do
            if v.charName == hero.charName then
                self.tyMenu.windwall.spell:MenuElement({id = k, name = v.charName.." | "..v.slot , value = true})
            end
        end
    end)

    self.tyMenu:MenuElement({type = MENU, id = "Setting", name = "Setting"})
        self.tyMenu.Setting:MenuElement({id = "Qhitchance", name = "Q hitchance", value = 0.4, min = 0.01, max = 1, step = 0.01})
        self.tyMenu.Setting:MenuElement({id = "Q3hitchance", name = "Q3 hitchance", value = 0.5, min = 0.01, max = 1, step = 0.01})

    --Draw
    self.tyMenu:MenuElement({type = MENU, id = "drawing", name = "Drawing"})
        self.tyMenu.drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.drawing:MenuElement({id = "Q3", name = "Draw [Q3] Range", value = true})
        self.tyMenu.drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.drawing:MenuElement({id = "EGap", name = "Draw [E] Gap Closer Range", value = false})
        self.tyMenu.drawing:MenuElement({id = "R", name = "Draw [R] Range", value = false})

end

--local prePos

function Yasuo:Draw()
    if myHero.dead then return end
    --[[
    if prePos ~= nil then
        Draw.Circle(prePos, 100,Draw.Color(80 ,0xFF,0xFF,0xFF))

    end
    ]]
    -- self:CastR()

    if self.tyMenu.drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.drawing.Q3:Value() and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" then
        Draw.Circle(myHero.pos, self.Q3.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.drawing.EGap:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.tyMenu.combo.Erange:Value(),Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end



function Yasuo:Tick()

    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end


    self:UpdateQDelay()
    self:CastW()

    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    elseif orbwalker.Modes[3] then --jungle
        self:Jungle()
    elseif orbwalker.Modes[4] then --lasthit
        self:LastHit()
    elseif orbwalker.Modes[5] then
        self:Flee()
    end
    -- print(self.Q3.delay)

end



local LastR = 0
local LastR2 = 0
local LastRf = 0
function Yasuo:CastR()                                                                                  -- Just some beta test for airblane for yasuo R. Still not in stable
    if LastRf + 200 > GetTickCount() then return end

    local enemys = OB:GetEnemyHeroes(1400)

    for i = 1, #enemys do
        local enemy = enemys[i]
        local isKnock , duration = self:IsKnock(enemy)
        if isKnock then

            if duration < 0.32 and duration > 0 and Ready(_R) then
                local Etarget = self:GetEtargetInRange()
                if Ready(_E) and Etarget and self.lastETick+100 <GetTickCount() then
                    Control.CastSpell(HK_E, Etarget)
                    self.lastETick = GetTickCount()
                    print("E "..GetTickCount())

                    SDK.Action:Add(function() 
                        print("check Q")
                        if Ready(_Q) and self.lastQTick +100 <GetTickCount() then 
                            Control.KeyDown(HK_Q)
                            self.lastQTick = GetTickCount()
                            print("Q "..GetTickCount())

                        end
                    end, 0.02)

                    SDK.Action:Add(function() 
                        if Ready(_R) and LastR + 2000 <GetTickCount() then 
                            Control.CastSpell(HK_R, enemy)
                            SDK.Action:Add(function() 
                                if LastR2 + 500 <GetTickCount() then
                                    Control.CastSpell(HK_R, enemy)
                                    print("R2 "..GetTickCount())
                                    LastR2 = GetTickCount()
                                end
                            end, 0.01)

                            print("R "..GetTickCount())
                            print("knock time: "..duration)
                            Control.KeyUp(HK_Q)
                            LastR = GetTickCount()
                        end
                    end, 0.1)
                end

            end
        end
    end
    LastRf = GetTickCount()

end



function Yasuo:UpdateQDelay()
    local activeSpell = myHero.activeSpell

    if activeSpell.valid then
        if activeSpell.name == "YasuoQ1" or activeSpell.name == "YasuoQ2" then
            self.Q.delay = activeSpell.windup
        end

        if activeSpell.name == "YasuoQ3" then
            self.Q3.delay = activeSpell.windup

            -- print(self.Q3.delay)
        end
    end
end

function Yasuo:Combo()
    local target = nil
    self.blockQ = false


    if self.tyMenu.combo.useE:Value() and Ready(_E) and self.lastETick + 100 < GetTickCount() and not myHero.pathing.isDashing then
        local range = self.tyMenu.combo.Erange:Value()
        target = self:GetHeroTarget(range)
        local AArange = myHero.range + myHero.boundingRadius
        local Eobj, distance, inQrange


        if target and self.tyMenu.combo.Emode:Value() == 1 then

            Eobj, distance, inQrange = self:GetBestEObjToTarget(target, self.tyMenu.combo.ETower:Value())
            if Eobj and distance < myHero.pos:DistanceTo(target.pos) then
                --print("distance: "..distance.." myHero--Target : "..myHero.pos:DistanceTo(target.pos))
                if orbwalker:CanMove() and myHero.pos:DistanceTo(target.pos) > AArange then
                    print("castE")
                    Control.CastSpell(HK_E, Eobj)
                    self.lastETick = GetTickCount()

                    local tmpTarget = target
                    DelayAction(function()
                        self:CheckEQ(tmpTarget)
                    end, (self.Epre.Delay-0.11))

                    if inQrange then
                        --print("blockQ 1")
                        self.blockQ = true
                    end
                end
            elseif Eobj and inQrange and Ready(_Q) and orbwalker:CanMove() then
                Control.CastSpell(HK_E, Eobj)
                print("castE")

                DelayAction(function()
                    self:CheckEQ(target)
                end, self.Epre.Delay-0.11)
    
                self.lastETick = GetTickCount()

                if inQrange then
                    --print("blockQ 2")
                    self.blockQ = true
                end
            end
            
        elseif target and self.tyMenu.combo.Emode:Value() == 2 then
            Eobj, distance  = self:GetBestEObjToCursor(self.tyMenu.combo.ETower:Value())
            if Eobj and distance < mousePos:DistanceTo(target.pos) then
                Control.CastSpell(HK_E, Eobj)
                print("cast E combo "..GetTickCount())
                self.lastETick = GetTickCount()

                local tmpTarget = target
                DelayAction(function()
                    self:CheckEQ(tmpTarget)
                end, self.Epre.Delay - 0.09)

                local endPos = self:GetDashPos(Eobj)
                local Qdistance = target.pos:DistanceTo(endPos)
                if Qdistance < self.QCirWidth then
                    self.blockQ = true
                end
            end
        end

    end

    target = self:GetHeroTarget(self.Q3.Range)
    if target and self.tyMenu.combo.useQ3:Value() and not self.blockQ then
        self:CastQ3(target)
    end

    target = self:GetHeroTarget(self.Q.Range)
    if target and self.tyMenu.combo.useQL:Value() then
        self:CastQ(target)
    end


end

function Yasuo:Harass()
    local target = nil

    target = self:GetHeroTarget(self.Q3.Range)
    if target and self.tyMenu.harass.useQ3:Value() and not self.blockQ then
        self:CastQ3(target)
    end

    target = self:GetHeroTarget(self.Q.Range)
    if target and self.tyMenu.harass.useQL:Value() then
        self:CastQ(target)
    end
end

function Yasuo:Jungle()
    local jungleInrange = OB:GetMonsters(475)
    if next(jungleInrange) == nil then return  end


    if jungleInrange[1] and not self:HasBuff(jungleInrange[1], "YasuoE") and self.tyMenu.jungle.useE:Value() 
       and Ready(_E) and self.lastETick + 100 < GetTickCount() and orbwalker:CanMove(myHero) and jungleInrange[1].pos:DistanceTo(myHero.pos) > myHero.range then
        print("jungle cast E")
        Control.CastSpell(HK_E, jungleInrange[1])
        self.lastETick = GetTickCount()
        if Ready(_Q) and self.lastQTick + 300< GetTickCount() then
            DelayAction(function()
                print("jungle EQ")
            Control.CastSpell(HK_Q)
            self.lastQTick = GetTickCount()

            end, 0.1)
        end
    end

    if self.tyMenu.jungle.useQL:Value()and Ready(_Q) and not myHero.pathing.isDashing and myHero:GetSpellData(0).name ~= "YasuoQ3Wrapper" and self.lastETick + 100 < GetTickCount() and
        myHero.pos:DistanceTo(jungleInrange[1].pos) <= self.Q.Range and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
            print("jungle Q1")
            Control.CastSpell(HK_Q,jungleInrange[1])
            self.lastQTick = GetTickCount()
 
    end

    if self.tyMenu.jungle.useQ3:Value()and Ready(_Q) and not myHero.pathing.isDashing and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" and self.lastETick + 100 < GetTickCount() and
        myHero.pos:DistanceTo(jungleInrange[1].pos) <= self.Q.Range and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
            print("jungle Q3")
            Control.CastSpell(HK_Q,jungleInrange[1])
            self.lastQTick = GetTickCount()
    end
end

function Yasuo:LastHit()
    local minionInRange = OB:GetEnemyMinions(self.Q.Range)
    if next(minionInRange) == nil then return  end

    for i = 1, #minionInRange do
        local minion = minionInRange[i]

        if self.tyMenu.lasthit.useQL:Value()and Ready(_Q) and not myHero.pathing.isDashing and myHero:GetSpellData(0).name ~= "YasuoQ3Wrapper" and self.lastETick + 100 < GetTickCount() and
        orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then

            local hpPred = healthPred:GetPrediction(minion, self.Q.delay)
            local dmg = self:GetQDamge(minion)
            if dmg >= hpPred then
                print("lasthit Q1")
                Control.CastSpell(HK_Q,minion)
                self.lastQTick = GetTickCount()
            end
        end

        if self.tyMenu.lasthit.useE:Value()and Ready(_E) and not myHero.pathing.isDashing  and self.lastETick + 100 < GetTickCount() and self.lastQTick + 300 < GetTickCount() and 
        orbwalker:CanMove(myHero) and not self:HasBuff(minion, "YasuoE") then
            local delay = self:GetEDmgDelay(minion)
            local hpPred = healthPred:GetPrediction(minion, delay-0.3)
            local dmg = self:GetEDamge(minion)

            if dmg >= hpPred then
                print("lasthit E")
                if self.tyMenu.lasthit.ETower:Value() then
                    local endPos = self:GetDashPos(minion)
                    if self:OutOfTurrents(endPos) then
                        Control.CastSpell(HK_E,minion)
                        self.lastETick = GetTickCount()    
                    end
                else
                    Control.CastSpell(HK_E,minion)
                    self.lastETick = GetTickCount()
                end
            end
        end
    end




end

function Yasuo:Flee()
    if Ready(_E) and self.lastETick + 100 < GetTickCount() and not myHero.pathing.isDashing then
        local Eobj, distance  = self:GetBestEObjToCursor(self.tyMenu.flee.ETower:Value())
        if Eobj and distance < mousePos:DistanceTo(myHero.pos) then
            Control.CastSpell(HK_E, Eobj)
            print("E flee "..GetTickCount())
            self.lastETick = GetTickCount()
        end
    end
end


function Yasuo:GetTargetPosAfterEDelay(target)
    -- self.Epre.Range = self.tyMenu.combo.Erange:Value()
    -- self.Epre.Delay = self:GetEDelay()

    -- local Pred = GetGamsteronPrediction(target, self.Epre, myHero)
    -- if Pred.UnitPosition then
    --     return Pred.UnitPosition
    -- else
    --     if target.pathing.isDashing then
    --         return target:GetPrediction(target.pathing.dashSpeed,self.Epre.Delay)
    --     else
    --         return target:GetPrediction(target.ms,self.Epre.Delay)
    --     end
    -- end

    return _G.PremiumPrediction:GetPositionAfterTime(target, self:GetEDelay())
end

function Yasuo:GetDashPos(obj)
    local myPos = Vector(myHero.pos.x, myHero.pos.y, myHero.pos.z)
    local objPos = Vector(obj.pos.x, myHero.pos.y, obj.pos.z)
    local pos = myPos:Extended(objPos, 475)

    return pos
end

function Yasuo:OutOfTurrents(endPos)
    local turrets = OB:GetEnemyTurrets()
    local range = 88.5 + 750 + myHero.boundingRadius / 2
    for i = 1, #turrets do
        local turret = turrets[i]
        if self:IsInRange(endPos, turret.pos, range) then
            return false
        end
    end
    return true
end

function Yasuo:CheckEQ(target)
    --print("check EQ")
    if myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) <= self.QCirWidth and Ready(_Q) then
        Control.KeyDown(HK_Q)
        orbwalker:SetAttack(false)
        --print("E delay "..self.Epre.Delay)
        print("EQ1 "..os.clock())
        DelayAction(function()
            Control.KeyUp(HK_Q)
            print("EQ2 "..os.clock())
            DelayAction(function()   
                orbwalker:SetAttack(true)
            end, 0.4)

        end, 0.05)
    end    
end

function Yasuo:GetEtargetInRange()
    local minionInERange = OB:GetEnemyMinions(475)
    local jungleInErange = OB:GetMonsters(475)
    local heroInErange   = OB:GetEnemyHeroes(475)

    for i,minion in pairs (minionInERange) do 
        if not self:HasBuff(minion, "YasuoE")  then
            return minion
        end
    end

    for i,minion in pairs (jungleInErange) do 
        if not self:HasBuff(minion, "YasuoE")  then
            return minion
        end
    end

    for i,minion in pairs (heroInErange) do 
        if not self:HasBuff(minion, "YasuoE") then
            return minion
        end
    end
end

function Yasuo:GetBestEObjToCursor(underTower)
    local minionInERange = OB:GetEnemyMinions(475)
    local jungleInErange = OB:GetMonsters(475)
    local heroInErange   = OB:GetEnemyHeroes(475)

    local minDistance = math.huge
    local bestMinion = nil

    for i,minion in pairs (minionInERange) do 
        if not self:HasBuff(minion, "YasuoE") then
            local endPos = self:GetDashPos(minion)
            local distance = mousePos:DistanceTo(endPos)

            if underTower then
                if self:OutOfTurrents(endPos) and distance < minDistance then
                    minDistance = distance
                    bestMinion = minion
                end
                        
            else
                if distance < minDistance then
                    minDistance = distance
                    bestMinion = minion
                end
            end
        end
    end

    if bestMinion == nil then
        for i,minion in pairs (jungleInErange) do 
            if not self:HasBuff(minion, "YasuoE") then
                local endPos = self:GetDashPos(minion)
                local distance = mousePos:DistanceTo(endPos)
    
                if underTower then
                    if self:OutOfTurrents(endPos) and distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                            
                else
                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end
            end
        end
    end

    if bestMinion == nil then
        for i,minion in pairs (heroInErange) do 
            if not self:HasBuff(minion, "YasuoE") then
                local endPos = self:GetDashPos(minion)
                local distance = mousePos:DistanceTo(endPos)
    
                if underTower then
                    if self:OutOfTurrents(endPos) and distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                            
                else
                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end
            end
        end
    end

    return bestMinion, minDistance

end

function Yasuo:GetBestEObjToTarget(target, underTower)
    local minionInERange = OB:GetEnemyMinions(475)
    local jungleInErange = OB:GetMonsters(475)
    local heroInErange   = OB:GetEnemyHeroes(475)

    --if next(minionInERange) == nil then return nil end

    local unitPos = self:GetTargetPosAfterEDelay(target)

    --prePos = unitPos

    local minDistance = math.huge
    local bestMinion = nil

    for i,minion in pairs (minionInERange) do 
        if not self:HasBuff(minion, "YasuoE") then
            local endPos = self:GetDashPos(minion)
            local distance = unitPos:DistanceTo(endPos)

            if underTower then
                if self:OutOfTurrents(endPos) then
                    if distance < self.QCirWidth then
                        return minion, distance, true
                    end

                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end

            else
                if distance < self.QCirWidth then
                    return minion, distance, true
                end

                if distance < minDistance then
                    minDistance = distance
                    bestMinion = minion
                end
            end
        end
    end

    if bestMinion == nil then
        for i,minion in pairs (jungleInErange) do 
            if not self:HasBuff(minion, "YasuoE") then
                local endPos = self:GetDashPos(minion)
                local distance = unitPos:DistanceTo(endPos)
    
                if underTower then
                    if self:OutOfTurrents(endPos) then
                        if distance < self.QCirWidth then
                            return minion, distance,true
                        end
    
                        if distance < minDistance then
                            minDistance = distance
                            bestMinion = minion
                        end
                    end
    
                else
                    if distance < self.QCirWidth then
                        return minion, distance, true
                    end
    
                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end
            end
        end
    end

    if bestMinion == nil then
        for i,minion in pairs (heroInErange) do 
            if not self:HasBuff(minion, "YasuoE") and minion ~= target then
                local endPos = self:GetDashPos(minion)
                local distance = unitPos:DistanceTo(endPos)
    
                if underTower then
                    if self:OutOfTurrents(endPos) then
                        if distance < self.QCirWidth then
                            return minion, distance, true
                        end
    
                        if distance < minDistance then
                            minDistance = distance
                            bestMinion = minion
                        end
                    end
    
                else
                    if distance < self.QCirWidth then
                        return minion, distance, true
                    end
    
                    if distance < minDistance then
                        minDistance = distance
                        bestMinion = minion
                    end
                end
            end
        end
    end



    if bestMinion == nil then
        if myHero.pos:DistanceTo(target.pos) < 475 and not self:HasBuff(target, "YasuoE") then 
            local endPos = self:GetDashPos(target)
            local distance = unitPos:DistanceTo(endPos)

            if underTower and not self:OutOfTurrents(endPos) then return end

            if distance < self.QCirWidth then
                --print("E target")
                return target, distance, true
            else 
                --print("E target")
                return target, distance
            end
        end
    end
    return bestMinion, minDistance
end

function Yasuo:GetEDelay()
    local movementSpeed = myHero.ms
    local Espeed = 715 + movementSpeed * 0.95

    return (475/Espeed + self.tyMenu.ping:Value()/1000)
end

function Yasuo:GetEDmgDelay(target)
    local movementSpeed = myHero.ms
    local Espeed = 715 + movementSpeed * 0.95
    local distance = myHero.pos:DistanceTo(target.pos)

    return (distance/Espeed + self.tyMenu.ping:Value()/1000)
end


function Yasuo:GetHeroTarget(range)
    local EnemyHeroes = OB:GetEnemyHeroes(range, false)
    local target = targetSelector:GetTarget(EnemyHeroes)

    return target
end

function Yasuo:CastQ(target, hitchance)

    if Ready(_Q) and not myHero.pathing.isDashing and myHero:GetSpellData(0).name ~= "YasuoQ3Wrapper" and self.lastETick + 100 < GetTickCount() and
       myHero.pos:DistanceTo(target.pos) <= self.Q.Range and orbwalker:CanMove(myHero) and self.lastQTick + 300 < GetTickCount() then
        -- local Pred = GetGamsteronPrediction(target, self.Q, myHero)
        -- if Pred.Hitchance >= hitchance then
        --     orbwalker:SetMovement(false)
        --     orbwalker:SetAttack(false)

        --     Control.CastSpell(HK_Q, Pred.CastPosition)

        --     self.lastQTick = GetTickCount()

        --     orbwalker:SetMovement(true)
        --     orbwalker:SetAttack(true)
        --     print("cast Q")
        -- end

        local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.Q)
        if pred.CastPos and pred.HitChance > self.tyMenu.Setting.Qhitchance:Value() then
            Control.CastSpell(HK_Q, pred.CastPos)
            self.lastQTick = GetTickCount()
            print("castQ")
        end 
    end
end

function Yasuo:CastQ3(target)
    if Ready(_Q) and not myHero.pathing.isDashing 
    and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" 
    and self.lastETick + 100 < GetTickCount() 
    and myHero.pos:DistanceTo(target.pos) <= self.Q3.Range 
    and orbwalker:CanMove(myHero) 

    then
        -- print(self.lastQTick)
        -- print("castQ3"..GetTickCount())
    end
    if Ready(_Q) and not myHero.pathing.isDashing 
    and myHero:GetSpellData(0).name == "YasuoQ3Wrapper" 
    and self.lastETick + 100 < GetTickCount() 
    and myHero.pos:DistanceTo(target.pos) <= self.Q3.Range 
    and orbwalker:CanMove(myHero) 
    and self.lastQTick + 300 < GetTickCount() then
        -- local Pred = GetGamsteronPrediction(target, self.Q3, myHero)
        -- if Pred.Hitchance >= _G.HITCHANCE_HIGH then
        --     orbwalker:SetMovement(false)
        --     orbwalker:SetAttack(false)

        --     Control.CastSpell(HK_Q, Pred.CastPosition)

        --     self.lastQTick = GetTickCount()

        --     orbwalker:SetMovement(true)
        --     orbwalker:SetAttack(true)
        --     print("cast Q3")
        -- end

        local pred = _G.PremiumPrediction:GetPrediction(myHero, target, self.Q3)
        if pred.CastPos 
        and pred.HitChance > self.tyMenu.Setting.Q3hitchance:Value() 
        then
            Control.CastSpell(HK_Q, pred.CastPos)
            self.lastQTick = GetTickCount()
            print("castQ3")
        end 
    end
end

local lastWTick = 0
function Yasuo:CastW()
    if lastWTick + 1000 > GetTickCount() or not Ready(_W) then return end
    if self.tyMenu.windwall.Wcombo:Value() and not orbwalker.Modes[0] then return end
    local EnemyHeroes = OB:GetEnemyHeroes(2800)
    for i = 1, #EnemyHeroes do
        local hero = EnemyHeroes[i]
        if hero.activeSpell.valid and TargetedSpell[hero.activeSpell.name] ~= nil then
            if hero.activeSpell.target == myHero.handle and self.tyMenu.windwall.spell[hero.activeSpell.name]:Value() then
                local dt = myHero.pos:DistanceTo(hero.pos)
                local hitTime = TargetedSpell[hero.activeSpell.name].delay + dt/TargetedSpell[hero.activeSpell.name].speed

                --print("hitTime: "..hitTime)

                DelayAction(function()
                    Control.CastSpell(HK_W, hero.pos)
                end,  (hitTime - self.tyMenu.ping:Value()/1000 - self.tyMenu.windwall.wDelay:Value()))

                lastWTick = GetTickCount()
                return
            end
            
        end
    end
end

function Yasuo:GetQDamge(obj)
    local baseDMG = ({20,45,70,95,120})[myHero:GetSpellData(0).level]
    local AD = myHero.totalDamage
    local dmg = dmglib:CalculateDamage(myHero, obj, _G.SDK.DAMAGE_TYPE_PHYSICAL ,  baseDMG + AD )

    return dmg
end

function Yasuo:GetEDamge(obj)
    local Ebonus = 1
    local buff, count = self:HasBuff(myHero, "YasuoDashScalar")
    if buff then
        if count == 1 then
            Ebonus = 1.25
        elseif count == 2 then
            Ebonus = 1.5
        end
    end

    local baseDMG = ({60,70,80,90,100})[myHero:GetSpellData(2).level]
    local AD = 0.2 * myHero.bonusDamage
    local AP = 0.6 * myHero.ap
    local dmg = dmglib:CalculateDamage(myHero, obj, _G.SDK.DAMAGE_TYPE_MAGICAL ,  baseDMG * Ebonus + AD + AP )

    return dmg
end

function Yasuo:IsKnock(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local bType = buff.type
            if bType == 29 or bType == 30 then
                return true, buff.duration
            end
        end
    end
    return false
end

Yasuo()

function Yasuo:HasBuff(unit, name)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name then
            return true , buff.count
        end
    end
    return false
end

function Yasuo:IsInRange(pos1, pos2, range)
    if GetDistanceSquared(pos1,pos2) < range * range then
        return true
    end
    return false
end
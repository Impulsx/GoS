require 'GGPrediction'

local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero
local TableInsert       = _G.table.insert
local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector
local LocalGameTimer = Game.Timer
local ControlKeyDown = Control.KeyDown
local ControlKeyUp = Control.KeyUp

local myHero = myHero

local lastQ = 0
local lastQdown = 0
local lastQup = 0
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
        if buff and buff.count > 0 and buff.name == name  then
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


class "Pantheon"

function Pantheon:__init()
    self.Q1 = {Hitchance = GGPrediction.HITCHANCE_HIGH, Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 500, Speed = math.huge, Collision = false}
    self.Q2 = {Hitchance = GGPrediction.HITCHANCE_HIGH, Type = GGPrediction.SPELLTYPE_LINE, Delay = 0, Radius = 60, Range = 1200, Speed = 1500, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}}
    self.W = {Range = 600}
    self.E = {Range = 250}
    self.R = {Range = 5500}

    self.Qchannel = false
    self.Echannel = false

	self.Qtimer = LocalGameTimer()

    self:LoadMenu()

    OnAllyHeroLoad(function(hero)
        TableInsert(Allys, hero);
    end)

    OnEnemyHeroLoad(function(hero)
        TableInsert(Enemys, hero);
    end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
    Callback.Add('WndMsg', function(...) self:WndMsg(...) end)


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

function Pantheon:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14Pantheon", name = "[14AIO] Pantheon"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({id = "UseQ1", name = "[Q1]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseQ2", name = "[Q2]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
    self.tyMenu.Combo:MenuElement({id = "checkW", name = "Dont Q if W ready", value = false})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Setting", name = "Setting"})
    self.tyMenu.Setting:MenuElement({id = "Erange", name = "Max E range", value = 250, min = 1, max = 400, step = 1, callback = function(value)
        self.E.Range = value
    end})

    self.tyMenu.Setting:MenuElement({name ="Q1 HitChance" , drop = {"High", "Normal"}, callback = function(value)
        if value == 1 then
            self.Q1.Hitchance = GGPrediction.HITCHANCE_HIGH
        end
        if value == 2 then
            self.Q1.Hitchance = GGPrediction.HITCHANCE_NORMAL
        end
    end})
    self.tyMenu.Setting:MenuElement({name ="Q2 HitChance" , drop = {"High", "Normal"}, callback = function(value)
        if value == 1 then
            self.Q2.Hitchance = GGPrediction.HITCHANCE_HIGH
        end
        if value == 2 then
            self.Q2.Hitchance = GGPrediction.HITCHANCE_NORMAL
        end
    end})


    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Q1", name = "Draw [Q1] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "Q2", name = "Draw [Q2] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Pantheon:Draw()
    if myHero.dead then
        return
    end
    if self.tyMenu.Drawing.Q2:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q2.Range,Draw.Color(255,255, 162, 000))
    end
    if self.tyMenu.Drawing.Q1:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q1.Range,Draw.Color(255,255, 162, 000))
    end
    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.Range,Draw.Color(255,255, 162, 000))
    end
    if self.tyMenu.Drawing.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(255,255, 162, 000))
    end
    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Pantheon:Tick()

    self:Buffmanager()

    if self.Echannel or self.Qchannel then
        orbwalker:SetAttack(false)
    else
        orbwalker:SetAttack(true)

    end

    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end


    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
    end

end

function Pantheon:Combo()

    local target = TargetSelector:GetTarget(self.W.Range)
    if target and self.tyMenu.Combo.UseW:Value() then
        if IsValid(target) and Ready(_W) and lastW + 250 < GetTickCount() and not self.Qchannel then
            Control.CastSpell(HK_W,target.pos)
            lastW = GetTickCount()
        end
    end

    local target = TargetSelector:GetTarget(self.Q1.Range)
    if target and self.tyMenu.Combo.UseQ1:Value() then
        if self.tyMenu.Combo.checkW:Value() then
            if not Ready(_W) then
                self:CastQ1(target)
            end
        else
            self:CastQ1(target)
        end
    end

    local target = TargetSelector:GetTarget(self.Q2.Range)
    if target and self.tyMenu.Combo.UseQ2:Value() then
        if self.tyMenu.Combo.checkW:Value() then
            if not Ready(_W) and not self.Qchannel then
                self:CastQ2(target)
            end
        else
            self:CastQ2(target)
        end
    end

    local target = TargetSelector:GetTarget(self.E.Range)
    if target and self.tyMenu.Combo.UseE:Value() and not Ready(_Q) then
        if IsValid(target) and Ready(_E) and lastE + 250 < GetTickCount() and not self.Qchannel and not self.Echannel then
            Control.CastSpell(HK_E,target.pos)
            lastE = GetTickCount()
        end
    end

end

function Pantheon:Harass()
    local target = TargetSelector:GetTarget(self.Q1.Range)
    if target and self.tyMenu.Harass.UseQ:Value() then
        self:CastQ1(target)
    end

    local target = TargetSelector:GetTarget(self.Q2.Range)
    if target and self.tyMenu.Harass.UseQ:Value() then
        self:CastQ2(target)
    end

end

function Pantheon:CastQ1(target)
    if IsValid(target) and Ready(_Q)  and  self.Qchannel == false and lastQ + 250 < GetTickCount()
    and orbwalker:CanMove() and GetDistanceSquared(myHero.pos,target.pos) < self.Q1.Range ^2 then
        local Pred = GGPrediction:SpellPrediction(self.Q1)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q1, myHero)
        print(GGPrediction.HITCHANCE_HIGH)
        if (Pred.Hitchance or Pred.HitChance >= self.Q1.Hitchance) or Pred:CanHit(self.Q1.Hitchance or GGPrediction.HITCHANCE_HIGH) then
            Control.CastSpell(HK_Q,Pred.CastPosition)
            lastQ = GetTickCount()
        end
    end
end

function Pantheon:CastQ2(target)
    if IsValid(target) and self.Qchannel == false and Ready(_Q) and lastQ + 500 < GetTickCount()
    and lastQdown + 150 < GetTickCount() and GetDistanceSquared(myHero.pos,target.pos) < self.Q2.Range ^2
    then
        ControlKeyDown(HK_Q)
        lastQdown = GetTickCount()
        self.Qchannel = true
        self.Qtimer = LocalGameTimer()
    end

    if IsValid(target) and LocalGameTimer() > self.Qtimer + 0.35 and LocalGameTimer() < self.Qtimer + 4
    and self.Qchannel and Ready(_Q)  and  lastQup + 150 < GetTickCount() then
        local Pred = GGPrediction:SpellPrediction(self.Q2)
        Pred:GetPrediction(target, myHero) --GetGamsteronPrediction(target, self.Q2, myHero)
        print(GGPrediction.HITCHANCE_HIGH)
        if (Pred.Hitchance or Pred.HitChance >= self.Q2.Hitchance) or Pred:CanHit(self.Q2.Hitchance or GGPrediction.HITCHANCE_HIGH) then
            -- Control.SetCursorPos(Pred.CastPosition)
            -- ControlKeyUp(HK_Q)
            Control.CastSpell(HK_Q,Pred.CastPosition)
            lastQup = GetTickCount()
            self.Qchannel = false
        end
    end
end


function Pantheon:Buffmanager()
    self.Qchannel = false
    self.Echannel = false
    for i=1, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff.duration >0 and buff.count > 0 then
            if buff.name == "PantheonQ" then
                self.Qchannel = true
            end
            if buff.name == "PantheonE" then
                self.Echannel = true
            end

        end
    end

    if not self.Qchannel and Control.IsKeyDown(HK_Q) and LocalGameTimer() > self.Qtimer + 0.25  then
        ControlKeyUp(HK_Q)
    end


end

function Pantheon:WndMsg(msg, wParam)
    if msg == 256 and wParam == 81 then
        if Ready(_Q) then
            self.Qchannel = true
            self.Qtimer = LocalGameTimer()
        end
    end
end


Pantheon()

local function DownloadFile(site, file)
	DownloadFileAsync(site, file, function() end)
	local timer = os.clock()
	while os.clock() < timer + 1 do end
	while not FileExist(file) do end
end

local function ReadFile(file)
	local txt = io.open(file, "r")
	local result = txt:read()
	txt:close(); return result
end

local Version = 1.21


local orbwalker = nil
local prediction = nil

local cachedEnemyHeroes = {}
local cachedAllyHeroes = {}
local cachedMinion = {}
local lastMionionCachedTime = 0
local cachedTurrets = {}
local lastTurretsCachedTime = 0

local table_insert = table.insert
local table_remove = table.remove
local table_move = table.move
local abs = math.abs
local sqrt = math.sqrt
local deg = math.deg
local acos = math.acos
local cos = math.cos
local sin = math.sin
local floor = math.floor
local max = math.max

local function CalcPhysicalDamage(source, target, amount)
    local armorPenetrationPercent = source.armorPenPercent
    local armorPenetrationFlat = source.armorPen *
                                     (0.6 + 0.4 * source.levelData.lvl / 18)
    local bonusArmorPenetrationMod = source.bonusArmorPenPercent

    local armor = target.armor
    local bonusArmor = target.bonusArmor
    local value

    if armor < 0 then
        value = 2 - 100 / (100 - armor)
    elseif armor * armorPenetrationPercent - bonusArmor *
        (1 - bonusArmorPenetrationMod) - armorPenetrationFlat < 0 then
        value = 1
    else
        value = 100 / (100 + armor * armorPenetrationPercent - bonusArmor *
                    (1 - bonusArmorPenetrationMod) - armorPenetrationFlat)
    end

    return max(floor(value * amount), 0)

end

local function CalcMagicDamage(source, target, amount)
    local magicResist = target.magicResist + target.bonusMagicResist
    local magicPenPercent = source.magicPenPercent
    local magicPen = source.magicPen

    local value

    if magicResist < 0 then
        value = 2 - 100 / (100 - magicResist )
    elseif magicResist * magicPenPercent - magicPen < 0 then
        value = 1
    else
        value = 100 / (100 + magicResist * magicPenPercent - magicPen)
    end

    return max(floor(value * amount), 0)

end

local delayedActions, delayedActionsExecuter = {}, nil
local function MyDelayAction(func, delay, args) --delay in seconds
  if not delayedActionsExecuter then
    function delayedActionsExecuter()
      for t, funcs in pairs(delayedActions) do
        if t <= os.clock() then
          for i = 1, #funcs do
            local f = funcs[i]
            if f and f.func then
              f.func(unpack(f.args or {}))
            end
          end
          delayedActions[t] = nil
        end
      end
    end
    -- AddEvent(Events.OnTick, delayedActionsExecuter)
    Callback.Add("Tick", delayedActionsExecuter)

  end
  local t = os.clock() + (delay or 0)
  if delayedActions[t] then
    delayedActions[t][#delayedActions[t] + 1] = {func = func, args = args}
  else
    delayedActions[t] = {{func = func, args = args}}
  end
end

local function tableMerge(t1, t2, t3 ,t4)
    local newTable = {}

    for i = 1, #t1 do
        local v = t1[i]
        table_insert(newTable,v)
    end
    for i = 1, #t2 do
        local v = t2[i]
        table_insert(newTable,v)
    end

    if t3 then
        for i = 1, #t3 do
            local v = t3[i]
            table_insert(newTable,v)
        end
    end

    if t4 then
        for i = 1, #t4 do
            local v = t4[i]
            table_insert(newTable,v)
        end
    end

    return newTable
end


local function GetDistanceSquared(vec1, vec2)
    local dx = vec1.x - vec2.x
    local dy = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    return dx * dx + dy * dy
end

local function GetDistance(a,b)
    return a:DistanceTo(b)
end

local function CircleCircleIntersection(c1, c2, r1, r2)
    local D = GetDistance(c1,c2)
    if D > r1 + r2 or D <= abs(r1 - r2) then return nil end
    local A = (r1 * r2 - r2 * r1 + D * D) / (2 * D)
    local H = sqrt(r1 * r1 - A * A)
    local Direction = (c2 - c1):Normalized()
    local PA = c1 + A * Direction
    local S1 = PA + H * Direction:Perpendicular()
    local S2 = PA - H * Direction:Perpendicular()
    return S1, S2
end

local function Rotate2D(center,rota,rad)            --Credit to Ark223
    local a = rota.x - center.x
    local b = rota.z - center.z

    local c = a*cos(rad)-b*sin(rad)
    local d = a*sin(rad)+b*cos(rad)

    return Vector(c+center.x,rota.y,d+center.z)
end

local function AngleBetween(v3, v1, v2)

    local p1, p2 = (-v3 + v1), (-v3 + v2)
    local theta = p1:Polar() - p2:Polar()
    if theta < 0 then theta = theta + 360 end
    if theta > 180 then theta = 360 - theta end
    return theta
end


--[[ local function CastSpell(key, position)
    local cPos = cursorPos
    local pos1 = position.pos or position
    local pos = pos1:To2D()

    Control.SetCursorPos(pos.x, pos.y)
    MyDelayAction(function()
        print("pos "..pos.x.." "..pos.y)
        print("cursor "..cursorPos.x.." "..cursorPos.y)

        local dx = cursorPos.x - pos.x
        local dy = (cursorPos.y) - pos.y
        local dr = dx * dx + dy *dy

        print("result "..dr)
        if dr < 1000 then
            Control.KeyDown(key)
            Control.KeyUp(key)
        end

        MyDelayAction(function()
            print(Control.SetCursorPos(cPos.x, cPos.y))
        end,0.01)

    end,0.011)


    -- Control.SetCursorPos(cPos.x, cPos.y)

    return true
end ]]

local function Hasbuff(unit, buffName)
    if unit then
        local buffCount = unit.buffCount
        if buffCount == nil then
            print("buff api error: buffCount nil")
            return nil
        end

        if buffCount < 0 or buffCount > 100000 then
            -- print(debug.traceback())
            print("buff api error: buffCount = "..buffCount)
            print(" Hero: "..unit.charName)
            return nil
        end

        for i = 0, buffCount do
            local buff = unit:GetBuff(i)
            if buff and buff.count > 0 and buff.name == buffName then
                return buff
            end
        end
    end
end


local function IsValid(unit)
    return unit and unit.valid and unit.isTargetable and unit.visible and unit.health > 0
end


local function Ready(spell)
    return Game.CanUseSpell(spell) == 0
end

local function GetEnemyHeroes()
	if #cachedEnemyHeroes == 0 then
		local count = Game.HeroCount()
		if count == nil or count < 0 or count > 100 then
			print('game.herocount=' .. tostring(count))
			return cachedEnemyHeroes
		end
	    for i = 1, count do
	        local obj = Game.Hero(i)
	        if obj.isEnemy then
	        	table_insert(cachedEnemyHeroes, obj)
        	end
	    end
	end
	return cachedEnemyHeroes
end

local function GetAllyHeroes()
	if #cachedAllyHeroes == 0 then
		local count = Game.HeroCount()
		if count == nil or count < 0 or count > 100 then
			print('game.herocount=' .. tostring(count))
			return cachedAllyHeroes
		end
	    for i = 1, count do
	        local obj = Game.Hero(i)
	        if obj.isAlly then
	        	table_insert(cachedAllyHeroes, obj)
        	end
	    end
	end
	return cachedAllyHeroes
end

local function OnAllyHeroLoad(cb)
    for i = 1, #GetAllyHeroes() do
        local obj = GetAllyHeroes()[i]
        cb(obj)
    end
end

local function OnEnemyHeroLoad(cb)
    for i = 1, #GetEnemyHeroes() do
        local obj = GetEnemyHeroes()[i]
        cb(obj)
    end
end

local function GetAllysInRange(range, position)
    local position = position or myHero.pos
    local allys = {}
    local allysTable = GetAllyHeroes()
    for i = 1, #allysTable do
        local obj = allysTable[i]
        if IsValid(obj) and GetDistanceSquared(obj.pos, position) < range * range then
            table_insert(allys,obj)
        end
    end

    return allys
end

local function GetEnemysInRange(range, position)
    local position = position or myHero.pos
    local enemys = {}
    local enemysTable = GetEnemyHeroes()

    for i = 1, #enemysTable do
        local obj = enemysTable[i]
        if IsValid(obj) and GetDistanceSquared(obj.pos, position) < range * range then
            table_insert(enemys,obj)
        end
    end

    return enemys
end


local function GetMinions()
    local minions = {}

    if #cachedMinion > 0 and lastMionionCachedTime + 1000 > GetTickCount() then
        return cachedMinion
    end

    local count = Game.MinionCount()
    if count and count > 0 and count < 1000 then
        for i = 1, count do
            local minion = Game.Minion(i)
            if IsValid(minion) then
                table_insert(minions, minion)
            end
        end
    end

    cachedMinion = minions
    lastMionionCachedTime = GetTickCount()

    return minions
end

local function GetMinionsInRange(range,position)
    local position = position or myHero.pos
    local minionsTable = {}
    local minions = GetMinions()

    for i = 1, #minions do
        local minion = minions[i]
        if IsValid(minion) and GetDistanceSquared(minion.pos, position) < range * range then
            table_insert(minionsTable, minion)
        end
    end

    return minionsTable
end

local function GetEnemyMinionsInRange(range,position)
    local position = position or myHero.pos
    local minionsTable = {}
    local minions = GetMinions()

    for i = 1, #minions do
        local minion = minions[i]
        if IsValid(minion) and GetDistanceSquared(minion.pos, position) < range * range and minion.team ~= myHero.team then
            table_insert(minionsTable, minion)
        end
    end

    return minionsTable
end

local function GetTurrets()
    local turrets = {}
    if #cachedTurrets > 0 and lastTurretsCachedTime + 5000 > GetTickCount() then
        return cachedTurrets
    end

    local count = Game.TurretCount()
    if count and count > 0 and count < 1000 then
        for i = 1, count do
            local turret = Game.Turret(i)
            if IsValid(turret) then
                table_insert(turrets, turret)
            end
        end
    end

    cachedTurrets = turrets
    lastTurretsCachedTime = GetTickCount()

    return turrets
end

local function GetTurretsInRange(range,position)
    local position = position or myHero.pos
    local turretsTable = {}
    local turrets = GetTurrets()

    for i = 1, #turrets do
        local turret = turrets[i]
        if IsValid(turret) and GetDistanceSquared(turret.pos, position) < range * range then
            table_insert(turretsTable, turret)
        end
    end

    return turretsTable
end



local function ShouldWait()
    return myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading) or (JustEvade and JustEvade.Evading())
end



class "_Predication"

function _Predication:GetPrediction(source,unit,data)
    if coreMenu.prediction:Value() == 1 then
        local pred = GGPrediction:SpellPrediction(data.GGPrediction)
        pred:GetPrediction(unit, source)

        if pred:CanHit(data.GGPrediction.HitChance) then
            return {
                castPosition = pred.CastPosition,
                unitPosition = Vector(pred.UnitPosition)
            }
        end
    end

    if coreMenu.prediction:Value() == 2 then
        local result = PremiumPrediction:GetPrediction(source,unit,data.PremiumPrediction)
        if result and result.CastPos then
            if result.HitChance >= data.PremiumPrediction.hitChance then
                return {
                    castPosition = result.CastPos,
                    unitPosition = result.PredPos
                }
            end
        end
    end

end


class  "_Orbwalker"

function _Orbwalker:__init()
    if _G.SDK then
        self.selection = 1
        self.orbwalker = _G.SDK.Orbwalker
        self.targetSelector = _G.SDK.TargetSelector
    end

    if _G.PremiumOrbwalker then
        self.selection = 2
        self.orbwalker = _G.PremiumOrbwalker
    end

end

function _Orbwalker:CanMove()
    if self.selection == 1 then
        return self.orbwalker:CanMove()
    end

    if self.selection == 2 then
        return self.orbwalker:CanMove()
    end
end

function _Orbwalker:CanAttack()
    if self.selection == 1 then
        return self.orbwalker:CanAttack()
    end

    if self.selection == 2 then
        return self.orbwalker:CanAttack()
    end
end

function _Orbwalker:OnPreMovement(func)
    if self.selection == 1 then
        self.orbwalker:OnPreMovement(func)
    end

    if self.selection == 2 then
        self.orbwalker:OnPreMovement(func)
    end
end

function _Orbwalker:OnPreAttack(func)
    if self.selection == 1 then
        self.orbwalker:OnPreAttack(func)
    end

    if self.selection == 2 then
        self.orbwalker:OnPreAttack(func)
    end
end

function _Orbwalker:OnPostAttack(func)
    if self.selection == 1 then
        self.orbwalker:OnPostAttackTick(func)
    end

    if self.selection == 2 then
        self.orbwalker:OnPostAttack(func)
    end
end

function _Orbwalker:SetAttack(bool)
    if self.selection == 1 then
        self.orbwalker:SetAttack(bool)
    end

    if self.selection == 2 then
        self.orbwalker:SetAttack(bool)
    end
end

function _Orbwalker:SetMovement(bool)
    if self.selection == 1 then
        self.orbwalker:SetMovement(bool)
    end

    if self.selection == 2 then
        self.orbwalker:SetMovement(bool)
    end
end

function _Orbwalker:GetMode()
    if self.selection == 1 then
        return self.orbwalker.Modes[0] and "Combo"
        or self.orbwalker.Modes[1] and "Harass"
        or self.orbwalker.Modes[2] and "LaneClear"
        or self.orbwalker.Modes[3] and "LaneClear"
        or self.orbwalker.Modes[4] and "LastHit"
        or self.orbwalker.Modes[5] and "Flee"

    end

    if self.selection == 2 then
       return self.orbwalker:GetMode()
    end

end

function _Orbwalker:GetTarget(range)
    if self.selection == 1 then
        return self.targetSelector:GetTarget(range)
    end
    if self.selection == 2 then
        return self.orbwalker:GetTarget(range)
    end
end














class "Brand"

function Brand:__init()
    self.Q = {

        PremiumPrediction = {
            hitChance = 0.5,
            speed = 1600,
            range = 1050,
            delay = 0.25,
            radius = 60,
            collision = {"minion","hero","windwall"},
            type = "linear"
        },
        GGPrediction = {
            HitChance = 3,
            Type = 0,
            Delay = 0.25,
            Radius = 60,
            Range = 1050,
            Speed = 1600,
            Collision = true,
            MaxCollision = 0,
            CollisionTypes = {GGPrediction.COLLISION_MINION, GGPrediction.COLLISION_ENEMYHERO, GGPrediction.COLLISION_YASUOWALL},--{0,2,3},
            UseBoundingRadius = true
        }
    }

    self.W = {
        PremiumPrediction = {
            hitChance = 0.5,
            speed = math.huge,
            range = 900,
            delay = 0.9,
            radius = 240,
            collision = nil,
            type = "circular"
        },
        GGPrediction = {
            Type = 1,
            Delay = 0.9,
            Radius = 240,
            Range = 900,
            Speed = math.huge,
            Collision = false,
            -- MaxCollision = 0,
            -- CollisionTypes = {GGPrediction.COLLISION_MINION,GGPrediction.COLLISION_ENEMYHERO,GGPrediction.COLLISION_YASUOWALL},
            UseBoundingRadius = false,
            HitChance = 3
        }

    }

    self.E = {range = 625}
    self.R = {range = 750}

    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0

    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

end

function Brand:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesBrand", name = "[14Series] Brand"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "W", name = "use W", value = true})
        self.tyMenu.combo:MenuElement({id = "EQ", name = "use EQ", value = true})
        self.tyMenu.combo:MenuElement({id = "R", name = "use R", value = true})
        self.tyMenu.combo:MenuElement({id = "RCount", name = "Min R target", value = 2, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.tyMenu.harass:MenuElement({id = "W", name = "use W", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "auto", name = "Auto"})
        self.tyMenu.auto:MenuElement({id = "Q", name = "auto Q to stun", value = true})
        self.tyMenu.auto:MenuElement({id = "E", name = "auto E on 2 Buff stack", value = true})
        self.tyMenu.auto:MenuElement({type = MENU, id = "antiDash", name = "EQ Anti Dash Target"})
        OnEnemyHeroLoad(function(hero) self.tyMenu.auto.antiDash:MenuElement({id = hero.networkID, name = hero.charName, value = true}) end)

    self.tyMenu:MenuElement({type = MENU, id = "pred", name = "Prediction Setting"})
        self.tyMenu.pred:MenuElement({name = " ", drop = {"Q Prediction"}})
        self.tyMenu.pred:MenuElement({id = "QGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.Q.GGPrediction.HitChance = value
            print("changed Q GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "Qperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.Q.PremiumPrediction.hitChance = value
            print("changed Q Premium Pred HitChance to "..value)
        end})


        self.tyMenu.pred:MenuElement({name = " ", drop = {"W Prediction"}})
        self.tyMenu.pred:MenuElement({id = "WGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.W.GGPrediction.HitChance = value
            print("changed W GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "Wperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.W.PremiumPrediction.hitChance = value
            print("changed W Premium Pred HitChance to "..value)
        end})


    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

-- local predtemp = nil
function Brand:Draw()

    -- if predtemp then
    --     Draw.Circle(predtemp.castPosition, 240 ,Draw.Color(255 ,0xE1,0xA0,0x00))
    --     Draw.Circle(predtemp.unitPosition, 10 ,Draw.Color(255 ,0xE1,0xA0,0x00))

    -- end

    if myHero.health == 0 then return  end

    if self.tyMenu.Drawing.Q:Value() then
        Draw.Circle(myHero.pos, 1050,Draw.Color(255 ,0xE1,0xA0,0x00))
    end

    if self.tyMenu.Drawing.W:Value() then
        Draw.Circle(myHero.pos, 900,Draw.Color(255 ,0xE1,0xA0,0x00))
    end

    if self.tyMenu.Drawing.E:Value() then
        Draw.Circle(myHero.pos, 625,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
    if self.tyMenu.Drawing.R:Value() then
        Draw.Circle(myHero.pos, 750,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
end

function Brand:Tick()
    if ShouldWait() then return end
    if orbwalker:GetMode() == "Combo" then
        self:Combo()
    end

    if orbwalker:GetMode() == "Harass" then
        self:Harass()
    end

    self:Auto()

end

function Brand:Combo()
    local target = orbwalker:GetTarget(625)
    if target and self.tyMenu.combo.EQ:Value()
    and Ready(_Q) and Ready(_E)
    and self.lastE + 500 < GetTickCount() then
        local result = prediction:GetPrediction(myHero,target,self.Q)
        if result and result.castPosition then
            if Control.CastSpell(HK_E, target) then
                self.lastE = GetTickCount()
            end
        end
    end

    target = orbwalker:GetTarget(900)
    if target and self.tyMenu.combo.W:Value() then
        self:CastW(target)
    end


    if self.tyMenu.combo.R:Value() and Ready(_R) and self.lastR  + 1000 < GetTickCount() then
        local enemys = GetEnemyHeroes()
        for i = 1 , #enemys do
            local enemy = enemys[i]
            if IsValid(enemy) and GetDistanceSquared(enemy.pos,myHero.pos) < 750 * 750 then
                if #GetEnemysInRange(480,enemy.pos) >= self.tyMenu.combo.RCount:Value() then
                    if Control.CastSpell(HK_R, enemy) then
                        self.lastR = GetTickCount()
                    end
                end
            end
        end
    end

end

function Brand:Harass()
    local target = orbwalker:GetTarget(900)
    if target and self.tyMenu.harass.W:Value() then
        self:CastW(target)
    end
end

function Brand:Auto()
    local enemys = GetEnemyHeroes()
    for i = 1 , #enemys do
        local enemy = enemys[i]

        if IsValid(enemy) then
            local distanceSqr = GetDistanceSquared(myHero.pos, enemy.pos)
            if Ready(_Q) and self.tyMenu.auto.Q:Value() and self.lastQ + 500 < GetTickCount() then
                local buff = Hasbuff(enemy, "BrandAblaze")
                if buff then
                    local result = prediction:GetPrediction(myHero,enemy,self.Q)
                    if result and result.castPosition then
                        local time = 0.25 + math.sqrt(GetDistanceSquared(myHero.pos,result.castPosition) / (1600*1600))
                        if buff.duration > time then
                            if Control.CastSpell(HK_Q, result.castPosition) then
                                self.lastQ = GetTickCount()
                            end
                        end
                    end
                end
            end

            if Ready(_E) and self.tyMenu.auto.E:Value()
            and self.lastE + 500 < GetTickCount() and distanceSqr < 625*625 then
                local buff = Hasbuff(enemy, "BrandAblaze")
                if buff and buff.count ==2 and buff.duration > 0.25 then
                    if Control.CastSpell(HK_E, enemy) then
                        self.lastE = GetTickCount()
                    end
                end
            end

            if self.tyMenu.auto.antiDash[enemy.networkID]
            and self.tyMenu.auto.antiDash[enemy.networkID]:Value()
            and enemy.pathing.isDashing and enemy.pathing.dashSpeed>0
            and Ready(_Q) and Ready(_E)
            and self.lastE+350 < GetTickCount() and distanceSqr < 625*625 then
                if Control.CastSpell(HK_E, enemy) then
                    self.lastE = GetTickCount()
                end
            end
        end
    end
end

function Brand:CastW(target)
    if Ready(_W) and self.lastW + 600 < GetTickCount() then
        local result = prediction:GetPrediction(myHero,target,self.W)
        if result and result.castPosition then
            -- predtemp = result
            if Control.CastSpell(HK_W, result.castPosition) then
                self.lastW = GetTickCount()
            end
        end
    end
end

class "FiddleSticks"

function FiddleSticks:__init()
    self.Q = {
        range = 570
    }
    self.W = {
        range = 650
    }

    self.E = {
        PremiumPrediction = {
            hitChance = 0.5,
            speed = math.huge,
            range = 850,
            delay = 0.4,
            radius = 120,
            -- collision = {"minion","hero","windwall"},
            type = "circular"
        },

        GGPrediction = {
            HitChance = 3,
            Type = 1,
            Delay = 0.4,
            Radius = 120,
            Range = 850,
            Speed = math.huge,
            Collision = false,
            -- MaxCollision = 0,
            -- CollisionTypes = {GGPrediction.COLLISION_YASUOWALL},
            UseBoundingRadius = false
        }
    }

    self.R = {
        range = 780
    }

    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0

    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

end

function FiddleSticks:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesFiddleSticks", name = "[14Series] FiddleSticks"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
    self.tyMenu.combo:MenuElement({id = "Q", name = "use Q", value = true})
    self.tyMenu.combo:MenuElement({id = "W", name = "use W", value = true})
    self.tyMenu.combo:MenuElement({id = "E", name = "use E", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
    self.tyMenu.harass:MenuElement({id = "E", name = "use E", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "auto", name = "Auto"})
    self.tyMenu.auto:MenuElement({type = MENU, id = "antiDash", name = "Q Anti Dash Target"})
    OnEnemyHeroLoad(function(hero) self.tyMenu.auto.antiDash:MenuElement({id = hero.networkID, name = hero.charName, value = true}) end)

    self.tyMenu:MenuElement({type = MENU, id = "pred", name = "Prediction Setting"})
    self.tyMenu.pred:MenuElement({name = " ", drop = {"E Prediction"}})
    self.tyMenu.pred:MenuElement({id = "EGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
        self.E.GGPrediction.HitChance = value
        print("changed E GG Pred HitChance to "..value)
    end})

    self.tyMenu.pred:MenuElement({id = "Eperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
        self.E.PremiumPrediction.hitChance = value
        print("changed E Premium Pred HitChance to "..value)
    end})


    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = false})
    self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = false})

end

function FiddleSticks:Draw()
    if myHero.health == 0 then return  end

    if self.tyMenu.Drawing.Q:Value()  then
        Draw.Circle(myHero.pos, 570,Draw.Color(255 ,0xE1,0xA0,0x00))
    end

    if self.tyMenu.Drawing.W:Value()  then
        Draw.Circle(myHero.pos, 650,Draw.Color(255 ,0xE1,0xA0,0x00))
    end

    if self.tyMenu.Drawing.E:Value() then
        Draw.Circle(myHero.pos, 850,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
    if self.tyMenu.Drawing.R:Value() then
        Draw.Circle(myHero.pos, 780,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
end

function FiddleSticks:Tick()
    if ShouldWait() then return end

    self:Auto()

    if myHero.activeSpell.valid and myHero.activeSpell.name == "FiddleSticksW" then
        orbwalker:SetAttack(false)
        orbwalker:SetMovement(false)
        return
    else
        orbwalker:SetAttack(true)
        orbwalker:SetMovement(true)
    end


    if orbwalker:GetMode() == "Combo" then
        self:Combo()
    end

    if orbwalker:GetMode() == "Harass" then
        self:Harass()
    end


end

function FiddleSticks:Combo()
    local target = orbwalker:GetTarget(850)
    if target and self.tyMenu.combo.E:Value() then
        self:CastE(target)
    end

    local target = orbwalker:GetTarget(570)
    if target and self.tyMenu.combo.Q:Value() then
        if Ready(_Q) and self.lastQ + 600 < GetTickCount() then
            if Control.CastSpell(HK_Q, target.pos) then
                self.lastQ = GetTickCount()
            end
        end
    end

    local target = orbwalker:GetTarget(650)
    if target and self.tyMenu.combo.W:Value() then
        if Ready(_W) and not Ready(_Q) and self.lastW + 600 < GetTickCount() then
            if Control.CastSpell(HK_W) then
                self.lastW = GetTickCount()
            end
        end
    end

end

function FiddleSticks:Harass()
    local target = orbwalker:GetTarget(850)
    if target and self.tyMenu.harass.E:Value() then
        self:CastE(target)
    end
end

function FiddleSticks:Auto()
    local enemys = GetEnemyHeroes()
    for i = 1 , #enemys do
        local enemy = enemys[i]

        if IsValid(enemy) then
            if self.tyMenu.auto.antiDash[enemy.networkID]
            and self.tyMenu.auto.antiDash[enemy.networkID]:Value()
            and enemy.pathing.isDashing and enemy.pathing.dashSpeed>0
            and Ready(_Q) and self.lastQ + 600 < GetTickCount()
            and GetDistanceSquared(myHero.pos, enemy.pos) < 570 * 570 then
                if Control.CastSpell(HK_Q, enemy) then
                    self.lastQ = GetTickCount()
                end
            end
        end
    end
end

function FiddleSticks:CastE(target)
    if Ready(_E) and self.lastE + 600 < GetTickCount() then
        local result = prediction:GetPrediction(myHero,target,self.E)
        if result and result.castPosition then
            if Control.CastSpell(HK_E, result.castPosition) then
                self.lastE = GetTickCount()
            end
        end
    end
end

class "Vayne"

function Vayne:__init()
    require "2DGeometry"
    require 'MapPositionGOS'

    self.Q = {range = 300, speed = 830}

    self.E = {

        PremiumPrediction = {
            hitChance = 0.25,
            speed = 2200,
            range = 650,
            delay = 0.25,
            radius = 60,
            collision = {"windwall"},
            type = "linear"
        },
        GGPrediction = {
            HitChance = 2,
            Type = 0,
            Delay = 0.25,
            Radius = 60,
            Range = 650,
            Speed = 2200,
            Collision = true,
            MaxCollision = 0,
            CollisionTypes = {GGPrediction.COLLISION_YASUOWALL},
            UseBoundingRadius = true
        }
    }

    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0

    self.attackTarget = nil
    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
    orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
    orbwalker:OnPostAttack(function() self:OnPostAttack() end)
end

function Vayne:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesVayne", name = "[14Series] Vayne"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
            self.tyMenu.combo:MenuElement({id = "Q", name = "Q AA reset", value = true})
            self.tyMenu.combo:MenuElement({id = "QToE", name = "Q To E position", value = true})
            self.tyMenu.combo:MenuElement({id = "E", name = "E", value = true})
            self.tyMenu.combo:MenuElement({id = "blockRAA", name = "Block AA if self invisible", value = false})

        self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
            self.tyMenu.harass:MenuElement({id = "Q", name = "Q AA reset", value = true})
            self.tyMenu.harass:MenuElement({id = "EStun", name = "use E stun", value = true})
            self.tyMenu.harass:MenuElement({id = "EStack", name = "use E If Target Have 2 W Stacks", value = true})

        self.tyMenu:MenuElement({type = MENU, id = "waveClear", name = "Wave Clear"})
            self.tyMenu.waveClear:MenuElement({id = "Q", name = "Q AA reset", value = false})


    self.tyMenu:MenuElement({type = MENU, id = "auto", name = "Auto"})
        self.tyMenu.auto:MenuElement({id = "antiMelee", name = "[E] Anti-Melee", value = false})
        self.tyMenu.auto:MenuElement({type = MENU, id = "antiDash", name = "EQ Anti Dash Target"})
        OnEnemyHeroLoad(function(hero) self.tyMenu.auto.antiDash:MenuElement({id = hero.networkID, name = hero.charName, value = true}) end)

    self.tyMenu:MenuElement({type = MENU, id = "misc", name = "Misc"})
        self.tyMenu.misc:MenuElement({id = "Qmode", name ="Q mode" , drop = {"To Side", "To Cursor"}})
        self.tyMenu.misc:MenuElement({id = "Erange", name = "E range", value = 400, min = 1, max = 475, step = 1})


    self.tyMenu:MenuElement({type = MENU, id = "pred", name = "Prediction Setting"})
        self.tyMenu.pred:MenuElement({name = " ", drop = {"E Prediction"}})
        self.tyMenu.pred:MenuElement({id = "EGG", name = "GG Pred HitChance", value = 2, min = 2, max = 4, step = 1, callback = function(value)
            self.E.GGPrediction.HitChance = value
            print("changed E GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "Eperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.E.PremiumPrediction.hitChance = value
            print("changed E Premium Pred HitChance to "..value)
        end})


    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})

end

function Vayne:Draw()
    if myHero.health == 0 then return  end

    if self.tyMenu.Drawing.Q:Value()  then
        Draw.Circle(myHero.pos, 300,Draw.Color(255 ,0xE1,0xA0,0x00))
    end

    if self.tyMenu.Drawing.E:Value()  then
        Draw.Circle(myHero.pos, 650,Draw.Color(255 ,0xE1,0xA0,0x00))
    end

end

function Vayne:Tick()
    if ShouldWait() then return end

    if orbwalker:GetMode() == "Combo" then
        self:Combo()
    end

    if orbwalker:GetMode() == "Harass" then
        self:Harass()
    end

    local ok, err = pcall(function()
        self:Auto()
    end)
    if not ok then
        print(err)
    end

end

function Vayne:OnPreAttack(args)
    if args.Process then
        self.attackTarget = args.Target
    end
end

function Vayne:OnPostAttack()
    if self.attackTarget then
        if Ready(_Q) and self.lastQ + 500 < GetTickCount() and orbwalker:CanMove() then
            if orbwalker:GetMode() == "Combo" and self.tyMenu.combo.Q:Value()
            or orbwalker:GetMode() == "Harass" and self.tyMenu.harass.Q:Value() and self.attackTarget.type == myHero.type
            or orbwalker:GetMode() == "LaneClear" and self.tyMenu.waveClear.Q:Value()
            then

                if self.tyMenu.misc.Qmode:Value() == 2 then
                    if Control.CastSpell(HK_Q) then
                        self.lastQ = GetTickCount()
                    end
                end

                if self.tyMenu.misc.Qmode:Value() == 1 then
                    local root1, root2 = CircleCircleIntersection(myHero.pos, self.attackTarget.pos, myHero.range , myHero.range-100)
                    if root1 and root2 then
                        local closest = GetDistanceSquared(root1, mousePos) < GetDistanceSquared(root2, mousePos) and root1 or root2
                        if Control.CastSpell(HK_Q,myHero.pos:Extended(closest, 300)) then
                            self.lastQ = GetTickCount()
                        end
                    end
                end

            end
        end
    end
end

function Vayne:Combo()
    local target = orbwalker:GetTarget(650)
    if target and self.tyMenu.combo.E:Value() then
        self:CastEStun(target)
    end

    if self.tyMenu.combo.blockRAA:Value() then
        if Hasbuff(myHero, "vaynetumblefade") then
            orbwalker:SetAttack(false)
        else
            orbwalker:SetAttack(true)
        end
    end

    local target = orbwalker:GetTarget(900)
    if target and self.tyMenu.combo.QToE:Value() then
        if Ready(_Q) and Ready(_E) and self.lastQ + 500 < GetTickCount() and orbwalker:CanMove() then

            local startPos = myHero.pos
            local endPos =  myHero.pos:Extended(Game.mousePos(), 300)

            for angle = 0, 360, 10 do
                local point = Rotate2D(startPos,endPos, math.rad(angle))
                if GetDistance(point,target.pos) < 650 -100 then
                    if not MapPosition:intersectsWall(LineSegment(point,myHero.pos)) then
                        local extendPos = target.pos:Extended(point,-self.tyMenu.misc.Erange:Value())

                        local lineE = LineSegment(point,extendPos)
                        local angle = AngleBetween(myHero.pos,target.pos, point)

                        if angle <160 and MapPosition:intersectsWall(lineE)  then
                            if Control.CastSpell(HK_Q,point) then
                                self.lastQ = GetTickCount()
                            end
                        end
                    end
                end
            end
        end
    end


end

function Vayne:Harass()
    local target = orbwalker:GetTarget(650)
    if target and self.tyMenu.harass.EStun:Value() then
        self:CastEStun(target)
    end

    if target and self.tyMenu.harass.EStack:Value() then
        if Ready(_E) and self.lastE + 500 < GetTickCount() and orbwalker:CanMove() then
            local buff = Hasbuff(target, "VayneSilveredDebuff")
            if buff and buff.count == 2 then
                if Control.CastSpell(HK_E,target) then
                    self.lastE = GetTickCount()
                end
            end
        end
    end
end

function Vayne:CastEStun(target)
    if Ready(_E) and self.lastE + 500 < GetTickCount() then
        local result = prediction:GetPrediction(myHero,target,self.E)
        if result and result.unitPosition then
            local extendPos = result.unitPosition:Extended(myHero.pos,-self.tyMenu.misc.Erange:Value())
            local lineE = LineSegment(result.unitPosition,extendPos)
            if MapPosition:intersectsWall(lineE) then
                if Control.CastSpell(HK_E,target) then
                    self.lastE = GetTickCount()
                end
            end
        end
    end
end

function Vayne:Auto()
    if Ready(_E) and self.lastE + 500 < GetTickCount() then

        local enemys = GetEnemyHeroes()
        for i = 1 , #enemys do
            local enemy = enemys[i]
            if IsValid(enemy) then
                if self.tyMenu.auto.antiDash[enemy.networkID]
                and self.tyMenu.auto.antiDash[enemy.networkID]:Value()
                and enemy.pathing.isDashing and enemy.pathing.dashSpeed>0
                and GetDistanceSquared(myHero.pos, enemy.pos) < 650 * 650 then
                    if Control.CastSpell(HK_E, enemy) then
                        self.lastE = GetTickCount()
                        return
                    end
                end

                if self.tyMenu.auto.antiMelee:Value() and orbwalker:CanMove() then
                    if enemy.range < 300 and GetDistanceSquared(myHero.pos, enemy.pos) < 300*300 then
                        if Control.CastSpell(HK_E, enemy) then
                            self.lastE = GetTickCount()
                            return
                        end
                    end
                end
            end
        end
    end
end

class "Senna"

function Senna:__init()
    self.Q1 = {
        range = function() return myHero.range + myHero.boundingRadius + myHero.boundingRadius end
    }

    self.Q2 = {
        PremiumPrediction = {
            hitChance = 0.5,
            speed = math.huge,
            range = 1300,
            delay = 0.4,
            radius = 50,
            collision = nil,
            type = "linear"
        },
        GGPrediction = {
            HitChance = 3,
            Type = 0,
            Delay = 0.4,
            Radius = 50,
            Range = 1300,
            Speed = math.huge,
            Collision = false,
            UseBoundingRadius = true
        }
    }

    self.W = {
        PremiumPrediction = {
            hitChance = 0.25,
            speed = 1000,
            range = 1100,
            delay = 0.25,
            radius = 60,
            collision = {"minion","windwall"},
            type = "linear"
        },

        GGPrediction = {
            HitChance = 3,
            Type = 0,
            Delay = 0.25,
            Radius = 60,
            Range = 1100,
            Speed = 1000,
            Collision = true,
            MaxCollision = 0,
            CollisionTypes = {GGPrediction.COLLISION_MINION,GGPrediction.COLLISION_YASUOWALL}, --{0,3},
            UseBoundingRadius = true
        }
    }

    self.R = {
        PremiumPrediction = {
            hitChance = 0.4,
            speed = 20000,
            range = math.huge,
            delay = 1,
            radius = 80,
            -- collision = {"minion","windwall"},
            type = "linear"
        },

        GGPrediction = {
            HitChance = 3,
            Type = 0,
            Delay = 1,
            Radius = 80,
            Range = math.huge,
            Speed = 20000,
            Collision = false,
            -- MaxCollision = 0,
            -- CollisionTypes = {0,3},
            UseBoundingRadius = true
        }
    }
    self.recalling = {}
    self.EnemyBase = nil
    for i = 1, Game.ObjectCount() do
        local base = Game.Object(i)
        if base.isEnemy and base.type == Obj_AI_SpawnPoint then
            self.EnemyBase = base
            break
        end
    end

    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0

    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
    Callback.Add("ProcessRecall", function(...) self:OnProcessRecall(...) end)

end

function Senna:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesSenna", name = "[14Series] Senna"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "Q", name = "use Q", value = true})
        self.tyMenu.combo:MenuElement({id = "W", name = "use W", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.tyMenu.harass:MenuElement({id = "Qexternal", name = "use Q External", value = true})
        self.tyMenu.harass:MenuElement({id = "Q", name = "use Q", value = true})
        self.tyMenu.harass:MenuElement({id = "W", name = "use W", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "ks", name = "KS"})
        self.tyMenu.ks:MenuElement({id = "Qexternal", name = "Q External KS", value = true})
        self.tyMenu.ks:MenuElement({id = "R", name = "R KS", value = true})
        self.tyMenu.ks:MenuElement({id = "MinRange",name = "Min R Range",value = 1300, min = 1,max = 2000,step = 1})
        self.tyMenu.ks:MenuElement({id = "MaxRange",name = "Max R Range",value = 5000, min = 1,max = 20000,step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "base", name = "BastULT"})
        self.tyMenu.base:MenuElement({id = "ping",name = "Your Ping [Very Important]",value = 60,min = 1,max = 300,step = 1})
        self.tyMenu.base:MenuElement({id = "R", name = "R BaseUlt", value = true})
        self.tyMenu.base:MenuElement({id = "Disable",name = "Disable BaseUlt If Combo Key",value = true})

    self.tyMenu:MenuElement({type = MENU, id = "heal", name = "Auto Heal"})
        self.tyMenu.heal:MenuElement({id = "Q", name = "Q Auto Heal Ally", value = true})
        self.tyMenu.heal:MenuElement({id = "HP",name = "If Ally HP < X %",value = 20,min = 1,max = 101,step = 1})


    self.tyMenu:MenuElement({type = MENU, id = "pred", name = "Prediction Setting"})
        self.tyMenu.pred:MenuElement({name = " ", drop = {"Q Prediction"}})
        self.tyMenu.pred:MenuElement({id = "QGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.Q2.GGPrediction.HitChance = value
            print("changed Q GG Pred HitChance to "..value)
        end})

        self.tyMenu.pred:MenuElement({id = "Qperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.Q2.PremiumPrediction.hitChance = value
            print("changed Q Premium Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({name = " ", drop = {"W Prediction"}})
        self.tyMenu.pred:MenuElement({id = "WGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.W.GGPrediction.HitChance = value
            print("changed W GG Pred HitChance to "..value)
        end})

        self.tyMenu.pred:MenuElement({id = "Qperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.W.PremiumPrediction.hitChance = value
            print("changed W Premium Pred HitChance to "..value)
        end})
    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q",name = "Draw [Q] Range",value = true})
        self.tyMenu.Drawing:MenuElement({id = "W",name = "Draw [W] Range",value = true})

end

function Senna:Draw()
    if myHero.dead then return end

    if self.tyMenu.Drawing.Q:Value()  then
        Draw.Circle(myHero.pos, 1300, Draw.Color(255, 0xE1,0xA0,0x00))
    end

    if self.tyMenu.Drawing.W:Value() then
        Draw.Circle(myHero.pos, 1100, Draw.Color(255, 0xE1,0xA0,0x00))
    end
end

function Senna:Tick()
    self:SetQDelay()

    if ShouldWait() then return end

    if orbwalker:GetMode() == "Combo" then
        self:Combo()
    end

    if orbwalker:GetMode() == "Harass" then
        self:Harass()
    end

    self:KS()
    self:BaseUlt()
    self:AutoHeal()
end


function Senna:SetQDelay()
    if myHero.activeSpell.valid and myHero.activeSpell.name == "SennaQCast" then
        self.Q2.PremiumPrediction.delay = myHero.activeSpell.windup
        self.Q2.GGPrediction.Delay = myHero.activeSpell.windup
    end
end

function Senna:Combo()
    local target = orbwalker:GetTarget(self.Q1.range())
    if target  and self.tyMenu.combo.Q:Value() then
        self:CastQ(target)
    end

    local target = orbwalker:GetTarget(1100)
    if target and self.tyMenu.combo.W:Value() then
        self:CastW(target)
    end

end

function Senna:Harass()

    local target = orbwalker:GetTarget(1300)
    if target  and self.tyMenu.combo.Q:Value() then
        self:CastQExternal(target)
    end

    local target = orbwalker:GetTarget(1100)
    if target and self.tyMenu.harass.W:Value() then
        self:CastW(target)
    end

    local target = orbwalker:GetTarget(self.Q1.range())
    if target  and self.tyMenu.harass.Q:Value() then
        self:CastQ(target)
    end
end

function Senna:KS()
    if self.tyMenu.ks.Qexternal:Value() then
        local enemys = GetEnemysInRange(1300)
        for i = 1 , #enemys do
            local enemy = enemys[i]
            if (enemy.health + enemy.shieldAD) < self:GetQDamage(enemy) then
                self:CastQExternal(enemy)
            end
        end
    end

    if self.tyMenu.ks.R:Value() and Ready(_R) and self.lastR + 2000 < GetTickCount()  then
        local enemys = GetEnemyHeroes()
        for i = 1, #enemys do
            local enemy = enemys[i]
            if IsValid(enemy) and (enemy.health + enemy.shieldAD) < self:GetRDamage(enemy) then
                if GetDistanceSquared(myHero.pos,enemy.pos) <  self.tyMenu.ks.MaxRange:Value() * self.tyMenu.ks.MaxRange:Value()
                and GetDistanceSquared(myHero.pos,enemy.pos) >  self.tyMenu.ks.MinRange:Value() * self.tyMenu.ks.MinRange:Value()
                and #GetAllysInRange(600,enemy.pos) == 0 then
                    local result = prediction:GetPrediction(myHero,enemy,self.R)
                    if result and result.castPosition then
                        if Control.CastSpell(HK_R, result.castPosition) then
                            self.lastR = GetTickCount()
                        end
                    end
                end
            end
        end
    end
end

function Senna:AutoHeal()
    if self.tyMenu.heal.Q:Value() and Ready(_Q) and self.lastQ + 600 < GetTickCount() then
        local allys = GetAllysInRange(self.Q1.range())
        for i = 1, #allys do
            local ally = allys[i]
            local percetHealth = ally.health / ally.maxHealth*100
            if ally ~= myHero and percetHealth < self.tyMenu.heal.HP:Value() then
                if Control.CastSpell(HK_Q, ally.pos) then
                    self.lastQ = GetTickCount()
                end
            end
        end
    end
end

function Senna:BaseUlt()
    if self.tyMenu.base.Disable:Value() and orbwalker:GetMode() == "Combo" then return end

    if self.tyMenu.base.R:Value() and Ready(_R) and self.lastR + 2000 < GetTickCount() then
        for k, recallObj in pairs(self.recalling) do
            if recallObj.isRecalling then
                local leftTime = recallObj.starttime - GetTickCount() + recallObj.info.totalTime
                local distance = self.EnemyBase.pos:DistanceTo(myHero.pos)
                local hittime = distance / 20000 + 1 +
                                    self.tyMenu.base.ping:Value() / 1000

                if hittime * 1000 - leftTime > 0 then
                    local PredictedHealth =
                        recallObj.hero.health + recallObj.hero.hpRegen * hittime
                    if PredictedHealth < self:GetRDamage(recallObj.hero) then
                        local castPosMM = self.EnemyBase.pos:ToMM()
                        Control.SetCursorPos(castPosMM.x, castPosMM.y)
                        Control.KeyDown(HK_R)
                        Control.KeyUp(HK_R)
                        self.lastR = GetTickCount()
                    end
                end
            end
        end
    end
end

function Senna:OnProcessRecall(Object, recallProc)
    if Object.team == myHero.team then return end

    local recallData = {}

    if recallProc.isStart then
        recallData.hero = Object
        recallData.info = recallProc
        recallData.starttime = GetTickCount()
        recallData.isRecalling = true
    else
        recallData.isRecalling = false
    end

    self.recalling[Object.networkID] = recallData
end


function Senna:GetQDamage(target)
    local baseDmg = ({50, 80, 110, 140, 170})[myHero:GetSpellData(_Q).level]
    local bonusDmg = myHero.bonusDamage * 0.5
    local passiveDmg = myHero.totalDamage * 0.2

    local value = baseDmg + bonusDmg + passiveDmg

    return CalcPhysicalDamage(myHero, target, value)

end

function Senna:GetRDamage(target)
    local baseDmg = ({250, 375, 500})[myHero:GetSpellData(_R).level]
    local bonusDmg = myHero.bonusDamage
    local bonusAP = myHero.ap * 0.4

    local value = baseDmg + bonusDmg + bonusAP

    return CalcPhysicalDamage(myHero, target, value)
end

function Senna:CastQExternal(target)
    if Ready(_Q) and self.lastQ + 600 < GetTickCount() and orbwalker:CanMove() then
        local result = prediction:GetPrediction(myHero,target,self.Q2)
        if result and result.unitPosition then
            local targetPos = myHero.pos:Extended(result.unitPosition,1300)

            local allyHeros = GetAllysInRange(self.Q1.range())
            local minions = GetMinionsInRange(self.Q1.range())
            local turrets = GetTurretsInRange(self.Q1.range())
            local enemys = GetEnemysInRange(self.Q1.range())

            local objectTable = tableMerge(allyHeros,minions,turrets,enemys)

            for i = 1, #objectTable do
                local object = objectTable[i]
                local objectPos = myHero.pos:Extended(object.pos, 1300)
                if GetDistanceSquared(targetPos, objectPos) <= (50 + target.boundingRadius) ^ 2 then
                    if Control.CastSpell(HK_Q, object.pos) then
                        self.lastQ = GetTickCount()
                    end
                end
            end
        end
    end
end

function Senna:CastQ(target)
    if Ready(_Q) and self.lastQ + 600 < GetTickCount() and orbwalker:CanMove() then
        if Control.CastSpell(HK_Q, target.pos) then
            self.lastQ = GetTickCount()
        end
    end
end

function Senna:CastW(target)
    if Ready(_W) and self.lastW + 600 < GetTickCount() then
        local result = prediction:GetPrediction(myHero,target,self.W)
        if result and result.castPosition then
            if Control.CastSpell(HK_W, result.castPosition) then
                self.lastW = GetTickCount()
            end
        end
    end
end

class "Nunu"

function Nunu:__init()
    self.Q = {
        range = 245
    }

    self.E = {
        PremiumPrediction = {
            hitChance = 0.4,
            speed = 2000,
            range = 690,
            delay = 0,
            radius = 40,
            collision = {"minion","windwall"},
            type = "linear"
        },

        GGPrediction = {
            HitChance = 2,
            Type = 0,
            Delay = 0,
            Radius = 40,
            Range = 690,
            Speed = 2000,
            Collision = true,
            MaxCollision = 0,
            CollisionTypes = {GGPrediction.COLLISION_MINION,GGPrediction.COLLISION_YASUOWALL}, --{0,3},
            UseBoundingRadius = true
        }
    }

    self.R = {
        range = 650
    }

    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0

    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

end

function Nunu:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesNunu", name = "[14Series] Nunu"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "Q", name = "use Q", value = true})
        self.tyMenu.combo:MenuElement({id = "E", name = "use E", value = true})
        self.tyMenu.combo:MenuElement({id = "R", name = "use R", value = true})
        self.tyMenu.combo:MenuElement({id = "RCount", name = "Min R target", value = 3, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "waveClear", name = "Wave Clear"})
        self.tyMenu.waveClear:MenuElement({id = "Q", name = "use Q if can kill", value = true})
        self.tyMenu.waveClear:MenuElement({id = "E", name = "use E", value = true})


    self.tyMenu:MenuElement({type = MENU, id = "pred", name = "Prediction Setting"})
        self.tyMenu.pred:MenuElement({name = " ", drop = {"E Prediction"}})
        self.tyMenu.pred:MenuElement({id = "EGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.E.GGPrediction.HitChance = value
            print("changed E GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "Eperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.E.PremiumPrediction.hitChance = value
            print("changed E Premium Pred HitChance to "..value)
        end})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Nunu:Draw()
    if myHero.health == 0 then return  end

    if self.tyMenu.Drawing.Q:Value() then
        Draw.Circle(myHero.pos, 245,Draw.Color(255 ,0xE1,0xA0,0x00))
    end

    if self.tyMenu.Drawing.E:Value() then
        Draw.Circle(myHero.pos, 690,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
    if self.tyMenu.Drawing.R:Value() then
        Draw.Circle(myHero.pos, 650,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
end

function Nunu:Tick()
    if ShouldWait() then return end
    if myHero.activeSpell.name == "NunuR" then
        orbwalker:SetAttack(false)
        orbwalker:SetMovement(false)
        return
    else
        orbwalker:SetAttack(true)
        orbwalker:SetMovement(true)
    end

    if orbwalker:GetMode() == "Combo" then
        self:Combo()
    end
    if orbwalker:GetMode() == "LaneClear" then
        self:WaveClear()
    end
end

function Nunu:Combo()
    if self.tyMenu.combo.Q:Value() then
        local target = orbwalker:GetTarget(245)
        if target and Ready(_Q) and self.lastQ + 1000 < GetTickCount() and orbwalker:CanMove() then
            if Control.CastSpell(HK_Q, target.pos) then
                self.lastQ = GetTickCount()
            end
        end
    end

    if self.tyMenu.combo.E:Value() then
        local target = orbwalker:GetTarget(690)
        if target then
            self:CastE(target)
        end
    end

    if self.tyMenu.combo.R:Value() then
        if Ready(_R) and self.lastR + 1000 < GetTickCount() then
            local enemys = GetEnemysInRange(650)
            if #enemys >= self.tyMenu.combo.RCount:Value() then
                if Control.CastSpell(HK_R) then
                    self.lastR = GetTickCount()
                    orbwalker:SetAttack(false)
                    orbwalker:SetMovement(false)
                end
            end
        end
    end
end

function Nunu:WaveClear()
    local QJungleObject = {
        ["SRU_Dragon_Elder"] = true,
        ["SRU_Dragon_Air"] = true,
        ["SRU_Dragon_Earth"] = true,
        ["SRU_Dragon_Fire"] = true,
        ["SRU_Dragon_Water"] = true,
        ["SRU_Red"] = true,
        ["SRU_Blue"] = true,
        ["SRU_Gromp"] = true,
        ["SRU_Murkwolf"] = true,
        ["SRU_Razorbeak"] = true,
        ["SRU_Krug"] = true,
        ["Sru_Crab"] = true,
        ["SRU_RiftHerald"] = true,
        ["SRU_Baron"] = true
    }
    if self.tyMenu.waveClear.Q:Value() then
        if Ready(_Q) and self.lastQ + 1000 < GetTickCount() and orbwalker:CanMove() then
            local minions = GetEnemyMinionsInRange(245)
            for i = 1, #minions do
                local minion = minions[i]
                if QJungleObject[minion.charName] then
                    if minion.health < self:GetQDamage(minion) then
                        if Control.CastSpell(HK_Q,minion) then
                            self.lastQ = GetTickCount()
                        end
                    end
                end
            end
        end
    end

    if self.tyMenu.waveClear.E:Value() then
        if Ready(_E) and self.lastE + 250 < GetTickCount() and orbwalker:CanMove() then
            local minions = GetEnemyMinionsInRange(690)
            if minions[1] then
                if Control.CastSpell(HK_E,minions[1]) then
                    self.lastE = GetTickCount()
                end
            end
        end
    end
end

function Nunu:CastE(target)
    if Ready(_E) and self.lastE + 250 < GetTickCount() then
        local result = prediction:GetPrediction(myHero,target,self.E)
        if result and result.castPosition then
            if Control.CastSpell(HK_E, result.castPosition) then
                self.lastE = GetTickCount()
            end
        end
    end
end

function Nunu:GetQDamage(target) --minion only
    local baseDmg = ({340, 500, 660, 820, 920})[myHero:GetSpellData(_Q).level]

    return baseDmg
end

class "Syndra"

function Syndra:__init()
    self.Q = {
        PremiumPrediction = {
            hitChance = 0.4,
            speed = math.huge,
            range = 800,
            delay = 0.7, --0.6 , 0.7 for gos
            radius = 190,
            collision = nil,
            type = "circular"
        },
        GGPrediction = {
            Type = 1,
            Delay = 0.8,
            Radius = 160,
            Range = 800,
            Speed = math.huge,
            Collision = false,
            -- MaxCollision = 0,
            -- CollisionTypes = {GGPrediction.COLLISION_MINION,GGPrediction.COLLISION_ENEMYHERO,GGPrediction.COLLISION_YASUOWALL},
            UseBoundingRadius = false,
            HitChance = 3
        }
    }

    self.W = {
        PremiumPrediction = {
            hitChance = 0.4,
            speed = math.huge,
            range = 950,
            delay = 0.8,  --0.6
            radius = 180, -- 220
            collision = nil,
            type = "circular"
        },
        GGPrediction = {
            Type = 1,
            Delay = 0.8,
            Radius = 180,
            Range = 950,
            Speed = math.huge,
            Collision = false,
            -- MaxCollision = 0,
            -- CollisionTypes = {GGPrediction.COLLISION_MINION,GGPrediction.COLLISION_ENEMYHERO,GGPrediction.COLLISION_YASUOWALL},
            UseBoundingRadius = false,
            HitChance = 3
        }
    }

    self.E = {
        PremiumPrediction = {
            hitChance = 0.4,
            speed = 2500,
            range = 750,
            delay = 0.25,
            radius = 0,
            angle = 40,
            collision = nil,
            type = "conic"
        },
        GGPrediction = {
            HitChance = 3,
            Type = 2,
            Delay = 0.25,
            Radius = 100,
            Range = 750,
            Speed = 2500,
            Collision = false,
            UseBoundingRadius = true
        }
    }

    self.QE = {
        PremiumPrediction = {
            hitChance = 0.55,
            speed = 2000,
            range = 1200,
            delay = 0.25,
            radius = 100,
            collision = {"windwall"},
            type = "linear"
        },
        GGPrediction = {
            HitChance = 3,
            Type = 0,
            Delay = 0.25,
            Radius = 100,
            Range = 1200,
            Speed = 2000,
            Collision = true,
            MaxCollision = 0,
            CollisionTypes = {GGPrediction.COLLISION_YASUOWALL}, --{3},
            UseBoundingRadius = true
        }
    }

    self.R = {
        range = 675
    }

    --ball last for 6s
    self.ballTable = {}
    self.WData = {isBall = false, ball = nil}
    --E 2500
    --EQ 2000

    self.lastQ = 0
    self.lastW1 = 0
    self.lastW2 = 0
    self.lastE = 0
    self.lastR = 0

    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)


end

function Syndra:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesSyndra", name = "[14Series] Syndra"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "Q", name = "use Q", value = true})
        self.tyMenu.combo:MenuElement({id = "W", name = "use W", value = true})
        self.tyMenu.combo:MenuElement({id = "E", name = "use E stun", value = true})
        self.tyMenu.combo:MenuElement({id = "LongE", name = "long E", key = string.byte("T"),toggle = true})
        self.tyMenu.combo:MenuElement({id = "R", name = "use R KS", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.tyMenu.harass:MenuElement({id = "Q", name = "use Q", value = true})
        self.tyMenu.harass:MenuElement({id = "W", name = "use W", value = false})

    self.tyMenu:MenuElement({type = MENU, id = "auto", name = "Auto"})
        self.tyMenu.auto:MenuElement({type = MENU, id = "antiDash", name = "EQ Anti Dash Target"})
        OnEnemyHeroLoad(function(hero) self.tyMenu.auto.antiDash:MenuElement({id = hero.networkID, name = hero.charName, value = true}) end)

    self.tyMenu:MenuElement({type = MENU, id = "pred", name = "Prediction Setting"})
        self.tyMenu.pred:MenuElement({name = " ", drop = {"Q Prediction"}})
        self.tyMenu.pred:MenuElement({id = "QGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.Q.GGPrediction.HitChance = value
            print("changed Q GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "Qperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.Q.PremiumPrediction.hitChance = value
            print("changed Q Premium Pred HitChance to "..value)
        end})


        self.tyMenu.pred:MenuElement({name = " ", drop = {"W Prediction"}})
        self.tyMenu.pred:MenuElement({id = "WGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.W.GGPrediction.HitChance = value
            print("changed W GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "Wperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.W.PremiumPrediction.hitChance = value
            print("changed W Premium Pred HitChance to "..value)
        end})


        self.tyMenu.pred:MenuElement({name = " ", drop = {"QE Prediction"}})
        self.tyMenu.pred:MenuElement({id = "QEGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.QE.GGPrediction.HitChance = value
            print("changed QE GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "QEperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.QE.PremiumPrediction.hitChance = value
            print("changed QE Premium Pred HitChance to "..value)
        end})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "QE", name = "Draw [QE] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "Ball", name = "Draw Ball Position", value = true})

end

function Syndra:Draw()
    if myHero.health == 0 then return  end

    if self.tyMenu.Drawing.Q:Value() then
        Draw.Circle(myHero.pos, 800,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
    if self.tyMenu.Drawing.W:Value() then
        Draw.Circle(myHero.pos, 950,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
    if self.tyMenu.Drawing.E:Value() then
        Draw.Circle(myHero.pos, 750,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
    if self.tyMenu.Drawing.QE:Value() then
        Draw.Circle(myHero.pos, 1200,Draw.Color(255 ,0xE1,0xA0,0x00))
    end
    if self.tyMenu.Drawing.R:Value() then
        Draw.Circle(myHero.pos, self.R.range ,Draw.Color(255 ,0xE1,0xA0,0x00))
    end

    if self.tyMenu.Drawing.Ball:Value() then
        for _, ball in pairs(self.ballTable) do
            Draw.Circle(Vector(ball.position), 40 ,Draw.Color(255 ,0xE1,0xA0,0x00))
            Draw.Text(GetTickCount() - ball.castTick,12 ,Vector(ball.position):To2D(),Draw.Color(255 ,0xE1,0xA0,0x00))
        end
    end

    local pos2D = myHero.pos:To2D()
    pos2D.y = pos2D.y-30

    if self.tyMenu.combo.LongE:Value() then
        Draw.Text("Lone E : enable",18 ,pos2D,Draw.Color(255 ,0xFF,0xFF,0xFF))
    else
        Draw.Text("Lone E : disable",18 ,pos2D,Draw.Color(255 ,0xFF,0x00,0x00))
    end

end

function Syndra:Tick()
    if ShouldWait() then return end

    self:UpdateBall()
    self:UpdateR()

    if orbwalker:GetMode() == "Combo" then
        self:Combo()
    end

    if orbwalker:GetMode() == "Harass" then
        self:Harass()
    end

    self:AntiDash()

end

function Syndra:UpdateBall()
    for k, ball in pairs(self.ballTable) do
        if GetTickCount() - ball.castTick >  6600 then
            table_remove(self.ballTable,k)
        end
    end
end

function Syndra:UpdateR()
    if self.R.Range ~= 750 and myHero:GetSpellData(_R).level == 3 then
        self.R.range = 750
    end
end

function Syndra:Combo()
    local target = orbwalker:GetTarget(800)
    if target  and self.tyMenu.combo.Q:Value() then
        self:CastQ(target)
    end

    local target = orbwalker:GetTarget(950)
    if target  and self.tyMenu.combo.W:Value() then
        self:CastW(target)
    end

    if self.tyMenu.combo.LongE:Value() then
        local target = orbwalker:GetTarget(1200)
        if target  and self.tyMenu.combo.E:Value() then
            self:CastE(target)
        end
    else
        local target = orbwalker:GetTarget(750)
        if target  and self.tyMenu.combo.E:Value() then
            self:CastE(target)
        end
    end

    local target = orbwalker:GetTarget(self.R.range)
    if target  and self.tyMenu.combo.R:Value() then
        self:CastR(target)
    end


end

function Syndra:Harass()
    local target = orbwalker:GetTarget(800)
    if target  and self.tyMenu.harass.Q:Value() then
        self:CastQ(target)
    end

    local target = orbwalker:GetTarget(950)
    if target  and self.tyMenu.harass.W:Value() then
        self:CastW(target)
    end
end

function Syndra:AntiDash()
    local enemys = GetEnemysInRange(750,myHero.pos)

    if enemys then
        for i = 1, #enemys do
            local enemy = enemys[i]
            if self.tyMenu.auto.antiDash[enemy.networkID]
            and self.tyMenu.auto.antiDash[enemy.networkID]:Value()
            and enemy.pathing and enemy.pathing.isDashing and enemy.pathing.dashSpeed>0
            and Ready(_E) and self.lastE+600 < GetTickCount() then

                local result = prediction:GetPrediction(myHero,enemy,self.E)
                if result and result.castPosition then
                    if Ready(_Q) and self.lastQ + 300 < GetTickCount() then
                        if GetDistanceSquared(myHero.pos,result.unitPosition) < 300*300 then
                            local castPos = myHero.pos:Extended(result.unitPosition , 500)
                            if Control.CastSpell(HK_Q, castPos) then
                                Control.CastSpell(HK_E)
                                self.lastQ = GetTickCount()
                                self.lastE = GetTickCount()
                            end
                        else
                            if Control.CastSpell(HK_Q, result.unitPosition) then
                                Control.CastSpell(HK_E)
                                self.lastQ = GetTickCount()
                                self.lastE = GetTickCount()
                            end
                        end
                    else
                        if Control.CastSpell(HK_E, result.castPosition) then
                            self.lastE = GetTickCount()
                        end
                    end
                end
            end
        end
    end
end

function Syndra:CastQ(target)
    if Ready(_Q) and self.lastQ + 600 < GetTickCount() and orbwalker:CanMove() then
        local result = prediction:GetPrediction(myHero,target,self.Q)
        if result and result.castPosition then
            if Control.CastSpell(HK_Q, result.castPosition) then
                self.lastQ = GetTickCount()
                table_insert(self.ballTable,{position = result.castPosition, castTick = GetTickCount()})
            end
        end
    end
end

function Syndra:CastW(target)
    if Ready(_W) then
        if myHero:GetSpellData(_W).toggleState == 1 and self.lastW1 + 500 < GetTickCount() then
            local result = prediction:GetPrediction(myHero,target,self.W)

            if result and result.castPosition then
                for _, ball in pairs(self.ballTable) do
                    if GetDistanceSquared(myHero.pos, ball.position) < 950*950 then
                        if Control.CastSpell(HK_W, ball.position) then
                            self.WData.isBall = true
                            self.WData.ball = ball
                            self.lastW1 = GetTickCount()
                            return
                        end
                    end
                end

                local minions = GetMinionsInRange(950,myHero.pos)
                if minions then
                    for i=1, #minions do
                        local minion = minions[i]
                        if Control.CastSpell(HK_W, minion.pos) then
                            self.WData.isBall = false
                            self.WData.ball = nil
                            self.lastW1 = GetTickCount()
                            return
                        end
                    end
                end
            end

        end

        if myHero:GetSpellData(_W).toggleState == 2
        and self.lastW2 + 300 < GetTickCount()
        and self.lastW1 + 100 < GetTickCount()
        then
            local result = prediction:GetPrediction(myHero,target,self.W)
            if result and result.castPosition then
                if Control.CastSpell(HK_W, result.castPosition) then
                    self.lastW2 = GetTickCount()
                    if self.WData.isBall then
                        self.WData.ball.position = result.castPosition
                    end
                end
            end
        end

    end
end

function Syndra:CastE(target)
    if Ready(_E) and self.lastE + 600 < GetTickCount() then
        local result = prediction:GetPrediction(myHero,target,self.QE)
        if result and result.unitPosition then
            local targetPos = myHero.pos:Extended(result.unitPosition,1200)
            for _, ball in pairs(self.ballTable) do
                local objectPos = myHero.pos:Extended(ball.position , 1300)
                if GetDistanceSquared(targetPos, objectPos) <= (100 + target.boundingRadius) ^ 2 then
                    if Control.CastSpell(HK_E, ball.position) then
                        self.lastE = GetTickCount()
                        return
                    end
                end
            end

            if Ready(_Q) and self.lastQ + 600 < GetTickCount() then
                local castPos = myHero.pos:Extended(result.unitPosition,700)
                if GetDistanceSquared(myHero.pos,result.unitPosition) < 750*750 then
                    if GetDistanceSquared(myHero.pos,result.unitPosition) < 300*300 then
                        local castPos = myHero.pos:Extended(result.unitPosition , 500)
                        if Control.CastSpell(HK_Q, castPos) then
                            Control.CastSpell(HK_E)
                            self.lastQ = GetTickCount()
                            self.lastE = GetTickCount()
                        end
                    else
                        if Control.CastSpell(HK_Q, result.unitPosition) then
                            Control.CastSpell(HK_E)
                            self.lastQ = GetTickCount()
                            self.lastE = GetTickCount()
                        end
                    end
                else
                    if Control.CastSpell(HK_Q, castPos) then
                        Control.CastSpell(HK_E)
                        self.lastQ = GetTickCount()
                        self.lastE = GetTickCount()
                    end
                end
            end
        end
    end
end

function Syndra:CastR(target)
    if Ready(_R) and self.lastR + 600 < GetTickCount() then
        if target.health + target.shieldAP < self:GetRDamage(target) then
            if Control.CastSpell(HK_R, target.pos) then
                self.lastR = GetTickCount()
            end
        end
    end
end

function Syndra:GetRDamage(target)
    local baseDamage = ({90,140,190})[myHero:GetSpellData(_R).level]
    local bonusDamage = myHero.ap * 0.2

    local value = myHero:GetSpellData(_R).ammo * (baseDamage+bonusDamage)

    if _G.SDK.Damage then
        return _G.SDK.Damage:CalculateDamage(myHero,target,1, value)
    else
        print("R KS require GGorblwaker")
    end
end

class "Yasuo"

function Yasuo:__init()
    self.Q = {
        PremiumPrediction = {
            hitChance = 0.55,
            speed = math.huge,
            range = 475,
            delay = 0.35,
            radius = 40,
            collision = nil,
            type = "linear"
        },
        GGPrediction = {
            HitChance = 3,
            Type = 0,
            Delay = 0.35,
            Radius = 40,
            Range = 475,
            Speed = math.huge,
            Collision = false,
            -- MaxCollision = 0,
            -- CollisionTypes = {3},
            UseBoundingRadius = true
        }
    }

    self.Q3 = {
        PremiumPrediction = {
            hitChance = 0.55,
            speed = 1500,
            range = 1060,
            delay = 0.35,
            radius = 90,
            collision = nil,
            type = "linear"
        },
        GGPrediction = {
            HitChance = 3,
            Type = 0,
            Delay = 0.35,
            Radius = 90,
            Range = 1060,
            Speed = 1500,
            Collision = false,
            MaxCollision = 0,
            CollisionTypes = {GGPrediction.COLLISION_YASUOWALL}, --{3},
            UseBoundingRadius = true
        }
    }

    self.E = {
        range = 475
    }

    self.R  = {
        range = 1400
    }


    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0

    self:LoadMenu()

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function Yasuo:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesYasuo", name = "[14Series] Yasuo"})

    self.tyMenu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.tyMenu.combo:MenuElement({id = "Q", name = "use Q", value = true})
        self.tyMenu.combo:MenuElement({id = "Emode", name = "E Mode", value = 1, drop = {"E to target", "E to cursor"}})
        self.tyMenu.combo:MenuElement({id = "Etower", name = "Stop E to Turret if Target HP(%) > X",  value = 25, min = 0, max = 100, step = 1})
        self.tyMenu.combo:MenuElement({id = "R", name = "use R", value = true})
        self.tyMenu.combo:MenuElement({type = MENU, id = "RTarget", name = "R Target"})
        OnEnemyHeroLoad(function(hero) self.tyMenu.combo.RTarget:MenuElement({id = hero.networkID, name = hero.charName, value = true}) end)
        self.tyMenu.combo:MenuElement({id = "RTargetHP", name = "Only R if Target HP (%) < X",  value = 50, min = 0, max = 100, step = 1})
        self.tyMenu.combo:MenuElement({id = "Rdelay", name = "Delay R to last (s)",  value = 0.08, min = 0.01, max = 1, step = 0.01})
        self.tyMenu.combo:MenuElement({id = "RCount", name = "R AOE If can hit ",  value = 3, min = 1, max = 5, step = 1})


    self.tyMenu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.tyMenu.harass:MenuElement({id = "Q", name = "use Q", value = true})
        self.tyMenu.harass:MenuElement({id = "Q3", name = "use Q3", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "lasthit", name = "Lasthit"})
        self.tyMenu.lasthit:MenuElement({id = "Q", name = "use Q", value = true})
        self.tyMenu.lasthit:MenuElement({id = "Q3", name = "use Q3", value = true})
        self.tyMenu.lasthit:MenuElement({id = "E", name = "use E", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "waveclear", name = "Waveclear"})
        self.tyMenu.waveclear:MenuElement({id = "EQ", name = "Circle Q1/Q2 If can hit",  value = 3, min = 0, max = 10, step = 1})
        self.tyMenu.waveclear:MenuElement({id = "EQ3", name = "Circle Q3 If can hit",  value = 4, min = 0, max = 10, step = 1})
        self.tyMenu.waveclear:MenuElement({id = "EHit", name = "Use E last Hit", value = true})
        self.tyMenu.waveclear:MenuElement({id = "QHit", name = "Use Q last Hit", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "waveclear", name = "Waveclear"})


end

class "Talon"

function Talon:__init()
    self.Q = {
        range = 575
    }

    self.W = {
        PremiumPrediction = {
            hitChance = 0.4,
            speed = 2500,
            range = 800,
            delay = 0.25,
            radius = 0,
            angle = 34,
            collision = nil,
            type = "conic"
        },
        GGPrediction = {
            HitChance = 3,
            Type = 2,
            Delay = 0.25,
            Radius = 100,
            Range = 800,
            Speed = 2500,
            Collision = false,
            UseBoundingRadius = true
        }
    }

    self.R = {
        range = 550
    }

    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0

    self:LoadMenu()

    Callback.Add("Tick", function() self:OnTick() end)
    Callback.Add("Draw", function() self:OnDraw() end)
    orbwalker:OnPostAttack(function() self:OnPostAttack() end)

end

function Talon:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesTalon", name = "[14Series] Talon"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({id = "Burst", name = "burst mode",key = string.byte('T'),toggle = true})
        self.tyMenu.Combo:MenuElement({id = "QRange", name = "Range Q", value = true})
        self.tyMenu.Combo:MenuElement({id = "QMelee", name = "Melee Q AA reset", value = true})
        self.tyMenu.Combo:MenuElement({id = "W", name = "W", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({id = "QRange", name = "Range Q", value = false})
        self.tyMenu.Harass:MenuElement({id = "QMelee", name = "Melee Q AA reset", value = true})
        self.tyMenu.Harass:MenuElement({id = "W", name = "W", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "KS", name = "KS"})
        self.tyMenu.KS:MenuElement({id = "Q", name = "Q", value = true})
        self.tyMenu.KS:MenuElement({id = "W", name = "W", value = true})
        self.tyMenu.KS:MenuElement({id = "R", name = "R", value = false})

    self.tyMenu:MenuElement({type = MENU, id = "pred", name = "Prediction Setting"})
        self.tyMenu.pred:MenuElement({name = " ", drop = {"W Prediction"}})
        self.tyMenu.pred:MenuElement({id = "WGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.W.GGPrediction.HitChance = value
            print("changed W GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "Wperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.W.PremiumPrediction.hitChance = value
            print("changed W Premium Pred HitChance to "..value)
        end})

    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
        self.tyMenu.Drawing:MenuElement({id = "Damage", name = "Draw Combo Damage of enemy", value = true})
        self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
        self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Talon:OnDraw()
    if myHero.dead then return end

    local myHeroDrawPos = myHero.pos
    myHeroDrawPos.x = myHeroDrawPos.x -60
    myHeroDrawPos.y = myHeroDrawPos.y -100


    if self.tyMenu.Combo.Burst:Value() then
        Draw.Text("Brust Mode: On ",17,myHeroDrawPos:To2D(),Draw.Color(255 ,0xFF,0xFF,0xFF))
    else
        Draw.Text("Brust Mode: Off ",17,myHeroDrawPos:To2D(),Draw.Color(255 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.Damage:Value() then
        local Enemys = GetEnemyHeroes()
        for i = 1, #Enemys do
            local enemy = Enemys[i]
            if IsValid(enemy) then
                local value = 0
                if Ready(_Q) then
                    value = value + self:getQDamage(enemy)
                end
                if Ready(_W) then
                    value = value + self:getWDamage(enemy)
                end
                if Ready(_R) then
                    value = value + self:getRDamage(enemy)
                    value = value + self:getRDamage(enemy)
                end

                local enemyDrawPos = enemy.pos
                enemyDrawPos.x = enemyDrawPos.x -100
                enemyDrawPos.y = enemyDrawPos.y -60


                local remainHP = floor(enemy.health + enemy.shieldAD - value)

                if remainHP < 0 then
                    Draw.Text("            Killable ",20,enemyDrawPos:To2D(),Draw.Color(255 ,0xFF,0x00,0x00))
                else
                    Draw.Text("HP left after combo: "..remainHP,20,enemyDrawPos:To2D())
                end
            end
        end
    end

    if self.tyMenu.Drawing.Q:Value() and  Ready(_Q) then
        Draw.Circle(myHero.pos, self.Q.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, 800,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Talon:OnPostAttack()
    if orbwalker:GetMode() == "Combo" and self.tyMenu.Combo.QMelee:Value() then
        local target = orbwalker:GetTarget()

        if target and self.lastQ + 300 < GetTickCount() and Ready(_Q) then
            Control.CastSpell(HK_Q,target)
            self.lastQ = GetTickCount()
        end
    end

    if orbwalker:GetMode() == "Harass" and self.tyMenu.Harass.QMelee:Value() then
        local target = orbwalker:GetTarget()

        if target and self.lastQ + 300 < GetTickCount() and Ready(_Q) then
            Control.CastSpell(HK_Q,target)
            self.lastQ = GetTickCount()
        end
    end
end


function Talon:OnTick()
    if ShouldWait() then return end

    if orbwalker:GetMode() == "Combo" then
        self:Combo()
    end

    if orbwalker:GetMode() == "Harass" then
        self:Harass()
    end

    self:KS()
end

function Talon:Combo()
    if self.tyMenu.Combo.Burst:Value() then
        local target = orbwalker:GetTarget(self.W.range)
        if target then
            self:CastW(target)
        end
        local target = orbwalker:GetTarget(self.R.range)
        if target and Ready(_R) and self.lastR + 300 < GetTickCount() then
            Control.CastSpell(HK_R)
            self.lastR = GetTickCount()
        end

        local target = orbwalker:GetTarget(self.Q.range)
        if target and Ready(_Q) and self.lastQ + 300 < GetTickCount() and not Ready(_R) then
            Control.CastSpell(HK_Q, target)
            self.lastQ = GetTickCount()
        end

    else
        local target = orbwalker:GetTarget(self.W.range)
        if target and self.tyMenu.Combo.W:Value() then
            self:CastW(target)
        end

        local target = orbwalker:GetTarget(self.Q.range)
        if target and self.tyMenu.Combo.QRange:Value() then
            if Ready(_Q) and
            GetDistanceSquared(myHero.pos, target.pos) > (myHero.range + myHero.boundingRadius + target.boundingRadius)^2
            and self.lastQ + 300 < GetTickCount()
            then
                Control.CastSpell(HK_Q, target)
                self.lastQ = GetTickCount()
            end
        end
    end

end

function Talon:Harass()
    local target = orbwalker:GetTarget(self.Q.range)
    if target and self.tyMenu.Harass.QRange:Value() then
        if Ready(_Q) and
        GetDistanceSquared(myHero.pos, target.pos) > (myHero.range + myHero.boundingRadius + target.boundingRadius)^2
        and self.lastQ + 300 < GetTickCount()
        then
            Control.CastSpell(HK_Q, target)
            lastQ = GetTickCount()
        end
    end

    local target = orbwalker:GetTarget(self.W.range)
    if target and self.tyMenu.Harass.W:Value() then
        self:CastW(target)
    end
end

function Talon:KS()
    local Enemys = GetEnemyHeroes()
    for i = 1, #Enemys do
        local enemy = Enemys[i]
        if IsValid(enemy) then
            if self.tyMenu.KS.Q:Value() and  GetDistanceSquared(myHero.pos, enemy.pos) < self.Q.range * self.Q.range
            and Ready(_Q) and self.lastQ + 300 < GetTickCount() then
                if enemy.health + enemy.shieldAD < self:getQDamage(enemy) then
                    if Control.CastSpell(HK_Q, target) then
                        self.lastQ = GetTickCount()
                        print("Q KS")
                        return
                    end
                end
            end
            if self.tyMenu.KS.W:Value() and GetDistanceSquared(myHero.pos, enemy.pos) < 800 * 800
            and  Ready(_W) and self.lastW + 300 < GetTickCount() then
                if enemy.health + enemy.shieldAD < self:getWDamage(enemy) then
                    self:CastW(enemy)
                    print("W KS")
                    return
                end
            end

            if self.tyMenu.KS.R:Value() and GetDistanceSquared(myHero.pos, enemy.pos) <  self.R.range * self.R.range
            and  Ready(_R) and self.lastR + 300 < GetTickCount() then
                if enemy.health + enemy.shieldAD < self:getRDamage(enemy) then
                    if Control.CastSpell(HK_R) then
                        self.lastR = GetTickCount()
                        print("R KS")
                        return
                    end
                end
            end
        end
    end
end


function Talon:CastW(target)
    if Ready(_W) and self.lastW + 300 < GetTickCount() and orbwalker:CanMove() then
        local result = prediction:GetPrediction(myHero,target,self.W)
        if result and result.castPosition then
            if Control.CastSpell(HK_W, result.castPosition) then
                self.lastW = GetTickCount()
            end
        end
    end
end

function Talon:getQDamage(target)
    local baseDMG = ({65,90,115,140,165})[myHero:GetSpellData(0).level]
    local AD = myHero.bonusDamage * 1.1

    local value = baseDMG + AD
    if GetDistanceSquared(myHero.pos,target.pos) < (myHero.range + myHero.boundingRadius + target.boundingRadius) ^2 then
        value = value * 1.5
    end

    return CalcPhysicalDamage(myHero, target, value)

end

function Talon:getWDamage(target)
    local baseDMG = ({45,60,75,90,105})[myHero:GetSpellData(1).level]
    local AD = myHero.bonusDamage * 0.4

    local value = baseDMG + AD

    return CalcPhysicalDamage(myHero, target, value)

end

function Talon:getRDamage(target)
    local baseDMG = ({90,135,180})[myHero:GetSpellData(3).level]
    local AD = myHero.bonusDamage

    local value = baseDMG + AD

    return CalcPhysicalDamage(myHero, target, value)
end

class "Kennen"

function Kennen:__init()
    self.Q = {

        PremiumPrediction = {
            hitChance = 0.5,
            speed = 1700,
            range = 950,
            delay = 0.175,
            radius = 50,
            collision = {"minion","hero","windwall"},
            type = "linear"
        },
        GGPrediction = {
            HitChance = 3,
            Type = 0,
            Delay = 0.175,
            Radius = 50,
            Range = 950,
            Speed = 1700,
            Collision = true,
            MaxCollision = 0,
            CollisionTypes = {GGPrediction.COLLISION_MINION,GGPrediction.COLLISION_ENEMYHERO,GGPrediction.COLLISION_YASUOWALL}, --{0,2,3},
            UseBoundingRadius = true
        }
    }

    self.W = {
        range = 770
    }

    self.R = {
        range = 550
    }

    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0

    self:LoadMenu()

    Callback.Add("Tick", function() self:OnTick() end)
    Callback.Add("Draw", function() self:OnDraw() end)

end


function Kennen:LoadMenu()
    self.tyMenu = MenuElement({type = MENU, id = "14SeriesKennen", name = "[14Series] Kennen"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Combo:MenuElement({id = "UseW", name = "[W] ", value = true})
    self.tyMenu.Combo:MenuElement({id = "rCount", name = "Use R If Can Hit X", value = 3, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.tyMenu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
    self.tyMenu.Harass:MenuElement({id = "UseW", name = "[W] ", value = true})

    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
    self.tyMenu.Auto:MenuElement({id = "UseQ", name = "auto Q stun", value = true})
    self.tyMenu.Auto:MenuElement({id = "UseW", name = "auto W stun", value = true})
    self.tyMenu.Auto:MenuElement({id = "rCount", name = "Use R If Can Hit X", value = 3, min = 1, max = 5, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "pred", name = "Prediction Setting"})
        self.tyMenu.pred:MenuElement({name = " ", drop = {"Q Prediction"}})
        self.tyMenu.pred:MenuElement({id = "QGG", name = "GG Pred HitChance", value = 3, min = 2, max = 4, step = 1, callback = function(value)
            self.Q.GGPrediction.HitChance = value
            print("changed Q GG Pred HitChance to "..value)
        end})
        self.tyMenu.pred:MenuElement({id = "Qperm", name = "Premium Pred HitChance", value = 0.5, min = 0, max = 1, step = 0.01, callback = function(value)
            self.Q.PremiumPrediction.hitChance = value
            print("changed Q Premium Pred HitChance to "..value)
        end})


    self.tyMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
    self.tyMenu.Drawing:MenuElement({id = "Damage", name = "Draw Combo Damage of enemy", value = true})
    self.tyMenu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "W", name = "Draw [W] Range", value = true})
    self.tyMenu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Kennen:OnDraw()
    if myHero.dead then
        return
    end

    if self.tyMenu.Drawing.Damage:Value() then
        local Enemys = GetEnemyHeroes()
        for i = 1, #Enemys do
            local enemy = Enemys[i]
            if IsValid(enemy) then
                local value = 0
                if Ready(_Q) then
                    value = value + self:GetQDamage(enemy)
                end
                if Ready(_W) then
                    value = value + self:GetWDamage(enemy)
                end
                if Ready(_R) then
                    value = value + self:GetRDamage(enemy)
                end

                local enemyDrawPos = enemy.pos2D
                enemyDrawPos.x = enemyDrawPos.x -70
                enemyDrawPos.y = enemyDrawPos.y +40

                local remainHP = floor(enemy.health + enemy.shieldAP - value)

                if remainHP < 0 then
                    Draw.Text("       Killable ",20,enemyDrawPos.x,enemyDrawPos.y,Draw.Color(255 ,0xFF,0x00,0x00))
                else
                    Draw.Text("HP left after combo: "..remainHP,enemyDrawPos.x,enemyDrawPos.y)
                end
            end
        end
    end


    if self.tyMenu.Drawing.Q:Value() and Ready(_Q) then
        Draw.Circle(myHero.pos, 950,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end

    if self.tyMenu.Drawing.W:Value() and Ready(_W) then
        Draw.Circle(myHero.pos, self.W.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end


    if self.tyMenu.Drawing.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.range,Draw.Color(80 ,0xFF,0xFF,0xFF))
    end
end

function Kennen:OnTick()
    self:CheckE()

    if ShouldWait() then return end

    if orbwalker:GetMode() == "Combo" then
        self:Combo()
    end

    if orbwalker:GetMode() == "Harass" then
        self:Harass()
    end

    self:Auto()
end

function Kennen:CheckE()
    if Hasbuff(myHero, "KennenLightningRush") then
        orbwalker:SetAttack(false)
    else
        orbwalker:SetAttack(true)
    end
    --KennenLightningRush
end


function Kennen:Combo()
    local target

    target = orbwalker:GetTarget(950)
    if target and IsValid(target) and self.tyMenu.Combo.UseQ:Value() then
        self:CastQ(target)
    end

    target = orbwalker:GetTarget(self.W.Range)
    if target and IsValid(target) and self.tyMenu.Combo.UseW:Value() and orbwalker:CanMove() then
        if Ready(_W) and self.lastW +260 < GetTickCount() and Hasbuff(target,"kennenmarkofstorm") then
            if Control.CastSpell(HK_W) then
                self.lastW = GetTickCount()
                -- print("W "..GetTickCount())
            end
        end
    end



    if Ready(_R) and self.lastR +260 < GetTickCount() then
        if #GetEnemysInRange(self.R.range) >= self.tyMenu.Combo.rCount:Value() then
            if Control.CastSpell(HK_R) then
                self.lastR = GetTickCount()
                -- print("R "..GetTickCount())
            end
        end
    end
end

function Kennen:Harass()
    local target

    target = orbwalker:GetTarget(950)
    if target and IsValid(target) and self.tyMenu.Harass.UseQ:Value() then
        self:CastQ(target)
    end

    target = orbwalker:GetTarget(self.W.Range)
    if target and IsValid(target) and self.tyMenu.Harass.UseW:Value() and orbwalker:CanMove() then
        if Ready(_W) and self.lastW +260 < GetTickCount() and Hasbuff(target,"kennenmarkofstorm") then
            if Control.CastSpell(HK_W) then
                self.lastW = GetTickCount()
                -- print("W "..GetTickCount())
            end
        end
    end
end

function Kennen:Auto()

    if self.tyMenu.Auto.UseQ:Value() and Ready(_Q) and self.lastQ +260 < GetTickCount() and orbwalker:CanMove() then
        local enemys = GetEnemysInRange(950)
        for i = 1, #enemys do
            local hero = enemys[i]
            local buff = Hasbuff(hero,"kennenmarkofstorm")
            if buff and buff.count == 2 then
                self:CastQ(hero)
            end
        end
    end

    if self.tyMenu.Auto.UseW:Value() and Ready(_W) and self.lastW +260 < GetTickCount() and orbwalker:CanMove() then
        local enemys = GetEnemysInRange(self.W.range)
        if enemys and enemys[1] then
            for i = 1, #enemys do
                local hero = enemys[i]
                local buff = Hasbuff(hero,"kennenmarkofstorm")
                if buff and buff.count == 2 then
                    if Control.CastSpell(HK_W) then
                        self.lastW = GetTickCount()
                    end
                end
            end
        end
    end

    if Ready(_R) and self.lastR +260 < GetTickCount() then
        if #GetEnemysInRange(self.R.range) >= self.tyMenu.Auto.rCount:Value() then
            if Control.CastSpell(HK_R) then
                self.lastR = GetTickCount()
            end
        end
    end
end

function Kennen:CastQ(target)
    if Ready(_Q) and self.lastQ +260 < GetTickCount() and orbwalker:CanMove() then
        local result = prediction:GetPrediction(myHero,target,self.Q)
        if result and result.castPosition then
            if Control.CastSpell(HK_Q, result.castPosition) then
                self.lastQ = GetTickCount()
            end
        end
    end
end

function Kennen:GetQDamage(target)
    local baseDmg = ({75, 115, 155,195,235})[myHero:GetSpellData(_Q).level]
    local bonusDmg = myHero.ap * 0.75

    local value = baseDmg + bonusDmg
    return CalcMagicDamage(myHero, target, value )
end

function Kennen:GetWDamage(target)
    local baseDmg = ({60, 85, 110,135,160})[myHero:GetSpellData(_W).level]
    local bonusDmg = myHero.ap * 0.8

    local value = baseDmg + bonusDmg
    return CalcMagicDamage(myHero, target, value )
end

function Kennen:GetRDamage(target)
    local baseDmg = ({300, 562.5, 825})[myHero:GetSpellData(_R).level]
    local bonusDmg = myHero.ap * 1.5
    local value = baseDmg + bonusDmg
    return CalcMagicDamage(myHero, target, value)

end





class "_Loader"

function _Loader:__init()

    self:LoadChmapions()

end

function _Loader:LoadCore()

    orbwalker = _Orbwalker()
    prediction = _Predication()

    self.lastAttack = 0
    self.lastMove = 0

    local pred = {
        [1] = function() require 'GGPrediction' end,
        [2] = function() require 'PremiumPrediction' end,

    }

    local function OnPredChange(val)
        pred[val]()
        print("If you changed Pred, Please F6*2 ")
    end

    coreMenu = MenuElement({type = MENU, id = "14SeriesCore", name = "[14Series] [Version "..Version.."] Core"})
    coreMenu:MenuElement({id = "prediction", name = "Prediction To Use", value = 1,drop = {"GG Pred", "Premium Pred"}, callback = OnPredChange})
    coreMenu:MenuElement({type = MENU, id = "human", name = "Humanizer"})
    coreMenu.human:MenuElement({id = "move", name = "Delay between every move (1000 = 1s)", value = 0, min = 0, max = 500, step = 1})
    coreMenu.human:MenuElement({id = "aa", name = "Delay between every attack (1000 = 1s)", value = 0, min = 0, max = 500, step = 1})
    coreMenu:MenuElement({id = "supportMode", name = "Support Mode (disable harass lasthit)", value = false})

    OnPredChange(coreMenu.prediction:Value())

    orbwalker:OnPreAttack(
        function(args)
            if args.Process then
                if coreMenu.supportMode:Value() and orbwalker:GetMode() == "Harass" then
                    if args.Target.type ~= myHero.type then
                        args.Process = false
                        return
                    end
                end

                if self.lastAttack + coreMenu.human.aa:Value() > GetTickCount() then
                    args.Process = false
                    print("block aa")
                else
                    self.lastAttack = GetTickCount()
                end
            end

        end
    )

    orbwalker:OnPreMovement(
        function(args)
            if args.Process then
                if (self.lastMove + coreMenu.human.move:Value() > GetTickCount()) then
                    args.Process = false
                else
                    self.lastMove = GetTickCount()
                end
            end
        end
    )

end



function _Loader:LoadChmapions()
    local supportChampions = {
        ["Brand"]  = true,
        ["FiddleSticks"] = true,
        ["Vayne"]  = true,
        ["Senna"]  = true,
        ["Nunu"]   = true,
        ["Syndra"] = true,
        ["Talon"]  = true,
        ["Kennen"] = true,
    }

    if supportChampions[myHero.charName] then
        self:LoadCore()
        print("14Series Core loaded")
        _G[myHero.charName]()
        print("14Series Champion "..myHero.charName.." loaded")
    else
        print(myHero.charName.." not supported")
    end
end

function OnLoad()
    if not _G._14Series then
        _G._14Series = true
        _Loader()
    end
end


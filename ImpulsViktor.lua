local Champions = {
["Viktor"] = function() return Viktor:__init() end,
}

if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"
require('2DGeometry')

local MathAbs, MathAtan, MathAtan2, MathAcos, MathCeil, MathCos, MathDeg, MathFloor, MathHuge, MathMax, MathMin, MathPi, MathRad, MathRandom, MathSin, MathSqrt =
	math.abs, math.atan, math.atan2, math.acos, math.ceil, math.cos, math.deg, math.floor, math.huge, math.max, math.min, math.pi, math.rad, math.random, math.sin, math.sqrt
local ControlIsKeyDown, ControlKeyDown, ControlKeyUp, ControlSetCursorPos, DrawCircle, DrawLine, DrawRect, DrawText, GameCanUseSpell, GameLatency, GameTimer, GameHero, GameMinion, GameTurret =
	Control.IsKeyDown, Control.KeyDown, Control.KeyUp, Control.SetCursorPos, Draw.Circle, Draw.Line, Draw.Rect, Draw.Text, Game.CanUseSpell, Game.Latency, Game.Timer, Game.Hero, Game.Minion, Game.Turret
local TableInsert, TableRemove, TableSort = table.insert, table.remove, table.sort
local HeroIcon = "https://www.mobafire.com/images/champion/icon/viktor.png"
local IgniteIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/f/f4/Ignite.png"
local QIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/3/30/Augment-_Turbocharge.png"
local WIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/b/bf/Augment-_Magnetize.png"
local EIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/5/5d/Augment-_Aftershock.png"
local RIcon = "https://static.wikia.nocookie.net/leagueoflegends/images/9/9f/Augment-_Perfect_Storm.png"
local R2Icon = "https://static.wikia.nocookie.net/leagueoflegends/images/1/1e/Chaos_Storm_2.png"

local function GameHeroCount()
	local c = Game.HeroCount()
	return (not c or c < 0 or c > 12) and 0 or c
end

local function GameMinionCount()
	local c = Game.MinionCount()
	return (not c or c < 0 or c > 500) and 0 or c
end

local function GameTurretCount()
	local c = Game.TurretCount()
	return (not c or c < 0 or c > 11) and 0 or c
end

local function GetBuffCount(unit)
	local c = unit.buffCount
	return (not c or c < 0 or c > 63) and -1 or c
end

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

--[[
-- [ update not enabled until proper rank ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "ImpulsViktor.lua",
            Url = "https://raw.githubusercontent.com/Impuls/GoS/master/ImpulsViktor.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "ImpulsViktor.version",
            Url = "https://raw.githubusercontent.com/Impuls/GoS/master/ImpulsViktor.version"
        }
    }


    local function AutoUpdate()
        
        local function DownloadFile(url, path, fileName)
            DownloadFileAsync(url, path .. fileName, function() end)
            while not FileExist(path .. fileName) do end
        end
        
        local function ReadFile(path, fileName)
            local file = io.open(path .. fileName, "r")
            local result = file:read()
            file:close()
            return result
        end
        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print(Files.Version.Name .. ": Updated to " .. tostring(NewVersion) .. ". Please Reload with 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end
]]

----------------------------------------------------
--|                    Checks                    |--
----------------------------------------------------

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	print("gamsteronPred. installed Press 2x F6")
	return
end

if not FileExist(COMMON_PATH .. "PremiumPrediction.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/Ark223/GoS-Scripts/master/PremiumPrediction.lua", COMMON_PATH .. "PremiumPrediction.lua", function() end)
	print("PremiumPred. installed Press 2x F6")
	return
end

if not FileExist(COMMON_PATH .. "GGPrediction.lua") then
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGPrediction.lua", COMMON_PATH .. "GGPrediction.lua", function() end)
	print("GGPrediction installed Press 2x F6")
	return
end

local function IsPoint(p)
	return p and p.x and type(p.x) == "number" and p.y and type(p.y) == "number"
end

class "PPoint"

function PPoint:__init(x, y)
	if not x then self.x, self.y = 0, 0
	elseif not y then self.x, self.y = x.x, x.y
	else self.x = x; if y and type(y) == "number" then self.y = y end end
end

function PPoint:__type()
	return "PPoint"
end

function PPoint:__eq(p)
	return self.x == p.x and self.y == p.y
end

function PPoint:__add(p)
	return PPoint(self.x + p.x, (p.y and self.y) and self.y + p.y)
end

function PPoint:__sub(p)
	return PPoint(self.x - p.x, (p.y and self.y) and self.y - p.y)
end

function PPoint.__mul(a, b)
	if type(a) == "number" and IsPoint(b) then
		return PPoint(b.x * a, b.y * a)
	elseif type(b) == "number" and IsPoint(a) then
		return PPoint(a.x * b, a.y * b)
	end
end

function PPoint.__div(a, b)
	if type(a) == "number" and IsPoint(b) then
		return PPoint(a / b.x, a / b.y)
	else
		return PPoint(a.x / b, a.y / b)
	end
end

function PPoint:__tostring()
	return "("..self.x..", "..self.y..")"
end

function PPoint:Appended(to, distance)
	return to + (to - self):Normalized() * distance
end

function PPoint:Clone()
	return PPoint(self)
end

function PPoint:Extended(to, distance)
	return self + (PPoint(to) - self):Normalized() * distance
end

function PPoint:Magnitude()
	return MathSqrt(self:MagnitudeSquared())
end

function PPoint:MagnitudeSquared(p)
	local p = p and PPoint(p) or self
	return p.x * p.x + p.y * p.y
end

function PPoint:Normalize()
	local dist = self:Magnitude()
	self.x, self.y = self.x / dist, self.y / dist
end

function PPoint:Normalized()
	local p = self:Clone()
	p:Normalize(); return p
end

function PPoint:Perpendicular()
	return PPoint(-self.y, self.x)
end

function PPoint:Perpendicular2()
	return PPoint(self.y, -self.x)
end

function PPoint:Rotate(phi)
	local c, s = MathCos(phi), MathSin(phi)
	self.x, self.y = self.x * c + self.y * s, self.y * c - self.x * s
end

function PPoint:Rotated(phi)
	local p = self:Clone()
	p:Rotate(phi); return p
end

function PPoint:Round()
	local p = self:Clone()
	p.x, p.y = Round(p.x), Round(p.y)
	return p
end

class "Geometry"

function Geometry:__init()
end

function Geometry:AngleBetween(p1, p2)
	local angle = MathAbs(MathDeg(MathAtan2(p3.y - p1.y,
		p3.x - p1.x) - MathAtan2(p2.y - p1.y, p2.x - p1.x)))
	if angle < 0 then angle = angle + 360 end
	return angle > 180 and 360 - angle or angle
end

function Geometry:CalcSkillshotPosition(data, time)
	local t = MathMax(0, GameTimer() + time - data.startTime - data.delay)
	t = MathMax(0, MathMin(self:Distance(data.startPos, data.endPos), data.speed * t))
	return PPoint(data.startPos):Extended(data.endPos, t)
end

function Geometry:ClosestPointOnSegment(s1, s2, pt)
	local ab = PPoint(s2 - s1)
	local t = ((pt.x - s1.x) * ab.x + (pt.y - s1.y) * ab.y) / (ab.x * ab.x + ab.y * ab.y)
	return t < 0 and PPoint(s1) or (t > 1 and PPoint(s2) or PPoint(s1 + t * ab))
end

function Geometry:CrossProduct(p1, p2)
	return p1.x * p2.y - p1.y * p2.x
end

function Geometry:Distance(p1, p2)
	return MathSqrt(self:DistanceSquared(p1, p2))
end

function Geometry:DistanceSquared(p1, p2)
	local dx, dy = p2.x - p1.x, p2.y - p1.y
	return dx * dx + dy * dy
end

function Geometry:DotProduct(p1, p2)
	return p1.x * p2.x + p1.y * p2.y
end

function Geometry:GetCircularAOEPos(points, radius)
	local bestPos, count = PPoint(0, 0), #points
	if count == 0 then return nil, 0 end
	if count == 1 then return points[1], 1 end
	local inside, furthest, id = 0, 0, 0
	for i, point in ipairs(points) do
		bestPos = bestPos + point
	end
	bestPos = bestPos / count
	for i, point in ipairs(points) do
		local distSqr = self:DistanceSquared(bestPos, point)
		if distSqr < radius * radius then inside = inside + 1 end
		if distSqr > furthest then furthest = distSqr; id = i end
	end
	if inside == count then
		return bestPos, count
	else
		TableRemove(points, id)
		return self:GetCircularAOEPos(points, radius)
	end
end

function Geometry:GetDynamicLinearAOEPos(points, minRange, maxRange, radius)
	local count = #points
	if count == 0 then return nil, nil, 0 end
	if count == 1 then return points[1], points[1], 1 end
	local myPos, bestStartPos, bestEndPos, bestCount, candidates =
		self:To2D(myHero.pos), PPoint(0, 0), PPoint(0, 0), 0, {}
	for i, p1 in ipairs(points) do
		TableInsert(candidates, p1)
		for j, p2 in ipairs(points) do
			if i ~= j then TableInsert(candidates,
				PPoint(p1 + p2) / 2) end
		end
	end
	local diffRange = maxRange - minRange
	for i, point in ipairs(points) do
		if Geometry:DistanceSquared(myPos, point) <= minRange * minRange then
			for j, candidate in ipairs(candidates) do
				if Geometry:DistanceSquared(candidate, point) <= diffRange * diffRange then
					local endPos, hitCount = PPoint(point):Extended(candidate, diffRange), 0
					for k, testPoint in ipairs(points) do
						if self:DistanceSquared(testPoint, self:ClosestPointOnSegment(myPos,
							endPos, testPoint)) < radius * radius then hitCount = hitCount + 1
						end
					end
					if hitCount > bestCount then
						bestStartPos, bestEndPos, bestCount = point, endPos, hitCount
					end
				end
			end
		end
	end
	return bestStartPos, bestEndPos, bestCount
end

function Geometry:GetStaticLinearAOEPos(points, range, radius)
	local count = #points
	if count == 0 then return nil, 0 end
	if count == 1 then return points[1], 1 end
	local myPos, bestPos, bestCount, candidates =
		self:To2D(myHero.pos), PPoint(0, 0), 0, {}
	for i, p1 in ipairs(points) do
		TableInsert(candidates, p1)
		for j, p2 in ipairs(points) do
			if i ~= j then TableInsert(candidates,
				PPoint(p1 + p2) / 2) end
		end
	end
	for i, candidate in ipairs(candidates) do
		local endPos, hitCount =
			PPoint(myPos):Extended(candidate, range), 0
		for j, point in ipairs(points) do
			if self:DistanceSquared(point, self:ClosestPointOnSegment(myPos,
				endPos, point)) < radius * radius then hitCount = hitCount + 1
			end
		end
		if hitCount > bestCount then
			bestPos, bestCount = endPos, hitCount
		end
	end
	return bestPos, bestCount
end

function Geometry:LineCircleIntersection(p1, p2, circle, radius)
	local d1, d2 = PPoint(p2 - p1), PPoint(p1 - circle)
	local a = d1:MagnitudeSquared()
	local b = 2 * self:DotProduct(d1, d2)
	local c = d2:MagnitudeSquared() - (radius * radius)
	local delta = b * b - 4 * a * c
	if delta >= 0 then
		local sqr = MathSqrt(delta)
		local t1, t2 = (-b + sqr) / (2 * a), (-b - sqr) / (2 * a)
		return PPoint(p1 + d1 * t1), PPoint(p1 + d1 * t2)
	end
	return nil, nil
end

function Geometry:RotateAroundPoint(p1, p2, theta)
	local p, s, c = PPoint(p2 - p1), MathSin(theta), MathCos(theta)
	return PPoint(c * p.x - s * p.y + p1.x, s * p.x + c * p.y + p1.y)
end

function Geometry:To2D(pos)
	return PPoint(pos.x, pos.z or pos.y)
end

function Geometry:To3D(pos, y)
	return Vector(pos.x, y or myHero.pos.y, pos.y)
end

function Geometry:ToScreen(pos, y)
	return Vector(self:To3D(pos, y)):To2D()
end

class "Manager"

function Manager:__init()
end

function Manager:CalcMagicalDamage(source, target, amount, time)
	local mr = target.magicResist * source.magicPenPercent - source.magicPen
	local val = mr < 0 and 2 - 100 / (100 - mr) or 100 / (100 + mr)
	return MathMax(0, MathFloor(val * amount) - target.hpRegen * (time or 0))
end

function Manager:CalcPhysicalDamage(source, target, amount, time)
	local ar = target.armor * source.armorPenPercent -
		(target.bonusArmor * (1 - source.bonusArmorPenPercent)) -
		(source.armorPen * (0.6 + (0.4 * (target.levelData.lvl / 18))))
	local val = ar < 0 and 2 - 100 / (100 - ar) or 100 / (100 + ar)
	return MathMax(0, MathFloor(val * amount) - target.hpRegen * (time or 0))
end

function Manager:CopyTable(tab)
	local copy = {}
	for key, val in pairs(tab) do
		copy[key] = val end
	return copy
end

function Manager:DrawPolygon(poly, width, color)
	local size = #poly; if size < 3 then
		return end; local j = size
	for i = 1, size do
		DrawLine(poly[i].x, poly[i].y, poly[j].x,
			poly[j].y, width, color); j = i
	end
end

function Manager:GetAllyHeroes()
	local allies = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit and unit.isAlly and not unit.isMe then
			TableInsert(allies, unit)
		end
	end
	return allies
end

function Manager:GetEnemyHeroes()
	local enemies = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit and unit.isEnemy then
			TableInsert(enemies, unit)
		end
	end
	return enemies
end

function Manager:GetEnemiesAround(pos, range)
	local units = {}
	for i, enemy in ipairs(self:GetEnemyHeroes()) do
		if enemy and self:IsValid(enemy, range, pos) then
			TableInsert(units, enemy)
		end
	end
	return units
end

function Manager:GetSpellCooldown(spell)
	return GameCanUseSpell(spell) == ONCOOLDOWN
		and myHero:GetSpellData(spell).currentCd or
		GameCanUseSpell(spell) == READY and 0 or MathHuge
end

function Manager:GetMinionsAround(pos, range, type)
	local minions = {}
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and self:IsValid(minion, range, pos) then
			if type == 2 and minion.isAlly or minion.isEnemy then
				TableInsert(minions, minion)
			end
		end
	end
	return minions
end

function Manager:GetOrbwalkerMode()
	if _G.SDK then
		return _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo"
		or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass"
		or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "LaneClear"
		or nil
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetMode()
	end
	return nil
end

function Manager:GetPercentHealth(unit)
	return 100 * unit.health / unit.maxHealth
end

function Manager:GetPercentMana()
	return 100 * myHero.mana / myHero.maxMana
end

function Manager:GetPriority(unit)
	local priority = Priorities[unit.charName] or 3
	return priority == 1 and 1 or
		priority == 2 and 1.5 or
		priority == 3 and 1.75 or
		priority == 4 and 2 or 2.5
end

function Manager:GetSummonerLevel()
	return myHero.levelData.lvl > 18
		and 1 or myHero.levelData.lvl
end

function Manager:IsAutoAttacking()
	return _G.SDK and _G.SDK.Orbwalker:IsAutoAttacking() or
		_G.PremiumOrbwalker and _G.PremiumOrbwalker:IsAutoAttacking() or false
end

function Manager:IsReady(spell)
	return GameCanUseSpell(spell) == READY
end

function Manager:IsUnderTurret(pos)
	for i = 1, GameTurretCount() do
		local turret = GameTurret(i)
		if turret and turret.valid and turret.isEnemy and turret.health > 0 then
			if Geometry:Distance(pos, Geometry:To2D(turret.pos)) <= 775 +
				(myHero.boundingRadius or 65) * 2 then return true
			end
		end
	end
	return false
end

function Manager:IsValid(unit, range, pos)
	local range = range or 12500
	local pos = pos or Geometry:To2D(myHero.pos)
	return unit and unit.valid and unit.visible and unit.health > 0 and unit.maxHealth > 5
		and Geometry:DistanceSquared(pos, Geometry:To2D(unit.pos)) <= range * range
end

class "Viktor"

function Viktor:__init()
	self.StartPos, self.EndPos, self.MPos = nil, nil, nil
	self.AttackRange, self.QueueTimer = myHero.range + myHero.boundingRadius + 35, 0
	self.Ignite = myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and {SUMMONER_1, HK_SUMMONER_1} or
		myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and {SUMMONER_2, HK_SUMMONER_2} or nil
	self.Q = {speed = 2000, range = 600, delay = 0.25}
	self.W = {speed = MathHuge, range = 800, delay = 1.75, radius = 270, windup = 0.25, collision = nil, type = "circular"}
	self.E = {speed = 1050, minRange = 525, range = 700, maxRange = 1225, delay = 0, radius = 80, collision = nil, type = "linear"}
	self.R = {speed = MathHuge, range = 700, delay = 0.25, radius = 325, windup = 0.25, collision = nil, type = "circular"}
	self.HasTurboCharge = function(name) return name == "ViktorPowerTransferReturn" end
	self.ViktorMenu = MenuElement({type = MENU, id = "Viktor", name = "Impuls Viktor v" .. Versions[myHero.charName]})
	self.ViktorMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.ViktorMenu.Combo:MenuElement({id = "UseQ", name = "Q [Siphon Power]", value = true, leftIcon = HeroIcon})
	self.ViktorMenu.Combo:MenuElement({id = "UseW", name = "W [Gravity Field]", value = true, leftIcon = WIcon})
	self.ViktorMenu.Combo:MenuElement({id = "UseE", name = "E [Death Ray]", value = true, leftIcon = EIcon})
	self.ViktorMenu.Combo:MenuElement({id = "UseR", name = "R [Chaos Storm]", value = true, leftIcon = RIcon})
	self.ViktorMenu.Combo:MenuElement({id = "MinW", name = "W: Minimum Enemies", value = 2, min = 1, max = 5, step = 1})
	self.ViktorMenu.Combo:MenuElement({id = "MinR", name = "R: Minimum Enemies", value = 2, min = 1, max = 5, step = 1})
	self.ViktorMenu.Combo:MenuElement({id = "MaxHPR", name = "R: Maximum Health [%]", value = 35, min = 1, max = 100, step = 1})
	self.ViktorMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.ViktorMenu.Harass:MenuElement({id = "UseQ", name = "Q [Siphon Power]", value = true, leftIcon = QIcon})
	self.ViktorMenu.Harass:MenuElement({id = "UseW", name = "W [Gravity Field]", value = false, leftIcon = WIcon})
	self.ViktorMenu.Harass:MenuElement({id = "UseE", name = "E [Death Ray]", value = true, leftIcon = EIcon})
	self.ViktorMenu.Harass:MenuElement({id = "MinW", name = "W: Minimum Enemies", value = 2, min = 1, max = 5, step = 1})
	self.ViktorMenu:MenuElement({id = "LaneClear", name = "LaneClear", type = MENU})
	self.ViktorMenu.LaneClear:MenuElement({id = "UseE", name = "E [Death Ray]", value = true, leftIcon = EIcon})
	self.ViktorMenu.LaneClear:MenuElement({id = "ManaE", name = "E: Mana Manager", value = 55, min = 0, max = 100, step = 5})
	self.ViktorMenu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	self.ViktorMenu.Drawings:MenuElement({id = "DrawQ", name = "Q: Draw Range", value = true})
	self.ViktorMenu.Drawings:MenuElement({id = "DrawW", name = "W: Draw Range", value = true})
	self.ViktorMenu.Drawings:MenuElement({id = "DrawE", name = "E: Draw Range", value = true})
	self.ViktorMenu.Drawings:MenuElement({id = "DrawR", name = "R: Draw Range", value = true})
	self.ViktorMenu.Drawings:MenuElement({id = "Track", name = "Track Enemies", value = true})
	self.ViktorMenu:MenuElement({id = "HitChance", name = "HitChance", type = MENU})
	self.ViktorMenu.HitChance:MenuElement({id = "HCW", name = "W: HitChance", value = 70, min = 0, max = 100, step = 5})
	self.ViktorMenu.HitChance:MenuElement({id = "HCR", name = "R: HitChance", value = 80, min = 0, max = 100, step = 5})
    self.ViktorMenu:MenuElement({type = MENU, id = "AutoLevel", name =  myHero.charName.." AutoLevel Spells"})
    self.ViktorMenu.AutoLevel:MenuElement({id = "on", name = "Enabled", value = true})
    self.ViktorMenu.AutoLevel:MenuElement({id = "LvL", name = "AutoLevel start -->", value = 5, min = 1, max = 6, step = 1})
    self.ViktorMenu.AutoLevel:MenuElement({id = "delay", name = "Delay for Level up", value = 2, min = 0 , max = 10, step = 0.5, identifier = "sec"})
    self.ViktorMenu.AutoLevel:MenuElement({id = "Order", name = "Skill Order", value = 3, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})
    self.ViktorMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.ViktorMenu.Pred:MenuElement({name = " ", drop = {"After change Prediction Type press 2xF6"}})	
	self.ViktorMenu.Pred:MenuElement({id = "Change", name = "Change Prediction Type", value = 4, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction", "InternalPrediction"}})	
	self.ViktorMenu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})
	self.ViktorMenu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
	self.ViktorMenu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
	if self.Ignite then
		self.ViktorMenu:MenuElement({id = "Misc", name = "Misc", type = MENU})
		self.ViktorMenu.Misc:MenuElement({id = "UseIgnite", name = "Use Ignite", value = true, leftIcon = IgniteIcon})
	end
	Callback.Add("Tick", function() self:OnTick() end)
	Callback.Add("Draw", function() self:OnDraw() end)
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
	end
end

function Viktor:GetSkillOrder()
	local Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	if self.ViktorMenu.AutoLevel.Order:Value() == 1 then
		Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 2 then
		Spell1, Spell2, Spell3 = HK_W, HK_E, HK_Q
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 3 then
		Spell1, Spell2, Spell3 = HK_E, HK_Q, HK_W
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 4 then
		Spell1, Spell2, Spell3 = HK_E, HK_W, HK_Q
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 5 then
		Spell1, Spell2, Spell3 = HK_W, HK_Q, HK_E
	elseif self.ViktorMenu.AutoLevel.Order:Value() == 6 then
		Spell1, Spell2, Spell3 = HK_Q, HK_E, HK_W
	end
	return Spell1, Spell2, Spell3
end

function Viktor:AutoLevelStart()
	if self.ViktorMenu.AutoLevel.on:Value() and not self.levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts
		local Spell1, Spell2, Spell3 = self:GetSkillOrder() 

		if (actualLevel == 18 and levelPoints == 0) or self.ViktorMenu.AutoLevel.LvL:Value() > actualLevel then return end
	
		if levelPoints > 0 then
			self.levelUP = true
			local Delay = self.ViktorMenu.AutoLevel.delay:Value()
			DelayAction(function()
				if actualLevel == 6 or actualLevel == 11 or actualLevel == 16 then
					Control.KeyDown(HK_LUS)
					Control.KeyDown(HK_R)
					Control.KeyUp(HK_R)
					Control.KeyUp(HK_LUS)
				elseif actualLevel == 1 or actualLevel == 4 or actualLevel == 5 or actualLevel == 7 or actualLevel == 9 then
					Control.KeyDown(HK_LUS)
					Control.KeyDown(Spell1)
					Control.KeyUp(Spell1)
					Control.KeyUp(HK_LUS)
				elseif actualLevel == 2 or actualLevel == 8 or actualLevel == 10 or actualLevel == 12 or actualLevel == 13 then
					Control.KeyDown(HK_LUS)
					Control.KeyDown(Spell2)
					Control.KeyUp(Spell2)
					Control.KeyUp(HK_LUS)
				elseif actualLevel == 3 or actualLevel == 14 or actualLevel == 15 or actualLevel == 17 or actualLevel == 18 then				
					Control.KeyDown(HK_LUS)
					Control.KeyDown(Spell3)
					Control.KeyUp(Spell3)
					Control.KeyUp(HK_LUS)
				end
				DelayAction(function()
					self.levelUP = false
				end, 0.25)				
			end, Delay)	
		end
	end	
end

function Viktor:CustomCastSpell(startPos, endPos)
	self.StartPos, self.EndPos, self.MPos = startPos, endPos, mousePos
end

function Viktor:GetBestLaserCastPos()
	if GameTimer() - self.QueueTimer <= 0.25 or self.EndPos then return end
	local candidates = Manager:GetEnemiesAround(self.MyPos, self.E.maxRange)
	if #candidates == 0 then return end
	TableSort(candidates, function(a, b) return
		Geometry:DistanceSquared(self.MyPos, Geometry:To2D(a.pos)) <
		Geometry:DistanceSquared(self.MyPos, Geometry:To2D(b.pos))
	end)
	local unitPos, dir = Geometry:To2D(candidates[1].pos), Geometry:To2D(candidates[1].dir)
	if Geometry:DistanceSquared(self.MyPos, unitPos) > self.E.minRange * self.E.minRange then
		local startPos = Geometry:To3D(self.MyPos:Extended(unitPos, self.E.minRange))
		local predPos = _G.PremiumPrediction:GetPrediction(startPos, candidates[1], self.E).CastPos
		if predPos == nil then return end
		if Geometry:DistanceSquared(self.MyPos, Geometry:To2D(predPos))
			> self.E.maxRange * self.E.maxRange then return end
		if predPos:To2D().onScreen then
			self:CustomCastSpell(startPos, predPos)
		else
			self.QueueTimer = GameTimer()
			local castPos = self.MyPos:Extended(Geometry:To2D(predPos), self.E.minRange)
			_G.Control.CastSpell(HK_E, Geometry:To3D(castPos))
		end
	else
		local predPos = #candidates > 1 and
			_G.PremiumPrediction:GetPrediction(
			Geometry:To3D(unitPos), candidates[2], self.E).CastPos or
			(_G.PremiumPrediction:IsMoving(candidates[1]) and
			_G.PremiumPrediction:GetPositionAfterTime(candidates[1], 1) or
			Geometry:To3D(PPoint(unitPos + dir * self.E.radius)))
		if predPos == nil then return end
		local endPos = Geometry:To3D(unitPos:Extended(
			Geometry:To2D(predPos), self.E.range))
		self:CustomCastSpell(candidates[1].pos, endPos)
	end
end

function Viktor:GetTarget(range)
	local units = {}
	for i, enemy in ipairs(Manager:GetEnemyHeroes()) do
		if Manager:IsValid(enemy, range, self.MyPos) then
			TableInsert(units, enemy)
		end
	end
	TableSort(units, function(a, b) return
		Manager:CalcMagicalDamage(myHero, a, 100) / (1 + a.health) * Manager:GetPriority(a) >
		Manager:CalcMagicalDamage(myHero, b, 100) / (1 + b.health) * Manager:GetPriority(b)
	end)
	return #units > 0 and units[1] or nil
end

function Viktor:OnPreAttack(args)
	if Manager:GetOrbwalkerMode() == "Combo" then
		local target = self:GetTarget(self.AttackRange)
		if target then args.Target = target; return end
	end
end

function Viktor:OnTick()
	self.MyPos = Geometry:To2D(myHero.pos)
	if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading)
		or Manager:IsAutoAttacking() or Game.IsChatOpen() or myHero.dead then return end
	if ControlIsKeyDown(HK_E) then
		if self.EndPos then
			ControlSetCursorPos(self.EndPos)
			ControlKeyUp(HK_E)
			self.EndPos = nil
			DelayAction(function()
				ControlSetCursorPos(self.MPos)
			end, 0.01); return
		elseif not Manager:IsReady(_E) then
			ControlKeyUp(HK_E)
		end
	elseif self.StartPos then
		ControlSetCursorPos(self.StartPos)
		ControlKeyDown(HK_E)
		self.StartPos = nil; return
	end
	if self.Ignite then self:Auto() end
	local mode = Manager:GetOrbwalkerMode()
	if mode == "LaneClear" then self:Clear(); return end
	if Manager:IsReady(_E) and ((mode == "Combo" and self.ViktorMenu.Combo.UseE:Value()) or
		(mode == "Harass" and self.ViktorMenu.Harass.UseE:Value())) then
			self:GetBestLaserCastPos()
	end
	local tQ, tW = self:GetTarget(self.Q.range), self:GetTarget(self.W.range)
	if mode == "Combo" then self:Combo(tQ, tW, self:GetTarget(self.R.range))
	elseif mode == "Harass" then self:Harass(tQ, tW) end
    if Game.IsOnTop() then
		self:AutoLevelStart()
	end	
    if not PredLoaded then
		DelayAction(function()
			if self.ViktorMenu.Pred.Change:Value() == 1 then
				require('GamsteronPrediction')
				PredLoaded = true
			elseif self.ViktorMenu.Pred.Change:Value() == 2 then
				require('PremiumPrediction')
				PredLoaded = true
			else 
				require('GGPrediction')
				PredLoaded = true					
			end
		end, 1)	
	end
	DelayAction(function()
		if self.ViktorMenu.Pred.Change:Value() == 1 then
			self.QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 210, Range = 800, Speed = math.huge, Collision = false, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
			self.WData = {Type = _G.SPELLTYPE_LINE, Delay = 0.00, Radius = 490, Range = 490, Speed = 2000, Collision = false, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
			self.EData = {Type = _G.SPELLTYPE_LINE, Delay = 0.4JUdGzvrMFDWrUUwY3toJATSeNwjn54LkCnKBPRzDuhzi5vSepHfUckJNxRL2gjkNrSqtCoRUrEDAgRwsQvVCjZbRyFTLRNyDmT1a1boZV = {_G.COLLISION_MINION}}
			self.RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.50, Radius = 160, Range = 1150, Speed =  3200, Collision = true, MaxCollision = 1, CollisionTypes = {_G.COLLISION_ENEMYHERO}}
        end
		if self.ViktorMenu.Pred.Change:Value() == 2 then
			self.QspellData = {speed = math.huge, range = 1025, delay = 0.25, radius = 210, type = "circular"}
            self.WspellData = {speed = 2000, range = 1025, delay = 0.00, radius = 490, type = "conic"}
            self.EspellData = {speed = 1200, range = 1025, delay = 0.45, radius = 80, collision = {"minion"}, type = "linear"}
            self.RspellData = {speed = 3200, range = 1025, delay = 0.50, radius = 160, type = "linear"}
		end
		if self.ViktorMenu.Pred.Change:Value() == 3 then  
            self.QPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 210, Range = 800, Speed = MathHuge, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
            self.WPrediction = GGPrediction:SpellPrediction({Delay = 0.00, Radius = 490, Range = 490, Speed = 2000, Collision = false, Type = GGPrediction.SPELLTYPE_CONE})
            self.EPrediction = GGPrediction:SpellPrediction({Delay = 0.45, Radius = 80,  Range = 450, Speed = 1200, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
            self.RPrediction = GGPrediction:SpellPrediction({Delay = 0.50, Radius = 160, Range = 1150, Speed = 3200, Collision = true, CollisionTypes = {GGPrediction.COLLISION_ENEMYHERO}, Type = GGPrediction.SPELLTYPE_LINE})
        end
            if self.ViktorMenu.Pred.Change:Value() == 4 then 
        end
	end, 1.2)	
end

function Viktor:OnDraw()
	if Game.IsChatOpen() or myHero.dead then return end
	if self.ViktorMenu.Drawings.DrawQ:Value() then
		DrawCircle(myHero.pos, self.Q.range, 1, Draw.Color(96, 0, 206, 209))
	end
	if self.ViktorMenu.Drawings.DrawW:Value() then
		DrawCircle(myHero.pos, self.W.range, 1, Draw.Color(96, 138, 43, 226))
	end
	if self.ViktorMenu.Drawings.DrawE:Value() then
		DrawCircle(myHero.pos, self.E.minRange, 1, Draw.Color(96, 255, 140, 0))
		DrawCircle(myHero.pos, self.E.maxRange, 1, Draw.Color(96, 255, 140, 0))
	end
	if self.ViktorMenu.Drawings.DrawR:Value() then
		DrawCircle(myHero.pos, self.R.range, 1, Draw.Color(96, 218, 112, 214))
	end
	if not self.MyPos then return end
	if self.ViktorMenu.Drawings.Track:Value() then
		for i, enemy in ipairs(Manager:GetEnemyHeroes()) do
			if enemy and enemy.valid and enemy.visible then
				local dist = Geometry:DistanceSquared(self.MyPos, Geometry:To2D(enemy.pos))
				DrawLine(myHero.pos:To2D(), enemy.pos:To2D(), 2.5,
					dist < 4000000 and Draw.Color(128, 220, 20, 60)
					or dist < 16000000 and Draw.Color(128, 240, 230, 140)
					or Draw.Color(128, 152, 251, 152))
			end
		end
	end
end

function Viktor:Clear()
	if GameTimer() - self.QueueTimer <= 0.25 or self.EndPos then return end
	if Manager:IsReady(_E) and self.ViktorMenu.LaneClear.UseE:Value() and
		Manager:GetPercentMana() > self.ViktorMenu.LaneClear.ManaE:Value() then
		local minions, points = Manager:GetMinionsAround(self.MyPos, self.E.maxRange), {}
		if #minions < 5 then return end
		for i, minion in ipairs(minions) do
			local predPos = _G.PremiumPrediction:GetFastPrediction(myHero, minion, self.E)
			if predPos then TableInsert(points, Geometry:To2D(predPos)) end
		end
		local startPos, endPos, count = Geometry:GetDynamicLinearAOEPos(
			points, self.E.minRange, self.E.maxRange, self.E.radius)
		if startPos and endPos and count >= 5 then
			self:CustomCastSpell(Geometry:To3D(startPos), Geometry:To3D(endPos))
		end
	end
end

function Viktor:Auto()
	if not self.ViktorMenu.Misc.UseIgnite:Value() or not
		Manager:IsReady(self.Ignite[1]) or Manager:IsReady(_E) then return end
	local units = Manager:GetEnemiesAround(self.MyPos, 600)
	for i, enemy in ipairs(units) do
		local dmg = 50 + 20 * Manager:GetSummonerLevel()
		if dmg >= (enemy.health + enemy.hpRegen * 3) then
			_G.Control.CastSpell(self.Ignite[2], enemy.pos); break
		end
	end
end

function Viktor:Combo(targetQ, targetW, targetR)
	if GameTimer() - self.QueueTimer <= 0.25 or self.EndPos then return end
	if targetQ and Manager:IsReady(_Q) and self.ViktorMenu.Combo.UseQ:Value() then
		self.QueueTimer = GameTimer()
		_G.Control.CastSpell(HK_Q, targetQ.pos)
	end
	if targetW and Manager:IsReady(_W) and self.ViktorMenu.Combo.UseW:Value() then
		local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, targetW, self.W)
		if pred.CastPos and pred.HitChance >= self.ViktorMenu.HitChance.HCW:Value() / 1000 and
			pred.HitCount >= self.ViktorMenu.Combo.MinW:Value() then
				self.QueueTimer = GameTimer()
				_G.Control.CastSpell(HK_W, pred.CastPos)
		end
	end
	if targetR and Manager:IsReady(_R) and self.ViktorMenu.Combo.UseR:Value() and
		Manager:GetPercentHealth(targetR) <= self.ViktorMenu.Combo.MaxHPR:Value() then
		local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, targetR, self.R)
		if pred.CastPos and pred.HitChance >= self.ViktorMenu.HitChance.HCR:Value() / 1000 and
			pred.HitCount >= self.ViktorMenu.Combo.MinR:Value() then
				self.QueueTimer = GameTimer()
				_G.Control.CastSpell(HK_R, pred.CastPos)
		end
	end
end

function Viktor:Harass(targetQ, targetW)
	if GameTimer() - self.QueueTimer <= 0.25 or self.EndPos then return end
	if targetQ and Manager:IsReady(_Q) and self.ViktorMenu.Harass.UseQ:Value() then
		self.QueueTimer = GameTimer()
		_G.Control.CastSpell(HK_Q, targetQ.pos)
	end
	if targetW and Manager:IsReady(_W) and self.ViktorMenu.Harass.UseW:Value() then
		local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, targetW, self.W)
		if pred.CastPos and pred.HitChance >= self.ViktorMenu.HitChance.HCW:Value() / 1000 and
			pred.HitCount >= self.ViktorMenu.Harass.MinW:Value() then
				self.QueueTimer = GameTimer()
				_G.Control.CastSpell(HK_W, pred.CastPos)
		end
	end
end
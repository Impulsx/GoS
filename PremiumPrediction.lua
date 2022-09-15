-- Premium Prediction
-- Author: Ark223

local Version, IntVer = 1.15, "1.1.5"

require "2DGeometry"
require "MapPositionGOS"

local MathAbs, MathAtan, MathAtan2, MathAcos, MathCeil, MathCos, MathDeg, MathFloor, MathHuge, MathMax, MathMin, MathPi, MathRad, MathSin, MathSqrt =
	math.abs, math.atan, math.atan2, math.acos, math.ceil, math.cos, math.deg, math.floor, math.huge, math.max, math.min, math.pi, math.rad, math.sin, math.sqrt
local DrawCircle, GameCanUseSpell, GameLatency, GameTimer, GameHero, GameMinion = Draw.Circle, Game.CanUseSpell, Game.Latency, Game.Timer, Game.Hero, Game.Minion
local TableInsert, TableRemove, TableSort = table.insert, table.remove, table.sort

local CCBuffs, CustomData = {[5] = true, [8] = true, [12] = true, --[18] = true,
	[22] = true, [23] = true, [30] = true, [35] = true}, {}

	--[[ {[5] = true, [8] = true, [11] = true, [18] = true,
	[21] = true, [22] = true, [24] = true, [28] = true, [29] = true} ]]
local DashWindups = {
	["AkaliE"] = 0.25,
	["CaitlynEntrapment"] = 0.25,
	["EzrealE"] = 0.25,
	["Crowstorm"] = 1.5,
	["GalioE"] = 0.4,
	["RiftWalk"] = 0.25,
	["OrnnE"] = 0.35,
	["ShyvanaTransformLeap"] = 0.25,
	["TristanaW"] = 0.25,
	["UrgotE"] = 0.45,
	["WarwickR"] = 0.1
}

local function GameHeroCount()
	local c = Game.HeroCount()
	return (not c or c < 0 or c > 12) and 0 or c
end

local function GameMinionCount()
	local c = Game.MinionCount()
	return (not c or c < 0 or c > 500) and 0 or c
end

local function GetBuffCount(unit)
	local c = unit.buffCount
	return (not c or c < 0 or c > 63) and -1 or c
end

local function GetPathCount(unit)
	local c = unit.pathing.pathCount
	return (not c or c < 0 or c > 20) and -1 or c
end

local function GetPathIndex(unit)
	local i = unit.pathing.pathIndex
	return (not i or i < 0 or i > 20) and -1 or i
end

local function Class()
	local cls = {}; cls.__index = cls
	return setmetatable(cls, {__call = function (c, ...)
		local instance = setmetatable({}, cls)
		if cls.__init then cls.__init(instance, ...) end
		return instance
	end})
end

--[[
	┌─┐┌─┐┬┌┐┌┌┬┐
	├─┘│ │││││ │ 
	┴  └─┘┴┘└┘ ┴ 
--]]

local function IsPoint(p)
	return p and p.x and type(p.x) == "number" and p.y and type(p.y) == "number"
end

local function IsVector(v)
	return v and v.x and type(v.x) == "number" and v.y and type(v.y) == "number" and v.z and type(v.z) == "number"
end

local Point2 = Class()

function Point2:__init(x, y)
	if not x then self.x, self.y = 0, 0
	elseif not y then self.x, self.y = x.x, x.y
	else self.x = x; if y and type(y) == "number" then self.y = y end end
end

function Point2:__type()
	return "Point"
end

function Point2:__eq(p)
	return (self.x == p.x and self.y == p.y)
end

function Point2:__add(p)
	return Point2(self.x + p.x, (p.y and self.y) and self.y + p.y)
end

function Point2:__sub(p)
	return Point2(self.x - p.x, (p.y and self.y) and self.y - p.y)
end

function Point2.__mul(a, b)
	if type(a) == "number" and IsPoint(b) then
		return Point2(b.x * a, b.y * a)
	elseif type(b) == "number" and IsPoint(a) then
		return Point2(a.x * b, a.y * b)
	end
end

function Point2.__div(a, b)
	if type(a) == "number" and IsPoint(b) then
		return Point2(a / b.x, a / b.y)
	else
		return Point2(a.x / b, a.y / b)
	end
end

function Point2:__tostring()
	return "("..self.x..", "..self.y..")"
end

function Point2:Clone()
	return Point2(self)
end

function Point2:Extended(to, distance)
	return self + (Point2(to) - self):Normalized() * distance
end

function Point2:Magnitude()
	return MathSqrt(self:MagnitudeSquared())
end

function Point2:MagnitudeSquared(p)
	local p = p and Point2(p) or self
	return self.x * self.x + self.y * self.y
end

function Point2:Normalize()
	local dist = self:Magnitude()
	self.x, self.y = self.x / dist, self.y / dist
end

function Point2:Normalized()
	local p = self:Clone()
	p:Normalize(); return p
end

function Point2:Perpendicular()
	return Point2(-self.y, self.x)
end

function Point2:Perpendicular2()
	return Point2(self.y, -self.x)
end

function Point2:Rotate(phi)
	local c, s = MathCos(phi), MathSin(phi)
	self.x, self.y = self.x * c + self.y * s, self.y * c - self.x * s
end

function Point2:Rotated(phi)
	local p = self:Clone()
	p:Rotate(phi); return p
end

--[[
	┌┬┐┌─┐┌─┐
	│││├┤ │  
	┴ ┴└─┘└─┘
--]]

local MEC = Class()

function MEC:__init()
end

function MEC:FindMinimalBoundingCircle(points)
	local hull = self:MakeConvexHull(points)
	local center, radius2 = points[1], MathHuge
	for i = 1, #hull - 1 do
		for j = i + 1, #hull do
			local testCenter = Point2((hull[i].x + hull[j].x) / 2, (hull[i].y + hull[j].y) / 2)
			local dx, dy = testCenter.x - hull[i].x, testCenter.y - hull[i].y
			local testRadius2 = dx * dx + dy * dy
			if testRadius2 < radius2 then
				if self:CircleEnclosesPoints(testCenter, testRadius2, points, i, j, -1) then
					center, radius2 = testCenter, testRadius2
				end
			end
		end
	end
	for i = 1, #hull - 2 do
		for j = i + 1, #hull - 1 do
			for k = j + 1, #hull do
				local testCenter, testRadius2 = self:FindCircle(hull[i], hull[j], hull[k])
				if testRadius2 < radius2 then
					if self:CircleEnclosesPoints(testCenter, testRadius2, points, i, j, k) then
						center, radius2 = testCenter, testRadius2
					end
				end
			end
		end
	end
	return center, radius2 == MathHuge and 0 or MathSqrt(radius2)
end

function MEC:GetMEC(points)
	local convexHull = self:MakeConvexHull(points)
	local center, radius = self:FindMinimalBoundingCircle(convexHull)
	return {Center = center, Radius = radius}
end

function MEC:MakeConvexHull(points)
	local points, bestPt, toRemove = self:HullCull(points), {points[1]}, 1
	for i, point in ipairs(points) do
		if (point.y < bestPt[1].y) or (point.y == bestPt[1].y
			and point.x < bestPt[1].x) then bestPt[1], toRemove = point, i
		end
	end
	local hull, sweepAngle = {bestPt[1]}, 0
	TableRemove(points, toRemove)
	while true do
		if #points == 0 then break end
		local x, y, bestAngle = hull[#hull].x, hull[#hull].y, 3600
		bestPt[1], toRemove = points[1], 1
		for i, point in ipairs(points) do
			local testAngle = self:AngleValue(x, y, point.x, point.y)
			if testAngle >= sweepAngle and bestAngle > testAngle then
				bestAngle, bestPt[1], toRemove = testAngle, point, i
			end
		end
		local firstAngle = self:AngleValue(x, y, hull[1].x, hull[1].y)
		if firstAngle >= sweepAngle and bestAngle >= firstAngle then break end
		TableInsert(hull, bestPt[1]); TableRemove(points, toRemove)
		sweepAngle = bestAngle
	end
	return hull
end

function MEC:AngleValue(x1, y1, x2, y2)
	local dx = x2 - x1; local ax = MathAbs(dx)
	local dy = y2 - y1; local ay = MathAbs(dy)
	local t = ax + ay == 0 and 40 or dy / (ax + ay)
	t = dx < 0 and 2 - t or (dy < 0 and 4 + t or t)
	return t * 90
end

function MEC:CircleEnclosesPoints(center, radius2, points, skip1, skip2, skip3)
	local unskipped = {}
	for i, point in ipairs(points) do
		if i ~= skip1 and i ~= skip2 and i ~= skip3 then
			TableInsert(unskipped, point)
		end
	end
	local enclosing = 0
	for i, point in ipairs(unskipped) do
		local dx, dy = center.x - point.x, center.y - point.y
		local testRadius2 = dx * dx + dy * dy
		if not (testRadius2 > radius2) then enclosing = enclosing + 1 end
	end
	return enclosing == #unskipped
end

function MEC:FindCircle(a, b, c)
	local x1, y1, dy1, dx1 = (b.x + a.x) / 2, (b.y + a.y) / 2, b.x - a.x, -(b.y - a.y)
	local x2, y2, dy2, dx2 = (c.x + b.x) / 2, (c.y + b.y) / 2, c.x - b.x, -(c.y - b.y)
	local cx = (y1 * dx1 * dx2 + x2 * dx1 * dy2 - x1 * dy1 * dx2 - y2 * dx1 * dx2) / (dx1 * dy2 - dy1 * dx2)
	local cy = (cx - x1) * dy1 / dx1 + y1
	local center = Point2(cx, cy)
	local dx, dy = cx - a.x, cy - a.y
	local radius2 = dx * dx + dy * dy
	return center, radius2
end

function MEC:GetMinMaxBox(points)
	local ul = Point2(0, 0)
	local ur, ll, lr = ul, ul, ul
	ul, ur, lr, ll = self:GetMinMaxCorners(points, ul, ur, ll, lr)
	local xmin, ymin, xmax, ymax = ul.x, ul.y, ur.x, lr.y
	if ymin < ur.y then ymin = ur.y end
	if xmax > lr.x then xmax = lr.x end
	if xmin < ll.x then xmin = ll.x end
	if ymax > ll.y then ymax = ll.y end
	return {xmin, ymin, xmax - xmin, ymax - ymin}
end

function MEC:GetMinMaxCorners(points, ul, ur, ll, lr)
	ul = points[1]; ur, ll, lr = ul, ul, ul
	for i, point in ipairs(points) do
		if -point.x - point.y > -ul.x - ul.y then ul = point end
		if point.x - point.y > ur.x - ur.y then ur = point end
		if -point.x - point.y > -ll.x + ll.y then ll = point end
		if point.x + point.y > lr.x + lr.y then lr = point end
	end
	return ul, ur, lr, ll
end

function MEC:HullCull(points)
	local box, results = self:GetMinMaxBox(points), {}
	local bottom, top, right, left = box[2] + box[4], box[2], box[1] + box[3], box[1]
	for i, point in ipairs(points) do
		if point.x <= left or point.x >= right or point.y <= top or point.y >= bottom then
			TableInsert(results, point)
		end
	end
	return results
end

--[[
	┬┌┐┌┬┌┬┐
	│││││ │ 
	┴┘└┘┴ ┴ 
--]]

local PremiumPred = Class()

function PremiumPred:__init()
	self.Loaded, self.Pi2 = false, 1.57079632679
	self.DashCBs, self.GainCBs, self.LoseCBs, self.PsCBs, self.WpCBs = {}, {}, {}, {}, {}
	self.PPMenu = MenuElement({type = MENU, id = "PremiumPrediction", name = "Premium Prediction v"..IntVer})
	self.PPMenu:MenuElement({id = "Debug", name = "Debug Settings", type = MENU})
	self.PPMenu.Debug:MenuElement({id = "Enable", name = "Enable Debug", value = false})
	self.PPMenu.Debug:MenuElement({id = "Cast", name = "Cast Q Spell", value = true})
	self.PPMenu.Debug:MenuElement({id = "Huge", name = "Huge Speed", value = false})
	self.PPMenu.Debug:MenuElement({id = "Collision", name = "Minion Collision", value = true})
	self.PPMenu.Debug:MenuElement({id = "Speed", name = "Speed", value = 1700, min = 600, max = 5000, step = 25})
	self.PPMenu.Debug:MenuElement({id = "Range", name = "Range", value = 1000, min = 250, max = 5000, step = 25})
	self.PPMenu.Debug:MenuElement({id = "Delay", name = "Delay", value = 0.25, min = 0, max = 3, step = 0.05})
	self.PPMenu.Debug:MenuElement({id = "Radius", name = "Radius", value = 55, min = 5, max = 300, step = 5})
	self.PPMenu.Debug:MenuElement({id = "HitChance", name = "HitChance", value = 0.3, min = 0, max = 1, step = 0.01})
	self.PPMenu:MenuElement({id = "CB", name = "Collision Buffer", value = 15, min = 0, max = 50, step = 1})
	self.PPMenu:MenuElement({id = "Latency", name = "Latency", value = 50, min = 5, max = 200, step = 5})
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	for i, unit in ipairs(self:GetEnemyHeroes()) do self:InitCustomData(unit) end
	self.Loaded = true
end

function PremiumPred:InitCustomData(unit)
	CustomData[unit.networkID] = {
		oldPos = Point2(0, 0), dash = {startPos = Point2(0, 0), endPos = Point2(0, 0), speed = 0},
		waypoints = {}, timers = {}, angles = {}, lengths = {}, spell = nil, visible = false, 
		mia = 0, windup = 0, avgLength = 0, avgMoveClick = 0, avgAngle = 0
	}
end

--[[
	┌─┐┌─┐┌─┐┌┬┐┌─┐┌┬┐┬─┐┬ ┬
	│ ┬├┤ │ ││││├┤  │ ├┬┘└┬┘
	└─┘└─┘└─┘┴ ┴└─┘ ┴ ┴└─ ┴ 
--]]

function PremiumPred:AngleBetween(p1, p2, p3)
	local angle = MathAbs(MathDeg(MathAtan2(p3.y - p1.y, p3.x - p1.x) - MathAtan2(p2.y - p1.y, p2.x - p1.x)))
	if angle < 0 then angle = angle + 360 end
	return angle > 180 and 360 - angle or angle
end

function PremiumPred:AppendVector(p1, p2, dist)
	return p2 + Point2(p2 - p1):Normalized() * dist
end

function PremiumPred:CalcTravelTime(startPos, endPos, spellData)
	return self:Distance(startPos, endPos) / spellData.speed + spellData.delay
end

function PremiumPred:ClosestPointOnSegment(s1, s2, pt)
	local ab = Point2(s2 - s1)
	local t = ((pt.x - s1.x) * ab.x + (pt.y - s1.y) * ab.y) / (ab.x * ab.x + ab.y * ab.y)
	return t < 0 and Point2(s1) or (t > 1 and Point2(s2) or Point2(s1 + t * ab))
end

function PremiumPred:CrossProduct(p1, p2)
	return p1.x * p2.y - p1.y * p2.x
end

function PremiumPred:CutWaypoints(waypoints, distance)
	if distance < 0 then
		waypoints[1] = Point2(waypoints[1]):Extended(waypoints[2], distance)
		return waypoints
	end
	local distance, result = distance, {}
	for i = 1, #waypoints - 1 do
		local dist = self:Distance(waypoints[i], waypoints[i + 1])
		if dist > distance then
			TableInsert(result, Point2(waypoints[i]):Extended(waypoints[i + 1], distance))
			for j = i + 1, #waypoints do TableInsert(result, waypoints[j]) end; break
		end
		distance = distance - dist
	end
	return #result > 0 and result or {waypoints[#waypoints]}
end

function PremiumPred:Distance(p1, p2)
	return MathSqrt(self:DistanceSquared(p1, p2))
end

function PremiumPred:DistanceSquared(p1, p2)
	local dx, dy = p2.x - p1.x, p2.y - p1.y
	return dx * dx + dy * dy
end

function PremiumPred:DotProduct(p1, p2)
	return p1.x * p2.x + p1.y * p2.y
end

function PremiumPred:GetPathLength(path)
	local dist = 0
	for i = 1, #path - 1 do dist = dist +
		self:Distance(path[i], path[i + 1])
	end
	return dist
end

function PremiumPred:GetPositionAfter(path, speed, time)
	if #path == 0 then return nil end
	if #path == 1 then return path[1] end
	local distance = time * speed
	if distance < 0 then
		return Point2(path[1]):Extended(path[2], distance)
	end
	for i = 1, #path - 1 do
		local a, b = path[i], path[i + 1]
		local dist = self:Distance(a, b)
		if dist == distance then
			return b
		elseif dist > distance then
			return Point2(a):Extended(b, distance)
		end
		distance = distance - dist
	end
	return path[#path]
end

function PremiumPred:GetPositionAfterTime(unit, time)
	if not self:IsMoving(unit) then return unit.pos end
	local path, speed = self:GetWaypoints(unit), self:GetMovementSpeed(unit)
	local pos = self:GetPositionAfter(path, speed, time)
	return pos and self:To3D(pos, unit.pos.y) or nil
end

function PremiumPred:GetPossibleUnits(source, unit, spellData)
	local result = {}
	local sourcePos = IsPoint(source) and self:To2D(source) or self:To2D(source.pos)
	for i, enemy in ipairs(self:GetEnemyHeroes()) do
		if enemy.valid and enemy.visible and not enemy.dead and enemy.networkID ~= unit.networkID then
			if self:Distance(sourcePos, self:To2D(enemy.pos)) <=
				(enemy.boundingRadius or 65) + spellData.range + spellData.radius then
					local pred = self:GetPrediction(source, enemy, spellData)
					if pred.HitChance > 0 then TableInsert(result, self:To2D(pred.PredPos)) end
			end
		end
	end
	return result
end

function PremiumPred:GetWaypoints(unit)
	local result = {}
	TableInsert(result, self:To2D(unit.pos))
	if self:IsMoving(unit) then
		if unit.pathing.isDashing then
			TableInsert(result, self:To2D(unit.pathing.endPos))
		else
			local index, count = GetPathIndex(unit), GetPathCount(unit)
			if index == -1 or count == -1 then return {} end
			for i = index, count do TableInsert(result,
				Point2(unit:GetPath(i).x, unit:GetPath(i).z))
			end
		end
	end
	return result
end

function PremiumPred:GetWaypoints3D(unit)
	local result = {}
	TableInsert(result, unit.pos)
	if self:IsMoving(unit) then
		if unit.pathing.isDashing then
			TableInsert(result, Vector(unit.pathing.endPos))
		else
			local index, count = GetPathIndex(unit), GetPathCount(unit)
			if index == -1 or count == -1 then return {} end
			for i = index, count do TableInsert(
				result, Vector(unit:GetPath(i))) end
		end
	end
	return result
end

function PremiumPred:Interception(startPos, endPos, source, speed, missileSpeed, delay)
	local delta = delta or 0
	local dir = Point2(endPos - startPos); local magn = self:Magnitude(dir)
	local vel = Point2(speed * dir.x / magn, speed * dir.y / magn)
	dir = Point2(startPos - source)
	local a = self:MagnitudeSquared(vel) - missileSpeed * missileSpeed
	local b = 2 * self:DotProduct(vel, dir)
	local c = self:MagnitudeSquared(dir)
	local delta = b * b - 4 * a * c
	if delta >= 0 then
		local rtDelta = MathSqrt(delta)
		local t1, t2, t = (-b + rtDelta) / (2 * a), (-b - rtDelta) / (2 * a), -1
		if t2 >= delay then t = t1 >= delay and MathMin(t1, t2) or MathMax(t1, t2) end
		return t
	end
	return 0
end

function PremiumPred:Intersection(a1, b1, a2, b2)
	local r, s = Point2(b1 - a1), Point2(b2 - a2); local x = self:CrossProduct(r, s)
	local t, u = self:CrossProduct(a2 - a1, s) / x, self:CrossProduct(a2 - a1, r) / x
	return x ~= 0 and t >= 0 and t <= 1 and u >= 0 and u <= 1 and Point2(a1 + t * r) or nil
end

function PremiumPred:IsColliding(source, position, spellData, flags, exclude)
	local position, result = self:To2D(position), {}
	local sourcePos = IsPoint(source) and self:To2D(source) or self:To2D(source.pos)
	for i = 1, #flags do
		local flag = flags[i]
		if flag == "minion" then
			for i = 1, GameMinionCount() do
				local minion = GameMinion(i)
				if minion and minion.valid and minion.visible and
					minion.team ~= myHero.team and not minion.dead and minion.maxHealth > 5 then
					if exclude and minion.networkID ~= exclude.networkID or not exclude then
						local predPos = self:GetFastPrediction(source, minion, spellData)
						if predPos ~= nil then
							local predPos = self:To2D(predPos)
							local point = self:ClosestPointOnSegment(sourcePos, position, predPos)
							if self:DistanceSquared(predPos, point) <= ((minion.boundingRadius or 45) +
								spellData.radius + self.PPMenu.CB:Value()) ^ 2 then TableInsert(result, minion)
							end
						end
					end
				end
			end
		elseif flag == "hero" then
			for i, hero in ipairs(self:GetEnemyHeroes()) do
				if hero.valid and hero.visible and not hero.dead then
					if exclude and hero.networkID ~= exclude.networkID or not exclude then
						local predPos = self:GetFastPrediction(source, hero, spellData)
						if predPos ~= nil then
							local predPos = self:To2D(predPos)
							local point = self:ClosestPointOnSegment(sourcePos, position, predPos)
							if self:DistanceSquared(predPos, point) <= ((hero.boundingRadius or 65) +
								spellData.radius + self.PPMenu.CB:Value()) ^ 2 then TableInsert(result, hero)
							end
						end
					end
				end
			end
		elseif flag == "windwall" and self.WindWall ~= nil then -- WINDWALL DETECTION WON'T BE ADDED DUE TO LOW GOS PERFORMANCE
			local data = self.WindWall
			if #data == 0 then break end
			local s1, s2, s3, s4 = Point2(data.pos1 - data.dir), Point2(data.pos1 + data.dir),
				Point2(data.pos2 - data.dir), Point2(data.pos2 + data.dir)
			local int1, int2 = self:Intersection(sourcePos, position, s1, s2),
				self:Intersection(sourcePos, position, s3, s4)
			if int1 or int2 then return true end
		end
	end
	return #result > 0 and result or false
end

function PremiumPred:IsFacing(source, unit, angle)
	local sPos, uPos, dir = self:To2D(source.pos), self:To2D(unit.pos), self:To2D(source.dir)
	return self:AngleBetween(sPos, Point2(sPos + dir * 65), uPos) < (angle or 90)
end

function PremiumPred:IsPointInArc(sourcePos, unitPos, endPos, range, angle)
	local sourcePos = IsVector(sourcePos) and self:To2D(sourcePos) or sourcePos
	local unitPos = IsVector(unitPos) and self:To2D(unitPos) or unitPos
	local endPos = IsVector(endPos) and self:To2D(endPos) or endPos
	local angle = MathRad(angle) / 2
	local a, b = Point2(sourcePos - unitPos), Point2(sourcePos - endPos)
	local c = self:Magnitude(b); local d = self:DotProduct(a, b) / c
	local inf = d / self:Magnitude(a) <= MathCos(angle)
	if inf then return false end
	return d <= c and self:DistanceSquared(
		sourcePos, unitPos) <= range * range
end

function PremiumPred:Magnitude(p)
	return MathSqrt(self:MagnitudeSquared(p))
end

function PremiumPred:MagnitudeSquared(p)
	return p.x * p.x + p.y * p.y
end

function PremiumPred:To2D(pos)
	return pos.z and Point2(pos.x, pos.z or pos.y) or Point2(pos)
end

function PremiumPred:To3D(pos, y)
	return Vector(pos.x, y or 0, pos.y)
end

--[[
	┌┬┐┌─┐┌┐┌┌─┐┌─┐┌─┐┬─┐
	│││├─┤│││├─┤│ ┬├┤ ├┬┘
	┴ ┴┴ ┴┘└┘┴ ┴└─┘└─┘┴└─
--]]

function PremiumPred:CalcAverage(samples)
	local result = 0
	for i, val in ipairs(samples) do
		result = result + val end
	return result / #samples
end

function PremiumPred:GetEnemyHeroes()
	local enemies = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit and unit.isEnemy then
			TableInsert(enemies, unit)
		end
	end
	return enemies
end

function PremiumPred:GetImmobileDuration(unit)
	if unit.activeSpell and unit.activeSpell.valid and
		(unit.activeSpell.isChanneling or unit.activeSpell.isAutoAttack) then
			local endTime = unit.activeSpell.castEndTime
			if endTime >= GameTimer() then return endTime - GameTimer() end
	end
	for i = 0, GetBuffCount(unit) do
		local buff = unit:GetBuff(i)
		if buff and buff.count > 0 and buff.duration > 0 and
			buff.duration <= 5 and CCBuffs[buff.type]
				then return buff.duration
		end
	end
	return 0
end

function PremiumPred:GetMovementSpeed(unit)
	return unit.valid and (unit.pathing.isDashing and
		unit.pathing.dashSpeed or unit.ms) or 315
end

function PremiumPred:IsDashing(unit)
	local nid = unit.networkID
	if CustomData[nid] == nil then self:InitCustomData(unit) end
	return CustomData[nid].windup > 0 or unit.pathing.isDashing
end

function PremiumPred:IsMoving(unit)
	return unit.pos.x - MathFloor(unit.pos.x) ~= 0
end

function PremiumPred:Round(num, places)
	local mult = 10 ^ (places or 0)
	return MathFloor(num * mult + 0.5) / mult
end

--[[
	┌─┐┌─┐┬  ┬  ┌┐ ┌─┐┌─┐┬┌─┌─┐
	│  ├─┤│  │  ├┴┐├─┤│  ├┴┐└─┐
	└─┘┴ ┴┴─┘┴─┘└─┘┴ ┴└─┘┴ ┴└─┘
--]]

function PremiumPred:Dash(func)
	TableInsert(self.DashCBs, func)
end

function PremiumPred:GainVision(func)
	TableInsert(self.GainCBs, func)
end

function PremiumPred:LoseVision(func)
	TableInsert(self.LoseCBs, func)
end

function PremiumPred:ProcessSpell(func)
	TableInsert(self.PsCBs, func)
end

function PremiumPred:ProcessWaypoint(func)
	TableInsert(self.WpCBs, func)
end

--[[
	┌─┐┬─┐┌─┐┌┬┐┬┌─┐┌┬┐┬┌─┐┌┐┌
	├─┘├┬┘├┤  ││││   │ ││ ││││
	┴  ┴└─└─┘─┴┘┴└─┘ ┴ ┴└─┘┘└┘
--]]

function PremiumPred:Tick()
	for i, unit in ipairs(self:GetEnemyHeroes()) do
		local nid = unit.networkID
		if CustomData[nid] == nil then self:InitCustomData(unit) end
		local data = CustomData[nid]
		if unit.valid and unit.visible and not unit.dead then
			-- Dash callback
			local dashData = myHero.pathing
			if not dashData.isDashing then
				data.dash = {startPos = Point2(0, 0), endPos = Point2(0, 0), speed = 0}
			elseif dashData.startPos ~= data.dash.startPos then
				for i = 1, #self.DashCBs do self.DashCBs[i](unit, dashData) end
				data.dash = {startPos = dashData.startPos, endPos = dashData.endPos,
					speed = dashData.speed, timer = GameTimer()}
			end
			-- Process spell
			local activeData = unit.activeSpell
			if activeData and activeData.valid and data.spell ~=
				activeData.name .. activeData.endTime then
				data.spell = activeData.name .. activeData.endTime
				for i = 1, #self.PsCBs do self.PsCBs[i](unit, activeData) end
				if DashWindups[activeData.name] then
					data.windup = GameTimer() + DashWindups[activeData.name]
				end
			end
			-- Process waypoint
			local isMoving = self:IsMoving(unit)
			local last = isMoving and self:To2D(unit.posTo) or self:To2D(unit.pos)
			if data.oldPos ~= last then
				local pathData = unit.pathing
				if isMoving then
					for i = 1, #self.WpCBs do
						self.WpCBs[i](unit, pathData.startPos, pathData.endPos) end
					self:OnProcessWaypoint(unit, nid, pathData)
				else
					for i = 1, #self.WpCBs do self.WpCBs[i](unit, unit.pos, unit.pos) end
				end
				data.oldPos = last
			end
		end
		-- Reset dash windup
		if data.windup ~= 0 and data.windup < GameTimer() then data.windup = 0 end
		-- Vision callbacks
		if data.visible ~= unit.visible then
			if not unit.visible then
				for i = 1, #self.LoseCBs do self.LoseCBs[i](unit) end
				data.mia = GameTimer()
			else
				for i = 1, #self.GainCBs do self.GainCBs[i](unit) end
				data.mia = 0
			end
			data.visible = unit.visible
		end
		-- Remove old data
		for i = #data.timers, 1, -1 do
			if GameTimer() - data.timers[i] > 1 then
				TableRemove(data.waypoints, i); TableRemove(data.timers, i)
				TableRemove(data.angles, i); TableRemove(data.lengths, i)
			end
		end
	end
end

function PremiumPred:Draw()
	if not self.PPMenu.Debug.Enable:Value() then return end
	for i, unit in ipairs(self:GetEnemyHeroes()) do
		if unit.valid and unit.visible and not unit.dead then
			local spellData = {
				speed = self.PPMenu.Debug.Huge:Value() and MathHuge or self.PPMenu.Debug.Speed:Value(),
				range = self.PPMenu.Debug.Range:Value(),
				delay = self.PPMenu.Debug.Delay:Value(),
				radius = self.PPMenu.Debug.Radius:Value(),
				collision = self.PPMenu.Debug.Collision:Value() and {"minion"} or {},
				type = "linear"
			}
			local output = self:GetPrediction(myHero, unit, spellData)
			if output.CastPos and output.PredPos then
				local boundingRadius = unit.boundingRadius or 65
				DrawCircle(output.PredPos, boundingRadius, 0.25, Draw.Color(192, 255, 255, 255))
				DrawCircle(output.CastPos, boundingRadius, 0.25, Draw.Color(192, 255, 255, 0))
				print("HitChance: " .. self:Round(output.HitChance, 2) .. " TimeToHit: " .. self:Round(output.TimeToHit, 2))
				if self.PPMenu.Debug.Cast:Value() and output.HitChance >= self.PPMenu.Debug.HitChance:Value() then
					if Game.CanUseSpell(_Q) == 0 then Control.CastSpell(HK_Q, output.CastPos) end
				end
			end
		end
	end
end

function PremiumPred:OnProcessWaypoint(unit, id, pathData)
	local data, endPos = CustomData[id], self:To2D(unit.posTo)
	local angle = #data.waypoints > 0 and self:AngleBetween(self:To2D(unit.pos),
		data.waypoints[#data.waypoints], endPos) or 0
	TableInsert(data.angles, angle)
	TableInsert(data.lengths, self:GetPathLength(self:GetWaypoints(unit)))
	TableInsert(data.timers, GameTimer())
	TableInsert(data.waypoints, endPos)
	data.avgAngle = self:CalcAverage(data.angles)
	data.avgLength = self:CalcAverage(data.lengths)
	data.avgMoveClick = MathMin(1, 1 / #data.timers)
end

function PremiumPred:GetPrediction(source, unit, spellData)
	local result = self:IsDashing(unit) and self:GetDashPrediction(source, unit, spellData)
		or self:PredictUnitPosition(source, unit, spellData)
	local hitChance = self:GetHitChance(source, unit,
		result.CastPos, spellData, result.TimeToHit, result.CanHit)
	return {CastPos = result.CastPos, PredPos = result.PredPos, HitChance = hitChance,
		HitCount = hitChance > 0 and 1 or 0, TimeToHit = result.TimeToHit}
end

function PremiumPred:GetAOEPrediction(source, unit, spellData)
	local output = self:GetPrediction(source, unit, spellData)
	if not output.CastPos then return output end
	local bestPos, bestCount, positions = self:To2D(output.CastPos), 1, {}
	local sourcePos = IsPoint(source) and self:To2D(source) or self:To2D(source.pos)
	local candidates = self:GetPossibleUnits(source, unit, spellData)
	if #candidates > 0 then
		TableInsert(candidates, self:To2D(output.PredPos))
		for i, pos in ipairs(candidates) do TableInsert(positions, pos) end
		local spellType = spellData.type
		if spellType ~= "circular" then
			for i = 1, #candidates do
				for j = 1, #candidates do
					if candidates[i] ~= candidates[j] then
						TableInsert(positions, Point2(candidates[i] + candidates[j]) / 2)
					end
				end
			end
			for i, pos in ipairs(positions) do
				local endPos, count = Point2(sourcePos):Extended(pos, spellData.range), 0
				for j, candidate in ipairs(candidates) do
					if spellType == "linear" and self:DistanceSquared(candidate, self:ClosestPointOnSegment(sourcePos, endPos, candidate))
						<= spellData.radius * spellData.radius or (spellType == "conic" and self:IsPointInArc(sourcePos, candidate, endPos,
						spellData.range, spellData.angle or 50)) then count = count + 1
					end
				end
				if count > bestCount then bestPos, bestCount = pos, count end
			end
		else
			local success = false
			while not success and #candidates > 1 do
				local mec = MEC:GetMEC(candidates)
				if self:DistanceSquared(sourcePos, mec.Center) <= spellData.range * spellData.range
				and mec.Radius <= spellData.radius then bestPos, bestCount, success = mec.Center, #candidates, true end
				if not success then
					TableSort(candidates, function(a, b) return
						self:DistanceSquared(mec.Center, a) >
						self:DistanceSquared(mec.Center, b) end)
					TableRemove(candidates, 1)
				end
			end
		end
	end
	output.CastPos = self:To3D(bestPos, unit.pos.y)
	output.TimeToHit = self:CalcTravelTime(sourcePos, output.CastPos, spellData)
	output.HitChance = self:GetHitChance(source, unit, output.CastPos, spellData, output.TimeToHit, true)
	output.HitCount = bestCount
	return output
end

function PremiumPred:GetFastPrediction(source, unit, spellData)
	if not unit.visible or not unit.valid then return nil end
	local sourcePos = IsPoint(source) and self:To2D(source) or self:To2D(source.pos)
	local unitPos, y = self:To2D(unit.pos), unit.pos.y
	if not self:IsMoving(unit) then return unitPos end
	local waypoints, moveSpeed = self:GetWaypoints(unit), self:GetMovementSpeed(unit)
	if #waypoints == 0 then return nil end
	waypoints = self:CutWaypoints(waypoints, (spellData.delay + self.PPMenu.Latency:Value() / 2000 + 0.07) * moveSpeed)
	if spellData.speed == MathHuge or #waypoints == 1 then return self:To3D(waypoints[1], y) end
	if #waypoints >= 2 then
		local t = self:Interception(waypoints[1], waypoints[2], sourcePos, moveSpeed, spellData.speed, 0)
		return t > 0 and self:To3D(self:GetPositionAfter(waypoints, moveSpeed, t), y) or self:To3D(waypoints[2], y)
	end
	return nil
end

function PremiumPred:GetDashPrediction(source, unit, spellData)
	local output = {CastPos = nil, PredPos = nil, TimeToHit = 0, CanHit = false}
	if not self:IsDashing(unit) then return output end
	local sourcePos = IsPoint(source) and self:To2D(source) or self:To2D(source.pos)
	local unitPos, nid = self:To2D(unit.pos), unit.networkID
	if CustomData[nid] == nil then self:InitCustomData(unit) end
	local data = CustomData[nid]
	if data.windup > 0 and unitPos then
		local travelTime = self:CalcTravelTime(sourcePos, unitPos, spellData)
		return travelTime > data.windup and output or
			{CastPos = unitPos, PredPos = unitPos, TimeToHit = travelTime, CanHit = true}
	end
	local waypoints, moveSpeed = self:GetWaypoints(unit), self:GetMovementSpeed(unit)
	if #waypoints == 0 then return output end
	waypoints = self:CutWaypoints(waypoints, (spellData.delay +
		self.PPMenu.Latency:Value() / 2000 + 0.07) * moveSpeed)
	local predPos = waypoints[1]
	if spellData.speed ~= MathHuge and #waypoints > 1 then
		local t = self:Interception(waypoints[1], waypoints[2], sourcePos, moveSpeed, spellData.speed, 0)
		predPos = t > 0 and self:GetPositionAfter(waypoints, moveSpeed, t) or waypoints[2]
	end
	local timeToHit = self:CalcTravelTime(sourcePos, predPos, spellData)
	if predPos == self:To2D(unit.pathing.endPos) then
		if MathMax(0, timeToHit - spellData.radius / moveSpeed + 0.07) >=
			self:Distance(unitPos, data.dash.endPos) / moveSpeed then return output end
	end
	local y = unit.pos.y; output.CanHit = true
	output.TimeToHit, output.CastPos, output.PredPos =
		timeToHit, self:To3D(predPos, y), self:To3D(predPos, y)
	return output
end

function PremiumPred:PredictUnitPosition(source, unit, spellData)
	local output = {CastPos = nil, PredPos = nil, TimeToHit = 0, CanHit = false}
	local sourcePos = IsPoint(source) and self:To2D(source) or self:To2D(source.pos)
	local nid = unit.networkID
	if CustomData[nid] == nil then self:InitCustomData(unit) end
	local data, moveSpeed = CustomData[nid], self:GetMovementSpeed(unit)
	if not unit.pos then return output end
	local unitPos, waypoints = self:To2D(unit.pos), {}
	if not unit.visible then
		if not unit.posTo then return output end
		local endPos = Point2(unitPos):Extended(self:To2D(unit.posTo), 12500)
		unitPos = Point2(unitPos):Extended(endPos, moveSpeed * (GameTimer() - data.mia))
		if MapPosition:intersectsWall(LineSegment(Point(unit.pos.x, unit.pos.z),
			Point(unitPos.x, unitPos.y))) then return output end
		waypoints = {unitPos, endPos}
	end
	if not self:IsMoving(unit) and #waypoints == 0 then
		output.CastPos, output.PredPos = unitPos, unitPos
	else
		if #waypoints == 0 then
			waypoints = self:GetWaypoints(unit)
			if #waypoints == 0 then return output end
		end
		local threshold = MathMax(0, (spellData.radius - 1) / moveSpeed)
		local delay = (spellData.delay + self.PPMenu.Latency:Value() / 2000 + 0.07)
		if spellData.speed == MathHuge then
			output.PredPos = self:GetPositionAfter(waypoints, moveSpeed, delay)
			output.CastPos = self:GetPositionAfter(waypoints, moveSpeed, delay - threshold)
		else
			waypoints = self:CutWaypoints(waypoints, delay * moveSpeed)
			local success = false
			if #waypoints ~= 1 then
				local totalTime = 0
				for i = 1, #waypoints - 1 do
					local a, b = waypoints[i], waypoints[i + 1]
					local timeB = self:Distance(a, b) / moveSpeed
					a = Point2(a):Extended(b, -moveSpeed * totalTime)
					local t = self:Interception(a, b, sourcePos, moveSpeed, spellData.speed, totalTime)
					if t > 0 and t >= totalTime and t <= totalTime + timeB then
						output.PredPos = self:GetPositionAfter(waypoints, moveSpeed, t)
						output.CastPos = self:GetPositionAfter(waypoints, moveSpeed, t - threshold)
						success = true; break
					end
					totalTime = totalTime + timeB
				end
			end
			if not success then
				local lastPos = waypoints[#waypoints]
				local limit = self:GetPathLength(waypoints) - threshold * moveSpeed
				output.PredPos = lastPos
				output.CastPos = limit > 0 and output.PredPos ~= unitPos and
							self:AppendVector(unitPos, lastPos, -limit) or lastPos
			end
		end
	end
	local y = unit.pos.y; output.CanHit = true
	output.TimeToHit = self:CalcTravelTime(sourcePos, output.CastPos, spellData)
	output.CastPos, output.PredPos = self:To3D(output.CastPos, y), self:To3D(output.PredPos, y)
	return output
end

function PremiumPred:GetHitChance(source, unit, castPos, spellData, timeToHit, canHit)
	if not canHit then return -2 end
	local nid = unit.networkID
	if CustomData[nid] == nil then self:InitCustomData(nid) end
	local data = CustomData[nid]
	local sourcePos, castPos = IsPoint(source) and self:To2D(source) or self:To2D(source.pos), self:To2D(castPos)
	local immobileTime, moveSpeed = self:GetImmobileDuration(unit), self:GetMovementSpeed(unit)
	local hcRadius = spellData.type == "conic" and spellData.angle * self.Pi2 or spellData.radius
	local hitChance = hcRadius / moveSpeed / MathMax(0, timeToHit - immobileTime)
	local mod = self:IsMoving(unit) and (1.5 - MathSin(MathRad(data.avgAngle))) *
		(data.avgMoveClick + 0.5) * (data.avgLength / self:Distance(sourcePos, castPos) + 0.5) or 1
	--local mod = self:IsMoving(unit) and -0.25 * (MathSin(MathRad(data.avgAngle)) - 2) * (data.avgMoveClick + 1) *
	--			(data.avgLength / self:Distance(sourcePos, castPos) / 2 + 0.5) or 1
	hitChance = self:IsDashing(unit) and 1 or MathMax(0, MathMin(1, hitChance * mod))
	if not unit.visible then hitChance = hitChance / 2 end
	local boundingRadius, flags = spellData.type == "linear" and spellData.speed ~= MathHuge and unit.boundingRadius or 0, spellData.collision
	if self:DistanceSquared(sourcePos, castPos) > (spellData.range * spellData.range - boundingRadius * boundingRadius) then hitChance = 0
	elseif flags and #flags > 0 and self:IsColliding(source, self:To3D(castPos), spellData, flags, unit) then hitChance = -1 end
	return hitChance
end

PremiumPred:__init()

-- API

_G.PremiumPrediction = {
	Loaded = function() return PremiumPred.Loaded end,
	PredictUnitPosition = function(self, source, unit, spellData) return PremiumPred:PredictUnitPosition(source, unit, spellData) end,
	GetPrediction = function(self, source, unit, spellData) return PremiumPred:GetPrediction(source, unit, spellData) end,
	GetAOEPrediction = function(self, source, unit, spellData) return PremiumPred:GetAOEPrediction(source, unit, spellData) end,
	GetDashPrediction = function(self, source, unit, spellData) return PremiumPred:GetDashPrediction(source, unit, spellData) end,
	GetFastPrediction = function(self, source, unit, spellData) return PremiumPred:GetFastPrediction(source, unit, spellData) end,
	GetHitChance = function(self, source, unit, castPos, spellData, timeToHit, canHit) return PremiumPred:GetHitChance(source, unit, castPos, spellData, timeToHit, canHit) end,
	GetImmobileDuration = function(self, unit) return PremiumPred:GetImmobileDuration(unit) end,
	GetMEC = function(self, points) return MEC:GetMEC(points) end,
	GetMovementSpeed = function(self, unit) return PremiumPred:GetMovementSpeed(unit) end,
	GetPositionAfterTime = function(self, unit, time) return PremiumPred:GetPositionAfterTime(unit, time) end,
	GetWaypoints = function(self, unit) return PremiumPred:GetWaypoints3D(unit) end,
	IsColliding = function(self, source, position, spellData, flags, exclude) return PremiumPred:IsColliding(source, position, spellData, flags, exclude) end,
	IsDashing = function(self, unit) return PremiumPred:IsDashing(unit) end,
	IsFacing = function(self, source, unit, angle) return PremiumPred:IsFacing(source, unit, angle) end,
	IsMoving = function(self, unit) return PremiumPred:IsMoving(unit) end,
	IsPointInArc = function(self, sourcePos, unitPos, endPos, range, angle) return PremiumPred:IsPointInArc(sourcePos, unitPos, endPos, range, angle) end,
	OnDash = function(self, func) PremiumPred:Dash(func) end,
	OnGainVision = function(self, func) PremiumPred:GainVision(func) end,
	OnLoseVision = function(self, func) PremiumPred:LoseVision(func) end,
	OnProcessSpell = function(self, func) PremiumPred:ProcessSpell(func) end,
	OnProcessWaypoint = function(self, func) PremiumPred:ProcessWaypoint(func) end,
	To2D = function(self, position) return PremiumPred:To2D(position) end,
	To3D = function(self, point, height) return PremiumPred:To3D(point, height) end,
	HitChance = {
		Impossible = function(hc) return hc == -2 end,
		Collision = function(hc) return hc == -1 end,
		OutOfRange = function(hc) return hc == 0 end,
		Low = function(hc) return hc > 0 end,
		Medium = function(hc) return hc >= 0.25 end,
		High = function(hc) return hc >= 0.5 end,
		VeryHigh = function(hc) return hc >= 0.75 end,
		Dashing = function(hc) return hc == 1 end,
		Immobile = function(hc) return hc == 1 end
	}
}
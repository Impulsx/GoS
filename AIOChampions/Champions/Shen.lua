local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.team ~= myHero.team then
			TableInsert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local function GetAllyHeroes()
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function EnemyInRange(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range and IsValid(target) then 
			count = count + 1
		end
	end
	return count
end

local function IsUnderTurret(unit)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local Ally1, Ally2, Ally3, Ally4 = nil, nil, nil, nil

function LoadScript()
	HPred()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	

	--FleeMenu  
	Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
	Menu.Flee:MenuElement({id = "UseE", name = "[E] mouse pos", value = true})
	Menu.Flee:MenuElement({name = " ", drop = {"Default Orbwalker key [A]"}})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		 	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Energy to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Energy to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawAlly", name = "Draw Ally Hp Info Text", value = true})	
	Menu.Drawing:MenuElement({id = "x", name = "TextPos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.Drawing:MenuElement({id = "y", name = "TextPos: [Y]", value = 0, min = 0, max = 860, step = 10})	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0, Radius = 60, Range = 600, Speed = 1200, Collision = false
	}
	
	EspellData = {speed = 1200, range = 600, delay = 0, radius = 60, collision = {nil}, type = "linear"}	

	Callback.Add("Tick", function() Tick() end)
	
	
	Callback.Add("Draw", function()

		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 600, 1, DrawColor(225, 225, 125, 10))
		end

		for i, target in ipairs(GetAllyHeroes()) do	
			if Ally1 == nil then
				Ally1 = target
			elseif Ally2 == nil then
				if target.networkID ~= Ally1.networkID then
					Ally2 = target
				end
			elseif Ally3 == nil then
				if target.networkID ~= Ally1.networkID and target.networkID ~= Ally2.networkID then
					Ally3 = target
				end	
			elseif Ally4 == nil then
				if target.networkID ~= Ally1.networkID and target.networkID ~= Ally2.networkID and target.networkID ~= Ally3.networkID then
					Ally4 = target
				end				
			end
			
			if Menu.Drawing.DrawAlly:Value() then	
				if Ally1 then 
					local Health = Ally1.health/Ally1.maxHealth*100
					if Ally1.dead then
						DrawText(Ally1.charName.." DEAD", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value(), DrawColor(255, 23, 23, 23))
					elseif Health > 50 then
						DrawText(Ally1.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value(), DrawColor(255, 0, 255, 0))
					elseif Health <= 50 and Health > 35 then
						DrawText(Ally1.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value(), DrawColor(255, 225, 255, 0))	
					elseif Health <= 35 then
						DrawText(Ally1.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value(), DrawColor(255, 220, 20, 60))						
					end	
				end
				if Ally2 then 
					local Health = Ally2.health/Ally2.maxHealth*100
					if Ally2.dead then
						DrawText(Ally2.charName.." DEAD", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+21, DrawColor(255, 23, 23, 23))
					elseif Health > 50 then
						DrawText(Ally2.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+21, DrawColor(255, 0, 255, 0))
					elseif Health <= 50 and Health > 35 then
						DrawText(Ally2.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+21, DrawColor(255, 225, 255, 0))	
					elseif Health <= 35 then
						DrawText(Ally2.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+21, DrawColor(255, 220, 20, 60))						
					end	
				end	
				if Ally3 then 
					local Health = Ally3.health/Ally3.maxHealth*100
					if Ally3.dead then
						DrawText(Ally3.charName.." DEAD", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+42, DrawColor(255, 23, 23, 23))
					elseif Health > 50 then
						DrawText(Ally3.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+42, DrawColor(255, 0, 255, 0))
					elseif Health <= 50 and Health > 35 then
						DrawText(Ally3.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+42, DrawColor(255, 225, 255, 0))	
					elseif Health <= 35 then
						DrawText(Ally3.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+42, DrawColor(255, 220, 20, 60))						
					end	
				end
				if Ally4 then 
					local Health = Ally4.health/Ally4.maxHealth*100
					if Ally4.dead then
						DrawText(Ally4.charName.." DEAD", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+63, DrawColor(255, 23, 23, 23))
					elseif Health > 50 then
						DrawText(Ally4.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+63, DrawColor(255, 0, 255, 0))
					elseif Health <= 50 and Health > 35 then
						DrawText(Ally4.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+63, DrawColor(255, 225, 255, 0))	
					elseif Health <= 35 then
						DrawText(Ally4.charName.. " " ..math.floor(Health).." % HP", 21, Menu.Drawing.x:Value(), Menu.Drawing.y:Value()+63, DrawColor(255, 220, 20, 60))						
					end	
				end				
			end	
		end
	end)	
end

local Blade = myHero.pos
function Tick()

if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		ComboQ()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "Flee" then	
		if Menu.Flee.UseE:Value() then
			Flee()
		end	
	end
	
	if myHero:GetSpellData(_Q).currentCd >= myHero:GetSpellData(_Q).cd - 0.1 then
		local time = myHero.pos:DistanceTo(Blade) / 3000
		DelayAction(function()
			Blade = myHero.pos
		end,time)	
	end
end

function ComboQ()
	if Ready(_Q) then
		local Enemies = EnemyInRange(1500)
		if Enemies >= 1 then
			local Count = HPred:GetLineTargetCount(Blade, myHero.pos, 0.1, 3000, 70)
			if Count >= 1 then
				Control.CastSpell(HK_Q)
			end
		end
	end	
end

function Combo()
local target = GetTarget(600)
if target == nil then return end
	if IsValid(target) then			
		
		if myHero.pos:DistanceTo(target.pos) < 590 and myHero.pos:DistanceTo(target.pos) > 300 and Menu.Combo.UseE:Value() and Ready(_E) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					Control.CastSpell(HK_E, pred.CastPos)
				end
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0, Radius = 60, Range = 600, Speed = 1200, Collision = false})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end
			end
		end
				
		if myHero.pos:DistanceTo(target.pos) <= 200 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q)		
		end	

		if Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(Blade) <= 350 then
			Control.CastSpell(HK_W)
		end		
	end
end	

function Flee()
	if Ready(_E) then
		Control.CastSpell(HK_E, mousePos)
	end
end

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 190 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q)
			end	 
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)	

		if myHero.pos:DistanceTo(minion.pos) <= 190 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q)
			end  
		end
	end
end

----------------------------------------------------------------------------
------------------------------HPrediction-----------------------------------
----------------------------------------------------------------------------

class "HPred"

local _tickFrequency = .2
local _nextTick = Game.Timer()


local _OnVision = {}
function HPred:OnVision(unit)
	if unit == nil or type(unit) ~= "userdata" then return end
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {visible = unit.visible , tick = GetTickCount(), pos = unit.pos } end
	if _OnVision[unit.networkID].visible == true and not unit.visible then _OnVision[unit.networkID].visible = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].visible == false and unit.visible then _OnVision[unit.networkID].visible = true _OnVision[unit.networkID].tick = GetTickCount() _OnVision[unit.networkID].pos = unit.pos end
	return _OnVision[unit.networkID]
end

--This must be called manually - It's not on by default because we've tracked down most of the freeze issues to this.
function HPred:Tick()
	
	
	--Update missile cache
	--DISABLED UNTIL LATER.
	--self:CacheMissiles()
	
	--Limit how often tick logic runs
	if _nextTick > Game.Timer() then return end
	_nextTick = Game.Timer() + _tickFrequency
	
	--Update hero movement history	
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t then
			if t.isEnemy then
				HPred:OnVision(t)
			end
		end
	end
	
	--Do not run rest of logic until freeze issues are fully tracked down
	if true then return end
	
end

function HPred:GetLineTargetCount(source, aimPos, delay, speed, width)
	local Count = 0
	for i, unit in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(unit.pos) <= 1500 and IsValid(unit) then		 			
			local predictedPos = self:PredictUnitPosition(unit, delay+ self:GetDistance(source, unit.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (unit.boundingRadius + width) * (unit.boundingRadius + width)) then
				Count = Count + 1	
			end			
		end	
	end	
	return Count
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			--This node of the path will be completed before the delay has finished. Move on to the next node if one remains
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

function HPred:CanTarget(target, allowInvisible)
	return target.isEnemy and target.alive and target.health > 0  and (allowInvisible or target.visible) and target.isTargetable
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return math.huge
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) 
end

function HPred:GetDistance(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistance target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return math.huge
	end
	return math.sqrt(self:GetDistanceSqr(p1, p2))
end

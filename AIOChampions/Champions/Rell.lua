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

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function CanStackPassive(range, pos)
    local pos = pos.pos
	for i, Enemy in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, Enemy.pos) < Range and IsValid(Enemy) and not HasBuff(Enemy, "rellp_debuff") then
			return Enemy
		end
	end
	return nil
end

local function BoundAlly()
	for i, Ally in ipairs(GetAllyHeroes()) do
		if Ally and IsValid(Ally) and HasBuff(Ally, "relle_target") then
			return Ally
		end
	end	
	return nil
end
--[[
local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return buff
		end
	end
	return false	
end
]]
local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

local function GetPathNodes(unit)
	local nodes = {}
	TableInsert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			TableInsert(nodes, path)
		end
	end		
	return nodes
end

local function GetTargetMS(target)
	local ms = target.ms
	return ms
end 

local function PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

local function GetLineTargetCount(source, Pos, delay, speed, width)
	local Count = 0
	for i, Enemy in ipairs(GetEnemyHeroes()) do
		if Enemy and myHero.pos:DistanceTo(Enemy.pos) <= 1500 and IsValid(Enemy) then
			
			local predictedPos = PredictUnitPosition(Enemy, delay+ GetDistance(source, Enemy.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (Enemy.boundingRadius + width) * (Enemy.boundingRadius + width)) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function LoadScript()	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Menu.Combo:MenuElement({id = "Passive", name = "Stack Passive all Enemies in AA range", value = true})
	Menu.Combo:MenuElement({id = "UseQ2", name = "Use [Q] too for Stack Passive", value = true})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})			
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE3", name = "[E] switch Ally if in Stun range", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Stun near BoundAlly/Rell", value = true})
	Menu.Combo:MenuElement({id = "UseE2", name = "[E] Stun Count between BoundAlly/Rell", value = true})
	Menu.Combo:MenuElement({id = "ECount", name = "min Stun Count between BoundAlly/Rell", value = 2, min = 1, max = 5})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({id = "UseRE", name = "[R] min Enemies in range", value = 1, min = 1, max = 5})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})		 

	--Extra
	Menu:MenuElement({type = MENU, id = "extra", name = "Extra Settings"})
	Menu.extra:MenuElement({id = "UseE", name = "Auto bound next Ally if not bound ally near", value = true})	
	Menu.extra:MenuElement({id = "range", name = "If bound Ally range bigger than -->", value = 2200, min = 1700, max = 5000})	
	Menu.extra:MenuElement({id = "Targets", name = "Select Main BoundAlly", type = MENU})
	Menu.extra.Targets:MenuElement({name = " ", drop = {"Pls select only one Ally as Main"}})
	DelayAction(function()
		for i, Hero in pairs(GetAllyHeroes()) do
			Menu.extra.Targets:MenuElement({id = Hero.charName, name = Hero.charName, value = false})		
		end
	end,0.2)	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Settings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Bound Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})		

	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.6, Radius = 45, Range = 700, Speed = 1500, Collision = false
	}
	
	QspellData = {speed = 1500, range = 700, delay = 0.6, radius = 45, collision = {nil}, type = "linear"}

	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.625, Radius = 110, Range = 750, Speed = MathHuge, Collision = false
	}
	
	WspellData = {speed = MathHuge, range = 750, delay = 0.625, radius = 110, collision = {nil}, type = "circular"}	
  	                                           											   
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()		
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 400, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 700, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 1700, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 750, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

local StunEnable = false
local lastAttack = 0
function Tick()
	if not HasBuff(myHero, "rellw_mountedbuff") and Ready(_W) then
		local target = GetTarget(1500)
		if target == nil then
			Control.CastSpell(HK_W)
		end	
	end
	
	if StunEnable then
		DelayAction(function()
			StunEnable = false
		end,4)
	end
	
	if MyHeroNotReady() then return end
	SearchMainAlly()
	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()	
	elseif Mode == "Harass" then
		Harass()		
	end	
	
	if Menu.extra.UseE:Value() and Ready(_E) and not StunEnable then
		AutoE()
	end
end
	
function Combo()
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target) then
		
		if Menu.Combo.Passive:Value() and ((CanStackPassive(myHero.range, myHero) and Game.Timer() - lastAttack > 1.7) or (Menu.Combo.UseQ2:Value() and Ready(_Q) and CanStackPassive(700, myHero))) then
			local AAHero = CanStackPassive(myHero.range, myHero)
			if AAHero then
				Control.Attack(AAHero)
				lastAttack = Game.Timer()
				
			else	
			
				if Menu.Combo.UseQ2:Value() and Ready(_Q) then
					local QHero = CanStackPassive(700, myHero)
					if QHero and myHero.pos:DistanceTo(QHero.pos) > myHero.range then
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(QHero, QData, myHero)
							if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						elseif Menu.Pred.Change:Value() == 2 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, QHero, QspellData)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						else
							local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.6, Radius = 45, Range = 700, Speed = 1500, Collision = false})
							QPrediction:GetPrediction(QHero, myHero)
							if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end	
						end
					end	
				end
			end				
			
		else
		
			if Ready(_E) then		
				if Menu.Combo.UseE:Value() then						
					local Ally = BoundAlly()
					if Ally and HasBuff(Ally, "relle_ready") then
						if GetEnemyCount(250, myHero) >= 1 then
							Control.CastSpell(HK_E, target)
							
						else								
						
							if GetEnemyCount(250, Ally) >= 1 then
								Control.CastSpell(HK_E, target)
							end
						end	
					end	
				end	
				
				if Menu.Combo.UseE2:Value() then
					local Ally = BoundAlly()
					if Ally and HasBuff(Ally, "relle_ready") then
						local Count = GetLineTargetCount(myHero.pos, Ally.pos, 0.35, 1700, 50)
						if Count >= Menu.Combo.ECount:Value() then
							Control.CastSpell(HK_E, target.pos)
						end
					end	
				end
				
				if Menu.Combo.UseE3:Value() then
					for i, ally in ipairs(GetAllyHeroes()) do
						if GetDistance(ally.pos, myHero.pos) <= 1700 and IsValid(ally) and GetEnemyCount(300, ally) >= 1 and not HasBuff(ally, "relle_target") then
							StunEnable = true
							Control.CastSpell(HK_E, ally)
						end	
					end	
				end
			end	
			
			if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.6, Radius = 45, Range = 700, Speed = 1500, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end	
				end
			end
		   
			if Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 700 then
				local Mounted = HasBuff(myHero, "rellw_mountedbuff")
				if Mounted then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, WData, myHero)
						if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
							SetAttack(false)
							SetMovement(false)
							Control.CastSpell(HK_W, pred.CastPosition)
							SetAttack(true)
							SetMovement(true)							
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
							SetAttack(false)
							SetMovement(false)							
							Control.CastSpell(HK_W, pred.CastPos)
							SetAttack(true)
							SetMovement(true)
						end
					else
						local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.625, Radius = 110, Range = 750, Speed = MathHuge, Collision = false})
						WPrediction:GetPrediction(target, myHero)
						if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
							SetAttack(false)
							SetMovement(false)							
							Control.CastSpell(HK_W, WPrediction.CastPosition)
							SetAttack(true)
							SetMovement(true)							
						end	
					end					
				end
				
				if not Mounted then
					if not HasBuff(myHero, "rellw_shield") or (HasBuff(myHero, "rellw_shield") and GetEnemyCount(300, myHero) == 0) then
						Control.CastSpell(HK_W)
					end
				end	
			end

			if Menu.Combo.UseR:Value() and Ready(_R) then
				local count = GetEnemyCount(400, myHero)
				if count >= Menu.Combo.UseRE:Value() and not myHero.pathing.isDashing then
					Control.CastSpell(HK_R)
				end	
			end
		end	
	end
end

function Harass()
local target = GetTarget(700)
if target == nil then return end
	if IsValid(target) then				
		
		if Menu.Harass.UseQ:Value() and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.6, Radius = 45, Range = 700, Speed = 1500, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end	
			end
        end 
	end
end

function AutoE()	
	local Ally = BoundAlly()	
	if Ally then
		if myHero.pos:DistanceTo(Ally.pos) > Menu.extra.range:Value() then
			local NextAlly = FindBestAlly()
			if NextAlly then
				Control.CastSpell(HK_E, NextAlly)
			end
		end	
	else
		for i, hero in ipairs(GetAllyHeroes()) do
			
			if hero and GetDistance(hero.pos, myHero.pos) <= 1700 and IsValid(hero) then
				Control.CastSpell(HK_E, hero)
			end
		end	
	end
end	

function SearchMainAlly()
	if Ready(_E) and not StunEnable then
		for i, ally in ipairs(GetAllyHeroes()) do
			if Menu.extra.Targets[ally.charName] and Menu.extra.Targets[ally.charName]:Value() and GetDistance(ally.pos, myHero.pos) <= 1700 and IsValid(ally) and not HasBuff(ally, "relle_target") then
				Control.CastSpell(HK_E, ally)
			end
		end
	end	
end

function FindBestAlly()
	for i, Ally in ipairs(GetAllyHeroes()) do	
		if GetDistance(Ally.pos, myHero.pos) <= 1700 and IsValid(Ally) and (GetEnemyCount(700, Ally) >= 1 or GetEnemyCount(500, myHero) >= 1) then
			return Ally
		end	
	end
	return nil
end

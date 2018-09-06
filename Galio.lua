if myHero.charName ~= "Galio" then return end

function OnLoad()
	PrintChat("PussyGalio by Pussykate")
end	


require "2DGeometry"
require "MapPositionGOS"
require "Collision"



local Q = { range = 825, width = myHero:GetSpellData(_Q).width, speed = myHero:GetSpellData(_Q).speed, delay = 0.25 }
local W = { range = 350 }
local E = { range = 650, width = 160, speed = 1400, delay = 0.45, collision = Collision:SetSpell(650, 1400, 0.45, 160, true)}
local R = { range = 4000 }




--Orbwalker

local function DisableMovement(bool)

	if _G.SDK then
		_G.SDK.Orbwalker:SetMovement(not bool)
	elseif _G.EOWLoaded then
		EOW:SetMovements(not bool)
	elseif _G.GOS then
		GOS.BlockMovement = bool
	end
end

local function DisableAttacks(bool)

	if _G.SDK then
		_G.SDK.Orbwalker:SetAttack(not bool)
	elseif _G.EOWLoaded then
		EOW:SetAttacks(not bool)
	elseif _G.GOS then
		GOS.BlockAttack = bool
	end
end

local function GetOrbMode()

	self.combo, self.harass, self.lastHit, self.laneClear, self.jungleClear, self.canMove, self.canAttack = nil,nil,nil,nil,nil,nil,nil
		
	if _G.EOWLoaded then

		local mode = EOW:Mode()

		self.combo = mode == 1
		self.harass = mode == 2
	    self.lastHit = mode == 3
	    self.laneClear = mode == 4
	    self.jungleClear = mode == 4

		self.canmove = EOW:CanMove()
		self.canattack = EOW:CanAttack()
	elseif _G.SDK then

		self.combo = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
		self.harass = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
	   	self.lastHit = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]
	   	self.laneClear = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]
	   	self.jungleClear = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]

		self.canmove = _G.SDK.Orbwalker:CanMove(myHero)
		self.canattack = _G.SDK.Orbwalker:CanAttack(myHero)
	elseif _G.GOS then

		local mode = GOS:GetMode()

		self.combo = mode == "Combo"
		self.harass = mode == "Harass"
	    self.lastHit = mode == "Lasthit"
	    self.laneClear = mode == "Clear"
	    self.jungleClear = mode == "Clear"

		self.canMove = GOS:CanMove()
		self.canAttack = GOS:CanAttack()	
	end
end



--Menu

local PussyGalio = MenuElement({type = MENU, id = "PussyGalio", name = "PussyGalio"})

	PussyGalio:MenuElement({id = "Combo", name = "Combo Settings", type = MENU})
	PussyGalio:MenuElement({id = "Harass", name = "Harass Settings", type = MENU})

	--- Combo ---
		PussyGalio.Combo:MenuElement({id = "useQ", name = "Use Q", value = true})
		PussyGalio.Combo:MenuElement({id = "useW", name = "Use W", value = true})
		PussyGalio.Combo:MenuElement({id = "useE", name = "Use E", value = true})

	--- Harass ---
		PussyGalio.Harass:MenuElement({id = "useQ", name = "Use Q", value = true})
		PussyGalio.Harass:MenuElement({id = "useW", name = "Use W", value = true})
		PussyGalio.Harass:MenuElement({id = "useE", name = "Use E", value = true})



local function OnTick()

	if #GetEnemyHeroesInRange(myHero.pos, 250) > 0 then
		if HasBuff(myHero, "galiow") then
			Orb:DisableMovement(true)
		else
			Orb:DisableMovement(false)
		end
	else
		Orb:DisableMovement(false)
	end

	local rRvl = myHero:GetSpellData(_R).level
	R.range = ({ 4000, 4750, 5500 })[rRvl]

	self.qTarget = GetTarget(Q.range)
	self.wTarget = GetTarget(W.range)
	self.eTarget = GetTarget(E.range)

	if Orb.combo and not isEvading then
		self:Combo()
	elseif Orb.harass and not isEvading then
		self:Harass()
	end
	HPred:Tick()
	OnVisionF()
end





--Utils
local function IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

local function IsValid(unit, pos, range)
	return self:GetDistance(unit.pos, pos) <= range and unit.health > 0 and unit.isTargetable and unit.visible
end

local function GetDistanceSqr(p1, p2)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    return (dx * dx + dz * dz)
end

local function GetDistance(p1, p2)
    return _sqrt(self:GetDistanceSqr(p1, p2))
end

local function GetDistance2D(p1,p2)
    return _sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local function GetHpPercent(unit)
    return unit.health / unit.maxHealth * 100
end

local function GetManaPercent(unit)
	return unit.mana / unit.maxMana * 100
end

local function GetTarget(range)

	if _G.EOWLoaded then
		if myHero.ap > myHero.totalDamage then
			return EOW:GetTarget(range, EOW.ap_dec, myHero.pos)
		else
			return EOW:GetTarget(range, EOW.ad_dec, myHero.pos)
		end
	elseif _G.SDK and _G.SDK.TargetSelector then
		if myHero.ap > myHero.totalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		end
	elseif _G.GOS then
		if myHero.ap > myHero.totalDamage then
			return GOS:GetTarget(range, "AP")
		else
			return GOS:GetTarget(range, "AD")
		end
	end
end

local function HasBuff(unit, buffName)

	for i = 1, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and buff.count > 0 and buff.name:lower() == buffName:lower() then 
			return true
		end
	end
	return false
end

local function GetAllyHeroes()
	local _AllyHeroes = {}
	if #_AllyHeroes > 0 then return _AllyHeroes end
  	for i = 1, LocalGameHeroCount() do
    	local unit = LocalGameHero(i)
    	if unit and unit.isAlly then
	  		_insert(_AllyHeroes, unit)
  		end
  	end
  	return _AllyHeroes
end

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	if #_EnemyHeroes > 0 then return _EnemyHeroes end
  	for i = 1, LocalGameHeroCount() do
    	local unit = LocalGameHero(i)
    	if unit and unit.isEnemy then
	  		_insert(_EnemyHeroes, unit)
  		end
  	end
  	return _EnemyHeroes
end

local function GetEnemyHeroesInRange(pos, range)
	local _EnemyHeroes = {}
  	for i = 1, LocalGameHeroCount() do
    	local unit = LocalGameHero(i)
    	if unit and unit.isEnemy and self:IsValid(unit, pos, range) then
	  		_insert(_EnemyHeroes, unit)
  		end
  	end
  	return _EnemyHeroes
end

local function GetAllyHeroesInRange(pos, range)
	local _AllyHeroes = {}	
  	for i = 1, LocalGameHeroCount() do
    	local unit = LocalGameHero(i)
    	if unit and unit.isAlly and self:IsValid(unit, pos, range) then
	  		_insert(_AllyHeroes, unit)
  		end
  	end
  	return _AllyHeroes
end

local function GetEnemyMinionsInRange(pos, range)

	local _EnemyMinions = {}
  	for i = 1, LocalGameMinionCount() do
    	local unit = LocalGameMinion(i)
    	if unit and unit.isEnemy and self:IsValid(unit, pos, range) then
	  		_insert(_EnemyMinions, unit)
  		end
  	end
  	return _EnemyMinions
end

local function GetAllyMinionsInRange(pos, range)

	local _AllyMinions = {}	
  	for i = 1, LocalGameMinionCount() do
    	local unit = LocalGameMinion(i)
    	if unit and unit.isAlly and self:IsValid(unit, pos, range) then
	  		_insert(_AllyMinions, unit)
  		end
  	end
  	return _AllyMinions
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastSpell(spell,pos,range,delay)

	local range = range or _huge
	local delay = delay or 250
	local ticker = GetTickCount()

	if castSpell.state == 0 and self:GetDistance(myHero.pos, pos) < range and ticker - castSpell.casting > delay + LocalGameLatency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < LocalGameLatency() then
			Control.SetCursorPos(pos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(local function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,LocalGameLatency()/1000)
		end
		if ticker - castSpell.casting > LocalGameLatency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

local function CastSpellMM(spell, pos, range, delay)

	local range = range or _huge
	local delay = delay or 250
	local ticker = GetTickCount()

	if castSpell.state == 0 and self:GetDistance(myHero.pos, pos) < range and ticker - castSpell.casting > delay + LocalGameLatency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < LocalGameLatency() then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x,castPosMM.y)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(local function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,LocalGameLatency()/1000)
		end
		if ticker - castSpell.casting > LocalGameLatency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

local function CastSpellCharged(spell, pos, range, delay)

	local range = range or _huge
	local delay = delay or 250
	local ticker = GetTickCount()

	if castSpell.state == 0 and self:GetDistance(myHero.pos, pos) < range and ticker - castSpell.casting > delay + LocalGameLatency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < LocalGameLatency() then
			Control.SetCursorPos(pos)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(local function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,LocalGameLatency()/1000)
		end
		if ticker - castSpell.casting > LocalGameLatency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

local function OnVision(unit)

	local _OnVision = {}
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
	return _OnVision[unit.networkID]
end

local function OnVisionF()

	local visionTick = GetTickCount()
	if GetTickCount() - visionTick > 100 then
		for k, v in pairs(self:GetEnemyHeroes()) do
			if v then
				self:OnVision(v)
			end
		end
	end
end

local function OnWaypoint(unit)

	local _OnWaypoint = {}
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = LocalGameTimer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = LocalGameTimer()}
			DelayAction(function()
				local time = (LocalGameTimer() - _OnWaypoint[unit.networkID].time)
				local speed = self:GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(LocalGameTimer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and self:GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = self:GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(LocalGameTimer() - _OnWaypoint[unit.networkID].time)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end 

local function GetPred(unit,speed,delay,sourcePos)

	local speed = speed or _huge
	local delay = delay or 0.25
	local sourcePos = sourcePos or myHero.pos
	local unitSpeed = unit.ms

	if self:OnWaypoint(unit).speed > unitSpeed then unitSpeed = self:OnWaypoint(unit).speed end

	if unitSpeed > unit.ms then
		local predPos = unit.pos + Vector(self:OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (self:GetDistance(sourcePos,unit.pos)/speed)))
		if self:GetDistance(unit.pos,predPos) > self:GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
		return predPos
	elseif self:IsImmobile(unit) then
		return unit.pos
	else
		return unit:GetPrediction(speed,delay)
	end
end





--Combo,Harass etc.
local function CastQcombo(unit)

	if IsValid(unit, myHero.pos, Q.range) then
		local t, aimPos = HPred:GetReliableTarget(myHero.pos, Q.range, Q.delay, Q.speed, Q.width)
		local hitChance, aimPos2 = HPred:GetHitchance(myHero.pos, unit, Q.range, Q.delay, Q.speed, Q.width, false, unit.charName)
			if t and aimPos then
				if GetDistance(myHero.pos, aimPos) < Q.range then
					if aimPos:To2D().onScreen then
						CastSpell(HK_Q, aimPos, Q.range)
					end
				end
			end
			if hitChance and aimPos2 and hitChance >= minAccuracy then
				if GetDistance(myHero.pos, aimPos2) < Q.range then
					if aimPos2:To2D().onScreen then
						CastSpell(HK_Q, aimPos2, Q.range)
					end
				end
			end
		end
	end


local function CastWcombo(unit)

	if IsValid(unit, myHero.pos, W.range) then 
		local pred = GetPred(unit, _huge, 0.4)
		if pred then
			if pred:To2D().onScreen then
				if GetDistance(pred, myHero.pos) < W.range then
					Control.KeyDown(HK_W)
				else
					if GetDistance(pred, myHero.pos) > W.range or GetDistance(unit.pos, myHero.pos) > W.range then
						Control.KeyUp(HK_W)
					end
				end
			end
		end
	else
		if Control.IsKeyDown(HK_W) then
			Control.KeyUp(HK_W)
		end
	end
end

local function CastEcombo(unit)

	if IsValid(unit, myHero.pos, E.range) then
		local t, aimPos = HPred:GetReliableTarget(myHero.pos, E.range, E.delay, E.speed, E.width)
		local hitChance, aimPos2 = HPred:GetHitchance(myHero.pos, unit, E.range, E.delay, E.speed, E.width, false, unit.charName)
			if t and aimPos then
				if GetDistance(aimPos, myHero.pos) < E.range and aimPos:To2D().onScreen then
					CastSpell(HK_E, myHero.pos:Extended(aimPos, E.range), E.range)
				end
			end
			if hitChance and aimPos2 and hitChance >= minAccuracy then 
				if GetDistance(aimPos2, myHero.pos) < E.range and aimPos2:To2D().onScreen then
					CastSpell(HK_E, myHero.pos:Extended(aimPos2, E.range), E.range)
				end
			end
		end
	end


local function Combo()

	local qReady = Menu.Combo.useQ:Value() and IsReady(_Q)
	local wReady = Menu.Combo.useW:Value() and IsReady(_W)
	local eReady = Menu.Combo.useE:Value() and IsReady(_E)

	if qReady and self.qTarget then
		self:CastQcombo(self.qTarget)
	end

	if wReady and self.wTarget then
		self:CastWcombo(self.wTarget)
	end

	if eReady and self.eTarget then
		self:CastEcombo(self.eTarget)
	end
end

local function Harass()

	local qReady = Menu.Harass.useQ:Value() and IsReady(_Q)
	local wReady = Menu.Harass.useW:Value() and IsReady(_W)
	local eReady = Menu.Harass.useE:Value() and IsReady(_E)

	if qReady and self.qTarget then
		self:CastQcombo(self.qTarget)
	end

	if wReady and self.wTarget then
		self:CastWcombo(self.wTarget)
	end

	if eReady and self.eTarget then
		self:CastEcombo(self.eTarget)
	end
end





--HPPred

local _reviveQueryFrequency = .2
local _lastReviveQuery = LocalGameTimer()
local _reviveLookupTable = 
	{ 
		["LifeAura.troy"] = 4, 
		["ZileanBase_R_Buf.troy"] = 3,
		["Aatrox_Base_Passive_Death_Activate"] = 3

	}

	
local _blinkSpellLookupTable = 
	{ 
		["EzrealArcaneShift"] = 475, 
		["RiftWalk"] = 500,
	
		["EkkoEAttack"] = 0,
		["AlphaStrike"] = 0,
		
		}

local _blinkLookupTable = 
	{ 
		"global_ss_flash_02.troy",
		"Lissandra_Base_E_Arrival.troy",
		"Leblanc_Base_W_return_activation.troy"
		
	}

local _cachedRevives = {}
local _cachedTeleports = {}
local _movementHistory = {}
local _cachedMissiles = {}
local _incomingDamage = {}
local _windwall
local _windwallStartPos
local _windwallWidth

function HPred:Tick()

	if LocalGameTimer() - _lastReviveQuery < _reviveQueryFrequency then return end
	_lastReviveQuery=LocalGameTimer()
	

	for _, revive in pairs(_cachedRevives) do
		if LocalGameTimer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	

	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then
			_cachedRevives[particle.networkID] = {}
			_cachedRevives[particle.networkID]["expireTime"] = LocalGameTimer() + _reviveLookupTable[particle.name]			
			local target = self:GetHeroByPosition(particle.pos)
			if target and target.isEnemy then				
				_cachedRevives[particle.networkID]["target"] = target
				_cachedRevives[particle.networkID]["pos"] = target.pos
				_cachedRevives[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
	end
	
	
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			self:UpdateMovementHistory(t)
		end
	end
	
		
	for _, teleport in pairs(_cachedTeleports) do
		if teleport and LocalGameTimer() > teleport.expireTime + .5 then
			_cachedTeleports[_] = nil
		end
	end	
	
	self:CacheTeleports()
end

function HPred:GetEnemyNexusPosition()
	
	if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end
end


function HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	
	target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	
	target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	
	target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
end


function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	
	

	target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	
	target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	

	target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
		if target and aimPosition then
		return target, aimPosition
	end
	

	target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	
	target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	
	target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash)
	if target and aimPosition then
		return target, aimPosition
	end
	
	
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	

end


function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
	local targetCount = 0
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTargetALL(t) and (targetAllies or t.isEnemy) then
			local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) * (t.boundingRadius + width)) then
				targetCount = targetCount + 1
			end
		end
	end
	return targetCount
end


function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist)
	local _validTargets = {}
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTarget(t) and (not whitelist or whitelist[t.charName]) then			
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision)		
			if hitChance >= minimumHitChance then
				_validTargets[t.charName] = {["hitChance"] = hitChance, ["aimPosition"] = aimPosition}
			end
		end
	end
	
	local rHitChance = 0
	local rAimPosition
	for targetName, targetData in pairs(_validTargets) do
		if targetData.hitChance > rHitChance then
			rHitChance = targetData.hitChance
			rAimPosition = targetData.aimPosition
		end		
	end
	
	if rHitChance >= minimumHitChance then
		return rHitChance, rAimPosition
	end	
end

function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision)	
	local hitChance = 1	
	
	local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed)	
	local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed)
	local reactionTime = self:PredictReactionTime(target, .1)
	
	
	if _movementHistory and _movementHistory[target.charName] and LocalGameTimer() - _movementHistory[target.charName]["ChangedAt"] < .25 then
		hitChance = 2
	end

	
	if not target.pathing or not target.pathing.hasMovePath then
		hitChance = 2
	end	
	
	
	local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
	if movementRadius - target.boundingRadius <= radius /2 then
		origin,movementRadius = self:UnitMovementBounds(target, interceptTime, 0)
		if movementRadius - target.boundingRadius <= radius /2 then
			hitChance = 4
		else		
			hitChance = 3
		end
	end	
	

	if target.activeSpell and target.activeSpell.valid then
		if target.activeSpell.startTime + target.activeSpell.windup - LocalGameTimer() >= delay then
			hitChance = 5
		else			
			hitChance = 3
		end
	end
	
	
	if not self:IsInRange(myHero.pos, aimPosition, range) then
		hitChance = -1
	end
	
	
	if hitChance > 0 and checkCollision then
		if self:IsWindwallBlocking(source, aimPosition) then
			hitChance = -1		
		elseif self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then
			hitChance = -1
		end
	end
	
	return hitChance, aimPosition
end

function HPred:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	if not unit or not reactionTime then return end
	
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - LocalGameTimer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end
	
	return reactionTime
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)

	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if self:IsInRange(source, dashEndPosition, range) then				
				local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed)
				local deltaInterceptTime =skillInterceptTime - dashTimeRemaining
				if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then
					target = t
					aimPosition = dashEndPosition
					return target, aimPosition
				end
			end			
		end
	end
end

function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy then		
			local success, timeRemaining = self:HasBuff(t, "zhonyasringshield")
			if success then
				local spellInterceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed)
				local deltaInterceptTime = spellInterceptTime - timeRemaining
				if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = t
					aimPosition = t.pos
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for _, revive in pairs(_cachedRevives) do
		if revive and revive.isEnemy then
			local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
			if interceptTime > revive.expireTime - LocalGameTimer() and interceptTime - revive.expireTime - LocalGameTimer() < timingAccuracy then
				target = revive.target
				aimPosition = revive.pos
				return target, aimPosition
			end
		end
	end	
end

function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then
			local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - LocalGameTimer()
			if windupRemaining > 0 then
				local endPos
				local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
				if type(blinkRange) == "table" then

				elseif blinkRange > 0 then
					endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)					
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * _min(self:GetDistance(t.activeSpell.startPos,endPos), range)
				else
					local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
					if blinkTarget then				
						local offsetDirection						
						
						
						if blinkRange == 0 then				

							if t.activeSpell.name ==  "AlphaStrike" then
								windupRemaining = windupRemaining + .75
								
							end						
							offsetDirection = (blinkTarget.pos - t.pos):Normalized()
						
						elseif blinkRange == -1 then						
							offsetDirection = (t.pos-blinkTarget.pos):Normalized()
						
						elseif blinkRange == -255 then
							if radius > 250 then
								endPos = blinkTarget.pos
							end							
						end
						
						if offsetDirection then
							endPos = blinkTarget.pos - offsetDirection * blinkTarget.boundingRadius
						end
						
					end
				end	
				
				local interceptTime = self:GetSpellInterceptTime(myHero.pos, endPos, delay,speed)
				local deltaInterceptTime = interceptTime - windupRemaining
				if self:IsInRange(source, endPos, range) and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
					target = t
					aimPosition = endPos
					return target,aimPosition					
				end
			end
		end
	end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and _blinkLookupTable[particle.name] and self:IsInRange(source, particle.pos, range) then
			local pPos = particle.pos
			for k,v in pairs(self:GetEnemyHeroes()) do
				local t = v
				if t and t.isEnemy and self:IsInRange(t.pos, pPos, t.boundingRadius) then
					if (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
						target = t
						aimPosition = pPos
						return target,aimPosition
					end
				end
			end
		end
	end
end

function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			local interceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed)
			if self:CanTarget(t) and self:IsInRange(source, t.pos, range) and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos	
				return target, aimPosition
			end
		end
	end
end

function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTarget(t) and self:IsInRange(source, t.pos, range) then
			local immobileTime = self:GetImmobileTime(t)
			
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos
				return target, aimPosition
			end
		end
	end
end

function HPred:CacheTeleports()

	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion and minion.isEnemy and not _cachedTeleports[minion.networkID] then
			local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
			if hasBuff then
				self:RecordTeleport(minion, self:GetTeleportOffset(minion.pos,143.25),expiresAt)
			end
		end
	end
end

function HPred:RecordTeleport(target, aimPos, endTime)
	_cachedTeleports[target.networkID] = {}
	_cachedTeleports[target.networkID]["target"] = target
	_cachedTeleports[target.networkID]["aimPos"] = aimPos
	_cachedTeleports[target.networkID]["expireTime"] = endTime + LocalGameTimer()
end


function HPred:CalculateIncomingDamage()
	_incomingDamage = {}
	local currentTime = LocalGameTimer()
	for _, missile in pairs(_cachedMissiles) do
		if missile then 
			local dist = self:GetDistance(missile.data.pos, missile.target.pos)			
			if missile.name == "" or currentTime >= missile.timeout or dist < missile.target.boundingRadius then
				_cachedMissiles[_] = nil
			else
				if not _incomingDamage[missile.target.networkID] then
					_incomingDamage[missile.target.networkID] = missile.damage
				else
					_incomingDamage[missile.target.networkID] = _incomingDamage[missile.target.networkID] + missile.damage
				end
			end
		end
	end	
end

function HPred:GetIncomingDamage(target)
	local damage = 0
	if target and _incomingDamage[target.networkID] then
		damage = _incomingDamage[target.networkID]
	end
	return damage
end


local _maxCacheRange = 3000


function HPred:CacheParticles()	
	if _windwall and _windwall.name == "" then
		_windwall = nil
	end
	
	for i = 1, LocalGameParticleCount() do
		local particle = LocalGameParticle(i)		
		if particle and self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then			
			if _find(particle.name, "W_windwall%d") and not _windwall then
				local owner =  self:GetObjectByHandle(particle.handle)
				if owner and owner.isEnemy then
					_windwall = particle
					_windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)				
					
					local index = _len(particle.name) - 5
					local spellLevel = _sub(particle.name, index, index) -1 
					_windwallWidth = 150 + spellLevel * 25					
				end
			end
		end
	end
end

function HPred:CacheMissiles()
	local currentTime = LocalGameTimer()
	for i = 1, LocalGameMissileCount() do
		local missile = LocalGameMissile(i)
		if missile and not _cachedMissiles[missile.networkID] and missile.missileData then
			
			if missile.missileData.target and missile.missileData.owner then
				local missileName = missile.missileData.name
				local owner =  self:GetObjectByHandle(missile.missileData.owner)	
				local target =  self:GetObjectByHandle(missile.missileData.target)		
				if owner and target and _find(target.type, "Hero") then			
					
					if (_find(missileName, "BasicAttack") or _find(missileName, "CritAttack")) then
						
						_cachedMissiles[missile.networkID] = {}
						_cachedMissiles[missile.networkID].target = target
						_cachedMissiles[missile.networkID].data = missile
						_cachedMissiles[missile.networkID].danger = 1
						_cachedMissiles[missile.networkID].timeout = currentTime + 1.5
						
						local damage = owner.totalDamage
						if _find(missileName, "CritAttack") then
							
							damage = damage * 1.5
						end						
						_cachedMissiles[missile.networkID].damage = self:CalculatePhysicalDamage(target, damage)
					end
				end
			end
		end
	end
end

function HPred:CalculatePhysicalDamage(target, damage)
	
	local localDmg = 0
	if target and damage then		
		local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
		local damageReduction = 100 / ( 100 + targetArmor)
		if targetArmor < 0 then
			damageReduction = 2 - (100 / (100 - targetArmor))
		end		
		localDmg = damage * damageReduction
	end
	return localDmg
end

function HPred:CalculateMagicalDamage(target, damage)
	
	local localDmg = 0
	if target and damage then	
		local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
		local damageReduction = 100 / ( 100 + targetMR)
		if targetMR < 0 then
			damageReduction = 2 - (100 / (100 - targetMR))
		end		
		localDmg = damage * damageReduction
	end
	
	return localDmg
end


function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)

	local target
	local aimPosition
	for _, teleport in pairs(_cachedTeleports) do
		if teleport and teleport.expireTime > LocalGameTimer() and self:IsInRange(source,teleport.aimPos, range) then			
			local spellInterceptTime = self:GetSpellInterceptTime(source, teleport.aimPos, delay, speed)
			local teleportRemaining = teleport.expireTime - LocalGameTimer()
			if spellInterceptTime > teleportRemaining and spellInterceptTime - teleportRemaining <= timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, teleport.aimPos, delay, speed, radius)) then								
				target = teleport.target
				aimPosition = teleport.aimPos
				return target, aimPosition
			end
		end
	end		
end

function HPred:GetTargetMS(target)
	if target then
		local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
		return ms
	end
	return _huge
end

function HPred:Angle(A, B)

	if A and B then
		local deltaPos = A - B
		local angle = _atan(deltaPos.x, deltaPos.z) *  180 / _pi	
		if angle < 0 then angle = angle + 360 end
		return angle
	end
end

function HPred:UpdateMovementHistory(unit)

	if not unit then return end

	if not _movementHistory[unit.charName] then
		_movementHistory[unit.charName] = {}
		_movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["StartPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["PreviousAngle"] = 0
		_movementHistory[unit.charName]["ChangedAt"] = LocalGameTimer()
	end
		
	if _movementHistory[unit.charName]["EndPos"].x ~=unit.pathing.endPos.x or _movementHistory[unit.charName]["EndPos"].y ~=unit.pathing.endPos.y or _movementHistory[unit.charName]["EndPos"].z ~=unit.pathing.endPos.z then				
		_movementHistory[unit.charName]["PreviousAngle"] = self:Angle(Vector(_movementHistory[unit.charName]["StartPos"].x, _movementHistory[unit.charName]["StartPos"].y, _movementHistory[unit.charName]["StartPos"].z), Vector(_movementHistory[unit.charName]["EndPos"].x, _movementHistory[unit.charName]["EndPos"].y, _movementHistory[unit.charName]["EndPos"].z))
		_movementHistory[unit.charName]["EndPos"] = unit.pathing.endPos
		_movementHistory[unit.charName]["StartPos"] = unit.pos
		_movementHistory[unit.charName]["ChangedAt"] = LocalGameTimer()
	end
end


function HPred:PredictUnitPosition(unit, delay)

	if not unit or not delay then return end
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
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

function HPred:IsChannelling(target, interceptTime)
	if not target then return false end
	if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then
		return true
	end
end

function HPred:HasBuff(target, buffName, minimumDuration)
	local duration = minimumDuration
	if not minimumDuration then
		duration = 0
	end
	if not target then return false end
	local durationRemaining
	for i = 1, target.buffCount do
		local buff = target:GetBuff(i)
		if buff and buff.duration > duration and buff.name == buffName then
			durationRemaining = buff.duration
			return true, durationRemaining
		end
	end
end


function HPred:GetTeleportOffset(origin, magnitude)
	local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude
	return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = LocalGameLatency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end


function HPred:CanTarget(target)
	return target and target.isEnemy and target.alive and target.visible and target.isTargetable
end


function HPred:CanTargetALL(target)
	return target and target.alive and target.visible and target.isTargetable
end


function HPred:UnitMovementBounds(unit, delay, reactionTime)

	if not unit then return end
	local startPosition = self:PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = self:GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end


function HPred:GetImmobileTime(unit)

	if not unit then return 0 end
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff and buff.count > 0 and buff.duration > duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			duration = buff.duration
		end
	end
	return duration		
end


function HPred:GetSlowedTime(unit)

	if not unit then return 0 end
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff and buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end


function HPred:GetPathNodes(unit)
	local nodes = {}
	_insert(nodes, unit.pos)
	if unit and unit.pathing and unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			_insert(nodes, path)
		end
	end		
	return nodes
end


function HPred:GetObjectByHandle(handle)

	if not handle then return nil end

	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and minion.handle == handle then
			target = minion
			return target
		end
	end
	
--[[	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.handle == handle then
			target = ward
			return target
		end
	end]]
	
--[[	for i = 1, LocalGameTurretCount() do 
		local turret = LocalGameTurret(i)
		if turret and turret.handle == handle then
			target = turret
			return target
		end
	end]]
	
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if particle and particle.handle == handle then
			target = particle
			return target
		end
	end
end

function HPred:GetHeroByPosition(position)

	if not position then return nil end
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetObjectByPosition(position)

	if not position then return nil end
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local enemy = LocalGameMinion(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
--[[	
	for i = 1, LocalGameWardCount() do
		local enemy = LocalGameWard()
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end]]
	
	for i = 1, LocalGameParticleCount() do 
		local enemy = LocalGameParticle()
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	

	if not handle then return nil end
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
end


function HPred:GetNearestParticleByNames(origin, names)
	local target
	local distance = 999999
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle then 
			local d = self:GetDistance(origin, particle.pos)
			if d < distance then
				distance = d
				target = particle
			end
		end
	end
	return target, distance
end


function HPred:GetPathLength(nodes)
	if not nodes then return 0 end
	local result = 0
	for i = 1, #nodes -1 do
		result = result + self:GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end



function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
	
	if origin and endpos and radius then
		if not frequency then
			frequency = radius
		end
		local directionVector = (endPos - origin):Normalized()
		local checkCount = self:GetDistance(origin, endPos) / frequency
		for i = 1, checkCount do
			local checkPosition = origin + directionVector * i * frequency
			local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed
			if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
				return true
			end
		end
	end
	return false
end


function HPred:IsMinionIntersection(location, radius, delay, maxDistance)

	if location and radius and delay then
		if not maxDistance then
			maxDistance = 500
		end
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and self:CanTarget(minion) and self:IsInRange(minion.pos, location, maxDistance) then
				local predictedPosition = self:PredictUnitPosition(minion, delay)
				if self:IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
					return true
				end
			end
		end
	end
	return false
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	if v1 and v2 and v then
		assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
		local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
		local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
		local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
		local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
		local isOnSegment = rS == rL
		local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	end
	return pointSegment, pointLine, isOnSegment
end


function HPred:IsWindwallBlocking(source, target)
	if _windwall and source and target then
		local windwallFacing = (_windwallStartPos-_windwall.pos):Normalized()
		return self:DoLineSegmentsIntersect(source, target, _windwall.pos + windwallFacing:Perpendicular() * _windwallWidth, _windwall.pos + windwallFacing:Perpendicular2() * _windwallWidth)
	end	
	return false
end

function HPred:DoLineSegmentsIntersect(A, B, C, D)

	local o1 = self:GetOrientation(A, B, C)
	local o2 = self:GetOrientation(A, B, D)
	local o3 = self:GetOrientation(C, D, A)
	local o4 = self:GetOrientation(C, D, B)
	
	if o1 ~= o2 and o3 ~= o4 then
		return true
	end
	
	if o1 == 0 and self:IsOnSegment(A, C, B) then return true end
	if o2 == 0 and self:IsOnSegment(A, D, B) then return true end
	if o3 == 0 and self:IsOnSegment(C, A, D) then return true end
	if o4 == 0 and self:IsOnSegment(C, B, D) then return true end
	
	return false
end


function HPred:GetOrientation(A,B,C)
	if A and B and C then
		local val = (B.z - A.z) * (C.x - B.x) -
			(B.x - A.x) * (C.z - B.z)
		if val == 0 then
			return 0
		elseif val > 0 then
			return 1
		else
			return 2
		end
	end
	return 0
end

function HPred:IsOnSegment(A, B, C)
	return B.x <= _max(A.x, C.x) and 
		B.x >= _min(A.x, C.x) and
		B.z <= _max(A.z, C.z) and
		B.z >= _min(A.z, C.z)
end


function HPred:GetSlope(A, B)
	return (B.z - A.z) / (B.x - A.x)
end

function HPred:GetEnemyByName(name)
	local target
	if name then
		for i = 1, LocalGameHeroCount() do
			local enemy = LocalGameHero(i)
			if enemy and enemy.isEnemy and enemy.charName == name then
				target = enemy
				return target
			end
		end
	end
	return nil
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	if origin and target and source and angle and range then
		local deltaAngle = _abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
		if deltaAngle < angle and self:IsInRange(origin,target,range) then
			return true
		end
	end
	return false
end

function HPred:GetEnemyHeroes()
	return Utils:GetEnemyHeroes()
end 

function HPred:GetDistanceSqr(p1, p2)	
	return Utils:GetDistanceSqr(p1, p2)
end 

function HPred:IsInRange(p1, p2, range)
	return self:GetDistance(p1, p2) <= range
end

function HPred:GetDistance(p1, p2)
	return _sqrt(self:GetDistanceSqr(p1, p2))
end






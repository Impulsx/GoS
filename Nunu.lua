if myHero.charName ~= "Nunu" then return end

--Version 190118--

require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"
require "Collision"


local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
end

local function PercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

local function PercentHP(target)
    return 100 * target.health / target.maxHealth
end

local function PercentMP(target)
    return 100 * target.mana / target.maxMana
end

local function IsImmune(unit)
    for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
        if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and PercentHP(unit) <= 10 then
            return true
        end
        if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then 
            return true
        end
    end
    return false
end

local sqrt = math.sqrt

local function GetDistanceSqr(p1, p2)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    return (dx * dx + dz * dz)
end

local function GetDistance(p1, p2)
    return p1:DistanceTo(p2)
end

local function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function IsValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range and IsImmune(target) == false
end

local Q = {range = 200, speed = 2200, delay = 0.79, icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/IreliaGatotsu.png"}
local W = {speed = 700, delay = 0.30, icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/IreliaHitenStyle.png"}
local E = {range = 550, speed = 20, delay = 0.75, icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/IreliaEquilibriumStrike.png"}
local R = {range = 600, speed = 779, delay = 0.75, icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/IreliaTranscendentBlades.png"}


local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}

local function Edmg(minion)
	if Ready(_E) then	
		return CalcMagicalDamage(myHero,minion,({80, 120, 160, 200, 240})[myHero:GetSpellData(_E).level] + 0.9 * myHero.totalDamage)
    end
    return 0
end

local function Qdmg(minion)
	if Ready(_Q) then	
		return CalcMagicalDamage(myHero,minion,({340, 500, 660, 820, 980})[myHero:GetSpellData(_Q).level])
    end
    return 0
end

local function Rdmg(minion)
	if Ready(_R) then	
		return CalcMagicalDamage(myHero,minion,({625, 875, 1125})[myHero:GetSpellData(_R).level + 2.5 * myHero.totalDamage])
    end
    return 0
end



local function IGdmg(target)
    return 50 + 20 * myHero.levelData.lvl - (target.hpRegen*3)
end

local function HeroesAround(pos, range, team)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local minion = Game.Hero(i)
		if minion and minion.team == team and not minion.dead and pos:DistanceTo(minion.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

local function MinionsAround(pos, range, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.team == team and not minion.dead and pos:DistanceTo(minion.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

local function GetTarget(range)
	local target = nil 
	if _G.EOWLoaded then
		target = EOW:GetTarget(range)
	elseif _G.SDK and _G.SDK.Orbwalker then 
		target = _G.SDK.TargetSelector:GetTarget(range)
	else
		target = _G.GOS:GetTarget(range)
	end
	return target
end

local function NoPotion()
	for i = 0, myHero.buffCount do 
	local buff = myHero:GetBuff(i)
		if buff.type == 13 and Game.Timer() < buff.expireTime then 
			return false
		end
	end
	return true
end



local function GetMode()
	if _G.EOWLoaded then
        if EOW.CurrentMode == 1 then
            return "Combo"
        elseif EOW.CurrentMode == 2 then
            return "Harass"
        elseif EOW.CurrentMode == 3 then
            return "Lasthit"
        elseif EOW.CurrentMode == 4 then
            return "Clear"
        end
	elseif _G.SDK and _G.SDK.Orbwalker then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "LastHit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
	else
		return GOS:GetMode()
	end
end

local function EnableOrb(bool)
	if Orb == 1 then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif Orb == 2 then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
end

local abs = math.abs 
local deg = math.deg 
local acos = math.acos
function IsFacing(target)
    local V = Vector((target.pos - myHero.pos))
    local D = Vector(target.dir)
    local Angle = 180 - deg(acos(V*D/(V:Len()*D:Len())))
    if abs(Angle) < 80 then 
        return true  
    end
    return false
end

function IsUnderTurret(unit)
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local PussyNunu = MenuElement({type = MENU, id = "PussyNunu", name = "PussyNunu", leftIcon = "https://raw.githubusercontent.com/Pussykate/GoS/master/Woman.jpg"})

PussyNunu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	PussyNunu.Combo:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})
	PussyNunu.Combo:MenuElement({id = "W", name = "W", value = true, leftIcon = W.icon})
	PussyNunu.Combo:MenuElement({id = "E", name = "E", value = true, leftIcon = E.icon})
	PussyNunu.Combo:MenuElement({id = "R", name = "R", value = true, leftIcon = R.icon})

PussyNunu:MenuElement({id = "Harass", name = "Harass", type = MENU})
    PussyNunu.Harass:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})
    PussyNunu.Harass:MenuElement({id = "W", name = "W", value = true, leftIcon = W.icon})
	PussyNunu.Harass:MenuElement({id = "E", name = "E", value = true, leftIcon = E.icon})

PussyNunu:MenuElement({id = "Clear", name = "Clear", type = MENU})
    PussyNunu.Clear:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})
    PussyNunu.Clear:MenuElement({id = "E", name = "E", value = true, leftIcon = W.icon})
	PussyNunu.Clear:MenuElement({id = "MP", name = "Min mana", value = 35, min = 0, max = 100})
	
PussyNunu:MenuElement({id = "JClear", name = "JungleClear", type = MENU})
    PussyNunu.JClear:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})
    PussyNunu.JClear:MenuElement({id = "W", name = "W", value = true, leftIcon = W.icon})
	PussyNunu.JClear:MenuElement({id = "E", name = "E", value = true, leftIcon = E.icon})
	PussyNunu.JClear:MenuElement({id = "MP", name = "Min mana", value = 35, min = 0, max = 100})	
	
PussyNunu:MenuElement({id = "LastHit", name = "LastHit", type = MENU})
    PussyNunu.LastHit:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})	
	PussyNunu.LastHit:MenuElement({id = "MP", name = "Min mana", value = 35, min = 0, max = 100})

PussyNunu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
    PussyNunu.Killsteal:MenuElement({id = "E", name = "E", value = true, leftIcon = Q.icon})
    PussyNunu.Killsteal:MenuElement({id = "R", name = "R", value = true, leftIcon = R.icon})
	
PussyNunu:MenuElement({type = MENU, id = "Activator", name = "Activator"})
	PussyNunu.Activator:MenuElement({type = MENU, id = "P", name = "Potions"})
	PussyNunu.Activator.P:MenuElement({id = "Pot", name = "All Potions", value = true, leftIcon = "https://raw.githubusercontent.com/Pussykate/GoS/master/836591686.jpg"})
	PussyNunu.Activator.P:MenuElement({id = "HP", name = "Health % to Potion", value = 60, min = 0, max = 100})
	
	PussyNunu.Activator:MenuElement({type = MENU, id = "I", name = "Items"})
	PussyNunu.Activator.I:MenuElement({id = "Tiamat", name = "Hydra / Tiamat", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3077.png","http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3074.png"})
	PussyNunu.Activator.I:MenuElement({id = "YG", name = "Youmuu's Ghostblade", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3153.png"})	
	PussyNunu.Activator.I:MenuElement({id = "King", name = "Blade of the Ruined King", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3142.png"})
	PussyNunu.Activator.I:MenuElement({id = "RO", name = "Randuin's Omen", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3143.png"})
	
	PussyNunu.Activator:MenuElement({type = MENU, id = "S", name = "Summoner Spells"})
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
			PussyNunu.Activator.S:MenuElement({id = "Heal", name = "Heal", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerHeal.png"})
			PussyNunu.Activator.S:MenuElement({id = "HealHP", name = "HP Under %", value = 25, min = 0, max = 100})
		end
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then
			PussyNunu.Activator.S:MenuElement({id = "Barrier", name = "Barrier", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerBarrier.png"})
			PussyNunu.Activator.S:MenuElement({id = "BarrierHP", name = "HP Under %", value = 25, min = 0, max = 100})
		end
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
			PussyNunu.Activator.S:MenuElement({id = "Ignite", name = "Combo Ignite", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerDot.png"})
		end
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then
			PussyNunu.Activator.S:MenuElement({id = "Exhaust", name = "Combo Exhaust", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerExhaust.png"})
			PussyNunu.Activator.S:MenuElement({id = "EnemyHP", name = "EnemyHP Under %", value = 25, min = 0, max = 100})
		end


PussyNunu:MenuElement({id = "Draw", name = "Drawings", type = MENU})
    PussyNunu.Draw:MenuElement({id = "Q", name = "Q - Bladesurge", value = true})
    PussyNunu.Draw:MenuElement({id = "E", name = "E - Equilibrium Strike", value = true})
    PussyNunu.Draw:MenuElement({id = "R", name = "R - Transcendent Blades", value = true})

Callback.Add("Tick", function() Tick() end)
Callback.Add("Draw", function() Drawings() end)

function Tick()
	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Lane()
		JungleClear()
	elseif Mode == "LastHit" then
		LastHit()
	end
	Activator()
	Killsteal()
end

local _EnemyHeroes
local function GetEnemyHeroes()
	if _EnemyHeroes then return _EnemyHeroes end
	_EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isEnemy then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local _OnVision = {}
function OnVision(unit)
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
	return _OnVision[unit.networkID]
end
Callback.Add("Tick", function() OnVisionF() end)
local visionTick = GetTickCount()
function OnVisionF()
	if GetTickCount() - visionTick > 100 then
		for i,v in pairs(GetEnemyHeroes()) do
			OnVision(v)
		
	end
end

local _OnWaypoint = {}
function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		-- print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
					-- print("OnDash: "..unit.charName)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end

local function GetPred(unit,speed,delay,sourcePos)
	local speed = speed or math.huge
	local delay = delay or 0.25
	local sourcePos = sourcePos or myHero.pos
	local unitSpeed = unit.ms
	if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
	if OnVision(unit).state == false then
		local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
		local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(sourcePos,unitPos)/speed)))
		if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
		return predPos
	else
		if unitSpeed > unit.ms then
			local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(sourcePos,unit.pos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		elseif IsImmobileTarget(unit) then
			return unit.pos
		else
			return unit:GetPrediction(speed,delay)
		end
	end
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastSpell(spell,pos,range,delay)
local range = range or math.huge
local delay = delay or 250
local ticker = GetTickCount()

	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			Control.SetCursorPos(pos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end



function Combo()
    local target = GetTarget(E.range)
	if target == nil then return end
		if IsValidTarget(target,W.range) and PussyNunu.Combo.W:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then
			EnableOrb(false)
			Control.CastSpell(HK_W, myHero)
			DelayAction(function() EnableOrb(true) end, 0.3)
		
		end
		if IsValidTarget(target,E.range) and PussyNunu.Combo.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 550 then
			EnableOrb(false)
			Control.CastSpell(HK_E, target)
			DelayAction(function() EnableOrb(true) end, 0.3)
		
		end
		if IsValidTarget(target,R.range) and PussyNunu.Combo.R:Value() and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 400 then
			EnableOrb(false)
			Control.CastSpell(HK_R)
			DelayAction(function() EnableOrb(true) end, 3.0)
		
		end
	end
end
				
function Harass()
	local target = GetTarget(E.range)
	if target == nil then return end
		if IsValidTarget(target,W.range) and PussyNunu.Harass.W:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 700 then
			EnableOrb(false)
			Control.CastSpell(HK_W, myHero)
			DelayAction(function() EnableOrb(true) end, 0.3)
		end
		if IsValidTarget(target,E.range) and PussyNunu.Harass.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 550 then
			EnableOrb(false)
			Control.CastSpell(HK_E, target)
			DelayAction(function() EnableOrb(true) end, 0.3)
			
		end
	end
	
	
function Lane()
	if PercentMP(myHero) < PussyNunu.Clear.MP:Value() then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion then
			if minion.team == 300 - myHero.team then
				if IsValidTarget(minion,E.range) and PussyNunu.Clear.E:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 550 then
					EnableOrb(false)
					if Edmg(minion) > minion.health then
					Control.CastSpell(HK_E, minion)
					DelayAction(function() EnableOrb(true) end, 0.4)
					end
				end
			end
		end
		if minion then
			if minion.team == 300 - myHero.team then
				if IsValidTarget(minion,Q.range) and PussyNunu.LastHit.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 200 then
					EnableOrb(false)
					if Qdmg(minion) > minion.health then
						Control.CastSpell(HK_Q, minion)
						DelayAction(function() EnableOrb(true) end, 0.4)
					end
				end
			end
		end
	end
end

function JungleClear()
	if PercentMP(myHero) < PussyNunu.JClear.MP:Value() then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
        if minion.team == 300 and not minion.dead then
			if IsValidTarget(minion,Q.range) and PussyNunu.JClear.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 190 then
				EnableOrb(false)
				Control.CastSpell(HK_Q)
				DelayAction(function() EnableOrb(true) end, 0.4)
			end
			if minion then
				if IsValidTarget(minion,W.range) and PussyNunu.JClear.W:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) < 550 then
					EnableOrb(false)
					Control.CastSpell(HK_W, myHero)
					DelayAction(function() EnableOrb(true) end, 0.4)
				end
			end
			if minion then
				if IsValidTarget(minion,E.range) and PussyNunu.JClear.E:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 550 then
					EnableOrb(false)
					Control.CastSpell(HK_E)
					DelayAction(function() EnableOrb(true) end, 0.4)
				end
			end
		end
	end
end



function LastHit()
    if PercentMP(myHero) < PussyNunu.LastHit.MP:Value() then return end
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
	local level = myHero:GetSpellData(_Q).level
		if minion then
			if minion.team == 300 - myHero.team then
				if IsValidTarget(minion,Q.range) and PussyNunu.LastHit.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 200 then
					EnableOrb(false)
					if Qdmg(minion) > minion.health then
					Control.CastSpell(HK_Q, minion)
					DelayAction(function() EnableOrb(true) end, 0.3)
					end
				end
			end
		end
	end
end	
	

	function Killsteal()
	local target = GetTarget(E.range)
	if target == nil then return end
	if PussyNunu.Killsteal.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 550 then
		if Qdmg(target) >= target.health then
			EnableOrb(false)
			if Edmg(minion) > minion.health then
			Control.CastSpell(HK_E, target)
			DelayAction(function() EnableOrb(true) end, 0.3)
			end
		end
	end		
	if target == nil then return end	
	if PussyNunu.Killsteal.R:Value() and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 600 then
		if Rdmg(target) > target.health then
			EnableOrb(false)
			if Edmg(minion) > minion.health then
			Control.CastSpell(HK_E)
			DelayAction(function() EnableOrb(true) end, 3.0)
			end
		end
	end
end		


function Activator()
	local target = GetTarget(1575)
	if target == nil then return end
	local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
    end
	local Potion = items[2003] or items[2010] or items[2031] or items[2032] or items[2033]
	if Potion and target and myHero:GetSpellData(Potion).currentCd == 0 and PussyNunu.Activator.P.Pot:Value() and PercentHP(myHero) < PussyNunu.Activator.P.HP:Value() and NoPotion() then
		Control.CastSpell(HKITEM[Potion])
	end
	if GetMode() == "Combo" then	
		local Tiamat = items[3077] or items[3748] or items[3074]
		if Tiamat and myHero:GetSpellData(Tiamat).currentCd == 0 and PussyNunu.Activator.I.Tiamat:Value() and myHero.pos:DistanceTo(target.pos) < 400 and myHero.attackData.state == 2 then
		Control.CastSpell(HKITEM[Tiamat], target.pos)
		end
		local King = items[3153]
		if King and myHero:GetSpellData(King).currentCd == 0 and PussyNunu.Activator.I.King:Value() and myHero.pos:DistanceTo(target.pos) < 600 and myHero.attackData.state == 2 then
		Control.CastSpell(HKITEM[King], target.pos)
		end
		local YG = items[3142]
		if YG and myHero:GetSpellData(YG).currentCd == 0 and PussyNunu.Activator.I.YG:Value() and myHero.pos:DistanceTo(target.pos) < 1575 then
		Control.CastSpell(HKITEM[YG])
		end
		local Randuin = items[3143]
		if Randuin and myHero:GetSpellData(Randuin).currentCd == 0 and PussyNunu.Activator.I.RO:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
		Control.CastSpell(HKITEM[Randuin])
		end
	end
		
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
		if PussyNunu.Activator.S.Heal:Value() and target then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and Ready(SUMMONER_1) and PercentHP(myHero) < PussyNunu.Activator.S.HealHP:Value() then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and Ready(SUMMONER_2) and PercentHP(myHero) < PussyNunu.Activator.S.HealHP:Value() then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
	end
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then
		if PussyNunu.Activator.S.Barrier:Value() and target then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier" and Ready(SUMMONER_1) and PercentHP(myHero) < PussyNunu.Activator.S.BarrierHP:Value() then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" and Ready(SUMMONER_2) and PercentHP(myHero) < PussyNunu.Activator.S.BarrierHP:Value() then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
	end
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then
		if PussyNunu.Activator.S.Exhaust:Value() and target then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and Ready(SUMMONER_1) and PercentHP(target) < PussyNunu.Activator.S.EnemyHP:Value() then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and Ready(SUMMONER_2) and PercentHP(target) < PussyNunu.Activator.S.EnemyHP:Value() then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
	end	



	if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
		if PussyNunu.Activator.S.Ignite:Value() then
			local IgDamage = IGdmg(target)
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) and IgDamage > target.health
			and myHero.pos:DistanceTo(target.pos) < 600 then
				Control.CastSpell(HK_SUMMONER_1, target)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) and IgDamage > target.health
			and myHero.pos:DistanceTo(target.pos) < 600 then
				Control.CastSpell(HK_SUMMONER_2, target)
			end
		end
	end
end	

function Drawings()
    if myHero.dead then return end
	if PussyNunu.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, Q.range, 1,  Draw.Color(255, 000, 222, 255)) end
	if PussyNunu.Draw.E:Value() and Ready(_E) then Draw.Circle(myHero.pos, E.range, 1,  Draw.Color(255, 000, 150, 255)) end
    if PussyNunu.Draw.R:Value() and Ready(_R) then Draw.Circle(myHero.pos, R.range, 1,  Draw.Color(255, 000, 043, 255)) end
	end

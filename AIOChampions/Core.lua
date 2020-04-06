local menu = 1
local Orb
local _OnWaypoint = {}
local _OnVision = {}
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local spellcast = {state = 1, mouse = mousePos}
local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7,}
local barHeight, barWidth, barXOffset, barYOffset = 8, 103, 0, 0
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local charging = false
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local MyHeroRange = myHero.range + myHero.boundingRadius * 2
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local ControlCastSpell = Control.CastSpell
local GameCanUseSpell = Game.CanUseSpell
local GameTimer = Game.Timer
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local GameObjectCount = Game.ObjectCount
local GameObject = Game.Object
local GameParticleCount = Game.ParticleCount
local GameParticle = Game.Particle
local GameMissileCount = Game.MissileCount
local GameMissile = Game.Missile
local GameIsChatOpen = Game.IsChatOpen
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local MathSqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
_G.LATENCY = 0.05


function LoadUnits()
	for i = 1, GameHeroCount() do
		local unit = GameHero(i); Units[i] = {unit = unit, spell = nil}
		if unit.team ~= myHero.team then TableInsert(Enemies, unit)
		elseif unit.team == myHero.team and unit ~= myHero then TableInsert(Allies, unit) end
	end
	for i = 1, GameTurretCount() do
		local turret = GameTurret(i)
		if turret and turret.isEnemy then TableInsert(Turrets, turret) end
	end
end
		
local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end

function GetMode()   
    if Orb == 1 then
        if combo == 1 then
            return 'Combo'
        elseif harass == 2 then
            return 'Harass'
        elseif lastHit == 3 then
            return 'Lasthit'
        elseif laneClear == 4 then
            return 'Clear'
        end
    elseif Orb == 2 then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "LastHit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
    elseif Orb == 3 then
        return GOS:GetMode()
    elseif Orb == 4 then
        return _G.gsoSDK.Orbwalker:GetMode()
	elseif Orb == 5 then
	  return _G.PremiumOrbwalker:GetMode()
	end
end

function GetTarget(range) 
	if Orb == 1 then
		if myHero.ap > myHero.totalDamage then
			return EOW:GetTarget(range, EOW.ap_dec, myHero.pos)
		else
			return EOW:GetTarget(range, EOW.ad_dec, myHero.pos)
		end
	elseif Orb == 2 and TargetSelector then
		if myHero.ap > myHero.totalDamage then
			return TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
		else
			return TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		end
	elseif _G.GOS then
		if myHero.ap > myHero.totalDamage then
			return GOS:GetTarget(range, "AP")
		else
			return GOS:GetTarget(range, "AD")
        end
    elseif _G.gsoSDK then
		return _G.gsoSDK.TS:GetTarget()
	
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end	
end

local function SetAttack(bool)
	if _G.EOWLoaded then
		EOW:SetAttacks(bool)
	elseif _G.SDK then                                                        
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetAttack(bool)	
	else
		GOS.BlockAttack = not bool
	end

end

local function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetMovement(bool)	
	else
		GOS.BlockMovement = not bool
	end
end

local function GetDistanceSqr(p1, p2)
	if not p1 then return MathHuge end
	p2 = p2 or myHero
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
end

local function GetDistance(p1, p2)
	p2 = p2 or myHero
	return MathSqrt(GetDistanceSqr(p1, p2))
end

local function GetDistance2D(p1,p2)
	return MathSqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local function IsRecalling(unit)
	for i = 1, 63 do
	local buff = unit:GetBuff(i) 
		if buff.count > 0 and buff.name == "recall" and Game.Timer() < buff.expireTime then
			return true
		end
	end 
	return false
end 
	
local function MyHeroNotReady()
    return myHero.dead or GameIsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero)
end

--[[
local currSpell = myHero.activeSpell
if currSpell and currSpell.valid and myHero.isChanneling then
print ("Width:  "..myHero.activeSpell.width)
print ("Speed:  "..myHero.activeSpell.speed)
print ("Delay:  "..myHero.activeSpell.castFrame)
print ("range:  "..myHero.activeSpell.range)
end
]]

DelayAction(function()
	LoadScript()
	LoadUnits()
end, math.max(0.07, 30 - Game.Timer()))

DelayAction(function()
	if not Menu.Pred then return end
	if Menu.Pred.Change:Value() == 1 then
		require('GamsteronPrediction')
	else
		require('PremiumPrediction')
	end	
end, math.max(0.07, 33 - Game.Timer()))


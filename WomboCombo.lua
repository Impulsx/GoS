if myHero.charName ~= "Kalista" then return end

--Version 270118--

require 'DamageLib'
require '2DGeometry'
require 'MapPositionGOS'
require 'Collision'

local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and Game.CanUseSpell(spell) == 0
end

local function HeroesAround(range, pos, team)
    local pos = pos or myHero.pos
    local team = team or 300 - myHero.team
    local Count = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.team == team and not hero.dead and hero.pos:DistanceTo(pos, hero.pos) < range then
			Count = Count + 1
		end
	end
	return Count
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

local function GetTarget(range)
	local target = nil
	if _G.EOWLoaded then
		target = EOW:GetTarget(range)
	elseif _G.SDK and _G.SDK.Orbwalker then
		target = _G.SDK.TargetSelector:GetTarget(range)
	else
		target = GOS:GetTarget(range)
	end
	return target
end

function HasBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff and buff.count > 0 and buff.name:lower() == buffname:lower()  then 
      return true
    end
  end
  return false
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
end	



--Menu
local = MenuElement({type = MENU, name = "WomboCombo", id = "WomboCombo"})
DelayAction(function()
	for _,k in pairs(GetAllyHeroes()) do
		if GetObjectName(k) == "Blitzcrank" then
		MenuElement({type = Menu, id = "Balista", name = "Balista Combo", value = true})
	end
	end
end, 0)

local souldboundhero = nil

OnTick(function(myHero)
    local target = GetCurrentTarget()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if soulboundhero then
			if GetObjectName(soulboundhero) == "Blitzcrank" then
				if ValidTarget(enemy, 2450) and MenuElement.Balista:Value() and GetCurrentHP(enemy) > 300 and GetCurrentHP(myHero) > 400 and GetDistance(soulboundhero, enemy) > 400 and GetDistance(enemy) > 400 and GetDistance(enemy) > GetDistance(soulboundhero, enemy)+100 and GotBuff(enemy, "rocketgrab2") > 0 then
					CastSpell(_R)
					end
				end
			end
		end
	end
end

OnUpdateBuff(function(unit,buff)
  if GetTeam(unit) ~= GetTeam(myHero) and buff.Name == "kalistaexpungemarker" then
  Estack[GetNetworkID(unit)] = buff.Count
  end
  if GetTeam(unit) == GetTeam(myHero) and buff.Name == "kalistacoopstrikeally" then
  soulboundhero = unit
  end
end)

OnRemoveBuff(function(unit,buff)
  if GetTeam(unit) ~= GetTeam(myHero) and buff.Name == "kalistaexpungemarker" then
  Estack[GetNetworkID(unit)] = 0
  end
end)	

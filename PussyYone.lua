local Heroes = {"Yone"}

if not table.contains(Heroes, myHero.charName) then return end

require "DamageLib"


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

-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyYone.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyYone.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyYone.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyYone.version"
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
        local textPos = myHero.pos:To2D()
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print("New PussyYone Version Press 2x F6")
        else
            print("PussyYone start after 15sec Ingame")
        end
    
    end
    
    AutoUpdate()

end 

----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

local checkCount = 0 
local heroes = false
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local sqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
local GameTimer = Game.Timer
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local DrawRect = Draw.Rect
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local GameCanUseSpell = Game.CanUseSpell
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local GameIsChatOpen = Game.IsChatOpen
_G.LATENCY = 0.05


function LoadUnits()
	for i = 1, GameHeroCount() do
		local unit = GameHero(i); Units[i] = {unit = unit, spell = nil}
		if unit.team ~= myHero.team then TableInsert(Enemies, unit)
		elseif unit.team == myHero.team and unit ~= myHero then TableInsert(Allies, unit) end
	end
	for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i)
		if turret and turret.isEnemy then TableInsert(Turrets, turret) end
	end
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

local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

local function GetDistance(pos1, pos2)
	return sqrt(GetDistanceSqr(pos1, pos2))
end

function GetTarget(range) 
	if _G.SDK then
		if myHero.ap > myHero.totalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
		end
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end
end

function GetMode()   
    if _G.SDK then
        return 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "LaneClear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] and "LaneClear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] and "LastHit"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] and "Flee"
		or nil
    
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetMode()
	end
	return nil
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

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end 

local function GetEnemyTurrets()
	return Turrets
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

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurrets()) do
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if not turret.dead then 
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff
		end
	end
	return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

local function IsRecalling(unit)
	local buff = GetBuffData(unit, "recall")
	if buff and buff.duration > 0 then
		return true, GameTimer() - buff.startTime
	end
    return false
end

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

local function GetLineTargetCount(source, Pos, delay, speed, width, range)
	local Count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
		if hero and myHero.pos:DistanceTo(hero.pos) <= range and IsValid(hero) then
			
			local predictedPos = PredictUnitPosition(hero, delay+ GetDistance(source, hero.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (hero.boundingRadius + width) * (hero.boundingRadius + width)) then
				Count = Count + 1
			end
		end
	end
	return Count
end

local function CalcFullDmg(unit)
	local QDmg     = Ready(_Q) and CalcPhysicalDamage(myHero, unit, (myHero:GetSpellData(_Q).level * 25 - 5) + myHero.totalDamage) or 0
	local WPDmg    = Ready(_W) and CalcPhysicalDamage(myHero, unit, (myHero:GetSpellData(_W).level * 5)) + CalcPhysicalDamage(myHero, unit, (myHero:GetSpellData(_W).level * 0.005 + 0.05) * unit.maxHealth) or 0
	local WMDmg    = Ready(_W) and CalcMagicalDamage(myHero, unit, (myHero:GetSpellData(_W).level * 5)) + CalcMagicalDamage(myHero, unit, (myHero:GetSpellData(_W).level * 0.005 + 0.05) * unit.maxHealth) or 0	
	local RPDmg    = Ready(_R) and CalcPhysicalDamage(myHero, unit, myHero:GetSpellData(_R).level * 100 + 0.4 * myHero.totalDamage) or 0
	local RMDmg    = Ready(_R) and CalcMagicalDamage(myHero, unit, myHero:GetSpellData(_R).level * 100 + 0.4 * myHero.totalDamage) or 0	
	local AADmg	   = CalcPhysicalDamage(myHero, unit, myHero.totalDamage * 2) + ((CalcPhysicalDamage(myHero, unit, 0.5 * myHero.totalDamage) + CalcMagicalDamage(myHero, unit, 0.5 * myHero.totalDamage)) * 2)	
	local CalcEDmg = (QDmg + WPDmg + WMDmg + RPDmg + RMDmg + AADmg) / 100
	local EDmg     = ((myHero:GetSpellData(_E).level * 2.5) + 22.5) * CalcEDmg
	local damage   = AADmg
	
	if Ready(_Q) then
		damage = damage + CalcPhysicalDamage(myHero, unit, (myHero:GetSpellData(_Q).level * 25 - 5) + myHero.totalDamage)
	end	
	if Ready(_W) then
		damage = damage + CalcPhysicalDamage(myHero, unit, (myHero:GetSpellData(_W).level * 5)) + CalcPhysicalDamage(myHero, unit, (myHero:GetSpellData(_W).level * 0.005 + 0.05) * unit.maxHealth) + CalcMagicalDamage(myHero, unit, (myHero:GetSpellData(_W).level * 5)) + CalcMagicalDamage(myHero, unit, (myHero:GetSpellData(_W).level * 0.005 + 0.05) * unit.maxHealth)
	end	
	if Ready(_E) then
		damage = damage + EDmg
	end	
	if Ready(_R) then
		damage = damage + CalcPhysicalDamage(myHero, unit, myHero:GetSpellData(_R).level * 100 + 0.4 * myHero.totalDamage) + CalcMagicalDamage(myHero, unit, myHero:GetSpellData(_R).level * 100 + 0.4 * myHero.totalDamage)
	end		
	return damage
end
--[[
local function CalcFullDmg(unit)
	local QDmg     = Ready(_Q) and getdmg("Q", unit, myHero) or 0
	local WDmg     = Ready(_W) and getdmg("W", unit, myHero, 1) + getdmg("W", unit, myHero, 2) or 0
	local RDmg 	   = Ready(_R) and getdmg("R", unit, myHero, 1) + getdmg("R", unit, myHero, 2) or 0
	local AADmg	   = CalcPhysicalDamage(myHero, unit, myHero.totalDamage * 2) + ((CalcPhysicalDamage(myHero, unit, 0.5 * myHero.totalDamage) + CalcMagicalDamage(myHero, unit, 0.5 * myHero.totalDamage)) * 2)	
	local CalcEDmg = (QDmg + WDmg + RDmg + AADmg) / 100
	local EDmg     = ((myHero:GetSpellData(_E).level * 2.5) + 22.5) * CalcEDmg
	local damage   = AADmg
	
	if Ready(_Q) then
		damage = damage + getdmg("Q", unit, myHero)
	end	
	if Ready(_W) then
		damage = damage + getdmg("W", unit, myHero, 1) + getdmg("W", unit, myHero, 2)
	end	
	if Ready(_E) then
		damage = damage + EDmg
	end	
	if Ready(_R) then
		damage = damage + getdmg("R", unit, myHero, 1) + getdmg("R", unit, myHero, 2)
	end		
	return damage
end
]]
local function CalcTurretDmg()
	local Damage = 0
	local TimeCalc = 100
	local Timer = GameTimer()
	
	if Timer < 30 then
		TimeCalc = 0
	elseif Timer < 90 then
		TimeCalc = 1
	elseif Timer < 150 then
		TimeCalc = 2
	elseif Timer < 210 then
		TimeCalc = 3
	elseif Timer < 270 then
		TimeCalc = 4
	elseif Timer < 330 then
		TimeCalc = 5
	elseif Timer < 390 then
		TimeCalc = 6
	elseif Timer < 450 then
		TimeCalc = 7
	elseif Timer < 510 then
		TimeCalc = 8
	elseif Timer < 570 then
		TimeCalc = 9
	elseif Timer < 630 then
		TimeCalc = 10
	elseif Timer < 690 then
		TimeCalc = 11
	elseif Timer < 750 then
		TimeCalc = 12
	elseif Timer < 810 then
		TimeCalc = 13
	elseif Timer >= 810 then
		TimeCalc = 14
	end
	
	if TimeCalc < 100 then
		local Dmg = 152 + (9 * TimeCalc)
		Damage = Dmg
	end
	return Damage
end

local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

local function MyHeroNotReady()
    return myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero)
end


----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Yone"

local QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.35, Radius = 80, Range = 900, Speed = 1500, Collision = false}
local QspellData = {speed = 1700, range = 900, delay = 0.35, radius = 80, collision = {nil}, type = "linear"}

local Q2Data = {Type = _G.SPELLTYPE_LINE, Delay = 0.65, Radius = 80, Range = 1150, Speed = 1500, Collision = false}
local Q2spellData = {speed = 1700, range = 1150, delay = 0.65, radius = 80, collision = {nil}, type = "linear"}

local WspellData = {speed = 2000, range = 600, delay = 0.15, radius = 0, angle = 80, collision = {nil}, type = "conic"}

local RData = {Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 120, Range = 900, Speed = 1500, Collision = false}
local RspellData = {speed = 1500, range = 900, delay = 0.5, radius = 120, collision = {nil}, type = "linear"}

local R2Data = {Type = _G.SPELLTYPE_LINE, Delay = 0.8, Radius = 120, Range = 1200, Speed = 1500, Collision = false}
local R2spellData = {speed = 1500, range = 1200, delay = 0.8, radius = 120, collision = {nil}, type = "linear"}

local PredLoaded = false
function Yone:__init()	
	self:LoadMenu()

	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)

	if not PredLoaded then
		DelayAction(function()
			if self.Menu.MiscSet.Pred.Change:Value() == 1 then
				require('GamsteronPrediction')
				PredLoaded = true
			elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
				require('PremiumPrediction')
				PredLoaded = true
			else 
				require('GGPrediction')
				PredLoaded = true					
			end
		end, 1)	
	end
end

function Yone:LoadMenu()                     	
									 -- MainMenu --
	self.Menu = MenuElement({type = MENU, id = "PussyYone", name = "PussyYone"})
	self.Menu:MenuElement({name = " ", drop = {"Version 0.01"}})
	
	
									  -- Combo --
	self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})
	
	-- Q --
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Q", name = "Q Settings"})
	self.Menu.ComboSet.Q:MenuElement({id = "UseQ1", name = "Use [Q] in Combo", value = true})	
	self.Menu.ComboSet.Q:MenuElement({id = "UseQ2", name = "Stack [Q] on Minions", value = true})
	self.Menu.ComboSet.Q:MenuElement({id = "UseQ3", name = "[Q3] Single Target", value = true})	
	self.Menu.ComboSet.Q:MenuElement({id = "UseQ4", name = "[Q3] Focus Multiple Targets", value = true})
	--self.Menu.ComboSet.Q:MenuElement({id = "UseQ5", name = "[Q3]+Flash behind Multiple Targets", value = true})		
			
	-- W --
	self.Menu.ComboSet:MenuElement({type = MENU, id = "W", name = "W Settings"})		
	self.Menu.ComboSet.W:MenuElement({id = "UseW1", name = "Use [W] in Combo", value = true})
	self.Menu.ComboSet.W:MenuElement({id = "UseW2", name = "[W] Focus Multiple Targets ( Bigger Shield )", value = true})	

	-- E --
	self.Menu.ComboSet:MenuElement({type = MENU, id = "E", name = "E Settings"})		
	self.Menu.ComboSet.E:MenuElement({id = "UseE1", name = "Use [E] in Combo", value = true})
	self.Menu.ComboSet.E:MenuElement({id = "UseE2", name = "Save Life under Tower (E2 Back if can Tower kill you)", value = true})
	self.Menu.ComboSet.E:MenuElement({id = "UseE3", name = "[E2] Back ( Back if Yone Hp lower than Slider )", value = true})
	self.Menu.ComboSet.E:MenuElement({id = "Hp", name = "[E2] Back if Yone Hp lower than -->", value = 20, min = 0, max = 100, identifier = "%"})	
	
	-- R --
	self.Menu.ComboSet:MenuElement({type = MENU, id = "R", name = "R Settings"})		
	self.Menu.ComboSet.R:MenuElement({id = "UseR1", name = "Use [R] in Combo", value = true})
	self.Menu.ComboSet.R:MenuElement({id = "UseR2", name = "[R] Single Target if killable full Combo", value = true})
	self.Menu.ComboSet.R:MenuElement({id = "UseR3", name = "[R] Focus Multiple Targets", value = true})
	self.Menu.ComboSet.R:MenuElement({id = "RCount", name = "[R] Multiple Targets", value = 2, min = 2, max = 5, step = 1})
	
	
									  -- Harass --
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})	
	
	self.Menu.Harass:MenuElement({id = "UseQ1", name = "Use [Q] in Harass", value = true})	
	self.Menu.Harass:MenuElement({id = "UseQ2", name = "Use [Q3] in Harass", value = true})
	self.Menu.Harass:MenuElement({id = "UseQ3", name = "Stack [Q] on Minions", value = true})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "Use [W] in Harass", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "Use [E] in Harass", value = true})
	self.Menu.Harass:MenuElement({id = "UseE2", name = "[E2] Back ( Back if Yone Hp lower than Slider )", value = true})
	self.Menu.Harass:MenuElement({id = "Hp", name = "[E2] Back if Yone Hp lower than -->", value = 20, min = 0, max = 100, identifier = "%"})	


								  -- Lane/JungleClear --
	self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ1", name = "Use [Q]", value = true})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ2", name = "Use [Q3]", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "UseW", name = "Use [W]", value = true})	
	
	--JungleClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ1", name = "Use [Q]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ2", name = "Use [Q3]", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "UseW", name = "Use [W]", value = true})		


										-- Misc --
    self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})	
			
	--Prediction
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.Menu.MiscSet.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q3]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] and [Q3] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "Kill", name = "Draw KillText 1 vs 1", value = true})		
end
	
local EPos = false
local CanCast = false
function Yone:Tick()	
if heroes == false then 
	for i, unit in pairs(Enemies) do			
		checkCount = checkCount + 1
	end
	if checkCount < 1 then
		LoadUnits()
	else
		heroes = true
	end
end	

if Ready(_E) and myHero.mana == 0 then
	EPos = true
else
	EPos = false
end	

if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "LaneClear" then
		self:JungleClear()
		self:Clear()	
	end			
end

function Yone:Combo()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target) then
		local EnemyCount = GetEnemyCount(2000, myHero)
		
		if self.Menu.ComboSet.E.UseE3:Value() and myHero.mana > 0 and Ready(_E) then
			if myHero.health/myHero.maxHealth <= self.Menu.ComboSet.E.Hp:Value() / 100 then
				SetAttack(false)
				SetMovement(false)
				Control.CastSpell(HK_E)
				DelayAction(function()
					SetAttack(true)
					SetMovement(true)
				end,0.2)
			end
		end

		if self.Menu.ComboSet.E.UseE2:Value() and myHero.mana > 0 and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 750 and IsUnderTurret(myHero) and IsUnderTurret(target) then
				local TurretDmg = CalcTurretDmg()
				if TurretDmg >= (myHero.health - (TurretDmg+50)) then
					SetAttack(false)
					SetMovement(false)
					Control.CastSpell(HK_E)
					DelayAction(function()
						SetAttack(true)
						SetMovement(true)
					end,0.2)
				end	
			end
		end		
		
		if Ready(_R) and self.Menu.ComboSet.R.UseR1:Value() and CanCast == false then			
			if self.Menu.ComboSet.R.UseR3:Value() then
				for i, Enemy in ipairs(GetEnemyHeroes()) do
					if self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0 then
						if Enemy and myHero.pos:DistanceTo(Enemy.pos) <= 1200 and IsValid(Enemy) then
							local count = GetLineTargetCount(myHero.pos, Enemy.pos, 0.75, 1700, 300, 1200)
							if count >= self.Menu.ComboSet.R.RCount:Value() then					
								CanCast = true
								Control.CastSpell(HK_E, Enemy.pos)
								DelayAction(function()
									Control.CastSpell(HK_R, Enemy.pos)
									CanCast = false
								end,0.3)									
							end
						end
					else
						if Enemy and myHero.pos:DistanceTo(Enemy.pos) <= 900 and IsValid(Enemy) then
							local count = GetLineTargetCount(myHero.pos, Enemy.pos, 0.75, 1700, 300, 900)
							if count >= self.Menu.ComboSet.R.RCount:Value() then					
								CanCast = true
								Control.CastSpell(HK_R, Enemy.pos)
								CanCast = false
							end
						end
					end	
				end	
			end

			if self.Menu.ComboSet.R.UseR2:Value() and EnemyCount == 1 then					
				if self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0 then
					if myHero.pos:DistanceTo(target.pos) <= 1200 then
						local FullDmg = CalcFullDmg(target)
						if FullDmg >= target.health then
							self:CastR(target)
						end	
					end	
				else
					if myHero.pos:DistanceTo(target.pos) <= 900 then
						local FullDmg = CalcFullDmg(target)
						if FullDmg >= target.health then
							self:CastR(target)
						end
					end	
				end
			end
		end			
		
		if self.Menu.ComboSet.W.UseW1:Value() and Ready(_W) and CanCast == false then			
			local CheckCount = GetEnemyCount(600, myHero)
			if self.Menu.ComboSet.W.UseW2:Value() and CheckCount >= 2 then
				self:CastW()
			else
				if myHero.pos:DistanceTo(target.pos) <= 500 then
					Control.CastSpell(HK_W, target.pos)
				end
			end	
		end	
			
		if self.Menu.ComboSet.Q.UseQ1:Value() and Ready(_Q) and CanCast == false then			
			if myHero:GetSpellData(_Q).name == "YoneQ" then
				if myHero.pos:DistanceTo(target.pos) <= 450 then
					Control.CastSpell(HK_Q, target.pos)
				else
					if self.Menu.ComboSet.Q.UseQ2:Value() then
						self:StackQMinion()
					end
				end
			else
				if self.Menu.ComboSet.Q.UseQ3:Value() and myHero:GetSpellData(_Q).name == "YoneQ3" and Ready(_Q) then
					if EnemyCount == 1 then
						if self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0  then
							if myHero.pos:DistanceTo(target.pos) <= 1150 then
								self:CastQ(target)	
							end
						else
							if myHero.pos:DistanceTo(target.pos) <= 850 then
								self:CastQ(target)
							end							
						end	
					end
				end	
				
				if self.Menu.ComboSet.Q.UseQ4:Value() and myHero:GetSpellData(_Q).name == "YoneQ3" and Ready(_Q) then
					for i, Enemy in ipairs(GetEnemyHeroes()) do
						if self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0 then
							if Enemy and myHero.pos:DistanceTo(Enemy.pos) <= 1200 and IsValid(Enemy) then
								local count = GetLineTargetCount(myHero.pos, Enemy.pos, 0.25, 1700, 200, 1200)
								if count >= 2 then					
									CanCast = true
									Control.CastSpell(HK_E, Enemy.pos)
									DelayAction(function()
										Control.CastSpell(HK_Q, Enemy.pos)
										CanCast = false
									end,0.3)	
								end
							end
						else
							if Enemy and myHero.pos:DistanceTo(Enemy.pos) <= 850 and IsValid(Enemy) then
								local count = GetLineTargetCount(myHero.pos, Enemy.pos, 0.25, 1700, 200, 850)
								if count >= 2 then
									CanCast = true
									Control.CastSpell(HK_Q, Enemy.pos)
									CanCast = false
								end
							end
						end	
					end	
				end				
			end
		end
	end
end	

function Yone:Harass()
local target = GetTarget(1300)     	
if target == nil then return end 
	if IsValid(target) then
	
		if self.Menu.Harass.UseE2:Value() and myHero.mana > 0 and Ready(_E) then
			if myHero.health/myHero.maxHealth <= self.Menu.Harass.Hp:Value() / 100 then
				SetAttack(false)
				SetMovement(false)
				Control.CastSpell(HK_E)
				DelayAction(function()
					SetAttack(true)
					SetMovement(true)
				end,0.2)
			end
		end			
		
		if self.Menu.Harass.UseW:Value() and Ready(_W) then			
			if myHero.pos:DistanceTo(target.pos) <= 500 then
				Control.CastSpell(HK_W, target.pos)
			end
		end	
			
		if self.Menu.Harass.UseQ1:Value() and Ready(_Q) then
			
			if myHero:GetSpellData(_Q).name == "YoneQ" then
				if myHero.pos:DistanceTo(target.pos) <= 450 then
					Control.CastSpell(HK_Q, target.pos)
				else
					if self.Menu.Harass.UseQ3:Value() then
						self:StackQMinion()
					end
				end
			else
				if self.Menu.Harass.UseQ2:Value() and myHero:GetSpellData(_Q).name == "YoneQ3" and Ready(_Q) then
					if self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.mana == 0 then
						if myHero.pos:DistanceTo(target.pos) <= 1200 then
							Control.CastSpell(HK_E, target.pos)
							DelayAction(function()
								Control.CastSpell(HK_Q, target.pos)
							end,0.3)	
						end
					else
						if myHero.pos:DistanceTo(target.pos) <= 850 then
							self:CastQ(target)
						end							
					end	
				end				
			end
		end
	end
end

function Yone:StackQMinion()
	if Ready(_Q) and myHero:GetSpellData(_Q).name == "YoneQ" then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)

			if (minion.team == TEAM_JUNGLE or minion.team == TEAM_ENEMY) and myHero.pos:DistanceTo(minion.pos) <= 450 and IsValid(minion) then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end	
	end	
end		

function Yone:JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_JUNGLE and IsValid(minion) then
 			
			if self.Menu.ClearSet.JClear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, minion.pos)                  
            end           
           
			if self.Menu.ClearSet.JClear.UseQ1:Value() then
				if myHero.pos:DistanceTo(minion.pos) <= 475 and myHero:GetSpellData(_Q).name == "YoneQ" and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end	

			if self.Menu.ClearSet.JClear.UseQ2:Value() then
				if myHero.pos:DistanceTo(minion.pos) <= 450 and myHero:GetSpellData(_Q).name == "YoneQ3" and Ready(_Q) then 
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end				
        end
    end
end
			
function Yone:Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if self.Menu.ClearSet.Clear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, minion.pos)                  
            end           
           
			if self.Menu.ClearSet.Clear.UseQ1:Value() then
				if myHero.pos:DistanceTo(minion.pos) <= 475 and myHero:GetSpellData(_Q).name == "YoneQ" and Ready(_Q) then 
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end	

			if self.Menu.ClearSet.Clear.UseQ2:Value() then
				if myHero.pos:DistanceTo(minion.pos) <= 450 and myHero:GetSpellData(_Q).name == "YoneQ3" and Ready(_Q) then 
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end				
        end
    end
end

function Yone:CastQ(unit)
	if EPos then
		if self.Menu.MiscSet.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, Q2Data, myHero)
			if pred.Hitchance >= self.Menu.MiscSet.Pred.PredQ:Value()+1 then
				CanCast = true
				Control.CastSpell(HK_E, pred.CastPosition)
				DelayAction(function()
					Control.CastSpell(HK_Q, pred.CastPosition)
					CanCast = false
				end,0.3)
			end
		elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, Q2spellData)
			if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredQ:Value(), pred.HitChance) then
				CanCast = true
				Control.CastSpell(HK_E, pred.CastPos)
				DelayAction(function()
					Control.CastSpell(HK_Q, pred.CastPos)
					CanCast = false
				end,0.3)
			end
		else
			self:CastQGGPred(unit)	
		end
	else
		if self.Menu.MiscSet.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, QData, myHero)
			if pred.Hitchance >= self.Menu.MiscSet.Pred.PredQ:Value()+1 then
				CanCast = true
				Control.CastSpell(HK_Q, pred.CastPosition)
				CanCast = false
			end
		elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
			if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredQ:Value(), pred.HitChance) then
				CanCast = true
				Control.CastSpell(HK_Q, pred.CastPos)
				CanCast = false
			end
		else
			self:CastQGGPred(unit)	
		end
	end
end	

function Yone:CastW()
	for i, Enemy in ipairs(GetEnemyHeroes()) do
		if Enemy and myHero.pos:DistanceTo(Enemy.pos) <= 600 and IsValid(Enemy) then
			if self.Menu.MiscSet.Pred.Change:Value() == 1 then
				local CheckCount = GetEnemyCount(300, Enemy)
				if CheckCount >= 2 then
					Control.CastSpell(HK_W, Enemy.pos)
				end
			elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, Enemy, WspellData)
				if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredW:Value(), pred.HitChance) and pred.HitCount >= 2 then
					Control.CastSpell(HK_W, pred.CastPos)
				end
			else
				self:CastWGGPred(2, 0.5)	
			end	
		end
	end
end	

function Yone:CastR(unit)
	if EPos then
		if self.Menu.MiscSet.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, R2Data, myHero)
			if pred.Hitchance >= self.Menu.MiscSet.Pred.PredR:Value()+1 then
				CanCast = true
				Control.CastSpell(HK_E, pred.CastPosition)
				DelayAction(function()
					Control.CastSpell(HK_R, pred.CastPosition)
					CanCast = false
				end,0.3)
			end
		elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, R2spellData)
			if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
				CanCast = true
				Control.CastSpell(HK_E, pred.CastPos)
				DelayAction(function()
					Control.CastSpell(HK_R, pred.CastPos)
					CanCast = false
				end,0.3)				
			end
		else
			self:CastRGGPred(unit)	
		end
	else
		if self.Menu.MiscSet.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, RData, myHero)
			if pred.Hitchance >= self.Menu.MiscSet.Pred.PredR:Value()+1 then
				CanCast = true
				Control.CastSpell(HK_R, pred.CastPosition)
				CanCast = false
			end
		elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RspellData)
			if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
				CanCast = true
				Control.CastSpell(HK_R, pred.CastPos)
				CanCast = false
			end
		else
			self:CastRGGPred(unit)	
		end
	end	
end	

function Yone:CastQGGPred(unit)
	local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.35, Radius = 100, Range = 900, Speed = 1700, Collision = false})
	local Q2Prediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.65, Radius = 100, Range = 1150, Speed = 1700, Collision = false})
	if EPos then
		Q2Prediction:GetPrediction(unit, myHero)
		if Q2Prediction:CanHit(self.Menu.MiscSet.Pred.PredQ:Value()+1) then
			CanCast = true
			Control.CastSpell(HK_E, Q2Prediction.CastPosition)
			DelayAction(function()
				Control.CastSpell(HK_Q, Q2Prediction.CastPosition)
				CanCast = false
			end,0.3)
		end	
	else
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(self.Menu.MiscSet.Pred.PredQ:Value()+1) then
			CanCast = true
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
			CanCast = false
		end	
	end	
end

function Yone:CastWGGPred(mintargets, maxtimetohit)
    local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.3, Radius = 300, Range = 600, Speed = 2000, Collision = false})
	local minhitchance = self.Menu.MiscSet.Pred.PredW:Value()+1
    local aoeresult = RPrediction:GetAOEPrediction(myHero)
    local bestaoe = nil
    local bestcount = 0
    local bestdistance = 1000
    for i = 1, #aoeresult do
        local aoe = aoeresult[i]
        if aoe.HitChance >= minhitchance and aoe.TimeToHit <= maxtimetohit and aoe.Count >= mintargets then
            if aoe.Count > bestcount or (aoe.Count == bestcount and aoe.Distance < bestdistance) then
                bestdistance = aoe.Distance
                bestcount = aoe.Count
                bestaoe = aoe
            end
        end
    end
    if bestaoe then
        Control.CastSpell(HK_W, bestaoe.CastPosition) 
    end
end

function Yone:CastRGGPred(unit)
	local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.5, Radius = 150, Range = 900, Speed = 1700, Collision = false})
	local R2Prediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.8, Radius = 150, Range = 1200, Speed = 1700, Collision = false})	
	if EPos then	  
		R2Prediction:GetPrediction(unit, myHero)
		if R2Prediction:CanHit(self.Menu.MiscSet.Pred.PredR:Value()+1) then
			CanCast = true
			Control.CastSpell(HK_E, R2Prediction.CastPosition)
			DelayAction(function()
				Control.CastSpell(HK_R, R2Prediction.CastPosition)
				CanCast = false
			end,0.3)			
		end
	else
		RPrediction:GetPrediction(unit, myHero)
		if RPrediction:CanHit(self.Menu.MiscSet.Pred.PredR:Value()+1) then
			CanCast = true
			Control.CastSpell(HK_R, RPrediction.CastPosition)
			CanCast = false
		end	
	end	
end
 
function Yone:Draw()
	
	if heroes == false then
		Draw.Text(myHero.charName.." is Loading ( Search Enemys ) !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 255, 0, 0))
	else
		if DrawTime == false then
			Draw.Text(myHero.charName.." is Ready !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 0, 255, 0))
			DelayAction(function()
			DrawTime = true
			end, 4.0)
		end	
	end

	if myHero.dead then return end
	
	if self.Menu.MiscSet.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 1000, 1, DrawColor(255, 225, 255, 10))
	end                                                 
	if self.Menu.MiscSet.Drawing.DrawQ:Value() and Ready(_Q) then
		if myHero:GetSpellData(_Q).name == "YoneQ3" then
			DrawCircle(myHero, 950, 1, DrawColor(225, 225, 0, 10))
		else
			DrawCircle(myHero, 475, 1, DrawColor(225, 225, 0, 10))
		end
	end
	if self.Menu.MiscSet.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 600, 1, DrawColor(225, 225, 125, 10))
	end
	
	if self.Menu.MiscSet.Drawing.Kill:Value() then
		local target = GetTarget(1500)     	
		if target == nil then return end

		if IsValid(target) then
			local EnemyCount = GetEnemyCount(2000, myHero)
			if EnemyCount == 1 then
				local FullDmg = CalcFullDmg(target)
				if FullDmg >= target.health then
					DrawText("Kill him", 15, target.pos2D.x, target.pos2D.y, DrawColor(0xFF00FF00))
				end
			end
		end	
	end	
end

DelayAction(function()
	if table.contains(Heroes, myHero.charName) then		
		_G[myHero.charName]()
	end	

	Callback.Add("Load", function()	
		LoadUnits()
	end)		
end, math.max(0.07, 15 - GameTimer()))

local Heroes = {"Quinn"}

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
            Name = "PussyQuinn.lua",
            Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/PussyQuinn.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyQuinn.version",
            Url = "https://raw.githubusercontent.com/Impulsx/GoS/master/PussyQuinn.version"
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
            print("New PussyQuinn Version Press 2x F6")
        else
            print("PussyQuinn loaded")
        end
    
    end
    
    AutoUpdate()

end 


----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local LastDist = 0
local LockedTarget = nil
local foundAUnit = false
local MarkedMinion = nil
local _movementHistory = {}
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local wClock = 0
local _OnVision = {}
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
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
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

local function GetEnemyHeroes()
	return Enemies
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

local function IsRecalling(unit)
	local buff = GetBuffData(unit, "recall")
	if buff and buff.duration > 0 then
		return true, GameTimer() - buff.startTime
	end
    return false
end

local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

local function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,GameMinionCount() do
	local hero = GameMinion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
			count = count + 1
		end
	end
	return count
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

local function MyHeroNotReady()
    return myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero)
end

----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Quinn"

	
local PredLoaded = false

function Quinn:__init()
	self:LoadMenu()
	self.LoseVisionTarget = {}
	Callback.Add("Tick",function()self:Tick()end)
	Callback.Add("Draw",function()self:Draw()end)
	
	if not PredLoaded then
		DelayAction(function()
			if self.Menu.Pred.Change:Value() == 1 then
				require('GamsteronPrediction')
				PredLoaded = true
			end	
			if self.Menu.Pred.Change:Value() == 2 then
				require('PremiumPrediction')
				PredLoaded = true
			end	
			if self.Menu.Pred.Change:Value() == 3 then 
				require('GGPrediction')
				PredLoaded = true					
			end
		end, 1)	
	end
	DelayAction(function()
		if self.Menu.Pred.Change:Value() == 1 then
			self.QData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1025, Speed = 1550, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}}
		end
		if self.Menu.Pred.Change:Value() == 2 then
			self.QspellData = {speed = 1550, range = 1025, delay = 0.25, radius = 60, collision = {"minion"}, type = "linear"}
		end
		if self.Menu.Pred.Change:Value() == 3 then  
			self.QPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = 1025, Speed = 1550, Collision = true, Type = GGPrediction.SPELLTYPE_LINE})				
		end
	end, 1.2)	
end 

function Quinn:LoadMenu()
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "PussyQuinn", name = "PussyQuinn"})
	self.Menu:MenuElement({name = " ", drop = {"Version 0.01"}})


	self.Menu:MenuElement({type=MENU,id="Combo",name="Combo Settings"})
		self.Menu.Combo:MenuElement({id="ComboQ",name="Use Q",value=true})
		self.Menu.Combo:MenuElement({id="ComboW",name="Use W if lose vision in AA range", value=true})
		self.Menu.Combo:MenuElement({id="ComboE",name="Use E",value=true})
		
	self.Menu:MenuElement({type=MENU,id="Harass",name="Harass Settings"})
		self.Menu.Harass:MenuElement({id="HarassQ",name="Use Q",value=true})
		self.Menu.Harass:MenuElement({id="HarassW",name="Use W if lose vision in AA range", value=true})
		self.Menu.Harass:MenuElement({id="HarassE",name="Use E",value=true})
		self.Menu.Harass:MenuElement({id="HarassMana",name="Min. Mana", value= 40, min= 0, max= 100})
		
	self.Menu:MenuElement({type=MENU,id="Clear",name="LaneClear Settings"})
		self.Menu.Clear:MenuElement({id="ClearQ",name="Use Q",value=true})
		self.Menu.Clear:MenuElement({id = "QCount", name = "min Minions for [Q]", value = 3, min = 1, max = 7, step = 1})		
		self.Menu.Clear:MenuElement({id="ClearMana",name="Min. Mana", value= 40, min= 0, max= 100})		
		
	self.Menu:MenuElement({type=MENU,id="Misc",name="Misc Settings"})
		self.Menu.Misc:MenuElement({id="WDist",name="[W]-[Combo/Harass] Check range invisible target", value= 900, min= 0, max= 1500})
		self.Menu.Misc:MenuElement({id="ProgPassiveH",name="Prog passive Minion [Harass]",value=true, tooltip = "if no Enemy in AA range"})		
		self.Menu.Misc:MenuElement({id="Passive",name="Block spells if target is under passive",value=true})
		self.Menu.Misc:MenuElement({id="NotQ_underR",name="Block Q under Ulti",value=true})
		self.Menu.Misc:MenuElement({id="E_AAreset",name="Use E to reset AA",value=true})
		self.Menu.Misc:MenuElement({type=MENU,id="flee",name="Flee Settings"})	
		self.Menu.Misc.flee:MenuElement({id="fleeprog",name="AA if enemy/minion has passive Buff",value=true})
		self.Menu.Misc.flee:MenuElement({id = "key", name = "Flee key", key = string.byte("A")})		
		self.Menu.Misc:MenuElement({type=MENU,id="AntiGap",name="Anti Gapclose Settings"})		
		self.Menu.Misc.AntiGap:MenuElement({id="Gap",name="[E] Anti Gapcloser",value=true})
		DelayAction(function()		
			for i, unit in ipairs(GetEnemyHeroes()) do
				self.Menu.Misc.AntiGap:MenuElement({id = unit.networkID, name = "Use on " ..unit.charName, value = true})
			end
		end,0.3)	
		
	self.Menu:MenuElement({type=MENU,id="KS",name="KillSteal Settings"})
		self.Menu.KS:MenuElement({id="Q_KS",name="Use Q",value=true})
		self.Menu.KS:MenuElement({id="E_KS",name="Use E",value=true})
		self.Menu.KS:MenuElement({id="R_KS",name="Calculate full Damage ( Q + E + R + AA )",value=true})
		
	self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
		self.Menu.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
		self.Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
		self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})		
		
	self.Menu:MenuElement({type=MENU,id="Draw",name="Drawing Settings"})	
		self.Menu.Draw:MenuElement({id="DrawReady",name="Draw Only Ready Spells [?]",value=true,tooltip="Only draws spells when they're ready"})
		self.Menu.Draw:MenuElement({id="DrawQ",name="Draw Q Range",value=false})
		self.Menu.Draw:MenuElement({id="DrawW",name="Draw W Range",value=false})
		self.Menu.Draw:MenuElement({id="DrawE",name="Draw E Range",value=false})
		self.Menu.Draw:MenuElement({id="DrawTarget",name="Draw Target [?]",value=false,tooltip="Draws current target"})
end 

function Quinn:Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass"then 
		self:Harass()
		if self.Menu.Misc.ProgPassiveH:Value()then
			self:ProgPassive()	
		end	
	elseif Mode == "LaneClear" then
		self:Clear()
	elseif Mode == "Flee" then
		if self.Menu.Misc.flee.fleeprog:Value()	and self.Menu.Misc.flee.key:Value() then
			self:Flee()
		end	
	end
	
	if self.Menu.Misc.AntiGap.Gap:Value()then 
		self:AntiGapCloser()
	end 
	if self.Menu.KS.Q_KS:Value() or self.Menu.KS.E_KS:Value() or self.Menu.KS.R_KS:Value()then 
		self:KillSteal()
	end
	self:CastW()
end

-- Thanks to Series --
function Quinn:CastW()
	if Ready(_W) and (GetMode() == "Combo" and self.Menu.Combo.ComboW:Value()) or (GetMode() == "Harass" and self.Menu.Harass.HarassW:Value()) then
		for i, target in ipairs(GetEnemyHeroes()) do
			local AArange = 525 + target.boundingRadius + myHero.boundingRadius 
		
			if LockedTarget and LockedTarget.dead then
				LockedTarget = nil 
				LastDist = 10000
			end
			
			if target and (LockedTarget == target or LockedTarget == nil) then
				LastDist = GetDistance(target.pos, myHero.pos)
			else
				if LastDist <= self.Menu.Misc.WDist:Value() and not LockedTarget.visible then
					Control.CastSpell(HK_W)
				end
				LockedTarget = nil 
				LastDist = 10000
				return 
			end
			
			if GetDistance(target.pos, myHero.pos) <= AArange then
				LockedTarget = target
			end
		end
	end
end	

function Quinn:Combo()
local target = GetTarget(1200)     	
if target == nil then return end
			
	if IsValid(target) then 
		local AState = myHero.attackData.state 
		local AArange = 525 + target.boundingRadius + myHero.boundingRadius 
		
		if HasBuff(target,"QuinnW") and self.Menu.Misc.Passive:Value() and myHero.pos:DistanceTo(target.pos) <= AArange then return end
		
		if self.Menu.Misc.NotQ_underR:Value() then
			if self.Menu.Combo.ComboQ:Value() and Ready(_Q) and not HasBuff(myHero,"QuinnR") then 
				local Qrange = 925 + target.boundingRadius + myHero.boundingRadius
				if myHero.pos:DistanceTo(target.pos) <= Qrange then 
					self:CastQ(target)
				end 
			end
		else
			if self.Menu.Combo.ComboQ:Value() and Ready(_Q) then 
				local Qrange = 925 + target.boundingRadius + myHero.boundingRadius
				if myHero.pos:DistanceTo(target.pos) <= Qrange then 
					self:CastQ(target)
				end 
			end		
		end
		
		if self.Menu.Misc.E_AAreset:Value() then
			if self.Menu.Combo.ComboE:Value() and Ready(_E) and AState == 3 then 
				local Erange = 675 + target.boundingRadius + myHero.boundingRadius
				if myHero.pos:DistanceTo(target.pos) <= Erange then 
					self:CastE(target)
				end 
			end
		else
			if self.Menu.Combo.ComboE:Value() and Ready(_E) then 
				local Erange = 675 + target.boundingRadius + myHero.boundingRadius
				if myHero.pos:DistanceTo(target.pos) <= Erange then 
					self:CastE(target)
				end 
			end		
		end	
	end 
end 

function Quinn:Harass()
local target = GetTarget(1100)     	
if target == nil then return end
	
	if IsValid(target) then 
		local AState = myHero.attackData.state 
		local AArange = 525 + target.boundingRadius + myHero.boundingRadius

		if HasBuff(target,"QuinnW") and self.Menu.Misc.Passive:Value() and myHero.pos:DistanceTo(target.pos) <= AArange then return end	
		
		if self.Menu.Misc.NotQ_underR:Value() then		
			if self.Menu.Harass.HarassQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value()/100 and Ready(_Q) and not HasBuff(myHero,"QuinnR") then 
				local Qrange = 925 + target.boundingRadius + myHero.boundingRadius
				if myHero.pos:DistanceTo(target.pos) <= Qrange then 
					self:CastQ(target)
				end 
			end
		else
			if self.Menu.Harass.HarassQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value()/100 and Ready(_Q) then 
				local Qrange = 925 + target.boundingRadius + myHero.boundingRadius
				if myHero.pos:DistanceTo(target.pos) <= Qrange then 
					self:CastQ(target)
				end 
			end		
		end
		
		if self.Menu.Misc.E_AAreset:Value() then		
			if self.Menu.Harass.HarassE:Value() and myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value()/100 and Ready(_E) and AState == 3 then 
				local Erange = 675 + target.boundingRadius + myHero.boundingRadius
				if myHero.pos:DistanceTo(target.pos) <= Erange then 
					self:CastE(target)
				end
			end
		else
			if self.Menu.Harass.HarassE:Value() and myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value()/100 and Ready(_E) then 
				local Erange = 675 + target.boundingRadius + myHero.boundingRadius
				if myHero.pos:DistanceTo(target.pos) <= Erange then 
					self:CastE(target)
				end
			end		
		end	
	end 
end

function Quinn:ProgPassive()
	local Count = GetEnemyCount(600, myHero)
	if Count == 0 and not HasBuff(myHero,"QuinnR") then	
		if MarkedMinion then
			Control.Attack(MarkedMinion)
			MarkedMinion = nil
			return
		else
			for i = 1, GameMinionCount() do
			local minion = GameMinion(i) 
				if GetDistance(minion.pos, myHero.pos) <= (525 + minion.boundingRadius + myHero.boundingRadius) and IsValid(minion) and (minion.team == TEAM_ENEMY or minion.team == TEAM_JUNGLE) and HasBuff(minion,"QuinnW") then
					MarkedMinion = minion
				end	
			end
		end	
	end	
end 

function Quinn:Clear()
	if self.Menu.Clear.ClearQ:Value() and Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.Clear.ClearMana:Value() / 100 then	
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)

			if myHero.pos:DistanceTo(minion.pos) < 1000 and minion.team == TEAM_ENEMY and IsValid(minion) then
				local Count = GetMinionCount(300, minion)
				if Count >= self.Menu.Clear.QCount:Value() then
					Control.CastSpell(HK_Q, minion.pos)					
				end					
			end
        end
    end
end

function Quinn:KillSteal()
	for i, target in ipairs(GetEnemyHeroes()) do
		if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1200 then 
			local QDmg 		= Ready(_Q) and getdmg("Q", target, myHero) or 0
			local EDmg 		= Ready(_E) and getdmg("E", target, myHero) or 0
			local RDmg   	= HasBuff(myHero, "QuinnR") and getdmg("R", target, myHero) or 0
			local AADmg  	= getdmg("AA", target, myHero)
			local Qrange 	= 925 + target.boundingRadius 
			local Erange 	= 675 + target.boundingRadius 
			local AArange 	= 525 + target.boundingRadius 
			
			if self.Menu.KS.Q_KS:Value() and myHero.pos:DistanceTo(target.pos) <= Qrange and QDmg > target.health then 
				self:CastQ(target)
			end 
			
			if self.Menu.KS.E_KS:Value() and myHero.pos:DistanceTo(target.pos) <= Erange and EDmg > target.health then 
				self:CastE(target)
			end
			
			if self.Menu.KS.R_KS:Value() then 
			
				if QDmg > 0 and EDmg > 0 and RDmg > 0 then
					if myHero.pos:DistanceTo(target.pos) <= Erange and (QDmg + EDmg + RDmg + (AADmg*4)) > target.health then
						self:CastE(target)
						DelayAction(function()
							self:CastQ(target)
						end,0.3)
					end
					
				elseif QDmg > 0 and EDmg > 0 then
					if myHero.pos:DistanceTo(target.pos) <= Erange and (QDmg + EDmg + (AADmg*4)) > target.health then
						self:CastE(target)
						DelayAction(function()
							self:CastQ(target)
						end,0.3)
					end
					
				elseif RDmg > 0 and EDmg > 0 then
					if myHero.pos:DistanceTo(target.pos) <= Erange and (RDmg + EDmg + (AADmg*4)) > target.health then
						self:CastE(target)
					end
					
				else
					if RDmg > 0 and QDmg > 0 then
						if myHero.pos:DistanceTo(target.pos) < AArange and (RDmg + QDmg + (AADmg*4)) > target.health then
							self:CastQ(target)
						end
					end	
				end	
			end   
		end 
	end  
end 
		
function Quinn:AntiGapCloser()
	for i, target in ipairs(GetEnemyHeroes()) do
		if self.Menu.Misc.AntiGap[target.networkID] and self.Menu.Misc.AntiGap[target.networkID]:Value() and myHero.pos:DistanceTo(target.pos) < 1000 then
            if target and Ready(_E) and target.pathing.isDashing and target.pathing.dashSpeed > 0 and GetDistanceSqr(target.pos) < 600*600 then	
				self:CastE(target)
			end
		end 
	end 
end

function Quinn:Flee()
	for i, target in ipairs(GetEnemyHeroes()) do
		
        if target and HasBuff(target,"QuinnW") then
			local AArangeT = 525 + target.boundingRadius + myHero.boundingRadius
			if GetDistanceSqr(target.pos) < AArangeT*AArangeT and IsValid(target) then
				Control.Attack(target)
			end
		else
			self:FleeMinion()	
		end 
	end 
end 

function Quinn:FleeMinion()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
		local AArangeM = 525 + minion.boundingRadius + myHero.boundingRadius
		if GetDistanceSqr(minion.pos) < AArangeM*AArangeM and IsValid(minion) and (minion.team == TEAM_ENEMY or minion.team == TEAM_JUNGLE) and HasBuff(minion,"QuinnW") then
			Control.Attack(minion)
		end
	end
end	

function Quinn:CastQ(unit)
	if Ready(_Q) then
		if self.Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, self.QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value()+1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end	
		if self.Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, self.QspellData)
			if pred.CastPos and ConvertToHitChance(self.Menu.Pred.PredQ:Value(), pred.HitChance) then
				Control.CastSpell(HK_Q, pred.CastPos)
			end
		end	
		if self.Menu.Pred.Change:Value() == 3 then
			self.QPrediction:GetPrediction(unit, myHero)			
			if self.QPrediction:CanHit(self.Menu.Pred.PredQ:Value() + 1) then
				Control.CastSpell(HK_Q, self.QPrediction.CastPosition)
			end	
		end
	end	
end

function Quinn:CastE(unit)
	Control.CastSpell(HK_E, unit)
end	

function Quinn:Draw()
if myHero.dead then return end 

	if self.Menu.Draw.DrawReady:Value() then 
		
		if Ready(_Q) and self.Menu.Draw.DrawQ:Value()then 
			DrawCircle(myHero, 1025, 1, DrawColor(255,96,203,67))
		end 
		
		if Ready(_W) and self.Menu.Draw.DrawW:Value()then 
			DrawCircle(myHero, 2100, 1, DrawColor(255,255,255,255))
		end 
		
		if Ready(_E) and self.Menu.Draw.DrawE:Value()then 
			DrawCircle(myHero, 675, 1, DrawColor(255,255,255,255))
		end 
		
	else
	
		if self.Menu.Draw.DrawQ:Value()then 
			DrawCircle(myHero, 1025, 1, DrawColor(255,96,203,67))
		end 
		
		if self.Menu.Draw.DrawW:Value()then 
			DrawCircle(myHero, 2100, 1, DrawColor(255,255,255,255))
		end 
		
		if self.Menu.Draw.DrawE:Value()then 
			DrawCircle(myHero, 675, 1, DrawColor(255,255,255,255))
		end  
	end
	
	if self.Menu.Draw.DrawTarget:Value()then 
		local target = GetTarget(925)     	
		if target then 
			DrawCircle(target, 80, 1, DrawColor(255,255,0,0))
		end 
	end 
end 

Callback.Add("Load", function()	
	if table.contains(Heroes, myHero.charName) then	
		_G[myHero.charName]()
		LoadUnits()	
	end	
end)
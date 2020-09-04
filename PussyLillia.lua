local Heroes = {"Lillia"}

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
    
    local Version = 0.04
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyLillia.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyLillia.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyLillia.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyLillia.version"
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
            print("New PussyLillia Version Press 2x F6")
        else
            print("PussyLillia loaded")
        end
    
    end
    
    AutoUpdate()

end 

----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

local heroes = false
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local foundAUnit = false
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
local Orb
local DrawRect = Draw.Rect
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local ControlSetCursorPos = Control.SetCursorPos
local ControlKeyUp = Control.KeyUp
local ControlKeyDown = Control.KeyDown
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

local function CheckLoadedEnemyies()
	local count = 0
	for i, unit in ipairs(Enemies) do
        if unit and unit.isEnemy then
		count = count + 1
		end
	end
	return count
end

local function GetEnemyHeroes()
	return Enemies
end

local function GetEnemyTurrets()
	return Turrets
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

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
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

local function GetBuffedEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) and HasBuff(hero, "LilliaPDoT") then
		count = count + 1
		end
	end
	return count
end

local function CalcDmg(unit)
	local total = 0
	local level = myHero.levelData.lvl
	
	if Ready(_Q) then
		local QDmg = CalcMagicalDamage(myHero, unit, (15 + 15 * level) + (0.4 * myHero.ap))
		local TrueDmg = (15 + 15 * level) + (0.4 * myHero.ap)		
		total = total + (QDmg + TrueDmg)
	end

	if Ready(_W) then
		local WDmg = CalcMagicalDamage(myHero, unit, (165 + 45 * level) + (0.9 * myHero.ap))		
		total = total + WDmg 
	end

	if Ready(_E) then
		local EDmg = CalcMagicalDamage(myHero, unit, (50 + 20 * level) + (0.4 * myHero.ap))		
		total = total + EDmg 
	end

	if Ready(_R) then
		local RDmg = CalcMagicalDamage(myHero, unit, (50 + 50 * level) + (0.3 * myHero.ap))		
		total = total + RDmg 
	end	
	return total
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

class "Lillia"


local WData = {Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 65, Range = 500, Speed = 1500, Collision = false}
local WspellData = {speed = 1500, range = 500, delay = 0.25, radius = 65, collision = {nil}, type = "circular"}

local EData = {Type = _G.SPELLTYPE_LINE, Delay = 0.4, Radius = 150, Range = 750, Speed = 1500, Collision = false}
local EspellData = {speed = 1500, range = 750, delay = 0.4, radius = 150, collision = {nil}, type = "linear"}

local PredLoaded = false

function Lillia:__init()
	self:LoadMenu()

	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
	end	

	if PredLoaded == false then
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

function Lillia:LoadMenu()                     	
--MainMenu
self.Menu = MenuElement({type = MENU, id = "PussyLillia", name = "PussyLillia"})
self.Menu:MenuElement({name = " ", drop = {"Version 0.04"}})

	--AutoQ
self.Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ Mode"})	
	self.Menu.AutoQ:MenuElement({name = " ", drop = {"Auto Q only if Combo not activated"}})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto Q Toggle Key", key = string.byte("T"), value = true, toggle = true})
	self.Menu.AutoQ:MenuElement({id = "QLogic", name = "[Q] Logic", value = 1, drop = {"Auto Q only outer range (TrueDmg)", "Auto Q always"}})

self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})
	
	--ComboMenu  
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "QLogic", name = "[Q] Logic", value = 1, drop = {"Q only outer range (TrueDmg)", "Q always"}})	
	self.Menu.ComboSet.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseE", name = "[E] only in Cast range", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "UseR", name = "[R]Single Target if killable", value = true})
	self.Menu.ComboSet.Combo:MenuElement({id = "UseRCount", name = "Auto[R] Multiple Enemys", value = true})	
	self.Menu.ComboSet.Combo:MenuElement({id = "RCount", name = "Multiple Enemys", value = 2, min = 2, max = 5, step = 1})
	self.Menu.ComboSet.Combo:MenuElement({id = "RRange", name = "Max search passive range for [R]", value = 1000, min = 0, max = 2000, step = 10})	
	


self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.ClearSet.Clear:MenuElement({id = "QCount", name = "min Minions for [Q]", value = 3, min = 1, max = 7, step = 1})	
	self.Menu.ClearSet.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.ClearSet.Clear:MenuElement({id = "WCount", name = "min Minions for [W]", value = 3, min = 1, max = 7, step = 1})			
	self.Menu.ClearSet.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseE", name = "[E]", value = true})		
	self.Menu.ClearSet.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})		

	
self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})

	self.Menu.MiscSet:MenuElement({type = MENU, id = "BlockAA", name = "Block AutoAttack"})
	self.Menu.MiscSet.BlockAA:MenuElement({name = " ", drop = {"BlockAA (Combo/AutoQ) if Q Ready or almost Ready"}})	
	self.Menu.MiscSet.BlockAA:MenuElement({id = "Block", name = "Toggle Key", key = string.byte("Z"), value = true, toggle = true})
							
	--Prediction
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.Menu.MiscSet.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	self.Menu.MiscSet.Drawing:MenuElement({id = "Draw_AutoQ", name = "Draw Auto Q indictator", value = true})
	self.Menu.MiscSet.Drawing:MenuElement({id = "Draw_BlockAA", name = "Draw Block AA indictator", value = true})	
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})		
end	

function Lillia:Tick()	
	if heroes == false then 
		local EnemyCount = CheckLoadedEnemyies()			
		if EnemyCount < 1 then
			LoadUnits()
		else
			heroes = true
		end
		
	else	

	if MyHeroNotReady() then return end

	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
			self:CountR()
		elseif Mode == "LaneClear" then
			self:JungleClear()
			self:Clear()	
		end

		if Mode ~= "Combo" and self.Menu.AutoQ.UseQ:Value() then
			self:AutoQ()
		end	
	end	
end

function Lillia:OnPreAttack(args)
	if self.Menu.MiscSet.BlockAA.Block:Value() then
		local Mode = GetMode()
		if ((Mode == "Combo" or self.Menu.AutoQ.UseQ:Value()) and (Ready(_Q) or myHero:GetSpellData(_Q).currentCd < 1.5)) then
			args.Process = false; return
		else
			args.Process = true;
		end
	end	
end

function Lillia:AutoQ()	
	for i, target in ipairs(GetEnemyHeroes()) do 		
		if target and myHero.pos:DistanceTo(target.pos) <= 475 and IsValid(target) and Ready(_Q) then			
			if self.Menu.AutoQ.QLogic:Value() == 1 then
				if myHero.pos:DistanceTo(target.pos) > (225+target.boundingRadius) then
					Control.CastSpell(HK_Q)
				end
			else
				Control.CastSpell(HK_Q)
			end
		end
	end
end

function Lillia:Combo()
local target = GetTarget(2000)     	
if target == nil then return end
	if IsValid(target) then

		if self.Menu.ComboSet.Combo.UseQ:Value() and Ready(_Q) then
			if self.Menu.ComboSet.Combo.QLogic:Value() == 1 then
				if myHero.pos:DistanceTo(target.pos) < 475 and myHero.pos:DistanceTo(target.pos) > (225+target.boundingRadius) then
					Control.CastSpell(HK_Q)
				end
			else
				if myHero.pos:DistanceTo(target.pos) < 475 then
					Control.CastSpell(HK_Q)
				end	
			end	
		end

		if self.Menu.ComboSet.Combo.UseW:Value() and Ready(_W) then	
			if myHero.pos:DistanceTo(target.pos) <= 500 then
				self:CastW(target)
			end
		end
		
		if self.Menu.ComboSet.Combo.UseE:Value() and Ready(_E) then	
			if myHero.pos:DistanceTo(target.pos) < 750 then
				self:CastE(target)
			end
		end	

		if self.Menu.ComboSet.Combo.UseR:Value() and Ready(_R) then	
			if myHero.pos:DistanceTo(target.pos) < 2000 then
				local FullDmg = CalcDmg(target)
				if FullDmg >= target.health then
					Control.CastSpell(HK_R)
				end	
			end
		end		
	end	
end	

function Lillia:CountR()
	for i, target in ipairs(GetEnemyHeroes()) do 		
		local CastRange = self.Menu.ComboSet.Combo.RRange:Value()
		if target and myHero.pos:DistanceTo(target.pos) <= CastRange and IsValid(target) and self.Menu.ComboSet.Combo.UseRCount:Value() and Ready(_R) then	
			local count = GetBuffedEnemyCount(CastRange, myHero)
			if count >= self.Menu.ComboSet.Combo.RCount:Value() then
				Control.CastSpell(HK_R)	
			end
		end	
	end
end		

function Lillia:JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_JUNGLE and IsValid(minion) then
 			
			if myHero.pos:DistanceTo(minion.pos) <= 500 and self.Menu.ClearSet.JClear.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 then
				Control.CastSpell(HK_W, minion.pos)                  
            end           
           
			if myHero.pos:DistanceTo(minion.pos) <= 750 and self.Menu.ClearSet.JClear.UseE:Value() and Ready(_E) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 then
				Control.CastSpell(HK_E, minion.pos)                  
            end			
			
			if myHero.pos:DistanceTo(minion.pos) <= 475 and self.Menu.ClearSet.JClear.UseQ:Value() and Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.JClear.Mana:Value() / 100 then
				Control.CastSpell(HK_Q)
			end	
        end
    end
end
			
function Lillia:Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if myHero.pos:DistanceTo(minion.pos) <= 500 and self.Menu.ClearSet.Clear.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
				local Count = GetMinionCount(500, minion)
				if Count >= self.Menu.ClearSet.Clear.WCount:Value() then
					Control.CastSpell(HK_W, minion.pos)
				end	
            end           		
			
			if myHero.pos:DistanceTo(minion.pos) <= 475 and self.Menu.ClearSet.Clear.UseQ:Value() and Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.ClearSet.Clear.Mana:Value() / 100 then
				local Count = GetMinionCount(475, minion)
				if Count >= self.Menu.ClearSet.Clear.QCount:Value() then				
					Control.CastSpell(HK_Q)
				end	
			end
        end
    end
end

function Lillia:CastW(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredW:Value()+1 then
			Control.CastSpell(HK_W, pred.CastPosition)
		end
	elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredW:Value(), pred.HitChance) then
			Control.CastSpell(HK_W, pred.CastPos)
		end
	else
		self:CastWGGPred(unit)	
	end
end

function Lillia:CastE(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, EData, myHero)
		if pred.Hitchance >= self.Menu.MiscSet.Pred.PredE:Value()+1 then
			Control.CastSpell(HK_E, pred.CastPosition)
		end
	elseif self.Menu.MiscSet.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), pred.HitChance) then
			Control.CastSpell(HK_E, pred.CastPos)
		end
	else
		self:CastEGGPred(unit)	
	end
end	

function Lillia:CastEGGPred(unit)
	local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.4, Radius = 150, Range = 750, Speed = 1500, Collision = false})
		  EPrediction:GetPrediction(unit, myHero)
	if EPrediction:CanHit(self.Menu.MiscSet.Pred.PredE:Value()+1) then
		Control.CastSpell(HK_E, EPrediction.CastPosition)
	end	
end
 
function Lillia:CastWGGPred(unit)
	local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 65, Range = 500, Speed = 1500, Collision = false})
		  WPrediction:GetPrediction(unit, myHero)
	if WPrediction:CanHit(self.Menu.MiscSet.Pred.PredW:Value()+1) then
		Control.CastSpell(HK_W, WPrediction.CastPosition)
	end	
end 
 
function Lillia:Draw()
	
	if heroes == false then
		Draw.Text(myHero.charName.." is Loading (Search Enemys) !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 255, 0, 0))
	else
		if DrawTime == false then
			Draw.Text(myHero.charName.." is Ready !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 0, 255, 0))
			DelayAction(function()
			DrawTime = true
			end, 4.0)
		end	
	end

	if myHero.dead then return end
	local posX, posY
	local mePos = myHero.pos:To2D()	
	
	if self.Menu.MiscSet.Drawing.Draw_AutoQ:Value() then

		posX = mePos.x - 50
		posY = mePos.y

		if self.Menu.AutoQ.UseQ:Value() then
			Draw.Text("Auto Q Enabled", (15), posX, posY, Draw.Color(240, 000, 255, 000))
		else
			Draw.Text("Auto Q Disabled", (15), posX, posY, Draw.Color(255, 255, 000, 000)) 
		end
	end
	
	if self.Menu.MiscSet.Drawing.Draw_BlockAA:Value() then	

		posX = mePos.x - 50
		posY = mePos.y + 16

		if self.Menu.MiscSet.BlockAA.Block:Value() then
			Draw.Text("Block AA Enabled", (15), posX, posY, Draw.Color(240, 000, 255, 000))
		else
			Draw.Text("Block AA Disabled", (15), posX, posY, Draw.Color(255, 255, 000, 000)) 
		end
	end	
	
	
	if self.Menu.MiscSet.Drawing.DrawR:Value() and Ready(_R) then
    DrawCircle(myHero, self.Menu.MiscSet.Rrange.R:Value(), 1, DrawColor(255, 225, 255, 10))
	end                                                 
	if self.Menu.MiscSet.Drawing.DrawQ:Value() and Ready(_Q) then
    DrawCircle(myHero, 485, 1, DrawColor(225, 225, 0, 10))
	end
	if self.Menu.MiscSet.Drawing.DrawE:Value() and Ready(_E) then
    DrawCircle(myHero, 700, 1, DrawColor(225, 225, 125, 10))
	end
	if self.Menu.MiscSet.Drawing.DrawW:Value() and Ready(_W) then
    DrawCircle(myHero, 500, 1, DrawColor(225, 225, 125, 10))
	end
end
	
Callback.Add("Load", function()	
	if table.contains(Heroes, myHero.charName) then	
		_G[myHero.charName]()
		LoadUnits()	
	end	
end)

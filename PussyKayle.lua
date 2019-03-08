if myHero.charName ~= "Kayle" then return end
class "Kayle"

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')

-- [ AutoUpdate ]

do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyKayle.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyKayle.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyKayle.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyKayle.version"
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
            print("New PussyKayle Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end




local menu = 1
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local Allies = {}; local Enemies = {}; local Turrets = {}; local Units = {}
local GameLatency = Game.Latency
local GameTimer = Game.Timer

function GunbladeDMG() 
    local level = myHero.levelData.lvl
    local damage = ({175,180,184,189,193,198,203,207,212,216,221,225,230,235,239,244,248,253})[level] + 0.30 * myHero.ap
	return damage
end


local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 195, Range = 850, Speed = 500, Collision = false
}

local EData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.34, Radius = 195, Range = 375, Speed = 500, Collision = false
}

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end


local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end 

local function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,Game.MinionCount() do
	local hero = Game.Minion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

function CanMove()
	if _G.SDK then
    return _G.SDK.Orbwalker:CanMove() 
	elseif _G.gsoSDK then
    return _G.gsoSDK.Orbwalker:CanMove()	
	end
end

function CanAttack()
	if _G.SDK then
		_G.SDK.Orbwalker:CanAttack()
	elseif _G.gsoSDK then
		_G.gsoSDK.Orbwalker:CanAttack()	
	end
end

function SetAttack(bool)
	if _G.EOWLoaded then
		EOW:SetAttacks(bool)
	elseif _G.SDK then                                                        
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.gsoSDK then
		_G.gsoSDK.Orbwalker:SetAttack(bool)	
	else
		GOS.BlockAttack = not bool
	end

end

function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then                                      
		_G.SDK.Orbwalker:SetMovement(bool)                  
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.gsoSDK then
		_G.gsoSDK.Orbwalker:SetMovement(bool)
		_G.gsoSDK.Orbwalker:SetAttack(bool)	
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end

end

function DisableOrb()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)
		end
end

function EnableOrb()
	if _G.SDK.TargetSelector:GetTarget(900) then
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)	
		end
end

function IsImmobileTarget(unit)
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10) and buff.count > 0 then
				return true
			end
		end
		return false	
end


	local function GetTarget(range) 
	local target = nil 
		if Orb == 1 then
			target = EOW:GetTarget(range)
		elseif Orb == 2 then 
			target = _G.SDK.TargetSelector:GetTarget(range)
		elseif Orb == 3 then
			target = GOS:GetTarget(range)
	    elseif Orb == 4 then
			target = _G.gsoSDK.TS:GetTarget()		
		end
		return target 
	end

	local intToMode = {
   		[0] = "",
   		[1] = "Combo",
   		[2] = "Harass",
   		[3] = "LastHit",
   		[4] = "Clear"
	}

	function GetMode()
		if Orb == 1 then
			return intToMode[EOW.CurrentMode]
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
		elseif Orb == 4 then
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
		else
			return GOS.GetMode()
		end
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


function GetDistanceSqr(p1, p2)
	if not p1 then return math.huge end
	p2 = p2 or myHero
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
end

function GetDistance(p1, p2)
	p2 = p2 or myHero
	return math.sqrt(GetDistanceSqr(p1, p2))
end

local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,
}

local function GetItemSlot(unit, id)
	for i = ITEM_1, ITEM_7 do
	    if unit:GetItemData(i).itemID == id then
		return i
	    end
	end
	return 0 
end

function Kayle:__init()

	if menu ~= 1 then return end
	menu = 2   	
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end) 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Kayle:EnemiesAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if (IsValid(hero) and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end

function Kayle:allysAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if (IsValid(hero) and hero.isAlly and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end

local function GetAllyHeroes()
    local _AllyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if IsValid(unit) and unit.isAlly then
            table.insert(_AllyHeroes, unit)
        end
    end
    return _AllyHeroes
end



function Kayle:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Kayle", name = "PussyKayle"})

	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "Auto Heal"})
	self.Menu.AutoW:MenuElement({id = "self", name = "Heal self", value = true})
	self.Menu.AutoW:MenuElement({id = "ally", name = "Heal Ally", value = true})
	self.Menu.AutoW:MenuElement({id = "HP", name = "HP Self/Ally", value = 50, min = 0, max = 100, step = 1, identifier = "%"})
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})			
	self.Menu.Combo:MenuElement({type = MENU, id = "UseR", name = "Ult Settings"})
	self.Menu.Combo.UseR:MenuElement({id = "self", name = "Ult self", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "ally", name = "Ult Ally", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "HP", name = "HP Self/Ally", value = 40, min = 0, max = 100, step = 1, identifier = "%"})	
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Lasthit Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "Lasthit[Q] Radiant Blast", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "Lasthit[E] Starfire Spellblade", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})		
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.ks:MenuElement({id = "gun", name = "Hextech Gunblade + [Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseIgn", name = "Ignite", value = true})

	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", name = "Activator"})		
	self.Menu.a:MenuElement({id = "gun", name = "Hextech Gunblade in ComboMode", value = true})	
	self.Menu.a:MenuElement({id = "HP", name = "Enemy %HP To Use Gunblade", value = 75, min = 0, max = 100, step = 5, identifier = "%"})

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Kayle:Tick()
	if myHero.dead == false and Game.IsChatOpen() == false then
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
			self:Gunblade()
		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		elseif Mode == "Flee" then
		
		end
		self:KillSteal()
		self:KillStealE()
		self:AutoW()
	
		end
	end	
	



function Kayle:ValidTarget(unit,range) 
	return unit and unit.team == TEAM_ENEMY and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false

end

local function IsValidCreep(unit, range)
    return unit and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false and unit.visible
end

function Kayle:AutoW()
local target = GetTarget(1200)     	
if target == nil then return end		
	if IsValid(target) then
		if self.Menu.AutoW.self:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= self.Menu.AutoW.HP:Value()/100 then
				Control.CastSpell(HK_W)
			end	
		end
		if self.Menu.AutoW.ally:Value() and Ready(_W) then		
			for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
				if IsValid(unit) and unit.isAlly then
				local Hp = GetPercentHP(unit)
						if Hp <= self.Menu.AutoW.HP:Value() and myHero.pos:DistanceTo(unit.pos) <= 900 then
							Control.CastSpell(HK_W, unit)	
						end	
					end
				end
			end
		end	
	end	


function Kayle:Gunblade()
	local target = GetTarget(1000)     	
	if target == nil then return end
	local Gun = GetItemSlot(myHero, 3146)		
	if IsValid(target) then	
		if self.Menu.a.gun:Value() and Gun > 0 and Ready(Gun) then
			if target.health/target.maxHealth <= self.Menu.a.HP:Value()/100 and myHero.pos:DistanceTo(target.pos) <= 700 then
				Control.CastSpell(ItemHotKey[Gun], target.pos)
			end
		end
	end
end
	
			


function Kayle:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 500, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 850, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 900, 1, Draw.Color(225, 225, 125, 10))
	end
end

function Kayle:KillStealE()	
	local target = GetTarget(600)     	
	if target == nil then return end
	local level = myHero.levelData.lvl
	local hp = target.health
	local EDmg = getdmg("E", target, myHero, 1)
	local E2Dmg = getdmg("E", target, myHero, 2)
	local E3Dmg = getdmg("E", target, myHero, 2) + getdmg("E", target, myHero, 3)
	if IsValid(target) then	
		
		if self.Menu.ks.UseE:Value() and Ready(_E) then
			if level >= 1 and level < 6 and EDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 550 then
				Control.CastSpell(HK_E)
		
			
			elseif level >= 6 and level < 16 and E2Dmg >= hp and myHero.pos:DistanceTo(target.pos) <= 550 then
				Control.CastSpell(HK_E)
				
			elseif level >= 16 and E3Dmg >= hp and myHero.pos:DistanceTo(target.pos) <= 550 then
				Control.CastSpell(HK_E)				
			end			
		end	
	end
end	
       


function Kayle:KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end
	local hp = target.health
	local QDmg = getdmg("Q", target, myHero)
	local IGdamage = 80 + 25 * myHero.levelData.lvl
	local GunDmg = GunbladeDMG()
	if IsValid(target) then	
		
		if self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 850 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end

		if self.Menu.ks.UseIgn:Value() then 
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and myHero.pos:DistanceTo(target.pos) <= 600 then
				if Ready(SUMMONER_1) then
					if IGdamage >= hp + target.hpRegen * 3 then
						Control.CastSpell(HK_SUMMONER_1, target)
					end
				end
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and myHero.pos:DistanceTo(target.pos) <= 600  then
				if Ready(SUMMONER_2) then
					if IGdamage >= hp + target.hpRegen * 3 then
						Control.CastSpell(HK_SUMMONER_2, target)
					end
				end
			end
		end
		local Gun = GetItemSlot(myHero, 3146)
		if self.Menu.ks.gun:Value() and Ready(_Q) and Gun > 0 and Ready(Gun) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if (QDmg + GunDmg) >= hp and myHero.pos:DistanceTo(target.pos) <= 700 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(ItemHotKey[Gun], target.pos)
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end	


function Kayle:Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then
			
		
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 850 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if self.Menu.Combo.UseE:Value() and Ready(_E) then			
			if myHero.pos:DistanceTo(target.pos) <= 400 then			
				Control.CastSpell(HK_E)
	
			end
		end
		
		if Ready(_R) and self.Menu.Combo.UseR.self:Value() then
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.UseR.HP:Value()/100 then 
				Control.CastSpell(HK_R, myHero)
			end
		end
		if Ready(_R) and self.Menu.Combo.UseR.ally:Value() then
			for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
				if IsValid(unit) and unit.isAlly then
				local enemy = self:EnemiesAround(unit.pos, 650)			
					if enemy >= 1 and unit.health/unit.maxHealth <= self.Menu.Combo.UseR.HP:Value()/100 and myHero.pos:DistanceTo(unit.pos) <= 900  then
						Control.CastSpell(HK_R, unit)
					end
				end
			end	
		end
	end	
end	





function Kayle:Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 850 and pred.Hitchance >= _G.HITCHANCE_HIGH then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
		
			if myHero.pos:DistanceTo(target.pos) <= 400 then			
				Control.CastSpell(HK_E)
	
			end
		end
	end
end	




function Kayle:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local level = myHero.levelData.lvl
	local HP = minion.health
	local QDmg = getdmg("Q", minion, myHero)	
	local EDmg = getdmg("E", minion, myHero, 1)
	local E2Dmg = getdmg("E", minion, myHero, 2)
	local E3Dmg = getdmg("E", minion, myHero, 2) + getdmg("E", minion, myHero, 3)
		
		if IsValidCreep(minion, 1000) and minion.team == TEAM_ENEMY and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then					
			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 500 and self.Menu.Clear.UseE:Value() then
				if level >= 1 and level < 6 and EDmg > HP then
					Control.CastSpell(HK_E)
				
				elseif level >= 6 and level < 16 and E2Dmg > HP then
					Control.CastSpell(HK_E)
					
				elseif level >= 16 and E3Dmg > HP then
					Control.CastSpell(HK_E)	
				end
			end
			
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 850 and self.Menu.Clear.UseQ:Value() and QDmg > HP then
				Control.CastSpell(HK_Q, minion.pos)
			end	 
		end
	end
end

function Kayle:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
			
		if IsValidCreep(minion, 1000) and minion.team == TEAM_JUNGLE and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 850 and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end
			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 550 and self.Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E)
			end		
		end
	end
end

------------------------------------------------------------------------------------------------------------

--Dmg Lib



local DamageReductionTable = {
  ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level] end},
  ["Urgot"] = {buff = "urgotswapdef", amount = function(target) return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level] end},
  ["Alistar"] = {buff = "Ferocious Howl", amount = function(target) return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level] end},
  ["Amumu"] = {buff = "Tantrum", amount = function(target) return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level] end, damageType = 1},
  ["Galio"] = {buff = "GalioIdolOfDurand", amount = function(target) return 0.5 end},
  ["Garen"] = {buff = "GarenW", amount = function(target) return 0.7 end},
  ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level] end},
  ["Annie"] = {buff = "MoltenShield", amount = function(target) return 1 - ({0.16,0.22,0.28,0.34,0.4})[target:GetSpellData(_E).level] end},
  ["Kayle"] = {buff = "Kaylepassiveshield", amount = function(target) return 0.1 end}
}

function GetPercentHP(unit)
  return 100 * unit.health / unit.maxHealth
end

function string.ends(String,End)
  return End == "" or string.sub(String,-string.len(End)) == End
end

function GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0
end

function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff.count
    end
  end
  return 0
end

function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function CalcPhysicalDamage(source, target, amount)
  local ArmorPenPercent = source.armorPenPercent
  local ArmorPenFlat = (0.4 + target.levelData.lvl / 30) * source.armorPen
  local BonusArmorPen = source.bonusArmorPenPercent

  if source.type == Obj_AI_Minion then
    ArmorPenPercent = 1
    ArmorPenFlat = 0
    BonusArmorPen = 1
  elseif source.type == Obj_AI_Turret then
    ArmorPenFlat = 0
    BonusArmorPen = 1
    if source.charName:find("3") or source.charName:find("4") then
      ArmorPenPercent = 0.25
    else
      ArmorPenPercent = 0.7
    end
  end

  if source.type == Obj_AI_Turret then
    if target.type == Obj_AI_Minion then
      amount = amount * 1.25
      if string.ends(target.charName, "MinionSiege") then
        amount = amount * 0.7
      end
      return amount
    end
  end

  local armor = target.armor
  local bonusArmor = target.bonusArmor
  local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)

  if armor < 0 then
    value = 2 - 100 / (100 - armor)
  elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 1)))
end

function CalcMagicalDamage(source, target, amount)
  local mr = target.magicResist
  local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)

  if mr < 0 then
    value = 2 - 100 / (100 - mr)
  elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 2)))
end

function DamageReductionMod(source,target,amount,DamageType)
  if source.type == Obj_AI_Hero then
    if GotBuff(source, "Exhaust") > 0 then
      amount = amount * 0.6
    end
  end

  if target.type == Obj_AI_Hero then

    for i = 0, target.buffCount do
      if target:GetBuff(i).count > 0 then
        local buff = target:GetBuff(i)
        if buff.name == "MasteryWardenOfTheDawn" then
          amount = amount * (1 - (0.06 * buff.count))
        end
    
        if DamageReductionTable[target.charName] then
          if buff.name == DamageReductionTable[target.charName].buff and (not DamageReductionTable[target.charName].damagetype or DamageReductionTable[target.charName].damagetype == DamageType) then
            amount = amount * DamageReductionTable[target.charName].amount(target)
          end
        end

        if target.charName == "Maokai" and source.type ~= Obj_AI_Turret then
          if buff.name == "MaokaiDrainDefense" then
            amount = amount * 0.8
          end
        end

        if target.charName == "MasterYi" then
          if buff.name == "Meditate" then
            amount = amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpellData(_W).level] / (source.type == Obj_AI_Turret and 2 or 1)
          end
        end
      end
    end

    if GetItemSlot(target, 1054) > 0 then
      amount = amount - 8
    end

    if target.charName == "Kassadin" and DamageType == 2 then
      amount = amount * 0.85
    end
  end

  return amount
end

function PassivePercentMod(source, target, amount, damageType)
  local SiegeMinionList = {"Red_Minion_MechCannon", "Blue_Minion_MechCannon"}
  local NormalMinionList = {"Red_Minion_Wizard", "Blue_Minion_Wizard", "Red_Minion_Basic", "Blue_Minion_Basic"}

  if source.type == Obj_AI_Turret then
    if table.contains(SiegeMinionList, target.charName) then
      amount = amount * 0.7
    elseif table.contains(NormalMinionList, target.charName) then
      amount = amount * 1.14285714285714
    end
  end
  if source.type == Obj_AI_Hero then 
    if target.type == Obj_AI_Hero then
      if (GetItemSlot(source, 3036) > 0 or GetItemSlot(source, 3034) > 0) and source.maxHealth < target.maxHealth and damageType == 1 then
        amount = amount * (1 + math.min(target.maxHealth - source.maxHealth, 500) / 50 * (GetItemSlot(source, 3036) > 0 and 0.015 or 0.01))
      end
    end
  end
  return amount
end

function WLvLDMG()
    total = 0
	local Lvl = myHero.levelData.lvl
    if Lvl > 0 then
	local damage = (1.5) + (3.5 * Lvl) 
	total = damage 
	end
	return total
end

local QLvL = WLvLDMG()

local DamageLibTable = {

  ["Kayle"] = {  
	{Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({70, 115, 160, 205, 250})[level] + 0.5 * source.ap + 0.6 * source.bonusDamage end},
	{Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({10, 15, 20, 25, 30})[level] + 0.2 * source.ap + 0.1 * source.totalDamage + source.totalDamage + ({10, 12, 15, 17, 20})[level] / 100 * (target.maxHealth - target.health) end},   
	{Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return (({10, 15, 20, 25, 30})[level] + 0.2 * source.ap + 0.1 * source.totalDamage + source.totalDamage +({10, 12, 15, 17, 20})[level] / 100 * (target.maxHealth - target.health)) + ({10, 15, 20, 25, 30})[level] + 0.2 * source.ap + 0.1 * source.totalDamage  end},	
	{Slot = "E", Stage = 3, DamageType = 3, Damage = function(source, target, level) return ({10, 15, 20, 25, 30})[level] + 0.2 * source.ap + 0.1 * source.totalDamage end},	
	{Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({200, 350, 500})[level] + 0.8 * source.ap + source.bonusDamage  end},

  }
}


function getdmg(spell,target,source,stage,level)
  local source = source or myHero
  local stage = stage or 1
  local swagtable = {}
  local k = 0
  if stage > 4 then stage = 4 end
  if spell == "Q" or spell == "W" or spell == "E" or spell == "R" or spell == "QM" or spell == "WM" or spell == "EM" then
    local level = level or source:GetSpellData(({["Q"] = _Q, ["QM"] = _Q, ["W"] = _W, ["WM"] = _W, ["E"] = _E, ["EM"] = _E, ["R"] = _R})[spell]).level
    if level <= 0 then return 0 end
    if level > 5 then level = 5 end
    if DamageLibTable[source.charName] then
      for i, spells in pairs(DamageLibTable[source.charName]) do
        if spells.Slot == spell then
          table.insert(swagtable, spells)
        end
      end
      if stage > #swagtable then stage = #swagtable end
      for v = #swagtable, 1, -1 do
        local spells = swagtable[v]
        if spells.Stage == stage then
          if spells.DamageType == 1 then
            return CalcPhysicalDamage(source, target, spells.Damage(source, target, level))
          elseif spells.DamageType == 2 then
            return CalcMagicalDamage(source, target, spells.Damage(source, target, level))
          elseif spells.DamageType == 3 then
            return spells.Damage(source, target, level)
          end
        end
      end
    end
  end
  if spell == "AA" then
    return CalcPhysicalDamage(source, target, source.totalDamage)
  end
  if spell == "IGNITE" then
    return 50+20*source.levelData.lvl - (target.hpRegen*3)
  end
  if spell == "SMITE" then
    if Smite then
      if target.type == Obj_AI_Hero then
        if source:GetSpellData(Smite).name == "s5_summonersmiteplayerganker" then
          return 20+8*source.levelData.lvl
        end
        if source:GetSpellData(Smite).name == "s5_summonersmiteduel" then
          return 54+6*source.levelData.lvl
        end
      end
      return ({390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000})[source.levelData.lvl]
    end
  end
  if spell == "BILGEWATER" then
    return CalcMagicalDamage(source, target, 100)
  end
  if spell == "BOTRK" then
    return CalcPhysicalDamage(source, target, target.maxHealth*0.1)
  end
  if spell == "HEXTECH" then
    return CalcMagicalDamage(source, target, 150+0.4*source.ap)
  end
  return 0
end

function OnLoad()
	Kayle()

end
	
  

















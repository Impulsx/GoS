local Heroes = {"Yuumi"}

if not table.contains(Heroes, myHero.charName) then return end

-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "YuumiBot.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/YuumiBot.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "YuumiBot.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/YuumiBot.version"
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
            print("New YuumiBot Version Press 2x F6")
        else
            print("YuumiBot loaded")
        end
    
    end
    
    AutoUpdate()

end

----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------


local Latency = Game.Latency
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local l,o,a,d,i,n,g = false,false,false,false,false,false,false
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6,}
local sqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local GameTimer = Game.Timer
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local Orb
local DrawColor = Draw.Color
local DrawText = Draw.Text
local ControlCastSpell = Control.CastSpell
local ControlSetCursorPos = Control.SetCursorPos
local ControlKeyUp = Control.KeyUp
local ControlKeyDown = Control.KeyDown
local GameCanUseSpell = Game.CanUseSpell
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
--local GameMinionCount = Game.MinionCount
--local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
--local GameIsChatOpen = Game.IsChatOpen
local AllySide = nil
local EnemySide = nil
local StartPoint = nil
local EnemyStartPoint = nil
local Next = false 
local buystate = 0 
local currenthave = 0
local buystance = false
local Items = {}
local gold = 0
local TowerHit = false
local Redempt = false

local ItemList = {} 
ItemList[#ItemList+1] = {"spellth",3850,400,nil} 	--- Spellthiefs Edge
ItemList[#ItemList+1] = {"chalice",3028,800,5} 		--- Chalice of Harmony
ItemList[#ItemList+1] = {"dark",1082,350,5}			--- Dark Seal
ItemList[#ItemList+1] = {"fiendish",3108,900,5}		--- Fiendish Codex
ItemList[#ItemList+1] = {"athen",3174,400,nil} 		--- Athenes Unholy Grail
ItemList[#ItemList+1] = {"forbidden",3114,800,7}	--- Forbidden Idol
ItemList[#ItemList+1] = {"aether",3113,850,7}		--- Aether Wisp
ItemList[#ItemList+1] = {"ardent",3504,650,nil}	  	--- Ardent Censer
ItemList[#ItemList+1] = {"chalice",3028,800,9} 		--- Chalice of Harmony
ItemList[#ItemList+1] = {"mejai",3041,1050,nil}		--- Mejais Soulstealer
ItemList[#ItemList+1] = {"mikael",3222,1300,nil}	--- Mikaels Crucible
ItemList[#ItemList+1] = {"redem",3107,2100,nil}		--- Redemption

----------------------------------------------------
--|               ////////////              	 |--
----------------------------------------------------

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

local function GetEnemyTurret()
	local _EnemyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        if turret.isEnemy and not turret.dead then
			TableInsert(_EnemyTurrets, turret)
		end
	end
	return _EnemyTurrets		
end

local function GetAllyTurret()
	local _AllyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        if turret.isAlly and not turret.dead then
			TableInsert(_AllyTurrets, turret)
		end
	end
	return _AllyTurrets		
end

----------------------------------------------------
--|               ////////////              	 |--
----------------------------------------------------

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end

local function isReady(spell)
    return GameCanUseSpell(spell) == 0
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

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
local function GetInventorySlotItem(itemID)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
    for _, j in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}) do
        if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
    end
    return nil
end

local function t( cond , T , F )
    if cond then return T else return F end
end

----------------------------------------------------
--|               ////////////              	 |--
----------------------------------------------------

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
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

local function BuffCheck()
	for i, Ally in pairs(GetAllyHeroes()) do
		if HasBuff(Ally, "YuumiWAlly") then
			return true
		end
	end
	return false
end

local CleanBuffs =
{
    [5] = true,
    [7] = true,
    [8] = true,
	[9] = true,
	[10] = true,
	[11] = true,
	[20] = true,
    [21] = true,
    [22] = true,
	[24] = true,
    [25] = true,
	[28] = true,
    [31] = true,
    [34] = true 
}

local function Cleans(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff then
            local bCount = buff.count;
            local bType = buff.type;
            if (bCount and bType and bCount > 0 and CleanBuffs[bType]) then
                return true
            end
        end
    end
    return false
end

local function IsRecalling(unit)
	for i = 1, 63 do
	local buff = unit:GetBuff(i) 
		if buff.count > 0 and buff.name == "recall" and GameTimer() < buff.expireTime then
			return true
		end
	end 
	return false
end

----------------------------------------------------
--|               ////////////              	 |--
---------------------------------------------------- 

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in pairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function GetAllyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in pairs(GetAllyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

local function GetLowAllyCount(range, pos)
    local pos = pos.pos
	local count = 1
	for i, hero in pairs(GetAllyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) and hero.health/hero.maxHealth <= 0.5 then
		count = count + 1
		end
	end
	return count
end

local function NearestAlly(pos,range)
	local near = nil
	for i, Hero in pairs(GetAllyHeroes()) do
		if IsValid(Hero) and pos:DistanceTo(Hero.pos) < range and (not near or near and pos:DistanceTo(Hero.pos) < pos:DistanceTo(near.pos)) then
			near = Hero
		end
	end
	return near
end

local function NearestTower(pos,range)
	local near = nil
	for i, turret in pairs(GetAllyTurret()) do
		if pos:DistanceTo(turret.pos) < range and (not near or near and pos:DistanceTo(turret.pos) < pos:DistanceTo(near.pos)) then
			near = turret
		end
	end
	return near
end

local function GetImmobileCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in pairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsImmobileTarget(hero) then
		count = count + 1
		end
	end
	return count
end

local function IsUnderTurret(unit)
	for i, turret in pairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.pos:DistanceTo(unit.pos) < range then
			return true
        end
    end
    return false
end 

----------------------------------------------------
--|               ////////////              	 |--
----------------------------------------------------

local BuyDistanceToStart = 1000
local function IsInBuyDistance()
	return StartPoint:DistanceTo(myHero.pos) < BuyDistanceToStart or myHero.dead
end

local function BaseCheck()
	if IsInBuyDistance() then 
		if (myHero.health < myHero.maxHealth or myHero.mana < myHero.maxMana) or buystance then
			return true
		end	
	end
	return false
end	

local function ClickMM(pos,range,delay)
	local range = range or MathHuge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Latency() then
			local castPosMM = pos:ToMM()
			ControlSetCursorPos(castPosMM.x,castPosMM.y)
			Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
			Control.mouse_event(MOUSEEVENTF_RIGHTUP)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					ControlSetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Latency()/1000)
		end
		if ticker - castSpell.casting > Latency() then
			ControlSetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

local function CastSpellMM(spell,pos,range,delay)
local range = range or MathHuge
local delay = delay or 250
local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Latency() then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x,castPosMM.y)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Latency()/1000)
		end
		if ticker - castSpell.casting > Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Yuumi"



function Yuumi:__init()
	self.levelUP = false
	Items = ItemList
	AllySide = t(myHero.team == 100, "Blue", "Red")
	EnemySide = t(myHero.team == 200, "Blue", "Red")
	StartPoint = t(AllySide == "Blue", Vector(105,33,134), Vector(14576,466,14693))
	EnemyStartPoint = t(AllySide == "Red", Vector(105,33,134), Vector(14576,466,14693))
 	
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)	
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	elseif _G.PremiumOrbwalker then
		Orb = 5		
	end
end

function Yuumi:LoadMenu()                     
	
	self.Menu = MenuElement({type = MENU, id = "YuumiBot", name = "Pussy YuumiBot"})
	self.Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
	
	self.Menu:MenuElement({type = MENU, id = "start", name = "Bot On/Off"})
	self.Menu.start:MenuElement({id = "On", name = "Bot On/Off", key = string.byte("T"), toggle = true})
	
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "[W] + [E] Settings"})
	self.Menu.AutoE:MenuElement({id = "UseEself", name = "[E]Auto Heal self", value = true})
	self.Menu.AutoE:MenuElement({id = "myHP", name = "MinHP Self to Heal", value = 80, min = 0, max = 100, identifier = "%"})
	self.Menu.AutoE:MenuElement({id = "MainHP", name = "Heal if Main Ally Hp lower than -->", value = 75, min = 0, max = 100, identifier = "%"})	
	self.Menu.AutoE:MenuElement({id = "AllyHP", name = "Heal if Other Ally Hp lower than -->", value = 70, min = 0, max = 100, identifier = "%"})	
	
	self.Menu:MenuElement({type = MENU, id = "AutoR", name = "Ultimate Settings"})
	self.Menu.AutoR:MenuElement({id = "UseRE", name = "Use[R] min Immobile Targets", value = 1, min = 1, max = 5})	
	self.Menu.AutoR:MenuElement({id = "UseRM", name = "Use[R] min Targets", value = 3, min = 1, max = 5})		
	
	self.Menu:MenuElement({type = MENU, id = "summ", name = "Summoner Spells"})	
    self.Menu.summ:MenuElement({type = MENU, id = "ex", name = "Exhaust"})
    self.Menu.summ.ex:MenuElement({id = "target", name = "Use Exhaust", value = true})
    self.Menu.summ.ex:MenuElement({id = "hp", name = "Target HP:", value = 20, min = 5, max = 95, identifier = "%"})
    self.Menu.summ:MenuElement({type = MENU, id = "ign", name = "Ignite"})
 	self.Menu.summ.ign:MenuElement({id = "ST", name = "TargetHP or KillSteal", drop = {"TargetHP", "KillSteal"}, value = 1})   
    self.Menu.summ.ign:MenuElement({id = "hp", name = "TargetHP:", value = 20, min = 5, max = 95, identifier = "%"})

	self.Menu:MenuElement({type = MENU, id = "item", name = "Redemption Settings"})	
    self.Menu.item:MenuElement({id = "hp", name = "SingleAlly HP lower than -->", value = 30, min = 5, max = 100, identifier = "%"})  
	self.Menu.item:MenuElement({id = "min", name = "min Allies under 50% in Radius", value = 2, min = 2, max = 5})	

	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "InfoText Position"})	
	self.Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	self.Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	
	
end

function Yuumi:Tick()
local count = GetAllyCount(20000, myHero)
	if count == 0 then
		LoadUnits()
		
		if l then
			DelayAction(function()
				l = false
			end,1)
		end					
		if not l then
			DelayAction(function()
				o = true
			end,0.1)
		end
		if o then
			DelayAction(function()
				a = true
			end,0.1)
		end
		if a then
			DelayAction(function()
				d = true
			end,0.1)
		end
		if d then
			DelayAction(function()
				i = true
			end,0.1)
		end
		if i then
			DelayAction(function()
				n = true
			end,0.1)
		end
		if n then
			DelayAction(function()
				g = true
			end,0.1)
		end
		if g then	
			DelayAction(function()
				l = true o = false a = false d = false i = false n = false g = false
			end,1)		
		end		
	end	
	
	if count > 0 and self.Menu.start.On:Value() then
		self:SetBuyStance()
		if buystate == 6 then
			buystate = 0
		end

		if BaseCheck() then	
			if BuffCheck() then
				ControlCastSpell(HK_W)
			else
				DelayAction(function()
					self:CheckBuy()
				end,1)
			end
		end
		
		if not BaseCheck() then
			--self:HitTower()	
			self:Redemption()
			if Redempt then return end
			self:SearchMain()
			self:AutoE()
			self:AutoR()
			self:Summoner()
			self:LvlUp()
			self:Mikaels()			
		end
	end
end 


----------------------------------------------------
--|           Spells and other stuff             |--
----------------------------------------------------

function Yuumi:Draw()
	DrawText("Bot: ", 15, self.Menu.Drawing.XY.x:Value(), self.Menu.Drawing.XY.y:Value()+15, DrawColor(255, 225, 255, 0))
	if self.Menu.start.On:Value() then 
		DrawText("ON", 15, self.Menu.Drawing.XY.x:Value()+74, self.Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
	else
		DrawText("OFF", 15, self.Menu.Drawing.XY.x:Value()+74, self.Menu.Drawing.XY.y:Value()+15, DrawColor(255, 255, 0, 0)) 
	end
	for i, Ally in pairs(GetAllyHeroes()) do
		local bestAlly = Yuumi:MainAlly()
		DrawText("Main Ally: ", 15, self.Menu.Drawing.XY.x:Value(), self.Menu.Drawing.XY.y:Value()+30, DrawColor(255, 225, 255, 0))
		DrawText("Status: ", 15, self.Menu.Drawing.XY.x:Value(), self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 225, 255, 0))	
		if bestAlly then
			DrawText("".. bestAlly.charName, 15, self.Menu.Drawing.XY.x:Value()+74, self.Menu.Drawing.XY.y:Value()+30, DrawColor(255, 0, 255, 0))
			DrawText("Ready", 15, self.Menu.Drawing.XY.x:Value()+74, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 0, 255, 0))		
		else		
			if Ally and not bestAlly then return end
			if not l then
				DrawText("L", 15, self.Menu.Drawing.XY.x:Value()+74, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 255, 0, 0))
			end
			if o then
				DrawText(" o", 15, self.Menu.Drawing.XY.x:Value()+75, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 255, 0, 0))
			end
			if a then
				DrawText("  a", 15, self.Menu.Drawing.XY.x:Value()+78, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 255, 0, 0))
			end
			if d then
				DrawText("   d", 15, self.Menu.Drawing.XY.x:Value()+81, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 255, 0, 0))
			end
			if i then
				DrawText("    i", 15, self.Menu.Drawing.XY.x:Value()+84, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 255, 0, 0))
			end
			if n then
				DrawText("     n", 15, self.Menu.Drawing.XY.x:Value()+85, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 255, 0, 0))
			end
			if g then
				DrawText("      g", 15, self.Menu.Drawing.XY.x:Value()+88, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 255, 0, 0))			
			end
		end
		if Ally and not bestAlly then
			local NextAlly = NearestAlly(myHero.pos, 30000)
			DrawText("".. NextAlly.charName, 15, self.Menu.Drawing.XY.x:Value()+74, self.Menu.Drawing.XY.y:Value()+30, DrawColor(255, 0, 255, 0))
			DrawText("Ready", 15, self.Menu.Drawing.XY.x:Value()+74, self.Menu.Drawing.XY.y:Value()+45, DrawColor(255, 0, 255, 0))
		end	
	end	
end

function Yuumi:LvlUp()
	if not self.levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts
		
		if levelPoints == 0 or not BuffCheck() then return end
		
		if levelPoints > 0 then
		 	
			skillingOrder = {'Q','E','Q','E','Q','R','Q','E','Q','E','R','Q','E','W','W','R','W','W'}				

			local QL, WL, EL, RL = 0, 1, 0, 0

			for i = 1, actualLevel do
				if skillingOrder[i] == "Q" then 		
					QL = QL + 1
				elseif skillingOrder[i] == "W" then		
					WL = WL + 1
				elseif skillingOrder[i] == "E" then 	
					EL = EL + 1
				elseif skillingOrder[i] == "R" then		
					RL = RL + 1
				end
			end

			local diffR = myHero:GetSpellData(_R).level - RL < 0
			local lowest = 99
			local spell 
			local lowHK_Q = myHero:GetSpellData(_Q).level - QL
			local lowHK_W = myHero:GetSpellData(_W).level - WL
			local lowHK_E = myHero:GetSpellData(_E).level - EL

			if lowHK_Q < lowest then
				lowest = lowHK_Q
				spell = HK_Q
			end

			if lowHK_W < lowest then
				lowest = lowHK_W
				spell = HK_W
			end

			if lowHK_E < lowest then
				lowest = lowHK_E
				spell = HK_E
			end

			if diffR then
				spell = HK_R
			end
			
			if spell then
				
				self.levelUP = true
				
				DelayAction(function()
					ControlKeyDown(17)
					ControlKeyDown(spell)
					ControlKeyUp(spell)
					ControlKeyUp(17)

					DelayAction(function()
						if Control.IsKeyDown(spell) or Control.IsKeyDown(17) then
							if Control.IsKeyDown(spell) then	
								ControlKeyUp(spell)
							end								
							if Control.IsKeyDown(17) then
								ControlKeyUp(17)								
							end
							DelayAction(function()
								self.levelUP = false
							end,0.5)	
						else
							self.levelUP = false
						end	
					end, 0.25)
				end, 0.7)
			end
		end
	end
end

function Yuumi:MainAlly()
local Allys = GetAllyHeroes()
local bestAlly, highest = nil, 0

	for i = 1, #Allys do
		local ally = Allys[i]
		if ally.range >= 500 then
			local amount = ally.totalDamage
			if amount > highest then
				highest = amount
				bestAlly = ally
			end
		end	
	end
	return bestAlly
end

function Yuumi:LowestAlly()
local Allys = GetAllyHeroes()
local LowAlly, highest = nil, 1.0

	for i = 1, #Allys do
		local ally = Allys[i]
		local amount = ally.health/ally.maxHealth
		if ally.pos:DistanceTo(myHero.pos) < 700 and amount < highest then
			highest = amount
			LowAlly = ally
		end	
	end
	return LowAlly
end
--[[
function Yuumi:HitTower()     	
if GetEnemyCount(2000, myHero) > 0 then 
	if TowerHit then
		TowerHit = false
	end	
return end
	for i, Ally in pairs(GetAllyHeroes()) do
		local spell = myHero:GetSpellData(_W)
		local turret = GetEnemyTurret()
		if Ally and HasBuff(Ally, "YuumiWAlly") and Ready(_W) then 			
				
			if IsUnderTurret(Ally) and spell.name ~= "YuumiW" then
				TowerHit = true
				ControlCastSpell(HK_W)
				
			end	
		end
		
		if spell.name == "YuumiW" then
			ControlCastSpell(HK_Q, turret.pos)
		end	
		
		if myHero.pos:DistanceTo(Ally.pos) <= 2000 and not IsUnderTurret(Ally) then
			TowerHit = false
		end	
	end	
end	
]]
function Yuumi:SearchMain()	
	local bestAlly = self:MainAlly()	
	local ready = true
	if not Ready(_W) then
		self:NextTower()
	end	
	
	if bestAlly and IsValid(bestAlly) then
		if not HasBuff(bestAlly, "YuumiWAlly") and Ready(_W) and ready then
			if myHero.pos:DistanceTo(bestAlly.pos) > 700 then
				local spell = myHero:GetSpellData(_W)
				if spell.name == "YuumiW" then
					local pos = bestAlly.pos
					ClickMM(pos,20000,1)
				end	
				
			else
				ControlCastSpell(HK_W, bestAlly)
				ready = false
				if HasBuff(bestAlly, "YuumiWAlly") then
					ready = true
				end
			end
		end	
	else	
		self:Next()
	end		
end	

function Yuumi:NextTower()
local Tower = NearestTower(myHero.pos, 20000)		
	if Tower then
		local pos = Tower.pos
		ClickMM(pos,20000,1)
	else
		local pos = StartPoint
		ClickMM(pos,20000,1)		
	end	
end

function Yuumi:Next()
local Ally = NearestAlly(myHero.pos, 20000)	
local ready = true	
	if IsValid(Ally) then
		if Ready(_W) and not HasBuff(Ally, "YuumiWAlly") and ready then
			if myHero.pos:DistanceTo(Ally.pos) > 700 then
				local pos = Ally.pos
				ClickMM(pos,20000,1)
			else
				ControlCastSpell(HK_W, Ally)
				ready = false
				if HasBuff(Ally, "YuumiWAlly") then
					ready = true
				end
			end
		end
	else
		local pos = StartPoint
		ClickMM(pos,20000,1)		
	end	
end	

function Yuumi:AutoR()
local target = GetTarget(1200)     	
if target == nil then return end		
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 900 and Ready(_R) then	
		if GetImmobileCount(400, target) >= self.Menu.AutoR.UseRE:Value() then   
			ControlCastSpell(HK_R, target.pos)
		end
	end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 500 and Ready(_R) then 
		if GetEnemyCount(400, target) >= self.Menu.AutoR.UseRM:Value() then   
			ControlCastSpell(HK_R, target.pos)
		end
	end		
end	

function Yuumi:Redemption()
	for i, ally in pairs(GetAllyHeroes()) do						 
		local Re = GetInventorySlotItem(3107)	
		local count = GetLowAllyCount(700, ally)
		
		if Re and ally.health/ally.maxHealth <= self.Menu.item.hp:Value()/100 and myHero.pos:DistanceTo(ally.pos) <= 5500 then
			Redempt = true
			if ally.pos:To2D().onScreen then						
				ControlCastSpell(ItemHotKey[Re], ally.pos) 
				Redempt = false
			elseif not ally.pos:To2D().onScreen then			
				CastSpellMM(ItemHotKey[Re], ally.pos, 5500)
				Redempt = false
			end
		end
		
		if Re and ally.health/ally.maxHealth <= 0.5 and count >= self.Menu.item.min:Value() and myHero.pos:DistanceTo(ally.pos) <= 5500 then
			Redempt = true
			if ally.pos:To2D().onScreen then						
				ControlCastSpell(ItemHotKey[Re], ally.pos) 
				Redempt = false
			elseif not ally.pos:To2D().onScreen then			
				CastSpellMM(ItemHotKey[Re], ally.pos, 5500)
				Redempt = false
			end
		end		
	end		
end	

function Yuumi:Mikaels()	
	for i, ally in pairs(GetAllyHeroes()) do
		local Mik = GetInventorySlotItem(3222)
		local ImmoAlly = Cleans(ally)
		local ImmoMe = Cleans(myHero)			

		if Mik and myHero.pos:DistanceTo(ally.pos) <= 600 and IsValid(ally) and ImmoAlly then
			ControlCastSpell(ItemHotKey[Mik], ally)	
        end

		if Mik and ImmoMe then
			ControlCastSpell(ItemHotKey[Mik], myHero)	
        end			
	end
end		


function Yuumi:AutoE()
	for i, Ally in pairs(GetAllyHeroes()) do	
		local bestAlly = self:MainAlly()
		local lowAlly = self:LowestAlly()
		local spell = myHero:GetSpellData(_W)
					 
		if Ready(_E) and spell.name == "YuumiW" then
			if myHero.health/myHero.maxHealth <= self.Menu.AutoE.myHP:Value() / 100 then
				ControlCastSpell(HK_E)
			end
		end
		
		if HasBuff(bestAlly, "YuumiWAlly") and Ready(_E) then
			if bestAlly.health/bestAlly.maxHealth <= self.Menu.AutoE.MainHP:Value() / 100 then 	
				ControlCastSpell(HK_E)
				
			elseif lowAlly and lowAlly ~= bestAlly and IsValid(lowAlly) and lowAlly.health/lowAlly.maxHealth <= self.Menu.AutoE.AllyHP:Value() / 100  and Ready(_E) and Ready(_W) then
				ControlCastSpell(HK_W, lowAlly)
			end
		end	
		
		if lowAlly and HasBuff(lowAlly, "YuumiWAlly") and Ready(_E) then
			if lowAlly ~= bestAlly and lowAlly.health/lowAlly.maxHealth <= self.Menu.AutoE.AllyHP:Value() / 100  and Ready(_E) then
				ControlCastSpell(HK_E)
			end
		end
		
		if HasBuff(Ally, "YuumiWAlly") and Ally ~= bestAlly and Ready(_E) then
			if Ally.health/Ally.maxHealth <= self.Menu.AutoE.AllyHP:Value() / 100 then 	
				ControlCastSpell(HK_E)
				
			elseif lowAlly and lowAlly ~= Ally and IsValid(lowAlly) and lowAlly.health/lowAlly.maxHealth <= self.Menu.AutoE.AllyHP:Value() / 100  and Ready(_E) and Ready(_W) then
				ControlCastSpell(HK_W, lowAlly)
			end
		end		
	end
end	

function Yuumi:Summoner()
local target = GetTarget(700)
if target == nil then return end	
	if IsValid(target) then		
		local TargetHp = target.health/target.maxHealth
        
		if self.Menu.summ.ex.target:Value() then
            if myHero.pos:DistanceTo(target.pos) <= 650 and TargetHp <= self.Menu.summ.ex.hp:Value()/100 then
                if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and isReady(SUMMONER_1) then
                    ControlCastSpell(HK_SUMMONER_1, target)
                elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and isReady(SUMMONER_2) then
                    ControlCastSpell(HK_SUMMONER_2, target)
                end
            end
        end
		
        if self.Menu.summ.ign.ST:Value() == 1 then
			if TargetHp <= self.Menu.summ.ign.hp:Value()/100 and myHero.pos:DistanceTo(target.pos) <= 600 then
                if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and isReady(SUMMONER_1) then
                    ControlCastSpell(HK_SUMMONER_1, target)
                elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and isReady(SUMMONER_2) then
                    ControlCastSpell(HK_SUMMONER_2, target)
                end
            end
        elseif self.Menu.summ.ign.ST:Value() == 2 then       
			local IGdamage = 50 + 20 * myHero.levelData.lvl
			if myHero.pos:DistanceTo(target.pos) <= 600 and target.health  <= IGdamage then
                if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and isReady(SUMMONER_1) then
                    ControlCastSpell(HK_SUMMONER_1, target)
                elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and isReady(SUMMONER_2) then
                    ControlCastSpell(HK_SUMMONER_2, target)
                end
            end
        end			
	end	
end	

----------------------------------------------------
--|      Buy Items (thx to Tweetieshy)           |--
----------------------------------------------------

local function KeyCombo(ModKey, PressKey)
	ControlKeyDown(ModKey)
	ControlKeyDown(PressKey)
	ControlKeyUp(PressKey)
	ControlKeyUp(ModKey)
end

local function SelectSearchFieldBuy()
	KeyCombo(17,"L")
end

local function PutKey(key)
	if key == "." then
		key = 190
	end
	
	--p-rint(key)
	
	if Control.IsKeyDown(key) then ControlKeyUp(key) end
    ControlKeyDown(key) 
    ControlKeyUp(key)
    
end

local function Write(value)    
    value:gsub(".", function(c)   
	PutKey(c:upper():byte()) 
	end)
end

local function Enter()    
    if Control.IsKeyDown(13) then ControlKeyUp(13) end
    ControlKeyDown(13)
    ControlKeyUp(13)    
end
-- Buystates: 0: No Buy, 1: Attempt to Buy, 2: Opened Buy Window, 3: Selected Item Chapter, 4: Buy Item, 5: Buy failed
function Yuumi:Buy()
	if buystate == 5 then
		if myHero.gold >= gold and Items[currenthave+1][3] > 0 and not Next then
			print("Buying not successful")
			PutKey(27) --  escape
			Next = true
			if Control.IsKeyDown(27) then
				ControlKeyUp(27)
				buystate = 6
				Next = false 
			else
				buystate = 6
				Next = false 
			end						
			return
		else
			buystate = 0
			currenthave = currenthave+1
			for k=1, #Items do
				if k > currenthave and myHero.gold > Items[k][3] then
					buystate = 2
					break;
				end
			end
			
		end
		
		if buystate ~= 2 and buystate ~= 6 and not Next then
			PutKey(27) --  escape
			Next = true
			if Control.IsKeyDown(27) then
				ControlKeyUp(27)
				buystate = 0
				Next = false 
			else
				buystate = 0
				Next = false 
			end	
		end
	end
	
	if buystate == 4 and not Next then
		gold = myHero.gold
		Enter()
		Next = true
		DelayAction(function()
			if Control.IsKeyDown(13) then
				ControlKeyUp(13) 
				Enter()
				DelayAction(function()
					if Control.IsKeyDown(13) then
						ControlKeyUp(13)
						buystate = 5
						Next = false
					else
						buystate = 5
						Next = false								
					end	
				end,0.3)
			else
				Enter()
				DelayAction(function()
					if Control.IsKeyDown(13) then
						ControlKeyUp(13)
						buystate = 5
						Next = false
					else
						buystate = 5
						Next = false								
					end	
				end,0.3)						
			end	
		end,0.3) 
	end
	
	if buystate == 3 and not Next then
		gold = myHero.gold
		Write(Items[currenthave+1][1])
		Next = true
		DelayAction(function()
		if not CurText then
			buystate = 4
			Next = false
		end	
		end,0.3)				
	end
		
	if buystate == 2 and not Next then
		SelectSearchFieldBuy()
		Next = true 
		DelayAction(function()
			if Control.IsKeyDown("L") then
				ControlKeyUp("L") 
			elseif Control.IsKeyDown(17) then
				ControlKeyUp(17)
				buystate = 3
				Next = false 						
			else
				buystate = 3
				Next = false 
			end	
		end,0.3)
	end
	
	if buystate == 1 and not Next then
		Next = true		
		PutKey("P") 
		DelayAction(function()
			if Control.IsKeyDown("P") then
				ControlKeyUp("P")
				buystate = 2
				Next = false 
			else
				buystate = 2
				Next = false 
			end	
		end,0.5)
	end
	
	if buystate == 0 then
		for k=1, #Items do
			if k > currenthave then
				if myHero.gold >= Items[k][3] then
					--print("buy item " .. Items[k][1])
					buystate = 1
				else
					--print("cant buy item!? "  .. v[1])
					buystate = 6
				end
				break
			end
		end
		
	end
end	

local function CanAffordNextItem()
	for k=1, #Items do
		if k > currenthave then
			if myHero.gold >= Items[k][3] then
				return true
			else
				return false
			end
			break
		end
	end
end

local function HasItem(item, Items)
	for k=1, #Items do
		if Items[k] and Items[k].itemID == item[2] then
			return true
		end
	end	 
	return false
end

local function CheckItems()
	local Itemslots = { myHero:GetItemData(ITEM_1), myHero:GetItemData(ITEM_2), myHero:GetItemData(ITEM_3), myHero:GetItemData(ITEM_4), myHero:GetItemData(ITEM_5), myHero:GetItemData(ITEM_6), myHero:GetItemData(ITEM_7) }
	local End = false
	
	for k=1, #Items do
		if HasItem(Items[k],Itemslots) then
			currenthave = k
			--p-rint(Items[k][1])
		elseif not End then
			if Items[k][4] and not HasItem(Items[Items[k][4]],Itemslots) then
				--p-rint("does not have " .. Items[k][1] .. " " .. Items[k][4])
				End = true
			end
		elseif End then
			return
		end
	end	
end

function Yuumi:SetBuyStance()
	if not buystance and CanAffordNextItem() then
		--p-rint("Start Buy items")
		buystance = true
		CheckItems()
	elseif buystance and not CanAffordNextItem() and (buystate == 0 or buystate == 6) then
		--p-rint("End Buy items")
		buystance = false
		buystate = 0
	end
end

function Yuumi:CheckBuy()
	if buystate ~= 6 then	
		if IsInBuyDistance() then
			self:Buy()
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
end, math.max(0.07, 30 - GameTimer()))
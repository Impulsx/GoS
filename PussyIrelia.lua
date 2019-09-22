local Heroes = {"Irelia"}

if not table.contains(Heroes, myHero.charName) then return end




----------------------------------------------------
--|                    Checks                    |--
----------------------------------------------------

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')


if not FileExist(COMMON_PATH .. "PussyDamageLib.lua") then
	print("PussyDamageLib. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/PussyDamageLib.lua", COMMON_PATH .. "PussyDamageLib.lua", function() end)
	while not FileExist(COMMON_PATH .. "PussyDamageLib.lua") do end
end
    
require('PussyDamageLib')


-- [ AutoUpdate ]
do
    
    local Version = 0.02
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyIrelia.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyIrelia.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyIrelia.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyIrelia.version"
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
            print("New PussyIrelia Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end



----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

local TEAM_ALLY, TEAM_ENEMY, TEAM_JUNGLE = myHero.team, 300 - myHero.team, 300
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local charging = false
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local _OnVision = {}
local sqrt = math.sqrt

function OnLoad()
	if table.contains(Heroes, myHero.charName) then
		_G[myHero.charName]()
	end	
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
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

local function GetMode()
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

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function IsUnderTurret(unit)
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

local function AllyMinionUnderTower()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_ALLY and IsValid(minion) and IsUnderTurret(minion) and myHero.pos:DistanceTo(minion.pos) <= 750 then
			return true
		end
	end
	return false
end

local function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff.count
    end
  end
  return 0
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

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
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

local function SetMovement(bool)
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
	if bool then
		castSpell.state = 0
	end
end

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end 

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local function OnVision(unit)
	_OnVision[unit.networkID] = _OnVision[unit.networkID] == nil and {state = unit.visible, tick = GetTickCount(), pos = unit.pos} or _OnVision[unit.networkID]
	if _OnVision[unit.networkID].state == true and not unit.visible then
		_OnVision[unit.networkID].state = false
		_OnVision[unit.networkID].tick = GetTickCount()
	end
	if _OnVision[unit.networkID].state == false and unit.visible then
		_OnVision[unit.networkID].state = true
		_OnVision[unit.networkID].tick = GetTickCount()
	end
	return _OnVision[unit.networkID]
end

local _OnWaypoint = {}
local function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end

local function GetPred(unit,speed,delay)
	local speed = speed or math.huge
	local delay = delay or 0.25
	local unitSpeed = unit.ms
	if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
	if OnVision(unit).state == false then
		local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
		local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
		if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
		return predPos
	else
		if unitSpeed > unit.ms then
			local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		elseif IsImmobileTarget(unit) then
			return unit.pos
		else
			return unit:GetPrediction(speed,delay)
		end
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

local function MyHeroReady()
    return myHero.dead == false and Game.IsChatOpen() == false and (ExtLibEvade == nil or ExtLibEvade.Evading == false) and IsRecalling(myHero) == false
end




----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Irelia"

local WData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.6 + ping, Radius = 100, Range = 825, Speed = 1400, Collision = false
}

local EData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.75 + ping, Radius = 50, Range = 775, Speed = 2000, Collision = false
}

local RData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 160, Range = 1000, Speed = 2000, Collision = false
}

function Irelia:__init()
   	
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

function Irelia:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Irelia", name = "PussyIrelia"})

	--AutoE 
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "2-5 Enemys stunable", value = true})	
	
	--AutoQ
	self.Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ LastHit"})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto LastHit Minion", value = true})
	self.Menu.AutoQ:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.AutoQ:MenuElement({id = "Q", name = "Auto Q Toggle Key", key = 84, toggle = true})
	self.Menu.AutoQ:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
			
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({name = " ", drop = {"E1, W, R, Q, E2, Q + (Q when kill / almost kill)"}})	
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"Marked + Dash back Minion", "Everytime"}})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	self.Menu.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	self.Menu.Clear.Last:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Clear:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	self.Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end	

function Irelia:Tick()
	if MyHeroReady() then
		local Mode = GetMode()
			if Mode == "Combo" then
				self:Combo()
			elseif Mode == "Harass" then
				self:Harass()
			elseif Mode == "Clear" then
				self:Clear()
			end

		
		self:KillSteal()
		self:CastE2()
		if self.Menu.AutoQ.Q:Value() and Mode ~= "Combo" then
			self:AutoQ()
		end
	end
end

function Irelia:UseHydraminion(minion)
local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
	if hydraitem and myHero.attackData.state == STATE_WINDDOWN and myHero.pos:DistanceTo(minion.pos) <= 300 then
		Control.CastSpell(keybindings[hydraitem])
	end
end

function Irelia:Draw()
  if myHero.dead then return end
	
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 1000, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 775, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 825, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	if self.Menu.AutoQ.UseQ:Value() then
		if self.Menu.AutoQ.Q:Value() then 
			Draw.Text("Auto[Q]Minion ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
		else
			Draw.Text("Auto[Q]Minion OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
		end	
	end	
	
	local target = GetTarget(1000)
	if target == nil then return end	
	if target and myHero.pos:DistanceTo(target.pos) <= 1000 and not target.dead then
	local Dmg = (getdmg("Q", target, myHero) + getdmg("W", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero)) 
	local hp = target.health	
		if myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_E).level > 0 and myHero:GetSpellData(_R).level > 0 and Dmg > hp then
			Draw.Text("KILL HIM", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
		else
			Draw.Text("HARASS HIM", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
		end	
	end
end

function Irelia:Combo()
local target = GetTarget(1100)     	
if target == nil or myHero.attackData.state == 2 then return end
	if IsValid(target) then
		
		if self.Menu.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 500 then					
				self:CastE(target)

			end
		end	
			
		
		if myHero.pos:DistanceTo(target.pos) <= 550 and Ready(_Q) and GotBuff(target, "ireliamark") == 1 then
			CastSpell(HK_Q, target.pos, 550, 0.25 + ping)
		end
		
		
		if self.Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				Control.CastSpell(HK_W, target.pos)

			end
		end	
		

		if self.Menu.Combo.UseR:Value() and Ready(_R) and not Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 1000 then					
				self:CastR(target)

			end
		end	
		
		
		if myHero.pos:DistanceTo(target.pos) <= 550 and Ready(_Q) then
			local dmg = getdmg("Q", target, myHero) 
			if dmg >= target.health then
				CastSpell(HK_Q, target.pos, 550, 0.25 + ping)
			else
				if (dmg + myHero.totalDamage) >= target.health then
					CastSpell(HK_Q, target.pos, 550, 0.25 + ping)
				end
			end				
		end
		self:Gapclose(target)	
	end	
end	

function Irelia:Harass()
local target = GetTarget(1100)     	
if target == nil or myHero.attackData.state == 2 then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) <= 550 and Ready(_Q) then
			if self.Menu.Harass.UseQ:Value() ~= 2 and GotBuff(target, "ireliamark") == 1 then
				CastSpell(HK_Q, target.pos, 550, 0.25 + ping)
				DelayAction(function()
				self:CastQMinion(target)
				end,0.5)
			end	
			if self.Menu.Harass.UseQ:Value() ~= 1 then
				CastSpell(HK_Q, target.pos, 550, 0.25 + ping)
			end	
		end
		
		if self.Menu.Harass.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				self:CastW(target)
				
			end
		end	
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 500 then					
				self:CastE(target)
				
			end
		end	
	end	
end
	
function Irelia:AutoQ()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	if myHero.attackData.state == 2 then return end
		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if self.Menu.AutoQ.UseItem:Value() then
				self:UseHydraminion(minion)
			end	
            
			if self.Menu.AutoQ.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.AutoQ.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					CastSpell(HK_Q, minion.pos, 550, 0.25 + ping)
				end
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					CastSpell(HK_Q, minion.pos, 550, 0.25 + ping)
				end
            end
		end
	end
end

function Irelia:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	if myHero.attackData.state == 2 then return end
		if minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if self.Menu.Clear.UseW:Value() and Ready(_W) and not Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 825 then
				Control.CastSpell(HK_W, minion)
                    
            end           
           
			if self.Menu.AutoQ.Q:Value() then return end
			if self.Menu.Clear.UseItem:Value() then
				self:UseHydraminion(minion)
			end				
			
			if self.Menu.Clear.Last.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					CastSpell(HK_Q, minion.pos, 550, 0.25 + ping)
				end	
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					CastSpell(HK_Q, minion.pos, 550, 0.25 + ping)
				end				
			end
        end
    end
end

function Irelia:KillSteal()
	local target = GetTarget(1100)     	
	if target == nil or myHero.attackData.state == 2 then return end
	
	
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and self.Menu.ks.UseQ:Value() then
			local QDmg = getdmg("Q", target, myHero)
			local hp = target.health
			if QDmg >= hp then
				CastSpell(HK_Q, target.pos, 550, 0.25 + ping)
				DelayAction(function()
				self:CastQMinion(target)
				end,0.5)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 825 and Ready(_W) and self.Menu.ks.UseW:Value() then
			local WDmg = getdmg("W", target, myHero)
			local hp = target.health
			if WDmg >= hp then
				self:CastW(target)
			end
		end	
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_R) and self.Menu.ks.UseR:Value() then
			local RDmg = getdmg("R", target, myHero)
			local hp = target.health
			if RDmg >= hp then
				self:CastR(target)
			end
		end
	end
end	

function Irelia:CastQMinion(target)
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if myHero.attackData.state == 2 then return end
		if minion.team == TEAM_ENEMY and IsValid(minion) then
			local Dmg = getdmg("Q", target, myHero) or getdmg("W", target, myHero) or getdmg("E", target, myHero) or getdmg("R", target, myHero)
			local QDmg = getdmg("Q", minion, myHero, 2)
			local hp = target.health
			if myHero.pos:DistanceTo(minion.pos) <= 600 and myHero.pos:DistanceTo(minion.pos) > myHero.pos:DistanceTo(target.pos) and not IsUnderTurret(minion) and hp > Dmg and QDmg >= minion.health then
				CastSpell(HK_Q, minion.pos, 550, 0.25 + ping)
			end
		end
	end
end	

function Irelia:Gapclose(target)
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if myHero.attackData.state == 2 then return end
		if myHero.pos:DistanceTo(target.pos) > 500 and myHero.pos:DistanceTo(minion.pos) <= 500 and target.pos:DistanceTo(minion.pos) < 600 then
			local QDmg = getdmg("Q", minion, myHero, 2)
			if Ready(_Q) and minion.team == TEAM_ENEMY and IsValid(minion) and QDmg >= minion.health then
				CastSpell(HK_Q, minion.pos, 550, 0.25 + ping)
			end
		end
	end	
end	

function Irelia:CastW(target)
    if target then
        if not charging and GotBuff(myHero, "ireliawdefense") == 0 then
            Control.KeyDown(HK_W)
            wClock = clock()
            settime = clock()
            charging = true
        end
		local pred = GetGamsteronPrediction(target, WData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
			if GotBuff(myHero, "ireliawdefense") == 1 and (target.pos:DistanceTo() > 600) then
				CastSpell(HK_W, pred.CastPosition)
				charging = false
			elseif GotBuff(myHero, "ireliawdefense") == 1 and clock() - wClock >= 0.5 and target.pos:DistanceTo() < 825 then
				CastSpell(HK_W, pred.CastPosition)
				charging = false
			end		
        end
        
        
    end
    if clock() - wClock >= 1.5 then
    Control.KeyUp(HK_W)
    charging = false
    end 
end

function Irelia:GetBestECastPositions(units)
    local units = GetEnemyHeroes()
    local startPos, endPos, count = nil, nil, 0
    local candidates, unitPositions = {}, {}
    for i, unit in ipairs(units) do
        local cp = GetPred(unit,2000,0.75 + ping)
        if cp then candidates[i], unitPositions[i] = cp, cp end
    end
    local maxCount = #units
    for i = 1, maxCount do
        for j = 1, maxCount do
            if candidates[j] ~= candidates[i] then
                table.insert(candidates, Vector(candidates[j] + candidates[i]) / 2)
            end
        end
    end
    for i, unit2 in pairs(units) do
        local cp = GetPred(unit2,2000,0.75 + ping)
        if cp then
            if myHero.pos:DistanceTo(cp.pos) < 775 then
                for i, pos2 in ipairs(candidates) do
                    if pos2:DistanceTo(cp.pos) < 775 then 
                        
                        local ePos = Vector(cp):Extended(pos2, 775)
                        local number = 0
                        for i = 1, #unitPositions do
                            local unitPos = unitPositions[i]   
                            local pointLine, pointSegment, onSegment = VectorPointProjectionOnLineSegment(cp, ePos, unitPos)
                            if pointSegment and GetDistance(pointSegment, unitPos) < 1550 then number = number + 1 end 
                             
                        end
                        if number >= 2 then startPos, endPos, count = cp, ePos, number end

                    end
                end
            end
        end
    end
    return startPos, endPos, count
end

function Irelia:CastE2()
local target = GetTarget(1100)
local startPos, endPos, count = self:GetBestECastPositions(target)
if IsValid(target) and self.Menu.AutoE.UseE:Value() and Ready(_E) then
    local targetCount = GetEnemyCount(725, myHero)
	if startPos and endPos and targetCount >= 2 then
	
		if myHero:GetSpellData(_E).name == "IreliaE" then
			if myHero:GetSpellData(_E).name == "IreliaE2" then return end
				SetMovement(false)
				CastSpell(HK_E, startPos)
				SetMovement(true)
		end

		if myHero:GetSpellData(_E).name == "IreliaE2" then
			SetMovement(false)
			CastSpell(HK_E, endPos)
			SetMovement(true)
       
		end
	end
end
end	

function Irelia:CastE(target)

    if myHero:GetSpellData(_E).name == "IreliaE" then
        if myHero:GetSpellData(_E).name == "IreliaE2" then return end
		pos = myHero.pos 
		Control.CastSpell(HK_E, pos)
    
    end
	local pred = GetGamsteronPrediction(target, EData, myHero)
    if myHero:GetSpellData(_E).name == "IreliaE2" and pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
        pos2 = pred.CastPosition + (myHero.pos - pred.CastPosition): Normalized() * -150
        SetMovement(false)
        CastSpell(HK_E, pos2, 775, 0.25 + ping)
        SetMovement(true)
       
	end
end


function Irelia:CastR(target)
	local pred = GetGamsteronPrediction(target, RData, myHero)
	if pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
		Control.CastSpell(HK_R, pred.CastPosition)
	end
end	




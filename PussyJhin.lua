local Heroes = {"Jhin"}

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


-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyJhin.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyJhin.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyJhin.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyJhin.version"
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
            print("New PussyJhin Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end]]



----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

local TEAM_ALLY, TEAM_ENEMY, TEAM_JUNGLE = myHero.team, 300 - myHero.team, 300
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}

function OnLoad()
	if table.contains(Heroes, myHero.charName) then
		_G[myHero.charName]()
	end	
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

local function CastSpellMM(spell,pos,range,delay)
	local range = range or math.huge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
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
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
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

local function IsRecalling(unit)
	for i = 1, 63 do
	local buff = unit:GetBuff(i) 
		if buff.count > 0 and buff.name == "recall" and Game.Timer() < buff.expireTime then
			return true
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

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function MyHeroReady()
    return myHero.dead == false and Game.IsChatOpen() == false and (ExtLibEvade == nil or ExtLibEvade.Evading == false) and IsRecalling(myHero) == false
end

local function CanUseSpell(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end


----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Jhin"

local WData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.75, Radius = 40, Range = 3000, Speed = 5000, Collision = false
}

local RData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 3500, Speed = 5000, Collision = false
}

function Jhin:__init()

   	
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

function Jhin:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Jhin", name = "PussyJhin"})

	--AutoW 
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	self.Menu.AutoW:MenuElement({name = " ", drop = {"Only for Dark Haevest Rune"}})
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W] if Enemy Hp<50%", value = true})
			
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"[Q]before 4th AAhit", "[Q]after 4th AAhit"}})	
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]snare Target", value = true})
	self.Menu.Combo:MenuElement({type = MENU, id = "Ulti", name = "Ult Setting"})
	self.Menu.Combo.Ulti:MenuElement({name = " ", drop = {"Hold Key [Result == StartUlt + AutoAim]"}})
	self.Menu.Combo.Ulti:MenuElement({id = "UseR", name = "Ult Activate Key", key = string.byte("T")})
	self.Menu.Combo.Ulti:MenuElement({id = "Draw", name = "Killable Text[onScreen+Minimap]", value = true})
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]Hit Minion+Enemy", value = 1, drop = {"Automatically", "HarassKey"}})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	self.Menu.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	self.Menu.Clear.Last:MenuElement({id = "UseW", name = "LastHit[W]Cannon/if out of AA range", value = 1, drop = {"Automatically", "ClearKey"}})	
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 3, min = 1, max = 6, step = 1}) 
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]if min 1 Minion killable", value = true})
	self.Menu.Clear:MenuElement({id = "UseQM", name = "Use[Q]min Minions arround killable Minion", value = 3, min = 1, max = 3, step = 1}) 
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end	

function Jhin:Tick()
	if MyHeroReady() then
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
		elseif Mode == "Harass" then
			if self.Menu.Harass.UseQ:Value() ~= 1 then
				self:Harass()
			end	
		elseif Mode == "Clear" then
			self:Clear()
			if self.Menu.Clear.Last.UseW:Value() ~= 1 then
				self:LastHitW()
			end	
		end	
		if self.Menu.Harass.UseQ:Value() ~= 2 then
			self:Harass()
		end
		if self.Menu.Clear.Last.UseW:Value() ~= 2 then
			self:LastHitW()
		end	
		if self.Menu.Combo.Ulti.UseR:Value() then
			self:StartR()
		end	

	self:KillSteal()
	self:AutoW()

		
	end
end

function Jhin:StartR()
local target = GetTarget(3500)     	
if target == nil then return end
	if myHero:GetSpellData(_R).name == "JhinR" and myHero.pos:DistanceTo(target.pos) <= 3500 and IsValid(target) and Ready(_R) then
		if target.pos:To2D().onScreen then
			CastSpell(HK_R, target.pos, 3500)
        else
			local castPos = myHero.pos:Extended(target.pos, 1000)    
			Control.CastSpell(HK_R, castPos)
                            
        end
		
	end
	
    if myHero:GetSpellData(_R).name == "JhinRShot" and myHero.pos:DistanceTo(target.pos) <= 3500 then
		self:CastR(target)
	end	
end

function Jhin:Draw()
  if myHero.dead then return end
	
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 3500, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 550, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 750, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 3000, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	
	local target = GetTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Combo.Ulti.Draw:Value() and not target.dead then
	local Dmg = (getdmg("R", target, myHero, 1)*3) + getdmg("R", target, myHero, 2)
	local hp = target.health	
		if Ready(_R) and Dmg > hp then
			Draw.Text("Ult Kill", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Ult Kill", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
			LSS = Circle(Point(target), target.boundingRadius)
			LSS:__draw()
		end	
	end
end

function Jhin:DarkHarvest()
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff.name:lower():find("darkharvest")then 
			return true
		end
	end
	return false
end

function Jhin:AutoW()
	local target = GetTarget(3000)     	
	if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) then
		if self.Menu.AutoW.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 3000 and target.health/target.maxHealth < 50/100 and self:DarkHarvest() then
				self:CastW(target)
			end
		end
	end
end

function Jhin:Combo()
local target = GetTarget(3000)     	
if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) <= 550 and Ready(_Q) then
			if 	self.Menu.Combo.UseQ:Value() ~= 1 and HasBuff(myHero, "jhinpassivereload") then
				Control.CastSpell(HK_Q, target)
			else 
				Control.CastSpell(HK_Q, target)
			end	
		end
		
		if self.Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 3000 and HasBuff(target, "jhinespotteddebuff") then					
				self:CastW(target)
				
			end
		end		
	end	
end	

function Jhin:Harass()
local target = GetTarget(1000)
if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
			if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 550 and target.pos:DistanceTo(minion.pos) <= 400 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion)
			end
		end
	end
end

function Jhin:Clear()
    if myHero:GetSpellData(_R).name == "JhinRShot" then return end
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if minion.team == TEAM_ENEMY then
            
            
			if self.Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 550 and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero)
				local count = GetMinionCount(400, minion)
				if QDmg >= minion.health and count >= self.Menu.Clear.UseQM:Value() then
					Control.CastSpell(HK_Q, minion)
				end	
            end
            local count = GetMinionCount(260, minion)          
			if Game.CanUseSpell(_E) == 0 and self.Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 750 and count >= self.Menu.Clear.UseEM:Value() then
				Control.CastSpell(HK_E, minion.pos)
                    
            end
        end
    end
end

function Jhin:LastHitW()
	if myHero:GetSpellData(_R).name == "JhinRShot" then return end
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_ENEMY and minion.charName:find("MinionSiege") and IsValid(minion) then
			local WDmg = getdmg("W", minion, myHero, 2)
			if myHero.pos:DistanceTo(minion.pos) >= 550 and myHero.pos:DistanceTo(minion.pos) <= 3000 and WDmg >= minion.health then
				Control.CastSpell(HK_W, minion.pos)
			end
		end
	end
end	

function Jhin:KillSteal()
	local target = GetTarget(3000)     	
	if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	
	
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 3000 and Ready(_W) and self.Menu.ks.UseW:Value() then
			local WDmg = getdmg("W", target, myHero, 1)
			local hp = target.health
			if WDmg >= hp then
				self:CastW(target)
			end
		end
	end
end	

function Jhin:CastW(target)
	local pred = GetGamsteronPrediction(target, WData, myHero)
	if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
		Control.CastSpell(HK_W, pred.CastPosition)
	end
end	

function Jhin:CastR(target)
	local pred = GetGamsteronPrediction(target, RData, myHero)
	if pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
		if target.pos:To2D().onScreen then
			CastSpell(HK_R, pred.CastPosition)
        else
			CastSpellMM(HK_R, pred.CastPosition)
                            
        end
	end
end	




----------------------------------------------------
--|                Damage Calc              	 |--
----------------------------------------------------



local DamageReductionTable = {
  ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level] end},
  ["Urgot"] = {buff = "urgotswapdef", amount = function(target) return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level] end},
  ["Alistar"] = {buff = "Ferocious Howl", amount = function(target) return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level] end},
  ["Amumu"] = {buff = "Tantrum", amount = function(target) return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level] end, damageType = 1},
  ["Galio"] = {buff = "GalioIdolOfDurand", amount = function(target) return 0.5 end},
  ["Garen"] = {buff = "GarenW", amount = function(target) return 0.7 end},
  ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level] end},
  ["Annie"] = {buff = "MoltenShield", amount = function(target) return 1 - ({0.16,0.22,0.28,0.34,0.4})[target:GetSpellData(_E).level] end},
  ["Malzahar"] = {buff = "malzaharpassiveshield", amount = function(target) return 0.1 end}
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

local DamageLibTable = {

  ["Jhin"] = {  
    {Slot = "Q", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({45, 70, 95, 120, 145})[level] + ({0.45, 0.52, 0.6, 0.67, 0.75})[level] * source.totalDamage + 0.6 * source.ap end},
	{Slot = "W", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 85, 120, 155, 190})[level] + 0.5 * source.totalDamage end},
    {Slot = "W", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({37, 63, 90, 116, 142})[level] + 0.37 * source.totalDamage end},
    {Slot = "R", Stage = 1, DamageType = 1, Damage = function(source, target, level) return ({50, 125, 200})[level] + 0.2 * source.totalDamage * (1 + (100 - GetPercentHP(target)) * 1.025) end},
    {Slot = "R", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({50, 125, 200})[level] + 0.2 * source.totalDamage * (1 + (100 - GetPercentHP(target)) * 1.025) * 2 end}	

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


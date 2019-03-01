if myHero.charName ~= "Kassadin" then return end
class "Kassadin"
local menu = 1





local cancelSpells = {
  ["Caitlyn"] = {
    ["CaitlynAceintheHole"] = {name = "Ace in the Hole"} --R
  },
  ["Darius"] = {
    ["DariusExecute"] = {name = "Noxian Guillotine"} --R
  },
  ["FiddleSticks"] = {
    ["DrainChannel"] = {name = "Drain"},  --W 
    ["Crowstorm"] = {name = "Crowstorm"}  --R 
  },
  ["Gragas"] = {
    ["GragasW"] = {name = "Drunken Rage"} --W 
  },
  ["Janna"] = {
    ["ReapTheWhirlwind"] = {name = "Monsoon"} --R
  },
  ["Karthus"] = {
    ["KarthusFallenOne"] = {name = "Requiem"} --R karthusfallenonecastsound
  },
  ["Katarina"] = {
    ["KatarinaR"] = {name = "Death Lotus"} --R 
  },
  ["Malzahar"] = {
    ["AlZaharNetherGrasp"] = {name = "Nether Grasp"} --R
  },
  ["MasterYi"] = {
    ["Meditate"] = {name = "Meditate"} --W 
  },
  ["MissFortune"] = {
    ["MissFortuneBulletTime"] = {name = "Bullet Time"} --R missfortunebulletsound   
  },
  ["Nunu"] = {
    ["AbsoluteZero"] = {name = "Absolute Zero"} --R
  },
  ["Pantheon"] = {
    ["PantheonE"] = {name = "Heartseeker Strike"}, --E
    ["PantheonRJump"] = {name = "Grand Skyfall"} --R
  },
  ["TwistedFate"] = {
    ["Destiny"] = {name = "Gate"} --R 
  },
  ["Warwick"] = {
    ["InfiniteDuress"] = {name = "Infinite Duress"} --R warwickrsound
  },
  ["Rammus"] = {
    ["PowerBall"] = {name = "Powerball"} --Q 
  }
}
local units = {}
local foundAUnit = false
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300

-- [ AutoUpdate ]
do
    
    local Version = 0.09
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyKassadin.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyKassadin.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyKassadin.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyKassadin.version"
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
            print("New PussyKassadin Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end


local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end 

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
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
	if bool then
		castSpell.state = 0
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

local spellcast = {state = 1, mouse = mousePos}

function CastSpell(HK, pos, delay)
	if spellcast.state == 2 then return end
	if ExtLibEvade and ExtLibEvade.Evading then return end
	
	spellcast.state = 2
	DisableOrb()
	spellcast.mouse = mousePos
	DelayAction(function() 
		Control.SetCursorPos(pos) 
		Control.KeyDown(HK)
		Control.KeyUp(HK)
	end, 0.05) 
	
		DelayAction(function()
			Control.SetCursorPos(spellcast.mouse)
		end,0.25)
		
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.35)
	
end


function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	elseif _G.gsoSDK then
		return _G.gsoSDK.TargetSelector:GetTarget(GetEnemyHeroes(5000), false)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
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

local function IsValidCreep(unit, range)
  return unit and unit.team ~= TEAM_ALLY and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false and unit.visible
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

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
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

function GetAllyHeroes() 
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function GetAllyTurret() 
	Allyturret = {}
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
		if turret.isAlly and not turret.dead then
			table.insert(Allyturret, turret)
		end
	end
	return Allyturret
end

function GetMinion() 
	Allminion = {}
	for i = 1,Game.MinionCount() do
		local minion = Game.Minion(i)
		if not minion.dead then
			table.insert(Allminion, minion)
		end
	end
	return Allminion
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

function Kassadin:__init()
 
  if menu ~= 1 then return end
  menu = 2
  self.passiveTracker = 0
  self.stacks = 0
  qdmg = 0
  edmg = 0
  rdmg = 0
  self:LoadSpells()   	
  self:LoadMenu()                                            
  Callback.Add("Tick", function() self:Tick() end)
  Callback.Add("Draw", function() self:Draw() end) 
 
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	elseif _G.gsoSDK then
		orbwalkername = "Gso orbwalker"
	else
		orbwalkername = "Orbwalker not found"
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



function Kassadin:LoadSpells()

  Q = { range = 650, delay = 0.25, speed = 1400, width = myHero:GetSpellData(_Q).width, radius = 50, Collision = false }
  W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
  E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
  R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

local Icons = {
["Kassadin"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/PussyKassadinScriptLogo.png",
["Combo"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/ComboScriptLogo.png",
["BlockSpells"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/BlockSpellsScriptLogo.png",
["Escape"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/EscapeScriptLogo.png",
["Harass"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/HarassScriptLogo.png",
["Clear"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/Clear%2BLasthitScriptLogo.png",
["JClear"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/JungleClearScriptLogo.png",
["Activator"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/ActivatorScriptLogo.png",
["Drawings"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/DrawingsScriptLogo.png",
["ks"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/KillStealScriptLogo.png",
["Pred"] = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/PredScriptLogo.png"
}


function Kassadin:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Kassadin", leftIcon = Icons["Kassadin"]})
 
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.Combo:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
 
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({id = "LastQ", name = "[Q] LastHit Minions", value = true})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Harass:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.Harass:MenuElement({id = "UseR", name = "Poke[R],[E],[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 65, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})         
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.Clear:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Clear:MenuElement({id = "EHit", name = "[E] if x minions", value = 3, min = 1, max = 7})
	self.Menu.Clear:MenuElement({id = "lastQ", name = "[Q] LastHit", value = true})         
	self.Menu.Clear:MenuElement({id = "lastW", name = "[W] LastHit", value = true})  
	self.Menu.Clear:MenuElement({id = "lastR", name = "[R] LastHit[Only if not Enemys near]", value = true})
	self.Menu.Clear:MenuElement({id = "RHit", name = "[R] LastHit if x minions", value = 3, min = 1, max = 7})  
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 50, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})         
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.JClear:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.JClear:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 50, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.ks:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
	self.Menu.ks:MenuElement({id = "UseQR", name = "[Q]then[R]", value = true})
	self.Menu.ks:MenuElement({id = "UseRQ", name = "[R]then[Q]", value = true})	
	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", leftIcon = Icons["Activator"]})		
	self.Menu.a:MenuElement({type = MENU, id = "Zhonyas", name = "Zhonya's + StopWatch"})
	self.Menu.a.Zhonyas:MenuElement({id = "ON", name = "Enabled", value = true})
	self.Menu.a.Zhonyas:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})
	self.Menu.a:MenuElement({type = MENU, id = "Seraphs", name = "Seraph's Embrace"})
	self.Menu.a.Seraphs:MenuElement({id = "ON", name = "Enabled", value = true})
	self.Menu.a.Seraphs:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})
 
	--BlockSpellsMenu
	self.Menu:MenuElement({type = MENU, id = "block", leftIcon = Icons["BlockSpells"]})
	for i = 1, Game.HeroCount() do
	local unit = Game.Hero(i)
		if unit.team ~= myHero.team then
		units[#units + 1] = unit
			if cancelSpells[unit.charName] then
			foundAUnit = true
		self.Menu.block:MenuElement({type = MENU, id = unit.charName, name = unit.charName})
				for spell, sname in pairs(cancelSpells[unit.charName]) do
				self.Menu.block[unit.charName]:MenuElement({id = spell, name = sname.name, value = true})
  
				end
			end
		end
	end
	if not foundAUnit then
	self.Menu.block:MenuElement({id = "none", name = "No blockable Spell found", type = SPACE}) 
	end 

	--EscapeMenu
	self.Menu:MenuElement({type = MENU, id = "evade", leftIcon = Icons["Escape"]})
	self.Menu.evade:MenuElement({type = MENU, id = "Life", name = "Auto Escape Menu"})	
	self.Menu.evade.Life:MenuElement({id = "UseR", name = "AutoEscape[R] to Ally or Tower", value = true})
	self.Menu.evade.Life:MenuElement({id = "MinR", name = "Min Life to Escape", value = 20, min = 0, max = 100, identifier = "%"})	
	self.Menu.evade:MenuElement({type = MENU, id = "Flee", name = "Manual Escape Menu"})	
	self.Menu.evade.Flee:MenuElement({id = "UseR", name = "Use[R] to Ally or Tower [EscapeKey]", value = true})
	self.Menu.evade.Flee:MenuElement({id = "UseRm", name = "Use[R] to Mouse.Pos [EscapeKey]", value = true})	
	self.Menu.evade.Flee:MenuElement({id = "Fleekey", name = "Escape key", key = string.byte("A")})
	
	
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable on Target and Minimap", value = true})	
end


function Kassadin:Tick()
	
	self:Activator()
	self:EscapeR()
	self:OnBuff(myHero)
	self:KillSteal()

	
	if Ready(_Q) and foundAUnit then     
		for i = 1, #units do
		local unit = units[i]
		
			if unit.isChanneling == true and unit.activeSpell.valid then
			local spellToCancel = cancelSpells[unit.charName]
			local activeSpell = unit.activeSpell.name
			if spellToCancel == nil then return end
			local ignore = (unit.activeSpell.name == "PowerBall") or (unit.activeSpell.name == "PantheonE") or (unit.activeSpell.name == "Meditate") or (unit.activeSpell.name == "GragasW") or (unit.activeSpell.name == "FiddleSticksDrain")	
				if spellToCancel[activeSpell] and self.Menu.block[unit.charName][activeSpell]:Value() then
					if myHero.pos:DistanceTo(unit.pos) <= 650 then
						Control.CastSpell(HK_Q, unit)
					elseif Ready(_R) and myHero.pos:DistanceTo(unit.pos) > 650 and myHero.pos:DistanceTo(unit.pos) <= 1150 then
						if ignore then return end
						Control.CastSpell(HK_R, unit.pos)
						Control.CastSpell(HK_Q, unit)
					end
				end
			end    
		end
	end
	if self.Menu.evade.Flee.Fleekey:Value() then
		self:Flee()
	end
	if self.Menu.evade.Flee.Fleekey:Value() then
		self:FleeR()
	end	
	
		
	if myHero.dead then return end
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		self:Combo()
		self:Combo1()
		self:FullRKill()
		if self.Menu.Combo.UseAW:Value() then
			self:AutoW()
		end
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then                
		self:Harass()
		self:LasthitQ()
		if self.Menu.Harass.UseAW:Value() then
			self:AutoW()
			self:AutoW1()
		end	
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
		self:Clear()
		self:JungleClear()
		if self.Menu.Clear.UseAW:Value() then
			self:AutoW1()
		end
		if self.Menu.JClear.UseAW:Value() then
			self:AutoW1()
		end		
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
		--self:LastHit()
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then

	elseif _G.gsoSDK then
	return _G.gsoSDK.Orbwalker:GetMode()
	else
	return GOS.GetMode()
	end
	
		
	

end



function Kassadin:EnemiesAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if (IsValid(hero) and hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end



function Kassadin:Activator()
if myHero.dead then return end
			--Zhonyas
	if self:EnemiesAround(myHero.pos,1000) then
		if self.Menu.a.Zhonyas.ON:Value()  then
		local Zhonyas = GetItemSlot(myHero, 3157)
			if Zhonyas > 0 and Ready(Zhonyas) then 
				if myHero.health/myHero.maxHealth < self.Menu.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
			--Stopwatch
		if self.Menu.a.Zhonyas.ON:Value() then
		local Stop = GetItemSlot(myHero, 2420)
			if Stop > 0 and Ready(Stop) then 
				if myHero.health/myHero.maxHealth < self.Menu.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Stop])
				end
			end
		end
			--Seraph's Embrace
		if self.Menu.a.Seraphs.ON:Value() then
		local Seraphs = GetItemSlot(myHero, 3040)
			if Seraphs > 0 and Ready(Seraphs) then
				if myHero.health/myHero.maxHealth < self.Menu.a.Seraphs.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Seraphs])
				end
			end
		end
	end
end

function Kassadin:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 500, 3, Draw.Color(255, 225, 255, 10))
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, Q.range, 3, Draw.Color(225, 225, 0, 10))
	end
  	local target = CurrentTarget(20000)
	if target == nil then return end	
	local hp = target.health
	local Dmg = (getdmg("Q", target)), (getdmg("E", target)), (getdmg("Q", target) + getdmg("R", target)), (getdmg("Q", target) + getdmg("E", target)), (getdmg("Q", target) + getdmg("E", target) + getdmg("R", target)), (getdmg("Q", target) + getdmg("W", target) + getdmg("E", target) + getdmg("R", target))
	local QWEdmg = getdmg("Q", target) + getdmg("W", target) + getdmg("E", target)
	local FullReady = Ready(_Q), Ready(_W), Ready(_E), Ready(_R)
	local QWEReady = Ready(_Q), Ready(_W), Ready(_E)	
	if IsValid(target) and self.Menu.Drawing.Kill:Value() then
				
		if Ready(_R) and getdmg("R", target) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_R) and (getdmg("R", target) + getdmg("R", target, myHero, 2)) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
		if FullReady and (getdmg("R", target) + getdmg("R", target, myHero, 2) + QWEdmg) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end	
		if Dmg > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))			
		end
		if QWEReady and QWEdmg > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end
	end
end
 
function Kassadin:ValidTarget(unit,range) 
  return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal 
end

function Kassadin:OnBuff(unit)

  if unit.buffCount == nil then self.passiveTracker = 0 self.stacks = 0 return end
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    
    if buff.name == "forcepulsecancast" then
      self.passiveTracker = buff.count
	end  
    if buff.name == "RiftWalk" then
      self.stacks = buff.count      
    end     
  end
end



function Kassadin:ClearLogic()
  local EPos = nil 
  local Most = 0 
    for i = 1, Game.MinionCount() do
    local Minion = Game.Minion(i)
      if IsValidCreep(Minion, 650) then
        local Count = GetMinionCount(650, Minion)
        if Count > Most then
          Most = Count
          EPos = Minion.pos
        end
      end
    end
    return EPos, Most
end 

	



function Kassadin:KillSteal()
	local target = CurrentTarget(1150)
	if target == nil then return end
	local hp = target.health
	local RDmg = getdmg("R", target)
	local QDmg = getdmg("Q", target)
	if IsValid(target) then
		
		if self.Menu.ks.UseQ:Value() and Ready(_Q) then
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 650 then
				Control.CastSpell(HK_Q, target.pos)					
			end				
		end
	
		if self.Menu.ks.UseR:Value() and Ready(_R) and not IsUnderTurret(target) then
			if RDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 500 then
				Control.CastSpell(HK_R, target)
			end
		end
		if self.Menu.ks.UseQR:Value() and Ready(_R) and Ready(_Q) then
			if (RDmg + QDmg) >= hp and myHero.pos:DistanceTo(target.pos) <= 500 and not IsUnderTurret(target) then
				Control.CastSpell(HK_Q, target.pos)
				Control.CastSpell(HK_R, target)
								
			end
		end	
		if self.Menu.ks.UseRQ:Value() and Ready(_R) and Ready(_Q) then
			if (RDmg + QDmg) >= hp and myHero.pos:DistanceTo(target.pos) < 1150 and myHero.pos:DistanceTo(target.pos) > 650 and not IsUnderTurret(target) then
				Control.CastSpell(HK_R, target)
				Control.CastSpell(HK_Q, target.pos)
								
			end
		end
	end
end	

function Kassadin:AutoW()  
	local target = CurrentTarget(300)
	if target == nil then return end
	if IsValid(target) and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 300 then
		Control.CastSpell(HK_W)
	end
end	
	
function Kassadin:AutoW1()	
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local TEAM_ENEMY = 300 - myHero.team 
	local TEAM_JUNGLE = 300
	if minion.team == TEAM_ENEMY or minion.team == TEAM_JUNGLE then
	if minion == nil then return end	
	if minion and not minion.dead and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 300 then
		Control.CastSpell(HK_W)
		end
	end
	end
end	


	
function Kassadin:Combo()
local target = CurrentTarget(650)
if target == nil then return end
	
	if IsValid(target) and self.Menu.Combo.UseQ:Value() and Ready(_Q) then	
		if myHero.pos:DistanceTo(target.pos) < 650 then
			Control.CastSpell(HK_Q, target.pos)
			
		end	
	end	
	
	if IsValid(target) and self.passiveTracker >= 1 and self.Menu.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 600 then	
		Control.CastSpell(HK_E, target)
	end
end	
	

function Kassadin:EscapeR()
	local target = CurrentTarget(2000)
	if target == nil then return end
	if IsValid(target) and self.Menu.evade.Life.UseR:Value() and Ready(_R) and 100*myHero.health/myHero.maxHealth <= self.Menu.evade.Life.MinR:Value() and myHero.pos:DistanceTo(target.pos) <= 600 then 
		for i,ally in pairs(GetAllyHeroes()) do
			if self:ValidTarget(ally, 2000) and myHero.pos:DistanceTo(ally.pos) < 2000 and myHero.pos:DistanceTo(ally.pos) > 500 then
				if GetEnemyCount(1000, ally) < 1 then
				Control.CastSpell(HK_R, ally.pos)
				end
			end	
		end
		for i,tower in pairs(GetAllyTurret()) do
			if self:ValidTarget(tower, 2000) and myHero.pos:DistanceTo(tower.pos) < 2000 and myHero.pos:DistanceTo(tower.pos) > 750 then
				Control.CastSpell(HK_R, tower.pos)
			end	
		end
	end
end
	

function Kassadin:Flee()
	if self.Menu.evade.Flee.UseR:Value() and Ready(_R) then		
	for i,ally in pairs(GetAllyHeroes()) do
			if self:ValidTarget(ally, 2000) and myHero.pos:DistanceTo(ally.pos) < 2000 and myHero.pos:DistanceTo(ally.pos) > 500 then
				if GetEnemyCount(1000, ally) < 1 then
					Control.CastSpell(HK_R, ally)
				end
			end
		end	
		for i,tower in pairs(GetAllyTurret()) do
			if self:ValidTarget(tower, 2000) and myHero.pos:DistanceTo(tower.pos) < 2000 and myHero.pos:DistanceTo(tower.pos) > 750 then
				Control.CastSpell(HK_R, tower)
					
			end	
		end
	end
end	

function Kassadin:FleeR()
	if self.Menu.evade.Flee.UseRm:Value() and Ready(_R) then				
		Control.CastSpell(HK_R)
	end
end			

function Kassadin:Harass()	
local target = CurrentTarget(1100)
if target == nil then return end	
local ready = Ready(_Q), Ready(_E), Ready(_R)

	if IsValid(target) then
	
		if self.Menu.Harass.UseR:Value() and ready and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then	
			if myHero.pos:DistanceTo(target.pos) <= 1000 and myHero.pos:DistanceTo(target.pos) >= 700 then	
				if self.stacks == 0 and self.passiveTracker >= 1 and not IsUnderTurret(target) then	
					Control.CastSpell(HK_R, target)
					Control.CastSpell(HK_E, target)
					Control.CastSpell(HK_Q, target.pos)
						
				end				
			end
		end
		if self.Menu.Harass.UseE:Value() and Ready(_E) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) and myHero.pos:DistanceTo(target.pos) <= 550 then
			if self.passiveTracker >= 1 then		
				Control.CastSpell(HK_E, target)
			end
		end
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) and myHero.pos:DistanceTo(target.pos) <= 650 then
			Control.CastSpell(HK_Q, target)
		end 
	end
end

function Kassadin:LasthitQ()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local target = CurrentTarget(650)
		if target == nil then
		local TEAM_ALLY = myHero.team
		local TEAM_ENEMY = 300 - myHero.team
		local Qdamage = getdmg("Q", minion)
			if minion.isEnemy and minion.team == TEAM_ENEMY and not minion.dead then	
				if self:ValidTarget(minion,650) and Qdamage >= minion.health and self.Menu.Harass.LastQ:Value() then
					if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 and myHero.pos:DistanceTo(minion.pos) > myHero.range then
						Control.CastSpell(HK_Q, minion)
					end
				end
			end
		end
	end
end	

		
function Kassadin:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local TEAM_ALLY = myHero.team
	local TEAM_ENEMY = 300 - myHero.team
	local Qdamage = getdmg("Q", minion)
	local Wdamage = getdmg("W", minion)	
	local Rdamage = getdmg("R", minion)	
	if minion.isEnemy and minion.team == TEAM_ENEMY and not minion.dead then	
		if self:ValidTarget(minion,650) and Qdamage >= minion.health then
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.Clear.lastQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) > myHero.range then
				Control.CastSpell(HK_Q, minion)
			end
		end
		if self:ValidTarget(minion,150) and Wdamage >= minion.health then
			if self.Menu.Clear.lastW:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= myHero.range then
				Control.CastSpell(HK_W, minion)
			end
		end	
		local target = CurrentTarget(1000)
		if target == nil then
		if self:ValidTarget(minion,500) and Rdamage >= minion.health then
			if Ready(_R) and self.stacks == 0 and myHero.pos:DistanceTo(minion.pos) < 500 and self.Menu.Clear.lastR:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) > myHero.range then	
				local EPos, Count = self:ClearLogic()	
				if Count >= self.Menu.Clear.RHit:Value() then
					Control.CastSpell(HK_R, minion)
				
				end
			end
		end
		end
		
		if self:ValidTarget(minion,650) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.Clear.UseQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) > myHero.range then
			Control.CastSpell(HK_Q, minion)
			
		end
		
		if self:ValidTarget(minion,600) and Ready(_E) and self.passiveTracker >= 1 and myHero.pos:DistanceTo(minion.pos) < 600 and self.Menu.Clear.UseE:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) > myHero.range then
		local EPos, Count = self:ClearLogic()
				if Count >= self.Menu.Clear.EHit:Value() then
						Control.CastSpell(HK_E, EPos)
				
				end
			end  
		end
	end
end

function Kassadin:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	local TEAM_JUNGLE = 300
		if minion.isEnemy and minion.team == TEAM_JUNGLE and not minion.dead then	
			if self:ValidTarget(minion,650) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.JClear.UseQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 ) then
				CastSpell(HK_Q, minion)
			end
			if self:ValidTarget(minion,500) and Ready(_R) and myHero.pos:DistanceTo(minion.pos) < 500 and self.Menu.JClear.UseR:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 ) then
				CastSpell(HK_R,minion.pos)			
			end
			if self:ValidTarget(minion,600) and Ready(_E) and self.passiveTracker >= 1 and myHero.pos:DistanceTo(minion.pos) < 600 and self.Menu.JClear.UseE:Value() then
				CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

function Kassadin:FullRKill()
	local target = CurrentTarget(2500)
	if target == nil then return end
	if self.Menu.Combo.UseR:Value() and Ready(_R) then
	local hp = target.health
	local dist = myHero.pos:DistanceTo(target.pos)
	local level = myHero:GetSpellData(_R).level
	local Fulldmg1 = CalcMagicalDamage(myHero, target,(({120, 150, 180})[level] + 0.5 * myHero.ap) + 0.03 * myHero.maxMana)
	local Fulldmg2 = CalcMagicalDamage(myHero, target,(({160, 200, 240})[level] + 0.6 * myHero.ap) + 0.04 * myHero.maxMana)
	local Fulldmg3 = CalcMagicalDamage(myHero, target,(({200, 250, 300})[level] + 0.7 * myHero.ap) + 0.05 * myHero.maxMana)
	local Fulldmg4 = CalcMagicalDamage(myHero, target,(({240, 300, 360})[level] + 0.8 * myHero.ap) + 0.06 * myHero.maxMana)
	local QWEdmg = getdmg("Q", target) + getdmg("W", target) + getdmg("E", target)	
	
	if IsValid(target) then	
			if getdmg("R", target) > hp then
				if dist < 500 and self.stacks == 0 then 
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 1 then
				if Fulldmg1 > hp and dist < 500 then
				Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 2 then
				if Fulldmg2 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 3 then
				if Fulldmg3 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 4 then
				if Fulldmg4 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end		
	-----------------------------------------------------	
			if (getdmg("R", target) + QWEdmg) > hp then
				if dist < 500 and self.stacks == 0 then 
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 1 then
				if (Fulldmg1 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 2 then
				if (Fulldmg2 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 3 then
				if (Fulldmg3 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 4 then
				if (Fulldmg4 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			
	---------------------------------------------------------------
		local Full1 = Fulldmg1 + QWEdmg
		if getdmg("R", target) > target.health or Full1 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 1000 and myHero.pos:DistanceTo(target.pos) > 500 then
				Control.CastSpell(HK_R, target)
					
					
				
			end
		end	
		local Full2 = Fulldmg2 + QWEdmg			
		if getdmg("R", target) > target.health or Full2 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 1500 and myHero.pos:DistanceTo(target.pos) > 1000 then
				Control.CastSpell(HK_R, target)
					
					
				
			end
		end
		local Full3 = Fulldmg3 + QWEdmg			
		if getdmg("R", target) > target.health or Full3 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 2000 and myHero.pos:DistanceTo(target.pos) > 1500 then
				Control.CastSpell(HK_R, target)
					
				
				
			end
		end	
		local Full4 = Fulldmg4 + QWEdmg		
		if getdmg("R", target) > target.health or Full4 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 2500 and myHero.pos:DistanceTo(target.pos) > 2000 then
				Control.CastSpell(HK_R, target)
					
					
			end
		end
	end
end
end
	
function Kassadin:Combo1()
	local target = CurrentTarget(2000)
	if target == nil then return end
	local hp = target.health
	local dist = myHero.pos:DistanceTo(target.pos)
	local qdmg = getdmg("Q", target) 		
	local wdmg = getdmg("W", target) 
	local edmg = getdmg("E", target) 
	local rdmg = getdmg("R", target) 
if IsValid(target) then 

	if Ready(_Q) and self.Menu.Combo.UseQ:Value() then 
		if dist < 650 and qdmg > hp then
			Control.CastSpell(HK_Q, target.pos)
	
		end
	end
	if Ready(_E) and self.Menu.Combo.UseE:Value() then	
		if dist < 600 and edmg > hp and self.passiveTracker >= 1 then	
			Control.CastSpell(HK_E, target)
		
		end
	end

	if Ready(_E) and Ready(_Q) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() then	
		if dist < 600 and (qdmg+edmg) > hp then
	
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
		
		end
	end	
	
	if Ready(_Q) and Ready(_R) and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() then	
		if dist < 500 and (rdmg+qdmg) > hp then
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_Q, target.pos)
				
		end
	end
	if Ready(_E) and Ready(_Q) and Ready(_R) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() then	
		if dist < 500 and (qdmg+edmg+rdmg) > hp then	
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
				
		end
	end
	if Ready(_E) and Ready(_Q) and Ready(_R) and Ready(_W) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() and self.Menu.Combo.UseW:Value() then	
		if dist < 500 and (qdmg+edmg+rdmg+wdmg) > hp then	
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
			Control.CastSpell(HK_W)	
		end
	end
	local Killable = (qdmg > hp and Ready(_Q)), (edmg > hp and Ready(_E)), (rdmg+qdmg > hp and Ready(_Q)), (qdmg+edmg > hp and Ready(_Q) and Ready(_E)), (qdmg+edmg+rdmg > hp and Ready(_Q) and Ready(_E)), (qdmg+edmg+rdmg+wdmg > hp and Ready(_Q) and Ready(_E) and Ready(_W))
	if Ready(_R) and self.Menu.Combo.UseR:Value() then
		if Killable and dist > 650 and dist < 2000 then
			Control.CastSpell(HK_R, target)
				
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

  ["Kassadin"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({65, 95, 125, 155, 185})[level] + 0.7 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({40, 65, 90, 115, 140})[level] + 0.8 * source.ap end},
    {Slot = "W", Stage = 2, DamageType = 2, Damage = function(source, target, level) return 20 + 0.1 * source.ap end},
    {Slot = "E", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 105, 130, 155, 180})[level] + 0.8 * source.ap end},
    {Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({80, 100, 120})[level] + (0.4 * source.ap) + (0.02 * source.maxMana) end},
    {Slot = "R", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({40, 50, 60})[level] + (0.1 * source.ap) + (0.01 * source.maxMana) end},
  },
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


function OnDraw()

	local Spells = myHero:GetSpellData(_Q).level < 1  
	local textPos = myHero.pos:To2D()
	if foundAUnit and Spells then
		Draw.Text("Blockable Spell Found", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
	end
end	


function OnLoad()
	Kassadin()
	

end
	
  

















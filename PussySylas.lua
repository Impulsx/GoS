if myHero.charName ~= "Sylas" then return end
class "Sylas"
local menu = 1

-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussySylas.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussySylas.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussySylas.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussySylas.version"
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
            print("New PussySylas Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end


local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300


local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
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

local function GetImmobileCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range and IsImmobileTarget(hero) then
		count = count + 1
		end
	end
	return count
end

local function IsImmobileTarget(unit)
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10) and buff.count > 0 then
				return true
			end
		end
		return false	
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

local function GetAllyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team == TEAM_ALLY and hero ~= myHero and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end
  

function CountEnemiesNear(origin, range)
	local count = 0
	for i  = 1,Game.HeroCount(i) do
		local enemy = Game.Hero(i)
		if enemy and  HPred:CanTarget(enemy) and HPred:IsInRange(origin, enemy.pos, range) then
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

function Sylas:__init()

  if menu ~= 1 then return end
  menu = 2
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

function GetPercentHP(unit)
	return (unit.health / unit.maxHealth) * 100
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

function GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

function Sylas:EnemiesAround(pos, range)
	local pos = pos.pos
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)
		local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
			N = N + 1
		end
	end
	return N	
end


function Sylas:LoadSpells()
	
	Q = {range = 775, width = 70, delay = 0.25, speed = 1800, collision = false}    
	W = {range = 400, width = 70, delay = 0.25, speed = 20, collision = false}   
	E = {Stage = 1, range = 400, width = 60, delay = 0.25, speed = 1800, collision = false}   
	E = {Stage = 2, range = 800, width = 60, delay = 0.25, speed = 1800, collision = true}   
	R = {range = 800}  

end







function Sylas:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Sylas", name = "PussySylas"})

	
	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})	
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Safe Auto[W]", value = true})
	self.Menu.AutoW:MenuElement({id = "hp", name = "Self Hp", value = 40, min = 1, max = 40, identifier = "%"})	
	
	--AutoR
	self.Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoR"})	
	self.Menu.AutoR:MenuElement({id = "UseR", name = "Auto[R]", value = true})
	self.Menu.AutoR:MenuElement({type = MENU, id = "Target", name = "Target Settings"})
	for i, hero in pairs(GetEnemyHeroes()) do
		self.Menu.AutoR.Target:MenuElement({id = "ult"..hero.charName, name = "Use R on: "..hero.charName, value = true})
		
	end	
		
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Tangle-Barbs", value = true})

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	self.Menu.Harass:MenuElement({type = MENU, id = "LH", name = "LastHit"})	
	self.Menu.Harass.LH:MenuElement({id = "UseQL", name = "LastHit[Q] Minions", value = true, tooltip = "There is no Enemy nearby"})
	self.Menu.Harass.LH:MenuElement({id = "UseQLM", name = "LastHit[Q] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W] Blooming Burst", value = true})	
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQL", name = "LastHit[Q] Blooming Burst", value = true})	
	self.Menu.Clear:MenuElement({id = "UseQLM", name = "LastHit[Q] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})  
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Tangle-Barbs", value = true})	
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 3, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Tangle-Barbs", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})
	self.Menu.ks:MenuElement({id = "PredQ", name = "HitChance[Q] [1]=low [5]=high", value = 1, min = 1, max = 5})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})		
	self.Menu.ks:MenuElement({id = "UseW", name = "[W] Tangle-Barbs", value = true})
	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", name = "Activator"})		
	self.Menu.a:MenuElement({id = "ON", name = "Protobelt", value = true})	
	self.Menu.a:MenuElement({type = MENU, id = "Zhonyas", name = "Zhonya's + StopWatch"})
	self.Menu.a.Zhonyas:MenuElement({id = "ON", name = "Enabled", value = true})
	self.Menu.a.Zhonyas:MenuElement({id = "HP", name = "HP", value = 15, min = 0, max = 100, step = 1, identifier = "%"})
	
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})
end


function Sylas:Tick()
if myHero.dead then return end	

	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		self:Combo()

	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then                
		self:Harass()
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		local TEAM_ALLY = myHero.team
		local TEAM_ENEMY = 300 - myHero.team
		local target = CurrentTarget(1000)
			if target == nil then	
				if minion.team == TEAM_ENEMY and not minion.dead and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then	
					local count = GetMinionCount(225, minion)			
					local hp = minion.health
					local QDmg = getdmg("Q", minion, myHero)
					if self:ValidTarget(minion,800) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 800 and self.Menu.Harass.LH.UseQL:Value() and count >= self.Menu.Harass.LH.UseQLM:Value() and hp <= QDmg then
						Control.CastSpell(HK_Q, minion)
					end	 
				end
			end
		end	

	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
		self:Clear()
		self:JungleClear()
	
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
		--self:LastHit()
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then

	elseif _G.gsoSDK then
	return _G.gsoSDK.Orbwalker:GetMode()
	else
	return GOS.GetMode()
	end
	
self:Activator()
self:KillSteal()	
self:AutoW()
self:AutoR()
self:Proto()
end 

			--Hextech Protobelt
function Sylas:Proto()	
if myHero.dead then return end	
	local target = CurrentTarget(1000)
	if target == nil then return end
	local Protobelt = GetItemSlot(myHero, 3152)
	if self:ValidTarget(target,600) and self.Menu.a.ON:Value() then
		if myHero.pos:DistanceTo(target.pos) < 500 and Protobelt > 0 and Ready(Protobelt) then	
			Control.CastSpell(ItemHotKey[Protobelt], target.pos)

		end
	end
end	 



function Sylas:Activator()
local target = CurrentTarget(1000)
if myHero.dead or target == nil then return end
			--Zhonyas	
	if self.Menu.a.Zhonyas.ON:Value()  then
	local Zhonyas = GetItemSlot(myHero, 3157)
		if Zhonyas > 0 and Ready(Zhonyas) then 
			if myHero.health/myHero.maxHealth <= self.Menu.a.Zhonyas.HP:Value()/100 then
				Control.CastSpell(ItemHotKey[Zhonyas])
			end
		end
	end
			--Stopwatch
	if self.Menu.a.Zhonyas.ON:Value() then
	local Stop = GetItemSlot(myHero, 2420)
		if Stop > 0 and Ready(Stop) then 
			if myHero.health/myHero.maxHealth <= self.Menu.a.Zhonyas.HP:Value()/100 then
				Control.CastSpell(ItemHotKey[Stop])
			end
		end
	end
end

			


function Sylas:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 1050, 3, Draw.Color(255, 225, 255, 10))
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 755, 3, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawing.DrawE:Value()) and Ready(_E) then
    Draw.Circle(myHero, 800, 3, Draw.Color(225, 225, 125, 10))
	end
	if(self.Menu.Drawing.DrawW:Value()) and Ready(_W) then
    Draw.Circle(myHero, 400, 3, Draw.Color(225, 225, 125, 10))
	end
	local target = CurrentTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Drawing.Kill:Value() and not target.dead then
	local hp = target.health	
		if Ready(_Q) and getdmg("Q", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_E) and getdmg("E", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
		if Ready(_E) and Ready(_Q) and (getdmg("E", target) + getdmg("Q", target)) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end	
	end
end
       
function Sylas:ValidTarget(unit,range) 
  return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal 
end


function Sylas:AutoR()
local target = CurrentTarget(1050)     	
if target == nil then return end
	if self:ValidTarget(target,1050) and self.Menu.AutoR.UseR:Value() and self.Menu.AutoR.Target["ult"..target.charName]:Value() and Ready(_R) then		
		if myHero.pos:DistanceTo(target.pos) <= 1050 then
			Control.CastSpell(HK_R, target)
		end
	end
end


function Sylas:AutoW()
local target = CurrentTarget(1000)
if target == nil then return end
   if self.Menu.AutoW.UseW:Value() and Ready(_W) then
        if myHero.pos:DistanceTo(target.pos) <= 400  and myHero.health/myHero.maxHealth <= self.Menu.AutoW.hp:Value()/100 then
            Control.CastSpell(HK_W, target)
        end
    end
end

function Sylas:KillSteal()
if myHero.dead then return end	
	local target = CurrentTarget(2000)     	
	if target == nil then return end
	local hp = target.health
	local QDmg = getdmg("Q", target, myHero)
	local WDmg = getdmg("W", target, myHero)
	if self:ValidTarget(target,1100) then
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.ks.UseQ:Value() and Ready(_Q) and hitRate and hitRate >= self.Menu.ks.PredQ:Value() then
			if QDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 775 then
				Control.CastSpell(HK_Q, aimPosition)
			end
		end
		if self.Menu.ks.UseW:Value() and Ready(_W) then
			if WDmg >= hp and myHero.pos:DistanceTo(target.pos) <= 400 then
				Control.CastSpell(HK_W, target)
			end
		end					
	end
end	





function Sylas:Combo()
	local target = CurrentTarget(1300)
	if target == nil then return end
	if self:ValidTarget(target,1300) then
		if self.Menu.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1200 and myHero.pos:DistanceTo(target.pos) >= 400 then			
			local EPos = myHero.pos:Shortened(target.pos - 800)
			Control.SetCursorPos(EPos)
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
		if myHero.pos:DistanceTo(target.pos) <= 800 then	
			Control.CastSpell(HK_E, target.pos)
		end
		end
		if self.Menu.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_E, target)	
			Control.CastSpell(HK_E, target)
		end	
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 775 then 	
				Control.CastSpell(HK_Q, target)
		end
		if self.Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_W, target)
		end
	end
end

	
		

function Sylas:Harass()	
	local target = CurrentTarget(1300)
	if target == nil then return end
	if self:ValidTarget(target,1300) and(myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then
		if self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1200 and myHero.pos:DistanceTo(target.pos) >= 400 then			
			local EPos = myHero.pos:Shortened(target.pos - 800)
			Control.SetCursorPos(EPos)
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
		if myHero.pos:DistanceTo(target.pos) <= 800 then	
			Control.CastSpell(HK_E, target)
		end
		end
		if self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_E, target)	
			Control.CastSpell(HK_E, target)
		end			
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 775 then 	
				Control.CastSpell(HK_Q, target)
		end
		if self.Menu.Harass.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 400 then
			Control.CastSpell(HK_W, target)
		end
	end
end



function Sylas:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local TEAM_ALLY = myHero.team
	local TEAM_ENEMY = 300 - myHero.team

		if minion.team == TEAM_ENEMY and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then			
		local count = GetMinionCount(225, minion)			
			if self:ValidTarget(minion,400) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 400 and self.Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E, minion)
				Control.CastSpell(HK_E, minion)
			end 			
			if self:ValidTarget(minion,775) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 755 and self.Menu.Clear.UseQL:Value() and count >= self.Menu.Clear.UseQLM:Value() then
				Control.CastSpell(HK_Q, minion)
			end	
			if self:ValidTarget(minion,1300) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1200 and myHero.pos:DistanceTo(minion.pos) >= 400 and self.Menu.Clear.UseE:Value() then
				local EPos = myHero.pos:Shortened(minion.pos - 800)
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
			if myHero.pos:DistanceTo(minion.pos) <= 800 then	
				Control.CastSpell(HK_E, minion)
			end
			end
			if self:ValidTarget(minion,400) and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 400 and self.Menu.Clear.UseW:Value() then
				Control.CastSpell(HK_W, minion)
			end  
		end
	end
end

function Sylas:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	local TEAM_JUNGLE = 300
		if minion.team == TEAM_JUNGLE and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if self:ValidTarget(minion,400) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 400 and self.Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion)
				Control.CastSpell(HK_E, minion)
			end			
			if self:ValidTarget(minion,775) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 775 and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion)
			end
			if self:ValidTarget(minion,1300) and Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1200 and myHero.pos:DistanceTo(minion.pos) >= 400 and self.Menu.JClear.UseE:Value() then
				local EPos = myHero.pos:Shortened(minion.pos - 800)
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
			if myHero.pos:DistanceTo(minion.pos) <= 800 then				
				Control.CastSpell(HK_E, minion)
			end
			end
			if self:ValidTarget(minion,400) and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 400 and self.Menu.JClear.UseW:Value() then
				Control.CastSpell(HK_W, minion)
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

  ["Sylas"] = {
    {Slot = "Q", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({45, 70, 95, 120, 145})[level] + 0.6 * source.ap end},
    {Slot = "Q", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({24, 38, 52, 66, 75})[level] + 0.5 * source.ap end},
    {Slot = "W", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({90, 135, 180, 225, 270})[level] + 0.825 * source.ap end},																										
	{Slot = "E", Stage = 2, DamageType = 2, Damage = function(source, target, level) return ({60, 65, 80, 95, 180})[level] + 0.4 * source.ap end},
	{Slot = "R", Stage = 1, DamageType = 2, Damage = function(source, target, level) return ({60, 65, 80, 95, 180})[level] + 0.4 * source.ap end}     
     --R Ratios conversion rates: (+0.7%) per (+1% total), (+0.5%) per (+1% bonus)
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

-----------------------------------------------------------------------------------------------------------------------------------


--[[
		GENERAL API
	
	HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
		Usage Purpose
			Wrapper method to find an enemy who can be very reliably hit. Includes hourglas, teleport, blink, dash, CC and more.
			Returns target, aimPosition
		Param Description
			Source: Where the spell will be cast from
			Range: How far away to search for targets (max spell range)
			Delay: How long it will take for the spell to cast
			Speed: How fast the spell will travel
			Radius: How wide the spell is for hitbox calculations
			TimingAccuracy: General accuracy setting. This is how long after a hourglass/teleport/etc we can allow the spell to hit. I suggest ~0.25 seconds
			CheckCollision: Determines if a linear skillshot can be body blocked by minions or other heroes
			
	HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist)
		Usage Purpose
			Finds any target in range who can be hit with at least 'minimumHitChance' of accuracy. Used as a wrapper for HPred:GetHitchance
			Returns target, aimPosition
		Param Description
			Source: Where the spell will be cast from
			Range: How far away to search for targets (max spell range)
			Delay: How long it will take for the spell to cast
			Speed: How fast the spell will travel
			Radius: How wide the spell is for hitbox calculations
			CheckCollision: Determines if a linear skillshot can be body blocked by minions or other heroes
			MinimumHitChance: How confident must we be that the target can be hit for the target to qualify. Recommend accuracy of 3 on almost all skills
				-1 	=	Invalid Target
				1	=	Standard accuracy
				2	=	Target is standing still or has changed movement path within the past 0.25 seconds
				3	=	The target is auto attacking and our spell will give them little time to react in order to dodge
				4	=	The target is using a spell and our spell will give them virtually no time in order to dodge
				5	=	The target should not be able to dodge without using movement skills
				
	HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision)
		Usage Purpose
			Determines the hitchance of a spell on a specified target and where to aim the spell
			Returns hitChance, aimPosition
		Param Description
			Source: Where the spell will be cast from
			Target: What entity are we trying to hit
			Range: How far away to search for targets (max spell range)
			Delay: How long it will take for the spell to cast
			Speed: How fast the spell will travel
			Radius: How wide the spell is for hitbox calculations
			CheckCollision: Determines if a linear skillshot can be body blocked by minions or other heroes
			
	HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
		Usage Purpose
			Determines how many targets will be hit if we cast a linear spell at a specified location - Can specify if the targets are enemies or allies
			Returns total target count
			
			
	HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
		UsagePurpose
			Simplified version of GetReliableTarget - will only check for hourglass, revive, teleport and CCd targets. Useful for high priority skills where you don't want to cast it every time an enemy dashes
			
]]



class "HPred"
local _atan = math.atan2
local _pi = math.pi
local _min = math.min
local _abs = math.abs
local _sqrt = math.sqrt
local _huge = math.huge
local _insert = table.insert
local _sort = table.sort
local _find = string.find
local _sub = string.sub
local _len = string.len

local LocalDrawLine					= Draw.Line;
local LocalDrawColor				= Draw.Color;
local LocalDrawCircle				= Draw.Circle;
local LocalDrawText					= Draw.Text;
local LocalControlIsKeyDown			= Control.IsKeyDown;
local LocalControlMouseEvent		= Control.mouse_event;
local LocalControlSetCursorPos		= Control.SetCursorPos;
local LocalControlKeyUp				= Control.KeyUp;
local LocalControlKeyDown			= Control.KeyDown;
local LocalGameCanUseSpell			= Game.CanUseSpell;
local LocalGameLatency				= Game.Latency;
local LocalGameTimer				= Game.Timer;
local LocalGameHeroCount 			= Game.HeroCount;
local LocalGameHero 				= Game.Hero;
local LocalGameMinionCount 			= Game.MinionCount;
local LocalGameMinion 				= Game.Minion;
local LocalGameTurretCount 			= Game.TurretCount;
local LocalGameTurret 				= Game.Turret;
local LocalGameWardCount 			= Game.WardCount;
local LocalGameWard 				= Game.Ward;
local LocalGameObjectCount 			= Game.ObjectCount;
local LocalGameObject				= Game.Object;
local LocalGameMissileCount 		= Game.MissileCount;
local LocalGameMissile				= Game.Missile;
local LocalGameParticleCount 		= Game.ParticleCount;
local LocalGameParticle				= Game.Particle;
local LocalGameIsChatOpen			= Game.IsChatOpen;
local LocalGameIsOnTop				= Game.IsOnTop;
	
local _tickFrequency = .2
local _nextTick = Game.Timer()
local _reviveLookupTable = 
	{ 
		["LifeAura.troy"] = 4, 
		["ZileanBase_R_Buf.troy"] = 3,
		["Aatrox_Base_Passive_Death_Activate"] = 3
		
		--TwistedFate_Base_R_Gatemarker_Red
			--String match would be ideal.... could be different in other skins
	}

--Stores a collection of spells that will cause a character to blink
	--Ground targeted spells go towards mouse castPos with a maximum range
	--Hero/Minion targeted spells have a direction type to determine where we will land relative to our target (in front of, behind, etc)
	
--Key = Spell name
--Value = range a spell can travel, OR a targeted end position type, OR a list of particles the spell can teleport to	
local _blinkSpellLookupTable = 
	{ 
		["EzrealArcaneShift"] = 475, 
		["RiftWalk"] = 500,
		
		--Ekko and other similar blinks end up between their start pos and target pos (in front of their target relatively speaking)
		["EkkoEAttack"] = 0,
		["AlphaStrike"] = 0,
		
		--Katarina E ends on the side of her target closest to where her mouse was... 
		["KatarinaE"] = -255,
		
		--Katarina can target a dagger to teleport directly to it: Each skin has a different particle name. This should cover all of them.
		["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, 
	}

local _blinkLookupTable = 
	{ 
		"global_ss_flash_02.troy",
		"Lissandra_Base_E_Arrival.troy",
		"LeBlanc_Base_W_return_activation.troy"
		--TODO: Check if liss/leblanc have diff skill versions. MOST likely dont but worth checking for completion sake
		
		--Zed uses 'switch shadows'... It will require some special checks to choose the shadow he's going TO not from...
		--Shaco deceive no longer has any particles where you jump to so it cant be tracked (no spell data or particles showing path)
		
	}

local _cachedBlinks = {}
local _cachedRevives = {}
local _cachedTeleports = {}

--Cache of all TARGETED missiles currently running
local _cachedMissiles = {}
local _incomingDamage = {}

--Cache of active enemy windwalls so we can calculate it when dealing with collision checks
local _windwall
local _windwallStartPos
local _windwallWidth

local _OnVision = {}
function HPred:OnVision(unit)
	if unit == nil or type(unit) ~= "userdata" then return end
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {visible = unit.visible , tick = GetTickCount(), pos = unit.pos } end
	if _OnVision[unit.networkID].visible == true and not unit.visible then _OnVision[unit.networkID].visible = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].visible == false and unit.visible then _OnVision[unit.networkID].visible = true _OnVision[unit.networkID].tick = GetTickCount() _OnVision[unit.networkID].pos = unit.pos end
	return _OnVision[unit.networkID]
end

--This must be called manually - It's not on by default because we've tracked down most of the freeze issues to this.
function HPred:Tick()
	
	
	--Update missile cache
	--DISABLED UNTIL LATER.
	--self:CacheMissiles()
	
	--Limit how often tick logic runs
	if _nextTick > Game.Timer() then return end
	_nextTick = Game.Timer() + _tickFrequency
	
	--Update hero movement history	
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			if t.isEnemy then
				HPred:OnVision(t)
			end
		end
	end
	
	--Do not run rest of logic until freeze issues are fully tracked down
	if true then return end
	
	
	--Remove old cached teleports	
	for _, teleport in pairs(_cachedTeleports) do
		if teleport and Game.Timer() > teleport.expireTime + .5 then
			_cachedTeleports[_] = nil
		end
	end	
	
	--Update teleport cache
	HPred:CacheTeleports()	
	
	
	--Record windwall
	HPred:CacheParticles()
	
	--Remove old cached revives
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	--Remove old cached blinks
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		--Record revives
		if particle and not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then
			_cachedRevives[particle.networkID] = {}
			_cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedRevives[particle.networkID]["target"] = target
				_cachedRevives[particle.networkID]["pos"] = target.pos
				_cachedRevives[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
		
		--Record blinks
		if particle and not _cachedBlinks[particle.networkID] and  _blinkLookupTable[particle.name] then
			_cachedBlinks[particle.networkID] = {}
			_cachedBlinks[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedBlinks[particle.networkID]["target"] = target
				_cachedBlinks[particle.networkID]["pos"] = target.pos
				_cachedBlinks[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
	end
	
end

function HPred:GetEnemyNexusPosition()
	--This is slightly wrong. It represents fountain not the nexus. Fix later.
	if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end
end


function HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
end


function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--TODO: Target whitelist. This will target anyone which is definitely not what we want
	--For now we can handle in the champ script. That will cause issues with multiple people in range who are goood targets though.
	
	
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get channeling enemies
	--local target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	--	if target and aimPosition then
	--	return target, aimPosition
	--end
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get instant dash enemies
	local target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get dashing enemies
	local target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get blink targets
	local target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
end

--Will return how many allies or enemies will be hit by a linear spell based on current waypoint data.
function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
	local targetCount = 0
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then
			
			local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) * (t.boundingRadius + width)) then
				targetCount = targetCount + 1
			end
		end
	end
	return targetCount
end

--Will return the valid target who has the highest hit chance and meets all conditions (minHitChance, whitelist check, etc)
function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist, isLine)
	local _validTargets = {}
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)		
		if t and self:CanTarget(t, true) and (not whitelist or whitelist[t.charName]) then
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision, isLine)		
			if hitChance >= minimumHitChance then
				_insert(_validTargets, {aimPosition,hitChance, hitChance * 100 + self:CalculateMagicDamage(t, 400)})
			end
		end
	end	
	_sort(_validTargets, function( a, b ) return a[3] >b[3] end)	
	if #_validTargets > 0 then	
		return _validTargets[1][2], _validTargets[1][1]
	end
end

function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision, isLine)

	if isLine == nil and checkCollision then
		isLine = true
	end
	
	local hitChance = 1
	local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed)	
	local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed)
	local reactionTime = self:PredictReactionTime(target, .1, isLine)
	
	--Check if they are walking the same path as the line or very close to it
	if isLine then
		local pathVector = aimPosition - target.pos
		local castVector = (aimPosition - myHero.pos):Normalized()
		if pathVector.x + pathVector.z ~= 0 then
			pathVector = pathVector:Normalized()
			if pathVector:DotProduct(castVector) < -.85 or pathVector:DotProduct(castVector) > .85 then
				if speed > 3000 then
					reactionTime = reactionTime + .25
				else
					reactionTime = reactionTime + .15
				end
			end
		end
	end			

	--If they are standing still give a higher accuracy because they have to take actions to react to it
	if not target.pathing or not target.pathing.hasMovePath then
		hitChancevisionData = 2
	end	
	
	
	local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
	--Our spell is so wide or the target so slow or their reaction time is such that the spell will be nearly impossible to avoid
	if movementRadius - target.boundingRadius <= radius /2 then
		origin,movementRadius = self:UnitMovementBounds(target, interceptTime, 0)
		if movementRadius - target.boundingRadius <= radius /2 then
			hitChance = 4
		else		
			hitChance = 3
		end
	end	
	
	--If they are casting a spell then the accuracy will be fairly high. if the windup is longer than our delay then it's quite likely to hit. 
	--Ideally we would predict where they will go AFTER the spell finishes but that's beyond the scope of this prediction
	if target.activeSpell and target.activeSpell.valid then
		if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then
			hitChance = 5
		else			
			hitChance = 3
		end
	end
	
	local visionData = HPred:OnVision(target)
	if visionData and visionData.visible == false then
		local hiddenTime = visionData.tick -GetTickCount()
		if hiddenTime < -1000 then
			hitChance = -1
		else
			local targetSpeed = self:GetTargetMS(target)
			local unitPos = target.pos + Vector(target.pos,target.posTo):Normalized() * ((GetTickCount() - visionData.tick)/1000 * targetSpeed)
			local aimPosition = unitPos + Vector(target.pos,target.posTo):Normalized() * (targetSpeed * (delay + (self:GetDistance(myHero.pos,unitPos)/speed)))
			if self:GetDistance(target.pos,aimPosition) > self:GetDistance(target.pos,target.posTo) then aimPosition = target.posTo end
			hitChance = _min(hitChance, 2)
		end
	end
	
	--Check for out of range
	if not self:IsInRange(source, aimPosition, range) then
		hitChance = -1
	end
	
	--Check minion block
	if hitChance > 0 and checkCollision then
		if self:IsWindwallBlocking(source, aimPosition) then
			hitChance = -1		
		elseif self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then
			hitChance = -1
		end
	end
	
	return hitChance, aimPosition
end

function HPred:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	
	--If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end	
	return reactionTime
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)

	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if self:IsInRange(source, dashEndPosition, range) then				
				--The dash ends within range of our skill. We now need to find if our spell can connect with them very close to the time their dash will end
				local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(source, dashEndPosition, delay, speed)
				local deltaInterceptTime =skillInterceptTime - dashTimeRemaining
				if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then
					target = t
					aimPosition = dashEndPosition
					return target, aimPosition
				end
			end			
		end
	end
end

function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy then		
			local success, timeRemaining = self:HasBuff(t, "zhonyasringshield")
			if success then
				local spellInterceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
				local deltaInterceptTime = spellInterceptTime - timeRemaining
				if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = t
					aimPosition = t.pos
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for _, revive in pairs(_cachedRevives) do	
		if revive.isEnemy then
			local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
			if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then
				target = revive.target
				aimPosition = revive.pos
				return target, aimPosition
			end
		end
	end	
end

function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then
			local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer()
			if windupRemaining > 0 then
				local endPos
				local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
				if type(blinkRange) == "table" then
					--Find the nearest matching particle to our mouse
					--local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange)
					--if target and distance < 250 then					
					--	endPos = target.pos		
					--end
				elseif blinkRange > 0 then
					endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)					
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * _min(self:GetDistance(t.activeSpell.startPos,endPos), range)
				else
					local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
					if blinkTarget then				
						local offsetDirection						
						
						--We will land in front of our target relative to our starting position
						if blinkRange == 0 then				

							if t.activeSpell.name ==  "AlphaStrike" then
								windupRemaining = windupRemaining + .75
								--TODO: Boost the windup time by the number of targets alpha will hit. Need to calculate the exact times this is just rough testing right now
							end						
							offsetDirection = (blinkTarget.pos - t.pos):Normalized()
						--We will land behind our target relative to our starting position
						elseif blinkRange == -1 then						
							offsetDirection = (t.pos-blinkTarget.pos):Normalized()
						--They can choose which side of target to come out on , there is no way currently to read this data so we will only use this calculation if the spell radius is large
						elseif blinkRange == -255 then
							if radius > 250 then
								endPos = blinkTarget.pos
							end							
						end
						
						if offsetDirection then
							endPos = blinkTarget.pos - offsetDirection * blinkTarget.boundingRadius
						end
						
					end
				end	
				
				local interceptTime = self:GetSpellInterceptTime(source, endPos, delay,speed)
				local deltaInterceptTime = interceptTime - windupRemaining
				if self:IsInRange(source, endPos, range) and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
					target = t
					aimPosition = endPos
					return target,aimPosition					
				end
			end
		end
	end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	local target
	local aimPosition
	for _, particle in pairs(_cachedBlinks) do
		if particle  and self:IsInRange(source, particle.pos, range) then
			local t = particle.target
			local pPos = particle.pos
			if t and t.isEnemy and (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
				target = t
				aimPosition = pPos
				return target,aimPosition
			end
		end		
	end
end

function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if self:CanTarget(t) and self:IsInRange(source, t.pos, range) and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos	
				return target, aimPosition
			end
		end
	end
end

function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTarget(t) and self:IsInRange(source, t.pos, range) then
			local immobileTime = self:GetImmobileTime(t)
			
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos
				return target, aimPosition
			end
		end
	end
end

function HPred:CacheTeleports()
	--Get enemies who are teleporting to towers
	for i = 1, LocalGameTurretCount() do
		local turret = LocalGameTurret(i);
		if turret and turret.isEnemy and not _cachedTeleports[turret.networkID] then
			local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
			if hasBuff then
				self:RecordTeleport(turret, self:GetTeleportOffset(turret.pos,223.31),expiresAt)
			end
		end
	end	
	
	--Get enemies who are teleporting to wards	
	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.isEnemy and not _cachedTeleports[ward.networkID] then
			local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
			if hasBuff then
				self:RecordTeleport(ward, self:GetTeleportOffset(ward.pos,100.01),expiresAt)
			end
		end
	end
	
	--Get enemies who are teleporting to minions
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion and minion.isEnemy and not _cachedTeleports[minion.networkID] then
			local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
			if hasBuff then
				self:RecordTeleport(minion, self:GetTeleportOffset(minion.pos,143.25),expiresAt)
			end
		end
	end	
end

function HPred:RecordTeleport(target, aimPos, endTime)
	_cachedTeleports[target.networkID] = {}
	_cachedTeleports[target.networkID]["target"] = target
	_cachedTeleports[target.networkID]["aimPos"] = aimPos
	_cachedTeleports[target.networkID]["expireTime"] = endTime + Game.Timer()
end


function HPred:CalculateIncomingDamage()
	_incomingDamage = {}
	local currentTime = Game.Timer()
	for _, missile in pairs(_cachedMissiles) do
		if missile then 
			local dist = self:GetDistance(missile.data.pos, missile.target.pos)			
			if missile.name == "" or currentTime >= missile.timeout or dist < missile.target.boundingRadius then
				_cachedMissiles[_] = nil
			else
				if not _incomingDamage[missile.target.networkID] then
					_incomingDamage[missile.target.networkID] = missile.damage
				else
					_incomingDamage[missile.target.networkID] = _incomingDamage[missile.target.networkID] + missile.damage
				end
			end
		end
	end	
end

function HPred:GetIncomingDamage(target)
	local damage = 0
	if _incomingDamage[target.networkID] then
		damage = _incomingDamage[target.networkID]
	end
	return damage
end


local _maxCacheRange = 3000

--Right now only used to cache enemy windwalls
function HPred:CacheParticles()	
	if _windwall and _windwall.name == "" then
		_windwall = nil
	end
	
	for i = 1, LocalGameParticleCount() do
		local particle = LocalGameParticle(i)		
		if particle and self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then			
			if _find(particle.name, "W_windwall%d") and not _windwall then
				--We don't care about ally windwalls for now
				local owner =  self:GetObjectByHandle(particle.handle)
				if owner and owner.isEnemy then
					_windwall = particle
					_windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)				
					
					local index = _len(particle.name) - 5
					local spellLevel = _sub(particle.name, index, index) -1
					--Simple fix
					if type(spellLevel) ~= "number" then
						spellLevel = 1
					end
					_windwallWidth = 150 + spellLevel * 25					
				end
			end
		end
	end
end

function HPred:CacheMissiles()
	local currentTime = Game.Timer()
	for i = 1, LocalGameMissileCount() do
		local missile = LocalGameMissile(i)
		if missile and not _cachedMissiles[missile.networkID] and missile.missileData then
			--Handle targeted missiles
			if missile.missileData.target and missile.missileData.owner then
				local missileName = missile.missileData.name
				local owner =  self:GetObjectByHandle(missile.missileData.owner)	
				local target =  self:GetObjectByHandle(missile.missileData.target)		
				if owner and target and _find(target.type, "Hero") then			
					--The missile is an auto attack of some sort that is targeting a player	
					if (_find(missileName, "BasicAttack") or _find(missileName, "CritAttack")) then
						--Cache it all and update the count
						_cachedMissiles[missile.networkID] = {}
						_cachedMissiles[missile.networkID].target = target
						_cachedMissiles[missile.networkID].data = missile
						_cachedMissiles[missile.networkID].danger = 1
						_cachedMissiles[missile.networkID].timeout = currentTime + 1.5
						
						local damage = owner.totalDamage
						if _find(missileName, "CritAttack") then
							--Leave it rough we're not that concerned
							damage = damage * 1.5
						end						
						_cachedMissiles[missile.networkID].damage = self:CalculatePhysicalDamage(target, damage)
					end
				end
			end
		end
	end
end

function HPred:CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

function HPred:CalculateMagicDamage(target, damage)			
	local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
	local damageReduction = 100 / ( 100 + targetMR)
	if targetMR < 0 then
		damageReduction = 2 - (100 / (100 - targetMR))
	end		
	damage = damage * damageReduction
	
	return damage
end


function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)

	local target
	local aimPosition
	for _, teleport in pairs(_cachedTeleports) do
		if teleport.expireTime > Game.Timer() and self:IsInRange(source,teleport.aimPos, range) then			
			local spellInterceptTime = self:GetSpellInterceptTime(source, teleport.aimPos, delay, speed)
			local teleportRemaining = teleport.expireTime - Game.Timer()
			if spellInterceptTime > teleportRemaining and spellInterceptTime - teleportRemaining <= timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, teleport.aimPos, delay, speed, radius)) then								
				target = teleport.target
				aimPosition = teleport.aimPos
				return target, aimPosition
			end
		end
	end		
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:Angle(A, B)
	local deltaPos = A - B
	local angle = _atan(deltaPos.x, deltaPos.z) *  180 / _pi	
	if angle < 0 then angle = angle + 360 end
	return angle
end

--Returns where the unit will be when the delay has passed given current pathing information. This assumes the target makes NO CHANGES during the delay.
function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			--This node of the path will be completed before the delay has finished. Move on to the next node if one remains
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:IsChannelling(target, interceptTime)
	if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then
		return true
	end
end

function HPred:HasBuff(target, buffName, minimumDuration)
	local duration = minimumDuration
	if not minimumDuration then
		duration = 0
	end
	local durationRemaining
	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		if buff.duration > duration and buff.name == buffName then
			durationRemaining = buff.duration
			return true, durationRemaining
		end
	end
end

--Moves an origin towards the enemy team nexus by magnitude
function HPred:GetTeleportOffset(origin, magnitude)
	local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude
	return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end

--Checks if a target can be targeted by abilities or auto attacks currently.
--CanTarget(target)
	--target : gameObject we are trying to hit
function HPred:CanTarget(target, allowInvisible)
	return target.isEnemy and target.alive and target.health > 0  and (allowInvisible or target.visible) and target.isTargetable
end

--Derp: dont want to fuck with the isEnemy checks elsewhere. This will just let us know if the target can actually be hit by something even if its an ally
function HPred:CanTargetALL(target)
	return target.alive and target.health > 0 and target.visible and target.isTargetable
end

--Returns a position and radius in which the target could potentially move before the delay ends. ReactionTime defines how quick we expect the target to be able to change their current path
function HPred:UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = self:PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = self:GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

--Returns how long (in seconds) the target will be unable to move from their current location
function HPred:GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			duration = buff.duration
		end
	end
	return duration		
end

--Returns how long (in seconds) the target will be slowed for
function HPred:GetSlowedTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end

--Returns all existing path nodes
function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

--Finds any game object with the correct handle to match (hero, minion, wards on either team)
function HPred:GetObjectByHandle(handle)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and minion.handle == handle then
			target = minion
			return target
		end
	end
	
	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.handle == handle then
			target = ward
			return target
		end
	end
	
	for i = 1, LocalGameTurretCount() do 
		local turret = LocalGameTurret(i)
		if turret and turret.handle == handle then
			target = turret
			return target
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and particle.handle == handle then
			target = particle
			return target
		end
	end
end

function HPred:GetHeroByPosition(position)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetObjectByPosition(position)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local enemy = LocalGameMinion(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameWardCount() do
		local enemy = LocalGameWard(i);
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local enemy = LocalGameParticle(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
end

--Finds the closest particle to the origin that is contained in the names array
function HPred:GetNearestParticleByNames(origin, names)
	local target
	local distance = 999999
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle then 
			local d = self:GetDistance(origin, particle.pos)
			if d < distance then
				distance = d
				target = particle
			end
		end
	end
	return target, distance
end

--Returns the total distance of our current path so we can calculate how long it will take to complete
function HPred:GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + self:GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end


--I know this isn't efficient but it works accurately... Leaving it for now.
function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
		
	if not frequency then
		frequency = radius
	end
	local directionVector = (endPos - origin):Normalized()
	local checkCount = self:GetDistance(origin, endPos) / frequency
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * frequency
		local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed
		if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end


function HPred:IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and self:CanTarget(minion) and self:IsInRange(minion.pos, location, maxDistance) then
			local predictedPosition = self:PredictUnitPosition(minion, delay)
			if self:IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
				return true
			end
		end
	end
	return false
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

--Determines if there is a windwall between the source and target pos. 
function HPred:IsWindwallBlocking(source, target)
	if _windwall then
		local windwallFacing = (_windwallStartPos-_windwall.pos):Normalized()
		return self:DoLineSegmentsIntersect(source, target, _windwall.pos + windwallFacing:Perpendicular() * _windwallWidth, _windwall.pos + windwallFacing:Perpendicular2() * _windwallWidth)
	end	
	return false
end
--Returns if two line segments cross eachother. AB is segment 1, CD is segment 2.
function HPred:DoLineSegmentsIntersect(A, B, C, D)

	local o1 = self:GetOrientation(A, B, C)
	local o2 = self:GetOrientation(A, B, D)
	local o3 = self:GetOrientation(C, D, A)
	local o4 = self:GetOrientation(C, D, B)
	
	if o1 ~= o2 and o3 ~= o4 then
		return true
	end
	
	if o1 == 0 and self:IsOnSegment(A, C, B) then return true end
	if o2 == 0 and self:IsOnSegment(A, D, B) then return true end
	if o3 == 0 and self:IsOnSegment(C, A, D) then return true end
	if o4 == 0 and self:IsOnSegment(C, B, D) then return true end
	
	return false
end

--Determines the orientation of ordered triplet
--0 = Colinear
--1 = Clockwise
--2 = CounterClockwise
function HPred:GetOrientation(A,B,C)
	local val = (B.z - A.z) * (C.x - B.x) -
		(B.x - A.x) * (C.z - B.z)
	if val == 0 then
		return 0
	elseif val > 0 then
		return 1
	else
		return 2
	end
	
end

function HPred:IsOnSegment(A, B, C)
	return B.x <= _max(A.x, C.x) and 
		B.x >= _min(A.x, C.x) and
		B.z <= _max(A.z, C.z) and
		B.z >= _min(A.z, C.z)
end

--Gets the slope between two vectors. Ignores Y because it is non-needed height data. Its all 2d math.
function HPred:GetSlope(A, B)
	return (B.z - A.z) / (B.x - A.x)
end

function HPred:GetEnemyByName(name)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.isEnemy and enemy.charName == name then
			target = enemy
			return target
		end
	end
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	local deltaAngle = _abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
	if deltaAngle < angle and self:IsInRange(origin,target,range) then
		return true
	end
end

function HPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return _huge
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) 
end

function HPred:IsInRange(p1, p2, range)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined IsInRange target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return false
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range 
end

function HPred:GetDistance(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistance target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return _huge
	end
	return _sqrt(self:GetDistanceSqr(p1, p2))
end
	


function OnLoad()
	Sylas()
end
	
  

















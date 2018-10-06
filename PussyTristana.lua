local Heroes = {"Tristana"}



local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}

-- [ AutoUpdate ]
do
    
    local Version = 0.02
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyTristana.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyTristana.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyTristana.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyTristana.version"
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
            Draw.Text("New PussyTristana Version Press 2x F6", 50, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end


local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}


if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
	PrintChat("TPred library loaded")
end
	if FileExist(COMMON_PATH .. "Collision.lua") then
	require 'Collision'

end
	if FileExist(COMMON_PATH .. "DamageLib.lua") then
	require 'DamageLib'

end

function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end



class "Tristana"



local HeroIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/0/06/TristanaSquare.png"

function Tristana:LoadSpells()

	W = {Range = 900, Width = 250, Delay = 0.25, Speed = 1100, Collision = false, aoe = true, Type = "circle"}
	E = {Range = 517 + (8 * myHero.levelData.lvl), Width = 75, Delay = 0.25, Speed = 2400, Collision = false, aoe = false, Type = "line"}
	R = {Range = 517 + (8 * myHero.levelData.lvl), Width = 0, Delay = 0.25, Speed = 1000, Collision = false, aoe = false, Type = "line"}

end

function Tristana:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Tristana", name = "PussyTristana", leftIcon = HeroIcon})
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "AutoQ when Explosive Charge", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Combo:MenuElement({id = "UseR", name = "(R)Finisher", tooltip = "is(R)Dmg+(E)Dmg+(E)StackDmg > TargetHP than Ult", value = true})
	self.Menu.Combo:MenuElement({id = "R", name = "R", type = MENU})
	for i, hero in pairs(self:GetEnemyHeroes()) do
	self.Menu.Combo.R:MenuElement({id = "RR"..hero.charName, name = "KS R on: "..hero.charName, value = true})
	end	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	self.Menu:MenuElement({id = "gap", name = "Gapclose", type = MENU})
	self.Menu.gap:MenuElement({id = "UseR", name = "Ultimate Gapclose", value = true})
	self.Menu.gap:MenuElement({id = "gapkey", name = "Gapclose key", key = string.byte("T")})
	

	
	self.Menu:MenuElement({id = "Blitz", name = "AntiBlitzGrab", type = MENU})
	self.Menu.Blitz:MenuElement({id = "UseW", name = "AutoW", value = true})
	
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "AutoQ when Explosive Charge", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({id = "MS", name = "Mercurial Scimittar", type = MENU})
	self.Menu.MS:MenuElement({id = "UseMS", name = "Auto AntiCC", value = true})
	
	
	self.Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	
	--W
	self.Menu.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU})
    self.Menu.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--E
	self.Menu.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU})
    self.Menu.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    self.Menu.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--R
	self.Menu.Drawings:MenuElement({id = "R", name = "Draw R range", type = MENU})
    self.Menu.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = true})
    self.Menu.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	

	self.Menu.Drawings:MenuElement({id = "DrawR", name = "Draw Kill Ulti Gapclose ", value = true})


	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5,tooltip = "", identifier = ""})
	

end


function Tristana:__init()
	
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
	else
		orbwalkername = "Orbwalker not found"
	end
end

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function Tristana:Tick()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true then return end
	if self.Menu.Combo.comboActive:Value() then
		self:Combo()
		self:ComboE()
		self:UseBotrk()
		self:ComboRKS()
		self:Finisher()
	end	
	if self.Menu.Harass.harassActive:Value() then
		self:HarassQ()
		self:HarassE()
	end
	if self.Menu.Drawings.DrawR:Value() then
		self:DrawGapR()
	end
	if self.Menu.Blitz.UseW:Value() then
		self:AntiBlitz()
	end
	if self.Menu.gap.gapkey:Value() then
		self:GapcloseR()
		self:AutoR()

	end
	self:UseMS()
end


function GotBuff(unit,name)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name and buff.name:lower() == name:lower() and buff.count > 0 then 
			return buff.count
		end
	end
	return 0
end

function Tristana:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function GetPercentHP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.health/unit.maxHealth
end

function Tristana:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Tristana:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Tristana:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function EnableMovement()
	SetMovement(true)
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

function Tristana:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 550 then
        return true
        end
    	end
    	return false
end

function Tristana:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Tristana:EnemyInRange(range)
	local count = 0
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

function CalculatePhysicalDamage(target, damage)

	if target and damage then
		local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
		local damageReduction = 100 / ( 100 + targetArmor)
		if targetArmor < 0 then
			damageReduction = 2 - (100 / (100 - targetArmor))
		end		
		damage = damage * damageReduction	
		return damage
	end
	return 0
end

function CalculateMagicalDamage(target, damage)
	
	if target and damage then	
		local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
		local damageReduction = 100 / ( 100 + targetMR)
		if targetMR < 0 then
			damageReduction = 2 - (100 / (100 - targetMR))
		end		
		damage = damage * damageReduction
		return damage
	end
	return 0
end

local timer = {state = false, tick = GetTickCount(), mouse = mousePos, done = false, delayer = GetTickCount()}
function Tristana:CastSpell(targetPos, spell)
	local curTime = GetTickCount()
	
	if timer.state == false then
		timer.tick = GetTickCount()
		timer.state = true
	end
	
	if curTime - timer.tick > 0 and timer.state == true and targetPos:ToScreen().onScreen and timer.done == false then
		
		if curTime - timer.tick <= 40 then
			timer.mouse = cursorPos
		elseif curTime - timer.tick > 50 then
			
			Control.SetCursorPos(targetPos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			Control.SetCursorPos(timer.mouse)
			timer.state = false
			timer.done = true
		end
		
	end
	
	
end



function Tristana:CheckSpell(range)
    local target
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
			if hero.activeSpell.name == "RocketGrab" then 
				casterPos = hero.pos
				grabTime = hero.activeSpell.startTime * 100
				return true
			end
        end
    end
    return false
end

-------------------------
-- DRAWINGS
-------------------------

function Tristana:Draw()
if self:CanCast(_W) and self.Menu.Drawings.W.Enabled:Value() then Draw.Circle(myHero, 900, self.Menu.Drawings.W.Width:Value(), self.Menu.Drawings.W.Color:Value()) end
if self:CanCast(_E) and self.Menu.Drawings.E.Enabled:Value() then Draw.Circle(myHero, GetERange(), self.Menu.Drawings.E.Width:Value(), self.Menu.Drawings.E.Color:Value()) end
if self:CanCast(_R) and self.Menu.Drawings.R.Enabled:Value() then Draw.Circle(myHero, GetRRange(), self.Menu.Drawings.R.Width:Value(), self.Menu.Drawings.R.Color:Value()) end

end	




function Tristana:DrawGapR()
	if self.Menu.Drawings.DrawR:Value() then
		local textPos = myHero.pos:To2D()
			local hero = CurrentTarget(GetRWRange())
			if hero == nil then return end
			if myHero.pos:DistanceTo(hero.pos) > R.Range and self:EnemyInRange(GetRWRange()) then
			local Rdamage = self:RDMG(hero)		
			local totalDMG = CalculateMagicalDamage(hero, Rdamage)
			if totalDMG > self:HpPred(hero,1) + hero.hpRegen * 1 and not hero.dead and self:IsReady(_R) and self:IsReady(_W) then
			Draw.Text("GapcloseKill PressKey", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
			end
			end
end
end			
		





function Tristana:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				SetMovement(false)
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function Tristana:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

-------------------------
-- BUFFS
-------------------------

function Tristana:IsImmobileTarget(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 22 or buff.type == 8 or buff.type == 24) and buff.count > 0 then
				return true
			end
		end
		return false	
	end


	
function Tristana:AntiBlitz()	
	if GetTickCount() - timer.tick > 300 and GetTickCount() - timer.tick < 700 then 
		timer.state = false
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end

	local ctc = Game.Timer() * 100
	
	local target = _G.SDK.TargetSelector:GetTarget(900, _G.SDK.DAMAGE_TYPE_PHYSICAL)
	if self.Menu.Blitz.UseW:Value() and self:CheckSpell(900) and grabTime ~= nil and self:CanCast(_W) then 
		if myHero.pos:DistanceTo(target.pos) > 350 then
			if ctc - grabTime >= 28 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		else
			if ctc - grabTime >= 12 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		end
	end
end	

--Blade of the RuinKing	
function Tristana:UseBotrk()
	local target = CurrentTarget(700)
	if target == nil then return end
		if self:EnemyInRange(700) then 
		local BOTR = GetInventorySlotItem(3153) or GetInventorySlotItem(3144)
		if BOTR and self:EnemyInRange(700) then
			Control.CastSpell(HKITEM[BOTR], target)
		end
	end
end

--Mercurial Scimittar
function Tristana:UseMS()
	if self.Menu.MS.UseMS:Value() then
	local MS = GetInventorySlotItem(3139)	
		if MS and GotBuff(myHero, "veigareventhorizonstun") > 0 or GotBuff(myHero, "stun") > 0 or GotBuff(myHero, "taunt") > 0 or GotBuff(myHero, "slow") > 0 or GotBuff(myHero, "snare") > 0 or GotBuff(myHero, "charm") > 0 or GotBuff(myHero, "suppression") > 0 or GotBuff(myHero, "flee") > 0 or GotBuff(myHero, "knockup") > 0 then
			Control.CastSpell(HKITEM[MS], myHero)
		
		end
	end
end



function Tristana:Combo()
		local target = CurrentTarget(GetAARange())
		if target == nil then return end
		for i = 1, target.buffCount do
		local buff = target:GetBuff(i)
			if buff and buff.name == "tristanaechargesound" then
				if self.Menu.Combo.UseQ:Value() and target and self:CanCast(_Q) and self:EnemyInRange(GetAARange()) then
					Control.CastSpell(HK_Q)
				end
			end
		end	
	end
	
		


function Tristana:ComboE()
    local target = CurrentTarget(GetERange())
    if target == nil then return end
    if self.Menu.Combo.UseE:Value() and target and self:CanCast(_E) then
	    if self:EnemyInRange(GetERange()) then
		Control.CastSpell(HK_E, target)
		    end
	    end
	    end
		
function Tristana:ComboRKS()
	local hero = CurrentTarget(GetRRange())
    if hero == nil then return end
 	if self.Menu.Combo.R["RR"..hero.charName]:Value() and self:CanCast(_R) then
	if self:EnemyInRange(GetRRange())  then
   	local Rdamage = self:RDMG(hero)   
	local totalDMG = CalculateMagicalDamage(hero, Rdamage)	
		if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1  and not hero.dead then
				Control.CastSpell(HK_R, hero)
			end
        end
    end
end

function Tristana:Finisher()
	local hero = CurrentTarget(GetRRange())
    if hero == nil then return end
	if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
	if self:EnemyInRange(GetRRange()) then
	Edmg = self:EDMG(hero)
	Rdmg = self:RDMG(hero)	
	calcEdmg = CalculatePhysicalDamage(hero, Edmg)
	calcRdmg = CalculateMagicalDamage(hero, Rdmg)
	totalDMG = calcEdmg + calcRdmg
			if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1 and not hero.dead then
			Control.CastSpell(HK_R, hero)
			end
		end
	end
end	



	
function Tristana:GapcloseR()
	local hero = CurrentTarget(GetRWRange())
    if hero == nil then return end
	local Rdamage = self:RDMG(hero)		
	local totalDMG = CalculateMagicalDamage(hero, Rdamage)	
		if self.Menu.gap.UseR:Value() and self:IsReady(_R) and self:IsReady(_W) then
		if myHero.pos:DistanceTo(hero.pos) > R.Range and self:EnemyInRange(GetRWRange()) then
		if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1 and not hero.dead then
			Control.CastSpell(HK_W, hero.pos) self:AutoR()
		end
		end
		end
	end	
		


function Tristana:AutoR()
	local hero = CurrentTarget(GetRRange())
    if hero == nil then return end
	if self:EnemyInRange(GetRRange()) and self:CanCast(_R) then
	local Rdamage = self:RDMG(hero)
	local totalDMG = CalculateMagicalDamage(hero, Rdamage)
		if  totalDMG > self:HpPred(hero,1) + hero.hpRegen * 1 and not hero.dead then
			Control.CastSpell(HK_R, hero)
		

			
		end
	end
end







function Tristana:HarassQ()
		local target = CurrentTarget(GetAARange())
		if target == nil then return end
		for i = 1, target.buffCount do
		local buff = target:GetBuff(i)	
			if buff and buff.name == "tristanaechargesound" then
				if self.Menu.Harass.UseQ:Value() and target and self:CanCast(_Q) and self:EnemyInRange(GetAARange()) then
					Control.CastSpell(HK_Q)
				end
			end
		end	
	end



function Tristana:HarassE()
    local target = CurrentTarget(GetERange())
    if target == nil then return end
    if self.Menu.Harass.UseE:Value() and target and self:CanCast(_E) then
	    if self:EnemyInRange(GetERange()) then
		Control.CastSpell(HK_E, target)
		    end
	    end
	end
 

-------------------------
-- DMG
---------------------
function Tristana:HasEbuff(unit)
	for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)
	for i = 1, hero.buffCount do
		local buff = hero:GetBuff(i)
		if self:HasBuff(hero, "tristanaechargesound") then
		if buff then
			return true
		end
	end
	return false
end
end
end

function Tristana:GetEstacks(unit)

	local stacks = 0
	if self:HasEbuff(unit) then
		for i = 1, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and buff.count > 0 and buff.name:lower() == "tristanaecharge" then
				stacks = buff.count
			end
		end
	end
	return stacks
end



function Tristana:RDMG(unit)
    total = 0
	local rLvl = myHero:GetSpellData(_R).level
    if rLvl > 0 then
	local rdamage = (({300,400,500})[rLvl] + myHero.ap)
	total = rdamage 
	end
	return total
end

function Tristana:AADMG(unit)
    total = 0
	local AALvl = myHero.levelData.lvl

	local AAdamage = 58 + ( 3 * AALvl)
	total = AAdamage * 3
	return total
end

function Tristana:GetStackDmg(unit)

	local total = 0
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 18, 21, 24, 27, 30 })[eLvl]
		local m = ({ 0.15, 0.195, 0.24, 0.285, 0.33 })[eLvl]
		local bonusDmg = m * myHero.bonusDamage
		total = raw + bonusDmg
	end
	return total
end

function Tristana:EDMG(unit)
	local total = 0
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 60, 70, 80, 90, 100 })[eLvl]
		local m = ({ 0.5, 0.65, 0.8, 0.95, 1.10 })[eLvl]
		local bonusDmg = m * myHero.bonusDamage
		total = raw + bonusDmg
		total = total + self:GetStackDmg(unit)  
	end
	return total
end	


function Tristana:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 550 
end


function GetRRange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end

function GetRWRange()
	local rrange = GetRRange()
	local wrange = W.Range
	local range = rrange + wrange
	return range
end



function GetERange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end

function GetAARange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end
	
Callback.Add("Load",function() _G[myHero.charName]() end)


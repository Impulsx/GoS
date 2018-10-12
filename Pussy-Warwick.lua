if myHero.charName ~= "Warwick" then return end

-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyTristana.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/Pussy-Warwick.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyTristana.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/Pussy-Warwick.version"
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
            print("New PussyWarwick Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end

require "DamageLib"
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local barHeight = 8
local barWidth = 103
local barXOffset = 0
local barYOffset = 0
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

class "PussyWarwick"
local Scriptname,Version,Author = "PussyWarwick", "Puusykate"

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function PussyWarwick:__init()
	
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
	PrintChat(Scriptname.." "..Version.." - Loaded....")
end

function PussyWarwick:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }

end

function PussyWarwick:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "PussyWarwick", name = Scriptname})
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.ComboMode:MenuElement({id = "Key", name = "Toggle: E Insta -- Delay Key", key = string.byte("T"), toggle = true})
	self.Menu.ComboMode:MenuElement({id = "UseR", name = "R: Infinite Duress", value = true})
	self.Menu.ComboMode:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.ComboMode:MenuElement({id = "UseHYDRA", name = "Use hydra", value = true})
	self.Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw RRange", value = true})
		
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.HarassMode:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})

	self.Menu:MenuElement({id = "ClearMode", name = "Clear", type = MENU})
	self.Menu.ClearMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.ClearMode:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
		
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 100, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
end

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end
	
function UseHydra()
		local HTarget = CurrentTarget(300)
		if HTarget then 
			local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
			if hydraitem and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(keybindings[hydraitem],HTarget.pos)
                Control.Attack(HTarget)
			end
		end
	end
   
   function UseHydraminion()
        for i = 1, Game.MinionCount() do
	    local minion = Game.Minion(i)
        if minion and minion.team == 300 or minion.team ~= myHero.team then 
			local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
			if hydraitem and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(keybindings[hydraitem])
                Control.Attack(minion)
			end
		end
        end
	end

function UseBotrk()
		local BTarget = CurrentTarget(600)
		if BTarget then 
			local botrkitem = GetInventorySlotItem(3153) or GetInventorySlotItem(3144)
			if botrkitem then
				Control.CastSpell(keybindings[botrkitem],BTarget.pos)
			end
		end
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

function PussyWarwick:Tick()
	if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true then return end
	if self.Menu.HarassMode.harassActive:Value() then
		self:Harass()
	end
	if self.Menu.ComboMode.comboActive:Value() then
		self:Combo()
	end
	if self.Menu.ClearMode.clearActive:Value() then
		self:Jungle()
	end
	if self.Menu.ComboMode.DrawDamage:Value() then
	self:Draw()
	end
end

function PussyWarwick:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function PussyWarwick:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function PussyWarwick:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function PussyWarwick:CanCast(spellSlot)
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

function PussyWarwick:QDmg()
	total = 0
	local qLvl = myHero:GetSpellData(_Q).level
    if qLvl > 0 then
	local qdamage = 1.2 * myHero.totalDamage + 0.9 * myHero.ap + (({6, 6.5, 7, 7.5, 8})[qLvl] / 100  * target.maxHealth)
	total = qdamage
	end
	return total

end

function PussyWarwick:RDmg()
	total = 0
	local rLvl = myHero:GetSpellData(_R).level
    if rLvl > 0 then
	local rdamage = (({175,350,525})[rLvl] + 1.67 * myHero.totalDamage)
	total = rdamage
	end
	return total

end

function PussyWarwick:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end


function PussyWarwick:Draw()
    local textPos = myHero.pos:To2D()
    if self:CanCast(_R) then Draw.Circle(myHero.pos, (2.5 * myHero.ms), Draw.Color(255, 000, 222, 255)) end
	if self.Menu.ComboMode.DrawDamage:Value() then
		for i, hero in pairs(self:GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (self:CanCast(_Q) and self:QDmg() or 0)
				local RDamage = (self:CanCast(_R) and self:RDmg() or 0)
				local damage = QDamage + RDamage
				if damage > self:HpPred(hero,1) + hero.hpRegen * 1 then
					Draw.Text("killable", 24, hero.pos2D.x, hero.pos2D.y,Draw.Color(0xFF00FF00))
					
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, Draw.Color(0xFF00FF00))
				end
			end
		end	
	end
	if self.Menu.ComboMode.Key:Value() then
		Draw.Text("Insta E: On", 20, textPos.x - 33, textPos.y + 50, Draw.Color(255, 000, 255, 000)) 
	else
		Draw.Text("Insta E: Off", 20, textPos.x - 33, textPos.y + 50, Draw.Color(255, 225, 000, 000)) 
	end
end

function PussyWarwick:CastSpell(spell,pos)
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


function PussyWarwick:Combo()
    if self.Menu.ComboMode.UseHYDRA:Value() and self:HasBuff(myHero, "Blood Hunt") and self:EnemyInRange(300) then
        if myHero.attackData.state == STATE_WINDDOWN then
            UseHydra()
        end
    end

    if self:CanCast(_E) then 
		local ETarget = CurrentTarget(375)
		if self.Menu.ComboMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == false and ETarget and self:HasBuff(myHero, "Primal Howl") then
			if self:EnemyInRange(375) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
        if self.Menu.ComboMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == true and ETarget and not self:HasBuff(myHero, "Primal Howl") then
			if self:EnemyInRange(375) and self:CanCast(_E) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
	end

	if self:CanCast(_Q) and self:EnemyInRange(350) then 
		local QTarget = CurrentTarget(350)
		if self.Menu.ComboMode.UseQ:Value() and QTarget then
            if self:EnemyInRange(350) and myHero.pos:DistanceTo(QTarget.pos) < 350 and myHero.pos:DistanceTo(QTarget.pos) > 125 then
				Control.CastSpell(HK_Q, QTarget)
            end
		end
	end

    if self:CanCast(_R) then 
        local rRange = 2.5 * myHero.ms
		local RTarget = CurrentTarget(rRange)
        if self.Menu.ComboMode.UseR:Value() and RTarget then
			if self:EnemyInRange(rRange) and myHero.pos:DistanceTo(RTarget.pos) < rRange then
				Control.CastSpell(HK_R, RTarget)
			end	
        end
    end
	

    if self:EnemyInRange(600) and not self:CanCast(_Q) then 
        local BTarget = CurrentTarget(600)
        if BTarget then
            if myHero.pos:DistanceTo(BTarget.pos) < 600 then
			    UseBotrk()
            end
        end
    end
    

end

function PussyWarwick:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function PussyWarwick:EnemyInRange(range)
	local count = 0
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

function PussyWarwick:Harass()
    if self.Menu.ComboMode.UseHYDRA:Value() and self:HasBuff(myHero, "Blood Hunt") and self:EnemyInRange(300) then
        if myHero.attackData.state == STATE_WINDDOWN then
            UseHydra()
        end
    end
    if self:CanCast(_E) then 
		local ETarget = CurrentTarget(375)
		if self.Menu.HarassMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == false and ETarget and self:HasBuff(myHero, "Primal Howl") then
			if self:EnemyInRange(375) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
        if self.Menu.HarassMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == true and ETarget and not self:HasBuff(myHero, "Primal Howl") then
			if self:EnemyInRange(375) and self:CanCast(_E) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
	end

	if self:CanCast(_Q) then 
		local QTarget = CurrentTarget(350)
		if self.Menu.HarassMode.UseQ:Value() and QTarget then
            if self:EnemyInRange(350) and myHero.pos:DistanceTo(QTarget.pos) < 350 and myHero.pos:DistanceTo(QTarget.pos) > 125 then
				Control.CastSpell(HK_Q, QTarget)
            end
		end
	end

	if self:CanCast(_W) then 
		local WTarget = CurrentTarget(125)
		if self.Menu.HarassMode.UseW:Value() and WTarget then
			if self:EnemyInRange(125) and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_W)
                Control.Attack(WTarget)
			end
		end
	end
	
end

function PussyWarwick:Jungle()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    if minion and minion.team == 300 or minion.team ~= myHero.team then
    if self:CanCast(_E) and minion then 
		if self.Menu.ClearMode.UseE:Value() and self.Menu.ComboMode.Key:Value()  == false and self:HasBuff(myHero, "Primal Howl") then
			if myHero.pos:DistanceTo(minion.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
        if self.Menu.ClearMode.UseE:Value() and self.Menu.ComboMode.Key:Value()  == true and not self:HasBuff(myHero, "Primal Howl") then
			if myHero.pos:DistanceTo(minion.pos) < 375 and self:CanCast(_E) then
				Control.CastSpell(HK_E)
			end
		end
	end	

    if self.Menu.ComboMode.UseHYDRA:Value() and not self:HasBuff(myHero, "Blood Hunt") and minion then
        if myHero.attackData.state == STATE_WINDDOWN and not self:CanCast(_W) and myHero.pos:DistanceTo(minion.pos) < 300 then
            UseHydraminion()
        end
    end
	if self:CanCast(_Q) and minion then 
		if self.Menu.ClearMode.UseQ:Value() and ValidTarget(minion, 350) then
            if myHero.pos:DistanceTo(minion.pos) < 350 and myHero.pos:DistanceTo(minion.pos) > 125 then
				Control.CastSpell(HK_Q, minion)
            end
		end
	end

	if self:CanCast(_W) and minion then 
		if self.Menu.ClearMode.UseW:Value() and ValidTarget(minion, 175) then
			if myHero.pos:DistanceTo(minion.pos) < 175 and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_W)
                Control.Attack(minion)
			end
		end
	end
	end
	end
end

function OnLoad()
	PussyWarwick()
end

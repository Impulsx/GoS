local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.team ~= myHero.team then
			TableInsert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end 

local function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return false
end

local function CountEnemiesNear(pos, range)
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

local function CastRange()
	return 517 + (8 * myHero.levelData.lvl)
end

function LoadScript()

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.11"}})	
	
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ2", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseQ", name = "Only [Q] when Explosive Charge", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Explosive Charge", value = true})
	Menu.Combo:MenuElement({type = MENU, id = "Targets", name = "Whitelist [E]"})	
	DelayAction(function()
		for i, Hero in pairs(GetEnemyHeroes()) do  
			Menu.Combo.Targets:MenuElement({id = Hero.charName, name = "UseE on "..Hero.charName, value = true})		
		end	
	end, 0.01)	
	Menu.Combo:MenuElement({id = "UseW", name = "[W] catch EStacks then [W] back ", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "(R)Finisher", tooltip = "is(R)Dmg+(E)Dmg+(E)StackDmg > TargetHP than Ult", value = true})	
	
	Menu.Combo:MenuElement({type = MENU, id = "gap", name = "Gapclose"})	
	Menu.Combo.gap:MenuElement({name = " ", drop = {"Gapclose [W + R] if KillableTarget > Ult-Range"}})		
	Menu.Combo.gap:MenuElement({id = "UseR", name = "Gapclose [W + R]", value = true})	
	Menu.Combo.gap:MenuElement({id = "UseW", name = "UseW Back after Gapclose", value = true})
	Menu.Combo.gap:MenuElement({id = "HP", name = "[W Back] if Tristana HP lower than", value = 40, min = 0, max = 100, identifier = "%"})	
	
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ2", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseQ", name = "Only [Q] when Explosive Charge", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E] Explosive Charge", value = true})
	
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Cannon Minions", value = true}) 		
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})			
	

	Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawings"})
	
	--W
	Menu.Drawings:MenuElement({type = MENU, id = "W", name = "Draw W range"})
    Menu.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    Menu.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Menu.Drawings.W:MenuElement({id = "Color", name = "Color", color = DrawColor(200, 255, 255, 255)})
	--E
	Menu.Drawings:MenuElement({type = MENU, id = "E", name = "Draw E range"})
    Menu.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    Menu.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Menu.Drawings.E:MenuElement({id = "Color", name = "Color", color = DrawColor(200, 255, 255, 255)})	
	--R
	Menu.Drawings:MenuElement({type = MENU, id = "R", name = "Draw R range"})
    Menu.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = false})
    Menu.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Menu.Drawings.R:MenuElement({id = "Color", name = "Color", color = DrawColor(200, 255, 255, 255)})	
     	                                           
	Callback.Add("Tick", function() Tick() end)	

	Callback.Add("Draw", function()
		if myHero.dead then return end
		if Ready(_W) and Menu.Drawings.W.Enabled:Value() then DrawCircle(myHero, 900, Menu.Drawings.W.Width:Value(), Menu.Drawings.W.Color:Value()) end
		if Ready(_E) and Menu.Drawings.E.Enabled:Value() then DrawCircle(myHero, CastRange(), Menu.Drawings.E.Width:Value(), Menu.Drawings.E.Color:Value()) end
		if Ready(_R) and Menu.Drawings.R.Enabled:Value() then DrawCircle(myHero, CastRange(), Menu.Drawings.R.Width:Value(), Menu.Drawings.R.Color:Value()) end

	end)	
end

function Tick()
--print(CastRange())
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		ComboQ()
		ComboE()
		Finisher()
		GapcloseR()
		CastWBack()		
	elseif Mode == "Harass" then
		HarassQ()
		HarassE()
	elseif Mode == "Clear" then		
		Clear()
	end	
end

local function EDMG(unit)
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 154, 176, 198, 220, 242 })[eLvl]
		local m = ({ 1.1, 1.65, 2.2, 2.75, 3.3 })[eLvl]
		local bonusDmg = (m * myHero.bonusDamage) + (1.1 * myHero.ap)
		local FullDmg = raw + bonusDmg
		return CalcPhysicalDamage(myHero, unit, FullDmg)  
	end
end

function Finisher()
local target = GetTarget(CastRange())
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < CastRange() and Menu.Combo.UseR:Value() and Ready(_R) then	
		local Buff = GotBuff(target, "tristanaecharge")
		if Buff and Buff.count >= 3 then
			local Edmg = EDMG(target)  
			local Rdmg = getdmg("R", target, myHero)	
			local totalDMG = (Edmg + Rdmg)
			if totalDMG > target.health then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function ComboQ()
local target = GetTarget(CastRange())
if target == nil then return end
	
	if IsValid(target) and Ready(_Q) and Menu.Combo.UseQ2:Value() then
		if Menu.Combo.UseQ:Value() then	
			if GotBuff(target, "tristanaecharge") then	
				Control.CastSpell(HK_Q)
			end
		else
			Control.CastSpell(HK_Q)
		end
	end	
end
	
function ComboE()
local target = GetTarget(CastRange())
if target == nil then return end
		
	if IsValid(target) and Menu.Combo.UseE:Value() and Menu.Combo.Targets[target.charName] and Menu.Combo.Targets[target.charName]:Value() and Ready(_E) then
		Control.CastSpell(HK_E, target)
	end
end	

local Gapclose2 = false
local LastPos2 = nil
function GapcloseR()
local target = GetTarget((CastRange()+900)-100)
if target == nil then return end
		
	if IsValid(target) and Menu.Combo.gap.UseR:Value() and Ready(_R) then
		local Rdamage = getdmg("R", target, myHero)		
		if Rdamage > target.health then		
			if myHero.pos:DistanceTo(target.pos) > CastRange() and Ready(_W) then
				local jump = Vector(myHero.pos):Extended(Vector(target.pos), 900)    ------
				LastPos2 = myHero.pos
				Gapclose2 = true				
				Control.CastSpell(HK_W, jump)
			else
				if myHero.pos:DistanceTo(target.pos) <= CastRange() then
					Control.CastSpell(HK_R, target)
				end
			end
		end
	end
	if Ready(_W) and Gapclose2 and Menu.Combo.gap.UseW:Value() and myHero.health/myHero.maxHealth <= Menu.Combo.gap.HP:Value() / 100 then
		local jump = Vector(LastPos2):Shortened(Vector(target.pos), 900-LastPos2:DistanceTo(target.pos))
		--DrawCircle(Vector(jump), 50, 1, DrawColor(255, 225, 255, 10))
		if Control.CastSpell(HK_W, jump) then
		Gapclose2 = false
		LastPos2 = nil
		return
		end
	end	
end
	
local Gapclose = false
local LastPos = nil
function CastWBack()	
	if Ready(_W) and Menu.Combo.UseW:Value() then
		for i, target in pairs(GetEnemyHeroes()) do
			local Buff = GotBuff(target, "tristanaecharge")
			if myHero.pos:DistanceTo(target.pos) < 900 and IsValid(target) then
				  			
				if myHero.pos:DistanceTo(target.pos) > CastRange()+150 and Buff and Buff.count == 2 then	
					LastPos = myHero.pos
					Gapclose = true
					Control.CastSpell(HK_W, target.pos)
				end	
		
			
				if Ready(_W) and Gapclose then
					local jump = Vector(LastPos):Shortened(Vector(target.pos), 900-LastPos:DistanceTo(target.pos))
					--DrawCircle(Vector(jump), 50, 1, DrawColor(255, 225, 255, 10))
					if Control.CastSpell(HK_W, jump) then
					Gapclose = false
					LastPos = nil
					return
					end
				end
			end	
		end
	end		
end	
		
function HarassQ()
local target = GetTarget(CastRange())
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < CastRange() and Ready(_Q) and Menu.Harass.UseQ2:Value() then
		if Menu.Harass.UseQ:Value() then	
			if GotBuff(target, "tristanaecharge") then	
				Control.CastSpell(HK_Q)
			end
		else
			Control.CastSpell(HK_Q)
		end
	end	
end

function HarassE()
local target = GetTarget(CastRange())
if target == nil then return end
    if IsValid(target) and myHero.pos:DistanceTo(target.pos) < CastRange() and Menu.Harass.UseE:Value() and Ready(_E) then
		Control.CastSpell(HK_E, target)
		   
	end
end

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) < CastRange() and minion.team == TEAM_ENEMY and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
            if Menu.Clear.UseE:Value() and mana_ok then
				if (minion.charName == "SRU_ChaosMinionSiege" or minion.charName == "SRU_OrderMinionSiege") then
					if Ready(_E) then
						Control.CastSpell(HK_E, minion)
					end	
					if Menu.Clear.UseQ:Value() and mana_ok and Ready(_Q) then
						Control.CastSpell(HK_Q)
					end					
				else
					if Menu.Clear.UseQ:Value() and mana_ok and Ready(_Q) then
						Control.CastSpell(HK_Q)
					end					
				end	
			else
				if Menu.Clear.UseQ:Value() and mana_ok and Ready(_Q) then
					Control.CastSpell(HK_Q)
				end			
            end					
        end
    end
end


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

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.06"}})	
	Menu:MenuElement({type = MENU, id = "Mode", name = myHero.charName})
	
	--AutoW
	Menu.Mode:MenuElement({type = MENU, id = "Auto", name = "AutoW"})
	Menu.Mode.Auto:MenuElement({id = "W", name = "[W] Immobile Target", value = true})
	
	
	--Combo
	Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Mode.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	Menu.Mode.Combo:MenuElement({id = "W", name = "UseW if Target Flee", value = true})
	Menu.Mode.Combo:MenuElement({id = "E", name = "Use E", value = true})
	Menu.Mode.Combo:MenuElement({id = "R", name = "Use R", value = true})
	Menu.Mode.Combo:MenuElement({id = "RHP", name = "R when target HP%", value = 20, min = 0, max = 100, step = 1})
	Menu.Mode.Combo:MenuElement({id = "myRHP", name = "R when XinZhao HP%", value = 30, min = 0, max = 100, step = 1})
	
	--Harass
	Menu.Mode:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Mode.Harass:MenuElement({id = "W", name = "Use W", value = true})
	Menu.Mode.Harass:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	Menu.Mode.Harass.MM:MenuElement({id = "WMana", name = "Min Mana to W in Harass(%)", value = 40, min = 0, max = 100, step = 1})
	
	--LaneClear
	Menu.Mode:MenuElement({type = MENU, id = "LaneClear", name = "Clear"})
	Menu.Mode.LaneClear:MenuElement({id = "W", name = "Use W", value = true})
	Menu.Mode.LaneClear:MenuElement({id = "WMinion", name = "Use W when X minions", value = 3,min = 1, max = 4, step = 1})
	Menu.Mode.LaneClear:MenuElement({id = "Q", name = "Use Q", value = true})
	Menu.Mode.LaneClear:MenuElement({id = "E", name = "Use E", value = true})
	
	--JungleClear
	Menu.Mode:MenuElement({type = MENU, id = "JungleClear", name = "JungleClear"})
	Menu.Mode.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true})
	Menu.Mode.JungleClear:MenuElement({id = "W", name = "Use W", value = true})
	Menu.Mode.JungleClear:MenuElement({id = "E", name = "Use E", value = true})
	
	--KillSteal
	Menu.Mode:MenuElement({type = MENU, id = "KS", name = "KillSteal"})
	Menu.Mode.KS:MenuElement({id = "E", name = "UseE", value = true})	
	
	--Spell Range 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "E", name = "Draw E Range", value = true})
	Menu.Drawing:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
	Menu.Drawing:MenuElement({id = "Color", name = "Color", color = DrawColor(255, 255, 255, 255)})

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		if Menu.Drawing.E:Value() then 
			DrawCircle(myHero.pos, 650, Menu.Drawing.Width:Value(), Menu.Drawing.Color:Value())	
		end
	end)	
	
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()		
	end	
	AutoW()	
	KS()
end

function AutoW()
local target = GetTarget(1000)     	
if target == nil then return end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 900 and IsImmobileTarget(target) then
		if Menu.Mode.Auto.W:Value() and Ready(_W) and not myHero.isChanneling then
			Control.CastSpell(HK_W, target.pos)
		end
	end			
end

function KS()
local target = GetTarget(800)     	
if target == nil then return end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 600 then
		local edamage = getdmg("E", target, myHero)
		if Menu.Mode.KS.E:Value() and Ready(_E) and not myHero.isChanneling and edamage > target.health then
			Control.CastSpell(HK_E, target)
		end
	end			
end

function Combo()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 600 and Menu.Mode.Combo.E:Value() and Ready(_E) and not myHero.isChanneling then
			Control.CastSpell(HK_E,target)
	    end	
		if myHero.pos:DistanceTo(target.pos) > 400 and myHero.pos:DistanceTo(target.pos) < 900 and Menu.Mode.Combo.W:Value() and Ready(_W) and not myHero.isChanneling then
			Control.CastSpell(HK_W,target.pos)
		end
		if myHero.pos:DistanceTo(target.pos) < 400 and Menu.Mode.Combo.Q:Value() and Ready(_Q) and myHero.attackData.state == STATE_WINDUP then
			Control.CastSpell(HK_Q)
		end 
		if myHero.pos:DistanceTo(target.pos) < 450 and Menu.Mode.Combo.R:Value() and Ready(_R) and target.health/target.maxHealth <= Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling then
			Control.CastSpell(HK_R)
		end
		if Menu.Mode.Combo.R:Value() and Ready(_R) and myHero.health/myHero.maxHealth <= Menu.Mode.Combo.myRHP:Value()/100 and not myHero.isChanneling then
			Control.CastSpell(HK_R)
		end		
	end    	
end	

function Harass()
local target = GetTarget(1000)     	
if target == nil then return end
		
	if IsValid(target) and target.pos:DistanceTo(myHero.pos) <= 900 and myHero.mana/myHero.maxMana >= Menu.Mode.Harass.MM.WMana:Value() / 100 and Menu.Mode.Harass.W:Value() and Ready(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W, target.pos)
	end
end

function Clear()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if minion.pos:DistanceTo(myHero.pos) <= 600 and Menu.Mode.LaneClear.E:Value() and Ready(_E) then
				Control.CastSpell(HK_E,minion)
				break
			end	
			if myHero.pos:DistanceTo(minion.pos) < 900 and Menu.Mode.LaneClear.W:Value() and Ready(_W) then
				if GetMinionCount(500, minion) >= Menu.Mode.LaneClear.WMinion:Value() then
					Control.CastSpell(HK_W,minion.pos)
					break
				end	
			end
			if myHero.pos:DistanceTo(minion.pos) < 400 and Menu.Mode.LaneClear.Q:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
				break
			end
		end
		if minion.team == TEAM_JUNGLE and IsValid(minion) then
			if minion.pos:DistanceTo(myHero.pos) <= 600 and Menu.Mode.JungleClear.E:Value() and Ready(_E) then
				Control.CastSpell(HK_E,minion)
				break
			end
			if myHero.pos:DistanceTo(minion.pos) < 400 and Menu.Mode.JungleClear.Q:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
				break
			end 
			if myHero.pos:DistanceTo(minion.pos) < 900 and Menu.Mode.JungleClear.W:Value() and Ready(_W) then
				Control.CastSpell(HK_W,minion.pos)
				break
			end	
		end
	end
end

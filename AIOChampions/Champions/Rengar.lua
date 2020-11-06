local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function IsImmobile(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 8 or buff.type == 11 or buff.type == 21 or buff.name == 22 or buff.name == 24 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.06"}})
	
	Menu:MenuElement({type = MENU, id = "Prio", name = "Empowered Spell Priority"})	
	Menu.Prio:MenuElement({id = "Logic", name = "Empowered[Q] / Empowered[E]", key = string.byte("T"), toggle = true})	
	Menu.Prio:MenuElement({id = "UseW", name = "Use Empowered[W] cleans CC", value = true})	
	
	--ComboMenu
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})		
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance [E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	--Drawing
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W]", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]", value = false})	
	Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "TextPos Spell Priority"})	
	Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1000, Speed = 1500, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	EspellData = {speed = 1500, range = 1000, delay = 0.25, radius = 70, collision = {"minion"}, type = "linear"}		

	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function() 
		if myHero.dead then return end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 450, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 1000, 1, DrawColor(225, 225, 0, 10))
		end	

		DrawText("Spell Priority: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+15, DrawColor(255, 225, 255, 0))
		if Menu.Prio.Logic:Value() then
			DrawText("Q", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		else
			DrawText("E", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		end		
	end)		
end

function Tick()
Buff()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		DashAktive()		
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end	
	if Menu.Prio.UseW:Value() and Ready(_W) then
		AutoW()
	end
end

local UltActive  = false 
local Dash       = false

function AutoW()
if myHero.mana < 4 then return end	
	if IsImmobile(myHero) then
		Control.CastSpell(HK_W)
	end
end	

function Buff()
	if HasBuff(myHero, "RengarR") then
		UltActive = true 
	else
		UltActive = false
	end

	if HasBuff(myHero, "rengarpassivebuff") then
		Dash = true
	else
		Dash = false
	end
end

function CastQ(unit)
	if (not Menu.Prio.Logic:Value() and myHero.mana == 4) then return end
	if myHero.pos:DistanceTo(unit.pos) < 400 then	
		Control.CastSpell(HK_Q)
	end
end

function CastW(unit)
	if myHero.mana == 4 then return end
	if myHero.pos:DistanceTo(unit.pos) < 450 then
		Control.CastSpell(HK_W)
	end
end

function CastE(unit)
	if (Menu.Prio.Logic:Value() and myHero.mana == 4) then return end
	if myHero.pos:DistanceTo(unit.pos) < 1000 then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				Control.CastSpell(HK_E, pred.CastPosition)
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				Control.CastSpell(HK_E, pred.CastPos)
			end
		else
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1000, Speed = 1500, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
			EPrediction:GetPrediction(unit, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value()+1) then
				Control.CastSpell(HK_E, EPrediction.CastPosition)
			end	
		end
	end
end

function Combo()
	if UltActive == true then
		UltCombo()
	end	
	if UltActive == true or Dash == true then return end
	local target = GetTarget(1100)
	if target == nil then return end
		if IsValid(target) then 
		if Menu.Combo.UseQ:Value() and Ready(_Q) then CastQ(target) end
		if Menu.Combo.UseW:Value() and Ready(_W) then CastW(target) end
		if Menu.Combo.UseE:Value() and Ready(_E) then CastE(target) end
	end
end

function UltCombo()
	local target = GetTarget(1100)
	if target == nil then return end
		if IsValid(target) then 
		if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 850 then Control.CastSpell(HK_Q) end
		if Menu.Combo.UseE:Value() and Ready(_E) and myHero.pathing.isDashing and myHero.pathing.dashSpeed > 500 then CastE(target) end
	end
end

local function QDmg(unit)
	if myHero.mana == 4 then 
		return getdmg("Q", unit, myHero, 2)
	else 
		return getdmg("Q", unit, myHero, 1) 
	end
end
	
function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 400 and minion.team == TEAM_ENEMY and IsValid(minion) then
			local QDmg = QDmg(minion)
			if Menu.Clear.UseQ:Value() and Ready(_Q) and QDmg > minion.health then 
				Control.CastSpell(HK_Q)	
			end
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_JUNGLE and IsValid(minion) then
			if myHero.pos:DistanceTo(minion.pos) <= 400 and Menu.JClear.UseQ:Value() and Ready(_Q) then 
				Control.CastSpell(HK_Q) 
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 450 and Menu.JClear.UseW:Value() and Ready(_W) then 
				Control.CastSpell(HK_W) 
			end
			
			if Menu.JClear.UseE:Value() and Ready(_E) then 
				Control.CastSpell(HK_E, minion.pos) 
			end
		end
	end
end

function DashAktive()
	if UltActive == true then return end
	local target = GetTarget(1100)
	if target == nil then return end
	if IsValid(target) and Dash == true then	
		if Ready(_Q) then CastQ(target) end	
		if Ready(_E) then CastE(target) end	
	end
end

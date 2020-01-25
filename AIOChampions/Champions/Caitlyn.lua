function GetEnemyHeroes()
	return Enemies
end

local function CheckTrap(unit, range)
	for i = 0, Game.ObjectCount() do
	local object = Game.Object(i)
		if object and GetDistance(object.pos, unit.pos) < range and (object.name == "Caitlyn_Base_W_Indicator_SizeRing") then
		return true
		end
	end
	return false
end

function EnemyInRange(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range and IsValid(target) then 
			count = count + 1
		end
	end
	return count
end

function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function GetMinionCount(range, pos)
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

function CastSpellMM(spell,pos,range,delay)
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

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})	

	--AutoW  
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})		
	Menu.AutoW:MenuElement({id = "UseW", name = "AutoW on Immobile Target", value = true})	
	
	--AutoE  
	Menu:MenuElement({type = MENU, id = "AntiGap", name = "Antigapclose"})
	Menu.AntiGap:MenuElement({name = " ", drop = {"WIP,,, Pls Report if is not working"}})
	Menu.AntiGap:MenuElement({id = "UseE", name = "Use[E] Antigapclose", value = true})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})				

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "Count", name = "Min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.ks:MenuElement({id = "Rrange", name = "Cast R if range greater than -->", value = 1200, min = 0, max = 3500})
	Menu.ks:MenuElement({id = "enemy", name = "Cast R if no Enemy in range -->", value = 1200, min = 0, max = 3500})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawKill", name = "Draw Ult Kill on Minimap", value = true})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.3, Radius = 60, Range = 1250, Speed = 2200, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}
	}

	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.75, Radius = 0, Range = 800, Speed = 1450, Collision = false
	}

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.7, Radius = 70, Range = 750, Speed = 1600, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
	}
  	                                           
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 3500, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 1300, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 750, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 125, 10))
		end
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end
		
		for i, target in ipairs(GetEnemyHeroes()) do	
			if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 6000 and IsValid(target) and Menu.Drawing.DrawKill:Value() then	
				local hp = target.health
				local RDmg = getdmg("R", target, myHero)
				if RDmg >= hp then
					Draw.Text("ULT KILL", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
				end
			end	
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
		JungleClear()		
	end	
	KillSteal()
	AutoW()
	AutoE()
end

function AutoW()
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) <= 800 and IsValid(target) and IsImmobileTarget(target) and not HasBuff(target, "caitlynyordletrapsight") and not CheckTrap(target, 200) and Menu.AutoW.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
				Control.CastSpell(HK_W, pred.CastPosition)
			end	
		end
	end
end	

function AutoE()
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) <= 1500 and IsValid(target) and Menu.AntiGap.UseE:Value() and Ready(_E) then
			if target.pathing.isDashing and target.pathing.dashSpeed > 500 and GetDistance(target.pos, myHero.pos) > GetDistance(Vector(target.pathing.endPos), myHero.pos) then
				Control.CastSpell(HK_E, target.pos)
			end	
		end
	end
end
       
function KillSteal()	
	for i, target in ipairs(GetEnemyHeroes()) do	
		if myHero.pos:DistanceTo(target.pos) <= 3500 and IsValid(target) then	
		local hp = target.health
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.ks.UseQ:Value() and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				local QDmg = getdmg("Q", target, myHero)
				if QDmg >= hp and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
			
			if myHero.pos:DistanceTo(target.pos) >= Menu.ks.Rrange:Value() and Menu.ks.UseR:Value() and Ready(_R) then
				local count = EnemyInRange(Menu.ks.enemy:Value())
				local RDmg = getdmg("R", target, myHero) - 100
				if RDmg >= hp and count == 0 then			
					if target.pos:To2D().onScreen then 		
						Control.CastSpell(HK_R, target) 
					
					elseif not target.pos:To2D().onScreen then	   
						CastSpellMM(HK_R, target.pos, 3500)
					end
				end
			end
		end
	end	
end	

function Combo()
local target = GetTarget(1400)
if target == nil then return end
	if IsValid(target) then

		if myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_E).level > 0 then
			
			if myHero.pos:DistanceTo(target.pos) <= 800 and not HasBuff(target, "caitlynyordletrapsight") and not CheckTrap(target, 200) and Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
					Control.CastSpell(HK_W, pred.CastPosition)
				end	
			end			
			
			if myHero.pos:DistanceTo(target.pos) <= 750 and Menu.Combo.UseE:Value() and Ready(_E) then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
					Control.CastSpell(HK_E, pred.CastPosition)
		
				end
			end
			
			if HasBuff(myHero, "caitlynheadshotrangcheck") then return end			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "caitlynyordletrapinternal") and Menu.Combo.UseQ:Value() and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then			
					Control.CastSpell(HK_Q, pred.CastPosition)
		
				end
			end

		else
			if myHero.pos:DistanceTo(target.pos) <= 800 and not HasBuff(target, "caitlynyordletrapsight") and not CheckTrap(target, 200) and Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
					Control.CastSpell(HK_W, pred.CastPosition)
				end	
			end			
			
			if myHero:GetSpellData(_W).level > 0 then
				if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "caitlynyordletrapinternal") and Menu.Combo.UseQ:Value() and Ready(_Q) then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then			
						Control.CastSpell(HK_Q, pred.CastPosition)
			
					end
				end
			else
				if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.Combo.UseQ:Value() and Ready(_Q) then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then			
						Control.CastSpell(HK_Q, pred.CastPosition)
			
					end
				end
			end	

			if myHero.pos:DistanceTo(target.pos) <= 750 and Menu.Combo.UseE:Value() and Ready(_E) then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
					Control.CastSpell(HK_E, pred.CastPosition)
		
				end
			end			
		end	
	end
end	

function Harass()
local target = GetTarget(1300)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then			
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end	

function Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and Menu.Clear.UseQ:Value() and GetMinionCount(180, minion) >= Menu.Clear.Count:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	 
		end
	end
end

function JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end  
		end
	end
end

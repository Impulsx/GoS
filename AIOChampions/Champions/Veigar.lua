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

function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

local _OnVision = {}
function OnVision(unit)
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
	return _OnVision[unit.networkID]
end

local _OnWaypoint = {}
function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		-- print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
					-- print("OnDash: "..unit.charName)
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

function LoadScript()

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})	
	
	Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	Menu.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "W", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "E", value = true})
	Menu.Combo:MenuElement({id = "WWait", name = "Only W when stunned", value = true})
	Menu.Combo:MenuElement({id = "EMode", name = "E Mode", drop = {"Edge", "Middle"}})
	Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
		
	Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	Menu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "W", value = true})
	Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	Menu.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
	Menu.Lasthit:MenuElement({id = "AutoQFarm", name = "Auto Q Farm", value = false, toggle = true, key = string.byte("T")})
	Menu.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
	Menu.Lasthit:MenuElement({type = MENU, id = "XY", name = "Text Position"})	
	Menu.Lasthit.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.Lasthit.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	
	
	Menu:MenuElement({id = "Clear", name = "Clear", type = MENU})
	Menu.Clear:MenuElement({id = "UseW", name = "W", value = true})
	Menu.Clear:MenuElement({id = "WHit", name = "W hits x minions", value = 3,min = 1, max = 6, step = 1})
	Menu.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
	
	Menu:MenuElement({id = "Mana", name = "Mana", type = MENU})
	Menu.Mana:MenuElement({id = "QMana", name = "Min mana to use Q", value = 35, min = 0, max = 100, step = 1})
	Menu.Mana:MenuElement({id = "WMana", name = "Min mana to use W", value = 40, min = 0, max = 100, step = 1})
	
	Menu:MenuElement({id = "Killsteal", name = "KillSteal", type = MENU})
	Menu.Killsteal:MenuElement({id = "UseQ", name = "Q", value = true})
	Menu.Killsteal:MenuElement({id = "UseW", name = "W", value = false})
	Menu.Killsteal:MenuElement({id = "RR", name = "R", value = true})

	Menu:MenuElement({id = "isCC", name = "AutoUseCC", type = MENU})
	Menu.isCC:MenuElement({id = "UseQ", name = "Q", value = true})
	Menu.isCC:MenuElement({id = "UseW", name = "W", value = true})
	Menu.isCC:MenuElement({id = "UseE", name = "E", value = false})
	Menu.isCC:MenuElement({id = "EMode", name = "E Mode", drop = {"Edge", "Middle"}})

	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
	
	Q = {Range = 950, Width = 70, Delay = 0.25, Speed = 2000, Collision = false, aoe = false, Type = "line"}
	W = {Range = 900, Width = 225, Delay = 1.35, Speed = 1000, Collision = false, aoe = true, Type = "circular"}
	E = {Range = 700, Width = 375, Delay = 0.5, Speed = 1000, Collision = false, aoe = true, Type = "circular"}
	R = {Range = 650, Width = 50, Delay = 0.25, Speed = 1400, Collision = false, aoe = false, Type = "line"}	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 950, Speed = 2000, Collision = true ,MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
	}

	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 1.25, Radius = 112, Range = 900, Speed = 1000, Collision = false
	}

	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 375, Range = 700, Speed = 1000, Collision = false
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
		if Menu.Lasthit.AutoQFarm:Value() then
			Draw.Text("Auto LastHit[Q]: ON", 15, Menu.Lasthit.XY.x:Value()+85, Menu.Lasthit.XY.y:Value()+15, Draw.Color(255, 0, 255, 0))
		else
			Draw.Text("Auto LastHit[Q]: OFF", 15, Menu.Lasthit.XY.x:Value()+85, Menu.Lasthit.XY.y:Value()+15, Draw.Color(255, 255, 0, 0))
		end	
		
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end
	end)	
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.Combo.comboActive:Value() then
			Combo()
		end
	elseif Mode == "Harass" then
		if Menu.Harass.harassActive:Value() then
			Harass()
		end
	elseif Mode == "Clear" then
		if Menu.Clear.clearActive:Value() then
			Clear()
		end	
	elseif Mode == "LastHit" then
		if Menu.Lasthit.lasthitActive:Value() then
			Lasthit()
		end		
	end

	KS()
	SpellonCC()
	AutoQFarm()
end

function Clear()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 900 and IsValid(minion) and Menu.Clear.UseW:Value() then
			if minion.team == TEAM_ENEMY then
				local count = GetMinionCount(120, minion)
				if count >= Menu.Clear.WHit:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= Menu.Mana.WMana:Value() / 100 then
					Control.CastSpell(HK_W,minion.pos)
				end
			end
			if minion.team == TEAM_JUNGLE then
				if Ready(_W) and myHero.mana/myHero.maxMana >= Menu.Mana.WMana:Value() / 100 then
					Control.CastSpell(HK_W,minion.pos)
				end	
			end
		end
	end	
end

function Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= Q.Range then	
			if Menu.Combo.UseQ:Value() and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
		end
		

		if myHero.pos:DistanceTo(target.pos) <= E.Range then	
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if Menu.Combo.UseE:Value() and Ready(_E) and pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
				if Menu.Combo.EMode:Value() == 1 then
					Control.CastSpell(HK_E, Vector(target:GetPrediction(math.huge,0.25))-Vector(Vector(target:GetPrediction(math.huge,0.25))-Vector(myHero.pos)):Normalized()*375) 
				elseif Menu.Combo.EMode:Value() == 2 then
					Control.CastSpell(HK_E,pred.CastPosition)
				end
			end	
		end
		

		if myHero.pos:DistanceTo(target.pos) <= W.Range then	
			if Menu.Combo.UseW:Value() and Ready(_W) then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				local ImmobileEnemy = IsImmobileTarget(target)
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
					if Menu.Combo.WWait:Value() and ImmobileEnemy then 
						Control.CastSpell(HK_W, pred.CastPosition)
					elseif Menu.Combo.WWait:Value() == false then 
						Control.CastSpell(HK_W, pred.CastPosition)	
					end
				end
			end
		end
	end
end	

function Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then    
		
		if myHero.pos:DistanceTo(target.pos) <= Q.Range then
			if Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.mana/myHero.maxMana >= Menu.Mana.QMana:Value() / 100 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
		end
	 

		if myHero.pos:DistanceTo(target.pos) <= W.Range then	
			if Menu.Harass.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= Menu.Mana.WMana:Value() / 100 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
					Control.CastSpell(HK_W, pred.CastPosition)
				end
			end
		end
	end
end
	
function AutoQFarm()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
			
		if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) < Q.Range and IsValid(minion) then
			local Qdamage =  getdmg("Q", minion, myHero)
			if Ready(_Q) and Menu.Lasthit.AutoQFarm:Value() and Qdamage > minion.health and myHero.mana/myHero.maxMana >= Menu.Mana.QMana:Value() / 100 then	
				Control.CastSpell(HK_Q,minion.pos)
			end
		end
	end
end

function Lasthit()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
			
		if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) < Q.Range and IsValid(minion) then
			if Menu.Lasthit.UseQ:Value() and Ready(_Q) then
				local Qdamage = getdmg("Q", minion, myHero)
				if Qdamage > minion.health and myHero.mana/myHero.maxMana >= Menu.Mana.QMana:Value() / 100 then
					Control.CastSpell(HK_Q,minion.pos)
				end
			end
		end
	end
end
	
	
function KS()
local target = GetTarget(1000)
if target == nil then return end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < Q.Range then 	
		if Menu.Killsteal.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
		   	local Qdamage = getdmg("Q", target, myHero)
			if Qdamage >= target.health then
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
		end
	end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < W.Range then	
		if Menu.Killsteal.UseW:Value() and Ready(_W) then 
			local pred = GetGamsteronPrediction(target, WData, myHero)
		   	local Wdamage = getdmg("W", target, myHero)
			if Wdamage >= target.health then
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
					Control.CastSpell(HK_W, pred.CastPosition)
				end
			end
		end
	end	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < R.Range and Menu.Killsteal.RR:Value() and Ready(_R) then   
		local Rdamage = getdmg("R", target, myHero)
		if Rdamage >= target.health then
			Control.CastSpell(HK_R, target)
		end
	end	
end




function SpellonCC()
local target = GetTarget(1000)
if target == nil then return end
		
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < Q.Range then	
		if Menu.isCC.UseQ:Value() and Ready(_Q) then
			local ImmobileEnemy = IsImmobileTarget(target)
			if ImmobileEnemy then
				Control.CastSpell(HK_Q, target.pos)
			
			end
		end
	end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < E.Range then	
		local ImmobileEnemy = IsImmobileTarget(target)
		if Menu.isCC.UseE:Value() and Ready(_E) and ImmobileEnemy then
			if Menu.Combo.EMode:Value() == 1 then
				Control.CastSpell(HK_E, Vector(target:GetPrediction(math.huge,0.25))-Vector(Vector(target:GetPrediction(math.huge,0.25))-Vector(myHero.pos)):Normalized()*375) 
			elseif Menu.Combo.EMode:Value() == 2 then
				Control.CastSpell(HK_E,target.pos)
			end
		end	
	end	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < W.Range then 	
		if Menu.isCC.UseW:Value() and Ready(_W) then
			local ImmobileEnemy = IsImmobileTarget(target)
			if ImmobileEnemy then
				Control.CastSpell(HK_W, target.pos)
			end
		end
	end	
end

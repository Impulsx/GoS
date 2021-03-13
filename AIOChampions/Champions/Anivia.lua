
--/////////////////Most is ported and reworked from Kiara789-Anivia//////////////////////

local MathAbs = math.abs
local MathAtan = math.atan
local PI = math.pi

local function GetData(islot)
	return myHero:GetSpellData(islot)
end

local function Polar(vector2D)
	if MathAbs(vector2D.x - 0) <= 1e-9 then
		return vector2D.y > 0 and 90 or (vector2D.y < 0 and 270 or 0)
	end

	local theta = MathAtan(vector2D.y / vector2D.x) * (180 / PI)
	if vector2D.x < 0 then
		theta = theta + 180
	end
	if theta < 0 then
		theta = theta + 360
	end
	return theta
end

local function AngleBetween(vector2D, toVector2D)
    local theta = Polar(vector2D) - Polar(toVector2D);
    if theta < 0 then
        theta = theta + 360;
	end

    if theta > 180 then
        theta = 360 - theta;
	end
    return theta;
end

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

local function GetAllyTurret()
	local _AllyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        if turret.isAlly and not turret.dead then
			TableInsert(_AllyTurrets, turret)
		end
	end
	return _AllyTurrets		
end

local function IsUnderAllyTurret(unit)
	for i, turret in ipairs(GetAllyTurret()) do
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2) 
		if turret.pos:DistanceTo(unit.pos) < range then
			return true
		end
    end
    return false
end

local OnPostAttack
OnPostAttack = function(fn)
    if _G.SDK then
        return _G.SDK.Orbwalker:OnPostAttack(fn)    
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:OnPostAttack(fn)
	end
end

local function GetWallLength()
	local data = myHero:GetSpellData(_W)
	
	if data.level == 0 then
		return 0
	end
	
	local lengths = { 400, 500, 600, 700, 800 }
	return lengths[data.level]
end

local function IsChilled(target)
	for i = 0, target.buffCount do
		local b = target:GetBuff(i)
		if b and b.name == "aniviachilled" and b.count > 0 and b.duration > 0 then
			return true
		end
	end
	return false
end

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

local QObject = { isValid = false, GameObject = nil, ID = nil }
local RObject = { isValid = false, GameObject = nil, isMaxed = false, ID = nil }
local LastSlot = nil
local RTimer = nil
local LastW = nil

local QData = { Range = 1000, Delay = 0.25, Speed = 950, Width = 125, Width2 = 225 }
local WData = { Range = 1000, Delay = 0.25, Width = GetWallLength() }
local EData = { Range = 600, Delay = 0.25, Speed = 1600 }
local RData = { Range = 750, Delay = 0.25, Speed = MathHuge, Width = 200 }

local function IsInStorm()
	if not RObject.isValid then
		return false
	end
	local Count = 0
	local Range = RData.Width * RData.Width
	for i, Enemy in ipairs(GetEnemyHeroes()) do
		if Enemy and IsValid(Enemy) and GetDistanceSqr(Enemy.pos, RObject.GameObject.pos) <= Range then
			Count = Count + 1
		end
	end
	return Count
end

local function GetHeroesInStorm()
	if not RObject.isValid then
		return nil
	end
	
	local t = {}
	for i = 1, GameHeroCount() do
		local hero = GameHero(i)
		if hero and IsValid(hero) and GetDistance(RObject.GameObject.pos, hero.pos) <= RData.Width + 150 then
			TableInsert(t, hero)
		end
		if i == GameHeroCount() then
			return t
		end
	end
	return nil
end

local function IsInQ2(unit)
	if QObject.isValid == false then
		return false
	end
	
	if GetDistance(QObject.GameObject.pos, unit.pos) <= QData.Width2 + 30 then
		return true
	end
end

local function IsSmartChilled(target)
	for i = 0, target.buffCount do
		local b = target:GetBuff(i)
		local _time = GetDistance(target.pos, myHero.pos) / (EData.Speed + EData.Delay)
		if b and b.name == "aniviachilled" and b.count > 0 and b.duration > _time then
			return true
		end
	end
	return false
end

local function GetPathNodes(unit)
	local nodes = {}
	TableInsert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			TableInsert(nodes, path)
		end
	end		
	return nodes
end

local function GetTargetMS(target)
	local ms = target.ms
	return ms
end

local function PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function LoadScript()	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})

	Menu:MenuElement({ type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]+[Q2]", value = true })
	Menu.Combo:MenuElement({ type = MENU, id = "ComboW", name = "[W] Settings"})
	Menu.Combo.ComboW:MenuElement({ id = "UseW", name = "Self HP / Enemy HP Logic", value = true})
	Menu.Combo.ComboW:MenuElement({id = "MyHp", name = "Push Back if Anivia Hp lower than ->", value = 30, min = 0, max = 100, identifier = "%"})
	Menu.Combo.ComboW:MenuElement({id = "EnemyHp", name = "Push to Anivia if Enemy Hp lower than ->", value = 40, min = 0, max = 100, identifier = "%"})	
	Menu.Combo.ComboW:MenuElement({ id = "UseW2", name = "Block Enemy run out of Ult", value = true})		
	Menu.Combo:MenuElement({ type = MENU, id = "ComboE", name = "[E] Settings"})
	Menu.Combo.ComboE:MenuElement({ id = "UseE", name = "[E]", value = true})
	Menu.Combo.ComboE:MenuElement({ id = "EMode", name = "[E] Mode", value = 3, drop = {"Always", "Fast", "Smart"}})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	Menu:MenuElement({ type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true })
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Harass:MenuElement({id = "EMode", name = "[E] Mode", value = 3, drop = {"Always", "Fast", "Smart"}})	

	Menu:MenuElement({ type = MENU, id = "Misc", name = "Auto Cast"})
	Menu.Misc:MenuElement({ id = "UseWR", name = "[R]+[W behind] if Enemy under AllyTower", value = true})	
	
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})

	GQData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 110, Range = 1100, Speed = 950, Collision = false
	}
	
	QspellData = {speed = 950, range = 1100, delay = 0.25, radius = 110, collision = {nil}, type = "linear"}
	
	GRData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 200, Range = 750, Speed = MathHuge, Collision = false
	}
	
	RspellData = {speed = MathHuge, range = 750, delay = 0.25, radius = 200, collision = {nil}, type = "circular"}	
	
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("WndMsg", function(msg, param) CheckWndMsg(msg, param) end)
	OnPostAttack(function(...) CheckObjects(...) end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end

		if Ready(_Q) and Menu.Drawing.DrawQ:Value() then
			DrawCircle(myHero.pos, QData.Range, DrawColor(255, 255, 255, 255))
		end
		if Ready(_E) and Menu.Drawing.DrawE:Value() then
			DrawCircle(myHero.pos, EData.Range, DrawColor(255, 255, 255, 255))
		end
		if Ready(_R) and Menu.Drawing.DrawR:Value() then
			DrawCircle(myHero.pos, RData.Range, DrawColor(255, 174, 237, 255))
		end	
	end)	
end

function Tick()	
	CheckSpells()
	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	end	
	if Mode ~= "Clear" then
		AutoW()
	end		
end

function CheckSpells()	
	if QObject.isValid == true then
		DelayAction(function()
			if not Ready(_Q) then
				QObject.isValid = false
				QObject.GameObject = nil
				QObject.ID = nil
			end
		end,0.05)	
	end
	
	if RTimer and RObject.isValid == true then
		if Game.Timer() - RTimer >= 1.5 then
			RData.Width = 400
			RObject.isMaxed = true		
		end
		if Game.Timer() - RTimer >= 1.2 and GameCanUseSpell(_R) > 0 then
			RData.Width = 200
			RObject.isValid = false
			RObject.GameObject = nil
			RObject.isMaxed = false
			RObject.ID = nil
			RTimer = nil
		end
	end	
end

function CheckWndMsg(msg, param)
	if msg == 257 then
		local delay = nil
		local Spell = nil
		if param == HK_Q then
			Spell = Q
			delay = 0.25 + ping
		elseif param == HK_R then
			RTimer = Game.Timer()
			Spell = R
			delay = 0.1 + ping
		end
	
		if delay then               
			DelayAction(function() 
				CheckObjects(Spell) 
			end, delay)
		end
	end	
end

function CheckTable(obj, spell)
	if spell == Q then
		if QObject.ID == obj.networkID then
			return true
		end
	end	
	if spell == R then
		if RObject.ID == obj.networkID then
			return true
		end
	end
	return false
end

function CheckObjects(spell)	
	if spell == Q then
		for i = 1, GameMissileCount() do
			local missile = GameMissile(i)	 
			if missile.missileData and missile.missileData.owner == myHero.handle and not CheckTable(missile, spell) then
				if missile.missileData.name:find("FlashFrostSpell") then
					QObject.isValid = true
					QObject.GameObject = missile
					QObject.ID = missile.networkID
					LastSlot = _Q
				end
			end	
		end
	end
	
	if spell == R then		
		for i = GameObjectCount(), 1, -1 do
			local obj = GameObject(i)
			if obj and obj.name == "Anivia_Base_R_indicator_ring" and not CheckTable(obj, spell) then
				RObject.isValid = true
				RObject.GameObject = obj
				RObject.ID = obj.networkID
				LastSlot = _R
			end
		end
	end	
end

function Combo()
	if GetHeroesInStorm() ~= nil and #GetHeroesInStorm() == 0 and myHero:GetSpellData(_R).toggleState == 2 then
		Control.CastSpell(HK_R)
	end

	local target = GetTarget(QData.Range)

	if target and IsValid(target) then
		if target.isImmortal then
			CastW(target)
			CastQ(target)
		else
			CastR(target)		
			CastQ(target)
			CastE(target)
			CastW(target)
		end
	end
end

function Harass()
	local target = GetTarget(QData.Range)
	
	if target and IsValid(target) then
		if target.isImmortal then
			CastQH(target)
		else
			CastQH(target)
			CastEH(target)
		end
	end
end

function AutoW()
	if not Menu.Misc.UseWR:Value() then return end
	for i, target in ipairs(GetEnemyHeroes()) do
		local data = myHero:GetSpellData(_R)
		if target and IsValid(target) and GetDistance(target.pos, myHero.pos) < WData.Range and IsUnderAllyTurret(target) then
			if Ready(_W) then				
				local WPos = Vector(target.pos) + Vector(myHero.pos - target.pos):Normalized() * -100
					--DrawCircle(EPos, 50, 1, DrawColor(225, 225, 125, 10))
				if GetDistance(WPos, myHero.pos) < WData.Range then
					LastW = Game.Timer()
					Control.CastSpell(HK_W, WPos)
				end
			end
		
			if LastW ~= nil then
				if Ready(_R) then													
					if data.toggleState == 1 then
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(target, GRData, myHero)
							if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
								Control.CastSpell(HK_R, pred.CastPosition)
							end
						elseif Menu.Pred.Change:Value() == 2 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
								Control.CastSpell(HK_R, pred.CastPos)
							end
						else
							local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 200, Range = 750, Speed = MathHuge, Collision = false})
							RPrediction:GetPrediction(target, myHero)
							if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
								Control.CastSpell(HK_R, RPrediction.CastPosition)
							end
						end
					elseif data.toggleState == 2 then
						local Count = IsInStorm()
						if Count == 0 then
							Control.CastSpell(HK_R)
							LastW = nil
						end
					end	
				end
			end
		else
			if data.toggleState == 2 then
				local Count = IsInStorm()
				if Count == 0 then
					Control.CastSpell(HK_R)
					LastW = nil
				end
			end		
		end
	end	
end

function CastQ(target)
	if not Menu.Combo.UseQ:Value() or not Ready(_Q) then return end
	
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.isChanneling or myHero.activeSpell.isAutoAttack then
		return
	end
	
	if GetDistance(target.pos, myHero.pos) < QData.Range and myHero:GetSpellData(_Q).toggleState == 1 then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(target, GQData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				Control.CastSpell(HK_Q, pred.CastPos)
			end
		else
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 110, Range = 1100, Speed = 950, Collision = false})
			QPrediction:GetPrediction(target, myHero)
			if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				Control.CastSpell(HK_Q, QPrediction.CastPosition)
			end
		end
		
	elseif myHero:GetSpellData(_Q).toggleState == 2 then
		if IsInQ2(target) then
			Control.CastSpell(HK_Q)
		end
	end
end

function CastQH(target)
	if not Menu.Harass.UseQ:Value() or not Ready(_Q) then return end
	
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.isChanneling or myHero.activeSpell.isAutoAttack then
		return
	end
	
	if GetDistance(target.pos, myHero.pos) < QData.Range and myHero:GetSpellData(_Q).toggleState == 1 then	
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(target, GQData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				Control.CastSpell(HK_Q, pred.CastPos)
			end
		else
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 110, Range = 1100, Speed = 950, Collision = false})
			QPrediction:GetPrediction(target, myHero)
			if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				Control.CastSpell(HK_Q, QPrediction.CastPosition)
			end
		end
		
	elseif myHero:GetSpellData(_Q).toggleState == 2 then
		if IsInQ2(target) then
			Control.CastSpell(HK_Q)
		end
	end
end

function CastW(target)
	if RObject.isValid and Menu.Combo.ComboW.UseW2:Value() and Ready(_W) then
		local path = PredictUnitPosition(target, 0.25 + GetDistance(target.pos, RObject.GameObject.pos) / target.ms)
		local p1 = Vector(target.pos) + (Vector(path) - Vector(target.pos)):Normalized() * 0.6 * target.ms
		if GetDistance(p1, myHero.pos) < 1000 and GetDistance(RObject.GameObject.pos, p1) > 150 and GetDistance(RObject.GameObject.pos, p1) < 250 and GetDistance(target.pos, path) > GetDistance(target.pos, p1) then
			Control.CastSpell(HK_W, p1)
		end
	end	
	
	if not Menu.Combo.ComboW.UseW:Value() or not Ready(_W) or (Ready(_Q) and QObject.isValid) then return end
	
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.isChanneling or myHero.activeSpell.isAutoAttack then
		return
	end
	
	local pHP = (myHero.health/myHero.maxHealth) * 100
	local pHPt = (target.health/target.maxHealth) * 100
	
	local dir = Vector(target.pos - myHero.pos)
	local offset = 0

	if (myHero.health/myHero.maxHealth <= Menu.Combo.ComboW.MyHp:Value()/100) or (target.health/target.maxHealth <= Menu.Combo.ComboW.EnemyHp:Value()/100) then
		if pHP > pHPt and not (GetDistance(target.pathing.endPos, myHero.pos) <= target.range) then
			offset = 200
		else 
			offset = 200 * (-1)
		end
		local endPos = dir:Normalized() * offset
		local finalPos = (target.pos + target.dir) + endPos
		local angle = AngleBetween(myHero.dir, target.pos - myHero.pos)
		
		if GetDistance(myHero.pos, target.pos) <= WData.Range and GetDistance(myHero.pos, target.pos) >= 450 and not (angle > 170 and angle <= 180) then
			Control.CastSpell(HK_W, finalPos)
		end
	end	
end

function CastE(target)
	if not Menu.Combo.ComboE.UseE:Value() or not Ready(_E) then return end
	
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.isChanneling or myHero.activeSpell.isAutoAttack then
		return
	end
	
	if GetDistance(target.pos, myHero.pos) <= EData.Range then
		if Menu.Combo.ComboE.EMode:Value() == 1 then
			Control.CastSpell(HK_E, target)
		elseif Menu.Combo.ComboE.EMode:Value() == 2 then
			if GetData(_Q).level == 0 and GetData(_R).level == 0 and GetData(_E).level > 0 then
				Control.CastSpell(HK_E, target)
			end
			if GetData(_Q).level > 0 and GetData(_R).level == 0 and GetData(_E).level > 0 then
				if IsChilled(target) then
					Control.CastSpell(HK_E, target)
				elseif myHero:GetSpellData(_Q).currentCd >= 1.5 and not Ready(_Q) and QObject.isValid == false then
					Control.CastSpell(HK_E, target)
				end
			end
			if GetData(_Q).level > 0 and GetData(_R).level > 0 and GetData(_E).level > 0 then
				if IsChilled(target) and (LastSlot == _Q or (LastSlot == _R and RObject.isMaxed)) then
					Control.CastSpell(HK_E, target)
				elseif not IsChilled(target) and (myHero:GetSpellData(_Q).currentCd >= 1.5 and not Ready(_Q)) and QObject.isValid == false and myHero:GetSpellData(_R).currentCd >= 2 then
					Control.CastSpell(HK_E, target)
				end
			end
		elseif Menu.Combo.ComboE.EMode:Value() == 3 then
			if GetData(_Q).level == 0 and GetData(_R).level == 0 and GetData(_E).level > 0 then
				Control.CastSpell(HK_E, target)
			end
			if GetData(_Q).level > 0 and GetData(_R).level == 0 and GetData(_E).level > 0 then
				if IsSmartChilled(target) then
					Control.CastSpell(HK_E, target)
				elseif myHero:GetSpellData(_Q).currentCd >= 1.5 and not Ready(_Q) and QObject.isValid == false then
					Control.CastSpell(HK_E, target)
				end
			end
			if GetData(_Q).level > 0 and GetData(_R).level > 0 and GetData(_E).level > 0 then
				if IsSmartChilled(target) and (LastSlot == _Q or (LastSlot == _R and RObject.isMaxed)) then
					Control.CastSpell(HK_E, target)
				elseif not IsSmartChilled(target) and (myHero:GetSpellData(_Q).currentCd >= 1.5 and not Ready(_Q)) and QObject.isValid == false and myHero:GetSpellData(_R).currentCd >= 2 then
					Control.CastSpell(HK_E, target)
				end
			end
		end
	end
end

function CastEH(target)
	if not Menu.Harass.UseE:Value() or not Ready(_E) then return end
	
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.isChanneling or myHero.activeSpell.isAutoAttack then
		return
	end
	
	if GetDistance(target.pos, myHero.pos) <= EData.Range then
		if Menu.Harass.EMode:Value() == 1 then
			Control.CastSpell(HK_E, target)
		elseif Menu.Harass.EMode:Value() == 2 then
			if GetData(_Q).level == 0 and GetData(_E).level > 0 then
				Control.CastSpell(HK_E, target)
			end
			if GetData(_Q).level > 0 and GetData(_E).level > 0 then
				if IsChilled(target) then
					Control.CastSpell(HK_E, target)
				elseif myHero:GetSpellData(_Q).currentCd >= 1.5 and not Ready(_Q) and QObject.isValid == false then
					Control.CastSpell(HK_E, target)
				end
			end
			if GetData(_Q).level > 0 and GetData(_E).level > 0 then
				if IsChilled(target) and LastSlot == _Q then
					Control.CastSpell(HK_E, target)
				elseif not IsChilled(target) and (myHero:GetSpellData(_Q).currentCd >= 1.5 and not Ready(_Q)) and QObject.isValid == false and myHero:GetSpellData(_R).currentCd >= 2 then
					Control.CastSpell(HK_E, target)
				end
			end
		elseif Menu.Harass.EMode:Value() == 3 then
			if GetData(_Q).level == 0 and GetData(_E).level > 0 then
				Control.CastSpell(HK_E, target)
			end
			if GetData(_Q).level > 0 and GetData(_E).level > 0 then
				if IsSmartChilled(target) then
					Control.CastSpell(HK_E, target)
				elseif myHero:GetSpellData(_Q).currentCd >= 1.5 and not Ready(_Q) and QObject.isValid == false then
					Control.CastSpell(HK_E, target)
				end
			end
			if GetData(_Q).level > 0 and GetData(_E).level > 0 then
				if IsSmartChilled(target) and LastSlot == _Q then
					Control.CastSpell(HK_E, target)
				elseif not IsSmartChilled(target) and (myHero:GetSpellData(_Q).currentCd >= 1.5 and not Ready(_Q)) and QObject.isValid == false and myHero:GetSpellData(_R).currentCd >= 2 then
					Control.CastSpell(HK_E, target)
				end
			end
		end
	end
end

function CastR(target)
	if not Menu.Combo.UseR:Value() or not Ready(_R) then return end
	
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.isChanneling or myHero.activeSpell.isAutoAttack then
		return
	end
	
	if GetDistance(target.pos, myHero.pos) <= RData.Range then
		local data = myHero:GetSpellData(_R)
		
		if data.toggleState == 1 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, GRData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					Control.CastSpell(HK_R, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					Control.CastSpell(HK_R, pred.CastPos)
				end
			else
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 200, Range = 750, Speed = MathHuge, Collision = false})
				RPrediction:GetPrediction(target, myHero)
				if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
					Control.CastSpell(HK_R, RPrediction.CastPosition)
				end
			end
		elseif data.toggleState == 2 and not LastW then
			local Count = IsInStorm()
			if Count == 0 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

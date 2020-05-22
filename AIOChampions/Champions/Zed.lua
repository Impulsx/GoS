local function GetEnemyHeroes()
	return Enemies
end

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, GameHeroCount() do 
	local hero = GameHero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
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

local function DistanceSquared(p1, p2)
	local dx, dy = p2.x - p1.x, p2.z - p1.z
	return dx * dx + dy * dy
end

local function GetCircularAOEPos(points, radius)
    local bestPos, count = Vector(0, 0, 0), #points
    if count == 0 then return nil, 0 end
    if count == 1 then return points[1], 1 end
    local inside, furthest, id = 0, 0, 0
    for i, point in ipairs(points) do
        bestPos = bestPos + point
    end
    bestPos = bestPos / count
    for i, point in ipairs(points) do
        local distSqr = DistanceSquared(bestPos, point)
        if distSqr < radius * radius then inside = inside + 1 end
        if distSqr > furthest then furthest = distSqr; id = i end
    end
    if inside == count then
        return bestPos, count
    else
        TableRemove(points, id)
        return GetCircularAOEPos(points, radius)
    end
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})			
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})	
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "Use Kill[R]", value = true})		
	Menu.Combo.Ult:MenuElement({id = "UseRTower", name = "Use Kill[R] Dive under Tower", value = true})

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W1]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Energy to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = false})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W1] + [E]", value = true})  
	Menu.Clear:MenuElement({id = "UseWM", name = "Use [W1] + [E] min Minions", value = 3, min = 1, max = 6})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Energy to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = false})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Energy to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  

	--Flee
	Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
	Menu.Flee:MenuElement({id = "key", name = "Flee Key", key = string.byte("A")})	
	Menu.Flee:MenuElement({id = "UseQ", name = "[Q] if possible", value = true})         	
	Menu.Flee:MenuElement({id = "UseW", name = "[W1] + [W2]", value = true})
	Menu.Flee:MenuElement({id = "UseE", name = "[E] if possible", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "QC", name = "[Q Combo Mode] check minion collision", value = true})
	Menu.Pred:MenuElement({id = "QH", name = "[Q Harass Mode] check minion collision", value = false})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	QDataC =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 45, Range = 900, Speed = 900, 
	if Menu.Pred.QC:Value() then Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION} else Collision = false end
	}
	
	QspellDataC = {speed = 900, range = 900, delay = 0.25, radius = 45, type = "linear"}, 
	if Menu.Pred.QC:Value() then collision = {"minion"} else collision = {nil} end
	
	QDataH =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 45, Range = 900, Speed = 900, 
	if Menu.Pred.QH:Value() then Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION} else Collision = false end
	}
	
	QspellDataH = {speed = 900, range = 900, delay = 0.25, radius = 45, type = "linear"}, 
	if Menu.Pred.QH:Value() then collision = {"minion"} else collision = {nil} end	

  	                                           
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	elseif _G.PremiumOrbwalker then
		Orb = 5		
	end	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 625, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 650, 1, DrawColor(225, 225, 0, 10))
		end		
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 290, 1, DrawColor(225, 225, 125, 10))
		end		
	end)		
end

local Wshadow = {}
local Rshadow = {}

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		--Ult()
		Combo()	
	elseif Mode == "Harass" then
		--Harass()
	elseif Mode == "Clear" then
		--Clear()
		--JungleClear()
	elseif Mode == "Flee" then
		if Menu.Flee.key:Value() then
			--Flee()
		end	
	end
end	

function Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
		local W1Casted = false
		local Wready = false
		local QcanCast = false
		local Qready = false
		
		if Ready(_Q) or myHero:GetSpellData(_Q).currentCd < 3 then
			Qready = true
		end		
		
		if Ready(_W) or myHero:GetSpellData(_W).currentCd < 3 then
			Wready = true
		end	
		
		if myHero.pos:DistanceTo(target.pos) < 850 and Menu.Combo.UseQ:Value() then
			if Wready then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QDataC, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 and Ready(_Q) then
						QcanCast = true
						if W1Casted then
							ControlCastSpell(HK_Q, pred.CastPosition)
							Wready = false
						end	
					else
						QcanCast = false
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellDataC)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) and Ready(_Q) then
						QcanCast = true
						if W1Casted then					
							ControlCastSpell(HK_Q, pred.CastPos)
							Wready = false
						end	
					else
						QcanCast = false					
					end	
				end
			else
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QDataC, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 and Ready(_Q) then
						ControlCastSpell(HK_Q, pred.CastPosition)
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellDataC)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) and Ready(_Q) then					
						ControlCastSpell(HK_Q, pred.CastPos)					
					end	
				end			
			end	
		end	
	
		if myHero.pos:DistanceTo(target.pos) <= 290 or W1Casted and Menu.Combo.UseE:Value() and Ready(_E) then
			ControlCastSpell(HK_E)
		end			
		
		if Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" then
			if Qready then
				if QcanCast then
					ControlCastSpell(HK_W, target.pos)
					W1Casted = true
				end
			else
				if Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 890 then
					ControlCastSpell(HK_W, target.pos)
				end	
			end	
		end	
	end
end

--[[
function Ult()
	if Menu.Combo.Ult.UseRcount:Value() then	
		for i, unit in pairs(GetEnemyHeroes()) do
			local points = {}
			if unit and myHero.pos:DistanceTo(unit.pos) <= 1100 then TableInsert(points, unit.pos) end
			local bestPos, count1 = GetCircularAOEPos(points, 600)
			if ActiveUlt then
				if myHero.activeSpell.valid and myHero.activeSpell.name == "FiddleSticksR" then
					if bestPos and myHero.pos:DistanceTo(bestPos) > 300 then
						if not ActiveW then
							Control.SetCursorPos(bestPos)
							Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
							Control.mouse_event(MOUSEEVENTF_RIGHTUP)
						end
						if ActiveW and myHero.pos:DistanceTo(bestPos) > 450 then
							Control.SetCursorPos(bestPos)
							Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
							Control.mouse_event(MOUSEEVENTF_RIGHTUP)
						end	
					end
				else
					ActiveUlt = false
				end
			else
				SetMovement(true)
			end	

			if Ready(_R) then
				local count1 = GetEnemyCount(2000, myHero)
				if count1 >= Menu.Combo.Ult.Rcount:Value() then
					if bestPos and count1 >= Menu.Combo.Ult.Rcount:Value() and myHero.pos:DistanceTo(bestPos) < 800 then
						local double = GetInventorySlotItem(3330)
						SetMovement(false)
						ControlCastSpell(HK_R, bestPos)
						ActiveUlt = true
						if Menu.Combo.Ult.ward:Value() and double then
							ControlCastSpell(ItemHotKey[double], bestPos)
						end	
					end	
				end
			end
		end	
	end
	
	local target = GetTarget(1000)
	if target == nil then return end	
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) < 800 and Ready(_R) and Menu.Combo.Ult.UseR:Value() then
			if target.health/target.maxHealth <= Menu.Combo.Ult.Rhp:Value() / 100 then
				ControlCastSpell(HK_R, target.pos)
			end
		end	
	end	
end

function Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
        
		if myHero.pos:DistanceTo(target.pos) <= 575 and Menu.Harass.UseQ:Value() and Ready(_Q) and mana_ok then
			ControlCastSpell(HK_Q, target)
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 800 and Menu.Harass.UseE:Value() and Ready(_E) and mana_ok then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then				
					ControlCastSpell(HK_E, pred.CastPosition)					
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then			
					ControlCastSpell(HK_E, pred.CastPos)					
				end	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 300 and Menu.Harass.UseW:Value() and Ready(_W) and mana_ok then
			ControlCastSpell(HK_W)
		end		
	end
end	

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 575 and IsValid(minion) and Ready(_Q) then
				ControlCastSpell(HK_Q, minion)
            end
			
            if Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 600 and IsValid(minion) and Ready(_W) then
                local count = GetMinionCount(575, minion)
				if count >= Menu.Clear.UseWM:Value() then
					ControlCastSpell(HK_W)
				end
            end
			
			if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and Ready(_E) then
				ControlCastSpell(HK_E, minion.pos)
            end			
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 575 and IsValid(minion) and Ready(_Q) then
                ControlCastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 550 and IsValid(minion) and Ready(_W) then	
				ControlCastSpell(HK_W)
            end
			
			if Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and Ready(_E) then
				ControlCastSpell(HK_E, minion.pos)
            end			
        end
    end
end
]]
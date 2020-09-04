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

local function GetInventorySlotItem(itemID)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
    for _, j in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}) do
        if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
    end
    return nil
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})			
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})	
	Menu.Combo.Ult:MenuElement({id = "UseRcount", name = "Use[R] count targets", value = true})
	Menu.Combo.Ult:MenuElement({id = "ward", name = "Use Double [Ward]", value = true})	
	Menu.Combo.Ult:MenuElement({id = "Rcount", name = "Use[R] min Targets", value = 2, min = 2, max = 5}) 
	Menu.Combo.Ult:MenuElement({name = " ", drop = {"--------------------------"}})	
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "Use[R] single target [HP check]", value = true})
	Menu.Combo.Ult:MenuElement({id = "Rhp", name = " Is single target Hp lower than -->", value = 40, min = 0, max = 100, identifier = "%"}) 

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = false})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})  
	Menu.Clear:MenuElement({id = "UseWM", name = "Use[W] min Minions", value = 3, min = 1, max = 6})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = false})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = false})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = false})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 35, Range = 850, Speed = 1800, Collision = false
	}
	
	EspellData = {speed = 1800, range = 850, delay = 0.25, radius = 35, collision = {nil}, type = "linear"}	

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 800, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 575, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 575, 1, DrawColor(225, 225, 0, 10))
		end		
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 850, 1, DrawColor(225, 225, 125, 10))
		end		
	end)		
end

local ActiveUlt = false
local ActiveW = false

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Ult()
		Combo()	
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()		
	end
end	

function Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
	
		if myHero.pos:DistanceTo(target.pos) <= 575 and Menu.Combo.UseQ:Value() and Ready(_Q) and not ActiveW then
			Control.CastSpell(HK_Q, target)
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 800 and Menu.Combo.UseE:Value() and Ready(_E) and not ActiveW then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then				
					Control.CastSpell(HK_E, pred.CastPosition)					
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then			
					Control.CastSpell(HK_E, pred.CastPos)					
				end	
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 35, Range = 850, Speed = 1800, Collision = false})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end					
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 300 and Menu.Combo.UseW:Value() and Ready(_W) then
			ActiveW = true
			Control.CastSpell(HK_W)	
			SetAttack(false)
		end	
		
		if ActiveW and myHero.activeSpell.valid and myHero.activeSpell.name == "FiddleSticksW" then
			SetMovement(false)
		else
			SetAttack(true)
			SetMovement(true)
			ActiveW = false
		end
	end
end

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
						Control.CastSpell(HK_R, bestPos)
						ActiveUlt = true
						if Menu.Combo.Ult.ward:Value() and double then
							Control.CastSpell(ItemHotKey[double], bestPos)
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
				Control.CastSpell(HK_R, target.pos)
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
			Control.CastSpell(HK_Q, target)
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 800 and Menu.Harass.UseE:Value() and Ready(_E) and mana_ok then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then				
					Control.CastSpell(HK_E, pred.CastPosition)					
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then			
					Control.CastSpell(HK_E, pred.CastPos)					
				end	
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 35, Range = 850, Speed = 1800, Collision = false})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end					
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 300 and Menu.Harass.UseW:Value() and Ready(_W) and mana_ok then
			Control.CastSpell(HK_W)
		end		
	end
end	

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 575 and IsValid(minion) and Ready(_Q) then
				Control.CastSpell(HK_Q, minion)
            end
			
            if Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 600 and IsValid(minion) and Ready(_W) then
                local count = GetMinionCount(575, minion)
				if count >= Menu.Clear.UseWM:Value() then
					Control.CastSpell(HK_W)
				end
            end
			
			if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and Ready(_E) then
				Control.CastSpell(HK_E, minion.pos)
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
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 550 and IsValid(minion) and Ready(_W) then	
				Control.CastSpell(HK_W)
            end
			
			if Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and Ready(_E) then
				Control.CastSpell(HK_E, minion.pos)
            end			
        end
    end
end

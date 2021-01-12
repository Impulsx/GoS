
local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

local function GetDistance(pos1, pos2)
	return math.sqrt(GetDistanceSqr(pos1, pos2))
end

local function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff
		end
	end
	return false
end

local function EnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

local function GetEnemyCount(range, pos)
	local count = 0
	for i, hero in ipairs(EnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function GetBlazeEnemyCount(unit)
	local count = 0
	for i, hero in ipairs(EnemyHeroes()) do
		local Radius = 600 * 600
		local Blaze = GetBuffData(hero, "BrandAblaze")
		if hero and hero ~= unit and GetDistanceSqr(unit.pos, hero.pos) < Radius and IsValid(hero) and Blaze then
		count = count + 1
		end
	end
	return count
end

local function GetMinionNearUnit(pos)
    local pos = pos.pos
	local target = nil
	for i = 1,GameMinionCount() do
	local hero = GameMinion(i)
	local Blaze = GetBuffData(hero, "BrandAblaze")
	local Range = Blaze and 600*600 or 300*300
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistance(myHero.pos, hero.pos) < 675 and GetDistanceSqr(pos, hero.pos) < Range then
			target = hero
		end
	end
	return target
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

local function GetCenter(points)
	local sum_x = 0
	local sum_z = 0
	
	for i = 1, #points do
		sum_x = sum_x + points[i].pos.x
		sum_z = sum_z + points[i].pos.z
	end	
	local center = {x = sum_x / #points, y = 0, z = sum_z / #points}	
	return center
end

local function ContainsThemAll(circle, points)
	local _sqrt = circle.radius*circle.radius
	local contains_them_all = true
	local i = 1
	
	if contains_them_all and i <= #points then
		contains_them_all = GetDistanceSqr(points[i].pos, circle.center) <= _sqrt
		i = i + 1
	end       
	return contains_them_all
end

function FarthestFromPositionIndex(points, position)
    local index = 2
	local actual_dist_sqr
    local max_dist_sqr = GetDistanceSqr(points[index], position)       
	
	for i = 3, #points do
		actual_dist_sqr = GetDistanceSqr(points[i].pos, position)
		if actual_dist_sqr > max_dist_sqr then
			index = i
			max_dist_sqr = actual_dist_sqr
		end
	end
	return index
end

local function RemoveWorst(targets, position)
    local worst_target = FarthestFromPositionIndex(targets, position)       
    TableRemove(targets, worst_target)
    return targets
end

local function GetInitialTargets(radius, unit)
    local targets = {unit}
    local _sqrt = 4 * radius * radius
        
	for i, target in ipairs(EnemyHeroes()) do
        if target and target.networkID ~= unit.networkID and IsValid(target) and GetDistanceSqr(unit.pos, target.pos) < _sqrt then 
			TableInsert(targets, target) 
		end       
	end
    return targets
end

local function GetAoEPosition(radius, unit)
	local targets = GetInitialTargets(radius, unit)
	local position = GetCenter(targets)
	local best_pos_found = true
	local circle = {position = position, radius = radius}
	circle.center = position
	
	if #targets > 2 then 
		best_pos_found = ContainsThemAll(circle, targets) 
	end
	
	if not best_pos_found then
		targets = RemoveWorst(targets, position)
		position = GetCenter(targets)
		circle.center = position
		best_pos_found = ContainsThemAll(circle, targets)
	end
		
	return position, #targets
end
	
function LoadScript()                     
	
--MainMenu
Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
--Combo 
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR1", name = "[R] Count Enemy check", value = true})
	Menu.Combo:MenuElement({id = "RCount", name = "[R] Count min Enemies", value = 3, min = 1, max = 6})
	Menu.Combo:MenuElement({id = "UseR2", name = "[R] If have more than 2 Enemies Blaze", value = true})	
					
--Harass		
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Mode"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	

--LaneClear Menu
Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear Mode"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true}) 			
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})  
	Menu.Clear:MenuElement({id = "UseWM", name = "[W] min Minions", value = 3, min = 1, max = 6})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})  
	Menu.Clear:MenuElement({id = "UseEM", name = "[E] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
--JungleClear
Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear Mode"})  
 	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})      	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 25, min = 0, max = 100, identifier = "%"}) 	
				
--Prediction
Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})	

--Drawing 
Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end                                                 
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			Draw.Circle(myHero, 750, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			Draw.Circle(myHero, 675, 1, Draw.Color(225, 225, 125, 10))
		end	
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			Draw.Circle(myHero, 900, 1, Draw.Color(225, 225, 125, 10))
		end			
	end)

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25+ping, Radius = 60, Range = 1100, Speed = 1600, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1600, range = 1100, delay = 0.25+ping, radius = 60, collision = {"minion"}, type = "linear"}
	
	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.9+ping, Radius = 260, Range = 900, Speed = MathHuge
	}
	
	WspellData = {speed = MathHuge, range = 900, delay = 0.9+ping, radius = 260, collision = {nil}, type = "circular"}		
	
end

function Tick()						
	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		KSCombo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()		
	end	
end

function KSCombo()
	for i, enemy in ipairs(EnemyHeroes()) do
		if enemy and GetDistance(myHero.pos, enemy.pos) <= 1000 and IsValid(enemy) then
			qDmg = Ready(_Q) and getdmg("Q", enemy, myHero) or 0
			wDmg = Ready(_W) and getdmg("W", enemy, myHero) or 0
            eDmg = Ready(_E) and getdmg("E", enemy, myHero) or 0
			rDmg = getdmg("R", enemy, myHero)

			if enemy.health <= qDmg then
				CastQ(enemy)
				return
			elseif enemy.health <= eDmg and GetDistance(enemy.pos, myHero.pos) < 650 then
				Control.CastSpell(HK_E, enemy)
				return
			elseif enemy.health <= wDmg and GetDistance(enemy.pos, myHero.pos) < 900 then
				CastW(enemy)
				return					
			elseif enemy.health <= (qDmg + wDmg + eDmg + rDmg) and GetDistance(enemy.pos, myHero.pos) <= 500 and Ready(_R) then
				Control.CastSpell(HK_R, enemy)
				return
			else
				Combo()
			end
		end
	end
end

function Combo()	
	local target = GetTarget(1000)     	
	if target == nil then return end	
	if IsValid(target) then
		local Blaze = GetBuffData(target, "BrandAblaze")
		
		if Menu.Combo.UseE:Value() and Ready(_E) then
			if GetDistance(myHero.pos, target.pos) <= 650 then
				Control.CastSpell(HK_E, target)
			else
				local Minion = GetMinionNearUnit(target)
				if Minion then
					Control.CastSpell(HK_E, Minion)
				end
			end	
		end			

		if Menu.Combo.UseW:Value() and Ready(_W) and GetDistance(myHero.pos, target.pos) < 900 then
			CastWAOE(target)
		end		
		
		if Blaze and Blaze.duration >= (0.3+(GetDistance(myHero.pos, target.pos)/1600)) and Menu.Combo.UseQ:Value() and Ready(_Q) then
			CastQ(target)
		end			
		
		if Menu.Combo.UseR1:Value() and Ready(_R) and GetDistance(myHero.pos, target.pos) < 750 then
			if GetEnemyCount(600, target.pos) >= Menu.Combo.RCount:Value() then
				Control.CastSpell(HK_R, target)
			end
		end	
		
		if Menu.Combo.UseR2:Value() and Ready(_R) then
			for i, enemy in ipairs(EnemyHeroes()) do
				if enemy and IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) < 750 then
					local Buff = GetBuffData(enemy, "BrandAblaze")
					if Buff then
						local Count = GetBlazeEnemyCount(enemy)
						if Count+1 >= 2 then
							Control.CastSpell(HK_R, enemy)
						end
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
		
		local Blaze = GetBuffData(target, "BrandAblaze")
		
		if Menu.Harass.UseE:Value() and Ready(_E) then
			if GetDistance(myHero.pos, target.pos) <= 650 then
				Control.CastSpell(HK_E, target)
			else
				local Minion = GetMinionNearUnit(target)
				if Minion then
					Control.CastSpell(HK_E, Minion)
				end
			end	
		end			

		if Menu.Harass.UseW:Value() and Ready(_W) and GetDistance(myHero.pos, target.pos) < 900 then
			CastWAOE(target)
		end		

		if Blaze and Blaze.duration >= (0.25+(GetDistance(myHero.pos, target.pos)/1600)) and Menu.Harass.UseQ:Value() and Ready(_Q) then
			CastQ(target)
		end					
	end	
end

function CastWAOE(unit)	
	local CastPos = GetAoEPosition(260, unit)
	if CastPos and GetDistance(CastPos, myHero.pos) < 850 then
		--DrawCircle(Vector(CastPos), 300, 1, DrawColor(255, 225, 255, 10))
		--DrawCircle(Vector(CastPos), 30, 1, DrawColor(255, 225, 255, 10))		
		if GetEnemyCount(260, CastPos) >= 2 then
			Control.CastSpell(HK_W, CastPos)
		else
			CastW(unit)		
		end
	else
		CastW(unit)
	end	
end

function CastQ(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, QData, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
			Control.CastSpell(HK_Q, pred.CastPos)
		end
	else
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25+ping, Radius = 60, Range = 1100, Speed = 1600, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end		
	end
end

function CastW(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
			Control.CastSpell(HK_W, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
			Control.CastSpell(HK_W, pred.CastPos)
		end
	else
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.9+ping, Radius = 260, Range = 900, Speed = MathHuge, Collision = false})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value()+1) then
			Control.CastSpell(HK_W, WPrediction.CastPosition)
		end		
	end
end

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY and GetDistance(minion.pos, myHero.pos) < 900 then
            if IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				
				if Menu.Clear.UseW:Value() and Ready(_W) then
					local count = GetMinionCount(260, minion)
					if count >= Menu.Clear.UseWM:Value() then
						Control.CastSpell(HK_W, minion.pos)
					end
				
				elseif Menu.Clear.UseE:Value() and Ready(_E) and GetDistance(minion.pos, myHero.pos) < 650 then
					local Radius
					local Blaze = GetBuffData(minion, "BrandAblaze") 
					if Blaze then
						Radius = 600
					else
						Radius = 300
					end	
					local count = GetMinionCount(Radius, minion)
					if count >= Menu.Clear.UseEM:Value() then
						Control.CastSpell(HK_E, minion)
					end
				else
					if Menu.Clear.UseQ:Value() and Ready(_Q) then
						Control.CastSpell(HK_Q, minion.pos)	
					end	
				end
			end
			
		elseif minion.team == TEAM_JUNGLE and GetDistance(minion.pos, myHero.pos) < 900 then
            if IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
				
				if Menu.JClear.UseE:Value() and Ready(_E) and GetDistance(minion.pos, myHero.pos) < 650 then
					Control.CastSpell(HK_E, minion)					
								
				elseif Menu.JClear.UseW:Value() and Ready(_W) then
					Control.CastSpell(HK_W, minion.pos)	
				
				else	
					if Menu.Clear.UseQ:Value() and Ready(_Q) then
						Control.CastSpell(HK_Q, minion.pos)	
					end					
				end
			end		
        end
    end
end

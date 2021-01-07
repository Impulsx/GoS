
local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

local function GetDistance(pos1, pos2)
	return math.sqrt(GetDistanceSqr(pos1, pos2))
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
Menu:MenuElement({name = " ", drop = {"Version 0.03"}})
	
--Combo 
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({id = "Mode", name = "[R] Mode", value = 4, drop = {"Everytime", "[R-AOE]", "[R] KSCombo", "[R-AOE] + [R] KSCombo"}})	
	Menu.Combo:MenuElement({id = "Count", name = "[R-AOE] Min Enemies", value = 3, min = 2, max = 5})
	Menu.Combo:MenuElement({id = "Targets", name = "[R] KSCombo White List", type = MENU})
	DelayAction(function()
		for i, Hero in pairs(EnemyHeroes()) do
			Menu.Combo.Targets:MenuElement({id = Hero.charName, name = "[R] KSCombo on "..Hero.charName, value = true})		
		end
	end,0.2)	
					
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
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})	

--Drawing 
Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end                                                 
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			Draw.Circle(myHero, 1000, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			Draw.Circle(myHero, 625, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			Draw.Circle(myHero, 400, 1, Draw.Color(225, 225, 125, 10))
		end		
	end)


	RData ={Type = _G.SPELLTYPE_CIRCLE, Delay = ping, Radius = 160, Range = 1000, Speed = 1835+myHero.ms, Collision = false}
	RspellData = {speed = 1835+myHero.ms, range = 1000, delay = ping, radius = 160, collision = {nil}, type = "circular"}
	
end

local KsUltTarget = nil
function Tick()						
	if MyHeroNotReady() then return end

	if KsUltTarget then
		GetPredR(KsUltTarget)
		if not Ready(_R) then
			KsUltTarget = nil
		end
	end	

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
			WDmg = Ready(_W) and getdmg("W", enemy, myHero) or 0
            eDmg = Ready(_E) and getdmg("E", enemy, myHero) or 0
			rDmg = getdmg("R", enemy, myHero) + (getdmg("AA", enemy, myHero)*2)

			if enemy.health <= qDmg and GetDistance(enemy.pos, myHero.pos) < 625 then
				Control.CastSpell(HK_Q, enemy)
				return
			elseif enemy.health <= eDmg and GetDistance(enemy.pos, myHero.pos) < 350 then
				Control.CastSpell(HK_E, enemy)
				return																		
			elseif (Menu.Combo.Mode:Value() == 3 or Menu.Combo.Mode:Value() == 4) and enemy.health <= (qDmg + WDmg + eDmg + rDmg) and GetDistance(enemy.pos, myHero.pos) <= 900 and Ready(_R) and Menu.Combo.Targets[enemy.charName] and Menu.Combo.Targets[enemy.charName]:Value() then
				KsUltTarget = enemy
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
		
		if Menu.Combo.UseE:Value() and Ready(_E) and GetDistance(myHero.pos, target.pos) <= 350 then
			Control.CastSpell(HK_E, target)
		end			

		if Menu.Combo.UseW:Value() and Ready(_W) and GetDistance(myHero.pos, target.pos) < 225 then
			Control.CastSpell(HK_W, target)
		end		
		
		if Menu.Combo.UseR:Value() and Ready(_R) then
			if (Menu.Combo.Mode:Value() == 2 or Menu.Combo.Mode:Value() == 4) then
				CastRAOE(target)
			elseif Menu.Combo.Mode:Value() == 1 then
				GetPredR(target)
			end	
		end	

		if Menu.Combo.UseQ:Value() and Ready(_Q) and GetDistance(myHero.pos, target.pos) < 625 then
			Control.CastSpell(HK_Q, target)
		end	
	end		
end

function Harass()
	local target = GetTarget(625)     	
	if target == nil then return end
	if IsValid(target) then
		
		if Menu.Harass.UseQ:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q, target)
		end	

		if Menu.Harass.UseE:Value() and Ready(_E) and GetDistance(myHero.pos, target.pos) <= 350 then
			Control.CastSpell(HK_E, target)
		end			

		if Menu.Harass.UseW:Value() and Ready(_W) and GetDistance(myHero.pos, target.pos) < 225 then
			Control.CastSpell(HK_W, target)
		end			
	end	
end

function CastRAOE(unit)	
	local ultPos = GetAoEPosition(300, unit)
	if ultPos and GetDistance(ultPos, myHero.pos) < 1000 then
		--DrawCircle(Vector(ultPos), 300, 1, DrawColor(255, 225, 255, 10))
		--DrawCircle(Vector(ultPos), 30, 1, DrawColor(255, 225, 255, 10))		
		if GetEnemyCount(300, ultPos) >= Menu.Combo.Count:Value() then
			Control.CastSpell(HK_R, ultPos)
		end
	end	
end

function GetPredR(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, RData, myHero)
		if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
			Control.CastSpell(HK_R, pred.CastPos)
		end
	else
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = ping, Radius = 160, Range = 1000, Speed = 1835+myHero.ms, Collision = false})
		RPrediction:GetPrediction(unit, myHero)
		if RPrediction:CanHit(Menu.Pred.PredR:Value()+1) then
			Control.CastSpell(HK_R, RPrediction.CastPosition)
		end		
	end
end

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY and GetDistance(minion.pos, myHero.pos) < 625 then
            if IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				if Menu.Clear.UseQ:Value() and Ready(_Q) then
					Control.CastSpell(HK_Q, minion)	
				
				elseif Menu.Clear.UseW:Value() and Ready(_W) then
					local count = GetMinionCount(350, myHero)
					if count >= Menu.Clear.UseWM:Value() then
						Control.CastSpell(HK_W, minion)
					end
				else
					if Menu.Clear.UseE:Value() and Ready(_E) then
						local count = GetMinionCount(400, myHero)
						if count >= Menu.Clear.UseEM:Value() then
							Control.CastSpell(HK_E, minion)
						end
					end					
				end
			end
			
		elseif minion.team == TEAM_JUNGLE and GetDistance(minion.pos, myHero.pos) < 625 then
            if IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
				if Menu.JClear.UseE:Value() and Ready(_E) and GetDistance(minion.pos, myHero.pos) < 350 then
					Control.CastSpell(HK_E, minion)					
				
				elseif Menu.JClear.UseQ:Value() and Ready(_Q) then
					Control.CastSpell(HK_Q, minion)	
				
				else
					if Menu.JClear.UseW:Value() and Ready(_W) and GetDistance(minion.pos, myHero.pos) < 300 then
						Control.CastSpell(HK_W)
					end	
				end
			end		
        end
    end
end

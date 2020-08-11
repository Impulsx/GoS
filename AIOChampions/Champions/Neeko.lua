local function IsValidRange(unit, range)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) and myHero.pos:DistanceTo(unit.pos) <= range then
        return true;
    end
    return false;
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

local function GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0
end

local function CountEnemiesNear(pos, range)
    local pos = pos.pos
	local count = 0
	for i = 1, GameHeroCount() do 
	local hero = GameHero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end	

local function GetAllyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, GameHeroCount() do 
	local hero = GameHero(i)
	local Range = range * range
		if hero.team == TEAM_ALLY and hero ~= myHero and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
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

local function GetAllyHeroes()
    local _AllyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isAlly and unit ~= myHero then
            TableInsert(_AllyHeroes, unit)
        end
    end
    return _AllyHeroes
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

local function GetImmobileCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, GameHeroCount() do 
	local hero = GameHero(i)
	local Range = range * range
		if hero.isEnemy and GetDistanceSqr(pos, hero.pos) < Range and IsImmobileTarget(hero) then
		count = count + 1
		end
	end
	return count
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
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

local function GetLineTargetCount(source, Pos, delay, speed, width, range)
	local Count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
		if hero and myHero.pos:DistanceTo(hero.pos) <= range and IsValid(hero) then
			
			local predictedPos = PredictUnitPosition(hero, delay+ GetDistance(source, hero.pos) / speed)
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(source, Pos, predictedPos)
			if proj1 and isOnSegment and (GetDistanceSqr(predictedPos, proj1) <= (hero.boundingRadius + width) * (hero.boundingRadius + width)) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function LoadScript()

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.07"}})	
	
	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})	
	Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E] 2-5 Targets", value = true})	
 
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	--[W]+[R]
	Menu.Combo.Ult:MenuElement({type = MENU, id = "WR", name = "Check in NeekoRange"})	
	Menu.Combo.Ult.WR:MenuElement({id = "UseR", name = "[R]+[W]", value = true, tooltip = "If [W] not Ready then only [R]"})
 	Menu.Combo.Ult.WR:MenuElement({id = "RHit", name = "min. Targets", value = 2, min = 1, max = 5})	
	--Ult Ally Range
	Menu.Combo.Ult:MenuElement({type = MENU, id = "Ally", name = "Check in AllyRange"})
	Menu.Combo.Ult.Ally:MenuElement({id = "UseR2", name = "Flash+[R]+[W] 2-5Targets", value = true, tooltip = "Check Enemys in Ally Range"})
	--Ult Immobile
	Menu.Combo.Ult:MenuElement({type = MENU, id = "Immo", name = "Ult Immobile"})	
	Menu.Combo.Ult.Immo:MenuElement({id = "UseR3", name = "Flash+[R]+[W]", value = true, tooltip = "Check Immobile Targets"})
 	Menu.Combo.Ult.Immo:MenuElement({id = "UseR3M", name = "min. Immobile Targets", value = 2, min = 1, max = 5})
	--Ult 1vs1
	Menu.Combo.Ult:MenuElement({type = MENU, id = "One", name = "1vs1"})	
	Menu.Combo.Ult.One:MenuElement({id = "UseR1", name = "[R]+[W] If Killable", value = true, tooltip = "If [W] not Ready then only [R]"})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({type = MENU, id = "LH", name = "LastHit"})	
	Menu.Harass.LH:MenuElement({id = "UseQL", name = "LastHit[Q] Minions", value = true, tooltip = "There is no Enemy nearby"})	
	Menu.Harass.LH:MenuElement({id = "UseQLM", name = "min. Minions", value = 2, min = 1, max = 6})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	Menu.Clear:MenuElement({id = "UseQL", name = "LastHit[Q] Blooming Burst", value = true})	
	Menu.Clear:MenuElement({id = "UseQLM", name = "LastHit[Q] min Minions", value = 2, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})  
	Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})	
	Menu.ks:MenuElement({id = "UseEQ", name = "[E]+[Q]", value = true})
	
	--Activator
	Menu:MenuElement({type = MENU, id = "a", name = "Activator"})		
	Menu.a:MenuElement({id = "ON", name = "Protobelt all UltSettings", value = true, tooltip = "Free Flash"})	

	--EscapeMenu
	Menu:MenuElement({type = MENU, id = "evade", name = "Escape"})	
	Menu.evade:MenuElement({id = "UseW", name = "Auto[W] Spawn Clone", value = true})
	Menu.evade:MenuElement({id = "Min", name = "Low Life to Spawn Clone", value = 30, min = 0, max = 100, identifier = "%"})

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})

	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 225, Range = 800, Speed = 500, Collision = false
	}
	
	QspellData = {speed = 500, range = 800, delay = 0.25, radius = 225, collision = {nil}, type = "circular"}	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1000, Speed = 1300, Collision = false
	}
	
	EspellData = {speed = 1300, range = 1000, delay = 0.25, radius = 70, collision = {nil}, type = "linear"}			
  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		if(Menu.Drawing.DrawR:Value()) and Ready(_R) then
		DrawCircle(myHero, 600, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if(Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
		DrawCircle(myHero, 800, 1, DrawColor(225, 225, 0, 10))
		end
		if(Menu.Drawing.DrawE:Value()) and Ready(_E) then
		DrawCircle(myHero, 1000, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

local Ult1, Ult2, Ult3, Ult4, Ult5, Ult6 = false, false, false, false, false, false
function Tick()

	if not Ready(_R) and (Ult1 or Ult2 or Ult3 or Ult4 or Ult5 or Ult6) then
		DelayAction(function()
			Ult1, Ult2, Ult3, Ult4, Ult5, Ult6 = false, false, false, false, false, false
		end,1.5)
	end	

	if MyHeroNotReady() then return end
	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		checkUltSpell()
		AutoR()
		AutoR1()
	elseif Mode == "Harass" then
		Harass()
		if Menu.Harass.LH.UseQL:Value() and Ready(_Q) then
			local target = GetTarget(1000)
			if target == nil then				
				for i = 1, GameMinionCount() do
				local minion = GameMinion(i)	
					if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 800 and IsValid(minion) and (myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 ) then	
						local count = GetMinionCount(225, minion)			
						local hp = minion.health
						local QDmg = getdmg("Q", minion, myHero)
						if hp < QDmg and count >= Menu.Harass.LH.UseQLM:Value() then
							Control.CastSpell(HK_Q, minion.pos)
						end	 
					end
				end
			end
		end	
	elseif Mode == "Clear" then
		Clear()
		JungleClear()	
	end	
	EscapeW()
	KillSteal()
	AutoE()	
end

function AutoE()
	if Menu.AutoE.UseE:Value() and Ready(_E) then
		for i, Enemy in ipairs(GetEnemyHeroes()) do
			if Enemy and IsValid(Enemy) and myHero.pos:DistanceTo(Enemy.pos) <= 1000 then	
				local count = GetLineTargetCount(myHero.pos, Enemy.pos, 0.25, 1300, 70, 1000)
				if count >= 2 then
					Control.CastSpell(HK_E, Enemy.pos)
				end
			end
		end
	end	
end

function EscapeW()  
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1500 and Ready(_W) and Menu.evade.UseW:Value() then
		if myHero.health/myHero.maxHealth <= Menu.evade.Min:Value()/100 then
			Control.CastSpell(HK_W, target.pos)
		end
	end
end

function checkUltSpell()
	if Ult1 then
		AutoUlt1()
		Immo1()	
	elseif Ult2 then	
		AutoUlt2()
		Immo2()
	elseif Ult3 then
		AutoUlt3()
		Immo3()
	elseif Ult4 then
		AutoUlt4()
		Immo4()	
	elseif Ult5 then
		AutoUlt5()
		Immo5()
	elseif Ult6 then
		AutoUlt6()
		Immo6()	
	end
	

	if Ready(_R) then
		local Protobelt = GetItemSlot(myHero, 3152)		
		
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
			if Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
				Ult1 = true Ult2 = false Ult3 = false Ult4 = false Ult5 = false Ult6 = false
			end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
			if Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
				Ult1 = true Ult2 = false Ult3 = false Ult4 = false Ult5 = false Ult6 = false	
			end	
		end

		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
			if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
				Ult1 = false Ult2 = true Ult3 = false Ult4 = false Ult5 = false Ult6 = false
			end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
			if  Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
				Ult1 = false Ult2 = true Ult3 = false Ult4 = false Ult5 = false Ult6 = false
			end	
		end
		
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
			if  Ready(_R) and Ready(_W) and (Protobelt > 0 and not Ready(Protobelt) or Protobelt == 0) then
				Ult1 = false Ult2 = false Ult3 = true Ult4 = false Ult5 = false Ult6 = false
			end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
			if  Ready(_R) and Ready(_W) and (Protobelt > 0 and not Ready(Protobelt) or Protobelt == 0) then
				Ult1 = false Ult2 = false Ult3 = true Ult4 = false Ult5 = false Ult6 = false
			end	
		end
		
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and not Ready(SUMMONER_1) then
			if  Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
				Ult1 = false Ult2 = false Ult3 = false Ult4 = true Ult5 = false Ult6 = false
			end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and not Ready(SUMMONER_2) then
			if Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
				Ult1 = false Ult2 = false Ult3 = false Ult4 = true Ult5 = false Ult6 = false	
			end	
		end	
		
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and not Ready(SUMMONER_1) then
			if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
				Ult1 = false Ult2 = false Ult3 = false Ult4 = false Ult5 = true Ult6 = false
			end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and not Ready(SUMMONER_2) then
			if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
				Ult1 = false Ult2 = false Ult3 = false Ult4 = false Ult5 = true Ult6 = false
			end	
		end	
		
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
			if Ready(_R) and not Ready(_W) and (Protobelt > 0 and not Ready(Protobelt)) or Protobelt == 0 then
				Ult1 = false Ult2 = false Ult3 = false Ult4 = false Ult5 = false Ult6 = true
			end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
			if Ready(_R) and not Ready(_W) and (Protobelt > 0 and not Ready(Protobelt)) or Protobelt == 0 then
				Ult1 = false Ult2 = false Ult3 = false Ult4 = false Ult5 = false Ult6 = true
			end	
		end	
	end	
end

function KillSteal()
local target = GetTarget(1100)     	
if target == nil then return end
		
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 800 then
		local QDmg = getdmg("Q", target, myHero)
		if Menu.ks.UseQ:Value() and Ready(_Q) and QDmg >= target.health then
			CastQ(target)
		end
	end	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1000 then
		local EDmg = getdmg("E", target, myHero)
		if Menu.ks.UseE:Value() and Ready(_E) and EDmg >= target.health then
			CastE(target)
		end
	end	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 800 then	
		local EDmg = getdmg("E", target, myHero)
		local QDmg = getdmg("Q", target, myHero)
		if Menu.ks.UseEQ:Value() and Ready(_E) and Ready(_Q) and (EDmg + QDmg) >= target.health then
			CastE(target)
			CastQ(target)		
		end
	end
end		

function AutoR()
local target = GetTarget(1000)
if target == nil then return end

local Protobelt = GetItemSlot(myHero, 3152)	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < 400 and Menu.Combo.Ult.WR.UseR:Value() and Menu.a.ON:Value() then
		if Ready(_R) and Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero, 600)
			if targetCount >= Menu.Combo.Ult.WR.RHit:Value() then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)				
			end
			
		elseif Ready(_R) and not Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then	
			local targetCount = CountEnemiesNear(myHero, 600)
			if targetCount >= Menu.Combo.Ult.WR.RHit:Value() then
				SetAttack(false)
				Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		
		elseif Ready(_R) and Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero, 600)
			if targetCount >= Menu.Combo.Ult.WR.RHit:Value() then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)				
			end
			
		elseif Ready(_R) and not Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then	
			local targetCount = CountEnemiesNear(myHero, 600)
			if targetCount >= Menu.Combo.Ult.WR.RHit:Value() then
				SetAttack(false)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end			
		end
	end
end

function AutoR1()
local target = GetTarget(2000)
if target == nil then return end
local hp = target.health
local RDmg = getdmg("R", target, myHero)
local QDmg = getdmg("Q", target, myHero)
local EDmg = getdmg("E", target, myHero)
local Protobelt = GetItemSlot(myHero, 3152)	
local targetCount = CountEnemiesNear(myHero, 2000)
local allyCount = GetAllyCount(1500, myHero)	
	if IsValid(target) then
		
		if Menu.Combo.Ult.One.UseR1:Value() and Menu.a.ON:Value() and Ready(_R) and Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			if targetCount == 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 400 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		elseif Menu.Combo.Ult.One.UseR1:Value() and Menu.a.ON:Value() and Ready(_R) and not Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			if targetCount == 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 400 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end	
		elseif Menu.Combo.Ult.One.UseR1:Value() and Menu.a.ON:Value() and Ready(_R) and Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			if targetCount == 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 300 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		elseif Menu.Combo.Ult.One.UseR1:Value() and Menu.a.ON:Value() and Ready(_R) and not Ready(_W) and (( not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			if targetCount == 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 300 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end			
		end
	end
end

--Hextech Protobelt
function Proto()		
local target = GetTarget(1000)
if target == nil then return end
local Protobelt = GetItemSlot(myHero, 3152)
	if IsValid(target) and Menu.a.ON:Value() then
		if myHero.pos:DistanceTo(target.pos) < 600 and Protobelt > 0 and Ready(Protobelt) then	
			Control.CastSpell(ItemHotKey[Protobelt], target)
		end
	end
end	

function AutoUlt1() --full
local target = GetTarget(1400)
if target == nil then return end

	for i, ally in pairs(GetAllyHeroes()) do	
		if ally and IsValidRange(ally,900) then
		local targetCount = CountEnemiesNear(ally, 600)	
			if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 1000 and myHero.pos:DistanceTo(ally.pos) >= 300 then	
				if Menu.Combo.Ult.Ally.UseR2:Value() then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						if Control.CastSpell(HK_R) then
							Proto()
							if Control.CastSpell(HK_W) then
								Control.CastSpell(HK_SUMMONER_1, ally.pos) 
							end	
						end
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						if Control.CastSpell(HK_R) then
							Proto()
							if Control.CastSpell(HK_W) then
								Control.CastSpell(HK_SUMMONER_1, ally.pos) 
							end	
						end
					end	
				end
			end
		end
	end
end

function AutoUlt2()   --no[W]
local target = GetTarget(1400)
if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if ally and IsValidRange(ally,900) then
		local targetCount = CountEnemiesNear(ally, 600)		
			if Menu.Combo.Ult.Ally.UseR2:Value()  then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 1000 and myHero.pos:DistanceTo(ally.pos) >= 300 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						if Control.CastSpell(HK_R) then
							Proto()
							Control.CastSpell(HK_SUMMONER_1, ally.pos) 	
						end
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						if Control.CastSpell(HK_R) then
							Proto()
							Control.CastSpell(HK_SUMMONER_1, ally.pos) 
						end
					end	
				end
			end
		end
	end
end

function AutoUlt3() --noProtobelt
local target = GetTarget(1200)
if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if ally and IsValidRange(ally,500) then
		local targetCount = CountEnemiesNear(ally, 600)		
			if Menu.Combo.Ult.Ally.UseR2:Value()  then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 600 and myHero.pos:DistanceTo(ally.pos) >= 200 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						if Control.CastSpell(HK_R) then
							if Control.CastSpell(HK_W) then
								Control.CastSpell(HK_SUMMONER_1, ally.pos) 
							end	
						end
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						if Control.CastSpell(HK_R) then
							if Control.CastSpell(HK_W) then
								Control.CastSpell(HK_SUMMONER_1, ally.pos) 
							end	
						end
					end	
				end
			end
		end
	end
end

function AutoUlt4()  --noFlash
local target = GetTarget(1200)
if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if ally and IsValidRange(ally,500) then
		local targetCount = CountEnemiesNear(ally, 600)		
			if Menu.Combo.Ult.Ally.UseR2:Value() then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 600 and myHero.pos:DistanceTo(ally.pos) >= 100 then
					if Control.CastSpell(HK_R) then
						Proto()
						Control.CastSpell(HK_W) 	
					end
				end
			end
		end
	end
end

function AutoUlt5()  --noFlash, no[W]
local target = GetTarget(1200)
if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if ally and IsValidRange(ally,500) then
		local targetCount = CountEnemiesNear(ally, 600)	
			if Menu.Combo.Ult.Ally.UseR2:Value()  then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 600 and myHero.pos:DistanceTo(ally.pos) >= 100 then
					if Control.CastSpell(HK_R) then
						Proto()
					end
				end
			end
		end
	end
end

function AutoUlt6() --noProtobelt, no[W]
local target = GetTarget(1200)
if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do
		if ally and IsValidRange(ally,500) then
		local targetCount = CountEnemiesNear(ally, 600)		
			if Menu.Combo.Ult.Ally.UseR2:Value() then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 600 and myHero.pos:DistanceTo(ally.pos) >= 200 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						if Control.CastSpell(HK_R) then
							Control.CastSpell(HK_SUMMONER_1, ally.pos) 
						end
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						if Control.CastSpell(HK_R) then
							Control.CastSpell(HK_SUMMONER_1, ally.pos) 
						end
					end	
				end
			end
		end    
	end
end
	
function Immo1() --full
local target = GetTarget(1400)
if target == nil then return end
	local targetCount = GetImmobileCount(600, target)
	if IsValid(target) and targetCount >= Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if Menu.Combo.Ult.Immo.UseR3:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 1000 and myHero.pos:DistanceTo(target.pos) >= 300 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
					if Control.CastSpell(HK_R) then
						Proto()
						if Control.CastSpell(HK_W) then
							Control.CastSpell(HK_SUMMONER_1, target.pos) 
						end	
					end
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
					if Control.CastSpell(HK_R) then
						Proto()
						if Control.CastSpell(HK_W) then
							Control.CastSpell(HK_SUMMONER_1, target.pos) 
						end	
					end
				end
			end
		end
	end
end

function Immo2() --no[W]
local target = GetTarget(1400)
if target == nil then return end
	local targetCount = GetImmobileCount(600, target)
	if IsValid(target) and targetCount >= Menu.Combo.Ult.Immo.UseR3M:Value() then		
		if Menu.Combo.Ult.Immo.UseR3:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 1000 and myHero.pos:DistanceTo(target.pos) >= 300 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
					if Control.CastSpell(HK_R) then
						Proto()
						Control.CastSpell(HK_SUMMONER_1, target.pos) 	
					end
			
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
					if Control.CastSpell(HK_R) then
						Proto()
						Control.CastSpell(HK_SUMMONER_1, target.pos) 
					end
				end	
			end
		end
	end
end

function Immo3() --noProtobelt
local target = GetTarget(1200)
if target == nil then return end
	local targetCount = GetImmobileCount(600, target)
	if IsValid(target) and targetCount >= Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if Menu.Combo.Ult.Immo.UseR3:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 600 and myHero.pos:DistanceTo(target.pos) >= 200 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
					if Control.CastSpell(HK_R) then
						if Control.CastSpell(HK_W) then
							Control.CastSpell(HK_SUMMONER_1, target.pos) 
						end	
					end
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
					if Control.CastSpell(HK_R) then
						if Control.CastSpell(HK_W) then
							Control.CastSpell(HK_SUMMONER_1, target.pos) 
						end	
					end
				end
			end
		end
	end
end

function Immo4() --noFlash
local target = GetTarget(1100)
if target == nil then return end
	local targetCount = GetImmobileCount(600, target)
	if IsValid(target) and targetCount >= Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if Menu.Combo.Ult.Immo.UseR3:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 600 and myHero.pos:DistanceTo(target.pos) >= 100 then
				if Control.CastSpell(HK_R) then
					Proto()
					Control.CastSpell(HK_W) 	
				end
			end
		end
	end
end

function Immo5() --noFlash, no[W]
local target = GetTarget(1100)
if target == nil then return end
	local targetCount = GetImmobileCount(600, target)
	if IsValid(target) and targetCount >= Menu.Combo.Ult.Immo.UseR3M:Value() then		
		if Menu.Combo.Ult.Immo.UseR3:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 600 and myHero.pos:DistanceTo(target.pos) >= 100 then
				if Control.CastSpell(HK_R) then
					Proto()
				end
			end
		end
	end
end

function Immo6() --noProtobelt, no[W]
local target = GetTarget(1200)
if target == nil then return end
	local targetCount = GetImmobileCount(600, target)
	if IsValid(target) and targetCount >= Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if Menu.Combo.Ult.Immo.UseR3:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 600 and myHero.pos:DistanceTo(target.pos) >= 200 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
					if Control.CastSpell(HK_R) then
						Control.CastSpell(HK_SUMMONER_1, target.pos) 
					end
			
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
					if Control.CastSpell(HK_R) then
						Control.CastSpell(HK_SUMMONER_1, target.pos) 
					end
				end
			end
		end
	end
end
		
function Combo()
local target = GetTarget(1100)
if target == nil then return end
	if IsValid(target) then

		if Menu.Combo.UseE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1000 then			
			CastE(target)
		end

		if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 800 then 
			CastQ(target)
		end	
	end
end

function Harass()	
local target = GetTarget(800)
if target == nil then return end	
	if IsValid(target) and (myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 ) then

		if Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 800 and Menu.Harass.UseE:Value() then
			CastE(target)
		end
		
		if Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 800 then	
			CastQ(target)
		end
	end
end

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,1200) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            if Menu.Clear.UseQL:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= 800 and Ready(_Q) then
                local count = GetMinionCount(225, minion)
				local QDmg = getdmg("Q", minion, myHero)
				if count >= Menu.Clear.UseQLM:Value() and minion.health <= QDmg then	
					Control.CastSpell(HK_Q, minion.pos)
				end	
            end

            if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= 1000 and Ready(_E) then
                local count = GetMinionCount(1000, myHero)
				if count >= Menu.Clear.UseEM:Value() then	
					Control.CastSpell(HK_E, minion.pos)
				end	
            end
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion,1200) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= 800 and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end

            if Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= 1000 and Ready(_E) then
                Control.CastSpell(HK_E, minion.pos)
            end
        end
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
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 225, Range = 800, Speed = 500, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end
	end
end

function CastE(unit)
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
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1000, Speed = 1300, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value()+1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end
	end
end

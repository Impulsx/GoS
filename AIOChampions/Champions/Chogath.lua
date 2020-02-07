local function GetDistanceSqr(p1, p2)
	if not p1 then return math.huge end
	p2 = p2 or myHero
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
end

local function GetKillMinionCount(range, pos)
    local pos = pos.pos
	local Qcount = 0
	local Wcount = 0
	local Ecount = 0	
	for i = 1,Game.MinionCount() do
	local hero = Game.Minion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
			local QDmg = getdmg("Q", hero, myHero)
			local WDmg = getdmg("W", hero, myHero)
			local EDmg = getdmg("E", hero, myHero)			
			if hero.health <= QDmg then
				Qcount = Qcount + 1
			end	
			if hero.health <= WDmg then
				Wcount = Wcount + 1
			end
			if hero.health <= EDmg then
				Ecount = Ecount + 1
			end			
		end
	end
	return Qcount,Wcount,Ecount
end

local function GetMinionCount(range, pos)
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

local function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

local function EnemyHeroes()
	return Enemies
end

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	

	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "countQ", name = "[Q] min Minions", value = 2, min = 0, max = 7, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "countW", name = "[W] min Minions", value = 2, min = 0, max = 7, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "countE", name = "[E] min Minions", value = 2, min = 0, max = 7, identifier = "Minion/s"})
	Menu.Clear:MenuElement({id = "UseR", name = "[R] only Cannon Minions", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear Menu
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.JClear:MenuElement({id = "UseR", name = "[R] Big and Epic Monster", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})

	--LastHitMode Menu
	Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit Mode"})
	Menu.LastHit:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.LastHit:MenuElement({id = "countQ", name = "[Q] Kill min Minions", value = 2, min = 0, max = 7, identifier = "Minion/s"})	
	Menu.LastHit:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.LastHit:MenuElement({id = "countW", name = "[W] Kill min Minions", value = 2, min = 0, max = 7, identifier = "Minion/s"})	
	Menu.LastHit:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.LastHit:MenuElement({id = "countE", name = "[E] Kill min Minions", value = 2, min = 0, max = 7, identifier = "Minion/s"})
	Menu.LastHit:MenuElement({id = "UseR", name = "[R] only Cannon Minions", value = true})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})		
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] if killable Minion near", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W] if killable Minion near", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	--JungleSteal
	Menu:MenuElement({type = MENU, id = "Steal", name = "JungleSteal Settings"})	
	Menu.Steal:MenuElement({id = "UseR", name = "[R] Steal Epic Monsters", value = true})		

	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal Settings"})	
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})		

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})	
	 
	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 250, Range = 925, Speed = 3200, Collision = false
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
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end  
		
		if myHero.dead then return end
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 925, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 625, 1, Draw.Color(225, 225, 125, 10))
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
		JungleClear()
		Clear()
		
	elseif Mode == "LastHit" then
		LastHit()	
	end	
	
	KillSteal()
	JungleSteal()
end

function Combo()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) then
		
		if myHero.pos:DistanceTo(target.pos) <= 925 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 625 and Menu.Combo.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target.pos)
		end	

		if myHero.pos:DistanceTo(target.pos) <= 250 and Menu.Combo.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E)
		end			
	end	
end	

function Harass()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
			
		if myHero.pos:DistanceTo(target.pos) <= 925 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			local Qcount = GetKillMinionCount(175, target)
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 and Qcount >= 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 625 and Menu.Harass.UseW:Value() and Ready(_W) then
			local Wcount = GetKillMinionCount(175, target)
			if Wcount >= 1 then
				Control.CastSpell(HK_W, target.pos)
			end	
		end	

		if myHero.pos:DistanceTo(target.pos) <= 250 and Menu.Harass.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E)
		end			
	end	
end

function LastHit()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) then
			
			
			if myHero.pos:DistanceTo(minion.pos) <= 925 and Menu.LastHit.UseQ:Value() and Ready(_Q) then
				local Qcount = GetKillMinionCount(175, minion)
				if Qcount >= Menu.LastHit.countQ:Value() then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end

			if myHero.pos:DistanceTo(minion.pos) <= 625 and Menu.LastHit.UseW:Value() and Ready(_W) then
				local Wcount = GetKillMinionCount(175, minion)
				if Wcount >= Menu.LastHit.countW:Value() then
					Control.CastSpell(HK_W, minion.pos)
				end
			end 
			
			if myHero.pos:DistanceTo(minion.pos) <= 250 and Menu.LastHit.UseE:Value() and Ready(_E) then
				local Ecount = GetKillMinionCount(300, minion)
				if Ecount >= Menu.LastHit.countE:Value() then
					Control.CastSpell(HK_E)
				end
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 175 and Menu.LastHit.UseR:Value() and Ready(_R) and minion.charName == "SRU_ChaosMinionSiege" then
				local RDmg = getdmg("R", minion, myHero)
				local buff = GetBuffData(myHero, "Feast")
				if RDmg >= minion.health and buff.count < 6 then
					Control.CastSpell(HK_R, minion)
				end
			end			
		end
	end
end

local function CheckJungle(unit)
	if unit.charName ==
		"SRU_Blue" or unit.charName ==
		"SRU_Red" or unit.charName ==
		"SRU_Gromp" or unit.charName ==
		"SRU_Murkwolf" or unit.charName ==
		"SRU_Razorbeak" or unit.charName ==
		"SRU_Krug" or unit.charName ==
		"Sru_Crab" then
		return true
	end
	return false
end	

local function CheckJungleSteal(unit)
	if unit.charName ==
		"SRU_Baron" or unit.charName ==
		"SRU_RiftHerald" or unit.charName ==
		"SRU_Dragon_Water" or unit.charName ==
		"SRU_Dragon_Fire" or unit.charName ==
		"SRU_Dragon_Earth" or unit.charName ==
		"SRU_Dragon_Air" or unit.charName ==
		"SRU_Dragon_Elder" then
		return true
	end
	return false
end

function JungleSteal()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 300 and minion.team == TEAM_JUNGLE and IsValid(minion) then	
		
			if myHero.pos:DistanceTo(minion.pos) <= 175 and Menu.Steal.UseR:Value() and Ready(_R) and CheckJungleSteal(minion) then
				local RDmg = getdmg("R", minion, myHero)
				if RDmg >= minion.health then
					Control.CastSpell(HK_R, minion)
				end
			end
		end
	end
end

function JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then

			if myHero.pos:DistanceTo(minion.pos) <= 925 and Menu.JClear.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) <= 625 and Menu.JClear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, minion.pos)
			end 
			
			if myHero.pos:DistanceTo(minion.pos) <= 250 and Menu.JClear.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E)
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 175 and Menu.JClear.UseR:Value() and Ready(_R) and CheckJungleSteal(minion) then
				local RDmg = getdmg("R", minion, myHero)
				if RDmg >= minion.health then
					Control.CastSpell(HK_R, minion)
				end
			end

			if myHero.pos:DistanceTo(minion.pos) <= 175 and Menu.JClear.UseR:Value() and Ready(_R) and CheckJungle(minion) then
				local RDmg = getdmg("R", minion, myHero)
				local buff = GetBuffData(myHero, "Feast")
				if RDmg >= minion.health and buff.count < 6 then
					Control.CastSpell(HK_R, minion)
				end
			end 			
        end
    end
end
			
function Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
		
			
			if myHero.pos:DistanceTo(minion.pos) <= 925 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				local Qcount = GetMinionCount(175, minion)
				if Qcount >= Menu.Clear.countQ:Value() then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end

			if myHero.pos:DistanceTo(minion.pos) <= 625 and Menu.Clear.UseW:Value() and Ready(_W) then
				local Wcount = GetMinionCount(175, minion)
				if Wcount >= Menu.Clear.countW:Value() then
					Control.CastSpell(HK_W, minion.pos)
				end
			end 
			
			if myHero.pos:DistanceTo(minion.pos) <= 250 and Menu.Clear.UseE:Value() and Ready(_E) then
				local Ecount = GetMinionCount(300, minion)
				if Ecount >= Menu.Clear.countE:Value() then
					Control.CastSpell(HK_E)
				end
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 175 and Menu.Clear.UseR:Value() and Ready(_R) and minion.charName == "SRU_ChaosMinionSiege" then
				local RDmg = getdmg("R", minion, myHero)
				local buff = GetBuffData(myHero, "Feast")
				if RDmg >= minion.health and buff.count < 6 then
					Control.CastSpell(HK_R, minion)
				end
			end		
		end
    end
end

function KillSteal()
	for i, target in pairs(EnemyHeroes()) do
	
		if myHero.pos:DistanceTo(target.pos) <= 1000 and IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) <= 925 and Menu.ks.UseQ:Value() and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				local QDmg = getdmg("Q", target, myHero)
				if QDmg >= target.health and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end

			if myHero.pos:DistanceTo(target.pos) <= 625 and Menu.ks.UseW:Value() and Ready(_W) then
				local WDmg = getdmg("W", target, myHero)
				if WDmg >= target.health then
					Control.CastSpell(HK_W, target.pos)
				end
			end	

			if myHero.pos:DistanceTo(target.pos) <= 175 and Menu.ks.UseR:Value() and Ready(_R) then
				local RDmg = getdmg("R", target, myHero)
				if RDmg >= target.health then
					Control.CastSpell(HK_R, target)
				end
			end			
		end
	end	
end	


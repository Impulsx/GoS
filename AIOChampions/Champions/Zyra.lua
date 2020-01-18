local function CheckSeed()
for i = 0, Game.ObjectCount() do
	local object = Game.Object(i)
	local Range = 900 * 900
		if object and GetDistanceSqr(object.pos, myHero.pos) < Range and (object.name == "Seed" or object.name == "Zyra_Base_W_Seed_Indicator_Zyra") then
		return object, object.pos
		end
	end
end

function GetDistanceSqr(p1, p2)
	if not p1 then return math.huge end
	p2 = p2 or myHero
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
end

function GetDistance(p1, p2)
	p2 = p2 or myHero
	return math.sqrt(GetDistanceSqr(p1, p2))
end

function GetDistance2D(p1,p2)
	return math.sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
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

function GetImmobileCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.isEnemy and GetDistanceSqr(pos, hero.pos) < Range and IsImmobileTarget(hero) then
		count = count + 1
		end
	end
	return count
end

function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})	
		
	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]on Immobile", value = true})

	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ"})
	Menu.AutoQ:MenuElement({id = "UseQ", name = "Use[Q] on Seeds near Target", value = 1, drop = {"Automatically", "Combo/Harass Mode"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({name = " ", drop = {"[Q] Check AutQ Menu"}})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W] Rampant Growth", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})			
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "UseRK", name = "Use[R] if Target killable ", value = true})	
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "Use[R] min Targets ", value = true})
	Menu.Combo.Ult:MenuElement({id = "UseRE", name = "Use[R] min Targets", value = 3, min = 1, max = 6})
	Menu.Combo.Ult:MenuElement({id = "Immo", name = "Use[R] if more than 2 Immobile Targets", value = true})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({name = " ", drop = {"[Q] Check AutQ Menu"}})
	Menu.Harass:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W] Rampant Growth", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})		
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})	
	Menu.ks:MenuElement({id = "UseEQ", name = "[E]+[Q]", value = true})

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1100, Speed = 1150, Collision = true, MaxCollision = 0, CollisionTypes = { _G.COLLISION_YASUOWALL }
	}

	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 85, Range = 800, Speed = 1400, Collision = false
	}

	RData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 500, Range = 700, Speed = 650, Collision = false
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
		Draw.Circle(myHero, 700, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 850, 1, Draw.Color(225, 225, 125, 10))
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
		Combo()
		if Menu.AutoQ.UseQ:Value() == 2 then
			AutoQ()
		end		
	elseif Mode == "Harass" then
		Harass()
		if Menu.AutoQ.UseQ:Value() == 2 then
			AutoQ()
		end		
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "Flee" then
		
	end	
	KillSteal()
	AutoE()
	ImmoR()
	if Menu.AutoQ.UseQ:Value() == 1 then
		AutoQ()
	end
end

function AutoQ()
local target = GetTarget(1400)     	
if target == nil then return end	
	
	if Ready(_Q) and IsValid(target) then
	local Seed = CheckSeed()
		if Seed and Seed.pos:DistanceTo(target.pos) <= 600 then
			Control.CastSpell(HK_Q, Seed.pos)
		end	
	end
end	

function AutoE()
local target = GetTarget(1200)     	
if target == nil then return end	
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1000 and IsValid(target) and Menu.AutoE.UseE:Value() then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if IsImmobileTarget(target) and pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
			Control.CastSpell(HK_E, pred.CastPosition)
		end	
	end
end	

function ImmoR()
local target = GetTarget(800)     	
if target == nil then return end
	
	if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 700 and IsValid(target) and Menu.Combo.Ult.Immo:Value() then
		local count = GetImmobileCount(500, target)
		local pred = GetGamsteronPrediction(target, RData, myHero)
		if count >= 2 and pred.Hitchance >= Menu.Pred.PredR:Value() + 1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end	
	end
end
       
function KillSteal()	
	local target = GetTarget(1200)     	
	if target == nil then return end
	
	
	if IsValid(target) then	
	local hp = target.health
		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= hp and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Menu.ks.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			local EDmg = getdmg("E", target, myHero)
			if EDmg >= hp and pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.ks.UseEQ:Value() and Ready(_E) and Ready(_Q) then
			local Epred = GetGamsteronPrediction(target, EData, myHero)
			local Qpred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local EQDmg = QDmg + EDmg
			if EQDmg >= hp then
				
				if Epred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
					Control.CastSpell(HK_E, Epred.CastPosition)
				end	
				if Qpred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then	
					Control.CastSpell(HK_Q, Qpred.CastPosition)
				end
			end
		end
	end
end	

function Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then

		if myHero.pos:DistanceTo(target.pos) <= 850 and Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
			Control.CastSpell(HK_W, target.pos)
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Menu.Combo.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 700 and Ready(_R) and Menu.Combo.Ult.UseR:Value() then
			local pred = GetGamsteronPrediction(target, RData, myHero)
			local count = GetEnemyCount(500, target)
			if count >= Menu.Combo.Ult.UseRE:Value() and pred.Hitchance >= Menu.Pred.PredR:Value() + 1 then
				Control.CastSpell(HK_R, pred.CastPosition)
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 700 and Ready(_R) and Menu.Combo.Ult.UseRK:Value() then
			local pred = GetGamsteronPrediction(target, RData, myHero)
			local RDmg = getdmg("R", target, myHero)+ 1000
			if RDmg >= target.health and pred.Hitchance >= Menu.Pred.PredR:Value() + 1 then
				Control.CastSpell(HK_R, pred.CastPosition)
			end
		end		
	end
end	

function Harass()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Menu.Harass.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
			end
		end
	end
end	

function Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			local Seed = CheckSeed()
			if Ready(_Q) and Seed and Seed.pos:DistanceTo(minion.pos) <= 600 and Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, Seed.pos)
			end	

			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1100 and Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

function JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			local Seed = CheckSeed()
			if Ready(_Q) and Seed and Seed.pos:DistanceTo(minion.pos) <= 600 and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, Seed.pos)
			end

			if Ready(_E) and myHero.pos:DistanceTo(minion.pos) <= 1100 and Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

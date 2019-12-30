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
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})	
	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]on Immobile", value = true})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W] Rampant Growth", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})			
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R] Stranglethorns", value = true})
	Menu.Combo.Ult:MenuElement({id = "UseRE", name = "Use [R] min Targets", value = 2, min = 1, max = 6})
	Menu.Combo.Ult:MenuElement({id = "killR", name = "Use[R] Killable Target", value = false})
	Menu.Combo.Ult:MenuElement({id = "Immo", name = "Use[R]Immobile Targets > 2", value = true})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})
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
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1100, Speed = 1150, 
	Collision = true, MaxCollision = 0, CollisionTypes = { _G.COLLISION_YASUOWALL }
	}

	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.85, Radius = 140, Range = 800, Speed = math.huge, Collision = false
	}

	RData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 2.0, Radius = 500, Range = 700, Speed = math.huge, Collision = false
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
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "Flee" then
		
	end	
	KillSteal()
	AutoE()
	AutoR()
	ImmoR()	
	UseW()	
		
end

function UseW()
local target = GetTarget(1200)     	
if target == nil then return end		
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 850 and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
		if IsImmobileTarget(target) then   
			Control.CastSpell(HK_W, target.pos) 
		end	
	end
end

function AutoE()
local target = GetTarget(1200)     	
if target == nil then return end	
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1000 and Menu.AutoE.UseE:Value() and Ready(_E) then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if IsImmobileTarget(target) and pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
			Control.CastSpell(HK_E, pred.CastPosition)
		end	
	end
end

function AutoR()
local target = GetTarget(800)     	
if target == nil then return end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 700 and Menu.Combo.Ult.killR:Value() and Ready(_R) then
		local hp = target.health
		local RDmg = getdmg("R", target, myHero)
		local QDmg = getdmg("Q", target, myHero)
		local EDmg = getdmg("E", target, myHero)
		local damage = RDmg + QDmg + EDmg + 300
		local pred = GetGamsteronPrediction(target, RData, myHero)
		if damage >= hp and pred.Hitchance >= Menu.Pred.PredR:Value() + 1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end	
	end
end	

function ImmoR()
local target = GetTarget(800)     	
if target == nil then return end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 700 and Menu.Combo.Ult.Immo:Value() and Ready(_R) then
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
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
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
	end
end	

function Harass()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
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

		if minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			
			if myHero.pos:DistanceTo(minion.pos) <= 800 and Ready(_Q) and Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 1100 and Ready(_E) and Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

function JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			if myHero.pos:DistanceTo(minion.pos) <= 800 and Ready(_Q) and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) <= 1100 and Ready(_E) and Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

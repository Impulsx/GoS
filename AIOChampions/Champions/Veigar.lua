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

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end



function LoadScript()

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.06"}})	
	
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
	Menu.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
	
	Q = {Range = 950, Width = 70, Delay = 0.25, Speed = 2000, Collision = false, aoe = false, Type = "line"}
	W = {Range = 900, Width = 225, Delay = 1.35, Speed = 1000, Collision = false, aoe = true, Type = "circular"}
	E = {Range = 700, Width = 375, Delay = 0.5, Speed = 1000, Collision = false, aoe = true, Type = "circular"}
	R = {Range = 650, Width = 50, Delay = 0.25, Speed = 1400, Collision = false, aoe = false, Type = "line"}	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.2, Radius = 35, Range = 900, Speed = 1200, Collision = true, MaxCollision = 1, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1200, range = 900, delay = 0.2, radius = 35, collision = {"minion"}, type = "linear"}	

	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 1.25, Radius = 112, Range = 900, Speed = MathHuge, Collision = false
	}
	
	WspellData = {speed = MathHuge, range = 900, delay = 1.25, radius = 112, collision = {nil}, type = "circular"}	

	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 375, Range = 700, Speed = MathHuge, Collision = false
	}

	EspellData = {speed = MathHuge, range = 700, delay = 0.75, radius = 375, collision = {nil}, type = "circular"}	
     	                                           
	Callback.Add("Tick", function() Tick() end)	

	Callback.Add("Draw", function()
		if Menu.Lasthit.AutoQFarm:Value() then
			DrawText("Auto LastHit[Q]: ON", 15, Menu.Lasthit.XY.x:Value()+85, Menu.Lasthit.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		else
			DrawText("Auto LastHit[Q]: OFF", 15, Menu.Lasthit.XY.x:Value()+85, Menu.Lasthit.XY.y:Value()+15, DrawColor(255, 255, 0, 0))
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
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 900 and IsValid(minion) and Menu.Clear.UseW:Value() then
			if minion.team == TEAM_ENEMY then
				local count = GetMinionCount(224, minion)
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
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)		
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then 
						local collisions =_G.PremiumPrediction:IsColliding(myHero, pred.CastPos, QspellData, {"minion"})
						if collisions and #collisions <= 1 or not collisions then
							Control.CastSpell(HK_Q, pred.CastPos)
						end	
					end
				else
					CastGGPred(_Q, target)
				end
			end
		end
		

		if myHero.pos:DistanceTo(target.pos) <= E.Range then	
			if Menu.Combo.UseE:Value() and Ready(_E) then
				if Menu.Combo.EMode:Value() == 1 then
					Control.CastSpell(HK_E, Vector(target:GetPrediction(MathHuge,0.75))-Vector(Vector(target:GetPrediction(MathHuge,0.75))-Vector(myHero.pos)):Normalized()*375) 
				elseif Menu.Combo.EMode:Value() == 2 then
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
						CastGGPred(_E, target)
					end
				end
			end	
		end
		

		if myHero.pos:DistanceTo(target.pos) <= W.Range then	
			if Menu.Combo.UseW:Value() and Ready(_W) then
				if Menu.Combo.WWait:Value() then 
					local ImmobileEnemy = IsImmobileTarget(target)
					if ImmobileEnemy then
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(target, WData, myHero)
							if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
								Control.CastSpell(HK_W, pred.CastPosition)
							end
						elseif Menu.Pred.Change:Value() == 2 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
								Control.CastSpell(HK_W, pred.CastPos)
							end
						else
							CastGGPred(_W, target)
						end
					end	
				else
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, WData, myHero)
						if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
							Control.CastSpell(HK_W, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
							Control.CastSpell(HK_W, pred.CastPos)
						end
					else
						CastGGPred(_W, target)
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
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)		
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then 
						local collisions =_G.PremiumPrediction:IsColliding(myHero, pred.CastPos, QspellData, {"minion"})
						if collisions and #collisions <= 1 or not collisions then
							Control.CastSpell(HK_Q, pred.CastPos)
						end	
					end
				else
					CastGGPred(_Q, target)
				end
			end
		end
	 

		if myHero.pos:DistanceTo(target.pos) <= W.Range then	
			if Menu.Harass.UseW:Value() and Ready(_W) and myHero.mana/myHero.maxMana >= Menu.Mana.WMana:Value() / 100 then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						Control.CastSpell(HK_W, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						Control.CastSpell(HK_W, pred.CastPos)
					end
				else
					CastGGPred(_W, target)
				end	
			end
		end
	end
end
	
function AutoQFarm()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
			
		if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) < Q.Range and IsValid(minion) then
			local Qdamage =  getdmg("Q", minion, myHero)
			if Ready(_Q) and Menu.Lasthit.AutoQFarm:Value() and Qdamage > minion.health and myHero.mana/myHero.maxMana >= Menu.Mana.QMana:Value() / 100 then	
				Control.CastSpell(HK_Q,minion.pos)
			end
		end
	end
end

function Lasthit()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
			
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
		   	local Qdamage = getdmg("Q", target, myHero)
			if Qdamage > target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)		
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then 
						local collisions =_G.PremiumPrediction:IsColliding(myHero, pred.CastPos, QspellData, {"minion"})
						if collisions and #collisions <= 1 or not collisions then
							Control.CastSpell(HK_Q, pred.CastPos)
						end	
					end
				else
					CastGGPred(_Q, target)
				end
			end
		end
	end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < W.Range then	
		if Menu.Killsteal.UseW:Value() and Ready(_W) then 
		   	local Wdamage = getdmg("W", target, myHero)
			if Wdamage > target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						Control.CastSpell(HK_W, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						Control.CastSpell(HK_W, pred.CastPos)
					end
				else
					CastGGPred(_W, target)
				end	
			end
		end
	end	
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < R.Range and Menu.Killsteal.RR:Value() and Ready(_R) then   
		local Rdamage = getdmg("R", target, myHero)
		if Rdamage > target.health then
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
				Control.CastSpell(HK_E, Vector(target:GetPrediction(MathHuge,0.75))-Vector(Vector(target:GetPrediction(MathHuge,0.75))-Vector(myHero.pos)):Normalized()*375) 
			elseif Menu.Combo.EMode:Value() == 2 then
				Control.CastSpell(HK_E, target.pos)
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

function CastGGPred(spell, unit)
	if spell == _Q then
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.2, Radius = 35, Range = 900, Speed = 1200, Collision = true, MaxCollision = 1, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end	
	
	elseif spell == _E then
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.75, Radius = 375, Range = 700, Speed = MathHuge, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end		
	
	else
		if spell == _W then
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 1.25, Radius = 112, Range = 900, Speed = MathHuge, Collision = false})
			WPrediction:GetPrediction(unit, myHero)
			if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
				Control.CastSpell(HK_W, WPrediction.CastPosition)
			end
		end	
	end
end

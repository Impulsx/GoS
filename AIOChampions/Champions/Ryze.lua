local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
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

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.13"}})	
	
	--ComboMenu
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({name = " ", drop = {"Combo Logic ( Full or Fast Combo )"}})	
	Menu.Combo:MenuElement({id = "Type", name = "Combo SwitchKey", key = string.byte("T"), toggle = true})
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[E] + [Q] Marked Minion", value = true})
	Menu.Clear:MenuElement({id = "Count", name = "Min minions for [E] + [Q]", value = 3, min = 1, max = 12, step = 1})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--LastHit
	Menu:MenuElement({type = MENU, id = "Last", name = "LastHit Minion"})
	Menu.Last:MenuElement({id = "UseQ", name = "[Q] if out of AA range", value = true})
	Menu.Last:MenuElement({id = "UseE", name = "[E] if not killable AA or Q", value = true})	
	Menu.Last:MenuElement({id = "Mana", name = "Min Mana to LastHit", value = 20, min = 0, max = 100, identifier = "%"})	
	
	--KillSteal
	Menu:MenuElement({type = MENU, id = "KillSteal", name = "KillSteal"})
	Menu.KillSteal:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.KillSteal:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.KillSteal:MenuElement({id = "UseE", name = "[E]", value = true})
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw[Q]", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw[W]", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw[E]", value = true})
	Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "Text Position"})	
	Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1000, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1700, range = 1000, delay = 0.25, radius = 60, collision = {"minion"}, type = "linear"}	
  	                                           
											   
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		DrawText("Combo Mode: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+15, DrawColor(255, 225, 255, 0))
		if Menu.Combo.Type:Value() then
			DrawText("Full Combo", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		else
			DrawText("Fast Combo", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		end	
		
		if myHero.dead then return end
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1000, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 615, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 615, 1, DrawColor(225, 225, 0, 10))
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
	elseif Mode == "LastHit" then
		LastHit()
	end
	KS()	
end

function Combo()
	ComboCollision()
	if Menu.Combo.Type:Value() then
		ComboFull()
	else
		ComboFast()
	end	
end

function ComboFull()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then    
		
		if Ready(_Q) and Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1000, Speed = 1700, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end
		
		elseif Ready(_W) and Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 615 then
			Control.CastSpell(HK_W, target)
		end
		
		if Ready(_Q) and Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1000, Speed = 1700, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end

		elseif Ready(_E) and Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 615 then	
			Control.CastSpell(HK_E, target)
		end	
	end
end	

function ComboFast()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then    
		
		if Ready(_Q) and Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1000, Speed = 1700, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end
		end	

		if Ready(_E) and Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 615 then	
			Control.CastSpell(HK_E, target)	
		end
		
		if Ready(_W) and Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 615 then
			Control.CastSpell(HK_W, target)	
		end	
	end
end

function ComboCollision()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then 	
		
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance < Menu.Pred.PredQ:Value()+1 then		
		
				for i = 1, GameMinionCount() do
				local minion = GameMinion(i)
					
					if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) then
						
						if myHero.pos:DistanceTo(minion.pos) <= 615 and target.pos:DistanceTo(minion.pos) <= 350 and Ready(_E) then
							Control.CastSpell(HK_E, minion)
						end			
						
						if myHero.pos:DistanceTo(minion.pos) <= 1000 and Ready(_Q) then
							if HasBuff(minion, "RyzeE") and HasBuff(target, "RyzeE") then
								Control.CastSpell(HK_Q, minion.pos)
							end
						end
					end
				end
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
			if not ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				for i = 1, GameMinionCount() do
				local minion = GameMinion(i)
					
					if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) then
						
						if myHero.pos:DistanceTo(minion.pos) <= 615 and target.pos:DistanceTo(minion.pos) <= 350 and Ready(_E) then
							Control.CastSpell(HK_E, minion)
						end			
						
						if myHero.pos:DistanceTo(minion.pos) <= 1000 and Ready(_Q) then
							if HasBuff(minion, "RyzeE") and HasBuff(target, "RyzeE") then
								Control.CastSpell(HK_Q, minion.pos)
							end
						end
					end
				end
			end
		else
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1000, Speed = 1700, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
			QPrediction:GetPrediction(target, myHero)
			if not QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				for i = 1, GameMinionCount() do
				local minion = GameMinion(i)
					
					if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) then
						
						if myHero.pos:DistanceTo(minion.pos) <= 615 and target.pos:DistanceTo(minion.pos) <= 350 and Ready(_E) then
							Control.CastSpell(HK_E, minion)
						end			
						
						if myHero.pos:DistanceTo(minion.pos) <= 1000 and Ready(_Q) then
							if HasBuff(minion, "RyzeE") and HasBuff(target, "RyzeE") then
								Control.CastSpell(HK_Q, minion.pos)
							end
						end
					end
				end
			end			
		end	
	end	
end	

function Harass()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1000 and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value()/100 then
		if Menu.Harass.UseQ:Value() and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1000, Speed = 1700, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end
		end
	end
end

function LastHit()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 1200 and myHero.mana/myHero.maxMana >= Menu.Last.Mana:Value() / 100 then
			local Qdmg = getdmg("Q", minion, myHero)
			local Edmg = getdmg("E", minion, myHero)

			
			if myHero:GetSpellData(_R).level == 0 and myHero.pos:DistanceTo(minion.pos) <= 615 and IsValid(minion) and minion.health > (myHero.totalDamage or Qdmg) and minion.health <= Edmg + 0.1*Qdmg and Menu.Last.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E,minion)				
			
			elseif myHero:GetSpellData(_R).level > 0 and myHero.pos:DistanceTo(minion.pos) <= 615 and IsValid(minion) and Menu.Last.UseE:Value() and Ready(_E) then
				local level = myHero:GetSpellData(_R).level
				local MarkedDmg = (({40, 70, 100})[level]) /100					
				if minion.health > (myHero.totalDamage or Qdmg) and minion.health <= (Edmg + MarkedDmg*Qdmg) then
					Control.CastSpell(HK_E,minion)
				end	
			end			
			
			if myHero:GetSpellData(_R).level == 0 and myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) and Menu.Last.UseE:Value() and Ready(_Q) then
				if HasBuff(minion, "RyzeE") and minion.health <= 0.1*Qdmg then
					Control.CastSpell(HK_Q, minion.pos)
				end
			elseif myHero:GetSpellData(_R).level > 0 and myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) and Menu.Last.UseE:Value() and Ready(_Q) then
				local level = myHero:GetSpellData(_R).level
				local MarkedDmg = (({40, 70, 100})[level]) /100	
				if HasBuff(minion, "RyzeE") and minion.health <= (MarkedDmg*Qdmg) then
					Control.CastSpell(HK_Q, minion.pos)
				end				
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 1000 and myHero.pos:DistanceTo(minion.pos) > (myHero.range + myHero.boundingRadius) and IsValid(minion) and Menu.Last.UseQ:Value() and Ready(_Q) and minion.health <= Qdmg then
				Control.CastSpell(HK_Q, minion.pos)
			end			
		end
	end
end

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if minion.team == TEAM_ENEMY and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
			local count = GetMinionCount(350, minion)
			if myHero.pos:DistanceTo(minion.pos) <= 615 and IsValid(minion) and Menu.Clear.UseQ:Value() and Ready(_E) and count >= Menu.Clear.Count:Value() then
				Control.CastSpell(HK_E,minion)
			end			
			
			if myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) and Menu.Clear.UseQ:Value() and Ready(_Q) and HasBuff(minion, "RyzeE") then			
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if minion.team == TEAM_JUNGLE and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
			if myHero.pos:DistanceTo(minion.pos) <= 615 and IsValid(minion) and Menu.JClear.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E, minion)
			end			
			
			if myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) and Menu.JClear.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end
end	

function KS()
local target = GetTarget(1200)
if target == nil then return end

	if IsValid(target) then    
		
		if myHero.pos:DistanceTo(target.pos) <= 615 and Menu.KillSteal.UseE:Value() and Ready(_E) then
			local Edmg = getdmg("E", target, myHero)
			local Qdmg = getdmg("Q", target, myHero)
			
			if myHero:GetSpellData(_R).level == 0 and (Edmg + 0.1*Qdmg) >= target.health then
				Control.CastSpell(HK_E,target)
			
			elseif myHero:GetSpellData(_R).level > 0 then
				local level = myHero:GetSpellData(_R).level
				local MarkedDmg = (({40, 70, 100})[level]) /100
				if (Edmg + Qdmg*MarkedDmg) >= target.health then
					Control.CastSpell(HK_E,target)
				end
			end
		end		
		
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Menu.KillSteal.UseQ:Value() and Ready(_Q) then
			local Qdmg = getdmg("Q", target, myHero)
			if Qdmg >= target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1000, Speed = 1700, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 615 and Menu.KillSteal.UseW:Value() and Ready(_W) then
			local Wdmg = getdmg("W", target, myHero)
			if Wdmg >= target.health then
				Control.CastSpell(HK_W,target)
			   
			end
		end
	end
end

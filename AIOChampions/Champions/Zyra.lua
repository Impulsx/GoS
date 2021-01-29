
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

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.09"}})	
	
	Menu:MenuElement({type = MENU, id = "E", name = "E range Setting"})
	Menu.E:MenuElement({id = "Erange", name = "Max E range", value = 900, min = 100, max = 1100, step = 10})	
		
	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]on Immobile", value = true})

	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ"})
	Menu.AutoQ:MenuElement({name = " ", drop = {"Turn Off Check objects if trouble with Fps"}})
	Menu.AutoQ:MenuElement({name = " ", drop = {"Check objects off then Q in Combo cast to enemy"}})	
	Menu.AutoQ:MenuElement({id = "Use", name = "Check for Objects [Seeds]", value = true})	
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
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
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
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1100, Speed = 1150, Collision = false
	}
	
	EspellData = {speed = 1150, range = 1100, delay = 0.25, radius = 70, collision = {nil}, type = "linear"}	

	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 85, Range = 800, Speed = 1400, Collision = false
	}
	
	QspellData = {speed = 1400, range = 800, delay = 0.25, radius = 85, collision = {nil}, type = "circular"}	

	RData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 450, Range = 700, Speed = 650, Collision = false
	}
	
	RspellData = {speed = 650, range = 700, delay = 0.25, radius = 450, collision = {nil}, type = "circular"}	
  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 700, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 800, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 1100, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 850, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end


function Tick()
	if MyHeroNotReady() then return end
	
	if Menu.AutoQ.Use:Value() then
		CheckSeed()
		RemoveSeed()
	end	

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		if Menu.AutoQ.Use:Value() and Menu.AutoQ.UseQ:Value() == 2 then
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
	if Menu.AutoQ.Use:Value() and Menu.AutoQ.UseQ:Value() == 1 then
		AutoQ()
	end
end

local Seeds = {}
local LastScan = 0
function CheckSeed()
	local target = GetTarget(1400)     	
	if target == nil then return end
	if GameTimer() - LastScan > 5 then
		for i = 0, GameObjectCount() do
			local object = GameObject(i)
			local Range = 1500 * 1500
			if object and GetDistanceSqr(object.pos, myHero.pos) < Range and object.name == "Zyra_Base_W_Seed_Indicator_Zyra" then
				TableInsert(Seeds, object)
				LastScan = GameTimer()
				--print("Added")
				return
			end
		end
	end	
end

function RemoveSeed()		
	for i, Seed in pairs(Seeds) do
		if Seed and Seed.networkID == 0 or Seed.name ~= "Zyra_Base_W_Seed_Indicator_Zyra" then
			TableRemove(Seeds, i)
			--print("REMOVED")
		end	
	end	
end	

function AutoQ()
	local target = GetTarget(1400)     	
	if target == nil then return end	
	if Ready(_Q) and IsValid(target) then	
		for i, Seed in pairs(Seeds) do
			--print(Seed.networkID)
			if Seed and Seed.pos:DistanceTo(target.pos) <= 525 and myHero.pos:DistanceTo(target.pos) < 800 then
				Control.CastSpell(HK_Q, target.pos)
			end	
		end
	end	
end	

function AutoE()
local target = GetTarget(1200)     	
if target == nil then return end	
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) <= Menu.E.Erange:Value() and IsValid(target) and Menu.AutoE.UseE:Value() then
		if IsImmobileTarget(target) then
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
				CastEGGPred(target)
			end
		end	
	end
end	

function ImmoR()
local target = GetTarget(800)     	
if target == nil then return end
	
	if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 700 and IsValid(target) and Menu.Combo.Ult.Immo:Value() then
		local count = GetImmobileCount(500, target)
		if count >= 2 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, RData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					Control.CastSpell(HK_R, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					Control.CastSpell(HK_R, pred.CastPos)
				end
			else
				CastRGGPred(target)
			end
		end	
	end
end
       
function KillSteal()	
	local target = GetTarget(1200)     	
	if target == nil then return end
	
	
	if IsValid(target) then	
		local hp = target.health
		if myHero.pos:DistanceTo(target.pos) <= 800 and Menu.ks.UseQ:Value() and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= hp then
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
					CastQGGPred(target)
				end
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= Menu.E.Erange:Value() and Menu.ks.UseE:Value() and Ready(_E) then
			local EDmg = getdmg("E", target, myHero)
			if EDmg >= hp then			
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
					CastEGGPred(target)
				end
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 750 and Menu.ks.UseEQ:Value() and Ready(_E) and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local EQDmg = QDmg + EDmg
			if EQDmg > hp then				
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
					CastEGGPred(target)
				end	
			end
		end
	end
end	

function Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then

		if not Menu.AutoQ.Use:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 750 then
			Control.CastSpell(HK_Q, target.pos)
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
			Control.CastSpell(HK_W, myHero.pos:Extended(target.pos, 400))
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= Menu.E.Erange:Value() and Menu.Combo.UseE:Value() and Ready(_E) then
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
				CastEGGPred(target)
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 700 and Ready(_R) and Menu.Combo.Ult.UseR:Value() then
			local count = GetEnemyCount(500, target)
			if count >= Menu.Combo.Ult.UseRE:Value() then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, RData, myHero)
					if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
						Control.CastSpell(HK_R, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
						Control.CastSpell(HK_R, pred.CastPos)
					end
				else
					CastRGGPred(target)
				end
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 700 and Ready(_R) and Menu.Combo.Ult.UseRK:Value() then
			local AADmg = getdmg("AA", target, myHero)*4
			local QDmg = Ready(_Q) and getdmg("Q", target, myHero) or 0
			local EDmg = Ready(_E) and getdmg("E", target, myHero) or 0
			local RDmg = getdmg("R", target, myHero)
			local FullDmg = AADmg+QDmg+EDmg+RDmg
			if FullDmg >= target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, RData, myHero)
					if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
						Control.CastSpell(HK_R, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
						Control.CastSpell(HK_R, pred.CastPos)
					end
				else
					CastRGGPred(target)
				end
			end
		end		
	end
end	

function Harass()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if not Menu.AutoQ.Use:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 750 then
			Control.CastSpell(HK_Q, target.pos)
		end		
		
		if myHero.pos:DistanceTo(target.pos) <= Menu.E.Erange:Value() and Menu.Harass.UseE:Value() and Ready(_E) then
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
				CastEGGPred(target)
			end
		end
	end
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 600 and Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	

			if Ready(_E) and Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)	

		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 600 and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if Ready(_E) and Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

function CastQGGPred(unit)
	local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 85, Range = 800, Speed = 1400, Collision = false})
	QPrediction:GetPrediction(unit, myHero)
	if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then
		Control.CastSpell(HK_Q, QPrediction.CastPosition)
	end
end

function CastEGGPred(unit)
	local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1100, Speed = 1150, Collision = false})
	EPrediction:GetPrediction(unit, myHero)
	if EPrediction:CanHit(Menu.Pred.PredE:Value()+1) then
		Control.CastSpell(HK_E, EPrediction.CastPosition)
	end
end

function CastRGGPred(unit)
	local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 2.25, Radius = 450, Range = 700, Speed = MathHuge, Collision = false})
	RPrediction:GetPrediction(unit, myHero)
	if RPrediction:CanHit(Menu.Pred.PredR:Value()+1) then
		Control.CastSpell(HK_R, RPrediction.CastPosition)
	end
end

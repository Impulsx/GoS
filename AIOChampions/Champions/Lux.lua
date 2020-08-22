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

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.team ~= myHero.team then
			TableInsert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local function GetAllyHeroes() 
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
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

function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function LoadScript()

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.14"}})	
	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQImmo"})
	Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto[Q]Immobile Target", value = true})

	--AutoW 
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W]Ally+Self", value = true})
	Menu.AutoW:MenuElement({id = "Heal", name = "min Hp Ally or Self", value = 40, min = 0, max = 100, identifier = "%"})	

	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]Immobile Target", value = true})
	
	--QSetting
	Menu:MenuElement({type = MENU, id = "Q", name = "Q Range Setting"})
	Menu.Q:MenuElement({id = "Qrange", name = "Max CastQ Range", value = 1200, min = 100, max = 1200, identifier = "range"})	
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})			
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})			
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 4, min = 1, max = 6, step = 1})  		
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  

	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})				
	Menu.ks:MenuElement({id = "UseR", name = "[R] Final Spark", value = true})
	Menu.ks:MenuElement({id = "Rrange", name = "Cast R if range greater than -->", value = 700, min = 0, max = 3340, identifier = "range"})	
		
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR2", name = "Draw [R] MinRange", value = false})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1175, Speed = 1200, Collision = true, MaxCollision = 1, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1200, range = 1175, delay = 0.25, radius = 70, collision = {nil}, type = "linear"}	

	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 310, Range = 1000, Speed = 1200, Collision = false
	}
	
	EspellData = {speed = 1200, range = 1000, delay = 0.25, radius = 310, collision = {nil}, type = "circular"}

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 1, Radius = 100, Range = 3340, Speed = MathHuge, Collision = false
	}
	
	RspellData = {speed = MathHuge, range = 3340, delay = 1, radius = 100, collision = {nil}, type = "linear"}	
	

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 3340, 1, DrawColor(255, 225, 255, 10))
		end  
		if Menu.Drawing.DrawR2:Value() and Ready(_R) then
		DrawCircle(myHero, Menu.ks.Rrange:Value(), 1, DrawColor(255, 225, 255, 10))
		end		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1175, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 1000, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 1075, 1, DrawColor(225, 225, 125, 10))
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
	end	

	KillSteal()
	AutoQ()
	AutoE()
	AutoW()		
end
--[[
local function NearestEnemy(entity)
	local distance = 999999
	local enemy = nil
	for i = 1,GameHeroCount()  do
		local hero = GameHero(i)	
		if hero and IsValid(hero) then
			local d = GetDistanceSqr(entity.pos, hero.pos)
			if d < distance then
				distance = d
				enemy = hero
			end
		end
	end
	return _sqrt(distance), enemy
end
]]

function AutoQ()
local target = GetTarget(1300)     	
if target == nil then return end	

	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1175 and IsImmobileTarget(target) and Menu.AutoQ.UseQ:Value() and Ready(_Q) then
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

local function IsELanded(unit)
	local LuxBuff = GetBuffData(myHero, "LuxLightStrikeKugel")
	local targetBuff = GetBuffData(unit, "slow")	
	if LuxBuff.count > 0 and targetBuff.count > 0 then
		return true
	end
	return false
end

function AutoE()
	for i, target in ipairs(GetEnemyHeroes()) do
		
		if myHero.pos:DistanceTo(target.pos) <= 1100 and IsValid(target) and IsELanded(target) then	
			Control.CastSpell(HK_E)
		end		

		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_E) and IsImmobileTarget(target) then
			if Menu.AutoE.UseE:Value() then
				Control.CastSpell(HK_E, target.pos)
			end
		end
	end	
end

function AutoW()
local target = GetTarget(2000)     	
if target == nil then return end
	if IsValid(target) then
		if Menu.AutoW.UseW:Value() and Ready(_W) and not IsRecalling(myHero) then
			if myHero.health/myHero.maxHealth <= Menu.AutoW.Heal:Value()/100 then
				Control.CastSpell(HK_W)
			end
			for i, ally in ipairs(GetAllyHeroes()) do			
				if IsValid(ally) and myHero.pos:DistanceTo(ally.pos) <= 1075 and ally.health/ally.maxHealth <= Menu.AutoW.Heal:Value()/100 then
					Control.CastSpell(HK_W, ally.pos)
				end	
			end
		end
	end
end

function Combo()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) <= Menu.Q.Qrange:Value() and Menu.Combo.UseQ:Value() and Ready(_Q) then
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
		
		if Menu.Combo.UseE:Value() and Ready(_E) then
			if IsELanded(target) then
				Control.CastSpell(HK_E)
			elseif myHero.pos:DistanceTo(target.pos) <= 1000 then	
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
end	

function Harass()
local target = GetTarget(1300)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= Menu.Q.Qrange:Value() and Menu.Harass.UseQ:Value() and Ready(_Q) then
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
		
		if Menu.Harass.UseE:Value() and Ready(_E) then
			if IsELanded(target) then
				Control.CastSpell(HK_E)
			elseif myHero.pos:DistanceTo(target.pos) <= 1000 then	
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
end

function Clear()
for i = 1, GameMinionCount() do 
local minion = GameMinion(i)
	if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) then
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if Menu.Clear.UseE:Value() then
			if IsELanded(minion) then
				Control.CastSpell(HK_E)
			elseif mana_ok and Ready(_E) then
				local count = GetMinionCount(500, minion)
				if count >= Menu.Clear.UseEM:Value() then
					Control.CastSpell(HK_E, minion.pos)
				end
			end
		end
	end
end
end

function JungleClear()
for i = 1, GameMinionCount() do 
local minion = GameMinion(i)
	if minion.team == TEAM_JUNGLE and myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) then
		local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100

		if Menu.JClear.UseE:Value() then
			if IsELanded(minion) then
				Control.CastSpell(HK_E)
			elseif mana_ok and Ready(_E) then
				Control.CastSpell(HK_E, minion.pos)
			end
		end
	end
end
end

function KillSteal()
	for i, target in ipairs(GetEnemyHeroes()) do
	
	
		if myHero.pos:DistanceTo(target.pos) <= 3500 and IsValid(target) then	
		local hp = target.health
			if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= Menu.Q.Qrange:Value() and Ready(_Q) then
				local QDmg = getdmg("Q", target, myHero)
				if QDmg >= hp then
					KillstealQ(target)
				end
			end
			if Menu.ks.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_E) then
				local EDmg = getdmg("E", target, myHero)
				if EDmg >= hp then
					KillstealE(target)
				end
			end
			if Menu.ks.UseR:Value() and myHero.pos:DistanceTo(target.pos) >= Menu.ks.Rrange:Value() and Ready(_R) then
				local RDmg = getdmg("R", target, myHero) 
				local RDmg2 = getdmg("R", target, myHero) + (10 + 10 * myHero.levelData.lvl + myHero.ap * 0.2)
				local buff = GetBuffData(target, "LuxIlluminatingFraulein")
				if buff.count > 0 and buff.duration > 1.25 and RDmg2 >= hp then    
					KillstealR(target)
				end
				if RDmg >= hp then
					KillstealR(target)
				end
			end
			if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= Menu.Q.Qrange:Value() and Ready(_R) and Ready(_Q) then
				local RDmg = getdmg("R", target, myHero)
				local QDmg = getdmg("Q", target, myHero)
				local QRDmg = QDmg + RDmg
				if QRDmg >= hp then
					KillstealQ(target)
				end	
			end
		end
	end	
end	

function KillstealQ(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, QData, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)		
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then 
			local collisions =_G.PremiumPrediction:IsColliding(myHero, pred.CastPos, QspellData, {"minion"})
			if collisions and #collisions <= 1 or not collisions then
				Control.CastSpell(HK_Q, pred.CastPos)
			end	
		end
	else
		CastGGPred(_Q, unit)
	end
end


function KillstealE(unit)
	Control.CastSpell(HK_E, unit.pos)
end

function KillstealR(unit)
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
		CastGGPred(_R, unit)	
	end
end

function CastGGPred(spell, unit)
	if spell == _Q then
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1175, Speed = 1200, Collision = true, MaxCollision = 1, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end	
	
	elseif spell == _E then
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 310, Range = 1000, Speed = 1200, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end		
	
	else
		if spell == _R then
			local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 1, Radius = 100, Range = 3340, Speed = MathHuge, Collision = false})
			RPrediction:GetPrediction(unit, myHero)
			if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
				Control.CastSpell(HK_R, RPrediction.CastPosition)
			end
		end	
	end
end

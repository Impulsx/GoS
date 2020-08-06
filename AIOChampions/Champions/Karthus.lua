local function GetEnemyHeroes()
	return Enemies
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

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local CanUlt = false
local KillRCount = 0
function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
	
	--AutoQ
	Menu:MenuElement({type = MENU, id = "QSet", name = "AutoQ"})
	Menu.QSet:MenuElement({name = " ", drop = {"AutoQ Minions is in Combo/Clear Modes disabled"}})		
	Menu.QSet:MenuElement({id = "UseQ", name = "AutoQ LastHit Minions", value = true})	
	Menu.QSet:MenuElement({id = "UseQH", name = "Use in Harass Mode???", value = true})	
	Menu.QSet:MenuElement({id = "Mana", name = "Min Mana", value = 30, min = 0, max = 100, identifier = "%"})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]Extend if TargetHp lower than 50%", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "Mana", name = "Break [E) if Mana lower than -->", value = 30, min = 0, max = 100, identifier = "%"})	

	--UltMenu  
	Menu:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Ult:MenuElement({id = "UseR", name = "Auto [R]", value = true})
	Menu.Ult:MenuElement({id = "count", name = "Min killable Targets", value = 2, min = 1, max = 5, step = 1, identifier = "Target/s"})	
	Menu.Ult:MenuElement({id = "range", name = "If no Enemy in near", value = 1200, min = 0, max = 3000, step = 10, identifier = "range"})
	Menu.Ult:MenuElement({id = "draw", name = "Draw possible Kill Count", value = true})
	Menu.Ult:MenuElement({id = "x", name = "TextPos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.Ult:MenuElement({id = "y", name = "TextPos: [Y]", value = 0, min = 0, max = 860, step = 10})
	Menu.Ult:MenuElement({id = "size", name = "Text Size", value = 20, min = 15, max = 40, step = 1})

	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
 
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true}) 
	Menu.Clear:MenuElement({id = "count", name = "[E] Min Minions", value = 3, min = 1, max = 7, step = 1, identifier = "Minion/s"}) 	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})

	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 1, Radius = 200, Range = 875, Speed = MathHuge, Collision = false
	}
	
	QspellData = {speed = MathHuge, range = 875, delay = 1, radius = 200, collision = {nil}, type = "circular"}	
  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			DrawCircle(myHero, 875, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			DrawCircle(myHero, 550, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			DrawCircle(myHero, 1000, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Ult.draw:Value() then
			DrawText("Kill Count: ", Menu.Ult.size:Value(), Pos.x + Menu.Ult.x:Value()+50, Pos.y + Menu.Ult.y:Value(), DrawColor(255, 0, 255, 0))
			if Ready(_R) then
				DrawText(KillRCount, Menu.Ult.size:Value(), Pos.x + Menu.Ult.x:Value(), Pos.y + Menu.Ult.y:Value(), DrawColor(255, 0, 255, 0))
			else
				DrawText("0", Menu.Ult.size:Value(), Pos.x + Menu.Ult.x:Value(), Pos.y + Menu.Ult.y:Value(), DrawColor(255, 0, 255, 0))
			end	
		end
	end)		
end

function Tick()
if CanUlt and not Ready(_R) then
	CanUlt = false
end	

if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()	
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Menu.QSet.UseQ:Value() then
		AutoQ()
	end	

	AutoUlt()
end

function Combo()
local target = GetTarget(900)
if target == nil then return end
	if IsValid(target) then
        
		if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 875 and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 1, Radius = 200, Range = 875, Speed = MathHuge, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end
			end
        end
       
		if Menu.Combo.UseE:Value() and Ready(_E) then
			local count = GetEnemyCount(500, myHero)
			local EBuff = HasBuff(myHero, "karthusdefile")
			if count == 0 and EBuff or myHero.mana/myHero.maxMana < Menu.Combo.Mana:Value() / 100 then
				Control.CastSpell(HK_E)
				return
			end
			if count > 0 and not EBuff and myHero.mana/myHero.maxMana > Menu.Combo.Mana:Value() / 100 then
				Control.CastSpell(HK_E)
				return
			end	
        end
		
		if Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 800 then
			if myHero.pos:DistanceTo(target.pos) > 500 and target.health/target.maxHealth <= 0.5 then
				local castPos = target.pos:Extended(myHero.pos, -300)
				Control.CastSpell(HK_W, castPos)
			end
		end	
	end
end

function Harass()
local target = GetTarget(900)
if target == nil then return end
	if IsValid(target) then
        
		if myHero.pos:DistanceTo(target.pos) < 875 then
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
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 1, Radius = 200, Range = 875, Speed = MathHuge, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end
				end
			end
		else
			if Menu.QSet.UseQ:Value() and Menu.QSet.UseQH:Value() then
				AutoQ()
			end
		end
	end
end

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) < 800 and minion.team == TEAM_ENEMY and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQ:Value() and mana_ok and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.Clear.UseE:Value() and Ready(_E) then
				local count = GetMinionCount(500, myHero)
				local EBuff = HasBuff(myHero, "karthusdefile")
				if count == 0 and EBuff or myHero.mana/myHero.maxMana <= Menu.Clear.Mana:Value() / 100 then
					Control.CastSpell(HK_E)
					return
				end
				if count > Menu.Clear.count:Value() and not EBuff and mana_ok then
					Control.CastSpell(HK_E)
					return
				end	
            end
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) < 800 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and mana_ok and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseE:Value() and Ready(_E) then
				local EBuff = HasBuff(myHero, "karthusdefile")
				if myHero.pos:DistanceTo(minion.pos) > 500 and EBuff or myHero.mana/myHero.maxMana <= Menu.Clear.Mana:Value() / 100 then
					Control.CastSpell(HK_E)
					return
				end
				if myHero.pos:DistanceTo(minion.pos) < 500 and not EBuff and mana_ok then
					Control.CastSpell(HK_E)
					return
				end	
            end
        end
    end
end

function AutoUlt()
	if Ready(_R) then
		local Rtargets = GetEnemyHeroes()
		for i = 1, #Rtargets do
			local target = Rtargets[i]
			if target and target.health > 0 then
				local RDmg = getdmg("R", target, myHero)
				if target.health < RDmg then
					KillRCount = KillRCount + 1
				end       
			end
		end	
		
		if Menu.Ult.UseR:Value() and KillRCount >= Menu.Ult.count:Value() and GetEnemyCount(Menu.Ult.range:Value(), myHero) == 0 then
			CanUlt = true
			Control.CastSpell(HK_R)
			return
		end
	end	
end

function AutoQ()
    if Ready(_Q) and myHero.mana/myHero.maxMana >= Menu.QSet.Mana:Value() / 100 and CanUlt == false then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
			if myHero.pos:DistanceTo(minion.pos) <= 850 and minion.team == TEAM_ENEMY and IsValid(minion) then
				local Q1Dmg = getdmg("Q", minion, myHero, 1) -- single
				local Q2Dmg = getdmg("Q", minion, myHero, 2) -- aoe
				if minion.health < Q1Dmg and GetMinionCount(160, minion) == 0 then
					Control.CastSpell(HK_Q, minion.pos)
				else
					if minion.health < Q2Dmg and GetMinionCount(160, minion) > 0 then
						Control.CastSpell(HK_Q, minion.pos)	
					end	
				end	
			end
		end
	end	
end

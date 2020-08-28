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

local function EnemiesAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i = 1, GameHeroCount() do
        local hero = GameHero(i)
        if (IsValid(hero) and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end

local TwinTable = {}
local TwinFound = false

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO" .. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.09"}})
	
	--Auto W 
	Menu:MenuElement({type = MENU, id = "Auto", name = "Auto [W]"})
	Menu.Auto:MenuElement({id = "UseW", name = "[W] Immobile Enemies", value = true})			
	Menu.Auto:MenuElement({id = "Targets", name = "Minimum Enemies", value = 2, min = 1, max = 5, step = 1, identifier = "Enemies"})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Combo:MenuElement({type = MENU, id = "AutoUlt", name = "Ultimate Settings"})
	Menu.Combo.AutoUlt:MenuElement({id = "UseR", name = "[R] Safe Life", value = true})	
	Menu.Combo.AutoUlt:MenuElement({id = "life", name = "[R] if Ekko HP lower than -->", value = 20, min = 0, max = 100, identifier = "%"})	
	Menu.Combo.AutoUlt:MenuElement({id = "range", name = "Range between Ekko / Twin bigger than-->", value = 800, min = 0, max = 3000})	
	Menu.Combo.AutoUlt:MenuElement({id = "Enemyrange", name = "Is no Enemy in Twin range-->", value = 500, min = 0, max = 3000})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true}) 		
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"}) 
	
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})	
	Menu.ks:MenuElement({id = "UseR", name = "Kill in Twin Range", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Collision = false, Delay = 0.25, Radius = 160, Range = 1075, Speed = 1650
	}
	
	QspellData = {speed = 1650, range = 1075, delay = 0.25, radius = 160, collision = {nil}, type = "linear"}	
	
	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.25, Radius = 375, Range = 1600, Speed = 1650
	}

	WspellData = {speed = 1650, range = 1600, delay = 0.25, radius = 375, collision = {nil}, type = "circular"}	


	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1100, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 1600, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 325, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

function Tick()
AddTwin()
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
	if Ready(_R) and myHero.health/myHero.maxHealth <= Menu.Combo.AutoUlt.life:Value()/100 and Menu.Combo.AutoUlt.UseR:Value() then
		AutoUlt()
	end	
	AutoW()
	KillSteal()
end

function AddTwin()
	if Ready(_R) then
		if TwinFound == false then
			for i = 0, Game.ObjectCount() do
				local object = Game.Object(i)
				if object and myHero.pos:DistanceTo(object.pos) < 3000 and object.name == "Ekko" then
					local Twin = true
					for i = 1, #TwinTable do
						if TwinTable[i].networkID == object.networkID then
							Twin = false
						end
					end
					
					if Twin then
						if object.name == "Ekko" then
							TwinFound = true
							TableInsert(TwinTable, 1, {obj = object, networkID = object.networkID})					
						end
					end
				end	
			end
		end	
	else
		RemoveTwin()
		TwinFound = false
	end	
end	

function RemoveTwin()
	local LastScan = 0
	if GameTimer() - LastScan > 1 then
		for i = 1, #TwinTable do
			if TwinTable[i] then
				local Twin = TwinTable[i] 
				local object = Twin.obj
				if object then
					LastScan = GameTimer()				
					TableRemove(TwinTable, i)
				end
			end	
		end
	end
end

function KillSteal()	
	local target = GetTarget(3000)     	
	if target == nil then return end
	local hp = target.health
	local IGdamage = 50 + 20 * myHero.levelData.lvl
	local QDmg = getdmg("Q", target, myHero)
	local RDmg = getdmg("R", target, myHero)	
	local FullDmg = RDmg + QDmg
	local FullIgn = FullDmg + IGdamage
	if IsValid(target) then	
		
		if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.ks.UseQ:Value() and Ready(_Q) then
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
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 160, Range = 1075, Speed = 1650, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end
			end
		end
		
		if hp <= FullIgn then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) and myHero.pos:DistanceTo(target.pos) <= 600 then
				Control.CastSpell(HK_SUMMONER_1, target)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) and myHero.pos:DistanceTo(target.pos) <= 600 then	
				Control.CastSpell(HK_SUMMONER_2, target)
			end	
		end	
							
		if Ready(_R) and Menu.ks.UseR:Value() and (FullDmg > hp or hp <= FullIgn) then
			for i = 1, #TwinTable do
				local unit = TwinTable[i]
				local twin = unit.obj			
				if twin and target.pos:DistanceTo(twin.pos) <= 400 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) and Ready(_R) and Ready(_Q) and hp <= FullIgn then
						Control.CastSpell(HK_R)
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) and Ready(_R) and Ready(_Q) and hp <= FullIgn then
						Control.CastSpell(HK_R)
					end
					
					if Ready(_R) and Ready(_Q) and FullDmg > hp then
						Control.CastSpell(HK_R)
					end
				end
			end	
		end	
	end
end	

function AutoW()
	local target = GetTarget(1600)     	
	if target == nil then return end
	local Immo = GetImmobileCount(400, target)
	if Menu.Auto.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 1600 and IsValid(target) and Immo >= Menu.Auto.Targets:Value() then
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
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 375, Range = 1600, Speed = 1650, Collision = false})
			WPrediction:GetPrediction(target, myHero)
			if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
				Control.CastSpell(HK_W, WPrediction.CastPosition)
			end				
		end
	end
end

function Combo()
local target = GetTarget(1000)	
if target == nil then return end
    if IsValid(target) then
	
		if Ready(_W) and Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 900 then
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
				local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 375, Range = 1600, Speed = 1650, Collision = false})
				WPrediction:GetPrediction(target, myHero)
				if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
					Control.CastSpell(HK_W, WPrediction.CastPosition)
				end				
			end
		end		
	   
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 800 and Menu.Combo.UseE:Value() then 
			Control.CastSpell(HK_E, target.pos)
		end	
	
		if Ready(_Q) and Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 900 then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 160, Range = 1075, Speed = 1650, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end
		end	
	end
end	

function Harass()
local target = GetTarget(1000)	
if target == nil then return end
    if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then   
	
		if Ready(_Q) and Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 900 then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 160, Range = 1075, Speed = 1650, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end		
		end
	end	
end	
 	 
function AutoUlt()	
	for i = 1, #TwinTable do
		local unit = TwinTable[i]
		local twin = unit.obj	
		if twin then
			if myHero.pos:DistanceTo(twin.pos) >= Menu.Combo.AutoUlt.range:Value() and EnemiesAround(twin, Menu.Combo.AutoUlt.Enemyrange:Value()) == 0 then
				Control.CastSpell(HK_R)
			end
		end	
	end
end	

function Clear()	
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100   
		if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_ENEMY and IsValid(minion) and mana_ok then
            	
			if Ready(_Q) and Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) < 500 and Ready(_E) and Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end
		end
    end
end

function JungleClear()         
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100        
		if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_JUNGLE and IsValid(minion) and mana_ok then
       
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) < 500 and Ready(_E) and Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end
		end
    end
end

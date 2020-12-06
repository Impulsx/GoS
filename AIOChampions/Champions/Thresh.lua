
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

local function GetEnemyTurret()
	local _EnemyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        if turret.isEnemy and not turret.dead then
			TableInsert(_EnemyTurrets, turret)
		end
	end
	return _EnemyTurrets		
end

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2) 
		if turret.pos:DistanceTo(unit.pos) < range then
			return true
		end
    end
    return false
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
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q1]", value = true})		
	Menu.Combo:MenuElement({id = "UseQ2", name = "[Q2]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W] if [Q1] and Ally out of AArange", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "EMode", name = "[E] Mode Key Pull/Push", key = string.byte("T"), toggle = true, value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({id = "UseRE", name = "[R] min Enemies in range", value = 2, min = 1, max = 5})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q1]", value = true})	
	Menu.Harass:MenuElement({id = "UseQ2", name = "[Q2]", value = false})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"}) 

	--Extra
	Menu:MenuElement({type = MENU, id = "extra", name = "Extra Settings"})	
	Menu.extra:MenuElement({id = "Qmin", name = "[Q1] min range", value = 200, min = 1, max = 500})
	Menu.extra:MenuElement({id = "Qmax", name = "[Q1] max range", value = 900, min = 500, max = 1100})
	Menu.extra:MenuElement({id = "QTower", name = "[Q2] under enemy Turret ?", value = false})	
	Menu.extra:MenuElement({id = "QTime", name = "[Q2] waiting for cast", value = 1.2, min = 0, max = 1.4, step = 0.1, identifier = "sec"})
	Menu.extra:MenuElement({id = "UseW", name = "Auto [W] Save Ally lower than 30% Hp", value = true})
	Menu.extra:MenuElement({id = "WCount", name = "Auto [W] Save Ally if enemies near", value = 4, min = 1, max = 5})
	Menu.extra:MenuElement({id = "UseW2", name = "Auto [W] CCed Ally", value = true})
	Menu.extra:MenuElement({id = "UseR", name = "Auto [R]", value = true})
	Menu.extra:MenuElement({id = "UseRE", name = "Auto [R] min Enemies in range", value = 3, min = 1, max = 5})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Settings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "Text Pos Settings"})	
	Menu.Drawing.XY:MenuElement({id = "Text", name = "Draw EMode Text", value = true})		
	Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 700, min = 0, max = 1500, step = 10})
	Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})		

	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 70, Range = 1100, Speed = 1900, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1900, range = 1100, delay = 0.5, radius = 70, collision = {"minion"}, type = "linear"}			
  	                                           											   
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.Drawing.XY.Text:Value() then 
			DrawText("EMode: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+10, DrawColor(255, 225, 255, 0))		
			if Menu.Combo.EMode:Value() then
				DrawText("Pull", 15, Menu.Drawing.XY.x:Value()+45, Menu.Drawing.XY.y:Value()+10, DrawColor(255, 0, 255, 0))
			else
				DrawText("Push", 15, Menu.Drawing.XY.x:Value()+45, Menu.Drawing.XY.y:Value()+10, DrawColor(255, 0, 255, 0))
			end
		end	
		
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 470, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, Menu.extra.Qmax:Value(), 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 400, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 950, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		if Menu.Combo.UseQ2:Value() and myHero:GetSpellData(_Q).name == "ThreshQLeap" then
			SetAttack(false)
			DelayAction(function()
				SetAttack(true)
				CastQ2()
			end,Menu.extra.QTime:Value())
		else
			SetAttack(true)
		end		
	elseif Mode == "Harass" then
		Harass()
		if Menu.Harass.UseQ2:Value() and myHero:GetSpellData(_Q).name == "ThreshQLeap" then
			SetAttack(false)
			DelayAction(function()
				SetAttack(true)
				CastQ2()
			end,Menu.extra.QTime:Value())
		else
			SetAttack(true)
		end		
	end	

	AutoW()
	AutoR()	
end
	
function Combo()
local target = GetTarget(1100)
if target == nil then return end
	if IsValid(target) then
        
		if Ready(_E) and Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 400 and myHero:GetSpellData(_Q).name ~= "ThreshQLeap" then
			if Menu.Combo.EMode:Value() then
				CastE(target)
			else
				Control.CastSpell(HK_E, target.pos)
			end
		end		
		
		if Menu.Combo.UseQ:Value() and myHero:GetSpellData(_Q).name ~= "ThreshQLeap" and myHero.pos:DistanceTo(target.pos) < Menu.extra.Qmax:Value() and myHero.pos:DistanceTo(target.pos) >= Menu.extra.Qmin:Value() and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.5, Radius = 70, Range = 1100, Speed = 1900, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end	
			end
        end
       
		if Menu.Combo.UseW:Value() and Ready(_W) and HasBuff(target, "ThreshQ") then
			local Ally = FindNearestAlly(target)			
			if Ally and IsValid(Ally) then
				Control.CastSpell(HK_W, Ally.pos)
			end	
        end

        if Menu.Combo.UseR:Value() and Ready(_R) then
            local count = GetEnemyCount(450, myHero)
			if count >= Menu.Combo.UseRE:Value() then
				Control.CastSpell(HK_R)
			end	
		end
	end
end

function Harass()
local target = GetTarget(1100)
if target == nil then return end
	if IsValid(target) then				
		
		if Menu.Harass.UseQ:Value() and myHero:GetSpellData(_Q).name ~= "ThreshQLeap" and myHero.pos:DistanceTo(target.pos) < Menu.extra.Qmax:Value() and myHero.pos:DistanceTo(target.pos) >= Menu.extra.Qmin:Value() and Ready(_Q) then
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
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.5, Radius = 70, Range = 1100, Speed = 1900, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end	
			end
        end 
	end
end

function AutoW()	
	if Ready(_W) then	
		
		if Menu.extra.UseW:Value() then
			local LowAlly = FindLowestAlly()
			if LowAlly and IsValid(LowAlly) and LowAlly.health/LowAlly.maxHealth <= 0.3 and GetEnemyCount(950, LowAlly) >= Menu.extra.WCount:Value() then
				Control.CastSpell(HK_W, LowAlly.pos)
			end
		end
		
		if Menu.extra.UseW2:Value() then
			for i, Ally in ipairs(GetAllyHeroes()) do
				if Ally and myHero.pos:DistanceTo(Ally.pos) <= 950 and IsValid(Ally) and IsImmobileTarget(Ally) then
					Control.CastSpell(HK_W, Ally.pos)
				end
			end
		end
	end	
end	

function AutoR()
	if Menu.extra.UseR:Value() and Ready(_R) then
		local count = GetEnemyCount(450, myHero)
		if count >= Menu.extra.UseRE:Value() then
			Control.CastSpell(HK_R)
		end	
	end
end	

function CastE(unit)
	local EPos = Vector(myHero.pos) + (Vector(myHero.pos) - Vector(unit.pos))
	Control.CastSpell(HK_E, EPos)
end

function CastQ2()
	for i, target in ipairs(GetEnemyHeroes()) do
		if HasBuff(target, "ThreshQ") then
			if Menu.extra.QTower:Value() then
				if not IsUnderTurret(target) then
					Control.CastSpell(HK_Q)
				end
			else
				Control.CastSpell(HK_Q)
			end
		end
	end
end
	
function FindLowestAlly()
	LowestAlly = nil
	for i, Ally in ipairs(GetAllyHeroes()) do
		if Ally and GetDistance(Ally.pos, myHero.pos) <= 950 and IsValid(Ally) then
			if LowestAlly == nil then
				LowestAlly = Ally
			elseif Ally.health < LowestAlly.health then
				LowestAlly = Ally
			end
		end
	end
	return LowestAlly
end

function FindNearestAlly(unit)
	local NearestAlly = nil
	for i, Ally in ipairs(GetAllyHeroes()) do
		if NearestAlly == nil then 
			if GetDistance(Ally.pos, myHero.pos) <= 1250 and IsValid(Ally) and GetDistance(Ally.pos, unit.pos) > Ally.range then
				NearestAlly = Ally
			end	
			
		elseif GetDistance(Ally.pos, myHero.pos) <= 1250 and IsValid(Ally) and GetDistance(Ally.pos, myHero.pos) > GetDistance(NearestAlly.pos, myHero.pos) and GetDistance(Ally.pos, unit.pos) > Ally.range then
			NearestAlly = Ally
		end
	end
	return NearestAlly
end

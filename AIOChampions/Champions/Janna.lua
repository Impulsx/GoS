
local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

local function GetDistance(pos1, pos2)
	return math.sqrt(GetDistanceSqr(pos1, pos2))
end

local function EnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

local function AllyHeroes()
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function GetAllyTurret()
	local _AllyTurrets = {}
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret.isAlly and not turret.dead then
			TableInsert(_AllyTurrets, turret)
		end
	end
	return _AllyTurrets		
end

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(EnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
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
	return false
end
	
function LoadScript()                     
	
--MainMenu
Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
		
--Combo 
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "QRange", name = "[Q] Only if range bigger than -->", value = 400, min = 0, max = 1000, step = 5})	
	Menu.Combo:MenuElement({name = " ", drop = {"[Q] CastTime = 1000range +(125range per 0.5sec)"}})	
	Menu.Combo:MenuElement({id = "QDelay", name = "[Q] CastTime -->", value = 2, min = 0, max = 3, step = 0.5, identifier = "sec"})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	
	Menu.Combo:MenuElement({type = MENU, id = "ComboE", name = "[E] Settings"})	
		Menu.Combo.ComboE:MenuElement({id = "UseE", name = "[E]", value = true})
		Menu.Combo.ComboE:MenuElement({id = "Emode", name = "[E] Mode", value = 1, drop = {"Combo Mode", "Auto Cast Mode"}})	
		Menu.Combo.ComboE:MenuElement({id = "UseE2", name = "[E] Shield Tower", value = true})
		Menu.Combo.ComboE:MenuElement({id = "UseE3", name = "[E] Shield Janna", value = true})
		Menu.Combo.ComboE:MenuElement({id = "UseE3H", name = "[E] if Janna Hp lower than -->", value = 30, min = 0, max = 100, step = 5, identifier = "%"})
		Menu.Combo.ComboE:MenuElement({id = "UseE4", name = "[E] Shield Ally", value = true})
		Menu.Combo.ComboE:MenuElement({id = "UseE4H", name = "[E] if Ally Hp lower than -->", value = 50, min = 0, max = 100, step = 5, identifier = "%"})
		Menu.Combo.ComboE:MenuElement({id = "Targets", name = "Ally BlockList", type = MENU})
		DelayAction(function()
			for i, Hero in pairs(AllyHeroes()) do
				Menu.Combo.ComboE.Targets:MenuElement({id = Hero.charName, name = "Block [E] on "..Hero.charName, value = false})		
			end	
		end,0.2)	

	Menu.Combo:MenuElement({type = MENU, id = "ComboR", name = "[R] Settings"})	
		Menu.Combo.ComboR:MenuElement({id = "UseR", name = "[R]", value = true})
		Menu.Combo.ComboR:MenuElement({id = "Rmode", name = "[R] Mode", value = 1, drop = {"Combo Mode", "Auto Cast Mode"}})
		Menu.Combo.ComboR:MenuElement({id = "UseR2", name = "[R] Stop for [E] Shield Janna/Ally", value = false})	
		Menu.Combo.ComboR:MenuElement({id = "UseR3", name = "[R] Check Janna Hp", value = true})
		Menu.Combo.ComboR:MenuElement({id = "UseR3H", name = "[R] if Janna Hp lower than -->", value = 15, min = 0, max = 100, step = 5, identifier = "%"})
		Menu.Combo.ComboR:MenuElement({id = "UseR4", name = "[R] Check Ally Hp", value = true})
		Menu.Combo.ComboR:MenuElement({id = "UseE4H", name = "[R] if Ally Hp lower than -->", value = 30, min = 0, max = 100, step = 5, identifier = "%"})
		Menu.Combo.ComboR:MenuElement({id = "Targets", name = "Ally BlockList", type = MENU})
		DelayAction(function()
			for i, Hero in pairs(AllyHeroes()) do
				Menu.Combo.ComboR.Targets:MenuElement({id = Hero.charName, name = "Block [R] on "..Hero.charName, value = false})		
			end	
		end,0.2)		
			
--Harass		
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Mode"})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})		
		
		
--Prediction
Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	


--Drawing 
Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] min Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end                                                 
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			Draw.Circle(myHero, 775, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			Draw.Circle(myHero, 1000, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			Draw.Circle(myHero, 550, 1, Draw.Color(225, 225, 125, 10))
		end		
	end)
	
	QRange = 1000 + (250 * Menu.Combo.QDelay:Value())
	QSpeed = 666.7 + (166.6 * Menu.Combo.QDelay:Value())
	QDelay = Menu.Combo.QDelay:Value()


	QData ={Type = _G.SPELLTYPE_LINE, Delay = QDelay+ping, Radius = 60, Range = QRange, Speed = QSpeed, Collision = false}
	QspellData = {speed = QSpeed, range = QRange, delay = QDelay+ping, radius = 60, collision = {nil}, type = "linear"}
	
end

local ActiveUlt = false
casted = false

function Tick()					
	local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid and myHero.isChanneling and currSpell.name == "JannaR" then	
		SetAttack(false)
		SetMovement(false)
		ActiveUlt = true
	else
		SetAttack(true)
		SetMovement(true)	
		ActiveUlt = false
	end
	
	local Buff = GetBuffData(myHero, "HowlingGale")		
	if buff and Buff.duration <= (3 - Menu.Combo.QDelay:Value()) then
		Control.CastSpell(HK_Q)
	end	
	
	if casted then
		DelayAction(function()	
			casted = false 
		end,Menu.Combo.QDelay:Value()+0.25)	
	end	
	
	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()	
	end
	
	if Menu.Combo.ComboE.UseE:Value() and Ready(_E) and Menu.Combo.ComboE.Emode:Value() == 2 then
		CastE()
	end	

	if Menu.Combo.ComboR.UseR:Value() and Ready(_R) and Menu.Combo.ComboR.Rmode:Value() == 2 then
		CastR()
	end		
end

function Combo()	
	local target = GetTarget(QRange)     	
	if target == nil then return end	
	if IsValid(target) then
		if Menu.Combo.ComboE.UseE:Value() and Ready(_E) and Menu.Combo.ComboE.Emode:Value() == 1 then
			CastE()
		end			
		
		if ActiveUlt then return end
		
		if Menu.Combo.UseQ:Value() and Ready(_Q) and GetDistance(myHero.pos, target.pos) >= Menu.Combo.QRange:Value() then
			local Buff = GetBuffData(myHero, "HowlingGale")
			if not Buff then 
				GetPredQ(target)
			end	
		end
		
		if Menu.Combo.UseW:Value() and Ready(_W) then
			if GetDistance(myHero.pos, target.pos) < 600 then
				Control.CastSpell(HK_W, target)
			end
		end

		if Menu.Combo.ComboR.UseR:Value() and Ready(_R) and Menu.Combo.ComboR.Rmode:Value() == 1 then
			CastR()
		end		
	end		
end

function CastE()	
	if Menu.Combo.ComboE.UseE2:Value() and not ActiveUlt then
		for k, enemy in ipairs(EnemyHeroes()) do    	
			if enemy and GetDistance(enemy.pos, myHero.pos) < 2000 and IsValid(enemy) then		
				for i, turret in ipairs(GetAllyTurret()) do
					
					if turret and GetDistance(myHero.pos, turret.pos) < 800 and turret.targetID == enemy.networkID then
						Control.CastSpell(HK_E, turret)
					end
				end
			end	
		end	
	end	
		
	if ActiveUlt and not Menu.Combo.ComboR.UseR2:Value() then return end
	if Menu.Combo.ComboE.UseE3:Value() then
		local Count = GetEnemyCount(1600, myHero)
		if Count >= 1 and myHero.health/myHero.maxHealth <= Menu.Combo.ComboE.UseE3H:Value() / 100 and not IsRecalling(myHero) then
			Control.CastSpell(HK_E, myHero)
		end
	end
	
	if Menu.Combo.ComboE.UseE4:Value() then
		for i, ally in ipairs(AllyHeroes()) do
			if ally and GetDistance(myHero.pos, ally.pos) < 800 and IsValid(ally) and Menu.Combo.ComboE.Targets[ally.charName] and not Menu.Combo.ComboE.Targets[ally.charName]:Value() and not IsRecalling(ally) then
				local Count = GetEnemyCount(1600, ally)
				if Count >= 1 and ally.health/ally.maxHealth <= Menu.Combo.ComboE.UseE4H:Value() / 100 then
					Control.CastSpell(HK_E, ally)
				end
			end
		end	
	end	
end

function CastR()	
	if Menu.Combo.ComboR.UseR3:Value() then
		local Count = GetEnemyCount(1600, myHero)
		if Count >= 1 and myHero.health/myHero.maxHealth <= Menu.Combo.ComboR.UseR3H:Value() / 100 and not IsRecalling(myHero) then
			Control.CastSpell(HK_R)
		end
	end
	
	if Menu.Combo.ComboR.UseR4:Value() then
		for i, ally in ipairs(AllyHeroes()) do
			if ally and GetDistance(myHero.pos, ally.pos) < 700 and IsValid(ally) and Menu.Combo.ComboR.Targets[ally.charName] and not Menu.Combo.ComboR.Targets[ally.charName]:Value() and not IsRecalling(ally) then
				local Count = GetEnemyCount(1600, ally)
				if Count >= 1 and ally.health/ally.maxHealth <= Menu.Combo.ComboR.UseE4H:Value() / 100 then
					Control.CastSpell(HK_R)
				end
			end
		end	
	end	
end

function Harass()
	local target = GetTarget(600)     	
	if target == nil or ActiveUlt then return end
	if IsValid(target) then

		if Menu.Combo.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target)
		end	
	end	
end

function GetPredQ(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, QData, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
			Control.CastSpell(HK_Q, pred.CastPos)
		end
	else
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = QDelay+ping, Radius = 60, Range = QRange, Speed = QSpeed, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) and not casted then
			casted = true
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
   			return
		end		
	end
end

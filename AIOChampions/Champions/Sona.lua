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

local function CountEnemiesNear(pos, range)
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
	Menu:MenuElement({name = " ", drop = {"Version 0.06"}})	
	
	Menu:MenuElement({id = "Key", name = "Key Settings", type = MENU})
	Menu.Key:MenuElement({id = "Combo",name = "Combo Key", key = string.byte(" ")})
	Menu.Key:MenuElement({id = "Harass",name = "Harass Key", key = string.byte("C")})

	Menu:MenuElement({type = MENU, id = "Qset", name = "Q Settings"})
	Menu.Qset:MenuElement({id = "Combo",name = "Use in Combo", value = true })
	Menu.Qset:MenuElement({id = "Harass", name = "Use in Harass", value = true})
	
	Menu:MenuElement({id = "Wset", name = "W Settings", type = MENU})
	Menu.Wset:MenuElement({id = "AutoW", name = "Enable Auto Health",value = true})
	Menu.Wset:MenuElement({id = "MyHp", name = "My HP lower than",value = 30, min = 1, max = 100,step = 1, identifier = "%"})
	Menu.Wset:MenuElement({id = "AllyHp", name = "AllyHP lower than",value = 50, min = 1, max = 100,step = 1, identifier = "%"})
	
	Menu:MenuElement({id = "Rset", name = "R Settings",type = MENU})
	Menu.Rset:MenuElement({id = "AutoR", name = "Enable Auto R",value = true})
	Menu.Rset:MenuElement({id = "RHit", name = "Min enemies hit",value = 2, min = 1, max = 5,step = 1})
	Menu.Rset:MenuElement({id = "AllyHp", name = "Use Ult if AllyHP lower than ",value = 30, min = 1, max = 100,step = 1, identifier = "%"})	
	
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	Menu:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
	Menu.Draw:MenuElement({id = "Q", name = "Draw Q Range", value = true})
	Menu.Draw:MenuElement({id = "W", name = "Draw W Range", value = true})
	Menu.Draw:MenuElement({id = "E", name = "Draw E Range", value = true})
	
	Q = {range = 825}
	W = {range = 1000}
	E = {range = 925}
	R = {range = 900}	
	
	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 235, Range = 825, Speed = 1000, Collision = false
	}
	
	QspellData = {speed = 1000, range = 825, delay = 0.25, radius = 235, collision = {nil}, type = "circular"}	
	
	Callback.Add("Tick", function() Tick() end)	

	Callback.Add("Draw", function()
		if myHero.dead then return end

		if Menu.Draw.Q:Value() then
			local qcolor = Ready(_Q) and  DrawColor(189, 183, 107, 255) or DrawColor(240,255,0,0)
			DrawCircle(Vector(myHero.pos),Q.range,1,qcolor)
		end
		if Menu.Draw.W:Value() then
			local wcolor = Ready(_W) and  DrawColor(240,30,144,255) or DrawColor(240,255,0,0)
			DrawCircle(Vector(myHero.pos),W.range,1,wcolor)
		end
		if Menu.Draw.E:Value() then
			local ecolor = Ready(_E) and  DrawColor(233, 150, 122, 255) or DrawColor(240,255,0,0)
			DrawCircle(Vector(myHero.pos),E.range,1,ecolor)
		end
	end)	
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.Key.Combo:Value() then
			Combo()
		end
	elseif Mode == "Harass" then
		if Menu.Key.Harass:Value() then
			Harass()
		end	
	end
	if Ready(_R) then
		AutoR()
		AutoR2()
	end
	if Ready(_W) then
		AutoW()
		AutoW2()
	end
end

function Combo()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 825 then	

		if Ready(_Q) and Menu.Qset.Combo:Value() then
			CastQ(target)
		end
	end
end

function Harass()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 825 then	
	
		if Ready(_Q) and Menu.Qset.Harass:Value() then
			CastQ(target)
		end
	end
end

function AutoW()
	for i, ally in pairs(GetAllyHeroes()) do
		if myHero.pos:DistanceTo(ally.pos) <= W.range and IsValid(ally) and Menu.Wset.AutoW:Value() then
			if ally.health/ally.maxHealth  < Menu.Wset.AllyHp:Value()/100 then
				Control.CastSpell(HK_W,ally.pos)
				return
			
			end			
		end
	end
end

function AutoW2()
	if myHero.health/myHero.maxHealth < Menu.Wset.MyHp:Value()/100 and Menu.Wset.AutoW:Value() then
		Control.CastSpell(HK_W,myHero.pos)
		return
	end
end

function AutoR()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < 900 and Menu.Rset.AutoR:Value() then		
		for i, ally in pairs(GetAllyHeroes()) do
			if ally.health/ally.maxHealth < Menu.Rset.AllyHp:Value()/100 and CountEnemiesNear(ally, 800) > 0 then
				Control.CastSpell(HK_R,target.pos)
				return
			end	
		end
	end
end	

function AutoR2()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < 900 and Menu.Rset.AutoR:Value() then	
		if CountEnemiesNear(target, 500) >= Menu.Rset.RHit:Value() then
			Control.CastSpell(HK_R,target.pos)
			return
		end	
	end
end

function CastQ(target)
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
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 235, Range = 825, Speed = 1000, Collision = false})
		QPrediction:GetPrediction(target, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end	
	end
end

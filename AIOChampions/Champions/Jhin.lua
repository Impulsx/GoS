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

local function GetAngle(v1, v2)
	local vec1 = v1:Len()
	local vec2 = v2:Len()
	local Angle = math.abs(math.deg(math.acos((v1*v2)/(vec1*vec2))))
	if Angle < 60 then
		return true
	end
	return false
end

local function DarkHarvest()
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff and buff.name:lower():find("darkharvest") then 
			return true
		end
	end
	return false
end

local function DarkHarvestReady()
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff and buff.name:lower():find("darkharvestcooldown") and buff.count == 0 then 
			return true
		end
	end
	return false
end

local function IsCastingAA(AAName)
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == AAName then
		return true
	end
	return false	
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.11"}})	
	
	--AutoW 
	Menu:MenuElement({type = MENU, id = "AutoW", name = "Stack Dark Harvest"})
	DelayAction(function()
		if DarkHarvest() then	
			Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W] HP Enemy is less 50%", value = true})
		else
			Menu.AutoW:MenuElement({name = " ", drop = {"Dark Harvest not equipped"}})	
		end
	end,0.2)	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"[Q]before 4th AAhit", "[Q]after 4th AAhit"}})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]marked Target", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({type = MENU, id = "Ulti", name = "Ult Setting"})
	Menu.Combo.Ulti:MenuElement({name = " ", drop = {"Hold Down AimKey [Result = StartUlt + AutoAim]"}})
	Menu.Combo.Ulti:MenuElement({id = "UseR", name = "Ult AimKey", key = string.byte("T")})
	Menu.Combo.Ulti:MenuElement({id = "Draw", name = "Killable Text[onScreen+Minimap]", value = true})
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]Hit Minion+Enemy", value = 1, drop = {"Automatically", "HarassKey"}})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	Menu.Clear.Last:MenuElement({id = "UseW", name = "LastHit[W]Cannon[out of AA range]", value = 2, drop = {"Automatically", "ClearKey"}})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 3, min = 1, max = 6, step = 1}) 
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]if min 1 Minion killable", value = true})
	Menu.Clear:MenuElement({id = "UseQM", name = "Use[Q]min Minions arround killable Minion", value = 3, min = 1, max = 3, step = 1}) 
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	
	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.75, Radius = 20, Range = 3000, Speed = 5000, Collision = false
	}
	
	WspellData = {speed = 5000, range = 3000, delay = 0.75, radius = 20, collision = {nil}, type = "linear"}

	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 1.25, Radius = 120, Range = 750, Speed = 1600, Collision = false
	}
	
	EspellData = {speed = 1600, range = 750, delay = 1.25, radius = 120, collision = {nil}, type = "circular"}	

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 3500, Speed = 5000, Collision = false
	}
	
	RspellData = {speed = 5000, range = 3500, delay = 0.25, radius = 80, collision = {nil}, type = "linear"}		
  	
	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function()
	if myHero.dead then return end
	
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 3500, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 600, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 750, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 3000, 1, DrawColor(225, 225, 125, 10))
		end
		
		local target = GetTarget(20000)
		if target == nil then return end	
		if Menu.Combo.Ulti.Draw:Value() and IsValid(target) then
		local Dmg = getdmg("R", target, myHero, 1)
		local hp = (target.health)	
			if Ready(_R) and (5*Dmg) > hp then
				DrawText("Ult Kill", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
				DrawText("Ult Kill", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))
			end	
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		HarassE()
		if Menu.Harass.UseQ:Value() ~= 1 then
			Harass()
		end	
	elseif Mode == "Clear" then
		Clear()
		if Menu.Clear.Last.UseW:Value() ~= 1 then
			LastHitW()
		end	
	end	
	
	if Menu.Harass.UseQ:Value() ~= 2 and Mode ~= "Combo" then
		Harass()
	end
	
	if Menu.Clear.Last.UseW:Value() ~= 2 and Mode ~= "Combo" then
		LastHitW()
	end
	
	if Menu.Combo.Ulti.UseR:Value() then
		StartR()
	end	

	KillSteal()
	if Menu.AutoW.UseW and Menu.AutoW.UseW:Value() then
		AutoW()
	end
end

function StartR()
	if myHero:GetSpellData(_R).name == "JhinRShot" then
		AimUlt()
	else
		local target = GetTarget(3500)     	
		if target == nil then return end
		
		if myHero.pos:DistanceTo(target.pos) < 3500 and IsValid(target) and Ready(_R) and myHero:GetSpellData(_R).name == "JhinR" then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, RData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					Control.CastSpell(HK_R, pred.CastPosition)
					return
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)		
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then 
					Control.CastSpell(HK_R, pred.CastPos)
					return
				end
			else
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 3500, Speed = 5000, Collision = false})
				RPrediction:GetPrediction(target, myHero)
				if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
					Control.CastSpell(HK_R, RPrediction.CastPosition)
					return
				end
			end	
		end
	end	
end
			
function AimUlt()				
	local target = GetTarget(3500)     	
	if target then 
		if myHero.pos:DistanceTo(target.pos) < 3500 and IsValid(target) and Ready(_R) and GetAngle(myHero.pos, target.pos) then
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
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 3500, Speed = 5000, Collision = false})
				RPrediction:GetPrediction(target, myHero)
				if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
					Control.CastSpell(HK_R, RPrediction.CastPosition)
				end
			end	
		end
	else
		for i, unit in ipairs(GetEnemyHeroes()) do
			if unit and IsValid(unit) and GetAngle(myHero.pos, unit.pos) and myHero.pos:DistanceTo(unit.pos) < 3500 then
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
					local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 3500, Speed = 5000, Collision = false})
					RPrediction:GetPrediction(unit, myHero)
					if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
						Control.CastSpell(HK_R, RPrediction.CastPosition)
					end
				end
			end
		end
	end
end	

function AutoW()
if myHero:GetSpellData(_R).name == "JhinRShot" then return end	
	for i, target in ipairs(GetEnemyHeroes()) do     	
		if Ready(_W) and DarkHarvestReady() and target and myHero.pos:DistanceTo(target.pos) <= 3000 and IsValid(target) then
			if target.health/target.maxHealth < 0.5 then
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
	
function Combo()
local target = GetTarget(2800)     	
if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) then
			
		if myHero.pos:DistanceTo(target.pos) <= 550 and Ready(_Q) then
			if Menu.Combo.UseQ:Value() ~= 1 then
				if IsCastingAA("JhinPassiveAttack") then
					DelayAction(function()
					Control.CastSpell(HK_Q, target)
					end,Latency()/100)
				end
			else 
				if IsCastingAA("JhinBasicAttack3") then
					DelayAction(function()
						Control.CastSpell(HK_Q, target)
					end,Latency()/100)
				end
			end	
		end
		
		if Menu.Combo.UseW:Value() and Ready(_W) then
			if HasBuff(target, "jhinespotteddebuff") then					
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

		if Ready(_E) and Game.CanUseSpell(_E) == 0 and Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 750 then
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

function Harass()
local target = GetTarget(1000)
if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 and Ready(_Q) then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
			if myHero.pos:DistanceTo(minion.pos) <= 550 and minion.team == TEAM_ENEMY and IsValid(minion) then
				local QDmg = getdmg("Q", minion, myHero)
				local count = GetMinionCount(400, minion)
				if QDmg >= minion.health and target.pos:DistanceTo(minion.pos) <= 400 and count <= 3 then
					Control.CastSpell(HK_Q, minion)
				else
					if myHero.pos:DistanceTo(target.pos) <= 550 then
						Control.CastSpell(HK_Q, target)
					end	
				end	
			else
				if myHero.pos:DistanceTo(target.pos) <= 550 then
					Control.CastSpell(HK_Q, target)
				end				
			end
		end	
	end
end

function HarassE()
local target = GetTarget(750)
if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if Ready(_E) and Game.CanUseSpell(_E) == 0 and Menu.Harass.UseE:Value() then
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

function Clear()
    if myHero:GetSpellData(_R).name == "JhinRShot" then return end
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 800 and minion.team == TEAM_ENEMY and IsValid(minion) then
            
            
			if Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 550 and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero)
				local count = GetMinionCount(400, minion)
				if QDmg >= minion.health and count >= Menu.Clear.UseQM:Value() then
					Control.CastSpell(HK_Q, minion)
				end	
            end
            local count = GetMinionCount(260, minion)          
			if Ready(_E) and Game.CanUseSpell(_E) == 0 and Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 750 and count >= Menu.Clear.UseEM:Value() then
				Control.CastSpell(HK_E, minion.pos)                   
            end
        end
    end
end

function LastHitW()
	if myHero:GetSpellData(_R).name == "JhinRShot" then return end
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 1500 and minion.team == TEAM_ENEMY and (minion.charName == "SRU_ChaosMinionSiege" or minion.charName == "SRU_OrderMinionSiege") and IsValid(minion) then
			local WDmg = getdmg("W", minion, myHero, 2)
			if myHero.pos:DistanceTo(minion.pos) > 550 and WDmg > minion.health then
				Control.CastSpell(HK_W, minion.pos)
			end
		end
	end
end	

function KillSteal()     	
if myHero:GetSpellData(_R).name == "JhinRShot" then return end
	for i, target in ipairs(GetEnemyHeroes()) do 	
		if target and Ready(_W) and Menu.ks.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 2800 and IsValid(target) then
			local WDmg = getdmg("W", target, myHero, 1)
			local hp = target.health
			if WDmg > hp then
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

function CastGGPred(spell, unit)
	if spell == _W then
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.75, Radius = 20, Range = 3000, Speed = 5000, Collision = false})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
			Control.CastSpell(HK_W, WPrediction.CastPosition)
		end	
	
	elseif spell == _E then
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 1.2, Radius = 60, Range = 750, Speed = 1000, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end			
	end
end


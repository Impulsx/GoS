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

local function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff
		end
	end
	return nil
end

local CanCastW = 0
local BlockW = false
local WRange = 1200
function LoadScript() 

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})			
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R] Target under 30% Hp", value = false})		
	
	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})

	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})	
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	Menu.ks:MenuElement({id = "Mode", name = "KillSteal Mode", value = 2, drop = {"Auto Mode", "Combo Mode"}})	
	  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})	
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 30, min = 0, max = 100, identifier = "%"})		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 800, Speed = 2400, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 2400, range = 800, delay = 0.25, radius = 60, collision = {"minion"}, type = "linear"}

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.35, Radius = 150, Range = 450, Speed = MathHuge, Collision = false
	}
	
	RspellData = {speed = MathHuge, range = 450, delay = 0.35, radius = 0, angle = 180, collision = {nil}, type = "conic"}	
  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end

		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 800, 1, DrawColor(255, 225, 255, 10))
		end  
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, WRange, 1, DrawColor(255, 225, 255, 10))
		end 
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 210, 1, DrawColor(255, 225, 255, 10))
		end 		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 500, 1, DrawColor(225, 225, 0, 10))
		end		
	end)		
end

function Tick()		
    if WRange < (1100 + 100 * myHero:GetSpellData(_W).level) then
        WRange = 1100 + 100 * myHero:GetSpellData(_W).level
    end	

	if MyHeroNotReady() then return end
	local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.ks.Mode:Value() == 2 then
			KS()
		end
	elseif Mode == "Harass" then
		Harass()		
	elseif Mode == "Clear" then
		LaneClear()
		JungleClear()		
	end
	if Menu.ks.Mode:Value() == 1 then
		KS()
	end
end

function KS()
    for i, Enemy in ipairs(GetEnemyHeroes()) do
		
		if Ready(_Q) and GetDistance(myHero.pos, Enemy.pos) < 750 and IsValid(Enemy) and myHero:GetSpellData(_Q).name == "EvelynnQ" and getdmg("Q", Enemy, myHero) > Enemy.health then
			if Ready(_W) then 
				BlockW = true
			end	
			CastQ(Enemy)
			
		elseif Ready(_Q) and GetDistance(myHero.pos, Enemy.pos) < 550 and IsValid(Enemy) and myHero:GetSpellData(_Q).name == "EvelynnQ" and (getdmg("Q", Enemy, myHero)*4) > Enemy.health then
			if Ready(_W) then 
				BlockW = true
			end				
			CastQ(Enemy) 

		elseif Ready(_Q) and GetDistance(myHero.pos, Enemy.pos) < 550 and IsValid(Enemy) and myHero:GetSpellData(_Q).name == "EvelynnQ2" and (getdmg("Q", Enemy, myHero)*3) > Enemy.health then
			if Ready(_W) then 
				BlockW = true
			end				
			Control.CastSpell(HK_Q, Enemy)

		elseif Ready(_R) and GetDistance(myHero.pos, Enemy.pos) < 450 and IsValid(Enemy) and Enemy.health/Enemy.maxHealth > 0.3 and getdmg("R", Enemy, myHero) > Enemy.health then
			if Ready(_W) then 
				BlockW = true
			end				
			CastR(Enemy)
			
		elseif Ready(_R) and GetDistance(myHero.pos, Enemy.pos) < 450 and IsValid(Enemy) and Enemy.health/Enemy.maxHealth < 0.28 and (getdmg("R", Enemy, myHero)+((getdmg("R", Enemy, myHero)/100)*140)) > Enemy.health then
			if Ready(_W) then 
				BlockW = true
			end				
			CastR(Enemy)

		elseif Ready(_E) and GetDistance(myHero.pos, Enemy.pos) < 300 and IsValid(Enemy) and getdmg("E", Enemy, myHero) > Enemy.health then
			if Ready(_W) then 
				BlockW = true
			end				
			Control.CastSpell(HK_E, Enemy)

		else
			if GetMode() == "Combo" then
				BlockW = false
				Combo()
			end
		end 
	end
end 

function Combo()
	local target = GetTarget(WRange)
	if target == nil then return end
	if IsValid(target) then
	
		if GetDistance(myHero.pos, target.pos) < WRange then
			local QDmg = Ready(_Q) and myHero:GetSpellData(_Q).name == "EvelynnQ" and getdmg("Q", target, myHero)*4 or 0
			local EDmg = Ready(_E) and getdmg("E", target, myHero) or 0
			local RDmg = Ready(_R) and getdmg("R", target, myHero) or 0
			local ComboDmg = QDmg+EDmg+RDmg
			if ComboDmg > target.health then
				BlockW = true
			end        
		end
		
		local WBuff = GetBuffData(target, "EvelynnW")
		
		if WBuff and WBuff.duration > 2.5 and target.activeSpell.target ~= myHero.handle then return end
		
		if BlockW == false and Menu.Combo.UseW:Value() and GetDistance(myHero.pos, target.pos) < WRange and Ready(_W) then
			CanCastW = GameTimer()
			Control.CastSpell(HK_W, target)	
        else		
		
			if Menu.Combo.UseE:Value() and Ready(_E) and GetDistance(myHero.pos, target.pos) < 300 and myHero:GetSpellData(_Q).name ~= "EvelynnQ2" then
				Control.CastSpell(HK_E, target)		
			end	
			
			if Menu.Combo.UseQ:Value() and Ready(_Q) and GameTimer() - CanCastW > 0.4 then
				if myHero:GetSpellData(_Q).name == "EvelynnQ" then
					CastQ(target)	
				else
					if myHero:GetSpellData(_Q).name == "EvelynnQ2" and GetDistance(myHero.pos, target.pos) <= 550 then
						Control.CastSpell(HK_Q, target)
					end			
				end	
			end	

			if Menu.Combo.UseR:Value() and Ready(_R) and GetDistance(myHero.pos, target.pos) < 450 and target.health/target.maxHealth < 0.28 then
				CastR(target)		
			end
		end	
	end
end

function Harass()
	local target = GetTarget(750)
	if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
        
		if Menu.Harass.UseQ:Value() and Ready(_Q) then
			if myHero:GetSpellData(_Q).name == "EvelynnQ" then
				CastQ(target)	
			else
				if myHero:GetSpellData(_Q).name == "EvelynnQ2" and GetDistance(myHero.pos, target.pos) <= 550 then
					Control.CastSpell(HK_Q, target)
				end			
			end	
        end
	end
end

function LaneClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY and GetDistance(myHero.pos, minion.pos) < 750 and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
            
			if Menu.Clear.UseE:Value() and GetDistance(myHero.pos, minion.pos) < 300 and Ready(_E) and myHero:GetSpellData(_Q).name ~= "EvelynnQ2" then
				Control.CastSpell(HK_E, minion)	
            end
			
			if Menu.Clear.UseQ:Value() and Ready(_Q) then
				if myHero:GetSpellData(_Q).name == "EvelynnQ" then
					Control.CastSpell(HK_Q, minion.pos)	
				else
					if myHero:GetSpellData(_Q).name == "EvelynnQ2" and GetDistance(myHero.pos, minion.pos) <= 550 then
						Control.CastSpell(HK_Q, minion)
					end			
				end	
			end			
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE and GetDistance(myHero.pos, minion.pos) < 750 and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
			
			if Menu.JClear.UseE:Value() and GetDistance(myHero.pos, minion.pos) < 300 and Ready(_E) and myHero:GetSpellData(_Q).name ~= "EvelynnQ2" then
				Control.CastSpell(HK_E, minion)	
            end
			
			if Menu.JClear.UseQ:Value() and Ready(_Q) then
				if myHero:GetSpellData(_Q).name == "EvelynnQ" then
					Control.CastSpell(HK_Q, minion.pos)	
				else
					if myHero:GetSpellData(_Q).name == "EvelynnQ2" and GetDistance(myHero.pos, minion.pos) <= 550 then
						Control.CastSpell(HK_Q, minion)
					end			
				end	
			end	
        end
    end
end

function CastQ(unit)
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
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 800, Speed = 2400, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end	
	end	
end

function CastR(unit)
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
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.35, Radius = 150, Range = 450, Speed = MathHuge, Collision = false})
		RPrediction:GetPrediction(unit, myHero)
		if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
			Control.CastSpell(HK_R, RPrediction.CastPosition)
		end	
	end	
end

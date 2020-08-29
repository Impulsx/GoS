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

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.09"}})
	
	Menu:MenuElement({type = MENU, id = "Qset", name = "Q Setting"})	
	Menu.Qset:MenuElement({id = "Qmin", name = "Min range use Q Human", value = 600, min = 400, max = 1500,step = 1})	
	
	--Combo
	Menu:MenuElement({type = MENU, id = "ComboMode", name = "Combo"})
	Menu.ComboMode:MenuElement({id = "UseQ", name = "Q: Javelin Toss", value = true})
	Menu.ComboMode:MenuElement({id = "UseW", name = "W: Bushwhack", value = true})
	Menu.ComboMode:MenuElement({id = "UseE", name = "E: Primal Surge", value = true})
	Menu.ComboMode:MenuElement({id = "UseQQ", name = "Q: Takedown", value = true})
	Menu.ComboMode:MenuElement({id = "UseWW", name = "W: Pounce", value = true})
	Menu.ComboMode:MenuElement({id = "UseEE", name = "E: Swipe", value = true})
	Menu.ComboMode:MenuElement({id = "UseR", name = "R: Aspect of the Cougar", value = true})
	Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
		
	--Harass
	Menu:MenuElement({type = MENU, id = "HarassMode", name = "Harass"})
	Menu.HarassMode:MenuElement({id = "UseQ", name = "Q: Javelin Toss", value = true})

	--Lane/JungleClear
	Menu:MenuElement({type = MENU, id = "ClearMode", name = "Lane/JungleClear"})
	Menu.ClearMode:MenuElement({id = "UseQ", name = "Q: Javelin Toss", value = true})
	Menu.ClearMode:MenuElement({id = "UseW", name = "W: Bushwhack", value = true})
	Menu.ClearMode:MenuElement({id = "UseE", name = "E: Primal Surge", value = true})
	Menu.ClearMode:MenuElement({id = "UseQQ", name = "Q: Takedown", value = true})
	Menu.ClearMode:MenuElement({id = "UseWW", name = "W: Pounce", value = true})
    Menu.ClearMode:MenuElement({id = "UseEE", name = "E: Swipe", value = true})
	Menu.ClearMode:MenuElement({id = "UseR", name = "R: Aspect of the Cougar", value = true})
	
	--KillSteal
	Menu:MenuElement({type = MENU, id = "KS", name = "KillSteal"})
	Menu.KS:MenuElement({id = "UseQ", name = "Q: Javelin Toss", value = true})
	Menu.KS:MenuElement({id = "UseR", name = "Auto switching Cougar/Human", value = true})	

	--Flee
	Menu:MenuElement({type = MENU, id = "Fl", name = "Flee"})
	Menu.Fl:MenuElement({id = "UseW", name = "W: Pounce", value = true, key = string.byte("A")})	
	
	--Drawings
	Menu:MenuElement({type = MENU, id = "DrawQ", name = "Drawings"})
	Menu.DrawQ:MenuElement({id = "Q", name = "Draw Q", value = true})

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q Human]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW1", name = "Hitchance[W Human]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1500, Speed = 1300, Collision = true, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1300, range = 1500, delay = 0.25, radius = 40, collision = {"minion"}, type = "linear"}	

	W1Data =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 1.0, Radius = 80, Range = 900, Speed = MathHuge, Collision = false
	}
	
	W1spellData = {speed = MathHuge, range = 900, delay = 1.0, radius = 80, collision = {nil}, type = "circular"}	
	
  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Ready(_Q) and Menu.DrawQ.Q:Value() then DrawCircle(myHero.pos, 1500, 1,  DrawColor(255, 000, 222, 255)) end
		if Menu.ComboMode.DrawDamage:Value() then
			for i, target in pairs(GetEnemyHeroes()) do
				local barPos = target.hpBar
				if not target.dead and target.pos2D.onScreen and barPos.onScreen and target.visible then
					local QDamage = (Ready(_Q) and Qdmg(target) or 0)
					local WDamage = (Ready(_W) and getdmg("W", target, myHero) or 0)
					local EDamage = (Ready(_E) and getdmg("E", target, myHero) or 0)
					local damage = QDamage + WDamage + EDamage
					if damage > target.health then
						DrawText("killable", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
						
					else
						local percentHealthAfterDamage = math.max(0, target.health - damage) / target.maxHealth
						local xPosEnd = barPos.x + barXOffset + barWidth * target.health/target.maxHealth
						local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
						Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, DrawColor(0xFF00FF00))
					end
				end
			end	
		end
	end)
end

function Qdmg(target)
    local qLvl = myHero:GetSpellData(_Q).level
	local result = 55 + 15 * qLvl + myHero.ap * 0.4
    
    local dist = myHero.pos:DistanceTo(target.pos)
    if dist > 525 then
        if dist > 1300 then
            dmg = result + (2 * result)
        else
            local num = (dist - 525) * 0.25 / 96.875
            dmg = result + (num * result)
        end
    end
    
    return dmg
end	

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Jungle()
	elseif Mode == "Flee" then
		Flee()
	end	
	KillSteal()	
end

LastR = GameTimer()

local function ForceCat()
    local RRTarget = GetTarget(1000)
	local count = 0
	for i = 0, GameHeroCount() do
		local hero = GameHero(i)
		if myHero.pos:DistanceTo(RRTarget.pos) < 700 then
			if hero == nil then return end
			local t = {}
 			for i = 0, hero.buffCount do
    			local buff = hero:GetBuff(i)
    			if buff.count > 0 then
    				TableInsert(t, buff)
    			end
  			end
  			if t ~= nil then
  				for i, buff in pairs(t) do
					if buff.name == "NidaleePassiveHunting" and buff.expireTime >= 2 then
						count = count +1
							return true
					end
				end
			end
		end
	end
	return false
end

function Flee()
    if Menu.Fl.UseW:Value() then 
		if myHero:GetSpellData(_W).name == "Pounce" and Ready(_W) then
			Control.CastSpell(HK_W, mousePos)
		
		elseif myHero:GetSpellData(_W).name == "Bushwhack" and Ready(_R) then
			Control.CastSpell(HK_R)
		end
	end
end	

function Combo()
local target = GetTarget(1600)
if target == nil then return end
	if IsValid(target) then	
		if Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1500 then 
			if Menu.ComboMode.UseQ:Value() and myHero.pos:DistanceTo(target.pos) >= Menu.Qset.Qmin:Value() then
				if myHero:GetSpellData(_Q).name == "JavelinToss" then
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
						local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1500, Speed = 1300, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
						QPrediction:GetPrediction(target, myHero)
						if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					end
				end
			end
		end
		
		if Ready(_R) and myHero.pos:DistanceTo(target.pos) < 800 then
			if Menu.ComboMode.UseR:Value() and myHero:GetSpellData(_Q).name == "JavelinToss" then
				if ForceCat() then
					Control.CastSpell(HK_R)
				end
			end
		end

		if Ready(_W) and myHero.pos:DistanceTo(target.pos) < 800 then 
			if Menu.ComboMode.UseW:Value() and myHero:GetSpellData(_W).name == "Bushwhack" then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, W1Data, myHero)
					if pred.Hitchance >= Menu.Pred.PredW1:Value()+1 then
						Control.CastSpell(HK_W, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, W1spellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW1:Value(), pred.HitChance) then
						Control.CastSpell(HK_W, pred.CastPos)
					end
				else
					local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 1.0, Radius = 80, Range = 900, Speed = MathHuge, Collision = false})
					WPrediction:GetPrediction(target, myHero)
					if WPrediction:CanHit(Menu.Pred.PredW1:Value() + 1) then
						Control.CastSpell(HK_W, WPrediction.CastPosition)
					end					
				end
			end
		end

		if Ready(_E) then 
			if Menu.ComboMode.UseE:Value() and myHero.health/myHero.maxHealth < .70 and myHero:GetSpellData(_E).name == "PrimalSurge" then
				Control.CastSpell(HK_E, myHero)
			end
		end

		if myHero.pos:DistanceTo(target.pos) < 700 and Ready(_W) then 
			if Menu.ComboMode.UseWW:Value() and myHero:GetSpellData(_W).name == "Pounce" then
				Control.CastSpell(HK_W, target.pos)
			end
		end

		if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 400 then 
			if Menu.ComboMode.UseQQ:Value() then
				if myHero:GetSpellData(_Q).name == "Takedown" then
					Control.CastSpell(HK_Q)
				end
			end
		end

		if myHero.pos:DistanceTo(target.pos) < 350 then 
			if Menu.ComboMode.UseEE:Value() and myHero:GetSpellData(_E).name == "Swipe" then
				if Ready(_E) then
					Control.CastSpell(HK_E, target)
				end
			end
		end

		if Ready(_R) and myHero.pos:DistanceTo(target.pos) < 140 then 
			if Menu.ComboMode.UseR:Value() and myHero:GetSpellData(_E).name == "Swipe" then
				if not Ready(_Q) and not Ready(_E) and not Ready(_W) then
					if Game.Timer() - LastR > 8 then
						Control.CastSpell(HK_R)
					end
				end
			end
		end

		if Ready(_R) then 
			if Menu.ComboMode.UseR:Value() and myHero:GetSpellData(_E).name == "Swipe" then
				if myHero.health/myHero.maxHealth < .50 and myHero.pos:DistanceTo(target.pos) > 700 then
					Control.CastSpell(HK_R)
				end
			end
		end
	end
end

function Harass()
local target = GetTarget(1600)
if target == nil then return end
	if IsValid(target) then   
		if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1500 and myHero.pos:DistanceTo(target.pos) >= Menu.Qset.Qmin:Value() then 
			if Menu.HarassMode.UseQ:Value() then
				if myHero:GetSpellData(_Q).name == "JavelinToss" then
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
						local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1500, Speed = 1300, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
						QPrediction:GetPrediction(target, myHero)
						if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					end
					
				elseif myHero:GetSpellData(_Q).name == "Takedown" and Ready(_R) then
					Control.CastSpell(HK_R)	
				end
			end
		end
	end
end

function Jungle()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
		if (minion.team == TEAM_JUNGLE or minion.team == TEAM_ENEMY) and IsValid(minion) then
			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 1500 then 
				if Menu.ClearMode.UseQ:Value() then
					if myHero:GetSpellData(_Q).name == "JavelinToss" then
						local newpos = myHero.pos:Extended(minion.pos,math.random(100,300))
						Control.CastSpell(HK_Q, newpos)
					end
				end
			end
			if myHero.pos:DistanceTo(minion.pos) < 800 then 
				if Menu.ClearMode.UseW:Value() and myHero:GetSpellData(_W).name == "Bushwhack" then
					if Ready(_W) then
						Control.CastSpell(HK_W, minion)
					end
				end
			end
			if myHero.pos:DistanceTo(minion.pos) < 800 and Ready(_R) then
				if Menu.ClearMode.UseR:Value() and myHero:GetSpellData(_Q).name == "JavelinToss" then
					if not Ready(_Q) and not Ready(_W) then
						if GameTimer() - LastR > 4 then
							Control.CastSpell(HK_R)
						end
					end
				end
			end
			if Ready(_E) then 
				if Menu.ClearMode.UseE:Value() and myHero.health/myHero.maxHealth < .70 and myHero:GetSpellData(_E).name == "PrimalSurge" then
					Control.CastSpell(HK_E, myHero)
				end
			end

			if myHero.pos:DistanceTo(minion.pos) < 700 then
				if Menu.ClearMode.UseWW:Value() and myHero:GetSpellData(_W).name == "Pounce" then
					if Ready(_W) then
						Control.CastSpell(HK_W, minion)
					end
				end
			end

			if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 275 then 
				if Menu.ClearMode.UseQQ:Value() then
					if myHero:GetSpellData(_Q).name == "Takedown" then
						Control.CastSpell(HK_Q)
					end
				end
			end

			if myHero.pos:DistanceTo(minion.pos) < 350 then 
				if Menu.ClearMode.UseEE:Value() and myHero:GetSpellData(_E).name == "Swipe" then
					if Ready(_E) then
						Control.CastSpell(HK_E, minion)
					end
				end
			end

			if Ready(_R) then 
				if Menu.ClearMode.UseR:Value() and myHero:GetSpellData(_E).name == "Swipe" then
					if not Ready(_Q) and not Ready(_E) and not Ready(_W) then
						if GameTimer() - LastR > 8 then
							Control.CastSpell(HK_R)
						end
					end
				end
			end

			if Ready(_R) and myHero.pos:DistanceTo(minion.pos) > 700 then 
				if Menu.ClearMode.UseR:Value() and myHero:GetSpellData(_E).name == "Swipe" then
					if myHero.health/myHero.maxHealth < .30 then
						Control.CastSpell(HK_R)
					end
				end
			end
		end
	end
end

function KillSteal()
local target = GetTarget(1600)
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1500 and myHero.pos:DistanceTo(target.pos) >= Menu.Qset.Qmin:Value() then 
		
		if Menu.KS.UseQ:Value() and Ready(_Q) then
			if Qdmg(target) >= target.health then
				
				if myHero:GetSpellData(_Q).name == "Takedown" and Menu.KS.UseR:Value() and Ready(_R) then
					Control.CastSpell(HK_R)
				end				
				
				if myHero:GetSpellData(_Q).name == "JavelinToss" then
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
						local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1500, Speed = 1300, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
						QPrediction:GetPrediction(target, myHero)
						if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					end
				end	
			end	
		end
	end	
end

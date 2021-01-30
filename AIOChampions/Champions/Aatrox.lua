
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
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
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

function LoadScript()	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Menu.Combo:MenuElement({id = "QMode", name = "On = Edge / Off = Ignore Edge", key = string.byte("T"), value = true, toggle = true})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q1],[Q2],[Q3]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W] after Q1", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E] for gapclose Q2/Q3 edge range", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({id = "Hp", name = "[R] if Hp lower than -->", value = 50, min = 0, max = 100, identifier = "%"})	
	Menu.Combo:MenuElement({id = "Count", name = "[R] if target count bigger than -->", value = 2, min = 1, max = 5})		 			

	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear Settings"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true}) 	
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Q-pos helper", value = true})		
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear Settings"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "UseE", name = "[E] Q-pos helper", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q1]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Settings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q1/Q2/Q3] Edge CastRange", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "Text Pos Settings"})		
	Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 700, min = 0, max = 1500, step = 10})
	Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	

	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.6, Radius = 80, Range = 600, Speed = MathHuge, Collision = false
	}
	
	QspellData = {speed = MathHuge, range = 600, delay = 0.6, radius = 80, collision = {nil}, type = "linear"}

	WData =
	{
	Type = _G._G.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 825, Speed = 1800, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	WspellData = {speed = 1800, range = 825, delay = 0.25, radius = 80, collision = {"minion"}, type = "linear"}	
  	                                           											   
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()		
		if myHero.dead then return end
		DrawText("Q-Edge: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+10, DrawColor(255, 225, 255, 0))
		if Menu.Combo.QMode:Value() then
			DrawText("ON", 15, Menu.Drawing.XY.x:Value()+55, Menu.Drawing.XY.y:Value()+10, DrawColor(255, 0, 255, 0))
		else						
			DrawText("OFF", 15, Menu.Drawing.XY.x:Value()+55, Menu.Drawing.XY.y:Value()+10, DrawColor(255, 255, 0, 0))		
		end
		                                             
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			local target = GetTarget(1000)
			if target and IsValid(target) then
				if myHero:GetSpellData(_Q).name == "AatroxQ" then
					DrawCircle(target, 520, 1, DrawColor(225, 225, 0, 10))
				elseif myHero:GetSpellData(_Q).name == "AatroxQ2" then
					DrawCircle(target, 370, 1, DrawColor(225, 225, 0, 10))
				elseif myHero:GetSpellData(_Q).name == "AatroxQ3" then
					DrawCircle(target, 340, 1, DrawColor(225, 225, 0, 10))
				end
			end	
		end

		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 300, 1, DrawColor(225, 225, 125, 10))
		end
		
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 825, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

function Tick()			
	if MyHeroNotReady() then return end
	
	local Mode = GetMode()
	if Mode == "Combo" then	
		Combo()	
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end		
end
	 	
function Combo()
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then

		if Menu.Combo.UseQ:Value() and Ready(_Q) then 
			if Menu.Combo.QMode:Value() then
				if myHero:GetSpellData(_Q).name == "AatroxQ" then
					if myHero.pos:DistanceTo(target.pos) < 600 then
						QCast(target)
					end	
				elseif myHero:GetSpellData(_Q).name == "AatroxQ2" then
					if myHero.pos:DistanceTo(target.pos) < 450 and myHero.pos:DistanceTo(target.pos) > 370 then
						Control.CastSpell(HK_Q, target.pos)
					else
						 if Menu.Combo.UseE:Value() and Ready(_E) then
							if myHero.pos:DistanceTo(target.pos) < 320 or myHero.pos:DistanceTo(target.pos) > 500 then
								local EPos = Vector(target.pos) + (Vector(myHero.pos) - Vector(target.pos)): Normalized() * 400
								Control.CastSpell(HK_E, EPos)
							end
						end	
					end	
				else
					if myHero:GetSpellData(_Q).name == "AatroxQ3" then
						if myHero.pos:DistanceTo(target.pos) < 340 then
							Control.CastSpell(HK_Q, target.pos)
						else
							 if Menu.Combo.UseE:Value() and Ready(_E) then
								if myHero.pos:DistanceTo(target.pos) < 640 then
									local EPos = Vector(target.pos) + (Vector(myHero.pos) - Vector(target.pos)): Normalized() * 300
									Control.CastSpell(HK_E, EPos)
								end
							end						
						end
					end	
				end	
			else
				if myHero:GetSpellData(_Q).name == "AatroxQ" then
					if myHero.pos:DistanceTo(target.pos) < 600 then
						QCast(target)
					else
						if Menu.Combo.UseE:Value() and Ready(_E) then
							if myHero.pos:DistanceTo(target.pos) < 800 then
								Control.CastSpell(HK_E, target.pos)
							end
						end							
					end	
				elseif myHero:GetSpellData(_Q).name == "AatroxQ2" then
					if myHero.pos:DistanceTo(target.pos) < 450 then
						Control.CastSpell(HK_Q, target.pos)
					else
						if Menu.Combo.UseE:Value() and Ready(_E) then
							if myHero.pos:DistanceTo(target.pos) < 700 then
								Control.CastSpell(HK_E, target.pos)
							end
						end	
					end	
				else
					if myHero:GetSpellData(_Q).name == "AatroxQ3" then
						if myHero.pos:DistanceTo(target.pos) < 340 then
							Control.CastSpell(HK_Q, target.pos)
						else
							if Menu.Combo.UseE:Value() and Ready(_E) then
								if myHero.pos:DistanceTo(target.pos) < 600 then
									Control.CastSpell(HK_E, target.pos)
								end
							end						
						end
					end	
				end			
			end	
		end

		if Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 800 and (myHero:GetSpellData(_Q).name ~= "AatroxQ" or not Ready(_Q)) then
			WCast(target)
		end	
		
		if Menu.Combo.UseR:Value() and Ready(_R) then
			if myHero.health/myHero.maxHealth <= Menu.Combo.Hp:Value()/100 then
				Control.CastSpell(HK_R)
			elseif GetEnemyCount(600, myHero.pos) >= Menu.Combo.Count:Value() then
				Control.CastSpell(HK_R)
			end
		end			
	end
end

function Clear()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
		if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) then
			if Menu.Clear.UseQ:Value() and Ready(_Q) then 
				if myHero:GetSpellData(_Q).name == "AatroxQ" then
					if myHero.pos:DistanceTo(minion.pos) < 600 then
						Control.CastSpell(HK_Q, minion.pos)
					end	
				elseif myHero:GetSpellData(_Q).name == "AatroxQ2" then
					if myHero.pos:DistanceTo(minion.pos) < 450 and myHero.pos:DistanceTo(minion.pos) > 370 then
						Control.CastSpell(HK_Q, minion.pos)
					else
						 if Menu.Clear.UseE:Value() and Ready(_E) then
							if myHero.pos:DistanceTo(minion.pos) < 320 or myHero.pos:DistanceTo(minion.pos) > 500 then
								local EPos = Vector(minion.pos) + (Vector(myHero.pos) - Vector(minion.pos)): Normalized() * 400
								Control.CastSpell(HK_E, EPos)
							end
						end	
					end	
				else
					if myHero:GetSpellData(_Q).name == "AatroxQ3" then
						if myHero.pos:DistanceTo(minion.pos) < 340 then
							Control.CastSpell(HK_Q, minion.pos)
						else
							 if Menu.Clear.UseE:Value() and Ready(_E) then
								if myHero.pos:DistanceTo(minion.pos) < 640 then
									local EPos = Vector(minion.pos) + (Vector(myHero.pos) - Vector(minion.pos)): Normalized() * 300
									Control.CastSpell(HK_E, EPos)
								end
							end						
						end
					end	
				end	
			end	
							  
			if Ready(_W) and Menu.Clear.UseW:Value() then
				Control.CastSpell(HK_W, minion.pos)    
			end
		end	
	end	
end

function JungleClear()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
		if minion.team == TEAM_JUNGLE and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) then
			if Menu.JClear.UseQ:Value() and Ready(_Q) then 
				if myHero:GetSpellData(_Q).name == "AatroxQ" then
					if myHero.pos:DistanceTo(minion.pos) < 600 then
						Control.CastSpell(HK_Q, minion.pos)
					end	
				elseif myHero:GetSpellData(_Q).name == "AatroxQ2" then
					if myHero.pos:DistanceTo(minion.pos) < 450 and myHero.pos:DistanceTo(minion.pos) > 370 then
						Control.CastSpell(HK_Q, minion.pos)
					else
						 if Menu.JClear.UseE:Value() and Ready(_E) then
							if myHero.pos:DistanceTo(minion.pos) < 320 or myHero.pos:DistanceTo(minion.pos) > 500 then
								local EPos = Vector(minion.pos) + (Vector(myHero.pos) - Vector(minion.pos)): Normalized() * 400
								Control.CastSpell(HK_E, EPos)
							end
						end	
					end	
				else
					if myHero:GetSpellData(_Q).name == "AatroxQ3" then
						if myHero.pos:DistanceTo(minion.pos) < 340 then
							Control.CastSpell(HK_Q, minion.pos)
						else
							 if Menu.JClear.UseE:Value() and Ready(_E) then
								if myHero.pos:DistanceTo(minion.pos) < 640 then
									local EPos = Vector(minion.pos) + (Vector(myHero.pos) - Vector(minion.pos)): Normalized() * 300
									Control.CastSpell(HK_E, EPos)
								end
							end						
						end
					end	
				end	
			end	
							  
			if Ready(_W) and Menu.JClear.UseW:Value() then
				Control.CastSpell(HK_W, minion.pos)    
			end
		end	
	end	
end

function QCast(unit)
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
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.6, Radius = 80, Range = 600, Speed = MathHuge, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then	
			Control.CastSpell(HK_Q, QPrediction.CastPosition)	
		end
	end
end

function WCast(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
			Control.CastSpell(HK_W, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
			Control.CastSpell(HK_W, pred.CastPos)
		end
	else
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 825, Speed = 1800, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value()+1) then
			Control.CastSpell(HK_W, WPrediction.CastPosition)
		end
	end
end

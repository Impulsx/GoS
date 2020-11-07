
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

function LoadScript()	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "Spirit", name = "Focus Spirit ?", value = true})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseW2", name = "[W] only if Tentacles in range", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "ERange", name = "Max [E] range", value = 700, min = 0, max = 900})	
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo.Ult:MenuElement({id = "UseRE", name = "[R] TargetCount", value = 2, min = 1, max = 5})
	Menu.Combo.Ult:MenuElement({id = "UseRE2", name = "Count Spirit with TargetCount", value = true})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "Spirit", name = "Focus Spirit ?", value = true})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "UseW2", name = "[W] only if Tentacles in range", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Harass:MenuElement({id = "ERange", name = "Max [E] range", value = 700, min = 0, max = 900})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] original Range ", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = (0.75+ping), Radius = 100, Range = 825, Speed = MathHuge, Collision = false
	}
	
	QspellData = {speed = MathHuge, range = 825, delay = (0.75+ping), radius = 100, collision = {nil}, type = "linear"}	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 50, Range = 900, Speed = 1900, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	EspellData = {speed = 1900, range = 900, delay = (0.25+ping), radius = 50, collision = {"minion"}, type = "linear"}		
  	                                           
											   
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 450, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 825, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

local FoundSpirit = false
local CastedE = false
local Spirit = {}
local Tentacles = {}
local TentNear = false

function Tick()
RemoveTent()

if FoundSpirit then
	RemoveSpirit()
end	
if CastedE then
	ScanSpirit()
end

for i = 0, myHero.buffCount do
	local buff = myHero:GetBuff(i)
	if buff and buff.name == "illaoitentaclespawncooldown" and buff.duration > 6 and buff.duration < 9 then
		CheckTent()
	end
end

if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()			
	end	
end

function CheckTent()	
	for i = 0, GameObjectCount() do
		local tent = GameObject(i)
		local NewTent = true
		if tent and myHero.pos:DistanceTo(tent.pos) < 1500 and tent.charName == "IllaoiMinion" then
			for i = 1, #Tentacles do
				if Tentacles[i].networkID == tent.networkID then
					NewTent = false
				end
			end				
			
			if NewTent then 
				if tent.charName == "IllaoiMinion" and myHero.pos:DistanceTo(tent.pos) < 1500 then
					--print("FoundTent")
					TableInsert(Tentacles, tent)
				end	
			end	
		end
	end	
end

function RemoveTent()
	for i = 1, #Tentacles do
		local Tent = Tentacles[i] 
		if Tent and myHero.pos:DistanceTo(Tent.pos) <= 1500 and (Tent.health < 1 or Tent.charName ~= "IllaoiMinion") then				
			TableRemove(Tentacles, i)
			--print("Removed")
		end	
	end
end

function ScanSpirit()
	if FoundSpirit then return end
	DelayAction(function()
		for i = 0, GameObjectCount() do
			local obj = GameObject(i)
			if obj and myHero.pos:DistanceTo(obj.pos) < 600 and obj.name == "Illaoi_Base_E_Spirit" then				
				--print("FoundSpirit")
				FoundSpirit = true
				CastedE = false
				TableInsert(Spirit, obj)
				return
			end
		end
	end,0.25)	
end

function RemoveSpirit()
	for i = 1, #Spirit do
		local Obj = Spirit[i] 
		if Obj and not Obj.visible then				
			TableRemove(Spirit, i)
			FoundSpirit = false
			--print("Removed")
		end
	end
end

local SpiritNear = false
function Combo()
	if Menu.Combo.Spirit:Value() and FoundSpirit then
		for i = 1, #Spirit do
			local Obj = Spirit[i]
			if Obj and myHero.pos:DistanceTo(Obj.pos) < 825 then
				SpiritNear = true
				
				if myHero.pos:DistanceTo(Obj.pos) <= 350 then
					--Control.Attack(Obj)
				end
				
				if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(Obj.pos) < 825 and Ready(_Q) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(Obj, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, Obj, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					else
						CastGGPred(_Q, Obj)
					end
				end
			   
				if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(Obj.pos) <= 450 and Ready(_W) then
					Control.CastSpell(HK_W)
					Control.Attack(Obj)
				end

				if Menu.Combo.Ult.UseR:Value() and Ready(_R) then
					local count = GetEnemyCount(450, myHero)
					if Menu.Combo.Ult.UseRE2:Value() then
						if myHero.pos:DistanceTo(Obj.pos) < 450 then
							if count+1 >= Menu.Combo.Ult.UseRE:Value() then
								Control.CastSpell(HK_R)
							end	
						else
							if count >= Menu.Combo.Ult.UseRE:Value() then
								Control.CastSpell(HK_R)
							end	
						end
					else
						if count >= Menu.Combo.Ult.UseRE:Value() then
							Control.CastSpell(HK_R)
						end						
					end	
				end
			else
				SpiritNear = false
			end
		end
	end	
	
	if (((Menu.Combo.Spirit:Value() and not FoundSpirit) or (Menu.Combo.Spirit:Value() and FoundSpirit and not SpiritNear)) or (not Menu.Combo.Spirit:Value())) then
		local target = GetTarget(900)
		if target == nil then return end
		if IsValid(target) then
		
			if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= Menu.Combo.ERange:Value() and Ready(_E) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						Control.CastSpell(HK_E, pred.CastPosition)
						CastedE = true
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						Control.CastSpell(HK_E, pred.CastPos)
						CastedE = true
					end
				else
					CastGGPred(_E, target)
				end
			end	
			
			if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 825 and Ready(_Q) then
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
					CastGGPred(_Q, target)
				end
			end
		   
			if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 450 and Ready(_W) then
				if Menu.Combo.UseW2:Value() then
					for i = 1, #Tentacles do
						local Tent = Tentacles[i] 
						if Tent and target.pos:DistanceTo(Tent.pos) < 850 then					
							Control.CastSpell(HK_W)
							Control.Attack(target)
						end
					end	
				else
					Control.CastSpell(HK_W)
					Control.Attack(target)
				end	
			end

			if Menu.Combo.Ult.UseR:Value() and Ready(_R) then
				local count = GetEnemyCount(450, myHero)
				if count >= Menu.Combo.Ult.UseRE:Value() then
					Control.CastSpell(HK_R)
				end	
			end
		end
	end	
end

function Harass()
	if Menu.Harass.Spirit:Value() and FoundSpirit then
		for i = 1, #Spirit do
			local Obj = Spirit[i]
			if Obj and myHero.pos:DistanceTo(Obj.pos) < 825 then
				SpiritNear = true
				
				if myHero.pos:DistanceTo(Obj.pos) <= 350 then
					--Control.Attack(Obj)
				end
				
				if Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(Obj.pos) < 825 and Ready(_Q) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(Obj, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, Obj, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					else
						CastGGPred(_Q, Obj)
					end
				end
			   
				if Menu.Harass.UseW:Value() and myHero.pos:DistanceTo(Obj.pos) <= 450 and Ready(_W) then
					Control.CastSpell(HK_W)
					Control.Attack(Obj)
				end
			else
				SpiritNear = false
			end
		end
	end	
	
	if (((Menu.Harass.Spirit:Value() and not FoundSpirit) or (Menu.Harass.Spirit:Value() and FoundSpirit and not SpiritNear)) or (not Menu.Harass.Spirit:Value())) then
		local target = GetTarget(900)
		if target == nil then return end
		if IsValid(target) then
		
			if Menu.Harass.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= Menu.Harass.ERange:Value() and Ready(_E) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						Control.CastSpell(HK_E, pred.CastPosition)
						CastedE = true
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						Control.CastSpell(HK_E, pred.CastPos)
						CastedE = true
					end
				else
					CastGGPred(_E, target)
				end
			end	
			
			if Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 825 and Ready(_Q) then
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
					CastGGPred(_Q, target)
				end
			end
		   
			if Menu.Harass.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= 450 and Ready(_W) then
				if Menu.Harass.UseW2:Value() then
					for i = 1, #Tentacles do
						local Tent = Tentacles[i] 
						if Tent and target.pos:DistanceTo(Tent.pos) < 850 then					
							Control.CastSpell(HK_W)
							Control.Attack(target)
						end
					end	
				else
					Control.CastSpell(HK_W)
					Control.Attack(target)
				end	
			end
		end
	end	
end	

function CastGGPred(spell, unit)
	if spell == _Q then
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.75+ping), Radius = 100, Range = 825, Speed = MathHuge, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end	
	
	else
	
		if spell == _E then
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = (0.25+ping), Radius = 50, Range = 900, Speed = 1900, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
			EPrediction:GetPrediction(unit, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
				Control.CastSpell(HK_E, EPrediction.CastPosition)
				CastedE = true
			end	
		end	
	end
end


local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function VectorWay(A,B)
	WayX = B.x - A.x
	WayY = B.y - A.y
	WayZ = B.z - A.z
	return Vector(WayX, WayY, WayZ)
end

require "MapPositionGOS"

-- Most stuff reworked from Internal Script by Noddy --
function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.05"}})
	
	--UltMenu  
	Menu:MenuElement({type = MENU, id = "Ult", name = "Semi Ult"})
	Menu.Ult:MenuElement({id = "Change", name = "Which Range?", value = 1, drop = {"Ult + Doante Range (1800)", "Only Ult Range (1000)"}})	
	Menu.Ult:MenuElement({id = "Key", name = "Semi manual Ult Key", key = string.byte("T")})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Mode"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseQ2", name = "Only [Q] if can donate Terrain", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Mouse Position", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.Combo:MenuElement({id = "Burst", name = "Burst Combo", value = true})
	Menu.Combo:MenuElement({id = "BurstE", name = "Burst [E] helper (Gapclose)", value = true})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Mode"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseQ2", name = "Only [Q] if can donate Terrain", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana [Q]", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear Mode"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana [Q]", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana [Q]", value = 40, min = 0, max = 100, identifier = "%"})  		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 20, Range = 925, Speed = 2000, Collision = false
	}
	
	QspellData = {speed = 2000, range = 925, delay = 0.25, radius = 20, collision = {nil}, type = "linear"}	
	
	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.15, Radius = 110, Range = 950, Speed = 1500, Collision = false
	}
	
	WspellData = {speed = 1500, range = 950, delay = 0.15, radius = 110, collision = {nil}, type = "circular"}	

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 1000, Speed = 2100, Collision = false
	}
	
	RspellData = {speed = 2100, range = 1000, delay = 0.25, radius = 50, collision = {nil}, type = "linear"}

	R2Data =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 1800, Speed = 2100, Collision = false
	}
	
	R2spellData = {speed = 2100, range = 1800, delay = 0.25, radius = 100, collision = {nil}, type = "linear"}	
			
  	                                          
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			DrawCircle(myHero, 925, 1, DrawColor(225, 0, 225, 85))
		end
		
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			DrawCircle(myHero, 950, 1, DrawColor(225, 225, 188, 0))
		end
		
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			DrawCircle(myHero, 425, 1, DrawColor(225, 225, 188, 0))
		end		
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			DrawCircle(myHero, 1000, 1, DrawColor(225, 225, 0, 10))
		end		
	end)

		
end

local DPS = 0
function Tick()
CheckDmg()
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
	 
	if Menu.Ult.Key:Value() then
		SemiUlt()
	end
end

local Qpred = false
local qDMG = 0
local rDMG = 0
function CheckDmg()
	local target = GetTarget(1800)
	if target and IsValid(target) then
		if Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Qpred = true
				else
					Qpred = false
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Qpred = true
				else
					Qpred = false					
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 1.4, Radius = 20, Range = 925, Speed = MathHuge, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Qpred = true
				else
					Qpred = false					
				end
			end		

			if QPred then				
				
				local checkPos1 = myHero.pos + ((VectorWay(myHero.pos, target.pos))/GetDistance(myHero.pos,target.pos))*930
				local checkPos2 = myHero.pos + ((VectorWay(myHero.pos, target.pos))/GetDistance(myHero.pos,target.pos))*(925/1.2)
				local checkPos3 = myHero.pos + ((VectorWay(myHero.pos, target.pos))/GetDistance(myHero.pos,target.pos))*(925/1.5)
				local checkPos4 = myHero.pos + ((VectorWay(myHero.pos, target.pos))/GetDistance(myHero.pos,target.pos))*(925/2)
				local checkPos5 = myHero.pos + ((VectorWay(myHero.pos, target.pos))/GetDistance(myHero.pos,target.pos))*(925/3)
				local checkPos6 = myHero.pos + ((VectorWay(myHero.pos, target.pos))/GetDistance(myHero.pos,target.pos))*(925/6)

				if MapPosition:inWall(checkPos6) == true then 
					if GetDistance(myHero.pos, checkPos6) > GetDistance(myHero.pos, target.pos) then
						qDMG = getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2)
					end
				elseif MapPosition:inWall(checkPos5) == true then 
					if GetDistance(myHero.pos, checkPos5) > GetDistance(myHero.pos, target.pos) then
						qDMG = getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2)
					end
				elseif MapPosition:inWall(checkPos4) == true then 
					if GetDistance(myHero.pos, checkPos4) > GetDistance(myHero.pos, target.pos) then
						qDMG = getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2)
					end
				elseif MapPosition:inWall(checkPos3) == true then 
					if GetDistance(myHero.pos, checkPos3) > GetDistance(myHero.pos, target.pos) then
						qDMG = getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2)
					end
				elseif MapPosition:inWall(checkPos2) == true then
					if GetDistance(myHero.pos, checkPos2) > GetDistance(myHero.pos, target.pos) then
						qDMG = getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2)
					end
				elseif MapPosition:inWall(checkPos1) == true then 
					if GetDistance(myHero.pos, checkPos1) > GetDistance(myHero.pos, target.pos) then
						qDMG = getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2)
					end
				else
					qDMG = getdmg("Q", target, myHero, 1)
				end
				
			else 
				qDMG = 0				
			end
		else
			Qpred = false
			qDMG = 0
		end

		if Ready(_R) then
			rDMG = getdmg("R", target, myHero, 1)
		else 
			rDMG = 0
		end

		DPS = qDMG + rDMG
	end	
end

function AAReset(unit)
	if not HasBuff(myHero, "gravesbasicattackammo2") and not HasBuff(myHero, "gravesbasicattackammo1") and Control.CastSpell(HK_E, unit) then
		if _G.SDK and _G.SDK.Orbwalker then
			_G.SDK.Orbwalker:__OnAutoAttackReset()
		elseif _G.PremiumOrbwalker then
			_G.PremiumOrbwalker:ResetAutoAttack()
		end		
	end
end

function SemiUlt()
	if Menu.Ult.Change:Value() == 1 then
		local target = GetTarget(1750)
		if target == nil then return end
		
		if Ready(_R) and IsValid(target) then
			if myHero.pos:DistanceTo(target.pos) > 1000 then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, R2Data, myHero)
					if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
						Control.CastSpell(HK_R, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, R2spellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
						Control.CastSpell(HK_R, pred.CastPos)
					end
				else
					local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 1800, Speed = 2100, Collision = false})
					RPrediction:GetPrediction(target, myHero)
					if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
						Control.CastSpell(HK_R, RPrediction.CastPosition)
					end	
				end
			else				
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
					local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 1000, Speed = 2100, Collision = false})
					RPrediction:GetPrediction(target, myHero)
					if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
						Control.CastSpell(HK_R, RPrediction.CastPosition)
					end	
				end
			end	
		end
	else
		local target = GetTarget(950)
		if target == nil then return end
		
		if Ready(_R) and IsValid(target) then				
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
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 1000, Speed = 2100, Collision = false})
				RPrediction:GetPrediction(target, myHero)
				if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
					Control.CastSpell(HK_R, RPrediction.CastPosition)
				end	
			end
		end	
	end	
end	

function Combo()
	local target = GetTarget(1800)
	if target == nil then return end
	
	if IsValid(target) then

		-- Burstcombo --
		if Ready(_Q) and Ready(_R) and Menu.Combo.Burst:Value() and myHero.pos:DistanceTo(target.pos) <= 1300 and target.health < DPS then
			if myHero.pos:DistanceTo(target.pos) <= 900 then
				if Menu.Pred.Change:Value() == 1 then
					local predq = GetGamsteronPrediction(target, QData, myHero)
					local predr = GetGamsteronPrediction(target, RData, myHero)
					if predq.Hitchance >= Menu.Pred.PredQ:Value()+1 and predr.Hitchance >= Menu.Pred.PredR:Value()+1 then
						if Control.CastSpell(HK_Q, predq.CastPosition) then	
							Control.CastSpell(HK_R, predr.CastPosition)	
						end			
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local predq = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					local predr = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
					if (predq.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), predq.HitChance)) and (predr.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), predr.HitChance)) then
						if Control.CastSpell(HK_Q, predq.CastPos) then	
							Control.CastSpell(HK_R, predr.CastPos)	
						end							
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 20, Range = 925, Speed = 2000, Collision = false})
					local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 1000, Speed = 2100, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					RPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) and RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then	
						if Control.CastSpell(HK_Q, QPrediction.CastPosition) then	
							Control.CastSpell(HK_R, RPrediction.CastPosition)	
						end				
					end
				end
			end	
			
			if myHero.pos:DistanceTo(target.pos) > 925 and Ready(_E) and Menu.Combo.BurstE:Value() then
				Control.CastSpell(HK_E, target.pos)
			end					
			
		else
			-- Normal Combo --
			if myHero.pos:DistanceTo(target.pos) <= 950 and Ready(_E) and Menu.Combo.UseE:Value() then
				AAReset(mousePos)
			end				
			
			if Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Combo.UseQ:Value() then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					
						local checkPos1 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*900
						local checkPos2 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/1.2)
						local checkPos3 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/1.5)
						local checkPos4 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/2)
						local checkPos5 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/3)
						local checkPos6 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/6)					
					
						if MapPosition:inWall(checkPos6) then 
							if GetDistance(myHero.pos, checkPos6) > GetDistance(myHero.pos, target.pos) then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						elseif MapPosition:inWall(checkPos5) then 
							if GetDistance(myHero.pos, checkPos5) > GetDistance(myHero.pos, target.pos) then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						elseif MapPosition:inWall(checkPos4) then 
							if GetDistance(myHero.pos, checkPos4) > GetDistance(myHero.pos, target.pos) then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						elseif MapPosition:inWall(checkPos3) then 
							if GetDistance(myHero.pos, checkPos3) > GetDistance(myHero.pos, target.pos) then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						elseif MapPosition:inWall(checkPos2) then
							if GetDistance(myHero.pos, checkPos2) > GetDistance(myHero.pos, target.pos) then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						elseif MapPosition:inWall(checkPos1) then 
							if GetDistance(myHero.pos, checkPos1) > GetDistance(myHero.pos, target.pos) then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end
						else
							if not Menu.Combo.UseQ2:Value() then
								Control.CastSpell(HK_Q, pred.CastPosition)
							end	
						end				
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then

						local checkPos1 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*900
						local checkPos2 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/1.2)
						local checkPos3 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/1.5)
						local checkPos4 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/2)
						local checkPos5 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/3)
						local checkPos6 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/6)						
						
						if MapPosition:inWall(checkPos6) then 
							if GetDistance(myHero.pos, checkPos6) > GetDistance(myHero.pos, pred.CastPos) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						elseif MapPosition:inWall(checkPos5) then 
							if GetDistance(myHero.pos, checkPos5) > GetDistance(myHero.pos, pred.CastPos) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						elseif MapPosition:inWall(checkPos4) then 
							if GetDistance(myHero.pos, checkPos4) > GetDistance(myHero.pos, pred.CastPos) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						elseif MapPosition:inWall(checkPos3) then 
							if GetDistance(myHero.pos, checkPos3) > GetDistance(myHero.pos, pred.CastPos) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						elseif MapPosition:inWall(checkPos2) then
							if GetDistance(myHero.pos, checkPos2) > GetDistance(myHero.pos, pred.CastPos) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						elseif MapPosition:inWall(checkPos1) then 
							if GetDistance(myHero.pos, checkPos1) > GetDistance(myHero.pos, pred.CastPos) then
								Control.CastSpell(HK_Q, pred.CastPos)
							end
						else
							if not Menu.Combo.UseQ2:Value() then
								Control.CastSpell(HK_Q, pred.CastPos)
							end	
						end
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 20, Range = 925, Speed = 2000, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then	
						
						local checkPos1 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*900
						local checkPos2 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/1.2)
						local checkPos3 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/1.5)
						local checkPos4 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/2)
						local checkPos5 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/3)
						local checkPos6 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/6)					

						if MapPosition:inWall(checkPos6) then 
							if GetDistance(myHero.pos, checkPos6) > GetDistance(myHero.pos, QPrediction.CastPosition) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end
						elseif MapPosition:inWall(checkPos5) then 
							if GetDistance(myHero.pos, checkPos5) > GetDistance(myHero.pos, QPrediction.CastPosition) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end
						elseif MapPosition:inWall(checkPos4) then 
							if GetDistance(myHero.pos, checkPos4) > GetDistance(myHero.pos, QPrediction.CastPosition) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end
						elseif MapPosition:inWall(checkPos3) then 
							if GetDistance(myHero.pos, checkPos3) > GetDistance(myHero.pos, QPrediction.CastPosition) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end
						elseif MapPosition:inWall(checkPos2) then
							if GetDistance(myHero.pos, checkPos2) > GetDistance(myHero.pos, QPrediction.CastPosition) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end
						elseif MapPosition:inWall(checkPos1) then 
							if GetDistance(myHero.pos, checkPos1) > GetDistance(myHero.pos, QPrediction.CastPosition) then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end
						else
							if not Menu.Combo.UseQ2:Value() then
								Control.CastSpell(HK_Q, QPrediction.CastPosition)
							end	
						end
					end
				end
			end	
		
			if Ready(_W) and myHero.pos:DistanceTo(target.pos) <= 950 and Menu.Combo.UseW:Value() then
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
					local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.15, Radius = 110, Range = 950, Speed = 1500, Collision = false})
					WPrediction:GetPrediction(target, myHero)
					if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
						Control.CastSpell(HK_W, WPrediction.CastPosition)
					end	
				end
			end
			
			--R 1
			if Ready(_R) and Menu.Combo.UseR:Value() and myHero.pos:DistanceTo(target.pos) <= 950 and target.health < getdmg("R", target, myHero, 1) then
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
					local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 1000, Speed = 2100, Collision = false})
					RPrediction:GetPrediction(target, myHero)
					if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
						Control.CastSpell(HK_R, RPrediction.CastPosition)
					end	
				end	
			end
			--R 2
			if Ready(_R) and Menu.Combo.UseR:Value() and myHero.pos:DistanceTo(target.pos) < 1800 and myHero.pos:DistanceTo(target.pos) > 1050 and target.health < getdmg("R", target, myHero, 2) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, R2Data, myHero)
					if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
						Control.CastSpell(HK_R, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, R2spellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
						Control.CastSpell(HK_R, pred.CastPos)
					end
				else
					local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 1800, Speed = 2100, Collision = false})
					RPrediction:GetPrediction(target, myHero)
					if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
						Control.CastSpell(HK_R, RPrediction.CastPosition)
					end	
				end	
			end
		end
	end	
end	

function Harass()
	local target = GetTarget(700)
	if target == nil then return end
	
	if IsValid(target) then

		if Ready(_Q) and Menu.Harass.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then

			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
				
					local checkPos1 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*900
					local checkPos2 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/1.2)
					local checkPos3 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/1.5)
					local checkPos4 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/2)
					local checkPos5 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/3)
					local checkPos6 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPosition))/GetDistance(myHero.pos,pred.CastPosition))*(900/6)					
				
					if MapPosition:inWall(checkPos6) then 
						if GetDistance(myHero.pos, checkPos6) > GetDistance(myHero.pos, target.pos) then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif MapPosition:inWall(checkPos5) then 
						if GetDistance(myHero.pos, checkPos5) > GetDistance(myHero.pos, target.pos) then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif MapPosition:inWall(checkPos4) then 
						if GetDistance(myHero.pos, checkPos4) > GetDistance(myHero.pos, target.pos) then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif MapPosition:inWall(checkPos3) then 
						if GetDistance(myHero.pos, checkPos3) > GetDistance(myHero.pos, target.pos) then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif MapPosition:inWall(checkPos2) then
						if GetDistance(myHero.pos, checkPos2) > GetDistance(myHero.pos, target.pos) then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif MapPosition:inWall(checkPos1) then 
						if GetDistance(myHero.pos, checkPos1) > GetDistance(myHero.pos, target.pos) then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					else
						if not Menu.Harass.UseQ2:Value() then
							Control.CastSpell(HK_Q, pred.CastPosition)
						end	
					end				
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then

					local checkPos1 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*900
					local checkPos2 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/1.2)
					local checkPos3 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/1.5)
					local checkPos4 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/2)
					local checkPos5 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/3)
					local checkPos6 = myHero.pos + ((VectorWay(myHero.pos, pred.CastPos))/GetDistance(myHero.pos,pred.CastPos))*(900/6)						
					
					if MapPosition:inWall(checkPos6) then 
						if GetDistance(myHero.pos, checkPos6) > GetDistance(myHero.pos, pred.CastPos) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					elseif MapPosition:inWall(checkPos5) then 
						if GetDistance(myHero.pos, checkPos5) > GetDistance(myHero.pos, pred.CastPos) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					elseif MapPosition:inWall(checkPos4) then 
						if GetDistance(myHero.pos, checkPos4) > GetDistance(myHero.pos, pred.CastPos) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					elseif MapPosition:inWall(checkPos3) then 
						if GetDistance(myHero.pos, checkPos3) > GetDistance(myHero.pos, pred.CastPos) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					elseif MapPosition:inWall(checkPos2) then
						if GetDistance(myHero.pos, checkPos2) > GetDistance(myHero.pos, pred.CastPos) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					elseif MapPosition:inWall(checkPos1) then 
						if GetDistance(myHero.pos, checkPos1) > GetDistance(myHero.pos, pred.CastPos) then
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					else
						if not Menu.Harass.UseQ2:Value() then
							Control.CastSpell(HK_Q, pred.CastPos)
						end	
					end
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 20, Range = 925, Speed = 2000, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then	
					
					local checkPos1 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*900
					local checkPos2 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/1.2)
					local checkPos3 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/1.5)
					local checkPos4 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/2)
					local checkPos5 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/3)
					local checkPos6 = myHero.pos + ((VectorWay(myHero.pos, QPrediction.CastPosition))/GetDistance(myHero.pos,QPrediction.CastPosition))*(900/6)					

					if MapPosition:inWall(checkPos6) then 
						if GetDistance(myHero.pos, checkPos6) > GetDistance(myHero.pos, QPrediction.CastPosition) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					elseif MapPosition:inWall(checkPos5) then 
						if GetDistance(myHero.pos, checkPos5) > GetDistance(myHero.pos, QPrediction.CastPosition) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					elseif MapPosition:inWall(checkPos4) then 
						if GetDistance(myHero.pos, checkPos4) > GetDistance(myHero.pos, QPrediction.CastPosition) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					elseif MapPosition:inWall(checkPos3) then 
						if GetDistance(myHero.pos, checkPos3) > GetDistance(myHero.pos, QPrediction.CastPosition) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					elseif MapPosition:inWall(checkPos2) then
						if GetDistance(myHero.pos, checkPos2) > GetDistance(myHero.pos, QPrediction.CastPosition) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					elseif MapPosition:inWall(checkPos1) then 
						if GetDistance(myHero.pos, checkPos1) > GetDistance(myHero.pos, QPrediction.CastPosition) then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end
					else
						if not Menu.Harass.UseQ2:Value() then
							Control.CastSpell(HK_Q, QPrediction.CastPosition)
						end	
					end
				end
			end
		end
	end
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_ENEMY and IsValid(minion) then					
			
			if Ready(_Q) and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				if not MapPosition:intersectsWall(myHero.pos, minion.pos) then
					Control.CastSpell(HK_Q, minion.pos)	
				end		
			end	

			if myHero.pos:DistanceTo(minion.pos) <= myHero.range and Menu.Clear.UseE:Value() and Ready(_E) then					
				AAReset(mousePos)	
			end				
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_JUNGLE and IsValid(minion) then					
			
			if Ready(_Q) and Menu.JClear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
				if not MapPosition:intersectsWall(myHero.pos, minion.pos) then
					Control.CastSpell(HK_Q, minion.pos)	
				end	
			end	

			if myHero.pos:DistanceTo(minion.pos) <= myHero.range and Menu.JClear.UseE:Value() and Ready(_E) then					
				AAReset(mousePos)	
			end			
		end
	end    
end

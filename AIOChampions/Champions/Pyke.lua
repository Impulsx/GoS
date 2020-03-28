local function GetEnemyHeroes()
	return Enemies
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

local function QCastTime(unit)
	return ((myHero.pos:DistanceTo(unit.pos) - 400) / 140) / 10 (+ 0.5)
end

local function UltDamage()
	local LvL = myHero.levelData.lvl
	local Dmg1 = ({250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550})[LvL]
	local Dmg2 = 0.8 * myHero.bonusDamage + 1.5 * myHero.armorPen
	local RDmg = Dmg1 + Dmg2
	return RDmg
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "Auto[R] Kill", value = true})
	Menu.Combo:MenuElement({id = "Draw", name = "Draw Killable FullCombo[onScreen+Minimap]", value = true})	
	Menu.Combo:MenuElement({type = MENU, id = "W", name = "W Setting"})	
	Menu.Combo.W:MenuElement({name = " ", drop = {"If Enemy killable and range bigger than Q range"}})
	Menu.Combo.W:MenuElement({id = "UseW", name = "[W]", value = true})   

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [E] Range", value = false})
	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Collision = false, Delay = 0.25, Radius = 150, Range = 550, Speed = 1700
	}
	
	EspellData = {speed = 1700, range = 550, delay = 0.25, radius = 150, collision = {}, type = "linear"}	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1100, Speed = 2000, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
	}
	
	QspellData = {speed = 2000, range = 1100, delay = 0.25, radius = 70, collision = {"minion"}, type = "linear"}	
  	 
	RData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.75, Radius = 250, Range = 750, Speed = MathHuge
	}
	
	RspellData = {speed = MathHuge, range = 750, delay = 0.75, radius = 250, collision = {}, type = "circular"}
	 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	elseif _G.PremiumOrbwalker then
		Orb = 5		
	end	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 750, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1100, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 550, 1, DrawColor(225, 225, 125, 10))
		end
		
		for i, target in pairs(GetEnemyHeroes()) do	
			if Menu.Combo.Draw:Value() and myHero.pos:DistanceTo(target.pos) <= 10000 and IsValid(target) then
			local RDmg = UltDamage()
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local FullDmg = (RDmg + QDmg + EDmg)
			local hp = target.health	
				if Ready(_R) and Ready(_Q) and Ready(_E) and FullDmg > hp then
					DrawText("Kill", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
					DrawText("Kill", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))
				end	
			end
		end		
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()		
	end
	Ult()	
end
	
function Ult()
local target = GetTarget(800)
if target == nil or HasBuff(target, "buffname") then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < 750 then
        local RDmg = UltDamage()
		if Menu.Combo.UseR:Value() and Ready(_R) and RDmg >= target.health then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, RData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					ControlCastSpell(HK_R, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					ControlCastSpell(HK_R, pred.CastPos)
				end	
			end
        end
	end
end

function Combo()
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target) then
		local ReadyCombo = myHero:GetSpellData(HK_Q).level > 0 and myHero:GetSpellData(HK_E).level > 0 and myHero:GetSpellData(HK_R).level > 0
		
		if ReadyCombo then
			local RDmg = UltDamage()
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local FullDmg = (RDmg + QDmg + EDmg)		
			if FullDmg >= target.health then
	
				if Menu.Combo.W.UseW:Value() and myHero.pos:DistanceTo(target.pos) > 1100 and Ready(_W) then
					ControlCastSpell(HK_W)
				end				
				
				if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1000 then
					local Time = QCastTime(target)
					if myHero.pos:DistanceTo(target.pos) > 400 then
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(target, QData, myHero)
							if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
								Control.SetCursorPos(pred.CastPosition)
								Control.KeyDown(HK_Q)
								if myHero.pos:DistanceTo(target.pos) > 1000 then return end
								DelayAction(function()
								Control.KeyUp(HK_Q)
								end, Time)
							end
						else
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
								Control.SetCursorPos(pred.CastPos)
								Control.KeyDown(HK_Q)
								if myHero.pos:DistanceTo(target.pos) > 1000 then return end
								DelayAction(function()
								Control.KeyUp(HK_Q)
								end, Time)																
							end	
						end	
					else
						ControlCastSpell(HK_Q, target.pos)
					end	
				end
			end

			if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 550 and Ready(_E) and HasBuff(target, "buffname") then
				ControlCastSpell(HK_E, target.pos)
			end	

		else

			if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1000 then
				local Time = QCastTime(target)
				if myHero.pos:DistanceTo(target.pos) > 400 then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							Control.SetCursorPos(pred.CastPosition)
							Control.KeyDown(HK_Q)
							if myHero.pos:DistanceTo(target.pos) > 1000 then return end
							DelayAction(function()
							Control.KeyUp(HK_Q)
							end, Time)
						end
					else
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							Control.SetCursorPos(pred.CastPos)
							Control.KeyDown(HK_Q)
							if myHero.pos:DistanceTo(target.pos) > 1000 then return end
							DelayAction(function()
							Control.KeyUp(HK_Q)
							end, Time)																
						end	
					end	
				else
					ControlCastSpell(HK_Q, target.pos)
				end

				if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 450 and Ready(_E) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, EData, myHero)
						if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
							local castPos = myHero.pos + (pred.CastPosition-myHero.pos):Normalized() * 550
							ControlCastSpell(HK_E, castPos)						
						end
					else
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
							local castPos = myHero.pos + (pred.CastPos-myHero.pos):Normalized() * 550
							ControlCastSpell(HK_E, castPos)
						end	
					end
				end					
			end			
		end
	end
end


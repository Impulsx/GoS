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
  return (((myHero.pos:DistanceTo(unit) - 400) / 140) / 10) + 0.75
end

local function UltDamage()
  local LvL = myHero.levelData.lvl
  local Dmg1 = ({250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550})[LvL]
  local Dmg2 = 0.8 * myHero.bonusDamage + 1.5 * myHero.armorPen
  local RDmg = nil

  if Dmg1 ~= nill then
    RDmg = Dmg1 + Dmg2
  else
    RDmg = Dmg2
  end
  return RDmg
end

local startR = 0
local RTarget = nil

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.05"}})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "QRange", name = "Use[Q] if range bigger than -->", value = 300, min = 0, max = 1100, step = 10})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R] Kill", value = true})
	Menu.Combo:MenuElement({id = "Draw", name = "Draw Killable FullCombo[onScreen+Minimap]", value = true})	
	Menu.Combo:MenuElement({type = MENU, id = "W", name = "W Setting"})	
	Menu.Combo.W:MenuElement({id = "UseW", name = "[W]", value = true}) 
	Menu.Combo.W:MenuElement({id = "WRange", name = "Use[W] if range bigger than -->", value = 600, min = 0, max = 1000, step = 10})

    --HarassMenu
    Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
    Menu.Harass:MenuElement({id = "QRange", name = "Use[Q] if range bigger than -->", value = 300, min = 0, max = 1100, step = 10})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Collision = false, Delay = 0.28, Radius = 60, Range = 550, Speed = 500
	}
	
	EspellData = {speed = 500, range = 550, delay = 0.28, radius = 60, collision = {nil}, type = "linear"}	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 1000, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1700, range = 1000, delay = 0.25, radius = 55, collision = {"minion"}, type = "linear"}	
  	 
	RData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.5, Radius = 250, Range = 750, Speed = 1000
	}
	
	RspellData = {speed = 1000, range = 750, delay = 0.5, radius = 250, collision = {nil}, type = "circular"}
	 
	 
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
			if Menu.Combo.Draw:Value() and myHero.pos:DistanceTo(target.pos) <= 5000 and IsValid(target) and Ready(_R) and Ready(_Q) and Ready(_E) then
			local RDmg = (Ready(_R) and UltDamage() or 0)
			local QDmg = (Ready(_Q) and getdmg("Q", target, myHero) or 0)
			local EDmg = (Ready(_E) and getdmg("E", target, myHero) or 0)
			local FullDmg = (RDmg + QDmg + EDmg)
			local hp = target.health	
				if FullDmg > hp then
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
		Ult()
	elseif Mode == "Harass" then
		Harass()		
	end
end

function Ult()
local target = GetTarget(800)
if target == nil then return end
	local buff1 = HasBuff(target, "PykeQMelee")
	local buff2 = HasBuff(myHero, "PykeQ")
	if not buff1 and not buff2 and Menu.Combo.UseR:Value() and Ready(_R) and IsValid(target) and myHero.pos:DistanceTo(target.pos) < 750 then
        local RDmg = UltDamage()
		if RDmg >= target.health then
			if GameTimer() - startR < 2 and RTarget == target then return end
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, RData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then					 
					startR = GameTimer()
					RTarget = target					
					Control.CastSpell(HK_R, pred.CastPosition)
					return
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					startR = GameTimer()
					RTarget = target
					Control.CastSpell(HK_R, pred.CastPos)
					return
				end
			else
				CastRGGPred(target)
			end
        end
	end
end

function Combo()
local target = GetTarget(1050)
if target == nil then return end
	if IsValid(target) then	
	
		if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) >= Menu.Combo.QRange:Value() and myHero.pos:DistanceTo(target.pos) < 1100 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then													
					local Time = QCastTime(pred.CastPosition)
					Control.KeyDown(HK_Q)
					DelayAction(function()
						SetAttack(false)
						SetMovement(false)
						Control.SetCursorPos(target.pos) 
						Control.KeyUp(HK_Q) 
						SetAttack(true)
						SetMovement(true)						
					end, Time)					
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					local Time = QCastTime(pred.CastPos)
					Control.KeyDown(HK_Q)
					DelayAction(function()
						SetAttack(false)
						SetMovement(false)					
						Control.SetCursorPos(target.pos) 
						Control.KeyUp(HK_Q) 
						SetAttack(true)
						SetMovement(true)						
					end, Time)
				end	
			else
				CastQGGPred(target)				
			end	
		end	
		
		if (myHero.activeSpell.valid and myHero.activeSpell.name == "PykeQ") then return end		
			
		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) > 100 and myHero.pos:DistanceTo(target.pos) <= 400 and Ready(_E) then
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
				CastEGGPred(target)				
			end
		end
			
		if Menu.Combo.W.UseW:Value() and myHero.pos:DistanceTo(target.pos) > Menu.Combo.W.WRange:Value() and Ready(_W) then
			Control.CastSpell(HK_W)
		end				
	end
end

function Harass()
local target = GetTarget(1050)
if target == nil then return end
	if IsValid(target) then
	
		if Menu.Harass.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) >= Menu.Harass.QRange:Value() and myHero.pos:DistanceTo(target.pos) < 1100 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then													
					local Time = QCastTime(pred.CastPosition)
					Control.KeyDown(HK_Q)
					DelayAction(function()
						SetAttack(false)
						SetMovement(false)					
						Control.SetCursorPos(target.pos) 
						Control.KeyUp(HK_Q) 
						SetAttack(true)
						SetMovement(true)						
					end, Time)					
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					local Time = QCastTime(pred.CastPos)
					Control.KeyDown(HK_Q)
					DelayAction(function()
						SetAttack(false)
						SetMovement(false)					
						Control.SetCursorPos(target.pos) 
						Control.KeyUp(HK_Q)
						SetAttack(true)
						SetMovement(true)						
					end, Time)
				end	
			else
				CastQGGPred(target)				
			end	
		end
	end
end

function CastQGGPred(unit)
	local QPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 55, Range = 1000, Speed = 1700, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
	QPrediction:GetPrediction(unit, myHero)
	if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
		local Time = QCastTime(QPrediction.CastPosition)
		Control.KeyDown(HK_Q)
		DelayAction(function()
			SetAttack(false)
			SetMovement(false)
			Control.SetCursorPos(unit.pos) 
			Control.KeyUp(HK_Q)
			SetAttack(true)
			SetMovement(true)			
		end, Time)
	end	
end	

function CastEGGPred(unit)
	local EPrediction = GGPrediction:SpellPrediction({Delay = 0.25, Radius = 60, Range = 550, Speed = 500, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
	EPrediction:GetPrediction(unit, myHero)
	if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
		Control.CastSpell(HK_E, EPrediction.CastPosition)
	end	
end	

function CastRGGPred(unit)
	local RPrediction = GGPrediction:SpellPrediction({Delay = 0.5, Radius = 250, Range = 750, Speed = 1000, Collision = false, Type = GGPrediction.SPELLTYPE_CIRCLE})
	RPrediction:GetPrediction(unit, myHero)
	if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
		startR = GameTimer()
		RTarget = target		
		Control.CastSpell(HK_R, RPrediction.CastPosition)
		return
	end	
end	

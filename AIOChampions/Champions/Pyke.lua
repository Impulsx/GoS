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

function UltDamage()
	local LvL = myHero.levelData.lvl
	local Dmg1 = ({250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550})[LvL]
	local Dmg2 = 0.8 * myHero.bonusDamage + 1.5 * myHero.armorPen
	local RDmg = Dmg1 + Dmg2
	return RDmg
end

function LoadScript()
	local isChannelingQ, startTime = false, 0
	local CastQReady = false
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "Auto[R] Kill", value = true})
	Menu.Combo:MenuElement({id = "Draw", name = "Draw Killable FullCombo[onScreen+Minimap]", value = true})	
	Menu.Combo:MenuElement({type = MENU, id = "W", name = "W Setting"})	
	Menu.Combo.W:MenuElement({name = " ", drop = {"If Enemy killable and range bigger than X"}})
	Menu.Combo.W:MenuElement({id = "UseW", name = "[W]", value = true}) 
	Menu.Combo.W:MenuElement({id = "WRange", name = "Use[W] if range bigger than -->", value = 500, min = 0, max = 1000, step = 10})		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
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
	
	EspellData = {speed = 500, range = 550, delay = 0.28, radius = 60, collision = {}, type = "linear"}	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 1000, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
	}
	
	QspellData = {speed = 1700, range = 1000, delay = 0.25, radius = 55, collision = {"minion"}, type = "linear"}	
  	 
	RData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.5, Radius = 250, Range = 750, Speed = 1000
	}
	
	RspellData = {speed = 1000, range = 750, delay = 0.5, radius = 250, collision = {}, type = "circular"}
	 
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
			if Menu.Combo.Draw:Value() and myHero.pos:DistanceTo(target.pos) <= 10000 and IsValid(target) and Ready(_R) and Ready(_Q) and Ready(_E) then
			local RDmg = UltDamage()
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
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

local function GetWindingQRange(startTime)
	local t = GameTimer() - startTime - 0.5
	return t <= 0 and 400 or math.min(1100, 400 + 1400 * t)
end

function Tick()
if MyHeroNotReady() then return end
	if (myHero.activeSpell.valid and myHero.activeSpell.name == "PykeQ") then
		isChannelingQ = true
		startTime = GameTimer()
	elseif not Ready(_Q) then
		isChannelingQ = false
	end
	if isChannelingQ and Ready(_Q) then
		local range = GetWindingQRange(startTime)
		if range <= 1100 then
			CastQ()
		end
	end	

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()		
	end
	Ult()
end

function CastQ()
local target = GetTarget(1100)
if target == nil then return end
	if IsValid(target) then		
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then								
				--SetMovement(false)
				ControlCastSpell(HK_Q, pred.CastPosition)
				--SetMovement(true)
			end
		else
			local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				--SetMovement(false)
				ControlCastSpell(HK_Q, pred.CastPos)
				--SetMovement(true)
			end	
		end	
	end
end
	
function Ult()
local target = GetTarget(800)
if target == nil then return end
	local buff1 = HasBuff(target, "PykeQMelee")
	local buff2 = HasBuff(myHero, "PykeQ")
	local startR = 0
	if not buff1 and not buff2 and Menu.Combo.UseR:Value() and Ready(_R) and IsValid(target) and myHero.pos:DistanceTo(target.pos) < 750 then
        local RDmg = UltDamage()
		if RDmg >= target.health then
			if GameTimer() - startR < 2 then return end
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, RData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then					 
					ControlCastSpell(HK_R, pred.CastPosition)
					startR = GameTimer()
					return
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					ControlCastSpell(HK_R, pred.CastPos)
					startR = GameTimer()
					return
				end	
			end
        end
	end
end

function Combo()
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target) then
		
		if Ready(_R) and myHero.pos:DistanceTo(target.pos) < 750 and UltDamage() > target.health then return end
		if (myHero.activeSpell.valid and myHero.activeSpell.name == "PykeQ") then CastQReady = false return end	
	
		if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1100 then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then													
					CastQReady = Control.KeyDown(HK_Q)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					CastQReady = Control.KeyDown(HK_Q)					
				end
			end	
		end	
			
		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 300 and Ready(_E) and (Ready(_Q) and not CastQ) or not Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then	
					SetMovement(false)
					ControlCastSpell(HK_E, pred.CastPosition)
					SetMovement(true)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					SetMovement(false)
					ControlCastSpell(HK_E, pred.CastPos)
					SetMovement(true)
				end	
			end
		end
			
		if Menu.Combo.W.UseW:Value() and myHero.pos:DistanceTo(target.pos) > Menu.Combo.W.WRange:Value() and Ready(_W) then
			ControlCastSpell(HK_W)
		end				
	end
end


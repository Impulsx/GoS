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

local function DisableOrb()
	_G.SDK.Orbwalker:SetMovement(false)
	_G.SDK.Orbwalker:SetAttack(false)
end

local function EnableOrb()
	_G.SDK.Orbwalker:SetMovement(true)
	_G.SDK.Orbwalker:SetAttack(true)	
end

local spellcast = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastSpell(HK, pos, delay)
	if spellcast.state == 2 then return end
	local delay = delay or 0.25
	spellcast.state = 2
	DisableOrb()
	spellcast.mouse = mousePos
	DelayAction(function() 
		Control.SetCursorPos(pos) 
		Control.KeyDown(HK)
		Control.KeyUp(HK)
	end, 0.05) 
	
		DelayAction(function()
			Control.SetCursorPos(spellcast.mouse)
		end,0.25)
		
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.35)
	
end

function LoadScript() 

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})			
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E1]", value = true})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true}) 
	Menu.Clear:MenuElement({id = "Key", name = "ToggleKey Push or LastHit", key = string.byte("T"), toggle = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Energie to LaneClear", value = 30, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Energie to JungleClear", value = 30, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})				

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "TextPos LaneClear[Q]"})	
	Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 650, Speed = 3200, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
	}
	
	EspellData = {speed = 3200, range = 650, delay = 0.25, radius = 55, collision = {"minion"}, type = "linear"}	
  	                                           
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end	
		
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 500, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 250, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 650, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 675, 1, DrawColor(225, 225, 0, 10))
		end		

		DrawText("LaneClear[Q]: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+15, DrawColor(255, 225, 255, 0))
		if Menu.Clear.Key:Value() then
			DrawText("Push", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		else
			DrawText("LastHit", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Clear" then
		if Menu.Clear.Key:Value() then
			Push()
		else
			LastHit()
		end	
		JungleClear()
	elseif Mode == "Harass" then
		Harass()		
	end
	KillSteal()	
end

function Combo()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target) then

		if myHero.pos:DistanceTo(target.pos) < 825 and Menu.Combo.UseR:Value() and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliR" then
			ControlCastSpell(HK_R, target)	
		end	
				
		if myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			CastSpell(HK_Q, target.pos)	
		end

		if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Combo.UseE:Value() and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliE" then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					CastSpell(HK_E, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					CastSpell(HK_E, pred.CastPos)
				end	
			end	
		end	

		if myHero.pos:DistanceTo(target.pos) < 1500 and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") then
			ControlCastSpell(HK_E)		
		end	

		if myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseW:Value() and Ready(_W) then
			CastSpell(HK_W, target.pos)	
		end	

		if myHero.pos:DistanceTo(target.pos) < 750 and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliRb" then
			CastSpell(HK_R, target.pos)	
		end			
	end	
end	

function Harass()
local target = GetTarget(700)     	
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) < 500 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			CastSpell(HK_Q, target.pos)	
		end

		if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Harass.UseE:Value() and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliE" then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					CastSpell(HK_E, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					CastSpell(HK_E, pred.CastPos)
				end	
			end
		end				
	end	
end

function Push()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_ENEMY and IsValid(minion) and Menu.Clear.UseQ:Value() then
			if mana_ok and Ready(_Q) then	
				CastSpell(HK_Q, minion.pos)
			end
		end
	end
end

function LastHit()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_ENEMY and IsValid(minion) and Menu.Clear.UseQ:Value() then
			if mana_ok and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero)
			local Q2Dmg = (QDmg / 100) * 25
			local FullDmg = QDmg + Q2Dmg
				if myHero:GetSpellData(_Q).level <= 4 then
					if QDmg >= minion.health then
						CastSpell(HK_Q, minion.pos)
					end
				else
					if FullDmg >= minion.health then
						CastSpell(HK_Q, minion.pos)
					end
				end	
			end
		end
	end
end

function JungleClear()	
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_JUNGLE and IsValid(minion) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            if Menu.JClear.UseQ:Value() and mana_ok and Ready(_Q) then  
				CastSpell(HK_Q, minion.pos)
            end
        end
    end
end

function KillSteal()
local target = GetTarget(1500)     	
if target == nil then return end		
	if IsValid(target) then		
	local EDmg = getdmg("E", target, myHero)
	local E2Dmg = getdmg("E", target, myHero) * 2
	local QDmg = getdmg("Q", target, myHero)	
		
		if myHero.pos:DistanceTo(target.pos) < 1500 and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") then
			if EDmg >= target.health then
				ControlCastSpell(HK_E)	
			end
			if Ready(_Q) and (EDmg + QDmg) >= target.health then
				ControlCastSpell(HK_E)	
			end	
		end		
		
		if myHero.pos:DistanceTo(target.pos) < 500 and Ready(_Q) and Menu.ks.UseQ:Value() then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health then
				CastSpell(HK_Q, target.pos)
			end
			if Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") and (EDmg + QDmg) >= target.health then
				CastSpell(HK_Q, target.pos)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 650 and Ready(_E) and Menu.ks.UseE:Value() then
			if E2Dmg >= target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						CastSpell(HK_E, pred.CastPosition)
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						CastSpell(HK_E, pred.CastPos)
					end	
				end		
			end
			if Ready(_Q) and (E2Dmg + QDmg) >= target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						CastSpell(HK_E, pred.CastPosition)
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						CastSpell(HK_E, pred.CastPos)
					end	
				end		
			end			
		end
	end
end

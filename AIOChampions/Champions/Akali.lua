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

function LoadScript() 

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"TestVersion 0.01"}})			
		
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
		Draw.Circle(myHero, 500, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 250, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 650, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 675, 1, Draw.Color(225, 225, 0, 10))
		end		
		
		local textPos = myHero.pos:To2D()		
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end	
		Draw.Text("LaneClear[Q]: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+15, Draw.Color(255, 225, 255, 0))
		if Menu.Clear.Key:Value() then
			Draw.Text("Push", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, Draw.Color(255, 0, 255, 0))
		else
			Draw.Text("LastHit", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, Draw.Color(255, 0, 255, 0))
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
	Passive()
	KillSteal()	
end

local function Move(pos)
local Position = pos
Control.SetCursorPos(Position) 
Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
Control.mouse_event(MOUSEEVENTF_RIGHTUP)
end

function Passive()
local target = GetTarget(600)     	
if target == nil then return end
	if IsValid(target) then
			
		if myHero.pos:DistanceTo(target.pos) < 500 and HasBuff(target, "buffname") then
		local Range = 550 - myHero.pos:DistanceTo(target.pos)
		local MovePos = target.pos:Extended(myHero.pos, Range)	
			_G.SDK.Orbwalker:SetMovement(false)
			_G.SDK.Orbwalker:SetAttack(false)
			Move(MovePos)
			DelayAction(function()
			_G.SDK.Orbwalker:SetMovement(true)
			_G.SDK.Orbwalker:SetAttack(true)
			end,0.75)
		end			
	end	
end

function Combo()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target) then

		if myHero.pos:DistanceTo(target.pos) < 825 and Menu.Combo.UseR:Value() and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliR" then
			Control.CastSpell(HK_R, target)	
		end	
				
		if myHero.pos:DistanceTo(target.pos) < 620 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q, target.pos)	
		end

		if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Combo.UseE:Value() and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliE" then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
				Control.CastSpell(HK_E, pred.CastPosition)	
			end	
		end	

		if myHero.pos:DistanceTo(target.pos) < 1500 and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") then
			Control.CastSpell(HK_E)		
		end	

		if myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W)	
		end	

		if myHero.pos:DistanceTo(target.pos) < 750 and Ready(_R) and myHero:GetSpellData(_R).name == "AkaliRb" then
			Control.CastSpell(HK_R, target.pos)	
		end			
	end	
end	

function Harass()
local target = GetTarget(700)     	
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) < 620 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q, target.pos)	
		end

		if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Harass.UseE:Value() and Ready(_E) and myHero:GetSpellData(_E).name == "AkaliE" then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
				Control.CastSpell(HK_E, pred.CastPosition)	
			end	
		end				
	end	
end

function Push()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if myHero.pos:DistanceTo(minion.pos) <= 620 and minion.team == TEAM_ENEMY and IsValid(minion) and Menu.Clear.UseQ:Value() then
			if mana_ok and Ready(_Q) then	
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end
end

function LastHit()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if myHero.pos:DistanceTo(minion.pos) <= 620 and minion.team == TEAM_ENEMY and IsValid(minion) and Menu.Clear.UseQ:Value() then
			if mana_ok and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero)
			local Q2Dmg = (QDmg / 100) * 25
			local FullDmg = QDmg + Q2Dmg
				if myHero:GetSpellData(_Q).level <= 4 then
					if QDmg >= minion.health then
						Control.CastSpell(HK_Q, minion.pos)
					end
				else
					if FullDmg >= minion.health then
						Control.CastSpell(HK_Q, minion.pos)
					end
				end	
			end
		end
	end
end

function JungleClear()	
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if myHero.pos:DistanceTo(minion.pos) <= 620 and minion.team == TEAM_JUNGLE and IsValid(minion) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            if Menu.JClear.UseQ:Value() and mana_ok and Ready(_Q) then  
				Control.CastSpell(HK_Q, minion.pos)
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
				Control.CastSpell(HK_E)	
			end
			if Ready(_Q) and (EDmg + QDmg) >= target.health then
				Control.CastSpell(HK_E)	
			end	
		end		
		
		if myHero.pos:DistanceTo(target.pos) < 620 and Ready(_Q) and Menu.ks.UseQ:Value() then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health then
				Control.CastSpell(HK_Q, target.pos)
			end
			if Ready(_E) and myHero:GetSpellData(_E).name == "AkaliEb" and HasBuff(target, "AkaliEMis") and (EDmg + QDmg) >= target.health then
				Control.CastSpell(HK_Q, target.pos)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 650 and Ready(_E) and Menu.ks.UseE:Value() then
		local pred = GetGamsteronPrediction(target, EData, myHero)
			if E2Dmg >= target.health and pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
				Control.CastSpell(HK_E, pred.CastPosition)		
			end
			if Ready(_Q) and (E2Dmg + QDmg) >= target.health and pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then
				Control.CastSpell(HK_E, pred.CastPosition)		
			end			
		end
	end
end

function CastSpell(spell,pos,range,delay)
    local range = range or math.huge
    local delay = delay or 250
    local ticker = GetTickCount()

    if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
        castSpell.state = 1
        castSpell.mouse = mousePos
        castSpell.tick = ticker
    end
    if castSpell.state == 1 then
        if ticker - castSpell.tick < Game.Latency() then
            Control.SetCursorPos(pos)
            Control.KeyDown(spell)
            Control.KeyUp(spell)
            castSpell.casting = ticker + delay
            DelayAction(function()
                if castSpell.state == 1 then
                    Control.SetCursorPos(castSpell.mouse)
                    castSpell.state = 0
                end
            end,Game.Latency()/1000)
        end
        if ticker - castSpell.casting > Game.Latency() then
            Control.SetCursorPos(castSpell.mouse)
            castSpell.state = 0
        end
    end
end

function CastSpellStart(spell, pos)
	_G.SDK.Orbwalker:SetMovement(false)
	Control.CastSpell(spell, pos)
	_G.SDK.Orbwalker:SetMovement(true)
end	

function CastSpellMM(spell,pos,range,delay)
	local range = range or math.huge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x,castPosMM.y)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end
 
function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,Game.MinionCount() do
	local hero = Game.Minion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

function GetAngle(v1, v2)
	local vec1 = v1:Len()
	local vec2 = v2:Len()
	local Angle = math.abs(math.deg(math.acos((v1*v2)/(vec1*vec2))))
	if Angle < 60 then
		return true
	end
	return false
end

function UseDarkHarvest()
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff.name:lower():find("darkharvest") and buff.count > 0 then 
			return true
		end
	end
	return false
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})	
	
	--AutoW 
	Menu:MenuElement({type = MENU, id = "AutoW", name = "Stack Dark Harvest"})
	if UseDarkHarvest() then	
		Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W] HP Enemy is less 50%", value = true})
	else
		Menu.AutoW:MenuElement({name = " ", drop = {"Dark Harvest not equipped"}})	
	end
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"[Q]before 4th AAhit", "[Q]after 4th AAhit"}})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]marked Target", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({type = MENU, id = "Ulti", name = "Ult Setting"})
	Menu.Combo.Ulti:MenuElement({name = " ", drop = {"Hold Key Down [Result == StartUlt + AutoAim]"}})
	Menu.Combo.Ulti:MenuElement({id = "UseR", name = "Ult Activate Key", key = string.byte("T")})
	Menu.Combo.Ulti:MenuElement({id = "Draw", name = "Killable Text[onScreen+Minimap]", value = true})
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]Hit Minion+Enemy", value = 2, drop = {"Automatically", "HarassKey"}})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	Menu.Clear.Last:MenuElement({id = "UseW", name = "LastHit[W]Cannon[out of AA range]", value = 2, drop = {"Automatically", "ClearKey"}})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 3, min = 1, max = 6, step = 1}) 
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]if min 1 Minion killable", value = true})
	Menu.Clear:MenuElement({id = "UseQM", name = "Use[Q]min Minions arround killable Minion", value = 3, min = 1, max = 3, step = 1}) 
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	
	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.66, Radius = 40, Range = 3000, Speed = 5000, Collision = false
	}

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 3500, Speed = 5000, Collision = false
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
	
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 3500, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 750, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 3000, 1, Draw.Color(225, 225, 125, 10))
		end
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end	
		
		local target = GetTarget(20000)
		if target == nil then return end	
		if Menu.Combo.Ulti.Draw:Value() and IsValid(target) then
		local Dmg = getdmg("R", target, myHero, 1)
		local hp = (target.health)	
			if Ready(_R) and (5*Dmg) > hp then
				Draw.Text("Ult Kill", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
				Draw.Text("Ult Kill", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
			end	
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		HarassE()
		if Menu.Harass.UseQ:Value() ~= 1 then
			Harass()
		end	
	elseif Mode == "Clear" then
		Clear()
		if Menu.Clear.Last.UseW:Value() ~= 1 then
			LastHitW()
		end	
	end	
	if Menu.Harass.UseQ:Value() ~= 2 and Mode ~= "Combo" then
		Harass()
	end
	if Menu.Clear.Last.UseW:Value() ~= 2 and Mode ~= "Combo" then
		LastHitW()
	end	
	if Menu.Combo.Ulti.UseR:Value() then
		StartR()
	end	

	KillSteal()
	if Menu.AutoW.UseW ~= nil and Menu.AutoW.UseW:Value() then
	AutoW()
	end
end

function StartR()
local target = GetTarget(3500)     	
if target == nil then return end
	if myHero:GetSpellData(_R).name == "JhinR" and myHero.pos:DistanceTo(target.pos) <= 3500 and IsValid(target) and Ready(_R) then
		if target.pos:To2D().onScreen then
			CastSpell(HK_R, target.pos, 3500)
        else
			local castPos = myHero.pos:Extended(target.pos, 1000)    
			Control.CastSpell(HK_R, castPos)
                            
        end
		
	end
	
    if myHero:GetSpellData(_R).name == "JhinRShot" and myHero.pos:DistanceTo(target.pos) <= 3500 then
		CastR(target)
		
	end	
end

function DarkHarvestReady()
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff.name:lower():find("darkharvestcooldown") and buff.count > 0 then 
			return true
		end
	end
	return false
end

function IsCastingAA(AAName)
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == AAName then
		return true
	end
	return false	
end

function AutoW()
	local target = GetTarget(3000)     	
	if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) then
		if Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 3000 and myHero.pos:DistanceTo(target.pos) > 600 and target.health/target.maxHealth < 0.5 and not DarkHarvestReady() then
				CastW(target)
			end
		end
	end
end
	
function Combo()
local target = GetTarget(3000)     	
if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) then
			
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
			if Menu.Combo.UseQ:Value() ~= 1 then
				if IsCastingAA("JhinPassiveAttack") then
					DelayAction(function()
					Control.CastSpell(HK_Q, target)
					end,Game.Latency()/100)
				end
			else 
				if IsCastingAA("JhinBasicAttack3") then
					DelayAction(function()
						Control.CastSpell(HK_Q, target)
					end,Game.Latency()/100)
				end
			end	
		end
		
		if Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 3000 and HasBuff(target, "jhinespotteddebuff") then					
				CastW(target)
				
			end
		end

		if Ready(_E) and Game.CanUseSpell(_E) == 0 and Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 750 then
			CastSpellStart(HK_E, target.pos)
        end		
	end	
end	

function Harass()
local target = GetTarget(1000)
if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
			if myHero.pos:DistanceTo(minion.pos) <= 550 and minion.team == TEAM_ENEMY and IsValid(minion) and Ready(_Q) then
			local QDmg = getdmg("Q", minion, myHero)
			local count = GetMinionCount(400, minion)
				if QDmg >= minion.health and target.pos:DistanceTo(minion.pos) <= 400 and count <= 3 then
					Control.CastSpell(HK_Q, minion)
				end	
			end
		end	
	end
end

function HarassE()
local target = GetTarget(800)
if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if Ready(_E) and Game.CanUseSpell(_E) == 0 and Menu.Harass.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 750 then
			CastSpellStart(HK_E, target.pos)
        end		
	end
end

function Clear()
    if myHero:GetSpellData(_R).name == "JhinRShot" then return end
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 800 and minion.team == TEAM_ENEMY and IsValid(minion) then
            
            
			if Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 550 and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero)
				local count = GetMinionCount(400, minion)
				if QDmg >= minion.health and count >= Menu.Clear.UseQM:Value() then
					Control.CastSpell(HK_Q, minion)
				end	
            end
            local count = GetMinionCount(260, minion)          
			if Ready(_E) and Game.CanUseSpell(_E) == 0 and Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 750 and count >= Menu.Clear.UseEM:Value() then
				CastSpellStart(HK_E, minion.pos)
                    
            end
        end
    end
end

function LastHitW()
	if myHero:GetSpellData(_R).name == "JhinRShot" then return end
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 3000 and minion.team == TEAM_ENEMY and minion.charName == "SRU_ChaosMinionSiege" and IsValid(minion) then
			local WDmg = getdmg("W", minion, myHero, 2)
			if myHero.pos:DistanceTo(minion.pos) > 550 and WDmg >= minion.health then
				CastSpellStart(HK_W, minion.pos)
			end
		end
	end
end	

function KillSteal()
	local target = GetTarget(3000)     	
	if target == nil or myHero:GetSpellData(_R).name == "JhinRShot" then return end
	
	
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 3000 and Ready(_W) and Menu.ks.UseW:Value() then
			local WDmg = getdmg("W", target, myHero, 1)
			local hp = target.health
			if WDmg >= hp then
				CastW(target)
			end
		end
	end
end	

function CastW(target)
	local pred = GetGamsteronPrediction(target, WData, myHero)
	if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
		CastSpellStart(HK_W, pred.CastPosition)
	end
end	

function CastR(target)	
	local pred = GetGamsteronPrediction(target, RData, myHero)
	local angle = GetAngle(myHero.pos, target.pos)
	if myHero.pos:DistanceTo(target.pos) <= 3500 and IsValid(target) and pred.Hitchance >= Menu.Pred.PredR:Value() + 1 and angle then
		_G.SDK.Orbwalker:SetMovement(false)
		if target.pos:To2D().onScreen then
			CastSpell(HK_R, pred.CastPosition)
        else
			CastSpellMM(HK_R, pred.CastPosition)
                            
        end
		_G.SDK.Orbwalker:SetMovement(true)
	end
end	


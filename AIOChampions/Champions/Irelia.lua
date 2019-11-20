
function LoadScript()
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})

	--Flee
	Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
	Menu.Flee:MenuElement({id = "Q", name = "Flee[Q]", value = true})	

	--AutoE 
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "UseE", name = "2-5 Enemys stunable", value = true})	
	
	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ LastHit"})
	Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto LastHit Minion", value = true})
	Menu.AutoQ:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	Menu.AutoQ:MenuElement({id = "Q", name = "Auto Q Toggle Key", key = 84, toggle = true})
	Menu.AutoQ:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
			
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({name = " ", drop = {"E1, W, R, Q, E2, Q + (Q when kill / almost kill)"}})
	Menu.Combo:MenuElement({id = "QLogic", name = "Last[Q]Almost Kill or Kill", key = string.byte("I"), toggle = true})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"Marked + Dash back Minion", "Everytime"}})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	Menu.Clear.Last:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	
	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.6 + ping, Radius = 100, Range = 825, Speed = 1400, Collision = false
	}

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.75 + ping, Radius = 50, Range = 775, Speed = 2000, Collision = false
	}

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 160, Range = 1000, Speed = 2000, Collision = false
	}	
	
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("Draw", function() Draw() end) 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end		
	
end


function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
	elseif Mode == "Flee" then
		Flee()		
	end

	KillSteal()
	CastE2()
	if Menu.AutoQ.Q:Value() and Mode ~= "Combo" then
		AutoQ()
	end
end

function UseHydraminion(minion)
local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
	if hydraitem and myHero.pos:DistanceTo(minion.pos) <= 400 then
		Control.CastSpell(keybindings[hydraitem])
	end
end

function Draw()
  if myHero.dead then return end
	
	if Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 900, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 0, 10))
	end
	if Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 775, 1, Draw.Color(225, 225, 125, 10))
	end
	if Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 825, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	local Mode = GetMode()
	if Menu.AutoQ.UseQ:Value() and Mode ~= "Combo" then
		if Menu.AutoQ.Q:Value() then 
			Draw.Text("Auto[Q]Minion ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
		else
			Draw.Text("Auto[Q]Minion OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
		end	
	end	

	if Mode == "Combo" then	
		if Menu.Combo.QLogic:Value() then
			Draw.Text("[Q]Almost Kill", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
		else
			Draw.Text("[Q]Kill", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
		end	
	end		
	
	local target = GetTarget(1000)
	if target == nil then return end	
	if target and myHero.pos:DistanceTo(target.pos) <= 1000 and not target.dead then
	local Dmg = (getdmg("Q", target, myHero) + getdmg("W", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero)) 
	local hp = target.health	
		if myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_E).level > 0 and myHero:GetSpellData(_R).level > 0 and Dmg > hp then
			Draw.Text("KILL HIM", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
		else
			Draw.Text("HARASS HIM", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
		end	
	end
end
 
function Combo()
local target = GetTarget(1100)     	
if target == nil then return end
	if IsValid(target) then
		
		if Menu.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				CastE(target)

			end
		end	
			
		
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and GotBuff(target, "ireliamark") == 1 then
			Control.CastSpell(HK_Q, target.pos)
		end
		
		
		if Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				Control.CastSpell(HK_W, target)

			end
		end	
		

		if Menu.Combo.UseR:Value() and Ready(_R) and not Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 1000 then					
				CastR(target)

			end
		end	
		
		if Menu.Combo.QLogic:Value() then 
		local dmg = getdmg("Q", target, myHero) 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				if dmg >= target.health then
					Control.CastSpell(HK_Q, target.pos)
				end
			end			
			
			if myHero.pos:DistanceTo(target.pos) >= 300 and myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and (dmg*2) >= target.health then
				Control.CastSpell(HK_Q, target.pos)
			end		
		
		else
			local dmg = getdmg("Q", target, myHero) 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				if dmg >= target.health then
					Control.CastSpell(HK_Q, target.pos)
				end
			end
		end
		Gapclose(target)
		StackPassive(target)
	end	
end	

function Harass()
local target = GetTarget(1100)     	
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
			if Menu.Harass.UseQ:Value() ~= 2 and GotBuff(target, "ireliamark") == 1 then
				Control.CastSpell(HK_Q, target.pos)
				DelayAction(function()
				CastQMinion(target)
				end,0.5)
			end	
			if Menu.Harass.UseQ:Value() ~= 1 then
				Control.CastSpell(HK_Q, target.pos)
			end	
		end
		
		if Menu.Harass.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				CastW(target)
				
			end
		end	
		if Menu.Harass.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				CastE(target)
				
			end
		end	
	end	
end
	
function AutoQ()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if Menu.AutoQ.UseItem:Value() then
				UseHydraminion(minion)
			end	
            
			if Menu.AutoQ.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.AutoQ.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					Control.CastSpell(HK_Q, minion.pos)
				end
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					Control.CastSpell(HK_Q, minion.pos)
				end
            end
		end
	end
end

function StackPassive(target)
if GotBuff(myHero, "ireliapassivestacksmax") == 1 then return end	
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if target.pos:DistanceTo(minion.pos) <= 600 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end
			UseHydraminion(minion)
		end
	end
end	
			
function Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if Menu.Clear.UseW:Value() and Ready(_W) and not Ready(_Q) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 825 then
				Control.CastSpell(HK_W, minion.pos)
                    
            end           
           
			if Menu.AutoQ.Q:Value() then return end
			if Menu.Clear.UseItem:Value() then
				UseHydraminion(minion)
			end				
			
			if Menu.Clear.Last.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					Control.CastSpell(HK_Q, minion.pos)
				end	
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					Control.CastSpell(HK_Q, minion.pos)
				end				
			end
        end
    end
end

function KillSteal()
	local target = GetTarget(1100)     	
	if target == nil then return end
	
	
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and Menu.ks.UseQ:Value() then
			local QDmg = getdmg("Q", target, myHero)
			local hp = target.health
			if QDmg >= hp then
				Control.CastSpell(HK_Q, target.pos)
				DelayAction(function()
				CastQMinion(target)
				end,0.5)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 825 and Ready(_W) and Menu.ks.UseW:Value() then
			local WDmg = getdmg("W", target, myHero)
			local hp = target.health
			if WDmg >= hp then
				CastW(target)
			end
		end	
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_R) and Menu.ks.UseR:Value() then
			local RDmg = getdmg("R", target, myHero)
			local hp = target.health
			if RDmg >= hp then
				CastR(target)
			end
		end
	end
end	

function CastQMinion(target)
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			local Dmg = getdmg("Q", target, myHero) or getdmg("W", target, myHero) or getdmg("E", target, myHero) or getdmg("R", target, myHero)
			local QDmg = getdmg("Q", minion, myHero, 2)
			local hp = target.health
			if myHero.pos:DistanceTo(minion.pos) <= 600 and myHero.pos:DistanceTo(minion.pos) > myHero.pos:DistanceTo(target.pos) and not IsUnderTurret(minion) and hp > Dmg and QDmg >= minion.health then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end
end	

function Gapclose(target)
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	

		if myHero.pos:DistanceTo(target.pos) > 500 and myHero.pos:DistanceTo(minion.pos) <= 500 and target.pos:DistanceTo(minion.pos) < 600 then
			local QDmg = getdmg("Q", minion, myHero, 2)
			if Ready(_Q) and minion.team == TEAM_ENEMY and IsValid(minion) and QDmg >= minion.health then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end	
end	

function CastW(target)
    if target then
        if not charging and GotBuff(myHero, "ireliawdefense") == 0 then
            Control.KeyDown(HK_W)
            wClock = clock()
            settime = clock()
            charging = true
        end
		local pred = GetGamsteronPrediction(target, WData, myHero)
		if pred.Hitchance >= Menu.Pred.PredR:Value() + 1 then
			if GotBuff(myHero, "ireliawdefense") == 1 and (target.pos:DistanceTo() > 600) then
				Control.CastSpell(HK_W, pred.CastPosition)
				charging = false
			elseif GotBuff(myHero, "ireliawdefense") == 1 and clock() - wClock >= 0.5 and target.pos:DistanceTo() < 825 then
				Control.CastSpell(HK_W, pred.CastPosition)
				charging = false
			end		
        end
        
        
    end
    if clock() - wClock >= 1.5 then
    Control.KeyUp(HK_W)
    charging = false
    end 
end

function Flee()
    local target = GetTarget(1100)     	
	if target == nil then return end
	if Menu.Flee.Q:Value() then
		if target.pos:DistanceTo(myHero.pos) < 1000 then
			if Ready(_Q) then
				for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
					if minion.team == TEAM_ENEMY and IsValid(minion) then
						local QDmg = getdmg("Q", minion, myHero, 2)
						if minion.pos:DistanceTo(myHero.pos) <= 600 and target.pos:DistanceTo(myHero.pos) < minion.pos:DistanceTo(target.pos) and QDmg > minion.health then
							Control.CastSpell(HK_Q, minion.pos)
						end
					end	
                end
            end
            
		end
	end
end

function LineCircleIntersection(p1, p2, circle, radius)
    local dx, dy = p2.x - p1.x, p2.z - p1.z
    local a = dx * dx + dy * dy
    local b = 2 * (dx * (p1.x - circle.x) + dy * (p1.z - circle.z))
    local c = (p1.x - circle.x) * (p1.x - circle.x) + (p1.z - circle.z) * (p1.z - circle.z) - (radius * radius)
    local delta = b * b - 4 * a * c
    if delta >= 0 then
        local t1, t2 = (-b + math.sqrt(delta)) / (2 * a), (-b - math.sqrt(delta)) / (2 * a)
        return Vector(p1.x + t1 * dx, p1.y, p1.z + t1 * dy), Vector(p1.x + t2 * dx, p1.y, p1.z + t2 * dy)
    end
    return nil, nil
end

function GetBestECastPositions(units)
    local units = GetEnemyHeroes()
    local startPos, endPos, count = nil, nil, 0
    local candidates, unitPositions = {}, {}
    for i, unit in ipairs(units) do
        local cp = GetPred(unit,2000,0.75 + ping)
        if cp then candidates[i], unitPositions[i] = cp, cp end
    end
    local maxCount = #units
    for i = 1, maxCount do
        for j = 1, maxCount do
            if candidates[j] ~= candidates[i] then
                table.insert(candidates, Vector(candidates[j] + candidates[i]) / 2)
            end
        end
    end
    for i, unit2 in pairs(units) do
        local cp = GetPred(unit2,2000,0.75 + ping)
        if cp then
            if myHero.pos:DistanceTo(cp.pos) < 775 then
                for i, pos2 in ipairs(candidates) do
                    if pos2:DistanceTo(cp.pos) < 775 then 
                        
                        local ePos = Vector(cp):Extended(pos2, 775)
                        local number = 0
                        for i = 1, #unitPositions do
                            local unitPos = unitPositions[i]   
                            local pointLine, pointSegment, onSegment = VectorPointProjectionOnLineSegment(cp, ePos, unitPos)
                            if pointSegment and GetDistance(pointSegment, unitPos) < 1550 then number = number + 1 end 
                             
                        end
                        if number >= 2 then startPos, endPos, count = cp, ePos, number end

                    end
                end
            end
        end
    end
    return startPos, endPos, count
end

function CastE2()
local target = GetTarget(1100)
	if IsValid(target) and Menu.AutoE.UseE:Value() and Ready(_E) then
		local startPos, endPos, count = GetBestECastPositions(target)
		if startPos and endPos then 
			local cast1, cast2 = LineCircleIntersection(startPos, endPos, myHero.pos, 725)
			local targetCount = GetEnemyCount(725, myHero)
				if targetCount >= 2 and cast1 and cast2 then
				if myHero:GetSpellData(_E).name == "IreliaE" then
					Control.CastSpell(HK_E, cast1)
				elseif myHero:GetSpellData(_E).name == "IreliaE2" then
					DelayAction(function() Control.CastSpell(HK_E, cast2) end, 0.15)
				end
			end
		end
	end	
end	

function CastE(target)

    if myHero:GetSpellData(_E).name == "IreliaE" then
		Control.CastSpell(HK_E, myHero.pos)
    
    end
	local pred = GetGamsteronPrediction(target, EData, myHero)
    if myHero:GetSpellData(_E).name == "IreliaE2" and pred.Hitchance >= Menu.Pred.PredR:Value() + 1 then
        pos2 = pred.CastPosition + (myHero.pos - pred.CastPosition): Normalized() * -150
        Control.CastSpell(HK_E, pos2)
       
	end
end


function CastR(target)
	local pred = GetGamsteronPrediction(target, RData, myHero)
	if pred.Hitchance >= Menu.Pred.PredR:Value() + 1 then
		Control.CastSpell(HK_R, pred.CastPosition)
	end
end	
local function CastSpellMM(spell,pos,range,delay)
	local range = range or MathHuge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Latency() then
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
			end,Latency()/1000)
		end
		if ticker - castSpell.casting > Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
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

local function GetEnemyHeroes()
	return Enemies
end 

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R] if killable with FullCombo", value = true})
	Menu.Combo:MenuElement({id = "Draw", name = "Draw Killable FullCombo[onScreen+Minimap]", value = true})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseQM", name = "Use[Q] min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})  
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"}) 		
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 1200, Speed = 1600, Collision = false
	}
	
	QspellData = {speed = 1600, range = 1200, delay = 0.25, radius = 100, collision = {}, type = "linear"}		
	
	Rrange = 1750 + 750 * myHero:GetSpellData(_R).lvl
  	
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
		DrawCircle(myHero, Rrange, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1200, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 425, 1, DrawColor(225, 225, 125, 10))
		end
		
		for i, target in pairs(GetEnemyHeroes()) do	
			if Menu.Combo.Draw:Value() and myHero.pos:DistanceTo(target.pos) <= 10000 and IsValid(target) then
			local RDmg = getdmg("R", target, myHero)
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local FullDmg = (RDmg + QDmg + EDmg)
			local hp = target.health	
				if Ready(_R) and Ready(_Q) and Ready(_E) and FullDmg > hp then
					DrawText("Ult Kill", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
					DrawText("Ult Kill", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))
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
		if Ready(_R) then
			Ult()
		end	
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end	
end

function Ult()
local target = GetTarget(Rrange+100)     	
if target == nil then return end
	if IsValid(target) then
			
		if myHero.pos:DistanceTo(target.pos) <= Rrange and Menu.Combo.UseR:Value() then
			local RDmg = getdmg("R", target, myHero)
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local FullDmg = (RDmg + QDmg + EDmg)
			if FullDmg >= target.health then				
				if target.pos:To2D().onScreen then
					ControlCastSpell(HK_R, target)
				else
					CastSpellMM(HK_R, target.pos)                            
				end				
			end
		end
	end	
end
	
function Combo()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target) then
			
		if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) and Menu.Combo.UseQ:Value() then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					ControlCastSpell(HK_Q, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					ControlCastSpell(HK_Q, pred.CastPos)
				end	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) < 400 and Ready(_E) and Menu.Combo.UseE:Value() then
			ControlCastSpell(HK_E, target)
        end				
		
		if myHero.pos:DistanceTo(target.pos) < 300 and Menu.Combo.UseW:Value() and Ready(_W) then				
			ControlCastSpell(HK_W)
		end
	end	
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_ENEMY and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < 1200 and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and Ready(_Q) then
				local count = GetMinionCount(400, minion)
				if count >= Menu.Clear.UseQM:Value() then
					ControlCastSpell(HK_Q, minion.pos)
				end	
            end
                      
			if myHero.pos:DistanceTo(minion.pos) < 425 and Ready(_E) and Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				local count = GetMinionCount(400, minion)
				if count >= Menu.Clear.UseEM:Value() then
					ControlCastSpell(HK_E, minion)
                end    
            end
        end
    end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < 1200 and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and Ready(_Q) then
				ControlCastSpell(HK_Q, minion.pos)
            end
                      
			if myHero.pos:DistanceTo(minion.pos) < 425 and Ready(_E) and Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				ControlCastSpell(HK_E, minion)    
            end
        end
    end
end


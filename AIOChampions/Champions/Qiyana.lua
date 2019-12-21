function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end			

function CheckWall(from, to, distance)
    local pos1 = to + (to - from):Normalized() * 50
    local pos2 = pos1 + (to - from):Normalized() * (distance - 50)
    local point1 = Point(pos1.x, pos1.z)
    local point2 = Point(pos2.x, pos2.z)
    if MapPosition:intersectsWall(LineSegment(point1, point2)) or (MapPosition:inWall(point1) and MapPosition:inWall(point2)) then
        return true
    end
    return false
end

require "MapPositionGOS"

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseQW", name = "[Q]only if Ready[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Combo:MenuElement({id = "UseR", name = "[R] Check Wall.pos", value = true})
			

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseQW", name = "[Q]only if Ready[W]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})		
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true}) 		
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"}) 	
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseQ2", name = "[Q] Terrain Buff", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})	
--[[
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
]] 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	

  	                                           
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
		--local textPos = myHero.pos:To2D()	
		--if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			--Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		--end  
		
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 875, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 650, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 650, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 125, 10))
		end		
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		CastUlt()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
			
	end	

	KillSteal()
end

function CastUlt()
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
		if myHero.pos:DistanceTo(hero.pos) < 875 and hero.team == TEAM_ENEMY and IsValid(hero) then
			if Menu.Combo.UseR:Value() and Ready(_R) and CheckWall(myHero.pos,  hero:GetPrediction(0.31, 2000), 280) then
				Control.CastSpell(HK_R, hero.pos)
			end
		end
	end
end	

function Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then		
		
		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_E) then			
			Control.CastSpell(HK_E, target)
        end		
		
		if Menu.Combo.UseQW:Value() then 
			if myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) and Ready(_W) and not HasBuff(myHero, "qiyanawenchantedbuff") then
				Control.CastSpell(HK_Q, target.pos)
			end
		else
			if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Combo.UseQ:Value() and Ready(_Q) and not HasBuff(myHero, "qiyanawenchantedbuff") then
				Control.CastSpell(HK_Q, target.pos)
			end			
        end
       
		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 1100 and Ready(_W) then
			Control.CastSpell(HK_W, target.pos)	
        end	

		if HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(target.pos) < 710 then
			Control.CastSpell(HK_Q, target.pos)
		end	
	end
end

function Harass()
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
        
		if Menu.Harass.UseQW:Value() then 
			if myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) and Ready(_W) and not HasBuff(myHero, "qiyanawenchantedbuff") then
				Control.CastSpell(HK_Q, target.pos)
			end
		else
			if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Harass.UseQ:Value() and Ready(_Q) and not HasBuff(myHero, "qiyanawenchantedbuff") then
				Control.CastSpell(HK_Q, target.pos)
			end			
        end
		
        if Menu.Harass.UseW:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) < 710 and Ready(_W) then			
			Control.CastSpell(HK_W, target.pos)
        end	

		if HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(target.pos) < 710 then
			Control.CastSpell(HK_Q, target.pos)
		end			
	end
end		

function Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if myHero.pos:DistanceTo(minion.pos) < 1200 and minion.team == TEAM_ENEMY and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
            if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_E) then
				Control.CastSpell(HK_E, minion)
            end			
			
			if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_Q) and Ready(_W) then
				Control.CastSpell(HK_Q, minion,pos)	
            end
			
            if Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1100 and Ready(_W) then	
				Control.CastSpell(HK_W, minion.pos)	
            end

			if HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(minion.pos) < 710 then
				Control.CastSpell(HK_Q, minion.pos)
			end				
        end
    end
end

function JungleClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if myHero.pos:DistanceTo(minion.pos) < 1200 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
            if Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_E) then
				Control.CastSpell(HK_E, minion)
            end				
			
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_Q) and Ready(_W) then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1100 and Ready(_W) then	
				Control.CastSpell(HK_W, minion.pos)	
            end

			if HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(minion.pos) < 710 then
				Control.CastSpell(HK_Q, minion.pos)
			end				
        end
    end
end

function KillSteal()	
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
       
	local QDmg = getdmg("Q", target, myHero, 1)
	local Q2Dmg = getdmg("Q", target, myHero, 2)
	local EDmg = getdmg("E", target, myHero)
	local WPassiveDmg = getdmg("W", target, myHero)
	local EWDmg = (EDmg + WPassiveDmg)	
	local HP = (target.health + (target.hpRegen * 2))	
		
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) and not HasBuff(myHero, "qiyanawenchantedbuff") then
			if QDmg-20 >= HP then
				Control.CastSpell(HK_Q, target.pos)
			end	
        end
		
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 710 and HasBuff(myHero, "qiyanawenchantedbuff") and not myHero:GetSpellData(_Q).name == "QiyanaQ_Rock" then
			if QDmg-20 >= HP then
				Control.CastSpell(HK_Q, target.pos)
			end	
        end		
		
		if Menu.ks.UseQ2:Value() and myHero.pos:DistanceTo(target.pos) < 710 and myHero:GetSpellData(_Q).name == "QiyanaQ_Rock" then
			if Q2Dmg-20 >= HP then
				Control.CastSpell(HK_Q, target.pos)
			end			
        end
		
		if HasBuff(myHero, "qiyanawenchantedbuffhaste") then
			if Menu.ks.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_E) then
				if EWDmg-20 >= HP then
					Control.CastSpell(HK_E, target)
				end	
			end
		else
			if Menu.ks.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_E) then
				if EDmg-20 >= HP then
					Control.CastSpell(HK_E, target)
				end	
			end		
		end
	end	
end


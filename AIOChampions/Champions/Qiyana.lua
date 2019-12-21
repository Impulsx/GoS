function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff.count
    end
  end
  return 0
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

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
			

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
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

	--LastHit
	Menu:MenuElement({type = MENU, id = "Last", name = "LastHit Minion"})
	Menu.Last:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Last:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Last:MenuElement({id = "Mana", name = "Min Mana to LastHit", value = 20, min = 0, max = 100, identifier = "%"})
	Menu.Last:MenuElement({id = "Active", name = "LastHit Key", key = string.byte("X")})	
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseRW", name = "[R]+[W] if in range", value = true})	
	Menu.ks:MenuElement({id = "UseRQ", name = "[R]+[Q] if range bigger", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
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
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end  
		
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
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "LastHit" then
		if Menu.Last.Active:Value() then
			--LastHit()	
		end
			
	end	

	--KillSteal()
end

function Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then
   
		if myHero.pos:DistanceTo(target.pos) < 875 and Ready(_R) then
			Control.CastSpell(HK_R, target.pos)
        end			
		
		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_E) then			
			Control.CastSpell(HK_E, target)
        end		
		
		if Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) then
			Control.CastSpell(HK_Q, target.pos)
        end
       
		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 1100 and Ready(_W) then
			Control.CastSpell(HK_W, target.pos)	
        end				
	end
end

function Harass()
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
        
		if Menu.Harass.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) then
			Control.CastSpell(HK_Q, target.pos)
        end
		
        if Menu.Harass.UseW:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) < 710 and Ready(_W) then			
			Control.CastSpell(HK_W, target.pos)
        end				
	end
end		

function Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if myHero.pos:DistanceTo(minion.pos) < 1200 and minion.team == TEAM_ENEMY and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
            if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_E) then
				Control.CastSpell(HK_E, minion.pos)
            end			
			
			if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion,pos)	
            end
			
            if Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1100 and Ready(_W) then	
				Control.CastSpell(HK_W, minion.pos)	
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
				Control.CastSpell(HK_E, minion.pos)
            end				
			
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1100 and Ready(_W) then	
				Control.CastSpell(HK_W, minion.pos)	
            end		
        end
    end
end
--[[
function LastHit()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Last.Mana:Value() / 100
            
			if Menu.Last.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and myHero.pos:DistanceTo(minion.pos) > 200 and IsValid(minion) and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero)
				if QDmg >= minion.health then
					Control.CastSpell(HK_Q, minion)
				end	
            end
			
            if Menu.Last.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 200 and IsValid(minion) and Ready(_W) then
				local Dmg = (getdmg("W", minion, myHero, 1) + getdmg("W", minion, myHero, 2) + getdmg("AA", minion, myHero))
				if Dmg >= minion.health then	
					Control.CastSpell(HK_W)
				end	
            end			
        end
    end
end

function KillSteal()	
local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
       
	local stacks = GotBuff(myHero, "RiftWalk")
	local QDmg = getdmg("Q", target, myHero)
	local RDmg = getdmg("R", target, myHero, 1)
	local RBonusDmg = getdmg("R", target, myHero, 2)
	local WDmg = (getdmg("W", target, myHero, 1) + getdmg("W", target, myHero, 2) + getdmg("AA", target, myHero))
	local FullRDmg = ((stacks * RBonusDmg) + RDmg)
	local RWDmg = (WDmg + FullRDmg)
	local HP = (target.health + (target.hpRegen * 2))	
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) then
			if QDmg-20 >= HP then
				Control.CastSpell(HK_Q, target)
			end	
        end
		
        if Menu.ks.UseRW:Value() and myHero.pos:DistanceTo(target.pos) < 650 then
	
			if stacks >= 1 then

				if Ready(_R) and Ready(_W) and RWDmg >= HP then
					Control.CastSpell(HK_R, target.pos)
				end	
				if Ready(_W) and myHero.pos:DistanceTo(target.pos) < 200 and WDmg >= target.health then
					Control.CastSpell(HK_W)
				end
			else
				if Ready(_R) and Ready(_W) and (RDmg + WDmg) >= HP then
					Control.CastSpell(HK_R, target.pos)
				end	
				if Ready(_W) and myHero.pos:DistanceTo(target.pos) < 200 and WDmg >= target.health then
					Control.CastSpell(HK_W)
				end				
			end
		end
		
		if Menu.ks.UseRQ:Value() and myHero.pos:DistanceTo(target.pos) > 650 and myHero.pos:DistanceTo(target.pos) < 1100 then
			if Ready(_R) and Ready(_Q) and QDmg-20 >= HP then
				Control.CastSpell(HK_R, target.pos)
			end			
        end
	end	
end
]]

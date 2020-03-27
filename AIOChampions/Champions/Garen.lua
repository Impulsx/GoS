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

local function EnemiesNear(pos,range)
	local pos = pos.pos
	local N = 0
	for i = 1,GameHeroCount()  do
		local hero = GameHero(i)
		local Range = range * range
		if IsValid(hero) and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < Range then
			N = N + 1
		end
	end
	return N	
end

local function Cleans(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and buff.type == 10 and buff.count > 0 then
			return true
		end
	end
	return false	
end	

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "cancel", name = "Cancel [E] if no Enemy near -->", value = 500, min = 0, max = 1000, identifier = "range"})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R] if killable", value = true})
	Menu.Combo:MenuElement({id = "UseRHP", name = "[R] Enemy HP check", value = false})	
	Menu.Combo:MenuElement({id = "HP", name = "[R] if Enemy HP lower than -->", value = 30, min = 0, max = 100, identifier = "%"})
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Lasthit", value = true})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 4, min = 1, max = 7, step = 1, identifier = "Minion/s"})  
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})

	--AutoW
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W]", value = true})
	Menu.AutoW:MenuElement({id = "HP", name = "[W] if own HP lower than -->", value = 70, min = 0, max = 100, identifier = "%"})

	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ"})
	Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto[Q] clean slows", value = true})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
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
	elseif _G.PremiumOrbwalker then
		Orb = 5		
	end	
	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function()
	if myHero.dead then return end

		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 400, 1, DrawColor(255, 225, 255, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 325, 1, DrawColor(225, 225, 125, 10))
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
	end
	AutoW()
	AutoQ()
end

function AutoW()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
	
		if Menu.AutoW.UseW:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= Menu.AutoW.HP:Value() / 100 then
				ControlCastSpell(HK_W)
			end	
		end
	end
end

function AutoQ()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
		local slow = Cleans(myHero)
		if Menu.AutoQ.UseQ:Value() and Ready(_Q) then
			if slow then
				ControlCastSpell(HK_Q)
			end	
		end
	end
end
	
function Combo()
local target = GetTarget(600)     	
if target == nil then return end
	if IsValid(target) then
		local Enemys1 = EnemiesNear(myHero,1000)
		local Enemys2 = EnemiesNear(myHero,500)
		local Enemys3 = EnemiesNear(myHero,Menu.Combo.cancel:Value())
		local RDmg = getdmg("R", target, myHero)
	
		if Enemys1 == 1 then
			if myHero.pos:DistanceTo(target.pos) <= 300 and Ready(_Q) and Menu.Combo.UseQ:Value() then
				ControlCastSpell(HK_Q)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 325 and Ready(_E) and not Ready(_Q) and Menu.Combo.UseE:Value() then
				ControlCastSpell(HK_E, target.pos)
			end

			if myHero:GetSpellData(HK_E).name == "GarenECancel" and (Enemys3 == 0 or (Ready(_R) and RDmg > target.health)) then
				ControlCastSpell(HK_E)
			end				
			
			if Ready(_R) then
				if myHero.pos:DistanceTo(target.pos) <= 400 then				
					if Menu.Combo.UseR:Value() and RDmg > target.health then
						ControlCastSpell(HK_R, target)
					end	
					if Menu.Combo.UseRHP:Value() and target.health/target.maxHealth <= Menu.Combo.HP:Value() / 100 then
						ControlCastSpell(HK_R, target)
					end				
				end
			end	
		end	
		
		if Enemys2 >= 2 then
			if Ready(_E) and Menu.Combo.UseE:Value() then
				ControlCastSpell(HK_E, target.pos)
			end

			if myHero:GetSpellData(HK_E).name == "GarenECancel" and (Enemys3 == 0 or (Ready(_R) and RDmg > target.health)) then
				ControlCastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) <= 300 and Ready(_Q) and Menu.Combo.UseQ:Value() then
				ControlCastSpell(HK_Q)
			end
			
			if Ready(_R) then
				if myHero.pos:DistanceTo(target.pos) <= 400 then				
					if Menu.Combo.UseR:Value() and RDmg > target.health then
						ControlCastSpell(HK_R, target)
					end	
					if Menu.Combo.UseRHP:Value() and target.health/target.maxHealth <= Menu.Combo.HP:Value() / 100 then
						ControlCastSpell(HK_R, target)
					end				
				end
			end				
		end
	end	
end	

function Harass()
local target = GetTarget(600)
if target == nil then return end
	if IsValid(target) then

		if myHero.pos:DistanceTo(target.pos) <= 300 then	
			if Menu.Harass.UseQ:Value() and Ready(_Q) then
				ControlCastSpell(HK_Q)
			end
		end
	end
end

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < 300 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero) + getdmg("AA", minion, myHero)
				if QDmg >= minion.health then
					ControlCastSpell(HK_Q)
				end	
            end
                      
			if myHero.pos:DistanceTo(minion.pos) < 325 and Ready(_E) and Menu.Clear.UseE:Value() then
				local count = GetMinionCount(400, minion)
				if count >= Menu.Clear.UseEM:Value() then
					ControlCastSpell(HK_E)
                end    
            end
        end
    end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < 300 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				ControlCastSpell(HK_Q)
            end
                      
			if myHero.pos:DistanceTo(minion.pos) < 325 and Ready(_E) and Menu.Clear.UseE:Value() then
				ControlCastSpell(HK_E)    
            end
        end
    end
end

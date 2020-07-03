local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end			

local function CheckWall(from, to, distance)
    local pos1 = to + (to - from):Normalized() * 50
    local pos2 = pos1 + (to - from):Normalized() * (distance - 50)
    local point1 = Point(pos1.x, pos1.z)
    local point2 = Point(pos2.x, pos2.z)
    if MapPosition:intersectsWall(LineSegment(point1, point2)) then
        return true
    end
    return false
end

local function IsUnderTurret(unit)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local function IsUltRangeTurret(unit)
    local _Tower = {}
	for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 200 + unit.boundingRadius / 2)
        if turret.pos:DistanceTo(unit.pos) < range then
            TableInsert(_Tower, turret)
        end
    end
    return _Tower
end

local function AllyMinionUnderTower()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if minion.team == TEAM_ALLY and IsValid(minion) and IsUnderTurret(minion) and myHero.pos:DistanceTo(minion.pos) <= 750 then
			return true
		end
	end
	return false
end

local function Rotate(startPos, endPos, height, theta)
    local dx, dy = endPos.x - startPos.x, endPos.z - startPos.z
    local px, py = dx * math.cos(theta) - dy * math.sin(theta), dx * math.sin(theta) + dy * math.cos(theta)
    return Vector(px + startPos.x, height, py + startPos.z)
end

local Objects = { [1] = WATER, [2] = GRASS, [3] = WALL }

local function FindBestQiyanaWPos(mode)
    local startPos, mPos, height = Vector(myHero.pos), Vector(mousePos), myHero.pos.y
    for i = 100, 2000, 100 do -- search range
        local endPos = startPos:Extended(mPos, i)
        for j = 20, 360, 20 do -- angle step
            local testPos = Rotate(startPos, endPos, height, math.rad(j))
            if testPos:ToScreen().onScreen then 
                if mode == Objects.WATER and MapPosition:inRiver(testPos) or
                    mode == Objects.GRASS and MapPosition:inBush(testPos) or
                    mode == Objects.WALL and MapPosition:inWall(testPos) then
                    return testPos
                end
            end
        end
    end
    return nil
end

require "2DGeometry"
require "MapPositionGOS"

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.10"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseQW", name = "[Q1]waiting for Ready[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseQW2", name = "[Q2]waiting for Ready[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	Menu.Combo:MenuElement({id = "UseR", name = "[R] Check Wall.pos/ Tower.pos", value = true})
			

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseQW", name = "[Q1]waiting for Ready[W]", value = true})	
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
	Menu.ks:MenuElement({id = "UseQ", name = "[Q1]", value = true})	
	Menu.ks:MenuElement({id = "UseQ2", name = "[Q2] Terrain Buff", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function() 
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 875, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			if HasBuff(myHero, "qiyanawenchantedbuff") then
				DrawCircle(myHero, 710, 1, DrawColor(225, 225, 0, 10))
			else
				DrawCircle(myHero, 650, 1, DrawColor(225, 225, 0, 10))
			end	
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 650, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 1100, 1, DrawColor(225, 225, 125, 10))
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
	
	for i = 1, GameHeroCount() do
        local hero = GameHero(i)
		if myHero.pos:DistanceTo(hero.pos) < 1100 and hero.team == TEAM_ENEMY and IsValid(hero) and Menu.Combo.UseR:Value() and Ready(_R) then
			if myHero.pos:DistanceTo(hero.pos) < 875 then
				local WallPos = CheckWall(myHero.pos, hero.pos, 400)
				if WallPos then
					SetAttack(false)
					 Control.CastSpell(HK_R, hero.pos)
					SetAttack(true)
				end
			end	
		
			for i, tower in pairs(IsUltRangeTurret(hero)) do				
				if Ready(_R) and tower and myHero.pos:DistanceTo(tower.pos) < 875 then
					SetAttack(false)
					 Control.CastSpell(HK_R, tower.pos)
					SetAttack(true)
				end		
			end
		end	
	end
end	

function Combo()

local target = GetTarget(2000)
if target == nil then return end
	if IsValid(target) then		
		
		if Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 650 and Ready(_E) then			
			 Control.CastSpell(HK_E, target)
        end		
		
		if Menu.Combo.UseQW:Value() then
			if myHero:GetSpellData(_W).level == 0 then
				if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Combo.UseQ:Value() and Ready(_Q) and not HasBuff(myHero, "qiyanawenchantedbuff") then
					 Control.CastSpell(HK_Q, target.pos)
				end				
			else	
				if myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) and Ready(_W) and not HasBuff(myHero, "qiyanawenchantedbuff") then
					 Control.CastSpell(HK_Q, target.pos)
				end
			end	
		else
			if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Combo.UseQ:Value() and Ready(_Q) and not HasBuff(myHero, "qiyanawenchantedbuff") then
				 Control.CastSpell(HK_Q, target.pos)
			end			
        end 
		
		local castPos = FindBestQiyanaWPos(Objects.WALL)
		if Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 1900 and Ready(_W) and castPos ~= nil and not HasBuff(myHero, "qiyanawenchantedbuff") then
			if target.pos:DistanceTo(castPos) < myHero.pos:DistanceTo(castPos) then
				 Control.CastSpell(HK_W, castPos)
			else
				 Control.CastSpell(HK_W, castPos)
			end
        end	

		if Menu.Combo.UseQW2:Value() then
			if HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(target.pos) < 710 and Ready(_Q) and Ready(_W) then
				 Control.CastSpell(HK_Q, target.pos)
			end
		else
			if HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(target.pos) < 710 and Ready(_Q) then
				 Control.CastSpell(HK_Q, target.pos)
			end			
		end	
	end
end

function Harass()

local target = GetTarget(800)
if target == nil then return end
	if IsValid(target) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
        
		if Menu.Harass.UseQW:Value() then 
			if myHero:GetSpellData(_W).level == 0 then
				if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Harass.UseQ:Value() and Ready(_Q) and not HasBuff(myHero, "qiyanawenchantedbuff") then
					 Control.CastSpell(HK_Q, target.pos)
				end	
			else
				if myHero.pos:DistanceTo(target.pos) < 650 and Ready(_Q) and Ready(_W) and not HasBuff(myHero, "qiyanawenchantedbuff") then
					 Control.CastSpell(HK_Q, target.pos)
				end
			end	
		else
			if myHero.pos:DistanceTo(target.pos) < 650 and Menu.Harass.UseQ:Value() and Ready(_Q) and not HasBuff(myHero, "qiyanawenchantedbuff") then
				 Control.CastSpell(HK_Q, target.pos)
			end			
        end 
		
		local castPos = FindBestQiyanaWPos(Objects.WALL)
		if Menu.Harass.UseW:Value() and myHero.pos:DistanceTo(target.pos) < 1100 and Ready(_W) and castPos ~= nil and not HasBuff(myHero, "qiyanawenchantedbuff") then
			if target.pos:DistanceTo(castPos) < myHero.pos:DistanceTo(target.pos) then
				 Control.CastSpell(HK_W, castPos)
			end
        end	

		if HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(target.pos) < 710 and Ready(_Q) then
			 Control.CastSpell(HK_Q, target.pos)
		end			
	end
end		

function Clear()

    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) < 1200 and minion.team == TEAM_ENEMY and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
            if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_E) then
				if not IsUnderTurret(minion) then
					 Control.CastSpell(HK_E, minion)
				elseif AllyMinionUnderTower() then
					 Control.CastSpell(HK_E, minion)
				end	
            end 		
			
			if myHero:GetSpellData(_W).level == 0 then
				if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_Q) then
					 Control.CastSpell(HK_Q, minion.pos)	
				end
			else	
				if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_Q) and Ready(_W) then
					 Control.CastSpell(HK_Q, minion.pos)	
				end
			end	
			
			local castPos = FindBestQiyanaWPos(Objects.WALL)			
            if Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 1100 and Ready(_W) and castPos ~= nil and not HasBuff(myHero, "qiyanawenchantedbuff") then	
				if not IsUnderTurret(minion) then
					 Control.CastSpell(HK_W, castPos)
				elseif AllyMinionUnderTower() then
					 Control.CastSpell(HK_W, castPos)
				end	
            end 		

			if Menu.Clear.UseQ:Value() and mana_ok and HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(minion.pos) < 710 and Ready(_Q) then
				 Control.CastSpell(HK_Q, minion.pos)
			end				
        end
    end
end

function JungleClear()

    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) < 1200 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
            if Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_E) then
				 Control.CastSpell(HK_E, minion)
            end				
			
			if myHero:GetSpellData(_W).level == 0 then			
				if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_Q) then
					 Control.CastSpell(HK_Q, minion.pos)
				end
			else
				if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 650 and Ready(_Q) and Ready(_W) then
					 Control.CastSpell(HK_Q, minion.pos)
				end	
			end 
			
			local castPos = FindBestQiyanaWPos(Objects.WALL)
			if Menu.JClear.UseW:Value() and myHero.pos:DistanceTo(minion.pos) < 1100 and Ready(_W) and castPos ~= nil and not HasBuff(myHero, "qiyanawenchantedbuff") then
				Control.CastSpell(HK_W, castPos)	
            end 

			if Menu.JClear.UseQ:Value() and mana_ok and HasBuff(myHero, "qiyanawenchantedbuff") and myHero.pos:DistanceTo(minion.pos) < 710 and Ready(_Q) then
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
		
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) < 710 and Ready(_Q) and HasBuff(myHero, "qiyanawenchantedbuff") and not myHero:GetSpellData(_Q).name == "QiyanaQ_Rock" then
			if QDmg-20 >= HP then
				 Control.CastSpell(HK_Q, target.pos)
			end	
        end		
		
		if Menu.ks.UseQ2:Value() and myHero.pos:DistanceTo(target.pos) < 710 and Ready(_Q) and myHero:GetSpellData(_Q).name == "QiyanaQ_Rock" then
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

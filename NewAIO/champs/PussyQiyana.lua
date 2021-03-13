--///////////////////////////////////////////////////////////
--//////////////////////////// Auto Update and Lib Download
--///////////////////////////////////////////////////////////
local version = 1.00

local function ReadFile(path, fileName)
    local file = io.open(path .. fileName, "r")
    local result = file:read()
    file:close()
    return result
end

DownloadFileAsync("https://raw.githubusercontent.com/Impulsx/GoS/master/NewAIO/champs/PussyQiyana.version", COMMON_PATH .. "PussyQiyana.version", function() 
	local onlineVersion = tonumber(ReadFile(COMMON_PATH , "PussyQiyana.version"))

	if onlineVersion > version then
		DownloadFileAsync("https://raw.githubusercontent.com/Impulsx/GoS/master/NewAIO/champs/PussyQiyana.lua", COMMON_PATH .. "PussyQiyana.lua", function() 
			print("PussyLoader: Qiyana updated. Press F6 to reload.")
		end)

		return
	end
end)

if not FileExist(COMMON_PATH, "PussyCore.lua") then
	print("PussyLoader: PussyCore is missing. Script wont start. Downloading...")

	DownloadFileAsync("https://raw.githubusercontent.com/Impulsx/GoS/master/NewAIO/PussyCore.lua", COMMON_PATH .. "PussyCore.lua", function()
		print("PussyLoader: PussyCore downloaded successfully. Please press F6 to restart.")
	end)

	return
end

if not FileExist(COMMON_PATH, "DamageLib.lua") then
	print("PussyLoader: DamageLib is missing. Script wont start. Downloading...")

	DownloadFileAsync("https://raw.githubusercontent.com/Impulsx/GoS/master/DamageLib.lua", COMMON_PATH .. "DamageLib.lua", function()
		print("PussyLoader: DamageLib downloaded successfully. Please press F6 to restart.")
	end)

	return
end

--///////////////////////////////////////////////////////////
--//////////////////////////// Requirements
--///////////////////////////////////////////////////////////

local Core = require 'PussyCore'
require "2DGeometry"
require "MapPositionGOS"
require "DamageLib"

--///////////////////////////////////////////////////////////
--//////////////////////////// Local Variables
--///////////////////////////////////////////////////////////

local rad = math.rad
local insert = table.insert
local Qiyana = {}

--///////////////////////////////////////////////////////////
--//////////////////////////// helpers
--///////////////////////////////////////////////////////////

function Qiyana:loadMenu()
	self.Menu = MenuElement({type = MENU, id = "PussyAIO: ".. myHero.charName, name = myHero.charName})
	self.Menu:MenuElement({name = " ", drop = {"Version 0.05"}})
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Combo:MenuElement({id = "UseQW", name = "[Q1]waiting for Ready[W]", value = true})	
	self.Menu.Combo:MenuElement({id = "UseQW2", name = "[Q2]waiting for Ready[W]", value = true})	
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})		
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R] Check Wall.pos/ Tower.pos", value = true})
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "UseQW", name = "[Q1]waiting for Ready[W]", value = true})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})		
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true}) 		
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"}) 	
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q1]", value = true})	
	self.Menu.ks:MenuElement({id = "UseQ2", name = "[Q2] Terrain Buff", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})
	--Prediction
	--self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})	
	--self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
end

function Qiyana:loadCallbacks()
	Callback.Add("Tick", function() Qiyana:Tick() end)
	Callback.Add("Draw", function() Qiyana:Draw() end)
end

function Qiyana:FindBestQiyanaWPos()
    local startPos, mPos, height = Vector(myHero.pos), Vector(mousePos), myHero.pos.y

    for i = 100, 2000, 100 do -- search range
        local endPos = startPos:Extended(mPos, i)

        for j = 20, 360, 20 do -- angle step
            local testPos = Core:Rotate(startPos, endPos, height, rad(j))

            if testPos:ToScreen().onScreen then 
                if MapPosition:inRiver(testPos) then
                    return testPos
				elseif MapPosition:inBush(testPos) then
					return testPos
                elseif MapPosition:inWall(testPos) then
					return testPos
                end
            end
        end
    end

    return nil
end

function Qiyana:IsUltRangeTurret(unit)
    local _Tower = {}

	for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        local range = turret.boundingRadius + 200 + unit.boundingRadius * .5

        if turret.pos:DistanceTo(unit.pos) < range then
            insert(_Tower, turret)
        end
    end

    return _Tower
end

--///////////////////////////////////////////////////////////
--//////////////////////////// Actions
--///////////////////////////////////////////////////////////

function Qiyana:CastQ(pos)
	Control.CastSpell(HK_Q, pos)
end

function Qiyana:CastW(pos)
	Control.CastSpell(HK_W, pos)
end

function Qiyana:CastE(unit)
	Control.CastSpell(HK_E, unit)
end

function Qiyana:CastR(pos)
	Control.CastSpell(HK_R, pos)
end

function Qiyana:Combo()
	local target = Core:GetTarget(2000)

	if target and Core:IsValid(target) then
		local comboMenu = self.Menu.Combo
		local targetDistance = myHero.pos:DistanceTo(target.pos)

		if comboMenu.UseE:Value() and targetDistance < 650 and Core:Ready(_E) then
			self:CastE(target)
			return
        end
		
		if comboMenu.UseQW:Value() and targetDistance < 650 then
			if myHero:GetSpellData(_W).level == 0 then
				if comboMenu.UseQ:Value() and Core:Ready(_Q) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
					self:CastQ(target.pos)
					return
				end				
			else	
				if Core:Ready(_Q) and Core:Ready(_W) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
					self:CastQ(target.pos)
					return
				end
			end	
		elseif targetDistance < 650 then
			if comboMenu.UseQ:Value() and Core:Ready(_Q) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
				self:CastQ(target.pos)
				return
			end			
        end

		if comboMenu.UseW:Value() and targetDistance < 1900 and Core:Ready(_W) and not HasBuff(myHero, "qiyanawenchantedbuff") then
			local castPos = self:FindBestQiyanaWPos()

			if target.pos:DistanceTo(castPos) < myHero.pos:DistanceTo(castPos) then
				self:CastW(HK_W, castPos)
				return
			end
        end

		if comboMenu.UseQW2:Value() then
			if Core:HasBuff(myHero, "qiyanawenchantedbuff") and targetDistance < 710 and Core:Ready(_Q) and Core:Ready(_W) then
				self:CastQ(target.pos)
				return
			end
		else
			if Core:HasBuff(myHero, "qiyanawenchantedbuff") and targetDistance < 710 and Core:Ready(_Q) then
				self:CastQ(target.pos)
				return
			end			
		end	
	end
end

function Qiyana:Harass()
	local target = Core:GetTarget(800)

	if target and Core:IsValid(target) then
		local harassMenu = self.Menu.Harass
        local mana_ok = myHero.mana / myHero.maxMana >= harassMenu.Mana:Value() / 100
        local distance = myHero.pos:DistanceTo(target.pos)
        
		if harassMenu.UseQW:Value() then 
			if myHero:GetSpellData(_W).level == 0 then
				if distance < 650 and harassMenu.UseQ:Value() and Core:Ready(_Q) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
					self:CastQ(target.pos)
					return
				end	
			else
				if distance < 650 and Core:Ready(_Q) and Core:Ready(_W) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
					self:CastQ(target.pos)
					return
				end
			end	
		else
			if distance < 650 and harassMenu.UseQ:Value() and Core:Ready(_Q) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
				self:CastQ(target.pos)
				return
			end			
        end
		
		if harassMenu.UseW:Value() and distance < 1100 and Core:Ready(_W) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
			local castPos = self:FindBestQiyanaWPos()

			if target.pos:DistanceTo(castPos) < distance then
				self:CastW(castPos)
				return
			end
        end

		if Core:HasBuff(myHero, "qiyanawenchantedbuff") and distance < 710 and Core:Ready(_Q) then
			self:CastQ(target.pos)
		end			
	end
end	

function Qiyana:Clear()
    for i = 1, Game.MinionCount() do
    	local minion = Game.Minion(i)
    	local distance = myHero.pos:DistanceTo(minion.pos)

        if distance < 1200 and minion.team == Core:TEAM_ENEMY and Core:IsValid(minion) then
        	local clearMenu = self.Menu.Clear
            local mana_ok = myHero.mana / myHero.maxMana >= clearMenu.Mana:Value() / 100
            
            if clearMenu.UseE:Value() and mana_ok and distance < 650 and Core:Ready(_E) and not Core:IsUnderTurret(minion) then
				self:CastE(minion)
				return
            end

            if clearMenu.UseE:Value() and mana_ok and distance < 650 and Core:Ready(_E) and Core:IsUnderTurret(minion) and Core:AllyMinionUnderTower() then
				self:CastE(minion)
				return
            end		
			
			if myHero:GetSpellData(_W).level == 0 then
				if clearMenu.UseQ:Value() and mana_ok and distance < 650 and Core:Ready(_Q) then
					self:CastQ(minion,pos)
					return
				end
			else	
				if clearMenu.UseQ:Value() and mana_ok and distance < 650 and Core:Ready(_Q) and Core:Ready(_W) then
					self:CastQ(minion,pos)
					return
				end
			end
			
            if clearMenu.UseW:Value() and mana_ok and distance < 1100 and Core:Ready(_W) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then	
				local castPos = self:FindBestQiyanaWPos()

				if not Core:IsUnderTurret(minion) then
					if minion.pos:DistanceTo(castPos) < distance then
						self:CastW(castPos)
						return
					end
				elseif Core:IsUnderTurret(minion) and Core:AllyMinionUnderTower() then
					self:CastW(castPos)
					return
				end
            end	

			if Core:HasBuff(myHero, "qiyanawenchantedbuff") and distance < 710 and Core:Ready(_Q) then
				self:CastQ(minion.pos)
				return
			end				
        end
    end
end

function Qiyana:JungleClear()
    for i = 1, Game.MinionCount() do
    	local minion = Game.Minion(i)
    	local distance = myHero.pos:DistanceTo(minion.pos)
    	local jungleMenu = self.Menu.JClear

        if distance < 1200 and minion.team == Core:TEAM_JUNGLE and Core:IsValid(minion) then
            local mana_ok = myHero.mana / myHero.maxMana >= jungleMenu.Mana:Value() / 100
            
            if jungleMenu.UseE:Value() and mana_ok and distance < 650 and Core:Ready(_E) then
				self:CastE(minion)
				return
            end		
			
			if myHero:GetSpellData(_W).level == 0 then			
				if jungleMenu.UseQ:Value() and mana_ok and distance < 650 and Core:Ready(_Q) then
					self:CastQ(minion.pos)
					return
				end
			else
				if jungleMenu.UseQ:Value() and mana_ok and distance < 650 and Core:Ready(_Q) and Core:Ready(_W) then
					self:CastQ(minion.pos)
					return
				end	
			end
			
			if jungleMenu.UseW:Value() and distance < 1100 and Core:Ready(_W) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
				local castPos = self:FindBestQiyanaWPos()

				if minion.pos:DistanceTo(castPos) < distance then
					self:CastW(castPos)
					return
				end		
            end

			if Core:HasBuff(myHero, "qiyanawenchantedbuff") and distance < 710 and Core:Ready(_Q) then
				self:CastQ(minion.pos)
				return
			end				
        end
    end
end

function Qiyana:KillSteal()	
	local target = Core:GetTarget(800)

	if target and Core:IsValid(target) then 
		local QDmg = getdmg("Q", target, myHero, 1)
		local Q2Dmg = getdmg("Q", target, myHero, 2)
		local EDmg = getdmg("E", target, myHero)
		local WPassiveDmg = getdmg("W", target, myHero)
		local EWDmg = (EDmg + WPassiveDmg)	
		local HP = (target.health + (target.hpRegen * 2))
		local ksMenu = self.Menu.ks
		local distance = myHero.pos:DistanceTo(target.pos)
		
		if QDmg-20 >= HP and ksMenu.UseQ:Value() and distance < 650 and Core:Ready(_Q) and not Core:HasBuff(myHero, "qiyanawenchantedbuff") then
			self:CastQ(target.pos)
			return
        end
		
		if QDmg-20 >= HP and ksMenu.UseQ:Value() and distance < 710 and Core:Ready(_Q) and Core:HasBuff(myHero, "qiyanawenchantedbuff") and not myHero:GetSpellData(_Q).name == "QiyanaQ_Rock" then
			self:CastQ(target.pos)
			return
        end
		
		if Q2Dmg-20 >= HP and ksMenu.UseQ2:Value() and distance < 710 and Core:Ready(_Q) and myHero:GetSpellData(_Q).name == "QiyanaQ_Rock" then
			self:CastQ(target.pos)
			return	
        end
		
		if EWDmg-20 >= HP and ksMenu.UseE:Value() and distance < 650 and Core:Ready(_E) then
			if Core:HasBuff(myHero, "qiyanawenchantedbuffhaste") then
				self:CastE(target)
				return
			end
		end
	end	
end

function Qiyana:CastUlt()
	for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        local distance = myHero.pos:DistanceTo(hero.pos)

		if distance < 1100 and hero.team == TEAM_ENEMY and Core:IsValid(hero) and self.Menu.Combo.UseR:Value() and Core:Ready(_R) then
			if distance < 875 then
				if Core:CheckWall(myHero.pos, hero.pos, 400) then
					Core:SetAttack(false)
					self:CastR(hero.pos)
					Core:SetAttack(true)

					return
				end				
			end
		
			for i, tower in pairs(self:IsUltRangeTurret(hero)) do				
				if tower and myHero.pos:DistanceTo(tower.pos) < 875 then
					Core:SetAttack(false)
					self:CastR(tower.pos)
					Core:SetAttack(true)
					return
				end		
			end
		end	
	end
end

--///////////////////////////////////////////////////////////
--//////////////////////////// Events
--///////////////////////////////////////////////////////////

function Qiyana:Tick()
	if Core:MyHeroNotReady() then return end

	local Mode = Core:GetMode()

	if Mode == "Combo" then
		self:Combo()
		self:CastUlt()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
	end	

	self:KillSteal()
end

function Qiyana:Draw()
	if myHero.dead then return end

	--local textPos = myHero.pos:To2D()	
	--if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		--Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	--end  
	
	if self.Menu.Drawing.DrawR:Value() and Core:Ready(_R) then
		Draw.Circle(myHero, 875, 1, Draw.Color(255, 225, 255, 10))
	end   

	if self.Menu.Drawing.DrawQ:Value() and Core:Ready(_Q) then
		if Core:HasBuff(myHero, "qiyanawenchantedbuff") then
			Draw.Circle(myHero, 710, 1, Draw.Color(225, 225, 0, 10))
		else
			Draw.Circle(myHero, 650, 1, Draw.Color(225, 225, 0, 10))
		end	
	end

	if self.Menu.Drawing.DrawE:Value() and Core:Ready(_E) then
		Draw.Circle(myHero, 650, 1, Draw.Color(225, 225, 125, 10))
	end

	if self.Menu.Drawing.DrawW:Value() and Core:Ready(_W) then
		Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 125, 10))
	end
end

function Qiyana:OnLoad()
	self:loadMenu()
	self:loadCallbacks()
end

Qiyana:OnLoad()

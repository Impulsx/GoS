class "AutoLvL"

function AutoLvL:__init()		
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)	
end

function AutoLvL:LoadMenu()	
	self.Menu = MenuElement({type = MENU, id = "AutoLvL", name = "PussyAutoLevel"})
	
	self.Menu:MenuElement({type = MENU, id = "lvl", name = "Simble AutoLevelSpells"})
	self.Menu.lvl:MenuElement({id = "on", name = "Use AutoLevel [Start LvL 2]", value = true})	
	self.Menu.lvl:MenuElement({id = "start", name = "Order", value = 1, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})
			
end

function AutoLvL:Tick()
	if self.Menu.lvl.on:Value() then
		self:AutoLevel()
	end	
end

function AutoLvL:AutoLevel()
	--local levelUP = false
	if not levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts

		if actualLevel == 18 and levelPoints == 0 or actualLevel == 1 then return end

		if levelPoints > 0 then
			local mode = self.Menu.lvl.start:Value()
			if mode == 1 then
				skillingOrder = {'Q','W','E','Q','Q','R','Q','W','Q','W','R','W','W','E','E','R','E','E'}
			elseif mode == 2 then
				skillingOrder = {'W','E','Q','W','W','R','W','E','W','E','R','E','E','Q','Q','R','Q','Q'}
			elseif mode == 3 then
				skillingOrder = {'E','Q','W','E','E','R','E','Q','E','Q','R','Q','Q','W','W','R','W','W'}
			elseif mode == 4 then
				skillingOrder = {'E','W','Q','E','E','R','E','W','E','W','R','W','W','Q','Q','R','Q','Q'}
			elseif mode == 5 then
				skillingOrder = {'W','Q','E','W','W','R','W','Q','W','Q','R','Q','Q','E','E','R','E','E'}
			elseif mode == 6 then
				skillingOrder = {'Q','E','W','Q','Q','R','Q','E','Q','E','R','E','E','W','W','R','W','W'}				
			end	

			local QL, WL, EL, RL = 0, 0, 0, myHero.charName == "Karma" and 1 or 0

			for i = 1, actualLevel do
				if skillingOrder[i] == "Q" then 		
					QL = QL + 1
				elseif skillingOrder[i] == "W" then		
					WL = WL + 1
				elseif skillingOrder[i] == "E" then 	
					EL = EL + 1
				elseif skillingOrder[i] == "R" then		
					RL = RL + 1
				end
			end

			local diffR = myHero:GetSpellData(_R).level - RL < 0
			local lowest = 99
			local spell
			local lowHK_Q = myHero:GetSpellData(_Q).level - QL
			local lowHK_W = myHero:GetSpellData(_W).level - WL
			local lowHK_E = myHero:GetSpellData(_E).level - EL

			if lowHK_Q < lowest then
				lowest = lowHK_Q
				spell = HK_Q
			end

			if lowHK_W < lowest then
				lowest = lowHK_W
				spell = HK_W
			end

			if lowHK_E < lowest then
				lowest = lowHK_E
				spell = HK_E
			end

			if diffR then
				spell = HK_R
			end

			if spell then
				levelUP = true

				DelayAction(function()
					Control.KeyDown(HK_LUS)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					Control.KeyUp(HK_LUS)

					DelayAction(function()
						levelUP = false
					end, .25)
				end, 0.7)
			end
		end
	end
end

function OnLoad()
	AutoLvL()
end

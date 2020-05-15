local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function GetEnemyHeroes()
	return Enemies
end

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, GameHeroCount() do 
	local hero = GameHero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end 

local function CanUse(spell)
	local Mana = 	myHero:GetSpellData(_Q).mana +
					myHero:GetSpellData(_W).mana +
					myHero:GetSpellData(_E).mana +
					myHero:GetSpellData(_R).mana
    return myHero:GetSpellData(spell).level > 0 and Mana <= myHero.mana
end

local Qrange = (50 + 25 * myHero:GetSpellData(_Q).level) + 200
local SpellsReady = false

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})  
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"}) 		
	
	--Prediction
	--Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	--Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	--Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	
	--[[QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1200, Speed = 1600, Collision = false
	}
	
	QspellData = {speed = 1600, range = 1200, delay = 0.25, radius = 60, collision = {}, type = "linear"}	]]	
  	
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
		DrawCircle(myHero, 325, 1, DrawColor(225, 225, 0, 10))
		end	
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 350, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 625, 1, DrawColor(225, 225, 125, 10))
		end	
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		CheckComboMode()	
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end
	
	if 	CanUse(_Q) and CanUse(_W) and CanUse(_E) and CanUse(_R) then
		SpellsReady = true
	end			
end

function CheckComboMode()
	local Enemies = GetEnemyCount(1500, myHero)
	if SpellsReady then
		if Enemies >= 2 then
			print("Combo2")		
			Combo2()
		else
			print("Combo1")		
			Combo1()
		end
	else
		print("Combo3")
		Combo3()
	end	
end

function Combo1()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) then
		local casted = false	
		local AA = false
		local spell = myHero.activeSpell
		if spell and spell.isAutoAttack and spell.spellWasCast then
			AA = true
		end

		if not Ready(_R) then
			SpellsReady = false
		end

		if myHero.pos:DistanceTo(target.pos) < 625 then
			
			if Ready(_E) then
				ControlCastSpell(HK_E, target)
			end

			if Ready(_W) and not Ready(_E) then				
				if AA then
					ControlCastSpell(HK_W, target.pos)
					AA = false
				end	
			end
		
			if Ready(_Q) and not Ready(_W) then
				if AA then
					ControlCastSpell(HK_Q)
					AA = false
				end
			end	

			if Ready(_R) and not Ready(_Q) then				
				SetAttack(false)
				casted = true
				ControlCastSpell(HK_R)
				DelayAction(function()
				SetAttack(true)
				casted = false
				end,2)
			end					
		end	
	end	
end	

function Combo2()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) then
		local buff = HasBuff(myHero, "monkeykingspinrecast")
		local castR = false
		local casted = false
		if not Ready(_R) then
			SpellsReady = false
		end

		if myHero.pos:DistanceTo(target.pos) < 625 then
			
			if Ready(_E) then
				ControlCastSpell(HK_E, target)
			end

			if Ready(_W) and not Ready(_E) then				
				ControlCastSpell(HK_W, target.pos)
			end
			
			if Ready(_R) and not Ready(_W) and not casted then				
				SetAttack(false)
				casted = true
				ControlCastSpell(HK_R)
				castR = true				
				DelayAction(function()
				SetAttack(true)
				casted = false
				end, 2.0)
			end	

			if Ready(_Q) and castR then				
				ControlCastSpell(HK_Q)
				castR = false
			end			
			
			if buff and not Ready(_Q) and not casted then 
				SetAttack(false)
				casted = true
				ControlCastSpell(HK_R)
				DelayAction(function()
				SetAttack(true)
				casted = false
				end, 2.0)
			end			
		end	
	end	
end

function Combo3()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) then
		local AA = false
		local spell = myHero.activeSpell
		if spell and spell.isAutoAttack and spell.spellWasCast then
			AA = true
		end
			
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 625 then
			ControlCastSpell(HK_E, target)
		end

		if Ready(_W) and myHero.pos:DistanceTo(target.pos) < 300 then				
			if AA then
				ControlCastSpell(HK_W, target.pos)
				AA = false
			end	
		end
	
		if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < Qrange then
			if AA then
				ControlCastSpell(HK_Q)
				AA = false
			end
		end	
	end	
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 700 and minion.team == TEAM_ENEMY and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < Qrange and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and Ready(_Q) then
				ControlCastSpell(HK_Q)	
            end
                      
			if myHero.pos:DistanceTo(minion.pos) < 625 and Ready(_E) and Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				ControlCastSpell(HK_E, minion)   
            end
			
			if myHero.pos:DistanceTo(minion.pos) < 300 and Ready(_W) and Menu.Clear.UseW:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				ControlCastSpell(HK_W, minion.pos)   
            end			
        end
    end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 700 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < Qrange and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and Ready(_Q) then
				ControlCastSpell(HK_Q)
            end
                      
			if myHero.pos:DistanceTo(minion.pos) < 625 and Ready(_E) and Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				ControlCastSpell(HK_E, minion)    
            end
			
			if myHero.pos:DistanceTo(minion.pos) < 300 and Ready(_W) and Menu.Clear.UseW:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				ControlCastSpell(HK_W, minion.pos)    
            end			
        end
    end
end

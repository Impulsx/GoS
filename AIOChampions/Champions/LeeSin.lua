function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function IsUnderTurret(unit)
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
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

function GetInventorySlotItem(itemID, target)
	local target = myHero
	for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }) do
		if target:GetItemData(j).itemID == itemID and (target:GetSpellData(j).ammo > 0 or target:GetItemData(j).ammo > 0) then return j end
	end
	return nil
end

function WardsAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i = 1, Game.WardCount() do
		local ward = Game.Ward(i)
        if ward and ward.isAlly and GetDistanceSqr(pos, ward.pos) < (range * range) and IsValid(ward) then
            N = N + 1
        end
    end
    return N
end

function GetAllysRange(unit) 
    for i = 1, Game.HeroCount() do 
		local ally = Game.Hero(i)
		if ally.isAlly and ally ~= myHero and ally.pos:DistanceTo(unit.pos) <= 1600 and myHero.pos:DistanceTo(unit.pos) <= 650 and IsValid(ally) then
			return true
		end
	end
	return false
end

function GetAllyTurretRange(unit) 
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
		if turret.isAlly and not turret.dead and turret.pos:DistanceTo(unit.pos) <= 1600 and myHero.pos:DistanceTo(unit.pos) <= 650 then
			return true
		end
	end
	return false
end

function GetAllyTurret() 
	Allyturret = {}
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
		if turret.isAlly and not turret.dead then
			table.insert(Allyturret, turret)
		end
	end
	return Allyturret
end

function EnemyHeroes()
	return Enemies
end

function GetAllyHeroes()
    return Allies
end

function LoadScript()
	_wards = {2055, 2049, 2050, 2301, 2302, 2303, 3340, 3361, 3362, 3711, 1408, 1409, 1410, 1411, 2043, 3350, 3205, 3207, 2045, 2044, 3154, 3160}
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})	
	Menu:MenuElement({name = " ", drop = {"WIP Version,,, not finished !!!"}})	

	--AutoW 
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	Menu.AutoW:MenuElement({id = "UseW", name = "Safe Ally/Self", value = true})
	Menu.AutoW:MenuElement({id = "myHeal", name = "min Hp self", value = 40, min = 0, max = 100, identifier = "%"})	
	Menu.AutoW:MenuElement({id = "allyHeal", name = "min Hp Ally", value = 30, min = 0, max = 100, identifier = "%"})	

	--AutoR
	Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoR SafeLife"})
	Menu.AutoR:MenuElement({id = "UseR", name = "Auto[R] safe your Life", value = true})
	Menu.AutoR:MenuElement({id = "Heal", name = "min Hp", value = 20, min = 0, max = 100, identifier = "%"})	
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({name = " ", drop = {"AutoSwitch Combo: Standart / InsecTower / InsecAlly"}})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "Auto", name = "AutoSwitch ComboModes", value = true})	
	Menu.Combo:MenuElement({id = "Gap", name = "Gapclose[WardJump]", value = true})
	
	Menu.Combo:MenuElement({id = "Set", name = "Gapclose Settings", type = MENU})		
	Menu.Combo.Set:MenuElement({id = "minRange", name = "MinCastDistance if not Ready[Q]", value = 600, min = 600, max = 1000, step = 50})	
	Menu.Combo.Set:MenuElement({id = "maxRange", name = "MaxCastDistance if not Ready[Q]", value = 1000, min = 1000, max = 1500, step = 50})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Energy to Harass", value = 40, min = 0, max = 100, identifier = "%"})
   
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Clear:MenuElement({id = "Heal", name = "min selfHp Use[W]", value = 70, min = 0, max = 100, identifier = "%"})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 3, min = 1, max = 6, step = 1, identifier = "Minion/s"})  		
	Menu.Clear:MenuElement({id = "Mana", name = "Min Energy to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Energy to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})				
	Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	Menu.ks:MenuElement({id = "UseQR", name = "[Q]+[R]", value = true})		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q1]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Insec
	Menu:MenuElement({id = "Modes", name = "WardJump", type = MENU}) 
	Menu.Modes:MenuElement({id = "Insec", name = "WardJump", key = string.byte("A")})
	
	
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 65, Range = 1200, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
	}
  	
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
		Draw.Circle(myHero, 375, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) and myHero:GetSpellData(_Q).name == "BlindMonkQOne" then
		Draw.Circle(myHero, 1200, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) and myHero:GetSpellData(_E).name == "BlindMonkEOne"  then
		Draw.Circle(myHero, 350, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 700, 1, Draw.Color(225, 225, 125, 10))
		end
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end	
	end)		
end

function Tick()
if MyHeroNotReady() then return end
	local Mode = GetMode()
		if Mode == "Combo" then
			if Ready(_R) and Menu.Combo.Auto:Value() then
				for i, hero in pairs(EnemyHeroes()) do
					if GetAllyTurretRange(hero) then
						InsecTower()
					elseif GetAllysRange(hero) then
						InsecAlly()
					else
						Combo()
						WardJump()
					end	
				end
			else
				Combo()
				WardJump()
			end	
			
		elseif Mode == "Harass" then
			Harass()
		elseif Mode == "Clear" then
			Clear()
			JungleClear()
		elseif Mode == "Flee" then
			WardJump()	
		
		end
	KillSteal()
	AutoR()
	AutoW()
end

local WardTicks = 0;
local LastCast = 0

function Cast(spell,pos)
	Control.SetCursorPos(pos)
	Control.KeyDown(spell)
	Control.KeyUp(spell)
end

function WardJump(key, param)
	local mouseRadius = 200
	if Ready(_W) and myHero:GetSpellData(_W).name == "BlindMonkWOne" then
		local wardslot = nil
		for t, VisionItem in pairs(_wards) do
			if not wardslot then
				wardslot = GetInventorySlotItem(VisionItem)
			end
		end
		if Menu.Modes.Insec:Value() then	
			if wardslot then
				local ward,dis = WardM()
				if ward~=nil and dis~=nil and dis<mouseRadius then
					if myHero.pos:DistanceTo(ward.pos) <=600 then
						Cast(HK_W, ward.pos)
					end
				elseif GetTickCount() > LastCast + 200 then
					LastCast = GetTickCount()
					local Data = myHero:GetSpellData(wardslot);
					if Data.ammo > 0 then
						if myHero.pos:DistanceTo(mousePos) < 600 then
							Cast(ItemHotKey[wardslot], mousePos)
							Cast(HK_W, mousePos)
						else
							newpos = myHero.pos:Extended(mousePos,600)
							Cast(ItemHotKey[wardslot], newpos)
							Cast(HK_W, newpos)
						end	
					end
				end
			end
		end
		local target = GetTarget(1300)     	
		if target == nil then return end
		if wardslot and Menu.Combo.Gap:Value() and not Ready(_Q) then
			if myHero.pos:DistanceTo(target.pos) <= Menu.Combo.Set.maxRange:Value() and myHero.pos:DistanceTo(target.pos) >= Menu.Combo.Set.minRange:Value() then		
				local ward,dis = WardM()
				if ward~=nil and dis~=nil and dis<mouseRadius then
					if myHero.pos:DistanceTo(ward.pos) <=600 then
						Cast(HK_W, ward.pos)
					end
				elseif GetTickCount() > LastCast + 200 then
					LastCast = GetTickCount()
					local Data = myHero:GetSpellData(wardslot);
					if Data.ammo > 0 then
						newpos = myHero.pos:Extended(target.pos,600)
						Cast(ItemHotKey[wardslot], newpos)
						Cast(HK_W, newpos)
					end	
				end
			end
		end
	end
end

function WardM()
local closer, near = math.huge, nil
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i)
		if ward~=nil then
			if (ward.isAlly and not ward.isMe) then
				if not IsValid(ward) and myHero.pos:DistanceTo(ward.pos) < 700 then
					local CurrentDistance = ward.pos:DistanceTo(mousePos)
					if CurrentDistance < closer then
						closer = CurrentDistance
						near = ward
					end
				end
			end
		end
	end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion~=nil then
			if (minion.isAlly) then
				if not IsValid(minion) and myHero.pos:DistanceTo(minion.pos) < 700 then
					local CurrentDistance = minion.pos:DistanceTo(mousePos)
					if CurrentDistance < closer then
						closer = CurrentDistance
						near = minion
					end
				end
			end
		end
	end
	
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero~=nil then
			if (hero.isAlly and not hero.isMe) then
				if not IsValid(hero) and myHero.pos:DistanceTo(hero.pos) < 700 then
					local CurrentDistance = hero.pos:DistanceTo(mousePos)
					if CurrentDistance < closer then
						closer = CurrentDistance
						near = hero
					end
				end
			end
		end
	end
	return near, closer
end

function InsecTower()
local target = GetTarget(1500)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
	local Data = myHero:GetSpellData(Item);	
		if IsValid(target) then
		if Item and Data.ammo == 0 then
			Combo() return end		
			
			for i, tower in pairs(GetAllyTurret()) do			
				if WardsAround(target, 400) == 0 and Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 250 and Item and Data.ammo > 0 then 
		
					if tower.pos:DistanceTo(target.pos) <= 1600 then
						local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (300)
						Start = InsecStart(CastPos)
					end				
				end
			end			
			

			
			if myHero.pos:DistanceTo(target.pos) < 500 and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 350 and Ready(_E) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" and myHero:GetSpellData(_E).name == "BlindMonkEOne" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) then
				Control.CastSpell(HK_R, target)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end	
		end
	end
end

function InsecAlly()
local target = GetTarget(1500)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
	local Data = myHero:GetSpellData(Item);	
		if IsValid(target) then
		
		if Item and Data.ammo == 0 then
			Combo() return end
			
			for i, ally in pairs(GetAllyHeroes()) do			
				if WardsAround(target, 400) == 0 and Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 250 and Item and Data.ammo > 0 then 
		
					if ally.pos:DistanceTo(myHero.pos) <= 1300 and IsValid(ally) and ally.pos:DistanceTo(target.pos) <= 1500 then
						local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (300)
						InsecStart(CastPos)
					end				
				end
			end
			
			if myHero.pos:DistanceTo(target.pos) < 500 and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 350 and Ready(_E) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" and myHero:GetSpellData(_E).name == "BlindMonkEOne" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) then
				Control.CastSpell(HK_R, target)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end	
		end
	end
end

function InsecStart(CastPos)
local target = GetTarget(1500)     	
if target == nil then return end
local wardslot = nil
	for t, VisionItem in pairs(_wards) do
		if not wardslot then
			wardslot = GetInventorySlotItem(VisionItem)
		elseif GetTickCount() > LastCast + 200 then
			LastCast = GetTickCount()
			if myHero.pos:DistanceTo(mousePos) < 1300 then		
				if target and Ready(_R) and wardslot then


					if Vector(myHero.pos):DistanceTo(CastPos)<=625 then
						if Ready(_W) and myHero:GetSpellData(_W).name == "BlindMonkWOne" then
							SetMovement(false)
							Control.SetCursorPos(CastPos)
							Cast(ItemHotKey[wardslot], CastPos)
							Cast(HK_W, CastPos)	
							SetMovement(true)
						end
					end
				end
			end
		end
	end
end

function AutoR()
local target = GetTarget(500)     	
if target == nil then return end
	if IsValid(target) then
		if myHero.health/myHero.maxHealth <= Menu.AutoR.Heal:Value()/100 and Menu.AutoR.UseR:Value() and Ready(_R) then
			if myHero.pos:DistanceTo(target.pos) <= 375 then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end	
end

function AutoW()
local target = GetTarget(2000)     	
if target == nil then return end	
	if IsValid(target) then	
		if Menu.AutoW.UseW:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= Menu.AutoW.myHeal:Value()/100 then
				Control.CastSpell(HK_W, myHero)
				if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
					Control.CastSpell(HK_W)
				end
			end
			for i, ally in pairs(GetAllyHeroes()) do
				if myHero.pos:DistanceTo(ally.pos) <= 700 and IsValid(ally) and ally.health/ally.maxHealth <= Menu.AutoW.allyHeal:Value()/100 then
					Control.CastSpell(HK_W, ally)
					if HasBuff(ally, "blindmonkwoneshield") then
						Control.CastSpell(HK_W)
					end
				end
			end
		end
	end	
end

function Combo()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target) then
		
		if Menu.Combo.UseQ:Value() and Ready(_Q) then
			if HasBuff(target, "BlindMonkQOne") then
				if myHero.pos:DistanceTo(target.pos) <= 1300 then
					Control.CastSpell(HK_Q)
				end	
					
			else 
				
				if myHero.pos:DistanceTo(target.pos) <= 1200 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end	
				end
			end	
		end
		
		if Menu.Combo.UseE:Value() and Ready(_E) then
			if myHero:GetSpellData(_E).name == "BlindMonkETwo" then 
				if myHero.pos:DistanceTo(target.pos) <= 500 then
					Control.CastSpell(HK_E)
				end	
				
			else
				
				if myHero.pos:DistanceTo(target.pos) <= 350 then	
					Control.CastSpell(HK_E)
				end	
			end
		end
	end	
end	

function Harass()
local target = GetTarget(1500)
if target == nil then return end
	local Mana = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100	
	if IsValid(target) and Mana then
 	
		if Menu.Harass.UseQ:Value() and Ready(_Q) then
			if HasBuff(target, "BlindMonkQOne") then
				if myHero.pos:DistanceTo(target.pos) <= 1300 then
					Control.CastSpell(HK_Q)
				end	
					
			else 
				
				if myHero.pos:DistanceTo(target.pos) <= 1200 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end	
				end
			end	
		end
		
		if Menu.Harass.UseE:Value() and Ready(_E) then
			if myHero:GetSpellData(_E).name == "BlindMonkETwo" then 
				if myHero.pos:DistanceTo(target.pos) <= 500 then
					Control.CastSpell(HK_E)
				end	
				
			else
				
				if myHero.pos:DistanceTo(target.pos) <= 350 then	
					Control.CastSpell(HK_E)
				end	
			end
		end	
	end	
end	

function Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if myHero.pos:DistanceTo(minion.pos) <= 1400 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
			
			if Menu.Clear.UseQ:Value() and Ready(_Q) then
			
				if HasBuff(minion, "BlindMonkQOne") then 
					if myHero.pos:DistanceTo(minion.pos) <= 1300 then
						Control.CastSpell(HK_Q)
					end
					
				else
					if myHero.pos:DistanceTo(minion.pos) <= 1200 and myHero.pos:DistanceTo(minion.pos) >= 500 then
						Control.CastSpell(HK_Q, minion.pos)
					end	
				end
			end

			local passiveBuff = HasBuff(myHero,"blindmonkpassive_cosmetic")
			if passiveBuff then return end
            
			if Menu.Clear.UseW:Value() and Ready(_W) then
			
				if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
					Control.CastSpell(HK_W)
			
				else
					
					if myHero.pos:DistanceTo(minion.pos) <= 500 and myHero.health/myHero.maxHealth <= Menu.Clear.Heal:Value()/100 then
						Control.CastSpell(HK_W, myHero)
					end
				end
			end
            
			if Menu.Clear.UseE:Value() and Ready(_E) then
			
				if myHero:GetSpellData(_E).name == "BlindMonkETwo" then
					if GetMinionCount(500, myHero) >= Menu.Clear.UseEM:Value() then
						Control.CastSpell(HK_E)
					end	
					
				else
					
					if GetMinionCount(350, myHero) >= Menu.Clear.UseEM:Value() then
						Control.CastSpell(HK_E)
					end	
				end
			end
        end
    end
end

function JungleClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if myHero.pos:DistanceTo(minion.pos) <= 1400 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
            
			if Menu.JClear.UseQ:Value() and Ready(_Q) then
			
				if myHero:GetSpellData(_Q).name == "BlindMonkQTwo" then 
					if myHero.pos:DistanceTo(minion.pos) <= 1300 then
						Control.CastSpell(HK_Q)
					end
				else
					
					if myHero.pos:DistanceTo(minion.pos) <= 1200 then
						Control.CastSpell(HK_Q, minion.pos)
					end	
				end
			end
			
			
			local passiveBuff = HasBuff(myHero,"blindmonkpassive_cosmetic")
			if passiveBuff then return end
           
			if Menu.JClear.UseW:Value() and Ready(_W) then
			
				if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
					Control.CastSpell(HK_W)		    
			
				else
					if myHero.pos:DistanceTo(minion.pos) <= 500 then
						Control.CastSpell(HK_W, myHero)
					end	
				end
			end
            
			if Menu.JClear.UseE:Value() and Ready(_E) then
			
				if myHero:GetSpellData(_E).name == "BlindMonkETwo" then
					
					if GetMinionCount(500, myHero) >= 1 then
						Control.CastSpell(HK_E)
					end	
						
				else
				
					if GetMinionCount(350, myHero) >= 1 and not Ready(_W) then
						Control.CastSpell(HK_E)
					end	
				end
			end
        end
    end
end

function KillSteal()
local target = GetTarget(1500)     	
if target == nil then return end
	
	if IsValid(target) then
		local hp = target.health
		local QDmg = (getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2))
		local EDmg = getdmg("E", target, myHero)
		local RDmg = getdmg("R", target, myHero)
		local QRDmg = QDmg + RDmg
		
		if IsUnderTurret(target) then return end
			
			if QRDmg >= hp and Menu.ks.UseQR:Value() and Ready(_Q) and Ready(_R) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if myHero.pos:DistanceTo(target.pos) <= 1200 and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
				if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
					Control.CastSpell(HK_Q)
				end	
				if myHero.pos:DistanceTo(target.pos) <= 350 and HasBuff(myHero, "BlindMonkQTwoDash") then
					Control.CastSpell(HK_R, target)
				end
			end
			
			if QDmg >= hp and Menu.ks.UseQ:Value() and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if myHero.pos:DistanceTo(target.pos) <= 1200 and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
				if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
					Control.CastSpell(HK_Q)
				end	
			end

		if myHero.pos:DistanceTo(target.pos) <= 350 and EDmg >= hp then
			if Menu.ks.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E)
			end
			if myHero:GetSpellData(_E).name == "BlindMonkETwo" and myHero.pos:DistanceTo(target.pos) <= 500 then
				Control.CastSpell(HK_E)
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 375 and RDmg >= hp and Menu.ks.UseR:Value() and Ready(_R) then
			Control.CastSpell(HK_R, target)
			
		end
	end
end	


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

function GetAllyHeroes()
    return Allies
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
	
	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ Immobile"})
	Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto[Q] + Auto[W]SavePos", value = true})

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
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
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
	Menu:MenuElement({id = "Modes", name = "Insec Mode", type = MENU}) 
	Menu.Modes:MenuElement({id = "Modes1", name = "Insec Mode 1", type = MENU})	
	Menu.Modes.Modes1:MenuElement({name = " ", drop = {"Fast Near Insec = Ward+W+R+Q1+Q2"}})
	Menu.Modes.Modes1:MenuElement({name = " ", drop = {"Burst Near Insec = Ward+W+E1+R+Q1+Q2+E2"}})	
	Menu.Modes.Modes1:MenuElement({name = " ", drop = {"Fast Far Insec = Q1+Q2+Ward+W+R"}})
	Menu.Modes.Modes1:MenuElement({name = " ", drop = {"Burst Far Insec = Q1+Q2+Ward+W+E1+E2+R"}})	
	Menu.Modes.Modes1:MenuElement({id = "Logic", name = "ToggleKey Near / Far Insec", key = string.byte("I"), toggle = true})
	Menu.Modes.Modes1:MenuElement({id = "Burst", name = "ToggleKey Fast / Burst Insec", key = string.byte("O"), toggle = true})
	Menu.Modes.Modes1:MenuElement({id = "Item", name = "Use Tiamat / Hydra BurstMode ", value = true})
	Menu.Modes.Modes1:MenuElement({id = "Insec", name = "Insec Activate Key", key = string.byte("T")})
	Menu.Modes.Modes1:MenuElement({id = "Draw", name = "Draw Insec Line / Circle", value = true})
	Menu.Modes.Modes1:MenuElement({id = "Type", name = "Draw Option", value = 1, drop = {"Always", "Pressed Insec Key"}})
	
	Menu.Modes:MenuElement({id = "Modes2", name = "Insec Mode 2", type = MENU})
	Menu.Modes.Modes2:MenuElement({id = "Insec", name = "WardJump", key = string.byte("A")})
	
	Menu.Modes:MenuElement({id = "Modes3", name = "Insec Mode 3", type = MENU})
	Menu.Modes.Modes3:MenuElement({id = "Insec", name = "If Killable[Q1+E+R+Q2+E2]", value = true})
	Menu.Modes.Modes3:MenuElement({id = "Draw", name = "Draw Killable Text", value = true})	
	
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
		
		
		if Menu.Modes.Modes1.Burst:Value() then
			Draw.Text("Fast Insec", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 000, 255, 000))
		else
			Draw.Text("Burst Insec", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 000, 255, 000))
		end	
		
		if Menu.Modes.Modes1.Logic:Value() then
			Draw.Text("Near Insec", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
		else
			Draw.Text("Far Insec", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))	
		end
		
		if Menu.Modes.Modes1.Draw:Value() then
			
			
			for v, spell in pairs(_wards) do
			local Item = GetInventorySlotItem(spell)	
			local Data = myHero:GetSpellData(Item);	
		
				if Item and Data.ammo > 0 and Ready(_Q) and Ready(_R) and Ready(_W) then
					for i = 1, Game.HeroCount() do
					local Hero = Game.Hero(i)
					local textPos = Hero.pos:To2D()
						if Menu.Modes.Modes1.Logic:Value() then	 
							
							if Menu.Modes.Modes1.Type:Value() == 2 and Menu.Modes.Modes1.Insec:Value() then 	
								if IsValid(Hero) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1300 then	
									local Vectori = Vector(myHero.pos - Hero.pos)
									local LS = LineSegment(myHero.pos, Hero.pos)
									LS:__draw()
									LSS = Circle(Point(Hero), Hero.boundingRadius)
									LSS:__draw()
									Draw.Text("Insec Mode", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
									Draw.Circle(myHero, 475, 1, Draw.Color(225, 225, 0, 0))
								end
							end	
							if Menu.Modes.Modes1.Type:Value() == 1 then
								if IsValid(Hero) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1300 then	
									local Vectori = Vector(myHero.pos - Hero.pos)
									local LS = LineSegment(myHero.pos, Hero.pos)
									LS:__draw()
									LSS = Circle(Point(Hero), Hero.boundingRadius)
									LSS:__draw()
									Draw.Text("Insec Mode", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
									Draw.Circle(myHero, 475, 1, Draw.Color(225, 225, 0, 0))
								end
							end	
						end
						
						if not Menu.Modes.Modes1.Logic:Value() then
							
							if Menu.Modes.Modes1.Type:Value() == 2 and Menu.Modes.Modes1.Insec:Value() then 	
								if IsValid(Hero) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1500 then								
									local Vectori = Vector(myHero.pos - Hero.pos)
									local LS = LineSegment(myHero.pos, Hero.pos)
									LS:__draw()
									LSS = Circle(Point(Hero), Hero.boundingRadius)
									LSS:__draw()
									Draw.Text("Insec Mode", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
									Draw.Circle(myHero, 1200, 1, Draw.Color(225, 225, 0, 0))
								end
							end	
							if Menu.Modes.Modes1.Type:Value() == 1 then
								if IsValid(Hero) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1500 then	
									local Vectori = Vector(myHero.pos - Hero.pos)
									local LS = LineSegment(myHero.pos, Hero.pos)
									LS:__draw()
									LSS = Circle(Point(Hero), Hero.boundingRadius)
									LSS:__draw()
									Draw.Text("Insec Mode", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
									Draw.Circle(myHero, 1200, 1, Draw.Color(225, 225, 0, 0))
								end
							end	
						end					
					end
				end
			end
		end
		local target = GetTarget(20000)
		if target == nil then return end	
		if IsValid(target) and Menu.Modes.Modes3.Draw:Value() then
			local hp = target.health	
			local QDmg = (getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2))
			local EDmg = getdmg("E", target, myHero)
			local RDmg = getdmg("R", target, myHero)
			local FullDmg = (QDmg + RDmg + EDmg)	
			if Ready(_Q) and Ready(_E) and Ready(_R) and FullDmg > hp then
				Draw.Text("Insec Kill", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
				Draw.Text("Insec Kill", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		
			end	
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end
	local Mode = GetMode()
		if Mode == "Combo" then
			Combo()
			WardJump()
		elseif Mode == "Harass" then
			Harass()
		elseif Mode == "Clear" then
			Clear()
			JungleClear()
		elseif Mode == "Flee" then
			WardJump()	
		
		end
	KillSteal()
	KillStealInsec()
	AutoQ()
	AutoR()
	AutoW()
	Activator()
	
	if Menu.Modes.Modes1.Insec:Value() then
		if Menu.Modes.Modes1.Logic:Value() then
			if Menu.Modes.Modes1.Burst:Value() then
				Insec1()
			else
				BurstInsec1()
			end	
		
		else	
			
			if Menu.Modes.Modes1.Burst:Value() then	
				Insec2()
			else
				BurstInsec2()
			end				
		end	
	end
end

local WardTicks = 0;
local LastCast = 0

function Cast(spell,pos)
	Control.SetCursorPos(pos)
	Control.KeyDown(spell)
	Control.KeyUp(spell)
end

function Activator()
local target = GetTarget(500)     	
if target == nil then return end	
local Tia, Rave, Tita = GetInventorySlotItem(3077), GetInventorySlotItem(3074), GetInventorySlotItem(3748)   
	if IsValid(target) and Menu.Modes.Modes1.Insec:Value() and Menu.Modes.Modes1.Item:Value() and not Menu.Modes.Modes1.Burst:Value() then
        
		if Tia and myHero.pos:DistanceTo(target.pos) <= 400 then
            Control.CastSpell(ItemHotKey[Tia])
        end
		
		if Rave and myHero.pos:DistanceTo(target.pos) <= 400 then
            Control.CastSpell(ItemHotKey[Rave])
        end
		
		if Tita and myHero.pos:DistanceTo(target.pos) <= 400 then
            Control.CastSpell(ItemHotKey[Tita])
        end		
	end
end	

function KillStealInsec()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	if IsValid(target) then
		local hp = target.health
		local QDmg = (getdmg("Q", target, myHero, 1) + getdmg("Q", target, myHero, 2))
		local EDmg = getdmg("E", target, myHero)
		local RDmg = getdmg("R", target, myHero)
		local FullDmg = (QDmg + RDmg + EDmg)
		if hp <= FullDmg and Menu.Modes.Modes3.Insec:Value() then
			if myHero.pos:DistanceTo(target.pos) < 500 and myHero:GetSpellData(_E).name == "BlindMonkETwo" and HasBuff(target, "BlindMonkRKick") then
				Control.CastSpell(HK_E)
			end	
			
			if myHero.pos:DistanceTo(target.pos) < 350 and Ready(_E) and myHero:GetSpellData(_E).name == "BlindMonkEOne" and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_E)
			end			
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Control.CastSpell(HK_R, target.pos)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 350 and not HasBuff(target, "BlindMonkQOne") and Ready(_Q) and pred.Hitchance >= 2 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkRKick") and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
		end				
	end
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
		if Menu.Modes.Modes2.Insec:Value() then	
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
		else
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

function Insec1()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
	local Data = myHero:GetSpellData(Item);	
		if IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
				Cast(HK_R, target.pos)
			end
						
			--local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and HasBuff(target, "BlindMonkRKick") and Ready(_Q) then
				Cast(HK_Q, target.pos)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
	
			for i, tower in pairs(GetAllyTurret()) do			
				if WardsAround(target, 400) == 0 and Ready(_R) and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 650 then 
					
		
					if tower.pos:DistanceTo(target.pos) <= 1600 then
						local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (150)
						InsecStart(CastPos)
					
					else
			
						for i, ally in pairs(GetAllyHeroes()) do
							if ally.pos:DistanceTo(myHero.pos) <= 1300 and IsValid(ally) and ally.pos:DistanceTo(target.pos) <= 1200 then
							local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (150)
								InsecStart(CastPos)
							end	
						end
					end				
				end
			end
		end
	end
end

function BurstInsec1()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
	local Data = myHero:GetSpellData(Item);	
		if IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) < 500 and HasBuff(myHero, "BlindMonkQTwoDash") and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 350 and Ready(_E) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" and myHero:GetSpellData(_E).name == "BlindMonkEOne" then
				Control.CastSpell(HK_E)
			end			
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Cast(HK_R, target.pos)
			end
						
			--local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and HasBuff(target, "BlindMonkRKick") and Ready(_Q) then
				Cast(HK_Q, target.pos)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
	
			for i, tower in pairs(GetAllyTurret()) do			
				if WardsAround(target, 400) == 0 and Ready(_R) and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 650 then 
					
		
					if tower.pos:DistanceTo(target.pos) <= 1600 then
						local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (150)
						InsecStart(CastPos)
					
					else
			
						for i, ally in pairs(GetAllyHeroes()) do
							if ally.pos:DistanceTo(myHero.pos) <= 1300 and IsValid(ally) and ally.pos:DistanceTo(target.pos) <= 1200 then
							local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (150)
								InsecStart(CastPos)
							end	
						end
					end				
				end
			end
		end
	end
end

function Insec2()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
	local Data = myHero:GetSpellData(Item);	
		if IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
				Cast(HK_R, target.pos)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) then
				Cast(HK_Q, pred.CastPosition)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
	
			for i, tower in pairs(GetAllyTurret()) do			
				if WardsAround(target, 400) == 0 and Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 250 and Item and Data.ammo > 0 then 
		
					if tower.pos:DistanceTo(target.pos) <= 1600 then
						local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (300)
						InsecStart(CastPos)
										
					else
						
						for i, ally in pairs(GetAllyHeroes()) do						
							if ally.pos:DistanceTo(myHero.pos) <= 1300 and IsValid(ally) and ally.pos:DistanceTo(target.pos) <= 1500 then
								local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (300)
								InsecStart(CastPos)
								
							end	
						end
					end				
				end
			end
		end
	end
end

function BurstInsec2()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
	local Data = myHero:GetSpellData(Item);	
		if IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) < 500 and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 350 and Ready(_E) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" and myHero:GetSpellData(_E).name == "BlindMonkEOne" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and not Ready(_E) then
				Cast(HK_R, target.pos)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) then
				Cast(HK_Q, pred.CastPosition)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
	
			for i, tower in pairs(GetAllyTurret()) do			
				if WardsAround(target, 400) == 0 and Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 250 and Item and Data.ammo > 0 then 
		
					if tower.pos:DistanceTo(target.pos) <= 1600 then
						local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (300)
						InsecStart(CastPos)
										
					else
						
						for i, ally in pairs(GetAllyHeroes()) do						
							if ally.pos:DistanceTo(myHero.pos) <= 1300 and IsValid(ally) and ally.pos:DistanceTo(target.pos) <= 1500 then
								local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (300)
								InsecStart(CastPos)
								
							end	
						end
					end				
				end
			end
		end
	end
end

function InsecStart(CastPos)
local target = GetTarget(1300)     	
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
							Control.SetCursorPos(CastPos)
							Cast(ItemHotKey[wardslot], CastPos)
							Cast(HK_W, CastPos)		
						end
					end
				end
			end
		end
	end
end

function AutoQ()
local target = GetTarget(1500)     	
if target == nil or IsUnderTurret(target) then return end	
	
	if IsValid(target) and Menu.AutoQ.UseQ:Value() and Ready(_Q) then
	local pred = GetGamsteronPrediction(target, QData, myHero)
	
		if IsImmobileTarget(target) and myHero.pos:DistanceTo(target.pos) <= 1200 and not HasBuff(target, "BlindMonkQOne") and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end	
		
		if IsImmobileTarget(target) and myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
			Control.CastSpell(HK_Q)
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


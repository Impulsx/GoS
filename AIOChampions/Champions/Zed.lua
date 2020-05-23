local function GetEnemyHeroes()
	return Enemies
end

local function GetAllyHeroes() 
	return Allies
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

local function DistanceSquared(p1, p2)
	local dx, dy = p2.x - p1.x, p2.z - p1.z
	return dx * dx + dy * dy
end

local function GetCircularAOEPos(points, radius)
    local bestPos, count = Vector(0, 0, 0), #points
    if count == 0 then return nil, 0 end
    if count == 1 then return points[1], 1 end
    local inside, furthest, id = 0, 0, 0
    for i, point in ipairs(points) do
        bestPos = bestPos + point
    end
    bestPos = bestPos / count
    for i, point in ipairs(points) do
        local distSqr = DistanceSquared(bestPos, point)
        if distSqr < radius * radius then inside = inside + 1 end
        if distSqr > furthest then furthest = distSqr; id = i end
    end
    if inside == count then
        return bestPos, count
    else
        TableRemove(points, id)
        return GetCircularAOEPos(points, radius)
    end
end

local function CastSpell(spell, pos)
	local delay = 250
	local ticker = GetTickCount()

	if castSpell.state == 0 and ticker - castSpell.casting > delay + Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Latency() then
			Control.SetCursorPos(pos)
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

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function GetEnergy()
	local currentEnergyNeeded = 0
	
	if Ready(_Q) then
		currentEnergyNeeded = currentEnergyNeeded + myHero:GetSpellData(_Q).mana
	end
	if Ready(_W) then
		currentEnergyNeeded = currentEnergyNeeded + myHero:GetSpellData(_W).mana
	end
	if Ready(_E) then
		currentEnergyNeeded = currentEnergyNeeded + myHero:GetSpellData(_E).mana
	end
	return currentEnergyNeeded
end

local function GetDamage(spell)
	local damage = 0
	local AD = myHero.bonusDamage
	
	if spell == HK_Q then
		if GameCanUseSpell(_Q) == 0 then
			damage = (myHero:GetSpellData(_Q).level * 35 + 45) + AD 
		end
	elseif spell == HK_E then
		if GameCanUseSpell(_E) == 0 then
			damage = (myHero:GetSpellData(_E).level * 25 + 45) + AD * 0.8
		end
	elseif spell == Ignite then
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and GameCanUseSpell(SUMMONER_1) == 0 then
			damage = 50 + 20 * myHero.levelData.lvl
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and GameCanUseSpell(SUMMONER_2) == 0 then
			damage = 50 + 20 * myHero.levelData.lvl
		end	
	end
	return damage
end

local Wshadow 		= 	{}
local Rshadow 		= 	{}
local QEKillable 	= 	false
local UltKillable 	= 	false
local UltTarget 	= 	nil
local Wtime 		= 	5000

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"TestVersion [WIP]"}})			
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	Menu.Combo.Ult:MenuElement({id = "UseR", name = "All Ult Option On/Off", value = true})	
	Menu.Combo.Ult:MenuElement({name = " ", drop = {"Ult-Logic: Calc. completely possible Dmg"}})	
	Menu.Combo.Ult:MenuElement({id = "IGN", name = "Use Ignite for KS and active Ult", value = true})			
	Menu.Combo.Ult:MenuElement({id = "UseRTower", name = "Kill[R] Dive under Tower", value = true})
	Menu.Combo.Ult:MenuElement({id = "UseRBack", name = "[R2]Back if Zed Hp low", value = true})
	Menu.Combo.Ult:MenuElement({id = "Hp", name = "[R2]Back if Zed Hp lower than -->", value = 15, min = 0, max = 100, identifier = "%"})	

	--[[HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W1]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Energy to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = false})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W1] + [E]", value = true})  
	Menu.Clear:MenuElement({id = "UseWM", name = "Use [W1] + [E] min Minions", value = 3, min = 1, max = 6})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Energy to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = false})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Energy to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  

	--Flee
	Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
	Menu.Flee:MenuElement({id = "key", name = "Flee Key", key = string.byte("A")})	
	Menu.Flee:MenuElement({id = "UseQ", name = "[Q] if possible", value = true})         	
	Menu.Flee:MenuElement({id = "UseW", name = "[W1] + [W2]", value = true})
	Menu.Flee:MenuElement({id = "UseE", name = "[E] if possible", value = true})	
]]
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQE", name = "KS: [W1]>[E]>[Q]", value = true})	
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "QC", name = "[Q Combo Mode] check minion collision", value = false})
	Menu.Pred:MenuElement({id = "QH", name = "[Q Harass Mode] check minion collision", value = false})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	

	if Menu.Pred.QC:Value() then
		QDataC =
		{
		Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 900, Speed = 1700,  Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
		}
		
		QspellDataC = {speed = 1700, range = 900, delay = 0.25, radius = 55, type = "linear",  collision = {"minion"}}
	else
		QDataC =
		{
		Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 900, Speed = 1700, Collision = false
		}
		
		QspellDataC = {speed = 1700, range = 900, delay = 0.25, radius = 55, type = "linear", collision = {nil}}	
	end
	
	if Menu.Pred.QH:Value() then	
		QDataH =
		{
		Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 900, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
		}
		
		QspellDataH = {speed = 1700, range = 900, delay = 0.25, radius = 55, type = "linear", collision = {"minion"}}
	else
		QDataH =
		{
		Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 900, Speed = 1700, Collision = false
		}
		
		QspellDataH = {speed = 1700, range = 900, delay = 0.25, radius = 55, type = "linear", collision = {nil}}
	end	
  	                                           
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
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 625, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 650, 1, DrawColor(225, 225, 0, 10))
		end		
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 290, 1, DrawColor(225, 225, 125, 10))
		end	

		for i, target in pairs(GetEnemyHeroes()) do
			local Qdmg2		= Ready(_Q) and GetDamage(HK_Q) or 0
			local Edmg2 	= Ready(_E) and GetDamage(HK_E) or 0
			local IGdmg 	= GetDamage(Ignite) or 0			
			local Qdmg 		= Ready(_Q) and getdmg("Q", target, myHero) or 0
			local Edmg 		= Ready(_E) and getdmg("E", target, myHero) or 0
			local Rdmg 		= getdmg("R", target, myHero)
			local physical	= myHero.totalDamage
			local magical 	= myHero.ap
			local TotalDmg 	= (Qdmg + Edmg + Rdmg + IGdmg + ((Qdmg2 + Edmg2 + physical)*(0.1 + 0.15 * myHero:GetSpellData(_R).level)) + ((physical + magical) * 2)) - (target.hpRegen*3)	
			local QEDmg 	= (Qdmg + Edmg) - (target.hpRegen*3)
			local currentEnergyNeeded = GetEnergy()
			if Ready(_R) then
				if myHero.pos:DistanceTo(target.pos) <= 20000 and IsValid(target) and target.health < TotalDmg and myHero.mana > currentEnergyNeeded then 
					DrawText("Kill", 24, target.pos2D.x, target.pos2D.y,DrawColor(255, 255, 0, 0))
					DrawText("Kill", 10, target.posMM.x - 15, target.posMM.y - 15,DrawColor(255, 255, 0, 0))			
				end
			else
				if myHero.pos:DistanceTo(target.pos) <= 20000 and IsValid(target) and target.health < QEDmg then
					DrawText("Kill", 24, target.pos2D.x, target.pos2D.y,DrawColor(255, 255, 0, 0))
					DrawText("Kill", 10, target.posMM.x - 15, target.posMM.y - 15,DrawColor(255, 255, 0, 0))	
				end				
			end	
		end	
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		if not QEKillable then
			Ult()
			Combo()
		end	
	--elseif Mode == "Harass" then
		--Harass()
	--elseif Mode == "Clear" then
		--Clear()
		--JungleClear()
	--elseif Mode == "Flee" then
		--if Menu.Flee.key:Value() then
			--Flee()
		--end	
	end
	if UltTarget and UltTarget.health <= 5 then
		ControlCastSpell(HK_R)
		UltTarget = nil
	end
	if Menu.ks.UseQE:Value() then
		QEKill()
	end	
end	

function Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) and not UltKillable then
		local Wready = false
		local QcanCast = false
		local Qready = false
		
		if QcanCast then
			SetMovement(false)
		else
			SetMovement(true)
		end	
		
		if Ready(_Q) or myHero:GetSpellData(_Q).currentCd < 3 then
			Qready = true
		else
			Qready = false
		end		
		
		if Ready(_W) or myHero:GetSpellData(_W).currentCd < 3 then
			Wready = true
		end	
		
		if myHero.pos:DistanceTo(target.pos) < 900 and Menu.Combo.UseQ:Value() then
			if Wready then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QDataC, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 and Ready(_Q) then
						QcanCast = true
						if myHero:GetSpellData(_W).name == "ZedW2" then
							CastSpell(HK_Q, pred.CastPosition)
							Wready = false
							QcanCast = false
						end	
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellDataC)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) and Ready(_Q) then
						QcanCast = true
						if myHero:GetSpellData(_W).name == "ZedW2" then					
							CastSpell(HK_Q, pred.CastPos)
							Wready = false
							QcanCast = false
						end						
					end	
				end
			else
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QDataC, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 and Ready(_Q) then
						CastSpell(HK_Q, pred.CastPosition)
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellDataC)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) and Ready(_Q) then					
						CastSpell(HK_Q, pred.CastPos)					
					end	
				end			
			end	
		end	
	
		if myHero.pos:DistanceTo(target.pos) <= 290 or myHero:GetSpellData(_W).name == "ZedW2" and Menu.Combo.UseE:Value() and Ready(_E) then
			ControlCastSpell(HK_E)
		end	
				
		if Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" then
			local Time = GetTickCount()
			if Qready then
				if QcanCast and (Wtime + 5000) < Time then
					CastSpell(HK_W, target.pos)
					Wtime = Time
				end
			else
				if Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 890 and myHero:GetSpellData(_W).name ~= "ZedW2" and (Wtime + 5000) < Time then
					CastSpell(HK_W, target.pos)
					Wtime = Time
				end	
			end	
		end	
	end
end

function Ult()
local target = GetTarget(1400)
if target == nil then return end	
	if IsValid(target) then	
		local Qdmg2		= Ready(_Q) and GetDamage(HK_Q) or 0
		local Edmg2 	= Ready(_E) and GetDamage(HK_E) or 0
		local IGdmg 	= GetDamage(Ignite) or 0			
		local Qdmg 		= Ready(_Q) and getdmg("Q", target, myHero) or 0
		local Edmg 		= Ready(_E) and getdmg("E", target, myHero) or 0
		local Rdmg 		= getdmg("R", target, myHero)
		local physical	= myHero.totalDamage
		local magical 	= myHero.ap
		local TotalDmg 	= (Qdmg + Edmg + Rdmg + IGdmg + ((Qdmg2 + Edmg2 + physical)*(0.1 + 0.15 * myHero:GetSpellData(_R).level)) + ((physical + magical) * 2)) - (target.hpRegen*3) 
		local currentEnergyNeeded = GetEnergy()
		
		if Menu.Combo.Ult.IGN:Value() and myHero.pos:DistanceTo(target.pos) <= 600 and (HasBuff(target, "zedrdeathmark") or IGdmg - (target.hpRegen*3) > target.health) then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and GameCanUseSpell(SUMMONER_1) == 0 then
				ControlCastSpell(HK_SUMMONER_1, target)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and GameCanUseSpell(SUMMONER_2) == 0 then
				ControlCastSpell(HK_SUMMONER_2, target)
			end	
		end	
		
		if Menu.Combo.Ult.UseR:Value() and Menu.Combo.Ult.UseRBack:Value() and myHero:GetSpellData(_R).name == "ZedR2" then

			if UltTarget == nil and HasBuff(target, "zedrdeathmark") then
				UltTarget = target
			end	
	
			if myHero.health/myHero.maxHealth <= Menu.Combo.Ult.Hp:Value() / 100 then
				ControlCastSpell(HK_R)
				UltTarget = nil
			end	
		end		
		
		if Menu.Combo.Ult.UseR:Value() and Ready(_R) and myHero:GetSpellData(_R).name ~= "ZedR2" then		
			
			if Ready(_W) and (target.health < Qdmg*2 and Ready(_Q)) or (target.health < Edmg and Ready(_E)) or (target.health < Qdmg*2+Edmg and Ready(_Q) and Ready(_E)) then return end
			
			if myHero.pos:DistanceTo(target.pos) <= 625 then
			
				if Menu.Combo.Ult.UseRTower:Value() then
					if target.health < TotalDmg and myHero.mana > currentEnergyNeeded then
						UltKillable = true
						Control.SetCursorPos(target)
						Control.KeyDown(HK_R)
						Control.KeyUp(HK_R)
						UltKillable = false
					end
				else
					for i, ally in pairs(GetAllyHeroes()) do
						if target.health < TotalDmg and myHero.mana > currentEnergyNeeded then
							if not IsUnderTurret(target) or (IsUnderTurret(target) and ally.pos:DistanceTo(target.pos) < 900 and IsUnderTurret(ally)) then
								UltKillable = true
								Control.SetCursorPos(target)
								Control.KeyDown(HK_R)
								Control.KeyUp(HK_R)
								UltKillable = false
							end	
						end	
					end	
				end
				
			else
				if Ready(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" and myHero.pos:DistanceTo(target.pos) > 700 and myHero.pos:DistanceTo(target.pos) < 1250 and target.health < TotalDmg and myHero.mana > currentEnergyNeeded then
					local EnemyCount = GetEnemyCount(800, target)
					if Menu.Combo.Ult.UseRTower:Value() and EnemyCount == 1 then
						UltKillable = true
						CastSpell(HK_W, target.pos)
						DelayAction(function()
							ControlCastSpell(HK_W)
						end,0.2)	
					else
						for i, ally in pairs(GetAllyHeroes()) do
							if (not IsUnderTurret(target) and EnemyCount == 1) or (IsUnderTurret(target) and ally.pos:DistanceTo(target.pos) < 800 and IsUnderTurret(ally)) then
								UltKillable = true
								CastSpell(HK_W, target.pos)
								DelayAction(function()
									ControlCastSpell(HK_W)
								end,0.2)
							end	
						end	
					end			
				end	
			end
		end	
	end	
end

function QEKill()
	for i, target in pairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) < 900 and IsValid(target) then
			local Qdmg 	= Ready(_Q) and getdmg("Q", target, myHero) or 0
			local Edmg 	= Ready(_E) and getdmg("E", target, myHero) or 0
			local QEdmg = (Qdmg + Edmg) - (target.hpRegen*3)		
			if Ready(_W) and myHero:GetSpellData(_W).name ~= "ZedW2" and target.health < QEdmg then
				QEKillable = true
				local Time = GetTickCount()
				if (Wtime + 5000) < Time then
					CastSpell(HK_W, target.pos)
					Wtime = Time
				end
			end
			if myHero:GetSpellData(_W).name == "ZedW2" then
				if Ready(_E) then
					ControlCastSpell(HK_E)
				end			
				if Ready(_Q) then
					CastSpell(HK_Q, target.pos)
					QEKillable = false
				end	
			end	
		end	
	end
end	
--[[


function Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100
        
		if myHero.pos:DistanceTo(target.pos) <= 575 and Menu.Harass.UseQ:Value() and Ready(_Q) and mana_ok then
			ControlCastSpell(HK_Q, target)
		end			
		
		if myHero.pos:DistanceTo(target.pos) < 800 and Menu.Harass.UseE:Value() and Ready(_E) and mana_ok then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then				
					ControlCastSpell(HK_E, pred.CastPosition)					
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then			
					ControlCastSpell(HK_E, pred.CastPos)					
				end	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 300 and Menu.Harass.UseW:Value() and Ready(_W) and mana_ok then
			ControlCastSpell(HK_W)
		end		
	end
end	

function Clear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
			if Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 575 and IsValid(minion) and Ready(_Q) then
				ControlCastSpell(HK_Q, minion)
            end
			
            if Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 600 and IsValid(minion) and Ready(_W) then
                local count = GetMinionCount(575, minion)
				if count >= Menu.Clear.UseWM:Value() then
					ControlCastSpell(HK_W)
				end
            end
			
			if Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and Ready(_E) then
				ControlCastSpell(HK_E, minion.pos)
            end			
        end
    end
end

function JungleClear()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_JUNGLE then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
            
			if Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 575 and IsValid(minion) and Ready(_Q) then
                ControlCastSpell(HK_Q, minion.pos)
            end
			
            if Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 550 and IsValid(minion) and Ready(_W) then	
				ControlCastSpell(HK_W)
            end
			
			if Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) < 800 and IsValid(minion) and Ready(_E) then
				ControlCastSpell(HK_E, minion.pos)
            end			
        end
    end
end
]]

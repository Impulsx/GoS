
local spellQ = {
	range = 800,
	radius = 180,
	speed = MathHuge,
	delay = 0.65
}

local spellW = {
	range = 925,
	radius = 195,
	speed = 1450,
	delay = 0.25
}

local spellE = {
	range = 700,
	width = 45,
	speed = 2500,
	delay = 0.25
}

local spellR = {
	range = 675
}

local spellQE = {
	range = 1100,
	width = 22,
	speed = 4500,
	delay = 0.15
}

local spellQE2 = {
	range = 1100,
	width = 22,
	speed = 2800,
	delay = 0.15
}

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.team ~= myHero.team then
			TableInsert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
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

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.type == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function GetEnemyTurrets()
	return Turrets
end

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurrets()) do
        local range = (turret.boundingRadius + 775 + unit.boundingRadius / 2)
        if not turret.dead then 
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

function LoadScript()	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "qcombo", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "qecombo", name = "[Q/E]", value = true})	
	Menu.Combo:MenuElement({id = "qerange", name = "[Q/E] Max range", value = 1100, min = 800, max = 1150, step = 1})
	Menu.Combo:MenuElement({id = "wcombo", name = "[W]", value = true})		
	Menu.Combo:MenuElement({id = "ecombo", name = "[E]", value = true})
	Menu.Combo:MenuElement({type = MENU, id = "rset", name = "Ultimate Settings"})	
	Menu.Combo.rset:MenuElement({id = "rcombo", name = "[R]", value = true})
	Menu.Combo.rset:MenuElement({id = "rmod", name = "[R] Mode - Engage/Finisher", key = string.byte("T"), value = true, toggle = true})	
	Menu.Combo.rset:MenuElement({id = "orb", name = "Min. Orbs for Engage Mode", value = 5, min = 3, max = 7})	
	Menu.Combo.rset:MenuElement({id = "engagemode", name = "Only Engage if ComboDmg can Kill", value = true})
	Menu.Combo.rset:MenuElement({type = MENU, id = "blacklist", name = "Ultimate Blacklist"})	
	DelayAction(function()
		for i, Hero in pairs(GetEnemyHeroes()) do
			Menu.Combo.rset.blacklist:MenuElement({id = Hero.charName, name = "Block Ult on: "..Hero.charName, value = false})		
		end		
	end,0.2)
	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "autoq", name = "Auto[Q]", value = false})	
	Menu.Harass:MenuElement({id = "autoqcc", name = "Auto[Q] on CC", value = true})	
	Menu.Harass:MenuElement({id = "turret2", name = "Block Auto[Q] if Syndra under Turret", value = true})
	Menu.Harass:MenuElement({id = "qharass", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "qeharass", name = "[Q/E]", value = true})	
	Menu.Harass:MenuElement({id = "wharass", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "eharass", name = "[E]", value = true})		
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 30, min = 0, max = 100, identifier = "%"})

	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "farmq", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "hitq", name = "[Q] min Minions", value = 2, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "farmw", name = "[W]", value = true})  
	Menu.Clear:MenuElement({id = "hitw", name = "[W] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 30, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "farmq", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 30, min = 0, max = 100, identifier = "%"})

	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "ksq", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "ksw", name = "[W]", value = true})	
	Menu.ks:MenuElement({id = "ksr", name = "[R]", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "Text Pos Settings"})	
	Menu.Drawing.XY:MenuElement({id = "Text", name = "Draw RMode Text", value = true})		
	Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 700, min = 0, max = 1500, step = 10})
	Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})	

	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = spellQ.delay, Radius = spellQ.radius, Range = spellQ.range, Speed = spellQ.speed, Collision = false
	}	
	QspellData = {speed = spellQ.speed, range = spellQ.range, delay = spellQ.delay, radius = spellQ.radius, collision = {nil}, type = "circular"}

	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = spellW.delay, Radius = spellW.radius, Range = spellW.range, Speed = spellW.speed, Collision = false 
	}	
	WspellData = {speed = spellW.speed, range = spellW.range, delay = spellW.delay, radius = spellW.radius, collision = {nil}, type = "circular"}

	QEData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = spellQE.delay, Radius = spellQE.width, Range = spellQE.range, Speed = spellQE.speed, Collision = false
	}	
	QEspellData = {speed = spellQE.speed, range = spellQE.range, delay = spellQE.delay, radius = spellQE.width, collision = {nil}, type = "circular"}	
	
	QE2Data =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = spellQE2.delay, Radius = spellQE2.width, Range = spellQE2.range, Speed = spellQE2.speed, Collision = false
	}	
	QE2spellData = {speed = spellQE2.speed, range = spellQE2.range, delay = spellQE2.delay, radius = spellQE2.width, collision = {nil}, type = "circular"}	
  	                                           											   
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("WndMsg", function(msg, param) CheckWndMsg(msg, param) end) 
	
	Callback.Add("Draw", function()
		if Menu.Drawing.XY.Text:Value() then 
			DrawText("R Mode: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+10, DrawColor(255, 225, 255, 0))		
			if Menu.Combo.rset.rmod:Value() then
				DrawText("Engage", 15, Menu.Drawing.XY.x:Value()+50, Menu.Drawing.XY.y:Value()+10, DrawColor(255, 0, 255, 0))
			else
				DrawText("Finisher", 15, Menu.Drawing.XY.x:Value()+50, Menu.Drawing.XY.y:Value()+10, DrawColor(255, 0, 255, 0))
			end
		end	
		
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, spellR.range, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, spellQ.range, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, spellE.range, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, spellW.range, 1, DrawColor(225, 225, 125, 10))
		end
	end)
end

local function GetTargetQ()
	return GetTarget(spellQ.range)
end

local function GetTargetW()
	return GetTarget(spellW.range)
end

local function GetTargetE()
	return GetTarget(spellE.range)
end

local function GetTargetR()
	return GetTarget(spellR.range)
end

local function GetTargetQE()
	return GetTarget(spellQE.range)
end

local NoIdeaWhatImDoing = 0
local LastWCast = 0
local ECasting = 0
local objSomething = {}

local function QDamage(target)
	local damage = 0
	
	if myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_Q).level < 5 then
		damage = getdmg("Q", target, myHero)
	end
	
	if myHero:GetSpellData(_Q).level == 5 then
		damage = getdmg("Q", target, myHero) + (getdmg("Q", target, myHero)*0.25)
	end
	return damage
end

local function WDamage(target)
	local damage = 0
	
	if myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_W).level < 5 then
		damage = getdmg("W", target, myHero)
	end
	
	if myHero:GetSpellData(_W).level == 5 then
		damage = getdmg("W", target, myHero) + (0.2 * (({70, 110, 150, 190, 230})[myHero:GetSpellData(_W).level] + 0.7 * myHero.ap))
	end
	return damage
end

local function RDamage(target)
	return getdmg("R", target, myHero, 2) * myHero:GetSpellData(_R).ammo
end

function CheckWndMsg(msg, param)
	if msg == 257 then
		local delay = nil
		if param == HK_Q then
			delay = 0.7 + ping
		elseif param == HK_R then
			delay = 0.5 + ping			
		end
	
		if delay then               
			DelayAction(function() 
				CheckSphere() 
			end, delay)
		end
	end	
end

function CheckObject(obj)
	for i = 1, #objSomething do
		if objSomething[i].networkID == obj.networkID then
			return true
		end
	end
	return false
end

function CheckSphere()
	for i = 1, GameObjectCount() do
		local obj = GameObject(i)
		if obj and obj.name == "Seed" and not CheckObject(obj) then
			TableInsert(objSomething, obj)
			NoIdeaWhatImDoing = os.clock() + 6
		end		
	end	
end

function Objects()
	local orbs = nil

	local closestObjDistance = 9999
	local lowest = 9999999999

	for i, objsq in pairs(objSomething) do
		if objsq then
			if not objsq.dead then
				if GetDistance(myHero.pos, objsq.pos) <= spellW.range then
					local minionDistanceToMouse = GetDistance(myHero.pos, objsq.pos)

					if NoIdeaWhatImDoing > 0 and lowest > NoIdeaWhatImDoing then
						lowest = NoIdeaWhatImDoing
						orbs = objsq
						closestObjDistance = minionDistanceToMouse
					end
				end
			else
				TableRemove(objSomething, i)
			end
		end
	end

	local closestMinion = nil
	local closestMinionDistance = 9999	

	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and IsValid(minion) and GetDistance(myHero.pos, minion.pos) <= spellW.range then
			if minion.team == TEAM_ENEMY then
				local minionDistanceToMouse1 = GetDistance(myHero.pos, minion.pos) 
				if minionDistanceToMouse1 < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse1
				end
			end	
			
			if minion.team == TEAM_JUNGLE then
				local minionDistanceToMouse2 = GetDistance(myHero.pos, minion.pos)

				if minionDistanceToMouse2 < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse2
				end			
			end	
		end
	end

	if orbs then
		return orbs
	end
	if closestMinion then
		return closestMinion
	end		
	return nil	
end

function Tick()
	spellQE.range = Menu.Combo.qerange:Value()
	
	if myHero:GetSpellData(_R).level == 3 then
		spellR.range = 750
	end	
	
	if MyHeroNotReady() then return end
	local Object = Objects()
	if Object and Ready(_E) then
		spellW.delay = 0.15 + GetDistance(myHero.pos, Object.pos) / 3000
	end

	Killsteal()
	
	if Menu.Harass.autoqcc:Value() and Ready(_Q) then
		if (myHero.mana / myHero.maxMana) * 100 >= Menu.Harass.Mana:Value() then
			local target = GetTargetQ()
			if target and IsValid(target) and IsImmobileTarget(target) then
				local pos = GetPredPos(target, Q)
				if pos then
					if Menu.Harass.turret2:Value() then
						if not IsUnderTurret(myHero) then
							Control.CastSpell(HK_Q, pos)
						end
					else
						Control.CastSpell(HK_Q, pos)
						
					end
				end
			end
		end
	end
	
	if Menu.Harass.autoq:Value() and Ready(_Q) then
		if (myHero.mana / myHero.maxMana) * 100 >= Menu.Harass.Mana:Value() then
			local target = GetTargetQ()
			if target and IsValid(target) then
				local pos = GetPredPos(target, Q)
				if pos then
					if Menu.Harass.turret2:Value() then
						if not IsUnderTurret(myHero) then
							Control.CastSpell(HK_Q, pos)
							
						end
					else
						Control.CastSpell(HK_Q, pos)
						
					end
				end
			end
		end
	end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		LaneClear()
		JungleClear()	
	end
end

function Killsteal()
	for i, enemies in pairs(GetEnemyHeroes()) do
		if enemies and IsValid(enemies) and not enemies.isImmortal then
			local hp = enemies.health

			if Menu.ks.ksq:Value() and Ready(_Q) then
				if GetDistance(myHero.pos, enemies.pos) < spellQ.range and QDamage(enemies) > hp then
					local pos = GetPredPos(enemies, Q)
					if pos then
						Control.CastSpell(HK_Q, pos)
					end
				end
			end
			
			if Menu.ks.ksw:Value() and Ready(_W) then
				if GetDistance(myHero.pos, enemies.pos) < spellW.range - 80 and WDamage(enemies) > hp then
					if myHero:GetSpellData(_W).name == "SyndraW" then
						local Object = Objects()
						if Object then
							if os.clock() - LastWCast > 0.26 + ping and os.clock() - ECasting > 0.24 + ping then
								Control.CastSpell(HK_W, Object.pos)
								LastWCast = os.clock()
								
							end
						end
					else
						if not HasBuff(enemies, "SyndraEDebuff") then
							local pos = GetPredPos(enemies, W)
							if pos then
								Control.CastSpell(HK_W, pos)
							end
						end
					end
				end
			end
			
			if Menu.ks.ksr:Value() and Ready(_R) then
				if GetDistance(myHero.pos, enemies.pos) < spellR.range and hp < RDamage(enemies) then
					Control.CastSpell(HK_R, enemies)
				end
			end
		end
	end
end

function JungleClear()
	if (myHero.mana / myHero.maxMana) * 100 >= Menu.JClear.Mana:Value() then
		if Menu.JClear.farmq:Value() and Ready(_Q) then
			for i = 1, GameMinionCount() do
				local minion = GameMinion(i)
				if minion and IsValid(minion) and minion.team == TEAM_JUNGLE and GetDistance(myHero.pos, minion.pos) <= spellQ.range then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end
		end
	end
end

function LaneClear()
	local aaa = 0
	if myHero:GetSpellData(_W).name ~= "SyndraW" then
		aaa = 1
	else
		aaa = 0
	end

	if (myHero.mana / myHero.maxMana) * 100 >= Menu.Clear.Mana:Value() then
		
		if Menu.Clear.farmq:Value() and Ready(_Q) then
			for i = 1, GameMinionCount() do
				local minion1 = GameMinion(i)
				if minion1 and IsValid(minion1) and minion1.team == TEAM_ENEMY and GetDistanceSqr(myHero.pos, minion1.pos) <= (spellQ.radius*spellQ.radius) then
					local count = 0
					for i = 1, GameMinionCount() do
						local minion2 = GameMinion(i)
						if minion2 and minion2 ~= minion1 and IsValid(minion2) and minion2.team == TEAM_ENEMY and GetDistanceSqr(minion1.pos, minion2.pos) <= (spellQ.radius*spellQ.radius) then
							count = count + 1
						end
						if count >= Menu.Clear.hitq:Value() then
							Control.CastSpell(HK_Q, minion1.pos)
							break
						end
					end
				end
			
			
				if minion1 and IsValid(minion1) and minion1.team == TEAM_ENEMY and GetDistance(myHero.pos, minion1.pos) <= spellQ.range then 
					local MinionCount = GetMinionCount(spellQ.radius, minion1)
					if MinionCount >= Menu.Clear.hitq:Value() then
						Control.CastSpell(HK_Q, minion1.pos)
					end
				end
			end	
		end
		
		if Menu.Clear.farmw:Value() and Ready(_W) then
			for i = 1, GameMinionCount() do
				local minion1 = GameMinion(i)
				if minion1 and IsValid(minion1) and minion1.team == TEAM_ENEMY and GetDistanceSqr(myHero.pos, minion1.pos) <= (spellW.radius*spellW.radius) then
					local count = 0
					for i = 1, GameMinionCount() do
						local minion2 = GameMinion(i)
						if minion2 and minion2 ~= minion1 and IsValid(minion2) and minion2.team == TEAM_ENEMY and GetDistanceSqr(minion1.pos, minion2.pos) <= (spellW.radius*spellW.radius) then
							count = count + 1
						end
						if count >= Menu.Clear.hitw:Value() then
							if myHero:GetSpellData(_W).name == "SyndraW" then
								local Object = Objects()
								if Object then
									if os.clock() - LastWCast > 0.26 + ping and os.clock() - ECasting > 0.24 + ping then
										Control.CastSpell(HK_W, Object.pos)
										LastWCast = os.clock()
										
									end
								end	
							else	
								if GetDistance(myHero.pos, minion1.pos) <= spellW.range then
									Control.CastSpell(HK_W, minion1.pos)
								end
							end
						end
						if GetMinionCount(spellW.range, myHero) == 0 then
							if myHero:GetSpellData(_W).name ~= "SyndraW" then
								Control.CastSpell(HK_W, myHero.pos)
							end
						end
					end
				end
			
				if minion1 and IsValid(minion1) and minion1.team == TEAM_ENEMY and GetDistance(myHero.pos, minion1.pos) <= spellW.range then
					if (GetMinionCount(spellW.radius, minion1) + aaa) >= Menu.Clear.hitw:Value() then
						if myHero:GetSpellData(_W).name == "SyndraW" then
							local Object = Objects()
							if Object then
								if os.clock() - LastWCast > 0.26 + ping and os.clock() - ECasting > 0.24 + ping then
									Control.CastSpell(HK_W, Object.pos)
									LastWCast = os.clock()
									
								end
							end	
						else	
							if GetDistance(myHero.pos, minion1.pos) <= spellW.range then
								Control.CastSpell(HK_W, minion1.pos)
							end
						end
					end
					if GetMinionCount(spellW.range, myHero) == 0 then
						if myHero:GetSpellData(_W).name ~= "SyndraW" then
							Control.CastSpell(HK_W, myHero.pos)
						end
					end
				end
			end
		end
	end
end

function Combo()
	if Menu.Combo.qcombo:Value() and Ready(_Q) then
		local target = GetTargetQ()
		if target and IsValid(target) then
			local pos = GetPredPos(target, Q)
			if pos then
				Control.CastSpell(HK_Q, pos)
			end
		end
	end
	
	if Menu.Combo.wcombo:Value() and Ready(_W) then
		local target = GetTargetW()
		if target and IsValid(target) then
			if GetDistance(myHero.pos, target.pos) <= spellW.range - 30 then
				local Object = Objects()
				if Object then
					local pos = GetPredPos(target, W)
					if pos then
						if myHero:GetSpellData(_W).name == "SyndraW" then
							if os.clock() - LastWCast > 0.26 + ping and os.clock() - ECasting > 0.24 + ping then
								Control.CastSpell(HK_W, Object.pos)
								LastWCast = os.clock()
								
							end
						else
							if not HasBuff(target, "SyndraEDebuff") then
								Control.CastSpell(HK_W, pos)
							end
						end
					end
				end
			end
		end
	end
	
	if os.clock() - LastWCast > 0.1 + ping then
		if Menu.Combo.ecombo:Value() and Ready(_E) then
			for i, target in ipairs(GetEnemyHeroes()) do
				if target and IsValid(target) and not target.isImmortal then
					if GetDistance(myHero.pos, target.pos) <= spellQE.range then
						for _, objsq in pairs(objSomething) do
							if objsq and not objsq.dead then
								if GetDistance(myHero.pos, objsq.pos) <= spellQE.range then
									if GetDistance(myHero.pos, objsq.pos) <= spellE.range and GetDistance(myHero.pos, objsq.pos) >= 100 and GetDistance(myHero.pos, target.pos) <= 1100 then
										local pos = GetPredPos(target, QE)
										if pos then
											local BallPosition = Vector(objsq.pos)
											local direction = (BallPosition - myHero.pos):Normalized()
											local distance = GetDistance(myHero.pos, pos)
											local extendedPos = myHero.pos + direction * distance
											if GetDistance(extendedPos, pos) < (spellQE.width + target.boundingRadius - 20) and GetDistance(myHero.pos, target.pos) >= 50 and GetDistance(myHero.pos, objsq.pos) >= 80 and GetDistance(myHero.pos, target.pos) <= spellQE.range then
												Control.CastSpell(HK_E, pos)
												ECasting = os.clock()
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if Menu.Combo.qecombo:Value() and Ready(_Q) and Ready(_E) then
		local target = GetTargetQE()
		if target and IsValid(target) then
			if myHero.mana > myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_E).mana then
				if GetDistance(myHero.pos, target.pos) <= spellQE.range then
					if GetDistance(myHero.pos, target.pos) > 1000 then
						spellQE2.delay = 0.24
					end
					if GetDistance(myHero.pos, target.pos) < 1000 and GetDistance(myHero.pos, target.pos) > 900 then
						spellQE2.delay = 0.16
					end
					if GetDistance(myHero.pos, target.pos) < 900 then
						spellQE2.delay = 0.25
					end
					
					local pos = GetPredPos(target, QE2)
					if pos then
						local CastPos = myHero.pos + (pos - myHero.pos):Normalized() * 700
						if GetDistance(myHero.pos, target.pos) > spellE.range then
							Control.CastSpell(HK_Q, CastPos)
						end
					end
				end
			end
		end
	end
	
	if Menu.Combo.rset.rcombo:Value() and Ready(_R) then
		local mode = Menu.Combo.rset.rmod:Value()
		local target = GetTargetR()
		if target and IsValid(target) then
			if not mode then
				if Menu.Combo.rset.blacklist[target.charName] and not Menu.Combo.rset.blacklist[target.charName]:Value() then
					if RDamage(target) > target.health then
						Control.CastSpell(HK_R, target)
					end
				end
				
			else

				if Menu.Combo.rset.blacklist[target.charName] and not Menu.Combo.rset.blacklist[target.charName]:Value() then
					if myHero:GetSpellData(_R).ammo >= Menu.Combo.rset.orb:Value() then
						if not Menu.Combo.rset.engagemode:Value() then
							Control.CastSpell(HK_R, target)						
						else
							local QDmg = Ready(_Q) and QDamage(target) or 0
							local WDmg = Ready(_W) and WDamage(target) or 0
							local EDmg = Ready(_E) and getdmg("E", target, myHero) or 0
							local damages = RDamage(target) + QDmg + WDmg + EDmg
							if target.health <= damages then
								Control.CastSpell(HK_R, target)
							end
						end
					end
				end
			end
		end
	end
end

function Harass()
	if (myHero.mana / myHero.maxMana) * 100 >= Menu.Harass.Mana:Value() then
		if Menu.Harass.qharass:Value() and Ready(_Q) then
			local target = GetTargetQ()
			if target and IsValid(target) then
				local pos = GetPredPos(target, Q)
				if pos then
					Control.CastSpell(HK_Q, pos)
				end
			end
		end
		
		if Menu.Harass.wharass:Value() and Ready(_W) then
			local target = GetTargetW()
			if target and IsValid(target) then
				if GetDistance(myHero.pos, target.pos) <= spellW.range - 30 then
					local Object = Objects()
					if Object then
						local pos = GetPredPos(target, W)
						if pos then
							if myHero:GetSpellData(_W).name == "SyndraW" then
								if os.clock() - LastWCast > 0.26 + ping and os.clock() - ECasting > 0.24 + ping then
									Control.CastSpell(HK_W, Object.pos)
									LastWCast = os.clock()
									
								end
							else
								if not HasBuff(target, "SyndraEDebuff") then
									Control.CastSpell(HK_W, pos)
								end
							end
						end
					end
				end	
			end
		end
		
		if os.clock() - LastWCast > 0.1 + ping then
			if Menu.Harass.eharass:Value() and Ready(_E) then
				for i, target in ipairs(GetEnemyHeroes()) do
					if target and IsValid(target) and not target.isImmortal then
						if GetDistance(myHero.pos, target.pos) <= spellQE.range then
							for _, objsq in pairs(objSomething) do
								if objsq and not objsq.dead then
									if GetDistance(myHero.pos, objsq.pos) <= spellQE.range then
										if GetDistance(myHero.pos, objsq.pos) <= spellE.range and GetDistance(myHero.pos, objsq.pos) >= 170 and GetDistance(myHero.pos, target.pos) <= 1100 then
											local pos = GetPredPos(target, QE)
											if pos then
												local BallPosition = Vector(objsq.pos)
												local direction = (BallPosition - myHero.pos):Normalized()
												local distance = GetDistance(myHero.pos, pos)
												local extendedPos = myHero.pos + direction * distance
												if GetDistance(extendedPos, pos) < (spellQE.width + target.boundingRadius - 20) and GetDistance(myHero.pos, target.pos) >= 50 and GetDistance(myHero.pos, objsq.pos) >= 80 and GetDistance(myHero.pos, target.pos) <= spellQE.range then
													Control.CastSpell(HK_E, pos)
													ECasting = os.clock()
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		if Menu.Harass.qeharass:Value() and Ready(_Q) and Ready(_E) then
			local target = GetTargetQE()
			if target and IsValid(target) then
				if myHero.mana > myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_E).mana then
					if GetDistance(myHero.pos, target.pos) <= spellQE.range then
						if GetDistance(myHero.pos, target.pos) > 1000 then
							spellQE2.delay = 0.24
						end
						if GetDistance(myHero.pos, target.pos) < 1000 and GetDistance(myHero.pos, target.pos) > 900 then
							spellQE2.delay = 0.16
						end
						if GetDistance(myHero.pos, target.pos) < 900 then
							spellQE2.delay = 0.25
						end
						
						local pos = GetPredPos(target, QE2)
						if pos then
							local CastPos = myHero.pos + (pos - myHero.pos):Normalized() * 700
							if GetDistance(myHero.pos, target.pos) > spellE.range then
								Control.CastSpell(HK_Q, CastPos)
							end
						end
					end
				end
			end
		end
	end
end

function GetPredPos(unit, Spell)
	if Spell == Q then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
				return pred.CastPosition
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				return pred.CastPos
			end
		else
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = spellQ.delay, Radius = spellQ.radius, Range = spellQ.range, Speed = spellQ.speed, Collision = false})
			QPrediction:GetPrediction(unit, myHero)
			if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				return QPrediction.CastPosition
			end	
		end
		
	elseif Spell == W then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
				return pred.CastPosition
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
				return pred.CastPos
			end
		else
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = spellW.delay, Radius = spellW.radius, Range = spellW.range, Speed = spellW.speed, Collision = false})
			WPrediction:GetPrediction(unit, myHero)
			if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
				return WPrediction.CastPosition
			end	
		end
		
	elseif Spell == QE then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, QEData, myHero)
			if pred.Hitchance >= 3 then
				return pred.CastPosition
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QEspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				return pred.CastPos
			end
		else
			local QEPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = spellQE.delay, Radius = spellQE.width, Range = spellQE.range, Speed = spellQE.speed, Collision = false})
			QEPrediction:GetPrediction(unit, myHero)
			if QEPrediction:CanHit(3) then
				return QEPrediction.CastPosition
			end	
		end
		
	elseif Spell == QE2 then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, QE2Data, myHero)
			if pred.Hitchance >= 3 then
				return pred.CastPosition
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QE2spellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				return pred.CastPos
			end
		else
			local QE2Prediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = spellQE2.delay, Radius = spellQE2.width, Range = spellQE2.range, Speed = spellQE2.speed, Collision = false})
			QE2Prediction:GetPrediction(unit, myHero)
			if QE2Prediction:CanHit(3) then
				return QE2Prediction.CastPosition
			end	
		end	
	end
	return nil
end


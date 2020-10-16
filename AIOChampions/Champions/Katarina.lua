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

local function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
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

local function GetEnemyTurret()
	local _EnemyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        if turret.isEnemy and not turret.dead then
			TableInsert(_EnemyTurrets, turret)
		end
	end
	return _EnemyTurrets		
end

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.pos:DistanceTo(unit.pos) < range then
			return true
        end
    end
    return false
end

local spellQ = {range = 625}
local spellW = {range = 400}
local spellE = {range = 725}
local spellR = {range = 550}


--/// Ported from Hanbot by Kornis ///--
function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "combomode", name = "Combo Mode:", value = 2, drop = {"Q>E", "E>Q", "E>W>R>Q"}})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "ETurret", name = "Dont [E] under Turret", value = false})	
	Menu.Combo:MenuElement({id = "SaveE", name = "Save [E] if no Daggers", value = false})
	Menu.Combo:MenuElement({id = "Magnet", name = "Magnet to Daggers", value = false})	
	Menu.Combo:MenuElement({id = "emode", name = "[E] Mode:", value = 3, drop = {"Infront", "Behind", "UltLogic"}})
	Menu.Combo:MenuElement({name = " ", drop = {"[E] Mode: UltLogic = If R is not ready then cast Infront. If R ready then Cast Behind"}})
	Menu.Combo:MenuElement({type = MENU, id = "rset", name = "Ultimate Settings"})
	Menu.Combo.rset:MenuElement({id = "rmode", name = "[R] Usage:", value = 2, drop = {"Always", "Only if Killable", "Never"}})	
	Menu.Combo.rset:MenuElement({id = "rhit", name = "[R] Only if Hits X Enemies", value = 1, min = 1, max = 5})
	Menu.Combo.rset:MenuElement({id = "CancelR", name = "Cancel [R] if no Enemies", value = true})	
	Menu.Combo.rset:MenuElement({id = "CancelRKS", name = "Cancel [R] if can KS", value = true})
	Menu.Combo.rset:MenuElement({id = "HP", name = "Don't waste [R] if Enemy Health lower than", value = 15, min = 0, max = 100, identifier = "%"})	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "harassmode", name = "Harass Mode:", value = 2, drop = {"Q>E", "E>Q"}})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseQL", name = "[Q] only for LastHit", value = true})
	Menu.Clear:MenuElement({id = "UseQAA", name = "[Q] dont LastHit in AutoAttack range", value = true})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = false})
	Menu.Clear:MenuElement({id = "WCount", name = "Use[W] min Minions", value = 3, min = 1, max = 6})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = false})
	Menu.Clear:MenuElement({id = "ECount", name = "Use[E] if Dagger hit min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "ETuuret", name = "Dont [E] under Turret", value = true})	
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true}) 
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true}) 	

	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.ks:MenuElement({id = "UseEDagger", name = "[E] Dagger", value = true})
	Menu.ks:MenuElement({id = "UseEGap", name = "[E] Gapclose for [Q] KS", value = true})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawDamage", name = "Draw Damage", value = true})

	Callback.Add("Tick", function() KataTick() end)
	
	Callback.Add("Draw", function() KataDraw() end)	
end

function DrawDamagesE(target)
	local pos = target.pos:To2D().onScreen
	if (math.floor((RDamage(target) + EDamage(target) + PDamage(target) + getdmg("Q", target, myHero)) / target.health * 100) < 100) then
		Draw.Line(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, DrawColor(255, 255, 153, 51))
		Draw.Line(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, DrawColor(255, 255, 153, 51))
		Draw.Line(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, DrawColor(255, 255, 153, 51))

		DrawText(
			tostring(
				"R: " .. math.floor(RDamage(target) + PDamage(target) + EDamage(target) + getdmg("Q", target, myHero))
			) ..
				" (" ..
					tostring(
						math.floor(
							(RDamage(target) + PDamage(target) + EDamage(target) + getdmg("Q", target, myHero)) / target.health * 100
						)
					) ..
						"%)" .. "Not Killable",
			20,
			pos.x + 55,
			pos.y - 80,
			DrawColor(255, 255, 153, 51)
		)
	end
	
	if(math.floor((RDamage(target) + EDamage(target) + PDamage(target) + getdmg("Q", target, myHero)) / target.health * 100) >= 100) then
		Draw.Line(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, DrawColor(255, 150, 255, 200))
		Draw.Line(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, DrawColor(255, 150, 255, 200))
		Draw.Line(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, DrawColor(255, 150, 255, 200))
		DrawText(
			tostring(
				"R: " .. math.floor(RDamage(target) + PDamage(target) + EDamage(target) + getdmg("Q", target, myHero))
			) ..
				" (" ..
					tostring(
						math.floor(
							(RDamage(target) + PDamage(target) + EDamage(target) + getdmg("Q", target, myHero)) / target.health * 100
						)
					) ..
						"%)" .. "Killable",
			20,
			pos.x + 55,
			pos.y - 80,
			DrawColor(255, 150, 255, 200)
		)
	end
end

function KataDraw()
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

	if Menu.Drawing.DrawDamage:Value() then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if enemy and IsValid(enemy) and myHero.pos:DistanceTo(enemy.pos) <= 1000 then
				DrawDamages(enemy)
			end
		end
	end
end

local objHolder = {}
local DaggerCount = 0
local allowing = true

function KataTick()
	ScanDagger()
	RemoveDagger()
	
	if HasBuff(myHero, "katarinarsound") then
		allowing = false
	else
		allowing = true
	end
	
	if size() == 0 then
		SetMovement(true)
	end
	
local Mode = GetMode()
	if Menu.Combo.Magnet:Value() then
		for i, enemies in ipairs(GetEnemyHeroes()) do
			if enemies and IsValid(enemies) and myHero.pos:DistanceTo(enemies.pos) <= 1000 then
				if not HasBuff(myHero, "katarinarsound") and size() > 0 then
					if GetClosestDagger() and myHero.pos:DistanceTo(enemies.pos) < 500 then
						local direction = (GetClosestDagger().pos - enemies.pos):Normalize()
						local extendedPos = GetClosestDagger().pos - direction * 150
						if Mode == "Combo" and GetClosestDagger().pos:DistanceTo(myHero.pos) >= 160 then
							SetMovement(false)
							Control.Move(extendedPos)
						else
							SetMovement(true)
						end
					end
				end
			end
		end
	end
	
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		LaneClear()
		JungleClear()			
	end		

	KillSteal()
end

local NewDagger = true
function ScanDagger()
local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid and currSpell.name == "KatarinaW" then
		DelayAction(function()
			for i = 0, GameObjectCount() do
				local Dagger = GameObject(i)
				
				if Dagger and myHero.pos:DistanceTo(Dagger.pos) < 1000 and Dagger.name == "W_Indicator_Ally" then
					for i = 1, #objHolder do
						if objHolder[i].networkID == Dagger.networkID then
							NewDagger = false
						end
					end				
					
					if NewDagger then 
						if Dagger.name == "W_Indicator_Ally" then
							print("FoundNewTrap")
							TableInsert(objHolder, 1, {obj = Dagger, networkID = Dagger.networkID})
							DaggerCount = DaggerCount + 1
						end	
					end	
				end
			end
		end,1.3)	
	end	
end

local LastScan = 0
function RemoveDagger()
	if DaggerCount > 0 and GameTimer() - LastScan > 1 then
		for i = 1, #objHolder do
			if objHolder[i] then
				local Dagger = objHolder[i] 
				local object = Dagger.obj
				if object and (object.health <= 0 or object.name ~= "W_Indicator_Ally") then
					LastScan = GameTimer()
					DaggerCount = DaggerCount - 1				
					TableRemove(objHolder, i)
					print("Removed")
					print(DaggerCount)
				end
			end	
		end
	end
end

function size()
	return DaggerCount
end

local function GetClosestJungle()
	local closestMinion = nil
	local closestMinionDistance = 9999

	for i = 1,GameMinionCount() do
		local minion = GameMinion(i)
		if mousePos:DistanceTo(minion.pos) < spellE.range and IsValid(minion) and minion.team == TEAM_JUNGLE then
			local minionPos = Vector(minion.pos)
			if minionPos:DistanceTo(mousePos) < 200 then
				local minionDistanceToMouse = minionPos:DistanceTo(mousePos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end

local function GetClosestMob()
	local closestMinion = nil
	local closestMinionDistance = 9999

	for i = 1,GameMinionCount() do
		local minion = GameMinion(i)
		if mousePos:DistanceTo(minion.pos) < spellE.range and IsValid(minion) and minion.team == TEAM_ENEMY then
			local minionPos = Vector(minion.pos)
			if minionPos:DistanceTo(mousePos) < 200 then
				local minionDistanceToMouse = minionPos:DistanceTo(mousePos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end

local function GetClosestDagger()
	local closestDagger = nil
	local closestDaggerDistance = 9999
	for _, objs in pairs(objHolder) do
		if objs then
			if objs.pos:DistanceTo(myHero.pos) < 360 then
				local DaggerDist = objs.pos:DistanceTo(myHero.pos)

				if DaggerDist < closestDaggerDistance then
					closestDagger = objs
					closestDaggerDistance = DaggerDist
				end
			end
		end
	end
	return closestDagger
end

local function GetClosestMobToEnemy(unit)
	local closestMinion = nil
	local closestMinionDistance = 9999

	for i = 1,GameMinionCount() do
		local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) < spellE.range and IsValid(minion) and minion.team == TEAM_ENEMY then
			if minion.pos:DistanceTo(unit.pos) < spellQ.range then
				local minionDistanceToMouse = minion.pos:DistanceTo(unit.pos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end

local function GetClosestJungleEnemy(unit)
	local closestMinion = nil
	local closestMinionDistance = 9999

	for i = 1,GameMinionCount() do
		local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) < spellE.range and IsValid(minion) and minion.team == TEAM_JUNGLE then
			if minion.pos:DistanceTo(unit.pos) < spellQ.range then
				local minionDistanceToMouse = minion.pos:DistanceTo(unit.pos)

				if minionDistanceToMouse < closestMinionDistance then
					closestMinion = minion
					closestMinionDistance = minionDistanceToMouse
				end
			end
		end
	end
	return closestMinion
end

local function EDamage(target)
	return getdmg("E", target, myHero)
end

local function RDamage(target)
	return getdmg("R", target, myHero, 2)
end

local PDamages = ({68, 72, 77, 82, 89, 96, 103, 112, 121, 131, 142, 154, 166, 180, 194, 208, 224, 240})
local function PDamage(target)
	local damage = 0
	local leveldamage = 0
	
	if (myHero.level >= 1 and myHero.level < 6) then
		leveldamage = 0.55
	end
	if (myHero.level >= 6 and myHero.level < 11) then
		leveldamage = 0.66
	end
	if (myHero.level >= 11 and myHero.level < 16) then
		leveldamage = 0.77
	end
	if (myHero.level >= 16) then
		leveldamage = 0.88
	end
	
	for _, objs in pairs(objHolder) do
		if objs then
			if target.pos:DistanceTo(objs.pos) < 450 then
				damage = CalcMagicalDamage(myHero, target, (PDamages[myHero.level] + 0.75 * myHero.bonusDamage + (myHero.ap * leveldamage)))
			end
		end
	end
	return damage
end

function KillSteal()
	for i, enemies in ipairs(GetEnemyHeroes()) do
		if enemies and IsValid(enemies) then
			local hp = enemies.health
			
			if Menu.ks.UseEDagger:Value() and Ready(_E) then
				for _, objs in pairs(objHolder) do
					if objs then
						if (enemies.pos:DistanceTo(myHero.pos) <= spellE.range and objs.pos:DistanceTo(enemies.pos) < 450 and PDamage(enemies) > hp) then
							allowing = true
							local direction = (objs.pos - enemies.pos):Normalize()
							local extendedPos = objs.pos - direction * 200
							Control.CastSpell(HK_E, extendedPos)
						end
					end
				end
			end

			if Menu.ks.UseQ:Value() and Ready(_Q) then
				if enemies.pos:DistanceTo(myHero.pos) <= spellQ.range and getdmg("Q", enemies, myHero) > hp then
					allowing = true
					Control.CastSpell(HK_Q, enemies.pos)
				end
			end
			
			if Menu.ks.UseE:Value() and Ready(_E) then
				if enemies.pos:DistanceTo(myHero.pos) <= spellE.range and EDamage(enemies) > hp then
					allowing = true
					Control.CastSpell(HK_E, enemies.pos)
				end	
			end

			if Menu.ks.UseEGap:Value() and Ready(_E) then
				if Ready(_Q) and enemies.pos:DistanceTo(myHero.pos) > spellQ.range and enemies.pos:DistanceTo(myHero.pos) < (spellQ.range + spellE.range - 70) and getdmg("Q", enemies, myHero) - 30 > hp then
					allowing = true
					local Lminion = GetClosestMobToEnemy(enemies)
					if Lminion then
						Control.CastSpell(HK_E, Lminion.pos)
					end

					local Jminios = GetClosestJungleEnemy(enemies)
					if Jminios then
						Control.CastSpell(HK_E, Jminion.pos)
					end
				end
			end
		end
	end
end

function LaneClear()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)	
		if minion and IsValid(minion) and minion.pos:DistanceTo(myHero.pos) < 775 and minion.team == TEAM_ENEMY then
			if Menu.Clear.UseQ:Value() and Menu.Clear.UseQL:Value() and Ready(_Q) then
				if minion.pos:DistanceTo(myHero.pos) < spellQ.range then

					if getdmg("Q", minion, myHero) >= minion.health then
						if not Menu.Clear.UseQAA:Value() then
							Control.CastSpell(HK_Q, minion.pos)
						end
						if Menu.Clear.UseQAA:Value() and minion.pos:DistanceTo(myHero.pos) > 250 then
							Control.CastSpell(HK_Q, minion.pos)
						end
					end
				end
			end
			
			if Menu.Clear.UseQ:Value() and not Menu.Clear.UseQL:Value() and Ready(_Q) then
				if minion.pos:DistanceTo(myHero.pos) < spellQ.range then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end
			
			if Menu.Clear.UseW:Value() and Ready(_W) and minion.pos:DistanceTo(myHero.pos) < 450 then
				if GetMinionCount(450, myHero) >= Menu.Clear.WCount:Value() then
					Control.CastSpell(HK_W, minion.pos)
				end
			end

			if Menu.Clear.UseE:Value() and Ready(_E) and minion.pos:DistanceTo(myHero.pos) < spellE.range then
				for _, objs in pairs(objHolder) do
					if objs then

						if  GetMinionCount(450, objs) >= Menu.Clear.ECount:Value() then
							local direction = (objs.pos - minion.pos):Normalize()
							local extendedPos = objs.pos - direction * 200

							if Menu.Clear.ETuuret:Value() then
								if not IsUnderTurret(objs) then
									Control.CastSpell(HK_E, extendedPos)
								end
							else
								Control.CastSpell(HK_E, extendedPos)
							end
						end
					end
				end
			end
		end
	end	
end
 
function JungleClear()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)	
		if minion and IsValid(minion) and minion.pos:DistanceTo(myHero.pos) < 625 and minion.team == TEAM_JUNGLE then	
			
			if Menu.JClear.UseQ:Value() and Ready(_Q) and minion.pos:DistanceTo(myHero.pos) < spellQ.range then
				Control.CastSpell(HK_Q, minion.pos)
			end
			
			if Menu.JClear.UseW:Value() and Ready(_W) and minion.pos:DistanceTo(myHero.pos) < 300 then
				Control.CastSpell(HK_W, minion.pos)
			end
		end
	end	
end
	
function Combo()
	if Menu.Combo.rset.CancelR:Value() then
		if HasBuff(myHero, "katarinarsound") then
			if GetEnemyCount(spellR.range + 10, myHero) == 0 then
				Control.Move(mousePos)
			end
		end
	end
	
	local target = GetTarget(775)
	if Menu.Combo.rset.CancelRKS:Value() then
		if target and IsValid(target)then
			if target.pos:DistanceTo(myHero.pos) <= spellE.range then
				if HasBuff(myHero, "katarinarsound") then
					if target.pos:DistanceTo(myHero.pos) >= spellR.range - 100 then
						if (getdmg("Q", target, myHero) + EDamage(target)) >= target.health then
							if size() > 0 and Ready(_E) and Ready(_Q) then
								for _, objs in pairs(objHolder) do
									if objs then
									
										if target.pos:DistanceTo(objs.pos) < 450 then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(objs) then
													allowing = true
													local direction = (objs.pos - target.pos):Normalize()
													local extendedPos = objs.pos - direction * 200
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												allowing = true
												local direction = (objs.pos - target.pos):Normalize()
												local extendedPos = objs.pos - direction * 200
												Control.CastSpell(HK_E, extendedPos)
											end
										end

										if objs.pos:DistanceTo(myHero.pos) > spellE.range then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(target) then
													allowing = true
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * -50
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												allowing = true
												local direction = (target.pos - myHero.pos):Normalize()
												local extendedPos = target.pos - direction * -50
												Control.CastSpell(HK_E, extendedPos)
											end
										end
										
										if target.pos:DistanceTo(objs.pos) > 450 then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(target) then
													allowing = true
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * -50
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												allowing = true
												local direction = (target.pos - myHero.pos):Normalize()
												local extendedPos = target.pos - direction * -50
												Control.CastSpell(HK_E, extendedPos)
											end
										end
									end
								end
							end
							
							if size() == 0 and Ready(_E) and Ready(_Q) then
								if Menu.Combo.ETurret:Value() then
									if not IsUnderTurret(target) then
										allowing = true
										local direction = (target.pos - myHero.pos):Normalize()
										local extendedPos = target.pos - direction * -50
										Control.CastSpell(HK_E, extendedPos)
									end
								else
									allowing = true
									local direction = (target.pos - myHero.pos):Normalize()
									local extendedPos = target.pos - direction * -50
									Control.CastSpell(HK_E, extendedPos)
								end
							end
							
							if target.pos:DistanceTo(myHero.pos) < spellQ.range and Ready(_Q) then
								allowing = true
								Control.CastSpell(HK_Q, target)
							end
						end
					end	
				end
			end
		end
	end
	
	if target then
		if IsValid(target) then
			if not HasBuff(myHero, "katarinarsound") then

				if Menu.Combo.combomode:Value() == 1 then
					
					if Menu.Combo.UseQ:Value() and Ready(_Q) then
						if target.pos:DistanceTo(myHero.pos) <= spellQ.range then
							Control.CastSpell(HK_Q, target)
						end
					end
					
					if Menu.Combo.UseE:Value() and not Ready(_Q) then
						if size() > 0 and Ready(_E) then
							for _, objs in pairs(objHolder) do
								if objs then
								
									if not Menu.Combo.SaveE:Value() then
									
										if target.pos:DistanceTo(objs.pos) < 450 then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(objs) then
													local direction = (objs.pos - target.pos):Normalize()
													local extendedPos = objs.pos - direction * 200
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):Normalize()
												local extendedPos = objs.pos - direction * 200
												Control.CastSpell(HK_E, extendedPos)
											end
										end
										
										if Menu.Combo.emode:Value() == 1 then										
											if objs.pos:DistanceTo(myHero.pos) > spellE.range then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * 50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
											
											if objs.pos:DistanceTo(target.pos) > 450 then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * 50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
										
										
										elseif Menu.Combo.emode:Value() == 2 then
											if objs.pos:DistanceTo(myHero.pos) > spellE.range then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * -50
													Control.CastSpell(HK_E, extendedPos)
												end
											end

											if objs.pos:DistanceTo(target.pos) > 450 then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * -50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
										
										else
										
											if not Ready(_R) then
												if objs.pos:DistanceTo(myHero.pos) > spellE.range then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * 50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												end
												
												if objs.pos:DistanceTo(target.pos) > 450 then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * 50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												end

											else
											
												if objs.pos:DistanceTo(myHero.pos) > spellE.range then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * -50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												end

												if objs.pos:DistanceTo(target.pos) > 450 then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * -50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												end
											end
										end

									else
									
										if target.pos:DistanceTo(objs.pos) < 450 then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(objs) then
													local direction = (objs.pos - target.pos):Normalize()
													local extendedPos = objs.pos - direction * 200
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):Normalize()
												local extendedPos = objs.pos - direction * 200
												Control.CastSpell(HK_E, extendedPos)
											end
										end
									end
								end
							end
						end
						
						if size() == 0 and Ready(_E) then							
							if not Menu.Combo.SaveE:Value() then
								
								if Menu.Combo.emode:Value() == 1 then
									if Menu.Combo.ETurret:Value() then
										if not IsUnderTurret(target) then
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * 50
											Control.CastSpell(HK_E, extendedPos)
										end
									else
										local direction = (target.pos - myHero.pos):Normalize()
										local extendedPos = target.pos - direction * 50
										Control.CastSpell(HK_E, extendedPos)
									end

								elseif Menu.Combo.emode:Value() == 2 then
									if Menu.Combo.ETurret:Value() then
										if not IsUnderTurret(target) then
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * -50
											Control.CastSpell(HK_E, extendedPos)
										end
									else
										local direction = (target.pos - myHero.pos):Normalize()
										local extendedPos = target.pos - direction * -50
										Control.CastSpell(HK_E, extendedPos)
									end

								else
								
									if not Ready(_R) then
										if Menu.Combo.ETurret:Value() then
											if not IsUnderTurret(target) then
												local direction = (target.pos - myHero.pos):Normalize()
												local extendedPos = target.pos - direction * 50
												Control.CastSpell(HK_E, extendedPos)
											end
										else
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * 50
											Control.CastSpell(HK_E, extendedPos)
										end

									else
									
										if Menu.Combo.ETurret:Value() then
											if not IsUnderTurret(target) then
												local direction = (target.pos - myHero.pos):Normalize()
												local extendedPos = target.pos - direction * -50
												Control.CastSpell(HK_E, extendedPos)
											end
										else
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * -50
											Control.CastSpell(HK_E, extendedPos)
										end
									end
								end
							end
						end
					end
					
					if Menu.Combo.UseW:Value() and Ready(_W) then
						if target.pos:DistanceTo(myHero.pos) <= spellW.range then
							Control.CastSpell(HK_W, target.pos)
						end
					end
					
					if Menu.Combo.rset.rmode:Value() == 1 and Ready(_R) then
						if target.pos:DistanceTo(myHero.pos) <= spellR.range - 50 then
							if GetEnemyCount(spellR.range - 100, myHero) >= Menu.Combo.rset.rhit:Value() then
								if target.health/target.maxHealth >= Menu.Combo.rset.HP:Value()/100 and not Ready(_Q) then
									if not Ready(_W) then
										Control.CastSpell(HK_R)
									end
								end
							end
						end
					
					elseif Menu.Combo.rset.rmode:Value() == 2 and Ready(_R) then
						if target.pos:DistanceTo(myHero.pos) <= spellR.range - 50 then
							if target.health <= (RDamage(target) + EDamage(target) + PDamage(target) + getdmg("Q", target, myHero)) then
								if target.health/target.maxHealth >= Menu.Combo.rset.HP:Value()/100 and not Ready(_Q) then
									if not Ready(_W) then
										Control.CastSpell(HK_R)
									end
								end
							end
						end
					end
				
				elseif Menu.Combo.combomode:Value() == 2 then
					
					if Menu.Combo.UseE:Value() and Ready(_E) then
						if size() > 0 then
							for _, objs in pairs(objHolder) do
								if objs then
									
									if not Menu.Combo.SaveE:Value() then
										if target.pos:DistanceTo(objs.pos) < 450 then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(objs) then
													local direction = (objs.pos - target.pos):Normalize()
													local extendedPos = objs.pos - direction * 200
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):Normalize()
												local extendedPos = objs.pos - direction * 200
												Control.CastSpell(HK_E, extendedPos)
											end
										end
										
										if Menu.Combo.emode:Value() == 1 then
											if objs.pos:DistanceTo(myHero.pos) > spellE.range then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * 50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
											
											if objs.pos:DistanceTo(target.pos) > 450 then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * 50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
										
										elseif Menu.Combo.emode:Value() == 2 then
											if objs.pos:DistanceTo(myHero.pos) > spellE.range then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * -50
													Control.CastSpell(HK_E, extendedPos)
												end
											end

											if objs.pos:DistanceTo(target.pos) > 450 then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * -50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
										
										else
										
											if not Ready(_R) then
												if objs.pos:DistanceTo(myHero.pos) > spellE.range then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * 50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												end
												
												if objs.pos:DistanceTo(target.pos) > 450 then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * 50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												end

											else
											
												if objs.pos:DistanceTo(myHero.pos) > spellE.range then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * -50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												end

												if objs.pos:DistanceTo(target.pos) > 450 then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * -50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												end
											end
										end
									
									else
		
										if target.pos:DistanceTo(objs.pos) < 450 then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(objs) then
													local direction = (objs.pos - target.pos):Normalize()
													local extendedPos = objs.pos - direction * 200
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):Normalize()
												local extendedPos = objs.pos - direction * 200
												Control.CastSpell(HK_E, extendedPos)
											end
										end
									end
								end
							end
						end
						
						if size() == 0 then
							if not Menu.Combo.SaveE:Value() then
								
								if Menu.Combo.emode:Value() == 1 then
									if Menu.Combo.ETurret:Value() then
										if not IsUnderTurret(target) then
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * 50
											Control.CastSpell(HK_E, extendedPos)
										end
									else
										local direction = (target.pos - myHero.pos):Normalize()
										local extendedPos = target.pos - direction * 50
										Control.CastSpell(HK_E, extendedPos)
									end

								elseif Menu.Combo.emode:Value() == 2 then
									if Menu.Combo.ETurret:Value() then
										if not IsUnderTurret(target) then
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * -50
											Control.CastSpell(HK_E, extendedPos)
										end
									else
										local direction = (target.pos - myHero.pos):Normalize()
										local extendedPos = target.pos - direction * -50
										Control.CastSpell(HK_E, extendedPos)
									end
								
								else
					
									if not Ready(_R) then
										if Menu.Combo.ETurret:Value() then
											if not IsUnderTurret(target) then
												local direction = (target.pos - myHero.pos):Normalize()
												local extendedPos = target.pos - direction * 50
												Control.CastSpell(HK_E, extendedPos)
											end
										else
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * 50
											Control.CastSpell(HK_E, extendedPos)
										end
									
									else
							
										if Menu.Combo.ETurret:Value() then
											if not IsUnderTurret(target) then
												local direction = (target.pos - myHero.pos):Normalize()
												local extendedPos = target.pos - direction * -50
												Control.CastSpell(HK_E, extendedPos)
											end
										else
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * -50
											Control.CastSpell(HK_E, extendedPos)
										end
									end
								end
							end
						end
					end

					if Menu.Combo.UseW:Value() and Ready(_W) then
						if target.pos:DistanceTo(myHero.pos) <= spellW.range then
							Control.CastSpell(HK_W, target.pos)
						end
					end
					
					if Menu.Combo.UseQ:Value() and Ready(_Q) then
						if target.pos:DistanceTo(myHero.pos) <= spellQ.range then
							Control.CastSpell(HK_Q, target)
						end
					end
					
					if Menu.Combo.rset.rmode:Value() == 1 and Ready(_R) then
						if target.pos:DistanceTo(myHero.pos) <= spellR.range - 50 then
							if GetEnemyCount(spellR.range - 100, myHero) >= Menu.Combo.rset.rhit:Value() then
								if target.health/target.maxHealth >= Menu.Combo.rset.HP:Value()/100 and not Ready(_Q) then
									if not Ready(_W) then
										Control.CastSpell(HK_R)
									end
								end
							end
						end
					
					elseif Menu.Combo.rset.rmode:Value() == 2 and Ready(_R) then
						if target.pos:DistanceTo(myHero.pos) <= spellR.range - 50 then
							if target.health <= (RDamage(target) + EDamage(target) + PDamage(target) + getdmg("Q", target, myHero)) then
								if target.health/target.maxHealth >= Menu.Combo.rset.HP:Value()/100 and not Ready(_Q) then
									if not Ready(_W) then
										Control.CastSpell(HK_R)
									end
								end
							end
						end
					end
				
				else
				
					if Menu.Combo.UseQ:Value() and Ready(_Q) and not Ready(_R) then
						if target.pos:DistanceTo(myHero.pos) <= spellQ.range then
							Control.CastSpell(HK_Q, target)
						end
					end
					
					if Menu.Combo.UseE:Value() and Ready(_E) then
						if size() > 0 then
							for _, objs in pairs(objHolder) do
								if objs then
									if not Menu.Combo.SaveE:Value() then
										if target.pos:DistanceTo(objs.pos) < 450 then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(objs) then
													local direction = (objs.pos - target.pos):Normalize()
													local extendedPos = objs.pos - direction * 200
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):Normalize()
												local extendedPos = objs.pos - direction * 200
												Control.CastSpell(HK_E, extendedPos)
											end
										end
										
										if Menu.Combo.emode:Value() == 1 then
											if objs.pos:DistanceTo(myHero.pos) > spellE.range then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * 50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
											
											if (objs.pos:DistanceTo(target.pos) > 450) then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * 50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
										
										elseif Menu.Combo.emode:Value() == 2 then
											if objs.pos:DistanceTo(myHero.pos) > spellE.range then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * -50
													Control.CastSpell(HK_E, extendedPos)
												end
											end

											if (objs.pos:DistanceTo(target.pos) > 450) then
												if Menu.Combo.ETurret:Value() then
													if not IsUnderTurret(target) then
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												else
													local direction = (target.pos - myHero.pos):Normalize()
													local extendedPos = target.pos - direction * -50
													Control.CastSpell(HK_E, extendedPos)
												end
											end
										
										else
										
											if not Ready(_R) then
												if objs.pos:DistanceTo(myHero.pos) > spellE.range then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * 50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												end
												
												if (objs.pos:DistanceTo(target.pos) > 450) then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * 50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * 50
														Control.CastSpell(HK_E, extendedPos)
													end
												end
											
											else
								
												if objs.pos:DistanceTo(myHero.pos) > spellE.range then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * -50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												end

												if (objs.pos:DistanceTo(target.pos) > 450) then
													if Menu.Combo.ETurret:Value() then
														if not IsUnderTurret(target) then
															local direction = (target.pos - myHero.pos):Normalize()
															local extendedPos = target.pos - direction * -50
															Control.CastSpell(HK_E, extendedPos)
														end
													else
														local direction = (target.pos - myHero.pos):Normalize()
														local extendedPos = target.pos - direction * -50
														Control.CastSpell(HK_E, extendedPos)
													end
												end
											end
										end
									
									else
								
										if (target.pos:DistanceTo(objs.pos) < 450) then
											if Menu.Combo.ETurret:Value() then
												if not IsUnderTurret(objs) then
													local direction = (objs.pos - target.pos):Normalize()
													local extendedPos = objs.pos - direction * 200
													Control.CastSpell(HK_E, extendedPos)
												end
											else
												local direction = (objs.pos - target.pos):Normalize()
												local extendedPos = objs.pos - direction * 200
												Control.CastSpell(HK_E, extendedPos)
											end
										end
									end
								end
							end
						end
						
						if size() == 0 then
							if not Menu.Combo.SaveE:Value() then
								
								if Menu.Combo.emode:Value() == 1 then
									if Menu.Combo.ETurret:Value() then
										if not IsUnderTurret(target) then
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * 50
											Control.CastSpell(HK_E, extendedPos)
										end
									else
										local direction = (target.pos - myHero.pos):Normalize()
										local extendedPos = target.pos - direction * 50
										Control.CastSpell(HK_E, extendedPos)
									end

								elseif Menu.Combo.emode:Value() == 2 then
									if Menu.Combo.ETurret:Value() then
										if not IsUnderTurret(target) then
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * -50
											Control.CastSpell(HK_E, extendedPos)
										end
									else
										local direction = (target.pos - myHero.pos):Normalize()
										local extendedPos = target.pos - direction * -50
										Control.CastSpell(HK_E, extendedPos)
									end
									
								else
							
									if not Ready(_R) then
										if Menu.Combo.ETurret:Value() then
											if not IsUnderTurret(target) then
												local direction = (target.pos - myHero.pos):Normalize()
												local extendedPos = target.pos - direction * 50
												Control.CastSpell(HK_E, extendedPos)
											end
										else
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * 50
											Control.CastSpell(HK_E, extendedPos)
										end
									
									else
							
										if Menu.Combo.ETurret:Value() then
											if not IsUnderTurret(target) then
												local direction = (target.pos - myHero.pos):Normalize()
												local extendedPos = target.pos - direction * -50
												Control.CastSpell(HK_E, extendedPos)
											end
										else
											local direction = (target.pos - myHero.pos):Normalize()
											local extendedPos = target.pos - direction * -50
											Control.CastSpell(HK_E, extendedPos)
										end
									end
								end
							end
						end
					end
					
					if Menu.Combo.UseW:Value() and Ready(_W) then
						if target.pos:DistanceTo(myHero.pos) <= spellW.range then
							Control.CastSpell(HK_W, target.pos)
						end
					end

					if Ready(_R) and target.pos:DistanceTo(myHero.pos) <= spellR.range - 50 then
						if not Ready(_W) then
							Control.CastSpell(HK_R)
						end
					end
				end
			end
		end
	end
end

local function Harass()
	local target = GetTarget(775)
	if target and IsValid(target) then
		
		if Menu.Harass.harassmode:Value() == 1 then
			if Menu.Harass.UseW:Value() and Ready(_W) then
				if target.pos:DistanceTo(myHero.pos) <= spellW.range then
					Control.CastSpell(HK_W, target.pos)
				end
			end
			
			if Menu.Harass.UseQ:Value() and Ready(_Q) then
				if target.pos:DistanceTo(myHero.pos) <= spellQ.range then
					Control.CastSpell(HK_Q, target)
				end
			end
			
			if Menu.Harass.UseE:Value() and Ready(_E) and not Ready(_Q) then
				if target.pos:DistanceTo(myHero.pos) <= spellE.range then
					for _, objs in pairs(objHolder) do
						if objs then
						
							if (target.pos:DistanceTo(objs.pos) < 450) then
								local direction = (objs.pos - target.pos):Normalize()
								local extendedPos = objs.pos - direction * 200
								Control.CastSpell(HK_E, extendedPos)
							end
							
							if (objs.pos:DistanceTo(myHero.pos) > spellE.range) then
								local direction = (target.pos - myHero.pos):Normalize()
								local extendedPos = target.pos - direction * 50
								Control.CastSpell(HK_E, extendedPos)
							end
						end
					end

					if size() == 0 then
						local direction = (target.pos - myHero.pos):Normalize()
						local extendedPos = target.pos - direction * 50
						Control.CastSpell(HK_E, extendedPos)
					end
				end
			end
		
		else
		
			if Menu.Harass.UseW:Value() and Ready(_W) then
				if target.pos:DistanceTo(myHero.pos) <= spellW.range then
					Control.CastSpell(HK_W, target.pos)
				end
			end
			
			if Menu.Harass.UseE:Value() and Ready(_E) then
				if target.pos:DistanceTo(myHero.pos) <= spellE.range then
					for _, objs in pairs(objHolder) do
						if objs then
						
							if (target.pos:DistanceTo(objs.pos) < 450) then
								local direction = (objs.pos - target.pos):Normalize()
								local extendedPos = objs.pos - direction * 200
								Control.CastSpell(HK_E, extendedPos)
							end
							
							if (objs.pos:DistanceTo(myHero.pos) > spellE.range) then
								local direction = (target.pos - myHero.pos):Normalize()
								local extendedPos = target.pos - direction * 50
								Control.CastSpell(HK_E, extendedPos)
							end
						end
					end

					if size() == 0 then
						local direction = (target.pos - myHero.pos):Normalize()
						local extendedPos = target.pos - direction * 50
						Control.CastSpell(HK_E, extendedPos)
					end
				end
			end

			if Menu.Harass.UseQ:Value() and Ready(_Q) and not Ready(_E) then
				if target.pos:DistanceTo(myHero.pos) <= spellQ.range then
					Control.CastSpell(HK_Q, target)
				end
			end
		end
	end
end


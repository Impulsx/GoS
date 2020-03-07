local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function CastSpellMM(spell,pos,range,delay)
	local range = range or math.huge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x,castPosMM.y)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency then
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

local function GetEnemyHeroes()
	return Enemies
end

local function IsKnockedUp(unit)
	if unit == nil then return false end
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 29 or buff.type == 30 or buff.type == 39) and buff.count > 0 then
			return true
		end
	end
	return false	
end
	
local function KnockedUpEnemies(range)
local count = 0
local rangeSqr = range * range
	for i = 1, GameHeroCount()do
	local hero = GameHero(i)
		if hero.isEnemy and hero.alive and GetDistanceSqr(myHero.pos, hero.pos) <= rangeSqr then
			if IsKnockedUp(hero)then
				count = count + 1
			end
		end
	end
	return count
end

local UltSpells = {
	["LuxMaliceCannon"] = {charName = "Lux"},
	["EnchantedCrystalArrow"] = {charName = "Ashe"},
	["DravenRCast"] = {charName = "Draven"},
	["EzrealR"] = {charName = "Ezreal"},	
	["JinxR"] = {charName = "Jinx"},
	["LucianR"] = {charName = "Lucian"},
	["NeekoR"] = {charName = "Neeko"},
	["RivenFengShuiEngine"] = {charName = "Riven"},	
	["SonaR"] = {charName = "Sona"},
	["ThreshRPenta"] = {charName = "Thresh"},
	["YasuoR"] = {charName = "Yasuo"},
}

function LoadScript()
	HPred()	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})	

	--AutoW
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})	
	Menu.AutoW:MenuElement({id = "UseW", name = "Safe Life", value = true})
	Menu.AutoW:MenuElement({id = "hp", name = "Self Hp", value = 40, min = 1, max = 40, identifier = "%"})	

	--AutoR
	Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoR"})	
	Menu.AutoR:MenuElement({id = "UseR", name = "Auto Pulling Ult", value = true})
	Menu.AutoR:MenuElement({type = MENU, id = "Target", name = "Target Settings"})
	DelayAction(function()
		for i, hero in pairs(GetEnemyHeroes()) do
			Menu.AutoR.Target:MenuElement({id = "ult"..hero.charName, name = "Pull Ult: "..hero.charName, value = true})
			
		end	
	end, 0.01)

		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})
	
	---------------------------------------------------------------------------------------------------------------------------------
	--UltSettings
	Menu.Combo:MenuElement({type = MENU, id = "Set", name = "Ult Settings"})
	--SkillShot+E Ults
	Menu.Combo.Set:MenuElement({id = "UltE", name = "Auto E+E2+SkillShotUlt", key = string.byte("T")})	
	Menu.Combo.Set:MenuElement({id = "BlockList", name = "E+E2+Ult List", type = MENU})
	DelayAction(function()
		for i, spell in pairs(UltSpells) do
			if not UltSpells[i] then return end
			for j, k in pairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not Menu.Combo.Set.BlockList[i] then
					if not Menu.Combo.Set.BlockList[i] then Menu.Combo.Set.BlockList:MenuElement({id = "Ult"..i, name = ""..spell.charName.."", value = true}) end
				end
			end
		end
	end, 0.01)
	
	--Heal+Shield Ults
	Menu.Combo.Set:MenuElement({id = "Heal", name = "Use HEAL+Shield Ults", value = true})   								
	Menu.Combo.Set:MenuElement({id = "HP", name = "MinHP Heal+Shield", value = 30, min = 0, max = 100, identifier = "%"})	
	--AOE Ults
	Menu.Combo.Set:MenuElement({id = "AOE", name = "Use AOE Ults", value = true})	   										
	Menu.Combo.Set:MenuElement({id = "Hit", name = "MinTargets AOE Ults", value = 2, min = 1, max = 5})	
	--KS Ults
	Menu.Combo.Set:MenuElement({id = "LastHit", name = "Use DMG Ults to kill Enemy", value = true})						
	---------------------------------------------------------------------------------------------------------------------------------
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({type = MENU, id = "LH", name = "LastHit"})	
	Menu.Harass.LH:MenuElement({id = "UseQL", name = "LastHit[Q] Minions", value = true, tooltip = "There is no Enemy nearby"})
	Menu.Harass.LH:MenuElement({id = "UseQLM", name = "LastHit[Q] min Minions", value = 2, min = 1, max = 6})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQL", name = "[Q] Chain Lash", value = true})	
	Menu.Clear:MenuElement({id = "UseQLM", name = "[Q] min Minions", value = 2, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})  
	Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})		
	Menu.ks:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})

	Q = {range = 775, radius = 70, delay = 0.25, speed = 1800, collision = false}    
	W = {range = 400, radius = 70, delay = 0.25, speed = 20, collision = false}      
	E = {range = 800, radius = 60, delay = 0.25, speed = 1800, collision = true}   
	R = {range = 800}	
  	
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
	local textPos = myHero.pos:To2D()

		if myHero.dead then return end
		if(Menu.Drawing.DrawR:Value()) and Ready(_R) then
		DrawCircle(myHero, 1050, 1, DrawColor(255, 225, 255, 10)) 
		end                                                 
		if(Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
		DrawCircle(myHero, 755, 1, DrawColor(225, 225, 0, 10))
		end
		if(Menu.Drawing.DrawE:Value()) and Ready(_E) then
		DrawCircle(myHero, 800, 1, DrawColor(225, 225, 125, 10))
		end
		if(Menu.Drawing.DrawW:Value()) and Ready(_W) then
		DrawCircle(myHero, 400, 1, DrawColor(225, 225, 125, 10))
		end
		local target = GetTarget(20000)
		if target == nil then return end	
		if Menu.Drawing.Kill:Value() and IsValid(target) then
		local hp = target.health
		local fullDmg = (getdmg("Q", target, myHero) + getdmg("E", target, myHero) + getdmg("W", target, myHero))	
			if Ready(_Q) and getdmg("Q", target, myHero) > hp then
				DrawText("Killable", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
				DrawText("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))
			end	
			if Ready(_E) and getdmg("E", target, myHero) > hp then
				DrawText("Killable", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
				DrawText("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))		
			end	
			if Ready(_W) and getdmg("W", target, myHero) > hp then
				DrawText("Killable", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
				DrawText("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))	
			end
			if Ready(_W) and Ready(_E) and Ready(_Q) and fullDmg > hp then
				DrawText("Killable", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
				DrawText("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))	
			end		
		end	
		local Ult = {"LuxMaliceCannon","EnchantedCrystalArrow","DravenRCast","EzrealR","JinxR","LucianR","NeekoR","RivenFengShuiEngine","SonaR","ThreshRPenta","YasuoR"}	
		if table.contains(Ult, myHero:GetSpellData(_R).name) then 
			DrawText("E+E2+Ult[Press Key]", 20, textPos.x - 80, textPos.y + 40, DrawColor(255, 000, 255, 000))
		end	
	end)		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	
	if Mode == "Combo" then
		Combo()
		if myHero:GetSpellData(_R).name ~= "SylasR" then	
			HealShieldUlt()
			AoeUlt()
			KsUlt()
		end		--131 champs added  
		
	elseif Mode == "Harass" then
		Harass()
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		local target = GetTarget(1000)
			if target == nil then	
				if myHero.pos:DistanceTo(minion.pos) <= 800 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then	
					local count = GetMinionCount(225, minion)			
					local hp = minion.health
					local QDmg = getdmg("Q", minion, myHero)
					if Ready(_Q) and Menu.Harass.LH.UseQL:Value() and count >= Menu.Harass.LH.UseQLM:Value() and hp <= QDmg then
						ControlCastSpell(HK_Q, minion)
					end	 
				end
			end
		end
		
	elseif Mode == "Clear" then
		Clear()
		JungleClear()		
	end	
	
	if Menu.Combo.Set.UltE:Value() then
		EUlt()
	end
	
	KillSteal()	

	   				
	local target = GetTarget(1200)  
	if target == nil then return end
	if Ready(_R) and IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1050 and Menu.AutoR.UseR:Value() and Menu.AutoR.Target["ult"..target.charName]:Value() then		
		if myHero:GetSpellData(_R).name == "SylasR" and not HasBuff(target, "SylasR") then                     
				ControlCastSpell(HK_R, target)
		end
	end	
 
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 400 and Menu.AutoW.UseW:Value() and Ready(_W) then
		if myHero.health/myHero.maxHealth <= Menu.AutoW.hp:Value()/100 then
			ControlCastSpell(HK_W, target)
		end
	end
end

function EUlt()
local target = GetTarget(3500)
if target == nil then return end
	if IsValid(target) then
	local Ult = {"LuxMaliceCannon","EnchantedCrystalArrow","DravenRCast","EzrealR","JinxR","LucianR","NeekoR","RivenFengShuiEngine","SonaR","ThreshRPenta","YasuoR"}	
	if not table.contains(Ult, myHero:GetSpellData(_R).name) then return end	
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" and Ready(_E) then	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 1 then
				ControlCastSpell(HK_E, aimPosition)
			end
		
		elseif myHero.pos:DistanceTo(target.pos) < 1300 and myHero:GetSpellData(_E).name == "SylasE" and Ready(_E) then			
			ControlCastSpell(HK_E, target.pos)
		end
		
		
		if myHero:GetSpellData(_E).name == "SylasE2" then		
			ControlCastSpell(HK_R, target.pos) 		
		end
	end
end

--------------------------KS Ults---------------------------------------------------
function KsUlt()

local target = GetTarget(25000)     	
if target == nil then return end
	if IsValid(target) and Menu.Combo.Set.LastHit:Value() and Ready(_R) then
	local hp = target.health		
		if (myHero:GetSpellData(_R).name == "AatroxR") then										--Aatrox 
			ControlCastSpell(HK_R, target)
			
		end
	





		if (myHero:GetSpellData(_R).name == "AhriTumble") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Ahri 
			if getdmg("R", target, myHero, 70) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "AkaliR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Akali 
			if getdmg("R", target, myHero, 20) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "AkaliRb") and myHero.pos:DistanceTo(target.pos) <= 750 then		--Akalib
			if getdmg("R", target, myHero, 21) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "FerociousHowl") then										--Alistar
			ControlCastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "CurseoftheSadMummy") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Amumu 
			if getdmg("R", target, myHero, 22) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "GlacialStorm") and myHero.pos:DistanceTo(target.pos) <= 750 then		--Anivia
			if getdmg("R", target, myHero, 13) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "AnnieR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Annie   	 
			if getdmg("R", target, myHero, 23) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "EnchantedCrystalArrow") and myHero.pos:DistanceTo(target.pos) <= 25000 then		--Ashe 
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.25, 1600, 130, false)
			if getdmg("R", target, myHero, 3) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					ControlCastSpell(HK_R, castPos)
				end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "AurelionSolR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--AurelionSol
			if getdmg("R", target, myHero, 14) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "AzirR") and myHero.pos:DistanceTo(target.pos) <= 250 then		--Azir
			if getdmg("R", target, myHero, 24) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "BlitzcrankR") and myHero.pos:DistanceTo(target.pos) <= 600 then	
			if getdmg("R", target, myHero, 26) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "BrandR") and myHero.pos:DistanceTo(target.pos) <= 750 then		--brand
			if getdmg("R", target, myHero, 48) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "BraumRWrapper") and myHero.pos:DistanceTo(target.pos) <= 1250 then		--Braum  
			if getdmg("R", target, myHero, 15) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	



		if (myHero:GetSpellData(_R).name == "CaitlynAceintheHole") and myHero.pos:DistanceTo(target.pos) <= 3500 then		--Caitlyn 
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 3500, 3.0, 3200, 50, true)
			if getdmg("R", target, myHero, 64) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					ControlCastSpell(HK_R, castPos)
				end	
			end
		end
	



		if (myHero:GetSpellData(_R).name == "CamilleR") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Camille
			ControlCastSpell(HK_R, target)
		end





		if (myHero:GetSpellData(_R).name == "CassiopeiaR") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Cassiopeia
			if getdmg("R", target, myHero, 10) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "Feast") and myHero.pos:DistanceTo(target.pos) <= 200 then		--Cho'gath
			if getdmg("R", target, myHero, 2) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "MissileBarrageMissile") and myHero.pos:DistanceTo(target.pos) <= 1225 then		--Corki
			if getdmg("R", target, myHero, 30) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "DariusExecute") and myHero.pos:DistanceTo(target.pos) <= 460 then		--Darius
			if getdmg("R", target, myHero, 71) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "DianaTeleport") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Diana
			if getdmg("R", target, myHero, 34) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	





		if (myHero:GetSpellData(_R).name == "DravenRCast") and myHero.pos:DistanceTo(target.pos) <= 25000 then		--Draven   
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.25, 2000, 160, false)
			if getdmg("R", target, myHero, 27) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					ControlCastSpell(HK_R, castPos)
				end	
			end
		end
	




		if (myHero:GetSpellData(_R).name == "EkkoR") and myHero.pos:DistanceTo(target.pos) <= 375 then		--Ekko
			if getdmg("R", target, myHero, 72) > hp then
				ControlCastSpell(HK_R)
			end
		end
	


--function Sylas:UltElise()



		if (myHero:GetSpellData(_R).name == "EvelynnR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Evelynn      
			local damage = getdmg("R", target, myHero, 25)*2
			if target.health/target.maxHealth <= 30/100 and damage > hp then
				ControlCastSpell(HK_R, target)
			elseif getdmg("R", target, myHero, 25) > hp then
				ControlCastSpell(HK_R, target)	
			end
		end
	





		if (myHero:GetSpellData(_R).name == "EzrealR") and myHero.pos:DistanceTo(target.pos) <= 25000 then		--ezreal
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 1.0, 2000, 160, false)
			if getdmg("R", target, myHero, 6) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					ControlCastSpell(HK_R, castPos)
				end	
			end
		end
	



		if (myHero:GetSpellData(_R).name == "Crowstorm") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Fiddlesticks
			if getdmg("R", target, myHero, 54) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	





		if (myHero:GetSpellData(_R).name == "FizzR") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Fizz   
			if getdmg("R", target, myHero, 28) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		local level = myHero:GetSpellData(_R).level
		local range = ({4000, 4750, 5500})[level]
		local count = GetEnemyCount(1000, myHero)

		if (myHero:GetSpellData(_R).name == "GalioR") and myHero.pos:DistanceTo(target.pos) <= range and count == 0 then		--Galio   
			if getdmg("R", target, myHero, 73) > hp then
				if target.pos:To2D().onScreen then						
					ControlCastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, range, 250)		
				end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "GangplankR") and myHero.pos:DistanceTo(target.pos) <= 20000 then		--Gankplank   
			if getdmg("R", target, myHero, 55) > hp then
				if target.pos:To2D().onScreen then						-----------check ist target in sichtweite
					ControlCastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			-----------ist target auserhalb sichtweite
					CastSpellMM(HK_R, target.pos, 20000, 500)		-----------CastSpellMM(HK_R, target.pos, range, delay)
				end
			end
		end
	




		local missingHP = (target.maxHealth - target.health)/100 * 0.286
		local missingHP2 = (target.maxHealth - target.health)/100 * 0.333
		local missingHP3 = (target.maxHealth - target.health)/100 * 0.4
		local damage = getdmg("R", target, myHero, 49) + missingHP
		local damage2 = getdmg("R", target, myHero, 49) + missingHP2
		local damage3 = getdmg("R", target, myHero, 49) + missingHP3

		if (myHero:GetSpellData(_R).name == "GarenR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Garen
			if damage3  > hp then
				ControlCastSpell(HK_R, target)
			elseif damage2  > hp then
				ControlCastSpell(HK_R, target)
			elseif damage  > hp then
				ControlCastSpell(HK_R, target)	
			end
		end
	



		if (myHero:GetSpellData(_R).name == "GnarR") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Gnar     
			if getdmg("R", target, myHero, 29) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "GragasR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Gragas   
			if getdmg("R", target, myHero, 30) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	



		if (myHero:GetSpellData(_R).name == "GravesChargeShot") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Graves  
			if getdmg("R", target, myHero, 31) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "HecarimUlt") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Hecarim  
			if getdmg("R", target, myHero, 32) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "HeimerdingerR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Heimerdinger
				ControlCastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "IllaoiR") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Illaoi
			if getdmg("R", target, myHero, 56) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "IreliaR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Irelia
			if getdmg("R", target, myHero, 16) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "IvernR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Ivern
			ControlCastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "JarvanIVCataclysm") and myHero.pos:DistanceTo(target.pos) <= 650 then		--jarvan
			if getdmg("R", target, myHero, 57) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




--function Sylas:UltJayyce()      


--		if (myHero:GetSpellData(_R).name == "JhinRShot") and myHero.pos:DistanceTo(target.pos) <= 525 then		--Jhin   orbwalker block für die ulti
--			if getdmg("R", target, myHero, 33) > hp then
--				ControlCastSpell(HK_R, target)
--			end
--		end

	



		if (myHero:GetSpellData(_R).name == "JinxR") and myHero.pos:DistanceTo(target.pos) <= 25000 then		--jinx
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.6, 1700, 140, false)
			if getdmg("R", target, myHero, 7) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					ControlCastSpell(HK_R, castPos)
				end
			end
		end



     

--function Sylas:UltKallista()


		if (myHero:GetSpellData(_R).name == "KarmaMantra") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Karma
			ControlCastSpell(HK_R)
			
		end
	



		if (myHero:GetSpellData(_R).name == "KarthusFallenOne") and myHero.pos:DistanceTo(target.pos) <= 20000 then		--karthus
			if getdmg("R", target, myHero, 8) > hp then
				ControlCastSpell(HK_R)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "RiftWalk") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Kassadin
			if getdmg("R", target, myHero, 58) > hp then
				ControlCastSpell(HK_R, target)
			end
		end





		if (myHero:GetSpellData(_R).name == "KatarinaR") and myHero.pos:DistanceTo(target.pos) <= 550 then		
			if getdmg("R", target, myHero, 35) > hp then
				ControlCastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "KaisaR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--Kaisa  
			ControlCastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "KaynR") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Kayn 
			ControlCastSpell(HK_R, target)
			ControlCastSpell(HK_R, target)
			ControlCastSpell(HK_R, target)
		end
	




		if (myHero:GetSpellData(_R).name == "KennenShurikenStorm") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Kennen  
			if getdmg("R", target, myHero, 36) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "KledR") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Kled   
			ControlCastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "KogMawLivingArtillery") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Kogmaw   
			if getdmg("R", target, myHero, 59) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "LeblancSlideM") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Leblanc   
			if getdmg("R", target, myHero, 60) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "BlindMonkRKick") and myHero.pos:DistanceTo(target.pos) <= 375 then		--LeeSin   
			if getdmg("R", target, myHero, 74) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "LeonaSolarFlare") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--leona   
			if getdmg("R", target, myHero, 5) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "LissandraR") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Lissandra      
			if getdmg("R", target, myHero, 18) > hp then
				ControlCastSpell(HK_R, target)
			end
		end

	


		if (myHero:GetSpellData(_R).name == "LucianR") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--Lucian
			if getdmg("R", target, myHero, 61) > hp then
				ControlCastSpell(HK_R, target)
			end
		end

	


 
		if (myHero:GetSpellData(_R).name == "LuxMaliceCannon") and myHero.pos:DistanceTo(target.pos) <= 3500 then		
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 3500, 1, math.huge, 120, false)
			if getdmg("R", target, myHero, 11) > hp and hitRate and hitRate >= 1 then
				

				
				if aimPosition:To2D().onScreen then 		
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)    
					ControlCastSpell(HK_R, castPos)
				end	
			end
		end
	



		if (myHero:GetSpellData(_R).name == "UFSlash") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--malphite 
			if getdmg("R", target, myHero, 50) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "MalzaharR") and myHero.pos:DistanceTo(target.pos) <= 700 then		
			if getdmg("R", target, myHero, 19) > hp then
				ControlCastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "MaokaiR") and myHero.pos:DistanceTo(target.pos) <= 3000 then		--Maokai 
			if getdmg("R", target, myHero, 37) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "Highlander") and myHero.pos:DistanceTo(target.pos) <= 500 then		--MasterYi
			ControlCastSpell(HK_R, target)
			
		end






		if (myHero:GetSpellData(_R).name == "MissFortuneBulletTime") and myHero.pos:DistanceTo(target.pos) <= 1400 then		
			if getdmg("R", target, myHero, 38) > hp then
				ControlCastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end				
			end
		end
	

  

		if (myHero:GetSpellData(_R).name == "MordekaiserChildrenOfTheGrave") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Mordekaiser  
			ControlCastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "SoulShackles") and myHero.pos:DistanceTo(target.pos) <= 625 then		--morgana   
			if getdmg("R", target, myHero, 52) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	





		if (myHero:GetSpellData(_R).name == "NamiR") and myHero.pos:DistanceTo(target.pos) <= 2750 then		--Nami 
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 2750, 0.5, 850, 250, false)
			if getdmg("R", target, myHero, 39) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					ControlCastSpell(HK_R, castPos)
				end
			end
		end
	





		if (myHero:GetSpellData(_R).name == "NautilusR") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Nautilus  
			if getdmg("R", target, myHero, 40) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "NeekoR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Neeko
			if getdmg("R", target, myHero, 65) > hp then
				ControlCastSpell(HK_R, target)
			end
		end

	

--function Sylas:UltNiedalee()


		local level = myHero:GetSpellData(_R).level
		local range = ({2500, 3250, 4000})[level]
		if (myHero:GetSpellData(_R).name == "NocturneParanoia") and myHero.pos:DistanceTo(target.pos) <= range then		--Nocturne   
			if getdmg("R", target, myHero, 75) > hp then
				if target.pos:To2D().onScreen then						
					ControlCastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, range, 250)		
				end
			end
		end
	




		if (myHero:GetSpellData(_R).name == "NunuR") and myHero.pos:DistanceTo(target.pos) <= 650 then		
			if getdmg("R", target, myHero, 17) > hp then
				ControlCastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end					
			end
		end
	



		if (myHero:GetSpellData(_R).name == "OlafRagnarok") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--Olaf  
			if IsImmobileTarget(myHero) then
				ControlCastSpell(HK_R)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "OrianaDetonateCommand-") and myHero.pos:DistanceTo(target.pos) <= 325 then		--Orianna  
			if getdmg("R", target, myHero, 66) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "OrnnR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Ornn
			ControlCastSpell(HK_R, target)
			
		end
	




		local count = GetEnemyCount(1000, myHero)
		if (myHero:GetSpellData(_R).name == "PantheonRJump") and myHero.pos:DistanceTo(target.pos) <= 5500 and count == 0 then		--Phantheon   
			if getdmg("R", target, myHero, 76) > hp then
				if target.pos:To2D().onScreen then						
					ControlCastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5500, 2000)		
				end
			end
		end



		if (myHero:GetSpellData(_R).name == "PoppyRSpell") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Poppy  
			if getdmg("R", target, myHero, 77) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	


		if (myHero:GetSpellData(_R).name == "PykeR") and myHero.pos:DistanceTo(target.pos) <= 750 and getdmg("R", target, myHero, 86) > hp then	 
			ControlCastSpell(HK_R, target)
		end
	



		if (myHero:GetSpellData(_R).name == "QuinnR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Quinn   
			ControlCastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "RakanR") and myHero.pos:DistanceTo(target.pos) <= 300 then		--Rakan  
			if getdmg("R", target, myHero, 78) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	
  
  

		if (myHero:GetSpellData(_R).name == "Tremors2") and myHero.pos:DistanceTo(target.pos) <= 300 then		--Rammus   
			if getdmg("R", target, myHero, 62) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "RekSaiR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--RekSai   
			if getdmg("R", target, myHero, 79) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "RengarR") and myHero.pos:DistanceTo(target.pos) <= 800 then		--Rengar  
			ControlCastSpell(HK_R, target)
		
		end
	
	


		if (myHero:GetSpellData(_R).name == "RivenFengShuiEngine") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Riven   
			ControlCastSpell(HK_R)
		
		end
	




		if (myHero:GetSpellData(_R).name == "RumbleCarpetBombDummy") and myHero.pos:DistanceTo(target.pos) <= 1700 then		--Rumble   
			if getdmg("R", target, myHero, 41) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "SejuaniR") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Sejuani   
			if getdmg("R", target, myHero, 42) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "HallucinateFull") and myHero.pos:DistanceTo(target.pos) <= 500 then --Shaco 
			if getdmg("R", target, myHero, 80) > hp then
				ControlCastSpell(HK_R)
				ControlCastSpell(HK_R, target)
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "ShyvanaTransformCast") and myHero.pos:DistanceTo(target.pos) <= 1000 then --shyvana 
			if getdmg("R", target, myHero, 51) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	

   

		if (myHero:GetSpellData(_R).name == "SkarnerImpale") and myHero.pos:DistanceTo(target.pos) <= 350 then		--Skarner    
			ControlCastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "SonaR") and myHero.pos:DistanceTo(target.pos) <= 900 then		--Sona    
			if getdmg("R", target, myHero, 43) > hp then
				ControlCastSpell(HK_R, target)
			end
		end






		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Swain    
			if getdmg("R", target, myHero, 67) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	



		if (myHero:GetSpellData(_R).name == "SyndraR") and myHero.pos:DistanceTo(target.pos) <= 675 then		--Syndra    
			ControlCastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "TaliyahR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Taliyah   
			ControlCastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "TalonShadowAssault") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Talon   
			if getdmg("R", target, myHero, 81) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "ThreshRPenta") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Tresh   
			if getdmg("R", target, myHero, 68) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		local level = myHero:GetSpellData(_R).level
		local range = ({400, 650, 900})[level]
		if (myHero:GetSpellData(_R).name == "TeemoR") and myHero.pos:DistanceTo(target.pos) <= range then		--Teemo   
			ControlCastSpell(HK_R, target.pos)
		
		end
	



		local range = 517 + (8 * myHero.levelData.lvl)
		local hp = target.health
		if (myHero:GetSpellData(_R).name == "TristanaR") and myHero.pos:DistanceTo(target.pos) <= range then		--Tristana  	
			if getdmg("R", target, myHero, 12) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "TrundlePain") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Trundle     
			ControlCastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "TwitchFullAutomatic") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Twitch    
			ControlCastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "UdyrPhoenixStance") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Udyr    
			ControlCastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "UrgotR") and myHero.pos:DistanceTo(target.pos) <= 1600 then		--Urgot      
			if getdmg("R", target, myHero, 44) > hp then
				ControlCastSpell(HK_R, target)
			end	
			if target.health/target.maxHealth < 25/100 then
				ControlCastSpell(HK_R, target)	
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "VarusR") and myHero.pos:DistanceTo(target.pos) <= 1075 then		--Varus     
			if getdmg("R", target, myHero, 45) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "VayneInquisition") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Vayne     
			ControlCastSpell(HK_R)
			
		end
	




		if (myHero:GetSpellData(_R).name == "VeigarR") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Vaiger
			if getdmg("R", target, myHero, 4) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	

--function Sylas:KillUltVel'koz()


		if (myHero:GetSpellData(_R).name == "ViR") and myHero.pos:DistanceTo(target.pos) <= 800 then		--Vi
			if getdmg("R", target, myHero, 82) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "ViktorChaosStorm") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Viktor
			if getdmg("R", target, myHero, 83) > hp then
				ControlCastSpell(HK_R, target.pos)
				ControlCastSpell(HK_R, target.pos)
				ControlCastSpell(HK_R, target.pos)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Vladimir
			if getdmg("R", target, myHero, 63) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "VolibearR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Volibear
			if getdmg("R", target, myHero, 69) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	




		local range = 2.5 * myHero.ms
		if (myHero:GetSpellData(_R).name == "WarwickR") and myHero.pos:DistanceTo(target.pos) <= range then		--Warwick	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, range, 0.1, 1800, 55, false)
			if getdmg("R", target, myHero, 47) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					ControlCastSpell(HK_R, castPos)
				end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "WukongR") and myHero.pos:DistanceTo(target.pos) <= 200 then		--Wukong
			ControlCastSpell(HK_R)
		
		end
	




		if (myHero:GetSpellData(_R).name == "XayahR") and myHero.pos:DistanceTo(target.pos) <= 1100 then		--Xayah
			if getdmg("R", target, myHero, 84) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	
	

--[[

		local level = myHero:GetSpellData(_R).level
		local range = ({3520, 4840, 6160})[level]
		local count = GetEnemyCount(1000, myHero)
		if (myHero:GetSpellData(_R).name == "XerathLocusOfPower2") and myHero.pos:DistanceTo(target.pos) <= range and count == 0 then		--Xerath   
			if getdmg("R", target, myHero, 73) > hp then
				ControlCastSpell(HK_R)
				Control.SetCursorPos(target.pos)
				aim = TargetSelector:GetTarget(NEAR_MOUSE)
				if GetDistance(mousePos, aim) < 200 then						
					ControlCastSpell(HK_R) 
				end
			return end
		end
	
]]





		if (myHero:GetSpellData(_R).name == "YasuoR") and myHero.pos:DistanceTo(target.pos) <= 1400 then		--Yasou
			if getdmg("R", target, myHero, 85) > hp and self:IsKnockedUp(target) then
				ControlCastSpell(HK_R)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "YorickReviveAlly") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Yorick
			ControlCastSpell(HK_R, target)
		
		end
	



		local level = myHero:GetSpellData(_R).level
		local range = ({700, 850, 1000})[level]
		if (myHero:GetSpellData(_R).name == "ZacR") and myHero.pos:DistanceTo(target.pos) <= range then		--Zac  						
			ControlCastSpell(HK_R, target.pos) 
			ControlCastSpell(HK_R, target.pos)
			ControlCastSpell(HK_R, target.pos)
				
		end
	



		if (myHero:GetSpellData(_R).name == "ZedR") and myHero.pos:DistanceTo(target.pos) <= 625 then		--Zed
			ControlCastSpell(HK_R, target)
			ControlCastSpell(HK_R)
			ControlCastSpell(HK_R)
			
		end
	




		if (myHero:GetSpellData(_R).name == "ZiggsR") and myHero.pos:DistanceTo(target.pos) <= 5300 then		--ziggs
			if getdmg("R", target, myHero, 9) > hp then
				if target.pos:To2D().onScreen then						
					ControlCastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5300, 375)		
				end
			end	
		end
	
	


		if (myHero:GetSpellData(_R).name == "ZoeR") and myHero.pos:DistanceTo(target.pos) <= 575 then		--Zoe
			ControlCastSpell(HK_R, target)
		
		end
	



		if (myHero:GetSpellData(_R).name == "ZyraR") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Zyra    
			if getdmg("R", target, myHero, 46) > hp then
				ControlCastSpell(HK_R, target)
			end
		end
	end
end	

----------------AOE Ults------------------------------------------------------------------------------------------------------------

--Amumu
function AoeUlt()
local target = GetTarget(20000)     	
if target == nil then return end

	if IsValid(target) and Menu.Combo.Set.AOE:Value() and Ready(_R) then
		
		if (myHero:GetSpellData(_R).name == "CurseoftheSadMummy") then		
			local count = GetEnemyCount(550, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Bard



		if (myHero:GetSpellData(_R).name == "BardR") then
			local count = GetEnemyCount(350, target)
			if myHero.pos:DistanceTo(target.pos) <= 3400 and count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Braum

		if (myHero:GetSpellData(_R).name == "BraumRWrapper") and myHero.pos:DistanceTo(target.pos) <= 1250 then		
			local count = GetEnemyCount(115, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Brand

		if (myHero:GetSpellData(_R).name == "BrandR") and myHero.pos:DistanceTo(target.pos) <= 750 then		
			local count = GetEnemyCount(600, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Cassiopeia

		if (myHero:GetSpellData(_R).name == "CassiopeiaR") and myHero.pos:DistanceTo(target.pos) <= 825 then		
			local count = GetEnemyCount(825, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Fiddlesticks

		if (myHero:GetSpellData(_R).name == "Crowstorm") and myHero.pos:DistanceTo(target.pos) <= 600 then		
			local count = GetEnemyCount(600, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	





--Gankplank

		if (myHero:GetSpellData(_R).name == "GangplankR") and myHero.pos:DistanceTo(target.pos) <= 20000 then		
			local count = GetEnemyCount(600, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				
				if target.pos:To2D().onScreen then						
					ControlCastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 20000, 500)		
				end
			end
		end
	
    

--Gragas
		if (myHero:GetSpellData(_R).name == "GragasR") then		
			local count = GetEnemyCount(400, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	



--Ilaoi
		if (myHero:GetSpellData(_R).name == "IllaoiR") then		
			local count = GetEnemyCount(450, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Janna
		if (myHero:GetSpellData(_R).name == "ReapTheWhirlwind") then		
			local count = GetEnemyCount(725, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Jarvan
		if (myHero:GetSpellData(_R).name == "JarvanIVCataclysm") and myHero.pos:DistanceTo(target.pos) <= 650 then		
			local count = GetEnemyCount(325, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	



--Katarina
		if (myHero:GetSpellData(_R).name == "KatarinaR") then		
			local count = GetEnemyCount(250, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	


--Leona 
		if (myHero:GetSpellData(_R).name == "LeonaSolarFlare") and myHero.pos:DistanceTo(target.pos) <= 1200 then		 
			local count = GetEnemyCount(250, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target,pos)
			end
		end
	

	


--Maokai
		if (myHero:GetSpellData(_R).name == "MaokaiR") and myHero.pos:DistanceTo(target.pos) <= 3000 then
			local count = GetEnemyCount(900, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Malzahar
		if (myHero:GetSpellData(_R).name == "MalzaharR") and myHero.pos:DistanceTo(target.pos) <= 700 then			
			local count = GetEnemyCount(500, target)
			if count >= Menu.Combo.Set.Hit:Value() then		
				ControlCastSpell(HK_R, target.pos)
				if myHero.activeSpell.isChanneling == true then	
					_G.SDK.Orbwalker:SetMovement(false)
					_G.SDK.Orbwalker:SetAttack(false)
				elseif myHero.activeSpell.isChanneling == false then	
					_G.SDK.Orbwalker:SetMovement(true)
					_G.SDK.Orbwalker:SetAttack(true)
				end
			end
		end


--Malphite
		if (myHero:GetSpellData(_R).name == "UFSlash") and myHero.pos:DistanceTo(target.pos) <= 1000 then
			local count = GetEnemyCount(300, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Morgana
		if (myHero:GetSpellData(_R).name == "SoulShackles") then
			local count = GetEnemyCount(625, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R)
			end
		end
	


--Nautilus
		if (myHero:GetSpellData(_R).name == "NautilusR") and myHero.pos:DistanceTo(target.pos) <= 825 then
			local count = GetEnemyCount(300, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R)
			end
		end
	


--Neeko
		if (myHero:GetSpellData(_R).name == "NeekoR") then
			local count = GetEnemyCount(600, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R)
			end
		end
	


--Nami
		if (myHero:GetSpellData(_R).name == "NamiR") and myHero.pos:DistanceTo(target.pos) <= 2750 then
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 2750, 0.5, 850, 250, false)
			local count = GetEnemyCount(250, aimPosition)
			if count >= Menu.Combo.Set.Hit:Value() and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					ControlCastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					ControlCastSpell(HK_R, castPos)
				end
			end
		end
	


--Orianna
		if (myHero:GetSpellData(_R).name == "OrianaDetonateCommand-") then
			local count = GetEnemyCount(325, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R)
			end
		end
	


--Rammus
		if (myHero:GetSpellData(_R).name == "Tremors2") then
			local count = GetEnemyCount(300, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Sona
		if (myHero:GetSpellData(_R).name == "SonaR") and myHero.pos:DistanceTo(target.pos) <= 900 then
			local count = GetEnemyCount(140, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Swain
		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") and myHero.pos:DistanceTo(target.pos) <= 650 then
			local count = GetEnemyCount(650, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Sejuani
		if (myHero:GetSpellData(_R).name == "SejuaniR") and myHero.pos:DistanceTo(target.pos) <= 1300 then
			local count = GetEnemyCount(120, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Talon
		if (myHero:GetSpellData(_R).name == "TalonShadowAssault") and myHero.pos:DistanceTo(target.pos) <= 550 then
			local count = GetEnemyCount(550, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R)
			end
		end
	


--Thresh
		if (myHero:GetSpellData(_R).name == "ThreshRPenta") and myHero.pos:DistanceTo(target.pos) <= 450 then
			local count = GetEnemyCount(450, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, myHero.pos)
			end
		end
	



--Vladimir
		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") and myHero.pos:DistanceTo(target.pos) <= 700 then
			local count = GetEnemyCount(325, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Varus
		if (myHero:GetSpellData(_R).name == "VarusR") and myHero.pos:DistanceTo(target.pos) <= 1075 then
			local count = GetEnemyCount(550, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Volibear
		if (myHero:GetSpellData(_R).name == "VolibearR") and myHero.pos:DistanceTo(target.pos) <= 500 then
			local count = GetEnemyCount(500, myHero)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	


--Yasuo

		if (myHero:GetSpellData(_R).name == "YasuoR") and myHero.pos:DistanceTo(target.pos) <= 1400 then
			local count = self:CountKnockedUpEnemies(1400)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R)
			end
		end
	



--Ziggs
		if (myHero:GetSpellData(_R).name == "ZiggsR") and myHero.pos:DistanceTo(target.pos) <= 5300 then
			local count = GetEnemyCount(550, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				if target.pos:To2D().onScreen then						
					ControlCastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5300, 375)		
				end
			end
		end
	


--Zyra
		if (myHero:GetSpellData(_R).name == "ZyraR") and myHero.pos:DistanceTo(target.pos) <= 700 then
			local count = GetEnemyCount(500, target)
			if count >= Menu.Combo.Set.Hit:Value() then
				ControlCastSpell(HK_R, target.pos)
			end
		end
	end
end

--------------------Heal/Shield Ults----------------------------------

function HealShieldUlt()
local target = GetTarget(1500)     	
if target == nil then return end	
	if IsValid(target) and Menu.Combo.Set.Heal:Value() and Ready(_R) and myHero.health/myHero.maxHealth <= Menu.Combo.Set.HP:Value()/100 then
		
--Alistar		
		if (myHero:GetSpellData(_R).name == "FerociousHowl") then		 			
			ControlCastSpell(HK_R, myHero)

		end
	


--Dr.Mundo
		if (myHero:GetSpellData(_R).name == "Sadism") then		 
			ControlCastSpell(HK_R, myHero)
		
		end
	


--Ekko

		if (myHero:GetSpellData(_R).name == "EkkoR") then		 
			ControlCastSpell(HK_R)
			
		end
	



--Fiora

		if (myHero:GetSpellData(_R).name == "FioraR") then		 
			ControlCastSpell(HK_R, target)
		end
	


--Janna

		if (myHero:GetSpellData(_R).name == "ReapTheWhirlwind") then		 
			ControlCastSpell(HK_R, target)
		
		end
	


--Jax

		if (myHero:GetSpellData(_R).name == "JaxRelentlessAssault") then		 
			ControlCastSpell(HK_R)
		
		end
	


--Kayle

		if (myHero:GetSpellData(_R).name == "JudicatorIntervention") then		 
			ControlCastSpell(HK_R, myHero)
			
		end
	


--Khazix

		if (myHero:GetSpellData(_R).name == "KhazixR") then		 
			ControlCastSpell(HK_R)
			
		end
	


--Kindred

		if (myHero:GetSpellData(_R).name == "KindredR") then		 
			ControlCastSpell(HK_R)
		
		end
	


--Lulu

		if (myHero:GetSpellData(_R).name == "LuluR") then		 
			ControlCastSpell(HK_R, myHero)
		
		end
	



--Nasus

		if (myHero:GetSpellData(_R).name == "NasusR") then		 
			ControlCastSpell(HK_R, target)
			
		end
	


--Renekton

		if (myHero:GetSpellData(_R).name == "RenektonReignOfTheTyrant") then		 
			ControlCastSpell(HK_R, target)
		
		end
	


--Singed

		if (myHero:GetSpellData(_R).name == "InsanityPotion") then		 
			ControlCastSpell(HK_R)
			
		end
	



--Sivir

		if (myHero:GetSpellData(_R).name == "SivirR") then		 
			ControlCastSpell(HK_R, myHero)
			
		end
	


--Soraka

		if (myHero:GetSpellData(_R).name == "SorakaR") then		 
			ControlCastSpell(HK_R)
		
		end
	


--Swain

		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") then		 
			ControlCastSpell(HK_R, target.pos)
			
		end
	


--Taric

		if (myHero:GetSpellData(_R).name == "TaricR") then		 
			ControlCastSpell(HK_R)
			
		end
	


--Tryndamere

		if (myHero:GetSpellData(_R).name == "UndyingRage") then		 
			ControlCastSpell(HK_R)
		
		end
	



--Vladimir

		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") then		 
			ControlCastSpell(HK_R, target.pos)
		
		end
	


--XinZhao

		if (myHero:GetSpellData(_R).name == "XenZhaoParry") then		 
			ControlCastSpell(HK_R)
			
		end
	


--Zilean

		if (myHero:GetSpellData(_R).name == "ZileanR") then		 
			ControlCastSpell(HK_R, myHero)
		
		end
	end
end

function KillSteal()
if myHero.dead then return end	
	local target = GetTarget(1500)     	
	if target == nil then return end
	
	if IsValid(target) then
	local EDmg = getdmg("E", target, myHero)
		if myHero.pos:DistanceTo(target.pos) <= 1200 and myHero.pos:DistanceTo(target.pos) > 400 and EDmg >= target.health and Menu.ks.UseE:Value() and Ready(_E) then			
			local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
			Control.SetCursorPos(EPos)
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
			if myHero.pos:DistanceTo(target.pos) <= 800 then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
				if hitRate and hitRate >= 2 then
					ControlCastSpell(HK_E, aimPosition)
				end	
			end
	
		elseif myHero.pos:DistanceTo(target.pos) <= 400 and EDmg >= target.health and Menu.ks.UseE:Value() and Ready(_E) then
			ControlCastSpell(HK_E, target)
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 2 then
				ControlCastSpell(HK_E, aimPosition)
			end	
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 775 and Menu.ks.UseQ:Value() and Ready(_Q) then
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health and hitRate and hitRate >= 2 then
				ControlCastSpell(HK_Q, aimPosition)
			end
		elseif myHero.pos:DistanceTo(target.pos) > 775 and myHero.pos:DistanceTo(target.pos) <= 1175 and Menu.ks.UseQ:Value() and Ready(_Q) and Ready(_E) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health then
				local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
			end	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)	
			if myHero.pos:DistanceTo(target.pos) <= 775 and hitRate and hitRate >= 2 then	
				ControlCastSpell(HK_Q, aimPosition)
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 400 and Menu.ks.UseW:Value() and Ready(_W) then
			local WDmg = getdmg("W", target, myHero)
			if WDmg >= target.health then
				ControlCastSpell(HK_W, target)		
			end
		elseif myHero.pos:DistanceTo(target.pos) > 400 and myHero.pos:DistanceTo(target.pos) <= 800 and Menu.ks.UseW:Value() and Ready(_W) and Ready(_E) then
			local WDmg = getdmg("W", target, myHero)
			if WDmg >= target.health then
				local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
			end	
			if myHero.pos:DistanceTo(target.pos) <= 400 then	
				ControlCastSpell(HK_W, target)	
			end			
		end					
	end
end	

function Combo()
local target = GetTarget(1300)
if target == nil then return end
	
	if IsValid(target) then
		if myHero.pos:DistanceTo(target.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 1 then
				ControlCastSpell(HK_E, aimPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) < 1300 and Menu.Combo.UseE:Value() and Ready(_E) then			
			if myHero:GetSpellData(_E).name == "SylasE" then
				ControlCastSpell(HK_E, target.pos)
			end
		end
		local passiveBuff = GetBuffData(myHero,"SylasPassiveAttack")
		if myHero.pos:DistanceTo(target.pos) < 400 and passiveBuff.count == 1 then return end
		if myHero.pos:DistanceTo(target.pos) <= 775 and Menu.Combo.UseQ:Value() and Ready(_Q) then 	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			if hitRate and hitRate >= 2 then
				ControlCastSpell(HK_Q, aimPosition)
			end	
		end
		if myHero.pos:DistanceTo(target.pos) <= 400 and Menu.Combo.UseW:Value() and Ready(_W) then
			ControlCastSpell(HK_W, target)
		end
	end
end

function Harass()	
local target = GetTarget(1300)
if target == nil then return end

	
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 1 then
				ControlCastSpell(HK_E, aimPosition)
			end	
		end	 	
		
		if myHero.pos:DistanceTo(target.pos) < 1300 and Menu.Harass.UseE:Value() and Ready(_E) then			
			if myHero:GetSpellData(_E).name == "SylasE" then
				ControlCastSpell(HK_E, target.pos)
			end
		end
		local passiveBuff = GetBuffData(myHero,"SylasPassiveAttack")
		if passiveBuff.count == 1 and myHero.pos:DistanceTo(target.pos) < 400 then return end	
		if myHero.pos:DistanceTo(target.pos) <= 775 and Menu.Harass.UseQ:Value() and Ready(_Q) then 	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			if hitRate and hitRate >= 2 then
				ControlCastSpell(HK_Q, aimPosition)
			end	
		end
		if myHero.pos:DistanceTo(target.pos) <= 400 and Menu.Harass.UseW:Value() and Ready(_W) then
			ControlCastSpell(HK_W, target)
		end
	end
end

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	local passiveBuff = GetBuffData(myHero,"SylasPassiveAttack")
		
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then			
			
			if myHero.pos:DistanceTo(minion.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, E.range, E.delay, E.speed, E.radius, false)
				if hitRate and hitRate >= 0 then
					ControlCastSpell(HK_E, aimPosition)
				end	
			end			
									
			if myHero.pos:DistanceTo(minion.pos) < 1300 and Ready(_E) and Menu.Clear.UseE:Value() and myHero:GetSpellData(_E).name == "SylasE" then
				ControlCastSpell(HK_E, minion)
			end
					
 			if passiveBuff.count == 1 and myHero.pos:DistanceTo(minion.pos) < 400 then return end 
			if myHero.pos:DistanceTo(minion.pos) <= 755 and Ready(_Q) and Menu.Clear.UseQL:Value() and GetMinionCount(225, minion) >= Menu.Clear.UseQLM:Value() then
				ControlCastSpell(HK_Q, minion)
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 400 and Ready(_W) and Menu.Clear.UseW:Value() then
				ControlCastSpell(HK_W, minion)
			end  
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)	
	
 	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			
			if myHero.pos:DistanceTo(minion.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, E.range, E.delay, E.speed, E.radius, false)
				if hitRate and hitRate >= 0 then
					ControlCastSpell(HK_E, aimPosition)
				end	
			end			
						
			if myHero.pos:DistanceTo(minion.pos) < 1300 and Ready(_E) and Menu.JClear.UseE:Value() and myHero:GetSpellData(_E).name == "SylasE" then
				ControlCastSpell(HK_E, minion)
			end			
			
			local passiveBuff = GetBuffData(myHero,"SylasPassiveAttack")
			if passiveBuff.count == 1 and myHero.pos:DistanceTo(minion.pos) < 400 then return end
			if myHero.pos:DistanceTo(minion.pos) <= 775 and Ready(_Q) and Menu.JClear.UseQ:Value() then
				ControlCastSpell(HK_Q, minion)
			end

			if myHero.pos:DistanceTo(minion.pos) <= 400 and Ready(_W) and Menu.JClear.UseW:Value() then
				ControlCastSpell(HK_W, minion)
			end 
		end
	end
end	



class "HPred"

local _tickFrequency = .2
local _nextTick = Game.Timer()
local _reviveLookupTable = 
	{ 
		["LifeAura.troy"] = 4, 
		["ZileanBase_R_Buf.troy"] = 3,
		["Aatrox_Base_Passive_Death_Activate"] = 3
		
		--TwistedFate_Base_R_Gatemarker_Red
			--String match would be ideal.... could be different in other skins
	}

--Stores a collection of spells that will cause a character to blink
	--Ground targeted spells go towards mouse castPos with a maximum range
	--Hero/Minion targeted spells have a direction type to determine where we will land relative to our target (in front of, behind, etc)
	
--Key = Spell name
--Value = range a spell can travel, OR a targeted end position type, OR a list of particles the spell can teleport to	
local _blinkSpellLookupTable = 
	{ 
		["EzrealArcaneShift"] = 475, 
		["RiftWalk"] = 500,
		
		--Ekko and other similar blinks end up between their start pos and target pos (in front of their target relatively speaking)
		["EkkoEAttack"] = 0,
		["AlphaStrike"] = 0,
		
		--Katarina E ends on the side of her target closest to where her mouse was... 
		["KatarinaE"] = -255,
		
		--Katarina can target a dagger to teleport directly to it: Each skin has a different particle name. This should cover all of them.
		["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, 
	}

local _blinkLookupTable = 
	{ 
		"global_ss_flash_02.troy",
		"Lissandra_Base_E_Arrival.troy",
		"LeBlanc_Base_W_return_activation.troy"
		--TODO: Check if liss/leblanc have diff skill versions. MOST likely dont but worth checking for completion sake
		
		--Zed uses 'switch shadows'... It will require some special checks to choose the shadow he's going TO not from...
		--Shaco deceive no longer has any particles where you jump to so it cant be tracked (no spell data or particles showing path)
		
	}

local _cachedBlinks = {}
local _cachedRevives = {}
local _cachedTeleports = {}

--Cache of all TARGETED missiles currently running
local _cachedMissiles = {}
local _incomingDamage = {}

--Cache of active enemy windwalls so we can calculate it when dealing with collision checks
local _windwall
local _windwallStartPos
local _windwallWidth

local _OnVision = {}
function HPred:OnVision(unit)
	if unit == nil or type(unit) ~= "userdata" then return end
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {visible = unit.visible , tick = GetTickCount(), pos = unit.pos } end
	if _OnVision[unit.networkID].visible == true and not unit.visible then _OnVision[unit.networkID].visible = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].visible == false and unit.visible then _OnVision[unit.networkID].visible = true _OnVision[unit.networkID].tick = GetTickCount() _OnVision[unit.networkID].pos = unit.pos end
	return _OnVision[unit.networkID]
end

--This must be called manually - It's not on by default because we've tracked down most of the freeze issues to this.
function HPred:Tick()
	
	
	--Update missile cache
	--DISABLED UNTIL LATER.
	--self:CacheMissiles()
	
	--Limit how often tick logic runs
	if _nextTick > Game.Timer() then return end
	_nextTick = Game.Timer() + _tickFrequency
	
	--Update hero movement history	
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t then
			if t.isEnemy then
				HPred:OnVision(t)
			end
		end
	end
	
	--Do not run rest of logic until freeze issues are fully tracked down
	if true then return end
	
	
	--Remove old cached teleports	
	for _, teleport in pairs(_cachedTeleports) do
		if teleport and Game.Timer() > teleport.expireTime + .5 then
			_cachedTeleports[_] = nil
		end
	end	
	
	--Update teleport cache
	HPred:CacheTeleports()	
	
	
	--Record windwall
	HPred:CacheParticles()
	
	--Remove old cached revives
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	--Remove old cached blinks
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		--Record revives
		if particle and not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then
			_cachedRevives[particle.networkID] = {}
			_cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedRevives[particle.networkID]["target"] = target
				_cachedRevives[particle.networkID]["pos"] = target.pos
				_cachedRevives[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
		
		--Record blinks
		if particle and not _cachedBlinks[particle.networkID] and  _blinkLookupTable[particle.name] then
			_cachedBlinks[particle.networkID] = {}
			_cachedBlinks[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedBlinks[particle.networkID]["target"] = target
				_cachedBlinks[particle.networkID]["pos"] = target.pos
				_cachedBlinks[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
	end
	
end

function HPred:GetEnemyNexusPosition()
	--This is slightly wrong. It represents fountain not the nexus. Fix later.
	if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end
end


function HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
end


function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--TODO: Target whitelist. This will target anyone which is definitely not what we want
	--For now we can handle in the champ script. That will cause issues with multiple people in range who are goood targets though.
	
	
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get channeling enemies
	--local target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	--	if target and aimPosition then
	--	return target, aimPosition
	--end
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get instant dash enemies
	local target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get dashing enemies
	local target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get blink targets
	local target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
end

--Will return how many allies or enemies will be hit by a linear spell based on current waypoint data.
function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
	local targetCount = 0
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t and self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then
			
			local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) * (t.boundingRadius + width)) then
				targetCount = targetCount + 1
			end
		end
	end
	return targetCount
end

--Will return the valid target who has the highest hit chance and meets all conditions (minHitChance, whitelist check, etc)
function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist, isLine)
	local _validTargets = {}
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)		
		if t and self:CanTarget(t, true) and (not whitelist or whitelist[t.charName]) then
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision, isLine)		
			if hitChance >= minimumHitChance then
				table.insert(_validTargets, {aimPosition,hitChance, hitChance * 100 + self:CalculateMagicDamage(t, 400)})
			end
		end
	end	
	table.sort(_validTargets, function( a, b ) return a[3] >b[3] end)	
	if #_validTargets > 0 then	
		return _validTargets[1][2], _validTargets[1][1]
	end
end

function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision, isLine)

	if isLine == nil and checkCollision then
		isLine = true
	end
	
	local hitChance = 1
	local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed)	
	local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed)
	local reactionTime = self:PredictReactionTime(target, .1, isLine)
	
	--Check if they are walking the same path as the line or very close to it
	if isLine then
		local pathVector = aimPosition - target.pos
		local castVector = (aimPosition - myHero.pos):Normalized()
		if pathVector.x + pathVector.z ~= 0 then
			pathVector = pathVector:Normalized()
			if pathVector:DotProduct(castVector) < -.85 or pathVector:DotProduct(castVector) > .85 then
				if speed > 3000 then
					reactionTime = reactionTime + .25
				else
					reactionTime = reactionTime + .15
				end
			end
		end
	end			

	--If they are standing still give a higher accuracy because they have to take actions to react to it
	if not target.pathing or not target.pathing.hasMovePath then
		hitChancevisionData = 2
	end	
	
	
	local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
	--Our spell is so wide or the target so slow or their reaction time is such that the spell will be nearly impossible to avoid
	if movementRadius - target.boundingRadius <= radius /2 then
		origin,movementRadius = self:UnitMovementBounds(target, interceptTime, 0)
		if movementRadius - target.boundingRadius <= radius /2 then
			hitChance = 4
		else		
			hitChance = 3
		end
	end	
	
	--If they are casting a spell then the accuracy will be fairly high. if the windup is longer than our delay then it's quite likely to hit. 
	--Ideally we would predict where they will go AFTER the spell finishes but that's beyond the scope of this prediction
	if target.activeSpell and target.activeSpell.valid then
		if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then
			hitChance = 5
		else			
			hitChance = 3
		end
	end
	
	local visionData = HPred:OnVision(target)
	if visionData and visionData.visible == false then
		local hiddenTime = visionData.tick -GetTickCount()
		if hiddenTime < -1000 then
			hitChance = -1
		else
			local targetSpeed = self:GetTargetMS(target)
			local unitPos = target.pos + Vector(target.pos,target.posTo):Normalized() * ((GetTickCount() - visionData.tick)/1000 * targetSpeed)
			local aimPosition = unitPos + Vector(target.pos,target.posTo):Normalized() * (targetSpeed * (delay + (self:GetDistance(myHero.pos,unitPos)/speed)))
			if self:GetDistance(target.pos,aimPosition) > self:GetDistance(target.pos,target.posTo) then aimPosition = target.posTo end
			hitChance = math.min(hitChance, 2)
		end
	end
	
	--Check for out of range
	if not self:IsInRange(source, aimPosition, range) then
		hitChance = -1
	end
	
	--Check minion block
	if hitChance > 0 and checkCollision then
		if self:IsWindwallBlocking(source, aimPosition) then
			hitChance = -1		
		elseif self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then
			hitChance = -1
		end
	end
	
	return hitChance, aimPosition
end

function HPred:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	
	--If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end	
	return reactionTime
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)

	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t and t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if self:IsInRange(source, dashEndPosition, range) then				
				--The dash ends within range of our skill. We now need to find if our spell can connect with them very close to the time their dash will end
				local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(source, dashEndPosition, delay, speed)
				local deltaInterceptTime =skillInterceptTime - dashTimeRemaining
				if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then
					target = t
					aimPosition = dashEndPosition
					return target, aimPosition
				end
			end			
		end
	end
end

function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t and t.isEnemy then		
			local success, timeRemaining = self:HasBuff(t, "zhonyasringshield")
			if success then
				local spellInterceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
				local deltaInterceptTime = spellInterceptTime - timeRemaining
				if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = t
					aimPosition = t.pos
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for _, revive in pairs(_cachedRevives) do	
		if revive.isEnemy then
			local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
			if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then
				target = revive.target
				aimPosition = revive.pos
				return target, aimPosition
			end
		end
	end	
end

function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t and t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then
			local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer()
			if windupRemaining > 0 then
				local endPos
				local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
				if type(blinkRange) == "table" then
					--Find the nearest matching particle to our mouse
					--local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange)
					--if target and distance < 250 then					
					--	endPos = target.pos		
					--end
				elseif blinkRange > 0 then
					endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)					
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * math.min(self:GetDistance(t.activeSpell.startPos,endPos), range)
				else
					local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
					if blinkTarget then				
						local offsetDirection						
						
						--We will land in front of our target relative to our starting position
						if blinkRange == 0 then				

							if t.activeSpell.name ==  "AlphaStrike" then
								windupRemaining = windupRemaining + .75
								--TODO: Boost the windup time by the number of targets alpha will hit. Need to calculate the exact times this is just rough testing right now
							end						
							offsetDirection = (blinkTarget.pos - t.pos):Normalized()
						--We will land behind our target relative to our starting position
						elseif blinkRange == -1 then						
							offsetDirection = (t.pos-blinkTarget.pos):Normalized()
						--They can choose which side of target to come out on , there is no way currently to read this data so we will only use this calculation if the spell radius is large
						elseif blinkRange == -255 then
							if radius > 250 then
								endPos = blinkTarget.pos
							end							
						end
						
						if offsetDirection then
							endPos = blinkTarget.pos - offsetDirection * blinkTarget.boundingRadius
						end
						
					end
				end	
				
				local interceptTime = self:GetSpellInterceptTime(source, endPos, delay,speed)
				local deltaInterceptTime = interceptTime - windupRemaining
				if self:IsInRange(source, endPos, range) and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
					target = t
					aimPosition = endPos
					return target,aimPosition					
				end
			end
		end
	end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	local target
	local aimPosition
	for _, particle in pairs(_cachedBlinks) do
		if particle  and self:IsInRange(source, particle.pos, range) then
			local t = particle.target
			local pPos = particle.pos
			if t and t.isEnemy and (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
				target = t
				aimPosition = pPos
				return target,aimPosition
			end
		end		
	end
end

function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t then
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if self:CanTarget(t) and self:IsInRange(source, t.pos, range) and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos	
				return target, aimPosition
			end
		end
	end
end

function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t and self:CanTarget(t) and self:IsInRange(source, t.pos, range) then
			local immobileTime = self:GetImmobileTime(t)
			
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos
				return target, aimPosition
			end
		end
	end
end

function HPred:CacheTeleports()
	--Get enemies who are teleporting to towers
	for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i)
		if turret and turret.isEnemy and not _cachedTeleports[turret.networkID] then
			local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
			if hasBuff then
				self:RecordTeleport(turret, self:GetTeleportOffset(turret.pos,223.31),expiresAt)
			end
		end
	end	
	
	--Get enemies who are teleporting to wards	
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i)
		if ward and ward.isEnemy and not _cachedTeleports[ward.networkID] then
			local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
			if hasBuff then
				self:RecordTeleport(ward, self:GetTeleportOffset(ward.pos,100.01),expiresAt)
			end
		end
	end
	
	--Get enemies who are teleporting to minions
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.isEnemy and not _cachedTeleports[minion.networkID] then
			local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
			if hasBuff then
				self:RecordTeleport(minion, self:GetTeleportOffset(minion.pos,143.25),expiresAt)
			end
		end
	end	
end

function HPred:RecordTeleport(target, aimPos, endTime)
	_cachedTeleports[target.networkID] = {}
	_cachedTeleports[target.networkID]["target"] = target
	_cachedTeleports[target.networkID]["aimPos"] = aimPos
	_cachedTeleports[target.networkID]["expireTime"] = endTime + Game.Timer()
end


function HPred:CalculateIncomingDamage()
	_incomingDamage = {}
	local currentTime = Game.Timer()
	for _, missile in pairs(_cachedMissiles) do
		if missile then 
			local dist = self:GetDistance(missile.data.pos, missile.target.pos)			
			if missile.name == "" or currentTime >= missile.timeout or dist < missile.target.boundingRadius then
				_cachedMissiles[_] = nil
			else
				if not _incomingDamage[missile.target.networkID] then
					_incomingDamage[missile.target.networkID] = missile.damage
				else
					_incomingDamage[missile.target.networkID] = _incomingDamage[missile.target.networkID] + missile.damage
				end
			end
		end
	end	
end

function HPred:GetIncomingDamage(target)
	local damage = 0
	if _incomingDamage[target.networkID] then
		damage = _incomingDamage[target.networkID]
	end
	return damage
end




--Right now only used to cache enemy windwalls
function HPred:CacheParticles()	
	if _windwall and _windwall.name == "" then
		_windwall = nil
	end
	
	for i = 1, Game.ParticleCount() do
		local particle = Game.Particle(i)		
		if particle and self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then			
			if string.find(particle.name, "W_windwall%d") and not _windwall then
				--We don't care about ally windwalls for now
				local owner =  self:GetObjectByHandle(particle.handle)
				if owner and owner.isEnemy then
					_windwall = particle
					_windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)				
					
					local index = string.len(particle.name) - 5
					local spellLevel = string.sub(particle.name, index, index) -1
					--Simple fix
					if type(spellLevel) ~= "number" then
						spellLevel = 1
					end
					_windwallWidth = 150 + spellLevel * 25					
				end
			end
		end
	end
end

function HPred:CacheMissiles()
	local currentTime = Game.Timer()
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		if missile and not _cachedMissiles[missile.networkID] and missile.missileData then
			--Handle targeted missiles
			if missile.missileData.target and missile.missileData.owner then
				local missileName = missile.missileData.name
				local owner =  self:GetObjectByHandle(missile.missileData.owner)	
				local target =  self:GetObjectByHandle(missile.missileData.target)		
				if owner and target and string.find(target.type, "Hero") then			
					--The missile is an auto attack of some sort that is targeting a player	
					if (string.find(missileName, "BasicAttack") or string.find(missileName, "CritAttack")) then
						--Cache it all and update the count
						_cachedMissiles[missile.networkID] = {}
						_cachedMissiles[missile.networkID].target = target
						_cachedMissiles[missile.networkID].data = missile
						_cachedMissiles[missile.networkID].danger = 1
						_cachedMissiles[missile.networkID].timeout = currentTime + 1.5
						
						local damage = owner.totalDamage
						if string.find(missileName, "CritAttack") then
							--Leave it rough we're not that concerned
							damage = damage * 1.5
						end						
						_cachedMissiles[missile.networkID].damage = self:CalculatePhysicalDamage(target, damage)
					end
				end
			end
		end
	end
end

function HPred:CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

function HPred:CalculateMagicDamage(target, damage)			
	local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
	local damageReduction = 100 / ( 100 + targetMR)
	if targetMR < 0 then
		damageReduction = 2 - (100 / (100 - targetMR))
	end		
	damage = damage * damageReduction
	
	return damage
end


function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)

	local target
	local aimPosition
	for _, teleport in pairs(_cachedTeleports) do
		if teleport.expireTime > Game.Timer() and self:IsInRange(source,teleport.aimPos, range) then			
			local spellInterceptTime = self:GetSpellInterceptTime(source, teleport.aimPos, delay, speed)
			local teleportRemaining = teleport.expireTime - Game.Timer()
			if spellInterceptTime > teleportRemaining and spellInterceptTime - teleportRemaining <= timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, teleport.aimPos, delay, speed, radius)) then								
				target = teleport.target
				aimPosition = teleport.aimPos
				return target, aimPosition
			end
		end
	end		
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:Angle(A, B)
	local deltaPos = A - B
	local angle = math.atan2(deltaPos.x, deltaPos.z) *  180 / math.pi	
	if angle < 0 then angle = angle + 360 end
	return angle
end

--Returns where the unit will be when the delay has passed given current pathing information. This assumes the target makes NO CHANGES during the delay.
function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			--This node of the path will be completed before the delay has finished. Move on to the next node if one remains
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:IsChannelling(target, interceptTime)
	if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then
		return true
	end
end

function HPred:HasBuff(target, buffName, minimumDuration)
	local duration = minimumDuration
	if not minimumDuration then
		duration = 0
	end
	local durationRemaining
	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		if buff.duration > duration and buff.name == buffName then
			durationRemaining = buff.duration
			return true, durationRemaining
		end
	end
end

--Moves an origin towards the enemy team nexus by magnitude
function HPred:GetTeleportOffset(origin, magnitude)
	local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude
	return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end

--Checks if a target can be targeted by abilities or auto attacks currently.
--CanTarget(target)
	--target : gameObject we are trying to hit
function HPred:CanTarget(target, allowInvisible)
	return target.isEnemy and target.alive and target.health > 0  and (allowInvisible or target.visible) and target.isTargetable
end

--Derp: dont want to fuck with the isEnemy checks elsewhere. This will just let us know if the target can actually be hit by something even if its an ally
function HPred:CanTargetALL(target)
	return target.alive and target.health > 0 and target.visible and target.isTargetable
end

--Returns a position and radius in which the target could potentially move before the delay ends. ReactionTime defines how quick we expect the target to be able to change their current path
function HPred:UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = self:PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = self:GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

--Returns how long (in seconds) the target will be unable to move from their current location
function HPred:GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			duration = buff.duration
		end
	end
	return duration		
end

--Returns how long (in seconds) the target will be slowed for
function HPred:GetSlowedTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end

--Returns all existing path nodes
function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

--Finds any game object with the correct handle to match (hero, minion, wards on either team)
function HPred:GetObjectByHandle(handle)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.handle == handle then
			target = minion
			return target
		end
	end
	
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i)
		if ward and ward.handle == handle then
			target = ward
			return target
		end
	end
	
	for i = 1, Game.TurretCount() do 
		local turret = Game.Turret(i)
		if turret and turret.handle == handle then
			target = turret
			return target
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if particle and particle.handle == handle then
			target = particle
			return target
		end
	end
end

function HPred:GetHeroByPosition(position)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetObjectByPosition(position)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.MinionCount() do
		local enemy = Game.Minion(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.WardCount() do
		local enemy = Game.Ward(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local enemy = Game.Particle(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
end

--Finds the closest particle to the origin that is contained in the names array
function HPred:GetNearestParticleByNames(origin, names)
	local target
	local distance = 999999
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if particle then 
			local d = self:GetDistance(origin, particle.pos)
			if d < distance then
				distance = d
				target = particle
			end
		end
	end
	return target, distance
end

--Returns the total distance of our current path so we can calculate how long it will take to complete
function HPred:GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + self:GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end


--I know this isn't efficient but it works accurately... Leaving it for now.
function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
		
	if not frequency then
		frequency = radius
	end
	local directionVector = (endPos - origin):Normalized()
	local checkCount = self:GetDistance(origin, endPos) / frequency
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * frequency
		local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed
		if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end


function HPred:IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and self:CanTarget(minion) and self:IsInRange(minion.pos, location, maxDistance) then
			local predictedPosition = self:PredictUnitPosition(minion, delay)
			if self:IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
				return true
			end
		end
	end
	return false
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

--Determines if there is a windwall between the source and target pos. 
function HPred:IsWindwallBlocking(source, target)
	if _windwall then
		local windwallFacing = (_windwallStartPos-_windwall.pos):Normalized()
		return self:DoLineSegmentsIntersect(source, target, _windwall.pos + windwallFacing:Perpendicular() * _windwallWidth, _windwall.pos + windwallFacing:Perpendicular2() * _windwallWidth)
	end	
	return false
end
--Returns if two line segments cross eachother. AB is segment 1, CD is segment 2.
function HPred:DoLineSegmentsIntersect(A, B, C, D)

	local o1 = self:GetOrientation(A, B, C)
	local o2 = self:GetOrientation(A, B, D)
	local o3 = self:GetOrientation(C, D, A)
	local o4 = self:GetOrientation(C, D, B)
	
	if o1 ~= o2 and o3 ~= o4 then
		return true
	end
	
	if o1 == 0 and self:IsOnSegment(A, C, B) then return true end
	if o2 == 0 and self:IsOnSegment(A, D, B) then return true end
	if o3 == 0 and self:IsOnSegment(C, A, D) then return true end
	if o4 == 0 and self:IsOnSegment(C, B, D) then return true end
	
	return false
end

--Determines the orientation of ordered triplet
--0 = Colinear
--1 = Clockwise
--2 = CounterClockwise
function HPred:GetOrientation(A,B,C)
	local val = (B.z - A.z) * (C.x - B.x) -
		(B.x - A.x) * (C.z - B.z)
	if val == 0 then
		return 0
	elseif val > 0 then
		return 1
	else
		return 2
	end
	
end

function HPred:IsOnSegment(A, B, C)
	return B.x <= _max(A.x, C.x) and 
		B.x >= math.min(A.x, C.x) and
		B.z <= _max(A.z, C.z) and
		B.z >= math.min(A.z, C.z)
end

--Gets the slope between two vectors. Ignores Y because it is non-needed height data. Its all 2d math.
function HPred:GetSlope(A, B)
	return (B.z - A.z) / (B.x - A.x)
end

function HPred:GetEnemyByName(name)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.isEnemy and enemy.charName == name then
			target = enemy
			return target
		end
	end
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	local deltaAngle = math.abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
	if deltaAngle < angle and self:IsInRange(origin,target,range) then
		return true
	end
end

function HPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return math.huge
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) 
end

function HPred:IsInRange(p1, p2, range)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined IsInRange target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return false
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range 
end

function HPred:GetDistance(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistance target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return math.huge
	end
	return math.sqrt(self:GetDistanceSqr(p1, p2))
end

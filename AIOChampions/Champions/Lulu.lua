
--Ported from Hanbot/ Kornis Lulu --- I love his codes ;)

local spellQ = {range = 925, speed = 1800, width = 60, delay = 0.25}
local spellW = {range = 650}
local spellE = {range = 650}
local spellR = {range = 900}

local function GetHeroes()
    local _Heroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit and not unit.isMe then
            TableInsert(_Heroes, unit)
        end
    end
    return _Heroes
end

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

local function GetAllyHeroes()
    local _AllyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isAlly and not unit.isMe then
            TableInsert(_AllyHeroes, unit)
        end
    end
    return _AllyHeroes
end

local function GetEnemyTurretHit(unit)
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret.isEnemy and not turret.dead and GetDistance(turret.pos, unit.pos) <= 1500 and turret.targetID == unit.networkID then
			return true
		end
	end
	return false		
end

local function GetAllyCount(range, pos)
    local pos = pos.pos
    local count = 0
    for i, hero in ipairs(GetAllyHeroes()) do
    local Range = range * range
        if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
        count = count + 1
        end
    end
    return count
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

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 8 or buff.type == 12 or buff.type == 22 or buff.type == 23 or buff.type == 25 or buff.type == 30 or buff.type == 35 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

local PSpells = {
	"CaitlynHeadshotMissile",
	"RumbleOverheatAttack",
	"JarvanIVMartialCadenceAttack",
	"ShenKiAttack",
	"MasterYiDoubleStrike",
	"sonahymnofvalorattackupgrade",
	"sonaariaofperseveranceupgrade",
	"sonasongofdiscordattackupgrade",
	"NocturneUmbraBladesAttack",
	"NautilusRavageStrikeAttack",
	"ZiggsPassiveAttack",
	"QuinnWEnhanced",
	"LucianPassiveAttack",
	"SkarnerPassiveAttack",
	"KarthusDeathDefiedBuff",
	"GarenQAttack",
	"KennenMegaProc",
	"MordekaiserQAttack",
	"MordekaiserQAttack2",
	"BlueCardPreAttack",
	"RedCardPreAttack",
	"GoldCardPreAttack",
	"XenZhaoThrust",
	"XenZhaoThrust2",
	"XenZhaoThrust3",
	"ViktorQBuff",
	"TrundleQ",
	"RenektonSuperExecute",
	"RenektonExecute",
	"GarenSlash2",
	"frostarrow",
	"SivirWAttack",
	"rengarnewpassivebuffdash",
	"YorickQAttack",
	"ViEAttack",
	"SejuaniBasicAttackW",
	"ShyvanaDoubleAttackHit",
	"ShenQAttack",
	"SonaEAttackUpgrade",
	"SonaWAttackUpgrade",
	"SonaQAttackUpgrade",
	"PoppyPassiveAttack",
	"NidaleeTakedownAttack",
	"NasusQAttack",
	"KindredBasicAttackOverrideLightbombFinal",
	"LeonaShieldOfDaybreakAttack",
	"KassadinBasicAttack3",
	"JhinPassiveAttack",
	"JayceHyperChargeRangedAttack",
	"JaycePassiveRangedAttack",
	"JaycePassiveMeleeAttack",
	"illaoiwattack",
	"hecarimrampattack",
	"DrunkenRage",
	"GalioPassiveAttack",
	"FizzWBasicAttack",
	"FioraEAttack",
	"EkkoEAttack",
	"ekkobasicattackp3",
	"MasochismAttack",
	"DravenSpinningAttack",
	"DianaBasicAttack3",
	"DariusNoxianTacticsONHAttack",
	"CamilleQAttackEmpowered",
	"CamilleQAttack",
	"PowerFistAttack",
	"AsheQAttack",
	"jinxqattack",
	"jinxqattack2",
	"KogMawBioArcaneBarrage"
}

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.valid then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
end

local function GetTargetQ()
	return GetTarget(spellQ.range)
end

local function GetTargetQE()
	return GetTarget(1800)
end

function LoadScript() 
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})

	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
    Menu.Combo:MenuElement({id = "QRange", name = "[Q] Max. Range", value = 700, min = 0, max = 925, step = 5})	
	Menu.Combo:MenuElement({id = "UseEQ", name = "Use [E] > [Q] Extended", value = false})
	
	Menu.Combo:MenuElement({type = MENU, id = "WEnemy", name = "[W] Enemy Settings"})
	Menu.Combo.WEnemy:MenuElement({id = "UseW", name = "[W] Enemy", value = false})
	Menu.Combo.WEnemy:MenuElement({type = MENU, id = "Blacklist", name = "[W] Blacklist"})	
	DelayAction(function()
		for i, Hero in pairs(GetEnemyHeroes()) do
			Menu.Combo.WEnemy.Blacklist:MenuElement({id = Hero.charName, name = "Dont Use on "..Hero.charName, value = false})		
		end		
	end,0.2)
	
	Menu.Combo:MenuElement({type = MENU, id = "WAlly", name = "Ally Settings"})
	Menu.Combo.WAlly:MenuElement({id = "UseW", name = "Auto[W] on Ally Auto Attack", value = true})
	Menu.Combo.WAlly:MenuElement({id = "UseE", name = "Auto[E] on Ally Auto Attack", value = false})	
	Menu.Combo.WAlly:MenuElement({type = MENU, id = "wset", name = "Ally Priority Settings"})	
	Menu.Combo.WAlly:MenuElement({name = " ", drop = {"0 = Disabled, 1 = Biggest Prio, 5 = Lowest Prio"}})
	DelayAction(function()
		for i, allies in pairs(GetAllyHeroes()) do
			if  allies.charName ~= "Lulu" and 
				allies.charName ~= "Twitch" and 
				allies.charName ~= "KogMaw" and
				allies.charName ~= "Tristana" and
				allies.charName ~= "Ashe" and
				allies.charName ~= "Vayne" and
				allies.charName ~= "Varus" and
				allies.charName ~= "Xayah" and
				allies.charName ~= "Lucian" and
				allies.charName ~= "Sivir" and
				allies.charName ~= "Draven" and
				allies.charName ~= "Kalista" and
				allies.charName ~= "Caitlyn" and
				allies.charName ~= "Jinx" and
				allies.charName ~= "Samira" and
				allies.charName ~= "Ezreal" then
				Menu.Combo.WAlly.wset:MenuElement({id = allies.charName, name = "Priority: "..allies.charName, value = 0, min = 0, max = 5})
			end	

			if  allies.charName == "Twitch" or 
				allies.charName == "KogMaw" or 
				allies.charName == "Tristana" or
				allies.charName == "Ashe" or
				allies.charName == "Vayne" or
				allies.charName == "Varus" or
				allies.charName == "Xayah" or
				allies.charName == "Lucian" or
				allies.charName == "Sivir" or
				allies.charName == "Draven" or
				allies.charName == "Kalista" or
				allies.charName == "Caitlyn" or
				allies.charName == "Jinx" or
				allies.charName == "Samira" or				
				allies.charName == "Ezreal" then
				Menu.Combo.WAlly.wset:MenuElement({id = allies.charName, name = "Priority: "..allies.charName, value = 1, min = 0, max = 5})
			end			
		end		
	end,0.2)
	
	Menu.Combo:MenuElement({id = "UseE", name = "E Usage on Enemy", value = 2, drop = {"Always", "Logic", "Never"}})

	Menu.Combo:MenuElement({type = MENU, id = "rset", name = "[R] Settings"})	
	Menu.Combo.rset:MenuElement({id = "UseR", name = "[R] Enemy", value = true})
    Menu.Combo.rset:MenuElement({id = "hitr", name = "[R] if Knocks Up X Enemies", value = 2, min = 1, max = 5})
	Menu.Combo.rset:MenuElement({type = MENU, id = "autor", name = "Auto[R] Ally"})	
	DelayAction(function()
		for i, allies in pairs(GetAllyHeroes()) do
			if not Menu.Combo.rset.autor[allies.charName] then
				Menu.Combo.rset.autor:MenuElement({id = allies.charName, name = allies.charName.." Hp lower than", value = 30, min = 1, max = 100, identifier = "%"})
			end
		end
	end, 0.2)
 
	Menu.Combo:MenuElement({type = MENU, id = "self", name = "Lulu Settings"})
	Menu.Combo.self:MenuElement({id = "turret", name = "Auto[E] Turret Hit", value = true})	
	Menu.Combo.self:MenuElement({id = "UseR", name = "Auto[R]", value = true})
    Menu.Combo.self:MenuElement({id = "hitr", name = "Auto[R] if Knocks Up X Enemies", value = 2, min = 1, max = 5})
	Menu.Combo.self:MenuElement({id = "cc", name = "Auto[R] on CC", value = true})	


	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "UseEQ", name = "Use [E] > [Q] Extended", value = true})

	--MiscMenu
	Menu:MenuElement({type = MENU, id = "misc", name = "Misc"})	

	Menu.misc:MenuElement({type = MENU, id = "shield", name = "Shielding Settings"})
	Menu.misc.shield:MenuElement({id = "enable", name = "Enable Shielding", value = true})
	Menu.misc.shield:MenuElement({id = "cc", name = "Auto Ult on CC", value = true})	

	
	Menu.misc.shield:MenuElement({type = MENU, id = "BasicAttack", name = "Basic Attack Shield Settings"})	
	Menu.misc.shield.BasicAttack:MenuElement({id = "aa", name = "Shield on Basic attack", value = true})
	Menu.misc.shield.BasicAttack:MenuElement({id = "aahp", name = "Ally HP to Shield", value = 40, min = 1, max = 100, identifier = "%"})	
	Menu.misc.shield.BasicAttack:MenuElement({id = "critaa", name = "Shield on Crit attack", value = true})
	Menu.misc.shield.BasicAttack:MenuElement({id = "crithp", name = "Ally HP to Shield", value = 40, min = 1, max = 100, identifier = "%"})		
	Menu.misc.shield.BasicAttack:MenuElement({id = "turret", name = "Shield on Turret attack", value = true})
	
	Menu.misc.shield:MenuElement({type = MENU, id = "Blacklist", name = "Ally Shield Blacklist"})	
	DelayAction(function()
		for i, Hero in pairs(GetAllyHeroes()) do
			Menu.misc.shield.Blacklist:MenuElement({id = Hero.charName, name = "Dont Use on "..Hero.charName, value = false})		
		end		
	end,0.2)		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})
	
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	


	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 950, Speed = 1450, Collision = false
	}
	
	QspellData = {speed = 1450, range = 950, delay = 0.25, radius = 60, collision = {nil}, type = "linear"}	
  	                                           
											   
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("WndMsg",function(msg, param) CheckWndMsg(msg, param) end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 900, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 925, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 650, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 650, 1, DrawColor(225, 225, 125, 10))
		end
	end)	
end

local Pix = nil
local timer = 0
function Tick()
	if MyHeroNotReady() then return end
	AutoInterrupt()
	if Menu.misc.shield.cc:Value() and Ready(_R) then
		for i, ally in pairs(GetAllyHeroes()) do
			if ally and IsValid(ally) then
				if Menu.misc.shield.Blacklist[ally.charName] and not Menu.misc.shield.Blacklist[ally.charName]:Value() and GetDistance(myHero.pos, ally.pos) <= spellR.range then
					if IsImmobileTarget(ally) then
						Control.CastSpell(HK_R, ally)
					end
				end
			end
		end
	end
	
	if Menu.Combo.self.cc:Value() and Ready(_R) then
		if IsImmobileTarget(myHero) then
			Control.CastSpell(HK_R, myHero)
		end
	end	

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()			
	end
end

function CheckWndMsg(msg, param)
	if msg == 257 then
		local delay = nil
		if param == HK_E then
			delay = ping
		end
	
		if delay then               
			DelayAction(function() 
				CheckPix() 
			end, delay)
		end
	end	
end

function CheckPixId(obj)
	if Pix and Pix.networkID == obj.networkID then
		return true
	end
	return false
end

function CheckPix()
	for i = 1, GameObjectCount() do
		local obj = GameObject(i)
		
		if obj and obj.name == "RobotBuddy" and obj.team == TEAM_ALLY and not CheckPixId(obj) then
			--print(obj.owner)
			Pix = obj
			--print("Pix Found")
		end
	end	
end
  
function AutoInterrupt()
	local unit, spell = OnProcessSpell()
	
	if Ready(_W) then
		if unit and unit.isEnemy and spell and spell.target == myHero.handle then
			for i = 1, #PSpells do
				if spell.name:lower():find(PSpells[i]:lower()) then
					if GetDistance(unit.pos, myHero.pos) <= spellW.range then
						Control.CastSpell(HK_W, unit)
					end
				end
			end
		end		
		
		for i, ally in pairs(GetAllyHeroes()) do
			if ally and IsValid(ally) then
				--local unit, spell = OnProcessSpell()
				if unit and unit.isEnemy and spell and spell.target == ally.handle then
					--print(spell)
					for i = 1, #PSpells do
						if spell.name:lower():find(PSpells[i]:lower()) then
							if Menu.misc.shield.Blacklist[ally.charName] and not Menu.misc.shield.Blacklist[ally.charName]:Value() and GetDistance(unit.pos, myHero.pos) <= spellW.range then
								Control.CastSpell(HK_W, unit)
							end
						end
					end
				end
			end
		end
	end	

	for i, enemy in pairs(GetEnemyHeroes()) do		
		local heroTarget = nil
		if unit and unit.isAlly and spell and spell.target == enemy.handle then
			for i = 1, #PSpells do
				if spell.name:lower():find(PSpells[i]:lower()) and GetDistance(unit.pos, myHero.pos) <= spellW.range and Menu.Combo.WAlly.wset[unit.charName] and Menu.Combo.WAlly.wset[unit.charName]:Value() > 0 then
					if heroTarget == nil then
						heroTarget = unit
					elseif Menu.Combo.WAlly.wset[unit.charName]:Value() < Menu.Combo.WAlly.wset[heroTarget.charName]:Value() then
						heroTarget = unit
					end
					if heroTarget then
						if Menu.Combo.WAlly.UseW:Value() and Ready(_W) then
							Control.CastSpell(HK_W, heroTarget)
						end
						if Menu.Combo.WAlly.UseE:Value() and Ready(_E) then
							Control.CastSpell(HK_E, heroTarget)
						end
					end
				end
			end
			if GetDistance(unit.pos, myHero.pos) <= spellW.range and Menu.Combo.WAlly.wset[unit.charName] and Menu.Combo.WAlly.wset[unit.charName]:Value() > 0 then
				if heroTarget == nil then
					heroTarget = unit
				elseif Menu.Combo.WAlly.wset[unit.charName]:Value() < Menu.Combo.WAlly.wset[heroTarget.charName]:Value() then
					heroTarget = unit
				end
				if heroTarget then
					if Menu.Combo.WAlly.UseW:Value() and Ready(_W) then
						Control.CastSpell(HK_W, heroTarget)
					end
					if Menu.Combo.WAlly.UseE:Value() and Ready(_E) then
						Control.CastSpell(HK_E, heroTarget)
					end
				end
			end			
		end
		
		if unit and unit.isAlly and spell then
			if spell.name:find("KogMawBioArcaneBarrage") and GetDistance(unit.pos, myHero.pos) <= spellW.range and Menu.Combo.WAlly.wset[unit.charName] and Menu.Combo.WAlly.wset[unit.charName]:Value() > 0 then
				if Menu.Combo.WAlly.UseW:Value() and Ready(_W) then
					Control.CastSpell(HK_W, unit)
				end
				if Menu.Combo.WAlly.UseE:Value() and Ready(_E) then
					Control.CastSpell(HK_E, unit)
				end
			end
		end

		for i, ally in pairs(GetAllyHeroes()) do
			if ally and IsValid(ally) then
				if unit and unit.isEnemy and spell and spell.target == ally.handle then
					if not spell.name:find("crit") then
						if not spell.name:find("BasicAttack") then
							if GetDistance(ally.pos, myHero.pos) <= spellE.range and Ready(_E) then
								Control.CastSpell(HK_E, ally)
							end

							if GetDistance(ally.pos, myHero.pos) <= spellR.range and Menu.Combo.rset.autor[ally.charName] and ally.health/ally.maxHealth <= Menu.Combo.rset.autor[ally.charName]:Value()/100 then
								Control.CastSpell(HK_R, ally)
							end
						end
					end
				end
			end
		end
		
		if Menu.misc.shield.BasicAttack.aa:Value() then
			for i, ally in pairs(GetAllyHeroes()) do
				if ally and GetDistance(ally.pos, myHero.pos) <= spellE.range and IsValid(ally) then
					if unit and unit.isEnemy and spell and spell.target == ally.handle then
						for i = 1, #PSpells do
							if spell.name:lower():find(PSpells[i]:lower()) then
								if (ally.health / ally.maxHealth)*100 <= Menu.misc.shield.BasicAttack.aahp:Value() then
									if Menu.misc.shield.Blacklist[ally.charName] and not Menu.misc.shield.Blacklist[ally.charName]:Value() then
										if Ready(_E) then
											Control.CastSpell(HK_E, ally)
										end
										if GetDistance(ally.pos, myHero.pos) <= spellR.range and Menu.Combo.rset.autor[ally.charName] and ally.health/ally.maxHealth <= Menu.Combo.rset.autor[ally.charName]:Value()/100 then
											Control.CastSpell(HK_R, ally)
										end
									end
								end
							end
						end
						
						if (ally.health / ally.maxHealth)*100 <= Menu.misc.shield.BasicAttack.aahp:Value() then
							if Menu.misc.shield.Blacklist[ally.charName] and not Menu.misc.shield.Blacklist[ally.charName]:Value() then
								if Ready(_E) then
									Control.CastSpell(HK_E, ally)
								end
								if GetDistance(ally.pos, myHero.pos) <= spellR.range and Menu.Combo.rset.autor[ally.charName] and ally.health/ally.maxHealth <= Menu.Combo.rset.autor[ally.charName]:Value()/100 then
									Control.CastSpell(HK_R, ally)
								end
							end
						end
					end
				end
			end
		end
		
		if Menu.misc.shield.BasicAttack.critaa:Value() then
			for i, ally in pairs(GetAllyHeroes()) do
				if ally and GetDistance(ally.pos, myHero.pos) <= spellE.range and IsValid(ally) then
					if unit and unit.isEnemy and spell and spell.target == ally.handle then
						if spell.name:find("crit") then
							if (ally.health / ally.maxHealth)*100 <= Menu.misc.shield.BasicAttack.crithp:Value() then
								if Menu.misc.shield.Blacklist[ally.charName] and not Menu.misc.shield.Blacklist[ally.charName]:Value() then
									if Ready(_E) then
										Control.CastSpell(HK_E, ally)
									end
									if GetDistance(ally.pos, myHero.pos) <= spellR.range and Menu.Combo.rset.autor[ally.charName] and ally.health/ally.maxHealth <= Menu.Combo.rset.autor[ally.charName]:Value()/100 then
										Control.CastSpell(HK_R, ally)
									end
								end
							end
						end 
						
					elseif unit and unit.isEnemy and spell and spell.target == myHero.handle then
						if myHero.health / myHero.maxHealth <= 0.3 then
							if Ready(_E) then
								Control.CastSpell(HK_E, myHero)
							end
							if Ready(_R) then
								Control.CastSpell(HK_R, myHero)
							end
						end					
					end
					
				elseif unit and unit.isEnemy and spell and spell.target == myHero.handle then
					if myHero.health / myHero.maxHealth <= 0.3 then
						if Ready(_E) then
							Control.CastSpell(HK_E, myHero)
						end
						if Ready(_R) then
							Control.CastSpell(HK_R, myHero)
						end
					end					
				end					
			end
		end		
		
		if Menu.misc.shield.BasicAttack.turret:Value() then
			for i, ally in pairs(GetAllyHeroes()) do
				if ally and GetDistance(ally.pos, myHero.pos) <= spellE.range and IsValid(ally) then
					local IsTurretHit = GetEnemyTurretHit(ally)
					if IsTurretHit then
						if Menu.misc.shield.Blacklist[ally.charName] and not Menu.misc.shield.Blacklist[ally.charName]:Value() then
							if Ready(_E) then
								Control.CastSpell(HK_E, ally)
							end
							if Ready(_R) and GetDistance(ally.pos, myHero.pos) <= spellR.range and Menu.Combo.rset.autor[ally.charName] and ally.health/ally.maxHealth <= Menu.Combo.rset.autor[ally.charName]:Value()/100 then
								Control.CastSpell(HK_R, ally)
							end
						end
					end
				end
			end
		end
		
		if Menu.Combo.self.turret:Value() and Ready(_E) then
			local IsTurretHit = GetEnemyTurretHit(myHero)
			if IsTurretHit then
				Control.CastSpell(HK_E, myHero)
			end
		end		
	end	
end

local function GetClosestMobToEnemyForGap()
	local closestMinion = nil
	local closestMinionDistance = 9999
	for i, enemies in pairs(GetEnemyHeroes()) do
		if enemies and IsValid(enemies) then
			for i = 1,GameMinionCount() do
				local minion = GameMinion(i)
				if myHero.pos:DistanceTo(minion.pos) < spellE.range and IsValid(minion) and minion.team == TEAM_ENEMY then
					if enemies.pos:DistanceTo(minion.pos) < spellQ.range then
						local minionDistanceToMouse = enemies.pos:DistanceTo(minion.pos)

						if minionDistanceToMouse < closestMinionDistance then
							closestMinion = minion
							closestMinionDistance = minionDistanceToMouse
						end
					end
				end
			end
		end
	end
	return closestMinion
end

function Harass()
	if Menu.Harass.UseQ:Value() and Ready(_Q) then
		local target = GetTargetQ()
		if target and IsValid(target) then
			local pos = PredPos(target, false)
			if pos and GetDistance(pos, myHero.pos) <= Menu.Combo.QRange:Value() then
				Control.CastSpell(HK_Q, pos)
			end
		end
		
		if Pix then
			for i, hero in pairs(GetEnemyHeroes()) do
				if hero and IsValid(hero) and GetDistance(Pix.pos, hero.pos) <= spellQ.range and GetDistance(myHero.pos, hero.pos) > spellQ.range then
					local pos = PredPos(hero, true)
					if pos then
						Control.CastSpell(HK_Q, pos)
					end
				end
			end
		end
	end
	
	if Menu.Harass.UseE:Value() and Ready(_E) then
		local target = GetTargetQ()
		if target and IsValid(target) then
			if (GetAllyCount(spellE.range + 200, myHero) == 1 or ((target.health / target.maxHealth) * 100 < 5 and (myHero.health / myHero.maxHealth) * 100 > 20)) then
				if GetDistance(myHero.pos, target.pos) < spellE.range then
					Control.CastSpell(HK_E, target)
				end
			end
		end
	end
	
	if Menu.Harass.UseEQ:Value() and Ready(_Q) then
		for i, ally in pairs(GetAllyHeroes()) do
			if ally and IsValid(ally) and GetDistance(myHero.pos, ally.pos) <= spellE.range then
				for k, hero in pairs(GetEnemyHeroes()) do
					if hero and IsValid(hero) and GetDistance(myHero.pos, hero.pos) > spellQ.range then
						if (GetDistance(hero.pos, ally.pos) < spellQ.range - 150) and Ready(_E) then
							Control.CastSpell(HK_E, ally)
						end
					end
				end
			end
		end
		
		local minion = GetClosestMobToEnemyForGap()
		if minion and GetDistance(myHero.pos, minion.pos) < spellE.range then
			for i, hero in pairs(GetEnemyHeroes()) do
				if hero and IsValid(hero) and GetDistance(myHero.pos, hero.pos) > spellQ.range then
					if Ready(_E) and (GetDistance(minion.pos, hero.pos) < spellQ.range - 150) and minion.health > getdmg("E", minion, myHero) then
						Control.CastSpell(HK_E, minion)
					end
				end
			end
		end
	end
end

function Combo()
	if Menu.Combo.WEnemy.UseW:Value() and Ready(_W) then
		local target = GetTargetQ()
		if target and IsValid(target) then
			if GetDistance(myHero.pos, target.pos) <= spellW.range then
				if Menu.Combo.WEnemy.Blacklist[target.charName] and not Menu.Combo.WEnemy.Blacklist[target.charName]:Value() then
					Control.CastSpell(HK_W, target)
				end
			end
		end
	end
	
	if Menu.Combo.UseQ:Value() and Ready(_Q) then
		local target = GetTargetQ()
		if target and IsValid(target) then
			local pos = PredPos(target, false)
			if pos and GetDistance(pos, myHero.pos) <= Menu.Combo.QRange:Value() then
				Control.CastSpell(HK_Q, pos)
			end
		end
	end
	
	local target = GetTargetQ()
	if target and IsValid(target) and Ready(_E) then
		if GetDistance(target.pos, myHero.pos) <= spellE.range then
			if Menu.Combo.UseE:Value() == 1 then
				Control.CastSpell(HK_E, target)
			
			elseif Menu.Combo.UseE:Value() == 2 then
				if (GetAllyCount(spellE.range + 200, myHero) == 1 or ((target.health / target.maxHealth) * 100 < 5 and (myHero.health / myHero.maxHealth) * 100 > 20)) then
					Control.CastSpell(HK_E, target)
				end
			end
		end
	end
	
	if Menu.Combo.rset.UseR:Value() and Ready(_R) then
		for i, hero in pairs(GetAllyHeroes()) do
			if hero and IsValid(hero) and GetDistance(hero.pos, myHero.pos) <= spellR.range then
				if GetEnemyCount(350, hero) >= Menu.Combo.rset.hitr:Value() then
					Control.CastSpell(HK_R, hero)
				end
			end
		end
	end
	
	if Menu.Combo.self.UseR:Value() and Ready(_R) then
		if GetEnemyCount(350, myHero) >= Menu.Combo.self.hitr:Value() then
			Control.CastSpell(HK_R, myHero)
		end
	end	
	
	if Pix and Ready(_Q) then
		for i, hero in pairs(GetEnemyHeroes()) do
			if hero and IsValid(hero) and GetDistance(hero.pos, Pix.pos) <= spellQ.range and GetDistance(hero.pos, myHero.pos) > spellQ.range then
				local pos = PredPos(hero, true)
				if pos then
					Control.CastSpell(HK_Q, pos)
				end
			end
		end
	end
	
	if Menu.Combo.UseEQ:Value() and Ready(_Q) then
		for i, ally in pairs(GetAllyHeroes()) do
			if ally and IsValid(ally) and GetDistance(myHero.pos, ally.pos) <= spellE.range then
				for k, hero in pairs(GetEnemyHeroes()) do
					if hero and IsValid(hero) and GetDistance(myHero.pos, hero.pos) > spellQ.range then
						if (GetDistance(hero.pos, ally.pos) < spellQ.range - 150) and Ready(_E) then
							Control.CastSpell(HK_E, ally)
						end
					end
				end
			end
		end
		
		local minion = GetClosestMobToEnemyForGap()
		if minion and GetDistance(myHero.pos, minion.pos) < spellE.range then
			for i, hero in pairs(GetEnemyHeroes()) do
				if hero and IsValid(hero) and GetDistance(myHero.pos, hero.pos) > spellQ.range then
					if Ready(_E) and (GetDistance(minion.pos, hero.pos) < spellQ.range - 150) and minion.health > getdmg("E", minion, myHero) then
						Control.CastSpell(HK_E, minion)
					end
				end
			end
		end
	end
end

function PredPos(unit, StartPos)
	if StartPos then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, QData, Pix)
			if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
				return pred.CastPosition
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(Pix, unit, QspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
				return pred.CastPos
			end
		else
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 950, Speed = 1450, Collision = false})
			QPrediction:GetPrediction(unit, Pix)
			if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				return QPrediction.CastPosition
			end
		end
		return false
	else
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
			local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 950, Speed = 1450, Collision = false})
			QPrediction:GetPrediction(unit, myHero)
			if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
				return QPrediction.CastPosition
			end
		end
		return false
	end	
end



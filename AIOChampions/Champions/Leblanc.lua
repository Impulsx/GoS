local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
end

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

local function GetEnemyCount(range, pos)
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
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

local function wUsed()
	return myHero:GetSpellData(_W).name == "leblancslidereturn"
end

local function wrUsed()
	return myHero:GetSpellData(_R).name == "leblancslidereturnm"
end 

local function GetCustomDistance(p1, p2)
	p2 = p2 or myHero.pos
	return math.sqrt((p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2)
end

local function SpellCalc(spell, target)
	local dmg = 0
	if spell == "RQ" then
		dmg = 100 * myHero:GetSpellData(_R).level + 0.65 * myHero.ap
	elseif spell == "RW" then
		dmg = 150 * myHero:GetSpellData(_R).level + 0.975 * myHero.ap 
	elseif spell == "RE" then
		dmg = 100 * myHero:GetSpellData(_R).level + 0.65 * myHero.ap
	elseif spell == "QMark" then
		dmg = 25 * myHero:GetSpellData(_Q).level + 30 + 0.4 * myHero.ap
	end 
	return ((CalcMagicalDamage(myHero, target, dmg) and CalcMagicalDamage(myHero, target, dmg)) or 0)
end

local smartComboTime = GameTimer()
local CanCastSpells = true
local lastActivated = nil
local RSkill = nil
local lastChainCast = GameTimer()
local chainTarget = nil
local WstartPos = myHero.pos
local WRstartPos = myHero.pos

function LoadScript() 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "comboWay", name = "Combo Logic", value = 1, drop = {"Smart", "QRWE", "QWRE", "WQRE", "WRQE"}})

	--WSettings  
	Menu:MenuElement({type = MENU, id = "settingsW", name = "W Settings"})
	Menu.settingsW:MenuElement({id = "useOptional", name = "Use Optional W Settings", value = true})	
	Menu.settingsW:MenuElement({id = "useOptionalW", name = "Return Way:", value = 1, drop = {"Smart", "Skills used"}})	
	
	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})		
	Menu.Harass:MenuElement({id = "harassQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "harassW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "harassE", name = "[E]", value = true})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--Lasthit Menu
	Menu:MenuElement({type = MENU, id = "Last", name = "Lasthit Minions"})	
	Menu.Last:MenuElement({id = "AA", name = "Only Lasthit if out of AA range", value = true}) 	
	Menu.Last:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Last:MenuElement({id = "UseW", name = "[W]", value = true})  	
	Menu.Last:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})	
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "killstealQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "killstealW", name = "[W]", value = true})	
	Menu.ks:MenuElement({id = "killstealE", name = "[E]", value = true})
	Menu.ks:MenuElement({id = "killstealR", name = "[R]", value = true})
	Menu.ks:MenuElement({id = "enemies", name = "Perform KillSteal on:", type = MENU})
	DelayAction(function()	
		for i, Hero in ipairs(GetEnemyHeroes()) do
			Menu.ks.enemies:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
		end	
	end, 0.01)		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	
	
	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.75, Radius = 70, Range = 750, Speed = 3200, Collision = false
	}
	
	WspellData = {speed = 3200, range = 750, delay = 0.75, radius = 70, collision = {nil}, type = "linear"}	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 400, Speed = 2000, Collision = false
	}
	
	QspellData = {speed = 2000, range = 400, delay = 0.25, radius = 70, collision = {nil}, type = "linear"}	
  	                                           
	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 865, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 700, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 600, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

function Tick()
	if CanCastSpell == false and smartComboTime + 3 > GameTimer() then CanCastSpells = true end
	if not Ready(_R) and not CanCastSpell then CanCastSpells = true RSkill = nil end	
	
	if MyHeroNotReady() then return end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		--Clear()
		--JungleClear()			
	end	
	
	if Menu.settingsW.useOptional:Value() then
		SpecificSpellChecks()
	end	
	CheckSpell()
	CeckBuffW()
	KillSteal()	
	
end	

function CheckSpell()
	local unit, spell = OnProcessSpell()

	if unit.isMe and spell.name == "LeblancSlide" then
		WstartPos = spell.startPos 
	end

	if unit.isMe and spell.name == "LeblancSlideM" then
		WRstartPos = spell.startPos
	end

	if unit.isMe and spell.name == "LeblancSoulShackle" then
		lastChainCast = GameTimer()
	end

	if unit.isMe and (spell.name == "LeblancChaosOrb" or spell.name == "LeblancSlide" or spell.name == "LeblancSoulShackle") then
    	lastActivated = spell.name
    end
end

function CeckBuffW()
	local target = GetTarget(900)
	if target == nil then return end
	if IsValid(target) and HasBuff(target, "") then
		chainTarget = target
	else
		chainTarget = nil
	end
end

function SpecificSpellChecks()
	if lastChainCast + 2 < GameTimer() then return end

	if wUsed() and chainTarget ~= nil and GetCustomDistance(WstartPos, chainTarget) <= 600 + 400 then return end 
	if wrUsed() and not wUsed() and chainTarget ~= nil and GetCustomDistance(WRstartPos, chainTarget) <= 600 + 400 then return end

	if Menu.settingsW.useOptionalW:Value() == 1 then 
		if wUsed() and wrUsed() then
			if GetEnemyCount(600, WRstartPos) < GetEnemyCount(600, myHero.pos) and not Ready(_Q) and not Ready(_E) then
				Control.CastSpell(HK_W)
			end
			
		elseif wUsed() and GetEnemyCount(600, WstartPos) < GetEnemyCount(600, myHero.pos) then
			Control.CastSpell(HK_W)
			
		else
			if wrUsed() and GetEnemyCount(600, WRstartPos) < GetEnemyCount(600, myHero.pos) then
				Control.CastSpell(HK_R)
			end	
		end
		
	else
		
		if wUsed() and wrUsed() then
			if not Ready(_Q) and not Ready(_E) then
				Control.CastSpell(HK_W)
			end
			
		elseif wUsed() then
			if not Ready(_Q) and not Ready(_E) then
				Control.CastSpell(HK_W)
			end
			
		elseif wrUsed() then
			if not Ready(_Q) and not Ready(_E) then
				Control.CastSpell(HK_R)
			end
		end
	end
end

function Combo()
	local target = GetTarget(900)
	if target == nil then return end
	if IsValid(target) then

		smartComboTime = GameTimer()

		if not CanCastSpells and RSkill ~= nil then
			if RSkill == "RQ" then
				Control.CastSpell(HK_Q, target)
			elseif RSkill == "RW" then
				Control.CastSpell(HK_W, target)
			end
			return
		end

		if CanCastSpells ~= true and RSkill ~= nil then return end

		if Menu.Combo.comboWay:Value() == 1 then
			SmartCombo(target)
		elseif Menu.Combo.comboWay:Value() == 2 then
			-- "Q", "RQ", "W", "E"
			Combo1(target)
		elseif Menu.Combo.comboWay:Value() == 3 then
			-- "Q", "W", "RW", "E"
			Combo2(target)
		elseif Menu.Combo.comboWay:Value() == 4 then
			-- "W", "Q", "RQ", "E"
			Combo3(target)
		elseif Menu.Combo.comboWay:Value() == 5 then
			-- "W", "RW", "Q", "E"
			Combo4(target)
		end
	end
end

function SmartCombo(target) 
	if not CanCastSpells and RSkill ~= nil then return end

	local Wdmg = ((Ready(_W) and not wUsed and getdmg("W", target, myHero)) or 0)
	local RWdmg = ((Ready(_R) and not wrUsed() and SpellCalc("RW", target)) or 0)

	if Ready(_W) and Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 600 then
		local enemyCount = GetEnemyCount(250, target.pos)
		if enemyCount >= 3 then
			if Control.CastSpell(HK_W, target) and not wUsed() then 
				CanCastSpells = false
				RSkill = "RW"
			end
			return
		end
	end

	local Qdmg = ((Ready(_Q) and getdmg("Q", target, myHero)) or 0)
	local RQdmg = ((Ready(_R) and SpellCalc("RQ", target)) or 0)
	local QMark = (((Ready(_Q) or Ready(_R)) and SpellCalc("QMark", target)) or 0)
	
	-- Q + R
	if myHero.pos:DistanceTo(target.pos) < 700 and Ready(_Q) and Ready(_R) and Qdmg + RQdmg + QMark + QMark + Wdmg > Wdmg + RWdmg + Qdmg then
		if Control.CastSpell(HK_Q, target) then
			CanCastSpells = false
			RSkill = "RQ"
		end
		return
		
	-- W + R
	elseif myHero.pos:DistanceTo(target.pos) < 600 and Ready(_W) and Ready(_R) and Wdmg + RWdmg > Qdmg + RQdmg + QMark then
		if Control.CastSpell(HK_W, target) then 
			CanCastSpells = false
			RSkill = "RW"
		end
		return
		
	elseif myHero.pos:DistanceTo(target.pos) > 700 and myHero.pos:DistanceTo(target.pos) < 950 and Ready(_E) then
		Control.CastSpell(HK_E, target) 
		return
		
	else
		if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
			Control.CastSpell(HK_Q, target)
		elseif Ready(_R) then
			CastR("Q", target)
		elseif Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then	
			Control.CastSpell(HK_W, target)
		elseif Ready(_R) then	
			CastR("W", target)
		else
			if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 850 then
				Control.CastSpell(HK_E, target)
			end	
		end
	end
end

function Combo1(target)
	if Ready(_Q) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		if Control.CastSpell(HK_Q, target) then
			CanCastSpell = false
			RSkill = "Q"
		end
		return
	end

	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	

	elseif lastActivated == "LeblancChaosOrb" and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_R, target)

	elseif not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then
		Control.CastSpell(HK_W, target)
	
	else
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 850 then
			Control.CastSpell(HK_E, target)
		end	
	end	
end

function Combo2(target)
	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)
	end	

	if Ready(_W) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 600 then
		if not wUsed() and Control.CastSpell(HK_W, target) then
			CanCastSpell = false
			RSkill = "W"
		end
		return
	end

	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then
		Control.CastSpell(HK_W, target)

	elseif lastActivated == "LeblancSlide" and Ready(_R) and not wrUsed() then
		CastR("W", target)
		
	else
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 850 then
			Control.CastSpell(HK_E, target)
		end	
	end	
end

function Combo3(target)
	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then 
		Control.CastSpell(HK_W, target) 
	end

	if Ready(_Q) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		if Control.CastSpell(HK_Q, target) then
			CanCastSpell = false
			RSkill = "Q"
		end
		return
	end

	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	

	elseif lastActivated == "LeblancChaosOrb" and Ready(_R) then
		CastR("Q", target)
	
	else
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 850 then
			Control.CastSpell(HK_E, target)
		end	
	end	
end

function Combo4(target)
	if Ready(_W) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 600 then
		if not wUsed() and Control.CastSpell(HK_W, target) then
			CanCastSpell = false
			RSkill = "W"
		end
		return
	end

	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then 
		Control.CastSpell(HK_W, target) 

	elseif self.lastActivated == "LeblancSlide" and Ready(_R) and not wrUsed() then
		CastR("W", target)
	
	elseif Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	
	
	else
		if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 850 then
			Control.CastSpell(HK_E, target)
		end	
	end
end

function Harass()
	local target = GetTarget(900)
	if target == nil then return end
	if IsValid(target) then
		
		if Menu.Harass.harassQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
			Control.CastSpell(HK_Q, target)
		end
		
		if Menu.Harass.harassW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then
			if not wUsed() then
				Control.CastSpell(HK_W, target) 
			end
		end
		
		if Menu.Harass.harassE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 850 then
			Control.CastSpell(HK_E, target)
		end

		if wUsed() and not Ready(_Q) and not Ready(_E) then
			Control.CastSpell(HK_W)
		end
	end
end

function KillSteal()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if IsValid(enemy) and myHero.pos:DistanceTo(enemy.pos) < 850 and Menu.ks.enemies[enemy.charName] and Menu.ks.enemies[enemy.charName]:Value() then
			local Qdmg = ((Menu.ks.killstealQ:Value() and myHero.pos:DistanceTo(enemy.pos) < 700 and Ready(_Q) and getdmg("Q", enemy, myHero)) or 0)
			local Wdmg = ((Menu.ks.killstealW:Value() and myHero.pos:DistanceTo(enemy.pos) < 600 and Ready(_W) and not wUsed() and getdmg("W", enemy, myHero)) or 0)
			local Edmg = ((Menu.ks.killstealE:Value() and myHero.pos:DistanceTo(enemy.pos) < 850 and Ready(_E) and getdmg("E", enemy, myHero)) or 0)
			local RQdmg = ((Menu.ks.killstealR:Value() and Ready(_R) and lastActivated == "LeblancChaosOrb" and SpellCalc("RQ", enemy)) or 0)
			local RWdmg = ((Menu.ks.killstealR:Value() and Ready(_R) and not wrUsed() and lastActivated == "LeblancSlide" and SpellCalc("RW", enemy)) or 0)
			
			if Qdmg > enemy.health then
				Control.CastSpell(HK_Q, enemy)
			elseif Wdmg > enemy.health then
				Control.CastSpell(HK_W, enemy)
			elseif Edmg > enemy.health then
				Control.CastSpell(HK_E, enemy)
			elseif RQdmg > enemy.health then
				CastR("Q", enemy)
			elseif RWdmg > enemy.health then
				CastR("W", enemy)
			end 
		end
	end
end

function CastR(skill, target)
	if skill == "Q" and lastActivated == "LeblancChaosOrb" then
		if myHero.pos:DistanceTo(target.pos) < 700 then
			Control.CastSpell(HK_R, target)
		end
	elseif skill == "W" and lastActivated == "LeblancSlide" then
		if not wrUsed() and myHero.pos:DistanceTo(target.pos) < 600 then
			Control.CastSpell(HK_R, target)
		end
	end
end
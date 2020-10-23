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
	return myHero:GetSpellData(_W).name == "LeblancWReturn"
end

local function wrUsed()
	return myHero:GetSpellData(_R).name == "LeblancRWReturn"
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
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})	
	Menu:MenuElement({name = " ", drop = {"TestVersion 0.1"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "comboWay", name = "Combo Logic", value = 1, drop = {"Smart", "QRWE", "QWRE", "WQRE", "WRQE"}})
	Menu.Combo:MenuElement({id = "Block", name = "Block AA if [R] Ready (FastCombo)", value = true})

	--WSettings  
	Menu:MenuElement({type = MENU, id = "settingsW", name = "W Settings"})
	Menu.settingsW:MenuElement({id = "useOptional", name = "Use Optional W Settings", value = true})	
	Menu.settingsW:MenuElement({id = "useOptionalW", name = "Return Way:", value = 1, drop = {"Smart", "Skills used"}})	
	
	--HarassMenu  
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})		
	Menu.Harass:MenuElement({id = "harassQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "harassW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "harassE", name = "[E]", value = true})	
	--[[  
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
 ]]
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
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	
	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 925, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	EspellData = {speed = 1750, range = 925, delay = 0.25, radius = 55, collision = {"minion"}, type = "linear"}	
  	                                          	
	Callback.Add("Tick", function() Tick() end)
	
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	end		
	
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
	if CanCastSpells == false and smartComboTime + 3 > GameTimer() then CanCastSpells = true end
	if not Ready(_R) and not CanCastSpells then CanCastSpells = true RSkill = nil end	
	if Control.IsKeyDown(HK_R) then	Control.KeyUp(HK_R) end
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

function StopAutoAttack(args)
	local Mode = GetMode()
	if Menu.Combo.Block:Value() and Mode == "Combo" then
		if Ready(_R) then
			args.Process = false 
		else
			if args.Process == false then
				args.Process = true
			end
		end	
	end
end

function CeckBuffW()
	--print(WstartPos)
	local target = GetTarget(1100)
	if target == nil then return end
	if IsValid(target) and HasBuff(target, "LeblancE") then
		chainTarget = target
	else
		chainTarget = nil
	end
end

function CheckSpell()
	if GameTimer() - myHero:GetSpellData(_Q).castTime <= 0.4 then
    	lastActivated = SpellQ
	end	
	if GameTimer() - myHero:GetSpellData(_W).castTime <= 0.4 then
    	lastActivated = SpellW		
    end
	if GameTimer() - myHero:GetSpellData(_E).castTime <= 0.4 then
    	lastActivated = SpellE
		lastChainCast = GameTimer()
    end	
end

function SpecificSpellChecks()
	if lastChainCast + 2 < GameTimer() then return end

	if wUsed() and chainTarget ~= nil and GetDistance(WstartPos, chainTarget.pos) <= 600 + 400 then return end 
	if wrUsed() and not wUsed() and chainTarget ~= nil and GetDistance(WRstartPos, chainTarget.pos) <= 600 + 400 then return end

	if Menu.settingsW.useOptionalW:Value() == 1 then 
		if (wUsed() and wrUsed()) then
			if GetEnemyCount(400, WRstartPos) < GetEnemyCount(400, myHero.pos) and not Ready(_Q) and not Ready(_E) then
				Control.CastSpell(HK_W)
			end
			
		elseif wUsed() and GetEnemyCount(400, WstartPos) < GetEnemyCount(400, myHero.pos) then
			Control.CastSpell(HK_W)
			
		else
			if wrUsed() and GetEnemyCount(400, WRstartPos) < GetEnemyCount(400, myHero.pos) then
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
			if RSkill == "RQ" and Ready(_R) then
				CastR("Q", target)
			elseif RSkill == "RW" and Ready(_R) then
				CastR("W", target)
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
			if not wUsed() then 
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target)
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
		WstartPos = myHero.pos
		Control.CastSpell(HK_W, target) 
		CanCastSpells = false
		RSkill = "RW"
		return
		
	elseif myHero.pos:DistanceTo(target.pos) > 700 and myHero.pos:DistanceTo(target.pos) < 860 and Ready(_E) then
		CastE(target)
		return
		
	else
		if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
			Control.CastSpell(HK_Q, target)
		elseif Ready(_R) then
			CastR("Q", target)
		elseif Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then	
			WstartPos = myHero.pos
			Control.CastSpell(HK_W, target)
		elseif Ready(_R) then	
			CastR("W", target)
		else
			if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
				CastE(target)
			end	
		end
	end
end

function Combo1(target)
	if Ready(_Q) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		if Control.CastSpell(HK_Q, target) then
			CanCastSpells = false
			RSkill = "Q"
		end
		return
	end

	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	
	end
	
	if lastActivated == SpellQ and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		CastR("Q", target)
	end
	
	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then
		WstartPos = myHero.pos
		Control.CastSpell(HK_W, target)
	end
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
		CastE(target)
	end		
end

function Combo2(target)
	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)
	end	

	if Ready(_W) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 600 then
		if not wUsed() then
			WstartPos = myHero.pos
			Control.CastSpell(HK_W, target) 
			CanCastSpells = false
			RSkill = "W"
		end
		return
	end

	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then
		WstartPos = myHero.pos
		Control.CastSpell(HK_W, target)
	end
	
	if lastActivated == SpellW and Ready(_R) and not wrUsed() and myHero.pos:DistanceTo(target.pos) > 400 then
		CastR("W", target)
	end	
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
		CastE(target)
	end	
end

function Combo3(target)
	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then 
		WstartPos = myHero.pos
		Control.CastSpell(HK_W, target) 
	end

	if Ready(_Q) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 700 then
		if Control.CastSpell(HK_Q, target) then
			CanCastSpells = false
			RSkill = "Q"
		end
		return
	end

	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	
	end
	
	if lastActivated == SpellQ and Ready(_R) then
		CastR("Q", target)
	end
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
		CastE(target)
	end			
end

function Combo4(target)
	if Ready(_W) and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 600 then
		if not wUsed() then 
			WstartPos = myHero.pos
			Control.CastSpell(HK_W, target)
			CanCastSpells = false
			RSkill = "W"
		end
		return
	end

	if not wUsed() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 600 then 
		WstartPos = myHero.pos
		Control.CastSpell(HK_W, target) 
	end
	
	if lastActivated == SpellW and Ready(_R) and not wrUsed() and myHero.pos:DistanceTo(target.pos) > 400 then
		CastR("W", target)
	end
	
	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 700 then
		Control.CastSpell(HK_Q, target)	
	end
	
	if Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
		CastE(target)
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
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, target) 
			end
		end
		
		if Menu.Harass.harassE:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 860 then
			CastE(target)
		end

		if wUsed() and not Ready(_Q) and not Ready(_E) then
			WstartPos = myHero.pos
			Control.CastSpell(HK_W)
		end
	end
end

function KillSteal()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if IsValid(enemy) and myHero.pos:DistanceTo(enemy.pos) < 850 and Menu.ks.enemies[enemy.charName] and Menu.ks.enemies[enemy.charName]:Value() then
			local Qdmg = ((Menu.ks.killstealQ:Value() and myHero.pos:DistanceTo(enemy.pos) < 700 and Ready(_Q) and getdmg("Q", enemy, myHero)) or 0)
			local Wdmg = ((Menu.ks.killstealW:Value() and myHero.pos:DistanceTo(enemy.pos) < 600 and Ready(_W) and not wUsed() and getdmg("W", enemy, myHero)) or 0)
			local Edmg = ((Menu.ks.killstealE:Value() and myHero.pos:DistanceTo(enemy.pos) < 860 and Ready(_E) and getdmg("E", enemy, myHero)) or 0)
			local RQdmg = ((Menu.ks.killstealR:Value() and Ready(_R) and lastActivated == SpellQ and SpellCalc("RQ", enemy)) or 0)
			local RWdmg = ((Menu.ks.killstealR:Value() and Ready(_R) and not wrUsed() and lastActivated == SpellW and SpellCalc("RW", enemy)) or 0)
			
			if Qdmg > enemy.health then
				Control.CastSpell(HK_Q, enemy)
			elseif Wdmg > enemy.health then
				WstartPos = myHero.pos
				Control.CastSpell(HK_W, enemy)
			elseif Edmg > enemy.health then
				CastE(enemy)
			elseif RQdmg > enemy.health then
				CastR("Q", enemy)
			elseif RWdmg > enemy.health then
				CastR("W", enemy)
			end 
		end
	end
end

function CastE(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, EData, myHero)
		if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
			Control.CastSpell(HK_E, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
			Control.CastSpell(HK_E, pred.CastPos)
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 55, Range = 925, Speed = 1750, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end	
	end
end

function CastR(skill, target)
	if skill == "Q" and lastActivated == SpellQ then
		if myHero.pos:DistanceTo(target.pos) < 700 then
			Control.CastSpell(HK_R, target)
		end
	elseif skill == "W" and lastActivated == SpellW then
		if not wrUsed() and myHero.pos:DistanceTo(target.pos) < 600 then
			WRstartPos = myHero.pos
			Control.SetCursorPos(target.pos)
			Control.KeyDown(HK_R)
		end
	end
end

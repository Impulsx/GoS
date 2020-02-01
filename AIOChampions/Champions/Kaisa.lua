function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
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
	local count = 1
	for i = 1,Game.MinionCount() do
	local hero = Game.Minion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end	

function GetEnemyCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

function CastSpellMM(spell,pos,range,delay)
	local range = range or math.huge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x-5,castPosMM.y-5)
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
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})		
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "Range", name = "Max Range for use [W]", value = 1400, min = 0, max = 3000, identifier = "Range"})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})				

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "Count", name = "Min Minions", value = 3, min = 1, max = 7, step = 1, identifier = "Minion/s"})
	Menu.Clear:MenuElement({id = "UseW", name = "LastHit[W]Cannon [if out of AA range]", value = true})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--LastHit
	Menu:MenuElement({type = MENU, id = "last", name = "Lasthit"})
	Menu.last:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.last:MenuElement({id = "UseW", name = "LastHit[W]Cannon [if out of range]", value = true})	
	Menu.last:MenuElement({id = "Mana", name = "Min Mana to LastHit", value = 40, min = 0, max = 100, identifier = "%"}) 
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.ks:MenuElement({id = "Range", name = "Max Range for use [W]", value = 3000, min = 0, max = 3000, identifier = "Range"})	
	Menu.ks:MenuElement({id = "UseR", name = "[R] if out of range", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})

	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 100, Range = 3000, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL} 
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
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 1000 + 500 * myHero:GetSpellData(_R).level, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 3000, 1, Draw.Color(225, 225, 125, 10))
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
		Combo()		
	elseif Mode == "Harass" then
		Harass()	
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "LastHit" then
		Lasthit()
	end	
	KillSteal()
		
	if HasBuff(myHero, "KaisaE") then
		_G.SDK.Orbwalker:SetAttack(false)
	else
		_G.SDK.Orbwalker:SetAttack(true)
	end	
end

function CheckQ()
	if HasBuff(myHero, "KaisaQEvolved") then 
		return 9 		
	else 
		return 5 
	end 
end

function GetWDmg(unit)
	local Wdmg = getdmg("W", unit, myHero, 1)
	local W2dmg = getdmg("W", unit, myHero, 2)	
	local buff = GetBuffData(unit, "kaisapassivemarker")
	if HasBuff(unit, "kaisapassivemarker") and buff.count == 4 then
		return (Wdmg+W2dmg)		
	else		
		return Wdmg 
	end 
end

function GetQDmg(unit)
	local count = GetEnemyCount(600, unit)
	local QDmg = getdmg("Q", unit, myHero)
	local QDmg2 = (CheckQ() * (getdmg("Q", unit, myHero)/100*25))
	if count >= 2 then 
		return QDmg+(QDmg2/count)
	else
		return QDmg+QDmg2
	end
end	
         
function KillSteal()	
	for i, target in ipairs(GetEnemyHeroes()) do	
	
		if Ready(_R) and Menu.ks.UseR:Value() then		
			local CanUseQ = myHero:GetSpellData(HK_Q).currentCd == 0 and myHero:GetSpellData(HK_Q).level > 0 and myHero:GetSpellData(HK_Q).mana <= myHero.mana
			if myHero.pos:DistanceTo(target.pos) > 800 and myHero.pos:DistanceTo(target.pos) < 1000 + 500 * myHero:GetSpellData(_R).level and HasBuff(target, "kaisapassivemarkerr") and Menu.ks.UseQ:Value() and CanUseQ and IsValid(target) then
				local QDmg = GetQDmg(target)
				if QDmg >= target.health then
				local castPos = myHero.pos:Extended(target.pos, 500)
					if target.pos:To2D().onScreen == true then
						Control.CastSpell(HK_R, castPos)

					else 
						CastSpellMM(HK_R, target.pos, 1000 + 500 * myHero:GetSpellData(_R).level)
					end	
				end
			end			
		end		

		if myHero.pos:DistanceTo(target.pos) < 600 and IsValid(target) and Menu.ks.UseQ:Value() and Ready(_Q) then
			local QDmg = GetQDmg(target) 
			if QDmg >= target.health then
				Control.CastSpell(HK_Q)	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) < Menu.ks.Range:Value() and IsValid(target) and Menu.ks.UseW:Value() and Ready(_W) then
			local WDmg = GetWDmg(target)
			if WDmg >= target.health then					
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then  
					Control.CastSpell(HK_W, pred.CastPosition)
				end	
			end
		end					
	end	
end	

function Combo()
local target = GetTarget(3000)
if target == nil then return end
	if IsValid(target) then
			
		if myHero.pos:DistanceTo(target.pos) > 525 and myHero.pos:DistanceTo(target.pos) < 800 and Menu.Combo.UseE:Value() and Ready(_E) then			
			Control.CastSpell(HK_E)
		end			

		if myHero.pos:DistanceTo(target.pos) < 600 and Menu.Combo.UseQ:Value() and Ready(_Q) then			
			Control.CastSpell(HK_Q)
		end
		
		if myHero.pos:DistanceTo(target.pos) <= Menu.Combo.Range:Value() and Menu.Combo.UseW:Value() and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value() + 1 then
				Control.CastSpell(HK_W, pred.CastPosition)
			end	
		end				
	end
end	

function Harass()
local target = GetTarget(600)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 600 and Menu.Harass.UseQ:Value() and Ready(_Q) then			
			Control.CastSpell(HK_Q)
		end
	end
end	

function Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and Menu.Clear.UseQ:Value() and GetMinionCount(400, minion) >= Menu.Clear.Count:Value() then
				Control.CastSpell(HK_Q)
			end	 
		end
		
		if myHero.pos:DistanceTo(minion.pos) > 550 and myHero.pos:DistanceTo(minion.pos) <= 3000 and minion.team == TEAM_ENEMY and minion.charName == "SRU_ChaosMinionSiege" and IsValid(minion) and Ready(_W) and Menu.Clear.UseW:Value() then
			local WDmg = getdmg("W", minion, myHero)
			if WDmg >= minion.health then
				Control.CastSpell(HK_W, minion.pos)
			end
		end		
	end
end

function JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
			
			if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_JUNGLE and IsValid(minion) and Ready(_Q) and Menu.JClear.UseQ:Value() then	
				Control.CastSpell(HK_Q)  
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 3000 and minion.team == TEAM_JUNGLE and IsValid(minion) and Ready(_W) and Menu.JClear.UseW:Value() then
				Control.CastSpell(HK_W, minion.pos)
			end		
		end
	end	
end

function Lasthit()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
	 if myHero.mana/myHero.maxMana >= Menu.last.Mana:Value() / 100 then
			
			if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then					
				local QDmg = (getdmg("Q", minion, myHero)*2)
				if Ready(_Q) and Menu.last.UseQ:Value() and minion.health/minion.maxHealth < 0.35 and QDmg > minion.health then
					Control.CastSpell(HK_Q)
				end	 
			end
			
			if myHero.pos:DistanceTo(minion.pos) > 550 and myHero.pos:DistanceTo(minion.pos) <= 3000 and minion.team == TEAM_ENEMY and minion.charName == "SRU_ChaosMinionSiege" and IsValid(minion) and Ready(_W) and Menu.last.UseW:Value() then
				local WDmg = getdmg("W", minion, myHero)
				if WDmg > minion.health then
					Control.CastSpell(HK_W, minion.pos)
				end
			end
		end
	end
end

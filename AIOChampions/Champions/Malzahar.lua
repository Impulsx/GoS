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

function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
			return true
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

function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})	

	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "Auto[Q]Immobile"})
	Menu.AutoQ:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})	
	
	Menu:MenuElement({type = MENU, id = "UseQE", name = "[Q]Waiting for [E]Debuff   [Settings]"})
	Menu.UseQE:MenuElement({id = "UseQC", name = "Use in Combo", value = true})
	Menu.UseQE:MenuElement({id = "UseQH", name = "Use in Harass", value = true})
	Menu.UseQE:MenuElement({id = "UseQL", name = "Use in LaneClear", value = true})
	Menu.UseQE:MenuElement({id = "UseQJ", name = "Use in JungleClear", value = true})
	Menu.UseQE:MenuElement({id = "Buff", name = "[E]Debuff ExpireTime [0 Sec = Debuff End]    ", value = 1, min = 0.0, max = 4, step = 0.1, identifier = "sec"})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})			
	Menu.Combo:MenuElement({id = "UseR", name = "[R] Nether Grasp", value = false})	
	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})		
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 2, min = 1, max = 6})  	
	Menu.Clear:MenuElement({id = "hp", name = "Use[E] if MinionHP less then", value = 50, min = 1, max = 100, identifier = "%"})	
	Menu.Clear:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})	
	Menu.ks:MenuElement({id = "UseW", name = "[W] Malefic Visions", value = true})			
	Menu.ks:MenuElement({id = "UseR", name = "[R] Void Swarm", value = true})
	Menu.ks:MenuElement({id = "full", name = "Full Combo", value = true})

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 85, Range = 900, Speed = 3200, Collision = false
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
		Draw.Circle(myHero, 700, 1, Draw.Color(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 850, 1, Draw.Color(225, 225, 125, 10))
		end
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end	
	end)		
end

function IsRCharging()
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "MalzaharR" then
		return true
	end
	return false	
end

function Tick()
ActiveUlt()	
if MyHeroNotReady() or IsRCharging() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()

	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	elseif Mode == "Flee" then
	
	end	

	KillSteal()
	AutoQ()
end

function AutoQ()
local target = GetTarget(1000)     	
if target == nil then return end	
local pred = GetGamsteronPrediction(target, QData, myHero)	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 900 and IsImmobileTarget(target) and Menu.AutoQ.UseQ:Value() and Ready(_Q) then
		if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end	
	end
end

function ActiveUlt()
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "MalzaharR" then	
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)	
	else
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end
end
       
function KillSteal()	
local target = GetTarget(1000)     	
if target == nil then return end
 
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 900 then
		local ready = Ready(_Q) and Ready(_E) and Ready(_W) and Ready(_R)
		local hp = target.health
		local QDmg = getdmg("Q", target, myHero)
		local EDmg = getdmg("E", target, myHero)
		local WDmg = getdmg("W", target, myHero)
		local RDmg = (getdmg("R", target, myHero, 1) + getdmg("R", target, myHero, 2))	
		local fullDmg = (QDmg + EDmg + WDmg + RDmg)
	
		
		if myHero.pos:DistanceTo(target.pos) <= 900 and QDmg >= hp and Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 650 and EDmg >= hp then	
			if Menu.ks.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E, target)
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 650 and WDmg >= hp then	
			if Menu.ks.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, target.pos)
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 700 and RDmg >= hp then	
			if Menu.ks.UseR:Value() and Ready(_R) then
				Control.CastSpell(HK_R, target)	
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 700 and fullDmg >= hp then	
			if Menu.ks.full:Value() and ready then
				KsFull(target)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 700 and RDmg >= hp and Menu.ks.full:Value() and Ready(_R) then
			Control.CastSpell(HK_R, target)
		end
	end
end	

function KsFull(target)
local pred = GetGamsteronPrediction(target, QData, myHero)
	
	if myHero.pos:DistanceTo(target.pos) <= 650 then
		Control.CastSpell(HK_E, target)
	end	
	if myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then 
		Control.CastSpell(HK_Q, pred.CastPosition)
	end	
	if myHero.pos:DistanceTo(target.pos) <= 650 then
		Control.CastSpell(HK_W, target.pos)
	end	
end

function Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
	local pred = GetGamsteronPrediction(target, QData, myHero)
		if myHero.pos:DistanceTo(target.pos) <= 650 then 	
			if Menu.Combo.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, target.pos) 
			end
		end

		if Menu.UseQE.UseQC:Value() then
			
			if myHero:GetSpellData(_E).level == 0 then
				if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Combo.UseQ:Value() and Ready(_Q) then
					if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end	
				end
			else
				local BuffStart = GetBuffData(target, "MalzaharE")
				if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Combo.UseQ:Value() and Ready(_Q) and HasBuff(target, "MalzaharE") and BuffStart.duration <= (Menu.UseQE.Buff:Value()+0.25) then
					if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end	
				end				
			end
		else
			if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Combo.UseQ:Value() and Ready(_Q) then
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end			
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 650 then	
			if Menu.Combo.UseE:Value() and Ready(_E) then			
				Control.CastSpell(HK_E, target)
	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 700 then	
			if Ready(_R) and Menu.Combo.UseR:Value() then
				Control.CastSpell(HK_R, target)
			end
		end
	end
	if IsRCharging() then	
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)
	else
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end	
end	

function Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
	local pred = GetGamsteronPrediction(target, QData, myHero)	
		if Menu.UseQE.UseQH:Value() then
			
			if myHero:GetSpellData(_E).level == 0 then
				if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Harass.UseQ:Value() and Ready(_Q) then
					if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end	
				end
			else
				local BuffStart = GetBuffData(target, "MalzaharE")
				if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Harass.UseQ:Value() and Ready(_Q) and HasBuff(target, "MalzaharE") and BuffStart.duration <= (Menu.UseQE.Buff:Value()+0.25) then
					if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end	
				end				
			end
		else
			if myHero.pos:DistanceTo(target.pos) <= 900 and Menu.Harass.UseQ:Value() and Ready(_Q) then
				if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end			
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 650 then	
			if Menu.Harass.UseE:Value() and Ready(_E) then			
				Control.CastSpell(HK_E, target)
	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 650 then	
			if Menu.Harass.UseW:Value() and Ready(_W) then			
				Control.CastSpell(HK_W, target.pos)
	
			end
		end
	end
end	

function Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100   
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) and mana_ok then
            
			if Menu.UseQE.UseQL:Value() then	
				if myHero:GetSpellData(_E).level == 0 then
					if myHero.pos:DistanceTo(minion.pos) <= 900 and Menu.Clear.UseQ:Value() and Ready(_Q) then
						Control.CastSpell(HK_Q, minion.pos)
					end
				else
					local BuffStart = GetBuffData(minion, "MalzaharE")
					if myHero.pos:DistanceTo(minion.pos) <= 900 and Menu.Clear.UseQ:Value() and Ready(_Q) and HasBuff(minion, "MalzaharE") and BuffStart.duration <= (Menu.UseQE.Buff:Value()+0.25) then
						Control.CastSpell(HK_Q, minion.pos)
					end				
				end
			else
				if myHero.pos:DistanceTo(minion.pos) <= 900 and Menu.Clear.UseQ:Value() and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)	
				end			
			end
            
			if Menu.Clear.UseW:Value() and myHero.pos:DistanceTo(minion.pos) <= 650 and Ready(_W) then
                Control.CastSpell(HK_W, minion.pos)
            end
            
			if Menu.Clear.UseE:Value() and myHero.pos:DistanceTo(minion.pos) <= 650 and Ready(_E) then
			local count = GetMinionCount(650, minion)
				if minion.health/minion.maxHealth <= Menu.Clear.hp:Value()/100 and count >= Menu.Clear.UseEM:Value() then	
					Control.CastSpell(HK_E, minion)
				end	
            end
        end
    end
end

function JungleClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100        
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_JUNGLE and IsValid(minion) and mana_ok then

			if Menu.UseQE.UseQJ:Value() then	
				if myHero:GetSpellData(_E).level == 0 then
					if myHero.pos:DistanceTo(minion.pos) <= 900 and Menu.JClear.UseQ:Value() and Ready(_Q) then
						Control.CastSpell(HK_Q, minion.pos)
					end
				else
					local BuffStart = GetBuffData(minion, "MalzaharE")
					if myHero.pos:DistanceTo(minion.pos) <= 900 and Menu.JClear.UseQ:Value() and Ready(_Q) and HasBuff(minion, "MalzaharE") and BuffStart.duration <= (Menu.UseQE.Buff:Value()+0.25) then
						Control.CastSpell(HK_Q, minion.pos)
					end				
				end
			else
				if myHero.pos:DistanceTo(minion.pos) <= 900 and Menu.JClear.UseQ:Value() and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)	
				end			
			end
            
			if Menu.JClear.UseW:Value() and myHero.pos:DistanceTo(minion.pos) <= 650 and Ready(_W) then
                Control.CastSpell(HK_W, minion.pos)
            end
            
			if Menu.JClear.UseE:Value() and myHero.pos:DistanceTo(minion.pos) <= 650 and Ready(_E) then
                Control.CastSpell(HK_E, minion)
            end
        end
    end
end

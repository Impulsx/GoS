local function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff.count
    end
  end
  return 0
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 ) and buff.count > 0 then
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

local function IsUltPosUnderTurret(Pos)
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        local range = (turret.boundingRadius + 750 + myHero.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(Pos) < range then
                return true
            end
        end
    end
    return false
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

function LoadScript() 	 
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.11"}})
	
	--ComboMenu
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "Qmin", name = "[Q] If Hit X Minion ", value = 2, min = 1, max = 6, step = 1, identifier = "Minion/s"})
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})
		
	--AutoSpell on CC
	Menu:MenuElement({type = MENU, id = "CC", name = "AutoSpells on CC"})
	Menu.CC:MenuElement({id = "UseQ", name = "Q", value = true})
	Menu.CC:MenuElement({id = "UseE", name = "E", value = true})
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	
	--Drawing
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw[Q]", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw[W]", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw[E]", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw[R]", value = false})		
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 90, Range = 880, Speed = 1100, Collision = false
	}
	
	QspellData = {speed = 1100, range = 880, delay = 0.25, radius = 90, collision = {nil}, type = "linear"}		

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 975, Speed = 1600, Collision = true, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	EspellData = {speed = 1600, range = 975, delay = 0.25, radius = 60, collision = {"minion"}, type = "linear"}		

  	                                          
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 880, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 700, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 975, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 450, 1, DrawColor(225, 225, 0, 10))
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
	end	
	CC()
end

function Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then    
	local Rcast = false	
	local Ecast = false		
		if Ready(_R) then	
			local buff = GotBuff(myHero, "AhriTumble")
			if myHero.pos:DistanceTo(target.pos) < 1000 and Menu.Combo.UseR:Value() and Ready(_R) and buff == 0 then
				if myHero.pos:DistanceTo(target.pos) < 550 then
					local castPos = target.pos:Extended(mousePos, 550)
					if not IsUltPosUnderTurret(castPos) then
						Rcast = Control.CastSpell(HK_R, castPos)
					end	
				else 
					if not IsUnderTurret(target) then
						Rcast = Control.CastSpell(HK_R, target.pos)	
					end	
				end	
			end	
			
			if not Ecast and myHero.pos:DistanceTo(target.pos) < 1000 and Menu.Combo.UseR:Value() and Ready(_R) and buff == 2 then
				if myHero.pos:DistanceTo(target.pos) < 550 then
					local castPos = target.pos:Extended(mousePos, 550)
					if not IsUltPosUnderTurret(castPos) then
						Rcast = Control.CastSpell(HK_R, castPos)
					end	
				else 
					if not IsUnderTurret(target) then
						Rcast = Control.CastSpell(HK_R, target.pos)	
					end	
				end	
			end

			if not Ecast and myHero.pos:DistanceTo(target.pos) < 1000 and Menu.Combo.UseR:Value() and Ready(_R) and buff == 1 then
				if myHero.pos:DistanceTo(target.pos) < 550 then
					local castPos = Vector(target) - (Vector(myHero) - Vector(target)):Perpendicular():Normalized() * 350
					if not IsUltPosUnderTurret(castPos) then
						Rcast = Control.CastSpell(HK_R, castPos)
					end
				else 
					if not IsUnderTurret(target) then
						Rcast = Control.CastSpell(HK_R, target.pos)	
					end	
				end					
			end			
			
			if myHero.pos:DistanceTo(target.pos) <= 975 and Menu.Combo.UseE:Value() and Ready(_E) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						Control.CastSpell(HK_E, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						Control.CastSpell(HK_E, pred.CastPos)
					end
				else
					local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 975, Speed = 1600, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
					EPrediction:GetPrediction(target, myHero)
					if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
						Control.CastSpell(HK_E, EPrediction.CastPosition)
					end				
				end
			end			
			
			if Ecast and myHero.pos:DistanceTo(target.pos) <= 880 and Menu.Combo.UseQ:Value() and Ready(_Q) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 90, Range = 880, Speed = 1100, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end
			end

			if myHero.pos:DistanceTo(target.pos) <= 700 and Menu.Combo.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W)
			end
		
		else
		
			if myHero.pos:DistanceTo(target.pos) <= 975 and Menu.Combo.UseE:Value() and Ready(_E) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						Control.CastSpell(HK_E, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						Control.CastSpell(HK_E, pred.CastPos)
					end
				else
					local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 975, Speed = 1600, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
					EPrediction:GetPrediction(target, myHero)
					if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
						Control.CastSpell(HK_E, EPrediction.CastPosition)
					end				
				end
			end			
			
			if myHero.pos:DistanceTo(target.pos) <= 880 and Menu.Combo.UseQ:Value() and Ready(_Q) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 90, Range = 880, Speed = 1100, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end
			end

			if myHero.pos:DistanceTo(target.pos) <= 700 and Menu.Combo.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W)
			end		
		end	
	end
end

function Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value()/100 then
		if myHero.pos:DistanceTo(target.pos) <= 975 and Menu.Harass.UseE:Value() and Ready(_E) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					Control.CastSpell(HK_E, pred.CastPos)
				end
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 975, Speed = 1600, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end				
			end
		end		
		
		if myHero.pos:DistanceTo(target.pos) <= 880 then	
			if Menu.Harass.UseQ:Value() and Ready(_Q) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 90, Range = 880, Speed = 1100, Collision = false})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 700 then	
			if Menu.Harass.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W)
			end
		end
	end
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
			
			if myHero.pos:DistanceTo(minion.pos) <= 880 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				local count = GetMinionCount(150, minion)
				if count >= Menu.Clear.Qmin:Value() then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 700 and Menu.Clear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W)
			end			
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
			
			if myHero.pos:DistanceTo(minion.pos) <= 880 and Menu.JClear.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
			end
			
			if myHero.pos:DistanceTo(minion.pos) <= 700 and Menu.JClear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W)
			end			
		end
	end
end

function CC()
local target = GetTarget(1000)
if target == nil then return end
local Immobile = IsImmobileTarget(target)	
	if Immobile and IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 975 and Menu.CC.UseE:Value() and Ready(_E) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
					Control.CastSpell(HK_E, pred.CastPos)
				end
			else
				local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 975, Speed = 1600, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				EPrediction:GetPrediction(target, myHero)
				if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end				
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 880 and Menu.CC.UseQ:Value() and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 90, Range = 880, Speed = 1100, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end
		end	
	end
end

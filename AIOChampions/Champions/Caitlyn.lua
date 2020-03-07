local function GetEnemyHeroes()
	return Enemies
end

local function CheckTrap(unit, range)
	for i = 0, GameObjectCount() do
	local object = GameObject(i)
		if object and GetDistance(object.pos, unit.pos) < range and (object.name == "Caitlyn_Base_W_Indicator_SizeRing") then
		return true
		end
	end
	return false
end

local function EnemyInRange(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range and IsValid(target) then 
			count = count + 1
		end
	end
	return count
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

local function CastSpellMM(spell,pos,range,delay)
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
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
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
	Menu:MenuElement({name = " ", drop = {"Version 0.10"}})	

	--AutoW  
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})		
	Menu.AutoW:MenuElement({id = "UseW", name = "AutoW on Immobile Target", value = true})	
	
	--AutoE  
	Menu:MenuElement({type = MENU, id = "AntiGap", name = "Antigapclose"})
	Menu.AntiGap:MenuElement({id = "UseE", name = "Use[E] Antigapclose", value = true})	
	
	--AutoQ 
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ"})		
	Menu.AutoQ:MenuElement({id = "UseQ", name = "AutoQ on Traped Target", value = true})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})				

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "Count", name = "Min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})
	Menu.ks:MenuElement({id = "Turret", name = "Dont Use Ult under Enemy Tower", value = true})	
	Menu.ks:MenuElement({id = "Rrange", name = "Cast R if range greater than -->", value = 1200, min = 0, max = 3500})
	Menu.ks:MenuElement({id = "enemy", name = "Cast R if no Enemy in range -->", value = 1200, min = 0, max = 3500})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawKill", name = "Draw Ult Kill on Minimap", value = true})

	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.3, Radius = 60, Range = 1250, Speed = 2200, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}
	}
	
	QspellData = {speed = 2200, range = 1250, delay = 0.3, radius = 60, collision = {}, type = "linear"}	

	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 70, Range = 800, Speed = 1450, Collision = false
	}
	
	WspellData = {speed = 1450, range = 800, delay = 0.5, radius = 70, collision = {}, type = "circular"}	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 750, Speed = 1600, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
	}
	
	EspellData = {speed = 1600, range = 750, delay = 0.25, radius = 70, collision = {"minion"}, type = "linear"}	
  	                                           
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
		DrawCircle(myHero, 3500, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1300, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 750, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 800, 1, DrawColor(225, 225, 125, 10))
		end
		
		for i, target in ipairs(GetEnemyHeroes()) do	
			if Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 6000 and IsValid(target) and Menu.Drawing.DrawKill:Value() then	
				local hp = target.health
				local RDmg = getdmg("R", target, myHero)
				if RDmg >= hp then
					DrawText("ULT KILL", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))
				end
			end	
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
	if Mode ~= "Combo" then
		AutoW()
		AutoQ()
	end	
	KillSteal()
	AutoE()
	local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid then
		_G.SDK.Orbwalker:SetAttack(false)
	else	
		_G.SDK.Orbwalker:SetAttack(true)
	end	
	
end

function AutoW()
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) <= 800 and IsValid(target) and IsImmobileTarget(target) and not HasBuff(target, "caitlynyordletrapsight") and Menu.AutoW.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
			if CheckTrap(target, 200) then return end			
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
					ControlCastSpell(HK_W, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
					ControlCastSpell(HK_W, pred.CastPos)
				end	
			end
		end
	end
end	

function AutoQ()
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) <= 1300 and IsValid(target) and HasBuff(target, "caitlynyordletrapinternal") and Menu.AutoQ.UseQ:Value() and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					ControlCastSpell(HK_Q, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					ControlCastSpell(HK_Q, pred.CastPos)
				end	
			end
		end		
	end
end

function AutoE()
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) <= 1500 and IsValid(target) and Menu.AntiGap.UseE:Value() and Ready(_E) then
			if target.pathing.isDashing and target.pathing.dashSpeed > 500 and GetDistance(target.pos, myHero.pos) > GetDistance(Vector(target.pathing.endPos), myHero.pos) then
				ControlCastSpell(HK_E, target.pos)
			end	
		end
	end
end
        
function KillSteal()	
	for i, target in ipairs(GetEnemyHeroes()) do	
		if myHero.pos:DistanceTo(target.pos) <= 3500 and IsValid(target) then		
			if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.ks.UseQ:Value() and Ready(_Q) then
				local QDmg = getdmg("Q", target, myHero) 
				if QDmg >= target.health then 
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							ControlCastSpell(HK_Q, pred.CastPosition)
						end
					else
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							ControlCastSpell(HK_Q, pred.CastPos)
						end	
					end
				end
			end
			
			if myHero.pos:DistanceTo(target.pos) >= Menu.ks.Rrange:Value() and Menu.ks.UseR:Value() and Ready(_R) then
				local count = EnemyInRange(Menu.ks.enemy:Value())
				local RDmg = getdmg("R", target, myHero) 
				if RDmg >= target.health and count == 0 then			
					if Menu.ks.Turret:Value() then	
						if not IsUnderTurret(myHero) then	
							if target.pos:To2D().onScreen then 		
								ControlCastSpell(HK_R, target) 
							
							elseif not target.pos:To2D().onScreen then	   
								CastSpellMM(HK_R, target.pos, 3500)
							end
						end	
						
					else
	
						if target.pos:To2D().onScreen then 		
							ControlCastSpell(HK_R, target) 
						
						elseif not target.pos:To2D().onScreen then	   
							CastSpellMM(HK_R, target.pos, 3500)
						end					
					end	
				end
			end
		end
	end	
end	

function Combo()
local target = GetTarget(1400)
if target == nil then return end
	if IsValid(target) then

		if myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_E).level > 0 then
			
			if myHero.pos:DistanceTo(target.pos) <= 800 and not HasBuff(target, "caitlynyordletrapsight") and Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
				if CheckTrap(target, 200) then return end
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						ControlCastSpell(HK_W, pred.CastPosition)
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						ControlCastSpell(HK_W, pred.CastPos)
					end	
				end
			end			
			
			if myHero.pos:DistanceTo(target.pos) <= 750 and Menu.Combo.UseE:Value() and Ready(_E) then
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
			
			if HasBuff(myHero, "caitlynheadshotrangcheck") then return end			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "caitlynyordletrapinternal") and Menu.Combo.UseQ:Value() and Ready(_Q) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						ControlCastSpell(HK_Q, pred.CastPosition)
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						ControlCastSpell(HK_Q, pred.CastPos)
					end	
				end
			end

		else
			if myHero.pos:DistanceTo(target.pos) <= 800 and not HasBuff(target, "caitlynyordletrapsight") and Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
				if CheckTrap(target, 200) then return end				
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						ControlCastSpell(HK_W, pred.CastPosition)
					end
				else
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						ControlCastSpell(HK_W, pred.CastPos)
					end	
				end	
			end			
			
			if myHero:GetSpellData(_W).level > 0 then
				if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "caitlynyordletrapinternal") and Menu.Combo.UseQ:Value() and Ready(_Q) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							ControlCastSpell(HK_Q, pred.CastPosition)
						end
					else
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							ControlCastSpell(HK_Q, pred.CastPos)
						end	
					end
				end
			else
				if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.Combo.UseQ:Value() and Ready(_Q) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							ControlCastSpell(HK_Q, pred.CastPosition)
						end
					else
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							ControlCastSpell(HK_Q, pred.CastPos)
						end	
					end
				end
			end	

			if myHero.pos:DistanceTo(target.pos) <= 750 and Menu.Combo.UseE:Value() and Ready(_E) then
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
		end	
	end
end	

function Harass()
local target = GetTarget(1300)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					ControlCastSpell(HK_Q, pred.CastPosition)
				end
			else
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					ControlCastSpell(HK_Q, pred.CastPos)
				end	
			end
		end
	end
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and Menu.Clear.UseQ:Value() and GetMinionCount(180, minion) >= Menu.Clear.Count:Value() then
				ControlCastSpell(HK_Q, minion.pos)
			end	 
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)	

		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				ControlCastSpell(HK_Q, minion.pos)
			end  
		end
	end
end

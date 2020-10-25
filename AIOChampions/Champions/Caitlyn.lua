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

local SafedTraps = {}
local TrapCount = 0

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.18"}})	

	--AutoW  
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})		
	Menu.AutoW:MenuElement({id = "UseW", name = "AutoW on Immobile Target", value = true})	
	
	--AutoE  
	Menu:MenuElement({type = MENU, id = "AntiGap", name = "Antigapclose"})
	Menu.AntiGap:MenuElement({id = "UseE", name = "Use[E] Antigapclose", value = true})
	DelayAction(function()		
		for i, unit in ipairs(GetEnemyHeroes()) do
			Menu.AntiGap:MenuElement({id = unit.networkID, name = "Use on " ..unit.charName, value = true})
		end
	end,0.3)	
	
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
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] MaxRange", value = false})
	Menu.Drawing:MenuElement({id = "DrawR2", name = "Draw [R] MinRange", value = false})	
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawKill", name = "Draw Ult Kill on Minimap", value = true})
	
	Menu:MenuElement({type = MENU, id = "Check", name = "Check Traps"})
	Menu.Check:MenuElement({id = "Enable", name = "Check Objects for Trap Pos", value = true})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.625, Radius = 90, Range = 1250, Speed = 2200, Collision = false
	}
	
	QspellData = {speed = 2200, range = 1250, delay = 0.625, radius = 90, collision = {nil}, type = "linear"}	

	WData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.35, Radius = 75, Range = 800, Speed = MathHuge, Collision = false
	}
	
	WspellData = {speed = MathHuge, range = 800, delay = 0.35, radius = 75, collision = {nil}, type = "circular"}	

	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.15, Radius = 75, Range = 750, Speed = 1600, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	EspellData = {speed = 1600, range = 750, delay = 0.15, radius = 70, collision = {"minion"}, type = "linear"}	

	Callback.Add("Tick", function() Tick() end)
	
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	end	
	
	Callback.Add("Draw", function()
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 3500, 1, DrawColor(255, 225, 255, 10))
		end 
		if Menu.Drawing.DrawR2:Value() and Ready(_R) then
		DrawCircle(myHero, Menu.ks.Rrange:Value(), 1, DrawColor(255, 225, 255, 10))
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

local BlockAA = false

function Tick()
	if BlockAA then
		DelayAction(function()
			BlockAA = false
		end,0.3)		
	end
	
	if Menu.Check.Enable:Value() then
		ScanTrap()
		RemoveTrap()
	end	
	
	
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
	
	if Menu.AntiGap.UseE:Value() then 
		AutoE()
	end	
	
	KillSteal()	
end

function StopAutoAttack(args)
	if BlockAA then
		args.Process = false 
	else
		args.Process = true
	end
end

function ScanTrap()
local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid and currSpell.name == "CaitlynYordleTrap" then
		DelayAction(function()
			for i = 0, GameObjectCount() do
				local Trap = GameObject(i)
				local NewTrap = true
				if Trap and myHero.pos:DistanceTo(Trap.pos) < 1000 and Trap.name == "Caitlyn_Base_W_Indicator_SizeRing" then
					for i = 1, #SafedTraps do
						if SafedTraps[i].networkID == Trap.networkID then
							NewTrap = false
						end
					end				
					
					if NewTrap then 
						if Trap.name == "Caitlyn_Base_W_Indicator_SizeRing" then
							--print("FoundNewTrap")
							TableInsert(SafedTraps, 1, {obj = Trap, networkID = Trap.networkID})
							TrapCount = TrapCount + 1
						end	
					end	
				end
			end
		end,0.3)	
	end	
end

function RemoveTrap()
	local LastScan = 0
	if TrapCount > 0 and GameTimer() - LastScan > 1 then
		for i = 1, #SafedTraps do
			if SafedTraps[i] then
				local Trap = SafedTraps[i] 
				local object = Trap.obj
				if object and (object.health <= 0 or object.name ~= "Caitlyn_Base_W_Indicator_SizeRing") then
					LastScan = GameTimer()
					TrapCount = TrapCount - 1				
					TableRemove(SafedTraps, i)
					--print("Removed")
					--print(TrapCount)
				end
			end	
		end
	end
end

function AutoW()
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) <= 800 and IsValid(target) and IsImmobileTarget(target) and not HasBuff(target, "caitlynyordletrapsight") and Menu.AutoW.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
			if TrapCount > 0 then
				for i = 1, #SafedTraps do
					local Object = SafedTraps[i]
					local Trap = Object.obj
					if Trap and Trap.pos:DistanceTo(target.pos) > 200 then 			
						if Menu.Pred.Change:Value() == 1 then
							local pred = GetGamsteronPrediction(target, WData, myHero)
							if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
								BlockAA = true
								Control.CastSpell(HK_W, pred.CastPosition)
							end
						elseif Menu.Pred.Change:Value() == 2 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
							if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
								BlockAA = true
								Control.CastSpell(HK_W, pred.CastPos)
							end
						else
							CastGGPred(_W, target)
						end
					end
				end
			else
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, WData, myHero)
					if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
						BlockAA = true
						Control.CastSpell(HK_W, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
						BlockAA = true
						Control.CastSpell(HK_W, pred.CastPos)
					end
				else
					CastGGPred(_W, target)
				end		
			end	
		end
	end
end	

function AutoQ()
	for i, target in ipairs(GetEnemyHeroes()) do
		if Menu.AutoQ.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1000 and IsValid(target) and HasBuff(target, "caitlynyordletrapinternal") then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					BlockAA = true
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					BlockAA = true
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				CastGGPred(_Q, target)
			end
		end		
	end
end

function AutoE()
	for i, target in ipairs(GetEnemyHeroes()) do
		if Menu.AntiGap[target.networkID] and Menu.AntiGap[target.networkID]:Value() and myHero.pos:DistanceTo(target.pos) < 1000 then
            if target and Ready(_E) and target.pathing.isDashing and target.pathing.dashSpeed > 0 and myHero.pos:DistanceTo(target.pos) < 600 and not IsImmobileTarget(target) then	
				Control.CastSpell(HK_E, target.pos)
			end
		end 
	end
end
        
function KillSteal()	
	for i, target in ipairs(GetEnemyHeroes()) do		
		if Menu.ks.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1200 and IsValid(target) then
			local QDmg = getdmg("Q", target, myHero) 
			if QDmg >= target.health then 
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						BlockAA = true
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						BlockAA = true
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					CastGGPred(_Q, target)
				end
			end
		end
		
		if Menu.ks.UseR:Value() and Ready(_R) and myHero.pos:DistanceTo(target.pos) <= 3500 and myHero.pos:DistanceTo(target.pos) >= Menu.ks.Rrange:Value() then
			local count = EnemyInRange(Menu.ks.enemy:Value())
			local RDmg = getdmg("R", target, myHero) 
			if RDmg >= target.health and count == 0 and IsValid(target) then			
				SetMovement(false)
				if Menu.ks.Turret:Value() then	
					if not IsUnderTurret(myHero) then	
						if target.pos2D.onScreen then 		
							Control.CastSpell(HK_R, target) 							
						else	   
							CastSpellMM(HK_R, target.pos, 3500)
						end
					end	
					
				else

					if target.pos2D.onScreen then 		
						Control.CastSpell(HK_R, target) 						
					else	   
						CastSpellMM(HK_R, target.pos, 3500)
					end					
				end	
			end
		end
		SetMovement(true)
	end	
end	

function Combo()
local target = GetTarget(1400)
if target == nil then return end
	if IsValid(target) then

		if myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_E).level > 0 then
			
			if myHero.pos:DistanceTo(target.pos) <= 800 and not HasBuff(target, "caitlynyordletrapsight") and Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
				if TrapCount > 0 then
					for i = 1, #SafedTraps do
						local Object = SafedTraps[i]
						local Trap = Object.obj
						if Trap and Trap.pos:DistanceTo(target.pos) > 200 then 
							if Menu.Pred.Change:Value() == 1 then
								local pred = GetGamsteronPrediction(target, WData, myHero)
								if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
									BlockAA = true
									Control.CastSpell(HK_W, pred.CastPosition)
								end
							elseif Menu.Pred.Change:Value() == 2 then
								local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
								if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
									BlockAA = true
									Control.CastSpell(HK_W, pred.CastPos)
								end
							else
								CastGGPred(_W, target)
							end
						end
					end	
				else
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, WData, myHero)
						if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
							BlockAA = true
							Control.CastSpell(HK_W, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
							BlockAA = true
							Control.CastSpell(HK_W, pred.CastPos)
						end
					else
						CastGGPred(_W, target)
					end					
				end
			end			
			
			if myHero.pos:DistanceTo(target.pos) <= 750 and Menu.Combo.UseE:Value() and Ready(_E) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						SetMovement(false)
						Control.CastSpell(HK_E, pred.CastPosition)
						SetMovement(true)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						SetMovement(false)
						Control.CastSpell(HK_E, pred.CastPos)
						SetMovement(true)
					end
				else
					CastGGPred(_E, target)
				end
			end
			
			if HasBuff(myHero, "caitlynheadshotrangcheck") then return end			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "caitlynyordletrapinternal") and Menu.Combo.UseQ:Value() and Ready(_Q) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						BlockAA = true
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						BlockAA = true
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					CastGGPred(_Q, target)
				end
			end

		else
			
			if myHero.pos:DistanceTo(target.pos) <= 800 and not HasBuff(target, "caitlynyordletrapsight") and Menu.Combo.UseW:Value() and Ready(_W) and myHero:GetSpellData(_W).ammo > 0 then
				if TrapCount > 0 then
					for i = 1, #SafedTraps do
						local Object = SafedTraps[i]
						local Trap = Object.obj
						if Trap and Trap.pos:DistanceTo(target.pos) > 200 then 
							if Menu.Pred.Change:Value() == 1 then
								local pred = GetGamsteronPrediction(target, WData, myHero)
								if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
									BlockAA = true
									Control.CastSpell(HK_W, pred.CastPosition)
								end
							elseif Menu.Pred.Change:Value() == 2 then
								local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
								if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
									BlockAA = true
									Control.CastSpell(HK_W, pred.CastPos)
								end
							else
								CastGGPred(_W, target)
							end
						end
					end	
				else
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, WData, myHero)
						if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
							BlockAA = true
							Control.CastSpell(HK_W, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, WspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
							BlockAA = true
							Control.CastSpell(HK_W, pred.CastPos)
						end
					else
						CastGGPred(_W, target)
					end				
				end
			end			
			
			if myHero:GetSpellData(_W).level > 0 then
				if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "caitlynyordletrapinternal") and Menu.Combo.UseQ:Value() and Ready(_Q) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							BlockAA = true
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							BlockAA = true
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					else
						CastGGPred(_Q, target)
					end
				end
			else
				if myHero.pos:DistanceTo(target.pos) <= 1300 and Menu.Combo.UseQ:Value() and Ready(_Q) then
					if Menu.Pred.Change:Value() == 1 then
						local pred = GetGamsteronPrediction(target, QData, myHero)
						if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
							BlockAA = true
							Control.CastSpell(HK_Q, pred.CastPosition)
						end
					elseif Menu.Pred.Change:Value() == 2 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
						if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
							BlockAA = true
							Control.CastSpell(HK_Q, pred.CastPos)
						end
					else
						CastGGPred(_Q, target)
					end
				end
			end	

			if myHero.pos:DistanceTo(target.pos) <= 750 and Menu.Combo.UseE:Value() and Ready(_E) then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, EData, myHero)
					if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
						SetMovement(false)
						Control.CastSpell(HK_E, pred.CastPosition)
						SetMovement(true)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, EspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
						SetMovement(false)
						Control.CastSpell(HK_E, pred.CastPos)
						SetMovement(true)
					end
				else
					CastGGPred(_E, target)
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
					BlockAA = true
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					BlockAA = true
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				CastGGPred(_Q, target)
			end
		end
	end
end	

function CastGGPred(spell, unit)
	if spell == _Q then
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.625, Radius = 90, Range = 1250, Speed = 2200, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			BlockAA = true
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end	
	
	elseif spell == _W then
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.35, Radius = 75, Range = 800, Speed = MathHuge, Collision = false})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
			BlockAA = true
			Control.CastSpell(HK_W, WPrediction.CastPosition)
		end		
	
	else
		if spell == _E then
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.15, Radius = 75, Range = 750, Speed = 1600, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
			EPrediction:GetPrediction(unit, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
				Control.CastSpell(HK_E, EPrediction.CastPosition)
			end
		end	
	end
end

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and Menu.Clear.UseQ:Value() and GetMinionCount(180, minion) >= Menu.Clear.Count:Value() then
				BlockAA = true
				Control.CastSpell(HK_Q, minion.pos)
			end	 
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)	

		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and Menu.JClear.UseQ:Value() then
				BlockAA = true
				Control.CastSpell(HK_Q, minion.pos)
			end  
		end
	end
end

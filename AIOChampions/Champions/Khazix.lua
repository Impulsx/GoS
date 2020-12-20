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

local function GetAllyTurret()
	local _AllyTurrets = {}
    for i = 1, GameTurretCount() do
        local turret = GameTurret(i)
        if turret.isAlly and not turret.dead then
			TableInsert(_AllyTurrets, turret)
		end
	end
	return _AllyTurrets		
end

local function GetEnemyCount(range, pos)
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function GetAllyCount(range, pos)
	local count = 0
	for i, hero in ipairs(GetAllyHeroes()) do
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

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 775 + unit.boundingRadius / 2)
        if not turret.dead then 
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local function IsPosUnderTurret(Position)
	for i, turret in ipairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 775 + myHero.boundingRadius / 2)
        if not turret.dead then 
            if turret.pos:DistanceTo(Position) < range then
                return true
            end
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

local QRange = 325
local ERange = 700
local EStartpos = myHero.pos
local CanCastE = false
local SafeLife = false
local IsoKill = false
local Kill = false

function LoadScript()	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})	
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "BlockE", name = "Block[E] if more Enemies than Allies", value = true})		
	Menu.Combo:MenuElement({id = "Tower", name = "[E] Block if under enemy Turret", value = true})	
	Menu.Combo:MenuElement({id = "Iso1", name = "[E] Try first find Isolated Target", value = true})
	Menu.Combo:MenuElement({id = "Iso2", name = "[E] Only Isolated Target", value = false})		
	Menu.Combo:MenuElement({name = " ", drop = {"Ult is situationell, I havent added"}})		 

	--Extra
	Menu:MenuElement({type = MENU, id = "extra", name = "Extra Settings"})
	Menu.extra:MenuElement({id = "UseR", name = "[KS] UseR before Jump if not Passiv ", value = true})		
	Menu.extra:MenuElement({id = "UseE3", name = "[Combo] UseE if Khazix Hp low", value = true})
	Menu.extra:MenuElement({id = "Hp", name = "[Combo] UseE if Khazix Hp lower than -->", value = 20, min = 0, max = 100, identifier = "%"})			

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})

	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear Settings"})	
	Menu.Clear:MenuElement({id = "UseQ1", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseQ2", name = "[Q] Only LastHit", value = true})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "[E] min Minions", value = 3, min = 1, max = 6})	
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})  
	Menu.Clear:MenuElement({id = "Hp", name = "[W] if Khazix Hp lower than -->", value = 80, min = 0, max = 100, identifier = "%"})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear Settings"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.JClear:MenuElement({id = "Hp", name = "[W] if Khazix Hp lower than -->", value = 80, min = 0, max = 100, identifier = "%"})	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 10, min = 0, max = 100, identifier = "%"})

	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({name = " ", drop = {"Ks logic = All possible Kill calc. with all spells"}})	
	Menu.ks:MenuElement({id = "Kill", name = "Full Ks logic", value = true})
	Menu.ks:MenuElement({id = "Mode", name = "KillSteal Mode", value = 2, drop = {"Auto Mode", "Combo Mode"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings Settings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})		

	
	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 300, Range = ERange, Speed = 1500, Collision = false
	}
	
	EspellData = {speed = 1500, range = ERange, delay = 0.25, radius = 300, collision = {nil}, type = "circular"}

	WData =
	{
	Type = _G._G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1000, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	WspellData = {speed = 1700, range = 1000, delay = 0.25, radius = 70, collision = {"minion"}, type = "linear"}	
  	                                           											   
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()		
		if myHero.dead then return end
		                                               
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, QRange, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, ERange, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 1000, 1, DrawColor(225, 225, 125, 10))
		end
	end)		
end

function Tick()	
	Checks()		
	if MyHeroNotReady() then return end
	
	local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.ks.Kill:Value() and Menu.ks.Mode:Value() == 2 then
			KillSteal()
		end		
		Combo()	
	elseif Mode == "Clear" then
		Clear()		
	end	
	
	if Menu.ks.Kill:Value() then
		if Menu.ks.Mode:Value() == 1 then
			KillSteal()
		end		
	end	
end

function Checks()
	if CanCastE then
		SetMovement(false)
		DelayAction(function()
			SetMovement(true)
			CanCastE = false
		end,0.3)
	end
	
	if SafeLife and not Ready(_E) then
		SafeLife = false
	end
	
	if QRange == 325 then 
		if myHero:GetSpellData(_Q).name == "KhazixQLong" then
			QRange = 375
		end	
	end
	
	if ERange == 700 then 
		if myHero:GetSpellData(_E).name == "KhazixELong" then
			ERange = 900
		end	
	end
end

local function IsolatedTarget(range)
	local Isolated = nil
	for i, hero in ipairs(GetEnemyHeroes()) do
	
		if Isolated == nil then 
			if GetDistance(hero.pos, myHero.pos) <= range and IsValid(hero) and GetEnemyCount(500, hero.pos) == 1 and GetMinionCount(500, hero) == 0 then
				Isolated = hero
			end
		else
			if GetDistance(Isolated.pos, myHero.pos) > range or not IsValid(Isolated) or GetEnemyCount(500, Isolated.pos) > 1 or GetMinionCount(500, Isolated) > 0 then
				Isolated = nil
			end		
		end
	end
	return Isolated
end

local function FindBestPos(unit)
	for i, Tower in ipairs(GetAllyTurret()) do
		if Tower and not Tower.dead and GetDistance(Tower.pos, myHero.pos) <= (ERange+700) then
			return Tower.pos
		end
	end

	for i, Ally in ipairs(GetAllyHeroes()) do
		if Ally and IsValid(Ally) and GetDistance(Ally.pos, myHero.pos) <= ERange and not IsUnderTurret(Ally) and GetEnemyCount(500, Ally.pos) == 0 and GetDistance(Ally.pos, unit.pos) > GetDistance(myHero.pos, unit.pos) then
			return Ally.pos
		end
	end	
	
	local Pos1 = myHero.pos:Extended(mousePos, -ERange)
	local Pos2 = myHero.pos:Extended(mousePos, ERange)
	if GetEnemyCount(500, Pos1) == 0 and not IsPosUnderTurret(Pos1) and GetDistance(Pos1, unit.pos) > GetDistance(myHero.pos, unit.pos) then
		return Pos1
	elseif GetEnemyCount(500, Pos2) == 0 and not IsPosUnderTurret(Pos2) and GetDistance(Pos2, unit.pos) > GetDistance(myHero.pos, unit.pos) then
		return Pos2
	end
	return nil
end	
	 	
function Combo()
	if IsoKill or Kill then return end
	
	if Menu.extra.UseE3:Value() and Ready(_E) and not myHero.pathing.isDashing and GetEnemyCount(1000, myHero.pos) > 0 then
		if myHero.health/myHero.maxHealth <= Menu.extra.Hp:Value()/100 then
			for i, hero in ipairs(GetEnemyHeroes()) do							
				if hero and IsValid(hero) and GetDistance(hero.pos, myHero.pos) <= 1500 then
					local SafePos = FindBestPos(hero)
					if SafePos then	
						SafeLife = true
						CanCastE = true
						if CanCastE then
							Control.CastSpell(HK_E, SafePos)
						end	
					end
				end
			end	
		end
	end	
	
	----------------------------------------------	
	
	local ComboRange = myHero.range+50
	if Ready(_Q) then
		ComboRange = QRange+ComboRange
	end	
	if Ready(_E) then
		ComboRange = ERange+ComboRange

	elseif Ready(_W) then
		ComboRange = 1000+ComboRange
	end	

	local target = GetTarget(ComboRange)
	if target == nil or SafeLife then return end
	if IsValid(target) then
	
		if Menu.Combo.UseE:Value() and Ready(_E) and not myHero.pathing.isDashing and myHero.pos:DistanceTo(target.pos) < ERange then
			if Menu.Combo.Iso2:Value() then
				local IsoTarget = IsolatedTarget(ERange)
				--print(IsoTarget)
				if IsoTarget then
					target = IsoTarget
					if Menu.Combo.Tower:Value() then
						if not IsUnderTurret(IsoTarget) then
							ECast2(IsoTarget)
						end
					else
						ECast2(IsoTarget)
					end
				end						
			else
				if Menu.Combo.Iso1:Value() then
					local IsoTarget = IsolatedTarget(ERange)
					if IsoTarget then
						target = IsoTarget
						if Menu.Combo.Tower:Value() then
							if not IsUnderTurret(IsoTarget) then
								ECast2(IsoTarget)
							end
						else
							ECast2(IsoTarget)
						end
					else
						if Menu.Combo.Tower:Value() then
							if not IsUnderTurret(target) then
								ECast2(target)
							end
						else
							ECast2(target)
						end							
					end
				else
					if Menu.Combo.Tower:Value() then
						if not IsUnderTurret(target) then
							ECast2(target)
						end
					else
						ECast2(target)
					end						
				end	
			end	
		end	

		if Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < QRange then 
			Control.CastSpell(HK_Q, target)
		end

		if Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 1000 and not myHero.pathing.isDashing then
			WCast(target)
		end	
	end
end

function Clear()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_ENEMY and IsValid(minion) then
			if myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then 
				if myHero.pos:DistanceTo(minion.pos) < QRange and Menu.Clear.UseQ1:Value() and Ready(_Q) then
					if Menu.Clear.UseQ2:Value() then
						local QDmg = getdmg("Q", minion, myHero, 1)
						if QDmg > minion.health then
							Control.CastSpell(HK_Q, minion)
						end	
					else
						Control.CastSpell(HK_Q, minion)
					end
						  
				elseif myHero.pos:DistanceTo(minion.pos) < ERange and Ready(_E) and Menu.Clear.UseE:Value() and not IsUnderTurret(minion) then
					local count = GetMinionCount(300, minion)
					if count >= Menu.Clear.UseEM:Value() then
						Control.CastSpell(HK_E, minion.pos)
					end    
					
				else
					if myHero.pos:DistanceTo(minion.pos) < 900 and Ready(_W) and Menu.Clear.UseW:Value() then
						if myHero.health/myHero.maxHealth <= Menu.Clear.Hp:Value() / 100 then
							Control.CastSpell(HK_W, minion.pos)
						end    
					end
				end	
			end	
		else
			if myHero.pos:DistanceTo(minion.pos) <= 900 and minion.team == TEAM_JUNGLE and IsValid(minion) then
				if myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then
				
					if myHero.pos:DistanceTo(minion.pos) < QRange and Menu.JClear.UseQ:Value() and Ready(_Q) then
						Control.CastSpell(HK_Q, minion)
							  
					elseif myHero.pos:DistanceTo(minion.pos) < ERange and Ready(_E) and Menu.JClear.UseE:Value() then
						Control.CastSpell(HK_E, minion.pos)    
					
					else
						if myHero.pos:DistanceTo(minion.pos) < 900 and Ready(_W) and Menu.JClear.UseW:Value() then
							if myHero.health/myHero.maxHealth <= Menu.JClear.Hp:Value() / 100 then
								Control.CastSpell(HK_W, minion.pos)
							end    
						end
					end	
				end	
			end			
		end
	end	
end

function KillSteal()				
	local IsoTarget = IsolatedTarget(ERange+1000)
	if IsoTarget then				
		if Ready(_Q) then
			local IsoQDmg = getdmg("Q", IsoTarget, myHero, 2)
			local EDmg = getdmg("E", IsoTarget, myHero)
			local WDmg = getdmg("W", IsoTarget, myHero)
			
			if Ready(_W) then
				if myHero.pos:DistanceTo(IsoTarget.pos) < ERange and Ready(_E) then
					if (IsoQDmg+EDmg+WDmg) > IsoTarget.health then
						IsoKill = true
						if Ready(_R) and Menu.extra.UseR:Value() and not HasBuff(myHero, "KhazixPDamage") then
							Control.CastSpell(HK_R)
						end						
						if ECast(IsoTarget) then
							WCast(IsoTarget)
						end
					end
				end					
			else
				if myHero.pos:DistanceTo(IsoTarget.pos) < ERange and Ready(_E) then
					if (IsoQDmg+EDmg) > IsoTarget.health then
						IsoKill = true
						if Ready(_R) and Menu.extra.UseR:Value() and not HasBuff(myHero, "KhazixPDamage") then
							Control.CastSpell(HK_R)
						end
						ECast(IsoTarget)
					end
				end
			end	
			
			if IsoQDmg > IsoTarget.health then
				IsoKill = true
				if myHero.pos:DistanceTo(IsoTarget.pos) > QRange then
					if Ready(_E) then
						if Ready(_R) and Menu.extra.UseR:Value() and not HasBuff(myHero, "KhazixPDamage") then
							Control.CastSpell(HK_R)
						end					
						EStartpos = myHero.pos
						CanCastE = true
						if CanCastE then
							Control.CastSpell(HK_E, IsoTarget.pos)
						end	
					end	
				else
					Control.CastSpell(HK_Q, IsoTarget)
				end
			end
		end
	end
	IsoKill = false
	
	if IsoKill then return end
	for i, target in ipairs(GetEnemyHeroes()) do	
		if target and IsValid(target) and myHero.pos:DistanceTo(target.pos) < ERange+1000 then 
			local QDmg = Ready(_Q) and getdmg("Q", target, myHero, 1) or 0
			local EDmg = Ready(_E) and getdmg("E", target, myHero) or 0
			local WDmg = Ready(_W) and getdmg("W", target, myHero) or 0
			
			if QDmg > 0 and EDmg > 0 and WDmg > 0 then
				if myHero.pos:DistanceTo(target.pos) < ERange then
					if (QDmg+EDmg+WDmg) > target.health then
						Kill = true
						if Ready(_R) and Menu.extra.UseR:Value() and not HasBuff(myHero, "KhazixPDamage") then
							Control.CastSpell(HK_R)
						end						
						ECast(target)							
					end
				end	
				
			elseif QDmg > 0 and WDmg > 0 then
				if myHero.pos:DistanceTo(target.pos) < QRange then
					if (QDmg+WDmg) > target.health then
						Kill = true
						if Control.CastSpell(HK_Q, target) then
							WCast(target)
						end
					end
				end		
			
			elseif EDmg > 0 and WDmg > 0 then
				if myHero.pos:DistanceTo(target.pos) < ERange then
					if (EDmg+WDmg) > target.health then
						Kill = true
						if Ready(_R) and Menu.extra.UseR:Value() and not HasBuff(myHero, "KhazixPDamage") then
							Control.CastSpell(HK_R)
						end						
						ECast(target)							
					end
				end
				
			elseif WDmg > 0 then
				if myHero.pos:DistanceTo(target.pos) < 1000 then
					if WDmg > target.health then
						Kill = true
						WCast(target)							
					end
				else
					if Ready(_E) and WDmg > target.health and myHero.pos:DistanceTo(target.pos) < (1000+ERange) then
						Kill = true
						if Ready(_R) and Menu.extra.UseR:Value() and not HasBuff(myHero, "KhazixPDamage") then
							Control.CastSpell(HK_R)
						end						
						EStartpos = myHero.pos
						CanCastE = true
						if CanCastE then
							Control.CastSpell(HK_E, target.pos)
						end	
					end
				end

			elseif EDmg > 0 and QDmg > 0 then
				if myHero.pos:DistanceTo(target.pos) < ERange then
					if (EDmg+QDmg) > target.health then
						Kill = true
						if Ready(_R) and Menu.extra.UseR:Value() and not HasBuff(myHero, "KhazixPDamage") then
							Control.CastSpell(HK_R)
						end						
						ECast(target)							
					end
				end
				
			elseif QDmg > 0 then
				if myHero.pos:DistanceTo(target.pos) < QRange then
					if QDmg > target.health then
						Kill = true
						Control.CastSpell(HK_Q, target)							
					end
				else
					if Ready(_E) and QDmg > target.health and myHero.pos:DistanceTo(target.pos) < (QRange+ERange) then
						Kill = true
						if Ready(_R) and Menu.extra.UseR:Value() and not HasBuff(myHero, "KhazixPDamage") then
							Control.CastSpell(HK_R)
						end						
						EStartpos = myHero.pos
						CanCastE = true
						if CanCastE then
							Control.CastSpell(HK_E, target.pos)
						end	
					end					
				end				
			end	
		end
	end
	Kill = false
end	

function ECast(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, EData, myHero)
		if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
			EStartpos = myHero.pos
			CanCastE = true
			if CanCastE then
				Control.CastSpell(HK_E, pred.CastPosition)
			end	
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
			EStartpos = myHero.pos
			CanCastE = true
			if CanCastE then
				Control.CastSpell(HK_E, pred.CastPos)
			end	
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 300, Range = ERange, Speed = 1500, Collision = false})
		EPrediction:GetPrediction(unit, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value()+1) then
			EStartpos = myHero.pos
			CanCastE = true
			if CanCastE then	
				Control.CastSpell(HK_E, EPrediction.CastPosition)
			end	
		end
	end
end

function ECast2(unit)
	if Menu.Combo.BlockE:Value() then
		local CE = GetEnemyCount(800, unit.pos)
		local CA = GetAllyCount(800, unit.pos)+1
		
		if CA < CE then return end
		
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				EStartpos = myHero.pos
				CanCastE = true
				if CanCastE then
					Control.CastSpell(HK_E, pred.CastPosition)
				end	
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				EStartpos = myHero.pos
				CanCastE = true
				if CanCastE then
					Control.CastSpell(HK_E, pred.CastPos)
				end	
			end
		else
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 300, Range = ERange, Speed = 1500, Collision = false})
			EPrediction:GetPrediction(unit, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value()+1) then
				EStartpos = myHero.pos
				CanCastE = true
				if CanCastE then	
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end	
			end
		end
	else
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, EData, myHero)
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				EStartpos = myHero.pos
				CanCastE = true
				if CanCastE then
					Control.CastSpell(HK_E, pred.CastPosition)
				end	
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				EStartpos = myHero.pos
				CanCastE = true
				if CanCastE then
					Control.CastSpell(HK_E, pred.CastPos)
				end	
			end
		else
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 300, Range = ERange, Speed = 1500, Collision = false})
			EPrediction:GetPrediction(unit, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value()+1) then
				EStartpos = myHero.pos
				CanCastE = true
				if CanCastE then	
					Control.CastSpell(HK_E, EPrediction.CastPosition)
				end	
			end
		end
	end
end

function WCast(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
			Control.CastSpell(HK_W, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
			Control.CastSpell(HK_W, pred.CastPos)
		end
	else
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1000, Speed = 1700, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value()+1) then
			Control.CastSpell(HK_W, WPrediction.CastPosition)
		end
	end
end

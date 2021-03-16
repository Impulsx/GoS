local function GetDistanceSqr(pos1, pos2)
	local pos2 = pos2 or myHero.pos
	local dx = pos1.x - pos2.x
	local dz = (pos1.z or pos1.y) - (pos2.z or pos2.y)
	return dx * dx + dz * dz
end

local function GetDistance(pos1, pos2)
	return math.sqrt(GetDistanceSqr(pos1, pos2))
end

local function SetAttack(bool)
	if _G.SDK then
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetAttack(bool)
	end
end

local function SetMovement(bool)
	if _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetMovement(bool)
	end
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

local function GetEnemyCount(range, pos)
	local EnemiesAroundUnit = 0
    for i, enemy in ipairs(GetEnemyHeroes()) do
        if enemy and not enemy.dead and IsValid(enemy) then
            if GetDistance(enemy.pos, pos.pos) < range then
                EnemiesAroundUnit = EnemiesAroundUnit + 1
            end
        end
    end
    return EnemiesAroundUnit
end

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurret()) do
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2) 
		if turret.pos:DistanceTo(unit.pos) < range then
			return true
		end
    end
    return false
end

local function CalcFullDmg(unit, DmgSpell)
	local QDmg     = Ready(_Q) and getdmg("Q", unit, myHero) or 0
	local WDmg     = Ready(_W) and getdmg("W", unit, myHero, 1) + getdmg("W", unit, myHero, 2) or 0
	local RDmg 	   = Ready(_R) and (getdmg("R", unit, myHero, 1) + getdmg("R", unit, myHero, 2))*0.8 or 0

	local AADmg	   		= getdmg("AA", unit, myHero)
	local AACritDmg		= CalcPhysicalDamage(myHero, unit, AADmg * 1.8)
	local AADmg2		= CalcPhysicalDamage(myHero, unit, myHero.totalDamage*0.5) + CalcMagicalDamage(myHero, unit, myHero.totalDamage*0.5)
	local AACritDmg2	= CalcPhysicalDamage(myHero, unit, (myHero.totalDamage*0.9)) + CalcMagicalDamage(myHero, unit, (myHero.totalDamage*0.9))
	local CalcEDmg = 0

	local AADmgFinal = ((AADmg + AADmg2)/2) * ((myHero.critChance*0.9)+1)

	local EDmgPercent     = 1 + ((myHero:GetSpellData(_E).level * 2.5) + 22.5)/100
	local damage   = 0
	local pdamage  = 0
	if Ready(_Q) then
		damage = damage + getdmg("Q", unit, myHero) + AADmgFinal
	end	
	if Ready(_W) then
		damage = damage + getdmg("W", unit, myHero, 1) + getdmg("W", unit, myHero, 2) + AADmgFinal
	end	
	if Ready(_R) then
		damage = damage + (getdmg("R", unit, myHero, 1) + getdmg("R", unit, myHero, 2)) *0.8 + AADmgFinal
	end
	if Ready(_E) or myHero.mana > 0 then
		damage = damage * EDmgPercent
	end	
	pdamage = (QDmg + WDmg + RDmg + (AADmgFinal*3)) * EDmgPercent
	--print(RDmg)
	local Damages = {CurrentDamage = damage, PossibleDamage = pdamage}		
	return Damages
end

local function CalcTurretDmg()
	local Damage = 0
	local TimeCalc = 100
	local Timer = GameTimer()
	
	if Timer < 30 then
		TimeCalc = 0
	elseif Timer < 90 then
		TimeCalc = 1
	elseif Timer < 150 then
		TimeCalc = 2
	elseif Timer < 210 then
		TimeCalc = 3
	elseif Timer < 270 then
		TimeCalc = 4
	elseif Timer < 330 then
		TimeCalc = 5
	elseif Timer < 390 then
		TimeCalc = 6
	elseif Timer < 450 then
		TimeCalc = 7
	elseif Timer < 510 then
		TimeCalc = 8
	elseif Timer < 570 then
		TimeCalc = 9
	elseif Timer < 630 then
		TimeCalc = 10
	elseif Timer < 690 then
		TimeCalc = 11
	elseif Timer < 750 then
		TimeCalc = 12
	elseif Timer < 810 then
		TimeCalc = 13
	elseif Timer >= 810 then
		TimeCalc = 14
	end
	
	if TimeCalc < 100 then
		local Dmg = 152 + (9 * TimeCalc)
		Damage = Dmg
	end
	return Damage
end


----------------------------------------------------
--|                Champion               		|--
----------------------------------------------------

class "Yone"

local CastedW = false
local TickW = false
local CastedQ = false
local TickQ = false
local CastedR = false
local TickR = false
local EDmgPred = 0
local Added = false
local AutoAttacks = 0
local LastSpellName = ""
local target = nil
local LastTargetHealth = 10000


function Yone:LoadScript()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	
	--//// Q-Prediction Data ////--
	QspellData = {speed = 1700, range = 900, delay = 0.35, radius = 120, collision = {nil}, type = "linear"}
	QShortspellData = {speed = 1700, range = 475, delay = 0.35, radius = 80, collision = {nil}, type = "linear"}
	Q2spellData = {speed = 1700, range = 1150, delay = 0.65, radius = 80, collision = {nil}, type = "linear"}

	--//// W-Prediction Data ////--
	WspellData = {speed = 2000, range = 600, delay = 0.15, radius = 0, angle = 80, collision = {nil}, type = "conic"}

	--//// R-Prediction Data ////--
	RspellData = {speed = 1500, range = 900, delay = 0.5, radius = 120, collision = {nil}, type = "linear"}
	R2spellData = {speed = 1500, range = 1200, delay = 0.8, radius = 120, collision = {nil}, type = "linear"}	
end

function Yone:LoadMenu()                     	
									 -- MainMenu --
	self.Menu = MenuElement({type = MENU, id = "PussySeries".. myHero.charName, name = "Yone"})
	self.Menu:MenuElement({name = " ", drop = {"Version 0.01"}})
	
	
									  -- Combo --
	self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})
	
	-- Q --
	self.Menu.ComboSet:MenuElement({type = MENU, id = "Q", name = "Q Settings"})
	self.Menu.ComboSet.Q:MenuElement({id = "UseQ1", name = "Use [Q] in Combo", value = true})	
	self.Menu.ComboSet.Q:MenuElement({id = "UseQ2", name = "Stack [Q] on Minions", value = false})
	self.Menu.ComboSet.Q:MenuElement({id = "UseQ3", name = "[Q3] Single Target", value = true})	
	self.Menu.ComboSet.Q:MenuElement({id = "UseQ4", name = "[Q3] Focus Multiple Targets", value = true})		
			
	-- W --
	self.Menu.ComboSet:MenuElement({type = MENU, id = "W", name = "W Settings"})		
	self.Menu.ComboSet.W:MenuElement({id = "UseW1", name = "Use [W] in Combo", value = true})
	self.Menu.ComboSet.W:MenuElement({id = "UseW2", name = "[W] Focus Multiple Targets ( Bigger Shield )", value = true})	

	-- E --
	self.Menu.ComboSet:MenuElement({type = MENU, id = "E", name = "E Settings"})		
	self.Menu.ComboSet.E:MenuElement({id = "UseE1", name = "Use [E] in Combo", value = true})
	self.Menu.ComboSet.E:MenuElement({id = "UseE2", name = "Save Life under Tower (E2 Back if can Tower kill you)", value = true})
	self.Menu.ComboSet.E:MenuElement({id = "UseE3", name = "[E2] Back ( Back if Yone Hp lower than Slider )", value = true})
	self.Menu.ComboSet.E:MenuElement({id = "Hp", name = "[E2] Back if Yone Hp lower than -->", value = 5, min = 0, max = 100, identifier = "%"})
	self.Menu.ComboSet.E:MenuElement({id = "UseE4", name = "[E2] Execute Target", value = true})
	
	
	-- R --
	self.Menu.ComboSet:MenuElement({type = MENU, id = "R", name = "R Settings"})		
	self.Menu.ComboSet.R:MenuElement({id = "UseR1", name = "Use [R] in Combo", value = true})
	self.Menu.ComboSet.R:MenuElement({id = "UseR2", name = "[R] Single Target if killable full Combo", value = true})
	self.Menu.ComboSet.R:MenuElement({id = "UseR3", name = "[R] Focus Multiple Targets", value = true})
	self.Menu.ComboSet.R:MenuElement({id = "RCount", name = "[R] Multiple Targets", value = 2, min = 2, max = 5, step = 1})
	
	
									  -- Harass --
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})	
	
	self.Menu.Harass:MenuElement({id = "UseQ1", name = "Use [Q] in Harass", value = true})	
	self.Menu.Harass:MenuElement({id = "UseQ2", name = "Use [Q3] in Harass", value = true})
	self.Menu.Harass:MenuElement({id = "UseQ3", name = "Stack [Q] on Minions", value = true})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "Use [W] in Harass", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "Use [E] in Harass", value = true})
	self.Menu.Harass:MenuElement({id = "UseE3", name = "[E2] Back (After Set Number of AA's)", value = true})
	self.Menu.Harass:MenuElement({id = "E3AA", name = "[E2] Number Of Auto Attacks -->", value = 2, min = 1, max = 5, step = 1})
	self.Menu.Harass:MenuElement({id = "UseE2", name = "[E2] Back ( Back if Yone Hp lower than Slider )", value = false})
	self.Menu.Harass:MenuElement({id = "Hp", name = "[E2] Back if Yone Hp lower than -->", value = 20, min = 0, max = 100, identifier = "%"})


	                                 -- KillSteal --
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal Settings"})	
	self.Menu.ks:MenuElement({id = "UseR", name = "Auto[R] killable single target", value = true})
	self.Menu.ks:MenuElement({id = "RRange", name = "Checkrange others around single Target", value = 500, min = 0, max = 2000, step = 10})	


								  -- Lane/JungleClear --
	self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ1", name = "Use [Q]", value = true})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ2", name = "Use [Q3]", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "UseW", name = "Use [W]", value = true})	
	
	--JungleClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ1", name = "Use [Q]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ2", name = "Use [Q3]", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "UseW", name = "Use [W]", value = true})		


										-- Misc --
    self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})	
			
	--Prediction
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.Menu.MiscSet.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Premium Prediction", "GGPrediction"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q3]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] and [Q3] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "Kill", name = "Draw KillText 1 vs 1", value = true})		
end

function Yone:Tick()

if IsLoaded and not PredLoaded then
	DelayAction(function()
		if self.Menu.MiscSet.Pred.Change:Value() == 1 then
			require('PremiumPrediction')
		else
			require('GGPrediction')
		end
	end, 0.1)
	PredLoaded = true
end		
target = GetTarget(1300)
local target2 = GetTarget(1300)
self:CalcEDmg(target)   

if MyHeroNotReady() then return end

self:ProcessSpells()
self:KsUlt()
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:JungleClear()
		self:Clear()	
	end			
end

function Yone:CastingChecks()
	local CastingQ = myHero.activeSpell.name == "YoneQ" or myHero.activeSpell.name == "YoneQ2" or myHero.activeSpell.name == "YoneQ3"
	local CastingW = myHero.activeSpell.name == "YoneW"
	local CastingE = myHero.activeSpell.name == "YoneE"
	local CastingR = myHero.activeSpell.name == "YoneR"

	local CastingChecksReturn = not CastingQ and not CastingW and not CastingE and not CastingR and not (myHero.pathing and myHero.pathing.isDashing) 
	return CastingChecksReturn
end

function Yone:ProcessSpells()
    if myHero:GetSpellData(_Q).currentCd == 0 then
        CastedQ = false
    else
        if CastedQ == false then
            TickQ = true
            --print(TickQ)
        end
        CastedQ = true
    end
    if myHero:GetSpellData(_W).currentCd == 0 then
        CastedW = false
    else
        if CastedW == false then
            TickW = true
        end
        CastedW = true
    end
    if myHero:GetSpellData(_R).currentCd == 0 then
        CastedR = false
    else
        if CastedR == false then
            TickR = true
        end
        CastedR = true
    end
end

function Yone:CalcEDmg(unit)
	if myHero.mana > 0 and unit ~= nil then

		local QDmg     		= getdmg("Q", unit, myHero)
		local QCritDmg 		= CalcPhysicalDamage(myHero, unit, QDmg * 1.8)
		local WDmg     		= getdmg("W", unit, myHero, 1) + getdmg("W", unit, myHero, 2)
		local RDmg     		= getdmg("R", unit, myHero, 1) + getdmg("R", unit, myHero, 2)

		local AADmg	   		= getdmg("AA", unit, myHero)
		local AACritDmg		= CalcPhysicalDamage(myHero, unit, AADmg * 1.8)
		local AADmg2		= CalcPhysicalDamage(myHero, unit, myHero.totalDamage*0.5) + CalcMagicalDamage(myHero, unit, myHero.totalDamage*0.5)
		local AACritDmg2	= CalcPhysicalDamage(myHero, unit, (myHero.totalDamage*0.5) *0.9) + CalcMagicalDamage(myHero, unit, (myHero.totalDamage*0.5) *0.9)
 		
		if Added == false then
            
			if myHero.activeSpell.name == "YoneBasicAttack" or myHero.activeSpell.name == "YoneBasicAttack3" then
            	LastSpellName = myHero.activeSpell.name
            	DelayAction(function()
                	EDmgPred = EDmgPred + AADmg
				end,0.2)
                Added = true
                AutoAttacks = AutoAttacks + 1
            elseif myHero.activeSpell.name == "YoneCritAttack" or myHero.activeSpell.name == "YoneCritAttack3" then
            	LastSpellName = myHero.activeSpell.name
            	DelayAction(function()
                	EDmgPred = EDmgPred + AACritDmg
				end,0.2)
                Added = true
                AutoAttacks = AutoAttacks + 1
            elseif myHero.activeSpell.name == "YoneBasicAttack2" or myHero.activeSpell.name == "YoneBasicAttack4" then
            	LastSpellName = myHero.activeSpell.name
            	DelayAction(function()
                	EDmgPred = EDmgPred + AADmg2
				end,0.2)
                Added = true
                AutoAttacks = AutoAttacks + 1
            elseif myHero.activeSpell.name == "YoneCritAttack2" or myHero.activeSpell.name == "YoneCritAttack4" then
            	LastSpellName = myHero.activeSpell.name
            	DelayAction(function()
                	EDmgPred = EDmgPred + AACritDmg2
				end,0.2)
                Added = true
                AutoAttacks = AutoAttacks + 1     
            end
        
		elseif myHero.activeSpell.name ~= LastSpellName then
            Added = false
        end
        
		if TickQ then
	        if unit.health ~= LastTargetHealth then
                if (LastTargetHealth - unit.health) - QDmg > -50 and (LastTargetHealth - unit.health) - QDmg < 50 then
                    EDmgPred = EDmgPred + QDmg
                    TickQ = false
                elseif (LastTargetHealth - unit.health) - QCritDmg > -50 and (LastTargetHealth - unit.health) - QCritDmg < 50 then
                	EDmgPred = EDmgPred + QCritDmg
                    TickQ = false
                end
	        end
        end
       	LastTargetHealth = unit.health
       
		if TickW then
        	--print("Tick W")
        	EDmgPred = EDmgPred + WDmg
        	TickW = false
        end
        
		if TickR then
        	EDmgPred = EDmgPred + RDmg
        	TickR = false      
		end
		
    else
    	
		EDmgPred = 0
    	Added = false
    	LastSpellName = ""
    	TickW = false
    	TickR = false
    	TickQ = false
    	AutoAttacks = 0
    	LastTargetHealth = 10000
	end
	
	local EPercent = 0.225 + (0.025*myHero:GetSpellData(_E).level)
	if EDmgPred ~= 0 then 
		--print(math.floor(EDmgPred * EPercent))
	end
end

function Yone:KsUlt()
	if Ready(_R) and self.Menu.ks.UseR:Value() then
		for i, Enemy in ipairs(GetEnemyHeroes()) do
			if Enemy and myHero.pos:DistanceTo(Enemy.pos) <= 1000 and IsValid(Enemy) then
				local RDmg  = getdmg("R", Enemy, myHero, 1) + getdmg("R", Enemy, myHero, 2)
				local AADmg = getdmg("AA", Enemy, myHero) + (CalcPhysicalDamage(myHero, Enemy, 0.5 * myHero.totalDamage) + CalcMagicalDamage(myHero, Enemy, 0.5 * myHero.totalDamage))
				local KSDmg = RDmg + AADmg

				if KSDmg >= Enemy.health and GetEnemyCount(self.Menu.ks.RRange:Value(), Enemy) == 1 and self:CastingChecks() then
					if self.Menu.MiscSet.Pred.Change:Value() == 1 then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, Enemy, RspellData)
						if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
							Control.CastSpell(HK_R, pred.CastPos)
						end
					else
						local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.5, Radius = 150, Range = 900, Speed = 1700, Collision = false})
						RPrediction:GetPrediction(Enemy, myHero)
						if RPrediction:CanHit(self.Menu.MiscSet.Pred.PredR:Value()+1) then
							Control.CastSpell(HK_R, RPrediction.CastPosition)
						end
					end	
				end			
			end
		end
	end	
end

function Yone:Combo()
local CastingE = myHero.activeSpell.name == "YoneE"
local CastingR = myHero.activeSpell.name == "YoneR"  	
if target == nil then return end
	
	if IsValid(target) then
		
		self:CalcEDmg(target)
		local FullDmg = CalcFullDmg(target)
		local EnemyCount = GetEnemyCount(2000, myHero)

		local Attacking = false
		if _G.SDK then
			Attacking = _G.SDK.Attack:IsActive()
		elseif _G.PremiumOrbwalker then
			Attacking =_G.PremiumOrbwalker:IsAutoAttacking()	-- added Prem.Orb Attack Check		
		end
				
		
		if self.Menu.ComboSet.E.UseE4:Value() and myHero.mana > 0 and Ready(_E) and not (myHero.pathing and myHero.pathing.isDashing) and not CastingE and not CastingR then
			local EPercent = 0.225 + (0.025*myHero:GetSpellData(_E).level)
			if target.health <= EDmgPred * EPercent then
				--print("Execute " .. math.floor(EDmgPred*EPercent))
				Control.CastSpell(HK_E)
			end
		end
		
		if self.Menu.ComboSet.E.UseE3:Value() and myHero.mana > 0 and Ready(_E) and not (myHero.pathing and myHero.pathing.isDashing) and not CastingE and not CastingR then
			if myHero.health/myHero.maxHealth <= self.Menu.ComboSet.E.Hp:Value() / 100 then
				Control.CastSpell(HK_E)
			end
		end

		if self.Menu.ComboSet.E.UseE2:Value() and myHero.mana > 0 and Ready(_E) and not (myHero.pathing and myHero.pathing.isDashing) and not CastingE and not CastingR then
			if myHero.pos:DistanceTo(target.pos) <= 750 and IsUnderTurret(myHero) and IsUnderTurret(target) then
				local TurretDmg = CalcTurretDmg()
				if TurretDmg + 50 >= myHero.health then
					Control.CastSpell(HK_E)
				end	
			end
		end


		local E1Ready = self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0
		local RReady = Ready(_R) and self.Menu.ComboSet.R.UseR1:Value()
		if RReady and self:CastingChecks() then

			if self.Menu.ComboSet.R.UseR3:Value() then
				if EnemyCount >= self.Menu.ComboSet.R.RCount:Value() then
					self:CastRAOE(target)
				end	
			end			
			if self.Menu.ComboSet.R.UseR2:Value() and (myHero:GetSpellData(_Q).name == "YoneQ" or myHero.mana == 0) then
				if myHero.pos:DistanceTo(target.pos) <= 900 then
					if FullDmg.CurrentDamage >= target.health then
						self:CastR(target)
					end
				end
			end
		end			

		local QReady = Ready(_Q) and self.Menu.ComboSet.Q.UseQ1:Value()
		if QReady and self:CastingChecks() and not Attacking then			
			if myHero:GetSpellData(_Q).name == "YoneQ" then
				if (myHero.mana == 0 or not Ready(_R) or target.health > FullDmg.CurrentDamage) then
					if myHero.pos:DistanceTo(target.pos) <= 450 then
						self:CastQShort(target)
					else
						if self.Menu.ComboSet.Q.UseQ2:Value() then
							self:StackQMinion()
						end
					end
				end
			else
				if self.Menu.ComboSet.Q.UseQ4:Value() then
					if EnemyCount > 2 then
						self:CastQAOE(target)
					end	
				end
				if self.Menu.ComboSet.Q.UseQ3:Value() then
					if myHero.pos:DistanceTo(target.pos) <= 850 then
						self:CastQ(target)
					end	
				end
			end
		end	

		if self.Menu.ComboSet.W.UseW1:Value() and Ready(_W) and self:CastingChecks() and not Attacking then			
			local CheckCount = GetEnemyCount(600, myHero)
			local CheckTargetCount = GetEnemyCount(250, target)
			local RPrimed = (myHero.mana > 0 and Ready(_R) and target.health < FullDmg.CurrentDamage)
			if self.Menu.ComboSet.W.UseW2:Value() and CheckCount >= 2 and (CheckTargetCount < 2 or not RPrimed) then 
				self:CastW()
			elseif not RPrimed then
				if myHero.pos:DistanceTo(target.pos) <= 500 then
					Control.CastSpell(HK_W, target.pos)
				end
			end	
		end	

	end
end	

function Yone:Harass()

local Attacking = false
if _G.SDK then
	Attacking = _G.SDK.Attack:IsActive()
elseif _G.PremiumOrbwalker then
	Attacking =_G.PremiumOrbwalker:IsAutoAttacking()	-- added Prem.Orb Attack Check		
end
     	
if target == nil then return end 
	
	if IsValid(target) then
		
		if self.Menu.Harass.UseE2:Value() and myHero.mana > 0 and Ready(_E) then
			if myHero.health/myHero.maxHealth <= self.Menu.Harass.Hp:Value() / 100 then
				Control.CastSpell(HK_E)
			end
		end			
		
		if self.Menu.Harass.UseE3:Value() and myHero.mana > 0 and Ready(_E) then
			if AutoAttacks >= self.Menu.Harass.E3AA:Value() then
				Control.CastSpell(HK_E)
			end
		end	

		if self.Menu.Harass.UseW:Value() and Ready(_W) and (not Attacking or GetDistance(target.pos) > 200) then			
			if myHero.pos:DistanceTo(target.pos) <= 500 then
				Control.CastSpell(HK_W, target.pos)
			end
		end	
			
		if self.Menu.Harass.UseQ1:Value() and Ready(_Q) and (not Attacking or GetDistance(target.pos) > 200) then
			
			if myHero:GetSpellData(_Q).name == "YoneQ" then
				if myHero.pos:DistanceTo(target.pos) <= 450 then
					self:CastQShort(target)
				else
					if self.Menu.Harass.UseQ3:Value() then
						self:StackQMinion()
					end
				end
			else
				if self.Menu.Harass.UseQ2:Value() and myHero:GetSpellData(_Q).name == "YoneQ3" and Ready(_Q) then
					if myHero.pos:DistanceTo(target.pos) <= 850 then
						self:CastQ(target)
					end							
				end				
			end
		end
	end
end

function Yone:StackQMinion()
	if Ready(_Q) and myHero:GetSpellData(_Q).name == "YoneQ" then
		for i = 1, GameMinionCount() do
		local minion = GameMinion(i)

			if (minion.team == TEAM_JUNGLE or minion.team == TEAM_ENEMY) and myHero.pos:DistanceTo(minion.pos) <= 400 and IsValid(minion) then
				SetMovement(false)
				Control.CastSpell(HK_Q, minion)
				SetMovement(true)
			end
		end	
	end	
end		

function Yone:JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_JUNGLE and IsValid(minion) then
 			
			if self.Menu.ClearSet.JClear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, minion.pos)                  
            end           
           
			if self.Menu.ClearSet.JClear.UseQ1:Value() then
				if myHero.pos:DistanceTo(minion.pos) <= 475 and myHero:GetSpellData(_Q).name == "YoneQ" and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end	

			if self.Menu.ClearSet.JClear.UseQ2:Value() then
				if myHero.pos:DistanceTo(minion.pos) <= 450 and myHero:GetSpellData(_Q).name == "YoneQ3" and Ready(_Q) then 
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end				
        end
    end
end
			
function Yone:Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 500 and minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if self.Menu.ClearSet.Clear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, minion.pos)                  
            end           
           
			if self.Menu.ClearSet.Clear.UseQ1:Value() then
				if myHero.pos:DistanceTo(minion.pos) <= 475 and myHero:GetSpellData(_Q).name == "YoneQ" and Ready(_Q) then 
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end	

			if self.Menu.ClearSet.Clear.UseQ2:Value() then
				if myHero.pos:DistanceTo(minion.pos) <= 450 and myHero:GetSpellData(_Q).name == "YoneQ3" and Ready(_Q) then 
					Control.CastSpell(HK_Q, minion.pos)
				end	
			end				
        end
    end
end

function Yone:CastE1Smart(unit)
	local mode = GetMode()
	local E1Ready = self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0
	if mode == "Harass" then
		E1Ready = self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.mana == 0
	end
	
	if E1Ready then
		local EnemyCount = GetEnemyCount(600, unit)
		if EnemyCount > 1 then
			for i, Enemy in ipairs(GetEnemyHeroes()) do
				if Enemy and GetDistance(Enemy.pos, unit.pos) < 600 then
	        		local EDirection = Vector((unit.pos - Enemy.pos):Normalized())
	        		local EDistance = GetDistance(unit.pos, Enemy.pos) + 300
	        		local ESpot = unit.pos + EDirection * 300
	        		if GetDistance(ESpot) < 300 and GetDistance(ESpot, unit.pos) < 600 then
	        			Control.CastSpell(HK_E, ESpot)
	        		end
				end
			end
		else
			Control.CastSpell(HK_E, unit)
		end
	end
end

function Yone:CastQ(unit)
	local mode = GetMode()
	local E1Ready = self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0
	if mode == "Harass" then
		E1Ready = self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.mana == 0
	end
	
	if myHero.mana > 0 or not E1Ready or GetDistance(unit.pos) < 200 then
		
		if self.Menu.MiscSet.Pred.Change:Value() == 1 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
			if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredQ:Value(), pred.HitChance) then
				Control.CastSpell(HK_Q, pred.CastPos)
			end
		else
			self:CastQGGPred(unit)	
		end
	
	elseif E1Ready then
		self:CastE1Smart(unit)
	end
end

function Yone:CastQShort(unit)
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QShortspellData)
		if pred.CastPos and pred.HitChance > 0  then
			Control.CastSpell(HK_Q, pred.CastPos)
		end
	else
		self:CastQShortGGPred(unit)	
	end
end		

function Yone:CastW()
	for i, Enemy in ipairs(GetEnemyHeroes()) do
		if Enemy and myHero.pos:DistanceTo(Enemy.pos) <= 600 and IsValid(Enemy) then
			if self.Menu.MiscSet.Pred.Change:Value() == 1 then
				local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, Enemy, WspellData)
				if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredW:Value(), pred.HitChance) and pred.HitCount >= 2 then
					Control.CastSpell(HK_W, pred.CastPos)
				end
			else
				self:CastWGGPred()	
			end	
		end
	end
end	

function Yone:CastR(unit)
	local mode = GetMode()
	local E1Ready = self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0
	if mode == "Harass" then
		E1Ready = self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.mana == 0
	end
	
	if myHero.mana > 0 or not E1Ready then
		if self.Menu.MiscSet.Pred.Change:Value() == 1 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, R2spellData)
			if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
				Control.CastSpell(HK_R, pred.CastPos)				
			end
		else
			self:CastRGGPred(unit)	
		end
	elseif E1Ready then 
		self:CastE1Smart(unit)
	end
end	

function Yone:CastRAOE(unit)
	local mode = GetMode()
	local E1Ready = self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0
	if mode == "Harass" then
		E1Ready = self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.mana == 0
	end
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, R2spellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
			if pred.HitCount >= self.Menu.ComboSet.R.RCount:Value() then
				if myHero.mana > 0 or not E1Ready then
					Control.CastSpell(HK_R, pred.CastPos)
				elseif E1Ready then 
					self:CastE1Smart(unit)
				end
			end				
		end
	else						-- GG-AOE-Prediction --
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.8, Radius = 120, Range = 1200, Speed = 1500, Collision = false})
		local minhitchance = self.Menu.MiscSet.Pred.PredR:Value()+1
		local aoeresult = RPrediction:GetAOEPrediction(myHero)
		local bestaoe = nil
		local bestcount = 0
		local bestdistance = 1000
	   
		for i = 1, #aoeresult do
			local aoe = aoeresult[i]
			if aoe.HitChance >= minhitchance and aoe.TimeToHit <= 0.8 and aoe.Count >= self.Menu.ComboSet.R.RCount:Value() then
				if aoe.Count > bestcount or (aoe.Count == bestcount and aoe.Distance < bestdistance) then
					bestdistance = aoe.Distance
					bestcount = aoe.Count
					bestaoe = aoe
				end
			end
		end
		
		if bestaoe then
			if myHero.mana > 0 or not E1Ready then
				Control.CastSpell(HK_R, bestaoe.CastPosition)
			elseif E1Ready then 
				self:CastE1Smart(unit)
			end			 
		end	
	end
end	

function Yone:CastQAOE(unit)
	local mode = GetMode()
	local E1Ready = self.Menu.ComboSet.E.UseE1:Value() and Ready(_E) and myHero.mana == 0
	if mode == "Harass" then
		E1Ready = self.Menu.Harass.UseE:Value() and Ready(_E) and myHero.mana == 0
	end
	
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, QspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredQ:Value(), pred.HitChance) then
			if pred.HitCount >= 2 then
				if myHero.mana > 0 or not E1Ready then
					Control.CastSpell(HK_Q, pred.CastPos)
				elseif E1Ready then 
					self:CastE1Smart(unit)
				end
			end	
		end
	else						-- GG-AOE-Prediction --
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.35, Radius = 120, Range = 900, Speed = 1700, Collision = false})
		local minhitchance = self.Menu.MiscSet.Pred.PredQ:Value()+1
		local aoeresult = QPrediction:GetAOEPrediction(myHero)
		local bestaoe = nil
		local bestcount = 0
		local bestdistance = 1000
	   
		for i = 1, #aoeresult do
			local aoe = aoeresult[i]
			if aoe.HitChance >= minhitchance and aoe.TimeToHit <= 0.4 and aoe.Count >= 2 then
				if aoe.Count > bestcount or (aoe.Count == bestcount and aoe.Distance < bestdistance) then
					bestdistance = aoe.Distance
					bestcount = aoe.Count
					bestaoe = aoe
				end
			end
		end
		
		if bestaoe then
			if myHero.mana > 0 or not E1Ready then
				Control.CastSpell(HK_Q, bestaoe.CastPosition)
			elseif E1Ready then 
				self:CastE1Smart(unit)
			end			 
		end
	end	
end	

function Yone:CastQGGPred(unit)
	local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.35, Radius = 120, Range = 900, Speed = 1700, Collision = false})
	QPrediction:GetPrediction(unit, myHero)
	if QPrediction:CanHit(self.Menu.MiscSet.Pred.PredQ:Value()+1) then
		Control.CastSpell(HK_Q, QPrediction.CastPosition)
	end	
end

function Yone:CastQShortGGPred(unit)
	local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.35, Radius = 100, Range = 475, Speed = 1700, Collision = false})
	QPrediction:GetPrediction(unit, myHero)
	if QPrediction:CanHit(2) then
		Control.CastSpell(HK_Q, QPrediction.CastPosition)
	end	
end

function Yone:CastWGGPred(mintargets, maxtimetohit)
    local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.3, Radius = 300, Range = 600, Speed = 2000, Collision = false})
	local minhitchance = self.Menu.MiscSet.Pred.PredW:Value()+1
    local aoeresult = WPrediction:GetAOEPrediction(myHero)
    local bestaoe = nil
    local bestcount = 0
    local bestdistance = 1000
   
	for i = 1, #aoeresult do
        local aoe = aoeresult[i]
        if aoe.HitChance >= minhitchance and aoe.TimeToHit <= 0.5 and aoe.Count >= 2 then
            if aoe.Count > bestcount or (aoe.Count == bestcount and aoe.Distance < bestdistance) then
                bestdistance = aoe.Distance
                bestcount = aoe.Count
                bestaoe = aoe
            end
        end
    end
    
	if bestaoe then
        Control.CastSpell(HK_W, bestaoe.CastPosition) 
    end
end

function Yone:CastRGGPred(unit)
	local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.8, Radius = 120, Range = 1200, Speed = 1500, Collision = false})
	RPrediction:GetPrediction(unit, myHero)
	if RPrediction:CanHit(self.Menu.MiscSet.Pred.PredR:Value()+1) then
		Control.CastSpell(HK_R, RPrediction.CastPosition)			
	end
end
 
function Yone:Draw()
	if myHero.dead then return end
	
	if self.Menu.MiscSet.Drawing.DrawR:Value() and Ready(_R) then
		Draw.Circle(myHero, 1000, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.MiscSet.Drawing.DrawQ:Value() and Ready(_Q) then
		if myHero:GetSpellData(_Q).name == "YoneQ3" then
			Draw.Circle(myHero, 950, 1, Draw.Color(225, 225, 0, 10))
		else
			Draw.Circle(myHero, 475, 1, Draw.Color(225, 225, 0, 10))
		end
	end
	if self.Menu.MiscSet.Drawing.DrawW:Value() and Ready(_W) then
		Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 125, 10))
	end
	
	if self.Menu.MiscSet.Drawing.Kill:Value() then  	
		if target == nil then return end

		if IsValid(target) then
			local EnemyCount = GetEnemyCount(2000, myHero)
			if EnemyCount == 1 then
				local FullDmg = CalcFullDmg(target)
				local DrawDamage = math.floor(FullDmg.CurrentDamage)
				local DrawPossibleDamage = math.floor(FullDmg.PossibleDamage)
				local DrawTargetHealth = math.floor(target.health)
				local DrawMaxTargetHealth = math.floor(target.maxHealth)
				if FullDmg.CurrentDamage >= target.health then
					Draw.Text("Kill Him  " .. DrawDamage .. "/" .. DrawTargetHealth, 15, target.pos2D.x, target.pos2D.y-10, Draw.Color(0xFF00FF00))
				else
					Draw.Text("" .. DrawDamage .. "/" .. DrawTargetHealth, 15, target.pos2D.x, target.pos2D.y-10, Draw.Color(0xFFff0000))
				end
				if FullDmg.PossibleDamage >= target.health then
					Draw.Text("Max Damage  " .. DrawPossibleDamage .. "/" .. DrawTargetHealth, 15, target.pos2D.x, target.pos2D.y+6, Draw.Color(0xFFcc5500))
				end
			end
		end	
	end	
end

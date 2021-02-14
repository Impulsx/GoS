local QStacks = 0 
local QLastCast  = Game.Timer()
local WRange = 260
local Flash = 	myHero:GetSpellData(SUMMONER_1).name:find("Flash") and {Index = SUMMONER_1, Key = HK_SUMMONER_1} or
				myHero:GetSpellData(SUMMONER_2).name:find("Flash") and {Index = SUMMONER_2, Key = HK_SUMMONER_2} or nil

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
    local pos = pos.pos
	local count = 0
	for i = 1, GameHeroCount() do 
	local hero = GameHero(i)
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

local function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff
		end
	end
	return nil
end

local function ForceTarget(unit)
	_G.SDK.Orbwalker.ForceTarget = unit
end

local function GetTurrets(range)
	return _G.SDK.ObjectManager:GetTurrets(range)
end

local function OnPostAttack(fn)
	_G.SDK.Orbwalker:OnPostAttack(fn)
end

local function OnPreMovement(fn)
	_G.SDK.Orbwalker:OnPreMovement(fn)
end
 
local function OnPreAttack(fn)
	_G.SDK.Orbwalker:OnPreAttack(fn)
end	

local function Orbwalk()
	_G.SDK.Orbwalker:Orbwalk()
end

local function ResetAutoAttack()
	_G.SDK.Orbwalker:__OnAutoAttackReset()
end

local function IsUnderTurret(pos, team)
    local turrets = GetTurrets(GetDistance(myHero.pos, pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if GetDistance(turret.pos, pos) <= 915 and turret.team == team then
            return turret
        end
    end
end

local function GetPassive()        
	return 0.2 + math.floor(myHero.levelData.lvl/3) * 0.05
end

local function TotalDamage(target)
	local damage = 0
	if Ready(_Q) or HasBuff(myHero, "RivenTriCleave") then
		local Qleft = 3 - QStacks 
		local Qpassive = Qleft * (1+GetPassive())            
		damage = damage + getdmg("Q", target, myHero) * (Qleft + Qpassive)
	end
	if Ready(_W) then
		damage = damage + getdmg("W", target, myHero)
	end
	if Ready(_R) then
		damage = damage + getdmg("R", target, myHero)
	end
	damage = damage + getdmg("AA", target, myHero)*2
	return damage        
end

local function GetTrueAttackRange(unit, target)
    local extra = target and target.boundingRadius or 0
    return unit.range + unit.boundingRadius + extra
end

local function IsFacing(unit, p2)
    p2 = p2 or myHero
    p2 = p2.pos or p2
    local V = unit.pos - p2
    local D = unit.dir
    local Angle = 180 - math.deg(math.acos(V * D / (V:Len() * D:Len())))
    if math.abs(Angle) < 80 then
        return true
    end
end

function LoadScript() 
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})	
	Menu:MenuElement({name = " ", drop = {"Ported from Rman/ProjectWinRate"}})	
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR1", name = "[R1]", value = true})
    Menu.Combo:MenuElement({id = "DmgPercent", name = "[R1] Min. Damage to Cast", value = 100, min = 50, max = 200, identifier = "%"})
    Menu.Combo:MenuElement({id = "MinHealth", name = "[R1] Min. Enemy Health to Cast", value = 5, min = 1, max = 100, identifier = "%"})
	Menu.Combo:MenuElement({id = "UseR2", name = "[R2]", value = true})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = false})	
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = false})	
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = false})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = false})		
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = false})	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = false})	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = false})	 
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.ks:MenuElement({id = "UseR2", name = "[R2]", value = true})

	--FleeMenu
	Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})         	
	Menu.Flee:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Flee:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Flee:MenuElement({id = "UseE", name = "[E]", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R2]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--MiscMenu
	Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})         	
	Menu.Misc:MenuElement({name = " ", drop = {"Misc Settings [Q]"}})
	Menu.Misc:MenuElement({id = "Alive", name = "Keep Alive", value = false})	
    Menu.Misc:MenuElement({id = "Delay", name = "Animation Cancelling", type = MENU})	
	Menu.Misc.Delay:MenuElement({id = "Q1", name = "Extra Q1 Delay", value = 100, min = 0, max = 200})
	Menu.Misc.Delay:MenuElement({id = "Q2", name = "Extra Q2 Delay", value = 100, min = 0, max = 200})
	Menu.Misc.Delay:MenuElement({id = "Q3", name = "Extra Q3 Delay", value = 100, min = 0, max = 200}) 	
	Menu.Misc:MenuElement({name = " ", drop = {"Misc Settings [W]"}})
	Menu.Misc:MenuElement({id = "AutoStun", name = "Auto Stun Nearby", value = 2, min = 0, max = 5, step = 1})
	Menu.Misc:MenuElement({id = "Burst", name = "Burst Settings", type = MENU})
	Menu.Misc.Burst:MenuElement({id = "Flash", name = "Allow Flash On Burst", value = true}) 
	Menu.Misc.Burst:MenuElement({id = "ShyKey", name = "Shy Burst Key", key = string.byte("G")})
	Menu.Misc.Burst:MenuElement({id = "WerKey", name = "Werhli Burst Key", key = string.byte("T")})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "Dmg", name = "Draw if Killable Enemy", value = true})	


	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 150, Range = 1150, Speed = 1600, Collision = false
	}
	
	RspellData = {speed = 1600, range = 1150, delay = 0.25, radius = 150, collision = {nil}, type = "linear"}	
	
	Callback.Add("Draw", function()
		if myHero.dead then return end	
		if Menu.Drawing.Dmg:Value() then
            for i, enemy in pairs(GetEnemyHeroes()) do
				if enemy and IsValid(enemy) then
					local dmg = TotalDamage(enemy)               
					if dmg >= enemy.health then
						local screenPos = enemy.pos:To2D()
						DrawText("Killable", 20, screenPos.x - 30, screenPos.y, DrawColor(255,255,0,0))
					end	
				end
			end	
		end
	end)
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("Tick",function() OnProcessSpell() end)
	Callback.Add("Tick",function() OnSpellLoop() end)
	Callback.Add("WndMsg",function(msg, param) OnWndMsg(msg, param) end)        
	OnPreAttack(function(...) FOnPreAttack(...) end)
	OnPostAttack(function(...) FOnPostAttack(...) end)
	OnPreMovement(function(...) FOnPreMovement(...) end) 	
end

function Tick()

	if MyHeroNotReady() then return end
	UpdateSpells()

	if GetActiveBurst() ~= 0 then return end
	Auto()
	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()		
	elseif Mode == "Clear" then
		Clear()
	elseif Mode == "Flee" then
		Flee()		
	end		
end

function UpdateSpells()
	if QStacks ~= 0 and Game.Timer() - QLastCast > 3.8 then QStacks = 0 end
	if IsR2() then WRange = 330 else WRange = 260 end
end

function GetActiveBurst()
	if Menu.Misc.Burst.ShyKey:Value() then            
		ShyCombo()
		return 1
	elseif Menu.Misc.Burst.WerKey:Value() then
		WerCombo()
		return 2
	end
	return 0
end

function OnWndMsg(msg, param)
	DelayAction(function() UpdateItems() end, 0.1)
	if msg ~= 257 then return end
	--
	local spell
	if param == HK_Q then 
		spell = "RivenTriCleave"                   
	elseif param == HK_E then 
		spell = "RivenFeint"                   
	end                
	if not spell then return end
	--           
	if GetMode() == "Combo" then
		OnProcessSpellCombo(spell)
	elseif GetActiveBurst() == 1 then
		OnProcessSpellShy(spell)
	elseif GetActiveBurst() == 2 then
		OnProcessSpellWer(spell)
	end           
end

local itemID = {Youmuu = 3142, Tiamat = 3077, Hydra = 3074, Titanic = 3748}
local itemName = {[3142] = "Youmuu", [3077] = "Tiamat", [3074] = "Hydra", [3748] = "Titanic"}
function UpdateItems()              
	for i = ITEM_1, ITEM_7 do
		local id = myHero:GetItemData(i).itemID
		local name = itemName[id]
		if name then                
			if (self[name] and i == self[name].Index and id ~= itemID[name]) then self[name] = nil end                 
			self[name] = {Index = i, Key = ItemHotKey[i]}                
		end    
	end
end

function FOnPreMovement(args)
	if MyHeroNotReady() then 
		args.Process = false
		return 
	end 
end

function FOnPreAttack(args) 
	if MyHeroNotReady() then 
		args.Process = false 
		return
	end 
end

function FOnPostAttack()        
	local target = GetTarget(400)
	if MyHeroNotReady() or not IsValid(target) then return end        
	--       
	if GetActiveBurst() == 1 then
		AfterAttackShy(target)
	elseif GetActiveBurst() == 2 then 
		AfterAttackWer(target)
	end
	--
	if GetMode() == "Combo" then
		AfterAttackCombo(target)
	elseif GetMode() == "Harass" then
		AfterAttackHarass(target)    
	end  
end

function Auto() 
	local time = Game.Timer()
	local qBuff = GetBuffData(myHero, "RivenTriCleave")        
	if qBuff and qBuff.expireTime >= time and Menu.Misc.Alive:Value() and Ready(_Q) and qBuff.expireTime - time <= 0.3 and not IsUnderTurret(myHero.pos + myHero.dir * QRange, TEAM_ENEMY) then            
		Control.CastSpell(HK_Q, mousePos)
	end
	--
	local minW = Menu.Misc.AutoStun:Value()
	if minW ~= 0 and Ready(_W) and GetEnemyCount(WRange, myHero) >= minW then
		Control.CastSpell(HK_W)
	end
      
	if IsR2() and (Menu.ks.UseR2:Value() or (Menu.Combo.UseR2:Value() and GetMode() == "Combo")) then
		for i, target in pairs(GetEnemyHeroes()) do
			if IsValid(target) and myHero.pos:DistanceTo(target.pos) < 1100 then                       
				local dmg = getdmg("R", target, myHero)                 
				if dmg > target.health then                        
					CastR2(target)
				end
			end
		end
		--
		local rBuff = GetBuffData(myHero, "rivenwindslashready") 
		if rBuff and rBuff.expireTime >= time and rBuff.expireTime - time <= 1 or myHero.health/myHero.maxHealth <= 0.2 then
			local targ = GetTarget(1100)
			if IsValid(targ) then
				CastR2(targ) 
			end	
		end
	end                              
end

function Combo()
	local target = GetTarget(900) 
	if not target or not IsValid(target) then return end
	--
	local attackRange, dist = GetTrueAttackRange(myHero), GetDistance(target.pos, myHero.pos)
	if Menu.Combo.UseE:Value() and Ready(_E) and dist <= 600 and dist > attackRange then
		CastE(target)
	end

	if Menu.Combo.UseQ:Value() and Ready(_Q) and dist <= attackRange + 275 and dist > attackRange and Game.Timer() - QLastCast > 1.1 and not myHero.pathing.isDashing then
		CastQ(target)            
	end
	
	if Menu.Combo.UseW:Value() and Ready(_W) and dist <= WRange then
		CastW(target) 
	end

	if Menu.Combo.UseR1:Value() and Ready(_R) and dist <= 600 and target.health < TotalDamage(target) * Menu.Combo.DmgPercent:Value()/100 then
		CastR1(target)
	end        
end

function OnProcessSpellCombo(spell)
	local target = GetTarget(1100)
	if not (spell and target) or not IsValid(target) then return end
	local dist = GetDistance(target.pos, myHero.pos)
	if spell:find("Tiamat") then
		if Menu.Combo.UseW:Value() and Ready(_W) and dist <= WRange then
			Control.CastSpell(HK_W)                
		elseif Ready(_Q) and dist <= 400 then
			CastQ(target)             
		end
	elseif spell:find("RivenMartyr") then
		if Menu.Combo.UseR2:Value() and Ready(_R) and IsR2() then
			CheckCastR2(target)
		end
	elseif spell:find("RivenFeint") then
		if Menu.Combo.UseR1:Value() and Ready(_R) and dist <= 600 and target.health < TotalDamage(target) * Menu.Combo.DmgPercent:Value()/100 then
			CastR1(target)
		elseif Menu.Combo.UseW:Value() and Ready(_W) and dist <= WRange then
			Control.CastSpell(HK_W) 
		elseif Ready(_Q) and dist <= 400 then
			CastQ(target)
		elseif Menu.Combo.UseR2:Value() and Ready(_R) and IsR2() then
			CheckCastR2(target)
		end
	elseif spell:find("RivenFengShuiEngine") then
		if Menu.Combo.UseW:Value() and Ready(_W) and dist <= WRange then
			Control.CastSpell(HK_W)
		end
	elseif spell:find("RivenIzunaBlade") and QStacks == 2 then
		if Ready(_Q) and dist <= 400 and myHero.attackData.state ~= STATE_WINDUP then
			CastQ(target)
		end
	end
end

function AfterAttackCombo(target)
	local dist = GetDistance(target.pos, myHero.pos)
	if Menu.Combo.UseQ:Value() and Ready(_Q) and dist <= 400 then
		CastQ(target)           
	elseif Menu.Combo.UseR2:Value() and Ready(_R) and Ready(_Q) then
		CheckCastR2(target)
	elseif Menu.Combo.UseW:Value() and Ready(_W) and dist <= WRange then
		CastW(target)
	elseif Menu.Combo.UseE:Value() and not Ready(_Q) and not Ready(_W) and Ready(_E) and dist <= 400 then
		CastE(target)
	end
end

function Harass() 
	local target = GetTarget(900) 
	if not target or not IsValid(target) then return end
	local attackRange, dist = GetTrueAttackRange(myHero), GetDistance(target.pos, myHero.pos)
	if Menu.Harass.UseE:Value() and Ready(_E) and dist <= 600 and dist > attackRange then
		CastE(target)
	end        
	if Menu.Harass.UseQ:Value() and Ready(_Q) and dist <= attackRange + 275 and dist > attackRange and Game.Timer() - QLastCast > 1.1 and not myHero.pathing.isDashing then
		CastQ(target)
	end
	if Menu.Harass.UseW:Value() and Ready(_W) and dist <= WRange then
		CastW(target)
	end        
end

function AfterAttackHarass(target)
	local dist = GetDistance(target.pos, myHero.pos)
	if Menu.Harass.UseQ:Value() and Ready(_Q) and dist <= 400 then
		CastQ(target)
	elseif Menu.Harass.UseW:Value() and Ready(_W) and dist <= WRange then
		CastW(target)
	elseif Menu.Harass.UseE:Value() and not Ready(_Q) and not Ready(_W) and Ready(_E) and dist <= 400 then
		CastE(target)
	end
end

function Clear()
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)              
		if myHero.pos:DistanceTo(minion.pos) <= 325 and minion.team == TEAM_JUNGLE and IsValid(minion) then
			local qJungle, wJungle, eJungle = Ready(_Q) and Menu.JClear.UseQ:Value(), Ready(_W) and Menu.JClear.UseW:Value(), Ready(_E) and Menu.JClear.UseE:Value()
			if qJungle and myHero.pos:DistanceTo(minion.pos) <= 275 then                
				CastQ(minion); return
			elseif wJungle and myHero.pos:DistanceTo(minion.pos) <= WRange then                
				PressKey(HK_W); return
			elseif eJungle then                
				PressKey(HK_E); return
			end            

		else        
			
			if myHero.pos:DistanceTo(minion.pos) <= 275 and minion.team == TEAM_ENEMY and IsValid(minion) then          		
				local qClear, wClear, eClear = Ready(_Q) and Menu.Clear.UseQ:Value(), Ready(_W) and Menu.Clear.UseW:Value(), Ready(_E) and Menu.Clear.UseE:Value()                          
				if wClear and myHero.pos:DistanceTo(minion.pos) <= WRange and getdmg("W", minion, myHero) >= minion.health then                
					PressKey(HK_W); return
				elseif qClear and getdmg("Q", minion, myHero)*3 >= minion.health then                
					CastQ(minion); return 
				elseif eClear and myHero.pos:DistanceTo(minion.pos) <= 325 then                
					PressKey(HK_E); return					
				end         
			end            
		end
    end  
end

function Flee() 
	Orbwalk()
	DelayAction(function()
		if Ready(_W) and Menu.Flee.UseW:Value() and GetEnemyCount(WRange, myHero) >= 1 then
			Control.CastSpell(HK_W)
		elseif Ready(_E) and Menu.Flee.UseE:Value() then                
			PressKey(HK_E) 
		elseif Ready(_Q) and Menu.Flee.UseQ:Value() then                 
			PressKey(HK_Q)
		end      
	end, 0.2)        
end

function ShyCombo()      
	local enemy = GetTarget(1500)        
	
	if enemy and GetDistance(enemy.pos, myHero.pos) <= GetTrueAttackRange(myHero) and IsValid(enemy) then
		Orbwalker.ForceTarget = enemy
	else
		Orbwalker.ForceTarget = nil
	end 
	Orbwalk()        
	if not enemy or not IsValid(enemy) then return end        
	local dist = GetDistance(enemy.pos, myHero.pos)
	
	if Flash and Ready(Flash.Index) and Menu.Misc.Burst.Flash:Value() then
		if dist < 775 then
			if Ready(_E) then                    
				Control.KeyDown(HK_E)
				DelayAction(function() Control.KeyUp(HK_E) end, 0.01)                   
			end
			if Ready(_R) and IsR1() then
				DelayAction(function() Control.CastSpell(HK_R) end, 0.05)
			end                
			if Ready(_W) and Ready(Flash.Index) and dist > 425 then
				DelayAction(function()
					local delay = (Game.Latency() < 60 and 0) or 0.1 + Game.Latency()/1000
					DelayAction(function() Control.CastSpell(HK_W) end, delay)                                                        
					Control.CastSpell(Flash.Key, enemy.pos:Extended(myHero.pos, 50))                                                                       
				end, 0.1)
			end
			if Ready(_W) and dist < WRange then
				DelayAction(function() Control.CastSpell(HK_W) end, 0.15)
			end
			if Ready(_R) and IsR2() and dist < 1100 then
				DelayAction(function() Control.CastSpell(HK_R, enemy.pos) end, 0.3)
			end
			if Ready(_Q) and dist < 275 then
				DelayAction(function() Control.CastSpell(HK_Q, enemy) end, 0.6)
			end
		end
		
	elseif dist < 425 then
		if IsValid(enemy) then
			if Ready(_E) then
				Control.KeyDown(HK_E)
				DelayAction(function() Control.KeyUp(HK_E) end, 0.01)
			end
			if Ready(_R) and IsR1() then
				DelayAction(function() Control.CastSpell(HK_R) end, 0.05)              
			end
			if Ready(_W) and dist < WRange then
				DelayAction(function() Control.CastSpell(HK_W) end, 0.1)
			end
			if Ready(_R) and IsR2() and dist < 1100 then
				DelayAction(function() Control.CastSpell(HK_R, enemy.pos) end, 0.3)
			end
			if Ready(_Q) and dist < 275 then
				DelayAction(function() Control.CastSpell(HK_Q, enemy) end, 0.6)
			end
		end
	end
end

function OnProcessSpellShy(spell)
	local target = GetTarget(1500)
	if not (spell and target) or not IsValid(target) then return end
	local dist = GetDistance(target.pos, myHero.pos)       
	
	if spell:find("Tiamat") then            
		if Ready(_W) and dist <= WRange then
			Control.CastSpell(HK_W)                
		elseif Ready(_Q) and dist <= 400 then
			CastQ(target)
		end        
	elseif spell:find("RivenFeint") then            
		if Ready(_R) and IsR1() then
			Control.CastSpell(HK_R)
		elseif Ready(_W) and dist <= WRange then
			Control.CastSpell(HK_W)
		end
	elseif spell:find("RivenMartyr") then            
		if Ready(_R) and IsR2() then
			Control.CastSpell(HK_R, target.pos)
		elseif Ready(_Q) and dist <= 400 then
			CastQ(target)
		end
	elseif spell:find("RivenIzunaBlade") and QStacks ~= 2 then            
		if Ready(_Q) and dist <= 400 then
			CastQ(target)
		end
	end
end

function AfterAttackShy(target)         
	local dist = GetDistance(target.pos, myHero.pos)
	if Ready(_W) and dist <= WRange then
		Control.CastSpell(HK_W)
	elseif Ready(_R) and IsR2() then
		Control.CastSpell(HK_R, target.pos)
	elseif not Ready(_R) and not Ready(_W) and Ready(_Q) and dist <= 275 then
		CastQ(target)           
	end
end

function WerCombo()
	local enemy = GetTarget(1200)        
	
	if enemy and GetDistance(enemy.pos, myHero.pos) <= GetTrueAttackRange(myHero) and IsValid(enemy) then
		Orbwalker.ForceTarget = enemy
	else
		Orbwalker.ForceTarget = nil
	end 
	Orbwalk()        
	if not enemy or not IsValid(enemy) then return end 
	local dist = GetDistance(enemy.pos, myHero.pos)  
	
	--
	if Ready(_R) and IsR1() then
		DelayAction(function() Control.CastSpell(HK_R) end, 0.01)
	end
	
	if Flash and Ready(Flash.Index) and Menu.Misc.Burst.Flash:Value() and dist > 600 then
		if dist < 1000 then                
			if not IsR2() then return end
			if Ready(_E) then                    
				Control.KeyDown(HK_E)
				DelayAction(function() Control.KeyUp(HK_E) end, 0.01)                 
			end
			if Ready(_R) then
				DelayAction(function() Control.CastSpell(HK_R, enemy.pos) end, 0.1)
			end                                
			if Ready(_W) and Ready(Flash.Index) and GetDistance(myHero.pos, enemy.pos) > 425 then
				DelayAction(function()
					if not Ready(_R) then
						local delay = (Game.Latency() < 60 and 0) or 0.1 + Game.Latency()/1000
						DelayAction(function() Control.CastSpell(HK_W) end, delay)                                                        
						Control.CastSpell(Flash.Key, enemy.pos + (myHero.pos-enemy.pos):Normalized() * 50)
					end                                                                       
				end, 0.35)
			end
			if Ready(_W) and dist < WRange then
				DelayAction(function() Control.CastSpell(HK_W) end, 0.4)
			end
			if Ready(_Q) and dist < 1100 then
				DelayAction(function() CastQ(enemy) end, 0.45)
			end              
		end
		
	elseif dist < 600 then
		if not IsR2() then return end
		if Ready(_E) then                    
			Control.KeyDown(HK_E)
			DelayAction(function() Control.KeyUp(HK_E) end, 0.01)                   
		end
		if Ready(_R) then
			DelayAction(function() Control.CastSpell(HK_R, enemy.pos) end, 0.1)
		end                      
		if Ready(_W) and dist < WRange then
			DelayAction(function()
				Control.CastSpell(HK_W)
			end, 0.2)
		end
		if Ready(_Q) and dist < 1100 then
			DelayAction(function() CastQ(enemy) end, 0.25)
		end
	end
end

function OnProcessSpellWer(spell)
	local target = GetTarget(1100)
	if not (spell and target) or not IsValid(target) then return end      
	local dist = GetDistance(target.pos, myHero.pos)
	
	if spell:find("Tiamat") then            
		if Ready(_W) and dist <= WRange then
			Control.CastSpell(HK_W)
		elseif Ready(_Q) and dist <= 400 then
			CastQ(target)
		end        
	elseif spell:find("RivenFeint") then            
		if Ready(_R) and IsR2() then
			Control.CastSpell(HK_R, target.pos)
		elseif Ready(_W) and dist <= WRange then
			Control.CastSpell(HK_W)
		end
	elseif spell:find("RivenMartyr") then            
		if Ready(_Q) and dist <= 400 then
			CastQ(target)
		end
	elseif spell:find("RivenIzunaBlade") and QStacks ~= 2 then            
		if Ready(_Q) and dist <= 400 then
			CastQ(target)
		end
	end
end

function AfterAttackWer(target)
	local dist = GetDistance(target.pos, myHero.pos)
	if Ready(_R) and IsR2() then
		Control.CastSpell(HK_R, target.pos)
	elseif Ready(_W) and dist <= WRange then
		Control.CastSpell(HK_W)       
	elseif Ready(_Q) and dist <= 275 then
		CastQ(target)           
	end
end

function OnSpellLoop()
	local time = Game.Timer()        
	if not Ready(_Q) then
		local spellQ = myHero:GetSpellData(_Q)  
		for i= 1, 3 do
			local i3 = i ~= 3
			if (i3 and spellQ.cd or 0.25) + time - spellQ.castTime  < 0.1 and (i3 and i or 0) == spellQ.ammo and (i3 or QStacks ~= 0) and QStacks ~= i then 
				--print("Q"..i.." Cast")
				QLastCast = time
				QStacks = i            
				ResetQ(i);return               
			end
		end
	end  
end

local lastSpell = {"Spell Reset", Game.Timer()}
function OnProcessSpell()
	local spell = myHero.activeSpell
	local time = Game.Timer()
	if time - lastSpell[2] > 1 then
		lastSpell = {"Spell Reset", time}
	end      
	if spell.valid and spell.name ~= lastSpell[1] then            
		if GetMode() == "Combo" then
			OnProcessSpellCombo(spell.name)                
		elseif GetActiveBurst() == 1 then
			OnProcessSpellShy(spell.name)
		elseif GetActiveBurst() == 2 then
			OnProcessSpellWer(spell.name)
		end
		lastSpell = {spell.name, time}
	end        
end

function ResetQ(x)
	if not GetMode() or (GetMode() == "Clear" or GetMode() == "Flee") then return end
	local extraDelay = Menu.Misc.Delay["Q"..x]:Value()       
	DelayAction(function()
		ResetAutoAttack()
		Control.Move(myHero.posTo)            
	end,extraDelay/1000) 
end

function CastQ(targ) 
	local target = targ or mousePos
	if not Ready(_Q) or (_G.SDK.Orbwalker:CanAttack() and GetDistance(targ.pos, myHero.pos) <= GetTrueAttackRange(myHero)) then return end             
	Control.CastSpell(HK_Q, targ)     
end

function CastW(target)
	if not (Ready(_W) and IsValid(target)) then return end
	if QStacks ~= 0 or (QStacks == 0 and not Ready(_Q)) or HasBuff(myHero, "RivenFeint") or not IsFacing(target) then
		Control.CastSpell(HK_W) 
	end
end

function CastE(target)
	if not (Ready(_E) and IsValid(target)) then return end 
	local dist, aaRange = GetDistance(target.pos, myHero.pos), GetTrueAttackRange(myHero)
	if Menu.Combo.UseQ:Value() and Ready(_Q) and dist <= aaRange + 260 and QStacks == 0 then return end
	--
	local qReady, wReady = Ready(_Q), Ready(_W)
	local qRange, wRange, eRange = (qReady and QStacks == 0 and 260 or 0), (wReady and WRange or 0), 325      
	if (dist <= eRange + qRange) or (dist <= eRange + wRange) or (not wReady and not qReady and dist <= eRange + aaRange) then
		Control.CastSpell(HK_E, target.pos) 
	end
end

function CastR1(target)        
	if not (IsValid(target) and IsR1() and Menu.Combo.UseR1:Value()) or target.health/target.maxHealth <= Menu.Combo.MinHealth:Value()/100 then return end
	Control.CastSpell(HK_R)         
end

function CastR2(unit)
	if not (IsValid(unit) and IsR2()) or not Ready(_R) then return end
	local R2Radius = GetDistance(unit.pos, myHero.pos) * 0.8

	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, RData, myHero)
		if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
			Control.CastSpell(HK_R, pred.CastPosition)	
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
			Control.CastSpell(HK_R, pred.CastPos)	
		end
	else
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = R2Radius, Range = 1100, Speed = 1600, Collision = false})
		RPrediction:GetPrediction(unit, myHero)
		if RPrediction:CanHit(Menu.Pred.PredR:Value()+1) then	
			Control.CastSpell(HK_R, RPrediction.CastPosition)	
		end
	end	
end

function CheckCastR2(target)
	if not (IsValid(target) and IsR2()) then return end
	local rDmg, aaDmg = getdmg("R", target, myHero), getdmg("AA", target, myHero)
	--        
	local rBuff = GetBuffData(myHero, "rivenwindslashready") 
	local time = Game.Timer()      
	if Ready(_R) and rBuff and rBuff.expireTime >= time and rBuff.expireTime - time <= 1 or myHero.health/myHero.maxHealth <= 0.2 or (target.health > rDmg + aaDmg * 2 and target.health/target.maxHealth < 0.4) or target.health <= rDmg then
		CastR2(target)
	end        
end

function IsR1()
	return myHero:GetSpellData(_R).name:find("RivenFengShuiEngine")
end

function IsR2()
	return myHero:GetSpellData(_R).name:find("RivenIzunaBlade")
end
	
function PressKey(k)
	Control.KeyDown(k)
	Control.KeyUp(k)
end	
	
	
	

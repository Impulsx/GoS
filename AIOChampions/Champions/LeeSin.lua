
local Forcetarget = nil
local insecTarget = nil
local Wards = {}
local casted, jumped = false, false
local oldPos = nil
local passiveTracker = 0
local LeftMousDown = false
local Flash = 	myHero:GetSpellData(SUMMONER_1).name:find("Flash") and {Index = SUMMONER_1, Key = HK_SUMMONER_1} or
				myHero:GetSpellData(SUMMONER_2).name:find("Flash") and {Index = SUMMONER_2, Key = HK_SUMMONER_2} or nil
local Smite = 	myHero:GetSpellData(SUMMONER_1).name:find("Smite") and {Index = SUMMONER_1, Key = HK_SUMMONER_1} or
				myHero:GetSpellData(SUMMONER_2).name:find("Smite") and {Index = SUMMONER_2, Key = HK_SUMMONER_2} or nil				
local WardKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7}				

local StealTable = {
	SRU_Baron = "StealBaron",
	SRU_RiftHerald = "StealHerald",
	SRU_Dragon_Water = "StealDragon",
	SRU_Dragon_Fire = "StealDragon",
	SRU_Dragon_Earth = "StealDragon",
	SRU_Dragon_Air = "StealDragon",
	SRU_Dragon_Elder = "StealDragon",
	SRU_Blue = "StealBlue",
	SRU_Red = "StealRed",
}

local SmiteDmg = {390 , 410 , 430 , 450 , 480 , 510 , 540 , 570 , 600 , 640 , 680 , 720 , 760 , 800 , 850 , 900 , 950 , 1000}

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

local function GetEnemyAround(pos)
	for i, hero in ipairs(GetEnemyHeroes()) do
		if GetDistance(pos, hero.pos) < 700 and IsValid(hero) then
		return true
		end
	end
	return false
end
 
local function IsFirstCast(x)
    if string.find(myHero:GetSpellData(x).name, 'One') then
        return true
    else
        return false
    end
end

local function GetEnemyTurrets()
	return Turrets
end 

local function Orbwalk()
	_G.SDK.Orbwalker:Orbwalk()
end

local function IsUnderTurret(unit)
	for i, turret in ipairs(GetEnemyTurrets()) do
        local range = (turret.boundingRadius / 2 + 775 + unit.boundingRadius / 2)
        if not turret.dead then 
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local function GetAllyTurrets(unit)
	for i = 1, GameTurretCount() do
		local turret = GameTurret(i)
		local Range = (turret.boundingRadius / 2 + unit.boundingRadius / 2) + 1800
		if turret and turret.isAlly and not turret.dead and turret.pos:DistanceTo(unit.pos) < Range then
			return turret
		end
	end
	return nil
end 

local function getMousePos(range)
    local MyPos = Vector(myHero.pos.x, myHero.pos.y, myHero.pos.z)
    local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
    return MyPos - (MyPos - MousePos):Normalized() * 600
end

local function GetWardSlot()
    for slot = ITEM_1, ITEM_7 do
		if myHero:GetSpellData(slot).name and Ready(slot) and string.find(string.lower(myHero:GetSpellData(slot).name), "trinkettotem") and myHero:GetSpellData(slot).ammo > 0 then
			return slot
		end
    end
    for slot = ITEM_1, ITEM_7 do
		if myHero:GetSpellData(slot).name and Ready(slot) and (string.find(string.lower(myHero:GetSpellData(slot).name), "ward") and not string.find(string.lower(myHero:GetItemData(slot).name), "vision")) and myHero:GetSpellData(slot).ammo > 0 then
			return slot
		end
    end
    for slot = ITEM_1, ITEM_7 do
		if myHero:GetSpellData(slot).name and Ready(slot) and string.find(string.lower(myHero:GetSpellData(slot).name), "ward") and myHero:GetSpellData(slot).ammo > 0 then
			return slot
		end
    end
    return nil
end

local function QDmg(unit)
    return getdmg("Q", unit, myHero, 1)+getdmg("Q", unit, myHero, 2)+getdmg("AA", unit, myHero)
end

local function IsKillable(unit)
	local RDmg = Ready(_R) and getdmg("R", unit, myHero) or 0
	local AADmg = getdmg("AA", unit, myHero)*2
	if unit.health <= RDmg+AADmg then
		return true
	end
	return false
end

local function FullComboDmg(unit)
	local RDmg = Ready(_R) and getdmg("R", unit, myHero) or 0
	local QDmg = Ready(_Q) and (getdmg("Q", unit, myHero, 1)+getdmg("Q", unit, myHero, 2)) or 0
	local EDmg = Ready(_E) and getdmg("E", unit, myHero) or 0
	local AADmg = getdmg("AA", unit, myHero)*2
	local FullDmg = RDmg+QDmg+EDmg+AADmg
	if FullDmg >= unit.health then
		return true
	end
	return false
end

local function CeckBuff()
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff and buff.name == "blindmonkpassive_cosmetic" and buff.count > 0 then
			passiveTracker = buff.count
			return
		end
		passiveTracker = 0
	end	
end

function LoadScript() 
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.06"}})		
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "FullDmg", name = "Ignore Passive if killable (FastCombo)", value = true})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "[R] Finish Enemy", value = true})	
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W] Back", value = true})	
	Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})				
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})		
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         		
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})

	--JungleSteal
	Menu:MenuElement({type = MENU, id = "steal", name = "Jungle Steal"})
	Menu.steal:MenuElement({name = " ", drop = {"Q1 + Q2 + If equipped Smite"}})	
	Menu.steal:MenuElement({id = "key", name = "Steal HotKey", key = string.byte("Z")}) 	
	Menu.steal:MenuElement({id = "StealDragon", name = "Steal Dragon", value = true})	
	Menu.steal:MenuElement({id = "StealBaron", name = "Steal Baron", value = true})	
	Menu.steal:MenuElement({id = "StealHerald", name = "Steal Herald", value = true})	
	Menu.steal:MenuElement({id = "StealRed", name = "Steal Red Buff", value = true})
	Menu.steal:MenuElement({id = "StealBlue", name = "Steal Blue Buff", value = true})	
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--InsecMenu
	Menu:MenuElement({type = MENU, id = "Misc", name = "Insec"})         	
	Menu.Misc:MenuElement({name = " ", drop = {"////WardJump////"}})
	Menu.Misc:MenuElement({id = "Insec3", name = "Use WardJump [Default FleeKey = A]", value = true})
	Menu.Misc:MenuElement({id = "Insec4", name = "Search Ally/Minion near Mouse before Ward", value = true})	
	Menu.Misc:MenuElement({name = " ", drop = {"////INSEC////"}})	
	Menu.Misc:MenuElement({name = " ", drop = {"Insec Logics:"}})
	Menu.Misc:MenuElement({name = " ", drop = {"Ward/Flash behind + Kick to AllyTower or Allies"}})	
	Menu.Misc:MenuElement({id = "Insec1", name = "Ward Insec", key = string.byte("T")})
	Menu.Misc:MenuElement({id = "Insec2", name = "Flash Insec", key = string.byte("G")})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})	
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	


	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25+ping, Radius = 60, Range = 1200, Speed = 1800, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 1800, range = 1200, delay = 0.25+ping, radius = 60, collision = {"minion"}, type = "linear"}	
	
	Callback.Add("Draw", function()				
		if myHero.dead then return end	
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			DrawCircle(myHero, 375, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			local QRange
			if IsFirstCast(_Q) then
				QRange = 1200
			else
				QRange = 1300
			end
			DrawCircle(myHero, QRange, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			local ERange
			if IsFirstCast(_E) then
				ERange = 350
			else
				ERange = 500
			end			
			DrawCircle(myHero, ERange, 1, DrawColor(225, 225, 125, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			local WRange
			if IsFirstCast(_W) then
				WRange = 700
			else
				WRange = 0
			end			
			DrawCircle(myHero, WRange, 1, DrawColor(225, 225, 125, 10))
		end	
	end)
	Callback.Add("Tick", function() Tick() end)
	Callback.Add("WndMsg",function(msg, param) OnWndMsg(msg, param) end)        
end
  
function Tick()
	if MyHeroNotReady() then return end
	OnProcessSpell()
    if Menu.Misc.Insec1:Value() then
		Insec()
    end
    if Menu.Misc.Insec2:Value() then
		FInsec()
    end
    if Menu.steal.key:Value() then
		JSteal()
    end

	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()		
	elseif Mode == "Clear" then
		Clear()
	elseif Mode == "Flee" then
		if Menu.Misc.Insec3:Value() then
			WardJump()
		end	
	end
	Killsteal()
end

function JSteal()
	Orbwalk()
	for i = 1, GameMinionCount() do
		minion = GameMinion(i);
		if minion and IsValid(minion) and minion.team == TEAM_JUNGLE and GetDistance(minion.pos, myHero.pos) < 1150 and StealTable[minion.charName] then
			if not GetEnemyAround(minion.pos) then return end
			local SDmg = Smite and Ready(Smite.Index) and SmiteDmg[myHero.levelData.lvl] or 0
			local QDmg = Ready(_Q) and getdmg("Q", minion, myHero, 1) + getdmg("Q", minion, myHero, 2) or 0
			if minion.health <= SDmg+QDmg then
				StealMinion(StealTable[minion.charName], minion);
			end
		end
	end	
end	

function StealMinion(type, minion)
	if not type then return end
	
	if Menu.steal[type]:Value() then
		if minion.pos2D.onScreen then
			if not IsFirstCast(_Q) and Ready(_Q) then 
				Control.CastSpell(HK_Q) 
			end				
			
			if Smite and Ready(Smite.Index) and GetDistance(minion.pos, myHero.pos) < (500+myHero.boundingRadius+minion.boundingRadius) then
				Control.CastSpell(Smite.Key, minion)
			end			
			
			if IsFirstCast(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
			end			
		end
	end
end

--WardInsec
function Insec()
	if not IsFirstCast(_Q) and Ready(_Q) then 
		Control.CastSpell(HK_Q) 
	end	
	
	if myHero:GetSpellData(_R).currentCd > 2 then return end
	
	local target = GetTarget(2500)
	local insecTarget = Forcetarget or target
	if insecTarget == nil then 
		if GetDistance(mousePos,myHero.pos) > myHero.boundingRadius then 
			Orbwalk()
		end 
		return 
	end
	
    local insecTowards = nil
	if insecTarget and IsValid(insecTarget) then
		local AllyTurret = GetAllyTurrets(insecTarget)
		if AllyTurret then
			insecTowards = AllyTurret.pos
		else
			insecTowards = nil
		end
    end    
	
	if insecTowards == nil then
		for i, unit in ipairs(GetAllyHeroes()) do
			if insecTarget and IsValid(insecTarget) and unit and IsValid(unit) and GetDistance(unit.pos, insecTarget.pos) < 2000 then
				insecTowards = unit.pos
			end
		end
	end
	
	if insecTowards == nil then return end
	local pos = insecTarget.pos
	local movePos = pos + (pos-insecTowards):Normalized() * 300
	
	if GetDistance(movePos, myHero.pos) <= 150 then
		if Control.CastSpell(HK_R, insecTarget) and Ready(_Q) then
			DelayAction(function() 
				local Ppos = PredictPos(insecTarget)
				if IsFirstCast(_Q) and Ppos then
					Control.CastSpell(HK_Q, Ppos) 
				end	
			end, 0.2+ping)					
		end
		return	
		
	elseif GetDistance(movePos, myHero.pos) < 600 then
		slot = GetWardSlot()
		if not slot then return end
		Control.CastSpell(WardKey[slot], movePos)
		DelayAction(function() Jump(movePos, 150, true, true) end,0.1+ping)
		return
		
	elseif GetDistance(movePos, myHero.pos) > insecTarget.boundingRadius+myHero.boundingRadius then 
		Orbwalk()
	end
end

--FlashInsec
function FInsec()    
	if not IsFirstCast(_Q) and Ready(_Q) then 
		Control.CastSpell(HK_Q) 
	end	
	
	if myHero:GetSpellData(_R).currentCd > 1 then return end	
	
	local target = GetTarget(2500)	
	local insecTarget = Forcetarget or target
    if insecTarget == nil then 
		if GetDistance(mousePos, myHero.pos) > myHero.boundingRadius then 
			Orbwalk() 
		end 
		return 
	end
	
    local insecTowards = nil
	if insecTarget and IsValid(insecTarget) then
		local AllyTurret = GetAllyTurrets(insecTarget)
		if AllyTurret then
			insecTowards = AllyTurret.pos
		else
			insecTowards = nil
		end
    end    
	
	if insecTowards == nil then
		for i, unit in ipairs(GetAllyHeroes()) do
			if insecTarget and IsValid(insecTarget) and unit and IsValid(unit) and GetDistance(unit.pos, insecTarget.pos) < 2000 then
				insecTowards = unit.pos
			end
		end
	end	
    
	if insecTowards == nil then return end
	local pos = insecTarget.pos
	local movePos = pos + (pos-insecTowards):Normalized() * 300
	
	if GetDistance(movePos, myHero.pos) <= 150 then
		if Control.CastSpell(HK_R, insecTarget) and Ready(_Q) then
			DelayAction(function() 
				local Ppos = PredictPos(insecTarget)
				if IsFirstCast(_Q) and Ppos then
					Control.CastSpell(HK_Q, Ppos) 
				end	
			end, 0.2+ping)					
		end
		return
		
	elseif GetDistance(movePos, myHero.pos) < 600 then
		if Flash and Ready(Flash.Index) and myHero:GetSpellData(_R).currentCd < 1 then
			Control.CastSpell(Flash.Key, movePos)
		end	
		return		

    elseif GetDistance(movePos, myHero.pos) > insecTarget.boundingRadius+myHero.boundingRadius then 
		Orbwalk()
    end
end

function OnWndMsg(msg, param)
	if msg == WM_LBUTTONDOWN then 
		LeftMousDown = true
    elseif msg == WM_LBUTTONUP then
		LeftMousDown = false
    end
    
	if msg == WM_LBUTTONDOWN then
		local minD = 0
		local starget = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if IsValid(enemy) then
				if GetDistance(enemy.pos, mousePos) <= minD or starget == nil then
					minD = GetDistance(enemy.pos, mousePos)
					starget = enemy
				end
			end
		end
		
		if starget and minD < starget.boundingRadius*2 then
			if Forcetarget and starget.charName == Forcetarget.charName then
				Forcetarget = nil
			else
				Forcetarget = starget
			end
		end
	end
end

function OnProcessSpell(unit, spell)  
    local spell = myHero.activeSpell
    if spell.valid and spell.isAutoAttack then
        lastWindup = Game.Timer()+spell.windup
    end
end

local lastWardTime = 0
function WardJump(unit)
	local Mpos = mousePos
	if Jump2(Mpos, 300, false) and Menu.Misc.Insec4:Value() then
		if Ready(_W) and myHero:GetSpellData(_W).name == "BlindMonkWOne" then
			Jump2(Mpos, 300, true)
			return
		end	
	
	else   

		if casted and jumped then 
			casted, jumped = false, false
		elseif Ready(_W) and myHero:GetSpellData(_W).name == "BlindMonkWOne" then
			if unit then
				local pos = myHero.pos + (myHero.pos-unit.pos):Normalized() * -600
				--DrawCircle(pos, 50, 1, DrawColor(225, 225, 125, 10))
				if Jump(pos, 1000, true, false) then 
					Jump(pos, 1000, true, true)
					return
				else
					local slot = GetWardSlot()
					if not slot or Game.Timer() - lastWardTime < 1 then return end
					lastWardTime = Game.Timer()
					Control.CastSpell(WardKey[slot], pos)
					DelayAction(function() Control.CastSpell(HK_W, pos) end, 0.2+ping)
					casted = true
					return
				end			
			else
				local pos = getMousePos()
				--DrawCircle(pos, 50, 1, DrawColor(225, 225, 125, 10))
				if Jump(pos, 300, true, false) then 
					Jump(pos, 300, true, true)
					return
				else
					local slot = GetWardSlot()
					if not slot or Game.Timer() - lastWardTime < 1 then return end
					if GetDistance(myHero.pos, pos) < 600 then
						lastWardTime = Game.Timer()
						Control.CastSpell(WardKey[slot], pos)
						DelayAction(function() Control.CastSpell(HK_W, pos) end, 0.2+ping)
						casted = true
						return
					end	
				end
			end	
		end
	end	
end

function Jump(pos, range, useWard, cast)
	local pos = Vector(pos)

	if useWard then
		for i = 1, Game.WardCount() do
			local ward = Game.Ward(i)
			if ward and ward.valid and ward.isAlly and GetDistance(ward.pos, pos) <= range and GetDistance(ward.pos, myHero.pos) < 700 then
				if cast then
					Control.CastSpell(HK_W, ward)
					jumped = true
				end	
				return true
			end
		end	
	else
	
		for k, ally in ipairs(GetAllyHeroes()) do
			if ally and IsValid(ally) and GetDistance(ally.pos, pos) <= range and GetDistance(ally.pos, pos) > 400 then
				if cast then			
					Control.CastSpell(HK_W, ally)
					jumped = true
				end	
				return true
			end
		end
		
		for i = 1, GameMinionCount() do
			local minion = GameMinion(i)
			if minion and minion.team == TEAM_ALLY and minion.dead == false and GetDistance(minion.pos, pos) <= range and GetDistance(minion.pos, pos) > 400 then
				if cast then			
					Control.CastSpell(HK_W, minion)
					jumped = true
				end	
				return true
			end
		end
		
		for i = 1, Game.WardCount() do
			local ward = Game.Ward(i)
			if ward and ward.valid and ward.isAlly and GetDistance(ward.pos, pos) <= range and GetDistance(ward.pos, pos) > 400 then
				if cast then
					Control.CastSpell(HK_W, ward)
					jumped = true
				end	
				return true
			end
		end
	end
	return false
end

function Jump2(pos, range, cast)
	local pos = Vector(pos)
	
	for k, ally in ipairs(GetAllyHeroes()) do
		if ally and IsValid(ally) and GetDistance(ally.pos, pos) <= range and GetDistance(ally.pos, myHero.pos) < 900 and GetDistance(ally.pos, myHero.pos) > 350 then			
			if cast and GetDistance(ally.pos, myHero.pos) < 700 then			
				Control.CastSpell(HK_W, ally)
				jumped = true
			end	
			return true
		end
	end
	
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if minion and minion.team == TEAM_ALLY and minion.dead == false and GetDistance(minion.pos, myHero.pos) < 900 and GetDistance(minion.pos, pos) <= range and GetDistance(minion.pos, myHero.pos) > 350 then			
			if cast and GetDistance(minion.pos, myHero.pos) < 700 then			
				Control.CastSpell(HK_W, minion)
				jumped = true
			end	
			return true
		end
	end	
end

function Combo()
    local target = GetTarget(1600)
	if target == nil then return end	
    CeckBuff()
	
	if IsValid(target) then
		
		if FullComboDmg(target) and Menu.Combo.FullDmg:Value() then
			if Menu.Combo.UseW:Value() and Ready(_W) then
				if IsFirstCast(_W) and GetDistance(target.pos, myHero.pos) <= 400 then
					Control.CastSpell(HK_W, myHero)
				elseif not IsFirstCast(_W) and GetDistance(target.pos, myHero.pos) < 400 then	
					Control.CastSpell(HK_W)
				end
			end		
			
			if Menu.Combo.UseE:Value() and Ready(_E) then
				if IsFirstCast(_E) and GetDistanceSqr(target.pos, myHero.pos) < 350 * 350 then
					Control.CastSpell(HK_E)
				elseif not IsFirstCast(_E) and GetDistanceSqr(target.pos, myHero.pos) < 470 * 470 then	
					Control.CastSpell(HK_E)
				end
			end
			
			local RDmg = Ready(_R) and getdmg("R", target, myHero) or 0
			if Menu.Combo.UseR:Value() and target.health < RDmg and GetDistance(target.pos, myHero.pos) < 375 then
				Control.CastSpell(HK_R, target)	
			end	
			
			if Menu.Combo.UseQ:Value() and Ready(_Q) and GetDistance(target.pos, myHero.pos) > 1050 and target.health/target.maxHealth < 0.3 then
				WardJump(target)
			end		
			
			if GetDistance(target.pos, myHero.pos) <= 1300 then
				if Menu.Combo.UseQ:Value() and Ready(_Q) and target.health < QDmg(target) + RDmg then
					if IsFirstCast(_Q) then
						local pos = PredictPos(target)
						if pos then
							Control.CastSpell(HK_Q, pos)
						end	
					
					elseif Ready(_Q) then
						DelayAction(function() Control.CastSpell(HK_Q)  end, 0.33+ping)
					end
				elseif Menu.Combo.UseQ:Value() and Ready(_Q) then
					if IsFirstCast(_Q) then
						local pos = PredictPos(target)
						if pos then
							Control.CastSpell(HK_Q, pos)
						end	
					elseif Ready(_Q) and not IsUnderTurret(target) then
						Control.CastSpell(HK_Q)
					end
					
				elseif Menu.Combo.UseQ:Value() and Ready(_Q) and GetDistance(target.pos, myHero.pos) > myHero.range+myHero.boundingRadius*2 then
					if IsFirstCast(_Q) then
						local pos = PredictPos(target)
						if pos then
							Control.CastSpell(HK_Q, pos)
						end	
					elseif Ready(_Q) and not IsUnderTurret(target) then
						Control.CastSpell(HK_Q)
					end
				end
			end
		else
			if Menu.Combo.UseW:Value() and Ready(_W) then
				if IsFirstCast(_W) and GetDistance(target.pos, myHero.pos) <= 400 then
					Control.CastSpell(HK_W, myHero)
				elseif not IsFirstCast(_W) and GetDistance(target.pos, myHero.pos) < 400 then	
					Control.CastSpell(HK_W)
				end
			end		
			
			if Menu.Combo.UseE:Value() and Ready(_E) and passiveTracker == 0 then
				if IsFirstCast(_E) and GetDistanceSqr(target.pos, myHero.pos) < 350 * 350 then
					Control.CastSpell(HK_E)
				elseif not IsFirstCast(_E) and GetDistanceSqr(target.pos, myHero.pos) < 470 * 470 then	
					Control.CastSpell(HK_E)
				end
			end
			
			local RDmg = Ready(_R) and getdmg("R", target, myHero) or 0
			if Menu.Combo.UseR:Value() and target.health < RDmg and GetDistance(target.pos, myHero.pos) < 375 then
				Control.CastSpell(HK_R, target)	
			end	
			
			if Menu.Combo.UseQ:Value() and Ready(_Q) and GetDistance(target.pos, myHero.pos) > 1050 and target.health/target.maxHealth < 0.3 then
				WardJump(target)
			end		
			
			if GetDistance(target.pos, myHero.pos) <= 1300 then
				if Menu.Combo.UseQ:Value() and Ready(_Q) and target.health < QDmg(target) + RDmg then
					if IsFirstCast(_Q) then
						local pos = PredictPos(target)
						if pos then
							Control.CastSpell(HK_Q, pos)
						end	
					
					elseif Ready(_Q) then
						DelayAction(function() Control.CastSpell(HK_Q)  end, 0.33+ping)
					end
				elseif Menu.Combo.UseQ:Value() and Ready(_Q) and passiveTracker == 0 then
					if IsFirstCast(_Q) then
						local pos = PredictPos(target)
						if pos then
							Control.CastSpell(HK_Q, pos)
						end	
					elseif Ready(_Q) and not IsUnderTurret(target) then
						Control.CastSpell(HK_Q)
					end
					
				elseif Menu.Combo.UseQ:Value() and Ready(_Q) and GetDistance(target.pos, myHero.pos) > myHero.range+myHero.boundingRadius*2 then
					if IsFirstCast(_Q) then
						local pos = PredictPos(target)
						if pos then
							Control.CastSpell(HK_Q, pos)
						end	
					elseif Ready(_Q) and not IsUnderTurret(target) then
						Control.CastSpell(HK_Q)
					end
				end
			end	
		end	
	end	
end

function Harass()
    local target = GetTarget(1300)
	if target == nil then return end
	
	if IsValid(target) then
		if Menu.Harass.UseQ:Value() and Ready(_Q) and IsFirstCast(_Q) then
			local pos = PredictPos(target)
			if pos then
				Control.CastSpell(HK_Q, pos)
			end	
		end
		
		if Menu.Harass.UseQ:Value() and Menu.Harass.UseW:Value() and Jump(target.pos, 700, false, false) and Ready(_W) and IsFirstCast(_W) and not IsFirstCast(_Q) and not IsUnderTurret(target) then
			Control.CastSpell(HK_Q)
		end
		
		if Menu.Harass.UseE:Value() and Ready(_E) and GetDistanceSqr(target.pos, myHero.pos) < 350 * 350 then
			Control.CastSpell(HK_E, target)
		end		
		
		if Menu.Harass.UseW:Value() and GetDistance(target.pos, myHero.pos) < 400 and Ready(_W) and IsFirstCast(_W) and not Ready(_E) then
			if not IsKillable(target) then
				Jump(target.pos, 700, false, true)
			end	
		end
	end	
end

function Killsteal()
    for k, enemy in pairs(GetEnemyHeroes()) do
		if enemy and IsValid(enemy) then
					
			if Menu.ks.UseQ:Value() and Ready(_Q) and enemy.health < getdmg("Q", enemy, myHero, 1) and GetDistance(enemy.pos, myHero.pos) < 1100 then
				if IsFirstCast(_Q) then
					local pos = PredictPos(enemy)
					if pos then
						Control.CastSpell(HK_Q, pos)
					end	
				else
					Control.CastSpell(HK_Q)
				end
				
			elseif Menu.ks.UseQ:Value() and Ready(_Q) and enemy.health < QDmg(enemy) and GetDistance(enemy.pos, myHero.pos) < 1100 then
				if IsFirstCast(_Q) then
					local pos = PredictPos(enemy)
					if pos then
						Control.CastSpell(HK_Q, pos)
					end	
				elseif Ready(_Q) then			  
					Control.CastSpell(HK_Q)
				end
			
			elseif Menu.ks.UseE:Value() and Ready(_E) and enemy.health < getdmg("E", enemy, myHero) and GetDistance(enemy.pos, myHero.pos) < 350 then
				Control.CastSpell(HK_E, enemy)
			
			elseif Menu.ks.UseR:Value() and Ready(_R) and enemy.health < getdmg("R", myHero, enemy) and GetDistance(enemy.pos, myHero.pos) < 375 then
				Control.CastSpell(HK_R, enemy)
			end
		end
    end
end 

function PredictPos(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, QData, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
			return pred.CastPosition
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
			return pred.CastPos
		end
	else
		local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25+ping, Radius = 60, Range = 1200, Speed = 1800, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
			return QPrediction.CastPosition
		end	
	end
	return nil
end

function Clear()
	CeckBuff()
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)              
		if GetDistance(minion.pos, myHero.pos) <= 400 and minion.team == TEAM_JUNGLE and IsValid(minion) and passiveTracker == 0 then
			local wJungle, eJungle = Ready(_W) and Menu.JClear.UseW:Value(), Ready(_E) and Menu.JClear.UseE:Value()
			if wJungle then                
				if IsFirstCast(_W) then
					Control.CastSpell(HK_W, myHero); return
				else
					Control.CastSpell(HK_W); return
				end	
			elseif eJungle then                
				Control.CastSpell(HK_E); return
			end            

		else        
			
			if GetDistance(minion.pos, myHero.pos) <= 400 and minion.team == TEAM_ENEMY and IsValid(minion) and passiveTracker == 0 then          		
				local wClear, eClear = Ready(_W) and Menu.Clear.UseW:Value(), Ready(_E) and Menu.Clear.UseE:Value()                          
				if wClear then                
					if IsFirstCast(_W) then
						Control.CastSpell(HK_W, myHero); return
					else
						Control.CastSpell(HK_W); return
					end
				elseif eClear then                
					Control.CastSpell(HK_E); return					
				end         
			end            
		end
    end  
end

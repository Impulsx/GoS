local function GetEnemyHeroes()
	return Enemies
end 

local function GetAllyHeroes()
	return Allies
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
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

local function KillMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,GameMinionCount() do
	local minion = GameMinion(i)
	local Range = range * range
		if minion.team ~= TEAM_ALLY and minion.dead == false and GetDistanceSqr(pos, minion.pos) < Range then
			local buff = HasBuff(minion, "kalistaexpungemarker")
			local EDmg = getdmg("E", minion, myHero)
			if buff and EDmg >= minion.health then
				count = count + 1
			end	
		end
	end
	return count
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

local ChampTable = {["Blitzcrank"] = {charName = "Blitzcrank"}, ["Skarner"] = {charName = "Skarner"}, ["TahmKench"] = {charName = "TahmKench"}, ["Sion"] = {charName = "Sion"}}
local BoundAlly = nil

function LoadScript() 	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.08"}})	
	
	--AutoQ	
	Menu:MenuElement({type = MENU, id = "AutoQ2", name = "AutoQ"})
	Menu.AutoQ2:MenuElement({id = "UseQ", name = "[Q]Transferring Minion-Stacks to Enemy", value = true})	

	--AutoR 
	Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoR"})
	Menu.AutoR:MenuElement({id = "UseR", name = "Auto[R]Safe Ally", value = true})
	Menu.AutoR:MenuElement({id = "Heal", name = "Hp Ally", value = 20, min = 0, max = 100, identifier = "%"})	

	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "E", name = "ToggleKey[LastHit Minions]", key = 84, toggle = true})
	Menu.AutoE:MenuElement({id = "Emin", name = "[E] If Kill X Minion ", value = 2, min = 1, max = 6, step = 1, identifier = "Minion/s"})
	Menu.AutoE:MenuElement({name = " ", drop = {"---------------------------------------------------"}})	
	Menu.AutoE:MenuElement({id = "E2", name = "[E] Enemy has spears and killable Minion near", value = true})
	Menu.AutoE:MenuElement({name = " ", drop = {"---------------------------------------------------"}})	
	Menu.AutoE:MenuElement({id = "UseE", name = "Panic[E] Enemy if duration runs out", value = true})
	Menu.AutoE:MenuElement({id = "UseEM", name = "min sec before Panic[E]", value = 0.9, min = 0.1, max = 4.0, step = 0.1, identifier = "sec"})
	Menu.AutoE:MenuElement({id = "count", name = "min Spears for Panic[E]", value = 5, min = 0, max = 10, identifier = "Spear/s"})	
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E] if has Target Spear and minion killable", value = true})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
	Menu.Clear:MenuElement({id = "UseE", name = "[E]LastHit", value = true}) 
	Menu.Clear:MenuElement({id = "Emin", name = "[E] If Kill X Minion ", value = 2, min = 1, max = 6, step = 1, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]LastHit", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})				

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 1, drop = {"Gamsteron Prediction", "Premium Prediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})	
	Menu.Drawing:MenuElement({type = MENU, id = "XY", name = "TextPos AutoE"})
	Menu.Drawing.XY:MenuElement({id = "Enable", name = "Draw AutoE Text", value = true})	
	Menu.Drawing.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.Drawing.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})
	Menu.Drawing:MenuElement({type = MENU, id = "HP", name = "TextPos Hp after E"})	
	Menu.Drawing.HP:MenuElement({name = " ", drop = {"After[E] HP / Current HP"}})	
	Menu.Drawing.HP:MenuElement({id = "Stacks", name = "Draw HP Text", value = true})		
	Menu.Drawing.HP:MenuElement({id = "x", name = "Pos: [X]", value = -100, min = -100, max = 100, step = 10})
	Menu.Drawing.HP:MenuElement({id = "y", name = "Pos: [Y]", value = -100, min = -200, max = 100, step = 10})	



	Menu:MenuElement({type = MENU, id = "ally", name = "WomboCombo"})

	DelayAction(function()
	for i, Hero in pairs(GetAllyHeroes()) do
	
		if ChampTable[Hero.charName] then
			Menu.ally:MenuElement({type = SPACE, id = "Tip", name = "Support[Blitzcrank, Skarner, TahmKench, Sion]"})		
			Menu.ally:MenuElement({id = "Champ", name = Hero.charName, value = true})
			Menu.ally:MenuElement({id = "MyHP", name = "Kalista min.Hp to UseR",  value = 40, min = 0, max = 100, step = 1})			
		end
	end 
	end, 0.3)
	

	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1150, Speed = 2100, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	QspellData = {speed = 2100, range = 1150, delay = 0.25, radius = 40, collision = {"minion"}, type = "linear"}	
  	                                           
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
		if myHero.dead then return end	
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 1100, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1150, 1, DrawColor(225, 225, 0, 10))
		end
	
		if Menu.Drawing.XY.Enable:Value() then
			DrawText("AutoLastHit[E]: ", 15, Menu.Drawing.XY.x:Value(), Menu.Drawing.XY.y:Value()+15, DrawColor(255, 225, 255, 0))
			if Menu.AutoE.E:Value() then
				DrawText("ON", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
			else
				DrawText("OFF", 15, Menu.Drawing.XY.x:Value()+85, Menu.Drawing.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
			end
		end
		
		local target = GetTarget(1200)     	
		if target == nil then return end
		local Pos = target.pos:To2D()
		if Menu.Drawing.HP.Stacks:Value() and Ready(_E) and IsValid(target) and target.pos2D.onScreen and Pos.onScreen and HasBuff(target,"kalistaexpungemarker") then		 	
			local damage = getdmg("E", target, myHero)	
			local HpAfterDmg = target.health - damage
				DrawText(" / HP "..math.floor(target.health), 17, Pos.x + Menu.Drawing.HP.x:Value()+50, Pos.y + Menu.Drawing.HP.y:Value(), DrawColor(255, 0, 255, 0))				
			if HpAfterDmg/target.health > 0.5 then 	
				DrawText("HP "..math.floor(HpAfterDmg), 17, Pos.x + Menu.Drawing.HP.x:Value(), Pos.y + Menu.Drawing.HP.y:Value(), DrawColor(255, 0, 255, 0))
			elseif HpAfterDmg/target.health < 0.5 and HpAfterDmg/target.health > 0.3 then
				DrawText("HP "..math.floor(HpAfterDmg), 17, Pos.x + Menu.Drawing.HP.x:Value(), Pos.y + Menu.Drawing.HP.y:Value(), DrawColor(255, 225, 255, 0))
			elseif HpAfterDmg/target.health < 0.3 then
				DrawText("HP "..math.floor(HpAfterDmg), 17, Pos.x + Menu.Drawing.HP.x:Value(), Pos.y + Menu.Drawing.HP.y:Value(), DrawColor(255, 255, 0, 0))
			end	
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Clear" then
		if not Menu.AutoE.E:Value() then
			Clear()
		end	
		JungleClear()
	end	

	if Menu.AutoE.E2:Value() then
		AutoE2()
	end	
	KillMinion()
	KillSteal()
	AutoQ()
	AutoE()		
	AutoR()
	BoundHero()
	WomboCombo()
	
end

function BoundHero()
	if BoundAlly then return end
	
	for i = 1, GameHeroCount() do
		local hero = GameHero(i)
		if not hero.isMe and hero.isAlly and HasBuff(hero,"kalistacoopstrikeally") then
			BoundAlly = hero
		end
	end	
end

function WomboCombo()
local target = GetTarget(2500)     	
if target == nil then return end
	
	if Menu.ally.Champ ~= nil and Menu.ally.Champ:Value() and BoundAlly and myHero.pos:DistanceTo(BoundAlly.pos) <= 1200 and IsValid(BoundAlly) then
		if Ready(_R) and myHero.health/myHero.maxHealth >= Menu.ally.MyHP:Value()/100 then
			
			if BoundAlly.charName == "Blitzcrank" and HasBuff(target, "rocketgrab2") then
				ControlCastSpell(HK_R)
			
			elseif BoundAlly.charName == "Skarner" and HasBuff(target, "SkarnerImpale") then
				ControlCastSpell(HK_R)
			
			elseif BoundAlly.charName == "TahmKench" and HasBuff(target, "tahmkenchwdevoured") then
				ControlCastSpell(HK_R)
			
			elseif BoundAlly.charName == "Sion" and (BoundAlly.activeSpell and BoundAlly.activeSpell.valid and BoundAlly.activeSpell.name == "SionR") then
				DelayAction(function()
				ControlCastSpell(HK_R) 
				end, 0.3)
			end
		end
	end
end

function AutoQ()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1150 and Menu.AutoQ2.UseQ:Value() and Ready(_Q) then
        for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
			if myHero.pos:DistanceTo(minion.pos) <= 1150 and minion.team == TEAM_ENEMY and IsValid(minion) then	
			local QDmg = getdmg("Q", minion, myHero)
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(myHero.pos, target.pos, minion.pos)
				if isOnSegment and (minion.pos.x - pointSegment.x)^2 + (minion.pos.z - pointSegment.y)^2 < (40 + minion.boundingRadius + 15) * (40 + minion.boundingRadius + 15) and HasBuff(minion, "kalistaexpungemarker") and QDmg >= minion.health then 
					ControlCastSpell(HK_Q, target.pos)
				end
			end	
        end
	end
end

function AutoE()
local target = GetTarget(1200)     	
if target == nil then return end
	if Menu.AutoE.UseE:Value() and IsValid(target) and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1100 then	
	local buff = GetBuffData(target, "kalistaexpungemarker")	
		if buff and buff.duration > 0 and buff.duration <= Menu.AutoE.UseEM:Value() and buff.count >= Menu.AutoE.count:Value() then  
			ControlCastSpell(HK_E)				
		end
	end	
end

function AutoE2()
local target = GetTarget(1200)     	
if target == nil then return end
	if IsValid(target) and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1100 then	
	local buff = HasBuff(target, "kalistaexpungemarker")	
	local count = KillMinionCount(1100, myHero)	
		if buff and count >= 1 then  
			ControlCastSpell(HK_E)				
		end
	end	
end

function AutoR()
	if BoundAlly then
		if myHero.pos:DistanceTo(BoundAlly.pos) <= 1200 and IsValid(BoundAlly) and Menu.AutoR.UseR:Value() and Ready(_R) then
			if BoundAlly.health/BoundAlly.maxHealth <= Menu.AutoR.Heal:Value()/100 then
				ControlCastSpell(HK_R)
			end
		end
	end
end

function Combo()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) < 1150 and Menu.Combo.UseQ:Value() and Ready(_Q) then
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
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_ENEMY and IsValid(minion) and Menu.Clear.UseE:Value() then
			if mana_ok and Ready(_E) then
			local count = KillMinionCount(1100, myHero)	
				if count >= Menu.Clear.Emin:Value() then
					ControlCastSpell(HK_E)
				end
			end
		end
	end
end

local function EpicMonster(unit)
	if unit.charName ==
		"SRU_Baron" or unit.charName ==
		"SRU_RiftHerald" or unit.charName ==
		"SRU_Dragon_Water" or unit.charName ==
		"SRU_Dragon_Fire" or unit.charName ==
		"SRU_Dragon_Earth" or unit.charName ==
		"SRU_Dragon_Air" or unit.charName ==		
		"SRU_Dragon_Elder" then
		return true
	end
	return false
end

function JungleClear()	
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_JUNGLE and IsValid(minion) then
        local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100
		local EDmg = getdmg("E", minion, myHero)
            if Menu.JClear.UseE:Value() and mana_ok and Ready(_E) then  
				if EpicMonster(minion) and EDmg/2 >= minion.health then
					ControlCastSpell(HK_E)
				end	
				if not EpicMonster(minion) and EDmg >= minion.health then
					ControlCastSpell(HK_E)
				end	
            end
        end
    end
end

function KillMinion()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_ENEMY and IsValid(minion) then
			if Menu.AutoE.E:Value() and Ready(_E) then
			local count = KillMinionCount(1100, myHero)	
				if count >= Menu.AutoE.Emin:Value() then
					ControlCastSpell(HK_E)
				end
			end
        end
    end
end

function KillSteal()
local target = GetTarget(1300)     	
if target == nil then return end		
	if IsValid(target) then		
		if myHero.pos:DistanceTo(target.pos) <= 1100 and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			if QDmg >= target.health and (EDmg < target.health or not Ready(_E)) then
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
		
		if myHero.pos:DistanceTo(target.pos) <= 1100 and Ready(_E) then
			local EDmg = getdmg("E", target, myHero)
			if EDmg >= target.health then
				ControlCastSpell(HK_E)
			end
		end
	end
end

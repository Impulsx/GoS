local heroes = false
local checkCount = 0 
local menu = 1
local Orb
local _OnWaypoint = {}
local _OnVision = {}
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local spellcast = {state = 1, mouse = mousePos}
local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7,}
local barHeight, barWidth, barXOffset, barYOffset = 8, 103, 0, 0
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local charging = false
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local MyHeroRange = myHero.range + myHero.boundingRadius * 2
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local ControlCastSpell = Control.CastSpell
local GameCanUseSpell = Game.CanUseSpell
local GameTimer = Game.Timer
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local GameObjectCount = Game.ObjectCount
local GameObject = Game.Object
local GameParticleCount = Game.ParticleCount
local GameParticle = Game.Particle
local GameMissileCount = Game.MissileCount
local GameMissile = Game.Missile
local GameIsChatOpen = Game.IsChatOpen
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local MathSqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
_G.LATENCY = 0.05


function LoadUnits()
	for i = 1, GameHeroCount() do
		local unit = GameHero(i); Units[i] = {unit = unit, spell = nil}
		if unit.team ~= myHero.team then TableInsert(Enemies, unit)
		elseif unit.team == myHero.team and unit ~= myHero then TableInsert(Allies, unit) end
	end
	for i = 1, GameTurretCount() do
		local turret = GameTurret(i)
		if turret and turret.isEnemy then TableInsert(Turrets, turret) end
	end
end

local function CheckLoadedEnemyies()
	local count = 0
	for i, unit in ipairs(Enemies) do
        if unit and unit.isEnemy then
		count = count + 1
		end
	end
	return count
end
		
local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and GameCanUseSpell(spell) == 0
end

function GetMode()   
    if Orb == 1 then
        if combo == 1 then
            return 'Combo'
        elseif harass == 2 then
            return 'Harass'
        elseif lastHit == 3 then
            return 'Lasthit'
        elseif laneClear == 4 then
            return 'Clear'
        end
    elseif Orb == 2 then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "LastHit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
    elseif Orb == 3 then
        return GOS:GetMode()
    elseif Orb == 4 then
        return _G.gsoSDK.Orbwalker:GetMode()
	elseif Orb == 5 then
	  return _G.PremiumOrbwalker:GetMode()
	end
	
    if _G.SDK then
        return 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "Clear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] and "Clear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] and "LastHit"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] and "Flee"
		or nil
    
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetMode()
	end
	return nil	
end

function GetTarget(range) 
	if Orb == 1 then
		if myHero.ap > myHero.totalDamage then
			return EOW:GetTarget(range, EOW.ap_dec, myHero.pos)
		else
			return EOW:GetTarget(range, EOW.ad_dec, myHero.pos)
		end
	elseif Orb == 2 and TargetSelector then
		if myHero.ap > myHero.totalDamage then
			return TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
		else
			return TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		end
	elseif _G.GOS then
		if myHero.ap > myHero.totalDamage then
			return GOS:GetTarget(range, "AP")
		else
			return GOS:GetTarget(range, "AD")
        end
    elseif _G.gsoSDK then
		return _G.gsoSDK.TS:GetTarget()
	
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end	
	
	if _G.SDK then
		if myHero.ap > myHero.totalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
		end
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end	
end

local function SetAttack(bool)
	if _G.EOWLoaded then
		EOW:SetAttacks(bool)
	elseif _G.SDK then                                                        
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetAttack(bool)	
	else
		GOS.BlockAttack = not bool
	end

end

local function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetMovement(bool)	
	else
		GOS.BlockMovement = not bool
	end
end

local function GetDistanceSqr(p1, p2)
	if not p1 then return MathHuge end
	p2 = p2 or myHero
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
end

local function GetDistance(p1, p2)
	p2 = p2 or myHero
	return MathSqrt(GetDistanceSqr(p1, p2))
end

local function GetDistance2D(p1,p2)
	return MathSqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local function IsRecalling(unit)
	for i = 1, 63 do
	local buff = unit:GetBuff(i) 
		if buff.count > 0 and buff.name == "recall" and Game.Timer() < buff.expireTime then
			return true
		end
	end 
	return false
end 
	
local function MyHeroNotReady()
    return myHero.dead or GameIsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero)
end

--[[
local currSpell = myHero.activeSpell
if currSpell and currSpell.valid and myHero.isChanneling then
print ("Width:  "..myHero.activeSpell.width)
print ("Speed:  "..myHero.activeSpell.speed)
print ("Delay:  "..myHero.activeSpell.animation)
print ("range:  "..myHero.activeSpell.range)
print ("Name:  "..myHero.activeSpell.name)
end
]]
--[[
for i = 0, myHero.buffCount do
	local buff = myHero:GetBuff(i)
	if buff.name == "" then
	--print(buff.name)
		print("Typ:  "..buff.type)
		print("Name:  "..buff.name)
		print("Start:  "..buff.startTime)
		print("Expire:  "..buff.expireTime)
		print("Dura:  "..buff.duration)
		print("Stacks:  "..buff.stacks)
		print("Count:  "..buff.count)
		print("Id:  "..buff.sourcenID)
		print("SouceName:  "..buff.sourceName)	
	end
end
]]
local IsLoaded = false
Callback.Add("Tick", function()  
	if heroes == false then 
		local EnemyCount = CheckLoadedEnemyies()			
		if EnemyCount < 1 then
			LoadUnits()
		else
			heroes = true
		end
	else	
		if not IsLoaded then
			LoadScript()
			DelayAction(function()
				if not Menu.Pred then return end
				if Menu.Pred.Change:Value() == 1 then
					require('GamsteronPrediction')
				elseif Menu.Pred.Change:Value() == 2 then
					require('PremiumPrediction')
				else
					require('GGPrediction')
				end	
			end, 1)
			IsLoaded = true
		end	
	end	
end)

local DrawTime = false
Callback.Add("Draw", function() 
	if heroes == false then
		Draw.Text(myHero.charName.." is Loading !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 255, 0, 0))
	else
		if not DrawTime then
			Draw.Text(myHero.charName.." is Ready !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 0, 255, 0))
			DelayAction(function()
			DrawTime = true
			end, 4.0)
		end	
	end
end)
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
		if minion.team == TEAM_ENEMY and minion.dead == false and GetDistanceSqr(pos, minion.pos) < Range then
			local buff = HasBuff(minion, "kalistaexpungemarker")
			local EDmg = getdmg("E", minion, myHero)
			if buff and EDmg >= minion.health then
				count = count + 1
			end	
		end
	end
	return count
end

local ChampTable = {["Blitzcrank"] = {charName = "Blitzcrank"}, ["Skarner"] = {charName = "Skarner"}, ["TahmKench"] = {charName = "TahmKench"}, ["Sion"] = {charName = "Sion"}}
local BoundAlly = nil

function LoadScript() 
	HPred()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.11"}})	
	
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
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]LastHit", value = true})	 
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})				

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
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
				Control.CastSpell(HK_R)
			
			elseif BoundAlly.charName == "Skarner" and HasBuff(target, "SkarnerImpale") then
				Control.CastSpell(HK_R)
			
			elseif BoundAlly.charName == "TahmKench" and HasBuff(target, "tahmkenchwdevoured") then
				Control.CastSpell(HK_R)
			
			elseif BoundAlly.charName == "Sion" and (BoundAlly.activeSpell and BoundAlly.activeSpell.valid and BoundAlly.activeSpell.name == "SionR") then
				DelayAction(function()
				Control.CastSpell(HK_R) 
				end, 0.3)
			end
		end
	end
end

function AutoQ()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1150 and Menu.AutoQ2.UseQ:Value() and Ready(_Q) then

		local killCount, nokillCount = HPred:GetLineTargetCount(myHero.pos, target.pos, 0.25, 2100, 80)				
		if killCount >= 1 and nokillCount == 0 then 
			Control.CastSpell(HK_Q, target.pos)	
		end	
	end
end

function AutoE()
local target = GetTarget(1200)     	
if target == nil then return end
	if Menu.AutoE.UseE:Value() and IsValid(target) and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 1100 then	
	local buff = GetBuffData(target, "kalistaexpungemarker")	
		if buff and buff.duration > 0 and buff.duration <= Menu.AutoE.UseEM:Value() and buff.count >= Menu.AutoE.count:Value() then  
			Control.CastSpell(HK_E)				
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
			Control.CastSpell(HK_E)				
		end
	end	
end

function AutoR()
	if BoundAlly then
		if myHero.pos:DistanceTo(BoundAlly.pos) <= 1200 and IsValid(BoundAlly) and Menu.AutoR.UseR:Value() and Ready(_R) then
			if BoundAlly.health/BoundAlly.maxHealth <= Menu.AutoR.Heal:Value()/100 then
				Control.CastSpell(HK_R)
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
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1150, Speed = 2100, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end	
		end		
	end	
end	

function Clear()
	if Ready(_E) and Menu.Clear.UseE:Value() then
	local count = KillMinionCount(1100, myHero)	
		if count >= Menu.Clear.Emin:Value() then
			Control.CastSpell(HK_E)
		end
	end
end

local function EpicMonster(unit)
	if unit.charName == "SRU_Baron" 
		or unit.charName == "SRU_RiftHerald" 
		or unit.charName == "SRU_Dragon_Water" 
		or unit.charName == "SRU_Dragon_Fire" 
		or unit.charName == "SRU_Dragon_Earth" 
		or unit.charName == "SRU_Dragon_Air" 
		or unit.charName ==	"SRU_Dragon_Elder" then
		return true
	else
		return false
	end
end

function JungleClear()	
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if myHero.pos:DistanceTo(minion.pos) <= 1100 and minion.team == TEAM_JUNGLE and IsValid(minion) then
				
            if Menu.JClear.UseE:Value() and Ready(_E) then  	
				if EpicMonster(minion) then
					local EDmg2 = getdmg("E", minion, myHero) / 2
					if EDmg2 > minion.health and HasBuff(minion, "kalistaexpungemarker") then	
						Control.CastSpell(HK_E)
					end	
				else
					local EDmg = getdmg("E", minion, myHero)
					if EDmg > minion.health and HasBuff(minion, "kalistaexpungemarker") then
						Control.CastSpell(HK_E)
					end	
				end	
            end
        end
    end
end

function KillMinion()
	if Menu.AutoE.E:Value() and Ready(_E) then
	local count = KillMinionCount(1100, myHero)	
		if count >= Menu.AutoE.Emin:Value() then
			Control.CastSpell(HK_E)
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
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1150, Speed = 2100, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
					QPrediction:GetPrediction(target, myHero)
					if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
						Control.CastSpell(HK_Q, QPrediction.CastPosition)
					end				
				end	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 1100 and Ready(_E) then
			local EDmg = getdmg("E", target, myHero)
			if EDmg >= target.health then
				Control.CastSpell(HK_E)
			end
		end
	end
end


----------------------------------------------------------------------------
------------------------------HPrediction-----------------------------------
----------------------------------------------------------------------------

class "HPred"

local _tickFrequency = .2
local _nextTick = Game.Timer()


local _OnVision = {}
function HPred:OnVision(unit)
	if unit == nil or type(unit) ~= "userdata" then return end
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {visible = unit.visible , tick = GetTickCount(), pos = unit.pos } end
	if _OnVision[unit.networkID].visible == true and not unit.visible then _OnVision[unit.networkID].visible = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].visible == false and unit.visible then _OnVision[unit.networkID].visible = true _OnVision[unit.networkID].tick = GetTickCount() _OnVision[unit.networkID].pos = unit.pos end
	return _OnVision[unit.networkID]
end

--This must be called manually - It's not on by default because we've tracked down most of the freeze issues to this.
function HPred:Tick()
	
	
	--Update missile cache
	--DISABLED UNTIL LATER.
	--self:CacheMissiles()
	
	--Limit how often tick logic runs
	if _nextTick > Game.Timer() then return end
	_nextTick = Game.Timer() + _tickFrequency
	
	--Update hero movement history	
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t then
			if t.isEnemy then
				HPred:OnVision(t)
			end
		end
	end
	
	--Do not run rest of logic until freeze issues are fully tracked down
	if true then return end
	
end

function HPred:GetLineTargetCount(source, aimPos, delay, speed, width)
	local killCount = 0
	local nokillCount = 0
	for i = 1, GameMinionCount() do
	local unit = GameMinion(i)
		if myHero.pos:DistanceTo(unit.pos) <= 1150 and unit.team == TEAM_ENEMY and IsValid(unit) then		 	
		
			local predictedPos = self:PredictUnitPosition(unit, delay+ self:GetDistance(source, unit.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			local QDmg = getdmg("Q", unit, myHero)
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (unit.boundingRadius + width) * (unit.boundingRadius + width)) and (not HasBuff(unit, "kalistaexpungemarker") or HasBuff(unit, "kalistaexpungemarker") and QDmg < unit.health) then
				nokillCount = nokillCount + 1	
			end
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (unit.boundingRadius + width) * (unit.boundingRadius + width)) and HasBuff(unit, "kalistaexpungemarker") and QDmg >= unit.health then
				killCount = killCount + 1			
			end			
		end	
	end	
	return killCount, nokillCount
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			--This node of the path will be completed before the delay has finished. Move on to the next node if one remains
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

function HPred:CanTarget(target, allowInvisible)
	return target.isEnemy and target.alive and target.health > 0  and (allowInvisible or target.visible) and target.isTargetable
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return math.huge
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) 
end

function HPred:GetDistance(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistance target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return math.huge
	end
	return math.sqrt(self:GetDistanceSqr(p1, p2))
end


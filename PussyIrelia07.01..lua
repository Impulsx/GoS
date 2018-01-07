if myHero.charName ~= "Irelia" then return end

if FileExist(COMMON_PATH .. "RomanovPred.lua") then
    require 'RomanovPred'
end
require 'DamageLib'
require '2DGeometry'
require 'MapPositionGOS'
require 'Collision'


local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
end

local function PercentHP(target)
    return 100 * target.health / target.maxHealth
end

local function PercentMP(target)
    return 100 * target.mana / target.maxMana
end

local function OnScreen(unit)
	return unit.pos:To2D().onScreen;
end

local function MinionsAround(range, pos, team)
    local pos = pos or myHero.pos
    local team = team or 300 - myHero.team
    local Count = 0
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.team == team and not minion.dead and pos:DistanceTo(minion.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

local function HeroesAround(range, pos, team)
    local pos = pos or myHero.pos
    local team = team or 300 - myHero.team
    local Count = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.team == team and not hero.dead and hero.pos:DistanceTo(pos, hero.pos) < range then
			Count = Count + 1
		end
	end
	return Count
end

local function GetDistance(p1,p2)
    local p2 = p2 or myHero.pos
    return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

local function GetDistance2D(p1,p2)
    local p2 = p2 or myHero
    return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2))
end

local function GetTarget(range)
	local target = nil
	if _G.EOWLoaded then
		target = EOW:GetTarget(range)
	elseif _G.SDK and _G.SDK.Orbwalker then
		target = _G.SDK.TargetSelector:GetTarget(range)
	else
		target = GOS:GetTarget(range)
	end
	return target
end


local Q = {range = 650, speed = 2200, delay = 0.79, width = myHero:GetSpellData(_Q).width, icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/IreliaGatotsu.png"}
local W = {range = myHero:GetSpellData(_W).range, speed = 400, delay = 0.30,  width = myHero:GetSpellData(_W).width, icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/IreliaHitenStyle.png"}
local E = {range = 325, speed = 20, delay = 0.75, width = myHero:GetSpellData(_E).width, icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/IreliaEquilibriumStrike.png"}
local R = {range = 1000, speed = 779, delay = 0.75, width = myHero:GetSpellData(_R).width, icon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/spell/IreliaTranscendentBlades.png"}

local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

--KS calc.

local function Qdmg(target)
	if Ready(_Q) then	
		return CalcPhysicalDamage(myHero,target,({20, 50, 80, 110, 140})[myHero:GetSpellData(_Q).level] + 1.2 * myHero.totalDamage) 
    end
    return 0
end

local function Rdmg(target)
    if Ready(_R) then
        return CalcPhysicalDamage(myHero,target,({320, 480, 640})[myHero:GetSpellData(_R).level] + 28.0 * myHero.bonusDamage + 20.0 * myHero.ap)
    end
    return 0
end

local function IGdmg(target)
	if Ready(SUMMONER_1) and Ready(SUMMONER_2)	
		return 50 + 20 * myHero.levelData.lvl - (target.hpRegen*3)
	end
	return 0
end

local function KSdmg(target)
	return Qdmg + Rdmg + IGdmg
end	


--KS calc.end

local function NoPotion()
	for i = 0, myHero.buffCount do 
	local buff = myHero:GetBuff(i)
		if buff.type == 13 and Game.Timer() < buff.expireTime then 
			return false
		end
	end
	return true
end



local function GetMode()
	if _G.EOWLoaded then
        if EOW.CurrentMode == 1 then
            return "Combo"
        elseif EOW.CurrentMode == 2 then
            return "Harass"
        elseif EOW.CurrentMode == 3 then
            return "Lasthit"
        elseif EOW.CurrentMode == 4 then
            return "Clear"
        end
	elseif _G.SDK and _G.SDK.Orbwalker then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "LastHit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
	else
		return GOS:GetMode()
	end
end

local function EnableOrb(bool)
	if Orb == 1 then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif Orb == 2 then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
end


function IsUnderTurret(unit)
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local PussyIrelia = MenuElement({type = MENU, id = "PussyIrelia", name = "PussyIrelia", leftIcon = "https://raw.githubusercontent.com/Pussykate/GoS/master/Woman.jpg"})

PussyIrelia:MenuElement({id = "Combo", name = "Combo", type = MENU})
	PussyIrelia.Combo:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})
	PussyIrelia.Combo:MenuElement({id = "W", name = "W", value = true, leftIcon = W.icon})
	PussyIrelia.Combo:MenuElement({id = "E", name = "E", value = true, leftIcon = E.icon})
	PussyIrelia.Combo:MenuElement({id = "R", name = "R", value = true, leftIcon = R.icon})

PussyIrelia:MenuElement({id = "Harass", name = "Harass", type = MENU})
    PussyIrelia.Harass:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})
    PussyIrelia.Harass:MenuElement({id = "W", name = "W", value = true, leftIcon = W.icon})
	PussyIrelia.Harass:MenuElement({id = "E", name = "E", value = true, leftIcon = E.icon})

PussyIrelia:MenuElement({id = "Clear", name = "Clear", type = MENU})
    PussyIrelia.Clear:MenuElement({id = "Q", name = "Q-Only LastHit", value = true, leftIcon = Q.icon})
    PussyIrelia.Clear:MenuElement({id = "W", name = "W", value = true, leftIcon = W.icon})
	PussyIrelia.Clear:MenuElement({id = "MP", name = "Min mana", value = 35, min = 0, max = 100})
	
PussyIrelia:MenuElement({id = "JClear", name = "JungleClear", type = MENU})
    PussyIrelia.JClear:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})
    PussyIrelia.JClear:MenuElement({id = "W", name = "W", value = true, leftIcon = W.icon})
	PussyIrelia.JClear:MenuElement({id = "E", name = "E", value = true, leftIcon = E.icon})
	PussyIrelia.JClear:MenuElement({id = "MP", name = "Min mana", value = 35, min = 0, max = 100})	
	
PussyIrelia:MenuElement({id = "LastHit", name = "LastHit", type = MENU})
    PussyIrelia.LastHit:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})	
	PussyIrelia.LastHit:MenuElement({id = "MP", name = "Min mana", value = 35, min = 0, max = 100})

PussyIrelia:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
    PussyIrelia.Killsteal:MenuElement({id = "Q", name = "Q", value = true, leftIcon = Q.icon})
    PussyIrelia.Killsteal:MenuElement({id = "R", name = "R", value = true, leftIcon = R.icon})
	PussyIrelia.Killsteal:MenuElement({id = "Q,R,IGKS", name = "Q,R,IgniteKS", value = true})
	
PussyIrelia:MenuElement({id = "AutoStun", name = "AutoStun E", type = MENU})
    PussyIrelia.AutoStun:MenuElement({id = "E", name = "E", value = true, leftIcon = E.icon})	
	
PussyIrelia:MenuElement({type = MENU, id = "Activator", name = "Activator"})
	PussyIrelia.Activator:MenuElement({type = MENU, id = "P", name = "Potions"})
	PussyIrelia.Activator.P:MenuElement({id = "Pot", name = "All Potions", value = true, leftIcon = "https://raw.githubusercontent.com/Pussykate/GoS/master/836591686.jpg"})
	PussyIrelia.Activator.P:MenuElement({id = "HP", name = "Health % to Potion", value = 60, min = 0, max = 100})
	
	PussyIrelia.Activator:MenuElement({type = MENU, id = "I", name = "Items"})
	PussyIrelia.Activator.I:MenuElement({id = "Tiamat", name = "Hydra / Tiamat", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3077.png","http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3074.png"})
	PussyIrelia.Activator.I:MenuElement({id = "YG", name = "Youmuu's Ghostblade", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3153.png"})	
	PussyIrelia.Activator.I:MenuElement({id = "King", name = "Blade of the Ruined King", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3142.png"})
	PussyIrelia.Activator.I:MenuElement({id = "RO", name = "Randuin's Omen", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/item/3143.png"})
	
	PussyIrelia.Activator:MenuElement({type = MENU, id = "S", name = "Summoner Spells"})
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
			PussyIrelia.Activator.S:MenuElement({id = "Heal", name = "Heal", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerHeal.png"})
			PussyIrelia.Activator.S:MenuElement({id = "HealHP", name = "HP Under %", value = 25, min = 0, max = 100})
		end
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then
			PussyIrelia.Activator.S:MenuElement({id = "Barrier", name = "Barrier", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerBarrier.png"})
			PussyIrelia.Activator.S:MenuElement({id = "BarrierHP", name = "HP Under %", value = 25, min = 0, max = 100})
		end
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
			PussyIrelia.Activator.S:MenuElement({id = "Ignite", name = "Combo Ignite", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerDot.png"})
		end
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then
			PussyIrelia.Activator.S:MenuElement({id = "Exhaust", name = "Combo Exhaust", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerExhaust.png"})
			PussyIrelia.Activator.S:MenuElement({id = "EnemyHP", name = "EnemyHP Under %", value = 25, min = 0, max = 100})
		end


PussyIrelia:MenuElement({id = "Draw", name = "Drawings", type = MENU})
    PussyIrelia.Draw:MenuElement({id = "Q", name = "Q - Bladesurge", value = true})
    PussyIrelia.Draw:MenuElement({id = "E", name = "E - Equilibrium Strike", value = true})
    PussyIrelia.Draw:MenuElement({id = "R", name = "R - Transcendent Blades", value = true})

Callback.Add("Tick", function() Tick() end)
Callback.Add("Draw", function() Drawings() end)

function Tick()
	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Lane()
		JungleClear()
	elseif Mode == "LastHit" then
		LastHit()
	end
	Activator()
	Killsteal()
	AutoStun()
end

function QCast(HK_Q,Q,target,myHero)
    local pred = RomanovPredPos(myHero,target,Q.speed,Q.delay,Q.width)
    if RomanovHitchance(myHero,target,Q.speed,Q.delay,Q.range,Q.width) >= 3 then
        Control.CastSpell(HK_Q, pred)
    end
end

function RCast(HK_R,R,target,myHero)
    local pred = RomanovPredPos(myHero,target,R.speed,R.delay,R.width)
    if RomanovHitchance(myHero,target,R.speed,R.delay,R.range,R.width) >= 2 then
        Control.CastSpell(HK_R, pred)
    end
end


function Combo()
    local target = GetTarget(R.range)
	if target == nil then return end
		if IsValidTarget(target,W.range) and PussyIrelia.Combo.W:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 4000 then
			Control.CastSpell(HK_W)
		
		end
		if IsValidTarget(target,Q.range) and PussyIrelia.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 650 then
			Control.CastSpell(HK_Q, target)
		
		end
		if IsValidTarget(target,E.range) and PussyIrelia.Combo.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 325 then
			Control.CastSpell(HK_E, target)
		
		end
		if PussyIrelia.Combo.R:Value() and Ready(_R) and GetDistance(pred) < R.range then
		local pred = target:GetPrediction(R.speed,R.delay,R.width)	
			Control.CastSpell(HK_R, pred)
		end
	end



function Harass()
	local target = GetTarget(Q.range)
	if target == nil then return end
		if IsValidTarget(target,W.range) and PussyIrelia.Harass.W:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 400 then
			Control.CastSpell(HK_W)
		end
		if IsValidTarget(target,Q.range) and PussyIrelia.Harass.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 650 then
			Control.CastSpell(HK_Q, target)
		end
		if IsValidTarget(target,E.range) and PussyIrelia.Harass.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 325 then
			Control.CastSpell(HK_E, target)
			
		end
	end
	
	

function AutoStun()	
	local target = GetTarget(E.range)
	if target == nil then return end
	local function PercentHP(source)
	local source = source or myHero
	return 100 * source.health / source.maxHealth
	end
	if IsValidTarget(target,E.range) and PussyIrelia.AutoStun.E:Value() and Ready(_E) and PercentHP(target) > PercentHP() and myHero.pos:DistanceTo(target.pos) < 325 then
				Control.CastSpell(HK_E, target)
			
		
	end
end	
	

function Lane()
	if PercentMP(myHero) < PussyIrelia.Clear.MP:Value() then return end
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
		if minion then
			if minion.team == 300 - myHero.team then
				if IsValidTarget(minion,W.range) and PussyIrelia.Clear.W:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) < 400 then
					Control.CastSpell(HK_W)
					
				end
			end
		end
		if minion then
			if minion.team == 300 - myHero.team then
				local pred = minion:GetPrediction(Q.speed,Q.delay,Q.width)
				if PussyIrelia.LastHit.Q:Value() and Ready(_Q) and GetDistance(pred) < Q.range then
					if Qdmg(minion) >= minion.health then
						Control.CastSpell(HK_Q, pred)
					end
				end
			end
		end
	end
end

function JungleClear()
	if PercentMP(myHero) < PussyIrelia.JClear.MP:Value() then return end
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
        if minion.team == 300 and not minion.dead then
			if IsValidTarget(minion,Q.range) and PussyIrelia.JClear.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 650 then
				Control.CastSpell(HK_Q)
			
			end
			if minion then
				if IsValidTarget(minion,W.range) and PussyIrelia.JClear.W:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) < 400 then
					Control.CastSpell(HK_W)
				end
			end
			if minion then
				if IsValidTarget(minion,E.range) and PussyIrelia.JClear.E:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 325 then
					Control.CastSpell(HK_E)
				end
			end
		end
	end
end



function LastHit()
    if PercentMP(myHero) < PussyIrelia.LastHit.MP:Value() then return end
		if PussyIrelia.LastHit.Q:Value() and Ready(_Q) and if GetDistance(pred) < Q.range then
			if Qdmg(minion) > minion.health then
			local pred = minion:GetPrediction(Q.speed,Q.delay,Q.width)	
				if minion then	
					if minion.team == 300 - myHero.team then
					for i = 1, Game.MinionCount() do
						local minion = Game.Minion(i)
							Control.CastSpell(HK_Q, pred)
						end
					end
				end
			end
		end
	end
end	
	
function Killsteal()
	local target = GetTarget(Q.range)
	if target == nil then return end
	if PussyIrelia.Killsteal.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 650 then
		if Qdmg(target) >= target.health then
			Control.CastSpell(HK_Q, target)
		end
	end		
	if target == nil then return end	
	if PussyIrelia.Killsteal.R:Value() and Ready(_R) and GetDistance(pred) < R.range then
		local pred = target:GetPrediction(R.speed,R.delay,R.width)
		if Rdmg(target) > target.health then
			Control.CastSpell(HK_R, pred)
		end
	end
end	

function Killsteal()
	local target = GetTarget(Q.range)
	if target == nil then return end
		if KSdmg(target) > target.health then	
			if PussyIrelia.Killsteal.Q,R,IGKS:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 650 then
					Control.CastSpell(HK_Q, target)
			
			if PussyIrelia.Killsteal.Q,R,IGKS:Value() and Ready(_R) and GetDistance(pred) < R.range then
				local pred = target:GetPrediction(R.speed,R.delay,R.width)
				Control.CastSpell(HK_R, pred)
			
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
				or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
					if PussyIrelia.Killsteal.Q,R,IGKS:Value() then
						if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) and
						myHero.pos:DistanceTo(target.pos) < 600 then
							Control.CastSpell(HK_SUMMONER_1, target)
						elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) and 
						myHero.pos:DistanceTo(target.pos) < 600 then
							Control.CastSpell(HK_SUMMONER_2, target)
		
						end
					end
				end
			end
		end
	end
end	
	


function Activator()
	local target = GetTarget(1575)
	if target == nil then return end
	local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
    end
	local Potion = items[2003] or items[2010] or items[2031] or items[2032] or items[2033]
	if Potion and target and myHero:GetSpellData(Potion).currentCd == 0 and PussyIrelia.Activator.P.Pot:Value() and PercentHP(myHero) < PussyIrelia.Activator.P.HP:Value() and NoPotion() then
		Control.CastSpell(HKITEM[Potion])
	end
	if GetMode() == "Combo" then	
		local Tiamat = items[3077] or items[3748] or items[3074]
		if Tiamat and myHero:GetSpellData(Tiamat).currentCd == 0 and PussyIrelia.Activator.I.Tiamat:Value() and myHero.pos:DistanceTo(target.pos) < 400 and myHero.attackData.state == 2 then
		Control.CastSpell(HKITEM[Tiamat], target.pos)
		end
		local King = items[3153]
		if King and myHero:GetSpellData(King).currentCd == 0 and PussyIrelia.Activator.I.King:Value() and myHero.pos:DistanceTo(target.pos) < 600 and myHero.attackData.state == 2 then
		Control.CastSpell(HKITEM[King], target.pos)
		end
		local YG = items[3142]
		if YG and myHero:GetSpellData(YG).currentCd == 0 and PussyIrelia.Activator.I.YG:Value() and myHero.pos:DistanceTo(target.pos) < 1575 then
		Control.CastSpell(HKITEM[YG])
		end
		local Randuin = items[3143]
		if Randuin and myHero:GetSpellData(Randuin).currentCd == 0 and PussyIrelia.Activator.I.RO:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
		Control.CastSpell(HKITEM[Randuin])
		end
	end
		
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
		if PussyIrelia.Activator.S.Heal:Value() and target then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and Ready(SUMMONER_1) and PercentHP(myHero) < PussyIrelia.Activator.S.HealHP:Value() then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and Ready(SUMMONER_2) and PercentHP(myHero) < PussyIrelia.Activator.S.HealHP:Value() then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
	end
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then
		if PussyIrelia.Activator.S.Barrier:Value() and target then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier" and Ready(SUMMONER_1) and PercentHP(myHero) < PussyIrelia.Activator.S.BarrierHP:Value() then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" and Ready(SUMMONER_2) and PercentHP(myHero) < PussyIrelia.Activator.S.BarrierHP:Value() then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
	end
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then
		if PussyIrelia.Activator.S.Exhaust:Value() and target then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and Ready(SUMMONER_1) and PercentHP(target) < PussyIrelia.Activator.S.EnemyHP:Value() then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and Ready(SUMMONER_2) and PercentHP(target) < PussyIrelia.Activator.S.EnemyHP:Value() then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
	end	



	if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
		if PussyIrelia.Activator.S.Ignite:Value() then
			local IgDamage = IGdmg(target)
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) and IgDamage > target.health
			and myHero.pos:DistanceTo(target.pos) < 600 then
				Control.CastSpell(HK_SUMMONER_1, target)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) and IgDamage > target.health
			and myHero.pos:DistanceTo(target.pos) < 600 then
				Control.CastSpell(HK_SUMMONER_2, target)
			end
		end
	end
end	

function Drawings()
    if myHero.dead then return end
	if PussyIrelia.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, Q.range, 1,  Draw.Color(255, 000, 222, 255)) end
	if PussyIrelia.Draw.E:Value() and Ready(_E) then Draw.Circle(myHero.pos, E.range, 1,  Draw.Color(255, 000, 150, 255)) end
    if PussyIrelia.Draw.R:Value() and Ready(_R) then Draw.Circle(myHero.pos, R.range, 1,  Draw.Color(255, 000, 043, 255)) end
	end

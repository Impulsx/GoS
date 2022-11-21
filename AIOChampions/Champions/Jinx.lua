--//// Ported from BoL / Dienofail Jinx ////--

local AARange = 525 + myHero.boundingRadius
local QRange = 605 + myHero.boundingRadius
local isFishBones;
local FishStacks = 0;


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

local function GetEnemyCount(range, unit)
    local pos = unit.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end
local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 8 or buff.type == 12 or buff.type == 22 or buff.type == 23 or buff.type == 25 or buff.type == 30 or buff.type == 35 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false
end

local function CheckImmobile()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if Ready(_E) and IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) < EData.Range then
			local IsImmobile = IsImmobileTarget(enemy)
			if IsImmobile then
				CastE(enemy)
			end
		end
	end
end

local function CheckDashes()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if Ready(_E) and IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) < EData.Range and enemy.pathing.isDashing then

			if GetDistanceSqr(enemy.pathing.endPos, myHero.pos) < GetDistanceSqr(enemy.pos, myHero.pos) then
				CastE(enemy)
			end
		end
	end
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

local function JinxUltSpeed(Target)
	if Target ~= nil and IsValid(Target) then
		local Distance = GetDistance(myHero.pos, Target.pos)
		local Speed = (Distance > 1350 and (1350*1700+((Distance-1350)*2200))/Distance or 1700)
		return Speed
	end
end

local function CalcRDmg(unit)
	local Damage = 0
	local Distance = GetDistance(myHero.pos, unit.pos)
	local MathDist = math.floor(math.floor(Distance)/100)
	local level = myHero:GetSpellData(_R).level
	local BaseR = ({25, 40, 55})[level] + 0.15 * myHero.bonusDamage
	local RMissHeal = ({25, 30, 35})[level] / 100 * (unit.maxHealth - unit.health)
	--local dist = myHero.pos:DistanceTo(unit.pos)
	if Distance < 100 then
		Damage = BaseR + RMissHeal
	elseif Distance >= 1500 then
		Damage = BaseR * 10	+ RMissHeal
	else
		Damage = ((((MathDist * 6) + 10) / 100) * BaseR) + BaseR + RMissHeal
	end
	return CalcDamage(myHero, unit, 1, Damage) -- or getdmg()
end


local function CheckQ()
	--print(myHero.range)
	--QRange = MyHeroRange --605 + myHero.boundingRadius*2--({80, 110, 140, 170, 200})[myHero:GetSpellData(_Q).level] + (myHero:GetSpellData(_Q).range) --(myHero:GetSpellData(_Q).level*25) + 75 + 600
	local qLevel = 1 or myHero:GetSpellData(_Q).level
	AARange = 525 + myHero.boundingRadius*2
	QRange = AARange + ({80, 110, 140, 170, 200})[qLevel]
	local fishBones = GetBuffData(myHero, "JinxQ").count >= 1
	local powPow = GetBuffData(myHero, "jinxqicon").count >= 1
	if fishBones then
		QRange = myHero.range + myHero.boundingRadius*2
		isFishBones = true
	else
		AARange = myHero.range + myHero.boundingRadius*2
		isFishBones = false
	end
	--DrawText('isfishBones: '..tostring(isFishBones)..' | fishBones: '..tostring(fishBones), 24, myHero.pos2D.x, myHero.pos2D.y+75)
	--DrawText('QRange: '..tostring(QRange)..' | AARange: '..tostring(AARange)..' | myHero.range: '..tostring(myHero.range), 24, myHero.pos2D.x, myHero.pos2D.y+25)
	local Buff = GetBuffData(myHero, "jinxqramp")
	if Buff.count then
		--FishStacks = Buff.stacks
		FishStacks = Buff.count
	else
		FishStacks = 0
	end
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.08"}})

	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu:MenuElement({type = MENU, id = "Extras", name = "Extra Settings"})
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})


	--Combo
	Menu.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true})
	Menu.Combo:MenuElement({id = "W", name = "Use [W]", value = true})
	Menu.Combo:MenuElement({id = "W2", name = "Only [W] if out of AA range", value = true})
	Menu.Combo:MenuElement({id = "E", name = "Use [E]", value = true})
	Menu.Combo:MenuElement({id = "R", name = "Use [R]", value = true})

	--Harass
	Menu.Harass:MenuElement({id = "Q", name = "Use [Q]", value = true})
	Menu.Harass:MenuElement({id = "W", name = "Use [W]", value = true})
	Menu.Harass:MenuElement({id = "E", name = "Use [E]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana", value = 30, min = 0, max = 100, identifier = "%"})

	--Draw
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})

	--Prediction
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})

	--KS
	Menu.ks:MenuElement({name = " ", drop = {"Only if Combo not active"}})
	Menu.ks:MenuElement({id = "UseW", name = "Use [W]", value = true})
	Menu.ks:MenuElement({id = "UseR", name = "Use [R]", value = true})

	--Extras
	Menu.Extras:MenuElement({id = "Key", name = "SemiKey [R]", key = string.byte("T")})
	Menu.Extras:MenuElement({id = "RRange3", name = "Max R Range (Semi Key)", value = 4000, min = 350, max = 12500, identifier = "range"})
	Menu.Extras:MenuElement({id = "RRange", name = "Max R Range (Combo / Ks)", value = 2000, min = 350, max = 4000, identifier = "range"})
	Menu.Extras:MenuElement({id = "MinRRange", name = "Min R Range (Combo / Ks)", value = 300, min = 0, max = 1800, identifier = "range"})
	Menu.Extras:MenuElement({id = "REnemies", name = "R multible Enemies (Combo)", value = 3, min = 1, max = 5})
	Menu.Extras:MenuElement({id = "RRange2", name = "Max R Range Check multible Enemies", value = 4000, min = 350, max = 12500, identifier = "range"})
	Menu.Extras:MenuElement({id = "ROverkill", name = "Check R Overkill", value = true})
	Menu.Extras:MenuElement({id = "WRange", name = "Min W Range", value = 300, min = 0, max = 1450, identifier = "range"})
	Menu.Extras:MenuElement({id = "EGapcloser", name = "Auto E Gapclosers", value = false})
	Menu.Extras:MenuElement({id = "EAutoCast", name = "Auto E Immobile Target", value = true})
	Menu.Extras:MenuElement({id = "SwapThree", name = "Swap Q at three fishbone stacks", value = true})
	Menu.Extras:MenuElement({id = "SwapDistance", name = "Swap Q for Distance", value = true})
	Menu.Extras:MenuElement({id = "SwapAOE", name = "Swap Q for AoE", value = true})
	Menu.Extras:MenuElement({id = "AOEFarm", name = "Swap Q for AoE Farm", value = false})

	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.6, Radius = 60, Range = 1450, Speed = 3300, Collision = true, MaxCollision = 0, CollisionTypes = { _G.COLLISION_MINION, _G.COLLISION_ENEMYHERO, _G.COLLISION_YASUOWALL }
	}

	WspellData = {speed = 3300, range = 1450, delay = 0.6, radius = 60, collision = {"minion", "hero", "windwall"}, type = "linear"}

	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.9, Radius = 115, Range = 925, Speed = 1100, Collision = false
	}

	EspellData = {speed = 1100, range = 925, delay = 0.9, radius = 115, collision = {nil}, type = "circular"}

	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function()
		if myHero.dead then return end

		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			--DrawCircle(myHero, QRange, 1, DrawColor(255, 225, 255, 10))
			local useRange
			if isFishBones then
				useRange = QRange
			else
				useRange = AARange
			end
			DrawCircle(myHero, useRange, 1, DrawColor(255, 225, 255, 10))
		end
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			DrawCircle(myHero, WData.Range, 1, DrawColor(255, 225, 255, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			DrawCircle(myHero, EData.Range, 1, DrawColor(255, 225, 255, 10))
		end
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			DrawCircle(myHero, Menu.Extras.RRange:Value(), 1, DrawColor(225, 225, 0, 10))
		end
	end)
end

function Tick()
	CheckQ()
	if MyHeroNotReady() then return end
	local target = GetTarget(EData.Range)
	local Wtarget = GetTarget(WData.Range)
	local Mode = GetMode()
	if Mode == "Combo" then
		ComboR()
		if target ~= nil then
			Combo(target)
		elseif Wtarget ~= nil then
			Combo(Wtarget)
		end
	elseif Mode == "Harass" then
		if target ~= nil then
			Harass(target)
		elseif Wtarget ~= nil then
			Harass(Wtarget)
		elseif Wtarget == nil and not isFishBones then
			Control.CastSpell(HK_Q)
		end
	elseif Mode == "Clear" then
		if Menu.Extras.AOEFarm:Value() then
			if not isFishBones then
				Control.CastSpell(HK_Q)
			end
		--[[ else
			if isFishBones then
				Control.CastSpell(HK_Q)
			end ]]
		end
	end

	if Ready(_R) and Menu.Extras.Key:Value() then
		SemiCastUlt()
	end

	if Mode ~= "Combo" then
		KS()
	end

	if Menu.Extras.EGapcloser:Value() then
		CheckDashes()
	end

	if Menu.Extras.EAutoCast:Value() then
		CheckImmobile()
	end

	if target == nil and Wtarget == nil and isFishBones and Ready(_Q) and Mode == "Clear" then --was not isFishBones.
		Control.CastSpell(HK_Q)
	end
end

function Combo(Target)
if Target == nil then return end

	if Menu.Combo.W2:Value() then
		if Ready(_W) and GetDistance(myHero.pos, Target.pos) < WData.Range and Menu.Combo.W:Value() then
			if GetDistance(myHero.pos, Target.pos) > QRange+50 then
				CastW(Target)
			end
		end
	else
		if Ready(_W) and GetDistance(myHero.pos, Target.pos) < WData.Range and Menu.Combo.W:Value() then
			CastW(Target)
		end
	end

	if Ready(_E) and Menu.Combo.E:Value() then
		CastComboE(Target)
	end

	if Ready(_Q) and Menu.Combo.Q:Value() then
		Swap(Target)
	end
end

function ComboR()
	local Target = GetTarget(12500)
	if Target == nil then return end
	if Ready(_R) and Menu.Combo.R:Value() then
		CastR(Target)
	end
end

function Swap(Target)
	if IsValid(Target) and Ready(_Q) then

		if isFishBones then
			if Menu.Extras.SwapThree:Value() and FishStacks == 3 and GetDistance(myHero.pos, Target.pos) < AARange then
				Control.CastSpell(HK_Q)
			end
			if Menu.Extras.SwapDistance:Value() and GetDistance(myHero.pos, Target.pos) < AARange + Target.boundingRadius and GetDistance(myHero.pos, Target.pos) < QRange + Target.boundingRadius then
				Control.CastSpell(HK_Q)
			end
			if Menu.Extras.SwapAOE:Value() and GetEnemyCount(250, Target) <= 1 or Menu.Extras.SwapThree:Value() and FishStacks < 2 then
				Control.CastSpell(HK_Q)
			end
		else
			if Menu.Extras.SwapAOE:Value() and GetEnemyCount(250, Target) > 1 then
				Control.CastSpell(HK_Q)
				--return
			end
			if Menu.Extras.SwapDistance:Value() and GetDistance(myHero.pos, Target.pos) < AARange + Target.boundingRadius then
				Control.CastSpell(HK_Q)
			end
			if Menu.Extras.SwapThree:Value() and FishStacks < 3 and GetDistance(myHero.pos, Target.pos) < AARange + Target.boundingRadius then
				Control.CastSpell(HK_Q)
			end
			if GetMode() == "Harass" and GetDistance(myHero.pos, Target.pos) > AARange + Target.boundingRadius + 50 then
				Control.CastSpell(HK_Q)
			end
		end
	end
end

function Harass(Target)
if Target == nil or myHero.mana/myHero.maxMana < Menu.Harass.Mana:Value()/100 then return end
	if Ready(_W) and Menu.Harass.W:Value() then
		CastW(Target)
	end

	if Ready(_Q) and Menu.Harass.Q:Value() then
		Swap(Target)
	end

	if Ready(_E) and Menu.Harass.E:Value() then
		CastComboE(Target)
	end
end


function CastComboE(Target)
	if Ready(_E) and GetDistance(myHero.pos, Target.pos) < EData.Range then
		CastE(Target)
	end
end

function CastW(Target)
	if GetDistance(myHero.pos, Target.pos) > Menu.Extras.WRange:Value() then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(Target, WData, myHero)
			if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
				Control.CastSpell(HK_W, pred.CastPosition)
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, Target, WspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
				Control.CastSpell(HK_W, pred.CastPos)
			end
		else
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.6, Radius = 60, Range = 1400, Speed = 3300, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION, GGPrediction.COLLISION_ENEMYHERO, GGPrediction.COLLISION_YASUOWALL}})
			WPrediction:GetPrediction(Target, myHero)
			if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
				Control.CastSpell(HK_W, WPrediction.CastPosition)
			end
		end
	end
end

function CastE(Target)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(Target, EData, myHero)
		if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
			Control.CastSpell(HK_E, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, Target, EspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
			Control.CastSpell(HK_E, pred.CastPos)
		end
	else
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 1.2, Radius = 120, Range = 900, Speed = MathHuge, Collision = false})
		EPrediction:GetPrediction(Target, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end
	end
end

function CastR(Target)
	if Target ~= nil and Ready(_R) then

		if GetDistance(myHero.pos, Target.pos) <= Menu.Extras.RRange2:Value() and GetEnemyCount(400, Target) >= Menu.Extras.REnemies:Value() then
			local CurrentRSpeed = JinxUltSpeed(Target)
			if Menu.Pred.Change:Value() == 1 then
				local RData = {Type = _G.SPELLTYPE_LINE, Delay = 1, Radius = 280, Range = 12500, Speed = CurrentRSpeed, Collision = false}
				local pred = GetGamsteronPrediction(Target, RData, myHero)
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					Control.CastSpell(HK_R, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local RspellData = {speed = CurrentRSpeed, range = 12500, delay = 1, radius = 280, collision = {"hero", "windwall"}, type = "linear"}
				local pred = _G.PremiumPrediction:GetPrediction(myHero, Target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					Control.CastSpell(HK_R, pred.CastPos)
				end
			else
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.6, Radius = 280, Range = 12500, Speed = CurrentRSpeed, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION, GGPrediction.COLLISION_ENEMYHERO, GGPrediction.COLLISION_YASUOWALL}})
				RPrediction:GetPrediction(Target, myHero)
				if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
					Control.CastSpell(HK_R, RPrediction.CastPosition)
				end
			end
		end

		if Menu.Extras.ROverkill:Value() then
			if GetDistance(myHero.pos, Target.pos) > Menu.Extras.MinRRange:Value() and GetDistance(myHero.pos, Target.pos) < Menu.Extras.RRange:Value() then
				local RDamage = CalcRDmg(Target)
				local ADamage = getdmg("AA", Target, myHero)
				if ((isFishBones and GetDistance(myHero.pos, Target.pos) < QRange+100) or (not isFishBones and GetDistance(myHero.pos, Target.pos) < AARange+100)) and Target.health < ADamage * 4 then
					return
				elseif Target.health < RDamage then
					CastPredUlt(Target)
				end
			end

		elseif GetDistance(myHero.pos, Target.pos) > Menu.Extras.MinRRange:Value() and GetDistance(myHero.pos, Target.pos) < Menu.Extras.RRange:Value() then
			local RDamage = CalcRDmg(Target)
			if Target.health < RDamage then
				CastPredUlt(Target)
			end
		end
	end
end

function SemiCastUlt()
	local Target = GetTarget(Menu.Extras.RRange3:Value())
	if Target == nil then return end

	local CurrentRSpeed = JinxUltSpeed(Target)
	if Menu.Pred.Change:Value() == 1 then
		local RData = {Type = _G.SPELLTYPE_LINE, Delay = 1, Radius = 70, Range = Menu.Extras.RRange3:Value(), Speed = CurrentRSpeed, Collision = false}
		local pred = GetGamsteronPrediction(Target, RData, myHero)
		if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local RspellData = {speed = CurrentRSpeed, range = Menu.Extras.RRange3:Value(), delay = 1, radius = 70, collision = {{"hero", "windwall"}}, type = "linear"}
		local pred = _G.PremiumPrediction:GetPrediction(myHero, Target, RspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
			Control.CastSpell(HK_R, pred.CastPos)
		end
	else
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 1, Radius = 70, Range = Menu.Extras.RRange3:Value(), Speed = CurrentRSpeed, Collision = true, CollisionTypes = { GGPrediction.COLLISION_ENEMYHERO, GGPrediction.COLLISION_YASUOWALL }})
		RPrediction:GetPrediction(Target, myHero)
		if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
			Control.CastSpell(HK_R, RPrediction.CastPosition)
		end
	end
end

function CastPredUlt(unit)
	local CurrentRSpeed = JinxUltSpeed(unit)
	if Menu.Pred.Change:Value() == 1 then
		local RData = {Type = _G.SPELLTYPE_LINE, Delay = 1, Radius = 70, Range = Menu.Extras.RRange:Value(), Speed = CurrentRSpeed, Collision = false}
		local pred = GetGamsteronPrediction(unit, RData, myHero)
		if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local RspellData = {speed = CurrentRSpeed, range = Menu.Extras.RRange:Value(), delay = 1, radius = 70, collision = {{"hero", "windwall"}}, type = "linear"}
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
			Control.CastSpell(HK_R, pred.CastPos)
		end
	else
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 1, Radius = 70, Range = Menu.Extras.RRange:Value(), Speed = CurrentRSpeed, Collision = true, CollisionTypes = {GGPrediction.COLLISION_ENEMYHERO, GGPrediction.COLLISION_YASUOWALL}})
		RPrediction:GetPrediction(unit, myHero)
		if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
			Control.CastSpell(HK_R, RPrediction.CastPosition)
		end
	end
end

function KS()
	if Ready(_R) then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) > Menu.Extras.MinRRange:Value() and GetDistance(myHero.pos, enemy.pos) < Menu.Extras.RRange:Value() and Menu.ks.UseR:Value() then
				local Rdmg = CalcRDmg(enemy)
				if Rdmg > enemy.health then
					CastR(enemy)
				end
			elseif IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) < WData.Range and Menu.ks.UseW:Value() then
				if getdmg("W", enemy, myHero) > enemy.health then
					CastW(enemy)
				end
			end
		end
	end
end

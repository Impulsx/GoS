--//// Ported from BoL / Dienofail Jinx ////--


local isFishBones = true
local FishStacks = 0
local QRange

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

function CalcRDmg(unit)
	local Damage = 0
	local Distance = GetDistance(myHero.pos, unit.pos)
	local MathDist = math.floor(math.floor(Distance)/100)	
	local level = myHero:GetSpellData(_R).level
	local BaseQ = ({25, 35, 45})[level] + 0.15 * myHero.bonusDamage
	local QMissHeal = ({25, 30, 35})[level] / 100 * (unit.maxHealth - unit.health)
	local dist = myHero.pos:DistanceTo(unit.pos)
	if Distance < 100 then
		Damage = BaseQ + QMissHeal
	elseif Distance >= 1500 then
		Damage = BaseQ * 10	+ QMissHeal		
	else
		Damage = ((((MathDist * 6) + 10) / 100) * BaseQ) + BaseQ + QMissHeal
	end
	return CalcPhysicalDamage(myHero, unit, Damage)
end

function LoadScript() 
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.04"}})
	
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
	Menu.Extras:MenuElement({id = "EGapcloser", name = "Auto E Gapclosers", value = true})
	Menu.Extras:MenuElement({id = "EAutoCast", name = "Auto E Immobile Target", value = true})
	Menu.Extras:MenuElement({id = "SwapThree", name = "Swap Q at three fishbone stacks", value = true})
	Menu.Extras:MenuElement({id = "SwapDistance", name = "Swap Q for Distance", value = true})
	Menu.Extras:MenuElement({id = "SwapAOE", name = "Swap Q for AoE", value = true})
	
	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.6, Radius = 30, Range = 1400, Speed = 3300, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	WspellData = {speed = 3300, range = 1400, delay = 0.6, radius = 30, collision = {"minion"}, type = "linear"}	
	
	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 1.5, Radius = 120, Range = 900, Speed = 1100, Collision = false
	}
	
	EspellData = {speed = 1100, range = 900, delay = 1.5, radius = 120, collision = {nil}, type = "circular"}	

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end	
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
			if isFishBones then
				DrawCircle(myHero, 600, 1, DrawColor(255, 225, 255, 10))
			else
				DrawCircle(myHero, QRange, 1, DrawColor(255, 225, 255, 10))
			end	
		end 		
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			DrawCircle(myHero, 1500, 1, DrawColor(255, 225, 255, 10))
		end 		
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
			DrawCircle(myHero, 900, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			DrawCircle(myHero, Menu.Extras.RRange:Value(), 1, DrawColor(225, 225, 0, 10))
		end
	end)	
end

function Tick()
	Check()
	if MyHeroNotReady() then return end	
	local target = GetTarget(900)
	local Wtarget = GetTarget(1450)	
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
		if not isFishBones then
			Control.CastSpell(HK_Q)
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

	if target == nil and Wtarget == nil and not isFishBones and Ready(_Q) and Mode == "Clear" then
		Control.CastSpell(HK_Q)
	end
end

function Combo(Target)	
if Target == nil then return end	
	
	if Menu.Combo.W2:Value() then
		if Ready(_W) and GetDistance(myHero.pos, Target.pos) < 1450 and Menu.Combo.W:Value() then
			if GetDistance(myHero.pos, Target.pos) > QRange+50 then
				CastW(Target)
			end	
		end
	else
		if Ready(_W) and GetDistance(myHero.pos, Target.pos) < 1450 and Menu.Combo.W:Value() then
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
	if IsValid(Target) and Ready(_Q)then
	
		if isFishBones then
			if Menu.Extras.SwapThree:Value() and FishStacks == 3 and GetDistance(myHero.pos, Target.pos) < QRange then
				Control.CastSpell(HK_Q)
			end
			if Menu.Extras.SwapDistance:Value() and GetDistance(myHero.pos, Target.pos) > 600 + Target.boundingRadius and GetDistance(myHero.pos, Target.pos) < QRange + Target.boundingRadius then
				Control.CastSpell(HK_Q)
			end
			if Menu.Extras.SwapAOE:Value() and GetEnemyCount(300, Target) > 1 and FishStacks > 2 then 
				Control.CastSpell(HK_Q)
			end
		else
			if Menu.Extras.SwapAOE:Value() and GetEnemyCount(300, Target) > 1 then 
				return
			end
			if Menu.Extras.SwapThree:Value() and FishStacks < 3 and GetDistance(myHero.pos, Target.pos) < 600 + Target.boundingRadius then
				Control.CastSpell(HK_Q)
			end
			if Menu.Extras.SwapDistance:Value() and GetDistance(myHero.pos, Target.pos) < 600 + Target.boundingRadius then
				Control.CastSpell(HK_Q)
			end
			if GetMode() == "Harass" and GetDistance(myHero.pos, Target.pos) > 600 + Target.boundingRadius + 50 then
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
	if Ready(_E) and GetDistance(myHero.pos, Target.pos) < 900 then
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
			local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.6, Radius = 30, Range = 1400, Speed = 3300, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
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
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 1.5, Radius = 120, Range = 900, Speed = 1100, Collision = false})
		EPrediction:GetPrediction(Target, myHero)
		if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
			Control.CastSpell(HK_E, EPrediction.CastPosition)
		end				
	end
end

function CastR(Target)
	if Target ~= nil and Ready(_R) then
		
		if GetDistance(myHero.pos, Target.pos) <= Menu.Extras.RRange2:Value() and GetEnemyCount(450, Target) >= Menu.Extras.REnemies:Value() then
			local CurrentRSpeed = JinxUltSpeed(Target)
			if Menu.Pred.Change:Value() == 1 then
				local RData = {Type = _G.SPELLTYPE_LINE, Delay = 1, Radius = 70, Range = 12500, Speed = CurrentRSpeed, Collision = false}				
				local pred = GetGamsteronPrediction(Target, RData, myHero)			
				if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					Control.CastSpell(HK_R, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local RspellData = {speed = CurrentRSpeed, range = 12500, delay = 1, radius = 70, collision = {nil}, type = "linear"}
				local pred = _G.PremiumPrediction:GetPrediction(myHero, Target, RspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
					Control.CastSpell(HK_R, pred.CastPos)
				end
			else
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 1, Radius = 70, Range = 12500, Speed = CurrentRSpeed, Collision = false})
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
				if ((isFishBones and GetDistance(myHero.pos, Target.pos) < QRange+100) or (not isFishBones and GetDistance(myHero.pos, Target.pos) < myHero.range+100)) and Target.health < ADamage * 4 then 
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
		local RspellData = {speed = CurrentRSpeed, range = Menu.Extras.RRange3:Value(), delay = 1, radius = 70, collision = {nil}, type = "linear"}
		local pred = _G.PremiumPrediction:GetPrediction(myHero, Target, RspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
			Control.CastSpell(HK_R, pred.CastPos)
		end
	else
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 1, Radius = 70, Range = Menu.Extras.RRange3:Value(), Speed = CurrentRSpeed, Collision = false})
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
		local RspellData = {speed = CurrentRSpeed, range = Menu.Extras.RRange:Value(), delay = 1, radius = 70, collision = {nil}, type = "linear"}
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
			Control.CastSpell(HK_R, pred.CastPos)
		end
	else
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 1, Radius = 70, Range = Menu.Extras.RRange:Value(), Speed = CurrentRSpeed, Collision = false})
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
			elseif IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) < 1500 and Menu.ks.UseW:Value() then
				if getdmg("W", enemy, myHero) > enemy.health then
					CastW(enemy)
				end
			end
		end
	end	
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

function CheckImmobile()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if Ready(_E) and IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) < 900 then
			local IsImmobile = IsImmobileTarget(enemy)
			if IsImmobile then
				CastE(enemy)
			end
		end
	end
end

function CheckDashes()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if Ready(_E) and IsValid(enemy) and GetDistance(myHero.pos, enemy.pos) < 900 and enemy.pathing.isDashing then

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

function Check()
	QRange = myHero:GetSpellData(_Q).level*25 + 50 + 600
	if myHero.range < 530 then
		isFishBones = true
	else
		isFishBones = false
	end
	
	local Buff = GetBuffData(myHero, "jinxqramp")
	if Buff then
		FishStacks = Buff.stacks
	else
		FishStacks = 0
	end	
end

function JinxUltSpeed(Target)
	if Target ~= nil and IsValid(Target) then
		local Distance = GetDistance(myHero.pos, Target.pos)
		local Speed = (Distance > 1350 and (1350*1700+((Distance-1350)*2200))/Distance or 1700)
		return Speed
	end
end 

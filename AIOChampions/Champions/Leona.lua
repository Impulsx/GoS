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

local function GetEnemyCount(range, unit)
    local pos = unit.pos
	local count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if unit ~= hero and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function Ignore(unit)
	for i = 1, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff then
			if (buff.name == "MorganaE") or (buff.name == "bansheesveil") or (buff.name == "SivirE") or (buff.name == "NocturneShroudofDarkness") or (buff.name == "OlafRagnarok") or (buff.name == "PoppyDiplomaticImmunity") then
				return true
			end	
		end
	end
	return false
end

local function IsStunned(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.type == 5 and buff.count > 0 then 
			return buff
		end
	end
	return false
end

function LoadScript() 
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.06"}})

	Menu:MenuElement({type = MENU, id = "EDash", name = "AntiDash"})
	Menu.EDash:MenuElement({id = "E", name = "Use [E] on Dashing Enemies", value = true})
	Menu.EDash:MenuElement({id = "Change", name = "AntiDash Option", value = 1, drop = {"Auto Use", "Only in Combo"}})	

	Menu:MenuElement({type = MENU, id = "Eset", name = "E Settings"})
	Menu.Eset:MenuElement({id = "Range", name = "Max E range", value = 800, min = 50, max = 900, step = 10})	
	
	--Combo

	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true})
	Menu.Combo:MenuElement({id = "W", name = "Use [W]", value = true})
	Menu.Combo:MenuElement({id = "E", name = "Use [E]", value = true})
	Menu.Combo:MenuElement({id = "R", name = "Use [R]", value = true})
	Menu.Combo:MenuElement({id = "CountR", name = "Min enemies to use R", value = 2, min = 1, max = 5})
	Menu.Combo:MenuElement({id = "R2", name = "Use [R] Single Target", value = true})
	Menu.Combo:MenuElement({id = "RHP", name = "Use R if Single Target Hp lower than", value = 30, min = 0, max = 100, identifier = "%"})	

	--Harass

	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "Q", name = "Use [Q]", value = true})
	Menu.Harass:MenuElement({id = "W", name = "Use [W]", value = true})
	Menu.Harass:MenuElement({id = "E", name = "Use [E]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana", value = 30, min = 0, max = 100, identifier = "%"})

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})

	
	EData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 900, Speed = 2000, Collision = false
	}
	
	EspellData = {speed = 2000, range = 900, delay = 0.25, radius = 70, collision = {nil}, type = "linear"}	
	
	RData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.85, Radius = 250, Range = 1200, Speed = math.huge, Collision = false
	}	
	
	R1spellData = {speed = math.huge, range = 1200, delay = 0.85, radius = 100, collision = {nil}, type = "circular"}	

	R2spellData = {speed = math.huge, range = 1200, delay = 0.85, radius = 250, collision = {nil}, type = "circular"}		
	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end	
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, Menu.Eset.Range:Value(), 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 1200, 1, DrawColor(225, 225, 0, 10))
		end
	end)	
end

local StopOrb1 = false
local StopOrb2 = false
local IsCastingE = false
function Tick()

local currSpell = myHero.activeSpell
if currSpell and currSpell.valid and myHero.isChanneling and currSpell.name == "LeonaZenithBlade" then
	IsCastingE = true
else
	IsCastingE = false
end

if StopOrb1 then
	DelayAction(function()
		SetMovement(true)
		SetAttack(true)
		StopOrb1 = false		
	end,0.25)
end

if StopOrb2 then
	DelayAction(function()
		SetMovement(true)
		SetAttack(true)
		StopOrb2 = false		
	end,0.65)
end

if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.EDash.E:Value() and Menu.EDash.Change:Value() == 2 then
			AntiDash()
		end
		Combo()
	elseif Mode == "Harass" then
		Harass()
	end
	
	if Menu.EDash.E:Value() and Menu.EDash.Change:Value() == 1 then
		AntiDash()
	end	
end

function AntiDash()
	if Ready(_E) then
		for i, target in ipairs(GetEnemyHeroes()) do
			if target and myHero.pos:DistanceTo(target.pos) < 900 and target.pathing.isDashing then
				if GetDistanceSqr(target.pathing.endPos, myHero.pos) < GetDistanceSqr(target.pos, myHero.pos) then
					CastE(target)
					return
				end
			end	
				
			for k, Ally in ipairs(GetAllyHeroes()) do
				if Ally and myHero.pos:DistanceTo(Ally.pos) < 800 then
					if target and Ally.pos:DistanceTo(target.pos) < 900 and target.pathing.isDashing then						
						if GetDistanceSqr(target.pathing.endPos, Ally.pos) < GetDistanceSqr(target.pos, Ally.pos) then
							CastE(target)
						end
					end	
				end
			end	
		end
	end	
end

function Combo()
local target = GetTarget(1150)
if target == nil then return end

	if Menu.Combo.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= Menu.Eset.Range:Value()  and StopOrb2 == false then
		local Stunned = IsStunned(target)
		if Stunned then			
			if Stunned.duration <= 0.3 then			
				CastE(target)
			end	
		else
			CastE(target)
		end	
	end
	
	if Menu.Combo.W:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 250 then
		Control.CastSpell(HK_W)
	end
	
	if Menu.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 275 and not Ignore(target) and StopOrb1 == false and StopOrb2 == false then
		local Stunned = IsStunned(target)
		if Stunned then		
			if Stunned.duration <= 0.5 then			
				Control.CastSpell(HK_Q)
				Control.Attack(target)
			end	
		else
			Control.CastSpell(HK_Q)
			Control.Attack(target)
		end	
	end

	if Menu.Combo.R2:Value() and Ready(_R) and not IsCastingE and myHero.pos:DistanceTo(target.pos) < 1150 and target.health/target.maxHealth <= Menu.Combo.RHP:Value()/100 and StopOrb1 == false then
		local Stunned = IsStunned(target)
		if Stunned then
			if Stunned.duration <= 0.9 then			
				CastR(target)
			end	
		else
			CastR(target)
		end	
	end
	
	if Menu.Combo.R:Value() and Ready(_R) and not IsCastingE and GetEnemyCount(1200, myHero) >= Menu.Combo.CountR:Value() and StopOrb1 == false then
		CastR2(target)
	end
end

function Harass()
local target = GetTarget(900)
if target == nil or myHero.mana/myHero.maxMana < Menu.Harass.Mana:Value()/100 then return end

	if Menu.Harass.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) <= Menu.Eset.Range:Value() then
		local Stunned = IsStunned(target)
		if Stunned then
			if Stunned.duration <= 0.3 then
				CastE(target)
			end	
		else
			CastE(target)
		end	
	end
	
	if Menu.Harass.W:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 250 then
		Control.CastSpell(HK_W)
	end
	
	if Menu.Harass.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 275 and not Ignore(target) and StopOrb1 == false then
		local Stunned = IsStunned(target)
		if Stunned then		
			if Stunned.duration <= 0.5 then
				Control.CastSpell(HK_Q)
				Control.Attack(target)
			end	
		else
			Control.CastSpell(HK_Q)
			Control.Attack(target)
		end	
	end
end

function CastE(unit)
	if not Ignore(unit) then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, EData, myHero)			
			if pred.Hitchance >= Menu.Pred.PredE:Value()+1 then
				SetMovement(false)
				SetAttack(false)
				StopOrb1 = true
				Control.CastSpell(HK_E, pred.CastPosition)
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, EspellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredE:Value(), pred.HitChance) then
				SetMovement(false)
				SetAttack(false)				
				StopOrb1 = true
				Control.CastSpell(HK_E, pred.CastPos)
			end
		else
			local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 900, Speed = 2000, Collision = false})
			EPrediction:GetPrediction(unit, myHero)
			if EPrediction:CanHit(Menu.Pred.PredE:Value() + 1) then
				SetMovement(false)
				SetAttack(false)				
				StopOrb1 = true
				Control.CastSpell(HK_E, EPrediction.CastPosition)
			end				
		end
	end
end	

function CastR(unit)
	if not Ignore(unit) then
		if Menu.Pred.Change:Value() == 1 then
			local pred = GetGamsteronPrediction(unit, RData, myHero)			
			if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
				SetMovement(false)
				SetAttack(false)				
				StopOrb2 = true
				Control.CastSpell(HK_R, pred.CastPosition)
			end
		elseif Menu.Pred.Change:Value() == 2 then
			local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, R1spellData)
			if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
				SetMovement(false)
				SetAttack(false)				
				StopOrb2 = true
				Control.CastSpell(HK_R, pred.CastPos)
			end
		else
			local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.85, Radius = 100, Range = 1200, Speed = math.huge, Collision = false})
			RPrediction:GetPrediction(unit, myHero)
			if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
				SetMovement(false)
				SetAttack(false)				
				StopOrb2 = true
				Control.CastSpell(HK_R, RPrediction.CastPosition)
			end				
		end
	end	
end

function CastR2(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, RData, myHero)			
		if pred.Hitchance >= Menu.Pred.PredR:Value()+1 and GetEnemyCount(500, unit) >= Menu.Combo.CountR:Value() then
			SetMovement(false)
			SetAttack(false)				
			StopOrb2 = true
			Control.CastSpell(HK_R, pred.CastPosition)
		end
		
	else
		
		for i, target in ipairs(GetEnemyHeroes()) do
			if Menu.Pred.Change:Value() == 2 then		
				local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, target, R2spellData)
				if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
					if pred.HitCount >= Menu.Combo.CountR:Value() then
						SetMovement(false)
						SetAttack(false)							
						StopOrb2 = true
						Control.CastSpell(HK_R, pred.CastPos)
					end	
				end
			else
				local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.85, Radius = 250, Range = 1200, Speed = math.huge, Collision = false})
				local minhitchance = Menu.Pred.PredR:Value() + 1
				local aoeresult = RPrediction:GetAOEPrediction(myHero)
				local bestaoe = nil
				local bestcount = 0
				local bestdistance = 1200
			   
				for i = 1, #aoeresult do
					local aoe = aoeresult[i]
					if aoe.HitChance >= minhitchance and aoe.Count >= Menu.Combo.CountR:Value() then
						if aoe.Count > bestcount or (aoe.Count == bestcount and aoe.Distance < bestdistance) then
							bestdistance = aoe.Distance
							bestcount = aoe.Count
							bestaoe = aoe
						end
					end
				end
				
				if bestaoe then
					SetMovement(false)
					SetAttack(false)						
					StopOrb2 = true
					Control.CastSpell(HK_R, bestaoe.CastPosition)			 
				end			
			end
		end	
	end	
end

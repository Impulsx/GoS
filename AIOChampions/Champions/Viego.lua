
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
	for i, hero in ipairs(GetEnemyHeroes()) do
	local Range = range * range
		if GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local WStart = 0
function LoadScript() 

	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})			
	 	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "Not Transformed [R] KS", value = true})
	Menu.Combo:MenuElement({id = "Soul", name = "Cast Spells if have Soul ?", value = true})	
	  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})			
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true}) 
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})		

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})		

	WData = {Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 900, Speed = 1300, Collision = true, CollisionTypes = {_G.COLLISION_MINION}}	
	WspellData = {speed = 1300, range = 900, delay = 0.25, radius = 60, collision = {"minion"}, type = "linear"}	
  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end

		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 600, 1, DrawColor(255, 225, 255, 10))
		end                                                 
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
		DrawCircle(myHero, 900, 1, DrawColor(225, 225, 0, 10))
		end                                                
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 500, 1, DrawColor(225, 225, 0, 10))
		end		
	end)		
end

function Tick()
	if Control.IsKeyDown(HK_W) and (not Ready(_W) or clock() - WStart >= 1.5) then
		SetMovement(true)
		Control.KeyUp(HK_W)
	end	
	
	if MyHeroNotReady() then return end
	local Mode = GetMode()
	if Mode == "Combo" then
		if HasBuff(myHero, "viegopassivetransform") then
			if Menu.Combo.Soul:Value() then
				Combo2()
			end
		else
			Combo1()
		end	
	elseif Mode == "Clear" then
		Push()
		JungleClear()		
	end
end

function Combo1()
local target = GetTarget(900)     	
if target == nil then return end
	if IsValid(target) then

		if Control.IsKeyDown(HK_W) then CheckCastW(target) return end
		
		if myHero.pos:DistanceTo(target.pos) < 500 and Menu.Combo.UseR:Value() and Ready(_R) and getdmg("R", target, myHero) >= target.health then
			Control.CastSpell(HK_R, target.pos)	
		else	
				
			if myHero.pos:DistanceTo(target.pos) < 600 and Menu.Combo.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q, target.pos)	
			end

			if Menu.Combo.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E, target.pos)	
			end	

			if Menu.Combo.UseW:Value() and Ready(_W) and not HasBuff(myHero, "ViegoW") then
				Control.KeyDown(HK_W)
				WStart = clock()		
			end	
		end	
	end	
end	

function Combo2()
local target = GetTarget(2000)     	
if target == nil then return end
	if IsValid(target) then
	local Buff = GetBuffData(myHero, "viegopassivetransform")

		if (Buff and Buff.duration <= 1) or (not Ready(_Q) and not Ready(_W) and not Ready(_E)) or (getdmg("R", target, myHero) >= target.health) and myHero.pos:DistanceTo(target.pos) < 500  and Ready(_R) then
			Control.CastSpell(HK_R, target.pos)	
		else	
				
			if myHero:GetSpellData(_Q).range == 0 and Ready(Q) then Control.CastSpell(HK_Q) end
			if myHero.pos:DistanceTo(target.pos) < myHero:GetSpellData(_Q).range and Ready(_Q) then
				if myHero:GetSpellData(_Q).width > 0 and myHero:GetSpellData(_Q).speed > 0 and myHero:GetSpellData(_Q).castFrame > 0 then
					PredCast(target, _Q)
				else	
					Control.CastSpell(HK_Q, target.pos)	
				end	
			end

			if myHero:GetSpellData(_E).range == 0 and Ready(Q) then Control.CastSpell(HK_E) end
			if myHero.pos:DistanceTo(target.pos) < myHero:GetSpellData(_E).range and Ready(_E) then
				if myHero:GetSpellData(_E).width > 0 and myHero:GetSpellData(_E).speed > 0 and myHero:GetSpellData(_E).castFrame > 0 then
					PredCast(target, _E)
				else				
					Control.CastSpell(HK_E, target.pos)
				end	
			end	

			if myHero:GetSpellData(_W).range == 0 and Ready(Q) then Control.CastSpell(HK_W) end
			if myHero.pos:DistanceTo(target.pos) < myHero:GetSpellData(_W).range and Ready(_W) then
				if myHero:GetSpellData(_W).width > 0 and myHero:GetSpellData(_W).speed > 0 and myHero:GetSpellData(_W).castFrame > 0 then
					PredCast(target, _W)
				else				
					Control.CastSpell(HK_W, target.pos)
				end		
			end	
		end	
	end	
end		

function Push()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)

		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) and Ready(_Q) and Menu.Clear.UseQ:Value() then
			Control.CastSpell(HK_Q, minion.pos)
		end
		
		if myHero.pos:DistanceTo(minion.pos) <= 300 and minion.team == TEAM_ENEMY and IsValid(minion) and Ready(_W) and Menu.Clear.UseW:Value() then
			Control.CastSpell(HK_W, minion.pos)
		end		
	end
end

function JungleClear()	
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        
		if Menu.JClear.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_JUNGLE and IsValid(minion) then 
			Control.CastSpell(HK_Q, minion.pos)
        end
		
		if Menu.JClear.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_JUNGLE and IsValid(minion) then 
			Control.CastSpell(HK_W, minion.pos)
        end		
    end
end

function CheckCastW(unit)
	local WDmg = getdmg("W", unit, myHero)	
	if GetDistance(unit.pos, myHero.pos) < 800 then		
		if GetDistance(unit.pos, myHero.pos) > 400 then
			if clock() - WStart >= 1 then
				CastW(unit)
			end
		else
			CastW(unit)
		end
	else
		CastW(unit)
	end
end

function CastW(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
			SetMovement(false)
			Control.CastSpell(HK_W, pred.CastPosition)
			SetMovement(true)
		end
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
			SetMovement(false)
			Control.CastSpell(HK_W, pred.CastPos)
			SetMovement(true)
		end
	else
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 900, Speed = 1300, Collision = false})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
			SetMovement(false)
			Control.CastSpell(HK_W, WPrediction.CastPosition)
			SetMovement(true)
		end				
	end
end

function PredCast(unit, Spell)
	local SpellType = GGPrediction.SPELLTYPE_LINE
	local SpellDelay = myHero:GetSpellData(Spell).castFrame/10
	local SpellRadius = myHero:GetSpellData(Spell).width
	local SpellSpeed = myHero:GetSpellData(Spell).speed
	local SpellRange = myHero:GetSpellData(Spell).range
	
	if SpellRadius > 100 then
		SpellType = GGPrediction.SPELLTYPE_CIRCLE
	end
	
	if SpellDelay > 0.5 then
		SpellSpeed = MathHuge
	end	
		
	if Spell == _Q then 
		local QPrediction = GGPrediction:SpellPrediction({Type = SpellType, Delay = SpellDelay, Radius = SpellRadius, Range = SpellRange, Speed = SpellSpeed, Collision = false})
		QPrediction:GetPrediction(unit, myHero)
		if QPrediction:CanHit(2) then
			Control.CastSpell(HK_Q, QPrediction.CastPosition)
		end	
	
	elseif Spell == _W then
		local WPrediction = GGPrediction:SpellPrediction({Type = SpellType, Delay = SpellDelay, Radius = SpellRadius, Range = SpellRange, Speed = SpellSpeed, Collision = false})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(2) then
			Control.CastSpell(HK_W, WPrediction.CastPosition)
		end	
	else
		if Spell == _E then
			local EPrediction = GGPrediction:SpellPrediction({Type = SpellType, Delay = SpellDelay, Radius = SpellRadius, Range = SpellRange, Speed = SpellSpeed, Collision = false})
			EPrediction:GetPrediction(unit, myHero)
			if EPrediction:CanHit(2) then
				Control.CastSpell(HK_E, EPrediction.CastPosition)
			end	
		end		
	end
end

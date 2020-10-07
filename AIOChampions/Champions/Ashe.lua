local InterruptingSpells = {
	["CaitlynAceintheHole"] 	= {charName = "Caitlyn", 		slot = _R, 	 	displayName = "Ace in the Hole"},
	["Crowstorm"] 				= {charName = "Fiddlesticks", 	slot = _R, 	 	displayName = "Crowstorm"},
	["GalioR"] 					= {charName = "Galio", 			slot = _R, 	 	displayName = "Hero's Entrance"},
	["KarthusFallenOne"]	 	= {charName = "Karthus", 		slot = _R, 		displayName = "Requiem"},
	["KatarinaR"] 				= {charName = "Katarina", 		slot = _R,  	displayName = "Death Lotus"},
	["LucianR"] 				= {charName = "Lucian", 		slot = _R, 		displayName = "The Culling"},
	["AlZaharNetherGrasp"] 		= {charName = "Malzahar", 		slot = _R, 		displayName = "Nether Grasp"},
	["MissFortuneBulletTime"] 	= {charName = "MissFortune", 	slot = _R, 		displayName = "Bullet Time"},
	["AbsoluteZero"] 			= {charName = "Nunu", 			slot = _R, 		displayName = "Absolute Zero"},
	["PantheonRFall"] 			= {charName = "Pantheon", 		slot = _R, 		displayName = "Grand Skyfall [Fall]"},
	["PantheonRJump"] 			= {charName = "Pantheon", 		slot = _R, 	 	displayName = "Grand Skyfall [Jump]"},
	["ShenR"] 					= {charName = "Shen", 			slot = _R, 		displayName = "Stand United"},
	["Destiny"] 				= {charName = "TwistedFate", 	slot = _R, 	 	displayName = "Destiny"},
	["VelKozR"] 				= {charName = "VelKoz", 		slot = _R,  	displayName = "Life Form Disintegration Ray"},
	["XerathLocusOfPower2"] 	= {charName = "Xerath", 		slot = _R, 	 	displayName = "Rite of the Arcane"},
	["ZacR"] 					= {charName = "Zac", 			slot = _R,  	displayName = "Let's Bounce!"}
}

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

local function GotBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff.count 
		end
	end
	return 0
end

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	

	--AutoE  
	Menu:MenuElement({type = MENU, id = "AutoE", name = "E Settings"})
	Menu.AutoE:MenuElement({name = " ", drop = {"Only if Target killable ( Combo Mode )"}})	
	Menu.AutoE:MenuElement({id = "UseE", name = "AutoE on not visible Target last pos seen", value = true})	
	Menu.AutoE:MenuElement({id = "HP", name = "[E] if Target Hp lower than -->", value = 40, min = 0, max = 100, identifier = "%"})	
	Menu.AutoE:MenuElement({id = "range", name = "Check Range for killable Target", value = 1100, min = 500, max = 2000, identifier = "range"})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseW2", name = "Try [W] before [Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "Semi-Manual [R] key", key = string.byte("T")})
	Menu.Combo:MenuElement({id = "Rrange", name = "[R] range", value = 4000, min = 0, max = 25000, identifier = "range"})
	Menu.Combo:MenuElement({type = MENU, id = "BlockListR", name = "Block List [R]"})
	DelayAction(function()		
		for i, unit in ipairs(GetEnemyHeroes()) do
			Menu.Combo.BlockListR:MenuElement({id = unit.networkID, name = "Block [R] on " ..unit.charName, value = false})
		end
	end,0.1)

	--AutoUlt
	Menu:MenuElement({type = MENU, id = "AutoR", name = "Auto Ult interrupting Spells"})
	Menu.AutoR:MenuElement({id = "UseR", name = "Auto [R]", value = true})
	Menu.AutoR:MenuElement({id = "range", name = "Check Range for Interrupting Spells", value = 2000, min = 0, max = 12000, identifier = "range"})	
	Menu.AutoR:MenuElement({type = MENU, id = "list", name = "Possible Interrupting Spells"})	
	self.Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()
		for i, spell in pairs(InterruptingSpells) do
			for j, hero in ipairs(GetEnemyHeroes()) do
				if not InterruptingSpells[i] then return end
				if spell.charName == hero.charName then
					if not Menu.AutoR.list[i] then Menu.AutoR.list:MenuElement({id = "Use"..i, name = "Use on "..spell.charName.." "..Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.1)	

	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "QCount", name ="[Q] min Minions", value = 3, min = 1, max = 7, step = 1, identifier = "Minion/s"}) 
	Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})		
	Menu.Clear:MenuElement({id = "WCount", name ="[W] min Minions", value = 3, min = 1, max = 7, step = 1, identifier = "Minion/s"})  	
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true}) 	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  	

	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = false})	
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw Combo [R] Range", value = false})
		

	WData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 20, Range = 1200, Speed = 2000, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION}
	}
	
	WspellData = {speed = 2000, range = 1200, delay = 0.25, radius = 20, collision = {"minion"}, type = "linear"}	

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 130, Range = 25000, Speed = 1600, Collision = false
	}
	
	RspellData = {speed = 1600, range = 25000, delay = 0.25, radius = 130, collision = {nil}, type = "linear"}	

	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) PreAttack(...) end)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(function(...) PreAttack(...) end)
	end

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.Drawing.DrawW:Value() and Ready(_W) then
			DrawCircle(myHero, 1200, 1, DrawColor(225, 225, 125, 10))
		end	
		
		if Menu.Drawing.DrawR:Value() and Ready(_R) then
			DrawCircle(myHero, Menu.Combo.Rrange:Value(), 1, DrawColor(255, 225, 255, 10))
		end 
	end)	
end

local CanCastQ = false
function Tick()	
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		ComboE()
		ComboR()
	elseif Mode == "Harass" then
		Harass()	
	elseif Mode == "Clear" then
		Clear()
		JungleClear()		
	end

	if Menu.AutoR.UseR:Value() and Ready(_R) then 
		AutoR()
	end	
end

function PreAttack(args)
	if CanCastQ and GotBuff(myHero, "asheqcastready") == 0 then CanCastQ = false end
	local target = GetTarget(myHero.range-50)
	if target == nil then return end
	local Mode = GetMode()
	if IsValid(target) and Mode == "Combo" then
		if Ready(_Q) and GotBuff(myHero, "asheqcastready") == 4 then
			CanCastQ = true
		end
	end
	CanCastQ = false
end

function Combo()
	local target = GetTarget(1200)
	if target == nil then return end
	
	if IsValid(target) then
		if Menu.Combo.UseW2:Value() and Menu.Combo.UseQ:Value() and Ready(_W) then
			if CanCastQ then
				CastWQ(target)
			end
		else
			if Menu.Combo.UseW:Value() and Ready(_W) then
				CastW(target)
			end
			
			if Menu.Combo.UseQ:Value() and Ready(_Q) and CanCastQ and myHero.pos:DistanceTo(target.pos) <= myHero.range-50 then
				Control.CastSpell(HK_Q)
			end			
		end
	end	
end

function ComboR()
local target = GetTarget(Menu.Combo.Rrange:Value())
if target == nil then return end
	
	if Ready(_R) and Menu.Combo.UseR:Value() and IsValid(target) then		
		if Menu.Combo.BlockListR[target.networkID] and not Menu.Combo.BlockListR[target.networkID]:Value() then
			CastR(target)
		end
	end
end

function AutoR()
	if not Menu.AutoR.list then return end
	for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) > Menu.AutoR.range:Value() then return end
		local spell = target.activeSpell	
		
		if spell and spell.isChanneling then
			if InterruptingSpells[spell.name] and Menu.AutoR.list["Use"..spell.name]:Value() then
				CastR(target)
			end
		end
	end	
end

function ComboE()
	local ETarget = nil
	--print(ETarget)
	if Ready(_E) and Menu.AutoE.UseE:Value() then
		for i, target in ipairs(GetEnemyHeroes()) do
		if myHero.pos:DistanceTo(target.pos) > Menu.AutoE.range:Value() then return end
			
			if ETarget == nil and IsValid(target) and target.health/target.maxHealth <= Menu.AutoE.HP:Value()/100 then
				ETarget = target
			end
			
			if ETarget then
				print(ETarget.pos)
				if not ETarget.visible and myHero.pos:DistanceTo(ETarget.pos) <= Menu.AutoE.range:Value()+500 then
					Control.CastSpell(HK_E, ETarget.pos)
				else
					ETarget = nil
				end
			end
		end
	else
		ETarget = nil
	end
end	
	
function Harass()
local target = GetTarget(1200)
if target == nil then return end
	
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then		
		if Menu.Harass.UseW:Value() and Ready(_W) then
			CastW(target)
		end
	end
end

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) < 1200 and minion.team == TEAM_ENEMY and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then					
			
			if Ready(_Q) and Menu.Clear.UseQ:Value() and GotBuff(myHero, "asheqcastready") == 4 and GetMinionCount(myHero.range, myHero) >= Menu.Clear.QCount:Value() then
				Control.CastSpell(HK_Q)
			end	

			if Ready(_W) and Menu.Clear.UseW:Value() and GetMinionCount(500, minion) >= Menu.Clear.WCount:Value() then
				Control.CastSpell(HK_W, minion.pos)
			end				
		end
	end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)	

		if myHero.pos:DistanceTo(minion.pos) <= 1200 and minion.team == TEAM_JUNGLE and IsValid(minion) and myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100 then	
			
			if Ready(_Q) and Menu.JClear.UseQ:Value() and GotBuff(myHero, "asheqcastready") == 4 and myHero.pos:DistanceTo(minion.pos) < myHero.range then
				Control.CastSpell(HK_Q)
			end 

			if Ready(_W) and Menu.JClear.UseW:Value() then
				Control.CastSpell(HK_W, minion.pos)
			end 			
		end
	end
end

function CastW(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
			Control.CastSpell(HK_W, pred.CastPosition)
		end
		
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
			Control.CastSpell(HK_W, pred.CastPos)
		end
		
	else
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 20, Range = 1200, Speed = 2000, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
			Control.CastSpell(HK_W, WPrediction.CastPosition)
		end	
	end
end

function CastWQ(unit)
	if Menu.Pred.Change:Value() == 1 then
		local pred = GetGamsteronPrediction(unit, WData, myHero)
		if pred.Hitchance >= Menu.Pred.PredW:Value()+1 then
			Control.CastSpell(HK_W, pred.CastPosition)
			DelayAction(function()
				Control.CastSpell(HK_Q)
			end,0.3)
		end
		
	elseif Menu.Pred.Change:Value() == 2 then
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WspellData)
		if pred.CastPos and ConvertToHitChance(Menu.Pred.PredW:Value(), pred.HitChance) then
			Control.CastSpell(HK_W, pred.CastPos)
			DelayAction(function()
				Control.CastSpell(HK_Q)
			end,0.3)			
		end
		
	else
		local WPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 20, Range = 1200, Speed = 2000, Collision = true, CollisionTypes = {GGPrediction.COLLISION_MINION}})
		WPrediction:GetPrediction(unit, myHero)
		if WPrediction:CanHit(Menu.Pred.PredW:Value() + 1) then
			Control.CastSpell(HK_W, WPrediction.CastPosition)
			DelayAction(function()
				Control.CastSpell(HK_Q)
			end,0.3)			
		end	
	end
end

function CastR(unit)
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
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 130, Range = 25000, Speed = 1600, Collision = false})
		RPrediction:GetPrediction(unit, myHero)
		if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
			Control.CastSpell(HK_R, RPrediction.CastPosition)
		end	
	end
end
local function GetEnemyHeroes()
	return Enemies
end 

local function GetInventorySlotItem(itemID)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
    for _, j in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
        if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
    end
    return nil
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

local function EnemiesAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i = 1, GameHeroCount() do
        local hero = GameHero(i)
        if (IsValid(hero) and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end

local Rrange = (myHero.ms / 100) * 250 - 100
function LoadScript()
	 
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.07"}})	
	
	--Combo--
	Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	Menu.ComboMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	Menu.ComboMode:MenuElement({id = "UseW", name = "W: Blood Hunt(< 20%)", value = true})
	Menu.ComboMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	Menu.ComboMode:MenuElement({id = "UseR", name = "R: Infinite Duress", value = true})
	Menu.ComboMode:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	Menu.ComboMode:MenuElement({id = "UseHYDRA", name = "Use Hydra", value = true})
	Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw Killable", value = true})
	Menu.ComboMode:MenuElement({id = "DrawRange", name = "Draw RRange", value = false})	
	Menu.ComboMode:MenuElement({type = MENU, id = "XY", name = "Text Pos Settings"})	
	Menu.ComboMode.XY:MenuElement({id = "x", name = "Pos: [X]", value = 0, min = 0, max = 1500, step = 10})
	Menu.ComboMode.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})
	Menu.ComboMode:MenuElement({name = " ", drop = {"Insta E Option for Combo/Harass/Clear"}})	
	Menu.ComboMode:MenuElement({id = "Key", name = "Toggle: E InstaKey", key = string.byte("T"), toggle = true})	
	
	--Harass--
	Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	Menu.HarassMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	Menu.HarassMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	Menu.HarassMode:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})

	--Lane/JungleClear
	Menu:MenuElement({id = "ClearMode", name = "Lane/JungleClear", type = MENU})
	Menu.ClearMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	Menu.ClearMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	Menu.ClearMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	Menu.ClearMode:MenuElement({id = "UseHYDRA", name = "Use Hydra", value = true})	
	Menu.ClearMode:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredR", name = "Hitchance [R]", value = 1, drop = {"Normal", "High", "Immobile"}})

	RData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.4, Radius = 55, Range = Rrange, Speed = 1800, Collision = false
	}
	
	RspellData = {speed = 1800, range = Rrange, delay = 0.4, radius = 55, collision = {nil}, type = "linear"}		
     	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if Menu.ComboMode.Key:Value() then 
			DrawText("Insta E: On", 15, Menu.ComboMode.XY.x:Value()+96, Menu.ComboMode.XY.y:Value()+15, DrawColor(255, 0, 255, 0))
		else
			DrawText("Insta E: Off", 15, Menu.ComboMode.XY.x:Value()+96, Menu.ComboMode.XY.y:Value()+15, DrawColor(255, 255, 0, 0)) 
		end
		
		if myHero.dead then return end
		if Menu.ComboMode.DrawRange:Value() and Ready(_R) then DrawCircle(myHero, Rrange, DrawColor(255, 000, 222, 255)) end
		if Menu.ComboMode.DrawDamage:Value() then
			for i, hero in pairs(GetEnemyHeroes()) do
				if hero.dead and IsValid(hero) then
					local QDamage = (Ready(_Q) and getdmg("Q", hero, myHero) or 0)
					local RDamage = (Ready(_R) and getdmg("R", hero, myHero) or 0)
					local damage = (QDamage + RDamage)
					if damage > hero.health then
						DrawText("Killable", 24, hero.pos2D.x, hero.pos2D.y, DrawColor(0xFF00FF00))
					end
				end
			end	
		end
	end)		
end

function Tick()
if MyHeroNotReady() then return end

if Ready(_R) and Rrange ~= (myHero.ms / 100) * 250 then
	Rrange = (myHero.ms / 100) * 250 - 100
end
local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.ComboMode.comboActive:Value() then
			Combo()
		end

	elseif Mode == "Harass" then
		if Menu.HarassMode.harassActive:Value() then
			Harass()
		end
	elseif Mode == "Clear" then
		if Menu.ClearMode.clearActive:Value() then
			Jungle()
		end
	end
end

function Combo()
	if Menu.ComboMode.UseHYDRA:Value() then
    	local HTarget = GetTarget(300)
		  
		if HTarget and IsValid(HTarget) then
            UseHydra()
        end
    end

    if Ready(_E) then 
		local ETarget = GetTarget(375)
		if ETarget and Menu.ComboMode.UseE:Value() and IsValid(ETarget) then 
			Control.CastSpell(HK_E)
			if Menu.ComboMode.Key:Value() then
				if myHero.pos:DistanceTo(ETarget.pos) < 375 and HasBuff(myHero, "Primal Howl") then
					Control.CastSpell(HK_E)
				end	
			end
		end
	end

	if Ready(_Q) then 
		local QTarget = GetTarget(350)
		if QTarget and Menu.ComboMode.UseQ:Value() and IsValid(QTarget) then
            if myHero.pos:DistanceTo(QTarget.pos) < 350 then
				if EnemiesAround(QTarget, 600) > 1 then
					Control.CastSpell(HK_Q, QTarget)
				else
					Control.SetCursorPos(QTarget.pos) 
					Control.KeyDown(HK_Q)
					DelayAction(function()
						Control.KeyUp(HK_Q)
					end,2)	
				end	
            end
		end
	end
	
	if Ready(_W) then 
		local WTarget = GetTarget(4000)
		if WTarget and Menu.ComboMode.UseW:Value() and IsValid(WTarget) then
			if myHero.pos:DistanceTo(WTarget.pos) < 4000 and WTarget.health/WTarget.maxHealth <= 0.20 then
				Control.CastSpell(HK_W)
			end
		end
	end	

    if Ready(_R) then 
		local RTarget = GetTarget(Rrange)
        if RTarget and Menu.ComboMode.UseR:Value() and IsValid(RTarget) then			
			if myHero.pos:DistanceTo(RTarget.pos) <= Rrange then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(RTarget, RData, myHero)
					if pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
						if EnemiesAround(RTarget, 600) > 1 and not HasBuff(myHero, "Primal Howl") then
							Control.CastSpell(HK_E)
						end	
						Control.CastSpell(HK_R, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, RTarget, RspellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredR:Value(), pred.HitChance) then
						if EnemiesAround(RTarget, 600) > 1 and not HasBuff(myHero, "Primal Howl") then
							Control.CastSpell(HK_E)
						end						
						Control.CastSpell(HK_R, pred.CastPos)
					end
				else
					CastGGPred(RTarget)
				end
			end	
        end
    end
end

function CastGGPred(unit)
	local RPrediction = GGPrediction:SpellPrediction({Delay = 0.4, Radius = 55, Range = Rrange, Speed = 1800, Collision = false, Type = GGPrediction.SPELLTYPE_LINE})
	RPrediction:GetPrediction(unit, myHero)
	if RPrediction:CanHit(Menu.Pred.PredR:Value() + 1) then
		if EnemiesAround(unit, 600) > 1 and not HasBuff(myHero, "Primal Howl") then
			Control.CastSpell(HK_E)
		end	
		Control.CastSpell(HK_R, RPrediction.CastPosition)
	end	
end

function Harass()
    if Menu.ComboMode.UseHYDRA:Value() then
        local HTarget = GetTarget(300)
		if HTarget == nil then return end 
		if IsValid(HTarget) then
            UseHydra()
        end
    end
	
    if Ready(_E) then 
		local ETarget = GetTarget(375)
		if ETarget and Menu.HarassMode.UseE:Value() and IsValid(ETarget) then 
			Control.CastSpell(HK_E)
			if Menu.ComboMode.Key:Value() then
				if myHero.pos:DistanceTo(ETarget.pos) < 375 and HasBuff(myHero, "Primal Howl") then
					Control.CastSpell(HK_E)
				end	
			end
		end
	end	

	if Ready(_Q) then 
		local QTarget = GetTarget(350)
		if QTarget == nil then return end 
		if Menu.HarassMode.UseQ:Value() and IsValid(QTarget) then
            if myHero.pos:DistanceTo(QTarget.pos) < 350 then
				Control.CastSpell(HK_Q, QTarget)
            end
		end
	end
end

function Jungle()
	for i = 1, GameMinionCount() do
	local minion = GameMinion(i)
		
		if (minion.team == TEAM_ENEMY or minion.team == TEAM_JUNGLE) and myHero.pos:DistanceTo(minion.pos) <= 400 then
		
			if Ready(_E) then 
				if Menu.ClearMode.UseE:Value() and IsValid(minion) then 
					Control.CastSpell(HK_E)
					if Menu.ComboMode.Key:Value() then
						if myHero.pos:DistanceTo(minion.pos) < 375 and HasBuff(myHero, "Primal Howl") then
							Control.CastSpell(HK_E)
						end	
					end
				end
			end			

			if Menu.ClearMode.UseHYDRA:Value() and not Ready(_W) and IsValid(minion) then
				if myHero.pos:DistanceTo(minion.pos) < 300 and not HasBuff(minion, "Blood Hunt") then
					UseHydra()
				end
			end
			
			if Ready(_Q) then 
				if Menu.ClearMode.UseQ:Value() and IsValid(minion) then
					if myHero.pos:DistanceTo(minion.pos) < 350 then
						Control.CastSpell(HK_Q, minion)
					end
				end
			end

			if Ready(_W) then 
				if Menu.ClearMode.UseW:Value() and IsValid(minion) then
					if myHero.pos:DistanceTo(minion.pos) < 175 then
						Control.CastSpell(HK_W)
					end
				end
			end
		end
	end
end

function UseHydra()
local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
	if hydraitem then
		Control.CastSpell(ItemHotKey[hydraitem])
	end
end

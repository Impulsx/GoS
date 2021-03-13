
local function HasPoison(unit)
	for i = 0, unit.buffCount do 
	local buff = unit:GetBuff(i)
		if buff.type == 23 and GameTimer() < buff.expireTime - 0.141  then
			return true
		end
	end
	return false
end

local function MinionsNear(pos,range)
	local pos = pos.pos
	local N = 0
		for i = 1, GameMinionCount() do 
		local Minion = GameMinion(i)
		local Range = range * range
		if Minion.team == TEAM_ENEMY and Minion.pos:DistanceTo(pos) < Range then
			N = N + 1
		end
	end
	return N	
end

function LoadScript()
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.12"}})	
		Menu:MenuElement({name = " ", drop = {"General Settings"}})	
		
		--Combo   
		Menu:MenuElement({type = MENU, id = "combo", name = "Combo"})		
		Menu.combo:MenuElement({id = "Q", name = "Use Q", value = true})
		Menu.combo:MenuElement({id = "W", name = "Use W", value = true})
		Menu.combo:MenuElement({id = "E", name = "Use E", value = true})
		Menu.combo:MenuElement({id = "SR", name = "Manual R ", key = string.byte("A")})
		Menu.combo:MenuElement({id = "R", name = "Use R ", value = true})
		Menu.combo:MenuElement({id = "R2", name = "Use R Stun/Slow if killable", value = true})		
		Menu.combo:MenuElement({id = "Count", name = "Min facing Amount to hit R", value = 2, min = 1, max = 5, step = 1})
		Menu.combo:MenuElement({id = "P", name = "Use Panic R and Ghost", value = true})
		Menu.combo:MenuElement({id = "HP", name = "Min HP % to Panic R", value = 30, min = 0, max = 100, step = 1})
		Menu.combo:MenuElement({name = " ", drop = {"-------------------------------------------"}})		
		Menu.combo:MenuElement({name = " ", drop = {"-------------------------------------------"}})		
		Menu.combo:MenuElement({name = " ", drop = {"Block AutoAttack Settings"}})		
		Menu.combo:MenuElement({name = " ", drop = {"Turn off AutoAttack in LoL Options/Game/"}})
		Menu.combo:MenuElement({id = "Block", name = "Block AA in Combo for E", value = true})
		Menu.combo:MenuElement({id = "Cd", name = "Block AA if Cooldown E lower than", value = 0.55, min = 0, max = 0.8, step = 0.01, identifier = "sec"})		
		
		--Harass
		Menu:MenuElement({type = MENU, id = "harass", name = "Harass"})
		Menu.harass:MenuElement({id = "Q", name = "UseQ", value = true})
		Menu.harass:MenuElement({id = "E", name = "UseE only poisend", value = true})		
		
		--Clear
		Menu:MenuElement({type = MENU, id = "clear", name = "Clear"})
		Menu.clear:MenuElement({id = "Q", name = "Use Q", value = true})
		Menu.clear:MenuElement({id = "W", name = "Use W", value = true})
		Menu.clear:MenuElement({id = "Count", name = "Min Minions to hit W", value = 3, min = 1, max = 5, step = 1})		
		Menu.clear:MenuElement({id = "E", name = "Auto E Toggle Key", key = 84, toggle = true, value = true})
		Menu.clear:MenuElement({id = "E2", name = "Auto E off in Combo Mode", value = true})		
		
		--JungleClear
		Menu:MenuElement({type = MENU, id = "jclear", name = "JungleClear"})
		Menu.jclear:MenuElement({id = "Q", name = "Use Q", value = true})
		Menu.jclear:MenuElement({id = "W", name = "Use W", value = true})
		Menu.jclear:MenuElement({id = "E", name = "Use E[poisend or Lasthit]", value = true})		
		
		--KillSteal
		Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
		Menu.ks:MenuElement({id = "Q", name = "UseQ", value = true})
		Menu.ks:MenuElement({id = "W", name = "UseW", value = true})
		Menu.ks:MenuElement({id = "E", name = "UseE", value = true})
		
		--Prediction
		Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
		Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})	
		Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
		Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})		
		
		--RSetting
		Menu:MenuElement({type = MENU, id = "RS", name = "R Range Setting"})
		Menu.RS:MenuElement({id = "Rrange", name = "Max CastR Range", value = 700, min = 100, max = 825, identifier = "range"})			
		
		--Mana
		Menu:MenuElement({type = MENU, id = "mana", name = "Mana Settings"})
		Menu.mana:MenuElement({name = " ", drop = {"Harass [%]"}})
		Menu.mana:MenuElement({id = "Q", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Menu.mana:MenuElement({id = "W", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Menu.mana:MenuElement({id = "E", name = "E Mana", value = 5, min = 0, max = 100, step = 1})
		Menu.mana:MenuElement({id = "R", name = "R Mana", value = 5, min = 0, max = 100, step = 1})		
		Menu.mana:MenuElement({name = " ", drop = {"Lane/JungleClear [%]"}})
		Menu.mana:MenuElement({id = "QW", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Menu.mana:MenuElement({id = "WW", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Menu.mana:MenuElement({id = "EW", name = "E Mana", value = 10, min = 0, max = 100, step = 1})
		
		Menu:MenuElement({name = " ", drop = {"Advanced Settings"}})

		--Drawings
		Menu:MenuElement({type = MENU, id = "drawings", name = "Drawings"})
		Menu.drawings:MenuElement({id = "ON", name = "Enable Drawings", value = true})
		Menu.drawings:MenuElement({type = MENU, id = "XY", name = "Text Pos Settings"})	
		Menu.drawings.XY:MenuElement({id = "Text", name = "Draw AutoE Text", value = true})		
		Menu.drawings.XY:MenuElement({id = "x", name = "Pos: [X]", value = 700, min = 0, max = 1500, step = 10})
		Menu.drawings.XY:MenuElement({id = "y", name = "Pos: [Y]", value = 0, min = 0, max = 860, step = 10})		
		Menu.drawings:MenuElement({type = MENU, id = "Q", name = "Q"})
		Menu.drawings.Q:MenuElement({id = "ON", name = "Enabled", value = false})       
		Menu.drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Menu.drawings.Q:MenuElement({id = "Color", name = "Color", color = DrawColor(255, 255, 255, 255)})
		Menu.drawings:MenuElement({type = MENU, id = "W", name = "W"})
		Menu.drawings.W:MenuElement({id = "ON", name = "Enabled", value = false})       
		Menu.drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Menu.drawings.W:MenuElement({id = "Color", name = "Color", color = DrawColor(255, 255, 255, 255)})
		Menu.drawings:MenuElement({type = MENU, id = "E", name = "E"})
		Menu.drawings.E:MenuElement({id = "ON", name = "Enabled", value = false})       
		Menu.drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Menu.drawings.E:MenuElement({id = "Color", name = "Color", color = DrawColor(255, 255, 255, 255)})
		Menu.drawings:MenuElement({type = MENU, id = "R", name = "R"})
		Menu.drawings.R:MenuElement({id = "ON", name = "Enabled", value = false})       
		Menu.drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Menu.drawings.R:MenuElement({id = "Color", name = "Color", color = DrawColor(255, 255, 255, 255)})						
	
	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.75+ping, Radius = 80, Range = 850, Speed = MathHuge, Collision = false
	}
	
	spellData = {speed = MathHuge, range = 850, delay = 0.75+ping, radius = 80, collision = {nil}, type = "circular"}	
	
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	end	
  	                                           
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead == false and Menu.drawings.ON:Value() then
			
			if Menu.drawings.XY.Text:Value() then 
				DrawText("Auto E: ", 15, Menu.drawings.XY.x:Value(), Menu.drawings.XY.y:Value()+10, DrawColor(255, 225, 255, 0))
				if Menu.clear.E:Value() then 
					if Menu.clear.E2:Value() then
						if GetMode() ~= "Combo" then
							DrawText("ON", 15, Menu.drawings.XY.x:Value()+45, Menu.drawings.XY.y:Value()+10, DrawColor(255, 0, 255, 0))
						else						
							DrawText("OFF", 15, Menu.drawings.XY.x:Value()+45, Menu.drawings.XY.y:Value()+10, DrawColor(255, 255, 0, 0)) 
						end	
					else
						DrawText("ON", 15, Menu.drawings.XY.x:Value()+45, Menu.drawings.XY.y:Value()+10, DrawColor(255, 0, 255, 0))
					end	
				else
					DrawText("OFF", 15, Menu.drawings.XY.x:Value()+45, Menu.drawings.XY.y:Value()+10, DrawColor(255, 255, 0, 0)) 
				end
			end
			if Menu.drawings.Q.ON:Value() then
				DrawCircle(myHero.pos, 850, Menu.drawings.Q.Width:Value(), Menu.drawings.Q.Color:Value())
			end
			if Menu.drawings.W.ON:Value() then
				DrawCircle(myHero.pos, 340, Menu.drawings.W.Width:Value(), Menu.drawings.W.Color:Value())
				DrawCircle(myHero.pos, 960, Menu.drawings.W.Width:Value(), Menu.drawings.W.Color:Value())
			end
			if Menu.drawings.E.ON:Value() then
				DrawCircle(myHero.pos, 750, Menu.drawings.E.Width:Value(), Menu.drawings.E.Color:Value())
			end	
			if Menu.drawings.R.ON:Value() then
				DrawCircle(myHero.pos, Menu.RS.Rrange:Value(), Menu.drawings.E.Width:Value(), Menu.drawings.E.Color:Value())
			end			
		end
	end)		
end

local QRange = 850
local MaxWRange = 700 	
local ERange = 700
local RRange = 825

function Tick()
	if MyHeroNotReady() then return end
	
	local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		if Menu.combo.R2:Value() then
			KillR()
		end		
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JClear()		
	end
	
	if Menu.clear.E:Value() then
		if Menu.clear.E2:Value() then
			if Mode ~= "Combo" then	
				AutoE()
			end
		else
			AutoE()
		end	
	end
	
	if Menu.combo.SR:Value() then
		SemiR()
	end	
	
	KsQ()
	KsW()
	KsE()	
end

local function ReadyForE()
    return myHero:GetSpellData(_E).currentCd <= Menu.combo.Cd:Value() and myHero:GetSpellData(_E).level > 0 and myHero:GetSpellData(_E).mana <= myHero.mana 
end

function StopAutoAttack(args)
	local Mode = GetMode()
	if Menu.combo.Block:Value() and Mode == "Combo" and ReadyForE() then
		args.Process = false 
		return
	end
end

function EdmgCreep()
	local level = myHero.levelData.lvl
	local base = (48 + 4 * level) + (0.1 * myHero.ap)
	return base
end	

function PEdmgCreep()
	local level = myHero:GetSpellData(_E).level
	local bonus = (({10, 30, 50, 70, 90})[level] + 0.60 * myHero.ap)
	local PEdamage = EdmgCreep() + bonus
	return PEdamage
end	

local function GetAngle(v1, v2)
	local vec1 = v1:Len()
	local vec2 = v2:Len()
	local Angle = math.abs(math.deg(math.acos((v1*v2)/(vec1*vec2))))
	if Angle < 80 then
		return true
	end
	return false
end

local function IsFacing(unit)
	local V = Vector((unit.pos - myHero.pos))
	local D = Vector(unit.dir)
	local Angle = 160 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
	if math.abs(Angle) < 80 then 
		return true  
	end
	return false
end

local function RLogic()
	local RTarget = nil 
	local Most = 0
	local ShouldCast = false
	local InFace = {}
	
	for i = 1, GameHeroCount() do
		local Hero = GameHero(i)
		if IsValid(Hero) and GetDistance(Hero.pos, myHero.pos) <= Menu.RS.Rrange:Value() then 
			--local LS = LineSegment(myHero.pos, Hero.pos)
			--LS:__draw()
			InFace[#InFace + 1] = Hero
		end
	end
	
	local IsFace = {}
	for r = 1, #InFace do 
		local FHero = InFace[r]
		if IsFacing(FHero) then
			local Vectori = Vector(myHero.pos - FHero.pos)
			IsFace[#IsFace + 1] = {Vector = Vectori, Host = FHero}
		end
	end
	
	local Count = {}
	local Number = #InFace
	for c = 1, #IsFace do 
		local MainLine = IsFace[c]
		if Count[MainLine] == nil then 
			Count[MainLine] = 1 
		end
		
		for w = 1, #IsFace do 
			local CloseLine = IsFace[w] 
			local A = CloseLine.Vector
			local B = MainLine.Vector
			if A ~= B then
				if GetAngle(A,B) and myHero.pos:DistanceTo(MainLine.Host.pos) < Menu.RS.Rrange:Value() then 
					Count[MainLine] = Count[MainLine] + 1
				end
			end
		end
		
		if Count[MainLine] > Most then
			Most = Count[MainLine]
			RTarget = MainLine.Host
		end
	end

	if Most >= Menu.combo.Count:Value() or Most == Number then
		ShouldCast = true 
	end
	return RTarget, ShouldCast
end

function KillR()
local target = GetTarget(Menu.RS.Rrange:Value())
if target == nil then return end

	if IsValid(target) and Ready(_R) then
		local EDmg = getdmg("E", target, myHero) * 3 
		local QDmg = Ready(_Q) and getdmg("Q", target, myHero) or 0
		local WDmg = Ready(_W) and getdmg("W", target, myHero) or 0
		local RDmg = getdmg("R", target, myHero) 
		local FullDmg = EDmg+QDmg+WDmg+RDmg
		if FullDmg > target.health then
			Control.CastSpell(HK_R, target.pos)
		end
	end
end
	
function Combo()
local target = GetTarget(950)
if target == nil then return end

	if IsValid(target) then	
    local Dist = myHero.pos:DistanceTo(target.pos)   
	
		if Menu.combo.E:Value() and Ready(_E) and Dist < ERange then
            Control.CastSpell(HK_E, target)
        end
		
        if Menu.combo.Q:Value() and Ready(_Q) then 
            if Dist < QRange then 
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, spellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					CastQGGPred(target)
				end	
            end
        end
		
        if Menu.combo.W:Value() and Ready(_W) then 
            if Dist < MaxWRange then
                if not IsFacing(target) and Dist < 525 then 
					local castPos = Vector(target.pos):Extended(Vector(myHero.pos), -200)    
					--DrawCircle(castPos, 50, 1, DrawColor(255, 225, 255, 10))
					Control.CastSpell(HK_W, castPos)
				elseif Dist < 600 then
					Control.CastSpell(HK_W, target.pos)				
                end
            end
        end
 
		if Menu.combo.P:Value() and myHero.health/myHero.maxHealth < Menu.combo.HP:Value()/100 and Ready(_R) then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerHaste" and Ready(SUMMONER_1) then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHaste" and Ready(SUMMONER_2) then
				Control.CastSpell(HK_SUMMONER_2)
			end

			if Dist < Menu.RS.Rrange:Value() and IsFacing(target) then
				Control.CastSpell(HK_R, target.pos)
			end
		end
		
		if Menu.combo.R:Value() and Ready(_R) then
			local RTarget, ShouldCast = RLogic() 
			if RTarget and ShouldCast then
				Control.CastSpell(HK_R, RTarget.pos)					
			end 
		end
	end
end	
	
function SemiR()
local target = GetTarget(Menu.RS.Rrange:Value())
if target == nil then return end
	if IsValid(target) and Ready(_R) then
		Control.CastSpell(HK_R, target.pos)			
	end 
end
	
function Harass()
local target = GetTarget(950)
if target == nil then return end
	
	if IsValid(target) then
		local EDmg = getdmg("E", target, myHero) * 2
		local Dist = myHero.pos:DistanceTo(target.pos)
		
		if Dist < ERange and Menu.harass.E:Value() and Ready(_E) and (HasPoison(target) or EDmg > target.health) then
            Control.CastSpell(HK_E, target)
        end
		
        if Dist < QRange and Menu.harass.Q:Value() and Ready(_Q) and myHero.mana/myHero.maxMana > Menu.mana.Q:Value()/100 then 
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, spellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				CastQGGPred(target)
			end
        end
	end
end	
	
function Clear()
	for i = 1, GameMinionCount() do 
	local minion = GameMinion(i)
		if minion.team == TEAM_ENEMY and IsValid(minion) then
		local mana_ok = myHero.mana/myHero.maxMana >= Menu.mana.QW:Value() / 100
			
			if Menu.clear.Q:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= QRange and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
			end
			
			if Menu.clear.W:Value() and mana_ok and Ready(_W) then
				if myHero.pos:DistanceTo(minion.pos) < MaxWRange and MinionsNear(minion,500) >= Menu.clear.Count:Value() then
					Control.CastSpell(HK_W, minion.pos)
				end	
			end
		end
	end
end

function JClear()
	for i = 1, GameMinionCount() do 
	local Minion = GameMinion(i)		 

		if Minion.team == TEAM_JUNGLE then	
		local Dist = myHero.pos:DistanceTo(Minion.pos)
			
			if IsValid(Minion) and Dist < QRange then	
				if Menu.jclear.Q:Value() and Ready(_Q) and myHero.mana/myHero.maxMana > Menu.mana.QW:Value()/100 then
					Control.CastSpell(HK_Q, Minion.pos)
					
				end
			end
			
			if IsValid(Minion) and Dist < MaxWRange then
				if Menu.jclear.W:Value() and Ready(_W) and myHero.mana/myHero.maxMana > Menu.mana.WW:Value()/100 then
					Control.CastSpell(HK_W, Minion.pos)
				
				end
			end
			
			if IsValid(Minion) and Dist < ERange then	
				if Menu.jclear.E:Value() and Ready(_E) then
					if HasPoison(Minion) then
						Control.CastSpell(HK_E, Minion)
						return
					elseif EdmgCreep() > Minion.health then
						Control.CastSpell(HK_E, Minion)
						return
					else
						if HasPoison(Minion) and PEdmgCreep() > Minion.health then
							Control.CastSpell(HK_E, Minion)
						end	
					end
				end
			end
		end
	end
end

function KsE()
local target = GetTarget(700)
if target == nil then return end 	
	if IsValid(target) then	
		local EDmg = getdmg("E", target, myHero) * 2
		local PEDmg = getdmg("E", target, myHero)
		
		if Menu.ks.E:Value() and Ready(_E) then 
			
			if HasPoison(target) and PEDmg > target.health then
				Control.CastSpell(HK_E, target)
			end
			
			if EDmg > target.health then
				Control.CastSpell(HK_E, target)			
			end
		end
	end	
end	

function KsQ()
local target = GetTarget(900)
if target == nil then return end
	
	if IsValid(target) then	
		if Menu.ks.Q:Value() and Ready(_Q) then 
			local QDmg = getdmg("Q", target, myHero)
			if QDmg > target.health then
				if Menu.Pred.Change:Value() == 1 then
					local pred = GetGamsteronPrediction(target, QData, myHero)
					if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				elseif Menu.Pred.Change:Value() == 2 then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, target, spellData)
					if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
						Control.CastSpell(HK_Q, pred.CastPos)
					end
				else
					CastQGGPred(target)
				end		
			end
		end
	end
end	

function KsW()
local target = GetTarget(700)
if target == nil then return end
	
	if IsValid(target) then	
		if Menu.ks.W:Value() and Ready(_W) then 
			local WDmg = getdmg("W", target, myHero)
			if WDmg > target.health then
				Control.CastSpell(HK_W, target.pos)			
			end
		end
	end	
end	
	
function AutoE()
    for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion) then	
			local mana_ok = myHero.mana/myHero.maxMana >= Menu.mana.EW:Value() / 100
            local Dist = myHero.pos:DistanceTo(minion.pos)
			
			if Menu.clear.E:Value() and mana_ok and Dist <= ERange and Ready(_E) then
				local PDmg = CalcMagicalDamage(myHero, minion, PEdmgCreep()) 
				local EDmg = CalcMagicalDamage(myHero, minion, EdmgCreep()) 				
				if HasPoison(minion) and PDmg  > minion.health then 
					if PEdmgCreep() > minion.health then
						Control.CastSpell(HK_E, minion)
					end
				end
				
				if EDmg > minion.health then 
					if EdmgCreep() > minion.health then
						Control.CastSpell(HK_E, minion)
					end
				end
            end	
		end
	end	
end

function CastQGGPred(unit)
	local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.75, Radius = 80, Range = 850, Speed = MathHuge, Collision = false})
	QPrediction:GetPrediction(unit, myHero)
	if QPrediction:CanHit(Menu.Pred.PredQ:Value()+1) then
		result = Control.CastSpell(HK_Q, QPrediction.CastPosition)
	end
end

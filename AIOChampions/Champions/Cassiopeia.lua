function IsValid1(unit, range)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) and myHero.pos:DistanceTo(unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius) then
        return true;
    end
    return false;
end

function Block(boolean) 
	if boolean == true then 
		if Orb == 1 then
			EOW:SetAttacks(false)
		elseif Orb == 2 then
			_G.SDK.Orbwalker:SetAttack(false)
		elseif Orb == 4 then
			_G.gsoSDK.Orbwalker:SetAttack(false)			
		else
			--GOS:BlockAttack(true)
		end
	else
		if Orb == 1 then
			EOW:SetAttacks(true)
		elseif Orb == 2 then
			_G.SDK.Orbwalker:SetAttack(true)
		elseif Orb == 4 then
			_G.gsoSDK.Orbwalker:SetAttack(true)			
		else
			--GOS:BlockAttack()
		end
	end
end

function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end 

function HasPoison(unit)
	for i = 0, unit.buffCount do 
	local buff = unit:GetBuff(i)
		if buff.type == 23 and Game.Timer() < buff.expireTime - 0.141  then
			return true
		end
	end
	return false
end

function EnemiesNear(pos,range)
	local pos = pos.pos
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)
		local Range = range * range
		if IsValid(hero) and hero.isEnemy and pos:DistanceTo(hero.pos) < Range then
			N = N + 1
		end
	end
	return N	
end

function MinionsNear(pos,range)
	local pos = pos.pos
	local N = 0
		for i = 1, Game.MinionCount() do 
		local Minion = Game.Minion(i)
		local Range = range * range
		if IsValid1(Minion, 800) and Minion.team == TEAM_ENEMY and Minion.pos:DistanceTo(pos) < Range then
			N = N + 1
		end
	end
	return N	
end

function EnemyInRange(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range and IsValid(target) then 
			count = count + 1
		end
	end
	return count
end



function LoadScript()
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.01"}})	
		Menu:MenuElement({name = " ", drop = {"General Settings"}})
		
		--Prediction
		Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
		Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
		Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})		
		
		--Combo   
		Menu:MenuElement({type = MENU, id = "c", name = "Combo"})
		Menu.c:MenuElement({id = "Block", name = "Block AA in Combo [?]", value = true, tooltip = "Reload Script after changing"})
		Menu.c:MenuElement({id = "Q", name = "Use Q", value = true})
		Menu.c:MenuElement({id = "W", name = "Use W", value = true})
		Menu.c:MenuElement({id = "E", name = "Use E", value = true})
		Menu.c:MenuElement({id = "SR", name = "Manual R ", key = string.byte("A")})
		Menu.c:MenuElement({id = "R", name = "Use R ", value = true})
		Menu.c:MenuElement({id = "Count", name = "Min Amount to hit R", value = 2, min = 1, max = 5, step = 1})
		Menu.c:MenuElement({id = "P", name = "Use Panic R and Ghost", value = true})
		Menu.c:MenuElement({id = "HP", name = "Min HP % to Panic R", value = 20, min = 0, max = 100, step = 1})
		
		--Harass
		Menu:MenuElement({type = MENU, id = "h", name = "Harass"})
		Menu.h:MenuElement({id = "Q", name = "UseQ", value = true})
		Menu.h:MenuElement({id = "E", name = "UseE only poisend", value = true})		
		
		--Clear
		Menu:MenuElement({type = MENU, id = "w", name = "Clear"})
		Menu.w:MenuElement({id = "Q", name = "Use Q", value = true})
		Menu.w:MenuElement({id = "W", name = "Use W", value = true})
		Menu.w:MenuElement({id = "Count", name = "Min Minions to hit W", value = 3, min = 1, max = 5, step = 1})		
		Menu.w:MenuElement({id = "E", name = "Auto E Toggle Key", key = 84, toggle = true})
		
		--JungleClear
		Menu:MenuElement({type = MENU, id = "j", name = "JungleClear"})
		Menu.j:MenuElement({id = "Q", name = "Use Q", value = true})
		Menu.j:MenuElement({id = "W", name = "Use W", value = true})
		Menu.j:MenuElement({id = "E", name = "Use E[poisend or Lasthit]", value = true})		
		
		--KillSteal
		Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
		Menu.ks:MenuElement({id = "Q", name = "UseQ", value = true})
		Menu.ks:MenuElement({id = "W", name = "UseW", value = true})
		Menu.ks:MenuElement({id = "E", name = "UseE", value = true})
	

		--Engage
		Menu:MenuElement({type = MENU, id = "kill", name = "Engage"})
		Menu.kill:MenuElement({id = "Eng", name = "EngageKill 1vs1", value = true, key = string.byte("T")})
		
		--Mana
		Menu:MenuElement({type = MENU, id = "m", name = "Mana Settings"})
		Menu.m:MenuElement({name = " ", drop = {"Harass [%]"}})
		Menu.m:MenuElement({id = "Q", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Menu.m:MenuElement({id = "W", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Menu.m:MenuElement({id = "E", name = "E Mana", value = 5, min = 0, max = 100, step = 1})
		Menu.m:MenuElement({id = "R", name = "R Mana", value = 5, min = 0, max = 100, step = 1})		
		Menu.m:MenuElement({name = " ", drop = {"Lane/JungleClear [%]"}})
		Menu.m:MenuElement({id = "QW", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Menu.m:MenuElement({id = "WW", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Menu.m:MenuElement({id = "EW", name = "E Mana", value = 10, min = 0, max = 100, step = 1})
		
		Menu:MenuElement({name = " ", drop = {"Advanced Settings"}})

		--Drawings
		Menu:MenuElement({type = MENU, id = "d", name = "Drawings"})
		Menu.d:MenuElement({id = "ON", name = "Enable Drawings", value = true})
		Menu.d:MenuElement({id = "Text", name = "Draw Text", value = true})
		Menu.d:MenuElement({type = MENU, id = "Q", name = "Q"})
		Menu.d.Q:MenuElement({id = "ON", name = "Enabled", value = true})       
		Menu.d.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Menu.d.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Menu.d:MenuElement({type = MENU, id = "W", name = "W"})
		Menu.d.W:MenuElement({id = "ON", name = "Enabled", value = false})       
		Menu.d.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Menu.d.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Menu.d:MenuElement({type = MENU, id = "E", name = "E"})
		Menu.d.E:MenuElement({id = "ON", name = "Enabled", value = true})       
		Menu.d.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Menu.d.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Menu.d:MenuElement({type = MENU, id = "R", name = "R"})
		Menu.d.R:MenuElement({id = "ON", name = "Enabled", value = true})       
		Menu.d.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Menu.d.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})				
		if Menu.c.Block:Value() then
			AA = true 
		end		
	
	QData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.8, Radius = 75, Range = 850, Speed = math.huge, Collision = false
	}

	RData =
	{
	Type = _G.SPELLTYPE_CONE, Delay = 0.5, Radius = 80, Range = 825, Speed = 3200, Collision = false
	}
  	                                           
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end
		if myHero.dead == false and Menu.d.ON:Value() then
			
			if Menu.d.Text:Value() then 
				if Menu.w.E:Value() then 
					Draw.Text("Auto E ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
				else
					Draw.Text("Auto E OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
				end
			end
			if Menu.d.Q.ON:Value() then
				Draw.Circle(myHero.pos, 850, Menu.d.Q.Width:Value(), Menu.d.Q.Color:Value())
			end
			if Menu.d.W.ON:Value() then
				Draw.Circle(myHero.pos, 340, Menu.d.W.Width:Value(), Menu.d.W.Color:Value())
				Draw.Circle(myHero.pos, 960, Menu.d.W.Width:Value(), Menu.d.W.Color:Value())
			end
			if Menu.d.E.ON:Value() then
				Draw.Circle(myHero.pos, 750, Menu.d.E.Width:Value(), Menu.d.E.Color:Value())
			end	
			if Menu.d.R.ON:Value() then
				Draw.Circle(myHero.pos, 750, Menu.d.E.Width:Value(), Menu.d.E.Color:Value())
			end			
		end
		local target = GetTarget(1200)
		if target == nil then return end

		if EnemiesNear(myHero,1200) == 1 and Ready(_R) and Ready(_W) and Ready(_E) and Ready(_Q) then	
			local fulldmg = getdmg("Q", target, myHero) + getdmg("W", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero)
			local textPos = target.pos:To2D()
			if IsValid(target) then
				if fulldmg > target.health then 
					Draw.Text("Engage PressKey", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
				end
			end
		end
	end)	
	
end

local AA = false
local QRange = 850
local MaxWRange = 800
local MinWRange = 420
local WMinCRange = 500 
local WMaxCRange = 800 	
local ERange = 700
local RRange = 825


function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		BlockAA()
		Check(Mode)
		Combo()
	elseif Mode == "Harass" then
		Check(Mode)
		Harass()
	elseif Mode == "Clear" then
		Check(Mode)
		Clear()
		JClear()
	elseif Mode == "Flee" then
		
	end
	if Menu.w.E:Value() and Mode ~= "Combo" then
		AutoE()
	end
	if Menu.kill.Eng:Value() then
		Engage()
	end	
	if Menu.c.SR:Value() then
		SemiR()
	end	
	UnBlockAA(Mode)
	KsQ()
	KsW()
	KsE()
	
		
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

function GetAngle(v1, v2)
	local vec1 = v1:Len()
	local vec2 = v2:Len()
	local Angle = math.abs(math.deg(math.acos((v1*v2)/(vec1*vec2))))
	if Angle < 90 then
		return true
	end
	return false
end

function IsFacing(unit)
	local V = Vector((unit.pos - myHero.pos))
	local D = Vector(unit.dir)
	local Angle = 180 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
	if math.abs(Angle) < 80 then 
		return true  
	end
	return false
end

function RLogic()
	local RTarget = nil 
	local Most = 0
	local ShouldCast = false
		local InFace = {}
		for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
			if IsValid1(Hero, 850) then 
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
		if Count[MainLine] == nil then Count[MainLine] = 1 end
			for w = 1, #IsFace do 
			local CloseLine = IsFace[w] 
			local A = CloseLine.Vector
			local B = MainLine.Vector
				if A ~= B then
					if GetAngle(A,B) and myHero.pos:DistanceTo(MainLine.Host.pos) < 825 then 
						Count[MainLine] = Count[MainLine] + 1
					end
				end
			end
			if Count[MainLine] > Most then
				Most = Count[MainLine]
				RTarget = MainLine.Host
			end
		end
	--	print(Most)
		if Most >= Menu.c.Count:Value() or Most == Number then
			ShouldCast = true 
		end
	--	print(Most)
	--	if RTarget then
	--		LSS = Circle(Point(RTarget), 50)
	--		LSS:__draw()
	--	end
	return RTarget, ShouldCast
end

function BlockAA()
	if AA == true then
		if Orb == 1 then
			EOW:SetAttacks(false)
		elseif Orb == 2 then
			_G.SDK.Orbwalker:SetAttack(false)
		elseif Orb == 4 then
			_G.gsoSDK.Orbwalker:SetAttack(false)				
		else
			--GOS:BlockAttack(true)
		end
	end
end


function UnBlockAA(Mode)
	if Mode ~= "Combo" and AA == false then 
		if Orb == 1 then 
			EOW:SetAttacks(true)
		elseif Orb == 2 then
			_G.SDK.Orbwalker:SetAttack(true)
		elseif Orb == 4 then
			_G.gsoSDK.Orbwalker:SetAttack(true)				
		else
		--	GOS:BlockAttack()
		end
	end
end

function Check(Mode)
	if AA == false or Mode ~= "Combo" then
	local activeSpell = myHero.activeSpell
	local cd = myHero:GetSpellData(_E).currentCd
		if activeSpell.windup > cd then
			if Orb == 1 then
				EOW:SetAttacks(false)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(false)
			elseif Orb == 4 then
				_G.gsoSDK.Orbwalker:SetAttack(false)					
			else
			--	GOS:BlockAttack(true)
			end
		else
			if Orb == 1 then 
				EOW:SetAttacks(true)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(true)
			elseif Orb == 4 then
				_G.gsoSDK.Orbwalker:SetAttack(true)				
			else
			--	GOS:BlockAttack()
			end
		end
	end
end
	
function Combo()
local target = GetTarget(950)
if target == nil then return end

	if IsValid(target) then	
	local result = false
    local Dist = myHero.pos:DistanceTo(target.pos) 
	local RTarget, ShouldCast = RLogic()   
		
		if not result and Menu.c.E:Value() and Ready(_E) and Dist < ERange then
            result = Control.CastSpell(HK_E, target)
        end
        if not result and Menu.c.Q:Value() and Ready(_Q) then 
            if Dist < QRange then 
            local pred = GetGamsteronPrediction(target, QData, myHero)
                if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
                    result = Control.CastSpell(HK_Q, pred.CastPosition)
                end
            end
        end 
        if not result and Menu.c.W:Value() and Ready(_W) then 
            if Dist < MaxWRange and Dist > MinWRange then
                if myHero.pos:DistanceTo(target.pos) < MaxWRange then 
                    CastW(HK_W, target.pos)
                end
            end
        end
		local pred = GetGamsteronPrediction(RTarget, RData, myHero)
		local WData = myHero:GetSpellData(_W) 
		local WCheck = Ready(_W)
		local Panic = Menu.c.P:Value() and myHero.health/myHero.maxHealth < Menu.c.HP:Value()/100 
		if Panic then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerHaste" and Ready(SUMMONER_1) then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHaste" and Ready(SUMMONER_2) then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
		if Menu.c.R:Value() and Ready(_R) and (HasPoison(target) or Panic) and ((WCheck == false or (WCheck and (Game.Timer() + WData.cd) - WData.castTime > 2)) or WValue == false) then
			if Panic then
				if Dist < RRange then
					if RTarget and pred.Hitchance >= Menu.Pred.PredR:Value()+1 then 
						Control.CastSpell(HK_R, pred.CastPosition)
					else
						Control.CastSpell(HK_R, target.pos)
					end
				end
			end
		end				
		if Menu.c.R:Value() and Ready(_R) then
			if Dist < RRange then 
				if RTarget and ShouldCast == true and pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
					Control.CastSpell(HK_R, pred.CastPosition)
					
				end 
			end
		end
	end
end	
	
function SemiR()
local target = GetTarget(950)
if target == nil then return end
	local RTarget, ShouldCast = RLogic()
	local Dist = myHero.pos:DistanceTo(target.pos)	
	local pred = GetGamsteronPrediction(RTarget, RData, myHero)
	if IsValid(target) and Dist < RRange and Ready(_R) then
		if RTarget and pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		else
			Control.CastSpell(HK_R, target.pos)			
		end
	end 
end
	
function Harass()
local target = GetTarget(950)
if target == nil then return end
	
	if IsValid(target) then
		local EDmg = getdmg("E", target, myHero) * 2
		local Dist = myHero.pos:DistanceTo(target.pos)
		local result = false
		if not result and Dist < ERange and Menu.h.E:Value() and Ready(_E) and (HasPoison(target) or EDmg >= target.health) then
            result = Control.CastSpell(HK_E, target)
        end
        if not result and Dist < QRange and Menu.h.Q:Value() and Ready(_Q) and myHero.mana/myHero.maxMana > Menu.m.Q:Value()/100 then 
        local pred = GetGamsteronPrediction(target, QData, myHero)
            if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
                result = Control.CastSpell(HK_Q, pred.CastPosition)
               
            end
        end
	end
end	
	
function Clear()
for i = 1, Game.MinionCount() do 
local minion = Game.Minion(i)
	if minion.team == TEAM_ENEMY and IsValid(minion) then
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.m.QW:Value() / 100
		if Menu.w.Q:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= QRange and Ready(_Q) then
			Control.CastSpell(HK_Q, minion.pos)
		end
		if Menu.w.W:Value() and mana_ok and Ready(_W) then
			local Dist = myHero.pos:DistanceTo(minion.pos)
			if Dist < MaxWRange and Dist > MinWRange and MinionsNear(minion,500) >= Menu.w.Count:Value() then
				CastW(HK_W, minion.pos)
			end	
		end
	end
end
end

function JClear()
	for i = 1, Game.MinionCount() do 
	local Minion = Game.Minion(i)		 

	if Minion.team == TEAM_JUNGLE then	
	
		if IsValid(Minion) and myHero.pos:DistanceTo(Minion.pos) < QRange then	
			if Menu.j.Q:Value() and Ready(_Q) and myHero.mana/myHero.maxMana > Menu.m.QW:Value()/100 then
				Control.CastSpell(HK_Q, Minion.pos)
				
			end
		end
		if IsValid(Minion) then
			local Dist = myHero.pos:DistanceTo(Minion.pos)
			if Dist < MaxWRange and Dist > MinWRange then	
				if Menu.j.W:Value() and Ready(_W) and myHero.mana/myHero.maxMana > Menu.m.WW:Value()/100 then
					CastW(HK_W, Minion.pos)
				
				end
			end
		end
		
		if IsValid(Minion) and myHero.pos:DistanceTo(Minion.pos) < ERange then	
			if Menu.j.E:Value() and Ready(_E) then
				if HasPoison(Minion) then
					Block(true)
					Control.CastSpell(HK_E, Minion)
					break
				elseif EdmgCreep() > Minion.health then
					Block(true)
					Control.CastSpell(HK_E, Minion)
					break
				elseif HasPoison(Minion) and PEdmgCreep() > Minion.health then
					Block(true)
					Control.CastSpell(HK_E, Minion)
					break					
				end
			end
		end
		Block(false)
	end
	end
end

function KsE()
local target = GetTarget(750)
if target == nil then return end
local Dist = myHero.pos:DistanceTo(target.pos)	 
	if IsValid(target) and Dist < ERange then	
		local EDmg = getdmg("E", target, myHero) * 2
		local PEDmg = getdmg("E", target, myHero)
		if Menu.ks.E:Value() and Ready(_E) then 
			if HasPoison(target) and PEDmg > target.health then
				Control.CastSpell(HK_E, target)
				
			elseif EDmg > target.health then
				Control.CastSpell(HK_E, target)
			
			end
		end
	end	
end	
	
function KsQ()
local target = GetTarget(900)
if target == nil then return end
local Dist = myHero.pos:DistanceTo(target.pos)	
	if IsValid(target) and Dist < QRange then	
		if Menu.ks.Q:Value() and Ready(_Q) then 
			local QDmg = getdmg("Q", target, myHero)
			if QDmg > target.health then
				Control.CastSpell(HK_Q, target.pos)
			
			end
		end
	end
end	

function KsW()
local target = GetTarget(900)
if target == nil then return end
local Dist = myHero.pos:DistanceTo(target.pos)
	
	if IsValid(target) and Dist < MaxWRange and Dist > MinWRange then	
		if Menu.ks.W:Value() and Ready(_W) then 
			local WDmg = getdmg("W", target, myHero)
			if WDmg > target.health then
				Control.CastSpell(HK_W, target.pos)
			
			end
		end
	end	
end	

	
function Engage()
local target = GetTarget(1200)
if target == nil then return end
local Dist = myHero.pos:DistanceTo(target.pos)

	if IsValid(target) and Dist < ERange then
		local fulldmg = getdmg("Q", target, myHero) + getdmg("W", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero)
		local RCheck = Ready(_R)
		local RTarget, ShouldCast = RLogic()
	
	
		local pred = GetGamsteronPrediction(RTarget, RData, myHero)
		if EnemiesNear(myHero,825) == 1 and Ready(_R) and Ready(_W) and Ready(_Q) and Ready(_E) then 
			if RTarget and EnemyInRange(RRange) and fulldmg > target.health and pred.Hitchance >= Menu.Pred.PredR:Value()+1 then
				Control.CastSpell(HK_R, pred.CastPosition)
			end
		end 
		if not Ready(_R) then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerHaste" and Ready(SUMMONER_1) then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHaste" and Ready(SUMMONER_2) then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end	
		if Ready(_Q) and not Ready(_R) then 
			if Dist < QRange then 
			local pred = GetGamsteronPrediction(target, QData, myHero)
				if Dist < QRange and pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
		end
		if Ready(_E) and not Ready(_R) then 
			if Dist < ERange then
				Control.CastSpell(HK_E, target)
			end
		end	
		if Ready(_W) and not Ready(_R) then 
			if Dist < MaxWRange and Dist > MinWRange then
				CastW(HK_W, target.pos)
				
			end
		end
	end	
end
	
function AutoE()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion) then	
			local mana_ok = myHero.mana/myHero.maxMana >= Menu.m.EW:Value() / 100
            local Dist = myHero.pos:DistanceTo(minion.pos)
			if Menu.w.E:Value() and mana_ok and Dist <= ERange and Ready(_E) then
				local PDmg = CalcMagicalDamage(myHero, minion, PEdmgCreep()) 
				local EDmg = CalcMagicalDamage(myHero, minion, EdmgCreep()) 
				if HasPoison(minion) and PDmg + 20 >= minion.health then 
					Block(true)
					if PEdmgCreep() >= minion.health then
						Control.CastSpell(HK_E, minion)
					end
					Block(false)
				end
				if EDmg + 20 >= minion.health then 
					Block(true)
					if EdmgCreep() >= minion.health then
						Control.CastSpell(HK_E, minion)
					end
					Block(false)
				end
            end	
		end
	end	
end
					
function CastW(key, pos)
	local key = key or HK_W
	local Dist = pos:DistanceTo()
	local h = myHero.pos
	local v = Vector(pos - myHero.pos):Normalized()
	if Dist < WMinCRange then
		Control.CastSpell(key, h + v*500)
	elseif Dist > WMaxCRange then
		Control.CastSpell(key, h + v*800)
	else
		Control.CastSpell(key, pos)
	end
end	

	

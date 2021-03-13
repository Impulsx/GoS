
local function EnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end

local function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,GameMinionCount() do
	local hero = GameMinion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

local function EnemiesNear(pos,range)
	local pos = pos.pos
	local N = 0
	for i = 1,GameHeroCount()  do
		local hero = GameHero(i)
		local Range = range * range
		if IsValid(hero) and hero.isEnemy and GetDistanceSqr(pos, hero.pos) < Range then
			N = N + 1
		end
	end
	return N	
end

local function Cleans(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and buff.type == 10 and buff.count > 0 then
			return true
		end
	end
	return false	
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

function LoadScript()
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.06"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R] if killable", value = true})
	Menu.Combo:MenuElement({id = "Targets", name = "[R] White List", type = MENU})
	DelayAction(function()
		for i, Hero in pairs(EnemyHeroes()) do
			Menu.Combo.Targets:MenuElement({id = Hero.charName, name = "[R] KS on "..Hero.charName, value = true})		
		end
	end,0.2)
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})	
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Lasthit", value = true})
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 4, min = 1, max = 7, step = 1, identifier = "Minion/s"})  
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})

	--AutoW
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W]", value = true})
	Menu.AutoW:MenuElement({id = "HP", name = "[W] if own HP lower than -->", value = 70, min = 0, max = 100, identifier = "%"})

	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ"})
	Menu.AutoQ:MenuElement({id = "UseQ2", name = "Use Auto [Q]", value = true})	
	Menu.AutoQ:MenuElement({id = "UseQ", name = "[Q] if slowed", value = 1, drop = {"Auto cast", "Only cast in Combo"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})		
  	
	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function()
	if myHero.dead then return end

		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, 400, 1, DrawColor(255, 225, 255, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 325, 1, DrawColor(225, 225, 125, 10))
		end	
	end)

	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	elseif _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:OnPreAttack(function(...) StopAutoAttack(...) end)
	end		
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
		if Menu.AutoQ.UseQ2:Value() and Menu.AutoQ.UseQ:Value() == 2 then
			AutoQ()
		end		
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end
	
	AutoW()
	
	if Menu.AutoQ.UseQ2:Value() and Menu.AutoQ.UseQ:Value() == 1 then
		AutoQ()
	end	
end

function StopAutoAttack(args)
	if myHero:GetSpellData(_E).name == "GarenECancel" then
		args.Process = false 
		return
	end
end

function AutoW()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
	
		if Menu.AutoW.UseW:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= Menu.AutoW.HP:Value() / 100 then
				Control.CastSpell(HK_W)
			end	
		end
	end
end

function AutoQ()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) then
		local slow = Cleans(myHero)
		if Ready(_Q) then
			if slow then
				Control.CastSpell(HK_Q)
			end	
		end
	end
end
	
function Combo()
local target = GetTarget(600)     	
if target == nil then return end
	if IsValid(target) then
		local Enemys1 = EnemiesNear(myHero,1000)
		local Enemys2 = EnemiesNear(myHero,500)
	
		if Enemys1 == 1 then
			if myHero.pos:DistanceTo(target.pos) <= 300 and Ready(_Q) and Menu.Combo.UseQ:Value() and not HasBuff(myHero, "GarenE") then
				Control.CastSpell(HK_Q)
			
			elseif myHero:GetSpellData(_E).name == "GarenE" and myHero.pos:DistanceTo(target.pos) <= 325 and Ready(_E) and not HasBuff(myHero, "GarenQ") and not Ready(_Q) and Menu.Combo.UseE:Value() then
				Control.CastSpell(HK_E, target.pos)
			end			
			
			if Ready(_R) then
				if myHero.pos:DistanceTo(target.pos) <= 400 then				
					local RDmg = (getdmg("R", target, myHero))
					if Menu.Combo.UseR:Value() and RDmg > target.health and Menu.Combo.Targets[target.charName] and Menu.Combo.Targets[target.charName]:Value() then
						Control.CastSpell(HK_R, target)
					end				
				end
			end	
		end	
		
		if Enemys2 >= 2 then
			if myHero:GetSpellData(_E).name == "GarenE" and Ready(_E) and not HasBuff(myHero, "GarenQ") and Menu.Combo.UseE:Value() then
				Control.CastSpell(HK_E, target.pos)			
			
			elseif myHero.pos:DistanceTo(target.pos) <= 300 and Ready(_Q) and Menu.Combo.UseQ:Value() and not HasBuff(myHero, "GarenE") and not Ready(_E) then
				Control.CastSpell(HK_Q)
			end
			
			if Ready(_R) then
				for i, Hero in pairs(EnemyHeroes()) do
					if myHero.pos:DistanceTo(Hero.pos) <= 400 and IsValid(Hero) then				
						local RDmg = (getdmg("R", Hero, myHero))
						if Menu.Combo.UseR:Value() and RDmg > Hero.health and Menu.Combo.Targets[Hero.charName] and Menu.Combo.Targets[Hero.charName]:Value() then
							Control.CastSpell(HK_R, Hero)
						end	
					end	
				end
			end				
		end
	end	
end	

function Harass()
local target = GetTarget(600)
if target == nil then return end
	if IsValid(target) then

		if myHero.pos:DistanceTo(target.pos) <= 300 then	
			if Menu.Harass.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end
		end
	end
end

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_ENEMY and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < 300 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero) + getdmg("AA", minion, myHero)
				if QDmg >= minion.health then
					Control.CastSpell(HK_Q)
				end	
            end
                      
			if myHero:GetSpellData(_E).name == "GarenE" and myHero.pos:DistanceTo(minion.pos) < 325 and Ready(_E) and not Ready(_Q) and Menu.Clear.UseE:Value() then
				local count = GetMinionCount(400, minion)
				if count >= Menu.Clear.UseEM:Value() then
					Control.CastSpell(HK_E)
                end    
            end
        end
    end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 600 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < 300 and Menu.Clear.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q)
            end
                      
			if myHero:GetSpellData(_E).name == "GarenE" and myHero.pos:DistanceTo(minion.pos) < 325 and Ready(_E) and not Ready(_Q) and Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E)    
            end
        end
    end
end

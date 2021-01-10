
local LastW = 0

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == 10 or buff.type == 22 or buff.name == 8 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function GetEnemyHeroes()
	local EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero and Hero.valid and Hero.alive and Hero.visible and Hero.isEnemy and Hero.isTargetable then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

local function GetAllyHeroes()
	local AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero and Hero.valid and Hero.alive and Hero.visible and Hero.isAlly then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

local function IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or (checkTeam and unit.isAlly) then
		return false
	end
	if myHero.pos:DistanceTo(unit.pos) > range then return false end 
	return true 
end

local Q = {Range = 350, Delay = 0.25}
local W = {Range = 650}
local E = {Range = 350}

function LoadScript()
	--MainMenu
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Reworked Trust Alistar"}})	
	Menu:MenuElement({name = " ", drop = {"Version 0.02"}})
	
	--[[Protector]]
	Menu:MenuElement({type = MENU, id = "Protector", name = "Protect from dashes"})
	Menu.Protector:MenuElement({id = "enabled", name = "Enabled", value = true})
	DelayAction(function()
		for i, hero in ipairs(GetAllyHeroes()) do
			Menu.Protector:MenuElement({id = "RU"..hero.charName, name = "Protect from dashes: "..hero.charName, value = true})
		end
	end,0.2)
	
	--[[Combo]]
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	Menu.Combo:MenuElement({id = "comboUseR1", name = "Use R if Immobile", value = true})	
	Menu.Combo:MenuElement({id = "comboUseR2", name = "Use R if Hp low", value = true})
	Menu.Combo:MenuElement({id = "Hp", name = "Use R if Hp lower than -->", value = 50, min = 0, max = 100, step = 5, identifier = "%"})	
	
	
	--[[Harass]]
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	
	Menu:MenuElement({type = MENU, id = "DrawMenu", name = "Draw Settings"})
	Menu.DrawMenu:MenuElement({id = "DrawQ", name = "Draw Q Range", value = false})
	Menu.DrawMenu:MenuElement({id = "QRangeC", name = "Q Range color", color = Draw.Color(0xBF3F3FFF)})
	Menu.DrawMenu:MenuElement({id = "DrawW", name = "Draw W Range", value = false})
	Menu.DrawMenu:MenuElement({id = "WRangeC", name = "W Range color", color = Draw.Color(0xBFBF3FFF)})

	Callback.Add("Tick", function() Tick() end)
	
	Callback.Add("Draw", function()
		if myHero.dead then return end                                                 
		
		if Menu.DrawMenu.DrawQ:Value() then
			Draw.Circle(myHero.pos, Q.Range, 1, Menu.DrawMenu.QRangeC:Value())
		end
		if Menu.DrawMenu.DrawW:Value() then
			Draw.Circle(myHero.pos, W.Range, 1, Menu.DrawMenu.WRangeC:Value())
		end	
	end)
end

function Tick()
	if MyHeroNotReady() then return end
	
	local combomodeactive = GetMode() == "Combo"
	local harassactive = GetMode() == "Harass"
	local protector = Menu.Protector.enabled:Value()

	if protector and Ready(_W) then
		for i, hero in pairs(GetEnemyHeroes()) do 
			if hero.pathing.hasMovePath and hero.pathing.isDashing and hero.pathing.dashSpeed>500 then 
				for i, allyHero in pairs(GetAllyHeroes()) do 
					if Menu.Protector["RU"..allyHero.charName] and Menu.Protector["RU"..allyHero.charName]:Value() then 
						if allyHero.pos:DistanceTo( Vector( hero.pathing.endPos ) ) < 100 and allyHero.distance < W.Range then
							Control.CastSpell(HK_W,hero)
							return
						end
					end
				end
			end
		end
	end
	
	if ( GetTickCount() < LastW + 2000 and GetMode() == "Combo" and Menu.Combo.comboUseQ:Value() and Ready(_Q) and (myHero.pathing.isDashing or not Ready(_W)) ) then
		Control.CastSpell(HK_Q)
		--print("Q Combo After W")
	end		
	
	if combomodeactive then
		if ( Menu.Combo.comboUseW:Value() and Ready(_Q) and Ready(_W) and CastW() ) then
			LastW = GetTickCount()
			--print("WQ Combo")
		elseif ( Menu.Combo.comboUseQ:Value() and Ready(_Q) and CastQ() ) then
			--print("Q Combo")
		end
		if ( Menu.Combo.comboUseE:Value() and Ready(_E) and CastE() ) then
			--print("E Combo")
		end
		if ( Menu.Combo.comboUseR1:Value() and Ready(_R) and CastR1() ) then
			--print("R Immo")
		elseif ( Menu.Combo.comboUseR2:Value() and Ready(_R) and CastR2() ) then
			--print("R Hp")			
		end		
	elseif harassactive then
		if Menu.Harass.harassUseQ:Value() and Ready(_Q) and CastQ() then
			--print("Q Harass")
		end
	end
end

function CastQ(target)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target then
		--local temppred = target:GetPrediction(math.huge,0.25)
		if target.pos:DistanceTo(myHero.pos) < Q.Range then 
			Control.CastSpell(HK_Q)
			return true
		end
	end
	return false
end

function CastW()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AP"))
	if target and target.pos:DistanceTo(myHero.pos) > Q.Range then		
		Control.CastSpell(HK_W, target)
		return true	
	end
	return false
end

function CastE()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
	if target then
		Control.CastSpell(HK_E)
		return true
	end
	return false
end

function CastR1()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	for i, hero in pairs(GetEnemyHeroes()) do 
		if IsValidTarget(hero, 500) and IsImmobileTarget(myHero) then
			Control.CastSpell(HK_R)
			return true
		end
	end	
	return false
end

function CastR2()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	for i, hero in pairs(GetEnemyHeroes()) do 
		if IsValidTarget(hero, 500) and myHero.health/myHero.maxHealth <= Menu.Combo.Hp:Value() / 100  then
			Control.CastSpell(HK_R)
			return true
		end
	end	
	return false
end

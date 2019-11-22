function LoadScript()
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	
	--AutoQ
	Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQImmo"})
	Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto[Q]Immobile Target", value = true})

	--AutoW 
	Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W]Ally+Self", value = true})
	Menu.AutoW:MenuElement({id = "Heal", name = "min Hp Ally or Self", value = 40, min = 0, max = 100, identifier = "%"})	

	--AutoE
	Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]Immobile Target", value = true})	
		
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})		
	Menu.Combo:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})			
	
	--HarassMenu
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})	
	Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})			
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 4, min = 1, max = 6, step = 1})  		
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})	
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	Menu.ks:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})	
	Menu.ks:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})				
	Menu.ks:MenuElement({id = "UseR", name = "[R] Final Spark", value = true})	
		
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1175, Speed = 1200, Collision = true, MaxCollision = 1, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
	}

	EData =
	{
	Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 310, Range = 1000, Speed = 1200, Collision = false
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
	Callback.Add("Draw", function() Draw() end)		
end

function Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Harass" then
		Harass()
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end	

	KillSteal()
	AutoQ()
	AutoE()
	AutoW()
end

function NearestEnemy(entity)
	local distance = 999999
	local enemy = nil
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if hero and HPred:CanTarget(hero) then
			local d = HPred:GetDistanceSqr(entity.pos, hero.pos)
			if d < distance then
				distance = d
				enemy = hero
			end
		end
	end
	return _sqrt(distance), enemy
end

function Draw()
  if myHero.dead then return end
	if Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 3340, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 1175, 1, Draw.Color(225, 225, 0, 10))
	end
	if Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 1000, 1, Draw.Color(225, 225, 125, 10))
	end
	if Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 1075, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
end

function AutoQ()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1175 and IsImmobileTarget(target) and Menu.AutoQ.UseQ:Value() and Ready(_Q) then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end	
	end
end

local eMissile
local eParticle

function IsETraveling()
	return eMissile and eMissile.name and eMissile.name == "LuxLightStrikeKugel"
end

function IsELanded()
	return eParticle and eParticle.name and _find(eParticle.name, "E_tar_aoe_sound") --Lux_.+_E_tar_aoe_
end

function AutoE()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target) and IsELanded() then
		if NearestEnemy(eParticle) < 310 then	
			Control.CastSpell(HK_E)
			eParticle = nil
		end	
	else		

		local eData = myHero:GetSpellData(_E)
		if eData.toggleState == 1 then

			if not IsETraveling() then
				for i = 1, Game.MissileCount() do
					local missile = Game.Missile(i)			
					if missle and missile.name == "LuxLightStrikeKugel" and HPred:IsInRange(missile.pos, myHero.pos, 400) then
						eMissile = missile
						break
					end
				end
			end
		elseif eData.toggleState == 2 then		
			for i = 1, Game.ParticleCount() do 
				local particle = Game.Particle(i)
				if particle and _find(particle.name, "E_tar_aoe_sound") then
					eParticle = particle
					break
				end
			end	
		end
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_E) and IsImmobileTarget(target) then
			if Menu.AutoE.UseE:Value() then
				Control.CastSpell(HK_E, target.pos)
				eMissile = nil

			end
		end
	end	
end

function AutoW()
	for i, ally in pairs(GetAllyHeroes()) do
		if Menu.AutoW.UseW:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= Menu.AutoW.Heal:Value()/100 and BaseCheck(myHero) == false then
				Control.CastSpell(HK_W)
			end
			if IsValid(ally) and myHero.pos:DistanceTo(ally.pos) <= 1075 and ally.health/ally.maxHealth <= Menu.AutoW.Heal:Value()/100 and BaseCheck(myHero) == false then
				Control.CastSpell(HK_W, ally.pos)
			end
		end
	end
end


function Combo()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) <= 1175 and Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		if Menu.Combo.UseE:Value() and Ready(_E) then
			if IsELanded() then
				AutoE()
			elseif myHero.pos:DistanceTo(target.pos) <= 1000 then	
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then				
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			end
		end		
	end	
end	

function Harass()
local target = GetTarget(1300)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 1175 and Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if Menu.Harass.UseE:Value() and Ready(_E) then
			if IsELanded() then
				AutoE()
			elseif myHero.pos:DistanceTo(target.pos) <= 1000 then	
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= Menu.Pred.PredE:Value() + 1 then				
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			end
		end
	end
end

function Clear()
for i = 1, Game.MinionCount() do 
local minion = Game.Minion(i)
	if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) then
	local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100

		if Menu.Clear.UseE ~= nil and Menu.Clear.UseE:Value() then
			if IsELanded() then
				Control.CastSpell(HK_E)
			elseif mana_ok and Ready(_E) then
				local count = GetMinionCount(500, minion)
				if count >= Menu.Clear.UseEM:Value() then
					Control.CastSpell(HK_E, minion.pos)
				end
			end
		end
	end
end
end

function JungleClear()
for i = 1, Game.MinionCount() do 
local minion = Game.Minion(i)
	if minion.team == TEAM_JUNGLE and myHero.pos:DistanceTo(minion.pos) <= 1000 and IsValid(minion) then
		local mana_ok = myHero.mana/myHero.maxMana >= Menu.JClear.Mana:Value() / 100

		if Menu.JClear.UseE:Value() then
			if IsELanded() then
				Control.CastSpell(HK_E)
			elseif mana_ok and Ready(_E) then
				Control.CastSpell(HK_E, minion.pos)
			end
		end
	end
end
end

function KillSteal()
	local target = GetTarget(3500)     	
	if target == nil then return end
	
	
	if IsValid(target) then	
		local hp = target.health
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1175 and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= hp then
				KillstealQ(target)
			end
		end
		if Menu.ks.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_E) then
			local EDmg = getdmg("E", target, myHero)
			if EDmg >= hp then
				KillstealE(target)
			end
		end
		if Menu.ks.UseR:Value() and myHero.pos:DistanceTo(target.pos) <= 3340 and Ready(_R) then
			local RDmg = getdmg("R", target, myHero) 
			local RDmg2 = getdmg("R", target, myHero) + (10 + 10 * myHero.levelData.lvl + myHero.ap * 0.2)
			if HPred:HasBuff(target, "LuxIlluminatingFraulein",1.25) and RDmg2 >= hp then    
				KillstealR()
			end
			if RDmg >= hp then
				KillstealR(target)
			end
		end
		if Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 1175 and Ready(_R) and Ready(_Q) then
			local RDmg = getdmg("R", target, myHero)
			local QDmg = getdmg("Q", target, myHero)
			local QRDmg = QDmg + RDmg
			if QRDmg >= hp then
				KillstealQ(target)
			end	
		end
	end
end	

function KillstealQ(target)
local pred = GetGamsteronPrediction(target, QData, myHero)
	if pred.Hitchance >= Menu.Pred.PredQ:Value() + 1 then
		Control.CastSpell(HK_Q, pred.CastPosition)
			
	end
end

function KillstealE(target)
	Control.CastSpell(HK_E, target.pos)
			
end

function KillstealR(target)
local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 3340, 1.0, 1000, 190, false)
	if hitRate and hitRate >= 1 then
		if aimPosition:To2D().onScreen then 		
			Control.CastSpell(HK_R, aimPosition) 
		
		elseif not aimPosition:To2D().onScreen then	
		local castPos = myHero.pos:Extended(aimPosition, 1000)    
			Control.CastSpell(HK_R, castPos)
		end		
	end
end
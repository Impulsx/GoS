Q = {	Range = 880,	Radius = 90,	Delay = 0.25,	Speed = 1700, 	IsLine = true}
W = {	Range = 800,	Delay = 0.25,	Speed = 999999	}
E = {	Range = 975,	Radius = 50,	Delay = 0.25,	Speed = 1600,	Collision = true, 	IsLine = true}
R = {	Range = 450,	Radius = 600,	Delay = 0.25,	Speed = 999999	}
	

function LoadScript()
	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({id = "Skills", name = "Skills", type = MENU})
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Orb of Deception", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })	
	Menu.Skills.Q:MenuElement({id = "KSAccuracy", name = "KS Accuracy", value = 2, min = 1, max = 6, step = 1 })	
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Cast On Immobile Targets", value = true, toggle = true })
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Minimum Mana", value = 20, min = 1, max = 100, step = 1 })

	Menu.Skills:MenuElement({id = "W", name = "[W] Fox Fire", type = MENU})
	Menu.Skills.W:MenuElement({id = "Radius", name = "Use Radius", value = 250, min = 0, max = 1000, step = 50 })
	Menu.Skills.W:MenuElement({id = "Mana", name = "Minimum Mana", value = 20, min = 1, max = 100, step = 1 })

	Menu.Skills:MenuElement({id = "E", name = "[E] Charm", type = MENU})
	Menu.Skills.E:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.E:MenuElement({id = "Auto", name = "Auto Cast On Immobile Targets", value = true, toggle = true })
	Menu.Skills.E:MenuElement({id = "Mana", name = "Minimum Mana", value = 20, min = 1, max = 100, step = 1 })

	Menu.Skills:MenuElement({id = "R", name = "[R] Spirit Rush", type = MENU})
	Menu.Skills.R:MenuElement({id = "Auto", name = "Danger Level (Auto)", value = 4, min = 1, max = 6, step = 1 })
	Menu.Skills.R:MenuElement({id = "Combo", name = "Danger Level (Combo)", value = 1, min = 1, max = 6, step = 1 })

		
	LocalDamageManager:OnIncomingCC(function(target, damage, ccType) OnCC(target, damage, ccType) end)
	LocalObjectManager:OnBlink(function(target) OnBlink(target) end )
	LocalObjectManager:OnSpellCast(function(spell) OnSpellCast(spell) end)
	Callback.Add("Tick", function() Tick() end)
end

function OnSpellCast(spell)
	if spell.isEnemy and Ready(_R) then
		local hitDetails = LocalDamageManager:GetSpellHitDetails(spell,myHero)
		if hitDetails.Hit and hitDetails.Path then
			if hitDetails.Danger >= Menu.Skills.R.Auto:Value() or (ComboActive() and hitDetails.Danger >= Menu.Skills.R.Combo:Value()) then	
				local dashPos = myHero.pos + hitDetails.Path * R.Range				
				CastSpell(HK_R, dashPos)
			end				
		end
	end
end

local NextTick = LocalGameTimer()
local NextR = LocalGameTimer()
function Tick()
	if BlockSpells() then return end
	if NextTick > LocalGameTimer() then return end
	
	if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
		local target = GetTarget(E.Range)
		--Get cast position for target
		if target and CanTarget(target) then
			local accuracyRequired = ComboActive() and Menu.Skills.E.Accuracy:Value() or Menu.Skills.E.Auto:Value() and 4 or 6
			local castPosition, accuracy = LocalGeometry:GetCastPosition(myHero, target, E.Range, E.Delay, E.Speed, E.Radius, E.Collision, E.IsLine)
			if castPosition and accuracy >= accuracyRequired and LocalGeometry:IsInRange(myHero.pos, castPosition, E.Range) then
				NextTick = LocalGameTimer() + .25
				CastSpell(HK_E, castPosition)
				return
			end	
		end
	end
	
	if Ready(_Q) and CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() then
		local target = GetTarget(Q.Range)
		--Get cast position for target
		if target and CanTarget(target) then		
			--Check the damage we will deal to the target
			local targetQDamage = 2 * _G.Alpha.DamageManager:CalculateMagicDamage(myHero, target, myHero.ap * .65 + ({75,120,165,210,255})[myHero:GetSpellData(_Q).level])			
			local accuracyRequired = ComboActive() and Menu.Skills.Q.Accuracy:Value() or Menu.Skills.Q.Auto:Value() and 4 or 6
			if targetQDamage > target.health and accuracyRequired > Menu.Skills.Q.KSAccuracy:Value() then
				accuracyRequired = Menu.Skills.Q.KSAccuracy:Value()
			end
			if accuracyRequired < 6 then
				local castPosition, accuracy = LocalGeometry:GetCastPosition(myHero, target, Q.Range, Q.Delay, Q.Speed, Q.Radius, Q.Collision, E.IsLine)
				if castPosition and accuracy >= accuracyRequired and LocalGeometry:IsInRange(myHero.pos, castPosition, Q.Range) then
					NextTick = LocalGameTimer() + .25
					CastSpell(HK_Q, castPosition)
					return
				end
			end			
		end
	end
	
	if Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() then		
		for i = 1, LocalGameHeroCount() do
			local hero = LocalGameHero(i)
			if hero and CanTarget(hero) then
				local origin = LocalGeometry:PredictUnitPosition(hero, W.Delay)
				if LocalGeometry:IsInRange(myHero.pos, origin, Menu.Skills.W.Radius:Value()) or (LocalGeometry:IsInRange(myHero.pos, origin,W.Range) and ComboActive()) then
					NextTick = LocalGameTimer() + .25
					CastSpell(HK_W)
					return
				end
			end
		end
	end
	
	NextTick = LocalGameTimer() + .1
end


function OnCC(target, damage, ccType)	
	if CanTarget(target) and LocalDamageManager.IMMOBILE_TYPES[ccType] then
		if Ready(_Q) and CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() and Menu.Skills.Q.Auto:Value() and LocalGeometry:IsInRange(myHero.pos, target.pos, Q.Range - 100) then
			NextTick = LocalGameTimer() +.25
			CastSpell(HK_Q, target.pos)
			return
		end
		if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() and Menu.Skills.E.Auto:Value() and LocalGeometry:IsInRange(myHero.pos, target.pos, E.Range - 100) then
			NextTick = LocalGameTimer() +.25
			CastSpell(HK_E, target.pos)
			return
		end
	end
end

function OnBlink(target)
	if CanTarget(target) then
		if Ready(_E) and Menu.Skills.E.Auto:Value() and LocalGeometry:IsInRange(myHero.pos, target.pos, E.Range) then
			local castPosition, accuracy = LocalGeometry:GetCastPosition(myHero, target, E.Range, E.Delay, E.Speed, E.Radius, E.Collision, E.IsLine)
			if accuracy > 0 then
				CastSpell(HK_E, target.pos)
			end	
		end
		if Ready(_Q) and Menu.Skills.Q.Auto:Value() and LocalGeometry:IsInRange(myHero.pos, target.pos, Q.Range) then
			local castPosition, accuracy = LocalGeometry:GetCastPosition(myHero, target, Q.Range, Q.Delay, Q.Speed, Q.Radius, Q.Collision, Q.IsLine)
			if accuracy > 0 then
				CastSpell(HK_Q, target.pos)			
			end	
		end
	end
end
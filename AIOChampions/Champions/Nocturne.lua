local function CastSpellMM(spell,pos,range,delay)
	local range = range or MathHuge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Latency() then
			local castPosMM = pos:ToMM()
			Control.SetCursorPos(castPosMM.x,castPosMM.y)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Latency()/1000)
		end
		if ticker - castSpell.casting > Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
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

local function GetEnemyHeroes()
	return Enemies
end 

local function GetEnemyHeroesInRange(pos, range)
local _EnemyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit and unit.isEnemy and GetDistanceSqr(pos, unit.pos) < range and IsValid(unit) then
			TableInsert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local function OnProcessSpell()
	for i = 1, #Units do
		local unit = Units[i].unit; local last = Units[i].spell; local spell = unit.activeSpell
		if spell and last ~= (spell.name .. spell.endTime) and unit.activeSpell.isChanneling then
			Units[i].spell = spell.name .. spell.endTime; return unit, spell
		end
	end
	return nil, nil
end

local Rrange = 1750 + 750 * myHero:GetSpellData(_R).level

function LoadScript()
	RActiv = false
	SpellsLoaded = false
	
	Menu = MenuElement({type = MENU, id = "PussyAIO".. myHero.charName, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.05"}})	
	
	--ComboMenu  
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	Menu.Combo:MenuElement({id = "UseR", name = "[R] if killable with FullCombo", value = true})
	Menu.Combo:MenuElement({id = "range", name = "[R] is range bigger than", value = 1000, min = 0, max = Rrange, step = 10, identifier = "range"})	
	Menu.Combo:MenuElement({id = "Draw", name = "Draw Killable FullCombo[onScreen+Minimap]", value = true})
	
	Menu:MenuElement({type = MENU, id = "spells", name = "Auto [W] Settings (WIP)"})
	Menu.spells:MenuElement({id = "wblock", name = "[W] Block Spells", value = true})
	for i, enemy in pairs(GetEnemyHeroes()) do
		Menu.spells:MenuElement({type = MENU, id = enemy.charName, name = enemy.charName})	
	end
  
	--LaneClear Menu
	Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	Menu.Clear:MenuElement({id = "UseQM", name = "Use[Q] min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})	
	Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 2, min = 1, max = 7, step = 1, identifier = "Minion/s"})  
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	Menu:MenuElement({type = MENU, id = "JClear", name = "JungelClear"})
	Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})
	Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"}) 		
	
	--Prediction
	Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	Menu.Pred:MenuElement({name = " ", drop = {"After change Pred.Typ reload 2x F6"}})
	Menu.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 3, drop = {"Gamsteron Prediction", "Premium Prediction", "GGPrediction"}})	
	Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = false})
	Menu.Drawing:MenuElement({id = "DrawRMiniMap", name = "Draw [R] Range MiniMap", value = true})	
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1200, Speed = 1600, Collision = false
	}
	
	QspellData = {speed = 1600, range = 1200, delay = 0.25, radius = 60, collision = {nil}, type = "linear"}		

	Callback.Add("Tick", function() Tick() end)

	Callback.Add("Draw", function()
	if myHero.dead then return end

		if Menu.Drawing.DrawR:Value() and Ready(_R) then
		DrawCircle(myHero, Rrange, 1, DrawColor(255, 225, 255, 10))
		end
		if Menu.Drawing.DrawRMiniMap:Value() and Ready(_R) then
			local Pos = myHero.pos
			if myHero:GetSpellData(_R).level == 1 then
			Draw.CircleMinimap(Pos.x, Pos.y, Pos.z, 2500, 1, DrawColor(255, 225, 255, 10))
			elseif myHero:GetSpellData(_R).level == 2 then
			Draw.CircleMinimap(Pos.x, Pos.y, Pos.z, 3250, 1, DrawColor(255, 225, 255, 10))
			elseif myHero:GetSpellData(_R).level == 3 then
			Draw.CircleMinimap(Pos.x, Pos.y, Pos.z, 4000, 1, DrawColor(255, 225, 255, 10))		
			end
		end	
		if Menu.Drawing.DrawQ:Value() and Ready(_Q) then
		DrawCircle(myHero, 1200, 1, DrawColor(225, 225, 0, 10))
		end
		if Menu.Drawing.DrawE:Value() and Ready(_E) then
		DrawCircle(myHero, 425, 1, DrawColor(225, 225, 125, 10))
		end
		
		for i, target in pairs(GetEnemyHeroes()) do	
			if Menu.Combo.Draw:Value() and myHero.pos:DistanceTo(target.pos) <= 10000 and IsValid(target) then
			local RDmg = getdmg("R", target, myHero)
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local FullDmg = (RDmg + QDmg + EDmg)
			local hp = target.health	
				if Ready(_R) and Ready(_Q) and Ready(_E) and FullDmg > hp then
					DrawText("Ult Kill", 24, target.pos2D.x, target.pos2D.y,DrawColor(0xFF00FF00))
					DrawText("Ult Kill", 13, target.posMM.x - 15, target.posMM.y - 15,DrawColor(0xFF00FF00))
				end	
			end
		end	
	end)		
end
 
--Full Credits to Ronin (BlockSpells)
function LoadBlockSpells()
	for i = 1, GameHeroCount(i) do
	local t = GameHero(i)
		if t and t.isEnemy then		
			for slot = 0, 3 do
			local enemy = t
			local spellName = enemy:GetSpellData(slot).name
				if slot == 0 and Menu.spells[enemy.charName] then
					Menu.spells[enemy.charName]:MenuElement({ id = spellName, name = "Block [Q]", value = false })
				end
				if slot == 1 and Menu.spells[enemy.charName] then
					Menu.spells[enemy.charName]:MenuElement({ id = spellName, name = "Block [W]", value = false })
				end
				if slot == 2 and Menu.spells[enemy.charName] then
					Menu.spells[enemy.charName]:MenuElement({ id = spellName, name = "Block [E]", value = false })
				end
				if slot == 3 and Menu.spells[enemy.charName] then
					Menu.spells[enemy.charName]:MenuElement({ id = spellName, name = "Block [R]", value = false })
				end			
			end
		end
	end
end

function Tick()
if not SpellsLoaded then 
	LoadBlockSpells()
	SpellsLoaded = true
end

if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		if not RActiv then
			Combo()
		end	
		if Ready(_R) then
			Ult()
		end	
	elseif Mode == "Clear" then
		Clear()
		JungleClear()
	end	
	
	if myHero:GetSpellData(_R).name == "NocturneParanoia2" then
		RActiv = true
	else
		RActiv = false
	end	
	
	if RActiv then
		SetAttack(false)
		SetMovement(false)
	else
		SetAttack(true)
		SetMovement(true)	
	end

	if Ready(_W) and Menu.spells.wblock:Value() and SpellsLoaded == true then
		local unit, spell = OnProcessSpell()
		--for i = 1, #Units do
			--local current = GetEnemyHeroesInRange(myHero.pos, 2000)[i]
			if unit and unit.isEnemy and myHero.pos:DistanceTo(unit.pos) < 3000 and spell then
				if unit.activeSpell and unit.activeSpell.valid and
				(unit.activeSpell.target == myHero.handle or 
				GetDistance(unit.activeSpell.placementPos, myHero.pos) <= myHero.boundingRadius * 2 + unit.activeSpell.width) and not 
				string.find(unit.activeSpell.name:lower(), "attack") then
					for j = 0, 3 do
						local cast = unit:GetSpellData(j)
						if Menu.spells[unit.charName][cast.name] and Menu.spells[unit.charName][cast.name]:Value() and cast.name == unit.activeSpell.name then
							local startPos = unit.activeSpell.startPos
							local placementPos = unit.activeSpell.placementPos
							local width = 0
							if unit.activeSpell.width > 0 then
								width = unit.activeSpell.width
							else
								width = 100
							end
							local distance = GetDistance(myHero.pos, placementPos)											
							if unit.activeSpell.target == myHero.handle then
								Control.CastSpell(HK_W)
								return
							else
								if distance <= width * 2 + myHero.boundingRadius then
									Control.CastSpell(HK_W)
								break
								end
							end							
						end
					end
				end
			end
		--end
	end	
end

function Ult()
local target = GetTarget(Rrange+100)     	
if target == nil then return end
	if IsValid(target) then
			
		if myHero.pos:DistanceTo(target.pos) <= Rrange and myHero.pos:DistanceTo(target.pos) > Menu.Combo.range:Value() and Menu.Combo.UseR:Value() then
			local RDmg = getdmg("R", target, myHero)
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local FullDmg = (RDmg + QDmg + EDmg)
			if FullDmg >= target.health then
				if myHero:GetSpellData(_R).name == "NocturneParanoia" then
					Control.CastSpell(HK_R)
				end	
				if myHero:GetSpellData(_R).name == "NocturneParanoia2" then
					if target.pos:To2D().onScreen then
						Control.CastSpell(HK_R, target)
					else
						CastSpellMM(HK_R, target.pos, Rrange)                            
					end
				end	
			end
		end
	end	
end
	
function Combo()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target) then

	
		if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) and Menu.Combo.UseQ:Value() then
			if Menu.Pred.Change:Value() == 1 then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= Menu.Pred.PredQ:Value()+1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			elseif Menu.Pred.Change:Value() == 2 then
				local pred = _G.PremiumPrediction:GetPrediction(myHero, target, QspellData)
				if pred.CastPos and ConvertToHitChance(Menu.Pred.PredQ:Value(), pred.HitChance) then
					Control.CastSpell(HK_Q, pred.CastPos)
				end
			else
				local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1200, Speed = 1600, Collision = false})
				QPrediction:GetPrediction(target, myHero)
				if QPrediction:CanHit(Menu.Pred.PredQ:Value() + 1) then
					Control.CastSpell(HK_Q, QPrediction.CastPosition)
				end				
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) < 400 and Ready(_E) and Menu.Combo.UseE:Value() then
			Control.CastSpell(HK_E, target)
        end				
		
		if myHero.pos:DistanceTo(target.pos) < 300 and Menu.Combo.UseW:Value() and Ready(_W) then				
			Control.CastSpell(HK_W)
		end
	end	
end	

function Clear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_ENEMY and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < 1200 and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and Ready(_Q) then
				local count = GetMinionCount(100, minion)
				if count >= Menu.Clear.UseQM:Value() then
					Control.CastSpell(HK_Q, minion.pos)
				end	
            end
                      
			if myHero.pos:DistanceTo(minion.pos) < 425 and Ready(_E) and Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				local count = GetMinionCount(100, minion)
				if count >= Menu.Clear.UseEM:Value() then
					Control.CastSpell(HK_E, minion)
                end    
            end
        end
    end
end

function JungleClear()
	for i = 1, GameMinionCount() do
    local minion = GameMinion(i)
	
		if myHero.pos:DistanceTo(minion.pos) <= 1300 and minion.team == TEAM_JUNGLE and IsValid(minion) then
            
            
			if myHero.pos:DistanceTo(minion.pos) < 1200 and Menu.Clear.UseQ:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end
                      
			if myHero.pos:DistanceTo(minion.pos) < 425 and Ready(_E) and Menu.Clear.UseE:Value() and myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100 then
				Control.CastSpell(HK_E, minion)    
            end
        end
    end
end

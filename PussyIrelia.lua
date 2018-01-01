class "PussyIrelia"
 
 --init
function PussyIrelia:__init()
    if myHero.charName ~= "Irelia" then return end
    require('DamageLib')
    PrintChat("[PussyIrelia] loaded")
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add('Tick', function() self:Tick() end)
    Callback.Add('Draw', function() self:Draw() end)
 
end

--SpellLoad
function PussyIrelia:LoadSpells()
    Q = {Range = 650}
    W = {Range = 200}
    E = {Range = 325}
    R = {Range = 1000, Delay = 0.5, Radius = 120, Speed = 1600}
end

--MENU
function PussyIrelia:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "PussyIrelia", name = "PussyIrelia", leftIcon="http://puu.sh/trYUs/449a80b95c.jpg"})
 
    --Combo
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
    self.Menu.Combo:MenuElement({id = "CombQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "CombW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "CombE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "CombR", name = "Use R", value = true})
    
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE comming soon"})
	self.Menu.AutoE:MenuElement({id = "AutoE", name = "Use E", value = true})
	
    --Harass
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
    self.Menu.Harass:MenuElement({id = "HaQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "HaE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "HaMana", name = "Min. Mana", value = 40, min = 0, max = 100})
 
    --Farm
    self.Menu:MenuElement({type = MENU, id = "Farm", name = "LaneClear"})
    self.Menu.Farm:MenuElement({id = "lcW", name = "Use W", value = true})
    self.Menu.Farm:MenuElement({id = "lcMana", name = "Min. Mana", value = 40, min = 0, max = 100})
	self.Menu.Farm:MenuElement({id = "lcQ", name = "UseQ only Lasthit", value = true})
    self.Menu.Farm:MenuElement({id = "lcMana", name = "Min. Mana", value = 40, min = 0, max = 100})
	
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JungleClear", name = "JungleClear comming soon"})
    self.Menu.JungleClear:MenuElement({id = "jcW", name = "Use W", value = true})
	self.Menu.JungleClear:MenuElement({id = "jcQ", name = "Use Q", value = true})
    self.Menu.JungleClear:MenuElement({id = "jcE", name = "Use E", value = true})
	
    --LastHit 
    self.Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit"})
    self.Menu.LastHit:MenuElement({id = "lhQ", name = "Use Q", value = true})
    self.Menu.LastHit:MenuElement({id = "lhMana", name = "Min. Mana", value = 40, min = 0, max = 100})
 
    --Misc
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})
if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
	self.Menu.Misc:MenuElement({id = "IgniteE", name = "Use Ignite", value = true})
end
    self.Menu.Misc:MenuElement({id = "kswithQ", name = "Use Q to ks", value = true})
    self.Menu.Misc:MenuElement({id = "kswithR", name = "Use R to ks", value = true})
 
 
    --Draw
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawSpells", name = "Draw Only Ready Spells", value = true})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})
 
    PrintChat("[PussyIrelia] Menu Loaded")
end
--MENU END


--TICK
function PussyIrelia:Tick()
 
    local target = self:GetTarget(R.Range)
 
    self:Misc()

    if self:GetMode() == "Combo" then
        self:Combo(target)
    elseif self:GetMode() == "Harass" then
        self:Harass(target)
    elseif self:GetMode() == "LaneClear" then
        self:Farm()
    elseif self:GetMode() == "LastHit" then
        self:LastHit()
	end
end
--TICK END


--IMPORTANT
function PussyIrelia:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end
 
function PussyIrelia:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end
 
function PussyIrelia:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end
 
function PussyIrelia:GetRange(spell)
  return myHero:GetSpellData(spell).range
end

function PussyIrelia:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end
 
function PussyIrelia:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance ~= nil
end
--IMPORTANT NEEDED


--LHCS
function PussyIrelia:GetMinions(team)
    local Minions
    if Minions then return Minions end
    Minions = {}
    for i = 1, Game.MinionCount() do
        local Minion = Game.Minion(i)
        if team then
            if Minion.team == team then
                table.insert(Minions, Minion)
            end
        else
            table.insert(Minions, Minion)
        end
    end
    return Minions
end
--ENDLHCS



--LCCS
function PussyIrelia:GetFarmTarget(range)
    local target
    for j = 1,Game.MinionCount() do
        local minion = Game.Minion(j)
        if self:IsValidTarget(minion, range) and minion.team ~= myHero.team then
            target = minion
            break
        end
    end
    return target
end
--END LCCS


--GETTARGET
function PussyIrelia:GetTarget(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
            target = hero
            break
        end
    end
    return target
end
--GETTARGET END


--MISC FOR IGNITE + KS
function PussyIrelia:Misc()
     for i = 1,Game.HeroCount() do
        local Enemy = Game.Hero(i)
        if self:IsValidTarget(Enemy, 650) and Enemy.team ~= myHero.team then
            if self.Menu.Misc.kswithQ:Value() then
                if getdmg("Q", Enemy, myHero) > Enemy.health then
                    self:CastQ(Enemy)
                    return;
                end
            end
        end


        if self:IsValidTarget(Enemy, 1000) and Enemy.team ~= myHero.team then
            if self.Menu.Misc.kswithR:Value() then
                if getdmg("R", Enemy, myHero) > Enemy.health then
                    self:CastR(Enemy)
                    return;
                end
            end
        

             --IGNITE
            if myHero:GetSpellData(5).name == "SummonerDot" and self.Menu.Misc.IgniteE:Value() and self:IsReady(SUMMONER_2) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_2, Enemy)
                    return;
                end
            end

            if myHero:GetSpellData(4).name == "SummonerDot" and self.Menu.Misc.IgniteE:Value() and self:IsReady(SUMMONER_1) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_1, Enemy)
                    return;
                end
            end
        end
    end
end
--MISC END



--Harass
function PussyIrelia:Harass(target)
    if (myHero.mana/myHero.maxMana >= self.Menu.Harass.HaMana:Value() / 100) then
        local target = self:GetTarget(Q.Range)
        if self.Menu.Harass.HaQ:Value() and self:CanCast(_Q) then
            self:CastQ(target)
        end

        local target = self:GetTarget(E.Range)
        if self.Menu.Harass.HaE:Value() and self:CanCast(_E) then
            self:CastE(target)
        end
    end
end
--Harass end

--COMBO
function PussyIrelia:Combo(target)
		local target = self:GetTarget(Q.Range)
		if self.Menu.Combo.CombQ:Value() and self:CanCast(_Q) and self:IsValidTarget(target, Q.Range) then
            self:CastQ(target)
		local target = self:GetTarget(R.Range)		
        elseif self.Menu.Combo.CombR:Value() and self:CanCast(_R) and self:IsValidTarget(target, R.Range) then
			self:CastR(target)
		local target = self:GetTarget(E.Range)
        elseif self.Menu.Combo.CombE:Value() and self:CanCast(_E) and self:IsValidTarget(target, E.Range) then
            self:CastE(target)
		local target = self:GetTarget(W.Range)
        elseif self.Menu.Combo.CombW:Value() and self:CanCast(_W) and self:IsValidTarget(target, W.Range) then
			self:CastW()

 
        end
end

--COMBO END

local function HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end


function PercentHP(unit)
	return (unit.health * 100) / unit.maxHealth
end

function PussyIrelia:AutoE()
        if self.Menu.AutoE.AutoE:Value() and self:CanCast(_E) and self:IsValidTarget(target, E.Range) then
          if PercentHP(Target) >= PercentHP(myHero) then
            self:CastE(target)
		end
	end 
 end
 
--LANELCLEAR
function PussyIrelia:Farm()
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			if self.Menu.Farm.lcW:Value() and self:CanCast(_W) then
					self:CastW()
			end
			local level = myHero:GetSpellData(_Q).level
			local Qdamage = (({20, 50, 80, 110, 140})[level] + 1.2 *myHero.totalDamage ) 
			if self.Menu.Farm.lcQ:Value() and self:IsValidTarget (minion) and myHero.pos:DistanceTo(minion.pos) < 650 and (myHero.mana/myHero.maxMana >= self.Menu.Farm.lcMana:Value() / 100 ) then
				if Qdamage >= HpPred(minion, 0.8) and self:CanCast(_Q) then
					self:CastQ(minion)
				end
			end
      	end
	end
end 

--LANECLEAR END


--JUNGLECLEAR









--JUNGLECLEAR END

--LASTHIT
function PussyIrelia:LastHit()
	local level = myHero:GetSpellData(_Q).level
  	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			local Qdamage = (({20, 50, 80, 110, 140})[level] + 1.2 *myHero.totalDamage ) 
			if self.Menu.LastHit.lhQ:Value() and self:IsValidTarget (minion) and myHero.pos:DistanceTo(minion.pos) < 650 and (myHero.mana/myHero.maxMana >= self.Menu.LastHit.lhMana:Value() / 100 ) then
				if Qdamage >= HpPred(minion, 0.8) and self:CanCast(_Q) then
					self:CastQ(minion)
				end
			end
      	end
	end
end 

--LASTHIT END

--MODE
function PussyIrelia:GetMode()
    if _G.SDK and _G.SDK.Orbwalker then
        if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
            return "Combo"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
            return "Harass"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
            return "LaneClear"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
            return "LastHit"
		end
    else    
        return GOS.GetMode()
    end
end
--MODE END

--Q W E R CAST

function PussyIrelia:CastQ(unit)
    Control.CastSpell(HK_Q, unit)
end
 
 
--W CAST
function PussyIrelia:CastW()
    Control.CastSpell(HK_W)
end
 
 
--E CAST
function PussyIrelia:CastE(unit)
    Control.CastSpell(HK_E, unit)
end
 
 
--R CAST
function PussyIrelia:CastR(Rtarget)
    if Rtarget then
        local castPos = Rtarget:GetPrediction(R.Speed, R.Delay)
        Control.CastSpell(HK_R, castPos)
    end
end

--END Q W E R CAST

--DRAWINGS
function PussyIrelia:Draw()
    if myHero.dead then return end
    if self.Menu.Draw.DrawSpells:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos,Q.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos,W.Range,1,Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos,E.Range,1,Draw.Color(255, 255, 255, 255))
        end
    end
end
--DRAWINGS END
 
 
 
 
function OnLoad()
    PussyIrelia()

end

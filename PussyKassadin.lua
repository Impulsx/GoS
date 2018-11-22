local menu = 1
class "Kassadin"

require 'DamageLib'

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end 

function CanMove()
  if _G.SDK then
    return _G.SDK.Orbwalker:CanMove()  
  end
end
function CanAttack()
  if _G.SDK then
    _G.SDK.Orbwalker:CanAttack()
  end
end 
function GetDistanceSqr(p1, p2)
  if not p1 then return math.huge end
  p2 = p2 or myHero
  local dx = p1.x - p2.x
  local dz = (p1.z or p1.y) - (p2.z or p2.y)
  return dx*dx + dz*dz
end

function GetDistance(p1, p2)
  p2 = p2 or myHero
  return math.sqrt(GetDistanceSqr(p1, p2))
end

local function IsValidCreep(unit, range)
  return unit and unit.team ~= TEAM_ALLY and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false and unit.visible
end

local function GetMinionCount(range, pos)
    local pos = pos.pos
      local count = 0
      for i = 1,Game.MinionCount() do
          local hero = Game.Minion(i)
          local Range = range * range
          if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
              count = count + 1
          end
      end
      return count
  end
  
	local function EnemyAround()
		for i = 1, Game.HeroCount() do 
		local Hero = Game.Hero(i) 
			if Hero.dead == false and Hero.team == TEAM_ENEMY and GetDistanceSqr(myHero.pos, Hero.pos) < 360000 then
				return true
			end
		end
		return false
	end  

function IsUnderTurret(unit)
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        local range = (turret.boundingRadius + 750 + unit.boundingRadius / 2)
        if turret.isEnemy and not turret.dead then
            if turret.pos:DistanceTo(unit.pos) < range then
                return true
            end
        end
    end
    return false
end

local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,
}

local function GetItemSlot(unit, id)
	  for i = ITEM_1, ITEM_7 do
	    if unit:GetItemData(i).itemID == id then
	      return i
	    end
	  end
	  return 0 
end



function Kassadin:__init()
  if menu ~= 1 then return end
  menu = 2
  self.passiveTracker = 0
  self.stacks = 0
  self:LoadSpells()
  self:LoadMenu()                                             --Init
  Callback.Add("Tick", function() self:Tick() end)
  Callback.Add("Draw", function() self:Draw() end)  

end



function Kassadin:LoadSpells()

  Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
  W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
  E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
  R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Kassadin:LoadMenu()                     
  --MainMenu
  self.Menu = MenuElement({type = MENU, id = "Kassadin", name = "PussyKassadin"})
  --ComboMenu  
  self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
  self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
  self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
  self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
  self.Menu.Combo:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
  --EscapeMenu
  self.Menu:MenuElement({type = MENU, id = "Escape", name = "Escape with Ult"})
  self.Menu.Escape:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true, tooltip = "Only if Ally in range"})
  self.Menu.Escape:MenuElement({id = "MinR", name = "Safe life % to use R", value = 20, min = 1, max = 100})
  --HarassMenu
  self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
  self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
  self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
  self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass(%)", value = 65, min = 0, max = 100})
  --LaneClear Menu
  self.Menu:MenuElement({type = MENU, id = "Clear", name = "Lane Clear"})
  self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})         
  self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
  self.Menu.Clear:MenuElement({id = "EHit", name = "[E] if x minions", value = 3, min = 1, max = 7})
  self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear(%)", value = 50, min = 0, max = 100})
  --LastHit Menu
  self.Menu:MenuElement({type = MENU, id = "Lasthit", name = "Lasthit"})
  self.Menu.Lasthit:MenuElement({id = "AutoQ", name = "Auto Q Lasthit", key = string.byte("K"),toggle = true})
  self.Menu.Lasthit:MenuElement({id = "Mana", name = "Min Mana to Lasthit (%)", value = 65, min = 0, max = 100})
  --Activator
  self.Menu:MenuElement({type = MENU, id = "a", name = "Activator"})		
  self.Menu.a:MenuElement({type = MENU, id = "Zhonyas", name = "Zhonya's + StopWatch"})
  self.Menu.a.Zhonyas:MenuElement({id = "ON", name = "Enabled", value = true})
  self.Menu.a.Zhonyas:MenuElement({id = "HP", name = "HP %", value = 15, min = 0, max = 100, step = 1})
  self.Menu.a:MenuElement({type = MENU, id = "Seraphs", name = "Seraph's Embrace"})
  self.Menu.a.Seraphs:MenuElement({id = "ON", name = "Enabled", value = true})
  self.Menu.a.Seraphs:MenuElement({id = "HP", name = "HP %", value = 15, min = 0, max = 100, step = 1})
  --Drawing 
  self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
  self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
  self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})

end

function Kassadin:Activator()
		if self.Menu.a.Zhonyas.ON:Value() then
		local Zhonyas = GetItemSlot(myHero, 3157) or GetItemSlot(myHero, 3420)
			if Zhonyas >= 1 and Ready(Zhonyas) then 
				if EnemyAround() and myHero.health/myHero.maxHealth < self.Menu.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
		if self.Menu.a.Seraphs.ON:Value() then
		local Seraphs = GetItemSlot(myHero, 3040)
			if Seraphs >= 1 and Ready(Seraphs) then
				if EnemyAround() and myHero.health/myHero.maxHealth < self.Menu.a.Seraphs.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Seraphs])
				end
			end
		end
end



function Kassadin:Draw()
  if myHero.dead then return end
  if(self.Menu.Drawing.DrawR:Value())then
    Draw.Circle(myHero, 500, 3, Draw.Color(255, 225, 255, 10))
  end                                                 
  if(self.Menu.Drawing.DrawQ:Value())then
    Draw.Circle(myHero, Q.range, 3, Draw.Color(225, 225, 0, 10))
  end
end

function Kassadin:ValidTarget(unit,range) 
  return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal 
end

function Kassadin:Tick()
  if myHero.dead then return end
	self:OnBuff(myHero)
    if self.Menu.Lasthit.AutoQ:Value() then
      self:LastHit()
    end
    if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
      self:Combo()
      self:Combo1()
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then                
      self:Harass()
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
      self:Clear()
	end
	self:Activator()
	--self:EscapeR()

end

function Kassadin:OnBuff(unit)

  if unit.buffCount == nil then self.passiveTracker = 0 self.stacks = 0 return end
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    
    if buff.name == "forcepulsecancast" then
      self.passiveTracker = buff.count
	end  
    if buff.name == "forcepulsecounter" then
	  self.passiveTracker = buff.count
    end
    if buff.name == "RiftWalk" then
      self.stacks = buff.count      
    end     
  end
end


	function Kassadin:Qdmg(unit)
		local base = ({65, 95, 125, 155, 185})[myHero:GetSpellData(_Q).level] + 0.70 * myHero.ap
		return CalcMagicalDamage(myHero,unit, base)
	end

	function Kassadin:Wdmg(unit)
		local base = ({60, 85, 110, 135, 160})[myHero:GetSpellData(_W).level] + 0.90 * myHero.ap
		return CalcMagicalDamage(myHero,unit, base)
	end

	function Kassadin:Edmg(unit)
		local base = ({80, 105, 130, 155, 180})[myHero:GetSpellData(_W).level] + 0.80 * myHero.ap
		return CalcMagicalDamage(myHero,unit, base)
	end
	
	function Kassadin:Rdmg(unit)
		local base = ({80, 100, 120})[myHero:GetSpellData(_R).level] + (0.40 * myHero.ap) + 0.02 * myHero.maxMana
		return CalcMagicalDamage(myHero,unit, base)
	end	

function Kassadin:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end	



function Kassadin:HasRbuff(unit)
	for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)
	for i = 1, hero.buffCount do
		local buff = hero:GetBuff(i)
		if self:HasBuff(hero, "RiftWalk") then  
		if buff then
			return true
		end
	end
	return false
end
end
end	

function Kassadin:GetRstacks(unit)

	local stacks = 0
	if self:HasRbuff(unit) then
		for i = 1, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and buff.count > 0 and buff.name:lower() == "RiftWalk" then
				stacks = buff.count
			end
		end
	end
	return stacks
end

function Kassadin:GetStackDmg(unit)

	local total = 0
	local rLvl = myHero:GetSpellData(_R).level
	if rLvl > 0 then
		local raw = ({ 80, 100, 120})[rLvl] + (0.40 * myHero.ap) + (0.02 * myHero.maxMana)
		local a = self:GetRstacks(myHero) * ({ 40, 50, 60})[rLvl]   
		local b = self:GetRstacks(myHero) * 0.10 * myHero.ap
		local c = self:GetRstacks(myHero) * 0.01 * myHero.maxMana
		total = raw + a + b + c
	end
	return total
end

function Kassadin:ClearLogic()
  local EPos = nil 
  local Most = 0 
    for i = 1, Game.MinionCount() do
    local Minion = Game.Minion(i)
      if IsValidCreep(Minion, 350) then
        local Count = GetMinionCount(400, Minion)
        if Count > Most then
          Most = Count
          EPos = Minion.pos
        end
      end
    end
    return EPos, Most
  end 


function Kassadin:Combo()
  local target = _G.SDK.TargetSelector:GetTarget(650, _G.SDK.DAMAGE_TYPE_MAGICAL)
  if target == nil then return end
	if self.Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) < 600 and self.passiveTracker >= 1 then
		local Hpred = target:GetPrediction(E.speed, 0.25 + Game.Latency()/1000)
		Control.CastSpell(HK_E, Hpred)
	end
	if self.Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 650 and myHero.pos:DistanceTo(target.pos) > myHero.range then
		Control.CastSpell(HK_Q, target)
	end
	if self.Menu.Combo.UseW:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) > myHero.range then
		Control.CastSpell(HK_W)
	end
end

--[[
function Kassadin:EscapeR()
for i = 1,Game.HeroCount()  do
	local hero = Game.Hero(i)
	local target = _G.SDK.TargetSelector:GetTarget(500, _G.SDK.DAMAGE_TYPE_MAGICAL)
	if target == nil then return end
		if self.Menu.Escape.UseR:Value() and Ready(_R) and 100*myHero.health/myHero.maxHealth <= self.Menu.Escape.MinR:Value() then 
			if self:CountEnemy(hero.pos,500) > 0 then
				if self:ValidTarget(hero,500) and hero.isAlly and not hero.isMe and myHero.pos:DistanceTo(hero.pos) > myHero.range then
					Control.CastSpell(HK_R, hero.pos)
					
				end
			end
		end	
	end
end ]]
	
	function Kassadin:Harass()
  local target = _G.SDK.TargetSelector:GetTarget(650, _G.SDK.DAMAGE_TYPE_MAGICAL)
  if target == nil then return end
  if self.Menu.Harass.UseE:Value() and self.passiveTracker >= 1 and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) and myHero.pos:DistanceTo(target.pos) < 600 then
    local Hpred = target:GetPrediction(E.speed, 0.25 + Game.Latency()/1000)
    Control.CastSpell(HK_E, Hpred)
  end
  if self:ValidTarget(target,650) and self.Menu.Harass.UseQ:Value() and Ready(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) and myHero.pos:DistanceTo(target.pos) < 650 then
    Control.CastSpell(HK_Q, target)
  end
end

function Kassadin:Clear()
   
  for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
    local Qdamage = self:Qdmg(minion)
    if Qdamage >= minion.health then
      if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 550 and self.Menu.Clear.UseQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and minion.isEnemy and myHero.pos:DistanceTo(minion.pos) > myHero.range then
        Control.CastSpell(HK_Q,minion)
      end
    end
    if self.passiveTracker >= 1 and myHero.pos:DistanceTo(minion.pos) < 550 and self.Menu.Clear.UseE:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) and minion.isEnemy and myHero.pos:DistanceTo(minion.pos) > myHero.range then
      local EPos, Count = self:ClearLogic()
      if EPos == nil then return end
      if Count >= self.Menu.Clear.EHit:Value() then
        Control.CastSpell(HK_E, EPos)
      end
    end  
  end
end

function Kassadin:LastHit()
  if Ready(_Q) then
    for i = 1, Game.MinionCount() do
      local minion = Game.Minion(i)      
      local Qdamage = self:Qdmg(minion)
	  if Qdamage >= minion.health then
        if self:ValidTarget(minion,650) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 550 and minion.isEnemy and myHero.pos:DistanceTo(minion.pos) > myHero.range then
          Control.CastSpell(HK_Q,minion)
        end
      end         
    end
  end
end

function Kassadin:Combo1()
  for _, enemy in pairs(_G.SDK.ObjectManager:GetEnemyHeroes(1000)) do
    if enemy ~= nil then
      local hp = enemy.health
      local dist = myHero.pos:DistanceTo(enemy.pos)
      
	  if (Ready(_Q) and self.Menu.Combo.UseQ:Value()) then 
        qdmg = self:Qdmg(enemy) 
      else qdmg = 0 
      end
	  if (Ready(_W) and self.Menu.Combo.UseW:Value()) then		
		wdmg = self:Wdmg(enemy)
	  else wdmg = 0 
      end	
      if (Ready(_E) and self.Menu.Combo.UseE:Value()) then 
        edmg = self:Edmg(enemy) 
      else edmg = 0 
      end
      if (Ready(_R) and self.Menu.Combo.UseR:Value()) then 
        rdmg = self:GetStackDmg(enemy) 
      else rdmg = 0 
      end
      
      if dist < Q.range and qdmg > hp then
        Control.CastSpell(HK_Q, enemy)
        return
      end
      if dist < E.range and edmg > hp and self.passiveTracker >= 1 then
        Control.CastSpell(HK_E, enemy.pos)
        return
      end
      if dist < 600 and rdmg+qdmg > hp then
        Control.CastSpell(HK_R, enemy.pos)
        Control.CastSpell(HK_Q, enemy)
		return
      end
      if dist < E.range and qdmg+edmg > hp and self.passiveTracker >= 1 then
        Control.CastSpell(HK_E, enemy.pos)
        Control.CastSpell(HK_Q, enemy)
        return
      end
      if dist < R.range and qdmg+edmg+rdmg > hp and self.passiveTracker >= 1 then
        Control.CastSpell(HK_R, enemy.pos)
        Control.CastSpell(HK_E, enemy.pos)
        Control.CastSpell(HK_Q, enemy)
		return
      end
	    if dist < R.range and qdmg+edmg+rdmg+wdmg > hp and self.passiveTracker >= 1 then
        Control.CastSpell(HK_R, enemy.pos)
		Control.CastSpell(HK_E, enemy.pos)
        Control.CastSpell(HK_Q, enemy)
		return
      end
    end
  end
end


function OnLoad()
  Kassadin()
end

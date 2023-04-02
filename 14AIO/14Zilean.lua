require 'GamsteronPrediction'
require 'GGPrediction'
require "DamageLib"
local EnemyLoaded = false
local EnemyHeroes = {}
local TableInsert       = _G.table.insert

local orbwalker         = _G.SDK.Orbwalker
local TargetSelector    = _G.SDK.TargetSelector
local GameHeroCount     = Game.HeroCount
local GameHero          = Game.Hero


local lastQ = 0
local lastW = 0
local lastE = 0
local lastR = 0
local lastIG = 0
local lastMove = 0
local lastAttack = 0


local Enemys =   {}
local Allys  =   {}

local function GetDistanceSquared(vec1, vec2)
    local dx = vec1.x - vec2.x
    local dy = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    return dx * dx + dy * dy
end


local function IsValid(unit)
    if (unit 
        and unit.valid 
        and unit.isTargetable 
        and unit.alive 
        and unit.visible 
        and unit.networkID 
        and unit.health > 0
        and not unit.dead
    ) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 
    and myHero:GetSpellData(spell).level > 0 
    and myHero:GetSpellData(spell).mana <= myHero.mana 
    and Game.CanUseSpell(spell) == 0
end

local function OnAllyHeroLoad(cb)
    for i = 1, GameHeroCount() do
        local obj = GameHero(i)
        if obj.isAlly then
            cb(obj)
        end
    end
end

local function OnEnemyHeroLoad(cb)
    for i = 1, GameHeroCount() do
        local obj = GameHero(i)
        if obj.isEnemy then
            cb(obj)
        end
    end
end

function GetEnemyHeroes()
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(EnemyHeroes, Hero)
            PrintChat(Hero.name)
        end
    end
    --PrintChat("Got Enemy Heroes")
end


class "Zilean"

function Zilean:__init()
    self.Q = {Type = _G.SPELLTYPE_CIRCLE, Delay = 0.8, Radius = 150, Range = 900, Speed = math.huge, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}}
    self.E = {Range = 550}
    self.R = {Range = 900}

    self:LoadMenu()

    OnAllyHeroLoad(function(hero) TableInsert(Allys, hero); end)
    OnEnemyHeroLoad(function(hero) TableInsert(Enemys, hero); end)

    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)

    orbwalker:OnPreAttack(
        function(args)
            if args.Process then
                if lastAttack + self.tyMenu.Human.AA:Value() > GetTickCount() then
                    args.Process = false
                    print("block aa")
                else
                    args.Process = true
                    self.AttackTarget = args.Target
                    lastAttack = GetTickCount()
                end
            end
        end
    )

    orbwalker:OnPreMovement(
        function(args)
            if args.Process then
                if (lastMove + self.tyMenu.Human.Move:Value() > GetTickCount()) or (ExtLibEvade and ExtLibEvade.Evading == true) then
                    args.Process = false
                else
                    args.Process = true
                    lastMove = GetTickCount()
                end
            end
        end 
    )

end

function Zilean:LoadMenu()

    self.tyMenu = MenuElement({type = MENU, id = "14Zilean", name = "14 Zilean"})

    self.tyMenu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
        self.tyMenu.Combo:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
        OnEnemyHeroLoad(function(hero) self.tyMenu.Combo.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
        self.tyMenu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
		self.tyMenu.Combo:MenuElement({id = "noaa", name = "[dont aa when q up]", value = true})
		self.tyMenu.Combo:MenuElement({id = "UseE", name = "[use e", value = false, key=string.byte("S")})
		self.tyMenu.Combo:MenuElement({id = "UseE2", name = "[use e right before using w", value = true, toggle=true, key=string.byte("E")})
		self.tyMenu.Combo:MenuElement({id = "UseEflee", name = "[use e before w on self if out of e range]", value = true})
		self.tyMenu.Combo:MenuElement({id = "Useqslow", name = "[prioritize using e before q]", value = false, toggle=true, key=string.byte("5")})
		
    self.tyMenu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
        self.tyMenu.Harass:MenuElement({name = "Use spell on:", id = "useon", type = _G.MENU})
        OnEnemyHeroLoad(function(hero) self.tyMenu.Harass.useon:MenuElement({id = hero.charName, name = hero.charName, value = true}) end)
        self.tyMenu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
    
    self.tyMenu:MenuElement({type = MENU, id = "Auto", name = "Auto"})
        self.tyMenu.Auto:MenuElement({id = "UseQ", name = "Auto Q if enemy has boom", value = false})
        self.tyMenu.Auto:MenuElement({id = "Rhp", name = "If Ally HP < X%", value = 20, min = 1, max = 100, step = 1})
        self.tyMenu.Auto:MenuElement({type = MENU, id = "Ron", name = "Use R On"})
        OnAllyHeroLoad(function(hero)
            self.tyMenu.Auto.Ron:MenuElement({id = hero.charName, name = hero.charName, value = true})
        end)
		self.tyMenu.Auto:MenuElement({type = MENU, id = "Eon", name = "Use E On"})
        OnAllyHeroLoad(function(hero)
            self.tyMenu.Auto.Eon:MenuElement({id = hero.charName, name = hero.charName, value = true})
        end)

    self.tyMenu:MenuElement({type = MENU, id = "Human", name = "Humanizer"})
        self.tyMenu.Human:MenuElement({id = "Move", name = "Only allow 1 movement in X Tick ", value = 180, min = 1, max = 500, step = 1})
        self.tyMenu.Human:MenuElement({id = "AA", name = "Only allow 1 AA in X Tick", value = 180, min = 1, max = 500, step = 1})

    self.tyMenu:MenuElement({type = MENU, id = "draw", name = "Drawing"})
        self.tyMenu.draw:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
        self.tyMenu.draw:MenuElement({id = "E", name = "Draw [E] Range", value = true})
        self.tyMenu.draw:MenuElement({id = "R", name = "Draw [R] Range", value = true})
    
	
	            if _G.SDK then
                _G.SDK.Orbwalker:CanAttackEvent(
                    function()
                        if
                            self.tyMenu.Combo.noaa:Value() and
                                ((_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo") or
                                    (_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass")) and
                                myHero:GetSpellData(_Q).currentCd <= 1
                         then
                            return false
                        end
                        return true
                    end
                )
            end
	
	
	
	
	
	
	
	
	
	
	
	
	

end

lastm=0

local LocalGetTickCount         = GetTickCount
local LocalVector		= Vector



local LocalGameHero 		= Game.Hero
local LocalGameMinionCount 	= Game.MinionCount
local LocalGameMinion 		= Game.Minion
local orbwalker         = _G.SDK.Orbwalker
redcast=0
local LocalTableInsert          = table.insert
local LocalTableSort            = table.sort
local LocalTableRemove          = table.remove;

local ipairs		        = ipairs
local pairs		        = pairs
    local ValidTarget =  function(unit, range)
	local range = type(range) == "number" and range or math.huge
	return unit and unit.team ~= myHero.team and unit.valid and unit.distance <= range and not unit.dead and unit.isTargetable and unit.visible
end
	local GetDistanceSqr = function(Pos1, Pos2)
	local Pos2 = Pos2 or myHero.pos
	local dx = Pos1.x - Pos2.x
	local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
	return dx^2 + dz^2
	end
	local lastETick=0
	local GetDistance = function(Pos1, Pos2)
		return math.sqrt(GetDistanceSqr(Pos1, Pos2))
	end

	Q2   = { range = 800 , delay = 0.8, speed = MathHuge, width = 150, collision = false, aoe = true, type = "linear" } 	
	
			function Zilean:mundoEcast(target)
				if target == nil then return end
				 
				
				if ValidTarget(target, 1200) then 
                local minions = _G.SDK.ObjectManager:GetMinions(900)
                for i = 1, #minions do
                    local minion = minions[i]
					
					
						if minion and not minion.dead and Zilean:HasQBuff(minion)  then 
							--local minionPos = LocalVector(myHero.pos):Extended(LocalVector(minion.pos), Q2.range)
							if GetDistance(target.pos, minion.pos) <= 330 then 
								if Ready(_W) then
									print("looking")
									
										if Ready(_E) and (self.tyMenu.Combo.UseE2:Value() or self.tyMenu.Combo.UseE:Value()) then
											if  GetDistanceSquared(target.pos, myHero.pos) <= (550+myHero.boundingRadius + target.boundingRadius)^2 then
												Control.CastSpell(HK_E,target)
												
											elseif  ((myHero.mana / myHero.maxMana)>0.75 or myHero.levelData.lvl>=6) and self.tyMenu.Combo.UseEflee:Value()  then
											    Control.KeyDown(18)
												Control.KeyDown(HK_E)
												Control.KeyUp(HK_E)
												Control.KeyUp(18)
											end
											
											
										end	
									Control.CastSpell(HK_W)
									lastW = GetTickCount()
									lastm = GetTickCount()
								end
								
								if Ready(_Q)then
									print("shooting")
										Control.CastSpell(HK_Q, minion.pos)
								end
						

							end
						end
						
					end
					
				    for i = 1, #Allys do
						local ally = Allys[i]	
						if ally and not ally.dead and Zilean:HasQBuff(ally) then
						
							if GetDistance(target.pos, ally.pos) <= 290 then 
								if Ready(_W) and GetDistance(myHero.pos, ally.pos)<=910   then
									--print("looking")
									
										if Ready(_E)  and self.tyMenu.Combo.UseE:Value() and GetDistanceSquared(target.pos, myHero.pos) <= (550+myHero.boundingRadius + target.boundingRadius)^2 then
											Control.CastSpell(HK_E,target)
										end	
									Control.CastSpell(HK_W)
									lastW = GetTickCount()
									lastm = GetTickCount()
								end
								
								if Ready(_Q) and lastQ+315<GetTickCount()then
									local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.2, Radius = 140, Range = 900, Speed = MathHuge, Collision = true, CollisionTypes={GGPrediction.COLLISION_YASUOWALL}})
										QPrediction:GetPrediction(ally, myHero)
										
										if QPrediction:CanHit(1) then
											Control.CastSpell(HK_Q, QPrediction.CastPosition)
											--print("cast Q "..GetTickCount())
											print("shooting at allybomb" )
										lastQ = GetTickCount()
										end
								end
							end
						end
					end
				end
			
			
			end



	local function HasBuffType(unit, type)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.type == type then
            return true
        end
    end
    return false

end

	
local function cantkill(unit,kill,ss,aa)
	--set kill to true if you dont want to waste on undying/revive targets
	--set ss to true if you dont want to cast on spellshield
	--set aa to true if ability applies onhit (yone q, ez q etc)

	for i = 0, unit.buffCount do
	
		local buff = unit:GetBuff(i)
		if buff.name:lower():find("kayler") and buff.count==1 then
			return true
		end
		
	
		if buff.name:lower():find("undyingrage") and (unit.health<100 or kill) and buff.count==1 then
			return true
		end
		if buff.name:lower():find("kindredrnodeathbuff") and (kill or (unit.health / unit.maxHealth)<0.11) and buff.count==1  then
			return true
		end	
		if buff.name:lower():find("chronoshift") and kill and buff.count==1 then
			return true
		end			
		
		if  buff.name:lower():find("willrevive") and kill and buff.count==1 then
			return true
		end
		
		
		
		if buff.name:lower():find("fioraw") or buff.name:lower():find("pantheone") and buff.count==1 then
			return true
		end
		
		if  buff.name:lower():find("jaxcounterstrike") and aa and buff.count==1  then
			return true
		end
		
		if  buff.name:lower():find("nilahw") and aa and buff.count==1  then
			return true
		end
		
		if  buff.name:lower():find("shenwbuff") and aa and buff.count==1  then
			return true
		end
		
	end
	if HasBuffType(unit, 4) and ss then
		return true
	end

	
	
	return false
end


function Zilean:Draw()
    if myHero.dead then return end

    if self.tyMenu.draw.Q:Value() and not self.tyMenu.Combo.Useqslow:Value() then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(255,255, 190, 000))
    end
	if self.tyMenu.draw.Q:Value() and  self.tyMenu.Combo.Useqslow:Value() then
        Draw.Circle(myHero.pos, self.Q.Range,Draw.Color(255,255, 0, 000))
    end
	
    if self.tyMenu.draw.E:Value() and Ready(_E) then
        Draw.Circle(myHero.pos, self.E.Range,Draw.Color(255,255, 162, 000))
    end
    if self.tyMenu.draw.R:Value() and Ready(_R) then
        Draw.Circle(myHero.pos, self.R.Range,Draw.Color(255,255, 162, 000))
    end

	if self.tyMenu.Combo.UseE2:Value() then
        Draw.Text("E: On ",20,myHero.pos:To2D(),Draw.Color(255 ,0,255,0))
    else
        Draw.Text("E: Off ",20,myHero.pos:To2D(),Draw.Color(255 ,255,0,0))

    end



end

local function HasBuff(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.name== "TimeWarp" and buff.count > 0 then
            --print(buff.name, buff.type)
		   return true
        end
    end
    return false
end

local function HasTWS(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.name== "timewarpslow" and buff.count > 0 then
          --  print(buff.name, buff.type)
		   return true
        end
    end
    return false
end

local function HasKR(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.name:lower():find("kindredrnodeathbuff") and buff.count > 0 then
          --  print(buff.name, buff.type)
		   return true
        end
    end
    return false
end


function Zilean:Tick()
    if myHero.dead or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) then
        return
    end
	allycount=0
	for i = 1, #Allys do
        local ally = Allys[i]
		if ally and  GetDistanceSquared(myHero.pos, ally.pos) <= (550+myHero.boundingRadius + ally.boundingRadius)^2 then
			allycount = allycount + 1
		end
	end
			-- ally hea

	self:AutoR()

	-- local target2 = TargetSelector:GetTarget(350)	
	-- if self:HasQBuff(myHero) and target2 then
		-- if Ready(_Q) then
			-- Control.CastSpell(HK_Q,myHero)
		-- elseif  Ready(_W) then
			-- if  Ready(_E) and (self.tyMenu.Combo.UseE2:Value() or self.tyMenu.Combo.UseE:Value()) then
		
			-- Control.CastSpell(HK_E,target2)
			-- end
			-- Control.CastSpell(HK_W)
		-- end
	-- end	
	local target2 = TargetSelector:GetTarget(1200)		
	if lastm +600 > GetTickCount() and target2 then
		 self:mundoEcast(target2)
	end
		
	local target1 = TargetSelector:GetTarget(550+myHero.boundingRadius+40)		

    if target1 and IsValid(target1) and self.tyMenu.Combo.UseE:Value() and Ready(_E) and  GetDistanceSquared(target1.pos, myHero.pos) <= (550+myHero.boundingRadius + target1.boundingRadius)^2  then
        Control.CastSpell(HK_E,target1)
	elseif self.tyMenu.Combo.UseE:Value() and not Ready(_E) and myHero:GetSpellData(_E).currentCd >= 3 and not Ready(_Q) and myHero:GetSpellData(_E).currentCd <= 10 and(not target1 or not HasTWS(target1)) and((target1 and IsValid(target1)) or (allycount>1)) then
		Control.CastSpell(HK_W)
		--Control.CastSpell(HK_E,target1)
		
    end
	
	if Ready(_E) and self.tyMenu.Combo.UseE:Value() and  not (target1 and  IsValid(target1) and  GetDistanceSquared(target1.pos, myHero.pos) <= (550+myHero.boundingRadius + target1.boundingRadius)^2) then
    for i = 1, #Allys do
        local ally = Allys[i]
					if ally and ally ~=myHero and GetDistanceSquared(myHero.pos, ally.pos) <= (550+myHero.boundingRadius + ally.boundingRadius)^2 and  self.tyMenu.Auto.Eon[ally.charName] then
					Control.CastSpell(HK_E,ally)
	
					return
					end
				end
	end
	
    if orbwalker.Modes[0] then --combo
        self:Combo()
    elseif orbwalker.Modes[1] then --harass
        self:Harass()
	elseif orbwalker.Modes[5] then
        if Ready(_E) then
                Control.KeyDown(18)
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                Control.KeyUp(18)
		lastE = GetTickCount()
		elseif not Ready(_E) and Ready(_W) and not HasBuff(myHero) and myHero:GetSpellData(_E).currentCd >= 3 and lastE+350< GetTickCount()  then
		Control.CastSpell(HK_W)
		end
	
    end
	    if EnemyLoaded == false then
        local CountEnemy = 0
        for i, enemy in pairs(EnemyHeroes) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
    end
  
    self:AutoQ()
end



  -- self.Q = {Type = _G.SPELLTYPE_CIRCLE, Delay = 0.8, Radius = 150, Range = 900, Speed = math.huge, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}}
			-- local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_LINE, Delay = self.Q3.delay, Radius = 50, Range = 1000, Speed = 1500, Collision = false})
				  -- QPrediction:GetPrediction(target, myHero)
			-- if QPrediction:CanHit(self.tyMenu.Pred.PredQ3:Value()+1) then
				-- Control.CastSpell(HK_Q, QPrediction.CastPosition)

function Zilean:CastQ(target)

    if not Ready(_Q) and lastQ +350 < GetTickCount() 
    and Ready(_W) and lastW +250 < GetTickCount() and orbwalker:CanMove() then
       local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.8, Radius = 140, Range = 900, Speed = MathHuge, Collision = true, CollisionTypes={GGPrediction.COLLISION_YASUOWALL}})
	   local hasBuff , duration = self:HasQBuff(target)
	   QPrediction:GetPrediction(target, myHero)
	   self:mundoEcast(target)
        if QPrediction:CanHit(1) and hasBuff and duration >= 0.8 then
			if Ready(_E) and (self.tyMenu.Combo.UseE2:Value() or self.tyMenu.Combo.UseE:Value()) then
				if  GetDistanceSquared(target.pos, myHero.pos) <= (550+myHero.boundingRadius + target.boundingRadius)^2 then
					Control.CastSpell(HK_E,target)
				elseif ((myHero.mana / myHero.maxMana)>0.75 or myHero.levelData.lvl>=6 )and self.tyMenu.Combo.UseEflee:Value() then
                Control.KeyDown(18)
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                Control.KeyUp(18)
				end
			end
			Control.CastSpell(HK_W)
           -- Control.CastSpell(HK_Q, QPrediction.CastPosition)
            --print("cast WQ "..GetTickCount())
          --  lastQ = GetTickCount()
            lastW = GetTickCount()
			
        end
    end 
	
	if Ready(_Q) and lastQ + 350 < GetTickCount() and lastm + 700 < GetTickCount()  and orbwalker:CanMove() and (( myHero:GetSpellData(_W).currentCd >= 5 or myHero:GetSpellData(_W).currentCd <= 2.5) or (target.health / target.maxHealth)<0.24) and not cantkill(target,false,true,false)  then
       local QPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.8, Radius = 140, Range = 900, Speed = MathHuge, Collision = true, CollisionTypes={GGPrediction.COLLISION_YASUOWALL}})
	   QPrediction:GetPrediction(target, myHero)
        if QPrediction:CanHit(1+1) then
            Control.CastSpell(HK_Q, QPrediction.CastPosition)
            --print("cast Q "..GetTickCount())
            lastQ = GetTickCount()
        end
    end	
end

local function isImmobil(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 11 or buff.type == 5 or buff.type == 8 or buff.type == 12 or buff.type == 22 or buff.type == 23 or buff.type == 25 or buff.type == 30 or buff.type == 35 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false
end

function Zilean:Combo()
    -- local targetList = {}
    -- local target

    -- for i = 1, #Enemys do
        -- local enemy = Enemys[i]
        -- local heroName = enemy.charName
        -- if self.tyMenu.Combo.useon[heroName] and self.tyMenu.Combo.useon[heroName]:Value() then
            -- targetList[#targetList + 1] = enemy
        -- end
    -- end

    -- target = self:GetTarget(targetList, 900)

    -- if target and IsValid(target) and self.tyMenu.Combo.UseQ:Value() then
	
	target4=TargetSelector:GetTarget(1200)	
	if target4 and (not Ready(_E) or isImmobil(target4) or not self.tyMenu.Combo.Useqslow:Value())  then
        self:CastQ(target4)
	end
	if self.tyMenu.Combo.Useqslow:Value() and target4 and (not Ready(_Q) or myHero:GetSpellData(_W).currentCd >= 3) then
		self:CastQ(target4)
	end

end

function Zilean:Harass()
    local targetList = {}
    local target

    for i = 1, #Enemys do
        local enemy = Enemys[i]
        local heroName = enemy.charName
        if self.tyMenu.Harass.useon[heroName] and self.tyMenu.Harass.useon[heroName]:Value() then
            targetList[#targetList + 1] = enemy
        end
    end

    target = self:GetTarget(targetList, self.Q.Range)

    if target and IsValid(target) and self.tyMenu.Harass.UseQ:Value() then
        self:CastQ(target)
    end
end

function Zilean:AutoQ()
    for i = 1, #Enemys do
        local enemy = Enemys[i]
        if self.tyMenu.Auto.UseQ:Value() and GetDistanceSquared(enemy.pos, myHero.pos) < 900*900 then
            local hasBuff , duration = self:HasQBuff(enemy)
            if hasBuff and duration >= 0.8 then
                self:CastQ(enemy)
            end
        end
    end
end


function Zilean:UltCalcs(unit,ally)
    local Rdmg = getdmg("R", ally, unit)
    local Qdmg = getdmg("Q", ally, unit)
    --local Qdmg = getdmg("Q", unit, myHero)
    local Wdmg = getdmg("W", ally, unit)
    local AAdmg = getdmg("AA", unit) 
    --PrintChat(Qdmg)
    --PrintChat(unit.activeSpell.name)
    --PrintChat(unit.activeSpellSlot)
    --PrintChat("Break------")
    --PrintChat(unit:GetSpellData(_Q).name)
    local CheckDmg = 0
    if unit.activeSpell.target == ally.handle and unit.activeSpell.isChanneling == false and unit.totalDamage and unit.critChance then
        --PrintChat(unit.activeSpell.name)
        --PrintChat(unit.totalDamage)
        --PrintChat(myHero.critChance)
        CheckDmg = unit.totalDamage + (unit.totalDamage*unit.critChance)
    else
        --PrintChat("Spell")
        if unit.activeSpell.name == unit:GetSpellData(_Q).name and Qdmg then
            --PrintChat(Qdmg)
            CheckDmg = Qdmg
        elseif unit.activeSpell.name == unit:GetSpellData(_W).name and Wdmg then
            --PrintChat("W")
            CheckDmg = Wdmg
        elseif unit.activeSpell.name == unit:GetSpellData(_E).name and Edmg then
            --PrintChat("E")
            CheckDmg = Edmg
        elseif unit.activeSpell.name == unit:GetSpellData(_R).name and Rdmg then
            --PrintChat("R")
            CheckDmg = Rdmg
        end
    end
   -- print(CheckDmg)
	-- print("CheckDmg")
    return CheckDmg * 1.1
    --[[

    check if spell is auto attack, if it is, get the target, if its us, check speed and sutff, add it to the list with an end time, the damage and so on.
    
    .isChanneling = spell
    not .isChanneling = AA    

    if it's a spell however
    Find spell name, check if that slot has damage .activeSpellSlot might work, would be super easy then.
    if it has damage, check if it has a target, if it does, and the target is myhero, get the speed yadayada, damage, add it to the table.
        if it doesn't have a target, get it's end spot, speed and target spot is close to myhero, and so on, add it to the table. also try .endtime
        .spellWasCast might help if it works, check when to add the spell to the list just the once.

        another function to clear the list of any spell that has expired.

        Add up all the damage of all the spells in the list, this is the total incoming damage to my hero

    ]]
end

function Zilean:AutoR()
    if not Ready(_R) or lastR + 150 > GetTickCount() then return end

    for i = 1, #Allys do
        local ally = Allys[i]
        if self.tyMenu.Auto.Ron[ally.charName] and self.tyMenu.Auto.Ron[ally.charName]:Value() then
            if IsValid(ally) and GetDistanceSquared(ally.pos, myHero.pos) < self.R.Range ^ 2 then
			    for i, enemy in pairs(EnemyHeroes) do
				if GetDistanceSquared(enemy.pos, ally.pos) < 700 ^ 2 then
					local IncDamage = self:UltCalcs(enemy,ally)
					if (ally.health / ally.maxHealth * 100 < self.tyMenu.Auto.Rhp:Value() and self:GetEnemyAround(ally) > 0 ) or (IncDamage> ally.health and ally.health / ally.maxHealth<0.5)  then
						if ally==myHero then
							Control.KeyDown(18)
							Control.KeyDown(HK_R)
							Control.KeyUp(HK_R)
							Control.KeyUp(18)
						else
						Control.CastSpell(HK_R, ally.pos)
						print("low Health cast R "..ally.charName)
						lastR = GetTickCount()
						return
						end
					end
				end
				end
            end
        end  
    end
		

end


function Zilean:GetTarget(list, range)
    local targetList = {}

    for i = 1, #list do
        local hero = list[i]
        if GetDistanceSquared(hero.pos, myHero.pos) < range * range then
            targetList[#targetList + 1] = hero
        end
    end

    return TargetSelector:GetTarget(targetList)
end

function Zilean:HasQBuff(unit)
    local name = "ZileanQEnemyBomb"
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name == name and buff.duration >= 0.8 then
            return true, buff.duration
        end
		if buff and buff.count > 0 and buff.name == "ZileanQAllyBomb" and buff.duration >= 0.8 then
            return true, buff.duration
        end
    end
    return false
end

function Zilean:GetEnemyAround(ally)
    local counter = 0
    for i = 1, #Enemys do
        local enemy = Enemys[i]
        if IsValid(enemy) and GetDistanceSquared(ally.pos, enemy.pos) < 600^2 then
            counter = counter + 1
        end
    end
    return counter
end

Zilean()

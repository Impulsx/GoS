-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyCassio.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyCassio.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyCassio.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyCassio.version"
        }
    }
    
    local function AutoUpdate()
        
        local function DownloadFile(url, path, fileName)
            DownloadFileAsync(url, path .. fileName, function() end)
            while not FileExist(path .. fileName) do end
        end
        
        local function ReadFile(path, fileName)
            local file = io.open(path .. fileName, "r")
            local result = file:read()
            file:close()
            return result
        end
        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        local textPos = myHero.pos:To2D()
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print("New PussyCassio Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end
	
	local Orb = 3
	local TEAM_ALLY = myHero.team
	local TEAM_JUNGLE = 300
	local TEAM_ENEMY = 300 - TEAM_ALLY

	local function GetDistanceSqr(p1, p2)
	    local dx = p1.x - p2.x
	    local dz = p1.z - p2.z
	    return (dx * dx + dz * dz)
	end

	local sqrt = math.sqrt  
	local function GetDistance(p1, p2)
		return sqrt(GetDistanceSqr(p1, p2))
	end

	local function GetDistance2D(p1,p2)
		return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
	end

	local function HasPoison(unit)
		for i = 0, unit.buffCount do 
		local buff = unit:GetBuff(i)
			if buff.type == 23 and Game.Timer() < buff.expireTime - 0.141  then
				return true
			end
		end
		return false
	end

	local function NoPotion()
		for i = 0, 63 do 
		local buff = myHero:GetBuff(i)
			if buff.type == 13 and Game.Timer() < buff.expireTime then 
				return false
			end
		end
		return true
	end

	local function Ready(spell)
		return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
	end

	local function GetTarget(range) 
	local target = nil 
		if Orb == 1 then
			target = EOW:GetTarget(range)
		elseif Orb == 2 then 
			target = _G.SDK.TargetSelector:GetTarget(range)
		elseif Orb == 3 then
			target = GOS:GetTarget(range)
		end
		--for i = 1, Game.HeroCount() do 
		--	local t = Game.Hero(i)
		--	local range2 = range * range 
		--	if t and t.team == TEAM_ENEMY and t.dead == false and GetDistanceSqr(myHero.pos, t.pos) <= range2 and t.isTargetable and t.isImmortal == false and t.visible and HasPoison(t) then
		--		target = t 
		--	end
		--end
		return target 
	end

	local _EnemyHeroes
	local function GetEnemyHeroes()
		if _EnemyHeroes then return _EnemyHeroes end
		_EnemyHeroes = {}
		for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
			if unit.team == TEAM_ENEMY then
				table.insert(_EnemyHeroes, unit)
			end
		end
		return _EnemyHeroes
	end

	local intToMode = {
   		[0] = "",
   		[1] = "Combo",
   		[2] = "Harass",
   		[3] = "LastHit",
   		[4] = "Clear"
	}

	function GetMode()
		if Orb == 1 then
			return intToMode[EOW.CurrentMode]
		elseif Orb == 2 then
			if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
				return "Combo"
			elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
				return "Harass"	
			elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
				return "Clear"
			elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
				return "LastHit"
			elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
				return "Flee"
			end
		else
			return GOS.GetMode()
		end
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

	local function HasTear()
		for i = ITEM_1, ITEM_6 do
		local id = myHero:GetItemData(i).itemID
			if id == 3070 or id == 3003 or id == 3004 then
				return true
			end
		end
		return false
	end
	
	local function IsRecalling()
		for i = 1, 63 do
		local buff = myHero:GetBuff(i) 
			if buff.count > 0 and buff.name == "recall" and Game.Timer() < buff.expireTime then
				return true
			end
		end 
		return false
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
	

	local function IsValidTarget(unit, range)
    	return unit and unit.team == TEAM_ENEMY and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false and unit.visible
	end

	local function IsValidCreep(unit, range)
    	return unit and unit.team ~= TEAM_ALLY and unit.dead == false and GetDistanceSqr(myHero.pos, unit.pos) <= (range + myHero.boundingRadius + unit.boundingRadius)^2 and unit.isTargetable and unit.isTargetableToTeam and unit.isImmortal == false and unit.visible
	end

	local function IsImmobileTarget(unit)
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
				return true
			end
		end
		return false	
	end

	local function Block(boolean) 
		if boolean == true then 
			if Orb == 1 then
				EOW:SetAttacks(false)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(false)
			else
				--GOS:BlockAttack(true)
			end
		else
			if Orb == 1 then
				EOW:SetAttacks(true)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(true)
			else
				--GOS:BlockAttack()
			end
		end
	end

	local _OnVision = {}
	function OnVision(unit)
		if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
		if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
		if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
		return _OnVision[unit.networkID]
	end
	Callback.Add("Tick", function() OnVisionF() end)
	local visionTick = GetTickCount()
	function OnVisionF()
		if GetTickCount() - visionTick > 100 then
			for i,v in pairs(GetEnemyHeroes()) do
				OnVision(v)
			end
		end
	end

	local _OnWaypoint = {}
	function OnWaypoint(unit)
		if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
		if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
			_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
				DelayAction(function()
					local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
					local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
					if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
						_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)

					end
				end,0.05)
		end
		return _OnWaypoint[unit.networkID]
	end

	local function GetPred(unit,speed,delay) 
		local speed = speed or math.huge
		local delay = delay or 0.25
		local unitSpeed = unit.ms
		if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
		if OnVision(unit).state == false then
			local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
			local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		else
			if unitSpeed > unit.ms then
				local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
				if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
				return predPos
			elseif IsImmobileTarget(unit) then
				return unit.pos
			else
				return unit:GetPrediction(speed,delay)
			end
		end	
	end

	require "2DGeometry"
	require "DamageLib"

	class "Cassiopeia"
	
	function Cassiopeia:LoadSpells()
	R = {Range = 825, Width = 200, Delay = 1.25, Speed = math.huge, Collision = false, aoe = false, Type = "circular"}

end

	local AA = false
	local QRange = 850 * 850
	local MaxWRange = 800 * 800
	local MinWRange = 420 * 420
	local WMinCRange = 500 
	local WMaxCRange = 800 	
	local ERange = 700 * 700
	local RRange = 825 * 825

	function Cassiopeia:__init()
		Callback.Add("Tick", function() self:Tick() end)
		Callback.Add("Draw", function() self:Draw() end)
		Cass = MenuElement({type = MENU, id = "Cass", name = "PussyCassio"})
		self:Menu()
		self:LoadSpells()
		if _G.EOWLoaded then
			Orb = 1
		elseif _G.SDK and _G.SDK.Orbwalker then
			Orb = 2
		end
		print("PussyCassio Loaded")
	end

	function Cassiopeia:Menu()
		Cass:MenuElement({name = " ", drop = {"General Settings"}})
		
		Cass:MenuElement({type = MENU, id = "c", name = "Combo"})
		Cass.c:MenuElement({id = "Block", name = "Block AA in Combo [?]", value = true, tooltip = "Reload Script after changing"})
		Cass.c:MenuElement({id = "Q", name = "Use Q", value = true})
		Cass.c:MenuElement({id = "W", name = "Use W", value = true})
		Cass.c:MenuElement({id = "E", name = "Use E", value = true})
		Cass.c:MenuElement({id = "R", name = "Use R ", value = true})
		Cass.c:MenuElement({id = "Count", name = "Min Amount to hit R", value = 2, min = 1, max = 5, step = 1})
		Cass.c:MenuElement({id = "P", name = "Use Panic R", value = true})
		Cass.c:MenuElement({id = "HP", name = "Min HP % to Panic R", value = 20, min = 0, max = 100, step = 1})
		
		Cass:MenuElement({type = MENU, id = "h", name = "Harass"})
		Cass.h:MenuElement({id = "Q", name = "UseQ", value = true})
		Cass.h:MenuElement({id = "E", name = "UseE only poisend", value = true})		
		
		Cass:MenuElement({type = MENU, id = "w", name = "Clear"})
		Cass.w:MenuElement({id = "Q", name = "Use Q", value = true})
		Cass.w:MenuElement({id = "W", name = "Use W ( next Update!! )", value = true})
		Cass.w:MenuElement({id = "Count", name = "Min Minions to hit W", value = 3, min = 1, max = 5, step = 1})		
		Cass.w:MenuElement({id = "E", name = "Auto E Toggle Key", key = 84, toggle = true})
		
		Cass:MenuElement({type = MENU, id = "m", name = "Mana Manager"})
		Cass.m:MenuElement({name = " ", drop = {"Harass [%]"}})
		Cass.m:MenuElement({id = "Q", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "W", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "E", name = "E Mana", value = 5, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "R", name = "R Mana", value = 5, min = 0, max = 100, step = 1})		
		
		Cass.m:MenuElement({name = " ", drop = {"Clear [%]"}})
		Cass.m:MenuElement({id = "QW", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "WW", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "EW", name = "E Mana", value = 10, min = 0, max = 100, step = 1})
		
		Cass:MenuElement({name = " ", drop = {"Advanced Settings"}})
		Cass:MenuElement({type = MENU, id = "a", name = "Activator"})
		Cass.a:MenuElement({type = MENU, id = "Hextech", name = "hextech GLP-800"})
		Cass.a.Hextech:MenuElement({id = "ON", name = "Enabled in Combo", value = true})
		Cass.a.Hextech:MenuElement({id = "HP", name = "Min Target HP %", value = 100, min = 0, max = 100, step = 1})		
		Cass.a:MenuElement({type = MENU, id = "Zhonyas", name = "Zhonya's Hourglass"})
		Cass.a.Zhonyas:MenuElement({id = "ON", name = "Enabled", value = true})
		Cass.a.Zhonyas:MenuElement({id = "HP", name = "HP % Zhonya's", value = 15, min = 0, max = 100, step = 1})
		Cass.a:MenuElement({type = MENU, id = "Seraphs", name = "Seraph's Embrace"})
		Cass.a.Seraphs:MenuElement({id = "ON", name = "Enabled", value = true})
		Cass.a.Seraphs:MenuElement({id = "HP", name = "HP % Seraph's", value = 15, min = 0, max = 100, step = 1})

		Cass:MenuElement({type = MENU, id = "d", name = "Drawings"})
		Cass.d:MenuElement({id = "ON", name = "Enable Drawings", value = true})
		Cass.d:MenuElement({id = "Text", name = "Draw Text", value = true})
		Cass.d:MenuElement({id = "Lines", name = "Draw Lines", value = true})
		Cass.d:MenuElement({type = MENU, id = "Q", name = "Q"})
		Cass.d.Q:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "W", name = "W"})
		Cass.d.W:MenuElement({id = "ON", name = "Enabled", value = false})       
		Cass.d.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "E", name = "E"})
		Cass.d.E:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "R", name = "R"})
		Cass.d.R:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})				
		if Cass.c.Block:Value() then
			AA = true 
		end
	end

	function Cassiopeia:Edmg(unit)
		local base = 48 + 4 * myHero.levelData.lvl + 0.1 * myHero.ap
		return CalcMagicalDamage(myHero,unit, base)
	end

	function Cassiopeia:PEdmg(unit)
		local base = 48 + 4 * myHero.levelData.lvl + 0.1 * myHero.ap
		local bonus = ({10, 30, 50, 70, 90})[myHero:GetSpellData(_E).level] + 0.60 * myHero.ap
		return CalcMagicalDamage(myHero,unit, base + bonus)
	end

	local abs = math.abs 
	local deg = math.deg 
	local acos = math.acos 
	function Cassiopeia:IsFacing(unit)
	    local V = Vector((unit.pos - myHero.pos))
	    local D = Vector(unit.dir)
	    local Angle = 180 - deg(acos(V*D/(V:Len()*D:Len())))
	    if abs(Angle) < 80 then 
	        return true  
	    end
	    return false
	end

	function Cassiopeia:GetAngle(v1, v2)
		local vec1 = v1:Len()
		local vec2 = v2:Len()
		local Angle = abs(deg(acos((v1*v2)/(vec1*vec2))))
		if Angle < 90 then
			return true
		end
		return false
	end

	function Cassiopeia:Tick()
		if myHero.dead == false and Game.IsChatOpen() == false then
		local Mode = GetMode()
			if Mode == "Combo" then
				self:BlockAA()
				self:Check(Mode)
				self:Combo()
			elseif Mode == "Harass" then
				self:Check(Mode)
				self:Harass()
			elseif Mode == "Clear" then
				self:Check(Mode)
				self:Clear()
			end
			if Cass.w.E:Value() and Mode ~= "Combo" then
				self:AutoE()
			end
			self:UnBlockAA(Mode)
			self:Activator(Mode)
		end
	end


	function Cassiopeia:BlockAA()
		if AA == true then
			if Orb == 1 then
				EOW:SetAttacks(false)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(false)
			else
				--GOS:BlockAttack(true)
			end
		end
	end

	function Cassiopeia:UnBlockAA(Mode)
		if Mode ~= "Combo" and AA == false then 
			if Orb == 1 then 
				EOW:SetAttacks(true)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(true)
			else
			--	GOS:BlockAttack()
			end
		end
	end

	function Cassiopeia:Check(Mode)
		if AA == false or Mode ~= "Combo" then
		local activeSpell = myHero.activeSpell
		local cd = myHero:GetSpellData(_E).currentCd
			if activeSpell.windup > cd then
				if Orb == 1 then
					EOW:SetAttacks(false)
				elseif Orb == 2 then
					_G.SDK.Orbwalker:SetAttack(false)
				else
				--	GOS:BlockAttack(true)
				end
			else
				if Orb == 1 then 
					EOW:SetAttacks(true)
				elseif Orb == 2 then
					_G.SDK.Orbwalker:SetAttack(true)
				else
				--	GOS:BlockAttack()
				end
			end
		end
	end

	function Cassiopeia:CastW(key, pos)
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

	function Cassiopeia:Activator(Mode)
		if Cass.a.Zhonyas.ON:Value() then
		local Zhonyas = GetItemSlot(myHero, 3157)
			if Zhonyas >= 1 and Ready(Zhonyas) then 
				if EnemyAround() and myHero.health/myHero.maxHealth < Cass.a.Zhonyas.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Zhonyas])
				end
			end
		end
		if Cass.a.Seraphs.ON:Value() then
		local Seraphs = GetItemSlot(myHero, 3040)
			if Seraphs >= 1 and Ready(Seraphs) then
				if EnemyAround() and myHero.health/myHero.maxHealth < Cass.a.Seraphs.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Seraphs])
				end
			end
		end
		local target = GetTarget(800)
		if target == nil then return end
		if Mode == "Combo" then
			if Cass.a.Hextech.ON:Value() then
			local Hextech = GetItemSlot(myHero, 3030)
				if Hextech >= 1 and Ready(Hextech) and target  and target.health/target.maxHealth < Cass.a.Hextech.HP:Value()/100 then
					Control.CastSpell(ItemHotKey[Hextech], target)
				end
			end

		end
	end

function EnemyInRange(range)
	local count = 0
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

function Cassiopeia:IsFacing(target)
local target = GetTarget(RRange)
if target == nil then return end
	local dotProduct = myHero.dir.x*target.dir.x + myHero.dir.z*target.dir.z
	if (dotProduct < 0) then
		if (myHero.dir.x > 0 and myHero.dir.z > 0) then
			return ((target.pos.x - myHero.pos.x > 0) and (target.pos.z - myHero.pos.z > 0))
		elseif (myHero.dir.x < 0 and myHero.dir.z < 0) then
			return ((target.pos.x - myHero.pos.x < 0) and (target.pos.z - myHero.pos.z < 0))
		elseif (myHero.dir.x > 0 and myHero.dir.z < 0) then
			return ((target.pos.x - myHero.pos.x > 0) and (target.pos.z - myHero.pos.z < 0))
		elseif (myHero.dir.x < 0 and myHero.dir.z > 0) then
			return ((target.pos.x - myHero.pos.x < 0) and (target.pos.z - myHero.pos.z > 0))
		end
	end
	return false
end

function EnemiesNear(pos,range)
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if IsValidTarget(hero,range + hero.boundingRadius) and hero.isEnemy and not hero.dead then
			N = N + 1
		end
	end
	return N	
end		

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in pairs(objects) do
        local hit = CountObjectsNearPos(object.pos, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object.pos
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in pairs(objects) do
        if GetDistanceSqr(pos, object.pos) <= radius * radius then
            n = n + 1
        end
    end
    return n
end	

	function Cassiopeia:RLogic()
		local RTarget = nil 
		local Most = 0
		local Cast = false
			local InFace = {}
			for i = 1, Game.HeroCount() do
			local Hero = Game.Hero(i)
				if IsValidTarget(Hero, 850) then 
					--local LS = LineSegment(myHero.pos, Hero.pos)
					--LS:__draw()
					InFace[#InFace + 1] = Hero
				end
			end
			local IsFace = {}
			for r = 1, #InFace do 
			local FHero = InFace[r]
				if self:IsFacing(FHero) then
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
						if self:GetAngle(A,B) and GetDistanceSqr(MainLine.Host.pos, myHero.pos) < RRange and HasPoison(CloseLine.Host) then 
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
			if Most >= Cass.c.Count:Value() or Most == Number then
				Cast = true 
			end
		--	print(Most)
		--	if RTarget then
		--		LSS = Circle(Point(RTarget), 50)
		--		LSS:__draw()
		--	end
		return RTarget, Cast
	end


	function Cassiopeia:Combo()
		local activeSpell = myHero.activeSpell
   		if activeSpell.valid and activeSpell.spellWasCast == false then
   			return
   		end
		local target = GetTarget(950)
		if target == nil then 
			return
		end
		local QValue = Cass.c.Q:Value()
		local WValue = Cass.c.W:Value()
		local RValue = Cass.c.R:Value()
		local Dist = GetDistanceSqr(myHero.pos, target.pos)
		local QData = myHero:GetSpellData(_Q) 
		local QWReady = Ready(_Q) 
		local RTarget, ShouldCast = self:RLogic()
		if Cass.c.W:Value() and Ready(_W)  then 
			if Dist < MaxWRange and Dist > MinWRange then
			local Pos = GetPred(target, 1500, 0.25 + Game.Latency()/1000)
				if GetDistanceSqr(Pos, myHero.pos) < MaxWRange then 
					self:CastW(HK_W, Pos)
				end
			end
		end
		if QValue and Ready(_Q) then 
			if Dist < QRange then 
			local Pos = GetPred(target, 20000, 0.44 + Game.Latency()/1000)
				if GetDistanceSqr(Pos, myHero.pos) < QRange then
					Control.CastSpell(HK_Q, Pos)
				end
			end
		end
		if Cass.c.E:Value() and Ready(_E) then 
			if Dist < ERange then
				Control.CastSpell(HK_E, target)
			end
		end		
		local WData = myHero:GetSpellData(_W) 
		local WCheck = Ready(_W)
		local Panic = Cass.c.P:Value() and myHero.health/myHero.maxHealth < Cass.c.HP:Value()/100 
		if Cass.c.R:Value() and Ready(_R) and (HasPoison(target) or Panic) and ((WCheck == false or (WCheck and (Game.Timer() + WData.cd) - WData.castTime > 2)) or WValue == false) then
			if Panic then
				if Dist < RRange and self:PEdmg(target) < target.health then
					if RTarget then
						Control.CastSpell(HK_R, RTarget)
					else
						Control.CastSpell(HK_R, target)
					end
				end
			end
			for i = 1, Game.HeroCount() do
			local hero = Game.Hero(i)
			if Cass.c.R:Value() and Ready(_R) and hero.isEnemy and not hero.dead then
				if EnemyInRange(RRange) then 
					if EnemiesNear(myHero.pos,800) >= Cass.c.Count:Value() and self:IsFacing() then
					Control.SetCursorPos(hero)
					Control.CastSpell(HK_R, hero)
					end
				end 
			end
			end

	end
	end
	

	function Cassiopeia:Harass()
		local activeSpell = myHero.activeSpell
   		if activeSpell.valid and activeSpell.spellWasCast == false then
   			return
   		end
		local target = GetTarget(950)
		if target == nil then 
			return
		end
		local QValue = Cass.h.Q:Value()
		local Dist = GetDistanceSqr(myHero.pos, target.pos)
		if QValue and Ready(_Q) and myHero.mana/myHero.maxMana > Cass.m.Q:Value()/100 then 
			if Dist < QRange then 
			local Pos = GetPred(target, 20000, 0.44 + Game.Latency()/1000)
				if GetDistanceSqr(Pos, myHero.pos) < QRange then
					Control.CastSpell(HK_Q, Pos)
				end
			end
		end

		if Cass.h.E:Value() and Ready(_E) and (HasPoison(target) or self:Edmg(target) * 2  > target.health) and myHero.mana/myHero.maxMana > Cass.m.E:Value()/100 then 
			if Dist < ERange then
				Control.CastSpell(HK_E, target)
			end
		end
	end
	
	

	function Cassiopeia:Clear()
		for i = 1, Game.MinionCount() do 
		local Minion = Game.Minion(i)		
		local QValue = Cass.w.Q:Value()
		local WValue = Cass.w.W:Value()				
			if Ready(_Q) and IsRecalling() == false and QValue and myHero.mana/myHero.maxMana > Cass.m.QW:Value()/100 then
				if IsValidCreep(Minion, 850) and GetDistanceSqr(Minion.pos, myHero.pos) < QRange then 
				local Pos = GetPred(Minion, 20000, 0.44 + Game.Latency()/1000)
					Control.CastSpell(HK_Q, Pos)
				end
			end
				
			--if Ready(_W) and IsRecalling() == false and WValue and myHero.mana/myHero.maxMana > Cass.m.WW:Value()/100 then
			--local BestPos, BestHit = GetBestCircularFarmPosition(50,112 + 80, Minion)	
				--if IsValidCreep(Minion, 800) and BestHit >= Cass.w.Count:Value() then 
					--Control.CastSpell(HK_W,BestPos)
													
						
						
					
				end
			end
		--end
	--end
	
	
	function Cassiopeia:AutoE()
		if Ready(_E) and IsRecalling() == false and myHero.mana/myHero.maxMana > Cass.m.EW:Value()/100 then
			for i = 1, Game.MinionCount() do 
			local Minion = Game.Minion(i) 
				if IsValidCreep(Minion, 690) and GetDistanceSqr(Minion.pos, myHero.pos) < ERange then 
					if HasPoison(Minion) and self:PEdmg(Minion) > Minion.health then 
						Block(true)
						Control.CastSpell(HK_E, Minion)
						break
					elseif self:Edmg(Minion) > Minion.health then 
						Block(true)
						Control.CastSpell(HK_E, Minion)
						break
					end
				end
			end
		end
		Block(false)
	end
					

	function Cassiopeia:Draw()
		if myHero.dead == false and Cass.d.ON:Value() then
			local textPos = myHero.pos:To2D()
			if Cass.d.Lines:Value() then
				local InFace = {}
				for i = 1, Game.HeroCount() do
				local Hero = Game.Hero(i)
					if IsValidTarget(Hero, 850) and self:IsFacing(Hero) then 
						local Vectori = Vector(myHero.pos - Hero.pos)
						local LS = LineSegment(myHero.pos, Hero.pos)
						LS:__draw()
					end
				end
				local RTarget = self:RLogic()
				if RTarget then
					LSS = Circle(Point(RTarget), RTarget.boundingRadius)
					LSS:__draw()
				end
			end
			if Cass.d.Text:Value() then 
				if Cass.w.E:Value() then 
					Draw.Text("Auto E ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
				else
					Draw.Text("Auto E OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
				end
			end
			if Cass.d.Q.ON:Value() then
				Draw.Circle(myHero.pos, 850, Cass.d.Q.Width:Value(), Cass.d.Q.Color:Value())
			end
			if Cass.d.W.ON:Value() then
				Draw.Circle(myHero.pos, 340, Cass.d.W.Width:Value(), Cass.d.W.Color:Value())
				Draw.Circle(myHero.pos, 960, Cass.d.W.Width:Value(), Cass.d.W.Color:Value())
			end
			if Cass.d.E.ON:Value() then
				Draw.Circle(myHero.pos, 750, Cass.d.E.Width:Value(), Cass.d.E.Color:Value())
			end	
			if Cass.d.R.ON:Value() then
				Draw.Circle(myHero.pos, 750, Cass.d.E.Width:Value(), Cass.d.E.Color:Value())
			end			
		end
	end

	function OnLoad()
 		if _G[myHero.charName] and myHero.charName == "Cassiopeia" then 
 			_G[myHero.charName]()

		end
	end

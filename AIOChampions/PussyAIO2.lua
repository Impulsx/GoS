local NextSpellCast = Game.Timer()
local _allyHealthPercentage = {}
local _allyHealthUpdateRate = 1
local Heroes = {"Draven" ,"Nami","Brand", "Zilean", "Soraka", "Lux", "Blitzcrank","Lulu", "MissFortune","Karthus", "Illaoi", "Taliyah", "Kalista",  "Azir", "Thresh", "AurelionSol"}
local _adcHeroes = { "Draven", "Kalista", "MissFortune"}
if not table.contains(Heroes, myHero.charName) then print("Hero not supported: " .. myHero.charName) return end


-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyAIO2.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyAIO.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyAIO2.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyAIO.version"
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
            print("New PussyAIO Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end


local _atan = math.atan2
local _pi = math.pi
local _min = math.min
local _abs = math.abs
local _sqrt = math.sqrt
local _huge = math.huge
local _insert = table.insert
local _sort = table.sort
local _find = string.find

local LocalDrawLine					= Draw.Line;
local LocalDrawColor				= Draw.Color;
local LocalDrawCircle				= Draw.Circle;
local LocalDrawText					= Draw.Text;
local LocalControlIsKeyDown			= Control.IsKeyDown;
local LocalControlMouseEvent		= Control.mouse_event;
local LocalControlSetCursorPos		= Control.SetCursorPos;
local LocalControlKeyUp				= Control.KeyUp;
local LocalControlKeyDown			= Control.KeyDown;
local LocalGameCanUseSpell			= Game.CanUseSpell;
local LocalGameLatency				= Game.Latency;
local LocalGameTimer				= Game.Timer;
local LocalGameHeroCount 			= Game.HeroCount;
local LocalGameHero 				= Game.Hero;
local LocalGameMinionCount 			= Game.MinionCount;
local LocalGameMinion 				= Game.Minion;
local LocalGameTurretCount 			= Game.TurretCount;
local LocalGameTurret 				= Game.Turret;
local LocalGameWardCount 			= Game.WardCount;
local LocalGameWard 				= Game.Ward;
local LocalGameObjectCount 			= Game.ObjectCount;
local LocalGameObject				= Game.Object;
local LocalGameMissileCount 		= Game.MissileCount;
local LocalGameMissile				= Game.Missile;
local LocalGameParticleCount 		= Game.ParticleCount;
local LocalGameParticle				= Game.Particle;
local LocalGameIsChatOpen			= Game.IsChatOpen;
local LocalGameIsOnTop				= Game.IsOnTop;

local BotTick
local HPredTick
local CleanseTick

local _nextVectorCast = Game.Timer()
function VectorCast(startPos, endPos, hotkey)
	if NextSpellCast > Game.Timer() then return end	
	if _nextVectorCast > Game.Timer() then return end
	_nextVectorCast = Game.Timer() + 2
	NextSpellCast = Game.Timer() + .25
	local cPos = cursorPos
	Control.SetCursorPos(startPos)	
	DelayAction(function()Control.KeyDown(hotkey) end,.05)
	DelayAction(function()Control.SetCursorPos(endPos) end,.1)
	DelayAction(function()Control.KeyUp(hotkey) end,.15) 
end


Callback.Add("Tick", function()
	if BotTick then
		BotTick()
	end
	
	if HPredTick then
		HPredTick()
	end
	
	if CleanseTick then
		CleanseTick()
	end
end)


Callback.Add("Load",
function()	

	AutoUtil()
	--Set up the initial menu for drawing and reaction time
	Menu = MenuElement({type = MENU, id = myHero.charName, name = "PussyKate "..myHero.charName})	
	Menu:MenuElement({id = "General", name = "General", type = MENU})
	Menu.General:MenuElement({id = "DrawQ", name = "Draw Q Range", value = false})
	Menu.General:MenuElement({id = "DrawW", name = "Draw W Range", value = false})
	Menu.General:MenuElement({id = "DrawE", name = "Draw E Range", value = false})
	Menu.General:MenuElement({id = "DrawR", name = "Draw R Range", value = false})
	Menu.General:MenuElement({id = "AutoInTurret", name = "Auto Cast While In Enemy Turret Range", value = true})
	Menu.General:MenuElement({id = "SkillFrequency", name = "Skill Frequency", value = .3, min = .1, max = 1, step = .1})
	Menu.General:MenuElement({id = "ReactionTime", name = "Reaction Time", value = .5, min = .1, max = 1, step = .1})
	Menu.General:MenuElement({id = "Delay", name = "Throttle Processing", value = false})
		
	Menu:MenuElement({id = "Skills", name = "Skills", type = MENU})
	if AutoUtil:GetCleanse() then
		Menu.Skills:MenuElement({id = "Cleanse", name = "Cleanse", type = MENU})	
		Menu.Skills.Cleanse:MenuElement({id = "CC", name = "CC Settings", type = MENU})	
		Menu.Skills.Cleanse.CC:MenuElement({id = "Suppression", name = "Suppression", value = true, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Stun", name = "Stun", value = true, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Sleep", name = "Sleep", value = true, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Polymorph", name = "Polymorph", value = true, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Taunt", name = "Taunt", value = true, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Charm", name = "Charm", value = true, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Fear", name = "Fear", value = true, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Blind", name = "Blind", value = false, toggle = true})	
		Menu.Skills.Cleanse.CC:MenuElement({id = "Snare", name = "Snare", value = false, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Slow", name = "Slow", value = false, toggle = true})
		Menu.Skills.Cleanse.CC:MenuElement({id = "Poison", name = "Poison", value = false, toggle = true})
		Menu.Skills.Cleanse:MenuElement({id = "CleanseTime", name = "Cleanse CC If Duration Over X Seconds", value = .5, min = .1, max = 2, step = .1 })
		Menu.Skills.Cleanse:MenuElement({id="Enabled", name="Enabled", value = true})
		Menu.Skills.Cleanse:MenuElement({id="Combo", name="Require Combo", value = true})
		CleanseTick = AutoUtil.AutoCleanse
	end
	Callback.Add("Draw", function() CoreDraw() end)
	Callback.Add("WndMsg",function(Msg, Key) WndMsg(Msg, Key) end)
end)

function CurrentTarget(range, physicalDamage)
	if forcedTarget and HPred:IsInRange(myHero.pos, forcedTarget.pos, range) then return forcedTarget end
	
	if _G.SDK then
		if physicalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
		end
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function IsFarming()
	if _G.SDK and _G.SDK.Orbwalker then		
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			return true
		end
	end
	return false
end

function WndMsg(msg,key)
	if msg == 513 then
		local starget = nil
		local dist = 10000
		for i  = 1,LocalGameHeroCount(i) do
			local enemy = LocalGameHero(i)
			if enemy and enemy.alive and enemy.isEnemy and HPred:GetDistanceSqr(mousePos, enemy.pos) < dist then
				starget = enemy
				dist = HPred:GetDistanceSqr(mousePos, enemy.pos)
			end
		end
		if starget then
			forcedTarget = starget
		end
	end	
end

local isLoaded = false
function TryLoad()
	if Game.Timer() < 30 then return end
	isLoaded = true	
	_G[myHero.charName]()
	
	--Can re-enable this later to turn on teleport/revive/blink tracking
	HPredTick = HPred.Tick
end

--Global draw function to be called from scripts to handle drawing spells and dashes - reduces duplicate code
function CoreDraw()
	
	if not isLoaded then
		TryLoad()
		return
	end
	
	
	--Disabled for now
	if Menu.General.Delay:Value() then return end
	
	
	if Q and Q.Range and KnowsSpell(_Q) and Menu.General.DrawQ:Value() then
		LocalDrawCircle(myHero.pos, Q.Range, LocalDrawColor(150, 255, 0,0))
	end	
	if W and W.Range and KnowsSpell(_W) and Menu.General.DrawW:Value() then
		LocalDrawCircle(myHero.pos, W.Range, LocalDrawColor(150, 0, 255,0))
	end	
	if E and E.Range and  KnowsSpell(_E) and Menu.General.DrawE:Value() then
		LocalDrawCircle(myHero.pos, E.Range, LocalDrawColor(150, 0, 0,255))
	end		
	if R and R.Range and KnowsSpell(_R) and Menu.General.DrawR:Value() then
		LocalDrawCircle(myHero.pos, R.Range, LocalDrawColor(150, 0, 255,255))
	end
	for i = 1, LocalGameHeroCount() do
		local Hero = LocalGameHero(i)    
		if Hero.isEnemy and Hero.pathing.hasMovePath and Hero.pathing.isDashing and Hero.pathing.dashSpeed>500 then
			LocalDrawCircle(Hero:GetPath(1), 40, 20, LocalDrawColor(255, 255, 255, 255))
		end
	end
end

function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
	else
		GOS.BlockMovement = not bool
	end
end

function SetAttack(bool)
	if _G.EOWLoaded then
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockAttack = not bool
	end
end

function IsEvading()
    if ExtLibEvade and ExtLibEvade.Evading then return true end
	return false
end

function IsAttacking()
	if myHero.attackData and myHero.attackData.target and myHero.attackData.state == STATE_WINDUP then return true end
	return false
end

local _nextTick = Game.Timer()
local _tickFrequency = .2

function IsDelaying()
	if _nextTick > Game.Timer() then return true end
	if Menu.General.Delay:Value() then
		_nextTick = Game.Timer() + _tickFrequency
	end
	return false
end

function SpecialCast(key, pos, bypassTiming, isLine)
	if not Menu.Skills.Combo:Value() and not Menu.General.AutoInTurret:Value() and InsideEnemyTurretRange() then return end
	if not bypassTiming and NextSpellCast > Game.Timer() then return end
	if not pos then
		Control.CastSpell(key)
		return
	end
	
	if type(pos) == "userdata" and pos.pos then
		pos = pos.pos
	end
	
	if not pos:ToScreen().onScreen and isLine then			
		pos = myHero.pos + (pos - myHero.pos):Normalized() * 250
	end
	
	if not pos:ToScreen().onScreen then
		return
	end
	
	if _G.SDK and _G.Control then
		_G.Control.CastSpell(key, pos)
	else
		Control.CastSpell(key, pos)
	end
	
	if not bypassTiming then
		NextSpellCast = Menu.General.SkillFrequency:Value() + Game.Timer()
	end
end


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastSpellMM(spell,pos,range,delay)
	local range = range or math.huge
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and HPred:GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
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
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end


local function ReleaseSpell(spell,pos,range,delay)
	local delay = delay or 250
	local ticker = GetTickCount()
	if castSpell.state == 0 and HPred:GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			if not pos:ToScreen().onScreen then
				pos = myHero.pos + (pos - myHero.pos):Normalized() * 250
				Control.SetCursorPos(pos)
				Control.KeyUp(spell)
			else
				Control.SetCursorPos(pos)
				Control.KeyUp(spell)
			end
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

function ImmediateCast(key, pos)
	if _G.SDK and _G.Control then
		_G.Control.CastSpell(key, pos)
	else
		Control.CastSpell(key, pos)
	end
end
 	
function KnowsSpell(spell)
	local spellInfo = myHero:GetSpellData(spell)
	if spellInfo and spellInfo.level > 0 then
		return true
	end
	return false
end
	
function CurrentPctLife(entity)
	local pctLife =  entity.health/entity.maxHealth  * 100
	return pctLife
end

function CurrentPctMana(entity)
	local pctMana =  entity.mana/entity.maxMana * 100
	return pctMana
end

function GetHeroByHandle(handle)	
	for ei = 1, LocalGameHeroCount() do
		local Enemy = LocalGameHero(ei)
		if Enemy.isEnemy and Enemy.handle == handle then
			return Enemy
		end
	end
end
 
function Ready(spellSlot)
	return Game.CanUseSpell(spellSlot) == 0
end

function IsRecalling()
	for i = 1, myHero.buffCount do 
		local buff = myHero:GetBuff(i)
		if buff.name == "recall" and buff.duration > 0 then
			return true
		end
	end
	return false
end


function InsideEnemyTurretRange()
	for i = 1, LocalGameTurretCount() do
		local turret = LocalGameTurret(i)
		if turret then
			local range = (turret.boundingRadius + 750 + myHero.boundingRadius / 2)
			if turret.isEnemy and HPred:IsInRange(turret.pos, myHero.pos, range) then
				return true
			end
		end
	end
end
function UpdateAllyHealth()
	local deltaTick = Game.Timer() - _allyHealthUpdateRate	
	if deltaTick >= 1 then	
		 _allyHealthPercentage = {}
		_allyHealthUpdateRate = Game.Timer()
		for i = 1, LocalGameHeroCount() do
			local hero = LocalGameHero(i)
			if hero ~= nill and hero.isAlly and hero.alive then	
				_allyHealthPercentage[hero.networkID] = CurrentPctLife(hero)				
			end
		end		
	end	
end

	
class "AutoUtil"

function AutoUtil:FindEnemyWithBuff(buffName, range, stackCount)
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)    
		if hero ~= nil and hero.isEnemy and HPred:IsInRange(myHero.pos, hero.pos, range) then
			for bi = 1, hero.buffCount do 
			local Buff = hero:GetBuff(bi)
				if Buff.name == buffName and Buff.duration > 0 and Buff.count >= stackCount then
					return hero
				end
			end
		end
	end
end

function AutoUtil:__init()
	itemKey = {}
	_ccNames = 
	{
		["Cripple"] = 3,
		["Stun"] = 5,
		["Silence"] = 7,
		["Taunt"] = 8,
		["Polymorph"] = 9,
		["Slow"] = 10,
		["Snare"] = 11,
		["Sleep"] = 18,
		["Nearsight"] = 19,
		["Fear"] = 21,
		["Charm"] = 22,
		["Poison"] = 23,
		["Suppression"] = 24,
		["Blind"] = 25,
		-- ["Shred"] = 27,
		["Flee"] = 28,
		-- ["Knockup"] = 29,
		["Airborne"] = 30,
		["Disarm"] = 31
	}
end

function AutoUtil:SupportMenu(Menu)			
	---[ITEM SETTINGS]---
	Menu:MenuElement({id = "Items", name = "Item Settings", type = MENU})	
	
	---[LOCKET SETTINGS]---
	Menu.Items:MenuElement({id = "Locket", name = "Locket", type = MENU})
	Menu.Items.Locket:MenuElement({id = "Threshold", tooltip = "How much damage allies received in last second", name = "Ally Damage Threshold", value = 15, min = 1, max = 80, step = 1 })
	Menu.Items.Locket:MenuElement({id="Count", tooltip = "How many allies must have been injured in last second to cast", name = "Ally Count", value = 3, min = 1, max = 6, step = 1 })
	Menu.Items.Locket:MenuElement({id="Enabled", name="Enabled", value = true})
	
	---[CRUCIBLE SETTINGS]---
	Menu.Items:MenuElement({id = "Crucible", name = "Crucible", type = MENU})
	Menu.Items.Crucible:MenuElement({id = "Targets", name = "Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero.isAlly and myHero ~= hero then			
			if table.contains(_adcHeroes, hero.charName) then
				Menu.Items.Crucible.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
			else
				Menu.Items.Crucible.Targets:MenuElement({id = hero.charName, name = hero.charName, value = false })
			end
		end
	end	
	Menu.Items.Crucible:MenuElement({id = "CC", name = "CC Settings", type = MENU})
	Menu.Items.Crucible.CC:MenuElement({id = "CleanseTime", name = "Cleanse CC If Duration Over (Seconds)", value = .5, min = .1, max = 2, step = .1 })
	Menu.Items.Crucible.CC:MenuElement({id = "Suppression", name = "Suppression", value = true, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Stun", name = "Stun", value = true, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Sleep", name = "Sleep", value = true, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Polymorph", name = "Polymorph", value = true, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Taunt", name = "Taunt", value = true, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Charm", name = "Charm", value = true, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Fear", name = "Fear", value = true, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Blind", name = "Blind", value = false, toggle = true})	
	Menu.Items.Crucible.CC:MenuElement({id = "Snare", name = "Snare", value = false, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Slow", name = "Slow", value = false, toggle = true})
	Menu.Items.Crucible.CC:MenuElement({id = "Poison", name = "Poison", value = false, toggle = true})
	
	---[REDEMPTION SETTINGS]---
	Menu.Items:MenuElement({id = "Redemption", name = "Redemption", type = MENU})
	Menu.Items.Redemption:MenuElement({id = "Targets", name = "Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero.isAlly then		
			Menu.Items.Redemption.Targets:MenuElement({id = hero.charName, name = hero.charName,  tooltip = "How low must this target's HP be to cast redemption", value = 60, min = 10, max = 90, step = 10 })
		end
	end
	Menu.Items.Redemption:MenuElement({id="Duration", name="Prediction Duration", tooltip = "allies must be immobile for at least this long for redemption to cast", value = .5, min = 0, max = 2, step = .25})
	Menu.Items.Redemption:MenuElement({id="Count", name = "Target Count", tooltip = "The total number of allies+enemies that may be hit with redemption in order to cast it.", value = 3, min = 1, max = 10, step = 1})
end

function AutoUtil:CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

function AutoUtil:CalculateMagicDamage(target, damage)			
	local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
	local damageReduction = 100 / ( 100 + targetMR)
	if targetMR < 0 then
		damageReduction = 2 - (100 / (100 - targetMR))
	end		
	damage = damage * damageReduction
	
	return damage
end

function AutoUtil:GetNearestAlly(entity, range)
	local ally = nil
	local distance = _huge
	for i = 1,LocalGameHeroCount()  do
		local hero = LocalGameHero(i)	
		if hero and hero ~= entity and hero.isAlly and HPred:CanTargetALL(hero) then
			local d = HPred:GetDistanceSqr(entity.pos, hero.pos)
			if d < distance and d < range * range then
				distance = d
				ally = hero
			end
		end
	end
	if distance <  range then
		return ally
	end
end

function AutoUtil:NearestEnemy(entity)
	local distance = 999999
	local enemy = nil
	for i = 1,LocalGameHeroCount()  do
		local hero = LocalGameHero(i)	
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

function AutoUtil:CountEnemiesNear(origin, range)
	local count = 0
	for i  = 1,LocalGameHeroCount(i) do
		local enemy = LocalGameHero(i)
		if enemy and  HPred:CanTarget(enemy) and HPred:IsInRange(origin, enemy.pos, range) then
			count = count + 1
		end			
	end
	return count
end

function AutoUtil:GetItemSlot(id)
	for i = 6, 12 do
		if myHero:GetItemData(i).itemID == id then
			return i
		end
	end
	return nil
end

function AutoUtil:IsItemReady(id, ward)
	if not self.itemKey or #self.itemKey == 0 then
		self.itemKey = 
		{
			HK_ITEM_1,
			HK_ITEM_2,
			HK_ITEM_3,
			HK_ITEM_4,
			HK_ITEM_5,
			HK_ITEM_6,
			HK_ITEM_7
		}
	end
	local slot = self:GetItemSlot(id)
	if slot then
		return myHero:GetSpellData(slot).currentCd == 0 and not (ward and myHero:GetSpellData(slot).ammo == 0)
	end
end

function AutoUtil:CastItem(unit, id, range)
	if unit == myHero or HPred:GetDistance(myHero.pos, unit.pos, range) then
		local keyIndex = self:GetItemSlot(id) - 5
		local key = self.itemKey[keyIndex]

		if key then
			if unit ~= myHero then
				Control.CastSpell(key, unit.pos or unit)
			else
				Control.CastSpell(key)
			end
		end
	end
end
function AutoUtil:CastItemMiniMap(pos, id)
	local keyIndex = self:GetItemSlot(id) - 5
	local key = self.itemKey[keyIndex]
	if key then
		CastSpellMM(key, pos)
	end
end

function AutoUtil:HasBuffType(unit, buffType, duration)	
	for i = 1, unit.buffCount do 
		local Buff = unit:GetBuff(i)
		if Buff.duration > duration and Buff.count > 0  and Buff.type == buffType then 
			return true 
		end
	end
	return false
end



function AutoUtil:UseSupportItems()
	--Use crucible on carry if they are CCd
	if AutoUtil:IsItemReady(3222) then
		AutoUtil:AutoCrucible()
	end	
	
	--Use Locket
	if AutoUtil:IsItemReady(3190) then
		AutoUtil:AutoLocket()
	end
	
	--Use Redemption
	if AutoUtil:IsItemReady(3107) then
		AutoUtil:AutoRedemption()
	end
end


function AutoUtil:AutoCrucible()
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and hero.alive and hero ~= myHero then
			if Menu.Items.Crucible.Targets[hero.charName] and Menu.Items.Crucible.Targets[hero.charName]:Value() then
				for ccName, ccType in pairs(_ccNames) do
					if Menu.Items.Crucible.CC[ccName] and Menu.Items.Crucible.CC[ccName]:Value() and self:HasBuffType(hero, ccType, Menu.Items.Crucible.CC.CleanseTime:Value()) then
						AutoUtil:CastItem(hero, 3222, 650)
					end
				end
			end
		end
	end
end

function AutoUtil:AutoLocket()
	local injuredCount = 0
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and _allyHealthPercentage and _allyHealthPercentage[hero.networkID] and hero.isAlly and hero.alive and  HPred:IsInRange(myHero.pos, hero.pos, 700) then			
			local deltaLifeLost = _allyHealthPercentage[hero.networkID] - CurrentPctLife(hero)
			if deltaLifeLost >= Menu.Items.Locket.Threshold:Value() then
				injuredCount = injuredCount + 1
			end
		end
	end	
	if injuredCount >= Menu.Items.Locket.Count:Value() then
		AutoUtil:CastItem(myHero, 3190, _huge)
	end
end

function AutoUtil:AutoRedemption()
	local targetCount = 0
	local aimPos
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and HPred:CanTargetALL(hero) and HPred:IsInRange(myHero.pos, hero.pos, 5500) and Menu.Items.Redemption.Targets[hero.charName] and Menu.Items.Redemption.Targets[hero.charName]:Value() >= CurrentPctLife(hero) then		
			--Check if they are immobile for at least the duration we specified
			if HPred:GetImmobileTime(hero) >= Menu.Items.Redemption.Duration:Value() then
				targetCount = 0
				aimPos = hero.pos
				--we can start adding targets within range!!
				for z = 1, LocalGameHeroCount() do
					local target = LocalGameHero(z)
					if target and HPred:CanTargetALL(target) and HPred:IsInRange(hero.pos, HPred:PredictUnitPosition(target, 2),525) then
						targetCount = targetCount + 1						
					end
				end
				if targetCount >= Menu.Items.Redemption.Count:Value() then
					break
				end
			end
		end
	end	
	if aimPos and targetCount >= Menu.Items.Redemption.Count:Value() then		
		AutoUtil:CastItemMiniMap(aimPos, 3107)
	end
end

function AutoUtil:GetExhaust()
	local exhaustHotkey
	local exhaustData = myHero:GetSpellData(SUMMONER_1)
	if exhaustData.name ~= "SummonerExhaust" then
		exhaustData = myHero:GetSpellData(SUMMONER_2)
		exhaustHotkey = HK_SUMMONER_2
	else 
		exhaustHotkey = HK_SUMMONER_1
	end
	
	if exhaustData.name == "SummonerExhaust" and exhaustData.currentCd == 0 then 
		return exhaustHotkey
	end	
end

function AutoUtil:AutoExhaust()
	local exhaustHotkey = AutoUtil:GetExhaust()	
	if not exhaustHotkey or not Menu.Skills.Exhaust then return end
	
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		--It's an enemy who is within exhaust range and is toggled ON in ExhaustList
		if enemy and enemy.isEnemy and HPred:IsInRange(myHero.pos, enemy.pos, 600 + enemy.boundingRadius) and HPred:CanTarget(enemy, 650) and Menu.Skills.Exhaust.Targets[enemy.charName] and Menu.Skills.Exhaust.Targets[enemy.charName]:Value() then
			for allyIndex = 1, LocalGameHeroCount() do
				local ally = LocalGameHero(allyIndex)
				if ally and ally.isAlly and ally.alive and HPred:IsInRange(enemy.pos, ally.pos, 600 + Menu.Skills.Exhaust.Radius:Value()) and CurrentPctLife(ally) <= Menu.Skills.Exhaust.Health:Value() then
					Control.CastSpell(exhaustHotkey, enemy)
					return
				end
			end
		end
	end
end

function AutoUtil:GetCleanse()
	local cleanseHotkey
	local cleanseData = myHero:GetSpellData(SUMMONER_1)
	if cleanseData.name ~= "SummonerBoost" then
		cleanseData = myHero:GetSpellData(SUMMONER_2)
		cleanseHotkey = HK_SUMMONER_2
	else 
		cleanseHotkey = HK_SUMMONER_1
	end	
	if cleanseData.name == "SummonerBoost" and cleanseData.currentCd < 2 then 
		return cleanseHotkey
	end	
end

function AutoUtil:AutoCleanse()
	local cleanseHotkey = AutoUtil:GetCleanse()	
	if not cleanseHotkey or not Menu.Skills.Cleanse then return end
	if not Menu.Skills.Combo then return end
	if Menu.Skills.Cleanse.Enabled:Value() and (Menu.Skills.Combo:Value() or not Menu.Skills.Cleanse.Combo:Value()) then
		for ccName, ccType in pairs(_ccNames) do
			if Menu.Skills.Cleanse.CC[ccName] and Menu.Skills.Cleanse.CC[ccName]:Value() and AutoUtil:HasBuffType(myHero, ccType, Menu.Skills.Cleanse.CleanseTime:Value()) then
				Control.CastSpell(cleanseHotkey)
				return
			end
		end
	end
end


class "Brand"
function Brand:__init()	
	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end
function Brand:LoadSpells()
	Q = {Range = 1050, Width = 80, Delay = 0.25, Speed = 1550, Collision = true}
	W = {Range = 900, Width = 250, Delay = 0.625, Speed = _huge}
	E = {Range = 600, Delay = 0.25, Speed = _huge}
	R = {Range = 750, Delay = 0.25, Speed = 1700}
end

function Brand:CreateMenu()	
	
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Sear", type = MENU})
	Menu.Skills.Q:MenuElement({id = "AccuracyCombo", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.Q:MenuElement({id = "AccuracyAuto", name = "Auto Accuracy", value = 3, min = 1, max = 6, step = 1 })
	
	Menu.Skills:MenuElement({id = "W", name = "[W] Pillar of Flame", type = MENU})
	Menu.Skills.W:MenuElement({id = "AccuracyCombo", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.W:MenuElement({id = "AccuracyAuto", name = "Auto Cast Accuracy", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.W:MenuElement({id = "Mana", name = "Auto Cast Mana", value = 30, min = 1, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Conflagration", type = MENU})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Auto Cast Mana", value = 15, min = 1, max = 100, step = 5 })
	Menu.Skills.E:MenuElement({id = "Targets", name = "Auto Harass Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Pyroclasm", type = MENU})
	Menu.Skills.R:MenuElement({id = "Count", name = "Auto Cast On Enemy Count", value = 3, min = 1, max = 6, step = 1 })	
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })	
end

function Brand:Draw()
	--Nothing special needs to be drawn for brand... Could add prediciton for Q/W but its prob not needed
end

local WCastPos, WCastTime
--Gets the time until our W will deal damage
function Brand:GetWHitTime()
	local deltaHitTime = 99999999
	if( WCastTime) then
		deltaHitTime = WCastTime + W.Delay - Game.Timer()
	end
	return deltaHitTime
end


function Brand:Tick()
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
		
	--UnCache the last W if its already hit
	if WCastPos and Game.Timer() - WCastTime > 1.5 then
		WCastPos = nil
	end
	--Reliable spells cast even if combo key is NOT pressed and are the most likely to hit.
	if Ready(_W) then
		Brand:ReliableW()
		if CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() then
			Brand:UnreliableW(Menu.Skills.W.AccuracyAuto:Value())
		end
	end
	
	if Ready(_Q) then
		Brand:ReliableQ()
	end
	
	if Ready(_E) then
		Brand:ReliableE()
	end
	
	if Ready(_R) then
		Brand:AutoR()
	end
	
	--Unreliable spells are cast if the combo or harass key is pressed
	if Menu.Skills.Combo:Value() then
		if Ready(_W) then
			Brand:UnreliableW(Menu.Skills.W.AccuracyCombo:Value())
		end
		if Ready(_Q) then		
			Brand:UnreliableQ(Menu.Skills.Q.AccuracyCombo:Value())
		end
	else	
		if Ready(_Q) then		
			Brand:UnreliableQ(Menu.Skills.Q.AccuracyAuto:Value())
		end
	end
	
	
	
end

function Brand:ReliableQ()
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
	if target and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
		--Check if they are ablaze or will be hit by W before Q
		local WInterceptTime = self:GetWHitTime()		
		local QInterceptTime = HPred:GetSpellInterceptTime(myHero.pos, aimPosition, Q.Delay, Q.Speed)
		
		if HPred:HasBuff(target, "BrandAblaze", QInterceptTime) or (WCastPos and HPred:IsInRange(WCastPos, aimPosition, W.Width) and  QInterceptTime > WInterceptTime) then
			SpecialCast(HK_Q, aimPosition, false, true)
		end
	end
end

function Brand:UnreliableQ(minAccuracy)

	for i  = 1,LocalGameHeroCount(i) do
		local enemy = LocalGameHero(i)		
		if enemy and HPred:CanTarget(enemy) then	
			local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, enemy,Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, nil)
			
			local WInterceptTime = self:GetWHitTime()		
			local QInterceptTime = HPred:GetSpellInterceptTime(myHero.pos, aimPosition, Q.Delay, Q.Speed)
			if hitChance and hitChance >= minAccuracy and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) and (HPred:HasBuff(enemy, "BrandAblaze",1) or (WCastPos and HPred:IsInRange(WCastPos, aimPosition, W.Width) and  QInterceptTime > WInterceptTime)) then
				SpecialCast(HK_Q, aimPosition, false, true)
			end
		end
	end
end

function Brand:ReliableW()	
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, W.Range, W.Delay, W.Speed,W.Width, Menu.General.ReactionTime:Value(), W.Collision)
	if target and HPred:IsInRange(myHero.pos, aimPosition, W.Range) then
		SpecialCast(HK_W, aimPosition)
		WCastPos = aimPosition
		WCastTime = Game.Timer()
	end
end

function Brand:UnreliableW(minAccuracy)
	local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, W.Range, W.Delay, W.Speed, W.Width, W.Collision, minAccuracy)	
	if hitRate and HPred:IsInRange(myHero.pos, aimPosition, W.Range) then
		SpecialCast(HK_W, aimPosition)
		WCastPos = aimPosition
		WCastTime = Game.Timer()
	end	
end

function Brand:ReliableE()
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and HPred:CanTarget(hero) and HPred:IsInRange(myHero.pos, hero.pos, E.Range)  and Menu.Skills.E.Targets[hero.charName] and Menu.Skills.E.Targets[hero.charName]:Value() then
			--TODO: Sort targets by priority and health (KS then priority list)
			SpecialCast(HK_E, hero.pos)
			break
		end
	end
end

function Brand:AutoR()	
	for i  = 1,LocalGameHeroCount(i) do
		local enemy = LocalGameHero(i)
		if enemy and HPred:CanTarget(enemy) and HPred:HasBuff(enemy, "BrandAblaze") and HPred:IsInRange(myHero.pos, enemy.pos, R.Range) then			
			local targetCount = AutoUtil:CountEnemiesNear(myHero.pos, 600)
			if targetCount >= Menu.Skills.R.Count:Value() then
				SpecialCast(HK_R, enemy.pos)
				break				
			end
		end
	end
end


class "Soraka"

function Soraka:__init()	
	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end
function Soraka:LoadSpells()


	Q = {Range = 800, Width = 235,Delay = 0.25, Speed = 1150}
	W = {Range = 550 }
	E = {Range = 925, Width = 300, Delay = 1, Speed = _huge}
end

function Soraka:CreateMenu()	
	
	AutoUtil:SupportMenu(Menu)
	
	
	
	if AutoUtil:GetExhaust() then
		Menu.Skills:MenuElement({id = "Exhaust", name = "Exhaust", type = MENU})	
		Menu.Skills.Exhaust:MenuElement({id ="Targets", name ="Target List", type = MENU})
		for i = 1, LocalGameHeroCount() do
			local hero = LocalGameHero(i)
			if hero and hero.isEnemy then
				Menu.Skills.Exhaust.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
			end
		end
		Menu.Skills.Exhaust:MenuElement({id = "Health", tooltip ="How low health allies must be to use exhaust", name = "Ally Health", value = 40, min = 1, max = 100, step = 5 })	
		Menu.Skills.Exhaust:MenuElement({id = "Radius", tooltip ="How close targets must be to allies to use exhaust", name = "Peel Distance", value = 200, min = 100, max = 1000, step = 25 })
		Menu.Skills.Exhaust:MenuElement({id="Enabled", name="Enabled", value = false})	
	end
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Starcall", type = MENU})
	Menu.Skills.Q:MenuElement({id = "AccuracyCombo", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.Q:MenuElement({id = "AccuracyAuto", name = "Auto Accuracy", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Auto Cast Mana", value = 30, min = 1, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "W", name = "[W] Astral Infusion", type = MENU})
	Menu.Skills.W:MenuElement({id = "Targets", name = "Target Settings", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and myHero ~= hero then
			Menu.Skills.W.Targets:MenuElement({id = hero.charName, name = hero.charName, value = 50, min = 1, max = 100, step = 5 })		
		end
	end	
	Menu.Skills.W:MenuElement({id = "Health", tooltip ="How high must our health be to heal", name = "W Minimum Health", value = 35, min = 1, max = 100, step = 5 })
	Menu.Skills.W:MenuElement({id = "Mana", tooltip ="How high must our mana be to heal", name = "W Minimum Mana", value = 20, min = 1, max = 100, step = 5 })
		
	Menu.Skills:MenuElement({id = "E", name = "[E] Equinox", type = MENU})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Auto Cast Mana", value = 15, min = 1, max = 100, step = 5 })
	Menu.Skills.E:MenuElement({id = "Targets", name = "Auto Interrupt Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Wish", type = MENU})
	Menu.Skills.R:MenuElement({id = "Targets", name = "Auto Save Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly then
			Menu.Skills.R.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	
	Menu.Skills.R:MenuElement({id = "EmergencyCount", tooltip = "How many allies must be below 40pct for ultimate to cast", name = "Ally count below 40% HP", value = 2, min = 1, max = 6, step = 1 })
	Menu.Skills.R:MenuElement({id = "DamageCount", tooltip = "How many allies must have been injured in last second to cast", name = "Ally count Damaged X%", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.R:MenuElement({id = "DamagePercent", tooltip = "How much damage allies received in last second", name = "Ally Damage Threshold", value = 40, min = 1, max = 80, step = 1 })
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })	
end

function Soraka:Draw()
	--Nothing special needs to be drawn for brand... Could add prediciton for Q/W but its prob not needed
end

function Soraka:Tick()
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	
	--Heal allies with R
	if Ready(_R) then
		Soraka:AutoR()
	end
	
	--Heal allies with W
	if Ready(_W) and CurrentPctLife(myHero) >=  Menu.Skills.W.Health:Value() and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() then
		Soraka:AutoW()
	end
	
	--Harass enemies with Q
	if Ready(_Q) then
		Soraka:AutoQ()
	end
	
	--Interrupt enemies with E
	if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
		Soraka:AutoE()
	end
	
	--Use Support Items
	AutoUtil:UseSupportItems()
	
	--Use Exhaust if we have it
	if Menu.Skills.Exhaust and Menu.Skills.Exhaust.Enabled:Value() then
		AutoUtil.AutoExhaust()
	end
end


function Soraka:AutoQ()
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
	if target and HPred:IsInRange(myHero.pos, aimPosition,Q.Range) then
		SpecialCast(HK_Q, aimPosition)
	--No Reliable target: Check for harass/combo unreliable target instead
	else
		if Menu.Skills.Combo:Value() then
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.AccuracyAuto:Value(), nil)	
			if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
				SpecialCast(HK_Q, aimPosition)
			end	
		elseif CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() then
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.AccuracyAuto:Value(), nil)	
			if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
				SpecialCast(HK_Q, aimPosition)
			end	
		end
	end
end

function Soraka:AutoW()
	local targets = {}
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and hero.alive and hero.isTargetable and hero ~= myHero and HPred:IsInRange(myHero.pos, hero.pos, W.Range + hero.boundingRadius) and Menu.Skills.W.Targets[hero.charName] and Menu.Skills.W.Targets[hero.charName]:Value() >= CurrentPctLife(hero) then		
			local pctLife = CurrentPctLife(hero)
			_insert(targets, {hero, pctLife})
		end
	end
	
	_sort(targets, function( a, b ) return a[2] < b[2] end)	
	if #targets > 0 then
		local castPos = targets[1][1].pos
		targets = nil
		SpecialCast(HK_W,castPos)
	end
	targets = nil
end

function Soraka:AutoE()
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, E.Range, E.Delay, E.Speed,E.Width, Menu.General.ReactionTime:Value(), E.Collision)
	if target and Menu.Skills.E.Targets[target.charName] and Menu.Skills.E.Targets[target.charName]:Value() and HPred:IsInRange(myHero.pos, aimPosition, E.Range) then
		SpecialCast(HK_E, aimPosition)
	end
end

function Soraka:AutoR()
	
	local count, isValid = self:GetEmergencyRCount()
	if isValid and count >= Menu.Skills.R.EmergencyCount:Value() then
		SpecialCast(HK_R)
	end
	
	local count, isValid = self:GetInjuredRCount()
	if isValid and count >= Menu.Skills.R.DamageCount:Value() then
		SpecialCast(HK_R)
	end
	
	UpdateAllyHealth()	
end

function Soraka:GetInjuredRCount()
	local count = 0
	local isValid = false
	
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and hero.alive and _allyHealthPercentage and _allyHealthPercentage[hero.networkID] then		
			local life = _allyHealthPercentage[hero.networkID]
			local deltaLifeLost = life - CurrentPctLife(hero)
			if deltaLifeLost >= Menu.Skills.R.DamagePercent:Value() then
				count = count + 1				
				--Only cast if we've chosen to save at least one of the damaged targets and that target is near an enemy
				--This is prone to issues with untargetable enemies or globals or damage prediction but it will serve for now.
				if not isValid and Menu.Skills.R.Targets[hero.charName] and Menu.Skills.R.Targets[hero.charName]:Value() and AutoUtil:NearestEnemy(hero) < 800 then					
					isValid = true
				end
				
			end
		end
	end
	return count, isValid
end

function Soraka:GetEmergencyRCount()
	local count = 0
	local isValid = false
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and hero.alive and CurrentPctLife(hero) <= 40 then
			count = count + 1
			if not isValid and Menu.Skills.R.Targets[hero.charName] and Menu.Skills.R.Targets[hero.charName]:Value() then
				isValid = true
			end
		end
	end	
	return count, isValid
end




class "Zilean"

function Zilean:__init()	
	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end
function Zilean:LoadSpells()
	Q = {Range = 900, Width = 180,Delay = 0.25, Speed = 2050}
	E = {Range = 550}
	R = {Range = 900}
end

function Zilean:CreateMenu()	
	
	AutoUtil:SupportMenu(Menu)
	
	
	
	if AutoUtil:GetExhaust() then
		Menu.Skills:MenuElement({id = "Exhaust", name = "Exhaust", type = MENU})	
		Menu.Skills.Exhaust:MenuElement({id ="Targets", name ="Target List", type = MENU})
		for i = 1, LocalGameHeroCount() do
			local hero = LocalGameHero(i)
			if hero and hero.isEnemy then
				Menu.Skills.Exhaust.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
			end
		end
		Menu.Skills.Exhaust:MenuElement({id = "Health", tooltip ="How low health allies must be to use exhaust", name = "Ally Health", value = 40, min = 1, max = 100, step = 5 })	
		Menu.Skills.Exhaust:MenuElement({id = "Radius", tooltip ="How close targets must be to allies to use exhaust", name = "Peel Distance", value = 200, min = 100, max = 1000, step = 25 })
		Menu.Skills.Exhaust:MenuElement({id="Enabled", name="Enabled", value = false})	
	end
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Timb Bomb", type = MENU})
	Menu.Skills.Q:MenuElement({id = "AccuracyCombo", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.Q:MenuElement({id = "AccuracyAuto", name = "Auto Accuracy", value = 3, min = 1, max = 6, step = 1 })
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Auto Cast Mana", value = 30, min = 1, max = 100, step = 5 })
	Menu.Skills.Q:MenuElement({id = "Targets", name = "Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.Q.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	
	
	Menu.Skills:MenuElement({id = "W", name = "[W] Rewind", type = MENU})
	Menu.Skills.W:MenuElement({id = "Cooldown", name = "Minimum Cooldown Remaining", value = 3, min = 1, max = 10, step = .5 })
	Menu.Skills.W:MenuElement({id = "Mana", name = "Minimum Mana", value = 25, min = 1, max = 100, step = 5 })
	
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Time Warp", type = MENU})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Minimum Mana", value = 25, min = 1, max = 100, step = 5 })
	Menu.Skills.E:MenuElement({id = "Health", name = "Peel When Under % HP", value = 40, min = 1, max = 100, step = 5 })
	Menu.Skills.E:MenuElement({id = "Radius", name = "Peel Range", value = 300, min = 100, max = 600, step = 50 })
	Menu.Skills.E:MenuElement({id = "Targets", name = "Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end	
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Chronoshift", type = MENU})
	Menu.Skills.R:MenuElement({id = "Health", name = "Ally Health", value = 20, min = 1, max = 100, step = 5 })
	Menu.Skills.R:MenuElement({id = "Damage", name = "Damage Received", value = 15, min = 1, max = 100, step = 5 })		
	Menu.Skills.R:MenuElement({id = "Targets", name = "Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly then
			Menu.Skills.R.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true})		
		end
	end	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })	
end

function Zilean:Draw()
	--Nothing special needs to be drawn for brand... Could add prediciton for Q/W but its prob not needed
end

function Zilean:Tick()
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	--Use Ult on Allies	
	if Ready(_R) then
		Zilean:AutoR()
	end
	
	--Reliable Q combo
	if Ready(_Q) then
		Zilean:AutoQ()
	end
	
	--Peel with E
	if Ready(_E) then
		Zilean:AutoEPeel()
	end
	
	--Reset cooldowns with W
	if Ready(_W) then
		Zilean:AutoWReset()
	end
		
	--Use Support Items
	AutoUtil:UseSupportItems()
	
	--Use Exhaust if we have it
	if Menu.Skills.Exhaust and Menu.Skills.Exhaust.Enabled:Value() then
		AutoUtil.AutoExhaust()
	end
end


function Zilean:AutoQ()	
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
	if target and HPred:CanTarget(target) and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) and Menu.Skills.Q.Targets[target.charName] and Menu.Skills.Q.Targets[target.charName]:Value() then
		if Ready(_W) then
			self:StunCombo(target, aimPosition)		
		else	
			SpecialCast(HK_Q, aimPosition)
		end	
	--Unreliable Q
	elseif CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() then
		local minAccuracy = Menu.Skills.Q.AccuracyAuto:Value()
		if Menu.Skills.Combo:Value() and Menu.Skills.Q.AccuracyCombo:Value() < minAccuracy then
			minAccuracy = Menu.Skills.Q.AccuracyCombo:Value()
		end
		
		local _whiteList = {}
		for i  = 1,LocalGameHeroCount(i) do
			local enemy = LocalGameHero(i)
			if enemy and Menu.Skills.Q.Targets[enemy.charName] and Menu.Skills.Q.Targets[enemy.charName]:Value() then
				_whiteList[enemy.charName] = true
			end
		end
		local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision,minAccuracy,_whiteList)	
		if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
			SpecialCast(HK_Q, aimPosition)
		end
	
	end
end


function Zilean:StunCombo(target, aimPosition)
	NextSpellCast = Game.Timer() + .5	
	if Ready(_E) and HPred:IsInRange(myHero.pos, target.pos,E.Range) then
		--We can lead with E, if not just go for QWQ stun combo and we can E later if we really want
		SpecialCast(HK_E, target, true)
	end
	
	--Try spam casting it for the hell of it
	SpecialCast(HK_Q, aimPosition, true)
	DelayAction(function()SpecialCast(HK_Q, aimPosition, true) end,.10)
	DelayAction(function()SpecialCast(HK_W) end,.15)
	DelayAction(function()SpecialCast(HK_Q, aimPosition, true) end, 0.3)
end

function Zilean:AutoWReset()
	if myHero.levelData.lvl > 3 and not Ready(_Q) and not Ready(_E) and Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() then
		if myHero:GetSpellData(_Q).currentCd >= Menu.Skills.W.Cooldown:Value() and myHero:GetSpellData(_E).currentCd >= Menu.Skills.W.Cooldown:Value() then		
			Control.CastSpell(HK_W)
		end
	end
end

function Zilean:AutoEPeel()	
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		--Its an ally, they are in range and we've set them as a carry. Lets peel for them!
		if hero and hero.isAlly and CurrentPctLife(hero) <= Menu.Skills.E.Health:Value() and HPred:IsInRange(myHero.pos, hero.pos, E.Range  + Menu.Skills.E.Radius:Value()) then				
			if target ~= nil and  AutoUtil:NearestEnemy(hero) <= Menu.Skills.E.Radius:Value() and HPred:IsInRange(myHero.pos, target.pos, E.Range) then
				SpecialCast(HK_E, target.pos, true)
			end
		end
	end
end

function Zilean:AutoR()
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and HPred:IsInRange(myHero.pos, hero.pos, R.Range) and CurrentPctLife(hero) <= Menu.Skills.R.Health:Value() and Menu.Skills.R.Targets[hero.charName] and Menu.Skills.R.Targets[hero.charName]:Value() and _allyHealthPercentage[hero.networkID] then			
			local deltaLifeLost = _allyHealthPercentage[hero.networkID] - CurrentPctLife(hero)
			if deltaLifeLost >= Menu.Skills.R.Damage:Value() and AutoUtil:NearestEnemy(hero) < 800 then
				SpecialCast(HK_R, hero.pos, true)
				break
			end
		end
	end	
	UpdateAllyHealth()	
end


class "Nami"

function Nami:__init()	
	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end
function Nami:LoadSpells()
	Q = {Range = 875, Width = 200,Delay = 0.95, Speed = _huge}
	W = {Range = 725}
	E = { Range = 800}
	R = {Range = 2750,Width = 215, Speed = 850, Delay = 0.5}
end

function Nami:CreateMenu()	
	
	AutoUtil:SupportMenu(Menu)
	
	
	
	if AutoUtil:GetExhaust() then
		Menu.Skills:MenuElement({id = "Exhaust", name = "Exhaust", type = MENU})	
		Menu.Skills.Exhaust:MenuElement({id ="Targets", name ="Target List", type = MENU})
		for i = 1, LocalGameHeroCount() do
			local hero = LocalGameHero(i)
			if hero and hero.isEnemy then
				Menu.Skills.Exhaust.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
			end
		end
		Menu.Skills.Exhaust:MenuElement({id = "Health", tooltip ="How low health allies must be to use exhaust", name = "Ally Health", value = 40, min = 1, max = 100, step = 5 })	
		Menu.Skills.Exhaust:MenuElement({id = "Radius", tooltip ="How close targets must be to allies to use exhaust", name = "Peel Distance", value = 200, min = 100, max = 1000, step = 25 })
		Menu.Skills.Exhaust:MenuElement({id="Enabled", name="Enabled", value = false})	
	end
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Aqua Prison", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })	
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Bubble Immobile Targets", value = true, toggle = true })	
	
	Menu.Skills:MenuElement({id = "W", name = "[W] Ebb and Flow", type = MENU})
	Menu.Skills.W:MenuElement({id = "ManaBounce", name = "Minimum Mana [Bounce]", value = 25, min = 1, max = 100, step = 5 })
	Menu.Skills.W:MenuElement({id = "HealthBounce", name = "Minimum Health [Bounce]", value = 60, min = 1, max = 100, step = 5 })	
	Menu.Skills.W:MenuElement({id = "ManaEmergency", name = "Minimum Mana [No Bounce]", value = 25, min = 1, max = 100, step = 5 })
	Menu.Skills.W:MenuElement({id = "HealthEmergency", name = "Minimum Health [No Bounce]", value = 25, min = 1, max = 100, step = 5 })
	
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Tidecaller's Blessing", type = MENU})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Minimum Mana", value = 25, min = 1, max = 100, step = 5 })
	Menu.Skills.E:MenuElement({id = "Auto", name = "Auto Buff Allies", value = true, toggle = true })	
	Menu.Skills.E:MenuElement({id = "Targets", name = "Targets", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly  then
			if table.contains(_adcHeroes, hero.charName) then
				Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
			else
				Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = false, toggle = true})
			end
		end
	end	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })	
end

function Nami:Draw()
	--Nothing special needs to be drawn for brand... Could add prediciton for Q/W but its prob not needed
end

function Nami:Tick()
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	--Auto Bubble Immobile targets and unreliable targets if combo button held down
	if Ready(_Q) then
		Nami:AutoQ()		
	end
		
	--Auto W bounce or solo target enemies
	if Ready(_W) then
		Nami:AutoW()
	end
	
	--Auto E selected allies who are auto attacking enemies
	if Ready(_E) and Menu.Skills.E.Auto:Value() and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
		Nami:AutoE()
	end
	
	
	--Use Support Items
	AutoUtil:UseSupportItems()
	
	--Use Exhaust if we have it
	if Menu.Skills.Exhaust and Menu.Skills.Exhaust.Enabled:Value() then
		AutoUtil.AutoExhaust()
	end	
end

function Nami:AutoQ()
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
	if target and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) and Menu.Skills.Q.Auto:Value() then
		SpecialCast(HK_Q, aimPosition)		
	elseif Menu.Skills.Combo:Value() then
		local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.Accuracy:Value(),nil)	
		if hitRate and HPred:IsInRange(myHero.pos, aimPosition,Q.Range) then
			SpecialCast(HK_Q, aimPosition)
		end	
	end
end

function Nami:AutoW()
	if CurrentPctMana(myHero) >= Menu.Skills.W.ManaEmergency:Value() then
		self:AutoWNoBounce()
	end	
	if CurrentPctMana(myHero) >= Menu.Skills.W.ManaBounce:Value() then
		self:AutoWBounce()
	end	
end

function Nami:AutoWNoBounce()
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and hero.alive and hero.isTargetable and HPred:IsInRange(myHero.pos, hero.pos,W.Range) and CurrentPctLife(hero) <= Menu.Skills.W.HealthEmergency:Value() then
			Control.CastSpell(HK_W, hero)			
		end
	end
end
function Nami:AutoWBounce()	
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)		
		if hero and hero.isAlly and hero.alive and hero.isTargetable and HPred:IsInRange(myHero.pos, hero.pos, W.Range) and CurrentPctLife(hero) <= Menu.Skills.W.HealthBounce:Value() then
			if AutoUtil:NearestEnemy(hero) < 500 then
				Control.CastSpell(HK_W, hero)
			end	
		end
	end
end

function Nami:AutoE()
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and hero.isTargetable and hero.alive and HPred:IsInRange(myHero.pos, hero.pos, E.Range) and Menu.Skills.E.Targets[hero.charName] and Menu.Skills.E.Targets[hero.charName]:Value() then
			
			local targetHandle = nil			
			if hero.activeSpell and hero.activeSpell.valid and hero.activeSpell.target then
				targetHandle = hero.activeSpell.target
			end
			
			if targetHandle then 		
				local Enemy = GetHeroByHandle(targetHandle)
				if Enemy and Enemy.isEnemy then
					Control.CastSpell(HK_E, hero)
				end
			end
		end
	end
end


class "Lux"

function Lux:__init()	
	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end
function Lux:LoadSpells()
	Q = {Range = 1075, Width = 50,Delay = 0.25, Speed = 1200, Collision = true}
	W = {Range = 1075, Width = 120,Delay = 0.25, Speed = 1400}
	E = {Range = 1100, Width = 310,Delay = 0.25, Speed = 1200}
	R = {Range = 3340, Width = 115, Delay = 1, Speed = _huge}
end

function Lux:CreateMenu()		
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Light Binding", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })	
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Cast On Immobile Targets", value = true, toggle = true })	
		
	Menu.Skills:MenuElement({id = "W", name = "[W] Prismatic Barrier", type = MENU})
	Menu.Skills.W:MenuElement({id = "Mana", name = "Minimum Mana", value = 20, min = 1, max = 100, step = 1 })
	Menu.Skills.W:MenuElement({id = "Damage", name = "Recent Damage Received", value = 15, min = 5, max = 60, step = 5 })
	Menu.Skills.W:MenuElement({id = "Count", name = "Minimum Targets", value = 1, min = 1, max = 6, step = 1 })
		
	Menu.Skills:MenuElement({id = "E", name = "[E] Lucent Singularity", type = MENU})
	Menu.Skills.E:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1 })	
	Menu.Skills.E:MenuElement({id = "Auto", name = "Auto Cast On Immobile Targets", value = true, toggle = true })
		
	Menu.Skills:MenuElement({id = "R", name = "[R] Final Spark", type = MENU})	
	Menu.Skills.R:MenuElement({id = "Count", name = "Target Count", tooltip = "How many targets we need to be able to hit to auto cast", value = 2, min = 1, max = 6, step = 1 })	
	Menu.Skills.R:MenuElement({id = "Killsteal", name = "Auto Killsteal", value = true, toggle = true })
	Menu.Skills.R:MenuElement({id = "Auto", name = "Auto Cast On Target Count", value = true, toggle = true })	
	Menu.Skills.R:MenuElement({id = "Targets", name = "Auto Targets", type = MENU})	
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.R.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
		end
	end
		
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })	
end

local _nextMissileCache = Game.Timer()
function Lux:Draw()
	if _nextMissileCache > Game.Timer() then return end	
	_nextMissileCache = Game.Timer() + .2
	HPred:CacheMissiles()	
	HPred:CalculateIncomingDamage()
end

function Lux:PrintDebugSpells()
local count = 0
	for i = 1, LocalGameMissileCount() do
		local missile = LocalGameMissile(i)	
		if missile ~= nil then
			local dist =  HPred:GetDistance(missile.pos, myHero.pos)
			if dist > 100 and dist < 800 then
				count = count + 1
				local screenPos = missile.pos:To2D()
				LocalDrawText(missile.name, 13, screenPos.x, screenPos.y+ count * 15)
			end
		end
	end
	local count = 0
	for i = 1, LocalGameParticleCount() do
		local particle = LocalGameParticle(i)
		if particle ~= nil then		
			local dist =  HPred:GetDistance(particle.pos, myHero.pos)
			if dist > 100 and dist < 800 then
				count = count + 1
				local screenPos = particle.pos:To2D()
				LocalDrawText(particle.name, 13, screenPos.x, screenPos.y + count * 15)
			end
		end
	end
end

function Lux:Tick()
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	if Ready(_Q) then
		Lux:AutoQ()
	end
			
	if Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() then
		Lux:AutoW()
	end
	
	if Ready(_E) then
		Lux:AutoE()
	end
			
	if Ready(_R) then
		Lux:AutoR()
	end
	
	UpdateAllyHealth()
end

function Lux:AutoQ()
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
	if target and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) and Menu.Skills.Q.Auto:Value() then
		SpecialCast(HK_Q, aimPosition)		
	elseif Menu.Skills.Combo:Value() then
		--Don't unreliable max range Qs, they will almost never hit...
		local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range* 2 / 3, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.Accuracy:Value(),nil)	
		if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
			SpecialCast(HK_Q, aimPosition)
		end	
	end
end

function Lux:AutoW()
	--Find allies who have taken X% damage in the last second. Calculate how many would be hit if we cast W on them
	--Choose ally that results in the most predicted allies hit with W to cast it on
	local aimPositions = {}
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and HPred:IsInRange(myHero.pos, hero.pos, W.Range) and _allyHealthPercentage[hero.networkID] then		
			local predictedLife = CurrentPctLife(hero)
			local predictedLoss = HPred:GetIncomingDamage(hero)/ hero.maxHealth  * 100
			predictedLife = predictedLife - predictedLoss
			local deltaLifeLost = _allyHealthPercentage[hero.networkID] - predictedLife
			if deltaLifeLost >= Menu.Skills.W.Damage:Value() then
				--Count how many allies will be hit
				
				if hero == myHero then
					local tempHero = AutoUtil:GetNearestAlly(myHero, W.Range)
					if tempHero then
						hero = tempHero
					end
				end
				
				local aimPosition = HPred:PredictUnitPosition(hero, W.Delay + HPred:GetDistance(myHero.pos, hero.pos) / W.Speed)				
				local targetCount = HPred:GetLineTargetCount(myHero.pos, aimPosition, W.Delay, W.Speed, W.Width, true)
				if targetCount >= Menu.Skills.W.Count:Value() then
					_insert(aimPositions, {aimPosition, targetCount})		
				end
			end
		end
	end
	
	_sort(aimPositions, function( a, b ) return a[2] < b[2] end)
	if #aimPositions > 0 then
		local aimPos = aimPositions[1][1]
		aimPositions = nil
		SpecialCast(HK_W, aimPos)
	end
end

local eMissile
local eParticle

function Lux:IsETraveling()
	return eMissile and eMissile.name and eMissile.name == "LuxLightStrikeKugel"
end

function Lux:IsELanded()
	return eParticle and eParticle.name and _find(eParticle.name, "E_tar_aoe_sound")
end

function Lux:AutoE()

	if self:IsELanded() then
		if AutoUtil:NearestEnemy(eParticle) < E.Width  then	
			Control.CastSpell(HK_E)
			eParticle = nil
		end	
	else		
		--Try to cast E or search for missile
		local eData = myHero:GetSpellData(_E)
		if eData.toggleState == 1 then
			--Check if we have the particle or not
			if not self:IsETraveling() then
				for i = 1, LocalGameMissileCount() do
					local missile = LocalGameMissile(i)			
					if missle and  missile.name == "LuxLightStrikeKugel" and HPred:IsInRange(missile.pos, myHero.pos, 400) then
						eMissile = missile
						break
					end
				end
			end
		elseif eData.toggleState == 2 then		
			for i = 1, LocalGameParticleCount() do 
				local particle = LocalGameParticle(i)
				if particle and _find(particle.name, "E_tar_aoe_sound") then
					eParticle = particle
					break
				end
			end			
		elseif Ready(_E) then
			local target, aimPosition = HPred:GetReliableTarget(myHero.pos, E.Range, E.Delay, E.Speed,E.Width, Menu.General.ReactionTime:Value(), E.Collision)
			if Menu.Skills.E.Auto:Value() and target and HPred:IsInRange(myHero.pos, aimPosition, E.Range) then
				SpecialCast(HK_E, aimPosition)
				eMissile = nil
			elseif Menu.Skills.Combo:Value() then					
				local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, E.Range, E.Delay, E.Speed, E.Width, E.Collision, Menu.Skills.E.Accuracy:Value(),nil)
				if hitRate then
					SpecialCast(HK_E, aimPosition)
					eMissile = nil
				end
			end
		end
	end	
end

function Lux:AutoR()			
	local rDamage= 200 + (myHero:GetSpellData(_R).level) * 100 + myHero.ap * 0.75
	--Check if the target has passive on them because that will deal extra damage
	--If the target is a near guarenteed hit then count how many targets it will hit: If enough targets are likely then cast regardless of health	
	
	--Unreliable ult killsteal. use line calculation to improve the accuracy significantly.
	
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, R.Range, R.Delay, R.Speed,R.Width, Menu.General.ReactionTime:Value(), R.Collision)
	if target and HPred:IsInRange(myHero.pos, aimPosition, R.Range) then		
		if Menu.Skills.R.Auto:Value() and Menu.Skills.R.Targets[target.charName] and Menu.Skills.R.Targets[target.charName]:Value() then			
			local cPos = myHero.pos + ( aimPosition- myHero.pos):Normalized() * R.Range
			local targetCount = HPred:GetLineTargetCount(myHero.pos, cPos, R.Delay, R.Speed, R.Width, false)
			if targetCount >= Menu.Skills.R.Count:Value() then
				SpecialCast(HK_R, aimPosition, false, true)
			end
		end
	elseif Menu.Skills.R.Killsteal:Value() then
		for i = 1, LocalGameHeroCount() do
			local hero = LocalGameHero(i)
			if HPred:CanTarget(hero) and Menu.Skills.R.Targets[hero.charName] and Menu.Skills.R.Targets[hero.charName]:Value() then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, hero, R.Range, R.Delay, R.Speed, R.Width, R.Collision)
				if hitRate > 2 and HPred:IsInRange(myHero.pos, aimPosition, R.Range) then
					local thisRDamage = rDamage
					if HPred:HasBuff(hero, "LuxIlluminatingFraulein",1.25) then
						thisRDamage = thisRDamage + 20 + myHero.levelData.lvl * 10 + myHero.ap * 0.2
					end
					local predictedHealth = hero.health
					if _G.SDK and _G.SDK.HealthPrediction then
						predictedHealth = _G.SDK.HealthPrediction:GetPrediction(hero, R.Delay)
					end
					thisRDamage = AutoUtil:CalculateMagicDamage(hero, thisRDamage)
					if thisRDamage > predictedHealth then
						SpecialCast(HK_R, aimPosition, false, true)
					end
				end
			end
		end
	end	
end

class "Blitzcrank" 
function Blitzcrank:__init()

	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
	
	
	if _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:OnPostAttack(function(args)
			if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
				local target = HPred:GetEnemyHeroByHandle(myHero.activeSpell.target)
				if target then
					Control.CastSpell(HK_E)
				end
			end
		end)
	end
	
	
end

function Blitzcrank:CreateMenu()

	Menu.General:MenuElement({id = "DrawQAim", name = "Draw Q Aim", value = true})
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Rocket Grab", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Targets", name = "Targets", type = MENU})	
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.Q.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
		end
	end
	Menu.Skills.Q:MenuElement({id = "Immobile", name = "Auto Hook Immobile", value = true})
	Menu.Skills.Q:MenuElement({id = "Range", name = "Minimum Auto Hook Range", value = 300, min = 900, max = 100, step = 50})
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
		
	Menu.Skills:MenuElement({id = "E", name = "[E] Power Fist", type = MENU})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Static Field", type = MENU})
	Menu.Skills.R:MenuElement({id = "KS", name = "Secure Kills", value = true})
	Menu.Skills.R:MenuElement({id = "Count", name = "Target Count", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.R:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })	
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })
end

function Blitzcrank:LoadSpells()
	Q = {Range = 925, Width = 120,Delay = 0.25, Speed = 1750,  Collision = true}
	R = {Range = 600 ,Delay = 0.25, Speed = _huge}
end

function Blitzcrank:Draw()	
	if Ready(_Q) and Menu.General.DrawQAim:Value() and forcedTarget and forcedTarget.alive and forcedTarget.visible then	
		local targetOrigin = HPred:PredictUnitPosition(forcedTarget, Q.Delay)
		local interceptTime = HPred:GetSpellInterceptTime(myHero.pos, targetOrigin, Q.Delay, Q.Speed)			
		local origin, radius = HPred:UnitMovementBounds(forcedTarget, interceptTime, Menu.General.ReactionTime:Value())		
						
		if radius < 25 then
			radius = 25
		end
		
		if HPred:IsInRange(myHero.pos, origin, Q.Range) then
			LocalDrawCircle(origin, 25,10, LocalDrawColor(150, 0, 255,0))
		else
			LocalDrawCircle(origin, 25,10, LocalDrawColor(150, 255, 0,0))
			LocalDrawCircle(origin, radius,1, LocalDrawColor(150, 255, 255,255))	
		end
	end	
end

function Blitzcrank:Tick()
	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	--TODO: Only update whitelist every second
	
	if Ready(_Q) then
		if Menu.Skills.Q.Immobile:Value() then
			local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
			if target and not HPred:IsInRange(myHero.pos, aimPosition, Menu.Skills.Q.Range:Value()) then
				SpecialCast(HK_Q, aimPosition)
			end
		end
		
		if Menu.Skills.Combo:Value() and CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() then
			local _whiteList = {}
			for i  = 1,LocalGameHeroCount(i) do
				local enemy = LocalGameHero(i)
				if enemy and Menu.Skills.Q.Targets[enemy.charName] and Menu.Skills.Q.Targets[enemy.charName]:Value() then
					_whiteList[enemy.charName] = true
				end
			end
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.Accuracy:Value(),_whiteList)	
			if hitRate then
				SpecialCast(HK_Q, aimPosition)
			end
		end
	end	
	
	if Ready(_R) and CurrentPctMana(myHero) >= Menu.Skills.R.Mana:Value() then
	
		
		local target, aimPosition =HPred:GetChannelingTarget(myHero.pos, R.Range, R.Delay, R.Speed, Menu.General.ReactionTime:Value(), R.Collision, R.Width)
			if target and aimPosition then
			Control.CastSpell(HK_R)
		end
		
		local targetCount = AutoUtil:CountEnemiesNear(myHero.pos, R.Range)
		if targetCount >= Menu.Skills.R.Count:Value() or (Menu.Skills.R.KS:Value() and Blitzcrank:CanRKillsteal())then
			Control.CastSpell(HK_R)
		NextSpellCast = .35 + Game.Timer()
		end
	end
end



function Blitzcrank:CanRKillsteal()
	local rDamage= 250 + (myHero:GetSpellData(_R).level -1) * 125 + myHero.ap 
	for i  = 1,LocalGameHeroCount(i) do
		local enemy = LocalGameHero(i)
		if enemy and enemy.alive and enemy.isEnemy and enemy.visible and enemy.isTargetable and HPred:IsInRange(myHero.pos, enemy.pos, R.Range) then
			local damage = AutoUtil:CalculateMagicDamage(enemy, rDamage)
			if damage >= enemy.health then
				return true
			end
		end
	end
end


class "Lulu" 
function Lulu:__init()

	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end

function Lulu:CreateMenu()

	AutoUtil:SupportMenu(Menu)
	
	
	
	if AutoUtil:GetExhaust() then
		Menu.Skills:MenuElement({id = "Exhaust", name = "Exhaust", type = MENU})	
		Menu.Skills.Exhaust:MenuElement({id ="Targets", name ="Target List", type = MENU})
		for i = 1, LocalGameHeroCount() do
			local hero = LocalGameHero(i)
			if hero and hero.isEnemy then
				Menu.Skills.Exhaust.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
			end
		end
		Menu.Skills.Exhaust:MenuElement({id = "Health", tooltip ="How low health allies must be to use exhaust", name = "Ally Health", value = 40, min = 1, max = 100, step = 5 })	
		Menu.Skills.Exhaust:MenuElement({id = "Radius", tooltip ="How close targets must be to allies to use exhaust", name = "Peel Distance", value = 200, min = 100, max = 1000, step = 25 })
		Menu.Skills.Exhaust:MenuElement({id="Enabled", name="Enabled", value = false})	
	end
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Glitterlance", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Immobile", name = "Cast On Immobile", value = true})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
		
	Menu.Skills:MenuElement({id = "W", name = "[E] Whimsy", type = MENU})
	
	Menu.Skills.W:MenuElement({id = "ComboRange", name = "Combo Radius", value = 350, min = 100, max = 800, step = 50 })
	Menu.Skills.W:MenuElement({id = "ComboTargets", name = "Combo Target List", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.W.ComboTargets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	Menu.Skills.W:MenuElement({id = "ComboMana", name = "Combo Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	
	Menu.Skills.W:MenuElement({id = "Auto", name = "Auto Peel Enemies", value = true, toggle = true})
	Menu.Skills.W:MenuElement({id = "AutoRange", name = "Auto Radius", value = 300, min = 100, max = 800, step = 50 })
	Menu.Skills.W:MenuElement({id = "AutoTargets", name = "Auto Target List", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.W.AutoTargets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	Menu.Skills.W:MenuElement({id = "AutoMana", name = "Auto Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Help, Pix!", type = MENU})
	Menu.Skills.E:MenuElement({id = "Combo", name = "Hit Enemies In Combo", value = true})
	Menu.Skills.E:MenuElement({id = "Targets", name = "Buff Ally List", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly and hero ~= myHero then
			Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Wild Growth", type = MENU})	
	Menu.Skills.R:MenuElement({id = "PeelTargets", name = "Ally Peel List", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly then
			Menu.Skills.R.PeelTargets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	Menu.Skills.R:MenuElement({id = "Life", name = "Current Percent Life", value = 25, min = 0, max = 100, step = 5 })
	Menu.Skills.R:MenuElement({id = "Damage", name = "Recent Damage Received", value = 25, min = 5, max = 60, step = 5 })
	
	
	Menu.Skills.R:MenuElement({id = "KnockupTargets", name = "Ally Knockup List", type = MENU})
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isAlly then
			Menu.Skills.R.KnockupTargets:MenuElement({id = hero.charName, name = hero.charName, value = true, toggle = true})
		end
	end
	Menu.Skills.R:MenuElement({id = "Count", name = "Enemy Count", value = 2, min = 1, max = 6, step = 1 })		
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })
end

function Lulu:LoadSpells()
	Q = {Range = 925, Width = 45,Delay = 0.25, Speed = 1500}
	W = {Range = 650, Delay = 0.25, Speed = 1600}
	E = {Range = 650, Delay = 0.25, Speed = _huge}	
	R = {Range = 900, Width = 400, Delay = 0.25, Speed = _huge}
end

function Lulu:Draw()
end

local _eTarget
local _nextESearch = Game.Timer()

function Lulu:FindETarget()
	if _nextESearch > Game.Timer() then return end
	_nextESearch = Game.Timer() + 0.2
	
	if _eTarget then
		local found = false
		for i = 1, _eTarget.buffCount do 
			local buff = _eTarget:GetBuff(i)
			if buff ~= nil and buff.duration > 0 and buff.name == "luluevision" then
				found = true
				break
			end
		end
		if not found then
			_eTarget = nil
		end
	end
	
	if _eTarget == nil then
		for i = 1, LocalGameHeroCount() do
			local enemy = LocalGameHero(i)
			if enemy ~= nil and HPred:CanTarget(enemy) then
				for i = 1, enemy.buffCount do 
					local buff = enemy:GetBuff(i)
					if buff ~= nil and buff.duration > 0 and buff.name == "luluevision" then
						_eTarget = enemy
						break
					end
				end
			end
		end
	end
end

function Lulu:Tick()
	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	Lulu:FindETarget()
	
	--Use ult to save ally or knockup enemy
	if Ready(_R) then
		Lulu:AutoR()
	end
	
	--Try to peel for allies using polymorph
	if Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.ComboMana:Value() then
		Lulu:AutoW()
	end	
	
	--Try to killsteal with E
	if Ready(_E) then
		if Menu.Skills.E.Combo:Value() and Menu.Skills.Combo:Value() then
			Lulu:ComboE()
		end
		if CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
			Lulu:BuffE()
		end
	end
	
	if Ready(_Q) then
		Lulu:AutoQ(myHero.pos)
		if _eTarget ~= nil then
			Lulu:AutoQ(_eTarget.pos)
		end
	end
	
	--Use Support Items
	AutoUtil:UseSupportItems()
	
	--Use Exhaust if we have it
	if Menu.Skills.Exhaust and Menu.Skills.Exhaust.Enabled:Value() then
		AutoUtil.AutoExhaust()
	end
	
	UpdateAllyHealth()
end

function Lulu:AutoQ(origin)
	local target, aimPosition = HPred:GetReliableTarget(origin, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
	if target and HPred:IsInRange(origin, aimPosition, Q.Range) then
		SpecialCast(HK_Q, aimPosition)		
	elseif Menu.Skills.Combo:Value() then
		--Don't unreliable max range Qs, they will almost never hit...
		local hitRate, aimPosition = HPred:GetUnreliableTarget(origin, Q.Range* 2 / 3, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.Accuracy:Value(),nil)	
		if hitRate and HPred:IsInRange(origin, aimPosition, Q.Range) then
			SpecialCast(HK_Q, aimPosition)
		end	
	end
end

function Lulu:AutoW()
	--Limit the cast range to be no greater than the max W range and then take into account combo vs non combo settings
	local isComboActive = Menu.Skills.Combo:Value() 
	local peelRange = Menu.Skills.W.AutoRange:Value()
	if isComboActive and Menu.Skills.W.ComboRange:Value() > peelRange then
		peelRange = Menu.Skills.W.ComboRange:Value()
	end
	if peelRange > W.Range then
		peelRange = W.Range
	end
	
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and HPred:CanTarget(enemy) and HPred:IsInRange(myHero.pos, enemy.pos, peelRange) then
			--We've set it to auto peel this target and they are in auto peel range: Zap them!
			if Menu.Skills.W.Auto:Value() and Menu.Skills.W.AutoTargets[enemy.charName] and Menu.Skills.W.AutoTargets[enemy.charName]:Value() then
				SpecialCast(HK_W, enemy)
				break
			end
			--We're in combo mode and this target is set to auto poly in combo: Zap them!
			if isComboActive and Menu.Skills.W.ComboTargets[enemy.charName] and Menu.Skills.W.ComboTargets[enemy.charName]:Value() then
				SpecialCast(HK_W, enemy)
				break
			end
		end
	end
end

function Lulu:BuffE()
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if  hero and hero.isAlly and hero.isTargetable and hero.alive and HPred:IsInRange(myHero.pos, hero.pos, E.Range) and Menu.Skills.E.Targets[hero.charName] and Menu.Skills.E.Targets[hero.charName]:Value() then			
			local targetHandle = nil			
			if hero.activeSpell and hero.activeSpell.valid and hero.activeSpell.target then
				targetHandle = hero.activeSpell.target
			end			
			if targetHandle then 		
				local Enemy = GetHeroByHandle(targetHandle)
				if Enemy and Enemy.isEnemy then
					SpecialCast(HK_E, hero)
					break
				end
			end
		end
	end
end

function Lulu:ComboE()
	local target = CurrentTarget(E.Range)
	if target and HPred:CanTarget(target) then
		SpecialCast(HK_E, target)
	end
end

function Lulu:AutoR()
	for i = 1, LocalGameHeroCount() do
		local ally = LocalGameHero(i)
		if ally and ally.isAlly and HPred:CanTargetALL(ally) and HPred:IsInRange(myHero.pos, ally.pos, R.Range) then
			if Menu.Skills.R.KnockupTargets[ally.charName] and Menu.Skills.R.KnockupTargets[ally.charName]:Value() then		
				local targetCount = AutoUtil:CountEnemiesNear(ally.pos, R.Width)
				if targetCount >= Menu.Skills.R.Count:Value() then
					SpecialCast(HK_R, ally)
					break
				end
			end
			if _allyHealthPercentage[ally.networkID] and Menu.Skills.R.PeelTargets[ally.charName] and Menu.Skills.R.PeelTargets[ally.charName]:Value() and CurrentPctLife(ally) <= Menu.Skills.R.Life:Value() then
				local deltaLifeLost = _allyHealthPercentage[ally.networkID] - CurrentPctLife(ally)
				if deltaLifeLost >= Menu.Skills.R.Damage:Value() then
					SpecialCast(HK_R, ally)
					break
				end
			end
		end
	end
end

class "MissFortune" 
local _usePostAttack = false
function MissFortune:__init()

	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)	
	
	if _G.SDK and _G.SDK.Orbwalker then
		_usePostAttack = true
		_G.SDK.Orbwalker:OnPostAttack(function(args) self:OnPostAttack() end)
	end
end

function MissFortune:CreateMenu()
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Double Up", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Minion Crit Bounce", value = true})
	Menu.Skills.Q:MenuElement({id = "Crit", name = "Require Minion Crit", value = true})
	Menu.Skills.Q:MenuElement({id = "Hero", name = "Auto 2X Hero Bounce", value = true})
	Menu.Skills.Q:MenuElement({id = "Killsteal", name = "Killsteal", value = true})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "W", name = "[W] Strut", type = MENU})
	Menu.Skills.W:MenuElement({id = "Auto", name = "Use in Combo", value = false})
	Menu.Skills.W:MenuElement({id = "Mana", name = "Mana Limit", value = 25, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Make it Rain", type = MENU})
	Menu.Skills.E:MenuElement({id = "Auto", name = "Cast on Immobile Targets", value = true})
	Menu.Skills.E:MenuElement({id = "Combo", name = "Cast in Combo", value = true})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 20, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })	
end

function MissFortune:LoadSpells()
	Q = {Range = 650, Delay = .25, Speed = 1800}
	E = {Range = 1000, Delay = .5, Width = 400}
end

function MissFortune:Draw()
end

function MissFortune:GetLineSide(A, B, C)
	return (B.x - A.x) * (C.z - A.z) - (B.z - A.z) * (C.x - A.x)
end
function MissFortune:Tick()	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	if MissFortune:IsRActive() then return end
	
	MissFortune:FindPassiveMark()
	
	if Ready(_Q) then
		MissFortune:AutoQ()
	end
	
	if Ready(_W) then
		MissFortune:AutoW()
	end
	
	if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
		MissFortune:AutoE()
	end
end

function MissFortune:OnPostAttack()	
	if Ready(_Q) and Menu.Skills.Combo:Value() then	
		local target = CurrentTarget(Q.Range, true)
		if target then
			SpecialCast(HK_Q, target.pos)
		end
	end	
end

function MissFortune:IsRActive()
	return myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name =="MissFortuneBulletTime"
end

function MissFortune:AutoQ()
	--Search for players we can kill
	if Menu.Skills.Q.Killsteal:Value() then
		for i = 1, LocalGameHeroCount() do
			local t = LocalGameHero(i)
			if t and HPred:IsInRange(myHero.pos, t.pos, Q.Range + t.boundingRadius) and HPred:CanTarget(t) and self:GetQDamage(t) >= t.health then			
				SpecialCast(HK_Q, t)
			end
		end		
	end
	
	--Search for players we can target that will bounce to other players
	if Menu.Skills.Q.Hero:Value() and CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() then
		for i = 1, LocalGameHeroCount() do
			local t = LocalGameHero(i)
			if t and HPred:IsInRange(myHero.pos, t.pos,Q.Range + t.boundingRadius) and HPred:CanTarget(t) then
				local bounceTarget = self:GetQBounce(t)
				if bounceTarget and HPred:CanTarget(bounceTarget) and _find(bounceTarget.type, "Hero") then
					SpecialCast(HK_Q, t)
				end
			end
		end
	end
	
	--Search for minions that we can bounce Q off of
	if (Menu.Skills.Q.Auto:Value() and CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value()) or Menu.Skills.Combo:Value() then
		for i = 1, LocalGameMinionCount() do
			local t = LocalGameMinion(i)
			if t and HPred:IsInRange(myHero.pos, t.pos, Q.Range + t.boundingRadius) and HPred:CanTarget(t) then
				local predictedHealth = t.health
				if _G.SDK and _G.SDK.HealthPrediction then
					predictedHealth = _G.SDK.HealthPrediction:GetPrediction(t, Q.Delay)
				end
				if self:GetQDamage(t) >= predictedHealth or Menu.Skills.Combo:Value() or not Menu.Skills.Q.Crit:Value() then
					local bounceTarget = self:GetQBounce(t)
					if bounceTarget and HPred:CanTarget(bounceTarget) and _find(bounceTarget.type, "Hero") then
						SpecialCast(HK_Q, t)
					end
				end
			end
		end
	end
	
	--If we aren't using IC Orb then we can just spam Q for shits and giggles
	if not _usePostAttack and Menu.Skills.Combo:Value() then	
		local target = CurrentTarget(Q.Range, true)
		if target then
			SpecialCast(HK_Q, target.pos)
		end
	end	
end

function MissFortune:AutoW()
	if Menu.Skills.Combo:Value() and Menu.Skills.W.Auto:Value() and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
		Control.CastSpell(HK_W)
	end
end

--Only cast on immobile targets, we dont want to waste it if not.
function MissFortune:AutoE()
	local target, aimPosition =HPred:GetImmobileTarget(myHero.pos, E.Range, E.Delay, _huge,Menu.General.ReactionTime:Value())
	if target and aimPosition then
		SpecialCast(HK_E, aimPosition)
	elseif Menu.Skills.E.Combo:Value() and Menu.Skills.Combo:Value() then
		local target = CurrentTarget(E.Range, true)
		if target and HPred:CanTarget(target) then
			local aimPosition = HPred:PredictUnitPosition(target, E.Delay)
			if HPred:IsInRange(myHero.pos, aimPosition, E.Range) then
				SpecialCast(HK_E, aimPosition)
			end
				
		end
	end
end

local _nextPassiveSearch = Game.Timer()
local _passiveSearchFrequency = .25
local _passiveSearchDistance = 1000
local _passiveTarget
function MissFortune:FindPassiveMark()
	if _nextPassiveSearch > Game.Timer() then return end
	_nextPassiveSearch = Game.Timer() + _passiveSearchFrequency
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and HPred:IsInRange(myHero.pos, particle.pos, _passiveSearchDistance) and _find(particle.name, "_P_Mark") then			
			_passiveTarget = HPred:GetObjectByPosition(particle.pos)
		end
	end
end

local _passiveDamagePctByLevel = { .50, .50, .60, .60, .60, .60, .60, .70, .70, .80, .80,.90, .90, 1,1,1,1,1 }
function MissFortune:GetQDamage(target)
	local qDamage= myHero:GetSpellData(_Q).level * 20  + myHero.ap * 0.35+ myHero.totalDamage
	
	--Boost if they dont have love tap on them
	if target ~= _passiveTarget and myHero.levelData then
		local bonusDamage = myHero.totalDamage * _passiveDamagePctByLevel[myHero.levelData.lvl]
		--Passive damage is half to minion
		if not _find(target.type, "Hero") then
			bonusDamage = bonusDamage / 2
		end		
		qDamage = qDamage + bonusDamage
	end
	local qDamage = AutoUtil:CalculatePhysicalDamage(target, qDamage)
	return qDamage
end

function MissFortune:GetQBounce(target)
	local targets = {}
	local bounceTargetingDelay = Q.Delay + HPred:GetDistance(myHero.pos, target.pos) / Q.Speed
	local targetOrigin = HPred:PredictUnitPosition(target, bounceTargetingDelay)
	local topVector = targetOrigin +(targetOrigin - myHero.pos):Perpendicular():Normalized()* 500
	local bottomVector = targetOrigin +(targetOrigin - myHero.pos):Perpendicular2():Normalized()* 500	
			
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t ~= target and HPred:CanTarget(t) then
			local predictedPosition = HPred:PredictUnitPosition(t, bounceTargetingDelay)
			if HPred:IsInRange(targetOrigin, predictedPosition, 500) and not
				HPred:IsInRange(topVector, predictedPosition, 450) and not
				HPred:IsInRange(bottomVector, predictedPosition, 450) and
				HPred:GetDistanceSqr(myHero.pos, t.pos) > HPred:GetDistanceSqr(myHero.pos, target.pos) then
				_insert(targets, {t, HPred:GetDistance(target.pos, predictedPosition)})
			end
		end
	end		
	for i = 1, LocalGameMinionCount() do
		local t = LocalGameMinion(i)
		if t and t ~= target and HPred:CanTarget(t) then
			local predictedPosition = HPred:PredictUnitPosition(t, bounceTargetingDelay)
			if HPred:IsInRange(targetOrigin, predictedPosition, 500) and not
				HPred:IsInRange(topVector, predictedPosition, 450) and not
				HPred:IsInRange(bottomVector, predictedPosition, 450) and
				HPred:GetDistanceSqr(myHero.pos, t.pos) > HPred:GetDistanceSqr(myHero.pos, target.pos) then
				_insert(targets, {t, HPred:GetDistance(target.pos, predictedPosition)})
			end
		end
	end
	
	if #targets > 0 then
		_sort(targets, function( a, b ) return a[2] < b[2] end)
		local t = targets[1][1]
		targets = nil
		return t
	end
end

class "Karthus" 
local _canUltCount = 0
local _targetUltData = {}
local _cachedQs = {}

function Karthus:__init()

	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end

function Karthus:CreateMenu()
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Lay Waste", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true})
	Menu.Skills.Q:MenuElement({id = "AccuracyAuto", name = "Auto Accuracy", value = 4, min = 1, max = 6, step = 1})
	Menu.Skills.Q:MenuElement({id = "AccuracyCombo", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	Menu.Skills.Q:MenuElement({id = "FarmMana", name = "Farm Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "W", name = "[W] Wall of Pain", type = MENU})
	Menu.Skills.W:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true})
	Menu.Skills.W:MenuElement({id = "Combo", name = "Auto Cast in Combo", value = false})
	Menu.Skills.W:MenuElement({id = "Assist", name = "Assist Key",value = false,  key = 0x71})	
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Defile", type = MENU})
	Menu.Skills.E:MenuElement({id = "Auto", name = "Auto Active When Enemy In Range", value = true})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
		
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Requiem", type = MENU})
	Menu.Skills.R:MenuElement({id = "Auto", name = "Auto Use In Passive (If Will Kill)", value = true})
	Menu.Skills.R:MenuElement({id = "Draw", name = "Draw Kill Count", value = true})
	
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })	
end

function Karthus:LoadSpells()
	Q = {Range = 874, Width = 100, Delay = .5, Speed = _huge}
	W = {Range = 1000, Width = 800, Delay = .25, Speed = _huge}
	E = { Range = 425 }
end

function Karthus:Draw()
	if Ready(_R) and _canUltCount > 0 and Menu.Skills.R.Draw:Value() then
		local drawPos = myHero.pos:To2D()
		LocalDrawText("[R] Can Kill " .. _canUltCount .. " Enemies!", 24, 100, 200)
	end	
end

function Karthus:Tick()
	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	Karthus:CacheQs()
	
	--Re-enable auto attacks if we're basically out of mana...
	if (Menu.Skills.Combo:Value() or IsFarming())and CurrentPctMana(myHero) > 15 then
		SetAttack(false)
	else
		SetAttack(true)
	end	
	
	if Ready(_E) then
		Karthus:AutoE()
	end
	
	if Ready(_R) then	
		Karthus:AutoR()
	end
	
	if Ready(_W) then
		Karthus:AutoW()
	end	
	
	if Ready(_Q) then
		Karthus:AutoQ()
		if IsFarming() and CurrentPctMana(myHero) >= Menu.Skills.Q.FarmMana:Value() then
			Karthus:FarmQ()
		end
	end
end

function Karthus:CacheQs()
	local currentTime = Game.Timer()
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and not _cachedQs[particle.networkID] and _find(particle.name,"Karthus_Base_Q_Ring") then
			_cachedQs[particle.networkID] = {}			
			_cachedQs[particle.networkID].data = particle
			_cachedQs[particle.networkID].expires = currentTime + .8
		end
	end
	for _, q in pairs(_cachedQs) do
		if not q or currentTime > q.expires then
			_cachedQs[_] = nil
		end
	end
end


function Karthus:GetQDamage(target)
	if myHero:GetSpellData(_Q).level < 1 then
		return 0
	end
	local damage = 30 + myHero:GetSpellData(_Q).level * 20 + myHero.ap * .3
	return damage
end

function Karthus:FarmQ()
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion and HPred:CanTarget(minion) and HPred:IsInRange(myHero.pos, minion.pos, Q.Range) then
		
			local predictedHealth = minion.health
			if _G.SDK and _G.SDK.HealthPrediction then
				predictedHealth = _G.SDK.HealthPrediction:GetPrediction(minion, Q.Delay)
			end
			local qDamage = self:GetQDamage(minion)
			local predictedDamage = minion.health - predictedHealth
			
			if predictedHealth > 0 and (predictedDamage < 25 or predictedHealth > 25) and qDamage > predictedHealth + 5 then
				local aimPosition = HPred:PredictUnitPosition(minion, Q.Delay)
				local valid = true
				for _, q in pairs(_cachedQs) do
					if HPred:IsInRange(q.data.pos, aimPosition, Q.Width) then
						valid = false
					end
				end
				if valid then					
					SpecialCast(HK_Q, aimPosition)
				end
			end
		end
	end
end

function Karthus:AutoQ()
	local hasCast = false
	if Menu.Skills.Q.Auto:Value() then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
			SpecialCast(HK_Q, aimPosition)
			hasCast = true
		end
	end
	
	if not hasCast and CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() then
		--TODO: Try Killstealing with Q? Will require some extra logic for sure.
		if Menu.Skills.Combo:Value() then
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.AccuracyCombo:Value(), nil)	
			if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
				SpecialCast(HK_Q, aimPosition)
			end
		elseif Menu.Skills.Q.Auto:Value() then
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.AccuracyAuto:Value(), nil)	
			if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
				SpecialCast(HK_Q, aimPosition)
			end
		end
	end	
	
	local hasBuff, timeRemaining = HPred:HasBuff(myHero, "KarthusDeathDefiedBuff")
	if not hasCast and hasBuff then
		local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, 1, nil)	
		if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
			SpecialCast(HK_Q, aimPosition)
		end
	end
end

function Karthus:AutoW()
	--Cast on reliable targets instead
	if Menu.Skills.W.Auto:Value() then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, W.Range, W.Delay, W.Speed,W.Width, Menu.General.ReactionTime:Value(), W.Collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, W.Range) then
			SpecialCast(HK_W, aimPosition)
		end
	end
	
	--If we're pushing the assisted aim W key then find a unreliable target we can hit and cast on them (nearest mouse)
	if Menu.Skills.W.Assist:Value() then		
		local distance, target = AutoUtil:NearestEnemy(myHero)
		if target and distance < W.Range then
			local castPos = HPred:PredictUnitPosition(target, W.Delay)
			if HPred:IsInRange(myHero.pos, castPos, W.Range) then
				SpecialCast(HK_W, castPos)
			end
		end
	end	
	
	if Menu.Skills.Combo:Value() and Menu.Skills.W.Combo:Value() then
		--Get the most targets we can hit?
		local distance, target = AutoUtil:NearestEnemy(myHero)
		if target and distance < W.Range then		
			local castPos = HPred:PredictUnitPosition(target, W.Delay)
			if HPred:IsInRange(myHero.pos, castPos, W.Range / 3 * 2) then
				SpecialCast(HK_W, castPos)
			end
		end
	end
end

local _eActivationTime = 0

function Karthus:AutoE()
	local eData = myHero:GetSpellData(_E)
	local distance, target = AutoUtil:NearestEnemy(myHero)
	if distance < E.Range and Menu.Skills.E.Auto:Value() then
		if eData.toggleState ==1 and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
			_eActivationTime = Game.Timer()
			Control.CastSpell(HK_E)
		elseif eData.toggleState == 2 and _eActivationTime > 0 and CurrentPctMana(myHero) < Menu.Skills.E.Mana:Value() then
			Control.CastSpell(HK_E)
			_eActivationTime = 0		
		end
	--Don't deactivate E if we are the ones who turned it on!
	elseif eData.toggleState == 2 and _eActivationTime > 0 then
		_eActivationTime = 0
		Control.CastSpell(HK_E)
	end
end

function Karthus:AutoR()
	_canUltCount = 0
	local rDamage= 250 + (myHero:GetSpellData(_R).level -1) * 150 + myHero.ap * 0.75
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t ~= nil then
			if HPred:CanTarget(t) then
				_targetUltData[t.charName] = {}
				_targetUltData[t.charName]["LastVisible"] = Game.Timer()
				_targetUltData[t.charName]["Damage"] = AutoUtil:CalculateMagicDamage(t, rDamage)
				_targetUltData[t.charName]["Life"] = t.health + t.hpRegen * 2
			elseif not t.alive and _targetUltData[t.charName] then
				_targetUltData[t.charName] = nil
			end
		end
	end	
	
	for _, target in pairs(_targetUltData) do
		if Game.Timer() - target.LastVisible < 5 and target.Damage > target.Life then
			_canUltCount = _canUltCount + 1		
		end
	end	
	
	local hasBuff, timeRemaining = HPred:HasBuff(myHero, "KarthusDeathDefiedBuff")
	if hasBuff and _canUltCount > 0 and Menu.Skills.R.Auto:Value() and timeRemaining < 4 then	
		Control.CastSpell(HK_R)
	end
end


class "Illaoi" 
local _spirit
local _nextSpiritSearch = Game.Timer()
function Illaoi:__init()

	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
	
	if _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:OnPostAttack(function(args)
			if Ready(_W) and currentMana >= Menu.Skills.W.Mana:Value() then
				local target = HPred:GetEnemyHeroByHandle(myHero.activeSpell.target)				
				if target or (_spirit and _spirit.networkID == myHero.activeSpell.target) then
					Control.CastSpell(HK_W)
				end
			end
		end)
	end
end

function Illaoi:CreateMenu()
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Tentacle Smash", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true})
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
		
	Menu.Skills:MenuElement({id = "W", name = "[W] Harsh Lesson", type = MENU})
	Menu.Skills.W:MenuElement({id = "Auto", name = "Attack Reset In Combo", value = true})
	Menu.Skills.W:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
		
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Test of Spirit", type = MENU})
	Menu.Skills.E:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true})
	Menu.Skills.E:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })	
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Leap of Faith", type = MENU})
	Menu.Skills.R:MenuElement({id = "Count", name = "Target Count", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.R:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })
end

function Illaoi:LoadSpells()
	Q = {Range = 850, Width = 100,Delay = 0.75, Speed = _huge }
	E = {Range = 900, Width = 45, Delay = 0.25, Speed = 1800, Collision = true}
	W = {Range = 350 }
	R = {Range = 450, Delay = 0.5, Speed = _huge}
end

function Illaoi:Draw()
end




function Illaoi:GetSpirit()
	if _nextSpiritSearch > Game.Timer() then return end
	_nextSpiritSearch = Game.Timer() + .25
	
	--Check if it still exists
	if _spirit and _spirit.name == "" then
		_spirit = nil	
	end
	if not _spirit then
		for i = 1, LocalGameParticleCount() do
			local particle = LocalGameParticle(i)	
			if particle then
				local dist =  HPred:GetDistance(particle.pos, myHero.pos)
				if dist > 100 and dist < 800 then
					if particle.name == "Illaoi_Base_E_Spirit" then
						_spirit = particle
						break
					end
				end
			end
		end
	end
end

function Illaoi:Tick()
	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	local currentMana = CurrentPctMana(myHero)
	
	Illaoi:GetSpirit()
	
	local eData = myHero:GetSpellData(_E)
	if Ready(_E) and eData.cd >0  then	
		local hasCast = false
		if Menu.Skills.E.Auto:Value() then
			local target, aimPosition = HPred:GetReliableTarget(myHero.pos, E.Range, E.Delay, E.Speed,E.Width, Menu.General.ReactionTime:Value(), E.Collision)
			if target and not HPred:IsInRange(myHero.pos, aimPosition, E.Range) then
				SpecialCast(HK_E, aimPosition)
				hasCast = true
			end
		end
		if not hasCast and Menu.Skills.Combo:Value() and currentMana >= Menu.Skills.E.Mana:Value() then			
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, E.Range, E.Delay, E.Speed,E.Width, E.Collision, Menu.Skills.E.Accuracy:Value())	
			if hitRate and HPred:IsInRange(myHero.pos, aimPosition, E.Range) then				
				SpecialCast(HK_E, aimPosition, myHero.pos, true)
			end
		end
	end	
	
	if Ready(_Q) and (Menu.Skills.Combo:Value() or (Menu.Skills.Q.Auto:Value() and currentMana >= Menu.Skills.Q.Mana:Value())) then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
		if target and not HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
			SpecialCast(HK_Q, aimPosition)
		elseif Menu.Skills.Combo:Value() then
			--Unreliable Q				
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.Accuracy:Value())	
			if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
				SpecialCast(HK_Q, aimPosition)
			end
		end
	end
	
	if Ready(_R) then		
		local targetCount = AutoUtil:CountEnemiesNear(myHero.pos, R.Range)		
		--Count their spirit as a hero! If we grab then ulting is probably a good idea.
		if _spirit then
			targetCount = targetCount + 1
		end
		if targetCount >= Menu.Skills.R.Count:Value() then
			Control.CastSpell(HK_R)
		end
	end
end






class "Taliyah" 
function Taliyah:__init()
	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end

function Taliyah:CreateMenu()
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Threaded Volley", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true})
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
		
	Menu.Skills:MenuElement({id = "W", name = "[W] Seismic Shove", type = MENU})
	Menu.Skills.W:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true})
	Menu.Skills.W:MenuElement({id = "PeelRange", name = "Push Range", value = 300, min = 100, max = 600, step = 50 })
	Menu.Skills.W:MenuElement({id = "Accuracy", name = "Combo Peel Accuracy", value = 3, min = 1, max = 6, step = 1})
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Unraveled Earth", type = MENU})
	Menu.Skills.E:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true})
	Menu.Skills.E:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })		
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })
end

function Taliyah:LoadSpells()
	Q = {Range = 1000, Width = 45,Delay = 0.25, Speed = 2850, Collision = true }
	W = {Range = 900, Width = 150,Delay = 0.25, Speed = _huge }
	E = {Range = 800, Width = 300,Delay = 0.25, Speed = 2000 }
end

function Taliyah:Draw()	
end

function Taliyah:Tick()
	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	Taliyah:FindW()
	if Ready(_E) then
		Taliyah:AutoE()
	end
	
	if Ready(_W) then
		Taliyah:AutoW()
	end
	
	if Ready(_Q) then
		Taliyah:AutoQ()
	end	
end


function Taliyah:AutoQ()	
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
	if Menu.Skills.Q.Auto:Value() and target and HPred:IsInRange(myHero.pos, aimPosition,Q.Range) then
		SpecialCast(HK_Q, aimPosition)
	--No Reliable target: Check for harass/combo unreliable target instead
	else
		if Menu.Skills.Combo:Value() then
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.Accuracy:Value(), nil)	
			if hitRate and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
				SpecialCast(HK_Q, aimPosition)
			end
		end
	end
end


local _wDirection
local _wCastAt = Game.Timer()
local _wParticle


function Taliyah:FindW()	
	if Game.Timer() - _wCastAt < 1 and not _wParticle then		
		for i = 1, LocalGameParticleCount() do 
			local particle = LocalGameParticle(i)
			if particle and particle.name == "Taliyah_Base_W_indicator_arrow" then
				_wParticle = particle
			end
		end
	elseif _wParticle and _wParticle.name ~= "Taliyah_Base_W_indicator_arrow" then
		_wParticle = nil		
	end
end
function Taliyah:AutoW()
	
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, W.Range, W.Delay, W.Speed,W.Width, Menu.General.ReactionTime:Value(), W.Collision)
	if Menu.Skills.W.Auto:Value() and target and HPred:IsInRange(myHero.pos, aimPosition,W.Range) then
	
		if HPred:IsInRange(myHero.pos, aimPosition, Menu.Skills.W.PeelRange:Value()) then	
		--push them			
			_wDirection = (aimPosition-myHero.pos):Normalized()
			_wCastAt = Game.Timer()
			VectorCast(aimPosition, aimPosition + _wDirection * 100, HK_W)
		else
			_wDirection = (myHero.pos- aimPosition):Normalized()
			_wCastAt = Game.Timer()
			VectorCast(aimPosition, aimPosition + _wDirection * 100, HK_W)
		end
		--receive satisfaction!
	elseif Menu.Skills.Combo:Value() then
		local distance, target = AutoUtil:NearestEnemy(myHero)
		if target and HPred:IsInRange(myHero.pos, target.pos, Menu.Skills.W.PeelRange:Value()) then
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, W.Range, W.Delay, W.Speed, W.Width, W.Collision, Menu.Skills.W.Accuracy:Value(), nil)	
			if hitRate and HPred:IsInRange(myHero.pos, aimPosition, W.Range) then
				--Push them away
				_wDirection = (aimPosition-myHero.pos):Normalized()
				_wCastAt = Game.Timer()
				VectorCast(aimPosition, aimPosition + _wDirection * 100, HK_W)
			end
		end
	end
end

function Taliyah:AutoE()

	--if Game.Timer() - _wCastAt < .6 and  _wParticle then
		--Find a target near it that will be bounced			
	--	local distance, target = AutoUtil:NearestEnemy(_wParticle)
	--	if target and distance < 1200 then			
	--		local origin,movementRadius = HPred:UnitMovementBounds(target, W.Delay - Game.Timer() - _wCastAt, 0)
	--		if HPred:GetDistance(target.pos, _wParticle.pos) + movementRadius <= W.Width then
	--			--Until we have a proper direction this is completely useless... like REALLY bad
	--		end
	--	end
	--end
	local target, aimPosition = HPred:GetGuarenteedTarget(myHero.pos, E.Range, E.Delay, E.Speed,E.Width, Menu.General.ReactionTime:Value(), E.Collision)
	if Menu.Skills.E.Auto:Value() and target and HPred:IsInRange(myHero.pos, aimPosition,E.Range) then		
		
		SpecialCast(HK_Q, aimPosition)
		DelayAction(function()SpecialCast(HK_E, aimPosition) end,.15)
	end
end



class "Kalista" 
function Kalista:__init()

	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end

function Kalista:CreateMenu()
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Pierce", type = MENU})
	--Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Harass Through Minions", value = true})
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
		
	Menu.Skills:MenuElement({id = "E", name = "[E] Rend", type = MENU})
	Menu.Skills.E:MenuElement({id = "Killsteal", name = "Killsteal", value = true})	
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })
end

function Kalista:LoadSpells()
	Q = {Range = 1150, Width = 35,Delay = 0.35, Speed = 2100, Collision = true }
end

function Kalista:Draw()	
end


function Kalista:GetEStacks(target)
	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		if buff.duration > 0 and buff.name == "kalistaexpungemarker" then
			return buff.count
		end
	end
	return 0
end

function Kalista:Tick()
	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	if Ready(_E) and Menu.Skills.E.Killsteal:Value() then
		Kalista:Killsteal()
	end
	if Ready(_Q) and CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() then
		Kalista:AutoQ()
	end
end


function Kalista:AutoQ()	
	if Menu.Skills.Combo:Value() then
		--If we're in combo mode then we want to take the possible heroes in range and assign them a priority based on hitchance and E stacks
		
		local qTargets = {}
		for i = 1, LocalGameHeroCount() do
			local t = LocalGameHero(i)
			if t and HPred:CanTarget(t) and HPred:IsInRange(myHero.pos, t.pos, Q.Range) then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, t, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision)
				if hitRate and hitRate >= Menu.Skills.Q.Accuracy:Value() and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
					_insert(qTargets, {aimPosition, hitRate * self:GetEStacks(t)})
				end
			end
		end
		
		_sort(qTargets, function( a, b ) return a[2] >b[2] end)	
		if #qTargets > 0 then
			local qTarget =qTargets[1][1]
			qTargets = nil
			SpecialCast(HK_Q, qTarget)
		end
	end
end

function Kalista:Killsteal()
	local eDamage= 20 + (myHero:GetSpellData(_E).level -1) * 10 + myHero.totalDamage * 0.6
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and HPred:CanTarget(t) and HPred:IsInRange(myHero.pos, t.pos, 525) then
			--Calculate the damage to this specific target
			local damage = eDamage + self:GetEStacks(t) * myHero.totalDamage * .3
			damage = HPred:CalculatePhysicalDamage(t, damage)
			if damage >= t.health then
				Control.CastSpell(HK_E)
			end
		end
	end
end


class "Azir"
function Azir:__init()

	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)	
end

function Azir:CreateMenu()
	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Conquering Sands", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Combo", name = "Combo Reposition Soldiers", value = true})
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
		
	Menu.Skills:MenuElement({id = "W", name = "[W] Arise!", type = MENU})
	Menu.Skills.W:MenuElement({id = "Combo", name = "Combo Cast", value = true})
	Menu.Skills.W:MenuElement({id = "Save", name = "Save Stacks", value = true})
	Menu.Skills.W:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Shifting Sands", type = MENU})
	Menu.Skills.E:MenuElement({id = "Mana", name = "~~COMING SOON~~", value = 15, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Emperor's Divide", type = MENU})
	Menu.Skills.R:MenuElement({id = "Count", name = "Ult Count", value = 2, min = 1, max = 6, step = 1 })
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })
end

function Azir:LoadSpells()
	Q = {Range = 750, Width = 70,Delay = 0.25, Speed = 3000}
	W = {Range = 525, Width = 375 ,Delay = 0.25, Speed = _huge}
	E = {Range = 1100, Width = 70 ,Delay = 0.25, Speed = 3000}
	R = {Range = 250, Width = 200 ,Delay = 0.25, Speed = 3000}
end

local _cachedSoldiers = {}
local _soldierCount = 0

function Azir:Draw()
end

function Azir:CanExtendAuto(target)
	for _, soldier in pairs(_cachedSoldiers) do
		local targetToSoldierDistance = HPred:GetDistance(target.pos, soldier.data.pos)
		local heroToSoldierDistance = HPred:GetDistance(myHero.pos, soldier.data.pos)
		if targetToSoldierDistance < 375 and heroToSoldierDistance < 750 then
			return true
		end		
	end	
end

function Azir:CacheSoldiers()
	local currentTime = Game.Timer()
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and not _cachedSoldiers[particle.networkID] and _find(particle.name,"P_Soldier_Ring") then
			_cachedSoldiers[particle.networkID] = {}			
			_cachedSoldiers[particle.networkID].data = particle
			_cachedSoldiers[particle.networkID].expires = currentTime + 11
			_soldierCount = _soldierCount + 1
		end
	end
	for _, soldier in pairs(_cachedSoldiers) do
		if not soldier or currentTime > soldier.expires then
			_cachedSoldiers[_] = nil
			_soldierCount = _soldierCount - 1
		end
	end
end

local _lastAutoAttackOrder = Game.Timer()
local _mousePos
function Azir:Tick()	
	Azir:CacheSoldiers()	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
		
	if Ready(_Q) and _soldierCount > 0 then
		Azir:AutoQ()
	end	
	
	if Ready(_R) then
		Azir:AutoR()
	end
		
	if Menu.Skills.Combo:Value() then
		if Ready(_W) then
			Azir:AutoW()
		end
		Azir:AA()
	end
end

function Azir:AA()
	if myHero.attackData.state ~= STATE_WINDUP and myHero.attackData.state ~= STATE_WINDDOWN and Game.Timer() - _lastAutoAttackOrder > .25 then			
		local aaUsed = false
		for i = 1, LocalGameHeroCount() do
			local t = LocalGameHero(i)
			if t and HPred:CanTarget(t) and Azir:CanExtendAuto(t) then
				_lastAutoAttackOrder = Game.Timer()
				_G.Control.Attack(t)
				aaUsed = true
				return true
			end
		end
	end
	return false
end

function Azir:AutoQ()
	--Q soldiers onto immobile
	if Menu.Skills.Q.Auto:Value() then
		local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
		if target and HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then	
			SpecialCast(HK_Q, aimPosition)
		end
	end
	
	--Q soldiers to get them back in AA range
	if Menu.Skills.Combo:Value() and Menu.Skills.Q.Combo:Value() and CurrentPctMana(myHero) > Menu.Skills.Q.Mana:Value() then
		local target = CurrentTarget(Q.Range)
		if target and not Azir:CanExtendAuto(target) then			
			local aimPosition = HPred:PredictUnitPosition(target, .35)
			if HPred:IsInRange(myHero.pos, aimPosition, Q.Range) then
				SpecialCast(HK_Q, target.pos)
			end
		end
	end	
	
end

function Azir:AutoW()
	local target = CurrentTarget(Q.Range)
	if Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() and target and HPred:CanTarget(target) and (not Azir:CanExtendAuto(target) or not Menu.Skills.W.Save:Value()) then			
		local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, target,W.Range, W.Delay, W.Speed, W.Width)
		if hitChance and hitChance >= 2 then
			SpecialCast(HK_W, aimPosition)
		end
	end
end

function Azir:AutoR()	
	if Menu.Skills.Combo:Value() then
		local distance, target = AutoUtil:NearestEnemy(myHero)
		if target and distance < R.Range then
			local aimPos = HPred:PredictUnitPosition(target, R.Delay)
			local targetCount = HPred:GetLineTargetCount(myHero.pos, aimPos, R.Delay, R.Speed, R.Width)
			if targetCount >= Menu.Skills.R.Count:Value() then
				SpecialCast(HK_R, aimPos)
			end
		end
	end
end

class "Thresh"
function Thresh:__init()
	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end

function Thresh:CreateMenu()
	Menu.General:MenuElement({id = "DrawQAim", name = "Draw Q Aim", value = true})
	
	AutoUtil:SupportMenu(Menu)	
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Death Sentence", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Targets", name = "Targets", type = MENU})	
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.Q.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
		end
	end
	Menu.Skills.Q:MenuElement({id = "Immobile", name = "Auto Hook Immobile", value = true})
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.Q:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
		
	Menu.Skills:MenuElement({id = "W", name = "[W] Dark Passage", type = MENU})
	Menu.Skills.W:MenuElement({id = "Auto", name = "Auto Lantern On Q2", value = true})
	Menu.Skills.W:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	
	Menu.Skills:MenuElement({id = "E", name = "[E] Flay", type = MENU})	
	Menu.Skills.E:MenuElement({id = "Targets", name = "Auto Peel Targets", type = MENU})	
	for i = 1, LocalGameHeroCount() do
		local hero = LocalGameHero(i)
		if hero and hero.isEnemy then
			Menu.Skills.E.Targets:MenuElement({id = hero.charName, name = hero.charName, value = true })
		end
	end
	Menu.Skills.E:MenuElement({id = "PeelRange", name = "Auto Peel Range", value = 300, min = 100, max = 600, step = 50 })	
	Menu.Skills.E:MenuElement({id = "Accuracy", name = "Combo Accuracy", value = 2, min = 1, max = 6, step = 1})
	Menu.Skills.E:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })
	
	Menu.Skills:MenuElement({id = "R", name = "[R] The Box", type = MENU})
	Menu.Skills.R:MenuElement({id = "Count", name = "Target Count", value = 3, min = 1, max = 6, step = 1})
	Menu.Skills.R:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 5, max = 100, step = 5 })	
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })
end

function Thresh:LoadSpells()
	Q = {Range = 1100, Width = 55,Delay = 0.5, Speed = 1900,  Collision = true}
	W = {Range = 950 }
	E = {Range = 400, Width = 95,Delay = 0.389, Speed = _huge }
	R = {Range = 450 }
end

function Thresh:Draw()	
	if Ready(_Q) and Menu.General.DrawQAim:Value() and forcedTarget and forcedTarget.alive and forcedTarget.visible then	
		local targetOrigin = HPred:PredictUnitPosition(forcedTarget, Q.Delay)
		local interceptTime = HPred:GetSpellInterceptTime(myHero.pos, targetOrigin, Q.Delay, Q.Speed)			
		local origin, radius = HPred:UnitMovementBounds(forcedTarget, interceptTime, Menu.General.ReactionTime:Value())		
						
		if radius < 25 then
			radius = 25
		end
		
		if HPred:IsInRange(myHero.pos, origin, Q.Range) then
			LocalDrawCircle(origin, 25,10, LocalDrawColor(150, 0, 255,0))
		else
			LocalDrawCircle(origin, 25,10, LocalDrawColor(150, 255, 0,0))
			LocalDrawCircle(origin, radius,1, LocalDrawColor(150, 255, 255,255))	
		end
	end	
end

--Save a whitelist. Save it only once per 5 seconds: Todo onchange event for menu elements...
local _qWhitelist = {}
local _eWhitelist = {}
local _nextWhitelistUpdate = Game.Timer()
function Thresh:UpdateHookWhitelist()
	if _nextWhitelistUpdate > Game.Timer() then return end
	_nextWhitelistUpdate = Game.Timer() + 5
	_qWhitelist = nil
	_eWhitelist = nil
	_qWhitelist = {}
	_eWhitelist = {}
	for i  = 1,LocalGameHeroCount(i) do
		local enemy = LocalGameHero(i)
		if enemy and Menu.Skills.Q.Targets[enemy.charName] and Menu.Skills.Q.Targets[enemy.charName]:Value() then
			_qWhitelist[enemy.charName] = true
		end
		if enemy and Menu.Skills.E.Targets[enemy.charName] and Menu.Skills.E.Targets[enemy.charName]:Value() then
			_eWhitelist[enemy.charName] = true
		end
	end
end
function Thresh:Tick()	
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	Thresh:UpdateHookWhitelist()
	
	if Ready(_W) and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() then
		Thresh:AutoW()
	end
	
	if Ready(_Q) then
		Thresh:AutoQ()
	end	
	
	if Ready(_E) and CurrentPctMana(myHero) >= Menu.Skills.E.Mana:Value() then
		Thresh:AutoE()
	end
	
	if Ready(_R) and CurrentPctMana(myHero) >= Menu.Skills.R.Mana:Value() then		
		local targetCount = AutoUtil:CountEnemiesNear(myHero.pos, R.Range)
		if targetCount >= Menu.Skills.R.Count:Value() then
			Control.CastSpell(HK_R)
			NextSpellCast = .35 + Game.Timer()
		end
	end
	
	AutoUtil:UseSupportItems()
end

function Thresh:AutoQ()
	local qData = myHero:GetSpellData(_Q)
	if qData.name == "ThreshQ" and qData.currentCd == 0 then
		if Menu.Skills.Q.Immobile:Value() then
			local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
			if target then
				SpecialCast(HK_Q, aimPosition)
			end
		end
		
		if Menu.Skills.Combo:Value() and CurrentPctMana(myHero) >= Menu.Skills.Q.Mana:Value() then						
			local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed, Q.Width, Q.Collision, Menu.Skills.Q.Accuracy:Value(),_qWhitelist)	
			if hitRate then
				SpecialCast(HK_Q, aimPosition)
			end
		end
	end
end

function Thresh:AutoW()
	if myHero.pathing and myHero.pathing.hasMovePath and myHero.pathing.isDashing and myHero.pathing.dashSpeed>500 then
		for i = 1, LocalGameHeroCount() do
			local ally = LocalGameHero(i)
			if ally and ally ~= myHero and ally.isAlly and HPred:IsInRange(myHero.pos, ally.pos, W.Range) then
				local castPos = HPred:PredictUnitPosition(ally, .35)
				Control.CastSpell(HK_W, castPos, true)
				break
			end
		end
	end
end

function Thresh:AutoE()
	--Don't auto E if our Q is already launched or it wastes CC time... there are some ccases where this might be useful but lets leave out for now.	
	local qData = myHero:GetSpellData(_Q)
	if qData.name == "ThreshQLeap" then return end	
	--Auto interrupt channeling targets by pushing them away
	
	local target, aimPosition =HPred:GetChannelingTarget(myHero.pos, E.Range, E.Delay, E.Speed, Menu.General.ReactionTime:Value(), E.Collision, E.Width)
	if target and aimPosition then
		Control.CastSpell(HK_E, aimPosition, true)
		return
	end
	local target, aimPosition =HPred:GetDashingTarget(myHero.pos, E.Range, E.Delay, E.Speed, Menu.General.ReactionTime:Value(), E.Collision, E.Width)
	if target and aimPosition then
		aimPosition = myHero.pos + (myHero.pos - aimPosition):Normalized() * 250
		Control.CastSpell(HK_E, aimPosition, true)
		return
	end
	
	--Peel enemies away from us!
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and HPred:CanTarget(enemy) and HPred:IsInRange(myHero.pos, enemy.pos, Menu.Skills.E.PeelRange:Value()) and _eWhitelist[enemy.charName] then
			Control.CastSpell(HK_E, enemy.pos)
			return	
		end
	end
	
	--pull enemies towards us
	if Menu.Skills.Combo:Value() then		
		
		for i = 1, LocalGameHeroCount() do
			local enemy = LocalGameHero(i)
			if enemy and HPred:CanTarget(enemy) and HPred:IsInRange(myHero.pos, enemy.pos, E.Range) then
				local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, enemy,E.Range, E.Delay, E.Speed, E.Width)
				if aimPosition and hitChance and hitChance >= Menu.Skills.E.Accuracy:Value() then
					--If they aren't in the list of targets we want to push away then instead we should pull them!
					if not _eWhitelist[enemy.charName] then
						aimPosition = myHero.pos + (myHero.pos - aimPosition):Normalized() * 250
					end
					SpecialCast(HK_E, aimPosition)
					return
				end
			end
		end
	end	
end


class "AurelionSol"
function AurelionSol:__init()
	print("Loaded [Auto] ".. myHero.charName)
	self:LoadSpells()
	self:CreateMenu()
	BotTick = self.Tick;
	Callback.Add("Draw", function() self:Draw() end)
end

function AurelionSol:CreateMenu()
	
			
	
	Menu.Skills:MenuElement({id = "Q", name = "[Q] Starsurge", type = MENU})
	Menu.Skills.Q:MenuElement({id = "Auto", name = "Auto Cast on Immobile", value = true })
	Menu.Skills.Q:MenuElement({id = "Detonate", name = "Auto Detonate", value = true })
	Menu.Skills.Q:MenuElement({id = "Accuracy", name = "Accuracy", value = 3, min = 1, max = 6, step =1 })
	
	Menu.Skills:MenuElement({id = "W", name = "[W] Celestial Expansion", type = MENU})
	Menu.Skills.W:MenuElement({id = "Auto", name = "Auto Toggle", value = true })
	Menu.Skills.W:MenuElement({id = "Mana", name = "Mana Limit", value = 15, min = 1, max = 100, step = 5 })
	Menu.Skills.W:MenuElement({id = "Duration", name = "Minimum Time Enabled", value = 3, min = .5, max = 10, step = .5 })
	
	Menu.Skills:MenuElement({id = "R", name = "[R] Voice of Light", type = MENU})
	Menu.Skills.R:MenuElement({id = "Killsteal", name = "Killsteal", value = true })
	Menu.Skills.R:MenuElement({id = "Auto", name = "Auto Peel", value = true })
	Menu.Skills.R:MenuElement({id = "Radius", name = "Auto Peel Radius", value = 300, min = 100, max = 600, step = 25 })
	
	Menu.Skills:MenuElement({id = "Combo", name = "Combo Key",value = false,  key = string.byte(" ") })	
end

function AurelionSol:LoadSpells()
	Q = {	Range = 600,	Delay = 0.25,	Speed = 1075,	Width = 210	}
	W = {	Range = 650	}
	R = {	Range = 1500,	Delay = 0.35,	Speed = 4285,	Width = 120	}
end

function AurelionSol:Draw()
end

local qMissile
function AurelionSol:Tick()
	if myHero.dead or  IsRecalling()  or IsEvading() or IsAttacking() or IsDelaying() then return end
	if NextSpellCast > Game.Timer() then return end
	
	AurelionSol:SetAA()
	AurelionSol:FindQ()
	
	if Ready(_W) then
		AurelionSol:AutoW()
	end
	
	if Ready(_Q) then
		AurelionSol:AutoQ()
	end

	if Ready(_R) and Menu.Skills.R.Killsteal:Value() then
		AurelionSol:Killsteal()
	end
	
	if Ready(_R) and Menu.Skills.R.Auto:Value() then
		local distance, enemy = AutoUtil:NearestEnemy(myHero)		
		if enemy and distance < Menu.Skills.R.Radius:Value() then
			local castPosition = HPred:PredictUnitPosition(enemy, R.Delay)
			--Check if we can cast Q in that direction first
			if Ready(_Q) then
				SpecialCast(HK_Q, castPosition)
				DelayAction(function()SpecialCast(HK_R, castPosition, true) end,.15)
			else
				SpecialCast(HK_R, castPosition)
			end	
		end
	end
	
	if qMissile and Menu.Skills.Q.Detonate:Value() then		
		local distance, enemy = AutoUtil:NearestEnemy(qMissile)
		if enemy and distance < 200 then
			SpecialCast(HK_Q)
		end
	end
	
end

function AurelionSol:Killsteal()
	local rDamage= 50 + myHero:GetSpellData(_R).level * 100 + myHero.ap * 0.7
	for i  = 1,LocalGameHeroCount(i) do
		local enemy = LocalGameHero(i)
		if enemy and HPred:CanTarget(enemy) and HPred:IsInRange(myHero.pos, enemy.pos, R.Range) then
			local castPosition = HPred:PredictUnitPosition(enemy, R.Delay)			
			local damage = AutoUtil:CalculateMagicDamage(enemy, rDamage)
			if damage >= enemy.health and HPred:IsInRange(myHero.pos, castPosition, R.Range) then
				SpecialCast(HK_R, castPosition)
				return
			end
		end
	end
end

function AurelionSol:SetAA()
	local allowAA = true	
	if Menu.Skills.Combo:Value() and self:IsWActive() then
		local target = CurrentTarget(W.Range)
		if target then
			local distance = HPred:GetDistance(myHero.pos, target.pos)
			if distance > 400 and distance < 800 then
				allowAA = false
			end
		end
	end	
	SetAttack(allowAA)
end


function AurelionSol:IsWActive()	
	local wData = myHero:GetSpellData(_W)
	return wData.toggleState ~= 0
end

local _wActivationTime = 0
function AurelionSol:AutoW()
	local wData = myHero:GetSpellData(_W)
	local distance, target = AutoUtil:NearestEnemy(myHero)
	if distance < 800 and distance > 400 and Menu.Skills.W.Auto:Value() then
		if wData.toggleState ==0 and CurrentPctMana(myHero) >= Menu.Skills.W.Mana:Value() then
			_wActivationTime = Game.Timer()
			Control.CastSpell(HK_W)
		elseif wData.toggleState == 2 and _wActivationTime > 0 and CurrentPctMana(myHero) < Menu.Skills.W.Mana:Value() then
			Control.CastSpell(HK_W)
			_wActivationTime = 0		
		end
		
	--Don't deactivate W if we are the ones who turned it on!
	elseif wData.toggleState == 2 and _wActivationTime > 0 and Game.Timer() - _wActivationTime > Menu.Skills.W.Duration:Value() then
		_wActivationTime = 0
		Control.CastSpell(HK_W)
	end
end

function AurelionSol:AutoQ()
	local target, aimPosition = HPred:GetReliableTarget(myHero.pos, Q.Range, Q.Delay, Q.Speed,Q.Width, Menu.General.ReactionTime:Value(), Q.Collision)
	if target and HPred:IsInRange(myHero.pos, aimPosition, 800) then
		SpecialCast(HK_Q, aimPosition)
	end
	local hitRate, aimPosition = HPred:GetUnreliableTarget(myHero.pos, Q.Range , Q.Delay, Q.Speed,Q.Width,Q.Collision, Menu.Skills.Q.Accuracy:Value())
	if hitRate then
		SpecialCast(HK_Q, aimPosition)
	end
end

function AurelionSol:FindQ()
	
	if qMissile and qMissile.name ~= "AurelionSolQMissile" then
		qMissile = nil
	end
	local qData = myHero:GetSpellData(_Q)
	if qData.toggleState == 2 and not qMissile then
		for i = 1, LocalGameMissileCount() do
			local missile = LocalGameMissile(i)
			if missile and missile.name == "AurelionSolQMissile" and HPred:IsInRange(missile.pos, myHero.pos, 400) then
				qMissile = missile
				break
			end
		end
	end
end




--[[
		GENERAL API
	
	HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
		Usage Purpose
			Wrapper method to find an enemy who can be very reliably hit. Includes hourglas, teleport, blink, dash, CC and more.
			Returns target, aimPosition
		Param Description
			Source: Where the spell will be cast from
			Range: How far away to search for targets (max spell range)
			Delay: How long it will take for the spell to cast
			Speed: How fast the spell will travel
			Radius: How wide the spell is for hitbox calculations
			TimingAccuracy: General accuracy setting. This is how long after a hourglass/teleport/etc we can allow the spell to hit. I suggest ~0.25 seconds
			CheckCollision: Determines if a linear skillshot can be body blocked by minions or other heroes
			
	HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist)
		Usage Purpose
			Finds any target in range who can be hit with at least 'minimumHitChance' of accuracy. Used as a wrapper for HPred:GetHitchance
			Returns target, aimPosition
		Param Description
			Source: Where the spell will be cast from
			Range: How far away to search for targets (max spell range)
			Delay: How long it will take for the spell to cast
			Speed: How fast the spell will travel
			Radius: How wide the spell is for hitbox calculations
			CheckCollision: Determines if a linear skillshot can be body blocked by minions or other heroes
			MinimumHitChance: How confident must we be that the target can be hit for the target to qualify. Recommend accuracy of 3 on almost all skills
				-1 	=	Invalid Target
				1	=	Standard accuracy
				2	=	Target is standing still or has changed movement path within the past 0.25 seconds
				3	=	The target is auto attacking and our spell will give them little time to react in order to dodge
				4	=	The target is using a spell and our spell will give them virtually no time in order to dodge
				5	=	The target should not be able to dodge without using movement skills
				
	HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision)
		Usage Purpose
			Determines the hitchance of a spell on a specified target and where to aim the spell
			Returns hitChance, aimPosition
		Param Description
			Source: Where the spell will be cast from
			Target: What entity are we trying to hit
			Range: How far away to search for targets (max spell range)
			Delay: How long it will take for the spell to cast
			Speed: How fast the spell will travel
			Radius: How wide the spell is for hitbox calculations
			CheckCollision: Determines if a linear skillshot can be body blocked by minions or other heroes
			
	HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
		Usage Purpose
			Determines how many targets will be hit if we cast a linear spell at a specified location - Can specify if the targets are enemies or allies
			Returns total target count
			
			
	HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
		UsagePurpose
			Simplified version of GetReliableTarget - will only check for hourglass, revive, teleport and CCd targets. Useful for high priority skills where you don't want to cast it every time an enemy dashes
			
]]


class "HPred"

local _atan = math.atan2
local _pi = math.pi
local _max = math.max
local _min = math.min
local _abs = math.abs
local _sqrt = math.sqrt
local _find = string.find
local _sub = string.sub
local _len = string.len
	
local _tickFrequency = .2
local _nextTick = Game.Timer()
local _reviveLookupTable = 
	{ 
		["LifeAura.troy"] = 4, 
		["ZileanBase_R_Buf.troy"] = 3,
		["Aatrox_Base_Passive_Death_Activate"] = 3
		
		--TwistedFate_Base_R_Gatemarker_Red
			--String match would be ideal.... could be different in other skins
	}

--Stores a collection of spells that will cause a character to blink
	--Ground targeted spells go towards mouse castPos with a maximum range
	--Hero/Minion targeted spells have a direction type to determine where we will land relative to our target (in front of, behind, etc)
	
--Key = Spell name
--Value = range a spell can travel, OR a targeted end position type, OR a list of particles the spell can teleport to	
local _blinkSpellLookupTable = 
	{ 
		["EzrealArcaneShift"] = 475, 
		["RiftWalk"] = 500,
		
		--Ekko and other similar blinks end up between their start pos and target pos (in front of their target relatively speaking)
		["EkkoEAttack"] = 0,
		["AlphaStrike"] = 0,
		
		--Katarina E ends on the side of her target closest to where her mouse was... 
		--["KatarinaE"] = -255,
		
		--Katarina can target a dagger to teleport directly to it: Each skin has a different particle name. This should cover all of them.
		--["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, 
	}

local _blinkLookupTable = 
	{ 
		"global_ss_flash_02.troy",
		"Lissandra_Base_E_Arrival.troy",
		"LeBlanc_Base_W_return_activation.troy"
		--TODO: Check if liss/leblanc have diff skill versions. MOST likely dont but worth checking for completion sake
		
		--Zed uses 'switch shadows'... It will require some special checks to choose the shadow he's going TO not from...
		--Shaco deceive no longer has any particles where you jump to so it cant be tracked (no spell data or particles showing path)
		
	}

local _cachedBlinks = {}
local _cachedRevives = {}
local _cachedTeleports = {}

--Cache of all TARGETED missiles currently running
local _cachedMissiles = {}
local _incomingDamage = {}

--Cache of active enemy windwalls so we can calculate it when dealing with collision checks
local _windwall
local _windwallStartPos
local _windwallWidth

local _OnVision = {}
function HPred:OnVision(unit)
	if unit == nil or type(unit) ~= "userdata" then return end
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {visible = unit.visible , tick = GetTickCount(), pos = unit.pos } end
	if _OnVision[unit.networkID].visible == true and not unit.visible then _OnVision[unit.networkID].visible = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].visible == false and unit.visible then _OnVision[unit.networkID].visible = true _OnVision[unit.networkID].tick = GetTickCount() _OnVision[unit.networkID].pos = unit.pos end
	return _OnVision[unit.networkID]
end

--This must be called manually - It's not on by default because we've tracked down most of the freeze issues to this.
function HPred:Tick()
	
	
	--Update missile cache
	--DISABLED UNTIL LATER.
	--self:CacheMissiles()
	
	--Limit how often tick logic runs
	if _nextTick > Game.Timer() then return end
	_nextTick = Game.Timer() + _tickFrequency
	
	--Update hero movement history	
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			if t.isEnemy then
				HPred:OnVision(t)
			end
		end
	end
	
	--Do not run rest of logic until freeze issues are fully tracked down
	if true then return end
	
	
	--Remove old cached teleports	
	for _, teleport in pairs(_cachedTeleports) do
		if teleport and Game.Timer() > teleport.expireTime + .5 then
			_cachedTeleports[_] = nil
		end
	end	
	
	--Update teleport cache
	HPred:CacheTeleports()	
	
	
	--Record windwall
	HPred:CacheParticles()
	
	--Remove old cached revives
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	--Remove old cached blinks
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		--Record revives
		if particle and not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then
			_cachedRevives[particle.networkID] = {}
			_cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedRevives[particle.networkID]["target"] = target
				_cachedRevives[particle.networkID]["pos"] = target.pos
				_cachedRevives[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
		
		--Record blinks
		if particle and not _cachedBlinks[particle.networkID] and  _blinkLookupTable[particle.name] then
			_cachedBlinks[particle.networkID] = {}
			_cachedBlinks[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedBlinks[particle.networkID]["target"] = target
				_cachedBlinks[particle.networkID]["pos"] = target.pos
				_cachedBlinks[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
	end
	
end

function HPred:GetEnemyNexusPosition()
	--This is slightly wrong. It represents fountain not the nexus. Fix later.
	if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end
end


function HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
end


function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--TODO: Target whitelist. This will target anyone which is definitely not what we want
	--For now we can handle in the champ script. That will cause issues with multiple people in range who are goood targets though.
	
	
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get channeling enemies
	--local target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	--	if target and aimPosition then
	--	return target, aimPosition
	--end
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get instant dash enemies
	local target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get dashing enemies
	local target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get blink targets
	local target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
end

--Will return how many allies or enemies will be hit by a linear spell based on current waypoint data.
function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
	local targetCount = 0
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then
			
			local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			if proj1 and isOnSegment and self:IsInRange(predictedPos, proj1, t.boundingRadius + width) then
				targetCount = targetCount + 1
			end
		end
	end
	return targetCount
end

--Will return the valid target who has the highest hit chance and meets all conditions (minHitChance, whitelist check, etc)
function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist, isLine)
	local _validTargets = {}
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)		
		if t and self:CanTarget(t, true) and (not whitelist or whitelist[t.charName]) then
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision, isLine)		
			if hitChance >= minimumHitChance then
				_insert(_validTargets, {aimPosition,hitChance, hitChance * 100 + AutoUtil:CalculateMagicDamage(t, 400)})
			end
		end
	end	
	_sort(_validTargets, function( a, b ) return a[3] >b[3] end)	
	if #_validTargets > 0 then	
		return _validTargets[1][2], _validTargets[1][1]
	end
end

function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision, isLine)

	if isLine == nil and checkCollision then
		isLine = true
	end
	
	local hitChance = 1
	local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed)	
	local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed)
	local reactionTime = self:PredictReactionTime(target, .1, isLine)
	
	--Check if they are walking the same path as the line or very close to it
	if isLine then
		local pathVector = aimPosition - target.pos
		local castVector = (aimPosition - myHero.pos):Normalized()
		if pathVector.x + pathVector.z ~= 0 then
			pathVector = pathVector:Normalized()
			if pathVector:DotProduct(castVector) < -.85 or pathVector:DotProduct(castVector) > .85 then
				if speed > 3000 then
					reactionTime = reactionTime + .2
				else
					reactionTime = reactionTime + .10
				end
			end
		end
	end			

	--If they are standing still give a higher accuracy because they have to take actions to react to it
	if not target.pathing or not target.pathing.hasMovePath then
		hitChance = 2
	end
	
	local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
	--Our spell is so wide or the target so slow or their reaction time is such that the spell will be nearly impossible to avoid
	if movementRadius - target.boundingRadius <= radius /2 then
		origin,movementRadius = self:UnitMovementBounds(target, interceptTime, 0)
		if movementRadius - target.boundingRadius <= radius /2 then
			hitChance = 4
		else		
			hitChance = 3
		end
	end	
	
	--If they are casting a spell then the accuracy will be fairly high. if the windup is longer than our delay then it's quite likely to hit. 
	--Ideally we would predict where they will go AFTER the spell finishes but that's beyond the scope of this prediction
	if target.activeSpell and target.activeSpell.valid then
		if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then
			hitChance = 4
		else			
			hitChance = 3
		end
	end
	
	local visionData = HPred:OnVision(target)
	if visionData and visionData.visible == false then
		local hiddenTime = visionData.tick -GetTickCount()
		if hiddenTime < -1000 then
			hitChance = -1
		else
			local targetSpeed = self:GetTargetMS(target)
			local unitPos = target.pos + Vector(target.pos,target.posTo):Normalized() * ((GetTickCount() - visionData.tick)/1000 * targetSpeed)
			local aimPosition = unitPos + Vector(target.pos,target.posTo):Normalized() * (targetSpeed * (delay + (self:GetDistance(myHero.pos,unitPos)/speed)))
			if self:GetDistance(target.pos,aimPosition) > self:GetDistance(target.pos,target.posTo) then aimPosition = target.posTo end
			hitChance = _min(hitChance, 2)
		end
	end
	
	--Check for out of range
	if not self:IsInRange(source, aimPosition, range) then
		hitChance = -1
	end
	
	--Check minion block
	if hitChance > 0 and checkCollision then
		if self:IsWindwallBlocking(source, aimPosition) then
			hitChance = -1		
		elseif self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then
			hitChance = -1
		end
	end
	
	return hitChance, aimPosition
end

function HPred:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	
	--If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end	
	return reactionTime
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)

	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if self:IsInRange(source, dashEndPosition, range) then				
				--The dash ends within range of our skill. We now need to find if our spell can connect with them very close to the time their dash will end
				local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(source, dashEndPosition, delay, speed)
				local deltaInterceptTime =skillInterceptTime - dashTimeRemaining
				if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then
					target = t
					aimPosition = dashEndPosition
					return target, aimPosition
				end
			end			
		end
	end
end

function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy then		
			local success, timeRemaining = self:HasBuff(t, "zhonyasringshield")
			if success then
				local spellInterceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
				local deltaInterceptTime = spellInterceptTime - timeRemaining
				if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = t
					aimPosition = t.pos
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for _, revive in pairs(_cachedRevives) do	
		if revive.isEnemy then
			local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
			if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then
				target = revive.target
				aimPosition = revive.pos
				return target, aimPosition
			end
		end
	end	
end

function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then
			local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer()
			if windupRemaining > 0 then
				local endPos
				local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
				if type(blinkRange) == "table" then
					--Find the nearest matching particle to our mouse
					--local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange)
					--if target and distance < 250 then					
					--	endPos = target.pos		
					--end
				elseif blinkRange > 0 then
					endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)					
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * _min(self:GetDistance(t.activeSpell.startPos,endPos), range)
				else
					local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
					if blinkTarget then				
						local offsetDirection						
						
						--We will land in front of our target relative to our starting position
						if blinkRange == 0 then				

							if t.activeSpell.name ==  "AlphaStrike" then
								windupRemaining = windupRemaining + .75
								--TODO: Boost the windup time by the number of targets alpha will hit. Need to calculate the exact times this is just rough testing right now
							end						
							offsetDirection = (blinkTarget.pos - t.pos):Normalized()
						--We will land behind our target relative to our starting position
						elseif blinkRange == -1 then						
							offsetDirection = (t.pos-blinkTarget.pos):Normalized()
						--They can choose which side of target to come out on , there is no way currently to read this data so we will only use this calculation if the spell radius is large
						elseif blinkRange == -255 then
							if radius > 250 then
								endPos = blinkTarget.pos
							end							
						end
						
						if offsetDirection then
							endPos = blinkTarget.pos - offsetDirection * blinkTarget.boundingRadius
						end
						
					end
				end	
				
				local interceptTime = self:GetSpellInterceptTime(source, endPos, delay,speed)
				local deltaInterceptTime = interceptTime - windupRemaining
				if self:IsInRange(source, endPos, range) and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
					target = t
					aimPosition = endPos
					return target,aimPosition					
				end
			end
		end
	end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	local target
	local aimPosition
	for _, particle in pairs(_cachedBlinks) do
		if particle  and self:IsInRange(source, particle.pos, range) then
			local t = particle.target
			local pPos = particle.pos
			if t and t.isEnemy and (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
				target = t
				aimPosition = pPos
				return target,aimPosition
			end
		end		
	end
end

function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if self:CanTarget(t) and self:IsInRange(source, t.pos, range) and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos	
				return target, aimPosition
			end
		end
	end
end

function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTarget(t) and self:IsInRange(source, t.pos, range) then
			local immobileTime = self:GetImmobileTime(t)
			
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos
				return target, aimPosition
			end
		end
	end
end

function HPred:CacheTeleports()
	--Get enemies who are teleporting to towers
	for i = 1, LocalGameTurretCount() do
		local turret = LocalGameTurret(i);
		if turret and turret.isEnemy and not _cachedTeleports[turret.networkID] then
			local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
			if hasBuff then
				self:RecordTeleport(turret, self:GetTeleportOffset(turret.pos,223.31),expiresAt)
			end
		end
	end	
	
	--Get enemies who are teleporting to wards	
	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.isEnemy and not _cachedTeleports[ward.networkID] then
			local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
			if hasBuff then
				self:RecordTeleport(ward, self:GetTeleportOffset(ward.pos,100.01),expiresAt)
			end
		end
	end
	
	--Get enemies who are teleporting to minions
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion and minion.isEnemy and not _cachedTeleports[minion.networkID] then
			local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
			if hasBuff then
				self:RecordTeleport(minion, self:GetTeleportOffset(minion.pos,143.25),expiresAt)
			end
		end
	end	
end

function HPred:RecordTeleport(target, aimPos, endTime)
	_cachedTeleports[target.networkID] = {}
	_cachedTeleports[target.networkID]["target"] = target
	_cachedTeleports[target.networkID]["aimPos"] = aimPos
	_cachedTeleports[target.networkID]["expireTime"] = endTime + Game.Timer()
end


function HPred:CalculateIncomingDamage()
	_incomingDamage = {}
	local currentTime = Game.Timer()
	for _, missile in pairs(_cachedMissiles) do
		if missile then 
			local dist = self:GetDistance(missile.data.pos, missile.target.pos)			
			if missile.name == "" or currentTime >= missile.timeout or dist < missile.target.boundingRadius then
				_cachedMissiles[_] = nil
			else
				if not _incomingDamage[missile.target.networkID] then
					_incomingDamage[missile.target.networkID] = missile.damage
				else
					_incomingDamage[missile.target.networkID] = _incomingDamage[missile.target.networkID] + missile.damage
				end
			end
		end
	end	
end

function HPred:GetIncomingDamage(target)
	local damage = 0
	if _incomingDamage[target.networkID] then
		damage = _incomingDamage[target.networkID]
	end
	return damage
end


local _maxCacheRange = 3000

--Right now only used to cache enemy windwalls
function HPred:CacheParticles()	
	if _windwall and _windwall.name == "" then
		_windwall = nil
	end
	
	for i = 1, LocalGameParticleCount() do
		local particle = LocalGameParticle(i)		
		if particle and self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then			
			if _find(particle.name, "W_windwall%d") and not _windwall then
				--We don't care about ally windwalls for now
				local owner =  self:GetObjectByHandle(particle.handle)
				if owner and owner.isEnemy then
					_windwall = particle
					_windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)				
					
					local index = _len(particle.name) - 5
					local spellLevel = _sub(particle.name, index, index) -1
					--Simple fix
					if type(spellLevel) ~= "number" then
						spellLevel = 1
					end
					_windwallWidth = 150 + spellLevel * 25					
				end
			end
		end
	end
end

function HPred:CacheMissiles()
	local currentTime = Game.Timer()
	for i = 1, LocalGameMissileCount() do
		local missile = LocalGameMissile(i)
		if missile and not _cachedMissiles[missile.networkID] and missile.missileData then
			--Handle targeted missiles
			if missile.missileData.target and missile.missileData.owner then
				local missileName = missile.missileData.name
				local owner =  self:GetObjectByHandle(missile.missileData.owner)	
				local target =  self:GetObjectByHandle(missile.missileData.target)		
				if owner and target and _find(target.type, "Hero") then			
					--The missile is an auto attack of some sort that is targeting a player	
					if (_find(missileName, "BasicAttack") or _find(missileName, "CritAttack")) then
						--Cache it all and update the count
						_cachedMissiles[missile.networkID] = {}
						_cachedMissiles[missile.networkID].target = target
						_cachedMissiles[missile.networkID].data = missile
						_cachedMissiles[missile.networkID].danger = 1
						_cachedMissiles[missile.networkID].timeout = currentTime + 1.5
						
						local damage = owner.totalDamage
						if _find(missileName, "CritAttack") then
							--Leave it rough we're not that concerned
							damage = damage * 1.5
						end						
						_cachedMissiles[missile.networkID].damage = self:CalculatePhysicalDamage(target, damage)
					end
				end
			end
		end
	end
end

function HPred:CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

function HPred:CalculateMagicDamage(target, damage)
	local targetMR = target.magicResist - target.magicResist * myHero.magicPenPercent - myHero.magicPen
	local damageReduction = 100 / ( 100 + targetMR)
	if targetMR < 0 then
		damageReduction = 2 - (100 / (100 - targetMR))
	end		
	damage = damage * damageReduction
	
	return damage
end


function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)

	local target
	local aimPosition
	for _, teleport in pairs(_cachedTeleports) do
		if teleport.expireTime > Game.Timer() and self:IsInRange(source,teleport.aimPos, range) then			
			local spellInterceptTime = self:GetSpellInterceptTime(source, teleport.aimPos, delay, speed)
			local teleportRemaining = teleport.expireTime - Game.Timer()
			if spellInterceptTime > teleportRemaining and spellInterceptTime - teleportRemaining <= timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, teleport.aimPos, delay, speed, radius)) then								
				target = teleport.target
				aimPosition = teleport.aimPos
				return target, aimPosition
			end
		end
	end		
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:Angle(A, B)
	local deltaPos = A - B
	local angle = _atan(deltaPos.x, deltaPos.z) *  180 / _pi	
	if angle < 0 then angle = angle + 360 end
	return angle
end

--Returns where the unit will be when the delay has passed given current pathing information. This assumes the target makes NO CHANGES during the delay.
function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			--This node of the path will be completed before the delay has finished. Move on to the next node if one remains
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:IsChannelling(target, interceptTime)
	if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then
		return true
	end
end

function HPred:HasBuff(target, buffName, minimumDuration)
	local duration = minimumDuration
	if not minimumDuration then
		duration = 0
	end
	local durationRemaining
	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		if buff.duration > duration and buff.name == buffName then
			durationRemaining = buff.duration
			return true, durationRemaining
		end
	end
end

--Moves an origin towards the enemy team nexus by magnitude
function HPred:GetTeleportOffset(origin, magnitude)
	local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude
	return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end

--Checks if a target can be targeted by abilities or auto attacks currently.
--CanTarget(target)
	--target : gameObject we are trying to hit
function HPred:CanTarget(target, allowInvisible)
	return target.isEnemy and target.alive and target.health > 0  and (allowInvisible or target.visible) and target.isTargetable
end

--Derp: dont want to fuck with the isEnemy checks elsewhere. This will just let us know if the target can actually be hit by something even if its an ally
function HPred:CanTargetALL(target)
	return target.alive and target.health > 0 and target.visible and target.isTargetable
end

--Returns a position and radius in which the target could potentially move before the delay ends. ReactionTime defines how quick we expect the target to be able to change their current path
function HPred:UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = self:PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = self:GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

--Returns how long (in seconds) the target will be unable to move from their current location
function HPred:GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			duration = buff.duration
		end
	end
	return duration		
end

--Returns how long (in seconds) the target will be slowed for
function HPred:GetSlowedTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end

--Returns all existing path nodes
function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

--Finds any game object with the correct handle to match (hero, minion, wards on either team)
function HPred:GetObjectByHandle(handle)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and minion.handle == handle then
			target = minion
			return target
		end
	end
	
	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.handle == handle then
			target = ward
			return target
		end
	end
	
	for i = 1, LocalGameTurretCount() do 
		local turret = LocalGameTurret(i)
		if turret and turret.handle == handle then
			target = turret
			return target
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and particle.handle == handle then
			target = particle
			return target
		end
	end
end

function HPred:GetHeroByPosition(position)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetObjectByPosition(position)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local enemy = LocalGameMinion(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameWardCount() do
		local enemy = LocalGameWard(i);
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local enemy = LocalGameParticle(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
end

--Finds the closest particle to the origin that is contained in the names array
function HPred:GetNearestParticleByNames(origin, names)
	local target
	local distance = 999999
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle then 
			local d = self:GetDistance(origin, particle.pos)
			if d < distance then
				distance = d
				target = particle
			end
		end
	end
	return target, distance
end

--Returns the total distance of our current path so we can calculate how long it will take to complete
function HPred:GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + self:GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end


--I know this isn't efficient but it works accurately... Leaving it for now.
function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
		
	if not frequency then
		frequency = radius
	end
	local directionVector = (endPos - origin):Normalized()
	local checkCount = self:GetDistance(origin, endPos) / frequency
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * frequency
		local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed
		if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end


function HPred:IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and self:CanTarget(minion) and self:IsInRange(minion.pos, location, maxDistance) then
			local predictedPosition = self:PredictUnitPosition(minion, delay)
			if self:IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
				return true
			end
		end
	end
	return false
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

--Determines if there is a windwall between the source and target pos. 
function HPred:IsWindwallBlocking(source, target)
	if _windwall then
		local windwallFacing = (_windwallStartPos-_windwall.pos):Normalized()
		return self:DoLineSegmentsIntersect(source, target, _windwall.pos + windwallFacing:Perpendicular() * _windwallWidth, _windwall.pos + windwallFacing:Perpendicular2() * _windwallWidth)
	end	
	return false
end
--Returns if two line segments cross eachother. AB is segment 1, CD is segment 2.
function HPred:DoLineSegmentsIntersect(A, B, C, D)

	local o1 = self:GetOrientation(A, B, C)
	local o2 = self:GetOrientation(A, B, D)
	local o3 = self:GetOrientation(C, D, A)
	local o4 = self:GetOrientation(C, D, B)
	
	if o1 ~= o2 and o3 ~= o4 then
		return true
	end
	
	if o1 == 0 and self:IsOnSegment(A, C, B) then return true end
	if o2 == 0 and self:IsOnSegment(A, D, B) then return true end
	if o3 == 0 and self:IsOnSegment(C, A, D) then return true end
	if o4 == 0 and self:IsOnSegment(C, B, D) then return true end
	
	return false
end

--Determines the orientation of ordered triplet
--0 = Colinear
--1 = Clockwise
--2 = CounterClockwise
function HPred:GetOrientation(A,B,C)
	local val = (B.z - A.z) * (C.x - B.x) -
		(B.x - A.x) * (C.z - B.z)
	if val == 0 then
		return 0
	elseif val > 0 then
		return 1
	else
		return 2
	end
	
end

function HPred:IsOnSegment(A, B, C)
	return B.x <= _max(A.x, C.x) and 
		B.x >= _min(A.x, C.x) and
		B.z <= _max(A.z, C.z) and
		B.z >= _min(A.z, C.z)
end

--Gets the slope between two vectors. Ignores Y because it is non-needed height data. Its all 2d math.
function HPred:GetSlope(A, B)
	return (B.z - A.z) / (B.x - A.x)
end

function HPred:GetEnemyByName(name)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.isEnemy and enemy.charName == name then
			target = enemy
			return target
		end
	end
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	local deltaAngle = _abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
	if deltaAngle < angle and self:IsInRange(origin,target,range) then
		return true
	end
end

function HPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return _huge
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) 
end

function HPred:IsInRange(p1, p2, range)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined IsInRange target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return false
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range 
end

function HPred:GetDistance(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistance target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return _huge
	end
	return _sqrt(self:GetDistanceSqr(p1, p2))
end
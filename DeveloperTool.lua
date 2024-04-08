local PRINT_CONSOLE = false;
local SCRIPT_NAME = "DevTool"


local myHero = myHero
local os = os
local math = math
local string = string
local table = table
local Game = Game
local Vector = Vector
local Control = Control
local Draw = Draw
local GetTickCount = GetTickCount

local math_huge = math.huge
local math_pi = math.pi
local math_ceil = assert(math.ceil)
local math_min = assert(math.min)
local math_max = assert(math.max)
local math_atan = assert(math.atan)
local math_random = assert(math.random)

local table_sort = assert(table.sort)
local table_remove = assert(table.remove)
local table_insert = assert(table.insert)

local pairs = pairs
local ipairs = ipairs

--[[ Game = {
	FPS = Game.FPS,
	TICK = Game.TICK,
	Timer = Game.Timer,
	Latency = Game.Latency,
	Resolution = Game.Resolution,
	IsOnTop = Game.IsOnTop,
	IsChatOpen = Game.IsChatOpen,
	CanUseSpell = Game.CanUseSpell,
	--
	Ward = Game.Ward,
	Hero = Game.Hero,
	Object = Game.Object,
	Turret = Game.Turret,
	Minion = Game.Minion,
	Missile = Game.Missile,
	Particle = Game.Particle,
	--
	WardCount = Game.WardCount,
	HeroCount = Game.HeroCount,
	ObjectCount = Game.ObjectCount,
	TurretCount = Game.TurretCount,
	MinionCount = Game.MinionCount,
	MissileCount = Game.MissileCount,
	ParticleCount = Game.ParticleCount,
	--
	GetObjectByNetID = Game.GetObjectByNetID,
} ]]

local DevTool = {}
local DevToolLoad = false
local DevToolMenu = false
local DevToolLoadDelay = 5
local menuLoadDelay = string.format("%2.1f", DevToolLoadDelay-Game.Timer())

local Color = {
    Red = Draw.Color(255, 255, 0, 0),
    Green = Draw.Color(255, 0, 255, 0),
    Blue = Draw.Color(255, 0, 0, 255),
    Yellow = Draw.Color(255, 255, 255, 0),
    Aqua = Draw.Color(255, 0, 255, 255),
    Fuchsia = Draw.Color(255, 255, 0, 255),
    Teal = Draw.Color(255, 0, 128, 128),
    Gray = Draw.Color(128, 128, 128, 128),
    White = Draw.Color(255, 255, 255, 255), --default/nil
    Black = Draw.Color(255, 0, 0, 0),
}
-- pool
local pool = {}
local poolmt = {__index = pool}

function pool.create(newObject, poolSize)
	poolSize = poolSize or 16
	assert(newObject, "A function that returns new objects for the pool is required.")

	local freeObjects = {}
	for _ = 1, poolSize do
		table.insert(freeObjects, newObject())
	end

	return setmetatable({
			freeObjects = freeObjects,
			newObject = newObject
		},
		poolmt
	)
end

function pool:obtain()
	return #self.freeObjects == 0 and self.newObject() or table.remove(self.freeObjects)
end

function pool:free(obj)
	assert(obj, "An object to be freed must be passed.")

	table.insert(self.freeObjects, obj)
	if obj.reset then obj.reset() end
end

function pool:clear()
	for k in pairs(self.freeObjects) do
		self.freeObjects[k] = nil
	end
end
--

local Obj_AI_Bases = {}

DevTool.buffType = {
	CCImmune = 0,
	Dodge = 0,
	Stun = 5,
	Silence = 7,
	Taunt = 8,
	Poly = 10,
	Slow = 11,
	Root = 12,
	Invulnerable = 18,
	Nearsighted = 20,
	Fear = 22,
	Charm = 23,
	Supression = 25,
	Blind = 26,
	Flee = 29,
	Knockup = 30,
	Knockback = 31,
	Disarm = 32,
	Grounded = 33,
	Drowsy = 34,
	Asleep = 35,
	--[[ 	enum class BuffType {
		Internal = 0,
		Aura = 1,
		CombatEnchancer = 2,
		CombatDehancer = 3,
		SpellShield = 4,
		Stun = 5,
		Invisibility = 6,
		Silence = 7,
		Taunt = 8,
		Berserk = 9,
		Polymorph = 10,
		Slow = 11,
		Snare = 12,
		Damage = 13,
		Heal = 14,
		Haste = 15,
		SpellImmunity = 16,
		PhysicalImmunity = 17,
		Invulnerability = 18,
		AttackSpeedSlow = 19,
		NearSight = 20,
		Fear = 22,
		Charm = 23,
		Poison = 24,
		Suppression = 25,
		Blind = 26,
		Counter = 27,
		Currency = 21,
		Shred = 28,
		Flee = 29,
		Knockup = 30,
		Knockback = 31,
		Disarm = 32,
		Grounded = 33,
		Drowsy = 34,
		Asleep = 35,
		Obscured = 36,
		ClickProofToEnemies = 37,
		Unkillable = 38
	};
	--]]
}
DevTool.Object = {
	spawn = Obj_AI_SpawnPoint,
	camp = Obj_AI_Camp,
	barracks = Obj_AI_Barracks,
	hero = Obj_AI_Hero,
	minion = Obj_AI_Minion,
	turret = Obj_AI_Turret,
	missle = Obj_AI_LineMissle,
	shop = Obj_AI_Shop,
	nexus = Obj_AI_Nexus,
}

local menu = MenuElement({ id = "DeveloperTool", name = "DeveloperTool", type = MENU });

DevTool.Menu = function()
	if not DevToolMenu then
		menu:MenuElement({ id = "DevTest", name = "DevTest", type = MENU });
		menu.DevTest:MenuElement({ id = "TestON", name = "[Enable] Test in", drop = { "DRAW", "TICK" },
			callback = function(value)
				DevTool.TestON = value
			end
		});
		menu.DevTest:MenuElement({ id = "testMouse", name = "testMouse", value = false,
			callback = function(value)
				DevTool.testMouse = value
			end
		});
		menu.DevTest:MenuElement({ id = "testSpells", name = "testSpells", value = false,
			callback = function(value)
				DevTool.testSpells = value
			end
		});
		menu.DevTest:MenuElement({ id = "testItems", name = "testItems", value = false,
			callback = function(value)
				DevTool.testItems = value
			end
		});
		menu.DevTest:MenuElement({ id = "testPathing", name = "testPathing", value = false,
		callback = function(value)
				DevTool.testPathing = value
			end
		});
		menu.DevTest:MenuElement({ id = "DevTest", name = "DevTest", value = false });
		menu:MenuElement({ id = "GameObject", name = "GameObject", type = MENU });
		menu.GameObject:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.GameObject:MenuElement({ id = "DrawObjectInfo", name = "Object Info", value = false });
		menu.GameObject:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.GameObject:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.GameObject:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ id = "damage", name = "damage", value = false });
		menu.damage:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.damage:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.damage:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.damage:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ id = "item", name = "item", value = false });
		menu.item:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.item:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.item:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.item:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ id = "attackData", name = "attackData", value = false });
		menu.attackData:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.attackData:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.attackData:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.attackData:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ id = "activeSpell", name = "activeSpell", value = false });
		menu.activeSpell:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.activeSpell:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.activeSpell:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.activeSpell:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ id = "missileData", name = "missileData", value = false });
		menu.missileData:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.missileData:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.missileData:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.missileData:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ id = "spellData", name = "spellData", value = false });
		menu.spellData:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.spellData:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.spellData:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.spellData:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ id = "buff", name = "buff", value = false });
		menu.buff:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.buff:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.buff:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.buff:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ id = "particles", name = "particles", value = false });
		menu.particles:MenuElement({ id = "GameObject", name = "All GameObjects", value = false });
		menu.particles:MenuElement({ id = "GameObjectHeros", name = "Heros", value = false });
		menu.particles:MenuElement({ id = "GameObjectMinions", name = "Minions", value = false });
		menu.particles:MenuElement({ id = "GameObjectTurrets", name = "Turrets", value = false });
		menu:MenuElement({ type = SPACE })
		menu:MenuElement({ id = "API", name = "[ Dump API Documentation ]", type = MENU, });
		menu.API:MenuElement({ id = "APIdump", name = "[ Click to dump API Documentation ]", type = SPACE, tooltip = "Dumps to \\LOLEXT\\Scripts\\'[API].lua'", onclick = function() local date = os.date(); print("| "..SCRIPT_NAME.." | - [DUMP API] to \\LOLEXT\\Scripts\\'[API].lua' @ ["..date.."]"); DumpDocumentation("[API].lua")  menu.API:Hide() end});
		--local SCRIPT_NAME = string.gsub(string.match(debug.getinfo(1, 'S').short_src, "[^/]+$"), '.lua', '')

		menu:MenuElement({ id = "DevToolLoading", name = "DeveloperTool will load after: ".. menuLoadDelay.." s, to avoid crash", type = SPACE })

		DevToolMenu = true
	end
	if not DevToolLoad then
		menu.DevToolLoading:Remove()
		menu:MenuElement({id = "DevToolLoading", name = "DeveloperTool will load after: ".. menuLoadDelay.." s, to avoid crash", type = SPACE })
		DelayAction(function()
			DevTool.Menu() --"recurssion" to update MenuElement
		end, 0.5)
	else
		menu.DevToolLoading:Remove()
	end

end

local handleToNetworkID = {};
local function getObjectByHandle(handle)
	if handle == nil then
		return nil;
	end
	local networkID = handleToNetworkID[handle];
	return networkID ~= nil and Game.GetObjectByNetID(networkID) or nil;
end

local function isObj_AI_Base(obj)
	if obj.type ~= nil then
		--Obj_AI_Hero    Obj_AI_Minion    Obj_AI_Turret
		return true --obj --obj.type == DevTool.Object.hero or obj.type == DevTool.Object.minion or obj.type == DevTool.Object.turret;
	end
	return false;
end

local function isValidTarget(target)
	if target == nil then
		return false;
	end
	if isObj_AI_Base(target) and not target.valid then
		return false;
	end
	if target.dead or (not target.visible) or (not target.isTargetable) then
		return false;
	end
	return true;
end

local function isValidMissile(missile)
	if missile == nil then
		return false;
	end
	if missile.dead --[[or (not missile.visible)]] then -- <-- Fere please
		return false;
	end
	return true;
end

local function isOnScreen(obj)
	if (obj.handle == myHero.handle) then return true end;
	return obj.pos:To2D().onScreen;
end

local function getValue(name, func)
	if PRINT_CONSOLE then
		print("Checking " .. name);
	end
	return name .. ": " .. tostring(func()) .. ", ";
end

local counters = {};
local function drawText(target, value)
	if counters[target.networkID] == nil then
		counters[target.networkID] = 0;
	else
		counters[target.networkID] = counters[target.networkID] + 1;
	end
	local position = target.pos:To2D();
	position.y = position.y + 30 + 18 * counters[target.networkID];
	Draw.Text(tostring(value), position);
end

local poscounters = {};
local function drawTextPos(pos, value)
	if poscounters[myHero.networkID] == nil then
		poscounters[myHero.networkID] = 0;
	else
		poscounters[myHero.networkID] = poscounters[myHero.networkID] + 1;
	end
	local position = pos
	-- local position = pos
	position.y = position.y + 30 + 18 * poscounters[myHero.networkID];
	Draw.Text(tostring(value), position);
end

--states
local stateTable = {};
stateTable[STATE_UNKNOWN] 	= "STATE_UNKNOWN";
stateTable[STATE_ATTACK]	= "STATE_ATTACK";
stateTable[STATE_WINDUP] 	= "STATE_WINDUP";
stateTable[STATE_WINDDOWN] 	= "STATE_WINDDOWN";
local function convertState(state)
	return stateTable[state];
end

--slots
local slots = {};
table_insert(slots, _Q);
table_insert(slots, _W);
table_insert(slots, _E);
table_insert(slots, _R);
table_insert(slots, ITEM_1);
table_insert(slots, ITEM_2);
table_insert(slots, ITEM_3);
table_insert(slots, ITEM_4);
table_insert(slots, ITEM_5);
table_insert(slots, ITEM_6);
table_insert(slots, ITEM_7);
table_insert(slots, SUMMONER_1);
table_insert(slots, SUMMONER_2);

local itemSlots = {};
table_insert(itemSlots, ITEM_1);
table_insert(itemSlots, ITEM_2);
table_insert(itemSlots, ITEM_3);
table_insert(itemSlots, ITEM_4);
table_insert(itemSlots, ITEM_5);
table_insert(itemSlots, ITEM_6);
table_insert(itemSlots, ITEM_7);

DevTool.Tick = function()
	Obj_AI_Bases = {};
	handleToNetworkID = {};

	if menu.GameObject.GameObject:Value() then
		DevTool.GetAllHandles()
	end
	if menu.GameObject.GameObjectHeros:Value() then
		DevTool.Heros()
	end
	if menu.GameObject.GameObjectMinions:Value() then
		DevTool.Minions()
	end
	if menu.GameObject.GameObjectTurrets:Value() then
		DevTool.Turrets()
	end
end

DevTool.GetAllHandles = function()
	-- DevTool.Heros()
	-- DevTool.Minions()
	-- DevTool.Turrets()
	for i = 1, Game.ObjectCount()  do
		local obj = Game.Object(i)
		--Draw.Circle(obj.pos, 5)
		if isValidTarget(obj) then
			if isObj_AI_Base(obj) then
				table_insert(Obj_AI_Bases, obj);
				handleToNetworkID[obj.handle] = obj.networkID;
			end
		end
	end
end

DevTool.Heros = function()
	for i = 1, Game.HeroCount() do
		local obj = Game.Hero(i);
		if isValidTarget(obj) then
			if isObj_AI_Base(obj) then
				if isOnScreen(obj) then -- just because of fps
					table_insert(Obj_AI_Bases, obj);
				end
				handleToNetworkID[obj.handle] = obj.networkID;
			end
		end
	end
end

DevTool.Minions = function()
	for i = 1, Game.MinionCount() do
		local obj = Game.Minion(i);
		if isValidTarget(obj) then
			if isObj_AI_Base(obj) then
				if isOnScreen(obj) then -- just because of fps
					table_insert(Obj_AI_Bases, obj);
				end
				handleToNetworkID[obj.handle] = obj.networkID;
			end
		end
	end
end

DevTool.Turrets = function()
	for i = 1, Game.TurretCount() do
		local obj = Game.Turret(i);
		if isValidTarget(obj) then
			if isObj_AI_Base(obj) then
				if isOnScreen(obj) then -- just because of fps
					table_insert(Obj_AI_Bases, obj);
				end
				handleToNetworkID[obj.handle] = obj.networkID;
			end
		end
	end
end

DevTool.DrawObjectInfo = function ()
	for i, obj in ipairs(Obj_AI_Bases) do
		if isOnScreen(obj) then
--[[ 	if GameObjectCount() > 0 then
		for i = 1, GameObjectCount() do
			local obj = GameObject(i); ]]
			if isValidTarget(obj) then
				drawText(obj, getValue("type", function()
					return obj.type;
				end));
				drawText(obj, getValue("charName", function()
					return obj.charName;
				end));
				drawText(obj, getValue("name", function()
					local name = obj.name
					if obj.name == myHero.name then name = "[REDACTED]" end
					return name;
				end));
				drawText(obj, getValue("range", function()
					return obj.range;
				end));

				drawText(obj, getValue("isAlly", function()
					return obj.isAlly;
				end));
				drawText(obj, getValue("isEnemy", function()
					return obj.isEnemy;
				end));
				drawText(obj, getValue("team", function()
					return obj.team;
				end));
				drawText(obj, getValue("health", function()
					return obj.health;
				end));
				drawText(obj, getValue("maxHealth", function()
					return obj.maxHealth;
				end));
				drawText(obj, getValue("hudAmmo", function()
					return obj.hudAmmo;
				end));
				drawText(obj, getValue("hudMaxAmmo", function()
					return obj.hudMaxAmmo;
				end));
				if obj.type == DevTool.Object.hero then --Obj_AI_Hero
					drawText(obj, getValue("lvl", function()
						return obj.levelData.lvl;
					end));
					drawText(obj, getValue("lvlPts", function()
						return obj.levelData.lvlPts;
					end));
					drawText(obj, getValue("exp", function()
						return obj.levelData.exp;
					end));
				end
			end
		end
	end
end

DevTool.DrawDamage = function ()
	for i, obj in ipairs(Obj_AI_Bases) do
		if isOnScreen(obj) then
			drawText(obj, getValue("totalDamage", function()
				return obj.totalDamage;
			end));
			drawText(obj, getValue("ap", function()
				return obj.ap;
			end));
			drawText(obj, getValue("armor", function()
				return obj.armor;
			end));
			if obj.type == DevTool.Object.hero then --Obj_AI_Hero
				drawText(obj, getValue("critChance", function()
					return obj.critChance;
				end));
				drawText(obj, getValue("bonusArmor", function()
					return obj.bonusArmor;
				end));
				drawText(obj, getValue("armorPen", function()
					return obj.armorPen;
				end));
				drawText(obj, getValue("armorPenPercent", function()
					return obj.armorPenPercent;
				end));
				drawText(obj, getValue("bonusArmorPenPercent", function()
					return obj.bonusArmorPenPercent;
				end));
				drawText(obj, getValue("magicResist", function()
					return obj.magicResist;
				end));
				drawText(obj, getValue("bonusMagicResist", function()
					return obj.bonusMagicResist;
				end));
				drawText(obj, getValue("magicPen", function()
					return obj.magicPen;
				end));
				drawText(obj, getValue("magicPenPercent", function()
					return obj.magicPenPercent;
				end));
			end
			if obj.type == DevTool.Object.minion then --Obj_AI_Minion
				drawText(obj, getValue("bonusDamagePercent", function()
					return obj.bonusDamagePercent;
				end));
				drawText(obj, getValue("flatDamageReduction", function()
					return obj.flatDamageReduction;
				end));
			end
		end
	end
end

DevTool.DrawAttackData = function ()
	for i, obj in ipairs(Obj_AI_Bases) do
		if isOnScreen(obj) and obj.type == Obj_AI_Hero then
			drawText(obj, getValue("state", function()
				return convertState(obj.attackData.state);
			end));
			drawText(obj, getValue("windUpTime", function()
				return obj.attackData.windUpTime;
			end));
			drawText(obj, getValue("windDownTime", function()
				return obj.attackData.windDownTime;
			end));
			drawText(obj, getValue("animationTime", function()
				return obj.attackData.animationTime;
			end));
			drawText(obj, getValue("endTime", function()
				return obj.attackData.endTime;
			end));
			drawText(obj, getValue("castFrame", function()
				return obj.attackData.castFrame;
			end));
			drawText(obj, getValue("projectileSpeed", function()
				return obj.attackData.projectileSpeed;
			end));
			drawText(obj, getValue("target", function()
				local target = obj.attackData.target;
				-- return obj.attackData.target
--[[ 				if target.name then
					local name = target.name
					if name == myHero.name then name = "[REDACTED]" end
					return name
				end ]]
				return target--isValidTarget(target) or "[No Target]";
			end));
			drawText(obj, getValue("timeLeft", function()
				return math_max(obj.attackData.endTime - Game.Timer(), 0);
			end));
		end
	end
end

DevTool.DrawItem = function ()
	for i, obj in ipairs(Obj_AI_Bases) do
		if isOnScreen(obj) then
			for j, slot in ipairs(itemSlots) do
				local item = obj:GetItemData(slot);
				if item ~= nil and item.itemID > 0 then
					drawText(obj, "itemID: " .. item.itemID ..
						", stacks: " .. item.stacks ..
						", ammo: " .. item.ammo
					);
				end
			end
		end
	end
end

DevTool.DrawSpellData = function ()
	for i, obj in ipairs(Obj_AI_Bases) do
		if isOnScreen(obj) then
			for j, slot in ipairs(slots) do
				local spellData = obj:GetSpellData(slot);
				if spellData ~= nil and spellData.name ~= "" and spellData.name ~= "BaseSpell" then
					drawText(obj, "name: " .. spellData.name ..
						", castTime: " .. spellData.castTime ..
						", range: " .. spellData.range ..
						", width: " .. spellData.width ..
						", speed: " .. spellData.speed ..
						", targetingType: " .. spellData.targetingType ..
						", coneAngle: " .. spellData.coneAngle ..
						", ammo: " .. spellData.ammo ..
						", toggleState: " .. spellData.toggleState ..
						", level: " .. spellData.level ..
						", cd: " .. spellData.cd ..
						", currentCd: " .. spellData.currentCd ..
						", castFrame: " .. spellData.castFrame ..
						", ammoTime: " .. spellData.ammoTime ..
						", ammoCd: " .. spellData.ammoCd ..
						", ammoCurrentCd: " .. spellData.ammoCurrentCd
					);
				end
			end
		end
	end
end

DevTool.DrawBuff = function ()
	for i, obj in ipairs(Obj_AI_Bases) do
		if isOnScreen(obj) then
			for j = 1, obj.buffCount do
				local buff = obj:GetBuff(j);
				if buff ~= nil and buff.count > 0 then
					local name = buff.sourceName
					if name == myHero.name then name = "[REDACTED]" end
					drawText(obj, "type: " .. buff.type ..
						", name: " .. buff.name ..
						", stacks: " .. buff.stacks ..
						", count: " .. buff.count ..
						", sourcenID: " .. buff.sourcenID ..
						", sourceName: " .. name ..
						", startTime: " .. buff.startTime ..
						", expireTime: " .. buff.expireTime ..
						", duration: " .. buff.duration
					);
				end
			end
		end
	end
end

DevTool.DrawActiveSpell = function()
	for i, obj in ipairs(Obj_AI_Bases) do
		if isOnScreen(obj) then
			drawText(obj, getValue("activeSpell", function()
				return obj.activeSpell;
			end));
			drawText(obj, getValue("valid", function()
				return obj.activeSpell.valid;
			end)); --always use this to check if it's casting
			drawText(obj, getValue("level", function()
				return obj.activeSpell.level;
			end));
			drawText(obj, getValue("charName", function()
				return obj.charName;
			end));
			drawText(obj, getValue("name", function()
				local name = obj.activeSpell.name
				if name == myHero.name then name = "[REDACTED]" end
				return name;
			end));
			drawText(obj, getValue("startPos", function()
				return obj.activeSpell.startPos;
			end)); -- Vector
			drawText(obj, getValue("placementPos", function()
				return obj.activeSpell.placementPos;
			end)); -- Vector
			drawText(obj, getValue("target", function()
				return obj.activeSpell.target;
			end)); -- GameObject handle
			drawText(obj, getValue("windup", function()
				return obj.activeSpell.windup;
			end));
			drawText(obj, getValue("animation", function()
				return obj.activeSpell.animation;
			end));
			drawText(obj, getValue("range", function()
				return obj.activeSpell.range;
			end));
			drawText(obj, getValue("mana", function()
				return obj.activeSpell.mana;
			end));
			drawText(obj, getValue("width", function()
				return obj.activeSpell.width;
			end));
			drawText(obj, getValue("speed", function()
				return obj.activeSpell.speed;
			end));
			drawText(obj, getValue("coneAngle", function()
				return obj.activeSpell.coneAngle;
			end));
			drawText(obj, getValue("coneDistance", function()
				return obj.activeSpell.coneDistance;
			end));
			drawText(obj, getValue("acceleration", function()
				return obj.activeSpell.acceleration;
			end));
			drawText(obj, getValue("castFrame", function()
				return obj.activeSpell.castFrame;
			end));
			drawText(obj, getValue("maxSpeed", function()
				return obj.activeSpell.maxSpeed;
			end));
			drawText(obj, getValue("minSpeed", function()
				return obj.activeSpell.minSpeed;
			end));
			drawText(obj, getValue("spellWasCast", function()
				return obj.activeSpell.spellWasCast;
			end));
			drawText(obj, getValue("isAutoAttack", function()
				return obj.activeSpell.isAutoAttack;
			end));
			drawText(obj, getValue("isCharging", function()
				return obj.activeSpell.isCharging;
			end));
			drawText(obj, getValue("isChanneling", function()
				return obj.activeSpell.isChanneling;
			end));
			drawText(obj, getValue("startTime", function()
				return obj.activeSpell.startTime;
			end));
			drawText(obj, getValue("castEndTime", function()
				return obj.activeSpell.castEndTime;
			end));
			drawText(obj, getValue("endTime", function()
				return obj.activeSpell.endTime;
			end));
			drawText(obj, getValue("isStopped", function()
				return obj.activeSpell.isStopped;
			end));
			drawText(obj, getValue("activeSpellSlot", function()
				return obj.activeSpellSlot;
			end)); --use this to determine which spell slot was activated for ".activeSpell"
			drawText(obj, getValue("isChanneling", function()
				return obj.isChanneling;
			end)); --use this to determine if ".activeSpell" is actually a spell, otherwise it's autoattack
		end
	end
end

DevTool.DrawMissileData = function ()
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i);
		if isValidMissile(missile) then
			if isOnScreen(missile) then
				drawText(missile, getValue("name", function()
					return missile.missileData.name;
				end));
				drawText(missile, getValue("owner", function()
					local owner = getObjectByHandle(missile.missileData.owner);
					if not owner then return "" end
					local name = owner.name
					if name == myHero.name then name = "[REDACTED]" end
					return isValidTarget(owner) and name or "";
				end));
				drawText(missile, getValue("target", function()
					local target = getObjectByHandle(missile.missileData.target);
					if not target then return "" end
					local name = target.name
					if name == myHero.name then name = "[REDACTED]" end
					return isValidTarget(target) and name or "";
				end));
				--[[
				drawText(missile, getValue("startPos", function()
					return missile.missileData.startPos;
				end));
				drawText(missile, getValue("endPos", function()
					return missile.missileData.endPos;
				end));
				drawText(missile, getValue("placementPos", function()
					return missile.missileData.placementPos;
				end));
				]]
				drawText(missile, getValue("range", function()
					return missile.missileData.range;
				end));
				drawText(missile, getValue("delay", function()
					return missile.missileData.delay;
				end));
				drawText(missile, getValue("speed", function()
					return missile.missileData.speed;
				end));
				drawText(missile, getValue("width", function()
					return missile.missileData.width;
				end));
				drawText(missile, getValue("manaCost", function()
					return missile.missileData.manaCost;
				end));
			end
		end
	end
end

DevTool.DrawParticles = function ()
	for i = 1, Game.ParticleCount() do
		local particle = Game.Particle(i);
		Draw.Circle(mousePos, 200)
		if particle ~= nil and not particle.dead and particle.pos:DistanceTo(mousePos) <= 200 then
			if isOnScreen(particle) then -- just because of fps
				drawText(particle, getValue("name", function()
					return particle.name;
				end));
			end
		end
	end
end

DevTool.OnPreAttack = function(args)
	print("OnPreAttack")
	Draw.Text("OnPreAttack: ", cursorPos);
end

DevTool.OnPostAttack = function(args)
	print("OnPostAttack")
	Draw.Text("OnPostAttack: ", cursorPos);
end

DevTool.OnAttack = function(args)
	print("OnAttack")
	Draw.Text("OnAttack: ", cursorPos);
end

DevTool.OnPreMovement = function(args)
	print("OnPreMovement")
	Draw.Text("OnPreMovement: ", cursorPos);
end

DevTool.Draw = function()
	counters = {};
	poscounters = {};
	DevTool.DrawGameInfo()

	if menu.GameObject.DrawObjectInfo:Value() then
		DevTool.DrawObjectInfo()
	end

	if menu.damage:Value() then
		DevTool.DrawDamage()
	end

	if menu.attackData:Value() then
		DevTool.DrawAttackData()
	end

	if menu.activeSpell:Value() then
		DevTool.DrawActiveSpell()
	end

	if menu.item:Value() then
		DevTool.DrawItem()
	end

	if menu.spellData:Value() then
		DevTool.DrawSpellData()
	end

	if menu.buff:Value() then
		DevTool.DrawBuff()
	end

	if menu.missileData:Value() then
		DevTool.DrawMissileData()
	end

	if menu.particles:Value() then
		DevTool.DrawParticles()
	end
end

DevTool.DrawGameInfo = function()
	local count = 0
	local mapID = Game.mapID
	local screenRes = Game.Resolution()
	local padding = 10
	local pos = {
		x = screenRes.x - padding,
		y = screenRes.y - padding - 100,
	}
	-- drawText(myHero, "screenRes: " .. tostring(screenRes))
	-- drawText(myHero, "Game.Resolution(): " .. tostring(Game.Resolution()))
	-- drawTextPos(pos, "screenRes: " .. tostring(screenRes))
	-- drawTextPos(pos, "Game.Resolution(): " .. tostring(Game.Resolution()))
	-- drawText(myHero, "screenRes: " .. screenRes)
	-- drawText(myHero, "Game.Resolution(): " .. Game.Resolution())
--[[ 	if not Game then
		local DrawGameInfo = "GameInfo Loading: " .. tostring(Game)
		drawTextPos(myHero, DrawGameInfo)
		return
	end ]]
	-- drawTextPos(screenRes - padding, "Game.FPS(): " .. tostring(Game.FPS()))
--[[ 	drawTextPos(pos, "Game.Resolution(): " .. tostring(Game.Resolution()) ..
	", Game.FPS(): " .. tostring(Game.FPS()) ..
	", Game.TICK(): " .. tostring(Game.TICK()) ..
	", GetTickCount: " .. tostring(GetTickCount()) ..
	", Game.Timer(): " .. tostring(Game.Timer()) ..
	", Game.Latency(): " .. tostring(Game.Latency()) ..
	", mapID: " .. tostring(mapID)
	); ]]
--[[
	-- Display fps
	-- drawText(myHero, "Game.FPS(): "..tostring(Game.FPS()))

	local fpsText = "FPS: " .. tostring(Game.FPS())
	Draw.Text(fpsText, 12, screenWidth - padding - 100, screenHeight + padding, Color.White)
	count = count + 20
	-- Display tick
	-- drawText(myHero, "Game.TICK(): "..tostring(Game.TICK()))

	local tickText = "Tick: " .. tostring(Game.TICK())
	Draw.Text(tickText, 12, screenWidth - padding - 100, screenHeight + padding + count, Color.White)
	count = count + 20
	-- Display tick
	-- drawText(myHero, "GetTickCount: "..tostring(GetTickCount()))

	local tickText = "Tickcount: " .. tostring(GetTickCount())
	Draw.Text(tickText, 12, screenWidth - padding - 100, screenHeight + padding + count, Color.White)
	count = count + 20

	-- drawText(myHero, "Game.Timer(): "..tostring(Game.Timer()))

	local timerText = "Timer: " .. tostring(Game.Timer())
	Draw.Text(timerText, 12, screenWidth - padding - 100, screenHeight + padding + count, Color.White)
	count = count + 20
	-- Display latency
	-- drawText(myHero, "Game.Latency(): "..tostring(Game.Latency()))

	local latencyText = "Latency: " .. tostring(Game.Latency()) .. "ms" -- * 0.001
	Draw.Text(latencyText, 12, screenWidth - padding - 100, screenHeight + padding + count, Color.White)
	count = count + 20
	-- Display mapID
	-- drawText(myHero, "mapID: "..tostring(mapID))

	local mapIDText = "mapID: " .. tostring(mapID)
	Draw.Text(mapIDText, 12, screenWidth - padding - 100, screenHeight + padding + count, Color.White)
	count = count + 20
	]]
end
--[[ DEBUG ]]
DevTool.LoadDebug = function()
	if jit then
		DevTool.EXTP = true
		--[[ jit : jitlib = {
		arch: string,
		flush: function(func: function | boolean, recursive: boolean),  ---@overload fun()
		off: function(func: function | boolean, recursive: boolean),  ---@overload fun()
		on: function(func: function | boolean, recursive: boolean),  ---@overload fun()
		os: string,
		status: function(): boolean, ...,  ---@return boolean status
		version: string,
		version_num: number,
		}, ]]
		--[[ EXTP = {
		os
		on
		off
		flush
		attach
		arch
		version_num
		version
		status
		opt
		security
		}, ]]
		-- for n in pairs(jit) do print(n) end
		-- jit.debug()
		local debuggsub = string.gsub(string.match(debug.getinfo(1, 'S').short_src, "[^/]+$"), '.lua', '')
		-- local ngsub = string:gsub(".lua$", "")
		local ngsub = string.gsub(string.match(debug.getinfo(1, 'S').short_src, "[^/]+$"), '.lua$', '')
		-- :gsub(".lua$", "")
		-- print("* | ngsub | - [ ".. ngsub .." ]");
		-- print("* | debuggsub '.lua' | - [ "..debuggsub.." ]");
		-- print("* | ngsub '.lua$' | - [ ".. ngsub .." ]");

		print("| " .. SCRIPT_NAME .. " | - [" .. jit.version .. "] - [ " .. _VERSION .. " ]");
	else
		DevTool.EXTP = false
		print("| " .. SCRIPT_NAME .. " | - [ EXTP: " .. tostring(DevTool.EXTP) .. "] - [ " .. _VERSION .. " ]");
	end
	DevTool.Debug()
end

DevTool.Debug = function ()
	if debug then
	--[[ debug : debug = {
		debug: function(),  --- Enters an interactive mode with the user, running each string that the user
		getfenv: function(o: any): table,  --- Returns the environment of object o.
		gethook: function(co: thread): function, string, integer,  --- Returns the current hook settings of the thread, as three values: the
		getinfo: function(thread: thread, f: integer | function, what: infowhat): debuginfo,  --- Returns a table with information about a function. You can give the
		getlocal: function(thread: thread, level: integer, index: integer): string, any,  --- This function returns the name and the value of the local variable with
		getmetatable: function(object: any): table,  --- Returns the metatable of the given `value` or **nil** if it does not have a metatable.
		getregistry: function(): table,  ---Returns the registry table.
		getupvalue: function(f: function, up: integer): string, any,  -- This function returns the name and the value of the upvalue with index up of the function f. The function returns fail if there is no upvalue with the given index.
		getuservalue: function(u: userdata, n: number): boolean,  --- Returns the `n`-th user value associated to the userdata `u` plus a boolean, **false** if the userdata does not have that value.
		setfenv: function(object: T, env: table): T,  -- Sets the environment of the given `object` to the given `table`. Returns `object`.
		sethook: function(thread: thread, hook: function, mask: hookmask, count: integer),  --- Sets the given function as a hook. The string `mask` and the number `count`
		setlocal: function(thread: thread, level: integer, index: integer, value: any): string,  --- This function assigns the value `value` to the local variable with
		setmetatable: function(value: T, meta: table): T,  --- Sets the metatable for the given `object` to the given `table` (which can be **nil**). Returns value.
		setupvalue: function(f: function, up: integer, value: any): string,  --- This function assigns the value `value` to the upvalue with index `up`
		setuservalue: function(udata: userdata, value: any, n: integer): userdata,  --- Sets the given *value* as the *n*-th associated to the given *udata*. *udata* must be a full userdata.
		traceback: function(thread: thread, message: any, level: integer): string,  --- If *message* is present but is neither a string nor **nil**, this function
		upvalueid: function(f: function(): number, n: integer): lightuserdata,  --- Returns a unique identifier (as a light userdata) for the upvalue numbered
		upvaluejoin: function(f1: function, n1: integer, f2: function, n2: integer),  --- Make the *n1*-th upvalue of the Lua closure f1 refer to the *n2*-th upvalue of the Lua closure f2.
	}, ]]
	--[[ EXTP = {
	getmetatable
	setmetatable
	sethook
	gethook
	traceback
	getuservalue
	setuservalue
	upvalueid
	getregistry
	getinfo
	getlocal
	setlocal
	getupvalue
	setupvalue
	}, ]]

	--[[ what:
	+> "n" -- `name` and `namewhat`
	+> "S" -- `source`, `short_src`, `linedefined`, `lastlinedefined`, and `what`
	+> "l" -- `currentline`
	+> "t" -- `istailcall`
	+> "u" -- `nups`, `nparams`, and `isvararg`
	+> "f" -- `func`
	+> "L" -- `activelines`
	]]

	-- for n in pairs(_G) do print(n) end
	-- print(debug.getinfo(DevTool))
	-- debug.getinfo(print)


--
	end
end

--[[ TEST ]]
DevTool.LoadTest = function()
	DevTool.testMouse = menu.DevTest.testMouse:Value()
	DevTool.testSpells = menu.DevTest.testSpells:Value()
	DevTool.testItems = menu.DevTest.testItems:Value()
	DevTool.testPathing = menu.DevTest.testPathing:Value()
	if menu.DevTest.TestON:Value() then

	end

	local options = menu.DevTest.TestON
	-- for i = 1, #options do
	DevTool.TestTick()
	-- end
end

DevTool.TestTick = function()
	if menu.DevTest.TestON:Value() == 1 then
		Callback.Add("Draw", function()
			DevTool.Test()
		end);
	end
	if menu.DevTest.TestON:Value() == 2 then
		Callback.Add("Tick", function()
			DevTool.Test()
		end);
	end
	-- end
end


DevTool.Test = function()
	--print(Game.HeroCount())
	if DevTool.testMouse then
		local mouse = mousePos
		local cursor = cursorPos
		local offset = 12
		--local mouseWall = Game.isWall(mousePos)
		--print(mouseWall)
		local position = mouse:To2D();
		-- position.y = position.y + 30 + 18;
		Draw.Circle(mouse, 10)
		-- Draw.Text("Game.isWall(mousePos): "..tostring(mouseWall), cursor);

	end
	if DevTool.testSpells then
		for i, obj in ipairs(Obj_AI_Bases) do
			if isOnScreen(obj) then
				for j, slot in ipairs(slots) do
					local spellData = obj:GetSpellData(slot);
					if spellData ~= nil and spellData.name ~= "" and spellData.name ~= "BaseSpell" then
						if obj.name == myHero.name then break end
--[[ 					drawText(obj, "name: " .. spellData.name ..
						", toggleState: " .. spellData.toggleState ..
						", cd: " .. spellData.cd ..
						", currentCd: " .. spellData.currentCd ..
						", slot: " .. slot ..
						", CanUseSpell("..slot.."): " .. Game.CanUseSpell(slot) ..
						", obj:GetSpellData("..slot..").currentCd: " .. obj:GetSpellData(slot).currentCd
						); ]]
					end
				end
			end
		end
--[[ 		if Game.CanUseSpell(_Q) then -- == 0  then
			--print("Q: ".. Game.CanUseSpell(_Q))
			-- print("Q: ".. myHero:GetSpellData(_Q).currentCd)
			-- Draw.Text("Q: "..Game.CanUseSpell(_Q), cursor);
			drawText(myHero, getValue("Q", function()
				return Game.CanUseSpell(_Q);
			end));
		end
		if Game.CanUseSpell(_W) then
			--print("W: "..Game.CanUseSpell(_W))
			-- Draw.Text("W: "..Game.CanUseSpell(_W), cursor);
			drawText(myHero, getValue("W", function()
				return Game.CanUseSpell(_W);
			end));
		end
		if Game.CanUseSpell(_E) then
			--print("E: "..Game.CanUseSpell(_E))
			-- Draw.Text("E: "..Game.CanUseSpell(_E), cursor);
			drawText(myHero, getValue("E", function()
				return Game.CanUseSpell(_E);
			end));
		end
		if Game.CanUseSpell(_R) then
			--print("R: "..Game.CanUseSpell(_R))
			-- Draw.Text("R: "..Game.CanUseSpell(_R), cursor);
			drawText(myHero, getValue("R", function()
				return Game.CanUseSpell(_R);
			end));
		end ]]
	end
	if DevTool.testItems then
	--[[ 		local obj = myHero
		if isOnScreen(obj) then
			for i, slot in ipairs(itemSlots) do
				local item = obj:GetItemData(slot);
				if item ~= nil and item.itemID > 0 then
					drawText(obj, "itemID: " .. item.itemID ..
						", stacks: " .. item.stacks ..
						", ammo: " .. item.ammo ..
						", stacks: " .. item.stacks ..
						", CanUseSpell("..slot.."): " .. Game.CanUseSpell(slot) ..

						", slot["..i.."]: " .. slot
					);
				end
			end
		end ]]
		for i, obj in ipairs(Obj_AI_Bases) do
			if isOnScreen(obj) then
				for j, slot in ipairs(itemSlots) do
					local item = obj:GetItemData(slot);
					if item ~= nil and item.itemID > 0 then
						if obj.name == myHero.name then break end
						drawText(obj, "itemID: " .. item.itemID ..
						", stacks: " .. item.stacks ..
						", ammo: " .. item.ammo ..
						", stacks: " .. item.stacks ..
						", slot: " .. slot ..
						", CanUseSpell("..slot.."): " .. Game.CanUseSpell(slot) ..
						", obj:GetSpellData("..slot..").currentCd: " .. obj:GetSpellData(slot).currentCd
					);
					end
				end
			end
		end
--[[ 		drawText(obj,
		"ITEM_1: " .. ITEM_1 ..
		", ITEM_2: " .. ITEM_2 ..
		", ITEM_3: " .. ITEM_3 ..
		", ITEM_4: " .. ITEM_4 ..
		", ITEM_5: " .. ITEM_5 ..
		", ITEM_6: " .. ITEM_6 ..
		", ITEM_7: " .. ITEM_7
	); ]]
	end

	if DevTool.testPathing then
		if myHero.pathing then
			Draw.Text("myHero.pathing.hasMovePath: "..tostring(myHero.pathing.hasMovePath), myHero.pos:To2D())
		end
	end
	--[[ 	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero and Hero.isEnemy then
			Draw.Circle(Hero.pos, 300)
			Draw.CircleMinimap(Hero.pos, 1000)
		end
	end ]]
	--[[ 	if SDK then
		SDK.Orbwalker:OnPreAttack(function(...) DevTool:OnPreAttack(...) end)
		SDK.Orbwalker:OnAttack(function(...) DevTool:OnAttack(...) end)
		SDK.Orbwalker:OnPostAttack(function(...) DevTool:OnPostAttack(...) end)
		SDK.Orbwalker:OnPreMovement(function(...) DevTool:OnPreMovement(...) end)
	elseif PremiumOrbwalker then
		PremiumOrbwalker:OnPreAttack(function(...) DevTool:OnPreAttack(...) end)
	end ]]
	--[[ 	print(
		" READY: "..READY..
		" NOTAVAILABLE: "..NOTAVAILABLE..
		" READYNOCAST: "..READYNOCAST..
		" NOTLEARNED: "..NOTLEARNED..
		" ONCOOLDOWN: "..ONCOOLDOWN..
		" NOMANA: "..NOMANA..
		" NOMANAONCOOLDOWN: "..NOMANAONCOOLDOWN) ]]

	for i, obj in ipairs(Obj_AI_Bases) do
		if isOnScreen(obj) then
		local baseHP = obj.baseHP
		local hpPerLevel = obj.hpPerLevel
		local hp = baseHP + (hpPerLevel * (obj.levelData.lvl - 1)) * (0.7025 + (0.0175 * (obj.levelData.lvl - 1)))
		local maxHP = obj.maxHealth
		-- print()
		drawText(obj, "baseHP: " .. baseHP ..
						", hpPerLevel: " .. hpPerLevel ..
						", hp: " .. hp ..
						", maxHP: " .. maxHP
		);
		end
	end
	if DevTool.Dump_G then
		for n in pairs(_G) do print(n) end
	end
end

--[[ LOAD ]]
DevTool.callbacks = {
	Load = "Load",
	UnLoad = "UnLoad",
	GameEnd = "GameEnd",
	Tick = "Tick",
	Draw = "Draw",
	WndMsg = "WndMsg", -- (msg, wParam)
	ProcessRecall = "ProcessRecall" -- (unit, proc)
 }
DevTool.Load = function()
	if Game.Timer() > DevToolLoadDelay then
		DevToolLoad = true
	end
	if not DevToolMenu then
		DevTool:Menu()
	end
	if not DevToolLoad then
		DelayAction(function()
			DevTool:Load()
		end, 1)
	else
		--for
		Callback.Add("Tick", function()
			DevTool:Tick()
		end);
		Callback.Add("Draw", function()
			DevTool:Draw()
		end);
		DevTool.GetAllHandles()
		DevTool.LoadTest()
		DevTool.LoadDebug()
	end
end
--[[ 	Callback.Add("Tick", function()
		if not DevToolLoad then
			menuLoadDelay = string.format("%2.1f", DevToolLoadDelay-Game.Timer())
		end
	end);
	Callback.Add("Tick", function()self:Tick() end)
	Callback.Add("Draw", function()self:Draw() end)
	--Callback.Add("Tick", OnProcessSpell)
	Callback.Add("UnLoad", function()

	end);
]]


-- [[ Update ]] --
--[[
local Author = "Impuls"
do
    local SCRIPT_NAME = string.gsub(string.match(debug.getinfo(1, 'S').short_src, "[^/]+$"), '.lua', '')
    -- local SCRIPT_NAME = "DamageLib"
    local gitHub = "https://raw.githubusercontent.com/"..Author.."x/GoS/master/"
    local Files = {
      Lua = {
        Path = COMMON_PATH,
        Name = SCRIPT_NAME..".lua",
      },
      Version = {
        Path = COMMON_PATH,
        Name = SCRIPT_NAME..".version",
      }
    }

    local function update()
      local function DownloadFile(path, fileName)
        DownloadFileAsync(gitHub .. fileName, path .. fileName, function() end)
        while not FileExist(path .. fileName) do end
      end

      local function ReadFile(path, fileName)
        local file = assert(io.open(path .. fileName, "r"))
        local result = file:read()
        file:close()
        return result
      end

      DownloadFile(Files.Version.Path, Files.Version.Name)
      local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
      if NewVersion > Version then
        DownloadFile(Files.Lua.Path, Files.Lua.Name)
        print("*WARNING* New "..SCRIPT_NAME.." [ver. " .. tostring(NewVersion) .. "] Downloaded - Please RELOAD with [ F6 ]")
      else
        print("| "..SCRIPT_NAME.." | [ver. " .. tostring(Version) .. "] loaded!")
      end
    end
    update()
end
]]


-- [[ AsyncUpdate ]] --
--[[
local Author = "Impuls"
do
  --local SCRIPT_NAME = string.gsub(string.match(debug.getinfo(1, 'S').short_src, "[^/]+$"), '.lua', '')
  local SCRIPT_NAME = "DeveloperTool"
  local gitHub = "https://raw.githubusercontent.com/" .. Author .. "x/GoS/master/"
  local Files = {
    -- self = self,
    -- lua = ".lua",         --string
    -- version = ".version", --string
    Lua = {
      Path = COMMON_PATH,
      Name = SCRIPT_NAME .. ".lua",
    },
    --source = self.Lua.Path .. self.Lua.Name,
    Version = {
      Path = COMMON_PATH,
      Name = SCRIPT_NAME .. ".version",
    },
    --versource = self.Version.Path .. self.Version.Name,
  }
  local function update()
    local function readAll(file)
      local f = assert(io.open(file, "r"))
      local content = f:read("*all")
      f:close()
      return content
    end
    local function downloadFile(path, fileName)
      DownloadFileAsync(gitHub .. fileName, path .. fileName, function() end)
      while not FileExist(path .. fileName) do end
    end
    local function readFile(path, fileName)
      local file = assert(io.open(path .. fileName, "r"))
      local result = file:read()
      file:close()
      return result
    end
    local function initializeScript()
      local function writeModule(content)
        local f = assert(io.open(Files.Lua.Path .. Files.Lua.Name, content and "a" or "w"))
        if content then
          f:write(content)
        end
        f:close()
      end
      --
      writeModule()
      --Write the core module
      writeModule(readAll(Files.Lua.Path .. Files.Lua.Name))
      -- writeModule(readAll(AUTO_PATH..coreName))
      -- writeModule(readAll(CHAMP_PATH..charName..dotlua))
      --Load the active module
      dofile(Files.Lua.Path .. Files.Lua.Name)
    end

    downloadFile(Files.Version.Path, Files.Version.Name)
    local NewVersion = tonumber(readFile(Files.Version.Path, Files.Version.Name))
    if NewVersion > Version then
      downloadFile(Files.Lua.Path, Files.Lua.Name)
    --   print("*WARNING* New "..SCRIPT_NAME.." [ver. " .. tostring(NewVersion) .. "] Downloaded - Please RELOAD with [ F6 ]")
      print("*WARNING* New " .. SCRIPT_NAME .. " [ver. " .. tostring(NewVersion) .. "] Downloaded - RELOADING")
      initializeScript()
    else
      print("| " .. SCRIPT_NAME .. " | [ver. " .. tostring(Version) .. "] loaded!")
    end
  end
  update()
end
]]
--[[
		Callback API: {
		Add = Adds a new Callback; Input: (iType, function); Return: callbackID
		Del = Deletes a callback, Input: (iType, callbackID)
	}

	iTypes: {
		"Load",
		"UnLoad",
		"GameEnd",
		"Tick",
		"Draw",
		"WndMsg", -- (msg, wParam)
		"ProcessRecall" -- (unit, proc)
	}
 ]]
--uwu
Callback.Add("Load", function()
	DevTool:Load()
	-- print("| "..SCRIPT_NAME.." |");
end);
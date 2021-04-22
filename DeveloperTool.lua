local PRINT_CONSOLE = false;

local menu = MenuElement({ id = "DeveloperTool", name = "DeveloperTool", type = MENU });
menu:MenuElement({ id = "GameObject", name = "GameObject", value = false });
menu:MenuElement({ id = "damage", name = "damage", value = false });
menu:MenuElement({ id = "item", name = "item", value = false });
menu:MenuElement({ id = "attackData", name = "attackData", value = false });
menu:MenuElement({ id = "missileData", name = "missileData", value = false });
menu:MenuElement({ id = "spellData", name = "spellData", value = false });
menu:MenuElement({ id = "buff", name = "buff", value = false });
menu:MenuElement({ id = "particles", name = "particles", value = false });


local function isObj_AI_Base(obj)
	if obj.type ~= nil then
		return obj.type == Obj_AI_Hero or obj.type == Obj_AI_Minion or obj.type == Obj_AI_Turret;
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
	return obj.pos:To2D().onScreen;
end

local function getValue(name, func)
	if PRINT_CONSOLE then
		print('Checking ' .. name);
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

local stateTable = {};
stateTable[STATE_UNKNOWN] 	= "STATE_UNKNOWN";
stateTable[STATE_ATTACK]	= "STATE_ATTACK";
stateTable[STATE_WINDUP] 	= "STATE_WINDUP";
stateTable[STATE_WINDDOWN] 	= "STATE_WINDDOWN";
local function convertState(state)
	return stateTable[state];
end

local slots = {};
table.insert(slots, _Q);
table.insert(slots, _W);
table.insert(slots, _E);
table.insert(slots, _R);
table.insert(slots, ITEM_1);
table.insert(slots, ITEM_2);
table.insert(slots, ITEM_3);
table.insert(slots, ITEM_4);
table.insert(slots, ITEM_5);
table.insert(slots, ITEM_6);
table.insert(slots, ITEM_7);
table.insert(slots, SUMMONER_1);
table.insert(slots, SUMMONER_2);

local handleToNetworkID = {};
local function getObjectByHandle(handle)
	if handle == nil then
		return nil;
	end
	local networkID = handleToNetworkID[handle];
	return networkID ~= nil and Game.GetObjectByNetID(networkID) or nil;
end

local itemSlots = {};
table.insert(itemSlots, ITEM_1);
table.insert(itemSlots, ITEM_2);
table.insert(itemSlots, ITEM_3);
table.insert(itemSlots, ITEM_4);
table.insert(itemSlots, ITEM_5);
table.insert(itemSlots, ITEM_6);
table.insert(itemSlots, ITEM_7);


Callback.Add('Load', 
	function()
		local Obj_AI_Bases = {}
		Callback.Add('Tick', function()
			Obj_AI_Bases = {};
			handleToNetworkID = {};
			for i = 0, Game.HeroCount() do
				local obj = Game.Hero(i);
				if isValidTarget(obj) then
					if isObj_AI_Base(obj) then
						if isOnScreen(obj) then -- just because of fps
							table.insert(Obj_AI_Bases, obj);
						end
						handleToNetworkID[obj.handle] = obj.networkID;
					end
				end
			end
			for i = 0, Game.MinionCount() do
				local obj = Game.Minion(i);
				if isValidTarget(obj) then
					if isObj_AI_Base(obj) then
						if isOnScreen(obj) then -- just because of fps
							table.insert(Obj_AI_Bases, obj);
						end
						handleToNetworkID[obj.handle] = obj.networkID;
					end
				end
			end
			for i = 0, Game.TurretCount() do
				local obj = Game.Turret(i);
				if isValidTarget(obj) then
					if isObj_AI_Base(obj) then
						if isOnScreen(obj) then -- just because of fps
							table.insert(Obj_AI_Bases, obj);
						end
						handleToNetworkID[obj.handle] = obj.networkID;
					end
				end
			end
		end);

		Callback.Add('Draw', function()
			counters = {};
			if menu.GameObject:Value() then
				if Game.ObjectCount() > 0 then
					for i = 0, Game.ObjectCount() do
						local obj = Game.Object(i);
						if isValidTarget(obj) then
							drawText(obj, getValue('type', function()
								return obj.type;
							end));
							drawText(obj, getValue('charName', function()
								return obj.charName;
							end));
							drawText(obj, getValue('name', function()
								return obj.name;
							end));
							drawText(obj, getValue('range', function()
								return obj.range;
							end));
							drawText(obj, getValue('isAlly', function()
								return obj.isAlly;
							end));
							drawText(obj, getValue('isEnemy', function()
								return obj.isEnemy;
							end));
							drawText(obj, getValue('team', function()
								return obj.team;
							end));
							drawText(obj, getValue('health', function()
								return obj.health;
							end));
							drawText(obj, getValue('maxHealth', function()
								return obj.maxHealth;
							end));
						end
					end
				end
			end
			for i, obj in ipairs(Obj_AI_Bases) do
				if isOnScreen(obj) then
					if menu.damage:Value() then
						drawText(obj, getValue('totalDamage', function()
							return obj.totalDamage;
						end));
						drawText(obj, getValue('ap', function()
							return obj.ap;
						end));
						drawText(obj, getValue('armor', function()
							return obj.armor;
						end));
						if obj.type == Obj_AI_Hero then
							drawText(obj, getValue('bonusArmor', function()
								return obj.bonusArmor;
							end));
							drawText(obj, getValue('armorPen', function()
								return obj.armorPen;
							end));
							drawText(obj, getValue('armorPenPercent', function()
								return obj.armorPenPercent;
							end));
							drawText(obj, getValue('bonusArmorPenPercent', function()
								return obj.bonusArmorPenPercent;
							end));
							drawText(obj, getValue('magicResist', function()
								return obj.magicResist;
							end));
							drawText(obj, getValue('bonusMagicResist', function()
								return obj.bonusMagicResist;
							end));
							drawText(obj, getValue('magicPen', function()
								return obj.magicPen;
							end));
							drawText(obj, getValue('magicPenPercent', function()
								return obj.magicPenPercent;
							end));
						end
						if obj.type == Obj_AI_Minion then
							drawText(obj, getValue('bonusDamagePercent', function()
								return obj.bonusDamagePercent;
							end));
							drawText(obj, getValue('flatDamageReduction', function()
								return obj.flatDamageReduction;
							end));
						end
					end

					if menu.attackData:Value() and obj.type == Obj_AI_Hero then
						drawText(obj, getValue('state', function()
							return convertState(obj.attackData.state);
						end));
						drawText(obj, getValue('windUpTime', function()
							return obj.attackData.windUpTime;
						end));
						drawText(obj, getValue('windDownTime', function()
							return obj.attackData.windDownTime;
						end));
						drawText(obj, getValue('animationTime', function()
							return obj.attackData.animationTime;
						end));
						drawText(obj, getValue('endTime', function()
							return obj.attackData.endTime;
						end));
						drawText(obj, getValue('castFrame', function()
							return obj.attackData.castFrame;
						end));
						drawText(obj, getValue('projectileSpeed', function()
							return obj.attackData.projectileSpeed;
						end));
						drawText(obj, getValue('target', function()
							local target = getObjectByHandle(obj.attackData.target);
							return isValidTarget(target) and target.name or "";
						end));
						drawText(obj, getValue('timeLeft', function()
							return math.max(obj.attackData.endTime - Game.Timer(), 0);
						end));
					end

					if menu.item:Value() then
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

					if menu.spellData:Value() then
						for j, slot in ipairs(slots) do
							local spellData = obj:GetSpellData(slot);
							if spellData ~= nil and spellData.name ~= "" and spellData.name ~= "BaseSpell" then
								drawText(obj, "name: " .. spellData.name .. 
									", castTime: " .. spellData.castTime .. 
									", cd: " .. spellData.cd ..
									", currentCd: " .. spellData.currentCd ..
									", toggleState: " .. spellData.toggleState ..
									", range: " .. spellData.range ..
									", width: " .. spellData.width ..
									", speed: " .. spellData.speed ..
									", targetingType: " .. spellData.targetingType ..
									", coneAngle: " .. spellData.coneAngle ..
									", castFrame: " .. spellData.castFrame
								);
							end
						end
					end

					if menu.buff:Value() then
						for j = 0, obj.buffCount do
							local buff = obj:GetBuff(j);
							if buff ~= nil and buff.count > 0 then
								drawText(obj, "type: " .. buff.type .. 
									", name: " .. buff.name .. 
									", startTime: " .. buff.startTime .. 
									", expireTime: " .. buff.expireTime .. 
									", duration: " .. buff.duration .. 
									", stacks: " .. buff.stacks .. 
									", count: " .. buff.count .. 
									", sourceName: " .. buff.sourceName
								);
							end
						end
					end
				end
			end

			if menu.missileData:Value() then
				for i = 0, Game.MissileCount() do
					local missile = Game.Missile(i);
					if isValidMissile(missile) then
						if isOnScreen(missile) then
							drawText(missile, getValue('name', function()
								return missile.missileData.name;
							end));
							drawText(missile, getValue('owner', function()
								local owner = getObjectByHandle(missile.missileData.owner);
								return isValidTarget(owner) and owner.name or "";
							end));
							drawText(missile, getValue('target', function()
								local target = getObjectByHandle(missile.missileData.target);
								return isValidTarget(target) and target.name or "";
							end));
							--[[
							drawText(missile, getValue('startPos', function()
								return missile.missileData.startPos;
							end));
							drawText(missile, getValue('endPos', function()
								return missile.missileData.endPos;
							end));
							drawText(missile, getValue('placementPos', function()
								return missile.missileData.placementPos;
							end));
							]]
							drawText(missile, getValue('range', function()
								return missile.missileData.range;
							end));
							drawText(missile, getValue('delay', function()
								return missile.missileData.delay;
							end));
							drawText(missile, getValue('speed', function()
								return missile.missileData.speed;
							end));
							drawText(missile, getValue('width', function()
								return missile.missileData.width;
							end));
							drawText(missile, getValue('manaCost', function()
								return missile.missileData.manaCost;
							end));
						end
					end
				end
			end

			if menu.particles:Value() then
				for i = 0, Game.ParticleCount() do
					local particle = Game.Particle(i);
					if particle ~= nil and not particle.dead and particle.pos:DistanceTo(mousePos) <= 200 then
						if isOnScreen(particle) then -- just because of fps
							drawText(particle, getValue('name', function()
								return particle.name;
							end));
						end
					end
				end
			end
		end);
	end);
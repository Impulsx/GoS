class "Activator"

 -- [ AutoUpdate ]
do
    
    local Version = 0.04
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "SimbleActivator.lua",
            Url = "https://github.com/Pussykate/GoS/master/SimbleActivator.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "SimbleActivator.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/SimbleActivator.version"
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
        
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print(Files.Version.Name .. ": Updated to " .. tostring(NewVersion) .. ". Please Reload with 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end
 
 function OnLoad()

	Activator()
end
 
 function Activator:__init()
	
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)

end


	


local ActivatorIcon = "https://raw.githubusercontent.com/Pussykate/GoS/master/Activator.png"
local ZhonyaIcon = "https://de.share-your-photo.com/img/76fbcec284.jpg"
local StopWatchIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/e6/Stopwatch_item.png"

function Activator:LoadMenu()
	
	self.Menu = MenuElement({type = MENU, id = "Zhonya+Stopwatch Activator", name = "Activator", leftIcon = ActivatorIcon})
	
	self.Menu:MenuElement({id = "ZS", name = "Zhonya's + StopWatch", type = MENU})	
	
	self.Menu.ZS:MenuElement({id = "Zhonya", name = "Zhonya's Hourglass", type = MENU, leftIcon = ZhonyaIcon})
	self.Menu.ZS.Zhonya:MenuElement({id = "UseZ", name = "Use Zhonya's Hourglass", value = true})
	
	self.Menu.ZS:MenuElement({id = "Stopwatch", name = "Stopwatch", type = MENU, leftIcon = StopWatchIcon})
	self.Menu.ZS.Stopwatch:MenuElement({id = "UseS", name = "Use Stopwatch", value = true})	
	
	self.Menu.ZS:MenuElement({id = "HP", name = "myHP", type = MENU})
	self.Menu.ZS.HP:MenuElement({id = "myHP", name = "Use if health is below:",value = 20, min = 0, max = 100,step = 1})	
	
	self.Menu.ZS:MenuElement({id = "QSS", name = "QSS Setings", type = MENU})
	self.Menu.ZS.QSS:MenuElement({id = "UseSZ", name = "AutoUse Stopwatch or Zhonya on ZedUlt", value = true})

	self.Menu:MenuElement({id = "Healing", name = "Potions", type = MENU})
	self.Menu.Healing:MenuElement({id = "Enabled", name = "Potions Enabled", value = true})
	self.Menu.Healing:MenuElement({id = "UsePots", name = "Health Potions", value = true, leftIcon = "http://puu.sh/rUYAW/7fe329aa43.png"})
	self.Menu.Healing:MenuElement({id = "UseCookies", name = "Biscuit", value = true, leftIcon = "http://puu.sh/rUZL0/201b970f16.png"})
	self.Menu.Healing:MenuElement({id = "UseRefill", name = "Refillable Potion", value = true, leftIcon = "http://puu.sh/rUZPt/da7fadf9d1.png"})
	self.Menu.Healing:MenuElement({id = "UseCorrupt", name = "Corrupting Potion", value = true, leftIcon = "http://puu.sh/rUZUu/130c59cdc7.png"})
	self.Menu.Healing:MenuElement({id = "UseHunters", name = "Hunter's Potion", value = true, leftIcon = "http://puu.sh/rUZZM/46b5036453.png"})
	self.Menu.Healing:MenuElement({id = "UsePotsPercent", name = "Use if health is below:", value = 50, min = 5, max = 95, identifier = "%"})
end		

local myPotTicks = 0;
local currentlyDrinkingPotion = false;
local HealthPotionSlot = 0;
local CookiePotionSlot = 0;
local RefillablePotSlot = 0;
local CorruptPotionSlot = 0;
local HuntersPotionSlot = 0;
local InventoryTable = {};
local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}


function Activator:Tick()
	self:UseZhonya()			
	self:UseStopwatch()
	self:UsePotion()
	self:QSS()
end	

--Utility------------------------
function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end	

function HasBuff(unit, buffName)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff ~= nil and buff.count > 0 then
			if buff.name == buffName then
				local CurrentTime = Game.Timer()
				if buff.startTime <= CurrentTime + 0.1 and buff.expireTime >= CurrentTime then
					return true
				end
			end
		end
	end
	return false
end		

		function GetPercentHP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.health/unit.maxHealth
end	

function Activator:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				SetMovement(false)
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

local function myGetSlot(itemID)
local retval = 0;
for i = ITEM_1, ITEM_6 do
	if InventoryTable[i] ~= nil then
		if InventoryTable[i].itemID == itemID then
			if (itemID > 2030) and (itemID < 2034) then 
				if InventoryTable[i].ammo > 0 then
					retval = i;
					break;
					end
				else
				retval = i;
				break;
				end
			end
		end
	end
return retval
end	

-- Zhonyas + StopWatch ---------------	
function Activator:UseZhonya()
	local Z = GetInventorySlotItem(3157)
	if Z and self.Menu.ZS.Zhonya.UseZ:Value() and GetPercentHP(myHero) < self.Menu.ZS.HP.myHP:Value() then
		Control.CastSpell(HKITEM[Z], myHero)
	
	end
end	
			
function Activator:UseStopwatch()
	local S = GetInventorySlotItem(2420)
	if S and self.Menu.ZS.Stopwatch.UseS:Value() and GetPercentHP(myHero) < self.Menu.ZS.HP.myHP:Value() then
		Control.CastSpell(HKITEM[S], myHero)			
	
	end
end	

function Activator:QSS()
	local hasBuff = HasBuff(myHero, "zedrdeathmark")
	local SZ = GetInventorySlotItem(2420) or GetInventorySlotItem(3157)
	if SZ and self.Menu.ZS.QSS.UseSZ:Value() and hasBuff then
		Control.CastSpell(HKITEM[SZ], myHero)
	end
end	
	


-- Potions ---------------------

function Activator:UsePotion()
	if (myPotTicks + 1000 < GetTickCount()) and self.Menu.Healing.Enabled:Value() then
	myPotTicks = GetTickCount();
	currentlyDrinkingPotion = false;
		for i = 0, 63 do
		local buffData = myHero:GetBuff(i);
		if buffData.count > 0 then
			if (buffData.type == 13) or (buffData.type == 26) then 
				if (buffData.name == "ItemDarkCrystalFlask") or (buffData.name == "ItemCrystalFlaskJungle") or (buffData.name == "ItemCrystalFlask") or (buffData.name == "ItemMiniRegenPotion") or (buffData.name == "RegenerationPotion") then
					currentlyDrinkingPotion = true;
					break;
				end
			end
		end
	end
	local HealthPotionSlot = myGetSlot(2003);
	local CookiePotionSlot = myGetSlot(2010);
	local RefillablePotSlot = myGetSlot(2031);
	local HuntersPotionSlot = myGetSlot(2032);
	local CorruptPotionSlot = myGetSlot(2033);
	if (currentlyDrinkingPotion == false) then
		if GetPercentHP(myHero) < self.Menu.Healing.UsePotsPercent:Value() and not myHero.dead then
	
			local HP = GetInventorySlotItem(2003)
			if HP and self.Menu.Healing.UsePots:Value() and HealthPotionSlot > 0 then
			Control.CastSpell(HKITEM[HP], myHero)
			end
			local C = GetInventorySlotItem(2010)
			if C and self.Menu.Healing.UseCookies:Value() and CookiePotionSlot > 0 then
			Control.CastSpell(HKITEM[C], myHero)
			end
			local RP = GetInventorySlotItem(2031)
			if RP and self.Menu.Healing.UseRefill:Value() and RefillablePotSlot > 0 then
			Control.CastSpell(HKITEM[RP], myHero)
			end
			local CP = GetInventorySlotItem(2033)
			if CP and self.Menu.Healing.UseCorrupt:Value() and CorruptPotionSlot > 0 then
			Control.CastSpell(HKITEM[CP], myHero)
			end
			local H = GetInventorySlotItem(2032)
			if H and self.Menu.Healing.UseHunters:Value() and HuntersPotionSlot > 0 then
			Control.CastSpell(HKITEM[H], myHero)
			end
		end
	end
end
end

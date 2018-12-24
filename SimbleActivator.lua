class "Activator"

 -- [ AutoUpdate ]
do
    
    local Version = 0.06
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "SimbleActivator.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/SimbleActivator.lua"
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
	
	self.Menu = MenuElement({type = MENU, id = "Activator", name = "Activator", leftIcon = ActivatorIcon})
	--Zhonyas,Stopwatch
	self.Menu:MenuElement({id = "ZS", name = "Zhonya's + StopWatch", type = MENU})	
	self.Menu.ZS:MenuElement({id = "Zhonya", name = "Zhonya's Hourglass", type = MENU, leftIcon = ZhonyaIcon})
	self.Menu.ZS.Zhonya:MenuElement({id = "UseZ", name = "Use Zhonya's Hourglass", value = true})
	self.Menu.ZS:MenuElement({id = "Stopwatch", name = "Stopwatch", type = MENU, leftIcon = StopWatchIcon})
	self.Menu.ZS.Stopwatch:MenuElement({id = "UseS", name = "Use Stopwatch", value = true})	
	self.Menu.ZS:MenuElement({id = "HP", name = "myHP", type = MENU})
	self.Menu.ZS.HP:MenuElement({id = "myHP", name = "Use if health is below:",value = 20, min = 0, max = 100,step = 1})	
	
	self.Menu.ZS:MenuElement({id = "QSS", name = "QSS Setings", type = MENU})
	self.Menu.ZS.QSS:MenuElement({id = "UseSZ", name = "AutoUse Stopwatch or Zhonya on ZedUlt", value = true})
	
	--Potions
	self.Menu:MenuElement({id = "Healing", name = "Potions", type = MENU})
	self.Menu.Healing:MenuElement({id = "Enabled", name = "Potions Enabled", value = true})
	self.Menu.Healing:MenuElement({id = "UsePots", name = "Health Potions", value = true, leftIcon = "http://puu.sh/rUYAW/7fe329aa43.png"})
	self.Menu.Healing:MenuElement({id = "UseCookies", name = "Biscuit", value = true, leftIcon = "http://puu.sh/rUZL0/201b970f16.png"})
	self.Menu.Healing:MenuElement({id = "UseRefill", name = "Refillable Potion", value = true, leftIcon = "http://puu.sh/rUZPt/da7fadf9d1.png"})
	self.Menu.Healing:MenuElement({id = "UseCorrupt", name = "Corrupting Potion", value = true, leftIcon = "http://puu.sh/rUZUu/130c59cdc7.png"})
	self.Menu.Healing:MenuElement({id = "UseHunters", name = "Hunter's Potion", value = true, leftIcon = "http://puu.sh/rUZZM/46b5036453.png"})
	self.Menu.Healing:MenuElement({id = "UsePotsPercent", name = "Use if health is below:", value = 50, min = 5, max = 95, identifier = "%"})
	
	--Summoners
	self.Menu:MenuElement({id = "summ", name = "Summoner Spells", type = MENU})
	self.Menu.summ:MenuElement({id = "heal", name = "SummonerHeal", type = MENU, leftIcon = "http://puu.sh/rXioi/2ac872033c.png"})
	self.Menu.summ.heal:MenuElement({id = "self", name = "Heal Self", value = true})
	self.Menu.summ.heal:MenuElement({id = "ally", name = "Heal Ally", value = true})
	self.Menu.summ.heal:MenuElement({id = "selfhp", name = "Self HP:", value = 30, min = 5, max = 95, identifier = "%"})
	self.Menu.summ.heal:MenuElement({id = "allyhp", name = "Ally HP:", value = 30, min = 5, max = 95, identifier = "%"})

	self.Menu.summ:MenuElement({id = "barr", name = "SummonerBarrier", type = MENU, leftIcon = "http://puu.sh/rXjQ1/af78cc6c34.png"})
	self.Menu.summ.barr:MenuElement({id = "self", name = "Use Barrier", value = true})
	self.Menu.summ.barr:MenuElement({id = "selfhp", name = "Self HP:", value = 30, min = 5, max = 95, identifier = "%"})
	
	self.Menu.summ:MenuElement({id = "ex", name = "SummonerExhaust", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerExhaust.png"})
	self.Menu.summ.ex:MenuElement({id = "target", name = "Use Exhaust", value = true})
	self.Menu.summ.ex:MenuElement({id = "hp", name = "Target HP:", value = 30, min = 5, max = 95, identifier = "%"})
	
	self.Menu.summ:MenuElement({id = "clean", name = "SummonerCleanse", type = MENU, leftIcon = "http://puu.sh/rYrzP/5853206291.png"})
	self.Menu.summ.clean:MenuElement({id = "self", name = "Use Cleanse", value = true})
	
	self.Menu.summ:MenuElement({id = "ign", name = "SummonerIgnite", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/5.9.1/img/spell/SummonerDot.png"})
	self.Menu.summ.ign:MenuElement({id = "target", name = "Use Ignite", value = true})
	self.Menu.summ.ign:MenuElement({id = "hp", name = "Target HP:", value = 15, min = 5, max = 95, identifier = "%"})	
end	





local myPotTicks = 0;
local currentlyDrinkingPotion = false;
local HealthPotionSlot = 0;
local CookiePotionSlot = 0;
local RefillablePotSlot = 0;
local CorruptPotionSlot = 0;
local HuntersPotionSlot = 0;
local InventoryTable = {};
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	elseif _G.gsoSDK then
		return _G.gsoSDK.TargetSelector:GetTarget(GetEnemyHeroes(5000), false)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function Activator:Tick()
	self:UseZhonya()			
	self:UseStopwatch()
	self:UsePotion()
	self:QSS()
	self:Summoner()
end	

--Utility------------------------
local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

local function Cleans(unit)
	if unit == nil then return false end
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 7 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 25 or buff.type == 10 or buff.type == 31 or buff.type == 24) and buff.count > 0 then
		return true
		end
	end
	return false	
end



function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end	

function GetAllyHeroes() 
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
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

function GetPercentMP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentMP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.mana/unit.maxMana
end

function Activator:ValidTarget(unit,range) 
  return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal 
end	

function Activator:EnemiesAround(pos,range)
	local pos = pos.pos
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)
		local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
			N = N + 1
		end
	end
	return N	
end

function GetDistanceSqr(p1, p2)
	if not p1 then return math.huge end
	p2 = p2 or myHero
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
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
	if myHero.dead then return end
		if self:EnemiesAround(myHero.pos,1000) then
		local Z = GetInventorySlotItem(3157)
		if Z and self.Menu.ZS.Zhonya.UseZ:Value() and GetPercentHP(myHero) < self.Menu.ZS.HP.myHP:Value() then
			Control.CastSpell(HKITEM[Z], myHero)
		end
	end
end	
			
function Activator:UseStopwatch()
	if myHero.dead then return end
	if self:EnemiesAround(myHero.pos,1000) then
		local S = GetInventorySlotItem(2420)
		if S and self.Menu.ZS.Stopwatch.UseS:Value() and GetPercentHP(myHero) < self.Menu.ZS.HP.myHP:Value() then
			Control.CastSpell(HKITEM[S], myHero)			
		end
	end
end	

function Activator:QSS()
	if myHero.dead then return end
	local hasBuff = HasBuff(myHero, "zedrdeathmark")
	local SZ = GetInventorySlotItem(2420), GetInventorySlotItem(3157)
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
			if HP and self.Menu.Healing.UsePots:Value() and HealthPotionSlot  then
			Control.CastSpell(HKITEM[HP], myHero)
			end
			local C = GetInventorySlotItem(2010)
			if C and self.Menu.Healing.UseCookies:Value() and CookiePotionSlot  then
			Control.CastSpell(HKITEM[C], myHero)
			end
			local RP = GetInventorySlotItem(2031)
			if RP and self.Menu.Healing.UseRefill:Value() and RefillablePotSlot  then
			Control.CastSpell(HKITEM[RP], myHero)
			end
			local CP = GetInventorySlotItem(2033)
			if CP and self.Menu.Healing.UseCorrupt:Value() and CorruptPotionSlot  then
			Control.CastSpell(HKITEM[CP], myHero)
			end
			local H = GetInventorySlotItem(2032)
			if H and self.Menu.Healing.UseHunters:Value() and HuntersPotionSlot  then
			Control.CastSpell(HKITEM[H], myHero)
			end
		end
	end
end
end

--Summoners-------------------------

function Activator:Summoner()
if myHero.dead then return end
target = CurrentTarget(2000)
if target == nil then return end
local MyHp = GetPercentHP(myHero)
local MyMp = GetPercentMP(myHero)

for i = 1, Game.HeroCount() do
local hero = Game.Hero(i)	
	if target then
		if self.Menu.summ.heal.self:Value() and MyHp <= self.Menu.summ.heal.selfhp:Value() then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and Ready(SUMMONER_1) then
				Control.CastSpell(HK_SUMMONER_1, myHero)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and Ready(SUMMONER_2) then
				Control.CastSpell(HK_SUMMONER_2, myHero)
			end
		end
		for i,ally in pairs(GetAllyHeroes()) do
		local AllyHp = GetPercentHP(ally)
		if self.Menu.summ.heal.ally:Value() and AllyHp <= self.Menu.summ.heal.allyhp:Value() then
			if self:ValidTarget(ally, 1000) and myHero.pos:DistanceTo(ally.pos) <= 850 and ally.dead == false then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1, ally)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2, ally)
				end
			end
		end	
		end
		if self.Menu.summ.barr.self:Value() and MyHp <= self.Menu.summ.barr.selfhp:Value() then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier" and Ready(SUMMONER_1) then
				Control.CastSpell(HK_SUMMONER_1, myHero)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" and Ready(SUMMONER_2) then
				Control.CastSpell(HK_SUMMONER_2, myHero)
			end
		end	
		local Immobile = Cleans(myHero)
		if self.Menu.summ.clean.self:Value() and Immobile then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost" and Ready(SUMMONER_1) then
				Control.CastSpell(HK_SUMMONER_1, myHero)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" and Ready(SUMMONER_2) then
				Control.CastSpell(HK_SUMMONER_2, myHero)
			end
		end
		local TargetHp = GetPercentHP(hero)
		if self.Menu.summ.ex.target:Value() then	
			if hero.isEnemy and not hero.dead and myHero.pos:DistanceTo(hero.pos) <= 650 and TargetHp <= self.Menu.summ.ex.hp:Value() then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1, hero)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2, hero)
				end
			end
		end
		local TargetHp = GetPercentHP(hero)
		if self.Menu.summ.ign.target:Value() and TargetHp <= self.Menu.summ.ign.hp:Value()  then	
			if myHero.pos:DistanceTo(hero.pos) <= 600 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1, hero)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2, hero)
				end
			end
		end			
	end
	end
end

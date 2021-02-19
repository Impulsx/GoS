

-- [ AutoUpdate ]

do
    
    local Version = 0.32
    
    local Files =
    {
        Lua =
        {
            Path = SCRIPT_PATH,
            Name = "SimbleActivator.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/SimbleActivator.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "SimbleActivator.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/SimbleActivator.version"
        },
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
            print("New PussyActivator Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
        
    end
    
    AutoUpdate()
    
end

local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6,}
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local MathSqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local AllyMenuLoaded = false

local myPotTicks = 0;
local myHealTicks = 0;
local myShieldTicks = 0;
local myAntiCCTicks = 0;

local hotkeyTable = {};
hotkeyTable[ITEM_1] = HK_ITEM_1;
hotkeyTable[ITEM_2] = HK_ITEM_2;
hotkeyTable[ITEM_3] = HK_ITEM_3;
hotkeyTable[ITEM_4] = HK_ITEM_4;
hotkeyTable[ITEM_5] = HK_ITEM_5;
hotkeyTable[ITEM_6] = HK_ITEM_6;
local InventoryTable = {};
local currentlyDrinkingPotion = false;
local HealthPotionSlot = 0;
local CookiePotionSlot = 0;
local RefillablePotSlot = 0;
local CorruptPotionSlot = 0;

function LoadUnits()
	for i = 1, GameHeroCount() do
		local unit = GameHero(i); Units[i] = {unit = unit, spell = nil}
		if unit.team ~= myHero.team then TableInsert(Enemies, unit)
		elseif unit.team == myHero.team and unit ~= myHero then TableInsert(Allies, unit) end
	end
	for i = 1, GameTurretCount() do
		local turret = GameTurret(i)
		if turret and turret.isEnemy then TableInsert(Turrets, turret) end
	end
end

local function Ready(spell)
    return Game.CanUseSpell(spell) == 0
end

local function GetTarget(range) 
	if _G.SDK then
		if myHero.ap > myHero.totalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
		end
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end
end

local function GetMode()
    if _G.SDK then
        return 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "LaneClear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] and "LaneClear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] and "LastHit"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] and "Flee"
		or nil
    
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetMode()
	end
	return nil
end

local function GetAllyHeroes() 
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.team ~= myHero.team then
			TableInsert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local function GetDistanceSqr(p1, p2)
    if not p1 then return MathHuge end
    p2 = p2 or myHero
    local dx = p1.x - p2.x
    local dz = (p1.z or p1.y) - (p2.z or p2.y)
    return dx * dx + dz * dz
end

local function GetDistance(p1, p2)
	p2 = p2 or myHero
	return MathSqrt(GetDistanceSqr(p1, p2))
end

local function CastSpellMM(spell,pos,range,delay)
local range = range or MathHuge
local delay = delay or 250
local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
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

local function IsRecalling()
	for i = 1, 63 do
	local buff = myHero:GetBuff(i) 
		if buff.count > 0 and buff.name == "recall" and Game.Timer() < buff.expireTime then
			return true
		end
	end 
	return false
end

local function MyHeroNotReady()
    return myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero) 
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function GetInventorySlotItem(itemID)
    assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
    for _, j in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
        if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
    end
    return nil
end

local MarkTable = {
	SRU_Baron = "MarkBaron",
	SRU_RiftHerald = "MarkHerald",
	SRU_Dragon_Water = "MarkDragon",
	SRU_Dragon_Fire = "MarkDragon",
	SRU_Dragon_Earth = "MarkDragon",
	SRU_Dragon_Air = "MarkDragon",
	SRU_Dragon_Elder = "MarkDragon",
	SRU_Blue = "MarkBlue",
	SRU_Red = "MarkRed",
	SRU_Gromp = "MarkGromp",
	SRU_Murkwolf = "MarkWolves",
	SRU_Razorbeak = "MarkRazorbeaks",
	SRU_Krug = "MarkKrugs",
	Sru_Crab = "MarkCrab",
}

local SmiteTable = {
	SRU_Baron = "SmiteBaron",
	SRU_RiftHerald = "SmiteHerald",
	SRU_Dragon_Water = "SmiteDragon",
	SRU_Dragon_Fire = "SmiteDragon",
	SRU_Dragon_Earth = "SmiteDragon",
	SRU_Dragon_Air = "SmiteDragon",
	SRU_Dragon_Elder = "SmiteDragon",
	SRU_Blue = "SmiteBlue",
	SRU_Red = "SmiteRed",
	SRU_Gromp = "SmiteGromp",
	SRU_Murkwolf = "SmiteWolves",
	SRU_Razorbeak = "SmiteRazorbeaks",
	SRU_Krug = "SmiteKrugs",
	Sru_Crab = "SmiteCrab",
}

local function myGetSlot(itemID)
local retval = 0;
for i = ITEM_1, ITEM_6 do
	if InventoryTable[i] ~= nil then
		if InventoryTable[i].itemID == itemID then
			if (itemID > 2030) and (itemID < 2034) then --potion solution
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

class "Activator"

local SmiteNames = {'SummonerSmite','S5_SummonerSmiteDuel','S5_SummonerSmitePlayerGanker','S5_SummonerSmiteQuick','ItemSmiteAoE'};
local SmiteDamage = {390 , 410 , 430 , 450 , 480 , 510 , 540 , 570 , 600 , 640 , 680 , 720 , 760 , 800 , 850 , 900 , 950 , 1000};
local mySmiteSlot = 0;

function Activator:__init()
    self:LoadMenu()
	self:OnLoad()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:OnDraw() end)
	
end

function Activator:LoadMenu()
    
    self.Menu = MenuElement({type = MENU, id = "PussyActivator", leftIcon = "https://raw.githubusercontent.com/Pussykate/GoS/master/PageImage/ActivatorScriptLogo.png"})
	self.Menu:MenuElement({name = " ", drop = {"Version 0.32"}})    
	
	--Shield/Heal MyHero
    self.Menu:MenuElement({id = "ZS", name = "MyHero/Ally [Shield/Heal Items]", type = MENU})
	
	self.Menu.ZS:MenuElement({type = MENU, id = "MikaCC2", name = "CC Types: Mikael's Blessing"})			
	self.Menu.ZS.MikaCC2:MenuElement({ id = "Stun", name = "Use on Stun", value = true})
	self.Menu.ZS.MikaCC2:MenuElement({ id = "Silence", name = "Use on Silence", value = true})
	self.Menu.ZS.MikaCC2:MenuElement({ id = "Taunt", name = "Use on Taunt", value = true})
	self.Menu.ZS.MikaCC2:MenuElement({ id = "Polymorph", name = "Use on Polymorph", value = true})
	self.Menu.ZS.MikaCC2:MenuElement({ id = "Slow", name = "Use on Slow", value = true})
	self.Menu.ZS.MikaCC2:MenuElement({ id = "Snare", name = "Use on Snare", value = true})
	self.Menu.ZS.MikaCC2:MenuElement({ id = "Fear", name = "Use on Fear", value = true})
	self.Menu.ZS.MikaCC2:MenuElement({ id = "Charm", name = "Use on Charm", value = true})		
	
	self.Menu.ZS:MenuElement({type = MENU, id = "MikaCC", name = "CC Types: Mercurial / Qss / Silvermere"})			
	self.Menu.ZS.MikaCC:MenuElement({ id = "Stun", name = "Use on Stun", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Silence", name = "Use on Silence", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Taunt", name = "Use on Taunt", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Polymorph", name = "Use on Polymorph", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Slow", name = "Use on Slow", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Snare", name = "Use on Snare", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Fear", name = "Use on Fear", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Charm", name = "Use on Charm", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Suppression", name = "Use on Suppression", value = true})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Blind", name = "Use on Blind", value = true})
	--self.Menu.ZS.MikaCC:MenuElement({ id = "KnockUp", name = "Use on KnockUp", value = false})
	--self.Menu.ZS.MikaCC:MenuElement({ id = "KnockBack", name = "Use on KnockBack", value = false})
	self.Menu.ZS.MikaCC:MenuElement({ id = "Disarm", name = "Use on Disarm", value = true})	
	
    self.Menu.ZS:MenuElement({id = "self", name = "MyHero Shield + Heal Items", type = MENU})	

    self.Menu.ZS.self:MenuElement({id = "UseZ", name = "Zhonya's", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3157.png"})
	self.Menu.ZS.self:MenuElement({id = "myHPZ", name = "If my Hero HP lower than", value = 30, min = 0, max = 100, step = 1, identifier = "%"})

    self.Menu.ZS.self:MenuElement({id = "UseS", name = "Stopwatch", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/2420.png"})
 	self.Menu.ZS.self:MenuElement({id = "myHPS", name = "If my Hero HP lower than", value = 30, min = 0, max = 100, step = 1, identifier = "%"})   

    self.Menu.ZS.self:MenuElement({id = "Iron", name = "Locket of the Iron Solari", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3190.png"})	
	self.Menu.ZS.self:MenuElement({id = "IronHP", name = "If my Hero HP lower than", value = 30, min = 0, max = 100, step = 1, identifier = "%"})
	
    self.Menu.ZS.self:MenuElement({id = "Red", name = "Redemption", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3107.png"})
	self.Menu.ZS.self:MenuElement({id = "RedHP", name = "If my Hero HP lower than", value = 30, min = 0, max = 100, step = 1, identifier = "%"})

    self.Menu.ZS.self:MenuElement({id = "UseG", name = "Gargoyle Stoneplate", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3193.png"})
	self.Menu.ZS.self:MenuElement({id = "myHPG", name = "If my Hero HP lower than", value = 30, min = 0, max = 100, step = 1, identifier = "%"})	

	self.Menu.ZS.self:MenuElement({id = "Mira", name = "Mercurial Scimittar[AntiCC]", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3139.png"})    
    self.Menu.ZS.self:MenuElement({id = "Quick", name = "Quicksilver Sash[AntiCC]", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3140.png"})    
    self.Menu.ZS.self:MenuElement({id = "Mika", name = "Mikael's Blessing[AntiCC]", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3222.png"})
    self.Menu.ZS.self:MenuElement({id = "Dawn", name = "Silvermere Dawn[AntiCC]", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6035.png"})    

------------------------------------------------------------------------------------------------------------------------------------------------------	
	--Shield/Heal Ally    
	
	self.Menu.ZS:MenuElement({id = "ally", name = "Ally Shield + Heal Items", type = MENU}) 

	DelayAction(function()		
		for i = 1, GameHeroCount() do
        local unit = GameHero(i)
			if unit and unit.team == myHero.team and unit ~= myHero then
				self.Menu.ZS.ally:MenuElement({id = unit.charName, name = unit.charName, type = MENU}) 
			end	
		end
	end,0.3)

-----------------------------------------------------------------------------------------------------------------------------------------------------------
	--Target Items

    self.Menu:MenuElement({id = "Dmg", name = "TargetItems [ComboMode]", type = MENU})
		
	self.Menu.Dmg:MenuElement({id = "Stride", name = "Stridebreaker", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6631.png"})		
	self.Menu.Dmg:MenuElement({id = "Claw", name = "Prowler's Claw", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6693.png"})	
 	self.Menu.Dmg:MenuElement({id = "Hex", name = "Hextech Rocketbelt", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3152.png"})		
 	self.Menu.Dmg:MenuElement({id = "Gale", name = "Galeforce", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6671.png"}) 	
	self.Menu.Dmg:MenuElement({id = "Gale2", name = "Galeforce if Enemy miss Hp bigger than ->", value = 60, min = 0, max = 70, identifier = "%"})
	self.Menu.Dmg:MenuElement({id = "Gale3", name = "Galeforce max Range", value = 800, min = 250, max = 1000, step = 10}) 	
	self.Menu.Dmg:MenuElement({id = "EFrost", name = "EverFrost", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6656.png"}) 	      
 	self.Menu.Dmg:MenuElement({id = "Omen", name = "Randuin's Omen", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3143.png"})	
 	self.Menu.Dmg:MenuElement({id = "Ocount", name = "Randuin's Omen min Targets", value = 2, min = 1, max = 5, step = 1})	
 	self.Menu.Dmg:MenuElement({id = "Gore", name = "Goredrinker", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6630.png"})
 	self.Menu.Dmg:MenuElement({id = "Gorecount", name = "Goredrinker min Targets", value = 2, min = 1, max = 5, step = 1})
    self.Menu.Dmg:MenuElement({id = "Gorehp", name = "Goredrinker if self HP lower than ->", value = 40, min = 5, max = 95, identifier = "%"})	
	self.Menu.Dmg:MenuElement({id = "Whip", name = "Ironspike Whip", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6029.png"})
 	self.Menu.Dmg:MenuElement({id = "Whipcount", name = "Ironspike Whip min Targets", value = 2, min = 1, max = 5, step = 1})	
	self.Menu.Dmg:MenuElement({id = "Shur", name = "Shurelya's Battlesong", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/2065.png"})
	self.Menu.Dmg:MenuElement({id = "ShurRange", name = "Shurelya's if Enemy in range", value = 1000, min = 100, max = 2000, step = 50})
 	self.Menu.Dmg:MenuElement({id = "Shurcount", name = "Shurelya's min Allies near", value = 1, min = 0, max = 4, step = 1}) 
	self.Menu.Dmg:MenuElement({id = "Turbo", name = "Turbo Chemtank", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/6664.png"})
	self.Menu.Dmg:MenuElement({id = "TurboRange", name = "Turbo Chemtank if Enemy in range", value = 700, min = 100, max = 2000, step = 50})	

------------------------------------------------------------------------------------------------------------------------------------------------------------
    --Potions
    self.Menu:MenuElement({id = "Healing", name = "Potions", type = MENU})
    
	self.Menu.Healing:MenuElement({id = "Enabled", name = "Potions Enabled", value = true})
    self.Menu.Healing:MenuElement({id = "UsePots", name = "Health Potions", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/2003.png"})
    self.Menu.Healing:MenuElement({id = "UseCookies", name = "Biscuit", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/2010.png"})
    self.Menu.Healing:MenuElement({id = "UseRefill", name = "Refillable Potion", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/2031.png"})
    self.Menu.Healing:MenuElement({id = "UseCorrupt", name = "Corrupting Potion", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/2033.png"})
    self.Menu.Healing:MenuElement({id = "UsePotsPercent", name = "Use if health is below:", value = 50, min = 5, max = 95, identifier = "%"})
    
    --Summoners
    self.Menu:MenuElement({id = "summ", name = "Summoner Spells", type = MENU})
    self.Menu.summ:MenuElement({id = "heal", name = "SummonerHeal", type = MENU, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerHeal.png"})
    self.Menu.summ.heal:MenuElement({id = "self", name = "Heal Self", value = true})
    self.Menu.summ.heal:MenuElement({id = "ally", name = "Heal Ally", value = true})
    self.Menu.summ.heal:MenuElement({id = "selfhp", name = "Self HP:", value = 30, min = 5, max = 95, identifier = "%"})
    self.Menu.summ.heal:MenuElement({id = "allyhp", name = "Ally HP:", value = 30, min = 5, max = 95, identifier = "%"})
    
    self.Menu.summ:MenuElement({id = "barr", name = "SummonerBarrier", type = MENU, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerBarrier.png"})
    self.Menu.summ.barr:MenuElement({id = "self", name = "Use Barrier", value = true})
    self.Menu.summ.barr:MenuElement({id = "selfhp", name = "Self HP:", value = 30, min = 5, max = 95, identifier = "%"})
    
    self.Menu.summ:MenuElement({id = "ex", name = "SummonerExhaust", type = MENU, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerExhaust.png"})
    self.Menu.summ.ex:MenuElement({id = "target", name = "Use Exhaust", value = true})
    self.Menu.summ.ex:MenuElement({id = "hp", name = "Target HP:", value = 30, min = 5, max = 95, identifier = "%"})
    
    self.Menu.summ:MenuElement({id = "clean", name = "SummonerCleanse", type = MENU, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerBoost.png"})
    self.Menu.summ.clean:MenuElement({id = "self", name = "Use Cleanse", value = true})
    
    self.Menu.summ:MenuElement({id = "ign", name = "SummonerIgnite", type = MENU, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerDot.png"})
	self.Menu.summ.ign:MenuElement({id = "Enabled1", name = "Use Ignite", value = true}) 		
	self.Menu.summ.ign:MenuElement({id = "ST", name = "Ignite TargetHp or Ks ?", value = 2, drop = {"TargetHP [ComboMode]", "KillSteal"}})   
    self.Menu.summ.ign:MenuElement({id = "hp", name = "TargetHP:", value = 30, min = 5, max = 95, identifier = "%"})
	
    self.Menu.summ:MenuElement({id = "SmiteMenu", name = "SummonerSmite", type = MENU, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/spell/SummonerSmite.png"})
	self.Menu.summ.SmiteMenu:MenuElement({id = "Enabled", name = "Enabled[OfficialSmiteManager]", value = true})
	
	self.Menu.summ.SmiteMenu:MenuElement({type = MENU, id = "SmiteMarker", name = "Smite Marker Minions"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkBaron", name = "Mark Baron", value = true, leftIcon = "https://puu.sh/rPuVv/933a78e350.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkHerald", name = "Mark Herald", value = true, leftIcon = "https://puu.sh/rQs4A/47c27fa9ea.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkDragon", name = "Mark Dragon", value = true, leftIcon = "https://puu.sh/rPvdF/a00d754b30.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkBlue", name = "Mark Blue Buff", value = true, leftIcon = "https://puu.sh/rPvNd/f5c6cfb97c.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkRed", name = "Mark Red Buff", value = true, leftIcon = "https://puu.sh/rPvQs/fbfc120d17.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkGromp", name = "Mark Gromp", value = true, leftIcon = "https://puu.sh/rPvSY/2cf9ff7a8e.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkWolves", name = "Mark Wolves", value = true, leftIcon = "https://puu.sh/rPvWu/d9ae64a105.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkRazorbeaks", name = "Mark Razorbeaks", value = true, leftIcon = "https://puu.sh/rPvZ5/acf0e03cc7.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkKrugs", name = "Mark Krugs", value = true, leftIcon = "https://puu.sh/rPw6a/3096646ec4.png"})
	self.Menu.summ.SmiteMenu.SmiteMarker:MenuElement({id = "MarkCrab", name = "Mark Crab", value = true, leftIcon = "https://puu.sh/rPwaw/10f0766f4d.png"})
	
	self.Menu.summ.SmiteMenu:MenuElement({type = MENU, id = "AutoSmiter", name = "Auto Smite Minions"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "Enabled", name = "Toggle Enable Key", key = string.byte("M"), toggle = true})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "DrawSTS", name = "Draw Smite Toggle State", value = true})
	
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteBaron", name = "Smite Baron", value = true, leftIcon = "https://puu.sh/rPuVv/933a78e350.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteHerald", name = "Smite Herald", value = true, leftIcon = "https://puu.sh/rQs4A/47c27fa9ea.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteDragon", name = "Smite Dragon", value = true, leftIcon = "https://puu.sh/rPvdF/a00d754b30.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteBlue", name = "Smite Blue Buff", value = true, leftIcon = "https://puu.sh/rPvNd/f5c6cfb97c.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteRed", name = "Smite Red Buff", value = true, leftIcon = "https://puu.sh/rPvQs/fbfc120d17.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteGromp", name = "Smite Gromp", value = false, leftIcon = "https://puu.sh/rPvSY/2cf9ff7a8e.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteWolves", name = "Smite Wolves", value = false, leftIcon = "https://puu.sh/rPvWu/d9ae64a105.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteRazorbeaks", name = "Smite Razorbeaks", value = false, leftIcon = "https://puu.sh/rPvZ5/acf0e03cc7.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteKrugs", name = "Smite Krugs", value = false, leftIcon = "https://puu.sh/rPw6a/3096646ec4.png"})
	self.Menu.summ.SmiteMenu.AutoSmiter:MenuElement({id = "SmiteCrab", name = "Smite Crab", value = false, leftIcon = "https://puu.sh/rPwaw/10f0766f4d.png"})
	
	self.Menu.summ.SmiteMenu:MenuElement({type = MENU, id = "AutoSmiterH", name = "Smite Heroes [Combo Mode]"})
	self.Menu.summ.SmiteMenu.AutoSmiterH:MenuElement({id = "On", name = "Use Smite Enemies", value = true})		
	self.Menu.summ.SmiteMenu.AutoSmiterH:MenuElement({id = "Enabled", name = "Smite Logic", value = 1, drop = {"Smite Always", "Smite KillSteal"}})
	self.Menu.summ.SmiteMenu.AutoSmiterH:MenuElement({id = "Ammo", name = "Safe 1 Smite for Jungle", value = true})	
end

function Activator:LoadAllyMenu()
	for i, unit in ipairs(GetAllyHeroes()) do
		if self.Menu.ZS.ally[unit.charName] then
			self.Menu.ZS.ally[unit.charName]:MenuElement({ id = "Red", name = "Redemption", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3107.png"})
			self.Menu.ZS.ally[unit.charName]:MenuElement({id = "allyHP", name = "Redemption / if AllyHP lower than", value = 30, min = 0, max = 100, step = 1, identifier = "%"}) 
			self.Menu.ZS.ally[unit.charName]:MenuElement({ id = "Iron", name = "Locket of the Iron Solari", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3190.png"})
			self.Menu.ZS.ally[unit.charName]:MenuElement({id = "IronHP", name = "Iron Solari / if AllyHP lower than", value = 30, min = 0, max = 100, step = 1, identifier = "%"})
			self.Menu.ZS.ally[unit.charName]:MenuElement({ id = "Mika", name = "Mikael's Blessing[AntiCC]", value = true, leftIcon = "https://ddragon.leagueoflegends.com/cdn/10.23.1/img/item/3222.png"})			
		end
	end
end	

function Activator:Tick()
	if not AllyMenuLoaded then 
		for i, unit in ipairs(GetAllyHeroes()) do
			if unit then
				self:LoadAllyMenu()
				AllyMenuLoaded = true
			end
		end	
	end

	if MyHeroNotReady() then return end  
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Target()
		self:Auto()
		if self.Menu.summ.SmiteMenu.Enabled:Value() then
			self:SmiteEnemy()
		end	
	end	

	self:MyHero()
    self:Ally()
    self:Summoner()
	self:Pots()
	if self.Menu.summ.SmiteMenu.Enabled:Value() then
		self:Smite()
	end

	if self.Menu.summ.ign.Enabled1:Value() then
		self:Ignite()
	end
end

function Activator:GetSmite(smiteSlot)
	local returnVal = 0;
	local spellName = myHero:GetSpellData(smiteSlot).name;
	for i = 1, 5 do
		if spellName == SmiteNames[i] then
			returnVal = smiteSlot
		end
	end
	return returnVal;
end

function Activator:Cleans2(unit)
	local CleanBuffs =
	{
		[5]  = self.Menu.ZS.MikaCC2.Stun:Value(),				--Stun
		[7]  = self.Menu.ZS.MikaCC2.Silence:Value(),			--Silence
		[8]  = self.Menu.ZS.MikaCC2.Taunt:Value(),				--Taunt
		[9]  = self.Menu.ZS.MikaCC2.Polymorph:Value(),			--Polymorph
		[10] = self.Menu.ZS.MikaCC2.Slow:Value(),				--Slow
		[11] = self.Menu.ZS.MikaCC2.Snare:Value(),				--Snare
		[21] = self.Menu.ZS.MikaCC2.Fear:Value(),				--Fear
		[22] = self.Menu.ZS.MikaCC2.Charm:Value(),				--Charm
	}    
	
	for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff then
            local bCount = buff.count;
            local bType = buff.type;
            if (bCount and bType and bCount > 0 and CleanBuffs[bType]) then
                return true
            end
        end
    end
    return false
end

function Activator:Cleans(unit)
	local CleanBuffs =
	{
		[5]  = self.Menu.ZS.MikaCC.Stun:Value(),				--Stun
		[7]  = self.Menu.ZS.MikaCC.Silence:Value(),				--Silence
		[8]  = self.Menu.ZS.MikaCC.Taunt:Value(),				--Taunt
		[9]  = self.Menu.ZS.MikaCC.Polymorph:Value(),			--Polymorph
		[10] = self.Menu.ZS.MikaCC.Slow:Value(),				--Slow
		[11] = self.Menu.ZS.MikaCC.Snare:Value(),				--Snare
		[21] = self.Menu.ZS.MikaCC.Fear:Value(),				--Fear
		[22] = self.Menu.ZS.MikaCC.Charm:Value(),				--Charm
		[24] = self.Menu.ZS.MikaCC.Suppression:Value(),			--Suppression
		[25] = self.Menu.ZS.MikaCC.Blind:Value(),				--Blind
		--[29] = self.Menu.ZS.MikaCC.KnockUp:Value(),			--KnockUp
		--[30] = self.Menu.ZS.MikaCC.KnockBack:Value(),			--KnockBack
		[31] = self.Menu.ZS.MikaCC.Disarm:Value()				--Disarm
	}    
	
	for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff then
            local bCount = buff.count;
            local bType = buff.type;
            if (bCount and bType and bCount > 0 and CleanBuffs[bType]) then
                return true
            end
        end
    end
    return false
end

function Activator:EnemiesAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i, hero in ipairs(GetEnemyHeroes()) do
        if (IsValid(hero) and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end

function Activator:AlliesAround(pos, range)
    local pos = pos.pos
    local N = 0
    for i, hero in ipairs(GetAllyHeroes()) do
        if (IsValid(hero) and GetDistanceSqr(pos, hero.pos) < range * range) then
            N = N + 1
        end
    end
    return N
end

function Activator:OnLoad()
	mySmiteSlot = self:GetSmite(SUMMONER_1);
	if mySmiteSlot == 0 then
		mySmiteSlot = self:GetSmite(SUMMONER_2);
	end
end

function Activator:DrawSmiteableMinion(type,minion)
	if not type or not self.Menu.summ.SmiteMenu.SmiteMarker[type] then
		return
	end
	if self.Menu.summ.SmiteMenu.SmiteMarker[type]:Value() then
		if minion.pos2D.onScreen then
			DrawCircle(minion.pos,minion.boundingRadius,6,DrawColor(0xFF00FF00));
		end
	end
end

function Activator:AutoSmiteMinion(type,minion)
	if not type or not self.Menu.summ.SmiteMenu.AutoSmiter[type] then
		return
	end
	if self.Menu.summ.SmiteMenu.AutoSmiter[type]:Value() then
		if minion.pos2D.onScreen then
			if mySmiteSlot == SUMMONER_1 then
				Control.CastSpell(HK_SUMMONER_1,minion)
			else
				Control.CastSpell(HK_SUMMONER_2,minion)
			end
		end
	end
end

function Activator:Smite()
if mySmiteSlot == 0 then return end	
	if self.Menu.summ.SmiteMenu.SmiteMarker.Enabled:Value() or self.Menu.summ.SmiteMenu.AutoSmiter.Enabled:Value() then 
		local SData = myHero:GetSpellData(mySmiteSlot);
		for i = 1, GameMinionCount() do
			minion = GameMinion(i);
			if minion and minion.valid and minion.team == TEAM_JUNGLE and minion.visible and not minion.dead then
				if minion.health <= SmiteDamage[myHero.levelData.lvl] then
					local minionName = minion.charName;
					if self.Menu.summ.SmiteMenu.SmiteMarker.Enabled:Value() then
						self:DrawSmiteableMinion(MarkTable[minionName], minion);
					end
					if self.Menu.summ.SmiteMenu.AutoSmiter.Enabled:Value() then
						if mySmiteSlot > 0 then
							if SData.level > 0 then
								if (SData.ammo > 0) then
									if minion.distance <= (500+myHero.boundingRadius+minion.boundingRadius) then
										self:AutoSmiteMinion(SmiteTable[minionName], minion);
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function Activator:SmiteEnemy()	
local target = GetTarget(800)
if target == nil or mySmiteSlot == 0 then return end
	if self.Menu.summ.SmiteMenu.AutoSmiterH.On:Value() and myHero.pos:DistanceTo(target.pos) <= (500+myHero.boundingRadius+target.boundingRadius) and IsValid(target) then	
	local smiteDmg = 20+8*myHero.levelData.lvl;
	local SData = myHero:GetSpellData(mySmiteSlot);
	
		if mySmiteSlot > 0 and SData.name == "S5_SummonerSmiteDuel" or SData.name == "S5_SummonerSmitePlayerGanker" then	

			if self.Menu.summ.SmiteMenu.AutoSmiterH.Ammo:Value() then
				
				if self.Menu.summ.SmiteMenu.AutoSmiterH.Enabled:Value() == 2 then
					if SData.level > 0 then
						if (SData.ammo > 1) then

							if target.health <= smiteDmg then
								if mySmiteSlot == SUMMONER_1 and Ready(SUMMONER_1) then
									Control.CastSpell(HK_SUMMONER_1,target)
									
								end	
								if mySmiteSlot == SUMMONER_2 and Ready(SUMMONER_2) then
									Control.CastSpell(HK_SUMMONER_2,target)
								end
							end
						end
					end
			
				elseif self.Menu.summ.SmiteMenu.AutoSmiterH.Enabled:Value() == 1 then
					if SData.level > 0 then
						if (SData.ammo > 1) then

							if mySmiteSlot == SUMMONER_1 and Ready(SUMMONER_1) then
								Control.CastSpell(HK_SUMMONER_1,target)
							end	
							if mySmiteSlot == SUMMONER_2 and Ready(SUMMONER_2) then
								Control.CastSpell(HK_SUMMONER_2,target)
							end
						end
					end
				end
			
			elseif not self.Menu.summ.SmiteMenu.AutoSmiterH.Ammo:Value() then
			
				if self.Menu.summ.SmiteMenu.AutoSmiterH.Enabled:Value() == 2 then
					if SData.level > 0 then
						if (SData.ammo > 0) then

							if target.health <= smiteDmg then
								if mySmiteSlot == SUMMONER_1 and Ready(SUMMONER_1) then
									Control.CastSpell(HK_SUMMONER_1,target)
									
								end	
								if mySmiteSlot == SUMMONER_2 and Ready(SUMMONER_2) then
									Control.CastSpell(HK_SUMMONER_2,target)
								end
							end
						end
					end
			
				elseif self.Menu.summ.SmiteMenu.AutoSmiterH.Enabled:Value() == 1 then
					if SData.level > 0 then
						if (SData.ammo > 0) then

							if mySmiteSlot == SUMMONER_1 and Ready(SUMMONER_1) then
								Control.CastSpell(HK_SUMMONER_1,target)
							end	
							if mySmiteSlot == SUMMONER_2 and Ready(SUMMONER_2) then
								Control.CastSpell(HK_SUMMONER_2,target)
							end
						end
					end
				end
			end
		end
	end
end

function Activator:OnDraw()
	if self.Menu.summ.SmiteMenu.Enabled:Value() and (mySmiteSlot > 0) then
		if self.Menu.summ.SmiteMenu.AutoSmiter.DrawSTS:Value() then
		local myKey = self.Menu.summ.SmiteMenu.AutoSmiter.Enabled:Key();
		if self.Menu.summ.SmiteMenu.AutoSmiter.Enabled:Value() then
			if myKey > 0 then DrawText("Smite On ".."["..string.char(self.Menu.summ.SmiteMenu.AutoSmiter.Enabled:Key()).."]",18,myHero.pos2D.x-70,myHero.pos2D.y+70,DrawColor(255, 30, 230, 30)) end;
			else
			if myKey > 0 then DrawText("Smite Off ".."["..string.char(self.Menu.summ.SmiteMenu.AutoSmiter.Enabled:Key()).."]",18,myHero.pos2D.x-70,myHero.pos2D.y+70,DrawColor(255, 230, 30, 30)) end;
			end
		end	
	end
end

-- MyHero Items ---------------

function Activator:MyHero()
	local Zo, St, Mi, Qu, Mik, Iro, Re, Ga, Da = GetInventorySlotItem(3157), GetInventorySlotItem(2420), GetInventorySlotItem(3139), GetInventorySlotItem(3140), GetInventorySlotItem(3222), GetInventorySlotItem(3190), GetInventorySlotItem(3107), GetInventorySlotItem(3193), GetInventorySlotItem(6035)   		
	local Immobile = self:Cleans(myHero)
	local Immobile2 = self:Cleans2(myHero)	

	if Immobile2 then
		if Mik and self.Menu.ZS.self.Mika:Value() then
            Control.CastSpell(ItemHotKey[Mik], myHero)
        end
	end	
	
	if Immobile then
		
		if Mi and self.Menu.ZS.self.Mira:Value() then
            Control.CastSpell(ItemHotKey[Mi])
        end
		
		if Qu and self.Menu.ZS.self.Quick:Value() then
            Control.CastSpell(ItemHotKey[Qu])
        end

		if Da and self.Menu.ZS.self.Dawn:Value() then
            Control.CastSpell(ItemHotKey[Da], myHero)
        end			
	end
	
	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy and GetDistance(myHero.pos, enemy.pos) < 2000 and IsValid(enemy) and enemy.activeSpell.target == myHero.handle then
			
			if Zo and self.Menu.ZS.self.UseZ:Value() and myHero.health/myHero.maxHealth < self.Menu.ZS.self.myHPZ:Value()/100 then
				Control.CastSpell(ItemHotKey[Zo])
			end
		
			if St and self.Menu.ZS.self.UseS:Value() and myHero.health/myHero.maxHealth < self.Menu.ZS.self.myHPS:Value()/100 then
				Control.CastSpell(ItemHotKey[St])
			end

			if Iro and self.Menu.ZS.self.Iron:Value() and myHero.health/myHero.maxHealth < self.Menu.ZS.self.IronHP:Value()/100 then
				Control.CastSpell(ItemHotKey[Iro])
			end	

			if Re and self.Menu.ZS.self.Red:Value() and myHero.health/myHero.maxHealth < self.Menu.ZS.self.RedHP:Value()/100 then
				Control.CastSpell(ItemHotKey[Re], myHero.pos)
			end	

			if Ga and self.Menu.ZS.self.UseG:Value() and myHero.health/myHero.maxHealth < self.Menu.ZS.self.myHPG:Value()/100 then
				Control.CastSpell(ItemHotKey[Ga])
			end			
		end
	end	
end   

-- Ally Items ---------------

function Activator:Ally()
	for i, ally in pairs(GetAllyHeroes()) do
		if ally then
			local EnemyNear = self:EnemiesAround(ally, 1500)	
			local Re, Mik, Iro = GetInventorySlotItem(3107), GetInventorySlotItem(3222), GetInventorySlotItem(3190)	

			if Mik and self.Menu.ZS.ally[ally.charName].Mika and self.Menu.ZS.ally[ally.charName].Mika:Value() and myHero.pos:DistanceTo(ally.pos) <= 650 and not ally.dead and self:Cleans2(ally) and EnemyNear > 0 then 
				Control.CastSpell(ItemHotKey[Mik], ally)
			end	
			
			for k, enemy in pairs(GetEnemyHeroes()) do
				if enemy and GetDistance(myHero.pos, enemy.pos) < 2000 and IsValid(enemy) and enemy.activeSpell.target == ally.handle then			
					if Re and self.Menu.ZS.ally[ally.charName].Red and self.Menu.ZS.ally[ally.charName].Red:Value() and ally.health/ally.maxHealth < self.Menu.ZS.ally[ally.charName].allyHP:Value()/100 and myHero.pos:DistanceTo(ally.pos) <= 5500 and not ally.dead then
						
						if ally.pos:To2D().onScreen then						
							Control.CastSpell(ItemHotKey[Re], ally.pos) 
							
						elseif not ally.pos:To2D().onScreen then			
							CastSpellMM(ItemHotKey[Re], ally.pos, 5500)
						end
					end
					
					if Iro and self.Menu.ZS.ally[ally.charName].Iron and self.Menu.ZS.ally[ally.charName].Iron:Value() and ally.health/ally.maxHealth < self.Menu.ZS.ally[ally.charName].IronHP:Value()/100 and myHero.pos:DistanceTo(ally.pos) <= 600 and not ally.dead then
						Control.CastSpell(ItemHotKey[Iro])
					end
				end
			end				
		end	
	end	
end


-- Target Items -----------------------------		
				
function Activator:Auto()	
local Omen, Gore, Whip, Shur = GetInventorySlotItem(3143), GetInventorySlotItem(6630), GetInventorySlotItem(6029), GetInventorySlotItem(2065)   			
	if Omen and self.Menu.Dmg.Omen:Value() and self:EnemiesAround(myHero, 500) >= self.Menu.Dmg.Ocount:Value() then
		Control.CastSpell(ItemHotKey[Omen])
	end	

	if Gore and self.Menu.Dmg.Gore:Value() and self:EnemiesAround(myHero, 400) >= self.Menu.Dmg.Gorecount:Value() and myHero.health/myHero.maxHealth <= self.Menu.Dmg.Gorehp:Value()/100 then 
		Control.CastSpell(ItemHotKey[Gore])
	end
	
	if Whip and self.Menu.Dmg.Whip:Value() and self:EnemiesAround(myHero, 400) >= self.Menu.Dmg.Whipcount:Value() then
		Control.CastSpell(ItemHotKey[Whip])
	end	
	
	if Shur and self.Menu.Dmg.Shur:Value() and self:EnemiesAround(myHero, self.Menu.Dmg.ShurRange:Value()) >= 1 and self:AlliesAround(myHero, 1000) >= self.Menu.Dmg.Shurcount:Value() then -- Range Ally
		Control.CastSpell(ItemHotKey[Shur])
	end		
end

function Activator:Target()
local target = GetTarget(1500)
if target == nil then return end
local Hex, Frost, Gale, Claw, Stride, Turbo = GetInventorySlotItem(3152), GetInventorySlotItem(6656), GetInventorySlotItem(6671), GetInventorySlotItem(6693), GetInventorySlotItem(6631), GetInventorySlotItem(6664)   
	if IsValid(target) then
	
		if Turbo and self.Menu.Dmg.Turbo:Value() and myHero.pos:DistanceTo(target.pos) <= self.Menu.Dmg.TurboRange:Value() then 
            Control.CastSpell(ItemHotKey[Turbo])
        end	
	
		if Stride and self.Menu.Dmg.Stride:Value() and myHero.pos:DistanceTo(target.pos) < 500 then 
            Control.CastSpell(ItemHotKey[Stride], target.pos)
        end	
	
		if Gale and self.Menu.Dmg.Gale:Value() and myHero.pos:DistanceTo(target.pos) < self.Menu.Dmg.Gale3:Value() and myHero.pos:DistanceTo(target.pos) > 210 and ((self.Menu.Dmg.Gale2:Value()/100) * (target.maxHealth/100)) <= ((target.maxHealth - target.health)/100) then 
            Control.CastSpell(ItemHotKey[Gale], target.pos)
        end
		
		if Claw and self.Menu.Dmg.Claw:Value() and myHero.pos:DistanceTo(target.pos) < 500 then 
            Control.CastSpell(ItemHotKey[Claw], target.pos)
        end			

		if Hex and self.Menu.Dmg.Hex:Value() and myHero.pos:DistanceTo(target.pos) < 800 then  
            Control.CastSpell(ItemHotKey[Hex], target.pos)
        end			
	
		if Frost and self.Menu.Dmg.EFrost:Value() and myHero.pos:DistanceTo(target.pos) < 800 then 
            Control.CastSpell(ItemHotKey[Frost], target.pos)
        end					
    end
end

-- Potions ---------------------

function Activator:Pots()
if myHero.alive == false then return end 

	hotkeyTable[ITEM_1] = HK_ITEM_1;
	hotkeyTable[ITEM_2] = HK_ITEM_2;
	hotkeyTable[ITEM_3] = HK_ITEM_3;
	hotkeyTable[ITEM_4] = HK_ITEM_4;
	hotkeyTable[ITEM_5] = HK_ITEM_5;
	hotkeyTable[ITEM_6] = HK_ITEM_6;

	if (myPotTicks + 1000 < GetTickCount()) and self.Menu.Healing.Enabled:Value() then
		local myPotTicks = GetTickCount();
		currentlyDrinkingPotion = false;
		for j = ITEM_1, ITEM_6 do
			InventoryTable[j] = myHero:GetItemData(j);
		end
		local HealthPotionSlot = GetInventorySlotItem(2003)
		local CookiePotionSlot = GetInventorySlotItem(2010)
		local RefillablePotSlot = GetInventorySlotItem(2031)
		local RefillAmmo = myHero:GetItemData(RefillablePotSlot).ammo
		local CorruptPotionSlot = GetInventorySlotItem(2033)
		local CorruptAmmo = myHero:GetItemData(CorruptPotionSlot).ammo
		
		for i = 0, 63 do
			local buffData = myHero:GetBuff(i);
			if buffData.count > 0 then
			--print(buffData.name)
				if (buffData.type == 13) or (buffData.type == 26) then 
					if (buffData.name == "ItemDarkCrystalFlask") or (buffData.name == "ItemCrystalFlaskJungle") or (buffData.name == "ItemCrystalFlask") or (buffData.name == "Item2010") or (buffData.name == "Item2003") then
						currentlyDrinkingPotion = true;
						break;
					end
				end
			end
		end
		
		if (currentlyDrinkingPotion == false) and myHero.health/myHero.maxHealth <= self.Menu.Healing.UsePotsPercent:Value()/100 then
			if HealthPotionSlot and self.Menu.Healing.UsePots:Value() then
				--print("Use Potion")
				Control.CastSpell(ItemHotKey[HealthPotionSlot])
			end
			if CookiePotionSlot and self.Menu.Healing.UseCookies:Value() then
				--print("Use Potion")
				Control.CastSpell(ItemHotKey[CookiePotionSlot])
			end
			if RefillablePotSlot and RefillAmmo > 0 and self.Menu.Healing.UseRefill:Value() then
				--print("Use Potion")
				Control.CastSpell(ItemHotKey[RefillablePotSlot])
			end
			if CorruptPotionSlot and CorruptAmmo > 0 and self.Menu.Healing.UseCorrupt:Value() then
				--print("Use Potion")
				Control.CastSpell(ItemHotKey[CorruptPotionSlot])
			end
		end
	end
end

--Summoners-------------------------

function Activator:Summoner()
	for i, target in pairs(GetEnemyHeroes()) do
   
		if target and GetDistance(myHero.pos, target.pos) < 2000 and IsValid(target) then
			
			if self.Menu.summ.barr.self:Value() and myHero.health/myHero.maxHealth <= self.Menu.summ.barr.selfhp:Value()/100 and target.activeSpell.target == myHero.handle then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1, myHero)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2, myHero)
				end
			end
			
			local Immobile = self:Cleans(myHero)
			if self.Menu.summ.clean.self:Value() and Immobile then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1, myHero)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2, myHero)
				end
			end
			
			if self.Menu.summ.ex.target:Value() then
				if myHero.pos:DistanceTo(target.pos) <= 650 and target.health/target.maxHealth <= self.Menu.summ.ex.hp:Value()/100 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and Ready(SUMMONER_1) then
						Control.CastSpell(HK_SUMMONER_1, target)
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and Ready(SUMMONER_2) then
						Control.CastSpell(HK_SUMMONER_2, target)
					end
				end
			end
			
			if self.Menu.summ.heal.self:Value() and myHero.health/myHero.maxHealth <= self.Menu.summ.heal.selfhp:Value()/100 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1, myHero)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2, myHero)
				end
			end
			
			for k, ally in pairs(GetAllyHeroes()) do
				if ally then
					if self.Menu.summ.heal.ally:Value() and ally.health/ally.maxHealth <= self.Menu.summ.heal.allyhp:Value()/100 then
						if IsValid(ally) and myHero.pos:DistanceTo(ally.pos) <= 850 and not ally.dead then
							if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and Ready(SUMMONER_1) then
								Control.CastSpell(HK_SUMMONER_1, ally)
							elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and Ready(SUMMONER_2) then
								Control.CastSpell(HK_SUMMONER_2, ally)
							end
						end
					end
				end	
			end
		end	
	end
end	
		
function Activator:Ignite()		
	for i, target in pairs(GetEnemyHeroes()) do	
		if target and GetDistance(myHero.pos, target.pos) < 600 and IsValid(target) then	
        
			if self.Menu.summ.ign.ST:Value() == 1 then
				if GetMode() == "Combo" and target.health/target.maxHealth <= self.Menu.summ.ign.hp:Value()/100 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) then
						Control.CastSpell(HK_SUMMONER_1, target)
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) then
						Control.CastSpell(HK_SUMMONER_2, target)
					end
				end
				
			else
				
				local IGdamage = 50 + 20 * myHero.levelData.lvl - (target.hpRegen*3)
				if target.health <= IGdamage then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) then
						Control.CastSpell(HK_SUMMONER_1, target)
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) then
						Control.CastSpell(HK_SUMMONER_2, target)
					end
				end
			end	
		end	
	end
end	
	
function OnLoad()
	Activator()
	LoadUnits()
end	

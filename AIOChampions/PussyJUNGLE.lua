local Heroes = {"LeeSin","Nidalee","XinZhao","Warwick","Sylas"}


function OnLoad()
if table.contains(Heroes, myHero.charName) then
	_G[myHero.charName]()
end		
HPred()
	
end

----------------------------------------------------
--|                    Checks                    |--
----------------------------------------------------
if not FileExist(COMMON_PATH .. "PussyManager.lua") then
	print("PussyLib installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyManager.lua", COMMON_PATH .. "PussyManager.lua", function() end)
	while not FileExist(COMMON_PATH .. "PussyManager.lua") do end
end
    
require('PussyManager')


if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')


if not FileExist(COMMON_PATH .. "PussyDamageLib.lua") then
	print("PussyDamageLib. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/PussyDamageLib.lua", COMMON_PATH .. "PussyDamageLib.lua", function() end)
	while not FileExist(COMMON_PATH .. "PussyDamageLib.lua") do end
end
    
require('PussyDamageLib')


-- [ AutoUpdate ]
do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyJUNGLE.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyJUNGLE.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyJUNGLE.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyJUNGLE.version"
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
            print("New PussyJungle Version Press 2x F6")
        else
            print("PussyJungle loaded")
        end
    
    end
    
    AutoUpdate()

end

local Allies = {}; local Enemies = {}; local Turrets = {}; local Units = {}; local AllyHeroes = {}
local intToMode = {[0] = "", [1] = "Combo", [2] = "Harass", [3] = "LastHit", [4] = "Clear"}
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local spellcast = {state = 1, mouse = mousePos}
local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7,}
local Orb
local barHeight, barWidth, barXOffset, barYOffset = 8, 103, 0, 0
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local Orb

local function GetTarget(range) 
	local target = nil 
	if Orb == 1 then
		target = EOW:GetTarget(range)
	elseif Orb == 2 then 
		target = _G.SDK.TargetSelector:GetTarget(range)
	elseif Orb == 3 then
		target = GOS:GetTarget(range)
	elseif Orb == 4 then
		target = _G.gsoSDK.TS:GetTarget()		
	end
	return target 
end



class "LeeSin"





local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 65, Range = 1200, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
}



require 'MapPositionGOS'

local _wards = {2055, 2049, 2050, 2301, 2302, 2303, 3340, 3361, 3362, 3711, 1408, 1409, 1410, 1411, 2043, 3350, 3205, 3207, 2045, 2044, 3154, 3160}
				
function LeeSin:__init()
  mySmiteSlot = self:GetSmite(SUMMONER_1);
  if mySmiteSlot == 0 then
	mySmiteSlot = self:GetSmite(SUMMONER_2);
  end	  	
  self:LoadMenu()                                            
  Callback.Add("Tick", function() self:Tick() end)
  Callback.Add("Draw", function() self:Draw() end) 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function LeeSin:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "LeeSin", name = "PussyLeeSin"})

	--AutoQ
	self.Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQImmobile"})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto[Q] + Auto[W]SavePos", value = true})

	--AutoW 
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Safe Ally/Self", value = true})
	self.Menu.AutoW:MenuElement({id = "Heal", name = "min Hp Self or Ally", value = 30, min = 0, max = 100, identifier = "%"})	

	--AutoR
	self.Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoRSafeLife"})
	self.Menu.AutoR:MenuElement({id = "UseR", name = "Auto[R] safe your Life", value = true})
	self.Menu.AutoR:MenuElement({id = "Heal", name = "min Hp", value = 20, min = 0, max = 100, identifier = "%"})	
		
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Combo:MenuElement({id = "Gap", name = "Gapclose[WardJump]", value = true})
	
	self.Menu.Combo:MenuElement({id = "Set", name = "Gapclose Settings", type = MENU})		
	self.Menu.Combo.Set:MenuElement({id = "minRange", name = "MinCastDistance if not Ready[Q]", value = 600, min = 600, max = 1000, step = 50})	
	self.Menu.Combo.Set:MenuElement({id = "maxRange", name = "MaxCastDistance if not Ready[Q]", value = 1000, min = 1000, max = 1500, step = 50})	
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Energy to Harass", value = 40, min = 0, max = 100, identifier = "%"})
   
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})			
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Clear:MenuElement({id = "Heal", name = "min selfHp Use[W]", value = 70, min = 0, max = 100, identifier = "%"})	
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 3, min = 1, max = 6, step = 1})  		
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Energy to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})         	
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Energy to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})				
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	self.Menu.ks:MenuElement({id = "UseQR", name = "[Q]+[R]", value = true})	
	
	
	--JungleSteal
	self.Menu:MenuElement({type = MENU, id = "Jsteal", name = "Junglesteal"})
	self.Menu.Jsteal:MenuElement({name = " ", drop = {"Ward+Q1+Q2+W back Ward [You need Smite Activator]"}})
	self.Menu.Jsteal:MenuElement({id = "Dragon", name = "Steal Dragon", value = true})
	self.Menu.Jsteal:MenuElement({id = "Baron", name = "Steal Baron", value = true})
	self.Menu.Jsteal:MenuElement({id = "Herald", name = "Steal Herald", value = true})	
	self.Menu.Jsteal:MenuElement({id = "Active", name = "Activate Key", key = string.byte("Z")})	

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Insec
	self.Menu:MenuElement({id = "Modes", name = "InsecModes", type = MENU}) 
	self.Menu.Modes:MenuElement({id = "Modes1", name = "Insec Mode 1", type = MENU})	
	self.Menu.Modes.Modes1:MenuElement({name = " ", drop = {"Fast Near Insec = Ward+W+R+Q1+Q2"}})
	self.Menu.Modes.Modes1:MenuElement({name = " ", drop = {"Burst Near Insec = Ward+W+E1+R+Q1+Q2+E2"}})	
	self.Menu.Modes.Modes1:MenuElement({name = " ", drop = {"Fast Far Insec = Q1+Q2+Ward+W+R"}})
	self.Menu.Modes.Modes1:MenuElement({name = " ", drop = {"Burst Far Insec = Q1+Q2+Ward+W+E1+E2+R"}})	
	self.Menu.Modes.Modes1:MenuElement({id = "Logic", name = "ToggleKey Near / Far Insec", key = string.byte("I"), toggle = true})
	self.Menu.Modes.Modes1:MenuElement({id = "Burst", name = "ToggleKey Fast / Burst Insec", key = string.byte("O"), toggle = true})
	self.Menu.Modes.Modes1:MenuElement({id = "Item", name = "Use Tiamat / Hydra BurstMode ", value = true})
	self.Menu.Modes.Modes1:MenuElement({id = "Insec", name = "Insec Activate Key", key = string.byte("T")})
	self.Menu.Modes.Modes1:MenuElement({id = "Draw", name = "Draw Insec Line / Circle", value = true})
	self.Menu.Modes.Modes1:MenuElement({id = "Type", name = "Draw Option", value = 1, drop = {"Always", "Pressed Insec Key"}})
	
	self.Menu.Modes:MenuElement({id = "Modes2", name = "Insec Mode 2", type = MENU})
	self.Menu.Modes.Modes2:MenuElement({id = "Insec", name = "WardJump", key = string.byte("A")})
	
	self.Menu.Modes:MenuElement({id = "Modes3", name = "Insec Mode 3", type = MENU})
	self.Menu.Modes.Modes3:MenuElement({id = "Insec", name = "If Killable[Q1+E+R+Q2+E2]", value = true})
	self.Menu.Modes.Modes3:MenuElement({id = "Draw", name = "Draw Killable Text", value = true})	
	
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
end	



function LeeSin:Tick()
	if MyHeroReady() then
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
			self:WardJump()
		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		elseif Mode == "Flee" then
			self:WardJump()	
		
		end
	self:OnCreateObj()
	self:JungleSteal()
	self:KillSteal()
	self:KillStealInsec()
	self:AutoQ()
	self:AutoR()
	self:AutoW()
	self:Activator()
	
	if self.Menu.Modes.Modes1.Insec:Value() then
		if self.Menu.Modes.Modes1.Logic:Value() then
			if self.Menu.Modes.Modes1.Burst:Value() then
				self:Insec1()
			else
				self:BurstInsec1()
				
			end	
		else	
			if self.Menu.Modes.Modes1.Burst:Value() then	
				self:Insec2()
			else
				self:BurstInsec2()
				
			end				
		end	
	end
	end
end

local SmiteNames = {'SummonerSmite','S5_SummonerSmiteDuel','S5_SummonerSmitePlayerGanker','S5_SummonerSmiteQuick','ItemSmiteAoE'};

function LeeSin:GetSmite(smiteSlot)
	local returnVal = 0;
	local spellName = myHero:GetSpellData(smiteSlot).name;
	for i = 1, 5 do
		if spellName == SmiteNames[i] then
			returnVal = smiteSlot
		end
	end
	return returnVal;
end

local JungleTable = {
["SRU_Baron"] = {charName = "SRU_Baron"}, 
["SRU_RiftHerald"] = {charName = "SRU_RiftHerald"}, 
["SRU_Dragon_Water"] = {charName = "SRU_Dragon_Water"}, 
["SRU_Dragon_Earth"] = {charName = "SRU_Dragon_Earth"}, 
["SRU_Dragon_Air"] = {charName = "SRU_Dragon_Air"},
["SRU_Dragon_Elder"] = {charName = "SRU_Dragon_Elder"},
["SRU_Dragon_Fire"] = {charName = "SRU_Dragon_Fire"}
}


local WardTicks = 0;
local SmiteDamage = {390 , 410 , 430 , 450 , 480 , 510 , 540 , 570 , 600 , 640 , 680 , 720 , 760 , 800 , 850 , 900 , 950 , 1000};
local LastCast = 0

function LeeSin:Cast(spell,pos)
	Control.SetCursorPos(pos)
	Control.KeyDown(spell)
	Control.KeyUp(spell)
end

function LeeSin:IsValid(unit)
	return unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable
end

function LeeSin:GetInventorySlotItem(itemID, target)
	local target = myHero
	for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }) do
		if target:GetItemData(j).itemID == itemID and (target:GetSpellData(j).ammo > 0 or target:GetItemData(j).ammo > 0) then return j end
	end
	return nil
end

function LeeSin:Activator()
if myHero.dead then return end
local target = GetTarget(500)     	
if target == nil then return end	
local Tia, Rave, Tita = GetInventorySlotItem(3077), GetInventorySlotItem(3074), GetInventorySlotItem(3748)   
	if IsValid(target, 500) and self.Menu.Modes.Modes1.Insec:Value() and self.Menu.Modes.Modes1.Item:Value() and not self.Menu.Modes.Modes1.Burst:Value() then
        
		if Tia and myHero.pos:DistanceTo(target.pos) <= 400 then
            Control.CastSpell(ItemHotKey[Tia])
        end
		
		if Rave and myHero.pos:DistanceTo(target.pos) <= 400 then
            Control.CastSpell(ItemHotKey[Rave])
        end
		
		if Tita and myHero.pos:DistanceTo(target.pos) <= 400 then
            Control.CastSpell(ItemHotKey[Tita])
        end		
	end
end	

function LeeSin:KillStealInsec()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	if IsValid(target) then
		local hp = target.health
		local QDmg = getdmg("Q", target, myHero)
		local EDmg = getdmg("E", target, myHero)
		local RDmg = getdmg("R", target, myHero)
		local FullDmg = (QDmg + RDmg + EDmg)
		if hp <= FullDmg and self.Menu.Modes.Modes3.Insec:Value() then
			if myHero.pos:DistanceTo(target.pos) < 500 and myHero:GetSpellData(_E).name == "BlindMonkETwo" and HasBuff(target, "BlindMonkRKick") then
				Control.CastSpell(HK_E)
			end	
			
			if myHero.pos:DistanceTo(target.pos) < 350 and Ready(_E) and myHero:GetSpellData(_E).name == "BlindMonkEOne" and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_E)
			end			
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Control.CastSpell(HK_R, target.pos)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 350 and not HasBuff(target, "BlindMonkQOne") and Ready(_Q) and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkRKick") and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
		end				
	end
end


function LeeSin:WardJump(key, param)
	local mouseRadius = 200
	if Ready(_W) and myHero:GetSpellData(_W).name == "BlindMonkWOne" then
		local wardslot = nil
		for t, VisionItem in pairs(_wards) do
			if not wardslot then
				wardslot = GetInventorySlotItem(VisionItem)
			end
		end
		if self.Menu.Modes.Modes2.Insec:Value() then	
			if wardslot then
				local ward,dis = self:WardM()
				if ward~=nil and dis~=nil and dis<mouseRadius then
					if myHero.pos:DistanceTo(ward.pos) <=600 then
						self:Cast(HK_W, ward.pos)
					end
				elseif GetTickCount() > LastCast + 200 then
					LastCast = GetTickCount()
					local Data = myHero:GetSpellData(wardslot);
					if Data.ammo > 0 then
						if myHero.pos:DistanceTo(mousePos) < 600 then
							self:Cast(ItemHotKey[wardslot], mousePos)
							self:Cast(HK_W, mousePos)
						else
							newpos = myHero.pos:Extended(mousePos,600)
							self:Cast(ItemHotKey[wardslot], newpos)
							self:Cast(HK_W, newpos)
						end	
					end
				end
			end
		else
			local target = GetTarget(1300)     	
			if target == nil then return end
			if wardslot and self.Menu.Combo.Gap:Value() and not Ready(_Q) then
				if myHero.pos:DistanceTo(target.pos) <= self.Menu.Combo.Set.maxRange:Value() and myHero.pos:DistanceTo(target.pos) >= self.Menu.Combo.Set.minRange:Value() then		
					local ward,dis = self:WardM()
					if ward~=nil and dis~=nil and dis<mouseRadius then
						if myHero.pos:DistanceTo(ward.pos) <=600 then
							self:Cast(HK_W, ward.pos)
						end
					elseif GetTickCount() > LastCast + 200 then
						LastCast = GetTickCount()
						local Data = myHero:GetSpellData(wardslot);
						if Data.ammo > 0 then
							newpos = myHero.pos:Extended(target.pos,600)
							self:Cast(ItemHotKey[wardslot], newpos)
							self:Cast(HK_W, newpos)
									
													
						end	
					end
				end
			end
		end
	end
end


function LeeSin:WardM()
	local closer, near = math.huge, nil
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i)
		if ward~=nil then
			if (ward.isAlly and not ward.isMe) then
				if not self:IsValid(ward) and myHero.pos:DistanceTo(ward.pos) < 700 then
					local CurrentDistance = ward.pos:DistanceTo(mousePos)
					if CurrentDistance < closer then
						closer = CurrentDistance
						near = ward
					end
				end
			end
		end
	end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion~=nil then
			if (minion.isAlly) then
				if not self:IsValid(minion) and myHero.pos:DistanceTo(minion.pos) < 700 then
					local CurrentDistance = minion.pos:DistanceTo(mousePos)
					if CurrentDistance < closer then
						closer = CurrentDistance
						near = minion
					end
				end
			end
		end
	end
	
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero~=nil then
			if (hero.isAlly and not hero.isMe) then
				if not self:IsValid(hero) and myHero.pos:DistanceTo(hero.pos) < 700 then
					local CurrentDistance = hero.pos:DistanceTo(mousePos)
					if CurrentDistance < closer then
						closer = CurrentDistance
						near = hero
					end
				end
			end
		end
	end
	return near, closer
end


function LeeSin:Insec1()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
		if IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
				self:Cast(HK_R, target.pos)
			end
						
			--local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and HasBuff(target, "BlindMonkRKick") and Ready(_Q) then
				self:Cast(HK_Q, target.pos)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
	
		for i, tower in pairs(GetAllyTurret()) do			
			if WardsAround(target, 400) == 0 and Ready(_R) then 
				local Data = myHero:GetSpellData(Item);
	
					
						
				if tower.pos:DistanceTo(target.pos) <= 1600 and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 650 then
					local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (150)
					self:InsecStart(CastPos)
				
				end	
			end
					
			for i, ally in pairs(GetAllyHeroes()) do
				if WardsAround(target, 400) == 0 and Ready(_R) then 
					local Data = myHero:GetSpellData(Item);
	
						
					if not IsValid(tower, 1600) and IsValid(ally, 1300) and ally.pos:DistanceTo(target.pos) <= 1200 and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 650 then
						local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (150)
						self:InsecStart(CastPos)
							
					end	
				end
			end				
		end
		end	
	end
end

function LeeSin:BurstInsec1()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
		if IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) < 500 and HasBuff(myHero, "BlindMonkQTwoDash") and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 350 and Ready(_E) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" and myHero:GetSpellData(_E).name == "BlindMonkEOne" then
				Control.CastSpell(HK_E)
			end			
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				self:Cast(HK_R, target.pos)
			end
						
			--local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and HasBuff(target, "BlindMonkRKick") and Ready(_Q) then
				self:Cast(HK_Q, target.pos)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
	
		for i, tower in pairs(GetAllyTurret()) do			
			if WardsAround(target, 400) == 0 and Ready(_R) then 
				local Data = myHero:GetSpellData(Item);
	
					
						
				if tower.pos:DistanceTo(target.pos) <= 1600 and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 650 then
					local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (150)
					self:InsecStart(CastPos)
				
				end	
			end
					
			for i, ally in pairs(GetAllyHeroes()) do
				if WardsAround(target, 400) == 0 and Ready(_R) then 
					local Data = myHero:GetSpellData(Item);
	
						
					if not IsValid(tower, 1600) and IsValid(ally, 1300) and ally.pos:DistanceTo(target.pos) <= 1200 and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 650 then
						local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (150)
						self:InsecStart(CastPos)
							
					end	
				end
			end				
		end
		end	
	end
end

function LeeSin:Insec2()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
		if IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
				self:Cast(HK_R, target.pos)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				self:Cast(HK_Q, pred.CastPosition)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
	
		for i, tower in pairs(GetAllyTurret()) do			
			if WardsAround(target, 400) == 0 and Ready(_R) then 
				local Data = myHero:GetSpellData(Item);
	
					
						
				if tower.pos:DistanceTo(target.pos) <= 1600 and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 250 then
					local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (300)
					self:InsecStart(CastPos)
									
				end	
			end
					
			for i, ally in pairs(GetAllyHeroes()) do
				if WardsAround(target, 400) == 0 and Ready(_R) then 
					local Data = myHero:GetSpellData(Item);
	
						
					if not IsValid(tower, 1600) and IsValid(ally, 1300) and ally.pos:DistanceTo(target.pos) <= 1500 and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 250 then
						local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (300)
						self:InsecStart(CastPos)
							
					end	
				end
			end				
		end
		end	
	end
end

function LeeSin:BurstInsec2()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	for v, spell in pairs(_wards) do
	local Item = GetInventorySlotItem(spell)
		if IsValid(target) then
			
			if myHero.pos:DistanceTo(target.pos) < 500 and myHero:GetSpellData(_E).name == "BlindMonkETwo" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 350 and Ready(_E) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" and myHero:GetSpellData(_E).name == "BlindMonkEOne" then
				Control.CastSpell(HK_E)
			end				
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and not Ready(_E) then
				self:Cast(HK_R, target.pos)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				self:Cast(HK_Q, pred.CastPosition)
			end
			
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
			end				
	
		for i, tower in pairs(GetAllyTurret()) do			
			if WardsAround(target, 400) == 0 and Ready(_R) then 
				local Data = myHero:GetSpellData(Item);
	
					
						
				if tower.pos:DistanceTo(target.pos) <= 1600 and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 250 then
					local CastPos = target.pos + (target.pos-tower.pos):Normalized() * (300)
					self:InsecStart(CastPos)
									
				end	
			end
					
			for i, ally in pairs(GetAllyHeroes()) do
				if WardsAround(target, 400) == 0 and Ready(_R) then 
					local Data = myHero:GetSpellData(Item);
	
						
					if not IsValid(tower, 1600) and IsValid(ally, 1300) and ally.pos:DistanceTo(target.pos) <= 1500 and Item and Data.ammo > 0 and myHero.pos:DistanceTo(target.pos) <= 250 then
						local CastPos = target.pos + (target.pos-ally.pos):Normalized() * (300)
						self:InsecStart(CastPos)
							
					end	
				end
			end				
		end
		end	
	end
end

function LeeSin:InsecStart(CastPos)
local target = GetTarget(1300)     	
if target == nil then return end
local wardslot = nil
	for t, VisionItem in pairs(_wards) do
		if not wardslot then
			wardslot = GetInventorySlotItem(VisionItem)
elseif GetTickCount() > LastCast + 200 then
			LastCast = GetTickCount()
			if myHero.pos:DistanceTo(mousePos) < 1300 then		
				if target and Ready(_R) and wardslot then


					if Vector(myHero.pos):DistanceTo(CastPos)<=625 then
						if Ready(_W) and myHero:GetSpellData(_W).name == "BlindMonkWOne" then
							Control.SetCursorPos(CastPos)
							self:Cast(ItemHotKey[wardslot], CastPos)
							self:Cast(HK_W, CastPos)		
						end
					end
				end
			end
		end
	end
end

function LeeSin:NearestEnemy(entity)
	local distance = 999999
	local enemy = nil
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
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

function LeeSin:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 375, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) and myHero:GetSpellData(_Q).name == "BlindMonkQOne" then
    Draw.Circle(myHero, 1200, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) and myHero:GetSpellData(_E).name == "BlindMonkEOne"  then
    Draw.Circle(myHero, 350, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 700, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	
	
	if self.Menu.Modes.Modes1.Burst:Value() then
		Draw.Text("Fast Insec", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 000, 255, 000))
	else
		Draw.Text("Burst Insec", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 000, 255, 000))
	end	
	
	if self.Menu.Modes.Modes1.Logic:Value() then
		Draw.Text("Near Insec", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
	else
		Draw.Text("Far Insec", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))	
	end
	
	if self.Menu.Modes.Modes1.Draw:Value() then
		
		
		for v, spell in pairs(_wards) do
		local Item = GetInventorySlotItem(spell)	
		local Data = myHero:GetSpellData(Item);	
	
			if Item and Data.ammo > 0 and Ready(_Q) and Ready(_R) and Ready(_W) then
				for i = 1, Game.HeroCount() do
				local Hero = Game.Hero(i)
				local textPos = Hero.pos:To2D()
					if self.Menu.Modes.Modes1.Logic:Value() then	 
						
						if self.Menu.Modes.Modes1.Type:Value() == 2 and self.Menu.Modes.Modes1.Insec:Value() then 	
							if IsValid(Hero) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1300 then	
								local Vectori = Vector(myHero.pos - Hero.pos)
								local LS = LineSegment(myHero.pos, Hero.pos)
								LS:__draw()
								LSS = Circle(Point(Hero), Hero.boundingRadius)
								LSS:__draw()
								Draw.Text("Insec Mode", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
								Draw.Circle(myHero, 475, 1, Draw.Color(225, 225, 0, 0))
							end
						end	
						if self.Menu.Modes.Modes1.Type:Value() == 1 then
							if IsValid(Hero) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1300 then	
								local Vectori = Vector(myHero.pos - Hero.pos)
								local LS = LineSegment(myHero.pos, Hero.pos)
								LS:__draw()
								LSS = Circle(Point(Hero), Hero.boundingRadius)
								LSS:__draw()
								Draw.Text("Insec Mode", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
								Draw.Circle(myHero, 475, 1, Draw.Color(225, 225, 0, 0))
							end
						end	
					end
					
					if not self.Menu.Modes.Modes1.Logic:Value() then
						
						if self.Menu.Modes.Modes1.Type:Value() == 2 and self.Menu.Modes.Modes1.Insec:Value() then 	
							if IsValid(Hero) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1500 then								
								local Vectori = Vector(myHero.pos - Hero.pos)
								local LS = LineSegment(myHero.pos, Hero.pos)
								LS:__draw()
								LSS = Circle(Point(Hero), Hero.boundingRadius)
								LSS:__draw()
								Draw.Text("Insec Mode", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
								Draw.Circle(myHero, 1200, 1, Draw.Color(225, 225, 0, 0))
							end
						end	
						if self.Menu.Modes.Modes1.Type:Value() == 1 then
							if IsValid(Hero) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1500 then	
								local Vectori = Vector(myHero.pos - Hero.pos)
								local LS = LineSegment(myHero.pos, Hero.pos)
								LS:__draw()
								LSS = Circle(Point(Hero), Hero.boundingRadius)
								LSS:__draw()
								Draw.Text("Insec Mode", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
								Draw.Circle(myHero, 1200, 1, Draw.Color(225, 225, 0, 0))
							end
						end	
					end					
				end
			end
		end
	end
	local target = GetTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Modes.Modes3.Draw:Value() and not target.dead then
	local hp = target.health	
	local QDmg = getdmg("Q", target, myHero)
	local EDmg = getdmg("E", target, myHero)
	local RDmg = getdmg("R", target, myHero)
	local FullDmg = (QDmg + RDmg + EDmg)	
		if Ready(_Q) and Ready(_E) and Ready(_R) and FullDmg > hp then
			Draw.Text("Insec Kill", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Insec Kill", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
	
		end	
	end
end

function LeeSin:AutoQ()
local target = GetTarget(1500)     	
if target == nil or IsUnderTurret(target) then return end	
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1200 and self.Menu.AutoQ.UseQ:Value() and Ready(_Q) then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if IsImmobileTarget(target) and myHero.pos:DistanceTo(target.pos) <= 1200 and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end	
		if IsImmobileTarget(target) and myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
			Control.CastSpell(HK_Q)
		end	
	end
end


function LeeSin:AutoR()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 1000 then
		if myHero.health/myHero.maxHealth <= self.Menu.AutoR.Heal:Value()/100 and self.Menu.AutoR.UseR:Value() and Ready(_R) then
			if myHero.pos:DistanceTo(target.pos) <= 375 then
				Control.CastSpell(HK_R, target)
			end
			
			if myHero.pos:DistanceTo(target.pos) > 375 and myHero.pos:DistanceTo(target.pos) <= 800 and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end	
		end
	end	
end

function LeeSin:AutoW()	
	
	if self.Menu.AutoW.UseW:Value() and Ready(_W) then
		if myHero.health/myHero.maxHealth <= self.Menu.AutoW.Heal:Value()/100 then
			Control.CastSpell(HK_W, myHero)
			if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
				Control.CastSpell(HK_W)
			end
		end
		for i, ally in pairs(GetAllyHeroes()) do
			if myHero.pos:DistanceTo(ally.pos) <= 700 and IsValid(ally) and ally.health/ally.maxHealth <= self.Menu.AutoW.Heal:Value()/100 then
				Control.CastSpell(HK_W, ally)
				if HasBuff(ally, "blindmonkwoneshield") then
					Control.CastSpell(HK_W)
				end
			end
		end
	end
end


function LeeSin:Combo()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target) then
		
		if self.Menu.Combo.UseQ:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
					
			elseif myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end
		end
		if self.Menu.Combo.UseE:Value() then
			if myHero:GetSpellData(_E).name == "BlindMonkETwo" and EnemiesAround(myHero, 500) >= 1 then
				Control.CastSpell(HK_E)
				
			elseif myHero.pos:DistanceTo(target.pos) <= 350 and Ready(_E) then	
				Control.CastSpell(HK_E)
			end
		end
	end	
end	

function LeeSin:Harass()
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target) then
		local Mana = myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 	
		if self.Menu.Harass.UseQ:Value() then
			if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
				Control.CastSpell(HK_Q)
					
		
			elseif myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) and Mana then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end	
		end
		if self.Menu.Harass.UseE:Value() then
			if myHero:GetSpellData(_E).name == "BlindMonkETwo" and EnemiesAround(myHero, 500) >= 1 then
				Control.CastSpell(HK_E)
					
			elseif myHero.pos:DistanceTo(target.pos) <= 350 and Ready(_E) then	
				Control.CastSpell(HK_E)
			end
		end	
	end	
end	

function LeeSin:Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and myHero.pos:DistanceTo(minion.pos) <= 1400 and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100
			
			if self.Menu.Clear.UseQ:Value() then
			
				if HasBuff(minion, "BlindMonkQOne") and myHero.pos:DistanceTo(minion.pos) <= 1300 then
					Control.CastSpell(HK_Q)
				
				elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= 1200 and myHero.pos:DistanceTo(minion.pos) >= 500 and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end

			local passiveBuff = GetBuffData(myHero,"blindmonkpassive_cosmetic")
			if  passiveBuff.count == 1 then return end
            
			if self.Menu.Clear.UseW:Value() then
			
				if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
					Control.CastSpell(HK_W)
			
				elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= 500 and Ready(_W) then
					if myHero.health/myHero.maxHealth <= self.Menu.Clear.Heal:Value()/100 then
						Control.CastSpell(HK_W, myHero)
					end
				end
			end
            
			if self.Menu.Clear.UseE:Value() then
			
				if myHero:GetSpellData(_E).name == "BlindMonkETwo" and GetMinionCount(500, myHero) >= self.Menu.Clear.UseEM:Value() then
					Control.CastSpell(HK_E)
					
				elseif mana_ok and GetMinionCount(350, myHero) >= self.Menu.Clear.UseEM:Value() and Ready(_E) then
					Control.CastSpell(HK_E)
				end
			end
        end
    end
end



function LeeSin:JungleClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE and myHero.pos:DistanceTo(minion.pos) <= 1400 and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100
            
			if self.Menu.JClear.UseQ:Value() then
			
				if myHero:GetSpellData(_Q).name == "BlindMonkQTwo" and myHero.pos:DistanceTo(minion.pos) <= 1300 then
					Control.CastSpell(HK_Q)
			
				elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= 1200 and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end
			
			
			local passiveBuff = GetBuffData(myHero,"blindmonkpassive_cosmetic")
			if  passiveBuff.count == 1 then return end
           
			if self.Menu.JClear.UseW:Value() then
			
				if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
					Control.CastSpell(HK_W)		    
			
				elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= 500 and Ready(_W) then
					Control.CastSpell(HK_W, myHero)
				end
			end
            
			if self.Menu.JClear.UseE:Value() then
			
				if myHero:GetSpellData(_E).name == "BlindMonkETwo" and GetMinionCount(500, myHero) >= 1 then
					Control.CastSpell(HK_E)
						
				elseif mana_ok and GetMinionCount(350, myHero) >= 1 and Ready(_E) and not Ready(_W) then
					Control.CastSpell(HK_E)
				end
			end
        end
    end
end

local lastWard = nil

function LeeSin:OnCreateObj()
if myHero.dead then return end
	for i = 1, Game.WardCount() do
	local object = Game.Ward(i)	
		if object ~= nil and object.valid and object.isAlly and (object.name == "VisionWard" or object.name == "SightWard") then
			lastWard = object
			lastTime = GetTickCount()
		end
	end
end

function LeeSin:JungleSteal()
--if mySmiteSlot == 0 then return end	
local minionlist = {}
	if _G.SDK then
		minionlist = _G.SDK.ObjectManager:GetMonsters(1500)
	elseif _G.GOS then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			
			if minion.team == TEAM_JUNGLE and minion.pos:DistanceTo(myHero.pos) < 1500 and IsValid(minion) then
				table.insert(minionlist, minion)
			end
		end
	end
	
for i, minion in pairs(minionlist) do
					
		
		if self.Menu.Jsteal.Active:Value() then
			local count = GetEnemyCount(1000, myHero)
			if Ready(_W) and myHero:GetSpellData(_W).name == "BlindMonkWOne" and count >= 1 then
				if lastTime > (GetTickCount() - 1000) then
					if (GetTickCount() - lastTime) >= 10 then	
						self:Cast(HK_W, lastWard)
					end
				end
			end		
		end	
	
	
	
	if minion.pos:DistanceTo(myHero.pos) < 1300 and self.Menu.Jsteal.Active:Value() then
		local Damage = (SmiteDamage[myHero.levelData.lvl] + getdmg("Q", minion, myHero))
		local SData = myHero:GetSpellData(mySmiteSlot);

		--if SData.level > 0 and SData.ammo > 0 then	
			
			if minion.pos:DistanceTo(myHero.pos) < 1200 and (JungleTable[minion.charName] or minion.charName == "SRU_RiftHerald" or minion.charName == "SRU_Baron") then
				for v, spell in pairs(_wards) do
				local Item = GetInventorySlotItem(spell)
				local Data = myHero:GetSpellData(Item);
				local count = GetEnemyCount(500, myHero)	
					if WardTicks + 200 < GetTickCount() then 
					local WardTicks = GetTickCount();
					UsedWard = false;	
						if UsedWard == false and Item and Data.ammo > 0 and Damage > minion.health and count == 0 then
							self:Cast(ItemHotKey[Item], myHero.pos)
						end	
					end
				end
			end
			
			if self.Menu.Jsteal.Dragon:Value() then
				if JungleTable[minion.charName] and minion.pos:DistanceTo(myHero.pos) < 1300 and Ready(_Q) then
					if myHero:GetSpellData(_Q).name == "BlindMonkQTwo" and minion.pos:DistanceTo(myHero.pos) < 1300 then
						Control.CastSpell(HK_Q)
						
					end
					if minion.pos:DistanceTo(myHero.pos) < 1200 and Damage > minion.health then
						self:Cast(HK_Q, minion.pos)
					end
				end
			end
			
			if self.Menu.Jsteal.Herald:Value() then
				if minion.charName == "SRU_RiftHerald" and minion.pos:DistanceTo(myHero.pos) < 1300 and Ready(_Q) then
					if myHero:GetSpellData(_Q).name == "BlindMonkQTwo" and minion.pos:DistanceTo(myHero.pos) < 1300 then
						Control.CastSpell(HK_Q)
						
					end
					if minion.pos:DistanceTo(myHero.pos) < 1200 and Damage > minion.health then
						self:Cast(HK_Q, minion.pos)
					end
				end
			end
			
			if self.Menu.Jsteal.Baron:Value() then
				if minion.charName == "SRU_Baron" and minion.pos:DistanceTo(myHero.pos) < 1300 and Ready(_Q) then
					if myHero:GetSpellData(_Q).name == "BlindMonkQTwo" and minion.pos:DistanceTo(myHero.pos) < 1300 then
						Control.CastSpell(HK_Q)
						
					end
					if minion.pos:DistanceTo(myHero.pos) < 1200 and Damage > minion.health then
						self:Cast(HK_Q, minion.pos)
					end
				end
			end 
		--end	
	end
end
end


function LeeSin:KillSteal()
	local target = GetTarget(1500)     	
	if target == nil then return end
	
	

	if myHero.pos:DistanceTo(target.pos) <= 1300 and IsValid(target) then
		local hp = target.health
		local QDmg = getdmg("Q", target, myHero)
		local EDmg = getdmg("E", target, myHero)
		local RDmg = getdmg("R", target, myHero)
		local QRDmg = QDmg + RDmg
		
		if IsUnderTurret(target) then return end
			
			if QRDmg >= hp and self.Menu.ks.UseQR:Value() and Ready(_Q) and Ready(_R) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if myHero.pos:DistanceTo(target.pos) <= 1200 and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
				if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
					Control.CastSpell(HK_Q)
				end	
				if myHero.pos:DistanceTo(target.pos) <= 350 and HasBuff(myHero, "BlindMonkQTwoDash") then
					Control.CastSpell(HK_R, target)
				end
			end
			if QDmg >= hp and self.Menu.ks.UseQ:Value() and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if myHero.pos:DistanceTo(target.pos) <= 1200 and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
				if myHero.pos:DistanceTo(target.pos) <= 1300 and HasBuff(target, "BlindMonkQOne") then
					Control.CastSpell(HK_Q)
				end	
			end

		if myHero.pos:DistanceTo(target.pos) <= 350 and EDmg >= hp then
			if self.Menu.ks.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E)
			end
			if myHero:GetSpellData(_E).name == "BlindMonkETwo" and myHero.pos:DistanceTo(target.pos) <= 500 then
				Control.CastSpell(HK_E)
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 375 and RDmg >= hp and self.Menu.ks.UseR:Value() and Ready(_R) then
			Control.CastSpell(HK_R, target)
			
		end
	end
end	





-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "Nidalee"





function Nidalee:__init()
	
	if menu ~= 1 then return end
	menu = 2
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4
	end

end

function Nidalee:LoadSpells()
	Q = {Range = 1500, width = 40, Delay = 0.25, Radius = 40, Speed = 1300, Collision = true, aoe = false, type = "linear"}
	W = {Range = 900, width = 50, Delay = 1.0, Radius = 100, Speed = 1000, Collision = false, aoe = true}
	E = {Range = 600, Delay = 0.25}
    QC = {Range = 200, Delay = 0.25}
	WC = {Range = 700, Delay = 0.25}
	EC = {Range = 300, Delay = 0.25}

end

local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1500, Speed = 1300, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
}

local W1Data =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 1.0, Radius = 100, Range = 900, Speed = 1000, Collision = false
}

local W2Data =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 75, Range = 375, Speed = 1000, Collision = false
}


function Nidalee:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Nidalee", name = "PussyNidalee"})
	
	--Combo
	self.Menu:MenuElement({type = MENU, id = "ComboMode", leftIcon = Icons["Combo"]})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Q: Javelin Toss", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "W: Bushwhack", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseE", name = "E: Primal Surge", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseQQ", name = "Q: Takedown", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseWW", name = "W: Pounce", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseEE", name = "E: Swipe", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseR", name = "R: Aspect of the Cougar", value = true})
	self.Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
		
	--Harass
	self.Menu:MenuElement({type = MENU, id = "HarassMode", leftIcon = Icons["Harass"]})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Q: Javelin Toss", value = true})

	--Lane/JungleClear
	self.Menu:MenuElement({type = MENU, id = "ClearMode", leftIcon = Icons["Clear"]})
	self.Menu.ClearMode:MenuElement({id = "UseQ", name = "Q: Javelin Toss", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseW", name = "W: Bushwhack", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseE", name = "E: Primal Surge", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseQQ", name = "Q: Takedown", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseWW", name = "W: Pounce", value = true})
    self.Menu.ClearMode:MenuElement({id = "UseEE", name = "E: Swipe", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseR", name = "R: Aspect of the Cougar", value = true})
	
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "KS", leftIcon = Icons["ks"]})
	self.Menu.KS:MenuElement({id = "UseQ", name = "Q: Javelin Toss", value = true})

	--Flee
	self.Menu:MenuElement({type = MENU, id = "Fl", leftIcon = Icons["Flee"]})
	self.Menu.Fl:MenuElement({id = "UseW", name = "W: Pounce", value = true, key = string.byte("A")})	
	
	self.Menu:MenuElement({type = MENU, id = "DrawQ", leftIcon = Icons["Drawings"]})
	self.Menu.DrawQ:MenuElement({id = "Q", name = "Draw Q", value = true})

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q Human]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredW1", name = "Hitchance[W Human]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredW2", name = "Hitchance[W Cougar]", value = 2, drop = {"Normal", "High", "Immobile"}})
end

function Nidalee:Tick()
if MyHeroReady() then
	self:KillSteal()
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Jungle()
	elseif Mode == "Flee" then
		self:Flee()
	end	
end
end

function Nidalee:Qdmg(target)
    local qLvl = myHero:GetSpellData(_Q).level
	local result = 55 + 15 * qLvl + myHero.ap * 0.4
    
    local dist = target.distance
    if dist > 525 then
        if dist > 1300 then
            result = result + 2 * result
        else
            local num = (dist - 525) * 0.25 / 96.875
            result = result + num * result
        end
    end
    
    return CalcMagicalDamage(target, result)
end

function Nidalee:Wdmg(target)
	local level = myHero:GetSpellData(_R).level
	local base = ({60, 110, 160, 210})[level] + 0.3 * myHero.ap
	return CalcMagicalDamage(target, base)
end

function Nidalee:Edmg(target)
	local level = myHero:GetSpellData(_R).level
	local base = ({70, 130, 190, 250})[level] + 0.45 * myHero.ap
	return CalcMagicalDamage(target, base)
end

function Nidalee:Draw()
    if Ready(_Q) and self.Menu.DrawQ.Q:Value() then Draw.Circle(myHero.pos, 1500, 1,  Draw.Color(255, 000, 222, 255)) end
	if self.Menu.ComboMode.DrawDamage:Value() then
		for i, target in pairs(GetEnemyHeroes()) do
			local barPos = target.hpBar
			if not target.dead and target.pos2D.onScreen and barPos.onScreen and target.visible then
				local QDamage = (Ready(_Q) and self:Qdmg(target) or 0)
				local WDamage = (Ready(_W) and self:Wdmg(target) or 0)
				local EDamage = (Ready(_E) and self:Edmg(target) or 0)
				local damage = QDamage + WDamage + EDamage
				if damage > target.health then
					Draw.Text("killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
					
				else
					local percentHealthAfterDamage = math.max(0, target.health - damage) / target.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * target.health/target.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, Draw.Color(0xFF00FF00))
				end
			end
		end	
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
end

function ForceCat()
    local RRTarget = GetTarget(1000)
	local count = 0
	for i = 0, Game.HeroCount() do
		local hero = Game.Hero(i)
		if myHero.pos:DistanceTo(RRTarget.pos) < 700 then
			if hero == nil then return end
			local t = {}
 			for i = 0, hero.buffCount do
    			local buff = hero:GetBuff(i)
    			if buff.count > 0 then
    				table.insert(t, buff)
    			end
  			end
  			if t ~= nil then
  				for i, buff in pairs(t) do
					if buff.name == "NidaleePassiveHunting" and buff.expireTime >= 2 then
						count = count +1
							return true
					end
				end
			end
		end
	end
	return false
end

function Nidalee:Flee()
    if self.Menu.Fl.UseW:Value() then 
		if myHero:GetSpellData(_W).name == "Pounce" and Ready(_W) then
			Control.CastSpell(HK_W, mousePos)
		
		elseif myHero:GetSpellData(_W).name == "Bushwhack" and Ready(_R) then
			Control.CastSpell(HK_R)
		end
	end
end	

function Nidalee:Combo()
local target = GetTarget(1600)
if target == nil then return end
if IsValid(target, 1600) then	
	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 1500 then 
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if self.Menu.ComboMode.UseQ:Value() then
            if myHero:GetSpellData(_Q).name == "JavelinToss" and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				CastSpell(HK_Q, pred.CastPosition)
            end
		end
	end
	
    if Ready(_R) and myHero.pos:DistanceTo(target.pos) < 800 then
        if self.Menu.ComboMode.UseR:Value() and myHero:GetSpellData(_Q).name == "JavelinToss" then
            if ForceCat() then
			    Control.CastSpell(HK_R)
            end
        end
    end

	if Ready(_W) and myHero.pos:DistanceTo(target.pos) < 800 then 
		local pred = GetGamsteronPrediction(target, W1Data, myHero)
		if self.Menu.ComboMode.UseW:Value() and myHero:GetSpellData(_W).name == "Bushwhack" then
			if pred.Hitchance >= self.Menu.Pred.PredW1:Value() then
				CastSpell(HK_W, pred.CastPosition)
			end
		end
	end

    if Ready(_E) then 
		if self.Menu.ComboMode.UseE:Value() and myHero.health/myHero.maxHealth < .70 and myHero:GetSpellData(_E).name == "PrimalSurge" then
			Control.CastSpell(HK_E, myHero)
		end
	end

    if myHero.pos:DistanceTo(target.pos) < 700 and Ready(_W) then 
		local pred = GetGamsteronPrediction(target, W2Data, myHero)
		if self.Menu.ComboMode.UseWW:Value() and myHero:GetSpellData(_W).name == "Pounce" then
			if pred.Hitchance >= self.Menu.Pred.PredW2:Value() then
				CastSpell(HK_W, pred.CastPosition)
			end
		end
	end

    if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 275 then 
		if self.Menu.ComboMode.UseQQ:Value() then
            if myHero:GetSpellData(_Q).name == "Takedown" then
				Control.CastSpell(HK_Q)
                Control.Attack(target)
            end
		end
	end

    if myHero.pos:DistanceTo(target.pos) < 350 then 
		if self.Menu.ComboMode.UseEE:Value() and myHero:GetSpellData(_E).name == "Swipe" then
			if Ready(_E) then
				Control.CastSpell(HK_E, target)
			end
		end
	end

    if Ready(_R) and myHero.pos:DistanceTo(target.pos) < 140 then 
        if self.Menu.ComboMode.UseR:Value() and myHero:GetSpellData(_E).name == "Swipe" then
            if not Ready(_Q) and not Ready(_E) and not Ready(_W) then
				if Game.Timer() - LastR > 8 then
			    	Control.CastSpell(HK_R)
				end
            end
        end
    end

    if Ready(_R) then 
        if self.Menu.ComboMode.UseR:Value() and myHero:GetSpellData(_E).name == "Swipe" then
            if myHero.health/myHero.maxHealth < .50 and myHero.pos:DistanceTo(target.pos) > 700 then
			    Control.CastSpell(HK_R)
            end
        end
    end
end
end

function Nidalee:Harass()
local target = GetTarget(1600)
if target == nil then return end
if IsValid(target, 1600) then   
	if Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1500 then 
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if self.Menu.HarassMode.UseQ:Value() then
            if myHero:GetSpellData(_Q).name == "JavelinToss" and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				CastSpell(HK_Q, pred.CastPosition)
			elseif myHero:GetSpellData(_Q).name == "Takedown" and Ready(_R) then
				Control.CastSpell(HK_R)	
            end
		end
	end
end
end

LastR = Game.Timer()
function Nidalee:Jungle()
for i = 1, Game.MinionCount() do
local minion = Game.Minion(i)
    if minion.team == TEAM_JUNGLE or minion.team == TEAM_ENEMY and IsValid(minion,1600) then
		if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 1500 then 
			if self.Menu.ClearMode.UseQ:Value() then
            	if myHero:GetSpellData(_Q).name == "JavelinToss" then
					local newpos = myHero.pos:Extended(minion.pos,math.random(100,300))
					Control.CastSpell(HK_Q, newpos)
            	end
			end
		end
		if myHero.pos:DistanceTo(minion.pos) < 800 then 
			if self.Menu.ClearMode.UseW:Value() and myHero:GetSpellData(_W).name == "Bushwhack" then
				if Ready(_W) then
					Control.CastSpell(HK_W, minion)
				end
			end
		end
		if myHero.pos:DistanceTo(minion.pos) < 800 and Ready(_R) then
        	if self.Menu.ClearMode.UseR:Value() and myHero:GetSpellData(_Q).name == "JavelinToss" then
            	if not Ready(_Q) and not Ready(_W) then
					if Game.Timer() - LastR > 4 then
						Control.CastSpell(HK_R)
					end
            	end
        	end
    	end
		if Ready(_E) then 
			if self.Menu.ClearMode.UseE:Value() and myHero.health/myHero.maxHealth < .70 and myHero:GetSpellData(_E).name == "PrimalSurge" then
				Control.CastSpell(HK_E, myHero)
			end
		end

    	if myHero.pos:DistanceTo(minion.pos) < 700 then
			if self.Menu.ClearMode.UseWW:Value() and myHero:GetSpellData(_W).name == "Pounce" then
				if Ready(_W) then
					Control.CastSpell(HK_W, minion)
				end
			end
		end

    	if Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 275 then 
			if self.Menu.ClearMode.UseQQ:Value() then
            	if myHero:GetSpellData(_Q).name == "Takedown" then
					Control.CastSpell(HK_Q)
                	Control.Attack(minion)
            	end
			end
		end

    	if myHero.pos:DistanceTo(minion.pos) < 350 then 
			if self.Menu.ClearMode.UseEE:Value() and myHero:GetSpellData(_E).name == "Swipe" then
				if Ready(_E) then
					Control.CastSpell(HK_E, minion)
				end
			end
		end

    	if Ready(_R) then 
        	if self.Menu.ClearMode.UseR:Value() and myHero:GetSpellData(_E).name == "Swipe" then
            	if not Ready(_Q) and not Ready(_E) and not Ready(_W) then
					if Game.Timer() - LastR > 8 then
			    		Control.CastSpell(HK_R)
					end
            	end
        	end
    	end

    	if Ready(_R) and myHero.pos:DistanceTo(minion.pos) > 700 then 
        	if self.Menu.ClearMode.UseR:Value() and myHero:GetSpellData(_E).name == "Swipe" then
            	if myHero.health/myHero.maxHealth < .30 then
			    	Control.CastSpell(HK_R)
            	end
        	end
    	end

	end
end
end

function Nidalee:KillSteal()
local target = GetTarget(1600)
if target == nil then return end
	if IsValid(target,1600) and myHero.pos:DistanceTo(target.pos) <= 1500 then 
		
		if self.Menu.KS.UseQ:Value() and Ready(_Q) and self:Qdmg(target) >= target.health then
            local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero:GetSpellData(_Q).name == "JavelinToss" and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				CastSpell(HK_Q, pred.CastPosition)
            elseif myHero:GetSpellData(_Q).name == "Takedown" and Ready(_R) then
				Control.CastSpell(HK_R)
			end
		end
	end	
end





-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Warwick"


function Warwick:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
end


local barHeight = 8
local barWidth = 103
local barXOffset = 0
local barYOffset = 0



		
function Warwick:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Warwick:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Warwick:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Warwick:QDmg()
	total = 0
	local qLvl = myHero:GetSpellData(_Q).level
    if qLvl > 0 then
	local qdamage = 1.2 * myHero.totalDamage + 0.9 * myHero.ap + (({6, 6.5, 7, 7.5, 8})[qLvl] / 100  * target.maxHealth)
	total = qdamage
	end
	return total

end

function Warwick:RDmg()
	total = 0
	local rLvl = myHero:GetSpellData(_R).level
    if rLvl > 0 then
	local rdamage = (({175,350,525})[rLvl] + 1.67 * myHero.totalDamage)
	total = rdamage
	end
	return total

end

function Warwick:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

function Warwick:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }

end

function Warwick:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "PussyWarwick", name = "PussyWarwick"})
	self.Menu:MenuElement({id = "ComboMode", leftIcon = Icons["Combo"], type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.ComboMode:MenuElement({id = "Key", name = "Toggle: E Insta -- Delay Key", key = string.byte("T"), toggle = true})
	self.Menu.ComboMode:MenuElement({id = "UseR", name = "R: Infinite Duress", value = true})
	self.Menu.ComboMode:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.ComboMode:MenuElement({id = "UseHYDRA", name = "Use hydra", value = true})
	self.Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw Killable", value = true})
	self.Menu.ComboMode:MenuElement({id = "DrawRange", name = "Draw RRange", value = true})	
		
	self.Menu:MenuElement({id = "HarassMode", leftIcon = Icons["Harass"], type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.HarassMode:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})

	self.Menu:MenuElement({id = "ClearMode", leftIcon = Icons["Clear"], type = MENU})
	self.Menu.ClearMode:MenuElement({id = "UseQ", name = "Q: Jaws of the Beast", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseW", name = "W: Blood Hunt", value = true})
	self.Menu.ClearMode:MenuElement({id = "UseE", name = "E: Primal Howl", value = true})
	self.Menu.ClearMode:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
		
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 100, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
end

function Warwick:Tick()
if MyHeroReady() then
	local Mode = GetMode()
		if Mode == "Combo" then
			if self.Menu.ComboMode.comboActive:Value() then
				self:Combo()
			end

		elseif Mode == "Harass" then
			if self.Menu.HarassMode.harassActive:Value() then
				self:Harass()
			end
		elseif Mode == "Clear" then
			if self.Menu.ClearMode.clearActive:Value() then
				self:Jungle()
			end
		elseif Mode == "Flee" then
		
		end

	if self.Menu.ComboMode.DrawDamage:Value() then
	self:Draw()
	end
end	
end	

function Warwick:Draw()
local textPos = myHero.pos:To2D()
  
	if self.Menu.ComboMode.DrawRange:Value() and self:CanCast(_R) then Draw.Circle(myHero.pos, (2.5 * myHero.ms), Draw.Color(255, 000, 222, 255)) end
	if self.Menu.ComboMode.DrawDamage:Value() then
		for i, hero in pairs(GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (self:CanCast(_Q) and self:QDmg() or 0)
				local RDamage = (self:CanCast(_R) and self:RDmg() or 0)
				local damage = QDamage + RDamage
				if damage > self:HpPred(hero,1) + hero.hpRegen * 1 then
					Draw.Text("killable", 24, hero.pos2D.x, hero.pos2D.y,Draw.Color(0xFF00FF00))
					
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, Draw.Color(0xFF00FF00))
				end
			end
		end	
	end
	if self.Menu.ComboMode.Key:Value() then
		Draw.Text("Insta E: On", 20, textPos.x - 33, textPos.y + 50, Draw.Color(255, 000, 255, 000)) 
	else
		Draw.Text("Insta E: Off", 20, textPos.x - 33, textPos.y + 50, Draw.Color(255, 225, 000, 000)) 
	end
end

function UseHydra()
	local HTarget = GetTarget(300)
	if HTarget then 
		local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
		if hydraitem and myHero.attackData.state == STATE_WINDDOWN then
			Control.CastSpell(keybindings[hydraitem],HTarget.pos)
            Control.Attack(HTarget)
		end
	end
end
   
function UseHydraminion()
    for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
        if minion and minion.team == 300 or minion.team ~= myHero.team then 
			local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
			if hydraitem and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(keybindings[hydraitem])
                Control.Attack(minion)
			end
		end
    end
end

function Warwick:Combo()
    if self.Menu.ComboMode.UseHYDRA:Value() and HasBuff(myHero, "Blood Hunt") and EnemyInRange(300) then
        if myHero.attackData.state == STATE_WINDDOWN then
            UseHydra()
        end
    end

    if self:CanCast(_E) then 
		local ETarget = GetTarget(375)
		if self.Menu.ComboMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == false and ETarget and HasBuff(myHero, "Primal Howl") then
			if EnemyInRange(375) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
        if self.Menu.ComboMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == true and ETarget and not HasBuff(myHero, "Primal Howl") then
			if EnemyInRange(375) and self:CanCast(_E) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
	end

	if self:CanCast(_Q) and EnemyInRange(350) then 
		local QTarget = GetTarget(350)
		if self.Menu.ComboMode.UseQ:Value() and QTarget then
            if EnemyInRange(350) and myHero.pos:DistanceTo(QTarget.pos) < 350 and myHero.pos:DistanceTo(QTarget.pos) > 125 then
				Control.CastSpell(HK_Q, QTarget)
            end
		end
	end

    if self:CanCast(_R) then 
        local rRange = 2.5 * myHero.ms
		local target = GetTarget(rRange)
		if target == nil then return end
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, rRange, 0.1, 1800, 55, false)
        if self.Menu.ComboMode.UseR:Value() then
			if myHero.pos:DistanceTo(target.pos) < rRange and hitRate and hitRate >= 1 then
			if EnemiesAround(target, 500) >= 2 then self:CastER(target) return end	
				if aimPosition:To2D().onScreen then
					Control.CastSpell(HK_R, aimPosition)
					
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition.pos, 1000)
					Control.CastSpell(HK_R, castPos)
				end	
			end	
        end
    end
	

    if EnemyInRange(600) and not self:CanCast(_Q) then 
        local BTarget = GetTarget(600)
        if BTarget then
            if myHero.pos:DistanceTo(BTarget.pos) < 600 then
			    UseHydra()
            end
        end
    end
end

function Warwick:CastER(target)
local rRange = 2.5 * myHero.ms  
	if HasBuff(myHero, "Primal Howl") then
		if myHero.pos:DistanceTo(target) < 150 then
			Control.CastSpell(HK_E)
		end
	end	
	
	if self:CanCast(_E) then 
		if not HasBuff(myHero, "Primal Howl") then
			Control.CastSpell(HK_E)
		end
	end
	
	
	local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, rRange, 0.1, 1800, 55, false)
	if hitRate and hitRate >= 1 then	
		if aimPosition:To2D().onScreen then
			Control.CastSpell(HK_R, aimPosition)
					
		elseif not aimPosition:To2D().onScreen then	
		local castPos = myHero.pos:Extended(aimPosition.pos, 1000)
			Control.CastSpell(HK_R, castPos)
		end
	end
	if HasBuff(myHero, "Primal Howl") then
		if myHero.pos:DistanceTo(target) < 150 then
			Control.CastSpell(HK_E)
		end
	end	
end


function Warwick:Harass()
    if self.Menu.ComboMode.UseHYDRA:Value() and HasBuff(myHero, "Blood Hunt") and EnemyInRange(300) then
        if myHero.attackData.state == STATE_WINDDOWN then
            UseHydra()
        end
    end
    if self:CanCast(_E) then 
		local ETarget = GetTarget(375)
		if self.Menu.HarassMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == false and ETarget and HasBuff(myHero, "Primal Howl") then
			if EnemyInRange(375) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
        if self.Menu.HarassMode.UseE:Value() and self.Menu.ComboMode.Key:Value() == true and ETarget and not HasBuff(myHero, "Primal Howl") then
			if EnemyInRange(375) and self:CanCast(_E) and myHero.pos:DistanceTo(ETarget.pos) < 375 then
				Control.CastSpell(HK_E)
			end
		end
	end

	if self:CanCast(_Q) then 
		local QTarget = GetTarget(350)
		if self.Menu.HarassMode.UseQ:Value() and QTarget then
            if EnemyInRange(350) and myHero.pos:DistanceTo(QTarget.pos) < 350 and myHero.pos:DistanceTo(QTarget.pos) > 125 then
				Control.CastSpell(HK_Q, QTarget)
            end
		end
	end

	if self:CanCast(_W) then 
		local WTarget = GetTarget(125)
		if self.Menu.HarassMode.UseW:Value() and WTarget then
			if EnemyInRange(125) and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_W)
                Control.Attack(WTarget)
			end
		end
	end
end

function Warwick:Jungle()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    if minion.team == TEAM_ENEMY or minion.team == TEAM_JUNGLE and myHero.pos:DistanceTo(minion.pos) < 375 then
		if self:CanCast(_E) and minion then 
			if self.Menu.ClearMode.UseE:Value() and self.Menu.ComboMode.Key:Value()  == false and HasBuff(myHero, "Primal Howl") then
				if myHero.pos:DistanceTo(minion.pos) < 375 then
					Control.CastSpell(HK_E)
				end
			end
			if self.Menu.ClearMode.UseE:Value() and self.Menu.ComboMode.Key:Value()  == true and not HasBuff(myHero, "Primal Howl") then
				if myHero.pos:DistanceTo(minion.pos) < 375 and self:CanCast(_E) then
					Control.CastSpell(HK_E)
				end
			end
		end	

		if self.Menu.ComboMode.UseHYDRA:Value() and not HasBuff(myHero, "Blood Hunt") and minion then
			if myHero.attackData.state == STATE_WINDDOWN and not self:CanCast(_W) and myHero.pos:DistanceTo(minion.pos) < 300 then
				UseHydraminion()
			end
		end
		if self:CanCast(_Q) and minion then 
			if self.Menu.ClearMode.UseQ:Value() and IsValid(minion, 350) then
				if myHero.pos:DistanceTo(minion.pos) < 350 and myHero.pos:DistanceTo(minion.pos) > 125 then
				Control.CastSpell(HK_Q, minion)
				end
			end
		end

		if self:CanCast(_W) and minion then 
			if self.Menu.ClearMode.UseW:Value() and IsValid(minion, 175) then
				if myHero.pos:DistanceTo(minion.pos) < 175 and myHero.attackData.state == STATE_WINDDOWN then
					Control.CastSpell(HK_W)
					Control.Attack(minion)
				end
			end
		end
	end
	end
end




--------------------------------------------------------------------------------------------------------------------------------------------------------------





class "XinZhao"







function XinZhao:GetValidEnemy(range)
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < E.range then
            return true
        end
    end
    return false
end

function XinZhao:GetValidMinion(range)
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < E.range then
            return true
        end
    end
    return false
end

function XinZhao:isReady(spell)
return Game.CanUseSpell(spell) == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function XinZhao:EDMG(unit)
	total = 0
	local eLvl = myHero:GetSpellData(_E).level
    if eLvl > 0 then
	local edamage = (({50,75,100,125,150})[eLvl] + 0.6 * myHero.ap)
	total = edamage
	end
	return total
end

function XinZhao:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function XinZhao:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end	
end

function XinZhao:LoadSpells()
	Q = {range = 375}
	W = {range = 900, Delay = 0.30, Width = 70, Speed = 1600, Collision = false, aoe = false}
	E = {range = 650}
	R = {range = 500}
end



function XinZhao:LoadMenu()
	--Main Menu
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "PussyXinZhao"})
	
	--Main Menu-- PussyXinZhao
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "PussyXinZhao"})
	--Main Menu-- PussyXinZhao -- Combo
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "UseW if Target Flee", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "E", name = "Use E", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "R", name = "Use R", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "RHP", name = "R when target HP%", value = 20, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo:MenuElement({id = "myRHP", name = "R when XinZhao HP%", value = 30, min = 0, max = 100, step = 1})
	
	--Main Menu-- PussyXinZhao -- Harass
	self.Menu.Mode:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Mode.Harass:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.Harass:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.Harass.MM:MenuElement({id = "WMana", name = "Min Mana to W in Harass(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- PussyXinZhao -- LaneClear
	self.Menu.Mode:MenuElement({type = MENU, id = "LaneClear", leftIcon = Icons["Clear"]})
	self.Menu.Mode.LaneClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "WMinion", name = "Use W when X minions", value = 3,min = 1, max = 4, step = 1})
	self.Menu.Mode.LaneClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "E", name = "Use E", value = true})
	--Main Menu-- PussyXinZhao -- JungleClear
	self.Menu.Mode:MenuElement({type = MENU, id = "JungleClear", leftIcon = Icons["JClear"]})
	self.Menu.Mode.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "E", name = "Use E", value = true})
	
	--Main Menu-- PussyXinZhao -- KillSteal
	self.Menu.Mode:MenuElement({type = MENU, id = "KS", leftIcon = Icons["ks"]})
	self.Menu.Mode.KS:MenuElement({id = "E", name = "UseE KS", value = true})	
	
	--Main Menu-- PussyXinZhao -- Spell Range 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "E", name = "Draw E Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
	self.Menu.Drawing:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
end

function XinZhao:Tick()
if MyHeroReady() then
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
	elseif Mode == "Flee" then
		
	end	
		
	self:KS()
end
end

function XinZhao:KS()
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
	
	if IsValid(target,650) and myHero.pos:DistanceTo(target.pos) <= 650 then
		local edamage = self:EDMG(target)
		if self.Menu.Mode.KS.E:Value() and self:isReady(_E) and not myHero.isChanneling and edamage > self:HpPred(target,1) + target.hpRegen * 1  then
			Control.CastSpell(HK_E,target)
		end
	end			
end

function XinZhao:Combo()

	if self:GetValidEnemy(800) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
			if IsValid(target,650) and myHero.pos:DistanceTo(target.pos) <= 650 and self.Menu.Mode.Combo.E:Value() and self:isReady(_E) and not myHero.isChanneling  then
			Control.CastSpell(HK_E,target)
	    	if IsValid(target,900) and myHero.pos:DistanceTo(target.pos) > 400 and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
			Control.CastSpell(HK_W,target)
	    	end
	    	if IsValid(target,375) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
			Control.CastSpell(HK_Q)
	    	end 
	    	if IsValid(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and target.health/target.maxHealth <= self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
			Control.CastSpell(HK_R)
	    	end
	    end		
		if IsValid(target,900) and myHero.pos:DistanceTo(target.pos) > 400 and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W,target)
	    	if IsValid(target,375) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
		Control.CastSpell(HK_Q)
	    	end
	    	if IsValid(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and target.health/target.maxHealth <= self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    	end
	    end	
	    if IsValid(target,375) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
		Control.CastSpell(HK_Q)
	    	if IsValid(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and target.health/target.maxHealth <= self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    	end
	    end   
		if IsValid(target,R.range) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and target.health/target.maxHealth <= self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    end
		if IsValid(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and not myHero.isChanneling and
		myHero.health/myHero.maxHealth <= self.Menu.Mode.Combo.myRHP:Value()/100 then
		Control.CastSpell(HK_R)
		end
		

end	


function XinZhao:Harass()

	if self:GetValidEnemy(800) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	if target.pos:DistanceTo(myHero.pos) <= W.range and (myHero.mana/myHero.maxMana >= self.Menu.Mode.Harass.MM.WMana:Value() / 100) and self.Menu.Mode.Harass.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W,target)
	end
end



function XinZhao:Clear()

	if self:GetValidMinion(600) == false then return end
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
			if minion.team == TEAM_ENEMY then
				if minion.pos:DistanceTo(myHero.pos) <= E.range and self.Menu.Mode.LaneClear.E:Value() and self:isReady(_E) then
					Control.CastSpell(HK_E,minion)
					break
				end	
				if IsValid(minion,W.range) and self.Menu.Mode.LaneClear.W:Value() and self:isReady(_W) then
					if GetMinionCount(W.range, minion) >= self.Menu.Mode.LaneClear.WMinion:Value() then
						Control.CastSpell(HK_W,minion)
						break
					end	
				end
				if IsValid(minion,Q.range) and self.Menu.Mode.LaneClear.Q:Value() and self:isReady(_Q) then
					Control.CastSpell(HK_Q)
					break
				end
			end
			if minion.team == TEAM_JUNGLE then
				if  minion.pos:DistanceTo(myHero.pos) <= E.range and self.Menu.Mode.JungleClear.E:Value() and self:isReady(_E) then
					Control.CastSpell(HK_E,minion)
					break
				end
				if IsValid(minion,Q.range) and self.Menu.Mode.JungleClear.Q:Value() and self:isReady(_Q) then
				Control.CastSpell(HK_Q)
				break
				end 
				if IsValid(minion,W.range) and self.Menu.Mode.JungleClear.W:Value() and self:isReady(_W) then
					Control.CastSpell(HK_W,minion)
					break
				end	
			end
		end
	end

	
function XinZhao:Draw()
if myHero.dead then return end
	if self.Menu.Drawing.E:Value() then 
		Draw.Circle(myHero.pos, 650, self.Menu.Drawing.Width:Value(), self.Menu.Drawing.Color:Value())	
	end	
end	


-------------------------------------------------------------------------------------------------------------------------------


class "HPred"


	
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
		["KatarinaE"] = -255,
		
		--Katarina can target a dagger to teleport directly to it: Each skin has a different particle name. This should cover all of them.
		["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, 
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
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
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
	
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
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
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t and self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then
			
			local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) * (t.boundingRadius + width)) then
				targetCount = targetCount + 1
			end
		end
	end
	return targetCount
end

--Will return the valid target who has the highest hit chance and meets all conditions (minHitChance, whitelist check, etc)
function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist, isLine)
	local _validTargets = {}
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)		
		if t and self:CanTarget(t, true) and (not whitelist or whitelist[t.charName]) then
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision, isLine)		
			if hitChance >= minimumHitChance then
				table.insert(_validTargets, {aimPosition,hitChance, hitChance * 100 + self:CalculateMagicDamage(t, 400)})
			end
		end
	end	
	table.sort(_validTargets, function( a, b ) return a[3] >b[3] end)	
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
					reactionTime = reactionTime + .25
				else
					reactionTime = reactionTime + .15
				end
			end
		end
	end			

	--If they are standing still give a higher accuracy because they have to take actions to react to it
	if not target.pathing or not target.pathing.hasMovePath then
		hitChancevisionData = 2
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
			hitChance = 5
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
			hitChance = math.min(hitChance, 2)
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
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
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
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
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
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
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
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * math.min(self:GetDistance(t.activeSpell.startPos,endPos), range)
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
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
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
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
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
	for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i)
		if turret and turret.isEnemy and not _cachedTeleports[turret.networkID] then
			local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
			if hasBuff then
				self:RecordTeleport(turret, self:GetTeleportOffset(turret.pos,223.31),expiresAt)
			end
		end
	end	
	
	--Get enemies who are teleporting to wards	
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i)
		if ward and ward.isEnemy and not _cachedTeleports[ward.networkID] then
			local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
			if hasBuff then
				self:RecordTeleport(ward, self:GetTeleportOffset(ward.pos,100.01),expiresAt)
			end
		end
	end
	
	--Get enemies who are teleporting to minions
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
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




--Right now only used to cache enemy windwalls
function HPred:CacheParticles()	
	if _windwall and _windwall.name == "" then
		_windwall = nil
	end
	
	for i = 1, Game.ParticleCount() do
		local particle = Game.Particle(i)		
		if particle and self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then			
			if string.find(particle.name, "W_windwall%d") and not _windwall then
				--We don't care about ally windwalls for now
				local owner =  self:GetObjectByHandle(particle.handle)
				if owner and owner.isEnemy then
					_windwall = particle
					_windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)				
					
					local index = string.len(particle.name) - 5
					local spellLevel = string.sub(particle.name, index, index) -1
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
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		if missile and not _cachedMissiles[missile.networkID] and missile.missileData then
			--Handle targeted missiles
			if missile.missileData.target and missile.missileData.owner then
				local missileName = missile.missileData.name
				local owner =  self:GetObjectByHandle(missile.missileData.owner)	
				local target =  self:GetObjectByHandle(missile.missileData.target)		
				if owner and target and string.find(target.type, "Hero") then			
					--The missile is an auto attack of some sort that is targeting a player	
					if (string.find(missileName, "BasicAttack") or string.find(missileName, "CritAttack")) then
						--Cache it all and update the count
						_cachedMissiles[missile.networkID] = {}
						_cachedMissiles[missile.networkID].target = target
						_cachedMissiles[missile.networkID].data = missile
						_cachedMissiles[missile.networkID].danger = 1
						_cachedMissiles[missile.networkID].timeout = currentTime + 1.5
						
						local damage = owner.totalDamage
						if string.find(missileName, "CritAttack") then
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
	local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
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
	local angle = math.atan2(deltaPos.x, deltaPos.z) *  180 / math.pi	
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
		local buff = unit:GetBuff(i)
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
		local buff = unit:GetBuff(i)
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
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.handle == handle then
			target = minion
			return target
		end
	end
	
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i)
		if ward and ward.handle == handle then
			target = ward
			return target
		end
	end
	
	for i = 1, Game.TurretCount() do 
		local turret = Game.Turret(i)
		if turret and turret.handle == handle then
			target = turret
			return target
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
		if particle and particle.handle == handle then
			target = particle
			return target
		end
	end
end

function HPred:GetHeroByPosition(position)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetObjectByPosition(position)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.MinionCount() do
		local enemy = Game.Minion(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.WardCount() do
		local enemy = Game.Ward(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, Game.ParticleCount() do 
		local enemy = Game.Particle(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
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
	for i = 1, Game.ParticleCount() do 
		local particle = Game.Particle(i)
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
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
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
		B.x >= math.min(A.x, C.x) and
		B.z <= _max(A.z, C.z) and
		B.z >= math.min(A.z, C.z)
end

--Gets the slope between two vectors. Ignores Y because it is non-needed height data. Its all 2d math.
function HPred:GetSlope(A, B)
	return (B.z - A.z) / (B.x - A.x)
end

function HPred:GetEnemyByName(name)
	local target
	for i = 1, Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy and enemy.isEnemy and enemy.charName == name then
			target = enemy
			return target
		end
	end
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	local deltaAngle = math.abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
	if deltaAngle < angle and self:IsInRange(origin,target,range) then
		return true
	end
end

function HPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return math.huge
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
		return math.huge
	end
	return math.sqrt(self:GetDistanceSqr(p1, p2))
end


local Jungle = {"LeeSin","Nidalee","XinZhao","Warwick"}
if table.contains(Jungle, myHero.charName) then
	_G[myHero.charName]()
end	

function OnLoad()
	AutoUpdate()

end

    local Version = 0.1
    
    local Files = {
        Lua = {
            Path = COMMON_PATH,
            Name = "PussyJUNGLE.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyJUNGLE.lua"
        },
        Version = {
            Path = COMMON_PATH,
            Name = "PussyJUNGLE.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyJUNGLE.version"
        }	
    }
    
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

	local function AutoUpdate()
        

        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        local textPos = myHero.pos:To2D()
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print("New PussyJungle Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end	
	end



class "LeeSin"





local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 65, Range = 1200, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
}



--require 'MapPositionGOS'

local _wards = {2055, 2049, 2050, 2301, 2302, 2303, 3340, 3361, 3362, 3711, 1408, 1409, 1410, 1411, 2043, 3350, 3205, 3207, 2045, 2044, 3154, 3160}
				
function LeeSin:__init()
  mySmiteSlot = self:GetSmite(SUMMONER_1);
  if mySmiteSlot == 0 then
	mySmiteSlot = self:GetSmite(SUMMONER_2);
  end	

  if menu ~= 1 then return end
  menu = 2   	
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
	self.Menu:MenuElement({type = MENU, id = "AutoQ", leftIcon = Icons["AutoQImmo"]})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto[Q] + Auto[W]SavePos", value = true})

	--AutoW 
	self.Menu:MenuElement({type = MENU, id = "AutoW", leftIcon = Icons["AutoW"]})
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Safe Ally/Self", value = true})
	self.Menu.AutoW:MenuElement({id = "Heal", name = "min Hp Self or Ally", value = 30, min = 0, max = 100, identifier = "%"})	

	--AutoR
	self.Menu:MenuElement({type = MENU, id = "AutoR", leftIcon = Icons["AutoRSafeLife"]})
	self.Menu.AutoR:MenuElement({id = "UseR", name = "Auto[R] safe your Life", value = true})
	self.Menu.AutoR:MenuElement({id = "Heal", name = "min Hp", value = 20, min = 0, max = 100, identifier = "%"})	
		
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Combo:MenuElement({id = "Gap", name = "Gapclose[WardJump]", value = true})
	
	self.Menu.Combo:MenuElement({id = "Set", name = "Gapclose Settings", type = MENU})		
	self.Menu.Combo.Set:MenuElement({id = "minRange", name = "MinCastDistance if not Ready[Q]", value = 600, min = 600, max = 1000, step = 50})	
	self.Menu.Combo.Set:MenuElement({id = "maxRange", name = "MaxCastDistance if not Ready[Q]", value = 1000, min = 1000, max = 1500, step = 50})	
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Energy to Harass", value = 40, min = 0, max = 100, identifier = "%"})
   
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})			
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Clear:MenuElement({id = "Heal", name = "min selfHp Use[W]", value = 70, min = 0, max = 100, identifier = "%"})	
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use[E] min Minions", value = 3, min = 1, max = 6, step = 1})  		
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Energy to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})         	
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Energy to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})				
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	self.Menu.ks:MenuElement({id = "UseQR", name = "[Q]+[R]", value = true})	
	
	
	--JungleSteal
	self.Menu:MenuElement({type = MENU, id = "Jsteal", leftIcon = Icons["junglesteal"]})
	self.Menu.Jsteal:MenuElement({name = " ", drop = {"Ward+Q1+Q2+W back Ward [You need Smite Activator]"}})
	self.Menu.Jsteal:MenuElement({id = "Dragon", name = "Steal Dragon", value = true})
	self.Menu.Jsteal:MenuElement({id = "Baron", name = "Steal Baron", value = true})
	self.Menu.Jsteal:MenuElement({id = "Herald", name = "Steal Herald", value = true})	
	self.Menu.Jsteal:MenuElement({id = "Active", name = "Activate Key", key = string.byte("Z")})	

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Insec
	self.Menu:MenuElement({id = "Modes", leftIcon = Icons["InsecMode"], type = MENU}) 
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
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
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
	
	if IsValid(target, 1300) then
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
			if myHero.pos:DistanceTo(target.pos) <= 350 and not HasBuff(target, "BlindMonkQOne") and Ready(_Q) and pred.Hitchance >= 2 then
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
		if IsValid(target, 1300) then
			
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
		if IsValid(target, 1300) then
			
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
		if IsValid(target, 1300) then
			
			if myHero.pos:DistanceTo(target.pos) < 375 and Ready(_R) and myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
				self:Cast(HK_R, target.pos)
			end
						
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) then
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
		if IsValid(target, 1300) then
			
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
			if myHero.pos:DistanceTo(target.pos) <= 1200 and Ready(_Q) then
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
							if IsValid(Hero, 1300) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1300 then	
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
							if IsValid(Hero, 1300) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1300 then	
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
							if IsValid(Hero, 1500) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1500 then								
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
							if IsValid(Hero, 1500) and Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos) <= 1500 then	
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
	
	if IsValid(target,1500) and myHero.pos:DistanceTo(target.pos) <= 1200 and self.Menu.AutoQ.UseQ:Value() and Ready(_Q) then
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
	if IsValid(target,1000) and myHero.pos:DistanceTo(target.pos) <= 1000 then
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
local target = GetTarget(800)     	
if target == nil then return end	
	
	if self.Menu.AutoW.UseW:Value() and Ready(_W) then
		if myHero.health/myHero.maxHealth <= self.Menu.AutoW.Heal:Value()/100 then
			Control.CastSpell(HK_W, myHero)
			if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
				Control.CastSpell(HK_W)
			end
		end
		for i, ally in pairs(GetAllyHeroes()) do
			if IsValid(ally,1000) and myHero.pos:DistanceTo(ally.pos) <= 700 and ally.health/ally.maxHealth <= self.Menu.AutoW.Heal:Value()/100 then
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
	if IsValid(target,1500) then
		
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
	if IsValid(target,1500) then
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
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
			
			if self.Menu.Clear.UseQ ~= nil and self.Menu.Clear.UseQ:Value() then
			
				if HasBuff(minion, "BlindMonkQOne") and myHero.pos:DistanceTo(minion.pos) <= 1300 then
					Control.CastSpell(HK_Q)
				
				elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and myHero.pos:DistanceTo(minion.pos) >= 500 and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end

			local passiveBuff = GetBuffData(myHero,"blindmonkpassive_cosmetic")
			if  passiveBuff.count == 1 then return end
            
			if self.Menu.Clear.UseW ~= nil and self.Menu.Clear.UseW:Value() then
			
				if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
					Control.CastSpell(HK_W)
			
				elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= 500 and Ready(_W) then
					if myHero.health/myHero.maxHealth <= self.Menu.Clear.Heal:Value()/100 then
						Control.CastSpell(HK_W, myHero)
					end
				end
			end
            
			if self.Menu.Clear.UseE ~= nil and self.Menu.Clear.UseE:Value() then
			
				if myHero:GetSpellData(_E).name == "BlindMonkETwo" and GetMinionCount(500, myHero) >= self.Menu.Clear.UseEM:Value() then
					Control.CastSpell(HK_E)
					
				elseif mana_ok and GetMinionCount(350, myHero) >= self.Menu.Clear.UseEM:Value() and Ready(_E) then
					Control.CastSpell(HK_E)
				end
			end
            
			if self.Menu.Clear.UseR ~= nil and self.Menu.Clear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end



function LeeSin:JungleClear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.JClear.Mana == nil or (self.Menu.JClear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100))
            
			if self.Menu.JClear.UseQ ~= nil and self.Menu.JClear.UseQ:Value() then
			
				if myHero:GetSpellData(_Q).name == "BlindMonkQTwo" and myHero.pos:DistanceTo(minion.pos) <= 1300 then
					Control.CastSpell(HK_Q)
			
				elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end
			
			
			local passiveBuff = GetBuffData(myHero,"blindmonkpassive_cosmetic")
			if  passiveBuff.count == 1 then return end
           
			if self.Menu.JClear.UseW ~= nil and self.Menu.JClear.UseW:Value() then
			
				if myHero:GetSpellData(_W).name == "BlindMonkWTwo" then
					Control.CastSpell(HK_W)		    
			
				elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
					Control.CastSpell(HK_W, myHero)
				end
			end
            
			if self.Menu.JClear.UseE ~= nil and self.Menu.JClear.UseE:Value() then
			
				if myHero:GetSpellData(_E).name == "BlindMonkETwo" and GetMinionCount(500, myHero) >= 1 then
					Control.CastSpell(HK_E)
						
				elseif mana_ok and GetMinionCount(350, myHero) >= 1 and Ready(_E) and not Ready(_W) then
					Control.CastSpell(HK_E)
				end
			end
            
			if self.Menu.JClear.UseR ~= nil and self.Menu.JClear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
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
			
			if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 1500 then
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
	
	

	if IsValid(target,1500) and myHero.pos:DistanceTo(target.pos) <= 1300 then
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

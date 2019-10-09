local Heroes = {"Mordekaiser","Kayle","Irelia"}


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
            Name = "PussyTOP.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyTOP.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyTOP.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyTOP.version"
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
            print("New PussyTop Version Press 2x F6")
        else
            print("PussyTop loaded")
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
local charging = false
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local Orb

local function GetTarget(range) 
	if Orb == 1 then
		if myHero.ap > myHero.totalDamage then
			return EOW:GetTarget(range, EOW.ap_dec, myHero.pos)
		else
			return EOW:GetTarget(range, EOW.ad_dec, myHero.pos)
		end
	elseif Orb == 2 and SDK.TargetSelector then
		if myHero.ap > myHero.totalDamage then
			return SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
		else
			return SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		end
	elseif _G.GOS then
		if myHero.ap > myHero.totalDamage then
			return GOS:GetTarget(range, "AP")
		else
			return GOS:GetTarget(range, "AD")
        end
    elseif _G.gsoSDK then
		return _G.gsoSDK.TS:GetTarget()
	end
end

class "Kayle"




function GunbladeDMG() 
    local level = myHero.levelData.lvl
    local damage = ({175,180,184,189,193,198,203,207,212,216,221,225,230,235,239,244,248,253})[level] + 0.30 * myHero.ap
	return damage
end

local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.5 - myHero.attackSpeed, Radius = 195, Range = 850, Speed = 500, Collision = false
}



function Kayle:__init()
	
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end) 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
end

function Kayle:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Kayle", name = "PussyKayle"})

	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	self.Menu.AutoW:MenuElement({id = "self", name = "Heal self", value = true})
	self.Menu.AutoW:MenuElement({id = "ally", name = "Heal Ally", value = true})
	self.Menu.AutoW:MenuElement({id = "HP", name = "HP Self/Ally", value = 50, min = 0, max = 100, step = 1, identifier = "%"})
	self.Menu.AutoW:MenuElement({id = "Mana", name = "min. Mana", value = 50, min = 0, max = 100, step = 1, identifier = "%"})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})			
	self.Menu.Combo:MenuElement({type = MENU, id = "UseR", name = "Ult Settings"})
	self.Menu.Combo.UseR:MenuElement({id = "self", name = "Ult self", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "ally", name = "Ult Ally", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "HP", name = "HP Self/Ally", value = 40, min = 0, max = 100, step = 1, identifier = "%"})	
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "Lasthit[Q] Radiant Blast", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "Lasthit[E] Starfire Spellblade", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})		
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.ks:MenuElement({id = "gun", name = "Hextech Gunblade + [Q]", value = true})	

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Kayle:Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
		
	end
	self:KillSteal()
	self:KillStealE()
	self:AutoW()
end

function Kayle:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 500, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 850, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 900, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
end

function Kayle:AutoW()
local target = GetTarget(1200)     	
if target == nil then return end		
	if IsValid(target) and myHero.health/myHero.maxHealth <= self.Menu.AutoW.HP:Value()/100 and myHero.mana/myHero.maxMana >= self.Menu.AutoW.Mana:Value() / 100 then
		if self.Menu.AutoW.self:Value() and Ready(_W) then
			Control.CastSpell(HK_W, myHero)
			
		end
		if self.Menu.AutoW.ally:Value() and Ready(_W) then		
			for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
				if unit.isAlly and IsValid(unit) then
				local Hp = GetPercentHP(unit)
						if Hp <= self.Menu.AutoW.HP:Value() and myHero.pos:DistanceTo(unit.pos) <= 900 then
							Control.CastSpell(HK_W, unit)	
						end	
					end
				end
			end
		end	
	end	

function Kayle:KillStealE()	
	local target = GetTarget(600)     	
	if target == nil then return end

	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= myHero.range then
		local hp = target.health
		local EDmg = getdmg("E", target, myHero)

		
		if self.Menu.ks.UseE:Value() and Ready(_E) then
			if EDmg >= hp then
				Control.CastSpell(HK_E)
		
			end			
		end	
	end
end	
       
function Kayle:KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) <= 900 then	
		local hp = target.health
		local QDmg = getdmg("Q", target, myHero)
		local GunDmg = GunbladeDMG()
		if myHero.pos:DistanceTo(target.pos) <= 850 and QDmg >= hp and self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end

		local Gun = GetItemSlot(myHero, 3146)
		if myHero.pos:DistanceTo(target.pos) <= 700 and (QDmg + GunDmg) >= hp and self.Menu.ks.gun:Value() and Ready(_Q) and Gun > 0 and Ready(Gun) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(ItemHotKey[Gun], target.pos)
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end	

function Kayle:Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target) then
			
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= myHero.range and self.Menu.Combo.UseE:Value() and Ready(_E) then					
			Control.CastSpell(HK_E)
	
		end
		
		if myHero.health/myHero.maxHealth <= self.Menu.Combo.UseR.HP:Value()/100 then	
			if Ready(_R) and self.Menu.Combo.UseR.self:Value() then
				Control.CastSpell(HK_R, myHero)
			end
		end
		if Ready(_R) and self.Menu.Combo.UseR.ally:Value() then
			for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
				if unit.isAlly and IsValid(unit) then
				local enemy = EnemiesAround(unit, 650)			
					if enemy >= 1 and unit.health/unit.maxHealth <= self.Menu.Combo.UseR.HP:Value()/100 and myHero.pos:DistanceTo(unit.pos) <= 900  then
						Control.CastSpell(HK_R, unit)
					end
				end
			end	
		end
	end	
end	

function Kayle:Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= myHero.range and self.Menu.Harass.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E)
	
			
		end
	end
end	

function Kayle:Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100
            if self.Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_Q) then	
				local QDmg = getdmg("Q", minion, myHero)	
				if QDmg > minion.health  then
					Control.CastSpell(HK_Q, minion.pos)
				end	
            end

            if self.Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero.range and Ready(_E) and not Ready(_Q) then
                local EDmg = getdmg("E", minion, myHero)
				if  EDmg > minion.health then
					Control.CastSpell(HK_E)

				end
            end
        end
    end
end

function Kayle:JungleClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion) then
            local mana_ok =  myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100
            if self.Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end

            if self.Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero.range and Ready(_E) then
                Control.CastSpell(HK_E)
            end
        end
    end
end



-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "Mordekaiser"



function Mordekaiser:__init()
	
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 400, Range = 675, Speed = 500, Collision = false
	}
  	
	self:LoadMenu()                                            
 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)	
end

function Mordekaiser:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Mordekaiser", name = "PussyMordekaiser"})

	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "Pull Enemys under Tower",value = true})

	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "AutoW"})
	self.Menu.AutoW:MenuElement({id = "UseW", name = "AutoW", value = true})
	self.Menu.AutoW:MenuElement({id = "UseWE", name = "Minimum Health", value = 50, min = 0, max = 100, identifier = "%"})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Combo:MenuElement({id = "count", name = "[E]Minimum Targets", value = 2, min = 1, max = 5})	
	
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})

  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})	

	
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JungleClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true}) 
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
 	
    
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})			
	self.Menu.ks:MenuElement({id = "Targets", name = "Ult Settings", type = MENU})	
	self.Menu.ks.Targets:MenuElement({id = "UseR", name = "[R] FullDmg", value = true})
	for i, Hero in pairs(GetEnemyHeroes()) do
		self.Menu.ks.Targets:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
	end		
	
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})	
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q]Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R]Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]Range", value = true})


end

function Mordekaiser:Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
		self:JClear()			
		
	end	

	self:KillSteal()
	self:AutoE()
	self:AutoW()

	
end

function Mordekaiser:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 650, 1, Draw.Color(255, 225, 255, 10)) 
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 625, 1, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawing.DrawE:Value()) and Ready(_E) then
    Draw.Circle(myHero, 900, 1, Draw.Color(225, 225, 125, 10))
	end

	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end				
end	

function Mordekaiser:AutoW()
	if myHero.health/myHero.maxHealth <= self.Menu.AutoW.UseWE:Value()/100 and self.Menu.AutoW.UseW:Value() and Ready(_W) then
		if HasBuff(myHero, "MordekaiserW") then 
			Control.CastSpell(HK_W)
		end
		if not HasBuff(myHero, "MordekaiserW") then 
			Control.CastSpell(HK_W)
		end			
	end
end

function Mordekaiser:AutoE()
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
		
        if self.Menu.AutoE.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 900 and IsUnderAllyTurret(myHero) and Ready(_E) then
			Control.CastSpell(HK_E, target.pos)
        end		
	end
end

function Mordekaiser:KillSteal()	
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
		if self.Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then	
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end	
        end

        if self.Menu.ks.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 900 and Ready(_E) then
            local EDmg = getdmg("E", target, myHero)
			if EDmg >= target.health then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
			end	
        end
        if self.Menu.ks.Targets.UseR:Value() and self.Menu.ks.Targets[target.charName] and self.Menu.ks.Targets[target.charName]:Value() and myHero.pos:DistanceTo(target.pos) <= 650 and Ready(_R) then
			if (getdmg("Q", target, myHero)+getdmg("E", target, myHero))*2 >= target.health then
				Control.CastSpell(HK_R, target.pos)
			end	
		end
	end	
end	

function Mordekaiser:Combo()
	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
		if self.Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then	
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
        end

        if self.Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= 900 and Ready(_E) then
            local count = GetEnemyCount(200, target)
			if count >= self.Menu.Combo.count:Value() then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
			end	
        end
	end
end

function Mordekaiser:Harass()

	local target = GetTarget(1000)
	if target == nil then return end
	if IsValid(target) then
        
        
		if self.Menu.Harass.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= 625 and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then	
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
        end	
	end
end	

function Mordekaiser:Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion) then
           
           
			if self.Menu.Clear.UseQ:Value() and myHero.pos:DistanceTo(minion.pos) <= 625 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end

            if self.Menu.Clear.UseE:Value() and myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_E) then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
            end
        end
    end
end

function Mordekaiser:JClear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion) then
            
           
			if self.Menu.JClear.UseQ:Value() and myHero.pos:DistanceTo(minion.pos) <= 625 and Ready(_Q) then
				Control.CastSpell(HK_Q, minion.pos)
            end

            if self.Menu.JClear.UseE:Value() and myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_E) then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
            end
        end
    end
end


-----------------------------------------------------------------------------------------------------------------------------------

class "Irelia"

local WData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.6 + ping, Radius = 100, Range = 825, Speed = 1400, Collision = false
}

local EData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.75 + ping, Radius = 50, Range = 775, Speed = 2000, Collision = false
}

local RData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25 + ping, Radius = 160, Range = 1000, Speed = 2000, Collision = false
}

function Irelia:__init()
   	
	self:LoadMenu()                                            
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end) 
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
end

function Irelia:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Irelia", name = "PussyIrelia"})

	--Flee
	self.Menu:MenuElement({type = MENU, id = "Flee", name = "Flee"})
	self.Menu.Flee:MenuElement({id = "Q", name = "Flee[Q]", value = true})	

	--AutoE 
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "AutoE"})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "2-5 Enemys stunable", value = true})	
	
	--AutoQ
	self.Menu:MenuElement({type = MENU, id = "AutoQ", name = "AutoQ LastHit"})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto LastHit Minion", value = true})
	self.Menu.AutoQ:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.AutoQ:MenuElement({id = "Q", name = "Auto Q Toggle Key", key = 84, toggle = true})
	self.Menu.AutoQ:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
			
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({name = " ", drop = {"E1, W, R, Q, E2, Q + (Q when kill / almost kill)"}})
	self.Menu.Combo:MenuElement({id = "QLogic", name = "Last[Q]Almost Kill or Kill", key = string.byte("I"), toggle = true})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Logic", value = 1, drop = {"Marked + Dash back Minion", "Everytime"}})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})
	self.Menu.Clear:MenuElement({type = MENU, id = "Last", name = "LastHit"})
	self.Menu.Clear.Last:MenuElement({id = "UseQ", name = "LastHit[Q]", value = true})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Clear:MenuElement({id = "UseItem", name = "Use Hydra/Tiamat", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
	self.Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})	
 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end	

function Irelia:Tick()
if MyHeroNotReady() then return end
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
	elseif Mode == "Flee" then
		self:Flee()		
	end

	self:KillSteal()
	self:CastE2()
	if self.Menu.AutoQ.Q:Value() and Mode ~= "Combo" then
		self:AutoQ()
	end
end

function Irelia:UseHydraminion(minion)
local hydraitem = GetInventorySlotItem(3748) or GetInventorySlotItem(3077) or GetInventorySlotItem(3074)
	if hydraitem and myHero.pos:DistanceTo(minion.pos) <= 400 then
		Control.CastSpell(keybindings[hydraitem])
	end
end

function Irelia:Draw()
  if myHero.dead then return end
	
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 900, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 775, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 825, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	local Mode = GetMode()
	if self.Menu.AutoQ.UseQ:Value() and Mode ~= "Combo" then
		if self.Menu.AutoQ.Q:Value() then 
			Draw.Text("Auto[Q]Minion ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
		else
			Draw.Text("Auto[Q]Minion OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
		end	
	end	

	if Mode == "Combo" then	
		if self.Menu.Combo.QLogic:Value() then
			Draw.Text("[Q]Almost Kill", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
		else
			Draw.Text("[Q]Kill", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
		end	
	end		
	
	local target = GetTarget(1000)
	if target == nil then return end	
	if target and myHero.pos:DistanceTo(target.pos) <= 1000 and not target.dead then
	local Dmg = (getdmg("Q", target, myHero) + getdmg("W", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero)) 
	local hp = target.health	
		if myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_E).level > 0 and myHero:GetSpellData(_R).level > 0 and Dmg > hp then
			Draw.Text("KILL HIM", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
		else
			Draw.Text("HARASS HIM", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
		end	
	end
end
 
function Irelia:Combo()
local target = GetTarget(1100)     	
if target == nil then return end
	if IsValid(target) then
		
		if self.Menu.Combo.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				self:CastE(target)

			end
		end	
			
		
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and GotBuff(target, "ireliamark") == 1 then
			Control.CastSpell(HK_Q, target.pos)
		end
		
		
		if self.Menu.Combo.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				Control.CastSpell(HK_W, target)

			end
		end	
		

		if self.Menu.Combo.UseR:Value() and Ready(_R) and not Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 1000 then					
				self:CastR(target)

			end
		end	
		
		if self.Menu.Combo.QLogic:Value() then 
		local dmg = getdmg("Q", target, myHero) 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				if dmg >= target.health then
					Control.CastSpell(HK_Q, target.pos)
				end
			end			
			
			if myHero.pos:DistanceTo(target.pos) >= 300 and myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and (dmg*2) >= target.health then
				Control.CastSpell(HK_Q, target.pos)
			end		
		
		else
			local dmg = getdmg("Q", target, myHero) 
			if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
				if dmg >= target.health then
					Control.CastSpell(HK_Q, target.pos)
				end
			end
		end
		self:Gapclose(target)
		self:StackPassive(target)
	end	
end	

function Irelia:Harass()
local target = GetTarget(1100)     	
if target == nil then return end
	if IsValid(target) then
				
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) then
			if self.Menu.Harass.UseQ:Value() ~= 2 and GotBuff(target, "ireliamark") == 1 then
				Control.CastSpell(HK_Q, target.pos)
				DelayAction(function()
				self:CastQMinion(target)
				end,0.5)
			end	
			if self.Menu.Harass.UseQ:Value() ~= 1 then
				Control.CastSpell(HK_Q, target.pos)
			end	
		end
		
		if self.Menu.Harass.UseW:Value() and Ready(_W) then
			if myHero.pos:DistanceTo(target.pos) <= 825 then					
				self:CastW(target)
				
			end
		end	
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) <= 725 then					
				self:CastE(target)
				
			end
		end	
	end	
end
	
function Irelia:AutoQ()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if self.Menu.AutoQ.UseItem:Value() then
				self:UseHydraminion(minion)
			end	
            
			if self.Menu.AutoQ.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.AutoQ.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					Control.CastSpell(HK_Q, minion.pos)
				end
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					Control.CastSpell(HK_Q, minion.pos)
				end
            end
		end
	end
end

function Irelia:StackPassive(target)
if GotBuff(myHero, "ireliapassivestacksmax") == 1 then return end	
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			if target.pos:DistanceTo(minion.pos) <= 600 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health then
					Control.CastSpell(HK_Q, minion.pos)
				end
			end
			self:UseHydraminion(minion)
		end
	end
end	
			
function Irelia:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
 			
			if self.Menu.Clear.UseW:Value() and Ready(_W) and not Ready(_Q) and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 825 then
				Control.CastSpell(HK_W, minion.pos)
                    
            end           
           
			if self.Menu.AutoQ.Q:Value() then return end
			if self.Menu.Clear.UseItem:Value() then
				self:UseHydraminion(minion)
			end				
			
			if self.Menu.Clear.Last.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 and myHero.pos:DistanceTo(minion.pos) <= 600 and Ready(_Q) then
				local QDmg = getdmg("Q", minion, myHero, 2)
				if QDmg > minion.health and not IsUnderTurret(minion) then
					Control.CastSpell(HK_Q, minion.pos)
				end	
				if QDmg > minion.health and IsUnderTurret(minion) and AllyMinionUnderTower() then
					Control.CastSpell(HK_Q, minion.pos)
				end				
			end
        end
    end
end

function Irelia:KillSteal()
	local target = GetTarget(1100)     	
	if target == nil then return end
	
	
	if IsValid(target) then	
		if myHero.pos:DistanceTo(target.pos) <= 600 and Ready(_Q) and self.Menu.ks.UseQ:Value() then
			local QDmg = getdmg("Q", target, myHero)
			local hp = target.health
			if QDmg >= hp then
				Control.CastSpell(HK_Q, target.pos)
				DelayAction(function()
				self:CastQMinion(target)
				end,0.5)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 825 and Ready(_W) and self.Menu.ks.UseW:Value() then
			local WDmg = getdmg("W", target, myHero)
			local hp = target.health
			if WDmg >= hp then
				self:CastW(target)
			end
		end	
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_R) and self.Menu.ks.UseR:Value() then
			local RDmg = getdmg("R", target, myHero)
			local hp = target.health
			if RDmg >= hp then
				self:CastR(target)
			end
		end
	end
end	

function Irelia:CastQMinion(target)
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion) then
			local Dmg = getdmg("Q", target, myHero) or getdmg("W", target, myHero) or getdmg("E", target, myHero) or getdmg("R", target, myHero)
			local QDmg = getdmg("Q", minion, myHero, 2)
			local hp = target.health
			if myHero.pos:DistanceTo(minion.pos) <= 600 and myHero.pos:DistanceTo(minion.pos) > myHero.pos:DistanceTo(target.pos) and not IsUnderTurret(minion) and hp > Dmg and QDmg >= minion.health then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end
end	

function Irelia:Gapclose(target)
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	

		if myHero.pos:DistanceTo(target.pos) > 500 and myHero.pos:DistanceTo(minion.pos) <= 500 and target.pos:DistanceTo(minion.pos) < 600 then
			local QDmg = getdmg("Q", minion, myHero, 2)
			if Ready(_Q) and minion.team == TEAM_ENEMY and IsValid(minion) and QDmg >= minion.health then
				Control.CastSpell(HK_Q, minion.pos)
			end
		end
	end	
end	

function Irelia:CastW(target)
    if target then
        if not charging and GotBuff(myHero, "ireliawdefense") == 0 then
            Control.KeyDown(HK_W)
            wClock = clock()
            settime = clock()
            charging = true
        end
		local pred = GetGamsteronPrediction(target, WData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
			if GotBuff(myHero, "ireliawdefense") == 1 and (target.pos:DistanceTo() > 600) then
				Control.CastSpell(HK_W, pred.CastPosition)
				charging = false
			elseif GotBuff(myHero, "ireliawdefense") == 1 and clock() - wClock >= 0.5 and target.pos:DistanceTo() < 825 then
				Control.CastSpell(HK_W, pred.CastPosition)
				charging = false
			end		
        end
        
        
    end
    if clock() - wClock >= 1.5 then
    Control.KeyUp(HK_W)
    charging = false
    end 
end

function Irelia:Flee()
    local target = GetTarget(1100)     	
	if target == nil then return end
	if self.Menu.Flee.Q:Value() then
		if target.pos:DistanceTo(myHero.pos) < 1000 then
			if Ready(_Q) then
				for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
					if minion.team == TEAM_ENEMY and IsValid(minion) then
						local QDmg = getdmg("Q", minion, myHero, 2)
						if minion.pos:DistanceTo(myHero.pos) <= 600 and target.pos:DistanceTo(myHero.pos) < minion.pos:DistanceTo(target.pos) and QDmg > minion.health then
							Control.CastSpell(HK_Q, minion.pos)
						end
					end	
                end
            end
            
		end
	end
end

function Irelia:LineCircleIntersection(p1, p2, circle, radius)
    local dx, dy = p2.x - p1.x, p2.z - p1.z
    local a = dx * dx + dy * dy
    local b = 2 * (dx * (p1.x - circle.x) + dy * (p1.z - circle.z))
    local c = (p1.x - circle.x) * (p1.x - circle.x) + (p1.z - circle.z) * (p1.z - circle.z) - (radius * radius)
    local delta = b * b - 4 * a * c
    if delta >= 0 then
        local t1, t2 = (-b + math.sqrt(delta)) / (2 * a), (-b - math.sqrt(delta)) / (2 * a)
        return Vector(p1.x + t1 * dx, p1.y, p1.z + t1 * dy), Vector(p1.x + t2 * dx, p1.y, p1.z + t2 * dy)
    end
    return nil, nil
end

function Irelia:GetBestECastPositions(units)
    local units = GetEnemyHeroes()
    local startPos, endPos, count = nil, nil, 0
    local candidates, unitPositions = {}, {}
    for i, unit in ipairs(units) do
        local cp = GetPred(unit,2000,0.75 + ping)
        if cp then candidates[i], unitPositions[i] = cp, cp end
    end
    local maxCount = #units
    for i = 1, maxCount do
        for j = 1, maxCount do
            if candidates[j] ~= candidates[i] then
                table.insert(candidates, Vector(candidates[j] + candidates[i]) / 2)
            end
        end
    end
    for i, unit2 in pairs(units) do
        local cp = GetPred(unit2,2000,0.75 + ping)
        if cp then
            if myHero.pos:DistanceTo(cp.pos) < 775 then
                for i, pos2 in ipairs(candidates) do
                    if pos2:DistanceTo(cp.pos) < 775 then 
                        
                        local ePos = Vector(cp):Extended(pos2, 775)
                        local number = 0
                        for i = 1, #unitPositions do
                            local unitPos = unitPositions[i]   
                            local pointLine, pointSegment, onSegment = VectorPointProjectionOnLineSegment(cp, ePos, unitPos)
                            if pointSegment and GetDistance(pointSegment, unitPos) < 1550 then number = number + 1 end 
                             
                        end
                        if number >= 2 then startPos, endPos, count = cp, ePos, number end

                    end
                end
            end
        end
    end
    return startPos, endPos, count
end

function Irelia:CastE2()
local target = GetTarget(1100)
	if IsValid(target) and self.Menu.AutoE.UseE:Value() and Ready(_E) then
		local startPos, endPos, count = self:GetBestECastPositions(target)
		if startPos and endPos then 
			local cast1, cast2 = self:LineCircleIntersection(startPos, endPos, myHero.pos, 725)
			local targetCount = GetEnemyCount(725, myHero)
				if targetCount >= 2 and cast1 and cast2 then
				if myHero:GetSpellData(_E).name == "IreliaE" then
					Control.CastSpell(HK_E, cast1)
				elseif myHero:GetSpellData(_E).name == "IreliaE2" then
					DelayAction(function() Control.CastSpell(HK_E, cast2) end, 0.15)
				end
			end
		end
	end	
end	

function Irelia:CastE(target)

    if myHero:GetSpellData(_E).name == "IreliaE" then
		Control.CastSpell(HK_E, myHero.pos)
    
    end
	local pred = GetGamsteronPrediction(target, EData, myHero)
    if myHero:GetSpellData(_E).name == "IreliaE2" and pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
        pos2 = pred.CastPosition + (myHero.pos - pred.CastPosition): Normalized() * -150
        Control.CastSpell(HK_E, pos2)
       
	end
end


function Irelia:CastR(target)
	local pred = GetGamsteronPrediction(target, RData, myHero)
	if pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
		Control.CastSpell(HK_R, pred.CastPosition)
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

local Support = {"Soraka","Yuumi","Rakan","Zyra","Morgana","Sona"}
if table.contains(Support, myHero.charName) then
	_G[myHero.charName]()
end	

function OnLoad()
	AutoUpdate()

end

    local Version = 0.1
    
    local Files = {
        Lua = {
            Path = COMMON_PATH,
            Name = "PussySUPP.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyAIOTest.lua"
        },
        Version = {
            Path = COMMON_PATH,
            Name = "PussySUPP.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyAIOTest.version"
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
            print("New PussySupport Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end	
	end




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Soraka"





function Soraka:__init()

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


local QData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 235, Range = 800, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}
}

local EData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 250, Range = 925, Speed = 1750, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}
}

function Soraka:LoadMenu()
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Soraka", name = "PussySoraka"})
	
	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", leftIcon = Icons["AutoE"]})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]Immobile Target", value = true})

	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", leftIcon = Icons["AutoW"]})
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Auto Heal Ally", value = true})
	self.Menu.AutoW:MenuElement({id = "UseWE", name = "Minimum Health Ally", value = 30, min = 0, max = 100, identifier = "%"})
	self.Menu.AutoW:MenuElement({id = "Mana", name = "Min Mana", value = 20, min = 0, max = 100, identifier = "%"})	

	--AutoR
	self.Menu:MenuElement({type = MENU, id = "AutoR", leftIcon = Icons["AutoR"]})
	self.Menu.AutoR:MenuElement({id = "UseR", name = "Auto Heal Allys below 40%", value = true})
	self.Menu.AutoR:MenuElement({id = "UseRE", name = "Minimum Allys below 40%", value = 2, min = 1, max = 5})
	self.Menu.AutoR:MenuElement({type = MENU, id = "AutoR2", name = "AutoSafe priority Ally"})
	self.Menu.AutoR.AutoR2:MenuElement({id = "UseRE", name = "Minimum Health priority Ally", value = 40, min = 0, max = 100, identifier = "%"})	
	for i, Hero in pairs(GetAllyHeroes()) do
		self.Menu.AutoR.AutoR2:MenuElement({id = Hero.charName, name = Hero.charName, value = false})		
	end	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})			
		
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		  	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})         	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})	


	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	


	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Soraka:Tick()
if MyHeroReady() then
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
	elseif Mode == "Flee" then
		
	end	
	self:KillSteal()
	self:AutoW()
	self:AutoR()
	self:AutoR2()
	self:ImmoE()	
	
end
end 

function Soraka:RCount()
	local count = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.isAlly and IsValid(hero) and hero.health/hero.maxHealth  * 100 < 40 then
			count = count + 1
		
		end
	end	
	return count
end

function Soraka:ImmoE()
local target = GetTarget(1000)     	
if target == nil then return end		
	
	if IsValid(target,1000) and myHero.pos:DistanceTo(target.pos) <= 925 and Ready(_E) and self.Menu.AutoE.UseE:Value() then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if IsImmobileTarget(target) and pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then   
			Control.CastSpell(HK_E, pred.CastPosition) 
			
		end	
	end
end


function Soraka:AutoR()
for i, ally in pairs(GetAllyHeroes()) do     	
if ally == nil then return end	
	if self.Menu.AutoR.UseR:Value() and Ready(_R) then
		if self:RCount() >= self.Menu.AutoR.UseRE:Value() then
			Control.CastSpell(HK_R)
		end	
	end
end	
end

function Soraka:AutoR2()
for i, ally in pairs(GetAllyHeroes()) do     	
if ally == nil then return end	
	if IsValid(ally) and Ready(_R) then 
		if self.Menu.AutoR.AutoR2[ally.charName] and self.Menu.AutoR.AutoR2[ally.charName]:Value() and ally.health/ally.maxHealth <= self.Menu.AutoR.UseRE:Value()/100 then
			Control.CastSpell(HK_R)
		end	
	end	
end
end	


function Soraka:AutoW()
for i, ally in pairs(GetAllyHeroes()) do     	
if ally == nil then return end	
	if IsValid(ally, 700) and myHero.pos:DistanceTo(ally.pos) <= 550 and Ready(_W) and BaseCheck(myHero) == false then 
		if self.Menu.AutoW.UseW:Value() then
			if ally.health/ally.maxHealth <= self.Menu.AutoW.UseWE:Value()/100 and myHero.mana/myHero.maxMana >= self.Menu.AutoW.Mana:Value()/100 then
				Control.CastSpell(HK_W, ally)
			end	
		end	
	end
end
end

			
function Soraka:Draw()
  if myHero.dead then return end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 925, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 550, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
end
       
function Soraka:KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end	
	if IsValid(target,1000) then	
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 925 and self.Menu.ks.UseE:Value() and Ready(_E) then
			local EDmg = getdmg("E", target, myHero)
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if EDmg >= target.health and pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
	end
end	

function Soraka:Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target,1000) then		
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 925 and self.Menu.Combo.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
	end
end	

function Soraka:Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target,1000) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 925 and self.Menu.Harass.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
	end
end	

function Soraka:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_ENEMY and IsValid(minion, 1200) and myHero.pos:DistanceTo(minion.pos) <= 800 and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then					
			if Ready(_Q) and self.Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	  
		end
	end
end

function Soraka:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if minion.team == TEAM_JUNGLE and IsValid(minion, 1200) and myHero.pos:DistanceTo(minion.pos) <= 800 and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end 
		end
	end
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






class "Sona"



local QData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 235, Range = 825, Speed = 1000, Collision = false
}


function Sona:__init()
	
	Q = {ready = false, range = 825, radius = 235, speed = 1000, delay = 0.25, type = "circular"}
	W = {ready = false, range = 1000,}
	E = {ready = false, range = 925, radius = 310, speed = math.huge, delay = 1.75, type = "circular"}
	R = {ready = false, range = 900,}
	self.SpellCast = {state = 1, mouse = mousePos}
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly  then
			self.Allies[hero.handle] = hero
		else
			self.Enemies[hero.handle] = hero
		end	
	end	
	self.lastTick = 0
	self.SelectedTarget = nil
	self:LoadMenu()
	
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end
	
	Callback.Add("Tick",function() self:Tick() end)
	Callback.Add("Draw",function() self:Draw() end)

end


function Sona:LoadMenu()
	self.Menu = MenuElement( {id = "Sona", name = "PussySona", type = MENU})
	self.Menu:MenuElement({id = "Key", leftIcon = Icons["KeySet"], type = MENU})
	self.Menu.Key:MenuElement({id = "Combo",name = "Combo", key = 32})
	self.Menu.Key:MenuElement({id = "Harass",name = "Harass", key = string.byte("C")})

	self.Menu:MenuElement({type = MENU, id = "Qset", leftIcon = Icons["QSet"]})
	self.Menu.Qset:MenuElement({id = "Combo",name = "Use in Combo", value = true })
	self.Menu.Qset:MenuElement({id = "Harass", name = "Use in Harass", value = true})
	
	self.Menu:MenuElement({id = "Wset", leftIcon = Icons["WSet"], type = MENU})
	self.Menu.Wset:MenuElement({id = "AutoW", name = "Enable Auto Health",value = true})
	self.Menu.Wset:MenuElement({id = "MyHp", name = "Heal my HP Percent",value = 30, min = 1, max = 100,step = 1})
	self.Menu.Wset:MenuElement({id = "AllyHp", name = "Heal AllyHP Percent",value = 50, min = 1, max = 100,step = 1})
	
	self.Menu:MenuElement({id = "Rset", leftIcon = Icons["RSet"],type = MENU})
	self.Menu.Rset:MenuElement({id = "AutoR", name = "Enable Auto R",value = true})
	self.Menu.Rset:MenuElement({id = "RHit", name = "Min enemies hit",value = 3, min = 1, max = 5,step = 1})
	self.Menu.Rset:MenuElement({id = "AllyHp", name = "Use Ult if AllyHP Percent below ",value = 30, min = 1, max = 100,step = 1})	
	
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	self.Menu:MenuElement({type = MENU, id = "Draw", leftIcon = Icons["Drawings"]})
	self.Menu.Draw:MenuElement({id = "Q", name = "Draw Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "W", name = "Draw W Range", value = true})
	self.Menu.Draw:MenuElement({id = "E", name = "Draw E Range", value = true})

end


function Sona:Tick()
	if MyHeroReady() then
	local Mode = GetMode()
		if Mode == "Combo" then
			if self.Menu.Key.Combo:Value() then
				self:Combo()
			end
		elseif Mode == "Harass" then
			if self.Menu.Key.Harass:Value() then
				self:Harass()
			end
		elseif Mode == "Clear" then

		elseif Mode == "Flee" then
		
		end
		if Ready(_R) then
			self:AutoR()
			self:AutoR2()
		end
		if Ready(_W) then
			self:AutoW()
			self:AutoW2()
		end
	end
end

local function isValidTarget(obj,range)
	range = range or math.huge
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= range
end


function Sona:Combo()
	local target = GetTarget(1000)     	
	if target == nil then return end
	if IsValid(target, 1000) and myHero.pos:DistanceTo(target.pos) <= 825 then	

		if Ready(_Q) and self.Menu.Qset.Combo:Value() then
			self:CastQ(target)
		end
	end
end

function Sona:Harass()
	local target = GetTarget(1000)     	
	if target == nil then return end
	if IsValid(target, 1000) then	
	
		if Ready(_Q) and self.Menu.Qset.Harass:Value() then
			self:CastQ(target)
		end
	end
end

function Sona:AutoW()
	if (not Ready(_W) or not self.Menu.Wset.AutoW:Value())then return end
	for i, ally in pairs(GetAllyHeroes()) do
		if isValidTarget(ally,W.range) and myHero.pos:DistanceTo(ally.pos) <= W.range then
			if ally.health/ally.maxHealth  < self.Menu.Wset.AllyHp:Value()/100 then
				Control.CastSpell(HK_W,ally.pos)
				return
			
			end			
		end
	end
end

function Sona:AutoW2()
	if (not Ready(_W) or not self.Menu.Wset.AutoW:Value())then return end

	if (myHero.health/myHero.maxHealth  < self.Menu.Wset.MyHp:Value()/100) then
		Control.CastSpell(HK_W,myHero.pos)
		return
	end
end

function Sona:AutoR()
if (not Ready(_R) or not self.Menu.Rset.AutoR:Value())then return end
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target, 1000) and myHero.pos:DistanceTo(target.pos) <= 900 then		
		for i, ally in pairs(GetAllyHeroes()) do
			if (ally.health/ally.maxHealth  < self.Menu.Rset.AllyHp:Value()/100) and (CountEnemiesNear(ally, 500) > 0) then
				Control.CastSpell(HK_R,target.pos)
				return
			end	
		end
	end
end	

function Sona:AutoR2()
	if (not Ready(_R) or not self.Menu.Rset.AutoR:Value())then return end
	local target = GetTarget(1000)     	
	if target == nil then return end
	if IsValid(target, 1000) and myHero.pos:DistanceTo(target.pos) <= 900 then	
		if CountEnemiesNear(target, 500) >= self.Menu.Rset.RHit:Value() then
			Control.CastSpell(HK_R,target.pos)
			return
		end	
	end
end

function Sona:CastQ(unit)
	if not unit then return end
	local pred = GetGamsteronPrediction(unit, QData, myHero)
	if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
		CastSpell(HK_Q,pred.CastPosition)
	end
end

function Sona:Draw()
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	if myHero.dead then return end

	if self.Menu.Draw.Q:Value() then
		local qcolor = Ready(_Q) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),Q.range,1,qcolor)
	end
	if self.Menu.Draw.W:Value() then
		local wcolor = Ready(_W) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.range,1,wcolor)
	end
	if self.Menu.Draw.E:Value() then
		local ecolor = Ready(_E) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.range,1,ecolor)
	end
	--R
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Yuumi"




    




local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.5, Radius = 65, Range = 1150, Speed = 100, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
}


function Yuumi:__init()
	self.DetectedMissiles = {}; self.DetectedSpells = {}; self.Target = nil; self.Timer = 0
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


function Yuumi:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Yuumi", name = "PussyYuumi"})

	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", name = "Auto[W]"})
	self.Menu.AutoW:MenuElement({id = "UseW", name = "[W]Safe self[Auto search Tankist Ally]", value = true})
	self.Menu.AutoW:MenuElement({id = "myHP", name = "MinHP self for search Ally", value = 30, min = 0, max = 100, identifier = "%"})
	self.Menu.AutoW:MenuElement({id = "SwitchW", name = "[W]Auto Switch Ally", value = true})
	self.Menu.AutoW:MenuElement({id = "AllyHP", name = "MinHP BoundedAlly to switch", value = 10, min = 0, max = 100, identifier = "%"})



	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", name = "Auto[E]"})
	self.Menu.AutoE:MenuElement({id = "UseEself", name = "[E]Auto Heal self", value = true})
	self.Menu.AutoE:MenuElement({id = "myHP", name = "MinHP Self to Heal", value = 30, min = 0, max = 100, identifier = "%"})
	self.Menu.AutoE:MenuElement({id = "UseEally", name = "[W]+[E]Auto Heal Ally", value = true})
	self.Menu.AutoE:MenuElement({id = "AllyHP", name = "MinHP Ally to Heal", value = 70, min = 0, max = 100, identifier = "%"})	
	
	--AutoR on Immobile
	self.Menu:MenuElement({type = MENU, id = "AutoR", name = "AutoR on Immobile"})
	self.Menu.AutoR:MenuElement({id = "UseR", name = "[R]", value = true})
	self.Menu.AutoR:MenuElement({id = "UseRE", name = "Use[R]min Immobile Targets", value = 2, min = 1, max = 5})	
	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]if not Bounded Ally", value = true})	
	self.Menu.Combo:MenuElement({id = "UseQAlly", name = "[Q]if Bounded Ally[in work]", value = false})	
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	self.Menu.Combo:MenuElement({id = "UseRE", name = "Use [R] min Targets", value = 3, min = 1, max = 5})	
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]if not Bounded Ally", value = true})
	self.Menu.Harass:MenuElement({id = "UseQAlly", name = "[Q]if Bounded Ally[in work]", value = false})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear"})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]if not Bounded Ally", value = true})		  	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", name = "JClear"})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]if not Bounded Ally", value = true})         	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", name = "ks"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]if not Bounded Ally", value = true})	
	self.Menu.ks:MenuElement({id = "UseQAlly", name = "[Q]if Bounded Ally[in work]", value = true})	
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]if not Bounded Ally", value = true})	
	self.Menu.ks:MenuElement({id = "UseRAlly", name = "[R]if Bounded Ally", value = true})
	self.Menu.ks:MenuElement({id = "UseWR", name = "[W]+[R]if Killable Enemy in Ally range", value = true})	

	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	
	
end

function Yuumi:Tick()
if MyHeroReady() then
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
	elseif Mode == "Flee" then
		
	end	
	self:KillSteal()
	self:AutoE()
	self:AutoW()
	self:AutoR()
	

end
end 



function Yuumi:GetTankAlly(pos, range)
local Allys = GetAllyHeroes()
local bestAlly, highest = nil, 0
local pos = pos.pos
local Range = range * range

for i = 1, #Allys do
    local ally = Allys[i]
    local amount = ally.armor + ally.magicResist + ally.health
	if GetDistanceSqr(pos, ally.pos) < Range then
		if amount > highest then
			highest = amount
			bestAlly = ally
		end	
    end
end

return bestAlly
end

function Yuumi:AutoR()
local target = GetTarget(1200)     	
if target == nil then return end	
		
	if IsValid(target,1200) and myHero.pos:DistanceTo(target.pos) <= 1100 and GetImmobileCount(300, target) >= self.Menu.AutoR.UseRE:Value() then	
		if self.Menu.AutoR.UseR:Value() and Ready(_R) then 
			if GotBuff(Ally, "YuumiWAlly") == 0 then   
				Control.CastSpell(HK_R, target.pos)
			end
			if GotBuff(Ally, "YuumiWAlly") > 0 then   
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end
	

function Yuumi:AutoE()
	for i, Ally in pairs(GetAllyHeroes()) do	
		if self.Menu.AutoE.UseEself:Value() and Ready(_E) and GotBuff(Ally, "YuumiWAlly") == 0 then
			if myHero.health/myHero.maxHealth <= self.Menu.AutoE.myHP:Value() / 100 then
				Control.CastSpell(HK_E)
			end
		end
		if IsValid(Ally,1000) and myHero.pos:DistanceTo(Ally.pos) <= 700 then	
			if self.Menu.AutoE.UseEally:Value() and Ready(_E) then
				if Ally.health/Ally.maxHealth <= self.Menu.AutoE.AllyHP:Value() / 100 then
					if Ready(_W) and GotBuff(Ally, "YuumiWAlly") == 0 then   
						Control.CastSpell(HK_W, Ally)	
					end
				end
				if GotBuff(Ally, "YuumiWAlly") > 0 and Ally.health/Ally.maxHealth <= self.Menu.AutoE.AllyHP:Value() / 100 then 	
					Control.CastSpell(HK_E)
				end
			end
		end
	end
end



function Yuumi:AutoW()
	for i, Ally in pairs(GetAllyHeroes()) do
		
		if IsValid(Ally,1000) then	
			local BoundAlly = GotBuff(Ally, "YuumiWAlly")	
			local bestAlly = self:GetTankAlly(myHero, 700)
			if self.Menu.AutoW.UseW:Value() and Ready(_W) and GotBuff(Ally, "YuumiWAlly") == 0 then
				if myHero.health/myHero.maxHealth <= self.Menu.AutoW.myHP:Value() / 100 then
					if bestAlly then 
						Control.CastSpell(HK_W, bestAlly)
					end
				end
			end	
			if self.Menu.AutoW.SwitchW:Value() and Ready(_W) and GotBuff(Ally, "YuumiWAlly") > 0 then  
				if BoundAlly and Ally.health/Ally.maxHealth <= self.Menu.AutoW.AllyHP:Value() / 100 then
					if bestAlly	then 
						Control.CastSpell(HK_W, bestAlly)
					end
				end
			end			
		end	
	end
end	

			
function Yuumi:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 1100, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 1150, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 700, 1, Draw.Color(225, 225, 125, 10))
	end
end
       
function Yuumi:KillSteal()	
	local target = GetTarget(1300)     	
	if target == nil then return end
	for i, Ally in pairs(GetAllyHeroes()) do
	if IsValid(target,1300) then	
		local hp = target.health	
		if myHero.pos:DistanceTo(target.pos) <= 1150 and self.Menu.ks.UseQ:Value() and Ready(_Q) and GotBuff(Ally, "YuumiWAlly") == 0 then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= hp and pred.Hitchance >= _G.HITCHANCE_NORMAL then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 1100 and self.Menu.ks.UseR:Value() and Ready(_R) and GotBuff(Ally, "YuumiWAlly") == 0 then
			local RDmg = getdmg("R", target, myHero)
			if RDmg >= hp then			
				Control.CastSpell(HK_R, target.pos)
	
			end
		end
		if IsValid(Ally,1000) and myHero.pos:DistanceTo(target.pos) <= 1100 then
		if self.Menu.ks.UseRAlly:Value() and Ready(_R) and GotBuff(Ally, "YuumiWAlly") > 0 then 
			local RDmg = getdmg("R", target, myHero)
			if RDmg >= hp then			
				Control.CastSpell(HK_R, target.pos)
	
			end
		end	
		if self.Menu.ks.UseWR:Value() and getdmg("R", target, myHero) >= hp then 
			if myHero.pos:DistanceTo(Ally.pos) <= 700 and myHero.pos:DistanceTo(Ally.pos) <= myHero.pos:DistanceTo(target.pos) then			
				if Ally.pos:DistanceTo(target.pos) <= 1100 and Ready(_W) and Ready(_R) then
					Control.CastSpell(HK_W, Ally)
				end
			end
			if myHero.pos:DistanceTo(target.pos) <= 1100 and Ready(_R) and GotBuff(Ally, "YuumiWAlly") > 0 then 
				Control.CastSpell(HK_R, target.pos)
			end
		end
		end
	end
	end
end	

function Yuumi:Combo()
local target = GetTarget(1200)
if target == nil then return end
for i, Ally in pairs(GetAllyHeroes()) do	
	if IsValid(target,1200) then		
		
		if myHero.pos:DistanceTo(target.pos) <= 1150 and self.Menu.Combo.UseQ:Value() and Ready(_Q) and GotBuff(Ally, "YuumiWAlly") == 0 then 
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= _G.HITCHANCE_NORMAL then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 1100 and self.Menu.Combo.UseR:Value() and Ready(_R) then 
			if GetEnemyCount(300, target) >= self.Menu.Combo.UseRE:Value() then
				if GotBuff(Ally, "YuumiWAlly") == 0 then   
					Control.CastSpell(HK_R, target.pos)
				end
				if GotBuff(Ally, "YuumiWAlly") > 0 then   
					Control.CastSpell(HK_R, target.pos)
				end
			end
		end
	end
end
end	

function Yuumi:Harass()
local target = GetTarget(1200)
if target == nil then return end
for i, Ally in pairs(GetAllyHeroes()) do	
	if IsValid(target,1200) and myHero.pos:DistanceTo(target.pos) <= 1150 and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and GotBuff(Ally, "YuumiWAlly") == 0 then 
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= _G.HITCHANCE_NORMAL then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end
end	

function Yuumi:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion, 1200) and myHero.pos:DistanceTo(minion.pos) <= 1150 and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then					
			
			if Ready(_Q) and self.Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	  
		end
	end
end

function Yuumi:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if minion.team == TEAM_JUNGLE and IsValid(minion, 1200) and myHero.pos:DistanceTo(minion.pos) <= 1150 and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if Ready(_Q) and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end 
		end
	end
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Zyra"





local EData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1100, Speed = 1150, 
Collision = true, MaxCollision = 0, CollisionTypes = { _G.COLLISION_YASUOWALL }
}

local QData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.85, Radius = 140, Range = 800, Speed = math.huge, Collision = false
}

local RData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 2.0, Radius = 500, Range = 700, Speed = math.huge, Collision = false
}

function Zyra:__init()

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

function Zyra:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Zyra", name = "PussyZyra"})

	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", leftIcon = Icons["AutoE"]})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]on Immobile", value = true})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})		
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Rampant Growth", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})			
	
	--UltSettings
	self.Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	self.Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R] Stranglethorns", value = true})
	self.Menu.Combo.Ult:MenuElement({id = "UseRE", name = "Use [R] min Targets", value = 2, min = 1, max = 6})
	self.Menu.Combo.Ult:MenuElement({id = "killR", name = "Use[R] Killable Target", value = false})
	self.Menu.Combo.Ult:MenuElement({id = "Immo", name = "Use[R]Immobile Targets > 2", value = true})	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W] Rampant Growth", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})  	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})	
	self.Menu.ks:MenuElement({id = "UseEQ", name = "[E]+[Q]", value = true})

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Zyra:Tick()
if MyHeroReady() then
local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
	elseif Mode == "Flee" then
		
	end	
	self:KillSteal()
	self:AutoE()
	self:AutoR()
	self:ImmoR()	
	self:UseW()
end
end 

function Zyra:UseW()
local target = GetTarget(1200)     	
if target == nil then return end		
	if IsValid(target,1200) and myHero.pos:DistanceTo(target.pos) <= 850 and Ready(_W) then
		if IsImmobileTarget(target) then   
			DelayAction(function() 
			Control.CastSpell(HK_W, target.pos) 
			Control.CastSpell(HK_W, target.pos)
		
			end, 0.05)
		end	
	end
end

function Zyra:AutoE()
local target = GetTarget(1200)     	
if target == nil then return end	
	
	if IsValid(target,1200) and myHero.pos:DistanceTo(target.pos) <= 1000 and self.Menu.AutoE.UseE:Value() and Ready(_E) then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if IsImmobileTarget(target) and pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
			
			Control.CastSpell(HK_E, pred.CastPosition)
		end	
	end
end

function Zyra:AutoR()
local target = GetTarget(800)     	
if target == nil then return end
	
	if IsValid(target,800) and myHero.pos:DistanceTo(target.pos) <= 700 and self.Menu.Combo.Ult.killR:Value() and Ready(_R) then
		local hp = target.health
		local RDmg = getdmg("R", target, myHero)
		local QDmg = getdmg("Q", target, myHero)
		local EDmg = getdmg("E", target, myHero)
		local damage = RDmg + QDmg + EDmg + 300
		local pred = GetGamsteronPrediction(target, RData, myHero)
		if damage >= hp and pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end	
	end
end	

function Zyra:ImmoR()
local target = GetTarget(800)     	
if target == nil then return end
	
	if IsValid(target,800) and myHero.pos:DistanceTo(target.pos) <= 700 and self.Menu.Combo.Ult.Immo:Value() and Ready(_R) then
		local count = GetImmobileCount(500, target)
		local pred = GetGamsteronPrediction(target, RData, myHero)
		if count >= 2 and pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
			Control.CastSpell(HK_R, pred.CastPosition)
		end	
	end
end

			
function Zyra:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 700, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 1100, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 850, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
end
       
function Zyra:KillSteal()	
	local target = GetTarget(1200)     	
	if target == nil then return end
	
	
	if IsValid(target,1200) then	
		local hp = target.health
		if myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= hp and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 1000 and self.Menu.ks.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			local EDmg = getdmg("E", target, myHero)
			if EDmg >= hp and pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then			
				
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.ks.UseEQ:Value() and Ready(_E) and Ready(_Q) then
			local Epred = GetGamsteronPrediction(target, EData, myHero)
			local Qpred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			local EDmg = getdmg("E", target, myHero)
			local EQDmg = QDmg + EDmg
			if EQDmg >= hp then
				
				if Epred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
					Control.CastSpell(HK_E, Epred.CastPosition)
				end	
				if Qpred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then	
					Control.CastSpell(HK_Q, Qpred.CastPosition)
				end
			end
		end
	end
end	

function Zyra:Combo()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target,1200) then

		if myHero.pos:DistanceTo(target.pos) <= 850 and self.Menu.Combo.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target.pos)
			DelayAction(function() 
			Control.CastSpell(HK_W, target.pos) 
			end, 0.05)
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 1000 and self.Menu.Combo.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then			
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 700 and Ready(_R) and self.Menu.Combo.Ult.UseR:Value() then
			local pred = GetGamsteronPrediction(target, RData, myHero)
			local count = GetEnemyCount(500, target)
			if count >= self.Menu.Combo.Ult.UseRE:Value() and pred.Hitchance >= self.Menu.Pred.PredR:Value() + 1 then
				Control.CastSpell(HK_R, pred.CastPosition)
			end
		end
	end
end	

function Zyra:Harass()
local target = GetTarget(1200)
if target == nil then return end
	if IsValid(target,1200) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 1000 and self.Menu.Harass.UseE:Value() and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then			
				
				Control.CastSpell(HK_E, pred.CastPosition)
	
			end
		end
	end
end	

function Zyra:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)

		if minion.team == TEAM_ENEMY and IsValid(minion, 1200) and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then					
			
			if myHero.pos:DistanceTo(minion.pos) <= 800 and Ready(_Q) and self.Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 1100 and Ready(_E) and self.Menu.Clear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end

function Zyra:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	

		if minion.team == TEAM_JUNGLE and IsValid(minion, 1200) and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			if myHero.pos:DistanceTo(minion.pos) <= 800 and Ready(_Q) and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end

			if myHero.pos:DistanceTo(minion.pos) <= 1100 and Ready(_E) and self.Menu.JClear.UseE:Value() then
				Control.CastSpell(HK_E, minion.pos)
			end  
		end
	end
end



-----------------------------------------------------------------------------------------------------------------------------------------------------------

class "Rakan"




local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 900, Speed = 1500, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
}

local WData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 250, Range = 600, Speed = 2050, Collision = false
}

function Rakan:__init()

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

function Rakan:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Rakan", name = "PussyRakan"})

	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", leftIcon = Icons["AutoE"]})
	self.Menu.AutoE:MenuElement({id = "ally", name = "AutoE Immobile Ally",value = true})
	self.Menu.AutoE:MenuElement({id = "E", name = "Auto E Toggle Key", key = 84, toggle = true})
	self.Menu.AutoE:MenuElement({id = "HP", name = "Min AllyHP", value = 30, min = 0, max = 100, identifier = "%"})
	self.Menu.AutoE:MenuElement({id = "Targets", name = "Ally Settings", type = MENU})
	for i, Hero in pairs(GetAllyHeroes()) do
		self.Menu.AutoE.Targets:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
		
	end	


	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})			
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R]", value = true})
	self.Menu.Combo:MenuElement({id = "UseRE", name = "Use [R] min Targets", value = 2, min = 1, max = 5})	
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Clear:MenuElement({id = "UseWM", name = "Use [W] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear Menu
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})	
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W]", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})	
    
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseW", name = "[W]", value = true})			
	self.Menu.ks:MenuElement({id = "UseR", name = "[R]", value = true})	
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})	

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q]Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R]Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawEX", name = "Draw Xayah[E]Range", value = true})	
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W]Range", value = true})

end

function Rakan:Tick()
	if MyHeroReady() then
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()

		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:Clear()
			self:JClear()
		elseif Mode == "Flee" then
		
		end	

	self:KillSteal()
	self:AutoE()
	self:AutoCCE()

	
	end
end 

function Rakan:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 150, 1, Draw.Color(255, 225, 255, 10)) 
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 900, 1, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawing.DrawE:Value()) and Ready(_E) then
    Draw.Circle(myHero, 700, 1, Draw.Color(225, 225, 125, 10))
	end
	if(self.Menu.Drawing.DrawW:Value()) and Ready(_W) then
    Draw.Circle(myHero, 600, 1, Draw.Color(225, 225, 125, 10))
	end
	if(self.Menu.Drawing.DrawEX:Value()) and Ready(_E) then
		for i = 1, Game.HeroCount() do
		local ally = Game.Hero(i)
			if ally.isAlly and ally.charName == "Xayah" then
				Draw.Circle(myHero, 1000, 1, Draw.Color(225, 225, 125, 10))
			end
		end
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	if self.Menu.AutoE.E:Value() then 
		Draw.Text("Auto E ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
	else
		Draw.Text("Auto E OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
	end
			
end	

function Rakan:AutoCCE()
	for i = 1, Game.HeroCount() do
	local ally = Game.Hero(i)
		if ally.isAlly and ally ~= myHero then
			if IsValid(ally, 800) and myHero.pos:DistanceTo(ally.pos) <= 700 then 
				if self.Menu.AutoE.ally:Value() and Ready(_E) and IsImmobileTarget(ally) then
					Control.CastSpell(HK_E, ally.pos)
				end
			end
		end
	end
end


function Rakan:AutoE()
	for i = 1, Game.HeroCount() do
	local ally = Game.Hero(i)
		if ally.isAlly and ally ~= myHero then
			if IsValid(ally, 1100) and myHero.pos:DistanceTo(ally.pos) <= 1000 and GotBuff(ally, "RakanEShield") == 0 then 
				if self.Menu.AutoE.E:Value() and self.Menu.AutoE.Targets[ally.charName] and self.Menu.AutoE.Targets[ally.charName]:Value() and Ready(_E) and ally.health/ally.maxHealth < self.Menu.AutoE.HP:Value()/100 then
					if ally.charName == "Xayah" and myHero.pos:DistanceTo(ally.pos) <= 1000 then
						Control.CastSpell(HK_E, ally.pos)
					elseif ally.charName ~= "Xayah" and myHero.pos:DistanceTo(ally.pos) <= 700 then
						Control.CastSpell(HK_E, ally.pos)	
					end
				end
			end
		end
	end
end

function Rakan:KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end

	if IsValid(target,1000) then	
		
		if myHero.pos:DistanceTo(target.pos) <= 900 and self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end

		if myHero.pos:DistanceTo(target.pos) <= 600 and self.Menu.ks.UseW:Value() and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			local WDmg = getdmg("W", target, myHero)
			if WDmg >= target.health and pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
				Control.CastSpell(HK_W, pred.CastPosition)
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 150 and self.Menu.ks.UseR:Value() and Ready(_R) then
			local RDmg = getdmg("R", target, myHero)
			if RDmg >= target.health then
				Control.CastSpell(HK_R)
	
			end
		end
	end
end	

function Rakan:Combo()
local target = GetTarget(1200)
if target == nil then return end
	
	if IsValid(target,1200) then
		for i = 1, Game.HeroCount() do
		local ally = Game.Hero(i)
			if ally.isAlly and ally ~= myHero and target.pos:DistanceTo(ally.pos) <= 600 and self.Menu.Combo.UseE:Value() and Ready(_E) and GotBuff(ally, "RakanEShield") == 0 then
				if ally.charName == "Xayah" and myHero.pos:DistanceTo(ally.pos) <= 1000 then			
					Control.CastSpell(HK_E, ally)
				elseif ally.charName ~= "Xayah" and myHero.pos:DistanceTo(ally.pos) <= 700 then			
					Control.CastSpell(HK_E, ally)	
				end
			end
		
		
			if myHero.pos:DistanceTo(target.pos) <= 600 and self.Menu.Combo.UseW:Value() and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then 
					Control.CastSpell(HK_W, pred.CastPosition) 
				end
			end			
		
			if Ready(_R) and self.Menu.Combo.UseR:Value() then
				local count = GetEnemyCount(400, myHero)
				if  count >= self.Menu.Combo.UseRE:Value() then
					Control.CastSpell(HK_R)
				end
			end	
				
		
			if myHero.pos:DistanceTo(target.pos) <= 900 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
			end
		
			if ally.isAlly and ally ~= myHero and target.pos:DistanceTo(ally.pos) <= 600 and self.Menu.Combo.UseE:Value() and Ready(_E) and GotBuff(ally, "RakanEShield") then
				if ally.charName == "Xayah" and myHero.pos:DistanceTo(ally.pos) <= 1000 then			
					Control.CastSpell(HK_E, ally)
				elseif ally.charName ~= "Xayah" and myHero.pos:DistanceTo(ally.pos) <= 700 then			
					Control.CastSpell(HK_E, ally)	
				end
			end
		end
	end
end

function Rakan:Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target,1000) and myHero.pos:DistanceTo(target.pos) <= 900 and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end	

function Rakan:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if IsValid(minion, 1000) and minion.team == TEAM_ENEMY and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then					
			if myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_Q) and self.Menu.Clear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	 
		
			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.Clear.UseW:Value() and Ready(_W) then
				local count = GetMinionCount(250, minion)
				if count >= self.Menu.Clear.UseWM:Value() then	
					Control.CastSpell(HK_W, minion.pos)
				end
			end
		end			
	end
end

function Rakan:JClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if IsValid(minion, 1000) and minion.team == TEAM_JUNGLE and myHero.pos:DistanceTo(minion.pos) <= 900 and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then					
			if myHero.pos:DistanceTo(minion.pos) <= 900 and Ready(_Q) and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion.pos)
			end	
			if myHero.pos:DistanceTo(minion.pos) <= 600 and self.Menu.JClear.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, minion.pos) 
			
			end				
		end
	end
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "Morgana"

function Morgana:__init()
	self.DetectedMissiles = {}; self.DetectedSpells = {}; self.Target = nil; self.Timer = 0
	
	
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

 
function Morgana:VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function Morgana:CalculateCollisionTime(startPos, endPos, unitPos, startTime, speed, delay, origin)
	local delay = origin == "spell" and delay or 0
	local pos = startPos:Extended(endPos, speed * (Game.Timer() - delay - startTime))
	return GetDistance(unitPos, pos) / speed
end

function Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, collision, type)
	local range = range or 3000; local endPos = startPos:Extended(placementPos, range)
	if type == "circular" or type == "rectangular" then
		if range > 0 then if GetDistance(unitPos, placementPos) < range then endPos = placementPos end
		else endPos = unitPos end
	elseif collision then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and minion.team == myHero.team and not minion.dead and GetDistance(minion.pos, startPos) < range then
				local col = self:VectorPointProjectionOnLineSegment(startPos, placementPos, minion.pos)
				if col and GetDistance(col, minion.pos) < (radius + minion.boundingRadius / 2) then
					range = GetDistance(startPos, col); endPos = startPos:Extended(placementPos, range); break
				end
			end
		end
	end
	return endPos, range

end

function Morgana:LoadSpells()
 
	Q = {range = 1175, radius = 70, delay = 0.25, speed = 1200, collision = true}    
	W = {range = 900, radius = 280, delay = 0.25, speed = math.huge, collision = false}   
	E = {range = 800,}    
	R = {range = 625,}  

end


local WData =
{
Type = _G.SPELLTYPE_CIRCLE, Collision = false, Delay = 0.25, Radius = 150, Range = 900, Speed = math.huge
}

local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1175, Speed = 1200, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
}



function Morgana:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Morgana", name = "PussyMorgana"})

	--AutoE
	self.Menu:MenuElement({id = "AutoE", leftIcon = Icons["AutoE"], type = MENU})
	self.Menu.AutoE:MenuElement({id = "self", name = "Use Self if CC ",value = true})
	self.Menu.AutoE:MenuElement({id = "ally", name = "Use Ally if CC ",value = true})	
	self.Menu.AutoE:MenuElement({id = "Targets", name = "Ally Settings", type = MENU})
	for i, Hero in pairs(GetAllyHeroes()) do
		self.Menu.AutoE.Targets:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
	end		
	
	self.Menu:MenuElement({type = MENU, id = "ESet", leftIcon = Icons["AutoECCSpells"]})	
	self.Menu.ESet:MenuElement({id = "UseE", name = "UseE Self", value = true})
	self.Menu.ESet:MenuElement({id = "UseEally", name = "UseE Ally", value = true})	
	self.Menu.ESet:MenuElement({id = "ST", name = "Track Spells", drop = {"Channeling", "Missiles", "Both"}, value = 1})	
	self.Menu.ESet:MenuElement({id = "BlockList", name = "Spell List", type = MENU})	
	
	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", leftIcon = Icons["AutoWImmo"]})	
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W]", value = true})
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})		
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]only if not Raedy[Q]", value = true})		
	
	--UltSettings
	self.Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	self.Menu.Combo.Ult:MenuElement({id = "UseR", name = "[R] Dark Binding", value = true})
	self.Menu.Combo.Ult:MenuElement({id = "UseRE", name = "Use [R] min Targets", value = 2, min = 1, max = 5})

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})	
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]only if not Raedy[Q]", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQL", name = "LastHit[Q] Dark Binding", value = true})		
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})  
	self.Menu.Clear:MenuElement({id = "UseWM", name = "Use [W] min Minions", value = 3, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})
	self.Menu.JClear:MenuElement({id = "UseWM", name = "Use [W] min Minions", value = 3, min = 1, max = 6})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Dark Binding", value = true})	
	self.Menu.ks:MenuElement({id = "UseW", name = "[W] Tormented Soil", value = true})	

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})
	
	self.Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()
		for i, spell in pairs(CCSpells) do
			if not CCSpells[i] then return end
			for j, k in pairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not self.Menu.ESet.BlockList[i] then
					if not self.Menu.ESet.BlockList[i] then self.Menu.ESet.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..self.Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end
		end
	end, 0.01)
      
end                     

function Morgana:Tick()

	if MyHeroReady() then
		local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		elseif Mode == "Flee" then
				
		end	

		self:KillSteal()
		self:AutoW()
		self:AutoE()
		self:Auto1()
		self:Auto2()
		
	end
end 


function Morgana:Auto2()
	if self.Menu.ESet.UseE:Value() and Ready(_E) then
		if self.Menu.ESet.ST:Value() ~= 1 then self:OnMissileCreate() end
		if self.Menu.ESet.ST:Value() ~= 2 then self:OnProcessSpell() end
		for i, spell in pairs(self.DetectedSpells) do self:UseE(i, spell) end
	end
end

function Morgana:Auto1()
	if self.Menu.ESet.UseEally:Value() and Ready(_E) then
		if self.Menu.ESet.ST:Value() ~= 1 then self:OnMissileCreate1() end
		if self.Menu.ESet.ST:Value() ~= 2 then self:OnProcessSpell1() end
		for i, spell in pairs(self.DetectedSpells) do self:UseEally(i, spell) end
	end	
end 

function Morgana:GetHeroByHandle(handle)
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.handle == handle then return unit end
	end  
end

function Morgana:UseE(i, s)


	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == math.huge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > Game.Timer() then
		local Col = Morgana:VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
		if s.type == "circular" and GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
			local t = 0.29; t = s.speed ~= math.huge and Morgana:CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay, s.origin)
			if t < 0.3 then Control.CastSpell(HK_E, myHero) end
		end
	else table.remove(self.DetectedSpells, i) end
end

function Morgana:OnMissileCreate()
	
	if Game.Timer() > self.Timer + 0.15 then
		for i, mis in pairs(self.DetectedMissiles) do if Game.Timer() > mis.timer + 2 then table.remove(self.DetectedMissiles, i) end end
		self.Timer = Game.Timer()
	end
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		if CCSpells[missile.missileData.name] then
			local unit = Morgana:GetHeroByHandle(missile.missileData.owner)
			if (not unit.visible and CCSpells[missile.missileData.name].origin ~= "spell") or CCExceptions[missile.missileData.name] then
				if GetDistance(unit.pos, myHero.pos) > 3000 or not self.Menu.ESet.BlockList["Dodge"..missile.missileData.name]:Value() then return end
				local Detected = CCSpells[missile.missileData.name]
				if Detected.origin ~= "spell" then
					for i, mis in pairs(self.DetectedMissiles) do if mis.name == missile.missileData.name then return end end
					table.insert(DetectedMissiles, {name = missile.missileData.name, timer = Game.Timer()})
					local startPos = Vector(missile.missileData.startPos); local placementPos = Vector(missile.missileData.placementPos); local unitPos = unit.pos
					local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
					local endPos, range2 = Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
					table.insert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "missile"})
				end
			end
		end
	end
end

function Morgana:OnProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and spell and CCSpells[spell.name] then
		if GetDistance(unit.pos, myHero.pos) > 3000 or not self.Menu.ESet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		if Detected.origin ~= "missile" then
			local type = Detected.type
			if type == "targeted" then
				if spell.target == myHero.handle then Control.CastSpell(HK_E, myHero) end
			else
				local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
				local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
				local endPos, range2 = Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
				table.insert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "spell"})
			end
		end
	end
end

function Morgana:UseEally(i, s)
for i, Hero in pairs(GetAllyHeroes()) do	
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == math.huge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > Game.Timer() then
		local Col = Morgana:VectorPointProjectionOnLineSegment(startPos, endPos, Hero.pos)
		if s.type == "circular" and GetDistanceSqr(Hero.pos, endPos) < (s.radius + Hero.boundingRadius) ^ 2 or GetDistanceSqr(Hero.pos, Col) < (s.radius + Hero.boundingRadius * 1.25) ^ 2 then
			local t = s.speed ~= math.huge and Morgana:CalculateCollisionTime(startPos, endPos, Hero.pos, s.startTime, s.speed, s.delay, s.origin) or 0.29
			if t < 0.3 and myHero.pos:DistanceTo(Hero.pos) <= 800 then Control.CastSpell(HK_E, Hero) end
		end
	else table.remove(self.DetectedSpells, i) end
end
end

function Morgana:OnProcessSpell1()
for i, Hero in pairs(GetAllyHeroes()) do
	
	local unit, spell = OnProcessSpell()
	if unit and spell and CCSpells[spell.name] then
		if GetDistance(unit.pos, Hero.pos) > 3000 or not self.Menu.ESet.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		if Detected.origin ~= "missile" then
			local type = Detected.type
			if type == "targeted" then
				if spell.target == Hero.handle and myHero.pos:DistanceTo(Hero.pos) <= 800 then Control.CastSpell(HK_E, Hero) end
			else
				local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
				local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
				local endPos, range2 = Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
				table.insert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "spell"})
			end
		end
	end
end
end


function Morgana:OnMissileCreate1()
for i, Hero in pairs(GetAllyHeroes()) do
	if Game.Timer() > self.Timer + 0.15 then
		for i, mis in pairs(self.DetectedMissiles) do if Game.Timer() > mis.timer + 2 then table.remove(self.DetectedMissiles, i) end end
		self.Timer = Game.Timer()
	end
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		if CCSpells[missile.missileData.name] then
			local unit = Morgana:GetHeroByHandle(missile.missileData.owner)
			if (not unit.visible and CCSpells[missile.missileData.name].origin ~= "spell") or CCExceptions[missile.missileData.name] then
				if GetDistance(unit.pos, Hero.pos) > 3000 or not self.Menu.ESet.BlockList["Dodge"..missile.missileData.name]:Value() then return end
				local Detected = CCSpells[missile.missileData.name]
				if Detected.origin ~= "spell" then
					for i, mis in pairs(self.DetectedMissiles) do if mis.name == missile.missileData.name then return end end
					table.insert(self.DetectedMissiles, {name = missile.missileData.name, timer = Game.Timer()})
					local startPos = Vector(missile.missileData.startPos); local placementPos = Vector(missile.missileData.placementPos); local unitPos = unit.pos
					local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
					local endPos, range2 = Morgana:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
					table.insert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "missile"})
				end
			end
		end
	end
end
end

function Morgana:AutoE()
		if IsImmobileTarget(myHero) and self.Menu.AutoE.self:Value() and Ready(_E) then
			Control.CastSpell(HK_E, myHero)
		end
		for i = 1, Game.HeroCount() do
		local ally = Game.Hero(i)
		if ally.isAlly and ally ~= myHero then
		if IsValid(ally) then 
			if myHero.pos:DistanceTo(ally.pos) <= 800 and IsImmobileTarget(ally) and self.Menu.AutoE.ally:Value() and self.Menu.AutoE.Targets[ally.charName] and self.Menu.AutoE.Targets[ally.charName]:Value() and Ready(_E) then
				Control.CastSpell(HK_E, ally.pos)
			end
		end
		end
	end
end
	
			
function Morgana:Draw()
local textPos = myHero.pos:To2D()	
if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
end  
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 625, 3, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 1175, 3, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 800, 3, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 900, 3, Draw.Color(225, 225, 125, 10))
	end
	local target = GetTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Drawing.Kill:Value() and not target.dead then
	local hp = target.health	
		if Ready(_Q) and getdmg("Q", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_W) and getdmg("W", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
	end
end

function Morgana:KillSteal()	
	local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
	local target = GetTarget(max_range)
	if target == nil then return end
	if IsValid(target,max_range) then
        
		if self.Menu.ks.UseQ ~= nil and self.Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= target.health and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
        end
        if self.Menu.ks.UseW ~= nil and self.Menu.ks.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
            local WDmg = getdmg("W", target, myHero)
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if WDmg >= target.health and pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then			
				Control.CastSpell(HK_W, pred.CastPosition)
			end	
        end
	end	
end

function Morgana:AutoW()
	local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
	local target = GetTarget(max_range)
	if target == nil then return end
	if IsValid(target,max_range) then
		if myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_W).range and IsImmobileTarget(target) and self.Menu.AutoW.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target.pos)
		
		elseif myHero.pos:DistanceTo(target.pos) > 900 and myHero.pos:DistanceTo(target.pos) < 1175 and IsImmobileTarget(target) and self.Menu.AutoW.UseW:Value() and Ready(_W) then
			local WPos = myHero.pos:Shortened(target.pos - 900)
			Control.SetCursorPos(WPos)
			Control.KeyDown(HK_W)
			Control.KeyUp(HK_W)
		end	
	end
end	


function Morgana:Combo()
	local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
	local target = GetTarget(max_range)
	if target == nil then return end
	if IsValid(target,max_range) then
        
		if self.Menu.Combo.UseQ ~= nil and self.Menu.Combo.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
        end
        if self.Menu.Combo.UseW ~= nil and self.Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_W).range and Ready(_W) and not Ready(_Q) then
            local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then			
				Control.CastSpell(HK_W, pred.CastPosition)
			end	
        end
        if self.Menu.Combo.UseE ~= nil and self.Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
			Control.CastSpell(HK_E, target.pos)
        end
        if self.Menu.Combo.Ult.UseR:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
            local count = GetEnemyCount(625, myHero)
			if count >= self.Menu.Combo.Ult.UseRE:Value() then
				Control.CastSpell(HK_R)
			end	
		end
	end
end

function Morgana:Harass()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
	local target = GetTarget(max_range)
	if target == nil then return end
	if IsValid(target,max_range) then
        local mana_ok = (self.Menu.Harass.Mana == nil or (self.Menu.Harass.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100))
        
		if self.Menu.Harass.UseQ ~= nil and self.Menu.Harass.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
        end
        if self.Menu.Harass.UseW ~= nil and self.Menu.Harass.UseW:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_W).range and Ready(_W) and not Ready(_Q) then
            local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then			
				Control.CastSpell(HK_W, pred.CastPosition)
	
			end
        end
        if self.Menu.Harass.UseE ~= nil and self.Menu.Harass.UseE:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
            Control.CastSpell(HK_E, target.pos)
        end
        if self.Menu.Harass.UseR ~= nil and self.Menu.Harass.UseR:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
            Control.CastSpell(HK_R, target.pos)
        end		
	end
end	

function Morgana:Clear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
            if self.Menu.Clear.UseQL ~= nil and self.Menu.Clear.UseQL:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
                local QDmg = getdmg("Q", minion, myHero)
				if QDmg >= minion.health then
					Control.CastSpell(HK_Q, minion.pos)
				end	
            end
            if self.Menu.Clear.UseW ~= nil and self.Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
                local count = GetMinionCount(275, minion)
				if count >= self.Menu.Clear.UseWM:Value() then
					Control.CastSpell(HK_W, minion.pos)
				end
            end
            if self.Menu.Clear.UseE ~= nil and self.Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
                Control.CastSpell(HK_E, minion.pos)
            end
            if self.Menu.Clear.UseR ~= nil and self.Menu.Clear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end

function Morgana:JungleClear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.JClear.Mana == nil or (self.Menu.JClear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100))
            if self.Menu.JClear.UseQ ~= nil and self.Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
            if self.Menu.JClear.UseW ~= nil and self.Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
                local count = GetMinionCount(275, minion)
				if count >= self.Menu.JClear.UseWM:Value() then	
					Control.CastSpell(HK_W, minion.pos)
				end	
            end
            if self.Menu.JClear.UseE ~= nil and self.Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
                Control.CastSpell(HK_E, minion.pos)
            end
            if self.Menu.JClear.UseR ~= nil and self.Menu.JClear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end


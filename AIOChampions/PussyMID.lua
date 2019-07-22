local Mid = {"Lux","Ryze","Kassadin","Veigar","Neeko","Cassiopeia","Malzahar","Sylas","Ekko","Xerath","Ahri"}
if table.contains(Mid, myHero.charName) then
	_G[myHero.charName]()
end	

function OnLoad()
	AutoUpdate()

end

    local Version = 0.1
    
    local Files = {
        Lua = {
            Path = COMMON_PATH,
            Name = "PussyMID.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyAIOTest.lua"
        },
        Version = {
            Path = COMMON_PATH,
            Name = "PussyMID.version",
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
            print("New PussyMid Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end	
	end



class "Ahri"



local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 880, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_YASUOWALL}
}

local WData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 80, Range = 700, Speed = 900, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
}

local EData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 975, Speed = 1600, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
}

local RData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 600, Range = 450, Speed = 2200, Collision = false
}

function Ahri:__init()
	
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

function Ahri:VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function Ahri:CalculateCollisionTime(startPos, endPos, unitPos, startTime, speed, delay, origin)
	local delay = origin == "spell" and delay or 0
	local pos = startPos:Extended(endPos, speed * (Game.Timer() - delay - startTime))
	return GetDistance(unitPos, pos) / speed
end

function Ahri:CalculateEndPos(startPos, placementPos, unitPos, range, radius, collision, type)
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

local HeroIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/a/aa/Star_Guardian_Ahri_profileicon.png"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/1/19/Orb_of_Deception.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/a/a8/Fox-Fire.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/0/04/Charm.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/8/86/Spirit_Rush.png"

function Ahri:LoadMenu()
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Ahri", name = "PussyAhri", leftIcon = HeroIcon})
	--ComboMenu
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true, leftIcon = QIcon})
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true, leftIcon = WIcon})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true, leftIcon = EIcon})
	self.Menu.Combo:MenuElement({id = "Type", name = "Combo Logic", value = 2,drop = {"QWE", "EQW", "EWQ"}})	
	self.Menu.Combo:MenuElement({type = MENU, id = "UseR", name = "Ult Settings", leftIcon = RIcon})
	self.Menu.Combo.UseR:MenuElement({id = "RR", name = "On/Off Ult Logic", value = true})	
	self.Menu.Combo.UseR:MenuElement({id = "Type", name = "Ult Logic", value = 1,drop = {"Use for Kill", "Use Full in Combo", "Use after manually activate"}})	
	self.Menu.Combo.UseR:MenuElement({id = "CC", name = "AutoUlt incomming CCSpells", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "BlockList", name = "CCSpell List", type = MENU})	
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true, leftIcon = QIcon})
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W]", value = true, leftIcon = WIcon})
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
	
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true, leftIcon = QIcon})
	self.Menu.Clear:MenuElement({id = "Qmin", name = "Use Q If Hit X Minion ", value = 2, min = 1, max = 5, step = 1, leftIcon = QIcon})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true, leftIcon = QIcon})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "KillSteal", leftIcon = Icons["ks"]})
	self.Menu.KillSteal:MenuElement({id = "UseQ", name = "[Q]", value = true, leftIcon = QIcon})
	self.Menu.KillSteal:MenuElement({id = "UseW", name = "[W]", value = true, leftIcon = WIcon})
	self.Menu.KillSteal:MenuElement({id = "UseE", name = "[E]", value = true, leftIcon = EIcon})
	
	--AutoSpell on CC
	self.Menu:MenuElement({id = "CC", leftIcon = Icons["AutoUseCC"], type = MENU})
	self.Menu.CC:MenuElement({id = "UseQ", name = "Q", value = true, leftIcon = QIcon})
	self.Menu.CC:MenuElement({id = "UseE", name = "E", value = true, leftIcon = EIcon})
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	
	--Drawing
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw[Q]", value = true, leftIcon = QIcon})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw[W]", value = true, leftIcon = WIcon})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw[E]", value = true, leftIcon = EIcon})	
	self.Menu.Drawing:MenuElement({id = "DrawDamage", name = "DmgHPbar+KillableText[if all Spells learned]", value = true})
	self.Slot = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	DelayAction(function()
		for i, spell in pairs(CCSpells) do
			if not CCSpells[i] then return end
			for j, k in pairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not self.Menu.Combo.UseR.BlockList[i] then
					if not self.Menu.Combo.UseR.BlockList[i] then self.Menu.Combo.UseR.BlockList:MenuElement({id = "Dodge"..i, name = ""..spell.charName.." "..self.Slot[spell.slot].." | "..spell.displayName, value = true}) end
				end
			end    
		end
	end, 0.01)
end


function Ahri:Tick()
	if MyHeroReady() then
	self:KS()
	self:CC()
	self:AutoR()	
	if self.Menu.Combo.UseR.RR:Value() then
	self:KillR()
	end
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
			if self.Menu.Combo.UseR.RR:Value() then
			self:ComboR()
			end
		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		elseif Mode == "Flee" then
		end
	end
end


function Ahri:AutoR()
	if self.Menu.Combo.UseR.CC:Value() and Ready(_R) then
		self:OnMissileCreate() 
		self:OnProcessSpell() 
		for i, spell in pairs(self.DetectedSpells) do self:UseR(i, spell) end
	end
end

function Ahri:KillR()
local target = GetTarget(1300)
if target == nil then return end
	if IsValid(target, 1300) and myHero.pos:DistanceTo(target.pos) <= 1200 and self.Menu.Combo.UseR.Type:Value() == 1 and Ready(_R) then
		local Rdmg = getdmg("R", target, myHero)*3    
		if Rdmg >= target.health then
			Control.CastSpell(HK_R,target.pos)
		end
	end
end	

function Ahri:ActiveSpell()
	return myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "AhriTumble"
end

function Ahri:ComboR()
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target, 1300) then	
		if myHero.pos:DistanceTo(target.pos) <= 600 and self.Menu.Combo.UseR.Type:Value() == 2 and Ready(_R) then
				Control.CastSpell(HK_R,target.pos)
		
		
		elseif myHero.pos:DistanceTo(target.pos) <= 1200 and self.Menu.Combo.UseR.Type:Value() == 3 and Ready(_R) then
			if GotBuff(myHero, "AhriTumble") then
				Control.CastSpell(HK_R,target.pos)
			if GotBuff(myHero, "AhriTumble") then
				Control.CastSpell(HK_R,target.pos)
			end	
			end
		end		
	end
end	



function Ahri:Draw()
local textPos = myHero.pos:To2D()	
if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
end 
if myHero.dead then return end
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 880, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 700, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 975, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawDamage:Value() then
		local hero = GetTarget(1500)
		if hero == nil then return end
		if IsValid(hero) then
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = getdmg("Q",hero,myHero)
				local WDamage = getdmg("W",hero,myHero)
				local EDamage = getdmg("E",hero,myHero)
				local RDamage = getdmg("R",hero,myHero)
				local damage = QDamage + WDamage + EDamage + RDamage
				if damage > hero.health and Ready(_Q) and Ready(_W) and Ready(_E) and Ready(_R) then
					Draw.Text("killable", 24, hero.pos2D.x, hero.pos2D.y,Draw.Color(0xFF00FF00))
					
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, Draw.Color(200, 255, 255, 255))
				end
			end
		end	
	end				
end

function Ahri:GetHeroByHandle(handle)
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.handle == handle then return unit end
	end
end

function Ahri:UseR(i, s)
	local startPos = s.startPos; local endPos = s.endPos; local travelTime = 0
	if s.speed == math.huge then travelTime = s.delay else travelTime = s.range / s.speed + s.delay end
	if s.type == "rectangular" then
		local StartPosition = endPos-Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		local EndPosition = endPos+Vector(endPos-startPos):Normalized():Perpendicular()*(s.radius2 or 400)
		startPos = StartPosition; endPos = EndPosition
	end
	if s.startTime + travelTime > Game.Timer() then
		local Col = Ahri:VectorPointProjectionOnLineSegment(startPos, endPos, myHero.pos)
		if s.type == "circular" and GetDistanceSqr(myHero.pos, endPos) < (s.radius + myHero.boundingRadius) ^ 2 or GetDistanceSqr(myHero.pos, Col) < (s.radius + myHero.boundingRadius * 1.25) ^ 2 then
			local t = s.speed ~= math.huge and Ahri:CalculateCollisionTime(startPos, endPos, myHero.pos, s.startTime, s.speed, s.delay, s.origin) or 0.29
			local MPos = myHero.pos:Extended(mousePos, 450)
			if t < 0.3 then Control.CastSpell(HK_R, MPos) end
		end
	else table.remove(self.DetectedSpells, i) end
end

function Ahri:OnProcessSpell()
	local unit, spell = OnProcessSpell()
	if unit and spell and CCSpells[spell.name] then
		if GetDistance(unit.pos, myHero.pos) > 3000 or not self.Menu.Combo.UseR.BlockList["Dodge"..spell.name]:Value() then return end
		local Detected = CCSpells[spell.name]
		if Detected.origin ~= "missile" then
			local type = Detected.type
			if type == "targeted" then
				local MPos = myHero.pos:Extended(mousePos, 450)
				if spell.target == myHero.handle then Control.CastSpell(HK_R, MPos) end
			else
				local startPos = Vector(spell.startPos); local placementPos = Vector(spell.placementPos); local unitPos = unit.pos
				local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
				local endPos, range2 = Ahri:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
				table.insert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "spell"})
			end
		end
	end
end


function Ahri:OnMissileCreate()
	if Game.Timer() > self.Timer + 0.15 then
		for i, mis in pairs(self.DetectedMissiles) do if Game.Timer() > mis.timer + 2 then table.remove(self.DetectedMissiles, i) end end
		self.Timer = Game.Timer()
	end
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		if CCSpells[missile.missileData.name] then
			local unit = Ahri:GetHeroByHandle(missile.missileData.owner)
			if (not unit.visible and CCSpells[missile.missileData.name].origin ~= "spell") or CCExceptions[missile.missileData.name] then
				if GetDistance(unit.pos, myHero.pos) > 3000 or not self.Menu.Combo.UseR.BlockList["Dodge"..missile.missileData.name]:Value() then return end
				local Detected = CCSpells[missile.missileData.name]
				if Detected.origin ~= "spell" then
					for i, mis in pairs(self.DetectedMissiles) do if mis.name == missile.missileData.name then return end end
					table.insert(self.DetectedMissiles, {name = missile.missileData.name, timer = Game.Timer()})
					local startPos = Vector(missile.missileData.startPos); local placementPos = Vector(missile.missileData.placementPos); local unitPos = unit.pos
					local radius = Detected.radius; local range = Detected.range; local col = Detected.collision; local type = Detected.type
					local endPos, range2 = Ahri:CalculateEndPos(startPos, placementPos, unitPos, range, radius, col, type)
					table.insert(self.DetectedSpells, {startPos = startPos, endPos = endPos, startTime = Game.Timer(), speed = Detected.speed, range = range2, delay = Detected.delay, radius = radius, radius2 = radius2 or nil, angle = angle or nil, type = type, collision = col, origin = "missile"})
				end
			end
		end
	end
end

function Ahri:Combo()
if self:ActiveSpell() then return end
	if self.Menu.Combo.Type:Value() == 1 then
		self:Combo1()
	elseif self.Menu.Combo.Type:Value() == 2 then
		self:Combo2()
	elseif self.Menu.Combo.Type:Value() == 3 then
		self:Combo3()
	end
end

function Ahri:Combo1()
local target = GetTarget(1000)
if target == nil then return end
if IsValid(target, 1000) then    
	if myHero.pos:DistanceTo(target.pos) <= 880 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q,pred.CastPosition)
		    
	    end
    end

	if myHero.pos:DistanceTo(target.pos) <= 700 and self.Menu.Combo.UseW:Value() and Ready(_W) then
		local pred = GetGamsteronPrediction(target, WData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
			Control.CastSpell(HK_W,pred.CastPosition)
    
		end
	end
 
    if myHero.pos:DistanceTo(target.pos) <= 975 and self.Menu.Combo.UseE:Value() and Ready(_E) then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
			Control.CastSpell(HK_E,pred.CastPosition)
		  
	    end
    end
end
end


function Ahri:Combo2()
local target = GetTarget(1000)
if target == nil then return end
if IsValid(target, 1000) then    
	if myHero.pos:DistanceTo(target.pos) <= 975 then	
		if self.Menu.Combo.UseE:Value() and target and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
			    Control.CastSpell(HK_E,pred.CastPosition)
		    end
	    end
    end
	
	if myHero.pos:DistanceTo(target.pos) <= 880 then	
		if self.Menu.Combo.UseQ:Value() and target and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			    Control.CastSpell(HK_Q,pred.CastPosition)
		    end
	    end
    end

	if myHero.pos:DistanceTo(target.pos) <= 700 then 	
		if self.Menu.Combo.UseW:Value() and target and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
			    Control.CastSpell(HK_W,pred.CastPosition)
            end
		end
	end
end
end


function Ahri:Combo3()
local target = GetTarget(1000)
if target == nil then return end
if IsValid(target, 1000) then    
	if myHero.pos:DistanceTo(target.pos) <= 975 then	
		if self.Menu.Combo.UseE:Value() and target and Ready(_E) then
			local pred = GetGamsteronPrediction(target, EData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
			    Control.CastSpell(HK_E,pred.CastPosition)
		    end
	    end
    end
	
	if myHero.pos:DistanceTo(target.pos) <= 700 then	
		if self.Menu.Combo.UseW:Value() and target and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
			    Control.CastSpell(HK_W,pred.CastPosition)
            end
		end
	end
	
	if myHero.pos:DistanceTo(target.pos) <= 880 then	
		if self.Menu.Combo.UseQ:Value() and target and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			    Control.CastSpell(HK_Q,pred.CastPosition)
		    end
	    end
    end
end
end

function Ahri:Harass()
local target = GetTarget(1000)
if target == nil then return end
if IsValid(target, 1000) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value()/100 then
	if myHero.pos:DistanceTo(target.pos) <= 880 then	
		if self.Menu.Harass.UseQ:Value() and target and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			    Control.CastSpell(HK_Q,pred.CastPosition)
		    end
	    end
    end

	if myHero.pos:DistanceTo(target.pos) <= 700 then	
		if self.Menu.Harass.UseW:Value() and target and Ready(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
			    Control.CastSpell(HK_W,pred.CastPosition)
            end
		end
	end
end
end	

function Ahri:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_ENEMY and IsValid(minion,900) and myHero.pos:DistanceTo(minion.pos) <= 880 and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then
			if self.Menu.Clear.UseQ:Value() and Ready(_Q) then
				local count = GetMinionCount(150, minion)
				if count >= self.Menu.Clear.Qmin:Value() then
					Control.CastSpell(HK_Q,minion)
				end
			end
		end
	end
end

function Ahri:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_JUNGLE and IsValid(minion,900) and myHero.pos:DistanceTo(minion.pos) <= 880 and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then
			if self.Menu.JClear.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q,minion)
				
			end
		end
	end
end

function Ahri:KS()
local target = GetTarget(1000)
if target == nil then return end

if IsValid(target, 1000) then    
	if myHero.pos:DistanceTo(target.pos) <= 880 and self.Menu.KillSteal.UseQ:Value() and target and Ready(_Q) then
	    local Qdmg = getdmg("Q", target, myHero)
		if Qdmg >= target.health then
		    local pred = GetGamsteronPrediction(target, QData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			    Control.CastSpell(HK_Q,pred.CastPosition)
		    end
	    end
    end

	if myHero.pos:DistanceTo(target.pos) <= 700 and self.Menu.KillSteal.UseW:Value() and target and Ready(_W) then
		local Wdmg = getdmg("W", target, myHero)
		if Wdmg >= target.health then 
			local pred = GetGamsteronPrediction(target, WData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
			    Control.CastSpell(HK_W,pred.CastPosition)
            end
		end
	end
 
    if myHero.pos:DistanceTo(target.pos) <= 975 and self.Menu.KillSteal.UseE:Value() and target and Ready(_E) then
	    local Edmg = getdmg("E", target, myHero)
		if Edmg >= target.health then
		    local pred = GetGamsteronPrediction(target, EData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
			    Control.CastSpell(HK_E,pred.CastPosition)
		    end
	    end
    end
end
end


function Ahri:CC()
local target = GetTarget(1000)
if target == nil then return end
local Immobile = IsImmobileTarget(target)	
if IsValid(target, 1000) and Immobile then	
	if myHero.pos:DistanceTo(target.pos) <= 975 and self.Menu.CC.UseE:Value() and target and Ready(_E) then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
			Control.CastSpell(HK_E,pred.CastPosition)
			
		end
	end
	
	if myHero.pos:DistanceTo(target.pos) <= 880 and self.Menu.CC.UseQ:Value() and target and Ready(_Q) then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q,pred.CastPosition)
			
		end
	end	
end
end







-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Cassiopeia"





function Cassiopeia:LoadSpells()
	R = {Range = 825, Width = 200, Delay = 0.8, Speed = math.huge, Collision = false, aoe = false, Type = "circular"}

end

local QData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.8, Radius = 75, Range = 850, Speed = math.huge, Collision = false
}

local RData =
{
Type = _G.SPELLTYPE_CONE, Delay = 0.5, Radius = 80, Range = 825, Speed = 3200, Collision = false
}

	local AA = false
	local QRange = 850 * 850
	local MaxWRange = 800 * 800
	local MinWRange = 420 * 420
	local WMinCRange = 500 
	local WMaxCRange = 800 	
	local ERange = 700 * 700
	local RRange = 825 * 825

	function Cassiopeia:__init()
		
		Callback.Add("Tick", function() self:Tick() end)
		Callback.Add("Draw", function() self:Draw() end)
		self:Menu()
		self:LoadSpells()
		if _G.EOWLoaded then
			Orb = 1
		elseif _G.SDK and _G.SDK.Orbwalker then
			Orb = 2
		elseif _G.gsoSDK then
			Orb = 4			
		end
		print("PussyCassio Loaded")
	end

	function Cassiopeia:Menu()
		Cass = MenuElement({type = MENU, id = "Cass", name = "PussyCassio"})		
		Cass:MenuElement({name = " ", drop = {"General Settings"}})
		
		--Prediction
		Cass:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
		Cass.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
		Cass.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 2, drop = {"Normal", "High", "Immobile"}})		
		
		--Combo   
		Cass:MenuElement({type = MENU, id = "c", leftIcon = Icons["Combo"]})
		Cass.c:MenuElement({id = "Block", name = "Block AA in Combo [?]", value = true, tooltip = "Reload Script after changing"})
		Cass.c:MenuElement({id = "Q", name = "Use Q", value = true})
		Cass.c:MenuElement({id = "W", name = "Use W", value = true})
		Cass.c:MenuElement({id = "E", name = "Use E", value = true})
		Cass.c:MenuElement({id = "SR", name = "Manual R ", key = string.byte("A")})
		Cass.c:MenuElement({id = "R", name = "Use R ", value = true})
		Cass.c:MenuElement({id = "Count", name = "Min Amount to hit R", value = 2, min = 1, max = 5, step = 1})
		Cass.c:MenuElement({id = "P", name = "Use Panic R and Ghost", value = true})
		Cass.c:MenuElement({id = "HP", name = "Min HP % to Panic R", value = 20, min = 0, max = 100, step = 1})
		
		--Harass
		Cass:MenuElement({type = MENU, id = "h", leftIcon = Icons["Harass"]})
		Cass.h:MenuElement({id = "Q", name = "UseQ", value = true})
		Cass.h:MenuElement({id = "E", name = "UseE only poisend", value = true})		
		
		--Clear
		Cass:MenuElement({type = MENU, id = "w", leftIcon = Icons["Clear"]})
		Cass.w:MenuElement({id = "Q", name = "Use Q", value = true})
		Cass.w:MenuElement({id = "W", name = "Use W", value = true})
		Cass.w:MenuElement({id = "Count", name = "Min Minions to hit W", value = 3, min = 1, max = 5, step = 1})		
		Cass.w:MenuElement({id = "E", name = "Auto E Toggle Key", key = 84, toggle = true})
		
		--JungleClear
		Cass:MenuElement({type = MENU, id = "j", leftIcon = Icons["JClear"]})
		Cass.j:MenuElement({id = "Q", name = "Use Q", value = true})
		Cass.j:MenuElement({id = "W", name = "Use W", value = true})
		Cass.j:MenuElement({id = "E", name = "Use E[poisend or Lasthit]", value = true})		
		
		--KillSteal
		Cass:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
		Cass.ks:MenuElement({id = "Q", name = "UseQ", value = true})
		Cass.ks:MenuElement({id = "W", name = "UseW", value = true})
		Cass.ks:MenuElement({id = "E", name = "UseE", value = true})
	

		--Engage
		Cass:MenuElement({type = MENU, id = "kill", leftIcon = Icons["Engage"]})
		Cass.kill:MenuElement({id = "Eng", name = "EngageKill 1vs1", value = true, key = string.byte("T")})
		
		--Mana
		Cass:MenuElement({type = MENU, id = "m", leftIcon = Icons["Mana"]})
		Cass.m:MenuElement({name = " ", drop = {"Harass [%]"}})
		Cass.m:MenuElement({id = "Q", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "W", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "E", name = "E Mana", value = 5, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "R", name = "R Mana", value = 5, min = 0, max = 100, step = 1})		
		Cass.m:MenuElement({name = " ", drop = {"Clear [%]"}})
		Cass.m:MenuElement({id = "QW", name = "Q Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "WW", name = "W Mana", value = 10, min = 0, max = 100, step = 1})
		Cass.m:MenuElement({id = "EW", name = "E Mana", value = 10, min = 0, max = 100, step = 1})
		
		Cass:MenuElement({name = " ", drop = {"Advanced Settings"}})

		--Drawings
		Cass:MenuElement({type = MENU, id = "d", leftIcon = Icons["Drawings"]})
		Cass.d:MenuElement({id = "ON", name = "Enable Drawings", value = true})
		Cass.d:MenuElement({id = "Text", name = "Draw Text", value = true})
		Cass.d:MenuElement({id = "Lines", name = "Draw Lines", value = true})
		Cass.d:MenuElement({type = MENU, id = "Q", name = "Q"})
		Cass.d.Q:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "W", name = "W"})
		Cass.d.W:MenuElement({id = "ON", name = "Enabled", value = false})       
		Cass.d.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "E", name = "E"})
		Cass.d.E:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
		Cass.d:MenuElement({type = MENU, id = "R", name = "R"})
		Cass.d.R:MenuElement({id = "ON", name = "Enabled", value = true})       
		Cass.d.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
		Cass.d.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})				
		if Cass.c.Block:Value() then
			AA = true 
		end
	end
	
	


	
	function Cassiopeia:EdmgCreep()
		local level = myHero.levelData.lvl
		local base = (48 + 4 * level) + (0.1 * myHero.ap)
		return base
	end	

	function Cassiopeia:PEdmgCreep()
		local level = myHero:GetSpellData(_E).level
		local bonus = (({10, 30, 50, 70, 90})[level] + 0.60 * myHero.ap)
		local PEdamage = self:EdmgCreep() + bonus
		return PEdamage
	end	

	function Cassiopeia:GetAngle(v1, v2)
		local vec1 = v1:Len()
		local vec2 = v2:Len()
		local Angle = math.abs(math.deg(math.acos((v1*v2)/(vec1*vec2))))
		if Angle < 90 then
			return true
		end
		return false
	end

	function Cassiopeia:Tick()
		if MyHeroReady() then
		local Mode = GetMode()
			if Mode == "Combo" then
				self:BlockAA()
				self:Check(Mode)
				self:Combo()
			elseif Mode == "Harass" then
				self:Check(Mode)
				self:Harass()
			elseif Mode == "Clear" then
				self:Check(Mode)
				self:Clear()
				self:JClear()
			elseif Mode == "Flee" then
				
			end
			if Cass.w.E:Value() and Mode ~= "Combo" then
				self:AutoE()
			end
			if Cass.kill.Eng:Value() then
				self:Engage()
			end	
			if Cass.c.SR:Value() then
				self:SemiR()
			end	
			self:UnBlockAA(Mode)
			self:KsQ()
			self:KsW()
			self:KsE()			
		end
	end

	function Cassiopeia:IsFacing(unit)
	    local V = Vector((unit.pos - myHero.pos))
	    local D = Vector(unit.dir)
	    local Angle = 180 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
	    if math.abs(Angle) < 80 then 
	        return true  
	    end
	    return false
	end

	function Cassiopeia:RLogic()
		local RTarget = nil 
		local Most = 0
		local ShouldCast = false
			local InFace = {}
			for i = 1, Game.HeroCount() do
			local Hero = Game.Hero(i)
				if IsValid(Hero, 850) then 
					--local LS = LineSegment(myHero.pos, Hero.pos)
					--LS:__draw()
					InFace[#InFace + 1] = Hero
				end
			end
			local IsFace = {}
			for r = 1, #InFace do 
			local FHero = InFace[r]
				if self:IsFacing(FHero) then
					local Vectori = Vector(myHero.pos - FHero.pos)
					IsFace[#IsFace + 1] = {Vector = Vectori, Host = FHero}
				end
			end
			local Count = {}
			local Number = #InFace
			for c = 1, #IsFace do 
			local MainLine = IsFace[c]
			if Count[MainLine] == nil then Count[MainLine] = 1 end
				for w = 1, #IsFace do 
				local CloseLine = IsFace[w] 
				local A = CloseLine.Vector
				local B = MainLine.Vector
					if A ~= B then
						if self:GetAngle(A,B) and GetDistanceSqr(MainLine.Host.pos, myHero.pos) < 825 then 
							Count[MainLine] = Count[MainLine] + 1
						end
					end
				end
				if Count[MainLine] > Most then
					Most = Count[MainLine]
					RTarget = MainLine.Host
				end
			end
		--	print(Most)
			if Most >= Cass.c.Count:Value() or Most == Number then
				ShouldCast = true 
			end
		--	print(Most)
		--	if RTarget then
		--		LSS = Circle(Point(RTarget), 50)
		--		LSS:__draw()
		--	end
		return RTarget, ShouldCast
	end

	function Cassiopeia:BlockAA()
		if AA == true then
			if Orb == 1 then
				EOW:SetAttacks(false)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(false)
			elseif Orb == 4 then
				_G.gsoSDK.Orbwalker:SetAttack(false)				
			else
				--GOS:BlockAttack(true)
			end
		end
	end
	

	function Cassiopeia:UnBlockAA(Mode)
		if Mode ~= "Combo" and AA == false then 
			if Orb == 1 then 
				EOW:SetAttacks(true)
			elseif Orb == 2 then
				_G.SDK.Orbwalker:SetAttack(true)
			elseif Orb == 4 then
				_G.gsoSDK.Orbwalker:SetAttack(true)				
			else
			--	GOS:BlockAttack()
			end
		end
	end
	
	function Cassiopeia:Check(Mode)
		if AA == false or Mode ~= "Combo" then
		local activeSpell = myHero.activeSpell
		local cd = myHero:GetSpellData(_E).currentCd
			if activeSpell.windup > cd then
				if Orb == 1 then
					EOW:SetAttacks(false)
				elseif Orb == 2 then
					_G.SDK.Orbwalker:SetAttack(false)
				elseif Orb == 4 then
					_G.gsoSDK.Orbwalker:SetAttack(false)					
				else
				--	GOS:BlockAttack(true)
				end
			else
				if Orb == 1 then 
					EOW:SetAttacks(true)
				elseif Orb == 2 then
					_G.SDK.Orbwalker:SetAttack(true)
				elseif Orb == 4 then
					_G.gsoSDK.Orbwalker:SetAttack(true)				
				else
				--	GOS:BlockAttack()
				end
			end
		end
	end

	function Cassiopeia:CastW(key, pos)
		local key = key or HK_W
		local Dist = pos:DistanceTo()
		local h = myHero.pos
		local v = Vector(pos - myHero.pos):Normalized()
		if Dist < WMinCRange then
			Control.CastSpell(key, h + v*500)
		elseif Dist > WMaxCRange then
			Control.CastSpell(key, h + v*800)
		else
			Control.CastSpell(key, pos)
		end
	end	

	
function Cassiopeia:Combo()

	local target = GetTarget(950)
	if target == nil then return end
	local RValue = Cass.c.R:Value()
	local Dist = GetDistanceSqr(myHero.pos, target.pos)
	local QWReady = Ready(_Q) 
	local RTarget, ShouldCast = self:RLogic()
	if IsValid(target, 950)  then	
		
        local result = false
        if not result and Cass.c.E:Value() and Ready(_E) and Dist < ERange then
            result = Control.CastSpell(HK_E, target)
        end
        if not result and Cass.c.Q:Value() and Ready(_Q) then 
            if Dist < QRange then 
            local pred = GetGamsteronPrediction(target, QData, myHero)
                if pred.Hitchance >= Cass.Pred.PredQ:Value() then
                    result = Control.CastSpell(HK_Q, pred.CastPosition)
                end
            end
        end
        if not result and Cass.c.W:Value() and Ready(_W) then 
            if Dist < MaxWRange and Dist > MinWRange then
            local Pos = GetPred(target, 1500, 0.25 + Game.Latency()/1000)
                if GetDistanceSqr(Pos, myHero.pos) < MaxWRange then 
                    self:CastW(HK_W, Pos)
                end
            end
        end
		local pred = GetGamsteronPrediction(RTarget, RData, myHero)
		local WData = myHero:GetSpellData(_W) 
		local WCheck = Ready(_W)
		local Panic = Cass.c.P:Value() and myHero.health/myHero.maxHealth < Cass.c.HP:Value()/100 
		if Panic then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerHaste" and Ready(SUMMONER_1) then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHaste" and Ready(SUMMONER_2) then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
		if Cass.c.R:Value() and Ready(_R) and (HasPoison(target) or Panic) and ((WCheck == false or (WCheck and (Game.Timer() + WData.cd) - WData.castTime > 2)) or WValue == false) then
			if Panic then
				if Dist < RRange then
					if RTarget and pred.Hitchance >= Cass.Pred.PredR:Value() then 
						Control.CastSpell(HK_R, pred.CastPosition)
					else
						Control.CastSpell(HK_R, target.pos)
					end
				end
			end
		end				
		if Cass.c.R:Value() and Ready(_R) then
			if Dist < RRange then 
				if RTarget and ShouldCast == true and pred.Hitchance >= Cass.Pred.PredR:Value() then
					Control.CastSpell(HK_R, pred.CastPosition)
					
				end 
			end
		end
	end
end	
	
function Cassiopeia:SemiR()
	local target = GetTarget(950)
	if target == nil then return end
	local RTarget, ShouldCast = self:RLogic()
	local Dist = GetDistanceSqr(myHero.pos, target.pos)	
	local pred = GetGamsteronPrediction(RTarget, RData, myHero)
	if IsValid(target, 950) and Dist < RRange and Ready(_R) then
		if RTarget and pred.Hitchance >= Cass.Pred.PredR:Value() then
			Control.CastSpell(HK_R, pred.CastPosition)
		else
			Control.CastSpell(HK_R, target.pos)			
		end
	end 
end
	
		

function Cassiopeia:Harass()

	local target = GetTarget(950)
	if target == nil then return end
	
	if IsValid(target, 950)  then
		local EDmg = getdmg("E", target, myHero) * 2
		local Dist = GetDistanceSqr(myHero.pos, target.pos)
		local result = false
		if not result and Dist < ERange and Cass.h.E:Value() and Ready(_E) and (HasPoison(target) or EDmg >= target.health) then
            result = Control.CastSpell(HK_E, target)
        end
        if not result and Dist < QRange and Cass.h.Q:Value() and Ready(_Q) and myHero.mana/myHero.maxMana > Cass.m.Q:Value()/100 then 
        local pred = GetGamsteronPrediction(target, QData, myHero)
            if pred.Hitchance >= Cass.Pred.PredQ:Value() then
                result = Control.CastSpell(HK_Q, pred.CastPosition)
               
            end
        end
	end
end	
	
function Cassiopeia:Clear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = myHero.mana/myHero.maxMana >= Cass.m.QW:Value() / 100
            local Dist = myHero.pos:DistanceTo(minion.pos)
			if Cass.w.Q:Value() and mana_ok and Dist <= myHero:GetSpellData(_Q).range and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
            if Cass.w.W:Value() and mana_ok and Dist <= MaxWRange and Ready(_W) then
                local Pos = GetPred(minion, 1500, 0.25 + Game.Latency()/1000)
				local Dist = GetDistanceSqr(minion.pos, myHero.pos)
				if Dist < MaxWRange and Dist > MinWRange and MinionsNear(minion,500) >= Cass.w.Count:Value() then
					self:CastW(HK_W, Pos)
				end	
            end
        end
    end
end

	
function Cassiopeia:JClear()
	for i = 1, Game.MinionCount() do 
	local Minion = Game.Minion(i)		 

	if Minion.team == TEAM_JUNGLE then	
		local Dist = myHero.pos:DistanceTo(Minion.pos)	
		if IsValid(Minion, 850) and Dist < QRange then	
			if Cass.j.Q:Value() and Ready(_Q) and myHero.mana/myHero.maxMana > Cass.m.QW:Value()/100 then
				Control.CastSpell(HK_Q, Minion.pos)
				
			end
		end
		if IsValid(Minion, 800) then
			local Pos = GetPred(Minion, 1500, 0.25 + Game.Latency()/1000)
			if Dist < MaxWRange then
				
				if Dist < MaxWRange and Dist > MinWRange then	
					if Cass.j.W:Value() and Ready(_W) and myHero.mana/myHero.maxMana > Cass.m.WW:Value()/100 then
						self:CastW(HK_W, Pos)
					end	
				end
			end
		end
		
		if IsValid(Minion, 750) and Dist < ERange then	
			if Cass.j.E:Value() and Ready(_E) then
				if HasPoison(Minion) then
					Block(true)
					Control.CastSpell(HK_E, Minion)
					break
				elseif self:EdmgCreep() > Minion.health then
					Block(true)
					Control.CastSpell(HK_E, Minion)
					break
				elseif HasPoison(Minion) and self:PEdmgCreep() > Minion.health then
					Block(true)
					Control.CastSpell(HK_E, Minion)
					break					
				end
			end
		end
		Block(false)
	end
	end
end

	
function Cassiopeia:KsE()
local target = GetTarget(750)
if target == nil then return end
local Dist = GetDistanceSqr(myHero.pos, target.pos)	 
	if IsValid(target, 750) and Dist < ERange then	
		local EDmg = getdmg("E", target, myHero) * 2
		local PEDmg = getdmg("E", target, myHero)
		if Cass.ks.E:Value() and Ready(_E) then 
			if HasPoison(target) and PEDmg > target.health then
				Control.CastSpell(HK_E, target)
				
			elseif EDmg > target.health then
				Control.CastSpell(HK_E, target)
			
			end
		end
	end	
end	
	
function Cassiopeia:KsQ()
local target = GetTarget(900)
if target == nil then return end
local Dist = GetDistanceSqr(myHero.pos, target.pos)	
	if IsValid(target, 900) and Dist < QRange then	
		if Cass.ks.Q:Value() and Ready(_Q) then 
			local QDmg = getdmg("Q", target, myHero)
			if QDmg > target.health then
				Control.CastSpell(HK_Q, target.pos)
			
			end
		end
	end
end	

function Cassiopeia:KsW()
local target = GetTarget(900)
if target == nil then return end
local Dist = GetDistanceSqr(myHero.pos, target.pos)	
	if IsValid(target, 900) and Dist < 800 then
		if Cass.ks.W:Value() and Ready(_W) then 
			local WDmg = getdmg("W", target, myHero)
			if WDmg > target.health then
				Control.CastSpell(HK_W, target.pos)
			
			end
		end
	end	
end	

	
	function Cassiopeia:Engage()
		local target = GetTarget(1200)
		if target == nil then return end
		local Dist = GetDistanceSqr(myHero.pos, target.pos)

		if IsValid(target, 1200) and Dist < ERange then
			local fulldmg = getdmg("Q", target, myHero) + getdmg("W", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero)
			local Dist = GetDistanceSqr(myHero.pos, target.pos)
			local RCheck = Ready(_R)
			local RTarget, ShouldCast = self:RLogic()
		
		
			local pred = GetGamsteronPrediction(RTarget, RData, myHero)
			if EnemiesNear(myHero,825) == 1 and Ready(_R) and Ready(_W) and Ready(_Q) and Ready(_E) then 
				if RTarget and EnemyInRange(RRange) and fulldmg > target.health and pred.Hitchance >= Cass.Pred.PredR:Value() then
					Control.CastSpell(HK_R, pred.CastPosition)
				end
			end 
			if not Ready(_R) then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerHaste" and Ready(SUMMONER_1) then
					Control.CastSpell(HK_SUMMONER_1)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHaste" and Ready(SUMMONER_2) then
					Control.CastSpell(HK_SUMMONER_2)
				end
			end	
			if Ready(_Q) and not Ready(_R) then 
				if Dist < QRange then 
				local pred = GetGamsteronPrediction(target, QData, myHero)
					if Dist < QRange and pred.Hitchance >= Cass.Pred.PredQ:Value() then
						Control.CastSpell(HK_Q, pred.CastPosition)
					end
				end
			end
			if Ready(_E) and not Ready(_R) then 
				if Dist < ERange then
					Control.CastSpell(HK_E, target)
				end
			end	
			if Ready(_W) and not Ready(_R) then 
				if Dist < MaxWRange and Dist > MinWRange then
				local Pos = GetPred(target, 1500, 0.25 + Game.Latency()/1000)
					if Dist < MaxWRange then 
						self:CastW(HK_W, Pos)
					end
				end
			end
		end	
	end
	
	
	
function Cassiopeia:AutoE()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,myHero:GetSpellData(_E).range) then	
			local mana_ok = myHero.mana/myHero.maxMana >= Cass.m.EW:Value() / 100
            local Dist = myHero.pos:DistanceTo(minion.pos)
			if Cass.w.E:Value() and mana_ok and Dist <= myHero:GetSpellData(_E).range and Ready(_E) then
				local PDmg = self:PEdmgCreep()
				local EDmg = self:EdmgCreep()
				if HasPoison(minion) and PDmg + 20 >= minion.health then 
					Block(true)
					if self:PEdmgCreep() >= minion.health then
						Control.CastSpell(HK_E, minion)
					end
				end
				if EDmg + 20 >= minion.health then 
					Block(true)
					if self:EdmgCreep() >= minion.health then
						Control.CastSpell(HK_E, minion)
					end
				end
				Block(false)
            end	
		end
	end	
end
					

	function Cassiopeia:Draw()
	local textPos = myHero.pos:To2D()	
		if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
			Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
		end
		if myHero.dead == false and Cass.d.ON:Value() then
			
			if Cass.d.Lines:Value() then
				local InFace = {}
				for i = 1, Game.HeroCount() do
				local Hero = Game.Hero(i)
					if IsValid(Hero, 850) and self:IsFacing(Hero) then 
						local Vectori = Vector(myHero.pos - Hero.pos)
						local LS = LineSegment(myHero.pos, Hero.pos)
						LS:__draw()
					end
				end
				local RTarget = self:RLogic()
				if RTarget then
					LSS = Circle(Point(RTarget), RTarget.boundingRadius)
					LSS:__draw()
				end
			end
			if Cass.d.Text:Value() then 
				if Cass.w.E:Value() then 
					Draw.Text("Auto E ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
				else
					Draw.Text("Auto E OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
				end
			end
			if Cass.d.Q.ON:Value() then
				Draw.Circle(myHero.pos, 850, Cass.d.Q.Width:Value(), Cass.d.Q.Color:Value())
			end
			if Cass.d.W.ON:Value() then
				Draw.Circle(myHero.pos, 340, Cass.d.W.Width:Value(), Cass.d.W.Color:Value())
				Draw.Circle(myHero.pos, 960, Cass.d.W.Width:Value(), Cass.d.W.Color:Value())
			end
			if Cass.d.E.ON:Value() then
				Draw.Circle(myHero.pos, 750, Cass.d.E.Width:Value(), Cass.d.E.Color:Value())
			end	
			if Cass.d.R.ON:Value() then
				Draw.Circle(myHero.pos, 750, Cass.d.E.Width:Value(), Cass.d.E.Color:Value())
			end			
		end
		local target = GetTarget(1200)
		if target == nil then return end
	
		if EnemiesNear(myHero,1200) == 1 and Ready(_R) and Ready(_W) and Ready(_E) and Ready(_Q) then	
			local fulldmg = getdmg("Q", target, myHero) + getdmg("W", target, myHero) + getdmg("E", target, myHero) + getdmg("R", target, myHero)
			local textPos = target.pos:To2D()
			if IsValid(target, 1200) then
				if fulldmg > target.health then 
					Draw.Text("Engage PressKey", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
				end
			end
		end		
	end
	


-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "Ekko"






function Ekko:__init()
	
	self.DetectedMissiles = {}; self.DetectedSpells = {}; self.Target = nil; self.Timer = 0
	if menu ~= 1 then return end
	menu = 2 
	twin = nil
	
	for i = 0, Game.ObjectCount() do
	local particle = Game.Object(i)
		if particle and not particle.dead and particle.name:find("Ekko") then
		twin = particle
		end
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

local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 60, Range = 1075, Speed = 2000, Collision = false
}

local WData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 375, Range = 1600, Speed = 1650, Collision = false
}

function Ekko:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Ekko", name = "PussyEkko"})
	
	--Auto W 
	self.Menu:MenuElement({type = MENU, id = "Auto", leftIcon = Icons["AutoWImmo"]})
	self.Menu.Auto:MenuElement({id = "UseW", name = "[W] Deadly Spines", value = true})			
	self.Menu.Auto:MenuElement({id = "Targets", name = "Minimum Targets", value = 2, min = 1, max = 5, step = 1})

	self.Menu:MenuElement({type = MENU, id = "Auto2", leftIcon = Icons["AutoWE"]})
	self.Menu.Auto2:MenuElement({id = "UseWE", name = "[W]+[E] Stun", value = true})			
	self.Menu.Auto2:MenuElement({id = "Targets", name = "Minimum Targets", value = 3, min = 1, max = 5, step = 1})

	--Auto R safe Life
	self.Menu:MenuElement({type = MENU, id = "Life", leftIcon = Icons["AutoRSafeLife"]})	
	self.Menu.Life:MenuElement({id = "UseR", name = "[R] Deadly Spines", value = true})	
	self.Menu.Life:MenuElement({id = "life", name = "Min HP", value = 20, min = 0, max = 100, identifier = "%"})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})		
	self.Menu.Combo:MenuElement({id = "UseWE", name = "[W]+[E] Stun", value = true})			
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = false})  	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Grasping Roots", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Deadly Spines", value = true})	
	self.Menu.ks:MenuElement({id = "UseR", name = "Kill in Twin Range", value = true})	
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Ekko:Tick()
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
		self:Auto()
		self:Auto2()	
		self:SafeLife()
		
	end
end


function Ekko:Draw()
local textPos = myHero.pos:To2D()	
if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
end  
  if myHero.dead then return end                                               
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 1075, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 1600, 1, Draw.Color(225, 225, 125, 10))
	end
	local target = GetTarget(1600)     	
	if target == nil then return end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) and IsValid(target) then
    Draw.Circle(target, 400, 1, Draw.Color(225, 225, 125, 10))
	end	
end

function Ekko:SafeLife()
	local target = GetTarget(1200)     	
	

		if twin and myHero.health/myHero.maxHealth <= self.Menu.Life.life:Value()/100 and self.Menu.Life.UseR:Value() and Ready(_R) and IsValid(target,1200) then
			if myHero.pos:DistanceTo(target.pos) <= 1200 and myHero.pos:DistanceTo(twin) >= 800 then
				Control.CastSpell(HK_R)
			end
		end
	end

function Ekko:Auto()
	local target = GetTarget(1700)     	
	if target == nil then return end
	local pred = GetGamsteronPrediction(target, WData, myHero)
	local Immo = GetImmobileCount(400, target)
	if IsValid(target, 1700) and myHero.pos:DistanceTo(target.pos) <= 1600 and Immo >= self.Menu.Auto.Targets:Value() then
		if self.Menu.Auto.UseW:Value() and Ready(_W) then
			if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
				Control.CastSpell(HK_W, pred.CastPosition)
			end
		end	
	end
end

function Ekko:Auto2()
	local target = GetTarget(1000)     	
	if target == nil then return end		
	local pred = GetGamsteronPrediction(target, WData, myHero)
	if self.Menu.Auto2.UseWE:Value() and IsValid(target, 1000) then
		if myHero.pos:DistanceTo(target.pos) <= 650 and Ready(_W) and Ready(_E) and CountEnemiesNear(target, 400) >= self.Menu.Auto2.Targets:Value() and pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
			Control.CastSpell(HK_W, pred.CastPosition)
		end
	
		if myHero.pos:DistanceTo(target.pos) <= 690 and Ready(_E) then
			local EPos = myHero.pos:Extended(target.pos, 325)
			DelayAction(function()
			Control.SetCursorPos(EPos)
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)			
			end, 2.0)	
		end	
	end	
end 

     

function Ekko:KillSteal()	
	local target = GetTarget(1700)     	
	if target == nil then return end
	local hp = target.health
	local IGdamage = 50 + 20 * myHero.levelData.lvl
	local QDmg = getdmg("Q", target, myHero)
	local RDmg = getdmg("R", target, myHero)	
	local FullDmg = RDmg + QDmg
	local FullIgn = FullDmg + IGdamage
	if IsValid(target) then	
		
		if myHero.pos:DistanceTo(target.pos) <= 900 and self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= hp and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end

		if twin and target.pos:DistanceTo(twin) <= 400 and self.Menu.ks.UseR:Value() then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) and Ready(_R) and Ready(_Q) and hp <= FullIgn then
				Control.CastSpell(HK_R)

				Control.CastSpell(HK_Q, target.pos)
				if myHero.pos:DistanceTo(target.pos) <= 600 then
					Control.CastSpell(HK_SUMMONER_1, target)
				end	
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2) and Ready(_R) and Ready(_Q) and hp <= FullIgn then
				Control.CastSpell(HK_R)
				self:AutoWE()
				Control.CastSpell(HK_Q, target.pos)
				if myHero.pos:DistanceTo(target.pos) <= 600 then
					Control.CastSpell(HK_SUMMONER_2, target)
				end
			elseif Ready(_R) and Ready(_Q) and hp <= FullDmg then
				Control.CastSpell(HK_R)
				self:AutoWE()
				Control.CastSpell(HK_Q, target.pos)
			elseif Ready(_R) and hp <= RDmg then
				Control.CastSpell(HK_R)
				self:AutoWE()
			end
		end	
	end
end	

function Ekko:Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target, 1000) then
				
		if myHero.pos:DistanceTo(target.pos) <= 900 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 900 and Ready(_W) and self.Menu.Combo.UseWE:Value() then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
				Control.CastSpell(HK_W, pred.CastPosition)
			end
		end	
		if myHero.pos:DistanceTo(target.pos) <= 405 and Ready(_E) then
			Control.CastSpell(HK_E, target.pos)	
		end
	end
end	

function Ekko:Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target, 1000) and myHero.pos:DistanceTo(target.pos) <= 900 and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end	

function Ekko:Clear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
            if self.Menu.Clear.UseQ ~= nil and self.Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
            if self.Menu.Clear.UseW ~= nil and self.Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
                Control.CastSpell(HK_W, minion.pos)
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

function Ekko:JungleClear()
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
                Control.CastSpell(HK_W, minion.pos)
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



-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "Kassadin"





function Kassadin:__init()
 
  if menu ~= 1 then return end
  menu = 2
  self.passiveTracker = 0
  self.stacks = 0
  qdmg = 0
  edmg = 0
  rdmg = 0
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

function Kassadin:LoadSpells()

  Q = { range = 650, delay = 0.25, speed = 1400, width = myHero:GetSpellData(_Q).width, radius = 50, Collision = false }
  W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
  E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
  R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end




function Kassadin:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Kassadin", leftIcon = Icons["Kassadin"]})
 
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.Combo:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
 
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({id = "LastQ", name = "[Q] LastHit Minions", value = true})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Harass:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.Harass:MenuElement({id = "UseR", name = "Poke[R],[E],[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 65, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})         
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.Clear:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.Clear:MenuElement({id = "EHit", name = "[E] if x minions", value = 3, min = 1, max = 7})
	self.Menu.Clear:MenuElement({id = "lastQ", name = "[Q] LastHit", value = true})         
	self.Menu.Clear:MenuElement({id = "lastW", name = "[W] LastHit", value = true})  
	self.Menu.Clear:MenuElement({id = "lastR", name = "[R] LastHit[Only if not Enemys near]", value = true})
	self.Menu.Clear:MenuElement({id = "RHit", name = "[R] LastHit if x minions", value = 3, min = 1, max = 7})  
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 50, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})         
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Nether Blade", value = true})
	self.Menu.JClear:MenuElement({id = "UseAW", name = "Auto[W] Nether Blade", value = true})	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Force Pulse", value = true})
	self.Menu.JClear:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 50, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Null Sphere", value = true})
	self.Menu.ks:MenuElement({id = "UseR", name = "[R] Riftwalk", value = true})
	self.Menu.ks:MenuElement({id = "UseQR", name = "[Q]then[R]", value = true})
	self.Menu.ks:MenuElement({id = "UseRQ", name = "[R]then[Q]", value = true})	
 
	--BlockSpellsMenu
	self.Menu:MenuElement({type = MENU, id = "block", leftIcon = Icons["BlockSpells"]})
	for i = 1, Game.HeroCount() do
	local unit = Game.Hero(i)
		if unit.team ~= myHero.team then
		units[#units + 1] = unit
			if cancelSpells[unit.charName] then
			foundAUnit = true
		self.Menu.block:MenuElement({type = MENU, id = unit.charName, name = unit.charName})
				for spell, sname in pairs(cancelSpells[unit.charName]) do
				self.Menu.block[unit.charName]:MenuElement({id = spell, name = sname.name, value = true})
  
				end
			end
		end
	end
	if not foundAUnit then
	self.Menu.block:MenuElement({id = "none", name = "No blockable Spell found", type = SPACE}) 
	end 

	--EscapeMenu
	self.Menu:MenuElement({type = MENU, id = "evade", leftIcon = Icons["Escape"]})
	self.Menu.evade:MenuElement({type = MENU, id = "Life", name = "Auto Escape Menu"})	
	self.Menu.evade.Life:MenuElement({id = "UseR", name = "AutoEscape[R] to Ally or Tower", value = true})
	self.Menu.evade.Life:MenuElement({id = "MinR", name = "Min Life to Escape", value = 20, min = 0, max = 100, identifier = "%"})	
	self.Menu.evade:MenuElement({type = MENU, id = "Flee", name = "Manual Escape Menu"})	
	self.Menu.evade.Flee:MenuElement({id = "UseR", name = "Use[R] to Ally or Tower [EscapeKey]", value = true})
	self.Menu.evade.Flee:MenuElement({id = "UseRm", name = "Use[R] to Mouse.Pos [EscapeKey]", value = true})	
	self.Menu.evade.Flee:MenuElement({id = "Fleekey", name = "Escape key", key = string.byte("A")})
	
	
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable on Target and Minimap", value = true})	
end

function Kassadin:Tick()
	if MyHeroReady() then
	self:EscapeR()
	self:OnBuff(myHero)
	self:KillSteal()

	
	if Ready(_Q) and foundAUnit then     
		for i = 1, #units do
		local unit = units[i]
		
			if IsValid(unit) and unit.isEnemy and unit.isChanneling == true and unit.activeSpell.valid then
			local spellToCancel = cancelSpells[unit.charName]
			local activeSpell = unit.activeSpell.name
			if spellToCancel == nil then return end
			local ignore = (unit.activeSpell.name == "PowerBall") or (unit.activeSpell.name == "PantheonE") or (unit.activeSpell.name == "Meditate") or (unit.activeSpell.name == "GragasW") or (unit.activeSpell.name == "FiddleSticksDrain")	
				if spellToCancel[activeSpell] and self.Menu.block[unit.charName][activeSpell]:Value() then
					if myHero.pos:DistanceTo(unit.pos) <= 650 then
						Control.CastSpell(HK_Q, unit)
					elseif Ready(_R) and myHero.pos:DistanceTo(unit.pos) > 650 and myHero.pos:DistanceTo(unit.pos) <= 1150 then
						if ignore then return end
						Control.CastSpell(HK_R, unit.pos)
						Control.CastSpell(HK_Q, unit)
					end
				end
			end    
		end
	end
	if self.Menu.evade.Flee.Fleekey:Value() then
		self:Flee()
	end
	if self.Menu.evade.Flee.Fleekey:Value() then
		self:FleeR()
	end	
	

	local Mode = GetMode()
		if Mode == "Combo" then
		self:Combo()
		self:Combo1()
		self:FullRKill()
		if self.Menu.Combo.UseAW:Value() then
			self:AutoW()
		end
		elseif Mode == "Harass" then
		self:Harass()
		self:LasthitQ()
		if self.Menu.Harass.UseAW:Value() then
			self:AutoW()
			self:AutoW1()
		end	
		elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
		if self.Menu.Clear.UseAW:Value() then
			self:AutoW1()
		end
		if self.Menu.JClear.UseAW:Value() then
			self:AutoW1()
		end	
		elseif Mode == "Flee" then
		
		end	
	end
end

function Kassadin:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 500, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, Q.range, 1, Draw.Color(225, 225, 0, 10))
	end
  	local target = GetTarget(20000)
	if target == nil then return end	
	local hp = target.health
	local Dmg = (getdmg("Q", target)), (getdmg("E", target)), (getdmg("Q", target) + getdmg("R", target)), (getdmg("Q", target) + getdmg("E", target)), (getdmg("Q", target) + getdmg("E", target) + getdmg("R", target)), (getdmg("Q", target) + getdmg("W", target) + getdmg("E", target) + getdmg("R", target))
	local QWEdmg = getdmg("Q", target) + getdmg("W", target) + getdmg("E", target)
	local FullReady = Ready(_Q), Ready(_W), Ready(_E), Ready(_R)
	local QWEReady = Ready(_Q), Ready(_W), Ready(_E)	
	if IsValid(target, 20000) and self.Menu.Drawing.Kill:Value() then
				
		if Ready(_R) and getdmg("R", target) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_R) and (getdmg("R", target) + getdmg("R", target, myHero, 2)) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
		if FullReady and (getdmg("R", target) + getdmg("R", target, myHero, 2) + QWEdmg) > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end	
		if Dmg > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))			
		end
		if QWEReady and QWEdmg > hp then
			Draw.Text("Killable Combo", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end
	end
end

function Kassadin:OnBuff(unit)

  if unit.buffCount == nil then self.passiveTracker = 0 self.stacks = 0 return end
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    
    if buff.name == "forcepulsecancast" then
      self.passiveTracker = buff.count
	end  
    if buff.name == "RiftWalk" then
      self.stacks = buff.count      
    end     
  end
end

function Kassadin:ClearLogic()
  local EPos = nil 
  local Most = 0 
    for i = 1, Game.MinionCount() do
    local Minion = Game.Minion(i)
      if IsValid(Minion, 650) then
        local Count = GetMinionCount(650, Minion)
        if Count > Most then
          Most = Count
          EPos = Minion.pos
        end
      end
    end
    return EPos, Most
end 

function Kassadin:KillSteal()
	local target = GetTarget(1150)
	if target == nil then return end

	
	
	if IsValid(target, 1150) then
		local hp = target.health	
		if myHero.pos:DistanceTo(target.pos) <= 650 then	
			local QDmg = getdmg("Q", target)
			if self.Menu.ks.UseQ:Value() and Ready(_Q) and QDmg >= hp then
				Control.CastSpell(HK_Q, target.pos)					
			end				
		end
	
		if myHero.pos:DistanceTo(target.pos) <= 500 then	
			local RDmg = getdmg("R", target)
			if self.Menu.ks.UseR:Value() and Ready(_R) and not IsUnderTurret(target) and RDmg >= hp then
				Control.CastSpell(HK_R, target)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 500 and self.Menu.ks.UseQR:Value() and Ready(_R) and Ready(_Q) then
			local RDmg = getdmg("R", target)
			local QDmg = getdmg("Q", target)
			if (RDmg + QDmg) >= hp and not IsUnderTurret(target) then
				Control.CastSpell(HK_Q, target.pos)
				Control.CastSpell(HK_R, target)
								
			end
		end	
		if myHero.pos:DistanceTo(target.pos) < 1150 and myHero.pos:DistanceTo(target.pos) > 650 and self.Menu.ks.UseRQ:Value() and Ready(_R) and Ready(_Q) then
			local RDmg = getdmg("R", target)
			local QDmg = getdmg("Q", target)
			if (RDmg + QDmg) >= hp and not IsUnderTurret(target) then
				Control.CastSpell(HK_R, target)
				Control.CastSpell(HK_Q, target.pos)
								
			end
		end
	end
end	



function Kassadin:AutoW()  
	local target = GetTarget(300)
	if target == nil then return end
	if IsValid(target, 300) and myHero.pos:DistanceTo(target.pos) <= 300 and Ready(_W) then
		Control.CastSpell(HK_W)
	end
end	
	
function Kassadin:AutoW1()	
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_ENEMY or minion.team == TEAM_JUNGLE then	
			if IsValid(minion,300) and myHero.pos:DistanceTo(minion.pos) <= 300 and Ready(_W) then
				Control.CastSpell(HK_W)
			end
		end
	end
end	


	
function Kassadin:Combo()
local target = GetTarget(650)
if target == nil then return end
	
	if IsValid(target, 650) and myHero.pos:DistanceTo(target.pos) < 650 then	
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) then	
			Control.CastSpell(HK_Q, target.pos)
			
		end	
	end	
	
	if IsValid(target, 600) and myHero.pos:DistanceTo(target.pos) < 600 and self.passiveTracker >= 1 and self.Menu.Combo.UseE:Value() and Ready(_E) then	
		Control.CastSpell(HK_E, target)
	end
end	
	

function Kassadin:EscapeR()
	local target = GetTarget(2000)
	if target == nil then return end
	if IsValid(target, 2000) and myHero.pos:DistanceTo(target.pos) <= 600 and myHero.health/myHero.maxHealth <= self.Menu.evade.Life.MinR:Value()/100 and self.Menu.evade.Life.UseR:Value() and Ready(_R) then 
		for i,ally in pairs(GetAllyHeroes()) do
			if IsValid(ally, 2000) and myHero.pos:DistanceTo(ally.pos) < 2000 and myHero.pos:DistanceTo(ally.pos) > 500 then
				if GetEnemyCount(1000, ally) < 1 then
				Control.CastSpell(HK_R, ally.pos)
				end
			end	
		end
		for i,tower in pairs(GetAllyTurret()) do
			if IsValid(tower, 2000) and myHero.pos:DistanceTo(tower.pos) < 2000 and myHero.pos:DistanceTo(tower.pos) > 750 then
				Control.CastSpell(HK_R, tower.pos)
			end	
		end
	end
end
	

function Kassadin:Flee()
	if self.Menu.evade.Flee.UseR:Value() and Ready(_R) then		
	for i,ally in pairs(GetAllyHeroes()) do
			if IsValid(ally, 2000) and myHero.pos:DistanceTo(ally.pos) < 2000 and myHero.pos:DistanceTo(ally.pos) > 500 then
				if GetEnemyCount(1000, ally) < 1 then
					Control.CastSpell(HK_R, ally)
				end
			end
		end	
		for i,tower in pairs(GetAllyTurret()) do
			if IsValid(tower, 2000) and myHero.pos:DistanceTo(tower.pos) < 2000 and myHero.pos:DistanceTo(tower.pos) > 750 then
				Control.CastSpell(HK_R, tower)
					
			end	
		end
	end
end	

function Kassadin:FleeR()
	if self.Menu.evade.Flee.UseRm:Value() and Ready(_R) then				
		Control.CastSpell(HK_R)
	end
end			

function Kassadin:Harass()	
local target = GetTarget(1100)
if target == nil then return end	


	if IsValid(target, 1100) then
	
		if myHero.pos:DistanceTo(target.pos) <= 1000 and myHero.pos:DistanceTo(target.pos) >= 700 then
			if self.stacks == 0 and self.passiveTracker >= 1 and not IsUnderTurret(target) then	
				if self.Menu.Harass.UseR:Value() and Ready(_Q) and Ready(_E) and Ready(_R) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then		
					Control.CastSpell(HK_R, target)
					Control.CastSpell(HK_E, target)
					Control.CastSpell(HK_Q, target.pos)
						
				end				
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 550 and self.passiveTracker >= 1 then	
			if self.Menu.Harass.UseE:Value() and Ready(_E) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then
				Control.CastSpell(HK_E, target)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 650 and self.Menu.Harass.UseQ:Value() and Ready(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then
			Control.CastSpell(HK_Q, target)
		end 
	end
end

function Kassadin:LasthitQ()
local target = GetTarget(650)
	if target == nil then
	    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
		if max_range > 1500 then
			max_range = 1500
		end
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
			if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then	
				local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
				if self.Menu.Harass.LastQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and myHero.pos:DistanceTo(minion.pos) > myHero.range and Ready(_Q) then
					local Qdamage = getdmg("Q", minion)
					if Qdamage >= minion.health then
						Control.CastSpell(HK_Q, minion.pos)
					end	
				end
			end
		end
	end
end	

function Kassadin:Clear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
            if self.Menu.Clear.lastQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and myHero.pos:DistanceTo(minion.pos) > myHero.range and Ready(_Q) then
				local Qdamage = getdmg("Q", minion)
				if Qdamage >= minion.health then
					Control.CastSpell(HK_Q, minion.pos)
				end	
            end
            if self.Menu.Clear.lastW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero.range and Ready(_W) then
                local Wdamage = getdmg("W", minion)
				if Wdamage >= minion.health then
					Control.CastSpell(HK_W, minion.pos)
				end	
            end
            if self.Menu.Clear.UseE ~= nil and self.Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and myHero.pos:DistanceTo(minion.pos) > myHero.range and Ready(_E) then
                local EPos, Count = self:ClearLogic()
				if self.passiveTracker >= 1 and Count >= self.Menu.Clear.EHit:Value() then
					Control.CastSpell(HK_E, EPos)
				end
            end
			local target = GetTarget(max_range)
			if target == nil then
				if self.Menu.Clear.lastR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and myHero.pos:DistanceTo(minion.pos) > myHero.range and self.stacks == 0 and Ready(_R) then
					local Rdamage = getdmg("R", minion)
					local EPos, Count = self:ClearLogic()	
					if Rdamage >= minion.health and Count >= self.Menu.Clear.RHit:Value() then
						Control.CastSpell(HK_R, minion)
					end
				end
            end
        end
    end
end

function Kassadin:JungleClear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.JClear.Mana == nil or (self.Menu.JClear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100))
            if self.Menu.JClear.UseQ ~= nil and self.Menu.JClear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
                Control.CastSpell(HK_Q, minion)
            end
            if self.Menu.JClear.UseW ~= nil and self.Menu.JClear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
                Control.CastSpell(HK_W, minion.pos)
            end
            if self.Menu.JClear.UseE ~= nil and self.Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and self.passiveTracker >= 1 and Ready(_E) then
                Control.CastSpell(HK_E, minion.pos)
            end
            if self.Menu.JClear.UseR ~= nil and self.Menu.JClear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end

function Kassadin:FullRKill()
	local target = GetTarget(2500)
	if target == nil then return end
		
	
	if IsValid(target, 2500) and myHero.pos:DistanceTo(target.pos) < 2500 and self.Menu.Combo.UseR:Value() and Ready(_R) then	
		local hp = target.health
		local dist = myHero.pos:DistanceTo(target.pos)
		local level = myHero:GetSpellData(_R).level
		local Fulldmg1 = CalcMagicalDamage(target,(({120, 150, 180})[level] + 0.5 * myHero.ap) + 0.03 * myHero.maxMana)
		local Fulldmg2 = CalcMagicalDamage(target,(({160, 200, 240})[level] + 0.6 * myHero.ap) + 0.04 * myHero.maxMana)
		local Fulldmg3 = CalcMagicalDamage(target,(({200, 250, 300})[level] + 0.7 * myHero.ap) + 0.05 * myHero.maxMana)
		local Fulldmg4 = CalcMagicalDamage(target,(({240, 300, 360})[level] + 0.8 * myHero.ap) + 0.06 * myHero.maxMana)
		local QWEdmg = getdmg("Q", target) + getdmg("W", target) + getdmg("E", target)
			
			
			if getdmg("R", target) > hp then
				if dist < 500 and self.stacks == 0 then 
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 1 then
				if Fulldmg1 > hp and dist < 500 then
				Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 2 then
				if Fulldmg2 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 3 then
				if Fulldmg3 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 4 then
				if Fulldmg4 > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end		
	-----------------------------------------------------	
			if (getdmg("R", target) + QWEdmg) > hp then
				if dist < 500 and self.stacks == 0 then 
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 1 then
				if (Fulldmg1 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end	
			if self.stacks == 2 then
				if (Fulldmg2 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 3 then
				if (Fulldmg3 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			if self.stacks == 4 then
				if (Fulldmg4 + QWEdmg) > hp and dist < 500 then
					Control.CastSpell(HK_R, target.pos)
				end
			end
			
	---------------------------------------------------------------
		local Full1 = Fulldmg1 + QWEdmg
		if getdmg("R", target) > target.health or Full1 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 1000 and myHero.pos:DistanceTo(target.pos) > 500 then
				Control.CastSpell(HK_R, target)
					
					
				
			end
		end	
		local Full2 = Fulldmg2 + QWEdmg			
		if getdmg("R", target) > target.health or Full2 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 1500 and myHero.pos:DistanceTo(target.pos) > 1000 then
				Control.CastSpell(HK_R, target)
					
					
				
			end
		end
		local Full3 = Fulldmg3 + QWEdmg			
		if getdmg("R", target) > target.health or Full3 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 2000 and myHero.pos:DistanceTo(target.pos) > 1500 then
				Control.CastSpell(HK_R, target)
					
				
				
			end
		end	
		local Full4 = Fulldmg4 + QWEdmg		
		if getdmg("R", target) > target.health or Full4 > target.health then
			if myHero.pos:DistanceTo(target.pos) < 2500 and myHero.pos:DistanceTo(target.pos) > 2000 then
				Control.CastSpell(HK_R, target)
					
					
			end
		end
	end
end

	
function Kassadin:Combo1()
	local target = GetTarget(2000)
	if target == nil then return end

if IsValid(target, 2000) and myHero.pos:DistanceTo(target.pos) < 2000 then 
	local hp = target.health
	local dist = myHero.pos:DistanceTo(target.pos)
	local qdmg = getdmg("Q", target) 		
	local wdmg = getdmg("W", target) 
	local edmg = getdmg("E", target) 
	local rdmg = getdmg("R", target) 


	if Ready(_Q) and self.Menu.Combo.UseQ:Value() then 
		if dist < 650 and qdmg > hp then
			Control.CastSpell(HK_Q, target.pos)
	
		end
	end
	if Ready(_E) and self.Menu.Combo.UseE:Value() then	
		if dist < 600 and edmg > hp and self.passiveTracker >= 1 then	
			Control.CastSpell(HK_E, target)
		
		end
	end

	if Ready(_E) and Ready(_Q) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() then	
		if dist < 600 and (qdmg+edmg) > hp then
	
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
		
		end
	end	
	
	if Ready(_Q) and Ready(_R) and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() then	
		if dist < 500 and (rdmg+qdmg) > hp then
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_Q, target.pos)
				
		end
	end
	if Ready(_E) and Ready(_Q) and Ready(_R) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() then	
		if dist < 500 and (qdmg+edmg+rdmg) > hp then	
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
				
		end
	end
	if Ready(_E) and Ready(_Q) and Ready(_R) and Ready(_W) and self.Menu.Combo.UseE:Value() and self.Menu.Combo.UseQ:Value() and self.Menu.Combo.UseR:Value() and self.Menu.Combo.UseW:Value() then	
		if dist < 500 and (qdmg+edmg+rdmg+wdmg) > hp then	
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_E, target)
			Control.CastSpell(HK_Q, target.pos)
			Control.CastSpell(HK_W)	
		end
	end
	local Killable = (qdmg > hp and Ready(_Q)), (edmg > hp and Ready(_E)), (rdmg+qdmg > hp and Ready(_Q)), (qdmg+edmg > hp and Ready(_Q) and Ready(_E)), (qdmg+edmg+rdmg > hp and Ready(_Q) and Ready(_E)), (qdmg+edmg+rdmg+wdmg > hp and Ready(_Q) and Ready(_E) and Ready(_W))
	if Ready(_R) and self.Menu.Combo.UseR:Value() then
		if Killable and dist > 650 and dist < 2000 then
			Control.CastSpell(HK_R, target)
				
		end
	end
end
end	

function OnDraw()

	local Spells = myHero:GetSpellData(_Q).level < 1  
	local textPos = myHero.pos:To2D()
	if foundAUnit and Spells then
		Draw.Text("Blockable Spell Found", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
	end
end



-------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Lux"




local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 70, Range = 1175, Speed = 1200, Collision = true, MaxCollision = 1, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
}

local EData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 310, Range = 1000, Speed = 1200, Collision = false
}

function Lux:__init()

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

function Lux:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Lux", name = "PussyLux"})

	--AutoQ
	self.Menu:MenuElement({type = MENU, id = "AutoQ", leftIcon = Icons["AutoQImmo"]})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto[Q]Immobile Target", value = true})

	--AutoW 
	self.Menu:MenuElement({type = MENU, id = "AutoW", leftIcon = Icons["AutoW"]})
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Auto[W]Ally+Self", value = true})
	self.Menu.AutoW:MenuElement({id = "Heal", name = "min Hp Ally or Self", value = 40, min = 0, max = 100, identifier = "%"})	

	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", leftIcon = Icons["AutoE"]})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]Immobile Target", value = true})	
		
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})			
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})			
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 4, min = 1, max = 6, step = 1})  		
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Light Binding", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Lucent Singularity", value = true})				
	self.Menu.ks:MenuElement({id = "UseR", name = "[R] Final Spark", value = true})	
	
	
	--JungleSteal
	self.Menu:MenuElement({type = MENU, id = "Jsteal", leftIcon = Icons["junglesteal"]})
	self.Menu.Jsteal:MenuElement({id = "Dragon", name = "AutoR Steal Dragon", value = true})
	self.Menu.Jsteal:MenuElement({id = "Baron", name = "AutoR Steal Baron", value = true})
	self.Menu.Jsteal:MenuElement({id = "Herald", name = "AutoR Steal Herald", value = true})	

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end	

function Lux:Tick()
	if MyHeroReady() then
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()

		elseif Mode == "Harass" then
			self:Harass()
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		end	
	self:JungleSteal()
	self:KillSteal()
	self:AutoQ()
	self:AutoE()
	self:AutoW()
	
	end
end

function Lux:NearestEnemy(entity)
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

function Lux:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 3340, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 1175, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 1000, 1, Draw.Color(225, 225, 125, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 1075, 1, Draw.Color(225, 225, 125, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
end

function Lux:AutoQ()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	if IsValid(target,1300) and myHero.pos:DistanceTo(target.pos) <= 1175 and IsImmobileTarget(target) and self.Menu.AutoQ.UseQ:Value() and Ready(_Q) then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end	
	end
end

local eMissile
local eParticle

function Lux:IsETraveling()
	return eMissile and eMissile.name and eMissile.name == "LuxLightStrikeKugel"
end

function Lux:IsELanded()
	return eParticle and eParticle.name and _find(eParticle.name, "E_tar_aoe_sound") --Lux_.+_E_tar_aoe_
end

function Lux:AutoE()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target,1300) and self:IsELanded() then
		if self:NearestEnemy(eParticle) < 310 then	
			Control.CastSpell(HK_E)
			eParticle = nil
		end	
	else		

		local eData = myHero:GetSpellData(_E)
		if eData.toggleState == 1 then

			if not self:IsETraveling() then
				for i = 1, Game.MissileCount() do
					local missile = Game.Missile(i)			
					if missle and missile.name == "LuxLightStrikeKugel" and HPred:IsInRange(missile.pos, myHero.pos, 400) then
						eMissile = missile
						break
					end
				end
			end
		elseif eData.toggleState == 2 then		
			for i = 1, Game.ParticleCount() do 
				local particle = Game.Particle(i)
				if particle and _find(particle.name, "E_tar_aoe_sound") then
					eParticle = particle
					break
				end
			end	
		end
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_E) and IsImmobileTarget(target) then
			if self.Menu.AutoE.UseE:Value() then
				Control.CastSpell(HK_E, target.pos)
				eMissile = nil

			end
		end
	end	
end

function Lux:AutoW()
	for i, ally in pairs(GetAllyHeroes()) do
		if self.Menu.AutoW.UseW:Value() and Ready(_W) then
			if myHero.health/myHero.maxHealth <= self.Menu.AutoW.Heal:Value()/100 and BaseCheck(myHero) == false then
				Control.CastSpell(HK_W)
			end
			if IsValid(ally,1300) and myHero.pos:DistanceTo(ally.pos) <= 1075 and ally.health/ally.maxHealth <= self.Menu.AutoW.Heal:Value()/100 and BaseCheck(myHero) == false then
				Control.CastSpell(HK_W, ally.pos)
			end
		end
	end
end


function Lux:Combo()
local target = GetTarget(1300)     	
if target == nil then return end
	if IsValid(target,1300) then
				
		if myHero.pos:DistanceTo(target.pos) <= 1175 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		if self.Menu.Combo.UseE:Value() and Ready(_E) then
			if self:IsELanded() then
				self:AutoE()
			elseif myHero.pos:DistanceTo(target.pos) <= 1000 then	
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then				
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			end
		end		
	end	
end	

function Lux:Harass()
local target = GetTarget(1300)
if target == nil then return end
	if IsValid(target,1300) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 1175 and self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if self.Menu.Harass.UseE:Value() and Ready(_E) then
			if self:IsELanded() then
				self:AutoE()
			elseif myHero.pos:DistanceTo(target.pos) <= 1000 then	
				local pred = GetGamsteronPrediction(target, EData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then				
					Control.CastSpell(HK_E, pred.CastPosition)
				end
			end
		end
	end
end

function Lux:Clear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
            if self.Menu.Clear.UseQ ~= nil and self.Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
            if self.Menu.Clear.UseW ~= nil and self.Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
                Control.CastSpell(HK_W, minion.pos)
            end
            if self.Menu.Clear.UseE ~= nil and self.Menu.Clear.UseE:Value() then
                if self:IsELanded() then
                    Control.CastSpell(HK_E)
                elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
                    local count = GetMinionCount(500, minion)
                    if count >= self.Menu.Clear.UseEM:Value() then
                        Control.CastSpell(HK_E, minion.pos)
                    end
                end
            end
            if self.Menu.Clear.UseR ~= nil and self.Menu.Clear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end

function Lux:JungleClear()
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
                Control.CastSpell(HK_W, minion.pos)
            end
            if self.Menu.JClear.UseE ~= nil and self.Menu.JClear.UseE:Value() then
                if self:IsELanded() then
                    Control.CastSpell(HK_E)
                elseif mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
                    Control.CastSpell(HK_E, minion.pos)
                end
            end
            if self.Menu.JClear.UseR ~= nil and self.Menu.JClear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end


local JungleTable = {
	SRU_Dragon_Water = "",
	SRU_Dragon_Fire = "",
	SRU_Dragon_Earth = "",
	SRU_Dragon_Air = "",
	SRU_Dragon_Elder = "",
}



function Lux:JungleSteal()
local minionlist = {}
	if _G.SDK then
		minionlist = _G.SDK.ObjectManager:GetMonsters(3500)
	elseif _G.GOS then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			
			if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 3340 then
				table.insert(minionlist, minion)
			end
		end
	end
	
	for i, minion in pairs(minionlist) do
	if minion == nil then return end	
	if minion.pos:DistanceTo(myHero.pos) < 3340 then
		local RDamage = getdmg("R", minion, myHero)	
		if self.Menu.Jsteal.Dragon:Value() and Ready(_R) then
			
			if JungleTable[minion.charName] and RDamage > minion.health then
				if minion.pos:To2D().onScreen then 		
					Control.CastSpell(HK_R, minion.pos) 
				
				elseif not minion.pos:To2D().onScreen then	
				local castPos = myHero.pos:Extended(minion.pos, 1000)    
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
		if self.Menu.Jsteal.Herald:Value() and Ready(_R) then

			if minion.charName == "SRU_RiftHerald" and RDamage > minion.health then
				if minion.pos:To2D().onScreen then 		
					Control.CastSpell(HK_R, minion.pos) 
				
				elseif not minion.pos:To2D().onScreen then	
				local castPos = myHero.pos:Extended(minion.pos, 1000)    
					Control.CastSpell(HK_R, castPos)
				end				
			end
		end
		if self.Menu.Jsteal.Baron:Value() and Ready(_R) then
			
			if minion.charName == "SRU_Baron" and RDamage > minion.health then
				if minion.pos:To2D().onScreen then 		
					Control.CastSpell(HK_R, minion.pos) 
				
				elseif not minion.pos:To2D().onScreen then	
				local castPos = myHero.pos:Extended(minion.pos, 1000)    
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	end
	end
end

function Lux:DMGJng()
    local level = myHero:GetSpellData(_R).level
    local rdamage = (({900, 1100, 1400})[level] + 0.75 * myHero.ap)
	return rdamage
end
function Lux:DMGBaron()
    local level = myHero:GetSpellData(_R).level
    local rdamage = (({900, 1100, 1900})[level] + 0.75 * myHero.ap)
	return rdamage
end

function Lux:KillSteal()
	local target = GetTarget(3500)     	
	if target == nil then return end
	
	
	if IsValid(target,3500) then	
		local hp = target.health
		if myHero.pos:DistanceTo(target.pos) <= 1175 and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= hp then
				self:KillstealQ()
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 1000 and Ready(_E) then
			local EDmg = getdmg("E", target, myHero)
			if EDmg >= hp then
				self:KillstealE()
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 3340 and Ready(_R) then
			local RDmg = getdmg("R", target, myHero) 
			local RDmg2 = getdmg("R", target, myHero) + (10 + 10 * myHero.levelData.lvl + myHero.ap * 0.2)
			if HPred:HasBuff(target, "LuxIlluminatingFraulein",1.25) and RDmg2 >= hp then    
				self:KillstealR()
			end
			if RDmg >= hp then
				self:KillstealR()
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 1175 and Ready(_R) and Ready(_Q) then
			local RDmg = getdmg("R", target, myHero)
			local QDmg = getdmg("Q", target, myHero)
			local QRDmg = QDmg + RDmg
			if QRDmg >= hp then
				self:KillstealQ()
			end	
		end
	end
end	

function Lux:KillstealQ()
	local target = GetTarget(1300)
	if target == nil then return end
	if IsValid(target,1300) and myHero.pos:DistanceTo(target.pos) <= 1175 then 	
		if self.Menu.ks.UseQ:Value() then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			
			end
		end
	end
end

function Lux:KillstealE()
	local target = GetTarget(1300)
	if target == nil then return end
	if IsValid(target,1300) and myHero.pos:DistanceTo(target.pos) <= 1000 and self.Menu.ks.UseE:Value() then
		Control.CastSpell(HK_E, target.pos)
			
		
	end
end

function Lux:KillstealR()
    local target = GetTarget(3400)
	if target == nil then return end
	if IsValid(target,3400) and myHero.pos:DistanceTo(target.pos) <= 3340 then	
		if self.Menu.ks.UseR:Value() then
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 3340, 1.0, 1000, 190, false)
			if hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 		
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)    
					Control.CastSpell(HK_R, castPos)
				end		
			end
		end
	end
end




-------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Malzahar"




local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 1.0, Radius = 85, Range = 900, Speed = 3200, Collision = false
}

function Malzahar:__init()

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

function Malzahar:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Malzahar", name = "PussyMalzahar"})

	--AutoQ
	self.Menu:MenuElement({type = MENU, id = "AutoQ", leftIcon = Icons["AutoQImmo"]})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})		
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})			
	self.Menu.Combo:MenuElement({id = "UseR", name = "[R] Nether Grasp", value = false})	
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 2, min = 1, max = 6})  	
	self.Menu.Clear:MenuElement({id = "hp", name = "Use[E] if MinionHP less then", value = 50, min = 1, max = 100, identifier = "%"})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Void Swarm", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Call of the Void", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Malefic Visions", value = true})	
	self.Menu.ks:MenuElement({id = "UseW", name = "[W] Malefic Visions", value = true})			
	self.Menu.ks:MenuElement({id = "UseR", name = "[R] Void Swarm", value = true})
	self.Menu.ks:MenuElement({id = "full", name = "Full Combo", value = true})

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Malzahar:IsRCharging()
	return myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "MalzaharR"
end

function Malzahar:Tick()
self:ActiveUlt()	
if self:IsRCharging() then return end
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
	self:AutoQ()
	
	
	end
end 

function Malzahar:AutoQ()
local target = GetTarget(1000)     	
if target == nil then return end	
local pred = GetGamsteronPrediction(target, QData, myHero)	
	if IsValid(target,1000) and myHero.pos:DistanceTo(target.pos) <= 900 and IsImmobileTarget(target) and self.Menu.AutoQ.UseQ:Value() and Ready(_Q) then
		if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end	
	end
end

function Malzahar:Draw()
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

function Malzahar:ActiveUlt()
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "MalzaharR" then	
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)	
	else
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end
end
       
function Malzahar:KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end
 

	if IsValid(target,1000) and myHero.pos:DistanceTo(target.pos) <= 900 then
		local ready = Ready(_Q) and Ready(_E) and Ready(_W) and Ready(_R)
		local hp = target.health
		local QDmg = getdmg("Q", target, myHero)
		local EDmg = getdmg("E", target, myHero)
		local WDmg = getdmg("W", target, myHero)
		local RDmg = (getdmg("R", target, myHero) + getdmg("R", target, myHero, 2))	
		local fullDmg = (QDmg + EDmg + WDmg + RDmg)
	
		
		if myHero.pos:DistanceTo(target.pos) <= 900 and QDmg >= hp and self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 650 and EDmg >= hp then	
			if self.Menu.ks.UseE:Value() and Ready(_E) then
				Control.CastSpell(HK_E, target)
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 650 and WDmg >= hp then	
			if self.Menu.ks.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, target.pos)
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 700 and RDmg >= hp then	
			if self.Menu.ks.UseR:Value() and Ready(_R) then
				Control.CastSpell(HK_R, target)	
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 700 and fullDmg >= hp then	
			if self.Menu.ks.full:Value() and ready then
				self:KsFull(target)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 700 and RDmg >= hp and self.Menu.ks.full:Value() and Ready(_R) then
			Control.CastSpell(HK_R, target)
		end
	end
end	

function Malzahar:KsFull(target)
	local pred = GetGamsteronPrediction(target, QData, myHero)
	
	if myHero.pos:DistanceTo(target.pos) <= 650 then
		Control.CastSpell(HK_E, target)
	end	
	if myHero.pos:DistanceTo(target.pos) <= 900 and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then 
		Control.CastSpell(HK_Q, pred.CastPosition)
	end	
	if myHero.pos:DistanceTo(target.pos) <= 650 then
		Control.CastSpell(HK_W, target.pos)
	end	
end
				

function Malzahar:Combo()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target,1000) then

		if myHero.pos:DistanceTo(target.pos) <= 650 then 	
			if self.Menu.Combo.UseW:Value() and Ready(_W) then
				Control.CastSpell(HK_W, target.pos) 
			end
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 900 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 650 then	
			if self.Menu.Combo.UseE:Value() and Ready(_E) then			
				Control.CastSpell(HK_E, target)
	
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 700 then	
			if Ready(_R) and self.Menu.Combo.UseR:Value() then
				Control.CastSpell(HK_R, target)
			end
		end
	end
	if self:IsRCharging() then	
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)	
	end
	
	_G.SDK.Orbwalker:SetMovement(true)
	_G.SDK.Orbwalker:SetAttack(true)	
end	

function Malzahar:Harass()
local target = GetTarget(1000)
if target == nil then return end
	if IsValid(target,1000) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 900 and self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 650 then	
			if self.Menu.Harass.UseE:Value() and Ready(_E) then			
				Control.CastSpell(HK_E, target)
	
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 650 then	
			if self.Menu.Harass.UseW:Value() and Ready(_W) then			
				Control.CastSpell(HK_W, target.pos)
	
			end
		end
	end
end	

function Malzahar:Clear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
            if self.Menu.Clear.UseQ ~= nil and self.Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
                Control.CastSpell(HK_Q, minion.pos)
            end
            if self.Menu.Clear.UseW ~= nil and self.Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
                Control.CastSpell(HK_W, minion.pos)
            end
            if self.Menu.Clear.UseE ~= nil and self.Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
				local count = GetMinionCount(650, minion)
				if minion.health/minion.maxHealth <= self.Menu.Clear.hp:Value()/100 and count >= self.Menu.Clear.UseEM:Value() then	
					Control.CastSpell(HK_E, minion)
				end	
            end
            if self.Menu.Clear.UseR ~= nil and self.Menu.Clear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end

function Malzahar:JungleClear()
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
                Control.CastSpell(HK_W, minion.pos)
            end
            if self.Menu.JClear.UseE ~= nil and self.Menu.JClear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
                Control.CastSpell(HK_E, minion)
            end
            if self.Menu.JClear.UseR ~= nil and self.Menu.JClear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------







class "Neeko"



function Neeko:__init()

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


function Neeko:LoadSpells()
	
	Q = {range = 800, width = 225, delay = 0.25, speed = 500, collision = false}    
	E = {range = 1000, width = 70, delay = 0.25, speed = 1300, collision = false}   


end

function Neeko:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Neeko", name = "PussyNeeko"})

	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", leftIcon = Icons["AutoE"]})	
	self.Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E] 2-5 Targets", value = true})	
 
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})	
	self.Menu.Combo:MenuElement({id = "PredQ", name = "HitChance[Q] [1]=low [5]=high", value = 1, min = 1, max = 5})	
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.Combo:MenuElement({id = "PredE", name = "HitChance[E] [1]=low [5]=high", value = 2, min = 1, max = 5})	
	--UltSettings
	self.Menu.Combo:MenuElement({type = MENU, id = "Ult", name = "Ultimate Settings"})
	--[W]+[R]
	self.Menu.Combo.Ult:MenuElement({type = MENU, id = "WR", name = "Check NeekoRange"})	
	self.Menu.Combo.Ult.WR:MenuElement({id = "UseR", name = "[R]+[W]", value = true, tooltip = "If [W] not Ready then only [R]"})
 	self.Menu.Combo.Ult.WR:MenuElement({id = "RHit", name = "min. Targets", value = 2, min = 1, max = 5})	
	--Ult Ally Range
	self.Menu.Combo.Ult:MenuElement({type = MENU, id = "Ally", name = "Check AllyRange"})
	self.Menu.Combo.Ult.Ally:MenuElement({id = "UseR2", name = "Flash+[R]+[W] 2-5Targets", value = true, tooltip = "Check Enemys in Ally Range"})
	--Ult Immobile
	self.Menu.Combo.Ult:MenuElement({type = MENU, id = "Immo", name = "Ult Immobile"})	
	self.Menu.Combo.Ult.Immo:MenuElement({id = "UseR3", name = "Flash+[R]+[W]", value = true, tooltip = "Check Immobile Targets"})
 	self.Menu.Combo.Ult.Immo:MenuElement({id = "UseR3M", name = "min. Immobile Targets", value = 2, min = 1, max = 5})
	--Ult 1vs1
	self.Menu.Combo.Ult:MenuElement({type = MENU, id = "One", name = "1vs1"})	
	self.Menu.Combo.Ult.One:MenuElement({id = "UseR1", name = "[R]+[W] If Killable", value = true, tooltip = "If [W] not Ready then only [R]"})	
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({type = MENU, id = "LH", name = "LastHit"})	
	self.Menu.Harass.LH:MenuElement({id = "UseQL", name = "LastHit[Q] Minions", value = true, tooltip = "There is no Enemy nearby"})	
	self.Menu.Harass.LH:MenuElement({id = "UseQLM", name = "min. Minions", value = 2, min = 1, max = 6})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})
	self.Menu.Harass:MenuElement({id = "PredQ", name = "HitChance[Q] [1]=low [5]=high", value = 1, min = 1, max = 5})	
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.Harass:MenuElement({id = "PredE", name = "HitChance[E] [1]=low [5]=high", value = 2, min = 1, max = 5})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQL", name = "LastHit[Q] Blooming Burst", value = true})	
	self.Menu.Clear:MenuElement({id = "UseQLM", name = "LastHit[Q] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})  
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 3, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Blooming Burst", value = true})
	self.Menu.ks:MenuElement({id = "PredQ", name = "HitChance[Q] [1]=low [5]=high", value = 1, min = 1, max = 5})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Tangle-Barbs", value = true})
	self.Menu.ks:MenuElement({id = "PredE", name = "HitChance[E] [1]=low [5]=high", value = 2, min = 1, max = 5})	
	self.Menu.ks:MenuElement({id = "UseEQ", name = "[E]+[Q]", value = true})

	
	--Activator
	self.Menu:MenuElement({type = MENU, id = "a", leftIcon = Icons["Activator"]})		
	self.Menu.a:MenuElement({id = "ON", name = "Protobelt all UltSettings", value = true, tooltip = "Free Flash"})	


	--EscapeMenu
	self.Menu:MenuElement({type = MENU, id = "evade", leftIcon = Icons["Escape"]})	
	self.Menu.evade:MenuElement({id = "UseW", name = "Auto[W] Spawn Clone", value = true})
	self.Menu.evade:MenuElement({id = "Min", name = "Min Life to Spawn Clone", value = 30, min = 0, max = 100, identifier = "%"})	
	self.Menu.evade:MenuElement({id = "gank", name = "Auto[W] Spawn Clone Incomming Gank", value = true})
	
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})
end

function Neeko:Tick()
	if MyHeroReady() then
	
	local Mode = GetMode()
		if Mode == "Combo" then
			self:Combo()
			self:checkUltSpell()
			self:AutoR()
			self:AutoR1()
		elseif Mode == "Harass" then
			self:Harass()
			for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local target = GetTarget(1000)
				if target == nil then	
					if minion.team == TEAM_ENEMY and IsValid(minion,1000) and myHero.pos:DistanceTo(minion.pos) <= 800 and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then	
						local count = GetMinionCount(225, minion)			
						local hp = minion.health
						local level = myHero:GetSpellData(_Q).level
						local QDmg = ({70,115,160,205,250})[level] + 0.5 * myHero.ap
						if self.Menu.Harass.LH.UseQL:Value() and Ready(_Q) and minion.health <= QDmg and count >= self.Menu.Harass.LH.UseQLM:Value() then
							Control.CastSpell(HK_Q, minion)
						end	 
					end
				end
			end
		elseif Mode == "Clear" then
			self:Clear()
			self:JungleClear()
		elseif Mode == "Flee" then
		
		end	
		self:EscapeW()
		self:KillSteal()
		self:GankW()
		self:AutoE()
	end
end 


function Neeko:Draw()
local textPos = myHero.pos:To2D()	


if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 600, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawing.DrawE:Value()) and Ready(_E) then
    Draw.Circle(myHero, 1000, 1, Draw.Color(225, 225, 125, 10))
	end
	local target = GetTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Drawing.Kill:Value() and not target.dead then
	local hp = target.health	
		if Ready(_Q) and getdmg("Q", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_E) and getdmg("E", target) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
		if Ready(_E) and Ready(_Q) and (getdmg("E", target) + getdmg("Q", target)) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end
	end
	
end

			
function Neeko:AutoE()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target,1000) and myHero.pos:DistanceTo(target.pos) <= 1000 and self.Menu.AutoE.UseE:Value() and Ready(_E) then	
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		local targetCount = HPred:GetLineTargetCount(myHero.pos, aimPosition, E.delay, E.speed, E.width, false)	
		if hitRate and hitRate >= 1 and targetCount >= 2 then
			Control.CastSpell(HK_E, aimPosition)
		end
	end
end


function Neeko:checkUltSpell()
local target = GetTarget(1500)     	
if target == nil then return end

if IsValid(target,1000) then
	local Protobelt = GetItemSlot(myHero, 3152)		
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
		if  Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt1()
			self:Immo1()
			self:Proto()
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
		if Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt1()
			self:Immo1()
			self:Proto()	
		end	
	end

	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
		if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt2()
			self:Immo2()
			self:Proto()	
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
		if  Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt2()
			self:Immo2()
			self:Proto()	
		end	
	end
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
		if  Ready(_R) and Ready(_W) and (Protobelt > 0 and not Ready(Protobelt) or Protobelt == 0) then
			self:AutoUlt3()
			self:Immo3()
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
		if  Ready(_R) and Ready(_W) and (Protobelt > 0 and not Ready(Protobelt) or Protobelt == 0) then
			self:AutoUlt3()
			self:Immo3()
		end	
	end
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and not Ready(SUMMONER_1) then
		if  Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt4()
			self:Immo4()
			self:Proto()	
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and not Ready(SUMMONER_2) then
		if Ready(_R) and Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt4()
			self:Immo4()
			self:Proto()	
		end	
	end	
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and not Ready(SUMMONER_1) then
		if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt5()
			self:Immo5()
			self:Proto()	
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and not Ready(SUMMONER_2) then
		if Ready(_R) and not Ready(_W) and Protobelt > 0 and Ready(Protobelt) then
			self:AutoUlt5()
			self:Immo5()
			self:Proto()	
		end	
	end	
	
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" and Ready(SUMMONER_1) then
		if Ready(_R) and not Ready(_W) and (Protobelt > 0 and not Ready(Protobelt)) or Protobelt == 0 then
			self:AutoUlt6()
			self:Immo6()
		end
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" and Ready(SUMMONER_2) then
		if Ready(_R) and not Ready(_W) and (Protobelt > 0 and not Ready(Protobelt)) or Protobelt == 0 then
			self:AutoUlt6()
			self:Immo6()
		end	
	end	
end	
end


function Neeko:KillSteal()
if myHero.dead then return end	
	local target = GetTarget(1100)     	
	if target == nil then return end
		
	if IsValid(target,1100) and myHero.pos:DistanceTo(target.pos) <= 800 then
		local QDmg = getdmg("Q", target, myHero)
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.ks.UseQ:Value() and Ready(_Q) and QDmg >= target.health and hitRate and hitRate >= self.Menu.ks.PredQ:Value() then
			Control.CastSpell(HK_Q, aimPosition)
		end
	end	
	if IsValid(target,1100) and myHero.pos:DistanceTo(target.pos) <= 1000 then
		local EDmg = getdmg("E", target, myHero)
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		if self.Menu.ks.UseE:Value() and Ready(_E) and EDmg >= target.health and hitRate and hitRate >= self.Menu.ks.PredE:Value() then
				Control.CastSpell(HK_E, aimPosition)
		end
	end	
	if IsValid(target,1100) and myHero.pos:DistanceTo(target.pos) <= 800 then	
		local EDmg = getdmg("E", target, myHero)
		local hitRateE, aimPositionE = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		local hitRateQ, aimPositionQ = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.ks.UseEQ:Value() and Ready(_E) and Ready(_Q) and (EDmg + QDmg) >= target.health and hitRateE and hitRateQ and hitRateE >= self.Menu.ks.PredE:Value() and hitRateQ >= self.Menu.ks.PredQ:Value() then
			Control.CastSpell(HK_E, aimPositionE)
			Control.CastSpell(HK_Q, aimPositionQ)
		
		end
	end
end	


function Neeko:EscapeW()  
	local target = GetTarget(1500)
	if target == nil then return end
	if IsValid(target,1500) and myHero.pos:DistanceTo(target.pos) <= 1000 then
	local hp = myHero.health
		if hp <= self.Menu.evade.Min:Value() and self.Menu.evade.UseW:Value() and Ready(_W) then
			local attackFalse = _G.SDK.Orbwalker:SetAttack(false)
			local attackTrue = _G.SDK.Orbwalker:SetAttack(true)
			local MPos = myHero.pos:Shortened(target.pos, 1000)
			DelayAction(attackFalse,0)
			Control.SetCursorPos(MPos)
			Control.KeyDown(HK_W)
			Control.KeyUp(HK_W)
			DelayAction(attackTrue, 0.2)
		end
	end
end	

function Neeko:GankW()  
	local target = GetTarget(1500)
	if target == nil then return end
	if IsValid(target,1500) and myHero.pos:DistanceTo(target.pos) <= 1500 then
		if self.Menu.evade.gank:Value() and Ready(_W) then
			local targetCount = CountEnemiesNear(myHero, 1000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount > 1 and allyCount == 0 then
				local attackFalse = _G.SDK.Orbwalker:SetAttack(false)
				local attackTrue = _G.SDK.Orbwalker:SetAttack(true)
				local MPos = myHero.pos:Shortened(target.pos, 1000)
				DelayAction(attackFalse,0)
				Control.SetCursorPos(MPos)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
				DelayAction(attackTrue, 0.2)				
			end
		end
	end
end	


function Neeko:AutoR()
local target = GetTarget(1000)
if target == nil then return end

local Protobelt = GetItemSlot(myHero, 3152)	
	if IsValid(target,1000) and myHero.pos:DistanceTo(target.pos) < 400 and self.Menu.Combo.Ult.WR.UseR:Value() and self.Menu.a.ON:Value() then
		if Ready(_R) and Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero, 600)
			if targetCount >= self.Menu.Combo.Ult.WR.RHit:Value() then
				SetAttack(false)
				Control.CastSpell(HK_W)
				self:Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)				
			end
			
		elseif Ready(_R) and not Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then	
			local targetCount = CountEnemiesNear(myHero, 600)
			if targetCount >= self.Menu.Combo.Ult.WR.RHit:Value() then
				SetAttack(false)
				self:Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		
		elseif Ready(_R) and Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero, 600)
			if targetCount >= self.Menu.Combo.Ult.WR.RHit:Value() then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)				
			end
			
		elseif Ready(_R) and not Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then	
			local targetCount = CountEnemiesNear(myHero, 600)
			if targetCount >= self.Menu.Combo.Ult.WR.RHit:Value() then
				SetAttack(false)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end			
		end
	end
end

			
	

function Neeko:AutoR1()
local target = GetTarget(2000)
if target == nil then return end
local hp = target.health
local RDmg = getdmg("R", target, myHero)
local QDmg = getdmg("Q", target, myHero)
local EDmg = getdmg("E", target, myHero)
local Protobelt = GetItemSlot(myHero, 3152)	
	if IsValid(target,500) then
		
		if self.Menu.Combo.Ult.One.UseR1:Value() and self.Menu.a.ON:Value() and Ready(_R) and Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero, 2000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount <= 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 400 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_W)
				self:Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		elseif self.Menu.Combo.Ult.One.UseR1:Value() and self.Menu.a.ON:Value() and Ready(_R) and not Ready(_W) and ((Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero, 2000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount <= 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 400 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				self:Proto()
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end	
		elseif self.Menu.Combo.Ult.One.UseR1:Value() and self.Menu.a.ON:Value() and Ready(_R) and Ready(_W) and ((not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero, 2000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount <= 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 300 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		elseif self.Menu.Combo.Ult.One.UseR1:Value() and self.Menu.a.ON:Value() and Ready(_R) and not Ready(_W) and (( not Ready(Protobelt) and Protobelt > 0) or (Protobelt == 0)) then
			local targetCount = CountEnemiesNear(myHero, 2000)
			local allyCount = GetAllyCount(1500, myHero)
			if targetCount <= 1 and allyCount == 0 and myHero.pos:DistanceTo(target.pos) <= 300 and hp < (RDmg+QDmg+EDmg) then
				SetAttack(false)
				Control.CastSpell(HK_R)	
				DelayAction(function()SetAttack(true) end, 0.3)
			end			
		end
	end
end

			--Hextech Protobelt
function Neeko:Proto()	
if myHero.dead then return end	
	local target = GetTarget(1000)
	if target == nil then return end
	local Protobelt = GetItemSlot(myHero, 3152)
	if IsValid(target,600) and self.Menu.a.ON:Value() then
		if myHero.pos:DistanceTo(target.pos) < 500 and Protobelt > 0 and Ready(Protobelt)  then	
			Control.CastSpell(ItemHotKey[Protobelt], target)
			CastSpell(ItemHotKey[Protobelt], target, 2.0)
		end
	end
end	


function Neeko:AutoUlt1() --full
	local target = GetTarget(1400)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,900) then
		local targetCount = CountEnemiesNear(ally, 600)	
			if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 800 and myHero.pos:DistanceTo(ally.pos) >= 300 then	
				if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, ally.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, ally.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
					end	
				end
			end
		end
	end
end

function Neeko:AutoUlt2()   --no[W]
	local target = GetTarget(1400)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,900) then
		local targetCount = CountEnemiesNear(ally, 600)		
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 800 and myHero.pos:DistanceTo(ally.pos) >= 300 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, ally.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, ally.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
					end	
				end
			end
		end
	end
end

function Neeko:AutoUlt3() --noProtobelt
	local target = GetTarget(1200)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,500) then
		local targetCount = CountEnemiesNear(ally, 600)		
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 500 and myHero.pos:DistanceTo(ally.pos) >= 200 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, ally.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, ally.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
					end	
				end
			end
		end
	end
end

function Neeko:AutoUlt4()  --noFlash
	local target = GetTarget(1200)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,500) then
		local targetCount = CountEnemiesNear(ally, 600)		
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 400 and myHero.pos:DistanceTo(ally.pos) >= 100 then
					SetAttack(false)
					Control.CastSpell(HK_W)
					Control.CastSpell(HK_R)
					DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end



function Neeko:AutoUlt5()  --noFlash, no[W]
	local target = GetTarget(1200)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do	
		if IsValid(ally,500) then
		local targetCount = CountEnemiesNear(ally, 600)	
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 400 and myHero.pos:DistanceTo(ally.pos) >= 100 then
					SetAttack(false)
					Control.CastSpell(HK_R)
					DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end

function Neeko:AutoUlt6() --noProtobelt, no[W]
	local target = GetTarget(1200)
	if target == nil then return end

	for i,ally in pairs(GetAllyHeroes()) do
		if IsValid(ally,500) then
		local targetCount = CountEnemiesNear(ally, 600)		
			if self.Menu.Combo.Ult.Ally.UseR2:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
				if targetCount >= 2 and myHero.pos:DistanceTo(ally.pos) <= 400 and myHero.pos:DistanceTo(ally.pos) >= 200 then
					if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, ally.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
					elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, ally.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
					end	
				end
			end
		end    
	end
end

	
function Neeko:Immo1() --full
	local target = GetTarget(1400)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,900) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 800 and myHero.pos:DistanceTo(target.pos) >= 300 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, target.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, target.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end

function Neeko:Immo2() --no[W]
	local target = GetTarget(1400)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,900) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then		
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 800 and myHero.pos:DistanceTo(target.pos) >= 300 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, target.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, target.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end

function Neeko:Immo3() --noProtobelt
	local target = GetTarget(1200)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,500) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 500 and myHero.pos:DistanceTo(target.pos) >= 200 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, target.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, target.pos)
						Control.CastSpell(HK_W)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end

function Neeko:Immo4() --noFlash
	local target = GetTarget(1100)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,500) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 400 and myHero.pos:DistanceTo(target.pos) >= 100 then
				SetAttack(false)
				Control.CastSpell(HK_W)
				Control.CastSpell(HK_R)
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		end
	end
end

function Neeko:Immo5() --noFlash, no[W]
	local target = GetTarget(1100)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,500) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then		
		if self.Menu.Combo.Ult.Immo.UseR3:Value()  --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 400 and myHero.pos:DistanceTo(target.pos) >= 100 then
				SetAttack(false)
				Control.CastSpell(HK_R)
				DelayAction(function()SetAttack(true) end, 0.3)
			end
		end
	end
end

function Neeko:Immo6() --noProtobelt, no[W]
	local target = GetTarget(1200)
	if target == nil then return end
	local targetCount = GetImmobileCount(600, target.pos)
	if IsValid(target,500) and targetCount >= self.Menu.Combo.Ult.Immo.UseR3M:Value() then			
		if self.Menu.Combo.Ult.Immo.UseR3:Value() --[[and GetAllyCount(1500, myHero) >= CountEnemiesNear(myHero.pos, 2000)]] then
			if myHero.pos:DistanceTo(target.pos) <= 500 and myHero.pos:DistanceTo(target.pos) >= 200 then
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_1, target.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
						SetAttack(false)
						Control.CastSpell(HK_SUMMONER_2, target.pos)
						Control.CastSpell(HK_R)
						DelayAction(function()SetAttack(true) end, 0.3)
				end
			end
		end
	end
end
	
	
	
function Neeko:Combo()
	local target = GetTarget(1100)
	if target == nil then return end
	if IsValid(target,1000) then
		local hitRateE, aimPositionE = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		if self.Menu.Combo.UseE:Value() and Ready(_E) and hitRateE and hitRateE >= self.Menu.Combo.PredE:Value() and myHero.pos:DistanceTo(target.pos) <= 1000 then			
			Control.CastSpell(HK_E, aimPositionE)
		
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) <= 800 and hitRate and hitRate >= self.Menu.Combo.PredQ:Value() then 
			Control.CastSpell(HK_Q, aimPosition)
		end
		end
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.Combo.UseQ:Value() and Ready(_Q) and not Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 800 and hitRate and hitRate >= self.Menu.Combo.PredQ:Value() and not IsImmobileTarget(target) then
			Control.CastSpell(HK_Q, aimPosition)
		end	
	end
end

	
		

function Neeko:Harass()	
	local target = GetTarget(800)
	if target == nil then return end	
	if IsValid(target,900)  and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then
		local hitRateE, aimPositionE = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.width, E.collision)
		if Ready(_E) and Ready(_Q) and hitRateE and hitRateE >= self.Menu.Harass.PredE:Value() and myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.Harass.UseE:Value() then
			Control.CastSpell(HK_E, aimPositionE)
			
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and hitRate and hitRate >= self.Menu.Harass.PredQ:Value() then	
			Control.CastSpell(HK_Q, aimPosition)
		end
		end
		
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.width, Q.collision)
		if self.Menu.Harass.UseQ:Value() and Ready(_Q) and not Ready(_E) and myHero.pos:DistanceTo(target.pos) <= 800 and hitRate and hitRate >= self.Menu.Harass.PredQ:Value() then
			Control.CastSpell(HK_Q, aimPosition)
		end
	end
end

function Neeko:Clear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
            if self.Menu.Clear.UseQL:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
                local count = GetMinionCount(225, minion)
				local level = myHero:GetSpellData(_Q).level
				local QDmg = ({70,115,160,205,250})[level] + 0.5 * myHero.ap
				if count >= self.Menu.Clear.UseQLM:Value() and minion.health <= QDmg then	
					Control.CastSpell(HK_Q, minion.pos)
				end	
            end
            if self.Menu.Clear.UseW ~= nil and self.Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
                Control.CastSpell(HK_W, minion.pos)
            end
            if self.Menu.Clear.UseE ~= nil and self.Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
                local count = GetMinionCount(1000, myHero)
				if count >= self.Menu.Clear.UseEM:Value() then	
					Control.CastSpell(HK_E, minion.pos)
				end	
            end
            if self.Menu.Clear.UseR ~= nil and self.Menu.Clear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end

function Neeko:JungleClear()
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
                Control.CastSpell(HK_W, minion.pos)
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



----------------------------------------------------------------------------------------------------------------------------------------------------------

class "Ryze"



local QData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 50, Range = 1000, Speed = 1700, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
}

function Ryze:__init()

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

function Ryze:LoadMenu()
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Ryze", name = "PussyRyze"})
	--ComboMenu
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Combo:MenuElement({id = "Type", name = "Combo Logic", value = 2,drop = {"Mark E then Q,W", "Mark E then W,Q"}})	

	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
	
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[E]+[Q] kill Minion", value = true})
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})
	
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "KillSteal", leftIcon = Icons["ks"]})
	self.Menu.KillSteal:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.KillSteal:MenuElement({id = "UseW", name = "[W]", value = true})
	self.Menu.KillSteal:MenuElement({id = "UseE", name = "[E]", value = true})
	
	--AutoSpell on CC
	self.Menu:MenuElement({id = "CC", leftIcon = Icons["AutoEW"], type = MENU})
	self.Menu.CC:MenuElement({id = "UseEW", name = "AutoE+W on CC", value = true})
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	

	--Drawing
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw[Q]", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw[W]", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw[E]", value = true})	
	
end

function Ryze:Tick()
	if MyHeroReady() then
	self:KS()
	self:CC()

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
	end
end
	

function Ryze:Draw()
  if myHero.dead then return end
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 1000, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawW:Value() and Ready(_W) then
    Draw.Circle(myHero, 615, 1, Draw.Color(225, 225, 0, 10))
	end
	if self.Menu.Drawing.DrawE:Value() and Ready(_E) then
    Draw.Circle(myHero, 615, 1, Draw.Color(225, 225, 0, 10))
	end
	local textPos = myHero.pos:To2D()	
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
end	

function Ryze:Combo()
	
	if self.Menu.Combo.Type:Value() == 1 then
		self:ComboEQW()
	end	
	
	if self.Menu.Combo.Type:Value() == 2 then
		self:ComboEWQ()
	end
	
	if not Ready(_E) then
		self:ComboQ()
		self:ComboW()
	end	
	
end

function Ryze:ComboEQW()
local target = GetTarget(1200)
if target == nil then return end
if IsValid(target, 1200) and myHero.pos:DistanceTo(target.pos) <= 615 then    
	if self.Menu.Combo.UseE:Value() and Ready(_E) then
		Control.CastSpell(HK_E,target)
		self:ComboQ()
		self:ComboW()
		
    end
end
end	

function Ryze:ComboEWQ()
local target = GetTarget(1200)
if target == nil then return end
if IsValid(target, 1200) and myHero.pos:DistanceTo(target.pos) <= 615 then    
	if self.Menu.Combo.UseE:Value() and Ready(_E) then
		Control.CastSpell(HK_E,target)
		self:ComboW()
		self:ComboQ()		
		
    end
end
end	
	
function Ryze:ComboQ()	
local target = GetTarget(1200)
if target == nil then return end
if IsValid(target, 1200) and myHero.pos:DistanceTo(target.pos) <= 1000 then    
local pred = GetGamsteronPrediction(target, QData, myHero)	
	if self.Menu.Combo.UseQ:Value() and Ready(_Q) then
		if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			if GotBuff(target, "RyzeE") then
				Control.CastSpell(HK_Q,pred.CastPosition)
			end	
			if not Ready(_E) then
				Control.CastSpell(HK_Q,pred.CastPosition)
			end
		end
	end
end
end	

	
function Ryze:ComboW()	
local target = GetTarget(700)
if target == nil then return end
if IsValid(target, 700) and myHero.pos:DistanceTo(target.pos) <= 615 then 	
	if self.Menu.Combo.UseW:Value() and Ready(_W) then
		Control.CastSpell(HK_W,target)
            
	end
end
end

function Ryze:Harass()
local target = GetTarget(1200)
if target == nil then return end
if IsValid(target, 1100) and myHero.pos:DistanceTo(target.pos) <= 1000 and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value()/100 then
	if self.Menu.Harass.UseQ:Value() and Ready(_Q) then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q,pred.CastPosition)
		    
	    end
    end
end
end

function Ryze:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	
		if minion.team == TEAM_ENEMY and IsValid(minion,1100) and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 then
			if myHero.pos:DistanceTo(minion.pos) <= 615 and self.Menu.Clear.UseQ:Value() and Ready(_E) then
				Control.CastSpell(HK_E,minion)
			end			
			
			if myHero.pos:DistanceTo(minion.pos) <= 1000 and self.Menu.Clear.UseQ:Value() and Ready(_Q) then
				local Qdmg = getdmg("Q", minion, myHero)
				if Qdmg >= minion.health then
					Control.CastSpell(HK_Q,minion)
				end
			end
		end
	end
end

function Ryze:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
		if minion.team == TEAM_JUNGLE and IsValid(minion,1100) and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then
			if myHero.pos:DistanceTo(minion.pos) <= 1000 and self.Menu.JClear.UseQ:Value() and Ready(_Q) then
				Control.CastSpell(HK_Q,minion)
				
			end
		end
	end
end	

function Ryze:KS()
local target = GetTarget(1200)
if target == nil then return end

if IsValid(target, 1200) and myHero.pos:DistanceTo(target.pos) <= 1000 then    
	if self.Menu.KillSteal.UseQ:Value() and Ready(_Q) then
	    local Qdmg = getdmg("Q", target, myHero)
		if Qdmg >= target.health then
		    local pred = GetGamsteronPrediction(target, QData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			    Control.CastSpell(HK_Q,pred.CastPosition)
		    end
	    end
    end

	if myHero.pos:DistanceTo(target.pos) <= 615 and self.Menu.KillSteal.UseW:Value() and Ready(_W) then
		local Wdmg = getdmg("W", target, myHero)
		if Wdmg >= target.health then
			Control.CastSpell(HK_W,target)
           
		end
	end
 
    if myHero.pos:DistanceTo(target.pos) <= 615 and self.Menu.KillSteal.UseE:Value() and Ready(_E) then
		local Edmg = getdmg("E", target, myHero)
		if Edmg >= target.health then
			Control.CastSpell(HK_E,target)
		   
	    end
    end
end
end

function Ryze:CC()
local target = GetTarget(800)
if target == nil then return end
if IsValid(target, 800) and myHero.pos:DistanceTo(target.pos) <= 615 then	
	local Immobile = IsImmobileTarget(target)	
	if self.Menu.CC.UseEW:Value() and Ready(_E) then
		if Immobile then
			Control.CastSpell(HK_E,target)
		end
	end
	
	if self.Menu.CC.UseEW:Value() and Ready(_W) then
		if Immobile then
			Control.CastSpell(HK_W,target)
		end
	end	
end
end







-------------------------------------------------------------------------------------------------------------------------------------------------------------


class "Sylas"



function Sylas:__init()

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

function Sylas:LoadSpells()
	
	Q = {range = 775, radius = 70, delay = 0.25, speed = 1800, collision = false}    
	W = {range = 400, radius = 70, delay = 0.25, speed = 20, collision = false}      
	E = {range = 800, radius = 60, delay = 0.25, speed = 1800, collision = true}   
	R = {range = 800}  

end


local UltSpells = {
	["LuxMaliceCannon"] = {charName = "Lux"},
	["EnchantedCrystalArrow"] = {charName = "Ashe"},
	["DravenRCast"] = {charName = "Draven"},
	["EzrealR"] = {charName = "Ezreal"},	
	["JinxR"] = {charName = "Jinx"},
	["LucianR"] = {charName = "Lucian"},
	["NeekoR"] = {charName = "Neeko"},
	["RivenFengShuiEngine"] = {charName = "Riven"},	
	["SonaR"] = {charName = "Sona"},
	["ThreshRPenta"] = {charName = "Thresh"},
	["YasuoR"] = {charName = "Yasuo"},
}



function Sylas:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Sylas", name = "PussySylas"})

	
	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", leftIcon = Icons["AutoW"]})	
	self.Menu.AutoW:MenuElement({id = "UseW", name = "Safe Life", value = true})
	self.Menu.AutoW:MenuElement({id = "hp", name = "Self Hp", value = 40, min = 1, max = 40, identifier = "%"})	

	--AutoR
	self.Menu:MenuElement({type = MENU, id = "AutoR", leftIcon = Icons["AutoR"]})	
	self.Menu.AutoR:MenuElement({id = "UseR", name = "Auto Pulling Ult", value = true})
	self.Menu.AutoR:MenuElement({type = MENU, id = "Target", name = "Target Settings"})
	for i, hero in pairs(GetEnemyHeroes()) do
		self.Menu.AutoR.Target:MenuElement({id = "ult"..hero.charName, name = "Pull Ult: "..hero.charName, value = true})
		
	end	
	

		
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})
	
	---------------------------------------------------------------------------------------------------------------------------------
	--UltSettings
	self.Menu.Combo:MenuElement({type = MENU, id = "Set", name = "Ult Settings"})
	--SkillShot+E Ults
	self.Menu.Combo.Set:MenuElement({id = "UltE", name = "Auto E+E2+SkillShotUlt", key = string.byte("T")})	
	self.Menu.Combo.Set:MenuElement({id = "BlockList", name = "E+E2+Ult List", type = MENU})
	DelayAction(function()
		for i, spell in pairs(UltSpells) do
			if not UltSpells[i] then return end
			for j, k in pairs(GetEnemyHeroes()) do
				if spell.charName == k.charName and not self.Menu.Combo.Set.BlockList[i] then
					if not self.Menu.Combo.Set.BlockList[i] then self.Menu.Combo.Set.BlockList:MenuElement({id = "Ult"..i, name = ""..spell.charName.."", value = true}) end
				end
			end
		end
	end, 0.01)
	
	--Heal+Shield Ults
	self.Menu.Combo.Set:MenuElement({id = "Heal", name = "Use HEAL+Shield Ults", value = true})   								
	self.Menu.Combo.Set:MenuElement({id = "HP", name = "MinHP Heal+Shield", value = 30, min = 0, max = 100, identifier = "%"})	
	--AOE Ults
	self.Menu.Combo.Set:MenuElement({id = "AOE", name = "Use AOE Ults", value = true})	   										
	self.Menu.Combo.Set:MenuElement({id = "Hit", name = "MinTargets AOE Ults", value = 2, min = 1, max = 5})	
	--KS Ults
	self.Menu.Combo.Set:MenuElement({id = "LastHit", name = "Use DMG Ults killable Enemy", value = true})						
	---------------------------------------------------------------------------------------------------------------------------------
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({type = MENU, id = "LH", name = "LastHit"})	
	self.Menu.Harass.LH:MenuElement({id = "UseQL", name = "LastHit[Q] Minions", value = true, tooltip = "There is no Enemy nearby"})
	self.Menu.Harass.LH:MenuElement({id = "UseQLM", name = "LastHit[Q] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})
	self.Menu.Harass:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})	
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQL", name = "[Q] Chain Lash", value = true})	
	self.Menu.Clear:MenuElement({id = "UseQLM", name = "[Q] min Minions", value = 2, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})  
	self.Menu.Clear:MenuElement({id = "UseEM", name = "Use [E] min Minions", value = 3, min = 1, max = 6})	
	self.Menu.Clear:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})
	self.Menu.JClear:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Chain Lash", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Abscond / Abduct", value = true})		
	self.Menu.ks:MenuElement({id = "UseW", name = "[W] Kingslayer", value = true})

	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Kill", name = "Draw Killable Targets", value = true})
end

function Sylas:Tick()
if MyHeroReady() then
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
		if myHero:GetSpellData(_R).name ~= "SylasR" then	
		self:HealShieldUlt()
		self:AoeUlt()
		self:KsUlt()
		
		end
									--131 champs added  
	elseif Mode == "Harass" then
		self:Harass()
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		local target = GetTarget(1000)
			if target == nil then	
				if minion.team == TEAM_ENEMY and IsValid(minion,1000) and myHero.pos:DistanceTo(minion.pos) <= 800 and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then	
					local count = GetMinionCount(225, minion)			
					local hp = minion.health
					local QDmg = getdmg("Q", minion, myHero)
					if Ready(_Q) and self.Menu.Harass.LH.UseQL:Value() and count >= self.Menu.Harass.LH.UseQLM:Value() and hp <= QDmg then
						Control.CastSpell(HK_Q, minion)
					end	 
				end
			end
		end
		
		
	elseif Mode == "Clear" then
		self:Clear()
		self:JungleClear()
	elseif Mode == "Flee" then
		
	end	
	if self.Menu.Combo.Set.UltE:Value() then
	self:EUlt()
	end
	self:KillSteal()	

	   				
	local target = GetTarget(1200)  
	if target == nil then return end
	if IsValid(target,1200) and myHero.pos:DistanceTo(target.pos) <= 1050 and self.Menu.AutoR.UseR:Value() and self.Menu.AutoR.Target["ult"..target.charName]:Value() and Ready(_R) then		
		if myHero:GetSpellData(_R).name == "SylasR" and GotBuff(target, "SylasR") == 0 then                     
				Control.CastSpell(HK_R, target)
		end
	end	
 
	if IsValid(target,600) and myHero.pos:DistanceTo(target.pos) <= 400 and self.Menu.AutoW.UseW:Value() and Ready(_W) then
		if myHero.health/myHero.maxHealth <= self.Menu.AutoW.hp:Value()/100 then
			Control.CastSpell(HK_W, target)
		end
	end	



end 
end

	
	
	
 
function Sylas:EUlt()
local target = GetTarget(3500)
if target == nil then return end
	if IsValid(target,3500) then
	local Ult = {"LuxMaliceCannon","EnchantedCrystalArrow","DravenRCast","EzrealR","JinxR","LucianR","NeekoR","RivenFengShuiEngine","SonaR","ThreshRPenta","YasuoR"}	
	if not table.contains(Ult, myHero:GetSpellData(_R).name) then return end	
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 1 then
				Control.CastSpell(HK_E, aimPosition)
			end
		
		elseif myHero.pos:DistanceTo(target.pos) < 1300 and myHero:GetSpellData(_E).name == "SylasE" and Ready(_E) then			
			Control.CastSpell(HK_E, target.pos)
		end
		
		
		if myHero:GetSpellData(_E).name == "SylasE2" then		
			Control.CastSpell(HK_R, target.pos) 		
		end
	end
end	

function Sylas:Draw()
local textPos = myHero.pos:To2D()


if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 1050, 1, Draw.Color(255, 225, 255, 10)) --1050
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 755, 1, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawing.DrawE:Value()) and Ready(_E) then
    Draw.Circle(myHero, 800, 1, Draw.Color(225, 225, 125, 10))
	end
	if(self.Menu.Drawing.DrawW:Value()) and Ready(_W) then
    Draw.Circle(myHero, 400, 1, Draw.Color(225, 225, 125, 10))
	end
	local target = GetTarget(20000)
	if target == nil then return end	
	if target and self.Menu.Drawing.Kill:Value() and not target.dead then
	local hp = target.health
	local fullDmg = (getdmg("Q", target, myHero) + getdmg("E", target, myHero) + getdmg("W", target, myHero))	
		if Ready(_Q) and getdmg("Q", target, myHero) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))
		end	
		if Ready(_E) and getdmg("E", target, myHero) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))		
		end	
		if Ready(_W) and getdmg("W", target, myHero) > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end
		if Ready(_W) and Ready(_E) and Ready(_Q) and fullDmg > hp then
			Draw.Text("Killable", 24, target.pos2D.x, target.pos2D.y,Draw.Color(0xFF00FF00))
			Draw.Text("Killable", 13, target.posMM.x - 15, target.posMM.y - 15,Draw.Color(0xFF00FF00))	
		end		
	end	
	local Ult = {"LuxMaliceCannon","EnchantedCrystalArrow","DravenRCast","EzrealR","JinxR","LucianR","NeekoR","RivenFengShuiEngine","SonaR","ThreshRPenta","YasuoR"}	
	if table.contains(Ult, myHero:GetSpellData(_R).name) then 
		Draw.Text("E+E2+Ult[Press Key]", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
	end	
		
end
       




function Sylas:GetPykeDamage()
	local total = 0
	local Lvl = myHero.levelData.lvl
	if Lvl > 5 then
		local raw = ({ 250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550 })[Lvl]
		local m = 1.5 * myHero.armorPen
		local Dmg = m + raw + (0.4 * myHero.ap)
		total = Dmg   
	end
	return total
end	


function Sylas:IsKnockedUp(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 29 or buff.type == 30 or buff.type == 39) and buff.count > 0 then
				return true
			end
		end
		return false	
	end
	
function Sylas:CountKnockedUpEnemies(range)
		local count = 0
		local rangeSqr = range * range
		for i = 1, Game.HeroCount()do
		local hero = Game.Hero(i)
			if hero.isEnemy and hero.alive and GetDistanceSqr(myHero.pos, hero.pos) <= rangeSqr then
			if Sylas:IsKnockedUp(hero)then
			count = count + 1
    end
  end
end
return count
end



--------------------------KS Ults---------------------------------------------------
function Sylas:KsUlt()

local target = GetTarget(25000)     	
if target == nil then return end
	if IsValid(target,25000) and self.Menu.Combo.Set.LastHit:Value() and Ready(_R) then
	local hp = target.health		
		if (myHero:GetSpellData(_R).name == "AatroxR") then										--Aatrox 
			Control.CastSpell(HK_R, target)
			
		end
	





		if (myHero:GetSpellData(_R).name == "AhriTumble") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Ahri 
			if getdmg("R", target, myHero, 70) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "AkaliR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Akali 
			if getdmg("R", target, myHero, 20) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "AkaliRb") and myHero.pos:DistanceTo(target.pos) <= 750 then		--Akalib
			if getdmg("R", target, myHero, 21) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "FerociousHowl") then										--Alistar
			Control.CastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "CurseoftheSadMummy") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Amumu 
			if getdmg("R", target, myHero, 22) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "GlacialStorm") and myHero.pos:DistanceTo(target.pos) <= 750 then		--Anivia
			if getdmg("R", target, myHero, 13) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "AnnieR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Annie   	 
			if getdmg("R", target, myHero, 23) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "EnchantedCrystalArrow") and myHero.pos:DistanceTo(target.pos) <= 25000 then		--Ashe 
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.25, 1600, 130, false)
			if getdmg("R", target, myHero, 3) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "AurelionSolR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--AurelionSol
			if getdmg("R", target, myHero, 14) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "AzirR") and myHero.pos:DistanceTo(target.pos) <= 250 then		--Azir
			if getdmg("R", target, myHero, 24) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "BlitzcrankR") and myHero.pos:DistanceTo(target.pos) <= 600 then	
			if getdmg("R", target, myHero, 26) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "BrandR") and myHero.pos:DistanceTo(target.pos) <= 750 then		--brand
			if getdmg("R", target, myHero, 48) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "BraumRWrapper") and myHero.pos:DistanceTo(target.pos) <= 1250 then		--Braum  
			if getdmg("R", target, myHero, 15) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	



		if (myHero:GetSpellData(_R).name == "CaitlynAceintheHole") and myHero.pos:DistanceTo(target.pos) <= 3500 then		--Caitlyn 
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 3500, 3.0, 3200, 50, true)
			if getdmg("R", target, myHero, 64) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end	
			end
		end
	



		if (myHero:GetSpellData(_R).name == "CamilleR") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Camille
			Control.CastSpell(HK_R, target)
		end





		if (myHero:GetSpellData(_R).name == "CassiopeiaR") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Cassiopeia
			if getdmg("R", target, myHero, 10) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "Feast") and myHero.pos:DistanceTo(target.pos) <= 200 then		--Cho'gath
			if getdmg("R", target, myHero, 2) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "MissileBarrageMissile") and myHero.pos:DistanceTo(target.pos) <= 1225 then		--Corki
			if getdmg("R", target, myHero, 30) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "DariusExecute") and myHero.pos:DistanceTo(target.pos) <= 460 then		--Darius
			if getdmg("R", target, myHero, 71) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "DianaTeleport") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Diana
			if getdmg("R", target, myHero, 34) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	





		if (myHero:GetSpellData(_R).name == "DravenRCast") and myHero.pos:DistanceTo(target.pos) <= 25000 then		--Draven   
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.25, 2000, 160, false)
			if getdmg("R", target, myHero, 27) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end	
			end
		end
	




		if (myHero:GetSpellData(_R).name == "EkkoR") and myHero.pos:DistanceTo(target.pos) <= 375 then		--Ekko
			if getdmg("R", target, myHero, 72) > hp then
				Control.CastSpell(HK_R)
			end
		end
	


--function Sylas:UltElise()



		if (myHero:GetSpellData(_R).name == "EvelynnR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Evelynn      
			local damage = getdmg("R", target, myHero, 25)*2
			if target.health/target.maxHealth <= 30/100 and damage > hp then
				Control.CastSpell(HK_R, target)
			elseif getdmg("R", target, myHero, 25) > hp then
				Control.CastSpell(HK_R, target)	
			end
		end
	





		if (myHero:GetSpellData(_R).name == "EzrealR") and myHero.pos:DistanceTo(target.pos) <= 25000 then		--ezreal
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 1.0, 2000, 160, false)
			if getdmg("R", target, myHero, 6) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end	
			end
		end
	



		if (myHero:GetSpellData(_R).name == "Crowstorm") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Fiddlesticks
			if getdmg("R", target, myHero, 54) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	





		if (myHero:GetSpellData(_R).name == "FizzR") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Fizz   
			if getdmg("R", target, myHero, 28) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		local level = myHero:GetSpellData(_R).level
		local range = ({4000, 4750, 5500})[level]
		local count = GetEnemyCount(1000, myHero)

		if (myHero:GetSpellData(_R).name == "GalioR") and myHero.pos:DistanceTo(target.pos) <= range and count == 0 then		--Galio   
			if getdmg("R", target, myHero, 73) > hp then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, range, 250)		
				end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "GangplankR") and myHero.pos:DistanceTo(target.pos) <= 20000 then		--Gankplank   
			if getdmg("R", target, myHero, 55) > hp then
				if target.pos:To2D().onScreen then						-----------check ist target in sichtweite
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			-----------ist target auserhalb sichtweite
					CastSpellMM(HK_R, target.pos, 20000, 500)		-----------CastSpellMM(HK_R, target.pos, range, delay)
				end
			end
		end
	




		local missingHP = (target.maxHealth - target.health)/100 * 0.286
		local missingHP2 = (target.maxHealth - target.health)/100 * 0.333
		local missingHP3 = (target.maxHealth - target.health)/100 * 0.4
		local damage = getdmg("R", target, myHero, 49) + missingHP
		local damage2 = getdmg("R", target, myHero, 49) + missingHP2
		local damage3 = getdmg("R", target, myHero, 49) + missingHP3

		if (myHero:GetSpellData(_R).name == "GarenR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Garen
			if damage3  > hp then
				Control.CastSpell(HK_R, target)
			elseif damage2  > hp then
				Control.CastSpell(HK_R, target)
			elseif damage  > hp then
				Control.CastSpell(HK_R, target)	
			end
		end
	



		if (myHero:GetSpellData(_R).name == "GnarR") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Gnar     
			if getdmg("R", target, myHero, 29) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "GragasR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Gragas   
			if getdmg("R", target, myHero, 30) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	



		if (myHero:GetSpellData(_R).name == "GravesChargeShot") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Graves  
			if getdmg("R", target, myHero, 31) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "HecarimUlt") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Hecarim  
			if getdmg("R", target, myHero, 32) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "HeimerdingerR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Heimerdinger
				Control.CastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "IllaoiR") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Illaoi
			if getdmg("R", target, myHero, 56) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "IreliaR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Irelia
			if getdmg("R", target, myHero, 16) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "IvernR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Ivern
			Control.CastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "JarvanIVCataclysm") and myHero.pos:DistanceTo(target.pos) <= 650 then		--jarvan
			if getdmg("R", target, myHero, 57) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




--function Sylas:UltJayyce()      


--		if (myHero:GetSpellData(_R).name == "JhinRShot") and myHero.pos:DistanceTo(target.pos) <= 525 then		--Jhin   orbwalker block für die ulti
--			if getdmg("R", target, myHero, 33) > hp then
--				Control.CastSpell(HK_R, target)
--			end
--		end

	



		if (myHero:GetSpellData(_R).name == "JinxR") and myHero.pos:DistanceTo(target.pos) <= 25000 then		--jinx
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 25000, 0.6, 1700, 140, false)
			if getdmg("R", target, myHero, 7) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end



     

--function Sylas:UltKallista()


		if (myHero:GetSpellData(_R).name == "KarmaMantra") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Karma
			Control.CastSpell(HK_R)
			
		end
	



		if (myHero:GetSpellData(_R).name == "KarthusFallenOne") and myHero.pos:DistanceTo(target.pos) <= 20000 then		--karthus
			if getdmg("R", target, myHero, 8) > hp then
				Control.CastSpell(HK_R)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "RiftWalk") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Kassadin
			if getdmg("R", target, myHero, 58) > hp then
				Control.CastSpell(HK_R, target)
			end
		end





		if (myHero:GetSpellData(_R).name == "KatarinaR") and myHero.pos:DistanceTo(target.pos) <= 550 then		
			if getdmg("R", target, myHero, 35) > hp then
				Control.CastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "KaisaR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--Kaisa  
			Control.CastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "KaynR") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Kayn 
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_R, target)
		end
	




		if (myHero:GetSpellData(_R).name == "KennenShurikenStorm") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Kennen  
			if getdmg("R", target, myHero, 36) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "KledR") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Kled   
			Control.CastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "KogMawLivingArtillery") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Kogmaw   
			if getdmg("R", target, myHero, 59) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "LeblancSlideM") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Leblanc   
			if getdmg("R", target, myHero, 60) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "BlindMonkRKick") and myHero.pos:DistanceTo(target.pos) <= 375 then		--LeeSin   
			if getdmg("R", target, myHero, 74) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "LeonaSolarFlare") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--leona   
			if getdmg("R", target, myHero, 5) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "LissandraR") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Lissandra      
			if getdmg("R", target, myHero, 18) > hp then
				Control.CastSpell(HK_R, target)
			end
		end

	


		if (myHero:GetSpellData(_R).name == "LucianR") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--Lucian
			if getdmg("R", target, myHero, 61) > hp then
				Control.CastSpell(HK_R, target)
			end
		end

	


 
		if (myHero:GetSpellData(_R).name == "LuxMaliceCannon") and myHero.pos:DistanceTo(target.pos) <= 3500 then		
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 3500, 1, math.huge, 120, false)
			if getdmg("R", target, myHero, 11) > hp and hitRate and hitRate >= 1 then
				

				
				if aimPosition:To2D().onScreen then 		
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)    
					Control.CastSpell(HK_R, castPos)
				end	
			end
		end
	



		if (myHero:GetSpellData(_R).name == "UFSlash") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--malphite 
			if getdmg("R", target, myHero, 50) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "MalzaharR") and myHero.pos:DistanceTo(target.pos) <= 700 then		
			if getdmg("R", target, myHero, 19) > hp then
				Control.CastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "MaokaiR") and myHero.pos:DistanceTo(target.pos) <= 3000 then		--Maokai 
			if getdmg("R", target, myHero, 37) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "Highlander") and myHero.pos:DistanceTo(target.pos) <= 500 then		--MasterYi
			Control.CastSpell(HK_R, target)
			
		end






		if (myHero:GetSpellData(_R).name == "MissFortuneBulletTime") and myHero.pos:DistanceTo(target.pos) <= 1400 then		
			if getdmg("R", target, myHero, 38) > hp then
				Control.CastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end				
			end
		end
	

  

		if (myHero:GetSpellData(_R).name == "MordekaiserChildrenOfTheGrave") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Mordekaiser  
			Control.CastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "SoulShackles") and myHero.pos:DistanceTo(target.pos) <= 625 then		--morgana   
			if getdmg("R", target, myHero, 52) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	





		if (myHero:GetSpellData(_R).name == "NamiR") and myHero.pos:DistanceTo(target.pos) <= 2750 then		--Nami 
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 2750, 0.5, 850, 250, false)
			if getdmg("R", target, myHero, 39) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	





		if (myHero:GetSpellData(_R).name == "NautilusR") and myHero.pos:DistanceTo(target.pos) <= 825 then		--Nautilus  
			if getdmg("R", target, myHero, 40) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "NeekoR") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Neeko
			if getdmg("R", target, myHero, 65) > hp then
				Control.CastSpell(HK_R, target)
			end
		end

	

--function Sylas:UltNiedalee()


		local level = myHero:GetSpellData(_R).level
		local range = ({2500, 3250, 4000})[level]
		if (myHero:GetSpellData(_R).name == "NocturneParanoia") and myHero.pos:DistanceTo(target.pos) <= range then		--Nocturne   
			if getdmg("R", target, myHero, 75) > hp then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, range, 250)		
				end
			end
		end
	




		if (myHero:GetSpellData(_R).name == "NunuR") and myHero.pos:DistanceTo(target.pos) <= 650 then		
			if getdmg("R", target, myHero, 17) > hp then
				Control.CastSpell(HK_R, target)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end					
			end
		end
	



		if (myHero:GetSpellData(_R).name == "OlafRagnarok") and myHero.pos:DistanceTo(target.pos) <= 1200 then		--Olaf  
			if IsImmobileTarget(myHero) then
				Control.CastSpell(HK_R)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "OrianaDetonateCommand-") and myHero.pos:DistanceTo(target.pos) <= 325 then		--Orianna  
			if getdmg("R", target, myHero, 66) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "OrnnR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Ornn
			Control.CastSpell(HK_R, target)
			
		end
	




		local count = GetEnemyCount(1000, myHero)
		if (myHero:GetSpellData(_R).name == "PantheonRJump") and myHero.pos:DistanceTo(target.pos) <= 5500 and count == 0 then		--Phantheon   
			if getdmg("R", target, myHero, 76) > hp then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5500, 2000)		
				end
			end
		end



		if (myHero:GetSpellData(_R).name == "PoppyRSpell") and myHero.pos:DistanceTo(target.pos) <= 475 then		--Poppy  
			if getdmg("R", target, myHero, 77) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		local dmg = self:GetPykeDamage()
		if (myHero:GetSpellData(_R).name == "PykeR") and myHero.pos:DistanceTo(target.pos) <= 750 and dmg >= hp then	 
			Control.CastSpell(HK_R, target)
		end
	



		if (myHero:GetSpellData(_R).name == "QuinnR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Quinn   
			Control.CastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "RakanR") and myHero.pos:DistanceTo(target.pos) <= 300 then		--Rakan  
			if getdmg("R", target, myHero, 78) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	
  
  

		if (myHero:GetSpellData(_R).name == "Tremors2") and myHero.pos:DistanceTo(target.pos) <= 300 then		--Rammus   
			if getdmg("R", target, myHero, 62) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "RekSaiR") and myHero.pos:DistanceTo(target.pos) <= 1500 then		--RekSai   
			if getdmg("R", target, myHero, 79) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "RengarR") and myHero.pos:DistanceTo(target.pos) <= 800 then		--Rengar  
			Control.CastSpell(HK_R, target)
		
		end
	
	


		if (myHero:GetSpellData(_R).name == "RivenFengShuiEngine") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Riven   
			Control.CastSpell(HK_R)
		
		end
	




		if (myHero:GetSpellData(_R).name == "RumbleCarpetBombDummy") and myHero.pos:DistanceTo(target.pos) <= 1700 then		--Rumble   
			if getdmg("R", target, myHero, 41) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "SejuaniR") and myHero.pos:DistanceTo(target.pos) <= 1300 then		--Sejuani   
			if getdmg("R", target, myHero, 42) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "HallucinateFull") and myHero.pos:DistanceTo(target.pos) <= 500 then --Shaco 
			if getdmg("R", target, myHero, 80) > hp then
				Control.CastSpell(HK_R)
				Control.CastSpell(HK_R, target)
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "ShyvanaTransformCast") and myHero.pos:DistanceTo(target.pos) <= 1000 then --shyvana 
			if getdmg("R", target, myHero, 51) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	

   

		if (myHero:GetSpellData(_R).name == "SkarnerImpale") and myHero.pos:DistanceTo(target.pos) <= 350 then		--Skarner    
			Control.CastSpell(HK_R, target)
			
		end
	




		if (myHero:GetSpellData(_R).name == "SonaR") and myHero.pos:DistanceTo(target.pos) <= 900 then		--Sona    
			if getdmg("R", target, myHero, 43) > hp then
				Control.CastSpell(HK_R, target)
			end
		end






		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Swain    
			if getdmg("R", target, myHero, 67) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	



		if (myHero:GetSpellData(_R).name == "SyndraR") and myHero.pos:DistanceTo(target.pos) <= 675 then		--Syndra    
			Control.CastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "TaliyahR") and myHero.pos:DistanceTo(target.pos) <= 1000 then		--Taliyah   
			Control.CastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "TalonShadowAssault") and myHero.pos:DistanceTo(target.pos) <= 550 then		--Talon   
			if getdmg("R", target, myHero, 81) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "ThreshRPenta") and myHero.pos:DistanceTo(target.pos) <= 450 then		--Tresh   
			if getdmg("R", target, myHero, 68) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		local level = myHero:GetSpellData(_R).level
		local range = ({400, 650, 900})[level]
		if (myHero:GetSpellData(_R).name == "TeemoR") and myHero.pos:DistanceTo(target.pos) <= range then		--Teemo   
			Control.CastSpell(HK_R, target.pos)
		
		end
	



		local range = 517 + (8 * myHero.levelData.lvl)
		local hp = target.health
		if (myHero:GetSpellData(_R).name == "TristanaR") and myHero.pos:DistanceTo(target.pos) <= range then		--Tristana  	
			if getdmg("R", target, myHero, 12) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "TrundlePain") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Trundle     
			Control.CastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "TwitchFullAutomatic") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Twitch    
			Control.CastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "UdyrPhoenixStance") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Udyr    
			Control.CastSpell(HK_R, target)
			
		end
	



		if (myHero:GetSpellData(_R).name == "UrgotR") and myHero.pos:DistanceTo(target.pos) <= 1600 then		--Urgot      
			if getdmg("R", target, myHero, 44) > hp then
				Control.CastSpell(HK_R, target)
			end	
			if target.health/target.maxHealth < 25/100 then
				Control.CastSpell(HK_R, target)	
			end
		end
	
	


		if (myHero:GetSpellData(_R).name == "VarusR") and myHero.pos:DistanceTo(target.pos) <= 1075 then		--Varus     
			if getdmg("R", target, myHero, 45) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "VayneInquisition") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Vayne     
			Control.CastSpell(HK_R)
			
		end
	




		if (myHero:GetSpellData(_R).name == "VeigarR") and myHero.pos:DistanceTo(target.pos) <= 650 then		--Vaiger
			if getdmg("R", target, myHero, 4) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	

--function Sylas:KillUltVel'koz()


		if (myHero:GetSpellData(_R).name == "ViR") and myHero.pos:DistanceTo(target.pos) <= 800 then		--Vi
			if getdmg("R", target, myHero, 82) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "ViktorChaosStorm") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Viktor
			if getdmg("R", target, myHero, 83) > hp then
				Control.CastSpell(HK_R, target.pos)
				Control.CastSpell(HK_R, target.pos)
				Control.CastSpell(HK_R, target.pos)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Vladimir
			if getdmg("R", target, myHero, 63) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		if (myHero:GetSpellData(_R).name == "VolibearR") and myHero.pos:DistanceTo(target.pos) <= 500 then		--Volibear
			if getdmg("R", target, myHero, 69) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	




		local range = 2.5 * myHero.ms
		if (myHero:GetSpellData(_R).name == "WarwickR") and myHero.pos:DistanceTo(target.pos) <= range then		--Warwick	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, range, 0.1, 1800, 55, false)
			if getdmg("R", target, myHero, 47) > hp and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	



		if (myHero:GetSpellData(_R).name == "WukongR") and myHero.pos:DistanceTo(target.pos) <= 200 then		--Wukong
			Control.CastSpell(HK_R)
		
		end
	




		if (myHero:GetSpellData(_R).name == "XayahR") and myHero.pos:DistanceTo(target.pos) <= 1100 then		--Xayah
			if getdmg("R", target, myHero, 84) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	
	

--[[

		local level = myHero:GetSpellData(_R).level
		local range = ({3520, 4840, 6160})[level]
		local count = GetEnemyCount(1000, myHero)
		if (myHero:GetSpellData(_R).name == "XerathLocusOfPower2") and myHero.pos:DistanceTo(target.pos) <= range and count == 0 then		--Xerath   
			if getdmg("R", target, myHero, 73) > hp then
				Control.CastSpell(HK_R)
				Control.SetCursorPos(target.pos)
				aim = TargetSelector:GetTarget(NEAR_MOUSE)
				if GetDistance(mousePos, aim) < 200 then						
					Control.CastSpell(HK_R) 
				end
			return end
		end
	
]]





		if (myHero:GetSpellData(_R).name == "YasuoR") and myHero.pos:DistanceTo(target.pos) <= 1400 then		--Yasou
			if getdmg("R", target, myHero, 85) > hp and self:IsKnockedUp(target) then
				Control.CastSpell(HK_R)
			end
		end
	



		if (myHero:GetSpellData(_R).name == "YorickReviveAlly") and myHero.pos:DistanceTo(target.pos) <= 600 then		--Yorick
			Control.CastSpell(HK_R, target)
		
		end
	



		local level = myHero:GetSpellData(_R).level
		local range = ({700, 850, 1000})[level]
		if (myHero:GetSpellData(_R).name == "ZacR") and myHero.pos:DistanceTo(target.pos) <= range then		--Zac  						
			Control.CastSpell(HK_R, target.pos) 
			Control.CastSpell(HK_R, target.pos)
			Control.CastSpell(HK_R, target.pos)
				
		end
	



		if (myHero:GetSpellData(_R).name == "ZedR") and myHero.pos:DistanceTo(target.pos) <= 625 then		--Zed
			Control.CastSpell(HK_R, target)
			Control.CastSpell(HK_R)
			Control.CastSpell(HK_R)
			
		end
	




		if (myHero:GetSpellData(_R).name == "ZiggsR") and myHero.pos:DistanceTo(target.pos) <= 5300 then		--ziggs
			if getdmg("R", target, myHero, 9) > hp then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5300, 375)		
				end
			end	
		end
	
	


		if (myHero:GetSpellData(_R).name == "ZoeR") and myHero.pos:DistanceTo(target.pos) <= 575 then		--Zoe
			Control.CastSpell(HK_R, target)
		
		end
	



		if (myHero:GetSpellData(_R).name == "ZyraR") and myHero.pos:DistanceTo(target.pos) <= 700 then		--Zyra    
			if getdmg("R", target, myHero, 46) > hp then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	






----------------AOE Ults------------------------------------------------------------------------------------------------------------

--Amumu
function Sylas:AoeUlt()
local target = GetTarget(20000)     	
if target == nil then return end

	if IsValid(target,20000) and self.Menu.Combo.Set.AOE:Value() and Ready(_R) then
		
		if (myHero:GetSpellData(_R).name == "CurseoftheSadMummy") then		
			local count = GetEnemyCount(550, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Bard



		if (myHero:GetSpellData(_R).name == "BardR") then
			local count = GetEnemyCount(350, target)
			if myHero.pos:DistanceTo(target.pos) <= 3400 and count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Braum

		if (myHero:GetSpellData(_R).name == "BraumRWrapper") and myHero.pos:DistanceTo(target.pos) <= 1250 then		
			local count = GetEnemyCount(115, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Brand

		if (myHero:GetSpellData(_R).name == "BrandR") and myHero.pos:DistanceTo(target.pos) <= 750 then		
			local count = GetEnemyCount(600, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Cassiopeia

		if (myHero:GetSpellData(_R).name == "CassiopeiaR") and myHero.pos:DistanceTo(target.pos) <= 825 then		
			local count = GetEnemyCount(825, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Fiddlesticks

		if (myHero:GetSpellData(_R).name == "Crowstorm") and myHero.pos:DistanceTo(target.pos) <= 600 then		
			local count = GetEnemyCount(600, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	





--Gankplank

		if (myHero:GetSpellData(_R).name == "GangplankR") and myHero.pos:DistanceTo(target.pos) <= 20000 then		
			local count = GetEnemyCount(600, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 20000, 500)		
				end
			end
		end
	
    

--Gragas
		if (myHero:GetSpellData(_R).name == "GragasR") then		
			local count = GetEnemyCount(400, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	



--Ilaoi
		if (myHero:GetSpellData(_R).name == "IllaoiR") then		
			local count = GetEnemyCount(450, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Janna
		if (myHero:GetSpellData(_R).name == "ReapTheWhirlwind") then		
			local count = GetEnemyCount(725, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Jarvan
		if (myHero:GetSpellData(_R).name == "JarvanIVCataclysm") and myHero.pos:DistanceTo(target.pos) <= 650 then		
			local count = GetEnemyCount(325, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	



--Katarina
		if (myHero:GetSpellData(_R).name == "KatarinaR") then		
			local count = GetEnemyCount(250, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
			end
		end
	


--Leona 
		if (myHero:GetSpellData(_R).name == "LeonaSolarFlare") and myHero.pos:DistanceTo(target.pos) <= 1200 then		 
			local count = GetEnemyCount(250, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target,pos)
			end
		end
	

	


--Maokai
		if (myHero:GetSpellData(_R).name == "MaokaiR") and myHero.pos:DistanceTo(target.pos) <= 3000 then
			local count = GetEnemyCount(900, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Malzahar
		local count = GetEnemyCount(500, target)
		if (myHero:GetSpellData(_R).name == "MalzaharR") and myHero.pos:DistanceTo(target.pos) <= 700 and count >= self.Menu.Combo.Set.Hit:Value() then		
				Control.CastSpell(HK_R, target.pos)
			if myHero.activeSpell.isChanneling == true then	
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
			elseif myHero.activeSpell.isChanneling == false then	
				_G.SDK.Orbwalker:SetMovement(true)
				_G.SDK.Orbwalker:SetAttack(true)
			end
		end
	


--Malphite
		if (myHero:GetSpellData(_R).name == "UFSlash") and myHero.pos:DistanceTo(target.pos) <= 1000 then
			local count = GetEnemyCount(300, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Morgana
		if (myHero:GetSpellData(_R).name == "SoulShackles") then
			local count = GetEnemyCount(625, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	


--Nautilus
		if (myHero:GetSpellData(_R).name == "NautilusR") and myHero.pos:DistanceTo(target.pos) <= 825 then
			local count = GetEnemyCount(300, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	


--Neeko
		if (myHero:GetSpellData(_R).name == "NeekoR") then
			local count = GetEnemyCount(600, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	


--Nami
		if (myHero:GetSpellData(_R).name == "NamiR") and myHero.pos:DistanceTo(target.pos) <= 2750 then
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 2750, 0.5, 850, 250, false)
			local count = GetEnemyCount(250, aimPosition)
			if count >= self.Menu.Combo.Set.Hit:Value() and hitRate and hitRate >= 1 then
				if aimPosition:To2D().onScreen then 	
					Control.CastSpell(HK_R, aimPosition) 
				
				elseif not aimPosition:To2D().onScreen then	
				local castPos = myHero.pos:Extended(aimPosition, 1000)   
					Control.CastSpell(HK_R, castPos)
				end
			end
		end
	


--Orianna
		if (myHero:GetSpellData(_R).name == "OrianaDetonateCommand-") then
			local count = GetEnemyCount(325, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	


--Rammus
		if (myHero:GetSpellData(_R).name == "Tremors2") then
			local count = GetEnemyCount(300, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Sona
		if (myHero:GetSpellData(_R).name == "SonaR") and myHero.pos:DistanceTo(target.pos) <= 900 then
			local count = GetEnemyCount(140, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Swain
		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") then
			local count = GetEnemyCount(650, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Sejuani
		if (myHero:GetSpellData(_R).name == "SejuaniR") and myHero.pos:DistanceTo(target.pos) <= 1300 then
			local count = GetEnemyCount(120, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Talon
		if (myHero:GetSpellData(_R).name == "TalonShadowAssault") then
			local count = GetEnemyCount(550, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	


--Thresh
		if (myHero:GetSpellData(_R).name == "ThreshRPenta") then
			local count = GetEnemyCount(450, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, myHero.pos)
			end
		end
	



--Vladimir
		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") and myHero.pos:DistanceTo(target.pos) <= 700 then
			local count = GetEnemyCount(325, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Varus
		if (myHero:GetSpellData(_R).name == "VarusR") and myHero.pos:DistanceTo(target.pos) <= 1075 then
			local count = GetEnemyCount(550, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Volibear
		if (myHero:GetSpellData(_R).name == "VolibearR") then
			local count = GetEnemyCount(500, myHero)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Yasuo

		if (myHero:GetSpellData(_R).name == "YasuoR") and myHero.pos:DistanceTo(target.pos) <= 1400 then
			local count = self:CountKnockedUpEnemies(1400)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R)
			end
		end
	



--Ziggs
		if (myHero:GetSpellData(_R).name == "ZiggsR") and myHero.pos:DistanceTo(target.pos) <= 5300 then
			local count = GetEnemyCount(550, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				if target.pos:To2D().onScreen then						
					Control.CastSpell(HK_R, target.pos) 
				
				elseif not target.pos:To2D().onScreen then			
					CastSpellMM(HK_R, target.pos, 5300, 375)		
				end
			end
		end
	


--Zyra
		if (myHero:GetSpellData(_R).name == "ZyraR") and myHero.pos:DistanceTo(target.pos) <= 700 then
			local count = GetEnemyCount(500, target)
			if count >= self.Menu.Combo.Set.Hit:Value() then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	end
end







--------------------Heal/Shield Ults----------------------------------

function Sylas:HealShieldUlt()
local target = GetTarget(1500)     	
if target == nil then return end	
	if IsValid(target,1500) and self.Menu.Combo.Set.Heal:Value() and Ready(_R) then
		
--Alistar		
		if (myHero:GetSpellData(_R).name == "FerociousHowl") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	


--Dr.Mundo
		if (myHero:GetSpellData(_R).name == "Sadism") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	


--Ekko

		if (myHero:GetSpellData(_R).name == "EkkoR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	



--Fiora

		if (myHero:GetSpellData(_R).name == "FioraR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target)
			end
		end
	


--Janna

		if (myHero:GetSpellData(_R).name == "ReapTheWhirlwind") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target)
			end
		end
	


--Jax

		if (myHero:GetSpellData(_R).name == "JaxRelentlessAssault") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	


--Kayle

		if (myHero:GetSpellData(_R).name == "JudicatorIntervention") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	


--Khazix

		if (myHero:GetSpellData(_R).name == "KhazixR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	


--Kindred

		if (myHero:GetSpellData(_R).name == "KindredR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	


--Lulu

		if (myHero:GetSpellData(_R).name == "LuluR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	



--Nasus

		if (myHero:GetSpellData(_R).name == "NasusR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target)
			end
		end
	


--Renekton

		if (myHero:GetSpellData(_R).name == "RenektonReignOfTheTyrant") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target)
			end
		end
	


--Singed

		if (myHero:GetSpellData(_R).name == "InsanityPotion") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	



--Sivir

		if (myHero:GetSpellData(_R).name == "SivirR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	


--Soraka

		if (myHero:GetSpellData(_R).name == "SorakaR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	


--Swain

		if (myHero:GetSpellData(_R).name == "SwainMetamorphism") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--Taric

		if (myHero:GetSpellData(_R).name == "TaricR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	


--Tryndamere

		if (myHero:GetSpellData(_R).name == "UndyingRage") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	



--Vladimir

		if (myHero:GetSpellData(_R).name == "VladimirHemoplague") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, target.pos)
			end
		end
	


--XinZhao

		if (myHero:GetSpellData(_R).name == "XenZhaoParry") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R)
			end
		end
	


--Zilean

		if (myHero:GetSpellData(_R).name == "ZileanR") then		 
			if myHero.health/myHero.maxHealth <= self.Menu.Combo.Set.HP:Value()/100 then
				Control.CastSpell(HK_R, myHero)
			end
		end
	end
end	



--------------Tranformation Ults-----------------------------








-------------------------------------------------------------






function Sylas:KillSteal()
if myHero.dead then return end	
	local target = GetTarget(2000)     	
	if target == nil then return end
	
	if IsValid(target,1300) and myHero.pos:DistanceTo(target.pos) <= 1300 then
		local EDmg = getdmg("E", target, myHero)
		if myHero.pos:DistanceTo(target.pos) <= 1200 and myHero.pos:DistanceTo(target.pos) > 400 and EDmg >= target.health and self.Menu.ks.UseE:Value() and Ready(_E) then			
			local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
			Control.SetCursorPos(EPos)
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
			if myHero.pos:DistanceTo(target.pos) <= 800 then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
				if hitRate and hitRate >= 2 then
					Control.CastSpell(HK_E, aimPosition)
				end	
			end
	
		elseif myHero.pos:DistanceTo(target.pos) <= 400 and EDmg >= target.health and self.Menu.ks.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E, target)
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 2 then
				Control.CastSpell(HK_E, aimPosition)
			end	
		end			
		
		if myHero.pos:DistanceTo(target.pos) <= 775 and self.Menu.ks.UseQ:Value() and Ready(_Q) then
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health and hitRate and hitRate >= 2 then
				Control.CastSpell(HK_Q, aimPosition)
			end
		elseif myHero.pos:DistanceTo(target.pos) > 775 and myHero.pos:DistanceTo(target.pos) <= 1175 and self.Menu.ks.UseQ:Value() and Ready(_Q) and Ready(_E) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health then
				local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)	
			if myHero.pos:DistanceTo(target.pos) <= 775 and hitRate and hitRate >= 2 then	
				Control.CastSpell(HK_Q, aimPosition)
			end
			end
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 400 and self.Menu.ks.UseW:Value() and Ready(_W) then
			local WDmg = getdmg("W", target, myHero)
			if WDmg >= target.health then
				Control.CastSpell(HK_W, target)		
			end
		elseif myHero.pos:DistanceTo(target.pos) > 400 and myHero.pos:DistanceTo(target.pos) <= 800 and self.Menu.ks.UseW:Value() and Ready(_W) and Ready(_E) then
			local WDmg = getdmg("W", target, myHero)
			if WDmg >= target.health then
				local EPos = target.pos:Shortened((myHero.pos:DistanceTo(target.pos) - 400))
				Control.SetCursorPos(EPos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
			if myHero.pos:DistanceTo(target.pos) <= 400 then	
				Control.CastSpell(HK_W, target)
			end		
			end			
		end					
	end
end	





function Sylas:Combo()
local target = GetTarget(1300)
if target == nil then return end
	
	if IsValid(target,1300) then
		if myHero.pos:DistanceTo(target.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 1 then
				Control.CastSpell(HK_E, aimPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) < 1300 and self.Menu.Combo.UseE:Value() and Ready(_E) then			
			if myHero:GetSpellData(_E).name == "SylasE" then
				Control.CastSpell(HK_E, target.pos)
			end
		end
		local passiveBuff = GetBuffData(myHero,"SylasPassiveAttack")
		if myHero.pos:DistanceTo(target.pos) < 400 and passiveBuff.count == 1 then return end
		if myHero.pos:DistanceTo(target.pos) <= 775 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then 	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			if hitRate and hitRate >= 2 then
				Control.CastSpell(HK_Q, aimPosition)
			end	
		end
		if myHero.pos:DistanceTo(target.pos) <= 400 and self.Menu.Combo.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target)
		end
	end
end

	
  		

function Sylas:Harass()	
local target = GetTarget(1300)
if target == nil then return end

	
	if IsValid(target,1300) and myHero.pos:DistanceTo(target.pos) < 1300 and (myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 ) then
		
		if myHero.pos:DistanceTo(target.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
			if hitRate and hitRate >= 1 then
				Control.CastSpell(HK_E, aimPosition)
			end	
		end	 	
		
		if myHero.pos:DistanceTo(target.pos) < 1300 and self.Menu.Harass.UseE:Value() and Ready(_E) then			
			if myHero:GetSpellData(_E).name == "SylasE" then
				Control.CastSpell(HK_E, target.pos)
			end
		end
		local passiveBuff = GetBuffData(myHero,"SylasPassiveAttack")
		if passiveBuff.count == 1 and myHero.pos:DistanceTo(target.pos) < 400 then return end	
		if myHero.pos:DistanceTo(target.pos) <= 775 and self.Menu.Harass.UseQ:Value() and Ready(_Q) then 	
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
			if hitRate and hitRate >= 2 then
				Control.CastSpell(HK_Q, aimPosition)
			end	
		end
		if myHero.pos:DistanceTo(target.pos) <= 400 and self.Menu.Harass.UseW:Value() and Ready(_W) then
			Control.CastSpell(HK_W, target)
		end
	end
end



function Sylas:Clear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
	local passiveBuff = GetBuffData(myHero,"SylasPassiveAttack")
		
		if minion.team == TEAM_ENEMY and IsValid(minion,1300) and (myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100 ) then			
			if myHero.pos:DistanceTo(minion.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, E.range, E.delay, E.speed, E.radius, false)
				if hitRate and hitRate >= 0 then
					Control.CastSpell(HK_E, aimPosition)
				end	
			end			
			
						
			if myHero.pos:DistanceTo(minion.pos) < 1300 and Ready(_E) and self.Menu.Clear.UseE:Value() and myHero:GetSpellData(_E).name == "SylasE" then
				Control.CastSpell(HK_E, minion)
			end
					
 			if passiveBuff.count == 1 and myHero.pos:DistanceTo(minion.pos) < 400 then return end 
			if myHero.pos:DistanceTo(minion.pos) <= 755 and Ready(_Q) and self.Menu.Clear.UseQL:Value() and GetMinionCount(225, minion) >= self.Menu.Clear.UseQLM:Value() then
				Control.CastSpell(HK_Q, minion)
			end	

			if myHero.pos:DistanceTo(minion.pos) <= 400 and Ready(_W) and self.Menu.Clear.UseW:Value() then
				Control.CastSpell(HK_W, minion)
			end  
		end
	end
end

function Sylas:JungleClear()
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)	
	
 	
		if minion.team == TEAM_JUNGLE and IsValid(minion,1300) and myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100 then	
			
			if myHero.pos:DistanceTo(minion.pos) <= 800 and myHero:GetSpellData(_E).name == "SylasE2" then	
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, E.range, E.delay, E.speed, E.radius, false)
				if hitRate and hitRate >= 0 then
					Control.CastSpell(HK_E, aimPosition)
				end	
			end			
						
			if myHero.pos:DistanceTo(minion.pos) < 1300 and Ready(_E) and self.Menu.JClear.UseE:Value() and myHero:GetSpellData(_E).name == "SylasE" then
				Control.CastSpell(HK_E, minion)
			end			
			local passiveBuff = GetBuffData(myHero,"SylasPassiveAttack")
			if passiveBuff.count == 1 and myHero.pos:DistanceTo(minion.pos) < 400 then return end
			if myHero.pos:DistanceTo(minion.pos) <= 775 and Ready(_Q) and self.Menu.JClear.UseQ:Value() then
				Control.CastSpell(HK_Q, minion)
			end

			if myHero.pos:DistanceTo(minion.pos) <= 400 and Ready(_W) and self.Menu.JClear.UseW:Value() then
				Control.CastSpell(HK_W, minion)
			end 
		end
	end
end









-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Veigar"





function Veigar:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)

	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.gsoSDK then
		Orb = 4			
	end	
end

function GetPercentMP(unit)
	return (unit.mana / unit.maxMana) * 100
end

function Veigar:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Veigar:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Veigar:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Veigar:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

function Veigar:LoadSpells()

	Q = {Range = 950, Width = 70, Delay = 0.25, Speed = 2000, Collision = false, aoe = false, Type = "line"}
	W = {Range = 900, Width = 225, Delay = 1.35, Speed = 1000, Collision = false, aoe = true, Type = "circular"}
	E = {Range = 700, Width = 375, Delay = 0.5, Speed = 1000, Collision = false, aoe = true, Type = "circular"}
	R = {Range = 650, Width = 50, Delay = 0.25, Speed = 1400, Collision = false, aoe = false, Type = "line"}

end

function Veigar:QDMG()
    local level = myHero:GetSpellData(_Q).level
    local qdamage = (({70,110,150,190,230})[level] + 0.60 * myHero.ap)
	return qdamage
end

function Veigar:WDMG()
    local level = myHero:GetSpellData(_W).level
    local wdamage = (({100,150,200,250,300})[level] + myHero.ap)
	return wdamage
end

function Veigar:RDMG()
    local level = myHero:GetSpellData(_R).level
    local rdamage = GetPercentHP(target) > 33.3 and ({175, 250, 325})[level] + 0.75 * myHero.ap or ({350, 500, 650})[level] + 1.5 * myHero.ap; return rdamage +((0.015 * rdamage) * (100 - ((target.health / target.maxHealth) * 100)))

end

local qData =
{
Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 100, Range = 950, Speed = 2000, Collision = true ,MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION,_G.COLLISION_YASUOWALL}
}

local WData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 1.25, Radius = 112, Range = 900, Speed = 1000, Collision = false
}

local EData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 375, Range = 700, Speed = 1000, Collision = false
}


function Veigar:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Veigar", name = "PussyVeigar"})
	self.Menu:MenuElement({id = "Combo", leftIcon = Icons["Combo"], type = MENU})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Combo:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Combo:MenuElement({id = "WWait", name = "Only W when stunned", value = true})
	self.Menu.Combo:MenuElement({id = "EMode", name = "E Mode", drop = {"Edge", "Middle"}})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
		
	self.Menu:MenuElement({id = "Harass", leftIcon = Icons["Harass"], type = MENU})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Harass:MenuElement({id = "AutoQ", name = "Auto Q Toggle", value = false, toggle = true, key = string.byte("U")})
	self.Menu.Harass:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({id = "Lasthit", leftIcon = Icons["Lasthit"], type = MENU})
	self.Menu.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Lasthit:MenuElement({id = "AutoQFarm", name = "Auto Q Farm", value = false, toggle = true, key = string.byte("Z")})
	self.Menu.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
	
	self.Menu:MenuElement({id = "Clear", leftIcon = Icons["Clear"], type = MENU})
	self.Menu.Clear:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.Clear:MenuElement({id = "WHit", name = "W hits x minions", value = 3,min = 1, max = 6, step = 1})
	self.Menu.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})
	
	self.Menu:MenuElement({id = "Mana", leftIcon = Icons["Mana"], type = MENU})
	self.Menu.Mana:MenuElement({id = "QMana", name = "Min mana to use Q", value = 35, min = 0, max = 100, step = 1})
	self.Menu.Mana:MenuElement({id = "WMana", name = "Min mana to use W", value = 40, min = 0, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Killsteal", leftIcon = Icons["ks"], type = MENU})
	self.Menu.Killsteal:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.Killsteal:MenuElement({id = "UseW", name = "W", value = false})
	self.Menu.Killsteal:MenuElement({id = "RR", name = "R", value = true})

	self.Menu:MenuElement({id = "isCC", leftIcon = Icons["AutoUseCC"], type = MENU})
	self.Menu.isCC:MenuElement({id = "UseQ", name = "Q", value = true})
	self.Menu.isCC:MenuElement({id = "UseW", name = "W", value = true})
	self.Menu.isCC:MenuElement({id = "UseE", name = "E", value = false})
	self.Menu.isCC:MenuElement({id = "EMode", name = "E Mode", drop = {"Edge", "Middle"}})

	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})	
	self.Menu.Pred:MenuElement({id = "PredW", name = "Hitchance[W]", value = 2, drop = {"Normal", "High", "Immobile"}})
	self.Menu.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 2, drop = {"Normal", "High", "Immobile"}})	



end

function Veigar:Tick()
if MyHeroReady() then
local Mode = GetMode()
	if Mode == "Combo" then
		if self.Menu.Combo.comboActive:Value() then
			self:Combo()
		end
	elseif Mode == "Harass" then
		if self.Menu.Harass.harassActive:Value() then
			self:Harass()
		end
	elseif Mode == "Clear" then
		if self.Menu.Clear.clearActive:Value() then
			self:Clear()
		end	
	end

	if self.Menu.Lasthit.lasthitActive:Value() then
		self:Lasthit()
	end

	self:KS()
	self:SpellonCC()
	self:AutoQ()
	self:AutoQFarm()
end
end



function Veigar:Clear()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
		if IsValid(minion,1000) and myHero.pos:DistanceTo(minion.pos) <= 900 and self.Menu.Clear.UseW:Value() then
			if minion.team == TEAM_ENEMY then
				
				local count = GetMinionCount(120, minion)
				if count >= self.Menu.Clear.WHit:Value() and self:CanCast(_W) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.WMana:Value() / 100 ) then
					Control.CastSpell(HK_W,minion.pos)
				end
			end
			if minion.team == TEAM_JUNGLE then
				if self:CanCast(_W) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.WMana:Value() / 100 ) then
					Control.CastSpell(HK_W,minion.pos)
				end	
			end
		end
	end	
end

function Veigar:Combo()
local target = GetTarget(1000)
if target == nil then return end
if IsValid(target,1000) then	
	if EnemyInRange(Q.Range) then	
		if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
		    end
	    end
    end
	

	if EnemyInRange(E.Range) then	
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if self.Menu.Combo.UseE:Value() and self:CanCast(_E) and pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
			if self.Menu.Combo.EMode:Value() == 1 then
				Control.CastSpell(HK_E, Vector(target:GetPrediction(math.huge,0.25))-Vector(Vector(target:GetPrediction(math.huge,0.25))-Vector(myHero.pos)):Normalized()*350) 
			elseif self.Menu.Combo.EMode:Value() == 2 then
				Control.CastSpell(HK_E,pred.CastPosition)
			end
		end	
	end
	

	if EnemyInRange(W.Range) then	
		if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
		    local ImmobileEnemy = IsImmobileTarget(target)
			if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
				if self.Menu.Combo.WWait:Value() and ImmobileEnemy then 
					Control.CastSpell(HK_W, pred.CastPosition)
				elseif self.Menu.Combo.WWait:Value() == false then 
					Control.CastSpell(HK_W, pred.CastPosition)	
				end
			end
		end
    end
end
end	

function Veigar:Harass()
local target = GetTarget(1000)
if target == nil then return end
if IsValid(target,1000) then    
	
	if EnemyInRange(Q.Range) then
		if self.Menu.Harass.UseQ:Value() and self:CanCast(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.QMana:Value() / 100 ) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
		    end
	    end
    end
 

	if EnemyInRange(W.Range) then	
		if self.Menu.Harass.UseW:Value() and self:CanCast(_W) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.WMana:Value() / 100 ) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
		    if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
				Control.CastSpell(HK_W, pred.CastPosition)
		    end
	    end
    end
end
end

function Veigar:AutoQ()
	local target = GetTarget(Q.Range)
	if target == nil then return end
	
	if IsValid(target,1000) and EnemyInRange(Q.Range) then 
		if self.Menu.Harass.AutoQ:Value() and self:CanCast(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Mana.QMana:Value() / 100 ) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 and self:CanCast(_Q) then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
	end
end
	
function Veigar:AutoQFarm()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
			
		if minion.team == TEAM_ENEMY and IsValid(minion,1000) and myHero.pos:DistanceTo(minion.pos) < Q.Range then
			local Qdamage = self:QDMG()
			if self:CanCast(_Q) and self.Menu.Lasthit.AutoQFarm:Value() and Qdamage >= minion.health and (myHero.mana/myHero.maxMana >= self.Menu.Mana.QMana:Value() / 100 ) then	
				Control.CastSpell(HK_Q,minion.pos)
			
			end
		end
	end
end

function Veigar:Lasthit()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
			
		if minion.team == TEAM_ENEMY and IsValid(minion,1000) and myHero.pos:DistanceTo(minion.pos) < Q.Range then
			if self.Menu.Lasthit.UseQ:Value() and self:CanCast(_Q) then
				local Qdamage = self:QDMG()
				if Qdamage >= self:HpPred(minion,1) then
				Control.CastSpell(HK_Q,minion.pos)
				end
			end
		end
	end
end
	
	
function Veigar:KS()
local target = GetTarget(950)
if target == nil then return end
	
	if IsValid(target,Q.Range) and EnemyInRange(Q.Range) then 	
		if self.Menu.Killsteal.UseQ:Value() and self:CanCast(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
		   	local Qdamage = Veigar:QDMG()
			if Qdamage >= self:HpPred(target,1) + target.hpRegen * 1 and not target.dead then
				if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
		end
	end
	if IsValid(target,W.Range) and EnemyInRange(W.Range) then	
		if self.Menu.Killsteal.UseW:Value() and self:CanCast(_W) then 
			local pred = GetGamsteronPrediction(target, WData, myHero)
		   	local Wdamage = self:WDMG()
			if Wdamage >= self:HpPred(target,1) + target.hpRegen * 1 and not target.dead then
				if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 then
					Control.CastSpell(HK_W, pred.CastPosition)
				end
			end
		end
	end	
	if IsValid(target,R.Range) and EnemyInRange(R.Range) and self.Menu.Killsteal.RR:Value() and self:CanCast(_R) then   
		local level = myHero:GetSpellData(_R).level	
		local dmg = GetPercentHP(target) > 33.3 and ({175, 250, 325})[level] + 0.75 * myHero.ap or ({350, 500, 650})[level] + 1.50 * myHero.ap
		local Rdamage = dmg +((0.015 * dmg) * (100 - ((target.health / target.maxHealth) * 100)))

		if Rdamage >= self:HpPred(target,1) * 1.2 + target.hpRegen * 2 then
			Control.CastSpell(HK_R, target)
		end
	end	
end




function Veigar:SpellonCC()
local target = GetTarget(950)
if target == nil then return end
		
	if IsValid(target,Q.Range) and EnemyInRange(Q.Range) then	
		if self.Menu.isCC.UseQ:Value() and self:CanCast(_Q) then
			local ImmobileEnemy = IsImmobileTarget(target)
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if ImmobileEnemy then
				if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end
		end
	end
	if IsValid(target,E.Range) and EnemyInRange(E.Range) then	
		local ImmobileEnemy = IsImmobileTarget(target)
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if self.Menu.isCC.UseE:Value() and self:CanCast(_E) and ImmobileEnemy and pred.Hitchance >= self.Menu.Pred.PredE:Value() + 1 then
			if self.Menu.Combo.EMode:Value() == 1 then
				Control.CastSpell(HK_E, Vector(target:GetPrediction(math.huge,0.25))-Vector(Vector(target:GetPrediction(math.huge,0.25))-Vector(myHero.pos)):Normalized()*350) 
			elseif self.Menu.Combo.EMode:Value() == 2 then
				Control.CastSpell(HK_E,pred.CastPosition)
			end
		end	
	end	
	if IsValid(target,W.Range) and EnemyInRange(W.Range) then 	
		if self.Menu.isCC.UseW:Value() and self:CanCast(_W) then
			local ImmobileEnemy = IsImmobileTarget(target)
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredW:Value() + 1 and ImmobileEnemy then
				Control.CastSpell(HK_W, pred.CastPosition)
			end
		end
	end	
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Xerath"



local QData =
{
Type = _G.SPELLTYPE_LINE, Collision = false, Delay = 0.35 + Game.Latency()/1000, Radius = 145, Range = 1400, Speed = math.huge
}

local WData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 0.5, Radius = 200, Range = 1100, Speed = math.huge, Collision = false
}

local EData =
{
Type = _G.SPELLTYPE_LINE, Collision = true, Delay = 0.25, Radius = 30, Range = 1050, Speed = 2300, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
}

local RData =
{
Type = _G.SPELLTYPE_CIRCLE, Delay = 1.0, Radius = 200, Range = 2200 + 1320*myHero:GetSpellData(_R).level, Speed = math.huge, Collision = false
}



function Xerath:__init()
	
	
	print("Xerath loaded!")

	self:LoadMenu()	
	self:LoadSpells()
	self.AA = { delay = 0.25, speed = 2000, width = 0, range = 525 }
	self.Q = { delay = 0.35, speed = math.huge, width = 145, range = 750 }
	self.W = { delay = 0.5, speed = math.huge, width = 200, range = 1100 }
	self.E = { delay = 0.25, speed = 2300, width = 30, range = 1050 }
	self.R = { delay = 0.5, speed = math.huge, width = 200, range = 3520 }
	self.range = 525
	self.chargeQ = false
	self.qTick = GetTickCount()
	self.chargeR = false
	self.chargeRTick = GetTickCount()
	self.R_target = nil
	self.R_target_tick = GetTickCount()
	self.firstRCast = true
	self.R_Stacks = 0
	self.lastRtick = GetTickCount()
	self.CanUseR = true
	self.lastTarget = nil
	self.lastTarget_tick = GetTickCount()
	self.lastMinion = nil
	self.lastMinion_tick = GetTickCount()	
	
	
	function OnTick() self:Tick() end
 	function OnDraw() self:Draw() end
end


local _EnemyHeroes
function Xerath:GetEnemyHeroes()
  if _EnemyHeroes then return _EnemyHeroes end
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isEnemy then
	  if _EnemyHeroes == nil then _EnemyHeroes = {} end
      table.insert(_EnemyHeroes, unit)
    end
  end
  return {}
end

function Xerath:IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function CanUseSpell(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

local function GetPercentHP(unit)
  if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  return 100*unit.health/unit.maxHealth
end

local function GetPercentMP(unit)
  if type(unit) ~= "userdata" then error("{GetPercentMP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  return 100*unit.mana/unit.maxMana
end

local function GetBuffs(unit)
  local t = {}
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.count > 0 then
      table.insert(t, buff)
    end
  end
  return t
end


function IsImmune(unit)
  if type(unit) ~= "userdata" then error("{IsImmune}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  for i, buff in pairs(GetBuffs(unit)) do
    if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and GetPercentHP(unit) <= 10 then
      return true
    end
    if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then 
      return true
    end
  end
  return false
end 

function IsValidTarget(unit, range, checkTeam, from)
  local range = range == nil and math.huge or range
  if type(range) ~= "number" then error("{IsValidTarget}: bad argument #2 (number expected, got "..type(range)..")") end
  if type(checkTeam) ~= "nil" and type(checkTeam) ~= "boolean" then error("{IsValidTarget}: bad argument #3 (boolean or nil expected, got "..type(checkTeam)..")") end
  if type(from) ~= "nil" and type(from) ~= "userdata" then error("{IsValidTarget}: bad argument #4 (vector or nil expected, got "..type(from)..")") end
  if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
    return false 
  end 
  return unit.pos:DistanceTo(from.pos and from.pos or myHero.pos) < range 
end

function CountAlliesInRange(point, range)
  if type(point) ~= "userdata" then error("{CountAlliesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
  local range = range == nil and math.huge or range 
  if type(range) ~= "number" then error("{CountAlliesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
  local n = 0
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isAlly and not unit.isMe and IsValidTarget(unit, range, false, point) then
      n = n + 1
    end
  end
  return n
end

local function CountEnemiesInRange(point, range)
  if type(point) ~= "userdata" then error("{CountEnemiesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
  local range = range == nil and math.huge or range 
  if type(range) ~= "number" then error("{CountEnemiesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
  local n = 0
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if IsValidTarget(unit, range, true, point) then
      n = n + 1
    end
  end
  return n
end

function CalcuPhysicalDamage(source, target, amount)
  local ArmorPenPercent = source.armorPenPercent
  local ArmorPenFlat = (0.4 + target.levelData.lvl / 30) * source.armorPen
  local BonusArmorPen = source.bonusArmorPenPercent

  if source.type == Obj_AI_Minion then
    ArmorPenPercent = 1
    ArmorPenFlat = 0
    BonusArmorPen = 1
  elseif source.type == Obj_AI_Turret then
    ArmorPenFlat = 0
    BonusArmorPen = 1
    if source.charName:find("3") or source.charName:find("4") then
      ArmorPenPercent = 0.25
    else
      ArmorPenPercent = 0.7
    end
  end

  if source.type == Obj_AI_Turret then
    if target.type == Obj_AI_Minion then
      amount = amount * 1.25
      if string.ends(target.charName, "MinionSiege") then
        amount = amount * 0.7
      end
      return amount
    end
  end

  local armor = target.armor
  local bonusArmor = target.bonusArmor
  local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)

  if armor < 0 then
    value = 2 - 100 / (100 - armor)
  elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 1)))
end

function CalcuMagicalDamage(source, target, amount)
  local mr = target.magicResist
  local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)

  if mr < 0 then
    value = 2 - 100 / (100 - mr)
  elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 2)))
end



local DamageReductionTable = {
  ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level] end},
  ["Urgot"] = {buff = "urgotswapdef", amount = function(target) return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level] end},
  ["Alistar"] = {buff = "Ferocious Howl", amount = function(target) return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level] end},
  -- ["Amumu"] = {buff = "Tantrum", amount = function(target) return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level] end, damageType = 1},
  ["Galio"] = {buff = "GalioIdolOfDurand", amount = function(target) return 0.5 end},
  ["Garen"] = {buff = "GarenW", amount = function(target) return 0.7 end},
  ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level] end},
  ["Annie"] = {buff = "MoltenShield", amount = function(target) return 1 - ({0.16,0.22,0.28,0.34,0.4})[target:GetSpellData(_E).level] end},
  ["Malzahar"] = {buff = "malzaharpassiveshield", amount = function(target) return 0.1 end}
}



local function DamageReductionMod(source,target,amount,DamageType)
  if source.type == Obj_AI_Hero then
    if GotBuff(source, "Exhaust") > 0 then
      amount = amount * 0.6
    end
  end

  if target.type == Obj_AI_Hero then

    for i = 0, target.buffCount do
      if target:GetBuff(i).count > 0 then
        local buff = target:GetBuff(i)
        if buff.name == "MasteryWardenOfTheDawn" then
          amount = amount * (1 - (0.06 * buff.count))
        end
    
        if DamageReductionTable[target.charName] then
          if buff.name == DamageReductionTable[target.charName].buff and (not DamageReductionTable[target.charName].damagetype or DamageReductionTable[target.charName].damagetype == DamageType) then
            amount = amount * DamageReductionTable[target.charName].amount(target)
          end
        end

        if target.charName == "Maokai" and source.type ~= Obj_AI_Turret then
          if buff.name == "MaokaiDrainDefense" then
            amount = amount * 0.8
          end
        end

        if target.charName == "MasterYi" then
          if buff.name == "Meditate" then
            amount = amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpellData(_W).level] / (source.type == Obj_AI_Turret and 2 or 1)
          end
        end
      end
    end

    if GetItemSlot(target, 1054) > 0 then
      amount = amount - 8
    end

    if target.charName == "Kassadin" and DamageType == 2 then
      amount = amount * 0.85
    end
  end

  return amount
end

local function PassivePercentMod(source, target, amount, damageType)
  local SiegeMinionList = {"Redmath.minion_MechCannon", "Bluemath.minion_MechCannon"}
  local NormalMinionList = {"Redmath.minion_Wizard", "Bluemath.minion_Wizard", "Redmath.minion_Basic", "Bluemath.minion_Basic"}

  if source.type == Obj_AI_Turret then
    if table.contains(SiegeMinionList, target.charName) then
      amount = amount * 0.7
    elseif table.contains(NormalMinionList, target.charName) then
      amount = amount * 1.14285714285714
    end
  end
  if source.type == Obj_AI_Hero then 
    if target.type == Obj_AI_Hero then
      if (GetItemSlot(source, 3036) > 0 or GetItemSlot(source, 3034) > 0) and source.maxHealth < target.maxHealth and damageType == 1 then
        amount = amount * (1 + math.min(target.maxHealth - source.maxHealth, 500) / 50 * (GetItemSlot(source, 3036) > 0 and 0.015 or 0.01))
      end
    end
  end
  return amount
end

local function Priority(charName)
  local p1 = {"Alistar", "Amumu", "Blitzcrank", "Braum", "Cho'Gath", "Dr. Mundo", "Garen", "Gnar", "Maokai", "Hecarim", "Jarvan IV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "TahmKench", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Poppy"}
  local p2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gragas", "Irelia", "Jax", "Lee Sin", "Morgana", "Janna", "Nocturne", "Pantheon", "Rengar", "Rumble", "Swain", "Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai", "Bard", "Nami", "Sona", "Camille"}
  local p3 = {"Akali", "Diana", "Ekko", "FiddleSticks", "Fiora", "Gangplank", "Fizz", "Heimerdinger", "Jayce", "Kassadin", "Kayle", "Kha'Zix", "Lissandra", "Mordekaiser", "Nidalee", "Riven", "Shaco", "Vladimir", "Yasuo", "Zilean", "Zyra", "Ryze"}
  local p4 = {"Ahri", "Anivia", "Annie", "Ashe", "Azir", "Brand", "Caitlyn", "Cassiopeia", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "Karma", "Karthus", "Katarina", "Kennen", "KogMaw", "Kindred", "Leblanc", "Lucian", "Lux", "Malzahar", "MasterYi", "MissFortune", "Orianna", "Quinn", "Sivir", "Syndra", "Talon", "Teemo", "Tristana", "TwistedFate", "Twitch", "Varus", "Vayne", "Veigar", "Velkoz", "Viktor", "Xerath", "Zed", "Ziggs", "Jhin", "Soraka"}
  if table.contains(p1, charName) then return 1 end
  if table.contains(p2, charName) then return 1.25 end
  if table.contains(p3, charName) then return 1.75 end
  return table.contains(p4, charName) and 2.25 or 1
end

function Xerath:GetTarget(range,t,pos)
local t = t or "AD"
local pos = pos or myHero.pos
local target = {}
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy and not hero.dead then
			OnVision(hero)
		end
		if hero.isEnemy and hero.valid and not hero.dead and (OnVision(hero).state == true or (OnVision(hero).state == false and GetTickCount() - OnVision(hero).tick < 650)) and hero.isTargetable then
			local heroPos = hero.pos
			if OnVision(hero).state == false then heroPos = hero.pos + Vector(hero.pos,hero.posTo):Normalized() * ((GetTickCount() - OnVision(hero).tick)/1000 * hero.ms) end
			if GetDistance(pos,heroPos) <= range then
				if t == "AD" then
					target[(CalcuPhysicalDamage(myHero,hero,100) / hero.health)*Priority(hero.charName)] = hero
				elseif t == "AP" then
					target[(CalcuMagicalDamage(myHero,hero,100) / hero.health)*Priority(hero.charName)] = hero
				elseif t == "HYB" then
					target[((CalcuMagicalDamage(myHero,hero,50) + CalcuPhysicalDamage(myHero,hero,50))/ hero.health)*Priority(hero.charName)] = hero
				end
			end
		end
	end
	local bT = 0
	for d,v in pairs(target) do
		if d > bT then
			bT = d
		end
	end
	if bT ~= 0 then return target[bT] end
end
 
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastSpell(spell,pos,range,delay)
local range = range or math.huge
local delay = delay or 250
local ticker = GetTickCount()

	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			Control.SetCursorPos(pos)
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

local function CastSpellMM(spell,pos,range,delay)
local range = range or math.huge
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

-- local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function ReleaseSpell(spell,pos,range,delay)
local delay = delay or 250
local ticker = GetTickCount()
	if castSpell.state == 0 and GetDistance(myHero.pos,pos) < range and ticker - castSpell.casting > delay + Game.Latency() then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			if not pos:ToScreen().onScreen then
				pos = myHero.pos + Vector(myHero.pos,pos):Normalized() * math.random(530,760)
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

local castAttack = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastAttack(pos,range,delay)
local delay = delay or myHero.attackData.windUpTime*1000/2

local ticker = GetTickCount()
	if castAttack.state == 0 and GetDistance(myHero.pos,pos.pos) < range and ticker - castAttack.casting > delay + Game.Latency() and aa.state == 1 and not pos.dead and pos.isTargetable then
		castAttack.state = 1
		castAttack.mouse = mousePos
		castAttack.tick = ticker
		lastTick = GetTickCount()
	end
	if castAttack.state == 1 then
		if ticker - castAttack.tick < Game.Latency() and aa.state == 1 then
				Control.SetCursorPos(pos.pos)
				Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
				Control.mouse_event(MOUSEEVENTF_RIGHTUP)
				castAttack.casting = ticker + delay
			DelayAction(function()
				if castAttack.state == 1 then
					Control.SetCursorPos(castAttack.mouse)
					castAttack.state = 0
				end
			end,Game.Latency()/1000)
		end
		if ticker - castAttack.casting > Game.Latency() and castAttack.state == 1 then
			Control.SetCursorPos(castAttack.mouse)
			castAttack.state = 0
		end
	end
end

local castMove = {state = 0, tick = GetTickCount(), mouse = mousePos}
local function CastMove(pos)
local movePos = pos or mousePos
Control.KeyDown(HK_TCO)
Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
Control.mouse_event(MOUSEEVENTF_RIGHTUP)
Control.KeyUp(HK_TCO)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local aa = {state = 1, tick = GetTickCount(), tick2 = GetTickCount(), downTime = GetTickCount(), target = myHero}
local lastTick = 0
local lastMove = 0
local aaTicker = Callback.Add("Tick", function() Xerath:aaTick() end)
function Xerath:aaTick()
	if myHero.charName ~= "Xerath" then return end
	if aa.state == 1 and myHero.attackData.state == 2 then
		lastTick = GetTickCount()
		aa.state = 2
		aa.target = myHero.attackData.target
	end
	if aa.state == 2 then
		if myHero.attackData.state == 1 then
			aa.state = 1
		end
		if Game.Timer() + Game.Latency()/2000 - myHero.attackData.castFrame/200 > myHero.attackData.endTime - myHero.attackData.windDownTime and aa.state == 2 then
			-- print("OnAttackComp WindUP:"..myHero.attackData.endTime)
			aa.state = 3
			aa.tick2 = GetTickCount()
			aa.downTime = myHero.attackData.windDownTime*1000 - (myHero.attackData.windUpTime*1000)
			if self.Menu.fastOrb ~= nil and self.Menu.fastOrb:Value() then
				if self:GetMode() ~= "" and myHero.attackData.state == 2 then
					Control.Move()
				end
			end
		end
	end
	if aa.state == 3 then
		if GetTickCount() - aa.tick2 - Game.Latency() - myHero.attackData.castFrame > myHero.attackData.windDownTime*1000 - (myHero.attackData.windUpTime*1000)/2 then
			aa.state = 1
		end
		if myHero.attackData.state == 1 then
			aa.state = 1
		end
		if GetTickCount() - aa.tick2 > aa.downTime then
			aa.state = 1
		end
	end
end



function Xerath:LoadSpells()
	
	Q = {range = 750, radius = 145, delay = 0.35 + Game.Latency()/1000, speed = math.huge, collision = false}    
	W = {range = 1100, radius = 200, delay = 0.5, speed = math.huge, collision = false}      
	E = {range = 1050, radius = 30, delay = 0.25, speed = 2300, collision = true}   
end

local spellIcons = {
Q = "http://vignette3.wikia.nocookie.net/leagueoflegends/images/5/57/Arcanopulse.png",
W = "http://vignette1.wikia.nocookie.net/leagueoflegends/images/2/20/Eye_of_Destruction.png",
E = "http://vignette2.wikia.nocookie.net/leagueoflegends/images/6/6f/Shocking_Orb.png",
R = "http://vignette1.wikia.nocookie.net/leagueoflegends/images/3/37/Rite_of_the_Arcane.png"
}


function Xerath:LoadMenu()
	Xerath.Menu = MenuElement({type = MENU, id = "Xerath", name = "PussyXerath[Reworked LazyXerath] "})
	Xerath.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu:MenuElement({type = MENU, id = "Killsteal", leftIcon = Icons["ks"]})
	self.Menu:MenuElement({type = MENU, id = "Misc", leftIcon = Icons["Misc"]})
	self.Menu:MenuElement({type = MENU, id = "Key", leftIcon = Icons["KeySet"]})
	self.Menu.Key:MenuElement({id = "Combo", name = "Combo", key = string.byte(" ")})
	self.Menu.Key:MenuElement({id = "Harass", name = "Harass | Mixed", key = string.byte("C")})
	self.Menu.Key:MenuElement({id = "Clear", name = "LaneClear | JungleClear", key = string.byte("V")})
	self.Menu.Key:MenuElement({id = "LastHit", name = "LastHit", key = string.byte("X")})
	self.Menu:MenuElement({id = "fastOrb", name = "Make Orbwalker fast again", value = true})	
	
	self.Menu.Combo:MenuElement({id = "useQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "legitQ", name = "Legit Q slider", value = 0.075, min = 0, max = 0.15, step = 0.01})
	self.Menu.Combo:MenuElement({id = "useW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "useE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "useR", name = "Use R", value = true})
	self.Menu.Combo:MenuElement({type = MENU, id = "R", name = "Ultimate Settings"})
	self.Menu.Combo.R:MenuElement({id = "useRself", name = "Start R manually", value = false})
	self.Menu.Combo.R:MenuElement({type = MENU, id = "BlackList", name = "Auto R blacklist"})
	self.Menu.Combo.R:MenuElement({id = "safeR", name = "Safety R stack", value = 1, min = 0, max = 2, step = 1})
	self.Menu.Combo.R:MenuElement({id = "targetChangeDelay", name = "Delay between target switch", value = 100, min = 0, max = 2000, step = 10})
	self.Menu.Combo.R:MenuElement({id = "castDelay", name = "Delay between casts", value = 150, min = 0, max = 500, step = 1})
	self.Menu.Combo.R:MenuElement({id = "useBlue", name = "Use Farsight Alteration", value = true})
	self.Menu.Combo.R:MenuElement({id = "useRkey", name = "On key press (close to mouse)", key = string.byte("Z")})
	
	self.Menu.Harass:MenuElement({id = "useQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "manaQ", name = " [Q]Mana-Manager", value = 40, min = 0, max = 100, step = 1})
	self.Menu.Harass:MenuElement({id = "useW", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "manaW", name = " [W]Mana-Manager", value = 60, min = 0, max = 100, step = 1})
	self.Menu.Harass:MenuElement({id = "useE", name = "Use E", value = false})
	self.Menu.Harass:MenuElement({id = "manaE", name = " [E]Mana-Manager", value = 80, min = 0, max = 100, step = 1})

	self.Menu.Clear:MenuElement({id = "useQ", name = "Use Q", value = true})
	self.Menu.Clear:MenuElement({id = "manaQ", name = " [Q]Mana-Manager", value = 40, min = 0, max = 100, step = 1})
	self.Menu.Clear:MenuElement({id = "hitQ", name = "min Minions Use Q", value = 2, min = 1, max = 6, step = 1})	
	self.Menu.Clear:MenuElement({id = "useW", name = "Use W", value = true})
	self.Menu.Clear:MenuElement({id = "manaW", name = " [W]Mana-Manager", value = 60, min = 0, max = 100, step = 1})	
	self.Menu.Clear:MenuElement({id = "hitW", name = "min Minions Use W", value = 2, min = 1, max = 6, step = 1})	
	
	self.Menu.Killsteal:MenuElement({id = "useQ", name = "Use Q to killsteal", value = true})
	self.Menu.Killsteal:MenuElement({id = "useW", name = "Use W to killsteal", value = true})
	self.Menu.Killsteal:MenuElement({id = "full", name = "AutoUse Q,W,R if killable", key = 84, toggle = true})	
	
	self.Menu.Misc:MenuElement({id = "Pred", name = "Prediction Settings", drop = {"LazyXerath Prediction", "Gamsteron Prediction", "HPred"}, value = 1})	
	self.Menu.Misc:MenuElement({id = "gapE", name = "Use E on gapcloser", value = true})
	self.Menu.Misc:MenuElement({id = "drawRrange", name = "Draw R range on MiniMap", value = true})
	
	self.Menu:MenuElement({id = "TargetSwitchDelay", name = "Delay between target switch", value = 350, min = 0, max = 750, step = 1})
	self:TargetMenu()
	self.Menu:MenuElement({id = "space", name = "Change the Key[COMBO] in your orbwalker!", type = SPACE, onclick = function() self.Menu.space:Hide() end})
end




function Xerath:IsQCharging()
	return myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "XerathArcanopulseChargeUp"
end

function Xerath:IsRCharging()
	return myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "XerathLocusOfPower2"
end

local create_menu_tick
function Xerath:TargetMenu()
	create_menu_tick = Callback.Add("Tick",function() 
		for i,v in pairs(self:GetEnemyHeroes()) do
			self:MenuRTarget(v,create_menu_tick)
		end
	end)
end

function Xerath:MenuRTarget(v,t)
	if self.Menu.Combo.R.BlackList[v.charName] ~= nil then
		-- Callback.Del("Tick",create_menu_tick)
	else
		self.Menu.Combo.R.BlackList:MenuElement({id = v.charName, name = "Blacklist: "..v.charName, value = false})
	end
end

function Xerath:Tick()
	if castSpell.state == 1 and GetTickCount() - castSpell.casting > Game.Latency() then
            Control.SetCursorPos(castSpell.mouse)
            castSpell.state = 0
    end
	if MyHeroReady() then

	
	if Xerath:GetMode() == "Combo" then   
		if aa.state ~= 2 then
			self:Combo()
		end
		self:ComboOrb()
	elseif Xerath:GetMode() == "Harass" then
		if aa.state ~= 2 then
			self:Harass()
		end
	
	elseif Xerath:GetMode() == "Clear" then
		if aa.state ~= 2 then
			self:Clear()
		end
	end	
	self:EnemyLoop()
	self:castingQ()
	self:castingR()
	self:useRonKey()
	self:EnemyLoop()
	self:KSFull()
	self:Auto()
	end
end

function Xerath:GetMode()
	if self.Menu.Key.Combo:Value() then return "Combo" end
	if self.Menu.Key.Harass:Value() then return "Harass" end
	if self.Menu.Key.Clear:Value() then return "Clear" end
	if self.Menu.Key.LastHit:Value() then return "LastHit" end
    return ""
end

function Xerath:Draw()
local textPos = myHero.pos:To2D()	
if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
end
if self.Menu.Killsteal.full:Value() then 
	Draw.Text("KS[Q,W,R]ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
else
	Draw.Text("KS[Q,W,R]OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
end

if myHero.dead then return end
	if self.Menu.Combo.R.useRkey:Value() then
		Draw.Circle(mousePos,500)
	end
	if self.Menu.Misc.drawRrange:Value() and self.chargeR == false then
		if Game.CanUseSpell(_R) == 0 then
			Draw.CircleMinimap(myHero.pos,2000 + 1220*myHero:GetSpellData(_R).level,1.5,Draw.Color(200,50,180,230))
		end
	end
end

function Xerath:ComboOrb()
	if self.chargeR == false and castSpell.state == 0 then
		local target = GetTarget(610)
		local tick = GetTickCount()
		if target then
			if aa.state == 1 and self.chargeQ == false and GetDistance(myHero.pos,target.pos) < 575 and ((Game.CanUseSpell(_Q) ~= 0 and Game.CanUseSpell(_W) ~= 0 and Game.CanUseSpell(_E) ~= 0) or GotBuff(myHero,"xerathascended2onhit") > 0 ) then
				CastAttack(target,575)
			elseif aa.state ~= 2 and tick - lastMove > 120 then
				Control.Move()
				lastMove = tick
			end
		else
			if aa.state ~= 2 and tick - lastMove > 120 then
				Control.Move()
				lastMove = tick
			end
		end
	end
end

function Xerath:castingQ()
	if self.chargeQ == true then
		self.Q.range = 750 + 500*(GetTickCount()-self.qTick)/1000
		if self.Q.range > 1500 then self.Q.range = 1500 end
	end
	local qBuff = GetBuffData(myHero,"XerathArcanopulseChargeUp")
	if self.chargeQ == false and qBuff.count > 0 then
		self.qTick = GetTickCount()
		self.chargeQ = true
	end
	if self.chargeQ == true and qBuff.count == 0 then
		self.chargeQ = false
		self.Q.range = 750
		if Control.IsKeyDown(HK_Q) == true then
			Control.KeyUp(HK_Q)
		end
	end
	if Control.IsKeyDown(HK_Q) == true and self.chargeQ == false then
		DelayAction(function()
			if Control.IsKeyDown(HK_Q) == true and self.chargeQ == false then
				Control.KeyUp(HK_Q)
			end
		end,0.3)
	end
	if Control.IsKeyDown(HK_Q) == true and Game.CanUseSpell(_Q) ~= 0 then
		DelayAction(function()
			if Control.IsKeyDown(HK_Q) == true then
				self.Q.range = 750
				Control.KeyUp(HK_Q)
			end
		end,0.01)
	end
end



function Xerath:castingR()
	local rBuff = GetBuffData(myHero,"XerathLocusOfPower2")
	if self.chargeR == false and rBuff.count > 0 then
		self.chargeR = true
		self.chargeRTick = GetTickCount()
		self.firstRCast = true
	end
	if self.chargeR == true and rBuff.count == 0 then
		self.chargeR = false
		self.R_target = nil
	end
	if self.chargeR == true then
		if self.CanUseR == true and Game.CanUseSpell(_R) ~= 0 and GetTickCount() - self.chargeRTick > 600 then
			self.CanUseR = false
			self.R_Stacks = self.R_Stacks - 1
			self.firstRCast = false
			self.lastRtick = GetTickCount()
		end
		if self.CanUseR == false and Game.CanUseSpell(_R) == 0 then
			self.CanUseR = true
		end
	end
	if self.chargeR == false then
		if Game.CanUseSpell(_R) == 0 then
			self.R_Stacks = 2+myHero:GetSpellData(_R).level
		end
	end
end

function Xerath:KSFull()
local target = self:GetRTarget(1100,2200 + 1220*myHero:GetSpellData(_R).level)
if target == nil then return end
local hp = target.health + target.shieldAP + target.shieldAD
local rRange = 2200 + 1220*myHero:GetSpellData(_R).level
local Qdmg = CalcuMagicalDamage(myHero,target,40 + 40*myHero:GetSpellData(_Q).level + 0.75*myHero.ap)	
local Wdmg = CalcuMagicalDamage(myHero,target,45 + 45*myHero:GetSpellData(_W).level + 0.9*myHero.ap)
local stackdmg = 2 + myHero:GetSpellData(_R).level
local Rdmg = CalcuMagicalDamage(myHero,target,160 + 40 * myHero:GetSpellData(_R).level + myHero.ap * 0.43) * stackdmg
local Fdmg = (Qdmg + Wdmg + Rdmg)	
	if self.Menu.Killsteal.full:Value() then
		if self.chargeR == false and hp <= Fdmg then
			if self.Menu.Misc.Pred:Value() == 1 then
				self:useQ()
				self:useW()

			elseif self.Menu.Misc.Pred:Value() == 2 then
				self:useQGSO()
				self:useWGSO()

			elseif self.Menu.Misc.Pred:Value() == 3 then
				self:useQHPred()			
				self:useWHPred()
				
			end
		end	
		if hp <= Rdmg and self.chargeR == false and Game.CanUseSpell(_R) == 0 and IsValid(target) and GetDistanceSqr(myHero.pos,target.pos) > 1000 and GetDistanceSqr(myHero.pos,target.pos) <= rRange then
			self:startR(target)
		end
		
	self:AutoR()
	end
end

function Xerath:Auto()
if myHero.dead then return end
local target = self:GetRTarget(1100,2200 + 1220*myHero:GetSpellData(_R).level)
if target == nil then return end	
local blue = GetInventorySlotItem(3363)   	
	if self.chargeR == true and not target.visible then		
		if blue and GetDistanceSqr(myHero.pos,target.pos) < 3800 then
        local bluePred = GetPred(target,math.huge,0.25)
			CastSpellMM(ItemHotKey[blue],bluePred,4000,50)
        
		end	
	end
end	

function Xerath:Combo()
	if self.chargeR == false then
		if self.Menu.Misc.Pred:Value() == 1 then
			if self.Menu.Combo.useW:Value() then
				self:useW()
			end
			if self.Menu.Combo.useE:Value() then
				self:useE()
			end
			if self.Menu.Combo.useQ:Value() then
				self:useQ()
			end
		elseif self.Menu.Misc.Pred:Value() == 2 then
			if self.Menu.Combo.useW:Value() then
				self:useWGSO()
			end
			if self.Menu.Combo.useE:Value() then
				self:useEGSO()
			end
			if self.Menu.Combo.useQ:Value() then
				self:useQGSO()
			end	
		elseif self.Menu.Misc.Pred:Value() == 3 then
			if self.Menu.Combo.useW:Value() then
				self:useWHPred()
			end
			if self.Menu.Combo.useE:Value() then
				self:useEHPred()
			end
			if self.Menu.Combo.useQ:Value() then
				self:useQHPred()
			end				
		end	
	end
	self:useR()
end

function Xerath:Harass()
	if self.chargeR == false then
	local mp = GetPercentMP(myHero)
		if self.Menu.Misc.Pred:Value() == 1 then			
			if self.Menu.Harass.useW:Value() and mp > self.Menu.Harass.manaW:Value() then
				self:useW()
			end
			if self.Menu.Harass.useE:Value() and mp > self.Menu.Harass.manaE:Value() then
				self:useE()
			end
			if self.Menu.Harass.useQ:Value() and (mp > self.Menu.Harass.manaQ:Value() or self.chargeQ == true) then	
				self:useQ()
			end
		elseif self.Menu.Misc.Pred:Value() == 2 then			
			if self.Menu.Harass.useW:Value() and mp > self.Menu.Harass.manaW:Value() then
				self:useWGSO()
			end
			if self.Menu.Harass.useE:Value() and mp > self.Menu.Harass.manaE:Value() then
				self:useEGSO()
			end
			if self.Menu.Harass.useQ:Value() and (mp > self.Menu.Harass.manaQ:Value() or self.chargeQ == true) then	
				self:useQGSO()
			end	
		elseif self.Menu.Misc.Pred:Value() == 3 then			
			if self.Menu.Harass.useW:Value() and mp > self.Menu.Harass.manaW:Value() then
				self:useWHPred()
			end
			if self.Menu.Harass.useE:Value() and mp > self.Menu.Harass.manaE:Value() then
				self:useEHPred()
			end
			if self.Menu.Harass.useQ:Value() and (mp > self.Menu.Harass.manaQ:Value() or self.chargeQ == true) then	
				self:useQHPred()
			end			
		end	
	end
end

function Xerath:Clear()
	if self.chargeR == false then
		local mp = GetPercentMP(myHero)
		if self.Menu.Clear.useW:Value() and mp > self.Menu.Clear.manaW:Value() then
			self:clearW()
		end
		if self.Menu.Clear.useQ:Value() and (mp > self.Menu.Clear.manaQ:Value() or self.chargeQ == true) then	
			self:clearQ()
		end
	end
end

function Xerath:clearQ()
	if Game.CanUseSpell(_Q) == 0 and castSpell.state == 0 then
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		local qPred = GetPred(minion,math.huge,0.35 + Game.Latency()/1000)
		local qPred2 = GetPred(minion,math.huge,1.0)
		local count = GetMinionCount(150, minion)		
			if minion.team == TEAM_ENEMY and qPred and qPred2 then
				if GetDistance(myHero.pos,qPred2) < 1400 and count >= self.Menu.Clear.hitQ:Value() then
					self:startQ(minion)
				end
				if self.chargeQ == true then
					self:useQonMinion(minion,qPred)
				end
			end
			if minion.team == TEAM_JUNGLE and qPred and qPred2 then
				if GetDistance(myHero.pos,qPred2) < 1400 then
					self:startQ(minion)
				end
				if self.chargeQ == true then
					self:useQonMinion(minion,qPred)
				end
			end			
		end
	end
end

function Xerath:useQ()
	if Game.CanUseSpell(_Q) == 0 and castSpell.state == 0 then
		local target = self:GetTarget(1500,"AP")
		if target then
			local qPred = GetPred(target,math.huge,0.35 + Game.Latency()/1000)
			local qPred2 = GetPred(target,math.huge,1.0)
			if qPred and qPred2 then
				if GetDistance(myHero.pos,qPred2) < 1400 then
					self:startQ(target)
				end
				if self.chargeQ == true then
					self:useQclose(target,qPred)
					self:useQCC(target)
					self:useQonTarget(target,qPred)
				end
			end
		end
	end
end

function Xerath:useQGSO()
	if Game.CanUseSpell(_Q) == 0 and castSpell.state == 0 then
		local target = self:GetTarget(1500,"AP")
		if target then
			local qPred2 = GetPred(target,math.huge,1.0)
			if qPred2 then
				if GetDistance(myHero.pos,qPred2) < 1400 then
					self:startQ(target)
				end
				if self.chargeQ == true then
					self:useQcloseGSO(target)
					self:useQCC(target)
					self:useQonTargetGSO(target)
				end
			end
		end
	end
end

function Xerath:useQHPred()
	if Game.CanUseSpell(_Q) == 0 and castSpell.state == 0 then
		local target = self:GetTarget(1500,"AP")
		if target then
			local qPred2 = GetPred(target,math.huge,1.0)
			if qPred2 then
				if GetDistance(myHero.pos,qPred2) < 1400 then
					self:startQ(target)
				end
				if self.chargeQ == true then
					self:useQcloseHPred(target)
					self:useQCC(target)
					self:useQonTargetHPred(target)
				end
			end
		end
	end
end

function Xerath:clearW()
	if Game.CanUseSpell(_W) == 0 and self.chargeQ == false and castSpell.state == 0 then
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		local count = GetMinionCount(250, minion)	
				if self.lastMinion == nil then self.lastMinion = minion end
				if minion.team == TEAM_ENEMY and minion and (minion == self.lastMinion or (GetDistance(minion.pos,self.lastMinion.pos) > 400 and GetTickCount() - self.lastMinion_tick > self.Menu.TargetSwitchDelay:Value())) then

						if count >= self.Menu.Clear.hitW:Value() then
							Control.CastSpell(HK_W,minion.pos)
						end	
				elseif minion.team == TEAM_JUNGLE then
					Control.CastSpell(HK_W, minion.pos)
				end	
			end	
		end
	end


function Xerath:useW()
	if Game.CanUseSpell(_W) == 0 and self.chargeQ == false and castSpell.state == 0 then
		local target = self:GetTarget(self.W.range,"AP")
		if self.lastTarget == nil then self.lastTarget = target end
		if target and (target == self.lastTarget or (GetDistance(target.pos,self.lastTarget.pos) > 400 and GetTickCount() - self.lastTarget_tick > self.Menu.TargetSwitchDelay:Value())) then
			local wPred = GetPred(target,math.huge,0.5)
			if wPred then
				self:useWdash(target)
				self:useWCC(target)
				self:useWkill(target,wPred)
				self:useWhighHit(target,wPred)
			end
		end
	end
end

function Xerath:useWGSO()
	if Game.CanUseSpell(_W) == 0 and self.chargeQ == false and castSpell.state == 0 then
		local target = self:GetTarget(self.W.range,"AP")
		if self.lastTarget == nil then self.lastTarget = target end
		if target and (target == self.lastTarget or (GetDistance(target.pos,self.lastTarget.pos) > 400 and GetTickCount() - self.lastTarget_tick > self.Menu.TargetSwitchDelay:Value())) then
			self:useWdashGSO(target)
			self:useWCC(target)
			self:useWkillGSO(target)
			self:useWhighHitGSO(target)
		end
	end
end

function Xerath:useWHPred()
	if Game.CanUseSpell(_W) == 0 and self.chargeQ == false and castSpell.state == 0 then
		local target = self:GetTarget(self.W.range,"AP")
		if self.lastTarget == nil then self.lastTarget = target end
		if target and (target == self.lastTarget or (GetDistance(target.pos,self.lastTarget.pos) > 400 and GetTickCount() - self.lastTarget_tick > self.Menu.TargetSwitchDelay:Value())) then
			self:useWdashHPred(target)
			self:useWCC(target)
			self:useWkillHPred(target)
			self:useWhighHitHPred(target)
		end
	end
end


function Xerath:useE()
	if Game.CanUseSpell(_E) == 0 and self.chargeQ == false and castSpell.state == 0 then
		self:useECC()
		local target = self:GetTarget(self.E.range,"AP")
		if self.lastTarget == nil then self.lastTarget = target end
		if target and (target == self.lastTarget or (GetDistance(target.pos,self.lastTarget.pos) > 400 and GetTickCount() - self.lastTarget_tick > self.Menu.TargetSwitchDelay:Value())) then
			local ePred = GetPred(target,self.E.speed,self.E.delay)
			if ePred and target:GetCollision(self.E.width,self.E.speed,self.E.delay) == 0 then
				self:useEdash(target)
				self:useEbrainAFK(target,ePred)
			end
		end
	end
end

function Xerath:useEGSO()
	if Game.CanUseSpell(_E) == 0 and self.chargeQ == false and castSpell.state == 0 then
		self:useECC()
		local target = self:GetTarget(self.E.range,"AP")
		if self.lastTarget == nil then self.lastTarget = target end
		if target and (target == self.lastTarget or (GetDistance(target.pos,self.lastTarget.pos) > 400 and GetTickCount() - self.lastTarget_tick > self.Menu.TargetSwitchDelay:Value())) then
			if target:GetCollision(self.E.width,self.E.speed,self.E.delay) == 0 then
				self:useEdashGSO(target)
				self:useEbrainAFKGSO(target)
			end
		end
	end
end

function Xerath:useEHPred()
	if Game.CanUseSpell(_E) == 0 and self.chargeQ == false and castSpell.state == 0 then
		self:useECC()
		local target = self:GetTarget(self.E.range,"AP")
		if self.lastTarget == nil then self.lastTarget = target end
		if target and (target == self.lastTarget or (GetDistance(target.pos,self.lastTarget.pos) > 400 and GetTickCount() - self.lastTarget_tick > self.Menu.TargetSwitchDelay:Value())) then
			if target:GetCollision(self.E.width,self.E.speed,self.E.delay) == 0 then
				self:useEdashHPred(target)
				self:useEbrainAFKHPred(target)
			end
		end
	end
end

function Xerath:useR()
	if Game.CanUseSpell(_R) == 0 and self.chargeQ == false and castSpell.state == 0 then
		local target = self:GetRTarget(1100,2200 + 1220*myHero:GetSpellData(_R).level)
		if target then
			self:useRkill(target)
			if ((self.firstRCast == true or self.chargeR ~= true) or (GetTickCount() - self.lastRtick > 500 + self.Menu.Combo.R.targetChangeDelay:Value() and GetDistance(target.pos,self.R_target.pos) > 750) or (GetDistance(target.pos,self.R_target.pos) <= 850)) and target ~= self.R_target then
				self.R_target = target
			end
			-- if target == self.R_target or (target ~= self.R_target and GetDistance(target.pos,self.R_target.pos) > 600 and GetTickCount() - self.lastRtick > 800 + self.Menu.Combo.R.targetChangeDelay:Value()) then
			if target == self.R_target then
				if self.chargeR == true and GetTickCount() - self.lastRtick >= 800 + self.Menu.Combo.R.castDelay:Value() then
					if target and not IsImmune(target) and (Game.Timer() - OnWaypoint(target).time > 0.05 and (Game.Timer() - OnWaypoint(target).time < 0.20 or Game.Timer() - OnWaypoint(target).time > 1.25) or self:IsImmobileTarget(target) == true or (self.firstRCast == true and OnVision(target).state == false) ) then
						local rPred = GetPred(target,math.huge,0.45)
						if rPred:ToScreen().onScreen then
							CastSpell(HK_R,rPred,2200 + 1320*myHero:GetSpellData(_R).level,100)
							self.R_target = target
						else 
							CastSpellMM(HK_R,rPred,2200 + 1320*myHero:GetSpellData(_R).level,100)
							self.R_target = target
						end
					end
				end
			end
		end
	end
end

function Xerath:EnemyLoop()
	if aa.state ~= 2 and castSpell.state == 0 then
		for i,target in pairs(self:GetEnemyHeroes()) do
			if not target.dead and target.isTargetable and target.valid and (OnVision(target).state == true or (OnVision(target).state == false and GetTickCount() - OnVision(target).tick < 500)) then
				if self.Menu.Killsteal.useQ:Value() then
					if Game.CanUseSpell(_Q) == 0 and GetDistance(myHero.pos,target.pos) < 1400 then
						local hp = target.health + target.shieldAP + target.shieldAD
						local dmg = CalcuMagicalDamage(myHero,target,40 + 40*myHero:GetSpellData(_Q).level + (0.75*myHero.ap))
						if hp < dmg then
							if self.chargeQ == false then
								local qPred2 = GetPred(target,math.huge,1.25)
								if GetDistance(qPred2,myHero.pos) < 1400 then
									Control.KeyDown(HK_Q)
								end
							else
								local qPred = GetPred(target,math.huge,0.35 + Game.Latency()/1000)
								self:useQonTarget(target,qPred)
							end
						end
					end
				end
						
					
				
				if self.Menu.Killsteal.useW:Value() then
					if Game.CanUseSpell(_W) == 0 and GetDistance(myHero.pos,target.pos) < self.W.range then
						local wPred = GetPred(target,math.huge,0.55)
						self:useWkill(target,wPred)
					end
				end
				if self.Menu.Misc.gapE:Value() then
					if GetDistance(target.pos,myHero.pos) < 500 then
						self:useEdash(target)
					end
				end
			end
		end
	end
end

function Xerath:startQ(target)
	local start = true
	if self.Menu.Combo.useE:Value() and Game.CanUseSpell(_E) == 0 and GetDistance(target.pos,myHero.pos) < 650 and target:GetCollision(self.E.width,self.E.speed,self.E.delay) == 0 then start = false end
	if Game.CanUseSpell(_Q) == 0 and self.chargeQ == false  and start == true then
		Control.KeyDown(HK_Q)
	end
end

function Xerath:startQ(minion)
	if Game.CanUseSpell(_Q) == 0 and self.chargeQ == false then
		Control.KeyDown(HK_Q)
	end
end

function Xerath:useQCC(target)
	if GetDistance(myHero.pos,target.pos) < self.Q.range - 20 then
		if self:IsImmobileTarget(target) == true then
			ReleaseSpell(HK_Q,target.pos,self.Q.range,100)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end
	end
end

function Xerath:useQonTarget(target,qPred)
	if  Game.Timer() - OnWaypoint(target).time > 0.05 + self.Menu.Combo.legitQ:Value() and (((Game.Timer() - OnWaypoint(target).time < 0.15 + self.Menu.Combo.legitQ:Value() or Game.Timer() - OnWaypoint(target).time > 1.0) and OnVision(target).state == true) or (OnVision(target).state == false)) and GetDistance(myHero.pos,qPred) < self.Q.range - target.boundingRadius then
		ReleaseSpell(HK_Q,qPred,self.Q.range,100)
		self.lastTarget = target
		self.lastTarget_tick = GetTickCount() + 200
	end
end

function Xerath:useQonTargetGSO(target)
	if  Game.Timer() - OnWaypoint(target).time > 0.05 + self.Menu.Combo.legitQ:Value() and (((Game.Timer() - OnWaypoint(target).time < 0.15 + self.Menu.Combo.legitQ:Value() or Game.Timer() - OnWaypoint(target).time > 1.0) and OnVision(target).state == true) or (OnVision(target).state == false)) and GetDistance(myHero.pos,target.pos) < self.Q.range - target.boundingRadius then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= _G.HITCHANCE_NORMAL then
			ReleaseSpell(HK_Q,pred.CastPosition,self.Q.range,100)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end	
	end
end

function Xerath:useQonTargetHPred(target)
	if  Game.Timer() - OnWaypoint(target).time > 0.05 + self.Menu.Combo.legitQ:Value() and (((Game.Timer() - OnWaypoint(target).time < 0.15 + self.Menu.Combo.legitQ:Value() or Game.Timer() - OnWaypoint(target).time > 1.0) and OnVision(target).state == true) or (OnVision(target).state == false)) and GetDistance(myHero.pos,target.pos) < self.Q.range - target.boundingRadius then
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
		if hitRate and hitRate >= 1 then
			ReleaseSpell(HK_Q,aimPosition,self.Q.range,100)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end	
	end
end

function Xerath:useQclose(target,qPred)
	if GetDistance(myHero.pos,qPred) < 750 and Game.Timer() - OnWaypoint(target).time > 0.05 then
		ReleaseSpell(HK_Q,qPred,self.Q.range,75)
		self.lastTarget = target
		self.lastTarget_tick = GetTickCount() + 200
	end
end

function Xerath:useQcloseGSO(target)
	if GetDistance(myHero.pos,target.pos) < 750 and Game.Timer() - OnWaypoint(target).time > 0.05 then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= _G.HITCHANCE_NORMAL then
			ReleaseSpell(HK_Q,pred.CastPosition,self.Q.range,75)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end	
	end
end

function Xerath:useQcloseHPred(target)
	if GetDistance(myHero.pos,target.pos) < 750 and Game.Timer() - OnWaypoint(target).time > 0.05 then
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, Q.range, Q.delay, Q.speed, Q.radius, Q.collision)
		if hitRate and hitRate >= 1 then
			ReleaseSpell(HK_Q,aimPosition,self.Q.range,75)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end	
	end
end

function Xerath:useQonMinion(minion,qPred)
	if Game.Timer() - OnWaypoint(minion).time > 0.05 + self.Menu.Combo.legitQ:Value() and (((Game.Timer() - OnWaypoint(minion).time < 0.15 + self.Menu.Combo.legitQ:Value() or Game.Timer() - OnWaypoint(minion).time > 1.0) and OnVision(minion).state == true) or (OnVision(minion).state == false)) and GetDistance(myHero.pos,qPred) < self.Q.range - minion.boundingRadius then
		ReleaseSpell(HK_Q,qPred,self.Q.range,100)
		self.lastMinion = minion
		self.lastMinion_tick = GetTickCount() + 200
	end
end

function Xerath:useWCC(target)
	if GetDistance(myHero.pos,target.pos) < self.W.range - 50 then
		if self:IsImmobileTarget(target) == true then
			CastSpell(HK_W,target.pos,self.W.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end
	end
end

function Xerath:useWhighHit(target,wPred)
	local afterE = false
	if Game.CanUseSpell(_E) == 0 and myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana <= myHero.mana and GetDistance(myHero.pos,target.pos) <= 750 then
		if target:GetCollision(self.E.width,self.E.speed,self.E.delay) == 0 then
			afterE = true
		end
	end
	if Game.Timer() - OnWaypoint(target).time > 0.05 and (Game.Timer() - OnWaypoint(target).time < 0.20 or Game.Timer() - OnWaypoint(target).time > 1.25) and GetDistance(myHero.pos,wPred) < self.W.range - 50 and afterE == false then
		CastSpell(HK_W,wPred,self.W.range)
		self.lastTarget = target
		self.lastTarget_tick = GetTickCount() + 200
	end
end

function Xerath:useWhighHitGSO(target)
	local afterE = false
	if Game.CanUseSpell(_E) == 0 and myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana <= myHero.mana and GetDistance(myHero.pos,target.pos) <= 750 then
		if target:GetCollision(self.E.width,self.E.speed,self.E.delay) == 0 then
			afterE = true
		end
	end
	if Game.Timer() - OnWaypoint(target).time > 0.05 and (Game.Timer() - OnWaypoint(target).time < 0.20 or Game.Timer() - OnWaypoint(target).time > 1.25) and GetDistance(myHero.pos,target.pos) < self.W.range - 50 and afterE == false then
		local pred = GetGamsteronPrediction(target, WData, myHero)
		if pred.Hitchance >= _G.HITCHANCE_NORMAL then
			CastSpell(HK_W,pred.CastPosition,self.W.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end	
	end
end

function Xerath:useWhighHitHPred(target)
	local afterE = false
	if Game.CanUseSpell(_E) == 0 and myHero:GetSpellData(_W).mana + myHero:GetSpellData(_E).mana <= myHero.mana and GetDistance(myHero.pos,target.pos) <= 750 then
		if target:GetCollision(self.E.width,self.E.speed,self.E.delay) == 0 then
			afterE = true
		end
	end
	if Game.Timer() - OnWaypoint(target).time > 0.05 and (Game.Timer() - OnWaypoint(target).time < 0.20 or Game.Timer() - OnWaypoint(target).time > 1.25) and GetDistance(myHero.pos,target.pos) < self.W.range - 50 and afterE == false then
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, W.range, W.delay, W.speed, W.radius, W.collision)
		if hitRate and hitRate >= 1 then
			CastSpell(HK_W,aimPosition,self.W.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end	
	end
end

function Xerath:useWdash(target)
	if OnWaypoint(target).speed > target.ms then
		local wPred = GetPred(target,math.huge,0.5)
		if GetDistance(myHero.pos,wPred) < self.W.range then
			CastSpell(HK_W,wPred,self.W.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end
	end
end

function Xerath:useWdashGSO(target)
	if OnWaypoint(target).speed > target.ms then
		local pred = GetGamsteronPrediction(target, WData, myHero)
		if GetDistance(myHero.pos,target.pos) < self.W.range and pred.Hitchance >= _G.HITCHANCE_NORMAL then
			CastSpell(HK_W,pred.CastPosition,self.W.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end
	end
end

function Xerath:useWdashHPred(target)
	if OnWaypoint(target).speed > target.ms then
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, W.range, W.delay, W.speed, W.radius, W.collision)
		if GetDistance(myHero.pos,target.pos) < self.W.range and hitRate and hitRate >= 1 then
			CastSpell(HK_W,aimPosition,self.W.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end
	end
end

function Xerath:useWkill(target,wPred)
	if Game.Timer() - OnWaypoint(target).time > 0.05 and GetDistance(myHero.pos,wPred) < self.W.range then
		if target.health + target.shieldAP + target.shieldAD < CalcuMagicalDamage(myHero,target,30 + 30*myHero:GetSpellData(_W).level + (0.6*myHero.ap)) then
			CastSpell(HK_W,wPred,self.W.range)
		end
	end
end

function Xerath:useWkillGSO(target)
	if Game.Timer() - OnWaypoint(target).time > 0.05 and GetDistance(myHero.pos,target.pos) < self.W.range then
		if target.health + target.shieldAP + target.shieldAD < CalcuMagicalDamage(myHero,target,30 + 30*myHero:GetSpellData(_W).level + (0.6*myHero.ap)) then
			local pred = GetGamsteronPrediction(target, WData, myHero)
			if pred.Hitchance >= _G.HITCHANCE_NORMAL then
				CastSpell(HK_W,pred.CastPosition,self.W.range)
			end	
		end
	end
end

function Xerath:useWkillHPred(target)
	if Game.Timer() - OnWaypoint(target).time > 0.05 and GetDistance(myHero.pos,target.pos) < self.W.range then
		if target.health + target.shieldAP + target.shieldAD < CalcuMagicalDamage(myHero,target,30 + 30*myHero:GetSpellData(_W).level + (0.6*myHero.ap)) then
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, W.range, W.delay, W.speed, W.radius, W.collision)
			if hitRate and hitRate >= 1 then
				CastSpell(HK_W,aimPosition,self.W.range)
			end	
		end
	end
end

function Xerath:useECC()
	local target = GetTarget(self.E.range,"AP")
	if target then
		if GetDistance(myHero.pos,target.pos) < self.E.range - 20 then
			if self:IsImmobileTarget(target) == true and target:GetCollision(self.E.width,self.E.speed,0.25) == 0 then
				CastSpell(HK_E,target.pos,5000)
				self.lastTarget = target
				self.lastTarget_tick = GetTickCount() + 200
			end
		end
	end
end

function Xerath:useEbrainAFK(target,ePred)
	if Game.Timer() - OnWaypoint(target).time > 0.05 and (Game.Timer() - OnWaypoint(target).time < 0.125 or Game.Timer() - OnWaypoint(target).time > 1.25) and GetDistance(myHero.pos,ePred) < self.E.range then
		if GetDistance(myHero.pos,ePred) <= 800 then
			CastSpell(HK_E,ePred,self.E.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		else
			if target.ms < 340 then
				CastSpell(HK_E,ePred,self.E.range)
				self.lastTarget = target
				self.lastTarget_tick = GetTickCount() + 200
			end
		end
	end
end

function Xerath:useEbrainAFKGSO(target)
	if Game.Timer() - OnWaypoint(target).time > 0.05 and (Game.Timer() - OnWaypoint(target).time < 0.125 or Game.Timer() - OnWaypoint(target).time > 1.25) and GetDistance(myHero.pos,target.pos) < self.E.range then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if GetDistance(myHero.pos,target.pos) <= 800 and pred.Hitchance >= _G.HITCHANCE_NORMAL then
			CastSpell(HK_E,pred.CastPosition,self.E.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		else
			if target.ms < 340 then
				CastSpell(HK_E,pred.CastPosition,self.E.range)
				self.lastTarget = target
				self.lastTarget_tick = GetTickCount() + 200
			end
		end
	end
end

function Xerath:useEbrainAFKHPred(target)
	if Game.Timer() - OnWaypoint(target).time > 0.05 and (Game.Timer() - OnWaypoint(target).time < 0.125 or Game.Timer() - OnWaypoint(target).time > 1.25) and GetDistance(myHero.pos,target.pos) < self.E.range then
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
		if GetDistance(myHero.pos,target.pos) <= 800 and hitRate and hitRate >= 1 then
			CastSpell(HK_E,aimPosition,self.E.range)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		else
			if target.ms < 340 then
				CastSpell(HK_E,aimPosition,self.E.range)
				self.lastTarget = target
				self.lastTarget_tick = GetTickCount() + 200
			end
		end
	end
end

function Xerath:useEdash(target)
	if OnWaypoint(target).speed > target.ms then
		local ePred = GetPred(target,math.huge,0.5)
		if GetDistance(myHero.pos,ePred) < self.E.range and target:GetCollision(self.E.width,self.E.speed,1) == 0 then
			CastSpell(HK_E,ePred,5000)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end
	end
end

function Xerath:useEdashGSO(target)
	if OnWaypoint(target).speed > target.ms then
		local pred = GetGamsteronPrediction(target, EData, myHero)
		if GetDistance(myHero.pos,target.pos) < self.E.range and pred.Hitchance >= _G.HITCHANCE_NORMAL then
			CastSpell(HK_E,pred.CastPosition,5000)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end
	end
end

function Xerath:useEdashHPred(target)
	if OnWaypoint(target).speed > target.ms then
		local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, E.range, E.delay, E.speed, E.radius, E.collision)
		if GetDistance(myHero.pos,target.pos) < self.E.range and hitRate and hitRate >= 1 then
			CastSpell(HK_E,aimPosition,5000)
			self.lastTarget = target
			self.lastTarget_tick = GetTickCount() + 200
		end
	end
end

function Xerath:startR(target)
	local eAallowed = 0
	if GetDistance(myHero.pos,target.pos) < 1200 + 250*myHero:GetSpellData(_R).level and target.visible then
		eAallowed = 1
	end
	if self.chargeR == false and CountEnemiesInRange(myHero.pos,2500) <= eAallowed and GetDistance(myHero.pos,target.pos) > 1300 and not (GetDistance(myHero.pos,target.pos) < 1500 and Game.CanUseSpell(_Q) == 0) and (OnVision(target).state == true or (OnVision(target).state == false and GetTickCount() - OnVision(target).tick < 50)) then
		if self.Menu.Combo.R.useBlue:Value() then
			local blue = GetItemSlot(myHero,3363)
			if blue > 0 and CanUseSpell(blue) and OnVision(target).state == false and GetDistance(myHero.pos,target.pos) < 3800 then
				local bluePred = GetPred(target,math.huge,0.25)
				CastSpellMM(HK_ITEM_7,bluePred,4000,50)
			else
				CastSpell(HK_R,myHero.pos + Vector(myHero.pos,target.pos):Normalized() * math.random(500,800),2200 + 1320*myHero:GetSpellData(_R).level,50)
			end
		else
			CastSpell(HK_R,myHero.pos + Vector(myHero.pos,target.pos):Normalized() * math.random(500,800),2200 + 1320*myHero:GetSpellData(_R).level,50)
		end
		self.R_target = target
		self.firstRCast = true
	end
end

function Xerath:useRkill(target)
	if self.chargeR == false and self.Menu.Combo.R.BlackList[target.charName] ~= nil and not self.Menu.Combo.R.useRself:Value() and self.Menu.Combo.R.BlackList[target.charName]:Value() == false then
		local rDMG = CalcuMagicalDamage(myHero,target,160+40*myHero:GetSpellData(_R).level + (myHero.ap*0.43))*(2+myHero:GetSpellData(_R).level - self.Menu.Combo.R.safeR:Value())
		if target.health + target.shieldAP + target.shieldAD < rDMG then
			local delay =  math.floor((target.health + target.shieldAP + target.shieldAD)/(rDMG/(2+myHero:GetSpellData(_R).level))) * 0.8
			if GetDistance(myHero.pos,target.pos) + target.ms*delay <= 2200 + 1320*myHero:GetSpellData(_R).level and not IsImmune(target) then
				self:startR(target)
			end
		end
	end
end

function Xerath:useRonKey()
	if self.Menu.Combo.R.useRkey:Value() then
		if self.chargeR == true and Game.CanUseSpell(_R) == 0 then
			local target = self:GetTarget(500,"AP",mousePos)
			if not target then target = self:GetTarget(2200 + 1320*myHero:GetSpellData(_R).level,"AP") end
			if target and not IsImmune(target) then
				
				local rPred = GetPred(target,math.huge,0.45)
				if rPred:ToScreen().onScreen then
					CastSpell(HK_R,rPred,2200 + 1320*myHero:GetSpellData(_R).level,100)
					self.R_target = target
					self.R_target_tick = GetTickCount()
				else
					CastSpellMM(HK_R,rPred,2200 + 1320*myHero:GetSpellData(_R).level,100)
					self.R_target = target
					self.R_target_tick = GetTickCount()
				end
			end
		end
	end
end

function Xerath:AutoR()

	if self.chargeR == true and Game.CanUseSpell(_R) == 0 then
		
		if not target then target = self:GetTarget(2200 + 1320*myHero:GetSpellData(_R).level,"AP") end
		if target and not IsImmune(target) then
				
			local rPred = GetPred(target,math.huge,0.45)
			if rPred:ToScreen().onScreen then
				CastSpell(HK_R,rPred,2200 + 1320*myHero:GetSpellData(_R).level,100)
				self.R_target = target
				self.R_target_tick = GetTickCount()
			else
				CastSpellMM(HK_R,rPred,2200 + 1320*myHero:GetSpellData(_R).level,100)
				self.R_target = target
				self.R_target_tick = GetTickCount()
				
			end
		end
	end
end

local _targetSelect
local _targetSelectTick = GetTickCount()
function Xerath:GetRTarget(closeRange,maxRange)
local tick = GetTickCount()
if tick - _targetSelectTick > 200 then
	_targetSelectTick = tick
	local killable = {}
		for i,hero in pairs(self:GetEnemyHeroes()) do
			if hero.isEnemy and hero.valid and not hero.dead and hero.isTargetable and (OnVision(hero).state == true or (OnVision(hero).state == false and GetTickCount() - OnVision(hero).tick < 50)) and hero.isTargetable and GetDistance(myHero.pos,hero.pos) < maxRange then
				local stacks = self.R_Stacks
				local rDMG = CalcuMagicalDamage(myHero,hero,160+40*myHero:GetSpellData(_R).level + (myHero.ap*0.43))*stacks
				if hero.health + hero.shieldAP + hero.shieldAD < rDMG then
					killable[hero.networkID] = hero
				end
			end
		end
		local target
		local p = 0
		local oneshot = false
		for i,kill in pairs(killable) do
			if (CalcuMagicalDamage(myHero,kill,160+40*myHero:GetSpellData(_R).level + (myHero.ap*0.43)) > kill.health + kill.shieldAP + kill.shieldAD) then
				if p < Priority(kill.charName) then
					p = Priority(kill.charName)
					target = kill
					oneshot = true
				end
			else
				if p < Priority(kill.charName) and oneshot == false then
					p = Priority(kill.charName)
					target = kill
				end
			end
		end
		if target then
			_targetSelect = target
			return _targetSelect
		end
	if CountEnemiesInRange(myHero.pos,closeRange) >= 2 then
		local t = GetTarget(closeRange,"AP")
		_targetSelect = t
		return _targetSelect
	else
		local t = GetTarget(maxRange,"AP")
		_targetSelect = t
		return _targetSelect
	end
end

if _targetSelect and not _targetSelect.dead then
	return _targetSelect
else
	_targetSelect = GetTarget(maxRange,"AP")
	return _targetSelect
end

end



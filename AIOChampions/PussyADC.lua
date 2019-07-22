local Adc = {"Kalista","Tristana"}
if table.contains(Adc, myHero.charName) then
	_G[myHero.charName]()
end	

function OnLoad()
	AutoUpdate()

end

    local Version = 0.1
    
    local Files = {
        Lua = {
            Path = COMMON_PATH,
            Name = "PussyADC.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyAIOTest.lua"
        },
        Version = {
            Path = COMMON_PATH,
            Name = "PussyADC.version",
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
            print("New PussyADC Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end	
	end




-------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Kalista"

local ChampTable = {["Blitzcrank"] = {charName = "Blitzcrank"}, ["Skarner"] = {charName = "Skarner"}, ["TahmKench"] = {charName = "TahmKench"}, ["Sion"] = {charName = "Sion"}}

function Kalista:__init()
	
	BoundAlly = nil
	stacks = 0
	QData =
	{
	Type = _G.SPELLTYPE_LINE, Delay = 0.25, Radius = 40, Range = 1150, Speed = 2100, Collision = true, MaxCollision = 0, CollisionTypes = {_G.COLLISION_MINION, _G.COLLISION_YASUOWALL}
	}

 
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



function Kalista:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Kalista", name = "PussyKalista"})

	--AutoQ
	self.Menu:MenuElement({type = MENU, id = "AutoQ", leftIcon = Icons["AutoQImmo"]})
	self.Menu.AutoQ:MenuElement({id = "UseQ", name = "Auto[Q]Immobile Target", value = true})
	
	self.Menu:MenuElement({type = MENU, id = "AutoQ2", leftIcon = Icons["QSet"]})
	self.Menu.AutoQ2:MenuElement({id = "UseQ", name = "[Q]Transferring Stacks Minion to Enemy", value = true})	

	--AutoR 
	self.Menu:MenuElement({type = MENU, id = "AutoR", leftIcon = Icons["AutoR"]})
	self.Menu.AutoR:MenuElement({id = "UseR", name = "Auto[R]Safe Ally", value = true})
	self.Menu.AutoR:MenuElement({id = "Heal", name = "min Hp Ally or Self", value = 20, min = 0, max = 100, identifier = "%"})	

	--AutoE
	self.Menu:MenuElement({type = MENU, id = "AutoE", leftIcon = Icons["AutoE"]})
	self.Menu.AutoE:MenuElement({id = "E", name = "AutoE ToggleKey[AutoE Minions always]", key = 84, toggle = true})	
	self.Menu.AutoE:MenuElement({id = "UseE", name = "Auto[E]if Enemy leave Range", value = true})
	self.Menu.AutoE:MenuElement({id = "UseEM", name = "min[E]Stacks leaved Enemy", value = 7, min = 1, max = 20, step = 1})	
		
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Combo:MenuElement({id = "UseEM", name = "min[E]Stacks", value = 10, min = 1, max = 20, step = 1})	
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Harass:MenuElement({id = "UseEM", name = "min[E]Stacks", value = 10, min = 1, max = 20, step = 1})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})			
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E]LastHit", value = true}) 		
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E]LastHit", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})				

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})


	self.Menu:MenuElement({type = MENU, id = "ally", name = "WomboCombo"})
	self.Menu.ally:MenuElement({type = SPACE, id = "Tip", name = "Champs[Blitzcrank, Skarner, TahmKench, Sion]"})
	DelayAction(function()
	for i, Hero in pairs(GetAllyHeroes()) do
	
		if ChampTable[Hero.charName] then			
			self.Menu.ally:MenuElement({id = "Champ", name = Hero.charName, value = true})
			self.Menu.ally:MenuElement({id = "MyHP", name = "Kalista min.Hp to UseR",  value = 40, min = 0, max = 100, step = 1})			
		
		end
	end 
	end, 0.3)	

	

	
	
end	

function Kalista:Tick()
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
	self:KillSteal()
	self:AutoQ()
	self:AutoQ2()
	self:AutoE()
	self:AutoR()
	self:BoundHero()
	self:KillMinion()
	self:WomboCombo()
	end
 
			

				
end

function Kalista:BoundHero()
	if BoundAlly then return end
	
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if not hero.isMe and hero.isAlly and HasBuff(hero,"kalistacoopstrikeally")  then
			--print("Found")
			BoundAlly = hero
		end
	end	
end



function Kalista:WomboCombo()
local target = GetTarget(1500)     	
if target == nil then return end

	
	
	if self.Menu.ally.Champ ~= nil and BoundAlly and IsValid(BoundAlly,1300) and myHero.pos:DistanceTo(BoundAlly.pos) <= 1200 then
		if Ready(_R) and self.Menu.ally.Champ:Value() and myHero.health/myHero.maxHealth >= self.Menu.ally.MyHP:Value()/100 then
			
			if BoundAlly.charName == "Blitzcrank" and GotBuff(target, "rocketgrab2") > 0 then
				Control.CastSpell(HK_R)
			
			elseif BoundAlly.charName == "Skarner" and GotBuff(target, "SkarnerImpale") > 0 then
				Control.CastSpell(HK_R)
			
			elseif BoundAlly.charName == "TahmKench" and GotBuff(target, "tahmkenchwdevoured") > 0 then
				Control.CastSpell(HK_R)
			
			elseif BoundAlly.charName == "Sion" and (BoundAlly.activeSpell and BoundAlly.activeSpell.valid and BoundAlly.activeSpell.name == "SionR") then
				DelayAction(function()
				Control.CastSpell(HK_R) 
				end, 0.3)
			end
		end
	end
end




function Kalista:GetEstacks(unit)

	local stacks = 0
	if HasBuff(unit, "kalistaexpungemarker") then
		for i = 1, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and buff.count > 0 and buff.name:lower() == "kalistaexpungemarker" then
				stacks = buff.count
			end
		end
	end
	return stacks
end

function Kalista:GetEDamage(unit,stacks)
	local level = myHero:GetSpellData(_E).level
	local basedmg = ({20, 30, 40, 50, 60})[level] + 0.6* (myHero.totalDamage)
	local stacksdmg = (stacks )*(({10, 14, 19, 25, 32})[level]+({0.198, 0.237, 0.274, 0.312, 0.349})[level] * myHero.totalDamage)
	return CalcPhysicalDamage(myHero, (basedmg + stacksdmg))
end

function Kalista:GetEDamageChamp(unit,stacks)
	local level = myHero:GetSpellData(_E).level
	local basedmg = ({20, 30, 40, 50, 60})[level] + 0.6* (myHero.totalDamage)
	local stacksdmg = (stacks+1)*(({10, 14, 19, 25, 32})[level]+({0.198, 0.237, 0.274, 0.312, 0.349})[level] * myHero.totalDamage)
	return CalcPhysicalDamage(myHero, (basedmg + stacksdmg))
end

function Kalista:GetQDamage(unit)
	local basedmg = ({20, 85, 150, 215, 280})[myHero:GetSpellData(_Q).level] + myHero.totalDamage
	return CalcPhysicalDamage(myHero,basedmg)
end

function Kalista:Draw()
  if myHero.dead then return end
	
	if self.Menu.Drawing.DrawR:Value() and Ready(_R) then
    Draw.Circle(myHero, 1100, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.Drawing.DrawQ:Value() and Ready(_Q) then
    Draw.Circle(myHero, 1150, 1, Draw.Color(225, 225, 0, 10))
	end
	
	local textPos = myHero.pos:To2D()
	if self.Menu.AutoE.E:Value() then 
		Draw.Text("AutoE ON", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000))
	else
		Draw.Text("AutoE OFF", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 220, 050, 000)) 
	end

		
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		Draw.Text("GsoPred. installed Press 2x F6", 50, textPos.x + 100, textPos.y - 250, Draw.Color(255, 255, 0, 0))
	end	
	for i, Hero in pairs(GetAllyHeroes()) do
		if ChampTable[Hero.charName] then
			Draw.Text("WomboCombo possible", 20, textPos.x + 1, textPos.y - 400, Draw.Color(255, 255, 0, 0))
		end
	end
end

function Kalista:AutoQ()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	if IsValid(target,1300) and myHero.pos:DistanceTo(target.pos) <= 1150 and IsImmobileTarget(target) and self.Menu.AutoQ.UseQ:Value() and Ready(_Q) then
		local pred = GetGamsteronPrediction(target, QData, myHero)
		if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
			Control.CastSpell(HK_Q, pred.CastPosition)
		end	
	end
end

function Kalista:AutoQ2()
local target = GetTarget(1300)     	
if target == nil then return end	
	
	if IsValid(target,1300) and myHero.pos:DistanceTo(target.pos) <= 1150 and self.Menu.AutoQ2.UseQ:Value() and Ready(_Q) then
        for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
			if minion.team == TEAM_ENEMY and IsValid(minion,1500) then
			local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 1150, 0.25, 2100, 40, false)	
			local QDmg = self:GetQDamage(minion)
			local pointSegment, pointLine, isOnSegment = HPred:VectorPointProjectionOnLineSegment(myHero.pos, aimPosition, minion.pos)
				if isOnSegment and (minion.pos.x - pointSegment.x)^2 + (minion.pos.z - pointSegment.y)^2 < (40 + minion.boundingRadius + 15) * (40 + minion.boundingRadius + 15) and self:GetEstacks(minion) >= 1 and QDmg >= minion.health and hitRate and hitRate >= 1 then 
					Control.CastSpell(HK_Q, aimPosition)
				end
			end	
        end
	end
end

function Kalista:AutoE()
local target = GetTarget(1000)     	
if target == nil then return end
	if IsValid(target,1000) and myHero.pos:DistanceTo(target.pos) > 800 and Ready(_E) then
		if self.Menu.AutoE.UseE:Value() and self:GetEstacks(target) >= self.Menu.AutoE.UseEM:Value() then
			Control.CastSpell(HK_E)
				
		end
	end	
end

function Kalista:AutoR()
	if BoundAlly then
		if IsValid(BoundAlly,1300) and myHero.pos:DistanceTo(BoundAlly.pos) <= 1200 and self.Menu.AutoR.UseR:Value() and Ready(_R) then

			if BoundAlly.health/BoundAlly.maxHealth <= self.Menu.AutoR.Heal:Value()/100 and BaseCheck(myHero) == false then
				Control.CastSpell(HK_R)
			end
		end
	end
end


function Kalista:Combo()
local target = GetTarget(1500)     	
if target == nil then return end
	if IsValid(target,1500) then
				
		if myHero.pos:DistanceTo(target.pos) <= 1150 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		if myHero.pos:DistanceTo(target.pos) <= 1500 and self.Menu.Combo.UseE:Value() and Ready(_E) then
			if self:GetEstacks(target) >= self.Menu.Combo.UseEM:Value() then	
				Control.CastSpell(HK_E)
			end
		end		
	end	
end	

function Kalista:Harass()
local target = GetTarget(1500)
if target == nil then return end
	if IsValid(target,1500) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 1500 and self.Menu.Harass.UseE:Value() and Ready(_E) then
			if self:GetEstacks(target) >= self.Menu.Harass.UseEM:Value() then	
				Control.CastSpell(HK_E)
			end
		end
	end
end

function Kalista:Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,1000) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))

            if myHero.pos:DistanceTo(minion.pos) <= 1000 and self.Menu.Clear.UseE:Value() then
				if mana_ok and Ready(_E) then
					if (minion.charName == "Siege" or minion.charName == "super") and self:GetEDamage(minion,stacks) >= minion.health then
						Control.CastSpell(HK_E)
					                    
                    elseif self:GetEDamage(minion,stacks) >= minion.health then
                        Control.CastSpell(HK_E)
                    end
				end
            end
        end
    end
end



local JungleTable = {
	"SRU_Baron",
	"SRU_RiftHerald",
	"SRU_Dragon_Water",
	"SRU_Dragon_Fire",
	"SRU_Dragon_Earth",
	"SRU_Dragon_Air",
	"SRU_Dragon_Elder",
	"SRU_Blue",
	"SRU_Red",
}


function Kalista:JungleClear()
	
	
	for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_JUNGLE and IsValid(minion,1000) then
            local mana_ok = myHero.mana/myHero.maxMana >= self.Menu.JClear.Mana:Value() / 100

            if myHero.pos:DistanceTo(minion.pos) <= 1000 and self.Menu.JClear.UseE:Value() then
				if mana_ok and Ready(_E) then  
                    if JungleTable[minion.charName] and self:GetEDamageChamp(minion,stacks) >= minion.health then
						 Control.CastSpell(HK_E)
					elseif self:GetEDamageChamp(minion,stacks) >= minion.health then
                        Control.CastSpell(HK_E)
					end	
                end
            end
        end
    end
end

function Kalista:KillMinion()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,1000) then
            if myHero.pos:DistanceTo(minion.pos) <= 1000 then
				if self.Menu.AutoE.E:Value() and Ready(_E) then
					if (minion.charName == "Siege" or minion.charName == "super") and self:GetEDamage(minion,stacks) >= minion.health then
						Control.CastSpell(HK_E)
					                    
                    elseif self:GetEDamage(minion,stacks) >= minion.health then
                        Control.CastSpell(HK_E)
                    end
                end
            end
        end
    end
end


function Kalista:KillSteal()
	local target = GetTarget(1500)     	
	if target == nil then return end
	
	
	if IsValid(target,1500) then	

		if myHero.pos:DistanceTo(target.pos) <= 1150 and Ready(_Q) then
			local QDmg = self:GetQDamage(target)
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if QDmg >= target.health and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 1500 and Ready(_E) then
			local EDmg = self:GetEDamageChamp(target,stacks)
			if EDmg >= target.health then
				Control.CastSpell(HK_E)
			end
		end
	end
end	



-------------------------------------------------------------------------------------------------------------------------------------------------------------



class "Tristana"




function Tristana:CheckSpell(range)
    local target
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
        if hero.team ~= myHero.team then
			if hero.activeSpell.name == "RocketGrab" then 
				casterPos = hero.pos
				grabTime = hero.activeSpell.startTime * 100
				return true
			end
        end
    end
    return false
end

function Tristana:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

function Tristana:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Tristana:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Tristana:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Tristana:__init()
	
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



function Tristana:LoadSpells()

	W = {Range = 900, Width = 250, Delay = 0.25, Speed = 1100, Collision = false, aoe = true, Type = "circle"}
	E = {Range = 517 + (8 * myHero.levelData.lvl), Width = 75, Delay = 0.25, Speed = 2400, Collision = false, aoe = false, Type = "line"}
	R = {Range = 517 + (8 * myHero.levelData.lvl), Width = 0, Delay = 0.25, Speed = 1000, Collision = false, aoe = false, Type = "line"}

end



function Tristana:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Tristana", name = "PussyTristana"})
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "AutoQ when Explosive Charge", value = true})
	self.Menu.Combo:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Combo:MenuElement({id = "UseR", name = "(R)Finisher", tooltip = "is(R)Dmg+(E)Dmg+(E)StackDmg > TargetHP than Ult", value = true})
	self.Menu.Combo:MenuElement({type = MENU, id = "R", name = "R"})
	for i, hero in pairs(GetEnemyHeroes()) do
	self.Menu.Combo.R:MenuElement({id = "RR"..hero.charName, name = "KS R on: "..hero.charName, value = true})
	end	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	self.Menu:MenuElement({type = MENU, id = "gap", leftIcon = Icons["Gapclose"]})
	self.Menu.gap:MenuElement({id = "UseR", name = "Ultimate Gapclose", value = true})
	self.Menu.gap:MenuElement({id = "gapkey", name = "Gapclose key", key = string.byte("T")})
	

	
	self.Menu:MenuElement({type = MENU, id = "Blitz", leftIcon = Icons["Escape"]})
	self.Menu.Blitz:MenuElement({id = "UseW", name = "AutoW", value = true})
	
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "AutoQ when Explosive Charge", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "E", value = true})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})

	
	
	self.Menu:MenuElement({type = MENU, id = "Drawings", leftIcon = Icons["Drawings"]})
	
	--W
	self.Menu.Drawings:MenuElement({type = MENU, id = "W", name = "Draw W range"})
    self.Menu.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--E
	self.Menu.Drawings:MenuElement({type = MENU, id = "E", name = "Draw E range"})
    self.Menu.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    self.Menu.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--R
	self.Menu.Drawings:MenuElement({type = MENU, id = "R", name = "Draw R range"})
    self.Menu.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = true})
    self.Menu.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	

	self.Menu.Drawings:MenuElement({id = "DrawR", name = "Draw Kill Ulti Gapclose ", value = true})


	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5,tooltip = "", identifier = ""})
	

end

function Tristana:Tick()
if MyHeroReady() then
local Mode = GetMode()
	if Mode == "Combo" then
		if self.Menu.Combo.comboActive:Value() then
			self:Combo()
			self:ComboE()
			self:ComboRKS()
			self:Finisher()
		end	
		if self.Menu.gap.gapkey:Value() then
			self:GapcloseR()
			self:AutoR()

		end
	elseif Mode == "Harass" then
		if self.Menu.Harass.harassActive:Value() then
			self:HarassQ()
			self:HarassE()
		end
	elseif Mode == "Clear" then
	
	elseif Mode == "Flee" then
		
	end

	if self.Menu.Blitz.UseW:Value() then
		self:AntiBlitz()
	end

end
end

function Tristana:Draw()
	if self:CanCast(_W) and self.Menu.Drawings.W.Enabled:Value() then Draw.Circle(myHero, 900, self.Menu.Drawings.W.Width:Value(), self.Menu.Drawings.W.Color:Value()) end
	if self:CanCast(_E) and self.Menu.Drawings.E.Enabled:Value() then Draw.Circle(myHero, GetERange(), self.Menu.Drawings.E.Width:Value(), self.Menu.Drawings.E.Color:Value()) end
	if self:CanCast(_R) and self.Menu.Drawings.R.Enabled:Value() then Draw.Circle(myHero, GetRRange(), self.Menu.Drawings.R.Width:Value(), self.Menu.Drawings.R.Color:Value()) end
	local target = GetTarget(GetRWRange())
	if target == nil then return end
	local textPos = myHero.pos:To2D()	
	if self.Menu.Drawings.DrawR:Value() and IsValid(target, 1500) then 
		if myHero.pos:DistanceTo(target.pos) > R.Range and EnemyInRange(GetRWRange()) then
		local Rdamage = self:RDMG(target)		
		local totalDMG = CalcMagicalDamage(target, Rdamage)
			if totalDMG > self:HpPred(target,1) + target.hpRegen * 1 and not target.dead and self:IsReady(_R) and self:IsReady(_W) then
			Draw.Text("GapcloseKill PressKey", 25, textPos.x - 33, textPos.y + 60, Draw.Color(255, 255, 0, 0))
			end
		end
	end
end	
local timer = {state = false, tick = GetTickCount(), mouse = mousePos, done = false, delayer = GetTickCount()}
function Tristana:AntiBlitz()	
	if GetTickCount() - timer.tick > 300 and GetTickCount() - timer.tick < 700 then 
		timer.state = false
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end

	local ctc = Game.Timer() * 100
	
	local target = GetTarget(900)
	if self.Menu.Blitz.UseW:Value() and self:CheckSpell(900) and grabTime ~= nil and self:CanCast(_W) then 
		if myHero.pos:DistanceTo(target.pos) > 350 then
			if ctc - grabTime >= 28 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		else
			if ctc - grabTime >= 12 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		end
	end
end	


function Tristana:Combo()
		local target = GetTarget(GetAARange())
		if target == nil then return end
		for i = 1, target.buffCount do
		local buff = target:GetBuff(i)
			if buff and buff.name == "tristanaechargesound" then
				if IsValid(target,GetAARange()) and EnemyInRange(GetAARange()) and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
					Control.CastSpell(HK_Q)
				end
			end
		end	
	end
	
		


function Tristana:ComboE()
    local target = GetTarget(GetERange())
    if target == nil then return end
	if IsValid(target,GetERange()) and EnemyInRange(GetERange()) then	
		if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
			Control.CastSpell(HK_E, target)
		end
	end
end
		
function Tristana:ComboRKS()
	local hero = GetTarget(GetRRange())
    if hero == nil then return end
 	if IsValid(hero,GetRRange()) and EnemyInRange(GetRRange()) then
		if self.Menu.Combo.R["RR"..hero.charName]:Value() and self:CanCast(_R) then
		local Rdamage = self:RDMG(hero)   
		local totalDMG = CalcMagicalDamage(hero, Rdamage)
			if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1 then
				Control.CastSpell(HK_R, hero)
			end
        end
    end
end

function Tristana:Finisher()
	local hero = GetTarget(GetRRange())
    if hero == nil then return end
	if IsValid(hero,GetRRange()) and EnemyInRange(GetRRange()) then	
		if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
			Edmg = self:EDMG(hero)
			Rdmg = self:RDMG(hero)	
			calcEdmg = CalcPhysicalDamage(hero, Edmg)
			calcRdmg = CalcMagicalDamage(hero, Rdmg)
			totalDMG = calcEdmg + calcRdmg
			if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1 then
			Control.CastSpell(HK_R, hero)
			end
		end
	end
end	

function Tristana:GapcloseR()
	local hero = GetTarget(GetRWRange())
    if hero == nil then return end
		
	if IsValid(hero,GetRWRange()) and EnemyInRange(GetRWRange()) and self.Menu.gap.UseR:Value() and self:CanCast(_R) and self:CanCast(_W) then
		if myHero.pos:DistanceTo(hero.pos) > R.Range then
			local Rdamage = self:RDMG(hero)		
			local totalDMG = CalcMagicalDamage(hero, Rdamage)
			if totalDMG >= self:HpPred(hero,1) + hero.hpRegen * 1 then
				Control.CastSpell(HK_W, hero.pos) 
				self:AutoR()
			end
		end
	end
end	
		
function Tristana:AutoR()
	local hero = GetTarget(GetRRange())
    if hero == nil then return end
	if IsValid(hero,GetRRange()) and EnemyInRange(GetRRange()) and self:CanCast(_R) then
		local Rdamage = self:RDMG(hero)
		local totalDMG = CalcMagicalDamage(hero, Rdamage)
		if  totalDMG > self:HpPred(hero,1) + hero.hpRegen * 1 then
			Control.CastSpell(HK_R, hero)
		
		end
	end
end

function Tristana:HarassQ()
		local target = GetTarget(GetAARange())
		if target == nil then return end
		for i = 1, target.buffCount do
		local buff = target:GetBuff(i)	
			if buff and buff.name == "tristanaechargesound" then
				if IsValid(target,GetAARange()) and EnemyInRange(GetAARange()) and self.Menu.Harass.UseQ:Value() and self:CanCast(_Q) then
					Control.CastSpell(HK_Q)
				end
			end
		end	
	end

function Tristana:HarassE()
    local target = GetTarget(GetERange())
    if target == nil then return end
    if IsValid(target,GetERange()) and EnemyInRange(GetERange()) and self.Menu.Harass.UseE:Value() and self:CanCast(_E) then
		Control.CastSpell(HK_E, target)
		   
	    end
	end
 

-------------------------
-- DMG
---------------------
function Tristana:HasEbuff(unit)
	for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)
	for i = 1, hero.buffCount do
		local buff = hero:GetBuff(i)
		if HasBuff(hero, "tristanaechargesound") then
		if buff then
			return true
		end
	end
	return false
end
end
end

function Tristana:GetEstacks(unit)

	local stacks = 0
	if self:HasEbuff(unit) then
		for i = 1, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and buff.count > 0 and buff.name:lower() == "tristanaecharge" then
				stacks = buff.count
			end
		end
	end
	return stacks
end



function Tristana:RDMG(unit)
    total = 0
	local rLvl = myHero:GetSpellData(_R).level
    if rLvl > 0 then
	local rdamage = (({300,400,500})[rLvl] + myHero.ap) 
	total = rdamage 
	end
	return total
end

function Tristana:AADMG(unit)
    total = 0
	local AALvl = myHero.levelData.lvl

	local AAdamage = 58 + ( 2 * AALvl)
	total = AAdamage 
	return total
end

function Tristana:GetStackDmg(unit)

	local total = 0
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 21, 24, 27, 30, 33 })[eLvl]
		local m = ({ 0.15, 0.21, 0.27, 0.33, 0.39 })[eLvl]
		local bonusDmg = (m * myHero.bonusDamage) + (0.15 * myHero.ap)
		total = (raw + bonusDmg) * self:GetEstacks(unit)
	end
	return total
end

function Tristana:EDMG(unit)
	local total = 0
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 70, 80, 90, 100, 110 })[eLvl]
		local m = ({ 0.5, 0.7, 0.9, 1.1, 1.3 })[eLvl]
		local bonusDmg = (m * myHero.bonusDamage) + (0.5 * myHero.ap)
		total = raw + bonusDmg
		total = total + self:GetStackDmg(unit)  
	end
	return total
end	

function GetRRange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end

function GetRWRange()
	local rrange = GetRRange()
	local wrange = W.Range
	local range = rrange + wrange
	return range
end

function GetERange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end

function GetAARange()
	local level = myHero.levelData.lvl
	local range = 517 + ( 8 * level)
	return range
end
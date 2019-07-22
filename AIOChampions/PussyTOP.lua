local Top = {"Mordekaiser","Kayle"}
if table.contains(Top, myHero.charName) then
	_G[myHero.charName]()
end	

function OnLoad()
	AutoUpdate()

end

    local Version = 0.1
    
    local Files = {
        Lua = {
            Path = COMMON_PATH,
            Name = "PussyTOP.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyTOP.lua"
        },
        Version = {
            Path = COMMON_PATH,
            Name = "PussyTOP.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/AIOChampions/PussyTOP.version"
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
            print("New PussyTOP Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
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
	elseif _G.gsoSDK then
		Orb = 4			
	end
end

function Kayle:LoadMenu()                     
	--MainMenu
	self.Menu = MenuElement({type = MENU, id = "Kayle", name = "PussyKayle"})

	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", leftIcon = Icons["AutoW"]})
	self.Menu.AutoW:MenuElement({id = "self", name = "Heal self", value = true})
	self.Menu.AutoW:MenuElement({id = "ally", name = "Heal Ally", value = true})
	self.Menu.AutoW:MenuElement({id = "HP", name = "HP Self/Ally", value = 50, min = 0, max = 100, step = 1, identifier = "%"})
	self.Menu.AutoW:MenuElement({id = "Mana", name = "min. Mana", value = 50, min = 0, max = 100, step = 1, identifier = "%"})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})			
	self.Menu.Combo:MenuElement({type = MENU, id = "UseR", name = "Ult Settings"})
	self.Menu.Combo.UseR:MenuElement({id = "self", name = "Ult self", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "ally", name = "Ult Ally", value = true})
	self.Menu.Combo.UseR:MenuElement({id = "HP", name = "HP Self/Ally", value = 40, min = 0, max = 100, step = 1, identifier = "%"})	
	

	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})
	self.Menu.Harass:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass", value = 40, min = 0, max = 100, identifier = "%"})
  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "Lasthit[Q] Radiant Blast", value = true})		
	self.Menu.Clear:MenuElement({id = "UseE", name = "Lasthit[E] Starfire Spellblade", value = true})	
	self.Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear", value = 40, min = 0, max = 100, identifier = "%"})
  
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})         	
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.JClear:MenuElement({id = "Mana", name = "Min Mana to JungleClear", value = 40, min = 0, max = 100, identifier = "%"})  
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q] Radiant Blast", value = true})		
	self.Menu.ks:MenuElement({id = "UseE", name = "[E] Starfire Spellblade", value = true})	
	self.Menu.ks:MenuElement({id = "gun", name = "Hextech Gunblade + [Q]", value = true})	

	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 2, drop = {"Normal", "High", "Immobile"}})

	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true})

	
	
end

function Kayle:Tick()
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
		self:KillStealE()
		self:AutoW()
	end
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
	if IsValid(target, 1200) and myHero.health/myHero.maxHealth <= self.Menu.AutoW.HP:Value()/100 and myHero.mana/myHero.maxMana >= self.Menu.AutoW.Mana:Value() / 100 then
		if self.Menu.AutoW.self:Value() and Ready(_W) then
			Control.CastSpell(HK_W, myHero)
			
		end
		if self.Menu.AutoW.ally:Value() and Ready(_W) then		
			for i = 1, Game.HeroCount() do
			local unit = Game.Hero(i)
				if unit.isAlly and IsValid(unit, 1000) then
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

	if IsValid(target, 600) and myHero.pos:DistanceTo(target.pos) <= 550 then
		local level = myHero.levelData.lvl
		local hp = target.health
		local EDmg = getdmg("E", target, myHero, 1)
		local E2Dmg = getdmg("E", target, myHero, 2)
		local E3Dmg = getdmg("E", target, myHero, 2) + getdmg("E", target, myHero, 3)
		
		if self.Menu.ks.UseE:Value() and Ready(_E) then
			if level >= 1 and level < 6 and EDmg >= hp then
				Control.CastSpell(HK_E)
		
			
			elseif level >= 6 and level < 16 and E2Dmg >= hp then
				Control.CastSpell(HK_E)
				
			elseif level >= 16 and E3Dmg >= hp then
				Control.CastSpell(HK_E)				
			end			
		end	
	end
end	
       
function Kayle:KillSteal()	
	local target = GetTarget(1000)     	
	if target == nil then return end
	
	if IsValid(target, 1000) and myHero.pos:DistanceTo(target.pos) <= 900 then	
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
	if IsValid(target, 1200) then
			
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and self.Menu.Combo.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end	
		end
		
		if myHero.pos:DistanceTo(target.pos) <= 550 and self.Menu.Combo.UseE:Value() and Ready(_E) then					
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
				if unit.isAlly and IsValid(unit, 1000) then
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
	if IsValid(target, 1000) and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
		
		if myHero.pos:DistanceTo(target.pos) <= 850 and self.Menu.Harass.UseQ:Value() and Ready(_Q) then
			local pred = GetGamsteronPrediction(target, QData, myHero)
			if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
				Control.CastSpell(HK_Q, pred.CastPosition)
			end
		end
		if myHero.pos:DistanceTo(target.pos) <= 550 and self.Menu.Harass.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E)
	
			
		end
	end
end	

function Kayle:Clear()
    local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if minion.team == TEAM_ENEMY and IsValid(minion,max_range) then
            local mana_ok = (self.Menu.Clear.Mana == nil or (self.Menu.Clear.Mana ~= nil and myHero.mana/myHero.maxMana >= self.Menu.Clear.Mana:Value() / 100))
            if self.Menu.Clear.UseQ ~= nil and self.Menu.Clear.UseQ:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
				local pred = GetGamsteronPrediction(minion, QData, myHero)	
				local QDmg = getdmg("Q", minion, myHero)	
				if QDmg > minion.health and pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then
					Control.CastSpell(HK_Q, pred.CastPosition)
				end	
            end
            if self.Menu.Clear.UseW ~= nil and self.Menu.Clear.UseW:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
                Control.CastSpell(HK_W, minion.pos)
            end
            if self.Menu.Clear.UseE ~= nil and self.Menu.Clear.UseE:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
                local EDmg = getdmg("E", minion, myHero, 1)
				local E2Dmg = getdmg("E", minion, myHero, 2)
				local E3Dmg = getdmg("E", minion, myHero, 2) + getdmg("E", minion, myHero, 3)
				local level = myHero.levelData.lvl
				if level >= 1 and level < 6 and EDmg > minion.health then
					Control.CastSpell(HK_E)
				
				elseif level >= 6 and level < 16 and E2Dmg > minion.health then
					Control.CastSpell(HK_E)
					
				elseif level >= 16 and E3Dmg > minion.health then
					Control.CastSpell(HK_E)	
				end
            end
            if self.Menu.Clear.UseR ~= nil and self.Menu.Clear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end

function Kayle:JungleClear()
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
                Control.CastSpell(HK_E)
            end
            if self.Menu.JClear.UseR ~= nil and self.Menu.JClear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
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
	self.Menu:MenuElement({type = MENU, id = "AutoE", leftIcon = Icons["AutoE"]})
	self.Menu.AutoE:MenuElement({id = "UseE", name = "Pull Enemys under Tower",value = true})

	--AutoW
	self.Menu:MenuElement({type = MENU, id = "AutoW", leftIcon = Icons["AutoW"]})
	self.Menu.AutoW:MenuElement({id = "UseW", name = "AutoW", value = true})
	self.Menu.AutoW:MenuElement({id = "UseWE", name = "Minimum Health", value = 50, min = 0, max = 100, identifier = "%"})	
	
	--ComboMenu  
	self.Menu:MenuElement({type = MENU, id = "Combo", leftIcon = Icons["Combo"]})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	self.Menu.Combo:MenuElement({id = "UseE", name = "[E]", value = true})
	self.Menu.Combo:MenuElement({id = "count", name = "[E]Minimum Targets", value = 2, min = 1, max = 5})	
	
	
	--HarassMenu
	self.Menu:MenuElement({type = MENU, id = "Harass", leftIcon = Icons["Harass"]})	
	self.Menu.Harass:MenuElement({id = "UseQ", name = "[Q]", value = true})

  
	--LaneClear Menu
	self.Menu:MenuElement({type = MENU, id = "Clear", leftIcon = Icons["Clear"]})	
	self.Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})
	self.Menu.Clear:MenuElement({id = "UseE", name = "[E]", value = true})	

	
	--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JClear", leftIcon = Icons["JClear"]})
	self.Menu.JClear:MenuElement({id = "UseQ", name = "[Q]", value = true}) 
	self.Menu.JClear:MenuElement({id = "UseE", name = "[E]", value = true})	
 	
    
 
	--KillSteal
	self.Menu:MenuElement({type = MENU, id = "ks", leftIcon = Icons["ks"]})
	self.Menu.ks:MenuElement({id = "UseQ", name = "[Q]", value = true})	
	self.Menu.ks:MenuElement({id = "UseE", name = "[E]", value = true})			
	self.Menu.ks:MenuElement({id = "Targets", name = "Ult Settings", type = MENU})	
	self.Menu.ks.Targets:MenuElement({id = "UseR", name = "[R] FullDmg", value = true})
	for i, Hero in pairs(GetEnemyHeroes()) do
		self.Menu.ks.Targets:MenuElement({id = Hero.charName, name = Hero.charName, value = true})		
	end		
	
	
	--Prediction
	self.Menu:MenuElement({type = MENU, id = "Pred", leftIcon = Icons["Pred"]})	
	self.Menu.Pred:MenuElement({id = "PredQ", name = "Hitchance[Q]", value = 1, drop = {"Normal", "High", "Immobile"}})	

 
	--Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", leftIcon = Icons["Drawings"]})
	self.Menu.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q]Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawR", name = "Draw [R]Range", value = true})
	self.Menu.Drawing:MenuElement({id = "DrawE", name = "Draw [E]Range", value = true})


end

function Mordekaiser:Tick()
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
	self:AutoW()

	
	end
end 

function Mordekaiser:Draw()
  if myHero.dead then return end
	if(self.Menu.Drawing.DrawR:Value()) and Ready(_R) then
    Draw.Circle(myHero, 650, 1, Draw.Color(255, 225, 255, 10)) 
	end                                                 
	if(self.Menu.Drawing.DrawQ:Value()) and Ready(_Q) then
    Draw.Circle(myHero, 675, 1, Draw.Color(225, 225, 0, 10))
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
	local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
	local target = GetTarget(max_range)
	if target == nil then return end
	if IsValid(target,max_range) then
		
        if self.Menu.AutoE.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_E).range and IsUnderAllyTurret(myHero) and Ready(_E) then
			Control.CastSpell(HK_E, target.pos)
        end		
	end
end

function Mordekaiser:KillSteal()	
	local max_range = math.max(myHero.range + myHero.boundingRadius, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range, myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range)
    if max_range > 1500 then
        max_range = 1500
    end
	local target = GetTarget(max_range)
	if target == nil then return end
	if IsValid(target,max_range) then
        
		if self.Menu.ks.UseQ ~= nil and self.Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_Q).range and Ready(_Q) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg >= target.health then
				local pred = GetGamsteronPrediction(target, QData, myHero)
				if pred.Hitchance >= self.Menu.Pred.PredQ:Value() + 1 then	
					Control.CastSpell(HK_Q, pred.CastPosition)
				end
			end	
        end
        if self.Menu.ks.UseW ~= nil and self.Menu.ks.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
            Control.CastSpell(HK_W, target.pos)
        end
        if self.Menu.ks.UseE ~= nil and self.Menu.ks.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
            local EDmg = getdmg("E", target, myHero)
			if EDmg >= target.health then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
			end	
        end
        if self.Menu.ks.Targets.UseR:Value() and self.Menu.ks.Targets[target.charName] and self.Menu.ks.Targets[target.charName]:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
			if (getdmg("Q", target, myHero)+getdmg("E", target, myHero))*2 >= target.health then
				Control.CastSpell(HK_R, target.pos)
			end	
		end
	end	
end	

function Mordekaiser:Combo()
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
        if self.Menu.Combo.UseW ~= nil and self.Menu.Combo.UseW:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
            Control.CastSpell(HK_W, target.pos)
        end
        if self.Menu.Combo.UseE ~= nil and self.Menu.Combo.UseE:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
            local count = GetEnemyCount(200, target)
			if count >= self.Menu.Combo.count:Value() then
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, target, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
			end	
        end
        if self.Menu.Combo.UseR ~= nil and self.Menu.Combo.UseR:Value() and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
            Control.CastSpell(HK_R, target.pos)
		end
	end
end


function Mordekaiser:Harass()
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
        if self.Menu.Harass.UseW ~= nil and self.Menu.Harass.UseW:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_W).range and Ready(_W) then
            Control.CastSpell(HK_W, target.pos)
        end
        if self.Menu.Harass.UseE ~= nil and self.Menu.Harass.UseE:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_E).range and Ready(_E) then
            Control.CastSpell(HK_E, target.pos)
        end
        if self.Menu.Harass.UseR ~= nil and self.Menu.Harass.UseR:Value() and mana_ok and myHero.pos:DistanceTo(target.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
            Control.CastSpell(HK_R, target.pos)
        end		
	end
end	


function Mordekaiser:Clear()
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
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
            end
            if self.Menu.Clear.UseR ~= nil and self.Menu.Clear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end

function Mordekaiser:JClear()
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
				local hitRate, aimPosition = HPred:GetHitchance(myHero.pos, minion, 700, 0.5, 500, 180, false)
				if hitRate and hitRate >= 1 then	
					Control.CastSpell(HK_E, aimPosition)	
				end	
            end
            if self.Menu.JClear.UseR ~= nil and self.Menu.JClear.UseR:Value() and mana_ok and myHero.pos:DistanceTo(minion.pos) <= myHero:GetSpellData(_R).range and Ready(_R) then
                Control.CastSpell(HK_R, minion.pos)
            end
        end
    end
end

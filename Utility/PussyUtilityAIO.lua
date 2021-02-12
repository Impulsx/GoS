do
    
    local Version = 0.01
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyUtilityAIO.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyUtilityAIO.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyUtilityAIO.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyUtilityAIO.version"
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
            print("New PussyUtility Version Press 2x F6")
        else
            print("PussyUtility loaded")
        end
    
    end
    
    AutoUpdate()

end

local lpairs = pairs
local mfloor = math.floor 
local TableInsert = table.insert
local TableRemove = table.remove
local mathmin = math.min
local mathceil = math.ceil
local res = Game.Resolution()
local width = res.x
local GameWardCount = Game.WardCount
local GameWard = Game.Ward
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameObjectCount = Game.ObjectCount
local GameObject = Game.Object
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local DrawRect = Draw.Rect
local DrawLine = Draw.Line

local function IntegerToMinSec(i)
	local m, s = mfloor(i/60), (i%60)
	return (m < 10 and 0 or "")..m..":"..(s < 10 and 0 or "")..s
end

class "WardTrapTracker"

function WardTrapTracker:__init()
	self.enemies = {}
	self.wards = {}
	self.SearchChamp = true
	self.TeemoTraps = {}
	self.NidaTraps = {}
	self.JhinTraps = {}
	self.ShacoTraps = {}
	self.MaoTraps = {}	
	self.FoundTeemo = false
	self.FoundNida = false
	self.FoundJhin = false
	self.FoundShaco = false	
	self.FoundMao = false
	self.FoundTrapChamp = false
	self.LastWardScan = Game.Timer()
	self:Tables()
	self:WLoadHeros()
	self:LoadMenu()	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:OnDrawTracker() end)	
end

function WardTrapTracker:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "PUtility", name = "Trap/Ward Tracker"})
	
	-- Ward Tracker --
	self.Menu:MenuElement({id = "Warding", name = "Enemy Ward Tracker", type = MENU })
		self.Menu.Warding:MenuElement({id = "Enabled", name = "Enabled", value = true})
		self.Menu.Warding:MenuElement({id = "EnabledScan", name = "Scan For Wards", value = true})
		self.Menu.Warding:MenuElement({type = MENU, id = "VisionWard", name = "Control Ward"})
			self.Menu.Warding.VisionWard:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})
		self.Menu.Warding:MenuElement({type = MENU, id = "Trinket", name = "Warding Totem"})
			self.Menu.Warding.Trinket:MenuElement({id = "TimerDisplay", name = "Show Ward Timer", value = true})
			self.Menu.Warding.Trinket:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})
		self.Menu.Warding:MenuElement({type = MENU, id = "Farsight", name = "Farsight Alteration"})
			self.Menu.Warding.Farsight:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})

	self.Menu:MenuElement({id = "WardingSpot", name = "Perfect Ward", type = MENU })
		self.Menu.WardingSpot:MenuElement({id = "Enabled", name = "Draw Perfect Ward Spots", value = true})			
	
	-- Trap Tracker --
	self.Menu:MenuElement({id = "Trap", name = "Trap Tracker", type = MENU })
		self.Menu.Trap:MenuElement({id = "TEnabled", name = "Draw Enemy Traps", value = true})		
		self.Menu.Trap:MenuElement({id = "Nida", name = "Use on Nidalee", value = true})
		self.Menu.Trap:MenuElement({id = "Teemo", name = "Use on Teemo", value = true})
		self.Menu.Trap:MenuElement({id = "Shaco", name = "Use on Shaco", value = true})
		self.Menu.Trap:MenuElement({id = "Jhin", name = "Use on Jhin", value = true})
		self.Menu.Trap:MenuElement({id = "Mao", name = "Use on Maokai", value = true})		
		self.Menu.Trap:MenuElement({id = "FontSize", name = "Text Size", value = 12, min = 10, max = 60})			
end

function WardTrapTracker:Tables()
	self.wards = {
		["Spots"] = {
			{x = 10383, y = 50, z = 3081},
			{x = 11882, y = -70, z = 4121},
			{x = 9703, y = -32, z = 6338},
			{x = 8618, y = 52, z = 4768},
			{x = 5206, y = -46, z = 8511},
			{x = 3148, y = -66, z = 10814},
			{x = 4450, y = 56, z = 11803},
			{x = 6287, y = 54, z = 10150},
			{x = 8268, y = 49, z = 10225},
			{x = 11590, y = 51, z = 7115},
			{x = 10540, y = -62, z = 5117},
			{x = 4421, y = -67, z = 9703},
			{x = 2293, y = 52, z = 9723},
			{x = 7044, y = 54, z = 11352}
		}
	}
end

function WardTrapTracker:WLoadHeros()
	for i = 1, GameHeroCount() do
		local hero = GameHero(i)
		if hero then
			self.enemies[#self.enemies + 1] = hero
		end	
	end
end			

function WardTrapTracker:OnDrawTracker()					
	self:DrawWard() 			
	if self.FoundTrapChamp and self.Menu.Trap.TEnabled:Value() then
		self:TrapTracker() 
	end
	
	if self.Menu.WardingSpot.Enabled:Value() then
		for i = 1, #self.wards.Spots do
			local wardSpot = Vector(self.wards.Spots[i]):To2D()

			if wardSpot.onScreen then
				DrawText("Ward Spot", 10, wardSpot.x-14, wardSpot.y-13, DrawColor(255, 50, 205, 50))
				DrawCircle(Vector(self.wards.Spots[i]), 50, 3, DrawColor(255, 50, 205, 50))
			end
		end
	end	
end

function WardTrapTracker:Tick()	
	self:ScanCheck()
end

function WardTrapTracker:ScanCheck()
	for i, hero in lpairs(self.enemies) do
		if hero and hero.isEnemy then
			self:ScanWards()
			self:CheckTrapChamps(hero)
			if self.FoundTrapChamp and self.Menu.Trap.TEnabled:Value() then	
				self:ScanTrap(hero)	
				self:RemoveTrap()
			end			
		end
	end	
end

function WardTrapTracker:CheckTrapChamps(unit)
	if self.SearchChamp then			
		if unit.charName == "Shaco" then
			self.FoundShaco = true
			self.FoundTrapChamp = true
		end
		if unit.charName == "Jhin" then
			self.FoundJhin = true
			self.FoundTrapChamp = true
		end
		if unit.charName == "Nidalee" then
			self.FoundNida = true
			self.FoundTrapChamp = true
		end
		if unit.charName == "Maokai" then
			self.FoundMao = true
			self.FoundTrapChamp = true
		end	
		if unit.charName == "Teemo" then
			self.FoundTeemo = true
			self.FoundTrapChamp = true
		end	
		self.SearchChamp = false
	end
end

function WardTrapTracker:ScanTrap(unit)	
	if self.FoundTeemo and self.Menu.Trap.Teemo:Value() then
		if unit.charName == "Teemo" then
			local currSpell = unit.activeSpell
			if currSpell and currSpell.valid and currSpell.isChanneling and currSpell.name == "TeemoRCast" then
				DelayAction(function()
					self:CheckObject("TeemoMushroom", self.TeemoTraps)					
				end,0.5)	
			end
		end	
	end

	if self.FoundShaco and self.Menu.Trap.Shaco:Value() then
		if unit.charName == "Shaco" then
			local currSpell = unit.activeSpell
			if currSpell and currSpell.valid and currSpell.isChanneling and currSpell.name == "JackInTheBox" then
				DelayAction(function()
					self:CheckObject("ShacoBox", self.ShacoTraps)					
				end,0.5)	
			end
		end	
	end

	if self.FoundJhin and self.Menu.Trap.Jhin:Value() then
		if unit.charName == "Jhin" then
			local currSpell = unit.activeSpell
			if currSpell and currSpell.valid and currSpell.isChanneling and currSpell.name == "JhinE" then
				DelayAction(function()
					self:CheckObject("JhinTrap", self.JhinTraps)					
				end,0.5)	
			end
		end	
	end	

	if self.FoundNida and self.Menu.Trap.Nida:Value() then
		if unit.charName == "Nidalee" then
		local currSpell = unit.activeSpell
			if currSpell and currSpell.valid and currSpell.isChanneling and currSpell.name == "Bushwhack" then
				DelayAction(function()
					self:CheckObject("NidaleeSpear", self.NidaTraps)					
				end,0.5)	
			end
		end	
	end	

	if self.FoundMao and self.Menu.Trap.Mao:Value() then
		if unit.charName == "Maokai" then
			local currSpell = unit.activeSpell
			if currSpell and currSpell.valid and currSpell.isChanneling and currSpell.name == "MaokaiE" then
				DelayAction(function()
					self:CheckObject("MaokaiSproutling", self.MaoTraps)
				end,0.5)	
			end
		end	
	end		
end

function WardTrapTracker:CheckObject(name, traptable)
	for i = 0, GameObjectCount() do
		local Trap = GameObject(i)
		local NewTrap = true	
		if Trap and Trap.charName == name and Trap.isEnemy then
			for i = 1, #traptable do
				if traptable[i] and traptable[i].networkID == Trap.networkID then
					NewTrap = false
				end
			end				
			
			if NewTrap then 
				TableInsert(traptable, Trap)
			end	
		end
	end
end

function WardTrapTracker:RemoveTrap()	
	if self.FoundTeemo and self.Menu.Trap.Teemo:Value() then
		for i, Trap in lpairs(self.TeemoTraps) do			
			if Trap and (Trap.health <= 0 or Trap.charName ~= "TeemoMushroom") then
				TableRemove(self.TeemoTraps, i)
			end				
		end
	end	
	
	if self.FoundShaco and self.Menu.Trap.Shaco:Value() then
		for i, Trap in lpairs(self.ShacoTraps) do			
			if Trap and (Trap.health <= 0 or Trap.charName ~= "ShacoBox") then
				TableRemove(self.ShacoTraps, i)
			end				
		end
	end

	if self.FoundJhin and self.Menu.Trap.Jhin:Value() then
		for i, Trap in lpairs(self.JhinTraps) do			
			if Trap and (Trap.health <= 0 or Trap.charName ~= "JhinTrap") then
				TableRemove(self.JhinTraps, i)
			end				
		end
	end

	if self.FoundNida and self.Menu.Trap.Nida:Value() then
		for i, Trap in lpairs(self.NidaTraps) do			
			if Trap and (Trap.health <= 0 or Trap.charName ~= "NidaleeSpear") then
				TableRemove(self.NidaTraps, i)
			end				
		end
	end

	if self.FoundMao and self.Menu.Trap.Mao:Value() then
		for i, Trap in lpairs(self.MaoTraps) do			
			if Trap and (Trap.health <= 0 or Trap.charName ~= "MaokaiSproutling") then
				TableRemove(self.MaoTraps, i)
			end				
		end
	end		
end		

function WardTrapTracker:CleanWards()
	for i = 1, #self.wards do
		local ward = self.wards[i]
		local life = 0
		if ward and ward.expire then
			life = ward.expire - Game.Timer()
		end
		if life <= 0 or ward.object == nil or ward.object.health <= 0 then
			TableRemove(self.wards, i)
			--print("Removed")
		end
	end
end	

function WardTrapTracker:ScanWards()
	if self.Menu.Warding.EnabledScan:Value() then
		self:CleanWards()
		if Game.Timer() - self.LastWardScan > 0.9 then
			--print("Scanning")
			for i = 1, GameWardCount() do
				local ward = GameWard(i)
				local NewWard = true
				for i = 1, #self.wards do
					--print(wards[i].networkID)
					if self.wards[i] and self.wards[i].networkID == ward.networkID then
						NewWard = false
					end
				end
				if NewWard then 
					local wardExpire
					if ward.valid and ward.isEnemy then
						for i = 1, ward.buffCount do
							local buff = ward:GetBuff(i);
							if (buff.count > 0) and (buff.expireTime > buff.startTime) then 
								wardExpire = buff.expireTime
							end
						end
						local wardType = ward.maxHealth == 4 and "VisionWard" or ward.maxHealth == 3 and (ward.maxMana == 150 and "SightWard" or "Trinket") or ward.maxHealth == 1 and "Farsight" or "WTFISTHISWARD"
						if wardExpire then
							TableInsert(self.wards, 1, {object = ward, expire = wardExpire, type = wardType, networkID = ward.networkID})
						end 
					end
				end
			end
			self.LastWardScan = Game.Timer()
		end
	end	
end		
local WardColors = {SightWard = DrawColor(255,0,255,0), VisionWard = DrawColor(0xFF,0xAA,0,0xAA), Trinket = DrawColor(0xFF,0xAA,0xAA,0), Farsight = DrawColor(0xFF,00,0xBF,0xFF)}
function WardTrapTracker:DrawWard()
	
	if self.Menu.Warding.Enabled:Value() then
		for i = 1, #self.wards do
			local wardSlot = self.wards[i]
			local ward = wardSlot.object
			local type = wardSlot.type
			local life = wardSlot.expire - Game.Timer()
			if ward and ward.pos2D.onScreen then
				DrawCircle(ward.pos, 70, 3, WardColors[type]);
				
				if self.Menu.Warding["Farsight"].VisionDisplay:Value() and ward.charName == "BlueTrinket" then
					DrawCircle(ward.pos, 500, 3, DrawColor(0xFF,00,0xBF,0xFF));
				end	
				if self.Menu.Warding["VisionWard"].VisionDisplay:Value() and ward.charName == "JammerDevice" then
					DrawCircle(ward.pos, 900, 3, DrawColor(0xFF,0xAA,0,0xAA));
				end	
				if self.Menu.Warding["Trinket"].VisionDisplay:Value() and ward.charName == "YellowTrinket" then
					DrawCircle(ward.pos, 900, 3, DrawColor(0xFF,0xAA,0xAA,0));
				end			
				if self.Menu.Warding["Trinket"].TimerDisplay:Value() and ward.charName == "YellowTrinket" then
					DrawText(IntegerToMinSec(mathceil(life)), 16, ward.pos2D.x, ward.pos2D.y-14, DrawColor(0xFF,0xAA,0xAA,0));
				end
			end
		end
	end
end	

function WardTrapTracker:TrapTracker()
	
	if self.FoundTeemo and self.Menu.Trap.Teemo:Value() then
		for i, Trap in ipairs(self.TeemoTraps) do
			if Trap and Trap.pos2D.onScreen then
				DrawCircle(Trap.pos, 75, 3, DrawColor(255,255,0,0))
				DrawText("Shroom", self.Menu.Trap.FontSize:Value(), Trap.pos2D.x, Trap.pos2D.y, DrawColor(255, 225, 255, 0))
				DrawCircle(Trap.pos, 450, 3, DrawColor(255,0,255,0))
			end
		end
	end	
	
	if self.FoundShaco and self.Menu.Trap.Shaco:Value() then
		for i, Trap in ipairs(self.ShacoTraps) do
			if Trap and Trap.pos2D.onScreen then
				DrawCircle(Trap.pos, 75, 3, DrawColor(255,255,0,0))
				DrawText("Shaco Box", self.Menu.Trap.FontSize:Value(), Trap.pos2D.x, Trap.pos2D.y, DrawColor(255, 225, 255, 0))
				DrawCircle(Trap.pos, 290, 3, DrawColor(255,0,255,0))
			end
		end
	end		
		
	if self.FoundJhin and self.Menu.Trap.Jhin:Value() then
		for i, Trap in ipairs(self.JhinTraps) do
			if Trap and Trap.pos2D.onScreen then		
				DrawCircle(Trap.pos, 75, 3, DrawColor(255,255,0,0))
				DrawText("Jhin Trap", self.Menu.Trap.FontSize:Value(), Trap.pos2D.x, Trap.pos2D.y, DrawColor(255, 225, 255, 0))
			end
		end
	end	

	if self.FoundNida and self.Menu.Trap.Nida:Value() then
		for i, Trap in ipairs(self.NidaTraps) do
			if Trap and Trap.pos2D.onScreen then		
				DrawCircle(Trap, 75, 3, DrawColor(255,255,0,0))
				DrawText("Nida Trap", self.Menu.Trap.FontSize:Value(), Trap.pos2D.x, Trap.pos2D.y, DrawColor(255, 225, 255, 0))
			end
		end
	end	
	
	if self.FoundMao and self.Menu.Trap.Mao:Value() then
		for i, Trap in ipairs(self.MaoTraps) do
			if Trap and Trap.pos2D.onScreen then		
				DrawCircle(Trap.pos, 75, 3, DrawColor(255,255,0,0))
				DrawText("Maokai Sap.", self.Menu.Trap.FontSize:Value(), Trap.pos2D.x, Trap.pos2D.y, DrawColor(255, 225, 255, 0))
				DrawCircle(Trap.pos, 350, 3, DrawColor(255,0,255,0))
			end
		end
	end	
end





class "RecallTracker"

function RecallTracker:__init()
	if not FileExist(SPRITE_PATH.."RecallTracker.png") then
		print("Missing Images, Downloading...")
		print("Pls Reload GoS 2xF6...")
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/RecallTracker.png", SPRITE_PATH.."RecallTracker.png", function() end)
		return
	end
	self:LoadData()
	self:LoadRecallTrackerMenu()
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("ProcessRecall", function(unit, recall) self:ProcessRecall(unit, recall) end)
	--Callback.Add("Tick", function() self:Tick() end)
end

function RecallTracker:LoadData()
	self.Sprite = Sprite("RecallTracker.png")
	self.Enemies, self.RecallData = {}, {}
end

function RecallTracker:LoadRecallTrackerMenu()
	self.Menu = MenuElement({type = MENU, id = "PussyUtillity", name = "Recall Tracker"})
    	self.Menu:MenuElement({type = MENU, id = "Tracker", name = "Tracker Settings"})
    	self.Menu.Tracker:MenuElement({id = "Enabled", name = "Show Recall Bar", value = true})
    	self.Menu.Tracker:MenuElement({id = "Circle", name = "Draw Circle last seen RecallUser.pos", value = true})		
    	self.Menu.Tracker:MenuElement({id = "X", name = "X Offset", value = Game.Resolution().x - 260, min = 0, max = Game.Resolution().x - 260, step = 1, callback = function(value) self.Sprite:SetPos(value, self.Sprite.y) end})
    	self.Menu.Tracker:MenuElement({id = "Y", name = "Y Offset", value = Game.Resolution().y - 250, min = 0, max = Game.Resolution().y - 51, step = 1, callback = function(value) self.Sprite:SetPos(self.Sprite.x, value) end})
    	self.Sprite:SetPos(self.Menu.Tracker.X:Value(), self.Menu.Tracker.Y:Value())
end

function RecallTracker:ProcessRecall(unit, recall)
	if not unit.isEnemy then return end
	if recall.isStart then
    	TableInsert(self.RecallData, {object = unit, start = Game.Timer(), duration = (recall.totalTime*0.001)})
    else
      	for i, rc in lpairs(self.RecallData) do
        	if rc.object.networkID == unit.networkID then
          		TableRemove(self.RecallData, i)
        	end
      	end
    end
end

function RecallTracker:GetRecallData(unit)
    	for i, recall in lpairs(self.RecallData) do
    		if recall.object.networkID == unit.networkID then
    			return {isRecalling = true, timeToRecall = recall.start+recall.duration-Game.Timer()}
	    	end
	end
	return {isRecalling = false, timeToRecall = 0}
end

function RecallTracker:ColorGradient(percent) 
    	local percent = mathmin(99, percent)
    	return DrawColor(255, percent < 50 and 255 or mathceil(255 * ((50 - percent % 50) / 50)), percent >= 50 and 255 or mathceil(255 * (percent / 50)), 0)
end

function RecallTracker:Draw()
	if #self.RecallData == 0 or self.Sprite == 0 then return end
	self.Sprite:Draw()
	for i, recall in lpairs(self.RecallData) do
		if self.Menu.Tracker.Enabled:Value() and Game.Timer() - recall.start < recall.duration then
			DrawRect(self.Sprite.x+6, self.Sprite.y+13, (recall.start+recall.duration-Game.Timer()) / recall.duration * 238, 7, self:ColorGradient((recall.start+recall.duration-Game.Timer()) / recall.duration * 100))
            DrawText(recall.object.charName.. " " ..mathceil((1 - (Game.Timer() - recall.start) / recall.duration) * 100) .. "%", 15, self.Sprite.x - 40 + ((recall.start+recall.duration-Game.Timer()) / recall.duration) * 238, self.Sprite.y - 10 - i * 15, DrawColor(255, 255, 255, 255))
			DrawLine(self.Sprite.x+6+(recall.start+recall.duration-Game.Timer()) / recall.duration * 238, self.Sprite.y+13, self.Sprite.x+6+(recall.start+recall.duration-Game.Timer()) / recall.duration * 238, self.Sprite.y + 5 - i * 15, 2, DrawColor(150,255,255,255))
			DrawCircle(recall.object.pos, 100, 3, Draw.Color(255,0,255,0))
			DrawText(recall.object.charName.." Recall", 14, recall.object.pos2D.x-25, recall.object.pos2D.y, DrawColor(200,0,255,0))
		end
		if self.Menu.Tracker.Circle:Value() and Game.Timer() - recall.start < recall.duration then
			DrawCircle(recall.object.pos, 100, 3, Draw.Color(255,0,255,0))
			DrawText(recall.object.charName.." Recall", 14, recall.object.pos2D.x-25, recall.object.pos2D.y, DrawColor(200,0,255,0))		
		end
	end
end




class "AutoLvL"

function AutoLvL:__init()
	self.levelUP = false	
	self:LoadLvLMenu()
	Callback.Add("Tick", function() self:Tick() end)	
end

function AutoLvL:LoadLvLMenu()
	self.Menu = MenuElement({type = MENU, id = myHero.charName.."ALvL", name = "AutoLvL Spells"})
		self.Menu:MenuElement({id = "on", name = "Enabled", value = true})
		self.Menu:MenuElement({id = "LvL", name = "AutoLevel start -->", value = 2, min = 1, max = 6, step = 1})
		self.Menu:MenuElement({id = "delay", name = "Delay for Level up", value = 2, min = 0 , max = 10, step = 0.5, identifier = "sec"})
		self.Menu:MenuElement({id = "Order", name = "Skill Order", value = 1, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})	
end
	
function AutoLvL:Tick()	
	if Game.IsOnTop() then
		self:AutoLevelStart()
	end	
end

function AutoLvL:GetSkillOrder()
	local Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	if self.Menu.Order:Value() == 1 then
		Spell1, Spell2, Spell3 = HK_Q, HK_W, HK_E
	elseif self.Menu.Order:Value() == 2 then
		Spell1, Spell2, Spell3 = HK_W, HK_E, HK_Q
	elseif self.Menu.Order:Value() == 3 then
		Spell1, Spell2, Spell3 = HK_E, HK_Q, HK_W
	elseif self.Menu.Order:Value() == 4 then
		Spell1, Spell2, Spell3 = HK_E, HK_W, HK_Q
	elseif self.Menu.Order:Value() == 5 then
		Spell1, Spell2, Spell3 = HK_W, HK_Q, HK_E
	elseif self.Menu.Order:Value() == 6 then
		Spell1, Spell2, Spell3 = HK_Q, HK_E, HK_W
	end
	return Spell1, Spell2, Spell3
end

function AutoLvL:AutoLevelStart()
	if self.Menu.on:Value() and not self.levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts
		local Spell1, Spell2, Spell3 = self:GetSkillOrder() 

		if (actualLevel == 18 and levelPoints == 0) or self.Menu.LvL:Value() > actualLevel then return end
	
		if levelPoints > 0 then
			self.levelUP = true
			local Delay = self.Menu.delay:Value()
			DelayAction(function()
				if actualLevel == 6 or actualLevel == 11 or actualLevel == 16 then
					Control.KeyDown(HK_LUS)
					Control.KeyDown(HK_R)
					Control.KeyUp(HK_R)
					Control.KeyUp(HK_LUS)
				elseif actualLevel == 1 or actualLevel == 4 or actualLevel == 5 or actualLevel == 7 or actualLevel == 9 then
					Control.KeyDown(HK_LUS)
					Control.KeyDown(Spell1)
					Control.KeyUp(Spell1)
					Control.KeyUp(HK_LUS)
				elseif actualLevel == 2 or actualLevel == 8 or actualLevel == 10 or actualLevel == 12 or actualLevel == 13 then
					Control.KeyDown(HK_LUS)
					Control.KeyDown(Spell2)
					Control.KeyUp(Spell2)
					Control.KeyUp(HK_LUS)
				elseif actualLevel == 3 or actualLevel == 14 or actualLevel == 15 or actualLevel == 17 or actualLevel == 18 then				
					Control.KeyDown(HK_LUS)
					Control.KeyDown(Spell3)
					Control.KeyUp(Spell3)
					Control.KeyUp(HK_LUS)
				end
				DelayAction(function()
					self.levelUP = false
				end, 0.25)				
			end, Delay)	
		end
	end	
end




class "CooldownTracker"

function CooldownTracker:__init()
	if not FileExist(SPRITE_PATH.."SummonerBarrier.png") then
		print("Missing Images, Downloading...")
		print("Pls Reload GoS 2xF6...")
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerBarrier.png", SPRITE_PATH.."SummonerBarrier.png", function() end)
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerBoost.png", SPRITE_PATH.."SummonerBoost.png", function() end)		
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerExhaust.png", SPRITE_PATH.."SummonerExhaust.png", function() end)
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerFlash.png", SPRITE_PATH.."SummonerFlash.png", function() end)
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerHaste.png", SPRITE_PATH.."SummonerHaste.png", function() end)
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerHeal.png", SPRITE_PATH.."SummonerHeal.png", function() end)
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerDot.png", SPRITE_PATH.."SummonerDot.png", function() end)
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerSmite.png", SPRITE_PATH.."SummonerSmite.png", function() end)
		DownloadFileAsync("https://raw.githubusercontent.com/Pussykate/GoS/master/Utility/Images/SummonerTeleport.png", SPRITE_PATH.."SummonerTeleport.png", function() end)
		return
	end	
	self.Summon, self.enemies = {}, {}
	self:CLoadHeros()
	self:CLoadData()
	self:LoadCTrackerMenu()
	Callback.Add("Draw", function() self:Draw() end)
end

function CooldownTracker:CLoadData()
	local _URL = "MenuElement\\"
	local _SIZE = 0.35
	
	self.Summon["SummonerBarrier"] = Sprite(_URL.."SummonerBarrier.png", _SIZE)
	self.Summon["SummonerBoost"] = Sprite(_URL.."SummonerBoost.png", _SIZE)
	self.Summon["SummonerExhaust"] = Sprite(_URL.."SummonerExhaust.png", _SIZE)
	self.Summon["SummonerFlash"] = Sprite(_URL.."SummonerFlash.png", _SIZE)
	self.Summon["SummonerHaste"] = Sprite(_URL.."SummonerHaste.png", _SIZE)
	self.Summon["SummonerHeal"] = Sprite(_URL.."SummonerHeal.png", _SIZE)
	self.Summon["SummonerDot"] = Sprite(_URL.."SummonerDot.png", _SIZE)
	self.Summon["SummonerSmite"] = Sprite(_URL.."SummonerSmite.png", _SIZE)
	self.Summon["S5_SummonerSmitePlayerGanker"] = Sprite(_URL.."SummonerSmite.png", _SIZE)
	self.Summon["S5_SummonerSmiteDuel"] = Sprite(_URL.."SummonerSmite.png", _SIZE)
	self.Summon["SummonerTeleport"] = Sprite(_URL.."SummonerTeleport.png", _SIZE)
end

function CooldownTracker:LoadCTrackerMenu()
	self.Menu = MenuElement({type = MENU, id = "Ctracker", name = "CooldownTracker"})
	self.Menu:MenuElement({id = "myteam", name = "Show Cooldowns my Team", value = false})
	self.Menu:MenuElement({id = "mycooldown", name = "Show own Cooldowns", value = false})		
	self.Menu:MenuElement({id = "enemyteam", name = "Show Cooldowns Enemy Team", value = true})
	self.Menu:MenuElement({id = "mana", name = "BlackBar / Ready Spell but not enough Mana", value = true})	
	self.Menu:MenuElement({id = "x", name = "Pos: [X]", value = -75, min = -150, max = 150, step = 1})
	self.Menu:MenuElement({id = "y", name = "Pos: [Y]", value = 10, min = -150, max = 150, step = 1})
end
	
function CooldownTracker:CLoadHeros()
	for i = 1, GameHeroCount() do
		local hero = GameHero(i)
		if hero then
			self.enemies[#self.enemies + 1] = hero
		end	
	end
end	

function CooldownTracker:Draw_Hero(hero)
	local x = width - 101
	local y = 70

	local offsetY = self.Menu.y:Value()
	local offsetT = offsetY+1
	
	local offsetQ = self.Menu.x:Value()
	local offsetW = offsetQ + 25
	local offsetE = offsetW + 25
	local offsetR = offsetE + 25
	
	local offsetS = offsetR + 27
	local offsetF = offsetS+ 25
	
	local offsetText = 12
	
	local wight = 24
	local hight = 17
	
	local barPos = hero.pos2D
	local t_wight = 0
	
	local spellQ = hero:GetSpellData(_Q).currentCd
	local spellW = hero:GetSpellData(_W).currentCd
	local spellE = hero:GetSpellData(_E).currentCd
	local spellR = hero:GetSpellData(_R).currentCd
		 
	if hero.pos2D.onScreen then
		if hero.visible and hero.dead == false then   		
			DrawRect(barPos.x+offsetQ-2, barPos.y+offsetY-2, 125, 22, DrawColor(200,0,0,0)) 
		
			if hero:GetSpellData(_Q).level ~= 0 then
				t_wight = Draw.FontRect(mfloor(spellQ),14).x
				if spellQ ~= 0 then
					DrawRect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
					DrawText(mfloor(spellQ), 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
				else
					if self.Menu.mana:Value() then
						if hero:GetSpellData(_Q).mana <= hero.mana then 
							DrawRect(barPos.x+offsetQ,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
							DrawText("Q", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2),barPos.y+offsetT, DrawColor(200,255,255,255))
						else
							DrawRect(barPos.x+offsetQ,  barPos.y+offsetY, wight,hight, DrawColor(255, 23, 23, 23)) 
							DrawText("Q", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2),barPos.y+offsetT, DrawColor(200,255,255,255))
						end
					else
						DrawRect(barPos.x+offsetQ,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
						DrawText("Q", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2),barPos.y+offsetT, DrawColor(200,255,255,255))					
					end	
				end
			else
				t_wight =Draw.FontRect("~",14).x
				DrawRect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
				DrawText("~", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
			end	
			
			if hero:GetSpellData(_W).level ~= 0 then
				t_wight =Draw.FontRect(mfloor(spellW),14).x
				if spellW ~= 0 then
					DrawRect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
					DrawText(mfloor(spellW), 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
				else
					if self.Menu.mana:Value() then				
						if hero:GetSpellData(_W).mana <= hero.mana then 
							DrawRect(barPos.x+offsetW,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
							DrawText("W", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						else
							DrawRect(barPos.x+offsetW,  barPos.y+offsetY, wight,hight, DrawColor(255, 23, 23, 23)) 
							DrawText("W", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						end
					else
						DrawRect(barPos.x+offsetW,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
						DrawText("W", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
					end	
				end
			else
				t_wight =Draw.FontRect("~",14).x
				DrawRect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
				DrawText("~", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
			end
			
			if hero:GetSpellData(_E).level ~= 0 then
				t_wight =Draw.FontRect(mfloor(spellE),14).x
				if spellE ~= 0 then
					DrawRect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
					DrawText(mfloor(spellE), 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
				else
					if self.Menu.mana:Value() then				
						if hero:GetSpellData(_E).mana <= hero.mana then 				
							DrawRect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
							DrawText("E", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						else
							DrawRect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, DrawColor(255, 23, 23, 23)) 
							DrawText("E", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255)) 
						end
					else
						DrawRect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
						DrawText("E", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
					end
				end
			else
				t_wight =Draw.FontRect("~",14).x
				DrawRect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
				DrawText("~", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
			end	
			
			if hero:GetSpellData(_R).level ~= 0 then
				t_wight =Draw.FontRect(mfloor(spellR),14).x
				if spellR ~= 0 then
					DrawRect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
					DrawText(mfloor(spellR), 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
				else
					if self.Menu.mana:Value() then				
						if hero:GetSpellData(_R).mana <= hero.mana then 				
							DrawRect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
							DrawText("R", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						else
							DrawRect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, DrawColor(255, 23, 23, 23)) 
							DrawText("R", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255)) 
						end
					else
						DrawRect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
						DrawText("R", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
					end	
				end
			else
				t_wight =Draw.FontRect("~",14).x
				DrawRect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
				DrawText("~", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
			end
		
			local spellOneCd = hero:GetSpellData(SUMMONER_1).currentCd
			if spellOneCd ~= 0 then
				self.Summon[hero:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
				DrawRect(barPos.x+offsetS-3,  barPos.y+offsetY-3, wight+3,hight+6, DrawColor(150,0,0,0)) 
				t_wight =Draw.FontRect(mfloor(spellOneCd),14).x
				DrawText(mfloor(spellOneCd), 14, (barPos.x+offsetS+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255)) 
			else
				self.Summon[hero:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
			end
			
			local spellTwoCd = hero:GetSpellData(SUMMONER_2).currentCd
			if spellTwoCd ~= 0 then
				self.Summon[hero:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
				DrawRect(barPos.x+offsetF-3,  barPos.y+offsetY-3, wight+3,hight+6, DrawColor(150,0,0,0)) 
				t_wight =Draw.FontRect(mfloor(spellTwoCd),14).x
				DrawText(mfloor(spellTwoCd), 14, (barPos.x+offsetF+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
			else
				self.Summon[hero:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
			end			
		end	
	end
end	

function CooldownTracker:Draw()
	for i, hero in lpairs(self.enemies) do
		if hero then
			if self.Menu.mycooldown:Value() then
				if hero and hero.team == myHero.team and myHero == hero then
					self:Draw_Hero(hero)
				end
			end		
			
			if self.Menu.myteam:Value() then
				if hero and hero.team == myHero.team and myHero ~= hero then
					self:Draw_Hero(hero)
				end
			end
			
			if self.Menu.enemyteam:Value() then
				if hero and hero.team ~= myHero.team then
					self:Draw_Hero(hero)
				end
			end
		end	
	end
end

function OnLoad()
  	WardTrapTracker()
	RecallTracker()
	AutoLvL()
	CooldownTracker()
end
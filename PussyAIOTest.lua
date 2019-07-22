local Heroes = {"Kalista","Mordekaiser","LeeSin","Soraka","Lux","Yuumi","Rakan","Nidalee","Ryze","XinZhao","Kassadin","Veigar","Tristana","Warwick","Neeko","Cassiopeia","Malzahar","Zyra","Sylas","Kayle","Morgana","Ekko","Xerath","Sona","Ahri"}
local GsoPred = {"Veigar","Kalista","Mordekaiser","LeeSin","Soraka","Lux","Yuumi","Rakan","Nidalee","Ryze","Cassiopeia","Malzahar","Zyra","Kayle","Morgana","Ekko","Xerath","Sona","Ahri"}
local Adc = {"Kalista","Tristana"}
local Support = {"Soraka","Yuumi","Rakan","Zyra","Morgana","Sona"}
local Mid = {"Lux","Ryze","Kassadin","Veigar","Neeko","Cassiopeia","Malzahar","Sylas","Ekko","Xerath","Ahri"}
local Top = {"Mordekaiser","Kayle"}
local Jungle = {"LeeSin","Nidalee","XinZhao","Warwick"}



if not table.contains(Heroes, myHero.charName) then return end




    local Version = 11.8
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyAIOTest.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyAIOTest.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyAIOTest.version",
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
            print("New PussyAIO Version Press 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end	
	end
	




local isLoaded = false
function TryLoad()
	if Game.Timer() < 10 then return end
	isLoaded = true	
	if table.contains(Heroes, myHero.charName) then
		
		if table.contains(Adc, myHero.charName) then
			if not FileExist(COMMON_PATH .. "PussyADC.lua") then
				print("Champion.lib installed Press 2x F6")
				DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "PussyADC.lua", function() end)
				while not FileExist(COMMON_PATH .. "PussyADC.lua") do end
			end	
		require "PussyADC"
		
		elseif table.contains(Support, myHero.charName) then
			if not FileExist(COMMON_PATH .. "PussySUPP.lua") then
				print("Champion.lib installed Press 2x F6")
				DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "PussySUPP.lua", function() end)
				while not FileExist(COMMON_PATH .. "PussySUPP.lua") do end
			end	
		require "PussySUPP"	

		elseif table.contains(Mid, myHero.charName) then
			if not FileExist(COMMON_PATH .. "PussyMID.lua") then
				print("Champion.lib installed Press 2x F6")
				DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "PussyMID.lua", function() end)
				while not FileExist(COMMON_PATH .. "PussyMID.lua") do end
			end	
		require "PussyMID"	

		elseif table.contains(Top, myHero.charName) then
			if not FileExist(COMMON_PATH .. "PussyTOP.lua") then
				print("Champion.lib installed Press 2x F6")
				DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "PussyTOP.lua", function() end)
				while not FileExist(COMMON_PATH .. "PussyTOP.lua") do end
			end	
		require "PussyTOP"

		else 
			table.contains(Jungle, myHero.charName) then
			if not FileExist(COMMON_PATH .. "PussyJUNGLE.lua") then
				print("Champion.lib installed Press 2x F6")
				DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-External/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "PussyJUNGLE.lua", function() end)
				while not FileExist(COMMON_PATH .. "PussyJUNGLE.lua") do end
			end	
		require "PussyJUNGLE"		
		end
	end	
end

function OnLoad()
	AutoUpdate()
	Start()
end


	
if table.contains(GsoPred, myHero.charName) then
	if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
		DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
		while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
								

	end
require "GamsteronPrediction"	
end

if table.contains(Heroes, myHero.charName) then
	if not FileExist(COMMON_PATH .. "PussyManager.lua") then
		DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "PussyManager.lua", function() end)
		while not FileExist(COMMON_PATH .. "PussyManager.lua") do end
								

	end
require "PussyManager"	
end
	

require "Collision"
require "2DGeometry"

class "Start"

function Start:__init()
	
	Callback.Add("Draw", function() self:Draw() end)
end



function Start:Draw()
if not isLoaded then
	TryLoad()
	return
end
local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
local textPos = myHero.pos:To2D()	

    if NewVersion > Version then
		Draw.Text("New PussyAIO Vers. Press 2xF6", 50, textPos.x + 100, textPos.y - 200, Draw.Color(255, 255, 0, 0))
	end
	
	if Game.Timer() > 20 then return end 
	if NewVersion == Version then	
		Draw.Text("Version: 11.8", 20, textPos.x + 400, textPos.y - 220, Draw.Color(255, 255, 0, 0))
		
		Draw.Text("Welcome to PussyAIO", 50, textPos.x + 100, textPos.y - 200, Draw.Color(255, 255, 100, 0))
		Draw.Text("Supported Champs", 30, textPos.x + 200, textPos.y - 150, Draw.Color(255, 255, 200, 0))
		
		Draw.Text("Ahri", 25, textPos.x + 200, textPos.y - 100, Draw.Color(255, 255, 200, 0))
		Draw.Text("Ekko", 25, textPos.x + 200, textPos.y - 80, Draw.Color(255, 255, 200, 0))
		Draw.Text("Kayle", 25, textPos.x + 200, textPos.y - 60, Draw.Color(255, 255, 200, 0))
		Draw.Text("Kalista", 25, textPos.x + 200, textPos.y - 40, Draw.Color(255, 255, 200, 0))
		Draw.Text("Lux", 25, textPos.x + 200, textPos.y - 20, Draw.Color(255, 255, 200, 0))
		Draw.Text("Morgana", 25, textPos.x + 200, textPos.y - 1, Draw.Color(255, 255, 200, 0))
		Draw.Text("Neeko", 25, textPos.x + 200, textPos.y + 20 , Draw.Color(255, 255, 200, 0))
		Draw.Text("Rakan", 25, textPos.x + 200, textPos.y + 40, Draw.Color(255, 255, 200, 0))
		Draw.Text("Soraka", 25, textPos.x + 200, textPos.y + 60, Draw.Color(255, 255, 200, 0))
		Draw.Text("Sylas", 25, textPos.x + 200, textPos.y + 80, Draw.Color(255, 255, 200, 0))		
		Draw.Text("Veigar", 25, textPos.x + 200, textPos.y + 100, Draw.Color(255, 255, 200, 0))	
		Draw.Text("Xerath", 25, textPos.x + 200, textPos.y + 120, Draw.Color(255, 255, 200, 0))
		Draw.Text("Yuumi", 25, textPos.x + 200, textPos.y + 140, Draw.Color(255, 255, 200, 0))


		Draw.Text("Cassiopeia", 25, textPos.x + 300, textPos.y - 100, Draw.Color(255, 255, 200, 0))	
		Draw.Text("Kassadin", 25, textPos.x + 300, textPos.y - 80, Draw.Color(255, 255, 200, 0))
		Draw.Text("LeeSin", 25, textPos.x + 300, textPos.y - 60, Draw.Color(255, 255, 200, 0))
		Draw.Text("Malzahar", 25, textPos.x + 300, textPos.y - 40, Draw.Color(255, 255, 200, 0))
		Draw.Text("Mordekaiser", 25, textPos.x + 300, textPos.y - 20, Draw.Color(255, 255, 200, 0))
		Draw.Text("Nidalee", 25, textPos.x + 300, textPos.y - 1 , Draw.Color(255, 255, 200, 0))
		Draw.Text("Ryze", 25, textPos.x + 300, textPos.y + 20, Draw.Color(255, 255, 200, 0))
		Draw.Text("Sona", 25, textPos.x + 300, textPos.y + 40, Draw.Color(255, 255, 200, 0))
		Draw.Text("Tristana", 25, textPos.x + 300, textPos.y + 60, Draw.Color(255, 255, 200, 0))		
		Draw.Text("Warwick", 25, textPos.x + 300, textPos.y + 80, Draw.Color(255, 255, 200, 0))	
		Draw.Text("XinZhao", 25, textPos.x + 300, textPos.y + 100, Draw.Color(255, 255, 200, 0))
		Draw.Text("Zyra", 25, textPos.x + 300, textPos.y + 120, Draw.Color(255, 255, 200, 0))		
	end
end	

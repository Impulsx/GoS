local version = 1.00
local myChamp = myHero.charName
local supportedChamps = {
	['Ahri'] = true, ['Camille'] = true, ['Cassiopeia'] = true, ['Ekko'] = true, ['Jhin'] = true, ['Kassadin'] = true, ['Lux'] = true, ['Malzahar'] = true, ['Morgana'] = true,
	['Mordekaiser'] = true, ['Neeko'] = true, ['Nidalee'] = true, ['Qiyana'] = true, ['Ryze'] = true, ['Soraka'] = true, ['Sona'] = true, ['Sylas'] = true, ['Tristana'] = true,
	['Veigar'] = true, ['Warwick'] = true, ['XinZhao'] = true, ['Zyra'] = true, ['LeeSin'] = true	
}

local function ReadFile(path, fileName)
    local file = io.open(path .. fileName, "r")
    local result = file:read()
    file:close()
    return result
end

DownloadFileAsync("github...PussyLoader.version", COMMON_PATH .. "PussyLoader.version", function() 
	local onlineVersion = tonumber(ReadFile(COMMON_PATH , "PussyLoader.version"))

	if onlineVersion > version then
		DownloadFileAsync("github...PussyLoader.lua", COMMON_PATH .. "PussyLoader.lua", function()
			print("PussyLoader updated. Press F6 to reload.")
		end)

		return
	else
		--no update needed, proceed
		if supportedChamps[myChamp] then
			--Champ is supported, now check if the script has been downloaded
			local fileName = 'Pussy' .. myChamp

			if FileExist(COMMON_PATH .. fileName .. ".lua") then
				require fileName --requires you to name every champ 'PussyCHAMPNAME.lua' e.g. PussyQiyana.lua
				print("PussyLoader: " .. filename .. " loaded.")
			else
				--Download the script and start it once finished
				DownloadFileAsync("github..." .. fileName .. ".lua", COMMON_PATH .. fileName .. ".lua", function()
					require fileName
					print("PussyLoader: " .. filename .. " loaded.")
				end)
			end
		else
			-- This champ is not supported, print?
		end
	end
end)
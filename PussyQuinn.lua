

-- [ AutoUpdate ] 
do
    
    local Version = 0.02
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyQuinn.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyQuinn.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyQuinn.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyQuinn.version"
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
            print("New PussyQuinn Version Press 2x F6")
        else
            print("PussyQuinn loaded")
        end
    
    end
    
    AutoUpdate()

end 



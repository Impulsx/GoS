

-- [ AutoUpdate ]
do
    
    local Version = 0.06
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyLillia.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyLillia.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyLillia.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyLillia.version"
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
            print("New PussyLillia Version Press 2x F6")
        else
            print("PussyLillia loaded")
        end
    
    end
    
    AutoUpdate()

end 



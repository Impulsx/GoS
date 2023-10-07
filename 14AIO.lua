local version = 0.25

local champName = myHero.charName

local SupportChampion = {
    ["Amumu"]      = true,
    ["Ashe"]       = true,
    ["Blitzcrank"] = true,
    ["Brand"]      = true,
    ["Diana"]      = true,
    ["Garen"]      = true,
    ["Graves"]     = true,
    ["Jax"]        = true,
    ["Kaisa"]      = true,
    ["Kayle"]      = true,
    ["Kennen"]     = true,
    ["Khazix"]     = true,
    ["Kindred"]    = true,
    ["Leona"]      = true,
    ["Lulu"]       = true,
    ["Morgana"]    = true,
    ["Nautilus"]   = true,
    ["Orianna"]    = true,
    ["Pantheon"]   = true,
    ["Ryze"]       = true,
    ["Senna"]      = true,
    ["Sivir"]      = true,
    ["Talon"]      = true,
    ["Thresh"]     = true,
    ["Tristana"]   = true,
    ["Tryndamere"] = true,
    ["Vayne"]      = true,
    ["Vi"]         = true,
    ["Yasuo"]      = true,
    ["Zilean"]     = true,
}
local AIOPath = "14AIO\\"
local AIO_CHAMPS = COMMON_PATH.."14AIO/"
local dotlua = ".lua"
local dotversion = ".version"
local AIO_name = "14AIO"
local AIO = AIO_name..dotlua
local AIO_VERSION = AIO_name..dotversion
local SCRIPT_FULL_PATH = SCRIPT_PATH .. AIO
local champFile = "14"..champName..dotlua
local champVersion = "14"..champName..dotversion
local champgitHub = "https://raw.githubusercontent.com/Impulsx/GoS/master/14AIO/"
local gitHub = "https://raw.githubusercontent.com/Impulsx/GoS/master/"

local function FileExists(path)
    local file = io.open(path, "r")
    if file ~= nil then
        io.close(file)
        return true
    else
        return false
    end
end

local function DownloadFile(path, fileName)
    local startTime = os.clock()
    DownloadFileAsync(gitHub .. fileName, path .. fileName, function() end)
    repeat until os.clock() - startTime > 3 or FileExists(path .. fileName)
end

local function AIOScriptDownload(path, fileName)
    local startTime = os.clock()
    DownloadFileAsync(champgitHub .. fileName, path .. fileName, function() end)
    repeat until os.clock() - startTime > 3 or FileExists(path .. fileName)
    if (FileExists(path .. fileName)) then
        return true
    else
        return false
    end
end

local function ReadFile(path, fileName)
    local file = io.open(path .. fileName, "r")
    local result = file:read()
    file:close()
    return result
end

local function CheckUpdateHeroScript()
    local scriptVersion = 0
    if FileExists(AIO_CHAMPS..champVersion) then
        scriptVersion = tonumber(ReadFile(AIO_CHAMPS, champVersion))
    else
        AIOScriptDownload(AIO_CHAMPS, champVersion)
    end
    local NewVersion = tonumber(ReadFile(AIO_CHAMPS, champVersion))
    if NewVersion > scriptVersion then
        AIOScriptDownload(AIO_CHAMPS, champFile)
        return true
    else
        return false
    end
end

local function DownloadALLChampScripts()
    for k,v in pairs(SupportChampion) do
        --if not FileExists(AIO_CHAMPS..k..dotlua) then
            print("| 14AIO | Downloading All Champion Scripts")
            AIOScriptDownload(AIO_CHAMPS, "14"..k..dotlua)
            AIOScriptDownload(AIO_CHAMPS, "14"..k..dotversion)
        --end
    end
end

local function CheckSupportedChamp()
    local result = FileExists(AIO_CHAMPS .. champFile)
    if (result == true) then
        return result
    else
        local tryDownload = AIOScriptDownload(AIO_CHAMPS, champFile)
        if (tryDownload) == true then return true end
        return result
    end
end

do
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = AIO,
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = AIO_VERSION,
        }
    }

--[[     local function DownloadFile(path, fileName)
        DownloadFileAsync(gitHub .. fileName, path .. fileName, function() end)
        while not FileExist(path .. fileName) do end
    end

    local function ReadFile(path, fileName)
        local file = assert(io.open(path .. fileName, "r"))
        local result = file:read()
        file:close()
        return result
    end ]]

    local function update()
        DownloadFile(Files.Version.Path, Files.Version.Name)
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > version then
            DownloadFile(Files.Lua.Path, Files.Lua.Name)
            DownloadALLChampScripts()
            print("*WARNING* New 14AIO [ver. " .. tostring(NewVersion) .. "] Downloaded - Please RELOAD with [ F6 ]")
        else
            print("| 14AIO | [ver. " .. tostring(version) .. "] loaded!")
        end
    end
    update()
end

if SupportChampion[champName] then
    if (CheckUpdateHeroScript()) then
        print("New 14AIO " .. champName .. " Version - Please RELOAD with [ F6 ]")
    else
        print("| 14AIO | " .. champName .. " Loaded! Enjoy :)")
    end

    local function Init14AIO()
        if (CheckSupportedChamp()) then --redundent
            require("14AIO\\14"..champName)
        else
            DownloadALLChampScripts()
            print("| 14AIO | - " .. champName .. " missing and downloaded - Please RELOAD with [ F6 ]")
        end
    end

    Callback.Add("Load", function()
        Init14AIO()
    end)
end
--[[
if SupportChampion[champName] then

    Callback.Add("Load", function()
        require(AIO_CHAMPS..champFile)
    end)

else
    print("| 14AIO | - " .. champName .. " is not supported!")
end

Callback.Add("Load", function()
    require(AIOPath.."source\\" .. lua)
end) ]]

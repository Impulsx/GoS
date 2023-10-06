local version = 0.24


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
local SCRIPT_FULL_PATH = SCRIPT_PATH .. "14AIO.lua"
local AIO_CHAMPS = COMMON_PATH .. "14AIO/"
local dotlua = ".lua"
local dotversion = ".version"
local AIO = "14AIO.lua"
local AIO_VERSION = "14AIO.version"
local champFile = "14" .. champName .. ".lua"
local champVersion = "14" .. champName .. ".version"
local champgitHub = "https://raw.githubusercontent.com/Impulsx/GoS/master/14AIO/"
local gitHub = "https://raw.githubusercontent.com/Impulsx/GoS/master/"

do
    --local AIOPath = "14AIO\\"
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
    local function DownloadFile(path, fileName)
        DownloadFileAsync(gitHub .. fileName, path .. fileName, function() end)
        while not FileExist(path .. fileName) do end
    end

    local function ReadFile(path, fileName)
        local file = assert(io.open(path .. fileName, "r"))
        local result = file:read()
        file:close()
        return result
    end

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
    end
    DownloadFile(AIO_CHAMPS, champVersion)
    local NewVersion = tonumber(ReadFile(AIO_CHAMPS, champVersion))
    if NewVersion > scriptVersion then
        DownloadFile(AIO_CHAMPS, champFile)
        return true
    else
        return false
    end
end

local function TryChampScriptDownload()
    local startTime = os.clock()
    DownloadFileAsync(gitHub .. "14AIO/" .. champFile, AIO_CHAMPS .. champFile, function() end)
    repeat until os.clock() - startTime > 3 or FileExists(AIO_CHAMPS .. champFile)
    if (FileExists(AIO_CHAMPS .. champFile)) then
        return true
    else
        return false
    end
end

local function DownloadALLChampScripts()
    for k,v in pairs(SupportChampion) do
        DownloadFile(champgitHub, AIO_CHAMPS, k..dotlua)
        DownloadFile(champgitHub, AIO_CHAMPS, k..dotversion)
    end
end

local function CheckSupportedChamp()
    local result = FileExists(AIO_CHAMPS .. champFile)
    if (result == true) then
        return result
    else
        local tryDownload = TryChampScriptDownload()
        if (tryDownload) == true then return true end
        return result
    end
end


if SupportChampion[champName] then
    if (CheckUpdateHeroScript()) then
        print("New 14AIO " .. champName .. " Version - Please RELOAD with [ F6 ]")
    else
        print("| 14AIO | " .. champName .. " Loaded! Enjoy :)")
    end

    local function Init14AIO()
        if (CheckSupportedChamp()) then --redundent
            require(AIO_CHAMPS .. champName)
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

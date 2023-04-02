local version = 0.24


local champ = myHero.charName
local AiOPath = "14AIO\\"
local lua = "14" .. champ

--[[ local function ReadFile(path, fileName)
    local file = io.open(path .. fileName, "r")
    local result = file:read()
    file:close()
    return result
end ]]

local SupportChampion = {
    ["Lulu"] 	    = 	    true,
    ["Sivir"] 	    = 	    true,
    ["Khazix"] 	    = 	    true,
    ["Brand"] 	    = 	    true,
    ["Amumu"] 	    = 	    true,
    ["Nautilus"]    = 	    true,
    ["Morgana"]     =       true,
    ["Blitzcrank"]  =       true,
    ["Vi"]          =       true,
    ["Zilean"]      =       true,
    ["Yasuo"]       =       true,
    ["Orianna"]     =       true,
    ["Leona"]       =       true,
    ["Senna"]       =       true,
    ["Thresh"]      =       true,
    ["Ryze"]        =       true,
    ["Kaisa"]       =       true,
    ["Kayle"]       =       true,
    ["Vayne"]       =       true,
    ["Kindred"]     =       true,
    ["Graves"]      =       true,
    ["Jax"]         =       true,
    ["Tristana"]    =       true,
    ["Ashe"]        =       true,
    ["Garen"]       =       true,
    ["Pantheon"]    =       true,
    ["Tryndamere"]  =       true,
    ["Kennen"]      =       true,
    ["Talon"]       =       true


}



if SupportChampion[champ] then

    Callback.Add("Load", function()
        require(AiOPath.. lua)
    end)

else
    print(champ.. " Not supported in 14AIO")
end

--[[ Callback.Add("Load", function()
    require(AiOPath.."source\\" .. lua)
end) ]]
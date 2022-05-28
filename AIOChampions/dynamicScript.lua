local menu = 1
local _OnWaypoint = {}
local _OnVision = {}
local Allies = {}; local Enemies = {}; local Turrets = {}; local Units = {}; local AllyHeroes = {}
local intToMode = {[0] = "", [1] = "Combo", [2] = "Harass", [3] = "LastHit", [4] = "Clear"}
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local spellcast = {state = 1, mouse = mousePos}
local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7,}
local Orb
local barHeight, barWidth, barXOffset, barYOffset = 8, 103, 0, 0
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local charging = false
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local sqrt = math.sqrt

if not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") then
	print("GsoPred. installed Press 2x F6")
	DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/GamsteronPrediction.lua", COMMON_PATH .. "GamsteronPrediction.lua", function() end)
	while not FileExist(COMMON_PATH .. "GamsteronPrediction.lua") do end
end
    
require('GamsteronPrediction')

local remaining = 30 - Game.Timer()
print(myHero.charName .. " will load shortly")
DelayAction(function()
	LoadScript()
end, remaining)

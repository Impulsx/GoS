-- [ AutoUpdate ]
do
    
    local Version = 0.09
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussyUtility.lua",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyUtility.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussyUtility.version",
            Url = "https://raw.githubusercontent.com/Pussykate/GoS/master/PussyUtility.version"
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
            print("New PussyUtility Version")
        else
            print("Utility loaded")
        end
    
    end
    
    AutoUpdate()

end

local gankAlert = MenuElement({id = "gaMenu", name = "PussyUtility", type = MENU })
	gankAlert:MenuElement({id = "gui", name = "Interface", type = MENU })
		gankAlert.gui:MenuElement({id = "drawGUI", name = "Draw Interface", value = true})
		gankAlert.gui:MenuElement({id = "side", name = "Cd Tracker Left or Right Side", value = 2, drop = {"Left", "Right"}})		
		gankAlert.gui:MenuElement({id = "x", name = "X", value = 50, min = 0, max = Game.Resolution().x, step = 1})
		gankAlert.gui:MenuElement({id = "y", name = "Y", value = 50, min = 0, max = Game.Resolution().y, step = 1})
		
	gankAlert:MenuElement({id = "circle", name = "Movement Circle", type = MENU })	
		gankAlert.circle:MenuElement({id = "draw", name = "Draw Circle", value = false, tooltip = "Can cause Fps Drops"})
		gankAlert.circle:MenuElement({id = "drawWP", name = "Draw last waypoint", value = false})	
		gankAlert.circle:MenuElement({id = "screen", name = "On Screen", value = false})
		gankAlert.circle:MenuElement({id = "minimap", name = "On Minimap", value = false})
		
	gankAlert:MenuElement({id = "alert", name = "Gank Alert", type = MENU })
		gankAlert.alert:MenuElement({id = "range", name = "Detection Range", value = 2500, min = 1500, max = 4000, step = 10})
		gankAlert.alert:MenuElement({id = "drawGank", name = "Gank Alert", value = true})
		gankAlert.alert:MenuElement({id = "drawGankFOW", name = "FOW Gank Alert", value = true})
		
	
	gankAlert:MenuElement({id = "drawRecall", name = "Predict Recall Position", value = false })
		
	gankAlert:MenuElement({id = "CD", name = "Cooldown Tracker", type = MENU })	 
		gankAlert.CD:MenuElement({id = "Pos", name = "Cd Tracker Interace or Champion", value = 2, drop = {"Interface", "Champion"}})
		gankAlert.CD:MenuElement({id = "x", name = "Champion Pos: [X]", value = -75, min = -150, max = 150, step = 1})
		gankAlert.CD:MenuElement({id = "y", name = "Champion Pos: [Y]", value = 10, min = -300, max = 150, step = 1})		
		gankAlert.CD:MenuElement({id = "enemyspell", name = "Show Enemy Spell CD [Interface]", value = true})
		gankAlert.CD:MenuElement({id = "enemysumm", name = "Show Enemy Summoner CD [Interface]", value = true})
		
	gankAlert:MenuElement({id = "JGLMenu", name = "Jungle Timers", type = MENU })
		gankAlert.JGLMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})
		gankAlert.JGLMenu:MenuElement({id = "OnScreen", name = "On Screen", type = MENU})
			gankAlert.JGLMenu.OnScreen:MenuElement({id = "Enabled", name = "Enabled", value = true})
			gankAlert.JGLMenu.OnScreen:MenuElement({id = "FontSize", name = "Text Size", value = 22, min = 10, max = 60})
		gankAlert.JGLMenu:MenuElement({id = "OnMinimap", name = "On Minimap", type = MENU})
			gankAlert.JGLMenu.OnMinimap:MenuElement({id = "Enabled", name = "Enabled", value = true})
			gankAlert.JGLMenu.OnMinimap:MenuElement({id = "FontSize", name = "Text Size", value = 10, min = 2, max = 36})

		
	gankAlert:MenuElement({id = "TrapMenu", name = "Trap/Tower Tracker", type = MENU })
		gankAlert.TrapMenu:MenuElement({id = "Tower", name = "Draw Enemy Tower Range", value = true})
		gankAlert.TrapMenu:MenuElement({id = "TowerTrans", name = "Tower Range Transparency", value = 80, min = 0, max = 255})					
		
		gankAlert.TrapMenu:MenuElement({id = "Trap", name = "Trap Tracker", type = MENU })
		gankAlert.TrapMenu.Trap:MenuElement({name = " ", drop = {"only use if you have enough (GoS-FPS)"}})
		gankAlert.TrapMenu.Trap:MenuElement({id = "TEnabled", name = "Draw Enemy Traps", value = false})
		gankAlert.TrapMenu.Trap:MenuElement({id = "FontSize", name = "Text Size", value = 12, min = 10, max = 60})		
			
	gankAlert:MenuElement({id = "Warding", name = "Enemy Ward Tracker", type = MENU })

		gankAlert.Warding:MenuElement({id = "Enabled", name = "Enabled", value = true})


		gankAlert.Warding:MenuElement({type = MENU, id = "VisionWard", name = "Control Ward"})
		gankAlert.Warding.VisionWard:MenuElement({id = "ScreenDisplay", name = "Show On Screen", value = true})
		gankAlert.Warding.VisionWard:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})


		gankAlert.Warding:MenuElement({type = MENU, id = "Trinket", name = "Warding Totem"})
		gankAlert.Warding.Trinket:MenuElement({id = "ScreenDisplay", name = "Show On Screen", value = true})
		gankAlert.Warding.Trinket:MenuElement({id = "TimerDisplay", name = "Show Ward Timer", value = true})
		gankAlert.Warding.Trinket:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})


		gankAlert.Warding:MenuElement({type = MENU, id = "Farsight", name = "Farsight Alteration"})
		gankAlert.Warding.Farsight:MenuElement({id = "ScreenDisplay", name = "Show On Screen", value = true})
		gankAlert.Warding.Farsight:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})
		
	gankAlert:MenuElement({id = "PussyLvL".. myHero.charName, name = "Auto Level Spells", type = MENU })		
		gankAlert["PussyLvL".. myHero.charName]:MenuElement({id = "on", name = "Enabled [Starts with LvL 2]", value = true})
		gankAlert["PussyLvL".. myHero.charName]:MenuElement({id = "start", name = "Skill Order", value = 1, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})
		
local function IsMoving(unit)
    return unit.pos.x - math.floor(unit.pos.x) ~= 0
end	

local function EnemiesAround(pos,range)
	local x = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and not hero.dead and hero.isEnemy and hero.pos:DistanceTo(pos) < range and hero.visible then
			x = x + 1
		end
	end
	return x
end

local function EnemiesInvisible(pos,range)
	local x = {}
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.valid and hero.isEnemy and hero.pos:DistanceTo(pos) < range and not hero.visible then
			table.insert(x, hero)
		end
	end
	return x
end

-------------------------

local FOWGank = Sprite("PussySprites\\Tracker\\FOWGank.png")
local APGank = Sprite("PussySprites\\Tracker\\AP.png")
local ADGank = Sprite("PussySprites\\Tracker\\AD.png")
local DEFGank = Sprite("PussySprites\\Tracker\\DEF.png")
local MRGank = Sprite("PussySprites\\Tracker\\MR.png")
local HPGank = Sprite("PussySprites\\Tracker\\HP.png")
local GankGUI = Sprite("PussySprites\\Tracker\\GankGUI.png")
local GankHP = Sprite("PussySprites\\Tracker\\GankHP.png")
local GankMANA = Sprite("PussySprites\\Tracker\\GankMANA.png")
local ultOFF = Sprite("PussySprites\\Tracker\\ultOFF.png")
local ultON = Sprite("PussySprites\\Tracker\\ultON.png")
local Shadow = Sprite("PussySprites\\Tracker\\Shadow.png")
local nrGUI = Sprite("PussySprites\\Tracker\\nrGUI.png")
local recallGUI = Sprite("PussySprites\\Tracker\\recallGUI.png")

local gankTOP = Sprite("PussySprites\\Tracker\\gankTOP.png")
local gankMID = Sprite("PussySprites\\Tracker\\gankMID.png")
local gankBOT = Sprite("PussySprites\\Tracker\\gankBOT.png")
local gankShadow = Sprite("PussySprites\\Tracker\\gankShadow.png")

local recallMini = Sprite("PussySprites\\Tracker\\recallMini.png",0.5)
local recallMiniC = Sprite("PussySprites\\Tracker\\recallMini.png",0.5)
local miniRed = Sprite("PussySprites\\Tracker\\miniRed.png",0.5)
local miniRedC = Sprite("PussySprites\\Tracker\\miniRed.png",0.5)

local bigRed = Sprite("PussySprites\\Tracker\\miniRed.png")

local champSprite = {}
local champSpriteSmall = {}
local champSpriteMini = {}
local champSpriteMiniC = {}

local midX = Game.Resolution().x/2
local midY = Game.Resolution().y/2

local wards = {}
local WardColors = {SightWard = Draw.Color(255,0,255,0), VisionWard = Draw.Color(0xFF,0xAA,0,0xAA), Trinket = Draw.Color(0xFF,0xAA,0xAA,0), Farsight = Draw.Color(0xFF,00,0xBF,0xFF)}

-------------------------

local minionEXP = {
 ["SRU_OrderMinionSuper"]	= 97,
 ["SRU_OrderMinionSiege"] 	= 93,
 ["SRU_OrderMinionMelee"] 	= 60.45,
 ["SRU_OrderMinionRanged"] 	= 29.76,
 --------------------------------------------
 ["SRU_ChaosMinionSuper"]	= 97,
 ["SRU_ChaosMinionSiege"] 	= 93,
 ["SRU_ChaosMinionMelee"] 	= 60.45,
 ["SRU_ChaosMinionRanged"] 	= 29.76,
}

local expT = {
 ["SRU_OrderMinionSiege"] 	= {[92] = 1, [60] = 2, [40] = 3, [30] = 4, [24] = 5} ,
 ["SRU_OrderMinionMelee"] 	= {[58] = 1, [38] = 2, [25] = 3, [19] = 4, [15] = 5} ,
 ["SRU_OrderMinionRanged"] 	= {[29] = 1, [19] = 2, [13] = 3, [9] = 4, [8] = 5} ,
}

local expMulti = {
 [1] = 1, [2] = 0.652, [3] = 0.4346, [4] = 0.326, [5] = 0.2608, [6] = 0.1337
}
 
local enemies = {}
local Summon = {}
local mfloor, lpairs = math.floor, pairs

local res = Game.Resolution()
local width = res.x

local on_rip_tick = 0
local before_rip_tick = 50000
local ripMinions = {}
local t = {}

local oldExp = {}
local newExp = {}
local eT = {}

local invChamp = {}
local iCanSeeYou = {}
local isRecalling = {}
local OnGainVision = {}

local aBasePos
local eBasePos

local mapID = Game.mapID;
local camps = {}
local TEAM_BLUE = 100;
local TEAM_RED = 200;

local function IntegerToMinSec(i)
	local m, s = math.floor(i/60), (i%60)
	return (m < 10 and 0 or "")..m..":"..(s < 10 and 0 or "")..s
end

local function DrawWard(type, ward)
	if not gankAlert.Warding[type] then
		return
	end
	if ward.pos2D.onScreen then
		if gankAlert.Warding[type].ScreenDisplay:Value() then
			Draw.Circle(ward.pos,70,2,WardColors[type]);
		end
		if gankAlert.Warding["Farsight"].VisionDisplay:Value() and ward.charName == "BlueTrinket" then
			Draw.Circle(ward.pos,500,2,WardColors[type]);
		end	
		if gankAlert.Warding["VisionWard"].VisionDisplay:Value() and ward.charName == "JammerDevice" then
			Draw.Circle(ward.pos,900,2,WardColors[type]);
		end	
		if gankAlert.Warding["Trinket"].VisionDisplay:Value() and ward.charName == "YellowTrinket" then
			Draw.Circle(ward.pos,900,2,WardColors[type]);
		end			

		if gankAlert.Warding[type].TimerDisplay and gankAlert.Warding[type].TimerDisplay:Value() then
			for i = 1, ward.buffCount do
				local buff = ward:GetBuff(i);
				if (buff.count > 0) and (buff.expireTime > buff.startTime) then 
					local wardLife = buff.expireTime - Game.Timer();
					Draw.Text(IntegerToMinSec(math.ceil(wardLife)),16,ward.pos2D.x,ward.pos2D.y-14,WardColors[type]);
					break;
				end
			end
		end
	end
end

local function InitSprites()
	local _URL = "PussySprites/summons/"
	local _SIZE = 0.35
	
	Summon["SummonerBarrier"] = Sprite(_URL.."Barrier.png", _SIZE)
	Summon["SummonerMana"] = Sprite(_URL.."Clarity.png", _SIZE)
	Summon["SummonerBoost"] = Sprite(_URL.."Barrier.png", _SIZE)
	Summon["SummonerExhaust"] = Sprite(_URL.."Exhaust.png", _SIZE)
	Summon["SummonerFlash"] = Sprite(_URL.."Flash.png", _SIZE)
	Summon["SummonerHaste"] = Sprite(_URL.."Ghost.png", _SIZE)
	Summon["SummonerHeal"] = Sprite(_URL.."Heal.png", _SIZE)
	Summon["SummonerDot"] = Sprite(_URL.."Ignite.png", _SIZE)
	Summon["SummonerSnowball"] = Sprite(_URL.."Mark.png", _SIZE)
	Summon["SummonerSmite"] = Sprite(_URL.."Smite.png", _SIZE)
	Summon["S5_SummonerSmitePlayerGanker"] = Sprite(_URL.."Chilling_Smite.png", _SIZE)
	Summon["S5_SummonerSmiteDuel"] = Sprite(_URL.."Challenging_Smite.png", _SIZE)
	Summon["SummonerTeleport"] = Sprite(_URL.."Teleport.png", _SIZE)

end
	


local mapPos = {
["BOT"] = {Vector(7832,49.4456,1252), Vector(10396,50.1820,1464), Vector(12650,51.5588,2466), Vector(13598,52.5385,4840), Vector(13580,52.3063,7024) },
["MID"] = {Vector(0,0,0), Vector(0,0,0), Vector(0,0,0), Vector(0,0,0), Vector(0,0,0) },
["TOP"] = {Vector(0,0,0), Vector(0,0,0), Vector(0,0,0), Vector(0,0,0), Vector(0,0,0) },
["BASE"] = {Vector(0,0,0), Vector(0,0,0) }
}

local add = 0
 
Callback.Add("Draw", function()
	
	for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)
		if hero and hero.team ~= myHero.team then
			if gankAlert.CD.Pos:Value() ~= 2 then 
				Draw_Hero(hero)
			else
				Draw_Hero2(hero) 
			end
		end
	end
end)

function OnLoad()


if myHero.team == 100 then
	aBasePos = Vector(415,182,415)
	eBasePos = Vector(14302,172,14387.8)
else
	aBasePos = Vector(14302,172,14387.8)
	eBasePos = Vector(415,182,415)
end

DelayAction(function()
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.isEnemy and eT[hero.networkID] == nil then	
			add = add + 1
			champSprite[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", 1.2)
			champSpriteSmall[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", 1)
			champSpriteMini[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", .5)
			champSpriteMiniC[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", .5)
			invChamp[hero.networkID] = {champ = hero, lastTick = GetTickCount(), lastWP = Vector(0,0,0), lastPos = hero.pos or eBasePos, where = "will be added.", status = hero.visible, n = add }
			iCanSeeYou[hero.networkID] = {tick = 0, champ = hero, number = add, draw = false}
			isRecalling[hero.networkID] = {status = false, tick = 0, proc = nil, spendTime = 0}
			OnGainVision[hero.networkID] = {status = not hero.visible, tick = 0}
			oldExp[hero.networkID] = 0
			newExp[hero.networkID] = 0
			table.insert(enemies, hero)
			eT[hero.networkID] = {champ = hero, fow = 0, saw = 0,}
		end
	end
end,30)

for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)
	if hero and hero.isEnemy then
		add = add + 1
		champSprite[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", 1.2)
		champSpriteSmall[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", 1)
		champSpriteMini[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", .5)
		champSpriteMiniC[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", .5)
		invChamp[hero.networkID] = {champ = hero, lastTick = GetTickCount(), lastWP = Vector(0,0,0), lastPos = hero.pos or eBasePos, where = "will be added.", status = hero.visible, n = add }
		iCanSeeYou[hero.networkID] = {tick = 0, champ = hero, number = add, draw = false}																	
		isRecalling[hero.networkID] = {status = false, tick = 0, proc = nil, spendTime = 0}
		OnGainVision[hero.networkID] = {status = not hero.visible, tick = 0}
		oldExp[hero.networkID] = 0
		newExp[hero.networkID] = 0
		table.insert(enemies, hero)
		eT[hero.networkID] = {champ = hero, fow = 0, saw = 0,}

	end
end

InitSprites()



function OnTick()

	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		--OnGainVision
		if invChamp[hero.networkID] ~= nil and invChamp[hero.networkID].status == false and hero.visible and not hero.dead then
			if myHero.pos:DistanceTo(hero.pos) <= gankAlert.alert.range:Value() + 100 and GetTickCount()-invChamp[hero.networkID].lastTick > 5000 then
				OnGainVision[hero.networkID].status = true
				OnGainVision[hero.networkID].tick = GetTickCount()
			end
			newExp[hero.networkID] = hero.levelData.exp
			oldExp[hero.networkID] = hero.levelData.exp
		end
		if hero and not hero.dead and hero.isEnemy and hero.visible then
			invChamp[hero.networkID].status = hero.visible
			isRecalling[hero.networkID].spendTime = 0
			newExp[hero.networkID] = hero.levelData.exp
			local hehTicker = GetTickCount()
			if (before_rip_tick + 10000) < hehTicker then
				oldExp[hero.networkID] = hero.levelData.exp
			before_rip_tick = hehTicker
			end
		end
		--OnLoseVision
		if invChamp[hero.networkID] ~= nil and invChamp[hero.networkID].status == true and not hero.visible and not hero.dead then
			invChamp[hero.networkID].lastTick = GetTickCount()
			invChamp[hero.networkID].lastWP = hero.posTo
			invChamp[hero.networkID].lastPos = hero.pos
			invChamp[hero.networkID].status = false
		end
	end
				
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		
		if minion.pos:DistanceTo(myHero.pos) < 2500 and minion.isAlly and not minion.dead then
			t[minion.networkID] = minion
		end
		
		local heheTicker = GetTickCount()
		if (on_rip_tick + 1000) < heheTicker then
			for i,v in pairs(t) do
				if v.dead then
					table.insert(ripMinions, v)
				end
			end
			on_rip_tick = heheTicker
			t = {}
		end
		
	end
	
-- MULTI EXP TRACK
	for i,hero in pairs(enemies) do
		if hero and not hero.dead and hero.pos:DistanceTo(myHero.pos) < 2500 and hero.isEnemy and hero.visible then
			local gainEXP = 0
			local gotEXP = newExp[hero.networkID] - oldExp[hero.networkID]
			for n,v in pairs(ripMinions) do
				if hero.pos:DistanceTo(v.pos) <= 1600 then
					if minionEXP[v.charName] ~= nil then
						gainEXP = gainEXP + minionEXP[v.charName]
					end
				end
			end
			if gainEXP > 0 then	
				for a,m in pairs(expMulti) do
					if math.floor(gotEXP) == math.floor(gainEXP*m) then
						eT[hero.networkID].fow = a - EnemiesAround(hero.pos,1600)
						eT[hero.networkID].saw = EnemiesAround(hero.pos,1600)
					end
				end
				oldExp[hero.networkID] = hero.levelData.exp
				DelayAction(function()
					ripMinions = {}
				end,0)
			end
		end
	end
	
	if gankAlert["PussyLvL".. myHero.charName].on:Value() and not levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts

		if actualLevel == 18 and levelPoints == 0 or actualLevel == 1 then return end

		if levelPoints > 0 then
			local mode = gankAlert["PussyLvL".. myHero.charName].start:Value()
			if mode == 1 then
				skillingOrder = {'Q','W','E','Q','Q','R','Q','W','Q','W','R','W','W','E','E','R','E','E'}
			elseif mode == 2 then
				skillingOrder = {'W','E','Q','W','W','R','W','E','W','E','R','E','E','Q','Q','R','Q','Q'}
			elseif mode == 3 then
				skillingOrder = {'E','Q','W','E','E','R','E','Q','E','Q','R','Q','Q','W','W','R','W','W'}
			elseif mode == 4 then
				skillingOrder = {'E','W','Q','E','E','R','E','W','E','W','R','W','W','Q','Q','R','Q','Q'}
			elseif mode == 5 then
				skillingOrder = {'W','Q','E','W','W','R','W','Q','W','Q','R','Q','Q','E','E','R','E','E'}
			elseif mode == 6 then
				skillingOrder = {'Q','E','W','Q','Q','R','Q','E','Q','E','R','E','E','W','W','R','W','W'}				
			end	

			local QL, WL, EL, RL = 0, 0, 0, myHero.charName == "Karma" and 1 or 0

			for i = 1, actualLevel do
				if skillingOrder[i] == "Q" then 		
					QL = QL + 1
				elseif skillingOrder[i] == "W" then		
					WL = WL + 1
				elseif skillingOrder[i] == "E" then 	
					EL = EL + 1
				elseif skillingOrder[i] == "R" then		
					RL = RL + 1
				end
			end

			local diffR = myHero:GetSpellData(_R).level - RL < 0
			local lowest = 99
			local spell
			local lowHK_Q = myHero:GetSpellData(_Q).level - QL
			local lowHK_W = myHero:GetSpellData(_W).level - WL
			local lowHK_E = myHero:GetSpellData(_E).level - EL

			if lowHK_Q < lowest then
				lowest = lowHK_Q
				spell = HK_Q
			end

			if lowHK_W < lowest then
				lowest = lowHK_W
				spell = HK_W
			end

			if lowHK_E < lowest then
				lowest = lowHK_E
				spell = HK_E
			end

			if diffR then
				spell = HK_R
			end

			if spell then
				levelUP = true

				DelayAction(function()
					Control.KeyDown(HK_LUS)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					Control.KeyUp(HK_LUS)

					DelayAction(function()
						levelUP = false
					end, .25)
				end, 0.7)
			end
		end
	end	

	if gankAlert.TrapMenu.Trap.TEnabled:Value() then
		for i,hero in pairs(enemies) do
			if hero and hero.isEnemy then 
		
				for i = Game.ObjectCount(), 1, -1 do
				local obj = Game.Object(i)
				--print(obj.name)
					if hero.charName == "Teemo" then
						if obj.charName == "TeemoMushroom" and obj.health ~= 0 and obj.team ~= myHero.team then            
							Draw.Circle(obj.pos, 75, 3, Draw.Color(255,255,0,0))
							Draw.Text("Mushroom", gankAlert.TrapMenu.Trap.FontSize:Value(), obj.pos2D.x, obj.pos2D.y, Draw.Color(255, 225, 255, 0))
							if obj.pos:DistanceTo(myHero.pos) < 1450 then
								Draw.Circle(obj.pos, 450, 3, Draw.Color(255,0,255,0))
							end
						end
					end	
					if hero.charName == "Shaco" then 
						if obj.charName == "ShacoBox" and obj.health ~= 0 and obj.team ~= myHero.team then     --obj.name == "Jack In The Box"       
							Draw.Circle(obj.pos, 75, 3, Draw.Color(255,255,0,0))
							Draw.Text("Shaco Box", gankAlert.TrapMenu.Trap.FontSize:Value(), obj.pos2D.x, obj.pos2D.y, Draw.Color(255, 225, 255, 0))
							if obj.pos:DistanceTo(myHero.pos) < 1290 then
								Draw.Circle(obj.pos, 290, 3, Draw.Color(255,0,255,0))
							end
						end						
					end
					if hero.charName == "Jhin" then 
						if obj.charName == "JhinTrap" and obj.health ~= 0 and obj.team ~= myHero.team then            
							Draw.Circle(obj.pos, 75, 3, Draw.Color(255,255,0,0))
							Draw.Text("Jhin Trap", gankAlert.TrapMenu.Trap.FontSize:Value(), obj.pos2D.x, obj.pos2D.y, Draw.Color(255, 225, 255, 0))
						end						
					end	
					if hero.charName == "Nidalee" then 
						if obj.charName == "NidaleeSpear" and obj.health ~= 0 and obj.team ~= myHero.team then            
							Draw.Circle(obj.pos, 75, 3, Draw.Color(255,255,0,0))
							Draw.Text("Nidalee Trap", gankAlert.TrapMenu.Trap.FontSize:Value(), obj.pos2D.x, obj.pos2D.y, Draw.Color(255, 225, 255, 0))
						end						
					end
				end
			end
		end
	end
	  
	if gankAlert.TrapMenu.Tower:Value() then	
		for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i)
			if turret.isEnemy and not turret.dead then
				if turret.pos:DistanceTo(myHero.pos) < 1750 then
					Draw.Circle(turret.pos, turret.boundingRadius + 750, 3, Draw.Color(gankAlert.TrapMenu.TowerTrans:Value(),255,0,0))
				end
			end		
		end		
	end

	
	
	local currentTicks = GetTickCount();
	for i = 1, Game.CampCount() do
	local camp = Game.Camp(i);
	if mapID == SUMMONERS_RIFT then
		if camp.isCampUp then
			if not camps[camp.chnd] then
				if camp.name == 'monsterCamp_1' then
					camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_BLUE, "Blue", camp.isCampUp, Draw.Color(255,0,180,255)}
				elseif camp.name == 'monsterCamp_2' then
					camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_BLUE, "Wolves", camp.isCampUp, Draw.Color(255,220,220,220)}
				elseif camp.name == 'monsterCamp_3' then
					camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_BLUE, "Raptors", camp.isCampUp, Draw.Color(255,50,255,50)}
				elseif camp.name == 'monsterCamp_4' then
					camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_BLUE, "Red", camp.isCampUp, Draw.Color(255,255,100,100)}
				elseif camp.name == 'monsterCamp_5' then
					camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_BLUE, "Krugs", camp.isCampUp, Draw.Color(255,160,160,160)}
				elseif camp.name == 'monsterCamp_6' then
					camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_BLUE, "Dragon", camp.isCampUp, Draw.Color(255,255,170,50)}
				elseif camp.name == 'monsterCamp_7' then
					camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_RED, "Blue", camp.isCampUp, Draw.Color(255,0,180,255)}
				elseif camp.name == 'monsterCamp_8' then
					camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_RED, "Wolves", camp.isCampUp, Draw.Color(255,220,220,220)}
				elseif camp.name == 'monsterCamp_9' then
					camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_RED, "Raptors", camp.isCampUp, Draw.Color(255,50,255,50)}
				elseif camp.name == 'monsterCamp_10' then
					camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_RED, "Red", camp.isCampUp, Draw.Color(255,255,100,100)}
				elseif camp.name == 'monsterCamp_11' then
					camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_RED, "Krugs", camp.isCampUp, Draw.Color(255,160,160,160)}
				elseif camp.name == 'monsterCamp_12' then
					camps[camp.chnd] = {currentTicks, 360000, camp, TEAM_RED, "Baron", camp.isCampUp, Draw.Color(255,180,50,250)}
				elseif camp.name == 'monsterCamp_13' then
					camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_BLUE, "Gromp", camp.isCampUp, Draw.Color(255,240,240,0)}
				elseif camp.name == 'monsterCamp_14' then
					camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_RED, "Gromp", camp.isCampUp, Draw.Color(255,240,240,0)}
				elseif camp.name == 'monsterCamp_15' then
					camps[camp.chnd] = {currentTicks, 150000, camp, TEAM_BLUE, "Scuttler", camp.isCampUp, Draw.Color(255,255,170,50)} 
				elseif camp.name == 'monsterCamp_16' then
					camps[camp.chnd] = {currentTicks, 150000, camp, TEAM_RED, "Scuttler", camp.isCampUp, Draw.Color(255,255,170,50)} 

				end
			else -- the camp has been allocated once
				camps[camp.chnd][1] = currentTicks;
				camps[camp.chnd][6] = camp.isCampUp;
				camps[camp.chnd][3] = camp;
			end
		else --else the camp is not LIVE (up)
			if camps[camp.chnd] then
				camps[camp.chnd][6] = camp.isCampUp;
				camps[camp.chnd][3] = camp;
			end
		end
	elseif mapID == TWISTED_TREELINE then
	if camp.isCampUp then
			if not camps[camp.chnd] then
				if camp.name == 'monsterCamp_1' then
					camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_BLUE, "Wraiths", camp.isCampUp, Draw.Color(255,255,100,100)}
				elseif camp.name == 'monsterCamp_2' then
					camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_BLUE, "Golems", camp.isCampUp, Draw.Color(255,0,180,255)}
				elseif camp.name == 'monsterCamp_3' then
					camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_BLUE, "Wolves", camp.isCampUp, Draw.Color(255,220,220,220)}
				elseif camp.name == 'monsterCamp_4' then
					camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_RED, "Wraiths", camp.isCampUp, Draw.Color(255,255,100,100)}
				elseif camp.name == 'monsterCamp_5' then
					camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_RED, "Golems", camp.isCampUp, Draw.Color(255,0,180,255)}
				elseif camp.name == 'monsterCamp_6' then
					camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_RED, "Wolves", camp.isCampUp, Draw.Color(255,220,220,220)}
				elseif camp.name == 'monsterCamp_7' then
					camps[camp.chnd] = {currentTicks, 90000, camp, TEAM_BLUE, "Health", camp.isCampUp, Draw.Color(255,50,255,50)}
				elseif camp.name == 'monsterCamp_8' then
					camps[camp.chnd] = {currentTicks, 360000, camp, TEAM_RED, "Vilemaw", camp.isCampUp, Draw.Color(255,180,50,250)}
				end
			else -- the camp has been allocated once
				camps[camp.chnd][1] = currentTicks;
				camps[camp.chnd][6] = camp.isCampUp;
				camps[camp.chnd][3] = camp;
			end
		else --else the camp is not LIVE (up)
			if camps[camp.chnd] then
				camps[camp.chnd][6] = camp.isCampUp;
				camps[camp.chnd][3] = camp;
			end
		end
	elseif mapID == HOWLING_ABYSS then
	if camp.isCampUp then
			if not camps[camp.chnd] then
				if camp.name == 'monsterCamp_1' then
					camps[camp.chnd] = {currentTicks, 60000, camp, TEAM_RED, "Health", camp.isCampUp, Draw.Color(255,50,255,50)}
				elseif camp.name == 'monsterCamp_2' then
					camps[camp.chnd] = {currentTicks, 60000, camp, TEAM_BLUE, "Health", camp.isCampUp, Draw.Color(255,50,255,50)}
				elseif camp.name == 'monsterCamp_3' then
					camps[camp.chnd] = {currentTicks, 60000, camp, TEAM_RED, "Health", camp.isCampUp, Draw.Color(255,50,255,50)}
				elseif camp.name == 'monsterCamp_4' then
					camps[camp.chnd] = {currentTicks, 60000, camp, TEAM_RED, "Health", camp.isCampUp, Draw.Color(255,50,255,50)}
				end
			else -- the camp has been allocated once
				camps[camp.chnd][1] = currentTicks;
				camps[camp.chnd][6] = camp.isCampUp;
				camps[camp.chnd][3] = camp;
			end
		else --else the camp is not LIVE (up)
			if camps[camp.chnd] then
				camps[camp.chnd][6] = camp.isCampUp;
				camps[camp.chnd][3] = camp;
			end
		end
	elseif mapID == CRYSTAL_SCAR then --definetly not dominion and others
	if camp.isCampUp then
			if not camps[camp.chnd] then
				camps[camp.chnd] = {currentTicks, 31000, camp, TEAM_RED, "Health", camp.isCampUp, Draw.Color(255,50,255,50)}
			else -- the camp has been allocated once
				camps[camp.chnd][1] = currentTicks;
				camps[camp.chnd][6] = camp.isCampUp;
				camps[camp.chnd][3] = camp;
			end
		else --else the camp is not LIVE (up)
			if camps[camp.chnd] then
				camps[camp.chnd][6] = camp.isCampUp;
				camps[camp.chnd][3] = camp;
			end
		end
	end

	end	
end



function OnDraw()
-- CIRCLE
if (gankAlert.circle.screen:Value() or gankAlert.circle.minimap:Value()) then
	for i,v in pairs(invChamp) do
		if v.status == false and not v.champ.dead then
			local recallTime = 0
			if isRecalling[v.champ.networkID].status == true then
				recallTime = GetTickCount()-isRecalling[v.champ.networkID].tick
			end
			local timer = (GetTickCount() - v.lastTick - isRecalling[v.champ.networkID].spendTime - recallTime)/1000
			local vec = v.lastPos + (Vector(v.lastPos,myHero.pos)/v.lastPos:DistanceTo(myHero.pos))*v.champ.ms*timer
			if v.champ.ms*timer < 10000 and v.champ.ms*timer > 0 and vec:DistanceTo(v.lastPos) < myHero.pos:DistanceTo(v.lastPos) + 2000 then
				if gankAlert.circle.screen:Value() then
					local d2 = v.lastPos:ToScreen()
					if d2.onScreen then
						bigRed:Draw(d2.x - 25, d2.y - 25)
						champSpriteSmall[v.champ.charName]:Draw(d2.x - 25, d2.y - 25)
					end
					if gankAlert.circle.drawWP:Value() then
						if v.lastPos ~= eBasePos and v.champ.pos:DistanceTo(eBasePos) > 250 then
							local d2_to = v.champ.posTo:ToScreen()
							if d2_to.onScreen or d2.onScreen then
								Draw.Line(d2,d2_to,2 ,Draw.Color(255,255,28,28))
							end
							if v.lastPos ~= eBasePos and d2_to.onScreen then
								champSpriteMiniC[v.champ.charName]:Draw(d2_to.x - 12.5, d2_to.y - 12.5)
								miniRedC:Draw(d2_to.x - 12.5, d2_to.y - 12.5)
							end
						end
					end
					if gankAlert.circle.draw:Value() then
						Draw.Circle(v.lastPos,v.champ.ms*timer,Draw.Color(180,225,0,30))
						Draw.Rect(vec:To2D().x - 6,vec:To2D().y-3,8*string.len(v.champ.charName),20,Draw.Color(200,25,25,25))
						Draw.Text(v.champ.charName, 14,vec:To2D())
					end
				end
			end
			if v.champ.ms*timer < 10000 and v.champ.ms*timer > 0 then
				if gankAlert.circle.minimap:Value() then
					champSpriteMini[v.champ.charName]:SetColor(Draw.Color(240,158,158,158))
					if v.lastPos ~= eBasePos then
						champSpriteMini[v.champ.charName]:Draw(v.champ.posMM.x - 12.5,v.champ.posMM.y - 12)
						miniRed:Draw(v.champ.posMM.x - 12,v.champ.posMM.y - 12)
						if isRecalling[v.champ.networkID].status == true then
							-- Draw.CircleMinimap(v.lastPos,900, 2,Draw.Color(255,225,0,10))
							local r = 25/isRecalling[v.champ.networkID].proc.totalTime * (isRecalling[v.champ.networkID].proc.totalTime - (GetTickCount()-isRecalling[v.champ.networkID].tick))
							local recallCut = {x = 0, y = 25, w = 25, h = r }
							recallMini:Draw(recallCut,v.champ.posMM.x - 12,v.champ.posMM.y - 12 + 25)
						end
					end
					if gankAlert.circle.draw:Value() and v.champ.ms*timer > 720 then
						Draw.CircleMinimap(v.lastPos,v.champ.ms*timer, 1,Draw.Color(180,225,0,30))
					end
				end
			end
		end
	end
end

-- RecallPos (add max disntace depends on :goTo)
if gankAlert.drawRecall:Value() then
	for i,v in pairs(invChamp) do
		if v.status == false and not v.champ.dead then
			if isRecalling[v.champ.networkID].status == true then
				local recall = isRecalling[v.champ.networkID]
				local spend_to_recall = recall.tick - v.lastTick - 500
				if spend_to_recall < 2000 then
					local recallPos = v.lastPos + (Vector(v.lastPos,v.champ.posTo)/v.lastPos:DistanceTo(v.champ.posTo))*(v.champ.ms*spend_to_recall/1000)
					if recallPos:DistanceTo(v.lastPos) < spend_to_recall*v.champ.ms then
						local d2 = recallPos:ToScreen()
						local b4_d2 = v.lastPos:ToScreen()
						if d2.onScreen or b4_d2.onScreen then
							Draw.Line(d2,b4_d2,4 ,Draw.Color(255,0,128,255))
							champSpriteMini[v.champ.charName]:SetColor(Draw.Color(255,255,255,255))
							champSpriteMini[v.champ.charName]:Draw(d2.x - 12.5,d2.y - 12.5)
							local r = 25/isRecalling[v.champ.networkID].proc.totalTime * (isRecalling[v.champ.networkID].proc.totalTime - (GetTickCount()-isRecalling[v.champ.networkID].tick))
							local recallCut = {x = 0, y = 25, w = 25, h = r }
							recallMiniC:Draw(recallCut,d2.x - 12.5,d2.y - 12.5 + 25)
						end
					end
				end
			end
		end
	end
end

if gankAlert.Warding.Enabled:Value() then
	local currentTick = GetTickCount();
	for i = 1, Game.WardCount() do
		local ward = Game.Ward(i);
		if ward.valid and ward.isEnemy then 
			DrawWard(ward.maxHealth == 4 and "VisionWard" or ward.maxHealth == 3 and (ward.maxMana == 150 and "SightWard" or "Trinket") or ward.maxHealth == 1 and "Farsight" or "WTFISTHISWARD", ward)
			if not wards[ward.networkID] then 
				if ward.maxHealth == 4 and gankAlert.Warding.VisionWard.VisionDisplay:Value() then
					wards[ward.networkID] = { ward.pos.x, ward.pos.y, ward.pos.z, currentTick, Draw.Color(0x70,0xAA,0,0xAA), 900 }
				
					end
				if ward.maxHealth == 3 then						
					if  gankAlert.Warding.Trinket.VisionDisplay:Value() then 
						wards[ward.networkID] = { ward.pos.x, ward.pos.y, ward.pos.z, currentTick, Draw.Color(0x70,0xAA,0xAA,0), 900 }
						
					end
				end
				if ward.maxHealth == 1 and gankAlert.Warding.Farsight.VisionDisplay:Value() then
					wards[ward.networkID] = { ward.pos.x, ward.pos.y, ward.pos.z, currentTick, Draw.Color(0x70,0,0xBF,0xFF), 500 }

					end
				else 
				if ward.maxHealth == 4 and gankAlert.Warding.VisionWard.VisionDisplay:Value() then
					wards[ward.networkID][4] = currentTick;
					end
				if ward.maxHealth == 3 then
					if  gankAlert.Warding.Trinket.VisionDisplay:Value() then 
						wards[ward.networkID][4] = currentTick;
					end
				end
				if ward.maxHealth == 1 and gankAlert.Warding.Farsight.VisionDisplay:Value() then
					wards[ward.networkID][4] = currentTick;
				end
			end
		end
	end
end

-- GUI
if gankAlert.gui.drawGUI:Value() then

	for i,v in pairs(invChamp) do
	
		--if v.ApDmg > v.AdDmg then
		if gankAlert.gui.side:Value() ~= 1 then
			--HPGank:Draw(gankAlert.gui.x:Value() + 72,gankAlert.gui.y:Value() + 75*(v.n-1) + 0)
			--Draw.Text( math.floor(v.champ.health).." /" , 10, gankAlert.gui.x:Value() + 130,gankAlert.gui.y:Value() + 75*(v.n-1) + 2)
			--Draw.Text( math.floor(v.champ.maxHealth), 10, gankAlert.gui.x:Value() + 160,gankAlert.gui.y:Value() + 75*(v.n-1) + 2)	

			--Draw.Text( math.floor(v.champ.mana).." /" , 10, gankAlert.gui.x:Value() + 130,gankAlert.gui.y:Value() + 75*(v.n-1) + 14)
			--Draw.Text( math.floor(v.champ.maxMana), 10, gankAlert.gui.x:Value() + 160,gankAlert.gui.y:Value() + 75*(v.n-1) + 14)			
		
			APGank:Draw(gankAlert.gui.x:Value() + 72,gankAlert.gui.y:Value() + 75*(v.n-1) + 31)
			Draw.Text( math.floor(v.champ.ap) , 12, gankAlert.gui.x:Value() + 100,gankAlert.gui.y:Value() + 75*(v.n-1) + 31)
			MRGank:Draw(gankAlert.gui.x:Value() + 137,gankAlert.gui.y:Value() + 75*(v.n-1) + 31)
			Draw.Text( math.floor(v.champ.magicResist) , 12, gankAlert.gui.x:Value() + 170,gankAlert.gui.y:Value() + 75*(v.n-1) + 31)
			
			ADGank:Draw(gankAlert.gui.x:Value() + 72,gankAlert.gui.y:Value() + 75*(v.n-1) + 46)
			Draw.Text( math.floor(v.champ.totalDamage) , 12, gankAlert.gui.x:Value() + 100,gankAlert.gui.y:Value() + 75*(v.n-1) + 46)
			DEFGank:Draw(gankAlert.gui.x:Value() + 137,gankAlert.gui.y:Value() + 75*(v.n-1) + 46)
			Draw.Text( math.floor(v.champ.armor) , 12, gankAlert.gui.x:Value() + 170,gankAlert.gui.y:Value() + 75*(v.n-1) + 46)			
		else 
			APGank:Draw(gankAlert.gui.x:Value() - 125,gankAlert.gui.y:Value() + 75*(v.n-1) + 31)
			Draw.Text( math.floor(v.champ.ap) , 12, gankAlert.gui.x:Value() - 97,gankAlert.gui.y:Value() + 75*(v.n-1) + 31)
			MRGank:Draw(gankAlert.gui.x:Value() - 60,gankAlert.gui.y:Value() + 75*(v.n-1) + 31)
			Draw.Text( math.floor(v.champ.magicResist) , 12, gankAlert.gui.x:Value() - 27,gankAlert.gui.y:Value() + 75*(v.n-1) + 31)
			
			ADGank:Draw(gankAlert.gui.x:Value() - 125,gankAlert.gui.y:Value() + 75*(v.n-1) + 46)
			Draw.Text( math.floor(v.champ.totalDamage) , 12, gankAlert.gui.x:Value() - 97,gankAlert.gui.y:Value() + 75*(v.n-1) + 46)
			DEFGank:Draw(gankAlert.gui.x:Value() - 60,gankAlert.gui.y:Value() + 75*(v.n-1) + 46)
			Draw.Text( math.floor(v.champ.armor) , 12, gankAlert.gui.x:Value() - 27,gankAlert.gui.y:Value() + 75*(v.n-1) + 46)
		end	
		local d = v.champ.dead
		champSprite[v.champ.charName]:Draw(gankAlert.gui.x:Value() + 12,gankAlert.gui.y:Value() + 75*(v.n-1) + 6)
		if v.status == false and not d then
			local timer = math.floor((GetTickCount() - v.lastTick)/1000)
			Shadow:Draw(gankAlert.gui.x:Value() + 15,gankAlert.gui.y:Value() + 75*(v.n-1) + 15)
			if timer < 350 then
				Draw.Text( timer , 27, gankAlert.gui.x:Value() + 42 - 6.34*string.len(timer),gankAlert.gui.y:Value() + 21 + 75*(v.n-1), Draw.Color(200,200,0,30))
			else
				Draw.Text( "AFK" , 25, gankAlert.gui.x:Value() + 43 - 6.34*3,gankAlert.gui.y:Value() + 21 + 75*(v.n-1), Draw.Color(200,225,0,30))
			end
			local eTimer = math.floor(v.lastPos:DistanceTo(myHero.pos)/v.champ.ms) - timer
			if eTimer > 0 then
				Draw.Rect(gankAlert.gui.x:Value() + 30,gankAlert.gui.y:Value() + 67 + 75*(v.n-1), 22, 14, Draw.Color(180,1,1,1))
				Draw.Text( eTimer , 12, gankAlert.gui.x:Value() + 39 - 3*(string.len(eTimer)-1),gankAlert.gui.y:Value() + 67 + 75*(v.n-1), Draw.Color(200,225,0,30))
			end
		elseif d then
			Shadow:Draw(gankAlert.gui.x:Value() + 15,gankAlert.gui.y:Value() + 75*(v.n-1) + 15)
		end
		
		
			
		GankGUI:Draw(gankAlert.gui.x:Value(),gankAlert.gui.y:Value() + 75*(v.n-1))
		if d then
			Draw.Text( "DEAD" , 10, gankAlert.gui.x:Value() + 29 ,gankAlert.gui.y:Value() + 55 + 75*(v.n-1), Draw.Color(200,255,255,255))
		elseif (v.lastPos == eBasePos or v.lastPos:DistanceTo(eBasePos) < 250) and v.status == false then
			Draw.Text( "BASE" , 10, gankAlert.gui.x:Value() + 30 ,gankAlert.gui.y:Value() + 55 + 75*(v.n-1), Draw.Color(200,255,255,255))
		elseif v.status == false then
			Draw.Text( "MISS" , 10, gankAlert.gui.x:Value() + 30 ,gankAlert.gui.y:Value() + 55 + 75*(v.n-1), Draw.Color(200,255,255,255))
		end
		---------------------------------------------	
		if not d then
			local Level = v.champ.levelData.lvl	
			if Level >= 10 then
				Draw.Text( Level , 12, gankAlert.gui.x:Value() + 36,gankAlert.gui.y:Value() + 75*(v.n-1) + 7)
			else
				Draw.Text( Level , 12, gankAlert.gui.x:Value() + 39,gankAlert.gui.y:Value() + 75*(v.n-1) + 7)
			end
			
			local CutHP = {x = 0, y = 47, w = 17, h = 47 - 47*(v.champ.health/v.champ.maxHealth)}
			GankHP:Draw(CutHP, gankAlert.gui.x:Value()+ 10,gankAlert.gui.y:Value() + 11 + 47 + 75*(v.n-1))
			
			local manaMulti = v.champ.mana/v.champ.maxMana
			if v.champ.maxMana == 0 then
				manaMulti = 0
			end
			local CutMANA = {x = 0, y = 47, w = 17, h = 47 - 47*(manaMulti)}
			GankMANA:Draw(CutMANA, gankAlert.gui.x:Value()+ 55,gankAlert.gui.y:Value() + 11 + 47 + 75*(v.n-1))
				
			nrGUI:Draw(gankAlert.gui.x:Value()+ 16,gankAlert.gui.y:Value() - 32 + 47 + 75*(v.n-1))
			if isRecalling[v.champ.networkID].status == true then
				local r = 38/isRecalling[v.champ.networkID].proc.totalTime * (isRecalling[v.champ.networkID].proc.totalTime - (GetTickCount()-isRecalling[v.champ.networkID].tick))
				local recallCut = {x = 0, y = 38, w = 50, h = r }		
				recallGUI:Draw(recallCut, gankAlert.gui.x:Value()+ 16,gankAlert.gui.y:Value() - 32 + 38 + 47 + 75*(v.n-1))
			end
		end
	end
end

-- GANK ALERT
if gankAlert.alert.drawGank:Value() and not myHero.dead then 
	local drawIT = false
	local nDraws = -1
	for i,v in pairs(invChamp) do
	
		if GetTickCount() - OnGainVision[v.champ.networkID].tick > 4000 and OnGainVision[v.champ.networkID].status == true then
			OnGainVision[v.champ.networkID].status = false
		end
		-- if OnGainVision[v.champ.networkID].status == true and GetTickCount() - OnGainVision[v.champ.networkID].tick <= 4000 and GetTickCount()-v.lastTick > 5000 and not v.champ.dead then
		if OnGainVision[v.champ.networkID].status == true and not v.champ.dead then
			if v.champ.pos:DistanceTo(myHero.pos) < gankAlert.alert.range:Value() then
				iCanSeeYou[v.champ.networkID].draw = true
				if GetTickCount() - OnGainVision[v.champ.networkID].tick > 3500 then
					OnGainVision[v.champ.networkID].status = false
					iCanSeeYou[v.champ.networkID].draw = false
				end
				drawIT = true
				nDraws = nDraws + 1
				iCanSeeYou[v.champ.networkID].number = nDraws
			end
		end
	end
	
	if drawIT == true then
		gankMID:Draw(midX - 152, midY/3)
		for i,v in pairs(iCanSeeYou) do
			if v.draw == true then
				gankShadow:Draw(midX - 25 - (50*nDraws/2) + 50*v.number ,midY/3 +1)
				champSpriteSmall[v.champ.charName]:Draw(midX - 25 - (50*nDraws/2) + 50*v.number ,midY/3 +1) -- need some work!!
			end
		end
		gankTOP:Draw(midX - 152, midY/3 - 14)
		gankBOT:Draw(midX - 152, midY/3 + 45)
	end
end

-- FOW
if gankAlert.alert.drawGankFOW:Value() then
	for i,v in pairs(eT) do
		if v.fow > 0 and v.champ.pos2D.onScreen and v.champ.pos:DistanceTo(myHero.pos) < 2500 and v.fow >= EnemiesAround(myHero.pos,2500) and v.champ.visible then
			Draw.Rect( v.champ.pos2D.x + 30,v.champ.pos2D.y+4, 22, 14, Draw.Color(180,1,1,1))
			Draw.Text("+"..v.fow, 10 , v.champ.pos2D.x + 36,v.champ.pos2D.y+6, Draw.Color(250,225,0,30))
			FOWGank:Draw(v.champ.pos2D.x - 36,v.champ.pos2D.y)
			for n,e in pairs(EnemiesInvisible(v.champ.pos, 1600)) do
				Draw.Text(e.charName, 10 , v.champ.pos2D.x - 30,v.champ.pos2D.y + 20*n, Draw.Color(250,225,0,30))
			end
		end
		if v.fow < EnemiesAround(myHero.pos,2000) and v.champ.visible and v.fow > 0 then
			-- print("reset FOW")
			v.fow = 0
		end
	end
end



if gankAlert.JGLMenu.Enabled:Value() then 
local currentTicks = GetTickCount();
	for num, camp in pairs(camps) do
		if camp[6] == true then

			else
			local timepassed = math.min(currentTicks - camp[1],camp[2])
			local timeleft = math.ceil((camp[2] - timepassed) / 1000);
			if gankAlert.JGLMenu.OnScreen.Enabled:Value() then
				Draw.Text(IntegerToMinSec(timeleft),gankAlert.JGLMenu.OnScreen.FontSize:Value(),camp[3].pos2D.x,camp[3].pos2D.y,camp[7]);
				end
			if gankAlert.JGLMenu.OnMinimap.Enabled:Value() then
				Draw.Text(IntegerToMinSec(timeleft),gankAlert.JGLMenu.OnMinimap.FontSize:Value(),camp[3].posMM.x-8,camp[3].posMM.y-8,camp[7]);
				end
			end
		end
	end
end	



function OnProcessRecall(unit,recall)
if isRecalling[unit.networkID] == nil then return end
	if recall.isFinish == false and recall.isStart == true and unit.type == "AIHeroClient" and isRecalling[unit.networkID] ~= nil then
		isRecalling[unit.networkID].status = true
		isRecalling[unit.networkID].tick = GetTickCount()
		isRecalling[unit.networkID].proc = recall
	elseif recall.isFinish == true and recall.isStart == false and unit.type == "AIHeroClient" and isRecalling[unit.networkID] ~= nil then
		isRecalling[unit.networkID].status = false
		isRecalling[unit.networkID].proc = recall
		isRecalling[unit.networkID].spendTime = 0
	elseif recall.isFinish == false and recall.isStart == false and unit.type == "AIHeroClient" and isRecalling[unit.networkID] ~= nil and isRecalling[unit.networkID].status == true then
		isRecalling[unit.networkID].status = false
		isRecalling[unit.networkID].proc = recall
		if not unit.visible then
			isRecalling[unit.networkID].spendTime = isRecalling[unit.networkID].spendTime + recall.passedTime
		end
	else
		if isRecalling[unit.networkID] ~= nil and isRecalling[unit.networkID].status == false then
			isRecalling[unit.networkID].status = true
			isRecalling[unit.networkID].tick = GetTickCount()
			isRecalling[unit.networkID].proc = recall
		end
	end
	if recall.isFinish == true and recall.isStart == false and unit.type == "AIHeroClient" and invChamp[unit.networkID] ~= nil then
		invChamp[unit.networkID].lastPos = eBasePos
		invChamp[unit.networkID].lastTick = GetTickCount()
	end
end
end

function Draw_Hero(hero)
	for i,v in pairs(invChamp) do
		if gankAlert.gui.drawGUI:Value() then
			local x = width - 101
			local y = 70
	
			-- Offsets Y --
			local offsetY = gankAlert.gui.y:Value() + 75*(v.n-1) -10
			local offsetT = offsetY+1
	
			-- Offsets X --
			if gankAlert.gui.side:Value() ~= 1 then
				local offsetQ = gankAlert.gui.x:Value() + 12

			
				local offsetW = offsetQ + 25
				local offsetE = offsetW + 25
				local offsetR = offsetE + 25
	
				local offsetS = offsetR + 27
				local offsetF = offsetS+ 25
	
				local offsetText = 12
	
				local wight = 24
				local hight = 17
	
				local barPos = {x = 60, y = 20}
				local t_wight = 0
	
				--[[ Spells ]]
				local spellQ = v.champ:GetSpellData(_Q).currentCd
				local spellW = v.champ:GetSpellData(_W).currentCd
				local spellE = v.champ:GetSpellData(_E).currentCd
				local spellR = v.champ:GetSpellData(_R).currentCd
		
				if gankAlert.CD.enemyspell:Value() and v.champ.visible and v.champ.dead == false then 

					
					Draw.Rect(barPos.x+offsetQ-2, barPos.y+offsetY-2, 125, 22, Draw.Color(200,0,0,0)) -- BackgroundColor
		
					if v.champ:GetSpellData(_Q).level ~= 0 then
						t_wight =Draw.FontRect(mfloor(spellQ),14).x
						if spellQ ~= 0 then
							Draw.Rect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
							Draw.Text(mfloor(spellQ), 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
						else
							Draw.Rect(barPos.x+offsetQ,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
							Draw.Text("Q", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2),barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
						end
					else
						t_wight =Draw.FontRect("~",14).x
						Draw.Rect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
						Draw.Text("~", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
					end	
		
					if v.champ:GetSpellData(_W).level ~= 0 then
						t_wight =Draw.FontRect(mfloor(spellW),14).x
						if spellW ~= 0 then
							Draw.Rect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
							Draw.Text(mfloor(spellW), 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
						else
							Draw.Rect(barPos.x+offsetW,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
							Draw.Text("W", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
						end
					else
						t_wight =Draw.FontRect("~",14).x
						Draw.Rect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
						Draw.Text("~", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
					end
		
					if v.champ:GetSpellData(_E).level ~= 0 then
						t_wight =Draw.FontRect(mfloor(spellE),14).x
						if spellE ~= 0 then
							Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
							Draw.Text(mfloor(spellE), 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
						else
							Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
							Draw.Text("E", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
						end
					else
						t_wight =Draw.FontRect("~",14).x
						Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
						Draw.Text("~", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
					end	
		
					if v.champ:GetSpellData(_R).level ~= 0 then
						t_wight =Draw.FontRect(mfloor(spellR),14).x
						if spellR ~= 0 then
							Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
							Draw.Text(mfloor(spellR), 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
						else
							Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
							Draw.Text("R", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
						end
					else
						t_wight =Draw.FontRect("~",14).x
						Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
						Draw.Text("~", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
					end
				end
					-- Summons --
					
				if gankAlert.CD.enemysumm:Value() and v.champ.visible and v.champ.dead == false then	
					local spellOneCd = v.champ:GetSpellData(SUMMONER_1).currentCd
					if spellOneCd ~= 0 then
						Summon[v.champ:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
						Draw.Rect(barPos.x+offsetS-3,  barPos.y+offsetY-3, wight+3,hight+6, Draw.Color(150,0,0,0)) -- negro
						t_wight =Draw.FontRect(mfloor(spellOneCd),14).x
						Draw.Text(mfloor(spellOneCd), 14, (barPos.x+offsetS+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
					else
						Summon[v.champ:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
					end
			
					local spellTwoCd = v.champ:GetSpellData(SUMMONER_2).currentCd
					if spellTwoCd ~= 0 then
						Summon[v.champ:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
						Draw.Rect(barPos.x+offsetF-3,  barPos.y+offsetY-3, wight+3,hight+6, Draw.Color(150,0,0,0)) -- negro
						t_wight =Draw.FontRect(mfloor(spellTwoCd),14).x
						Draw.Text(mfloor(spellTwoCd), 14, (barPos.x+offsetF+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
					else
						Summon[v.champ:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
					end						
				end
				
			else
				local offsetQ = gankAlert.gui.x:Value() - 205
			
				local offsetW = offsetQ + 25
				local offsetE = offsetW + 25
				local offsetR = offsetE + 25
	
				local offsetS = offsetR + 27
				local offsetF = offsetS+ 25
	
				local offsetText = 12
	
				local wight = 24
				local hight = 17
	
				local barPos = {x = 60, y = 20}
				local t_wight = 0
	
				--[[ Spells ]]
				local spellQ = v.champ:GetSpellData(_Q).currentCd
				local spellW = v.champ:GetSpellData(_W).currentCd
				local spellE = v.champ:GetSpellData(_E).currentCd
				local spellR = v.champ:GetSpellData(_R).currentCd
		
				if gankAlert.CD.enemyspell:Value() and v.champ.visible and v.champ.dead == false then 
				 
		
					Draw.Rect(barPos.x+offsetQ-2, barPos.y+offsetY-2, 125, 22, Draw.Color(200,0,0,0)) -- BackgroundColor
		
					if v.champ:GetSpellData(_Q).level ~= 0 then
						t_wight =Draw.FontRect(mfloor(spellQ),14).x
						if spellQ ~= 0 then
							Draw.Rect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
							Draw.Text(mfloor(spellQ), 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
						else
							Draw.Rect(barPos.x+offsetQ,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
							Draw.Text("Q", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2),barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
						end
					else
						t_wight =Draw.FontRect("~",14).x
						Draw.Rect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
						Draw.Text("~", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
					end	
		
					if v.champ:GetSpellData(_W).level ~= 0 then
						t_wight =Draw.FontRect(mfloor(spellW),14).x
						if spellW ~= 0 then
							Draw.Rect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
							Draw.Text(mfloor(spellW), 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
						else
							Draw.Rect(barPos.x+offsetW,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
							Draw.Text("W", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
						end
					else
						t_wight =Draw.FontRect("~",14).x
						Draw.Rect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
						Draw.Text("~", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
					end
		
					if v.champ:GetSpellData(_E).level ~= 0 then
						t_wight =Draw.FontRect(mfloor(spellE),14).x
						if spellE ~= 0 then
							Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
							Draw.Text(mfloor(spellE), 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
						else
							Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
							Draw.Text("E", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
						end
					else
						t_wight =Draw.FontRect("~",14).x
						Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
						Draw.Text("~", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
					end	
		
					if v.champ:GetSpellData(_R).level ~= 0 then
						t_wight =Draw.FontRect(mfloor(spellR),14).x
						if spellR ~= 0 then
							Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
							Draw.Text(mfloor(spellR), 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
						else
							Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
							Draw.Text("R", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
						end
					else
						t_wight =Draw.FontRect("~",14).x
						Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
						Draw.Text("~", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
					end
				end
					-- Summons --
					
				if gankAlert.CD.enemysumm:Value() and v.champ.visible and v.champ.dead == false then					
					local spellOneCd = v.champ:GetSpellData(SUMMONER_1).currentCd
					if spellOneCd ~= 0 then
						Summon[v.champ:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
						Draw.Rect(barPos.x+offsetS-3,  barPos.y+offsetY-3, wight+3,hight+6, Draw.Color(150,0,0,0)) -- negro
						t_wight =Draw.FontRect(mfloor(spellOneCd),14).x
						Draw.Text(mfloor(spellOneCd), 14, (barPos.x+offsetS+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
					else
						Summon[v.champ:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
					end
						
					local spellTwoCd = v.champ:GetSpellData(SUMMONER_2).currentCd
					if spellTwoCd ~= 0 then
						Summon[v.champ:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
						Draw.Rect(barPos.x+offsetF-3,  barPos.y+offsetY-3, wight+3,hight+6, Draw.Color(150,0,0,0)) -- negro
						t_wight =Draw.FontRect(mfloor(spellTwoCd),14).x
						Draw.Text(mfloor(spellTwoCd), 14, (barPos.x+offsetF+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
					else
						Summon[v.champ:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
					end			
				end	 				
			end
		end
	end	
end

function Draw_Hero2(hero)
	local x = width - 101
	local y = 70
	
	-- Offsets Y --
	local offsetY = gankAlert.CD.y:Value()
	local offsetT = offsetY+1
	
	-- Offsets X --
	local offsetQ = gankAlert.CD.x:Value()
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
		
		Draw.Rect(barPos.x+offsetQ-2, barPos.y+offsetY-2, 125, 22, Draw.Color(200,0,0,0)) -- BackgroundColor
		
		if hero:GetSpellData(_Q).level ~= 0 then
			t_wight =Draw.FontRect(mfloor(spellQ),14).x
			if spellQ ~= 0 then
				Draw.Rect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
				Draw.Text(mfloor(spellQ), 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
				else
				Draw.Rect(barPos.x+offsetQ,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) -- Verde
				Draw.Text("Q", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2),barPos.y+offsetT, Draw.Color(200,255,255,255)) -- CDs
			end
		else
			t_wight =Draw.FontRect("~",14).x
			Draw.Rect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) -- rojo
			Draw.Text("~", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
		end	
		
		if hero:GetSpellData(_W).level ~= 0 then
			t_wight =Draw.FontRect(mfloor(spellW),14).x
			if spellW ~= 0 then
				Draw.Rect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) 
				Draw.Text(mfloor(spellW), 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
				else
				Draw.Rect(barPos.x+offsetW,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) 
				Draw.Text("W", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) 
			end
		else
			t_wight =Draw.FontRect("~",14).x
			Draw.Rect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) 
			Draw.Text("~", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
		end
		
		if hero:GetSpellData(_E).level ~= 0 then
			t_wight =Draw.FontRect(mfloor(spellE),14).x
			if spellE ~= 0 then
				Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) 
				Draw.Text(mfloor(spellE), 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
				else
				Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) 
				Draw.Text("E", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255)) 
			end
		else
			t_wight =Draw.FontRect("~",14).x
			Draw.Rect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) 
			Draw.Text("~", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
		end	
		
		if hero:GetSpellData(_R).level ~= 0 then
			t_wight =Draw.FontRect(mfloor(spellR),14).x
			if spellR ~= 0 then
				Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0))
				Draw.Text(mfloor(spellR), 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
				else
				Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,0, 153, 35)) 
				Draw.Text("R", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
			end
		else
			t_wight =Draw.FontRect("~",14).x
			Draw.Rect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, Draw.Color(200,190,0,0)) 
			Draw.Text("~", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
		end
		
		 -- Summons --
			local spellOneCd = hero:GetSpellData(SUMMONER_1).currentCd
			if spellOneCd ~= 0 then
				Summon[hero:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
				Draw.Rect(barPos.x+offsetS-3,  barPos.y+offsetY-3, wight+3,hight+6, Draw.Color(150,0,0,0))
				t_wight =Draw.FontRect(mfloor(spellOneCd),14).x
				Draw.Text(mfloor(spellOneCd), 14, (barPos.x+offsetS+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
				else
				Summon[hero:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
			end
			
			local spellTwoCd = hero:GetSpellData(SUMMONER_2).currentCd
			if spellTwoCd ~= 0 then
				Summon[hero:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
				Draw.Rect(barPos.x+offsetF-3,  barPos.y+offsetY-3, wight+3,hight+6, Draw.Color(150,0,0,0)) 
				t_wight =Draw.FontRect(mfloor(spellTwoCd),14).x
				Draw.Text(mfloor(spellTwoCd), 14, (barPos.x+offsetF+offsetText)-(t_wight/2), barPos.y+offsetT, Draw.Color(200,255,255,255))
				else
				Summon[hero:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
			end
			
		end	
	end
		

end

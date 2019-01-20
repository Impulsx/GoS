if myHero.charName ~= "Kalista" then return end

function OnLoad()
	PrintChat("WomboComboMontage by RMAN and Pussykate")
	DelayAction(delayload,260)
end
	

 
--Locals
local CastSpell     = Control.CastSpell
local CanUseSpell   = Game.CanUseSpell
local Hero          = Game.Hero
local HeroCount     = Game.HeroCount
 
-- Spell Data
local rRange    = 1100
local swornAlly = nil



 -- Menu
local Menu = MenuElement({type = MENU, id = "WomboCombo by RMAN and Pussykate", name = "KalistaWomboCombo"})
Menu:MenuElement({id = "Blitz", name = "[BlitzCrank]UseR on Grab", value = true})
Menu:MenuElement({id = "Skarner", name = "[Skarner]UseR on Skarner Ult", value = true})
Menu:MenuElement({id = "Tham", name = "[TahmKench]UseR on Devour", value = true})
Menu:MenuElement({id = "Sion", name = "[Sion]UseR on Unstoppable Onslaught", value = true})
Menu:MenuElement({id = "MyHP", name = "Kalista min.Hp to UseR",  value = 40, min = 0, max = 100, step = 1})
Menu:MenuElement({id = "TargetHP", name = "Target min.Hp to UseR",  value = 30, min = 0, max = 100, step = 1})

-- Common
local function Ready(slot)
    return CanUseSpell(slot) == 0
end
 
local function GetDistanceSqr(p1, p2) 
    local dx, dz = p1.x - p2.x, p1.z - p2.z 
    return dx * dx + dz * dz
end

local function getPercentHP(unit)
	return unit.health * 100 / unit.maxHealth
end
	
local function GetSwornAlly()   
    for i = 1, HeroCount() do
        local hero = Hero(i)
        if hero and hero.isAlly and GotBuff(hero, "kalistacoopstrikeally") == 1 then            
            return (hero.charName == "Blitzcrank" or hero.charName == "Skarner" or hero.charName == "TahmKench" or hero.charName == "Sion") and hero or "Wrong Oath" 
		end
    end 
end
 
local function ExecuteBalista()
    for i = 1, HeroCount() do
        local enemy = Hero(i)
        if enemy and enemy.isEnemy and (GotBuff(enemy, "rocketgrab2") == 1 and getPercentHP(enemy) >= Menu.TargetHP:Value()) then          
            CastSpell(HK_R)
            return
        end
    end 
end	


local function ExecuteSkarlista()
    for i = 1, HeroCount() do
        local enemy = Hero(i)
        if enemy and enemy.isEnemy and (GotBuff(enemy, "SkarnerImpale") == 1 and getPercentHP(enemy) >= Menu.TargetHP:Value()) then          
            CastSpell(HK_R)
            return
        end
    end 
end


local function ExecuteThamlista()
    for i = 1, HeroCount() do
        local enemy = Hero(i)
        if enemy and enemy.isEnemy and (GotBuff(enemy, "tahmkenchwdevoured") == 1 and getPercentHP(enemy) >= Menu.TargetHP:Value()) then         
            CastSpell(HK_R)
            return
        end
    end 
end

local function ExecuteSion()
    for i = 1, HeroCount() do
        local unit = Hero(i)
        if unit.team == myHero.team and unit.activeSpell.name == "SionR" then         
            DelayAction(function()CastSpell(HK_R) end, 0.3)
            return
        end
    end 
end

local function OnTick()
    if not swornAlly then
        swornAlly = GetSwornAlly()
    end
    for i = 1, HeroCount() do
        local hero = Hero(i)
	if Ready(_R) and getPercentHP(myHero) >= Menu.MyHP:Value() then
	
		if (swornAlly and hero.charName == "Blitzcrank") and Menu.Blitz:Value() and GetDistanceSqr(swornAlly.pos, myHero.pos) <= rRange * rRange then
		ExecuteBalista() 
	
		elseif (swornAlly and hero.charName == "Skarner") and Menu.Skarner:Value() and GetDistanceSqr(swornAlly.pos, myHero.pos) <= rRange * rRange then
		ExecuteSkarlista()
	
		elseif (swornAlly and hero.charName == "TahmKench") and Menu.Tham:Value() and GetDistanceSqr(swornAlly.pos, myHero.pos) <= rRange * rRange then
		ExecuteThamlista()
		
		elseif (swornAlly and hero.charName == "Sion") and Menu.Sion:Value() and GetDistanceSqr(swornAlly.pos, myHero.pos) <= rRange * rRange then
		ExecuteSion()
		end
	end
end
end
	

function delayload()
	if not swornAlly then
        swornAlly = GetSwornAlly()
    end
		for i = 1, HeroCount() do
        local hero = Hero(i)
		if (swornAlly and hero.charName == "Blitzcrank") then
			PrintChat("Blitzcrank found !!!!!!!! Lets Rock and Roll !!!!!!")
		elseif (swornAlly and hero.charName == "Skarner") then
			PrintChat("Skarner found !!!!!!!! Lets Rock and Roll !!!!!!")
		elseif (swornAlly and hero.charName == "TahmKench") then
			PrintChat("ThamKench found !!!!!!!! Lets Rock and Roll !!!!!!")
		elseif (swornAlly and hero.charName == "Sion") then
			PrintChat("Sion found !!!!!!!! Lets Rock and Roll !!!!!!")		
		
		end
	end
end





 
Callback.Add("Tick", OnTick)



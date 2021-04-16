local heroes = false
local checkCount = 0 
local menu = 1
local Orb
local _OnWaypoint = {}
local _OnVision = {}
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local spellcast = {state = 1, mouse = mousePos}
local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7,}
local barHeight, barWidth, barXOffset, barYOffset = 8, 103, 0, 0
local Allies, Enemies, Turrets, Units = {}, {}, {}, {}
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local charging = false
local wClock = 0
local clock = os.clock
local Latency = Game.Latency
local ping = Latency() * 0.001
local MyHeroRange = myHero.range + myHero.boundingRadius * 2
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text
local ControlCastSpell = Control.CastSpell
local GameCanUseSpell = Game.CanUseSpell
local GameTimer = Game.Timer
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local GameObjectCount = Game.ObjectCount
local GameObject = Game.Object
local GameParticleCount = Game.ParticleCount
local GameParticle = Game.Particle
local GameMissileCount = Game.MissileCount
local GameMissile = Game.Missile
local GameIsChatOpen = Game.IsChatOpen
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local MathSqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
_G.LATENCY = 0.05

local currSpell = myHero.activeSpell
if currSpell and currSpell.valid and myHero.isChanneling then
print ("Width:  "..myHero.activeSpell.width)
print ("Speed:  "..myHero.activeSpell.speed)
print ("Delay:  "..myHero.activeSpell.animation)
print ("range:  "..myHero.activeSpell.range)
print ("Name:  "..myHero.activeSpell.name)
end


for i = 0, myHero.buffCount do
	local buff = myHero:GetBuff(i)
	if buff.name == "" then
	--print(buff.name)
		print("Typ:  "..buff.type)
		print("Name:  "..buff.name)
		print("Start:  "..buff.startTime)
		print("Expire:  "..buff.expireTime)
		print("Dura:  "..buff.duration)
		print("Stacks:  "..buff.stacks)
		print("Count:  "..buff.count)
		print("Id:  "..buff.sourcenID)
		print("SouceName:  "..buff.sourceName)	
	end
end

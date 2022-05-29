	MenuElement - Class
		MenuElement({}) -- initial call; returns instance
			possible properties of the input table:
				- id = "string", can be omitted but then it will not save
				- name = "string"
				- type = MENU|PARAM|SPACE, for PARAM type can be omitted
				- leftIcon = "string" [URL!], -> icon displayed on the left, 100% menu height
				- rightIcon = "string" [URL!] -> automatically converts param to boolean, 50% menu height
				- icon = "string" [URL!] -> icon displayed on the right, e.g. sub menu, 100% menu height
				- value =
					-> true|false, creates boolean param
					-> number, creates slider param
						-> + min = "number" + max = "number" [+ step = "number"] [+ identifier = "string"]
						or
						-> drop = {"string"[, "string", ...]}
					-> table {"number", "number"}, creates min/max slider param
						-> + min = "number" + max = "number" [+ step = "number"]
				- color = "color", creates color param
					-> Draw.Color(integer)
					or
					-> Draw.Color(hex)
					or
					-> Draw.Color(alpha, red, green, blue)
					or
					-> Draw.Color(hue, saturation, lightness)
				- key = "number", creates key param
				- toggle = "boolean", defaults to false, used to make a toggle key param
				- callback = "function"
					-> gets called on param change with changed value as input
				- onKeyChange = "function"
					-> gets called on key change with changed key as input
				- onhover = "function"
					-> gets called on param hover with the param as input
				- onclick = "function"
					-> gets called on param click with the param as input
				- tooltip = "string"
					-> gets displayed on hover
		instance:MenuElement({})
			creates submenu
		instance:Value([newVal])
			-> if called without newVal it returns the current value
			-> if called with newVal it'll set the current value to newVal and return it
		instance:Sprite(which[, url])
			-> which = "string"; "leftIcon"|"rightIcon"|"icon"
			-> if called without url it returns the current sprite
			-> if called with url it'll set the current sprite to that url
		instance:Hide([bool])
			-> if called without bool it'll toggle the hide property between true|false and return it
			-> if called with bool it'll set the hide property to that value and return it
		instance:Remove()
			-> this will permanently remove the MenuElement

	Example:
		local menu = MenuElement({id = "myMenu", name = "This is my Menu", type = MENU})
		menu:MenuElement({id = "bool", name = "My boolean Value", value = true})
		menu:MenuElement({id = "slide", name = "My slider", value = 0.7, min = 0, max = 1, step = 0.1})
		menu:MenuElement({id = "space", name = "This will get hidden on mouse click", type = SPACE, onclick = function() menu.space:Hide() end})
		Callback.Add("Tick", function()
			PrintChat("My bool: "..tostring(menu.bool:Value()).."; My slider: "..menu.slide:Value()..";")
		end)



Vector - Class
	Vector(...) -- initial call; returns instance
		overloads:
			() => 'nullvector' => (0, 0, 0)
			({x = 100, y = 100}) => (xy-table) => (100, 100)
			({x = 100, y = 0, z = 100}) => (xyz-table) => (100, 0, 100)
			(100, 0, 100) => (number, number, number) => (100, 0, 100)
			({x = 0, y = 50, z = 75}, {x = 100, y = 100, z = 100}) => (startVec, endVec) => (100, 50, 25)
	properties:
		.x -- the x value
		.y -- the y value
		.z -- the z value
		.onScreen -- for 2D vectors
	functions:
		:To2D() -- returns screenpos from Vector3 (alias ToScreen)
		:ToMM() -- returns minimap position from Vector3
		:Clone() -- returns a new vector
		:Unpack() -- returns x, y, z
		:DistanceTo(Vector) -- returns distance to another vector or, if ommited, myHero
		:Len() -- returns length
		:Len2() -- returns squared length
		:Normalize() -- normalizes a vector
		:Normalized() -- creates a new vector, normalizes it and returns it
		:Center(Vector) -- center between 2 vectors
		:CrossProduct(Vector) -- cross product of 2 vectors (alias: CrossP)
		:DotProduct(Vector) -- dot product of 2 vectors (alias: DotP)
		:ProjectOn(Vector) -- projects a vector on a vector
		:MirrorOn(Vector) -- mirrors a vector on a vector
		:Sin(Vector) -- calculates sin of 2 vector
		:Cos(Vector) -- calculates cos of 2 vector
		:Angle(Vector) -- calculates angle between 2 vectors
		:AffineArea(Vector) -- calculates area between 2 vectors
		:TriangleArea(Vector) -- calculates triangular area between 2 vectors
		:RotateX(phi) -- rotates vector by phi around x axis
		:RotateY(phi) -- rotates vector by phi around y axis
		:RotateZ(phi) -- rotates vector by phi around z axis
		:Rotate(phiX, phiY, phiZ) -- rotates vector 
		:Rotated(phiX, phiY, phiZ) -- creates a new vector, rotates it and returns it
		:Polar() -- returns polar value
		:AngleBetween(Vector, Vector) -- returns the angle formed from a vector to both input vectors
		:Compare(Vector) -- compares both vectors, returns difference
		:Perpendicular() -- creates a new vector that is rotated 90° right
		:Perpendicular2() -- creates a new vector that is rotated 90° left
		:Extend(Vector, distance) -- extends a vector towards a vector
		:Extended(Vector, distance) -- creates a new vector, extends it and returns it
		:Shorten(Vector, distance) -- shortens a vector towards a vector
		:Shortened(Vector, distance) -- creates a new vector, shortens it and returns it
		:Lerp(Vector, delta) -- creates a new vector, lerps it towards vector by delta



Sprite - Class
	Sprite(path)
		overloads:
			Sprite(path, scale)
			Sprite(path, scaleX, scaleY)
	properties (READ-ONLY):
		.x -- the x value
		.y -- the y value
		.pos -- Vector2
		.path -- file path
		.width -- the width
		.height -- the height
		.scale -- the scale
		.color -- the color
	functions:
		:Draw() -- draws the sprite at .pos
		:Draw(Vector2) -- draws the sprite at Vector2
		:Draw(x, y) -- draws the sprite at x y
		:Draw({x, y, w, h}, Vector2) -- draws a rectangle of the sprite at Vector2
		:Draw({x, y, w, h}, x, y) -- draws a rectangle of the sprite at x y
		:SetScale(scale) -- sets a sprite's scale
		:SetScale(scaleX, scaleY) -- sets a sprite's scale
		:SetPos(Vector2) -- sets a sprite's pos
		:SetPos(x, y) -- sets a sprite's pos
		:SetColor(Color) -- sets a sprite's color

GameObject
	-- not callable by user
	properties:
		.networkID
		.handle -- use for missile owner/target check
		.chnd --use for camp handle
		.buffCount
		.isMe
		.isAlly
		.isEnemy
		.team
		.owner
		.targetID --Turret Target
		.type
		.name
		.charName
		.health
		.maxHealth
		.mana
		.maxMana
		.hudAmmo
		.hudMaxAmmo --used for Jhin/Graves bullets or Annie stun or even Kled mount health; use with caution on other champs because it's not always 0 by default
		.shieldAD
		.shieldAP
		.cdr
		.armorPen
		.armorPenPercent
		.bonusArmorPenPercent
		.magicPen
		.magicPenPercent
		.baseDamage
		.bonusDamage
		.totalDamage
		.ap
		.lifeSteal
		.spellVamp
		.attackSpeed
		.critChance
		.armor
		.bonusArmor
		.magicResist
		.bonusMagicResist
		.hpRegen
		.mpRegen
		.ms
		.range
		.boundingRadius
		.gold
		.totalGold
		.dead
		.visible
		.isImmortal --works for zhonya and kayle ulti ++
		.isTargetable
		.isTargetableToTeam --works for turrets
		.distance
		.pos
			.x
			.y
			.z
		.posTo
			.x
			.y
			.z
		.hpBar
			.x
			.y
			.onScreen
		.pos2D
			.x
			.y
			.onScreen
		.toScreen
			.x
			.y
			.onScreen
		.posMM
			.x
			.y
		.dir
			.x
			.y
			.z
		.isCampUp -- for jungle camps only
		.valid -- for units only
		.attackData -- for units only
			.state -- STATE_UNKNOWN, STATE_ATTACK, STATE_WINDUP, STATE_WINDDOWN
			.windUpTime
			.windDownTime
			.animationTime
			.endTime
			.castFrame
			.projectileSpeed
			.target -- GameObject handle
			.attackDelayOffsetPercent -- used for calculating animationTime
			.attackDelayCastOffsetPercent -- used for calculating windUpTime
		.levelData -- for heroes only
			.exp
			.lvl
			.lvlPts
		.activeSpell
			.valid --always use this to check if it's casting
			.level
			.name
			.startPos -- Vector
			.placementPos -- Vector
			.target -- GameObject handle
			.windup
			.animation
			.range
			.mana
			.width
			.speed
			.coneAngle
			.coneDistance
			.acceleration
			.castFrame
			.maxSpeed
			.minSpeed
			.spellWasCast
			.isAutoAttack
			.isCharging
			.isChanneling
			.startTime
			.castEndTime
			.endTime
			.isStopped
		.activeSpellSlot --use this to determine which spell slot was activated for ".activeSpell"
		.isChanneling --use this to determine if ".activeSpell" is actually a spell, otherwise it's autoattack
		.missileData -- for missiles only
			.name -- string
			.owner -- GameObject handle
			.target -- GameObject handle
			.startPos -- Vector
			.endPos -- Vector
			.placementPos -- Vector
			.range
			.delay
			.speed
			.width
			.manaCost
		.bonusDamagePercent -- for minions only
		.flatDamageReduction -- for minions only
		.pathing --returns waypoints for unit
			.hasMovePath
			.pathIndex
			.startPos
				.x 
				.y 
				.z 
			.endPos
				.x 
				.y 
				.z
			.pathCount
			.isDashing
			.dashSpeed
			.dashGravity
	functions: -- for units only
		:GetSpellData(iSlot)
			.name
			.level
			.castTime
			.cd
			.currentCd
			.ammo
			.ammoTime
			.ammoCd
			.ammoCurrentCd
			.toggleState
			.range
			.mana
			.width
			.speed
			.targetingType
			.coneAngle
			.coneDistance
			.acceleration
			.castFrame
			.maxSpeed
			.minSpeed
		:GetItemData(index)
			.itemID
			.stacks
			.ammo
		:GetBuff(index)
			.type
			.name
			.startTime
			.expireTime
			.duration
			.stacks
			.count
			.sourcenID
			.sourceName
		:GetPrediction(speed,delay) --Vector
			.x
			.y
			.z
		:GetCollision(width,speed,delay)
			number --Collision Count
		:IsValidTarget(range,team check,source or pos) -- returns a boolean
		:GetPath(index) --returns a vector
			.x
			.y
			.z




Draw API: {
    Circle = Draws a 3D Circle; Input: (x, y, z)
    Circle = Draws a 3D Circle; Input: (x, y, z, Color)
    Circle = Draws a 3D Circle; Input: (x, y, z, radius)
    Circle = Draws a 3D Circle; Input: (x, y, z, radius, Color)
    Circle = Draws a 3D Circle; Input: (x, y, z, radius, width)
    Circle = Draws a 3D Circle; Input: (x, y, z, radius, width, Color)
    Circle = Draws a 3D Circle; Input: (Vector3)
    Circle = Draws a 3D Circle; Input: (Vector3, Color)
    Circle = Draws a 3D Circle; Input: (Vector3, radius)
    Circle = Draws a 3D Circle; Input: (Vector3, radius, Color)
    Circle = Draws a 3D Circle; Input: (Vector3, radius, width)
    Circle = Draws a 3D Circle; Input: (Vector3, radius, width, Color)
	CircleMinimap = Draws a 2D Circle; Input: (x, y, z)
    CircleMinimap = Draws a 2D Circle; Input: (x, y, z, Color)
    CircleMinimap = Draws a 2D Circle; Input: (x, y, z, radius)
    CircleMinimap = Draws a 2D Circle; Input: (x, y, z, radius, Color)
    CircleMinimap = Draws a 2D Circle; Input: (x, y, z, radius, width)
    CircleMinimap = Draws a 2D Circle; Input: (x, y, z, radius, width, Color)
    CircleMinimap = Draws a 2D Circle; Input: (Vector3)
    CircleMinimap = Draws a 2D Circle; Input: (Vector3, Color)
    CircleMinimap = Draws a 2D Circle; Input: (Vector3, radius)
    CircleMinimap = Draws a 2D Circle; Input: (Vector3, radius, Color)
    CircleMinimap = Draws a 2D Circle; Input: (Vector3, radius, width)
    CircleMinimap = Draws a 2D Circle; Input: (Vector3, radius, width, Color)
    Rect = Draws a 2D Rectangle; Input: (x, y, width, height)
    Rect = Draws a 2D Rectangle; Input: (x, y, width, height, Color)
    Rect = Draws a 2D Rectangle; Input: (Vector2, width, height)
    Rect = Draws a 2D Rectangle; Input: (Vector2, width, height, Color)
    Line = Draws a 2D Line; Input: (x1, y1, x2, y2)
    Line = Draws a 2D Line; Input: (x1, y1, x2, y2, Color)
    Line = Draws a 2D Line; Input: (x1, y1, x2, y2, width)
    Line = Draws a 2D Line; Input: (x1, y1, x2, y2, width, Color)
    Line = Draws a 2D Line; Input: (Vector2, x2, y2)
    Line = Draws a 2D Line; Input: (Vector2, x2, y2, Color)
    Line = Draws a 2D Line; Input: (Vector2, x2, y2, width)
    Line = Draws a 2D Line; Input: (Vector2, x2, y2, width, Color)
    Line = Draws a 2D Line; Input: (x1, y1, Vector2)
    Line = Draws a 2D Line; Input: (x1, y1, Vector2, Color)
    Line = Draws a 2D Line; Input: (x1, y1, Vector2, width)
    Line = Draws a 2D Line; Input: (x1, y1, Vector2, width, Color)
    Line = Draws a 2D Line; Input: (Vector2, Vector2)
    Line = Draws a 2D Line; Input: (Vector2, Vector2, Color)
    Line = Draws a 2D Line; Input: (Vector2, Vector2, width)
    Line = Draws a 2D Line; Input: (Vector2, Vector2, width, Color)
    Color = Creates a drawable Color; Input: (a, r, g, b); Returns Color
    Color = Creates a drawable Color; Input: (hex); Returns Color
    Color = Creates a drawable Color; Input: (unsigned); Returns Color
    Color = Creates a drawable Color; Input: (h, s, l); Returns Color
    Color = Creates a drawable Color; Input: (); Returns Color
    Default Color is White.
    Text = Draws a 2D Text; Input: (text, x, y)
    Text = Draws a 2D Text; Input: (text, size, x, y)
    Text = Draws a 2D Text; Input: (text, size, x, y, Color)
    Text = Draws a 2D Text; Input: (text, size, x, y, Color, Font)
    Text = Draws a 2D Text; Input: (text, Vector2)
    Text = Draws a 2D Text; Input: (text, size, Vector2)
    Text = Draws a 2D Text; Input: (text, size, Vector2, Color)
    Text = Draws a 2D Text; Input: (text, size, Vector2, Color, Font)
    Font = Creates a drawable Font; Input: (path, fontName)
    FontRect = Gets a Font Rectangle; Input: (text, fontSize); Return {width, height}
    FontRect = Gets a Font Rectangle; Input: (text, fontSize, Font); Return {width, height}
}



Control API: {
	LeftClick = Executes a left mouse click; Input: (XYTable | x, y)
	RightClick = Executes a right mouse click; Input: (XYTable | x, y)
    CastSpell = Executes a keystroke; Input: (char | byte)
    CastSpell = Executes a keystroke; Input: (char | byte, GameObject)
	CastSpell = Executes a keystroke and moves mouse; Input: (char | byte, x, y) --screen position
    CastSpell = Executes a keystroke and moves mouse; Input: (char | byte, x, y, z)
    CastSpell = Executes a keystroke and moves mouse; Input: (char | byte, Vector3)
    Move = Sends a move command towards mousePos; Input: none
	Move = Sends a move command; Input: (x, y) --screen position
    Move = Sends a move command; Input: (x, y, z)
    Move = Sends a move command; Input: (Vector3)
    Attack = Sends an attack command; Input: (GameObject)
    IsKeyDown = Check for a key being held down; Input: none; Return bool
	SetCursorPos = Sets the cursor position; Input: (Object | Vector3 | Vector2 | x, y) Return: bool
	KeyDown = Holds down a keystroke; Input: (char | byte) Return: bool
	KeyUp = Releases up a keystroke; Input: (char | byte) Return: bool
	mouse_event = Sends a mouse click (down or up, depending on flag); Input: (byte) Return: bool
}



Game API: {
    MyHero = Input none; Returns myHero
    Resolution = Input none; Returns Resolution as Vector
    FPS = Input none; Returns the total FPS
    IsOnTop = Input none; Return true/false if Game is on top
    IsChatOpen = Input none; Return true/false if chat is open
    Timer = Input none; Return the Game Timer
    mapID = The current map ID
    HeroCount = Input none; Return the total Hero Count
    Hero = Input (index); Return the Hero at index
    ObjectCount = Input none; Return the total Object Count
    Object = Input (index); Return the Object at index
    HeroCount = Input none; Return the total Hero Count
    Hero = Input (index); Return the Hero at index
    CampCount = Input none; Return the total Camp Count
    Camp = Input (index); Return the Camp at index
    TurretCount = Input none; Return the total Turret Count
    Turret = Input (index); Return the Turret at index
    MissileCount = Input none; Return the total Object Count
    Missile = Input (index); Return the Object at index
	ParticleCount = Input none; Return the total Object Count
    Particle = Input (index); Return the Object at index
    MinionCount = Input none; Return the total Minion Count
    Minion = Input (index); Return the Minion at index
    WardCount = Input none; Return the total Wards Count
    Ward = Input (index); Return the Wards at index
    ObjectCount = Input none; Return the total Object Count
    Object = Input (index); Return the Object at index
	GetObjectByNetID = Input (networkID); returns the object with the networkID requested
	Latency = Input none; Returns the game latency (ping)
	CanUseSpell = Input (spell index); Returns the state of a specific spell
	mousePos = alias to the global mouse pos; Return Vector3
	cursorPos = alias to the global cursor pos; Return Vector2
}



Callback API: {
    Add = Adds a new Callback; Input: (iType, function); Return: callbackID
    Del = Deletes a callback, Input: (iType, callbackID)
}

iTypes: {
    "Load",
    "UnLoad",
    "GameEnd",
    "Tick",
    "Draw",
    "WndMsg", -- (msg, wParam)
    "ProcessRecall" -- (unit, proc)
}



Global Constants:
	SCRIPT_PATH
	COMMON_PATH
	SPRITE_PATH
	SOUNDS_PATH
	FONTS_PATH
	
	READY
	NOTAVAILABLE
	READYNOCAST
	NOTLEARNED
	ONCOOLDOWN
	NOMANA
	NOMANAONCOOLDOWN

	WM_MOUSEHWHEEL
	WM_MBUTTONUP
	WM_MBUTTONDOWN
	WM_RBUTTONUP
	WM_RBUTTONDOWN
	WM_LBUTTONUP
	WM_LBUTTONDOWN
	KEY_UP
	KEY_DOWN

	CRYSTAL_SCAR
	TWISTED_TREELINE
	SUMMONERS_RIFT
	HOWLING_ABYSS

	STATE_UNKNOWN
	STATE_ATTACK
	STATE_WINDUP
	STATE_WINDDOWN

	_Q
	_W
	_E
	_R
	ITEM_1
	ITEM_2
	ITEM_3
	ITEM_4
	ITEM_5
	ITEM_6
	ITEM_7 --(trinket)
	SUMMONER_1
	SUMMONER_2
	
	HK_Q
	HK_W
	HK_E
	HK_R
	HK_ITEM_1
	HK_ITEM_2
	HK_ITEM_3
	HK_ITEM_4
	HK_ITEM_5
	HK_ITEM_6
	HK_ITEM_7 --(trinket)
	HK_SUMMONER_1
	HK_SUMMONER_2
	HK_TCO -- Target Champions Only
	HK_LUS -- Level Up Spell Hotkey
	HK_MENU -- Hotkey for the LUA Menu
	
	MOUSEEVENTF_LEFTDOWN --used by mouse_event
	MOUSEEVENTF_LEFTUP
	MOUSEEVENTF_RIGHTDOWN
	MOUSEEVENTF_RIGHTUP

	Obj_AI_SpawnPoint
	Obj_AI_Camp
	Obj_AI_Barracks
	Obj_AI_Hero
	Obj_AI_Minion
	Obj_AI_Turret
	Obj_AI_LineMissle
	Obj_AI_Shop
	Obj_AI_Nexus

	cursorPos (Vector2)
	mousePos (Vector3)

	myHero (GameObject)


Global Functions:
	GetTickCount()
	GetImageInfoFromFile(path)
	PrintChat(message) -- prints one string
	print(...) -- prints everything
	DumpDocumentation("api.lua") -- writes this text to a file
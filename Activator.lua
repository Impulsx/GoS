class "Zhonya"

 function OnLoad()

	Zhonya()
end
 
 function Zhonya:__init()
	
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)

	end
	

local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}

function Zhonya:LoadMenu()
	
	self.Menu = MenuElement({type = MENU, id = "Zhonya+Stopwatch Activator", name = "Zhonyas and StopWatch Activator"})
	self.Menu:MenuElement({id = "Zhonya", name = "Zhonya's Hourglass", type = MENU})
	self.Menu.Zhonya:MenuElement({id = "UseZ", name = "Use Zhonya's Hourglass", value = true})
	self.Menu:MenuElement({id = "Stopwatch", name = "Stopwatch", type = MENU})
	self.Menu.Stopwatch:MenuElement({id = "UseS", name = "Use Stopwatch", value = true})	
	self.Menu:MenuElement({id = "HP", name = "myHP", type = MENU})
	self.Menu.HP:MenuElement({id = "myHP", name = "My HP%",value = 20, min = 0, max = 100,step = 1})	

end		

function Zhonya:Tick()
	self:UseZhonya()			
	self:UseStopwatch()
	
end	



function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end	
		
function GetPercentHP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.health/unit.maxHealth
end	

function Zhonya:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				SetMovement(false)
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end	
	
function Zhonya:UseZhonya()
	local Z = GetInventorySlotItem(3157)
	if Z and self.Menu.Zhonya.UseZ:Value() and GetPercentHP(myHero) < self.Menu.HP.myHP:Value() then
		Control.CastSpell(HKITEM[Z], myHero)
	
	end
end	
			
function Zhonya:UseStopwatch()
	local S = GetInventorySlotItem(2420)
	if S and self.Menu.Stopwatch.UseS:Value() and GetPercentHP(myHero) < self.Menu.HP.myHP:Value() then
		Control.CastSpell(HKITEM[S], myHero)			
	
	end
end	

function OnTick()

end











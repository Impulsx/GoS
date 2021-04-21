----------------------------------------------------
--|                    Utils                     |--
----------------------------------------------------

_G.LATENCY = 0.05

----------------------------------------------------
--|                Managment               		|--
----------------------------------------------------
class "Dev"

local EnemyLoaded = false

local HeroIcon = "http://gamingonsteroids.com/uploads/profile/photo-194827.jpg"

function Dev:__init()
	self:Menu()
    --self:Spells()

    --GetEnemyHeroes()
    Callback.Add("Tick", function() self:Tick() end)
    --Callback.Add("Draw", function() self:Draw() end)
--[[
	if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) self:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) self:OnPostAttack(...) end)
    ende
]]
end

function Dev:Menu()
	self.Menu = MenuElement({type = MENU, id = "DevKit", name = "Impuls DevKit"})
		self.Menu:MenuElement({id = "Enable", name = "Enable DevKit Print", value = true})
		self.Menu:MenuElement({id = "EnableSpellBuff", name = "Print & Draw - Enable for Spells | Disable for Buffs", value = true})
		self.Menu:MenuElement({id = "Q", name = "Q Info", type = MENU})
			self.Menu.Q:MenuElement({id = "Q", name = "Q Name: "..myHero:GetSpellData(_Q).name})
			self.Menu.Q:MenuElement({id = "Q", name = "Q Width: "..myHero:GetSpellData(_Q).width})
			self.Menu.Q:MenuElement({id = "Q", name = "Q Speed: "..myHero:GetSpellData(_Q).speed})
			self.Menu.Q:MenuElement({id = "Q", name = "Q Range: "..myHero:GetSpellData(_Q).range})
			self.Menu.Q:MenuElement({id = "Q", name = "Q Targetingtype: "..myHero:GetSpellData(_Q).targetingType})
			self.Menu.Q:MenuElement({id = "Q", name = "Q ConeAngle: "..myHero:GetSpellData(_Q).coneAngle})
			self.Menu.Q:MenuElement({id = "Q", name = "Q ConeDistance: "..myHero:GetSpellData(_Q).coneDistance})
			self.Menu.Q:MenuElement({id = "Q", name = "Q Ammo: "..myHero:GetSpellData(_Q).ammo})
			self.Menu.Q:MenuElement({id = "Q", name = "Q AmmoTime: "..myHero:GetSpellData(_Q).ammoTime})
			self.Menu.Q:MenuElement({id = "Q", name = "Q AmmoCD: "..myHero:GetSpellData(_Q).ammoCd})
			self.Menu.Q:MenuElement({id = "Q", name = "Q ToggleState: "..myHero:GetSpellData(_Q).toggleState})
			self.Menu.Q:MenuElement({id = "Q", name = "Q Acceleration: "..myHero:GetSpellData(_Q).acceleration})
			self.Menu.Q:MenuElement({id = "Q", name = "Q CastFrame: "..myHero:GetSpellData(_Q).castFrame})
			self.Menu.Q:MenuElement({id = "Q", name = "Q MaxSpeed: "..myHero:GetSpellData(_Q).maxSpeed})
			self.Menu.Q:MenuElement({id = "Q", name = "Q MinSpeed: "..myHero:GetSpellData(_Q).minSpeed})
		self.Menu:MenuElement({id = "W", name = "W Info", type = MENU})
			self.Menu.W:MenuElement({id = "W", name = "W Name: "..myHero:GetSpellData(_W).name})
			self.Menu.W:MenuElement({id = "W", name = "W Width: "..myHero:GetSpellData(_W).width})
			self.Menu.W:MenuElement({id = "W", name = "W Speed: "..myHero:GetSpellData(_W).speed})
			self.Menu.W:MenuElement({id = "W", name = "W Range: "..myHero:GetSpellData(_W).range})
			self.Menu.W:MenuElement({id = "W", name = "W Targetingtype: "..myHero:GetSpellData(_W).targetingType})
			self.Menu.W:MenuElement({id = "W", name = "W ConeAngle: "..myHero:GetSpellData(_W).coneAngle})
			self.Menu.W:MenuElement({id = "W", name = "W ConeDistance: "..myHero:GetSpellData(_W).coneDistance})
			self.Menu.W:MenuElement({id = "W", name = "W Ammo: "..myHero:GetSpellData(_W).ammo})
			self.Menu.W:MenuElement({id = "W", name = "W AmmoTime: "..myHero:GetSpellData(_W).ammoTime})
			self.Menu.W:MenuElement({id = "W", name = "W AmmoCD: "..myHero:GetSpellData(_W).ammoCd})
			self.Menu.W:MenuElement({id = "W", name = "W ToggleState: "..myHero:GetSpellData(_W).toggleState})
			self.Menu.W:MenuElement({id = "W", name = "W Acceleration: "..myHero:GetSpellData(_W).acceleration})
			self.Menu.W:MenuElement({id = "W", name = "W CastFrame: "..myHero:GetSpellData(_W).castFrame})
			self.Menu.W:MenuElement({id = "W", name = "W MaxSpeed: "..myHero:GetSpellData(_W).maxSpeed})
			self.Menu.W:MenuElement({id = "W", name = "W MinSpeed: "..myHero:GetSpellData(_W).minSpeed})
		self.Menu:MenuElement({id = "E", name = "E Info", type = MENU})
			self.Menu.E:MenuElement({id = "E", name = "E Name: "..myHero:GetSpellData(_E).name})
			self.Menu.E:MenuElement({id = "E", name = "E Width: "..myHero:GetSpellData(_E).width})
			self.Menu.E:MenuElement({id = "E", name = "E Speed: "..myHero:GetSpellData(_E).speed})
			self.Menu.E:MenuElement({id = "E", name = "E Range: "..myHero:GetSpellData(_E).range})
			self.Menu.E:MenuElement({id = "E", name = "E Targetingtype: "..myHero:GetSpellData(_E).targetingType})
			self.Menu.E:MenuElement({id = "E", name = "E ConeAngle: "..myHero:GetSpellData(_E).coneAngle})
			self.Menu.E:MenuElement({id = "E", name = "E ConeDistance: "..myHero:GetSpellData(_E).coneDistance})
			self.Menu.E:MenuElement({id = "E", name = "E Ammo: "..myHero:GetSpellData(_E).ammo})
			self.Menu.E:MenuElement({id = "E", name = "E AmmoTime: "..myHero:GetSpellData(_E).ammoTime})
			self.Menu.E:MenuElement({id = "E", name = "E AmmoCD: "..myHero:GetSpellData(_E).ammoCd})
			self.Menu.E:MenuElement({id = "E", name = "E ToggleState: "..myHero:GetSpellData(_E).toggleState})
			self.Menu.E:MenuElement({id = "E", name = "E Acceleration: "..myHero:GetSpellData(_E).acceleration})
			self.Menu.E:MenuElement({id = "E", name = "E CastFrame: "..myHero:GetSpellData(_E).castFrame})
			self.Menu.E:MenuElement({id = "E", name = "E MaxSpeed: "..myHero:GetSpellData(_E).maxSpeed})
			self.Menu.E:MenuElement({id = "E", name = "E MinSpeed: "..myHero:GetSpellData(_E).minSpeed})
		self.Menu:MenuElement({id = "R", name = "R Info", type = MENU})
			self.Menu.R:MenuElement({id = "R", name = "R Name: "..myHero:GetSpellData(_R).name})
			self.Menu.R:MenuElement({id = "R", name = "R Width: "..myHero:GetSpellData(_R).width})
			self.Menu.R:MenuElement({id = "R", name = "R Speed: "..myHero:GetSpellData(_R).speed})
			self.Menu.R:MenuElement({id = "R", name = "R Range: "..myHero:GetSpellData(_R).range})
			self.Menu.R:MenuElement({id = "R", name = "R Targetingtype: "..myHero:GetSpellData(_R).targetingType})
			self.Menu.R:MenuElement({id = "R", name = "R ConeAngle: "..myHero:GetSpellData(_R).coneAngle})
			self.Menu.R:MenuElement({id = "R", name = "R ConeDistance: "..myHero:GetSpellData(_R).coneDistance})
			self.Menu.R:MenuElement({id = "R", name = "R Ammo: "..myHero:GetSpellData(_R).ammo})
			self.Menu.R:MenuElement({id = "R", name = "R AmmoTime: "..myHero:GetSpellData(_R).ammoTime})
			self.Menu.R:MenuElement({id = "R", name = "R AmmoCD: "..myHero:GetSpellData(_R).ammoCd})
			self.Menu.R:MenuElement({id = "R", name = "R ToggleState: "..myHero:GetSpellData(_R).toggleState})
			self.Menu.R:MenuElement({id = "R", name = "R Acceleration: "..myHero:GetSpellData(_R).acceleration})
			self.Menu.R:MenuElement({id = "R", name = "R CastFrame: "..myHero:GetSpellData(_R).castFrame})
			self.Menu.R:MenuElement({id = "R", name = "R MaxSpeed: "..myHero:GetSpellData(_R).maxSpeed})
			self.Menu.R:MenuElement({id = "R", name = "R MinSpeed: "..myHero:GetSpellData(_R).minSpeed})
		self.Menu:MenuElement({id = "Buff", name = "Buff Info", type = MENU})
		--[[DelayAction(function()
			for i, Hero in pairs(GetEnemyHeroes()) do
				self.Menu.Buff:MenuElement({id = myHero:GetBuff(i).name, name = "Buff Name: "..myHero:GetBuff(i).name, drop = {"Buff Name: "..myHero:GetBuff}})		
			end		
		end,0.2)]]	
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff Name: "..myHero:GetBuff(i).name})
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff Type: "..myHero:GetBuff(i).type})
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff Stacks: "..myHero:GetBuff(i).stacks})
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff Count: "..myHero:GetBuff(i).count})
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff Duration: "..myHero:GetBuff(i).duration})
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff StartTime: "..myHero:GetBuff(i).startTime})
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff ExpireTime: "..myHero:GetBuff(i).expireTime})
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff SourceID: "..myHero:GetBuff(i).sourcenID})
			self.Menu.Buff:MenuElement({id = "Buff", name = "Buff SourceName: "..myHero:GetBuff(i).sourceName})
			self.Menu:MenuElement({id = "Ammo", name = "Ammo Info", type = MENU})	
			self.Menu.Ammo:MenuElement({id = "Ammo", name = "Current Ammo: "..myHero.hudAmmo})
			self.Menu.Ammo:MenuElement({id = "Ammo", name = "Max Ammo: "..myHero.hudMaxAmmo})

			--[[Callback.Add("Tick", function()  
		if myHero.activeSpell and myHero.activeSpell.valid and myHero.isChanneling then
			print(myHero.activeSpell.name.." Delay: "..myHero.activeSpell.animation) 
		end
	end)]]
end

function Dev:Spells()
    if self.Menu.EnableSpellBuff:Value() then
		local currSpell = myHero.activeSpell
		if currSpell and currSpell.valid and myHero.isChanneling then
			print (myHero.activeSpell.name.." Width:  "..myHero.activeSpell.width)
			print (myHero.activeSpell.name.." Speed:  "..myHero.activeSpell.speed)
			print (myHero.activeSpell.name.." Delay:  "..myHero.activeSpell.animation)
			print (myHero.activeSpell.name.." range:  "..myHero.activeSpell.range)
			print (myHero.activeSpell.name.." Name:  "..myHero.activeSpell.name)
			print (myHero.charName.." Current Ammo: "..myHero.hudAmmo)
			print (myHero.charName.." Max Ammo: "..myHero.hudMaxAmmo)
		end
	else
		for i = 0, myHero.buffCount do
			local buff = myHero:GetBuff(i)
			--if buff.name == "" then
			--print(buff.name)
				print("Type:  "..buff.type)
				print("Name:  "..buff.name)
				print("Start:  "..buff.startTime)
				print("Expire:  "..buff.expireTime)
				print("Dura:  "..buff.duration)
				print("Stacks:  "..buff.stacks)
				print("Count:  "..buff.count)
				print("Id:  "..buff.sourcenID)
				print("SourceName:  "..buff.sourceName)	
			--end
		end
	end	
end

function Dev:Tick()

	if myHero.dead or Game.IsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) then
        return
    end
	--DelayAction(function() self:Spells() end, 1.00)
	PrintChat(myHero.activeSpell.name)
	--for i = 1, myHero.buffCount do
		--local buff = myHero:GetBuff(i)
		--if buff.count ~= 0 then
			PrintChat(myHero:GetBuff(i).name)
		--end
	--end
end

function Dev:Draw()
	if myHero.dead then return end
 
    if self.Menu.Enable:Value() then
			Draw.Text("DevKit ON", 18, myHero.pos2D.x+50,myHero.pos2D.y+25, Draw.Color(255, 30, 230, 30))
		if self.Menu.EnableSpellBuff:Value() then
			Draw.Text(myHero.activeSpell.name.." Width:  "..myHero.activeSpell.width, 18, myHero.pos2D.x+25,myHero.pos2D.y+50, Draw.Color(255, 30, 230, 30))
			Draw.Text(myHero.activeSpell.name.." Speed:  "..myHero.activeSpell.speed, 18, myHero.pos2D.x+25,myHero.pos2D.y+75, Draw.Color(255, 30, 230, 30))
			Draw.Text(myHero.activeSpell.name.." Delay:  "..myHero.activeSpell.animation, 18, myHero.pos2D.x+25,myHero.pos2D.y+100, Draw.Color(255, 30, 230, 30))
			Draw.Text(myHero.activeSpell.name.." range:  "..myHero.activeSpell.range, 18, myHero.pos2D.x+25,myHero.pos2D.y+125, Draw.Color(255, 30, 230, 30))
			Draw.Text(myHero.activeSpell.name.." Name:  "..myHero.activeSpell.name, 18, myHero.pos2D.x+25,myHero.pos2D.y+150, Draw.Color(255, 30, 230, 30))
			Draw.Text(myHero.charName.." Current Ammo: "..myHero.hudAmmo, 18, myHero.pos2D.x+25,myHero.pos2D.y+175, Draw.Color(255, 30, 230, 30))
			Draw.Text(myHero.charName.." Max Ammo: "..myHero.hudMaxAmmo, 18, myHero.pos2D.x+25,myHero.pos2D.y+200, Draw.Color(255, 30, 230, 30))
		elseif not self.Menu.EnableSpellBuff:Value() then
			--for i = 0, myHero.buffCount do
				--local buff = myHero:GetBuff(i)
				Draw.Text("Buff Name: "..myHero:GetBuff(i).name, 18, myHero.pos2D.x+25,myHero.pos2D.y+50, Draw.Color(255, 30, 230, 30))
				Draw.Text("Buff Type: "..myHero:GetBuff(i).type, 18, myHero.pos2D.x+25,myHero.pos2D.y+75, Draw.Color(255, 30, 230, 30))
				Draw.Text("Buff Stacks: "..myHero:GetBuff(i).stacks, 18, myHero.pos2D.x+25,myHero.pos2D.y+100, Draw.Color(255, 30, 230, 30))
				Draw.Text("Buff Count: "..myHero:GetBuff(i).count, 18, myHero.pos2D.x+25,myHero.pos2D.y+125, Draw.Color(255, 30, 230, 30))
				Draw.Text("Buff Duration: "..myHero:GetBuff(i).duration, 18, myHero.pos2D.x+25,myHero.pos2D.y+150, Draw.Color(255, 30, 230, 30))
				Draw.Text("Buff StartTime: "..myHero:GetBuff(i).startTime, 18, myHero.pos2D.x+25,myHero.pos2D.y+175, Draw.Color(255, 30, 230, 30))
				Draw.Text("Buff ExpireTime: "..myHero:GetBuff(i).expireTime, 18, myHero.pos2D.x+25,myHero.pos2D.y+200, Draw.Color(255, 30, 230, 30))
				Draw.Text("Buff SourceID: "..myHero:GetBuff(i).sourcenID, 18, myHero.pos2D.x+25,myHero.pos2D.y+225, Draw.Color(255, 30, 230, 30))
				Draw.Text("Buff SourceName: "..myHero:GetBuff(i).sourceName, 18, myHero.pos2D.x+25,myHero.pos2D.y+250, Draw.Color(255, 30, 230, 30))
			--end
		else
			Draw.Text("DevKit OFF", 18, myHero.pos2D.x+25,myHero.pos2D.y+25, Draw.Color(255, 230, 30, 30))
		end
	end	
end

function Dev:OnPostAttack(args)
end

function Dev:OnPostAttackTick(args)
end

function Dev:OnPreAttack(args)
end

function OnLoad()
	Dev()
end	
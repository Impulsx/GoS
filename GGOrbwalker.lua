local Version = 2.8
local Name = "GGOrbwalker"

_G.GGUpdate = {}
do
    function GGUpdate:__init()
        self.Callbacks = {}
    end
    function GGUpdate:DownloadFile(url, path)
        DownloadFileAsync(url, path, function() end)
    end
    function GGUpdate:Trim(s)
        local from = s:match"^%s*()"
        return from > #s and "" or s:match(".*%S", from)
    end
    function GGUpdate:ReadFile(path)
        local result = {}
        local file = io.open(path, "r")
        if file then
            for line in file:lines() do
                local str = self:Trim(line)
                if #str > 0 then
                    table.insert(result, str)
                end
            end
            file:close()
        end
        return result
    end
    function GGUpdate:New(args)
        local updater = {}
        function updater:__init()
            self.Step = 1
            self.Version = type(args.version) == 'number' and args.version or tonumber(args.version)
            self.VersionUrl = args.versionUrl
            self.VersionPath = args.versionPath
            self.ScriptUrl = args.scriptUrl
            self.ScriptPath = args.scriptPath
            self.ScriptName = args.scriptName
            self.VersionTimer = GetTickCount()
            self:DownloadVersion()
        end
        function updater:DownloadVersion()
            if not FileExist(self.ScriptPath) then
                self.Step = 4
                GGUpdate:DownloadFile(self.ScriptUrl, self.ScriptPath)
                self.ScriptTimer = GetTickCount()
                return
            end
            GGUpdate:DownloadFile(self.VersionUrl, self.VersionPath)
        end
        function updater:OnTick()
            if self.Step == 0 then
                return
            end
            if self.Step == 1 then
                if GetTickCount() > self.VersionTimer + 1 then
                    local response = GGUpdate:ReadFile(self.VersionPath)
                    if #response > 0 and tonumber(response[1]) > self.Version then
                        self.Step = 2
                        self.NewVersion = response[1]
                        GGUpdate:DownloadFile(self.ScriptUrl, self.ScriptPath)
                        self.ScriptTimer = GetTickCount()
                    else
                        self.Step = 3
                    end
                end
            end
            if self.Step == 2 then
                if GetTickCount() > self.ScriptTimer + 1 then
                    self.Step = 0
                    print(self.ScriptName .. ' - new update found! [' .. tostring(self.Version) .. ' -> ' .. self.NewVersion .. '] Please 2xf6!')
                end
                return
            end
            if self.Step == 3 then
                self.Step = 0
                return
            end
            if self.Step == 4 then
                if GetTickCount() > self.ScriptTimer + 1 then
                    self.Step = 0
                    print(self.ScriptName .. ' - downloaded! Please 2xf6!')
                end
            end
        end
        updater:__init()
        table.insert(self.Callbacks, updater)
    end
    GGUpdate:__init()
end
GGUpdate:New({
    version = Version,
    scriptName = Name,
    scriptPath = SCRIPT_PATH .. Name .. ".lua",
    scriptUrl = "https://raw.githubusercontent.com/gamsteron/GG/master/" .. Name .. ".lua",
    versionPath = SCRIPT_PATH .. Name .. ".version",
    versionUrl = "https://raw.githubusercontent.com/gamsteron/GG/master/" .. Name .. ".version"
})

if _G.SDK then
    return
end

local Updated, FlashHelper, Cached, Menu, Color, Action, Buff, Damage, Data, Spell, SummonerSpell, Item, Object, Target, Orbwalker, Movement, Cursor, Health, Attack, EvadeSupport

local myHero = _G.myHero
local os = _G.os
local Game = _G.Game
local Vector = _G.Vector
local Control = _G.Control
local Draw = _G.Draw
local pairs = _G.pairs
local GetTickCount = _G.GetTickCount
local math_huge = math.huge
local math_pi = math.pi
local math_sqrt = assert(math.sqrt)
local math_abs = assert(math.abs)
local math_ceil = assert(math.ceil)
local math_min = assert(math.min)
local math_max = assert(math.max)
local math_pow = assert(math.pow)
local math_atan = assert(math.atan)
local math_acos = assert(math.acos)
local math_random = assert(math.random)
local table_sort = assert(table.sort)
local table_remove = assert(table.remove)
local table_insert = assert(table.insert)
local GameCanUseSpell = _G.Game.CanUseSpell

local DAMAGE_TYPE_PHYSICAL = 0
local DAMAGE_TYPE_MAGICAL = 1
local DAMAGE_TYPE_TRUE = 2

local ORBWALKER_MODE_NONE = -1
local ORBWALKER_MODE_COMBO = 0
local ORBWALKER_MODE_HARASS = 1
local ORBWALKER_MODE_LANECLEAR = 2
local ORBWALKER_MODE_JUNGLECLEAR = 3
local ORBWALKER_MODE_LASTHIT = 4
local ORBWALKER_MODE_FLEE = 5

local SORT_AUTO = 1
local SORT_CLOSEST = 2
local SORT_NEAR_MOUSE = 3
local SORT_LOWEST_HEALTH = 4
local SORT_LOWEST_MAX_HEALTH = 5
local SORT_HIGHEST_PRIORITY = 6
local SORT_MOST_STACK = 7
local SORT_MOST_AD = 8
local SORT_MOST_AP = 9
local SORT_LESS_CAST = 10
local SORT_LESS_ATTACK = 11

local ItemSlots = {ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}
local ItemKeys = {HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4, HK_ITEM_5, HK_ITEM_6, HK_ITEM_7}

local function IsInRange(v1, v2, range)
    v1 = v1.pos or v1
    v2 = v2.pos or v2
    local dx = v1.x - v2.x
    local dz = (v1.z or v1.y) - (v2.z or v2.y)
    if dx * dx + dz * dz <= range * range then
        return true
    end
    return false
end

local function GetDistance(v1, v2)
    v1 = v1.pos or v1
    v2 = v2.pos or v2
    local dx = v1.x - v2.x
    local dz = (v1.z or v1.y) - (v2.z or v2.y)
    return math_sqrt(dx * dx + dz * dz)
end

local function Polar(v1)
    local x = v1.x
    local z = v1.z or v1.y
    if x == 0 then
        if z > 0 then
            return 90
        end
        return z < 0 and 270 or 0
    end
    local theta = math_atan(z / x) * (180.0 / math_pi)
    if x < 0 then
        theta = theta + 180
    end
    if theta < 0 then
        theta = theta + 360
    end
    return theta
end

local function AngleBetween(vec1, vec2)
    local theta = Polar(vec1) - Polar(vec2)
    if theta < 0 then
        theta = theta + 360
    end
    if theta > 180 then
        theta = 360 - theta
    end
    return theta
end

local function IsFacing(source, target, angle)
    angle = angle or 90
    target = target.pos or Vector(target)
    if AngleBetween(source.dir, target - source.pos) < angle then
        return true
    end
    return false
end

local function Base64Decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r..(f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end return string.char(c)
    end))
end

local function WriteToFile(path, str)
    path = SPRITE_PATH .. path
    if FileExist(path) then return end
    local output = io.open(path, 'wb')
    output:write(Base64Decode(str))
    output:close()
end

local function GetControlPos(a, b, c)
    local pos
    if a and b and c then
        pos = {x = a, y = b, z = c}
    elseif a and b then
        pos = {x = a, y = b}
    elseif a then
        pos = a.pos or a
    end
    return pos
end

local function CastKey(key)
    if key == MOUSEEVENTF_RIGHTDOWN then
        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
        Control.mouse_event(MOUSEEVENTF_RIGHTUP)
    else
        Control.KeyDown(key)
        Control.KeyUp(key)
    end
end

-- flash helper
FlashHelper = {}
do
    -- init
    function FlashHelper:__init()
        self.Timer = 0
        self.FlashSpell = 0
        self.Flash = nil
        _G.Control.Flash = function()
            if Cursor.Step == 0 then
                Cursor:Add(self.Menu.Flashlol:Key(), myHero.pos:Extended(Vector(mousePos), 600))
                return
            end
            self.Flash = self.Menu.Flashlol:Key()
        end
    end
    
    -- create menu
    function FlashHelper:CreateMenu(main)
        self.Menu = main:MenuElement({type = MENU, id = "PMenuFH", name = "Flash Helper", leftIcon = "/Gamsteron_Spell_SummonerFlash.png"})
        self.Menu:MenuElement({id = "Enabled", name = "Enabled", value = true})
        self.Menu:MenuElement({id = "Flashlol", name = "Flash LOL HotKey", key = string.byte("P")})
        self.Menu:MenuElement({id = "Flashgos", name = "Flash GOS HotKey", key = string.byte("F")})
    end
    
    -- on tick
    function FlashHelper:OnTick()
        if self.Menu.Flashgos:Value() and self.Menu.Enabled:Value() and self:IsReady() and not myHero.dead and not Game.IsChatOpen() and Game.IsOnTop() then
            print("Flash Helper | Flashing!")
            self.Timer = GetTickCount()
            Control.Flash()
        end
    end
    
    -- is ready
    function FlashHelper:IsReady()
        local has_flash = false
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
            self.FlashSpell = SUMMONER_1
            has_flash = true
        end
        if myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
            self.FlashSpell = SUMMONER_2
            has_flash = true
        end
        if (not has_flash) then
            return false
        end
        if GetTickCount() < LastChatOpenTimer + 1000 then
            return
        end
        if (myHero:GetSpellData(self.FlashSpell).currentCd > 0) then
            return false
        end
        if (Game.CanUseSpell(self.FlashSpell) ~= 0) then
            return false
        end
        if GetTickCount() < self.Timer + 1000 then
            return false
        end
        return true
    end
    
    -- init call
    FlashHelper:__init()
end

-- cached
Cached = {}
do
    -- init
    function Cached:__init()
        self.Minions = {}
        self.Turrets = {}
        self.Wards = {}
        self.Heroes = {}
        self.Buffs = {}
        self.HeroesSaved = false
        self.MinionsSaved = false
        self.TurretsSaved = false
        self.WardsSaved = false
    end
    -- reset
    function Cached:Reset()
        -- heroes
        if self.HeroesSaved then
            for i = #self.Heroes, 1, -1 do
                self.Heroes[i] = nil
            end
            self.HeroesSaved = false
        end
        -- minions
        if self.MinionsSaved then
            for i = #self.Minions, 1, -1 do
                self.Minions[i] = nil
            end
            self.MinionsSaved = false
        end
        -- turrets
        if self.TurretsSaved then
            for i = #self.Turrets, 1, -1 do
                self.Turrets[i] = nil
            end
            self.TurretsSaved = false
        end
        -- wards
        if self.WardsSaved then
            for i = #self.Wards, 1, -1 do
                self.Wards[i] = nil
            end
            self.WardsSaved = false
        end
        -- buffs
        for k in pairs(self.Buffs) do
            self.Buffs[k] = nil
        end
    end
    -- buff
    function Cached:Buff(b)
        local class = {}
        local members = {}
        local metatable = {}
        local _b = b
        function metatable.__index(s, k)
            if members[k] == nil then
                if k == 'duration' then
                    members[k] = _b.duration
                elseif k == 'count' then
                    members[k] = _b.count
                elseif k == 'stacks' then
                    members[k] = _b.stacks
                else
                    members[k] = _b[k]
                end
            end
            return members[k]
        end
        setmetatable(class, metatable)
        return class
    end
    -- get heroes
    function Cached:GetHeroes()
        if not self.HeroesSaved then
            self.HeroesSaved = true
            local count = Game.HeroCount()
            if count and count > 0 and count < 1000 then
                for i = 1, count do
                    local o = Game.Hero(i)
                    if o and o.valid and o.visible and o.isTargetable and not o.dead then
                        table_insert(self.Heroes, o)
                    end
                end
            end
        end
        return self.Heroes
    end
    -- get minions
    function Cached:GetMinions()
        if not self.MinionsSaved then
            self.MinionsSaved = true
            local count = Game.MinionCount()
            if count and count > 0 and count < 1000 then
                for i = 1, count do
                    local o = Game.Minion(i)
                    if o and o.valid and o.visible and o.isTargetable and not o.dead and not o.isImmortal then
                        table_insert(self.Minions, o)
                    end
                end
            end
        end
        return self.Minions
    end
    -- get turrets
    function Cached:GetTurrets()
        if not self.TurretsSaved then
            self.TurretsSaved = true
            local count = Game.TurretCount()
            if count and count > 0 and count < 1000 then
                for i = 1, count do
                    local o = Game.Turret(i)
                    if o and o.valid and o.visible and o.isTargetable and not o.dead and not o.isImmortal then
                        table_insert(self.Turrets, o)
                    end
                end
            end
        end
        return self.Turrets
    end
    -- get wards
    function Cached:GetWards()
        if not self.WardsSaved then
            self.WardsSaved = true
            local count = Game.WardCount()
            if count and count > 0 and count < 1000 then
                for i = 1, count do
                    local o = Game.Ward(i)
                    if o and o.valid and o.visible and o.isTargetable and not o.dead and not o.isImmortal then
                        table_insert(self.Wards, o)
                    end
                end
            end
        end
        return self.Wards
    end
    -- get buffs
    function Cached:GetBuffs(o)
        local id = o.networkID
        if self.Buffs[id] == nil then
            local count = o.buffCount
            if count and count >= 0 and count < 10000 then
                local b, b2 = nil, nil
                local buffs = {}
                for i = 0, count do
                    b = o:GetBuff(i)
                    if b then
                        b2 = self:Buff(b)
                        if b2.count > 0 then
                            table_insert(buffs, b2)
                        end
                    end
                end
                self.Buffs[id] = buffs
            end
        end
        return self.Buffs[id] or {}
    end
    -- init call
    Cached:__init()
end

-- menu
Menu = {}
do
    -- init
    function Menu:__init()
        self.Main = nil
        self.Target = nil
        self.Orbwalker = nil
        WriteToFile('MenuElement/Gamsteron_Drawings.png', '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')
        WriteToFile('MenuElement/Gamsteron_Item_3072.png', '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')
        WriteToFile('MenuElement/Gamsteron_Loader.png', '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')
        WriteToFile('MenuElement/Gamsteron_Minion.png', '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')
        WriteToFile('MenuElement/Gamsteron_Orbwalker.png', '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')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerBarrier.png', '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')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerBoost.png', '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')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerDot.png', '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')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerExhaust.png', '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')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerFlash.png', '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')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerHaste.png', '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')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerHeal.png', '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')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerSmite.png', 'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAACXBIWXMAAAsTAAALEwEAmpwYAAAXz0lEQVRoga2af3Qc1ZXnP6pfrnZLTQvJPdKRkN22kSxG4FiRkSUkbBqDiX8kAc9mmcwZZhJz2IRwkuzgMJAlmQNxGMiGzU6WCQyDGQYPA5tsbIKIiTEIbAsJYdHCduPGwnYbWYqUtkS3Wy51qaqrtH9U9S9ZZvLH3KOj8/rVe1Xf773v3nffjxJZEGRRVETRsKxp05QFZBFFBJAFHCnNFmQJr4qqCIC6QCz3imQluAhAlQVVFssVEahZJK9pKn0nfD553gaar1bHxq3klOl01w0l13dBiZUre0yz6WZvYLkS2XfhyDtmx1YWXwVgaLKpWea0DWRmDKexOWVLpm2btj1tmoWIc2WHCbMuellyn6oL8tCBVYvQZUE37cLK2oACOOj9lwmJ83n06gJRN5hXAsvkwHIFiJ8y6xpd9IDiFRWvaGgWoJ+38gQKEAtg59SfQ6+IyFn1zyurFtEcoDeRVWG2f21AeTdywUEPJM5bOfRAxeJVTrPJTwaTCdNfLmcJKEBk3wWg88/mfsvhoPhEwEhZQBEouUCtSpGKXfSK5I4fwLNAdNDf2UQ4jm7azvhxntYskkfixug5s+oyofA96gJRXSAmU4Y3W9P2l/8Y/rdvOOWly0sDy9360N3lmAn+Iylx8RUMfaEEsQRRQM2yK5Eoy5aX+/Od269QN/+5PHTMGorYCRXA55F9Htkn2FWV5fqMkZzS/KVqrn15xgPE/uDtPhpIJDPRiSngthU1O/Y0PHjfIWDHTzrJvE3yVJZuea6vkREAO60BelJ3Kj8ZQsqhdySHPq8zCSWL3lc8ijb/udxwtfjqi+YcraiKrM8Y+oyhKvKcR91HA7E/uNpvrCwDdn80yn3xHT/p7N7/CZeShRVixrCmNcHjdTjkRMo57pwxk0M/L/S2Nnn733jR6fr3vDO66l+oYFtcJOGznIkEgeCfaLE/eBsrfUB0ItVYWda9f6h7/yehmxYXdfAvQyjJ/RIXegFrugj9sGuB4sGTg+6g90h4C2i40LMyFLHnogdAnzH8vlJA19Phszz7LkCo1O217aZY7FibU45OpIAH7+vpHcwSWLIB/3IAPebWaJOYqTkaOfQqw0NIooBYgmVTGH9kgRIJKeu4gWyfe7+7sH2TL/eK6C+SZeUMpwHKRVEQRAER0Epam67Jkpzw+MJ8dxlA4zV/AGBh46qKBYIB+N9R2msrH/9oCDjwvrj2Sysp3Z57v555wS1dhnpmpwiiqqAqI9GJfS+bAB5KVCnvA7n5SxGxRbxZ3ddAW7u8/XteAL/rlGODetf/0x30QHmpWqbKPlUBzNmWyFEtclRrusZbU5IfGJo1AXzz6ybg/4I//KgBNN+vHDhQCxx45QhgSPWh2zq7dx/q3t1TnrX8vU92hJrecMrd7wjR34wuWyEsXyECJWVKHn1u8lJERMklENf5q+uz6AsI7P32eK/klus84C0DfKriU5UD/csc9MAcAgMfiMA3vmY0Xe8Fxnqs6g5xyFr88J3PO23SVOfalxc43r2PGqHrbIdAXUl8eaMInIxaLoFC3TscxKz6vRI/+u7C9uuyM79fBcLPJsc/0OcQcNQP7NpVl/twY+lVuXIsmY/r/2ObUN0hOhym2pYCDodLEUhU0rtHz/5IAL/bY5z6yJZEAVFElAAkEB1vLgj8bU1qS7NqpBFVUfSIZDh5zOj7CFTVIwHIkqBJotdT7nhZz/ty4gKhVl+o1QfE9o7lQOjJ/CSy+//Gbu+8vWlT02RJJPBPz9X88IF/vT89daBnbyxPoHciTzh6JkrlVvc9Y939b134dNwu9yN5VYwMhTInZdjxdb9BUeKy78XpbEsBkCVRkVz372wxe953Y39ojQ+IXTnrqv9dkwpj8Eg+h4vsjTRtamra1JT6kwdSBw751nb61nZuPjsx9NYQMPTW0L03NgOPvxl22r/86siXN9e+/OrIdHeemJSbpBSJ3KyTqwx9TgVs3RZUwdItIHZmnhifQ39oQO55X6kC4MF/GNnxndrgmjxiv9cEchwieyOR30aaNjX51nX61nWOPPSIb21nww0NDTc0nHjrRP0N9Q2Dn/aeHpvnSwVyiQQtK6FV7ii3dTfenzyWn3dlSQQc9TvoH33a2/F5oy4beNu/enzb8vJgqwyEvusNiq7pBo8oTRubInsjL93z0o5NO5zK2r/7/shDj/iWfxlouKEBYLAPaAtW98XGyFpgLoG0jpxNFpxx4CnBK1DjA/D6wQ/ZMWbrNmmLvNHys3d1Y/C5u9NVEiePqIEl7mfaVzCuWuMfEhvXxj8t/+orW717woGp8Ial2lRv8ip/OTD82/66ra6jV266xTgeVa4vB/RdY0nQJdGjKtWlnuCF6kozoCf9ipa2SwGMDJo+nwW8Mt6s2X/+L8nWQfWuO9SLm80rHWtFwC5OaoLV3u4P4jtfi31+T7jh1mZgaE8493S4e7jOdU4Ev18su+S3ul8fv7iyiIBXxjs3+6L/A91KWN/8jjsPLF8snvrEntOmZpnfQd+5TgS2pMaOjKpHRlXg4Idm9wfxYJU3Nq4N7Qk33NrscDhXNjncPTznPcqSpWTOANYnaf44cQkYGRSJgHf+RgP95pP/oDkcli8WTy62CjnULPOv2bD0kQcN4NDbVs8BK3FdzR3XJlfW6MDZyUBsXAOCVd6hPYecLg23NjfcoA+/+UnPgz3D3cNWMiH6CzLng0XLgOjZ+GcR8OAOcTtDy+X0T7oPsnMG5Sr+FeroeX75knHHZkVXWRdSpl8ESF0WABqWph76TmroaN3aKy3AI4n73k8mK+TWm+XWDUpbyqrSVbCAcZp33x2+7eltAH5P3VZuUAKDd92jDR/2Va524X77hbLmRl9zY2o4tuvMiZ49b3Tcuh7QuxLA2+9GhctIZMF1bPDnh9DGJlrLCwhk8rm0I0eH7CNDVsM1IlB1BeNn3fr+93z97/nKVQ58LDocgP7XTaB1gxJc7429mc+Bo12Dhe+s3rKJpwuUffc2KAdS4ehUOArC/c8/1nnrTZvKmpH8hR3rgmrn+nIKfWDj1TBC/yStFfOZCoBdr5q3pcTqOqrrAFLTtF6b+vkTta3Xpm6/YiGwtt5++FVOxPJdguu9wTfmcAg3bmku4iAlUuHDo888BZQ1Nzr1NXfe9kB9O3Boz/5c432vjm3YXN1xo3/xUo9TU0Rg78g8oNMZCrnnFH8pWVtvOQT6Xzf79xmt/5XQo4Hu++M5DtGuwUICQCp8OBUeqLnzG77m1ZDMP7gA0HnrTTzP7l8/B2zYXH3L5mo9mteQlL4AsGWDzE1e+WMteNiMnweo9oOzIsuQ1PWyUgHwlYrREV31yNUVIpBIqROpslRKAyY0E+hNWnWt9tZTbigcfWqabQ8Cq24/VD7894ljHiAg2OgepDHAymimHvddVeq7ah2AHkUqMF9WdZ23eju/sDVXq5b3OoXYR2nXAltuuSh8FrvB1AW7rFS4uM3qVuWpJ6aB8TNi1RJrLCZWB+1r/37V6Btjo2+OA4meQ+UdneUdnUDNhB3/XX+ur5XRAFkNwGfFmc+WIj+96Wrxb7MrdAf9xa78H8pYTKi7mpr11TXrq997YDD5ziEHfXlHJ7oOXMzByYVHDoeB0XfyFrBqapxC756hwJWn7vje7XO+FTuh/7HoykqF2molNTU3kzvcb3zjnoWOEYDxM2J10AJq17tZsfl+USYbuKU1B93KaIoasDLayOFD7z2506mvuSYEjPaOA6clDejbMwQEO6JF0D9Kd7+SBEqC2Zn79C9VFrF1ixtjk6Xuul6V8Ki0NAgtDeJTr5hVkrpptdsnIdUCzXffHv7FS9GuCLAsdM0tP74DqRHBixLAiJOy5LKAuMALkMlrV89EgfiBWPxgbOhgsr6tvuKKCkBP6EA8no7H9ZOZKWDgtQjw67GNub59u144fkz3XSZQOIT29lkbvyi2XSf0vTM3U3CkZYXIK3O3gIDwL15qvvv2aNeDLnpHbA0jjuhVKyusGc2a0VwOBRL5UXf8YAyob2t10DvioI+f08nOzjs/3gG9wN6uE4A2bNTWyanzVup8wd7oPT8zT39RbO8QL0Vgjox9aqnZ7Yrffq0YPSB4AcQ8aGtGE7PJ69hbBwYf7gIC1wcB5lGLKwOvRXZ+7Obb99zVBWzcUu+7TExl93eLfKC3x2rvEB9/zIS5vtvSULTvNfapBVSvbho7HBk7HAHmQQ9YmpWZ6zZjbx0Y/OHDgdBtuZrJs5O5sjYtuOoHXN1z+LXIf/v24w56IIcekGYFNzjqs+L2H5i9v/B+63bhwWemPSqAv1QgAxfsilIxNgIXCAY5b4mJT/XWGwPxD8JjfUNA6MHNamm1ro8JggrYQnbendXMdH7cm8nBE8+cngwna268QVGCTqVxbszr803+3vJ6Ra9XnPxUj4673Vu2+Hr37338+zEgIanA2s9VaGcnTcsG0tOWPmPl9ayWWMzSHTZCzUqo2ewbnmvX3W8YjUsFZhmNaUDtUm88bjnog2sbDCPhoAcsI584FBrOQV/R7HdwmxNj5sQ44L06pGmW8+e0jE+ZgAO9ULZ0VncdKlpk5gl4BBub7rAJhJrlQgKNS4XoaSt62m5c6pqrJugFYgeHgtfXB9c2MJ9YppYjMBE+MfTMqxVLl1Q0+yfDScB3GQ76hStW2eD1ivFzJhA3DCBQJjscitB3VOXK6WlLT1t62pY8gp22BY/gOm532Aw1y8DGK9W9H+dyaqKnrRx6oHapd+S0BoR+sGXOZ2xbd9DbpuaoyEEPONAdC0z3jwP+zo3A5KiW133KuBi6I09/v9lRf3raAvS0DUg6lAh2hUzKYlwC6P2I5iuUVcv1vYOU+wFkhfi4yzC4iJqVfv/ihe89f2brz9rIuCTtgiRMNPpFXOvGXvxV7JAGBDu9jZVRIBwpG/zQl7Ka1iyvTY7oQCrpho1YInXinDv8tJm0sypJGFpsOv7rH7epV25L/ctWQM8AWLOWpltSmQDgE0llPXtwxGy+QomezXt6fNwOVAk5DjUr/cC1dyzxryhKKh0RMobTzoidmH77VdS6YKc32OkFwr8qG/zQN/ihb9Wfpmov94186m44ewUFiCVSsWQKRG0mDWgzefTN/mDoq9tjx3pzX9HSlqZbmm5LPtFFP5WN/qtqZWD3u2ZjrTtmAlVCoFp0CNSs9Nd+Lr/8mwM9VzZiJ4CF6zb7Zfe4pfuR+N5Bd8tx8EPfsur8drkiKkAsmXIUr83omqEDum0lTA04rRVlezn0gOQTgbz6geYrlPDZogSmqVmJj1kOE0f9nyGKrqXOniisiR3Suh+JA5TmK0cTU/kfklxAAAc94KD3y96kqXX/+09DX93Oi48DOfRAycZKgBM6gCKxqlrY1qLc06U3FuB8YVfV418bBzbf7W+4IShfHgDEhV5dCgKCZQCKmZ+MGM+vG5//Z//R192fg8lgrl6VCrZPpIJzFz0/eccuFFSTfHP/NuDhH3VX2ZF8V2CiYG90W4sS/n3R3Nl2vbtUqF+tNqxWBU/+Aw50QLTyccPS4k7ojB1Ldb84Gv1Y/emxJ47sC+/a/mzhaxMzBpCYMYGllzNHOtYket4tByoU93OjRvLGm3a+uX/bD38Qevohl8DQSDw/D0xmqJYABosJtF8vnzisA1vu9gNiAYEcbtE2c+gdAg564JqbVx3ZF165oXnlhuaHv/XcgVfyhnLQA90j+ekuVMn9/z3W0+cH2iuDwMSMNjnjmsjh8MW2pp/+qtupkRzohTI4VpTMta9VfvyFZP3qog0z58htjjjo7el4924tFskP8V3bnz3y+uAdj2/74c6GA7+ZePjOIQd90sjZTQRCtdaONnPVN6OH+vyO+h30QMUC72jWK2+8aecL3wtuWdPU9W4EkPQMog2gOvFVd6Oss6BuWyNwVg9W0fqlOrW2AkDwWoJsGViioojZSCLARJ8IySFt6Jfx7rM0XeUOPCU92LjaGor17fz6QOgrq9a21L452Ljzrt3RaBVwTQvAylZjZYdrmb5n/f+7q91JJVWVCknVM5aesetVdxoeSiZDPwo/to61Vf79Z5BSl9wtB9j+N0pvn1V3bUXdpTdbrOlJR4eTEW3ol3Hg9j9b2HSVAkSOG/3vmwnd8qtCLGl2P/1eCGLvjwY/X7PtewUf9rjoj/RU/LRrZa46nbE8kqhnLKBC9UzqaaBCVcd0/vZt1i+Bz95eb1vjzgN11+bRW4IMWKKSQ2+lJ+30ZPKkBtR/JQBUeI3IcSNy3IwcNynHrwrlqrjUr/hrKhz0AMzdGD3SU7HrsYZCRA501dkDz+Q5OPLGGR5bd5EFBsbyv9vbXN+ao34HvWgZ1kzSQQ9UNHmByYg2+aG2f9iIHM/HpWQ2ZjuRufvp94Kfr0mVsevJbIsL7fNqUM/YDgFVEvWso07qOrB+CT+5AUBiFq+IZqFnWO6hNmmO6bSUsbGW9o21QPtG9AyCpIqSKkoeUT+XDxnJWL58dmzgqDVw1Bo4alOaN+2CaRfK+AX71DlnqKieEit0V/M/90b2/iYOqJKbIW9oT997q/X4Q+7xQnmp7uge8GSSQK1EbSU7OnV1meW/2dRPCZK3aKWVl+DqojgjSp91RBDu09571xg46mraymBlFZYGVUY3UBVyNye6fzXuXxp/4rmme/7a5eCg/9n2JFcAIzkOOWlpTwMt7TpQ1ZxPk+f6wOEUQEtZEQFZ9WeRpefwDfdpg33aYJ+mF6QJDnqXg4RuuhwuyxII1Kp7X45v/HJg45cDDoH/tT1xS7sLq33dVPu6aO/bZUqpPvC2D2hZl2pZUZB6FBweFBEYmKKljJYyVvvmWgCwMrqd0UXJAxhj8ekPIr/u8w72aVwkVmZujcNhjux9OQ5s/FLgiW3znOS1r5uiVG9Zl8U9z+kMgOTex5q1VOyQyvCnBGDJrTKehcyk8NUC4oUz5BaHx6JA/2Hj0SdJlObR/5flcsMisStqAGk9PxV6cqUMxmze9JwcPqmP1TfI925Q9PxpBGqioE+hIgpVXQaw/4C6/6Aq+SQRSGUsnySA++H2NpGZ7CQ1U3RN5NBho+ew2TPgBpmVNcLKGnFljZhIcuJcPoKFlsjBcjGWsPpG5lle1VUK9deqDSuUix/9MeJAf+Og6vJKFe98uOHfmKKsphB9//5U//7UvkPTF7/x+fcMLIYm7PpKYWjCbqsVguUiECwXg4vyXpOatYDFi0TAH8yj10aRywAUH+jZ0yHV1XROfndA2HdQ3HdQVMlHlHkmslz4ZybFAvdyzc/vG+nfPwV0dMgdq+VHn3RpHBm1j4zagHPtYGjCvrdTvVTAWrxo/pBnTmFOuRzUhdlanZMfAZw8zKnD/OOZ+d9asr7MXY6VCXzlcoB796gAGbfDQI/x5D/pg+P2ts/JzdViumCdMFww6+mztNa5+HSdZwYN4M5VSqJgHFdXFoAoxFPgGrEJDg8LA8PiwFlRtyx9Vsw21wOq7JVEQCi4BSeBu5h0lmb17fmth4Ee46nHpgH8goM+PGbt3G8Cf7lGXnmF2BrMazQ3U/68xzhyzvWlb72m11cKK6vEldUiULjQU70A0d+bQOT33rXLOHCKA6fyinPELxiqYAMmAqBlLK8kmhnI3odwLQDUKrSXuuo/8Y711lsMvOP636xfGMyu6IsGXYF2CzfqC8eQXtDGX1BfXWBJa9YP/N3NhJ4sIqAWmMYh4FjAyY7k7A0bV/dk1d/1P42hXjtaYNY8+v8kWVUrj1+YJzp1f5PQ//msjlrGAkREWcKxQ0nID1AmUavyF1eqxxNWNGlFky7iCwaAmR1WRgm6CNkzleytUywLu/Dacv6yIWKB35ZL7v1lRSqyZDK79v3tfVV3PaV3Hc++xxYAa9YUS2QLO/+qWSF3TaOIgCoJOeiGlf/vEDBKmBYpOicr+GFfdIDm0HC+6szCpdnb13IxgencwXWD+sB1avXDcwkA9qwIODvRtu28pOCAwyeRyhC7UDRUjILpwSjBLEG2sQpB2whzcNsuK7kkSwAUyMV8M0PO+hdLzwm9q1zdchU5IzjoC7+YEzNjuwTKJFIXvTGH3rQxHC3OugjyIhVwcNqXACwUyN6wdgkUyqXQO9J1nByBOejnlf8PvLBZx7TfaLcAAAAASUVORK5CYII=')
        WriteToFile('MenuElement/Gamsteron_Spell_SummonerTeleport.png', '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')
        WriteToFile('MenuElement/Gamsteron_TargetSelector.png', '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')
        self.Main = MenuElement({id = "GGOrbwalker", name = "GG Orbwalker", type = MENU})
        self.Main:MenuElement({id = "Loader", name = "Loader", type = MENU, leftIcon = "/Gamsteron_Loader.png"})
        self.Main.Loader:MenuElement({id = "Items", name = "Items", value = true})
        self.Main.Loader:MenuElement({id = "SummonerSpells", name = "SummonerSpells", value = true})
        self.Target = self.Main:MenuElement({id = 'Target', name = 'Target Selector', type = MENU, leftIcon = '/Gamsteron_TargetSelector.png'})
        self.Target:MenuElement({id = 'Priorities', name = 'Priorities', type = MENU})
        self.Target:MenuElement({id = 'SelectedTarget', name = 'Selected Target', value = true})
        self.Target:MenuElement({id = 'OnlySelectedTarget', name = 'Only Selected Target', value = false})
        self.Target:MenuElement({id = 'SortMode' .. myHero.charName, name = 'Sort Mode', value = 1, drop = {'Auto', 'Closest', 'Near Mouse', 'Lowest HP', 'Lowest MaxHP', 'Highest Priority', 'Most Stack', 'Most AD', 'Most AP', 'Less Cast', 'Less Attack'}})
        self.Orbwalker = self.Main:MenuElement({id = 'Orbwalker', name = 'Orbwalker', type = MENU, leftIcon = '/Gamsteron_Orbwalker.png'})
        self.Orbwalker:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
        self.Orbwalker:MenuElement({id = 'MovementEnabled', name = 'Movement Enabled', value = true})
        self.Orbwalker:MenuElement({id = 'AttackEnabled', name = 'Attack Enabled', value = true})
        self.Orbwalker:MenuElement({id = 'Keys', name = 'Keys', type = MENU})
        self.Orbwalker.Keys:MenuElement({id = 'Combo', name = 'Combo Key', key = string.byte(' ')})
        self.Orbwalker.Keys:MenuElement({id = 'Harass', name = 'Harass Key', key = string.byte('C')})
        self.Orbwalker.Keys:MenuElement({id = 'LastHit', name = 'LastHit Key', key = string.byte('X')})
        self.Orbwalker.Keys:MenuElement({id = 'LaneClear', name = 'LaneClear Key', key = string.byte('V')})
        self.Orbwalker.Keys:MenuElement({id = 'Jungle', name = 'Jungle Key', key = string.byte('V')})
        self.Orbwalker.Keys:MenuElement({id = 'Flee', name = 'Flee Key', key = string.byte('A')})
        self.Orbwalker.Keys:MenuElement({id = 'HoldKey', name = 'Hold Key', key = string.byte('H'), tooltip = 'Should be same in game keybinds'})
        self.Orbwalker:MenuElement({id = 'General', name = 'General', type = MENU})
        self.Orbwalker.General:MenuElement({id = 'AttackResetting', name = 'Attack Resetting', value = true})
        self.Orbwalker.General:MenuElement({id = 'FastKiting', name = 'Fast Kiting', value = true})
        self.Orbwalker.General:MenuElement({id = 'LaneClearHeroes', name = 'LaneClear Heroes', value = true})
        self.Orbwalker.General:MenuElement({id = 'HoldRadius', name = 'Hold Radius', value = 0, min = 0, max = 250, step = 10})
        self.Orbwalker.General:MenuElement({id = 'ExtraWindUpTime', name = 'Extra WindUpTime', value = 0, min = -25, max = 75, step = 5})
        self.Orbwalker:MenuElement({id = 'RandomHumanizer', name = 'Random Humanizer', type = MENU})
        self.Orbwalker.RandomHumanizer:MenuElement({id = 'Min', name = 'Min', value = 100, min = 50, max = 300, step = 10})
        self.Orbwalker.RandomHumanizer:MenuElement({id = 'Max', name = 'Max', value = 150, min = 150, max = 400, step = 10})
        self.Orbwalker:MenuElement({id = 'Farming', name = 'Farming Settings', type = MENU})
        self.Orbwalker.Farming:MenuElement({id = 'LastHitPriority', name = 'Priorize Last Hit over Harass', value = true})
        self.Orbwalker.Farming:MenuElement({id = 'PushPriority', name = 'Priorize Push over Freeze', value = true})
        self.Orbwalker.Farming:MenuElement({id = 'ExtraFarmDelay', name = 'ExtraFarmDelay', value = 0, min = -80, max = 80, step = 10})
        if self.Main.Loader.SummonerSpells:Value() then
            self.SummonerSpellsLoaded = true
            self.SummonerSpells = self.Main:MenuElement({id = 'SummonerSpells', name = 'Summoner Spells', type = MENU, leftIcon = "/Gamsteron_Spell_SummonerDot.png"})
            self.SummonerSpells:MenuElement({id = 'Cleanse', name = 'Cleanse', type = MENU, leftIcon = '/Gamsteron_Spell_SummonerBoost.png'})
            self.SummonerSpells.Cleanse:MenuElement({id = 'BuffTypes', name = 'Buff Types', type = MENU})
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Slow', name = 'Slow: nasus w', value = true})--SLOW = 10 -> nasus W, zilean E
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Stun', name = 'Stun: sona r', value = true})--STUN = 5
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Snare', name = 'Snare: xayah e', value = true})--SNARE = 11
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Supress', name = 'Supress: warwick r', value = true})--SUPRESS = 24
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Knockup', name = 'Knockup: yasuo q3', value = true})--KNOCKUP = 29
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Fear', name = 'Fear: fiddle q', value = true})--FEAR = 21 -> fiddle Q, ...
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Charm', name = 'Charm: ahri e', value = true})--CHARM = 22 -> ahri E, ...
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Taunt', name = 'Taunt: rammus e', value = true})--TAUNT = 8 -> rammus E, ...
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Knockback', name = 'Knockback: alistar w', value = true})--KNOCKBACK = 30 -> alistar W, lee sin R, ...
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Blind', name = 'Blind: teemo q', value = true})--BLIND = 25 -> teemo Q
            self.SummonerSpells.Cleanse.BuffTypes:MenuElement({id = 'Disarm', name = 'Disarm: lulu w', value = true})--DISARM = 31 -> Lulu W
            self.SummonerSpells.Cleanse:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
            self.SummonerSpells.Cleanse:MenuElement({id = 'Count', name = 'Enemies Count', value = 1, min = 0, max = 5, step = 1})
            self.SummonerSpells.Cleanse:MenuElement({id = 'Distance', name = 'Enemies Distance < X', value = 1200, min = 0, max = 1500, step = 50})
            self.SummonerSpells.Cleanse:MenuElement({id = 'Duration', name = 'Buff Duration > X', value = 500, min = 0, max = 1000, step = 50})
        end
        if self.Main.Loader.Items:Value() then
            self.ItemsLoaded = true
            self.Main:MenuElement({id = 'Items', name = 'Items', type = MENU, leftIcon = '/Gamsteron_Item_3072.png'})
            self.Main.Items:MenuElement({id = 'Qss', name = 'Qss', type = MENU})
            self.Main.Items.Qss:MenuElement({id = 'BuffTypes', name = 'Buff Types', type = MENU})
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Slow', name = 'Slow: nasus w', value = true})--SLOW = 10 -> nasus W, zilean E
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Stun', name = 'Stun: sona r', value = true})--STUN = 5
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Snare', name = 'Snare: xayah e', value = true})--SNARE = 11
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Supress', name = 'Supress: warwick r', value = true})--SUPRESS = 24
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Knockup', name = 'Knockup: yasuo q3', value = true})--KNOCKUP = 29
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Fear', name = 'Fear: fiddle q', value = true})--FEAR = 21 -> fiddle Q, ...
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Charm', name = 'Charm: ahri e', value = true})--CHARM = 22 -> ahri E, ...
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Taunt', name = 'Taunt: rammus e', value = true})--TAUNT = 8 -> rammus E, ...
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Knockback', name = 'Knockback: alistar w', value = true})--KNOCKBACK = 30 -> alistar W, lee sin R, ...
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Blind', name = 'Blind: teemo q', value = true})--BLIND = 25 -> teemo Q
            self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Disarm', name = 'Disarm: lulu w', value = true})--DISARM = 31 -> Lulu W
            self.Main.Items.Qss:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
            self.Main.Items.Qss:MenuElement({id = 'Count', name = 'Enemies Count', value = 1, min = 0, max = 5, step = 1})
            self.Main.Items.Qss:MenuElement({id = 'Distance', name = 'Enemies Distance < X', value = 1200, min = 0, max = 1500, step = 50})
            self.Main.Items.Qss:MenuElement({id = 'Duration', name = 'Buff Duration > X', value = 500, min = 0, max = 1000, step = 50})
            self.Main.Items:MenuElement({id = 'Botrk', name = 'Botrk', type = MENU})
            self.Main.Items.Botrk:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
            self.Main.Items.Botrk:MenuElement({id = 'AntiMelee', name = 'Anti Melee', value = true})
            self.Main.Items.Botrk:MenuElement({id = 'HeroHealth', name = 'Hero Health % < X', value = 50, min = 0, max = 100, step = 1})
            self.Main.Items.Botrk:MenuElement({id = 'TargetDistance', name = 'Target Distance < X', value = 0, min = 0, max = 650, step = 10})
            self.Main.Items.Botrk:MenuElement({id = 'FleeRange', name = 'Flee Target Distance > X', value = 550, min = 300, max = 600, step = 10})
            self.Main.Items.Botrk:MenuElement({id = 'FleeHealth', name = 'Flee Target Health % < X', value = 50, min = 0, max = 100, step = 1})
            self.Main.Items:MenuElement({id = 'HexGun', name = 'Hex Gunblade', type = MENU})
            self.Main.Items.HexGun:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
            self.Main.Items.HexGun:MenuElement({id = 'AntiMelee', name = 'Anti Melee', value = true})
            self.Main.Items.HexGun:MenuElement({id = 'HeroHealth', name = 'Hero Health % < X', value = 50, min = 0, max = 100, step = 1})
            self.Main.Items.HexGun:MenuElement({id = 'TargetDistance', name = 'Target Distance < X', value = 300, min = 0, max = 700, step = 10})
            self.Main.Items.HexGun:MenuElement({id = 'FleeRange', name = 'Flee Target Distance > X', value = 550, min = 300, max = 600, step = 10})
            self.Main.Items.HexGun:MenuElement({id = 'FleeHealth', name = 'Flee Target Health % < X', value = 50, min = 0, max = 100, step = 1})
        end
        self.Main:MenuElement({id = 'Drawings', name = 'Drawings', type = MENU, leftIcon = '/Gamsteron_Drawings.png'})
        self.Main.Drawings:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
        self.Main.Drawings:MenuElement({id = 'Cursor', name = 'Cursor', value = true})
        self.Main.Drawings:MenuElement({id = 'Range', name = 'AutoAttack Range', value = true})
        self.Main.Drawings:MenuElement({id = 'EnemyRange', name = 'Enemy AutoAttack Range', value = true})
        self.Main.Drawings:MenuElement({id = 'HoldRadius', name = 'Hold Radius', value = false})
        self.Main.Drawings:MenuElement({id = 'LastHittableMinions', name = 'Last Hittable Minions', value = true})
        self.Main.Drawings:MenuElement({id = 'SelectedTarget', name = 'Selected Target', value = true})
        FlashHelper:CreateMenu(self.Main)
        self.Main:MenuElement({name = '', type = _G.SPACE, id = 'GeneralSpace'})
        self.Main:MenuElement({id = 'AttackTKey', name = 'Attack Target Key', key = string.byte('U'), tooltip = 'You should bind this one in ingame settings'})
        self.Main:MenuElement({id = 'Latency', name = 'Ping [ms]', value = 50, min = 0, max = 120, step = 1, callback = function(value) _G.LATENCY = value end})
        self.Main:MenuElement({id = 'SetCursorMultipleTimes', name = 'Set Cursor Position Multiple Times', value = false})
        self.Main:MenuElement({id = 'CursorDelay', name = 'Cursor Delay', value = 30, min = 30, max = 50, step = 1})
        self.Main:MenuElement({name = '', type = _G.SPACE, id = 'VersionSpaceA'})
        self.Main:MenuElement({name = 'Version  ' .. Version, type = _G.SPACE, id = 'VersionSpaceB'})
        _G.LATENCY = self.Main.Latency:Value()
    end
    -- init call
    Menu:__init()
end

-- color
Color = {}
do
    -- init
    function Color:__init()
        self.LightGreen = Draw.Color(255, 144, 238, 144)
        self.OrangeRed = Draw.Color(255, 255, 69, 0)
        self.Black = Draw.Color(255, 0, 0, 0)
        self.Red = Draw.Color(255, 255, 0, 0)
        self.Yellow = Draw.Color(255, 255, 255, 0)
        self.DarkRed = Draw.Color(255, 204, 0, 0)
        self.AlmostLastHitable = Draw.Color(255, 239, 159, 55)
        self.LastHitable = Draw.Color(255, 255, 255, 255)
        self.Range = Draw.Color(150, 49, 210, 0)
        self.EnemyRange = Draw.Color(150, 255, 0, 0)
        self.Cursor = Draw.Color(255, 0, 255, 0)
    end
    -- init call
    Color:__init()
end

-- action
Action = {}
do
    -- init
    function Action:__init()
        self.Tasks = {}
    end
    -- on tick
    function Action:OnTick()
        for i, task in pairs(self.Tasks) do
            if os.clock() >= task[2] then
                if task[1]() or os.clock() >= task[3] then
                    table_remove(self.Tasks, i)
                end
            end
        end
    end
    -- add
    function Action:Add(task, startTime, endTime)
        startTime = startTime or 0
        endTime = endTime or 10000
        table_insert(self.Tasks, {task, os.clock() + startTime, os.clock() + startTime + endTime})
    end
    -- init call
    Action:__init()
end

-- buff
Buff = {}
do
    -- get buff duration
    function Buff:GetBuffDuration(unit, name)
        name = name:lower()
        local result = 0
        local buff = nil
        local buffs = Cached:GetBuffs(unit)
        for i = 1, #buffs do
            buff = buffs[i]
            if buff.name:lower() == name then
                local duration = buff.duration
                if duration > result then
                    result = duration
                end
            end
        end
        return result
    end
    -- get buffs
    function Buff:GetBuffs(unit)
        return Cached:GetBuffs(unit)
    end
    -- get buff
    function Buff:GetBuff(unit, name)
        name = name:lower()
        local result = nil
        local buff = nil
        local buffs = Cached:GetBuffs(unit)
        for i = 1, #buffs do
            buff = buffs[i]
            if buff.name:lower() == name then
                result = buff
                break
            end
        end
        return result
    end
    -- has buff contains name
    function Buff:HasBuffContainsName(unit, name)
        name = name:lower()
        local buffs = Cached:GetBuffs(unit)
        local result = false
        for i = 1, #buffs do
            if buffs[i].name:lower():find(name) then
                result = true
                break
            end
        end
        return result
    end
    -- contains buffs
    function Buff:ContainsBuffs(unit, arr)
        local buffs = Cached:GetBuffs(unit)
        local result = false
        for i = 1, #buffs do
            if arr[buffs[i].name:lower()] then
                result = true
                break
            end
        end
        return result
    end
    -- has buff
    function Buff:HasBuff(unit, name)
        name = name:lower()
        local buffs = Cached:GetBuffs(unit)
        local result = false
        for i = 1, #buffs do
            if buffs[i].name:lower() == name then
                result = true
                break
            end
        end
        return result
    end
    -- has buff types
    function Buff:HasBuffTypes(unit, arr)
        local buffs = Cached:GetBuffs(unit)
        local result = false
        for i = 1, #buffs do
            if arr[buffs[i].type] then
                result = true
                break
            end
        end
        return result
    end
    -- get buff count
    function Buff:GetBuffCount(unit, name)
        name = name:lower()
        local result = 0
        local buff = nil
        local buffs = Cached:GetBuffs(unit)
        for i = 1, #buffs do
            buff = buffs[i]
            if buff.name:lower() == name then
                local count = buff.count
                if count > result then
                    result = count
                end
            end
        end
        return result
    end
    -- print
    function Buff:Print()
        local result = ''
        local buffs = self:GetBuffs(myHero)
        for i = 1, #buffs do
            local buff = buffs[i]
            result = result .. buff.name .. ': count=' .. buff.count .. '\n'
        end
        local pos2D = myHero.pos:To2D()
        local posX = pos2D.x - 50
        local posY = pos2D.y
        Draw.Text(result, posX + 50, posY - 15)
    end
end

-- damage
Damage = {}
do
    -- init
    function Damage:__init()
        self.BaseTurrets =
        {
            ["SRUAP_Turret_Order3"] = true,
            ["SRUAP_Turret_Order4"] = true,
            ["SRUAP_Turret_Chaos3"] = true,
            ["SRUAP_Turret_Chaos4"] = true,
        }
        self.TurretToMinionPercent =
        {
            ["SRU_ChaosMinionMelee"] = 0.43,
            ["SRU_ChaosMinionRanged"] = 0.68,
            ["SRU_ChaosMinionSiege"] = 0.14,
            ["SRU_ChaosMinionSuper"] = 0.05,
            ["SRU_OrderMinionMelee"] = 0.43,
            ["SRU_OrderMinionRanged"] = 0.68,
            ["SRU_OrderMinionSiege"] = 0.14,
            ["SRU_OrderMinionSuper"] = 0.05,
            ["HA_ChaosMinionMelee"] = 0.43,
            ["HA_ChaosMinionRanged"] = 0.68,
            ["HA_ChaosMinionSiege"] = 0.14,
            ["HA_ChaosMinionSuper"] = 0.05,
            ["HA_OrderMinionMelee"] = 0.43,
            ["HA_OrderMinionRanged"] = 0.68,
            ["HA_OrderMinionSiege"] = 0.14,
            ["HA_OrderMinionSuper"] = 0.05,
        }
        self.HeroStaticDamage =
        {
            ["Caitlyn"] = function(args)
                if Buff:HasBuff(args.From, "caitlynheadshot") then
                    if args.TargetIsMinion then
                        args.RawPhysical = args.RawPhysical + args.From.totalDamage * 1.5
                    else
                        --TODO
                    end
                end
            end,
            ["Corki"] = function(args)
                args.RawTotal = args.RawTotal * 0.5
                args.RawMagical = args.RawTotal
            end,
            ["Diana"] = function(args)
                if Buff:GetBuffCount(args.From, "dianapassivemarker") == 2 then
                    local level = args.From.levelData.lvl
                    args.RawMagical = args.RawMagical + math_max(15 + 5 * level, -10 + 10 * level, -60 + 15 * level, -125 + 20 * level, -200 + 25 * level) + 0.8 * args.From.ap
                end
            end,
            ["Draven"] = function(args)
                if Buff:HasBuff(args.From, "DravenSpinningAttack") then
                    local level = args.From:GetSpellData(_Q).level
                    args.RawPhysical = args.RawPhysical + 25 + 5 * level + (0.55 + 0.1 * level) * args.From.bonusDamage
                end
            end,
            ["Graves"] = function(args)
                local t = {70, 71, 72, 74, 75, 76, 78, 80, 81, 83, 85, 87, 89, 91, 95, 96, 97, 100}
                args.RawTotal = args.RawTotal * t[math_max(math_min(args.From.levelData.lvl, 18), 1)] * 0.01
            end,
            ["Jinx"] = function(args)
                if Buff:HasBuff(args.From, "JinxQ") then
                    args.RawPhysical = args.RawPhysical + args.From.totalDamage * 0.1
                end
            end,
            ["Kalista"] = function(args)
                args.RawPhysical = args.RawPhysical - args.From.totalDamage * 0.1
            end,
            ["Kayle"] = function(args)
                local level = args.From:GetSpellData(_E).level
                if level > 0 then
                    if Buff:HasBuff(args.From, "JudicatorRighteousFury") then
                        args.RawMagical = args.RawMagical + 10 + 10 * level + 0.3 * args.From.ap
                    else
                        args.RawMagical = args.RawMagical + 5 + 5 * level + 0.15 * args.From.ap
                    end
                end
            end,
            ["Nasus"] = function(args)
                if Buff:HasBuff(args.From, "NasusQ") then
                    args.RawPhysical = args.RawPhysical + math_max(Buff:GetBuffCount(args.From, "NasusQStacks"), 0) + 10 + 20 * args.From:GetSpellData(_Q).level
                end
            end,
            ["Thresh"] = function(args)
                local level = args.From:GetSpellData(_E).level
                if level > 0 then
                    local damage = math_max(Buff:GetBuffCount(args.From, "threshpassivesouls"), 0) + (0.5 + 0.3 * level) * args.From.totalDamage
                    if Buff:HasBuff(args.From, "threshqpassive4") then
                        damage = damage * 1
                    elseif Buff:HasBuff(args.From, "threshqpassive3") then
                        damage = damage * 0.5
                    elseif Buff:HasBuff(args.From, "threshqpassive2") then
                        damage = damage * 1 / 3
                    else
                        damage = damage * 0.25
                    end
                    args.RawMagical = args.RawMagical + damage
                end
            end,
            ["TwistedFate"] = function(args)
                if Buff:HasBuff(args.From, "cardmasterstackparticle") then
                    args.RawMagical = args.RawMagical + 30 + 25 * args.From:GetSpellData(_E).level + 0.5 * args.From.ap
                end
                if Buff:HasBuff(args.From, "BlueCardPreAttack") then
                    args.DamageType = DAMAGE_TYPE_MAGICAL
                    args.RawMagical = args.RawMagical + 20 + 20 * args.From:GetSpellData(_W).level + 0.5 * args.From.ap
                elseif Buff:HasBuff(args.From, "RedCardPreAttack") then
                    args.DamageType = DAMAGE_TYPE_MAGICAL
                    args.RawMagical = args.RawMagical + 15 + 15 * args.From:GetSpellData(_W).level + 0.5 * args.From.ap
                elseif Buff:HasBuff(args.From, "GoldCardPreAttack") then
                    args.DamageType = DAMAGE_TYPE_MAGICAL
                    args.RawMagical = args.RawMagical + 7.5 + 7.5 * args.From:GetSpellData(_W).level + 0.5 * args.From.ap
                end
            end,
            ["Varus"] = function(args)
                local level = args.From:GetSpellData(_W).level
                if level > 0 then
                    args.RawMagical = args.RawMagical + 6 + 4 * level + 0.25 * args.From.ap
                end
            end,
            ["Viktor"] = function(args)
                if Buff:HasBuff(args.From, "ViktorPowerTransferReturn") then
                    args.DamageType = DAMAGE_TYPE_MAGICAL
                    args.RawMagical = args.RawMagical + 20 * args.From:GetSpellData(_Q).level + 0.5 * args.From.ap
                end
            end,
            ["Vayne"] = function(args)
                if Buff:HasBuff(args.From, "vaynetumblebonus") then
                    args.RawPhysical = args.RawPhysical + (0.25 + 0.05 * args.From:GetSpellData(_Q).level) * args.From.totalDamage
                end
            end,
        }
        self.ItemStaticDamage =
        {
            [1043] = function(args)
                args.RawPhysical = args.RawPhysical + 15
            end,
            [2015] = function(args)
                if Buff:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
                    args.RawMagical = args.RawMagical + 40
                end
            end,
            [3057] = function(args)
                if Buff:HasBuff(args.From, "sheen") then
                    args.RawPhysical = args.RawPhysical + 1 * args.From.baseDamage
                end
            end,
            [3078] = function(args)
                if Buff:HasBuff(args.From, "sheen") then
                    args.RawPhysical = args.RawPhysical + 2 * args.From.baseDamage
                end
            end,
            [3085] = function(args)
                args.RawPhysical = args.RawPhysical + 15
            end,
            [3087] = function(args)
                if Buff:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
                    local t = {50, 50, 50, 50, 50, 56, 61, 67, 72, 77, 83, 88, 94, 99, 104, 110, 115, 120}
                    args.RawMagical = args.RawMagical + (1 + (args.TargetIsMinion and 1.2 or 0)) * t[math_max(math_min(args.From.levelData.lvl, 18), 1)]
                end
            end,
            [3091] = function(args)
                args.RawMagical = args.RawMagical + 40
            end,
            [3094] = function(args)
                if Buff:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
                    local t = {50, 50, 50, 50, 50, 58, 66, 75, 83, 92, 100, 109, 117, 126, 134, 143, 151, 160}
                    args.RawMagical = args.RawMagical + t[math_max(math_min(args.From.levelData.lvl, 18), 1)]
                end
            end,
            [3100] = function(args)
                if Buff:HasBuff(args.From, "lichbane") then
                    args.RawMagical = args.RawMagical + 0.75 * args.From.baseDamage + 0.5 * args.From.ap
                end
            end,
            [3115] = function(args)
                args.RawMagical = args.RawMagical + 15 + 0.15 * args.From.ap
            end,
            [3124] = function(args)
                args.CalculatedMagical = args.CalculatedMagical + 15
            end
        }
        self.HeroPassiveDamage =
        {
            ["Jhin"] = function(args)
                if Buff:HasBuff(args.From, "jhinpassiveattackbuff") then
                    args.CriticalStrike = true
                    args.RawPhysical = args.RawPhysical + math_min(0.25, 0.1 + 0.05 * math_ceil(args.From.levelData.lvl / 5)) * (args.Target.maxHealth - args.Target.health)
                end
            end,
            ["Lux"] = function(args)
                if Buff:HasBuff(args.Target, "LuxIlluminatingFraulein") then
                    args.RawMagical = 20 + args.From.levelData.lvl * 10 + args.From.ap * 0.2
                end
            end,
            ["Orianna"] = function(args)
                local level = math_ceil(args.From.levelData.lvl / 3)
                args.RawMagical = args.RawMagical + 2 + 8 * level + 0.15 * args.From.ap
                if args.Target.handle == args.From.attackData.target then
                    args.RawMagical = args.RawMagical + math_max(Buff:GetBuffCount(args.From, "orianapowerdaggerdisplay"), 0) * (0.4 + 1.6 * level + 0.03 * args.From.ap)
                end
            end,
            ["Quinn"] = function(args)
                if Buff:HasBuff(args.Target, "QuinnW") then
                    local level = args.From.levelData.lvl
                    args.RawPhysical = args.RawPhysical + 10 + level * 5 + (0.14 + 0.02 * level) * args.From.totalDamage
                end
            end,
            ["Teemo"] = function(args)
                local Edata = myHero:GetSpellData(_E)
                if Edata.level > 0 then
                    args.RawMagical = Edata.level * 10 + 0.30 * args.From.ap
                end
            end,
            ["Vayne"] = function(args)
                if Buff:GetBuffCount(args.Target, "VayneSilveredDebuff") == 2 then
                    local level = args.From:GetSpellData(_W).level
                    args.CalculatedTrue = args.CalculatedTrue + math_max((0.045 + 0.015 * level) * args.Target.maxHealth, 20 + 20 * level)
                end
            end,
            ["Zed"] = function(args)
                if 100 * args.Target.health / args.Target.maxHealth <= 50 and not Buff:HasBuff(args.From, "zedpassivecd") then
                    args.RawMagical = args.RawMagical + args.Target.maxHealth * (4 + 2 * math_ceil(args.From.levelData.lvl / 6)) * 0.01
                end
            end
        }
    end
    -- is base turret
    function Damage:IsBaseTurret(name)
        if self.BaseTurrets[name] then
            return true
        end
        return false
    end
    -- set hero static damage
    function Damage:SetHeroStaticDamage(args)
        local s = self.HeroStaticDamage[args.From.charName]
        if s then s(args) end
    end
    -- set item static damage
    function Damage:SetItemStaticDamage(id, args)
        local s = self.ItemStaticDamage[id]
        if s then s(args) end
    end
    -- set hero passive damage
    function Damage:SetHeroPassiveDamage(args)
        local s = self.HeroPassiveDamage[args.From.charName]
        if s then s(args) end
    end
    -- calculate damage
    function Damage:CalculateDamage(from, target, damageType, rawDamage, isAbility, isAutoAttackOrTargetted)
        if from == nil or target == nil then
            return 0
        end
        if isAbility == nil then
            isAbility = true
        end
        if isAutoAttackOrTargetted == nil then
            isAutoAttackOrTargetted = false
        end
        local fromIsMinion = from.type == Obj_AI_Minion
        local targetIsMinion = target.type == Obj_AI_Minion
        local baseResistance = 0
        local bonusResistance = 0
        local penetrationFlat = 0
        local penetrationPercent = 0
        local bonusPenetrationPercent = 0
        if damageType == DAMAGE_TYPE_PHYSICAL then
            baseResistance = math_max(target.armor - target.bonusArmor, 0)
            bonusResistance = target.bonusArmor
            penetrationFlat = from.armorPen
            penetrationPercent = from.armorPenPercent
            bonusPenetrationPercent = from.bonusArmorPenPercent
            -- Minions return wrong percent values.
            if fromIsMinion then
                penetrationFlat = 0
                penetrationPercent = 0
                bonusPenetrationPercent = 0
            elseif from.type == Obj_AI_Turret then
                penetrationPercent = self:IsBaseTurret(from.charName) and 0.75 or 0.3
                penetrationFlat = 0
                bonusPenetrationPercent = 0
            end
        elseif damageType == DAMAGE_TYPE_MAGICAL then
            baseResistance = math_max(target.magicResist - target.bonusMagicResist, 0)
            bonusResistance = target.bonusMagicResist
            penetrationFlat = from.magicPen
            penetrationPercent = from.magicPenPercent
            bonusPenetrationPercent = 0
        elseif damageType == DAMAGE_TYPE_TRUE then
            return rawDamage
        end
        local resistance = baseResistance + bonusResistance
        if resistance > 0 then
            if penetrationPercent > 0 then
                baseResistance = baseResistance * penetrationPercent
                bonusResistance = bonusResistance * penetrationPercent
            end
            if bonusPenetrationPercent > 0 then
                bonusResistance = bonusResistance * bonusPenetrationPercent
            end
            resistance = baseResistance + bonusResistance
            resistance = resistance - penetrationFlat
        end
        local percentMod = 1
        -- Penetration cant reduce resistance below 0.
        if resistance >= 0 then
            percentMod = percentMod * (100 / (100 + resistance))
        else
            percentMod = percentMod * (2 - 100 / (100 - resistance))
        end
        local flatPassive = 0
        local percentPassive = 1
        if fromIsMinion and targetIsMinion then
            percentPassive = percentPassive * (1 + from.bonusDamagePercent)
        end
        local flatReceived = 0
        if not isAbility and targetIsMinion then
            flatReceived = flatReceived - target.flatDamageReduction
        end
        return math_max(percentPassive * percentMod * (rawDamage + flatPassive) + flatReceived, 0)
    end
    -- get static auto attack damage
    function Damage:GetStaticAutoAttackDamage(from, targetIsMinion)
        local args = {
            From = from,
            RawTotal = from.totalDamage,
            RawPhysical = 0,
            RawMagical = 0,
            CalculatedTrue = 0,
            CalculatedPhysical = 0,
            CalculatedMagical = 0,
            DamageType = DAMAGE_TYPE_PHYSICAL,
            TargetIsMinion = targetIsMinion
        }
        self:SetHeroStaticDamage(args)
        local HashSet = {}
        for i = 1, #ItemSlots do
            local slot = ItemSlots[i]
            local item = args.From:GetItemData(slot)
            if item ~= nil and item.itemID > 0 then
                if HashSet[item.itemID] == nil then
                    self:SetItemStaticDamage(item.itemID, args)
                    HashSet[item.itemID] = true
                end
            end
        end
        return args
    end
    -- get hero auto attack damage
    function Damage:GetHeroAutoAttackDamage(from, target, static)
        local args = {
            From = from,
            Target = target,
            RawTotal = static.RawTotal,
            RawPhysical = static.RawPhysical,
            RawMagical = static.RawMagical,
            CalculatedTrue = static.CalculatedTrue,
            CalculatedPhysical = static.CalculatedPhysical,
            CalculatedMagical = static.CalculatedMagical,
            DamageType = static.DamageType,
            TargetIsMinion = target.type == Obj_AI_Minion,
            CriticalStrike = false,
        }
        if args.TargetIsMinion and args.Target.maxHealth <= 6 then
            return 1
        end
        self:SetHeroPassiveDamage(args)
        if args.DamageType == DAMAGE_TYPE_PHYSICAL then
            args.RawPhysical = args.RawPhysical + args.RawTotal
        elseif args.DamageType == DAMAGE_TYPE_MAGICAL then
            args.RawMagical = args.RawMagical + args.RawTotal
        elseif args.DamageType == DAMAGE_TYPE_TRUE then
            args.CalculatedTrue = args.CalculatedTrue + args.RawTotal
        end
        if args.RawPhysical > 0 then
            args.CalculatedPhysical = args.CalculatedPhysical + self:CalculateDamage(from, target, DAMAGE_TYPE_PHYSICAL, args.RawPhysical, false, args.DamageType == DAMAGE_TYPE_PHYSICAL)
        end
        if args.RawMagical > 0 then
            args.CalculatedMagical = args.CalculatedMagical + self:CalculateDamage(from, target, DAMAGE_TYPE_MAGICAL, args.RawMagical, false, args.DamageType == DAMAGE_TYPE_MAGICAL)
        end
        local percentMod = 1
        if args.From.critChance - 1 == 0 or args.CriticalStrike then
            percentMod = percentMod * self:GetCriticalStrikePercent(args.From)
        end
        return percentMod * args.CalculatedPhysical + args.CalculatedMagical + args.CalculatedTrue
    end
    -- get auto attack damage
    function Damage:GetAutoAttackDamage(from, target, respectPassives)
        if respectPassives == nil then
            respectPassives = true
        end
        if from == nil or target == nil then
            return 0
        end
        local targetIsMinion = target.type == Obj_AI_Minion
        if respectPassives and from.type == Obj_AI_Hero then
            return self:GetHeroAutoAttackDamage(from, target, self:GetStaticAutoAttackDamage(from, targetIsMinion))
        end
        if targetIsMinion then
            if target.maxHealth <= 6 then
                return 1
            end
            if from.type == Obj_AI_Turret and not self:IsBaseTurret(from.charName) then
                local percentMod = self.TurretToMinionPercent[target.charName]
                if percentMod ~= nil then
                    return target.maxHealth * percentMod
                end
            end
        end
        return self:CalculateDamage(from, target, DAMAGE_TYPE_PHYSICAL, from.totalDamage, false, true)
    end
    -- get critical strike percent
    function Damage:GetCriticalStrikePercent(from)
        local baseCriticalDamage = 2
        local percentMod = 1
        local fixedMod = 0
        if from.charName == "Jhin" then
            percentMod = 0.75
        elseif from.charName == "XinZhao" then
            baseCriticalDamage = baseCriticalDamage - (0.875 - 0.125 * from:GetSpellData(_W).level)
        elseif from.charName == "Yasuo" then
            percentMod = 0.9
        end
        return baseCriticalDamage * percentMod
    end
    -- init call
    Damage:__init()
end

-- data
Data = {}
do
    -- init
    function Data:__init()
        self.JungleTeam = 300
        self.AllyTeam = myHero.team
        self.EnemyTeam = self.JungleTeam - myHero.team
        self.HeroName = myHero.charName:lower()
        self.ChannelingBuffs =
        {
            ['caitlyn'] = function()
                return Buff:HasBuff(myHero, 'CaitlynAceintheHole')
            end,
            ['fiddlesticks'] = function()
                return Buff:HasBuff(myHero, 'Drain') or Buff:HasBuff(myHero, 'Crowstorm')
            end,
            ['galio'] = function()
                return Buff:HasBuff(myHero, 'GalioIdolOfDurand')
            end,
            ['janna'] = function()
                return Buff:HasBuff(myHero, 'ReapTheWhirlwind')
            end,
            ['kaisa'] = function()
                return Buff:HasBuff(myHero, 'KaisaE')
            end,
            ['karthus'] = function()
                return Buff:HasBuff(myHero, 'karthusfallenonecastsound')
            end,
            ['katarina'] = function()
                return Buff:HasBuff(myHero, 'katarinarsound')
            end,
            ['lucian'] = function()
                return Buff:HasBuff(myHero, 'LucianR')
            end,
            ['malzahar'] = function()
                return Buff:HasBuff(myHero, 'alzaharnethergraspsound')
            end,
            ['masteryi'] = function()
                return Buff:HasBuff(myHero, 'Meditate')
            end,
            ['missfortune'] = function()
                return Buff:HasBuff(myHero, 'missfortunebulletsound')
            end,
            ['nunu'] = function()
                return Buff:HasBuff(myHero, 'AbsoluteZero')
            end,
            ['pantheon'] = function()
                return Buff:HasBuff(myHero, 'pantheonesound') or Buff:HasBuff(myHero, 'PantheonRJump')
            end,
            ['shen'] = function()
                return Buff:HasBuff(myHero, 'shenstandunitedlock')
            end,
            ['twistedfate'] = function()
                return Buff:HasBuff(myHero, 'Destiny')
            end,
            ['urgot'] = function()
                return Buff:HasBuff(myHero, 'UrgotSwap2')
            end,
            ['varus'] = function()
                return Buff:HasBuff(myHero, 'VarusQ')
            end,
            ['velkoz'] = function()
                return Buff:HasBuff(myHero, 'VelkozR')
            end,
            ['vi'] = function()
                return Buff:HasBuff(myHero, 'ViQ')
            end,
            ['vladimir'] = function()
                return Buff:HasBuff(myHero, 'VladimirE')
            end,
            ['warwick'] = function()
                return Buff:HasBuff(myHero, 'infiniteduresssound')
            end,
            ['xerath'] = function()
                return Buff:HasBuff(myHero, 'XerathArcanopulseChargeUp') or Buff:HasBuff(myHero, 'XerathLocusOfPower2')
            end,
        }
        self.SpecialWindup =
        {
            ['twistedfate'] = function()
                if Buff:HasBuff(myHero, 'BlueCardPreAttack') or Buff:HasBuff(myHero, 'RedCardPreAttack') or Buff:HasBuff(myHero, 'GoldCardPreAttack') then
                    return 0.125
                end
                return nil
            end,
            ['jayce'] = function()
                if Buff:HasBuff(myHero, 'JayceHyperCharge') then
                    return 0.125
                end
                return nil
            end
        }
        self.AllowMovement =
        {
            ['kaisa'] = function()
                return Buff:HasBuff(myHero, 'KaisaE')
            end,
            ['lucian'] = function()
                return Buff:HasBuff(myHero, 'LucianR')
            end,
            ['varus'] = function()
                return Buff:HasBuff(myHero, 'VarusQ')
            end,
            ['vi'] = function()
                return Buff:HasBuff(myHero, 'ViQ')
            end,
            ['vladimir'] = function()
                return Buff:HasBuff(myHero, 'VladimirE')
            end,
            ['xerath'] = function()
                return Buff:HasBuff(myHero, 'XerathArcanopulseChargeUp')
            end,
        }
        self.DisableAttackBuffs =
        {
            ['urgot'] = function()
                return Buff:HasBuff(myHero, 'UrgotW')
            end,
            ['darius'] = function()
                return Buff:HasBuff(myHero, 'dariusqcast')
            end,
            ['graves'] = function()
                if myHero.hudAmmo == 0 then
                    return true
                end
                return false
            end,
            ['jhin'] = function()
                if Buff:HasBuff(myHero, 'JhinPassiveReload') then
                    return true
                end
                if myHero.hudAmmo == 0 then
                    return true
                end
                return false
            end,
        }
        self.SpecialMissileSpeeds =
        {
            ['aphelios'] = function()
                if Buff:HasBuff(myHero, 'ApheliosCrescendumManager') then
                    return math.huge
                end
                return 1500
            end,
            ['caitlyn'] = function()
                if Buff:HasBuff(myHero, 'caitlynheadshot') then
                    return 3000
                end
                return nil
            end,
            ['graves'] = function()
                return 3800
            end,
            ['illaoi'] = function()
                if Buff:HasBuff(myHero, 'IllaoiW') then
                    return 1600
                end
                return nil
            end,
            ['jayce'] = function()
                if Buff:HasBuff(myHero, 'jaycestancegun') then
                    return 2000
                end
                return nil
            end,
            ['jhin'] = function()
                if Buff:HasBuff(myHero, 'jhinpassiveattackbuff') then
                    return 3000
                end
                return nil
            end,
            ['jinx'] = function()
                if Buff:HasBuff(myHero, 'JinxQ') then
                    return 2000
                end
                return nil
            end,
            ['poppy'] = function()
                if Buff:HasBuff(myHero, 'poppypassivebuff') then
                    return 1600
                end
                return nil
            end,
            ['twitch'] = function()
                if Buff:HasBuff(myHero, 'TwitchFullAutomatic') then
                    return 4000
                end
                return nil
            end,
            ['kayle'] = function()
                if Buff:HasBuff(myHero, 'KayleE') then
                    return 1750
                end
                return nil
            end,
        }
        --10.19.1
        self.HEROES = {aatrox = {3, true, 0.651}, ahri = {4, false, 0.668}, akali = {4, true, 0.625}, alistar = {1, true, 0.625}, amumu = {1, true, 0.736}, anivia = {4, false, 0.625}, annie = {4, false, 0.579}, aphelios = {5, false, 0.64}, ashe = {5, false, 0.658}, aurelionsol = {4, false, 0.625}, azir = {4, true, 0.625}, bard = {3, false, 0.625}, blitzcrank = {1, true, 0.625}, brand = {4, false, 0.625}, braum = {1, true, 0.644}, caitlyn = {5, false, 0.681}, camille = {3, true, 0.644}, cassiopeia = {4, false, 0.647}, chogath = {1, true, 0.625}, corki = {5, false, 0.638}, darius = {2, true, 0.625}, diana = {4, true, 0.625}, draven = {5, false, 0.679}, drmundo = {1, true, 0.721}, ekko = {4, true, 0.688}, elise = {3, false, 0.625}, evelynn = {4, true, 0.667}, ezreal = {5, false, 0.625}, fiddlesticks = {3, false, 0.625}, fiora = {3, true, 0.69}, fizz = {4, true, 0.658}, galio = {1, true, 0.625}, gangplank = {4, true, 0.658}, garen = {1, true, 0.625}, gnar = {1, false, 0.625}, gragas = {2, true, 0.675}, graves = {4, false, 0.475}, hecarim = {2, true, 0.67}, heimerdinger = {3, false, 0.625}, illaoi = {3, true, 0.571}, irelia = {3, true, 0.656}, ivern = {1, true, 0.644}, janna = {2, false, 0.625}, jarvaniv = {3, true, 0.658}, jax = {3, true, 0.638}, jayce = {4, false, 0.658}, jhin = {5, false, 0.625}, jinx = {5, false, 0.625}, kaisa = {5, false, 0.644}, kalista = {5, false, 0.694}, karma = {4, false, 0.625}, karthus = {4, false, 0.625}, kassadin = {4, true, 0.64}, katarina = {4, true, 0.658}, kayle = {4, false, 0.625}, kayn = {4, true, 0.669}, kennen = {4, false, 0.625}, khazix = {4, true, 0.668}, kindred = {4, false, 0.625}, kled = {2, true, 0.625}, kogmaw = {5, false, 0.665}, leblanc = {4, false, 0.625}, leesin = {3, true, 0.651}, leona = {1, true, 0.625}, lillia = {4, false, 0.625}, lissandra = {4, false, 0.656}, lucian = {5, false, 0.638}, lulu = {3, false, 0.625}, lux = {4, false, 0.669}, malphite = {1, true, 0.736}, malzahar = {3, false, 0.625}, maokai = {2, true, 0.8}, masteryi = {5, true, 0.679}, missfortune = {5, false, 0.656}, monkeyking = {3, true, 0.711}, mordekaiser = {4, true, 0.625}, morgana = {3, false, 0.625}, nami = {3, false, 0.644}, nasus = {2, true, 0.638}, nautilus = {1, true, 0.706}, neeko = {4, false, 0.625}, nidalee = {4, false, 0.638}, nocturne = {4, true, 0.721}, nunu = {2, true, 0.625}, olaf = {2, true, 0.694}, orianna = {4, false, 0.658}, ornn = {2, true, 0.625}, pantheon = {3, true, 0.644}, poppy = {2, true, 0.625}, pyke = {4, true, 0.667}, qiyana = {4, true, 0.625}, quinn = {5, false, 0.668}, rakan = {3, true, 0.635}, rammus = {1, true, 0.656}, reksai = {2, true, 0.667}, renekton = {2, true, 0.665}, rengar = {4, true, 0.667}, riven = {4, true, 0.625}, rumble = {4, true, 0.644}, ryze = {4, false, 0.625}, samira = {5, false, 0.658}, sejuani = {2, true, 0.688} , seraphine = {2, false, 0.625}, senna = {5, true, 0.625}, sett = {2, true, 0.625}, shaco = {4, true, 0.694}, shen = {1, true, 0.751}, shyvana = {2, true, 0.658}, singed = {1, true, 0.613}, sion = {1, true, 0.679}, sivir = {5, false, 0.625}, skarner = {2, true, 0.625}, sona = {3, false, 0.644}, soraka = {3, false, 0.625}, swain = {3, false, 0.625}, sylas = {4, true, 0.645}, syndra = {4, false, 0.625}, tahmkench = {1, true, 0.658}, taliyah = {4, false, 0.625}, talon = {4, true, 0.625}, taric = {1, true, 0.625}, teemo = {4, false, 0.69}, thresh = {1, true, 0.625}, tristana = {5, false, 0.656}, trundle = {2, true, 0.67}, tryndamere = {4, true, 0.67}, twistedfate = {4, false, 0.651}, twitch = {5, false, 0.679}, udyr = {2, true, 0.658}, urgot = {2, true, 0.625}, varus = {5, false, 0.658}, vayne = {5, false, 0.658}, veigar = {4, false, 0.625}, velkoz = {4, false, 0.625}, vi = {2, true, 0.644}, viktor = {4, false, 0.658}, vladimir = {3, false, 0.658}, volibear = {2, true, 0.625}, warwick = {2, true, 0.638}, xayah = {5, false, 0.625}, xerath = {4, false, 0.625}, xinzhao = {3, true, 0.645}, yasuo = {4, true, 0.697}, yone = {4, true, 0.625}, yorick = {2, true, 0.625}, yuumi = {3, false, 0.625}, zac = {1, true, 0.736}, zed = {4, true, 0.651}, ziggs = {4, false, 0.656}, zilean = {3, false, 0.625}, zoe = {4, false, 0.625}, zyra = {2, false, 0.625}, }
        self.HeroSpecialMelees =
        {
            ['elise'] = function()
                return myHero.range < 200
            end,
            ['gnar'] = function()
                return myHero.range < 200
            end,
            ['jayce'] = function()
                return myHero.range < 200
            end,
            ['kayle'] = function()
                return myHero.range < 200
            end,
            ['nidalee'] = function()
                return myHero.range < 200
            end,
        }
        self.IsAttackSpell =
        {
            ['CaitlynHeadshotMissile'] = true,
            ['GarenQAttack'] = true,
            ['KennenMegaProc'] = true,
            ['MordekaiserQAttack'] = true,
            ['MordekaiserQAttack1'] = true,
            ['MordekaiserQAttack2'] = true,
            ['QuinnWEnhanced'] = true,
            ['BlueCardPreAttack'] = true,
            ['RedCardPreAttack'] = true,
            ['GoldCardPreAttack'] = true,
            -- 9.9 patch
            ['RenektonSuperExecute'] = true,
            ['RenektonExecute'] = true,
            ['XinZhaoQThrust1'] = true,
            ['XinZhaoQThrust2'] = true,
            ['XinZhaoQThrust3'] = true,
            ['MasterYiDoubleStrike'] = true,
        }
        self.IsNotAttack =
        {
            ['GravesAutoAttackRecoil'] = true,
            ['LeonaShieldOfDaybreakAttack'] = true,
        }
        self.MinionRange =
        {
            ["SRU_ChaosMinionMelee"] = 110,
            ["SRU_ChaosMinionRanged"] = 550,
            ["SRU_ChaosMinionSiege"] = 300,
            ["SRU_ChaosMinionSuper"] = 170,
            ["SRU_OrderMinionMelee"] = 110,
            ["SRU_OrderMinionRanged"] = 550,
            ["SRU_OrderMinionSiege"] = 300,
            ["SRU_OrderMinionSuper"] = 170,
            ["HA_ChaosMinionMelee"] = 110,
            ["HA_ChaosMinionRanged"] = 550,
            ["HA_ChaosMinionSiege"] = 300,
            ["HA_ChaosMinionSuper"] = 170,
            ["HA_OrderMinionMelee"] = 110,
            ["HA_OrderMinionRanged"] = 550,
            ["HA_OrderMinionSiege"] = 300,
            ["HA_OrderMinionSuper"] = 170,
        }
        self.ExtraAttackRanges =
        {
            ["caitlyn"] = function(target)
                if target and Buff:HasBuff(target, "caitlynyordletrapinternal") then
                    return 650
                end
                return 0
            end,
        }
        self.AttackResets =
        {
            ["ashe"] = {Slot = _Q, Key = HK_Q},
            ["blitzcrank"] = {Slot = _E, Key = HK_E},
            ["camille"] = {Slot = _Q, Key = HK_Q},
            ["chogath"] = {Slot = _E, Key = HK_E},
            ["darius"] = {Slot = _W, Key = HK_W},
            ["drmundo"] = {Slot = _E, Key = HK_E},
            ["elise"] = {Slot = _W, Key = HK_W, Name = "EliseSpiderW"},
            ["fiora"] = {Slot = _E, Key = HK_E},
            ["garen"] = {Slot = _Q, Key = HK_Q},
            ["graves"] = {Slot = _E, Key = HK_E, OnCast = true, CanCancel = true},
            ["kassadin"] = {Slot = _W, Key = HK_W},
            ["illaoi"] = {Slot = _W, Key = HK_W},
            ["jax"] = {Slot = _W, Key = HK_W},
            ["jayce"] = {Slot = _W, Key = HK_W, Name = "JayceHyperCharge"},
            ["kayle"] = {Slot = _E, Key = HK_E},
            ["katarina"] = {Slot = _E, Key = HK_E, CanCancel = true, OnCast = true},
            ["kindred"] = {Slot = _Q, Key = HK_Q},
            ["leona"] = {Slot = _Q, Key = HK_Q},
            ['lucian'] = {Slot = _E, Key = HK_E, OnCast = true, CanCancel = true}, -- Buff = {["lucianpassivebuff"] = true},
            ["masteryi"] = {Slot = _W, Key = HK_W},
            ["mordekaiser"] = {Slot = _Q, Key = HK_Q},
            ["nautilus"] = {Slot = _W, Key = HK_W},
            ["nidalee"] = {Slot = _Q, Key = HK_Q, Name = "Takedown"},
            ["nasus"] = {Slot = _Q, Key = HK_Q},
            ["reksai"] = {Slot = _Q, Key = HK_Q, Name = "RekSaiQ"},
            ["renekton"] = {Slot = _W, Key = HK_W},
            ["rengar"] = {Slot = _Q, Key = HK_Q},
            ["riven"] = {Slot = _Q, Key = HK_Q},
            -- RIVEN BUFFS ["riven"] = {'riventricleavesoundone', 'riventricleavesoundtwo', 'riventricleavesoundthree'},
            ["sejuani"] = {Slot = _E, Key = HK_E, ReadyCheck = true, ActiveCheck = true, SpellName = "SejuaniE2"},
            ["shyvana"] = {Slot = _Q, Key = HK_Q},
            ["sivir"] = {Slot = _W, Key = HK_W},
            ["trundle"] = {Slot = _Q, Key = HK_Q},
            ["vayne"] = {Slot = _Q, Key = HK_Q, Buff = {["vaynetumblebonus"] = true}, CanCancel = true},
            ["vi"] = {Slot = _E, Key = HK_E},
            ["volibear"] = {Slot = _Q, Key = HK_Q},
            ["monkeyking"] = {Slot = _Q, Key = HK_Q},
            ["xinzhao"] = {Slot = _Q, Key = HK_Q},
            ["yorick"] = {Slot = _Q, Key = HK_Q},
        }
        self.IsChanneling = self.ChannelingBuffs[self.HeroName]
        self.CanDisableMove = self.AllowMovement[self.HeroName]
        self.CanDisableAttack = self.DisableAttackBuffs[self.HeroName]
        self.SpecialMissileSpeed = self.SpecialMissileSpeeds[self.HeroName]
        self.IsHeroMelee = self.HEROES[self.HeroName][2]
        self.IsHeroSpecialMelee = self.HeroSpecialMelees[self.HeroName]
        self.ExtraAttackRange = self.ExtraAttackRanges[self.HeroName]
        self.AttackReset = self.AttackResets[self.HeroName]
        if self.AttackReset == nil then
            return
        end
        self.AttackResetSuccess = false
        self.AttackResetSlot = self.AttackReset.Slot
        self.AttackResetBuff = self.AttackReset.Buff
        self.AttackResetOnCast = self.AttackReset.OnCast
        self.AttackResetCanCancel = self.AttackReset.CanCancel
        self.AttackResetTimer = 0
        self.AttackResetTimeout = 0
    end
    -- wnd msg
    function Data:WndMsg(msg, wParam)
        if self.AttackReset == nil or self.AttackResetCanCancel then
            return
        end
        local AttackResetKey = self.AttackReset.Key
        local AttackResetActiveSpell = self.AttackReset.ActiveCheck
        local AttackResetIsReady = self.AttackReset.ReadyCheck
        local AttackResetName = self.AttackReset.Name
        local AttackResetSpellName = self.AttackReset.SpellName
        local X, T = 0, 0
        if not self.AttackResetSuccess and not Control.IsKeyDown(HK_LUS) and not Game.IsChatOpen() and wParam == AttackResetKey then
            local checkNum = Object.IsRiven and 400 or 600
            if GetTickCount() <= self.AttackResetTimer + checkNum then
                return
            end
            if AttackResetIsReady and Game.CanUseSpell(self.AttackResetSlot) ~= 0 then
                return
            end
            local spellData = myHero:GetSpellData(self.AttackResetSlot)
            if (Object.IsRiven or spellData.mana <= myHero.mana) and spellData.currentCd == 0 and (not AttackResetName or spellData.name == AttackResetName) then
                if AttackResetActiveSpell then
                    self.AttackResetTimer = GetTickCount()
                    local startTime = GetTickCount() + 400
                    Action:Add(function()
                        local s = myHero.activeSpell
                        if s and s.valid and s.name == AttackResetSpellName then
                            self.AttackResetTimer = GetTickCount()
                            self.AttackResetSuccess = true
                            --print("Attack Reset ActiveSpell")
                            --print(startTime - GetTickCount())
                            return true
                        end
                        if GetTickCount() < startTime then
                            return false
                        end
                        return true
                    end)
                    return
                end
                self.AttackResetTimer = GetTickCount()
                if Object.IsKindred then
                    Orbwalker:SetMovement(false)
                    local setTime = GetTickCount() + 550
                    -- SET ATTACK
                    Action:Add(function()
                        if GetTickCount() < setTime then
                            return false
                        end
                        --print("Move True Kindred")
                        Orbwalker:SetMovement(true)
                        return true
                    end)
                    return
                end
                self.AttackResetSuccess = true
                --print("Attack Reset")
                -- RIVEN
                if Object.IsRiven then
                    X = X + 1
                    if X == 1 then
                        T = GetTickCount()
                    end
                    if X == 3 then
                        --print(GetTickCount() - T)
                    end
                    local isThree = Buff:HasBuff(myHero, 'riventricleavesoundtwo')
                    if isThree then
                        X = 0
                    end
                    local riven_start = GetTickCount() + 450 + (isThree and 100 or 0) - LATENCY
                    Action:Add(function()
                        if GetTickCount() < riven_start then
                            if Cursor.Step == 0 then
                                Movement.MoveTimer = 0
                                Control.Move()
                            end
                            return false
                        end
                        Orbwalker:SetAttack(true)
                        Attack.Reset = true
                        return true
                    end)
                    Orbwalker:SetAttack(false)
                    return
                end
            end
        end
    end
    -- id equals
    function Data:IdEquals(a, b)
        if a == nil or b == nil then
            return false
        end
        return a.networkID == b.networkID
    end
    -- get auto attack range
    function Data:GetAutoAttackRange(from, target)
        local result = from.range
        local fromType = from.type
        if fromType == Obj_AI_Minion then
            local fromName = from.charName
            result = self.MinionRange[fromName] ~= nil and self.MinionRange[fromName] or 0
        elseif fromType == Obj_AI_Turret then
            result = 775
        end
        if target then
            local targetType = target.type
            if targetType == Obj_AI_Barracks then
                result = result + 270
            elseif targetType == Obj_AI_Nexus then
                result = result + 380
            else
                result = result + from.boundingRadius + target.boundingRadius
                if targetType == Obj_AI_Hero and self.ExtraAttackRange then
                    result = result + self.ExtraAttackRange(target)
                end
            end
        else
            result = result + from.boundingRadius + 35
        end
        return result
    end
    -- is in auto attack range
    function Data:IsInAutoAttackRange(from, target, extrarange)
        local range = extrarange or 0
        return IsInRange(from.pos, target.pos, self:GetAutoAttackRange(from, target) + range)
    end
    -- is in auto attack range 2
    function Data:IsInAutoAttackRange2(from, target, extrarange)
        local range = self:GetAutoAttackRange(from, target) + (extrarange or 0)
        if IsInRange(from.pos, target.pos, range) and IsInRange(from.pos, target.posTo, range) then
            return true
        end
        return false
    end
    -- can reset attack
    function Data:CanResetAttack()
        if self.AttackReset == nil then
            return false
        end
        if self.AttackResetCanCancel then
            if self.AttackResetOnCast then
                if self.AttackResetBuff == nil or Buff:HasBuff(myHero, self.AttackResetBuff) then
                    local spellData = myHero:GetSpellData(self.AttackResetSlot)
                    local startTime = spellData.castTime - spellData.cd
                    if not self.AttackResetSuccess and Game.Timer() - startTime > 0.075 and Game.Timer() - startTime < 0.5 and GetTickCount() > self.AttackResetTimer + 1000 then
                        --print('Reset Cast, Buff ' .. tostring(os.clock()))
                        self.AttackResetSuccess = true
                        self.AttackResetTimeout = GetTickCount()
                        self.AttackResetTimer = GetTickCount()
                        return true
                    end
                    if self.AttackResetSuccess and GetTickCount() > self.AttackResetTimeout + 200 then
                        --print('Reset Timeout')
                        self.AttackResetSuccess = false
                    end
                    return false
                end
            elseif Buff:ContainsBuffs(myHero, self.AttackResetBuff) then
                if not self.AttackResetSuccess then
                    self.AttackResetSuccess = true
                    --print('Reset Buff')
                    return true
                end
                return false
            end
            if self.AttackResetSuccess then
                --print('Remove Reset')
                self.AttackResetSuccess = false
            end
            return false
        end
        if self.AttackResetSuccess then
            self.AttackResetSuccess = false
            --print("AA RESET STOP !")
            return true
        end
        return false
    end
    -- is attack
    function Data:IsAttack(name)
        if self.IsAttackSpell[name] then
            return true
        end
        if self.IsNotAttack[name] then
            return false
        end
        return name:lower():find('attack')
    end
    -- get latency
    function Data:GetLatency()
        return LATENCY * 0.001
    end
    -- hero can move
    function Data:HeroCanMove()
        if self.IsChanneling and self.IsChanneling() then
            if self.CanDisableMove == nil or (not self.CanDisableMove()) then
                return false
            end
        end
        return true
    end
    -- hero can attack
    function Data:HeroCanAttack()
        if self.IsChanneling and self.IsChanneling() then
            return false
        end
        if self.CanDisableAttack and self.CanDisableAttack() then
            return false
        end
        if Buff:HasBuffTypes(myHero, {[25] = true, [31] = true}) then
            return false
        end
        return true
    end
    -- is melee
    function Data:IsMelee()
        if self.IsHeroMelee or (self.IsHeroSpecialMelee and self.IsHeroSpecialMelee()) then
            return true
        end
        return false
    end
    -- get hero priority
    function Data:GetHeroPriority(name)
        local p = self.HEROES[name:lower()]
        return p and p[1] or 5
    end
    -- get hero data
    function Data:GetHeroData(obj)
        if obj == nil then
            return {}
        end
        local id = obj.networkID
        if id == nil or id <= 0 then
            return {}
        end
        local name = obj.charName
        if name == nil then
            return {}
        end
        if self.HEROES[name:lower()] == nil and not name:lower():find("dummy") then
            return {}
        end
        local Team = obj.team
        local IsEnemy = obj.isEnemy
        local IsAlly = obj.isAlly
        if Team == nil or Team < 100 or Team > 200 or IsEnemy == nil or IsAlly == nil or IsEnemy == IsAlly then
            return {}
        end
        return
        {
            valid = true,
            isEnemy = IsEnemy,
            isAlly = IsAlly,
            networkID = id,
            charName = name,
            team = Team,
            unit = obj,
        }
    end
    -- get total shield
    function Data:GetTotalShield(obj)
        local shieldAd, shieldAp
        shieldAd = obj.shieldAD
        shieldAp = obj.shieldAP
        return (shieldAd and shieldAd or 0) + (shieldAp and shieldAp or 0)
    end
    -- get building bbox
    function Data:GetBuildingBBox(unit)
        local type = unit.type
        if type == Obj_AI_Barracks then
            return 270
        end
        if type == Obj_AI_Nexus then
            return 380
        end
        return 0
    end
    -- stop
    function Data:Stop()
        return Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading) or (JustEvade and JustEvade.Evading()) or (not Game.IsOnTop())
    end
    -- init call
    Data:__init()
end

-- spell
Spell = {}
do
    -- init
    function Spell:__init()
        self.QTimer = 0
        self.WTimer = 0
        self.ETimer = 0
        self.RTimer = 0
        self.QkTimer = 0
        self.WkTimer = 0
        self.EkTimer = 0
        self.RkTimer = 0
        self.OnSpellCastCb = {}
        self.ControlKeyDown = _G.Control.KeyDown
        _G.Control.KeyDown = function(key)
            if key == HK_Q then
                local timer = Game.Timer()
                if timer > self.QTimer + 0.5 and GameCanUseSpell(_Q) == 0 then
                    self.QTimer = timer
                    for i = 1, #self.OnSpellCastCb do
                        self.OnSpellCastCb[i](_Q)
                    end
                end
            end
            if key == HK_W then
                local timer = Game.Timer()
                if timer > self.WTimer + 0.5 and GameCanUseSpell(_W) == 0 then
                    self.WTimer = timer
                    for i = 1, #self.OnSpellCastCb do
                        self.OnSpellCastCb[i](_W)
                    end
                end
            end
            if key == HK_E then
                local timer = Game.Timer()
                if timer > self.ETimer + 0.5 and GameCanUseSpell(_E) == 0 then
                    self.ETimer = timer
                    for i = 1, #self.OnSpellCastCb do
                        self.OnSpellCastCb[i](_E)
                    end
                end
            end
            if key == HK_R then
                local timer = Game.Timer()
                if timer > self.RTimer + 0.5 and GameCanUseSpell(_R) == 0 then
                    self.RTimer = timer
                    for i = 1, #self.OnSpellCastCb do
                        self.OnSpellCastCb[i](_R)
                    end
                end
            end
            self.ControlKeyDown(key)
        end
    end
    -- on spell cast
    function Spell:OnSpellCast(cb)
        table_insert(self.OnSpellCastCb, cb)
    end
    -- wnd msg
    function Spell:WndMsg(msg, wParam)
        local timer = Game.Timer()
        if wParam == HK_Q then
            if timer > self.QkTimer + 0.5 and GameCanUseSpell(_Q) == 0 then
                self.QkTimer = timer
            end
            return
        end
        if wParam == HK_W then
            if timer > self.WkTimer + 0.5 and GameCanUseSpell(_W) == 0 then
                self.WkTimer = timer
            end
            return
        end
        if wParam == HK_E then
            if timer > self.EkTimer + 0.5 and GameCanUseSpell(_E) == 0 then
                self.EkTimer = timer
            end
            return
        end
        if wParam == HK_R then
            if timer > self.RkTimer + 0.5 and GameCanUseSpell(_R) == 0 then
                self.RkTimer = timer
            end
            return
        end
    end
    -- is ready
    function Spell:IsReady(spell, delays)
        if Cursor.Step > 0 then
            return false
        end
        if not self:CanTakeAction(delays) then
            return false
        end
        return GameCanUseSpell(spell) == 0
    end
    -- check spell delays
    function Spell:CanTakeAction(delays)
        if delays == nil then
            return true
        end
        local t = Game.Timer()
        local q = t - delays.q
        local w = t - delays.w
        local e = t - delays.e
        local r = t - delays.r
        if q < self.QkTimer or q < self.QTimer then
            return false
        end
        if w < self.WkTimer or w < self.WTimer then
            return false
        end
        if e < self.EkTimer or e < self.ETimer then
            return false
        end
        if r < self.RkTimer or r < self.RTimer then
            return false
        end
        return true
    end
    -- spell clear
    function Spell:SpellClear(spell, spelldata, isReady, canLastHit, canLaneClear, getDamage)
        -- class
        local c = {}
        -- init
        function c:__init()
            self.HK = 0
            self.SpellPrediction = spelldata
            self.Radius = spelldata.Radius
            self.Delay = spelldata.Delay
            self.Speed = spelldata.Speed
            self.Range = spelldata.Range
            self.ShouldWaitTime = 0
            self.IsLastHitable = false
            self.LastHitHandle = 0
            self.LaneClearHandle = 0
            self.FarmMinions = {}
            if spell == _Q then
                self.HK = HK_Q
            elseif spell == _W then
                self.HK = HK_W
            elseif spell == _E then
                self.HK = HK_E
            elseif spell == _R then
                self.HK = HK_R
            end
        end
        -- get last hit targets
        function c:GetLastHitTargets()
            local result = {}
            for i, minion in pairs(self.FarmMinions) do
                if minion.LastHitable then
                    local unit = minion.Minion
                    if unit.handle ~= Health.LastHitHandle then
                        table_insert(result, unit)
                    end
                end
            end
            return result
        end
        -- get lane clear targets
        function c:GetLaneClearTargets()
            local result = {}
            for i, minion in pairs(self.FarmMinions) do
                local unit = minion.Minion
                if unit.handle ~= Health.LaneClearHandle then
                    table_insert(result, unit)
                end
            end
            return result
        end
        -- should wait
        function c:ShouldWait()
            return Game.Timer() <= self.ShouldWaitTime + 1
        end
        -- set last hitable
        function c:SetLastHitable(target, time, damage)
            local hpPred = Health:GetPrediction(target, time)
            local lastHitable = false
            local almostLastHitable = false
            if hpPred - damage < 0 then
                lastHitable = true
                self.IsLastHitable = true
            elseif Health:GetPrediction(target, myHero:GetSpellData(spell).cd + (time * 3)) - damage < 0 then
                almostLastHitable = true
                self.ShouldWaitTime = Game.Timer()
            end
            return {LastHitable = lastHitable, Unkillable = hpPred < 0, Time = time, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = target}
        end
        -- reset
        function c:Reset()
            for i = 1, #self.FarmMinions do
                table_remove(self.FarmMinions, i)
            end
            self.IsLastHitable = false
            self.LastHitHandle = 0
            self.LaneClearHandle = 0
        end
        -- tick
        function c:Tick()
            if Cursor.Step > 0 or Orbwalker:IsAutoAttacking() or not isReady() then
                return
            end
            local isLastHit = canLastHit() and (Orbwalker.Modes[ORBWALKER_MODE_LASTHIT] or Orbwalker.Modes[ORBWALKER_MODE_LANECLEAR])
            local isLaneClear = canLaneClear() and Orbwalker.Modes[ORBWALKER_MODE_LANECLEAR]
            if not isLastHit and not isLaneClear then
                return
            end
            if myHero:GetSpellData(spell).level == 0 then
                return
            end
            if myHero.mana < myHero:GetSpellData(spell).mana then
                return
            end
            if Game.CanUseSpell(spell) ~= 0 and myHero:GetSpellData(spell).currentCd > 0.5 then
                return
            end
            local targets = Object:GetEnemyMinions(self.Range, false, true)
            for i = 1, #targets do
                local target = targets[i]
                table_insert(self.FarmMinions, self:SetLastHitable(target, self.Delay + target.distance / self.Speed + Data:GetLatency(), getDamage()))
            end
            if self.IsLastHitable and (isLastHit or isLaneClear) then
                local targets = self:GetLastHitTargets()
                for i = 1, #targets do
                    local unit = targets[i]
                    if unit.alive then
                        --self.SpellPrediction:GetPrediction(unit, myHero)
                        if Control.CastSpell(self.HK, unit.pos) then
                            --if self.SpellPrediction:CanHit() and Control.CastSpell(self.HK, self.SpellPrediction.CastPosition) then
                            self.LastHitHandle = unit.handle
                            Orbwalker:SetAttack(false)
                            Action:Add(function()
                                Orbwalker:SetAttack(true)
                            end, self.Delay + (unit.distance / self.Speed) + 0.05, 0)
                            break
                        end
                    end
                end
            end
            if isLaneClear and self.LastHitHandle == 0 and not self:ShouldWait() then
                local targets = self:GetLaneClearTargets()
                for i = 1, #targets do
                    local unit = targets[i]
                    if unit.alive then
                        --self.SpellPrediction:GetPrediction(unit, myHero)
                        if Control.CastSpell(self.HK, unit.pos) then
                            --if self.SpellPrediction:CanHit() and Control.CastSpell(self.HK, self.SpellPrediction.CastPosition) then
                            self.LaneClearHandle = unit.handle
                        end
                    end
                end
            end
            local targets = self.FarmMinions
            for i = 1, #targets do
                local minion = targets[i]
                if minion.LastHitable then
                    Draw.Circle(minion.Minion.pos, 50, 1, Draw.Color(150, 255, 255, 255))
                elseif minion.AlmostLastHitable then
                    Draw.Circle(minion.Minion.pos, 50, 1, Draw.Color(150, 239, 159, 55))
                end
            end
        end
        -- init call
        c:__init()
        Health:AddSpell(c)
    end
    -- init call
    Spell:__init()
end

-- summoner spell
SummonerSpell = {}
do
    -- init
    function SummonerSpell:__init()
        self.SpellNames =
        {
            'SummonerHeal', --1 heal
            'SummonerHaste', --2 ghost
            'SummonerBarrier', --3 barrier
            'SummonerExhaust', --4 exhaust
            'SummonerFlash', --5 flash
            'SummonerTeleport', --6 teleport
            'SummonerSmite', --7 smite
            'SummonerBoost', --8 cleanse
            'SummonerDot', --9 ignite
        }
        self.Spell =
        {
            {
                Id = 0,
                Ready = false,
            },
            {
                Id = 0,
                Ready = false,
            },
        }
        self.CleanseStartTime = GetTickCount()
        if Menu.SummonerSpellsLoaded then
            self.MenuCleanse = Menu.SummonerSpells.Cleanse
            self.MenuCleanseBuffs = Menu.SummonerSpells.Cleanse.BuffTypes
        end
    end
    -- on tick
    function SummonerSpell:OnTick()
        if not Menu.SummonerSpellsLoaded then
            return
        end
        if Cursor.Step > 0 then
            return
        end
        local sd1 = myHero:GetSpellData(SUMMONER_1)
        local sd2 = myHero:GetSpellData(SUMMONER_2)
        local success1 = false
        local success2 = false
        for i = 1, 9 do
            if not success1 and sd1.name == self.SpellNames[i] then
                self.Spell[1].Id = i
                self.Spell[1].Ready = sd1.currentCd == 0 and Game.CanUseSpell(SUMMONER_1) == 0
                success1 = true
            elseif not success2 and sd2.name == self.SpellNames[i] then
                self.Spell[2].Id = i
                self.Spell[2].Ready = sd2.currentCd == 0 and Game.CanUseSpell(SUMMONER_2) == 0
                success2 = true
            end
        end
        if not success1 and not success2 then
            return
        end
        if not success1 then
            self.Spell[1].Ready = false
        end
        if not success2 then
            self.Spell[2].Ready = false
        end
        local s1 = self.Spell[1]
        local s2 = self.Spell[2]
        if not s1.Ready and not s2.Ready then
            return
        end
        self:UseCleanse(s1, s2)
    end
    -- use cleanse
    function SummonerSpell:UseCleanse(s1, s2)
        local hk
        if s1.Id == 8 and s1.Ready then hk = HK_SUMMONER_1 end
        if s2.Id == 8 and s2.Ready then hk = HK_SUMMONER_2 end
        if hk == nil then return false end
        if GetTickCount() < Item.CleanseStartTime + 200 then return false end
        if not self.MenuCleanse.Enabled:Value() then
            return false
        end
        local enemiesCount = 0
        local menuDistance = self.MenuCleanse.Distance:Value()
        local cachedHeroes = Cached:GetHeroes()
        for i = 1, #cachedHeroes do
            local hero = cachedHeroes[i]
            if hero.isEnemy and hero.distance <= menuDistance then
                enemiesCount = enemiesCount + 1
            end
        end
        if enemiesCount < self.MenuCleanse.Count:Value() then
            return false
        end
        local menuDuration = self.MenuCleanse.Duration:Value() * 0.001
        local menuBuffs = {
            [5] = self.MenuCleanseBuffs.Stun:Value(),
            [11] = self.MenuCleanseBuffs.Snare:Value(),
            [24] = self.MenuCleanseBuffs.Supress:Value(),
            [29] = self.MenuCleanseBuffs.Knockup:Value(),
            [21] = self.MenuCleanseBuffs.Fear:Value(),
            [22] = self.MenuCleanseBuffs.Charm:Value(),
            [8] = self.MenuCleanseBuffs.Taunt:Value(),
            [30] = self.MenuCleanseBuffs.Knockback:Value(),
            [25] = self.MenuCleanseBuffs.Blind:Value(),
            [31] = self.MenuCleanseBuffs.Disarm:Value(),
        }
        local casted = false
        local buffs = Buff:GetBuffs(myHero)
        for i = 1, #buffs do
            local buff = buffs[i]
            if buff.duration >= menuDuration and menuBuffs[buff.type] then
                casted = true
                Control.CastSpell(hk)
                self.CleanseStartTime = GetTickCount()
                break
            end
        end
        if not casted and self.MenuCleanseBuffs.Slow:Value() then
            local ms = myHero.ms
            for i = 1, #buffs do
                local buff = buffs[i]
                if buff.type == 10 and buff.duration >= 1 and ms <= 200 then
                    casted = true
                    Control.CastSpell(hk)
                    self.CleanseStartTime = GetTickCount()
                    break
                end
            end
        end
        return casted
    end
    -- init call
    SummonerSpell:__init()
end

-- item
Item = {}
do
    -- init
    function Item:__init()
        self.ItemBotrk = {3153, 3144, 3389}
        self.ItemQss = {3139, 3140}
        self.ItemGunblade = 3146
        self.CachedItems = {}
        self.Hotkey = nil
        self.CleanseStartTime = GetTickCount()
        if Menu.ItemsLoaded then
            self.MenuQss = Menu.Main.Items.Qss
            self.MenuQssBuffs = Menu.Main.Items.Qss.BuffTypes
            self.MenuBotrk = Menu.Main.Items.Botrk
            self.MenuGunblade = Menu.Main.Items.HexGun
        end
    end
    -- on tick
    function Item:OnTick()
        if not Menu.ItemsLoaded then
            return
        end
        self.CachedItems = {}
        if self:UseQss() then
            return
        end
        if Orbwalker.Modes[ORBWALKER_MODE_COMBO] then
            if self:UseGunblade() then
                return
            end
            if self:UseBotrk() then
                return
            end
        end
    end
    -- get item by id
    function Item:GetItemById(unit, id)
        local networkID = unit.networkID
        if self.CachedItems[networkID] == nil then
            local t = {}
            for i = 1, #ItemSlots do
                local slot = ItemSlots[i]
                local item = unit:GetItemData(slot)
                if item ~= nil and item.itemID ~= nil and item.itemID > 0 then
                    t[item.itemID] = i
                end
            end
            self.CachedItems[networkID] = t
        end
        return self.CachedItems[networkID][id]
    end
    -- is ready
    function Item:IsReady(unit, id)
        local item = self:GetItemById(unit, id)
        if item and myHero:GetSpellData(ItemSlots[item]).currentCd == 0 then
            self.Hotkey = ItemKeys[item]
            return true
        end
        return false
    end
    -- use botrk
    function Item:UseBotrk()
        if not self.MenuBotrk.Enabled:Value() then
            return false
        end
        local botrkReady = false
        for _, id in pairs(self.ItemBotrk) do
            if self:IsReady(myHero, id) then
                botrkReady = true
                break
            end
        end
        if not botrkReady then
            return false
        end
        local bbox = myHero.boundingRadius
        local target = Target:GetTarget(550 + bbox, 0, true)
        if target == nil then
            return false
        end
        if target.distance < self.MenuBotrk.TargetDistance:Value() then
            Control.CastSpell(self.Hotkey, target)
            return true
        end
        if self.MenuBotrk.AntiMelee:Value() then
            local meleeHeroes = {}
            local cachedHeroes = Cached:GetHeroes()
            for i = 1, #cachedHeroes do
                local hero = cachedHeroes[i]
                if hero.isEnemy then
                    local heroRange = hero.range
                    if heroRange < 400 and hero.distance < heroRange + bbox + hero.boundingRadius then
                        table_insert(meleeHeroes, hero)
                    end
                end
            end
            if #meleeHeroes > 0 then
                table_sort(meleeHeroes, function(a, b) return a.health + (a.totalDamage * 2) + (a.attackSpeed * 100) > b.health + (b.totalDamage * 2) + (b.attackSpeed * 100) end)
                Control.CastSpell(self.Hotkey, meleeHeroes[1])
                return true
            end
        end
        local myHeroHealth = 100 * (myHero.health / myHero.maxHealth)
        if myHeroHealth <= self.MenuBotrk.HeroHealth:Value() then
            Control.CastSpell(self.Hotkey, target)
            return true
        end
        if target.distance >= self.MenuBotrk.FleeRange:Value() and 100 * (target.health / target.maxHealth) <= self.MenuBotrk.FleeHealth:Value() and IsFacing(myHero, target, 90) and not IsFacing(target, myHero, 90) then
            Control.CastSpell(self.Hotkey, target)
            return true
        end
        return false
    end
    -- use gun blade
    function Item:UseGunblade()
        if not self.MenuGunblade.Enabled:Value() then
            return false
        end
        if not self:IsReady(myHero, self.ItemGunblade) then
            return false
        end
        local target = Target:GetTarget(700, 1, false)
        if target == nil then
            return false
        end
        if target.distance < self.MenuGunblade.TargetDistance:Value() then
            Control.CastSpell(self.Hotkey, target)
            return true
        end
        if self.MenuGunblade.AntiMelee:Value() then
            local meleeHeroes = {}
            local bbox = myHero.boundingRadius
            local cachedHeroes = Cached:GetHeroes()
            for i = 1, #cachedHeroes do
                local hero = cachedHeroes[i]
                if hero.isEnemy then
                    local heroRange = hero.range
                    if heroRange < 400 and hero.distance < heroRange + bbox + hero.boundingRadius then
                        table_insert(meleeHeroes, hero)
                    end
                end
            end
            if #meleeHeroes > 0 then
                table_sort(meleeHeroes, function(a, b) return a.health + (a.totalDamage * 2) + (a.attackSpeed * 100) > b.health + (b.totalDamage * 2) + (b.attackSpeed * 100) end)
                Control.CastSpell(self.Hotkey, meleeHeroes[1])
                return true
            end
        end
        local myHeroHealth = 100 * (myHero.health / myHero.maxHealth)
        if myHeroHealth <= self.MenuGunblade.HeroHealth:Value() then
            Control.CastSpell(self.Hotkey, target)
            return true
        end
        if target.distance >= self.MenuGunblade.FleeRange:Value() and 100 * (target.health / target.maxHealth) <= self.MenuGunblade.FleeHealth:Value() and IsFacing(myHero, target, 90) and not IsFacing(target, myHero, 90) then
            Control.CastSpell(self.Hotkey, target)
            return true
        end
        return false
    end
    -- use qss
    function Item:UseQss()
        if GetTickCount() < SummonerSpell.CleanseStartTime + 200 then return false end
        if not self.MenuQss.Enabled:Value() then
            return false
        end
        local qssReady = false
        for _, id in pairs(self.ItemQss) do
            if self:IsReady(myHero, id) then
                qssReady = true
                break
            end
        end
        if not qssReady then
            return false
        end
        local enemiesCount = 0
        local menuDistance = self.MenuQss.Distance:Value()
        local cachedHeroes = Cached:GetHeroes()
        for i = 1, #cachedHeroes do
            local hero = cachedHeroes[i]
            if hero.isEnemy and hero.distance <= menuDistance then
                enemiesCount = enemiesCount + 1
            end
        end
        if enemiesCount < self.MenuQss.Count:Value() then
            return false
        end
        local menuDuration = self.MenuQss.Duration:Value() * 0.001
        local menuBuffs = {
            [5] = self.MenuQssBuffs.Stun:Value(),
            [11] = self.MenuQssBuffs.Snare:Value(),
            [24] = self.MenuQssBuffs.Supress:Value(),
            [29] = self.MenuQssBuffs.Knockup:Value(),
            [21] = self.MenuQssBuffs.Fear:Value(),
            [22] = self.MenuQssBuffs.Charm:Value(),
            [8] = self.MenuQssBuffs.Taunt:Value(),
            [30] = self.MenuQssBuffs.Knockback:Value(),
            [25] = self.MenuQssBuffs.Blind:Value(),
            [31] = self.MenuQssBuffs.Disarm:Value(),
        }
        local casted = false
        local buffs = Buff:GetBuffs(myHero)
        for i = 1, #buffs do
            local buff = buffs[i]
            if buff.duration >= menuDuration and menuBuffs[buff.type] then
                casted = true
                Control.CastSpell(self.Hotkey)
                self.CleanseStartTime = GetTickCount()
                break
            end
        end
        if not casted and self.MenuQssBuffs.Slow:Value() then
            local ms = myHero.ms
            for i = 1, #buffs do
                local buff = buffs[i]
                if buff.type == 10 and buff.duration >= 1 and ms <= 200 then
                    casted = true
                    Control.CastSpell(self.Hotkey)
                    self.CleanseStartTime = GetTickCount()
                    break
                end
            end
        end
        return casted
    end
    -- has item
    function Item:HasItem
        (unit, id)
        return self:GetItemById(unit, id) ~= nil
    end
    -- init call
    Item:__init()
end

-- object
Object = {}
do
    -- init
    function Object:__init()
        self.UndyingBuffs =
        {
            ['zhonyasringshield'] = true,
            ['kindredrnodeathbuff'] = true,
            ['ChronoShift'] = true,
            ['UndyingRage'] = true,
            ['JaxCounterStrike'] = true,
        }
        self.AllyBuildings = {}
        self.EnemyBuildings = {}
        self.AllyHeroesInGame = {}
        self.EnemyHeroesInGame = {}
        self.EnemyHeroCb = {}
        self.AllyHeroCb = {}
        self.CachedHeroes = {}
        self.CachedMinions = {}
        self.CachedTurrets = {}
        self.CachedWards = {}
        self.IsKalista = myHero.charName == "Kalista"
        self.IsCaitlyn = myHero.charName == "Caitlyn"
        self.IsRiven = myHero.charName == "Riven"
        self.IsKindred = myHero.charName == "Kindred"
        self:OnEnemyHeroLoad(function(args)
            if args.charName == 'Kayle' then
                self.UndyingBuffs['JudicatorIntervention'] = true
                return
            end
            if args.charName == 'Taric' then
                self.UndyingBuffs['TaricR'] = true
                return
            end
            if args.charName == 'Kindred' then
                self.UndyingBuffs['kindredrnodeathbuff'] = true
                return
            end
            if args.charName == 'Zilean' then
                self.UndyingBuffs['ChronoShift'] = true
                self.UndyingBuffs['chronorevive'] = true
                return
            end
            if args.charName == 'Tryndamere' then
                self.UndyingBuffs['UndyingRage'] = true
                return
            end
            if args.charName == 'Jax' then
                self.UndyingBuffs['JaxCounterStrike'] = true
                return
            end
            if args.charName == 'Fiora' then
                self.UndyingBuffs['FioraW'] = true
                return
            end
            if args.charName == 'Aatrox' then
                self.UndyingBuffs['aatroxpassivedeath'] = true
                return
            end
            if args.charName == 'Vladimir' then
                self.UndyingBuffs['VladimirSanguinePool'] = true
                return
            end
            if args.charName == 'KogMaw' then
                self.UndyingBuffs['KogMawIcathianSurprise'] = true
                return
            end
            if args.charName == 'Karthus' then
                self.UndyingBuffs['KarthusDeathDefiedBuff'] = true
                return
            end
        end)
    end
    -- on load
    function Object:OnLoad()
        for i = 1, Game.ObjectCount() do
            local object = Game.Object(i)
            if object and (object.type == Obj_AI_Barracks or object.type == Obj_AI_Nexus) then
                if object.isEnemy then
                    table_insert(self.EnemyBuildings, object)
                elseif object.isAlly then
                    table_insert(self.AllyBuildings, object)
                end
            end
        end
        Action:Add(function()
            local success = false
            for i = 1, Game.HeroCount() do
                local args = Data:GetHeroData(Game.Hero(i))
                if args.valid and args.isAlly and self.AllyHeroesInGame[args.networkID] == nil then
                    self.AllyHeroesInGame[args.networkID] = true
                    for j, func in pairs(self.AllyHeroCb) do
                        func(args)
                    end
                end
                if args.valid and args.isEnemy and self.EnemyHeroesInGame[args.networkID] == nil then
                    self.EnemyHeroesInGame[args.networkID] = true
                    for j, func in pairs(self.EnemyHeroCb) do
                        func(args)
                    end
                    success = true
                end
            end
            return success
        end, 1, 100)
    end
    -- on ally hero load
    function Object:OnAllyHeroLoad(cb)
        table_insert(self.AllyHeroCb, cb)
    end
    -- on enemy hero load
    function Object:OnEnemyHeroLoad(cb)
        table_insert(self.EnemyHeroCb, cb)
    end
    -- is facing
    function Object:IsFacing(source, target, angle)
        return IsFacing(source, target, angle)
    end
    -- is valid
    function Object:IsValid(unit)
        return unit and unit.valid and unit.visible and unit.isTargetable and not unit.dead
    end
    -- is hero immortal
    function Object:IsHeroImmortal(unit, isAttack)
        local hp
        hp = 100 * (unit.health / unit.maxHealth)
        self.UndyingBuffs['kindredrnodeathbuff'] = hp < 10
        self.UndyingBuffs['ChronoShift'] = hp < 15
        self.UndyingBuffs['chronorevive'] = hp < 15
        self.UndyingBuffs['UndyingRage'] = hp < 15
        self.UndyingBuffs['JaxCounterStrike'] = isAttack
        for buffName, isActive in pairs(self.UndyingBuffs) do
            if isActive and Buff:HasBuff(unit, buffName) then
                return true
            end
        end
        -- anivia passive, olaf R, ... if unit.isImmortal and not Buff:HasBuff(unit, 'willrevive') and not Buff:HasBuff(unit, 'zacrebirthready') then return true end
        return false
    end
    -- get heroes
    function Object:GetHeroes(range, bbox, immortal, isAttack)
        local result = {}
        local a = self:GetEnemyHeroes(range, bbox, immortal, isAttack)
        local b = self:GetAllyHeroes(range, bbox, immortal, isAttack)
        for i = 1, #a do
            table_insert(result, a[i])
        end
        for i = 1, #b do
            table_insert(result, b[i])
        end
        return result
    end
    -- get enemy heroes
    function Object:GetEnemyHeroes(range, bbox, immortal, isAttack)
        local result = {}
        local cachedHeroes = Cached:GetHeroes()
        for i = 1, #cachedHeroes do
            local hero = cachedHeroes[i]
            if hero.isEnemy and self:IsValid(hero) and (not immortal or not self:IsHeroImmortal(hero, isAttack)) then
                if not range or hero.distance < range + (bbox and hero.boundingRadius or 0) then
                    table_insert(result, hero)
                end
            end
        end
        return result
    end
    -- get ally heroes
    function Object:GetAllyHeroes(range, bbox, immortal, isAttack)
        local result = {}
        local cachedHeroes = Cached:GetHeroes()
        for i = 1, #cachedHeroes do
            local hero = cachedHeroes[i]
            if hero.isAlly and self:IsValid(hero) and (not immortal or not self:IsHeroImmortal(hero, isAttack)) then
                if not range or hero.distance < range + (bbox and hero.boundingRadius or 0) then
                    table_insert(result, hero)
                end
            end
        end
        return result
    end
    -- get minions
    function Object:GetMinions(range, bbox, immortal)
        local result = {}
        local a = self:GetEnemyMinions(range, bbox, immortal)
        local b = self:GetAllyMinions(range, bbox, immortal)
        for i = 1, #a do
            table_insert(result, a[i])
        end
        for i = 1, #b do
            table_insert(result, b[i])
        end
        return result
    end
    -- get enemy minions
    function Object:GetEnemyMinions(range, bbox, immortal)
        local result = {}
        local cachedminions = Cached:GetMinions()
        for i = 1, #cachedminions do
            local obj = cachedminions[i]
            if obj.isEnemy and (not immortal or not obj.isImmortal) then
                if not range or obj.distance < range + (bbox and obj.boundingRadius or 0) then
                    table_insert(result, obj)
                end
            end
        end
        return result
    end
    -- get monsters
    function Object:GetMonsters(range, bbox, immortal)
        local result = {}
        local cachedminions = Cached:GetMinions()
        for i = 1, #cachedminions do
            local obj = cachedminions[i]
            if obj.isEnemy and obj.team == 300 and (not immortal or not obj.isImmortal) then
                if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) then
                    table_insert(result, obj)
                end
            end
        end
        return result
    end
    -- get ally minions
    function Object:GetAllyMinions(range, bbox, immortal)
        local result = {}
        local cachedminions = Cached:GetMinions()
        for i = 1, #cachedminions do
            local obj = cachedminions[i]
            if obj.isAlly and obj.team < 300 and (not immortal or not obj.isImmortal) then
                if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) then
                    table_insert(result, obj)
                end
            end
        end
        return result
    end
    -- get other minions
    function Object:GetOtherMinions(range, bbox, immortal)
        local result = {}
        local a = self:GetOtherAllyMinions(range, bbox, immortal)
        local b = self:GetOtherEnemyMinions(range, bbox, immortal)
        for i = 1, #a do
            table_insert(result, a[i])
        end
        for i = 1, #b do
            table_insert(result, b[i])
        end
        return result
    end
    -- get other ally minions
    function Object:GetOtherAllyMinions(range)
        local result = {}
        local cachedwards = Cached:GetWards()
        for i = 1, #cachedwards do
            local obj = cachedwards[i]
            if obj.isAlly and (not range or obj.distance < range) then
                table_insert(result, obj)
            end
        end
        return result
    end
    -- get other enemy minions
    function Object:GetOtherEnemyMinions(range)
        local result = {}
        local cachedwards = Cached:GetWards()
        for i = 1, #cachedwards do
            local obj = cachedwards[i]
            if obj.isEnemy and (not range or obj.distance < range) then
                table_insert(result, obj)
            end
        end
        return result
    end
    -- get turrets
    function Object:GetTurrets(range, bbox, immortal)
        local result = {}
        local a = self:GetEnemyTurrets(range, bbox, immortal)
        local b = self:GetAllyTurrets(range, bbox, immortal)
        for i = 1, #a do
            table_insert(result, a[i])
        end
        for i = 1, #b do
            table_insert(result, b[i])
        end
        return result
    end
    -- get enemy turrets
    function Object:GetEnemyTurrets(range, bbox, immortal)
        local result = {}
        local cachedturrets = Cached:GetTurrets()
        for i = 1, #cachedturrets do
            local obj = cachedturrets[i]
            if obj.isEnemy and (not immortal or not obj.isImmortal) then
                if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) then
                    table_insert(result, obj)
                end
            end
        end
        return result
    end
    -- get ally turrets
    function Object:GetAllyTurrets(range, bbox, immortal)
        local result = {}
        local cachedturrets = Cached:GetTurrets()
        for i = 1, #cachedturrets do
            local obj = cachedturrets[i]
            if obj.isAlly then
                if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) then
                    table_insert(result, obj)
                end
            end
        end
        return result
    end
    -- get enemy buildings
    function Object:GetEnemyBuildings(range, bbox)
        local result = {}
        for i = 1, #self.EnemyBuildings do
            local obj = self.EnemyBuildings[i]
            if obj and obj.valid and obj.visible and obj.isTargetable and not obj.dead and not obj.isImmortal then
                if (not range or obj.distance < range + (bbox and Data:GetBuildingBBox(obj) or 0)) then
                    table_insert(result, obj)
                end
            end
        end
        return result
    end
    -- get ally buildings
    function Object:GetAllyBuildings(range, bbox)
        local result = {}
        for i = 1, #self.AllyBuildings do
            local obj = self.AllyBuildings[i]
            if obj and obj.valid and obj.visible and obj.isTargetable and not obj.dead and not obj.isImmortal then
                if (not range or obj.distance < range + (bbox and Data:GetBuildingBBox(obj) or 0)) then
                    table_insert(result, obj)
                end
            end
        end
        return result
    end
    -- get all structures
    function Object:GetAllStructures(range, bbox)
        local result = {}
        for i = 1, #self.AllyBuildings do
            local obj = self.AllyBuildings[i]
            if obj and obj.valid and obj.visible and obj.isTargetable and not obj.dead and not obj.isImmortal then
                if (not range or obj.distance < range + (bbox and Data:GetBuildingBBox(obj) or 0)) then
                    table_insert(result, obj)
                end
            end
        end
        for i = 1, #self.EnemyBuildings do
            local obj = self.EnemyBuildings[i]
            if obj and obj.valid and obj.visible and obj.isTargetable and not obj.dead and not obj.isImmortal then
                if (not range or obj.distance < range + (bbox and Data:GetBuildingBBox(obj) or 0)) then
                    table_insert(result, obj)
                end
            end
        end
        local cachedturrets = Cached:GetTurrets()
        for i = 1, #cachedturrets do
            local obj = cachedturrets[i]
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) then
                table_insert(result, obj)
            end
        end
        return result
    end
    -- init call
    Object:__init()
end

-- target
Target = {}
do
    -- init
    function Target:__init()
        self.SelectionTick = 0
        self.Selected = nil
        self.CurrentSort = nil
        self.CurrentSortMode = 0
        self.CurrentDamage = nil
        self.ActiveStackBuffs = {'BraumMark'}
        self.StackBuffs =
        {
            ['Vayne'] = {'VayneSilverDebuff'},
            ['TahmKench'] = {'tahmkenchpdebuffcounter'},
            ['Kennen'] = {'kennenmarkofstorm'},
            ['Darius'] = {'DariusHemo'},
            ['Ekko'] = {'EkkoStacks'},
            ['Gnar'] = {'GnarWProc'},
            ['Kalista'] = {'KalistaExpungeMarker'},
            ['Kindred'] = {'KindredHitCharge', 'kindredecharge'},
            ['Tristana'] = {'tristanaecharge'},
            ['Twitch'] = {'TwitchDeadlyVenom'},
            ['Varus'] = {'VarusWDebuff'},
            ['Velkoz'] = {'VelkozResearchStack'},
            ['Vi'] = {'ViWProc'},
        }
        self.MenuPriorities = Menu.Target.Priorities
        self.MenuDrawSelected = Menu.Main.Drawings.SelectedTarget
        self.MenuTableSortMode = Menu.Target['SortMode' .. myHero.charName]
        self.MenuCheckSelected = Menu.Target.SelectedTarget
        self.MenuCheckSelectedOnly = Menu.Target.OnlySelectedTarget
        Object:OnEnemyHeroLoad(function(args)
            local priority = Data:GetHeroPriority(args.charName) or 1
            self.MenuPriorities:MenuElement({id = args.charName, name = args.charName, value = priority, min = 1, max = 5, step = 1})
        end)
        if self.StackBuffs[myHero.charName] then
            for i, buffName in pairs(self.StackBuffs[myHero.charName]) do
                table_insert(self.ActiveStackBuffs, buffName)
            end
        end
        self.SortModes =
        {
            [SORT_AUTO] = function(a, b)
                local aMultiplier = 1.75 - self:GetPriority(a) * 0.15
                local bMultiplier = 1.75 - self:GetPriority(b) * 0.15
                local aDef, bDef = 0, 0
                if self.CurrentDamage == DAMAGE_TYPE_MAGICAL then
                    local magicPen, magicPenPercent = myHero.magicPen, myHero.magicPenPercent
                    aDef = math_max(0, aMultiplier * (a.magicResist - magicPen) * magicPenPercent)
                    bDef = math_max(0, bMultiplier * (b.magicResist - magicPen) * magicPenPercent)
                elseif self.CurrentDamage == DAMAGE_TYPE_PHYSICAL then
                    local armorPen, bonusArmorPenPercent = myHero.armorPen, myHero.bonusArmorPenPercent
                    aDef = math_max(0, aMultiplier * (a.armor - armorPen) * bonusArmorPenPercent)
                    bDef = math_max(0, bMultiplier * (b.armor - armorPen) * bonusArmorPenPercent)
                end
                return (a.health * aMultiplier * ((100 + aDef) / 100)) - a.ap - (a.totalDamage * a.attackSpeed * 2) < (b.health * bMultiplier * ((100 + bDef) / 100)) - b.ap - (b.totalDamage * b.attackSpeed * 2)
            end,
            [SORT_CLOSEST] = function(a, b)
                return a.distance < b.distance
            end,
            [SORT_NEAR_MOUSE] = function(a, b)
                return a.pos:DistanceTo(Vector(mousePos)) < b.pos:DistanceTo(Vector(mousePos))
            end,
            [SORT_LOWEST_HEALTH] = function(a, b)
                return a.health < b.health
            end,
            [SORT_LOWEST_MAX_HEALTH] = function(a, b)
                return a.maxHealth < b.maxHealth
            end,
            [SORT_HIGHEST_PRIORITY] = function(a, b)
                return self:GetPriority(a) > self:GetPriority(b)
            end,
            [SORT_MOST_STACK] = function(a, b)
                local aMax = 0
                for i, buffName in pairs(self.ActiveStackBuffs) do
                    local buff = Buff:GetBuff(a, buffName)
                    if buff then
                        aMax = math_max(aMax, math_max(buff.Count, buff.Stacks))
                    end
                end
                local bMax = 0
                for i, buffName in pairs(self.ActiveStackBuffs) do
                    local buff = Buff:GetBuff(b, buffName)
                    if buff then
                        bMax = math_max(bMax, math_max(buff.Count, buff.Stacks))
                    end
                end
                return aMax > bMax
            end,
            [SORT_MOST_AD] = function(a, b)
                return a.totalDamage > b.totalDamage
            end,
            [SORT_MOST_AP] = function(a, b)
                return a.ap > b.ap
            end,
            [SORT_LESS_CAST] = function(a, b)
                local aMultiplier = 1.75 - self:GetPriority(a) * 0.15
                local bMultiplier = 1.75 - self:GetPriority(b) * 0.15
                local aDef, bDef = 0, 0
                local magicPen, magicPenPercent = myHero.magicPen, myHero.magicPenPercent
                aDef = math_max(0, aMultiplier * (a.magicResist - magicPen) * magicPenPercent)
                bDef = math_max(0, bMultiplier * (b.magicResist - magicPen) * magicPenPercent)
                return (a.health * aMultiplier * ((100 + aDef) / 100)) - a.ap - (a.totalDamage * a.attackSpeed * 2) < (b.health * bMultiplier * ((100 + bDef) / 100)) - b.ap - (b.totalDamage * b.attackSpeed * 2)
            end,
            [SORT_LESS_ATTACK] = function(a, b)
                local aMultiplier = 1.75 - self:GetPriority(a) * 0.15
                local bMultiplier = 1.75 - self:GetPriority(b) * 0.15
                local aDef, bDef = 0, 0
                local armorPen, bonusArmorPenPercent = myHero.armorPen, myHero.bonusArmorPenPercent
                aDef = math_max(0, aMultiplier * (a.armor - armorPen) * bonusArmorPenPercent)
                bDef = math_max(0, bMultiplier * (b.armor - armorPen) * bonusArmorPenPercent)
                return (a.health * aMultiplier * ((100 + aDef) / 100)) - a.ap - (a.totalDamage * a.attackSpeed * 2) < (b.health * bMultiplier * ((100 + bDef) / 100)) - b.ap - (b.totalDamage * b.attackSpeed * 2)
            end,
        }
        self.CurrentSortMode = self.MenuTableSortMode:Value()
        self.CurrentSort = self.SortModes[self.CurrentSortMode]
    end
    -- wnd msg
    function Target:WndMsg(msg, wParam)
        if msg == WM_LBUTTONDOWN and self.MenuCheckSelected:Value() and GetTickCount() > self.SelectionTick + 100 then
            self.Selected = nil
            local num = 10000000
            local pos = Vector(mousePos)
            local enemies = Object:GetEnemyHeroes()
            for i = 1, #enemies do
                local enemy = enemies[i]
                if enemy.pos:ToScreen().onScreen then
                    local distance = pos:DistanceTo(enemy.pos)
                    if distance < 150 and distance < num then
                        self.Selected = enemy
                        num = distance
                    end
                end
            end
            self.SelectionTick = GetTickCount()
        end
    end
    -- on draw
    function Target:OnDraw()
        if self.MenuDrawSelected:Value() and Object:IsValid(self.Selected) and not Object:IsHeroImmortal(self.Selected) then
            Draw.Circle(self.Selected.pos, 150, 1, Color.DarkRed)
        end
    end
    -- on tick
    function Target:OnTick()
        local sortMode = self.MenuTableSortMode:Value()
        if sortMode ~= self.CurrentSortMode then
            self.CurrentSortMode = sortMode
            self.CurrentSort = self.SortModes[sortMode]
        end
    end
    -- ge target
    function Target:GetTarget(a, dmgType, isAttack)
        a = a or 20000
        dmgType = dmgType or 1
        self.CurrentDamage = dmgType
        if self.MenuCheckSelected:Value() and Object:IsValid(self.Selected) and not Object:IsHeroImmortal(self.Selected, isAttack) then
            if type(a) == 'number' then
                if self.Selected.distance < a then
                    return self.Selected
                end
            else
                local ok
                for i = 1, #a do
                    if a[i].networkID == self.Selected.networkID then
                        ok = true
                        break
                    end
                end
                if ok then
                    return self.Selected
                end
            end
            if self.MenuCheckSelectedOnly:Value() then
                return nil
            end
        end
        if type(a) == 'number' then
            a = Object:GetEnemyHeroes(a, false, true, isAttack)
        end
        if self.CurrentSortMode == SORT_MOST_STACK then
            local stackA = {}
            for i = 1, #a do
                local obj = a[i]
                for j = 1, #self.ActiveStackBuffs do
                    if Buff:HasBuff(obj, self.ActiveStackBuffs[j]) then
                        table_insert(stackA, obj)
                    end
                end
            end
            local sortMode = (#stackA == 0 and SORT_AUTO or SORT_MOST_STACK)
            if sortMode == SORT_MOST_STACK then
                a = stackA
            end
            table_sort(a, self.SortModes[sortMode])
        else
            table_sort(a, self.CurrentSort)
        end
        return (#a == 0 and nil or a[1])
    end
    -- get priority
    function Target:GetPriority(unit)
        local name = unit.charName
        if self.MenuPriorities[name] then
            return self.MenuPriorities[name]:Value()
        end
        if Data.HEROES[name:lower()] then
            return Data.HEROES[name:lower()][1]
        end
        return 1
    end
    -- get combo target
    function Target:GetComboTarget(dmgType)
        dmgType = dmgType or DAMAGE_TYPE_PHYSICAL
        local attackRange = myHero.range + myHero.boundingRadius
        local enemies = Object:GetEnemyHeroes(false, false, true, true)
        local enemiesaa = {}
        for i = 1, #enemies do
            local enemy = enemies[i]
            local extraRange = enemy.boundingRadius - 35
            if Object.IsCaitlyn and Buff:HasBuff(enemy, 'caitlynyordletrapinternal') then
                extraRange = extraRange + 600
            end
            if enemy.distance < attackRange + extraRange then
                table_insert(enemiesaa, enemy)
            end
        end
        return self:GetTarget(enemiesaa, dmgType, true)
    end
    -- init call
    Target:__init()
end

-- health
Health = {}
do
    -- init
    function Health:__init()
        self.ExtraFarmDelay = Menu.Orbwalker.Farming.ExtraFarmDelay
        self.MenuDrawings = Menu.Main.Drawings
        self.IsLastHitable = false
        self.ShouldRemoveObjects = false
        self.ShouldWaitTime = 0
        self.OnUnkillableC = {}
        self.ActiveAttacks = {}
        self.AllyTurret = nil
        self.AllyTurretHandle = nil
        self.StaticAutoAttackDamage = nil
        self.FarmMinions = {}
        self.Handles = {}
        self.AllyMinionsHandles = {}
        self.EnemyWardsInAttackRange = {}
        self.EnemyMinionsInAttackRange = {}
        self.JungleMinionsInAttackRange = {}
        self.EnemyStructuresInAttackRange = {}
        self.CachedWards = {}
        self.CachedMinions = {}
        self.TargetsHealth = {}
        self.AttackersDamage = {}
        self.Spells = {}
        self.LastHitHandle = 0
        self.LaneClearHandle = 0
    end
    -- add spell
    function Health:AddSpell(class)
        table_insert(self.Spells, class)
    end
    -- on tick
    function Health:OnTick()
        local attackRange, structures, pos, speed, windup, time, anim
        -- RESET ALL
        if self.ShouldRemoveObjects then
            self.ShouldRemoveObjects = false
            self.AllyTurret = nil
            self.AllyTurretHandle = nil
            self.StaticAutoAttackDamage = nil
            self.FarmMinions = {}
            self.EnemyWardsInAttackRange = {}
            self.EnemyMinionsInAttackRange = {}
            self.JungleMinionsInAttackRange = {}
            self.EnemyStructuresInAttackRange = {}
            self.AttackersDamage = {}
            self.ActiveAttacks = {}
            self.AllyMinionsHandles = {}
            self.TargetsHealth = {}
            self.Handles = {}
            self.CachedMinions = {}
            self.CachedWards = {}
        end
        -- SPELLS
        for i = 1, #self.Spells do
            self.Spells[i]:Reset()
        end
        if Orbwalker.IsNone or Orbwalker.Modes[ORBWALKER_MODE_COMBO] then
            return
        end
        self.IsLastHitable = false
        self.ShouldRemoveObjects = true
        self.StaticAutoAttackDamage = Damage:GetStaticAutoAttackDamage(myHero, true)
        -- SET OBJECTS
        attackRange = myHero.range + myHero.boundingRadius
        local cachedminions = Cached:GetMinions()
        for i = 1, #cachedminions do
            local obj = cachedminions[i]
            if IsInRange(myHero, obj, 2000) then
                table_insert(self.CachedMinions, obj)
            end
        end
        local cachedwards = Cached:GetWards()
        for i = 1, #cachedwards do
            local obj = cachedwards[i]
            if obj.isEnemy and IsInRange(myHero, obj, 2000) then
                table_insert(self.CachedWards, obj)
            end
        end
        for i = 1, #self.CachedMinions do
            local obj = self.CachedMinions[i]
            local handle = obj.handle
            self.Handles[handle] = obj
            local team = obj.team
            if team == Data.AllyTeam then
                self.AllyMinionsHandles[handle] = obj
            elseif team == Data.EnemyTeam then
                if IsInRange(myHero, obj, attackRange + obj.boundingRadius) then
                    table_insert(self.EnemyMinionsInAttackRange, obj)
                end
            elseif team == Data.JungleTeam then
                if IsInRange(myHero, obj, attackRange + obj.boundingRadius) then
                    table_insert(self.JungleMinionsInAttackRange, obj)
                end
            end
        end
        for i = 1, #self.CachedWards do
            local obj = self.CachedWards[i]
            if IsInRange(myHero, obj, attackRange + 35) then
                table_insert(self.EnemyWardsInAttackRange, obj)
            end
        end
        structures = Object:GetAllStructures(2000)
        for i = 1, #structures do
            local obj = structures[i]
            local objType = obj.type
            if objType == Obj_AI_Turret then
                self.Handles[obj.handle] = obj
                if obj.team == Data.AllyTeam then
                    self.AllyTurret = obj
                    self.AllyTurretHandle = obj.handle
                end
            end
            if obj.team == Data.EnemyTeam then
                local objRadius = 0
                if objType == Obj_AI_Barracks then
                    objRadius = 270
                elseif objType == Obj_AI_Nexus then
                    objRadius = 380
                elseif objType == Obj_AI_Turret then
                    objRadius = obj.boundingRadius
                end
                if IsInRange(myHero, obj, attackRange + objRadius) then
                    table_insert(self.EnemyStructuresInAttackRange, obj)
                end
            end
        end
        -- ON ATTACK
        local timer = Game.Timer()
        for handle, obj in pairs(self.Handles) do
            local s = obj.activeSpell
            if s and s.valid and s.isAutoAttack then
                local endTime = s.endTime
                local speed = s.speed
                local animation = s.animation
                local windup = s.windup
                local target = s.target
                if endTime and speed and animation and windup and target and endTime > timer then
                    self.ActiveAttacks[handle] =
                    {
                        Speed = speed,
                        EndTime = endTime,
                        AnimationTime = animation,
                        WindUpTime = windup,
                        StartTime = endTime - animation,
                        Target = target,
                    }
                end
            end
        end
        -- SET FARM MINIONS
        pos = myHero.pos
        speed = Attack:GetProjectileSpeed()
        windup = Attack:GetWindup()
        time = windup - Data:GetLatency() - self.ExtraFarmDelay:Value() * 0.001
        anim = Attack:GetAnimation()
        for i = 1, #self.EnemyMinionsInAttackRange do
            local target = self.EnemyMinionsInAttackRange[i]
            table_insert(self.FarmMinions, self:SetLastHitable(target, anim, time + target.distance / speed, Damage:GetAutoAttackDamage(myHero, target, self.StaticAutoAttackDamage)))
        end
        -- SPELLS
        for i = 1, #self.Spells do
            self.Spells[i]:Tick()
        end
    end
    -- on draw
    function Health:OnDraw()
        if self.MenuDrawings.Enabled:Value() and self.MenuDrawings.LastHittableMinions:Value() then
            for i = 1, #self.FarmMinions do
                local args = self.FarmMinions[i]
                local minion = args.Minion
                if Object:IsValid(minion) then
                    if args.LastHitable then
                        Draw.Circle(minion.pos, math_max(65, minion.boundingRadius), 1, Color.LastHitable)
                    elseif args.AlmostLastHitable then
                        Draw.Circle(minion.pos, math_max(65, minion.boundingRadius), 1, Color.AlmostLastHitable)
                    end
                end
            end
        end
    end
    -- get prediction
    function Health:GetPrediction(target, time)
        local timer, pos, team, handle, health, attackers
        timer = Game.Timer()
        pos = target.pos
        handle = target.handle
        if self.TargetsHealth[handle] == nil then
            self.TargetsHealth[handle] = target.health + Data:GetTotalShield(target)
        end
        health = self.TargetsHealth[handle]
        for attackerHandle, attack in pairs(self.ActiveAttacks) do
            local c = 0
            local attacker = self.Handles[attackerHandle]
            if attacker and attack.Target == handle then
                local speed, startT, flyT, endT, damage
                speed = attack.Speed
                startT = attack.StartTime
                flyT = speed > 0 and GetDistance(attacker.pos, pos) / speed or 0
                endT = (startT + attack.WindUpTime + flyT) - timer
                if endT > 0 and endT < time then
                    c = c + 1
                    if self.AttackersDamage[attackerHandle] == nil then
                        self.AttackersDamage[attackerHandle] = {}
                    end
                    if self.AttackersDamage[attackerHandle][handle] == nil then
                        self.AttackersDamage[attackerHandle][handle] = Damage:GetAutoAttackDamage(attacker, target)
                    end
                    damage = self.AttackersDamage[attackerHandle][handle]
                    
                    health = health - damage
                end
            end
        end
        return health
    end
    -- local get prediction
    function Health:LocalGetPrediction(target, time)
        local timer, pos, team, handle, health, attackers, turretAttacked
        turretAttacked = false
        timer = Game.Timer()
        pos = target.pos
        handle = target.handle
        if self.TargetsHealth[handle] == nil then
            self.TargetsHealth[handle] = target.health + Data:GetTotalShield(target)
        end
        health = self.TargetsHealth[handle]
        local handles = {}
        for attackerHandle, attack in pairs(self.ActiveAttacks) do
            local attacker = self.Handles[attackerHandle]
            if attacker and attacker.valid and attacker.visible and attacker.alive and attack.Target == handle then
                local speed, startT, flyT, endT, damage
                speed = attack.Speed
                startT = attack.StartTime
                flyT = speed > 0 and GetDistance(attacker.pos, pos) / speed or 0
                endT = (startT + attack.WindUpTime + flyT) - timer
                -- laneClear
                if endT < 0 and timer - attack.EndTime < 1.25 then
                    endT = attack.WindUpTime + flyT
                    endT = timer > attack.EndTime and endT or endT + (attack.EndTime - timer)
                    startT = timer > attack.EndTime and timer or attack.EndTime
                end
                if endT > 0 and endT < time then
                    handles[attackerHandle] = true
                    -- damage
                    if self.AttackersDamage[attackerHandle] == nil then
                        self.AttackersDamage[attackerHandle] = {}
                    end
                    if self.AttackersDamage[attackerHandle][handle] == nil then
                        self.AttackersDamage[attackerHandle][handle] = Damage:GetAutoAttackDamage(attacker, target)
                    end
                    damage = self.AttackersDamage[attackerHandle][handle]
                    -- laneClear
                    local c = 1
                    while (endT < time) do
                        if attackerHandle == self.AllyTurretHandle then
                            turretAttacked = true
                        else
                            health = health - damage
                        end
                        endT = (startT + attack.WindUpTime + flyT + c * attack.AnimationTime) - timer
                        c = c + 1
                        if c > 10 then
                            print("ERROR LANECLEAR!")
                            health = self.TargetsHealth[handle]
                            break
                        end
                    end
                end
            end
        end
        -- laneClear
        for attackerHandle, obj in pairs(self.AllyMinionsHandles) do
            if handles[attackerHandle] == nil and obj and obj.valid and obj.visible and obj.alive then
                local aaData = obj.attackData
                local isMoving = obj.pathing.hasMovePath
                if aaData == nil or aaData.target == nil or self.Handles[aaData.target] == nil or isMoving or self.ActiveAttacks[attackerHandle] == nil then
                    local distance = GetDistance(obj.pos, pos)
                    local range = Data:GetAutoAttackRange(obj, target)
                    local extraRange = isMoving and 250 or 0
                    if distance < range + extraRange then
                        local speed, flyT, endT, damage
                        speed = aaData.projectileSpeed
                        distance = distance > range and range or distance
                        flyT = speed > 0 and distance / speed or 0
                        endT = aaData.windUpTime + flyT
                        if endT < time then
                            if self.AttackersDamage[attackerHandle] == nil then
                                self.AttackersDamage[attackerHandle] = {}
                            end
                            if self.AttackersDamage[attackerHandle][handle] == nil then
                                self.AttackersDamage[attackerHandle][handle] = Damage:GetAutoAttackDamage(obj, target)
                            end
                            damage = self.AttackersDamage[attackerHandle][handle]
                            local c = 1
                            while (endT < time) do
                                health = health - damage
                                endT = aaData.windUpTime + flyT + c * aaData.animationTime
                                c = c + 1
                                if c > 10 then
                                    print("ERROR LANECLEAR!")
                                    health = self.TargetsHealth[handle]
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        return health, turretAttacked
    end
    -- set last hitable
    function Health:SetLastHitable(target, anim, time, damage)
        local timer, handle, currentHealth, health, lastHitable, almostLastHitable, almostalmost, unkillable
        timer = Game.Timer()
        handle = target.handle
        currentHealth = target.health + Data:GetTotalShield(target)
        self.TargetsHealth[handle] = currentHealth
        health = self:GetPrediction(target, time)
        lastHitable = false
        almostLastHitable = false
        almostalmost = false
        unkillable = false
        -- unkillable
        if health < 0 then
            unkillable = true
            for i = 1, #self.OnUnkillableC do
                self.OnUnkillableC[i](target)
            end
            return
            {
                LastHitable = lastHitable,
                Unkillable = unkillable,
                AlmostLastHitable = almostLastHitable,
                PredictedHP = health,
                Minion = target,
                AlmostAlmost = almostalmost,
                Time = time,
            }
        end
        -- lasthitable
        if health - damage < 0 then
            lastHitable = true
            self.IsLastHitable = true
            return
            {
                LastHitable = lastHitable,
                Unkillable = unkillable,
                AlmostLastHitable = almostLastHitable,
                PredictedHP = health,
                Minion = target,
                AlmostAlmost = almostalmost,
                Time = time,
            }
        end
        -- almost lasthitable
        local turretAttack, extraTime, almostHealth, almostAlmostHealth, turretAttacked
        turretAttack = self.AllyTurret ~= nil and self.AllyTurret.attackData or nil
        extraTime = (1.5 - anim) * 0.3
        extraTime = extraTime < 0 and 0 or extraTime
        almostHealth, turretAttacked = self:LocalGetPrediction(target, anim + time + extraTime)-- + 0.25
        if almostHealth < 0 then
            almostLastHitable = true
            self.ShouldWaitTime = GetTickCount()
        elseif almostHealth - damage < 0 then
            almostLastHitable = true
        elseif currentHealth ~= almostHealth then
            almostAlmostHealth, turretAttacked = self:LocalGetPrediction(target, 1.25 * anim + 1.25 * time + 0.5 + extraTime)
            if almostAlmostHealth - damage < 0 then
                almostalmost = true
            end
        end
        -- under turret, turret attackdata: 1.20048 0.16686 1200
        if turretAttacked or (turretAttack and turretAttack.target == handle) or (self.AllyTurret and (Data:IsInAutoAttackRange(self.AllyTurret, target) or Data:IsInAutoAttackRange2(self.AllyTurret, target))) then
            local nearTurret, isTurretTarget, maxHP, startTime, windUpTime, flyTime, turretDamage, turretHits
            nearTurret = true
            isTurretTarget = turretAttack.target == handle
            maxHP = target.maxHealth
            startTime = turretAttack.endTime - 1.20048
            windUpTime = 0.16686
            flyTime = GetDistance(self.AllyTurret, target) / 1200
            turretDamage = Damage:GetAutoAttackDamage(self.AllyTurret, target)
            turretHits = 1
            while (maxHP > turretHits * turretDamage) do
                turretHits = turretHits + 1
                if turretHits > 10 then
                    print("ERROR TURRETHITS")
                    break
                end
            end
            turretHits = turretHits - 1
            return
            {
                LastHitable = lastHitable,
                Unkillable = unkillable,
                AlmostLastHitable = almostLastHitable,
                PredictedHP = health,
                Minion = target,
                AlmostAlmost = almostalmost,
                Time = time,
                -- turret
                NearTurret = nearTurret,
                IsTurretTarget = isTurretTarget,
                TurretHits = turretHits,
                TurretDamage = turretDamage,
                TurretFlyDelay = flyTime,
                TurretStart = startTime,
                TurretWindup = windUpTime,
            }
        end
        return
        {
            LastHitable = lastHitable,
            Unkillable = health < 0,
            AlmostLastHitable = almostLastHitable,
            PredictedHP = health,
            Minion = target,
            AlmostAlmost = almostalmost,
            Time = time,
        }
    end
    -- should wait
    function Health:ShouldWait()
        return GetTickCount() < self.ShouldWaitTime + 250
    end
    -- get jungle target
    function Health:GetJungleTarget()
        if #self.JungleMinionsInAttackRange > 0 then
            table_sort(self.JungleMinionsInAttackRange, function(a, b) return a.maxHealth > b.maxHealth end);
            return self.JungleMinionsInAttackRange[1]
        end
        return #self.EnemyWardsInAttackRange > 0 and self.EnemyWardsInAttackRange[1] or nil
    end
    -- get last hit target
    function Health:GetLastHitTarget()
        local min = 10000000
        local result = nil
        for i = 1, #self.FarmMinions do
            local minion = self.FarmMinions[i]
            if Object:IsValid(minion.Minion) and minion.LastHitable and minion.PredictedHP < min and Data:IsInAutoAttackRange(myHero, minion.Minion) then
                min = minion.PredictedHP
                result = minion.Minion
                self.LastHitHandle = result.handle
            end
        end
        return result
    end
    -- get harass target
    function Health:GetHarassTarget()
        local LastHitPriority = Menu.Orbwalker.Farming.LastHitPriority:Value()
        local structure = #self.EnemyStructuresInAttackRange > 0 and self.EnemyStructuresInAttackRange[1] or nil
        if structure ~= nil then
            if not LastHitPriority then
                return structure
            end
            if self.IsLastHitable then
                return self:GetLastHitTarget()
            end
            if LastHitPriority and not self:ShouldWait() then
                return structure
            end
        else
            if not LastHitPriority then
                local hero = Target:GetComboTarget()
                if hero ~= nil then
                    return hero
                end
            end
            if self.IsLastHitable then
                return self:GetLastHitTarget()
            end
            if LastHitPriority and not self:ShouldWait() then
                local hero = Target:GetComboTarget()
                if hero ~= nil then
                    return hero
                end
            end
        end
    end
    -- get lane minion
    function Health:GetLaneMinion()
        local laneMinion = nil
        local num = 10000
        for i = 1, #self.FarmMinions do
            local minion = self.FarmMinions[i]
            if Data:IsInAutoAttackRange(myHero, minion.Minion) then
                if minion.PredictedHP < num and not minion.AlmostAlmost and not minion.AlmostLastHitable then--and (self.AllyTurret == nil or minion.CanUnderTurret) then
                    num = minion.PredictedHP
                    laneMinion = minion.Minion
                end
            end
        end
        return laneMinion
    end
    -- get lane clear target
    function Health:GetLaneClearTarget()
        local LastHitPriority = Menu.Orbwalker.Farming.LastHitPriority:Value()
        local LaneClearHeroes = Menu.Orbwalker.General.LaneClearHeroes:Value()
        local structure = #self.EnemyStructuresInAttackRange > 0 and self.EnemyStructuresInAttackRange[1] or nil
        local other = #self.EnemyWardsInAttackRange > 0 and self.EnemyWardsInAttackRange[1] or nil
        if structure ~= nil then
            if not LastHitPriority then
                return structure
            end
            if self.IsLastHitable then
                return self:GetLastHitTarget()
            end
            if other ~= nil then
                return other
            end
            if LastHitPriority and not self:ShouldWait() then
                return structure
            end
        else
            if not LastHitPriority and LaneClearHeroes then
                local hero = Target:GetComboTarget()
                if hero ~= nil then
                    return hero
                end
            end
            if self.IsLastHitable then
                return self:GetLastHitTarget()
            end
            if self:ShouldWait() then
                return nil
            end
            if LastHitPriority and LaneClearHeroes then
                local hero = Target:GetComboTarget()
                if hero ~= nil then
                    return hero
                end
            end
            -- lane minion
            local laneMinion = self:GetLaneMinion()
            if laneMinion ~= nil then
                self.LaneClearHandle = laneMinion.handle
                return laneMinion
            end
            -- ward
            if other ~= nil then
                return other
            end
        end
        return nil
    end
    -- init call
    Health:__init()
end

-- move
Movement = {}
do
    local MenuRandomHumanizer = Menu.Orbwalker.RandomHumanizer
    -- init
    function Movement:__init()
        self.MoveTimer = 0
    end
    -- get humanizer
    function Movement:GetHumanizer()
        local min = MenuRandomHumanizer.Min:Value()
        local max = MenuRandomHumanizer.Max:Value()
        return max <= min and min or math_random(min, max)
    end
    -- init call
    Movement:__init()
end

-- Control
do
    _G.LevelUpKeyTimer = 0
    Callback.Add("WndMsg", function(msg, wParam)
        if msg == HK_LUS or wParam == HK_LUS then
            _G.LevelUpKeyTimer = GetTickCount()
        end
    end)
    _G.LastChatOpenTimer = 0
    local ischatopen = _G.Game.IsChatOpen
    _G.Game.IsChatOpen = function()
        if ischatopen() then
            _G.LastChatOpenTimer = GetTickCount()
            return true
        end
        return false
    end
    local AttackKey = Menu.Main.AttackTKey
    local FastKiting = Menu.Orbwalker.General.FastKiting
    _G.Control.Evade = function(a)
        local pos = GetControlPos(a)
        if pos and EvadeSupport == nil then
            if Cursor.Step == 0 then
                Cursor:Add(MOUSEEVENTF_RIGHTDOWN, pos)
                return true
            end
            EvadeSupport = pos
            return true
        end
        return false
    end
    _G.Control.Attack = function(target)
        if target then
            Cursor:Add(AttackKey:Key(), target)
            if FastKiting:Value() then
                Movement.MoveTimer = 0
            end
            return true
        end
        return false
    end
    _G.Control.CastSpell = function(key, a, b, c)
        local pos = GetControlPos(a, b, c)
        if pos then
            if Cursor.Step > 0 then
                return false
            end
            if b == nil and a.pos then
                Cursor:Add(key, a)
            else
                Cursor:Add(key, pos)
            end
            return true
        end
        if a == nil then
            CastKey(key)
            return true
        end
        return false
    end
    _G.Control.Hold = function(key)
        CastKey(key)
        Movement.MoveTimer = 0
        Orbwalker.CanHoldPosition = false
        return true
    end
    _G.Control.Move = function(a, b, c)
        if Cursor.Step > 0 or GetTickCount() < Movement.MoveTimer then
            return false
        end
        local pos = GetControlPos(a, b, c)
        if pos then
            Cursor:Add(MOUSEEVENTF_RIGHTDOWN, pos)
        elseif a == nil then
            CastKey(MOUSEEVENTF_RIGHTDOWN)
        end
        Movement.MoveTimer = GetTickCount() + Movement:GetHumanizer()
        Orbwalker.CanHoldPosition = true
        return true
    end
end

-- cursor
Cursor = {}
do
    local MenuMultipleTimes = Menu.Main.SetCursorMultipleTimes
    local MenuDelay = Menu.Main.CursorDelay
    local MenuDrawCursor = Menu.Main.Drawings.Cursor
    -- init
    function Cursor:__init()
        self.Step = 0
    end
    -- add
    function Cursor:Add(key, castPos)
        self.Key = key
        self.CursorPos = cursorPos
        self.CastPos = castPos
        if self.CastPos ~= nil then
            self.IsTarget = self.CastPos.pos ~= nil
            self.IsMouseClick = key == MOUSEEVENTF_RIGHTDOWN
            self.Timer = GetTickCount() + MenuDelay:Value()
            self:StepSetToCastPos()
            self:StepPressKey()
        end
    end
    -- step ready
    function Cursor:StepReady()
        if FlashHelper.Flash then
            self:Add(FlashHelper.Flash, myHero.pos:Extended(Vector(mousePos), 600))
            FlashHelper.Flash = nil
        elseif EvadeSupport then
            self:Add(MOUSEEVENTF_RIGHTDOWN, EvadeSupport)
            EvadeSupport = nil
        end
    end
    -- step set to cast pos
    function Cursor:StepSetToCastPos()
        local pos
        if self.IsTarget then
            pos = self.CastPos.pos:To2D()
        else
            pos = (self.CastPos.z ~= nil) and Vector(self.CastPos.x, self.CastPos.y or 0, self.CastPos.z):To2D() or Vector({x = self.CastPos.x, y = self.CastPos.y})
        end
        Control.SetCursorPos(pos.x, pos.y)
    end
    -- step press key
    function Cursor:StepPressKey()
        if self.IsMouseClick then
            Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
            Control.mouse_event(MOUSEEVENTF_RIGHTUP)
        else
            Control.KeyDown(self.Key)
            Control.KeyUp(self.Key)
        end
        self.Step = 1
    end
    -- step wait for response
    function Cursor:StepWaitForResponse()
        if GetTickCount() > self.Timer then
            self.Step = 2
        elseif MenuMultipleTimes:Value() then
            self:StepSetToCastPos()
            --self:StepPressKey()
        end
    end
    -- step set to cursor pos
    function Cursor:StepSetToCursorPos()
        Control.SetCursorPos(self.CursorPos.x, self.CursorPos.y)
        self.Timer = GetTickCount() + MenuDelay:Value()
        self.Step = 3
    end
    -- step wait for ready
    function Cursor:StepWaitForReady()
        if GetTickCount() > self.Timer then
            self.Step = 0
        end
    end
    -- on tick
    function Cursor:OnTick()
        local step = self.Step
        if step == 0 then
            self:StepReady()
        elseif step == 1 then
            self:StepWaitForResponse()
        elseif step == 2 then
            self:StepSetToCursorPos()
        elseif step == 3 then
            self:StepWaitForReady()
        end
    end
    -- on draw
    function Cursor:OnDraw()
        if MenuDrawCursor:Value() then
            Draw.Circle(mousePos, 150, 1, Color.Cursor)
        end
    end
    -- init call
    Cursor:__init()
end

-- attack
Attack = {}
do
    -- init
    function Attack:__init()
        self.TestDamage = false
        self.TestCount = 0
        self.TestStartTime = 0
        self.IsGraves = myHero.charName == 'Graves'
        self.SpecialWindup = Data.SpecialWindup[myHero.charName:lower()]
        self.IsJhin = myHero.charName == 'Jhin'
        self.BaseAttackSpeed = Data.HEROES[Data.HeroName][3]
        self.BaseWindupTime = nil
        self.Reset = false
        self.ServerStart = 0
        self.CastEndTime = 1
        self.LocalStart = 0
        self.AttackWindup = 0
        self.AttackAnimation = 0
        self.IsSenna = myHero.charName == "Senna"
    end
    -- on tick
    function Attack:OnTick()
        if Data:CanResetAttack() and Orbwalker.Menu.General.AttackResetting:Value() then
            self.Reset = true
        end
        local spell = myHero.activeSpell
        if spell and spell.valid and spell.target > 0 and spell.castEndTime > self.CastEndTime and (spell.isAutoAttack or Data:IsAttack(spell.name)) then
            -- spell.isAutoAttack then  and Game.Timer() < self.LocalStart + 0.2
            for i = 1, #Orbwalker.OnAttackCb do
                Orbwalker.OnAttackCb[i]()
            end
            self.CastEndTime = spell.castEndTime
            self.AttackWindup = spell.windup
            self.ServerStart = self.CastEndTime - self.AttackWindup
            self.AttackAnimation = spell.animation
            if self.TestDamage then
                if self.TestCount == 0 then
                    self.TestStartTime = Game.Timer()
                end
                self.TestCount = self.TestCount + 1
                if self.TestCount == 5 then
                    print('5 attacks in time: ' .. tostring(Game.Timer() - self.TestStartTime) .. '[sec]')
                    self.TestCount = 0
                    self.TestStartTime = 0
                end
            end
        end
    end
    -- get windup
    function Attack:GetWindup()
        if self.IsJhin then
            return self.AttackWindup
        end
        if self.IsGraves then
            return myHero.attackData.windUpTime * 0.2
        end
        if self.SpecialWindup then
            local windup = self.SpecialWindup()
            if windup then
                return windup
            end
        end
        if self.BaseWindupTime then
            return math_max(self.AttackWindup, 1 / (myHero.attackSpeed * self.BaseAttackSpeed) / self.BaseWindupTime)
        end
        local data = myHero.attackData
        if data.animationTime > 0 and data.windUpTime > 0 then
            self.BaseWindupTime = data.animationTime / data.windUpTime
        end
        return math_max(self.AttackWindup, myHero.attackData.windUpTime)
    end
    -- get animation
    function Attack:GetAnimation()
        if self.IsJhin then
            return self.AttackAnimation
        end
        if self.IsGraves then
            return myHero.attackData.animationTime * 0.9
        end
        return 1 / (myHero.attackSpeed * self.BaseAttackSpeed)
    end
    -- get projectileSpeed
    function Attack:GetProjectileSpeed()
        if Data.IsHeroMelee or (Data.IsHeroSpecialMelee and Data.IsHeroSpecialMelee()) then
            return math_huge
        end
        if Data.SpecialMissileSpeed then
            local speed = Data.SpecialMissileSpeed()
            if speed then
                return speed
            end
        end
        local speed = myHero.attackData.projectileSpeed
        if speed > 0 then
            return speed
        end
        return math_huge
    end
    -- is ready
    function Attack:IsReady()
        if self.CastEndTime > self.LocalStart then
            if self.Reset or Game.Timer() >= self.ServerStart + self:GetAnimation() - Data:GetLatency() - 0.01 then
                return true
            end
            return false
        end
        if Game.Timer() < self.LocalStart + 0.2 then
            return false
        end
        return true
    end
    -- get attack cast time
    function Attack:GetAttackCastTime(num)
        num = num or 0
        return self:GetWindup() - Data:GetLatency() + num + 0.025 + (Orbwalker.Menu.General.ExtraWindUpTime:Value() * 0.001)
    end
    -- is active
    function Attack:IsActive(num)
        num = num or 0
        if self.CastEndTime > self.LocalStart then
            if Game.Timer() >= self.ServerStart + self:GetWindup() - Data:GetLatency() + 0.025 + num + (Orbwalker.Menu.General.ExtraWindUpTime:Value() * 0.001) then
                return false
            end
            return true
        end
        if Game.Timer() < self.LocalStart + 0.2 then
            return true
        end
        return false
    end
    -- is before
    function Attack:IsBefore(multipier)
        return Game.Timer() > self.LocalStart + multipier * self:GetAnimation()
    end
    -- init call
    Attack:__init()
end

-- orbwalker
Orbwalker = {}
do
    -- init
    function Orbwalker:__init()
        self.LastTarget = nil
        self.CanHoldPosition = true
        self.PostAttackTimer = 0
        self.IsNone = true
        self.OnPreAttackCb = {}
        self.OnPostAttackCb = {}
        self.OnPostAttackTickCb = {}
        self.OnAttackCb = {}
        self.OnMoveCb = {}
        self.Menu = Menu.Orbwalker
        self.MenuDrawings = Menu.Main.Drawings
        self.HoldPositionButton = Menu.Orbwalker.Keys.HoldKey
        self.MenuKeys =
        {
            [ORBWALKER_MODE_COMBO] = {},
            [ORBWALKER_MODE_HARASS] = {},
            [ORBWALKER_MODE_LANECLEAR] = {},
            [ORBWALKER_MODE_JUNGLECLEAR] = {},
            [ORBWALKER_MODE_LASTHIT] = {},
            [ORBWALKER_MODE_FLEE] = {},
        }
        self.Modes =
        {
            [ORBWALKER_MODE_COMBO] = false,
            [ORBWALKER_MODE_HARASS] = false,
            [ORBWALKER_MODE_LANECLEAR] = false,
            [ORBWALKER_MODE_JUNGLECLEAR] = false,
            [ORBWALKER_MODE_LASTHIT] = false,
            [ORBWALKER_MODE_FLEE] = false,
        }
        self:RegisterMenuKey(ORBWALKER_MODE_COMBO, self.Menu.Keys.Combo)
        self:RegisterMenuKey(ORBWALKER_MODE_HARASS, self.Menu.Keys.Harass)
        self:RegisterMenuKey(ORBWALKER_MODE_LASTHIT, self.Menu.Keys.LastHit)
        self:RegisterMenuKey(ORBWALKER_MODE_LANECLEAR, self.Menu.Keys.LaneClear)
        self:RegisterMenuKey(ORBWALKER_MODE_JUNGLECLEAR, self.Menu.Keys.Jungle)
        self:RegisterMenuKey(ORBWALKER_MODE_FLEE, self.Menu.Keys.Flee)
        self.ForceMovement = nil
        self.ForceTarget = nil
        self.PostAttackBool = false
        self.AttackEnabled = true
        self.MovementEnabled = true
        self.CanAttackC = function() return true end
        self.CanMoveC = function() return true end
    end
    -- on tick
    function Orbwalker:OnTick()
        if not self.Menu.Enabled:Value() then
            return
        end
        self.IsNone = self:HasMode(ORBWALKER_MODE_NONE)
        self.Modes = self:GetModes()
        if Cursor.Step > 0 then
            return
        end
        if Data:Stop() then
            return
        end
        if self.IsNone then
            return
        end
        self:Orbwalk()
    end
    -- on draw
    function Orbwalker:OnDraw()
        if not self.Menu.Enabled:Value() then
            return
        end
        if self.MenuDrawings.Range:Value() then
            Draw.Circle(myHero.pos, Data:GetAutoAttackRange(myHero), 1, Color.Range)
        end
        if self.MenuDrawings.HoldRadius:Value() then
            Draw.Circle(myHero.pos, self.Menu.General.HoldRadius:Value(), 1, Color.LightGreen)
        end
        if self.MenuDrawings.EnemyRange:Value() then
            local t = Object:GetEnemyHeroes()
            for i = 1, #t do
                local enemy = t[i]
                local range = Data:GetAutoAttackRange(enemy, myHero)
                Draw.Circle(enemy.pos, range, 1, IsInRange(enemy, myHero, range) and Color.EnemyRange or Color.Range)
            end
        end
    end
    -- register menu key
    function Orbwalker:RegisterMenuKey(mode, key)
        table_insert(self.MenuKeys[mode], key)
    end
    -- reset movement
    function Orbwalker:ResetMovement()
        Movement.MoveTimer = 0
    end
    -- get modes
    function Orbwalker:GetModes()
        return {
            [ORBWALKER_MODE_COMBO] = self:HasMode(ORBWALKER_MODE_COMBO),
            [ORBWALKER_MODE_HARASS] = self:HasMode(ORBWALKER_MODE_HARASS),
            [ORBWALKER_MODE_LANECLEAR] = self:HasMode(ORBWALKER_MODE_LANECLEAR),
            [ORBWALKER_MODE_JUNGLECLEAR] = self:HasMode(ORBWALKER_MODE_JUNGLECLEAR),
            [ORBWALKER_MODE_LASTHIT] = self:HasMode(ORBWALKER_MODE_LASTHIT),
            [ORBWALKER_MODE_FLEE] = self:HasMode(ORBWALKER_MODE_FLEE),
        }
    end
    -- has mode
    function Orbwalker:HasMode(mode)
        if mode == ORBWALKER_MODE_NONE then
            for _, value in pairs(self:GetModes()) do
                if value then
                    return false
                end
            end
            return true
        end
        for i = 1, #self.MenuKeys[mode] do
            local key = self.MenuKeys[mode][i]
            if key:Value() then
                return true
            end
        end
        return false
    end
    -- on pre attack
    function Orbwalker:OnPreAttack(func)
        table_insert(self.OnPreAttackCb, func)
    end
    -- on post attack
    function Orbwalker:OnPostAttack(func)
        table_insert(self.OnPostAttackCb, func)
    end
    -- on post attack tick
    function Orbwalker:OnPostAttackTick(func)
        table_insert(self.OnPostAttackTickCb, func)
    end
    -- on attack
    function Orbwalker:OnAttack(func)
        table_insert(self.OnAttackCb, func)
    end
    -- on pre movement
    function Orbwalker:OnPreMovement(func)
        table_insert(self.OnMoveCb, func)
    end
    -- can attack event
    function Orbwalker:CanAttackEvent(func)
        self.CanAttackC = func
    end
    -- can move event
    function Orbwalker:CanMoveEvent(func)
        self.CanMoveC = func
    end
    -- on auto attack reset
    function Orbwalker:__OnAutoAttackReset()
        Attack.Reset = true
    end
    -- set movement
    function Orbwalker:SetMovement(boolean)
        self.MovementEnabled = boolean
    end
    -- set attack
    function Orbwalker:SetAttack(boolean)
        self.AttackEnabled = boolean
    end
    -- is enabled
    function Orbwalker:IsEnabled()
        return true
    end
    -- is auto attacking
    function Orbwalker:IsAutoAttacking(unit)
        if unit == nil or unit.isMe then
            return Attack:IsActive()
        end
        return Game.Timer() < unit.attackData.endTime - unit.attackData.windDownTime
    end
    -- can move
    function Orbwalker:CanMove(unit)
        if unit == nil or unit.isMe then
            if not self.CanMoveC() then
                return false
            end
            if (JustEvade and JustEvade.Evading()) or (ExtLibEvade and ExtLibEvade.Evading) then
                return false
            end
            if myHero.charName == 'Kalista' then
                return true
            end
            if not Data:HeroCanMove() then
                return false
            end
            return not Attack:IsActive()
        end
        local attackData = unit.attackData
        return Game.Timer() > attackData.endTime - attackData.windDownTime
    end
    -- can attack
    function Orbwalker:CanAttack(unit)
        if unit == nil or unit.isMe then
            if not self.CanAttackC() then
                return false
            end
            if (JustEvade and JustEvade.Evading()) or (ExtLibEvade and ExtLibEvade.Evading) then
                return false
            end
            if not Data:HeroCanAttack() then
                return false
            end
            return Attack:IsReady()
        end
        return Game.Timer() > unit.attackData.endTime
    end
    -- get target
    function Orbwalker:GetTarget()
        if Object:IsValid(self.ForceTarget) and not Object:IsHeroImmortal(self.ForceTarget, true) then
            return self.ForceTarget
        end
        if self.Modes[ORBWALKER_MODE_COMBO] then
            return Target:GetComboTarget()
        end
        if self.Modes[ORBWALKER_MODE_LASTHIT] then
            return Health:GetLastHitTarget()
        end
        if self.Modes[ORBWALKER_MODE_JUNGLECLEAR] then
            local jungle = Health:GetJungleTarget()
            if jungle ~= nil then
                return jungle
            end
        end
        if self.Modes[ORBWALKER_MODE_LANECLEAR] then
            return Health:GetLaneClearTarget()
        end
        if self.Modes[ORBWALKER_MODE_HARASS] then
            return Health:GetHarassTarget()
        end
        return nil
    end
    -- on unkillable minion
    function Orbwalker:OnUnkillableMinion(cb)
        table_insert(Health.OnUnkillableMinionCallbacks, cb);
    end
    -- attack
    function Orbwalker:Attack(unit)
        if not self.Menu.AttackEnabled:Value() then
            return
        end
        if self.AttackEnabled and unit and unit.valid and unit.visible and self:CanAttack() then
            local args = {Target = unit, Process = true}
            for i = 1, #self.OnPreAttackCb do
                self.OnPreAttackCb[i](args)
            end
            if args.Process then
                if args.Target then
                    self.LastTarget = args.Target
                    local targetpos = args.Target.pos
                    local attackpos = targetpos:ToScreen().onScreen and args.Target or myHero.pos:Extended(targetpos, 800)
                    if Control.Attack(attackpos) then
                        Attack.Reset = false
                        Attack.LocalStart = Game.Timer()
                        self.PostAttackBool = true
                    end
                end
                return true
            end
        end
        return false
    end
    -- move
    function Orbwalker:Move()
        if not self.Menu.MovementEnabled:Value() then
            return
        end
        if self.MovementEnabled and self:CanMove() then
            if self.PostAttackBool and not Attack:IsActive(0.025) then
                for i = 1, #self.OnPostAttackCb do
                    self.OnPostAttackCb[i]()
                end
                self.PostAttackTimer = Game.Timer()
                self.PostAttackBool = false
            end
            if not Attack:IsActive(0.025) and Game.Timer() < self.PostAttackTimer + 1 then
                for i = 1, #self.OnPostAttackTickCb do
                    self.OnPostAttackTickCb[i](self.PostAttackTimer)
                end
            end
            local mePos = myHero.pos
            if IsInRange(mePos, mousePos, self.Menu.General.HoldRadius:Value()) then
                if self.CanHoldPosition then
                    Control.Hold(self.HoldPositionButton:Key())
                end
                return
            end
            if GetTickCount() > Movement.MoveTimer then
                local args = {Target = nil, Process = true}
                for i = 1, #self.OnMoveCb do
                    self.OnMoveCb[i](args)
                end
                if not args.Process then
                    return
                end
                if self.ForceMovement ~= nil then
                    Control.Move(self.ForceMovement)
                    return
                end
                if args.Target ~= nil then
                    if args.Target.x then
                        args.Target = Vector(args.Target)
                    elseif args.Target.pos then
                        args.Target = args.Target.pos
                    end
                    Control.Move(args.Target)
                    return
                end
                local pos = IsInRange(mePos, mousePos, 100) and mePos:Extend(mousePos, 100) or nil
                Control.Move(pos)
            end
        end
    end
    -- orbwalk
    function Orbwalker:Orbwalk()
        if not self:Attack(self:GetTarget()) then
            self:Move()
        end
    end
    -- init call
    Orbwalker:__init()
end

_G.SDK =
{
    OnDraw = {},
    OnTick = {},
    OnWndMsg = {},
    Menu = Menu,
    Color = Color,
    Action = Action,
    BuffManager = Buff,
    Damage = Damage,
    Data = Data,
    Spell = Spell,
    SummonerSpell = SummonerSpell,
    ItemManager = Item,
    ObjectManager = Object,
    TargetSelector = Target,
    HealthPrediction = Health,
    Cursor = Cursor,
    Attack = Attack,
    Orbwalker = Orbwalker,
    DAMAGE_TYPE_PHYSICAL = DAMAGE_TYPE_PHYSICAL,
    DAMAGE_TYPE_MAGICAL = DAMAGE_TYPE_MAGICAL,
    DAMAGE_TYPE_TRUE = DAMAGE_TYPE_TRUE,
    ORBWALKER_MODE_NONE = ORBWALKER_MODE_NONE,
    ORBWALKER_MODE_COMBO = ORBWALKER_MODE_COMBO,
    ORBWALKER_MODE_HARASS = ORBWALKER_MODE_HARASS,
    ORBWALKER_MODE_LANECLEAR = ORBWALKER_MODE_LANECLEAR,
    ORBWALKER_MODE_JUNGLECLEAR = ORBWALKER_MODE_JUNGLECLEAR,
    ORBWALKER_MODE_LASTHIT = ORBWALKER_MODE_LASTHIT,
    ORBWALKER_MODE_FLEE = ORBWALKER_MODE_FLEE,
}

Callback.Add('Load', function()
    Object:OnLoad()
    local ticks = SDK.OnTick
    local draws = SDK.OnDraw
    local wndmsgs = SDK.OnWndMsg
    Callback.Add("Draw", function()
        FlashHelper:OnTick()
        Cached:Reset()
        Cursor:OnTick()
        Action:OnTick()
        Attack:OnTick()
        Orbwalker:OnTick()
        for i = 1, #ticks do
            ticks[i]()
        end
        if not Menu.Main.Drawings.Enabled:Value() then
            return
        end
        Target:OnDraw()
        Cursor:OnDraw()
        Orbwalker:OnDraw()
        Health:OnDraw()
        for i = 1, #draws do
            draws[i]()
        end
    end)
    Callback.Add("Tick", function()
        Cached:Reset()
        SummonerSpell:OnTick()
        Item:OnTick()
        Target:OnTick()
        Health:OnTick()
        if not Updated then
            local ok = true
            for i = 1, #GGUpdate.Callbacks do
                local updater = GGUpdate.Callbacks[i]
                updater:OnTick()
                if updater.Step > 0 then
                    ok = false
                end
            end
            if ok then
                Updated = true
            end
        end
    end)
    Callback.Add("WndMsg", function(msg, wParam)
        Data:WndMsg(msg, wParam)
        Spell:WndMsg(msg, wParam)
        Target:WndMsg(msg, wParam)
        for i = 1, #wndmsgs do
            wndmsgs[i](msg, wParam)
        end
    end)
    if _G.Orbwalker then
        _G.Orbwalker.Enabled:Value(false)
        _G.Orbwalker.Drawings.Enabled:Value(false)
    end
end)

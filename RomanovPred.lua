--[[
    Require API
        if FileExist(COMMON_PATH .. "RomanovPred.lua") then
	        require 'RomanovPred'
        end

    Prediction API
        RomanovPredPos(from,to,speed,delay,width)

    Hitchance API
        Hitchance(from,to,speed,delay,width,range)
            0 = out of range
            1 = low
            2 = normal
            3 = high
            4 = very high
            5 = dashing
]]

local RomanovPredVersion = "v2.0"

function Dir(to)
	local topath = to.pathing
	local dir
	if topath.hasMovePath then
		for i = topath.pathIndex, topath.pathCount do
			dir = to:GetPath(i)
        end
    end
	return dir
end

function GetDistance(p1,p2)
    local p2 = p2 or myHero.pos
    return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

function Dash(to)
    local dash = to.pathing
    local dashing
    local dashspeed
    if dash.isDashing then
        local dashing = true
        local dashspeed = dash.dashSpeed
    else
        local dashing = false
        local dashspeed = 0
    end
    return dashing, dashspeed
end

function MoveHandleBuff(to,duration)
    local duration = duration or 0.1
    for i = 0, to.buffCount do
        local buff = to:GetBuff(i);
        if buff.count > 0 then
            if (buff.type == 5 or buff.type == 11 or buff.type == 18 or buff.type == 24 or buff.type == 28 or buff.type == 29 or buff.type == 31) and buff.duration > duration then
                return immobile
            end
            if (buff.type == 9 or buff.type == 10) and buff.duration > duration then
                return slow
            end
        end
    end
end

local splitsecond = 0.01
function RomanovPredPos(from,to,speed,delay,width)
    local distto = GetDistance(from.pos,to.pos)
    local timeto = (distto / speed) + delay
    local dashing, dashspeed = Dash(to)
	local dir = Dir(to)
    if dir == nil or to.isChanneling then return to.pos end

    if dashing == true then
        local movespeed = dashspeed
    end

    local movespeed = to.ms
    local vec = to.pos:Extended(dir, - movespeed * splitsecond)
    local vec2 = vec:Extended(to.pos, width/2 - to.boundingRadius)
    local targtovec = GetDistance(to.pos,vec)
    local speedtimetovec = GetDistance(to.pos,vec) / movespeed

    local disttovec = GetDistance(from.pos,vec)
    local timetovec = (disttovec / speed) + delay

    local result = timetovec - speedtimetovec

    if result < 0 then
        splitsecond = splitsecond + (-1 * (result - 0.01))
    elseif result > 0.02 then
        splitsecond = splitsecond - (result - 0.01)
    else
        splitsecond = splitsecond
	end
	return vec2
end

function RomanovHitchance(from,to,speed,delay,range,width)
    local pred = RomanovPredPos(from,to,speed,delay,width)
    local disttopred = GetDistance(from.pos,pred)
    local timetopred = (disttopred / speed) + delay
    local distto = GetDistance(from.pos,to.pos)
    local timeto = (distto / speed) + delay
    local dashing, timetodash, endpos = Dash(to)

    if disttopred > range then
        return 0
    end
    if dashing == true then
        return 5
    end
    if MoveHandleBuff(to,timeto) == immobile then
        return 4
    end
    if MoveHandleBuff(to,timetopred) == slow then
        return 3
    end
    if timetopred < delay + 0.5 then
        return 3
    end
    if to.isChanneling then
        return 3
    end
    if MoveHandleBuff(to) == slow and not MoveHandleBuff(to,timetopred) == slow then
        return 1
    end
    if timetopred > delay + 1 then
        return 1
    end
    return 2
end

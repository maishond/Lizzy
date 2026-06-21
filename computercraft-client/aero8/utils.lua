function split(str, delimiter)
    local result = {}

    for v in string.gmatch(str, "([^" .. delimiter .. "]+)") do
        result[#result + 1] = v
    end

    return result
end

function clamp(min, v, max)
    if v > max then return max end
    if v < min then return min end
    return v
end

function angle_diff(a, b)
	local d = a - b

	while d > math.pi do
		d = d - math.pi * 2
	end

	while d < -math.pi do
		d = d + math.pi * 2
	end

	return d
end

local navtable = peripheral.find('navigation_table')

function get_state()
	-- ! Get P2 pos (rear)
    local event, side, channel, replyChannel, message, distance

	-- modem = peripheral.find('modem')
	-- modem.open(42) -- p2 (back)  

    -- repeat
    --     event, side, channel, replyChannel, message, distance =
    --         os.pullEvent("modem_message")
    -- until channel == 42

    -- local spl = split(message, " ")

    -- local p2_x = tonumber(spl[1])
    -- local p2_y = tonumber(spl[2])
    -- local p2_z = tonumber(spl[3])
	-- local x = tonumber(spl[1])
    -- local y = tonumber(spl[2])
    -- local z = tonumber(spl[3])

	-- ! P1 pos (front)
    -- repeat
    --     event, side, channel, replyChannel, message, distance =
    --         os.pullEvent("modem_message")
    -- until channel == 40

    -- spl = split(message, " ")

    -- local p2_x = tonumber(spl[1])
    -- local p2_y = tonumber(spl[2])
    -- local p2_z = tonumber(spl[3])

	-- ! Self
    -- local p2_x, p2_y, p2_z = gps.locate(0.1)
    local x, y, z = gps.locate(0.1)
	-- print(p2_x, p2_z)

    if x then
		-- ! Yaw
		yaw = 180 - navtable.getRelativeAngle()
		-- local yaw = 360 - math.deg(math.atan2(p2_x_diff, p2_z_diff))
		-- while yaw < 0 do
		-- 	yaw = yaw + 360
		-- end

		correction_distance = 45
		local corr_x = x + correction_distance * math.cos(math.rad(yaw - 90))
		local corr_z = z + correction_distance * math.sin(math.rad(yaw - 90))


		-- ! Oops
		pitch = -1
		roll = -1

		return corr_x, y, corr_z, pitch, yaw, roll
	end
end
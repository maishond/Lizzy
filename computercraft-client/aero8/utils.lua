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

function get_state()
	-- ! Get P2 pos (rear)
    local event, side, channel, replyChannel, message, distance

	modem = peripheral.find('modem')
	modem.open(40) -- p1 (front)
	modem.open(41) -- p3 (side)
	modem.open(42) -- p2 (back)  

    repeat
        event, side, channel, replyChannel, message, distance =
            os.pullEvent("modem_message")
    until channel == 42

    local spl = split(message, " ")

    -- local p2_x = tonumber(spl[1])
    -- local p2_y = tonumber(spl[2])
    -- local p2_z = tonumber(spl[3])
	local p2_x = tonumber(spl[1])
    local p2_y = tonumber(spl[2])
    local p2_z = tonumber(spl[3])

	-- ! P3 pos (right)
    repeat
        event, side, channel, replyChannel, message, distance =
            os.pullEvent("modem_message")
    until channel == 41

    spl = split(message, " ")

    local p3_x = tonumber(spl[1])
    local p3_y = tonumber(spl[2])
    local p3_z = tonumber(spl[3])

	-- ! P1 pos (front)
    repeat
        event, side, channel, replyChannel, message, distance =
            os.pullEvent("modem_message")
    until channel == 40

    spl = split(message, " ")

    local x = tonumber(spl[1])
    local y = tonumber(spl[2])
    local z = tonumber(spl[3])

	-- ! Self
    -- local p2_x, p2_y, p2_z = gps.locate(0.1)

    -- local x, y, z = gps.locate(0.1)

    if x and p2_x and p3_x then

		local p2_x_diff = p2_x - x
		local p2_y_diff = p2_y - y
		local p2_z_diff = p2_z - z

		local p3_x_diff = p3_x - x
		local p3_y_diff = p3_y - y
		local p3_z_diff = p3_z - z

		-- ! Pitch
		local horizontal_pitch = math.sqrt(p2_x_diff * p2_x_diff + p2_z_diff * p2_z_diff)
		local pitch = math.atan2(p2_y_diff, horizontal_pitch) * 180 / math.pi


		-- ! Yaw
		-- print(math.floor(x), math.floor(y), math.floor(z))
		-- print(math.floor(p2_x), math.floor(p2_y), math.floor(p2_z))
		-- print(math.floor(p3_x), math.floor(p3_y), math.floor(p3_z))
		-- print(math.floor(p2_x_diff), math.floor(p2_z_diff))
		-- local yaw = 360 - (180 + math.atan2(p2_x_diff, p2_z_diff) * 180 / math.pi)
		local yaw = 360 - math.deg(math.atan2(p2_x_diff, p2_z_diff))
		while yaw < 0 do
			yaw = yaw + 360
		end


		-- ! Roll
		local horizontal_roll =math.sqrt(p3_x * p3_x + p3_z_diff * p3_z_diff)
		local roll = math.atan2(p3_y_diff, horizontal_roll) * 180 / math.pi

		return x, y, z, pitch, yaw, roll
	end
end
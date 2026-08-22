leftprop = peripheral.wrap('Create_RotationSpeedController_0')
rightprop = peripheral.wrap('Create_RotationSpeedController_1')

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
	-- ! Self
    local x, y, z = gps.locate(0.1)
    -- local x, y, z = gps.locate(0.1)
    if x then

		local pitch = 0
		local roll = 0
		local yaw = peripheral.wrap('bottom').getRelativeAngle() - 90
		
		return x, y, z, pitch, yaw, roll
	end
end
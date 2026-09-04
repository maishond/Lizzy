leftprop = peripheral.wrap('Create_RotationSpeedController_11')
rightprop = peripheral.wrap('Create_RotationSpeedController_12')

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
	-- ! PC is 13 (?) blocks from the center
	local base_x, y, base_z = gps.locate(0.1)
    if base_x then
		local yaw = peripheral.wrap('navigation_table_3').getRelativeAngle() - 180
		local yaw_rad = math.rad(yaw + 0)
		x = base_x - 13 * math.sin(yaw_rad)
		z = base_z - 13 * math.cos(yaw_rad)

		local pitch = 0
		local roll = 0
		
		return x, y, z, pitch, yaw, roll
	end
end
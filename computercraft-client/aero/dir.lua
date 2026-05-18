function get_power_level (diff)
	local min_diff = 5
	if diff < -min_diff then
		return 1
	elseif diff > min_diff then
		return -1
	end
	return 0
end

function get_directions ()
	local file = fs.open('xz.txt', 'r')
	local s = file.readAll()
	file.close()
	local stuff = s:gmatch("%S+")
	local nx = -1
	local nz = -1
	for w in stuff do 
		if nx == -1 then
			nx = tonumber(w)
		else
			nz = tonumber(w)
		end
	 end
	local desired_x = nx
	local desired_y = nil
	local desired_z = nz
	local x, y, z = gps.locate()

	print('Destination:', nx, nz)

	if y == nil
	 or y < 105
	 then
		return {
			z = 0,
			x = 0
		}
	end

	-- 0 for off, -1 for inverse, 1 for on
	z_diff = z - desired_z
	x_diff = x - desired_x
	return {
		z = get_power_level(z_diff),
		x = get_power_level(x_diff)
	}
end
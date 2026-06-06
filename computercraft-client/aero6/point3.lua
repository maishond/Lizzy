-- ! Write startup override
local file = fs.open('startup-override.lua', 'w')
file.write("require('update')\nrequire('point3')")
file.close()

function mean_gps_locate(samples, timeout)
	local sum_x = 0
	local sum_y = 0
	local sum_z = 0

	local count = 0

	for i = 1, samples do
		local x, y, z = gps.locate(timeout)

		if x and y and z then
			sum_x = sum_x + x
			sum_y = sum_y + y
			sum_z = sum_z + z

			count = count + 1
		end
	end

	if count == 0 then
		return nil
	end

	return
		sum_x / count,
		sum_y / count,
		sum_z / count
end

print('hi3')

local modem = peripheral.wrap('back')

while true do
	-- ! Mean GPS position
	local x, y, z = mean_gps_locate(8, 0.02)

	if x and y and z then
		print(math.floor(x), math.floor(y), math.floor(z))
		modem.transmit(41, 2, string.format('%s %s %s', x, y, z))
	end

	sleep(0.05)
end
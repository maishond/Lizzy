require 'utils'
require 'mods'

local modem = peripheral.wrap('back')

-- ! Take args
local x_or_name_arg, z_arg = ...

keymap = {
	spawn = { x = 156, z = 63 },
	-- base = {x = -636, z = 1349},
	base = {x = -592, z = 1413 },
	-- yogco = {x = 172, z = -15},
	yogco = {x = 123, z = -71 },
	caney = {x = 78, z = 274 },
	p_ = {x = -119, z = 6 },
	howler = {x = 278, z = 87 },
	desert = { x = 2714, z = 651 },
	mc = { x = -121, z = 396 },
	frozen = { x = 730, z = -19 }
}

if x_or_name_arg == nil then
	print('\ngoto usage:')
	print('    goto -579 -4136')
	print('    goto <location>')
	print('    ^ e.g `goto airstrip`')
	print('\nPre-programmed locations:')
	for k,v in pairs(keymap) do
		print(k)
	end
	print('\n')
	return
end

print(x_or_name_arg, z_arg)

function main()

	local x, z
	if keymap[x_or_name_arg] ~= nil then
		print('Location identified:', x_or_name_arg)
		x = keymap[x_or_name_arg]['x']
		z = keymap[x_or_name_arg]['z']
		print(x, z)
	else 
		x = tonumber(x_or_name_arg)
		z = tonumber(z_arg)
		print('X/Z identified:', x, z)
	end
	
	if x and z then
		modem.transmit(1339, 1338, 'OK')
		local file = fs.open('telemetry.txt', 'w')
		cx, cy, cz = get_state()
		print(cx)
		
		while cx == nil do
			cx, cy, cz = get_state()
		end
		
		if cy < 200 then
			-- play_warning()
			file.write('Taking off (to' .. x .. ' ' .. z .. ')')
			file.close()
			take_off()
		end
		
		print('Heading to', x, z)
		stabilise_at(x, z, x_or_name_arg .. ' ' .. (z or ''))
		
		print('Stabilised at co-ords, landing!')
		-- Clear file
		local file = fs.open('telemetry.txt', 'w')
		file.write('Landing')
		file.close()
		land()
		local file = fs.open('telemetry.txt', 'w')
		file.write('')
		file.close()
		 
		print('----')
		print('Thank you for flying with the Zenith!')
	else
		print('Invalid arguments')
		modem.transmit(1339, 1338, 'Invalid arguments')
	end
end

function checkexit()
	while true do
		local current = multishell.getCurrent()
		if fs.exists('delete.txt') then
			local file = fs.open('delete.txt', 'r')
			if file then
				local to_delete = file.readAll()
				print('DO DELETE', to_delete, current, tostring(to_delete) == tostring(current))
				if tostring(to_delete) == tostring(current) then
					shell.run('rm delete.txt')
					return
				end
			end
		end
		coroutine.yield()
	end
end

-- main()
parallel.waitForAny(checkexit, main)
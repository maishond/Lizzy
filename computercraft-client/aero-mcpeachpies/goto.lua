require 'utils'
require 'mods'

-- ! Take args
local x_or_name_arg, z_arg = ...

keymap = {
	spawn = { x = 156, z = 63 },
	-- base = {x = -636, z = 1349},
	house = {x = -13, z = -7},
	-- yogco = {x = 172, z = -15},
	yogco = {x = 123, z = -71},
	caney = {x = 78, z = 274},
	p_ = {x = -119, z = 6},
	howler = {x = 278, z = 87},
	desert = { x = 2714, z = 651 },
	mc = { x = -121, z = 396 },
	frozen = { x = 730, z = -19}
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
	cx, cy, cz = get_state()
	print(cx)
	while cx == nil do
		cx, cy, cz = get_state()
	end
	-- if cy < 200 then
	-- 	play_warning()
	-- 	take_off()
	-- end
	redstone.setAnalogOutput('front', 14)
		
	
	print('Heading to', x, z)
	stabilise_at(x, z)
	
	print('Stabilised at co-ords, landing!')
	play_warning()
	land()
	
	print('----')
	print('Thank you for flying with the M-6')
else
	print('Invalid arguments')
end

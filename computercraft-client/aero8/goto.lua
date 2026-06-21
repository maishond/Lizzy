require 'utils'
require 'mods'

-- ! Open modem
local modem = peripheral.wrap("back")
modem.open(42) -- p2 (back)  
modem.open(41) -- p3 (side)

-- ! Take args
local x_or_name_arg, z_arg = ...

keymap = {
	sting = {x = -762, z = 569},
	wouter = {x = -270, z = -176},
	casper = {x = -1692, z = -183},
	airstrip = {x = -1198, z = -2856},
	airstrip2 = {x = -1255, z = -2849},
	airstrip3 = {x = -1153, z = -2838},
	villagers = {x = -1969, z = -1093},
	factory = {x = -512, z = 213}
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

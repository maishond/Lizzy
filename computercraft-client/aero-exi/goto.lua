require 'utils'
require 'mods'

-- ! Open modem
local modem = peripheral.wrap("back")
modem.open(42) -- p2 (back)  
modem.open(41) -- p3 (side)

redstone.setAnalogOutput('left', 15)
redstone.setAnalogOutput('right', 15)

-- ! Take args
local x_or_name_arg, z_arg = ...

keymap = {
	base = {x = -636, z = 1349},
	project = {x = -119, z = 6},
	howler = {x = 278, z = 87},
	yogco = {x = 172, z = -15},
	caney = {x = 78, z = 274},
	desert = { x = 2714, z = 651 }
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
	while cx == nil do
		cx, cy, cz = get_state()
	end
	if cy < 200 then
		play_warning()
		take_off()
	end
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

require 'utils'
require 'mods'

-- ! Open modem
local modem = peripheral.find("modem")
modem.open(40) -- p1 (front)
modem.open(41) -- p3 (side)
modem.open(42) -- p2 (back)  

-- ! Take args
local x_or_name_arg, z_arg = ...

keymap = {
	spawn = {x = 0, z = 0},
	border = {x = 30000000, z = 30000000},
}

if x_or_name_arg == nil then
	print('\ngoto usage:')
	print('    goto $x $z')
	print('    ^ e.g `goto -579 -4136`')
	print('    goto <location>')
	print('    ^ e.g `goto spawn`')
	print('\nPre-programmed locations:')
	for k,v in pairs(keymap) do
		print('goto', k)
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
	
	print('Heading to', x, z)
	stabilise_at(x, z)
	
	print('Stabilised at co-ords, landing!')
	-- play_warning()
	-- land()
	
	print('----')
	print('Thank you for flying on the Zenith!')
else
	print('Invalid arguments')
end

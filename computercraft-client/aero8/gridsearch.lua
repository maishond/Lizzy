require 'utils'
require 'mods'

-- ! Open modem
local modem = peripheral.find("modem")
modem.open(40) -- p1 (front)
modem.open(41) -- p3 (side)
modem.open(42) -- p2 (back)  

redstone.setAnalogOutput('left', 15)
redstone.setAnalogOutput('right', 15)
redstone.setAnalogOutput('front', 14)

print('Wait')
sleep(30)
print('They don\'t love you like I love you')


X_STEP = 160
Z_OFFSET = 8000

INIT_X = nil

while true do
	x, y, z = get_state()
	while x == nil do
		x, y, z = get_state()
	end

	print('Current', x, y, z)

	
	print('Going to', x + X_STEP, -Z_OFFSET)
	stabilise_at(x + X_STEP, -Z_OFFSET)
	print('Going to', x + X_STEP, Z_OFFSET)
	stabilise_at(x + X_STEP, Z_OFFSET)
end

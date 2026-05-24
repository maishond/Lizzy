-- Write baseUrl to file
local file = fs.open('startup-override.lua', 'w')
file.write("require('update')\nrequire('point2')")
file.close()

print('hi2')

modem = peripheral.wrap('front')

while true do
	x, y, z = gps.locate(0.1)
	print(x, y, z)
	modem.transmit(42, 2, string.format('%s %s %s', x, y, z))
	sleep(0.05)
end
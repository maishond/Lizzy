-- Write baseUrl to file
local file = fs.open('startup-override.lua', 'w')
file.write("require('update')\nrequire('mainsub')")
file.close()

print('hi2')

modem = peripheral.wrap('left')

while true do
	x, y, z = gps.locate()
	print(x, y, z)
	modem.transmit(42, 2, string.format('%s %s %s', x, y, z))
end
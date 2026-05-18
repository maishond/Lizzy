print('lol')
require('dir')

x_pos = 'top'
x_neg = 'front'
z_neg = 'left'
z_pos = 'right'

while true do
	dir = get_directions()

	print(dir['x'], dir['z'])
	redstone.setOutput(x_pos, dir['x'] == 1)
	redstone.setOutput(x_neg, dir['x'] == -1)
	
	redstone.setOutput(z_pos, dir['z'] == 1)
	redstone.setOutput(z_neg, dir['z'] == -1)
end
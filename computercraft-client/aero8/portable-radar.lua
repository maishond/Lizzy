
-- Write startup override
local file = fs.open("startup-override.lua", "w")
file.write("require('update')\nrequire('portable-radar')")
file.close()

require 'utils'

local modem = peripheral.find('modem')
modem.open(69)

positions = {}

WIDTH = 26
HEIGHT = 20

colors = {
	colours.green,
	colours.blue,
	colours.red,
	colours.white,
}

function render()
	px, py, pz = gps.locate(0.1)
	if px == nil then return nil end

	term.clear()
	
	x = 1
	y = 0
	i = 1
	c = {}
	-- Name selection
	for name, pos in pairs(positions) do
		c[name] = colors[(i - 1 % #colors) + 1]
		term.setCursorPos(1, y + 1)
		term.setTextColour(c[name])
		
		if x == 1 then
			y = y + 1
			x = WIDTH / 2 + 1
		else
			x = 1
		end
		term.setCursorPos(x, y)
		i = i + 1
		term.write(name)
	end

	term.setCursorPos(1, y + 1)
	term.setTextColour(colours.grey)
	term.write('--------------------------')

	-- !
	START = y + 1
	END = HEIGHT
	term.setCursorPos(WIDTH / 2, y + 1)
	term.write('N')
	term.setCursorPos(WIDTH, START + ((END - START) / 2))
	term.write('E')
	term.setCursorPos(WIDTH / 2, END)
	term.write('S')
	term.setCursorPos(1, START + ((END - START) / 2))
	term.write('W')

	CENTER_X = WIDTH / 2
	CENTER_Y = START + ((END - START) / 2)

	SMALLEST_X = 0
	LARGEST_X = 0
	SMALLEST_Z = 0
	LARGEST_Z = 0
	LARGEST_Z_DIFF = 0
	LARGEST_X_DIFF = 0

	for name, pos in pairs(positions) do
		X_DIFF = px - pos['x']
		Z_DIFF = pz - pos['z']
		if Z_DIFF > LARGEST_Z then LARGEST_Z = Z_DIFF end
		if Z_DIFF < SMALLEST_Z then SMALLEST_Z = Z_DIFF end
		if X_DIFF < LARGEST_X then LARGEST_X = X_DIFF end
		if X_DIFF < SMALLEST_X then SMALLEST_X = X_DIFF end

		if math.abs(X_DIFF) > LARGEST_X_DIFF then LARGEST_X_DIFF = math.abs(X_DIFF) end
		if math.abs(Z_DIFF) > LARGEST_Z_DIFF then LARGEST_Z_DIFF = math.abs(Z_DIFF) end
	end
	
	X_SCALE_FACTOR = (WIDTH - 4) / LARGEST_X_DIFF
	Z_SCALE_FACTOR = ((HEIGHT - START) - 2) / LARGEST_Z_DIFF

	i = 1
	for name, pos in pairs(positions) do
		term.setTextColour(c[name])
		X_DIFF = px - pos['x']
		Z_DIFF = pz - pos['z']
		
		X_ON_SCREEN = CENTER_X - X_DIFF * (X_SCALE_FACTOR / 2)
		Y_ON_SCREEN = CENTER_Y - Z_DIFF * (Z_SCALE_FACTOR / 2)
		DESC = math.floor(math.sqrt(X_DIFF ^ 2 + Z_DIFF ^ 2))
		term.setCursorPos(X_ON_SCREEN - math.floor(#tostring(DESC) / 2), Y_ON_SCREEN)
		term.write(DESC)
		i = i + 1
	end

	term.setCursorPos(CENTER_X, CENTER_Y)
	term.setTextColour(colours.grey)
	term.write('O')
end

while true do
	local event, side, channel, replyChannel, message, distance

    repeat
        event, side, channel, replyChannel, message, distance =
            os.pullEvent("modem_message")
    until channel == 69

	spl1 = split(message, ' / ')
	name = spl1[1]
	x = tonumber(spl1[2])
	y = tonumber(spl1[3])
	z = tonumber(spl1[4])

	positions[name] ={x=x, y=y, z=z}
	-- print(table.unpack(positions))
	render()
	
	-- print(message)
end
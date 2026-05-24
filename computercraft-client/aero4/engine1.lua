require 'utils'
-- Write baseUrl to file
local file = fs.open('startup-override.lua', 'w')
file.write("require('update')\nrequire('engine1')")
file.close()

c = 43
peripheral.wrap("top").open(c)

while true do
	-- Get power level
	local event, side, channel, replyChannel, message, distance
	repeat
		event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
	until channel == c
	spl = split(message, ' ')
	power = spl[1]
	inverted = spl[2]
	print(inverted)
	redstone.setOutput('back', inverted == 'true')
	redstone.setAnalogOutput('bottom', tonumber(power))

	::continue::
end
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
	print(message)
	redstone.setAnalogOutput('bottom', tonumber(message))

	::continue::
end
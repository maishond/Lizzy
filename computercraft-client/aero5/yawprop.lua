-- ! Write startup override
local file = fs.open('startup-override.lua', 'w')
file.write("require('update')\nrequire('yawprop')")
file.close()

print("yaw prop")

local modem = peripheral.wrap("bottom")
modem.open(43)

while true do
	local event, side, channel, replyChannel, message, distance
	repeat
        event, side, channel, replyChannel, message, distance =
            os.pullEvent("modem_message")
    until channel == 43

	local nv = tonumber(message)
	redstone.setAnalogOutput('left', 0)
	redstone.setAnalogOutput('right', 0)
	redstone.setAnalogOutput('back', 0)

	print(nv)
	
	if nv < 0.3 and nv > -300 then
		redstone.setAnalogOutput('right', 15)
	elseif nv > 0.3  then
		redstone.setAnalogOutput('left', 15)
	end
	if math.abs(nv) < 1 and nv > -300 then
		redstone.setAnalogOutput('back', 15)
	end

end
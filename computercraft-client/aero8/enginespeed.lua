-- ! Write startup override
local file = fs.open('startup-override.lua', 'w')
file.write("require('update')\nrequire('enginespeed')")
file.close()

print('Engine speed controller!')

local modem = peripheral.find('modem')

leftprop = peripheral.wrap('left')
rightprop = peripheral.wrap('right')

while true do
	local event, side, channel, replyChannel, leftvalue, rightvalue, distance

	modem = peripheral.find('modem')
	modem.open(88) -- left
	modem.open(89) -- right

    repeat
        event, side, channel, replyChannel, leftvalue, distance =
            os.pullEvent("modem_message")
    until channel == 88

	repeat
        event, side, channel, replyChannel, rightvalue, distance =
            os.pullEvent("modem_message")
    until channel == 89

	print(leftvalue, rightvalue)
	leftprop.setTargetSpeed(leftvalue)
	rightprop.setTargetSpeed(rightvalue)
	
end
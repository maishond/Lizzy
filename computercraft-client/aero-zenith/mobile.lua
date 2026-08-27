local modem = peripheral.find('modem')

modem.open(1337) -- Zenith Master PC telemetry

os.setComputerLabel('Zenith Mobile')

print('Yippee mobile')

while true do
    -- Await message
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent('modem_message')
    until channel == 1337
    print(message)
end
local modem = peripheral.find('modem')

local a, b = ...

modem.open(1339)

local x, y, z
while not x do
    x, y, z = gps.locate(0.1)
end

modem.transmit(1338, 1339, { command = 'lower', args = a or 15 })

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if channel == 1339 then
        print(message)
        if message == 'OK' then
            shell.run('bg')
            shell.exit()
            break
        end
    end
end

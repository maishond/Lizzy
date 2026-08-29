local modem = peripheral.find('modem')

local a, b = ...

modem.open(1339)

modem.transmit(1338, 1339, { command = 'goto', args = a .. ' ' .. (b or '') })

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

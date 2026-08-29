local modem = peripheral.wrap('back')
if not modem then
    error('No modem found')
end

modem.open(1338)

function cleanfirst()
    -- Remove all tabs that might interfere
    local tabcount = multishell.getCount()
    for i=1,tabcount do
        local title = multishell.getTitle(i)
        print(i, title)
        if title == 'goto' then
            -- Close tab
            print('Close', i, title)
            local file = fs.open('delete.txt', 'w')
            file.write(i)
            file.close()
        end
    end
end

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if channel == 1338 then
        print(message)

        for key, value in pairs(message or {}) do
            print(key, ': ', value)
        end

        local cmd = message['command']

        if cmd == 'goto' or cmd == 'lower' then
            cleanfirst()
            shell.run('bg', cmd, message['args'])
        end
        if cmd == 'stop' 
        or cmd == 'invert' 
        or cmd == 'reset' 
        or cmd == 'flip'
        or cmd == 'takeoff'
        or cmd == 'land'
         then
            cleanfirst()
            shell.run('bg', cmd)
            modem.transmit(1339, 1340, 'OK')
        end
    end
end
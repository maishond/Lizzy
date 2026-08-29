require 'utils'

local modem = peripheral.wrap('back')

while true do
    local x, y, z = gps.locate(0.1)
    local heading = navtable.getRelativeAngle() - 90

    if x then
        s = ''
        print('TELEMETRY')
        s = s .. 'X:       ' .. math.floor(x) .. '\n'
        s = s .. 'Y:       ' .. math.floor(y) .. '\n'
        s = s .. 'Z:       ' .. math.floor(z) .. '\n'
        s = s .. 'Heading: ' .. math.floor(heading)
        s = s .. '\n\n--------\n\n'

        -- Read telemetry from 'telemetry.txt' file
        if fs.exists('telemetry.txt') then
            local file = fs.open('telemetry.txt', 'r')
            local telemetry = file.readAll()
            file.close()
            s = s .. telemetry
        end
        print(s)
        modem.transmit(1337, 1335, s)
        os.sleep(0.25)
    end
end
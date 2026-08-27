require 'utils'

local modem = peripheral.wrap('back')

while true do
    local x, y, z = gps.locate(0.1)
    local heading = navtable.getRelativeAngle() - 90

    if x then
        s = ''
        print('TELEMETRY')
        s = s .. 'X:       ' .. x .. '\n'
        s = s .. 'Y:       ' .. y .. '\n'
        s = s .. 'Z:       ' .. z .. '\n'
        s = s .. 'Heading: ' .. heading
        print(s)
        modem.transmit(1337, 1335, s)
    end
end
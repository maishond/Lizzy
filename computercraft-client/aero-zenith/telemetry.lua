require 'utils'

local modem = peripheral.wrap('back')
local gimbal = peripheral.wrap('gimbal_sensor_0')


while true do
    local x, y, z = gps.locate(0.1)
    local heading = navtable.getRelativeAngle() - 90
    
    local angles = gimbal.getAngles()
    local pitch = angles[1]
    local roll = angles[2]

    if x then
        s = ''
        print('TELEMETRY')
        -- s = s .. 'X:       ' .. math.floor(x) .. '\n'
        -- s = s .. 'Y:       ' .. math.floor(y) .. '\n'
        -- s = s .. 'Z:       ' .. math.floor(z) .. '\n'
        s = s .. '    ' .. string.rep(' ', 5 - #tostring(math.floor(x))) .. math.floor(x) .. ' ' .. math.floor(y) .. ' ' .. math.floor(z)

        s = s .. '\nY: ' .. math.floor(heading) .. '  P: ' .. string.format("%.2f", pitch) .. '  R: ' .. string.format("%.2f", roll)
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
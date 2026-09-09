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
        s = s .. math.floor(x) .. ' ' .. math.floor(y) .. ' ' .. math.floor(z)
        s = s .. '\nEngine RPM: ' .. speedometer.getSpeed()

        local stress_capacity = stressometer.getStressCapacity()
        local stress = stressometer.getStress()
        local stress_used_percentage = math.floor((stress / stress_capacity * 100) + 0.5) 
        local engine_status = 'operational' .. ' (' .. stress_used_percentage .. '%)'
        if stress_used_percentage > 100 then
            engine_status = 'overstressed' .. ' (' .. stress_used_percentage .. '%)'
        end
        if stress_capacity < FULL_CAPACITY then
            engine_status = 'Starting (' .. math.floor(stress_capacity / FULL_CAPACITY * 100 + 0.5) .. ')'
        end

        s = s .. '\nEngine: ' .. engine_status
        s = s .. '\nY:' .. math.floor(heading) .. ' P:' .. string.format("%.2f", pitch) .. ' R:' .. string.format("%.2f", roll)
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
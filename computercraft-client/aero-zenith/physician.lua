require 'utils'

local disabled = false

while true do
    local stress_capacity = stressometer.getStressCapacity()
    local stress = stressometer.getStress()
    local stress_used_percentage = math.floor((stress / stress_capacity * 100) + 0.5) 
    print(stress_used_percentage .. '% stress')
    print(math.floor(stress_capacity / FULL_CAPACITY * 100 + 0.5) .. '% of full capacity')
    print('Total capacity: ' .. math.floor(stress_capacity) .. ' of desired ' .. math.floor(FULL_CAPACITY))
    if stress_used_percentage > 100 or stress_capacity < FULL_CAPACITY then
        disabled = true
        if stress_used_percentage > 100 then
            leftprops.setTargetSpeed(0)
            rightprops.setTargetSpeed(0)
            local current_speed = frontprops.getTargetSpeed()
            local new_speed = current_speed - 5
            if new_speed < 0 then
                new_speed = 0
            end
            frontprops.setTargetSpeed(new_speed)
            rearprops.setTargetSpeed(new_speed * reartofrontratio)
            print("Overstressed, reducing speed to " .. new_speed)
        end
        
        local telfile = fs.open('telemetry.txt', 'w')
        telfile.write('SHIP IS RECOVERING FROM OVERSTRESS, ENGINE ' .. math.floor(stress_capacity / FULL_CAPACITY * 100) .. '% recovered')
        telfile.close()
        print('HELLO 2')


    elseif frontprops.getTargetSpeed() == 0 and disabled and stress_capacity >= FULL_CAPACITY then
        disabled = false
        frontprops.setTargetSpeed(MIN_VERT_POWER)
        rearprops.setTargetSpeed(MIN_VERT_POWER * reartofrontratio)

        local telfile = fs.open('telemetry.txt', 'w')
        telfile.write('Engine recovered from crash')
        telfile.close()
    end

    sleep(0.1)
end
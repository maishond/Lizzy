require 'utils'

local modem = peripheral.wrap('back')

leftprops.setTargetSpeed(0)
rightprops.setTargetSpeed(0)

for i=frontprops.getTargetSpeed(), MIN_VERT_POWER, -5 do
    print(i)
    frontprops.setTargetSpeed(i)
    rearprops.setTargetSpeed(i * reartofrontratio)
    modem.transmit(1339, 1340, 'Power now at ' .. i)
    os.sleep(0.5)
end

frontprops.setTargetSpeed(MIN_VERT_POWER)
rearprops.setTargetSpeed(MIN_VERT_POWER * reartofrontratio)

-- modem.transmit(1339, 1340, 'Power now at ' .. i)
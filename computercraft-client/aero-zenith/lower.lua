require 'utils'

require 'reset'

local points = tonumber(...)

local msg = 'Lowering power by ' .. points .. ' points'
local modem = peripheral.wrap('back')
print(msg)
modem.transmit(1339, 1340, msg)

for i=frontprops.getTargetSpeed(), frontprops.getTargetSpeed() - points, -5 do
    print(i)
    frontprops.setTargetSpeed(i)
    modem.transmit(1339, 1340, 'Power now at ' .. i)
    rearprops.setTargetSpeed(i * reartofrontratio)
    os.sleep(0.5)
end

sleep(2)

modem.transmit(1339, 1340, 'OK')
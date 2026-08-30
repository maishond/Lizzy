
require 'utils'

print('Going up')


-- rearprops.setTargetSpeed(256)
-- frontprops.setTargetSpeed(-256)

-- for i=frontprops.getTargetSpeed(), MAX_VERT_POWER, 5 do
--     print(i)
--     frontprops.setTargetSpeed(i)
--     rearprops.setTargetSpeed(i * reartofrontratio)
--     sleep(0.5)
-- end

-- print('Up, waiting 15 seconds before inverting')

-- sleep(15)

-- print('FLIP IT!')

rearprops.setTargetSpeed(-256)
frontprops.setTargetSpeed(256)

sleep(3)
print('Reset!')

rearprops.setTargetSpeed(256 * reartofrontratio)
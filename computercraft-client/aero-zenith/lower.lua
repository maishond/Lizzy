require 'utils'

local points = tonumber(...)

print('Lowering power by ' .. points .. 'points')

for i=frontprops.getTargetSpeed(), frontprops.getTargetSpeed() - points, -5 do
    print(i)
    frontprops.setTargetSpeed(i)
    rearprops.setTargetSpeed(i * reartofrontratio)
    os.sleep(0.5)
end
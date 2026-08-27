require 'utils'

for i=frontprops.getTargetSpeed(), MAX_VERT_POWER, 5 do
    print(i)
    frontprops.setTargetSpeed(i)
    rearprops.setTargetSpeed(i * reartofrontratio)
    sleep(0.5)
end

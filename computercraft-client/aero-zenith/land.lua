require 'utils'

for i=frontprops.getTargetSpeed(), MIN_VERT_POWER, -5 do
    print(i)
    frontprops.setTargetSpeed(i)
    rearprops.setTargetSpeed(i * reartofrontratio)
    os.sleep(0.5)
end

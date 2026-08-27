require 'utils'

for i=0,10 do
    l = frontprops.getTargetSpeed()
    if math.abs(l) < 250 then
        l = 256
    end
    frontprops.setTargetSpeed(-l)
    rearprops.setTargetSpeed(-l * reartofrontratio)
end
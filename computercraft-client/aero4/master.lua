-- Write startup override
local file = fs.open("startup-override.lua", "w")
file.write("require('update')\nrequire('master')")
file.close()
require 'mods'

print("Flight controller starting...")

local modem = peripheral.find("modem")

modem.open(42) -- p2 (back)
modem.open(41) -- p3 (right)


-- ! Main loop
print(1)
-- navigate_to(0, 0)
print(2)
-- while true do

    
			
-- 		-- ! Do whatever the state machine says
-- 		-- TODO obv
--         -- stabilise(x, y, z, roll, pitch, yaw)

--     end

--     sleep(0.05)
-- end
stabilise_at(-1650, 120, -210, 0, 0, 0)
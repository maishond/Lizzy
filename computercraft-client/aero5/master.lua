-- Write startup override
local file = fs.open("startup-override.lua", "w")
file.write("require('update')\nrequire('master')")
file.close()


-- ! Ports docs
-- ! 42 is point 2 (back)
-- ! 41 is point 3 (side)
------------

last_yaw = 0

require 'mods'

print("Flight controller starting...")

local modem = peripheral.wrap("back")

modem.open(42) -- p2 (back)
modem.open(41) -- p3 (side)


-- ! Main loop
print('Go')

stabilise_at(999999999, 0, 0, 0, 0, 0)

-- stabilise_at(0, 0, 0, 0, 0, 0)
-- stabilise_at(2500, 0, 2500, 0, 0, 0)
-- stabilise_at(-1000, 0, 0, 0, 0, 0)
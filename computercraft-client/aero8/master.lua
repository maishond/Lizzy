-- Write startup override
local file = fs.open("startup-override.lua", "w")
file.write("require('update')\nrequire('master')")
file.close()


-- ! Ports docs
-- ! 42 is point 2 XYZ (back)
-- ! 41 is point 3 XYZ (side)
------------

require 'mods'

print("Flight controller starting...")

local modem = peripheral.find("modem")

require 'reset'


-- ! Main loop
print('Main initialised')

-- thou = 1000
-- stabilise_at(50 * thou, 0, 0, 0, 0, 0)

-- stabilise_at(-283, 95, -177, 0, 0, 0) -- wouter airstrip
-- stabilise_at(-348, 136, 2, 0, 0, 0) -- wouter huis
-- stabilise_at(-1686, 78, -186, 0, 0, 0) -- casper
-- stabilise_at(-608, 42, 2034, 0, 0, 0) -- ocean
-- stabilise_at(-1258, 69, -2934, 0, 0, 0) -- NEW airport

-- stabilise_at(0, 0, 0, 0, 0, 0)
-- stabilise_at(299, 0, 2286, 0, 0, 0)
-- stabilise_at(2500, 0, 2500, 0, 0, 0)
-- stabilise_at(-1000, 0, 0, 0, 0, 0)
-- stabilise_at(5000, 0, 0, 0, 0, 0)

b = 30000
-- stabilise_at(0, 0)
-- stabilise_at(b, 0)
-- stabilise_at(b, b)
-- stabilise_at(-b, b)
-- stabilise_at(-b, -b)
-- stabilise_at(b, -b)
-- stabilise_at(b, 0)
-- stabilise_at(-348, 2) -- wouter huis
-- Write baseUrl to file
local file = fs.open('startup-override.lua', 'w')
file.write("require('update')\nrequire('master')")
file.close()

print('hi3')
local modem = peripheral.wrap("front")
modem.open(42)

local function set_eng1(l) 
	modem.transmit(43, 0, l)
end

local function set_eng2(l) 
	modem.transmit(44, 0, l)
end

local function set_eng3(l) 
	modem.transmit(45, 0, l)
end

local function set_eng4(l) 
	modem.transmit(46, 0, l)
end

while true do
	-- for i=1,15 do
	-- 	set_eng1(i)
	-- 	set_eng2(i)
	-- 	print(i)
	-- 	sleep(1)
	-- end
	set_eng1(0)
	set_eng2(0)
	set_eng3(0)
	set_eng4(0)
	sleep(5)
	set_eng1(0)
	set_eng2(0)
	set_eng3(15)
	set_eng4(15)
	sleep(5)
	set_eng1(15)
	set_eng2(15)
	set_eng3(0)
	set_eng4(0)
	sleep(5)
end

-- local DESIRED_X = 0
-- local DESIRED_Z = 0

-- local function split(str, delimiter)
--     local returnTable = {}
--     for k, v in string.gmatch(str, "([^" .. delimiter .. "]+)") 
--     do
--         returnTable[#returnTable+1] = k
--     end
--     return returnTable
-- end

-- while true do
-- 	-- Remote X, Z
-- 	local event, side, channel, replyChannel, message, distance
-- 	repeat
-- 		event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
-- 	until channel == 42
-- 	local spl = split(message, ' ')
-- 	local xr = tonumber(spl[1])
-- 	local zr = tonumber(spl[3])

-- 	-- Self X, z
-- 	local x, y, z = gps.locate()
-- 	if x == nil or xr == nil then
-- 		goto continue
-- 	end

-- 	local x_diff = x - xr
-- 	local z_diff = z - zr
-- 	local angle = math.atan2(x_diff, z_diff)

-- 	local X_DIFF = x - DESIRED_X
-- 	local Z_DIFF = z - DESIRED_Z
-- 	local DESIRED_ANGLE = math.atan2(X_DIFF, Z_DIFF) + math.pi / 2
-- 	-- Difference between current and desired angle
-- 	local angle_diff = DESIRED_ANGLE - angle

-- 	-- Normalize to -pi .. pi
-- 	while angle_diff > math.pi do
-- 		angle_diff = angle_diff - (2 * math.pi)
-- 	end
-- 	while angle_diff < -math.pi do
-- 		angle_diff = angle_diff + (2 * math.pi)
-- 	end

-- 	-- Determine direction
-- 	local desired_direction

-- 	if math.abs(angle_diff) < 0.1 then
-- 		desired_direction = "forward"
-- 	elseif angle_diff > 0 then
-- 		desired_direction = "left"
-- 	else
-- 		desired_direction = "right"
-- 	end
	
-- 	rr = desired_direction == 'right' and math.min(15, math.max(math.floor((-angle_diff / 8) * 15), 0)) or 0
-- 	lr = desired_direction == 'left' and math.min(15, math.max(math.floor((angle_diff / 8) * 15), 0)) or 0
-- 	br = math.abs(angle_diff)  < 0.5 and 1 or 0
-- 	print(fr, lr, angle_diff)
-- 	redstone.setAnalogOutput('right', rr)
-- 	redstone.setAnalogOutput('left', lr)
-- 	redstone.setAnalogOutput('back', br)

-- 	-- print("Angle:", angle)
-- 	print("Direction:", desired_direction)
-- 	::continue::
-- end
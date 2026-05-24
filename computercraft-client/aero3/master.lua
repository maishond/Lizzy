-- Write startup override
local file = fs.open("startup-override.lua", "w")
file.write("require('update')\nrequire('master')")
file.close()
require 'mods'

print("Flight controller starting...")

local modem = peripheral.wrap("front")

modem.open(42) -- p2 (back)
modem.open(41) -- p3 (right)



local function split(str, delimiter)
    local result = {}

    for v in string.gmatch(str, "([^" .. delimiter .. "]+)") do
        result[#result + 1] = v
    end

    return result
end

-- =========================================================
-- MAIN LOOP
-- =========================================================


while true do

    -- =====================================================
    -- RECEIVE P2 (BACK)
    -- =====================================================

    local event, side, channel, replyChannel, message, distance

    repeat
        event, side, channel, replyChannel, message, distance =
            os.pullEvent("modem_message")
    until channel == 42

    local spl = split(message, " ")

    local p2_x = tonumber(spl[1])
    local p2_y = tonumber(spl[2])
    local p2_z = tonumber(spl[3])

    -- =====================================================
    -- RECEIVE P3 (RIGHT)
    -- =====================================================

    repeat
        event, side, channel, replyChannel, message, distance =
            os.pullEvent("modem_message")
    until channel == 41

    spl = split(message, " ")

    local p3_x = tonumber(spl[1])
    local p3_y = tonumber(spl[2])
    local p3_z = tonumber(spl[3])

    -- =====================================================
    -- SELF POSITION
    -- =====================================================

    local x, y, z = gps.locate(0.1)

    if x and p2_x and p3_x then

		-- =====================================================
		-- PITCH CALCULATION
		--
		-- Main unit = front
		-- p2 = back
		-- =====================================================

		local p2_x_diff = p2_x - x
		local p2_y_diff = p2_y - y
		local p2_z_diff = p2_z - z

		local horizontal_pitch =
			math.sqrt(
				p2_x_diff * p2_x_diff +
				p2_z_diff * p2_z_diff
			)

		local pitch_deg =
			math.atan2(
				p2_y_diff,
				horizontal_pitch
			) * 180 / math.pi

		-- =====================================================
		-- YAW CALCULATION
		--
		-- Front -> Back vector projected onto XZ plane
		-- =====================================================

		local yaw_deg =
			math.atan2(
				p2_z_diff,
				p2_x_diff
			) * 180 / math.pi

		-- Optional normalize to 0-360

		if yaw_deg < 0 then
			yaw_deg = yaw_deg + 360
		end

		-- =====================================================
		-- ROLL CALCULATION
		--
		-- p2 = back
		-- p3 = right
		-- =====================================================

		local p3_dx = p3_x - p2_x
		local p3_dy = p3_y - p2_y
		local p3_dz = p3_z - p2_z

		local horizontal_roll =
			math.sqrt(
				p3_dx * p3_dx +
				p3_dz * p3_dz
			)

		local roll_deg =
			math.atan2(
				p3_dy,
				horizontal_roll
			) * 180 / math.pi
			
		-- stabilise(pitch_deg, roll_deg, yaw_deg, x, y, z) 
		fly_to(0, 0, 0, pitch_deg, roll_deg, yaw_deg, x, y, z) 

end

    sleep(0.05)
end
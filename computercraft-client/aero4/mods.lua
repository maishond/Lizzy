require 'utils'
local modem = peripheral.wrap("front")
modem.open(42)
modem.open(41)

local function set_frontleft(l, inverted) 
	modem.transmit(43, 0, tostring(15 - l) .. ' ' .. tostring(inverted or false))
end

local function set_frontright(l, inverted) 
	modem.transmit(44, 0, tostring(15 - l) .. ' ' .. tostring(inverted or false))
end

local function set_rearright(l, inverted) 
	modem.transmit(45, 0, tostring(15 - l) .. ' ' .. tostring(inverted or false))
end

local function set_rearleft(l, inverted) 
	modem.transmit(46, 0, tostring(15 - l) .. ' ' .. tostring(inverted or false))
end

function stabilise_at(px, py, pz, ppitch, pyaw, proll)
	while true do
		x, y, z, pitch, yaw, roll = get_state()
		if x then
			x_diff = x - px
			y_diff = y - py
			z_diff = z - pz
			print(x_diff, z_diff)
			pitch_diff = pitch - ppitch
			yaw_diff = yaw - pyaw
			roll_diff = roll - proll

			MAX_CORRECT_STRENGTH = 3
			BASE_STRENGTH = 10

			DIV_ROLL = 10
			DIV_PITCH = 10
			DIV_Y = 5

			-- ! Correct roll
			roll_power = math.floor(clamp(0, math.abs(roll_diff / DIV_ROLL) * MAX_CORRECT_STRENGTH, MAX_CORRECT_STRENGTH) + 0.5)
			if roll_diff < 0 then roll_power = -roll_power end

			-- ! Correct pitch
			pitch_power = math.floor(clamp(0, math.abs(pitch_diff / DIV_PITCH) * MAX_CORRECT_STRENGTH, MAX_CORRECT_STRENGTH) + 0.5)
			if pitch_diff < 0 then pitch_power = -pitch_power end

			-- ! Correct Y
			-- y_diff = -y_diff
			y_power = math.floor(clamp(0, math.abs(y_diff / DIV_Y) * 4, 4) + 0.5)
			if y_diff < 0 then y_power = -y_power end
			if math.abs(pitch_diff) + math.abs(roll_diff) > 20 then
				y_diff = 0
			end -- Let it stabilise first

			-- ! Angle to target
			angle_from_target = ((360 - (yaw - (math.atan2(z_diff, x_diff) * 180 / math.pi) - 90)) - 360)

			-- 90 deg = to the right
			-- 180 deg = go back
			-- 270 deg = go left
			fl_angle = -45
			rl_angle = -135
			fr_angle = 45
			rr_angle = 135

			-- MAX_XZ_CORR = 4

			-- fl_power = clamp(0, ((1 - (1 + math.cos(math.rad((angle_from_target - fl_angle)))) / 2)) * MAX_XZ_CORR, MAX_XZ_CORR)
			-- fr_power = clamp(0, ((1 - (1 + math.cos(math.rad((angle_from_target - fr_angle)))) / 2)) * MAX_XZ_CORR, MAX_XZ_CORR)
			-- rr_power = clamp(0, ((1 - (1 + math.cos(math.rad((angle_from_target - rr_angle)))) / 2)) * MAX_XZ_CORR, MAX_XZ_CORR)
			-- rl_power = clamp(0, ((1 - (1 + math.cos(math.rad((angle_from_target - rl_angle)))) / 2)) * MAX_XZ_CORR, MAX_XZ_CORR)
			-- if -y_diff > 10 and false then
				fl_power = 0
				fr_power = 0
				rr_power =0
				rl_power = 0
			-- end

			print(roll_power, pitch_power, y_power)
			
			-- ! Calculate propellor strength
			fl = BASE_STRENGTH + roll_power + pitch_power + y_power + fl_power
			fr = BASE_STRENGTH - roll_power + pitch_power + y_power + fr_power
			rl = BASE_STRENGTH + roll_power - pitch_power + y_power + rl_power
			rr = BASE_STRENGTH - roll_power - pitch_power + y_power + rr_power

			-- ! Determine directions
			turn_left = false
			turn_right = false
			desired_yaw = pyaw
		
			local yaw_error = (desired_yaw - yaw + 180) % 360 - 180

			turn_left = yaw_error < 0
			turn_right = yaw_error > 0
				
			print(yaw)
			set_frontleft(clamp(0, fl, 15), false)
			set_frontright(clamp(0, fr, 15), false)
			set_rearleft(clamp(0, rl, 15), false)
			set_rearright(clamp(0, rr, 15), false)
		end
	end
end

stabilise_at(300, -300, 0, 0, 0, 0)
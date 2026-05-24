require 'utils'
local modem = peripheral.find("modem")
modem.open(42)
modem.open(41)

function set_front(power_level)
	if power_level == 0 then power_level = 15 end
	redstone.setAnalogOutput('front', power_level)
end

function set_rear(power_level)
	if power_level == 0 then power_level = 15 end
	redstone.setAnalogOutput('back', power_level)
end

function set_right(power_level)
	if power_level == 0 then power_level = 15 end
	redstone.setAnalogOutput('left', power_level)
end

function set_left(power_level)
	if power_level == 0 then power_level = 15 end
	redstone.setAnalogOutput('right', power_level)
end

function stabilise_at(px, py, pz, ppitch, pyaw, proll)
	while true do
		x, y, z, pitch, yaw, roll = get_state()
		-- print(x, y, z)
		print('Current P/Y/R:', pitch, yaw, roll)
		if x then
			x_diff = x - px
			y_diff = y - py
			z_diff = z - pz
			-- print(x_diff, z_diff)
			pitch_diff = pitch - ppitch
			yaw_diff = yaw - pyaw
			roll_diff = roll - proll

			MAX_CORRECT_STRENGTH = 4
			BASE_STRENGTH = 10

			DIV_ROLL = 5
			DIV_PITCH = 5
			DIV_Y = 5

			-- ! Correct roll
			roll_power = math.floor(clamp(0, math.abs(roll_diff / DIV_ROLL) * MAX_CORRECT_STRENGTH, MAX_CORRECT_STRENGTH) + 0.5)
			if roll_diff < 0 then roll_power = -roll_power end

			-- ! Correct pitch
			pitch_power = math.floor(clamp(0, math.abs(pitch_diff / DIV_PITCH) * MAX_CORRECT_STRENGTH, MAX_CORRECT_STRENGTH) + 0.5)
			if pitch_diff < 0 then pitch_power = -pitch_power end

			-- ! Correct Y
			-- y_diff = -y_diff
			y_power = math.floor(clamp(0, math.abs(y_diff / DIV_Y) * 2, 2) + 0.5)
			if y_diff < 0 then y_power = -y_power end
			if math.abs(pitch_diff) + math.abs(roll_diff) > 20 then
				y_diff = 0
			end -- Let it stabilise first

			-- ! Angle to target
			angle_from_target = ((360 - (yaw - (math.atan2(z_diff, x_diff) * 180 / math.pi) - 90)) - 360)
			-- MAX_XZ_CORR = 4

			
			
			if -y_diff > 10 then
				fl_power = 0
				fr_power = 0
				rr_power =0
				rl_power = 0
			end

			print('Roll, pitch, y power:', roll_power, pitch_power, y_power)
			
			-- ! Calculate propellor strength
			front = BASE_STRENGTH - pitch_power + y_power + fl_power
			rear = BASE_STRENGTH + pitch_power + y_power + fr_power
			left = BASE_STRENGTH + roll_power + y_power + rl_power
			right = BASE_STRENGTH - roll_power + y_power + rr_power

			-- ! Determine directions
			MAX = 8
			set_front(clamp(0, front, MAX))
			set_rear(clamp(0, rear, MAX))

			set_right(clamp(0, right, MAX))
			set_left(clamp(0, left, MAX))
		end
	end
end

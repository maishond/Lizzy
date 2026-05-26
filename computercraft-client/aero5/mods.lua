require 'utils'
local modem = peripheral.wrap("back")
modem.open(42)
modem.open(41)

function angle_diff(current, target)
    local diff = (target - current + 180) % 360 - 180
    return diff
end

yaw_velocity_history = {}

function stabilise_at(px, py, pz)
	last_yaw_adjust = 0
	while true do
		x, y, z, pitch, yaw, roll = get_state()
		if x then
			x_diff = x - px
			y_diff = y - py
			z_diff = z - pz

			destination_angle = math.deg(math.atan2(z_diff, x_diff)) + 90
			yaw_error = angle_diff(destination_angle, yaw)

			hor_dist = math.sqrt(x_diff^2 + z_diff^2)

			dist_multiplier = clamp(0, hor_dist / 500, 1)

			print('Yaw_err:      ', math.floor(yaw_error))
			print('Navigating to:', px, pz)
			print('Current X/Z:  ', math.floor(x), math.floor(z))
			print('Dist_mult:    ', dist_multiplier)
			print('Distance:     ', hor_dist)
			

			POWER_OFF = 15
			
			if hor_dist > 5 and dist_multiplier > 0.2 then
				
				l = 15
				r = 15
				f = 0

				table.insert(yaw_velocity_history, 1, last_yaw - yaw)
				yaw_velocity_history[10] = nil

				yaw_avg = 0
				for i=1,#yaw_velocity_history do
					yaw_avg = yaw_avg + yaw_velocity_history[i]
				end
				yaw_avg = yaw_avg / #yaw_velocity_history
				-- yaw_velocity = yaw_avg
				yaw_velocity = last_yaw - yaw

				last_yaw = yaw

				-- ! Lol
				local output = 0.3 * yaw_error - 2 * yaw_velocity
				
				power_level = clamp(1, math.abs(yaw_error) / 3, 2)
				BASE_POWER = 7

				if output > 1 then
					r = BASE_POWER + power_level
					l = BASE_POWER
				elseif output < -1 then
					r = BASE_POWER
					l = BASE_POWER + power_level
				else
					l = BASE_POWER
					r = BASE_POWER
				end

				-- ! Write output
				redstone.setAnalogOutput('right', clamp(0, r * dist_multiplier, 15))
				redstone.setAnalogOutput('left', clamp(0, l * dist_multiplier, 15))
				redstone.setAnalogOutput('front', clamp(0, f * dist_multiplier, 15))
			else
				-- Disable big props
				redstone.setAnalogOutput('left', 15)
				redstone.setAnalogOutput('right', 15)
				redstone.setAnalogOutput('front', 0)

				-- Switch to small props!
				-- Once those exist, lol
			end
			print('----')
		end
	end
end

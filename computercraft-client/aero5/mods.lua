require 'utils'
local modem = peripheral.wrap("back")
modem.open(42)
modem.open(41)

function angle_diff(current, target)
    local diff = (target - current + 180) % 360 - 180
    return diff
end
l = 0
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

			dist_multiplier = clamp(0, hor_dist / 200, 1)
			power_level = clamp(0, (math.abs(yaw_error ^ 3) / 5), 3) * dist_multiplier

			print('Yaw_err:      ', math.floor(yaw_error))
			print('Navigating to:', px, pz)
			print('Current X/Z:  ', math.floor(x), math.floor(z))
			print('Pow yaw:      ', math.floor(power_level))
			print('Dist_mult:    ', dist_multiplier)
			print('Distance:     ', hor_dist)
			print('----')

			POWER_OFF = 15
			
			if hor_dist > 5 then
				redstone.setAnalogOutput('front', 0)
				l = 0
				r = 0
				f = 0
				if hor_dist < 68 then
					l = 15
					r = 15
				elseif yaw_error > 5 then
					-- Turn right
					r = power_level
					
					-- sleep(0.05)
					-- redstone.setAnalogOutput('right', 0)
					-- sleep(0.3)
					last_yaw_adjust = os.time('local')
				elseif yaw_error < -5 then
					-- Turn left
					l = power_level
					-- sleep(0.05)
					-- redstone.setAnalogOutput('left', 0)
					-- sleep(0.3)
					last_yaw_adjust = os.time('local')
				else
					local now = os.time('local')
					local seconds_since_last_yaw_adjust = (60 * (now - last_yaw_adjust)) * 60 -- to seconds

					if seconds_since_last_yaw_adjust > 2 or true then
						local speed = clamp(0, 14 * dist_multiplier, 14)
						-- ! Go forward
						-- redstone.setAnalogOutput('left', 0)
						-- redstone.setAnalogOutput('right', 0)
						f = speed
					end
				end
				redstone.setAnalogOutput('right', r)
				redstone.setAnalogOutput('left', l)
				redstone.setAnalogOutput('front', f)
			else
				redstone.setAnalogOutput('left', 15)
				redstone.setAnalogOutput('right', 15)
				redstone.setAnalogOutput('front', 0)
			end
		end
	end
end

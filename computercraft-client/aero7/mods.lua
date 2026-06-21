require 'utils'
local modem = peripheral.wrap("back")
modem.open(42)
modem.open(41)

function angle_diff(current, target)
    local diff = (target - current + 180) % 360 - 180
    return diff
end

yaw_velocity_history = {}
stable_ticks = 0
last_yaw = 0

leftprop = peripheral.wrap("right")
rightprop = peripheral.wrap("left") -- Trust!
MAX_SPEED = 200

function take_off() 
	print('Taking off')
	for i=1,4 do
		print('Set power to', 10+i)
		redstone.setAnalogOutput('front', 10+i)
		sleep(7)
	end
	while true do
		x, y, z = get_state()
		if y and y > 290 then
			print('Y >= 290 passed! Time to let it stabilise for a bit')
			sleep(15)
			break
		end
	end
	print('Take-off complete!')
end

function stabilise_at(px, pz)
	last_yaw_adjust = 0
	while true do
		x, y, z, pitch, yaw, roll = get_state()
		if x then
			x_diff = x - px
			z_diff = z - pz

			destination_angle = math.deg(math.atan2(z_diff, x_diff)) + 90
			yaw_error = angle_diff(destination_angle, yaw)

			hor_dist = math.sqrt(x_diff^2 + z_diff^2)

			max_distance_before_slowing = 800
			distance_clamped = clamp(0, hor_dist, max_distance_before_slowing) / max_distance_before_slowing
			-- dist_multiplier_v = 1 - (1 - distance_clamped) * (1 - distance_clamped)
			dist_multiplier_v = 1 - ((1 - distance_clamped) ^ 1.5)
			dist_multiplier = clamp(0, dist_multiplier_v, 1)

			print('Yaw_err:      ', math.floor(yaw_error + 0.5))

			-- ! Since the airship can go forward and backward (being symmetrical in that aspect), adjust the yaw and desired prop direction
			do_ccw = false
			if math.abs(yaw_error) > 90 then
				do_ccw = true
				yaw_error = 180 - yaw_error % 360
				while yaw < 0 do
					yaw = yaw + 360
				end
				yaw = -yaw
			end

			print('Yaw corr:     ', math.floor(yaw_error + 0.5))
			print('Navigating to:', px, pz)
			print('Current X/Z:  ', math.floor(x), math.floor(z))
			print('Dist_mult:    ', dist_multiplier)
			print('Distance:     ', hor_dist)
			
			

			-- ! Calculate turning power with distance to goal in mind
			BASE_POWER = 226
			MAX_SPEED_ADJUST = 30

			local l = BASE_POWER
			local r = BASE_POWER

			-- ?
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

			rotate_in_place = math.abs(yaw_error) > 30 or (math.abs(yaw_error) >= 1 and hor_dist < 40)
			print('Rotate CoM:   ', rotate_in_place)
			apply_dist_mult = true
			if rotate_in_place then
				-- ! Rotate in place
				s = clamp(0, math.abs((yaw_error / 2) ^ 2), 20)
				-- print(s)
				if yaw_error < 0 then s = -s end
				l = s
				r = -s
				apply_dist_mult = false
			else
				-- ! Move forward with 
				local output = 0.3 * yaw_error - 1 * yaw_velocity
				power_level = clamp(1, math.abs(yaw_error) / 2, MAX_SPEED_ADJUST)

				if output > 1 then
					l = BASE_POWER + power_level
					r = BASE_POWER - power_level
				elseif output < -1 then
					l = BASE_POWER - power_level
					r = BASE_POWER + power_level
				else
					l = BASE_POWER
					r = BASE_POWER
				end
				-- ?
			end
				
			print('L/R power:    ', math.floor(l), math.floor(r))
			print('CCW:          ', do_ccw)

			-- ! Set power
			print('----')
			if apply_dist_mult == false then dist_multiplier = 1 end
			if do_ccw then
				leftprop.setTargetSpeed(-r * dist_multiplier)
				rightprop.setTargetSpeed(-l * dist_multiplier)
			else
				leftprop.setTargetSpeed(r * dist_multiplier)
				rightprop.setTargetSpeed(l * dist_multiplier)
			end

			-- ! Set height
			-- 4 is a nice hover highish-up, 15 is max
			hover_power = 4
			max_power = 15
			height_power = clamp(hover_power, hover_power + ((hor_dist / 400) * (max_power - hover_power)), 15)
			-- print(height_power, 'h')
			redstone.setAnalogOutput('top', height_power)

		end
	end
end

function land() 
	print('Landing')
	local x, y, z
	for i=1,3 do
		print('Set power to', 14-i)
		redstone.setAnalogOutput('front', 14-i)
		sleep(16)
	end
	LOW_POWER = 5
	redstone.setAnalogOutput('front', LOW_POWER)
	print('Set power to', LOW_POWER)
	print('Landed. Maybe upside down? I\'m a computer, how should I know')
end

function play_warning() 
	return nil
	-- print('playing warning')
	-- local speaker = peripheral.find("speaker")
	-- local dfpwm = require("cc.audio.dfpwm")

	-- for i=1,5 do
	-- 	local decoder = dfpwm.make_decoder()
	-- 	for chunk in io.lines("landing.dfpwm", 16 * 1024) do
	-- 		local buffer = decoder(chunk)
	
	-- 		while not speaker.playAudio(buffer, 2000) do
	-- 			os.pullEvent("speaker_audio_empty")
	-- 		end
	-- 	end
	-- end
end
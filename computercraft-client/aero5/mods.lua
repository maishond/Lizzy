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


function take_off() 
	redstone.setAnalogOutput('left', 15)
	redstone.setAnalogOutput('right', 15)
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

			print(last_yaw)
			dist_multiplier = clamp(0, hor_dist / 500, 1)

			print('Yaw_err:      ', math.floor(yaw_error))
			print('Navigating to:', px, pz)
			print('Current X/Z:  ', math.floor(x), math.floor(z))
			print('Dist_mult:    ', dist_multiplier)
			print('Distance:     ', hor_dist)
			
			POWER_OFF = 15
			
			if hor_dist > 200 then
				
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
				
				power_level = clamp(1, math.abs(yaw_error) / 3, 1)
				BASE_POWER = 8

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
			else
				-- Disable big props
				redstone.setAnalogOutput('left', 15)
				redstone.setAnalogOutput('right', 15)
			end

			if hor_dist > 4 then
				modem.transmit(43, 0, yaw_error)
				stable_ticks = 0
			else
				stable_ticks = stable_ticks + 1
				modem.transmit(43, 0, -400)
				print(stable_ticks)
				if stable_ticks > 40 then
					-- Reached the destination. Yippeee!
					return
				end
			end

			print('----')
		end
	end
end

function land() 
	print('Landing')
	local x, y, z
	for i=1,3 do
		print('Set power to', 14-i)
		redstone.setAnalogOutput('front', 14-i)
		sleep(9)
	end
	LOW_POWER = 9
	redstone.setAnalogOutput('front', LOW_POWER)
	print('Set power to', LOW_POWER)
	print('Landed. Maybe upside down? I\'m a computer, how should I know')
end

function play_warning() 
	print('playing warning')
	local speaker = peripheral.find("speaker")
	local dfpwm = require("cc.audio.dfpwm")

	for i=1,5 do
		local decoder = dfpwm.make_decoder()
		for chunk in io.lines("landing.dfpwm", 16 * 1024) do
			local buffer = decoder(chunk)
	
			while not speaker.playAudio(buffer, 2000) do
				os.pullEvent("speaker_audio_empty")
			end
		end
	end
end
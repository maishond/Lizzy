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
	print('take_off')
end

motors = {
	N_MOTOR = 'front',
	E_MOTOR = 'right',
	S_MOTOR = 'top',
	W_MOTOR = 'left',
}
function set_power(name, power)
	redstone.setAnalogOutput(motors[name], 15 - power)
end

function stabilise_at(px, pz)
	print('stabilise_at')
	while true do
		x, y, z, pitch, yaw, roll = get_state()
		if x then

			-- x_diff = x - px
			-- z_diff = z - pz

			-- dist_from_target = math.sqrt(math.abs(x_diff) ^ 2 + math.abs(z_diff) ^ 2)
			-- target_angle = math.deg(math.atan2(x_diff, z_diff))

			-- adjusted_angle = (yaw - target_angle) % 360

			local dx = px - x
			local dz = pz - z
			local yaw_r = math.rad(yaw - 180)

			local bearing = math.atan2(dx, dz)      -- radians, 0 = north
			local heading_error = bearing - yaw_r

			local dist = math.sqrt(dx^2 + dz^2)

			local max_tilt = 20.0      -- degrees
			local k = 0.1              -- tune this

			local tilt = math.min(max_tilt, k * clamp(0, dist / 40, 400))

			local eps = 1e-9
			local desired_pitch = math.cos(heading_error) * tilt
			local desired_roll  = math.sin(heading_error) * tilt

			local HOVER_Y = 200
			if math.abs(HOVER_Y - y) > 10 then
				print('Not at HOVER_Y')
				desired_pitch = 0
				desired_roll = 0
			end

			roll_error = roll - desired_roll
			pitch_error = pitch - desired_pitch

			-- print(pitch_error)

			-- N = neg pitch
			-- S = pos pitch

			-- E = neg roll
			-- W = pos roll
			
			local BASE_POWER = 11
			n = BASE_POWER
			e = BASE_POWER
			s = BASE_POWER
			w = BASE_POWER

			pitch_adjustment = clamp(0, math.abs(pitch_error) / 2, 1)
			roll_adjustment  = clamp(0, math.abs(roll_error ) / 2, 1)

			if desired_pitch > pitch then
				n = n + pitch_adjustment
				s = s - pitch_adjustment
			else 
				n = n - pitch_adjustment
				s = s + pitch_adjustment
			end

			if desired_roll > roll then
				e = e + roll_adjustment
				w = w - roll_adjustment
			else 
				e = e - roll_adjustment
				w = w + roll_adjustment
			end


			set_power('N_MOTOR', n)
			set_power('E_MOTOR', e)
			set_power('S_MOTOR', s)
			set_power('W_MOTOR', w)

			print('Desired pitch:', desired_pitch)
			print('Pitch:        ', pitch)
			print('Desired roll: ', desired_roll)
			print('Roll:         ', roll)
			print('---')

			-- N is 0   deg
			-- E is 90  deg
			-- S is 180 deg
			-- W is 270 deg

			-- print(x, y, z)
			-- print(pitch, yaw, roll)
		end
	end
end

function land() 
	print('Land')
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
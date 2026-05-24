local modem = peripheral.wrap("front")

-- =========================================================
-- MOTOR LAYOUT
--
--        FRONT
--
--    m1         m2
--
--
--    m3         m4
--
--        BACK
--
-- Left side  = m1,m3
-- Right side = m2,m4
--
-- Positive pitch correction:
--   increase rear thrust
--   decrease front thrust
--
-- Positive roll correction:
--   increase left thrust
--   decrease right thrust
-- =========================================================

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

local function clamp(v, mn, mx)
    if v < mn then return mn end
    if v > mx then return mx end
    return v
end

-- =========================================================
-- TUNING
-- =========================================================

local BASE = 7

local KP_PITCH = 0.3
local KP_ROLL = 0.3

function stabilise(pitch_deg, roll_deg, yaw_deg, x, y, z) 
	local DESIRED_PITCH = 0
	local DESIRED_ROLL = 0

	-- =====================================================
	-- PID (P ONLY CURRENTLY)
	-- =====================================================
	
	local pitch_error = pitch_deg - DESIRED_PITCH
	local pitch_correction = pitch_error * KP_PITCH
	local roll_error = roll_deg - DESIRED_ROLL
	local roll_correction  = roll_error  * KP_ROLL
	
	-- =====================================================
	-- MOTOR MIXING
	-- =====================================================
		
	local m1 = BASE
	local m2 = BASE
	local m3 = BASE
	local m4 = BASE

	-- =====================================================
	-- PITCH
	--
	-- Increase rear thrust
	-- Decrease front thrust
	-- =====================================================

	m1 = m1 - pitch_correction
	m2 = m2 - pitch_correction

	m3 = m3 + pitch_correction
	m4 = m4 + pitch_correction

	-- =====================================================
	-- ROLL
	--
	-- Increase left thrust
	-- Decrease right thrust
	-- =====================================================

	-- Roll correction

	m1 = m1 - roll_correction
	m3 = m3 - roll_correction

	m2 = m2 + roll_correction
	m4 = m4 + roll_correction

	-- =====================================================
	-- CLAMP
	-- =====================================================

	m1 = clamp(m1, 0, 15)
	m2 = clamp(m2, 0, 15)
	m3 = clamp(m3, 0, 15)
	m4 = clamp(m4, 0, 15)

	-- =====================================================
	-- OUTPUT
	-- =====================================================

	set_eng1(m1)
	set_eng2(m2)
	set_eng3(m3)
	set_eng4(m4)


	print(
		string.format(
			"Pitch: %.2f  Roll: %.2f",
			pitch_deg,
			roll_deg
		)
	)

	print(
		string.format(
			"M1 %.2f | M2 %.2f | M3 %.2f | M4 %.2f",
			m1, m2, m3, m4
		)
	)

end

local fly_state = {
	stage = 1,
	target_x = nil,
	target_y = nil,
	target_z = nil,
	yaw_stable_ticks = 0
}

local function norm_deg(a)
	a = a % 360
	if a < 0 then a = a + 360 end
	return a
end

local function angle_diff(target, current)
	local diff = norm_deg(target) - norm_deg(current)
	if diff > 180 then diff = diff - 360 end
	if diff < -180 then diff = diff + 360 end
	return diff
end

function fly_to(target_x, target_y, target_z, pitch_deg, roll_deg, yaw_deg, x, y, z)
	local ALTITUDE_TOLERANCE = 1
	local YAW_TOLERANCE = 5
	local ARRIVAL_DISTANCE = 2

	local ALTITUDE_GAIN = 0.30
	local YAW_GAIN = 0.01
	local FORWARD_GAIN = 0.10

	local MAX_YAW_CORRECTION = 0.6
	local MAX_PITCH_TARGET = 8

	if fly_state.target_x ~= target_x
		or fly_state.target_y ~= target_y
		or fly_state.target_z ~= target_z then
		fly_state.stage = 1
		fly_state.target_x = target_x
		fly_state.target_y = target_y
		fly_state.target_z = target_z
		fly_state.yaw_stable_ticks = 0
	end

	local dx = target_x - x
	local dy = target_y - y
	local dz = target_z - z

	local horizontal_distance = math.sqrt(dx * dx + dz * dz)

	-- Your yaw is FRONT -> BACK, so forward heading is +180
	local current_heading = norm_deg(yaw_deg + 180)
	local target_heading = norm_deg(math.atan2(dz, dx) * 180 / math.pi)
	print(target_heading, current_heading)
	local yaw_error = angle_diff(target_heading, current_heading)

	local desired_pitch = 0
	local desired_roll = 0
	local thrust_adjust = 0
	local yaw_correction = 0

	if fly_state.stage == 1 then
		thrust_adjust = clamp(dy * ALTITUDE_GAIN, -4, 4)

		-- Hold all attitude corrections off during climb
		desired_pitch = pitch_deg
		desired_roll  = roll_deg
		yaw_correction = 0

		if math.abs(dy) <= ALTITUDE_TOLERANCE then
			fly_state.stage = 2
			fly_state.yaw_stable_ticks = 0
		end

	elseif fly_state.stage == 2 then
		thrust_adjust = clamp(dy * ALTITUDE_GAIN, -4, 4)

		if math.abs(yaw_error) > YAW_TOLERANCE then
			fly_state.yaw_stable_ticks = 0
			yaw_correction = clamp(yaw_error * YAW_GAIN, -MAX_YAW_CORRECTION, MAX_YAW_CORRECTION)
		else
			fly_state.yaw_stable_ticks = fly_state.yaw_stable_ticks + 1
			yaw_correction = 0
		end

		if fly_state.yaw_stable_ticks >= 8 then
			fly_state.stage = 3
		end

	elseif fly_state.stage == 3 then
		thrust_adjust = clamp(dy * ALTITUDE_GAIN, -4, 4)

		if math.abs(yaw_error) > YAW_TOLERANCE then
			fly_state.stage = 2
			fly_state.yaw_stable_ticks = 0
		end

		desired_pitch = clamp(-horizontal_distance * FORWARD_GAIN, -MAX_PITCH_TARGET, 0)

		if horizontal_distance <= ARRIVAL_DISTANCE and math.abs(dy) <= ALTITUDE_TOLERANCE then
			fly_state.stage = 4
		end

	else
		thrust_adjust = clamp(dy * ALTITUDE_GAIN, -4, 4)
	end

	local pitch_error = pitch_deg - desired_pitch
	local roll_error = roll_deg - desired_roll

	local pitch_correction = pitch_error * KP_PITCH
	local roll_correction = roll_error * KP_ROLL

	local m1 = BASE + thrust_adjust
	local m2 = BASE + thrust_adjust
	local m3 = BASE + thrust_adjust
	local m4 = BASE + thrust_adjust

	m1 = m1 - pitch_correction
	m2 = m2 - pitch_correction
	m3 = m3 + pitch_correction
	m4 = m4 + pitch_correction

	m1 = m1 - roll_correction
	m3 = m3 - roll_correction
	m2 = m2 + roll_correction
	m4 = m4 + roll_correction

	-- yaw only during stage 2
	m1 = m1 + yaw_correction
	m4 = m4 + yaw_correction
	m2 = m2 - yaw_correction
	m3 = m3 - yaw_correction

	m1 = clamp(m1, 0, 15)
	m2 = clamp(m2, 0, 15)
	m3 = clamp(m3, 0, 15)
	m4 = clamp(m4, 0, 15)

	set_eng1(m1)
	set_eng2(m2)
	set_eng3(m3)
	set_eng4(m4)

	print(string.format("Stage %d | Alt %.2f | Yaw %.2f | Dist %.2f", fly_state.stage, dy, yaw_error, horizontal_distance))
end
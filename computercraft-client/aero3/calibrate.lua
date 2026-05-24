-- =========================================================
-- STABLE HOP TRIM CALIBRATOR (INVERTED THRUST SAFE)
-- =========================================================

local modem = peripheral.wrap("front")

modem.open(42)
modem.open(41)

-- =========================================================
-- MOTOR OUTPUT
-- =========================================================

local function set_eng1(v) modem.transmit(43, 0, v) end
local function set_eng2(v) modem.transmit(44, 0, v) end
local function set_eng3(v) modem.transmit(45, 0, v) end
local function set_eng4(v) modem.transmit(46, 0, v) end

local function clamp(v, mn, mx)
	if v < mn then return mn end
	if v > mx then return mx end
	return v
end

local function split(str)
	local t = {}
	for v in string.gmatch(str, "([^ ]+)") do
		t[#t+1] = v
	end
	return t
end

-- =========================================================
-- TRIMS
-- =========================================================

local trim1, trim2, trim3, trim4 = 0, 0, 0, 0

-- invert-safe correction sign (IMPORTANT)
local PITCH_SIGN = 1
local ROLL_SIGN  = 1

-- learning rate (VERY slow on purpose)
local RATE = 0.015

-- =========================================================
-- MOTOR APPLY
-- =========================================================

local BASE = 7.5

local function apply()
	local m1 = clamp(BASE + trim1, 0, 15)
	local m2 = clamp(BASE + trim2, 0, 15)
	local m3 = clamp(BASE + trim3, 0, 15)
	local m4 = clamp(BASE + trim4, 0, 15)

	set_eng1(m1)
	set_eng2(m2)
	set_eng3(m3)
	set_eng4(m4)
end

-- =========================================================
-- READ SENSOR
-- =========================================================

local function read()
	local e,s,c,r,msg,d

	repeat
		e,s,c,r,msg,d = os.pullEvent("modem_message")
	until c == 42
	local p2 = split(msg)

	repeat
		e,s,c,r,msg,d = os.pullEvent("modem_message")
	until c == 41
	local p3 = split(msg)

	local x,y,z = gps.locate(0.1)
	print(x, p2[1])
	if not x or not p2[1] then return nil end
	if tonumber(p2[1]) == nil then return nil end

	-- =========================
	-- PITCH
	-- =========================

	local dx = tonumber(p2[1]) - x
	local dy = tonumber(p2[2]) - y
	local dz = tonumber(p2[3]) - z

	local horiz = math.sqrt(dx*dx + dz*dz)
	local pitch = math.atan2(dy, horiz) * 180 / math.pi

	-- =========================
	-- ROLL
	-- =========================
	if tonumber(p3[1]) == nil then return nil end
	local rx = tonumber(p3[1]) - tonumber(p2[1])
	local ry = tonumber(p3[2]) - tonumber(p2[2])
	local rz = tonumber(p3[3]) - tonumber(p2[3])

	local rhor = math.sqrt(rx*rx + rz*rz)
	local roll = math.atan2(ry, rhor) * 180 / math.pi

	return pitch, roll
end

-- =========================================================
-- HOP CYCLE
-- =========================================================

local function takeoff()
	print("Take off")
	set_eng1(BASE - 1.5)
	set_eng2(BASE - 1.5)
	set_eng3(BASE - 1.5)
	set_eng4(BASE - 1.5)
	sleep(5)
end

local function land()
	print('Land')
	for i = 1, 25 do
		set_eng1(15)
		set_eng2(15)
		set_eng3(15)
		set_eng4(15)
		sleep(0.2)
	end
end

-- wait for physics to settle
local function settle()
	local last_y
	local stable = 0

	while stable < 15 do
		local _, y = gps.locate(0.1)

		if y and last_y then
			if math.abs(y - last_y) < 0.05 then
				stable = stable + 1
			else
				stable = 0
			end
		end

		last_y = y
		sleep(0.1)
	end
end

-- =========================================================
-- MAIN LOOP
-- =========================================================

while true do

	print("Starting calibration hop...")

	takeoff()

	local pitch_sum = 0
	local roll_sum = 0
	local n = 0

	for i = 1, 40 do
		local pitch, roll = read()
		if pitch and roll then
			pitch_sum = pitch_sum + pitch
			roll_sum = roll_sum + roll
			n = n + 1
		end
		apply()
		sleep(0.1)
	end

	land()
	settle()

	if n > 0 then
		local avg_pitch = pitch_sum / n
		local avg_roll  = roll_sum / n

		-- =================================================
		-- INVERTED THRUST CORRECTION
		-- =================================================

		-- Pitch fix
		trim1 = trim1 - PITCH_SIGN * avg_pitch * RATE
		trim2 = trim2 - PITCH_SIGN * avg_pitch * RATE
		trim3 = trim3 + PITCH_SIGN * avg_pitch * RATE
		trim4 = trim4 + PITCH_SIGN * avg_pitch * RATE

		-- Roll fix
		trim1 = trim1 - ROLL_SIGN * avg_roll * RATE
		trim3 = trim3 - ROLL_SIGN * avg_roll * RATE
		trim2 = trim2 + ROLL_SIGN * avg_roll * RATE
		trim4 = trim4 + ROLL_SIGN * avg_roll * RATE

		-- clamp trims
		trim1 = clamp(trim1, -2, 2)
		trim2 = clamp(trim2, -2, 2)
		trim3 = clamp(trim3, -2, 2)
		trim4 = clamp(trim4, -2, 2)

		print("---- RESULT ----")
		print(string.format("Pitch bias: %.3f", avg_pitch))
		print(string.format("Roll  bias: %.3f", avg_roll))
		print("Trims updated:")
		print(trim1, trim2, trim3, trim4)
	end

	sleep(2)
end
require 'utils'
-- Write startup override
local file = fs.open("startup-override.lua", "w")
file.write("require('update')\nrequire('monitor')")
file.close()

-- Peripheral setup
local modem = peripheral.wrap("bottom")
modem.open(43)
modem.open(44)
modem.open(45)
modem.open(46)

-- Find first monitor on the modem network
local monitorName = nil

for _, name in ipairs(peripheral.getNames()) do
	if peripheral.getType(name) == "monitor" then
		monitorName = name
		break
	end
end

if not monitorName then
	error("No monitor found")
end

local mon = peripheral.wrap(monitorName)

mon.setBackgroundColor(colors.black)
mon.clear()

local w, h = mon.getSize()

-- Engine power cache
local enginePower = {
	fl = 0,
	fr = 0,
	rr = 0,
	rl = 0
}

local function drawBar(x, y, width, height, value)
	value = math.max(0, math.min(15, value))

	local filled = math.floor((value / 15) * height)

	-- Clear area
	mon.setBackgroundColor(colors.gray)

	for iy = 0, height - 1 do
		for ix = 0, width - 1 do
			mon.setCursorPos(x + ix, y + iy)
			mon.write(" ")
		end
	end

	-- Draw green fill from bottom upward
	mon.setBackgroundColor(colors.green)

	for iy = 0, filled - 1 do
		for ix = 0, width - 1 do
			mon.setCursorPos(x + ix, y + height - 1 - iy)
			mon.write(" ")
		end
	end
end

local function redraw()
	local barW = 3
	local barH = math.floor(h / 2)
	print('yo')
	-- Top-left (front-left)
	drawBar(
		1,
		1,
		barW,
		barH,
		enginePower.fl
	)

	-- Top-right (front-right)
	drawBar(
		w - barW + 1,
		1,
		barW,
		barH,
		enginePower.fr
	)

	-- Bottom-right (rear-right)
	drawBar(
		w - barW + 1,
		h - barH + 1,
		barW,
		barH,
		enginePower.rr
	)

	-- Bottom-left (rear-left)
	drawBar(
		1,
		h - barH + 1,
		barW,
		barH,
		enginePower.rl
	)
end

-- Listen for modem updates
while true do
	print(1)
	local _, _, channel, _, message = os.pullEvent("modem_message")
	message = split(message, ' ')[1]
	print(message)

	-- Incoming values are inverted:
	-- transmitted = 15 - enginePower
	
	if channel == 43 then
		local power = 15 - tonumber(message)
		enginePower.fl = power
	elseif channel == 44 then
		local power = 15 - tonumber(message)
		enginePower.fr = power
	elseif channel == 45 then
		local power = 15 - tonumber(message)
		enginePower.rr = power
	elseif channel == 46 then
		local power = 15 - tonumber(message)
		enginePower.rl = power
	end

	redraw()
end
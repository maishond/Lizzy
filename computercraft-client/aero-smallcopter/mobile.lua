local up = 0
local held = {}

local modem = peripheral.find('modem')

modem.open(4810)
modem.open(4811)

local function update() 
    local left = 0
    local right = 0
    term.clear()
    term.setCursorPos(1, 1)

    t = os.time()
    print(t)


    local step = 80
    if held[65] then
        -- A
        left = left - 10
        right = right + 10 
    end
    if held[68] then
        -- D
        right = right - 10
        left = left + 10
    end

    if held[87] or held[83] then
        -- W and S
        left = left + step
        right = right + step
    end
    
    if held[83] then
        -- S
        left = -left
        right = -right
    end

    print('UP:    ' .. up)
    print('LEFT:  ' .. left)
    print('RIGHT: ' .. right)

    modem.transmit(4810, 4811, {up = up, left = left, right = right,time=t})
end

local function keypress()
  while true do
    local e, k = os.pullEvent("key")
    held[k] = true
    print(k)
    if k == 340 then 
    -- Shift
      up = up + 15
    elseif k == 341 then
    -- Control
      up = up - 15
    end
    update()
  end
end

local function keypressup()
  while true do
    local e, k = os.pullEvent("key_up")
    held[k] = nil
    update()
  end
end

local function updateLoop()
  while true do
    sleep(0.02)
    update()
  end
end

parallel.waitForAny(keypress, keypressup, updateLoop)
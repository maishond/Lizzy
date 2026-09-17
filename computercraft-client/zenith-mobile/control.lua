local held = {}

local modem = peripheral.find('modem')

modem.open(3810)
modem.open(3811)

local function update() 
    local up = 0
    local left = 0
    local right = 0
    term.clear()
    term.setCursorPos(1, 1)

    t = os.time()
    print(t)

    local step = 80
    local rotationstep = 20
    if held[65] then
        -- A
        left = left - rotationstep
        right = right + rotationstep 
    end
    if held[68] then
        -- D
        right = right - rotationstep
        left = left + rotationstep
    end

    if held[87]  then
        -- W
        left = left + step
        right = right + step
    end
    
    if held[83] then
        print('S')
        -- S
        left = left - step
        right = right - step
    end

    if held[340] then 
    -- Shift
      up = up + 15
    elseif held[341] then
    -- Control
      up = up - 15
    end

    print('UP:    ' .. up)
    print('LEFT:  ' .. left)
    print('RIGHT: ' .. right)

    modem.transmit(1338, 3811, {command = 'control', up = up, left = left, right = right,time=t})
end

local function keypress()
  while true do
    local e, k = os.pullEvent("key")
    held[k] = true
    print(k)
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
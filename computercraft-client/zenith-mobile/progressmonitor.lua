local modem = peripheral.find('modem')

modem.open(1337) -- Zenith Master PC telemetry

os.setComputerLabel('Progress monitor')

local monitor = peripheral.wrap('back')

print('Yippee mobile')

local function split(str, delimiter)
    local returnTable = {}
    for k, v in string.gmatch(str, "([^" .. delimiter .. "]+)") 
    do
        returnTable[#returnTable+1] = k
    end
    return returnTable
end

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

while true do
    local progress = 0
    local started = ''
    local target = ''

    -- Await message
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent('modem_message')
    until channel == 1337

    for i, line in pairs(split(message, '\n')) do
        local value = split(line, ':')
        local key = value[1]
        local value = value[2]
   
        if key == 'Started' then
            -- started = string.gsub(value, "%s+", "")
            started = trim(value)
        end

        if key == 'Args' then
            target = trim(value)
        end

        if key == 'Progress' then
            print(string.gsub(value, '%%', ''))
            progress = string.gsub(value, '%%', '')
            progress = trim(progress)
            progress = tonumber(progress) / 100
        end

        local monitor_width, monitor_height = monitor.getSize()
        monitor.clear()

        if #started > 0 then
            -- Top line
            local right_side_string = 'Started ' .. started
            local left_side_string = 'Target: ' .. target
            local top_string = left_side_string .. string.rep(' ', monitor_width - #left_side_string - #right_side_string) .. right_side_string

            monitor.setCursorPos(1, 1) 
            monitor.write(top_string)

            -- Progress bar
            local progress_string_length = 7
            local progress_string = math.floor(progress * 100 + 0.5) .. '%'
            progress_string = string.rep(' ', progress_string_length - #progress_string - 1) .. progress_string .. '  '
            monitor.setCursorPos(1, 3)
            monitor.write(progress_string)
            
            local bar_length = monitor_width - #progress_string - 2
            local green_length = math.floor(progress * bar_length)
            local gray_length = bar_length - green_length
            monitor.setBackgroundColor(colours.green)
            monitor.write(string.rep(' ', green_length))
            monitor.setBackgroundColor(colours.grey)
            monitor.write(string.rep(' ', gray_length))
            

            print(progress)
            monitor.setBackgroundColor(colours.black)
        end
    end
end
-- Import utils
os.loadAPI('json.lua')
require('utils')

-- File for access points
local file = fs.open('startup.lua', 'w')
file.write('shell.run("update") shell.run("mobile")')
file.close()

local storageSystemId = getStorageSystemId()
local apiBaseUrl = 'https://' .. getHostName()

-- Mobile app logic
local itemSelected = 1
local apSelected = 1
local searchQuery = ''
local dropCount = '';

-- ! Fetch system
local response
local systemRes

local items = {}
local aps = {}
local itemToDrop = ''
function fetchData()
    response = http.get(apiBaseUrl .. '/system/' .. storageSystemId)
    systemRes = json.decode(response.readAll())

    items = {}
    aps = {}

    -- Create items and aps
    for itemName, count in pairs(systemRes.items) do
        items[#items + 1] = {itemName, count}
    end
    for i, data in pairs(systemRes.accessPoints) do
        aps[i] = data
        local apX = data.position.x or 0
        local apY = data.position.y or 0
        local apZ = data.position.z or 0
        local x, y, z = gps.locate() or 0, 0, 0
        local distance = math.sqrt(math.abs(apX - x) ^ 2 + math.abs(apY - y) ^ 2 + math.abs(apZ - z) ^ 2)
        aps[i].distance = distance
    end

    -- Sort items by count
    table.sort(items, function(a, b)
        return a[2] > b[2]
    end)
    table.sort(aps, function(a, b)
        local aStatus = a.online
        local bStatus = b.online
        return (aStatus and 1 or 0) > (bStatus and 1 or 0)
    end)

    -- Sort APs by distance
    table.sort(aps, function(a, b)
        return a.distance < b.distance
    end)
end
fetchData()

function getFilteredItems()
    local filteredItems = {}
    for _, item in ipairs(items) do
        if string.find(toItemName(item[1]), toItemName(searchQuery)) then
            filteredItems[#filteredItems + 1] = item
        end
    end
    return filteredItems
end

function drawHeader()
    local w, h = term.getSize()

    -- Draw header
    term.setCursorPos(1, 1)
    term.clearLine()
    for x = 1, w do
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.white)
        term.write('-')
    end

    -- Write systemRes.name in middle of screen
    term.setCursorPos((w + 2) / 2 - #systemRes.name / 2, 1)
    term.setTextColor(colors.black)
    term.write(systemRes.name)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

term.clear()

function searchBox(value, centered)
    local w, h = term.getSize()
    local searchBoxY = 4
    for x = 2, w - 1 do
        term.setCursorPos(x, searchBoxY)
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.gray)
        term.write('-')
    end
    term.setTextColor(colors.white)
    term.setCursorPos(centered and ((w + 2) / 2) - (#value / 2) or 2, searchBoxY)
    term.write(value)
end

function draw()
    local w, h = term.getSize()

    term.setCursorPos(1, 1)

    drawHeader()

    local items = getFilteredItems()

    -- Draw search box
    searchBox(searchQuery)

    -- Reset colors
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    -- Draw items
    local itemBoxY = 7;
    local itemBoxSize = h - (itemBoxY - 1)
    local shouldStarScrolling = math.floor(itemBoxSize / 2)
    for y = itemBoxY, h do
        local line = y - (itemBoxY - 1);

        -- Item index should start at line, but should not start moving up until line is greater than shouldStartScrolling
        local offset = 0
        if itemSelected > shouldStarScrolling then
            offset = itemSelected - shouldStarScrolling
        end
        local itemIndex = line + offset

        -- Reset colors
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.setCursorPos(1, y)
        term.clearLine()

        local item = items[itemIndex]
        if item then
            if item[1] == items[itemSelected][1] then
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)

            end

            local name = toItemName(split(item[1], ':')[2])
            -- First letter of name to uppercase
            name = name:gsub("^%l", string.upper)

            local count = 'x ' .. item[2]
            term.write(name .. string.rep(' ', w - #name - #count) .. count)
        end

    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    -- Listen for events
    local event, key = os.pullEvent("key")

    if key == keys.up and itemSelected > 1 then
        -- Move selectedItem up
        itemSelected = itemSelected - 1
    elseif key == keys.down and itemSelected < #items then
        -- Move selectedItem down
        itemSelected = itemSelected + 1
    elseif key == keys.enter then
        -- If enter is pressed, open item
        if items[itemSelected] == nil then
            os.reboot()
        end
        itemToDrop = items[itemSelected][1]
        term.clear()
        fetchData()
        drawSecondStep()
    elseif key == keys.backspace then
        itemSelected = 1
        searchQuery = string.sub(searchQuery, 1, #searchQuery - 1)
    elseif pcall(function()
        return string.char(key)
    end) then
        itemSelected = 1
        searchQuery = searchQuery .. string.char(key)
    end

    -- Redraw
    draw()
end

function drawSecondStep()
    local w, h = term.getSize()
    drawHeader()

    searchBox(dropCount == '' and '64' or dropCount, true)

    -- ! This is a repeat of the item list code.
    -- ! If anybody's ever bored, they are more than welcome to refactor this to be a function
    -- Draw items
    local itemBoxY = 7;
    local itemBoxSize = h - (itemBoxY - 1)
    local shouldStarScrolling = math.floor(itemBoxSize / 2)
    for y = itemBoxY, h do
        local line = y - (itemBoxY - 1);

        -- Item index should start at line, but should not start moving up until line is greater than shouldStartScrolling
        local offset = 0
        if apSelected > shouldStarScrolling then
            offset = apSelected - shouldStarScrolling
        end
        local accessPointIndex = line + offset

        -- Reset colors
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.setCursorPos(1, y)
        term.clearLine()

        local accessPoint = aps[accessPointIndex]
        if accessPoint then
            if accessPoint.id == aps[apSelected].id then
                term.setTextColor(accessPoint.online and colors.black or colors.gray)
                term.setBackgroundColor(colors.white)
            else
                term.setTextColor(accessPoint.online and colors.white or colors.gray)

            end

            local name = accessPoint.name
            -- First letter of name to uppercase
            name = name:gsub("^%l", string.upper)

            local rightSide = (accessPoint.x ~= '0' and math.floor(accessPoint.distance) .. 'm')
            if not accessPoint.online then
                rightSide = 'Offline'
            end
            term.write(name .. string.rep(' ', w - #name - #rightSide) .. rightSide)
        end

    end

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    -- Listen for events
    local event, key = os.pullEvent("key")

    if key == keys.up and apSelected > 1 then
        -- Move selectedItem up
        apSelected = apSelected - 1
    elseif key == keys.down and apSelected < #aps then
        -- Move selectedItem down
        apSelected = apSelected + 1
    elseif key == keys.enter then
        -- If enter is pressed, open item
        local realDropCount = dropCount == '' and '64' or dropCount
        print('Dropping ' .. realDropCount .. ' ' .. itemToDrop .. ' to ' .. aps[apSelected].name)

        local url =
            apiBaseUrl .. '/system/' .. storageSystemId .. '/drop-item/' .. itemToDrop .. '/' .. realDropCount .. '/' ..
                aps[apSelected].inGameId

        local res = http.get(url)
        local msg = res.readAll()
        term.clear()

        term.setCursorPos((w + 2) / 2 - #msg / 2, h / 2)
        term.write(msg)
        local escMessage = 'Press esc'
        term.setCursorPos((w + 2) / 2 - #escMessage / 2, (h / 2) + 5)
        term.write(escMessage)
        fetchData()
        os.sleep(3)

        term.clear()
        itemSelected = 1
        apSelected = 1
        dropCount = ''
        searchQuery = ''
        return
    elseif key == keys.backspace then
        apSelected = 1
        dropCount = string.sub(dropCount, 1, #dropCount - 1)
    elseif pcall(function()
        return string.char(key)
    end) then
        itemSelected = 1
        if tonumber(string.char(key)) ~= nil then
            dropCount = dropCount .. tonumber(string.char(key)) or ''
        end
    end

    drawSecondStep()
end

draw()

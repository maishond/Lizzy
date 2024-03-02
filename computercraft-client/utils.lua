function getHostName()
    print('Getting hostname from master')
    -- Request hostname through rednet
    peripheral.find("modem", rednet.open)
    local hostname = ''
    while hostname == '' do
        rednet.broadcast('hostname', 'master')
        local senderId, message, protocol = rednet.receive('hostname', 2)
        print(senderId, message, protocol, 'hostname')
        if message ~= nil and message ~= 'hostname' and message ~= 'storageSystemId' then
            hostname = message
        end
    end
    print('Got hostname')
    return hostname
end

-- Init websocket
function getBaseUrl()
    local file = fs.open('hostname.txt', 'r')
    local hostName = file.readAll()
    file.close()
    return hostName
end

local ws = assert(http.websocket("wss://" .. getBaseUrl() .. '/ws'))

function getStorageSystemId()
    local storageSystemId = 'storageSystemId.txt'
    if fs.exists(storageSystemId) then
        print('Storage system id is local')
        return fs.open(storageSystemId, 'r').readAll()
    end

    print('Getting storage system id from master')

    -- Request storage system id through rednet
    peripheral.find("modem", rednet.open)
    rednet.broadcast('storageSystemId', 'master')

    local value = ''
    while value == '' do
        local senderId, message, protocol = rednet.receive('storageSystemId', 2)

        if message ~= nil and message ~= 'hostname' and message ~= 'storageSystemId' then
            value = message
        else
            print('No storage system id received', os.time())
        end
    end

    print('Got storage system id')
    return value
end

local storageSystemId = getStorageSystemId()

-- Local network
local modem = nil
for i, peripheralName in ipairs(peripheral.getNames()) do
    if peripheral.wrap(peripheralName).getNameLocal then
        modem = peripheral.wrap(peripheralName)
    end
end
if modem then
    modem.open(1)
end
local turtleName = modem and modem.getNameLocal() or 'unknown'

peripheral.find("modem", rednet.open)

function getTurtleName()
    return turtleName
end

function getBarrels()
    local allPeripherals = getNames()
    local barrels = {}
    for i = 1, #allPeripherals do
        local peripheralName = allPeripherals[i]
        if peripheral.getType(peripheralName) == 'minecraft:barrel' then
            barrels[#barrels + 1] = peripheral.wrap(peripheralName)
            barrels[#barrels].id = peripheralName
        end
    end
    return barrels
end

function toLeft(str)
    -- Convert str to string
    str = str .. ''
    -- If str is less than 8 characters, add spaces to the end
    if #str < 8 then
        str = str .. string.rep(' ', 8 - #str)
    end
    return string.sub(str, 1, 8) .. '|'
end

-- Function to split string
function split(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table, cap)
        end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end

-- Function to remove mod name from item name and make it lowercase (and replace underscores with spaces)
function toItemName(str)
    -- Take name, split by : and get last item
    local nameSplit = split(str, ':')
    local itemName = nameSplit[#nameSplit] or str

    -- Replace underscore with space and make it lowercase
    itemName = string.gsub(itemName, '_', ' ')
    itemName = string.lower(itemName)

    -- Remove spaces from start and end
    itemName = string.gsub(itemName, '^%s*(.-)%s*$', '%1')

    return itemName
end

function getContainers()
    -- ! Find all chests, trapped chests, and barrels
    local allPeripherals = getNames()

    local containers = {}
    for i = 1, #allPeripherals do
        local peripheralName = allPeripherals[i]
        if (peripheral.getType(peripheralName) == 'minecraft:chest' or peripheral.getType(peripheralName) ==
            'minecraft:barrel' or peripheral.getType(peripheralName) == 'minecraft:trapped_chest') then
            local c = peripheral.wrap(peripheralName)

            -- Add name to c
            c.name = peripheralName
            c.id = peripheralName

            containers[#containers + 1] = c
        end
    end

    return containers
end

-- Function get ws
function getWs()
    return ws
end

-- peripheral.getNames without dupes
function getNames()
    local peripherals = peripheral.getNames()
    local accessPoints = {}
    local knownNames = {}
    for i, peripheralName in ipairs(peripherals) do
        if not knownNames[peripheralName] then
            knownNames[peripheralName] = true
            accessPoints[#accessPoints + 1] = peripheralName
        end
    end
    return accessPoints
end

-- Send websocket message (with batching to deal with max length)
function sendMessage(msg)
    local turtleName = getTurtleName()
    local lines = split(msg, '\n')
    local maxMessageLength = 131e3 -- Found this number through a manual binary search
    local batch = os.date()

    function getBaseMessage()
        local xyz = fs.exists('xyz.txt') and fs.open('xyz.txt', 'r').readAll() or '0 0 0'
        return 'IDENTIFY ' .. turtleName .. ' ' .. storageSystemId .. ' ' .. xyz .. '\nBATCH ' .. batch
    end

    local sendingMessage = getBaseMessage()

    for i = 1, #lines do
        local line = lines[i]
        if #sendingMessage + #line > maxMessageLength then
            ws.send(sendingMessage)
            sendingMessage = getBaseMessage()
        end

        sendingMessage = sendingMessage .. '\n' .. line
    end

    ws.send(sendingMessage)

    -- Write message to file
    local file = fs.open('last-message.txt', 'w')
    file.write(sendingMessage)
    file.close()

    ws.send(getBaseMessage() .. '\nEND_BATCH')
    ws.receive(5) -- Wait for batch to be acknowledged
end

require('utils')
sendMessage('STARTUP')

local containerSizeCache = {}

function getItemsAndContainersDetailed()
    local containers = getContainers()
    local newContainers = {}
    local itemCount = {}

    for i = 1, #containers do
        local container = containers[i]
        if containerSizeCache[container.id] == nil then
            containerSizeCache[container.id] = container.size()
        end

        slotsUsed = 0
        items = container.list()
        for i = 1, #container.size() do
            if items[i] ~= nil then
                slotsUsed = slotsUsed + 1
            end
        end

        newContainers[i] = containers[i]
        newContainers[i].slots = containerSizeCache[container.id]
        newContainers[i].slotsUsed = slotsUsed
        newContainers[i].type = peripheral.getType(container.id)

        -- Get list of items
        local items = container.list()
        if items == nil then
            print('No items found')
        else
            -- Loop through table of items
            for i, item in pairs(items) do
                -- Get item name
                local itemName = item.name

                item = {
                    chestId = container.id,
                    slot = i,
                    itemName = itemName,
                    count = item.count
                }

                -- Check if it contains a namespace (so no "bottom", "left", etc.)
                if string.find(container.id, ':') then
                    table.insert(itemCount, item)
                end
            end

        end
    end

    return itemCount, newContainers
end

while true do

    local start = os.clock()

    print(toLeft('Sync AP'), 'Getting APs')

    -- ! Send access points
    local peripherals = getNames()
    local accessPoints = {}
    local knownNames = {}
    for i, peripheralName in ipairs(peripherals) do
        if peripheral.getType(peripheralName) == 'turtle' then
            knownNames[peripheralName] = true
            accessPoints[#accessPoints + 1] = {
                id = peripheralName,
                name = peripheral.wrap(peripheralName).getLabel() or 'unknown'
            }
        end
    end

    local message = 'SET_ACCESS_POINTS'

    for i, x in ipairs(accessPoints) do
        -- AP ID, label
        message = message .. '\n' .. x.id .. '/' .. x.name
    end

    sendMessage(message)

    print(toLeft('Sync AP'), 'Sent APs')

    print(toLeft('Sync'), 'Getting items and containers')

    -- ! Send all containers
    local items, containers = getItemsAndContainersDetailed()

    print(toLeft('Sync'), 'Found ' .. #containers .. ' containers, ' .. #items .. ' items')

    local message = 'SET_CONTAINERS'

    for i, x in ipairs(containers) do
        -- Container ID / slots / slots used
        message = message .. '\n' .. x.id .. '/' .. x.type .. '/' .. x.slots .. '/' .. x.slotsUsed
    end

    sendMessage(message)

    print(toLeft('Sync container'), 'Sent containers')

    -- ! Send inventory
    local message = 'SET_INVENTORY'

    for i, x in ipairs(items) do
        -- Chest ID, slot, count, item name
        message = message .. '\n' .. x.chestId .. "/" .. x.slot .. "/" .. x.count .. "/" .. x.itemName
    end

    sendMessage(message)

    print(toLeft('Sync items'), 'Sent items')

    local w, h = term.getSize()
    print(string.rep('-', w))

    local diff = os.clock() - start

    local minInterval = 20
    local sleepTime = minInterval - diff
    if sleepTime < 0 then
        sleepTime = 0
    end

    print('Took ' .. diff .. ' seconds')
    print('Synced, sleeping ' .. sleepTime .. ' seconds...')

    os.sleep(sleepTime)
end

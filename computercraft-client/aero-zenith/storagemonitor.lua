while true do
    -- Find all vaults
    peripherals = peripheral.getNames()
    vaults = {}
    for i, name in ipairs(peripherals) do
        if string.find(name, 'item_vault') then
            table.insert(vaults, name)
        end
    end

    local monitor = peripheral.wrap('bottom')

    local capacities = {}
    local total_capacity = 0
    local total_items = 0
    for i, peripheralname in ipairs(vaults) do
        local vault = peripheral.wrap(peripheralname)
        local capacity = vault.size()
        local items = #vault.list()
        capacities[vault] = {capacity = capacity, items = items}
        total_capacity = total_capacity + capacity
        total_items = total_items + items
    end

    -- Sort capacities by items
    local sorted_vaults = {}
    for vault, data in pairs(capacities) do
        table.insert(sorted_vaults, {vault = vault, items = data['items'], capacity = data['capacity']})
    end
    table.sort(sorted_vaults, function(a, b) return a.items > b.items end)

    monitor.setTextScale(0.5)
    monitor.clear()
    monitor.setCursorPos(2, 2)
    -- Set color to gray 
    monitor.setTextColor(colors.lightGray)

    -- Basic info
    monitor.write('Slots Used:          ' .. total_items)
    monitor.setCursorPos(2, 3)
    monitor.write('Total Slot Capacity: ' .. total_capacity)
    monitor.setCursorPos(2, 4)
    monitor.write('Percentage full:     ' .. math.floor(total_items / total_capacity * 100) .. '%')
    
    -- Individual vault info
    local line = 6
    local width, height = monitor.getSize()
    print(width)
    for vault, data in ipairs(sorted_vaults) do
        monitor.setCursorPos(2, line)
        
        local ratio = data['items'] / data['capacity']
        local green = math.floor(ratio * (width - 3) + 0.5)
        local gray = (width - 3) - green
        print(ratio, green, gray, data['items'], data['capacity'])
        -- print(textutils.serialize(data), data['items'], data['capacity'])
        -- print('-')
        monitor.setBackgroundColor(colors.green)
        monitor.write(string.rep(' ', green))
        monitor.setBackgroundColor(colors.gray)
        monitor.write(string.rep(' ', gray))
        
        monitor.setBackgroundColor(colors.black)

        line = line + 2
    end


    sleep(1)
end
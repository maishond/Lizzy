require('utils')

local ws = getWs()
local apCanCraft = nil

function acknowledge(id, message)
    sendMessage('ACK_MESSAGE ' .. id .. '\n' .. message)
end

function depositSelf()
    local barrels = getBarrels()
    local transferred = 0;
    for i = 1, 16 do
        local j = 1

        local item = turtle.getItemDetail(i)

        while item do
            local barrel = barrels[j]
            transferred = transferred + barrel.pullItems(getTurtleName(), i)
            item = turtle.getItemDetail(i)
            j = j + 1
        end
    end
end

function drop()
    for i = 1, 16 do
        turtle.select(i)
        turtle.dropDown()
    end

    playSound()
end

function playSound()
    local speaker = peripheral.find('speaker')
    if speaker then
        speaker.playSound('minecraft:block.note_block.cow_bell', 1, 1)
    end
end

while true do
    print('Waiting for message...')
    sendMessage('LISTENING')
    local msg = ws.receive(10)
    if msg then
        local lines = split(msg, '\n')

        -- Get content (all lines after 1)
        local content = ''
        for i = 3, #lines do
            content = content .. lines[i]
            if i < #lines then
                content = content .. '\n'
            end
        end

        local command = lines[2]
        -- Execute all orders
        if command then

            local ACK_MESSAGE = 'UNKNOWN_COMMAND'

            print('command : ' .. command)

            local cleanedOutCache = {}

            -- TODO: clean all this up by moving into subfiles
            if command == 'DEPOSIT_SELF' or command == 'MOVE_ITEMS_DROP' then
                depositSelf()
                ACK_MESSAGE = 'DEPOSITED'
            end

            if command == 'MOVE_ITEMS' or command == 'MOVE_ITEMS_DROP' then
                turtle.select(1)
                -- Move list of items (fromContainer, fromSlot, toContainer, toSlot, quantity)
                local transferred = 0
                for i = 3, #lines do
                    local split = split(lines[i], '/')
                    local fromContainer = split[1]
                    local fromSlot = tonumber(split[2])
                    local toContainer = split[3]
                    local toSlot = tonumber(split[4])
                    local quantity = tonumber(split[5])

                    local compound = fromContainer .. fromSlot

                    if not cleanedOutCache[compound] then
                        local container = peripheral.wrap(fromContainer)
                        transferred = transferred + container.pushItems(toContainer, fromSlot, quantity, toSlot)

                        if not container.list()[fromSlot] then
                            cleanedOutCache[compound] = true
                        end
                    end

                    if command == 'MOVE_ITEMS_DROP' then
                        turtle.dropDown()
                    end
                end
                if command == 'MOVE_ITEMS_DROP' then
                    playSound()
                end
                ACK_MESSAGE = 'TRANSFERRED ' .. transferred
            end

            if command == 'CAN_CRAFT' then
                ACK_MESSAGE = tostring(not not turtle.craft)
            end

            if command == 'CRAFT' then
                turtle.craft()
                local item = turtle.getItemDetail(1)
                ACK_MESSAGE = (item and item.name or 'nil') .. ' ' .. (item and item.count or 0)
                depositSelf()
            end

            if command == 'DROP_DOWN' then
                drop()
                ACK_MESSAGE = 'DROPPED_DOWN'
            end

            -- Only after all orders are done, send acknowledgement with response. 
            acknowledge(lines[1], ACK_MESSAGE)

        end
    end
end

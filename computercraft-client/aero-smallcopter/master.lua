local modem = peripheral.wrap('front')
if not modem then
    error('No modem found')
end
modem.open(4810)
modem.open(4811)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if channel ~= 4810 then
        -- Ignore messages from other channels. This keeps them from being silently discarded
        -- before the loop can process the next valid message.
    else
        print(message)

        for key, value in pairs(message or {}) do
            print(key, ': ', value)
            
            local target = key
            if key == 'up' then
                target = 'Create_RotationSpeedController_10'
            elseif key == 'right' then
                target = 'left'
            elseif key == 'left' then
                target = 'right'
            end
            
            local device = peripheral.wrap(target)
            print(device)
            if device then
                device.setTargetSpeed(value)
            end
        end
    end
end
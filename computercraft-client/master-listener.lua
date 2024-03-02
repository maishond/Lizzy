-- Listen for messages on rednet and reply with storage system id
print('Initiating master listener...')

local storageSystemId = fs.open('storageSystemId.txt', 'r').readAll()

while true do
    peripheral.find("modem", rednet.open)

    local senderId, message, protocol = rednet.receive('master')
    print(senderId, message, protocol)

    if message == 'storageSystemId' then
        rednet.send(senderId, storageSystemId, 'storageSystemId')
    end

    if message == 'hostname' then
        local hostName = fs.open('hostname.txt', 'r').readAll()
        rednet.send(senderId, hostName, 'hostname')
    end
end

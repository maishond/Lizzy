-- File for master computer
-- See if a storageSystemId file exists
-- If not, prompt the user for an id and write it to the file
local storageSystemId = 'storageSystemId.txt'
if not fs.exists(storageSystemId) then
    print('Enter storage system ID:')
    local id = read()
    local file = fs.open(storageSystemId, 'w')
    file.write(id)
    file.close()
end

-- Write true to is-master.txt
local file = fs.open('is-master.txt', 'w')
file.write('true')
file.close()

-- Write self to startup
local file = fs.open('startup.lua', 'w')
file.write('shell.run("update") shell.run("master")')
file.close()

storageSystemId = fs.open(storageSystemId, 'r').readAll()

-- Listener (for in-network communication, like hostname & system ID)
shell.run('bg master-listener')

shell.run('master-ws')
print('Crashed or disconnected, restarting in 5 seconds...')
os.sleep(5)
os.reboot()

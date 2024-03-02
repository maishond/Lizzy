-- Import utils
require('utils')

-- File for access points
local file = fs.open('startup.lua', 'w')
file.write('shell.run("update") shell.run("client")')
file.close()

-- Check if xyz.txt exists. If it doesn't, create it
if not fs.exists('xyz.txt') then
    local x, y, z = gps.locate()
    print('x: ' .. (x or '0') .. ' y: ' .. (y or '0') .. ' z: ' .. (z or '0'))
    if x then
        local file = fs.open('xyz.txt', 'w')
        file.write(x .. ' ' .. y .. ' ' .. z)
        file.close()
    else
        print('To complete setup, please set up a GPS system and attach a modem to this computer')
        os.sleep(5)
        shell.run('reboot')
    end
end

sendMessage('STARTUP')

print('Running client-ws...')
shell.run('client-ws')
print('Crashed or disconnected, restarting in 5 seconds...')
os.sleep(5)
os.reboot()

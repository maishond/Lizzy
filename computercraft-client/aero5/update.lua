function getHostName()
    print('Getting hostname from master')
    -- Request hostname through rednet
    peripheral.find("modem", rednet.open)
    return 'lizzy.jipfr.nl/aero5'
end

local isMasterComputer = fs.exists('is-master.txt')
local onDeviceHostName = fs.exists('hostname.txt') and fs.open('hostname.txt', 'r').readLine() or nil
print('Is master: ' .. tostring(isMasterComputer))
local hostNameValue = 'lizzy.jipfr.nl/aero5/'
local hostName = isMasterComputer and (onDeviceHostName or hostNameValue) or getHostName()
local baseUrl = 'https://' .. hostName

-- Write baseUrl to file
local file = fs.open('hostname.txt', 'w')
file.write(hostName)
file.close()

local urls = {
    update = baseUrl .. '/update.lua',
    startup = baseUrl .. '/startup.lua',
    master = baseUrl .. '/master.lua',
    point2 = baseUrl .. '/point2.lua',
    point3 = baseUrl .. '/point3.lua',
    mods = baseUrl .. '/mods.lua',
    reset = baseUrl .. '/reset.lua',
    utils = baseUrl .. '/utils.lua',
}

-- Loop over urls
for key, url in pairs(urls) do
    -- Get response
    local response = http.get(url)

    if response ~= nil then
        -- Read response
        local responseText = response.readAll()

        -- Write to file
        local file = fs.open(key .. '.lua', 'w')
        file.write(responseText)
        file.close()
        print('Saved ' .. key .. '.lua')

        -- Close response
        response.close()
    else
        print('Failed to get response from ' .. url)
    end
end

-- Check if startup-override.lua exists, if so, replace startup.lua with it
if fs.exists('startup-override.lua') then
    fs.delete('startup.lua')
    fs.copy('startup-override.lua', 'startup.lua')
    print('Replaced startup.lua with startup-override.lua')
end
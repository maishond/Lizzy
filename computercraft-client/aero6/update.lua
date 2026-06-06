local hostName = 'lizzy.jipfr.nl/aero5'
local baseUrl = 'https://' .. hostName

local urls = {
    ['update.lua'] = baseUrl .. '/update.lua',
    ['startup.lua'] = baseUrl .. '/startup.lua',
    ['master.lua'] = baseUrl .. '/master.lua',
    ['point2.lua'] = baseUrl .. '/point2.lua',
    ['point3.lua'] = baseUrl .. '/point3.lua',
    ['mods.lua'] = baseUrl .. '/mods.lua',
    ['reset.lua'] = baseUrl .. '/reset.lua',
    ['utils.lua'] = baseUrl .. '/utils.lua',
    ['yawprop.lua'] = baseUrl .. '/yawprop.lua',
    ['forward.lua'] = baseUrl .. '/forward.lua',
    ['landing.dfpwm'] = baseUrl .. '/landing.dfpwm',
    ['goto.lua'] = baseUrl .. '/goto.lua',
    ['crashed.lua'] = baseUrl .. '/crashed.lua',
    ['hover.lua'] = baseUrl .. '/hover.lua',
    ['portable-radar.lua'] = baseUrl .. '/portable-radar.lua',
}

-- Loop over urls
for key, url in pairs(urls) do
    -- Get response
    print('G', url)
    local response = http.get(url)

    if response ~= nil then
        -- Read response
        local responseText = response.readAll()

        -- Write to file
        local file = fs.open(key, 'w')
        file.write(responseText)
        file.close()
        print('Saved ' .. key)

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
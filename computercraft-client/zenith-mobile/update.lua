local hostName = 'lizzy.jipfr.nl/zenith-mobile'
local baseUrl = 'https://' .. hostName

local urls = {
    ['update.lua'] = baseUrl .. '/update.lua',
    ['startup.lua'] = baseUrl .. '/startup.lua',
    ['info.lua'] = baseUrl .. '/info.lua',
    ['goto.lua'] = baseUrl .. '/goto.lua',
    ['reset.lua'] = baseUrl .. '/reset.lua',
    ['invert.lua'] = baseUrl .. '/invert.lua',
    ['stop.lua'] = baseUrl .. '/stop.lua',
    ['flip.lua'] = baseUrl .. '/flip.lua',
    ['summon.lua'] = baseUrl .. '/summon.lua',
    ['land.lua'] = baseUrl .. '/land.lua',
    ['takeoff.lua'] = baseUrl .. '/takeoff.lua',
    ['lower.lua'] = baseUrl .. '/lower.lua',
}

-- Loop over urls
for key, url in pairs(urls) do
    -- Get response
    -- print('G', url)
    local response = http.get(url)

    if response ~= nil then
        -- Read response
        local responseText = response.readAll()

        -- Write to file
        print(key)
        local file = fs.open(key, 'w')
        file.write(responseText)
        file.close()

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
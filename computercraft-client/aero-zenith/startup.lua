require('update')

if os.getComputerLabel() == 'Zenith Mobile' then
    shell.run('mobile.lua')
elseif os.getComputerLabel() == 'Storage Monitor' then
    shell.run('storagemonitor')
else
    shell.run('bg telemetry.lua')
    shell.run('bg listener.lua')
end
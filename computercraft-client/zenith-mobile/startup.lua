require 'update'

if os.getComputerLabel() == "Zenith Mobile" then
    shell.run('bg info')
    shell.run('bg')
else
    shell.run('progressmonitor')
end

shell.exit()
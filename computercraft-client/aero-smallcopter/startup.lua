require('update')

local modem = peripheral.find('modem')
modem.open(4810)

if os.getComputerLabel() == nil then
    require 'master'
end

local modem = peripheral.wrap("front")

require 'utils'

local function set_fl(l)
    modem.transmit(43, 0, 15 - l)
end

local function set_fr(l)
    modem.transmit(44, 0, 15 - l)
end

local function set_rr(l)
    modem.transmit(45, 0, 15 - l)
end

local function set_rl(l)
    modem.transmit(46, 0, 15 - l)
end


set_fl(0)
set_fr(0)
set_rr(0)
set_rl(0)

-- while true do
--     x, y, z = get_state()
--     if not y then return nil end
--     print(y)
--     if y > 10 then
--         set_fl(15)
--         set_fr(15, true)
--         set_rr(15)
--         set_rl(15, true)
--     else
--         set_fl(15)
--         set_fr(15)
--         set_rr(15)
--         set_rl(115)
--     end
-- end
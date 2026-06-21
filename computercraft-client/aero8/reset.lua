local modem = peripheral.wrap("front")

require 'mods'

peripheral.wrap('left').setTargetSpeed(0)
peripheral.wrap('right').setTargetSpeed(0)

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
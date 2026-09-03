
navtable = peripheral.wrap('navigation_table_2')
frontprops = peripheral.wrap('Create_RotationSpeedController_9')
rearprops = peripheral.wrap('Create_RotationSpeedController_6')
leftprops = peripheral.wrap('Create_RotationSpeedController_8')
rightprops = peripheral.wrap('Create_RotationSpeedController_7')

reartofrontratio = 118/256
-- righttoleftratio = 235/256
righttoleftratio = 256/256

local basepower = 150
MIN_VERT_POWER = 100
MAX_VERT_POWER = 256
-- frontprops.setTargetSpeed(basepower)
-- rearprops.setTargetSpeed(basepower * reartofrontratio)

-- local horizontalpower = -256
-- leftprops.setTargetSpeed(horizontalpower)
-- rightprops.setTargetSpeed(horizontalpower * righttoleftratio)

function clamp(min, v, max)
    if v > max then return max end
    if v < min then return min end
    return v
end

function get_state()
	-- ! PC is 13 (?) blocks from the center
	local base_x, y, base_z = gps.locate(0.1)
    if base_x then
		local yaw = navtable.getRelativeAngle() - 180
		local yaw_rad = math.rad(yaw - 90)
		local distance = 33.5
		x = base_x - distance * math.sin(yaw_rad)
		z = base_z - distance * math.cos(yaw_rad)

		local pitch = 0
		local roll = 0
		
		return x, y, z, pitch, yaw, roll
	end
end
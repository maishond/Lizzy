
navtable = peripheral.wrap('navigation_table_1')
frontprops = peripheral.wrap('Create_RotationSpeedController_5')
rearprops = peripheral.wrap('Create_RotationSpeedController_4')
leftprops = peripheral.wrap('Create_RotationSpeedController_2')
rightprops = peripheral.wrap('Create_RotationSpeedController_3')

reartofrontratio = 122/256
righttoleftratio = 237/256

-- local basepower = 256
-- local horizontalpower = -256
-- frontprops.setTargetSpeed(basepower)
-- rearprops.setTargetSpeed(basepower * reartofrontratio)

-- leftprops.setTargetSpeed(horizontalpower)
-- rightprops.setTargetSpeed(horizontalpower * righttoleftratio)
-- leftprops.setTargetSpeed(0)
-- rightprops.setTargetSpeed(0)

function clamp(min, v, max)
    if v > max then return max end
    if v < min then return min end
    return v
end

function get_state()
	-- ! PC is 13 (?) blocks from the center
	local base_x, y, base_z = gps.locate(0.1)
    if base_x then
		local yaw = navtable.getRelativeAngle() - 90
		local yaw_rad = math.rad(yaw + 0)
		x = base_x - 13 * math.sin(yaw_rad)
		z = base_z - 13 * math.cos(yaw_rad)

		local pitch = 0
		local roll = 0
		
		return x, y, z, pitch, yaw, roll
	end
end
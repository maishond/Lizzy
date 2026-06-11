function split(str, delimiter)
    local result = {}

    for v in string.gmatch(str, "([^" .. delimiter .. "]+)") do
        result[#result + 1] = v
    end

    return result
end

function clamp(min, v, max)
    if v > max then return max end
    if v < min then return min end
    return v
end

function angle_diff(a, b)
	local d = a - b

	while d > math.pi do
		d = d - math.pi * 2
	end

	while d < -math.pi do
		d = d + math.pi * 2
	end

	return d
end

local function normalize(x, y, z)
    local m = math.sqrt(x*x + y*y + z*z)
    if m < 1e-9 then
        return 0, 0, 0
    end
    return x/m, y/m, z/m
end

local function cross(ax, ay, az, bx, by, bz)
    return
        ay*bz - az*by,
        az*bx - ax*bz,
        ax*by - ay*bx
end

function get_state()
    local modem = peripheral.wrap("back")
    modem.open(41)
    modem.open(42)

    local rear_msg
    local right_msg

    while not (rear_msg and right_msg) do
        local _, _, channel, _, message =
            os.pullEvent("modem_message")

        if channel == 42 then
            rear_msg = message
        elseif channel == 41 then
            right_msg = message
        end
    end

    local rear = split(rear_msg, " ")
    local right = split(right_msg, " ")

    local p2_x = tonumber(rear[1])
    local p2_y = tonumber(rear[2])
    local p2_z = tonumber(rear[3])

    local p3_x = tonumber(right[1])
    local p3_y = tonumber(right[2])
    local p3_z = tonumber(right[3])

    local x, y, z = gps.locate(0.1)

    if not (x and p2_x and p3_x) then
        return nil
    end

    ------------------------------------------------------------------
    -- Marker vectors in world coordinates
    ------------------------------------------------------------------

    local rx = p2_x - x
    local ry = p2_y - y
    local rz = p2_z - z

    local qx = p3_x - x
    local qy = p3_y - y
    local qz = p3_z - z

    ------------------------------------------------------------------
    -- Normalize marker directions
    ------------------------------------------------------------------

    rx, ry, rz = normalize(rx, ry, rz)
    qx, qy, qz = normalize(qx, qy, qz)

    ------------------------------------------------------------------
    -- Body axes
    --
    -- rear marker = behind center
    -- right marker = right of center
    ------------------------------------------------------------------

    local fx = -rx
    local fy = -ry
    local fz = -rz

    local rix = qx
    local riy = qy
    local riz = qz

    local ux, uy, uz =
        cross(fx, fy, fz,
              rix, riy, riz)

    ux, uy, uz = normalize(ux, uy, uz)

    ------------------------------------------------------------------
    -- Yaw
    --
    -- 0 = north (+z)
    -- 90 = east (+x)
    ------------------------------------------------------------------

    local yaw =
        math.deg(math.atan2(fx, fz))

    if yaw < 0 then
        yaw = yaw + 360
    end

    ------------------------------------------------------------------
    -- Pitch
    ------------------------------------------------------------------

    local pitch =
        math.deg(math.atan2(fy,
            math.sqrt(fx*fx + fz*fz)))

    ------------------------------------------------------------------
    -- Roll
    ------------------------------------------------------------------

    local roll =
        math.deg(math.atan2(riy, uy))

    return x, y, z, pitch, yaw, roll
end
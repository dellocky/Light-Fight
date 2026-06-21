--[[Hand Coded physics module, with some vector math support]]

local Physics = {}

function Physics.vectorSub(start_coordinate, destination_coordinate)
    return start_coordinate.x - destination_coordinate.x, start_coordinate.y - destination_coordinate.y
end

function Physics.vectorLength(x, y)
    return math.sqrt(x * x + y * y)
end

function Physics.normalize(x, y)
    local length = Physics.vectorLength(x, y)
    if length == 0 then
        return 0, 0
    end
    return x / length, y / length
end

--sliding effect
function Physics.updateVelocity(velocity, dirX, dirY, acceleration, friction, maxSpeed, dt)
    if dirX ~= 0 or dirY ~= 0 then
        local nx, ny = Physics.normalize(dirX, dirY)
        velocity.x = velocity.x + nx * acceleration * dt
        velocity.y = velocity.y + ny * acceleration * dt

        local speed = Physics.vectorLength(velocity.x, velocity.y)
        if speed > maxSpeed then
            local scale = maxSpeed / speed
            velocity.x = velocity.x * scale
            velocity.y = velocity.y * scale
        end
    else
        local speed = Physics.vectorLength(velocity.x, velocity.y)
        if speed > 0 then
            local stopAmount = friction * dt
            local newSpeed = math.max(speed - stopAmount, 0)
            local scale = newSpeed / speed
            velocity.x = velocity.x * scale
            velocity.y = velocity.y * scale
        end
    end

    return velocity
end

return Physics

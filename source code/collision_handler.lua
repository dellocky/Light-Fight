--[[The point of this module is to handle object movement such that it is calculated on a step by step basis
    the reason for this is that I had a serious issue with "tunneling" (where an object moves fast enough that
    it goes through walls), due to the nature of having fast entities and projecties with small hitboxes
]]

local Collision = {}
--[[Hand Written function -- Checks an object against a group of objects for collisions]]
function Collision.check_collision(root_entity, entities)

    for other in entities:each() do
        if other ~= root_entity and other.hitbox_map then
            for _, ohb in ipairs(other.hitbox_map) do
                for _, rhb in ipairs(root_entity.hitbox_map) do
                    if rhb:check_collision(ohb) then
                        return other
                    end
                end
            end
        end
    end

    return false

end
-- Partially AI created function - Swept collision detection: moves entity incrementally and checks collisions at each step
-- Allows to check for collisions regardless of speed, and stop the movement when a collision occurs
function Collision.swept_move(entity, dt, collision_entities)
    local move_x = entity.velocity.x * dt
    local move_y = entity.velocity.y * dt
    local hitbox_size = entity.hitbox_size

    local function check_collision()
        return Collision.check_collision(entity, collision_entities)
    end

    local function resolve_axis(axis, delta, axis_name)
        if delta == 0 then
            return true
        end

        local original = entity[axis]
        entity[axis] = original + delta
        entity:update_hitboxes()

        local other = check_collision()
        if not other then
            return true
        end
        
        --Based off the current delta time as to prevent lag, this comes at the cost of projectile tunneling
        --But increaced the number of entities that could be processed by a factor of nearly 10X
        local step_size = hitbox_size * 0.5
        local steps = math.max(1, math.ceil(math.abs(delta) / step_size))
        local step_delta = delta / steps

        --Resolves Axies indivdually, allows for dynamic collision handling on the part of the object colided with
        entity[axis] = original
        entity:update_hitboxes()

        for step = 1, steps do
            entity[axis] = original + step_delta * step
            entity:update_hitboxes()
            other = check_collision()

            if other then
                if entity.collision == true then
                    entity[axis] = original + step_delta * (step - 1)
                    entity:update_hitboxes()
                else
                    entity[axis] = original
                    entity:update_hitboxes()
                end

                other:collide(entity, axis_name, original)
                return false
            end
        end

        return true
    end

    if not resolve_axis("x", move_x, "x") then
        return
    end

    resolve_axis("y", move_y, "y")
end
return Collision





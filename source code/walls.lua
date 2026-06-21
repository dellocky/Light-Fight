-- Wall class to generate the boundaries of the map,
--TODO make these prettier



local Wall = {}
local Hitbox = require("hitbox")


Wall.__index = Wall

function Wall:new(start_coordinate, destination_coordinate, color, thickness)
    local self = setmetatable({}, Wall)
    self.start_coordinate = start_coordinate
    self.destination_coordinate = destination_coordinate
    self.color = color
    self.thickness = thickness

    -- Calculate min/max bounds directly from the raw coordinates
    self.min_x = math.min(start_coordinate.x, destination_coordinate.x)
    self.max_x = math.max(start_coordinate.x, destination_coordinate.x)
    
    self.min_y = math.min(start_coordinate.y, destination_coordinate.y)
    self.max_y = math.max(start_coordinate.y, destination_coordinate.y)

    -- Expand hitbox by thickness so lines have area for collisions
    local half_thick = (thickness or 0) * 0.5
    self.hitbox_map = {
        Hitbox:new(self.min_x - half_thick, self.min_y - half_thick, (self.max_x - self.min_x) + half_thick * 2, (self.max_y - self.min_y) + half_thick * 2)
    }

    return self
end

function Wall:update(dt)
    --Interface needed in current archetecture, TODO improve the arch
end


function Wall:collide(entity, axis)
    -- Check if entity is a projectile
    if entity.type == "projectile" then
        if projectiles_pool then
            projectiles_pool:remove(entity)
        end
        return
    end

    -- bouncing for non-projectile collisions
    local bounce = entity.bounce_factor or 0.5

    if axis == "x" then
        entity.velocity.x = -entity.velocity.x * bounce
    else
        entity.velocity.y = -entity.velocity.y * bounce
    end
end


function Wall:draw()
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(self.thickness)

    love.graphics.line(self.start_coordinate.x, self.start_coordinate.y,
                       self.destination_coordinate.x, self.destination_coordinate.y)
    love.graphics.setLineWidth(1)
    if debug_rects == 1 then
        for i = 1, #self.hitbox_map do
            self.hitbox_map[i]:draw()
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

end
return Wall








    

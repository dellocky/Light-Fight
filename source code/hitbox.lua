--[[Handcoded very basic hitbox rectangle object to check for collisions, draw function for debugging]]

local Hitbox = {}
Hitbox.__index =  Hitbox

function Hitbox:new(x, y, w, h)
    local self = setmetatable({}, Hitbox)

    self.width = w
    self.height = h

    self.left = x
    self.right = x + w
    self.top = y
    self.bot = y + h

    return self
end

--Tracking
function Hitbox:move(x, y)
    self.left = x
    self.right = x + self.width
    self.top = y
    self.bot = y + self.height
end 

function Hitbox:draw()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", self.left, self.top, self.right - self.left, self.bot - self.top)
    love.graphics.setColor(1, 1, 1, 1)
end

function Hitbox:check_collision(colliding_hitbox)
    -- If any of these 4 conditions are true, there is NO collision:
    if self.right <= colliding_hitbox.left or   -- Self is completely to the left
       self.left >= colliding_hitbox.right or   -- Self is completely to the right
       self.bot <= colliding_hitbox.top or      -- Self is completely above
       self.top >= colliding_hitbox.bot then    -- Self is completely below
        return false
    end
    -- If none of the above are true, they must be overlapping
    return true
end

return Hitbox
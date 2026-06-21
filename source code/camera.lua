--[[Hand Written Module to keep the game centered on the player, very useful as it allows us to
    easily display entities with respect to the player's current Position
]]

local Camera = {}
Camera.__index = Camera

function Camera:new(x, y, viewport_width, viewport_height, scale)
    local self = setmetatable({}, Camera)

    self.x = x
    self.y = y

    self.viewport_width = viewport_width
    self.viewport_height = viewport_height

    self.scale = scale

    return self
end

function Camera:update(dt, target)
    if target then
        self.x = target.x
        self.y = target.y
    end
end

--Applies offset
function Camera:attach()
    love.graphics.push()

    love.graphics.translate(
        self.viewport_width / 2 - self.x,
        self.viewport_height / 2 - self.y
    )
end

--Removes offset for future UI elements
function Camera:detach()
    love.graphics.pop()
end

--Needed for targeting, transforms the absolute position of the mouse on the screen into
--A relevant game position
function Camera:get_relative_mouse_coordinate()
    local mouse_x, mouse_y = love.mouse.getPosition()

    local canvas_mouse_x = mouse_x / (love.graphics.getWidth() / self.viewport_width)
    local canvas_mouse_y = mouse_y / (love.graphics.getHeight() / self.viewport_height)

    return
        canvas_mouse_x  + self.x - self.viewport_width / 2,
        canvas_mouse_y + self.y - self.viewport_height / 2
    end

return Camera
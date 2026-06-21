--[[Most logic is in the ship parent class, player class handles input support
and locks the camera onto it

--TODO make controls dynamic and rebindable for other systems
]]

local Ship = require("ship")
local Weapons = require("weapons")

local Player = setmetatable({}, { __index = Ship })
Player.__index = Player

function Player:new(x, y, camera)
    local self = Ship:new(x, y)
    setmetatable(self, Player)
    self.name = "player"
    self.team = 1
    self.base_color = {0, 1, 0, 1}
    self.health = 300
    self.division_line_color  = {0, .8, 0, 1}
    self.outline_color = {0, 0.1, 0, 1}
    self.weapon_list = {Weapons.Laser:new(self),
                        Weapons.Sword:new(self)
        }
    self.current_weapon = 1
    self.weapon = self.weapon_list[self.current_weapon]
    self.camera = camera

    self.base_max_speed = 500
    self.current_max_speed = 500
    self.base_acceleration = 1300
    self.current_acceleration = 1300
    self.base_friction = 600
    self.current_friction = 600
    self.swap_max_cooldown = .2
    self.swap_current_cooldown = 0
    if god_mode == 1 then
        self.health = 1000
    end
    return self
end


function Player:update(dt)
    local mouse_x, mouse_y = self.camera:get_relative_mouse_coordinate()
    self.angle = math.atan2(mouse_y - self.y, mouse_x - self.x)

    local move_x = 0
    local move_y = 0

    if god_mode == 1 then
        self.health = 1000
    end

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        move_x = move_x - 1
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        move_x = move_x + 1
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        move_y = move_y - 1
    end

    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        move_y = move_y + 1
    end

    if love.keyboard.isDown("space") and self.boost_current_cooldown <= 0 then
        self:boost()
    end

    if love.keyboard.isDown("tab")  and self.swap_current_cooldown <= 0 then
        self.current_weapon = (self.current_weapon % #self.weapon_list) + 1
        self.weapon = self.weapon_list[self.current_weapon]
        self.swap_current_cooldown = self.swap_max_cooldown
    end

    if love.mouse.isDown("1") then
        self:attack(mouse_x, mouse_y, self.angle)
    end

    if self.swap_current_cooldown > 0 then
        self.swap_current_cooldown = self.swap_current_cooldown - dt
    end

    self.move_x = move_x
    self.move_y = move_y

    Ship.update(self, dt)
    
end


return Player
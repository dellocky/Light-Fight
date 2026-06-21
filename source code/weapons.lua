local weapons = {}

-- Base Weapon class
local Weapon = {}
local Physics = require("physics")
local Projectiles = require("projectiles") 

Weapon.__index = Weapon

function Weapon:new(user)
    local self = setmetatable({}, Weapon)
    self.user = user
    self.current_cooldown = 0
    self.max_cooldown = 1.0
    self.damage = 0
    return self
end

function Weapon:update(dt)
    if self.current_cooldown > 0 then
        self.current_cooldown = self.current_cooldown - dt
    end
end

function Weapon:attack()
    if self.current_cooldown <= 0 then
        self.current_cooldown = self.max_cooldown
        return true
    end
    return false
end

function Weapon:draw()
    -- Override in subclasses
end

-- Laser Weapon subclass
local Laser = setmetatable({}, { __index = Weapon })
Laser.__index = Laser

function Laser:new(user)
    local self = Weapon:new(user)
    setmetatable(self, Laser)

    self.max_cooldown = 0.2
    self.current_cooldown = 0

    return self
end

function Laser:attack(x, y, angle)

    local active_port = self.user.gun_ports[self.user.active_gun_port]

    local starting_position = {
        x = active_port.gun_mid.x,
        y = active_port.gun_mid.y
    }
    
    local target_position = {
        x = x,
        y = y
    }

    if self.current_cooldown <= 0 then
        self.current_cooldown = self.max_cooldown
        local vx, vy = Physics.normalize(Physics.vectorSub(target_position, starting_position))
        assert(projectiles_pool, "projectiles_pool must be initialized before firing")
        projectiles_pool:register(Projectiles.LaserBullet:new(
            starting_position.x,
            starting_position.y,
            { x = vx, y = vy },
            angle,
            self.user.base_color,
            self.user.team))
        return true
    end

    return false
end

function Laser:draw()
end

-- Sword Weapon subclass
local Sword = {}
Sword.__index = Sword
setmetatable(Sword, { __index = Weapon })

function Sword:new(user)

    local self = Weapon:new(user)
    setmetatable(self, Sword)

    self.max_cooldown = 0.45

    self.damage = 40

    self.dash_force = 2000

    return self
end

function Sword:attack(target_x, target_y, angle)

    if self.current_cooldown > 0 then
        return false
    end
    self.current_cooldown = self.max_cooldown
    self.user.external_velocity.x = self.user.external_velocity.x + math.cos(angle) * self.dash_force
    self.user.external_velocity.y = self.user.external_velocity.y + math.sin(angle) * self.dash_force

    --TODO normalize these function signatures
    local slash =
        Projectiles.SwordSlash:new(
            self.user,
            self.damage
        )

    projectiles_pool:register(slash)

    return true
end



-- Register classes in weapons module
weapons.Weapon = Weapon
weapons.Laser = Laser
weapons.Sword = Sword

return weapons


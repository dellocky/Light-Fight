--Base Class for player and opponets

local Ship = {}
Ship.__index = Ship

local Hitbox = require("hitbox")
local Physics = require("physics")

local flame_shader = love.graphics.newShader("flame.glsl")

--Mesh vertex cord for shader
local unit_mesh = love.graphics.newMesh({
    {0, 0, 0, 0}, -- Top Left
    {1, 0, 1, 0}, -- Top Right
    {1, 1, 1, 1}, -- Bottom Right
    {0, 1, 0, 1}  -- Bottom Left
}, "fan", "static")

function Ship:new(x, y)
    local self = setmetatable({}, Ship)
    self.team = 2
    self.x = x
    self.y = y
    self.pos = { x = self.x, y = self.y }
    self.type = "ship"
    self.collision = true
    self.value = 0

    --Color scheme
    self.base_color = {1, 1, 1, 1}
    self.division_line_color = {1, 1, 1, 1}
    self.outline_color = {1, 1, 1, 1}
    self.port_color = {.3, .3, .3, 1}

    self.size = 15
    self.booster_size = self.size * 0.25
    self.booster_x = -self.size * 0.65

    --Shader Size
    self.flame_w = self.booster_size * 4
    self.flame_h = self.booster_size


    local gun_size = self.size * .2
    local gun_x = self.size * .25

    --Spawn projectiles from ports
    self.gun_ports = {
        {
            gun_size = gun_size,
            gun_x = gun_x,
            gun_y = -self.size * .3,
            gun_mid = { x = 0, y = 0 }
        },
        {
            gun_size = gun_size,
            gun_x = gun_x,
            gun_y = self.size * .05,
            gun_mid = { x = 0, y = 0 }
        }
    }

    self.active_gun_port = 1

    self.angle = 0
    self.hitbox_size = self.size * 0.6
    self.rotationSpeed = 3
    self.weapon = 0
    self.creation_time = love.timer.getTime()

    self.velocity = { x = 0, y = 0 }
    --TODO, sword supposed to move ship forward but bug somewhere
    self.external_velocity = {x = 0, y = 0}
    self.speed = 0

    --Physics params
    self.base_max_speed = 500
    self.current_max_speed = 500
    self.base_acceleration = 1300
    self.current_acceleration = 1300
    self.base_friction = 600
    self.current_friction = 600

    self.health = 100

    self.move_x = 0
    self.move_y = 0

    -- Boost effect currently only used by player, planned to be inhereted by charger enemey class
    self.is_boosting = 0
    self.boost_factor = 2.0

    self.boost_max_cooldown = 2
    self.boost_current_cooldown = 0

    self.boost_max_duration = .75
    self.boost_current_duration = 0

    self.hitbox_map = {
        Hitbox:new(
            self.x - self.hitbox_size * 0.5,
            self.y - self.hitbox_size * 0.5,
            self.hitbox_size,
            self.hitbox_size
        )
    }

    return self
end

function Ship:update(dt)
    --apply phsyics to object
    Physics.updateVelocity(self.velocity, self.move_x, self.move_y, self.current_acceleration, self.current_friction, self.current_max_speed, dt)
    self.speed = math.sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y)
    self.pos.x = self.x
    self.pos.y = self.y

    self.external_velocity.x = self.external_velocity.x * 0.85
    self.external_velocity.y = self.external_velocity.y * 0.85
    
    --Timers
    if self.is_boosting == 1 then
        self.boost_current_duration = self.boost_current_duration - dt
    end
    
    if self.boost_current_duration <= 0 and self.is_boosting == 1 then
        self.is_boosting = 0
        self.current_max_speed = self.base_max_speed
        self.current_acceleration = self.base_acceleration
        self.current_friction = self.base_friction
    end
    
    if self.boost_current_cooldown > 0 then
        self.boost_current_cooldown = self.boost_current_cooldown - dt
    end

    if self.weapon then
        self.weapon:update(dt)
    end

    self:updateGunPorts()
end

function Ship:updateGunPorts()
    --track port locations with player movement
    local cos_a = math.cos(self.angle)
    local sin_a = math.sin(self.angle)

    for _, port in ipairs(self.gun_ports) do
        local local_x = port.gun_x + port.gun_size * 0.5
        local local_y = port.gun_y + port.gun_size * 0.5

        port.gun_mid.x = self.x + local_x * cos_a - local_y * sin_a
        port.gun_mid.y = self.y + local_x * sin_a + local_y * cos_a
    end
end

function Ship:boost()
    self.is_boosting = 1
    self.boost_current_cooldown = self.boost_max_cooldown
    self.boost_current_duration = self.boost_max_duration

    self.current_max_speed = self.current_max_speed * self.boost_factor
    self.current_acceleration = self.current_acceleration * self.boost_factor
    self.current_friction = self.current_friction * 1/self.boost_factor
end

function  Ship:attack(x, y, angle)
    --fire weapon
    if self.weapon then
        local fired = self.weapon:attack(x, y, angle) -- ensure weapon is fired for proper gun port effect
        if fired then
            self.active_gun_port = (self.active_gun_port % #self.gun_ports) + 1
        end
    end

end

function Ship:damage(amount)
    --when hit
    self.health = self.health - amount
    if self.health <= 0 then
        if self.team ~= 0 then
            score = score + self.value
        end
        entities_pool:remove(self)
    end
end

function Ship:update_hitboxes()
        local offset = self.hitbox_size * 0.5
        for _, hitbox in ipairs(self.hitbox_map) do
            hitbox:move(self.x - offset, self.y - offset)
        end
    end


function Ship:collide(entity, axis)
    -- Check if entity is a projectile and if so its team
    if entity.type == "projectile" and entity.can_damage then
        if entity.team ~= self.team then
            self:damage(entity.damage)
            if not entity.piercing then
                entity.can_damage = true
                projectiles_pool:remove(entity)
            end
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

function Ship:draw()
    love.graphics.push() -- change drawing context into ship
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    local base_intensity = .2
    local intensity = base_intensity + (1 - base_intensity) * (self.speed / self.current_max_speed)
    local flame_color = self.is_boosting

    if self.speed > 5 then
        local elapsed_time = love.timer.getTime() - self.creation_time
        flame_shader:send("time", elapsed_time)
        flame_shader:send("intensity", intensity)
        flame_shader:send("flame_color", flame_color)

        love.graphics.setShader(flame_shader)
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

        love.graphics.draw(unit_mesh, self.booster_x - self.flame_w, -self.size * 0.3, 0, self.flame_w, self.flame_h)
        love.graphics.draw(unit_mesh, self.booster_x - self.flame_w, self.size * 0.05, 0, self.flame_w, self.flame_h)

        love.graphics.setShader()
    end

    love.graphics.setColor(self.base_color)
    love.graphics.polygon(
        "fill",
        self.size, 0,
        -self.size * 0.5, self.size * 0.5,
        -self.size * 0.5, -self.size * 0.5
    )

    love.graphics.setColor(self.division_line_color )
    love.graphics.setLineWidth(2)
    love.graphics.line(
        self.size * 0.7, 0,
        -self.size * 0.35, 0
    )
    love.graphics.setColor(self.outline_color)
    love.graphics.polygon(
        "line",
        self.size, 0,
        -self.size * 0.5, self.size * 0.5,
        -self.size * 0.5, -self.size * 0.5
    )
    love.graphics.setLineWidth(1)

    love.graphics.setColor(self.port_color)
    love.graphics.rectangle("fill", self.gun_ports[1].gun_x, self.gun_ports[1].gun_y, self.gun_ports[1].gun_size,  self.gun_ports[1].gun_size)
    love.graphics.rectangle("fill", self.gun_ports[2].gun_x, self.gun_ports[2].gun_y, self.gun_ports[2].gun_size,  self.gun_ports[2].gun_size)


    love.graphics.rectangle("fill", self.booster_x, -self.size * 0.25, self.booster_size, self.booster_size)
    love.graphics.rectangle("fill", self.booster_x, self.size * 0.05, self.booster_size, self.booster_size)

    love.graphics.pop()
    if debug_rects == 1 then
        for i = 1, #self.hitbox_map do
            self.hitbox_map[i]:draw()
        end
    end


    love.graphics.setColor(1, 1, 1, 1)
end

return Ship

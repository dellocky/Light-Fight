local Projectiles = {}
local Hitbox = require("hitbox")


--[[ LaserBullet Weapon Class - Handcoded:
    The projectiles fired from the laser gun, takes in parameters for its coordinates and vector
    for inertail conditions
]]
local LaserBullet = {}
LaserBullet.__index = LaserBullet

function LaserBullet:new(x, y, vector, angle, color, team)
    local self = setmetatable({},  LaserBullet)

    self.name = "laserbullet"
    self.x = x
    self.y = y
    self.pos = { x = self.x, y = self.y }
    self.damage = 20
    self.team = team
    self.type = "projectile"

    self.collision = false
    self.can_damage = true
    
    self.speed = 2000
    self.vector = {
        x = vector.x,
        y = vector.y
    }

    self.velocity = {
    x = 0,
    y = 0
    }

    self.angle = angle
    self.size = 3

    self.base_color = color
    self.outline_color = {self.base_color[1] * .1, self.base_color[2] * .1, self.base_color[3] * .1, 1}

    self.hitbox_size = self.size * 0.6
    self.hitbox_map = {
        Hitbox:new(
            self.x - self.hitbox_size * 0.5,
            self.y - self.hitbox_size * 0.5,
            self.hitbox_size,
            self.hitbox_size
        )
    }
    self.max_life_span = .5
    self.current_life_span = 0

    return self
end

function LaserBullet:update(dt)
    self.velocity.x = self.speed * self.vector.x
    self.velocity.y = self.speed * self.vector.y
    self.pos.x = self.x
    self.pos.y = self.y
    self.current_life_span = self.current_life_span + dt
    if self.current_life_span >= self.max_life_span then
        projectiles_pool:remove(self)
    end
    
end


function LaserBullet:collide(entity, axis)
end

function LaserBullet:update_hitboxes()
        local offset = self.hitbox_size * 0.5
        for _, hitbox in ipairs(self.hitbox_map) do
            hitbox:move(self.x - offset, self.y - offset)
        end
    end

function LaserBullet:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    love.graphics.setColor(self.base_color)
    love.graphics.ellipse("fill", 0, 0, self.size * 2, self.size)

    love.graphics.setLineWidth(2)
    love.graphics.setColor(self.outline_color)
    love.graphics.ellipse("line", 0, 0, self.size * 2, self.size)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
    if debug_rects == 1 then
        for i = 1, #self.hitbox_map do
            self.hitbox_map[i]:draw()
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

--Sword Mostly AI coded, lack of parent class and cleaning this mess up is a TODO, 
local SwordSlash = {}
SwordSlash.__index = SwordSlash

local Hitbox = require("hitbox")

function SwordSlash:new(owner, damage)

    local self = setmetatable({}, SwordSlash)

    self.owner = owner

    self.name = "swordslash"

    self.x = owner.x
    self.y = owner.y
    self.angle = owner.angle

    self.pos = {
        x = self.x,
        y = self.y
    }

    self.type = "projectile"
    self.team = owner.team
    self.damage = damage 
    self.can_damage = true
    self.piercing = true
    self.collision = false
    self.velocity = {
        x = 0,
        y = 0
    }
    self.speed = 400

    self.velocity = {
        x = math.cos(owner.angle) * self.speed,
        y = math.sin(owner.angle) * self.speed
    }

    self.radius = owner.size * 4

    self.arc_angle = math.rad(120)

    self.hitbox_size = owner.size * 0.9

    self.hitbox_count = 5

    self.life_time = 0.15
    self.current_life = 0

    self.hitbox_map = {}

    for i = 1, self.hitbox_count do

        table.insert(
            self.hitbox_map,
            Hitbox:new(
                self.x,
                self.y,
                self.hitbox_size,
                self.hitbox_size
            )
        )
    end
    self:update_hitboxes()
    return self
end

-- Custom hitbox editing function, to create a fan/sword shape
-- not perfect but works decently right now
function SwordSlash:update_hitboxes()

    local start_angle =
        self.angle -
        self.arc_angle * 0.5

    local step_angle =
        self.arc_angle /
        (self.hitbox_count - 1)

    for index, hitbox in ipairs(self.hitbox_map) do

        local arc_progress =
            (index - 1) /
            (self.hitbox_count - 1)


        local hitbox_angle =
            start_angle +
            step_angle * (index - 1)

        local distance_multiplier =
            0.75 +
            math.sin(
                arc_progress * math.pi
            ) * 0.5

        local hitbox_radius =
            self.radius *
            distance_multiplier

        local hitbox_x =
            self.x +
            math.cos(hitbox_angle) *
            hitbox_radius

        local hitbox_y =
            self.y +
            math.sin(hitbox_angle) *
            hitbox_radius

        hitbox:move(
            hitbox_x - self.hitbox_size * 0.5,
            hitbox_y - self.hitbox_size * 0.5
        )
    end
end

function SwordSlash:update(dt)

    self.current_life =
        self.current_life + dt

    if self.current_life >= self.life_time then
        projectiles_pool:remove(self)
        return
    end
end

function SwordSlash:collide(entity, axis)
end

function SwordSlash:draw()

    
    local alpha =
        1 -
        (self.current_life / self.life_time)

    love.graphics.setColor(
        self.owner.base_color[1],
        self.owner.base_color[2],
        self.owner.base_color[3],
        alpha
    )

    love.graphics.setLineWidth(4)

    love.graphics.arc(
        "line",
        "open",
        self.owner.x,
        self.owner.y,
        self.radius,
        self.owner.angle - self.arc_angle * 0.5,
        self.owner.angle + self.arc_angle * 0.5
    )

    love.graphics.setLineWidth(1)

    if debug_rects == 1 then
        for _, hitbox in ipairs(self.hitbox_map) do
            hitbox:draw()
        end
    end

    love.graphics.setColor(1,1,1,1)
end

Projectiles.SwordSlash = SwordSlash
Projectiles.LaserBullet = LaserBullet
return Projectiles


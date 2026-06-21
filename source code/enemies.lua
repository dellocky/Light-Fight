--[[
    This is a module created with the assitance of AI with the idea to have an enemy that tries 
    to strafe and "kite" (keeping something at a distance while shooting it) the player, planned to have
    a melee advisary as well that "charged" the player instead using the sword weapon but ran out of time
    as well as an "assassin" type enemy that tried to sneak up on the player,

    I was able to extrapolate many AI behaviors into this one enemy though
    in a way that I belive is unique and satisfactory for the target genere
]]


local Ship = require("ship")
local Weapons = require("weapons")
local Enemies = {}

local Shooter = {}
Shooter.__index = Shooter
setmetatable(Shooter, { __index = Ship })

function Shooter:new(x, y, player)
    local self = Ship:new(x, y)
    setmetatable(self, Shooter)

    self.player = player
    self.name = "shooter"
    self.size = 12

    self.health = 40
    self.base_max_speed = 350
    self.current_max_speed = 350
    self.base_acceleration = 600
    self.current_acceleration = 600
    self.base_friction = 600
    self.current_friction = 600
    self.value = 20

    self.base_color = {1, 0, 0, 1}
    self.division_line_color = {.8, 0, 0, 1}
    self.outline_color = {.1, 0, 0, 1}

    self.range = 360
    self.kite_distance = 270

    self.strafe_direction = 1
    self.strafe_timer = 0
    self.strafe_min_time = 1.5
    self.strafe_max_time = 3.5

    self.procces_current_time = 0
    self.procces_delay = .1

    self.weapon = Weapons.Laser:new(self)

    return self
end

--Mimics Multilevel Priority Queue, only process input one every 6 frames on average
--TODO make this delay dynamic as one the game dips below 10 FPS
--It becomes overhead That does nothing

function Shooter:update(dt)
    self.procces_current_time = self.procces_current_time + dt
    if self.procces_current_time >= self.procces_delay then
        self:process(self.procces_current_time)
        self.procces_current_time = 0
    end
    Ship.update(self, dt)
end

function  Shooter:process(dt)

    self.strafe_timer = self.strafe_timer - dt
    --Strafing Behavior
    if self.strafe_timer <= 0 then
        self.strafe_timer =
            love.math.random() *
            (self.strafe_max_time - self.strafe_min_time)
            + self.strafe_min_time

        self.strafe_direction = -self.strafe_direction
    end

    local dx = self.player.x - self.x
    local dy = self.player.y - self.y

    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0 then

        local dir_x = dx / distance
        local dir_y = dy / distance

        self.angle = math.atan2(dy, dx)


        local strafe_x = -dir_y * self.strafe_direction
        local strafe_y = dir_x * self.strafe_direction

        local move_x = 0
        local move_y = 0
        -- If the player is too far get closer
        if distance > self.range then

            move_x = dir_x
            move_y = dir_y

        -- If the Player is too close run away
        elseif distance < self.kite_distance then

            move_x = (-dir_x * 1.25) + strafe_x
            move_y = (-dir_y * 1.25) + strafe_y
            if self.player.health > 0 then
                self:attack(
                    self.player.x,
                    self.player.y,
                    self.angle
                )
            end
        -- Else strafe and shoot
        else

            move_x = strafe_x
            move_y = strafe_y
            if self.player.health > 0 then
                self:attack(
                    self.player.x,
                    self.player.y,
                    self.angle
                )
            end

        end

        local move_length = math.sqrt(
            move_x * move_x +
            move_y * move_y
        )

        if move_length > 0 then
            move_x = move_x / move_length
            move_y = move_y / move_length
        end

        self.move_x = move_x
        self.move_y = move_y

    else
        self.move_x = 0
        self.move_y = 0
    end
end

function Shooter:draw()
    Ship.draw(self)
end

Enemies.Shooter = Shooter
return Enemies
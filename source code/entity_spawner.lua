--[[Dynamic entity spawner module, Handcoded aside for the Placement location logic which
was created with the help of AI assitance increaces with size over time, at set times
]]

local EnemySpawner = {}
EnemySpawner.__index = EnemySpawner

local Enemies = require("enemies")
function EnemySpawner:new(player, bounds)
    local self = setmetatable({}, EnemySpawner)

    self.player = player
    self.bounds = bounds
    self.wave = 0
    self.wave_timer = 10
    self.wave_interval = 10

    self.base_wave_size = 3
    self.wave_growth = 1

    self.spawn_distance = 800

    return self
end

function EnemySpawner:update(dt)

    self.wave_timer = self.wave_timer - dt

    if self.wave_timer <= 0 then
        self:start_wave()
        self.wave_timer = self.wave_interval
    end
end


function EnemySpawner:start_wave()

    self.wave = self.wave + 1

    local enemy_count =
        self.base_wave_size +
        ((self.wave - 1) * self.wave_growth)

    for enemy_index = 1, enemy_count do
        --Spawns at a set distance from a given angle vector from the player
        local angle = love.math.random() * math.pi * 2

        local spawn_x =
            self.player.x +
            math.cos(angle) * self.spawn_distance

        local spawn_y =
            self.player.y +
            math.sin(angle) * self.spawn_distance

        local enemy = Enemies.Shooter:new(
            spawn_x,
            spawn_y,
            self.player
        )
        --Check if within bounds this might be the worst way the AI could have implemented this but no time to handcode better logic
        local margin = enemy.hitbox_size or enemy.size or 0
        spawn_x = math.max(self.bounds.min_x + margin, math.min(self.bounds.max_x - margin, spawn_x))
        spawn_y = math.max(self.bounds.min_y + margin, math.min(self.bounds.max_y - margin, spawn_y))

        enemy.x = spawn_x
        enemy.y = spawn_y
        enemy.pos.x = spawn_x
        enemy.pos.y = spawn_y
        

        entities_pool:register(enemy)
    end
    if debug_print == 1 then
        print(
            string.format(
                "Wave %d spawned %d enemies",
                self.wave,
                enemy_count
            )
        )
    end
end

return EnemySpawner
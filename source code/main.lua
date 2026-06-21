--[[
Kyle Dellock -- This whole project came from the idea of making the AI more fun and dynamic
in the Game vampire survivors, but as I was developing, I grew to like the abstract space like
astetic and decided to make the game also have physics and weight to them to make it feel like
a space-ship dogfighting type game with the core still vampire survivors, 
and while its far from complete, I belive the game is ratherfun and I am happy where with it ended off 

--Note to meet the deadlines I have employed the use of LMM's to small parts of the implemntation
The overall design, architecture, and file structure, and the majority of the code is written by me
I have disclamed where AI has assisted or fully wrote a function, all of these AI functions have been
analysed, thourly tested and or modified by me however as it seriously struggles with optamization and
overall archetcture.
]]

--Debug globals
debug_rects = 0
god_mode = 0
debug_print = 0

local game_canvas
local wall_size
local scale

local Player = require("player")
local Enemies = require("enemies")
local Camera = require("camera")
local Walls = require("walls")
local Collision = require("collision_handler")
local PooledManager = require("pooled_manager")
local EntitySpawner = require("entity_spawner")
local nebula_shader = love.graphics.newShader("nebula.glsl")

entities_pool = PooledManager.new(0)
projectiles_pool = PooledManager.new(0.05)

local enemy_pool
local player
local camera
local Spawner

--Mesh for shader vertex target
local unit_mesh = love.graphics.newMesh({
    {0, 0, 0, 0}, -- Top Left
    {1, 0, 1, 0}, -- Top Right
    {1, 1, 1, 1}, -- Bottom Right
    {0, 1, 0, 1}  -- Bottom Left
}, "fan", "static")

--Shared Globals
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
score = 0

function love.load()
    love.window.setMode(
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        {
            vsync = true,
            fullscreen = false
        }
    )

    love.window.setTitle("Light Fight")

    --[[
        rather than displaying anything to the window directly a trick I 
        learned in pixel art games is to display to a canvas that scales to the size 
        of the screen, this allow for easy resolution scaling and different aspect ration support
    ]]
    game_canvas = {
        x = 800,
        y = 450,
    }
    game_canvas.screen = love.graphics.newCanvas(game_canvas.x, game_canvas.y)

    --border wall params
    wall_size = {
        x = 1900,
        y = 1200,
        buffer = 50,
        color = {0, 0, 1, 1},
        thickness = 5
    }
    --scaling factor from canvas to window
    scale = {
        x = love.graphics.getWidth() / game_canvas.x,
        y = love.graphics.getHeight() / game_canvas.y
    }

    player = Player:new(100, 100)

    entity_spawner = EntitySpawner:new(player, {
        min_x = wall_size.buffer,
        max_x = wall_size.x - wall_size.buffer,
        min_y = wall_size.buffer,
        max_y = wall_size.y - wall_size.buffer
    })
    entities_pool:register(player)

    entities_pool:register(Walls:new(
        {x = wall_size.buffer, y = wall_size.buffer},
        {x = wall_size.x - wall_size.buffer, y = wall_size.buffer},
        {0, 0, 1, 1},
        wall_size.thickness
    ))

    entities_pool:register(Walls:new(
        {x = wall_size.buffer, y = wall_size.y - wall_size.buffer},
        {x = wall_size.x - wall_size.buffer, y = wall_size.y - wall_size.buffer},
        {0, 0, 1, 1},
        wall_size.thickness
    ))

    entities_pool:register(Walls:new(
        {x = wall_size.buffer, y = wall_size.buffer},
        {x = wall_size.buffer, y = wall_size.y - wall_size.buffer},
        {0, 0, 1, 1},
        wall_size.thickness
    ))

    entities_pool:register(Walls:new(
        {x = wall_size.x - wall_size.buffer, y = wall_size.buffer},
        {x = wall_size.x - wall_size.buffer, y = wall_size.y - wall_size.buffer},
        {0, 0, 1, 1},
        wall_size.thickness
    ))
    -- starting enemies
    for i = 1, 5 do
        entities_pool:register(Enemies.Shooter:new((i * 100) + 500, (i * 50) + 500, player))
    end

    camera = Camera:new(
        player.x,
        player.y,
        game_canvas.x,
        game_canvas.y,
        scale
    )

    player.camera = camera -- lock camera on player
    love.graphics.setBackgroundColor(0, 0, .05)
    spawner = EntitySpawner:new(player)
end

function love.update(dt)
    --Debug values
    local entity_amount = 0
    local projectile_amount = 0

    --process entities
    for entity in entities_pool:each() do
        entity_amount = entity_amount + 1
        if entity then
            entity:update(dt)
            if entity.velocity then
              Collision.swept_move(entity, dt, entities_pool)
            end
        end
    end

    --process projectiles
    for projectile in projectiles_pool:each() do
        projectile_amount = projectile_amount + 1
        if projectile then
            projectile:update(dt)
            if projectile then
                Collision.swept_move(projectile, dt, entities_pool) --NOTE porjectiles do not collide with other projectiles for preformance right now
            end
        end
    end
    if debug_print == 1 then
        print(string.format("DT = %.3f  Entity Amount = %d  Projectile Amount = %d",
        dt, entity_amount, projectile_amount))
    end
    if player.health > 0 then -- if player is alive
        entity_spawner:update(dt) 
    end
    camera:update(dt, player)
end

function love.draw()
    love.graphics.setCanvas(game_canvas.screen)
    love.graphics.clear()

    nebula_shader:send("time", love.timer.getTime())
    nebula_shader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
    nebula_shader:send("player_position", {player.x, player.y})

    love.graphics.setShader(nebula_shader) -- starry background shader
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()

    camera:attach()

    for entity in entities_pool:each() do
        if entity then
            entity:draw(dt)
        end
    end

    for projectile in projectiles_pool:each() do
        if projectile then
            projectile:draw(dt)
        end
    end

    if player.health <= 0 then --print does not take relative camera into account for some reason, "magic numbers" used for position lack of time
        love.graphics.print('Game Over!', player.x - 32, player.y - 5)
        love.graphics.print('Score =', player.x - 32, player.y + 20)
        love.graphics.print(score, player.x + 24, player.y + 20)
    end

    camera:detach()

    love.graphics.setCanvas()
    love.graphics.draw(
        game_canvas.screen,
        0,
        0,
        0,
        scale.x,
        scale.y
    )
end
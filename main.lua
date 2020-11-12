-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

WIN_Width = 1280
WIN_Height = 720

VIR_Width = 432
VIR_Height = 242

PAD_Speed = 275

function love.load()
     -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')
    -- Title of our game
    love.window.setTitle('Lario vs Muigi Pong Battle')
    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    -- more "retro-looking" font object we can use for any text
    s_Font = love.graphics.newFont('font.ttf', 8)
    L_Font = love.graphics.newFont('font.ttf', 16)
    SCORE_Font = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(s_Font)

    -- initialize window with virtual resolution
    push:setupScreen(VIR_Width, VIR_Height, WIN_Width, WIN_Height, {
        fullscrn  = false,
        resizable = true,
        V_sync    = true, 
        canvas    = false
    })

    -- paddle positions on the Y axis (they can only move up or down)
    Player_1.y = VIR_Height / 2 - 12
    Player_2.y = VIR_Height / 2 - 12

    -- velocity and position variables for our ball when play starts
    Fong_Ball.x = VIRTUAL_WIDTH / 2 - 5
    Fong_Ball.y = VIRTUAL_HEIGHT / 2 - 5

    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)

    -- game state variable used to transition between different parts of the game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    gameState = 'start'
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    -- player 1 movement
    if love.keyboard.isDown('w') then
        Player_1.y = math.max(0, Player1.y + -PAD_Speed * dt)
    elseif love.keyboard.isDown('s') then       
        Player1.y = math.min(VIR_Height - 20, Player_1.y + PAD_Speed * dt)
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2Y = math.max(0, Player_2.y + -PAD_Speed * dt)
    elseif love.keyboard.isDown('down') then
        player2Y = math.min(VIR_Height - 20, Player_2.y + PAD_Speed * dt)
    end

    
    if gameState == 'play' then
        Fong_Ball.x = VIRTUAL_WIDTH / 2 - 5 * dt
        Fong_Ball.y = VIRTUAL_HEIGHT / 2 - 5 * dt
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'
            
            Fong_Ball.x = VIRTUAL_WIDTH / 2 - 5
            Fong_Ball.y = VIRTUAL_HEIGHT / 2 - 5

            ballDX = math.random(2) == 1 and 100 or -100
            ballDY = math.random(-50, 50) * 1.5
        end
    end
end

function love.draw()
    
    push:apply('start')

    love.graphics.clear(40, 45, 52, 255)


    love.graphics.setFont(s_Font)

    if gameState == 'start' then
        love.graphics.printf('Hello Start State!', 0, 20, VIR_Width, 'center')
    else
        love.graphics.printf('Hello Play State!', 0, 20, VIR_Width, 'center')
    end

    -- render first paddle (left side), now using the players' Y variable
    love.graphics.rectangle('fill', 10, Player_1.y, 10, 24)

    -- render second paddle (right side)
    love.graphics.rectangle('fill', VIR_Width - 10, Player_2.y, 10, 24)

    -- render ball (center)
    love.graphics.rectangle('fill', Fong_Ball.x, Fong_Ball.y, 10, 10)

    -- end rendering at virtual resolution
    push:apply('end')
end

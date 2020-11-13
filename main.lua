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

    Player_1_Score = 0
    Player_2_Score = 0

    Player_1       = Paddle_1(10, VIR_Height / 2 - 12, 10, 24)
    Player_2       = Paddle_2(VIR_Width - 20, VIR_Height / 2 - 12, 10, 24)

    Fong_Ball      = Box(VIR_Width / 2 - 5, VIR_Height / 2 - 5, 10, 10)

    Game_State     = 'start'
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    if Game_State == 'play' then
        if Fong_Ball:collides(Player_1) then
            Fong_Ball.dx = -Fong_Ball.dx * 1.07 
            Fong_Ball.x  = Player_1.x + 10 

            if Fong_Ball.dy < 0 then
                Fong_Ball.dy = -math.random(10, 150)
            else
                Fong_Ball.dy = math.random(10, 150)
            end
        end

        if Fong_Ball:collides(Player_2) then
            Fong_Ball.dx = -Fong_Ball.dx * 1.07 
            Fong_Ball.x  = Player_2.x - 10

            if Fong_Ball.dy < 0 then
                Fong_Ball.dy = -math.random(10, 150)
            else
                Fong_Ball.dy = math.random(10, 150)
            end
        end

        if Fong_Ball.y <= 0 then
            Fong_Ball.y  = 0
            Fong_Ball.dy = -Fong_Ball.dy
        end

        if Fong_Ball.y >= VIR_Height - 30 then
            Fong_Ball.y  = VIR_Height - 30
            Fong_Ball.dy = -Fong_Ball.dy
        end
        
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1

            -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    
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
       Box:update()
    end

    Player_1:update()
    Player_2:update()
    
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'
            
            Fong_Ball:reset()
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
    --display score
    love.graphics.setFont(SCORE_Font)
    love.graphics.print(tostring(Player_1_Score), VIR_Width / 2 - 50, 
        VIR_Height - 53)
    love.graphics.print(tostring(Player_2_Score), VIR_Width / 2 + 30,
        VIR_Height - 53)
    -- render first paddle (left side), now using the players' Y variable

    Player_1:render()
    
    Player_2:render()

    Fong_Ball:render()

    displayFPS()

    -- end rendering at virtual resolution
    push:apply('end')
end

function displayFPS()

    love.graphics.setFont(s_Font)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), VIR_Width - 55, 10)
    love.graphics.setColor(255/255, 255/244, 255/255, 255/255)
    
end
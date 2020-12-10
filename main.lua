--[[
    GD50 2018
    Pong Remake

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

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

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- initialize score variables
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = 1

    -- player who won the game; not set to a proper value until we reach
    -- that state in the game
    winningPlayer = 0

    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
    -- 5. 'menu' (state where the player can choose game mode)
    gameState = 'menu'

    -- game mode options; can be any of the following:
    -- 1. 'pvp' (player vs player)
    -- 2. 'pvc' (player vs computer)
    -- 3. 'cvc' (computer vs computer)
    gameMode = ' '
end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example. In this case, we only need to worry
    about calling out to `push` to handle the resizing. Takes in a `w` and
    `h` variable representing width and height, respectively.
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    Called every frame, passing in `dt` since the last frame. `dt`
    is short for `deltaTime` and is measured in seconds. Multiplying
    this by any changes we wish to make in our game will allow our
    game to perform consistently across all hardware; otherwise, any
    changes we make will be applied as fast as possible and will vary
    across system hardware.
]]
function love.update(dt)
    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        if gameMode == 'pvp' then
            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
        -- pvc game mode
        elseif gameMode == 'pvc' then
            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
        -- cvc game mode
        elseif gameMode == 'cvc' then
            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
            -- to continously play
            gameState = 'play'
        end
    elseif gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position
        -- at which it collided, then playing a sound effect
        if gameMode == 'pvp' then
            if ball:collides(player1) then
                ball.dx = -ball.dx * 1.05
                ball.x = player1.x + 5

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end

                sounds['paddle_hit']:play()
            end
            if ball:collides(player2) then
                ball.dx = -ball.dx * 1.05
                ball.x = player2.x - 4

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end

                sounds['paddle_hit']:play()
            end
        -- 2nd paddle will be the ai
        elseif gameMode == 'pvc' then
            if ball:collides(player1) then
                ball.dx = -ball.dx * 1.05
                ball.x = player1.x + 5

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end

                sounds['paddle_hit']:play()
            end
            if ball:collides(player2) then
                ball.dx = -ball.dx * 1.05
                ball.x = player2.x - 4

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end

                sounds['paddle_hit']:play()
            end

        elseif gameMode == 'cvc' then
            -- faster increase in ball's speed when collide
            if ball:collides(player1) then
                ball.dx = -ball.dx * 1.1
                ball.x = player1.x + 5

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end
                 -- to continously play
                gameState = 'play'
                sounds['paddle_hit']:play()
            end
            if ball:collides(player2) then
                ball.dx = -ball.dx * 1.1
                ball.x = player2.x - 4

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end
                 -- to continously play
                gameState = 'play'
                sounds['paddle_hit']:play()
            end
        end
        -- detect upper and lower screen boundary collision, playing a sound
        -- effect and reversing dy if true
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- if we reach the left edge of the screen, go back to serve
        -- and update the score and serving player
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

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

        -- if we reach the right edge of the screen, go back to serve
        -- and update the score and serving player
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end
    end

    --
    -- paddles can move no matter what state we're in
    --
    if gameMode == 'pvp' then
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    -- padlle2 will be the ai
    elseif gameMode == 'pvc' then
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        -- player 2
        if player2.y > ball.y + ball.height  then
            player2.dy = -(PADDLE_SPEED - 85)
        elseif player2.y + player2.height < ball.y + ball.height  then
            player2.dy = PADDLE_SPEED - 85
        else
           player2.dy = 0
        end
    -- both paddle is ai
    elseif gameMode == 'cvc' then
        -- faster paddle speed
        -- random so that both ai can score
        if player1.y > ball.y + ball.height  then
            player1.dy = -(PADDLE_SPEED - 80)
         elseif player1.y + player1.height < ball.y + ball.height  then
            player1.dy = AIPADDLE_SPEED - 80
         else
            player1.dy = 0
         end

        -- player2 is ai 
        if player2.y > ball.y + ball.height  then
            player2dy = -(PADDLE_SPEED - 80)
        elseif player2.y + player2.height < ball.y + ball.height  then
            player2. = PADDLE_SPEED - 80
        else
           player2.dy = 0
        end
    end
    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    -- `key` will be whatever key this callback detected as pressed
    if key == 'escape' then
        if gameState == 'menu' then
        -- the function LÖVE2D uses to quit the application
            love.event.quit()
        elseif gameState ~= 'menu' then
            gameState = 'menu'
            ball:reset()
            player1Score = 0
            player2Score = 0
            player1:reset1()
            player2:reset2()
        end
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == 'enter' or key == 'return' then
        if  (gameMode == 'cvc') or (gameMode == 'pvp') or (gameMode == 'pvc') then
            if gameState == 'start' then
                gameState = 'serve'

                -- decide serving player as the opposite of who won
                if winningPlayer == 1 then
                    servingPlayer = 2
                else
                    servingPlayer = 1
                end

            elseif gameState == 'serve' then
                gameState = 'play'
            elseif gameState == 'done' then
                -- go back to menu to choose mode and play again
                gameState = 'menu'

                ball:reset()
                player1Score = 0
                player2Score = 0
                player1:reset1()
                player2:reset2()
            end
        end
    end

    if gameState == 'menu' then
        if key == '1' then
            gameMode = 'pvp'
            gameState = 'start'
        elseif key == '2' then
            gameMode = 'pvc'
            gameState = 'start'
        elseif key == '3' then
            gameMode = 'cvc'
            gameState = 'start'
        end
    end
end

--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
    -- begin drawing with push, in our virtual resolution
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 1)
    
    -- render different things depending on which part of the game we're in
    if gameState == 'menu' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Welcome to Pong! \n Choose game mode!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. Player vs. Player', 0, 60, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('2. Player vs. Computer', 0, 70, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('3. Computer vs. Computer', 0, 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press esc to exit', 0, 10, VIRTUAL_WIDTH - 10, 'right')
    elseif gameState == 'start' then
        -- UI messages
        if gameMode == 'pvp' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('You choose Player vs Player game mode.', 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
        elseif gameMode == 'pvc' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('You choose Player vs Computer game mode. \n You will play the left paddle!', 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to begin!', 0, 30, VIRTUAL_WIDTH, 'center')
        elseif gameMode == 'cvc' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('You choose Computer vs Computer game mode.', 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to begin watching!', 0, 20, VIRTUAL_WIDTH, 'center')
        end
    elseif gameState == 'serve' then
        -- UI messages
        if gameMode == 'pvp' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
                0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
        elseif gameMode == 'pvc' then
            if servingPlayer == 1 then
                love.graphics.setFont(smallFont)
                love.graphics.printf('You are going to serve!', 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
            elseif servingPlayer == 2 then
                love.graphics.setFont(smallFont)
                love.graphics.printf("Computer's serve!", 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.printf('Press Enter to start', 0, 20, VIRTUAL_WIDTH, 'center')
            end
        elseif gameMode == 'cvc' then
            -- no ui
            -- game continuosly play
        end
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        if gameMode == 'pvp' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
                0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
        elseif gameMode == 'pvc' then
            if winningPlayer == 1 then
                love.graphics.setFont(largeFont)
                love.graphics.printf('You win!', 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.setFont(smallFont)
                love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
            elseif winningPlayer == 2 then
                love.graphics.setFont(largeFont)
                love.graphics.printf('Computer wins!', 0, 10, VIRTUAL_WIDTH, 'center')
                love.graphics.setFont(smallFont)
                love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
            end
        elseif gameMode == 'cvc' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('Game done!', 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Computer wins!', 0, 20, VIRTUAL_WIDTH, 'center')
        end
    end

    -- show the score before ball is rendered so it can move over the text
    if gameState ~= 'menu' then
        displayScore()
        
        player1:render()
        player2:render()
        ball:render()
    end
    -- display FPS for debugging; simply comment out to remove
    displayFPS()

    -- end our drawing to push
    push:apply('end')
end

--[[
    Simple function for rendering the scores.
]]
function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

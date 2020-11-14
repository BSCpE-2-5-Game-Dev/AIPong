push = require 'push'
Class = require 'class'
require 'Paddle_1'
require 'Paddle_2'
require 'Background'
require 'Box'

WIN_Width  = 1280
WIN_Height = 680
VIR_Width  = 432
VIR_Height = 242
PAD_Speed  = 275

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Rio and Lui Pong')
    math.randomseed(os.time())

    s_Font = love.graphics.newFont('font.ttf', 8)
    L_Font = love.graphics.newFont('font.ttf', 16)
    SCORE_Font = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(s_Font)

    sounds = {
        ['paddleHit'] = love.audio.newSource('sounds/paddleHit.wav', 'static'),
        ['scoreHit']  = love.audio.newSource('sounds/scoreHit.wav', 'static'),
        ['wallHit']   = love.audio.newSource('sounds/wallHit.wav', 'static'),
        ['victory']   = love.audio.newSource('sounds/victory.wav', 'static')
    }

    push:setupScreen(VIR_Width, VIR_Height, WIN_Width, WIN_Height, {
        fullscrn  = false,
        resizable = true,
        V_sync    = true,
        canvas    = false
    })
    Background:init()
    Player_1_Score = 0
    Player_2_Score = 0
    Player_Server  = 1
    Player_Winner  = 0
    Player_1       = Paddle_1(10, VIR_Height / 2 - 12, 10, 24)
    Player_2       = Paddle_2(VIR_Width - 20, VIR_Height / 2 - 12, 10, 24)
    Fong_Ball      = Box(VIR_Width / 2 - 5, VIR_Height / 2 - 5, 10, 10)
    Game_State     = 'start'

end

function love.resize(w, h)

    push:resize(w, h)

end


function love.update(dt)

    if Game_State == 'serve' then
        Fong_Ball.dy = math.random(-50, 50)
        if Player_Server == 1 then
            Fong_Ball.dx = math.random(140, 200)
        else
            Fong_Ball.dx = -math.random(140, 200)
        end

    elseif Game_State == 'play' then
        if Fong_Ball:collides(Player_1) then
            Fong_Ball.dx = -Fong_Ball.dx * 1.07
            Fong_Ball.x  = Player_1.x + 10

            if Fong_Ball.dy < 0 then
                Fong_Ball.dy = -math.random(10, 150)
            else
                Fong_Ball.dy = math.random(10, 150)
            end
            sounds['paddleHit']:play()
        end

        if Fong_Ball:collides(Player_2) then
            Fong_Ball.dx = -Fong_Ball.dx * 1.07
            Fong_Ball.x  = Player_2.x - 10

            if Fong_Ball.dy < 0 then
                Fong_Ball.dy = -math.random(10, 150)
            else
                Fong_Ball.dy = math.random(10, 150)
            end
            sounds['paddleHit']:play()
        end

        if Fong_Ball.y <= 0 then
            Fong_Ball.y  = 0
            Fong_Ball.dy = -Fong_Ball.dy
            sounds['wallHit']:play()
        end

        if Fong_Ball.y >= VIR_Height - 30 then
            Fong_Ball.y  = VIR_Height - 30
            Fong_Ball.dy = -Fong_Ball.dy
            sounds['wallHit']:play()
        end

        if Fong_Ball.x < 0 then
            Player_Server  = 1
            Player_2_Score = Player_2_Score + 1
            sounds['scoreHit']:play()

            if Player_2_Score == 10 then
                Player_Winner  = 2
                Game_State = 'done'
                sounds['victory']:play()
            else
                Game_State = 'serve'
                Fong_Ball:reset()
            end
        end

        if Fong_Ball.x > VIR_Width then
            Player_Server  = 2
            Player_1_Score = Player_1_Score + 1
            sounds['scoreHit']:play()

            if Player_1_Score == 10 then
                Player_Winner  = 1
                Game_State = 'done'
                sounds['victory']:play()
            else
                Game_State = 'serve'
                Fong_Ball:reset()
            end
        end

    end

    if love.keyboard.isDown('w') then
        Player_1.dy = -PAD_Speed
    elseif love.keyboard.isDown('s') then
        Player_1.dy = PAD_Speed
        if Player_1.y >= VIR_Height - 50 then
            Player_1.y  = VIR_Height - 50
        end
    else
        Player_1.dy = 0
    end

    if love.keyboard.isDown('up') then
        Player_2.dy = -PAD_Speed
    elseif love.keyboard.isDown('down') then
        Player_2.dy = PAD_Speed
        if Player_2.y >= VIR_Height - 50 then
            Player_2.y  = VIR_Height - 50
        end
    else
        Player_2.dy = 0
    end

    if Game_State == 'play' then
        Fong_Ball:update(dt)
    end

    Player_1:update(dt)
    Player_2:update(dt)

end

function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if Game_State == 'start' then
            Game_State = 'serve'
        elseif Game_State == 'serve' then
            Game_State = 'play'
        elseif Game_State == 'done' then
            Game_State = 'serve'

            Fong_Ball:reset()

            Player_1_Score = 0
            Player_2_Score = 0

            if Player_Winner == 1 then
                Player_Server = 2
            else
                Player_Server = 1
            end
        end
    end

end

function love.draw()

    push:apply('start')
    Background:render()


    if Game_State == 'start' then
        love.graphics.setFont(s_Font)
        love.graphics.printf('Welcome to Rio and Lui Pong!', 0, 95, VIR_Width, 'center')
        love.graphics.printf('Press ENTER to Begin!', 0, 140, VIR_Width, 'center')
    elseif Game_State == 'serve' then
        love.graphics.setFont(s_Font)
        love.graphics.printf('Player ' .. tostring(Player_Server) .. "'s Serve!",
            0, 90, VIR_Width, 'center')
        love.graphics.printf('Press ENTER to Serve!', 0, 140, VIR_Width, 'center')
    elseif Game_State == 'play' then
    elseif Game_State == 'done' then
        love.graphics.setFont(L_Font)
        love.graphics.printf('Player ' .. tostring(Player_Winner) .. ' Wins!',
            0, 90, VIR_Width, 'center')
        love.graphics.setFont(s_Font)
        love.graphics.printf('Press ENTER to Restart!', 0, 140, VIR_Width, 'center')
    end

    displayScore()

    Player_1:render()
    Player_2:render()
    Fong_Ball:render()

    displayFPS()

    push:finish()

end


function displayScore()

    love.graphics.setFont(SCORE_Font)
    love.graphics.print(tostring(Player_1_Score), VIR_Width / 2 - 50,
        VIR_Height - 53)
    love.graphics.print(tostring(Player_2_Score), VIR_Width / 2 + 30,
        VIR_Height - 53)

end

function displayFPS()

    love.graphics.setFont(s_Font)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), VIR_Width - 55, 10)
    love.graphics.setColor(255/255, 255/244, 255/255, 255/255)
end

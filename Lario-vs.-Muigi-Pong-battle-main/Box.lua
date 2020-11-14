Box = Class{}

function Box:init(x, y, width, height)
  self.x = x
  self.y = y
  self.img = love.graphics.newImage('assets/Ball.png')
  self.width = self.img:getWidth()
  self.height = self.img:getHeight()
  self.dy = 0
  self.dx = 0
end

function Box:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    return true
end

function Box:reset()
    self.x = VIR_Width / 2 - 10
    self.y = VIR_Height / 2 - 10
    self.dx = 0
    self.dy = 0
end

function Box:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Box:render()
    love.graphics.draw(self.img, self.x, self.y)
end

Paddle_1= Class{}

function Paddle_1:init(x, y, width, height)

  self.x = x
  self.y = y
  self.img = love.graphics.newImage('assets/Mario.png')
  self.width = self.img:getWidth()
  self.height = self.img:getHeight()
  self.dy = 0

end

function Paddle_1:update(dt)

    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)

    else
        self.y = math.min(VIR_Height - self.height, self.y + self.dy * dt)
    end

end

function Paddle_1:render()

    love.graphics.draw(self.img, self.x, self.y)

end

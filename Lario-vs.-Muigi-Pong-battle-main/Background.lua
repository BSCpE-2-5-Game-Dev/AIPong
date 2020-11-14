Background = Class{}

function Background:init()
    self.x = 0
    self.y = 0
    self.img = love.graphics.newImage('assets/backgroundPixel.png')
    self.width = self.img:getWidth()
    self.height = self.img:getHeight()
    
end

function Background:update(dt)
    
end

function Background:render()
    love.graphics.draw(self.img, self.x, self.y)
end

Player = Class {}

function Player:init(x, y)
    self.scale = 0.3
    self.initial_x = x
    self.x = x
    self.initial_y = y
    self.y = y
    self.width, self.height = Sprites.getDimensions()
    self.width = self.width * self.scale
    self.height = self.height * self.scale
    self.dx = 0
end

function Player:update(dt)
    if self.dx < 0 then
        self.x = math.max(self.width / 2, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width / 2, self.x + self.dx * dt)
    end
end

function Player:reset()
    self.x = self.initial_x
    self.y = self.initial_y
    self.dx = 0
end

function Player:render()
    love.graphics.setColor(1, 0.263, 0.212, 1)
    Sprites.draw(Sprites.R3C5, self.x - (self.width) / 2,
        self.y - 10 - (self.height) / 2, self.scale)
end

return Player

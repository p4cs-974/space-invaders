Player = Class {}

function Player:init(x, y)
    self.initialX = x
    self.initialY = y
    self.x = x
    self.y = y
    self.dx = 0

    self.scale = PLAYER_SCALE
    local spriteWidth, spriteHeight = Sprites.getDimensions()
    self.width = spriteWidth * self.scale
    self.height = spriteHeight * self.scale
end

function Player:update(dt)
    self.x = self.x + self.dx * dt
    self.x = math.max(self.width / 2, self.x)
    self.x = math.min(VIRTUAL_WIDTH - self.width / 2, self.x)
end

function Player:resetPosition()
    self.x = self.initialX
    self.y = self.initialY
    self.dx = 0
end

function Player:getDrawX()
    return self.x - self.width / 2
end

function Player:getDrawY()
    return self.y - self.height / 2
end

function Player:getTopY()
    local _, y = self:getCollisionRect()
    return y
end

function Player:getCollisionRect()
    local x = self:getDrawX() + self.width * 0.2
    local y = self:getDrawY() + self.height * 0.34
    local w = self.width * 0.6
    local h = self.height * 0.45
    return x, y, w, h
end

function Player:getGunPosition()
    local x, y, w = self:getCollisionRect()
    return x + w / 2, y
end

function Player:render(alpha)
    local drawAlpha = alpha or 1
    love.graphics.setColor(1, 0.27, 0.22, drawAlpha)
    Sprites.draw(Sprites.R3C5, self:getDrawX(), self:getDrawY(), self.scale)
    love.graphics.setColor(1, 1, 1, 1)
end

function Player:drawBoundingBox()
    local x, y, w, h = self:getCollisionRect()
    love.graphics.rectangle('line', x, y, w, h)
end

return Player

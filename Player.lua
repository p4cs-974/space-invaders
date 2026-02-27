Player = Class {}

function Player:init(x, y)
    self.initial_x = x
    self.x = x
    self.initial_y = y
    self.y = y
    self.width, self.height = Sprites.getDimensions()
    self.width = self.width * SPRITE_SCALE
    self.height = self.height * SPRITE_SCALE
    self.dx = 0

    -- Opaque pixel bounds for R3C5 inside the 110x127 tile.
    self.hitOffsetX = 24
    self.hitOffsetY = 33
    self.hitWidth = 64
    self.hitHeight = 46
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
    Sprites.draw(Sprites.R3C5, self:getDrawX(),
        self:getDrawY(), SPRITE_SCALE)
end

function Player:getDrawX()
    return self.x - self.width / 2
end

function Player:getDrawY()
    return self.y - 10 - self.height / 2
end

function Player:getTopY()
    return self:getDrawY()
end

function Player:getCollisionRect()
    local x = self:getDrawX() + self.hitOffsetX * SPRITE_SCALE
    local y = self:getDrawY() + self.hitOffsetY * SPRITE_SCALE
    local w = self.hitWidth * SPRITE_SCALE
    local h = self.hitHeight * SPRITE_SCALE
    return x, y, w, h
end

function Player:drawBoundingBox()
    local x, y, w, h = self:getCollisionRect()
    love.graphics.rectangle('line', x, y, w, h)
end

return Player

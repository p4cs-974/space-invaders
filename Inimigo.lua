Inimigo = Class {}

function Inimigo:init(def)
    self.kind = def.kind or 'common'
    self.points = def.points or 10
    self.x = def.x or 0
    self.y = def.y or 0
    self.scale = def.scale or ENEMY_SCALE
    self.skins = def.skins or { Sprites.R1C2 }
    self.animInterval = def.animInterval or 0.35
    self.animTimer = 0
    self.spriteIndex = 1

    local spriteWidth, spriteHeight = Sprites.getDimensions()
    self.width = spriteWidth * self.scale
    self.height = spriteHeight * self.scale
end

function Inimigo:update(dt)
    self.animTimer = self.animTimer + dt
    if self.animTimer >= self.animInterval then
        self.animTimer = self.animTimer - self.animInterval
        self.spriteIndex = (self.spriteIndex % #self.skins) + 1
    end
end

function Inimigo:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Inimigo:getDrawX()
    return self.x - self.width / 2
end

function Inimigo:getDrawY()
    return self.y - self.height / 2
end

function Inimigo:getCollisionRect()
    local x = self:getDrawX() + self.width * 0.15
    local y = self:getDrawY() + self.height * 0.25
    local w = self.width * 0.7
    local h = self.height * 0.55
    return x, y, w, h
end

function Inimigo:getFormationRect()
    local x = self:getDrawX() + self.width * 0.28
    local y = self:getDrawY() + self.height * 0.25
    local w = self.width * 0.44
    local h = self.height * 0.55
    return x, y, w, h
end

function Inimigo:getBottomY()
    local _, y, _, h = self:getCollisionRect()
    return y + h
end

function Inimigo:render()
    if self.kind == 'boss' then
        love.graphics.setColor(1, 0.7, 0.2, 1)
    else
        love.graphics.setColor(0.5, 1, 0.5, 1)
    end

    Sprites.draw(self.skins[self.spriteIndex], self:getDrawX(), self:getDrawY(), self.scale)
    love.graphics.setColor(1, 1, 1, 1)
end

function Inimigo:drawBoundingBox()
    local x, y, w, h = self:getCollisionRect()
    love.graphics.rectangle('line', x, y, w, h)
end

return Inimigo

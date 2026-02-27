Shot = Class {}
local SHOT_HIT_OFFSET_X = 43
local SHOT_HIT_OFFSET_Y = 29
local SHOT_HIT_WIDTH = 26
local SHOT_HIT_HEIGHT = 45

function Shot:init(centerX, startY)
    self.speed = 220
    self.sprite = Sprites.R3C7

    self.width, self.height = Sprites.getDimensions()
    self.drawX = centerX - (self.width * SHOT_SCALE) / 2
    self.drawY = startY

    -- Opaque pixel bounds for R3C7 inside the 110x127 tile.
    self.hitOffsetX = SHOT_HIT_OFFSET_X
    self.hitOffsetY = SHOT_HIT_OFFSET_Y
    self.hitWidth = SHOT_HIT_WIDTH
    self.hitHeight = SHOT_HIT_HEIGHT

    self.remove = false
end

function Shot.getSpawnDrawYForTopCollision(topCollisionY)
    return topCollisionY - (SHOT_HIT_OFFSET_Y + SHOT_HIT_HEIGHT) * SHOT_SCALE
end

function Shot:update(dt)
    self.drawY = self.drawY - self.speed * dt

    if self.drawY + (self.height * SHOT_SCALE) < 0 then
        self.remove = true
    end
end

function Shot:getCollisionRect()
    local x = self.drawX + self.hitOffsetX * SHOT_SCALE
    local y = self.drawY + self.hitOffsetY * SHOT_SCALE
    local w = self.hitWidth * SHOT_SCALE
    local h = self.hitHeight * SHOT_SCALE
    return x, y, w, h
end

function Shot:render()
    love.graphics.setColor(1, 1, 1, 1)
    Sprites.draw(self.sprite, self.drawX, self.drawY, SHOT_SCALE)
end

function Shot:drawBoundingBox()
    local x, y, w, h = self:getCollisionRect()
    love.graphics.rectangle('line', x, y, w, h)
end

return Shot

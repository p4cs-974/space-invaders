Shot = Class {}

function Shot:init(centerX, startY, direction, speed, owner)
    self.direction = direction or -1
    self.speed = speed or 220
    self.owner = owner or 'player'
    self.scale = SHOT_SCALE
    self.remove = false
    self.impactDuration = 0.08
    self.impactTimer = 0
    self.inImpact = false

    self.width, self.height = Sprites.getDimensions()
    self.drawX = centerX - (self.width * self.scale) / 2
    self.drawY = startY

    -- Player and enemy shots share the same projectile sprite.
    self.sprite = Sprites.R3C7
end

function Shot:impact()
    if self.inImpact then
        return
    end

    self.inImpact = true
    self.impactTimer = self.impactDuration
    self.sprite = Sprites.R3C8
end

function Shot:update(dt)
    if self.inImpact then
        self.impactTimer = self.impactTimer - dt
        if self.impactTimer <= 0 then
            self.remove = true
        end
        return
    end

    self.drawY = self.drawY + self.direction * self.speed * dt

    if self.drawY + (self.height * self.scale) < 0 then
        self:impact()
    end
    if self.drawY > VIRTUAL_HEIGHT then
        self:impact()
    end
end

function Shot:canHit()
    return not self.inImpact
end

function Shot:getCollisionRect()
    local x = self.drawX + self.width * self.scale * 0.38
    local y = self.drawY + self.height * self.scale * 0.2
    local w = self.width * self.scale * 0.24
    local h = self.height * self.scale * 0.52
    return x, y, w, h
end

function Shot:render()
    love.graphics.setColor(1, 1, 1, 1)
    Sprites.draw(self.sprite, self.drawX, self.drawY, self.scale)
    love.graphics.setColor(1, 1, 1, 1)
end

function Shot:drawBoundingBox()
    local x, y, w, h = self:getCollisionRect()
    love.graphics.rectangle('line', x, y, w, h)
end

return Shot

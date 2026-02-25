Brick = Class {}

function Brick:init(x, y, width, height, color, hp, spriteRow, spriteCol)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.color = color
    self.alive = true
    self.hp = hp
    self.initialHP = hp
    -- Sprite coordinates (optional, for drawing with sprites)
    self.spriteRow = spriteRow
    self.spriteCol = spriteCol
end

function Brick:setHP(hp)
    self.hp = hp
    self.initialHP = hp
end

function Brick:setSprite(row, col)
    self.spriteRow = row
    self.spriteCol = col
end

function Brick:hit()
    self.hp = self.hp - 1
    if self.hp <= 0 then
        self.alive = false
    end
end

function Brick:render()
    if not self.alive then
        return
    end

    -- If we have sprite coordinates and sprites are loaded, draw the sprite
    if self.spriteRow and self.spriteCol and sprites and sprites.sheet then
        -- Calculate scale to fit the brick size
        local spriteW, spriteH = sprites.getDimensions()
        local scaleX = self.width / spriteW
        local scaleY = self.height / spriteH
        
        -- Calculate alpha based on current HP: decreases from 1.0 to 0.3 in initialHP steps
        local alpha = 0.3 + 0.7 * (self.hp / self.initialHP)
        
        -- Save current color and apply alpha
        local old_r, old_g, old_b, old_a = love.graphics.getColor()
        love.graphics.setColor(1, 1, 1, alpha)
        
        -- Draw the sprite
        sprites.drawByGrid(self.spriteRow, self.spriteCol, self.x, self.y, scaleX, scaleY)
        
        -- Restore color
        love.graphics.setColor(old_r, old_g, old_b, old_a)
    else
        -- Fallback to rectangle rendering
        local alpha = 0.3 + 0.7 * (self.hp / self.initialHP)
        local old_r, old_g, old_b, old_a = love.graphics.getColor()
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
        love.graphics.setColor(old_r, old_g, old_b, old_a)
    end
end

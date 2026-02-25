Row = Class {}

function Row:init(rowIndex, color, bricksPerRow, baseHP, spriteRow)
    self.index = rowIndex
    self.color = color
    self.bricks = {}

    local brickWidth = VIRTUAL_WIDTH / bricksPerRow - 2
    local brickHeight = 10
    local startX = 2
    local startY = 40 + (rowIndex - 1) * (brickHeight + 4)
    
    -- Default to using the rowIndex as the sprite row (1-3)
    -- Can be overridden by passing spriteRow parameter
    local sprRow = spriteRow or math.min(rowIndex, 3)

    for i = 1, bricksPerRow do
        local brickX = startX + (i - 1) * (brickWidth + 2)
        local brickY = startY
        local brick = Brick(brickX, brickY, brickWidth, brickHeight, color, baseHP)
        
        -- Assign a sprite based on position (cycles through columns 1-9)
        local sprCol = ((i - 1) % 9) + 1
        brick:setSprite(sprRow, sprCol)
        
        table.insert(self.bricks, brick)
    end
end

function Row:render()
    for _, brick in ipairs(self.bricks) do
        if brick.alive then
            brick:render()
        end
    end
end

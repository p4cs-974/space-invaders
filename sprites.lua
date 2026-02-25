--[[
    Sprites module for managing sprite sheets and quads

    Usage:
        local sprites = require 'sprites'
        sprites.load()

        -- Draw a specific sprite
        sprites.draw(sprites.ALIEN_1, x, y)

        -- Or draw by row/col
        sprites.drawByGrid(row, col, x, y)
]]

local sprites = {}

-- Sprite sheet configuration
local SPRITE_WIDTH = 110
local SPRITE_HEIGHT = 127
local COLUMNS = 9
local ROWS = 3

-- Named sprite constants (adjust based on your actual sprite layout)
sprites.SPRITE_1 = { row = 1, col = 1 }
sprites.SPRITE_2 = { row = 1, col = 2 }
sprites.SPRITE_3 = { row = 1, col = 3 }
sprites.SPRITE_4 = { row = 1, col = 4 }
sprites.SPRITE_5 = { row = 1, col = 5 }
sprites.SPRITE_6 = { row = 1, col = 6 }
sprites.SPRITE_7 = { row = 1, col = 7 }
sprites.SPRITE_8 = { row = 1, col = 8 }
sprites.SPRITE_9 = { row = 1, col = 9 }

sprites.SPRITE_10 = { row = 2, col = 1 }
sprites.SPRITE_11 = { row = 2, col = 2 }
sprites.SPRITE_12 = { row = 2, col = 3 }
sprites.SPRITE_13 = { row = 2, col = 4 }
sprites.SPRITE_14 = { row = 2, col = 5 }
sprites.SPRITE_15 = { row = 2, col = 6 }
sprites.SPRITE_16 = { row = 2, col = 7 }
sprites.SPRITE_17 = { row = 2, col = 8 }
sprites.SPRITE_18 = { row = 2, col = 9 }

sprites.SPRITE_19 = { row = 3, col = 1 }
sprites.SPRITE_20 = { row = 3, col = 2 }
sprites.SPRITE_21 = { row = 3, col = 3 }
sprites.SPRITE_22 = { row = 3, col = 4 }
sprites.SPRITE_23 = { row = 3, col = 5 }
sprites.SPRITE_24 = { row = 3, col = 6 }
sprites.SPRITE_25 = { row = 3, col = 7 }
sprites.SPRITE_26 = { row = 3, col = 8 }
sprites.SPRITE_27 = { row = 3, col = 9 }

--[[
    Load the sprite sheet and create all quads
]]
function sprites.load()
    sprites.sheet = love.graphics.newImage('SpaceInvaders.png')
    sprites.sheet:setFilter('nearest', 'nearest') -- crisp pixels

    -- Store sheet dimensions
    local sheetWidth = sprites.sheet:getWidth()
    local sheetHeight = sprites.sheet:getHeight()

    -- Pre-create all quads in a 2D array
    sprites.quads = {}
    for row = 1, ROWS do
        sprites.quads[row] = {}
        for col = 1, COLUMNS do
            local x = (col - 1) * SPRITE_WIDTH
            local y = (row - 1) * SPRITE_HEIGHT
            sprites.quads[row][col] = love.graphics.newQuad(
                x, y,
                SPRITE_WIDTH, SPRITE_HEIGHT,
                sheetWidth, sheetHeight
            )
        end
    end

    -- Sprite dimensions (useful for positioning)
    sprites.width = SPRITE_WIDTH
    sprites.height = SPRITE_HEIGHT
end

--[[
    Get a quad for a specific row and column

    @param row - row number (1-3)
    @param col - column number (1-9)
    @return quad object
]]
function sprites.getQuad(row, col)
    if sprites.quads and sprites.quads[row] and sprites.quads[row][col] then
        return sprites.quads[row][col]
    end
    return nil
end

--[[
    Draw a sprite by row and column

    @param row - row number (1-3)
    @param col - column number (1-9)
    @param x - x position
    @param y - y position
    @param scaleX - optional x scale (default: 1)
    @param scaleY - optional y scale (default: scaleX or 1)
]]
function sprites.drawByGrid(row, col, x, y, scaleX, scaleY)
    scaleX = scaleX or 1
    scaleY = scaleY or scaleX

    local quad = sprites.getQuad(row, col)
    if quad then
        love.graphics.draw(sprites.sheet, quad, x, y, 0, scaleX, scaleY)
    end
end

--[[
    Draw a sprite using a named constant

    @param spriteDef - table with {row = n, col = m} (use sprites.ALIEN_X constants)
    @param x - x position
    @param y - y position
    @param scaleX - optional x scale (default: 1)
    @param scaleY - optional y scale (default: scaleX or 1)
]]
function sprites.draw(spriteDef, x, y, scaleX, scaleY)
    scaleX = scaleX or 1
    scaleY = scaleY or scaleX

    if spriteDef and spriteDef.row and spriteDef.col then
        sprites.drawByGrid(spriteDef.row, spriteDef.col, x, y, scaleX, scaleY)
    end
end

--[[
    Get the sprite dimensions

    @return width, height
]]
function sprites.getDimensions()
    return SPRITE_WIDTH, SPRITE_HEIGHT
end

return sprites

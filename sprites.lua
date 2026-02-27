--[[
    Sprites module for managing sprite sheets and quads

    Usage:
        local sprites = require 'Sprites'
        sprites.load()

        -- Draw a specific sprite
        sprites.draw(sprites.R1C1, x, y)

        -- Or draw by row/col
        sprites.drawByGrid(row, col, x, y)
]]

local Sprites = {}

-- Sprite sheet configuration
local SPRITE_WIDTH = 110
local SPRITE_HEIGHT = 127
local COLUMNS = 9
local ROWS = 3

-- Named sprite constants by grid position: R{row}C{col}
Sprites.R1C1 = { row = 1, col = 1 }
Sprites.R1C2 = { row = 1, col = 2 }
Sprites.R1C3 = { row = 1, col = 3 }
Sprites.R1C4 = { row = 1, col = 4 }
Sprites.R1C5 = { row = 1, col = 5 }
Sprites.R1C6 = { row = 1, col = 6 }
Sprites.R1C7 = { row = 1, col = 7 }
Sprites.R1C8 = { row = 1, col = 8 }
Sprites.R1C9 = { row = 1, col = 9 }

Sprites.R2C1 = { row = 2, col = 1 }
Sprites.R2C2 = { row = 2, col = 2 }
Sprites.R2C3 = { row = 2, col = 3 }
Sprites.R2C4 = { row = 2, col = 4 }
Sprites.R2C5 = { row = 2, col = 5 }
Sprites.R2C6 = { row = 2, col = 6 }
Sprites.R2C7 = { row = 2, col = 7 }
Sprites.R2C8 = { row = 2, col = 8 }
Sprites.R2C9 = { row = 2, col = 9 }

Sprites.R3C1 = { row = 3, col = 1 }
Sprites.R3C2 = { row = 3, col = 2 }
Sprites.R3C3 = { row = 3, col = 3 }
Sprites.R3C4 = { row = 3, col = 4 }
Sprites.R3C5 = { row = 3, col = 5 }
Sprites.R3C6 = { row = 3, col = 6 }
Sprites.R3C7 = { row = 3, col = 7 }
Sprites.R3C8 = { row = 3, col = 8 }
Sprites.R3C9 = { row = 3, col = 9 }

local skinsInimigo = {}

skinsInimigo.ENEMY_1 = { Sprites.R1C2, Sprites.R1C3 }
skinsInimigo.ENEMY_2 = { Sprites.R1C4, Sprites.R1C5 }
skinsInimigo.ENEMY_3 = { Sprites.R1C6, Sprites.R1C7 }
skinsInimigo.ENEMY_4 = { Sprites.R1C8, Sprites.R1C9 }
skinsInimigo.ENEMY_5 = { Sprites.R2C1, Sprites.R2C2 }
skinsInimigo.ENEMY_6 = { Sprites.R2C3, Sprites.R2C4 }
skinsInimigo.ENEMY_7 = { Sprites.R2C6, Sprites.R2C6 }
skinsInimigo.ENEMY_8 = { Sprites.R2C7, Sprites.R2C8 }
skinsInimigo.ENEMY_9 = { Sprites.R2C9, Sprites.R3C1 }
skinsInimigo.ENEMY_10 = { Sprites.R3C2, Sprites.R3C3 }

function Sprites.load()
    Sprites.sheet = love.graphics.newImage('SpaceInvaders.png')
    Sprites.sheet:setFilter('nearest', 'nearest') -- crisp pixels

    -- Store sheet dimensions
    local sheetWidth = Sprites.sheet:getWidth()
    local sheetHeight = Sprites.sheet:getHeight()

    -- Pre-create all quads in a 2D array
    Sprites.quads = {}
    for row = 1, ROWS do
        Sprites.quads[row] = {}
        for col = 1, COLUMNS do
            local x = (col - 1) * SPRITE_WIDTH
            local y = (row - 1) * SPRITE_HEIGHT
            Sprites.quads[row][col] = love.graphics.newQuad(
                x, y,
                SPRITE_WIDTH, SPRITE_HEIGHT,
                sheetWidth, sheetHeight
            )
        end
    end

    -- Sprite dimensions (useful for positioning)
    Sprites.width = SPRITE_WIDTH
    Sprites.height = SPRITE_HEIGHT
end

--[[
    Get a quad for a specific row and column

    @param row - row number (1-3)
    @param col - column number (1-9)
    @return quad object
]]
function Sprites.getQuad(row, col)
    if Sprites.quads and Sprites.quads[row] and Sprites.quads[row][col] then
        return Sprites.quads[row][col]
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
function Sprites.drawByGrid(row, col, x, y, scaleX, scaleY)
    scaleX = scaleX or 1
    scaleY = scaleY or scaleX

    local quad = Sprites.getQuad(row, col)
    if quad then
        love.graphics.draw(Sprites.sheet, quad, x, y, 0, scaleX, scaleY)
    end
end

--[[
    Draw a sprite using a named constant

    @param spriteDef - table with {row = n, col = m} (use sprites.RxCy constants)
    @param x - x position
    @param y - y position
    @param scaleX - optional x scale (default: 1)
    @param scaleY - optional y scale (default: scaleX or 1)
]]
function Sprites.draw(spriteDef, x, y, scaleX, scaleY)
    scaleX = scaleX or 1
    scaleY = scaleY or scaleX

    if spriteDef and spriteDef.row and spriteDef.col then
        Sprites.drawByGrid(spriteDef.row, spriteDef.col, x, y, scaleX, scaleY)
    end
end

--[[
    Get the sprite dimensions

    @return width, height
]]
function Sprites.getDimensions()
    return SPRITE_WIDTH, SPRITE_HEIGHT
end

return Sprites

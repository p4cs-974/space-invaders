--[[
    Utils module for Space Invaders
    Contains splash screen utilities: stars, background, and logo drawing
]]

local Utils = {}

-- Star data (initialized by initializeStars)
Utils.stars = {}

--[[
    Initialize the starfield with random positions, sizes, and blink properties
]]
function Utils.initializeStars()
    Utils.stars = {}
    local starCount = 50
    for i = 1, starCount do
        Utils.stars[i] = {
            x = math.random(0, VIRTUAL_WIDTH),
            y = math.random(0, VIRTUAL_HEIGHT),
            opacity = math.random(),
            blinkSpeed = 2.0 + math.random() * 3.0, -- random speed between 2.0 and 5.0
            blinkDirection = 1,                     -- 1 for increasing, -1 for decreasing
            size = math.random(1, 2)                -- random size: 1x1 or 2x2
        }
    end
end

--[[
    Update star blinking: pick 1-5 random stars to blink

    @param dt - delta time since last frame
]]
function Utils.updateStars(dt)
    local numStarsToBlink = math.random(1, 5)
    for i = 1, numStarsToBlink do
        local starIndex = math.random(1, #Utils.stars)
        local star = Utils.stars[starIndex]
        star.opacity = star.opacity + star.blinkSpeed * dt * star.blinkDirection
        if star.opacity >= 1 then
            star.opacity = 1
            star.blinkDirection = -1
        elseif star.opacity <= 0.5 then
            star.opacity = 0.5
            star.blinkDirection = 1
        end
    end
end

--[[
    Draw the starfield background with blinking stars.
]]
function Utils.drawStarsBackground(globalAlpha)
    local alphaMultiplier = globalAlpha or 1
    for _, star in ipairs(Utils.stars) do
        love.graphics.setColor(1, 1, 1, star.opacity * alphaMultiplier)
        love.graphics.rectangle('fill', star.x, star.y, star.size, star.size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

--[[
    Draw the Space Invaders logo with layered sprites
]]
function Utils.drawLogo(globalAlpha, yOffset)
    local alpha = globalAlpha or 1
    local offsetY = yOffset or 0
    love.graphics.setColor(0, 1, 0, alpha)
    local scale = 1
    local logoWidth, logoHeight = Sprites.getDimensions()
    Sprites.draw(Sprites.R1C1, VIRTUAL_WIDTH / 2 - (logoWidth * scale) / 2,
        VIRTUAL_HEIGHT / 2 - 15 - (logoHeight * scale) / 2 + offsetY, scale)
    love.graphics.setColor(0, 1, 1, alpha)
    scale = 1.1
    Sprites.draw(Sprites.R1C1, VIRTUAL_WIDTH / 2 - (logoWidth * scale) / 2,
        VIRTUAL_HEIGHT / 2 - 15 - (logoHeight * scale) / 2 + offsetY, scale)
    love.graphics.setColor(0, 0, 1, alpha)
    scale = 1.15
    Sprites.draw(Sprites.R1C1, VIRTUAL_WIDTH / 2 - (logoWidth * scale) / 2,
        VIRTUAL_HEIGHT / 2 - 15 - (logoHeight * scale) / 2 + offsetY, scale)
    love.graphics.setColor(1, 1, 1, 1)
end

--[[
    Draw the complete splash screen (background + logo)
]]
function Utils.drawSplashScreen(starsAlpha, logoAlpha, logoYOffset)
    Utils.drawStarsBackground(starsAlpha)
    Utils.drawLogo(logoAlpha, logoYOffset)
end

--[[
    Draw collision boxes for any objects that expose one.
    Priority:
    1) object:drawBoundingBox()
    2) object:getCollisionRect() -> x, y, w, h
]]
function Utils.drawCollisionBoxes(objects)
    if not objects then
        return
    end

    love.graphics.setColor(0.3, 1, 0.3, 1)

    for i = 1, #objects do
        local object = objects[i]
        if object then
            if object.drawBoundingBox then
                object:drawBoundingBox()
            elseif object.getCollisionRect then
                local x, y, w, h = object:getCollisionRect()
                love.graphics.rectangle('line', x, y, w, h)
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Utils

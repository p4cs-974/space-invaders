local UIComponents = {}

function UIComponents.drawFancyBox(x1, y1, x2, y2)
    local oldR, oldG, oldB, oldA = love.graphics.getColor()

    local width = x2 - x1
    local height = y2 - y1

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', x1, y1, width, height)

    love.graphics.setColor(oldR, oldG, oldB, oldA)
    love.graphics.rectangle('line', x1 + 2, y1 + 2, width - 4, height - 4)
end

function UIComponents.drawAlertBox(title, subtitle, virtualWidth, virtualHeight, largeFont, smallFont)
    UIComponents.drawFancyBox(10, virtualHeight / 2 - 90, virtualWidth - 10, virtualHeight / 2 + 30)

    love.graphics.setFont(largeFont)
    love.graphics.printf(title, 0, virtualHeight / 2 - 70, virtualWidth, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf(subtitle, 0, virtualHeight / 2, virtualWidth, 'center')
end

function UIComponents.drawDemoBox(virtualWidth, virtualHeight, largeFont)
    UIComponents.drawFancyBox(84, virtualHeight / 2 - 68, virtualWidth - 88, virtualHeight / 2 - 38)

    love.graphics.setFont(largeFont)
    love.graphics.printf('DEMO', 0, virtualHeight / 2 - 60, virtualWidth, 'center')
end

return UIComponents

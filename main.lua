push = require 'push'
Class = require 'class'

Sprites = require 'Sprites'
require 'UIComponents'
Utils = require 'Utils'
require 'Player'
require 'Shot'
require 'GameState'

WINDOW_WIDTH = 750
WINDOW_HEIGHT = 1000

VIRTUAL_WIDTH = 225
VIRTUAL_HEIGHT = 300
SPRITE_SCALE = 0.3
SHOT_SCALE = 0.22

PLAYER_SPEED = 120

local startTransitionActive = false
local startTransitionTimer = 0
local startTransitionTargetState = nil
local START_LOGO_FADE_DURATION = 0.35
local START_STARS_FADE_DURATION = 0.55
local START_LOGO_DRIFT_PIXELS = 10
local shots = {}

local function beginStartTransition(targetState)
    if currentState ~= GameState.START or startTransitionActive then
        return
    end

    startTransitionActive = true
    startTransitionTimer = 0
    startTransitionTargetState = targetState
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    Sprites.load()

    love.window.setTitle('Space Invaders')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    currentState = GameState.START

    -- local spriteScale = 0.3
    -- local spriteWidth, spriteHeight = Sprites.getDimensions()
    playerShip = Player(0, 0)
    playerShip.x = (VIRTUAL_WIDTH / 2)
    -- print("player.x = " .. player.x)
    -- print("spriteWidth = " .. spriteWidth)

    playerShip.y = (VIRTUAL_HEIGHT - playerShip.height * SPRITE_SCALE)
    -- print("player.y = " .. player.y)
    -- print("player.height = " .. player.height)
    -- print("spriteHeight = " .. spriteHeight)
    Utils.initializeStars()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    Utils.updateStars(dt)

    if startTransitionActive then
        startTransitionTimer = startTransitionTimer + dt
        if startTransitionTimer >= START_STARS_FADE_DURATION then
            startTransitionActive = false
            currentState = startTransitionTargetState
            startTransitionTargetState = nil
        end
    end

    if currentState ~= GameState.START then
        local moveLeft = love.keyboard.isDown('a') or love.keyboard.isDown('left')
        local moveRight = love.keyboard.isDown('d') or love.keyboard.isDown('right')

        if moveLeft and not moveRight then
            playerShip.dx = -PLAYER_SPEED
        elseif moveRight and not moveLeft then
            playerShip.dx = PLAYER_SPEED
        else
            playerShip.dx = 0
        end

        playerShip:update(dt)

        for i = #shots, 1, -1 do
            local shot = shots[i]
            shot:update(dt)

            if shot.remove then
                table.remove(shots, i)
            end
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 't' then
        if currentState == GameState.START then
            beginStartTransition(GameState.TESTE_1)
        else
            currentState = GameState.TESTE_1
        end
    elseif key == 'enter' or key == 'return' then
        if currentState == GameState.START then
            beginStartTransition(GameState.TESTE_1)
        end
    elseif key == 'space' and currentState ~= GameState.START then
        local playerCollisionX, playerCollisionY, playerCollisionW = playerShip:getCollisionRect()
        local shotX = playerCollisionX + playerCollisionW / 2
        local shotY = Shot.getSpawnDrawYForTopCollision(playerCollisionY)
        table.insert(shots, Shot(shotX, shotY))
    end
end

function love.draw()
    push:start()

    love.graphics.clear(10 / 255, 11 / 255, 26 / 255, 255 / 255)

    if currentState == GameState.START then
        local starsAlpha = 1
        local logoAlpha = 1
        local logoYOffset = 0

        if startTransitionActive then
            starsAlpha = math.max(0, 1 - (startTransitionTimer / START_STARS_FADE_DURATION))
            logoAlpha = math.max(0, 1 - (startTransitionTimer / START_LOGO_FADE_DURATION))
            logoYOffset = -START_LOGO_DRIFT_PIXELS * math.min(1, startTransitionTimer / START_LOGO_FADE_DURATION)
        end

        Utils.drawSplashScreen(starsAlpha, logoAlpha, logoYOffset)
    elseif currentState == GameState.TESTE_1 then

    end

    if currentState ~= GameState.START then
        for i = 1, #shots do
            shots[i]:render()
        end

        playerShip:render()

        local collisionObjects = { playerShip }
        for i = 1, #shots do
            collisionObjects[#collisionObjects + 1] = shots[i]
        end
        Utils.drawCollisionBoxes(collisionObjects)
    end

    push:finish()
end

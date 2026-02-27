push = require 'push'
Class = require 'class'

Sprites = require 'Sprites'
require 'UIComponents'
Utils = require 'Utils'
require 'Player'
require 'GameState'

WINDOW_WIDTH = 750
WINDOW_HEIGHT = 1000

VIRTUAL_WIDTH = 225
VIRTUAL_HEIGHT = 300

PLAYER_SPEED = 120

local startTransitionActive = false
local startTransitionTimer = 0
local startTransitionTargetState = nil
local START_LOGO_FADE_DURATION = 0.35
local START_STARS_FADE_DURATION = 0.55
local START_LOGO_DRIFT_PIXELS = 10

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

    playerShip.y = (VIRTUAL_HEIGHT - playerShip.height * playerShip.scale)
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
        if love.keyboard.isDown('a') and not love.keyboard.isDown('d') then
            playerShip.dx = -PLAYER_SPEED
        elseif love.keyboard.isDown('d') and not love.keyboard.isDown('a') then
            playerShip.dx = PLAYER_SPEED
        else
            playerShip.dx = 0
        end

        playerShip:update(dt)
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
        playerShip:render()
    end

    push:finish()
end

push = require 'push'
Class = require 'class'

WINDOW_WIDTH = 750
WINDOW_HEIGHT = 1000

VIRTUAL_WIDTH = 225
VIRTUAL_HEIGHT = 300
PLAYER_SCALE = 0.28
ENEMY_SCALE = 0.2
SHOT_SCALE = 0.2

PLAYER_SPEED = 120
PLAYER_SHOT_SPEED = 240
ENEMY_SHOT_SPEED = 115
PLAYER_SHOT_COOLDOWN = 0.2
ENEMY_MOVE_STEP_BASE = 1
ENEMY_MOVE_STEP_PER_DESCENT = 0.2
ENEMY_DESCENT_DISTANCE = 5

MAX_LEVEL = 3
BOSS_STEP_INTERVAL = 0.1

Sprites = require 'Sprites'
UIComponents = require 'UIComponents'
Utils = require 'Utils'
GameState = require 'GameState'
Player = require 'Player'
Shot = require 'Shot'
Inimigo = require 'Inimigo'

local currentState = GameState.START
local score = 0
local lives = 3
local level = 1

local playerShip = nil
local playerShots = {}
local enemyShots = {}
local enemies = {}
local boss = nil

local enemyStepTimer = 0
local enemyMoveDirection = 1
local enemyNeedsDescent = false
local enemyMoveStep = ENEMY_MOVE_STEP_BASE
local enemyFireTimer = 0
local bossStepTimer = 0
local bossSpawnTimer = 0

local playerShotTimer = 0
local playerInvulnerableTimer = 0
local playerDeathTimer = 0
local playerRespawnPending = false
local playerRespawnResetWave = false
local debugCollision = false
local startTransitionTimer = 0
local playingStarted = false

local START_TRANSITION_DURATION = 0.8
local LOGO_FADE_DURATION = 0.35
local LOGO_RISE_PIXELS = 10

local smallFont = nil
local largeFont = nil

local function beginStartTransition()
    startTransitionTimer = 0
    currentState = GameState.START_TRANSITION
end

local function rectsOverlap(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

local function randomBossSpawnDelay()
    return math.random(30, 50)
end

local function resetBossSpawnTimer()
    bossSpawnTimer = randomBossSpawnDelay()
end

local function resetEnemyPattern()
    enemyStepTimer = 0
    enemyMoveDirection = 1
    enemyNeedsDescent = false
    enemyMoveStep = ENEMY_MOVE_STEP_BASE
    enemyFireTimer = 0
end

local function enemyTypeForRow(row)
    if row == 1 then
        return {
            skins = { Sprites.R1C6, Sprites.R1C7 },
            points = 30
        }
    elseif row == 2 then
        return {
            skins = { Sprites.R1C4, Sprites.R1C5 },
            points = 20
        }
    end

    return {
        skins = { Sprites.R1C2, Sprites.R1C3 },
        points = 10
    }
end

local function spawnEnemyFormation()
    enemies = {}

    local rows = math.min(5, 3 + (level - 1))
    local cols = 8
    local spacingX = 3
    local spacingY = 4

    local spriteW, spriteH = Sprites.getDimensions()
    local enemyW = spriteW * ENEMY_SCALE
    local enemyH = spriteH * ENEMY_SCALE

    local formationWidth = cols * enemyW + (cols - 1) * spacingX
    local startX = (VIRTUAL_WIDTH - formationWidth) / 2 + enemyW / 2
    local startY = 22 + enemyH / 2

    for row = 1, rows do
        local enemyType = enemyTypeForRow(row)
        for col = 1, cols do
            local enemyX = startX + (col - 1) * (enemyW + spacingX)
            local enemyY = startY + (row - 1) * (enemyH + spacingY)

            enemies[#enemies + 1] = Inimigo({
                kind = 'common',
                x = enemyX,
                y = enemyY,
                scale = ENEMY_SCALE,
                points = enemyType.points,
                skins = enemyType.skins
            })
        end
    end

    resetEnemyPattern()
end

local function spawnBoss()
    local bossEnemy = Inimigo({
        kind = 'boss',
        x = 0,
        y = 0,
        scale = ENEMY_SCALE * 1.2,
        points = 50,
        skins = { Sprites.R3C4 },
        animInterval = 0.25
    })

    bossEnemy.x = bossEnemy.width / 2
    bossEnemy.y = bossEnemy.height / 2 + 4
    boss = bossEnemy
    bossStepTimer = 0
end

local function startGame()
    score = 0
    lives = 3
    level = 1

    playerShots = {}
    enemyShots = {}
    boss = nil

    playerShotTimer = 0
    playerInvulnerableTimer = 0
    playerDeathTimer = 0
    playerRespawnPending = false
    playerRespawnResetWave = false
    playingStarted = false

    playerShip = Player(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT - 24)

    spawnEnemyFormation()
    resetBossSpawnTimer()

    currentState = GameState.PLAYING
end

local function advanceLevel()
    if level >= MAX_LEVEL then
        currentState = GameState.VICTORY
        return
    end

    level = level + 1
    playerShots = {}
    enemyShots = {}
    boss = nil

    playerShip:resetPosition()
    spawnEnemyFormation()
    resetBossSpawnTimer()

    playerInvulnerableTimer = 1
    playerDeathTimer = 0
    playerRespawnPending = false
    playerRespawnResetWave = false
end

local function loseLife(resetWave)
    if playerInvulnerableTimer > 0 or playerDeathTimer > 0 then
        return
    end

    lives = lives - 1
    if lives <= 0 then
        currentState = GameState.DEFEAT
        return
    end

    playerShip.dx = 0
    playerDeathTimer = 0.45
    playerRespawnPending = true
    playerRespawnResetWave = resetWave
    playerShots = {}
    enemyShots = {}
end

local function getEnemyLowestDistanceRatio()
    if #enemies == 0 then
        return 0
    end

    local lowestY = 0
    for i = 1, #enemies do
        local enemyBottom = enemies[i]:getBottomY()
        if enemyBottom > lowestY then
            lowestY = enemyBottom
        end
    end

    local playAreaHeight = VIRTUAL_HEIGHT - 30
    return math.min(1, lowestY / playAreaHeight)
end

local function getEnemyStepInterval()
    local baseInterval = 0.25 - (level - 1) * 0.03
    return math.max(0.11, baseInterval)
end

local function getEnemyFireInterval()
    local baseInterval = 1.7 - (level - 1) * 0.2
    baseInterval = math.max(0.8, baseInterval)

    local proximity = getEnemyLowestDistanceRatio()
    local multiplier = 1 - proximity * 0.5
    return math.max(0.25, baseInterval * multiplier)
end

local function getFormationBounds()
    if #enemies == 0 then
        return 0, 0, 0
    end

    local minX = math.huge
    local maxX = -math.huge
    local maxBottom = -math.huge

    for i = 1, #enemies do
        local enemy = enemies[i]
        local drawX = enemy:getDrawX()
        local drawW = enemy.width
        local _, ey, _, eh = enemy:getCollisionRect()

        if drawX < minX then
            minX = drawX
        end
        if drawX + drawW > maxX then
            maxX = drawX + drawW
        end
        if ey + eh > maxBottom then
            maxBottom = ey + eh
        end
    end

    return minX, maxX, maxBottom
end

local function dropEnemiesSafely()
    local dropCandidates = {}
    for i = 1, #enemies do
        local enemy = enemies[i]
        local x, y, w, h = enemy:getCollisionRect()
        dropCandidates[#dropCandidates + 1] = {
            enemy = enemy,
            x = x,
            y = y,
            w = w,
            h = h,
            dy = ENEMY_DESCENT_DISTANCE
        }
    end

    table.sort(dropCandidates, function(a, b)
        return (a.y + a.h) > (b.y + b.h)
    end)

    local occupiedRects = {}
    for i = 1, #dropCandidates do
        local current = dropCandidates[i]
        local targetY = current.y + current.dy
        local blocked = false

        for j = 1, #occupiedRects do
            local other = occupiedRects[j]
            if rectsOverlap(current.x, targetY, current.w, current.h, other.x, other.y, other.w, other.h) then
                blocked = true
                break
            end
        end

        if blocked then
            occupiedRects[#occupiedRects + 1] = { x = current.x, y = current.y, w = current.w, h = current.h }
        else
            current.enemy:move(0, current.dy)
            occupiedRects[#occupiedRects + 1] = { x = current.x, y = targetY, w = current.w, h = current.h }
        end
    end
end

local function moveEnemiesHorizontally()
    local minX, maxX = getFormationBounds()
    local hitBorder = false
    local dx = enemyMoveDirection * enemyMoveStep
    if minX + dx < 0 then
        dx = -minX
        hitBorder = true
    elseif maxX + dx > VIRTUAL_WIDTH then
        dx = VIRTUAL_WIDTH - maxX
        hitBorder = true
    end

    for i = 1, #enemies do
        enemies[i]:move(dx, 0)
    end

    return hitBorder
end

local function updateEnemyMovement(dt)
    for i = 1, #enemies do
        enemies[i]:update(dt)
    end

    enemyStepTimer = enemyStepTimer + dt
    local stepInterval = getEnemyStepInterval()

    while enemyStepTimer >= stepInterval do
        enemyStepTimer = enemyStepTimer - stepInterval

        if enemyNeedsDescent then
            dropEnemiesSafely()
            enemyMoveStep = enemyMoveStep + ENEMY_MOVE_STEP_PER_DESCENT
            enemyNeedsDescent = false
        else
            local hitBorder = moveEnemiesHorizontally()

            if hitBorder then
                enemyMoveDirection = -enemyMoveDirection
                enemyNeedsDescent = true
            end
        end
    end

    local _, _, maxBottom = getFormationBounds()
    if maxBottom >= VIRTUAL_HEIGHT - 2 then
        loseLife(true)
    end
end

local function enemyShoot()
    if #enemies == 0 then
        return
    end

    local shooter = enemies[math.random(1, #enemies)]
    local ex, ey, ew, eh = shooter:getCollisionRect()
    local shotX = ex + ew / 2
    local shotY = ey + eh - 2
    enemyShots[#enemyShots + 1] = Shot(shotX, shotY, 1, ENEMY_SHOT_SPEED + level * 12, 'enemy')
end

local function updateEnemyFire(dt)
    enemyFireTimer = enemyFireTimer + dt
    local fireInterval = getEnemyFireInterval()

    while enemyFireTimer >= fireInterval do
        enemyFireTimer = enemyFireTimer - fireInterval
        enemyShoot()
    end
end

local function updateBoss(dt)
    if boss then
        boss:update(dt)
        bossStepTimer = bossStepTimer + dt

        while bossStepTimer >= BOSS_STEP_INTERVAL do
            bossStepTimer = bossStepTimer - BOSS_STEP_INTERVAL
            boss:move(5, 0)
        end

        if boss:getDrawX() > VIRTUAL_WIDTH then
            boss = nil
            resetBossSpawnTimer()
        end
        return
    end

    bossSpawnTimer = bossSpawnTimer - dt
    if bossSpawnTimer <= 0 then
        spawnBoss()
    end
end

local function updatePlayerShots(dt)
    for i = #playerShots, 1, -1 do
        local shot = playerShots[i]
        shot:update(dt)

        if shot.remove then
            table.remove(playerShots, i)
        elseif shot:canHit() then
            local sx, sy, sw, sh = shot:getCollisionRect()
            local consumedShot = false

            if boss then
                local bx, by, bw, bh = boss:getCollisionRect()
                if rectsOverlap(sx, sy, sw, sh, bx, by, bw, bh) then
                    score = score + boss.points
                    boss = nil
                    resetBossSpawnTimer()
                    shot:impact()
                    consumedShot = true
                end
            end

            if not consumedShot then
                for j = #enemies, 1, -1 do
                    local enemy = enemies[j]
                    local ex, ey, ew, eh = enemy:getCollisionRect()
                    if rectsOverlap(sx, sy, sw, sh, ex, ey, ew, eh) then
                        score = score + enemy.points
                        table.remove(enemies, j)
                        shot:impact()
                        break
                    end
                end
            end
        end
    end

    if #enemies == 0 and currentState == GameState.PLAYING then
        advanceLevel()
    end
end

local function updateEnemyShots(dt)
    for i = #enemyShots, 1, -1 do
        local shot = enemyShots[i]
        shot:update(dt)

        if shot.remove then
            table.remove(enemyShots, i)
        elseif shot:canHit() then
            if playerInvulnerableTimer <= 0 then
                local sx, sy, sw, sh = shot:getCollisionRect()
                local px, py, pw, ph = playerShip:getCollisionRect()
                if rectsOverlap(sx, sy, sw, sh, px, py, pw, ph) then
                    shot:impact()
                    loseLife(false)
                    return
                end
            end
        end
    end
end

local function updatePlayerInput(dt)
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
end

local function shootPlayer()
    if playerShotTimer > 0 or playerDeathTimer > 0 or playerRespawnPending then
        return
    end

    local shotX, shotY = playerShip:getGunPosition()
    playerShots[#playerShots + 1] = Shot(shotX, shotY - 18, -1, PLAYER_SHOT_SPEED, 'player')
    playerShotTimer = PLAYER_SHOT_COOLDOWN
end

local function drawHud()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Pontos: ' .. tostring(score), 6, 6)
    love.graphics.print('Vidas: ' .. tostring(lives), 6, 16)
    love.graphics.print('Nivel: ' .. tostring(level), VIRTUAL_WIDTH - 50, 6)
end

local function drawStartScreen()
    Utils.drawSplashScreen(1, 1, 0)
    UIComponents.drawFancyBox(14, VIRTUAL_HEIGHT / 2 + 30, VIRTUAL_WIDTH - 14, VIRTUAL_HEIGHT - 14)
    love.graphics.setFont(smallFont)
    love.graphics.printf('Aperte ENTER para jogar', 0, VIRTUAL_HEIGHT / 2 + 54, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Setas/A,D movem | ESPACO atira', 0, VIRTUAL_HEIGHT / 2 + 68, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Destrua todos os inimigos em 3 niveis', 0, VIRTUAL_HEIGHT / 2 + 82, VIRTUAL_WIDTH, 'center')
end

local function drawStartTransitionScreen()
    local progress = math.min(1, startTransitionTimer / START_TRANSITION_DURATION)
    local logoProgress = math.min(1, startTransitionTimer / LOGO_FADE_DURATION)

    local starsAlpha = 1 - progress
    local logoAlpha = 1 - logoProgress
    local logoYOffset = -LOGO_RISE_PIXELS * logoProgress

    Utils.drawSplashScreen(starsAlpha, logoAlpha, logoYOffset)
end

local function drawPlayScreen()
    for i = 1, #enemies do
        enemies[i]:render()
    end

    if boss then
        boss:render()
    end

    for i = 1, #playerShots do
        playerShots[i]:render()
    end

    for i = 1, #enemyShots do
        enemyShots[i]:render()
    end

    if playerDeathTimer > 0 then
        love.graphics.setColor(1, 0.85, 0.35, 1)
        Sprites.draw(Sprites.R3C6, playerShip:getDrawX(), playerShip:getDrawY(), PLAYER_SCALE)
        love.graphics.setColor(1, 1, 1, 1)
    elseif playerInvulnerableTimer <= 0 or math.floor(playerInvulnerableTimer * 10) % 2 == 0 then
        playerShip:render()
    end

    drawHud()

    if not playingStarted then
        UIComponents.drawFancyBox(50, VIRTUAL_HEIGHT / 2 - 18, VIRTUAL_WIDTH - 50, VIRTUAL_HEIGHT / 2 + 18)
        love.graphics.setFont(smallFont)
        love.graphics.printf('ENTER para iniciar', 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('A,D/Setas | ESPACO atira', 0, VIRTUAL_HEIGHT / 2 + 2, VIRTUAL_WIDTH, 'center')
    end

    if debugCollision then
        local objects = { playerShip }
        for i = 1, #playerShots do
            objects[#objects + 1] = playerShots[i]
        end
        for i = 1, #enemyShots do
            objects[#objects + 1] = enemyShots[i]
        end
        for i = 1, #enemies do
            objects[#objects + 1] = enemies[i]
        end
        if boss then
            objects[#objects + 1] = boss
        end
        Utils.drawCollisionBoxes(objects)
    end
end

local function drawResultScreen(title, subtitle)
    Utils.drawStarsBackground(1)
    UIComponents.drawAlertBox(title, subtitle, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, largeFont, smallFont)
    love.graphics.setFont(smallFont)
    love.graphics.printf('Pontuacao final: ' .. tostring(score), 0, VIRTUAL_HEIGHT / 2 + 44, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('ENTER para jogar novamente', 0, VIRTUAL_HEIGHT / 2 + 58, VIRTUAL_WIDTH, 'center')
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    love.window.setTitle('Space Invaders')

    Sprites.load()
    Utils.initializeStars()

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    Utils.updateStars(dt)

    if currentState == GameState.START_TRANSITION then
        startTransitionTimer = startTransitionTimer + dt
        if startTransitionTimer >= START_TRANSITION_DURATION then
            startGame()
        end
        return
    end

    if currentState ~= GameState.PLAYING then
        return
    end

    if not playingStarted then
        return
    end

    playerShotTimer = math.max(0, playerShotTimer - dt)
    playerInvulnerableTimer = math.max(0, playerInvulnerableTimer - dt)
    playerDeathTimer = math.max(0, playerDeathTimer - dt)

    if playerDeathTimer > 0 then
        for i = #playerShots, 1, -1 do
            playerShots[i]:update(dt)
            if playerShots[i].remove then
                table.remove(playerShots, i)
            end
        end
        for i = #enemyShots, 1, -1 do
            enemyShots[i]:update(dt)
            if enemyShots[i].remove then
                table.remove(enemyShots, i)
            end
        end
        return
    end

    if playerRespawnPending then
        playerShip:resetPosition()
        playerShots = {}
        enemyShots = {}
        boss = nil
        resetBossSpawnTimer()
        if playerRespawnResetWave then
            spawnEnemyFormation()
        end
        playerInvulnerableTimer = 1.25
        playerRespawnPending = false
        playerRespawnResetWave = false
    end

    updatePlayerInput(dt)
    updateEnemyMovement(dt)
    if currentState ~= GameState.PLAYING then
        return
    end

    updateEnemyFire(dt)
    updateBoss(dt)
    updatePlayerShots(dt)
    if currentState ~= GameState.PLAYING then
        return
    end
    updateEnemyShots(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
        return
    end

    if key == 'b' then
        debugCollision = not debugCollision
        return
    end

    if currentState == GameState.START then
        if key == 'enter' or key == 'return' or key == 'space' then
            beginStartTransition()
        end
        return
    end

    if currentState == GameState.PLAYING then
        if not playingStarted then
            if key == 'enter' or key == 'return' then
                playingStarted = true
            end
            return
        end

        if key == 'space' then
            shootPlayer()
        end
        return
    end

    if currentState == GameState.VICTORY or currentState == GameState.DEFEAT then
        if key == 'enter' or key == 'return' or key == 'space' then
            startGame()
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear(10 / 255, 11 / 255, 26 / 255, 1)

    if currentState == GameState.START then
        drawStartScreen()
    elseif currentState == GameState.START_TRANSITION then
        drawStartTransitionScreen()
    elseif currentState == GameState.PLAYING then
        drawPlayScreen()
    elseif currentState == GameState.VICTORY then
        drawResultScreen('VITORIA', 'Todos os inimigos foram destruidos!')
    elseif currentState == GameState.DEFEAT then
        drawResultScreen('DERROTA', 'Voce perdeu todas as vidas.')
    end

    push:finish()
end

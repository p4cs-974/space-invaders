Player = Class {}

function Player:init(x, y)
    self.scale = 0.3
    self.initial_x = x
    self.x = x
    self.initial_y = y
    self.y = y
    self.width, self.height = Sprites.getDimensions()
    self.width = self.width * self.scale
    self.height = self.height * self.scale
    self.dx = 0
end

function Player:update(dt)
    -- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated Y position when pressing up so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
        -- similar to before, this time we use math.min to ensure we don't
        -- go any farther than the bottom of the screen minus the paddle's
        -- height (or else it will go partially below, since position is
        -- based on its top left corner)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
end

function Player:reset()
    self.x = self.initial_x
    self.y = self.initial_y
    self.dx = 0
end

function Player:render()
    love.graphics.setColor(1, 0.263, 0.212, 1)
    Sprites.draw(Sprites.R3C5, VIRTUAL_WIDTH / 2 - (self.width) / 2,
        VIRTUAL_HEIGHT / 2 - 10 - (self.height) / 2, self.scale)
end

return Player

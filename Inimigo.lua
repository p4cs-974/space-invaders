Inimigo = Class {}

function Inimigo:init(x, y, skin, color)
    self.timer = 0
    self.waitTime = 1
    self.speed = 2
    self.skin = skin
    self.x = x
    self.y = y
    self.dx = self.speed
    self.dy = 0
    self.width, self.height = Sprites.getDimensions()
    self.idxSprite = 1
    self.color = color
end

function Inimigo:mudarEstado()
    self.dx = self.dx * -1
end

function Inimigo:trocarSprite()
    self.idxSprite = (self.idxSprite % 2) + 1
end

function Inimigo:update(dt)
    self.timer = self.timer + dt
    if (self.timer >= self.waitTime / 4) then
        self:mudarEstado()
        self.timer = 0
    end
    if (self.timer >= self.waitTime) then
        self:mudarEstado()
        self.timer = 0
    end
end

function Inimigo:render()

end

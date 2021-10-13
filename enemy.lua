Goomba = class("goomba")
goombas = {}

function Goomba:initialize(x, y)
    local goomba = world:newRectangleCollider(x, y, 70, 90, {collision_class = "Danger"})
    self.direction = 1
    self.speed = 200
    self.animation = animations.goomba
    table.insert(goombas, goomba)
end

function Goomba:update(dt)
end

function Goomba:draw()
end
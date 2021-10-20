Goomba = class("goomba")

function Goomba:initialize(x, y)
    self.body = world:newRectangleCollider(x, y, 70, 90, {collision_class = "Danger"})
    self.direction = 1
    self.speed = 200
    self.animation = animations.goomba
end

function Goomba:destroy()
self.body:destroy()
end

function Goomba:update(dt)
end

function Goomba:draw()
end
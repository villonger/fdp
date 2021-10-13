Player = class("player")

function Player:initialize(x, y)
    self.startX = x
    self.startY = y


    self.animation = animations.idle
    self.isMoving = false
    self.direction = 1 -- 1 = right, -1 = left
    self.grounded = true
    self.shiftWas = false

    self.XlinearVelocity = 0
    self.YlinearVelocity = 0
    self.rotation = 0
    self.coyote = 0


    self.collider = world:newCircleCollider(self.startX, self.startY, 30, {collision_class = "Player"})

    self.collider:setLinearDamping(0.05)
    self.collider:setPreSolve(function (a, b, contact)
        local nx, ny = contact:getNormal()
        if math.abs(nx) ~= 0 then -- horizontal collision
            contact:setFriction(0)
        end
    end)
end

function Player:update(dt)
    -- I dunno if this goes here it made no sense where it was before either
    self.collider:setFixedRotation(true)


    self.XlinearVelocity, self.YlinearVelocity = self.collider:getLinearVelocity()
    if self.collider.shiftWas then
        self.rotation = self.XlinearVelocity*0.03*-1
    else
        self.rotation = 0
    end

    if self.collider.body then
        local colliders = world:queryRectangleArea(self.collider:getX() - 30, self.collider:getY() + 30, 60, 2, {'Platform'})
        if #colliders > 0 then
            self.grounded = true
        else
            self.grounded = false
        end

        if self.shiftWas == false then
            local px, py = self.collider:getPosition()
            local vx, vy = self.collider:getLinearVelocity()

            if self.grounded then
                vx = math.min(500, math.max(-500, vx))
            else
                vx = math.min(550, math.max(-550, vx))
            end

            self.collider:setLinearVelocity(vx, vy)
            if love.keyboard.isDown('right') then
                self.collider:applyForce(20000,0)
                self.isMoving = true
                self.direction = 1
            end

            if love.keyboard.isDown('left') then
                self.collider:applyForce(-20000,0)
                self.isMoving = true
                self.direction = -1
            end

            if love.keyboard.isDown('lshift') and self.shiftWas == false then
                if love.keyboard.isDown('right') then
                    self.collider:applyLinearImpulse(8000,800)
                    self.dashCD = 1000
                    self.shiftWas = true
                    sounds.bonk:play()
                elseif love.keyboard.isDown('left') then
                    self.collider:applyLinearImpulse(-8000,800)
                    self.dashCD = 1000
                    self.shiftWas = true
                    sounds.bonk:play()
                end
            end
        end

        if self.collider:enter('Danger') then
            self.collider:setPosition(self.startX, self.startY)
        end

        if self.grounded then
            if self.isMoving then
                self.animation = animations.run
            else
                self.animation = animations.idle
            end

            self.coyote = 0
        else
            self.coyote = self.coyote + dt
        end

        if self.collider:getLinearVelocity() == 0 and self.grounded then
            self.shiftWas = false
        end

        self.animation:update(dt)

        if love.keyboard.isDown('z') and not self.shiftWas and self.YlinearVelocity < 0 then
            self.collider:setGravityScale(0.5)
        else
            self.collider:setGravityScale(1)
        end

        if self.shiftWas and love.keyboard.isDown('x') then
            self.collider:setFriction(1.2)
            self.collider:setLinearDamping(0.5)
        elseif self.shiftWas then
            self.collider:setGravityScale(0.5)
            self.collider:setFriction(0.5)
            self.collider:setLinearDamping(0.05)
        else
            self.collider:setFriction(0.6)
            self.collider:setLinearDamping(0.05)
        end
    end
    --world:queryRectangleArea(player:getX() - 35, player:getY() + 26, 70, 4, {'Platform'})
end

function Player:keypressed(key)
    if key == 'z' then
        if self.grounded or self.coyote<=0.075 then
            self.collider:applyLinearImpulse(0, -3000)
            sounds.jump:play()
        end
    end
end

function Player:draw()
    local px, py = self.collider:getPosition()
    self.animation:draw(sprites.playerSheet, px, py, self.rotation, 0.4 * self.direction, 0.4, 120, 150)
end
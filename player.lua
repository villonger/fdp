playerStartX = 360
playerStartY = 100

player = world:newCircleCollider(playerStartX, playerStartY, 30, {collision_class = "Player"})

player:setLinearDamping(0.05)
player.XlinearVelocity = 0
player.YlinearVelocity = 0
player.rotation = 0
player.speed = 500
player.animation = animations.idle
player.isMoving = false
player.direction = 1 -- 1 = right, -1 = left
player.grounded = true
player.shiftWas = false

if player.shiftWas then
    player:setFixedRotation(false)
else
    player:setFixedRotation(true)
end

function playerUpdate(dt)
    player.XlinearVelocity, player.YlinearVelocity = player:getLinearVelocity()
    if player.shiftWas then
        player.rotation = player.XlinearVelocity*0.03*-1
    else
        player.rotation = 0
    end

    if player.body then
        local colliders = world:queryRectangleArea(player:getX() - 30, player:getY() + 30, 60, 2, {'Platform'})
        if #colliders > 0 then 
            player.grounded = true
        else
            player.grounded = false
        end
        if player.shiftWas == false then
                local px, py = player:getPosition()
                local vx, vy = player:getLinearVelocity()
                if player.grounded then
                    vx = math.min(500, math.max(-500, vx))
                else 
                    vx = math.min(550, math.max(-550, vx))
                end
                player:setLinearVelocity(vx, vy)
                if love.keyboard.isDown('right') then
                    player:applyForce(20000,0)
                    player.isMoving = true
                    player.direction = 1
                end
                if love.keyboard.isDown('left') then
                    player:applyForce(-20000,0)
                    player.isMoving = true
                    player.direction = -1
                end
            if love.keyboard.isDown('lshift') and player.shiftWas == false then
                if love.keyboard.isDown('right') then
                    player:applyLinearImpulse(8000,800)
                    player.dashCD = 1000
                    player.shiftWas = true
                    sounds.bonk:play()
                elseif love.keyboard.isDown('left') then
                    player:applyLinearImpulse(-8000,800)
                    player.dashCD = 1000
                    player.shiftWas = true
                    sounds.bonk:play()
                end
            end
        end
        if player:enter('Danger') then
            player:setPosition(playerStartX, playerStartY)
        end
        if player.grounded then
            if player.isMoving then
                player.animation = animations.run
            else
                player.animation = animations.idle
            end

            coyote = 0
            else
                coyote = coyote + dt
        end
        if player:getLinearVelocity() == 0 and player.grounded then
            player.shiftWas = false
        end
        player.animation:update(dt)
        if love.keyboard.isDown('z') and player.shiftWas == false and player.YlinearVelocity < 0 then
            player:setGravityScale(0.5)
            else
                player:setGravityScale(1)
        end
        if player.shiftWas and love.keyboard.isDown('x') then
            player:setFriction(1.2)
            player:setLinearDamping(0.5)
        elseif player.shiftWas then
            player:setGravityScale(0.5)
            player:setFriction(0.5)
            player:setLinearDamping(0.05)
        else
            player:setFriction(0.6)
            player:setLinearDamping(0.05)
        end
    end
    function love.keypressed(key)
        if player.body then
            if key == 'z' then
                if player.grounded or coyote<=0.075 then
                player:applyLinearImpulse(0, -3000)
                sounds.jump:play()
                end
            end
            if key == 'r' then
                loadMap("test")
                player:setLinearVelocity(0,0)
            end
        end
    end
    --world:queryRectangleArea(player:getX() - 35, player:getY() + 26, 70, 4, {'Platform'})
end

function resolve(a, b, contact)
    local nx, ny = contact:getNormal()
    if math.abs(nx) == 1 then -- horizontal collision
        contact:setFriction(0)
    end
end
player:setPreSolve(resolve)

function playerDraw()
    
    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet, px, py, player.rotation, 0.4 * player.direction, 0.4, 120, 150)
end
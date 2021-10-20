function love.load()
    love.window.setMode(1000, 768)

    class = require "libraries.middleclass"
    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'

    cam = cameraFile()

    sounds = {}
    sounds.jump = love.audio.newSource("audio/jump.wav", "static")
    sounds.bonk = love.audio.newSource("audio/bonk.ogg", "static")

    --[[sounds.music = love.audio.newSource("audio/music.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.1)
    sounds.music:play()]]


    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/cirnoSheet.png')
    sprites.background = love.graphics.newImage('sprites/background.jpg')

    local grid = anim8.newGrid(240, 240, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-2',2), 0.1)
    animations.run = anim8.newAnimation(grid('1-2',1), 0.1)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)
    world:setGravity(0,2000)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')

    require('player')

    require('enemy')
    require('libraries/show')

    --dangerZone = world:newRectangleCollider(-500, 800, 10000, 50, {collision_class = "Danger"})
    --dangerZone:setType('static')

    platforms = {}
    reses = {}

    flagX = 0
    flagY = 0

    saveData = {}
    saveData.currentLevel = "level1"

    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    myFont = love.graphics.newFont(30)

    loadMap(saveData.currentLevel)
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)

    myPlayer:update(dt)

    for _, goomba in ipairs(goombas) do
        Goomba:update(dt)
    end

    local px, py = myPlayer.collider:getPosition()
    cam:lockX(px, cam.smooth.linear(10000))
    cam:lockY(py, cam.smooth.linear(5000))
    cam:zoomTo(0.7)

    local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
    if #colliders > 0 then
        if saveData.currentLevel == "level1" then
        loadMap("level1")
        elseif saveData.currentLevel == "level1" then
            loadMap("level1")
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 70)
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        world:draw()


        myPlayer:draw()
        for _, goomba in ipairs(goombas) do
            Goomba:draw(dt)
        end
    cam:detach()
    love.graphics.print(myPlayer.coyote, myFont)

    if myPlayer.grounded then
        love.graphics.print("True",myFont,40,40)
    else
        love.graphics.print("False",myFont,40,40)
    end


end

function spawnPlatform(x, y, width, height)
    local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
    platform:setType('static')
    table.insert(platforms, platform)
end
--[[function spawnRes(x, y)
    local res = world:newCircleCollider(x, y, 10, {'Player'})
    res:setType('static')
    table.insert(reses, res)
end]]

function destroyAll()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i-1
    end

  --[[  local i = #goombas
    while i > -1 do
        if goombas[i] ~= nil then
            goombas[i]:destroy()
        end
        table.remove(goombas, i)
        i = i-1
    end]]
end

function loadMap(mapName)
    saveData.currentLevel = level1
    love.filesystem.write("data.lua", table.show(saveData, "saveData"))
    destroyAll()
    gameMap = sti("maps/level1.lua")
    for i, obj in pairs(gameMap.layers["Start"].objects) do
        myPlayer = Player:new(obj.x, obj.y)
    end

    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["Goombas"].objects) do
        table.insert(goombas, Goomba:new(obj.x, obj.y))
    end
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
    --[[for i, obj in pairs(gameMap.layers["Res"].objects) do
        spawnRes(obj.x, obj.y)
    end]]--
end

function love.keypressed(key)

    myPlayer:keypressed(key)
    
    if key == 'r' then
        loadMap("test")
        myPlayer.collider:setLinearVelocity(0,0)
        myPlayer.collider:setPosition(myPlayer.startX,myPlayer.startY)
    end
end


--[[function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end]]
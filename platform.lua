Platform = class("platform")

function Platform:initialize(obj)
    if obj.shape == "rectangle" then
    self.body = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
    elseif obj.shape == "polygon" then
        print("!")
        local vertices = {}

        for _,vertice in ipairs(obj.polygon) do
            table.insert(vertices, vertice.x)
            table.insert(vertices, vertice.y)
        end
        self.body = world:newPolygonCollider(vertices)
    end

    self.body:setType('static')
    self.body:setCollisionClass("Platform")


end
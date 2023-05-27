class('Scene').extends(playdate.object);

function Scene:init()
    Scene.super.init(self);
end

function Scene:onEnter()
    print("Scene Enter: "..self.className);
end

function Scene:onExit()
    print("Scene Exit: "..self.className);
end

function Scene:update()
end

function Scene:draw()
end

function Scene:lateUpdate()
end

function Scene:lateDraw()
end
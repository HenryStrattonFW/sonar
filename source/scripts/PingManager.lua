import "CoreLibs/graphics"

class("PingManager").extends(playdate.object)

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local pingSpeed <const> = 50;

function PingManager:init()
    PingManager.super.init(self);
    self:reset();
end

function PingManager:reset()
    self.pings = {};
end

function PingManager:triggerPing(x, y, size)
    self.pings[#self.pings+1] = {
        x = x,
        y = y,
        radius = 0,
        target = size
    };
end

function PingManager:tick(dt)
    if(#self.pings == 0) then return end; 
    local step = pingSpeed * dt;
    local n = #self.pings;
    for i=1,n do
        local ping = self.pings[i];
        ping.radius = math.min(ping.target, ping.radius + step);
        if(ping.radius >= ping.target)then
            self.pings[i] = nil;
        end
    end
    condenseArray(self.pings);
end

function PingManager:draw()
    if(#self.pings == 0) then return end;
    for _,ping in ipairs(self.pings) do
        gfx.drawCircleAtPoint(ping.x, ping.y, ping.radius);
    end
end
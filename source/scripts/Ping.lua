import "CoreLibs/graphics"

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local sample <const> = pd.sound.sampleplayer;

class('Ping').extends(pd.object);

-- TODO: update to use a timer instead of manually updating based on crude delta time.

function Ping:init()
	Ping.super.init(self);
    self.speed = 128.0;
    self.radius = 0;
    self:reset();
    self.audio = sample.new("./assets/audio/ping");
end

function Ping:reset()
    self.target = 0;
    self.radius = 0;
    self.mineIds = {};
end

function Ping:hasPingedMine(id) 
    return self.mineIds[id] ~= nil;
end
        
function Ping:pingMine(id) 
    self.mineIds[id] = true;
end

function Ping:activate(x ,y, range)
    self.x, self.y = x, y;
    self.mineIds = {};
    self.target = range;
    self.radius = 1;
    self.audio:play(1);
end

function Ping:isActive()
    return self.radius > 0;
end

function Ping:tick(dt)
    if self.target <= 0 then return end;

    self.radius = math.min(self.target, self.radius + (self.speed*dt));
    
    if(self.radius < self.target) then return end;
    
    self.target = 0;
    self.radius = 0;
end

function Ping:draw()
    if(self.radius <= 0) then return end;
    gfx.drawCircleAtPoint(self.x, self.y, self.radius);
end
local pd <const> = playdate;

class('Stopwatch').extends(pd.object);

function Stopwatch:init(autoStart)
    self.active = false;
    self.totalSeconds = 0;
    self.paused = false;
    if(autoStart) then self:start(); end
end

function Stopwatch:tick(dt)
    if((not self.active) or self.paused) then return end;
    self.totalSeconds += dt;
end

function Stopwatch:start()
    if(self.active) then return end;
    self.active = true;
    self.paused = false;
    self.totalSeconds = 0;
    Tickables.add(self);
end

function Stopwatch:pause()
    self.paused = true;
end

function Stopwatch:resume()
    self.paused = false;
end

function Stopwatch:stop()
    if(not self.active) then return end;
    self.active = false;
    self.paused = false;
    Tickables.remove(self);
end
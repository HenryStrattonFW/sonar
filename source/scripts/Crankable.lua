import "CoreLibs/crank"

local pd <const> = playdate;

class('Crankable').extends(pd.object)


function Crankable:init(min, max, crankFactor, directional)
    Crankable.super.init(self);
    self.value = 0;
    self.minValue = min;
    self.maxValue = max;
    self.directional = directional;
    self.crankFactor = crankFactor;
    self.enabled = true;
end

function Crankable:setEnabled(enabled)
    self.enabled = enabled;
end

function Crankable:getValue()
    return self.value;
end

function Crankable:getValueNormalized()
    return (inverseLerp(self.minValue, self.maxValue, self.value));
end

function Crankable:setValue(value)
    self.value = clamp(value, self.minValue, self.maxValue);
end

function Crankable:tick(dt)
    if(self.enabled == false) then return end;
    
    local change = pd.getCrankChange() * self.crankFactor;
    if(self.directional == false) then 
        change = math.abs(change);
    end
    self:setValue(self.value + (change * dt));
end

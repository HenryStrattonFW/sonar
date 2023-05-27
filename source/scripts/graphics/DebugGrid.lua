local gfx <const> = playdate.graphics;
local point <const> = playdate.geometry.point;

class('DebugGrid').extends(playdate.object)

function DebugGrid:init(x, y, width, height, spacing)
    self.points = {};
    local pointImage = gfx.image.new("./assets/images/point");
    local count = width * height;
    for i=0,(count-1) do
        local y2 = math.floor(i / width);
        local x2 = i - (y2*width);
        local newSprite = gfx.sprite.new(pointImage);
        newSprite:moveTo(x + (x2*spacing), y +(y2*spacing));
        newSprite:add();
        self.points[i] = newSprite;
    end
end

function DebugGrid:cleanup()
    local points = self.points;
    for i=1,#points do
        points[i]:remove();
        points[i] = nil;
    end
    self.points = {};
end
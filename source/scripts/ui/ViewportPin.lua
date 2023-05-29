import "CoreLibs/graphics"
import "./scripts/utils/utils";

local pd <const> = playdate;
local gfx <const> = pd.graphics;

local function toScreenSpace(x,y)
    local cx,cy = gfx.getDrawOffset();
    return x+cx, y+cy;
end

local function pinToViewport(x, y, viewport)
    x = clamp(x, viewport.left, viewport.right);
    y = clamp(y, viewport.top, viewport.bottom);
    return x,y;
end

class("ViewportPin").extends(gfx.sprite)

function ViewportPin:init(image, viewport, target)
    ViewportPin.super.init(self,image);
    self:setIgnoresDrawOffset(true);

    self.target = target;

    -- adjust viewport by image size to ensure we'll be entirely within it.
    viewport.x += self.width/2;
    viewport.y += self.height/2;
    viewport.width -= self.width;
    viewport.height -= self.height;
    self.viewport = viewport;
end

function ViewportPin:update()
    local targetX, targetY = self.target:getPosition();
    local screenX, screenY = toScreenSpace(targetX, targetY);
    if(self.viewport:containsPoint(screenX, screenY)) then
        self:setVisible(false);
    else
        self:setVisible(true);
        screenX,screenY = pinToViewport(screenX, screenY, self.viewport);
        self:moveTo(screenX,screenY);
    end
end

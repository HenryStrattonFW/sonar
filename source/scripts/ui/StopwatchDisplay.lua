import "CoreLibs/graphics"
import "./scripts/utils/utils";

local gfx <const> = playdate.graphics;

class("StopwatchDisplay").extends(gfx.sprite);

function StopwatchDisplay:init(stopwatch, slices, x, y, w, h)
    StopwatchDisplay.super.init(self);
    self.stopwatch = stopwatch;
    self.panelImage = utils.createNineSliceImage(slices, w, h);
    self.lastUpdatedTime = -1;
    self:setImage(gfx.image.new(w,h));
    self:redraw();
    self:moveTo(x,y);
end

function StopwatchDisplay:update()
    self:redraw();
end

function StopwatchDisplay:redraw()
    local time = math.floor(self.stopwatch.totalSeconds);

    if(time == self.lastUpdatedTime) then return end;

    local prevFont = gfx.getFont();
    local prevDrawMode = gfx.getImageDrawMode();
    local mins = math.floor(time/60);
    local seconds = time - (mins *60);
    local displayString = string.format("%02d",mins)..":"..string.format("%02d",seconds);
    local img = self:getImage();
    gfx.pushContext(img);
    self.panelImage:draw(0,0);
    gfx.setImageDrawMode(gfx.kDrawModeInverted);
    gfx.setFont(Fonts.highlightFont);
    gfx.drawTextAligned(displayString, self.width/2, 3, kTextAlignment.center);
    gfx.popContext();
    self.lastUpdatedTime = time;
    gfx.setImageDrawMode(prevDrawMode);
    gfx.setFont(prevFont);
end
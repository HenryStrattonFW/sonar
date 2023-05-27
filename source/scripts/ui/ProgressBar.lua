import "CoreLibs/graphics"

local pd <const> = playdate;
local gfx <const> = pd.graphics;

class('ProgressBar').extends(gfx.sprite);


function ProgressBar:init(sliceImage, width, height, fillColour, fillInset, showNegative)
    ProgressBar.super.init(self);
    self.width = width;
    self.height = height;
    self.fillColour = fillColour;
    self.showNegative = showNegative;
    self.sliceImage = sliceImage;
    self.fillInset = fillInset;
    self.render = gfx.image.new(width, height);
    self:setValue(0);
end

function ProgressBar:setValue(value)
    local clamped = value;
    if(self.showNegative) then
        clamped = clamp(value, -1, 1);
    else
        clamped = clamp(value, 0, 1);
    end
    if(clamped == self.value) then return end;
    self.value = clamped;
    self:redraw();
end

function ProgressBar:redraw()
    local inset = self.fillInset;
    local fullInset = inset * 2;
    local fullWidth = self.width - fullInset;
    local fillWidth = fullWidth * math.abs(self.value);
    local leftPos = inset;

    if(self.showNegative) then
        leftPos += (fullWidth * 0.5);
        fillWidth *= 0.5;
        if(self.value < 0) then
            leftPos -= fillWidth;
        end
    end

    gfx.pushContext(self.render);
    gfx.setBackgroundColor(gfx.kColorClear);
    gfx.clear();
    gfx.setColor(self.fillColour);

    gfx.fillRect(leftPos, inset, fillWidth, (self.height-fullInset));
    self.sliceImage:drawInRect(0, 0, self.width, self.height);

    gfx.popContext();
    self:setImage(self.render);
    self:markDirty();
end
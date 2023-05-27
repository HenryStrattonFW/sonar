import "CoreLibs/graphics"

local pd <const> = playdate;
local gfx <const> = pd.graphics;

class('ModuleLabel').extends(gfx.sprite);


function ModuleLabel:init(text, drawMode, selected)
    ModuleLabel.super.init(self);
    self.selected = selected or false;
    self.drawMode = drawMode;
    self:setText(text);
end

function ModuleLabel:setSelected(selected)
    if(selected == self.selected) then return end;
    self.selected = selected;
    self:redraw();
end

function ModuleLabel:setText(text)
    if(self.text == text) then return end;
    self.text = text;
    self:redraw();
end

function ModuleLabel:redraw()
    local prevFont = gfx.getFont();
    local prevDrawMode = gfx.getImageDrawMode();    
    gfx.setFont(Fonts.miniSans);
    gfx.setImageDrawMode(self.drawMode);    
    local img = gfx.imageWithText(self.text, gfx.getTextSize(self.text));
    gfx.setImageDrawMode(prevDrawMode);

    local tmp = img:copy();
    tmp:clear(gfx.kColorClear);

    gfx.lockFocus(tmp);
    if(self.selected) then
        img:draw(0, 0);
    else
        img:drawFaded(0, 0, 0.25, gfx.image.kDitherTypeBayer4x4);
    end
    gfx.unlockFocus();

    self:setImage(tmp);
    gfx.setFont(prevFont);
end

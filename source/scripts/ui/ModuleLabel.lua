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

    gfx.setImageDrawMode(self.drawMode);
    if(self.selected) then
        gfx.setFont(Fonts.normalFont);
    else
        gfx.setFont(Fonts.outlinedFont);
    end
    local img = gfx.imageWithText(self.text, gfx.getTextSize(self.text));
    self:setImage(img);

    gfx.setFont(prevFont);
    gfx.setImageDrawMode(prevDrawMode);
end

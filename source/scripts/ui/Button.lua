import "CoreLibs/graphics";
import "./scripts/utils/utils";

local pd <const> = playdate;
local gfx <const> = pd.graphics;

class("Button").extends(gfx.sprite);

function Button:init(text, normalImage, selectedImage, callback)
    Button.super.init(self);
    self.selected = false;
    self.callback = callback;
    self.text = text;
    self.normalImage = normalImage;
    self.selectedImage = selectedImage;
    self:setImage(gfx.image.new(normalImage.width, normalImage.height));
    self:redraw();
end

function Button:setSelected(selected)
    if(self.selected == selected) then return end;
    self.selected = selected;
    self:redraw();
end

function Button:click()
    self.callback();
end

function Button:redraw()
    local prevDrawMode = gfx.getImageDrawMode();
    gfx.pushContext(self:getImage());
    gfx.clear();
    if(self.selected) then
        self.selectedImage:draw(0,0);
    else
        self.normalImage:draw(0,0);
        gfx.setImageDrawMode(gfx.kDrawModeInverted);
    end
    local yPos = (self.height - gfx.getFont():getHeight())/2;
    gfx.drawTextInRect(self.text, 0, yPos, self.width, self.height, nil, "...", kTextAlignment.center);
    gfx.popContext();
    self:markDirty();
    gfx.setImageDrawMode(prevDrawMode);
end
import "CoreLibs/graphics";
import "./scripts/utils/utils";
import "./scripts/ui/Button";

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local padding <const> = 4; -- TODO: This should be configurable.

class("ButtonList").extends(pd.object);

function ButtonList:init(normalButtonImage, selectedButtonImage);
    ButtonList.super.init(self);
    self.buttons = {};
    self.normalImage = normalButtonImage;
    self.selectedImage = selectedButtonImage;
    self.selectedIdx = 0;
end

function ButtonList:moveTo(x,y)
    local buttons = self.buttons;
    local yStep = self.normalImage.height + padding;
    for i=1,#buttons do
        buttons[i]:moveTo(x,y);
        y += yStep;
    end
end

function ButtonList:addButton(text, callback)
    local buttons = self.buttons;
    local newButton = Button(text, self.normalImage, self.selectedImage, callback);
    newButton:add();
    buttons[#buttons+1] = newButton;
    if(#buttons == 1) then self.selectedIdx = 1; end
end

function ButtonList:navigate(delta)
    local buttons = self.buttons;
    local prev = self.selectedIdx;
    local curr = wrap(prev + delta, 1, #buttons+1);
    self.selectedIdx = curr;
    buttons[prev]:setSelected(false);
    buttons[curr]:setSelected(true);
end

function ButtonList:setSelected(index)
    if(self.selectedIdx ~= 0) then
        self.buttons[self.selectedIdx]:setSelected(false);
    end
    self.selectedIdx = index;
    self.buttons[index]:setSelected(true);
end

function ButtonList:clickCurrent()
    if(#self.buttons == 0) then return end;
    self.buttons[self.selectedIdx]:click();
end

function ButtonList:removeButton(text)
    local buttons = self.buttons;
    for i=1,#buttons do
        if(buttons[i].text == text) then
            buttons[i]:remove();
            buttons[i] = nil;
        end
    end
    condenseArray(buttons);
end
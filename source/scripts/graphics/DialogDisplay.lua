import "CoreLibs/graphics";
import "CoreLibs/nineSlice";
import "CoreLibs/animation";

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local blinkTime <const> = 0.5;

local slices = gfx.nineSlice.new("./assets/images/ui/ui_dialog_box", 12, 6, 8, 2);
local chevronImage = gfx.image.new("./assets/images/ui/ui_dialog_chevron");
local chevronOffsetX <const> = (chevronImage.width/2) + 12;
local chevronOffsetY <const> = (chevronImage.height/2);

local function processToLines(text, maxLineChars)
    local lines = {};
    local wordLength = 0;
    local tempLength = 0;
    local tempLine = "";
    for word in string.gmatch(text, "%S+") do
        wordLength = word:len();
        tempLength += wordLength;
        if(tempLength <= maxLineChars) then
            if(tempLine:len() == 0) then
                tempLine = word;
            else
                tempLine = tempLine.." "..word;
                tempLength += 1; -- add 1 for the sapce.
            end
        else
            lines[#lines+1] = tempLine;
            tempLine = word;
            tempLength = word:len();
        end
    end
    if(tempLength > 0) then
        lines[#lines+1] = tempLine;
    end
    return lines;
end

class("DialogDisplay").extends(gfx.sprite)

function DialogDisplay:init(x,y,w,h, padding)
    DialogDisplay.super.init(self);
    self.panelImage = gfx.image.new(w, h);
    self:setPadding(padding,padding,padding,padding);
    self.chevron = gfx.sprite.new(chevronImage);
    self.chevron:moveTo(x + (w-chevronOffsetX), y + (h-chevronOffsetY));

    self:setImage(self.panelImage);
    self:moveTo(x,y);
    self:setVisible(false);
    self:setUpdatesEnabled(false);
    self:setCenter(0,0);
end

function DialogDisplay:setPadding(left, right, top, bottom)
    self.padding = {left, top, right, bottom};
    self:refreshTextRect();
end

function DialogDisplay:refreshTextRect()
    local padding = self.padding;
    self.textRect = pd.geometry.rect.new(
        padding[1],
        padding[2],
        self.panelImage.width - (padding[1] + padding[3]),
        self.panelImage.height - (padding[2] + padding[4])
    );
    self.lineWidth = math.floor(self.textRect.width / Fonts.miniMono:getTextWidth("A")); --mono font, so any character will do.
    self.maxLines = math.floor(self.textRect.height / Fonts.miniMono:getHeight());
end

function DialogDisplay:show(messageArray)
    -- preprocess the messages into sized out lines.
    local msgList = {};
    for i=1,#messageArray do
        msgList[i] = processToLines(messageArray[i], self.lineWidth);
    end
    self.messages = msgList;
    self.msgIndex = 1;
    self.partIndex = 1;
    self:redraw();
    self:setVisible(true);
    self:setUpdatesEnabled(true);
    self.blinker = -1;
    self.chevron:setVisible(true);
end

function DialogDisplay:update()
    -- Avoid immediately progressing if A button was used to trigger the dialog in the first
    if(self.blinker == -1) then 
        self.blinker = 0;
        return;
     end; 

    -- Update the blinking chevron.
    self.blinker += Engine.deltaTime;
    self.chevron:setVisible(self.blinker >= blinkTime);
    if(self.blinker >= blinkTime*2) then
        self.blinker = 0;
    end

    -- Listen for press to move to next part of the message.
    if(pd.buttonJustPressed(pd.kButtonA)) then
        self.partIndex += 1;
        if(self.partIndex > #self.messages[self.msgIndex]) then
            -- next message.
            self.msgIndex += 1;
            self.partIndex  = 1;
            if(self.msgIndex > #self.messages) then
                -- end of messages
                self:setVisible(false);
                self:setUpdatesEnabled(false);
                return;
            end
        end
        self:redraw();
    end
end

function DialogDisplay:redraw()
    gfx.pushContext(self.panelImage);
    gfx.setFont(Fonts.miniMono);
    local textRect = self.textRect;
    slices:drawInRect(0,0,self.width, self.height);
    local currMessage = self.messages[self.msgIndex];
    local text = currMessage[self.partIndex];
    for i=0,self.maxLines do
        self.partIndex += 1;
        if(self.partIndex + i > #currMessage) then break end;
        text = text.." "..currMessage[self.partIndex];
    end
    gfx.setImageDrawMode(gfx.kDrawModeInverted);
    gfx.drawTextInRect(text, textRect.x, textRect.y, textRect.width, textRect.height, nil);
    gfx.popContext();
    self:setImage(self.panelImage);
end
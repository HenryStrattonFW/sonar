import "CoreLibs/graphics";
import "CoreLibs/nineSlice";
import "CoreLibs/animation";

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local blinkTime <const> = 0.5;

local slices = gfx.nineSlice.new("./assets/images/ui/ui_dialog_box", 4, 4, 8, 6);
local chevronImage = gfx.image.new("./assets/images/ui/ui_dialog_chevron");

local function processToLines(text, maxLineChars)
    local lines = {};
    local wordLength = 0;
    local tempLength = 0;
    local tempLine = "";
    local first = true;
    for word in string.gmatch(text, "%S+") do
        wordLength = word:len();
        tempLength += wordLength;
        if(tempLength <= maxLineChars) then
            if(first) then
                first = false;
                tempLine = word;
            else
                tempLine = tempLine.." "..word;
                tempLength += 1; -- add 1 for the sapce between words.
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
    self.textRect = pd.geometry.rect.new(padding, padding, w-(padding*2), h-(padding*2));
    self.lineWidth = math.floor(self.textRect.width / Fonts.miniMono:getTextWidth("A")); --mono font, so any character will do.
    self.maxLines = math.floor(self.textRect.height / Fonts.miniMono:getHeight());
    self.chevron = gfx.sprite.new(chevronImage);
    self.chevron:moveTo(x + (w-chevronImage.width/2), y + (h-chevronImage.height/2));

    self:setImage(self.panelImage);
    self:moveTo(x,y);
    self:setVisible(false);
    self:setUpdatesEnabled(false);
    self:setCenter(0,0);
end

function DialogDisplay:setPadding(left, right, top, bottom)
    self.padding = pd.geometry.rect.new(left,right,top,bottom);
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
    self.shownOnFrame = Engine.frame;
    self.blinker = 0;
    self.chevron:setVisible(true);
end

function DialogDisplay:update()
    if(Engine.frame == self.shownOnFrame) then return end;

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
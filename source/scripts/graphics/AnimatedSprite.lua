import "CoreLibs/graphics";
import "./scripts/utils/utils";

local pd <const> = playdate;
local gfx <const> = pd.graphics;

class("AnimatedSprite").extends(gfx.sprite);

function AnimatedSprite:init(imagetable, framerate)
    AnimatedSprite.super.init(self);
    self.imagetable = imagetable;
    self.framerate = framerate;
    self.tags = {};
    self.frameInterval = 1000 / framerate; -- 1000 as we'll be doing intervals in milliseconds not seconds.
    self.playTime = 0;
    self.currentAnim = nil;
end

function AnimatedSprite:play(startFrame, endFrame, loop, onComplete)
    self.currentAnim = {from = startFrame, to = endFrame, loop = (loop or false), callback = onComplete};
    self:setImage(self.imagetable:getImage(startFrame));
    self:setVisible(true);
    self.playTime = pd.getCurrentTimeMilliseconds();
end

function AnimatedSprite:playAnimation(tag, loop, onComplete)
    local data = self.tags[tag];
    if(data == nil) then 
        print("No Animation With Tag: "..tag);
        return 
    end;
    self.currentAnim = {from = data.from, to = data.to, loop = (loop or false), callback = onComplete};
    self:setImage(self.imagetable:getImage(data.from));
    self:setVisible(true);
    self.playTime = pd.getCurrentTimeMilliseconds();
end

function AnimatedSprite:setAnimation(tag, startFrame, endFrame)
    self.tags[tag] = {
        from = startFrame,
        to = endFrame
    };
end

function AnimatedSprite:clearAnimations()
    self.tags = {};
end

function AnimatedSprite:stop()
    self.currentAnim = nil;
    self:setVisible(false);
end

function AnimatedSprite:update()
    local anim  = self.currentAnim;
    if(anim == nil)then return end;

    local sinceStart = pd.getCurrentTimeMilliseconds() - self.playTime;
    local frame = anim.from + math.floor(sinceStart / self.frameInterval);
    if(frame <= anim.to) then
        self:setImage(self.imagetable:getImage(frame));
        return;
    end
    
    -- Animation has ended. callback if set, then either discard the animation, or reset if looping.
    if(anim.callback ~= nil) then anim.callback(); end;
    if(anim.loop) then
        self.playTime = pd.getCurrentTimeMilliseconds();
    else
        self.currentAnim = nil;
        self:setVisible(false);
    end
end
import "CoreLibs/graphics";
import "./scripts/utils/utils";
import "./scripts/graphics/AnimatedSprite";

local pd <const> = playdate;
local timers <const> = pd.timer;
local gfx <const> = pd.graphics;
local visibleTime <const> = 1500;
local fps <const> = 2;
local seamineImages <const> = gfx.imagetable.new("./assets/images/SeaMine");
local audioSample <const> = pd.sound.sample.new("./assets/audio/ping_short");

class('SeaMine').extends(AnimatedSprite);

function SeaMine:init(id)
    SeaMine.super.init(self, seamineImages, fps);
    self.id = id;
    self:setImage(seamineImages:getImage(1));
    self:setAnimation("fadeOut", 1, 4);
    self:setVisible(false);
    self.audio = pd.sound.sampleplayer.new(audioSample);
end

function SeaMine:pinged()
    if(self:isVisible()) then return end;
    self:stop();
    self:setVisible(true);
    self:setImage(seamineImages:getImage(1));
    timers.performAfterDelay(visibleTime, function()
        self:playAnimation("fadeOut");
    end);
    self.audio:stop();
    self.audio:play(1);
end
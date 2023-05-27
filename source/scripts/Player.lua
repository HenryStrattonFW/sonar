import "CoreLibs/graphics";
import "./scripts/utils/utils";

local pd <const> = playdate;
local gfx <const> = pd.graphics;

local rotSteps <const> = 18;
local moveSpeed <const> = 25;
local turnSpeed <const> = 45;
local sonarOffestDistance <const> = 24;


local createRotationTable = function(image, rotation, count)
    local table = gfx.imagetable.new(count);
    local side = math.max(image.width, image.height);
    local center = side/2;
    local thetaStep = rotation / (count-1);
    for i=1,count do
        local tempImage = gfx.image.new(side,side);
        gfx.pushContext(tempImage);
        image:drawRotated(center, center, -(i-1)*thetaStep);
        gfx.popContext();
        table:setImage(i, tempImage);
    end
    return table;
end



class('Player').extends(gfx.sprite);


function Player:init()
    Player.super.init(self);
    local subImage = gfx.image.new("./assets/images/Submarine");
    self.trueWidth, self.trueHeight = subImage.width, subImage.height;
    self.rotationTable = createRotationTable(subImage, 90, rotSteps);
    self:setImage(self.rotationTable:getImage(1));
    self.rotation = 0;
    self.speed = 0;
end



function Player:update()
    local dt = Engine.deltaTime;
    local rotation = self.rotation;
    local deltaRot = 0;
    if(pd.buttonIsPressed(pd.kButtonLeft))then
        deltaRot = turnSpeed*dt;
    end
    if(pd.buttonIsPressed(pd.kButtonRight))then
        deltaRot = -turnSpeed*dt;
    end

    if(deltaRot ~= 0)then
        rotation = (rotation + deltaRot) % 360;
        self.rotation = rotation;
        self:setImage(self.rotationTable:getImage(self:getFrameForRotation(-rotation)));

        if(rotation >= 270) then
            self:setImageFlip(gfx.kImageFlippedY);
        elseif(rotation >= 180) then
            self:setImageFlip(gfx.kImageFlippedXY);
        elseif(rotation >= 90) then
            self:setImageFlip(gfx.kImageFlippedX);
        else
            self:setImageFlip(gfx.kImageUnflipped);
        end
    end
    
    local moveStep = self.speed * moveSpeed;
    local px,py = self:getPosition();
    if(not approx(moveStep, 0)) then
        local rads = math.rad(rotation);
        px += math.cos(rads) * moveStep * dt;
        py -= math.sin(rads) * moveStep * dt;
    end  
    self:moveTo(px,py);
end

function Player:getFrameForRotation(rotation)
    local totalFrames = #self.rotationTable-1;
    local rotStep = 90 / (totalFrames);
    local tempRotation = rotation % 180;
    return pingpong(round(tempRotation/rotStep),totalFrames)+1;
end

function Player:getSonarOrigin()
    local rads = math.rad(self.rotation);
    return self.x + (math.cos(rads) * sonarOffestDistance), self.y + (-math.sin(rads) * sonarOffestDistance);
end
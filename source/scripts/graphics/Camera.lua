local affine <const> = playdate.geometry.affineTransform;

class('Camera').extends(playdate.object)

function Camera:init(x,y)
    Camera.super.init(self);
    self.sprites = {};
    self.transform = affine.new();
    self:move(x or 0, y or 0);
end

function Camera:moveTo(x,y)
    -- update position, and refresh the transform.
    self.transform:reset();
    self:move(x,y);
end

function Camera:move(x,y)
    -- update the transform itself.
    local transform = self.transform;
    transform:translate(x,y);
    
    -- update all associated sprites positions.
    local sprites = self.sprites;
    local sx,sy;
    for i=1,#sprites do
        sx,sy = sprites[i]:getPosition();
        transform:transformXY(sx,sy);
        sprites[i]:setPosition(sx,sy);
    end
end

function Camera:addSprite(sprite, preTransformed)
    self.sprites[#self.sprites+1] = sprite;
    if(preTransformed == nil) then
        local sx,sy = sprites[i]:getPosition();
        self.transform:transformXY(sx,sy);
        sprite:setPosition(sx,sy);
    end
end

function Camera:removeSprite(sprite)
    for i=1,#self.sprites do
        if self.sprites[i] == sprite then
            self.sprites[i] = nil;
        end
    end
    condenseArray(self.sprites);
end


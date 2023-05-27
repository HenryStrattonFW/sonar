local pd <const> = playdate;
local gfx <const> = pd.graphics;
local point <const> = pd.geometry.point;


utils = {
    randomPointInRect = function(rect)
        return point.new(
            math.random(rect.left, rect.right),
            math.random(rect.top, rect.bottom)
        );
    end,

    prettyTime = function(seconds)
        local seconds = seconds % 60;
        local mins = math.floor(seconds / 60.0);
        if(seconds >= 10) then
            return (tostring(mins)..":"..tostring(seconds));
        else
            return (tostring(mins)..":0"..tostring(seconds));
        end
    end,

    createNineSliceImage=function(nineSlice, w, h, bgColour)
        bgColour = bgColour or gfx.kColorClear;
        local image = gfx.image.new(w, h, bgColour);
        gfx.pushContext(image);
        nineSlice:drawInRect(0,0,w,h);
        gfx.popContext();
        return image;
    end,

    createNineSliceSprite=function(nineSlice, w, h, bgColour)
        return gfx.sprite.new(utils.createNineSliceImage(nineSlice, w,h,bgColour));
    end
};


--
-- Some extensions for the point class to get it to support things that you'd expect (that vectors do)
--
function playdate.geometry.point:scale(scalar)
    self.x *= scalar;
    self.y *= scalar;
end

function playdate.geometry.point:scaled(scalar)
    return point.new(self.x*scalar, self.y*scalar)
end

function playdate.geometry.point:zero()
    self.x = 0;
    self.y = 0;
end

function playdate.geometry.point.getZero()
    return point.new(0,0);
end


--
-- Removes any nil values from the array, and condenses the contents to remove any gaps.
--
function condenseArray(array)
    local j = 1;
    local count = #array;
    for i=1,count do
        if(array[i] ~= nil) then
            if(j<i) then
                array[j] = array[i];
                array[i] = nil;
            end
            j += 1;
        end
    end
end


function clamp(val, min, max)
    return math.min(math.max(val,min),max);
end

function inverseLerp(a,b,x)
	return (x-a)/(b-a);
end

function approx(a,b)
    return (math.abs(a-b) < 0.00001);
end

-- rounds the value to the nearest integer.
function round(a)
	return math.floor(a+0.5);
end

-- returns only the fractional part of the value.
function frac(a) 
	return a - math.floor(a);
end

-- gets the a element of a sequence that ping-pongs between 0 and b forever.
function pingpong(a, b)
	if (b == 0) then
		return 0;
	else
		return round(math.abs(frac((a - b) / (b * 2)) * b * 2 - b));
	end
end

function wrap(x, min, max)
    return (((x - min) % (max - min)) + (max - min)) % (max - min) + min;
end


-- Gets a random position from within a specified rectangle.
function randomInRect(x,y,w,h)    
    return (x + math.random()*w), (y + math.random()*h);
end
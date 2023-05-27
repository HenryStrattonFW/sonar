import "./scripts/utils/utils";

local pd <const> = playdate;

Tickables = {
    allObjects = {},
    lastMs = 0
};

Tickables.update = function()
    local millis = pd.getCurrentTimeMilliseconds();
    local dt = (millis - Tickables.lastMs)/1000;
    Tickables.lastMs = millis;
    local temp = Tickables.allObjects;
    for i = 1,#temp do
        temp[i]:tick(dt);
    end
end

Tickables.add = function(object)
    local temp = Tickables.allObjects;
    for i = 1,#temp do
        if(temp[i] == object) then
            print("Attempted to add a tickable that is already registered.");
            return;
        end
    end
    temp[#temp+1] = object;
end

Tickables.remove = function(object)
    local temp = Tickables.allObjects;
    local j = 1;
    for i = 1,#temp do
        if(temp[i] == object) then
            temp[i] = nil;
        end
    end
    condenseArray(temp);
end
Tickables.removeAll=function()
    local temp = Tickables.allObjects;
    for i = 1,#temp do
        if(temp[i] == object) then
            temp[i] = nil;
        end
    end
    Tickables.allObjects = {};
end
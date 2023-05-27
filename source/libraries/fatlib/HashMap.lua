
local defaultCellSize <const> = 64;

local function coordToKey(x, y)
    return x..y;
end

local function worldCoordToKey(cellSize, x, y)
    return coordToKey(math.floor(x/cellSize),math.floor(y/cellSize));
end

class("HashMap").extends(playdate.object);

function HashMap:init(cellSize)
    HashMap.super.init(self);
    self.cells = {};
    self.cellSize = cellSize or defaultCellSize;
end

function HashMap:debugPrintContents()
    for key, cell in ipairs(self.cells) do
        print("Cell "..key);
        for i=1,#cell do
            print("Item:",cell[i]);
        end
    end
end

-- TODO: extend to support width and height at some point, for now I don't need it.
function HashMap:add(obj, x, y)
    local cells = self.cells;
    local key = worldCoordToKey(self.cellSize, x,y);

    if(cells[key] == nil) then
        cells[key] = {};
    end
    local cell = cells[key];
    cell[#cell+1] = {obj = obj, x = x, y = y};
end

function HashMap:remove(obj)
    local cells = self.cells;
    local tempCell;
    for i=1,#cells do
        tempCell = cells[i];
        local removed = false;
        for j=1,#tempCell do
            if(tempCell[j].obj == obj) then
                tempCell[j] = nil;
                removed = true;
            end
        end
        if(removed) then
            condenseArray(tempCell);
        end
    end
end

function HashMap:clear()
    self.cells = {};
end

function HashMap:forEach(x, y, w, h, callback)
    local cellSize = self.cellSize;
    x = math.floor(x/cellSize);
    y = math.floor(y/cellSize);
    w = math.floor(w/cellSize);
    h = math.floor(h/cellSize);
    for i=x,(x+w) do
        for j=y,(y+h) do
            self:forEachInCell(i,j,callback);
        end
    end
end

function HashMap:forEachInCell(x,y,callback)
    local key = coordToKey(x, y);
    local cell = self.cells[key];
    if(cell == nil) then return end;
    for i=1,#cell do
        callback(cell[i].obj);
    end
end

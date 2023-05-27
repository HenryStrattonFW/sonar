import "CoreLibs/graphics";
import "./scripts/utils/utils";
import "./scripts/graphics/DebugGrid";
import "./scripts/graphics/AnimatedSprite";

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local mineSafeZone <const> = 100;
local debugSpacing <const> = 50;

local playArea = pd.geometry.rect.new(0,0,800,300);
local mineArea = pd.geometry.rect.new(playArea.x + mineSafeZone, playArea.y, playArea.width-(mineSafeZone*2), playArea.height);
local debugGrid;

class('Level').extends(pd.object);

function Level:init()
    Level.super.init();

    --todo: decide on a format and support loading in pre-built levels.
    self.mines = {};
    debugGrid = DebugGrid(playArea.x,
                          playArea.y,
                          (playArea.width/debugSpacing)+1,
                          (playArea.height/debugSpacing)+1,
                          debugSpacing);
    self.goalFlag = AnimatedSprite(gfx.imagetable.new("./assets/images/Flag"), 4);
    self.goalFlag:moveTo(playArea.right - 32, playArea.top + (playArea.height/2));
    self.goalFlag:play(1, 4, true);
    self.goalFlag:add();
end

function Level:spawnRandomMines(count)
    for i=1,count do
        local newMine = SeaMine(i);
        newMine:moveTo(randomInRect(mineArea.x, mineArea.y, mineArea.width, mineArea.height));
        self.mines[i] = newMine;
        newMine:add();
    end
end

function Level:cleanup()
    local mines = self.mines;
    for i=1,#mines do
        mines[i]:remove();
        mines[i] = nil;
    end
    mines = {};
    self.goalFlag:remove();
    debugGrid:cleanup();
end

function Level:clampToPlayArea(x,y)
    return clamp(x, playArea.left, playArea.right), clamp(y, playArea.top, playArea.bottom);
end
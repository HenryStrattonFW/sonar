import "CoreLibs/sprites";
import "CoreLibs/math";
import "CoreLibs/nineSlice";

import "./libraries/fatlib/scene";
import "./libraries/fatlib/HashMap";

import "./scripts/utils/utils";
import "./scripts/utils/Stopwatch";

import "./scripts/ui/ProgressBar";
import "./scripts/ui/ModuleLabel";
import "./scripts/ui/StopwatchDisplay";

import "./scripts/Crankable";
import "./scripts/Player";
import "./scripts/Ping";
import "./scripts/SeaMine";
import "./scripts/PingManager";
import "./scripts/Level";
import "./scripts/graphics/DialogDisplay";

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local geom <const> = pd.geometry;
local screenWidth<const> = 400;
local screenHeight <const> = 240;
local halfScreenWidth <const> = 200;
local halfScreenHeight <const> = 120;
local camOffsetY <const> = -16;


class('GameScene').extends(Scene);

local engineProgress,sonarProgress;
local engineLabel,sonarLabel;
local uiPanelSprite;
local timerPanel;
local sonarCrank;
local engineCrank;
local sonarDecay = 50;
local player;
local playerPing;
local pingManager;
local mineCount = 15;
local level;
local playTimer;
local hash;
local dialog;

function GameScene:init()
    GameScene.super.init(self);

    playTimer = Stopwatch(false);

    -- Build the image/sprite that will act as the panel background for our UI
    local boltPanelSlices = gfx.nineSlice.new("./assets/images/ui/ui_panel_bolted", 9, 9, 6, 6);
    local uiPanelImage = gfx.image.new(screenWidth, 50);
    gfx.pushContext(uiPanelImage);
    boltPanelSlices:drawInRect(0, 0, halfScreenWidth, 50);
    boltPanelSlices:drawInRect(halfScreenWidth, 0, halfScreenWidth, 50);
    gfx.popContext();
    uiPanelSprite = gfx.sprite.new(uiPanelImage);
    uiPanelSprite:setCenter(0,0);
    uiPanelSprite:moveTo(0,screenHeight-50);
    uiPanelSprite:setIgnoresDrawOffset(true);

    local timerBgImage = gfx.nineSlice.new("./assets/images/ui/ui_panel_rounded", 4, 4, 4, 4);
    timerPanel = StopwatchDisplay(playTimer, timerBgImage, halfScreenWidth, 0, 150, 24);
    timerPanel:setCenter(0.5,0);
    timerPanel:setIgnoresDrawOffset(true);

    -- Create the togglable lables for the two modules.
    engineLabel = ModuleLabel("ENGINE", gfx.kDrawModeInverted, true);
    engineLabel:setCenter(0,0);
    engineLabel:moveTo(12, screenHeight-43);
    engineLabel:setIgnoresDrawOffset(true);
    sonarLabel = ModuleLabel("SONAR", gfx.kDrawModeInverted, false);
    sonarLabel:setCenter(0,0);
    sonarLabel:moveTo(halfScreenWidth+12, screenHeight-43);
    sonarLabel:setIgnoresDrawOffset(true);

    -- Create the progress bars for the two modules.
    local progSlice = gfx.nineSlice.new("./assets/images/ui/ui_slider_slice", 2, 2, 2, 2);
    local barWidth = halfScreenWidth-32;
    engineProgress = ProgressBar(progSlice, barWidth, 8, gfx.kColorWhite, 0, true);
    engineProgress:setCenter(0,0);
    engineProgress:moveTo(16, screenHeight-21);
    engineProgress:setIgnoresDrawOffset(true);
    sonarProgress  = ProgressBar(progSlice, barWidth, 8, gfx.kColorWhite, 0, false);
    sonarProgress:setCenter(0,0);
    sonarProgress:moveTo(halfScreenWidth+16, screenHeight-21);
    sonarProgress:setIgnoresDrawOffset(true);

    sonarCrank = Crankable(0, 150.0, 5, false);
    engineCrank = Crankable(-50, 50.0, 1, true);

    -- Setup the player.
    player = Player();
    player:moveTo(50, halfScreenHeight);

    playerPing = Ping();
    pingManager = PingManager();

    dialog = DialogDisplay(0,screenHeight-100, screenWidth, 100, 16);
end

function GameScene:onEnter()
    GameScene.super.onEnter(self);
    
    gfx.setBackgroundColor(gfx.kColorBlack);
    gfx.setColor(gfx.kColorWhite);
    gfx.clear();

    level = Level();
    level:spawnRandomMines(mineCount);

    player:add();

    Tickables.add(pingManager);
    Tickables.add(engineCrank);
    Tickables.add(sonarCrank);
    Tickables.add(playerPing);

    sonarCrank:setEnabled(false);
    engineCrank:setEnabled(true);

    uiPanelSprite:add();
    engineLabel:add();
    sonarLabel:add();
    engineProgress:add();
    sonarProgress:add();
    timerPanel:add();

    hash = HashMap(64);
    local mines = level.mines;
    for _, mine in ipairs(mines) do
        hash:add(mine, mine.x, mine.y, 1,1);
    end

    playTimer:start();

    dialog:add();
    dialog.chevron:add();

    local test = {};
    test[1] = "Le Test";
    test[2] = "Le more test";
    test[3] = "A third test? this is just madness at this point.";
    dialog:show(test);
end

function GameScene:onExit()
    GameScene.super.onExit(self);

    gfx.sprite.removeAll();
    Tickables.removeAll();
    level:cleanup();
    hash.clear();
end

function GameScene:update()
    GameScene.super.update(self);
    
    if(dialog:isVisible()) then return end;

    -- offset the camera so that we focus the palyer in the center of the screen (more or less.)
    gfx.setDrawOffset(halfScreenWidth - player.x, (halfScreenHeight - player.y) + camOffsetY);

    local engineValue = (engineCrank:getValueNormalized()*2)-1;
    local sonarValue = sonarCrank:getValueNormalized();
    sonarProgress:setValue(sonarValue);
    engineProgress:setValue(engineValue);

    -- decay the sonar over time.
    sonarCrank:setValue(sonarCrank:getValue() - (Engine.deltaTime * sonarDecay));
    player.speed = engineValue;

    if (sonarCrank.enabled and pd.buttonJustPressed(pd.kButtonA)) then
        local px,py = player:getSonarOrigin();
        local range = sonarCrank:getValue();
        playerPing:activate(px,py,range);
        sonarCrank:setValue(0);
    end

    --Toggle the active module between engine and sonar.
    if (pd.buttonJustPressed(pd.kButtonB)) then
        sonarCrank:setEnabled(not sonarCrank.enabled);
        sonarLabel:setSelected(sonarCrank.enabled);

        engineCrank:setEnabled(not engineCrank.enabled);
        engineLabel:setSelected(engineCrank.enabled);
    end
    
    -- confine player to the play area.
    player:moveTo(level:clampToPlayArea(player:getPosition()));
end

function GameScene:draw()
    GameScene.super.draw(self);
end

function GameScene:lateDraw()
    gfx.setScreenClipRect(0,0,screenWidth, screenHeight-uiPanelSprite.height);
    playerPing:draw();
    pingManager:draw();

    -- update collisions.
    self:checkCollisions();
end


-- Non-Scene methods used during the various logic of the game scene.
function GameScene:checkCollisions()
    -- Use the hashmap to check collisions between the player and the mines.
    local playerRect = geom.rect.new(0, 0, player.trueWidth, player.trueHeight);
    local playerTransform = geom.affineTransform.new();
    playerTransform:rotate(player.rotation);
    playerTransform:translate(player.trueWidth * 0.5, player.trueHeight * 0.5);
    local dx,dy,mx,my, sqDist;
    hash:forEach(player.x - (player.width/2),
                 player.y - (player.width/2),
                 playerRect.width,
                 playerRect.width,
                 function(mine)
                    mx, my = mine.x, mine.y;
                    -- Then check against the player.
                    dx, dy = mx-player.x, my-player.y;
                    -- check the relative position transformed into the players rotated space.
                    if(playerRect:containsPoint(playerTransform:transformXY(dx,dy))) then
                        -- Collision detected, blow that shit up.
                        self:killPlayer();
                        return;
                     end
                 end
    );

    -- Do general square distance checks for the mines if the ping is active.
    if(playerPing:isActive())then
        local pingSizeSquared = playerPing.radius * playerPing.radius;
        local pingX, pingY = playerPing.x, playerPing.y;
        local mines = level.mines;
        for _, mine in ipairs(mines) do
            mx, my = mine.x, mine.y;
            dx, dy = mx-pingX, my-pingY;
            sqDist = (dx*dx) + (dy*dy);
            if (sqDist <= pingSizeSquared and not playerPing:hasPingedMine(mine.id)) then
                playerPing:pingMine(mine.id);
                pingManager:triggerPing(mx, my, 50);
                mine:pinged();
            end
        end
    end

    -- Check for player against goal flag
    local goal = level.goalFlag;
    if(math.abs(player.x-goal.x) < 16 and math.abs(player.y-goal.y) < 16) then
       self:playerWin(); 
    end
end


function GameScene:killPlayer()
    --print("Time: "..playTimer.totalSeconds);
    --Engine.setScene(Scenes.mainMenu);
end


function GameScene:playerWin()
    --print("Time: "..playTimer.totalSeconds);
    --Engine.setScene(Scenes.mainMenu);
end
import "CoreLibs/sprites";
import "CoreLibs/timer";
import "./scripts/Tickable";

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local sprite <const> = gfx.sprite;

Engine = {
    initialized = false,
    drawFps = true,
    frame = 0
};

Engine.initialize = function(startingScene)
    if(Engine.initialized) then
        print("Engine already initialized.");
        return;
    end
    local millis = pd.getCurrentTimeMilliseconds();
	math.randomseed(millis);
    Engine.lastFrameTimeMs = millis;
    Engine.deltaTime = 0;    
    Engine.initialized = true;
    Engine.setScene(startingScene);
end

Engine.setScene = function(newScene, transitionData)
    if(Engine.currentScene ~= nil) then
         Engine.currentScene:onExit();
    end
    Engine.currentScene = newScene;
    Engine.currentScene:onEnter();
    -- TODO: Later on, revisit and add support for transitions between scenes.
end

Engine.update = function()
    local scene = Engine.currentScene;
    if(scene == nil) then
        return;
    end;
    Engine.frame += 1;
    local millis = pd.getCurrentTimeMilliseconds();
    Engine.deltaTime = (millis - Engine.lastFrameTimeMs)/1000;

    Tickables.update();
    pd.timer.updateTimers();
    
    scene:update();
    scene:draw();
    sprite.update();
    scene:lateUpdate();
    scene:lateDraw();

	if(Engine.drawFps) then pd.drawFPS(0,0) end;

    Engine.lastFrameTimeMs = millis;
end
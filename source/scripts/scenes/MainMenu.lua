import "CoreLibs/sprites";
import "CoreLibs/nineSlice";

import "./libraries/fatlib/scene";

import "./scripts/utils/utils";

import "./scripts/ui/ButtonList";
import "./scripts/ui/progressBar";

import "./scripts/graphics/AnimatedSprite";

local pd <const> = playdate;
local gfx <const> = pd.graphics;
local display <const> = pd.display;
local sprite <const> = gfx.sprite;
local nineSlice <const> = gfx.nineSlice;


local panelSprite;
local logoSprite;
local buttonList;

class('MainMenu').extends(Scene);


function MainMenu:init()
    MainMenu.super.init(self);

    local logoImg = gfx.image.new("./assets/images/ui/logo_banner");
    logoSprite = sprite.new(logoImg);
    logoSprite:moveTo(display.getWidth()/2, logoImg.height/2);

    local boltPanelSlices = nineSlice.new("./assets/images/ui/ui_panel_bolted", 9, 9, 6, 6);
    panelSprite = utils.createNineSliceSprite(boltPanelSlices, display.getWidth(), display.getHeight());
    panelSprite:moveTo(display.getWidth()/2, display.getHeight()/2);

    local normalButtonSlices = nineSlice.new("./assets/images/ui/ui_button_normal",2,2,12,9);
    local selectedButtonSlices = nineSlice.new("./assets/images/ui/ui_button_selected",2,2,12,9);
    local buttonNormal = utils.createNineSliceImage(normalButtonSlices, 150, 32);
    local buttonSelected = utils.createNineSliceImage(selectedButtonSlices, 150, 32);

    buttonList = ButtonList(buttonNormal, buttonSelected);
end


function MainMenu:onEnter()
    MainMenu.super.onEnter(self);
    gfx.setBackgroundColor(gfx.kColorBlack);
    gfx.setColor(gfx.kColorWhite);
    gfx.clear();
    gfx.setDrawOffset(0,0);

    panelSprite:add();
    logoSprite:add();

    buttonList:addButton("Play", function() Engine.setScene(Scenes.gameScene) end);
    buttonList:moveTo(200, 120);
    buttonList:setSelected(1);
end


function MainMenu:onExit()
    MainMenu.super.onExit(self);

    gfx.sprite.removeAll();
    Tickables.removeAll();
end

function MainMenu:update()
    MainMenu.super.update(self);

    if(pd.buttonJustPressed(pd.kButtonUp)) then buttonList:navigate(-1); end
    if(pd.buttonJustPressed(pd.kButtonDown)) then buttonList:navigate(1); end
    if(pd.buttonJustPressed(pd.kButtonA)) then buttonList:clickCurrent(); end
end

function MainMenu:draw()
    MainMenu.super.draw(self);
end
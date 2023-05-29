import "CoreLibs/graphics";
import "CoreLibs/object"

import "./libraries/fatlib/Engine";
import "./libraries/fatlib/Events";
import "./scripts/utils/utils";
import "./scripts/scenes/GameScene";
import "./scripts/scenes/MainMenu";

local gfx <const> = playdate.graphics;
local pd <const> = playdate;
local display <const> = playdate.display;

Fonts = {
	miniSans = gfx.font.new("./assets/font/Mini Sans 2X"),
	miniMono2 = gfx.font.new("./assets/font/Mini Mono 2X"),
	miniMono = gfx.font.new("./assets/font/Mini Mono"),
};

gfx.setFont(Fonts.miniSans);

Scenes = {
	mainMenu = MainMenu(),
	gameScene = GameScene(),
};

pd.display.setRefreshRate(50);
Engine.initialize(Scenes.mainMenu);

function pd.update()
	if(Engine.initialized == false) then
		gfx.clear();
		local sw, sh = display.getSize();
		gfx.drawTextAligned("Engine Not Initialized.",
							sw/2,
							sh/2,
							kTextAlignment.center);
		return;
	end;
	Engine.update();
end
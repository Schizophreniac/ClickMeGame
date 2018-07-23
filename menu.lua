local composer = require( "composer" )
local scene = composer.newScene()

local _width = display.contentWidth
local _height = display.contentHeight

local buttonParameters = {
	fontSize = _width / 18,
	top = ( _width / 20 ) * 2,
	left = _width / 2
}

-- Listeners --
local function gotoGame()
	composer.gotoScene( "game", { time = 800, effect = "crossFade" } )
end

local function gotoHighScores()
	composer.gotoScene( "highscores", { time = 800, effect = "crossFade" } )
end
-----------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view

	local background = display.newRect(
		sceneGroup,
		display.contentCenterX,
		display.contentCenterY,
		_width,
		_height
	)
	background:setFillColor( 0.6, 0.6, 0.6 )

	local playButton = display.newText(
		sceneGroup,
		"Play",
		buttonParameters.left,
		_height / 2,
		native.systemFont,
		buttonParameters.fontSize
	)
	local highScoresButton = display.newText(
		sceneGroup,
		"High Scores",
		buttonParameters.left,
		_height / 2 + buttonParameters.top,
		native.systemFont,
		buttonParameters.fontSize
	)


	playButton:addEventListener( "tap", gotoGame )
	highScoresButton:addEventListener( "tap", gotoHighScores )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
		composer.removeScene( "menu" )
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
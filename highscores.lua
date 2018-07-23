local composer = require( "composer" )
local scene = composer.newScene()

local json = require( "json" )
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )
local scoresTable = {}

local _width = display.contentWidth
local _height = display.contentHeight

-- Loads the scores from JSON file --
local function loadScores()
	local file = io.open( filePath, "r" )

	if ( file ) then
		local contents = file:read( "*a")
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end
-------------------------------------------------------

-- Saves the scores to JSON file
local function saveScores()
	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
	end

	local file = io.open( filePath, "w" )
	if ( file ) then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end
---------------------------------------------------

-- Listener --
local function gotoMenu()
	composer.gotoScene( "menu", { time = 800, effect = "crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()
function scene:create( event )
	print("created")
	local sceneGroup = self.view

	local background = display.newRect(
		sceneGroup,
		display.contentCenterX,
		display.contentCenterY,
		_width,
		_height
	)
	background:setFillColor( 0.6, 0.6, 0.6 )

	loadScores()

	-- Inserting last result and sorting the table with it
	table.insert( scoresTable, composer.getVariable( "finalScore" ) )
	composer.setVariable( "finalScore", 0 )
	local function compare( a, b ) 
		return a > b
	end
	table.sort( scoresTable, compare )

	saveScores()

	local header = display.newText(
		sceneGroup,
		"High Scores",
		_width / 2,
		_height / 6,
		0,
		0,
		native.systemFont,
		_width / 20
	)

	for i = 1, #scoresTable do
		if ( scoresTable[i] ) then
			local number = display.newText(
				sceneGroup,
				"#" .. i,
				_width * ( 2 / 6 ),
				_height / 5 + _height / 20 * i,
				0,
				0, 
				native.systemFont,
				_width / 30
			)
			number.anchorX = 0

			local score = display.newText(
				sceneGroup,
				scoresTable[i],
				_width * ( 4 / 6),
				_height / 5 + _height / 20 * i,
				0,
				0,
				native.systemFont,
				_width / 25
			)
			score.anchorX = 1
		end
	end

	local menuButton = display.newText(
		sceneGroup,
		"back to menu",
		_width / 2,
		_height * ( 5 / 6 ),
		0,
		0,
		native.systemFont,
		_width / 30
	)
	menuButton:addEventListener( "tap", gotoMenu )
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		-- Start the music!
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
		composer.removeScene( "highscores" )
	end
end

-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
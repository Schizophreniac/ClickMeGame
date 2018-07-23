local composer = require( "composer" )
local scene = composer.newScene()

local _width = display.contentWidth
local _height = display.contentHeight

-- The table of levels --
-- Each level has threshold, number of circles, destinations and speed
-- Refer to a current level with "currentLevel" variable
local levels = {
	{
		threshold = 10,
		n = 6,
		dests = 10,
		speed = 0.1
	},
	{
		threshold = 12,
		n = 7,
		dests = 9,
		speed = 0.15
	},
	{
		threshold = 14,
		n = 8,
		dests = 8,
		speed = 0.2
	},
	{
		threshold = 16,
		n = 9,
		dests = 7,
		speed = 0.25
	},
	{
		threshold = 18,
		n = 10,
		dests = 6,
		speed = 0.3
	},
	{
		threshold = 20,
		n = 11,
		dests = 5,
		speed = 0.35
	},
	{
		threshold = 22,
		n = 12,
		dests = 4,
		speed = 0.4
	},
	{
		threshold = 24,
		n = 13,
		dests = 3,
		speed = 0.45
	},
	{
		threshold = 26,
		n = 14,
		dests = 2,
		speed = 0.5
	},
	{
		threshold = 28,
		n = 15,
		dests = 1,
		speed = 0.55
	}
}
local currentLevel = 1
-------------------------

-- Groups --
local backGroup
local mainGroup
local uiGroup
----------------


-- Circles --
local circleRadius = _width / 20

-- Circle colors --
local colors = {
	-- red
	{
		r = 1,
		g = 0,
		b = 0,
		-- name = "red"
	},
	-- green
	{
		r = 0,
		g = 1,
		b = 0,
		-- name = "green"
	},
	-- blue
	{
		r = 0,
		g = 0,
		b = 1,
		-- name = "blue"
	},
	-- yellow
	{
		r = 0.8,
		g = 0.8,
		b = 0.2,
		-- name = "yellow"
	},
	-- lightseagreen
	{
		r = 0,
		g = 0.6,
		b = 0.6,
		-- name = "lightseagreen"
	},
	-- indigo
	{
		r = 0.2,
		g = 0,
		b = 0.4,
		-- name = "indigo"
	},
	-- mediumvioletred
	{
		r = 0.65,
		g = 0.05,
		b = 0.4,
		-- name = "mediumvioletred"
	}
}
---------------------------------------


-- Counters --
local counters = {}
local totalCounter
local counterParametrs = {
	fontSize = _width / 25,
	left = _width / ( #colors + 1 ),
	top = _width / #colors / 2
}
----------------------------------------

local gameLoopTimer

-- Gets a point with random coordinates --
local function getRandomPair()
	local pair = {
		x = math.random( circleRadius, _width - circleRadius ),
		y = math.random( counterParametrs.top * 3, _height - circleRadius )
	}
	return pair
end
------------------------------------------------------------------------------


local gotoNextLevel
local createCircle
local circlesTable = {}
local function circleListener( event ) -- Destroys a circle by touch --
	if ( event.phase == "began" ) then
		display.remove( event.target )
		for i = 1, #circlesTable do
			if ( event.target == circlesTable[i] ) then
				table.remove( circlesTable, i )
				table.insert( circlesTable, createCircle() )
				local id = event.target.colorId
				counters[id].number = counters[id].number + 1
				counters[id].text = counters[id].number
				totalCounter.number = totalCounter.number + 1
				totalCounter.text = totalCounter.number .. " / " .. levels[currentLevel].threshold
				if ( totalCounter.number >= levels[currentLevel].threshold ) then
					gotoNextLevel()
				end
				break
			end
		end
	end
	return true
end
-------------------------------------------------------------------------------------------------


-- Creates a circle and sets its parameters
createCircle = function()
	local randomPair = getRandomPair()
	local circle = display.newCircle( mainGroup, randomPair.x, randomPair.y, circleRadius )

	local colorId = math.random( #colors )
	circle.colorId = colorId
	local randColor = colors[colorId]
	local r = randColor.r
	local g = randColor.g
	local b = randColor.b
	circle:setFillColor( r, g, b )
	circle:setStrokeColor( 1, 1, 1, 0.7 )
	circle.strokeWidth = 3

	circle.isMoving = false
	circle.currentPoint = 1
	circle.points = {}
	-- local numberOfPoints = composer.getVariable( "numberOfDestinations" )
	local numberOfPoints = levels[currentLevel].dests
	for i = 1, numberOfPoints do
		table.insert( circle.points, getRandomPair() )
	end
	circle:addEventListener( "touch", circleListener )

	return circle
end
---------------------------------------------------------


-- Creates circles for current level --
local function createCircles( number )
	for i = 1, number do
		local newCircle = createCircle()
		table.insert( circlesTable, newCircle )
	end
end
-----------------------------------------------


-- Goes to the next levels ans update score --
gotoNextLevel = function()
	currentLevel = currentLevel + 1
	if ( levels[currentLevel] ) then
		for i = 1, #circlesTable do
			display.remove( circlesTable[i] )
			circlesTable[i] = nil
		end
		for i = 1, #counters do
			counters[i].number = 0
		end
		totalCounter.number = 0
		timer.performWithDelay( 2000, createCircles( levels[currentLevel].n ), 0 )
	else
		composer.setVariable( "finalScore", currentLevel - 1 )
		composer.gotoScene( "highscores", { time = 800, effect = "crossFade" } )
	end
end
----------------------------------------------------------------------------------


-- Destroys circle and changes the counter --
local function destroyCircle( index )
	local circle = circlesTable[index]
	display.remove( circle )
	table.remove( circlesTable, index )
	table.insert( circlesTable, createCircle() )
	local id = circle.colorId
	counters[id].number = counters[id].number - 1
	counters[id].text = counters[id].number
	totalCounter.number = totalCounter.number - 1
	totalCounter.text = totalCounter.number .. " / " .. levels[currentLevel].threshold
	if ( totalCounter.number <= -levels[currentLevel].threshold ) then
		composer.setVariable( "finalScore", currentLevel )
		composer.gotoScene( "highscores", { time = 5000, effect = "crossFade" } )
	end
end
------------------------------------------------------------------------------------


-- Moves circle using transition based on speed --
local function moveCircle( index )
	local circle = circlesTable[index]
	local points = circle.points
	local currentP = circle.currentPoint
	if ( circle.isMoving == false ) then
		if ( points[currentP] ) then
			local dx = points[currentP].x - circle.x
			local dy = points[currentP].y - circle.y
			local s = math.sqrt( math.pow( dx, 2 ) + math.pow( dy, 2 ) )
			circle.isMoving = true
			transition.to( circle, {
				x = points[currentP].x,
				y = points[currentP].y,
				time = s / levels[currentLevel].speed,
				onComplete = function()
					circle.isMoving = false
					circle.currentPoint = currentP + 1
				end
			} )
		else
			destroyCircle( index )
		end
	end
end
-------------------------------------------------------------


local function gameLoop()
	for i = 1, #circlesTable do
		moveCircle( i )
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()
function scene:create()

	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert( backGroup )

	mainGroup = display.newGroup()
	sceneGroup:insert( mainGroup )

	uiGroup = display.newGroup()
	sceneGroup:insert( uiGroup )

	local background = display.newRect( backGroup, display.contentCenterX, display.contentCenterY, _width, _height )
	background:setFillColor( 0.6, 0.6, 0.6 )

	local numberOfCircles = levels[currentLevel].n
	createCircles( numberOfCircles )


	-- Initializing counters --
	for i = 1, #colors do
		local counter = display.newText(
			uiGroup,
			0,
			counterParametrs.left * i,
			counterParametrs.top,
			0,
			0,
			native.systemFont,
			counterParametrs.fontSize
		)
		counter:setFillColor( colors[i].r, colors[i].g, colors[i].b )
		counter.number = 0
		table.insert( counters, counter )
	end

	totalCounter = display.newText(
		uiGroup,
		0 .. " / " .. levels[currentLevel].threshold,
		_width / 2,
		counterParametrs.top * 2,
		0,
		0,
		native.systemFont,
		counterParametrs.fontSize * 1.5
	)
	totalCounter.number = 0
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		gameLoopTimer = timer.performWithDelay( 50, gameLoop, 0 )
	end
end

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		timer.cancel( gameLoopTimer )
	elseif ( phase == "did" ) then
		composer.removeScene( "game" )
	end
end

-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view
end
--------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
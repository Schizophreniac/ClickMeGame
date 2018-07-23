local composer = require( "composer" )

display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() )

composer.setVariable( "finalScore", 0 )
composer.setVariable( "v", 0.2 )
composer.setVariable( "numberOfDestinations", 4)
composer.gotoScene( "menu" )
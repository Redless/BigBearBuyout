-- Configuration
function love.conf(t)
	t.title = "Big Bear Buyout" -- The title of the window the game is in (string)
	--t.version = "0.9.1"         -- The LÖVE version this game was made for (string)
	t.window.width = 800
	t.window.height = 8000
	t.window.fullscreen = true

	-- For Windows debugging
	--t.window.icon = 'assets/placedbear.png'
	t.console = false
end

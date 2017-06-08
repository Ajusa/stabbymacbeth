export sti = require "sti"
export Camera = require "camera"
export bump = require 'bump'
export player = x: 100, y: 100, w: 64, h: 64, speed: 100
camera = Camera(player.x, player.y)
playerFilter = (item, other) ->
	if other.isPlayer then return 'cross'
	return "slide"
love.load = ->	
	export world = bump.newWorld!
	export map = sti("data/testmap.lua", {"bump"})
	player.image = love.graphics.newImage("player.png")
	map\bump_init(world)
	world\add(player, player.x, player.y, 64, 64)
	export bulletSpeed = 250
	export bullets = {}
	export dagger = love.graphics.newImage("dagger.png")
love.update = (dt) ->
	
		-- Update world
	map\update(dt)
	if love.keyboard.isDown("a") then player.x, player.y = world\move(player, player.x - player.speed*dt,player.y, playerFilter)
	if love.keyboard.isDown("d") then player.x, player.y = world\move(player, player.x + player.speed*dt,player.y, playerFilter)
	if love.keyboard.isDown("w") then player.x, player.y = world\move(player, player.x, player.y - player.speed*dt, playerFilter)
	if love.keyboard.isDown("s") then player.x, player.y = world\move(player, player.x, player.y + player.speed*dt, playerFilter)
	camera\lockPosition(player.x, player.y)
love.draw = ->
	dt = love.timer.getDelta( )
	camera\attach()
	map\draw()
	for i=#bullets,1,-1 do
		v = bullets[i]
		v.x, v.y, cols = world\move(v, v.x + (v.dx * dt), v.y + (v.dy * dt), (item, other) -> "cross")
		for _, col in ipairs(cols) do 
			if col.other.properties != nil then 
				for k, v in pairs(col.other) do
	   			love.graphics.print(tostring(k), 12, 12)
				if (col.other.properties and col.other.properties.collidable == true) then 
					table.remove(bullets, i)
	for i,v in ipairs(bullets) do love.graphics.draw(dagger, v.x, v.y, v.angle)
	love.graphics.draw(player.image, player.x, player.y)
	--map:bump_draw(world) --this is the debug code for seeing collision boxes
	camera\detach()

love.mousepressed = (x, y, button) ->
	if button == 1
		startX = player.x + 32
		startY = player.y + 32
		mouseX, mouseY = camera\worldCoords(x,y) --this stops the mouse coords from being off from the real coors, cause we have a camera
		angle = math.atan2((mouseY - startY), (mouseX - startX))
		bulletDx = bulletSpeed * math.cos(angle)
		bulletDy = bulletSpeed * math.sin(angle)
		bullet = x: startX, y: startY, dx: bulletDx, dy: bulletDy, isPlayer: true, :angle
		table.insert(bullets, bullet)
		world\add(bullet, bullet.x, bullet.y, 20, 40)
sti = require "sti"
Camera = require "camera"
bump = require 'bump'
love.graphics.setDefaultFilter("nearest")
love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 14))
random = (l, h) -> love.math.random(l, h)
collision = (x1,y1,w1,h1, x2,y2,w2,h2) -> x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
sinceFire = 0
class Entity
  new: (p) => @p = p
  update: (dt) => @p.x, @p.y = @p.x + @p.dx*dt, @p.y + @p.dy*dt
class Dagger extends Entity
	draw: => love.graphics.draw(dagger, @p.x, @p.y, @p.angle)
	update: (dt, i) => 
		@p.distance += ((@p.dx^2) + (@p.dy^2))^(1/2)*dt
		if @p.distance > 400 do table.remove(bullets, i)
		super dt
class Enemy extends Entity
	new: (p) => 
		@p = p
		world\add(self, @p.x, @p.y, 64, 64)
	draw: => love.graphics.draw(enemy, @p.x, @p.y, 0,4,4)
	update: (dt, i) =>
		angle = math.atan2((player.y - @p.y), (player.x - @p.x))
		@p.dx, @p.dy  = @p.speed * math.cos(angle), @p.speed * math.sin(angle)
		@p.x, @p.y = world\move(self,@p.x + @p.dx*dt, @p.y + @p.dy*dt, enemyFilter)
		for i=#bullets,1,-1 do 
			v = bullets[i]
			if collision(v.p.x, v.p.y, 20, 40, @p.x, @p.y, 64, 64) then
				@p.lives -= 1
				table.remove(bullets, i)
		if @p.lives < 1 do 
				world\remove(self)
				table.remove(enemies, i)

export player = x: 100, y: 100, w: 64, h: 64, speed: 100, lives: 5
camera = Camera(player.x, player.y)
playerFilter = (item, other) -> 
	if other.p != nil and other.p.isEnemy
		other.p.lives = 0
		item.lives -= 1
		return "cross"
	return "slide"
export enemyFilter = (item, other) -> if other.p != nil and other.p.isEnemy then false else "slide"
love.load = ->	
	export world = bump.newWorld!
	export map = sti("data/testmap.lua", {"bump"})
	player.image = love.graphics.newImage("player.png")
	map\bump_init(world)
	world\add(player, player.x, player.y, 64, 64)
	export enemies = for i = 1, 40 do Enemy x: random(256, (map.width-2)*64), y: random(256, (map.height-2)*64), lives: 5, isEnemy: true, speed: 30
	export bulletSpeed = 250
	export bullets = {}
	export dagger = love.graphics.newImage("dagger.png")
	export enemy = love.graphics.newImage("enemy.png")
love.update = (dt) ->
		-- Update world
	map\update(dt)
	sinceFire += dt
	if love.keyboard.isDown("a") then player.x, player.y = world\move(player, player.x - player.speed*dt,player.y, playerFilter)
	if love.keyboard.isDown("d") then player.x, player.y = world\move(player, player.x + player.speed*dt,player.y, playerFilter)
	if love.keyboard.isDown("w") then player.x, player.y = world\move(player, player.x, player.y - player.speed*dt, playerFilter)
	if love.keyboard.isDown("s") then player.x, player.y = world\move(player, player.x, player.y + player.speed*dt, playerFilter)
	for i=#bullets,1,-1 do bullets[i]\update(dt,i)
	for i=#enemies,1,-1 do enemies[i]\update(dt,i)
	camera\lockPosition(player.x, player.y)
love.draw = ->
	camera\attach()
	map\draw()
	sx, sy = camera\worldCoords(12,12)
	love.graphics.print(player.lives, sx, sy)
	for i,v in ipairs(bullets) do v\draw!
	for i,v in ipairs(enemies) do v\draw!
	love.graphics.draw(player.image, player.x, player.y, 0, 4, 4)
	--map\bump_draw(world) --this is the debug code for seeing collision boxes
	camera\detach()

love.mousepressed = (x, y, button) ->
	if button == 1 and sinceFire > .3
		sinceFire = 0
		startX = player.x + 32
		startY = player.y + 32
		mouseX, mouseY = camera\worldCoords(x,y) --this stops the mouse coords from being off from the real coors, cause we have a camera
		angle = math.atan2((mouseY - startY), (mouseX - startX))
		dx, dy  = bulletSpeed * math.cos(angle), bulletSpeed * math.sin(angle)
		bullet = Dagger x: startX, y: startY, :dx, :dy, :angle, distance: 0
		table.insert(bullets, bullet)
		--world\add(bullet, bullet.p.x, bullet.p.y, 20, 40)
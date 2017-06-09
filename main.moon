sti = require "sti"
Camera = require "camera"
bump = require 'bump'
love.graphics.setDefaultFilter("nearest")
love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 14))
love.window.setFullscreen(true)
random = (l, h) -> love.math.random(l, h)
collision = (x1,y1,w1,h1, x2,y2,w2,h2) -> x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
playerFilter = (item, other) -> if other.p != nil and other.p.isEnemy then "cross" else "slide"
enemyFilter = (item, other) -> if other.p != nil and (other.p.isEnemy or other.p.speed == 100) then false else "slide"
sinceFire = 0
score = 0
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
		@p.speed += dt
		angle = math.atan2((player.p.y - @p.y), (player.p.x - @p.x))
		@p.dx, @p.dy  = @p.speed * math.cos(angle), @p.speed * math.sin(angle)
		@p.x, @p.y = world\move(self,@p.x + @p.dx*dt, @p.y + @p.dy*dt, enemyFilter)
		for i=#bullets,1,-1 do if collision(bullets[i].p.x, bullets[i].p.y, 20, 40, @p.x, @p.y, 64, 64) then
				@p.lives -= 1
				score += 1
				table.remove(bullets, i)
		if @p.lives < 1 do 
				world\remove(self)
				score += 5
				table.remove(enemies, i)
class Player extends Entity
	new: (p) => 
		@p = p
		world\add(self, @p.x, @p.y, 64, 64)
	draw: => love.graphics.draw(@p.image, @p.x, @p.y, 0,4,4)
	update: (dt) =>
		for i=#enemies,1,-1 do if collision(enemies[i].p.x + 8, enemies[i].p.y + 8, 48, 48, @p.x, @p.y, 64, 64) -- the 8's are for a smaller hitbox
				@p.lives -= 1
				table.remove(enemies, i)
love.load = ->	
	export world = bump.newWorld!
	export map = sti("data/testmap.lua", {"bump"})
	export player = Player x: 43*64, y: 6*64, w: 64, h: 64, speed: 100, lives: 5, image: love.graphics.newImage("player.png")
	export camera = Camera(player.p.x, player.p.y)
	map\bump_init(world)
	export enemies = for i = 1, 40 do Enemy x: random(0, (32)*64), y: random(0, (map.height-2)*64), lives: 5, isEnemy: true, speed: 30
	export bulletSpeed = 250
	export bullets = {}
	export dagger = love.graphics.newImage("dagger.png")
	export enemy = love.graphics.newImage("enemy.png")
love.update = (dt) ->
	if player.p.lives > 0
		-- Update world
		map\update(dt)
		sinceFire += dt
		if love.keyboard.isDown("a") then player.p.x, player.p.y = world\move(player, player.p.x - player.p.speed*dt,player.p.y, playerFilter)
		if love.keyboard.isDown("d") then player.p.x, player.p.y = world\move(player, player.p.x + player.p.speed*dt,player.p.y, playerFilter)
		if love.keyboard.isDown("w") then player.p.x, player.p.y = world\move(player, player.p.x, player.p.y - player.p.speed*dt, playerFilter)
		if love.keyboard.isDown("s") then player.p.x, player.p.y = world\move(player, player.p.x, player.p.y + player.p.speed*dt, playerFilter)
		for i=#bullets,1,-1 do bullets[i]\update(dt,i)
		for i=#enemies,1,-1 do enemies[i]\update(dt,i)
		player\update(dt)
		camera\lockPosition(player.p.x, player.p.y)
love.draw = ->
	if player.p.lives > 0
		camera\attach()
		map\draw()
		for i,v in ipairs(bullets) do v\draw!
		for i,v in ipairs(enemies) do v\draw!
		player\draw!
		--map\bump_draw(world) --this is the debug code for seeing collision boxes
		camera\detach()
		love.graphics.setColor(255, 0, 0, score)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth!, love.graphics.getHeight!)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("Lives: "..player.p.lives, 12, 12)
		love.graphics.print("Score: "..score, 100, 12)
	else 
		love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 30))
		love.graphics.print("GAME OVER MACBETH!", love.graphics.getWidth!/4, love.graphics.getHeight!/2)
		love.graphics.print("Score: ".. score, love.graphics.getWidth!/4, love.graphics.getHeight!/1.5)
love.mousepressed = (x, y, button) ->
	if button == 1 and sinceFire > .3
		sinceFire = 0
		startX, startY = player.p.x + 32, player.p.y + 32
		mouseX, mouseY = camera\worldCoords(x,y) --this stops the mouse coords from being off from the real coors, cause we have a camera
		angle = math.atan2((mouseY - startY), (mouseX - startX))
		dx, dy = bulletSpeed * math.cos(angle), bulletSpeed * math.sin(angle)
		table.insert(bullets, Dagger x: startX, y: startY, :dx, :dy, :angle, distance: 0)
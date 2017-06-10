local sti = require("sti")
local Camera = require("camera")
local bump = require('bump')
love.graphics.setDefaultFilter("nearest")
love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 16))
love.window.setFullscreen(true)
local random
random = function(l, h)
  return love.math.random(l, h)
end
local collision
collision = function(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end
local playerFilter
playerFilter = function(item, other)
  if other.p ~= nil and other.p.isEnemy then
    return "cross"
  else
    return "slide"
  end
end
local enemyFilter
enemyFilter = function(item, other)
  if other.p ~= nil and (other.p.isEnemy or other.p.speed == 100) then
    return false
  else
    return "slide"
  end
end
local sinceFire = 0
local score = 0
local enemies = { }
local Entity
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      self.p.x, self.p.y = self.p.x + self.p.dx * dt, self.p.y + self.p.dy * dt
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, p)
      self.p = p
    end,
    __base = _base_0,
    __name = "Entity"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Entity = _class_0
end
local Dagger
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    draw = function(self)
      return love.graphics.draw(dagger, self.p.x, self.p.y, self.p.angle)
    end,
    update = function(self, dt, i)
      self.p.distance = self.p.distance + (((self.p.dx ^ 2) + (self.p.dy ^ 2)) ^ (1 / 2) * dt)
      if self.p.distance > 400 then
        do
          table.remove(bullets, i)
        end
      end
      return _class_0.__parent.__base.update(self, dt)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Dagger",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Dagger = _class_0
end
local Enemy
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    draw = function(self)
      return love.graphics.draw(enemy, self.p.x, self.p.y, 0, 4, 4)
    end,
    update = function(self, dt, i)
      self.p.speed = self.p.speed + dt
      local angle = math.atan2((player.p.y - self.p.y), (player.p.x - self.p.x))
      self.p.dx, self.p.dy = self.p.speed * math.cos(angle), self.p.speed * math.sin(angle)
      self.p.x, self.p.y = world:move(self, self.p.x + self.p.dx * dt, self.p.y + self.p.dy * dt, enemyFilter)
      for i = #bullets, 1, -1 do
        if collision(bullets[i].p.x, bullets[i].p.y, 20, 40, self.p.x, self.p.y, 64, 64) then
          self.p.lives = self.p.lives - 1
          score = score + 1
          table.remove(bullets, i)
        end
      end
      if self.p.lives < 1 then
        do
          world:remove(self)
          score = score + 5
          return table.remove(enemies, i)
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, p)
      self.p = p
      return world:add(self, self.p.x + 8, self.p.y + 8, 48, 48)
    end,
    __base = _base_0,
    __name = "Enemy",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Enemy = _class_0
end
local Macduff
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    update = function(self, dt)
      self.p.speed = self.p.speed + dt
      local angle = math.atan2((player.p.y - self.p.y), (player.p.x - self.p.x))
      self.p.dx, self.p.dy = self.p.speed * math.cos(angle), self.p.speed * math.sin(angle)
      _class_0.__parent.__base.update(self, dt)
      if collision(self.p.x, self.p.y, 64, 64, player.p.x, player.p.y, 64, 64) then
        player.p.lives = 0
      end
    end,
    draw = function(self)
      return love.graphics.draw(self.p.image, self.p.x, self.p.y, 0, 4, 4)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Macduff",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Macduff = _class_0
end
local Player
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    draw = function(self)
      return love.graphics.draw(self.p.image, self.p.x, self.p.y, 0, 4, 4)
    end,
    update = function(self, dt)
      if love.keyboard.isDown("a") then
        self.p.x, self.p.y = world:move(self, self.p.x - self.p.speed * dt, self.p.y, playerFilter)
      end
      if love.keyboard.isDown("d") then
        self.p.x, self.p.y = world:move(self, self.p.x + self.p.speed * dt, self.p.y, playerFilter)
      end
      if love.keyboard.isDown("w") then
        self.p.x, self.p.y = world:move(self, self.p.x, self.p.y - self.p.speed * dt, playerFilter)
      end
      if love.keyboard.isDown("s") then
        self.p.x, self.p.y = world:move(self, self.p.x, self.p.y + self.p.speed * dt, playerFilter)
      end
      for i = #enemies, 1, -1 do
        if collision(enemies[i].p.x + 8, enemies[i].p.y + 8, 48, 48, self.p.x, self.p.y, 64, 64) then
          self.p.lives = self.p.lives - 1
          table.remove(enemies, i)
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Player",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Player = _class_0
end
local BaseState
do
  local _class_0
  local _base_0 = {
    draw = function(self)
      map:draw()
      for i, v in ipairs(bullets) do
        v:draw()
      end
      return player:draw()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      map:bump_init(world)
      return world:add(player, player.p.x + 8, player.p.y + 8, 48, 48)
    end,
    __base = _base_0,
    __name = "BaseState"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  BaseState = _class_0
end
local MainGame
do
  local _class_0
  local _parent_0 = BaseState
  local _base_0 = {
    update = function(self, dt)
      if score > 100 then
        macduff:update(dt)
      end
      for i = #enemies, 1, -1 do
        enemies[i]:update(dt, i)
      end
      player:update(dt)
      if love.keyboard.isDown("return") then
        STATE = MainGame()
      end
    end,
    draw = function(self)
      _class_0.__parent.__base.draw(self)
      for i, v in ipairs(enemies) do
        v:draw()
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      world = bump.newWorld()
      map = sti("data/testmap.lua", {
        "bump"
      })
      player.p.x, player.p.y, player.p.lives, score = 43 * 64, 4 * 64, 5, 0
      love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 16))
      _class_0.__parent.__init(self)
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, 40 do
          _accum_0[_len_0] = Enemy({
            x = random(64 * (2), (32) * 64),
            y = random(64 * (2), (map.height - 2) * 64),
            lives = 5,
            isEnemy = true,
            speed = 30
          })
          _len_0 = _len_0 + 1
        end
        enemies = _accum_0
      end
      macduff = Macduff({
        x = 128,
        y = 20 * 64,
        speed = 90,
        image = love.graphics.newImage("macduff.png")
      })
    end,
    __base = _base_0,
    __name = "MainGame",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  MainGame = _class_0
end
local BeforeFight
do
  local _class_0
  local _parent_0 = BaseState
  local _base_0 = {
    update = function(self, dt)
      self.temp = self.temp + dt
      if collision(player.p.x, player.p.y, 64, 64, 9 * 64, 24 * 64, 128, 64) then
        STATE = MainGame()
      end
      if self.temp > 25 then
        return player:update(dt)
      end
    end,
    draw = function(self, dt)
      _class_0.__parent.__base.draw(self)
      return love.graphics.draw(self.messenger, 10 * 64, 5 * 64, 0, 4, 4)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      world = bump.newWorld()
      map = sti("data/castle.lua", {
        "bump"
      })
      player.p.x, player.p.y = (10) * 64, (3) * 64
      _class_0.__parent.__init(self)
      love.audio.newSource("beforegame.ogg"):play()
      self.messenger = love.graphics.newImage("messenger.png")
      self.temp = 0
    end,
    __base = _base_0,
    __name = "BeforeFight",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  BeforeFight = _class_0
end
local Castle
do
  local _class_0
  local _parent_0 = BaseState
  local _base_0 = {
    update = function(self, dt)
      player:update(dt)
      for i, v in ipairs(bullets) do
        if collision(v.p.x, v.p.y, 20, 40, 10 * 64, 3 * 64, 64, 64) then
          self.temp = true
          self.duncan = love.graphics.newImage("duncandead.png")
        end
      end
      if self.temp then
        self.time = self.time + dt
      end
      if self.time > 5 then
        STATE = BeforeFight()
      end
    end,
    draw = function(self)
      _class_0.__parent.__base.draw(self)
      if self.temp then
        love.graphics.print("Macbeth becomes king, and soon Malcolm is leading an army against him.", player.p.x - 30, player.p.y - 30)
      end
      return love.graphics.draw(self.duncan, 10 * 64, 3 * 64, 0, 4, 4)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      world = bump.newWorld()
      map = sti("data/castle.lua", {
        "bump"
      })
      player.p.x, player.p.y = (17) * 64, (15) * 64
      self.duncan = love.graphics.newImage("duncan.png")
      self.temp = false
      self.time = 0
      return _class_0.__parent.__init(self)
    end,
    __base = _base_0,
    __name = "Castle",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Castle = _class_0
end
love.load = function()
  player = Player({
    x = 43 * 64,
    y = 6 * 64,
    w = 64,
    h = 64,
    speed = 150,
    lives = 5,
    image = love.graphics.newImage("player.png")
  })
  STATE = Castle()
  camera = Camera(player.p.x, player.p.y)
  bullets = { }
  dagger = love.graphics.newImage("dagger.png")
  enemy = love.graphics.newImage("enemy.png")
end
love.update = function(dt)
  STATE:update(dt)
  if player.p.lives > 0 then
    map:update(dt)
    sinceFire = sinceFire + dt
    for i = #bullets, 1, -1 do
      bullets[i]:update(dt, i)
    end
    return camera:lockPosition(player.p.x, player.p.y)
  end
end
love.draw = function()
  if player.p.lives > 0 then
    camera:attach()
    STATE:draw()
    if score > 110 then
      macduff:draw()
    end
    camera:detach()
    love.graphics.setColor(255, 0, 0, score)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("Lives: " .. player.p.lives, 12, 12)
    return love.graphics.print("Score: " .. score, 100, 12)
  else
    love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 30))
    love.graphics.print("GAME OVER MACBETH!", love.graphics.getWidth() / 4, love.graphics.getHeight() / 2)
    love.graphics.print("Score: " .. score, love.graphics.getWidth() / 4, love.graphics.getHeight() / 1.5)
    return love.graphics.print("Hit enter to play again ", love.graphics.getWidth() / 4, love.graphics.getHeight() / 1.2)
  end
end
love.mousepressed = function(x, y, button)
  if button == 1 and sinceFire > .3 then
    sinceFire = 0
    local startX, startY = player.p.x + 32, player.p.y + 32
    local mouseX, mouseY = camera:worldCoords(x, y)
    local angle = math.atan2((mouseY - startY), (mouseX - startX))
    local dx, dy = 250 * math.cos(angle), 250 * math.sin(angle)
    return table.insert(bullets, Dagger({
      x = startX,
      y = startY,
      dx = dx,
      dy = dy,
      angle = angle,
      distance = 0
    }))
  end
end

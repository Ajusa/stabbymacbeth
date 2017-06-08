local sti = require("sti")
local Camera = require("camera")
local bump = require('bump')
love.graphics.setDefaultFilter("nearest")
love.graphics.setFont(love.graphics.newFont("kenpixel.ttf", 14))
local random
random = function(l, h)
  return love.math.random(l, h)
end
local collision
collision = function(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end
local sinceFire = 0
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
      local angle = math.atan2((player.y - self.p.y), (player.x - self.p.x))
      self.p.dx, self.p.dy = self.p.speed * math.cos(angle), self.p.speed * math.sin(angle)
      self.p.x, self.p.y = world:move(self, self.p.x + self.p.dx * dt, self.p.y + self.p.dy * dt, enemyFilter)
      for i = #bullets, 1, -1 do
        local v = bullets[i]
        if collision(v.p.x, v.p.y, 20, 40, self.p.x, self.p.y, 64, 64) then
          self.p.lives = self.p.lives - 1
          table.remove(bullets, i)
        end
      end
      if self.p.lives < 1 then
        do
          world:remove(self)
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
      return world:add(self, self.p.x, self.p.y, 64, 64)
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
player = {
  x = 100,
  y = 100,
  w = 64,
  h = 64,
  speed = 100,
  lives = 5
}
local camera = Camera(player.x, player.y)
local playerFilter
playerFilter = function(item, other)
  if other.p ~= nil and other.p.isEnemy then
    other.p.lives = 0
    item.lives = item.lives - 1
    return "cross"
  end
  return "slide"
end
enemyFilter = function(item, other)
  if other.p ~= nil and other.p.isEnemy then
    return false
  else
    return "slide"
  end
end
love.load = function()
  world = bump.newWorld()
  map = sti("data/testmap.lua", {
    "bump"
  })
  player.image = love.graphics.newImage("player.png")
  map:bump_init(world)
  world:add(player, player.x, player.y, 64, 64)
  do
    local _accum_0 = { }
    local _len_0 = 1
    for i = 1, 40 do
      _accum_0[_len_0] = Enemy({
        x = random(256, (map.width - 2) * 64),
        y = random(256, (map.height - 2) * 64),
        lives = 5,
        isEnemy = true,
        speed = 30
      })
      _len_0 = _len_0 + 1
    end
    enemies = _accum_0
  end
  bulletSpeed = 250
  bullets = { }
  dagger = love.graphics.newImage("dagger.png")
  enemy = love.graphics.newImage("enemy.png")
end
love.update = function(dt)
  map:update(dt)
  sinceFire = sinceFire + dt
  if love.keyboard.isDown("a") then
    player.x, player.y = world:move(player, player.x - player.speed * dt, player.y, playerFilter)
  end
  if love.keyboard.isDown("d") then
    player.x, player.y = world:move(player, player.x + player.speed * dt, player.y, playerFilter)
  end
  if love.keyboard.isDown("w") then
    player.x, player.y = world:move(player, player.x, player.y - player.speed * dt, playerFilter)
  end
  if love.keyboard.isDown("s") then
    player.x, player.y = world:move(player, player.x, player.y + player.speed * dt, playerFilter)
  end
  for i = #bullets, 1, -1 do
    bullets[i]:update(dt, i)
  end
  for i = #enemies, 1, -1 do
    enemies[i]:update(dt, i)
  end
  return camera:lockPosition(player.x, player.y)
end
love.draw = function()
  camera:attach()
  map:draw()
  local sx, sy = camera:worldCoords(12, 12)
  love.graphics.print(player.lives, sx, sy)
  for i, v in ipairs(bullets) do
    v:draw()
  end
  for i, v in ipairs(enemies) do
    v:draw()
  end
  love.graphics.draw(player.image, player.x, player.y, 0, 4, 4)
  return camera:detach()
end
love.mousepressed = function(x, y, button)
  if button == 1 and sinceFire > .3 then
    sinceFire = 0
    local startX = player.x + 32
    local startY = player.y + 32
    local mouseX, mouseY = camera:worldCoords(x, y)
    local angle = math.atan2((mouseY - startY), (mouseX - startX))
    local dx, dy = bulletSpeed * math.cos(angle), bulletSpeed * math.sin(angle)
    local bullet = Dagger({
      x = startX,
      y = startY,
      dx = dx,
      dy = dy,
      angle = angle,
      distance = 0
    })
    return table.insert(bullets, bullet)
  end
end

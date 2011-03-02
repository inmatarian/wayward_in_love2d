
local util = require 'util'
local prototype = require 'prototype'

----------------------------------------


local dirs = { "up", "down", "left", "right" }
function testBehavior( self, dt )
  self.clock = (self.clock or 0) + dt

  if self.clock >= 3 then
    self.clock = self.clock - 3
    local t = math.random(1, 4)
    self.dir = dirs[t]
  else
    self.dir = nil
  end
end

----------------------------------------

local Sprite = prototype:clone {
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  gid = 1,
  dir = nil,
  moving = nil,
  excess = 0,
  speed = 64,
  layer = nil
}

function Sprite:init( x, y )
  if type(x)=="table" then
    self.x = x.x
    self.y = x.y
    self.w = x.w
    self.h = x.h
    self.gid = x.gid
    if x.type == "PLAYER" then
      print("PLAYER FOUND!")
      self.behavior = testBehavior
    end
  elseif x or y then
    self.x = x
    self.y = y
    self.w = 16
    self.h = 16
  end
end

function Sprite:setLayer( l )
  self.layer = l
end

function Sprite:isBlocked( dir )
  if not self.layer then return false end

  local cx, cy = self.layer:convToLayer( self.x, self.y )

  if dir == "up" then cy = cy - 1
  elseif dir == "down" then cy = cy + 1
  elseif dir == "left" then cx = cx - 1
  elseif dir == "right" then cx = cx + 1
  end

  return self.layer:isSolid( cx, cy )
end

function Sprite:otherSprite( dir )
  local cx, cy = self.layer:convToLayer( self.x, self.y )
  if dir == "up" then cy = cy - 1
  elseif dir == "down" then cy = cy + 1
  elseif dir == "left" then cx = cx - 1
  elseif dir == "right" then cx = cx + 1
  end

  return self.layer:spriteAt( cx, cy )
end

function Sprite:update(dt)
  local oldx, oldy, oldw, oldh = self.x, self.y, self.w, self.h

  if self.behavior then self:behavior(dt) end

  local speed = self.speed * dt
  local excess = self.excess
  self.excess = 0
  local inmove = self.moving~=nil
  if (not inmove) and self.dir~=nil then
    if self:isBlocked(self.dir) then return end
    if self:otherSprite(self.dir) then return end
  end
  self.moving = self.moving or self.dir

  if self.moving=="up" then
    local ny = self.y - speed - excess
    local bar = math.floor(self.y/16)*16
    if ny < bar and inmove then
      self.excess = bar - ny
      ny = bar
      self.moving = nil
    end
    self.y = ny

  elseif self.moving=="down" then
    local ny = self.y + speed + excess
    local bar = math.ceil(self.y/16)*16
    if ny > bar and inmove then
      self.excess = ny - bar
      ny = bar
      self.moving = nil
    end
    self.y = ny

  elseif self.moving=="left" then
    local nx = self.x - speed - excess
    local bar = math.floor(self.x/16)*16
    if nx < bar and inmove then
      self.excess = bar - nx
      nx = bar
      self.moving = nil
    end
    self.x = nx

  elseif self.moving=="right" then
    local nx = self.x + speed + excess
    local bar = math.ceil(self.x/16)*16
    if nx > bar and inmove then
      self.excess = nx - bar
      nx = bar
      self.moving = nil
    end
    self.x = nx
  end

  self.layer:updateHash( self, oldx, oldy, oldw, oldh )
end

function Sprite:draw( camera )
  camera:drawTile( self.x, self.y, self.gid )
end

function Sprite.gameLoadSprites( layername, layerprops, objects )
  print( "loadObjects: "..layername )
  print( "  objects:" )
  util.print_r( objects, "    " )
  print( "  properties:" )
  util.print_r( layerprops, "    " )

  local sprites = {}

  for i, v in ipairs( objects ) do
    local spr = Sprite:new( v )
    sprites[i] = spr
  end

  return sprites
end

return Sprite

----------------------------------------


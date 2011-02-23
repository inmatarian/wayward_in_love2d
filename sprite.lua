
local util = require 'util'
local prototype = require 'prototype'
local friend = require 'friend'

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
  speed = 64
}

function Sprite:init( x, y )
  if type(x)=="table" then
    self.x = x.x
    self.y = x.y
    self.w = x.w
    self.h = x.h
    self.gid = x.gid
  elseif x or y then
    self.x = x
    self.y = y
  end
end

function Sprite:update(dt)
  local speed = self.speed * dt
  local excess = self.excess
  self.excess = 0
  local inmove = self.moving~=nil and true or false
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


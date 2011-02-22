
local util = require 'util'
local prototype = require 'prototype'
local tmx = require 'tmx'
local friend = require 'friend'

----------------------------------------

local Tileset = prototype:clone()

function Tileset:drawTile( x, y, index )
  love.graphics.drawq( self.image, self.quads[index], x, y )
end

function Tileset.gameLoadTileset( name, filename, width, height, firstgid, tilewidth, tileheight, properties )
  print( "loadTileset: "..name )
  print( "  filename: "..filename ) 
  print( "  size: "..width.." x "..height )
  print( "  firstgid: "..firstgid )
  print( "  tilesize: "..tilewidth.." x "..tileheight )
  print( "  properties:" )
  util.print_r( properties, "    " )

  local tileimage = love.graphics.newImage( filename )
  tileimage:setFilter("nearest", "nearest")
  local sw = tileimage:getWidth()
  local sh = tileimage:getHeight()
  local quads = {}
  local y = 0
  local i = firstgid
  while y < sh do
    local x = 0
    while x < sw do
      local quad = love.graphics.newQuad( x, y, 16, 16, sw, sh )
      quads[i] = quad
      i = i + 1
      x = x + tilewidth
    end
    y = y + tileheight
  end

  local tileset = Tileset:clone()
  tileset.image = tileimage
  tileset.quads = quads
  return tileset
end

----------------------------------------

local Camera = prototype:clone( { x = 0, y = 0 } )

function Camera:translate( x, y )
  self.x, self.y = self.x + x, self.y + y
end

function Camera:drawTile( x, y, index )
  self.tileset:drawTile( x - self.x, y - self.y, index )
end

function Camera:reset()
  self.x, self.y = Camera.x, Camera.y
end

----------------------------------------

local Layer = prototype:clone( { sx = 0, sy = 0 } )

function Layer:get( x, y )
  if x < 1 or y < 1 or x > self.width or y > self.height then
    return 0
  end
  return self[ 1 + ( (y-1) * self.width ) + (x-1) ]
end

function Layer:set( x, y, t )
  if x >= 1 or y >= 1 or x <= self.width or y <= self.height then
    self[ 1 + ( (y-1) * self.width ) + (x-1) ] = t
  end
end

function Layer:draw( tileset )
  local tw, th = 16, 16
  local sx, sy = math.floor(self.sx / tw), math.floor(self.sy / th)
  local ox, oy = self.sx - (sx*tw), self.sy - (sy*th)
  for y = 0, 15 do
    for x = 0, 20 do
      local item = self:get( x+1+sx, y+1+sy )
      if item > 0 then
        tileset:drawTile( x*tw-ox, y*th-oy, item )
      end
    end
  end
end

function Layer:scroll( dx, dy )
  self.sx = self.sx + dx
  self.sy = self.sy + dy
end

function Layer:centerOn( sprite )
  self.sx = sprite.x - 152
  self.sy = sprite.y - 112
end

function Layer.gameLoadLayer( name, width, height, data, props )
  print( "loadLayer: "..name )
  print( "  size: "..width.." x "..height )
  print( "  properties:" )
  util.print_r( props, "    " )

  local layer = Layer:clone( data )
  layer.width = width
  layer.height = height
  return layer
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
  speed = 64
}

function Sprite:init( t )
  if t then
    self.x = t.x
    self.y = t.y
    self.w = t.w
    self.h = t.h
    self.gid = t.gid
  end
end

function Sprite:inspect()
  love.graphics.print( "X: "..self.x, 4, 4 )
  love.graphics.print( "Y: "..self.y, 4, 14 )
  love.graphics.print( "dir: "..(self.dir or "nil"), 4, 24 )
  love.graphics.print( "moving: "..(self.moving or "nil"), 4, 34 )
  love.graphics.print( "excess: "..self.excess, 4, 44 )
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

----------------------------------------

local Player = Sprite:clone()

function Player:update(dt)
  if not self.dir or not friend.pressed(self.dir) then
    if friend.pressed("up") then self.dir = "up"
    elseif friend.pressed("down") then self.dir = "down"
    elseif friend.pressed("left") then self.dir = "left"
    elseif friend.pressed("right") then self.dir = "right"
    elseif friend.pressed("f9") then self.x, self.y = 0, 0
    else self.dir = nil end
  end

  Sprite.update(self, dt)
end

----------------------------------------
-- Here's the actual module.

local Explorer = prototype:clone()

function Explorer:init()
  self.player = Player:new()
  self.camera = Camera:new()
  self.font = love.graphics.newFont( 10 )
end

function Explorer:update(dt)
  self.player:update(dt)
  for _, v in ipairs(self.sprites) do
    v:update(dt)
  end
  self.layer:centerOn( self.player )
end

function Explorer:draw()
  love.graphics.setFont( self.font )
  love.graphics.setColor( 255, 255, 255 )
  self.layer:draw( self.tileset )
  self.camera:reset()
  self.camera:translate( self.layer.sx, self.layer.sy )
  self.player:draw( self.camera )
  for _, v in ipairs(self.sprites) do
    v:draw( self.camera )
  end
  self.player:inspect()
end

function Explorer:enter()
  tmx.loadTMX( "world.tmx",
               function(...) self.tileset = Tileset.gameLoadTileset(...) end,
               function(...) self.layer = Layer.gameLoadLayer(...) end,
               function(...) self.sprites = Sprite.gameLoadSprites(...) end )
  self.camera.tileset = self.tileset
end

return Explorer

----------------------------------------


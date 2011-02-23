
local util = require 'util'
local prototype = require 'prototype'
local friend = require 'friend'
local Sprite = require 'sprite'
local Tileset = require 'tileset'

----------------------------------------

local Layer = prototype:clone { sx = 0, sy = 0 }

function Layer:init()
  --
end

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

return Layer

----------------------------------------


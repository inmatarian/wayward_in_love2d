
local util = require 'util'
local prototype = require 'prototype'
local Sprite = require 'sprite'
local Tileset = require 'tileset'

local tilew, tileh = 16, 16

----------------------------------------

local Layer = prototype:clone { sx = 0, sy = 0 }

function Layer:init( data )
  self.sprites = {}
  for i, v in ipairs(data) do
    self[i] = v
  end
  self.spatial = { __mode='v' }
  setmetatable( self.spatial, self.spatial )
end

function Layer:addSprite(...)
  for n = 1, select( '#', ... ) do
    local s = select( n, ... )
    if type(s)=="table" then
      if prototype.isa(s, Sprite) then
        print("layer adding sprite", s)
        table.insert(self.sprites, s)
        s:setLayer(self)
      else
        for _, v in ipairs(s) do
          self:addSprite(v)
        end
      end
    end
  end
end

-- alias
Layer.addSprites = Layer.addSprite

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

function Layer:update(dt)
  for _, v in ipairs(self.sprites) do
    v:update(dt)
  end
end

function Layer:draw( tileset )
  local sx, sy = math.floor(self.sx / tilew), math.floor(self.sy / tileh)
  local ox, oy = self.sx - (sx*tilew), self.sy - (sy*tileh)
  for y = 0, 15 do
    for x = 0, 20 do
      local item = self:get( x+1+sx, y+1+sy )
      if item > 0 then
        tileset:drawTile( x*tilew-ox, y*tileh-oy, item )
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

function Layer:isSolid( x, y )
  local t = self:get(x, y)
  return (t>0) and (t<64)
end

function Layer:convToLayer( x, y )
  return math.floor(x/tilew)+1, math.floor(y/tileh)+1
end

function Layer:convFromLayer( x, y )
  return (x-1)*tilew, (y+1)*tileh
end

function Layer:modifyHash( x, y, w, h, value )
  local sx, sy, tx, ty, mx, my
  sy, my = 1+math.floor(y/tileh), 1+math.floor((y+h-0.1)/tileh)
  for ty = sy, my do
    sx, mx = 1+math.floor(x/tilew), 1+math.floor((x+w-0.1)/tilew)
    for tx = sx, mx do
      if tx >= 1 or ty >= 1 or tx <= self.width or ty <= self.height then
        self.spatial[ 1 + ( (ty-1) * self.width ) + (tx-1) ] = value
      end
    end
  end
end

function Layer:updateHash( sprite, oldx, oldy, oldw, oldh )
  self:modifyHash( oldx, oldy, oldw, oldh, nil )
  self:modifyHash( sprite.x, sprite.y, sprite.w, sprite.h, sprite )
end

function Layer:spriteAt( x, y )
  if x < 1 or y < 1 or x > self.width or y > self.height then
    return nil
  end
  return self.spatial[ 1 + ( (y-1) * self.width ) + (x-1) ]
end

function Layer:inspect()
  for k, v in pairs(self.spatial) do
    print( k, v )
  end
end

function Layer.gameLoadLayer( name, width, height, data, props )
  print( "loadLayer: "..name )
  print( "  size: "..width.." x "..height )
  print( "  properties:" )
  util.print_r( props, "    " )

  local layer = Layer:new( data )
  layer.width = width
  layer.height = height
  return layer
end

----------------------------------------

return Layer

----------------------------------------


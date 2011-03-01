
local util = require 'util'
local prototype = require 'prototype'

----------------------------------------

local Tileset = prototype:clone()

function Tileset:init( image, quads )
  self.image = image
  self.quads = quads
end

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

  local tileset = Tileset:new( tileimage, quads )
  return tileset
end

return Tileset

----------------------------------------


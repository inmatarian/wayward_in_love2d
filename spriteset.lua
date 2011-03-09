
local util = require 'util'
local prototype = require 'prototype'

----------------------------------------
local Spriteset = prototype:clone()
----------------------------------------

-- Singleton shared between all instances.
Spriteset.image = nil
Spriteset.quads = nil

----------------------------------------

function Spriteset:init()
  if not Spriteset.image then
    Spriteset.image = love.graphics.newImage("waysprites.png")
    Spriteset.image:setFilter("nearest", "nearest")
    Spriteset.quads = {}
    local sw = Spriteset.image:getWidth()
    local sh = Spriteset.image:getHeight()
    local y, i = 0, 1
    while y < sh do
      local x = 0
      while x < sw do
        local quad = love.graphics.newQuad( x, y, 16, 16, sw, sh )
        Spriteset.quads[i] = quad
        i, x = i + 1, x + 16
      end
      y = y + 16
    end
  end
end

----------------------------------------

function Spriteset:draw( x, y, index )
  love.graphics.drawq( self.image, self.quads[index], x, y )
end

----------------------------------------
return Spriteset
----------------------------------------


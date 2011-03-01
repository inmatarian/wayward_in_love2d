
local util = require 'util'
local prototype = require 'prototype'
local tmx = require 'tmx'
local friend = require 'friend'
local Sprite = require 'sprite'
local Tileset = require 'tileset'
local Layer = require 'layer'

----------------------------------------

local Camera = prototype:clone { x = 0, y = 0 }

function Camera:setTileset( t )
  self.tileset = t
end

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

local Player = Sprite:clone()

function Player:update(dt)
  if not self.dir or not friend.pressed(self.dir) then
    if friend.pressed("up") then self.dir = "up"
    elseif friend.pressed("down") then self.dir = "down"
    elseif friend.pressed("left") then self.dir = "left"
    elseif friend.pressed("right") then self.dir = "right"
    else self.dir = nil end
  end
  if friend.pressed("f9") then self.x, self.y = 32, 32 end

  Sprite.update(self, dt)
end

----------------------------------------
-- Here's the actual module.

local Explorer = prototype:clone()

function Explorer:init()
  self.player = Player:new(32, 32)
  self.camera = Camera:new()
  self.font = love.graphics.newFont( 10 )
  self.lastDT = 0
end

function Explorer:update(dt)
  self.player:update(dt)
  for _, v in ipairs(self.sprites) do
    v:update(dt)
  end
  self.layer:centerOn( self.player )
  self.lastDT = dt
end

function Explorer:inspect()
  local p = self.player
  love.graphics.setColor( 255, 64, 255 )
  love.graphics.print( "X: "..util.truncate(p.x,0.001), 4, 4 )
  love.graphics.print( "Y: "..util.truncate(p.y,0.001), 4, 14 )
  love.graphics.print( "dir: "..(p.dir or "nil"), 4, 24 )
  love.graphics.print( "moving: "..(p.moving or "nil"), 4, 34 )
  love.graphics.print( "excess: "..util.truncate(p.excess,0.001), 4, 44 )
  love.graphics.print( "dt: "..util.truncate(self.lastDT,0.001), 4, 54 )
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
  self:inspect()
end

function Explorer:enter()
  tmx.loadTMX( "world.tmx",
               function(...) self.tileset = Tileset.gameLoadTileset(...) end,
               function(...) self.layer = Layer.gameLoadLayer(...) end,
               function(...) self.sprites = Sprite.gameLoadSprites(...) end )
  self.camera:setTileset( self.tileset )

  self.layer:addSprites( self.player, self.sprites )
end

return Explorer

----------------------------------------


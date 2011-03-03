
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

function Player:init(...)
  Sprite.init(self, ...)
end

function Player:behavior(dt)
  if not self.dir or not friend.pressed(self.dir) then
    if friend.pressed("up") then self.dir = "up"
    elseif friend.pressed("down") then self.dir = "down"
    elseif friend.pressed("left") then self.dir = "left"
    elseif friend.pressed("right") then self.dir = "right"
    else self.dir = nil end
  end
  if friend.pressed("f9") == 1 then self.x, self.y = 32, 32 end
  if friend.pressed("f8") == 1 then self.layer:inspect() end
end

----------------------------------------
-- Here's the actual module.

local Explorer = prototype:clone()

function Explorer:init()
  self.player = Player:new(32, 32)
  self.camera = Camera:new()
  self.font = friend.font()
  self.lastDT = 0
end

function Explorer:update(dt)
  self.layer:update(dt)
  self.layer:centerOn( self.player )
  self.lastDT = dt
end

local function textRend( font, x, y, overlap, text, ... )
  for c in string.format(text, ...):gmatch('.') do
    love.graphics.print(c, x, y)
    x = x + font:getWidth(c) - overlap
  end
end

function Explorer:inspect()
  local p, f = self.player, self.font
  local h, o, x, y = f:getLineHeight(), 2, 4, 4
  love.graphics.setColor( 255, 64, 255 )
  textRend( f, x, y, o, "X: %.3f", p.x )
  textRend( f, x, y+h, o, "Y: %.3f", p.y )
  textRend( f, x, y+h*2, o, "dir: %s", (p.dir or "nil") )
  textRend( f, x, y+h*3, o, "moving: %s", (p.moving or "nil") )
  textRend( f, x, y+h*4, o, "excess: %.3f", p.excess )
  textRend( f, x, y+h*5, o, "dt: %.3f", self.lastDT )
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


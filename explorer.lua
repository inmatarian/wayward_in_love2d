
local util = require 'util'
local prototype = require 'prototype'
local tmx = require 'tmx'
local friend = require 'friend'
local Sprite = require 'sprite'
local Tileset = require 'tileset'
local Layer = require 'layer'
local RichText = require 'richtext'

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
  self.dir = nil
end

function Player:behavior(dt)
  local d = self.dir
  if not self.dir or not friend.pressed(self.dir) then
    if friend.pressed("up") then d = "up"
    elseif friend.pressed("down") then d = "down"
    elseif friend.pressed("left") then d = "left"
    elseif friend.pressed("right") then d = "right"
    else d = nil end
  end

  if d == "up" then self:setMovement("N")
  elseif d == "down" then self:setMovement("S");
  elseif d == "left" then self:setMovement("W");
  elseif d == "right" then self:setMovement("E");
  end
  self.dir = d

  if friend.pressed("f9") == 1 then self.x, self.y = 32, 32 end
  if friend.pressed("f8") == 1 then self.layer:inspect() end
end

----------------------------------------
-- Here's the actual module.
local Explorer = prototype:clone()
----------------------------------------

function Explorer:init()
  self.player = Player:new(32, 32)
  self.camera = Camera:new()
  self.font = friend.font()
  self.clock = { dt = 0, frames = 0, fpsAvg = 0, fps = 0, timer = 0 }
end

function Explorer:update(dt)
  self.layer:update(dt)
  self.layer:centerOn( self.player )
  local clock = self.clock
  clock.dt = dt
  clock.fpsAvg = ((1/dt)+(clock.frames*clock.fpsAvg))/(clock.frames+1)
  clock.frames = clock.frames + 1
  clock.timer = clock.timer + dt
  if clock.timer >= 1 then
    clock.timer = clock.timer - 1
    clock.fps = clock.fpsAvg
    clock.frames = 0
  end
end


function Explorer:inspect()
  local p, f = self.player, self.font
  local h, o, x, y = f:getLineHeight(), 2, 4, 4
  local text, format = RichText.fastDraw, string.format
  local clock = self.clock
  love.graphics.setColor( 255, 64, 255 )
  text( f, x, y, o, format("X: %.3f", p.x) )
  text( f, x, y+h, o, format("Y: %.3f", p.y) )
  text( f, x, y+h*2, o, format("dir: %s %s %s %s", tostring(p.xtarget),
        tostring(p.ytarget), tostring(p.moving), tostring(p.dir)) )
  text( f, x, y+h*3, o, format("excess: %.3f %.3f", p.xexcess, p.yexcess) )
  text( f, x, y+h*4, o, format("FPS: %i (%.3f)", clock.fps, clock.dt) )
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

----------------------------------------
return Explorer
----------------------------------------


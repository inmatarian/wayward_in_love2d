
local util = require 'util'
local prototype = require 'prototype'
local friend = require 'friend'
local Sprite = require 'sprite'
local Tileset = require 'tileset'
local Layer = require 'layer'

----------------------------------------
local Player = Sprite:clone()
----------------------------------------

local FRAME = 0.25

function Player:init( x, y )
  Sprite.init(self, x, y)
  self.dir = nil

  self.animator:addPattern( "up", 1, FRAME, 2, FRAME )
  self.animator:addPattern( "down", 3, FRAME, 4, FRAME )
  self.animator:addPattern( "left", 5, FRAME, 6, FRAME )
  self.animator:addPattern( "right", 7, FRAME, 8, FRAME )
  self.animator:setPattern("down")
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

  local moving = self.moving

  if d == "up" then self:setMovement("N")
  elseif d == "down" then self:setMovement("S");
  elseif d == "left" then self:setMovement("W");
  elseif d == "right" then self:setMovement("E");
  end
  self.dir = d

  if not moving and self.moving and d and d ~= self.animator:getName() then
    self.animator:setPattern(d)
  end

  if friend.pressed("f9") == 1 then self.x, self.y = 32, 32 end
  if friend.pressed("f8") == 1 then self.layer:inspect() end
end

----------------------------------------
return Player
----------------------------------------


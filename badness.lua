
local prototype = require 'prototype'
local util = require 'util'
local Explorer = require 'explorer'
local friend = require 'friend'

----------------------------------------
-- 16x12 Square fade in.

local Badness = prototype:clone()

function Badness:init( nextState )
  self.nextState = nextState
  self.co = coroutine.create( Badness.run )
  self.font = love.graphics.newFont( 24 )
  self.delta = 0
  self.list = {}
  for y = 1, 12 do
    for x = 1, 16 do
      local e = {}
      e.visible = false
      e.x = 20 * (x-1)
      e.y = 20 * (y-1)
      table.insert( self.list, e )
    end
  end
  util.shuffle( self.list )
end

function Badness:update(dt)
  if coroutine.status( self.co ) ~= "dead" then
    coroutine.resume(self.co, self, dt)
  else
    friend.setState( self.nextState:new() )
  end
end

function Badness:wait( count )
  count = count - self.delta
  while count > 0 do
    local s, dt = coroutine.yield()
    count = count - dt
  end
  self.delta = -count
end

function Badness:run()
  local STEP = 0.005

  for i = 1, #self.list do
    self:wait(STEP)
    self.list[i].visible = true
  end

  self:wait(1.5)

  for i = 1, #self.list do
    self.list[i].visible = false
    self:wait(STEP)
  end

  self:wait(0.5)
end

function Badness:draw()
  love.graphics.setColor( 112, 0, 128 )
  for i = 1, #self.list do
    local e = self.list[i]
    if e.visible then
      love.graphics.rectangle( "fill", e.x, e.y, 20, 20 )
    end
  end
  love.graphics.setFont( self.font )
  love.graphics.setColor( 0, 0, 0 )
  love.graphics.printf("PLANET BADNESS", 0, 100, 320, "center" )
end

return Badness


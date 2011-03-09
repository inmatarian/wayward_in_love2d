
local util = require 'util'
local prototype = require 'prototype'
local Spriteset = require 'spriteset'
local Animator = require 'animator'

----------------------------------------

local Sprite = prototype:clone {
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  gid = 1,
  moving = false,
  xexcess = 0,
  yexcess = 0,
  xtarget = nil,
  ytarget = nil,
  lastdir = "I",
  speed = 64,
  layer = nil,
  animator = nil,
  spriteset = nil
}

function Sprite:init( x, y )
  if type(x)=="table" then
    self.x = x.x
    self.y = x.y
    self.w = x.w
    self.h = x.h
    self.gid = x.gid
  elseif x or y then
    self.x = x
    self.y = y
    self.w = 16
    self.h = 16
  end

  if Sprite.spriteset == nil then
    Sprite.spriteset = Spriteset:new()
  end

  self.animator = Animator:new( self.gid )
end

function Sprite:setLayer( l )
  self.layer = l
end

function Sprite:isBlocked( dir )
  if not self.layer then return false end

  local cx, cy = self.layer:convToLayer( self.x, self.y )

  if dir == "N" then cy = cy - 1
  elseif dir == "S" then cy = cy + 1
  elseif dir == "W" then cx = cx - 1
  elseif dir == "E" then cx = cx + 1
  end

  return self.layer:isSolid( cx, cy )
end

function Sprite:otherSprite( dir )
  local cx, cy = self.layer:convToLayer( self.x, self.y )
  if dir == "N" then cy = cy - 1
  elseif dir == "S" then cy = cy + 1
  elseif dir == "W" then cx = cx - 1
  elseif dir == "E" then cx = cx + 1
  end

  return self.layer:spriteAt( cx, cy )
end

function Sprite:updatePosition(dt)
  local xt, yt = self.xtarget, self.ytarget
  if not self.moving then
    return
  end

  local oldx, oldy, oldw, oldh = self.x, self.y, self.w, self.h
  local nx, ny = oldx, oldy
  local speed = self.speed * dt
  local xex, yex = self.xexcess, self.yexcess
  self.xexcess, self.yexcess = 0, 0

  if xt < oldx then
    nx = oldx - speed - xex
    if nx <= xt then
      self.xexcess, nx, self.moving = xt-nx, xt, false
    end
  elseif xt > oldx then
    nx = oldx + speed + xex
    if nx >= xt then
      self.xexcess, nx, self.moving = nx-xt, xt, false
    end
  end
  self.x = nx

  if yt < oldy then
    ny = oldy - speed - yex
    if ny <= yt then
      self.yexcess, ny, self.moving = yt-ny, yt, false
    end
  elseif yt > oldy then
    ny = oldy + speed + yex
    if ny >= yt then
      self.yexcess, ny, self.moving = ny-yt, yt, false
    end
  end
  self.y = ny

  self.layer:updateHash( self, oldx, oldy, oldw, oldh )
end

function Sprite:update(dt)
  if self.behavior then self:behavior(dt) end
  self:updatePosition(dt)
  self.animator:update(dt)
  self.gid = self.animator:getFrame()
end

function Sprite:setMovement(dir)
  if self.moving then return end
  if self:isBlocked(dir) or self:otherSprite(dir) then return end

  local x, y = math.floor(self.x/16)*16, math.floor(self.y/16)*16
  if dir == "N" then self.xtarget, self.ytarget = x, y-16
  elseif dir == "S" then self.xtarget, self.ytarget = x, y+16
  elseif dir == "W" then self.xtarget, self.ytarget = x-16, y
  elseif dir == "E" then self.xtarget, self.ytarget = x+16, y
  end
  self.lastdir = dir
  self.xexcess, self.yexcess = 0, 0
  self.moving = true
end

function Sprite:draw( offx, offy )
  self.spriteset:draw( self.x - offx, self.y - offy, self.gid )
end

----------------------------------------

local Actor = Sprite:clone()
Sprite.Actor = Actor

function Actor:init( x, y )
  Sprite.init(self, x, y)
  self.thread = coroutine.create( self.run )
end

function Actor:behavior(dt)
  if coroutine.status( self.thread ) ~= "dead" then
    local okay, message = coroutine.resume(self.thread, self, dt)
    if not okay then error(message) end
  end
end

function Actor:wait( count )
  while count > 0 do
    local s, dt = coroutine.yield()
    count = count - dt
  end
end

function Actor:waitForMove()
  while self.moving do
    coroutine.yield()
  end
end

local dirs = { "N", "S", "W", "E" }

-- N.orth, S.outh, W.est, E.ast, R.andom, F.low, T.oward, A.way, H.op, I.dle.

function Actor:move( dir, count )
  count = count or 1
  dir = dir:upper()
  if dir == "R" then
    dir = dirs[ math.random(1, 4) ]
  elseif dir == "F" then
    dir = self.lastdir
  end

  if dir == "N" or dir == "S" or dir == "W" or dir == "E" then
    self:setMovement(dir)
  end

  self:waitForMove()
end

function Actor:walk( path )
  for dir, count in path:gmatch("(%S)(%d*)") do
    count = tonumber(count) or 1
    self:move(dir, count)
  end
end

----------------------------------------

local Enemy = Actor:clone()
Actor.Enemy = Enemy

----------------------------------------

local Ruffian = Enemy:clone()
Enemy.Ruffian = Ruffian

function Ruffian:run(dt)
  while true do
    self:walk("IIIIRRRRIIIIHHHH")
  end
end

----------------------------------------

local TestActor = Actor:clone()

function TestActor:run( dt )
  while true do
    self:wait(3)
    self:walk("RFFF")
  end
end

----------------------------------------

function Sprite.gameLoadSprites( layername, layerprops, objects )
  print( "loadObjects: "..layername )
  print( "  objects:" )
  util.print_r( objects, "    " )
  print( "  properties:" )
  util.print_r( layerprops, "    " )

  local sprites = {}

  for i, v in ipairs( objects ) do
    local spr = Sprite.createNew( v )
    sprites[i] = spr
  end

  return sprites
end

----------------------------------------

function Sprite.createNew( t )
  if t.type == "PLAYER" then
    print("PLAYER FOUND!")
    return TestActor:new(t)
  else
    return Sprite:new(t)
  end
end

----------------------------------------
return Sprite
----------------------------------------


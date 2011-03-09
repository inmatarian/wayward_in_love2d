
local util = require 'util'
local prototype = require 'prototype'

----------------------------------------
local Animator = prototype:clone()
----------------------------------------

function Animator:init( default )
  self.patterns = {}
  self.current = nil
  self.clock = 0
  self.index = 0
  self.frame = default or 0
  self.alarm = 0
  self.name = ""
end

function Animator:addPattern( name, ... )
  self.patterns[name] = {...}
end

function Animator:setPattern( name )
  self.name = name
  if not self.patterns[name] then
    self.current = nil
    return
  end

  self.current = self.patterns[name]
  self.index = 1
  self.frame = self.current[1]
  self.alarm = self.current[2]
end

function Animator:update(dt)
  if not self.current then return end

  self.clock = self.clock + dt
  if self.clock >= self.alarm then
    self.clock = self.clock - self.alarm
    self.index = self.index + 2
    if self.index > #self.current then self.index = 1 end
    self.frame = self.current[ self.index ]
    self.alarm = self.current[ self.index + 1 ] or 1
  end
end

function Animator:getName()
  return self.name
end

function Animator:getFrame()
  return self.frame
end

----------------------------------------
return Animator
----------------------------------------



local util = require 'util'
local prototype = require 'prototype'

----------------------------------------
local Registry = prototype:clone()
----------------------------------------

function Registry:init()
  self.actors = setmetatable( {}, {_mode="v"} )
  self.names = setmetatable( {}, {_mode="k"} )
  self.messages = setmetatable( {}, {_mode="k"} )
end

function Registry:register( name, actor )
  self.actors[name] = actor
  self.names[actor] = name
  self.messages[actor] = util.Queue:new()
end

function Registry:unregister( name )
  local actor = self.actors[name]
  self.messages[actor] = nil
  self.names[actor] = nil
  self.actors[name] = nil
end

function Registry:identify( actor )
  return self.names[actor]
end

function Registry:send( name, message )
  local actor = self.actors[name]
  self.messages[actor]:pushBack( message )
end

function Registry:hasMessages(name)
  local actor = self.actors[name]
  return ( self.messages[actor]:size() > 0 )
end

function Registry:receive( name )
  local actor = self.actors[name]
  return self.messages[actor]:popFront()
end

function Registry:clearMessages(name)
  local actor = self.actors[name]
  self.messages[actor]:clear()
end

----------------------------------------
return Registry
----------------------------------------


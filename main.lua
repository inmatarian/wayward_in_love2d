
local util = require 'util'
local prototype = require 'prototype'
local tmx = require 'tmx'
local friend = require 'friend'
local Badness = require 'badness'
local Explorer = require 'explorer'

friend.setState( Badness:new( Explorer ) )


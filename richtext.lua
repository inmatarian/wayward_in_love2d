
local friend = require 'friend'
local util = require 'util'
local prototype = require 'prototype'

----------------------------------------
local RichText = prototype:clone()
----------------------------------------

function RichText:init()
  --
end

function RichText.fastDraw( font, x, y, overlap, text )
  for c in text:gmatch('.') do
    love.graphics.print(c, x, y)
    x = x + font:getWidth(c) - overlap
  end
end

----------------------------------------
return RichText
----------------------------------------



local util = require 'util'

----------------------------------------

local function XMLparseargs(s)
  local arg = {}
  string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
  end)
  return arg
end
  
local function XMLcollect(s)
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=XMLparseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=XMLparseargs(xarg)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[#stack].label)
  end
  return stack[1]
end

local function nullLoadTileset( name, filename, width, height, firstgid, tilewidth, tileheight, properties )
  print( "loadTileset: "..name )
  print( "  filename: "..filename ) 
  print( "  size: "..width.." x "..height )
  print( "  firstgid: "..firstgid )
  print( "  tilesize: "..tilewidth.." x "..tileheight )
  print( "  properties:" )
  util.print_r( properties, "    " )
end

local function nullLoadLayer( name, width, height, data, props )
  print( "loadLayer: "..name )
  print( "  size: "..width.." x "..height )
  print( "  properties:" )
  util.print_r( props, "    " )
end

local function nullLoadObjects( layername, layerprops, objects )
  print( "loadObjects: "..layername )
  print( "  objects:" )
  util.print_r( objects, "    " )
  print( "  properties:" )
  util.print_r( layerprops, "    " )
end

local function collectProperties( t )
  if not t then return end
  local r = {}
  for _, v in ipairs(t) do
    r[v.xarg.name] = v.xarg.value
  end
  return r
end

local function csvParse( data )
  local N = data:len()
  local T = {}
  local i, t = 1, 1
  while i <= N do
    local x = data:find(',', i) or N
    T[t] = tonumber( data:sub(i, x-1) )
    t = t + 1
    i = x + 1
    if data:sub(i,i)=='\n' then i = i + 1 end
  end
  return T
end

local function loadTMX( filename, loadTileset, loadLayer, loadObjects )
  print( "loading "..filename )
  loadTileset = loadTileset or nullLoadTileset
  loadLayer = loadLayer or nullLoadLayer
  loadObjects = loadObjects or nullLoadObjects

  local xml = XMLcollect( love.filesystem.read(filename) )

  local map = xml[2]
  local tilewidth = map.xarg.tilewidth
  local tileheight = map.xarg.tileheight

  for _, v in ipairs(map) do
    if v.label == "tileset" then
      local imagefn = ""
      local tileprops = {}
      local name = v.xarg.name
      local firstgid = tonumber(v.xarg.firstgid)
      local tilewidth, tileheight = tonumber(v.xarg.tilewidth), tonumber(v.xarg.tileheight)
      local w, h
      for _, u in ipairs(v) do
        if u.label == "image" then
          imagefn = u.xarg.source
          w, h = tonumber(u.xarg.width), tonumber(u.xarg.height)
        elseif u.label == "tile" then
          local id = u.xarg.id
          tileprops[id] = collectProperties(u[1])
        end
      end
      loadTileset( name, imagefn, w, h, firstgid, tilewidth, tileheight, tileprops )

    elseif v.label == "layer" then
      local w, h = tonumber(v.xarg.width), tonumber(v.xarg.height)
      local name = v.xarg.name
      local props, data
      for _, u in ipairs(v) do
        if u.label == "properties" then
          props = collectProperties(u)
        elseif u.label == "data" then
          assert( u.xarg.encoding == "csv" )
          data = csvParse(u[1])
        end
      end
      loadLayer( name, w, h, data, props )

    elseif v.label == "objectgroup" then
      local layername = v.xarg.name
      local objects = {}
      local layerprops
      for _, u in ipairs(v) do
        if u.label == "properties" then
          layerprops = collectProperties(u)
        elseif u.label == "object" then
          local obj = {}
          obj.name = u.xarg.name
          obj.type = u.xarg.type
          obj.x = tonumber(u.xarg.x)
          obj.y = tonumber(u.xarg.y)
          obj.w = tonumber(u.xarg.width or tilewidth)
          obj.h = tonumber(u.xarg.height or tileheight)
          obj.gid = tonumber(u.xarg.gid)
          obj.properties = collectProperties( u[1] )
          objects[#objects+1] = obj
        end
      end
      loadObjects( layername, layerprops, objects )
    end
  end
end

----------------------------------------

return { loadTMX = loadTMX }

----------------------------------------


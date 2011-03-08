----------------------------------------
local Defines = {}
----------------------------------------

local function enum( e, ... )
  local t = {}
  for i = 1, select('#', ...) do
    local k = e - 1 + i
    local v = select(i, ...)
    t[k] = v
    t[v] = k
  end
end

local function anims( t, offset, ... )
  local t = t or {}
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    t[v] = enum( offset, "U1", "U2", "D1", "D2", "L1", "L2", "R1", "R2" )
    offset = offset + 8
  end
  return t
end

----------------------------------------

Defines.Sprites = anims( {}, 1, "Sylvia", "Bunny", "Seraph", "Erhardt",
    "Graven", "GravenGrey", "Vex", "Lynch", "Abbot", "Asmodeus" )

----------------------------------------







----------------------------------------
return Defines
----------------------------------------


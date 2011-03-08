-- Prototype
-- Freeform Class definitions
----------------------------------------

local function clone( base, inst )
  inst = inst or {}
  inst.__index = base
  return setmetatable( inst, inst )
end

local function new( base, ... )
  local inst = clone( base )
  if inst.init then inst:init(...) end
  return inst
end

local function isa( inst, base )
  local c = inst
  while c do
    if c.__index == base then return true end
    c = c.__index
  end
  return false
end

local function super( inst )
  return inst.__index
end

----------------------------------------

return {
  clone = clone;
  isa = isa;
  new = new;
  super = super;
}

----------------------------------------


-- local storage_tanks = 
-- {
--   ["angels-storage-tank-1"] = true,
--   ["angels-storage-tank-2"] = true,
--   ["angels-storage-tank-3"] = true,
--   ["angels-pressure-tank-1"] = true,
--   ["bob-storage-tank-all-corners"] = true,
--   ["bob-storage-tank-all-corners-2"] = true,
--   ["bob-storage-tank-all-corners-3"] = true,
--   ["bob-storage-tank-all-corners-4"] = true,
--   ["bob-small-inline-storage-tank"] = true,
--   ["bob-small-storage-tank"] = true,
--   ["storage-tank"] = true,
--   ["storage-tank-2"] = true,
--   ["storage-tank-3"] = true,
--   ["storage-tank-4"] = true,
-- }

local function mining_time_from_capacity(capacity)
  if capacity < 10000 then
    return 1 -- at least 1
  end 
  return capacity / 10000
end

if not settings.startup['seablock-evil-mode-disable-voiding-restrictions'].value then
  
  for entity_name, entity in pairs(data.raw["storage-tank"]) do
    if entity.fluid_box and entity.minable then
      local capacity = entity.fluid_box.base_area * 100
      entity.minable.mining_time = mining_time_from_capacity(capacity)
    end
  end

  for entity_name, entity in pairs(data.raw["fluid-wagon"]) do
    if entity.minable then
      entity.minable.mining_time = mining_time_from_capacity(entity.capacity)
    end
  end
end
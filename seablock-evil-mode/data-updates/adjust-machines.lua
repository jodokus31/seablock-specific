local libfunctions = require("lib/libfunctions")

if not settings.startup['seablock-evil-mode-disable-voiding-restrictions'].value then
  -- nerf to flare stack
  --   type = "furnace",
  --   name = "angels-flare-stack",
  --   energy_usage = "30kW",
  --   crafting_speed = 2
  libfunctions.multiply_unit_value(data.raw["furnace"]["angels-flare-stack"], "energy_usage", 5)
  --data.raw["furnace"]["angels-flare-stack"].crafting_speed = data.raw["furnace"]["angels-flare-stack"].crafting_speed / 2
end


--enable chemical plant mk1 from start
libfunctions.adjust_recipe_enabled(data.raw["recipe"]["angels-chemical-plant"], true)

--enable clarifier from start
--adjust_recipe_enabled(data.raw["recipe"]["clarifier"], true)
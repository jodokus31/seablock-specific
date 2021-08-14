local libfunctions = require("lib/libfunctions")

local solid_fuel_factor = settings.startup['burner-power-progression-factor-solid'].value
local fluid_fuel_factor = settings.startup['burner-power-progression-factor-fluid'].value

-- don't increase vehicle fuels, because vehicle effectivity remain unchanged
-- rocket-booster, rocket-fuel, nuclear-fuel

local items_exceptions = 
{
  ["rocket-booster"] = true,
  ["rocket-fuel"] = true,
  ["nuclear-fuel"] = true,
}

local fluids_exceptions = 
{
}

-- Muliply fuel values at last step

for item_name, item in pairs(data.raw.item) do
  if not items_exceptions[item_name] then 
    -- don't increase not chemical fuel like fuel cells, as nuclear reactors remain unchanged
    -- uranium-fuel-cell, deuterium-fuel-cell, plutonium-fuel-cell, thorium-fuel-cell, thorium-plutonium-fuel-cell
    if item.fuel_value and item.fuel_category == "chemical" then
      libfunctions.multiply_unit_value(item, "fuel_value", solid_fuel_factor)
      log ("adjust solid fuel value with factor ".. solid_fuel_factor..": ".. item_name)
    end
  end
end

for fluid_name, fluid in pairs(data.raw.fluid) do
  if not fluids_exceptions[fluid_name] then 
    if fluid.fuel_value then
      libfunctions.multiply_unit_value(fluid, "fuel_value", fluid_fuel_factor)
      log ("adjust fluid fuel value with factor ".. fluid_fuel_factor..": ".. fluid_name)
    end
  end
end

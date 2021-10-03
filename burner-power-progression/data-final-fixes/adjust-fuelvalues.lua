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

local items_fuel_categories =
{
  ["chemical"] = true,
  ["processed-chemical"] = true
}

local fluids_exceptions = 
{
}

-- Muliply fuel values at last step

for item_name, item in pairs(data.raw.item) do
  if not items_exceptions[item_name] then 
    -- don't increase not chemical fuel like fuel cells, as nuclear reactors remain unchanged
    -- uranium-fuel-cell, deuterium-fuel-cell, plutonium-fuel-cell, thorium-fuel-cell, thorium-plutonium-fuel-cell
    if item.fuel_value 
          and item.fuel_category 
          and items_fuel_categories[item.fuel_category] then
      local before_value = item.fuel_value
      libfunctions.multiply_unit_value(item, "fuel_value", solid_fuel_factor)
      log ("adjust solid fuel value with factor ".. solid_fuel_factor..": ".. item_name .. "; from ".. before_value .." to " .. item.fuel_value)
    end
  end
end

for fluid_name, fluid in pairs(data.raw.fluid) do
  if not fluids_exceptions[fluid_name] then 
    if fluid.fuel_value then
      local before_value = fluid.fuel_value
      libfunctions.multiply_unit_value(fluid, "fuel_value", fluid_fuel_factor)
      log ("adjust fluid fuel value with factor ".. fluid_fuel_factor..": ".. fluid_name .. "; from ".. before_value .." to " .. fluid.fuel_value)
    end
  end
end

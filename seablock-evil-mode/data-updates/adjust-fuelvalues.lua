local libfunctions = require("lib/libfunctions")

local SOLID_FUEL_FACTOR = 2
local FLUID_FUEL_FACTOR = 1

-- don't increase vehicle fuels, because vehicle effectivity remain unchanged
-- rocket-booster, rocket-fuel, nuclear-fuel

-- don't increase fuel cells, as nuclear reactors remain unchanged
-- uranium-fuel-cell, deuterium-fuel-cell, plutonium-fuel-cell, thorium-fuel-cell, thorium-plutonium-fuel-cell

local solids_with_fuel_value = 
{
  ["wood-charcoal"] = true,
  ["pellet-coke"] = true,
  ["cellulose-fiber"] = true,
  ["wood"] = true,
  ["wood-pellets"] = true,
  ["solid-fuel"] = true,
  ["solid-carbon"] = true,
  ["enriched-fuel"] = true,
}

local fluids_with_fuel_value = 
{
  ["hydrazine"] = true,
  ["gas-hydrazine"] = true,
  ["liquid-fuel-oil"] = true,
  ["liquid-fuel"] = true,
  ["gas-methane"] = true,
  ["crude-oil"] = true,
  ["diesel-fuel"] = true,
}

for item, really_change in pairs(solids_with_fuel_value) do 
  if really_change and data.raw.item[item] and data.raw.item[item].fuel_value then
    libfunctions.multiply_unit_value(data.raw.item[item], "fuel_value", SOLID_FUEL_FACTOR)
  else
    log(item .. " item fuel_value was not changed")
  end
end

for fluid, really_change in pairs(fluids_with_fuel_value) do 
  if really_change and data.raw.fluid[fluid] and data.raw.fluid[fluid].fuel_value then
    libfunctions.multiply_unit_value(data.raw.fluid[fluid], "fuel_value", FLUID_FUEL_FACTOR)
  else
    log(fluid .. " fluid fuel_value was not changed")
  end
end

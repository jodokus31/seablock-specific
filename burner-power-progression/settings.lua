
local default_tiers = require("default_tiers")

data:extend({
  {
      type = "bool-setting",
      name = "burner-power-progression-disabled",
      order = "aaa",
      setting_type = "startup",
      default_value = false,
  }})

data:extend({
  {
      type = "double-setting",
      name = "burner-power-progression-factor-solid",
      order = "effectivity-a1",
      setting_type = "startup",
      default_value = 2.0,
      minimum_value = 0.1,
      maximum_value = 5.0
  }})

data:extend({
  {
      type = "string-setting",
      name = "burner-power-progression-tiers-solid",
      order = "effectivity-a2",
      setting_type = "startup",
      default_value = default_tiers.GetSolidTiers(),
  }})

data:extend({
  {
      type = "double-setting",
      name = "burner-power-progression-factor-fluid",
      order = "effectivity-b1",
      setting_type = "startup",
      default_value = 1.0,
      minimum_value = 0.1,
      maximum_value = 5.0
  }})

data:extend({
  {
      type = "string-setting",
      name = "burner-power-progression-tiers-fluid",
      order = "effectivity-b2",
      setting_type = "startup",
      default_value = default_tiers.GetFluidTiers(),
  }})
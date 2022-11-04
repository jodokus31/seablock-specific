local libfunctions = require("lib/libfunctions")

if mods["burner-power-progression"] then
  libfunctions.overwrite_setting("double-setting", "burner-power-progression-factor-solid", 2.0)
  libfunctions.overwrite_setting("double-setting", "burner-power-progression-factor-fluid", 1.0)

  libfunctions.overwrite_setting("string-setting", "burner-power-progression-tiers-solid", "0.425, 0.50, 0.575, 0.65,  0.75")
  libfunctions.overwrite_setting("string-setting", "burner-power-progression-tiers-fluid", "-.-,   0.60, 0.70,  0.825, 0.95")
end

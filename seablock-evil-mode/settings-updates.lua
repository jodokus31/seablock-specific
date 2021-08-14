local libfunctions = require("lib/libfunctions")

libfunctions.overwrite_setting("double-setting", "boiler-effectivities-factor-solid", 2.0)
libfunctions.overwrite_setting("double-setting", "boiler-effectivities-factor-fluid", 1.0)

libfunctions.overwrite_setting("string-setting", "boiler-effectivities-tiers-solid", "0.425, 0.50, 0.575, 0.65,  0.75")
libfunctions.overwrite_setting("string-setting", "boiler-effectivities-tiers-fluid", "-.-,   0.60, 0.70,  0.825, 0.95")

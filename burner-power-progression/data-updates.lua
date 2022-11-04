if not settings.startup['burner-power-progression-disabled'].value then
  require("data-updates/adjust-boiler-effectivity")
end

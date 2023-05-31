local settings = {}
  
table.insert(settings,
{
    type = "double-setting",
    name = "seablock-jetpack-fuels-enriched-fuel",
    order = "a1",
    setting_type = "startup",
    default_value = 0.5,
    minimum_value = 0.0,
    maximum_value = 1.1,
})

table.insert(settings,
{
    type = "double-setting",
    name = "seablock-jetpack-fuels-pellet-charcoal",
    order = "a2",
    setting_type = "startup",
    default_value = 0.3,
    minimum_value = 0.0,
    maximum_value = 1.1,
})

table.insert(settings,
{
    type = "double-setting",
    name = "seablock-jetpack-fuels-wood-brick",
    order = "a3",
    setting_type = "startup",
    default_value = 0.25,
    minimum_value = 0.0,
    maximum_value = 1.1,
})

table.insert(settings,
{
    type = "double-setting",
    name = "seablock-jetpack-fuels-wood-charcoal",
    order = "a4",
    setting_type = "startup",
    default_value = 0.2,
    minimum_value = 0.0,
    maximum_value = 1.1,
})

data:extend(settings)

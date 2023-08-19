-- data:extend({
-- 	{
-- 		type = "int-setting",
-- 		name = "edl-ticks",
-- 		setting_type = "runtime-per-user",
-- 		default_value = 60,
-- 		minimum_value = 1,
-- 	},
-- })
local settings = {}

table.insert(settings,
    {
        type = "int-setting",
        name = "extended-fasttransfer-custom-drop-amount",
        order = "a",
        setting_type = "runtime-per-user",
        default_value = 10,
        minimum_value = 1,
        maximum_value = 1000,
    })

table.insert(settings,
    {
        type = "int-setting",
        name = "extended-fasttransfer-max-ammo-amount",
        order = "b",
        setting_type = "runtime-per-user",
        default_value = 25,
        minimum_value = 1,
        maximum_value = 1000,
    })

table.insert(settings,
    {
        type = "int-setting",
        name = "extended-fasttransfer-max-fuel-furnace",
        order = "c",
        setting_type = "runtime-per-user",
        default_value = 10,
        minimum_value = 1,
        maximum_value = 1000,
    })
table.insert(settings,
    {
        type = "int-setting",
        name = "extended-fasttransfer-max-fuel-boiler",
        order = "d",
        setting_type = "runtime-per-user",
        default_value = 25,
        minimum_value = 1,
        maximum_value = 1000,
    })
table.insert(settings,
    {
        type = "int-setting",
        name = "extended-fasttransfer-max-fuel-inserter",
        order = "e",
        setting_type = "runtime-per-user",
        default_value = 2,
        minimum_value = 1,
        maximum_value = 1000,
    })

data:extend(settings)
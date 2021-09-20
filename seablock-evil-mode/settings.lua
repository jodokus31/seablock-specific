data:extend({
{
    type = "bool-setting",
    name = "seablock-evil-mode-disable-voiding-restrictions",
    order = "a1",
    setting_type = "startup",
    default_value = false,
}})

data:extend({
{
    type = "bool-setting",
    name = "seablock-evil-mode-enable-fluid-removed-log",
    order = "b1",
    setting_type = "startup",
    default_value = false,
}})

data:extend({
{
    type = "string-setting",
    name = "seablock-evil-mode-steam-recipe-mode",
    order = "c1",
    setting_type = "startup",
    default_value = "default",
    allowed_values = {"default", "0_0_5"},
}})

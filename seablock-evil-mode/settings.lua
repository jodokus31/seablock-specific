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
      name = "seablock-evil-mode-disable-voiding-exceptions",
      order = "a11",
      setting_type = "startup",
      default_value = false,
  }})

data:extend({
{
    type = "bool-setting",
    name = "seablock-evil-mode-disable-sorting-rebalance",
    order = "a2",
    setting_type = "startup",
    default_value = true,
}})

data:extend({
{
    type = "bool-setting",
    name = "seablock-evil-mode-disable-steam-recipe",
    order = "a3",
    setting_type = "startup",
    default_value = true,
}})

data:extend({
{
    type = "string-setting",
    name = "seablock-evil-mode-steam-recipe-mode",
    order = "a31",
    setting_type = "startup",
    default_value = "default",
    allowed_values = {"default", "0_0_5"},
}})

data:extend({
{
    type = "bool-setting",
    name = "seablock-evil-mode-disable-misc",
    order = "a4",
    setting_type = "startup",
    default_value = true,
}})

data:extend({
{
    type = "bool-setting",
    name = "seablock-evil-mode-enable-fluid-removed-log",
    order = "b1",
    setting_type = "runtime-per-user",
    default_value = false,
}})



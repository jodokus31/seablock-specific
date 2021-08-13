data:extend({

  -- 1 steam(165 degree) == 30kJ
  -- 1 h2 needed 30kJ with electrolysis I

  {
    type = "recipe",
    name = "sbem-steam-from-h2-o2-1",
    category = "chemistry",
    subgroup = "petrochem-basics",
    energy_required = 1.4, --21 for 100
    enabled = true,
    ingredients = {
      {type = "fluid", name = "gas-oxygen", amount = 75},
      {type = "fluid", name = "gas-hydrogen", amount = 100}
    },
    results = {
      {type = "fluid", name = "steam", amount = 24},
      -- {type = "fluid", name = "water-purified", amount = 76},
    },
    always_show_products = true,
    icons = angelsmods.functions.create_liquid_recipe_icon(
      {
        "steam"
      },
      "www"
    ),
    order = "a[sbem-steam-from-h2-o2-1]",
    crafting_machine_tint = {
      primary = {r = 1, g = 1, b = 1, a = 0},
      secondary = {r = 0.7, g = 0.7, b = 1, a = 0},
      tertiary = {r = 167 / 255, g = 75 / 255, b = 5 / 255, a = 0 / 255}
    }
  },

  {
    type = "recipe",
    name = "sbem-steam-from-h2-o2-2",
    category = "chemistry",
    subgroup = "petrochem-basics",
    energy_required = 2.1, --21 for 100
    enabled = true,
    ingredients = {
      {type = "fluid", name = "gas-oxygen", amount = 75},
      {type = "fluid", name = "gas-hydrogen", amount = 150}
    },
    results = {
      {type = "fluid", name = "steam", amount = 36},
      -- {type = "fluid", name = "water-purified", amount = 114},
    },
    always_show_products = true,
    icons = angelsmods.functions.create_liquid_recipe_icon(
      {
        "steam"
      },
      "www"
    ),
    order = "a[sbem-steam-from-h2-o2-2]",
    crafting_machine_tint = {
      primary = {r = 1, g = 1, b = 1, a = 0},
      secondary = {r = 0.7, g = 0.7, b = 1, a = 0},
      tertiary = {r = 167 / 255, g = 75 / 255, b = 5 / 255, a = 0 / 255}
    }
  },
})
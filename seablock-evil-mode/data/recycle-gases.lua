data:extend({

  -- 1 steam(165 degree) == 30kJ
  -- 1 h2 needed 30kJ with electrolysis I

  {
    type = "recipe",
    name = "sbem-steam-from-h2-o2-1",
    category = "chemistry",
    subgroup = "petrochem-basics",
    energy_required = 1, -- 1/1.75 sec. for 8 elecs on plant mk1
    enabled = true,
    ingredients = {
      {type = "fluid", name = "gas-oxygen", amount = 60},
      {type = "fluid", name = "gas-hydrogen", amount = 80}
    },
    results = {
      {type = "fluid", name = "steam", amount = 25, temperature = 165}, -- plant consumes 258.3333 kW in 1 sec.
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
    energy_required = 1, -- 1/1.75 sec. for 8 elecs on plant mk1
    enabled = true,
    ingredients = {
      {type = "fluid", name = "gas-oxygen", amount = 40},
      {type = "fluid", name = "gas-hydrogen", amount = 80}
    },
    results = {
      {type = "fluid", name = "steam", amount = 21, temperature = 165}, -- plant consumes 258.3333 kW in 1 sec.
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
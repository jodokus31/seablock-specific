local mw_crystallize_recipe = data.raw.recipe["sb-water-mineralized-crystallization"]

-- mw_crystallize_recipe.energy_required = 2.9
-- mw_crystallize_recipe.ingredients = 
-- {
--   {type = "fluid", name = "water-mineralized", amount = 290}
-- }

-- mw_crystallize_recipe.results = 
-- {
--   {type = "item", name = "angels-ore1", amount = 1},
--   {type = "item", name = "angels-ore1", amount = 1, probability = 0.595},
--   {type = "item", name = "angels-ore3", amount = 1},
--   {type = "item", name = "angels-ore3", amount = 1, probability = 0.015},
-- }

mw_crystallize_recipe.energy_required = 5.72
mw_crystallize_recipe.ingredients = 
{
  {type = "fluid", name = "water-mineralized", amount = 572}
}

mw_crystallize_recipe.results = 
{
  {type = "item", name = "angels-ore1", amount = 3},
  {type = "item", name = "angels-ore1", amount = 1, probability = 0.146},
  {type = "item", name = "angels-ore3", amount = 2},
  {type = "item", name = "angels-ore3", amount = 1, probability = 0.002},
}

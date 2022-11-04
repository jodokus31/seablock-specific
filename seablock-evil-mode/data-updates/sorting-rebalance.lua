
if not settings.startup['seablock-evil-mode-disable-sorting-rebalance'].value then

  -- Catalysator recipes

  -- Tier 1
  local crushed_catalystor_recipes = {
    ["angelsore-crushed-mix1-processing"] = {{ name ="iron-ore", amount = 3 }},
    ["angelsore-crushed-mix2-processing"] = {{ name ="copper-ore", amount = 3 }},
    ["angelsore-crushed-mix3-processing"] = {{ name ="lead-ore", amount = 3 }},
    ["angelsore-crushed-mix4-processing"] = {{ name ="tin-ore", amount = 3 }},
  }

  -- Tier 2
  local chunk_catalystor_recipes = {
    ["angelsore-chunk-mix1-processing"] = {{ name ="quartz", amount = 3 }},
    ["angelsore-chunk-mix2-processing"] = {{ name ="nickel-ore", amount = 3 }},
    ["angelsore-chunk-mix3-processing"] = {{ name ="bauxite-ore", amount = 3 }},
    ["angelsore-chunk-mix4-processing"] = {{ name ="zinc-ore", amount = 3 }},
    ["angelsore-chunk-mix5-processing"] = {{ name ="silver-ore", amount = 3 }},
    ["angelsore-chunk-mix6-processing"] = {{ name ="fluorite-ore", amount = 3 }},
    -- ["angelsore-chunk-mix7-processing"] = {{ name ="angels-void", amount = 3 }}, -- disabled
  }

  -- Tier 3
  local crystal_catalystor_recipes = {
    ["angelsore-crystal-mix1-processing"] = {{ name ="rutile-ore", amount = 4 }},
    ["angelsore-crystal-mix2-processing"] = {{ name ="gold-ore", amount = 4 }},
    ["angelsore-crystal-mix3-processing"] = {{ name ="cobalt-ore", amount = 4 }},
    -- ["angelsore-crystal-mix4-processing"] = {{ name ="angels-void", amount = 3 }}, -- disabled
    -- ["angelsore-crystal-mix5-processing"] = {{ name ="uranium-ore", amount = 2 }}, -- unchanged
    -- ["angelsore-crystal-mix6-processing"] = {{ name ="thorium-ore", amount = 2 }}, -- unchanged
  }

  -- Tier 4
  local pure_catalystor_recipes = {
    ["angelsore-pure-mix1-processing"] = {{ name ="tungsten-ore", amount = 4 }},
    -- ["angelsore-pure-mix2-processing"] = {{ name ="platinum-ore", amount = 2 }}, -- unchanged
    -- ["angelsore-pure-mix3-processing"] = {{ name ="angels-void", amount = 4 }}, -- disabled
  }

  -- Single ore sorting recipes
  -- Tier 1

  -- angelsore1-crushed-processing
  -- --angelsore2-crushed-processing --disabled
  -- angelsore3-crushed-processing
  -- --angelsore4-crushed-processing --disabled
  -- angelsore5-crushed-processing
  -- angelsore6-crushed-processing

  -- angelsore8-crushed-processing
  -- angelsore9-crushed-processing

  -- Tier 2
  local chunk_single_ore_recipes = {
    ["angelsore1-chunk-processing"] = {{ name ="iron-ore", amount = 1}, { name ="quartz", amount = 2}}, -- unchanged
    ["angelsore2-chunk-processing"] = {{ name ="iron-ore", amount = 1}, { name ="bauxite-ore", amount = 2}},
    ["angelsore3-chunk-processing"] = {{ name ="copper-ore", amount = 1}, { name ="silver-ore", amount = 2}},
    ["angelsore4-chunk-processing"] = {{ name ="copper-ore", amount = 1}, { name ="bauxite-ore", amount = 2}},
    ["angelsore5-chunk-processing"] = {{ name ="lead-ore", amount = 1}, { name ="nickel-ore", amount = 2}},
    ["angelsore6-chunk-processing"] = {{ name ="tin-ore", amount = 1}, { name ="zinc-ore", amount = 2}},

    -- ["angelsore8-powder-processing"] = {{ name ="manganese-ore", amount = 3}} }, -- unchanged
    -- ["angelsore9-powder-processing"] = {{ name ="copper-ore", amount = 4}} }, -- unchanged
  }


  -- Tier 3
  local crystal_single_ore_recipes = {
    ["angelsore1-crystal-processing"] = {{ name ="iron-ore", amount = 1}, { name ="rutile-ore", amount = 3}},
    ["angelsore2-crystal-processing"] = {{ name ="iron-ore", amount = 1}, { name ="cobalt-ore", amount = 3}},
    ["angelsore3-crystal-processing"] = {{ name ="copper-ore", amount = 1}, { name ="uranium-ore", amount = 3}},
    ["angelsore4-crystal-processing"] = {{ name ="copper-ore", amount = 1}, { name ="bauxite-ore", amount = 3}},
    ["angelsore5-crystal-processing"] = {{ name ="lead-ore", amount = 1}, { name ="gold-ore", amount = 3}},
    ["angelsore6-crystal-processing"] = {{ name ="tin-ore", amount = 1}, { name ="silver-ore", amount = 3}},
    -- ["angelsore8-dust-processing"] = {{ name ="manganese-ore", amount = 4}}, -- unchanged
    -- ["angelsore9-dust-processing"] = {{ name ="silver-ore", amount = 2}, { name ="gold-ore", amount = 2}}, -- unchanged
  }

  -- Tier 4
  local pure_single_ore_recipes = {
    ["angelsore1-pure-processing"] = {{ name ="iron-ore", amount = 1}, { name ="copper-ore", amount = 1}, { name ="tungsten-ore", amount = 3}, { name ="rutile-ore", amount = 3}},
    ["angelsore2-pure-processing"] = {{ name ="iron-ore", amount = 1}, { name ="copper-ore", amount = 1}, { name ="cobalt-ore", amount = 3}, { name ="tungsten-ore", amount = 3}},
    ["angelsore3-pure-processing"] = {{ name ="iron-ore", amount = 1}, { name ="copper-ore", amount = 1}, { name ="uranium-ore", amount = 3}, { name ="tungsten-ore", amount = 3}},
    ["angelsore4-pure-processing"] = {{ name ="iron-ore", amount = 1}, { name ="copper-ore", amount = 1}, { name ="cobalt-ore", amount = 3}, { name ="rutile-ore", amount = 3}},
    ["angelsore5-pure-processing"] = {{ name ="lead-ore", amount = 1}, { name ="nickel-ore", amount = 1}, { name ="uranium-ore", amount = 3}, { name ="gold-ore", amount = 3}},
    ["angelsore6-pure-processing"] = {{ name ="tin-ore", amount = 1}, { name ="quartz", amount = 1}, { name ="cobalt-ore", amount = 3}, { name ="gold-ore", amount = 3}},
    -- angelsore8-crystal-processing-- unchanged
    -- angelsore9-crystal-processing-- unchanged
  }

  local function change_recipe_result_amounts(list)
    for recipe_name, changes in pairs(list) do
      
      local recipe = data.raw.recipe[recipe_name]

      if recipe then
        local branches = { recipe, recipe.normal or nil, recipe.expensive or nil }

        for _, branch in pairs (branches) do
          if branch and branch.results then
            
            for _, result in pairs(branch.results) do
              for _, change in pairs(changes) do
                if result and result.name == change.name then
                  result.amount = change.amount
                end
              end
            end

          end
        end

      end
    end
  end

  change_recipe_result_amounts(crushed_catalystor_recipes)
  change_recipe_result_amounts(chunk_catalystor_recipes)
  change_recipe_result_amounts(crystal_catalystor_recipes)
  change_recipe_result_amounts(pure_catalystor_recipes)

  change_recipe_result_amounts(chunk_single_ore_recipes)
  change_recipe_result_amounts(crystal_single_ore_recipes)
  change_recipe_result_amounts(pure_single_ore_recipes)

end
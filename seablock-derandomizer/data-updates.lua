local function find_first_in_table(tab, condition_func)
  for index, item in pairs(tab) do
    if condition_func(item) then
      return index
    end
  end
  return -1
end

-- mineralized-crystallization
do
  local recipe = data.raw.recipe["sb-water-mineralized-crystallization"]
  local factor = 2.86
  --local factor = 1.45

  recipe.energy_required = factor * recipe.energy_required
  for _, ingredient in pairs(recipe.ingredients) do
    ingredient.amount = factor * ingredient.amount
  end

  local additional_results = {}
  for _, result in pairs(recipe.results) do
    if result.probability then
      local new_amount = factor * result.amount * result.probability
      local new_floored_amount = math.floor(new_amount)
      result.amount = 1
      result.probability = new_amount - new_floored_amount

      local new_result = {
        type = result.type,
        name = result.name,
        amount = new_floored_amount
      }
      table.insert(additional_results, new_result)
    else
      result.amount = factor * result.amount
    end
  end

  for _, new_result in pairs(additional_results) do

    local existing_index = find_first_in_table(recipe.results,
      function(result) return result.name == new_result.name end)

    table.insert(recipe.results, existing_index, new_result)
  end

end

-- local temperate_garden_a = data.raw.recipe["temperate-garden-a"]
-- local desert_garden_a = data.raw.recipe["desert-garden-a"]
-- local swamp_garden_a = data.raw.recipe["swamp-garden-a"]
do
  for _, prefix in pairs({"temperate", "desert", "swamp"}) do
    local variant = "a"
    local recipe_name = prefix.."-garden-"..variant
    log("Adjust recipe: "..recipe_name)
    local recipe = data.raw.recipe[recipe_name]

    local amounts =
    {
      [prefix.."-1-seed"] = 3,
      [prefix.."-2-seed"] = 2,
      [prefix.."-3-seed"] = 1,
      [prefix.."-4-seed"] = 0,
      [prefix.."-5-seed"] = 0,
    }

    local remove_result_names = {}

    for _, result in pairs(recipe.results) do
      if result.probability then
        local new_amount = amounts[result.name]
        if new_amount >= 1 then
          result.amount = new_amount
          result.probability = nil
        else
          table.insert(remove_result_names, result.name)
        end
      end
    end

    for _, result_name in pairs(remove_result_names) do
      local remove_index = find_first_in_table(recipe.results,
          function(result) return result.name == result_name end)

      if remove_index > 0 then
        table.remove(recipe.results, remove_index)
      end
    end
  end

end

-- local temperate_garden_b = data.raw.recipe["temperate-garden-b"]
-- local desert_garden_b = data.raw.recipe["desert-garden-b"]
-- local swamp_garden_b = data.raw.recipe["swamp-garden-b"]
do
  for _, prefix in pairs({"temperate", "desert", "swamp"}) do
    local variant = "b"
    local factor = 2
    local recipe_name = prefix.."-garden-"..variant
    log("Adjust recipe: "..recipe_name)
    local recipe = data.raw.recipe[recipe_name]

    recipe.energy_required = factor * recipe.energy_required
    for _, ingredient in pairs(recipe.ingredients) do
      ingredient.amount = factor * ingredient.amount
    end

    for _, result in pairs(recipe.results) do
      if result.probability then
        result.amount = factor * result.amount * result.probability
        result.probability = nil
      else
        result.amount = factor * result.amount
      end
    end
  end

end

-- for _, prefix in pairs({"temperate", "desert", "swamp"}) do
--   for variant, factor in pairs({["a"] = 2, ["b"] = 2 }) do

--     local recipe_name = prefix.."-garden-"..variant
--     log("Adjust recipe: "..recipe_name)
--     local recipe = data.raw.recipe[recipe_name]

--     recipe.energy_required = factor * recipe.energy_required
--     for _, ingredient in pairs(recipe.ingredients) do
--       ingredient.amount = factor * ingredient.amount
--     end

--     local remove_result_names = {}
--     for _, result in pairs(recipe.results) do
--       if result.probability then
--         local new_amount = factor * result.amount * result.probability
--         if new_amount >= 1 then
--           result.amount = factor * result.amount * result.probability
--           result.probability = nil
--         else
--           table.insert(remove_result_names, result.name)
--         end
--       else
--         result.amount = factor * result.amount
--       end
--     end

--     for _, result_name in pairs(remove_result_names) do
--       local remove_index = find_first_in_table(recipe.results,
--           function(result) return result.name == result_name end)

--       if remove_index > 0 then
--         table.remove(recipe.results, remove_index)
--       end
--     end
--   end
-- end
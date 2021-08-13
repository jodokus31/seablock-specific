local LibFunctions = {}

function LibFunctions.multiply_unit_value(table, propertyname, factor)
  local count, unit = (table[propertyname]):match("([%d\\.]+)([%a]+)")
  if count and factor and unit then
    table[propertyname] = (count*factor) .. unit
  end
end

function LibFunctions.adjust_recipe_enabled(recipe, enabled)
  recipe.enabled = enabled
  if recipe.normal then
    recipe.normal.enabled = enabled
  end
  if recipe.expensive then
    recipe.expensive.enabled = enabled
  end
end

return LibFunctions
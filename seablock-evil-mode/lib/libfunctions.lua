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

function LibFunctions.overwrite_setting(setting_type, setting_name, value)
  -- setting_type: [bool-setting | int-setting | double-setting | string-setting]
  if data.raw[setting_type] then
    local s = data.raw[setting_type][setting_name]
    if s then
      if setting_type == 'bool-setting' then
        s.forced_value = value
      else
        s.default_value = value
        s.allowed_values = {value}
      end
      s.hidden = true
    else
      log('Error: missing setting ' .. setting_name)
    end
  else
    log('Error: missing setting type ' .. setting_type)
  end
end

return LibFunctions
local LibFunctions = {}

function LibFunctions.multiply_unit_value(table, propertyname, factor)
  local count, unit = (table[propertyname]):match("([%d\\.]+)([%a]+)")
  if count and factor and unit then
    table[propertyname] = (count*factor) .. unit
  end
end

return LibFunctions
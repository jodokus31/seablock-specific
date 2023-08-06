local mall_crafting_items = {}

local explicit_item_inclusion = {}

for _, item in pairs(data.raw["item"]) do
  if item.place_result and not item.place_result:match("(.*pipe)$") then
    mall_crafting_items[item.name] = true
  elseif item.placed_as_equipment_result then
    mall_crafting_items[item.name] = true
  elseif explicit_item_inclusion[item.name] then
    mall_crafting_items[item.name] = true
  end
end

for _, item in pairs(data.raw["item-with-entity-data"]) do
  if item.place_result then
    mall_crafting_items[item.name] = true
  end
end

local special_item_groups = {
  "repair-tool",
  "rail-planner",
  "gun",
  "ammo",
  "capsule",
  "armor",
}

for _, item_group in pairs(special_item_groups) do
  for _, item in pairs(data.raw[item_group]) do
    mall_crafting_items[item.name] = true
  end
end

for _, recipe in pairs(data.raw.recipe) do
  if recipe.category == nil or recipe.category == "crafting" then
    local actual_recipe = recipe.normal or recipe.expensive or recipe
    local result
    if actual_recipe.results then
      for _, r in pairs(actual_recipe.results) do
        if r.type == "item" then
          result = r.name
          break
        end
      end
    else
      result = actual_recipe.result
    end

    if result then
      if mall_crafting_items[result] then
        recipe.category = "mall-crafting"
      end
    end
  end
end

local crafters = {}

for _, assembling_machine in pairs(data.raw["assembling-machine"]) do
  crafters[assembling_machine.name] = assembling_machine
end

do
  local character = data.raw["character"]["character"]
  crafters[character.name] = character
end

for _, crafter in pairs(crafters) do
  local contains_crafting = false
  for _, category in pairs(crafter.crafting_categories) do
    if category == "crafting" then
      contains_crafting = true
    end
  end

  if contains_crafting then
    table.insert(crafter.crafting_categories, "mall-crafting")
  end
end
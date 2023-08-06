local bobsmodactive = mods["bobassembly"]

do
  local mall_crafting_recipe_category = {
    type = "recipe-category",
    name = "mall-crafting"
  }
  data:extend(
  {
    mall_crafting_recipe_category
  })
end

do
  local tech_prerequisites
  if bobsmodactive then
    tech_prerequisites = {
      "automation-3",
      "logistic-robotics"
    }
  else
    tech_prerequisites = {
      "automation-2",
      "logistic-robotics"
    }
  end

  local tech_ingredients
  if bobsmodactive then
    tech_ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    }
  else
    tech_ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1}
    }
  end

  local lmam_assembling_machine_technology = {
    type = "technology",
    name = "lmam-assembling-machine",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__logistic-mall-assembling-machine__/graphics/technology/lmam-assembling-machine.png",
    localised_description = {"technology-description.lmam-assembling-machine"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "lmam-assembling-machine"
      }
    },
    prerequisites = tech_prerequisites,
    unit =
    {
      count = 75,
      ingredients = tech_ingredients,
      time = 60
    },
    order = bobsmodactive and "a-b-ca" or "a-b-ba"
  }

  data:extend(
  {
    lmam_assembling_machine_technology
  })
end

-- lmam-assembling-machine
do
  local lmam_assembling_machine_entity
  if bobsmodactive then
    lmam_assembling_machine_entity = util.table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
  else
    lmam_assembling_machine_entity = util.table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"])
  end

  lmam_assembling_machine_entity.name = "lmam-assembling-machine"
  lmam_assembling_machine_entity.minable.result = "lmam-assembling-machine"
  lmam_assembling_machine_entity.selection_box = {{-1.2, -1.2}, {1.2, 1.2}}
  lmam_assembling_machine_entity.next_upgrade = nil
  lmam_assembling_machine_entity.fast_replaceable_group = nil
  lmam_assembling_machine_entity.crafting_categories = { "mall-crafting" }
  --lmam_assembling_machine_entity.icon = "__logistic-mall-assembling-machine__/graphics/icon/logistic-mall-assembling-machine.png"

  local lmam_assembling_machine_item = util.table.deepcopy(data.raw["item"]["assembling-machine-3"])
  lmam_assembling_machine_item.name = "lmam-assembling-machine"
  lmam_assembling_machine_item.place_result = "lmam-assembling-machine"
  lmam_assembling_machine_item.icon = "__logistic-mall-assembling-machine__/graphics/icon/lmam-assembling-machine.png"

  data:extend(
  {
    lmam_assembling_machine_entity,
    lmam_assembling_machine_item,
  })
end

-- lmam-chest-requester
do
  local lmam_chest_requester_entity = util.table.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])
  lmam_chest_requester_entity.name = "lmam-chest-requester"
  lmam_chest_requester_entity.minable = { mining_time = 0.001, result = nil }
  lmam_chest_requester_entity.flags = {"player-creation"}
  lmam_chest_requester_entity.collision_mask = {}
  lmam_chest_requester_entity.fast_replaceable_group = "lmam-container"

  local lmam_chest_requester_item = util.table.deepcopy(data.raw["item"]["logistic-chest-requester"])
  lmam_chest_requester_item.name = "lmam-chest-requester"
  lmam_chest_requester_item.place_result = "lmam-chest-requester"
  data:extend(
  {
    lmam_chest_requester_entity,
    lmam_chest_requester_item,
  })
end

-- lmam-chest-buffer
do
  local lmam_chest_buffer_entity = util.table.deepcopy(data.raw["logistic-container"]["logistic-chest-buffer"])
  lmam_chest_buffer_entity.name = "lmam-chest-buffer"
  lmam_chest_buffer_entity.minable = { mining_time = 0.001, result = nil }
  lmam_chest_buffer_entity.flags = {"player-creation"}
  lmam_chest_buffer_entity.collision_mask = {}
  lmam_chest_buffer_entity.fast_replaceable_group = "lmam-container"

  local lmam_chest_buffer_item = util.table.deepcopy(data.raw["item"]["logistic-chest-buffer"])
  lmam_chest_buffer_item.name = "lmam-chest-buffer"
  lmam_chest_buffer_item.place_result = "lmam-chest-buffer"
  data:extend(
  {
    lmam_chest_buffer_entity,
    lmam_chest_buffer_item,
  })
end

-- lmam-chest-remainder
do
  local lmam_chest_remainder_entity = util.table.deepcopy(data.raw["logistic-container"]["logistic-chest-active-provider"])
  lmam_chest_remainder_entity.name = "lmam-chest-remainder"
  lmam_chest_remainder_entity.minable = { mining_time = 0.1, result = nil }
  lmam_chest_remainder_entity.fast_replaceable_group = "lmam-container"

  local lmam_chest_remainder_item = util.table.deepcopy(data.raw["item"]["logistic-chest-active-provider"])
  lmam_chest_remainder_item.name = "lmam-chest-remainder"
  lmam_chest_remainder_item.place_result = "lmam-chest-remainder"
  data:extend(
  {
    lmam_chest_remainder_entity,
    lmam_chest_remainder_item,
  })
end

-- lmam-input-inserter
do
  local lmam_input_inserter_entity = util.table.deepcopy(data.raw["inserter"]["stack-inserter"])
  lmam_input_inserter_entity.name = "lmam-input-inserter"
  lmam_input_inserter_entity.minable = {mining_time = 0.001, result = nil}
  lmam_input_inserter_entity.flags = {"player-creation"}
  lmam_input_inserter_entity.collision_mask = {}
  --lmam_input_inserter_entity.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
  --lmam_input_inserter_entity.selection_box = {{0,0}, {0,0}}
  lmam_input_inserter_entity.allow_custom_vectors = true
  lmam_input_inserter_entity.pickup_position = {0, -1}
  lmam_input_inserter_entity.insert_position = {1.2, 0}

  local lmam_input_inserter_item = util.table.deepcopy(data.raw["item"]["stack-inserter"])
  lmam_input_inserter_item.name = "lmam-input-inserter";
  lmam_input_inserter_item.place_result = "lmam-input-inserter";
  data:extend(
  {
    lmam_input_inserter_entity,
    lmam_input_inserter_item,
  })
end

-- lmam-output-inserter
do
  local lmam_output_inserter_entity = util.table.deepcopy(data.raw["inserter"]["stack-inserter"])
  lmam_output_inserter_entity.name = "lmam-output-inserter"
  lmam_output_inserter_entity.minable = {mining_time = 0.001, result = nil}
  lmam_output_inserter_entity.flags = {"player-creation"}
  lmam_output_inserter_entity.collision_mask = {}
  --lmam_output_inserter_entity.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
  --lmam_output_inserter_entity.selection_box = {{0,0}, {0,0}}
  lmam_output_inserter_entity.allow_custom_vectors = true
  lmam_output_inserter_entity.pickup_position = {-1, 0}
  lmam_output_inserter_entity.insert_position = {0, -1.2}

  local lmam_output_inserter_item = util.table.deepcopy(data.raw["item"]["stack-inserter"])
  lmam_output_inserter_item.name = "lmam-output-inserter";
  lmam_output_inserter_item.place_result = "lmam-output-inserter";
  data:extend(
  {
    lmam_output_inserter_entity,
    lmam_output_inserter_item
  })
end




do
  local recipe_ingredients
  if bobsmodactive then
    recipe_ingredients =
    {
      {"assembling-machine-3", 1},
      {"advanced-circuit", 2 },
      {"electronic-circuit", 20 },
      {"steel", 16 },
    }
  else
    recipe_ingredients =
    {
      {"assembling-machine-2", 1},
      {"advanced-circuit", 10 },
      {"electronic-circuit", 20 },
      {"steel", 16 },
    }
  end

  local lmam_assembling_machine_recipe = {
    type = "recipe",
    name = "lmam-assembling-machine",
    enabled = false,
    ingredients = recipe_ingredients,
    result = "lmam-assembling-machine"
  }

  data:extend(
  {
    lmam_assembling_machine_recipe,
  })
end

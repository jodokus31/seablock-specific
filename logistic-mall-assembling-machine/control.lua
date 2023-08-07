local function is_lmam(entity)
  return entity and entity.valid and entity.name == "lmam-assembling-machine"
end

local function clear_requests(lmam)

  for i = lmam.chest_input.request_slot_count, 1, -1 do
    lmam.chest_input.clear_request_slot(i)
  end

  for i = lmam.chest_output.request_slot_count, 1, -1 do
    lmam.chest_output.clear_request_slot(i)
  end

  lmam.inserter_output.get_or_create_control_behavior().circuit_condition = {
    condition = {
      comparator="<",
      first_signal = { type="item", name = nil },
      constant = nil
    }
  }
  -- lmam.inserter_output.get_or_create_control_behavior().connect_to_logistic_network = false
  -- lmam.inserter_output.get_or_create_control_behavior().logistic_condition = {
  --   condition = {
  --     comparator="<",
  --     first_signal = { type="item", name = nil },
  --     constant = nil
  --   }
  -- }
  lmam.selected_recipe_name = nil
end

local function get_placeable_entity(item_name)
  local item_prototype = game.item_prototypes[item_name]
  return item_prototype and item_prototype.place_result or nil
end

local function is_placed_as_equipment(item_name)
  local item_prototype = game.item_prototypes[item_name]
  return item_prototype and item_prototype.place_as_equipment_result ~= nil
end

local function get_special_item_group(item_name)
  local special_item_groups = {
    ["repair-tool"] = "repair-tool",
    ["rail-planner"] = "rail-planner",
    ["gun"] = "gun",
    ["ammo"] = "ammo",
    ["capsule"] = "capsule",
    ["armor"] = "armor",
  }
  local item_prototype = game.item_prototypes[item_name]
  return item_prototype and special_item_groups[item_prototype.type]
end

local function get_item_group(item_name)
  local item_group = get_special_item_group(item_name)

  if item_group then
    return item_group
  end

  local placeable_entity = get_placeable_entity(item_name)
  if placeable_entity and placeable_entity.type ~= "pipe" then
    return "placeable"
  elseif is_placed_as_equipment(item_name) then
    return "equipment"
  end
end

local function get_previous_tier_item_group(product_item_group, ingredient_name)
  if not product_item_group then
    return nil
  end

  local ingredient_item_group = get_item_group(ingredient_name)
  return ingredient_item_group
end

---comments
---@param lmam any
---@param recipe LuaRecipe
local function set_requests(lmam, recipe)

  local product_name
  for _, v in pairs(recipe.products) do
    if v.type == "item" then
      product_name = v.name
      break;
    end
  end

  local product_item_group = get_item_group(product_name)

  -- don't change input requests, when already existing
  -- this happens f.e. after blueprinting the lmam
  if lmam.chest_input.request_slot_count == 0 then
    local i = 1
    local request_from_buffers = false

    for _, v in pairs(recipe.ingredients) do
      if v.type == "item" then
        local ingredient_name = v.name
        local request_amount

        local previous_tier_item_group = get_previous_tier_item_group(product_item_group, ingredient_name)
        if previous_tier_item_group then
          request_amount = 1
          if previous_tier_item_group == "ammo" then
            request_amount = 20

          elseif previous_tier_item_group == "capsule" then
            request_amount = 2
          end

          request_from_buffers = true
        else
          request_amount = v.amount
          if product_item_group then
            if product_item_group == "placeable" then
              request_amount = 2*v.amount

            elseif product_item_group == "repair-tool"
                or product_item_group == "ammo"
                or product_item_group == "capsule" then
              request_amount = 5*v.amount

            elseif product_item_group == "rail-planner" then
              request_amount = 50
            end
          end
          local ingredient_prototype = game.item_prototypes[ingredient_name]
          local ingredient_stacksize = ingredient_prototype and ingredient_prototype.stack_size
          if ingredient_prototype and request_amount > ingredient_stacksize then
            request_amount = ingredient_stacksize
          end
        end

        lmam.chest_input.set_request_slot( { name = ingredient_name, count = request_amount }, i)
        i = i+1
      end
    end

    if request_from_buffers then
      lmam.chest_input.request_from_buffers = true
    end
  end

  -- don't change output conditions, when already existing
  -- this happens f.e. after blueprinting the lmam
  if lmam.chest_output.request_slot_count == 0 then

    local product_prototype = product_name and game.item_prototypes[product_name] or nil

    if product_name and product_prototype then
      local chest_output_capacity = lmam.chest_output.prototype.get_inventory_size(defines.inventory.chest) * product_prototype.stack_size
      if chest_output_capacity > 0 then
        lmam.chest_output.set_request_slot( { name = product_name, count = chest_output_capacity }, 1)
      end

      local limit = product_prototype.stack_size
      if product_item_group then
        if product_item_group == "placeable" then
          if product_prototype.stack_size > 10 then
            limit = 10
          elseif product_prototype.stack_size > 1 then
            limit = 4
          else
            limit = 1
          end
        elseif product_item_group == "gun"
            or product_item_group == "armor"
            or product_item_group == "equipment" then
          limit = 1
        elseif product_item_group == "rail-planner" then
          limit = 4*product_prototype.stack_size
        end
      end

      lmam.inserter_output.get_or_create_control_behavior().circuit_condition = {
        condition = {
          comparator="<",
          first_signal = { type="item", name = product_name },
          constant = limit
        }
      }
      -- lmam.inserter_output.get_or_create_control_behavior().connect_to_logistic_network = true
      -- lmam.inserter_output.get_or_create_control_behavior().logistic_condition = {
      --   condition = {
      --     comparator="<",
      --     first_signal = { type="item", name = product_name },
      --     constant = limit
      --   }
      -- }
    end
  end

  lmam.selected_recipe_name = recipe.name
end

local function update_lmam(lmam)
  if not is_lmam(lmam.entity) then
    log("None existing (nil) Lmam attempting to update logistics settings!")
    return;
  end

  local recipe = lmam.entity.get_recipe()

  if not recipe and not lmam.selected_recipe_name then
    return
  end

  if not recipe and lmam.selected_recipe_name then
    clear_requests(lmam)

  elseif recipe and not lmam.selected_recipe_name then
    set_requests(lmam, recipe)

  elseif recipe.name ~= lmam.selected_recipe_name then
    clear_requests(lmam)
    set_requests(lmam, recipe)
  end
end

global.Existing_Lmams = global.Existing_Lmams or {}

local function create_lmam(entity)
  local lmam = global.Existing_Lmams[entity.unit_number]
  if lmam then
    -- should not exist already
    return
  end

  local search_area = {
    { entity.position.x + 0.001 - 1.5, entity.position.y + 0.001 - 1.5},
    { entity.position.x - 0.001 + 1.5, entity.position.y - 0.001 + 1.5}
  }

  local chest_input, chest_output, inserter_input, inserter_output
  -- try revive belonging entities, if any ghosts exist, f.e. when blueprinting.
  local ghosts = entity.surface.find_entities(search_area)
  for _, ghost in pairs (ghosts) do
    if ghost.valid then
      if ghost.name == "entity-ghost" then
        if ghost.ghost_name == "lmam-chest-requester" then
          _, chest_input = ghost.revive()
        elseif ghost.ghost_name == "lmam-chest-buffer" then
          _, chest_output = ghost.revive()
        elseif ghost.ghost_name == "lmam-input-inserter" then
          _, inserter_input = ghost.revive()
        elseif ghost.ghost_name == "lmam-output-inserter" then
          _, inserter_output = ghost.revive()
        end
        --somehow, the entity already exists. f.e. editor mode
      elseif ghost.name == "lmam-chest-requester" then
        chest_input = ghost
      elseif ghost.name == "lmam-chest-buffer" then
        chest_output = ghost
      elseif ghost.name == "lmam-input-inserter" then
        inserter_input = ghost
      elseif ghost.name == "lmam-output-inserter" then
        inserter_output = ghost
      end
    end
  end

  chest_input = chest_input or entity.surface.create_entity
  {
    name = "lmam-chest-requester",
    position = {
      (entity.position.x)-0.8,
      (entity.position.y)-0.8
    },
    force = entity.force
  }
  chest_input.minable = false
  chest_input.destructible = false

  chest_output = chest_output or entity.surface.create_entity
  {
    name = "lmam-chest-buffer",
    position = {
      (entity.position.x)+1,
      (entity.position.y)-0.8
    },
    force = entity.force
  }
  chest_output.minable = false
  chest_output.destructible = false

  inserter_input = inserter_input or entity.surface.create_entity
  {
    name = "lmam-input-inserter",
    position =
    {
      (entity.position.x)-1.5,
      (entity.position.y)
    },
    force = entity.force
  }
  inserter_input.minable = false
  inserter_input.destructible = false

  inserter_output = inserter_output or entity.surface.create_entity
  {
    name = "lmam-output-inserter",
    position =
    {
      (entity.position.x)+0.5,
      (entity.position.y)
    },
    force = entity.force
  }
  inserter_output.minable = false
  inserter_output.destructible = false

  chest_output.connect_neighbour({target_entity=inserter_output, wire=defines.wire_type.red})
  --inserter_output.get_or_create_control_behavior()

  lmam =
  {
    entity = entity,
    chest_input = chest_input,
    chest_output = chest_output,
    inserter_input = inserter_input,
    inserter_output = inserter_output
  }

  global.Existing_Lmams[entity.unit_number] = lmam
end

local function replace_chest(entity, player)
  if entity and entity.valid then
    if not entity.has_items_inside() then
      return
    end

    entity.minable = true
    entity.destructible = true
    local new_entity = entity.surface.create_entity {
      name = "lmam-chest-remainder",
      position = entity.position,
      direction = entity.direction,
      force = entity.force,
      fast_replace = true,
      player = player,
      --spill = false,
      --type = nil,
      raise_built = true,
    }

    if new_entity.valid then
      new_entity.minable = true
      new_entity.destructible = true
    else
      return
    end

    return new_entity
  end
end

local function die_entity(entity)
  if entity and entity.valid then
    entity.destructible = true
    entity.die();
  end
end

local function destroy_entity(entity)
  if entity and entity.valid then
    entity.destroy();
  end
end

local REMOVE_MODE =
{
  by_player = 1,
  by_robot = 2,
  died = 3,
  script_destroyed = 4,
}

local function handle_chest(chest, player, force, remove_mode)
  local chest_remainder_input = replace_chest(chest, player)
  if chest_remainder_input then
    chest_remainder_input.order_deconstruction(force, player)
    if remove_mode == REMOVE_MODE.by_player then
      player.mine_entity(chest_remainder_input, false)
    end

  else
    destroy_entity(chest)
  end
end

local function handle_inserter(inserter, player, force, remove_mode)
  if inserter and inserter.valid and inserter.has_items_inside() then
    inserter.minable = true
    inserter.destructible = true
    inserter.order_deconstruction(force, player)
    if remove_mode == REMOVE_MODE.by_player then
      player.mine_entity(inserter, false)
    end

  else
    destroy_entity(inserter)
  end
end

local function remove_lmam(entity, player, force, remove_mode)
  local lmam = global.Existing_Lmams[entity.unit_number]
  if not lmam then return end

  if remove_mode == REMOVE_MODE.died then
    die_entity(lmam.chest_input)
    die_entity(lmam.chest_output)
    die_entity(lmam.inserter_input)
    die_entity(lmam.inserter_output)

  elseif remove_mode == REMOVE_MODE.script_destroyed then
    destroy_entity(lmam.chest_input)
    destroy_entity(lmam.chest_output)
    destroy_entity(lmam.inserter_input)
    destroy_entity(lmam.inserter_output)

  else
    handle_chest(lmam.chest_input, player, force, remove_mode)
    handle_chest(lmam.chest_output, player, force, remove_mode)

    handle_inserter(lmam.inserter_input, player, force, remove_mode)
    handle_inserter(lmam.inserter_output, player, force, remove_mode)
  end

  lmam.selected_recipe_name = nil
  global.Existing_Lmams[entity.unit_number] = nil
end

local function on_entity_created(event)
  local entity = event.entity or event.created_entity or event.destination
  if is_lmam(entity) then
    create_lmam(entity)
  end
end

local function on_entity_remove(event, remove_mode)
  local entity = event.entity
  local player, force

  if remove_mode == REMOVE_MODE.by_player then
    player = event.player_index and game.players[event.player_index]
    force = player.force
  elseif remove_mode == REMOVE_MODE.by_robot then
    force = event.robot.force
    for _, p in pairs(game.connected_players) do
      if p.force.name == force.name then
        player = player
      end
    end
  end

  if is_lmam(entity) then
    remove_lmam(entity, player, force, remove_mode)
  end
end

local filters = {{ filter="type", type="assembling-machine" }}

script.on_event(defines.events.on_built_entity, on_entity_created, filters)
script.on_event(defines.events.on_robot_built_entity, on_entity_created, filters)
script.on_event(defines.events.script_raised_built, on_entity_created)
script.on_event(defines.events.script_raised_revive, on_entity_created)
script.on_event(defines.events.on_entity_cloned, on_entity_created)


script.on_event(defines.events.on_pre_player_mined_item, function (event) on_entity_remove(event, REMOVE_MODE.by_player) end, filters)
script.on_event(defines.events.on_robot_pre_mined, function (event) on_entity_remove(event, REMOVE_MODE.by_robot) end, filters)
script.on_event(defines.events.on_entity_died, function (event) on_entity_remove(event, REMOVE_MODE.died) end, filters)
script.on_event(defines.events.script_raised_destroy, function (event) on_entity_remove(event, REMOVE_MODE.script_destroyed) end)


script.on_nth_tick(60, function(event)
  for _, lmam in pairs(global.Existing_Lmams) do
    update_lmam(lmam)
  end
end)

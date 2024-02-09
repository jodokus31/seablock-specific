script.on_init(function()
  global.SeablockEvilMode_Statistics_FluidRemoved = {}
end)

local players_with_enabled_logs = nil
local function ensure_players_with_enabled_logs_is_filled()
  if players_with_enabled_logs then
    return players_with_enabled_logs
  end

  players_with_enabled_logs = {}
  for _, p in pairs(game.players) do
    if settings.get_player_settings(p.index)["seablock-evil-mode-enable-fluid-removed-log"].value then
      players_with_enabled_logs[p.index] = true
    end
  end
  return players_with_enabled_logs
end

local function find_affected_players(event)
  players_with_enabled_logs = ensure_players_with_enabled_logs_is_filled()
  if not next(players_with_enabled_logs) then
    return {}
  end

  local players = {}
  if event.player_index then
    local player = game.players[event.player_index]
    if player then
      table.insert(players, player)
    end
  elseif event.entity and event.entity.force then
    local force = event.entity.force;
    for player_index, _ in pairs(players_with_enabled_logs) do
      local player = game.players[player_index]
      if player.force.name == force.name then
        table.insert(players, player)
      end
    end
  end
  return players
end

local function on_mined_or_died_fluid_container(event)
  local entity = event.entity

  global.SeablockEvilMode_Statistics_FluidRemoved =
    global.SeablockEvilMode_Statistics_FluidRemoved or {}

  local fluid_contents = entity.get_fluid_contents()
  local players = nil

  for fluid, amount in pairs(fluid_contents) do
    global.SeablockEvilMode_Statistics_FluidRemoved[fluid] = 
      (global.SeablockEvilMode_Statistics_FluidRemoved[fluid] or 0) + amount

    players = players or find_affected_players(event)

    for _, player in pairs(players) do
      local remove_fluid_text = string.format("fluid removed %s: %.4f (overall: %.4f)",
          fluid, amount, global.SeablockEvilMode_Statistics_FluidRemoved[fluid])
      player.print(remove_fluid_text)
    end
  end
end

script.on_event(defines.events.on_player_mined_entity, on_mined_or_died_fluid_container)
script.on_event(defines.events.on_robot_mined_entity, on_mined_or_died_fluid_container)

local function on_player_flushed_fluid(event)
  -- player_index 	:: uint Index of the player
  -- fluid 	:: string Name of a fluid that was flushed
  -- amount 	:: double Amount of fluid that was removed
  -- entity 	:: LuaEntity Entity from which flush was performed
  -- only_this_entity 	:: boolean True if flush was requested only on this entity
  -- name 	:: defines.events Identifier of the event
  -- tick 	:: uint Tick the event was generated.

  local amount = event.amount
  local fluid = event.fluid

  global.SeablockEvilMode_Statistics_FluidRemoved = global.SeablockEvilMode_Statistics_FluidRemoved or {}
  global.SeablockEvilMode_Statistics_FluidRemoved[fluid] = (global.SeablockEvilMode_Statistics_FluidRemoved[fluid] or 0) + amount

  if not event.player_index then
    return
  end

  players_with_enabled_logs = ensure_players_with_enabled_logs_is_filled()
  if players_with_enabled_logs[event.player_index] then
    local player = game.players[event.player_index]
    if player then
      local remove_fluid_text = 
        string.format("fluid removed %s: %.4f (overall: %.4f)",
          fluid, amount, global.SeablockEvilMode_Statistics_FluidRemoved[fluid])
    
      player.print(remove_fluid_text)
    end
  end
end

local function spill_all_inventories(entity)
  for inventory_type = 1, entity.get_max_inventory_index() do
    local inventory = entity.get_inventory(inventory_type)
    if inventory then
      for item_name, count in pairs(inventory.get_contents()) do
        -- don't spill on belts
        entity.surface.spill_item_stack(entity.position, {name = item_name, count = count}, false, nil, false)
      end
    end
  end
end

script.on_event(defines.events.on_player_flushed_fluid, on_player_flushed_fluid)

local function on_entity_died_handler(event)
  local entity = event.entity

  spill_all_inventories(entity)

  -- in case the died entity contained fluids
  on_mined_or_died_fluid_container(event)
end

local function on_character_corpse_expired(event)
  if not event.corpse then return end

  spill_all_inventories(event.corpse)
end

script.on_event(defines.events.on_entity_died, on_entity_died_handler)
script.on_event(defines.events.on_character_corpse_expired, on_character_corpse_expired)

script.on_event(defines.events.on_runtime_mod_setting_changed, function()
  -- simply reset the local cache, when anything changes.
  players_with_enabled_logs = nil
end)

commands.add_command(
  "seablock_evil_mode_statistics_fluid_removed",
  "displays a statistic about how much fluids were removed by picking up entites",
  function()
    if next(global.SeablockEvilMode_Statistics_FluidRemoved) then
      game.print("fluids removed by picking up entites:")
      for name, amount in pairs(global.SeablockEvilMode_Statistics_FluidRemoved) do
        local remove_fluid_text = string.format("%s: %.4f", name, amount)
        game.print(remove_fluid_text)
      end
    end
  end)

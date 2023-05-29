script.on_init(function()
  global.SeablockEvilMode_Statistics_FluidRemoved = {}
end)

function on_mined_or_died_fluid_container(event)
  
  local entity = event.entity
    
  global.SeablockEvilMode_Statistics_FluidRemoved = 
    global.SeablockEvilMode_Statistics_FluidRemoved or {}
  
  local fluid_contents = entity.get_fluid_contents()
  
  for fluid, amount in pairs(fluid_contents) do
    global.SeablockEvilMode_Statistics_FluidRemoved[fluid] = 
      (global.SeablockEvilMode_Statistics_FluidRemoved[fluid] or 0) + amount
    
    local players = {}
    if event.player_index then
      player = game.players[event.player_index]
      if player then
        table.insert(players, player)
      end
    elseif event.cause then
      player = event.cause.player
      if player then
        table.insert(players, player)
      end
    elseif event.robot and event.robot.force then
      for _, player in pairs(game.players) do
        if player.force.name == event.robot.force.name then
          table.insert(players, player)
        end
      end
    end

    for _, player in pairs(players) do
      if settings.get_player_settings(player.index)["seablock-evil-mode-enable-fluid-removed-log"].value then
        local remove_fluid_text = 
          string.format("fluid removed %s: %.4f (overall: %.4f)", 
            fluid, amount, global.SeablockEvilMode_Statistics_FluidRemoved[fluid])
        
        player.print(remove_fluid_text)
      end
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

  if settings.get_player_settings(event.player_index)["seablock-evil-mode-enable-fluid-removed-log"].value then
    local player = game.players[event.player_index]
    if player then
      local remove_fluid_text = 
        string.format("fluid removed %s: %.4f (overall: %.4f)", 
          fluid, amount, global.SeablockEvilMode_Statistics_FluidRemoved[fluid])
    
      player.print(remove_fluid_text)
    end
  end
end

script.on_event(defines.events.on_player_flushed_fluid, on_player_flushed_fluid)

function on_entity_died_handler(event)
  local entity = event.entity
  
  for inventory_type = 1, 10 do
    local inventory = entity.get_inventory(inventory_type)
    if inventory then
      for item_name, count in pairs(inventory.get_contents()) do
        -- don't spill on belts
        entity.surface.spill_item_stack(entity.position, {name = item_name, count = count}, false, nil, false)
      end
    end
  end

  -- in case the died entity contained fluids
  on_mined_or_died_fluid_container(event)
end

script.on_event(defines.events.on_entity_died, on_entity_died_handler)

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

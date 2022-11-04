script.on_init(function()
  global.SeablockEvilMode_Statistics_FluidRemoved = {}
end)

function on_mined_or_died_fluid_container(event)
  
  local entity = event.entity
    
  global.SeablockEvilMode_Statistics_FluidRemoved = 
    global.SeablockEvilMode_Statistics_FluidRemoved or {}
  
  local fluid_contents = entity.get_fluid_contents()
  
  for name, amount in pairs(fluid_contents) do
    global.SeablockEvilMode_Statistics_FluidRemoved[name] = 
      (global.SeablockEvilMode_Statistics_FluidRemoved[name] or 0) + amount
    
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
            name, amount, global.SeablockEvilMode_Statistics_FluidRemoved[name])
        
        player.print(remove_fluid_text)
      end
    end
  end
end

script.on_event(defines.events.on_player_mined_entity, on_mined_or_died_fluid_container)
script.on_event(defines.events.on_robot_mined_entity, on_mined_or_died_fluid_container)

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

script.on_init(function()
  global.SeablockEvilMode_Statistics_FluidRemoved = {}
end)

function on_entity_died_handler(event)
  local entity = event.entity
  
  for i = 1, 10 do
    if entity.get_inventory(i) then
      for item_name, count in pairs(event.entity.get_inventory(i).get_contents()) do
        entity.surface.spill_item_stack(entity.position, {name = item_name, count = count} )
      end
    end
  end
end

local filter_container_types = {
  {filter = "type", type = "container"},
  {filter = "type", type = "cargo-wagon"},
  {filter = "type", type = "logistic-container"},
  {filter = "type", type = "car"},
}

script.on_event(defines.events.on_entity_died, on_entity_died_handler, filter_container_types)

function on_mined_fluid_container(event)
  
  local entity = event.entity
    
  global.SeablockEvilMode_Statistics_FluidRemoved = 
    global.SeablockEvilMode_Statistics_FluidRemoved or {}
  
  local fluid_contents = entity.get_fluid_contents()
  
  for name, amount in pairs(fluid_contents) do
    global.SeablockEvilMode_Statistics_FluidRemoved[name] = 
      (global.SeablockEvilMode_Statistics_FluidRemoved[name] or 0) + amount
    
    if settings.startup['seablock-evil-mode-enable-fluid-removed-log'].value then
      local remove_fluid_text = 
        string.format("fluid removed %s: %.4f (overall: %.4f)", 
          name, amount, global.SeablockEvilMode_Statistics_FluidRemoved[name])
      
      game.print(remove_fluid_text)
    end
  end  
end

local filter_fluid_types = {
  {filter = "type", type = "storage-tank"},
  {filter = "type", type = "fluid-wagon", mode = "or"},
  {filter = "type", type = "pipe", mode = "or"},
  {filter = "type", type = "pipe-to-ground", mode = "or"},
  {filter = "type", type = "assembling-machine", mode = "or"},
}

script.on_event(defines.events.on_player_mined_entity, on_mined_fluid_container, filter_fluid_types)
script.on_event(defines.events.on_robot_mined_entity, on_mined_fluid_container, filter_fluid_types)


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

function on_entity_died_handler(event)
  local entity = event.entity
  if entity.type == "container" 
      or entity.type == "cargo-wagon" 
      or entity.type == "logistic-container" 
      or entity.type == "car" then

    for i = 1, 10 do
      if entity.get_inventory(i) then
        for item_name, count in pairs(event.entity.get_inventory(i).get_contents()) do
          entity.surface.spill_item_stack(entity.position, {name = item_name, count = count} )
        end
      end
    end
  end
end
script.on_event(defines.events.on_entity_died, on_entity_died_handler)


-- unfortunately is not possible to prevent picking up fluid tanks.
-- function on_pre_mined_entity(event)
-- end

-- script.on_event(defines.on_pre_player_mined_item, on_pre_mined_entity)
-- script.on_event(defines.on_robot_pre_mined, on_pre_mined_entity)
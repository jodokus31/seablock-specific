local GLOBAL_RECHECK_INTERVAL = 30

local player_data = {}
function get_player_data(index)
  player_data[index] = player_data[index] or {}
  return player_data[index]
end

local product_to_recipes_map = nil
function get_product_to_recipes_map()
  if not product_to_recipes_map then
    product_to_recipes_map = {}
    local all_prototypes = game.get_filtered_recipe_prototypes({{filter = "has-product-item"}})
    --game.print("all_prototypes count: " .. #all_prototypes)
    for recipe_name, recipe_prototype in pairs(all_prototypes) do
      -- game.print("recipe_prototype ".. recipe_prototype.name)
      for _, product in pairs(recipe_prototype.products) do
        local product_name = product.name
        --game.print("product_name: "..product_name)
        -- no need to cache the recipe, which is named like the produced item. This recipe would have already found.
        if product_name ~= recipe_name then
          --game.print("product_name: "..product_name)
          product_to_recipes_map[product_name] = product_to_recipes_map[product_name] or {}
          product_to_recipes_map[product_name].unsorted = product_to_recipes_map[product_name].unsorted or {}
          table.insert(product_to_recipes_map[product_name].unsorted, recipe_name)
        end
      end
    end
    -- local count = 0
    -- for _ in pairs(product_to_recipes_map) do count = count+1 end
    -- game.print("product_to_recipes_map: "..count)
  end
  return product_to_recipes_map
end

function ensure_sorted_by_prio(recipe_list, player, search_name)
  if not recipe_list.sorted and recipe_list.unsorted then
    
    local sort_list = {}
    local index = 1

    for _, recipe_name in pairs(recipe_list.unsorted) do
      local recipe = player.force.recipes[recipe_name]
      local recipe_prototype = recipe and recipe.prototype
      if recipe_prototype then
        
        local product_amount_prio = 3
        if #recipe_prototype.products <= 1 then
          product_amount_prio = 1
        elseif recipe_prototype.main_product and recipe_prototype.main_product.name == search_name then
          product_amount_prio = 2
        end

        local product = nil
        for _, p in pairs(recipe_prototype.products) do
          if p.name == search_name then
            product = p
            break
          end
        end

        if product then
          local amount = (product.amount or (product.amount_min + product.amount_max)/2) * (product.probability or 1)
          amount = ((amount == 0) and 1) or amount
          table.insert(sort_list, 
            { 
              product_amount_prio = product_amount_prio,
              energy_per_amount = recipe_prototype.energy / amount,
              index = index,
              recipe_name = recipe_prototype.name,
            })

          index = index+1
        end
      end
    end

    table.sort(sort_list, 
      function(a,b)
        if a.product_amount_prio > b.product_amount_prio then return false end
        if a.energy_per_amount > b.energy_per_amount then return false end
        if a.index > b.index then return false end -- unique criteria
        return true
      end)

    recipe_list.sorted = {}
    for _, sort_item in pairs(sort_list) do
      -- player.print("sort_item: " ..serpent.block(sort_item))
      table.insert(recipe_list.sorted, sort_item.recipe_name)
    end
    recipe_list.unsorted = nil
  end
end

function get_recipe_for_name(search_name, player)
  if not player then return true, nil end  
  local cheat = player.cheat_mode

  if not search_name then return true, nil end
  
  search_name = search_name:gsub("%s+", "")
  if search_name == "" then return true, nil end

  -- if the name is a recipe, just use that.
  local direct_recipe = player.force.recipes[search_name]
  if direct_recipe then 
    if (cheat or (direct_recipe.enabled and player.get_craftable_count(direct_recipe) > 0)) then
      return true, direct_recipe
    else
      return true, nil
    end
  end

  local recipes_map = get_product_to_recipes_map()
  local recipe_list = recipes_map[search_name]
  if not recipe_list then return false, nil end

  ensure_sorted_by_prio(recipe_list, player, search_name)

  if not recipe_list.sorted or #recipe_list.sorted <= 0 then return false, nil end

  for _, recipe_name in pairs(recipe_list.sorted) do
    -- get first recipe from the sorted list which is craftable
    local recipe = player.force.recipes[recipe_name]
    if recipe then 
      if (cheat or (recipe.enabled and player.get_craftable_count(recipe) > 0)) then
        return true, recipe
      end
    end
  end
end

function hint_missing_recipes(player, not_existing_recipes_string)
  player.print("idle-crafter: Those items or recipes were not found: " .. not_existing_recipes_string)
end

function hint_general(player)
  player.print("idle-crafter: Please enter an item or recipe name (internal name) in mod settings per player.")
  player.print("idle-crafter: The internal name can be seen, if you press F4 and enable show-debug-info-in-tooltip in always tab")
  player.print("idle-crafter: If you hover over an item or recipe in crafting view you can use item-name or recipe-name")
end

function split_setting_string(input)
  local delimiter = "%s,;" -- whitespace, "," or ";"
  local output = {}
  for split in string.gmatch(input, "([^"..delimiter.."]+)") do
     table.insert(output, split)
  end
  return output
end

function check_player(player, force_check)
  if player.valid and player.connected and player.controller_type == defines.controllers.character then
    local data = get_player_data(player.index)
    
    if data.error_state then
      return
    end

    if not force_check and data.recipe_not_craftable_count then
      if data.recipe_not_craftable_count > 50 and (data.recipe_not_craftable_count%10) > 0 then
        data.recipe_not_craftable_count = data.recipe_not_craftable_count+1
        return
      elseif data.recipe_not_craftable_count > 10 and (data.recipe_not_craftable_count%5) > 0 then
        data.recipe_not_craftable_count = data.recipe_not_craftable_count+1
        return
      end
    end

    if not force_check and data.recheck_tick and data.recheck_tick > game.tick then
      return
    end

    if player.crafting_queue_size > 1 then
      return
    end

    data.item_or_recipe_names = data.item_or_recipe_names or settings
      .get_player_settings(player.index)["idle-crafter-product-or-recipe-names"].value
    
    local doRequeue = false
    local time_remaining = 0
    if player.crafting_queue_size == 1 then
      local _, queue_item = next(player.crafting_queue)
      if queue_item and queue_item.count <= 2 then
        local recipe = player.force.recipes[queue_item.recipe]
        time_remaining = (queue_item.count*recipe.energy) - (recipe.energy*player.crafting_queue_progress)
        --player.print("time_remaining: " .. time_remaining)
      
        if time_remaining*60 < 1.5*GLOBAL_RECHECK_INTERVAL then
          doRequeue = true
        end
      end
    else
      doRequeue = true;
    end

    if doRequeue then
      local recipe_exists = true
      local not_existing_recipes = {}

      local entries = split_setting_string(data.item_or_recipe_names)
      for _, entry in pairs(entries) do
        local name_with_count_pattern = "^([^=]+)=(%d+)$"
        local name, count_str = entry:match(name_with_count_pattern)
        local count = tonumber(count_str)

        -- player.print("entry, name, count " .. entry .. ", ".. (name or "nil") .. ", ".. (count or "nil"))

        if not name then
          name = entry
        end
        
        local is_item = false
        local player_item_count = 0
        if count then
          local item_prototype = game.item_prototypes[name]
          -- player.print("item_prototype " .. serpent.block(item_prototype))
          if item_prototype then
            is_item = true
            player_item_count = player.get_item_count(name)
          end
        end

        if not count or (player_item_count < count) then
          recipe_exists, recipe = get_recipe_for_name(name, player)
          if recipe_exists then
            if recipe then -- recipe is only set, when it's craftable by player
              local craft_amount = 1
              
              -- prevent over craft
              if count and not is_item then
                -- name is not an item but a recipe, so take first product of recipe
                local _, first_product = next(recipe.products)
                player_item_count = (first_product and player.get_item_count(first_product.name)) or 0
              end

              if count and (count - player_item_count)<=2 then
                local _, queue_item = next(player.crafting_queue or {})

                if queue_item then
                  local queue_recipe = player.force.recipes[queue_item.recipe]
                  if queue_recipe.name == recipe.name then
                    player_item_count = player_item_count+queue_item.count
                  end
                end
                if (player_item_count + craft_amount) > count then
                  craft_amount = math.min(count - player_item_count, craft_amount)
                end  
              end

              if craft_amount > 0 then
                player.begin_crafting 
                  { 
                    count = craft_amount,
                    recipe = recipe, 
                    silent = true 
                  }

                data.recheck_tick = game.tick + time_remaining*60 + recipe.energy*60 - GLOBAL_RECHECK_INTERVAL
                data.recipe_not_craftable_count = 0
                break
              end
            else
              -- player.print("doRequeue failed")
              data.recipe_not_craftable_count = (data.recipe_not_craftable_count or 0) + 1
            end
          else
            table.insert(not_existing_recipes, name)
          end

        end
      end

      local not_existing_recipes_string
      if next(not_existing_recipes) then
        not_existing_recipes_string = table.concat(not_existing_recipes, ", ")
      end

      if recipe_exists and not_existing_recipes_string then
        -- report only once as long as nothing changes
        if not data.reported_recipes or data.reported_recipes ~= not_existing_recipes_string then
          data.reported_recipes = not_existing_recipes_string
          hint_missing_recipes(player, not_existing_recipes_string)
        end
      end

      if not recipe_exists then
        data.error_state = true
        hint_missing_recipes(player, not_existing_recipes_string)
        hint_general(player)
      end
    end
  end
end

script.on_nth_tick(GLOBAL_RECHECK_INTERVAL, function(event)
  for _, player in pairs(game.connected_players) do
    check_player(player)
  end
end)

script.on_event(defines.events.on_player_crafted_item, function(event)
  local player = game.players[event.player_index]
  check_player(player, true)
end)

script.on_event(defines.events.on_player_cancelled_crafting, function(event)
  local player = game.players[event.player_index]
  local data = get_player_data(event.player_index)
  if player.crafting_queue_size <= 1 then
    data.recheck_tick = 0
  end
  check_player(player, true)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "idle-crafter-product-or-recipe-names" then
    local data = get_player_data(event.player_index)
    data.item_or_recipe_names = settings.get_player_settings(event.player_index)[event.setting].value
    data.reported_recipes = nil
    data.error_state = false
  end
end)

function check_settings_and_hint()
  for _, player in pairs(game.connected_players) do
    local data = get_player_data(player.index)
    data.item_or_recipe_names = settings.get_player_settings(player.index)["idle-crafter-product-or-recipe-names"].value
    if not data.item_or_recipe_names or data.item_or_recipe_names == "" then
      hint_general(player)
    end
  end
end

script.on_init(function()
  global.player_data = {}
  player_data = {}
  check_settings_and_hint()
end)

script.on_configuration_changed(function()
  global.player_data = {}
  player_data = {}
  check_settings_and_hint()
end)

script.on_load(function()
  player_data = global.player_data
end)

local burner = {}

local logger = require("scripts/logger")

local function check_fuel_category(burner_entity, fuel_category)
	if not fuel_category then
		return false
	end

	local energy_source = burner_entity.prototype and burner_entity.prototype.burner_prototype
	if not energy_source then
		return false
	end

	if energy_source.fuel_categories[fuel_category] then
		return true
	end

	if not next(energy_source.fuel_categories) and fuel_category == "chemical" then
		return true
	end

	return false
end

local function find_fuel_from_player(player, burner_entity, state)
	if state.last_fuel_item_name and player.get_item_count(state.last_fuel_item_name) > 0 then
		return state.last_fuel_item_name
	end

	state.last_fuel_item_name = nil

	local fuel_item_name = nil
	local highest_fuel_value = 0
	for itemname, amount in pairs(player.get_main_inventory().get_contents()) do
		if amount > 0 then
			local item_prot = game.item_prototypes[itemname]
			local item_fuel_value = item_prot and item_prot.fuel_value or 0
			if item_prot and item_fuel_value > highest_fuel_value then
				if check_fuel_category(burner_entity, item_prot.fuel_category) then
					highest_fuel_value = item_fuel_value
					fuel_item_name = itemname
				end
			end
		end
	end
	state.last_fuel_item_name = fuel_item_name
	return fuel_item_name
end

local function get_max_amount(burner_entity, state)
	if burner_entity.type == "boiler" then
		return state.setting_max_fuel_boiler
  elseif burner_entity.type == "inserter" then
    return state.setting_max_fuel_inserter
  end
	return state.setting_max_fuel_furnace
end

function burner.topupfuel(player, burner_entity, state)

	local flying_text_infos = {}

	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return flying_text_infos
	end

	local fuel_inventory = burner_entity.get_inventory(defines.inventory.fuel)
	if not fuel_inventory or not fuel_inventory.valid then
		return flying_text_infos
	end

	local fuel_item_name = nil
	local existing_fuel_amount = 0
	for itemname, amount in pairs(fuel_inventory.get_contents()) do
		local item_prot = game.item_prototypes[itemname]
		if item_prot and item_prot.fuel_value > 0.001 then
			if check_fuel_category(burner_entity, item_prot.fuel_category) then
				fuel_item_name = itemname
				existing_fuel_amount = amount
			end
		end
	end

  local max_amount = get_max_amount(burner_entity, state)
  if max_amount and existing_fuel_amount >= max_amount then
    -- already enough
    return flying_text_infos
  end

	if not fuel_item_name then
		fuel_item_name = find_fuel_from_player(player, burner_entity, state)
	end

	if not fuel_item_name then
		-- no fuel in player's inventory
		return flying_text_infos
	end

  if not max_amount then
    max_amount = get_max_amount(burner_entity, state)
  end

	local transfer_amount = max_amount - existing_fuel_amount

	local player_count = player.get_item_count(fuel_item_name)
	if transfer_amount > player_count then
		transfer_amount = player_count
	end

	local transfer_amount_stack = { name = fuel_item_name, count = transfer_amount }

	if transfer_amount > 0 and fuel_inventory.can_insert(transfer_amount_stack) then

		local actually_inserted = fuel_inventory.insert(transfer_amount_stack)
		transfer_amount_stack.count = actually_inserted
		player.remove_item(transfer_amount_stack)
		flying_text_infos[fuel_item_name] = {
      amount = -actually_inserted,
      total = player.get_item_count(fuel_item_name) or 0
    }

	end
	return flying_text_infos
end

local function pickupitemsfrominventory(player, inventory, flying_text_infos)
	if not inventory or not inventory.valid then return end

	for itemname, amount in pairs(inventory.get_contents()) do
    local transfer_amount = amount
    local transfer_amount_stack = { name = itemname, count = transfer_amount }
    if transfer_amount > 0 and player.can_insert(transfer_amount_stack) then
      local actually_inserted = player.insert(transfer_amount_stack)
      transfer_amount_stack.count = actually_inserted
      logger.print(player, "move " .. actually_inserted .. " " .. itemname .. " to player")
      inventory.remove(transfer_amount_stack)
      flying_text_infos[itemname] = { amount = actually_inserted, total = player.get_item_count(itemname) or 0 }
    end
  end
end

function burner.pickupitems(player, fuel_inventory, other_inventory)

  local flying_text_infos = {}

	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return flying_text_infos
	end

  logger.print(player, "pickupcraftingslots to player")

  if fuel_inventory and fuel_inventory.valid then
    pickupitemsfrominventory(player, fuel_inventory, flying_text_infos)
  end

  if other_inventory and other_inventory.valid then
	  pickupitemsfrominventory(player, other_inventory, flying_text_infos)
  end

	return flying_text_infos
end

return burner

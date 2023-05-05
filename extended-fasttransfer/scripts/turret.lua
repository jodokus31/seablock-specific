local turret = {}

local logger = require("scripts/logger")

local function topupammo(player, inventory, items, max_amount, flying_text_infos)
	
	for itemname, count in pairs(items) do
		
		local transfer_amount = max_amount
		local stack_size = game.item_prototypes[itemname].stack_size
		if stack_size < transfer_amount then
			transfer_amount = stack_size
		end

		local transfer_amount = transfer_amount - count
		if transfer_amount > 0 then
			
			local player_count = player.get_item_count(itemname) or 0
			if player_count < transfer_amount then
				transfer_amount = player_count
			end

			local transfer_amount_stack = { name = itemname, count = transfer_amount }
			if transfer_amount > 0 and inventory.can_insert(transfer_amount_stack) then
				
				local actually_inserted = inventory.insert(transfer_amount_stack)
				transfer_amount_stack.count = actually_inserted
				player.remove_item(transfer_amount_stack)
				flying_text_infos[itemname] = { amount = -actually_inserted, total = player.get_item_count(itemname) or 0 }
				return true
			else
				-- there is need to top-up, but player has nothing.
				-- we continue, because a turret could have more slots, where next slot can be topped-up
				-- if the turret has more emtpy slots, we return false
				-- and then try to fill an empty slot with matching ammo, which is available. (second run)
			end
		else
			
			return true
		end
	end

	return false
end

local ammo_items_per_category = nil
local function get_ammo_items_per_category_cache()
	
	if ammo_items_per_category then 
		return ammo_items_per_category 
	end

	ammo_items_per_category = {}
	local ammo_item_prototypes = game.get_filtered_item_prototypes{{ filter="type", type="ammo" }}
	for name, ammo_item_prototype in pairs(ammo_item_prototypes) do
		
		local ammo_type = ammo_item_prototype.get_ammo_type()
		if ammo_type then
			
			ammo_items_per_category[ammo_type.category] = ammo_items_per_category[ammo_type.category] or {}
			table.insert(ammo_items_per_category[ammo_type.category], name)
		end
	end
	return ammo_items_per_category
end

function turret.topupturret(player, ammo_turret, max_amount)
	
	logger.print(player, "topupturret with " .. max_amount .. " items")
	local flying_text_infos = {}
	-- hand must be empty
	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return flying_text_infos
	end
	local inventory = ammo_turret.get_inventory(defines.inventory.turret_ammo)

	if not topupammo(player, inventory, inventory.get_contents(), max_amount, flying_text_infos) then
		
		local turret_ammo_categories = ammo_turret.prototype.attack_parameters.ammo_categories
		local matching_ammo = {}

		for _, ammo_category in pairs(turret_ammo_categories) do
			
			local ammo_item_names = get_ammo_items_per_category_cache()[ammo_category]
			
			if ammo_item_names then
				for _, itemname in pairs(ammo_item_names) do
					
					matching_ammo[itemname] = 0
				end
			end
		end
		
		topupammo(player, inventory, matching_ammo, max_amount, flying_text_infos)
	end

	return flying_text_infos
end

return turret

local partialstacks = {}

local logger = require("scripts/logger")

local function transfer_to_inventory(player, itemname, transfer_amount, inventory, flying_text_infos)
	local transfer_remaining = transfer_amount
	local transfer_stack = { name = itemname, count = transfer_amount }
	if transfer_amount > 0 and inventory.can_insert(transfer_stack) then

		local actually_inserted = inventory.insert(transfer_stack)
		transfer_stack.count = actually_inserted
		logger.print(player, "move "..actually_inserted.. " " .. itemname .. " to inventory")
		player.remove_item(transfer_stack)
		flying_text_infos[itemname] =
		{
			amount = (flying_text_infos[itemname] and flying_text_infos[itemname].amount or 0) - actually_inserted,
			total = player.get_item_count(itemname) or 0
		}
		transfer_remaining = transfer_remaining - actually_inserted
	end
	return transfer_remaining
end

function partialstacks.partialstackstoentity(flying_text_infos, player, inventory, fuel_inventory)

	logger.print(player, "partialstacks to chest")

	-- hand must be empty
	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return
	end

	local take_items_with_only_one_partial_stack = true
	local take_items_with_multiple_stacks_and_one_is_partial = true

	for itemname, player_count in pairs(player.get_main_inventory().get_contents()) do

		local item_prototype = game.item_prototypes[itemname]
		local stack_size = item_prototype.stack_size
		local transfer_amount = 0

		if take_items_with_only_one_partial_stack and player_count < stack_size then
			-- take items, which have a count lower than stacksize
			transfer_amount = player_count
		end

		if take_items_with_multiple_stacks_and_one_is_partial and player_count > stack_size then
			-- if items are more than stacksize, take remainder
			transfer_amount = player_count % stack_size
		end

		local transfer_remaining = transfer_amount
		if fuel_inventory and fuel_inventory.valid then
			-- try to add to fuel inventory, when item has a fuel value
			if item_prototype.fuel_value > 0.001 then
				transfer_remaining = transfer_to_inventory(player, itemname, transfer_amount, fuel_inventory, flying_text_infos)
			end
		end

		transfer_to_inventory(player, itemname, transfer_remaining, inventory, flying_text_infos)
	end

	inventory.sort_and_merge()
end

return partialstacks
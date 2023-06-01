local partialstacks = {}

local logger = require("scripts/logger")

function partialstacks.partialstackstoentity(player, inventory)

	logger.print(player, "partialstacks to chest")
	local flying_text_infos = {}

	-- hand must be empty
	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return flying_text_infos
	end

	local take_items_with_only_one_partial_stack = true
	local take_items_with_multiple_stacks_and_one_is_partial = true

	for itemname, player_count in pairs(player.get_main_inventory().get_contents()) do

		local stack_size = game.item_prototypes[itemname].stack_size
		local transfer_to_chest = 0

		if take_items_with_only_one_partial_stack and player_count < stack_size then
			-- take items, which have a count lower than stacksize
			transfer_to_chest = player_count
		end

		if take_items_with_multiple_stacks_and_one_is_partial and player_count > stack_size then
			-- if items are more than stacksize, take remainder
			transfer_to_chest = player_count % stack_size
		end

		local transfer_to_chest_stack = { name = itemname, count = transfer_to_chest }
		if transfer_to_chest > 0 and inventory.can_insert(transfer_to_chest_stack) then

			local actually_inserted = inventory.insert(transfer_to_chest_stack)
			transfer_to_chest_stack.count = actually_inserted
			logger.print(player, "move "..actually_inserted.. " " .. itemname .. " to inventory")
			player.remove_item(transfer_to_chest_stack)
      flying_text_infos[itemname] =
      {
        amount = (flying_text_infos[itemname] and flying_text_infos[itemname].amount or 0) - actually_inserted,
        total = player.get_item_count(itemname) or 0
      }
		end
	end

	inventory.sort_and_merge()
	return flying_text_infos

end

return partialstacks
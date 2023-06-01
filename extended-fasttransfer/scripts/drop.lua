local drop = {}

local logger = require("scripts/logger")

function drop.dropitems(player, inventory, max_count)

	local flying_text_infos = {}
	-- hand may not be empty
	if not player.cursor_stack or not player.cursor_stack.valid_for_read then
		return flying_text_infos
	end

  logger.print(player, "drop " .. max_count .. " items")

	local itemname = player.cursor_stack.name
	local remaining_count = max_count
	local stop_condition = false

	repeat
		local current_count = player.cursor_stack.count

		local transfer_count = remaining_count
		if current_count < remaining_count then
			transfer_count = current_count
		end

		local transfer_count_stack = { name = itemname, count = transfer_count }
		if transfer_count > 0 then
			local actually_inserted = 0
			if inventory.can_insert(transfer_count_stack) then
				actually_inserted = inventory.insert(transfer_count_stack)
			end

			if actually_inserted <= 0 then
				stop_condition = true
			else
				local remaining_stack = { name = itemname, count = current_count - actually_inserted }
				if remaining_stack.count > 0 then
					player.cursor_stack.count = current_count - actually_inserted
				else
					player.cursor_stack.set_stack(nil)
					local stack_from_player, index = player.get_inventory(defines.inventory.character_main).find_item_stack(itemname)
					if stack_from_player then
						player.cursor_stack.swap_stack(stack_from_player)
						player.hand_location = { inventory = defines.inventory.character_main, slot = index }
					end
				end
				if not player.cursor_stack or not player.cursor_stack.valid_for_read then
					stop_condition = true
				end
				remaining_count = remaining_count - actually_inserted
        flying_text_infos[itemname] =
				{
					amount = (flying_text_infos[itemname] and flying_text_infos[itemname].amount or 0) - actually_inserted,
					total = player.get_item_count(itemname) or 0
				}
			end
		end
	until remaining_count <= 0 or stop_condition
	return flying_text_infos
end

return drop

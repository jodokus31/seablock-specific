local chest = {}

local logger = require("scripts/logger")

function chest.topupplayerstacks(player, inventory)
	-- transfer to player from inventory
	logger.print(player, "topup player stacks")

	local flying_text_infos = {}

	-- hand must be empty
	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return flying_text_infos
	end

	for itemname, inventory_count in pairs(inventory.get_contents()) do

		local player_count = player.get_item_count(itemname) or 0
		local stack_size = game.item_prototypes[itemname].stack_size

		local remainder = player_count % stack_size
		local transfer_to_player = stack_size - remainder

		if remainder > 0 and (transfer_to_player > inventory_count) then
			transfer_to_player = inventory_count
		end

		if transfer_to_player <= inventory_count then

			local transfer_to_player_stack = { name = itemname, count = transfer_to_player }
			if transfer_to_player > 0 and player.can_insert(transfer_to_player_stack) then

				local actually_inserted = player.insert(transfer_to_player_stack)
				transfer_to_player_stack.count = actually_inserted
				logger.print(player, "move " .. actually_inserted .. " " .. itemname .. " to player")
				inventory.remove(transfer_to_player_stack)
				flying_text_infos[itemname] = { amount = actually_inserted, total = player.get_item_count(itemname) or 0 }

			end
		end
	end

	inventory.sort_and_merge()
	return flying_text_infos

end

function chest.quickstacktoentity(player, inventory)
  -- transfer from player to inventory
	logger.print(player, "quickstack to chest")

	local flying_text_infos = {}
	-- hand must be empty
	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return flying_text_infos
	end

	local keep_doing = true
	while keep_doing do

		keep_doing = false
		for itemname, _ in pairs(inventory.get_contents()) do

			local player_count = player.get_item_count(itemname) or 0
			local stack_size = game.item_prototypes[itemname].stack_size
			local transfer_to_chest = 0
			if player_count > stack_size then

				--take remainder first
				transfer_to_chest = player_count % stack_size
				if transfer_to_chest == 0 then

					transfer_to_chest = stack_size
				end
			else

				transfer_to_chest = player_count
			end

			local transfer_to_chest_stack = { name = itemname, count = transfer_to_chest }
			if transfer_to_chest > 0 and inventory.can_insert(transfer_to_chest_stack) then

				local actually_inserted = inventory.insert(transfer_to_chest_stack)
				transfer_to_chest_stack.count = actually_inserted
				logger.print(player, "move "..actually_inserted.. " " .. itemname .. " to chest")
				player.remove_item(transfer_to_chest_stack)
				flying_text_infos[itemname] =
				{
					amount = (flying_text_infos[itemname] and flying_text_infos[itemname].amount or 0) - actually_inserted,
					total = player.get_item_count(itemname) or 0
				}
				keep_doing = true
			end
		end
	end

	inventory.sort_and_merge()
	return flying_text_infos

end

return chest

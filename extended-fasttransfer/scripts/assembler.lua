local assembler = {}

local logger = require("scripts/logger")

function assembler.fillcraftingslots(player, assembling_machine)
	
	local flying_text_infos = {}

	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return flying_text_infos
	end

	local recipe = assembling_machine.get_recipe()

	if not recipe then
		return flying_text_infos
	end
	
	local inventory = assembling_machine.get_inventory(defines.inventory.assembling_machine_input)
	local ingredients = {}
	for _, ingredient in pairs(recipe.ingredients) do
		
		if ingredient.type == "item" then
			ingredients[ingredient.name] = ingredient.amount
		end
	end

	local min_count_of_recipes = -1

	for itemname, amount_per_recipe in pairs(ingredients) do
		
		local existing_amount = inventory.get_item_count(itemname) or 0
		local player_amount = player.get_item_count(itemname) or 0
		local stack_size = game.item_prototypes[itemname].stack_size
		local available_amount = existing_amount + player_amount
		
		if available_amount > stack_size then
			available_amount = stack_size
		end
		
		local count_of_recipes = math.floor(available_amount / amount_per_recipe)
		
		if (min_count_of_recipes == -1) or (count_of_recipes < min_count_of_recipes) then
			min_count_of_recipes = count_of_recipes
		end
	end

	if min_count_of_recipes > 0 then
		
		for itemname, amount_per_recipe in pairs(ingredients) do
			
			local needed_amount = min_count_of_recipes * amount_per_recipe
			local existing_amount = inventory.get_item_count(itemname) or 0
			local transfer_amount = needed_amount - existing_amount
			local transfer_amount_stack = { name = itemname, count = transfer_amount }
			
			if transfer_amount > 0 and inventory.can_insert(transfer_amount_stack) then
				
				local actually_inserted = inventory.insert(transfer_amount_stack)
				transfer_amount_stack.count = actually_inserted
				player.remove_item(transfer_amount_stack)
				flying_text_infos[itemname] = { amount = -actually_inserted, total = player.get_item_count(itemname) or 0}

			end
		end
	end
	return flying_text_infos
end

function assembler.pickupcraftingslots(player, assembling_machine)

  local flying_text_infos = {}

	if player.cursor_stack and player.cursor_stack.valid_for_read then
		return flying_text_infos
	end

  logger.print(player, "pickupcraftingslots to player")
	
  local recipe = assembling_machine.get_recipe()

	if not recipe then
		return flying_text_infos
	end
	
	local inventory = assembling_machine.get_inventory(defines.inventory.assembling_machine_input)
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

	return flying_text_infos
end

return assembler

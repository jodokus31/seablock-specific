local flying_text = {}

function flying_text.create_flying_text_entities(entity, flying_text_infos)
	
	if not entity or not flying_text_infos then
		return
	end

	local offset = 0
	for itemname, info in pairs(flying_text_infos) do
		
		local sign = (info.amount > 0) and "       +" or "        "
		
		entity.surface.create_entity(
			{
				name = "extended-fasttransfer-flying-text",
				position = { entity.position.x - 0.5, entity.position.y + (offset or 0) },
				text = {"", sign, info.amount, " ", game.item_prototypes[itemname].localised_name, " (", info.total ,")"},
				color = { r = 1, g = 1, b = 1 } -- white
			})
		
		offset = offset - 0.5
	end
end

function flying_text.create_flying_text_entity_for_cant_reach(entity)
	entity.surface.create_entity(
			{
				name = "extended-fasttransfer-flying-text",
				position = { entity.position.x - 0.5, entity.position.y + (offset or 0) },
				text = {"cant-reach"},
				color = { r = 1, g = 1, b = 1 } -- white
			})
end

return flying_text

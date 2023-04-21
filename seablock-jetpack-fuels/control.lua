function get_jetpack_fuels()
	local fuel_list = 
	{
		["enriched-fuel"] = settings.startup["seablock-jetpack-fuels-enriched-fuel"].value,
		["pellet-charcoal"] = settings.startup["seablock-jetpack-fuels-pellet-charcoal"].value,
		["wood-brick"] = settings.startup["seablock-jetpack-fuels-wood-brick"].value,
		["wood-charcoal"] = settings.startup["seablock-jetpack-fuels-wood-charcoal"].value,
	}

	-- remove entries with thrust 0.0
	local filtered_list = {}
	for name, thrust in pairs(fuel_list) do
		if thrust > 0.0 then
			filtered_list[name] = thrust
		end
	end

	-- game.print(serpent.block(filtered_list))

	return filtered_list
end

remote.add_interface("seablock-jetpack-fuels", { jetpack_fuels = get_jetpack_fuels })

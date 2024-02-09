require("util")

local IGNORE_DIRECT_ACTION_AFTER_DRAG = 15

local custom_inputs = require("custom_inputs")

local chest = require("scripts/chest")
local turret = require("scripts/turret")
local assembler = require("scripts/assembler")
local burner = require("scripts/burner")

local drop = require("scripts/drop")
local partialstacks = require("scripts/partialstacks")

local actiontype = require("scripts/actiontype")
local flying_text = require("scripts/flying_text")

local logger = require("scripts/logger")

script.on_init(function()
	global.player_state = {}
end)

script.on_configuration_changed(function()
	global.player_state = {}
end)

local function get_player_state(player_index)
	local state = global.player_state[player_index]
	if not state then
		state =
		{
			last_action_tick = nil,
			last_action_types = nil,
			last_drag_action_happened = nil,
			setting_custom_drop_amount = settings.get_player_settings(player_index)["extended-fasttransfer-custom-drop-amount"].value,
			setting_max_ammo_amount    = settings.get_player_settings(player_index)["extended-fasttransfer-max-ammo-amount"].value,
			setting_max_fuel_furnace   = settings.get_player_settings(player_index)["extended-fasttransfer-max-fuel-furnace"].value,
      setting_max_fuel_drill     = settings.get_player_settings(player_index)["extended-fasttransfer-max-fuel-drill"].value,
			setting_max_fuel_boiler    = settings.get_player_settings(player_index)["extended-fasttransfer-max-fuel-boiler"].value,
			setting_max_fuel_inserter  = settings.get_player_settings(player_index)["extended-fasttransfer-max-fuel-inserter"].value,
		}
		global.player_state[player_index] = state
	end
	return state
end

local entity_groups =
{
	["assembling-machine"]	= "assembling-machine",
	["furnace"]							= "furnace",
	["inserter"]					  = "inserter",
	["boiler"]					    = "boiler",
	["reactor"]							= "power",
  ["burner-generator"]    = "power",
	["mining-drill"]        = "mining-drill",
	["container"] 					= "container",
	["logistic-container"]	= "container",
	["infinity-container"]	= "container",
	["ammo-turret"] 				= "ammo-turret",
  ["lab"]                 = "lab",
}

local function handle_action_on_entity(player, selected_entity, state, tick, is_from_drag)

  local entity_type = selected_entity.type
	local entity_group = entity_groups[entity_type]
	if not entity_group then
		return nil
	end

	if not player.can_reach_entity(selected_entity) then
		return nil
	end

	local flying_text_infos = {}
	if entity_group == "container" then

		local inventory = selected_entity.get_inventory(defines.inventory.chest)
		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupplayerstacks, tick) then
				chest.topupplayerstacks(flying_text_infos, player, inventory)
			elseif actiontype.is_last_action(state, custom_inputs.topupentities) then
				-- stop, when chest is selected
				actiontype.reset_action(state)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.quickstack, tick) then
				chest.quickstacktoentity(flying_text_infos, player, inventory)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.partialstacks, tick) then
				partialstacks.partialstackstoentity(flying_text_infos, player, inventory)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				drop.dropitems(flying_text_infos, player, inventory, state.setting_custom_drop_amount)
			end
		end

	elseif entity_group == "ammo-turret" then

		local inventory = selected_entity.get_inventory(defines.inventory.turret_ammo)
		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupentities, tick) then
				turret.topupturret(flying_text_infos, player, selected_entity, state.setting_max_ammo_amount)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.partialstacks, tick) then
				partialstacks.partialstackstoentity(flying_text_infos, player, inventory)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				drop.dropitems(flying_text_infos, player, inventory, state.setting_custom_drop_amount)
			end
		end

  elseif entity_group == "lab" then

		local inventory = selected_entity.get_inventory(defines.inventory.lab_input)
		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				drop.dropitems(flying_text_infos, player, inventory, state.setting_custom_drop_amount)
			end
		end

	elseif entity_group == "assembling-machine" then

		local input_inventory = selected_entity.get_inventory(defines.inventory.assembling_machine_input)
		local fuel_inventory = selected_entity.get_inventory(defines.inventory.fuel)

		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.pickupcraftingslots, tick) then
				burner.pickupitems(flying_text_infos, player, fuel_inventory, nil)
				assembler.pickupcraftingslots(flying_text_infos, player, selected_entity)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupentities, tick) then
				burner.topupfuel(flying_text_infos, player, selected_entity, state)
				assembler.fillcraftingslots(flying_text_infos, player, selected_entity)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.partialstacks, tick) then
				partialstacks.partialstackstoentity(flying_text_infos, player, input_inventory, fuel_inventory)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				drop.dropitems_with_fuel(flying_text_infos, player, fuel_inventory, input_inventory, state.setting_custom_drop_amount)
			end
		end

	elseif entity_group == "furnace" then

		local input_inventory = selected_entity.get_inventory(defines.inventory.furnace_source)
		local fuel_inventory = selected_entity.get_inventory(defines.inventory.fuel)

		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.pickupcraftingslots, tick) then
				burner.pickupitems(flying_text_infos, player, fuel_inventory, input_inventory)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupentities, tick) then
				burner.topupfuel(flying_text_infos, player, selected_entity, state)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.partialstacks, tick) then
				partialstacks.partialstackstoentity(flying_text_infos, player, input_inventory, fuel_inventory)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				drop.dropitems_with_fuel(flying_text_infos, player, fuel_inventory, input_inventory, state.setting_custom_drop_amount)
			end
		end

	elseif entity_group == "inserter" then

		local fuel_inventory = selected_entity.get_inventory(defines.inventory.fuel)

		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.pickupcraftingslots, tick) then
				burner.pickupitems(flying_text_infos, player, fuel_inventory, nil)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupentities, tick) then
				burner.topupfuel(flying_text_infos, player, selected_entity, state)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				drop.dropitems_with_fuel(flying_text_infos, player, fuel_inventory, nil, state.setting_custom_drop_amount)
			end
		end

	elseif entity_group == "boiler" or entity_group == "power" or entity_group == "mining-drill" then

		local fuel_inventory = selected_entity.get_inventory(defines.inventory.fuel)

		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.pickupcraftingslots, tick) then
				burner.pickupitems(flying_text_infos, player, fuel_inventory, nil)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupentities, tick) then
				burner.topupfuel(flying_text_infos, player, selected_entity, state)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				drop.dropitems_with_fuel(flying_text_infos, player, fuel_inventory, nil, state.setting_custom_drop_amount)
			end
		end
	end

	if flying_text_infos and next(flying_text_infos) then

		flying_text.create_flying_text_entities(selected_entity, flying_text_infos)
		--something has moved
		player.play_sound({ path = "utility/inventory_move" })

		if is_from_drag then
			logger.print(player, "drag action happened: "..tick)
			state.last_drag_action_happened = tick
		end
	end
end

---comment
---@param e EventData.CustomInputEvent
local function common_custominput_handler(e)

	local player = game.get_player(e.player_index)
	if not player or not player.valid then
		return
	end

	local state = get_player_state(e.player_index)

	-- save the tick, when this hotkey was pressed
	-- this opens a time period of x ticks, where the player could drag the mouse to the next entity
	-- which yields an on_selected_entity_changed event.
	-- while the time period is open, the on_selected_entity_changed eventhandler does its action and extends the period.
	-- there also some conditions, when the period is closed immediately instead of let x ticks pass by

	local tick = game.tick
	if not actiontype.set_action(state, e.input_name, tick) then
		logger.print(player, "other fixed action already set")
		return
	end

	local selected_entity = player.selected
	if not selected_entity then
		return
	end

	logger.print(player, "should omit direct call?: "..tick
		.." state.last_drag_action_happened: " .. (state.last_drag_action_happened or "nil"))

	if entity_groups[selected_entity.type] and not player.can_reach_entity(selected_entity)  then
		player.play_sound({ path = "utility/cannot_build" })
		flying_text.create_flying_text_entity_for_cant_reach(selected_entity)
		return
	end

	if not state.last_drag_action_happened or (state.last_drag_action_happened + IGNORE_DIRECT_ACTION_AFTER_DRAG) <= tick then
		handle_action_on_entity(player, selected_entity, state, tick, false)
		state.last_drag_action_happened = nil
	end
end

local function add_item_to_item_request_proxy(entity, item, add_amount, flying_text_infos)
	local current_item_requests = util.table.deepcopy(entity.item_requests or {})
	if not item then
		for name, amount in pairs(current_item_requests) do
			flying_text_infos[name] = { amount = -1*amount, total = 0 }
		end
		current_item_requests = {}
	else
		current_item_requests[item] = (current_item_requests[item] or 0) + add_amount
		flying_text_infos[item] = { amount = add_amount, total = current_item_requests[item] }
	end
	entity.item_requests = current_item_requests
end

local function createitemrequests_handler(e)
	local player = game.get_player(e.player_index)
	if not player or not player.valid then
		return
	end

	local entity = player.selected
	if not entity or not entity.valid then
		return
	end

	local cursor_stack = player.cursor_stack
	if not cursor_stack or not cursor_stack.valid then
		return
	end

	local add_amount = 1
	local entity_name = entity.name
	local is_ghost = entity_name == "entity-ghost"
	local is_item_request_proxy = entity_name == "item-request-proxy"

	local item_in_hand = cursor_stack.valid_for_read and cursor_stack.name or nil

	local flying_text_infos = {}

	local destroy_entity = false

	if is_ghost or is_item_request_proxy then
		add_item_to_item_request_proxy(entity, item_in_hand, add_amount, flying_text_infos)
		if is_item_request_proxy and not item_in_hand then
			-- destroy the item-request-proxy at the end, if item_in_hand is empty
			destroy_entity = true
		end
	else
		-- first try to find an existing "item-request-proxy" in this area
		local search_area = {
			{ entity.position.x + 0.001 - 0.5, entity.position.y + 0.001 - 0.5},
			{ entity.position.x - 0.001 + 0.5, entity.position.y - 0.001 + 0.5}
		}
		local entities = entity.surface.find_entities(search_area)
		local is_found = false
		for _, found_entity in pairs(entities) do
			if found_entity.valid then
				if found_entity.name == "item-request-proxy" then
					is_found = true
					add_item_to_item_request_proxy(found_entity, item_in_hand, add_amount, flying_text_infos)
					if not item_in_hand then
						-- destroy the item-request-proxy, if item_in_hand is empty
						found_entity.destroy()
					end
					break
				end
			end
		end

		-- if not found we add an item request proxy entity
		if not is_found and item_in_hand then
			local new_entity = player.surface.create_entity
---@diagnostic disable-next-line: missing-fields
			{
				name = "item-request-proxy",
				target = entity,
				modules = {[item_in_hand] = add_amount},
				position = entity.position,
				force = player.force,
			}

			if new_entity and new_entity.valid then
				flying_text_infos[item_in_hand] = { amount = add_amount, total = add_amount }
			end
		end
	end

	if flying_text_infos and next(flying_text_infos) then
		flying_text.create_flying_text_entities(entity, flying_text_infos)
		--something has happened
		player.play_sound({ path = "utility/smart_pipette" })
	end

	if destroy_entity then
		entity.destroy()
	end
end


script.on_event(custom_inputs.topupplayerstacks, common_custominput_handler)
script.on_event(custom_inputs.pickupcraftingslots, common_custominput_handler)
script.on_event(custom_inputs.topupentities, common_custominput_handler)
script.on_event(custom_inputs.quickstack, common_custominput_handler)
script.on_event(custom_inputs.partialstacks, common_custominput_handler)
script.on_event(custom_inputs.dropitems, common_custominput_handler)
script.on_event(custom_inputs.createitemrequests, createitemrequests_handler)

---comment
---@param e EventData.on_selected_entity_changed
local function on_selected_entity_changed(e)

	local state = get_player_state(e.player_index)
	if not state.last_action_tick then
		return
	end

	local player = game.get_player(e.player_index)
	if not player or not player.valid then
		return
	end

	local tick = game.tick
	if actiontype.check_action_expired(state, tick) then
		return
	end

	local selected_entity = player.selected
	if not selected_entity then
		-- don't reset action, when no entity is selected
		-- this could be the start of the drag
		return
	end

	handle_action_on_entity(player, selected_entity, state, tick, true)

end

script.on_event(defines.events.on_selected_entity_changed, on_selected_entity_changed)

---comment
---@param e EventData.on_player_fast_transferred
local function on_player_fast_transferred(e)
	-- stop, if something is fast transfered regulary
	logger.print(e.player_index, "stop, if something is fast transfered regulary")
	local state = get_player_state(e.player_index)
	actiontype.reset_action(state)
end
script.on_event(defines.events.on_player_fast_transferred, on_player_fast_transferred)

---comment
---@param e EventData.on_runtime_mod_setting_changed
local function on_runtime_mod_setting_changed(e)

	if e.setting == "extended-fasttransfer-custom-drop-amount" then
    local state = get_player_state(e.player_index)
    state.setting_custom_drop_amount = settings.get_player_settings(e.player_index)[e.setting].value
	elseif e.setting == "extended-fasttransfer-max-ammo-amount" then
    local state = get_player_state(e.player_index)
    state.setting_max_ammo_amount = settings.get_player_settings(e.player_index)[e.setting].value
	elseif e.setting == "extended-fasttransfer-max-fuel-furnace" then
    local state = get_player_state(e.player_index)
    state.setting_max_fuel_furnace = settings.get_player_settings(e.player_index)[e.setting].value
  elseif e.setting == "extended-fasttransfer-max-fuel-drill" then
    local state = get_player_state(e.player_index)
    state.setting_max_fuel_drill = settings.get_player_settings(e.player_index)[e.setting].value
	elseif e.setting == "extended-fasttransfer-max-fuel-boiler" then
    local state = get_player_state(e.player_index)
    state.setting_max_fuel_boiler = settings.get_player_settings(e.player_index)[e.setting].value
	elseif e.setting == "extended-fasttransfer-max-fuel-inserter" then
    local state = get_player_state(e.player_index)
    state.setting_max_fuel_inserter = settings.get_player_settings(e.player_index)[e.setting].value
  end

end

script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
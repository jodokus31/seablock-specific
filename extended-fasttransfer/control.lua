local IGNORE_DIRECT_ACTION_AFTER_DRAG = 15

local custom_inputs = require("custom_inputs")

local chest = require("scripts/chest")
local turret = require("scripts/turret")
local assembler = require("scripts/assembler")
local drop = require("scripts/drop")
local partialstacks = require("scripts/partialstacks")

local actiontype = require("scripts/actiontype")
local flying_text = require("scripts/flying_text")

local logger = require("scripts/logger")

script.on_init(function()
	global.player_state = {}
end)

function get_player_state(player_index)
	local state = global.player_state[player_index]
	if not state then
		state = 
		{
			last_action_tick = nil,
			last_action_types = nil,
			last_drag_action_happened = nil,
			setting_custom_drop_amount = settings.get_player_settings(player_index)["extended-fasttransfer-custom-drop-amount"].value,
			setting_max_ammo_amount    = settings.get_player_settings(player_index)["extended-fasttransfer-max-ammo-amount"].value,
		}
		global.player_state[player_index] = state
	end
	return state
end

local entity_groups = 
{
	["assembling-machine"]	= "assembling-machine",
	["container"] 					= "container",
	["logistic-container"]	= "container",
	["ammo-turret"] 				= "ammo-turret"
}

local function handle_action_on_entity(player, selected_entity, state, tick, is_from_drag)

	local entity_group = entity_groups[selected_entity.type]
	if not entity_group then
		return nil
	end

	if not player.can_reach_entity(selected_entity) then
		return nil
	end

	local flying_text_infos = nil
	if entity_group == "container" then

		local inventory = selected_entity.get_inventory(defines.inventory.chest)
		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupplayerstacks, tick) then
				flying_text_infos = chest.topupplayerstacks(player, inventory)
			elseif actiontype.is_last_action(state, custom_inputs.topupentities) then
				-- stop, when chest is selected
				actiontype.reset_action(state)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.quickstack, tick) then
				flying_text_infos = chest.quickstacktoentity(player, inventory)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.partialstacks, tick) then
				flying_text_infos = partialstacks.partialstackstoentity(player, inventory)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				flying_text_infos = drop.dropitems(player, inventory, state.setting_custom_drop_amount)
			end
		end
		
	elseif entity_group == "ammo-turret" then

		local inventory = selected_entity.get_inventory(defines.inventory.turret_ammo)
		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupentities, tick) then
				flying_text_infos = turret.topupturret(player, selected_entity, state.setting_max_ammo_amount)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.partialstacks, tick) then
				flying_text_infos = partialstacks.partialstackstoentity(player, inventory)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				flying_text_infos = drop.dropitems(player, inventory, state.setting_custom_drop_amount)
			end
		end

	elseif entity_group == "assembling-machine" then
		
		local inventory = selected_entity.get_inventory(defines.inventory.assembling_machine_input)
		
		if not player.cursor_stack or not player.cursor_stack.valid_for_read then
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.pickupcraftingslots, tick) then
				flying_text_infos = assembler.pickupcraftingslots(player, selected_entity)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.topupentities, tick) then
				flying_text_infos = assembler.fillcraftingslots(player, selected_entity)
			elseif actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.partialstacks, tick) then
				flying_text_infos = partialstacks.partialstackstoentity(player, inventory)
			end
		else
			if actiontype.is_last_action_if_yes_set_fixed(state, custom_inputs.dropitems, tick) then
				flying_text_infos = drop.dropitems(player, inventory, state.setting_custom_drop_amount)
			end
		end

	end
	flying_text.create_flying_text_entities(selected_entity, flying_text_infos)
	
	if flying_text_infos and next(flying_text_infos) then
		--something has moved
		player.play_sound({ path = "utility/inventory_move" })
		
		if is_from_drag then
			logger.print(player, "drag action happened: "..tick)
			state.last_drag_action_happened = tick
		end
	end
end

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

script.on_event(custom_inputs.topupplayerstacks, common_custominput_handler)
script.on_event(custom_inputs.pickupcraftingslots, common_custominput_handler)
script.on_event(custom_inputs.topupentities, common_custominput_handler)
script.on_event(custom_inputs.quickstack, common_custominput_handler)
script.on_event(custom_inputs.partialstacks, common_custominput_handler)
script.on_event(custom_inputs.dropitems, common_custominput_handler)

script.on_event(defines.events.on_selected_entity_changed, function(e)

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

end)

script.on_event(defines.events.on_player_fast_transferred, function(e)
	-- stop, if something is fast transfered regulary
	logger.print(e.player_index, "stop, if something is fast transfered regulary")
	local state = get_player_state(e.player_index)
	actiontype.reset_action(state)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
  
	if e.setting == "extended-fasttransfer-custom-drop-amount" then
    local state = get_player_state(e.player_index)
    state.setting_custom_drop_amount = settings.get_player_settings(e.player_index)[e.setting].value
	elseif e.setting == "extended-fasttransfer-max-ammo-amount" then
    local state = get_player_state(e.player_index)
    state.setting_max_ammo_amount = settings.get_player_settings(e.player_index)[e.setting].value
  end

end)
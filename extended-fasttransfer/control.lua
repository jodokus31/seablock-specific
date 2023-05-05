local TICKS_TO_DETECT_DRAG = 20

local custom_inputs = require("custom_inputs")

local chest = require("scripts/chest")
local turret = require("scripts/turret")
local assembler = require("scripts/assembler")
local drop = require("scripts/drop")
local partialstacks = require("scripts/partialstacks")

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
			last_action_type = nil,
			setting_custom_drop_amount = settings.get_player_settings(player_index)["extended-fasttransfer-custom-drop-amount"].value,
			setting_max_ammo_amount    = settings.get_player_settings(player_index)["extended-fasttransfer-max-ammo-amount"].value,
		}
		global.player_state[player_index] = state
	end
	return state
end

local function set_action(state, tick, type, force)
	if not state.last_action_tick or force or state.last_action_tick < tick then
		state.last_action_tick = tick
		state.last_action_type = {}
		state.last_action_type[type] = true
		logger.print(player, "set_action: " .. (force and "(force) " or "") .. (type or "nil"))
	elseif state.last_action_tick == tick then
		state.last_action_type[type] = true
		logger.print(player, "add_action: " .. (type or "nil"))
	end
end

local function reset_action(state)
	state.last_action_tick = nil
	state.last_action_type = nil
end

local function check_action_expired(state, tick)
	if (state.last_action_tick + TICKS_TO_DETECT_DRAG) < tick then
		-- stop after x ticks, where no new entity is selected
		logger.print(player, "stop after x ticks, when no new entity is selected")
		reset_action(state)
		return true
	end

	return false
end

local function is_last_action(state, type)
	if not state.last_action_tick or not state.last_action_type then
		return false
	end
	return state.last_action_type[type]
end

local function handle_action_on_entity(player, selected_entity, state)

	local flying_text_infos = nil
	if selected_entity.type == "container" or selected_entity.type == "logistic-container" then

		local inventory = selected_entity.get_inventory(defines.inventory.chest)
		if is_last_action(state, custom_inputs.topupplayerstacks) then
			set_action(state, game.tick, custom_inputs.topupplayerstacks, true)
			flying_text_infos = chest.topupplayerstacks(player, inventory)
		elseif is_last_action(state, custom_inputs.topupentities) then
			-- stop, when chest is selected
			reset_action(state)
			logger.print(player, "stop, when chest is selected")
		elseif is_last_action(state, custom_inputs.quickstack) then
			set_action(state, game.tick, custom_inputs.quickstack, true)
			flying_text_infos = chest.quickstacktoentity(player, inventory)
		elseif is_last_action(state, custom_inputs.dropitems) then
			set_action(state, game.tick, custom_inputs.dropitems, true)
			flying_text_infos = drop.dropitems(player, inventory, state.setting_custom_drop_amount)
		elseif is_last_action(state, custom_inputs.partialstacks) then
			set_action(state, game.tick, custom_inputs.partialstack, true)
			flying_text_infos = partialstacks.partialstackstoentity(player, inventory)
		end

	elseif selected_entity.type == "ammo-turret" then

		local inventory = selected_entity.get_inventory(defines.inventory.turret_ammo)
		if is_last_action(state, custom_inputs.topupentities) then
			set_action(state, game.tick, custom_inputs.topupentities, true)
			flying_text_infos = turret.topupturret(player, selected_entity, state.setting_max_ammo_amount)
		elseif is_last_action(state, custom_inputs.dropitems) then
			set_action(state, game.tick, custom_inputs.dropitems, true)
			flying_text_infos = drop.dropitems(player, inventory, state.setting_custom_drop_amount)
		elseif is_last_action(state, custom_inputs.partialstacks) then
			set_action(state, game.tick, custom_inputs.partialstacks, true)
			flying_text_infos = partialstacks.partialstackstoentity(player, inventory)
		end

	elseif selected_entity.type == "assembling-machine" then
		
		local inventory = selected_entity.get_inventory(defines.inventory.assembling_machine_input)
		if is_last_action(state, custom_inputs.pickupcraftingslots) then
			set_action(state, game.tick, custom_inputs.pickupcraftingslots, true)
			flying_text_infos = assembler.pickupcraftingslots(player, selected_entity)
		elseif is_last_action(state, custom_inputs.topupentities) then
			set_action(state, game.tick, custom_inputs.topupentities, true)
			flying_text_infos = assembler.fillcraftingslots(player, selected_entity)
		elseif is_last_action(state, custom_inputs.dropitems) then
			set_action(state, game.tick, custom_inputs.dropitems, true)
			flying_text_infos = drop.dropitems(player, inventory, state.setting_custom_drop_amount)
		elseif is_last_action(state, custom_inputs.partialstacks) then
			set_action(state, game.tick, custom_inputs.partialstacks, true)
			flying_text_infos = partialstacks.partialstackstoentity(player, inventory)
		end

	end
	flying_text.create_flying_text_entities(selected_entity, flying_text_infos)
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

	set_action(state, game.tick, e.input_name)

	local selected_entity = player.selected
	if not selected_entity then
		return
	end

	handle_action_on_entity(player, selected_entity, state)
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

	if check_action_expired(state, game.tick) then
		return
	end

	local selected_entity = player.selected
	if not selected_entity then
		-- don't reset, when no entity is selected
		return
	end

	handle_action_on_entity(player, selected_entity, state)

end)

script.on_event(defines.events.on_player_fast_transferred, function(e)
	-- stop, if something is fast transfered regulary
	logger.print(e.player_index, "stop, if something is fast transfered regulary")
	local state = get_player_state(e.player_index)
	reset_action(state)
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
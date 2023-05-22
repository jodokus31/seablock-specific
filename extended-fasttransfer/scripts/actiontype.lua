local actiontype = {}

local TICKS_TO_DETECT_DRAG = 10

local logger = require("scripts/logger")

function actiontype.set_action(state, type, tick)
	if not state.last_action_tick or state.last_action_tick < tick then
		state.last_action_tick = tick
    state.last_action_is_fixed = nil
		state.last_action_types = {}
		state.last_action_types[type] = true
		logger.print(player, "set_action: " .. (type or "nil"))
    return true
	elseif state.last_action_tick == tick and not state.last_action_is_fixed then
		state.last_action_types[type] = true
		logger.print(player, "add_action: " .. (type or "nil"))
    return true
	end
  return false
end

function actiontype.reset_action(state)
	state.last_action_tick = nil
	state.last_action_types = nil
  state.last_action_is_fixed = nil
end

function actiontype.check_action_expired(state, tick)
	if (state.last_action_tick + TICKS_TO_DETECT_DRAG) < tick then
		-- stop after x ticks, where no new entity is selected
		logger.print(player, "stop after x ticks, when no new entity is selected")
		actiontype.reset_action(state)
		return true
	end

	return false
end

function actiontype.is_last_action(state, type)
	if not state.last_action_tick or not state.last_action_types then
		return false
	end
	return state.last_action_types[type]
end

function actiontype.is_last_action_if_yes_set_fixed(state, type, tick)
	if actiontype.is_last_action(state, type) then
		state.last_action_tick = tick
		state.last_action_is_fixed = true
    state.last_action_types = {}
		state.last_action_types[type] = true
    logger.print(player, "set_action fixed: " .. (type or "nil"))
    return true
	end
  return false
end

return actiontype

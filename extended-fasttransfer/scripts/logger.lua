local logger = {}

logger.DEBUG = false

function logger.print(player_or_player_index, text)
	if not logger.DEBUG then
		return
	end

  local player = nil
  local index = tonumber(player_or_player_index) or 0
  if index > 0 then
---@diagnostic disable-next-line: param-type-mismatch
    player = game.get_player(index)
  else
    player = player_or_player_index
  end

  if player and player.valid then
    player.print(text)
  else
    game.print(text)
  end
end

return logger

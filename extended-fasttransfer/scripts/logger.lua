local logger = {}

logger.DEBUG = true

function logger.print(player_or_player_index, text)
	if not logger.DEBUG then
		return
	end
		
  local player = nil
  local index = tonumber(player_or_player_index)
  if index and index > 0 then
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

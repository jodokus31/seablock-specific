local mod_gui = require("mod-gui")
require("util")

local MOD_NAME = "seablock-landfill-replacer"
local GUI_BUTTON = MOD_NAME.."-button"

local landfilltiles = require('landfilltiles')

local landfilltilesByName = {}
for _, tilename in pairs(landfilltiles) do
  landfilltilesByName[tilename] = true
end

function replace_landfill(blueprint, player)
    local old_tiles = blueprint.get_blueprint_tiles()
    local default_tile = settings.get_player_settings(player)["seablock-landfill-replacer-default-landfill"].value

    game.print("Replace all landfill with: " .. default_tile)

    local index = 0
    local new_tiles = {}

    if old_tiles then
      for _, old_tile in pairs(old_tiles) do
        if landfilltilesByName[old_tile.name] then
          local pos = old_tile.position
          new_tiles[index + 1] = { name = default_tile, position = { pos.x, pos.y } }
          index = index + 1
        end
      end
    end

    return { tiles = new_tiles }
end


function get_slr_flow(player)

    local button_flow = mod_gui.get_button_flow(player)
    local flow = button_flow.slr_flow
    if not flow then
        flow = button_flow.add {
            type = "flow",
            name = "slr_flow",
            direction = "horizontal"
        }
    end
    return flow
end

function add_top_button(player)

    if player.gui.top.slr_flow then player.gui.top.slr_flow.destroy() end -- remove the old flow

    local flow = get_slr_flow(player)

    if flow[GUI_BUTTON] then flow[GUI_BUTTON].destroy() end
    flow.add {
        type = "sprite-button",
        name = GUI_BUTTON,
        sprite = "item/landfill",
        style = mod_gui.button_style,
        tooltip = { "slr_tooltip" }
    }
end

function is_valid_slot(slot, state)

    if not slot or not slot.valid_for_read then return false end

    --if state then
    if state == "empty" then
        return not slot.is_blueprint_setup()
    elseif state == "setup" then
        return slot.is_blueprint_setup()
    end
    --end
    return true
end

function get_blueprint_on_cursor(player)

    local stack = player.cursor_stack
    if stack.valid_for_read then
        if (stack.type == "blueprint" and is_valid_slot(stack, 'setup')) then
            return stack
        elseif stack.type == "blueprint-book" then
            local active = stack.get_inventory(defines.inventory.item_main)[stack.active_index]
            if is_valid_slot(active, 'setup') then
                return active
            end
        end
    end
    return false
end

script.on_init(function()
    for _, player in pairs(game.players) do
        add_top_button(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    add_top_button(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
    local player = game.players[event.player_index]

    if event.element.name == GUI_BUTTON then
        if player.cursor_stack.valid_for_read then
            local blueprint = get_blueprint_on_cursor(player)
            if blueprint then
                local modified = replace_landfill(blueprint, player)
                if next(modified.tiles) ~= nil then
                    blueprint.set_blueprint_tiles(modified.tiles)
                end
            end
        end
    end
end)


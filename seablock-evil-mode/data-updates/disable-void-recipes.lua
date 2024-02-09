
if not settings.startup['seablock-evil-mode-disable-voiding-restrictions'].value then

  local enable_execptions = not settings.startup['seablock-evil-mode-disable-voiding-exceptions'].value
  local water_exceptions = enable_execptions
    and
    {
      ["water"] = true,
      ["water-purified"] = true,
      ["water-saline"] = true,
      
      ["water-heavy-mud"] = true,
      ["water-concentrated-mud"] = true,
      ["water-light-mud"] = true,
      ["water-thin-mud"] = true,
    }
    or {}

  local chemical_exceptions = enable_execptions
    and
    {
      ["gas-hydrogen"] = true,
      ["gas-oxygen"] = true,
      ["gas-nitrogen"] = true,
      ["gas-chlorine"] = true,
      ["gas-compressed-air"] = true,
    }
    or {}

  for recipe_name, recipe in pairs(data.raw["recipe"]) do 

    -- "angels-water-void-" .. fluid_name
    -- f.e. angels-water-void-water-greenyellow-waste
    local water_name = recipe_name:match("angels%-water%-void%-(.*)")
    
    if water_name then
      if not water_exceptions[water_name] then
        -- log("disable water void: " .. water_name)
        recipe.enabled = false
      end
    end

    -- "angels-chemical-void-" .. fluid_name
    -- f.e. angels-chemical-void-gas-carbon-monoxide
    local chemical_name = recipe_name:match("angels%-chemical%-void%-(.*)")

    if chemical_name then
      if not chemical_exceptions[chemical_name] then
        -- log("disable chemical void: " .. chemical_name)
        recipe.enabled = false
      end
    end
    
  end
end
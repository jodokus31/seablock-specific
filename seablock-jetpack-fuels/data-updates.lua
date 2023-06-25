
if mods["grappling-gun"] then
    if data.raw.recipe["grappling-gun-ammo"] then
        for _, ing in pairs(data.raw.recipe["grappling-gun-ammo"].ingredients) do
            if ing.name == "coal" then
                ing.name = "wood-charcoal"
                break;
            end
        end
    end
end
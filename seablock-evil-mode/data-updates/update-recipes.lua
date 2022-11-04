
if not settings.startup['seablock-evil-mode-disable-misc'].value then
  local sct_t2_micro_wafer = data.raw.recipe["sct-t2-micro-wafer"]

  if sct_t2_micro_wafer and sct_t2_micro_wafer.normal then
    for _, ing in pairs(sct_t2_micro_wafer.normal.ingredients) do
      if ing.name == "lead-plate" then
        ing.amount = 4
      end
    end
  end

  local milling_drum_used = data.raw.recipe["milling-drum-used"]

  if milling_drum_used then
    for _, ing in pairs(milling_drum_used.ingredients) do
      if ing.name == "lubricant" then
        ing.amount = 4.5
      end
    end
  end
end

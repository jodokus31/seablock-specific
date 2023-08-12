local custom_inputs = require("custom_inputs")

data:extend{
	{
		type = "flying-text",
		name = "extended-fasttransfer-flying-text",
		flags = {"not-on-map", "placeable-off-grid"},
		time_to_live = 150,
		speed = 0.05
	}
}

data:extend{
  {
    type = "custom-input",
    name = custom_inputs.topupplayerstacks, --no hand, chests
    key_sequence = "CONTROL + mouse-button-3",
    order = "a"
  },
	{
    type = "custom-input",
    name = custom_inputs.pickupcraftingslots, --no hand, assemblers
    key_sequence = "CONTROL + mouse-button-3",
    order = "b"
  },
  {
    type = "custom-input",
    name = custom_inputs.topupentities, --no hand, assemblers and turrets
    key_sequence = "CONTROL + SHIFT + mouse-button-3",
    order = "c"
  },
	{
    type = "custom-input",
    name = custom_inputs.quickstack, --no hand, chests
    key_sequence = "CONTROL + SHIFT + mouse-button-3",
    order = "d"
  },
	{
    type = "custom-input",
    name = custom_inputs.dropitems, --hand, all
    key_sequence = "SHIFT + Z",
    order = "e"
  },
	{
    type = "custom-input",
    name = custom_inputs.partialstacks, --no hand, all
    key_sequence = "CONTROL + SHIFT + ALT + mouse-button-3",
    order = "f"
  },
	{
    type = "custom-input",
    name = custom_inputs.createitemrequests,
    key_sequence = "ALT + I",
    order = "g"
  }

}
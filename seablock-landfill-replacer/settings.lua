local landfilltiles = require('landfilltiles')

data:extend({
  {
    type = 'string-setting',
    name = 'seablock-landfill-replacer-default-landfill',
    setting_type = 'runtime-per-user',
    default_value = landfilltiles[6],
    allowed_values = landfilltiles
  }
})

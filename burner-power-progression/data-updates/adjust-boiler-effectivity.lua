local default_tiers = require("default_tiers")

local fuel_tiers_solid = settings.startup['burner-power-progression-tiers-solid'].value
local fuel_tiers_fluid = settings.startup['burner-power-progression-tiers-fluid'].value

local solid_fuel_factor = settings.startup['burner-power-progression-factor-solid'].value

log("solid tiers: "..fuel_tiers_solid)
log("fluid tiers: "..fuel_tiers_fluid)

local n = "([%d\\.\\-]+)" -- number pattern incl. - and .
local d = "[%s,]+"        -- delimiter pattern incl. whitespaces

local five_tiers_regex = "^%s*"..n..d..n..d..n..d..n..d..n.."%s*$"

local solid_tier1, solid_tier2, solid_tier3, solid_tier4, solid_tier5 =
    fuel_tiers_solid:match(five_tiers_regex)
local _, fluid_tier2, fluid_tier3, fluid_tier4, fluid_tier5 =
    fuel_tiers_fluid:match(five_tiers_regex)

    log(string.format("solid tiers before validation: %s %s %s %s %s", solid_tier1, solid_tier2, solid_tier3, solid_tier4, solid_tier5))
    log(string.format("fluid tiers before validation: %s %s %s %s", fluid_tier2, fluid_tier3, fluid_tier4, fluid_tier5))

local function validate_tier_number(tier, default_tier)
    if not tier then
        return default_tier
    end
    
    local tier_as_number = tonumber(tier)
    if not tier_as_number then
        return default_tier
    end
    
    if tier_as_number < 0.2 then
        return default_tier
    end
    
    if tier_as_number > 5 then
        return default_tier
    end
    
    return tier_as_number
end

solid_tier1 = validate_tier_number(solid_tier1, default_tiers.SOLID_TIER1)
solid_tier2 = validate_tier_number(solid_tier2, default_tiers.SOLID_TIER2)
solid_tier3 = validate_tier_number(solid_tier3, default_tiers.SOLID_TIER3)
solid_tier4 = validate_tier_number(solid_tier4, default_tiers.SOLID_TIER4)
solid_tier5 = validate_tier_number(solid_tier5, default_tiers.SOLID_TIER5)

fluid_tier2 = validate_tier_number(fluid_tier2, default_tiers.FLUID_TIER2)
fluid_tier3 = validate_tier_number(fluid_tier3, default_tiers.FLUID_TIER3)
fluid_tier4 = validate_tier_number(fluid_tier4, default_tiers.FLUID_TIER4)
fluid_tier5 = validate_tier_number(fluid_tier5, default_tiers.FLUID_TIER5)

log(string.format("solid tiers after validation: %s %s %s %s %s", solid_tier1, solid_tier2, solid_tier3, solid_tier4, solid_tier5))
log(string.format("fluid tiers after validation: %s %s %s %s", fluid_tier2, fluid_tier3, fluid_tier4, fluid_tier5))

local boilers = 
{
    ["boiler"]   = solid_tier1, --bob
    ["boiler-2"] = solid_tier2, --bob
    ["boiler-3"] = solid_tier3, --bob
    ["boiler-4"] = solid_tier4, --bob
    ["boiler-5"] = solid_tier5, --bob
    
    ["oil-boiler"]   = fluid_tier2, --bob
    ["oil-boiler-2"] = fluid_tier3, --bob
    ["oil-boiler-3"] = fluid_tier4, --bob
    ["oil-boiler-4"] = fluid_tier5, --bob

    ["oil-steam-boiler"] = fluid_tier2, --ks power
}

local burner_generators = 
{
    ["bob-burner-generator"] = solid_tier1, --bob

    ["burner-generator"] = solid_tier1, --ks power
    ["big-burner-generator"] = solid_tier3, --ks power
}

--aai: use current value divided by fuel factor
if data.raw["burner-generator"]["burner-turbine"] then
    burner_generators["burner-turbine"] = data.raw["burner-generator"]["burner-turbine"].burner.effectivity / solid_fuel_factor
end


local generators = 
{
    ["fluid-generator"]   = fluid_tier2, --bob
    ["fluid-generator-2"] = fluid_tier3, --bob
    ["fluid-generator-3"] = fluid_tier4, --bob
    ["hydrazine-generator"] = fluid_tier5 * 1.103, --bob

    ["petroleum-generator"] = fluid_tier5, --ks power
}

local reactors = 
{   
    ["burner-reactor"]   = solid_tier3, --bob
    ["burner-reactor-2"] = solid_tier4, --bob
    ["burner-reactor-3"] = solid_tier5, --bob
    ["fluid-reactor"]   = fluid_tier3, --bob
    ["fluid-reactor-2"] = fluid_tier4, --bob
    ["fluid-reactor-3"] = fluid_tier5, --bob
}

-- don't change heat exchanger, because they are needed for nuclear
--data.raw.["boiler"]["heat-exchanger"].energy_source.effectivity = solid_tier3

for name, boiler in pairs(data.raw["boiler"]) do
    local tier = boilers[name]
    if tier then
        boiler.energy_source.effectivity = tier
        log("adjust efficiency of boiler: " .. name .. " to " .. tier)
    end
end

for name, generator in pairs(data.raw["generator"]) do
    local tier = generators[name]
    if tier then
        generator.effectivity = tier
        log("adjust efficiency of generator: " .. name .. " to " .. tier)
    end
end

for name, reactor in pairs(data.raw["reactor"]) do
    local tier = reactors[name]
    if tier then
        -- for some reason, all bob's fluid-reactors share the same energy_source instance. So, first copy before adjusting
        if name:find("^fluid") then
            reactor.energy_source = table.deepcopy(reactor.energy_source)
        end
        reactor.energy_source.effectivity = tier
        log("adjust efficiency of reactor: " .. name .. " to " .. tier)
    end
end

for name, burner_generator in pairs(data.raw["burner-generator"]) do
    local tier = burner_generators[name]
    if tier then
        burner_generator.burner.effectivity = tier
        log("adjust efficiency of burner-generator: " .. name .. " to " .. tier)
    end
end
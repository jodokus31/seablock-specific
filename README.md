# seablock-specific

## SeaBlock Evil mode

Flaring gases and clarify fluids is heavily restricted and consumes more power. H2/O2 still can be voided, but also could be tranformed into steam.\
Lower tier boilers are less efficient, but higher tiers get better.\
\
CAUTION: Voiding solid item by destroying containers won't work, because the items get spilled on the ground.\

### Details:
 - Disables most water void recipes\
   Exceptions: (Regular Water, Purified, Saline, Heavy Mud, Concentrated Mud, Light Mud, Thin Mud)
 - Disables most chemical void recipes\
   Exceptions: (Hydrogen, Oxygen, Nitrogen, Chlorine, Compressed Air)
 - Spill items on the floor, when containers are getting destroyed
 - Increase mining time of storage tanks and fluid wagons
 - Flarestack consumes 5 times more power
 - Add 2 recipes to get a bit of steam from hydrogen/oxygen (activated from start)
    - One to consume exactly the ratio of dirty electrolysis
    - One to consume more hydrogen, to be able to balance oxygen consumption.
    - Chemical plant mk1 is available from start.
 - Use "Burner power progression" (seperate mod) to adjust efficiencies of boiler tiers 
    - Fuel value for most chemical solids are doubled
    - Nerfed boiler efficiencies compared to default settings
    - Boiler mk1: 42.5% (actually 85% because of doubled fuel values)
    - Boiler mk2: 50.0% (actually 100%)
    - Boiler mk3: 57.5% (actually 115%)
    - Boiler mk4: 65.0% (actually 130%)
    - Boiler mk5: 75.0% (actually 150%)
    - Fluid boiler mk1: 60.0%
    - Fluid boiler mk2: 70.0%
    - Fluid boiler mk3: 82.5%
    - Fluid boiler mk4: 95.0%
    - Nuclear efficiencies are unchanged

## Burner Power Progression
Higher tier boilers for power generation are more efficient (supports Bob's Power and KS Power).\
\
Fuel values of chemical fuels (like coal or solid fuel) are doubled (except nuclear and rocket fuel).

### Details:
 - Fuel value for most chemical solids are doubled
    - Don't adjust nuclear fuel, rocket fuel, etc.
 - Boiler efficiency is tiered (percentages relative to unchanged values)
 - All tiers and fuel factors are customizable
 - Fuel values for most chemical solids are doubled
 - Default values:
    - Boiler mk1: default 50.0% (actually 100% because of doubled fuel values)
    - Boiler mk2: default 55.0% (actually 110%)
    - Boiler mk3: default 62.5% (actually 125%)
    - Boiler mk4: default 72.5% (actually 145%)
    - Boiler mk5: default 85.0% (actually 170%)
    - Fluid boiler mk1: default 100%
    - Fluid boiler mk2: default 110%
    - Fluid boiler mk3: default 125%
    - Fluid boiler mk4: default 145%
    - Nuclear efficiencies are unchanged

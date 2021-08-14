local DefaultTiers = {}

DefaultTiers.SOLID_TIER1 = 0.5 
DefaultTiers.SOLID_TIER2 = 0.55
DefaultTiers.SOLID_TIER3 = 0.625
DefaultTiers.SOLID_TIER4 = 0.725
DefaultTiers.SOLID_TIER5 = 0.85

DefaultTiers.FLUID_TIER1 = "-.-"
DefaultTiers.FLUID_TIER2 = 1.0
DefaultTiers.FLUID_TIER3 = 1.1
DefaultTiers.FLUID_TIER4 = 1.25
DefaultTiers.FLUID_TIER5 = 1.45

function DefaultTiers.GetSolidTiers()
  return DefaultTiers.SOLID_TIER1 .. ", "
      .. DefaultTiers.SOLID_TIER2 .. ", "
      .. DefaultTiers.SOLID_TIER3 .. ", "
      .. DefaultTiers.SOLID_TIER4 .. ", "
      .. DefaultTiers.SOLID_TIER5 
end

function DefaultTiers.GetFluidTiers()
  return DefaultTiers.FLUID_TIER1 .. ", "
      .. DefaultTiers.FLUID_TIER2 .. ", "
      .. DefaultTiers.FLUID_TIER3 .. ", "
      .. DefaultTiers.FLUID_TIER4 .. ", "
      .. DefaultTiers.FLUID_TIER5 
end

return DefaultTiers

module Ai4EComponentLib

using ModelingToolkit

@variables t
∂ = Differential(t)

export t, ∂

include("lib/Electrochemistry/Electrochemistry.jl")
include("lib/IncompressiblePipe/IncompressiblePipe.jl")
include("lib/CompressedAirSystem/CompressedAirSystem.jl")
include("lib/AirPipeSim/AirPipeSim.jl")
include("lib/ThermodynamicCycle/ThermodynamicCycle.jl")
include("lib/HVAC/HVAC.jl")

end

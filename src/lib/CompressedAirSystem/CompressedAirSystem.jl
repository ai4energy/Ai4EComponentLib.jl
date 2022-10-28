module CompressedAirSystem

using ModelingToolkit, IfElse
using DocStringExtensions

@variables t
∂ = Differential(t)

include("utils.jl")
include("Components/pipes.jl")
include("Components/compressors.jl")
include("Components/air_storage_tank.jl")
include("Components/filter_and_cooler.jl")
include("Components/sources.jl")
include("Components/valves.jl")

export  FlowPort,
        StraightPipe, SimplifiedPipe, TransitionPipe,
        VarySpeedCompressor,
        AirStroageTank,
        Purifier,
        Source,
        ConstantValve
export t, ∂
end # module

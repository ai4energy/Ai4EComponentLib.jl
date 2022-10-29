module CompressedAirSystem

using ModelingToolkit, IfElse
using DocStringExtensions

@variables t
∂ = Differential(t)

include("utils.jl")
include("components/pipes.jl")
include("components/compressors.jl")
include("components/air_storage_tank.jl")
include("components/filter_and_cooler.jl")
include("components/sources.jl")
include("components/valves.jl")

export  FlowPort,
        StraightPipe, SimplifiedPipe, TransitionPipe,
        VarySpeedCompressor,
        AirStroageTank,
        Purifier,
        Source,
        ConstantValve
export t, ∂
end # module

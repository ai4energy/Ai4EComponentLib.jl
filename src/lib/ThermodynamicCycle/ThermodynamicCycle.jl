module ThermodynamicCycle

using CoolProp
using ModelingToolkit
using DocStringExtensions

include("utils.jl")
include("components/process.jl")
include("components/states.jl")

export IsentropicProcess, IsobaricProcess, IsochoricProcess, IsoenthalpyProcess, IsothermalProcess
export ThermalStates, DThermalStates, ArbitraryProcess, StreamNode, StreamPort
export t, ∂
end
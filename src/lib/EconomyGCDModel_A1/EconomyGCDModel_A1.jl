module EconomyGCDModel_A1

using ..Ai4EComponentLib
using ModelingToolkit, Unitful

include("utils.jl")
include("components/Firm.jl")
include("components/Household.jl")

export Firm
export Household
export Capitalflow

end
module Electrochemistry

using ModelingToolkit, Unitful
using DocStringExtensions
using ..Ai4EComponentLib

include("utils.jl")
include("components/Electrolyzer.jl")
include("components/PhotovoltaicCell.jl")
include("components/Lithium_ion_batteries.jl")

export PhotovoltaicCell, PEMElectrolyzer, Lithium_ion_batteries
export Pin, Ground, OnePort

end
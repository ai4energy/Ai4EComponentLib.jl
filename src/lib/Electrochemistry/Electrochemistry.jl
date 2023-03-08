module Electrochemistry

using ModelingToolkit, Unitful
using DocStringExtensions
using ..Ai4EComponentLib

include("utils.jl")
include("components/Electrolyzer.jl")
include("components/PhotovoltaicCell.jl")
include("components/Lithium_ion_batteries.jl")
include("components/Charge_Controller.jl")
include("components/DC2DC.jl")
include("components/Super_capacity.jl")
include("components/Vanadium_flow_batteries.jl")
include("components/MPPT_Controller.jl")

export PhotovoltaicCell,
    PEMElectrolyzer,
    Lithium_ion_batteries,
    charge_controller, DC2DC,
    Lithium_ion_batteries_PNGV,
    step_v, MPPT_Controller,
    MPPT_Controller_2Pin,
    PhotovoltaicCell_secrete,
    Super_capacity,
    Vanadium_flow_batteries

export Pin,
    Ground,
    OnePort,
    OnePort_key,
    TwoPort,
    Resistor,
    vari_Resistor,
    Conductor,
    Capacitor,
    Inductor,
    Voltage_source,
    Current_source,
    RealInput,
    RealOutput,
    Constant,
    Secrete,
    electronic_load,
    get_datas
end
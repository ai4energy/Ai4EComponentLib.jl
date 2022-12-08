using Ai4EComponentLib
using SafeTestsets

# Base.show_backtrace(false)

@safetestset "IncompressiblePipe System" begin
    include("incompressiblepipe.jl")
end

@safetestset "hvac_test" begin
    include("hvac_test.jl")
end

@safetestset "Li_battery_test" begin
    include("Li_battery_test.jl")
end

@safetestset "AirPipeSim" begin
    include("AirPipeSim.jl")
end

@safetestset "Photovoltaic_energy_storage_system" begin
    include("Photovoltaic_energy_storage_system.jl")
end

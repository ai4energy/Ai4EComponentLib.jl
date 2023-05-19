using Ai4EComponentLib
using SafeTestsets

Base.show_backtrace(stdout, false)

#  @safetestset "IncompressiblePipe System" begin
#      include("incompressiblepipe.jl")
#  end

#  @safetestset "hvac_test" begin
#      include("hvac_test.jl")
#  end

#  @safetestset "Li_battery_test" begin
#      include("Li_battery_test.jl")
#  end

#  @safetestset "Photovoltaic_energy_storage_system" begin
#      include("Photovoltaic_energy_storage_system.jl")
#  end

@safetestset "Exam_ThermodynamicCycle.jl" begin
    include("Exam_ThermodynamicCycle.jl")
end

@safetestset "Exam_IncompressiblePipe.jl" begin
    include("Exam_IncompressiblePipe.jl")
end

@safetestset "Exam_AirPipeSim" begin
    include("Exam_AirPipeSim.jl")
end

@safetestset "Exam_Li_battery" begin
    include("Exam_Li_battery.jl")
end

@safetestset "Exam_PEMElectrolyzer" begin
    include("Exam_PEMElectrolyzer.jl")
end

@safetestset "Exam_PhotovoltaicCell" begin
    include("Exam_PhotovoltaicCell.jl")
end

@safetestset "Exam_EconomyGCDModel_A1" begin
    include("Exam_EconomyGCDModel_A1.jl")
end



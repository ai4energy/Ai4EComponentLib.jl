using Ai4EComponentLib
using Documenter

# Automatically generate API files and check the files
include("writeAPI.jl")
tutorial_files = readdir(joinpath(@__DIR__, "src", "tutorials"))
tutorials = map(file -> joinpath("tutorials", file), tutorial_files)
API_files = joinpath.(@__DIR__, "src", "API", tutorial_files)
map(x -> write(x, writeAPIcontents(splitpath(x)[end][1:end-3])), API_files)
API = map(file -> joinpath("API", file), readdir(joinpath(@__DIR__, "src/API")))

DocMeta.setdocmeta!(Ai4EComponentLib, :DocTestSetup, :(using Ai4EComponentLib); recursive=true)

makedocs(;
    modules=[
        Ai4EComponentLib
        Ai4EComponentLib.Electrochemistry
        Ai4EComponentLib.AirPipeSim
        Ai4EComponentLib.CompressedAirSystem
        Ai4EComponentLib.IncompressiblePipe
        Ai4EComponentLib.ThermodynamicCycle
        Ai4EComponentLib.EconomyGCDModel_A1
    ],
    authors="jake484 <522432938@qq.com> and contributors",
    repo="https://github.com/ai4energy/Ai4EComponentLib.jl/blob/{commit}{path}#{line}",
    sitename="Ai4EComponentLib.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ai4energy.github.io/Ai4EComponentLib.jl",
        edit_link="main",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
        "Tutorials" => tutorials,
        "API" => API
    ]
)

deploydocs(;
    repo="github.com/ai4energy/Ai4EComponentLib.jl",
    devbranch="main"
)

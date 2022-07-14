using Ai4EComponentLib
using Documenter

DocMeta.setdocmeta!(Ai4EComponentLib, :DocTestSetup, :(using Ai4EComponentLib); recursive=true)

makedocs(;
    modules=[
        Ai4EComponentLib
        Ai4EComponentLib.Electrochemistry
    ],
    authors="jake484 <522432938@qq.com> and contributors",
    repo="https://github.com/ai4energy/Ai4EComponentLib.jl/blob/{commit}{path}#{line}",
    sitename="Ai4EComponentLib.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ai4energy.github.io/Ai4EComponentLib.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials/Electrochemistry.md"
            "tutorials/IncompressiblePipe.md"
        ],
        "API" => [
            "API/IncompressiblePipeAPI.md"
            "API/ElectrochemistryAPI.md"
        ]
    ],
)

deploydocs(;
    repo="github.com/ai4energy/Ai4EComponentLib.jl",
    devbranch="main",
)

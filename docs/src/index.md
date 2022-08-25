# Ai4EComponentLib.jl

Ai4EComponentLib.jl is a Component library based on the [ModelingToolkit](https://mtk.sciml.ai/dev/) acasual modeling system.

## Installation

Import Ai4EComponentLib.jl in the standard way:

```julia
import Pkg; Pkg.add("Ai4EComponentLib")
```

## Citation

If Ai4EComponentLib is useful, please cite the this [paper](https://arxiv.org/abs/2208.11352):

```
@article{yang2022ai4ecomponentlib,
  title={Ai4EComponentLib.jl: A Component-base Model Library in Julia},
  author={Yuebao Yang, Jingyi Yang, Mingtao Li},
  journal={arXiv preprint arXiv:2208.11352},
  year={2022},
  primaryClass={cs.SE}
}
```

## Tutorials

```@contents
Pages = map(file -> joinpath("tutorials", file), readdir("tutorials"))
```

## Libraries

```@contents
Pages = map(file -> joinpath("API", file), readdir("API"))
```

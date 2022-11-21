"""
$(TYPEDSIGNATURES)

`Source` is a general source, which can generate pressure boundary("p"), temperature boundary("T") or mass flow boundary("qm") with different input parameters.

Valve with constant resistance.

# Arguments:
-  `boundary`: `Dict` with boundaries

# Connectors:
- `source`: port of source

```julia
inletBoundary = Dict(
    "p" => 1.0e5(1 + 0.001sin(t)),
    "T" => 300,
)
```

"""
function Source(; name, boundary)
    @named source = FlowPort()
    d = Dict("p" => source.p, "T" => source.T, "qm" => -source.qm)
    eqs = Equation[]
    for i in keys(boundary)
        if haskey(d, i)
            push!(eqs, d[i] ~ boundary[i])
        else
            error("Boundary", i, "is not availabe.")
        end
    end
    compose(ODESystem(eqs, t; name), source)
end
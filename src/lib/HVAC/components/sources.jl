"""
$(TYPEDSIGNATURES)

# Component: Source

# States:
"""
function source(; name, qm=100, p=100, t0=30.0)
    @named source = FlowPort()
    compose(ODESystem([], t; name), source)
end
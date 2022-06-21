
@parameters t
∂ = Differential(t)

"""
$(TYPEDSIGNATURES)

A pin in an analog circuit.

From [ModelingToolkitStandardLibrary.jl](http://mtkstdlib.sciml.ai/dev/)

# States:
- `v(t)`: [`V`] The voltage at this pin
- `i(t)`: [`A`] The current passing through this pin
"""
@connector function Pin(; name)
    sts = @variables v(t) = 1.0 i(t) = 1.0 [connect = Flow]
    ODESystem(Equation[], t, sts, []; name=name)
end



"""
$(TYPEDSIGNATURES)

Ground node with the potential of zero and connector `g`. Every circuit must have one ground
node.

From [ModelingToolkitStandardLibrary.jl](http://mtkstdlib.sciml.ai/dev/)

# Connectors:
- `g`
"""
function Ground(; name)
    @named g = Pin()
    eqs = [g.v ~ 0]
    compose(ODESystem(eqs, t, [], []; name=name), g)
end



"""
$(TYPEDSIGNATURES)

Component with two electrical pins `p` and `n` and current `i` flows from `p` to `n`.

From [ModelingToolkitStandardLibrary.jl](http://mtkstdlib.sciml.ai/dev/)

# States:
- `v(t)`: [`V`] The voltage across component `p.v - n.v`
- `i(t)`: [`A`] The current passing through positive pin

# Parameters:
- `v_start`: [`V`] Initial voltage across the component
- `i_start`: [`A`] Initial current through the component

# Connectors:
- `p` Positive pin
- `n` Negative pin
"""
function OnePort(; name)
    @named p = Pin()
    @named n = Pin()
    sts = @variables v(t) = 1.0 i(t) = 1.0
    eqs = [
        v ~ p.v - n.v
        0 ~ p.i + n.i
        i ~ p.i
    ]
    compose(ODESystem(eqs, t, sts, []; name=name), p, n)
end
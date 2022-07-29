
"""
$(TYPEDSIGNATURES)

# Component: a source (or sink) with constant pressure

# Parameters:
* `p`: [`Pa`] The pressure this source (or sink) supply.
* `T`: [`K`] Temperature of the gas flow out (or into) this source (or sink). Default to 300K.

# Connectors:
- `port`: a FlowPort type subcomponent.
"""
function PressureSource(; name, p=1.013e5, T=300)
    @named port = FlowPort(T=T)
    eqs = [
        port.p ~ p
    ]
    compose(ODESystem(eqs, t, [], []; name=name), port)
end

"""
$(TYPEDSIGNATURES)

# Component: a source (or sink) with constant mass flow rate

# Parameters:
* `qm`: [`kg⋅s^{-1}`] The mass flow rate this source supply or this sink absorb.
* `T`: [`K`] Temperature of the gas flow out (or into) this source (or sink). Default to 300K.

# Connectors:
- `port`: a FlowPort type subcomponent.
"""
function FlowSource(; name, qm=0.0, T=300)
    @named port = FlowPort(T=T)
    eqs = [
        port.qm ~ -qm
    ]
    compose(ODESystem(eqs, t, [], []; name=name), port)
end
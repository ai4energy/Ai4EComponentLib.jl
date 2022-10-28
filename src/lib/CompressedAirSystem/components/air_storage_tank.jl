"""
$(TYPEDSIGNATURES)

Air tank.

Valve with constant resistance.

# Arguments:
-  `V`: [`m³`] Volume, defaults: 20
-  `T`: [`K`] Temperature, defaults: 300
-  `p0`: [`Pa`] Initial pressure, defaults: 1e5

# Connectors:
- `inlet` inlet of components
- `outlet` outlet of components
"""
function AirStroageTank(; name, V=20, T=300, p0=1e5)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    @variables p(t) = p0
    @parameters V = V T = T
    eqs = [
        ∂(p) ~ 287.11 * T / V * (inlet.qm + outlet.qm)
        p ~ inlet.p
        p ~ outlet.p
        inlet.T ~ T
        outlet.T ~ T
    ]
    compose(ODESystem(eqs, t; name=name), inlet, outlet)
end
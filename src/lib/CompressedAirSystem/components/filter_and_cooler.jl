"""
$(TYPEDSIGNATURES)

General purifier.

# Arguments:
-  `c`: Purification coefficient, percentage of residual mass flow after purification to inlet mass flow, defaults: 1.0
-  `Δp`: [`Pa`] Absolute pressure drop across the component
-  `T`: [`K`] Outlet temperature after cooling

# Connectors:
- `inlet` inlet of components
- `outlet` outlet of components
"""
function Purifier(; name, c=1, Δp=0, T = 300)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    @variables ΔT(t) = 0
    @parameters c = c Δp = Δp T = T
    eqs = [
        inlet.p - outlet.p ~ Δp
        outlet.qm ~ -inlet.qm * c
        ΔT ~ inlet.T - outlet.T
        outlet.T ~ T
    ]
    compose(ODESystem(eqs, t; name=name), inlet, outlet)
end
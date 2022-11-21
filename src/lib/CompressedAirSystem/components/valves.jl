function GateValve(; name, operations, T=300)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    @parameters T=T
    eqs = [
        outlet.qm + inlet.qm ~ 0
        outlet.T ~ inlet.T
        0 ~ operations*(inlet.p-outlet.p)/1e5+(1-operations)*inlet.qm
    ]
    compose(ODESystem(eqs, t; name), inlet, outlet)
end


"""
$(TYPEDSIGNATURES)

Valve with constant resistance.

# Connectors:
- `inlet` inlet of components
- `outlet` outlet of components
"""
function ConstantValve(; name, R=100)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    @parameters R=R
    eqs = [
        outlet.qm + inlet.qm ~ 0
        outlet.T ~ inlet.T
        inlet.p-outlet.p~R*inlet.qm*abs(inlet.qm)
    ]
    compose(ODESystem(eqs, t; name), inlet, outlet)
end

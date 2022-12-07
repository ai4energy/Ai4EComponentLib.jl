"""
$(TYPEDSIGNATURES)

# Component: SimplePipe(pipe with fixed friction factor `f`)

# States:

# Parameters:
- `R`: [`Pa·s/m³`] Friction factor

# Arguments:


# Connectors:
- `inlet`: Inlet of pipe
- `outlet`: Outlet of pipe

"""
function SimplePipe(; name, R=100, T=300)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    ps = @parameters begin
        R = R
    end
    eqs = [
        inlet.p - outlet.p ~ R * inlet.qm * abs(inlet.qm),
        inlet.qm + outlet.qm ~ 0,
        inlet.T ~ outlet.T
    ]
    compose(ODESystem(eqs, t, [], ps; name=name), inlet, outlet)
end
"""
$(TYPEDSIGNATURES)

# Component: Source_P(source with inlet pressure losses)

# Parameters:
* `D`: [`m`] Diameter of pipe
* `K_inlet`: Local resistance loss coefficient of Inlet port, `default`: 0.5

# Connectors:
- `port`: port of source

# Arguments:
* `z`: [`m`] The height of source
* `ρ`: [`m³/kg`] The density of fluid
* `p`: [`Pa`] The pressure of source, `default`: 101325 (standard atmospheric pressure)

"""
function Source_P(; name, D=25E-3, z=0.0, ρ=1.0E3, p=101325, K_inlet=0.5)
    @named port = PipeNode(z=z)
    eqs = [
        _NodeEnergy(port, D, ρ) ~ p / (ρ * gn) + z + _h_m(port, K_inlet, D)
    ]
    compose(ODESystem(eqs, t, [], [], name=name), port)
end



"""
$(TYPEDSIGNATURES)

# Component: Sink_P

Sink_P can be defined as a source(where fluids are from) or sink(where fluid are going to).

# Connectors:
- `port`: port of sink

# Arguments:
* `p`: [`Pa`] The pressure of sink, `default`: 101325 (standard atmospheric pressure)

"""
function Sink_P(; name, p=101325)
    @named port = PipeNode(z=0.0)
    eqs = [
        port.p ~ p
    ]
    compose(ODESystem(eqs, t, [], [], name=name), port)
end
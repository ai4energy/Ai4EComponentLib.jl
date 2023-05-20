"""
$(TYPEDSIGNATURES)

State Equation of Dry Air
"""
stateEquation(p, ρ, T) = p - ρ * T * 287.11
@register_symbolic stateEquation(p, ρ, T) #状态方程


"""
$(TYPEDSIGNATURES)

Port(inlet or outlet) in CompressedAirSystem.

# States:
- `p(t)`: [`Pa`] The pressure at this port
- `qm(t)`: [`kg/s`] The mass flow rate passing through this port
- `T(t)`: [`K`] The mass flow rate passing through this port
- `ρ(t)`: [`kg/m³`] The density passing at this port
- `μ(t)`: [`Pa⋅s`] The absolute viscosity at this port
- `qv(t)`: [`m³/s`] The volume  flow rate passing through this port

"""
@connector function FlowPort(; name)
    sts = @variables begin
        p(t) = 1.013e5
        T(t) = 300
        (qm(t)=0, [connect = Flow])
        (ρ(t)=1.2, [connect = Stream])
        (μ(t)=1.819e-5, [connect = Stream])
        (qv(t)=0, [connect = Stream])
    end
    eqs = [
        0 ~ stateEquation(p, ρ, T)
        μ ~ 1.819e-5
        qv ~ qm / ρ
    ]
    ODESystem(eqs, t, sts, []; name=name)
end


"""
$(TYPEDSIGNATURES)

The Component with two ports `inlet` and `outlet` and mass flow `qm` flows from `inlet` to `outlet`.
It plays the same role as `Oneport` in the circuit system.

# States:
- `qm(t)`: [`kg/s`] The mass flow rate passing through this component
- `Δp(t)`: [`Pa`] The pressure difference at a component
- `ρ_mean(t)`: [`kg/m³`] The density at a component
- `μ_mean(t)`: [`Pa⋅s`] The absolute viscosity at a component
- `qv_mean(t)`: [`m³/s`] The volume flow rate passing through this component

# Connectors:
- `inlet` inlet of components
- `outlet` outlet of components
"""
function SISOComponent(; name)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    vars = @variables begin
        Δp(t) = 2000
        qm(t) = 0
        qv_mean(t) = 0
        ρ_mean(t) = 1.2
        μ_mean(t) = 1.819e-5
    end
    eqs = [
        Δp ~ inlet.p - outlet.p
        qm ~ inlet.qm
        qm ~ -outlet.qm
        ρ_mean ~ sqrt(abs(inlet.ρ * outlet.ρ))
        μ_mean ~ sqrt(abs(inlet.μ * outlet.μ))
        qv_mean * ρ_mean ~ qm
    ]
    compose(ODESystem(eqs, t, vars, []; name=name), inlet, outlet)
end
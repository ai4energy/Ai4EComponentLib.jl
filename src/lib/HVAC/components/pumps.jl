"""
$(TYPEDSIGNATURES)

# Component: CentrifugalPump

# States:
- `n(t)`: [`rpm`] Actual speed of pump
- `qv(t)`: [`m³/s`] Actual volume flow rate
- `H(t)`: [`m`] Actual head
- `η(t)`: [`-`] Actual efficiency
- `P(t)`: [`W`] Actual power

# Parameters:
- `D`: [`m`] Diameter of pump
- `n0`: [`rpm`] Rated speed of pump
- `ρ`: [`kg/m³`] Density of liquid
- `g`: [`m/s²`] Gravitational acceleration

# Arguments:
- `name`: Name of the component
- `D`: [`m`] Diameter of pump
- `n0`: [`rpm`] Rated speed of pump
- `ρ`: [`kg/m³`] Density of liquid
- `g`: [`m/s²`] Gravitational acceleration

# Connectors:
- `inlet`: Inlet of pump
- `outlet`: Outlet of pump

"""
function Pump(; name, D::Vector{Float64}, n0=2000, ρ=1.0e3, g=10.0) 
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    sts = @variables begin
        n(t) = 50     
        qv(t) = 0.1      
        H(t) = 1.5      
        η(t) = 0.5      
        P(t) = 2000      
    end
    ps = @parameters D[1:6] = D n0 = n0 ρ = ρ g = g
    eqs = [
        qv ~ inlet.qm / ρ,
        H ~ (outlet.p - inlet.p) / (ρ * g),
        H ~ D[1]*(n/n0)^2+D[2]*qv*(n/n0)^2+D[3]*qv^2,
        η ~ D[4] + D[5] * qv * (n0 / n) + D[6] * qv^2 * (n0 / n)^2,
        P ~ (qv * ρ * g * H) / η,
        inlet.qm + outlet.qm ~ 0,
        inlet.T ~ outlet.T
    ]
    compose(ODESystem(eqs, t; name), inlet, outlet)
end

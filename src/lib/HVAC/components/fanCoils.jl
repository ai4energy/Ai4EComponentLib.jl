"""
$(TYPEDSIGNATURES)

# Component: FanCoil

# States:
- `Qf(t)`: [`W`] Actual heat transfer
- `Twi(t)`: [`K`] Actual inlet water temperature
- `Two(t)`: [`K`] Actual outlet water temperature

# Arguments:
- `D`: [`Vector{Float64}`] Coefficient of fan coil
- `Qf0`: [`W`] Rated heat transfer
- `Tai0`: [`K`] Rated inlet air temperature
- `Twi0`: [`K`] Rated inlet water temperature
- `Tai`: [`K`] Inlet air temperature
- `cp`: [`J/(kg·K)`] Specific heat of water

# Connectors:
- `inlet`: Inlet of fan coil
- `outlet`: Outlet of fan coil

"""
function FanCoil(; name, D::Vector{Float64}, Qf0=2000, Tai0=25, Twi0=7, Tai=25, cp=4.18)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    sts = @variables begin
        Qf(t) = 10   
        Twi(t) = 8      
        Two(t) = 12     
    end

    ps = @parameters D[1:3] = D Qf0 = Qf0 Tai0 = Tai0 Twi0 = Twi0 cp = cp Tai = Tai
    eqs = [
        Qf ~ D[1] * (abs(Tai) / Tai0)^D[2] * (abs(Twi) / Twi0)^D[3] * Qf0,
        Twi ~ inlet.T,
        Two ~ outlet.T,
        Qf ~ inlet.qm * (Two - Twi) * cp,
        inlet.p ~ outlet.p,
        inlet.qm + outlet.qm ~ 0
    ]
    compose(ODESystem(eqs, t; name), inlet, outlet)
end
"""
$(TYPEDSIGNATURES)

# Component: CoolingTower

# States:
- `qc(t)`: [`kg/s`] Cooling water mass flow
- `Tci(t)`: [`K`] Water supply temperature of cooling water
- `Tco(t)`: [`K`] Return water temperature
- `ΔT(t)`: [`K`] Temperature difference between supply and return water

# Parameters:
- `Tw`: [`K`] Water temperature
- `ΔTct`: [`K`] Temperature difference between water and air

# Equations:
- `qc ~ inlet.qm`: [`kg/s`] Cooling water mass flow
- `Tci ~ outlet.T`: [`K`] Water supply temperature of cooling water
- `Tco ~ inlet.T`: [`K`] Return water temperature
- `Tci ~ Tw + ΔTct`: [`K`] Water temperature
- `ΔT ~ Tco - Tci`: [`K`] Temperature difference between supply and return water
- `inlet.qm + outlet.qm ~ 0`: [`kg/s`] Mass balance
- `inlet.p ~ outlet.p`: [`Pa`] Pressure balance

# Arguments:


# Connectors:
- `inlet`: Inlet of cooling tower
- `outlet`: Outlet of cooling tower


"""
function CoolingTower(; name, Tw=26, ΔTct=5)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    sts = @variables begin
        qc(t) = 100     
        Tci(t) = 26     
        Tco(t) = 40     
        ΔT(t) = 10 
    end
    ps = @parameters Tw = Tw ΔTct = ΔTct
    eqs = [
        qc ~ inlet.qm,
        Tci ~ outlet.T,
        Tco ~ inlet.T,
        Tci ~ Tw + ΔTct,
        ΔT ~ Tco - Tci,
        inlet.qm + outlet.qm ~ 0,
        inlet.p ~ outlet.p
    ]
    compose(ODESystem(eqs, t; name), inlet, outlet)
end
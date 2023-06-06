"""
$(TYPEDSIGNATURES)

# Component: WaterChiller

# States:
- `COP(t)`: [`-`] Coefficient of performance
- `Qe(t)`: [`W`] Cooling capacity
- `P(t)`: [`W`] Power
- `PLR(t)`: [`-`] Power load ratio
- `qe(t)`: [`m³/s`] Cooling water flow rate
- `qc(t)`: [`m³/s`] Chilled water flow rate
- `Tei(t)`: [`K`] Cooling water inlet temperature
- `Teo(t)`: [`K`] Cooling water outlet temperature
- `Tci(t)`: [`K`] Chilled water inlet temperature
- `Tco(t)`: [`K`] Chilled water outlet temperature
- `ΔTe(t)`: [`K`] Cooling water inlet-outlet temperature difference
- `ΔTc(t)`: [`K`] Chilled water inlet-outlet temperature difference

# Parameters:
- `D`: [`-`] Coefficient of performance
- `Qe0`: [`W`] Cooling capacity at PLR=1

# Arguments:
- `name`: Name of the component
- `Qe0`: [`W`] Cooling capacity at PLR=1

# Connectors:
- `coolerIn`: Inlet of cooler
- `coolerOut`: Outlet of cooler
- `chilledIn`: Inlet of chilled water
- `chilledOut`: Outlet of chilled water
"""


function WaterChiller_SimplifiedPolynomial(; name, D1,D2,D3,D4,D5,D6,D7,D8, Qe0=3000)
    @named coolerIn = FlowPort()
    @named coolerOut = FlowPort()
    @named chilledIn = FlowPort()
    @named chilledOut = FlowPort()
    sts = @variables begin
        COP(t) = 2      
        Qe(t) = 10      
        P(t) = 1000      
        PLR(t) = 0.8     
        qe(t) = 100      
        qc(t) = 100     
        Tei(t) = 7      
        Teo(t) = 15     
        Tci(t) = 26    
        Tco(t) = 40  
    end
    cp = 4.18
    ps = @parameters D1=D1 D2=D2 D3=D3 D4=D4 D5=D5 D6=D6 D7=D7 D8=D8 Qe0 = Qe0
    eqs = [
        COP ~ D1 + D2 * Qe + D3 * Teo + D4 * Tci + D5 * Qe^2 + D6 * Qe * Teo + D7 * Qe * Tci + D8 * Teo * Tci,
        Qe ~ COP * P,
        PLR ~ Qe / Qe0,
        Qe ~ (Teo - Tei) * qe * cp,
        (Tco - Tci) * qc * cp ~ (Teo - Tei) * qe * cp + P,
        Tco ~ coolerOut.T,
        Tci ~ coolerIn.T,
        Teo ~ chilledIn.T,
        Tei ~ chilledOut.T,
        qe ~ chilledIn.qm,
        qc ~ coolerIn.qm,
        chilledIn.qm + chilledOut.qm ~ 0,
        coolerIn.qm + coolerOut.qm ~ 0,
        chilledIn.p ~ chilledOut.p,
        coolerIn.p ~ coolerOut.p
    ]
    compose(ODESystem(eqs, t; name), coolerIn, coolerOut, chilledIn, chilledOut)
end

#=
function WaterChiller_SimplifiedPolynomial(; name, D::Vector{Float64}, Qe0=3000)
    @named coolerIn = FlowPort()
    @named coolerOut = FlowPort()
    @named chilledIn = FlowPort()
    @named chilledOut = FlowPort()
    sts = @variables begin
        COP(t) = 2      
        Qe(t) = 10      
        P(t) = 1000      
        PLR(t) = 0.8     
        qe(t) = 100      
        qc(t) = 100     
        Tei(t) = 7      
        Teo(t) = 15     
        Tci(t) = 26    
        Tco(t) = 40  
    end
    cp = 4.18
    ps = @parameters D[1:8] = D Qe0 = Qe0
    eqs = [
        COP ~ D[1] + D[2] * Qe + D[3] * Teo + D[4] * Tci + D[5] * Qe^2 + D[6] * Qe * Teo + D[7] * Qe * Tci + D[8] * Teo * Tci,
        Qe ~ COP * P,
        PLR ~ Qe / Qe0,
        Qe ~ (Teo - Tei) * qe * cp,
        (Tco - Tci) * qc * cp ~ (Teo - Tei) * qe * cp + P,
        Tco ~ coolerOut.T,
        Tci ~ coolerIn.T,
        Teo ~ chilledIn.T,
        Tei ~ chilledOut.T,
        qe ~ chilledIn.qm,
        qc ~ coolerIn.qm,
        chilledIn.qm + chilledOut.qm ~ 0,
        coolerIn.qm + coolerOut.qm ~ 0,
        chilledIn.p ~ chilledOut.p,
        coolerIn.p ~ coolerOut.p
    ]
    compose(ODESystem(eqs, t; name), coolerIn, coolerOut, chilledIn, chilledOut)
end
=#

"""
$(TYPEDSIGNATURES)

# Component: an air storage tank

# Assumptions

* Ignore the pressure drop between inlet and outlet. The pressure everywhere inside tank equal to the inlet and outlet.
* Temperature of the tank doesn't change. Default to 300K.
* Ideal gas law is avliable.

Function of this component:

```math
\\frac{\\mathrm{d}p}{\\mathrm{d}t}=\\frac{R_gT}{V}\\left (q_{m,in}+q_{m,in}\\right)
```

# Parameters:
* `R_g`: [`J⋅kg^{-1}⋅K^{-1}`] Ideal gas constant. For air is 287.11, which is unchangeable in this component.
* `V`: [`m^3`] Volume of the tank.
* `T`: [`K`] Temperature of the gas inside the tank.

# Connectors:
- `in`: Inlet of tank
- `out`: Outlet of tank

# Arguments:
* `p_0`: [`Pa`] Initial value of tank pressure.

"""
function AirStorageTank(; name, V=20, T=300, p0=5e5)
    @named inlet = FlowPort(T=T)
    @named outlet = FlowPort(T=T)
    @variables p(t) = p0
    @parameters V = V T = T
    eqs = [
        ∂(p) ~ 287.11 * T / V * (inlet.qm + outlet.qm)
        p ~ inlet.p
        p ~ outlet.p
    ]
    compose(ODESystem(eqs, t; name=name), inlet, outlet)
end
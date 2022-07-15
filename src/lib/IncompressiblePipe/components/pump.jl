"""
$(TYPEDSIGNATURES)

# Component: CentrifugalPump

Ideal H-Q Characteristic curves of Centrifugal Pumps:

```math
H_t=\\frac{(r\\omega)^2}{g}-\\frac{\\omega \\cot\\beta }{2\\pi bg}Q=c_0\\omega^2-c_1\\omega Q=a_0-a_1Q
```

# Parameters:
* `D`: [`m`] Diameter of pipe
* `ω`: [`r/min`] rotary speed
* `c_0`: parameter in H-Q Characteristic curves
* `c_1`: parameter in H-Q Characteristic curves

# Connectors:
- `in`: Inlet of pump
- `out`: Outlet of pump

"""
function CentrifugalPump(; name, D=25E-3, ω=2500, c_0=4.4e-4, c_1=5.622, ρ=1.0E3)
    @named in = PipeNode()
    @named out = PipeNode()
    a_0 = c_0 * abs2(ω * 2π / 60)
    a_1 = c_1 * ω * 2π / 60
    ps = @parameters D = D
    eqs = [
        _NodeEnergy(in, D, ρ) + a_0 - a_1 * abs(in.q) ~ _NodeEnergy(out, D, ρ)
        0 ~ in.q + out.q
    ]
    compose(ODESystem(eqs, t, [], ps, name=name), in, out)
end

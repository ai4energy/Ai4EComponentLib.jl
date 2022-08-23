"""
$(TYPEDSIGNATURES)

# Component: SimplePipe(pipe with fixed friction factor `f`)

Energy conservation equation in the form of Bernoulli Equation between two ports:

```math
\\frac{p_{in}}{\\rho g} +\\frac{8q_{in}^{2}}{\\pi^2D^4g} + z_{in}=
\\frac{p_{out}}{\\rho g} +\\frac{8q_{out}^{2}}{\\pi^2D^4g} + z_{out}+h_f+h_m
```

# Parameters:
* `D`: [`m`] Diameter of pipe
* `L`: [`m`] Length of pipe
* `f`: Friction factor
* `K_inside`: Coefficient of local resistance loss inside the pipe

# Connectors:
- `in`: Inlet of pipe
- `out`: Outlet of pipe

# Arguments:
* `zin`: [`m`] The height of inlet port
* `zout`: [`m`] The height of outlet port
* `ρ`: [`m³/kg] The density of fluid passing the port

"""
function SimplePipe(; name, L=10.0, D=25E-3, f=0.01, ρ=1.0E3, zin=0.0, zout=0.0, K_inside=0.0)
    @named in = PipeNode(z=zin)
    @named out = PipeNode(z=zout)
    ps = @parameters D = D L = L f = f K_inside = K_inside
    eqs = [
        _NodeEnergy(in, D, ρ) ~ _NodeEnergy(out, D, ρ) + _h_f(in, f, L, D) + _h_m(in, K_inside, D)
        0 ~ in.q + out.q
    ]
    compose(ODESystem(eqs, t, [], ps, name=name), in, out)
end


"""
$(TYPEDSIGNATURES)

# Component: ElbowPipe(pipe with fixed local resistance loss coefficient `f`)

Energy conservation equation in the form of Bernoulli Equation between two ports:

```math
\\frac{p_{in}}{\\rho g} +\\frac{8q_{in}^{2}}{\\pi^2D^4g} + z_{in}=
\\frac{p_{out}}{\\rho g} +\\frac{8q_{out}^{2}}{\\pi^2D^4g} + z_{out}+h_f+h_m
```

# Parameters:
* `D`: [`m`] Diameter of pipe
* `K`: Local resistance loss coefficient

# Connectors:
- `in`: Inlet of pipe
- `out`: Outlet of pipe

# Arguments:
* `zin`: [`m`] The height of inlet port
* `zout`: [`m`] The height of outlet port
* `ρ`: [`m³/kg] The density of fluid passing the port

"""
function ElbowPipe(; name, D=25E-3, K=1.0, ρ=1.0E3, zin=0.0, zout=0.0)
    @named in = PipeNode(z=zin)
    @named out = PipeNode(z=zout)
    ps = @parameters D = D K = K
    eqs = [
        _NodeEnergy(in, D, ρ) ~ _NodeEnergy(out, D, ρ) + _h_m(in, K, D)
        0 ~ in.q + out.q
    ]
    compose(ODESystem(eqs, t, [], ps, name=name), in, out)
end





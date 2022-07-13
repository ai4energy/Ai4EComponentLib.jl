"""
$(TYPEDSIGNATURES)

# Component: SimplePipe(pipe with fixed friction factor `f`)

Energy conservation equation in the form of Bernoulli Equation between two ports:

```math
\\frac{p_{in}}{\\rho g} +\\frac{8q_{in}^{2}}{2\\pi^2D^4g} + z_{in}=
\\frac{p_{out}}{\\rho g} +\\frac{8q_{out}^{2}}{2\\pi^2D^4g} + z_{out}+h_f+h_m
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
\\frac{p_{in}}{\\rho g} +\\frac{8q_{in}^{2}}{2\\pi^2D^4g} + z_{in}=
\\frac{p_{out}}{\\rho g} +\\frac{8q_{out}^{2}}{2\\pi^2D^4g} + z_{out}+h_f+h_m
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

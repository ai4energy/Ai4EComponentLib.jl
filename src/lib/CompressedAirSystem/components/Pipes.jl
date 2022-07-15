
"""
$(TYPEDSIGNATURES)

# Component: a single pipe or a pipe network with only one inlet and one outlet in steady state.

# Assumptions

* The density or pressure of the air doesn't change too fast.
* Temperature of the pipe (pipe network) doesn't change. Default to 300K.
* Ideal gas law is avliable.

Function of this component:

```math
p_{in}-p_{out}=Rq_m|q_m|
```

# Parameters:
* `R`: [`kg^{-1}⋅m^{-1}`] Resistance coefficient of a pipe (or pipe network)
* `T`: [`K`] Approximate temperature of the gas inside pipe.

# Connectors:
- `in`: Inlet of tank
- `out`: Outlet of tank

"""
function SimplePipe(; name, R=100, T=300)
    @named inlet = FlowPort(T=T)
    @named outlet = FlowPort(T=T)
    ps = @parameters begin
        R = R
    end
    eqs = [
        inlet.p - outlet.p ~ R * inlet.qm * abs(inlet.qm)
        inlet.qm + outlet.qm ~ 0
    ]
    compose(ODESystem(eqs, t, [], ps; name=name), inlet, outlet)
end


"""
$(TYPEDSIGNATURES)

# Component: a single straight pipe in transition state.

# Assumptions

* Ignore the difference in parameters on the same cross section. The flow inside pipe can be treated an 1-D flow.
* Temperature of the pipe (pipe network) doesn't change. Default to 300K.
* Ideal gas law is avliable.

Function of this component:

```math
\\frac{\\partial p}{\\partial t}=-\\frac{R_{g} T}{A} \\frac{\\partial q_{m}}{\\partial x} \\\\
\\frac{\\partial q_{m}}{\\partial t}=\\left(\\frac{R_{g} T}{A} \\frac{q_{m}^{2}}{p^{2}}-A\\right) \\frac{\\partial p}{\\partial x}-2 \\frac{R_{g} T}{A} \\frac{q_{m}}{p} \\frac{\\partial q_{m}}{\\partial x}-\\frac{f}{2 D} \\frac{R_{g} T}{A} \\frac{q_{m}\\left|q_{m}\\right|}{p}
```

# Parameters:
# Parameters:
* `R_g`: [`J⋅kg^{-1}⋅K^{-1}`] Ideal gas constant. For air is 287.11, which is unchangeable in this component.
* `T`: [`K`] Temperature of the air.
* `f`: Friction factor
* `D`: [`m`] Diameter of the pipe
* `L`: [`m`] Length of the pipe

# Connectors:
- `in`: Inlet of tank
- `out`: Outlet of tank

# Arguments:
* `λ1, λ2 and λ3`: Three coefficient for other use like parameter estimation. They have no influence on simulation, and they are default to 1.
* `n`: The number of control volumes that the pipe be divided into equally.
* `pins and pouts`: [`Pa`] The initial pressure at the inlet and outlet of pipe. Simulation will start from the steady state of pipe at the boundary pins and pouts.

"""
function TransitionPipe(; name,λ1=1.0,λ2=1.0,λ3=1.0, n=10, f=0.016, D=0.2, L=100, T=300, pins=0.56e6, pouts=0.56e6)
    #化作体积流量与压力的方程,消去密度
    RT = 287.11 * T
    A0 = pi / 4 * D^2
    c10 = RT / A0
    c20 = c10 * f / 2 / D
    dx=L/n

    @named inlet = FlowPort(T=T)
    @named outlet = FlowPort(T=T)

    @variables qm[1:n](t) p[1:n+1](t)

    qms = sqrt(abs(pins^2 - pouts^2) / (f * L * RT / D / A0 / A0))
    initialValue = Dict(qm[i] => qms for i = 1:n)
    merge!(initialValue, Dict(p[i] => sqrt(pins^2 * (1 - (i-1) / n) + pouts^2 * (i-1) / n) for i = 1:n+1))

    @parameters begin
        A = A0*λ2
        c1 = c10*λ1
        c2 = c20*λ3
        dx = L / n
        f = f
    end

    eqs_continous = [
        ∂(p[i]) ~ c1 * (qm[i-1] - qm[i]) / dx for i = 2:n
    ]

    eqs_momentum = [
        ∂(qm[i]) ~ (c1 * qm[i]^2 / (0.5 * (p[i+1] + p[i]))^2 - A) * (p[i+1] - p[i]) / dx + c1 * qm[i] / (0.5 * (p[i+1] + p[i])) * (qm[i-1] - qm[i+1]) / dx - c2 * qm[i] * abs(qm[i]) / (0.5 * (p[i+1] + p[i])) for i = 2:n-1
    ]

    bd = [
        p[1] ~ inlet.p
        p[n+1] ~ outlet.p
        qm[n] ~ -outlet.qm
        qm[1] ~ inlet.qm
        ∂(qm[1]) ~ (c1 * qm[1]^2 / (0.5 * (p[2] + p[1]))^2 - A) * (p[2] - p[1]) / dx + c1 * qm[1] / (0.5 * (p[2] + p[1])) * (3 * qm[1] - 4 * qm[2] + qm[3]) / dx - c2 * qm[1] * abs(qm[1]) / (0.5 * (p[2] + p[1]))
        ∂(qm[n]) ~ (c1 * qm[n]^2 / (0.5 * (p[n+1] + p[n]))^2 - A) * (p[n+1] - p[n]) / dx + c1 * qm[n] / (0.5 * (p[n+1] + p[n])) * (-3 * qm[n] + 4 * qm[n-1] - qm[n-2]) / dx - c2 * qm[n] * abs(qm[n]) / (0.5 * (p[n+1] + p[n]))
    ]
    compose(ODESystem([eqs_continous; eqs_momentum; bd], t; name=name, defaults=initialValue), inlet, outlet)
end
"""
$(TYPEDSIGNATURES)

Fitting Formula for Friction Coefficient of Turbulent Pipe
"""
pipeFriction_turbulent(f, Re, ϵ, D) = f - 1 / (2 * log10(abs(ϵ / D / 3.7 + 2.51 / Re / sqrt(abs(f)))))^2

"""
$(TYPEDSIGNATURES)

Flow rate in pipe
"""
pipeVelocity(Δp, ρ, L, D, f) = (Δp >= 0) ? (sqrt(abs(2 * Δp * D / L / f / ρ))) : (-sqrt(abs(-2 * Δp * D / L / f / ρ)))

"""
$(TYPEDSIGNATURES)

Reynolds number
"""
pipeRe(ρ, u, D, μ) = (u >= 0) ? (ρ * u * D / μ) : (-ρ * u * D / μ)

@register pipeFriction_turbulent(f, Re, ϵ, D)
@register pipeVelocity(Δp, ρ, L, D, f)
@register pipeRe(ρ, u, D, μ)

"""
$(TYPEDSIGNATURES)

Straight round pipe and height difference is not considered.
Friction coefficient is obtained from Modi diagram.

# Arguments:
-  `D`: [`m`] Pipe diameter, defaults: 1.0
-  `L`: [`m`] Pipe length, defaults: 1.0
-  `ϵ`: [`m`] Absolute roughness of pipeline, defaults: 0.05

# Connectors:
- `inlet` inlet of components
- `outlet` outlet of components

"""
function StraightPipe(; name, D=1.0, L=1.0, ϵ=0.05e-3)
    @named this_i1o1Component = SISOComponent()
    @unpack Δp, qm, ρ_mean, qv_mean, μ_mean, inlet, outlet = this_i1o1Component
    sts = @variables begin
        Re(t) = 1.5e5
        u(t) = 10
        f(t) = 0.03
        R(t) = 10
    end
    ps = @parameters D = D L = L ϵ = ϵ
    eqs = [
        Re ~ pipeRe(ρ_mean, u, D, μ_mean)
        0 ~ pipeFriction_turbulent(f, Re, ϵ, D)
        u ~ pipeVelocity(Δp, ρ_mean, L, D, f)
        qv_mean ~ u * pi / 4 * D * D
        R ~ abs(Δp) / qm / qm
    ]
    extend(ODESystem(eqs, t, sts, ps; name=name), this_i1o1Component)
end

"""
$(TYPEDSIGNATURES)

Simplified pipe model

# Arguments:
-  `R0`: [`kg/m^7`] Resistance coefficient of pipeline

# Connectors:
- `inlet` inlet of components
- `outlet` outlet of components

"""
function SimplifiedPipe(; name, R0)
    @named this_i1o1Component = SISOComponent()
    @unpack Δp, qm, qv_mean, inlet, outlet = this_i1o1Component
    sys = @variables R(t) = 3000
    eqs = [
        R ~ R0
        qm ~ IfElse.ifelse(Δp >= 0, sqrt(Δp / R), -sqrt(-Δp / R))
    ]
    extend(ODESystem(eqs, t, sys, []; name=name), this_i1o1Component)
end

"""
$(TYPEDSIGNATURES)

Simplified pipe model

# Arguments:
-  `f`: [`kg/m⁷`] Resistance coefficient of pipeline
-  `n`: Number of pipe discrete node
-  `D`: [`m`] Pipe diameter, defaults: 1.0
-  `L`: [`m`] Pipe length, defaults: 1.0
-  `T`: [`K`] Ambient temperature, defaults: 300
-  `p0`: [`Pa`] Initial pressure of each node
-  `qm0`: [`kg/(m²⋅s)`] Initial specific momentum of each node

# Connectors:
- `inlet` inlet of components
- `outlet` outlet of components

"""
function TransitionPipe(; name, n=10, f=0.011, D=1.0, L=1.0, T=300, p0=zeros(n), qm0=zeros(n))

    RT = 287.11 * T
    A0 = pi / 4 * D^2
    c10 = RT / A0
    c20 = c10 * f / 2 / D

    @named inlet = FlowPort()
    @named outlet = FlowPort()

    @parameters begin
        A = A0
        c1 = c10
        c2 = c20
        dx = L / n
        f = f
    end

    @variables (qm(t))[1:n] (p(t))[1:n+1]

    initialValue = Dict(qm[i] => qm0[i] for i = 1:n)
    merge!(initialValue, Dict(p[i] => p0[i] for i = 1:n))

    eqs_continous = [
        ∂(p[i]) ~ c1 * (qm[i-1] - qm[i]) / dx
        for i = 2:n
    ]

    eqs_momentum = [
        ∂(qm[i]) ~ (c1 * qm[i]^2 / (0.5 * (p[i+1] + p[i]))^2 - A) * (p[i+1] - p[i]) / dx + c1 * qm[i] / (0.5 * (p[i+1] + p[i])) * (qm[i-1] - qm[i+1]) / dx - c2 * qm[i] * abs(qm[i]) / (0.5 * (p[i+1] + p[i]))
        for i = 2:n-1
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

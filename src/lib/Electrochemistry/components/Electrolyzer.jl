
"""
$(TYPEDSIGNATURES)

# Component: Electrolyzer

I-U in Electrolyzer:
```math
U_{cell}=U_{0}-\\tau \\times \\sinh \\left(\\frac{I}{I_{0}(T)}\\right)+I \\times R_{\\text{sol}}(T)
```

Molar Yield of Hydrogen and Oxygen, Molar consumption of water:
```math
\\begin{aligned}
\\dot{n}_{H_{2} O} &=\\frac{n_{c} I_{e l}}{2 \\cdot F} \\\\
\\dot{n}_{H_{2}} &=\\frac{n_{c} I_{e l}}{2 \\cdot F} \\cdot \\eta_{f} \\\\
\\dot{n}_{O_{2}} &=\\frac{n_{c} I_{e l}}{2 \\cdot F} \\cdot \\eta_{f}
\\end{aligned}
```

Mass yield of hydrogen[1]:
```math
\\frac{\\mathrm{d}^{2} \\dot{m}}{\\mathrm{~d} t^{2}}=-2 \\zeta \\cdot \\omega_{n} \\frac{\\mathrm{d} \\dot{m}}{\\mathrm{~d} t}-\\omega_{n}{ }^{2} \\dot{m}+\\omega_{n}{ }^{2} M_{H_{2}} n_{H_{2}}
```

# States:
* `v(t)`: [`V`] Voltage across the Electrolyzer
* `i(t)`: [`A`] Current through the Electrolyzer
* `n_H_2(t)`: [`mol/s`] Molar Yield of Hydrogen
* `η_f(t)`: Faraday efficiency, here \$η_f = 1\$
* `m_H_2(t)`: ['g/s'] Mass yield of hydrogen
* `∂_m_H_2`: Derivative of hydrogen mass yield

# Parameters:
* `τ`: Tafel slope
* `I_0`: Exchange Current Density
* `n`: Number of electrolyzers in series
* `u_0`: Equilibrium potential
* `R_sol`: Solution resistance

# Inside Variables:
* ωₙ: Natural frequency of Hydrogen production [1]
* ζ: Damping ratio of Hydrogen production [1]
* molarMass_H_2: [`g/mol`] Molar mass of hydrogen

# Connectors:
- `p` Positive pin
- `n` Negative pin

# Reference:
* [1]Espinosa-López M, Darras C, Poggi P, et al. Modelling and experimental validation of a 46 kw pem high pressure water electrolyzer[J]. Renewable energy, 2018, 119:160-173.

"""
function Electrolyzer(; name, τ=0.02, I_0=0.01, n=1, u_0=1.47, R_sol=0.22)
    @named oneport = OnePort()
    @unpack v, i = oneport
    sts = @variables n_H_2(t) η_f(t) m_H_2(t) ∂_m_H_2(t)
    ps = @parameters(
        τ = τ,
        I_0 = I_0,
        n = n,
        ωₙ = 17,
        ζ = 0.7,
        molarMass_H_2 = 2.016,
        u_0 = u_0
    )
    eqs = [
        η_f ~ 1
        n_H_2 ~ i * n * η_f / ((Unitful.Na * Unitful.q).val)
        ∂(m_H_2) ~ ∂_m_H_2
        ∂(∂_m_H_2) ~ -2 * ζ * ωₙ * ∂_m_H_2 - ωₙ^2 * m_H_2 + ωₙ^2 * molarMass_H_2 * n_H_2
        v ~ τ * n * asinh(i / I_0) + n * u_0 + n * R_sol * i
    ]
    extend(ODESystem(eqs, t, sts, ps; name=name), oneport)
end
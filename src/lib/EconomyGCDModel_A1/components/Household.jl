
"""


# Component: an agent---Household.

Function of this component:

```math
household.m.w\\times household.m.L-household.m.p\\times household.m.C-household.m.M\\\\
(household.m.M)'=2\\mu^H_{M^H}(\\hat{M}^H-household.m.M)-\\lambda_2\\\\
(household.m.C)'=\\mu^H_C\\gamma (household.m.C)^{\\gamma-1}-\\lambda_1(household.m.p)+\\lambda_2(household.m.p)-\\lambda_3
```

# States:
- `Mʰ(t)`: Money stock household.
- `mʰ(t)`: Derivative of Mʰ(t).

# Parameters:
* `α,β`: Parameters in a simple Cobb-Douglas production function.
* `dp̂`: depreciation.
* `μ₁`: The parameter of Consumption.
* `μ₆`: The parameter of money stock household.
* `K₀`: Initial value of Capital.
* `M̂ʰ`: The amount of cash that Households aim to keep.
* `γ`: The parameter of Consumption and Household.

# Connectors:
- `m`: money.

"""
function Household(; name, α=0.05, β=0.011, γ=0.25, K₀=0.1, μ₁=0.011, μ₆=0.011, M̂ʰ=0.011)
    @named m = Capitalflow()
    ps = @parameters begin
        β = β
        K₀ = K₀
        α = α
        μ₁ = μ₁
        μ₆ = μ₆
        M̂ʰ = M̂ʰ
        γ = γ
    end
    sts = @variables begin
        Mʰ(t) = 1.2
        mʰ(t) = 0.0
    end
    eqs = [
        0 ~ (m.w) * (m.l) - (m.p) * (m.c) - mʰ
        mʰ ~ 2 * μ₆ * (M̂ʰ - Mʰ) - m.𝛌₁
        ∂(Mʰ) ~ mʰ
        ∂(m.c) ~ μ₁ * γ * abs(m.c)^(γ - 1) - m.𝛌₁ * (m.p) + m.𝛌₂ * (m.p) - m.𝛌₃
    ]
    compose(ODESystem(eqs, t, sts, ps; name=name), m)
end
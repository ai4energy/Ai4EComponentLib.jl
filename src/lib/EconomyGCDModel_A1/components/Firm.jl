
"""


# Component: an agent---firm.

Function of this component:

```math
DP=\\hat{dp}(K)\\\\
firm.m.p\\times firm.m.C-firm.m.w\\times firm.m.L-firm.m.M=0\\\\
\\beta(firm.m.L)^\\alpha(K)^{1-\\alpha}-firm.m.C-(K)'-(S)'-DP=0\\\\
(K)'=\\mu^H_Kp\\beta(1-\\alpha)(firm.m.L)^\\alpha(K)^{-\\alpha}-\\lambda_3\\\\
(firm.m.M)'=-\\lambda_2\\
(S)'=\\mu^F_S(\\hat{S}-S)-\\lambda_3\\ \\
(firm.m.p)'=\\mu^F_p\\beta(K)^{1-\\alpha}(firm.m.L)^\\alpha-\\lambda_1(firm.m.C)+\\lambda_2(firm.m.C)\\\\
(firm.m.w)'=\\mu^F_w(firm.m.L)+\\lambda_1(firm.m.L)-\\lambda_2(firm.m.L)\\\\
(firm.m.L)'=\\mu^H_L(\\hat{L}-firm.m.L)+\\mu^F_L(\\alpha\\beta(K)^{1-\\alpha}(firm.m.L)^{\\alpha-1}-firm.m.w)\\\\
+\\lambda_1(firm.m.w)-\\lambda_2(firm.m.w)+\\lambda_3\\alpha\\beta(firm.m.L)^{\\alpha-1}(K)^{1-\\alpha}
```

# Parameters:
* `α,β`: Parameters in a simple Cobb-Douglas production function.
* `dp̂`: depreciation.
* `μ₂`: The parameter of Capital.
* `μ₃`: The parameter of Labor and Household.
* `μ₄`: The parameter of Labor and Firm.
* `μ₇`: The parameter of Price.
* `μ₈`: The parameter of storage.
* `μ₉`: The parameter of Wage.
* `Ŝ`: The planned inventory of storage.
* `l̂`: The wish of working time.

# Connectors:
- `m`: money.

"""
function Firm(; name, α=0.05, β=0.011, dp̂=0.011, μ₂=0.011, μ₃=0.011, μ₄=0.011, μ₇=0.05, μ₈=0.011, μ₉=0.0, Ŝ=0.011, l̂=0.011)
    @named m = Capitalflow()
    ps = @parameters begin
        β = β
        α = α
        dp̂ = dp̂
        μ₂ = μ₂
        μ₃ = μ₃
        μ₄ = μ₄
        μ₇ = μ₇
        μ₈ = μ₈
        μ₉ = μ₉
        Ŝ = Ŝ
        l̂ = l̂
    end
    sts = @variables begin
        K(t) = 2.0
        Mᶠ(t) = 1.2
        mᶠ(t) = 0.1
        S(t) = 0.8
        𝛌₁(t) = -0.1
        𝛌₂(t) = -0.3
        𝛌₃(t) = 0.4
    end
    eqs = [
        0 ~ (m.p) * (m.c) - (m.w) * (m.l) - mᶠ
        0 ~ β * abs(m.l)^α * abs(K)^(1 - α) - m.c - ∂(K) - ∂(S) - dp̂ * (K)
        ∂(K) ~ μ₂ * (m.p) * β * (1 - α) * abs(m.l)^α * abs(K)^(-α) - m.𝛌₃
        mᶠ ~ -m.𝛌₂
        ∂(Mᶠ) ~ mᶠ
        ∂(S) ~ 2 * μ₈ * (Ŝ - S) - m.𝛌₃
        ∂(m.p) ~ μ₇ * β * abs(m.l)^α * abs(K)^(1 - α) - m.𝛌₁ * (m.c) + m.𝛌₂ * (m.c)
        ∂(m.w) ~ -μ₉ * (m.l) + m.𝛌₁ * (m.l) - m.𝛌₂ * (m.l)
        ∂(m.l) ~ 2 * μ₃ * (l̂ - m.l) + μ₄ * (α * β * abs(m.l)^(α - 1) * abs(K)^(1 - α) - m.w) + m.𝛌₁ * (m.w) - m.𝛌₂ * (m.w) + m.𝛌₃ * (α * β * abs(m.l)^(α - 1) * abs(K)^(1 - α))
    ]
    compose(ODESystem(eqs, t, sts, ps; name=name), m)
end
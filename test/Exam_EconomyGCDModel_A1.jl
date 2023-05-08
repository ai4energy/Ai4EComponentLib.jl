@info "Running EconomyGCDModel_A1..."
using Ai4EComponentLib
using Ai4EComponentLib.EconomyGCDModel_A1
using ModelingToolkit, OrdinaryDiffEq
using Test

@info "Constructing components..."
@named firm = Firm(α=0.05, β=0.011, dp̂=0.011, μ₂=0.011, μ₃=0.011, μ₄=0.011, μ₇=0.05, μ₈=0.011, μ₉=0.0, Ŝ=0.011, l̂=0.011)
@named household = Household(α=0.05, β=0.011, γ=0.25, K₀=0.1, μ₁=0.011, μ₆=0.011, M̂ʰ=0.011)

@info "Constructing system..."
eqs = [
    connect(firm.m, household.m)
]

@named connects = ODESystem(eqs, t)
@named model = compose(connects, [firm, household])

@info "Simplifying system..."
sys = structural_simplify(model)

@info "Solving system..."
prob = ODAEProblem(sys, [], (0.0, 10000.0))
sol = solve(prob, Tsit5(), reltol=1e-6)

@test sol.retcode == ReturnCode.Success

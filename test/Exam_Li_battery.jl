@info "Running Li_battery..."
using ModelingToolkit, OrdinaryDiffEq
using Ai4EComponentLib
using Ai4EComponentLib.Electrochemistry
using Test

@info "Constructing components..."
@named batter = Lithium_ion_batteries()
@named Pv = PhotovoltaicCell()
@named ground = Ground()

@info "Constructing system..."
eqs = [
    connect(batter.p, Pv.p)
    connect(batter.n, Pv.n)
    connect(Pv.n, ground.g)
]
@named OdeFun = ODESystem(eqs, t)
@named model = compose(OdeFun, [Pv, batter, ground])

@info "Simplifying system..."
sys = structural_simplify(model)

@info "Solving system..."
u0 = [
    batter.v_f => 0.5
    batter.v_s => 0.5
    batter.v_soc => 0.5
]
prob = ODEProblem(sys, u0, (0.0, 3600.0))
sol = solve(prob, Rosenbrock23())

@test sol.retcode == ReturnCode.Success

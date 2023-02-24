@info "Running PEMElectrolyzer..."
using ModelingToolkit, OrdinaryDiffEq
using Ai4EComponentLib
using Ai4EComponentLib.Electrochemistry
using Test

@info "Constructing components..."
@named Pv = PhotovoltaicCell()
@named El = PEMElectrolyzer()
@named ground = Ground()

@info "Constructing system..."
eqs = [
    connect(Pv.p, El.p)
    connect(Pv.n, El.n)
    connect(Pv.n, ground.g)
]
@named OdeFun = ODESystem(eqs, t)
@named model = compose(OdeFun, [Pv, El, ground])

@info "Simplifying system..."
sys = structural_simplify(model)

@info "Solving system..."
u0 = [
    El.m_H_2 => 0.0
    El.∂_m_H_2 => 0.0
]
prob = ODEProblem(sys, u0, (0.0, 3600.0))
sol = solve(prob, Rosenbrock23())

@test sol.retcode == ReturnCode.Success

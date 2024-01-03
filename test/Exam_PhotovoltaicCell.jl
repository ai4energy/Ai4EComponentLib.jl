@info "Running IncompressiblePipe..."
using Ai4EComponentLib
using Ai4EComponentLib.Electrochemistry
using OrdinaryDiffEq, ModelingToolkit
using Test

@info "Constructing components..."
@named Pv = PhotovoltaicCell()
@named R = vari_Resistor()
@named ground = Ground()

@info "Constructing system..."
eqs = [
    connect(Pv.p, R.p)
    connect(Pv.n, R.n, ground.g)
]

@named model = compose(ODESystem(eqs, t, name=:funs), [Pv, R, ground])

@info "Simplifying system..."
sys = structural_simplify(model)

@info "Solving system..."
prob = ODEProblem(sys, [], (0, 300))
sol = solve(prob, Rodas4())

@test sol.retcode == ReturnCode.Success
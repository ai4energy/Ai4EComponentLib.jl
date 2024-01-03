@info "Running IncompressiblePipe..."
using Ai4EComponentLib
using Ai4EComponentLib.IncompressiblePipe
using OrdinaryDiffEq, ModelingToolkit
using Test

@info "Constructing components..."
@named high = Source_P(D=0.15, z=25.0, ρ=1.0E3, p=101325, K_inlet=0.5)
@named low = Sink_P(p=101325)
@named elbow1 = ElbowPipe(K=0.9, D=0.15, ρ=1.0E3, zin=0.0, zout=0.0)
@named elbow2 = ElbowPipe(K=0.9, D=0.15, ρ=1.0E3, zin=15.0, zout=15.0)
@named pipe1 = SimplePipe(L=30.0, D=0.15, f=0.023, zin=25.0, zout=0.0, K_inside=0.0)
@named pipe2 = SimplePipe(L=15.0, D=0.15, f=0.023, zin=0.0, zout=15.0, K_inside=0.0)
@named pipe3 = SimplePipe(L=60.0, D=0.15, f=0.023, zin=15.0, zout=15.0, K_inside=10.8)

@info "Constructing system..."
eqs = [
    connect(high.port, pipe1.in)
    connect(pipe1.out, elbow1.in)
    connect(elbow1.out, pipe2.in)
    connect(pipe2.out, elbow2.in)
    connect(elbow2.out, pipe3.in)
    connect(pipe3.out, low.port)
]

@named model = compose(ODESystem(eqs, t, name=:funs), [high, low, pipe1, pipe2, pipe3, elbow1, elbow2])

@info "Simplifying system..."
sys = structural_simplify(model)

@info "Solving system..."
prob = ODEProblem(sys, [], (0, 0))
sol = solve(prob, Rodas4())

@test sol.retcode == ReturnCode.Success
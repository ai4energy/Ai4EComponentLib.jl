@info "Running AirPipeSim..."
using Ai4EComponentLib
using Ai4EComponentLib.AirPipeSim
using ModelingToolkit, OrdinaryDiffEq
using Test

@info "Constructing components..."
@named inlet = PressureSource(p=6e5, T=300)
@named pipe1 = AirSimplePipe(R=100, T=300)
@named pipe2 = TransitionPipe(n=20, f=0.016, D=0.2, L=100, T=300, pins=5.6e5, pouts=4e5)
@named airTank = AirStorageTank(V=20, T=300, p0=4e5)
@named pipe3 = TransitionPipe(n=20, f=0.016, D=0.2, L=100, T=300, pins=4e5, pouts=2e5)
@named outlet = PressureSource(p=2.5e5, T=300)

@info "Constructing system..."
eqs = [
    connect(inlet.port, pipe1.inlet)
    connect(pipe1.outlet, pipe2.inlet)
    connect(pipe2.outlet, airTank.inlet)
    connect(airTank.outlet, pipe3.inlet)
    connect(pipe3.outlet, outlet.port)
]

@named connects = ODESystem(eqs, t)
@named model = compose(connects, inlet, pipe1, pipe2, pipe3, airTank, outlet)

@info "Simplifying system..."
sys = structural_simplify(model)

@info "Solving system..."
prob = ODAEProblem(sys, [], (0.0, 15.0))
sol = solve(prob, Rodas4(), reltol=1e-6)

@test sol.retcode == ReturnCode.Success

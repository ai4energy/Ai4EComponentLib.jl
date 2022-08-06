using Ai4EComponentLib.CompressedAirSystem
using ModelingToolkit, DifferentialEquations
using Plots

@named inlet = PressureSource(p=6e5, T=300)
@named pipe1 = SimplePipe(R=100, T=300)
@named pipe2 = TransitionPipe(n=20, f=0.016, D=0.2, L=100, T=300, pins=5.6e5, pouts=4e5)
@named airTank = AirStorageTank(V=20, T=300, p0=4e5)
@named pipe3 = TransitionPipe(n=20, f=0.016, D=0.2, L=100, T=300, pins=4e5, pouts=2e5)
@named outlet = PressureSource(p=2.5e5, T=300)

eqs=[
    connect(inlet.port,pipe1.inlet)
    connect(pipe1.outlet,pipe2.inlet)
    connect(pipe2.outlet,airTank.inlet)
    connect(airTank.outlet,pipe3.inlet)
    connect(pipe3.outlet,outlet.port)
]

@named connects=ODESystem(eqs,t)
@named model=compose(connects,inlet,pipe1,pipe2,pipe3,airTank,outlet)

sys=structural_simplify(model)

prob=ODAEProblem(sys,[],(0.0,15.0))

#prob=DAEProblem(sys,zeros(length(states(sys))),ModelingToolkit.defaults(sys),(0.0,5.0))

sol=solve(prob,Tsit5(),reltol=1e-6)

a=plot(
    xlabel="time s",
    ylabel="mass flow rate kg/s"
)
plot!(a,sol.t,-sol[inlet.port.qm],label="inlet mass flow")
plot!(a,sol.t,sol[outlet.port.qm],label="outlet mass flow")
b=plot(
    xlabel="time s",
    ylabel="pressure bar"
)
plot!(b,sol.t,sol[airTank.p]*1e-5,label="tank pressure",legendposition=:topleft)

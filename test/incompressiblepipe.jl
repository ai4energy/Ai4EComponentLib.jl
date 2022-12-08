using Ai4EComponentLib
using Ai4EComponentLib.IncompressiblePipe
using OrdinaryDiffEq, ModelingToolkit, Test

system = []

@named pumpA = CentrifugalPump();
push!(system, pumpA);
@named pumpB = CentrifugalPump();
push!(system, pumpB);
@named pumpC = CentrifugalPump();
push!(system, pumpC);

@named pipe1 = SimplePipe(L=1.0);
push!(system, pipe1);
@named pipe2 = SimplePipe(L=10.0);
push!(system, pipe2);
@named pipe3 = SimplePipe(L=1.0);
push!(system, pipe3);
@named pipe4 = SimplePipe(L=10.0);
push!(system, pipe4);
@named pipe5 = SimplePipe(L=5.0);
push!(system, pipe5);
@named pipe6 = SimplePipe(L=1.0);
push!(system, pipe6);
@named pipe7 = SimplePipe(L=5.0);
push!(system, pipe7);
@named pipe8 = SimplePipe(L=1.0);
push!(system, pipe8);
@named pipe9 = SimplePipe(L=10.0);
push!(system, pipe9);
@named pipe10 = SimplePipe(L=1.0);
push!(system, pipe10);

@named sink1 = Sink_P(p=1.0E5);
push!(system, sink1);
@named sink2 = Sink_P(p=1.0E5);
push!(system, sink2);
@named sink3 = Sink_P(p=1.0E5);
push!(system, sink3);
@named sink4 = Sink_P(p=1.0E5);
push!(system, sink4);
@named sink5 = Sink_P(p=1.0E5);
push!(system, sink5);

eqs = [
    connect(sink3.port, pumpA.in)
    connect(pumpA.out, pipe1.in)
    connect(pipe1.out, pipe2.in, pipe4.in)
    connect(pipe2.out, pipe3.out, pipe5.in)
    connect(sink4.port, pumpB.in)
    connect(pumpB.out, pipe3.in)
    connect(pipe5.out, pipe6.in, pipe7.in)
    connect(pipe6.out, sink1.port)
    connect(pipe4.out, pipe9.out, pipe8.in)
    connect(pipe7.out, pipe10.out, pipe9.in)
    connect(sink5.port, pumpC.in)
    connect(pipe10.in, pumpC.out)
    connect(pipe8.out, sink2.port)
]

@named model = compose(ODESystem(eqs, t, name=:funs), system)
sys = structural_simplify(model)
prob = ODEProblem(sys, [], (0, 0.0))
sol = solve(prob, Rosenbrock23())

ins = sol[pipe1.in.q][1] + sol[pipe3.in.q][1] + sol[pipe10.in.q][1]
outs = sol[pipe6.in.q][1] + sol[pipe8.in.q][1]
@test isapprox(ins, outs, atol=1.0e-10)

@info "Running ThermodynamicCycle..."
using Ai4EComponentLib
using Ai4EComponentLib.ThermodynamicCycle
using OrdinaryDiffEq, ModelingToolkit
using Test

@info "Constructing components..."
@named pump = IsentropicProcess(inter_state="P")
@named pump_P = ThermalStates(state="P", value=3.0E6)

@named boiler = IsobaricProcess(inter_state="T")
@named boiler_T = ThermalStates(state="T", value=723.15)

@named turbine = IsentropicProcess(inter_state="P")
@named turbine_P = ThermalStates(state="P", value=4.0E3)

@named condenser = IsothermalProcess(inter_state="Q_0")

@info "Constructing system..."
eqs = [
    connect(pump.out, boiler.in)
    connect(boiler.in, pump_P.node)
    connect(boiler.out, turbine.in)
    connect(turbine.in, boiler_T.node)
    connect(turbine.out, condenser.in)
    connect(condenser.in, turbine_P.node)
    connect(condenser.out, pump.in)
]

@named model = ODESystem(eqs, t, systems=[pump, boiler, turbine, condenser, pump_P, boiler_T, turbine_P])

@info "Simplifying system..."
sys = structural_simplify(model)

@info "Solving system..."
prob = ODEProblem(sys, [], (0, 0))
sol = solve(prob, Rosenbrock23())

q1 = sol[boiler.Δh][1]
w = -sol[turbine.Δh][1] - sol[pump.Δh][1]

@test isapprox(w / q1, 0.4, atol=0.05)
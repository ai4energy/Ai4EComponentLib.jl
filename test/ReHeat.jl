@info "Running ThermodynamicCycle..."
using Ai4EComponentLib
using Ai4EComponentLib.ThermodynamicCycle
using OrdinaryDiffEq, ModelingToolkit
using CoolProp
@info "Constructing components..."
@named pump = IsentropicProcess(inter_state="P")
@named pump_P = ThermalStates(state="P", value=10.0E6)

@named boiler = IsobaricProcess(inter_state="T")
@named boiler_T = DThermalStates(state="T", value=-10, u0=750 + 273.15)

@named turbine = IsentropicProcess(inter_state="P")
@named turbine_P = ThermalStates(state="P", value=3.0e6)

@named reboiler = IsobaricProcess(inter_state="T")
@named reboiler_T = ThermalStates(state="T", value=450 + 273.15)

@named returbine = IsentropicProcess(inter_state="P")
@named returbine_P = ThermalStates(state="P", value=4.0e3)

@named condenser = IsothermalProcess(inter_state="Q_0")
@info "Constructing system..."
eqs = [
    connect(pump.out, boiler.in, pump_P.node)
    connect(boiler.out, turbine.in, boiler_T.node)
    connect(turbine.out, reboiler.in, turbine_P.node)
    connect(reboiler.out, returbine.in, reboiler_T.node)
    connect(returbine.out, condenser.in, returbine_P.node)
    connect(condenser.out, pump.in)
]

@named model = ODESystem(eqs, t, systems=[pump, boiler, turbine,
    condenser, pump_P, boiler_T, turbine_P, reboiler,
    reboiler_T, returbine, returbine_P])

@info "Simplifying system..."
sys = structural_simplify(model)

prob = ODEProblem(sys, [], (0, 40), saveat=1)
sol = solve(prob, Tsit5())
@info "Solving system..."
q1 = sol[boiler.Δh] .+ sol[reboiler.Δh] |> println
w = -sol[turbine.Δh] - sol[returbine.Δh] - sol[pump.Δh] |> println
η = w ./ q1


@test true



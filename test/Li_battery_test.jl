include("Ai4EComponentLib.jl")

using ModelingToolkit, DifferentialEquations
using Plots
import Main.Ai4EComponentLib.Electrochemistry.PhotovoltaicCell
import Main.Ai4EComponentLib.Electrochemistry.lithium_ion_batteries
import Main.Ai4EComponentLib.Electrochemistry.PEMElectrolyzer
import Main.Ai4EComponentLib.Electrochemistry.Pin
import Main.Ai4EComponentLib.Electrochemistry.Ground
import Main.Ai4EComponentLib.Electrochemistry.OnePort
import Main.Ai4EComponentLib.Electrochemistry.t
import Main.Ai4EComponentLib.Electrochemistry.∂

function vari_Resistor(; name,r=1000)
    @named oneport = OnePort()
    @unpack v, i = oneport
    eqs = [
        v ~ i * r
    ]
    extend(ODESystem(eqs, t, [], []; name=name), oneport)
end

@named batter = Lithium_ion_batteries()
@named Pv = PhotovoltaicCell()
@named R = vari_Resistor()
@named ground = Ground()

eqs = [
    connect(batter.p, Pv.p)
    connect(batter.n, Pv.n, ground.g)
]

@named OdeFun = ODESystem(eqs, t)
@named model = compose(OdeFun, [Pv, batter, ground])
sys = structural_simplify(model)
u0 = [
    batter.v_f => 0.5
    batter.v_s => 0.5
    batter.v_soc => 0.5
]
prob = ODEProblem(sys, u0, (0.0, 30.0))
sol = solve(prob)
plot(sol.t, sol[batter.v_s], color = "red")
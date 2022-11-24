# include("Ai4EComponentLib.jl")

using ModelingToolkit, DifferentialEquations
using Plots

# function vari_Resistor(; name,r=1000)
#     @named oneport = OnePort()
#     @unpack v, i = oneport
#     eqs = [
#         v ~ i * r
#     ]
#     extend(ODESystem(eqs, t, [], []; name=name), oneport)
# end

# @named batter = Lithium_ion_batteries()
@named Pv = PhotovoltaicCell()
# @named R = vari_Resistor()
@named ground = Ground()
# @named sc = Super_capacity()
@named cg = charge_controller()
@named vfb = Vanadium_flow_batteries(Q = 0.01)
eqs = [
    connect(vfb.p, cg.p)
    connect(vfb.n, cg.n, ground.g)
]


@named OdeFun = ODESystem(eqs, t)
@named model = compose(OdeFun, [vfb, cg, ground])
sys = structural_simplify(model)
u0 = [
    cg.i   => -315.0
    vfb.C_av2 => 0.15
    vfb.C_av3 => 1.35
    vfb.C_av4 => 1.35
    vfb.C_av5 => 0.15
    vfb.C_tk2 => 0.15
    vfb.C_tk3 => 1.35
    vfb.C_tk4 => 1.35
    vfb.C_tk5 => 0.15
]
prob = ODEProblem(sys, u0, (0.0, 20000))
sol = solve(prob)
using PlotlyJS
PlotlyJS.plot(sol.t, sol[vfb.soc]) 

function linescatter1()
    C_av2 = scatter(;name="C_av2", x=sol.t, y=sol[vfb.C_av2], mode="lines")
    C_av3 = scatter(;name="C_av3",x=sol.t, y=sol[vfb.C_av5], mode="lines")
    C_av4 = scatter(;name="C_av4",x=sol.t, y=sol[vfb.C_tk2], mode="lines")
    C_av5 = scatter(;name="C_av5",x=sol.t, y=sol[vfb.C_tk5], mode="lines")
    plot([C_av2, C_av3, C_av4, C_av5])
end
linescatter1()
function linescatter1()
    C_av2 = scatter(;name="C_av2", x=sol.t, y=sol[vfb.C_av2], mode="lines")
    C_av3 = scatter(;name="C_av3",x=sol.t, y=sol[vfb.C_av3], mode="lines")
    C_av4 = scatter(;name="C_av4",x=sol.t, y=sol[vfb.C_av4], mode="lines")
    C_av5 = scatter(;name="C_av5",x=sol.t, y=sol[vfb.C_av5], mode="lines")
    plot([C_av2, C_av3, C_av4, C_av5])
end
linescatter1()


function test(;name)
    @named Power = Power_Pin()
    sts = @variables p(t) = 1 i(t) = 1 v(t)=30
    eqs = [
        ∂(v) ~ 0
        p ~ v * i
        p ~ Power.p
    ]
    compose(ODESystem(eqs, t, sts, []; name=name), Power)
end

@named test1 = test()
@named Pv = PhotovoltaicCell()
@named ground = Ground()
@named cg = MPPT_Controller(Sampling_time = 0.05)
eqs = [
    connect(Pv.p, cg.p)
    connect(Pv.n, cg.n, ground.g)
]


@named OdeFun = ODESystem(eqs, t)
@named model = compose(OdeFun, [Pv, cg, ground])
sys = structural_simplify(model)
u0 = [
cg.v => 1
]
prob = ODEProblem(sys, u0, (0.0, 100))
sol = solve(prob)
using PlotlyJS
PlotlyJS.plot(sol.t, sol[cg.v]) 






function Lithium_ion_batteries(; name,R_sd=1e5,C_b=3060.)
    @named oneport = OnePort()
    @unpack v, i = oneport
    sts = @variables v_b(t)=1 i_b(t)=1 v_s(t) v_f(t) v_soc(t) v_oc(v_soc)=2.8 R_0(v_soc)=0.2 R_s(v_soc)=0.5 C_s(v_soc)=100. R_f(v_soc)=7. C_f(v_soc)=1000.
    ps = @parameters(
        R_sd = R_sd,
        C_b = C_b
    )
    eqs = [
        ∂(v_s) ~ (i_b - v_s / R_s) / C_s
        ∂(v_f) ~ (i_b - v_f / R_f) / C_f
        ∂(v_soc) ~ (-i_b - v_soc / R_sd) / C_b
        v_b ~ v_oc - v_s - v_f - R_0 * i_b
        v_oc ~ -1.031 * exp(-35 * v_soc) + 3.685 + 0.2156 * v_soc - 0.1178 * v_soc^2 + 0.3201 * v_soc^3
        R_0 ~ 0.1562 * exp(-24.37 * v_soc) + 0.07446
        R_s ~ 0.3208 * exp(-29.14 * v_soc) + 0.04669
        C_s ~ -752.9 * exp(-13.51 * v_soc) + 703.6
        R_f ~ 6.603 * exp(-155.2 * v_soc) +  0.04984
        C_f ~ -6056 * exp(-27.12 * v_soc) + 4475.
        v ~ v_b
        i ~ -i_b
    ]
    return extend(ODESystem(eqs, t, sts, ps; name=name), oneport)
end

@named ground = Ground()
@named cg = charge_controller()
@named batter = Lithium_ion_batteries()
eqs = [
    connect(batter.p, cg.p)
    connect(batter.n, cg.n, ground.g)
]


@named OdeFun = ODESystem(eqs, t)
@named model = compose(OdeFun, [batter, cg, ground])
sys = structural_simplify(model)
u0 = [
    batter.v_s   => 0.0
    batter.v_soc => 1.0
    batter.v_f => 0.0
    cg.i => 0.0
]
prob = ODEProblem(sys, u0, (0.0, 16000))
sol = solve(prob)
using PlotlyJS
PlotlyJS.plot(sol.t, sol[batter.v_b]) 
function linescatter3()
    C_av2 = scatter(;name="C_av2", x=sol.t, y=sol[batter.v_b], mode="lines")
    # C_av3 = scatter(;name="C_av3",x=sol.t, y=sol[vfb.C_tk3], mode="lines")
    # C_av4 = scatter(;name="C_av4",x=sol.t, y=sol[vfb.C_tk4], mode="lines")
    # C_av5 = scatter(;name="C_av5",x=sol.t, y=sol[vfb.C_tk5], mode="lines")
    layout = Layout(;title="Li_ion Pulse Discharge (320mA)", yaxis_range=[3., 4.2])
    plot([C_av2],layout)
end
linescatter3()
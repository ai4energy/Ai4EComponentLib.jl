# Electrochemistry System

## PhotovoltaicCell

To use `PhotovoltaicCell()`, we design a resistor called `vari_Resistor` whose resistance value changes with time. Then we can see the I-U curve of `PhotovoltaicCell` with different loads.

```@example 1
using ModelingToolkit, DifferentialEquations
using Ai4EComponentLib.Electrochemistry
using Plots

function vari_Resistor(; name)
    @named oneport = OnePort()
    @unpack v, i = oneport
    eqs = [
        v ~ i * t
    ]
    extend(ODESystem(eqs, t, [], []; name=name), oneport)
end

@named Pv = PhotovoltaicCell()
@named R = vari_Resistor()
@named ground = Ground()

eqs = [
    connect(Pv.p, R.p)
    connect(Pv.n, R.n, ground.g)
]

@named OdeFun = ODESystem(eqs, t)
@named model = compose(OdeFun, [Pv, R, ground])
sys = structural_simplify(model)
prob = ODEProblem(sys, [], (0.0, 300.0))
sol = solve(prob)
```

```@example 1
plot(sol[R.p.v], sol[R.p.i], color = "red")
savefig("example_1.svg"); nothing # hide
```

![图一](example_1.svg)

## PEMElectrolyzer

Using above PhotovoltaicCell to drive Electrolyzer, then we build a *PVEL system*. In default paraments, we can know how the system works.

```@example 2
using ModelingToolkit, DifferentialEquations
using Ai4EComponentLib.Electrochemistry

@named Pv = PhotovoltaicCell()
@named El = PEMElectrolyzer()
@named ground = Ground()
eqs = [
    connect(Pv.p, El.p)
    connect(Pv.n, El.n, ground.g)
]
@named OdeFun = ODESystem(eqs, t)
@named model = compose(OdeFun, [Pv, El, ground])
sys = structural_simplify(model)
u0 = [
    El.m_H_2 => 0.0
    El.∂_m_H_2 => 0.0
]
prob = ODEProblem(sys, u0, (0.0, 30.0))
sol = solve(prob)
```

Get states of system by `states()`

```@example 2
states(sys)
```

Check voltage, current and mass yield of electrolyzer.

```@example 2
sol[El.v]
```

```@example 2
sol[El.i]
```

```@example 2
sol[El.m_H_2]
```

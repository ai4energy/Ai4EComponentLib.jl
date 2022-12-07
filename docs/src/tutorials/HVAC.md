# HVAC System

## Example 1: A basic test for components

![图 1](../assets/HVAC-17-19-48.png)  

This test has 5 kinds of components:
- Water Chiller
- FanCoil
- Pump
- Cooling Tower
- Simple Pipe
  
```@example HVAC1
using Ai4EComponentLib
using Ai4EComponentLib.HVAC
using DifferentialEquations, ModelingToolkit

# Define components

D_ch = [22.08252111,-0.008374357,0.605004615,-0.544042021,-2.10E-07,7.04E-05,0.000299955,-0.028824777]
@named ch1 = WaterChiller_SimplifiedPolynomial(D=D_ch)
D_pump = [120,-1500,-0.5,0.8,0.8,0.8]
@named pump1 = Pump(D=D_pump)
@named pump2 = Pump(D=D_pump)

@named coolingTower1 = CoolingTower(Tw=26, ΔTct=5)

D_fan = [1, 1.2, 1.2]
@named fancoil1 = FanCoil(D=D_fan, Qf0=2500)
@named pipe1 = SimplePipe(R=100)
@named pipe2 = SimplePipe(R=100)
@named pipe3 = SimplePipe(R=100)
@named pipe4 = SimplePipe(R=100)

# Connect components
eqs = [
    connect(ch1.coolerIn, pipe1.outlet),
    connect(ch1.coolerOut, pipe2.inlet),
    connect(ch1.chilledIn, pipe3.outlet),
    connect(ch1.chilledOut, pipe4.inlet),
    connect(pipe2.outlet, coolingTower1.inlet),
    connect(coolingTower1.outlet, pump1.inlet),
    connect(pipe1.inlet, pump1.outlet),
    connect(fancoil1.inlet, pipe4.outlet),
    connect(fancoil1.outlet, pump2.inlet),
    connect(pump2.outlet, pipe3.inlet),
    pump2.inlet.p ~ 0,
    pump1.inlet.p ~ 0,
    pump1.n ~ 2000,
    pump2.n ~ 2000,
    ch1.Tei ~ 7
]

@named connects = ODESystem(eqs, t)
@named model = compose(connects, ch1, pipe1, pipe2, pipe3, pipe4, pump1, pump2, fancoil1, coolingTower1)

sys = structural_simplify(model)
prob = ODEProblem(sys, [], (0.0, 0.0))
sol = solve(prob)
```

```@example HVAC1
sol[ch1.P]
```

```@example HVAC1
sol[ch1.Tei]
```

```@example HVAC1
sol[ch1.Teo]
```

```@example HVAC1
sol[ch1.Tci]
```

```@example HVAC1
sol[ch1.Tco]
```


"""
$(TYPEDSIGNATURES)

# Component: ThermalStates

The `ThermalStates` passed a fixed value of the state that determined in process. 

# Connectors:
- `node`: A node passing value

# Arguments:
* `state`: State that determined in process. There are 5 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
* `value`: The value of the state

"""
function ThermalStates(; name, state, value)
    @named node = StreamNode()
    chs = chose_state(node, state)
    eqs = [
        chs ~ value
    ]
    compose(ODESystem(eqs, t, [], []; name=name), node)
end

"""
$(TYPEDSIGNATURES)

# Component: DThermalStates

The `DThermalStates` make the value of state changes over time. 

```math
\\frac{\\partial State}{\\partial t} = ConstantValue
```

# Connectors:
- `node`: A node passing value

# Arguments:
* `state`: State that determined in process. There are 5 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
* `value`: The value of `ConstantValue` in above formula:
* `u0`: The initial value of the state

"""
function DThermalStates(; name, state, value, u0=0)
    @named node = StreamNode()
    chs = chose_state(node, state)
    eqs = [
        ∂(chs) ~ value
    ]
    compose(ODESystem(eqs, t, [], [], defaults=Dict(chs => u0); name=name), node)
end
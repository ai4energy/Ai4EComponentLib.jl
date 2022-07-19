"""
$(TYPEDSIGNATURES)

# Component: IsobaricProcess

The `Pressure` is constant during the process. 

Once the two states in a node are determined, the remaining 3 states can be obtained from these two known states.
In IsobaricProcess, `pressure` are the same from inlet to outlet. So another state still needed. 

# Connectors:
- `in`: Inlet of process
- `out`: Outlet of process

# Arguments:
* `inter_state`: Another state need to be determined. There are 7 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
    - `"Q_0"`: Giving saturated liquid(0 is value of the state, automatically passed into ODESystem)
    - `"Q_1"`: Giving saturated vapor(1 is value of the state, automatically passed into ODESystem)
* `fluid`: The fluid passing throught the component, default: "Water"

"""
function IsobaricProcess(; name, inter_state="Q_0", fluid="Water")
    @assert inter_state != "P" "IsobaricProcess can't accept P. Please chose another state."
    @named oneport = StreamPort()
    @unpack Δp, out = oneport
    eqs = [
        Δp ~ 0]
    push!(eqs, chose_equations(out, inter_state, "P", fluid)...)
    return extend(ODESystem(eqs, t, [], []; name=name), oneport)
end

"""
$(TYPEDSIGNATURES)

# Component: IsentropicProcess

The `Entropy` is constant during the process. 

Once the two states in a node are determined, the remaining 3 states can be obtained from these two known states.
In IsentropicProcess, `entropy` are the same from inlet to outlet. So another state still needed. 

# Connectors:
- `in`: Inlet of process
- `out`: Outlet of process

# Arguments:
* `inter_state`: Another state need to be determined. There are 7 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
    - `"Q_0"`: Giving saturated liquid(0 is value of the state, automatically passed into ODESystem)
    - `"Q_1"`: Giving saturated vapor(1 is value of the state, automatically passed into ODESystem)
* `fluid`: The fluid passing throught the component, default: "Water"

"""
function IsentropicProcess(; name, inter_state="Q_0", fluid="Water")
    @assert inter_state != "S" "IsentropicProcess can't accept S. Please chose another state."
    @named oneport = StreamPort()
    @unpack Δs, out = oneport
    eqs = [
        Δs ~ 0
    ]
    push!(eqs, chose_equations(out, inter_state, "S", fluid)...)
    return extend(ODESystem(eqs, t, [], []; name=name), oneport)
end



"""
$(TYPEDSIGNATURES)

# Component: IsoenthalpyProcess

The `Enthalpy` is constant during the process. 

Once the two states in a node are determined, the remaining 3 states can be obtained from these two known states.
In IsoenthalpyProcess, `enthalpy` are the same from inlet to outlet. So another state still needed. 

# Connectors:
- `in`: Inlet of process
- `out`: Outlet of process

# Arguments:
* `inter_state`: Another state need to be determined. There are 7 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
    - `"Q_0"`: Giving saturated liquid(0 is value of the state, automatically passed into ODESystem)
    - `"Q_1"`: Giving saturated vapor(1 is value of the state, automatically passed into ODESystem)
* `fluid`: The fluid passing throught the component, default: "Water"

"""
function IsoenthalpyProcess(; name, inter_state="Q_0", fluid="Water")
    @assert inter_state != "H" "IsoenthalpyProcess can't accept H. Please chose another state."
    @named oneport = StreamPort()
    @unpack Δh, out = oneport
    eqs = [
        Δh ~ 0
    ]
    push!(eqs, chose_equations(out, inter_state, "H", fluid)...)
    return extend(ODESystem(eqs, t, [], []; name=name), oneport)
end


"""
$(TYPEDSIGNATURES)

# Component: IsochoricProcess

The `Density` is constant during the process. 

Once the two states in a node are determined, the remaining 3 states can be obtained from these two known states.
In IsochoricProcess, `density` are the same from inlet to outlet. So another state still needed. 

# Connectors:
- `in`: Inlet of process
- `out`: Outlet of process

# Arguments:
* `inter_state`: Another state need to be determined. There are 7 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
    - `"Q_0"`: Giving saturated liquid(0 is value of the state, automatically passed into ODESystem)
    - `"Q_1"`: Giving saturated vapor(1 is value of the state, automatically passed into ODESystem)
* `fluid`: The fluid passing throught the component, default: "Water"

"""
function IsochoricProcess(; name, inter_state="Q_0", fluid="Water")
    @assert inter_state != "D" "IsochoricProcess can't accept D. Please chose another state."
    @named oneport = StreamPort()
    @unpack Δρ, out = oneport
    eqs = [
        Δρ ~ 0
    ]
    push!(eqs, chose_equations(out, inter_state, "D", fluid)...)
    return extend(ODESystem(eqs, t, [], []; name=name), oneport)
end

"""
$(TYPEDSIGNATURES)

# Component: IsothermalProcess

The `Temperature` is constant during the process. 

Once the two states in a node are determined, the remaining 3 states can be obtained from these two known states.
In IsothermalProcess, `temperature` are the same from inlet to outlet. So another state still needed. 

# Connectors:
- `in`: Inlet of process
- `out`: Outlet of process

# Arguments:
* `inter_state`: Another state need to be determined. There are 7 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
    - `"Q_0"`: Giving saturated liquid(0 is value of the state, automatically passed into ODESystem)
    - `"Q_1"`: Giving saturated vapor(1 is value of the state, automatically passed into ODESystem)
* `fluid`: The fluid passing throught the component, default: "Water"

"""
function IsothermalProcess(; name, inter_state="Q_0", fluid="Water")
    @assert inter_state != "T" "IsothermalProcess can't accept T. Please chose another state."
    @named oneport = StreamPort()
    @unpack ΔT, out = oneport
    eqs = [
        ΔT ~ 0
    ]
    push!(eqs, chose_equations(out, inter_state, "T", fluid)...)
    return extend(ODESystem(eqs, t, [], []; name=name), oneport)
end


"""
$(TYPEDSIGNATURES)

# Component: ArbitraryProcess

Once the two states in a node are determined, the remaining 3 states can be obtained from these two known states. 
In `ArbitraryProcess`, 2 states need to be determined. 

# Connectors:
- `in`: Inlet of process
- `out`: Outlet of process

# Arguments:
* `inter_state`: One state to be determined. There are 7 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
    - `"Q_0"`: Giving saturated liquid(0 is value of the state, automatically passed into ODESystem)
    - `"Q_1"`: Giving saturated vapor(1 is value of the state, automatically passed into ODESystem)
* `process`: Another state to be determined. There are 5 options:
    - `"P"`: Giving state pressure
    - `"H"`: Giving state enthalpy 
    - `"T"`: Giving state temperature
    - `"D"`: Giving state density
    - `"S"`: Giving state entropy
* `fluid`: The fluid passing throught the component, default: "Water"

"""
function ArbitraryProcess(; name, inter_state="Q_0", process="T", fluid="Water")
    @named oneport = StreamPort()
    @unpack out = oneport
    eqs = push!(Equation[], chose_equations(out, inter_state, process, fluid)...)
    return extend(ODESystem(eqs, t, [], []; name=name), oneport)
end
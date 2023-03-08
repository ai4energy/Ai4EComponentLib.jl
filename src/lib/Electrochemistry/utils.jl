"""
$(TYPEDSIGNATURES)

A pin in an analog circuit.

From [ModelingToolkitStandardLibrary.jl](http://mtkstdlib.sciml.ai/dev/)

# States:
- `v(t)`: [`V`] The voltage at this pin
- `i(t)`: [`A`] The current passing through this pin
"""
@connector function Pin(; name)
    sts = @variables v(t) = 1.0 i(t) = 1.0 [connect = Flow]
    ODESystem(Equation[], t, sts, []; name=name)
end



"""
$(TYPEDSIGNATURES)

Ground node with the potential of zero and connector `g`. Every circuit must have one ground
node.

From [ModelingToolkitStandardLibrary.jl](http://mtkstdlib.sciml.ai/dev/)

# Connectors:
- `g`
"""
function Ground(; name)
    @named g = Pin()
    eqs = [g.v ~ 0]
    compose(ODESystem(eqs, t, [], []; name=name), g)
end



"""
$(TYPEDSIGNATURES)

Component with two electrical pins `p` and `n` and current `i` flows from `p` to `n`.

From [ModelingToolkitStandardLibrary.jl](http://mtkstdlib.sciml.ai/dev/)

# States:
- `v(t)`: [`V`] The voltage across component `p.v - n.v`
- `i(t)`: [`A`] The current passing through positive pin

# Parameters:
- `v_start`: [`V`] Initial voltage across the component
- `i_start`: [`A`] Initial current through the component

# Connectors:
- `p` Positive pin
- `n` Negative pin
"""
function OnePort(; name, v_start=1.0, i_start=0.0)
    @named p = Pin()
    @named n = Pin()
    sts = @variables begin
        v(t) = v_start
        i(t) = i_start
    end
    eqs = [v ~ p.v - n.v
        0 ~ p.i + n.i
        i ~ p.i]
    return compose(ODESystem(eqs, t, sts, []; name=name), p, n)
end

"""
$(TYPEDSIGNATURES)

Component with two electrical pins `p` and `n` and current `i` flows from `p` to `n`.

The component does exactly the same thing as the "OnePort" 
but its variables can not be simplified in the function "structural_simplify"

"""
function OnePort_key(; name, v_start=1.0, i_start=0.0)
    @named p = Pin()
    @named n = Pin()
    sts = @variables v(t) = v_start [irreducible = true] i(t) = i_start [irreducible = true]
    eqs = [
        v ~ p.v - n.v
        0 ~ p.i + n.i
        i ~ p.i
    ]
    compose(ODESystem(eqs, t, sts, []; name=name), p, n)
end

"""
$(TYPEDSIGNATURES)

Component with four electrical pins `p1`, `n1`, `p2` and `n2`
Current `i1` flows from `p1` to `n1` and `i2` from `p2` to `n2`.

# States:
- `v1(t)`: [`V`] The voltage across first ports `p1.v - n1.v`
- `v2(t)`: [`V`] The voltage across second ports `p2.v - n2.v`
- `i1(t)`: [`A`] The current passing through positive pin `p1`
- `i2(t)`: [`A`] The current passing through positive pin `p2`

# Parameters:
- `v1_start`: [`V`] Initial voltage across p1 and n1
- `v2_start`: [`V`] Initial voltage across p2 and n2
- `i2_start`: [`A`] Initial current through p1
- `i2_start`: [`A`] Initial current through p2

# Connectors:
- `p1` First positive pin
- `p2` Second positive pin
- `n1` First negative pin
- `n2` Second Negative pin
"""
function TwoPort(; name, v1_start=0.0, v2_start=0.0, i1_start=0.0, i2_start=0.0)
    @named p1 = Pin()
    @named n1 = Pin()
    @named p2 = Pin()
    @named n2 = Pin()
    sts = @variables begin
        v1(t) = v1_start
        i1(t) = i1_start
        v2(t) = v2_start
        i2(t) = i2_start
    end
    eqs = [v1 ~ p1.v - n1.v
        0 ~ p1.i + n1.i
        i1 ~ p1.i
        v2 ~ p2.v - n2.v
        0 ~ p2.i + n2.i
        i2 ~ p2.i]
    return compose(ODESystem(eqs, t, sts, []; name=name), p1, p2, n1, n2)
end

"""
$(TYPEDSIGNATURES)

Creates an ideal Resistor following Ohm's Law.

# States:
See [OnePort](@ref)

# Connectors:
- `p` Positive pin
- `n` Negative pin

# Parameters:
- `R`: [`Ω`] Resistance
"""
function Resistor(; name, R=1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    pars = @parameters R = R
    eqs = [
        v ~ i * R,
    ]
    extend(ODESystem(eqs, t, [], pars; name=name), oneport)
end

"""
$(TYPEDSIGNATURES)

Creates an Resistor whose value increases with time.

# States:
See [OnePort](@ref)

# Connectors:
- `p` Positive pin
- `n` Negative pin

# Parameters:
- `R`: [`Ω`] Resistance
"""
function vari_Resistor(; name, R=1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    pars = @parameters R = R
    eqs = [
        v ~ i * R * t,
    ]
    extend(ODESystem(eqs, t, [], pars; name=name), oneport)
end


"""
$(TYPEDSIGNATURES)

Creates an ideal conductor.

# States:
See [OnePort](@ref)

# Connectors:
- `p` Positive pin
- `n` Negative pin

# Parameters:
- `G`: [`S`] Conductance
"""
function Conductor(; name, G)
    @named oneport = OnePort()
    @unpack v, i = oneport
    pars = @parameters G = G
    eqs = [
        i ~ v * G,
    ]
    extend(ODESystem(eqs, t, [], pars; name=name), oneport)
end

"""
$(TYPEDSIGNATURES)

Creates an ideal capacitor.

# States:
- `v(t)`: [`V`] The voltage across the capacitor, given by `D(v) ~ p.i / C`

# Connectors:
- `p` Positive pin
- `n` Negative pin

# Parameters:
- `C`: [`F`] Capacitance
- `v_start`: [`V`] Initial voltage of capacitor
"""
function Capacitor(; name, C, v_start=0.0)
    @named oneport = OnePort(; v_start=v_start)
    @unpack v, i = oneport
    pars = @parameters C = C
    eqs = [
        ∂(v) ~ i / C,
    ]
    extend(ODESystem(eqs, t, [], pars; name=name), oneport)
end

"""
$(TYPEDSIGNATURES)

Creates an ideal Inductor.

# States:
See [OnePort](@ref)

# Connectors:
- `p` Positive pin
- `n` Negative pin

# Parameters:
- `L`: [`H`] Inductance
- `i_start`: [`A`] Initial current through inductor
"""
function Inductor(; name, L, i_start=0.0)
    @named oneport = OnePort(; i_start=i_start)
    @unpack v, i = oneport
    pars = @parameters L = L
    eqs = [
        ∂(i) ~ 1 / L * v,
    ]
    extend(ODESystem(eqs, t, [], pars; name=name), oneport)
end

"""
$(TYPEDSIGNATURES)  

Acts as an ideal voltage source with no internal resistance.

# States:
See [OnePort](@ref)

# Connectors:
- `p` Positive pin
- `n` Negative pin
- `u` [RealInput](@ref) Input for the voltage control signal, i.e. `V ~ p.v - n.v`
"""
function Voltage_source(; name)
    @named oneport = OnePort()
    @unpack v, i = oneport
    @named u = RealInput()
    eqs = [
        v ~ u.u,
    ]

    extend(ODESystem(eqs, t, [], []; name=name, systems=[u]), oneport)
end

"""
$(TYPEDSIGNATURES)   

Acts as an ideal current source with no internal resistance.

# States:
See [OnePort](@ref)

# Connectors:
- `p` Positive pin
- `n` Negative pin
- `u` [RealInput](@ref) Input for the current control signal, i.e. `I ~ p.i
"""
function Current_source(; name)
    @named oneport = OnePort()
    @unpack v, i = oneport
    @named u = RealInput()
    eqs = [
        i ~ u.u,
    ]

    extend(ODESystem(eqs, t, [], []; name=name, systems=[u]), oneport)
end

"""
$(TYPEDSIGNATURES) 

Connector with one input signal of type Real.

# Parameters:
- `nin=1`: Number of inputs
- `u_start=0`: Initial value for `u`  

# States:
- `u`: Value of of the connector; if nin=1 this is a scalar
"""
@connector function RealInput(; name, nin=1, u_start=nin > 1 ? zeros(nin) : 0.0)
    if nin == 1
        @variables u(t) = u_start [input = true]
    else
        @variables u(t)[1:nin] = u_start [input = true]
        u = collect(u)
    end
    ODESystem(Equation[], t, [u...], []; name=name)
end

"""
$(TYPEDSIGNATURES) 

Connector with one output signal of type Real.

# Parameters:
- `nout=1`: Number of inputs
- `u_start=0`: Initial value for `u`  

# States:
- `u`: Value of of the connector; if nout=1 this is a scalar
"""
@connector function RealOutput(; name, nout=1, u_start=nout > 1 ? zeros(nout) : 0.0)
    if nout == 1
        @variables u(t) = u_start [output = true]
    else
        @variables u(t)[1:nout] = u_start [output = true]
        u = collect(u)
    end
    ODESystem(Equation[], t, [u...], []; name=name)
end

"""
$(TYPEDSIGNATURES) 

Generate constant signal.

# Parameters:
- `U`: Constant output value

# Connectors:
- `u`
"""
function Constant(; name, U=1)
    @named u = RealOutput()
    pars = @parameters U = U
    eqs = [
        u.u ~ U,
    ]
    compose(ODESystem(eqs, t, [], pars; name=name), [u])
end
"""
$(TYPEDSIGNATURES) 

Generate secrete signal.

# Parameters:
- `data_name`: the name of datafile
- `output_type`: the type of sample time includes `s` or `min` or `hour` or `day`

# Connectors:
- `u`
"""
function Secrete(data; name, output_type="s")
    @named u = RealOutput()
    n = ifelse(output_type == "s", 1,
        ifelse(output_type == "min", 60,
            ifelse(output_type == "hour", 3600, 86400)))
    eqs = [
        u.u ~ get_datas(t / n, data)
    ]
    compose(ODESystem(eqs, t, [], []; name=name), [u])
end

function get_datas(t, data)
    getindex(data, Int(floor(t) + 1))
end
@register_symbolic get_datas(t, data::Array)

"""
$(TYPEDSIGNATURES) 

Simulated load.

# Connectors:
- `u`
"""
function electronic_load(; name)
    @named oneport = OnePort()
    @unpack v, i = oneport
    @named u = RealInput()
    ps = []
    eqs = [
        v * i ~ u.u
    ]
    return extend(compose(ODESystem(eqs, t, [], ps; name=name), [u]), oneport)
end
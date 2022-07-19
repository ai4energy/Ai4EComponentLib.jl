
@variables t
∂ = Differential(t)

PropsSI(out::AbstractString, name1::AbstractString, value1::Real, name2::AbstractString, value2::Real, fluid::AbstractString) = CoolProp.PropsSI(out, name1, value1, name2, value2, fluid)
@register PropsSI(out::AbstractString, name1::AbstractString, value1::Real, name2::AbstractString, value2::Real, fluid::AbstractString)

"""
$(TYPEDSIGNATURES)

A stream node(inlet or outlet) in a thermodynamic cycle system. 
There are five states in a node: pressure, enthalpy, temperature, density, entropy.

# States:
- `p(t)`: [`Pa`] The pressure at this node
- `h(t)`: [`J/kg`] The enthalpy at this node
- `T(t)`: [`K`] The temperature at this node
- `ρ(t)`: [`kg/m³`] The density at this node
- `s(t)`: [`J/(kg·K)`] The entropy at this node

"""
@connector function StreamNode(; name)
    sts = @variables begin
        p(t) = 1.0e5
        h(t) = 1.0e5
        T(t) = 300.0
        ρ(t) = 1.0e5
        s(t) = 1.0e5
    end
    ODESystem(Equation[], t, sts, []; name=name)
end


"""
$(TYPEDSIGNATURES)

Component with two stream nodes `in` and `out` and some variables between `in` and `out`.

# States:
- `Δp(t)`: [`Pa`] The pressure at this node
- `Δh(t)`: [`J/kg`] The enthalpy at this node
- `ΔT(t)`: [`K`] The temperature at this node
- `Δρ(t)`: [`kg/m³`] The density at this node
- `Δs(t)`: [`J/(kg·K)`] The entropy at this node

# Connectors:
- `in` inlet of components
- `out` outlet of components
"""
function StreamPort(; name)
    @named in = StreamNode()
    @named out = StreamNode()
    sts = @variables begin
        Δp(t) = 1.0e5
        Δh(t) = 1.0e5
        ΔT(t) = 300.0
        Δρ(t) = 1.0e5
        Δs(t) = 1.0e5
    end
    eqs = [
        Δp ~ out.p - in.p
        Δh ~ out.h - in.h
        ΔT ~ out.T - in.T
        Δρ ~ out.ρ - in.ρ
        Δs ~ out.s - in.s
    ]
    compose(ODESystem(eqs, t, sts, []; name=name), in, out)
end

function chose_equations(out, inter_state, process, fluid="Water")
    ps = ["H", "S", "P", "D", "T", "Q_0", "Q_1"]
    @assert inter_state in ps "Please check the *inter_state*, it must be one of state in $(ps)"
    @assert process in ps[1:5] "Please check the *process*, it must be one of state in $(ps[1:5])"
    index_process = findfirst(x -> x == process, ps)
    index_input = findfirst(x -> x == inter_state, ps)
    nums = [out.h, out.s, out.p, out.ρ, out.T]
    eqs = []
    if index_input == 6 || index_input == 7
        state_val = index_input == 6 ? 0 : 1
        for i in 1:5
            if i != index_process
                push!(eqs, nums[i] ~ PropsSI(ps[i], ps[index_process], nums[index_process], "Q", state_val, fluid))
            end
        end
    else
        for i in 1:5
            if !(i == index_process || i == index_input)
                push!(eqs, nums[i] ~ PropsSI(ps[i], ps[index_process], nums[index_process], ps[index_input], nums[index_input], fluid))
            end
        end
    end
    return eqs
end

function chose_state(node, state)
    ps = ["H", "S", "P", "D", "T"]
    @assert state in ps "Please check the ThermalStates's state, it must be one of state in $(ps)"
    nums = [node.h, node.s, node.p, node.ρ, node.T]
    ind = findfirst(x -> x == state, ps)
    return nums[ind]
end

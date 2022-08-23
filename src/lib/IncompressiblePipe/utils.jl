
@variables t
∂ = Differential(t)
const gn = Unitful.gn.val

"""
$(TYPEDSIGNATURES)

A pipe port(inlet or outlet) in an pipe network.

# States:
- `p(t)`: [`Pa`] The pressure at this port
- `q(t)`: [`m³/s`] The volume flow passing through this port

# Parameters:
* `z`: [`m`] The hight of port, expressing potential energy

"""
@connector function PipeNode(; name, z=0)
    sts = @variables begin
        p(t) = 1.0
        (q(t)=1.0, [connect = Flow])
    end
    ps = @parameters z = z
    ODESystem(Equation[], t, sts, ps; name=name)
end



"""
$(TYPEDSIGNATURES)

To get the energy at the port.

The governing equation of incompressible pipe network is Bernoulli Equation: 

```math
\\frac{p}{\\rho g} +\\frac{v^{2}}{2g} + z=\\mathrm{constant}
```

In volume flow form:

```math
\\frac{p}{\\rho g} +\\frac{8q^{2}}{\\pi^2D^4g} + z=\\mathrm{constant}
```

* `D`: [`m`] Diameter of pipe
* `ρ`: [`m³/kg] The density of fluid passing the port

"""
function _NodeEnergy(node, D, ρ)
    return node.p / (ρ * gn) + node.z + 8 * abs2(node.q) / (π^2 * D^4 * gn)
end



"""
$(TYPEDSIGNATURES)

To get the loss of resistance along the pipe(between two ports).

In volume flow form:

```math
h_f = f\\frac{L}{D} \\frac{8q^{2}}{\\pi^2D^4g}
```

"""
function _h_f(node, f, L, D)
    return f * L * 8 / (D^5 * π^2 * gn) * node.q * abs(node.q)
end


"""
$(TYPEDSIGNATURES)

To get the local resistance loss the components.

In volume flow form:

```math
h_m = K \\frac{8q^{2}}{\\pi^2D^4g}
```

"""
function _h_m(node, K, D)
    return K * 8 / (D^4 * π^2 * gn) * node.q * abs(node.q)
end
"""
$(TYPEDSIGNATURES)

A pipe port(inlet or outlet) in an pipe network.

# States:
- `p(t)`: [`Pa`] The pressure at this port
- `qm(t)`: [`kg/s`] The mass flow rate passing through this port

# Parameters:
* `T`: [`K`] The temperature of port. It'll be used in future develop.

"""
@connector function FlowPort(; name, T=300)
    sts = @variables begin
        p(t) = 1.013e5
        (qm(t)=0, [connect = Flow])
    end
    ps = @parameters T = T
    ODESystem(Equation[], t, sts, ps; name=name)
end
"""
$(TYPEDSIGNATURES)

A pipe port(inlet or outlet) in an pipe network.

# States:
- `p(t)`: [`Pa`] The pressure at this port
- `q(t)`: [`m³/s`] The volume flow passing through this port
- `T(t)`: [`K`] The temperature at this port
"""
@connector function FlowPort(; name, T0=30.0)
    sts = @variables begin
        p(t) = 1.013e5
        (qm(t)=1, [connect = Flow])
        (T(t)=T0, [output = true])
    end
    ODESystem(Equation[], t, sts, []; name=name)
end
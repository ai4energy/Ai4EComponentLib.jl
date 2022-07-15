
@variables t
∂ = Differential(t)

@connector function FlowPort(; name, T=300)
    sts = @variables begin
        p(t) = 1.013e5
        (qm(t)=0, [connect = Flow])
    end
    ps = @parameters T = T
    ODESystem(Equation[], t, sts, ps; name=name)
end
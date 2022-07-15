function PressureSource(; name, p=1.013e5)
    @named port = FlowPort(T=300)
    eqs = [
        port.p ~ p
    ]
    compose(ODESystem(eqs, t, [], []; name=name), port)
end

function FlowSource(; name, qm=100.0)
    @named port = FlowPort(T=300)
    eqs = [
        port.qm ~ -qm
    ]
    compose(ODESystem(eqs, t, [], []; name=name), port)
end
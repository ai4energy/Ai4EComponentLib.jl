
"""
$(TYPEDSIGNATURES)

Variable speed compressor.

```math
h_polCoff = a1 * inlet.qv^2 + a2 * inlet.qv * n / n0 + a3 * (n / n0)^3) * g
```

```math
etaCoff = b1 * inlet.qv^2 * (n0 / n)^2 + b2 * inlet.qv * n0 / n + b3
```

```math
surgeCoff = (c1 * n * n + c2 * n + c3) / 3600
```

```math
chokeCoff = (d1 * n * n + d2 * n + d3) / 3600
```

# States:
-  `qm(t)`: [`kg/s`] The mass flow rate
-  `n(t)`: [`rpm`] speed
-  `ϵ(t)`: pressure ratio
-  `h_pol(t)`: [`J`] Energy head
-  `h_tot(t)`: [`J`] Total Work
-  `eta_pol(t)`: Surge limit coefficient
-  `qv_surge(t)`: [`kg/s`] Surge flow rate
-  `qv_choke(t)`: [`kg/s`] choke flow rate
-  `σ(t)`

# Arguments:
-  `n0`: [`rpm`] Rated speed
-  `h_polCoff`: Work coefficient
-  `etaCoff`: Efficiency coefficient
-  `surgeCoff`: Surge limit coefficient
-  `chokeCoff`: Choke limit coefficient

# Connectors:
- `inlet` inlet of components
- `outlet` outlet of components
"""
function VarySpeedCompressor(; name, n0=4000, h_polCoff, etaCoff, surgeCoff, chokeCoff)
    @named inlet = FlowPort()
    @named outlet = FlowPort()
    sts = @variables begin
        qm(t)
        n(t) 
        ϵ(t)  
        h_pol(t)    
        h_tot(t)   
        eta_pol(t)  
        qv_surge(t)
        qv_choke(t)
        σ(t)
    end
    initialValue = [
        qm => 6.4
        n => 4000
        ϵ => 1.6
        h_pol => 6e4
        h_tot => 6e4
        eta_pol => 0.85
        qv_surge => 6
        qv_choke => 9
        σ => 3
        inlet.qv => 7.5
    ]
    ps = @parameters begin
        g = 9.8
        n0 = n0
        k = 1.4
        a1 = h_polCoff[1]
        a2 = h_polCoff[2]
        a3 = h_polCoff[3]
        b1 = etaCoff[1]
        b2 = etaCoff[2]
        b3 = etaCoff[3]
        c1 = surgeCoff[1]
        c2 = surgeCoff[2]
        c3 = surgeCoff[3]
        d1 = chokeCoff[1]
        d2 = chokeCoff[2]
        d3 = chokeCoff[3]
    end
    eqs = [
        qm ~ inlet.qm
        inlet.qm + outlet.qm ~ 0
        h_pol ~ IfElse.ifelse(inlet.qv >= qv_choke,
            (a1 * qv_choke^2 + a2 * qv_choke * n / n0 + a3 * (n / n0)^3) * g,
            IfElse.ifelse(inlet.qv <= qv_surge,
                (a1 * qv_surge^2 + a2 * qv_surge * n / n0 + a3 * (n / n0)^3) * g,
                (a1 * inlet.qv^2 + a2 * inlet.qv * n / n0 + a3 * (n / n0)^3) * g
            )
        )
        eta_pol ~ IfElse.ifelse(inlet.qv >= qv_choke,
            b1 * qv_choke^2 * (n0 / n)^2 + b2 * qv_choke * n0 / n + b3,
            IfElse.ifelse(inlet.qv <= qv_surge,
                b1 * qv_surge^2 * (n0 / n)^2 + b2 * qv_surge * n0 / n + b3,
                b1 * inlet.qv^2 * (n0 / n)^2 + b2 * inlet.qv * n0 / n + b3
            )
        )
        qv_surge ~ (c1 * n * n + c2 * n + c3) / 3600
        qv_choke ~ (d1 * n * n + d2 * n + d3) / 3600
        h_tot ~ h_pol / eta_pol
        σ ~ eta_pol * k / (k - 1)
        h_pol ~ σ * 287.11 * (outlet.T - inlet.T)
        ϵ ~ (abs(outlet.T / inlet.T))^σ
        ϵ ~ outlet.p / inlet.p
    ]
    compose(ODESystem(eqs, t, sts, ps; name=name, defaults=initialValue), inlet, outlet)
end
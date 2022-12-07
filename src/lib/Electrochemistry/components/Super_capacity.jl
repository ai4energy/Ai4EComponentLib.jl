"""
$(TYPEDSIGNATURES)

# Component: Super_capacity with 6 Paramenters

# States:
* `v_b`: [`V`] Load voltage
* `i_b`: [`A`] Load current
* `v_0`: [`V`] Voltage through the capacity of the first branch
* `v_2`: [`V`] Voltage through the capacity of the second branch

# Paramenters:
- R_0: Series resistor of the first branch
- C_0: Constant capacity of the first branch
- K_v: Proportionality coefficient term
- R_2: Series resistor of the second branch
- C_2: Constant capacity of the second branch
- R_EPR: self_discharge resistor

# Connectors:
- `p` Positive pin
- `n` Negative pin

Reference:
R. Faranda, M. Gallina, D.T. Son, A new simplified model of double-layer capacitors, in: Proceedings of the IEEE International Conference on Clean Electrical
Power (ICEEP), May 21–23, 2007.https://ieeexplore.ieee.org/abstract/document/4272459/

"""
function Super_capacity(; name, R_0=0.0100478, C_0=89.03, K_v=29.1062, R_2=17.4976, C_2=13.7162, R_EPR = 5000.)
    @named oneport = OnePort()
    @unpack v, i = oneport
    sts = @variables v_b(t)=1 i_b(t)=-1 v_0(t) v_2(t)
    ps = @parameters(
        R_0 = R_0,
        C_0 = C_0,
        K_v = K_v,
        R_2 = R_2,
        C_2 = C_2,        
        R_EPR = R_EPR,
    )
    eqs = [
        ∂(v_0) ~ (v_b - v_0) / R_0 / (C_0 + K_v * v_b) 
        ∂(v_2) ~ (v_b - v_2) / (R_2 * C_2)
        i_b ~ v_b / R_EPR + (v_b - v_0) / R_0 + (v_b - v_2) / R_2
        v ~ v_b
        i ~ i_b
    ]
    return extend(ODESystem(eqs, t, sts, ps; name=name), oneport)
end
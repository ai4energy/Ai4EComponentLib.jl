"""
$(TYPEDSIGNATURES)

# Component: vanadium_flow_batteries with 19 Paramenters

# Connectors:
- `p` Positive pin
- `n` Negative pin

Reference:
全钒液流电池储能系统建模与控制技术-李鑫、李建林、邱亚著-机械工业出版社-ISBN 978-7-111-66341-6.

"""

function Vanadium_flow_batteries(; name, R_1=0.0396, R_2=0.0264, R_3=12.64, C_1=0.051, V_tk=10874.0, V_av=12.6, k_2=3.17e-8, k_3=7.16e-9, k_4=2.0e-8, k_5=1.25e-8, F=96485, z=1, d=2.54e-3, S=15, N_cell=117, u_eq=1.259, T=298.15, R=8.314, Q=0.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    sts = @variables v_e(t) = 0 C_tk2(t) = 1.5 C_tk3(t) = 1.5 C_tk4(t) = 1.5 C_tk5(t) = 1.5 C_av2(t) = 1.5 C_av3(t) = 1.5 C_av4(t) = 1.5 C_av5(t) = 1.5 v_s(t) = 1 i_s(t) = 1 [irreducible=true] soc(t) = 0.5
    ps = @parameters(
        R_1 = R_1,
        R_2 = R_2,
        R_3 = R_3,
        C_1 = C_1,
        V_tk = V_tk,
        V_av = V_av,
        k_2 = k_2,
        k_3 = k_3,
        k_4 = k_4,
        k_5 = k_5,
        F = F,
        z = z,
        d = d,
        S = S,
        N_cell = N_cell,
        u_eq = u_eq,
        T = T,
        R = R,
        Q = Q
    )
    eqs = [
        ∂(C_tk2) ~ N_cell * Q * (C_av2 - C_tk2) * 2 / V_tk
        ∂(C_tk3) ~ N_cell * Q * (C_av3 - C_tk3) * 2 / V_tk
        ∂(C_tk4) ~ N_cell * Q * (C_av4 - C_tk4) * 2 / V_tk
        ∂(C_tk5) ~ N_cell * Q * (C_av5 - C_tk5) * 2 / V_tk
        ∂(C_av2) ~ (Q * (C_tk2 - C_av2) - k_2 * C_av2 * S / d - 2 * k_5 * C_av5 * S / d - k_4 * C_av4 * S / d + i_s / z / F) * 2 / V_av
        ∂(C_av3) ~ (Q * (C_tk3 - C_av3) - k_3 * C_av3 * S / d + 3 * k_5 * C_av5 * S / d + 2 * k_4 * C_av4 * S / d - i_s / z / F) * 2 / V_av
        ∂(C_av4) ~ (Q * (C_tk4 - C_av4) - k_4 * C_av4 * S / d + 3 * k_2 * C_av2 * S / d + 2 * k_3 * C_av3 * S / d - i_s / z / F) * 2 / V_av
        ∂(C_av5) ~ (Q * (C_tk5 - C_av5) - k_5 * C_av5 * S / d - 2 * k_2 * C_av2 * S / d - k_3 * C_av3 * S / d + i_s / z / F) * 2 / V_av
        soc ~ C_tk2 / (C_tk2 + C_tk3)
        v_s ~ N_cell * (u_eq + R * T / z / F * log((C_av2 * C_av5) / (C_av3 * C_av4)))
        ∂(v_e) ~ (i - v / R_3 - i_s) / C_1
        v_e ~ i_s * R_1 + v_s
        v ~ v_e + (i - v / R_3) * R_2
    ]
    extend(ODESystem(eqs, t, sts, ps; name=name), oneport)
end
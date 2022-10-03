"""
$(TYPEDSIGNATURES)

# Component: lithium_ion_batteries with 8 Paramenters

# States:
* `v_b`: [`V`] Load voltage
* `i_b`: [`A`] Load current
* `v_s`: [`V`] Voltage through the short transient RC
* `v_f`: [`V`] Voltage through the long transient RC
* `v_soc`: [`V`] Voltage representing SOC(0~1)
* `v_oc`: [`V`] Open circuit voltage

# Paramenters:
- R_0: Series resistor
- R_s: Short transient resistor
- R_f: Long transient resistor
- R_sd: Self-discharge resistor
- C_s: Short transient capacity
- C_f: Long transient capacity
- C_b: Usable capacity
- SOC2OC: The fitting function of v_soc and v_oc

# Connectors:
- `p` Positive pin
- `n` Negative pin

Reference:
M. Chen, G.A. Rincon-Mora, Accurate electrical battery model capable of predicting runtime and i-v performance, IEEE Trans. 
    Energy Convers. 21 (2) (2006) 504–511, https://doi.org/10.1109/TEC.2006.874229.

"""
function Lithium_ion_batteries(; name, R_0=0.01, R_s=0.01, R_f=0.008, R_sd=0.5, C_s=2.5e4, C_f=8.0e3, C_b=108000., SOC2OC=[2.80595458402267,1.55152642441438,9.74740200393579,-63.9029654523517,136.818961490389,-128.826085360179,45.4027129038144])
    @named oneport = OnePort()
    @unpack v, i = oneport
    sts = @variables v_b(t)=1 i_b(t)=1 v_s(t) v_f(t) v_soc(t) v_oc(v_soc)=2.8
    ps = @parameters(
        R_0 = R_0,
        R_s = R_s,
        R_f = R_f,
        R_sd = R_sd,
        C_s = C_s,        
        C_f = C_f,
        C_b = C_b
    )
    eqs = [
        ∂(v_s) ~ (i_b - v_s / R_s) / C_s
        ∂(v_f) ~ (i_b - v_f / R_f) / C_f
        ∂(v_soc) ~ (-i_b - v_soc / R_sd) / C_b
        v_b ~ v_oc - v_s - v_f - R_0 * i_b
        v_oc ~ SOC2OC[1] + SOC2OC[2]*v_soc + SOC2OC[3]*v_soc^2 + SOC2OC[4]*v_soc^3 + SOC2OC[5]*v_soc^4 + SOC2OC[6]*v_soc^5 + SOC2OC[7]*v_soc^6
        v ~ v_b
        i ~ -i_b
    ]
    return extend(ODESystem(eqs, t, sts, ps; name=name), oneport)
end
"""
$(TYPEDSIGNATURES)

# Component: PhotovoltaicCell with 5 Paramenters

# States:
* `v(t)`: [`V`] Voltage across the Cell
* `i(t)`: [`A`] Current through the Cell

# Paramenters:
- I_ph: Photocurrent
- I_0: Reverse saturation current
- a: Correction factor
- R_s: Series resistance
- R_sh: Ohmic resistance

# Connectors:
- `p` Positive pin
- `n` Negative pin

Reference:
De Soto W, Klein S A, Beckman W A. Improvement and validation of a model for photovoltaic array performance[J]. Solar energy, 2006, 80(1):78-88.

"""
function PhotovoltaicCell(; name, I_ph=6.08, I_0=6.88e-13, a=2.3402, R_s=0.741, R_sh=457.17)
    @named oneport = OnePort()
    @unpack v, i = oneport
    ps = @parameters(
        I_ph = I_ph,
        I_0 = I_0,
        a = a,
        R_s = R_s,
        R_sh = R_sh
    )
    eqs = [
        -i ~ I_ph - I_0 * (exp((v - i * R_s) / a) - 1) - (v - i * R_s) / R_sh
    ]
    return extend(ODESystem(eqs, t, [], ps; name=name), oneport)
end
"""
$(TYPEDSIGNATURES)

# Component: DC2DC

DC2DC is a device that converts electrical energy of one voltage value into electrical energy of another voltage value in a direct current circuit.

# Parameters:
* `n`: efficiency of conversion
* `output_type`: type of "boost" includes `voltage` or `current` or `none`
* `value`: the value of outport

# Connectors:
- `in.p` Positive pin of the solar panel
- `in.n` Negative pin of the solar panel
- `out.p` Positive pin of the battery
- `out.n` Negative pin of the battery

"""
function DC2DC(; name,n = 1.0, output_type = "voltage", value = 10)
    @named in = OnePort_key()
    @named out = OnePort_key()   
    ps = @parameters (
        n = n,
        value = value
        )
        output_type == "none" ? eqs = [out.i * out.v ~ - n * in.v * in.i] : output_type == "voltage" ? eqs = [out.v ~ value, out.i ~ - n * in.v * in.i / out.v] : eqs = [out.i ~ -value, out.v ~ - n * in.v * in.i / out.i]

    return compose(ODESystem(eqs, t, [], ps; name=name), in, out)
end
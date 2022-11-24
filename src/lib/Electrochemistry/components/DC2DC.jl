"""
$(TYPEDSIGNATURES)

# Component: DC2DC

DC2DC is a device that converts electrical energy of one voltage value into electrical energy of another voltage value in a direct current circuit.

# Parameters:
* `n`: efficiency of conversion
* `type`: type of "boost" includes `voltage` or `current` or `none`
* `value`: the value of outport

# Connectors:
- `inport.p` Positive pin of the solar panel
- `inport.n` Negative pin of the solar panel
- `outport.p` Positive pin of the battery
- `outport.n` Negative pin of the battery

"""
function DC2DC(; name,n = 1.0, type = "voltage", value = 10)
    @named inport = OnePort_key()
    @named outport = OnePort_key()   
    ps = @parameters (
        n = n,
        value = value
        )
    type == "none" ? eqs = [outport.i * outport.v ~ - n * inport.v * inport.i] : type == "voltage" ? eqs = [outport.v ~ value, outport.i ~ - n * inport.v * inport.i / outport.v] : eqs = [outport.i ~ -value, outport.v ~ - n * inport.v * inport.i / outport.i]

    return compose(ODESystem(eqs, t, [], ps; name=name), inport, outport)
end
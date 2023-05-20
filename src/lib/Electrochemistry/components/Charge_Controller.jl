"""
$(TYPEDSIGNATURES)

# Component: charge_controller

The charge controller can maintain a constant current and change the current at a specific time.

# Parameters:
* `time`: The time the current is changed
* `value`: The value of current after `time`

# Connectors:
- `p` Positive pin
- `n` Negative pin

"""
function charge_controller(; name,time = 5., value = 1.)
    @named oneport = OnePort()
    @unpack v, i = oneport
    ps = @parameters(
        time = time,
        value = value
    )
    eqs = [∂(i) ~ 0]
    continuous_events  = [
        [t ~ time] => [i ~ value],
    ]
    return extend(ODESystem(eqs, t, [], ps; name=name,continuous_events =continuous_events), oneport)
end
































# function charge_controller(;name)
#     @named oneport = OnePort()
#     @unpack v, i = oneport
#     n = 20000
#     eval(quote
#     function charge_current(t)
#         if t<=5000
#             return 5
#         elseif 5000<t<=10000
#             return 0
#         elseif 10000<t<=15000
#             return 5
#         elseif 15000<t<=$(n)
#             return 0
#         elseif $(n)<t<=$(n+5000)
#             return 5
#         # elseif 54999<t<=59999
#         #     return 0
#         # elseif 30000<t<=35000
#         #     return -5
#         # elseif 35000<t<=40000
#         #     return 0
#         # elseif 40000<t<=45000
#         #     return 5
#         # elseif 45000<t<=50000
#         #     return 0
#         # elseif 50000<t<=55000
#         #     return -5
#         # elseif 55000<t<=60000
#         #     return 0   
#         else
#             return 0
#         end
#     end
#     @register_symbolic charge_current(t)
#     end)
#     eqs = [i~charge_current(t)]
#     return extend(ODESystem(eqs, t, [], []; name=name), oneport)
# end


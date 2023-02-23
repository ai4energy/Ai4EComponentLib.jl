function step_v(dp, du)
    dp * sign(du) >= 0 ? 0.1 : -0.1
end
@register step_v(dp, du)

"""
$(TYPEDSIGNATURES)

# Component: MPPT_controller

The MPPT controller can detect the generating voltage of the solar panel in real time, and track the maximum voltage current value (VI), so that the system can charge the battery at the maximum power output. 

# Parameters:
* `Sampling_time`: Voltage sampling time

# Connectors:
- `in.p` Positive pin of the solar panel
- `in.n` Negative pin of the solar panel
- `out.p` Positive pin of the battery
- `out.n` Negative pin of the battery

"""
function MPPT_Controller(; name,Sampling_time = 0.1)
    @named in = OnePort_key()
    @named out = OnePort() 
    sts = @variables v_last(t) = 1 p_new(t) = 1 [irreducible=true] p_last(t) = 1 tmp(t) = 0
    discrete_events = [Sampling_time => [tmp ~ in.v, in.v ~ in.v + step_v(p_new - p_last, in.v - v_last), p_last ~ tmp * in.i, v_last ~ tmp]]
    eqs = [
        p_new ~ in.v * in.i
        ∂(v_last) ~ 0
        ∂(in.v) ~ 0
        ∂(p_last) ~ 0
        ∂(tmp) ~ 0
        out.v ~ in.v
        out.i ~ -in.i
        ]
    return compose(ODESystem(eqs, t, sts, []; name=name,discrete_events=discrete_events), [in,out])
end

function MPPT_Controller_2Pin(; name,Sampling_time = 0.1)
    @named oneport = OnePort()
    @unpack v, i = oneport
    sts = @variables v_last(t) = 1 p_new(t) = 1 [irreducible=true] p_last(t) = 1 tmp(t) = 0
    discrete_events = [Sampling_time => [tmp ~ v, v ~ v + step_v(p_new - p_last, v - v_last), p_last ~ tmp * i, v_last ~ tmp]]
    eqs = [
        p_new ~ v * i
        ∂(v_last) ~ 0
        ∂(v) ~ 0
        ∂(p_last) ~ 0
        ∂(tmp) ~ 0
        ]
    return extend(ODESystem(eqs, t, sts, []; name=name,discrete_events=discrete_events), oneport)
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
#     @register charge_current(t)
#     end)
#     eqs = [i~charge_current(t)]
#     return extend(ODESystem(eqs, t, [], []; name=name), oneport)
# end


"""


The port through which money flows.

# States:
- `p(t)`: Price of good
- `w(t)`: Wage(per hour)
- `l(t)`: Labor
- `c(t)`: Consumption
- `𝛌₁(t),𝛌₂(t),𝛌₃(t)`:Parameters that result from the constraint force for the change in consumption and varies over time.

# Parameters:
* `α,β`: Parameters in a simple Cobb-Douglas production function.
* `K₀`: Initial value of Capital.
"""
@connector function Capitalflow(; name, β=0.011, K₀=0.1, α=0.05)
    ps = @parameters begin
        β = β
        K₀ = K₀
        α = α
    end
    sts = @variables begin
        (p(t)=0.8, [output = true])
        (w(t)=1.2, [output = true])
        (l(t)=0.8, [output = true])
        (c(t)=1.22, [output = true])
        (𝛌₁(t)=-0.1, [output = true])
        (𝛌₂(t)=-0.3, [output = true])
        (𝛌₃(t)=0.4, [output = true])
    end
    ODESystem(Equation[], t, sts, ps; name=name)
end
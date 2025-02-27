export Curado
import Base.maximum
"""
    Curado <: Entropy
    Curado(; b = 1.0)

The Curado entropy (Curado & Nobre, 2004)[^Curado2004], used with [`entropy`](@ref) to
compute

```math
H_C(p) = \\left( \\sum_{i=1}^N e^{-b p_i} \\right) + e^{-b} - 1,
```

with `b ∈ ℛ, b > 0`, where the terms outside the sum ensures that ``H_C(0) = H_C(1) = 0``.

[^Curado2004]: Curado, E. M., & Nobre, F. D. (2004). On the stability of analytic
    entropic forms. Physica A: Statistical Mechanics and its Applications, 335(1-2), 94-106.
"""
Base.@kwdef struct Curado{B} <: Entropy
    b::B = 1.0

    function Curado(b::B) where B <: Real
        b > 0 || throw(ArgumentError("Need b > 0. Got b=$(b)."))
        return new{B}(b)
    end
end

function entropy(e::Curado, probs::Probabilities)
    b = e.b
    return sum(1 - exp(-b*pᵢ)  for pᵢ in probs) + exp(-b) - 1
end

function maximum(e::Curado, L::Int)
    b = e.b
    # Maximized for the uniform distribution, which for distribution of length L is
    return L * (1 - exp(-b/L)) + exp(-b) - 1
end

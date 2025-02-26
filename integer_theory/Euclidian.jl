
function GCD(a::Integer, b::Integer)::Integer
    if b == 0
        return a 
    end
    return GCD(b, a % b)
end

function Z_LinearCombo(a::Integer, b::Integer)::Tuple{Integer, Integer}
    if b == 0
        return (1, 0)
    end
    x, y = Z_LinearCombo(b, a % b)
    return (y, x - div(a, b) * y)
end

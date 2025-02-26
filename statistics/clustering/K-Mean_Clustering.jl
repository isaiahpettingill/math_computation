function EuclidianDistance(a::Tuple{<:Real, <:Real}, b::Tuple{<:Real, <:Real})::Real
    sqrt((b[1] - a[1])^2 + (b[2] - a[2])^2)
end

function GetCentroid(points::Vector{<:Tuple{<:Real, <:Real}})::Tuple{Real,Real}
    x = map(p -> p[1], points)
    y = map(p -> p[2], points)
    cnt = length(points)
    (sum(x)/cnt, sum(y)/cnt)
end
